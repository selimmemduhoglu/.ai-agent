# progress-39 — Kod denetimi (2 gerçek bug) + 4 UI isteği

**Tarih:** 2026-08-21 · **Tur:** 8 · **Repolar:** `NetTrex.MM` · `NetTrex.Web.UI`

**Kullanıcının isteği:** *"MM ve WebUI git history'sinden de bakabilirsin… bu commit'lere göre bizim
bu yazdığımız manuel reeskont ekranı güzel oldu mu, mantıklı mı, dokümana uygun mu, gerçekten istenen
aksiyonları alan bir ekran mı, bu yaptığımız işteki eksiklikler ve kaçaklar neler olabilir çünkü
kaçaklar çok önemli, biz fiş kesicez… select/get/insert/update işlemlerini yaparken benim MM'deki kod
mantığına uygun mu, test ederken nelere dikkat etmem gerekir."* + 4 UI isteği (aşağıda).

Commit tabanı: `NetTrex.MM` 4 commit (`3d8e8617` → `0c9a683d`), `NetTrex.Web.UI` 4 commit
(`3cecb9a6` → `c9b4275c`). Toplam ~4000 (+MM) / ~2350 (+WebUI) satır.

---

## 1. 🔴 İki GERÇEK BUG bulundu ve düzeltildi

### B-1 — `MaxItems` çelişkisi: 11-50 satır seçimi **reddediliyordu**

| Katman | Sınır |
|---|---|
| Ekran (`MR_MAX_EXECUTE_ITEMS`) | 50 |
| `ExecutionsHandler.MaxItems` | 50 |
| **`ExecutionsRequestValidator`** | **10** ← |

`MaxItems` bir önceki turda 10→50 çıkarılmış, validator'daki **sabit 10** güncellenmemişti
(yorumda hâlâ *"Sınır ExecutionsHandler.MaxItems ile AYNI olmalı (10)"* yazıyordu). 11-50 satır
seçen kullanıcı *"At most 10 transactions can be sent at once"* ile geri dönüyordu ve **hiçbir test
bunu görmüyordu** — testlerin tamamı ≤10 satırla koşuyordu.

**Düzeltme:** `MaxItems` `public const` yapıldı, validator onu kullanıyor → tek kaynak.
**Yeni 2 test:** `ExecutionsValidator_WithMaxItemsCount_ShouldBeValid` (50 satır geçer) ·
`..._WithOneMoreThanMaxItems_ShouldBeInvalid` (51 reddedilir). Sınır değişirse ikisi de yakalar.

### B-2 — Kolon sıralaması **yalnız yüklü sayfayı** sıralıyordu

Grid `remoteOperations: { paging: true, sorting: false }`. 6 sabit kolonda `allowSorting`
**yazılmamıştı** → DevExtreme varsayılanı açık → kullanıcı "External Customer Id" başlığına
tıklayınca **sadece o 50 satır** sıralanıyor, tüm kümeyi sıraladığını sanıyordu. Filtrede aynı tuzak
yaşanmıştı (`ADR-MR-019`); ilke aynı: **sunucunun yapamadığı işi kullanıcıya sunmuyoruz.**

**Düzeltme:** 6 sabit kolona `allowSorting: false` + ortak gerekçe notu. Test: *"hiçbir sabit kolon
client-side sıralanamaz"*.

---

## 2. Denetim — doğru yapılmış olanlar (MM konvansiyonu)

| Konu | Bulgu |
|---|---|
| **Fiş kesme yolu** | Ekran **kendi muhasebe mantığını yazmıyor**: `RevaluationAccountingService` · `LoanRevaluationAccountingService` · `RevaluationReverseAccountingService` — batch'in **birebir aynı** servisleri (pipeline + `unitOfWork.CommitAsync()`) |
| **MM ↔ InterbankLoan dallanması** | `RevaluationBatchItem.cs:92-95` / `:128-131` deseninin aynısı; ters fişte dallanma yok çünkü `AccEntryMain.Id` üzerinden çalışıyor (batch de öyle) |
| **INSERT** | `AccountingDataManager.InsertAsync` → Id'ler `ngDataService.GetNewNumbersWithPrefixAsync` ile (framework numaratörü), elle Id **yok**, `SeqNumber` sıralı |
| **SELECT** | `AsNoTracking` · sabit `OrderByDescending(Id)` · `Skip/Take` **sunucuda** · müşteri/ilişki alanları **EXISTS (`Any`)** ile (required navigation INNER JOIN satır kaybı tuzağı) · filtre **sayımlardan önce** |
| **Durum doğrulama** | Her satır için durum sunucuda **yeniden türetilir** (§ 4.5) → bayat UI verisiyle fiş kesilmiyor, `STATUS_CHANGED` ile reddediyor |
| **Hata yönetimi** | Satır başına `try/catch` (`ADR-MR-007`), sessiz kırpma yok (`TOO_MANY_ITEMS` açık red), `Failed` doluysa `IsSuccess = false` |
| **Para** | `decimal` + `RoundAwayFromZero(2)`; `float/double` yok |
| **Kullanıcı izi** | Ters fişte `StateMaker` = gerçek kullanıcı (`T-01`) |

---

## 3. Kalan kaçaklar (düzeltilmedi — karar/onay gerekiyor)

| # | Kaçak | Etki | Not |
|---|-------|------|-----|
| K-1 | **Regenerate 3 ayrı commit**: nötrleme → yeni değerleme → yeni ters fiş. Dış transaction **yok** | 2. veya 3. adım patlarsa satır `Failed` görünür ama DB'de **ilk iki fiş durur** | Toparlanma var: durum yeniden türetildiği için `Generate` eksik ters fişi tamamlıyor. Batch de aynı desen (tek fiş kestiği için sorun görünmüyor) |
| K-2 | **Fimple sync (step 15) → local persist (20) → commit** sırası | Fimple 200 döner, commit patlar → **Fimple'da fiş var, bizde yok** | Platform geneli (batch dahil). Bizim eklediğimiz bir kusur değil, ama manuel ekranda **çok daha sık tetiklenebilir** |
| K-3 | Çift-tıklama guard'ı **process-içi** (`ConcurrentDictionary`) | Çok pod'lu ortamda iki istek ayrı pod'a düşerse **çift fiş** | Gerçek çözüm: cluster kilidi (Redis) + Fimple **idempotency** header'ı (`Ö-08` Fimple'a soruldu) |
| K-4 | `CancellationToken` HTTP isteğine bağlı | Kullanıcı sekmeyi kapatır / 10 dk timeout → döngü **ortada** kesilir | Kesilen satır K-1 gibi yarım kalabilir; kalanlar hiç işlenmez |
| K-5 | 🔴 **T+0 reeskont fişinde `StateMaker` YOK** | `RevaluationAccountingServiceContext(TransactionId, LogicalDate)` kullanıcı taşımıyor → fiş **`SYSTEM`** damgalanıyor; ters fişte gerçek kullanıcı var | *"Kim kesti"* yarım kalıyor. Düzeltme **paylaşılan pipeline'a** dokunur (batch de kullanıyor) → opsiyonel `StateMaker` parametresi (`null` → `SYSTEM`, batch etkilenmez) ile yapılabilir, **kullanıcı onayı bekliyor** |
| K-6 | `ExecutionDate` **geçmişe** izinli (≤ bugün), **iş günü kontrolü yok** | Kapalı muhasebe dönemine fiş kesme denemesi | Doküman § 10 *"iş günü olmalı"* diyor → **bilinçli sapma değil, açık kalem**. Yeni T+1 kuralı takvimsiz olduğu için burada da takvim istemek tutarsız olurdu; karar senin |
| K-7 | T+1 artık **hafta sonuna** düşebilir (yeni kural) | Fimple/muhasebe kapalı gün valörünü reddederse satır patlar | Bilinçli ödün (`ADR-MR-027`); tarayıcı testi § 18.2/11 bunu ölçüyor |

---

## 4. Bu turda yapılan 4 UI isteği

| # | İstek | Yapılan |
|---|-------|---------|
| 1 | *"dark modda Generate/Regenerate yazıları çok silik"* | Pasif buton renkleri değişti: Generate `#8CA0BC/#EDF1F6` (kontrast ~1.6:1) → `#4A5A75/#E8EDF5` (~5:1); Regenerate `#DDB9A6/#F7EDE7` → `#7A4A33/#F6E7DF`. `.dx-button-text` de açıkça boyandı. **Tema-özel kural yazılmadı** — tek renk seti iki temada da okunur (buton kendi zeminini taşıyor) |
| 2 | *"grid içindeki arama kutusunu (search reference or customer) sevmedim, kaldır; DailyFlowV2'deki gibi DevExtreme'in kolon yapısı olsun"* | `searchPanel` **kaldırıldı**. Filtre satırı Netix grid davranışına çekildi: `applyFilter: "auto"` (apply butonu yok) + `onEditorPreparing` ile `valueChangeEvent: "change"` (Enter/odak kaybında **tek** istek — tuş başına istek yok) + `showClearButton`. CSS iç boşlukları `framework_devextreme_datagrid_medium.css:93` deseninden alındı |
| 3 | *"info yazısında next business day demişsin ama takvim günü kullanacağız"* | `mr-info-gen-NotReversed` (tr+en, 6 dosya) ve JS fallback metni **"next calendar day" / "bir sonraki takvim günü"** oldu |
| 4 | *"Rediscounted'da Generate'i disable mı etsek, açıklama mı koysak?"* | **İkisi birlikte:** seçimin tamamı `Rediscounted` ise Generate **pasif** + altında gerekçe (*"…zaten reeskont edilip ters fişi kesilmiş — Regenerate kullanın"*). Gerekçe **kalıcı** (notify gibi kaybolmuyor), (i) ikonu pasifken de açıldığı için "neden" cevabı orada. Eskiden buton aktifti → boşa bir sunucu turu + `ALREADY_REDISCOUNTED` hatası |
| 5 | *"sonuç şeridinin sağ üstünde çarpı olsun, isteyen kapatabilsin"* | `.mr-result-bar-close` (×) eklendi. 🔴 Kapatmak **yalnız şeridi gizler**; `mrResultOverlays` dokunulmaz → satırlardaki `Error` rozeti, sebep düğmesi (!) ve `Status Description` metni **kalır**. Overlay'i de silmek "hangi satır patladı" bilgisini yok etmek olurdu |
| 6 | *"Error statüsünün yanındaki `...` ne anlama geliyor"* | O `...` **benim eklediğim hata sebebi düğmesiydi** (!): `Status` kolonu 150px, rozet + 18px düğme sığmayınca DevExtreme hücre ellipsis'i devreye giriyordu. Kolon **190px** yapıldı + `td.mr-cell-status`'ta `text-overflow: clip` / `white-space: nowrap` |

Yeni yardımcı: `mrAllRediscounted(uniqueKey, rows)` — durumu **overlay'in `dbStatus`**'ünden okur,
anlık `Error`/`Processing` yanıltmaz (4 test).

---

## 5. Açık karar — grid filtre/sıralama modeli

Treasy'nin ev grid'i (`ToNetixDataGrid`, `Framework.WebUI/Extensions/GridBuilderExtensions.cs:456+`)
şu varsayılanlarla çalışıyor: **`RemoteOperations(false)`** (yani **tüm veri istemciye**),
`HeaderFilter.Visible(true)` (huni ikonu), `FilterRow` + `ColumnChooser` + `GroupPanel` +
`RowAlternation` + `datagrid-medium` sınıfı.

Bizim grid **sunucu taraflı sayfalı** (`ADR-MR-009`). Bu yüzden:
- ✅ filtre satırı **verildi** (sunucuya gidiyor, `TotalCount` ve özet şeridi tutarlı),
- ❌ **huni (headerFilter) verilemedi**: distinct değer listesi yalnız yüklü sayfadan çıkar → yanıltıcı olur.

**Seçenek A (şu anki):** sunucu taraflı sayfalama + 3 metin kolonunda sunucu filtresi. Doğru ama ev
grid'inin tüm özellikleri yok.
**Seçenek B (tam ev deseni):** `remoteOperations: false` + tek seferde tüm veri → huni, gruplama,
kolon seçici, tam filtre/sıralama **bedava** gelir. ⚠️ Bedeli: modül ucunun `Take` tavanı **200**;
bir tarihte 200'den fazla uygun işlem olan müşteride grid **sessizce eksik** gösterir → tavanın
kaldırılması + performans ölçümü gerekir.

Karar kullanıcıya bırakıldı.

---

## 6. Test / build

| | Önce | Şimdi |
|---|---|---|
| MM | 204 | **206** ✅ (+2 sınır testi) |
| JS (Manuel Reeskont) | 78 | **83** ✅ (+5) |
| JS (tüm suite) | 378 | **383** ✅ |
| Build | ✅ | MM 0 error · WebUI 0 error |

## 7. Tarayıcı testinde dikkat edilecekler (bu tura özel)

1. **50 satır seç → Execute** (B-1 düzeltmesi; eskiden 11'de reddediyordu).
2. Kolon başlığına tıkla → **sıralama olmamalı** (B-2).
3. Grid içinde **arama kutusu olmamalı**; filtre kutusuna yazıp **Enter** → tek istek (ağ sekmesinde doğrula).
4. **Dark mode**: pasif Generate/Regenerate yazısı okunur.
5. Sadece `Rediscounted` satır seç → Generate **pasif** + gerekçe; (i) ikonu hâlâ açılıyor.
6. Info penceresi: *"next calendar day"* yazmalı.
7. 🔴 **DB doğrulaması** (asıl iş): `AccEntryMain` (Type · IsReverse · ReverseId · ValueDate · StateMaker · MessageKey) + `AccEntry` borç/alacak dengesi + Fimple karşılığı. T+0 fişinde `StateMaker = SYSTEM` görürsen bu **K-5**, beklenen.
8. Regenerate'i kasten patlat (Fimple'ı kapat) → **K-1** yarım kalma davranışını gör: satır `Failed`, ama nötrleme + yeni değerleme DB'de. Ardından `Generate` ile tamamlanıyor mu?
