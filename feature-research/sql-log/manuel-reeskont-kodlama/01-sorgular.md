# 01-sorgular.md — manuel-reeskont-kodlama

Denetim kaydı — Hard Rule (mssql-read skill). Her sorgu çalıştırmadan ÖNCE buraya yazılır.
Sunucu: `tcp:192.168.10.211,1433`. Kullanıcı: `trusr`. Yazma sorgusu: **0**.

---

## #1 — Hangi `NetTrexCommon*` DB'leri var, kullanıcının `USE NetTrexCommon`'ı hangisi

**Amaç:** Kullanıcı SSMS'te `USE NetTrexCommon` demiş; `NetTrex.Common/Code/docker-compose.override.yml:24`
ise `NetTrexCommon_Dev` yazıyor. Aynı DB mi, yanlış DB'ye mi bakılıyor — önce bunu netleştirdim.

```sql
SET NOCOUNT ON;
SELECT TOP (20) name FROM sys.databases WHERE name LIKE '%NetTrexCommon%' ORDER BY name;
```

**Sonuç:** 20 farklı `NetTrexCommon*` varyantı var (`NetTrexCommon`, `NetTrexCommon_Dev`,
`NetTrexCommon_132/133/134/135[_Dev]`, ...). İkisi de **ayrı, gerçek** DB.

---

## #2 — Reeskont satırları `NetTrexCommon_Dev`'de var mı (override dosyasının işaret ettiği DB)

**Amaç:** `docker-compose.override.yml`'in gösterdiği DB'de satırlar yoksa "yanlış DB'ye insert edilmiş"
ihtimali güçlenir.

```sql
SET NOCOUNT ON;
SELECT TOP (20) Id, Description, MenuKey, IsActive, ParentId
FROM dbo.FrameworkMenu WHERE Description LIKE '%Reesko%' ORDER BY Id DESC;
```
(DB: `NetTrexCommon_Dev`)

**Sonuç:** 0 satır — `NetTrexCommon_Dev`'de bu 3 kayıt **yok**. (Not: bu tek başına "yanlış DB" kanıtı
DEĞİL — override dosyası yalnız yerel docker-compose stack'i için, kullanıcının 191 cluster'ındaki
gerçek Common API'nin hangi DB'yi kullandığını göstermiyor. `kubectl` bu makineden cluster'a bağlanamadı,
context yok — canlı pod'un connection string'i doğrulanamadı.)

---

## #3 — `NetTrexCommon` (kullanıcının baktığı DB) — aktif menülerin `ModuleName` dağılımı

**Amaç:** Yeni 3 satırın `ModuleName`'i diğer aktif satırlarla aynı desende mi.

```sql
SET NOCOUNT ON;
SELECT ModuleName, COUNT(*) AS Adet FROM dbo.FrameworkMenu WHERE IsActive=1 GROUP BY ModuleName ORDER BY Adet DESC;
```
(DB: `NetTrexCommon`)

**Sonuç:** `GENERAL|262`, `Accounting|14`, `DERIV|4`, `OptionsFX|2`. Toplam 282 — **hiç NULL grup yok**.

---

## #4 — Parent (129) ve iki referans satırın (276, 339, 1548, 1551) `ModuleName`/çeviri değerleri

```sql
SET NOCOUNT ON;
SELECT Id, Description, MenuKey, ModuleName, ParentId, IsActive FROM dbo.FrameworkMenu WHERE Id IN (129,276,339,1551,1548);
```
(DB: `NetTrexCommon`)

**Sonuç:** Hepsi `ModuleName='GENERAL'` (tam büyük harf).

---

## #5 — 3 Reeskont satırının kendi `ModuleName` + `ForcedPermission` değeri

```sql
SET NOCOUNT ON;
SELECT Id, Description, MenuKey, ModuleName, IsActive, ParentId, ItemOrderId, ForcedPermission
FROM dbo.FrameworkMenu WHERE MenuKey IN ('TreasuryReeskontKey','SecurityReeskontKey','InvestmentReeskontKey');
```
(DB: `NetTrexCommon`)

**Sonuç:** `ModuleName = 'General'` (yalnız ilk harf büyük) — **'GENERAL' değil**. Diğer 282 aktif
satırın hiçbiri bu case varyasyonunu kullanmıyor.

---

## #6 — Aynı 3 satırın çeviri (Translation*) kolonları

```sql
SET NOCOUNT ON;
SELECT Id, TranslationYatirimEN, TranslationYatirimTR, TranslationKatilimEN, TranslationKatilimTR
FROM dbo.FrameworkMenu WHERE MenuKey IN ('TreasuryReeskontKey','SecurityReeskontKey','InvestmentReeskontKey');
```
(DB: `NetTrexCommon`)

**Sonuç:** 4 kolon da, 3 satırın hepsinde **NULL**.

---

## #7 — Referans satırların (276, 339, 1548, 1551) aynı çeviri kolonları — NULL normal mi

```sql
SET NOCOUNT ON;
SELECT Id, Description, TranslationYatirimEN, TranslationYatirimTR, TranslationKatilimEN, TranslationKatilimTR
FROM dbo.FrameworkMenu WHERE Id IN (276,339,1551,1548);
```
(DB: `NetTrexCommon`)

**Sonuç:** 4 satırın da 4 çeviri kolonu **dolu** (Description ile aynı veya EN/TR ayrımlı). NULL örneği yok.

---

## #8 — `FrameworkMenu` şema / nullability

```sql
SET NOCOUNT ON;
SELECT c.name, t.name AS type, c.is_nullable FROM sys.columns c JOIN sys.types t ON t.user_type_id=c.user_type_id
WHERE c.object_id=OBJECT_ID('dbo.FrameworkMenu') ORDER BY c.column_id;
```
(DB: `NetTrexCommon`)

**Sonuç:** `ModuleName` ve 4 `Translation*` kolonu DB seviyesinde **nullable** (constraint izin veriyor) —
yani DB bunları zorunlu kılmıyor, ama **hiçbir aktif satır** bu boşluğu kullanmıyor. Uygulama tarafında
bir varsayım/karşılaştırma bu boşluğa/case farkına takılıyor olmalı — kod tarafı ayrıca araştırılıyor.

---

## #9 — Tüm aktif menüde çeviri eksikliği ne kadar yaygın?

**Amaç:** Kullanıcı sordu: "Menü isimleri DB'de eksik ve Türkçe ve geride kalmış mı?" — yalnız yeni 3
Reeskont satırına mı özgü yoksa tabloda genel bir teknik borç mu, ölçüyorum.

```sql
SET NOCOUNT ON;
SELECT
  COUNT(*) AS ToplamAktif,
  SUM(CASE WHEN TranslationYatirimEN IS NULL THEN 1 ELSE 0 END) AS YatirimEN_Null,
  SUM(CASE WHEN TranslationYatirimTR IS NULL THEN 1 ELSE 0 END) AS YatirimTR_Null,
  SUM(CASE WHEN TranslationKatilimEN IS NULL THEN 1 ELSE 0 END) AS KatilimEN_Null,
  SUM(CASE WHEN TranslationYatirimEN = TranslationYatirimTR THEN 1 ELSE 0 END) AS EN_TR_Ayni_YaniCeviriYok
FROM dbo.FrameworkMenu WHERE IsActive = 1;
```
(DB: `NetTrexCommon`)

---

## #10 — Hangi `NetTrexMM*` DB'leri var (Common'daki gibi çoklu varyant ihtimali)

**Amaç:** Kullanıcı "TransactionDataManager'daki filtreye uygun data hangi tarihte var, DB'ye bağlan
bul" dedi. Önce doğru `NetTrexMM*` varyantını netleştiriyorum (Common'da yaşanan "yanlış DB" tuzağı
tekrar olmasın).

```sql
SET NOCOUNT ON;
SELECT TOP (20) name FROM sys.databases WHERE name LIKE '%NetTrexMM%' ORDER BY name;
```

Sunucu: `tcp:192.168.10.211,1433` (`NetTrex.MM/Code/docker-compose.override.yml:38`).

---

## #11 — Adaya (muhtemelen `NetTrexMM`) en güncel TxnMM satırları — hangisi "canlı" DB anlamak için

**Amaç:** Birden fazla varyant varsa, en güncel `StateDate`'e sahip olan muhtemelen aktif kullanılan.

```sql
SET NOCOUNT ON;
SELECT TOP (20) Id, LogicalReference, ValueDate, MaturityDate, StateId, StateDate, TxnMmProductTypeId
FROM dbo.TxnMM ORDER BY Id DESC;
```

---

## #12 — Reeskont uygunluk filtresine (`GetRediscountEligibleTransactionsAsync`) uyan satırlar

**Amaç:** `TransactionDataManager.cs:33-46`'daki LINQ filtresini SQL'e çevirip hangi `ValueDate`
(dolayısıyla hangi ekran "Date" seçimi) gerçekten satır döndürür görmek — kullanıcı ekranda "Total 0
records" görüyor, doğru tarihi bulmasına yardım.

```sql
SET NOCOUNT ON;
SELECT DISTINCT t.ValueDate
FROM dbo.TxnMM t
WHERE t.TxnMmProductTypeId <> 6 -- ISSUE (doğrulanacak)
  AND EXISTS (SELECT 1 FROM dbo.AccEntryMain a WHERE a.TxnMmId = t.Id AND a.Type = 1) -- Opening
  AND EXISTS (SELECT 1 FROM dbo.TxnMMDetail d WHERE d.TxnMmId = t.Id AND d.IsPrincipalAmount = 0)
ORDER BY t.ValueDate DESC;
```
(Tablo/kolon adları tahmini — gerçek şemaya göre düzeltilecek, önce `sys.columns` ile doğrulanacak.)

---

## #15 — TxnLoan'da gerçekten `TxnMmProductTypeId` var mı? (kullanıcı iddiası doğrulanıyor)

**Amaç:** Kullanıcı "TxnMmProductTypeId kolonu hem TxnMM hem TxnLoan'da var, ürünler oradan bağlanıyor"
dedi. `TxnLoanEntityBase` (kod) bunu göstermiyor (`ProductDefinitionId` var, `TxnMmProductTypeId` yok) —
DB'den empirik doğruluyorum, kod okuması yanlış olabilir.

```sql
SET NOCOUNT ON;
SELECT c.name FROM sys.columns c WHERE c.object_id=OBJECT_ID('dbo.TxnLoan')
  AND (c.name LIKE '%Product%' OR c.name LIKE '%TypeId%') ORDER BY c.column_id;
```
(DB: `NetTrexMM_134`)

**Sonuç:** `ProductDefinitionId` var, `TxnMmProductTypeId` **YOK**. Kod okuması doğruymuş, kullanıcının
hatırladığı yanlış.

---

## #16 — TxnLoan'da fiilen hangi ProductDefinition'lar kullanılıyor

```sql
SET NOCOUNT ON;
SELECT DISTINCT t.ProductDefinitionId, p.Code, p.Name
FROM dbo.TxnLoan t LEFT JOIN dbo.PrdProductDefinition p ON p.Id = t.ProductDefinitionId
ORDER BY t.ProductDefinitionId;
```
(DB: `NetTrexMM_134`)

**Sonuç:** 57 satırın TAMAMI tek bir `ProductDefinitionId=2` ("Loan"/"Interbank Loan") kullanıyor —
bu ortamda IL'in alt ürün ayrımı (Murabaha/Wakala tarzı) hiç yok gibi görünüyor. Kesin değil (başka
tanımlı ama kullanılmamış `ProductDefinition` satırı olabilir), kullanıcıya soruldu.

---

## #17 — 🔴 TxnMM.Id ile TxnLoan.Id ÇAKIŞIYOR MU (AccEntryMain.ProductCode filtresizliği riski)

**Neden:** `AccountingDataManager.GetRevaluationByValueDateAsync` (satır 109-116) yalnız
`TxnId == transactionId` filtreliyor, **`ProductCode` filtresi YOK**. `AccEntryMain` hem MM
(`ProductCode='MM'`) hem InterbankLoan (`'Loan'`) fişlerini taşıyor. İki tablonun Id aralıkları
örtüşüyorsa Manuel Reeskont'ta IL satırı seçildiğinde **MM'in fişi okunabilir** → yanlış durum
türetme, hatta yanlış fişe ters kesme (gerçek para riski). ExecutionsHandler'a Loan dispatch'i
yazmadan ÖNCE doğrulanması zorunlu.

```sql
SET NOCOUNT ON;
SELECT 'TxnMM' AS Tbl, MIN(Id) AS MinId, MAX(Id) AS MaxId, COUNT(*) AS Cnt FROM dbo.TxnMM
UNION ALL
SELECT 'TxnLoan', MIN(Id), MAX(Id), COUNT(*) FROM dbo.TxnLoan;
```
(DB: `NetTrexMM_134`)

```sql
SET NOCOUNT ON;
SELECT TOP (20) l.Id
FROM dbo.TxnLoan l
WHERE EXISTS (SELECT 1 FROM dbo.TxnMM m WHERE m.Id = l.Id)
ORDER BY l.Id DESC;
```
(DB: `NetTrexMM_134`) — kesişen Id var mı, varsa örnekleri.

```sql
SET NOCOUNT ON;
SELECT TOP (20) a.ProductCode, COUNT(*) AS Cnt
FROM dbo.AccEntryMain a
GROUP BY a.ProductCode
ORDER BY COUNT(*) DESC;
```
(DB: `NetTrexMM_134`) — AccEntryMain'de hangi ProductCode değerleri ne yoğunlukta.

---

## Tur 2026-08-18 (akşam) — Doküman uyum turu sonrası DB doğrulaması

Amaç: kod dokümanı birebir uygular hale getirildi; şimdi **gerçekten DB'ye ne yazıldığına** bakılacak.
Özellikle: reeskont (T+0) ve ters fiş (T+1) çiftleri, `ReverseId` bağı, `ValueDate` değerleri,
`ProductCode` ayrımı ve `StateMaker` (T-01: ters fişi kesen kullanıcı `SYSTEM` olmamalı).

### #18 — En yeni Revaluation fişleri (T+0) ve ters bağı

```sql
SET NOCOUNT ON;
SELECT TOP (20) Id, TxnId, ProductCode, TxnTypeCode, Type, IsReverse, ReverseId,
       ValueDate, StateMaker, BusinessKey, MessageKey
FROM dbo.AccEntryMain
WHERE Type = 2
ORDER BY Id DESC;
```
Neden: `Type = 2` reeskont (Revaluation). `ReverseId = 0` → ters alınmamış (`Not Reversed`),
`> 0` → tamamlanmış (`Rediscounted`). `DeriveStatus`'ün DB'deki karşılığı bu.

### #19 — Ters fişler (T+1) — valör gerçekten kaydırılmış mı

```sql
SET NOCOUNT ON;
SELECT TOP (20) Id, TxnId, ProductCode, Type, IsReverse, ReverseId,
       ValueDate, StateMaker
FROM dbo.AccEntryMain
WHERE IsReverse = 1
ORDER BY Id DESC;
```
Neden: ters fişin `ValueDate`'i T+0'dan farklı mı (T+1 iş günü) — bu turda takvim (`NextWorkingDayAsync`)
devreye alındı, eskiden düz `AddDays(1)` idi. Cumartesi/Pazar valörlü ters fiş var mı görülecek.

### #20 — T+0 / T+1 çiftini yan yana: valör farkı kaç gün

```sql
SET NOCOUNT ON;
SELECT TOP (20) t0.Id AS T0Id, t0.ValueDate AS T0Value, t1.Id AS T1Id, t1.ValueDate AS T1Value,
       DATEDIFF(DAY, t0.ValueDate, t1.ValueDate) AS DayDiff,
       DATENAME(WEEKDAY, t1.ValueDate) AS T1Weekday,
       t0.TxnId, t0.ProductCode, t1.StateMaker
FROM dbo.AccEntryMain t0
INNER JOIN dbo.AccEntryMain t1 ON t1.Id = t0.ReverseId
WHERE t0.Type = 2 AND t0.ReverseId > 0
ORDER BY t0.Id DESC;
```
Neden: **asıl doğrulama bu.** `DayDiff` ve `T1Weekday` birlikte, ters fişin hafta sonuna düşüp
düşmediğini gösterir. `T1Weekday = Saturday/Sunday` çıkarsa eski `AddDays(1)` bug'ının canlı izidir.

### #21 — `ProductCode` dağılımı (MM ↔ InterbankLoan ayrımı)

```sql
SET NOCOUNT ON;
SELECT TOP (20) ProductCode, COUNT(*) AS Cnt, MIN(TxnId) AS MinTxnId, MAX(TxnId) AS MaxTxnId
FROM dbo.AccEntryMain
GROUP BY ProductCode
ORDER BY COUNT(*) DESC;
```
Neden: progress-26'da eklenen `ProductCode` filtresinin dayanağı. `TxnId` aralıkları ürün bazında
ayrık mı — çakışma latent risk olarak duruyor mu.

### #22 — Ters fişlerin hafta günü dağılımı (plan dışı, #20'nin bulgusu üzerine)

```sql
SET NOCOUNT ON;
SELECT TOP (20) DATENAME(WEEKDAY, ValueDate) AS Weekday, COUNT(*) AS Cnt
FROM dbo.AccEntryMain
WHERE IsReverse = 1
GROUP BY DATENAME(WEEKDAY, ValueDate)
ORDER BY COUNT(*) DESC;
```
Neden: #20'de **Cumartesi valörlü** ters fiş görüldü (`555770 → 555772`, 2026-07-24 Cuma + 1 gün).
Tek bir kaza mı, sistematik mi — ölçek lazım.

### #23 — 🔴 Aynı `TxnId` iki farklı `ProductCode` altında var mı (ayrım açığı testi)

```sql
SET NOCOUNT ON;
SELECT TOP (20) TxnId, COUNT(DISTINCT ProductCode) AS ProductCodeCount,
       MIN(ProductCode) AS Code1, MAX(ProductCode) AS Code2, COUNT(*) AS RowCnt
FROM dbo.AccEntryMain
GROUP BY TxnId
HAVING COUNT(DISTINCT ProductCode) > 1
ORDER BY TxnId DESC;
```
Neden: progress-26'da `AccEntryMain`'e `ProductCode` filtresi eklendi; gerekçe "TxnMM ve TxnLoan Id
aralıkları örtüşürse yanlış fiş okunur" idi ve **latent** diye kaydedilmişti. #21 gösterdi ki
`ProductCode='MM'` satırlarının `TxnId` aralığı (551011–1201167) `Loan`'ın aralığını (552940–553162)
**kapsıyor**. Bu sorgu aynı `TxnId`'nin iki ürüne ait fişi olup olmadığını kesin söyler.

### #24 — TxnLoan Id aralığı ile MM fişlerinin çakışması

```sql
SET NOCOUNT ON;
SELECT TOP (20) a.Id, a.TxnId, a.ProductCode, a.Type, a.IsReverse, a.ValueDate
FROM dbo.AccEntryMain a
WHERE a.ProductCode = 'MM' AND a.TxnId >= 1201069
ORDER BY a.Id DESC;
```
Neden: #21'de `ProductCode='MM'` için `MaxTxnId = 1201167` çıktı — bu değer daha önce **TxnLoan**
Id uzayı (≥1.201.069) olarak kaydedilmişti. Bu satırlar gerçekten TxnLoan'a mı işaret ediyor?

### #25 — 🔴 TxnMM ↔ TxnLoan Id aralıkları (progress-26'da #17 olarak denenip ERİŞİLEMEMİŞTİ)

```sql
SET NOCOUNT ON;
SELECT 'TxnMM' AS Tbl, MIN(Id) AS MinId, MAX(Id) AS MaxId, COUNT(*) AS Cnt FROM dbo.TxnMM
UNION ALL
SELECT 'TxnLoan', MIN(Id), MAX(Id), COUNT(*) FROM dbo.TxnLoan;
```
Neden: `AccEntryMain` iki navigation'ı da **aynı `TxnId` FK**'sına bağlıyor, discriminator yok
(`AccEntryMainConfiguration.cs:72-80`). Aralıklar örtüşürse yanlış ürünün fişi okunabilir.
#24 bunu şüpheli hale getirdi: `ProductCode='Loan'` fişlerinin `TxnId`'leri (552940–553162)
TxnMM aralığına benziyor, `ProductCode='MM'` fişlerinin bir kısmı (≥1201069) TxnLoan aralığına.

### #26 — Aynı Id iki tabloda birlikte var mı (kesin test)

```sql
SET NOCOUNT ON;
SELECT TOP (20) l.Id
FROM dbo.TxnLoan l
WHERE EXISTS (SELECT 1 FROM dbo.TxnMM m WHERE m.Id = l.Id)
ORDER BY l.Id DESC;
```
Neden: örtüşme **fiilen** var mı — tek satır bile çıkarsa `ProductCode` filtresi latent değil
**aktif** koruma demektir.

### #27 — `ProductCode='Loan'` fişleri hangi tabloya ait

```sql
SET NOCOUNT ON;
SELECT TOP (20) a.Id, a.TxnId, a.ProductCode,
       CASE WHEN EXISTS (SELECT 1 FROM dbo.TxnMM m WHERE m.Id = a.TxnId) THEN 1 ELSE 0 END AS InTxnMM,
       CASE WHEN EXISTS (SELECT 1 FROM dbo.TxnLoan l WHERE l.Id = a.TxnId) THEN 1 ELSE 0 END AS InTxnLoan
FROM dbo.AccEntryMain a
WHERE a.ProductCode = 'Loan'
ORDER BY a.Id DESC;
```
Neden: `ProductCode` **ürün tanımından** (`MainProductCode`) geliyor, tablodan değil. Bu sorgu
`ProductCode`'un tabloyu gösterip göstermediğini doğrudan söyler.

### #28 — T+0 fişinin `StateMaker`'ı kim (T-01 / audit C-19)

```sql
SET NOCOUNT ON;
SELECT TOP (20) Id, LogicalReference, StateMaker, StateDate
FROM dbo.TxnMM
WHERE Id = 553337
ORDER BY Id DESC;
```
Neden: #18'de ekranın kestiği çiftte T+0 `StateMaker = PARTNER.TREASY.004`, T+1
`StateMaker = PARTNER_NETIX_001`. İkisi **farklı**. T+1 bizim `CurrentUserId`'miz (T-01 fix'i);
T+0'ın kimden geldiği doğrulanacak — transaction'ın kendi maker'ı mı?

### #29 — Ekranda `Not Reversed` görünecek satırlar hangi tarihte

```sql
SET NOCOUNT ON;
SELECT TOP (20) a.Id, a.TxnId, a.ValueDate, a.ProductCode, a.ReverseId, m.LogicalReference
FROM dbo.AccEntryMain a
INNER JOIN dbo.TxnMM m ON m.Id = a.TxnId
WHERE a.Type = 2 AND a.IsReverse = 0 AND a.ReverseId = 0
ORDER BY a.Id DESC;
```
Neden: kullanıcı ters fiş valörü popup'ını **göremedi**. Popup doküman § 8.2 gereği yalnız
`Not Reversed` satır seçildiğinde çıkıyor; kullanıcının ekran görüntüsündeki özet
**"0 Not Reversed"** diyordu. Hangi `ExecutionDate` ile hangi satırın `Not Reversed` görüneceğini
kesin söylemek için (`ReverseId = 0` → `DeriveStatus` = NotReversed).

### #30 — 🔴 Kaybolan satırın `TxnTypeCode`'u `defTxnType`'ta var mı (INNER JOIN bug'ı)

```sql
SET NOCOUNT ON;
SELECT TOP (20) m.Id, m.LogicalReference, m.TxnTypeCode, m.MarketCode, m.PortfolioCode,
       CASE WHEN EXISTS (SELECT 1 FROM dbo.defTxnType t WHERE t.Code = m.TxnTypeCode) THEN 1 ELSE 0 END AS TxnTypeExists
FROM dbo.TxnMM m
WHERE m.Id IN (553292, 553311, 553306, 553283)
ORDER BY m.Id DESC;
```
Neden: API'de `Status = NotReversed` filtresiyle `totalCount = 1` ama `items` **boş** döndü.
Sayım sorgusu `Direction` navigation'ına dokunmuyor, satır projeksiyonu
(`TransactionDataManager.cs:101` → `p.Entity.Direction.Name`) dokunuyor. `Direction`
`IsRequired()` olduğu için (`TxnMmEntityConfiguration.cs:110-113`, FK = `TxnTypeCode`) EF
**INNER JOIN** üretiyor → `defTxnType`'ta karşılığı olmayan satır **sessizce düşüyor**.
553292 kaybolan satır, diğer 3'ü dönen satırlar — karşılaştırma için birlikte sorgulanıyor.

### #31 — 🔴 Kaybolan satırın required FK'ları dolu mu (INNER JOIN adayları)

```sql
SET NOCOUNT ON;
SELECT TOP (20) m.Id, m.LogicalReference, m.CustomerId, m.BasisCode, m.TxnMmProductTypeId,
       m.MarketCode, m.Ccy, m.TermId, m.PortfolioId, m.FundSourceId
FROM dbo.TxnMM m
WHERE m.Id IN (553292, 553311, 553306, 553283)
ORDER BY m.Id DESC;
```
Neden: #30'da `TxnTypeCode` sağlam çıktı, yani `Direction` teorisi düştü. Projeksiyonda kullanılan
**diğer `IsRequired()` navigation'lar**: `Customer` (FK `CustomerId`), `Basis` (FK `BasisCode`),
`Product` (FK `TxnMmProductTypeId`) — `TxnMmEntityConfiguration.cs:95-108`. EF Core required
navigation'da `x.Nav != null` guard'ını sadeleştirip **INNER JOIN** üretebiliyor; FK **NULL** ya da
karşılığı yoksa satır sessizce düşer. 553292 kaybolan, diğer 3'ü dönen satır — fark aranıyor.

### #32 — 🔴 `CustomerId = 1086` `cusCustomer`'da var mı (kaybolan satırın tek farkı)

```sql
SET NOCOUNT ON;
SELECT TOP (20) m.Id, m.LogicalReference, m.CustomerId,
       CASE WHEN EXISTS (SELECT 1 FROM dbo.cusCustomer c WHERE c.Id = m.CustomerId) THEN 1 ELSE 0 END AS CustomerExists,
       CASE WHEN EXISTS (SELECT 1 FROM dbo.defDateBasis b WHERE b.Id = m.BasisCode) THEN 1 ELSE 0 END AS BasisExists
FROM dbo.TxnMM m
WHERE m.Id IN (553292, 553311, 553306, 553283)
ORDER BY m.Id DESC;
```
Neden: #31'de tüm required FK'lar dolu çıktı ama kaybolan satırın `CustomerId`'si (**1086**)
dönen üç satırdan (**2107**) farklı. `Customer` navigation'ı `IsRequired()`
(`TxnMmEntityConfiguration.cs:95-98`) → EF **INNER JOIN** üretiyor; FK dolu ama **karşılığı yoksa**
satır sessizce düşer ve `COUNT` sorgusu bunu görmez (o join'i yapmıyor).

### #33 — `cusCustomer` anahtar kolonunun gerçek adı

```sql
SET NOCOUNT ON;
SELECT TOP (20) COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'cusCustomer'
ORDER BY ORDINAL_POSITION;
```
Neden: #32 iki kez `Invalid column name` verdi (`Id`, `CustomerId`). EF config `HasKey(e => e.Id)`
diyor ama DB kolon adı farklı (muhtemelen `HasColumnName` ile eşlenmiş). Doğru kolon adı olmadan
FK çözünürlüğü test edilemiyor.


---

## Tur 2026-08-24 — PO geri bildirimi: SubProduct listesi gerçek kaynaktan

### #34 — `PrdProductDefinition` alt ürün listesi (MM + InterbankLoan)

```sql
SET NOCOUNT ON;
SELECT TOP (50) Id, Code, Name, MainProductCode, ModuleCode, IsActive
FROM PrdProductDefinition
ORDER BY Id DESC;
```

**Neden:** PO isteği (2026-08-24) — Manuel Reeskont'un `Sub Product` listesi `treasury.json`'da
**elle yazılı**; kullanıcı bunun `MmTransaction/Index` ve `InterbankLoan/Index` ekranlarındaki
`Product Type` kutusuyla **aynı kaynaktan** (`GetProductDefinitions`) dolmasını istiyor.
Ayrıca: *"Money Market modülünde Pas/Gil gelecek, bunları listeden hard olarak çıkarabilirsin"* —
`Pas`/`Gil` kayıtlarının **gerçek `Code`/`Name` değerlerini** görmem lazım ki filtreyi doğru yazayım.

⚠️ `TOP (50)` kullanıldı (kural `TOP (20)`): bu bir **referans/tanım** tablosu, satır sayısı düşük
ve **listenin tamamını** görmek işin özü — 20 satır MM + InterbankLoan alt ürünlerinin tamamını
kapsamayabilir. Kolonlar tek tek yazıldı, `SELECT *` yok.

🔴 Şema varsayımı: kolon adları koddan (`ProductDefinitionDataManager`) tahmin edildi;
hata verirse `INFORMATION_SCHEMA` ile doğrulanacak ve o sorgu da **#35** olarak kaydedilecek.


### #35 — `PrdProductDefinition` gerçek şeması

```sql
SET NOCOUNT ON;
SELECT COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'PrdProductDefinition'
ORDER BY ORDINAL_POSITION;
```

**Neden:** #34 `Invalid column name 'ModuleCode'` ve `'IsActive'` verdi. Koddan tahmin ettiğim
kolon adları DB'de yok; doğru adları görmeden listeyi çekemiyorum.


### #36 — Alt ürün listesi (doğru kolon adlarıyla)

```sql
SET NOCOUNT ON;
SELECT TOP (50) Id, Code, Name, MainProductCode, IsEnabled, StateId, [Order]
FROM PrdProductDefinition
ORDER BY MainProductCode, [Order], Id;
```

**Neden:** #35 gerçek şemayı verdi. Şimdi asıl soru: MM ve InterbankLoan'ın alt ürünleri
neler, `Pas`/`Gil` kayıtları hangi `Code`/`Name` ile duruyor, hangileri `IsEnabled = 0`.
`ORDER BY` ekrandaki sırayı taklit ediyor (`Order` kolonu var → ekran onunla sıralıyor olabilir).

## Tur 2026-08-26 — 🔴 MM / InterbankLoan tablo izolasyonu (kullanici sorusu)

**Kullanicinin sorusu:** *"MM ve InterbankLoan ekranlarini strategy pattern'le beraber goturuyorum,
kayit tablolari ayri, Manuel Reeskont'ta da Product olarak ayirdim. Select ve execute islemlerinde
bunlar yine ayri gidiyor degil mi, yanlislikla kod hatasindan dolayi birbirinin tablolarina bakip
islem yapmiyorlar?"*

**Kod okumasindan cikan iki gerceklestirilmis endise:**

1. `AccEntryMainConfiguration.cs:69-77` — `accEntryMain.TxnId` **AYNI KOLON** iki tabloya FK:
   `HasOne(x => x.Transaction)` → `TxnMM.Id` **ve** `HasOne(x => x.TransactionLoan)` → `TxnLoan.Id`.
   Join'de discriminator **yok**.
2. Manuel Reeskont sorgulari ayrimi `a.ProductCode == x.Product.MainProductCode` (MM) /
   `a.ProductCode == x.ProductDefinition.MainProductCode` (Loan) ile yapiyor. Ama **#36** (2026-08-24)
   `MainProductCode`'un **11 urun taniminin tamaminda `'MM'`** oldugunu gosterdi — `Loan` (Id 2)
   dahil. Yani iki taraf da `'MM'`'e cozuluyor, filtre **ayrim yapmiyor**.

Kalan tek bilinmeyen: **Id araliklari cakisiyor mu.** Bu soru `#17` olarak sorulmus ama o gun
`192.168.10.211` erisilemedigi icin sorgu **hic kosmamis** (bkz. `02-ciktilar.md` → `#17`).
Simdi kosturuluyor.

### #37 — TxnMM ve TxnLoan Id araliklari

**Amac:** iki tablonun Id araliklari ortusuyor mu — ortusmuyorsa (ör. biri 1-1000, digeri
500000+) cakisma **fiilen** imkansiz ve mevcut kod guvenli; ortusuyorsa gercek para riski var.

```sql
SET NOCOUNT ON;
SELECT 'TxnMM' AS Tbl, MIN(Id) AS MinId, MAX(Id) AS MaxId, COUNT(*) AS Cnt FROM dbo.TxnMM
UNION ALL
SELECT 'TxnLoan', MIN(Id), MAX(Id), COUNT(*) FROM dbo.TxnLoan;
```

### #38 — Fiilen kesisen Id var mi

**Amac:** aralik ortusmesi teorik; **ayni Id'nin iki tabloda da var olmasi** fiili cakismadir.
Varsa ornekleri gorulecek — o Id'ler Manuel Reeskont'ta test edilirse hata **uretilebilir**.

```sql
SET NOCOUNT ON;
SELECT TOP (20) l.Id
FROM dbo.TxnLoan l
WHERE EXISTS (SELECT 1 FROM dbo.TxnMM m WHERE m.Id = l.Id)
ORDER BY l.Id DESC;
```

### #39 — accEntryMain'de hangi ProductCode degerleri var

**Amac:** `#36` urun **tanimi** tablosunu gosterdi. Fis tarafinda gercekten ne yaziliyor?
`'MM'` disinda bir deger (ör. `'Loan'`) varsa filtre bir kismi ayirabiliyor demektir;
hepsi `'MM'` ise filtre tamamen etkisiz.

```sql
SET NOCOUNT ON;
SELECT TOP (20) a.ProductCode, COUNT(*) AS Cnt
FROM dbo.accEntryMain a
GROUP BY a.ProductCode
ORDER BY COUNT(*) DESC;
```

### #40 — Cakisan bir Id'nin fisleri gercekten karisiyor mu

**Amac:** #38 bir Id verirse (ör. `X`), o Id icin `accEntryMain`'de kac fis var ve
`ProductCode`'lari ne — yani Manuel Reeskont Loan urunuyle bakildiginda MM'in fisi
gorunur mu. **Bu sorgu #38'in sonucuna gore parametrelenecek.**

```sql
SET NOCOUNT ON;
SELECT TOP (20) a.Id, a.TxnId, a.ProductCode, a.TxnTypeCode, a.Type, a.IsReverse,
       a.ReverseId, a.ValueDate
FROM dbo.accEntryMain a
WHERE a.TxnId = <#38'den gelen Id>
ORDER BY a.Id DESC;
```

### #41 — 🔴 `ProductCode = 'Loan'` fisleri kime ait

**Neden:** #39 beklenmedik bir sonuc verdi — `accEntryMain.ProductCode`'da **uc** deger var:
`MM` (4774), `TWR` (46), `Loan` (20). Oysa `#36` urun **tanimi** tablosunda `MainProductCode`
**hepsinde `'MM'`**. Yani fis tarafindaki `ProductCode` `MainProductCode`'dan gelmiyor olabilir.

Bu **kritik**, cunku Manuel Reeskont'un Loan sorgusu ayrimi
`a.ProductCode == x.ProductDefinition.MainProductCode` ile yapiyor → `a.ProductCode == 'MM'`.
Loan'in kendi fisleri `'Loan'` ise bu filtre **Loan'in kendi fislerini disliyor** demektir
(korktugumun tersi yon: cakisma degil, **kor nokta**).

```sql
SET NOCOUNT ON;
SELECT TOP (20) a.Id, a.TxnId, a.ProductCode, a.TxnTypeCode, a.Type, a.IsReverse,
       a.ReverseId, a.ValueDate
FROM dbo.accEntryMain a
WHERE a.ProductCode = 'Loan'
ORDER BY a.Id DESC;
```

### #42 — TxnLoan islemlerinin fisleri hangi ProductCode ile yazilmis

**Neden:** #41 fis tarafina bakiyor; bu sorgu **islem tarafindan** bakiyor. TxnLoan Id araligi
(#37: 1201069-1201167) icin `accEntryMain`'de hangi `ProductCode`'lar var? Hepsi `'Loan'` ise
Manuel Reeskont'un Loan ucu **hicbir fis goremiyor** demektir.

```sql
SET NOCOUNT ON;
SELECT a.ProductCode, a.Type, COUNT(*) AS Cnt
FROM dbo.accEntryMain a
WHERE EXISTS (SELECT 1 FROM dbo.TxnLoan l WHERE l.Id = a.TxnId)
GROUP BY a.ProductCode, a.Type
ORDER BY COUNT(*) DESC;
```

### #43 — `TWR` (Tawarruq) fisleri hangi tabloya ait

**Neden:** ucuncu deger `TWR`. Tawarruq MM tarafinda bir ozellik (`feature:Tawarruq:Enable`).
Ayni kor nokta MM ucunda da var mi — yani `ProductCode='TWR'` olan bir MM islemi
`a.ProductCode == 'MM'` filtresi yuzunden goz ardi ediliyor mu?

```sql
SET NOCOUNT ON;
SELECT a.ProductCode, a.Type, COUNT(*) AS Cnt,
       SUM(CASE WHEN EXISTS (SELECT 1 FROM dbo.TxnMM m WHERE m.Id = a.TxnId) THEN 1 ELSE 0 END) AS TxnMMde,
       SUM(CASE WHEN EXISTS (SELECT 1 FROM dbo.TxnLoan l WHERE l.Id = a.TxnId) THEN 1 ELSE 0 END) AS TxnLoanda
FROM dbo.accEntryMain a
WHERE a.ProductCode IN ('TWR', 'Loan')
GROUP BY a.ProductCode, a.Type
ORDER BY a.ProductCode, a.Type;
```

### #44 — `#43`'un duzeltilmis hali (SUM icinde EXISTS yasak)

**Neden:** #43 `Msg 130: Cannot perform an aggregate function on an expression containing an
aggregate or a subquery` verdi — `SUM(CASE WHEN EXISTS(...))` T-SQL'de gecersiz. LEFT JOIN'e
cevriliyor. Amac ayni: `TWR` ve `Loan` kodlu fisler hangi islem tablosuna ait.

```sql
SET NOCOUNT ON;
SELECT a.ProductCode, a.Type,
       COUNT(*) AS Cnt,
       COUNT(m.Id) AS TxnMMde,
       COUNT(l.Id) AS TxnLoanda
FROM dbo.accEntryMain a
LEFT JOIN dbo.TxnMM   m ON m.Id = a.TxnId
LEFT JOIN dbo.TxnLoan l ON l.Id = a.TxnId
WHERE a.ProductCode IN ('TWR', 'Loan')
GROUP BY a.ProductCode, a.Type
ORDER BY a.ProductCode, a.Type;
```

### #45 — Id ayrikligi GARANTI mi, tesaduf mu (IDENTITY tohumlari)

**Neden:** #37/#38 araliklarin ayrik oldugunu ve kesisimin **0** oldugunu gosterdi — yani bugun
cakisma yok. Ama bu **yapisal bir garanti mi**? TxnMM 553350'de, TxnLoan 1201069'da basliyor.
TxnMM buyuyup 1201069'a ulasirsa cakisma **baslar**. Iki kolon ayri IDENTITY mi, ortak bir
SEQUENCE mi, yoksa trigger mi uretiyor — cevaba gore risk "yok" ya da "simdilik yok".

```sql
SET NOCOUNT ON;
SELECT t.name AS TableName, c.name AS ColName, c.is_identity,
       ic.seed_value, ic.increment_value, ic.last_value
FROM sys.tables t
JOIN sys.columns c ON c.object_id = t.object_id
LEFT JOIN sys.identity_columns ic ON ic.object_id = t.object_id AND ic.column_id = c.column_id
WHERE t.name IN ('TxnMM', 'TxnLoan') AND c.name = 'Id';
```

### #46 — TxnMM tablosunda `Loan` (Id 2) urunlu islem var mi

**Neden:** Manuel Reeskont MM ucu alt urun suzgecini `subProductTypeIds.Contains(x.TxnMmProductTypeId)`
ile yapiyor ve alt urun listesi `PrdProductDefinition`'in **tamamindan** geliyor — icinde
`Loan` (Id 2) de var. TxnMM'de `TxnMmProductTypeId = 2` olan satir varsa, kullanici
"MM Transactions" urununu secip alt urun olarak "Interbank Loan" secebilir ve **TxnMM'deki**
loan islemlerini gorur. Bu kod hatasi degil ama iki ekranin ayni islemi iki yerden gostermesi
demek olabilir — kullaniciya bildirilmeli.

```sql
SET NOCOUNT ON;
SELECT TOP (20) t.TxnMmProductTypeId, p.Code, p.Name, COUNT(*) AS Cnt
FROM dbo.TxnMM t
LEFT JOIN dbo.PrdProductDefinition p ON p.Id = t.TxnMmProductTypeId
GROUP BY t.TxnMmProductTypeId, p.Code, p.Name
ORDER BY COUNT(*) DESC;
```

### #47 — 🔴 `ProductCode='Loan'` acilis fisi olan TxnMM satirlari Manuel Reeskont'ta GORUNUYOR mu

**Neden:** #46 `TxnMM`'de **12 satirin** `TxnMmProductTypeId = 2` (Interbank Loan) oldugunu gosterdi.
#44 ise `ProductCode='Loan'` olan **20 acilis fisinin tamaminin TxnMM'de** oldugunu gosterdi.
Manuel Reeskont MM ucunun uygunluk sarti:

```csharp
x.AccountingMainEntries.Any(w => w.Type == openingType &&
                                 w.ProductCode == x.Product.MainProductCode)   // == 'MM'
```

Bu satirlarin acilis fisi `'Loan'` ise sart **saglanmiyor** → satir MM listesinde **hic
gorunmuyor**. TxnLoan tablosunda da olmadiklari icin InterbankLoan listesinde de yok.
Yani **kor nokta** olabilir. Bu sorgu onu olcuyor.

```sql
SET NOCOUNT ON;
SELECT t.Id, t.TxnMmProductTypeId,
       SUM(CASE WHEN a.ProductCode = 'MM'   AND a.Type = 1 THEN 1 ELSE 0 END) AS AcilisMM,
       SUM(CASE WHEN a.ProductCode = 'Loan' AND a.Type = 1 THEN 1 ELSE 0 END) AS AcilisLoan,
       SUM(CASE WHEN a.Type = 2 THEN 1 ELSE 0 END) AS ReeskontFisi
FROM dbo.TxnMM t
LEFT JOIN dbo.accEntryMain a ON a.TxnId = t.Id
WHERE t.TxnMmProductTypeId = 2
GROUP BY t.Id, t.TxnMmProductTypeId
ORDER BY t.Id DESC;
```

### #48 — `TxnMM.Id` / `TxnLoan.Id` degeri NEREDEN uretiliyor

**Neden:** #45 iki kolonun da **IDENTITY olmadigini** gosterdi (`is_identity = 0`). O halde Id'yi
uygulama ya da bir trigger/sequence uretiyor. Ayrikligin (551002-553350 vs 1201069-1201167)
**yapisal garanti** mi yoksa **tesaduf** mu oldugu buna bagli: ortak bir sequence varsa asla
cakismazlar; ayri sayaclarsa TxnMM buyudugunde cakisabilirler.

```sql
SET NOCOUNT ON;
SELECT name, start_value, increment, current_value FROM sys.sequences ORDER BY name;
```

```sql
SET NOCOUNT ON;
SELECT TOP (20) t.name AS TriggerName, OBJECT_NAME(t.parent_id) AS TableName, t.is_disabled
FROM sys.triggers t
WHERE OBJECT_NAME(t.parent_id) IN ('TxnMM', 'TxnLoan')
ORDER BY t.name;
```

### #49 — `TxnMMTrigger` / `TxnLoanTrigger` govdesi: Id nasil uretiliyor

**Neden:** #48a `sys.sequences` **bos** dondu (hic sequence yok), #48b iki tabloda da aktif
trigger oldugunu gosterdi. Id IDENTITY degil, sequence de yok → muhtemelen trigger uretiyor.
Govdeyi okumak ayrikligin **garanti mi tesaduf mu** oldugunu soyleyecek. `EXEC sp_helptext`
**yasak**, `sys.sql_modules` kullaniliyor.

```sql
SET NOCOUNT ON;
SELECT tr.name, LEFT(m.definition, 2000) AS Body
FROM sys.sql_modules m
JOIN sys.triggers tr ON tr.object_id = m.object_id
WHERE tr.name IN ('TxnMMTrigger', 'TxnLoanTrigger');
```

### #50 — `ProductCode='Loan'` acilis fisi olan TxnMM satirlarinin reeskont fisi var mi

**Neden:** #47 gosterdi ki `TxnMmProductTypeId=2` olan 12 TxnMM satirinin **hicbirinin**
`'Loan'` kodlu acilisi yok (8'inde normal `'MM'` acilis var) — yani korktugum kor nokta
**o satirlarda yok**. Ama #41'deki 20 `'Loan'` kodlu acilis **baska** TxnMM satirlarina ait.
O satirlar Manuel Reeskont MM uygunluk sartini (`acilis fisi ProductCode='MM'`) sagliyor mu,
ve zaten reeskont kesilen satirlar mi — yani kor nokta gercek bir kayip mi yoksa
onemsiz mi.

```sql
SET NOCOUNT ON;
SELECT COUNT(DISTINCT a.TxnId) AS LoanAcilisliTxn,
       COUNT(DISTINCT CASE WHEN mm.TxnId IS NOT NULL THEN a.TxnId END) AS AyricaMMAcilisiVar,
       COUNT(DISTINCT CASE WHEN rv.TxnId IS NOT NULL THEN a.TxnId END) AS ReeskontFisiVar
FROM dbo.accEntryMain a
LEFT JOIN (SELECT DISTINCT TxnId FROM dbo.accEntryMain WHERE Type = 1 AND ProductCode = 'MM') mm
       ON mm.TxnId = a.TxnId
LEFT JOIN (SELECT DISTINCT TxnId FROM dbo.accEntryMain WHERE Type = 2) rv
       ON rv.TxnId = a.TxnId
WHERE a.Type = 1 AND a.ProductCode = 'Loan';
```

## Tur 2026-08-26 (2) — `AccEntryEntity` EF tracking hatasi

Kullanicinin Generate'te aldigi hata:
`The instance of entity type 'AccEntryEntity' cannot be tracked because another instance with the
same key value for {'Id'} is already being tracked.`

Kodda ölçülen: `AccEntryEntity.Id` **IDENTITY degil**, uygulama `sp_GetNewNumbers` ile atiyor
(`NumberGeneratorDataService.GetNewNumbersWithPrefixAsync` → `EXEC dbo.sp_GetNewNumbers`).
Iki farkli CLR instance'in **ayni Id**'yi alabilmesi icin o SP'nin ayni numarayi **iki kez**
dondurmesi gerekir. SP govdesi okunmadan bu ne dogrulanabilir ne de elenebilir.

### #51 — `sp_GetNewNumbers` govdesi

**Neden:** Id'yi kim/nasil uretiyor — sayaci `UPDATE` ile mi ilerletiyor, yoksa hedef tablodan
`MAX(Id)+1` mi okuyor? `MAX` okuyorsa **ayni islem icinde henuz flush edilmemis** satirlar
gorunmez ve ikinci cagri **ayni numarayi** dondurur → hatanin birebir aciklamasi.
`EXEC sp_helptext` **yasak**, `sys.sql_modules` kullaniliyor.

```sql
SET NOCOUNT ON;
SELECT o.name, LEFT(m.definition, 4000) AS Body
FROM sys.sql_modules m
JOIN sys.objects o ON o.object_id = m.object_id
WHERE o.name = 'sp_GetNewNumbers';
```

### #52 — `DefNumberGen` sayac satirlari (AccountingEntry / AccountingEntryMain / GeneratedAccountingEntry)

**Neden:** Kodda `EntityColumnType.AccountingEntry_Id`, `GeneratedAccountingEntry_Id` ve
`AccountingEntryMain_Id` **ucu de `55` onekini** kullaniyor
(`NumberGeneratorDataService._entityPrefixDictionary`). Sayaclar **ayri satirlar mi** yoksa
ayni satiri mi paylaşiyorlar — paylaşiyorlarsa ayni turda alinan iki numara kumesi ortusebilir.
Kolon adlari bilinmedigi icin once tablo semasi okunuyor.

```sql
SET NOCOUNT ON;
SELECT TOP (20) c.name AS ColName, ty.name AS TypeName, c.max_length, c.is_nullable
FROM sys.columns c
JOIN sys.tables t ON t.object_id = c.object_id
JOIN sys.types ty ON ty.user_type_id = c.user_type_id
WHERE t.name = 'DefNumberGen'
ORDER BY c.column_id;
```

### #53 — `accEntryMain` / `accEntry` Id kolonu IDENTITY mi (kod bulgusunun DB dogrulamasi)

**Neden:** `#45`'te `TxnMM`/`TxnLoan` icin IDENTITY olmadigi olculmustu. Ayni sey muhasebe
tablolari icin de gecerliyse "Id'yi uygulama atiyor" zinciri kapanir ve duplicate Id senaryosu
**tek olasi** aciklama kalir.

```sql
SET NOCOUNT ON;
SELECT t.name AS TableName, c.name AS ColName, c.is_identity
FROM sys.tables t
JOIN sys.columns c ON c.object_id = t.object_id
WHERE t.name IN ('accEntryMain', 'accEntry') AND c.name = 'Id';
```

### #54 — 🔴 SAYAC KAYMASI: `defNumberGen.LastNumber` tablonun gercek MAX'inin gerisinde mi

**Neden:** `#51` gosterdi ki `sp_GetNewNumbers` sayaci `UPDATE ... WITH (ROWLOCK, UPDLOCK)` ile
**monoton** ilerletiyor — mukerrer numara **uretemez**. O halde EF'in
*"another instance with the same key value is already being tracked"* hatasi icin kalan tek
mekanik aciklama: sayacin dagittigi Id **tabloda ZATEN VAR**. Bu, satirlar sayac ilerletilmeden
(script/migration ile) eklendiginde olur.

Kodda Id soyle uretiliyor (`NumberGeneratorDataService`):
`Id = int.Parse("55" + LastNumber)` — yani `LastNumber = 4576` → `Id = 554576`.
Dolayisiyla karsilastirma **`MAX(Id) - 550000`** ile `LastNumber` arasinda yapilir
(`accEntryMain`, `accEntry`, `TxnMM` icin onek 55).

EntityColumnType degerleri (`EntityColumnType.cs`): `TransactionMM_Id = 1` ·
`AccountingEntryMain_Id = 2` · `AccountingEntry_Id = 3` · `GeneratedAccountingEntry_Id = 4`.

```sql
SET NOCOUNT ON;
SELECT g.EntityColumnType, g.LastNumber, g.LastUpdateDate,
       (SELECT MAX(a.Id) FROM dbo.accEntryMain a) AS MaxAccEntryMainId,
       (SELECT MAX(e.Id) FROM dbo.accEntry e)     AS MaxAccEntryId,
       (SELECT MAX(m.Id) FROM dbo.TxnMM m)        AS MaxTxnMmId
FROM dbo.defNumberGen g
WHERE g.EntityColumnType IN (1, 2, 3, 4)
ORDER BY g.EntityColumnType;
```

### #55 — Sayacin dagitacagi SONRAKI Id tabloda var mi (dogrudan test)

**Neden:** #54 sayilarla kiyas veriyor; bu sorgu **niyeti** test ediyor: `LastNumber + 1`'den
baslayan ilk 20 Id'nin kaci `accEntry`'de **zaten mevcut**. Sifirdan buyukse hata mekanigi
kanitlanmis olur.

```sql
SET NOCOUNT ON;
WITH nxt AS (
    SELECT TOP (20) CAST('55' + CAST(g.LastNumber + v.n AS varchar(20)) AS int) AS NextId
    FROM dbo.defNumberGen g
    CROSS JOIN (SELECT TOP (20) ROW_NUMBER() OVER (ORDER BY object_id) AS n FROM sys.objects) v
    WHERE g.EntityColumnType = 3
    ORDER BY v.n
)
SELECT n.NextId, CASE WHEN e.Id IS NULL THEN 0 ELSE 1 END AS TablodaVar
FROM nxt n
LEFT JOIN dbo.accEntry e ON e.Id = n.NextId
ORDER BY n.NextId;
```


## Tur 2026-09-01 — Ayna çifti canlı test doğrulaması (TreasuryRediscount/Index)

**Bağlam:** MM+WebUI canlı ayakta, Fimple sync flag kapalı. TransactionId 553344 (TMMBRW2608210004)
üzerinde sırayla Generate(NotRediscounted→NotReversed)→Generate(NotReversed→Rediscounted)→
Regenerate(Rediscounted, ayna çifti) endpoint'leri çağrıldı, hepsi isSuccess:true döndü.
Bu sorgu DB'de gerçekte kaç AccEntryMain satırı yazıldığını ve ReverseId zincirinin beklendiği
gibi olup olmadığını doğruluyor.

```sql
SET NOCOUNT ON;
SELECT TOP (20) Id, TxnId, ValueDate, IsReverse, ReverseId, MessageKey, Description, StateDate
FROM dbo.accEntryMain
WHERE TxnId = 553344
ORDER BY Id DESC;
```

## Tur 2026-09-01 (2) — Regenerate(NotReversed) + karışık statülü toplu Execute doğrulaması

**Bağlam:** 553306 (NotReversed→Regenerate, tek satır, çağrı ~2dk sürdü — Fimple flag kapalı
olmasına rağmen anormal yavaş, ayrıca araştırılacak) ve 553283+553326'nın TEK istekte karışık
statüyle (NotReversed + Rediscounted) Regenerate'i test edildi, ikisi de isSuccess:true.
Bu sorgu üç transaction'ın gerçek accEntryMain zincirini doğruluyor.

```sql
SET NOCOUNT ON;
SELECT TOP (20) Id, TxnId, ValueDate, IsReverse, ReverseId, StateDate
FROM dbo.accEntryMain
WHERE TxnId IN (553306, 553283, 553326)
ORDER BY Id DESC;
```

## Tur 2026-09-04 — 🔴 Cluster'da EF tracking hatasi: MUKERRER accEntry.Id hipotezi

**Baglam:** Cluster'da (deploy) `AccEntryEntity ... same key value for {'Id'} is already being tracked`
hatasi 553344 ve 553336'da tekrarliyor; local'de ayni akis gecti. Hipotez: hata kod degil VERI
kaynakli — `accEntry` tablosunda ayni Id'ye sahip iki satir varsa, tracking bir sorgu (Include ile)
o iki satiri ayni graph'a materialize ederken EF tam bu hatayi atar. Oyleyse `ChangeTracker.Clear()`
duzeltmesi bunu COZMEZ, once bu olculmeli (deploy pahali).

```sql
SET NOCOUNT ON;
SELECT TOP (20) e.Id, COUNT(*) AS Adet
FROM dbo.accEntry e
WHERE e.TxnId IN (553344, 553336)
GROUP BY e.Id
HAVING COUNT(*) > 1
ORDER BY e.Id DESC;
```

```sql
SET NOCOUNT ON;
SELECT TOP (20) m.Id, m.TxnId, m.ValueDate, m.IsReverse, m.ReverseId, m.MessageKey, m.StateDate
FROM dbo.accEntryMain m
WHERE m.TxnId IN (553344, 553336) AND m.ValueDate >= '2026-09-02'
ORDER BY m.Id DESC;
```

---

## 2026-09-04 — `sp_GetNewNumbers` sozlesmesi + sayac vs MAX(Id)

**Neden:** Cluster'da `AccEntryEntity ... already being tracked` hatasi hem reeskont hem ters fis
yolunda cikiyor; iki yol da `AccountingDataManager.InsertAsync` icindeki
`acEntryIds` listesinden geciyor. Liste detay sayisindan **kisa** donerse dongu geri kalan
detaylarin `Id`'sini `0`'da birakir → grafta iki detay ayni anahtar (`0`) → tam bu hata.
Bu yuzden SP'nin **kac satir** dondurdugu ve sayacin `MAX(Id)`'ye gore konumu olculuyor.

```sql
SET NOCOUNT ON;
SELECT TOP (20) o.name, m.definition
FROM sys.sql_modules m
JOIN sys.objects o ON o.object_id = m.object_id
WHERE o.name = 'sp_GetNewNumbers'
ORDER BY o.name DESC;
```

---

## 2026-09-04 — Deploy sonrasi tekrar-uretim adayi: 553336 vs 553344 durumu

**Neden:** Teshis deploy'undan sonra hatayi tekrar uretebilmek icin **hala patlayacak** bir satir gerek.
`553344` local testimde tamamlandi (`newStatus 4`) → Generate artik `ALREADY_REDISCOUNTED` donebilir.
`553336` cluster'da iki kez patladi, local hic dokunmadi. Ikisinin 09-03 valorlu fis durumu okunuyor.

```sql
SET NOCOUNT ON;
SELECT TOP (20) m.Id, m.TxnId, m.ValueDate, m.IsReverse, m.ReverseId, m.Type, m.MessageKey, m.StateDate
FROM dbo.accEntryMain m
WHERE m.TxnId IN (553344, 553336, 553335)
  AND m.ValueDate >= '2026-08-17'
ORDER BY m.Id DESC;
```

---

## 2026-09-10 — `defNumberGen` sayaci `MAX(Id)`'nin GERISINDE mi? (tracking hatasinin ikinci yarisi)

**Neden:** Stack trace + izole EF deneyi kesinlestirdi: hata ancak **ayni sifir-olmayan `Id`'yi tasiyan
iki `AccEntryEntity`** ayni context'te izlenirse cikar. Prefix+sayi birlesimi matematiksel olarak
mukerrer uretemez, `sp_GetNewNumbers` atomik. Oyleyse cakisan ikinci nesne **var olan bir satir**
olmali → sayac `MAX(Id)`'nin gerisinde olabilir. Prefix 55, yani `Id = int('55' + LastNumber)`.

```sql
SET NOCOUNT ON;
SELECT TOP (20) g.EntityColumnType, g.LastNumber, g.LastUpdateDate
FROM dbo.defNumberGen g
WHERE g.EntityColumnType IN (1, 2, 3, 4)
ORDER BY g.EntityColumnType DESC;
```

```sql
SET NOCOUNT ON;
SELECT TOP (20) MAX(e.Id) AS MaxAccEntryId, COUNT(*) AS RowCnt FROM dbo.accEntry e;
```

```sql
SET NOCOUNT ON;
SELECT TOP (20) MAX(m.Id) AS MaxAccEntryMainId, COUNT(*) AS RowCnt FROM dbo.accEntryMain m;
```

```sql
SET NOCOUNT ON;
DECLARE @next int = CAST('55' + CAST((SELECT g.LastNumber FROM dbo.defNumberGen g
                                      WHERE g.EntityColumnType = 3) AS varchar(20)) AS int);
SELECT TOP (20) @next AS NextAccEntryId,
       (SELECT COUNT(*) FROM dbo.accEntry e WHERE e.Id > @next) AS RowsAheadOfCounter;
```

```sql
SET NOCOUNT ON;
SELECT TOP (20) e.Id, e.AccEntryMainId, e.TxnId, e.ValueDate, e.SeqNumber, e.StateDate
FROM dbo.accEntry e
WHERE e.TxnId = 553306
ORDER BY e.Id DESC;
```

---

## Tur: 2026-09-10 — "tek fis kesince de hata aliyorum" iddiasinin dogrulanmasi

**Amac:** `AccEntryEntity ... already being tracked` hatasinda kac `InsertAsync` denemesi oldugunu
belirlemek. `sp_GetNewNumbers` her `InsertAsync`'te `AccountingEntries.Count` kadar numara yakiyor;
sayac ile `MAX(Id)` arasindaki bosluklar deneme sayisini ve fis bacak sayisini veriyor.

**Baglanti:** `-S "tcp:192.168.10.211,1433" -d NetTrexMM -U trusr -P '***'`

### #56 — defNumberGen kolon adlari (sayac sorgusunu dogru yazmak icin)
```sql
SET NOCOUNT ON;
SELECT TOP (20) c.name AS ColumnName, t.name AS TypeName
FROM sys.columns c
JOIN sys.types t ON t.user_type_id = c.user_type_id
WHERE c.object_id = OBJECT_ID('dbo.defNumberGen')
ORDER BY c.column_id DESC;
```

### #57 — accEntryMain son 20 kayit (kac fis kesilmis, hangi txn/valor/tip)
```sql
SET NOCOUNT ON;
SELECT TOP (20) Id, TxnId, ValueDate, Type, IsReverse, ReverseId, ProductCode, StateId, StateDate
FROM dbo.accEntryMain
ORDER BY Id DESC;
```

### #58 — accEntry son 20 kayit (Id boslugu + bacak sayisi)
```sql
SET NOCOUNT ON;
SELECT TOP (20) Id, AccEntryMainId, TxnId, ValueDate, DebitCredit, Amount, SeqNumber, Ccy
FROM dbo.accEntry
ORDER BY Id DESC;
```

### #59 — accEntry son 20 (MAX(Id) sayacin onunde mi arkasinda mi + bacak sayisi)
```sql
SET NOCOUNT ON;
SELECT TOP (20) Id, AccEntryMainId, TxnId, ValueDate, DebitCredit, Amount, SeqNumber, Ccy
FROM dbo.accEntry
ORDER BY Id DESC;
```
**Beklenti:** sayac `Account Entry = 12390` → sonraki Id `5512391`.
MAX < 5512391 ise sayac **onde** (yakilan numaralar) → cakisma DB satiriyla olamaz.
MAX > 5512391 ise sayac **arkada** → generator var olan Id'yi tekrar dagitiyor.

### #60 — sp_GetNewNumbers TAM govde (CTE gercekten tekil mi?)
```sql
SET NOCOUNT ON;
SELECT TOP (1) m.definition
FROM sys.sql_modules m
WHERE m.object_id = OBJECT_ID('dbo.sp_GetNewNumbers');
```
**Gerekce:** gercek EF modeliyle olculdu — temiz context'te 2/4 tekil Id'li graf **sorunsuz** Attach ediliyor;
hata **yalniz** iki bacak ayni Id tasidiginda cikiyor. Grafta Id'leri tek atayan yer bu SP.

### #61 — sayaclar TEKRAR (15:39 denemesi kac InsertAsync yapti?)
```sql
SET NOCOUNT ON;
SELECT TOP (20) EntityColumnType, Definition, LastNumber, LastUpdateDate
FROM dbo.defNumberGen ORDER BY EntityColumnType DESC;
```
**Baz (11:52:32):** Main=6008 · Entry=12390 · GeneratedAccount=8000.
Entry **+2** / Main **+1** ise 15:39'da **tek** InsertAsync → cakisma grafin icinde.
Entry **+4** / Main **+2** ise **iki** InsertAsync → cakisma iki insert arasinda.

## 2026-09-15 — DerivSwp Manuel Reeskont: `interestRateDetailList is null` teshis

DB: `NetTrexDerivSWP` @ 192.168.10.211 — kullanici `trusr` / parola `***`

### S-01 — Hata veren islemin chart/currency bilgileri
```sql
SET NOCOUNT ON;
SELECT TOP (20) t.Id, t.LogicalReference, t.ReceiveCurrency, t.ReceiveIndexChartId,
       t.PayCurrency, t.PayIndexChartId, t.ReceiveMaturityDate, t.PayMaturityDate
FROM TxnTransaction t
WHERE t.LogicalReference IN ('TDCCS26081800001','TDIRS26072700001')
ORDER BY t.Id DESC;
```
Gerekce: `TotalNpvStep` iki bacak icin ayri getiri egrisi cekiyor; hangi ChartId+Ccy ikilisinin arandigini bulmak icin.

### S-02 — ChartId=7 icin 2026-09-10 getiri egrisi var mi, hangi para birimlerinde
```sql
SET NOCOUNT ON;
SELECT TOP (20) ir.Id, ir.ChartId, ir.YieldDate, ir.StateId, d.Ccy, COUNT(d.Id) AS DetailCount
FROM InterestRate ir LEFT JOIN InterestRateDetail d ON d.InterestRateId = ir.Id
WHERE ir.ChartId = 7 AND ir.YieldDate >= '2026-09-05' AND ir.YieldDate <= '2026-09-11'
GROUP BY ir.Id, ir.ChartId, ir.YieldDate, ir.StateId, d.Ccy
ORDER BY ir.Id DESC;
```
Gerekce: `InterestRateDetailRepository.GetListByFilter` `YieldDate == calculateDate.Date` ile TAM esitlik ariyor; USD bacagi icin kayit yoksa liste bos doner.

### S-03 — Sistemde USD egrisi hic var mi + en guncel yield tarihi
```sql
SET NOCOUNT ON;
SELECT TOP (20) d.Ccy, ir.ChartId, MAX(ir.YieldDate) AS LastYieldDate, COUNT(d.Id) AS DetailCount
FROM InterestRateDetail d JOIN InterestRate ir ON ir.Id = d.InterestRateId
GROUP BY d.Ccy, ir.ChartId ORDER BY MAX(ir.YieldDate) DESC;
```
Gerekce: USD bacagi icin hic egri girilmemis mi yoksa sadece 2026-09-10 gunu mu eksik.

### S-04 — ChartId=7 icin para birimi kirilimi (USD var mi?)
```sql
SET NOCOUNT ON;
SELECT TOP (20) d.Ccy, COUNT(d.Id) AS DetailCount, MIN(ir.YieldDate) AS FirstYield, MAX(ir.YieldDate) AS LastYield
FROM InterestRateDetail d JOIN InterestRate ir ON ir.Id = d.InterestRateId
WHERE ir.ChartId = 7 GROUP BY d.Ccy ORDER BY MAX(ir.YieldDate) DESC;
```
Gerekce: CCS'in Pay bacagi USD/Chart7; bu ikili hic tanimli mi.

### S-05 — Bu islem icin batch daha once degerleme uretebilmis mi
```sql
SET NOCOUNT ON;
SELECT TOP (20) r.Id, r.TxnId, r.ValueDate, r.ReceiveTotalAmountNPV, r.PayTotalAmountNPV, r.StateId
FROM DerivativesRevaluation r WHERE r.TxnId IN (88167, 88164) ORDER BY r.Id DESC;
```
Gerekce: EOD batch de ayni egriyi kullaniyor; batch hangi tarihe kadar uretebilmis.

### S-05a — (S-05 HATA: Invalid column name 'ValueDate'/'StateId') kolon adlarini bul
```sql
SET NOCOUNT ON;
SELECT TOP (50) c.name, t.name AS TypeName
FROM sys.columns c JOIN sys.types t ON t.user_type_id = c.user_type_id
WHERE c.object_id = OBJECT_ID('DerivativesRevaluation') ORDER BY c.column_id;
```
Gerekce: TOP(50) gerekcesi — tablo genis, kolon adlarini tek seferde almak icin.

### S-06 — Batch bu islemler icin hangi tarihe kadar degerleme uretmis
```sql
SET NOCOUNT ON;
SELECT TOP (20) r.Id, r.TxnId, r.CalculationDate, r.ReceiveCurrency, r.ReceiveIndexChartId
FROM DerivativesRevaluation r WHERE r.TxnId IN (88167, 88164) ORDER BY r.Id DESC;
```

### S-07 — `InterestRate` ve `InterestRateDetail` kolon semasi (INSERT scripti icin)
```sql
SET NOCOUNT ON;
SELECT TOP (50) OBJECT_NAME(c.object_id) AS TableName, c.name, t.name AS TypeName, c.is_nullable, c.is_identity, c.max_length
FROM sys.columns c JOIN sys.types t ON t.user_type_id = c.user_type_id
WHERE c.object_id IN (OBJECT_ID('InterestRate'), OBJECT_ID('InterestRateDetail'))
ORDER BY OBJECT_NAME(c.object_id), c.column_id;
```
Gerekce: TOP(50) — iki tablonun tum kolonlari tek seferde; INSERT kolon listesi bunun uzerine kurulacak.

### S-08 — Chart 7'nin son iyi gununde hangi noktalar/oranlar var (sablon satirlar)
```sql
SET NOCOUNT ON;
SELECT TOP (50) ir.YieldDate, d.Ccy, d.PointId, p.Days AS PointDays, p.Code AS PointCode,
       d.PointDate, d.AskRate, d.BidRate, d.MidRate, d.Source
FROM InterestRateDetail d
JOIN InterestRate ir ON ir.Id = d.InterestRateId
JOIN Point p ON p.Id = d.PointId
WHERE ir.ChartId = 7 AND ir.YieldDate IN ('2026-09-09','2026-06-18')
ORDER BY ir.YieldDate DESC, d.Ccy, p.Days;
```
Gerekce: TOP(50) — insert scriptinin sablonu; chart 7'de kullanilan nokta kumesi ve oran buyuklukleri.

### S-08a — (S-08 HATA: Invalid column name 'Code') `Point` tablosu kolonlari
```sql
SET NOCOUNT ON;
SELECT TOP (20) c.name, t.name AS TypeName FROM sys.columns c
JOIN sys.types t ON t.user_type_id = c.user_type_id
WHERE c.object_id = OBJECT_ID('Point') ORDER BY c.column_id;
```

### S-08b — Chart 7 sablon satirlari (duzeltilmis)
```sql
SET NOCOUNT ON;
SELECT TOP (50) ir.YieldDate, d.Ccy, d.PointId, p.Days AS PointDays, p.PointCode,
       d.AskRate, d.BidRate, d.MidRate, d.Source
FROM InterestRateDetail d
JOIN InterestRate ir ON ir.Id = d.InterestRateId
JOIN Point p ON p.Id = d.PointId
WHERE ir.ChartId = 7 AND ir.YieldDate IN ('2026-09-09','2026-06-18')
ORDER BY ir.YieldDate DESC, d.Ccy, p.Days;
```

### S-09 — Chart 7 / 2026-09-09 (son iyi gun) detaylari + USD nokta kumesi
```sql
SET NOCOUNT ON;
SELECT TOP (20) ir.Id AS RateId, ir.YieldDate, ir.StateId, ir.StateMaker, ir.Description,
       d.Id AS DetailId, d.Ccy, d.PointId, d.PointDate, d.AskRate, d.BidRate, d.MidRate, d.Source, d.SymbolName
FROM InterestRate ir LEFT JOIN InterestRateDetail d ON d.InterestRateId = ir.Id
WHERE ir.ChartId = 7 AND ir.YieldDate = '2026-09-09' ORDER BY d.Id DESC;
```

### S-09a — (S-09 bos dondu) Id ile dogrudan
```sql
SET NOCOUNT ON;
SELECT TOP (20) d.Id, d.InterestRateId, d.Ccy, d.PointId, d.PointDate, d.AskRate, d.BidRate, d.MidRate, d.Source, d.SymbolName, d.LastUpdate
FROM InterestRateDetail d WHERE d.InterestRateId = 12770 ORDER BY d.Id DESC;
```

### S-09b — Celiski kontrolu: chart 7'nin en yeni basliklari ve gercek detay sayilari
```sql
SET NOCOUNT ON;
SELECT TOP (20) ir.Id, ir.ChartId, ir.YieldDate, ir.StateId,
       (SELECT COUNT(1) FROM InterestRateDetail d WHERE d.InterestRateId = ir.Id) AS DetailCount
FROM InterestRate ir WHERE ir.ChartId = 7 ORDER BY ir.Id DESC;
```

### S-10 — Chart 7 para birimi bazinda guncel durum (S-04 tekrari; ara durum degismis olabilir)
```sql
SET NOCOUNT ON;
SELECT TOP (20) d.Ccy, COUNT(DISTINCT d.PointId) AS PointCount, COUNT(d.Id) AS DetailCount, MAX(ir.YieldDate) AS LastYield
FROM InterestRateDetail d JOIN InterestRate ir ON ir.Id = d.InterestRateId
WHERE ir.ChartId = 7 GROUP BY d.Ccy ORDER BY MAX(ir.YieldDate) DESC;
```

### S-11 — 2026-09-15 basliginin (Id 13720) detay sablonu: PointDate/SymbolName semantigi
```sql
SET NOCOUNT ON;
SELECT TOP (20) d.Id, d.Ccy, d.PointId, p.Days, p.PointCode, d.PointDate, d.AskRate, d.BidRate, d.MidRate, d.Source, d.SymbolName, d.LastUpdate
FROM InterestRateDetail d JOIN Point p ON p.Id = d.PointId
WHERE d.InterestRateId = 13720 ORDER BY d.Id DESC;
```

### S-12 — Id uretimi: numarator tablosu var mi (Id identity degil)
```sql
SET NOCOUNT ON;
SELECT TOP (20) t.name AS TableName FROM sys.tables t
WHERE t.name LIKE '%Number%' OR t.name LIKE '%Sequence%' OR t.name LIKE '%Counter%'
ORDER BY t.name DESC;
```
Gerekce: `InterestRate.Id` identity degil; script Id uretecek, numarator tablosunu bozmamak gerek.

### S-13 — `DefNumberGen` InterestRate icin sayac tutuyor mu
```sql
SET NOCOUNT ON;
SELECT TOP (20) c.name FROM sys.columns c WHERE c.object_id = OBJECT_ID('DefNumberGen') ORDER BY c.column_id;
```

### S-13a — `DefNumberGen` satirlari: InterestRate / InterestRateDetail kayitli mi
```sql
SET NOCOUNT ON;
SELECT TOP (20) g.EntityColumnType, g.LastNumber, g.Definition, g.LastUpdateDate
FROM DefNumberGen g WHERE g.EntityColumnType LIKE '%Interest%' ORDER BY g.EntityColumnType DESC;
```

### S-14 — OptFX urun tanimlari (SubProduct listesi icin)
```sql
SET NOCOUNT ON;
SELECT TOP (20) p.Id, p.Code, p.Name, p.IsEnabled, p.[Order]
FROM ProductDefinition p ORDER BY p.Id DESC;
```
Gerekce: OptFX manuel reeskont ekraninda alt urun listesi; S-14 oncesinde `PrdProductDefinition`
denendi, `Invalid object name` hatasi alindi (OptFX'te tablo adi farkli).

### S-15 — OptFX'te gercekten tek urun tanimi mi var (state filtresi dahil)
```sql
SET NOCOUNT ON;
SELECT TOP (20) p.Id, p.Code, p.Name, p.MainProductCode, p.ExternalSubProductCode, p.IsEnabled, p.[Order]
FROM ProductDefinition p ORDER BY p.Id DESC;
```

### S-16 — OptFX `DefNumberGen` sayaclari: reeskont ters fisi `Id=990` uretti, neden
```sql
SET NOCOUNT ON;
SELECT TOP (20) g.EntityColumnType, g.LastNumber, g.Definition, g.LastUpdateDate
FROM DefNumberGen g ORDER BY g.EntityColumnType DESC;
```
**DB:** `NetTrexOptFX` @ 192.168.10.211 · `-U trusr -P '***'`
**Gerekce:** `executions` ucunda `AccountingEntryEntity ... key value '{Id: 990}' is already being
tracked` hatasi alindi. `NumberGeneratorDataManager` Id'yi `int.Parse($"{99}{x.Number}")` ile
kuruyor; yani **990 = prefix 99 + Number 0**. Gercek tablodaki Id'ler 992060 / 9910358 (= 99+2060,
99+10358). Yani `sp_GetNewNumbers` **0** dondurmus. Sayac satirlari (EntityColumnType 2 =
AccEntryMain_Id, 3 = AccEntry_Id) DB'de ne durumda, once onu gormek gerekiyor.

### S-17 — `sp_GetNewNumbers`'in govdesi: hangi kolon adiyla donuyor
```sql
SET NOCOUNT ON;
SELECT TOP (20) m.definition FROM sys.sql_modules m
WHERE m.object_id = OBJECT_ID('dbo.sp_GetNewNumbers');
```
**DB:** `NetTrexOptFX` @ 192.168.10.211 · `-U trusr -P '***'`
**Gerekce:** S-16'da sayaclar AccEntryMain_Id=125, AccEntry_Id=757 (son guncelleme 2026-08-26)
cikti; ama tablodaki gercek Id'ler 992060 / 9910358 yani Number 2060 / 10358. Uretilen Id ise 990
(= Number 0). Dapper'in `NewNumberEntity.Number` alanini dolduramadigi (kolon adi uyusmuyor)
hipotezini dogrulamak icin SP'nin dondurdugu kolon adi gerekiyor.

### S-18 — Gercek Id araligi ve `990` kaydi var mi
```sql
SET NOCOUNT ON;
SELECT TOP (20) m.Id, m.TxnId, m.Type, m.IsReverse, m.ReverseId, m.ValueDate, m.StateDate
FROM AccEntryMain m ORDER BY m.Id DESC;
```
**DB:** `NetTrexOptFX` @ 192.168.10.211 · `-U trusr -P '***'`
**Gerekce:** Uretilen Id 990; sayac ise 125 (=> beklenen 99126). Tablodaki gercek en buyuk Id'yi ve
990'in var olup olmadigini gormek, "sayac mi bayat yoksa Dapper kolon eslesmesi mi bozuk" ayrimini
kesinlestirir.

### S-19 — Sunucudaki OptFX veritabanlari (S-18 yanlis DB'ye bakmis olabilir)
```sql
SET NOCOUNT ON;
SELECT TOP (20) d.name, d.database_id, d.collation_name, d.create_date
FROM sys.databases d WHERE d.name LIKE '%OPTFX%' ORDER BY d.database_id DESC;
```
**DB:** `master` @ 192.168.10.211 · `-U trusr -P '***'`
**Gerekce:** S-18'de `NetTrexOptFX`.AccEntryMain max Id = 99125 ve son kayit 2026-08-26; oysa hata
veren istek TxnId=991227, AccEntryMain 992060/992065/992067, 2026-09-17. Yani API baska bir
veritabanina bagli. appsettings'te iki MSSQL satiri var (`NetTrexOptFX`/trusr ve `NetTrexOPTFX`/sa).

### S-20 — DOGRU DB (`NetTrexOptFX-investmentbank`): sayaclar + gercek Id araligi + `990` var mi
```sql
SET NOCOUNT ON;
SELECT TOP (20) g.EntityColumnType, g.LastNumber, g.Definition, g.LastUpdateDate
FROM DefNumberGen g ORDER BY g.EntityColumnType DESC;

SELECT TOP (20) m.Id, m.TxnId, m.Type, m.IsReverse, m.ReverseId, m.ValueDate, m.StateDate
FROM AccEntryMain m ORDER BY m.Id DESC;
```
**DB:** `NetTrexOptFX-investmentbank` @ 192.168.10.211 · `-U trusr -P '***'`
**Gerekce:** S-18/S-19'da `NetTrexOPTFX`'in en buyuk Id'si 99125 ve son kayit 2026-08-26 cikti; hata
veren istek ise 992060+ ve 2026-09-17. launchSettings'te ucuncu profil (`Api:UAT-Investment`)
`NetTrexOptFX-investmentbank` DB'sini kullaniyor — API'nin gercekte bagli oldugu DB bu olmali.

### S-21 — Manuel Reeskont listeleme yavaşlığı (3006 satır ~1 dk): ilgili tabloların index'leri + satır sayıları
```sql
SET NOCOUNT ON;
SELECT t.name AS tbl, i.name AS idx, i.type_desc,
       STUFF((SELECT ',' + c.name FROM sys.index_columns ic JOIN sys.columns c ON c.object_id=ic.object_id AND c.column_id=ic.column_id
              WHERE ic.object_id=i.object_id AND ic.index_id=i.index_id AND ic.is_included_column=0 ORDER BY ic.key_ordinal FOR XML PATH('')),1,1,'') AS keys,
       STUFF((SELECT ',' + c.name FROM sys.index_columns ic JOIN sys.columns c ON c.object_id=ic.object_id AND c.column_id=ic.column_id
              WHERE ic.object_id=i.object_id AND ic.index_id=i.index_id AND ic.is_included_column=1 FOR XML PATH('')),1,1,'') AS incl
FROM sys.indexes i JOIN sys.tables t ON t.object_id=i.object_id
WHERE t.name IN ('TxnMM','txnMMDetail','accEntryMain','txnMmDailyCalculation','cusCustomer','defTxnType','TxnLoan','LoanRevaluation') AND i.type>0
ORDER BY t.name, i.index_id;
SELECT t.name, SUM(p.rows) AS rows FROM sys.partitions p JOIN sys.tables t ON t.object_id=p.object_id
WHERE p.index_id IN (0,1) AND t.name IN ('TxnMM','txnMMDetail','accEntryMain','txnMmDailyCalculation','cusCustomer','TxnLoan','LoanRevaluation')
GROUP BY t.name ORDER BY t.name;
```
**DB:** `NetTrexMM_37_28092026_MR` @ 192.168.10.211 · `-U trusr -P '***'`
**Gerekce:** Listeleme sorgusu satır başına ~25 korele alt sorgu (AccEntryMain×4, DailyCalculation×6, Detail×4, cusCustomer×4)
içeriyor ve 5 kez (1 count + 3 statü count + items) koşuyor. FK kolonlarında (TxnId) index yoksa her alt sorgu tablo taraması
olur → 1 dk'yı açıklar. Index var mı, tablolar ne büyüklükte görmek istiyorum.

### S-22 — Listeleme sorgusunun ölçümü (EF harness, gerçek `TransactionDataManager.GetRediscountEligibleTransactionsAsync`)
Kod: scratchpad `mrperf/Program.cs` — EfDbContext + UseSqlServer, repository'ler `ctx.Set<T>()` (salt okuma, AsNoTracking,
SaveChanges YOK). Parametre: executionDate=2026-09-27, subProduct=null, status=null, skip=0, take=int.MaxValue. 2 kez koşar.
EF'in ürettiği SELECT'ler (1 COUNT + 3 statü COUNT + items SELECT) ham olarak `02-ciktilar.md`'ye yazılacak.
**DB:** `NetTrexMM_37_28092026_MR` @ 192.168.10.211 · `-U trusr -P '***'`
**Gerekce:** Ekranda 3006 satır ~1 dk. Sürenin DB'de mi (hangi sorguda) yoksa UI/serileştirmede mi geçtiğini ölçmek.

### S-23 — S-22 tekrar, set-based yeniden yazım sonrası (aynı harness, aynı parametre)
Yeni akış: scopeIds SELECT · reeskont fişleri SELECT (SelectMany + ters fiş PK lookup) · sayfa satırları SELECT
(cusCustomer/defTxnType LEFT JOIN) · txnMMDetail SELECT · txnMmDailyCalculation SUM GROUP BY · günlük valuation SELECT.
Hepsi salt okuma. Sonuç sayıları S-22 ile birebir karşılaştırılacak (3005 / NR 3005).
**DB:** `NetTrexMM_37_28092026_MR` @ 192.168.10.211 · `-U trusr -P '***'`
**Gerekce:** Performans kazancını ve sonuç eşitliğini doğrulamak.

### S-24 — Reeskont fişi bulunan tarihler (eski/yeni sorgu eşitlik testi için statü karışık bir gün seçmek)
```sql
SET NOCOUNT ON;
SELECT TOP (20) CAST(ValueDate AS date) AS ValueDate, ProductCode, IsReverse, COUNT(*) AS Adet
FROM accEntryMain WHERE Type = 5
GROUP BY CAST(ValueDate AS date), ProductCode, IsReverse
ORDER BY ValueDate DESC;
```
**DB:** `NetTrexMM_37_28092026_MR` @ 192.168.10.211 · `-U trusr -P '***'`
**Gerekce:** 2026-09-27'de tüm satırlar NotRediscounted; NotReversed/Rediscounted dallarını da eski sorguyla karşılaştırmak için
reeskont fişi olan bir tarih lazım. (Revaluation enum değeri koddan doğrulanacak; 5 değilse sorgu tekrar edilir.)

> S-24 ÇALIŞTIRILMADI: koddan `AccountingType.Revaluation = 2` doğrulandı (5 = Manuel). Yerine S-25.

### S-25 — S-24'ün düzeltilmiş hali (Type = 2)
```sql
SET NOCOUNT ON;
SELECT TOP (20) CAST(ValueDate AS date) AS ValueDate, ProductCode, IsReverse, COUNT(*) AS Adet
FROM accEntryMain WHERE Type = 2
GROUP BY CAST(ValueDate AS date), ProductCode, IsReverse
ORDER BY ValueDate DESC;
```
**DB:** `NetTrexMM_37_28092026_MR` @ 192.168.10.211 · `-U trusr -P '***'`
**Gerekce:** S-24 ile aynı.

### S-26 — Eski (git HEAD) vs yeni listeleme sorgusu eşitlik testi (MM + IL), salt okuma
Harness `mrperf/Program.cs`: HEAD'deki `TransactionDataManager` / `TransactionLoanDataManager` kopyası (MrPerf.Old*) ile yeni kod
aynı parametrelerle çağrılır, sonuç JSON'ları birebir karşılaştırılır. Tarihler 2026-09-22/23/27/28; statü all/1/3/4; sayfalama
skip=10 take=25 ve skip=3000 take=50. EF'in ürettiği SELECT'ler S-22/S-23 ile aynı biçimde (eski: korele alt sorgular; yeni:
6 düz SELECT). Yazma YOK.
**DB:** `NetTrexMM_37_28092026_MR` @ 192.168.10.211 · `-U trusr -P '***'`
**Gerekce:** Performans değişikliğinin ekrana giden veriyi (statü, sayımlar, tüm kolonlar, sıra) değiştirmediğini kanıtlamak.

### S-27 — S-26'daki 4 DIFF vakası, sayı ölçeği normalize edilerek tekrar (salt okuma, aynı harness)
Vakalar: MM 2026-09-28 all skip10/take25 · MM 2026-09-28 st1 skip3000/take50 · MM 2026-09-28 all · MM 2026-09-27 all.
**DB:** `NetTrexMM_37_28092026_MR` @ 192.168.10.211 · `-U trusr -P '***'`
**Gerekce:** Farkın yalnız decimal ölçeği (0.000… vs 0) olduğunu, başka alan farkı olmadığını kanıtlamak.

### S-28 — FX: yük testi verisi hangi DB'de + listeleme tablolarının index'leri / satır sayıları
```sql
SET NOCOUNT ON;
SELECT (SELECT COUNT(*) FROM txnFX WHERE LogicalReference LIKE 'TFXFWYT%') AS YukTestiAdet, (SELECT COUNT(*) FROM txnFX) AS TxnFxToplam;
SELECT t.name AS tbl, i.name AS idx, i.type_desc,
       STUFF((SELECT ',' + c.name FROM sys.index_columns ic JOIN sys.columns c ON c.object_id=ic.object_id AND c.column_id=ic.column_id
              WHERE ic.object_id=i.object_id AND ic.index_id=i.index_id AND ic.is_included_column=0 ORDER BY ic.key_ordinal FOR XML PATH('')),1,1,'') AS keys
FROM sys.indexes i JOIN sys.tables t ON t.object_id=i.object_id
WHERE (t.name IN ('txnFX','AccEntryMain','CusCustomer','prdProductInstrument') OR t.name LIKE '%Valuation%') AND i.type>0
ORDER BY t.name, i.index_id;
SELECT t.name, SUM(p.rows) AS rows FROM sys.partitions p JOIN sys.tables t ON t.object_id=p.object_id
WHERE p.index_id IN (0,1) AND (t.name IN ('txnFX','AccEntryMain','CusCustomer') OR t.name LIKE '%Valuation%')
GROUP BY t.name ORDER BY t.name;
```
**DB:** `NetTrexFX_133` @ 192.168.10.211 · `-U trusr -P '***'` (FX Web.API launchSettings `Api:Staging-Investment`)
**Gerekce:** FX listeleme sorgusu da satır başına korele alt sorgu içeriyor (reeskont fişi, valuation OUTER APPLY, müşteri, instrument,
ters fiş). Yük testi verisi bu DB'de ise MM'deki gibi ölçüp düzeltmek; FK index'leri var mı görmek.

### S-29 — FX yük testi verisinin DB'si: sunucudaki FX veritabanları (en yeni önce)
```sql
SET NOCOUNT ON;
SELECT TOP (20) name, create_date FROM sys.databases WHERE name LIKE '%FX%' ORDER BY create_date DESC;
```
**DB:** `master` @ 192.168.10.211 · `-U trusr -P '***'`
**Gerekce:** S-28'de NetTrexFX_133 boş çıktı; MM'deki gibi (NetTrexMM_37_28092026_MR) güncel bir kopya olmalı.

### S-30 — FX eşitlik testi için veri içeren DB: aday DB'lerde TxnFX / AccEntryMain(Type=2) / TxnFxValuation sayıları
Her DB için ayrı ayrı (sqlcmd -d <DB>):
```sql
SET NOCOUNT ON;
SELECT DB_NAME() AS Db, (SELECT COUNT(*) FROM TxnFX) AS TxnFx,
       (SELECT COUNT(*) FROM TxnFX WHERE LogicalReference LIKE 'TFXFWYT%') AS YukTesti,
       (SELECT COUNT(*) FROM AccEntryMain WHERE Type = 2) AS Reeskont,
       (SELECT COUNT(*) FROM TxnFxValuation) AS FxValuation,
       (SELECT MAX(TradeDate) FROM TxnFX) AS SonTrade;
```
DB'ler: NetTrexFX, NetTrexFX_Dev, NetTrexFX_P_Test, NetTrexFX_136, NetTrexFX_136_Dev, NetTrexFX_136_Test
**DB:** yukarıdakiler @ 192.168.10.211 · `-U trusr -P '***'`
**Gerekce:** FX listeleme düzeltmesinin eski/yeni sonuç eşitliğini gerçek veride sınamak; hangi DB'de reeskontlu FX verisi var.

### S-31 — NetTrexFX_Dev: reeskont fişi olan günler (FX eşitlik testi tarihleri)
```sql
SET NOCOUNT ON;
SELECT TOP (20) CAST(ValueDate AS date) AS ValueDate, ProductCode, IsReverse, COUNT(*) AS Adet
FROM AccEntryMain WHERE Type = 2
GROUP BY CAST(ValueDate AS date), ProductCode, IsReverse
ORDER BY ValueDate DESC;
```
**DB:** `NetTrexFX_Dev` @ 192.168.10.211 · `-U trusr -P '***'`
**Gerekce:** Eski/yeni FX listeleme karşılaştırmasında statüleri karışık günler seçmek.

### S-32 — MM: işlem başına faiz (IsPrincipalAmount=0) detay satırı sayısı dağılımı
```sql
SET NOCOUNT ON;
SELECT TOP (20) x.FaizSatiri, COUNT(*) AS IslemAdedi
FROM (SELECT TxnId, COUNT(*) AS FaizSatiri FROM TxnMMDetail WHERE IsPrincipalAmount = 0 GROUP BY TxnId) x
GROUP BY x.FaizSatiri ORDER BY x.FaizSatiri DESC;
```
**DB:** `NetTrexMM_37_28092026_MR` @ 192.168.10.211 · `-U trusr -P '***'`
**Gerekce:** Kullanıcı "MM şu an single çalışıyor" dedi. Listelemedeki "ilk faiz detayı" seçimi tek satır varsa sorun değil; birden fazla
faiz satırlı işlem var mı doğrulamak.

### S-33 — Birden fazla faiz satırlı MM işlemlerinin detayları (dönemler gerçekten farklı mı)
```sql
SET NOCOUNT ON; SELECT TOP (20) d.TxnId, d.Id, CAST(d.PeriodStartDate AS date) AS PStart, CAST(d.PeriodEndDate AS date) AS PEnd, d.InterestRate, d.Amount, t.LogicalReference, t.StateId, CAST(t.MaturityDate AS date) AS Maturity FROM TxnMMDetail d JOIN TxnMM t ON t.Id = d.TxnId WHERE d.IsPrincipalAmount = 0 AND d.TxnId IN (SELECT TxnId FROM TxnMMDetail WHERE IsPrincipalAmount = 0 GROUP BY TxnId HAVING COUNT(*) > 1) ORDER BY d.TxnId DESC, d.Id;
```
**DB:** `NetTrexMM_37_28092026_MR` @ 192.168.10.211 · `-U trusr -P '***'`
**Gerekce:** S-32'de 31 işlem >1 faiz satırlı. Rollover/faiz değişimi mi, gerçek çok dönem mi; listelemede ilk satırın seçilmesi yanlış dönem gösterir mi.

### S-34 — Çok faiz satırlı MM işlemlerinin StateId dağılımı (listeleme kapsamı 26/18)
```sql
SET NOCOUNT ON; SELECT t.StateId, COUNT(DISTINCT d.TxnId) AS CokFaizSatirliIslem FROM TxnMMDetail d JOIN TxnMM t ON t.Id = d.TxnId WHERE d.IsPrincipalAmount = 0 AND d.TxnId IN (SELECT TxnId FROM TxnMMDetail WHERE IsPrincipalAmount = 0 GROUP BY TxnId HAVING COUNT(*) > 1) GROUP BY t.StateId ORDER BY t.StateId;
```
**DB:** `NetTrexMM_37_28092026_MR` @ 192.168.10.211 · `-U trusr -P '***'`
**Gerekce:** S-33'teki örnekler StateId 22 (silinmiş). Onaylı durumda çok dönemli MM işlemi var mı.

### S-35 — FX eski (git HEAD) vs yeni listeleme eşitlik testi (harness `mrperffx`), salt okuma
Tarihler: 2026-02-04, 2026-02-05, 2025-09-01, 2025-08-28, 2024-10-18, 2024-05-09, 2026-08-20 · includeSpot false/true · statü all/1/3/4 ·
sayfalama all ve skip2/take5. Eski: kaynak başına 3 COUNT + korele items; yeni: kaynak başına Id + reeskont SELECT, sayfa için
satır (cusCustomer/instrument LEFT JOIN) + valuation SELECT. Yazma YOK.
**DB:** `NetTrexFX_Dev` @ 192.168.10.211 · `-U trusr -P '***'`
**Gerekce:** FX listeleme optimizasyonunun sonucu (statü, sayımlar, tüm alanlar, sıra) değiştirmediğini kanıtlamak.

### S-36 — DerivSwp (NetTrexDerivSWP) ve OptionsFX (NetTrexOPTFX): reeskont fişi olan son günler (eşitlik testi tarihleri)
```sql
SET NOCOUNT ON; SELECT TOP (8) CAST(a.ValueDate AS date) AS ValueDate, a.IsReverse, COUNT(*) AS Adet FROM AccEntryMain a WHERE a.Type = 2 GROUP BY CAST(a.ValueDate AS date), a.IsReverse ORDER BY ValueDate DESC;
```
Her iki DB'de ayrı ayrı; OptionsFX'te tablo adı farklıysa hata çıktısı da kaydedilir.
**DB:** `NetTrexDerivSWP`, `NetTrexOPTFX` @ 192.168.10.211 · `-U trusr -P '***'`
**Gerekce:** DerivSwp/OptionsFX listeleme optimizasyonunu gerçek veride eski sorguyla karşılaştırmak.

### S-37 — DerivSwp eski (git HEAD) vs yeni listeleme eşitlik testi (harness `mrperfderiv`), salt okuma
Tarihler 2026-09-09/15/16/17/22/28 · statü all/1/3/4 · sayfalama all ve skip2/take5. Yazma YOK.
**DB:** `NetTrexDerivSWP` @ 192.168.10.211 · `-U trusr -P '***'`
**Gerekce:** DerivSwp listeleme optimizasyonunun sonucu değiştirmediğini kanıtlamak.

### S-38 — OptionsFX eski (git HEAD) vs yeni listeleme eşitlik testi (harness `mrperfopt`), salt okuma
Tarihler 2026-09-24/25/26/28 · statü all/1/3/4 · sayfalama all ve skip2/take5. Yazma YOK.
**DB:** `NetTrexOPTFX` @ 192.168.10.211 · `-U trusr -P '***'`
**Gerekce:** OptionsFX listeleme optimizasyonunun sonucu değiştirmediğini kanıtlamak.

### S-39 — Daha fazla veri içeren OptionsFX DB'si (eşitlik testini güçlendirmek)
```sql
SET NOCOUNT ON; SELECT DB_NAME() AS Db, (SELECT COUNT(*) FROM TxnTransaction) AS Txn, (SELECT COUNT(*) FROM AccEntryMain WHERE Type = 2) AS Reeskont, (SELECT MAX(CAST(ValueDate AS date)) FROM AccEntryMain WHERE Type = 2) AS SonReeskont;
```
DB'ler: NetTrexOPTFX_134, NetTrexOptFx_136, NetTrexOptFx_136_Test, NetTrexOptFX_135, NetTrexOPTFX_Dev, NetTrexOptFX_UAT
**DB:** yukarıdakiler @ 192.168.10.211 · `-U trusr -P '***'`
**Gerekce:** S-38'de NetTrexOPTFX'te günde en fazla 1 satır vardı; daha kalabalık veride tekrar sınamak.

### S-40 — S-38 harness'ı NetTrexOptFx_136 üzerinde (100 işlem; reeskont yok → çok satır + valuation eşleşmesi sınanır)
Tarihler 2026-03-01, 2026-06-01, 2026-08-11, 2026-09-01, 2026-09-28 · statü all/1/3/4 · sayfalama. Salt okuma.
**DB:** `NetTrexOptFx_136` @ 192.168.10.211 · `-U trusr -P '***'`
**Gerekce:** OptionsFX eşitliğini kalabalık veride doğrulamak.

### S-41 — Ayna tespiti: reeskont (Type=2) main'lerinde bacak ReverseId dağılımı
```sql
SET NOCOUNT ON; SELECT m.IsReverse, CASE WHEN EXISTS (SELECT 1 FROM AccEntry e WHERE e.AccEntryMainId = m.Id AND e.ReverseId <> 0) THEN 1 ELSE 0 END AS BacaktaReverseIdVar, COUNT(*) AS Adet FROM AccEntryMain m WHERE m.Type = 2 GROUP BY m.IsReverse, CASE WHEN EXISTS (SELECT 1 FROM AccEntry e WHERE e.AccEntryMainId = m.Id AND e.ReverseId <> 0) THEN 1 ELSE 0 END ORDER BY m.IsReverse;
```
**DB:** `NetTrexMM_37_28092026_MR` @ 192.168.10.211 · `-U trusr -P '***'`
**Gerekce:** Ayna fiş (BuildMirror) bacaklarına ReverseId = kaynak bacak Id yazıyor; normal reeskont bacaklarında 0 mı? Statü hesabında 'ayna' işareti buna dayanacak.

### S-42 — S-41 düzeltilmiş (GROUP BY türetilmiş tabloda)
```sql
SET NOCOUNT ON; SELECT x.IsReverse, x.BacaktaReverseIdVar, COUNT(*) AS Adet FROM (SELECT m.IsReverse, CASE WHEN EXISTS (SELECT 1 FROM AccEntry e WHERE e.AccEntryMainId = m.Id AND e.ReverseId <> 0) THEN 1 ELSE 0 END AS BacaktaReverseIdVar FROM AccEntryMain m WHERE m.Type = 2) x GROUP BY x.IsReverse, x.BacaktaReverseIdVar ORDER BY x.IsReverse, x.BacaktaReverseIdVar;
```
**DB:** `NetTrexMM_37_28092026_MR` · **Gerekce:** S-41 Msg 144 verdi.

### S-DS-01 — DerivSwp ayna işareti: reeskont (Type=2) main'lerinde IsReverse × main ReverseId dolu mu × bacakta ReverseId dolu mu dağılımı
```sql
SET NOCOUNT ON; SELECT x.IsReverse, x.MainReversed, x.LegHasReverseId, COUNT(*) AS Adet FROM (SELECT m.IsReverse, CASE WHEN m.ReverseId <> 0 THEN 1 ELSE 0 END AS MainReversed, CASE WHEN EXISTS (SELECT 1 FROM AccEntry e WHERE e.AccEntryMainId = m.Id AND e.ReverseId IS NOT NULL AND e.ReverseId <> 0) THEN 1 ELSE 0 END AS LegHasReverseId FROM AccEntryMain m WHERE m.Type = 2) x GROUP BY x.IsReverse, x.MainReversed, x.LegHasReverseId ORDER BY x.IsReverse, x.MainReversed, x.LegHasReverseId;
```
**DB:** `NetTrexDerivSWP` @ 192.168.10.211 · `-U trusr -P '***'`
**Gerekce:** DerivSwp AccountingReverseService kaynak bacaklara da ReverseId yazıyor (accEntryEntities[i].ReverseId = ters bacak). Terslenen normal reeskontun bacağında ReverseId dolu mu? Doluysa MM'deki "bacakta ReverseId != 0 → ayna" işareti DerivSwp'de kullanılamaz.

### S-43 — MM + IL eski (git HEAD) vs yeni (10 madde sonrası) listeleme eşitliği, salt okuma (harness `mrperf`)
Yeni kod ek olarak: günün reeskont fişlerinin bacaklarından ayna tespiti (SELECT DISTINCT AccEntryMainId FROM AccEntry
WHERE ReverseId IS NOT NULL AND ReverseId <> 0 ... kapsam join'i). Karşılaştırmada yeni alanlar (NeutralizationPending, IsMirror)
yok sayılır. Ayna içeren günlerde statü sayımları BİLİNÇLİ olarak farklı olabilir (tersi olan ayna → gün NotRediscounted).
**DB:** `NetTrexMM_37_28092026_MR` @ 192.168.10.211 · `-U trusr -P '***'`
**Gerekce:** 10 madde değişikliğinin ayna dışı satırlarda listelemeyi değiştirmediğini, ayna satırlarında ise beklenen farkı verdiğini görmek.

### S-DS-02 — DerivSwp: bacağında ReverseId olan ters-olmayan reeskontlar (ayna adayı) — bacak ReverseId'nin gösterdiği bacağın main'i ters mi, aynı gün/aynı işlem mi
```sql
SET NOCOUNT ON; SELECT TOP (20) m.Id, m.TxnId, CAST(m.ValueDate AS date) AS VD, m.ReverseId, e.Id AS LegId, e.ReverseId AS LegRev, s.AccEntryMainId AS SrcMain, sm.IsReverse AS SrcIsRev, sm.TxnId AS SrcTxn, CAST(sm.ValueDate AS date) AS SrcVD, sm.ReverseId AS SrcRev, CAST(r.ValueDate AS date) AS SrcRevVD, CAST(mr.ValueDate AS date) AS MirrorRevVD FROM AccEntryMain m JOIN AccEntry e ON e.AccEntryMainId = m.Id AND e.ReverseId IS NOT NULL AND e.ReverseId <> 0 LEFT JOIN AccEntry s ON s.Id = e.ReverseId LEFT JOIN AccEntryMain sm ON sm.Id = s.AccEntryMainId LEFT JOIN AccEntryMain r ON r.Id = sm.ReverseId LEFT JOIN AccEntryMain mr ON mr.Id = m.ReverseId WHERE m.Type = 2 AND m.IsReverse = 0 ORDER BY m.Id DESC, e.Id DESC;
```
**DB:** `NetTrexDerivSWP` @ 192.168.10.211 · `-U trusr -P '***'`
**Gerekce:** S-DS-01'deki 8 adayın gerçekten ayna olduğunu (bacak → nötrlenen kaynak reeskontun bacağı, kaynak ters değil, aynı işlem/gün) ve kaynağın ters fiş valörünün DB'den bulunabildiğini doğrulamak.

### S-OF-01 — OptionsFX ayna işareti: reeskont (Type=2) main'lerinde IsReverse × main ReverseId dolu mu × bacakta ReverseId dolu mu dağılımı
```sql
SET NOCOUNT ON; SELECT x.IsReverse, x.MainReversed, x.LegHasReverseId, COUNT(*) AS Adet FROM (SELECT m.IsReverse, CASE WHEN m.ReverseId <> 0 THEN 1 ELSE 0 END AS MainReversed, CASE WHEN EXISTS (SELECT 1 FROM AccEntry e WHERE e.AccEntryMainId = m.Id AND e.ReverseId IS NOT NULL AND e.ReverseId <> 0) THEN 1 ELSE 0 END AS LegHasReverseId FROM AccEntryMain m WHERE m.Type = 2) x GROUP BY x.IsReverse, x.MainReversed, x.LegHasReverseId ORDER BY x.IsReverse, x.MainReversed, x.LegHasReverseId;
```
**DB:** `NetTrexOPTFX` @ 192.168.10.211 · `-U trusr -P '***'`
**Gerekce:** OptionsFX BuildMirror ayna bacaklarına ReverseId = kaynak bacak Id yazıyor; AccountingReverseReverseFactory yalnız TERS bacaklara (IsReverse=1) yazıyor. Ters olmayan normal reeskont bacaklarında ReverseId boş mu? Boşsa "bacakta ReverseId != 0 → ayna" işareti OptionsFX'te kullanılabilir.

### S-FX-01 — FX ayna (DoForward) işareti: reeskont (Type=2) main'lerinde IsReverse × açıklama öneki (İptal/Cancellation · Ters/Reverse · diğer) × bacakta ReverseId dolu mu dağılımı
```sql
SET NOCOUNT ON; SELECT x.IsReverse, x.DescKind, x.LegHasReverseId, COUNT(*) AS Adet FROM (SELECT m.IsReverse, CASE WHEN m.Description LIKE N'İptal Fiş:%' OR m.Description LIKE N'Cancellation:%' THEN 'MIRROR' WHEN m.Description LIKE N'Ters Fiş:%' OR m.Description LIKE N'Reverse:%' THEN 'REVERSE' ELSE 'OTHER' END AS DescKind, CASE WHEN EXISTS (SELECT 1 FROM AccEntry e WHERE e.AccEntryMainId = m.Id AND e.ReverseId IS NOT NULL AND e.ReverseId <> 0) THEN 1 ELSE 0 END AS LegHasReverseId FROM AccEntryMain m WHERE m.Type = 2) x GROUP BY x.IsReverse, x.DescKind, x.LegHasReverseId ORDER BY x.IsReverse, x.DescKind, x.LegHasReverseId;
```
**DB:** `NetTrexFX_Dev` @ 192.168.10.211 · `-U trusr -P '***'`
**Gerekce:** FX'te ayna fiş RevaluationReverseOperation.Forward ile kesiliyor: ters fişin klonu, IsReverse=0, ReverseId=0, bacak ReverseId=0 (MM'deki bacak işareti YOK), açıklama "Ters Fiş: " → "İptal Fiş: " (TR) / "Reverse: " → "Cancellation: ". Gerçek veride bu önek yalnız ters-olmayan reeskontlarda mı görülüyor, normal reeskontlarda hiç yok mu?

### S-FX-02 — FX: ters-olmayan reeskontlarda gevşek arama (ptal / Cancel / Forward izleri) + aynı işlem·aynı gün birden fazla ters-olmayan reeskont olan (Regenerate izi) örnekler
```sql
SET NOCOUNT ON; SELECT TOP (20) m.Id, m.TxnId, CAST(m.ValueDate AS date) AS VD, m.ReverseId, m.StateId, m.ProductCode, LEFT(m.Description, 80) AS Descr FROM AccEntryMain m WHERE m.Type = 2 AND m.IsReverse = 0 AND (m.Description LIKE N'%ptal%' OR m.Description LIKE N'%Cancel%' OR EXISTS (SELECT 1 FROM AccEntryMain o WHERE o.Type = 2 AND o.IsReverse = 0 AND o.TxnId = m.TxnId AND o.ValueDate = m.ValueDate AND o.Id <> m.Id)) ORDER BY m.Id DESC;
```
**DB:** `NetTrexFX_Dev` @ 192.168.10.211 · `-U trusr -P '***'`
**Gerekce:** S-FX-01 ayna öneki bulamadı. Önek farklı mı (encoding/ülke), yoksa gün içinde birden fazla reeskont (Regenerate) hiç oluşmamış mı?

### S-FX-03 — FX: tüm reeskont (Type=2) fişlerinde "ptal" / "Cancel" geçen açıklama sayısı (IsReverse kırılımı)
```sql
SET NOCOUNT ON; SELECT m.IsReverse, SUM(CASE WHEN m.Description LIKE N'%ptal%' THEN 1 ELSE 0 END) AS Iptal, SUM(CASE WHEN m.Description LIKE N'%Cancel%' THEN 1 ELSE 0 END) AS Cancel, COUNT(*) AS Toplam FROM AccEntryMain m WHERE m.Type = 2 GROUP BY m.IsReverse ORDER BY m.IsReverse;
```
**DB:** `NetTrexFX_Dev` @ 192.168.10.211 · `-U trusr -P '***'`
**Gerekce:** Ayna açıklama işaretinin gerçek veride hiç oluşup oluşmadığını satır çekmeden saymak.

### S-FX-04 — FX: reeskont (Type=2, ters olmayan) fişlerinin ProductCode dağılımı
```sql
SET NOCOUNT ON; SELECT TOP (20) ISNULL(m.ProductCode, '<NULL>') AS ProductCode, COUNT(*) AS Adet FROM AccEntryMain m WHERE m.Type = 2 AND m.IsReverse = 0 GROUP BY m.ProductCode ORDER BY Adet DESC;
```
**DB:** `NetTrexFX_Dev` @ 192.168.10.211 · `-U trusr -P '***'`
**Gerekce:** Execute'taki fiş okuması (GetRevaluationByValueDateAsync) yalnız TxnId ile arıyor; kaynaklar arası TxnId çakışmasında başka alt ürünün fişini okuyabilir. Listeleme native kaynaklarda ProductCode (FX/SWAPFX/PM/SWAPPM veya NULL) ile süzüyor; External fişlerin ProductCode'u ne?

### S-44 — S-43 tam liste vakası (MM 2026-09-28 all), EF komut süreleri loglanarak 2 kez (salt okuma)
**DB:** `NetTrexMM_37_28092026_MR` · **Gerekce:** Yeni sürede 11,7 sn — hangi SELECT (ayna tespiti?) yavaş.

### S-45 — Madde 1/2/3/5 geri alındıktan sonra MM tam liste (2026-09-28 all) süre ölçümü, 2 koşu, EF komut süreleri (salt okuma)
**DB:** `NetTrexMM_37_28092026_MR` · **Gerekce:** Search performansı geri geldi mi; valuation sorgularındaki 6 sn'nin kaynağı.

### S-46 — S-43 vaka seti, geri alma sonrası (eski HEAD vs yeni), loglama kapalı, salt okuma
**DB:** `NetTrexMM_37_28092026_MR` · **Gerekce:** Kalan değişikliklerin (IL faiz oranı T'yi kapsayan dönemden, filtre temizliği) listelemeyi başka yerde değiştirmediğini ve Search süresini doğrulamak.
