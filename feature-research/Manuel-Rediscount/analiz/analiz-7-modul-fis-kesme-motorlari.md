# analiz-7 — Modüllerin reeskont fiş kesme motorları (MM · OptionsFX · DerivSwp · FX)

> 2026-09-26. Kaynak: 4 paralel kod incelemesi (salt-okunur). "MEVCUT" = commit'lenmiş kod (HEAD).
> "ÖNERİLEN" = `stash@{0}` ("melih abinin son istediği maddeler eklendi") — 2-1 nötrleme sırası, 30 limiti,
> `CreateReverse`. Satır numaraları ilgili repodaki dosyalara göredir.

## 1. Ortak tablo

| | MM | OptionsFX | DerivSwp | FX |
|---|---|---|---|---|
| Mimari | Pipeline, `Order` sıralı adımlar (`01_…`, `05_…`) | Generic `PipelineBuilder.AddStep<TStep,TIn,TOut>` (adım **imzaya göre** çözülüyor) | `IOperation` + `AccountingExecutorBase` (motor facade) + düz servisler | Valuation servisleri + `RevaluationReverseOperation` + muhasebe executer'ları |
| Fiş satırları | tek `SaveChanges` (satır satır değil) | tek `SaveChanges` | tek `SaveChanges` | tek `SaveChanges` (ama başlık önce INSERT, sonra MessageKey için UPDATE) |
| Commit'i kim atıyor | her servis kendisi | her servis kendisi | **çağıran** (handler/batch); mirror kendisi | gizli commit'ler: `Forward` (RRO:94), executer (FXEXEC:119), external AddValuation (EVO:56) + handler |
| Transaction | yok — her commit bağımsız | yok | yok | **satır başına `TransactionScope(RequiresNew)`** — tüm commit'ler ancak `scope.Complete()`'te kalıcı |
| Id üretimi | `sp_GetNewNumbers`, ayrı Dapper bağlantısı → txn dışı, hata olursa boşluk | aynı (önek 99) | **EF read-modify-write** `defNumberGen`, fişle aynı SaveChanges → boşluk yok ama kilit yok (yarış → PK ihlali) | `sp_NewNumber`, `Suppress` scope → hemen kalıcı, boşluk |
| Sıra | Fimple → Id → DB stage → Kafka → Commit | aynı | Fimple → stage → Kafka → Commit | Id → SaveChanges (kalıcı değil) → Fimple → Kafka → … → Complete |
| Kafka | fire-and-forget, commit ÖNCESİ, hata Information log | aynı | try/catch yutuluyor, commit öncesi | await (sync-over-async), scope Complete ÖNCESİ |
| Fimple idempotency | her çağrıda yeni Guid → retry = mükerrer | — | — | yeni Guid; ters-alma (key ile) tekrar denemede idempotent sayılıyor |
| Tracker reset | satır başı + catch | satır başı + catch + her servis sonrası | satır başı + catch + her commit sonrası | her engine çağrısı sonrası |

## 2. Satır başına commit sayısı (tek tarih)

| Senaryo | MM | OptionsFX | DerivSwp | FX (native) |
|---|---|---|---|---|
| Generate / NotRediscounted | 1 | 1 | 1 | 2 (executer + handler) |
| Generate / NotReversed | 1 | 1 | 1 | 1 |
| Regenerate / NotRediscounted | 2 | 2 | 2 | 3 |
| Regenerate / NotReversed | 3 | 3 | 3 | 4 |
| Regenerate / Rediscounted | 4 | 4 | 4 | 4 |

`CreateReverse = false` (öneri) her satırda 1 eksik. `RegenerateToToday` gün sayısıyla çarpar (en fazla 31).
FX hariç hepsinde bu commit'ler **bağımsız**: ortada patlarsa öncekiler DB'de kalır.

## 3. Hata matrisi — ortak desen

| Hata noktası | DB | Fimple | Kafka |
|---|---|---|---|
| Hesap / motor / validasyon (Fimple öncesi) | yok | yok | yok |
| Fimple OK, sonra Id / stage / commit patladı | yok (FX: scope geri alır) | **yetim fiş** | MM/OptFX/Deriv: commit başarısızsa **hayalet mesaj**; FX: mesaj gitti, Accounting DB'de **yetim satır** (consumer upsert) |
| Fimple HTTP cevabı kayboldu | yok | fiş var | — ; retry **mükerrer** (yeni Guid) |
| Kafka düştü | commit OK | OK | **sessizce eksik** |
| **Regenerate/Rediscounted: ayna çifti commit'lendi, yeni reeskont patladı** (MM/OptFX/Deriv) | orijinal + ayna → gün net 0; en büyük Id'li reeskont = **ayna** → statü hâlâ **Rediscounted** | gitti | gitti | → retry **aynanın aynasını** keser = orijinal tutar geri gelir + yeni reeskont → **gün ÇİFT** |
| MEVCUT ayna: ayna commit, tersi patladı (MM/OptFX/Deriv) | ayna ReverseId=0 → NotReversed | ayna gitti | ayna gitti | retry: aynayı T+0 terslerse + yeni → **çift** |

Kök sebep: `GetRevaluationByValueDateAsync` (IsReverse=false, Type=Revaluation, ValueDate=T, max Id) aynayı
gerçek reeskonttan ayırt edemiyor.

## 4. Modüle özel bulgular

**MM**
- Reverse adımı Fimple'ı **kaynak fiş yüklenmeden önce** çağırıyor; `MessageKey == 0` ise Fimple atlanıyor.
- `AccountingDataManager.InsertAsync` kural sayısı = satır sayısı varsayıyor (IndexOutOfRange Fimple'dan SONRA).
- Regenerate'teki `created` yeniden okuması eski fişi/aynayı bulabiliyor → NoAccrual kontrolü pratikte ölü.
- Batch'te tracker reset yok; bir hata sonraki işlemin commit'ine taşınabilir.

**OptionsFX**
- Adımlar imzaya göre çözülüyor: 5 InternalSync adımı aynı imzada → log'da yanlış sınıf adı; birini değiştiren
  diğer akışları sessizce değiştirir (`PipelineBuilder.cs:24`).
- Reverse'te `MessageKey == 0` koruması yok (MM'de var).
- FI / müşteri (dinamik muhasebe) ayrımı her serviste.
- Sıfır tutarlı reeskont `AccountingException` → ekranda ExternalError (NoAccrual değil).

**DerivSwp**
- 🔴 `AccountingReverseService.cs:129` — müşteri tersinde `(response.MessageKey, response.MessageKey)` dönüyor:
  ters fişin **BusinessKey'i Fimple MessageKey'i ile yazılıyor**. Response'ta BusinessKey alanı var.
- FI tersinde Fimple null dönerse MessageKey sessizce 0 (reeskont yolu aynı durumda hata fırlatıyor).
- `defNumberGen` kilitsiz okuma-yazma: iki pod / ekran + EOD aynı anda → PK ihlali, ama Fimple ve Kafka çoktan gitmiş.
- Kafka reverse için repository'den de önce.
- EOD sadece belirli exception tiplerini yakalıyor; DbUpdateException koşuyu durdurur.

**FX**
- Tek scope satırın tüm günlerini + tüm engine çağrılarını kapsıyor; timeout verilmemiş → varsayılan 60 sn.
  31 günlük RegenerateToToday + yavaş Fimple → `TransactionAbortedException`, gönderilenler kalır.
- `DoReverseAccounting` başarısızlığını **kimse kontrol etmiyor** (VS:339, :363) → satır başarılı, DB ≠ Fimple.
- NotReversed + preValuation null → hiçbir şey yapılmıyor ama **Success** dönüyor.
- Rediscounted'da iç içe Kafka döngüsü (VS:368, FVS:323, EVS:471) → k² gönderim (consumer upsert ettiği için zararsız).
- External: `DeleteValuation` `Id`, valuation `LocalId` ile arıyor — farklıysa silinmiyor.
- Regenerate NotReversed 2. aşaması eski valuation'ı silmiyor → aynı gün 2 aktif valuation.
- Eski FX ekranı Swap/Pm/External'da `ReverseId == 0` filtresiyle preValuation'ı boş alıyor → mirror yok, 2. fiş.

## 5. ÖNERİLEN (stash) değişikliği hakkında incelemelerin ortak notları

- 2 numaralı fiş Fimple'a "ters al" değil **ayrı normal fiş** olarak gidiyor → Fimple'da iki fiş birbirine bağlı değil.
- Birinci Fimple gönderimi başarılı, ikincisi başarısız → T+n valörlü **yetim fiş**.
- MM / OptionsFX: `UpdateReverseIdAsync` + ikinci commit **gereksiz** (değer INSERT'te zaten var).
- MM / OptionsFX / DerivSwp: ayna çifti artık tek commit → DB'de **atomik** (iyileşme).
- FX: `updateRepository:false` zorunlu — ters kayıt henüz Added iken `UpdateAndDetach` onu Modified yapıp
  olmayan satırı UPDATE etmeye çalışırdı. FX'te artık ters bacak da Fimple hatasında exception fırlatıyor (eskiden sessizdi).
- FX: `CreateReverse=false` + RegenerateToToday → **her gün** için geçerli (yalnız son gün değil).

## 6. Test ve code review kontrol listesi

1. **Yarım kalan Regenerate/Rediscounted + retry** — ayna sonrası yeni reeskontu patlat, statüye bak, tekrar Regenerate
   et, T / T+1 bakiyesini kontrol et (MM, OptFX, Deriv). Çözüm önerisi: aynayı `Flag`/`Type` ile işaretleyip
   durum sorgusundan dışlamak.
2. **Yetim Fimple fişi** — Fimple OK + DB hatası (commit / Id üretimi) enjekte et; Fimple'da AccEntryMain'siz fiş kalıyor mu.
3. **Retry mükerrerliği** — cevap timeout'u sonrası tekrar; Fimple'da iki fiş var mı.
4. **Eşzamanlılık** — iki pod / ekran + EOD aynı işlem-gün; `InFlight` yalnız process içi.
5. **Kafka** — commit öncesi gönderiliyor; DB rollback sonrası Accounting DB'de hayalet/yetim satır.
6. **Tracker** — hatalı satır + ardından sağlam satır: sağlam satırın commit'ine yabancı AccEntry sızıyor mu (batch'te koruma yok).
7. **Statü raporu** — ExternalError'da dönen `NewStatus` ekrandaki eski statü; grid'i DB'den yenile.
8. **FX timeout** — 31 gün RegenerateToToday + yavaş Fimple.
9. **FX sessiz ters fiş hatası** — DoReverseAccounting başarısız olunca satır başarılı mı görünüyor.
10. **DerivSwp BusinessKey hatası** — müşteri ters fişlerinde `BusinessKey == MessageKey` mi, DB'de kontrol et.
11. **Sayaç taşması** — `int.Parse(önek + sayaç)`; sayaç 8 hane olunca taşar (DerivSwp'te 7 hane üstü).
12. **Sıfır tutar** — NoAccrual yerine ExternalError; beklenen mi.
