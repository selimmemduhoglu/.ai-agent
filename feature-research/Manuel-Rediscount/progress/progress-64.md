# progress-64 — Listeleme performansı (yalnız MM) + dark mode popup/pill + yük testi skill'i (2026-09-29)

> Önceki tur: [progress-63](progress-63.md). Tetikleyen: 3000 klonlu MM yük testinde Search ~1 dk.
> PO kararı: **yalnız MM**; diğer modüller MM testinden sonra onayla.

## Teşhis (ölçüm: `sql-log/manuel-reeskont-kodlama` S-21…S-27)
- `TransactionDataManager.GetRediscountEligibleTransactionsAsync` items SELECT'i satır başına ~27 korele alt sorgu
  (accEntryMain ×13, txnMMDetail ×4, txnMmDailyCalculation ×6, cusCustomer ×4).
- `AccEntryMain` / `TxnMMDetail` / `TxnMmDailyCalculation`'da TxnId index'i YOK (yalnız PK) → her alt sorgu tablo taraması.
- EF log'undaki "Executed DbCommand" süresi ilk satıra kadar (~1 sn); asıl süre satır üretiminde (75–96 sn).
- LogRef filtresiyle hızlı: kapsam 1 satır → alt sorgular 1 kez.

## Yapılan (MM)
- Yeni `Data/Managers/Transaction/RediscountEligibleScope.cs`: statü türetimi (eski SQL dallarıyla birebir), statü sayımları,
  statü filtresi, Id desc sıralama, skip/take — bellekte.
- `TransactionDataManager` + `TransactionLoanDataManager`: 5 sorgu (1 count + 3 statü count + korele items) → 6 düz sorgu:
  kapsam Id'leri · günün reeskont fişleri (+ ters fiş PK ile) · sayfa satırları (cusCustomer/defTxnType LEFT JOIN) ·
  detail (MM) / faiz cash flow (IL) · valuation SUM GROUP BY + günlük valuation (MM) / LoanRevaluation (IL).
  Sayfa verisi Id aralığıyla (IN listesi 2100 parametre sınırı), aralıktaki sayfa dışı satırlar bellekte elenir.
- Özel enum'lar (`RediscountStatusFilter`, `LoanRediscountStatusFilter`) kaldırıldı → helper sabitleri.
- Önerilen index script'i (kullanıcı uygular): `outputs/2026-09-29-ManuelReeskont-Listeleme-Index/1-NetTrexMM-ManuelReeskont-Index.sql`.

## Doğrulama
- Eşitlik harness'ı (HEAD kopyası vs yeni, JSON birebir): MM + IL 25 vaka, tarih 22/23/27/28 Eylül, statü all/1/3/4,
  sayfalama → **hepsi EŞİT** (tek fark `AccruedInterest` 0.000…↔0 ölçeği; sayısal aynı, handler 2 haneye yuvarlıyor).
- Süre: MM 3006 satır **92 sn → 1,8 sn**, 3005 satır **82 sn → 1,3 sn**. EF model ısınması ~25 sn (process başına 1 kez).
- MM Data.Tests 25/25 (yeni `RediscountEligibleScopeTests` 5) · MM Api.Services.Tests 322/322.

## UI (Common.UI + WebUI, yalnız CSS)
- Error reason popup `.mr-reason-detail` dark renk; sonuç popup ayırıcıları; Status Description ve soluk metinler; sonuç şeridi.
- Status pill: seçilide ✓ + kalın çerçeve; dark'ta pasifler şeffaf. Çoklu seçim mantığı bozuk DEĞİLDİ (Set filtresi sağlam);
  seçili/pasif farkı görünmüyordu + test gününde NotReversed satır 0'dı.

## Yük testi skill'i
- `skills/yuk-testi.md` + `skills/yuk-testi/*.md` (6 script) · `_index.md` satırı · MM/Fx `.claude/skills/yuk-testi/SKILL.md`.

⬜ FX / DerivSwp / OptionsFX listeleme: MM testinden sonra PO onayı. ⬜ Commit YAPILMADI.

## Sonradan (aynı gün) — PO onayıyla diğer modüller + 20 sınırı
- **DerivSwp** `TransactionRepository` + yeni `RediscountEligibleScope.cs` (ProductCode filtresi yok; revaluation tek SELECT,
  eski sırasız TOP(1) → en küçük Id). Eşitlik S-37: **30/30**.
- **OptionsFX** `ManualRediscountDataManager` + yeni `RediscountEligibleScope.cs` (RediscountId dahil; revaluation Id desc).
  Eşitlik S-38/S-40: **45/45** (veri az: günde en çok 5 satır).
- **FX** `ManualRediscountRepository` (çok kaynak birleşimi, ProductCode null izni, external LocalId, valuation IsActiveRevaluation
  Id desc). Eşitlik S-35: **70/70**. `pageWindow` taşma koruması artık gereksiz (bellekte sayfalama).
- **MaxItems 30 → 20**: MM/DerivSwp/OptionsFX/FX handler + Common.UI/WebUI `MR_MAX_EXECUTE_ITEMS` (+ yorumlar).
- Testler: MM 322 + 25 · DerivSwp 75 · OptionsFX 85 · FX ManualRediscount 38 (tüm suite 789'da 12 FutureExternal hatası
  önceden var, dokunulmadı) · WebUI jest 470 · Common.UI typecheck ✅.
- MM dönem gözlemi: onaylı MM işlemlerinde faiz satırı hep 1 (S-32/33/34) → MM için geçersiz.
- İnceleme (salt okuma) bulguları sohbette raporlandı; doğrulananlar: Regenerate `created` aynaya düşebilir, header select-all 20'yi aşar.

## Sonradan (2026-09-29, 3. tur) — "10 madde" isteği ve PO'nun geri alma kararı
- 10 madde MM'de uygulandı, sonra PO kararıyla **madde 1 (Id-bazlı "fiş oluştu mu" + çift ters fiş koruması), 2 (ayna /
  yarım nötrleme tanıma), 3 (Execute kapsam kontrolü + DB referansı), 5 (TransactionIds kısmi yenileme) GERİ ALINDI**
  (unstaged → staged hale `git restore`, yedek: scratchpad `mm-backup-10madde/unstaged.patch`).
- KALANLAR (MM, unstaged): madde 6 IL faiz oranı T'yi kapsayan dönemden · madde 9 temizlik (RegenerateToToday, serbest
  ReverseValueDate, ExternalCustomerId/Name/SearchText sunucu filtreleri, validator "bugün" bayatlığı, TotalCount ifadesi,
  MessageKey testi) · madde 10 tek statü kuralı `RediscountStatusRule` (ayna parametresi yok).
- Doğrulama: MM Api 315/315 · Data 25/25 · eşitlik S-46 29/29, tam liste 75,3 sn → 0,9 sn.
- ⚠️ FX / DerivSwp / OptionsFX'te durdurulan ajanların YARIM değişiklikleri var (derlenmedi/test edilmedi) — PO kararı bekliyor.
- UI (WebUI + Common.UI): kısmi yenileme / NeutralizationPending / ALREADY_REVERSED geri alınıyor; sayfa boyutu 20,
  statü doğruluğu, ağ hatasında Processing→Error, temizlik kalıyor.

## Sonradan (4. tur) — MM'de kalanlar diğer modüllere + UI geri alma tamam
- FX / DerivSwp / OptionsFX: durdurulan ajanların yarım değişiklikleri geri alındı (yedek: scratchpad `agent-partial/<repo>/`),
  staged (performans + MaxItems 20) üstüne MM'de kalan maddeler uygulandı: RegenerateToToday ve serbest ReverseValueDate
  kaldırıldı, ExternalCustomerId/Name/SearchText sunucu filtreleri kaldırıldı, validator "bugün" okuması kural içine, TotalCount
  ifadesi sadeleşti, tek statü kuralı `RediscountStatusRule` (repo/scope + resolver ona bağlı).
- Testler: DerivSwp 73/73 · OptionsFX 78/78 · FX ManualRediscount 38/38 (düşüş = silinen RegenerateToToday/ReverseValueDate testleri).
- UI (WebUI + Common.UI): kısmi yenileme, NeutralizationPending, ALREADY_REVERSED geri alındı; sayfa 20 + selectAllMode page,
  sunucu statüsü esas, ağ hatasında Processing→Error (+ tam yenileme), temizlik kaldı. Jest 473/473 · typecheck ✅.
⬜ Commit YAPILMADI.
