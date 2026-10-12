# SQL Log — swap-mm-rapor — Sorgular

> Konu: Swap & Money Market Raporu (AD-8945) — MM / FX / Common.UI. Analiz: `.ai-agent/swap-mm-rapor/01-analiz.md`

Özet: **Sorgu: 4 · Yazma: 0**

---

## #1 — MM faiz oranı birimi (TxnMMDetail.InterestRate)

**Amaç:** Rapordaki "Getiri Oranı" kolonu yüzde (41.75) mı oran (0.4175) mı taşıyor — UI formatı (`%` ekleme / ×100) buna bağlı.

```sql
SET NOCOUNT ON;
SELECT TOP (20) Id, TxnMmId, IsPrincipalAmount, InterestRate, Amount
FROM txnMMDetail
WHERE IsPrincipalAmount = 0
ORDER BY Id DESC;
```

DB: `NetTrexMM` · Server: `tcp:192.168.10.211,1433` · User: `trusr` · Pass: `***` (kaynak: `NetTrex.MM/Code/docker-compose.override.yml:24`)

---

## #2 — Interbank Loan faiz oranı birimi (TxnCashFlow.Rate, faiz akışı)

**Amaç:** Loan tarafında da aynı birim mi — iki ürün aynı kolon setini kullanacak.

```sql
SET NOCOUNT ON;
SELECT TOP (20) Id, TxnId, FlowTypeId, Rate, CashFlowAmount, Days
FROM TxnCashFlow
WHERE FlowTypeId = 2
ORDER BY Id DESC;
```

DB: `NetTrexMM` · aynı bağlantı

---

## #3 — FX Swap bacak yapısı (txnFXSwap)

**Amaç:** Near/Far bacak eşleşmesi (`PkgNo` + `InstrumentId` 1068/1069), kur alanı (`DealRateNet`) ve tutar alanlarının gerçek veride beklendiği gibi dolu olduğunu doğrulamak — gruplama ve oran hesabı buna dayanıyor.

```sql
SET NOCOUNT ON;
SELECT TOP (20) Id, PkgNo, InstrumentId, CcyPair, BuyCcy, BuyAmount, SellCcy, SellAmount, DealRateNet, ValueDate, TradeDate, StateId
FROM txnFXSwap
ORDER BY Id DESC;
```

DB: `NetTrexFX_Dev` · Server: `tcp:192.168.10.211,1433` · User: `trusr` · Pass: `***` (kaynak: `NetTrex.Fx/Code/docker-compose.override.yml:17`)

---

## #4 — Treasy.Common.UI menü ağacı (FrameworkMenu)

**Amaç:** Vade Raporu menü kaydının hangi üst menünün altına gireceğini gerçek ağaçtan seçmek (kullanıcı talebi: "menü tablosuna select at, en mantıklı yere konumlandır"). `TOP (50)`: ağaç tek sorguda görünsün diye — 20 satır Common.UI ağacının tamamını göstermeyebilir.

```sql
SET NOCOUNT ON;
SELECT TOP (50) Id, ApplicationName, MenuKey, Description, MenuType, Value, ParentId, ItemOrderId, ModuleName, IsActive
FROM dbo.FrameworkMenu
WHERE ApplicationName = 'Treasy.Common.UI' OR MenuKey LIKE '%Report%' OR MenuKey LIKE '%Rediscount%'
ORDER BY Id DESC;
```

DB: `NetTrexCommon` · Server: `tcp:192.168.10.211,1433` · User: `trusr` · Pass: `***` (kaynak: `NetTrex.Common/Code/docker-compose.override.yml`)

---

# Oturum 2026-10-01 — ekran alanlarının gerçek veriyle testi (kullanıcı: `USE NetTrexMM` / `USE NetTrexFX`)

## #5

**Amaç:** MM ürün tanımları + onaylı işlem sayısı. Kodda ISSUE dışlama `TxnMmProductTypeId != 3` (enum) ile yapılmış; mevcut kod `Product.AccountingMapCode == "ISSUE"` kullanıyor. Id 3 gerçekten ihraç mı, doğrulanacak.

```sql
SET NOCOUNT ON;
SELECT TOP (20) p.Id, p.Name, p.AccountingMapCode, COUNT(t.Id) AS VerifiedTxnCnt
FROM prdProductDefinition p
LEFT JOIN TxnMM t ON t.TxnMmProductTypeId = p.Id AND t.StateId IN (18, 26)
GROUP BY p.Id, p.Name, p.AccountingMapCode
ORDER BY p.Id DESC;
```

DB: `NetTrexMM` · Server: `tcp:192.168.10.211,1433` · User: `trusr` · Pass: `***` (kaynak: `NetTrex.MM/Code/docker-compose.override.yml`)

## #6

**Amaç:** Money Market rapor satırları — `MaturityReportDataManager.GetMoneyMarketTransactionsAsync` sorgusunun SQL karşılığı (oran = ilk faiz dönemi, faiz = Σ faiz detayı). Kolonlar ekrandaki 12 alanı dolduruyor mu?

```sql
SET NOCOUNT ON;
SELECT TOP (20) t.Id, t.LogicalReference, p.Name AS SubProduct, p.AccountingMapCode, LEFT(c.Name, 40) AS Counterparty,
       t.TxnTypeCode, tt.Name AS Direction, t.Ccy, t.DealAmount,
       (SELECT TOP (1) d.InterestRate FROM txnMMDetail d WHERE d.TxnId = t.Id AND d.IsPrincipalAmount = 0 ORDER BY d.PeriodStartDate) AS InterestRate,
       (SELECT SUM(d.Amount) FROM txnMMDetail d WHERE d.TxnId = t.Id AND d.IsPrincipalAmount = 0) AS InterestAmount,
       CONVERT(date, t.ValueDate) AS ValueDate, CONVERT(date, t.MaturityDate) AS MaturityDate,
       DATEDIFF(day, t.ValueDate, t.MaturityDate) AS TenorDays, t.StateId
FROM TxnMM t
LEFT JOIN prdProductDefinition p ON p.Id = t.TxnMmProductTypeId
LEFT JOIN cusCustomer c ON c.Id = t.CustomerId
LEFT JOIN defTxnType tt ON tt.TxnTypeCode = t.TxnTypeCode
WHERE t.StateId IN (18, 26)
ORDER BY t.Id DESC;
```

DB: `NetTrexMM` · Server: `tcp:192.168.10.211,1433` · User: `trusr` · Pass: `***` (kaynak: `NetTrex.MM/Code/docker-compose.override.yml`)

## #7

**Amaç:** Interbank Loan rapor satırları — `GetInterbankLoanTransactionsAsync` karşılığı. Başlık Rate / ilk faiz cash flow Rate / faiz toplamı dolu mu?

```sql
SET NOCOUNT ON;
SELECT TOP (20) l.Id, l.LogicalReference, p.Name AS SubProduct, LEFT(c.Name, 40) AS Counterparty, l.TxnTypeCode,
       l.CurrencyCode, l.PrincipalAmount, l.Rate AS HeaderRate,
       (SELECT TOP (1) cf.Rate FROM TxnCashFlow cf WHERE cf.TxnId = l.Id AND cf.FlowTypeId = 2 ORDER BY cf.StartDate) AS FirstInterestRate,
       (SELECT SUM(cf.CashFlowAmount) FROM TxnCashFlow cf WHERE cf.TxnId = l.Id AND cf.FlowTypeId = 2) AS InterestAmount,
       CONVERT(date, l.ValueDate) AS ValueDate, CONVERT(date, l.MaturityDate) AS MaturityDate, l.StateId
FROM TxnLoan l
LEFT JOIN prdProductDefinition p ON p.Id = l.ProductDefinitionId
LEFT JOIN cusCustomer c ON c.Id = l.CustomerId
WHERE l.StateId IN (18, 26)
ORDER BY l.Id DESC;
```

DB: `NetTrexMM` · Server: `tcp:192.168.10.211,1433` · User: `trusr` · Pass: `***` (kaynak: `NetTrex.MM/Code/docker-compose.override.yml`)

## #8

**Amaç:** Ay bazında onaylı işlem dağılımı (TxnMM, TxnLoan) — ekran testinde hangi tarih aralığının veri döndüreceğini bilmek için.

```sql
SET NOCOUNT ON;
SELECT TOP (20) Src, Ay, Cnt FROM (
    SELECT 'TxnMM' AS Src, FORMAT(ValueDate, 'yyyy-MM') AS Ay, COUNT(*) AS Cnt
    FROM TxnMM WHERE StateId IN (18, 26) GROUP BY FORMAT(ValueDate, 'yyyy-MM')
    UNION ALL
    SELECT 'TxnLoan', FORMAT(ValueDate, 'yyyy-MM'), COUNT(*)
    FROM TxnLoan WHERE StateId IN (18, 26) GROUP BY FORMAT(ValueDate, 'yyyy-MM')
) x
ORDER BY Ay DESC, Src;
```

DB: `NetTrexMM` · Server: `tcp:192.168.10.211,1433` · User: `trusr` · Pass: `***` (kaynak: `NetTrex.MM/Code/docker-compose.override.yml`)

## #9

**Amaç:** NetTrexFX tablo adları — EF entity'leri `TXN_FX_SWAP` (Oracle) ile işaretli; SQL Server adı doğrulanacak.

```sql
SET NOCOUNT ON;
SELECT TOP (20) name FROM sys.tables
WHERE name LIKE '%Swap%' OR name IN ('TxnFX', 'TxnPM', 'cusCustomer')
ORDER BY name;
```

DB: `NetTrexFX` · Server: `tcp:192.168.10.211,1433` · User: `trusr` · Pass: `***` (kaynak: `NetTrex.Fx/Code/docker-compose.override.yml`)


## #10

**Amaç:** FX / PM swap aktif near bacaklarının ay dağılımı — endpoint testinde hangi tarih aralığı veri döndürür.

```sql
SET NOCOUNT ON;
SELECT TOP (20) Src, Ay, NearCnt FROM (
    SELECT 'TxnFXSwap' AS Src, FORMAT(ValueDate, 'yyyy-MM') AS Ay, COUNT(*) AS NearCnt
    FROM TxnFXSwap WHERE InstrumentId = 1068 AND (StateId & 6) = 2 AND PkgNo <> 0 GROUP BY FORMAT(ValueDate, 'yyyy-MM')
    UNION ALL
    SELECT 'TxnPMSwap', FORMAT(ValueDate, 'yyyy-MM'), COUNT(*)
    FROM TxnPMSwap WHERE InstrumentId = 1068 AND (StateId & 6) = 2 AND PkgNo <> 0 GROUP BY FORMAT(ValueDate, 'yyyy-MM')
) x
ORDER BY Ay DESC, Src;
```

DB: `NetTrexFX` · Server: `tcp:192.168.10.211,1433` · User: `trusr` · Pass: `***` (kaynak: `NetTrex.Fx/Code/docker-compose.override.yml:17`)

## #11

**Amaç:** FX Swap near/far eşleşmesi (`MaturityReportRepository.FxSwapPairs` karşılığı): PkgNo + 1068/1069, kurlar, tutarlar, müşteri adı dolu mu.

```sql
SET NOCOUNT ON;
SELECT TOP (20) n.PkgNo, n.Id AS NearId, f.Id AS FarId, n.LogicalReference, LEFT(c.Name, 30) AS Counterparty, n.CcyPair,
       n.BuyCcy, n.BuyAmount, n.SellCcy, n.SellAmount, n.DealRateNet AS NearRate, f.DealRateNet AS FarRate,
       f.BuyCcy AS FarBuyCcy, f.BuyAmount AS FarBuyAmount, f.SellCcy AS FarSellCcy, f.SellAmount AS FarSellAmount,
       CONVERT(date, n.ValueDate) AS NearDate, CONVERT(date, f.ValueDate) AS FarDate
FROM TxnFXSwap n
JOIN TxnFXSwap f ON f.PkgNo = n.PkgNo AND f.InstrumentId = 1069 AND (f.StateId & 6) = 2
LEFT JOIN CusCustomer c ON c.Id = n.CustomerId
WHERE n.InstrumentId = 1068 AND (n.StateId & 6) = 2 AND n.PkgNo <> 0
ORDER BY n.Id DESC;
```

DB: `NetTrexFX` · Server: `tcp:192.168.10.211,1433` · User: `trusr` · Pass: `***` (kaynak: `NetTrex.Fx/Code/docker-compose.override.yml:17`)

## #12

**Amaç:** PM Swap eşleşmesi + ons/gram alanları (`PmSwapPairs` karşılığı).

```sql
SET NOCOUNT ON;
SELECT TOP (20) n.PkgNo, n.Id AS NearId, f.Id AS FarId, n.LogicalReference, LEFT(c.Name, 30) AS Counterparty, n.CcyPair,
       n.BuyCcy, n.BuyAmount, n.SellCcy, n.SellAmount, n.DealRateNet AS NearRate, f.DealRateNet AS FarRate,
       n.BuyAmountOunce, n.SellAmountOunce, n.BuyAmountGram, n.SellAmountGram,
       CONVERT(date, n.ValueDate) AS NearDate, CONVERT(date, f.ValueDate) AS FarDate
FROM TxnPMSwap n
JOIN TxnPMSwap f ON f.PkgNo = n.PkgNo AND f.InstrumentId = 1069 AND (f.StateId & 6) = 2
LEFT JOIN CusCustomer c ON c.Id = n.CustomerId
WHERE n.InstrumentId = 1068 AND (n.StateId & 6) = 2 AND n.PkgNo <> 0
ORDER BY n.Id DESC;
```

DB: `NetTrexFX` · Server: `tcp:192.168.10.211,1433` · User: `trusr` · Pass: `***` (kaynak: `NetTrex.Fx/Code/docker-compose.override.yml:17`)

## #13

**Amaç:** Bacak bütünlüğü: aynı PkgNo'da birden fazla aktif near (R5 tekilleştirme gerekli mi), far'ı olmayan near (rapordan düşer), PkgNo = 0 aktif bacak (rapordan düşer).

```sql
SET NOCOUNT ON;
SELECT TOP (20) Src, Kontrol, Cnt FROM (
    SELECT 'TxnFXSwap' AS Src, 'PkgNo basina >1 aktif near' AS Kontrol, COUNT(*) AS Cnt FROM (
        SELECT PkgNo FROM TxnFXSwap WHERE InstrumentId = 1068 AND (StateId & 6) = 2 AND PkgNo <> 0 GROUP BY PkgNo HAVING COUNT(*) > 1) a
    UNION ALL
    SELECT 'TxnFXSwap', 'Far bacagi olmayan aktif near', COUNT(*) FROM TxnFXSwap n
        WHERE n.InstrumentId = 1068 AND (n.StateId & 6) = 2 AND n.PkgNo <> 0
          AND NOT EXISTS (SELECT 1 FROM TxnFXSwap f WHERE f.PkgNo = n.PkgNo AND f.InstrumentId = 1069 AND (f.StateId & 6) = 2)
    UNION ALL
    SELECT 'TxnFXSwap', 'PkgNo = 0 aktif bacak', COUNT(*) FROM TxnFXSwap WHERE PkgNo = 0 AND (StateId & 6) = 2
    UNION ALL
    SELECT 'TxnPMSwap', 'PkgNo basina >1 aktif near', COUNT(*) FROM (
        SELECT PkgNo FROM TxnPMSwap WHERE InstrumentId = 1068 AND (StateId & 6) = 2 AND PkgNo <> 0 GROUP BY PkgNo HAVING COUNT(*) > 1) b
    UNION ALL
    SELECT 'TxnPMSwap', 'Far bacagi olmayan aktif near', COUNT(*) FROM TxnPMSwap n
        WHERE n.InstrumentId = 1068 AND (n.StateId & 6) = 2 AND n.PkgNo <> 0
          AND NOT EXISTS (SELECT 1 FROM TxnPMSwap f WHERE f.PkgNo = n.PkgNo AND f.InstrumentId = 1069 AND (f.StateId & 6) = 2)
    UNION ALL
    SELECT 'TxnPMSwap', 'PkgNo = 0 aktif bacak', COUNT(*) FROM TxnPMSwap WHERE PkgNo = 0 AND (StateId & 6) = 2
) x
ORDER BY Src, Kontrol;
```

DB: `NetTrexFX` · Server: `tcp:192.168.10.211,1433` · User: `trusr` · Pass: `***` (kaynak: `NetTrex.Fx/Code/docker-compose.override.yml:17`)

## #A1 — (SQL değil) lokal API çağrıları

**Amaç:** EF sorgusunun gerçekten çevrildiğini/çalıştığını görmek. Salt-okunur rapor endpoint'leri, lokal docker container'ları:

- `POST http://localhost:5041/api/maturity-report/transactions` (MM) — MoneyMarket 2026-09, InterbankLoan 2026-06
- `POST http://localhost:5011/api/maturity-report/transactions` (FX) — FxPmSwap


## #14

**Amaç:** #10-#12 boş döndü. Swap tablolarında InstrumentId / StateId / PkgNo gerçek dağılımı — 1068/1069 ve `(StateId & 6) = 2` varsayımı veriyle tutuyor mu? TOP (40): iki tablo × kombinasyonlar 20 satırı aşabilir.

```sql
SET NOCOUNT ON;
SELECT TOP (40) Src, InstrumentId, StateId, HasPkg, Cnt, MaxId FROM (
    SELECT 'TxnFXSwap' AS Src, InstrumentId, StateId, CASE WHEN PkgNo <> 0 THEN 1 ELSE 0 END AS HasPkg, COUNT(*) AS Cnt, MAX(Id) AS MaxId
    FROM TxnFXSwap GROUP BY InstrumentId, StateId, CASE WHEN PkgNo <> 0 THEN 1 ELSE 0 END
    UNION ALL
    SELECT 'TxnPMSwap', InstrumentId, StateId, CASE WHEN PkgNo <> 0 THEN 1 ELSE 0 END, COUNT(*), MAX(Id)
    FROM TxnPMSwap GROUP BY InstrumentId, StateId, CASE WHEN PkgNo <> 0 THEN 1 ELSE 0 END
) x
ORDER BY Src, Cnt DESC;
```

DB: `NetTrexFX` · aynı bağlantı


## #15

**Amaç:** #14 de boş — swap tabloları hiç satır içermiyor olabilir. NetTrexFX* veritabanları listesi + NetTrexFX'te ana tabloların satır sayısı (yalnız COUNT).

```sql
SET NOCOUNT ON;
SELECT TOP (20) d.name AS Db FROM sys.databases d WHERE d.name LIKE 'NetTrexFX%' ORDER BY d.name;
SELECT 'NetTrexFX' AS Db, (SELECT COUNT(*) FROM NetTrexFX.dbo.TxnFX) AS TxnFX, (SELECT COUNT(*) FROM NetTrexFX.dbo.TxnFXSwap) AS TxnFXSwap,
       (SELECT COUNT(*) FROM NetTrexFX.dbo.TxnPM) AS TxnPM, (SELECT COUNT(*) FROM NetTrexFX.dbo.TxnPMSwap) AS TxnPMSwap,
       (SELECT COUNT(*) FROM NetTrexFX.dbo.TxnFXSwapHistory) AS TxnFXSwapHistory;
```

DB: `NetTrexFX` · aynı bağlantı


## #16

**Amaç:** NetTrexFX'te swap yok (#15). `NetTrexFX_Dev`'de (compose'un önceki DB'si) swap verisi var mı — mantığı orada doğrulamak için (yalnız COUNT).

```sql
SET NOCOUNT ON;
SELECT 'NetTrexFX_Dev' AS Db, (SELECT COUNT(*) FROM TxnFX) AS TxnFX, (SELECT COUNT(*) FROM TxnFXSwap) AS TxnFXSwap,
       (SELECT COUNT(*) FROM TxnPM) AS TxnPM, (SELECT COUNT(*) FROM TxnPMSwap) AS TxnPMSwap;
```

DB: `NetTrexFX_Dev` · aynı server/kullanıcı


## #17, #18, #19

**Amaç:** #11, #12, #14 sorgularının AYNISI `NetTrexFX_Dev` üzerinde (FX pair, PM pair, InstrumentId/StateId dağılımı) — eşleşme mantığı ve kolonlar gerçek veriyle.

DB: `NetTrexFX_Dev` · SQL: #11 / #12 / #14 ile birebir


## #20

**Amaç:** Manuel Reeskont menü kayıtları (kullanıcının örnek scripti: ApplicationName Trex.WebUI, parent 129) + 129 numaralı parent ve kardeşleri — Vade Raporu menüsünün yerini ve ItemOrderId'yi buna göre seçmek için. MaturityReportKey zaten var mı.

```sql
SET NOCOUNT ON;
SELECT TOP (20) m.Id, m.ApplicationName, m.MenuKey, LEFT(m.Description, 40) AS Description, m.MenuType, m.Value,
       m.ParentId, LEFT(p.Description, 30) AS ParentDesc, m.ItemOrderId, m.ModuleName, m.IsActive
FROM dbo.FrameworkMenu m
LEFT JOIN dbo.FrameworkMenu p ON p.Id = m.ParentId
WHERE m.MenuKey IN ('ManuelRevaluationV2', 'ManuelRediscountKey', 'TreasuryRediscountKey', 'SecurityRediscountKey', 'InvestmentRediscountKey', 'MaturityReportKey')
   OR m.Value LIKE '%Rediscount/Index%' OR m.Value LIKE 'MaturityReport/%'
   OR m.Id = 129 OR m.ParentId = 129
ORDER BY m.Id DESC;
```

DB: `NetTrexCommon` · Server: `tcp:192.168.10.211,1433` · User: `trusr` · Pass: `***` (kaynak: `NetTrex.Common/Code/docker-compose.override.yml:27`)


## #21

**Amaç:** Aktif rapor menüleri ve bağlı oldukları gruplar — "en mantıklı yer" için. TOP (50): rapor menüleri birden çok modülde, 20 satır grubu tam göstermeyebilir.

```sql
SET NOCOUNT ON;
SELECT TOP (50) m.Id, m.MenuKey, LEFT(m.Description, 40) AS Description, m.MenuType, LEFT(m.Value, 45) AS Value,
       m.ParentId, LEFT(p.Description, 30) AS ParentDesc, m.ItemOrderId, m.ModuleName
FROM dbo.FrameworkMenu m
LEFT JOIN dbo.FrameworkMenu p ON p.Id = m.ParentId
WHERE m.IsActive = 1
  AND (m.MenuKey LIKE '%Report%' OR m.Description LIKE '%Report%' OR m.Description LIKE '%Rapor%' OR m.Value LIKE '%Report%')
ORDER BY m.Id DESC;
```

DB: `NetTrexCommon` · Server: `tcp:192.168.10.211,1433` · User: `trusr` · Pass: `***` (kaynak: `NetTrex.Common/Code/docker-compose.override.yml:27`)


## #22

**Amaç:** Reports (34), Money & Market (36), FX & PM Transactions (38) altındaki menüler — Vade Raporu'nun ItemOrderId'si ve ikonu kardeşlerine göre seçilecek.

```sql
SET NOCOUNT ON;
SELECT TOP (20) m.Id, m.ApplicationName, m.MenuKey, LEFT(m.Description, 35) AS Description, m.MenuType, LEFT(m.Value, 40) AS Value,
       m.ItemOrderId, m.ModuleName, m.Icon, m.IsActive
FROM dbo.FrameworkMenu m
WHERE m.ParentId IN (34, 36, 38)
ORDER BY m.Id DESC;
```

DB: `NetTrexCommon` · aynı bağlantı


## #23

**Amaç:** Kullanıcı kararı: rapora yalnız ProductDefinition'da Enabled olan ürünler gelecek. Hangi ürün açık/kapalı, TxnMM ve TxnLoan'da kaçar onaylı işlemi var — filtre sonrası ekranda ne görüneceğini bilmek için.

```sql
SET NOCOUNT ON;
SELECT TOP (20) p.Id, p.Name, p.AccountingMapCode, p.IsEnabled, p.StateId,
       (SELECT COUNT(*) FROM TxnMM t WHERE t.TxnMmProductTypeId = p.Id AND t.StateId IN (18, 26)) AS TxnMmCnt,
       (SELECT COUNT(*) FROM TxnLoan l WHERE l.ProductDefinitionId = p.Id AND l.StateId IN (18, 26)) AS TxnLoanCnt
FROM prdProductDefinition p
ORDER BY p.Id DESC;
```

DB: `NetTrexMM` · Server: `tcp:192.168.10.211,1433` · User: `trusr` · Pass: `***` (kaynak: `NetTrex.MM/Code/docker-compose.override.yml`)



## #24

**Amaç:** Test hazırlığı: MM/IL test senaryoları için alt ürün (Code) bazında aktif ((StateId & 6) = 2) işlem sayısı ve valör aralığı; aktif state'lerin dağılımı (container eski VerifiedStatesId ile mi çalışıyor ayırt etmek için).

```sql
SET NOCOUNT ON;
SELECT TOP (20) p.Id, p.Code, p.Name, p.IsEnabled,
       (SELECT COUNT(*) FROM TxnMM t WHERE t.TxnMmProductTypeId = p.Id AND (t.StateId & 6) = 2) AS MmActive,
       (SELECT COUNT(*) FROM TxnLoan l WHERE l.ProductDefinitionId = p.Id AND (l.StateId & 6) = 2) AS LoanActive,
       (SELECT MIN(t.ValueDate) FROM TxnMM t WHERE t.TxnMmProductTypeId = p.Id AND (t.StateId & 6) = 2) AS MmMinVal,
       (SELECT MAX(t.ValueDate) FROM TxnMM t WHERE t.TxnMmProductTypeId = p.Id AND (t.StateId & 6) = 2) AS MmMaxVal,
       (SELECT MIN(l.ValueDate) FROM TxnLoan l WHERE l.ProductDefinitionId = p.Id AND (l.StateId & 6) = 2) AS LoanMinVal,
       (SELECT MAX(l.ValueDate) FROM TxnLoan l WHERE l.ProductDefinitionId = p.Id AND (l.StateId & 6) = 2) AS LoanMaxVal
FROM prdProductDefinition p
ORDER BY p.Id DESC;
SELECT TOP (20) 'TxnMM' AS Src, StateId, COUNT(*) AS Cnt FROM TxnMM WHERE (StateId & 6) = 2 GROUP BY StateId
UNION ALL
SELECT 'TxnLoan', StateId, COUNT(*) FROM TxnLoan WHERE (StateId & 6) = 2 GROUP BY StateId
ORDER BY Src, StateId DESC;
```

DB: `NetTrexMM` · Server: `tcp:192.168.10.211,1433` · User: `trusr` · Pass: `***`


## #25

**Amaç:** #24 tekrarı (sqlcmd -i dosya yolunu açamadı; sorgu -Q ile).

```sql
SET NOCOUNT ON;
SELECT TOP (20) p.Id, p.Code, p.Name, p.IsEnabled,
       (SELECT COUNT(*) FROM TxnMM t WHERE t.TxnMmProductTypeId = p.Id AND (t.StateId & 6) = 2) AS MmActive,
       (SELECT COUNT(*) FROM TxnLoan l WHERE l.ProductDefinitionId = p.Id AND (l.StateId & 6) = 2) AS LoanActive,
       (SELECT MIN(t.ValueDate) FROM TxnMM t WHERE t.TxnMmProductTypeId = p.Id AND (t.StateId & 6) = 2) AS MmMinVal,
       (SELECT MAX(t.ValueDate) FROM TxnMM t WHERE t.TxnMmProductTypeId = p.Id AND (t.StateId & 6) = 2) AS MmMaxVal,
       (SELECT MIN(l.ValueDate) FROM TxnLoan l WHERE l.ProductDefinitionId = p.Id AND (l.StateId & 6) = 2) AS LoanMinVal,
       (SELECT MAX(l.ValueDate) FROM TxnLoan l WHERE l.ProductDefinitionId = p.Id AND (l.StateId & 6) = 2) AS LoanMaxVal
FROM prdProductDefinition p
ORDER BY p.Id DESC;
SELECT TOP (20) 'TxnMM' AS Src, StateId, COUNT(*) AS Cnt FROM TxnMM WHERE (StateId & 6) = 2 GROUP BY StateId
UNION ALL
SELECT 'TxnLoan', StateId, COUNT(*) FROM TxnLoan WHERE (StateId & 6) = 2 GROUP BY StateId
ORDER BY Src, StateId DESC;
```

DB: `NetTrexMM` · Server: `tcp:192.168.10.211,1433` · User: `trusr` · Pass: `***`


## #26

**Amaç:** Test hazırlığı: FX/PM swap bacaklarının (1068 near / 1069 far) state ve valör dağılımı — 20'şer test senaryosu için hangi tarih aralıklarında aktif veri var. TOP (40): iki tablo x instrument x state 20'yi aşabilir.

```sql
SET NOCOUNT ON;
SELECT TOP (40) Src, InstrumentId, StateId, Cnt, MinVal, MaxVal FROM (
    SELECT 'TxnFXSwap' AS Src, InstrumentId, StateId, COUNT(*) AS Cnt, MIN(CAST(ValueDate AS date)) AS MinVal, MAX(CAST(ValueDate AS date)) AS MaxVal
    FROM TxnFXSwap WHERE PkgNo <> 0 GROUP BY InstrumentId, StateId
    UNION ALL
    SELECT 'TxnPMSwap', InstrumentId, StateId, COUNT(*), MIN(CAST(ValueDate AS date)), MAX(CAST(ValueDate AS date))
    FROM TxnPMSwap WHERE PkgNo <> 0 GROUP BY InstrumentId, StateId
) x
ORDER BY Src, InstrumentId, Cnt DESC;
```

DB: `NetTrexFX` · Server: `tcp:192.168.10.211,1433` · User: `trusr` · Pass: `***`


## #27

**Amaç:** Test hazırlığı (IL): aktif TxnLoan son 20 kayıt (referans/valör/vade örnekleri) ve valör-vade ay dağılımı — tek gün, sınır ve referans senaryolarını gerçek değerlerle kurmak için.

```sql
SET NOCOUNT ON;
SELECT TOP (20) l.Id, l.LogicalReference, CAST(l.ValueDate AS date) AS ValueDate, CAST(l.MaturityDate AS date) AS MaturityDate,
       l.CurrencyCode, l.PrincipalAmount, l.Rate, l.TxnTypeCode, l.CustomerId, l.StateId
FROM TxnLoan l
WHERE (l.StateId & 6) = 2
ORDER BY l.Id DESC;
SELECT TOP (20) FORMAT(ValueDate, 'yyyy-MM') AS ValMonth, FORMAT(MaturityDate, 'yyyy-MM') AS MatMonth, COUNT(*) AS Cnt
FROM TxnLoan WHERE (StateId & 6) = 2
GROUP BY FORMAT(ValueDate, 'yyyy-MM'), FORMAT(MaturityDate, 'yyyy-MM')
ORDER BY ValMonth DESC, MatMonth DESC;
```

DB: `NetTrexMM` · Server: `tcp:192.168.10.211,1433` · User: `trusr` · Pass: `***`


## #28

**Amaç:** Test hazırlığı (Swap): 2026-09 sonrası tüm FX/PM swap bacakları (aktif + Input 16 + DeleteVerified 22) — referans testleri ve dışlanma testleri için gerçek LogicalReference/PkgNo değerleri. TOP (40): FX 10 + PM 14 bacak var, 20 hepsini göstermez.

```sql
SET NOCOUNT ON;
SELECT TOP (40) Src, Id, PkgNo, InstrumentId, StateId, LogicalReference, CustomerId, CcyPair, BuyCcy, BuyAmount, SellCcy, SellAmount, DealRateNet, ValueDate FROM (
    SELECT 'FX' AS Src, Id, PkgNo, InstrumentId, StateId, LogicalReference, CustomerId, CcyPair, BuyCcy, BuyAmount, SellCcy, SellAmount, DealRateNet, CAST(ValueDate AS date) AS ValueDate
    FROM TxnFXSwap WHERE PkgNo <> 0 AND ValueDate >= '2026-09-01'
    UNION ALL
    SELECT 'PM', Id, PkgNo, InstrumentId, StateId, LogicalReference, CustomerId, CcyPair, BuyCcy, BuyAmount, SellCcy, SellAmount, DealRateNet, CAST(ValueDate AS date)
    FROM TxnPMSwap WHERE PkgNo <> 0 AND ValueDate >= '2026-09-01'
) x
ORDER BY Id DESC;
```

DB: `NetTrexFX` · Server: `tcp:192.168.10.211,1433` · User: `trusr` · Pass: `***`


## #29

**Amaç:** Testte 'Vadeye Kalan' kontrolü için MM ve FX mantıksal tarih parametreleri (Trex:MMLogicalDate, Trex:FxLogicalDate). FX ekranında 07.10 vadeye 5 gün, MM'de 28.11'e 58 gün yazıyor — iki modülün tarihi farklı mı?

```sql
SET NOCOUNT ON;
SELECT TOP (20) Id, OptionPath, OptionName, ApplicationName, EnvironmentName, Value, StateId
FROM FrameworkParameter
WHERE OptionName IN ('MMLogicalDate', 'FxLogicalDate')
ORDER BY Id DESC;
```

DB: `NetTrexCommon` · Server: `tcp:192.168.10.211,1433` · User: `trusr` · Pass: `***`


## #30

**Amaç:** Test MM: Ekran varsayılanı (bu ay) — valör 2026-10-01–2026-10-31. API (ekran) sonucu ile karşılaştırma; TOP (20) satır alan alan, sayı/toplamlar pencere fonksiyonuyla tüm küme üzerinden.

```sql
SET NOCOUNT ON;
DECLARE @LD date = '2026-10-01';
WITH Q AS (
SELECT t.Id, t.LogicalReference, c.Name AS CounterpartyName, ROUND(t.DealAmount, 2) AS PrincipalAmount, t.Ccy AS Currency,
       CAST(t.ValueDate AS date) AS ValueDate, CAST(t.MaturityDate AS date) AS MaturityDate,
       ir.Rate AS InterestRate, ROUND(ia.Amt, 2) AS InterestAmount, ISNULL(tt.Name, t.TxnTypeCode) AS Direction, p.Name AS SubProductName
FROM TxnMM t
JOIN prdProductDefinition p ON p.Id = t.TxnMmProductTypeId AND p.IsEnabled = 1
OUTER APPLY (SELECT TOP (1) cu.Name FROM cusCustomer cu WHERE cu.Id = t.CustomerId) c
OUTER APPLY (SELECT TOP (1) x.Name FROM defTxnType x WHERE x.TxnTypeCode = t.TxnTypeCode) tt
OUTER APPLY (SELECT TOP (1) d.InterestRate AS Rate FROM txnMMDetail d WHERE d.TxnId = t.Id AND d.IsPrincipalAmount = 0 ORDER BY d.PeriodStartDate) ir
OUTER APPLY (SELECT SUM(d.Amount) AS Amt FROM txnMMDetail d WHERE d.TxnId = t.Id AND d.IsPrincipalAmount = 0) ia
WHERE (t.StateId & 6) = 2 AND t.ValueDate >= '2026-10-01' AND t.ValueDate < DATEADD(day, 1, CAST('2026-10-31' AS date))
)
SELECT TOP (20) Id, LogicalReference, CounterpartyName, PrincipalAmount, Currency, ValueDate, MaturityDate,
       DATEDIFF(day, ValueDate, MaturityDate) AS OriginalTenorDays,
       CASE WHEN MaturityDate < @LD THEN 0 ELSE DATEDIFF(day, @LD, MaturityDate) END AS DaysToMaturity,
       InterestRate, InterestAmount, Direction, SubProductName,
       COUNT(*) OVER () AS TotCnt, SUM(PrincipalAmount) OVER () AS TotPrincipal, SUM(InterestAmount) OVER () AS TotInterest,
       MIN(ValueDate) OVER () AS MinVal, MAX(ValueDate) OVER () AS MaxVal
FROM Q
ORDER BY Id DESC;
```

DB: `NetTrexMM` · Server: `tcp:192.168.10.211,1433` · User: `trusr` · Pass: `***`


## #31

**Amaç:** Test MM: Eylül 2026 valör — valör 2026-09-01–2026-09-30. API (ekran) sonucu ile karşılaştırma; TOP (20) satır alan alan, sayı/toplamlar pencere fonksiyonuyla tüm küme üzerinden.

```sql
SET NOCOUNT ON;
DECLARE @LD date = '2026-10-01';
WITH Q AS (
SELECT t.Id, t.LogicalReference, c.Name AS CounterpartyName, ROUND(t.DealAmount, 2) AS PrincipalAmount, t.Ccy AS Currency,
       CAST(t.ValueDate AS date) AS ValueDate, CAST(t.MaturityDate AS date) AS MaturityDate,
       ir.Rate AS InterestRate, ROUND(ia.Amt, 2) AS InterestAmount, ISNULL(tt.Name, t.TxnTypeCode) AS Direction, p.Name AS SubProductName
FROM TxnMM t
JOIN prdProductDefinition p ON p.Id = t.TxnMmProductTypeId AND p.IsEnabled = 1
OUTER APPLY (SELECT TOP (1) cu.Name FROM cusCustomer cu WHERE cu.Id = t.CustomerId) c
OUTER APPLY (SELECT TOP (1) x.Name FROM defTxnType x WHERE x.TxnTypeCode = t.TxnTypeCode) tt
OUTER APPLY (SELECT TOP (1) d.InterestRate AS Rate FROM txnMMDetail d WHERE d.TxnId = t.Id AND d.IsPrincipalAmount = 0 ORDER BY d.PeriodStartDate) ir
OUTER APPLY (SELECT SUM(d.Amount) AS Amt FROM txnMMDetail d WHERE d.TxnId = t.Id AND d.IsPrincipalAmount = 0) ia
WHERE (t.StateId & 6) = 2 AND t.ValueDate >= '2026-09-01' AND t.ValueDate < DATEADD(day, 1, CAST('2026-09-30' AS date))
)
SELECT TOP (20) Id, LogicalReference, CounterpartyName, PrincipalAmount, Currency, ValueDate, MaturityDate,
       DATEDIFF(day, ValueDate, MaturityDate) AS OriginalTenorDays,
       CASE WHEN MaturityDate < @LD THEN 0 ELSE DATEDIFF(day, @LD, MaturityDate) END AS DaysToMaturity,
       InterestRate, InterestAmount, Direction, SubProductName,
       COUNT(*) OVER () AS TotCnt, SUM(PrincipalAmount) OVER () AS TotPrincipal, SUM(InterestAmount) OVER () AS TotInterest,
       MIN(ValueDate) OVER () AS MinVal, MAX(ValueDate) OVER () AS MaxVal
FROM Q
ORDER BY Id DESC;
```

DB: `NetTrexMM` · Server: `tcp:192.168.10.211,1433` · User: `trusr` · Pass: `***`


## #32

**Amaç:** Test MM: Yalnız valör başlangıç — valör 2026-09-15–…. API (ekran) sonucu ile karşılaştırma; TOP (20) satır alan alan, sayı/toplamlar pencere fonksiyonuyla tüm küme üzerinden.

```sql
SET NOCOUNT ON;
DECLARE @LD date = '2026-10-01';
WITH Q AS (
SELECT t.Id, t.LogicalReference, c.Name AS CounterpartyName, ROUND(t.DealAmount, 2) AS PrincipalAmount, t.Ccy AS Currency,
       CAST(t.ValueDate AS date) AS ValueDate, CAST(t.MaturityDate AS date) AS MaturityDate,
       ir.Rate AS InterestRate, ROUND(ia.Amt, 2) AS InterestAmount, ISNULL(tt.Name, t.TxnTypeCode) AS Direction, p.Name AS SubProductName
FROM TxnMM t
JOIN prdProductDefinition p ON p.Id = t.TxnMmProductTypeId AND p.IsEnabled = 1
OUTER APPLY (SELECT TOP (1) cu.Name FROM cusCustomer cu WHERE cu.Id = t.CustomerId) c
OUTER APPLY (SELECT TOP (1) x.Name FROM defTxnType x WHERE x.TxnTypeCode = t.TxnTypeCode) tt
OUTER APPLY (SELECT TOP (1) d.InterestRate AS Rate FROM txnMMDetail d WHERE d.TxnId = t.Id AND d.IsPrincipalAmount = 0 ORDER BY d.PeriodStartDate) ir
OUTER APPLY (SELECT SUM(d.Amount) AS Amt FROM txnMMDetail d WHERE d.TxnId = t.Id AND d.IsPrincipalAmount = 0) ia
WHERE (t.StateId & 6) = 2 AND t.ValueDate >= '2026-09-15'
)
SELECT TOP (20) Id, LogicalReference, CounterpartyName, PrincipalAmount, Currency, ValueDate, MaturityDate,
       DATEDIFF(day, ValueDate, MaturityDate) AS OriginalTenorDays,
       CASE WHEN MaturityDate < @LD THEN 0 ELSE DATEDIFF(day, @LD, MaturityDate) END AS DaysToMaturity,
       InterestRate, InterestAmount, Direction, SubProductName,
       COUNT(*) OVER () AS TotCnt, SUM(PrincipalAmount) OVER () AS TotPrincipal, SUM(InterestAmount) OVER () AS TotInterest,
       MIN(ValueDate) OVER () AS MinVal, MAX(ValueDate) OVER () AS MaxVal
FROM Q
ORDER BY Id DESC;
```

DB: `NetTrexMM` · Server: `tcp:192.168.10.211,1433` · User: `trusr` · Pass: `***`


## #33

**Amaç:** Test MM: Yalnız valör bitiş — valör …–2025-09-30. API (ekran) sonucu ile karşılaştırma; TOP (20) satır alan alan, sayı/toplamlar pencere fonksiyonuyla tüm küme üzerinden.

```sql
SET NOCOUNT ON;
DECLARE @LD date = '2026-10-01';
WITH Q AS (
SELECT t.Id, t.LogicalReference, c.Name AS CounterpartyName, ROUND(t.DealAmount, 2) AS PrincipalAmount, t.Ccy AS Currency,
       CAST(t.ValueDate AS date) AS ValueDate, CAST(t.MaturityDate AS date) AS MaturityDate,
       ir.Rate AS InterestRate, ROUND(ia.Amt, 2) AS InterestAmount, ISNULL(tt.Name, t.TxnTypeCode) AS Direction, p.Name AS SubProductName
FROM TxnMM t
JOIN prdProductDefinition p ON p.Id = t.TxnMmProductTypeId AND p.IsEnabled = 1
OUTER APPLY (SELECT TOP (1) cu.Name FROM cusCustomer cu WHERE cu.Id = t.CustomerId) c
OUTER APPLY (SELECT TOP (1) x.Name FROM defTxnType x WHERE x.TxnTypeCode = t.TxnTypeCode) tt
OUTER APPLY (SELECT TOP (1) d.InterestRate AS Rate FROM txnMMDetail d WHERE d.TxnId = t.Id AND d.IsPrincipalAmount = 0 ORDER BY d.PeriodStartDate) ir
OUTER APPLY (SELECT SUM(d.Amount) AS Amt FROM txnMMDetail d WHERE d.TxnId = t.Id AND d.IsPrincipalAmount = 0) ia
WHERE (t.StateId & 6) = 2 AND t.ValueDate < DATEADD(day, 1, CAST('2025-09-30' AS date))
)
SELECT TOP (20) Id, LogicalReference, CounterpartyName, PrincipalAmount, Currency, ValueDate, MaturityDate,
       DATEDIFF(day, ValueDate, MaturityDate) AS OriginalTenorDays,
       CASE WHEN MaturityDate < @LD THEN 0 ELSE DATEDIFF(day, @LD, MaturityDate) END AS DaysToMaturity,
       InterestRate, InterestAmount, Direction, SubProductName,
       COUNT(*) OVER () AS TotCnt, SUM(PrincipalAmount) OVER () AS TotPrincipal, SUM(InterestAmount) OVER () AS TotInterest,
       MIN(ValueDate) OVER () AS MinVal, MAX(ValueDate) OVER () AS MaxVal
FROM Q
ORDER BY Id DESC;
```

DB: `NetTrexMM` · Server: `tcp:192.168.10.211,1433` · User: `trusr` · Pass: `***`


## #34

**Amaç:** Test MM: Tek gün valör (iki uç dahil) — valör 2026-09-18–2026-09-18. API (ekran) sonucu ile karşılaştırma; TOP (20) satır alan alan, sayı/toplamlar pencere fonksiyonuyla tüm küme üzerinden.

```sql
SET NOCOUNT ON;
DECLARE @LD date = '2026-10-01';
WITH Q AS (
SELECT t.Id, t.LogicalReference, c.Name AS CounterpartyName, ROUND(t.DealAmount, 2) AS PrincipalAmount, t.Ccy AS Currency,
       CAST(t.ValueDate AS date) AS ValueDate, CAST(t.MaturityDate AS date) AS MaturityDate,
       ir.Rate AS InterestRate, ROUND(ia.Amt, 2) AS InterestAmount, ISNULL(tt.Name, t.TxnTypeCode) AS Direction, p.Name AS SubProductName
FROM TxnMM t
JOIN prdProductDefinition p ON p.Id = t.TxnMmProductTypeId AND p.IsEnabled = 1
OUTER APPLY (SELECT TOP (1) cu.Name FROM cusCustomer cu WHERE cu.Id = t.CustomerId) c
OUTER APPLY (SELECT TOP (1) x.Name FROM defTxnType x WHERE x.TxnTypeCode = t.TxnTypeCode) tt
OUTER APPLY (SELECT TOP (1) d.InterestRate AS Rate FROM txnMMDetail d WHERE d.TxnId = t.Id AND d.IsPrincipalAmount = 0 ORDER BY d.PeriodStartDate) ir
OUTER APPLY (SELECT SUM(d.Amount) AS Amt FROM txnMMDetail d WHERE d.TxnId = t.Id AND d.IsPrincipalAmount = 0) ia
WHERE (t.StateId & 6) = 2 AND t.ValueDate >= '2026-09-18' AND t.ValueDate < DATEADD(day, 1, CAST('2026-09-18' AS date))
)
SELECT TOP (20) Id, LogicalReference, CounterpartyName, PrincipalAmount, Currency, ValueDate, MaturityDate,
       DATEDIFF(day, ValueDate, MaturityDate) AS OriginalTenorDays,
       CASE WHEN MaturityDate < @LD THEN 0 ELSE DATEDIFF(day, @LD, MaturityDate) END AS DaysToMaturity,
       InterestRate, InterestAmount, Direction, SubProductName,
       COUNT(*) OVER () AS TotCnt, SUM(PrincipalAmount) OVER () AS TotPrincipal, SUM(InterestAmount) OVER () AS TotInterest,
       MIN(ValueDate) OVER () AS MinVal, MAX(ValueDate) OVER () AS MaxVal
FROM Q
ORDER BY Id DESC;
```

DB: `NetTrexMM` · Server: `tcp:192.168.10.211,1433` · User: `trusr` · Pass: `***`


## #35

**Amaç:** Test MM: Ay sonu sınırı (30.09 dahil) — valör 2026-09-30–2026-09-30. API (ekran) sonucu ile karşılaştırma; TOP (20) satır alan alan, sayı/toplamlar pencere fonksiyonuyla tüm küme üzerinden.

```sql
SET NOCOUNT ON;
DECLARE @LD date = '2026-10-01';
WITH Q AS (
SELECT t.Id, t.LogicalReference, c.Name AS CounterpartyName, ROUND(t.DealAmount, 2) AS PrincipalAmount, t.Ccy AS Currency,
       CAST(t.ValueDate AS date) AS ValueDate, CAST(t.MaturityDate AS date) AS MaturityDate,
       ir.Rate AS InterestRate, ROUND(ia.Amt, 2) AS InterestAmount, ISNULL(tt.Name, t.TxnTypeCode) AS Direction, p.Name AS SubProductName
FROM TxnMM t
JOIN prdProductDefinition p ON p.Id = t.TxnMmProductTypeId AND p.IsEnabled = 1
OUTER APPLY (SELECT TOP (1) cu.Name FROM cusCustomer cu WHERE cu.Id = t.CustomerId) c
OUTER APPLY (SELECT TOP (1) x.Name FROM defTxnType x WHERE x.TxnTypeCode = t.TxnTypeCode) tt
OUTER APPLY (SELECT TOP (1) d.InterestRate AS Rate FROM txnMMDetail d WHERE d.TxnId = t.Id AND d.IsPrincipalAmount = 0 ORDER BY d.PeriodStartDate) ir
OUTER APPLY (SELECT SUM(d.Amount) AS Amt FROM txnMMDetail d WHERE d.TxnId = t.Id AND d.IsPrincipalAmount = 0) ia
WHERE (t.StateId & 6) = 2 AND t.ValueDate >= '2026-09-30' AND t.ValueDate < DATEADD(day, 1, CAST('2026-09-30' AS date))
)
SELECT TOP (20) Id, LogicalReference, CounterpartyName, PrincipalAmount, Currency, ValueDate, MaturityDate,
       DATEDIFF(day, ValueDate, MaturityDate) AS OriginalTenorDays,
       CASE WHEN MaturityDate < @LD THEN 0 ELSE DATEDIFF(day, @LD, MaturityDate) END AS DaysToMaturity,
       InterestRate, InterestAmount, Direction, SubProductName,
       COUNT(*) OVER () AS TotCnt, SUM(PrincipalAmount) OVER () AS TotPrincipal, SUM(InterestAmount) OVER () AS TotInterest,
       MIN(ValueDate) OVER () AS MinVal, MAX(ValueDate) OVER () AS MaxVal
FROM Q
ORDER BY Id DESC;
```

DB: `NetTrexMM` · Server: `tcp:192.168.10.211,1433` · User: `trusr` · Pass: `***`


## #36

**Amaç:** Test MM: Vade aralığı Eylül 2026 — vade 2026-09-01–2026-09-30. API (ekran) sonucu ile karşılaştırma; TOP (20) satır alan alan, sayı/toplamlar pencere fonksiyonuyla tüm küme üzerinden.

```sql
SET NOCOUNT ON;
DECLARE @LD date = '2026-10-01';
WITH Q AS (
SELECT t.Id, t.LogicalReference, c.Name AS CounterpartyName, ROUND(t.DealAmount, 2) AS PrincipalAmount, t.Ccy AS Currency,
       CAST(t.ValueDate AS date) AS ValueDate, CAST(t.MaturityDate AS date) AS MaturityDate,
       ir.Rate AS InterestRate, ROUND(ia.Amt, 2) AS InterestAmount, ISNULL(tt.Name, t.TxnTypeCode) AS Direction, p.Name AS SubProductName
FROM TxnMM t
JOIN prdProductDefinition p ON p.Id = t.TxnMmProductTypeId AND p.IsEnabled = 1
OUTER APPLY (SELECT TOP (1) cu.Name FROM cusCustomer cu WHERE cu.Id = t.CustomerId) c
OUTER APPLY (SELECT TOP (1) x.Name FROM defTxnType x WHERE x.TxnTypeCode = t.TxnTypeCode) tt
OUTER APPLY (SELECT TOP (1) d.InterestRate AS Rate FROM txnMMDetail d WHERE d.TxnId = t.Id AND d.IsPrincipalAmount = 0 ORDER BY d.PeriodStartDate) ir
OUTER APPLY (SELECT SUM(d.Amount) AS Amt FROM txnMMDetail d WHERE d.TxnId = t.Id AND d.IsPrincipalAmount = 0) ia
WHERE (t.StateId & 6) = 2 AND t.MaturityDate >= '2026-09-01' AND t.MaturityDate < DATEADD(day, 1, CAST('2026-09-30' AS date))
)
SELECT TOP (20) Id, LogicalReference, CounterpartyName, PrincipalAmount, Currency, ValueDate, MaturityDate,
       DATEDIFF(day, ValueDate, MaturityDate) AS OriginalTenorDays,
       CASE WHEN MaturityDate < @LD THEN 0 ELSE DATEDIFF(day, @LD, MaturityDate) END AS DaysToMaturity,
       InterestRate, InterestAmount, Direction, SubProductName,
       COUNT(*) OVER () AS TotCnt, SUM(PrincipalAmount) OVER () AS TotPrincipal, SUM(InterestAmount) OVER () AS TotInterest,
       MIN(ValueDate) OVER () AS MinVal, MAX(ValueDate) OVER () AS MaxVal
FROM Q
ORDER BY Id DESC;
```

DB: `NetTrexMM` · Server: `tcp:192.168.10.211,1433` · User: `trusr` · Pass: `***`


## #37

**Amaç:** Test MM: Yalnız vade başlangıç — vade 2026-11-01–…. API (ekran) sonucu ile karşılaştırma; TOP (20) satır alan alan, sayı/toplamlar pencere fonksiyonuyla tüm küme üzerinden.

```sql
SET NOCOUNT ON;
DECLARE @LD date = '2026-10-01';
WITH Q AS (
SELECT t.Id, t.LogicalReference, c.Name AS CounterpartyName, ROUND(t.DealAmount, 2) AS PrincipalAmount, t.Ccy AS Currency,
       CAST(t.ValueDate AS date) AS ValueDate, CAST(t.MaturityDate AS date) AS MaturityDate,
       ir.Rate AS InterestRate, ROUND(ia.Amt, 2) AS InterestAmount, ISNULL(tt.Name, t.TxnTypeCode) AS Direction, p.Name AS SubProductName
FROM TxnMM t
JOIN prdProductDefinition p ON p.Id = t.TxnMmProductTypeId AND p.IsEnabled = 1
OUTER APPLY (SELECT TOP (1) cu.Name FROM cusCustomer cu WHERE cu.Id = t.CustomerId) c
OUTER APPLY (SELECT TOP (1) x.Name FROM defTxnType x WHERE x.TxnTypeCode = t.TxnTypeCode) tt
OUTER APPLY (SELECT TOP (1) d.InterestRate AS Rate FROM txnMMDetail d WHERE d.TxnId = t.Id AND d.IsPrincipalAmount = 0 ORDER BY d.PeriodStartDate) ir
OUTER APPLY (SELECT SUM(d.Amount) AS Amt FROM txnMMDetail d WHERE d.TxnId = t.Id AND d.IsPrincipalAmount = 0) ia
WHERE (t.StateId & 6) = 2 AND t.MaturityDate >= '2026-11-01'
)
SELECT TOP (20) Id, LogicalReference, CounterpartyName, PrincipalAmount, Currency, ValueDate, MaturityDate,
       DATEDIFF(day, ValueDate, MaturityDate) AS OriginalTenorDays,
       CASE WHEN MaturityDate < @LD THEN 0 ELSE DATEDIFF(day, @LD, MaturityDate) END AS DaysToMaturity,
       InterestRate, InterestAmount, Direction, SubProductName,
       COUNT(*) OVER () AS TotCnt, SUM(PrincipalAmount) OVER () AS TotPrincipal, SUM(InterestAmount) OVER () AS TotInterest,
       MIN(ValueDate) OVER () AS MinVal, MAX(ValueDate) OVER () AS MaxVal
FROM Q
ORDER BY Id DESC;
```

DB: `NetTrexMM` · Server: `tcp:192.168.10.211,1433` · User: `trusr` · Pass: `***`


## #38

**Amaç:** Test MM: Yalnız vade bitiş — vade …–2025-10-31. API (ekran) sonucu ile karşılaştırma; TOP (20) satır alan alan, sayı/toplamlar pencere fonksiyonuyla tüm küme üzerinden.

```sql
SET NOCOUNT ON;
DECLARE @LD date = '2026-10-01';
WITH Q AS (
SELECT t.Id, t.LogicalReference, c.Name AS CounterpartyName, ROUND(t.DealAmount, 2) AS PrincipalAmount, t.Ccy AS Currency,
       CAST(t.ValueDate AS date) AS ValueDate, CAST(t.MaturityDate AS date) AS MaturityDate,
       ir.Rate AS InterestRate, ROUND(ia.Amt, 2) AS InterestAmount, ISNULL(tt.Name, t.TxnTypeCode) AS Direction, p.Name AS SubProductName
FROM TxnMM t
JOIN prdProductDefinition p ON p.Id = t.TxnMmProductTypeId AND p.IsEnabled = 1
OUTER APPLY (SELECT TOP (1) cu.Name FROM cusCustomer cu WHERE cu.Id = t.CustomerId) c
OUTER APPLY (SELECT TOP (1) x.Name FROM defTxnType x WHERE x.TxnTypeCode = t.TxnTypeCode) tt
OUTER APPLY (SELECT TOP (1) d.InterestRate AS Rate FROM txnMMDetail d WHERE d.TxnId = t.Id AND d.IsPrincipalAmount = 0 ORDER BY d.PeriodStartDate) ir
OUTER APPLY (SELECT SUM(d.Amount) AS Amt FROM txnMMDetail d WHERE d.TxnId = t.Id AND d.IsPrincipalAmount = 0) ia
WHERE (t.StateId & 6) = 2 AND t.MaturityDate < DATEADD(day, 1, CAST('2025-10-31' AS date))
)
SELECT TOP (20) Id, LogicalReference, CounterpartyName, PrincipalAmount, Currency, ValueDate, MaturityDate,
       DATEDIFF(day, ValueDate, MaturityDate) AS OriginalTenorDays,
       CASE WHEN MaturityDate < @LD THEN 0 ELSE DATEDIFF(day, @LD, MaturityDate) END AS DaysToMaturity,
       InterestRate, InterestAmount, Direction, SubProductName,
       COUNT(*) OVER () AS TotCnt, SUM(PrincipalAmount) OVER () AS TotPrincipal, SUM(InterestAmount) OVER () AS TotInterest,
       MIN(ValueDate) OVER () AS MinVal, MAX(ValueDate) OVER () AS MaxVal
FROM Q
ORDER BY Id DESC;
```

DB: `NetTrexMM` · Server: `tcp:192.168.10.211,1433` · User: `trusr` · Pass: `***`


## #39

**Amaç:** Test MM: Valör + vade birlikte — valör 2026-09-01–2026-09-30, vade 2026-11-01–2026-12-31. API (ekran) sonucu ile karşılaştırma; TOP (20) satır alan alan, sayı/toplamlar pencere fonksiyonuyla tüm küme üzerinden.

```sql
SET NOCOUNT ON;
DECLARE @LD date = '2026-10-01';
WITH Q AS (
SELECT t.Id, t.LogicalReference, c.Name AS CounterpartyName, ROUND(t.DealAmount, 2) AS PrincipalAmount, t.Ccy AS Currency,
       CAST(t.ValueDate AS date) AS ValueDate, CAST(t.MaturityDate AS date) AS MaturityDate,
       ir.Rate AS InterestRate, ROUND(ia.Amt, 2) AS InterestAmount, ISNULL(tt.Name, t.TxnTypeCode) AS Direction, p.Name AS SubProductName
FROM TxnMM t
JOIN prdProductDefinition p ON p.Id = t.TxnMmProductTypeId AND p.IsEnabled = 1
OUTER APPLY (SELECT TOP (1) cu.Name FROM cusCustomer cu WHERE cu.Id = t.CustomerId) c
OUTER APPLY (SELECT TOP (1) x.Name FROM defTxnType x WHERE x.TxnTypeCode = t.TxnTypeCode) tt
OUTER APPLY (SELECT TOP (1) d.InterestRate AS Rate FROM txnMMDetail d WHERE d.TxnId = t.Id AND d.IsPrincipalAmount = 0 ORDER BY d.PeriodStartDate) ir
OUTER APPLY (SELECT SUM(d.Amount) AS Amt FROM txnMMDetail d WHERE d.TxnId = t.Id AND d.IsPrincipalAmount = 0) ia
WHERE (t.StateId & 6) = 2 AND t.ValueDate >= '2026-09-01' AND t.ValueDate < DATEADD(day, 1, CAST('2026-09-30' AS date)) AND t.MaturityDate >= '2026-11-01' AND t.MaturityDate < DATEADD(day, 1, CAST('2026-12-31' AS date))
)
SELECT TOP (20) Id, LogicalReference, CounterpartyName, PrincipalAmount, Currency, ValueDate, MaturityDate,
       DATEDIFF(day, ValueDate, MaturityDate) AS OriginalTenorDays,
       CASE WHEN MaturityDate < @LD THEN 0 ELSE DATEDIFF(day, @LD, MaturityDate) END AS DaysToMaturity,
       InterestRate, InterestAmount, Direction, SubProductName,
       COUNT(*) OVER () AS TotCnt, SUM(PrincipalAmount) OVER () AS TotPrincipal, SUM(InterestAmount) OVER () AS TotInterest,
       MIN(ValueDate) OVER () AS MinVal, MAX(ValueDate) OVER () AS MaxVal
FROM Q
ORDER BY Id DESC;
```

DB: `NetTrexMM` · Server: `tcp:192.168.10.211,1433` · User: `trusr` · Pass: `***`


## #40

**Amaç:** Test MM: Tüm aralık, tüm alt ürünler — valör 2020-01-01–2030-12-31, vade 2020-01-01–2035-12-31. API (ekran) sonucu ile karşılaştırma; TOP (20) satır alan alan, sayı/toplamlar pencere fonksiyonuyla tüm küme üzerinden.

```sql
SET NOCOUNT ON;
DECLARE @LD date = '2026-10-01';
WITH Q AS (
SELECT t.Id, t.LogicalReference, c.Name AS CounterpartyName, ROUND(t.DealAmount, 2) AS PrincipalAmount, t.Ccy AS Currency,
       CAST(t.ValueDate AS date) AS ValueDate, CAST(t.MaturityDate AS date) AS MaturityDate,
       ir.Rate AS InterestRate, ROUND(ia.Amt, 2) AS InterestAmount, ISNULL(tt.Name, t.TxnTypeCode) AS Direction, p.Name AS SubProductName
FROM TxnMM t
JOIN prdProductDefinition p ON p.Id = t.TxnMmProductTypeId AND p.IsEnabled = 1
OUTER APPLY (SELECT TOP (1) cu.Name FROM cusCustomer cu WHERE cu.Id = t.CustomerId) c
OUTER APPLY (SELECT TOP (1) x.Name FROM defTxnType x WHERE x.TxnTypeCode = t.TxnTypeCode) tt
OUTER APPLY (SELECT TOP (1) d.InterestRate AS Rate FROM txnMMDetail d WHERE d.TxnId = t.Id AND d.IsPrincipalAmount = 0 ORDER BY d.PeriodStartDate) ir
OUTER APPLY (SELECT SUM(d.Amount) AS Amt FROM txnMMDetail d WHERE d.TxnId = t.Id AND d.IsPrincipalAmount = 0) ia
WHERE (t.StateId & 6) = 2 AND t.ValueDate >= '2020-01-01' AND t.ValueDate < DATEADD(day, 1, CAST('2030-12-31' AS date)) AND t.MaturityDate >= '2020-01-01' AND t.MaturityDate < DATEADD(day, 1, CAST('2035-12-31' AS date))
)
SELECT TOP (20) Id, LogicalReference, CounterpartyName, PrincipalAmount, Currency, ValueDate, MaturityDate,
       DATEDIFF(day, ValueDate, MaturityDate) AS OriginalTenorDays,
       CASE WHEN MaturityDate < @LD THEN 0 ELSE DATEDIFF(day, @LD, MaturityDate) END AS DaysToMaturity,
       InterestRate, InterestAmount, Direction, SubProductName,
       COUNT(*) OVER () AS TotCnt, SUM(PrincipalAmount) OVER () AS TotPrincipal, SUM(InterestAmount) OVER () AS TotInterest,
       MIN(ValueDate) OVER () AS MinVal, MAX(ValueDate) OVER () AS MaxVal
FROM Q
ORDER BY Id DESC;
```

DB: `NetTrexMM` · Server: `tcp:192.168.10.211,1433` · User: `trusr` · Pass: `***`


## #41

**Amaç:** Test MM: Alt ürün: Money Market — valör 2025-01-01–…, alt ürün [MoneyMarket]. API (ekran) sonucu ile karşılaştırma; TOP (20) satır alan alan, sayı/toplamlar pencere fonksiyonuyla tüm küme üzerinden.

```sql
SET NOCOUNT ON;
DECLARE @LD date = '2026-10-01';
WITH Q AS (
SELECT t.Id, t.LogicalReference, c.Name AS CounterpartyName, ROUND(t.DealAmount, 2) AS PrincipalAmount, t.Ccy AS Currency,
       CAST(t.ValueDate AS date) AS ValueDate, CAST(t.MaturityDate AS date) AS MaturityDate,
       ir.Rate AS InterestRate, ROUND(ia.Amt, 2) AS InterestAmount, ISNULL(tt.Name, t.TxnTypeCode) AS Direction, p.Name AS SubProductName
FROM TxnMM t
JOIN prdProductDefinition p ON p.Id = t.TxnMmProductTypeId AND p.IsEnabled = 1
OUTER APPLY (SELECT TOP (1) cu.Name FROM cusCustomer cu WHERE cu.Id = t.CustomerId) c
OUTER APPLY (SELECT TOP (1) x.Name FROM defTxnType x WHERE x.TxnTypeCode = t.TxnTypeCode) tt
OUTER APPLY (SELECT TOP (1) d.InterestRate AS Rate FROM txnMMDetail d WHERE d.TxnId = t.Id AND d.IsPrincipalAmount = 0 ORDER BY d.PeriodStartDate) ir
OUTER APPLY (SELECT SUM(d.Amount) AS Amt FROM txnMMDetail d WHERE d.TxnId = t.Id AND d.IsPrincipalAmount = 0) ia
WHERE (t.StateId & 6) = 2 AND t.ValueDate >= '2025-01-01' AND p.MainProductCode = 'MM' AND p.Code IN ('MoneyMarket')
)
SELECT TOP (20) Id, LogicalReference, CounterpartyName, PrincipalAmount, Currency, ValueDate, MaturityDate,
       DATEDIFF(day, ValueDate, MaturityDate) AS OriginalTenorDays,
       CASE WHEN MaturityDate < @LD THEN 0 ELSE DATEDIFF(day, @LD, MaturityDate) END AS DaysToMaturity,
       InterestRate, InterestAmount, Direction, SubProductName,
       COUNT(*) OVER () AS TotCnt, SUM(PrincipalAmount) OVER () AS TotPrincipal, SUM(InterestAmount) OVER () AS TotInterest,
       MIN(ValueDate) OVER () AS MinVal, MAX(ValueDate) OVER () AS MaxVal
FROM Q
ORDER BY Id DESC;
```

DB: `NetTrexMM` · Server: `tcp:192.168.10.211,1433` · User: `trusr` · Pass: `***`


## #42

**Amaç:** Test MM: Alt ürün: Murabaha — valör 2020-01-01–…, alt ürün [Murabaha]. API (ekran) sonucu ile karşılaştırma; TOP (20) satır alan alan, sayı/toplamlar pencere fonksiyonuyla tüm küme üzerinden.

```sql
SET NOCOUNT ON;
DECLARE @LD date = '2026-10-01';
WITH Q AS (
SELECT t.Id, t.LogicalReference, c.Name AS CounterpartyName, ROUND(t.DealAmount, 2) AS PrincipalAmount, t.Ccy AS Currency,
       CAST(t.ValueDate AS date) AS ValueDate, CAST(t.MaturityDate AS date) AS MaturityDate,
       ir.Rate AS InterestRate, ROUND(ia.Amt, 2) AS InterestAmount, ISNULL(tt.Name, t.TxnTypeCode) AS Direction, p.Name AS SubProductName
FROM TxnMM t
JOIN prdProductDefinition p ON p.Id = t.TxnMmProductTypeId AND p.IsEnabled = 1
OUTER APPLY (SELECT TOP (1) cu.Name FROM cusCustomer cu WHERE cu.Id = t.CustomerId) c
OUTER APPLY (SELECT TOP (1) x.Name FROM defTxnType x WHERE x.TxnTypeCode = t.TxnTypeCode) tt
OUTER APPLY (SELECT TOP (1) d.InterestRate AS Rate FROM txnMMDetail d WHERE d.TxnId = t.Id AND d.IsPrincipalAmount = 0 ORDER BY d.PeriodStartDate) ir
OUTER APPLY (SELECT SUM(d.Amount) AS Amt FROM txnMMDetail d WHERE d.TxnId = t.Id AND d.IsPrincipalAmount = 0) ia
WHERE (t.StateId & 6) = 2 AND t.ValueDate >= '2020-01-01' AND p.MainProductCode = 'MM' AND p.Code IN ('Murabaha')
)
SELECT TOP (20) Id, LogicalReference, CounterpartyName, PrincipalAmount, Currency, ValueDate, MaturityDate,
       DATEDIFF(day, ValueDate, MaturityDate) AS OriginalTenorDays,
       CASE WHEN MaturityDate < @LD THEN 0 ELSE DATEDIFF(day, @LD, MaturityDate) END AS DaysToMaturity,
       InterestRate, InterestAmount, Direction, SubProductName,
       COUNT(*) OVER () AS TotCnt, SUM(PrincipalAmount) OVER () AS TotPrincipal, SUM(InterestAmount) OVER () AS TotInterest,
       MIN(ValueDate) OVER () AS MinVal, MAX(ValueDate) OVER () AS MaxVal
FROM Q
ORDER BY Id DESC;
```

DB: `NetTrexMM` · Server: `tcp:192.168.10.211,1433` · User: `trusr` · Pass: `***`


## #43

**Amaç:** Test MM: Alt ürün: Wakale + Loan — valör 2020-01-01–…, alt ürün [Wakale,Loan]. API (ekran) sonucu ile karşılaştırma; TOP (20) satır alan alan, sayı/toplamlar pencere fonksiyonuyla tüm küme üzerinden.

```sql
SET NOCOUNT ON;
DECLARE @LD date = '2026-10-01';
WITH Q AS (
SELECT t.Id, t.LogicalReference, c.Name AS CounterpartyName, ROUND(t.DealAmount, 2) AS PrincipalAmount, t.Ccy AS Currency,
       CAST(t.ValueDate AS date) AS ValueDate, CAST(t.MaturityDate AS date) AS MaturityDate,
       ir.Rate AS InterestRate, ROUND(ia.Amt, 2) AS InterestAmount, ISNULL(tt.Name, t.TxnTypeCode) AS Direction, p.Name AS SubProductName
FROM TxnMM t
JOIN prdProductDefinition p ON p.Id = t.TxnMmProductTypeId AND p.IsEnabled = 1
OUTER APPLY (SELECT TOP (1) cu.Name FROM cusCustomer cu WHERE cu.Id = t.CustomerId) c
OUTER APPLY (SELECT TOP (1) x.Name FROM defTxnType x WHERE x.TxnTypeCode = t.TxnTypeCode) tt
OUTER APPLY (SELECT TOP (1) d.InterestRate AS Rate FROM txnMMDetail d WHERE d.TxnId = t.Id AND d.IsPrincipalAmount = 0 ORDER BY d.PeriodStartDate) ir
OUTER APPLY (SELECT SUM(d.Amount) AS Amt FROM txnMMDetail d WHERE d.TxnId = t.Id AND d.IsPrincipalAmount = 0) ia
WHERE (t.StateId & 6) = 2 AND t.ValueDate >= '2020-01-01' AND p.MainProductCode = 'MM' AND p.Code IN ('Wakale', 'Loan')
)
SELECT TOP (20) Id, LogicalReference, CounterpartyName, PrincipalAmount, Currency, ValueDate, MaturityDate,
       DATEDIFF(day, ValueDate, MaturityDate) AS OriginalTenorDays,
       CASE WHEN MaturityDate < @LD THEN 0 ELSE DATEDIFF(day, @LD, MaturityDate) END AS DaysToMaturity,
       InterestRate, InterestAmount, Direction, SubProductName,
       COUNT(*) OVER () AS TotCnt, SUM(PrincipalAmount) OVER () AS TotPrincipal, SUM(InterestAmount) OVER () AS TotInterest,
       MIN(ValueDate) OVER () AS MinVal, MAX(ValueDate) OVER () AS MaxVal
FROM Q
ORDER BY Id DESC;
```

DB: `NetTrexMM` · Server: `tcp:192.168.10.211,1433` · User: `trusr` · Pass: `***`


## #44

**Amaç:** Test MM: Alt ürün: veri olmayan (Bond Issue) — valör 2020-01-01–…, alt ürün [Issue]. API (ekran) sonucu ile karşılaştırma; TOP (20) satır alan alan, sayı/toplamlar pencere fonksiyonuyla tüm küme üzerinden.

```sql
SET NOCOUNT ON;
DECLARE @LD date = '2026-10-01';
WITH Q AS (
SELECT t.Id, t.LogicalReference, c.Name AS CounterpartyName, ROUND(t.DealAmount, 2) AS PrincipalAmount, t.Ccy AS Currency,
       CAST(t.ValueDate AS date) AS ValueDate, CAST(t.MaturityDate AS date) AS MaturityDate,
       ir.Rate AS InterestRate, ROUND(ia.Amt, 2) AS InterestAmount, ISNULL(tt.Name, t.TxnTypeCode) AS Direction, p.Name AS SubProductName
FROM TxnMM t
JOIN prdProductDefinition p ON p.Id = t.TxnMmProductTypeId AND p.IsEnabled = 1
OUTER APPLY (SELECT TOP (1) cu.Name FROM cusCustomer cu WHERE cu.Id = t.CustomerId) c
OUTER APPLY (SELECT TOP (1) x.Name FROM defTxnType x WHERE x.TxnTypeCode = t.TxnTypeCode) tt
OUTER APPLY (SELECT TOP (1) d.InterestRate AS Rate FROM txnMMDetail d WHERE d.TxnId = t.Id AND d.IsPrincipalAmount = 0 ORDER BY d.PeriodStartDate) ir
OUTER APPLY (SELECT SUM(d.Amount) AS Amt FROM txnMMDetail d WHERE d.TxnId = t.Id AND d.IsPrincipalAmount = 0) ia
WHERE (t.StateId & 6) = 2 AND t.ValueDate >= '2020-01-01' AND p.MainProductCode = 'MM' AND p.Code IN ('Issue')
)
SELECT TOP (20) Id, LogicalReference, CounterpartyName, PrincipalAmount, Currency, ValueDate, MaturityDate,
       DATEDIFF(day, ValueDate, MaturityDate) AS OriginalTenorDays,
       CASE WHEN MaturityDate < @LD THEN 0 ELSE DATEDIFF(day, @LD, MaturityDate) END AS DaysToMaturity,
       InterestRate, InterestAmount, Direction, SubProductName,
       COUNT(*) OVER () AS TotCnt, SUM(PrincipalAmount) OVER () AS TotPrincipal, SUM(InterestAmount) OVER () AS TotInterest,
       MIN(ValueDate) OVER () AS MinVal, MAX(ValueDate) OVER () AS MaxVal
FROM Q
ORDER BY Id DESC;
```

DB: `NetTrexMM` · Server: `tcp:192.168.10.211,1433` · User: `trusr` · Pass: `***`


## #45

**Amaç:** Test MM: Alt ürün: pasif ürün (TermDeposit) — valör 2020-01-01–…, alt ürün [TermDeposit]. API (ekran) sonucu ile karşılaştırma; TOP (20) satır alan alan, sayı/toplamlar pencere fonksiyonuyla tüm küme üzerinden.

```sql
SET NOCOUNT ON;
DECLARE @LD date = '2026-10-01';
WITH Q AS (
SELECT t.Id, t.LogicalReference, c.Name AS CounterpartyName, ROUND(t.DealAmount, 2) AS PrincipalAmount, t.Ccy AS Currency,
       CAST(t.ValueDate AS date) AS ValueDate, CAST(t.MaturityDate AS date) AS MaturityDate,
       ir.Rate AS InterestRate, ROUND(ia.Amt, 2) AS InterestAmount, ISNULL(tt.Name, t.TxnTypeCode) AS Direction, p.Name AS SubProductName
FROM TxnMM t
JOIN prdProductDefinition p ON p.Id = t.TxnMmProductTypeId AND p.IsEnabled = 1
OUTER APPLY (SELECT TOP (1) cu.Name FROM cusCustomer cu WHERE cu.Id = t.CustomerId) c
OUTER APPLY (SELECT TOP (1) x.Name FROM defTxnType x WHERE x.TxnTypeCode = t.TxnTypeCode) tt
OUTER APPLY (SELECT TOP (1) d.InterestRate AS Rate FROM txnMMDetail d WHERE d.TxnId = t.Id AND d.IsPrincipalAmount = 0 ORDER BY d.PeriodStartDate) ir
OUTER APPLY (SELECT SUM(d.Amount) AS Amt FROM txnMMDetail d WHERE d.TxnId = t.Id AND d.IsPrincipalAmount = 0) ia
WHERE (t.StateId & 6) = 2 AND t.ValueDate >= '2020-01-01' AND p.MainProductCode = 'MM' AND p.Code IN ('TermDeposit')
)
SELECT TOP (20) Id, LogicalReference, CounterpartyName, PrincipalAmount, Currency, ValueDate, MaturityDate,
       DATEDIFF(day, ValueDate, MaturityDate) AS OriginalTenorDays,
       CASE WHEN MaturityDate < @LD THEN 0 ELSE DATEDIFF(day, @LD, MaturityDate) END AS DaysToMaturity,
       InterestRate, InterestAmount, Direction, SubProductName,
       COUNT(*) OVER () AS TotCnt, SUM(PrincipalAmount) OVER () AS TotPrincipal, SUM(InterestAmount) OVER () AS TotInterest,
       MIN(ValueDate) OVER () AS MinVal, MAX(ValueDate) OVER () AS MaxVal
FROM Q
ORDER BY Id DESC;
```

DB: `NetTrexMM` · Server: `tcp:192.168.10.211,1433` · User: `trusr` · Pass: `***`


## #46

**Amaç:** Test MM: Yalnız referans (tarih yok) — ref 'TMMPLC2609'. API (ekran) sonucu ile karşılaştırma; TOP (20) satır alan alan, sayı/toplamlar pencere fonksiyonuyla tüm küme üzerinden.

```sql
SET NOCOUNT ON;
DECLARE @LD date = '2026-10-01';
WITH Q AS (
SELECT t.Id, t.LogicalReference, c.Name AS CounterpartyName, ROUND(t.DealAmount, 2) AS PrincipalAmount, t.Ccy AS Currency,
       CAST(t.ValueDate AS date) AS ValueDate, CAST(t.MaturityDate AS date) AS MaturityDate,
       ir.Rate AS InterestRate, ROUND(ia.Amt, 2) AS InterestAmount, ISNULL(tt.Name, t.TxnTypeCode) AS Direction, p.Name AS SubProductName
FROM TxnMM t
JOIN prdProductDefinition p ON p.Id = t.TxnMmProductTypeId AND p.IsEnabled = 1
OUTER APPLY (SELECT TOP (1) cu.Name FROM cusCustomer cu WHERE cu.Id = t.CustomerId) c
OUTER APPLY (SELECT TOP (1) x.Name FROM defTxnType x WHERE x.TxnTypeCode = t.TxnTypeCode) tt
OUTER APPLY (SELECT TOP (1) d.InterestRate AS Rate FROM txnMMDetail d WHERE d.TxnId = t.Id AND d.IsPrincipalAmount = 0 ORDER BY d.PeriodStartDate) ir
OUTER APPLY (SELECT SUM(d.Amount) AS Amt FROM txnMMDetail d WHERE d.TxnId = t.Id AND d.IsPrincipalAmount = 0) ia
WHERE (t.StateId & 6) = 2 AND t.LogicalReference LIKE '%TMMPLC2609%'
)
SELECT TOP (20) Id, LogicalReference, CounterpartyName, PrincipalAmount, Currency, ValueDate, MaturityDate,
       DATEDIFF(day, ValueDate, MaturityDate) AS OriginalTenorDays,
       CASE WHEN MaturityDate < @LD THEN 0 ELSE DATEDIFF(day, @LD, MaturityDate) END AS DaysToMaturity,
       InterestRate, InterestAmount, Direction, SubProductName,
       COUNT(*) OVER () AS TotCnt, SUM(PrincipalAmount) OVER () AS TotPrincipal, SUM(InterestAmount) OVER () AS TotInterest,
       MIN(ValueDate) OVER () AS MinVal, MAX(ValueDate) OVER () AS MaxVal
FROM Q
ORDER BY Id DESC;
```

DB: `NetTrexMM` · Server: `tcp:192.168.10.211,1433` · User: `trusr` · Pass: `***`


## #47

**Amaç:** Test MM: Referans + tarih — valör 2026-09-01–2026-09-30, ref 'BRW'. API (ekran) sonucu ile karşılaştırma; TOP (20) satır alan alan, sayı/toplamlar pencere fonksiyonuyla tüm küme üzerinden.

```sql
SET NOCOUNT ON;
DECLARE @LD date = '2026-10-01';
WITH Q AS (
SELECT t.Id, t.LogicalReference, c.Name AS CounterpartyName, ROUND(t.DealAmount, 2) AS PrincipalAmount, t.Ccy AS Currency,
       CAST(t.ValueDate AS date) AS ValueDate, CAST(t.MaturityDate AS date) AS MaturityDate,
       ir.Rate AS InterestRate, ROUND(ia.Amt, 2) AS InterestAmount, ISNULL(tt.Name, t.TxnTypeCode) AS Direction, p.Name AS SubProductName
FROM TxnMM t
JOIN prdProductDefinition p ON p.Id = t.TxnMmProductTypeId AND p.IsEnabled = 1
OUTER APPLY (SELECT TOP (1) cu.Name FROM cusCustomer cu WHERE cu.Id = t.CustomerId) c
OUTER APPLY (SELECT TOP (1) x.Name FROM defTxnType x WHERE x.TxnTypeCode = t.TxnTypeCode) tt
OUTER APPLY (SELECT TOP (1) d.InterestRate AS Rate FROM txnMMDetail d WHERE d.TxnId = t.Id AND d.IsPrincipalAmount = 0 ORDER BY d.PeriodStartDate) ir
OUTER APPLY (SELECT SUM(d.Amount) AS Amt FROM txnMMDetail d WHERE d.TxnId = t.Id AND d.IsPrincipalAmount = 0) ia
WHERE (t.StateId & 6) = 2 AND t.ValueDate >= '2026-09-01' AND t.ValueDate < DATEADD(day, 1, CAST('2026-09-30' AS date)) AND t.LogicalReference LIKE '%BRW%'
)
SELECT TOP (20) Id, LogicalReference, CounterpartyName, PrincipalAmount, Currency, ValueDate, MaturityDate,
       DATEDIFF(day, ValueDate, MaturityDate) AS OriginalTenorDays,
       CASE WHEN MaturityDate < @LD THEN 0 ELSE DATEDIFF(day, @LD, MaturityDate) END AS DaysToMaturity,
       InterestRate, InterestAmount, Direction, SubProductName,
       COUNT(*) OVER () AS TotCnt, SUM(PrincipalAmount) OVER () AS TotPrincipal, SUM(InterestAmount) OVER () AS TotInterest,
       MIN(ValueDate) OVER () AS MinVal, MAX(ValueDate) OVER () AS MaxVal
FROM Q
ORDER BY Id DESC;
```

DB: `NetTrexMM` · Server: `tcp:192.168.10.211,1433` · User: `trusr` · Pass: `***`


## #48

**Amaç:** Test MM: Tam referans — ref 'TMMBRW2609110002'. API (ekran) sonucu ile karşılaştırma; TOP (20) satır alan alan, sayı/toplamlar pencere fonksiyonuyla tüm küme üzerinden.

```sql
SET NOCOUNT ON;
DECLARE @LD date = '2026-10-01';
WITH Q AS (
SELECT t.Id, t.LogicalReference, c.Name AS CounterpartyName, ROUND(t.DealAmount, 2) AS PrincipalAmount, t.Ccy AS Currency,
       CAST(t.ValueDate AS date) AS ValueDate, CAST(t.MaturityDate AS date) AS MaturityDate,
       ir.Rate AS InterestRate, ROUND(ia.Amt, 2) AS InterestAmount, ISNULL(tt.Name, t.TxnTypeCode) AS Direction, p.Name AS SubProductName
FROM TxnMM t
JOIN prdProductDefinition p ON p.Id = t.TxnMmProductTypeId AND p.IsEnabled = 1
OUTER APPLY (SELECT TOP (1) cu.Name FROM cusCustomer cu WHERE cu.Id = t.CustomerId) c
OUTER APPLY (SELECT TOP (1) x.Name FROM defTxnType x WHERE x.TxnTypeCode = t.TxnTypeCode) tt
OUTER APPLY (SELECT TOP (1) d.InterestRate AS Rate FROM txnMMDetail d WHERE d.TxnId = t.Id AND d.IsPrincipalAmount = 0 ORDER BY d.PeriodStartDate) ir
OUTER APPLY (SELECT SUM(d.Amount) AS Amt FROM txnMMDetail d WHERE d.TxnId = t.Id AND d.IsPrincipalAmount = 0) ia
WHERE (t.StateId & 6) = 2 AND t.LogicalReference LIKE '%TMMBRW2609110002%'
)
SELECT TOP (20) Id, LogicalReference, CounterpartyName, PrincipalAmount, Currency, ValueDate, MaturityDate,
       DATEDIFF(day, ValueDate, MaturityDate) AS OriginalTenorDays,
       CASE WHEN MaturityDate < @LD THEN 0 ELSE DATEDIFF(day, @LD, MaturityDate) END AS DaysToMaturity,
       InterestRate, InterestAmount, Direction, SubProductName,
       COUNT(*) OVER () AS TotCnt, SUM(PrincipalAmount) OVER () AS TotPrincipal, SUM(InterestAmount) OVER () AS TotInterest,
       MIN(ValueDate) OVER () AS MinVal, MAX(ValueDate) OVER () AS MaxVal
FROM Q
ORDER BY Id DESC;
```

DB: `NetTrexMM` · Server: `tcp:192.168.10.211,1433` · User: `trusr` · Pass: `***`


## #49

**Amaç:** Test MM: Olmayan referans — ref 'YOKBOYLEREF'. API (ekran) sonucu ile karşılaştırma; TOP (20) satır alan alan, sayı/toplamlar pencere fonksiyonuyla tüm küme üzerinden.

```sql
SET NOCOUNT ON;
DECLARE @LD date = '2026-10-01';
WITH Q AS (
SELECT t.Id, t.LogicalReference, c.Name AS CounterpartyName, ROUND(t.DealAmount, 2) AS PrincipalAmount, t.Ccy AS Currency,
       CAST(t.ValueDate AS date) AS ValueDate, CAST(t.MaturityDate AS date) AS MaturityDate,
       ir.Rate AS InterestRate, ROUND(ia.Amt, 2) AS InterestAmount, ISNULL(tt.Name, t.TxnTypeCode) AS Direction, p.Name AS SubProductName
FROM TxnMM t
JOIN prdProductDefinition p ON p.Id = t.TxnMmProductTypeId AND p.IsEnabled = 1
OUTER APPLY (SELECT TOP (1) cu.Name FROM cusCustomer cu WHERE cu.Id = t.CustomerId) c
OUTER APPLY (SELECT TOP (1) x.Name FROM defTxnType x WHERE x.TxnTypeCode = t.TxnTypeCode) tt
OUTER APPLY (SELECT TOP (1) d.InterestRate AS Rate FROM txnMMDetail d WHERE d.TxnId = t.Id AND d.IsPrincipalAmount = 0 ORDER BY d.PeriodStartDate) ir
OUTER APPLY (SELECT SUM(d.Amount) AS Amt FROM txnMMDetail d WHERE d.TxnId = t.Id AND d.IsPrincipalAmount = 0) ia
WHERE (t.StateId & 6) = 2 AND t.LogicalReference LIKE '%YOKBOYLEREF%'
)
SELECT TOP (20) Id, LogicalReference, CounterpartyName, PrincipalAmount, Currency, ValueDate, MaturityDate,
       DATEDIFF(day, ValueDate, MaturityDate) AS OriginalTenorDays,
       CASE WHEN MaturityDate < @LD THEN 0 ELSE DATEDIFF(day, @LD, MaturityDate) END AS DaysToMaturity,
       InterestRate, InterestAmount, Direction, SubProductName,
       COUNT(*) OVER () AS TotCnt, SUM(PrincipalAmount) OVER () AS TotPrincipal, SUM(InterestAmount) OVER () AS TotInterest,
       MIN(ValueDate) OVER () AS MinVal, MAX(ValueDate) OVER () AS MaxVal
FROM Q
ORDER BY Id DESC;
```

DB: `NetTrexMM` · Server: `tcp:192.168.10.211,1433` · User: `trusr` · Pass: `***`


## #50

**Amaç:** Test MM: Ekran varsayılanı (bu ay) — valör 2026-10-01–2026-10-31. API (ekran) sonucu ile karşılaştırma; TOP (20) satır alan alan, sayı/toplamlar pencere fonksiyonuyla tüm küme üzerinden.

```sql
SET NOCOUNT ON;
DECLARE @LD date = '2026-10-01';
WITH Q AS (
SELECT t.Id, t.LogicalReference, c.Name AS CounterpartyName, ROUND(t.DealAmount, 2) AS PrincipalAmount, t.Ccy AS Currency,
       CAST(t.ValueDate AS date) AS ValueDate, CAST(t.MaturityDate AS date) AS MaturityDate,
       ir.Rate AS InterestRate, ROUND(ia.Amt, 2) AS InterestAmount, ISNULL(tt.Name, t.TxnTypeCode) AS Direction, p.Name AS SubProductName
FROM TxnMM t
JOIN prdProductDefinition p ON p.Id = t.TxnMmProductTypeId AND p.IsEnabled = 1
OUTER APPLY (SELECT TOP (1) cu.Name FROM cusCustomer cu WHERE cu.Id = t.CustomerId) c
OUTER APPLY (SELECT TOP (1) x.Name FROM defTxnType x WHERE x.TxnTypeCode = t.TxnTypeCode) tt
OUTER APPLY (SELECT TOP (1) d.InterestRate AS Rate FROM txnMMDetail d WHERE d.TxnId = t.Id AND d.IsPrincipalAmount = 0 ORDER BY d.PeriodStartDate) ir
OUTER APPLY (SELECT SUM(d.Amount) AS Amt FROM txnMMDetail d WHERE d.TxnId = t.Id AND d.IsPrincipalAmount = 0) ia
WHERE (t.StateId & 6) = 2 AND t.ValueDate >= '2026-10-01' AND t.ValueDate < DATEADD(day, 1, CAST('2026-10-31' AS date))
)
SELECT TOP (20) Id, LogicalReference, CounterpartyName, PrincipalAmount, Currency, ValueDate, MaturityDate,
       DATEDIFF(day, ValueDate, MaturityDate) AS OriginalTenorDays,
       CASE WHEN MaturityDate < @LD THEN 0 ELSE DATEDIFF(day, @LD, MaturityDate) END AS DaysToMaturity,
       InterestRate, InterestAmount, Direction, SubProductName,
       COUNT(*) OVER () AS TotCnt, SUM(PrincipalAmount) OVER () AS TotPrincipal, SUM(InterestAmount) OVER () AS TotInterest,
       MIN(ValueDate) OVER () AS MinVal, MAX(ValueDate) OVER () AS MaxVal
FROM Q
ORDER BY Id DESC;
```

DB: `NetTrexMM` · Server: `tcp:192.168.10.211,1433` · User: `trusr` · Pass: `***`


## #51

**Amaç:** Test MM: Eylül 2026 valör — valör 2026-09-01–2026-09-30. API (ekran) sonucu ile karşılaştırma; TOP (20) satır alan alan, sayı/toplamlar pencere fonksiyonuyla tüm küme üzerinden.

```sql
SET NOCOUNT ON;
DECLARE @LD date = '2026-10-01';
WITH Q AS (
SELECT t.Id, t.LogicalReference, c.Name AS CounterpartyName, ROUND(t.DealAmount, 2) AS PrincipalAmount, t.Ccy AS Currency,
       CAST(t.ValueDate AS date) AS ValueDate, CAST(t.MaturityDate AS date) AS MaturityDate,
       ir.Rate AS InterestRate, ROUND(ia.Amt, 2) AS InterestAmount, ISNULL(tt.Name, t.TxnTypeCode) AS Direction, p.Name AS SubProductName
FROM TxnMM t
JOIN prdProductDefinition p ON p.Id = t.TxnMmProductTypeId AND p.IsEnabled = 1
OUTER APPLY (SELECT TOP (1) cu.Name FROM cusCustomer cu WHERE cu.Id = t.CustomerId) c
OUTER APPLY (SELECT TOP (1) x.Name FROM defTxnType x WHERE x.TxnTypeCode = t.TxnTypeCode) tt
OUTER APPLY (SELECT TOP (1) d.InterestRate AS Rate FROM txnMMDetail d WHERE d.TxnId = t.Id AND d.IsPrincipalAmount = 0 ORDER BY d.PeriodStartDate) ir
OUTER APPLY (SELECT SUM(d.Amount) AS Amt FROM txnMMDetail d WHERE d.TxnId = t.Id AND d.IsPrincipalAmount = 0) ia
WHERE (t.StateId & 6) = 2 AND t.ValueDate >= '2026-09-01' AND t.ValueDate < DATEADD(day, 1, CAST('2026-09-30' AS date))
)
SELECT TOP (20) Id, LogicalReference, CounterpartyName, PrincipalAmount, Currency, ValueDate, MaturityDate,
       DATEDIFF(day, ValueDate, MaturityDate) AS OriginalTenorDays,
       CASE WHEN MaturityDate < @LD THEN 0 ELSE DATEDIFF(day, @LD, MaturityDate) END AS DaysToMaturity,
       InterestRate, InterestAmount, Direction, SubProductName,
       COUNT(*) OVER () AS TotCnt, SUM(PrincipalAmount) OVER () AS TotPrincipal, SUM(InterestAmount) OVER () AS TotInterest,
       MIN(ValueDate) OVER () AS MinVal, MAX(ValueDate) OVER () AS MaxVal
FROM Q
ORDER BY Id DESC;
```

DB: `NetTrexMM` · Server: `tcp:192.168.10.211,1433` · User: `trusr` · Pass: `***`


## #52

**Amaç:** Test MM: Yalnız valör başlangıç — valör 2026-09-15–…. API (ekran) sonucu ile karşılaştırma; TOP (20) satır alan alan, sayı/toplamlar pencere fonksiyonuyla tüm küme üzerinden.

```sql
SET NOCOUNT ON;
DECLARE @LD date = '2026-10-01';
WITH Q AS (
SELECT t.Id, t.LogicalReference, c.Name AS CounterpartyName, ROUND(t.DealAmount, 2) AS PrincipalAmount, t.Ccy AS Currency,
       CAST(t.ValueDate AS date) AS ValueDate, CAST(t.MaturityDate AS date) AS MaturityDate,
       ir.Rate AS InterestRate, ROUND(ia.Amt, 2) AS InterestAmount, ISNULL(tt.Name, t.TxnTypeCode) AS Direction, p.Name AS SubProductName
FROM TxnMM t
JOIN prdProductDefinition p ON p.Id = t.TxnMmProductTypeId AND p.IsEnabled = 1
OUTER APPLY (SELECT TOP (1) cu.Name FROM cusCustomer cu WHERE cu.Id = t.CustomerId) c
OUTER APPLY (SELECT TOP (1) x.Name FROM defTxnType x WHERE x.TxnTypeCode = t.TxnTypeCode) tt
OUTER APPLY (SELECT TOP (1) d.InterestRate AS Rate FROM txnMMDetail d WHERE d.TxnId = t.Id AND d.IsPrincipalAmount = 0 ORDER BY d.PeriodStartDate) ir
OUTER APPLY (SELECT SUM(d.Amount) AS Amt FROM txnMMDetail d WHERE d.TxnId = t.Id AND d.IsPrincipalAmount = 0) ia
WHERE (t.StateId & 6) = 2 AND t.ValueDate >= '2026-09-15'
)
SELECT TOP (20) Id, LogicalReference, CounterpartyName, PrincipalAmount, Currency, ValueDate, MaturityDate,
       DATEDIFF(day, ValueDate, MaturityDate) AS OriginalTenorDays,
       CASE WHEN MaturityDate < @LD THEN 0 ELSE DATEDIFF(day, @LD, MaturityDate) END AS DaysToMaturity,
       InterestRate, InterestAmount, Direction, SubProductName,
       COUNT(*) OVER () AS TotCnt, SUM(PrincipalAmount) OVER () AS TotPrincipal, SUM(InterestAmount) OVER () AS TotInterest,
       MIN(ValueDate) OVER () AS MinVal, MAX(ValueDate) OVER () AS MaxVal
FROM Q
ORDER BY Id DESC;
```

DB: `NetTrexMM` · Server: `tcp:192.168.10.211,1433` · User: `trusr` · Pass: `***`


## #53

**Amaç:** Test MM: Yalnız valör bitiş — valör …–2025-09-30. API (ekran) sonucu ile karşılaştırma; TOP (20) satır alan alan, sayı/toplamlar pencere fonksiyonuyla tüm küme üzerinden.

```sql
SET NOCOUNT ON;
DECLARE @LD date = '2026-10-01';
WITH Q AS (
SELECT t.Id, t.LogicalReference, c.Name AS CounterpartyName, ROUND(t.DealAmount, 2) AS PrincipalAmount, t.Ccy AS Currency,
       CAST(t.ValueDate AS date) AS ValueDate, CAST(t.MaturityDate AS date) AS MaturityDate,
       ir.Rate AS InterestRate, ROUND(ia.Amt, 2) AS InterestAmount, ISNULL(tt.Name, t.TxnTypeCode) AS Direction, p.Name AS SubProductName
FROM TxnMM t
JOIN prdProductDefinition p ON p.Id = t.TxnMmProductTypeId AND p.IsEnabled = 1
OUTER APPLY (SELECT TOP (1) cu.Name FROM cusCustomer cu WHERE cu.Id = t.CustomerId) c
OUTER APPLY (SELECT TOP (1) x.Name FROM defTxnType x WHERE x.TxnTypeCode = t.TxnTypeCode) tt
OUTER APPLY (SELECT TOP (1) d.InterestRate AS Rate FROM txnMMDetail d WHERE d.TxnId = t.Id AND d.IsPrincipalAmount = 0 ORDER BY d.PeriodStartDate) ir
OUTER APPLY (SELECT SUM(d.Amount) AS Amt FROM txnMMDetail d WHERE d.TxnId = t.Id AND d.IsPrincipalAmount = 0) ia
WHERE (t.StateId & 6) = 2 AND t.ValueDate < DATEADD(day, 1, CAST('2025-09-30' AS date))
)
SELECT TOP (20) Id, LogicalReference, CounterpartyName, PrincipalAmount, Currency, ValueDate, MaturityDate,
       DATEDIFF(day, ValueDate, MaturityDate) AS OriginalTenorDays,
       CASE WHEN MaturityDate < @LD THEN 0 ELSE DATEDIFF(day, @LD, MaturityDate) END AS DaysToMaturity,
       InterestRate, InterestAmount, Direction, SubProductName,
       COUNT(*) OVER () AS TotCnt, SUM(PrincipalAmount) OVER () AS TotPrincipal, SUM(InterestAmount) OVER () AS TotInterest,
       MIN(ValueDate) OVER () AS MinVal, MAX(ValueDate) OVER () AS MaxVal
FROM Q
ORDER BY Id DESC;
```

DB: `NetTrexMM` · Server: `tcp:192.168.10.211,1433` · User: `trusr` · Pass: `***`


## #54

**Amaç:** Test MM: Tek gün valör (iki uç dahil) — valör 2026-09-18–2026-09-18. API (ekran) sonucu ile karşılaştırma; TOP (20) satır alan alan, sayı/toplamlar pencere fonksiyonuyla tüm küme üzerinden.

```sql
SET NOCOUNT ON;
DECLARE @LD date = '2026-10-01';
WITH Q AS (
SELECT t.Id, t.LogicalReference, c.Name AS CounterpartyName, ROUND(t.DealAmount, 2) AS PrincipalAmount, t.Ccy AS Currency,
       CAST(t.ValueDate AS date) AS ValueDate, CAST(t.MaturityDate AS date) AS MaturityDate,
       ir.Rate AS InterestRate, ROUND(ia.Amt, 2) AS InterestAmount, ISNULL(tt.Name, t.TxnTypeCode) AS Direction, p.Name AS SubProductName
FROM TxnMM t
JOIN prdProductDefinition p ON p.Id = t.TxnMmProductTypeId AND p.IsEnabled = 1
OUTER APPLY (SELECT TOP (1) cu.Name FROM cusCustomer cu WHERE cu.Id = t.CustomerId) c
OUTER APPLY (SELECT TOP (1) x.Name FROM defTxnType x WHERE x.TxnTypeCode = t.TxnTypeCode) tt
OUTER APPLY (SELECT TOP (1) d.InterestRate AS Rate FROM txnMMDetail d WHERE d.TxnId = t.Id AND d.IsPrincipalAmount = 0 ORDER BY d.PeriodStartDate) ir
OUTER APPLY (SELECT SUM(d.Amount) AS Amt FROM txnMMDetail d WHERE d.TxnId = t.Id AND d.IsPrincipalAmount = 0) ia
WHERE (t.StateId & 6) = 2 AND t.ValueDate >= '2026-09-18' AND t.ValueDate < DATEADD(day, 1, CAST('2026-09-18' AS date))
)
SELECT TOP (20) Id, LogicalReference, CounterpartyName, PrincipalAmount, Currency, ValueDate, MaturityDate,
       DATEDIFF(day, ValueDate, MaturityDate) AS OriginalTenorDays,
       CASE WHEN MaturityDate < @LD THEN 0 ELSE DATEDIFF(day, @LD, MaturityDate) END AS DaysToMaturity,
       InterestRate, InterestAmount, Direction, SubProductName,
       COUNT(*) OVER () AS TotCnt, SUM(PrincipalAmount) OVER () AS TotPrincipal, SUM(InterestAmount) OVER () AS TotInterest,
       MIN(ValueDate) OVER () AS MinVal, MAX(ValueDate) OVER () AS MaxVal
FROM Q
ORDER BY Id DESC;
```

DB: `NetTrexMM` · Server: `tcp:192.168.10.211,1433` · User: `trusr` · Pass: `***`


## #55

**Amaç:** Test MM: Ay sonu sınırı (30.09 dahil) — valör 2026-09-30–2026-09-30. API (ekran) sonucu ile karşılaştırma; TOP (20) satır alan alan, sayı/toplamlar pencere fonksiyonuyla tüm küme üzerinden.

```sql
SET NOCOUNT ON;
DECLARE @LD date = '2026-10-01';
WITH Q AS (
SELECT t.Id, t.LogicalReference, c.Name AS CounterpartyName, ROUND(t.DealAmount, 2) AS PrincipalAmount, t.Ccy AS Currency,
       CAST(t.ValueDate AS date) AS ValueDate, CAST(t.MaturityDate AS date) AS MaturityDate,
       ir.Rate AS InterestRate, ROUND(ia.Amt, 2) AS InterestAmount, ISNULL(tt.Name, t.TxnTypeCode) AS Direction, p.Name AS SubProductName
FROM TxnMM t
JOIN prdProductDefinition p ON p.Id = t.TxnMmProductTypeId AND p.IsEnabled = 1
OUTER APPLY (SELECT TOP (1) cu.Name FROM cusCustomer cu WHERE cu.Id = t.CustomerId) c
OUTER APPLY (SELECT TOP (1) x.Name FROM defTxnType x WHERE x.TxnTypeCode = t.TxnTypeCode) tt
OUTER APPLY (SELECT TOP (1) d.InterestRate AS Rate FROM txnMMDetail d WHERE d.TxnId = t.Id AND d.IsPrincipalAmount = 0 ORDER BY d.PeriodStartDate) ir
OUTER APPLY (SELECT SUM(d.Amount) AS Amt FROM txnMMDetail d WHERE d.TxnId = t.Id AND d.IsPrincipalAmount = 0) ia
WHERE (t.StateId & 6) = 2 AND t.ValueDate >= '2026-09-30' AND t.ValueDate < DATEADD(day, 1, CAST('2026-09-30' AS date))
)
SELECT TOP (20) Id, LogicalReference, CounterpartyName, PrincipalAmount, Currency, ValueDate, MaturityDate,
       DATEDIFF(day, ValueDate, MaturityDate) AS OriginalTenorDays,
       CASE WHEN MaturityDate < @LD THEN 0 ELSE DATEDIFF(day, @LD, MaturityDate) END AS DaysToMaturity,
       InterestRate, InterestAmount, Direction, SubProductName,
       COUNT(*) OVER () AS TotCnt, SUM(PrincipalAmount) OVER () AS TotPrincipal, SUM(InterestAmount) OVER () AS TotInterest,
       MIN(ValueDate) OVER () AS MinVal, MAX(ValueDate) OVER () AS MaxVal
FROM Q
ORDER BY Id DESC;
```

DB: `NetTrexMM` · Server: `tcp:192.168.10.211,1433` · User: `trusr` · Pass: `***`


## #56

**Amaç:** Test MM: Vade aralığı Eylül 2026 — vade 2026-09-01–2026-09-30. API (ekran) sonucu ile karşılaştırma; TOP (20) satır alan alan, sayı/toplamlar pencere fonksiyonuyla tüm küme üzerinden.

```sql
SET NOCOUNT ON;
DECLARE @LD date = '2026-10-01';
WITH Q AS (
SELECT t.Id, t.LogicalReference, c.Name AS CounterpartyName, ROUND(t.DealAmount, 2) AS PrincipalAmount, t.Ccy AS Currency,
       CAST(t.ValueDate AS date) AS ValueDate, CAST(t.MaturityDate AS date) AS MaturityDate,
       ir.Rate AS InterestRate, ROUND(ia.Amt, 2) AS InterestAmount, ISNULL(tt.Name, t.TxnTypeCode) AS Direction, p.Name AS SubProductName
FROM TxnMM t
JOIN prdProductDefinition p ON p.Id = t.TxnMmProductTypeId AND p.IsEnabled = 1
OUTER APPLY (SELECT TOP (1) cu.Name FROM cusCustomer cu WHERE cu.Id = t.CustomerId) c
OUTER APPLY (SELECT TOP (1) x.Name FROM defTxnType x WHERE x.TxnTypeCode = t.TxnTypeCode) tt
OUTER APPLY (SELECT TOP (1) d.InterestRate AS Rate FROM txnMMDetail d WHERE d.TxnId = t.Id AND d.IsPrincipalAmount = 0 ORDER BY d.PeriodStartDate) ir
OUTER APPLY (SELECT SUM(d.Amount) AS Amt FROM txnMMDetail d WHERE d.TxnId = t.Id AND d.IsPrincipalAmount = 0) ia
WHERE (t.StateId & 6) = 2 AND t.MaturityDate >= '2026-09-01' AND t.MaturityDate < DATEADD(day, 1, CAST('2026-09-30' AS date))
)
SELECT TOP (20) Id, LogicalReference, CounterpartyName, PrincipalAmount, Currency, ValueDate, MaturityDate,
       DATEDIFF(day, ValueDate, MaturityDate) AS OriginalTenorDays,
       CASE WHEN MaturityDate < @LD THEN 0 ELSE DATEDIFF(day, @LD, MaturityDate) END AS DaysToMaturity,
       InterestRate, InterestAmount, Direction, SubProductName,
       COUNT(*) OVER () AS TotCnt, SUM(PrincipalAmount) OVER () AS TotPrincipal, SUM(InterestAmount) OVER () AS TotInterest,
       MIN(ValueDate) OVER () AS MinVal, MAX(ValueDate) OVER () AS MaxVal
FROM Q
ORDER BY Id DESC;
```

DB: `NetTrexMM` · Server: `tcp:192.168.10.211,1433` · User: `trusr` · Pass: `***`


## #57

**Amaç:** Test MM: Yalnız vade başlangıç — vade 2026-11-01–…. API (ekran) sonucu ile karşılaştırma; TOP (20) satır alan alan, sayı/toplamlar pencere fonksiyonuyla tüm küme üzerinden.

```sql
SET NOCOUNT ON;
DECLARE @LD date = '2026-10-01';
WITH Q AS (
SELECT t.Id, t.LogicalReference, c.Name AS CounterpartyName, ROUND(t.DealAmount, 2) AS PrincipalAmount, t.Ccy AS Currency,
       CAST(t.ValueDate AS date) AS ValueDate, CAST(t.MaturityDate AS date) AS MaturityDate,
       ir.Rate AS InterestRate, ROUND(ia.Amt, 2) AS InterestAmount, ISNULL(tt.Name, t.TxnTypeCode) AS Direction, p.Name AS SubProductName
FROM TxnMM t
JOIN prdProductDefinition p ON p.Id = t.TxnMmProductTypeId AND p.IsEnabled = 1
OUTER APPLY (SELECT TOP (1) cu.Name FROM cusCustomer cu WHERE cu.Id = t.CustomerId) c
OUTER APPLY (SELECT TOP (1) x.Name FROM defTxnType x WHERE x.TxnTypeCode = t.TxnTypeCode) tt
OUTER APPLY (SELECT TOP (1) d.InterestRate AS Rate FROM txnMMDetail d WHERE d.TxnId = t.Id AND d.IsPrincipalAmount = 0 ORDER BY d.PeriodStartDate) ir
OUTER APPLY (SELECT SUM(d.Amount) AS Amt FROM txnMMDetail d WHERE d.TxnId = t.Id AND d.IsPrincipalAmount = 0) ia
WHERE (t.StateId & 6) = 2 AND t.MaturityDate >= '2026-11-01'
)
SELECT TOP (20) Id, LogicalReference, CounterpartyName, PrincipalAmount, Currency, ValueDate, MaturityDate,
       DATEDIFF(day, ValueDate, MaturityDate) AS OriginalTenorDays,
       CASE WHEN MaturityDate < @LD THEN 0 ELSE DATEDIFF(day, @LD, MaturityDate) END AS DaysToMaturity,
       InterestRate, InterestAmount, Direction, SubProductName,
       COUNT(*) OVER () AS TotCnt, SUM(PrincipalAmount) OVER () AS TotPrincipal, SUM(InterestAmount) OVER () AS TotInterest,
       MIN(ValueDate) OVER () AS MinVal, MAX(ValueDate) OVER () AS MaxVal
FROM Q
ORDER BY Id DESC;
```

DB: `NetTrexMM` · Server: `tcp:192.168.10.211,1433` · User: `trusr` · Pass: `***`


## #58

**Amaç:** Test MM: Yalnız vade bitiş — vade …–2025-10-31. API (ekran) sonucu ile karşılaştırma; TOP (20) satır alan alan, sayı/toplamlar pencere fonksiyonuyla tüm küme üzerinden.

```sql
SET NOCOUNT ON;
DECLARE @LD date = '2026-10-01';
WITH Q AS (
SELECT t.Id, t.LogicalReference, c.Name AS CounterpartyName, ROUND(t.DealAmount, 2) AS PrincipalAmount, t.Ccy AS Currency,
       CAST(t.ValueDate AS date) AS ValueDate, CAST(t.MaturityDate AS date) AS MaturityDate,
       ir.Rate AS InterestRate, ROUND(ia.Amt, 2) AS InterestAmount, ISNULL(tt.Name, t.TxnTypeCode) AS Direction, p.Name AS SubProductName
FROM TxnMM t
JOIN prdProductDefinition p ON p.Id = t.TxnMmProductTypeId AND p.IsEnabled = 1
OUTER APPLY (SELECT TOP (1) cu.Name FROM cusCustomer cu WHERE cu.Id = t.CustomerId) c
OUTER APPLY (SELECT TOP (1) x.Name FROM defTxnType x WHERE x.TxnTypeCode = t.TxnTypeCode) tt
OUTER APPLY (SELECT TOP (1) d.InterestRate AS Rate FROM txnMMDetail d WHERE d.TxnId = t.Id AND d.IsPrincipalAmount = 0 ORDER BY d.PeriodStartDate) ir
OUTER APPLY (SELECT SUM(d.Amount) AS Amt FROM txnMMDetail d WHERE d.TxnId = t.Id AND d.IsPrincipalAmount = 0) ia
WHERE (t.StateId & 6) = 2 AND t.MaturityDate < DATEADD(day, 1, CAST('2025-10-31' AS date))
)
SELECT TOP (20) Id, LogicalReference, CounterpartyName, PrincipalAmount, Currency, ValueDate, MaturityDate,
       DATEDIFF(day, ValueDate, MaturityDate) AS OriginalTenorDays,
       CASE WHEN MaturityDate < @LD THEN 0 ELSE DATEDIFF(day, @LD, MaturityDate) END AS DaysToMaturity,
       InterestRate, InterestAmount, Direction, SubProductName,
       COUNT(*) OVER () AS TotCnt, SUM(PrincipalAmount) OVER () AS TotPrincipal, SUM(InterestAmount) OVER () AS TotInterest,
       MIN(ValueDate) OVER () AS MinVal, MAX(ValueDate) OVER () AS MaxVal
FROM Q
ORDER BY Id DESC;
```

DB: `NetTrexMM` · Server: `tcp:192.168.10.211,1433` · User: `trusr` · Pass: `***`


## #59

**Amaç:** Test MM: Valör + vade birlikte — valör 2026-09-01–2026-09-30, vade 2026-11-01–2026-12-31. API (ekran) sonucu ile karşılaştırma; TOP (20) satır alan alan, sayı/toplamlar pencere fonksiyonuyla tüm küme üzerinden.

```sql
SET NOCOUNT ON;
DECLARE @LD date = '2026-10-01';
WITH Q AS (
SELECT t.Id, t.LogicalReference, c.Name AS CounterpartyName, ROUND(t.DealAmount, 2) AS PrincipalAmount, t.Ccy AS Currency,
       CAST(t.ValueDate AS date) AS ValueDate, CAST(t.MaturityDate AS date) AS MaturityDate,
       ir.Rate AS InterestRate, ROUND(ia.Amt, 2) AS InterestAmount, ISNULL(tt.Name, t.TxnTypeCode) AS Direction, p.Name AS SubProductName
FROM TxnMM t
JOIN prdProductDefinition p ON p.Id = t.TxnMmProductTypeId AND p.IsEnabled = 1
OUTER APPLY (SELECT TOP (1) cu.Name FROM cusCustomer cu WHERE cu.Id = t.CustomerId) c
OUTER APPLY (SELECT TOP (1) x.Name FROM defTxnType x WHERE x.TxnTypeCode = t.TxnTypeCode) tt
OUTER APPLY (SELECT TOP (1) d.InterestRate AS Rate FROM txnMMDetail d WHERE d.TxnId = t.Id AND d.IsPrincipalAmount = 0 ORDER BY d.PeriodStartDate) ir
OUTER APPLY (SELECT SUM(d.Amount) AS Amt FROM txnMMDetail d WHERE d.TxnId = t.Id AND d.IsPrincipalAmount = 0) ia
WHERE (t.StateId & 6) = 2 AND t.ValueDate >= '2026-09-01' AND t.ValueDate < DATEADD(day, 1, CAST('2026-09-30' AS date)) AND t.MaturityDate >= '2026-11-01' AND t.MaturityDate < DATEADD(day, 1, CAST('2026-12-31' AS date))
)
SELECT TOP (20) Id, LogicalReference, CounterpartyName, PrincipalAmount, Currency, ValueDate, MaturityDate,
       DATEDIFF(day, ValueDate, MaturityDate) AS OriginalTenorDays,
       CASE WHEN MaturityDate < @LD THEN 0 ELSE DATEDIFF(day, @LD, MaturityDate) END AS DaysToMaturity,
       InterestRate, InterestAmount, Direction, SubProductName,
       COUNT(*) OVER () AS TotCnt, SUM(PrincipalAmount) OVER () AS TotPrincipal, SUM(InterestAmount) OVER () AS TotInterest,
       MIN(ValueDate) OVER () AS MinVal, MAX(ValueDate) OVER () AS MaxVal
FROM Q
ORDER BY Id DESC;
```

DB: `NetTrexMM` · Server: `tcp:192.168.10.211,1433` · User: `trusr` · Pass: `***`


## #60

**Amaç:** Test MM: Tüm aralık, tüm alt ürünler — valör 2020-01-01–2030-12-31, vade 2020-01-01–2035-12-31. API (ekran) sonucu ile karşılaştırma; TOP (20) satır alan alan, sayı/toplamlar pencere fonksiyonuyla tüm küme üzerinden.

```sql
SET NOCOUNT ON;
DECLARE @LD date = '2026-10-01';
WITH Q AS (
SELECT t.Id, t.LogicalReference, c.Name AS CounterpartyName, ROUND(t.DealAmount, 2) AS PrincipalAmount, t.Ccy AS Currency,
       CAST(t.ValueDate AS date) AS ValueDate, CAST(t.MaturityDate AS date) AS MaturityDate,
       ir.Rate AS InterestRate, ROUND(ia.Amt, 2) AS InterestAmount, ISNULL(tt.Name, t.TxnTypeCode) AS Direction, p.Name AS SubProductName
FROM TxnMM t
JOIN prdProductDefinition p ON p.Id = t.TxnMmProductTypeId AND p.IsEnabled = 1
OUTER APPLY (SELECT TOP (1) cu.Name FROM cusCustomer cu WHERE cu.Id = t.CustomerId) c
OUTER APPLY (SELECT TOP (1) x.Name FROM defTxnType x WHERE x.TxnTypeCode = t.TxnTypeCode) tt
OUTER APPLY (SELECT TOP (1) d.InterestRate AS Rate FROM txnMMDetail d WHERE d.TxnId = t.Id AND d.IsPrincipalAmount = 0 ORDER BY d.PeriodStartDate) ir
OUTER APPLY (SELECT SUM(d.Amount) AS Amt FROM txnMMDetail d WHERE d.TxnId = t.Id AND d.IsPrincipalAmount = 0) ia
WHERE (t.StateId & 6) = 2 AND t.ValueDate >= '2020-01-01' AND t.ValueDate < DATEADD(day, 1, CAST('2030-12-31' AS date)) AND t.MaturityDate >= '2020-01-01' AND t.MaturityDate < DATEADD(day, 1, CAST('2035-12-31' AS date))
)
SELECT TOP (20) Id, LogicalReference, CounterpartyName, PrincipalAmount, Currency, ValueDate, MaturityDate,
       DATEDIFF(day, ValueDate, MaturityDate) AS OriginalTenorDays,
       CASE WHEN MaturityDate < @LD THEN 0 ELSE DATEDIFF(day, @LD, MaturityDate) END AS DaysToMaturity,
       InterestRate, InterestAmount, Direction, SubProductName,
       COUNT(*) OVER () AS TotCnt, SUM(PrincipalAmount) OVER () AS TotPrincipal, SUM(InterestAmount) OVER () AS TotInterest,
       MIN(ValueDate) OVER () AS MinVal, MAX(ValueDate) OVER () AS MaxVal
FROM Q
ORDER BY Id DESC;
```

DB: `NetTrexMM` · Server: `tcp:192.168.10.211,1433` · User: `trusr` · Pass: `***`


## #61

**Amaç:** Test MM: Alt ürün: Money Market — valör 2025-01-01–…, alt ürün [MoneyMarket]. API (ekran) sonucu ile karşılaştırma; TOP (20) satır alan alan, sayı/toplamlar pencere fonksiyonuyla tüm küme üzerinden.

```sql
SET NOCOUNT ON;
DECLARE @LD date = '2026-10-01';
WITH Q AS (
SELECT t.Id, t.LogicalReference, c.Name AS CounterpartyName, ROUND(t.DealAmount, 2) AS PrincipalAmount, t.Ccy AS Currency,
       CAST(t.ValueDate AS date) AS ValueDate, CAST(t.MaturityDate AS date) AS MaturityDate,
       ir.Rate AS InterestRate, ROUND(ia.Amt, 2) AS InterestAmount, ISNULL(tt.Name, t.TxnTypeCode) AS Direction, p.Name AS SubProductName
FROM TxnMM t
JOIN prdProductDefinition p ON p.Id = t.TxnMmProductTypeId AND p.IsEnabled = 1
OUTER APPLY (SELECT TOP (1) cu.Name FROM cusCustomer cu WHERE cu.Id = t.CustomerId) c
OUTER APPLY (SELECT TOP (1) x.Name FROM defTxnType x WHERE x.TxnTypeCode = t.TxnTypeCode) tt
OUTER APPLY (SELECT TOP (1) d.InterestRate AS Rate FROM txnMMDetail d WHERE d.TxnId = t.Id AND d.IsPrincipalAmount = 0 ORDER BY d.PeriodStartDate) ir
OUTER APPLY (SELECT SUM(d.Amount) AS Amt FROM txnMMDetail d WHERE d.TxnId = t.Id AND d.IsPrincipalAmount = 0) ia
WHERE (t.StateId & 6) = 2 AND t.ValueDate >= '2025-01-01' AND p.MainProductCode = 'MM' AND p.Code IN ('MoneyMarket')
)
SELECT TOP (20) Id, LogicalReference, CounterpartyName, PrincipalAmount, Currency, ValueDate, MaturityDate,
       DATEDIFF(day, ValueDate, MaturityDate) AS OriginalTenorDays,
       CASE WHEN MaturityDate < @LD THEN 0 ELSE DATEDIFF(day, @LD, MaturityDate) END AS DaysToMaturity,
       InterestRate, InterestAmount, Direction, SubProductName,
       COUNT(*) OVER () AS TotCnt, SUM(PrincipalAmount) OVER () AS TotPrincipal, SUM(InterestAmount) OVER () AS TotInterest,
       MIN(ValueDate) OVER () AS MinVal, MAX(ValueDate) OVER () AS MaxVal
FROM Q
ORDER BY Id DESC;
```

DB: `NetTrexMM` · Server: `tcp:192.168.10.211,1433` · User: `trusr` · Pass: `***`


## #62

**Amaç:** Test MM: Alt ürün: Murabaha — valör 2020-01-01–…, alt ürün [Murabaha]. API (ekran) sonucu ile karşılaştırma; TOP (20) satır alan alan, sayı/toplamlar pencere fonksiyonuyla tüm küme üzerinden.

```sql
SET NOCOUNT ON;
DECLARE @LD date = '2026-10-01';
WITH Q AS (
SELECT t.Id, t.LogicalReference, c.Name AS CounterpartyName, ROUND(t.DealAmount, 2) AS PrincipalAmount, t.Ccy AS Currency,
       CAST(t.ValueDate AS date) AS ValueDate, CAST(t.MaturityDate AS date) AS MaturityDate,
       ir.Rate AS InterestRate, ROUND(ia.Amt, 2) AS InterestAmount, ISNULL(tt.Name, t.TxnTypeCode) AS Direction, p.Name AS SubProductName
FROM TxnMM t
JOIN prdProductDefinition p ON p.Id = t.TxnMmProductTypeId AND p.IsEnabled = 1
OUTER APPLY (SELECT TOP (1) cu.Name FROM cusCustomer cu WHERE cu.Id = t.CustomerId) c
OUTER APPLY (SELECT TOP (1) x.Name FROM defTxnType x WHERE x.TxnTypeCode = t.TxnTypeCode) tt
OUTER APPLY (SELECT TOP (1) d.InterestRate AS Rate FROM txnMMDetail d WHERE d.TxnId = t.Id AND d.IsPrincipalAmount = 0 ORDER BY d.PeriodStartDate) ir
OUTER APPLY (SELECT SUM(d.Amount) AS Amt FROM txnMMDetail d WHERE d.TxnId = t.Id AND d.IsPrincipalAmount = 0) ia
WHERE (t.StateId & 6) = 2 AND t.ValueDate >= '2020-01-01' AND p.MainProductCode = 'MM' AND p.Code IN ('Murabaha')
)
SELECT TOP (20) Id, LogicalReference, CounterpartyName, PrincipalAmount, Currency, ValueDate, MaturityDate,
       DATEDIFF(day, ValueDate, MaturityDate) AS OriginalTenorDays,
       CASE WHEN MaturityDate < @LD THEN 0 ELSE DATEDIFF(day, @LD, MaturityDate) END AS DaysToMaturity,
       InterestRate, InterestAmount, Direction, SubProductName,
       COUNT(*) OVER () AS TotCnt, SUM(PrincipalAmount) OVER () AS TotPrincipal, SUM(InterestAmount) OVER () AS TotInterest,
       MIN(ValueDate) OVER () AS MinVal, MAX(ValueDate) OVER () AS MaxVal
FROM Q
ORDER BY Id DESC;
```

DB: `NetTrexMM` · Server: `tcp:192.168.10.211,1433` · User: `trusr` · Pass: `***`


## #63

**Amaç:** Test MM: Alt ürün: Wakale + Loan — valör 2020-01-01–…, alt ürün [Wakale,Loan]. API (ekran) sonucu ile karşılaştırma; TOP (20) satır alan alan, sayı/toplamlar pencere fonksiyonuyla tüm küme üzerinden.

```sql
SET NOCOUNT ON;
DECLARE @LD date = '2026-10-01';
WITH Q AS (
SELECT t.Id, t.LogicalReference, c.Name AS CounterpartyName, ROUND(t.DealAmount, 2) AS PrincipalAmount, t.Ccy AS Currency,
       CAST(t.ValueDate AS date) AS ValueDate, CAST(t.MaturityDate AS date) AS MaturityDate,
       ir.Rate AS InterestRate, ROUND(ia.Amt, 2) AS InterestAmount, ISNULL(tt.Name, t.TxnTypeCode) AS Direction, p.Name AS SubProductName
FROM TxnMM t
JOIN prdProductDefinition p ON p.Id = t.TxnMmProductTypeId AND p.IsEnabled = 1
OUTER APPLY (SELECT TOP (1) cu.Name FROM cusCustomer cu WHERE cu.Id = t.CustomerId) c
OUTER APPLY (SELECT TOP (1) x.Name FROM defTxnType x WHERE x.TxnTypeCode = t.TxnTypeCode) tt
OUTER APPLY (SELECT TOP (1) d.InterestRate AS Rate FROM txnMMDetail d WHERE d.TxnId = t.Id AND d.IsPrincipalAmount = 0 ORDER BY d.PeriodStartDate) ir
OUTER APPLY (SELECT SUM(d.Amount) AS Amt FROM txnMMDetail d WHERE d.TxnId = t.Id AND d.IsPrincipalAmount = 0) ia
WHERE (t.StateId & 6) = 2 AND t.ValueDate >= '2020-01-01' AND p.MainProductCode = 'MM' AND p.Code IN ('Wakale', 'Loan')
)
SELECT TOP (20) Id, LogicalReference, CounterpartyName, PrincipalAmount, Currency, ValueDate, MaturityDate,
       DATEDIFF(day, ValueDate, MaturityDate) AS OriginalTenorDays,
       CASE WHEN MaturityDate < @LD THEN 0 ELSE DATEDIFF(day, @LD, MaturityDate) END AS DaysToMaturity,
       InterestRate, InterestAmount, Direction, SubProductName,
       COUNT(*) OVER () AS TotCnt, SUM(PrincipalAmount) OVER () AS TotPrincipal, SUM(InterestAmount) OVER () AS TotInterest,
       MIN(ValueDate) OVER () AS MinVal, MAX(ValueDate) OVER () AS MaxVal
FROM Q
ORDER BY Id DESC;
```

DB: `NetTrexMM` · Server: `tcp:192.168.10.211,1433` · User: `trusr` · Pass: `***`


## #64

**Amaç:** Test MM: Alt ürün: veri olmayan (Bond Issue) — valör 2020-01-01–…, alt ürün [Issue]. API (ekran) sonucu ile karşılaştırma; TOP (20) satır alan alan, sayı/toplamlar pencere fonksiyonuyla tüm küme üzerinden.

```sql
SET NOCOUNT ON;
DECLARE @LD date = '2026-10-01';
WITH Q AS (
SELECT t.Id, t.LogicalReference, c.Name AS CounterpartyName, ROUND(t.DealAmount, 2) AS PrincipalAmount, t.Ccy AS Currency,
       CAST(t.ValueDate AS date) AS ValueDate, CAST(t.MaturityDate AS date) AS MaturityDate,
       ir.Rate AS InterestRate, ROUND(ia.Amt, 2) AS InterestAmount, ISNULL(tt.Name, t.TxnTypeCode) AS Direction, p.Name AS SubProductName
FROM TxnMM t
JOIN prdProductDefinition p ON p.Id = t.TxnMmProductTypeId AND p.IsEnabled = 1
OUTER APPLY (SELECT TOP (1) cu.Name FROM cusCustomer cu WHERE cu.Id = t.CustomerId) c
OUTER APPLY (SELECT TOP (1) x.Name FROM defTxnType x WHERE x.TxnTypeCode = t.TxnTypeCode) tt
OUTER APPLY (SELECT TOP (1) d.InterestRate AS Rate FROM txnMMDetail d WHERE d.TxnId = t.Id AND d.IsPrincipalAmount = 0 ORDER BY d.PeriodStartDate) ir
OUTER APPLY (SELECT SUM(d.Amount) AS Amt FROM txnMMDetail d WHERE d.TxnId = t.Id AND d.IsPrincipalAmount = 0) ia
WHERE (t.StateId & 6) = 2 AND t.ValueDate >= '2020-01-01' AND p.MainProductCode = 'MM' AND p.Code IN ('Issue')
)
SELECT TOP (20) Id, LogicalReference, CounterpartyName, PrincipalAmount, Currency, ValueDate, MaturityDate,
       DATEDIFF(day, ValueDate, MaturityDate) AS OriginalTenorDays,
       CASE WHEN MaturityDate < @LD THEN 0 ELSE DATEDIFF(day, @LD, MaturityDate) END AS DaysToMaturity,
       InterestRate, InterestAmount, Direction, SubProductName,
       COUNT(*) OVER () AS TotCnt, SUM(PrincipalAmount) OVER () AS TotPrincipal, SUM(InterestAmount) OVER () AS TotInterest,
       MIN(ValueDate) OVER () AS MinVal, MAX(ValueDate) OVER () AS MaxVal
FROM Q
ORDER BY Id DESC;
```

DB: `NetTrexMM` · Server: `tcp:192.168.10.211,1433` · User: `trusr` · Pass: `***`


## #65

**Amaç:** Test MM: Alt ürün: pasif ürün (TermDeposit) — valör 2020-01-01–…, alt ürün [TermDeposit]. API (ekran) sonucu ile karşılaştırma; TOP (20) satır alan alan, sayı/toplamlar pencere fonksiyonuyla tüm küme üzerinden.

```sql
SET NOCOUNT ON;
DECLARE @LD date = '2026-10-01';
WITH Q AS (
SELECT t.Id, t.LogicalReference, c.Name AS CounterpartyName, ROUND(t.DealAmount, 2) AS PrincipalAmount, t.Ccy AS Currency,
       CAST(t.ValueDate AS date) AS ValueDate, CAST(t.MaturityDate AS date) AS MaturityDate,
       ir.Rate AS InterestRate, ROUND(ia.Amt, 2) AS InterestAmount, ISNULL(tt.Name, t.TxnTypeCode) AS Direction, p.Name AS SubProductName
FROM TxnMM t
JOIN prdProductDefinition p ON p.Id = t.TxnMmProductTypeId AND p.IsEnabled = 1
OUTER APPLY (SELECT TOP (1) cu.Name FROM cusCustomer cu WHERE cu.Id = t.CustomerId) c
OUTER APPLY (SELECT TOP (1) x.Name FROM defTxnType x WHERE x.TxnTypeCode = t.TxnTypeCode) tt
OUTER APPLY (SELECT TOP (1) d.InterestRate AS Rate FROM txnMMDetail d WHERE d.TxnId = t.Id AND d.IsPrincipalAmount = 0 ORDER BY d.PeriodStartDate) ir
OUTER APPLY (SELECT SUM(d.Amount) AS Amt FROM txnMMDetail d WHERE d.TxnId = t.Id AND d.IsPrincipalAmount = 0) ia
WHERE (t.StateId & 6) = 2 AND t.ValueDate >= '2020-01-01' AND p.MainProductCode = 'MM' AND p.Code IN ('TermDeposit')
)
SELECT TOP (20) Id, LogicalReference, CounterpartyName, PrincipalAmount, Currency, ValueDate, MaturityDate,
       DATEDIFF(day, ValueDate, MaturityDate) AS OriginalTenorDays,
       CASE WHEN MaturityDate < @LD THEN 0 ELSE DATEDIFF(day, @LD, MaturityDate) END AS DaysToMaturity,
       InterestRate, InterestAmount, Direction, SubProductName,
       COUNT(*) OVER () AS TotCnt, SUM(PrincipalAmount) OVER () AS TotPrincipal, SUM(InterestAmount) OVER () AS TotInterest,
       MIN(ValueDate) OVER () AS MinVal, MAX(ValueDate) OVER () AS MaxVal
FROM Q
ORDER BY Id DESC;
```

DB: `NetTrexMM` · Server: `tcp:192.168.10.211,1433` · User: `trusr` · Pass: `***`


## #66

**Amaç:** Test MM: Yalnız referans (tarih yok) — ref 'TMMPLC2609'. API (ekran) sonucu ile karşılaştırma; TOP (20) satır alan alan, sayı/toplamlar pencere fonksiyonuyla tüm küme üzerinden.

```sql
SET NOCOUNT ON;
DECLARE @LD date = '2026-10-01';
WITH Q AS (
SELECT t.Id, t.LogicalReference, c.Name AS CounterpartyName, ROUND(t.DealAmount, 2) AS PrincipalAmount, t.Ccy AS Currency,
       CAST(t.ValueDate AS date) AS ValueDate, CAST(t.MaturityDate AS date) AS MaturityDate,
       ir.Rate AS InterestRate, ROUND(ia.Amt, 2) AS InterestAmount, ISNULL(tt.Name, t.TxnTypeCode) AS Direction, p.Name AS SubProductName
FROM TxnMM t
JOIN prdProductDefinition p ON p.Id = t.TxnMmProductTypeId AND p.IsEnabled = 1
OUTER APPLY (SELECT TOP (1) cu.Name FROM cusCustomer cu WHERE cu.Id = t.CustomerId) c
OUTER APPLY (SELECT TOP (1) x.Name FROM defTxnType x WHERE x.TxnTypeCode = t.TxnTypeCode) tt
OUTER APPLY (SELECT TOP (1) d.InterestRate AS Rate FROM txnMMDetail d WHERE d.TxnId = t.Id AND d.IsPrincipalAmount = 0 ORDER BY d.PeriodStartDate) ir
OUTER APPLY (SELECT SUM(d.Amount) AS Amt FROM txnMMDetail d WHERE d.TxnId = t.Id AND d.IsPrincipalAmount = 0) ia
WHERE (t.StateId & 6) = 2 AND t.LogicalReference LIKE '%TMMPLC2609%'
)
SELECT TOP (20) Id, LogicalReference, CounterpartyName, PrincipalAmount, Currency, ValueDate, MaturityDate,
       DATEDIFF(day, ValueDate, MaturityDate) AS OriginalTenorDays,
       CASE WHEN MaturityDate < @LD THEN 0 ELSE DATEDIFF(day, @LD, MaturityDate) END AS DaysToMaturity,
       InterestRate, InterestAmount, Direction, SubProductName,
       COUNT(*) OVER () AS TotCnt, SUM(PrincipalAmount) OVER () AS TotPrincipal, SUM(InterestAmount) OVER () AS TotInterest,
       MIN(ValueDate) OVER () AS MinVal, MAX(ValueDate) OVER () AS MaxVal
FROM Q
ORDER BY Id DESC;
```

DB: `NetTrexMM` · Server: `tcp:192.168.10.211,1433` · User: `trusr` · Pass: `***`


## #67

**Amaç:** Test MM: Referans + tarih — valör 2026-09-01–2026-09-30, ref 'BRW'. API (ekran) sonucu ile karşılaştırma; TOP (20) satır alan alan, sayı/toplamlar pencere fonksiyonuyla tüm küme üzerinden.

```sql
SET NOCOUNT ON;
DECLARE @LD date = '2026-10-01';
WITH Q AS (
SELECT t.Id, t.LogicalReference, c.Name AS CounterpartyName, ROUND(t.DealAmount, 2) AS PrincipalAmount, t.Ccy AS Currency,
       CAST(t.ValueDate AS date) AS ValueDate, CAST(t.MaturityDate AS date) AS MaturityDate,
       ir.Rate AS InterestRate, ROUND(ia.Amt, 2) AS InterestAmount, ISNULL(tt.Name, t.TxnTypeCode) AS Direction, p.Name AS SubProductName
FROM TxnMM t
JOIN prdProductDefinition p ON p.Id = t.TxnMmProductTypeId AND p.IsEnabled = 1
OUTER APPLY (SELECT TOP (1) cu.Name FROM cusCustomer cu WHERE cu.Id = t.CustomerId) c
OUTER APPLY (SELECT TOP (1) x.Name FROM defTxnType x WHERE x.TxnTypeCode = t.TxnTypeCode) tt
OUTER APPLY (SELECT TOP (1) d.InterestRate AS Rate FROM txnMMDetail d WHERE d.TxnId = t.Id AND d.IsPrincipalAmount = 0 ORDER BY d.PeriodStartDate) ir
OUTER APPLY (SELECT SUM(d.Amount) AS Amt FROM txnMMDetail d WHERE d.TxnId = t.Id AND d.IsPrincipalAmount = 0) ia
WHERE (t.StateId & 6) = 2 AND t.ValueDate >= '2026-09-01' AND t.ValueDate < DATEADD(day, 1, CAST('2026-09-30' AS date)) AND t.LogicalReference LIKE '%BRW%'
)
SELECT TOP (20) Id, LogicalReference, CounterpartyName, PrincipalAmount, Currency, ValueDate, MaturityDate,
       DATEDIFF(day, ValueDate, MaturityDate) AS OriginalTenorDays,
       CASE WHEN MaturityDate < @LD THEN 0 ELSE DATEDIFF(day, @LD, MaturityDate) END AS DaysToMaturity,
       InterestRate, InterestAmount, Direction, SubProductName,
       COUNT(*) OVER () AS TotCnt, SUM(PrincipalAmount) OVER () AS TotPrincipal, SUM(InterestAmount) OVER () AS TotInterest,
       MIN(ValueDate) OVER () AS MinVal, MAX(ValueDate) OVER () AS MaxVal
FROM Q
ORDER BY Id DESC;
```

DB: `NetTrexMM` · Server: `tcp:192.168.10.211,1433` · User: `trusr` · Pass: `***`


## #68

**Amaç:** Test MM: Tam referans — ref 'TMMBRW2609110002'. API (ekran) sonucu ile karşılaştırma; TOP (20) satır alan alan, sayı/toplamlar pencere fonksiyonuyla tüm küme üzerinden.

```sql
SET NOCOUNT ON;
DECLARE @LD date = '2026-10-01';
WITH Q AS (
SELECT t.Id, t.LogicalReference, c.Name AS CounterpartyName, ROUND(t.DealAmount, 2) AS PrincipalAmount, t.Ccy AS Currency,
       CAST(t.ValueDate AS date) AS ValueDate, CAST(t.MaturityDate AS date) AS MaturityDate,
       ir.Rate AS InterestRate, ROUND(ia.Amt, 2) AS InterestAmount, ISNULL(tt.Name, t.TxnTypeCode) AS Direction, p.Name AS SubProductName
FROM TxnMM t
JOIN prdProductDefinition p ON p.Id = t.TxnMmProductTypeId AND p.IsEnabled = 1
OUTER APPLY (SELECT TOP (1) cu.Name FROM cusCustomer cu WHERE cu.Id = t.CustomerId) c
OUTER APPLY (SELECT TOP (1) x.Name FROM defTxnType x WHERE x.TxnTypeCode = t.TxnTypeCode) tt
OUTER APPLY (SELECT TOP (1) d.InterestRate AS Rate FROM txnMMDetail d WHERE d.TxnId = t.Id AND d.IsPrincipalAmount = 0 ORDER BY d.PeriodStartDate) ir
OUTER APPLY (SELECT SUM(d.Amount) AS Amt FROM txnMMDetail d WHERE d.TxnId = t.Id AND d.IsPrincipalAmount = 0) ia
WHERE (t.StateId & 6) = 2 AND t.LogicalReference LIKE '%TMMBRW2609110002%'
)
SELECT TOP (20) Id, LogicalReference, CounterpartyName, PrincipalAmount, Currency, ValueDate, MaturityDate,
       DATEDIFF(day, ValueDate, MaturityDate) AS OriginalTenorDays,
       CASE WHEN MaturityDate < @LD THEN 0 ELSE DATEDIFF(day, @LD, MaturityDate) END AS DaysToMaturity,
       InterestRate, InterestAmount, Direction, SubProductName,
       COUNT(*) OVER () AS TotCnt, SUM(PrincipalAmount) OVER () AS TotPrincipal, SUM(InterestAmount) OVER () AS TotInterest,
       MIN(ValueDate) OVER () AS MinVal, MAX(ValueDate) OVER () AS MaxVal
FROM Q
ORDER BY Id DESC;
```

DB: `NetTrexMM` · Server: `tcp:192.168.10.211,1433` · User: `trusr` · Pass: `***`


## #69

**Amaç:** Test MM: Olmayan referans — ref 'YOKBOYLEREF'. API (ekran) sonucu ile karşılaştırma; TOP (20) satır alan alan, sayı/toplamlar pencere fonksiyonuyla tüm küme üzerinden.

```sql
SET NOCOUNT ON;
DECLARE @LD date = '2026-10-01';
WITH Q AS (
SELECT t.Id, t.LogicalReference, c.Name AS CounterpartyName, ROUND(t.DealAmount, 2) AS PrincipalAmount, t.Ccy AS Currency,
       CAST(t.ValueDate AS date) AS ValueDate, CAST(t.MaturityDate AS date) AS MaturityDate,
       ir.Rate AS InterestRate, ROUND(ia.Amt, 2) AS InterestAmount, ISNULL(tt.Name, t.TxnTypeCode) AS Direction, p.Name AS SubProductName
FROM TxnMM t
JOIN prdProductDefinition p ON p.Id = t.TxnMmProductTypeId AND p.IsEnabled = 1
OUTER APPLY (SELECT TOP (1) cu.Name FROM cusCustomer cu WHERE cu.Id = t.CustomerId) c
OUTER APPLY (SELECT TOP (1) x.Name FROM defTxnType x WHERE x.TxnTypeCode = t.TxnTypeCode) tt
OUTER APPLY (SELECT TOP (1) d.InterestRate AS Rate FROM txnMMDetail d WHERE d.TxnId = t.Id AND d.IsPrincipalAmount = 0 ORDER BY d.PeriodStartDate) ir
OUTER APPLY (SELECT SUM(d.Amount) AS Amt FROM txnMMDetail d WHERE d.TxnId = t.Id AND d.IsPrincipalAmount = 0) ia
WHERE (t.StateId & 6) = 2 AND t.LogicalReference LIKE '%YOKBOYLEREF%'
)
SELECT TOP (20) Id, LogicalReference, CounterpartyName, PrincipalAmount, Currency, ValueDate, MaturityDate,
       DATEDIFF(day, ValueDate, MaturityDate) AS OriginalTenorDays,
       CASE WHEN MaturityDate < @LD THEN 0 ELSE DATEDIFF(day, @LD, MaturityDate) END AS DaysToMaturity,
       InterestRate, InterestAmount, Direction, SubProductName,
       COUNT(*) OVER () AS TotCnt, SUM(PrincipalAmount) OVER () AS TotPrincipal, SUM(InterestAmount) OVER () AS TotInterest,
       MIN(ValueDate) OVER () AS MinVal, MAX(ValueDate) OVER () AS MaxVal
FROM Q
ORDER BY Id DESC;
```

DB: `NetTrexMM` · Server: `tcp:192.168.10.211,1433` · User: `trusr` · Pass: `***`


## #70

**Amaç:** Test IL: Ekran varsayılanı (bu ay) — valör 2026-10-01–2026-10-31. API (ekran) sonucu ile karşılaştırma; TOP (20) satır alan alan, sayı/toplamlar pencere fonksiyonuyla tüm küme üzerinden.

```sql
SET NOCOUNT ON;
DECLARE @LD date = '2026-10-01';
WITH Q AS (
SELECT l.Id, l.LogicalReference, c.Name AS CounterpartyName, ROUND(l.PrincipalAmount, 2) AS PrincipalAmount, l.CurrencyCode AS Currency,
       CAST(l.ValueDate AS date) AS ValueDate, CAST(l.MaturityDate AS date) AS MaturityDate,
       CASE WHEN l.Rate IS NOT NULL AND l.Rate <> 0 THEN l.Rate ELSE ir.Rate END AS InterestRate,
       ROUND(ia.Amt, 2) AS InterestAmount, ISNULL(tt.Name, l.TxnTypeCode) AS Direction, p.Name AS SubProductName
FROM TxnLoan l
JOIN prdProductDefinition p ON p.Id = l.ProductDefinitionId AND p.IsEnabled = 1
OUTER APPLY (SELECT TOP (1) cu.Name FROM cusCustomer cu WHERE cu.Id = l.CustomerId) c
OUTER APPLY (SELECT TOP (1) x.Name FROM defTxnType x WHERE x.TxnTypeCode = l.TxnTypeCode) tt
OUTER APPLY (SELECT TOP (1) cf.Rate FROM TxnCashFlow cf WHERE cf.TxnId = l.Id AND cf.FlowTypeId = 2 ORDER BY cf.StartDate) ir
OUTER APPLY (SELECT SUM(cf.CashFlowAmount) AS Amt FROM TxnCashFlow cf WHERE cf.TxnId = l.Id AND cf.FlowTypeId = 2) ia
WHERE (l.StateId & 6) = 2 AND l.ValueDate >= '2026-10-01' AND l.ValueDate < DATEADD(day, 1, CAST('2026-10-31' AS date))
)
SELECT TOP (20) Id, LogicalReference, CounterpartyName, PrincipalAmount, Currency, ValueDate, MaturityDate,
       DATEDIFF(day, ValueDate, MaturityDate) AS OriginalTenorDays,
       CASE WHEN MaturityDate < @LD THEN 0 ELSE DATEDIFF(day, @LD, MaturityDate) END AS DaysToMaturity,
       InterestRate, InterestAmount, Direction, SubProductName,
       COUNT(*) OVER () AS TotCnt, SUM(PrincipalAmount) OVER () AS TotPrincipal, SUM(InterestAmount) OVER () AS TotInterest,
       MIN(ValueDate) OVER () AS MinVal, MAX(ValueDate) OVER () AS MaxVal
FROM Q
ORDER BY Id DESC;
```

DB: `NetTrexMM` · Server: `tcp:192.168.10.211,1433` · User: `trusr` · Pass: `***`


## #71

**Amaç:** Test IL: Nisan 2026 valör — valör 2026-04-01–2026-04-30. API (ekran) sonucu ile karşılaştırma; TOP (20) satır alan alan, sayı/toplamlar pencere fonksiyonuyla tüm küme üzerinden.

```sql
SET NOCOUNT ON;
DECLARE @LD date = '2026-10-01';
WITH Q AS (
SELECT l.Id, l.LogicalReference, c.Name AS CounterpartyName, ROUND(l.PrincipalAmount, 2) AS PrincipalAmount, l.CurrencyCode AS Currency,
       CAST(l.ValueDate AS date) AS ValueDate, CAST(l.MaturityDate AS date) AS MaturityDate,
       CASE WHEN l.Rate IS NOT NULL AND l.Rate <> 0 THEN l.Rate ELSE ir.Rate END AS InterestRate,
       ROUND(ia.Amt, 2) AS InterestAmount, ISNULL(tt.Name, l.TxnTypeCode) AS Direction, p.Name AS SubProductName
FROM TxnLoan l
JOIN prdProductDefinition p ON p.Id = l.ProductDefinitionId AND p.IsEnabled = 1
OUTER APPLY (SELECT TOP (1) cu.Name FROM cusCustomer cu WHERE cu.Id = l.CustomerId) c
OUTER APPLY (SELECT TOP (1) x.Name FROM defTxnType x WHERE x.TxnTypeCode = l.TxnTypeCode) tt
OUTER APPLY (SELECT TOP (1) cf.Rate FROM TxnCashFlow cf WHERE cf.TxnId = l.Id AND cf.FlowTypeId = 2 ORDER BY cf.StartDate) ir
OUTER APPLY (SELECT SUM(cf.CashFlowAmount) AS Amt FROM TxnCashFlow cf WHERE cf.TxnId = l.Id AND cf.FlowTypeId = 2) ia
WHERE (l.StateId & 6) = 2 AND l.ValueDate >= '2026-04-01' AND l.ValueDate < DATEADD(day, 1, CAST('2026-04-30' AS date))
)
SELECT TOP (20) Id, LogicalReference, CounterpartyName, PrincipalAmount, Currency, ValueDate, MaturityDate,
       DATEDIFF(day, ValueDate, MaturityDate) AS OriginalTenorDays,
       CASE WHEN MaturityDate < @LD THEN 0 ELSE DATEDIFF(day, @LD, MaturityDate) END AS DaysToMaturity,
       InterestRate, InterestAmount, Direction, SubProductName,
       COUNT(*) OVER () AS TotCnt, SUM(PrincipalAmount) OVER () AS TotPrincipal, SUM(InterestAmount) OVER () AS TotInterest,
       MIN(ValueDate) OVER () AS MinVal, MAX(ValueDate) OVER () AS MaxVal
FROM Q
ORDER BY Id DESC;
```

DB: `NetTrexMM` · Server: `tcp:192.168.10.211,1433` · User: `trusr` · Pass: `***`


## #72

**Amaç:** Test IL: Mayıs 2026 valör — valör 2026-05-01–2026-05-31. API (ekran) sonucu ile karşılaştırma; TOP (20) satır alan alan, sayı/toplamlar pencere fonksiyonuyla tüm küme üzerinden.

```sql
SET NOCOUNT ON;
DECLARE @LD date = '2026-10-01';
WITH Q AS (
SELECT l.Id, l.LogicalReference, c.Name AS CounterpartyName, ROUND(l.PrincipalAmount, 2) AS PrincipalAmount, l.CurrencyCode AS Currency,
       CAST(l.ValueDate AS date) AS ValueDate, CAST(l.MaturityDate AS date) AS MaturityDate,
       CASE WHEN l.Rate IS NOT NULL AND l.Rate <> 0 THEN l.Rate ELSE ir.Rate END AS InterestRate,
       ROUND(ia.Amt, 2) AS InterestAmount, ISNULL(tt.Name, l.TxnTypeCode) AS Direction, p.Name AS SubProductName
FROM TxnLoan l
JOIN prdProductDefinition p ON p.Id = l.ProductDefinitionId AND p.IsEnabled = 1
OUTER APPLY (SELECT TOP (1) cu.Name FROM cusCustomer cu WHERE cu.Id = l.CustomerId) c
OUTER APPLY (SELECT TOP (1) x.Name FROM defTxnType x WHERE x.TxnTypeCode = l.TxnTypeCode) tt
OUTER APPLY (SELECT TOP (1) cf.Rate FROM TxnCashFlow cf WHERE cf.TxnId = l.Id AND cf.FlowTypeId = 2 ORDER BY cf.StartDate) ir
OUTER APPLY (SELECT SUM(cf.CashFlowAmount) AS Amt FROM TxnCashFlow cf WHERE cf.TxnId = l.Id AND cf.FlowTypeId = 2) ia
WHERE (l.StateId & 6) = 2 AND l.ValueDate >= '2026-05-01' AND l.ValueDate < DATEADD(day, 1, CAST('2026-05-31' AS date))
)
SELECT TOP (20) Id, LogicalReference, CounterpartyName, PrincipalAmount, Currency, ValueDate, MaturityDate,
       DATEDIFF(day, ValueDate, MaturityDate) AS OriginalTenorDays,
       CASE WHEN MaturityDate < @LD THEN 0 ELSE DATEDIFF(day, @LD, MaturityDate) END AS DaysToMaturity,
       InterestRate, InterestAmount, Direction, SubProductName,
       COUNT(*) OVER () AS TotCnt, SUM(PrincipalAmount) OVER () AS TotPrincipal, SUM(InterestAmount) OVER () AS TotInterest,
       MIN(ValueDate) OVER () AS MinVal, MAX(ValueDate) OVER () AS MaxVal
FROM Q
ORDER BY Id DESC;
```

DB: `NetTrexMM` · Server: `tcp:192.168.10.211,1433` · User: `trusr` · Pass: `***`


## #73

**Amaç:** Test IL: Haziran 2026 valör — valör 2026-06-01–2026-06-30. API (ekran) sonucu ile karşılaştırma; TOP (20) satır alan alan, sayı/toplamlar pencere fonksiyonuyla tüm küme üzerinden.

```sql
SET NOCOUNT ON;
DECLARE @LD date = '2026-10-01';
WITH Q AS (
SELECT l.Id, l.LogicalReference, c.Name AS CounterpartyName, ROUND(l.PrincipalAmount, 2) AS PrincipalAmount, l.CurrencyCode AS Currency,
       CAST(l.ValueDate AS date) AS ValueDate, CAST(l.MaturityDate AS date) AS MaturityDate,
       CASE WHEN l.Rate IS NOT NULL AND l.Rate <> 0 THEN l.Rate ELSE ir.Rate END AS InterestRate,
       ROUND(ia.Amt, 2) AS InterestAmount, ISNULL(tt.Name, l.TxnTypeCode) AS Direction, p.Name AS SubProductName
FROM TxnLoan l
JOIN prdProductDefinition p ON p.Id = l.ProductDefinitionId AND p.IsEnabled = 1
OUTER APPLY (SELECT TOP (1) cu.Name FROM cusCustomer cu WHERE cu.Id = l.CustomerId) c
OUTER APPLY (SELECT TOP (1) x.Name FROM defTxnType x WHERE x.TxnTypeCode = l.TxnTypeCode) tt
OUTER APPLY (SELECT TOP (1) cf.Rate FROM TxnCashFlow cf WHERE cf.TxnId = l.Id AND cf.FlowTypeId = 2 ORDER BY cf.StartDate) ir
OUTER APPLY (SELECT SUM(cf.CashFlowAmount) AS Amt FROM TxnCashFlow cf WHERE cf.TxnId = l.Id AND cf.FlowTypeId = 2) ia
WHERE (l.StateId & 6) = 2 AND l.ValueDate >= '2026-06-01' AND l.ValueDate < DATEADD(day, 1, CAST('2026-06-30' AS date))
)
SELECT TOP (20) Id, LogicalReference, CounterpartyName, PrincipalAmount, Currency, ValueDate, MaturityDate,
       DATEDIFF(day, ValueDate, MaturityDate) AS OriginalTenorDays,
       CASE WHEN MaturityDate < @LD THEN 0 ELSE DATEDIFF(day, @LD, MaturityDate) END AS DaysToMaturity,
       InterestRate, InterestAmount, Direction, SubProductName,
       COUNT(*) OVER () AS TotCnt, SUM(PrincipalAmount) OVER () AS TotPrincipal, SUM(InterestAmount) OVER () AS TotInterest,
       MIN(ValueDate) OVER () AS MinVal, MAX(ValueDate) OVER () AS MaxVal
FROM Q
ORDER BY Id DESC;
```

DB: `NetTrexMM` · Server: `tcp:192.168.10.211,1433` · User: `trusr` · Pass: `***`


## #74

**Amaç:** Test IL: Yalnız valör başlangıç — valör 2026-06-15–…. API (ekran) sonucu ile karşılaştırma; TOP (20) satır alan alan, sayı/toplamlar pencere fonksiyonuyla tüm küme üzerinden.

```sql
SET NOCOUNT ON;
DECLARE @LD date = '2026-10-01';
WITH Q AS (
SELECT l.Id, l.LogicalReference, c.Name AS CounterpartyName, ROUND(l.PrincipalAmount, 2) AS PrincipalAmount, l.CurrencyCode AS Currency,
       CAST(l.ValueDate AS date) AS ValueDate, CAST(l.MaturityDate AS date) AS MaturityDate,
       CASE WHEN l.Rate IS NOT NULL AND l.Rate <> 0 THEN l.Rate ELSE ir.Rate END AS InterestRate,
       ROUND(ia.Amt, 2) AS InterestAmount, ISNULL(tt.Name, l.TxnTypeCode) AS Direction, p.Name AS SubProductName
FROM TxnLoan l
JOIN prdProductDefinition p ON p.Id = l.ProductDefinitionId AND p.IsEnabled = 1
OUTER APPLY (SELECT TOP (1) cu.Name FROM cusCustomer cu WHERE cu.Id = l.CustomerId) c
OUTER APPLY (SELECT TOP (1) x.Name FROM defTxnType x WHERE x.TxnTypeCode = l.TxnTypeCode) tt
OUTER APPLY (SELECT TOP (1) cf.Rate FROM TxnCashFlow cf WHERE cf.TxnId = l.Id AND cf.FlowTypeId = 2 ORDER BY cf.StartDate) ir
OUTER APPLY (SELECT SUM(cf.CashFlowAmount) AS Amt FROM TxnCashFlow cf WHERE cf.TxnId = l.Id AND cf.FlowTypeId = 2) ia
WHERE (l.StateId & 6) = 2 AND l.ValueDate >= '2026-06-15'
)
SELECT TOP (20) Id, LogicalReference, CounterpartyName, PrincipalAmount, Currency, ValueDate, MaturityDate,
       DATEDIFF(day, ValueDate, MaturityDate) AS OriginalTenorDays,
       CASE WHEN MaturityDate < @LD THEN 0 ELSE DATEDIFF(day, @LD, MaturityDate) END AS DaysToMaturity,
       InterestRate, InterestAmount, Direction, SubProductName,
       COUNT(*) OVER () AS TotCnt, SUM(PrincipalAmount) OVER () AS TotPrincipal, SUM(InterestAmount) OVER () AS TotInterest,
       MIN(ValueDate) OVER () AS MinVal, MAX(ValueDate) OVER () AS MaxVal
FROM Q
ORDER BY Id DESC;
```

DB: `NetTrexMM` · Server: `tcp:192.168.10.211,1433` · User: `trusr` · Pass: `***`


## #75

**Amaç:** Test IL: Yalnız valör bitiş — valör …–2026-05-15. API (ekran) sonucu ile karşılaştırma; TOP (20) satır alan alan, sayı/toplamlar pencere fonksiyonuyla tüm küme üzerinden.

```sql
SET NOCOUNT ON;
DECLARE @LD date = '2026-10-01';
WITH Q AS (
SELECT l.Id, l.LogicalReference, c.Name AS CounterpartyName, ROUND(l.PrincipalAmount, 2) AS PrincipalAmount, l.CurrencyCode AS Currency,
       CAST(l.ValueDate AS date) AS ValueDate, CAST(l.MaturityDate AS date) AS MaturityDate,
       CASE WHEN l.Rate IS NOT NULL AND l.Rate <> 0 THEN l.Rate ELSE ir.Rate END AS InterestRate,
       ROUND(ia.Amt, 2) AS InterestAmount, ISNULL(tt.Name, l.TxnTypeCode) AS Direction, p.Name AS SubProductName
FROM TxnLoan l
JOIN prdProductDefinition p ON p.Id = l.ProductDefinitionId AND p.IsEnabled = 1
OUTER APPLY (SELECT TOP (1) cu.Name FROM cusCustomer cu WHERE cu.Id = l.CustomerId) c
OUTER APPLY (SELECT TOP (1) x.Name FROM defTxnType x WHERE x.TxnTypeCode = l.TxnTypeCode) tt
OUTER APPLY (SELECT TOP (1) cf.Rate FROM TxnCashFlow cf WHERE cf.TxnId = l.Id AND cf.FlowTypeId = 2 ORDER BY cf.StartDate) ir
OUTER APPLY (SELECT SUM(cf.CashFlowAmount) AS Amt FROM TxnCashFlow cf WHERE cf.TxnId = l.Id AND cf.FlowTypeId = 2) ia
WHERE (l.StateId & 6) = 2 AND l.ValueDate < DATEADD(day, 1, CAST('2026-05-15' AS date))
)
SELECT TOP (20) Id, LogicalReference, CounterpartyName, PrincipalAmount, Currency, ValueDate, MaturityDate,
       DATEDIFF(day, ValueDate, MaturityDate) AS OriginalTenorDays,
       CASE WHEN MaturityDate < @LD THEN 0 ELSE DATEDIFF(day, @LD, MaturityDate) END AS DaysToMaturity,
       InterestRate, InterestAmount, Direction, SubProductName,
       COUNT(*) OVER () AS TotCnt, SUM(PrincipalAmount) OVER () AS TotPrincipal, SUM(InterestAmount) OVER () AS TotInterest,
       MIN(ValueDate) OVER () AS MinVal, MAX(ValueDate) OVER () AS MaxVal
FROM Q
ORDER BY Id DESC;
```

DB: `NetTrexMM` · Server: `tcp:192.168.10.211,1433` · User: `trusr` · Pass: `***`


## #76

**Amaç:** Test IL: Tek gün valör (12.06 iki uç dahil) — valör 2026-06-12–2026-06-12. API (ekran) sonucu ile karşılaştırma; TOP (20) satır alan alan, sayı/toplamlar pencere fonksiyonuyla tüm küme üzerinden.

```sql
SET NOCOUNT ON;
DECLARE @LD date = '2026-10-01';
WITH Q AS (
SELECT l.Id, l.LogicalReference, c.Name AS CounterpartyName, ROUND(l.PrincipalAmount, 2) AS PrincipalAmount, l.CurrencyCode AS Currency,
       CAST(l.ValueDate AS date) AS ValueDate, CAST(l.MaturityDate AS date) AS MaturityDate,
       CASE WHEN l.Rate IS NOT NULL AND l.Rate <> 0 THEN l.Rate ELSE ir.Rate END AS InterestRate,
       ROUND(ia.Amt, 2) AS InterestAmount, ISNULL(tt.Name, l.TxnTypeCode) AS Direction, p.Name AS SubProductName
FROM TxnLoan l
JOIN prdProductDefinition p ON p.Id = l.ProductDefinitionId AND p.IsEnabled = 1
OUTER APPLY (SELECT TOP (1) cu.Name FROM cusCustomer cu WHERE cu.Id = l.CustomerId) c
OUTER APPLY (SELECT TOP (1) x.Name FROM defTxnType x WHERE x.TxnTypeCode = l.TxnTypeCode) tt
OUTER APPLY (SELECT TOP (1) cf.Rate FROM TxnCashFlow cf WHERE cf.TxnId = l.Id AND cf.FlowTypeId = 2 ORDER BY cf.StartDate) ir
OUTER APPLY (SELECT SUM(cf.CashFlowAmount) AS Amt FROM TxnCashFlow cf WHERE cf.TxnId = l.Id AND cf.FlowTypeId = 2) ia
WHERE (l.StateId & 6) = 2 AND l.ValueDate >= '2026-06-12' AND l.ValueDate < DATEADD(day, 1, CAST('2026-06-12' AS date))
)
SELECT TOP (20) Id, LogicalReference, CounterpartyName, PrincipalAmount, Currency, ValueDate, MaturityDate,
       DATEDIFF(day, ValueDate, MaturityDate) AS OriginalTenorDays,
       CASE WHEN MaturityDate < @LD THEN 0 ELSE DATEDIFF(day, @LD, MaturityDate) END AS DaysToMaturity,
       InterestRate, InterestAmount, Direction, SubProductName,
       COUNT(*) OVER () AS TotCnt, SUM(PrincipalAmount) OVER () AS TotPrincipal, SUM(InterestAmount) OVER () AS TotInterest,
       MIN(ValueDate) OVER () AS MinVal, MAX(ValueDate) OVER () AS MaxVal
FROM Q
ORDER BY Id DESC;
```

DB: `NetTrexMM` · Server: `tcp:192.168.10.211,1433` · User: `trusr` · Pass: `***`


## #77

**Amaç:** Test IL: Vade aralığı H2 2026 — vade 2026-07-01–2026-12-31. API (ekran) sonucu ile karşılaştırma; TOP (20) satır alan alan, sayı/toplamlar pencere fonksiyonuyla tüm küme üzerinden.

```sql
SET NOCOUNT ON;
DECLARE @LD date = '2026-10-01';
WITH Q AS (
SELECT l.Id, l.LogicalReference, c.Name AS CounterpartyName, ROUND(l.PrincipalAmount, 2) AS PrincipalAmount, l.CurrencyCode AS Currency,
       CAST(l.ValueDate AS date) AS ValueDate, CAST(l.MaturityDate AS date) AS MaturityDate,
       CASE WHEN l.Rate IS NOT NULL AND l.Rate <> 0 THEN l.Rate ELSE ir.Rate END AS InterestRate,
       ROUND(ia.Amt, 2) AS InterestAmount, ISNULL(tt.Name, l.TxnTypeCode) AS Direction, p.Name AS SubProductName
FROM TxnLoan l
JOIN prdProductDefinition p ON p.Id = l.ProductDefinitionId AND p.IsEnabled = 1
OUTER APPLY (SELECT TOP (1) cu.Name FROM cusCustomer cu WHERE cu.Id = l.CustomerId) c
OUTER APPLY (SELECT TOP (1) x.Name FROM defTxnType x WHERE x.TxnTypeCode = l.TxnTypeCode) tt
OUTER APPLY (SELECT TOP (1) cf.Rate FROM TxnCashFlow cf WHERE cf.TxnId = l.Id AND cf.FlowTypeId = 2 ORDER BY cf.StartDate) ir
OUTER APPLY (SELECT SUM(cf.CashFlowAmount) AS Amt FROM TxnCashFlow cf WHERE cf.TxnId = l.Id AND cf.FlowTypeId = 2) ia
WHERE (l.StateId & 6) = 2 AND l.MaturityDate >= '2026-07-01' AND l.MaturityDate < DATEADD(day, 1, CAST('2026-12-31' AS date))
)
SELECT TOP (20) Id, LogicalReference, CounterpartyName, PrincipalAmount, Currency, ValueDate, MaturityDate,
       DATEDIFF(day, ValueDate, MaturityDate) AS OriginalTenorDays,
       CASE WHEN MaturityDate < @LD THEN 0 ELSE DATEDIFF(day, @LD, MaturityDate) END AS DaysToMaturity,
       InterestRate, InterestAmount, Direction, SubProductName,
       COUNT(*) OVER () AS TotCnt, SUM(PrincipalAmount) OVER () AS TotPrincipal, SUM(InterestAmount) OVER () AS TotInterest,
       MIN(ValueDate) OVER () AS MinVal, MAX(ValueDate) OVER () AS MaxVal
FROM Q
ORDER BY Id DESC;
```

DB: `NetTrexMM` · Server: `tcp:192.168.10.211,1433` · User: `trusr` · Pass: `***`


## #78

**Amaç:** Test IL: Yalnız vade başlangıç (2027+) — vade 2027-01-01–…. API (ekran) sonucu ile karşılaştırma; TOP (20) satır alan alan, sayı/toplamlar pencere fonksiyonuyla tüm küme üzerinden.

```sql
SET NOCOUNT ON;
DECLARE @LD date = '2026-10-01';
WITH Q AS (
SELECT l.Id, l.LogicalReference, c.Name AS CounterpartyName, ROUND(l.PrincipalAmount, 2) AS PrincipalAmount, l.CurrencyCode AS Currency,
       CAST(l.ValueDate AS date) AS ValueDate, CAST(l.MaturityDate AS date) AS MaturityDate,
       CASE WHEN l.Rate IS NOT NULL AND l.Rate <> 0 THEN l.Rate ELSE ir.Rate END AS InterestRate,
       ROUND(ia.Amt, 2) AS InterestAmount, ISNULL(tt.Name, l.TxnTypeCode) AS Direction, p.Name AS SubProductName
FROM TxnLoan l
JOIN prdProductDefinition p ON p.Id = l.ProductDefinitionId AND p.IsEnabled = 1
OUTER APPLY (SELECT TOP (1) cu.Name FROM cusCustomer cu WHERE cu.Id = l.CustomerId) c
OUTER APPLY (SELECT TOP (1) x.Name FROM defTxnType x WHERE x.TxnTypeCode = l.TxnTypeCode) tt
OUTER APPLY (SELECT TOP (1) cf.Rate FROM TxnCashFlow cf WHERE cf.TxnId = l.Id AND cf.FlowTypeId = 2 ORDER BY cf.StartDate) ir
OUTER APPLY (SELECT SUM(cf.CashFlowAmount) AS Amt FROM TxnCashFlow cf WHERE cf.TxnId = l.Id AND cf.FlowTypeId = 2) ia
WHERE (l.StateId & 6) = 2 AND l.MaturityDate >= '2027-01-01'
)
SELECT TOP (20) Id, LogicalReference, CounterpartyName, PrincipalAmount, Currency, ValueDate, MaturityDate,
       DATEDIFF(day, ValueDate, MaturityDate) AS OriginalTenorDays,
       CASE WHEN MaturityDate < @LD THEN 0 ELSE DATEDIFF(day, @LD, MaturityDate) END AS DaysToMaturity,
       InterestRate, InterestAmount, Direction, SubProductName,
       COUNT(*) OVER () AS TotCnt, SUM(PrincipalAmount) OVER () AS TotPrincipal, SUM(InterestAmount) OVER () AS TotInterest,
       MIN(ValueDate) OVER () AS MinVal, MAX(ValueDate) OVER () AS MaxVal
FROM Q
ORDER BY Id DESC;
```

DB: `NetTrexMM` · Server: `tcp:192.168.10.211,1433` · User: `trusr` · Pass: `***`


## #79

**Amaç:** Test IL: Yalnız vade bitiş — vade …–2026-06-30. API (ekran) sonucu ile karşılaştırma; TOP (20) satır alan alan, sayı/toplamlar pencere fonksiyonuyla tüm küme üzerinden.

```sql
SET NOCOUNT ON;
DECLARE @LD date = '2026-10-01';
WITH Q AS (
SELECT l.Id, l.LogicalReference, c.Name AS CounterpartyName, ROUND(l.PrincipalAmount, 2) AS PrincipalAmount, l.CurrencyCode AS Currency,
       CAST(l.ValueDate AS date) AS ValueDate, CAST(l.MaturityDate AS date) AS MaturityDate,
       CASE WHEN l.Rate IS NOT NULL AND l.Rate <> 0 THEN l.Rate ELSE ir.Rate END AS InterestRate,
       ROUND(ia.Amt, 2) AS InterestAmount, ISNULL(tt.Name, l.TxnTypeCode) AS Direction, p.Name AS SubProductName
FROM TxnLoan l
JOIN prdProductDefinition p ON p.Id = l.ProductDefinitionId AND p.IsEnabled = 1
OUTER APPLY (SELECT TOP (1) cu.Name FROM cusCustomer cu WHERE cu.Id = l.CustomerId) c
OUTER APPLY (SELECT TOP (1) x.Name FROM defTxnType x WHERE x.TxnTypeCode = l.TxnTypeCode) tt
OUTER APPLY (SELECT TOP (1) cf.Rate FROM TxnCashFlow cf WHERE cf.TxnId = l.Id AND cf.FlowTypeId = 2 ORDER BY cf.StartDate) ir
OUTER APPLY (SELECT SUM(cf.CashFlowAmount) AS Amt FROM TxnCashFlow cf WHERE cf.TxnId = l.Id AND cf.FlowTypeId = 2) ia
WHERE (l.StateId & 6) = 2 AND l.MaturityDate < DATEADD(day, 1, CAST('2026-06-30' AS date))
)
SELECT TOP (20) Id, LogicalReference, CounterpartyName, PrincipalAmount, Currency, ValueDate, MaturityDate,
       DATEDIFF(day, ValueDate, MaturityDate) AS OriginalTenorDays,
       CASE WHEN MaturityDate < @LD THEN 0 ELSE DATEDIFF(day, @LD, MaturityDate) END AS DaysToMaturity,
       InterestRate, InterestAmount, Direction, SubProductName,
       COUNT(*) OVER () AS TotCnt, SUM(PrincipalAmount) OVER () AS TotPrincipal, SUM(InterestAmount) OVER () AS TotInterest,
       MIN(ValueDate) OVER () AS MinVal, MAX(ValueDate) OVER () AS MaxVal
FROM Q
ORDER BY Id DESC;
```

DB: `NetTrexMM` · Server: `tcp:192.168.10.211,1433` · User: `trusr` · Pass: `***`


## #80

**Amaç:** Test IL: Tek gün vade (15.06) — vade 2026-06-15–2026-06-15. API (ekran) sonucu ile karşılaştırma; TOP (20) satır alan alan, sayı/toplamlar pencere fonksiyonuyla tüm küme üzerinden.

```sql
SET NOCOUNT ON;
DECLARE @LD date = '2026-10-01';
WITH Q AS (
SELECT l.Id, l.LogicalReference, c.Name AS CounterpartyName, ROUND(l.PrincipalAmount, 2) AS PrincipalAmount, l.CurrencyCode AS Currency,
       CAST(l.ValueDate AS date) AS ValueDate, CAST(l.MaturityDate AS date) AS MaturityDate,
       CASE WHEN l.Rate IS NOT NULL AND l.Rate <> 0 THEN l.Rate ELSE ir.Rate END AS InterestRate,
       ROUND(ia.Amt, 2) AS InterestAmount, ISNULL(tt.Name, l.TxnTypeCode) AS Direction, p.Name AS SubProductName
FROM TxnLoan l
JOIN prdProductDefinition p ON p.Id = l.ProductDefinitionId AND p.IsEnabled = 1
OUTER APPLY (SELECT TOP (1) cu.Name FROM cusCustomer cu WHERE cu.Id = l.CustomerId) c
OUTER APPLY (SELECT TOP (1) x.Name FROM defTxnType x WHERE x.TxnTypeCode = l.TxnTypeCode) tt
OUTER APPLY (SELECT TOP (1) cf.Rate FROM TxnCashFlow cf WHERE cf.TxnId = l.Id AND cf.FlowTypeId = 2 ORDER BY cf.StartDate) ir
OUTER APPLY (SELECT SUM(cf.CashFlowAmount) AS Amt FROM TxnCashFlow cf WHERE cf.TxnId = l.Id AND cf.FlowTypeId = 2) ia
WHERE (l.StateId & 6) = 2 AND l.MaturityDate >= '2026-06-15' AND l.MaturityDate < DATEADD(day, 1, CAST('2026-06-15' AS date))
)
SELECT TOP (20) Id, LogicalReference, CounterpartyName, PrincipalAmount, Currency, ValueDate, MaturityDate,
       DATEDIFF(day, ValueDate, MaturityDate) AS OriginalTenorDays,
       CASE WHEN MaturityDate < @LD THEN 0 ELSE DATEDIFF(day, @LD, MaturityDate) END AS DaysToMaturity,
       InterestRate, InterestAmount, Direction, SubProductName,
       COUNT(*) OVER () AS TotCnt, SUM(PrincipalAmount) OVER () AS TotPrincipal, SUM(InterestAmount) OVER () AS TotInterest,
       MIN(ValueDate) OVER () AS MinVal, MAX(ValueDate) OVER () AS MaxVal
FROM Q
ORDER BY Id DESC;
```

DB: `NetTrexMM` · Server: `tcp:192.168.10.211,1433` · User: `trusr` · Pass: `***`


## #81

**Amaç:** Test IL: Valör + vade birlikte — valör 2026-06-01–2026-06-30, vade 2026-09-01–2026-10-31. API (ekran) sonucu ile karşılaştırma; TOP (20) satır alan alan, sayı/toplamlar pencere fonksiyonuyla tüm küme üzerinden.

```sql
SET NOCOUNT ON;
DECLARE @LD date = '2026-10-01';
WITH Q AS (
SELECT l.Id, l.LogicalReference, c.Name AS CounterpartyName, ROUND(l.PrincipalAmount, 2) AS PrincipalAmount, l.CurrencyCode AS Currency,
       CAST(l.ValueDate AS date) AS ValueDate, CAST(l.MaturityDate AS date) AS MaturityDate,
       CASE WHEN l.Rate IS NOT NULL AND l.Rate <> 0 THEN l.Rate ELSE ir.Rate END AS InterestRate,
       ROUND(ia.Amt, 2) AS InterestAmount, ISNULL(tt.Name, l.TxnTypeCode) AS Direction, p.Name AS SubProductName
FROM TxnLoan l
JOIN prdProductDefinition p ON p.Id = l.ProductDefinitionId AND p.IsEnabled = 1
OUTER APPLY (SELECT TOP (1) cu.Name FROM cusCustomer cu WHERE cu.Id = l.CustomerId) c
OUTER APPLY (SELECT TOP (1) x.Name FROM defTxnType x WHERE x.TxnTypeCode = l.TxnTypeCode) tt
OUTER APPLY (SELECT TOP (1) cf.Rate FROM TxnCashFlow cf WHERE cf.TxnId = l.Id AND cf.FlowTypeId = 2 ORDER BY cf.StartDate) ir
OUTER APPLY (SELECT SUM(cf.CashFlowAmount) AS Amt FROM TxnCashFlow cf WHERE cf.TxnId = l.Id AND cf.FlowTypeId = 2) ia
WHERE (l.StateId & 6) = 2 AND l.ValueDate >= '2026-06-01' AND l.ValueDate < DATEADD(day, 1, CAST('2026-06-30' AS date)) AND l.MaturityDate >= '2026-09-01' AND l.MaturityDate < DATEADD(day, 1, CAST('2026-10-31' AS date))
)
SELECT TOP (20) Id, LogicalReference, CounterpartyName, PrincipalAmount, Currency, ValueDate, MaturityDate,
       DATEDIFF(day, ValueDate, MaturityDate) AS OriginalTenorDays,
       CASE WHEN MaturityDate < @LD THEN 0 ELSE DATEDIFF(day, @LD, MaturityDate) END AS DaysToMaturity,
       InterestRate, InterestAmount, Direction, SubProductName,
       COUNT(*) OVER () AS TotCnt, SUM(PrincipalAmount) OVER () AS TotPrincipal, SUM(InterestAmount) OVER () AS TotInterest,
       MIN(ValueDate) OVER () AS MinVal, MAX(ValueDate) OVER () AS MaxVal
FROM Q
ORDER BY Id DESC;
```

DB: `NetTrexMM` · Server: `tcp:192.168.10.211,1433` · User: `trusr` · Pass: `***`


## #82

**Amaç:** Test IL: Tüm aralık, tüm alt ürünler — valör 2020-01-01–2030-12-31. API (ekran) sonucu ile karşılaştırma; TOP (20) satır alan alan, sayı/toplamlar pencere fonksiyonuyla tüm küme üzerinden.

```sql
SET NOCOUNT ON;
DECLARE @LD date = '2026-10-01';
WITH Q AS (
SELECT l.Id, l.LogicalReference, c.Name AS CounterpartyName, ROUND(l.PrincipalAmount, 2) AS PrincipalAmount, l.CurrencyCode AS Currency,
       CAST(l.ValueDate AS date) AS ValueDate, CAST(l.MaturityDate AS date) AS MaturityDate,
       CASE WHEN l.Rate IS NOT NULL AND l.Rate <> 0 THEN l.Rate ELSE ir.Rate END AS InterestRate,
       ROUND(ia.Amt, 2) AS InterestAmount, ISNULL(tt.Name, l.TxnTypeCode) AS Direction, p.Name AS SubProductName
FROM TxnLoan l
JOIN prdProductDefinition p ON p.Id = l.ProductDefinitionId AND p.IsEnabled = 1
OUTER APPLY (SELECT TOP (1) cu.Name FROM cusCustomer cu WHERE cu.Id = l.CustomerId) c
OUTER APPLY (SELECT TOP (1) x.Name FROM defTxnType x WHERE x.TxnTypeCode = l.TxnTypeCode) tt
OUTER APPLY (SELECT TOP (1) cf.Rate FROM TxnCashFlow cf WHERE cf.TxnId = l.Id AND cf.FlowTypeId = 2 ORDER BY cf.StartDate) ir
OUTER APPLY (SELECT SUM(cf.CashFlowAmount) AS Amt FROM TxnCashFlow cf WHERE cf.TxnId = l.Id AND cf.FlowTypeId = 2) ia
WHERE (l.StateId & 6) = 2 AND l.ValueDate >= '2020-01-01' AND l.ValueDate < DATEADD(day, 1, CAST('2030-12-31' AS date))
)
SELECT TOP (20) Id, LogicalReference, CounterpartyName, PrincipalAmount, Currency, ValueDate, MaturityDate,
       DATEDIFF(day, ValueDate, MaturityDate) AS OriginalTenorDays,
       CASE WHEN MaturityDate < @LD THEN 0 ELSE DATEDIFF(day, @LD, MaturityDate) END AS DaysToMaturity,
       InterestRate, InterestAmount, Direction, SubProductName,
       COUNT(*) OVER () AS TotCnt, SUM(PrincipalAmount) OVER () AS TotPrincipal, SUM(InterestAmount) OVER () AS TotInterest,
       MIN(ValueDate) OVER () AS MinVal, MAX(ValueDate) OVER () AS MaxVal
FROM Q
ORDER BY Id DESC;
```

DB: `NetTrexMM` · Server: `tcp:192.168.10.211,1433` · User: `trusr` · Pass: `***`


## #83

**Amaç:** Test IL: Alt ürün: Interbank Loan — valör 2020-01-01–…, alt ürün [Loan]. API (ekran) sonucu ile karşılaştırma; TOP (20) satır alan alan, sayı/toplamlar pencere fonksiyonuyla tüm küme üzerinden.

```sql
SET NOCOUNT ON;
DECLARE @LD date = '2026-10-01';
WITH Q AS (
SELECT l.Id, l.LogicalReference, c.Name AS CounterpartyName, ROUND(l.PrincipalAmount, 2) AS PrincipalAmount, l.CurrencyCode AS Currency,
       CAST(l.ValueDate AS date) AS ValueDate, CAST(l.MaturityDate AS date) AS MaturityDate,
       CASE WHEN l.Rate IS NOT NULL AND l.Rate <> 0 THEN l.Rate ELSE ir.Rate END AS InterestRate,
       ROUND(ia.Amt, 2) AS InterestAmount, ISNULL(tt.Name, l.TxnTypeCode) AS Direction, p.Name AS SubProductName
FROM TxnLoan l
JOIN prdProductDefinition p ON p.Id = l.ProductDefinitionId AND p.IsEnabled = 1
OUTER APPLY (SELECT TOP (1) cu.Name FROM cusCustomer cu WHERE cu.Id = l.CustomerId) c
OUTER APPLY (SELECT TOP (1) x.Name FROM defTxnType x WHERE x.TxnTypeCode = l.TxnTypeCode) tt
OUTER APPLY (SELECT TOP (1) cf.Rate FROM TxnCashFlow cf WHERE cf.TxnId = l.Id AND cf.FlowTypeId = 2 ORDER BY cf.StartDate) ir
OUTER APPLY (SELECT SUM(cf.CashFlowAmount) AS Amt FROM TxnCashFlow cf WHERE cf.TxnId = l.Id AND cf.FlowTypeId = 2) ia
WHERE (l.StateId & 6) = 2 AND l.ValueDate >= '2020-01-01' AND p.MainProductCode = 'MM' AND p.Code IN ('Loan')
)
SELECT TOP (20) Id, LogicalReference, CounterpartyName, PrincipalAmount, Currency, ValueDate, MaturityDate,
       DATEDIFF(day, ValueDate, MaturityDate) AS OriginalTenorDays,
       CASE WHEN MaturityDate < @LD THEN 0 ELSE DATEDIFF(day, @LD, MaturityDate) END AS DaysToMaturity,
       InterestRate, InterestAmount, Direction, SubProductName,
       COUNT(*) OVER () AS TotCnt, SUM(PrincipalAmount) OVER () AS TotPrincipal, SUM(InterestAmount) OVER () AS TotInterest,
       MIN(ValueDate) OVER () AS MinVal, MAX(ValueDate) OVER () AS MaxVal
FROM Q
ORDER BY Id DESC;
```

DB: `NetTrexMM` · Server: `tcp:192.168.10.211,1433` · User: `trusr` · Pass: `***`


## #84

**Amaç:** Test IL: Alt ürün: Money Market (IL'de yok) — valör 2020-01-01–…, alt ürün [MoneyMarket]. API (ekran) sonucu ile karşılaştırma; TOP (20) satır alan alan, sayı/toplamlar pencere fonksiyonuyla tüm küme üzerinden.

```sql
SET NOCOUNT ON;
DECLARE @LD date = '2026-10-01';
WITH Q AS (
SELECT l.Id, l.LogicalReference, c.Name AS CounterpartyName, ROUND(l.PrincipalAmount, 2) AS PrincipalAmount, l.CurrencyCode AS Currency,
       CAST(l.ValueDate AS date) AS ValueDate, CAST(l.MaturityDate AS date) AS MaturityDate,
       CASE WHEN l.Rate IS NOT NULL AND l.Rate <> 0 THEN l.Rate ELSE ir.Rate END AS InterestRate,
       ROUND(ia.Amt, 2) AS InterestAmount, ISNULL(tt.Name, l.TxnTypeCode) AS Direction, p.Name AS SubProductName
FROM TxnLoan l
JOIN prdProductDefinition p ON p.Id = l.ProductDefinitionId AND p.IsEnabled = 1
OUTER APPLY (SELECT TOP (1) cu.Name FROM cusCustomer cu WHERE cu.Id = l.CustomerId) c
OUTER APPLY (SELECT TOP (1) x.Name FROM defTxnType x WHERE x.TxnTypeCode = l.TxnTypeCode) tt
OUTER APPLY (SELECT TOP (1) cf.Rate FROM TxnCashFlow cf WHERE cf.TxnId = l.Id AND cf.FlowTypeId = 2 ORDER BY cf.StartDate) ir
OUTER APPLY (SELECT SUM(cf.CashFlowAmount) AS Amt FROM TxnCashFlow cf WHERE cf.TxnId = l.Id AND cf.FlowTypeId = 2) ia
WHERE (l.StateId & 6) = 2 AND l.ValueDate >= '2020-01-01' AND p.MainProductCode = 'MM' AND p.Code IN ('MoneyMarket')
)
SELECT TOP (20) Id, LogicalReference, CounterpartyName, PrincipalAmount, Currency, ValueDate, MaturityDate,
       DATEDIFF(day, ValueDate, MaturityDate) AS OriginalTenorDays,
       CASE WHEN MaturityDate < @LD THEN 0 ELSE DATEDIFF(day, @LD, MaturityDate) END AS DaysToMaturity,
       InterestRate, InterestAmount, Direction, SubProductName,
       COUNT(*) OVER () AS TotCnt, SUM(PrincipalAmount) OVER () AS TotPrincipal, SUM(InterestAmount) OVER () AS TotInterest,
       MIN(ValueDate) OVER () AS MinVal, MAX(ValueDate) OVER () AS MaxVal
FROM Q
ORDER BY Id DESC;
```

DB: `NetTrexMM` · Server: `tcp:192.168.10.211,1433` · User: `trusr` · Pass: `***`


## #85

**Amaç:** Test IL: Alt ürün: Loan + Murabaha — valör 2026-06-01–2026-06-30, alt ürün [Loan,Murabaha]. API (ekran) sonucu ile karşılaştırma; TOP (20) satır alan alan, sayı/toplamlar pencere fonksiyonuyla tüm küme üzerinden.

```sql
SET NOCOUNT ON;
DECLARE @LD date = '2026-10-01';
WITH Q AS (
SELECT l.Id, l.LogicalReference, c.Name AS CounterpartyName, ROUND(l.PrincipalAmount, 2) AS PrincipalAmount, l.CurrencyCode AS Currency,
       CAST(l.ValueDate AS date) AS ValueDate, CAST(l.MaturityDate AS date) AS MaturityDate,
       CASE WHEN l.Rate IS NOT NULL AND l.Rate <> 0 THEN l.Rate ELSE ir.Rate END AS InterestRate,
       ROUND(ia.Amt, 2) AS InterestAmount, ISNULL(tt.Name, l.TxnTypeCode) AS Direction, p.Name AS SubProductName
FROM TxnLoan l
JOIN prdProductDefinition p ON p.Id = l.ProductDefinitionId AND p.IsEnabled = 1
OUTER APPLY (SELECT TOP (1) cu.Name FROM cusCustomer cu WHERE cu.Id = l.CustomerId) c
OUTER APPLY (SELECT TOP (1) x.Name FROM defTxnType x WHERE x.TxnTypeCode = l.TxnTypeCode) tt
OUTER APPLY (SELECT TOP (1) cf.Rate FROM TxnCashFlow cf WHERE cf.TxnId = l.Id AND cf.FlowTypeId = 2 ORDER BY cf.StartDate) ir
OUTER APPLY (SELECT SUM(cf.CashFlowAmount) AS Amt FROM TxnCashFlow cf WHERE cf.TxnId = l.Id AND cf.FlowTypeId = 2) ia
WHERE (l.StateId & 6) = 2 AND l.ValueDate >= '2026-06-01' AND l.ValueDate < DATEADD(day, 1, CAST('2026-06-30' AS date)) AND p.MainProductCode = 'MM' AND p.Code IN ('Loan', 'Murabaha')
)
SELECT TOP (20) Id, LogicalReference, CounterpartyName, PrincipalAmount, Currency, ValueDate, MaturityDate,
       DATEDIFF(day, ValueDate, MaturityDate) AS OriginalTenorDays,
       CASE WHEN MaturityDate < @LD THEN 0 ELSE DATEDIFF(day, @LD, MaturityDate) END AS DaysToMaturity,
       InterestRate, InterestAmount, Direction, SubProductName,
       COUNT(*) OVER () AS TotCnt, SUM(PrincipalAmount) OVER () AS TotPrincipal, SUM(InterestAmount) OVER () AS TotInterest,
       MIN(ValueDate) OVER () AS MinVal, MAX(ValueDate) OVER () AS MaxVal
FROM Q
ORDER BY Id DESC;
```

DB: `NetTrexMM` · Server: `tcp:192.168.10.211,1433` · User: `trusr` · Pass: `***`


## #86

**Amaç:** Test IL: Yalnız referans (tarih yok) — ref 'TLNPLC'. API (ekran) sonucu ile karşılaştırma; TOP (20) satır alan alan, sayı/toplamlar pencere fonksiyonuyla tüm küme üzerinden.

```sql
SET NOCOUNT ON;
DECLARE @LD date = '2026-10-01';
WITH Q AS (
SELECT l.Id, l.LogicalReference, c.Name AS CounterpartyName, ROUND(l.PrincipalAmount, 2) AS PrincipalAmount, l.CurrencyCode AS Currency,
       CAST(l.ValueDate AS date) AS ValueDate, CAST(l.MaturityDate AS date) AS MaturityDate,
       CASE WHEN l.Rate IS NOT NULL AND l.Rate <> 0 THEN l.Rate ELSE ir.Rate END AS InterestRate,
       ROUND(ia.Amt, 2) AS InterestAmount, ISNULL(tt.Name, l.TxnTypeCode) AS Direction, p.Name AS SubProductName
FROM TxnLoan l
JOIN prdProductDefinition p ON p.Id = l.ProductDefinitionId AND p.IsEnabled = 1
OUTER APPLY (SELECT TOP (1) cu.Name FROM cusCustomer cu WHERE cu.Id = l.CustomerId) c
OUTER APPLY (SELECT TOP (1) x.Name FROM defTxnType x WHERE x.TxnTypeCode = l.TxnTypeCode) tt
OUTER APPLY (SELECT TOP (1) cf.Rate FROM TxnCashFlow cf WHERE cf.TxnId = l.Id AND cf.FlowTypeId = 2 ORDER BY cf.StartDate) ir
OUTER APPLY (SELECT SUM(cf.CashFlowAmount) AS Amt FROM TxnCashFlow cf WHERE cf.TxnId = l.Id AND cf.FlowTypeId = 2) ia
WHERE (l.StateId & 6) = 2 AND l.LogicalReference LIKE '%TLNPLC%'
)
SELECT TOP (20) Id, LogicalReference, CounterpartyName, PrincipalAmount, Currency, ValueDate, MaturityDate,
       DATEDIFF(day, ValueDate, MaturityDate) AS OriginalTenorDays,
       CASE WHEN MaturityDate < @LD THEN 0 ELSE DATEDIFF(day, @LD, MaturityDate) END AS DaysToMaturity,
       InterestRate, InterestAmount, Direction, SubProductName,
       COUNT(*) OVER () AS TotCnt, SUM(PrincipalAmount) OVER () AS TotPrincipal, SUM(InterestAmount) OVER () AS TotInterest,
       MIN(ValueDate) OVER () AS MinVal, MAX(ValueDate) OVER () AS MaxVal
FROM Q
ORDER BY Id DESC;
```

DB: `NetTrexMM` · Server: `tcp:192.168.10.211,1433` · User: `trusr` · Pass: `***`


## #87

**Amaç:** Test IL: Referans + tarih — valör 2026-06-01–2026-06-30, ref 'BRW'. API (ekran) sonucu ile karşılaştırma; TOP (20) satır alan alan, sayı/toplamlar pencere fonksiyonuyla tüm küme üzerinden.

```sql
SET NOCOUNT ON;
DECLARE @LD date = '2026-10-01';
WITH Q AS (
SELECT l.Id, l.LogicalReference, c.Name AS CounterpartyName, ROUND(l.PrincipalAmount, 2) AS PrincipalAmount, l.CurrencyCode AS Currency,
       CAST(l.ValueDate AS date) AS ValueDate, CAST(l.MaturityDate AS date) AS MaturityDate,
       CASE WHEN l.Rate IS NOT NULL AND l.Rate <> 0 THEN l.Rate ELSE ir.Rate END AS InterestRate,
       ROUND(ia.Amt, 2) AS InterestAmount, ISNULL(tt.Name, l.TxnTypeCode) AS Direction, p.Name AS SubProductName
FROM TxnLoan l
JOIN prdProductDefinition p ON p.Id = l.ProductDefinitionId AND p.IsEnabled = 1
OUTER APPLY (SELECT TOP (1) cu.Name FROM cusCustomer cu WHERE cu.Id = l.CustomerId) c
OUTER APPLY (SELECT TOP (1) x.Name FROM defTxnType x WHERE x.TxnTypeCode = l.TxnTypeCode) tt
OUTER APPLY (SELECT TOP (1) cf.Rate FROM TxnCashFlow cf WHERE cf.TxnId = l.Id AND cf.FlowTypeId = 2 ORDER BY cf.StartDate) ir
OUTER APPLY (SELECT SUM(cf.CashFlowAmount) AS Amt FROM TxnCashFlow cf WHERE cf.TxnId = l.Id AND cf.FlowTypeId = 2) ia
WHERE (l.StateId & 6) = 2 AND l.ValueDate >= '2026-06-01' AND l.ValueDate < DATEADD(day, 1, CAST('2026-06-30' AS date)) AND l.LogicalReference LIKE '%BRW%'
)
SELECT TOP (20) Id, LogicalReference, CounterpartyName, PrincipalAmount, Currency, ValueDate, MaturityDate,
       DATEDIFF(day, ValueDate, MaturityDate) AS OriginalTenorDays,
       CASE WHEN MaturityDate < @LD THEN 0 ELSE DATEDIFF(day, @LD, MaturityDate) END AS DaysToMaturity,
       InterestRate, InterestAmount, Direction, SubProductName,
       COUNT(*) OVER () AS TotCnt, SUM(PrincipalAmount) OVER () AS TotPrincipal, SUM(InterestAmount) OVER () AS TotInterest,
       MIN(ValueDate) OVER () AS MinVal, MAX(ValueDate) OVER () AS MaxVal
FROM Q
ORDER BY Id DESC;
```

DB: `NetTrexMM` · Server: `tcp:192.168.10.211,1433` · User: `trusr` · Pass: `***`


## #88

**Amaç:** Test IL: Tam referans (faiz oranı boş kayıt) — ref 'TLNBRW2606200001'. API (ekran) sonucu ile karşılaştırma; TOP (20) satır alan alan, sayı/toplamlar pencere fonksiyonuyla tüm küme üzerinden.

```sql
SET NOCOUNT ON;
DECLARE @LD date = '2026-10-01';
WITH Q AS (
SELECT l.Id, l.LogicalReference, c.Name AS CounterpartyName, ROUND(l.PrincipalAmount, 2) AS PrincipalAmount, l.CurrencyCode AS Currency,
       CAST(l.ValueDate AS date) AS ValueDate, CAST(l.MaturityDate AS date) AS MaturityDate,
       CASE WHEN l.Rate IS NOT NULL AND l.Rate <> 0 THEN l.Rate ELSE ir.Rate END AS InterestRate,
       ROUND(ia.Amt, 2) AS InterestAmount, ISNULL(tt.Name, l.TxnTypeCode) AS Direction, p.Name AS SubProductName
FROM TxnLoan l
JOIN prdProductDefinition p ON p.Id = l.ProductDefinitionId AND p.IsEnabled = 1
OUTER APPLY (SELECT TOP (1) cu.Name FROM cusCustomer cu WHERE cu.Id = l.CustomerId) c
OUTER APPLY (SELECT TOP (1) x.Name FROM defTxnType x WHERE x.TxnTypeCode = l.TxnTypeCode) tt
OUTER APPLY (SELECT TOP (1) cf.Rate FROM TxnCashFlow cf WHERE cf.TxnId = l.Id AND cf.FlowTypeId = 2 ORDER BY cf.StartDate) ir
OUTER APPLY (SELECT SUM(cf.CashFlowAmount) AS Amt FROM TxnCashFlow cf WHERE cf.TxnId = l.Id AND cf.FlowTypeId = 2) ia
WHERE (l.StateId & 6) = 2 AND l.LogicalReference LIKE '%TLNBRW2606200001%'
)
SELECT TOP (20) Id, LogicalReference, CounterpartyName, PrincipalAmount, Currency, ValueDate, MaturityDate,
       DATEDIFF(day, ValueDate, MaturityDate) AS OriginalTenorDays,
       CASE WHEN MaturityDate < @LD THEN 0 ELSE DATEDIFF(day, @LD, MaturityDate) END AS DaysToMaturity,
       InterestRate, InterestAmount, Direction, SubProductName,
       COUNT(*) OVER () AS TotCnt, SUM(PrincipalAmount) OVER () AS TotPrincipal, SUM(InterestAmount) OVER () AS TotInterest,
       MIN(ValueDate) OVER () AS MinVal, MAX(ValueDate) OVER () AS MaxVal
FROM Q
ORDER BY Id DESC;
```

DB: `NetTrexMM` · Server: `tcp:192.168.10.211,1433` · User: `trusr` · Pass: `***`


## #89

**Amaç:** Test IL: Tam referans (faiz oranı 0 kayıt) — ref 'TLNBRW2606120006'. API (ekran) sonucu ile karşılaştırma; TOP (20) satır alan alan, sayı/toplamlar pencere fonksiyonuyla tüm küme üzerinden.

```sql
SET NOCOUNT ON;
DECLARE @LD date = '2026-10-01';
WITH Q AS (
SELECT l.Id, l.LogicalReference, c.Name AS CounterpartyName, ROUND(l.PrincipalAmount, 2) AS PrincipalAmount, l.CurrencyCode AS Currency,
       CAST(l.ValueDate AS date) AS ValueDate, CAST(l.MaturityDate AS date) AS MaturityDate,
       CASE WHEN l.Rate IS NOT NULL AND l.Rate <> 0 THEN l.Rate ELSE ir.Rate END AS InterestRate,
       ROUND(ia.Amt, 2) AS InterestAmount, ISNULL(tt.Name, l.TxnTypeCode) AS Direction, p.Name AS SubProductName
FROM TxnLoan l
JOIN prdProductDefinition p ON p.Id = l.ProductDefinitionId AND p.IsEnabled = 1
OUTER APPLY (SELECT TOP (1) cu.Name FROM cusCustomer cu WHERE cu.Id = l.CustomerId) c
OUTER APPLY (SELECT TOP (1) x.Name FROM defTxnType x WHERE x.TxnTypeCode = l.TxnTypeCode) tt
OUTER APPLY (SELECT TOP (1) cf.Rate FROM TxnCashFlow cf WHERE cf.TxnId = l.Id AND cf.FlowTypeId = 2 ORDER BY cf.StartDate) ir
OUTER APPLY (SELECT SUM(cf.CashFlowAmount) AS Amt FROM TxnCashFlow cf WHERE cf.TxnId = l.Id AND cf.FlowTypeId = 2) ia
WHERE (l.StateId & 6) = 2 AND l.LogicalReference LIKE '%TLNBRW2606120006%'
)
SELECT TOP (20) Id, LogicalReference, CounterpartyName, PrincipalAmount, Currency, ValueDate, MaturityDate,
       DATEDIFF(day, ValueDate, MaturityDate) AS OriginalTenorDays,
       CASE WHEN MaturityDate < @LD THEN 0 ELSE DATEDIFF(day, @LD, MaturityDate) END AS DaysToMaturity,
       InterestRate, InterestAmount, Direction, SubProductName,
       COUNT(*) OVER () AS TotCnt, SUM(PrincipalAmount) OVER () AS TotPrincipal, SUM(InterestAmount) OVER () AS TotInterest,
       MIN(ValueDate) OVER () AS MinVal, MAX(ValueDate) OVER () AS MaxVal
FROM Q
ORDER BY Id DESC;
```

DB: `NetTrexMM` · Server: `tcp:192.168.10.211,1433` · User: `trusr` · Pass: `***`


## #90

**Amaç:** Test FX Swap: Ekran varsayılanı (bu ay) — valör 2026-10-01–2026-10-31. API (ekran) gruplanmış satırları ile karşılaştırma (aynı join/gruplama/oran formülü).

```sql
SET NOCOUNT ON;
DECLARE @LD date = '2026-10-02';
WITH N AS (SELECT * FROM TxnFXSwap WHERE InstrumentId = 1068 AND (StateId & 6) = 2 AND ValueDate >= '2026-10-01' AND ValueDate < DATEADD(day, 1, CAST('2026-10-31' AS date))),
F AS (SELECT * FROM TxnFXSwap WHERE InstrumentId = 1069 AND (StateId & 6) = 2),
P AS (
    SELECT n.PkgNo, n.Id AS NearId, f.Id AS FarId, n.CustomerId, LTRIM(RTRIM(n.CcyPair)) AS CcyPair, n.LogicalReference AS NearRef,
           n.BuyCcy, n.BuyAmount, n.SellCcy, n.SellAmount, 
           CAST(n.DealRateNet AS float) AS NearRate, CAST(f.DealRateNet AS float) AS FarRate,
           CAST(n.ValueDate AS date) AS NearDate, CAST(f.ValueDate AS date) AS FarDate,
           COUNT(*) OVER () AS JoinCnt,
           ROW_NUMBER() OVER (PARTITION BY n.PkgNo ORDER BY n.Id DESC, f.Id DESC) AS Rn
    FROM N n JOIN F f ON f.PkgNo = n.PkgNo
    WHERE n.PkgNo <> 0
),
M AS (
    SELECT p.*, CASE WHEN UPPER(p.BuyCcy) = UPPER(CASE WHEN CHARINDEX('/', p.CcyPair) > 1 THEN LTRIM(RTRIM(LEFT(p.CcyPair, CHARINDEX('/', p.CcyPair) - 1)))
                                     WHEN LEN(p.CcyPair) >= 6 THEN LEFT(p.CcyPair, 3) ELSE p.BuyCcy END) THEN 1 ELSE 0 END AS BaseBought
    FROM P p WHERE p.Rn = 1
),
C AS (
    SELECT m.*, CASE WHEN BaseBought = 1 THEN 'B/S' ELSE 'S/B' END AS Direction,
           CAST(CASE WHEN BaseBought = 1 THEN SellAmount ELSE BuyAmount END AS float) AS NB,
           CASE WHEN BaseBought = 1 THEN SellCcy ELSE BuyCcy END AS NBCcy,
           CAST(0 AS float) AS Ounce, CAST(0 AS float) AS Gram,
           CASE WHEN NearRate = 0 THEN 0 ELSE (FarRate - NearRate) / NearRate * (360.0 / CASE WHEN DATEDIFF(day, NearDate, FarDate) = 0 THEN 1 ELSE DATEDIFF(day, NearDate, FarDate) END) * 100 END AS SR
    FROM M m
)
SELECT TOP (20) MAX(c.NearId) AS MaxNearId, cu.Name AS CounterpartyName, UPPER(c.CcyPair) AS CcyPair, c.Direction, c.NearDate, c.FarDate,
       DATEDIFF(day, c.NearDate, c.FarDate) AS Tenor,
       CASE WHEN c.FarDate < @LD THEN 0 ELSE DATEDIFF(day, @LD, c.FarDate) END AS DaysToMaturity,
       ROUND(SUM(c.NB), 2) AS TotalAmount, MAX(c.NBCcy) AS TotalAmountCcy,
       CASE WHEN SUM(c.NB) <> 0 THEN SUM(c.NB * c.SR) / SUM(c.NB) ELSE AVG(c.SR) END AS SwapRate,
       MAX(c.SellCcy) AS SoldCcy, ROUND(SUM(c.SellAmount), 2) AS SoldAmount, MAX(c.BuyCcy) AS BoughtCcy, ROUND(SUM(c.BuyAmount), 2) AS BoughtAmount,
       ROUND(SUM(c.Ounce), 2) AS Ounce, ROUND(SUM(c.Gram), 2) AS Gram,
       COUNT(*) AS TxnCount, STRING_AGG(c.NearRef, ', ') AS Refs,
       MAX(c.JoinCnt) AS JoinCnt, (SELECT COUNT(*) FROM M) AS PkgCnt
FROM C c
LEFT JOIN CusCustomer cu ON cu.Id = c.CustomerId
GROUP BY c.CustomerId, cu.Name, UPPER(c.CcyPair), c.Direction, c.NearDate, c.FarDate
ORDER BY MaxNearId DESC;
```

DB: `NetTrexFX` · Server: `tcp:192.168.10.211,1433` · User: `trusr` · Pass: `***`


## #91

**Amaç:** Test FX Swap: Yalnız valör başlangıç — valör 2026-10-01–…. API (ekran) gruplanmış satırları ile karşılaştırma (aynı join/gruplama/oran formülü).

```sql
SET NOCOUNT ON;
DECLARE @LD date = '2026-10-02';
WITH N AS (SELECT * FROM TxnFXSwap WHERE InstrumentId = 1068 AND (StateId & 6) = 2 AND ValueDate >= '2026-10-01'),
F AS (SELECT * FROM TxnFXSwap WHERE InstrumentId = 1069 AND (StateId & 6) = 2),
P AS (
    SELECT n.PkgNo, n.Id AS NearId, f.Id AS FarId, n.CustomerId, LTRIM(RTRIM(n.CcyPair)) AS CcyPair, n.LogicalReference AS NearRef,
           n.BuyCcy, n.BuyAmount, n.SellCcy, n.SellAmount, 
           CAST(n.DealRateNet AS float) AS NearRate, CAST(f.DealRateNet AS float) AS FarRate,
           CAST(n.ValueDate AS date) AS NearDate, CAST(f.ValueDate AS date) AS FarDate,
           COUNT(*) OVER () AS JoinCnt,
           ROW_NUMBER() OVER (PARTITION BY n.PkgNo ORDER BY n.Id DESC, f.Id DESC) AS Rn
    FROM N n JOIN F f ON f.PkgNo = n.PkgNo
    WHERE n.PkgNo <> 0
),
M AS (
    SELECT p.*, CASE WHEN UPPER(p.BuyCcy) = UPPER(CASE WHEN CHARINDEX('/', p.CcyPair) > 1 THEN LTRIM(RTRIM(LEFT(p.CcyPair, CHARINDEX('/', p.CcyPair) - 1)))
                                     WHEN LEN(p.CcyPair) >= 6 THEN LEFT(p.CcyPair, 3) ELSE p.BuyCcy END) THEN 1 ELSE 0 END AS BaseBought
    FROM P p WHERE p.Rn = 1
),
C AS (
    SELECT m.*, CASE WHEN BaseBought = 1 THEN 'B/S' ELSE 'S/B' END AS Direction,
           CAST(CASE WHEN BaseBought = 1 THEN SellAmount ELSE BuyAmount END AS float) AS NB,
           CASE WHEN BaseBought = 1 THEN SellCcy ELSE BuyCcy END AS NBCcy,
           CAST(0 AS float) AS Ounce, CAST(0 AS float) AS Gram,
           CASE WHEN NearRate = 0 THEN 0 ELSE (FarRate - NearRate) / NearRate * (360.0 / CASE WHEN DATEDIFF(day, NearDate, FarDate) = 0 THEN 1 ELSE DATEDIFF(day, NearDate, FarDate) END) * 100 END AS SR
    FROM M m
)
SELECT TOP (20) MAX(c.NearId) AS MaxNearId, cu.Name AS CounterpartyName, UPPER(c.CcyPair) AS CcyPair, c.Direction, c.NearDate, c.FarDate,
       DATEDIFF(day, c.NearDate, c.FarDate) AS Tenor,
       CASE WHEN c.FarDate < @LD THEN 0 ELSE DATEDIFF(day, @LD, c.FarDate) END AS DaysToMaturity,
       ROUND(SUM(c.NB), 2) AS TotalAmount, MAX(c.NBCcy) AS TotalAmountCcy,
       CASE WHEN SUM(c.NB) <> 0 THEN SUM(c.NB * c.SR) / SUM(c.NB) ELSE AVG(c.SR) END AS SwapRate,
       MAX(c.SellCcy) AS SoldCcy, ROUND(SUM(c.SellAmount), 2) AS SoldAmount, MAX(c.BuyCcy) AS BoughtCcy, ROUND(SUM(c.BuyAmount), 2) AS BoughtAmount,
       ROUND(SUM(c.Ounce), 2) AS Ounce, ROUND(SUM(c.Gram), 2) AS Gram,
       COUNT(*) AS TxnCount, STRING_AGG(c.NearRef, ', ') AS Refs,
       MAX(c.JoinCnt) AS JoinCnt, (SELECT COUNT(*) FROM M) AS PkgCnt
FROM C c
LEFT JOIN CusCustomer cu ON cu.Id = c.CustomerId
GROUP BY c.CustomerId, cu.Name, UPPER(c.CcyPair), c.Direction, c.NearDate, c.FarDate
ORDER BY MaxNearId DESC;
```

DB: `NetTrexFX` · Server: `tcp:192.168.10.211,1433` · User: `trusr` · Pass: `***`


## #92

**Amaç:** Test FX Swap: Yalnız valör bitiş (öncesi) — valör …–2026-09-30. API (ekran) gruplanmış satırları ile karşılaştırma (aynı join/gruplama/oran formülü).

```sql
SET NOCOUNT ON;
DECLARE @LD date = '2026-10-02';
WITH N AS (SELECT * FROM TxnFXSwap WHERE InstrumentId = 1068 AND (StateId & 6) = 2 AND ValueDate < DATEADD(day, 1, CAST('2026-09-30' AS date))),
F AS (SELECT * FROM TxnFXSwap WHERE InstrumentId = 1069 AND (StateId & 6) = 2),
P AS (
    SELECT n.PkgNo, n.Id AS NearId, f.Id AS FarId, n.CustomerId, LTRIM(RTRIM(n.CcyPair)) AS CcyPair, n.LogicalReference AS NearRef,
           n.BuyCcy, n.BuyAmount, n.SellCcy, n.SellAmount, 
           CAST(n.DealRateNet AS float) AS NearRate, CAST(f.DealRateNet AS float) AS FarRate,
           CAST(n.ValueDate AS date) AS NearDate, CAST(f.ValueDate AS date) AS FarDate,
           COUNT(*) OVER () AS JoinCnt,
           ROW_NUMBER() OVER (PARTITION BY n.PkgNo ORDER BY n.Id DESC, f.Id DESC) AS Rn
    FROM N n JOIN F f ON f.PkgNo = n.PkgNo
    WHERE n.PkgNo <> 0
),
M AS (
    SELECT p.*, CASE WHEN UPPER(p.BuyCcy) = UPPER(CASE WHEN CHARINDEX('/', p.CcyPair) > 1 THEN LTRIM(RTRIM(LEFT(p.CcyPair, CHARINDEX('/', p.CcyPair) - 1)))
                                     WHEN LEN(p.CcyPair) >= 6 THEN LEFT(p.CcyPair, 3) ELSE p.BuyCcy END) THEN 1 ELSE 0 END AS BaseBought
    FROM P p WHERE p.Rn = 1
),
C AS (
    SELECT m.*, CASE WHEN BaseBought = 1 THEN 'B/S' ELSE 'S/B' END AS Direction,
           CAST(CASE WHEN BaseBought = 1 THEN SellAmount ELSE BuyAmount END AS float) AS NB,
           CASE WHEN BaseBought = 1 THEN SellCcy ELSE BuyCcy END AS NBCcy,
           CAST(0 AS float) AS Ounce, CAST(0 AS float) AS Gram,
           CASE WHEN NearRate = 0 THEN 0 ELSE (FarRate - NearRate) / NearRate * (360.0 / CASE WHEN DATEDIFF(day, NearDate, FarDate) = 0 THEN 1 ELSE DATEDIFF(day, NearDate, FarDate) END) * 100 END AS SR
    FROM M m
)
SELECT TOP (20) MAX(c.NearId) AS MaxNearId, cu.Name AS CounterpartyName, UPPER(c.CcyPair) AS CcyPair, c.Direction, c.NearDate, c.FarDate,
       DATEDIFF(day, c.NearDate, c.FarDate) AS Tenor,
       CASE WHEN c.FarDate < @LD THEN 0 ELSE DATEDIFF(day, @LD, c.FarDate) END AS DaysToMaturity,
       ROUND(SUM(c.NB), 2) AS TotalAmount, MAX(c.NBCcy) AS TotalAmountCcy,
       CASE WHEN SUM(c.NB) <> 0 THEN SUM(c.NB * c.SR) / SUM(c.NB) ELSE AVG(c.SR) END AS SwapRate,
       MAX(c.SellCcy) AS SoldCcy, ROUND(SUM(c.SellAmount), 2) AS SoldAmount, MAX(c.BuyCcy) AS BoughtCcy, ROUND(SUM(c.BuyAmount), 2) AS BoughtAmount,
       ROUND(SUM(c.Ounce), 2) AS Ounce, ROUND(SUM(c.Gram), 2) AS Gram,
       COUNT(*) AS TxnCount, STRING_AGG(c.NearRef, ', ') AS Refs,
       MAX(c.JoinCnt) AS JoinCnt, (SELECT COUNT(*) FROM M) AS PkgCnt
FROM C c
LEFT JOIN CusCustomer cu ON cu.Id = c.CustomerId
GROUP BY c.CustomerId, cu.Name, UPPER(c.CcyPair), c.Direction, c.NearDate, c.FarDate
ORDER BY MaxNearId DESC;
```

DB: `NetTrexFX` · Server: `tcp:192.168.10.211,1433` · User: `trusr` · Pass: `***`


## #93

**Amaç:** Test FX Swap: Tek gün valör 01.10 — valör 2026-10-01–2026-10-01. API (ekran) gruplanmış satırları ile karşılaştırma (aynı join/gruplama/oran formülü).

```sql
SET NOCOUNT ON;
DECLARE @LD date = '2026-10-02';
WITH N AS (SELECT * FROM TxnFXSwap WHERE InstrumentId = 1068 AND (StateId & 6) = 2 AND ValueDate >= '2026-10-01' AND ValueDate < DATEADD(day, 1, CAST('2026-10-01' AS date))),
F AS (SELECT * FROM TxnFXSwap WHERE InstrumentId = 1069 AND (StateId & 6) = 2),
P AS (
    SELECT n.PkgNo, n.Id AS NearId, f.Id AS FarId, n.CustomerId, LTRIM(RTRIM(n.CcyPair)) AS CcyPair, n.LogicalReference AS NearRef,
           n.BuyCcy, n.BuyAmount, n.SellCcy, n.SellAmount, 
           CAST(n.DealRateNet AS float) AS NearRate, CAST(f.DealRateNet AS float) AS FarRate,
           CAST(n.ValueDate AS date) AS NearDate, CAST(f.ValueDate AS date) AS FarDate,
           COUNT(*) OVER () AS JoinCnt,
           ROW_NUMBER() OVER (PARTITION BY n.PkgNo ORDER BY n.Id DESC, f.Id DESC) AS Rn
    FROM N n JOIN F f ON f.PkgNo = n.PkgNo
    WHERE n.PkgNo <> 0
),
M AS (
    SELECT p.*, CASE WHEN UPPER(p.BuyCcy) = UPPER(CASE WHEN CHARINDEX('/', p.CcyPair) > 1 THEN LTRIM(RTRIM(LEFT(p.CcyPair, CHARINDEX('/', p.CcyPair) - 1)))
                                     WHEN LEN(p.CcyPair) >= 6 THEN LEFT(p.CcyPair, 3) ELSE p.BuyCcy END) THEN 1 ELSE 0 END AS BaseBought
    FROM P p WHERE p.Rn = 1
),
C AS (
    SELECT m.*, CASE WHEN BaseBought = 1 THEN 'B/S' ELSE 'S/B' END AS Direction,
           CAST(CASE WHEN BaseBought = 1 THEN SellAmount ELSE BuyAmount END AS float) AS NB,
           CASE WHEN BaseBought = 1 THEN SellCcy ELSE BuyCcy END AS NBCcy,
           CAST(0 AS float) AS Ounce, CAST(0 AS float) AS Gram,
           CASE WHEN NearRate = 0 THEN 0 ELSE (FarRate - NearRate) / NearRate * (360.0 / CASE WHEN DATEDIFF(day, NearDate, FarDate) = 0 THEN 1 ELSE DATEDIFF(day, NearDate, FarDate) END) * 100 END AS SR
    FROM M m
)
SELECT TOP (20) MAX(c.NearId) AS MaxNearId, cu.Name AS CounterpartyName, UPPER(c.CcyPair) AS CcyPair, c.Direction, c.NearDate, c.FarDate,
       DATEDIFF(day, c.NearDate, c.FarDate) AS Tenor,
       CASE WHEN c.FarDate < @LD THEN 0 ELSE DATEDIFF(day, @LD, c.FarDate) END AS DaysToMaturity,
       ROUND(SUM(c.NB), 2) AS TotalAmount, MAX(c.NBCcy) AS TotalAmountCcy,
       CASE WHEN SUM(c.NB) <> 0 THEN SUM(c.NB * c.SR) / SUM(c.NB) ELSE AVG(c.SR) END AS SwapRate,
       MAX(c.SellCcy) AS SoldCcy, ROUND(SUM(c.SellAmount), 2) AS SoldAmount, MAX(c.BuyCcy) AS BoughtCcy, ROUND(SUM(c.BuyAmount), 2) AS BoughtAmount,
       ROUND(SUM(c.Ounce), 2) AS Ounce, ROUND(SUM(c.Gram), 2) AS Gram,
       COUNT(*) AS TxnCount, STRING_AGG(c.NearRef, ', ') AS Refs,
       MAX(c.JoinCnt) AS JoinCnt, (SELECT COUNT(*) FROM M) AS PkgCnt
FROM C c
LEFT JOIN CusCustomer cu ON cu.Id = c.CustomerId
GROUP BY c.CustomerId, cu.Name, UPPER(c.CcyPair), c.Direction, c.NearDate, c.FarDate
ORDER BY MaxNearId DESC;
```

DB: `NetTrexFX` · Server: `tcp:192.168.10.211,1433` · User: `trusr` · Pass: `***`


## #94

**Amaç:** Test FX Swap: Valör 02.10 sonrası — valör 2026-10-02–…. API (ekran) gruplanmış satırları ile karşılaştırma (aynı join/gruplama/oran formülü).

```sql
SET NOCOUNT ON;
DECLARE @LD date = '2026-10-02';
WITH N AS (SELECT * FROM TxnFXSwap WHERE InstrumentId = 1068 AND (StateId & 6) = 2 AND ValueDate >= '2026-10-02'),
F AS (SELECT * FROM TxnFXSwap WHERE InstrumentId = 1069 AND (StateId & 6) = 2),
P AS (
    SELECT n.PkgNo, n.Id AS NearId, f.Id AS FarId, n.CustomerId, LTRIM(RTRIM(n.CcyPair)) AS CcyPair, n.LogicalReference AS NearRef,
           n.BuyCcy, n.BuyAmount, n.SellCcy, n.SellAmount, 
           CAST(n.DealRateNet AS float) AS NearRate, CAST(f.DealRateNet AS float) AS FarRate,
           CAST(n.ValueDate AS date) AS NearDate, CAST(f.ValueDate AS date) AS FarDate,
           COUNT(*) OVER () AS JoinCnt,
           ROW_NUMBER() OVER (PARTITION BY n.PkgNo ORDER BY n.Id DESC, f.Id DESC) AS Rn
    FROM N n JOIN F f ON f.PkgNo = n.PkgNo
    WHERE n.PkgNo <> 0
),
M AS (
    SELECT p.*, CASE WHEN UPPER(p.BuyCcy) = UPPER(CASE WHEN CHARINDEX('/', p.CcyPair) > 1 THEN LTRIM(RTRIM(LEFT(p.CcyPair, CHARINDEX('/', p.CcyPair) - 1)))
                                     WHEN LEN(p.CcyPair) >= 6 THEN LEFT(p.CcyPair, 3) ELSE p.BuyCcy END) THEN 1 ELSE 0 END AS BaseBought
    FROM P p WHERE p.Rn = 1
),
C AS (
    SELECT m.*, CASE WHEN BaseBought = 1 THEN 'B/S' ELSE 'S/B' END AS Direction,
           CAST(CASE WHEN BaseBought = 1 THEN SellAmount ELSE BuyAmount END AS float) AS NB,
           CASE WHEN BaseBought = 1 THEN SellCcy ELSE BuyCcy END AS NBCcy,
           CAST(0 AS float) AS Ounce, CAST(0 AS float) AS Gram,
           CASE WHEN NearRate = 0 THEN 0 ELSE (FarRate - NearRate) / NearRate * (360.0 / CASE WHEN DATEDIFF(day, NearDate, FarDate) = 0 THEN 1 ELSE DATEDIFF(day, NearDate, FarDate) END) * 100 END AS SR
    FROM M m
)
SELECT TOP (20) MAX(c.NearId) AS MaxNearId, cu.Name AS CounterpartyName, UPPER(c.CcyPair) AS CcyPair, c.Direction, c.NearDate, c.FarDate,
       DATEDIFF(day, c.NearDate, c.FarDate) AS Tenor,
       CASE WHEN c.FarDate < @LD THEN 0 ELSE DATEDIFF(day, @LD, c.FarDate) END AS DaysToMaturity,
       ROUND(SUM(c.NB), 2) AS TotalAmount, MAX(c.NBCcy) AS TotalAmountCcy,
       CASE WHEN SUM(c.NB) <> 0 THEN SUM(c.NB * c.SR) / SUM(c.NB) ELSE AVG(c.SR) END AS SwapRate,
       MAX(c.SellCcy) AS SoldCcy, ROUND(SUM(c.SellAmount), 2) AS SoldAmount, MAX(c.BuyCcy) AS BoughtCcy, ROUND(SUM(c.BuyAmount), 2) AS BoughtAmount,
       ROUND(SUM(c.Ounce), 2) AS Ounce, ROUND(SUM(c.Gram), 2) AS Gram,
       COUNT(*) AS TxnCount, STRING_AGG(c.NearRef, ', ') AS Refs,
       MAX(c.JoinCnt) AS JoinCnt, (SELECT COUNT(*) FROM M) AS PkgCnt
FROM C c
LEFT JOIN CusCustomer cu ON cu.Id = c.CustomerId
GROUP BY c.CustomerId, cu.Name, UPPER(c.CcyPair), c.Direction, c.NearDate, c.FarDate
ORDER BY MaxNearId DESC;
```

DB: `NetTrexFX` · Server: `tcp:192.168.10.211,1433` · User: `trusr` · Pass: `***`


## #95

**Amaç:** Test FX Swap: Vade aralığı Ekim — vade 2026-10-01–2026-10-31. API (ekran) gruplanmış satırları ile karşılaştırma (aynı join/gruplama/oran formülü).

```sql
SET NOCOUNT ON;
DECLARE @LD date = '2026-10-02';
WITH N AS (SELECT * FROM TxnFXSwap WHERE InstrumentId = 1068 AND (StateId & 6) = 2),
F AS (SELECT * FROM TxnFXSwap WHERE InstrumentId = 1069 AND (StateId & 6) = 2 AND ValueDate >= '2026-10-01' AND ValueDate < DATEADD(day, 1, CAST('2026-10-31' AS date))),
P AS (
    SELECT n.PkgNo, n.Id AS NearId, f.Id AS FarId, n.CustomerId, LTRIM(RTRIM(n.CcyPair)) AS CcyPair, n.LogicalReference AS NearRef,
           n.BuyCcy, n.BuyAmount, n.SellCcy, n.SellAmount, 
           CAST(n.DealRateNet AS float) AS NearRate, CAST(f.DealRateNet AS float) AS FarRate,
           CAST(n.ValueDate AS date) AS NearDate, CAST(f.ValueDate AS date) AS FarDate,
           COUNT(*) OVER () AS JoinCnt,
           ROW_NUMBER() OVER (PARTITION BY n.PkgNo ORDER BY n.Id DESC, f.Id DESC) AS Rn
    FROM N n JOIN F f ON f.PkgNo = n.PkgNo
    WHERE n.PkgNo <> 0
),
M AS (
    SELECT p.*, CASE WHEN UPPER(p.BuyCcy) = UPPER(CASE WHEN CHARINDEX('/', p.CcyPair) > 1 THEN LTRIM(RTRIM(LEFT(p.CcyPair, CHARINDEX('/', p.CcyPair) - 1)))
                                     WHEN LEN(p.CcyPair) >= 6 THEN LEFT(p.CcyPair, 3) ELSE p.BuyCcy END) THEN 1 ELSE 0 END AS BaseBought
    FROM P p WHERE p.Rn = 1
),
C AS (
    SELECT m.*, CASE WHEN BaseBought = 1 THEN 'B/S' ELSE 'S/B' END AS Direction,
           CAST(CASE WHEN BaseBought = 1 THEN SellAmount ELSE BuyAmount END AS float) AS NB,
           CASE WHEN BaseBought = 1 THEN SellCcy ELSE BuyCcy END AS NBCcy,
           CAST(0 AS float) AS Ounce, CAST(0 AS float) AS Gram,
           CASE WHEN NearRate = 0 THEN 0 ELSE (FarRate - NearRate) / NearRate * (360.0 / CASE WHEN DATEDIFF(day, NearDate, FarDate) = 0 THEN 1 ELSE DATEDIFF(day, NearDate, FarDate) END) * 100 END AS SR
    FROM M m
)
SELECT TOP (20) MAX(c.NearId) AS MaxNearId, cu.Name AS CounterpartyName, UPPER(c.CcyPair) AS CcyPair, c.Direction, c.NearDate, c.FarDate,
       DATEDIFF(day, c.NearDate, c.FarDate) AS Tenor,
       CASE WHEN c.FarDate < @LD THEN 0 ELSE DATEDIFF(day, @LD, c.FarDate) END AS DaysToMaturity,
       ROUND(SUM(c.NB), 2) AS TotalAmount, MAX(c.NBCcy) AS TotalAmountCcy,
       CASE WHEN SUM(c.NB) <> 0 THEN SUM(c.NB * c.SR) / SUM(c.NB) ELSE AVG(c.SR) END AS SwapRate,
       MAX(c.SellCcy) AS SoldCcy, ROUND(SUM(c.SellAmount), 2) AS SoldAmount, MAX(c.BuyCcy) AS BoughtCcy, ROUND(SUM(c.BuyAmount), 2) AS BoughtAmount,
       ROUND(SUM(c.Ounce), 2) AS Ounce, ROUND(SUM(c.Gram), 2) AS Gram,
       COUNT(*) AS TxnCount, STRING_AGG(c.NearRef, ', ') AS Refs,
       MAX(c.JoinCnt) AS JoinCnt, (SELECT COUNT(*) FROM M) AS PkgCnt
FROM C c
LEFT JOIN CusCustomer cu ON cu.Id = c.CustomerId
GROUP BY c.CustomerId, cu.Name, UPPER(c.CcyPair), c.Direction, c.NearDate, c.FarDate
ORDER BY MaxNearId DESC;
```

DB: `NetTrexFX` · Server: `tcp:192.168.10.211,1433` · User: `trusr` · Pass: `***`


## #96

**Amaç:** Test FX Swap: Yalnız vade başlangıç 03.10 — vade 2026-10-03–…. API (ekran) gruplanmış satırları ile karşılaştırma (aynı join/gruplama/oran formülü).

```sql
SET NOCOUNT ON;
DECLARE @LD date = '2026-10-02';
WITH N AS (SELECT * FROM TxnFXSwap WHERE InstrumentId = 1068 AND (StateId & 6) = 2),
F AS (SELECT * FROM TxnFXSwap WHERE InstrumentId = 1069 AND (StateId & 6) = 2 AND ValueDate >= '2026-10-03'),
P AS (
    SELECT n.PkgNo, n.Id AS NearId, f.Id AS FarId, n.CustomerId, LTRIM(RTRIM(n.CcyPair)) AS CcyPair, n.LogicalReference AS NearRef,
           n.BuyCcy, n.BuyAmount, n.SellCcy, n.SellAmount, 
           CAST(n.DealRateNet AS float) AS NearRate, CAST(f.DealRateNet AS float) AS FarRate,
           CAST(n.ValueDate AS date) AS NearDate, CAST(f.ValueDate AS date) AS FarDate,
           COUNT(*) OVER () AS JoinCnt,
           ROW_NUMBER() OVER (PARTITION BY n.PkgNo ORDER BY n.Id DESC, f.Id DESC) AS Rn
    FROM N n JOIN F f ON f.PkgNo = n.PkgNo
    WHERE n.PkgNo <> 0
),
M AS (
    SELECT p.*, CASE WHEN UPPER(p.BuyCcy) = UPPER(CASE WHEN CHARINDEX('/', p.CcyPair) > 1 THEN LTRIM(RTRIM(LEFT(p.CcyPair, CHARINDEX('/', p.CcyPair) - 1)))
                                     WHEN LEN(p.CcyPair) >= 6 THEN LEFT(p.CcyPair, 3) ELSE p.BuyCcy END) THEN 1 ELSE 0 END AS BaseBought
    FROM P p WHERE p.Rn = 1
),
C AS (
    SELECT m.*, CASE WHEN BaseBought = 1 THEN 'B/S' ELSE 'S/B' END AS Direction,
           CAST(CASE WHEN BaseBought = 1 THEN SellAmount ELSE BuyAmount END AS float) AS NB,
           CASE WHEN BaseBought = 1 THEN SellCcy ELSE BuyCcy END AS NBCcy,
           CAST(0 AS float) AS Ounce, CAST(0 AS float) AS Gram,
           CASE WHEN NearRate = 0 THEN 0 ELSE (FarRate - NearRate) / NearRate * (360.0 / CASE WHEN DATEDIFF(day, NearDate, FarDate) = 0 THEN 1 ELSE DATEDIFF(day, NearDate, FarDate) END) * 100 END AS SR
    FROM M m
)
SELECT TOP (20) MAX(c.NearId) AS MaxNearId, cu.Name AS CounterpartyName, UPPER(c.CcyPair) AS CcyPair, c.Direction, c.NearDate, c.FarDate,
       DATEDIFF(day, c.NearDate, c.FarDate) AS Tenor,
       CASE WHEN c.FarDate < @LD THEN 0 ELSE DATEDIFF(day, @LD, c.FarDate) END AS DaysToMaturity,
       ROUND(SUM(c.NB), 2) AS TotalAmount, MAX(c.NBCcy) AS TotalAmountCcy,
       CASE WHEN SUM(c.NB) <> 0 THEN SUM(c.NB * c.SR) / SUM(c.NB) ELSE AVG(c.SR) END AS SwapRate,
       MAX(c.SellCcy) AS SoldCcy, ROUND(SUM(c.SellAmount), 2) AS SoldAmount, MAX(c.BuyCcy) AS BoughtCcy, ROUND(SUM(c.BuyAmount), 2) AS BoughtAmount,
       ROUND(SUM(c.Ounce), 2) AS Ounce, ROUND(SUM(c.Gram), 2) AS Gram,
       COUNT(*) AS TxnCount, STRING_AGG(c.NearRef, ', ') AS Refs,
       MAX(c.JoinCnt) AS JoinCnt, (SELECT COUNT(*) FROM M) AS PkgCnt
FROM C c
LEFT JOIN CusCustomer cu ON cu.Id = c.CustomerId
GROUP BY c.CustomerId, cu.Name, UPPER(c.CcyPair), c.Direction, c.NearDate, c.FarDate
ORDER BY MaxNearId DESC;
```

DB: `NetTrexFX` · Server: `tcp:192.168.10.211,1433` · User: `trusr` · Pass: `***`


## #97

**Amaç:** Test FX Swap: Yalnız vade bitiş 02.10 — vade …–2026-10-02. API (ekran) gruplanmış satırları ile karşılaştırma (aynı join/gruplama/oran formülü).

```sql
SET NOCOUNT ON;
DECLARE @LD date = '2026-10-02';
WITH N AS (SELECT * FROM TxnFXSwap WHERE InstrumentId = 1068 AND (StateId & 6) = 2),
F AS (SELECT * FROM TxnFXSwap WHERE InstrumentId = 1069 AND (StateId & 6) = 2 AND ValueDate < DATEADD(day, 1, CAST('2026-10-02' AS date))),
P AS (
    SELECT n.PkgNo, n.Id AS NearId, f.Id AS FarId, n.CustomerId, LTRIM(RTRIM(n.CcyPair)) AS CcyPair, n.LogicalReference AS NearRef,
           n.BuyCcy, n.BuyAmount, n.SellCcy, n.SellAmount, 
           CAST(n.DealRateNet AS float) AS NearRate, CAST(f.DealRateNet AS float) AS FarRate,
           CAST(n.ValueDate AS date) AS NearDate, CAST(f.ValueDate AS date) AS FarDate,
           COUNT(*) OVER () AS JoinCnt,
           ROW_NUMBER() OVER (PARTITION BY n.PkgNo ORDER BY n.Id DESC, f.Id DESC) AS Rn
    FROM N n JOIN F f ON f.PkgNo = n.PkgNo
    WHERE n.PkgNo <> 0
),
M AS (
    SELECT p.*, CASE WHEN UPPER(p.BuyCcy) = UPPER(CASE WHEN CHARINDEX('/', p.CcyPair) > 1 THEN LTRIM(RTRIM(LEFT(p.CcyPair, CHARINDEX('/', p.CcyPair) - 1)))
                                     WHEN LEN(p.CcyPair) >= 6 THEN LEFT(p.CcyPair, 3) ELSE p.BuyCcy END) THEN 1 ELSE 0 END AS BaseBought
    FROM P p WHERE p.Rn = 1
),
C AS (
    SELECT m.*, CASE WHEN BaseBought = 1 THEN 'B/S' ELSE 'S/B' END AS Direction,
           CAST(CASE WHEN BaseBought = 1 THEN SellAmount ELSE BuyAmount END AS float) AS NB,
           CASE WHEN BaseBought = 1 THEN SellCcy ELSE BuyCcy END AS NBCcy,
           CAST(0 AS float) AS Ounce, CAST(0 AS float) AS Gram,
           CASE WHEN NearRate = 0 THEN 0 ELSE (FarRate - NearRate) / NearRate * (360.0 / CASE WHEN DATEDIFF(day, NearDate, FarDate) = 0 THEN 1 ELSE DATEDIFF(day, NearDate, FarDate) END) * 100 END AS SR
    FROM M m
)
SELECT TOP (20) MAX(c.NearId) AS MaxNearId, cu.Name AS CounterpartyName, UPPER(c.CcyPair) AS CcyPair, c.Direction, c.NearDate, c.FarDate,
       DATEDIFF(day, c.NearDate, c.FarDate) AS Tenor,
       CASE WHEN c.FarDate < @LD THEN 0 ELSE DATEDIFF(day, @LD, c.FarDate) END AS DaysToMaturity,
       ROUND(SUM(c.NB), 2) AS TotalAmount, MAX(c.NBCcy) AS TotalAmountCcy,
       CASE WHEN SUM(c.NB) <> 0 THEN SUM(c.NB * c.SR) / SUM(c.NB) ELSE AVG(c.SR) END AS SwapRate,
       MAX(c.SellCcy) AS SoldCcy, ROUND(SUM(c.SellAmount), 2) AS SoldAmount, MAX(c.BuyCcy) AS BoughtCcy, ROUND(SUM(c.BuyAmount), 2) AS BoughtAmount,
       ROUND(SUM(c.Ounce), 2) AS Ounce, ROUND(SUM(c.Gram), 2) AS Gram,
       COUNT(*) AS TxnCount, STRING_AGG(c.NearRef, ', ') AS Refs,
       MAX(c.JoinCnt) AS JoinCnt, (SELECT COUNT(*) FROM M) AS PkgCnt
FROM C c
LEFT JOIN CusCustomer cu ON cu.Id = c.CustomerId
GROUP BY c.CustomerId, cu.Name, UPPER(c.CcyPair), c.Direction, c.NearDate, c.FarDate
ORDER BY MaxNearId DESC;
```

DB: `NetTrexFX` · Server: `tcp:192.168.10.211,1433` · User: `trusr` · Pass: `***`


## #98

**Amaç:** Test FX Swap: Tek gün vade 07.10 — vade 2026-10-07–2026-10-07. API (ekran) gruplanmış satırları ile karşılaştırma (aynı join/gruplama/oran formülü).

```sql
SET NOCOUNT ON;
DECLARE @LD date = '2026-10-02';
WITH N AS (SELECT * FROM TxnFXSwap WHERE InstrumentId = 1068 AND (StateId & 6) = 2),
F AS (SELECT * FROM TxnFXSwap WHERE InstrumentId = 1069 AND (StateId & 6) = 2 AND ValueDate >= '2026-10-07' AND ValueDate < DATEADD(day, 1, CAST('2026-10-07' AS date))),
P AS (
    SELECT n.PkgNo, n.Id AS NearId, f.Id AS FarId, n.CustomerId, LTRIM(RTRIM(n.CcyPair)) AS CcyPair, n.LogicalReference AS NearRef,
           n.BuyCcy, n.BuyAmount, n.SellCcy, n.SellAmount, 
           CAST(n.DealRateNet AS float) AS NearRate, CAST(f.DealRateNet AS float) AS FarRate,
           CAST(n.ValueDate AS date) AS NearDate, CAST(f.ValueDate AS date) AS FarDate,
           COUNT(*) OVER () AS JoinCnt,
           ROW_NUMBER() OVER (PARTITION BY n.PkgNo ORDER BY n.Id DESC, f.Id DESC) AS Rn
    FROM N n JOIN F f ON f.PkgNo = n.PkgNo
    WHERE n.PkgNo <> 0
),
M AS (
    SELECT p.*, CASE WHEN UPPER(p.BuyCcy) = UPPER(CASE WHEN CHARINDEX('/', p.CcyPair) > 1 THEN LTRIM(RTRIM(LEFT(p.CcyPair, CHARINDEX('/', p.CcyPair) - 1)))
                                     WHEN LEN(p.CcyPair) >= 6 THEN LEFT(p.CcyPair, 3) ELSE p.BuyCcy END) THEN 1 ELSE 0 END AS BaseBought
    FROM P p WHERE p.Rn = 1
),
C AS (
    SELECT m.*, CASE WHEN BaseBought = 1 THEN 'B/S' ELSE 'S/B' END AS Direction,
           CAST(CASE WHEN BaseBought = 1 THEN SellAmount ELSE BuyAmount END AS float) AS NB,
           CASE WHEN BaseBought = 1 THEN SellCcy ELSE BuyCcy END AS NBCcy,
           CAST(0 AS float) AS Ounce, CAST(0 AS float) AS Gram,
           CASE WHEN NearRate = 0 THEN 0 ELSE (FarRate - NearRate) / NearRate * (360.0 / CASE WHEN DATEDIFF(day, NearDate, FarDate) = 0 THEN 1 ELSE DATEDIFF(day, NearDate, FarDate) END) * 100 END AS SR
    FROM M m
)
SELECT TOP (20) MAX(c.NearId) AS MaxNearId, cu.Name AS CounterpartyName, UPPER(c.CcyPair) AS CcyPair, c.Direction, c.NearDate, c.FarDate,
       DATEDIFF(day, c.NearDate, c.FarDate) AS Tenor,
       CASE WHEN c.FarDate < @LD THEN 0 ELSE DATEDIFF(day, @LD, c.FarDate) END AS DaysToMaturity,
       ROUND(SUM(c.NB), 2) AS TotalAmount, MAX(c.NBCcy) AS TotalAmountCcy,
       CASE WHEN SUM(c.NB) <> 0 THEN SUM(c.NB * c.SR) / SUM(c.NB) ELSE AVG(c.SR) END AS SwapRate,
       MAX(c.SellCcy) AS SoldCcy, ROUND(SUM(c.SellAmount), 2) AS SoldAmount, MAX(c.BuyCcy) AS BoughtCcy, ROUND(SUM(c.BuyAmount), 2) AS BoughtAmount,
       ROUND(SUM(c.Ounce), 2) AS Ounce, ROUND(SUM(c.Gram), 2) AS Gram,
       COUNT(*) AS TxnCount, STRING_AGG(c.NearRef, ', ') AS Refs,
       MAX(c.JoinCnt) AS JoinCnt, (SELECT COUNT(*) FROM M) AS PkgCnt
FROM C c
LEFT JOIN CusCustomer cu ON cu.Id = c.CustomerId
GROUP BY c.CustomerId, cu.Name, UPPER(c.CcyPair), c.Direction, c.NearDate, c.FarDate
ORDER BY MaxNearId DESC;
```

DB: `NetTrexFX` · Server: `tcp:192.168.10.211,1433` · User: `trusr` · Pass: `***`


## #99

**Amaç:** Test FX Swap: Tek gün vade 13.10 (silinmiş paket) — vade 2026-10-13–2026-10-13. API (ekran) gruplanmış satırları ile karşılaştırma (aynı join/gruplama/oran formülü).

```sql
SET NOCOUNT ON;
DECLARE @LD date = '2026-10-02';
WITH N AS (SELECT * FROM TxnFXSwap WHERE InstrumentId = 1068 AND (StateId & 6) = 2),
F AS (SELECT * FROM TxnFXSwap WHERE InstrumentId = 1069 AND (StateId & 6) = 2 AND ValueDate >= '2026-10-13' AND ValueDate < DATEADD(day, 1, CAST('2026-10-13' AS date))),
P AS (
    SELECT n.PkgNo, n.Id AS NearId, f.Id AS FarId, n.CustomerId, LTRIM(RTRIM(n.CcyPair)) AS CcyPair, n.LogicalReference AS NearRef,
           n.BuyCcy, n.BuyAmount, n.SellCcy, n.SellAmount, 
           CAST(n.DealRateNet AS float) AS NearRate, CAST(f.DealRateNet AS float) AS FarRate,
           CAST(n.ValueDate AS date) AS NearDate, CAST(f.ValueDate AS date) AS FarDate,
           COUNT(*) OVER () AS JoinCnt,
           ROW_NUMBER() OVER (PARTITION BY n.PkgNo ORDER BY n.Id DESC, f.Id DESC) AS Rn
    FROM N n JOIN F f ON f.PkgNo = n.PkgNo
    WHERE n.PkgNo <> 0
),
M AS (
    SELECT p.*, CASE WHEN UPPER(p.BuyCcy) = UPPER(CASE WHEN CHARINDEX('/', p.CcyPair) > 1 THEN LTRIM(RTRIM(LEFT(p.CcyPair, CHARINDEX('/', p.CcyPair) - 1)))
                                     WHEN LEN(p.CcyPair) >= 6 THEN LEFT(p.CcyPair, 3) ELSE p.BuyCcy END) THEN 1 ELSE 0 END AS BaseBought
    FROM P p WHERE p.Rn = 1
),
C AS (
    SELECT m.*, CASE WHEN BaseBought = 1 THEN 'B/S' ELSE 'S/B' END AS Direction,
           CAST(CASE WHEN BaseBought = 1 THEN SellAmount ELSE BuyAmount END AS float) AS NB,
           CASE WHEN BaseBought = 1 THEN SellCcy ELSE BuyCcy END AS NBCcy,
           CAST(0 AS float) AS Ounce, CAST(0 AS float) AS Gram,
           CASE WHEN NearRate = 0 THEN 0 ELSE (FarRate - NearRate) / NearRate * (360.0 / CASE WHEN DATEDIFF(day, NearDate, FarDate) = 0 THEN 1 ELSE DATEDIFF(day, NearDate, FarDate) END) * 100 END AS SR
    FROM M m
)
SELECT TOP (20) MAX(c.NearId) AS MaxNearId, cu.Name AS CounterpartyName, UPPER(c.CcyPair) AS CcyPair, c.Direction, c.NearDate, c.FarDate,
       DATEDIFF(day, c.NearDate, c.FarDate) AS Tenor,
       CASE WHEN c.FarDate < @LD THEN 0 ELSE DATEDIFF(day, @LD, c.FarDate) END AS DaysToMaturity,
       ROUND(SUM(c.NB), 2) AS TotalAmount, MAX(c.NBCcy) AS TotalAmountCcy,
       CASE WHEN SUM(c.NB) <> 0 THEN SUM(c.NB * c.SR) / SUM(c.NB) ELSE AVG(c.SR) END AS SwapRate,
       MAX(c.SellCcy) AS SoldCcy, ROUND(SUM(c.SellAmount), 2) AS SoldAmount, MAX(c.BuyCcy) AS BoughtCcy, ROUND(SUM(c.BuyAmount), 2) AS BoughtAmount,
       ROUND(SUM(c.Ounce), 2) AS Ounce, ROUND(SUM(c.Gram), 2) AS Gram,
       COUNT(*) AS TxnCount, STRING_AGG(c.NearRef, ', ') AS Refs,
       MAX(c.JoinCnt) AS JoinCnt, (SELECT COUNT(*) FROM M) AS PkgCnt
FROM C c
LEFT JOIN CusCustomer cu ON cu.Id = c.CustomerId
GROUP BY c.CustomerId, cu.Name, UPPER(c.CcyPair), c.Direction, c.NearDate, c.FarDate
ORDER BY MaxNearId DESC;
```

DB: `NetTrexFX` · Server: `tcp:192.168.10.211,1433` · User: `trusr` · Pass: `***`


## #100

**Amaç:** Test FX Swap: Valör + vade birlikte — valör 2026-10-01–2026-10-01, vade 2026-10-02–2026-10-02. API (ekran) gruplanmış satırları ile karşılaştırma (aynı join/gruplama/oran formülü).

```sql
SET NOCOUNT ON;
DECLARE @LD date = '2026-10-02';
WITH N AS (SELECT * FROM TxnFXSwap WHERE InstrumentId = 1068 AND (StateId & 6) = 2 AND ValueDate >= '2026-10-01' AND ValueDate < DATEADD(day, 1, CAST('2026-10-01' AS date))),
F AS (SELECT * FROM TxnFXSwap WHERE InstrumentId = 1069 AND (StateId & 6) = 2 AND ValueDate >= '2026-10-02' AND ValueDate < DATEADD(day, 1, CAST('2026-10-02' AS date))),
P AS (
    SELECT n.PkgNo, n.Id AS NearId, f.Id AS FarId, n.CustomerId, LTRIM(RTRIM(n.CcyPair)) AS CcyPair, n.LogicalReference AS NearRef,
           n.BuyCcy, n.BuyAmount, n.SellCcy, n.SellAmount, 
           CAST(n.DealRateNet AS float) AS NearRate, CAST(f.DealRateNet AS float) AS FarRate,
           CAST(n.ValueDate AS date) AS NearDate, CAST(f.ValueDate AS date) AS FarDate,
           COUNT(*) OVER () AS JoinCnt,
           ROW_NUMBER() OVER (PARTITION BY n.PkgNo ORDER BY n.Id DESC, f.Id DESC) AS Rn
    FROM N n JOIN F f ON f.PkgNo = n.PkgNo
    WHERE n.PkgNo <> 0
),
M AS (
    SELECT p.*, CASE WHEN UPPER(p.BuyCcy) = UPPER(CASE WHEN CHARINDEX('/', p.CcyPair) > 1 THEN LTRIM(RTRIM(LEFT(p.CcyPair, CHARINDEX('/', p.CcyPair) - 1)))
                                     WHEN LEN(p.CcyPair) >= 6 THEN LEFT(p.CcyPair, 3) ELSE p.BuyCcy END) THEN 1 ELSE 0 END AS BaseBought
    FROM P p WHERE p.Rn = 1
),
C AS (
    SELECT m.*, CASE WHEN BaseBought = 1 THEN 'B/S' ELSE 'S/B' END AS Direction,
           CAST(CASE WHEN BaseBought = 1 THEN SellAmount ELSE BuyAmount END AS float) AS NB,
           CASE WHEN BaseBought = 1 THEN SellCcy ELSE BuyCcy END AS NBCcy,
           CAST(0 AS float) AS Ounce, CAST(0 AS float) AS Gram,
           CASE WHEN NearRate = 0 THEN 0 ELSE (FarRate - NearRate) / NearRate * (360.0 / CASE WHEN DATEDIFF(day, NearDate, FarDate) = 0 THEN 1 ELSE DATEDIFF(day, NearDate, FarDate) END) * 100 END AS SR
    FROM M m
)
SELECT TOP (20) MAX(c.NearId) AS MaxNearId, cu.Name AS CounterpartyName, UPPER(c.CcyPair) AS CcyPair, c.Direction, c.NearDate, c.FarDate,
       DATEDIFF(day, c.NearDate, c.FarDate) AS Tenor,
       CASE WHEN c.FarDate < @LD THEN 0 ELSE DATEDIFF(day, @LD, c.FarDate) END AS DaysToMaturity,
       ROUND(SUM(c.NB), 2) AS TotalAmount, MAX(c.NBCcy) AS TotalAmountCcy,
       CASE WHEN SUM(c.NB) <> 0 THEN SUM(c.NB * c.SR) / SUM(c.NB) ELSE AVG(c.SR) END AS SwapRate,
       MAX(c.SellCcy) AS SoldCcy, ROUND(SUM(c.SellAmount), 2) AS SoldAmount, MAX(c.BuyCcy) AS BoughtCcy, ROUND(SUM(c.BuyAmount), 2) AS BoughtAmount,
       ROUND(SUM(c.Ounce), 2) AS Ounce, ROUND(SUM(c.Gram), 2) AS Gram,
       COUNT(*) AS TxnCount, STRING_AGG(c.NearRef, ', ') AS Refs,
       MAX(c.JoinCnt) AS JoinCnt, (SELECT COUNT(*) FROM M) AS PkgCnt
FROM C c
LEFT JOIN CusCustomer cu ON cu.Id = c.CustomerId
GROUP BY c.CustomerId, cu.Name, UPPER(c.CcyPair), c.Direction, c.NearDate, c.FarDate
ORDER BY MaxNearId DESC;
```

DB: `NetTrexFX` · Server: `tcp:192.168.10.211,1433` · User: `trusr` · Pass: `***`


## #101

**Amaç:** Test FX Swap: Geniş aralık — valör 2020-01-01–2030-12-31, vade 2020-01-01–2030-12-31. API (ekran) gruplanmış satırları ile karşılaştırma (aynı join/gruplama/oran formülü).

```sql
SET NOCOUNT ON;
DECLARE @LD date = '2026-10-02';
WITH N AS (SELECT * FROM TxnFXSwap WHERE InstrumentId = 1068 AND (StateId & 6) = 2 AND ValueDate >= '2020-01-01' AND ValueDate < DATEADD(day, 1, CAST('2030-12-31' AS date))),
F AS (SELECT * FROM TxnFXSwap WHERE InstrumentId = 1069 AND (StateId & 6) = 2 AND ValueDate >= '2020-01-01' AND ValueDate < DATEADD(day, 1, CAST('2030-12-31' AS date))),
P AS (
    SELECT n.PkgNo, n.Id AS NearId, f.Id AS FarId, n.CustomerId, LTRIM(RTRIM(n.CcyPair)) AS CcyPair, n.LogicalReference AS NearRef,
           n.BuyCcy, n.BuyAmount, n.SellCcy, n.SellAmount, 
           CAST(n.DealRateNet AS float) AS NearRate, CAST(f.DealRateNet AS float) AS FarRate,
           CAST(n.ValueDate AS date) AS NearDate, CAST(f.ValueDate AS date) AS FarDate,
           COUNT(*) OVER () AS JoinCnt,
           ROW_NUMBER() OVER (PARTITION BY n.PkgNo ORDER BY n.Id DESC, f.Id DESC) AS Rn
    FROM N n JOIN F f ON f.PkgNo = n.PkgNo
    WHERE n.PkgNo <> 0
),
M AS (
    SELECT p.*, CASE WHEN UPPER(p.BuyCcy) = UPPER(CASE WHEN CHARINDEX('/', p.CcyPair) > 1 THEN LTRIM(RTRIM(LEFT(p.CcyPair, CHARINDEX('/', p.CcyPair) - 1)))
                                     WHEN LEN(p.CcyPair) >= 6 THEN LEFT(p.CcyPair, 3) ELSE p.BuyCcy END) THEN 1 ELSE 0 END AS BaseBought
    FROM P p WHERE p.Rn = 1
),
C AS (
    SELECT m.*, CASE WHEN BaseBought = 1 THEN 'B/S' ELSE 'S/B' END AS Direction,
           CAST(CASE WHEN BaseBought = 1 THEN SellAmount ELSE BuyAmount END AS float) AS NB,
           CASE WHEN BaseBought = 1 THEN SellCcy ELSE BuyCcy END AS NBCcy,
           CAST(0 AS float) AS Ounce, CAST(0 AS float) AS Gram,
           CASE WHEN NearRate = 0 THEN 0 ELSE (FarRate - NearRate) / NearRate * (360.0 / CASE WHEN DATEDIFF(day, NearDate, FarDate) = 0 THEN 1 ELSE DATEDIFF(day, NearDate, FarDate) END) * 100 END AS SR
    FROM M m
)
SELECT TOP (20) MAX(c.NearId) AS MaxNearId, cu.Name AS CounterpartyName, UPPER(c.CcyPair) AS CcyPair, c.Direction, c.NearDate, c.FarDate,
       DATEDIFF(day, c.NearDate, c.FarDate) AS Tenor,
       CASE WHEN c.FarDate < @LD THEN 0 ELSE DATEDIFF(day, @LD, c.FarDate) END AS DaysToMaturity,
       ROUND(SUM(c.NB), 2) AS TotalAmount, MAX(c.NBCcy) AS TotalAmountCcy,
       CASE WHEN SUM(c.NB) <> 0 THEN SUM(c.NB * c.SR) / SUM(c.NB) ELSE AVG(c.SR) END AS SwapRate,
       MAX(c.SellCcy) AS SoldCcy, ROUND(SUM(c.SellAmount), 2) AS SoldAmount, MAX(c.BuyCcy) AS BoughtCcy, ROUND(SUM(c.BuyAmount), 2) AS BoughtAmount,
       ROUND(SUM(c.Ounce), 2) AS Ounce, ROUND(SUM(c.Gram), 2) AS Gram,
       COUNT(*) AS TxnCount, STRING_AGG(c.NearRef, ', ') AS Refs,
       MAX(c.JoinCnt) AS JoinCnt, (SELECT COUNT(*) FROM M) AS PkgCnt
FROM C c
LEFT JOIN CusCustomer cu ON cu.Id = c.CustomerId
GROUP BY c.CustomerId, cu.Name, UPPER(c.CcyPair), c.Direction, c.NearDate, c.FarDate
ORDER BY MaxNearId DESC;
```

DB: `NetTrexFX` · Server: `tcp:192.168.10.211,1433` · User: `trusr` · Pass: `***`


## #102

**Amaç:** Test FX Swap: Yalnız referans önek — ref 'TFXSW261001'. API (ekran) gruplanmış satırları ile karşılaştırma (aynı join/gruplama/oran formülü).

```sql
SET NOCOUNT ON;
DECLARE @LD date = '2026-10-02';
WITH N AS (SELECT * FROM TxnFXSwap WHERE InstrumentId = 1068 AND (StateId & 6) = 2),
F AS (SELECT * FROM TxnFXSwap WHERE InstrumentId = 1069 AND (StateId & 6) = 2),
P AS (
    SELECT n.PkgNo, n.Id AS NearId, f.Id AS FarId, n.CustomerId, LTRIM(RTRIM(n.CcyPair)) AS CcyPair, n.LogicalReference AS NearRef,
           n.BuyCcy, n.BuyAmount, n.SellCcy, n.SellAmount, 
           CAST(n.DealRateNet AS float) AS NearRate, CAST(f.DealRateNet AS float) AS FarRate,
           CAST(n.ValueDate AS date) AS NearDate, CAST(f.ValueDate AS date) AS FarDate,
           COUNT(*) OVER () AS JoinCnt,
           ROW_NUMBER() OVER (PARTITION BY n.PkgNo ORDER BY n.Id DESC, f.Id DESC) AS Rn
    FROM N n JOIN F f ON f.PkgNo = n.PkgNo
    WHERE n.PkgNo <> 0 AND (n.LogicalReference LIKE '%TFXSW261001%' OR f.LogicalReference LIKE '%TFXSW261001%')
),
M AS (
    SELECT p.*, CASE WHEN UPPER(p.BuyCcy) = UPPER(CASE WHEN CHARINDEX('/', p.CcyPair) > 1 THEN LTRIM(RTRIM(LEFT(p.CcyPair, CHARINDEX('/', p.CcyPair) - 1)))
                                     WHEN LEN(p.CcyPair) >= 6 THEN LEFT(p.CcyPair, 3) ELSE p.BuyCcy END) THEN 1 ELSE 0 END AS BaseBought
    FROM P p WHERE p.Rn = 1
),
C AS (
    SELECT m.*, CASE WHEN BaseBought = 1 THEN 'B/S' ELSE 'S/B' END AS Direction,
           CAST(CASE WHEN BaseBought = 1 THEN SellAmount ELSE BuyAmount END AS float) AS NB,
           CASE WHEN BaseBought = 1 THEN SellCcy ELSE BuyCcy END AS NBCcy,
           CAST(0 AS float) AS Ounce, CAST(0 AS float) AS Gram,
           CASE WHEN NearRate = 0 THEN 0 ELSE (FarRate - NearRate) / NearRate * (360.0 / CASE WHEN DATEDIFF(day, NearDate, FarDate) = 0 THEN 1 ELSE DATEDIFF(day, NearDate, FarDate) END) * 100 END AS SR
    FROM M m
)
SELECT TOP (20) MAX(c.NearId) AS MaxNearId, cu.Name AS CounterpartyName, UPPER(c.CcyPair) AS CcyPair, c.Direction, c.NearDate, c.FarDate,
       DATEDIFF(day, c.NearDate, c.FarDate) AS Tenor,
       CASE WHEN c.FarDate < @LD THEN 0 ELSE DATEDIFF(day, @LD, c.FarDate) END AS DaysToMaturity,
       ROUND(SUM(c.NB), 2) AS TotalAmount, MAX(c.NBCcy) AS TotalAmountCcy,
       CASE WHEN SUM(c.NB) <> 0 THEN SUM(c.NB * c.SR) / SUM(c.NB) ELSE AVG(c.SR) END AS SwapRate,
       MAX(c.SellCcy) AS SoldCcy, ROUND(SUM(c.SellAmount), 2) AS SoldAmount, MAX(c.BuyCcy) AS BoughtCcy, ROUND(SUM(c.BuyAmount), 2) AS BoughtAmount,
       ROUND(SUM(c.Ounce), 2) AS Ounce, ROUND(SUM(c.Gram), 2) AS Gram,
       COUNT(*) AS TxnCount, STRING_AGG(c.NearRef, ', ') AS Refs,
       MAX(c.JoinCnt) AS JoinCnt, (SELECT COUNT(*) FROM M) AS PkgCnt
FROM C c
LEFT JOIN CusCustomer cu ON cu.Id = c.CustomerId
GROUP BY c.CustomerId, cu.Name, UPPER(c.CcyPair), c.Direction, c.NearDate, c.FarDate
ORDER BY MaxNearId DESC;
```

DB: `NetTrexFX` · Server: `tcp:192.168.10.211,1433` · User: `trusr` · Pass: `***`


## #103

**Amaç:** Test FX Swap: Tam referans (near bacak) — ref 'TFXSW26100100011'. API (ekran) gruplanmış satırları ile karşılaştırma (aynı join/gruplama/oran formülü).

```sql
SET NOCOUNT ON;
DECLARE @LD date = '2026-10-02';
WITH N AS (SELECT * FROM TxnFXSwap WHERE InstrumentId = 1068 AND (StateId & 6) = 2),
F AS (SELECT * FROM TxnFXSwap WHERE InstrumentId = 1069 AND (StateId & 6) = 2),
P AS (
    SELECT n.PkgNo, n.Id AS NearId, f.Id AS FarId, n.CustomerId, LTRIM(RTRIM(n.CcyPair)) AS CcyPair, n.LogicalReference AS NearRef,
           n.BuyCcy, n.BuyAmount, n.SellCcy, n.SellAmount, 
           CAST(n.DealRateNet AS float) AS NearRate, CAST(f.DealRateNet AS float) AS FarRate,
           CAST(n.ValueDate AS date) AS NearDate, CAST(f.ValueDate AS date) AS FarDate,
           COUNT(*) OVER () AS JoinCnt,
           ROW_NUMBER() OVER (PARTITION BY n.PkgNo ORDER BY n.Id DESC, f.Id DESC) AS Rn
    FROM N n JOIN F f ON f.PkgNo = n.PkgNo
    WHERE n.PkgNo <> 0 AND (n.LogicalReference LIKE '%TFXSW26100100011%' OR f.LogicalReference LIKE '%TFXSW26100100011%')
),
M AS (
    SELECT p.*, CASE WHEN UPPER(p.BuyCcy) = UPPER(CASE WHEN CHARINDEX('/', p.CcyPair) > 1 THEN LTRIM(RTRIM(LEFT(p.CcyPair, CHARINDEX('/', p.CcyPair) - 1)))
                                     WHEN LEN(p.CcyPair) >= 6 THEN LEFT(p.CcyPair, 3) ELSE p.BuyCcy END) THEN 1 ELSE 0 END AS BaseBought
    FROM P p WHERE p.Rn = 1
),
C AS (
    SELECT m.*, CASE WHEN BaseBought = 1 THEN 'B/S' ELSE 'S/B' END AS Direction,
           CAST(CASE WHEN BaseBought = 1 THEN SellAmount ELSE BuyAmount END AS float) AS NB,
           CASE WHEN BaseBought = 1 THEN SellCcy ELSE BuyCcy END AS NBCcy,
           CAST(0 AS float) AS Ounce, CAST(0 AS float) AS Gram,
           CASE WHEN NearRate = 0 THEN 0 ELSE (FarRate - NearRate) / NearRate * (360.0 / CASE WHEN DATEDIFF(day, NearDate, FarDate) = 0 THEN 1 ELSE DATEDIFF(day, NearDate, FarDate) END) * 100 END AS SR
    FROM M m
)
SELECT TOP (20) MAX(c.NearId) AS MaxNearId, cu.Name AS CounterpartyName, UPPER(c.CcyPair) AS CcyPair, c.Direction, c.NearDate, c.FarDate,
       DATEDIFF(day, c.NearDate, c.FarDate) AS Tenor,
       CASE WHEN c.FarDate < @LD THEN 0 ELSE DATEDIFF(day, @LD, c.FarDate) END AS DaysToMaturity,
       ROUND(SUM(c.NB), 2) AS TotalAmount, MAX(c.NBCcy) AS TotalAmountCcy,
       CASE WHEN SUM(c.NB) <> 0 THEN SUM(c.NB * c.SR) / SUM(c.NB) ELSE AVG(c.SR) END AS SwapRate,
       MAX(c.SellCcy) AS SoldCcy, ROUND(SUM(c.SellAmount), 2) AS SoldAmount, MAX(c.BuyCcy) AS BoughtCcy, ROUND(SUM(c.BuyAmount), 2) AS BoughtAmount,
       ROUND(SUM(c.Ounce), 2) AS Ounce, ROUND(SUM(c.Gram), 2) AS Gram,
       COUNT(*) AS TxnCount, STRING_AGG(c.NearRef, ', ') AS Refs,
       MAX(c.JoinCnt) AS JoinCnt, (SELECT COUNT(*) FROM M) AS PkgCnt
FROM C c
LEFT JOIN CusCustomer cu ON cu.Id = c.CustomerId
GROUP BY c.CustomerId, cu.Name, UPPER(c.CcyPair), c.Direction, c.NearDate, c.FarDate
ORDER BY MaxNearId DESC;
```

DB: `NetTrexFX` · Server: `tcp:192.168.10.211,1433` · User: `trusr` · Pass: `***`


## #104

**Amaç:** Test FX Swap: Tam referans (far bacak) — ref 'TFXSW26100100010'. API (ekran) gruplanmış satırları ile karşılaştırma (aynı join/gruplama/oran formülü).

```sql
SET NOCOUNT ON;
DECLARE @LD date = '2026-10-02';
WITH N AS (SELECT * FROM TxnFXSwap WHERE InstrumentId = 1068 AND (StateId & 6) = 2),
F AS (SELECT * FROM TxnFXSwap WHERE InstrumentId = 1069 AND (StateId & 6) = 2),
P AS (
    SELECT n.PkgNo, n.Id AS NearId, f.Id AS FarId, n.CustomerId, LTRIM(RTRIM(n.CcyPair)) AS CcyPair, n.LogicalReference AS NearRef,
           n.BuyCcy, n.BuyAmount, n.SellCcy, n.SellAmount, 
           CAST(n.DealRateNet AS float) AS NearRate, CAST(f.DealRateNet AS float) AS FarRate,
           CAST(n.ValueDate AS date) AS NearDate, CAST(f.ValueDate AS date) AS FarDate,
           COUNT(*) OVER () AS JoinCnt,
           ROW_NUMBER() OVER (PARTITION BY n.PkgNo ORDER BY n.Id DESC, f.Id DESC) AS Rn
    FROM N n JOIN F f ON f.PkgNo = n.PkgNo
    WHERE n.PkgNo <> 0 AND (n.LogicalReference LIKE '%TFXSW26100100010%' OR f.LogicalReference LIKE '%TFXSW26100100010%')
),
M AS (
    SELECT p.*, CASE WHEN UPPER(p.BuyCcy) = UPPER(CASE WHEN CHARINDEX('/', p.CcyPair) > 1 THEN LTRIM(RTRIM(LEFT(p.CcyPair, CHARINDEX('/', p.CcyPair) - 1)))
                                     WHEN LEN(p.CcyPair) >= 6 THEN LEFT(p.CcyPair, 3) ELSE p.BuyCcy END) THEN 1 ELSE 0 END AS BaseBought
    FROM P p WHERE p.Rn = 1
),
C AS (
    SELECT m.*, CASE WHEN BaseBought = 1 THEN 'B/S' ELSE 'S/B' END AS Direction,
           CAST(CASE WHEN BaseBought = 1 THEN SellAmount ELSE BuyAmount END AS float) AS NB,
           CASE WHEN BaseBought = 1 THEN SellCcy ELSE BuyCcy END AS NBCcy,
           CAST(0 AS float) AS Ounce, CAST(0 AS float) AS Gram,
           CASE WHEN NearRate = 0 THEN 0 ELSE (FarRate - NearRate) / NearRate * (360.0 / CASE WHEN DATEDIFF(day, NearDate, FarDate) = 0 THEN 1 ELSE DATEDIFF(day, NearDate, FarDate) END) * 100 END AS SR
    FROM M m
)
SELECT TOP (20) MAX(c.NearId) AS MaxNearId, cu.Name AS CounterpartyName, UPPER(c.CcyPair) AS CcyPair, c.Direction, c.NearDate, c.FarDate,
       DATEDIFF(day, c.NearDate, c.FarDate) AS Tenor,
       CASE WHEN c.FarDate < @LD THEN 0 ELSE DATEDIFF(day, @LD, c.FarDate) END AS DaysToMaturity,
       ROUND(SUM(c.NB), 2) AS TotalAmount, MAX(c.NBCcy) AS TotalAmountCcy,
       CASE WHEN SUM(c.NB) <> 0 THEN SUM(c.NB * c.SR) / SUM(c.NB) ELSE AVG(c.SR) END AS SwapRate,
       MAX(c.SellCcy) AS SoldCcy, ROUND(SUM(c.SellAmount), 2) AS SoldAmount, MAX(c.BuyCcy) AS BoughtCcy, ROUND(SUM(c.BuyAmount), 2) AS BoughtAmount,
       ROUND(SUM(c.Ounce), 2) AS Ounce, ROUND(SUM(c.Gram), 2) AS Gram,
       COUNT(*) AS TxnCount, STRING_AGG(c.NearRef, ', ') AS Refs,
       MAX(c.JoinCnt) AS JoinCnt, (SELECT COUNT(*) FROM M) AS PkgCnt
FROM C c
LEFT JOIN CusCustomer cu ON cu.Id = c.CustomerId
GROUP BY c.CustomerId, cu.Name, UPPER(c.CcyPair), c.Direction, c.NearDate, c.FarDate
ORDER BY MaxNearId DESC;
```

DB: `NetTrexFX` · Server: `tcp:192.168.10.211,1433` · User: `trusr` · Pass: `***`


## #105

**Amaç:** Test FX Swap: Referans + tarih — valör 2026-10-01–2026-10-31, ref 'TFXSW26100100013'. API (ekran) gruplanmış satırları ile karşılaştırma (aynı join/gruplama/oran formülü).

```sql
SET NOCOUNT ON;
DECLARE @LD date = '2026-10-02';
WITH N AS (SELECT * FROM TxnFXSwap WHERE InstrumentId = 1068 AND (StateId & 6) = 2 AND ValueDate >= '2026-10-01' AND ValueDate < DATEADD(day, 1, CAST('2026-10-31' AS date))),
F AS (SELECT * FROM TxnFXSwap WHERE InstrumentId = 1069 AND (StateId & 6) = 2),
P AS (
    SELECT n.PkgNo, n.Id AS NearId, f.Id AS FarId, n.CustomerId, LTRIM(RTRIM(n.CcyPair)) AS CcyPair, n.LogicalReference AS NearRef,
           n.BuyCcy, n.BuyAmount, n.SellCcy, n.SellAmount, 
           CAST(n.DealRateNet AS float) AS NearRate, CAST(f.DealRateNet AS float) AS FarRate,
           CAST(n.ValueDate AS date) AS NearDate, CAST(f.ValueDate AS date) AS FarDate,
           COUNT(*) OVER () AS JoinCnt,
           ROW_NUMBER() OVER (PARTITION BY n.PkgNo ORDER BY n.Id DESC, f.Id DESC) AS Rn
    FROM N n JOIN F f ON f.PkgNo = n.PkgNo
    WHERE n.PkgNo <> 0 AND (n.LogicalReference LIKE '%TFXSW26100100013%' OR f.LogicalReference LIKE '%TFXSW26100100013%')
),
M AS (
    SELECT p.*, CASE WHEN UPPER(p.BuyCcy) = UPPER(CASE WHEN CHARINDEX('/', p.CcyPair) > 1 THEN LTRIM(RTRIM(LEFT(p.CcyPair, CHARINDEX('/', p.CcyPair) - 1)))
                                     WHEN LEN(p.CcyPair) >= 6 THEN LEFT(p.CcyPair, 3) ELSE p.BuyCcy END) THEN 1 ELSE 0 END AS BaseBought
    FROM P p WHERE p.Rn = 1
),
C AS (
    SELECT m.*, CASE WHEN BaseBought = 1 THEN 'B/S' ELSE 'S/B' END AS Direction,
           CAST(CASE WHEN BaseBought = 1 THEN SellAmount ELSE BuyAmount END AS float) AS NB,
           CASE WHEN BaseBought = 1 THEN SellCcy ELSE BuyCcy END AS NBCcy,
           CAST(0 AS float) AS Ounce, CAST(0 AS float) AS Gram,
           CASE WHEN NearRate = 0 THEN 0 ELSE (FarRate - NearRate) / NearRate * (360.0 / CASE WHEN DATEDIFF(day, NearDate, FarDate) = 0 THEN 1 ELSE DATEDIFF(day, NearDate, FarDate) END) * 100 END AS SR
    FROM M m
)
SELECT TOP (20) MAX(c.NearId) AS MaxNearId, cu.Name AS CounterpartyName, UPPER(c.CcyPair) AS CcyPair, c.Direction, c.NearDate, c.FarDate,
       DATEDIFF(day, c.NearDate, c.FarDate) AS Tenor,
       CASE WHEN c.FarDate < @LD THEN 0 ELSE DATEDIFF(day, @LD, c.FarDate) END AS DaysToMaturity,
       ROUND(SUM(c.NB), 2) AS TotalAmount, MAX(c.NBCcy) AS TotalAmountCcy,
       CASE WHEN SUM(c.NB) <> 0 THEN SUM(c.NB * c.SR) / SUM(c.NB) ELSE AVG(c.SR) END AS SwapRate,
       MAX(c.SellCcy) AS SoldCcy, ROUND(SUM(c.SellAmount), 2) AS SoldAmount, MAX(c.BuyCcy) AS BoughtCcy, ROUND(SUM(c.BuyAmount), 2) AS BoughtAmount,
       ROUND(SUM(c.Ounce), 2) AS Ounce, ROUND(SUM(c.Gram), 2) AS Gram,
       COUNT(*) AS TxnCount, STRING_AGG(c.NearRef, ', ') AS Refs,
       MAX(c.JoinCnt) AS JoinCnt, (SELECT COUNT(*) FROM M) AS PkgCnt
FROM C c
LEFT JOIN CusCustomer cu ON cu.Id = c.CustomerId
GROUP BY c.CustomerId, cu.Name, UPPER(c.CcyPair), c.Direction, c.NearDate, c.FarDate
ORDER BY MaxNearId DESC;
```

DB: `NetTrexFX` · Server: `tcp:192.168.10.211,1433` · User: `trusr` · Pass: `***`


## #106

**Amaç:** Test FX Swap: Olmayan referans — ref 'YOKBOYLEREF'. API (ekran) gruplanmış satırları ile karşılaştırma (aynı join/gruplama/oran formülü).

```sql
SET NOCOUNT ON;
DECLARE @LD date = '2026-10-02';
WITH N AS (SELECT * FROM TxnFXSwap WHERE InstrumentId = 1068 AND (StateId & 6) = 2),
F AS (SELECT * FROM TxnFXSwap WHERE InstrumentId = 1069 AND (StateId & 6) = 2),
P AS (
    SELECT n.PkgNo, n.Id AS NearId, f.Id AS FarId, n.CustomerId, LTRIM(RTRIM(n.CcyPair)) AS CcyPair, n.LogicalReference AS NearRef,
           n.BuyCcy, n.BuyAmount, n.SellCcy, n.SellAmount, 
           CAST(n.DealRateNet AS float) AS NearRate, CAST(f.DealRateNet AS float) AS FarRate,
           CAST(n.ValueDate AS date) AS NearDate, CAST(f.ValueDate AS date) AS FarDate,
           COUNT(*) OVER () AS JoinCnt,
           ROW_NUMBER() OVER (PARTITION BY n.PkgNo ORDER BY n.Id DESC, f.Id DESC) AS Rn
    FROM N n JOIN F f ON f.PkgNo = n.PkgNo
    WHERE n.PkgNo <> 0 AND (n.LogicalReference LIKE '%YOKBOYLEREF%' OR f.LogicalReference LIKE '%YOKBOYLEREF%')
),
M AS (
    SELECT p.*, CASE WHEN UPPER(p.BuyCcy) = UPPER(CASE WHEN CHARINDEX('/', p.CcyPair) > 1 THEN LTRIM(RTRIM(LEFT(p.CcyPair, CHARINDEX('/', p.CcyPair) - 1)))
                                     WHEN LEN(p.CcyPair) >= 6 THEN LEFT(p.CcyPair, 3) ELSE p.BuyCcy END) THEN 1 ELSE 0 END AS BaseBought
    FROM P p WHERE p.Rn = 1
),
C AS (
    SELECT m.*, CASE WHEN BaseBought = 1 THEN 'B/S' ELSE 'S/B' END AS Direction,
           CAST(CASE WHEN BaseBought = 1 THEN SellAmount ELSE BuyAmount END AS float) AS NB,
           CASE WHEN BaseBought = 1 THEN SellCcy ELSE BuyCcy END AS NBCcy,
           CAST(0 AS float) AS Ounce, CAST(0 AS float) AS Gram,
           CASE WHEN NearRate = 0 THEN 0 ELSE (FarRate - NearRate) / NearRate * (360.0 / CASE WHEN DATEDIFF(day, NearDate, FarDate) = 0 THEN 1 ELSE DATEDIFF(day, NearDate, FarDate) END) * 100 END AS SR
    FROM M m
)
SELECT TOP (20) MAX(c.NearId) AS MaxNearId, cu.Name AS CounterpartyName, UPPER(c.CcyPair) AS CcyPair, c.Direction, c.NearDate, c.FarDate,
       DATEDIFF(day, c.NearDate, c.FarDate) AS Tenor,
       CASE WHEN c.FarDate < @LD THEN 0 ELSE DATEDIFF(day, @LD, c.FarDate) END AS DaysToMaturity,
       ROUND(SUM(c.NB), 2) AS TotalAmount, MAX(c.NBCcy) AS TotalAmountCcy,
       CASE WHEN SUM(c.NB) <> 0 THEN SUM(c.NB * c.SR) / SUM(c.NB) ELSE AVG(c.SR) END AS SwapRate,
       MAX(c.SellCcy) AS SoldCcy, ROUND(SUM(c.SellAmount), 2) AS SoldAmount, MAX(c.BuyCcy) AS BoughtCcy, ROUND(SUM(c.BuyAmount), 2) AS BoughtAmount,
       ROUND(SUM(c.Ounce), 2) AS Ounce, ROUND(SUM(c.Gram), 2) AS Gram,
       COUNT(*) AS TxnCount, STRING_AGG(c.NearRef, ', ') AS Refs,
       MAX(c.JoinCnt) AS JoinCnt, (SELECT COUNT(*) FROM M) AS PkgCnt
FROM C c
LEFT JOIN CusCustomer cu ON cu.Id = c.CustomerId
GROUP BY c.CustomerId, cu.Name, UPPER(c.CcyPair), c.Direction, c.NearDate, c.FarDate
ORDER BY MaxNearId DESC;
```

DB: `NetTrexFX` · Server: `tcp:192.168.10.211,1433` · User: `trusr` · Pass: `***`


## #107

**Amaç:** Test FX Swap: Input (16) paketin referansı — ref 'TFXSW26100100005'. API (ekran) gruplanmış satırları ile karşılaştırma (aynı join/gruplama/oran formülü).

```sql
SET NOCOUNT ON;
DECLARE @LD date = '2026-10-02';
WITH N AS (SELECT * FROM TxnFXSwap WHERE InstrumentId = 1068 AND (StateId & 6) = 2),
F AS (SELECT * FROM TxnFXSwap WHERE InstrumentId = 1069 AND (StateId & 6) = 2),
P AS (
    SELECT n.PkgNo, n.Id AS NearId, f.Id AS FarId, n.CustomerId, LTRIM(RTRIM(n.CcyPair)) AS CcyPair, n.LogicalReference AS NearRef,
           n.BuyCcy, n.BuyAmount, n.SellCcy, n.SellAmount, 
           CAST(n.DealRateNet AS float) AS NearRate, CAST(f.DealRateNet AS float) AS FarRate,
           CAST(n.ValueDate AS date) AS NearDate, CAST(f.ValueDate AS date) AS FarDate,
           COUNT(*) OVER () AS JoinCnt,
           ROW_NUMBER() OVER (PARTITION BY n.PkgNo ORDER BY n.Id DESC, f.Id DESC) AS Rn
    FROM N n JOIN F f ON f.PkgNo = n.PkgNo
    WHERE n.PkgNo <> 0 AND (n.LogicalReference LIKE '%TFXSW26100100005%' OR f.LogicalReference LIKE '%TFXSW26100100005%')
),
M AS (
    SELECT p.*, CASE WHEN UPPER(p.BuyCcy) = UPPER(CASE WHEN CHARINDEX('/', p.CcyPair) > 1 THEN LTRIM(RTRIM(LEFT(p.CcyPair, CHARINDEX('/', p.CcyPair) - 1)))
                                     WHEN LEN(p.CcyPair) >= 6 THEN LEFT(p.CcyPair, 3) ELSE p.BuyCcy END) THEN 1 ELSE 0 END AS BaseBought
    FROM P p WHERE p.Rn = 1
),
C AS (
    SELECT m.*, CASE WHEN BaseBought = 1 THEN 'B/S' ELSE 'S/B' END AS Direction,
           CAST(CASE WHEN BaseBought = 1 THEN SellAmount ELSE BuyAmount END AS float) AS NB,
           CASE WHEN BaseBought = 1 THEN SellCcy ELSE BuyCcy END AS NBCcy,
           CAST(0 AS float) AS Ounce, CAST(0 AS float) AS Gram,
           CASE WHEN NearRate = 0 THEN 0 ELSE (FarRate - NearRate) / NearRate * (360.0 / CASE WHEN DATEDIFF(day, NearDate, FarDate) = 0 THEN 1 ELSE DATEDIFF(day, NearDate, FarDate) END) * 100 END AS SR
    FROM M m
)
SELECT TOP (20) MAX(c.NearId) AS MaxNearId, cu.Name AS CounterpartyName, UPPER(c.CcyPair) AS CcyPair, c.Direction, c.NearDate, c.FarDate,
       DATEDIFF(day, c.NearDate, c.FarDate) AS Tenor,
       CASE WHEN c.FarDate < @LD THEN 0 ELSE DATEDIFF(day, @LD, c.FarDate) END AS DaysToMaturity,
       ROUND(SUM(c.NB), 2) AS TotalAmount, MAX(c.NBCcy) AS TotalAmountCcy,
       CASE WHEN SUM(c.NB) <> 0 THEN SUM(c.NB * c.SR) / SUM(c.NB) ELSE AVG(c.SR) END AS SwapRate,
       MAX(c.SellCcy) AS SoldCcy, ROUND(SUM(c.SellAmount), 2) AS SoldAmount, MAX(c.BuyCcy) AS BoughtCcy, ROUND(SUM(c.BuyAmount), 2) AS BoughtAmount,
       ROUND(SUM(c.Ounce), 2) AS Ounce, ROUND(SUM(c.Gram), 2) AS Gram,
       COUNT(*) AS TxnCount, STRING_AGG(c.NearRef, ', ') AS Refs,
       MAX(c.JoinCnt) AS JoinCnt, (SELECT COUNT(*) FROM M) AS PkgCnt
FROM C c
LEFT JOIN CusCustomer cu ON cu.Id = c.CustomerId
GROUP BY c.CustomerId, cu.Name, UPPER(c.CcyPair), c.Direction, c.NearDate, c.FarDate
ORDER BY MaxNearId DESC;
```

DB: `NetTrexFX` · Server: `tcp:192.168.10.211,1433` · User: `trusr` · Pass: `***`


## #108

**Amaç:** Test FX Swap: DeleteVerified (22) paketin referansı — ref 'TFXSW26100100007'. API (ekran) gruplanmış satırları ile karşılaştırma (aynı join/gruplama/oran formülü).

```sql
SET NOCOUNT ON;
DECLARE @LD date = '2026-10-02';
WITH N AS (SELECT * FROM TxnFXSwap WHERE InstrumentId = 1068 AND (StateId & 6) = 2),
F AS (SELECT * FROM TxnFXSwap WHERE InstrumentId = 1069 AND (StateId & 6) = 2),
P AS (
    SELECT n.PkgNo, n.Id AS NearId, f.Id AS FarId, n.CustomerId, LTRIM(RTRIM(n.CcyPair)) AS CcyPair, n.LogicalReference AS NearRef,
           n.BuyCcy, n.BuyAmount, n.SellCcy, n.SellAmount, 
           CAST(n.DealRateNet AS float) AS NearRate, CAST(f.DealRateNet AS float) AS FarRate,
           CAST(n.ValueDate AS date) AS NearDate, CAST(f.ValueDate AS date) AS FarDate,
           COUNT(*) OVER () AS JoinCnt,
           ROW_NUMBER() OVER (PARTITION BY n.PkgNo ORDER BY n.Id DESC, f.Id DESC) AS Rn
    FROM N n JOIN F f ON f.PkgNo = n.PkgNo
    WHERE n.PkgNo <> 0 AND (n.LogicalReference LIKE '%TFXSW26100100007%' OR f.LogicalReference LIKE '%TFXSW26100100007%')
),
M AS (
    SELECT p.*, CASE WHEN UPPER(p.BuyCcy) = UPPER(CASE WHEN CHARINDEX('/', p.CcyPair) > 1 THEN LTRIM(RTRIM(LEFT(p.CcyPair, CHARINDEX('/', p.CcyPair) - 1)))
                                     WHEN LEN(p.CcyPair) >= 6 THEN LEFT(p.CcyPair, 3) ELSE p.BuyCcy END) THEN 1 ELSE 0 END AS BaseBought
    FROM P p WHERE p.Rn = 1
),
C AS (
    SELECT m.*, CASE WHEN BaseBought = 1 THEN 'B/S' ELSE 'S/B' END AS Direction,
           CAST(CASE WHEN BaseBought = 1 THEN SellAmount ELSE BuyAmount END AS float) AS NB,
           CASE WHEN BaseBought = 1 THEN SellCcy ELSE BuyCcy END AS NBCcy,
           CAST(0 AS float) AS Ounce, CAST(0 AS float) AS Gram,
           CASE WHEN NearRate = 0 THEN 0 ELSE (FarRate - NearRate) / NearRate * (360.0 / CASE WHEN DATEDIFF(day, NearDate, FarDate) = 0 THEN 1 ELSE DATEDIFF(day, NearDate, FarDate) END) * 100 END AS SR
    FROM M m
)
SELECT TOP (20) MAX(c.NearId) AS MaxNearId, cu.Name AS CounterpartyName, UPPER(c.CcyPair) AS CcyPair, c.Direction, c.NearDate, c.FarDate,
       DATEDIFF(day, c.NearDate, c.FarDate) AS Tenor,
       CASE WHEN c.FarDate < @LD THEN 0 ELSE DATEDIFF(day, @LD, c.FarDate) END AS DaysToMaturity,
       ROUND(SUM(c.NB), 2) AS TotalAmount, MAX(c.NBCcy) AS TotalAmountCcy,
       CASE WHEN SUM(c.NB) <> 0 THEN SUM(c.NB * c.SR) / SUM(c.NB) ELSE AVG(c.SR) END AS SwapRate,
       MAX(c.SellCcy) AS SoldCcy, ROUND(SUM(c.SellAmount), 2) AS SoldAmount, MAX(c.BuyCcy) AS BoughtCcy, ROUND(SUM(c.BuyAmount), 2) AS BoughtAmount,
       ROUND(SUM(c.Ounce), 2) AS Ounce, ROUND(SUM(c.Gram), 2) AS Gram,
       COUNT(*) AS TxnCount, STRING_AGG(c.NearRef, ', ') AS Refs,
       MAX(c.JoinCnt) AS JoinCnt, (SELECT COUNT(*) FROM M) AS PkgCnt
FROM C c
LEFT JOIN CusCustomer cu ON cu.Id = c.CustomerId
GROUP BY c.CustomerId, cu.Name, UPPER(c.CcyPair), c.Direction, c.NearDate, c.FarDate
ORDER BY MaxNearId DESC;
```

DB: `NetTrexFX` · Server: `tcp:192.168.10.211,1433` · User: `trusr` · Pass: `***`


## #109

**Amaç:** Test FX Swap: FX + PM birlikte seçili (FX satırları) — valör 2026-10-01–2026-10-31. API (ekran) gruplanmış satırları ile karşılaştırma (aynı join/gruplama/oran formülü).

```sql
SET NOCOUNT ON;
DECLARE @LD date = '2026-10-02';
WITH N AS (SELECT * FROM TxnFXSwap WHERE InstrumentId = 1068 AND (StateId & 6) = 2 AND ValueDate >= '2026-10-01' AND ValueDate < DATEADD(day, 1, CAST('2026-10-31' AS date))),
F AS (SELECT * FROM TxnFXSwap WHERE InstrumentId = 1069 AND (StateId & 6) = 2),
P AS (
    SELECT n.PkgNo, n.Id AS NearId, f.Id AS FarId, n.CustomerId, LTRIM(RTRIM(n.CcyPair)) AS CcyPair, n.LogicalReference AS NearRef,
           n.BuyCcy, n.BuyAmount, n.SellCcy, n.SellAmount, 
           CAST(n.DealRateNet AS float) AS NearRate, CAST(f.DealRateNet AS float) AS FarRate,
           CAST(n.ValueDate AS date) AS NearDate, CAST(f.ValueDate AS date) AS FarDate,
           COUNT(*) OVER () AS JoinCnt,
           ROW_NUMBER() OVER (PARTITION BY n.PkgNo ORDER BY n.Id DESC, f.Id DESC) AS Rn
    FROM N n JOIN F f ON f.PkgNo = n.PkgNo
    WHERE n.PkgNo <> 0
),
M AS (
    SELECT p.*, CASE WHEN UPPER(p.BuyCcy) = UPPER(CASE WHEN CHARINDEX('/', p.CcyPair) > 1 THEN LTRIM(RTRIM(LEFT(p.CcyPair, CHARINDEX('/', p.CcyPair) - 1)))
                                     WHEN LEN(p.CcyPair) >= 6 THEN LEFT(p.CcyPair, 3) ELSE p.BuyCcy END) THEN 1 ELSE 0 END AS BaseBought
    FROM P p WHERE p.Rn = 1
),
C AS (
    SELECT m.*, CASE WHEN BaseBought = 1 THEN 'B/S' ELSE 'S/B' END AS Direction,
           CAST(CASE WHEN BaseBought = 1 THEN SellAmount ELSE BuyAmount END AS float) AS NB,
           CASE WHEN BaseBought = 1 THEN SellCcy ELSE BuyCcy END AS NBCcy,
           CAST(0 AS float) AS Ounce, CAST(0 AS float) AS Gram,
           CASE WHEN NearRate = 0 THEN 0 ELSE (FarRate - NearRate) / NearRate * (360.0 / CASE WHEN DATEDIFF(day, NearDate, FarDate) = 0 THEN 1 ELSE DATEDIFF(day, NearDate, FarDate) END) * 100 END AS SR
    FROM M m
)
SELECT TOP (20) MAX(c.NearId) AS MaxNearId, cu.Name AS CounterpartyName, UPPER(c.CcyPair) AS CcyPair, c.Direction, c.NearDate, c.FarDate,
       DATEDIFF(day, c.NearDate, c.FarDate) AS Tenor,
       CASE WHEN c.FarDate < @LD THEN 0 ELSE DATEDIFF(day, @LD, c.FarDate) END AS DaysToMaturity,
       ROUND(SUM(c.NB), 2) AS TotalAmount, MAX(c.NBCcy) AS TotalAmountCcy,
       CASE WHEN SUM(c.NB) <> 0 THEN SUM(c.NB * c.SR) / SUM(c.NB) ELSE AVG(c.SR) END AS SwapRate,
       MAX(c.SellCcy) AS SoldCcy, ROUND(SUM(c.SellAmount), 2) AS SoldAmount, MAX(c.BuyCcy) AS BoughtCcy, ROUND(SUM(c.BuyAmount), 2) AS BoughtAmount,
       ROUND(SUM(c.Ounce), 2) AS Ounce, ROUND(SUM(c.Gram), 2) AS Gram,
       COUNT(*) AS TxnCount, STRING_AGG(c.NearRef, ', ') AS Refs,
       MAX(c.JoinCnt) AS JoinCnt, (SELECT COUNT(*) FROM M) AS PkgCnt
FROM C c
LEFT JOIN CusCustomer cu ON cu.Id = c.CustomerId
GROUP BY c.CustomerId, cu.Name, UPPER(c.CcyPair), c.Direction, c.NearDate, c.FarDate
ORDER BY MaxNearId DESC;
```

DB: `NetTrexFX` · Server: `tcp:192.168.10.211,1433` · User: `trusr` · Pass: `***`


## #110

**Amaç:** Test FX Swap: Ekran varsayılanı (bu ay) — valör 2026-10-01–2026-10-31. API (ekran) gruplanmış satırları ile karşılaştırma (aynı join/gruplama/oran formülü).

```sql
SET NOCOUNT ON;
DECLARE @LD date = '2026-10-02';
WITH N AS (SELECT * FROM TxnFXSwap WHERE InstrumentId = 1068 AND (StateId & 6) = 2 AND ValueDate >= '2026-10-01' AND ValueDate < DATEADD(day, 1, CAST('2026-10-31' AS date))),
F AS (SELECT * FROM TxnFXSwap WHERE InstrumentId = 1069 AND (StateId & 6) = 2),
P AS (
    SELECT n.PkgNo, n.Id AS NearId, f.Id AS FarId, n.CustomerId, LTRIM(RTRIM(n.CcyPair)) AS CcyPair, n.LogicalReference AS NearRef,
           n.BuyCcy, n.BuyAmount, n.SellCcy, n.SellAmount, 
           CAST(n.DealRateNet AS float) AS NearRate, CAST(f.DealRateNet AS float) AS FarRate,
           CAST(n.ValueDate AS date) AS NearDate, CAST(f.ValueDate AS date) AS FarDate,
           COUNT(*) OVER () AS JoinCnt,
           ROW_NUMBER() OVER (PARTITION BY n.PkgNo ORDER BY n.Id DESC, f.Id DESC) AS Rn
    FROM N n JOIN F f ON f.PkgNo = n.PkgNo
    WHERE n.PkgNo <> 0
),
M AS (
    SELECT p.*, CASE WHEN UPPER(p.BuyCcy) = UPPER(CASE WHEN CHARINDEX('/', p.CcyPair) > 1 THEN LTRIM(RTRIM(LEFT(p.CcyPair, CHARINDEX('/', p.CcyPair) - 1)))
                                     WHEN LEN(p.CcyPair) >= 6 THEN LEFT(p.CcyPair, 3) ELSE p.BuyCcy END) THEN 1 ELSE 0 END AS BaseBought
    FROM P p WHERE p.Rn = 1
),
C AS (
    SELECT m.*, CASE WHEN BaseBought = 1 THEN 'B/S' ELSE 'S/B' END AS Direction,
           CAST(CASE WHEN BaseBought = 1 THEN SellAmount ELSE BuyAmount END AS float) AS NB,
           CASE WHEN BaseBought = 1 THEN SellCcy ELSE BuyCcy END AS NBCcy,
           CAST(0 AS float) AS Ounce, CAST(0 AS float) AS Gram,
           CASE WHEN NearRate = 0 THEN 0 ELSE (FarRate - NearRate) / NearRate * (360.0 / CASE WHEN DATEDIFF(day, NearDate, FarDate) = 0 THEN 1 ELSE DATEDIFF(day, NearDate, FarDate) END) * 100 END AS SR
    FROM M m
)
SELECT TOP (20) MAX(c.NearId) AS MaxNearId, cu.Name AS CounterpartyName, UPPER(c.CcyPair) AS CcyPair, c.Direction, c.NearDate, c.FarDate,
       DATEDIFF(day, c.NearDate, c.FarDate) AS Tenor,
       CASE WHEN c.FarDate < @LD THEN 0 ELSE DATEDIFF(day, @LD, c.FarDate) END AS DaysToMaturity,
       ROUND(SUM(c.NB), 2) AS TotalAmount, MAX(c.NBCcy) AS TotalAmountCcy,
       CASE WHEN SUM(c.NB) <> 0 THEN SUM(c.NB * c.SR) / SUM(c.NB) ELSE AVG(c.SR) END AS SwapRate,
       MAX(c.SellCcy) AS SoldCcy, ROUND(SUM(c.SellAmount), 2) AS SoldAmount, MAX(c.BuyCcy) AS BoughtCcy, ROUND(SUM(c.BuyAmount), 2) AS BoughtAmount,
       ROUND(SUM(c.Ounce), 2) AS Ounce, ROUND(SUM(c.Gram), 2) AS Gram,
       COUNT(*) AS TxnCount, STRING_AGG(c.NearRef, ', ') AS Refs,
       MAX(c.JoinCnt) AS JoinCnt, (SELECT COUNT(*) FROM M) AS PkgCnt
FROM C c
LEFT JOIN CusCustomer cu ON cu.Id = c.CustomerId
GROUP BY c.CustomerId, cu.Name, UPPER(c.CcyPair), c.Direction, c.NearDate, c.FarDate
ORDER BY MaxNearId DESC;
```

DB: `NetTrexFX` · Server: `tcp:192.168.10.211,1433` · User: `trusr` · Pass: `***`


## #111

**Amaç:** Test FX Swap: Ekran varsayılanı (bu ay) — valör 2026-10-01–2026-10-31. API (ekran) gruplanmış satırları ile karşılaştırma (aynı join/gruplama/oran formülü).

```sql
SET NOCOUNT ON;
DECLARE @LD date = '2026-10-02';
WITH N AS (SELECT * FROM TxnFXSwap WHERE InstrumentId = 1068 AND (StateId & 6) = 2 AND ValueDate >= '2026-10-01' AND ValueDate < DATEADD(day, 1, CAST('2026-10-31' AS date))),
F AS (SELECT * FROM TxnFXSwap WHERE InstrumentId = 1069 AND (StateId & 6) = 2),
P AS (
    SELECT n.PkgNo, n.Id AS NearId, f.Id AS FarId, n.CustomerId, LTRIM(RTRIM(n.CcyPair)) AS CcyPair, n.LogicalReference AS NearRef,
           n.BuyCcy, n.BuyAmount, n.SellCcy, n.SellAmount, 
           CAST(n.DealRateNet AS float) AS NearRate, CAST(f.DealRateNet AS float) AS FarRate,
           CAST(n.ValueDate AS date) AS NearDate, CAST(f.ValueDate AS date) AS FarDate,
           COUNT(*) OVER () AS JoinCnt,
           ROW_NUMBER() OVER (PARTITION BY n.PkgNo ORDER BY n.Id DESC, f.Id DESC) AS Rn
    FROM N n JOIN F f ON f.PkgNo = n.PkgNo
    WHERE n.PkgNo <> 0
),
M AS (
    SELECT p.*, CASE WHEN UPPER(p.BuyCcy) = UPPER(CASE WHEN CHARINDEX('/', p.CcyPair) > 1 THEN LTRIM(RTRIM(LEFT(p.CcyPair, CHARINDEX('/', p.CcyPair) - 1)))
                                     WHEN LEN(p.CcyPair) >= 6 THEN LEFT(p.CcyPair, 3) ELSE p.BuyCcy END) THEN 1 ELSE 0 END AS BaseBought
    FROM P p WHERE p.Rn = 1
),
C AS (
    SELECT m.*, CASE WHEN BaseBought = 1 THEN 'B/S' ELSE 'S/B' END AS Direction,
           CAST(CASE WHEN BaseBought = 1 THEN SellAmount ELSE BuyAmount END AS float) AS NB,
           CASE WHEN BaseBought = 1 THEN SellCcy ELSE BuyCcy END AS NBCcy,
           CAST(0 AS float) AS Ounce, CAST(0 AS float) AS Gram,
           CASE WHEN NearRate = 0 THEN 0 ELSE (FarRate - NearRate) / NearRate * (360.0 / CASE WHEN DATEDIFF(day, NearDate, FarDate) = 0 THEN 1 ELSE DATEDIFF(day, NearDate, FarDate) END) * 100 END AS SR
    FROM M m
)
SELECT TOP (20) MAX(c.NearId) AS MaxNearId, CAST(cu.Name AS nvarchar(200)) AS CounterpartyName, UPPER(c.CcyPair) AS CcyPair, c.Direction, c.NearDate, c.FarDate,
       DATEDIFF(day, c.NearDate, c.FarDate) AS Tenor,
       CASE WHEN c.FarDate < @LD THEN 0 ELSE DATEDIFF(day, @LD, c.FarDate) END AS DaysToMaturity,
       ROUND(SUM(c.NB), 2) AS TotalAmount, MAX(c.NBCcy) AS TotalAmountCcy,
       CASE WHEN SUM(c.NB) <> 0 THEN SUM(c.NB * c.SR) / SUM(c.NB) ELSE AVG(c.SR) END AS SwapRate,
       MAX(c.SellCcy) AS SoldCcy, ROUND(SUM(c.SellAmount), 2) AS SoldAmount, MAX(c.BuyCcy) AS BoughtCcy, ROUND(SUM(c.BuyAmount), 2) AS BoughtAmount,
       ROUND(SUM(c.Ounce), 2) AS Ounce, ROUND(SUM(c.Gram), 2) AS Gram,
       COUNT(*) AS TxnCount, STRING_AGG(c.NearRef, ', ') AS Refs,
       MAX(c.JoinCnt) AS JoinCnt, (SELECT COUNT(*) FROM M) AS PkgCnt
FROM C c
LEFT JOIN CusCustomer cu ON cu.Id = c.CustomerId
GROUP BY c.CustomerId, cu.Name, UPPER(c.CcyPair), c.Direction, c.NearDate, c.FarDate
ORDER BY MaxNearId DESC;
```

DB: `NetTrexFX` · Server: `tcp:192.168.10.211,1433` · User: `trusr` · Pass: `***`


## #112

**Amaç:** FX #90/#111'de karşı kurum adı DB çıktısında 'Akbank A.S.' göründü, #91'de 'Akbank A.Ş.'. DB'de karakter gerçekte Ş (350) mı saklı yoksa S (83) mı — fark veride mi sqlcmd dönüşümünde mi?

```sql
SET NOCOUNT ON;
SELECT TOP (20) Id, Name, LEN(Name) AS Len, UNICODE(SUBSTRING(Name, 10, 1)) AS Char10Code, SQL_VARIANT_PROPERTY(Name, 'BaseType') AS BaseType
FROM CusCustomer
WHERE Id = 2095
ORDER BY Id DESC;
```

DB: `NetTrexFX` · Server: `tcp:192.168.10.211,1433` · User: `trusr` · Pass: `***`


## #113

**Amaç:** Test PM Swap: Ekran varsayılanı (bu ay) — valör 2026-10-01–2026-10-31. API (ekran) gruplanmış satırları ile karşılaştırma (aynı join/gruplama/oran formülü).

```sql
SET NOCOUNT ON;
DECLARE @LD date = '2026-10-02';
WITH N AS (SELECT * FROM TxnPMSwap WHERE InstrumentId = 1068 AND (StateId & 6) = 2 AND ValueDate >= '2026-10-01' AND ValueDate < DATEADD(day, 1, CAST('2026-10-31' AS date))),
F AS (SELECT * FROM TxnPMSwap WHERE InstrumentId = 1069 AND (StateId & 6) = 2),
P AS (
    SELECT n.PkgNo, n.Id AS NearId, f.Id AS FarId, n.CustomerId, LTRIM(RTRIM(n.CcyPair)) AS CcyPair, n.LogicalReference AS NearRef,
           n.BuyCcy, n.BuyAmount, n.SellCcy, n.SellAmount, n.BuyAmountOunce, n.SellAmountOunce, n.BuyAmountGram, n.SellAmountGram,
           CAST(n.DealRateNet AS float) AS NearRate, CAST(f.DealRateNet AS float) AS FarRate,
           CAST(n.ValueDate AS date) AS NearDate, CAST(f.ValueDate AS date) AS FarDate,
           COUNT(*) OVER () AS JoinCnt,
           ROW_NUMBER() OVER (PARTITION BY n.PkgNo ORDER BY n.Id DESC, f.Id DESC) AS Rn
    FROM N n JOIN F f ON f.PkgNo = n.PkgNo
    WHERE n.PkgNo <> 0
),
M AS (
    SELECT p.*, CASE WHEN UPPER(p.BuyCcy) = UPPER(CASE WHEN CHARINDEX('/', p.CcyPair) > 1 THEN LTRIM(RTRIM(LEFT(p.CcyPair, CHARINDEX('/', p.CcyPair) - 1)))
                                     WHEN LEN(p.CcyPair) >= 6 THEN LEFT(p.CcyPair, 3) ELSE p.BuyCcy END) THEN 1 ELSE 0 END AS BaseBought
    FROM P p WHERE p.Rn = 1
),
C AS (
    SELECT m.*, CASE WHEN BaseBought = 1 THEN 'B/S' ELSE 'S/B' END AS Direction,
           CAST(CASE WHEN BaseBought = 1 THEN SellAmount ELSE BuyAmount END AS float) AS NB,
           CASE WHEN BaseBought = 1 THEN SellCcy ELSE BuyCcy END AS NBCcy,
           CAST(ISNULL(CASE WHEN BaseBought = 1 THEN BuyAmountOunce ELSE SellAmountOunce END, 0) AS float) AS Ounce, CAST(ISNULL(CASE WHEN BaseBought = 1 THEN BuyAmountGram ELSE SellAmountGram END, 0) AS float) AS Gram,
           CASE WHEN NearRate = 0 THEN 0 ELSE (FarRate - NearRate) / NearRate * (360.0 / CASE WHEN DATEDIFF(day, NearDate, FarDate) = 0 THEN 1 ELSE DATEDIFF(day, NearDate, FarDate) END) * 100 END AS SR
    FROM M m
)
SELECT TOP (20) MAX(c.NearId) AS MaxNearId, CAST(cu.Name AS nvarchar(200)) AS CounterpartyName, UPPER(c.CcyPair) AS CcyPair, c.Direction, c.NearDate, c.FarDate,
       DATEDIFF(day, c.NearDate, c.FarDate) AS Tenor,
       CASE WHEN c.FarDate < @LD THEN 0 ELSE DATEDIFF(day, @LD, c.FarDate) END AS DaysToMaturity,
       ROUND(SUM(c.NB), 2) AS TotalAmount, MAX(c.NBCcy) AS TotalAmountCcy,
       CASE WHEN SUM(c.NB) <> 0 THEN SUM(c.NB * c.SR) / SUM(c.NB) ELSE AVG(c.SR) END AS SwapRate,
       MAX(c.SellCcy) AS SoldCcy, ROUND(SUM(c.SellAmount), 2) AS SoldAmount, MAX(c.BuyCcy) AS BoughtCcy, ROUND(SUM(c.BuyAmount), 2) AS BoughtAmount,
       ROUND(SUM(c.Ounce), 2) AS Ounce, ROUND(SUM(c.Gram), 2) AS Gram,
       COUNT(*) AS TxnCount, STRING_AGG(c.NearRef, ', ') AS Refs,
       MAX(c.JoinCnt) AS JoinCnt, (SELECT COUNT(*) FROM M) AS PkgCnt
FROM C c
LEFT JOIN CusCustomer cu ON cu.Id = c.CustomerId
GROUP BY c.CustomerId, cu.Name, UPPER(c.CcyPair), c.Direction, c.NearDate, c.FarDate
ORDER BY MaxNearId DESC;
```

DB: `NetTrexFX` · Server: `tcp:192.168.10.211,1433` · User: `trusr` · Pass: `***`


## #114

**Amaç:** Test PM Swap: Yalnız valör başlangıç — valör 2026-10-01–…. API (ekran) gruplanmış satırları ile karşılaştırma (aynı join/gruplama/oran formülü).

```sql
SET NOCOUNT ON;
DECLARE @LD date = '2026-10-02';
WITH N AS (SELECT * FROM TxnPMSwap WHERE InstrumentId = 1068 AND (StateId & 6) = 2 AND ValueDate >= '2026-10-01'),
F AS (SELECT * FROM TxnPMSwap WHERE InstrumentId = 1069 AND (StateId & 6) = 2),
P AS (
    SELECT n.PkgNo, n.Id AS NearId, f.Id AS FarId, n.CustomerId, LTRIM(RTRIM(n.CcyPair)) AS CcyPair, n.LogicalReference AS NearRef,
           n.BuyCcy, n.BuyAmount, n.SellCcy, n.SellAmount, n.BuyAmountOunce, n.SellAmountOunce, n.BuyAmountGram, n.SellAmountGram,
           CAST(n.DealRateNet AS float) AS NearRate, CAST(f.DealRateNet AS float) AS FarRate,
           CAST(n.ValueDate AS date) AS NearDate, CAST(f.ValueDate AS date) AS FarDate,
           COUNT(*) OVER () AS JoinCnt,
           ROW_NUMBER() OVER (PARTITION BY n.PkgNo ORDER BY n.Id DESC, f.Id DESC) AS Rn
    FROM N n JOIN F f ON f.PkgNo = n.PkgNo
    WHERE n.PkgNo <> 0
),
M AS (
    SELECT p.*, CASE WHEN UPPER(p.BuyCcy) = UPPER(CASE WHEN CHARINDEX('/', p.CcyPair) > 1 THEN LTRIM(RTRIM(LEFT(p.CcyPair, CHARINDEX('/', p.CcyPair) - 1)))
                                     WHEN LEN(p.CcyPair) >= 6 THEN LEFT(p.CcyPair, 3) ELSE p.BuyCcy END) THEN 1 ELSE 0 END AS BaseBought
    FROM P p WHERE p.Rn = 1
),
C AS (
    SELECT m.*, CASE WHEN BaseBought = 1 THEN 'B/S' ELSE 'S/B' END AS Direction,
           CAST(CASE WHEN BaseBought = 1 THEN SellAmount ELSE BuyAmount END AS float) AS NB,
           CASE WHEN BaseBought = 1 THEN SellCcy ELSE BuyCcy END AS NBCcy,
           CAST(ISNULL(CASE WHEN BaseBought = 1 THEN BuyAmountOunce ELSE SellAmountOunce END, 0) AS float) AS Ounce, CAST(ISNULL(CASE WHEN BaseBought = 1 THEN BuyAmountGram ELSE SellAmountGram END, 0) AS float) AS Gram,
           CASE WHEN NearRate = 0 THEN 0 ELSE (FarRate - NearRate) / NearRate * (360.0 / CASE WHEN DATEDIFF(day, NearDate, FarDate) = 0 THEN 1 ELSE DATEDIFF(day, NearDate, FarDate) END) * 100 END AS SR
    FROM M m
)
SELECT TOP (20) MAX(c.NearId) AS MaxNearId, CAST(cu.Name AS nvarchar(200)) AS CounterpartyName, UPPER(c.CcyPair) AS CcyPair, c.Direction, c.NearDate, c.FarDate,
       DATEDIFF(day, c.NearDate, c.FarDate) AS Tenor,
       CASE WHEN c.FarDate < @LD THEN 0 ELSE DATEDIFF(day, @LD, c.FarDate) END AS DaysToMaturity,
       ROUND(SUM(c.NB), 2) AS TotalAmount, MAX(c.NBCcy) AS TotalAmountCcy,
       CASE WHEN SUM(c.NB) <> 0 THEN SUM(c.NB * c.SR) / SUM(c.NB) ELSE AVG(c.SR) END AS SwapRate,
       MAX(c.SellCcy) AS SoldCcy, ROUND(SUM(c.SellAmount), 2) AS SoldAmount, MAX(c.BuyCcy) AS BoughtCcy, ROUND(SUM(c.BuyAmount), 2) AS BoughtAmount,
       ROUND(SUM(c.Ounce), 2) AS Ounce, ROUND(SUM(c.Gram), 2) AS Gram,
       COUNT(*) AS TxnCount, STRING_AGG(c.NearRef, ', ') AS Refs,
       MAX(c.JoinCnt) AS JoinCnt, (SELECT COUNT(*) FROM M) AS PkgCnt
FROM C c
LEFT JOIN CusCustomer cu ON cu.Id = c.CustomerId
GROUP BY c.CustomerId, cu.Name, UPPER(c.CcyPair), c.Direction, c.NearDate, c.FarDate
ORDER BY MaxNearId DESC;
```

DB: `NetTrexFX` · Server: `tcp:192.168.10.211,1433` · User: `trusr` · Pass: `***`


## #115

**Amaç:** Test PM Swap: Yalnız valör bitiş (öncesi) — valör …–2026-09-30. API (ekran) gruplanmış satırları ile karşılaştırma (aynı join/gruplama/oran formülü).

```sql
SET NOCOUNT ON;
DECLARE @LD date = '2026-10-02';
WITH N AS (SELECT * FROM TxnPMSwap WHERE InstrumentId = 1068 AND (StateId & 6) = 2 AND ValueDate < DATEADD(day, 1, CAST('2026-09-30' AS date))),
F AS (SELECT * FROM TxnPMSwap WHERE InstrumentId = 1069 AND (StateId & 6) = 2),
P AS (
    SELECT n.PkgNo, n.Id AS NearId, f.Id AS FarId, n.CustomerId, LTRIM(RTRIM(n.CcyPair)) AS CcyPair, n.LogicalReference AS NearRef,
           n.BuyCcy, n.BuyAmount, n.SellCcy, n.SellAmount, n.BuyAmountOunce, n.SellAmountOunce, n.BuyAmountGram, n.SellAmountGram,
           CAST(n.DealRateNet AS float) AS NearRate, CAST(f.DealRateNet AS float) AS FarRate,
           CAST(n.ValueDate AS date) AS NearDate, CAST(f.ValueDate AS date) AS FarDate,
           COUNT(*) OVER () AS JoinCnt,
           ROW_NUMBER() OVER (PARTITION BY n.PkgNo ORDER BY n.Id DESC, f.Id DESC) AS Rn
    FROM N n JOIN F f ON f.PkgNo = n.PkgNo
    WHERE n.PkgNo <> 0
),
M AS (
    SELECT p.*, CASE WHEN UPPER(p.BuyCcy) = UPPER(CASE WHEN CHARINDEX('/', p.CcyPair) > 1 THEN LTRIM(RTRIM(LEFT(p.CcyPair, CHARINDEX('/', p.CcyPair) - 1)))
                                     WHEN LEN(p.CcyPair) >= 6 THEN LEFT(p.CcyPair, 3) ELSE p.BuyCcy END) THEN 1 ELSE 0 END AS BaseBought
    FROM P p WHERE p.Rn = 1
),
C AS (
    SELECT m.*, CASE WHEN BaseBought = 1 THEN 'B/S' ELSE 'S/B' END AS Direction,
           CAST(CASE WHEN BaseBought = 1 THEN SellAmount ELSE BuyAmount END AS float) AS NB,
           CASE WHEN BaseBought = 1 THEN SellCcy ELSE BuyCcy END AS NBCcy,
           CAST(ISNULL(CASE WHEN BaseBought = 1 THEN BuyAmountOunce ELSE SellAmountOunce END, 0) AS float) AS Ounce, CAST(ISNULL(CASE WHEN BaseBought = 1 THEN BuyAmountGram ELSE SellAmountGram END, 0) AS float) AS Gram,
           CASE WHEN NearRate = 0 THEN 0 ELSE (FarRate - NearRate) / NearRate * (360.0 / CASE WHEN DATEDIFF(day, NearDate, FarDate) = 0 THEN 1 ELSE DATEDIFF(day, NearDate, FarDate) END) * 100 END AS SR
    FROM M m
)
SELECT TOP (20) MAX(c.NearId) AS MaxNearId, CAST(cu.Name AS nvarchar(200)) AS CounterpartyName, UPPER(c.CcyPair) AS CcyPair, c.Direction, c.NearDate, c.FarDate,
       DATEDIFF(day, c.NearDate, c.FarDate) AS Tenor,
       CASE WHEN c.FarDate < @LD THEN 0 ELSE DATEDIFF(day, @LD, c.FarDate) END AS DaysToMaturity,
       ROUND(SUM(c.NB), 2) AS TotalAmount, MAX(c.NBCcy) AS TotalAmountCcy,
       CASE WHEN SUM(c.NB) <> 0 THEN SUM(c.NB * c.SR) / SUM(c.NB) ELSE AVG(c.SR) END AS SwapRate,
       MAX(c.SellCcy) AS SoldCcy, ROUND(SUM(c.SellAmount), 2) AS SoldAmount, MAX(c.BuyCcy) AS BoughtCcy, ROUND(SUM(c.BuyAmount), 2) AS BoughtAmount,
       ROUND(SUM(c.Ounce), 2) AS Ounce, ROUND(SUM(c.Gram), 2) AS Gram,
       COUNT(*) AS TxnCount, STRING_AGG(c.NearRef, ', ') AS Refs,
       MAX(c.JoinCnt) AS JoinCnt, (SELECT COUNT(*) FROM M) AS PkgCnt
FROM C c
LEFT JOIN CusCustomer cu ON cu.Id = c.CustomerId
GROUP BY c.CustomerId, cu.Name, UPPER(c.CcyPair), c.Direction, c.NearDate, c.FarDate
ORDER BY MaxNearId DESC;
```

DB: `NetTrexFX` · Server: `tcp:192.168.10.211,1433` · User: `trusr` · Pass: `***`


## #116

**Amaç:** Test PM Swap: Tek gün valör 01.10 — valör 2026-10-01–2026-10-01. API (ekran) gruplanmış satırları ile karşılaştırma (aynı join/gruplama/oran formülü).

```sql
SET NOCOUNT ON;
DECLARE @LD date = '2026-10-02';
WITH N AS (SELECT * FROM TxnPMSwap WHERE InstrumentId = 1068 AND (StateId & 6) = 2 AND ValueDate >= '2026-10-01' AND ValueDate < DATEADD(day, 1, CAST('2026-10-01' AS date))),
F AS (SELECT * FROM TxnPMSwap WHERE InstrumentId = 1069 AND (StateId & 6) = 2),
P AS (
    SELECT n.PkgNo, n.Id AS NearId, f.Id AS FarId, n.CustomerId, LTRIM(RTRIM(n.CcyPair)) AS CcyPair, n.LogicalReference AS NearRef,
           n.BuyCcy, n.BuyAmount, n.SellCcy, n.SellAmount, n.BuyAmountOunce, n.SellAmountOunce, n.BuyAmountGram, n.SellAmountGram,
           CAST(n.DealRateNet AS float) AS NearRate, CAST(f.DealRateNet AS float) AS FarRate,
           CAST(n.ValueDate AS date) AS NearDate, CAST(f.ValueDate AS date) AS FarDate,
           COUNT(*) OVER () AS JoinCnt,
           ROW_NUMBER() OVER (PARTITION BY n.PkgNo ORDER BY n.Id DESC, f.Id DESC) AS Rn
    FROM N n JOIN F f ON f.PkgNo = n.PkgNo
    WHERE n.PkgNo <> 0
),
M AS (
    SELECT p.*, CASE WHEN UPPER(p.BuyCcy) = UPPER(CASE WHEN CHARINDEX('/', p.CcyPair) > 1 THEN LTRIM(RTRIM(LEFT(p.CcyPair, CHARINDEX('/', p.CcyPair) - 1)))
                                     WHEN LEN(p.CcyPair) >= 6 THEN LEFT(p.CcyPair, 3) ELSE p.BuyCcy END) THEN 1 ELSE 0 END AS BaseBought
    FROM P p WHERE p.Rn = 1
),
C AS (
    SELECT m.*, CASE WHEN BaseBought = 1 THEN 'B/S' ELSE 'S/B' END AS Direction,
           CAST(CASE WHEN BaseBought = 1 THEN SellAmount ELSE BuyAmount END AS float) AS NB,
           CASE WHEN BaseBought = 1 THEN SellCcy ELSE BuyCcy END AS NBCcy,
           CAST(ISNULL(CASE WHEN BaseBought = 1 THEN BuyAmountOunce ELSE SellAmountOunce END, 0) AS float) AS Ounce, CAST(ISNULL(CASE WHEN BaseBought = 1 THEN BuyAmountGram ELSE SellAmountGram END, 0) AS float) AS Gram,
           CASE WHEN NearRate = 0 THEN 0 ELSE (FarRate - NearRate) / NearRate * (360.0 / CASE WHEN DATEDIFF(day, NearDate, FarDate) = 0 THEN 1 ELSE DATEDIFF(day, NearDate, FarDate) END) * 100 END AS SR
    FROM M m
)
SELECT TOP (20) MAX(c.NearId) AS MaxNearId, CAST(cu.Name AS nvarchar(200)) AS CounterpartyName, UPPER(c.CcyPair) AS CcyPair, c.Direction, c.NearDate, c.FarDate,
       DATEDIFF(day, c.NearDate, c.FarDate) AS Tenor,
       CASE WHEN c.FarDate < @LD THEN 0 ELSE DATEDIFF(day, @LD, c.FarDate) END AS DaysToMaturity,
       ROUND(SUM(c.NB), 2) AS TotalAmount, MAX(c.NBCcy) AS TotalAmountCcy,
       CASE WHEN SUM(c.NB) <> 0 THEN SUM(c.NB * c.SR) / SUM(c.NB) ELSE AVG(c.SR) END AS SwapRate,
       MAX(c.SellCcy) AS SoldCcy, ROUND(SUM(c.SellAmount), 2) AS SoldAmount, MAX(c.BuyCcy) AS BoughtCcy, ROUND(SUM(c.BuyAmount), 2) AS BoughtAmount,
       ROUND(SUM(c.Ounce), 2) AS Ounce, ROUND(SUM(c.Gram), 2) AS Gram,
       COUNT(*) AS TxnCount, STRING_AGG(c.NearRef, ', ') AS Refs,
       MAX(c.JoinCnt) AS JoinCnt, (SELECT COUNT(*) FROM M) AS PkgCnt
FROM C c
LEFT JOIN CusCustomer cu ON cu.Id = c.CustomerId
GROUP BY c.CustomerId, cu.Name, UPPER(c.CcyPair), c.Direction, c.NearDate, c.FarDate
ORDER BY MaxNearId DESC;
```

DB: `NetTrexFX` · Server: `tcp:192.168.10.211,1433` · User: `trusr` · Pass: `***`


## #117

**Amaç:** Test PM Swap: Valör 02.10 sonrası — valör 2026-10-02–…. API (ekran) gruplanmış satırları ile karşılaştırma (aynı join/gruplama/oran formülü).

```sql
SET NOCOUNT ON;
DECLARE @LD date = '2026-10-02';
WITH N AS (SELECT * FROM TxnPMSwap WHERE InstrumentId = 1068 AND (StateId & 6) = 2 AND ValueDate >= '2026-10-02'),
F AS (SELECT * FROM TxnPMSwap WHERE InstrumentId = 1069 AND (StateId & 6) = 2),
P AS (
    SELECT n.PkgNo, n.Id AS NearId, f.Id AS FarId, n.CustomerId, LTRIM(RTRIM(n.CcyPair)) AS CcyPair, n.LogicalReference AS NearRef,
           n.BuyCcy, n.BuyAmount, n.SellCcy, n.SellAmount, n.BuyAmountOunce, n.SellAmountOunce, n.BuyAmountGram, n.SellAmountGram,
           CAST(n.DealRateNet AS float) AS NearRate, CAST(f.DealRateNet AS float) AS FarRate,
           CAST(n.ValueDate AS date) AS NearDate, CAST(f.ValueDate AS date) AS FarDate,
           COUNT(*) OVER () AS JoinCnt,
           ROW_NUMBER() OVER (PARTITION BY n.PkgNo ORDER BY n.Id DESC, f.Id DESC) AS Rn
    FROM N n JOIN F f ON f.PkgNo = n.PkgNo
    WHERE n.PkgNo <> 0
),
M AS (
    SELECT p.*, CASE WHEN UPPER(p.BuyCcy) = UPPER(CASE WHEN CHARINDEX('/', p.CcyPair) > 1 THEN LTRIM(RTRIM(LEFT(p.CcyPair, CHARINDEX('/', p.CcyPair) - 1)))
                                     WHEN LEN(p.CcyPair) >= 6 THEN LEFT(p.CcyPair, 3) ELSE p.BuyCcy END) THEN 1 ELSE 0 END AS BaseBought
    FROM P p WHERE p.Rn = 1
),
C AS (
    SELECT m.*, CASE WHEN BaseBought = 1 THEN 'B/S' ELSE 'S/B' END AS Direction,
           CAST(CASE WHEN BaseBought = 1 THEN SellAmount ELSE BuyAmount END AS float) AS NB,
           CASE WHEN BaseBought = 1 THEN SellCcy ELSE BuyCcy END AS NBCcy,
           CAST(ISNULL(CASE WHEN BaseBought = 1 THEN BuyAmountOunce ELSE SellAmountOunce END, 0) AS float) AS Ounce, CAST(ISNULL(CASE WHEN BaseBought = 1 THEN BuyAmountGram ELSE SellAmountGram END, 0) AS float) AS Gram,
           CASE WHEN NearRate = 0 THEN 0 ELSE (FarRate - NearRate) / NearRate * (360.0 / CASE WHEN DATEDIFF(day, NearDate, FarDate) = 0 THEN 1 ELSE DATEDIFF(day, NearDate, FarDate) END) * 100 END AS SR
    FROM M m
)
SELECT TOP (20) MAX(c.NearId) AS MaxNearId, CAST(cu.Name AS nvarchar(200)) AS CounterpartyName, UPPER(c.CcyPair) AS CcyPair, c.Direction, c.NearDate, c.FarDate,
       DATEDIFF(day, c.NearDate, c.FarDate) AS Tenor,
       CASE WHEN c.FarDate < @LD THEN 0 ELSE DATEDIFF(day, @LD, c.FarDate) END AS DaysToMaturity,
       ROUND(SUM(c.NB), 2) AS TotalAmount, MAX(c.NBCcy) AS TotalAmountCcy,
       CASE WHEN SUM(c.NB) <> 0 THEN SUM(c.NB * c.SR) / SUM(c.NB) ELSE AVG(c.SR) END AS SwapRate,
       MAX(c.SellCcy) AS SoldCcy, ROUND(SUM(c.SellAmount), 2) AS SoldAmount, MAX(c.BuyCcy) AS BoughtCcy, ROUND(SUM(c.BuyAmount), 2) AS BoughtAmount,
       ROUND(SUM(c.Ounce), 2) AS Ounce, ROUND(SUM(c.Gram), 2) AS Gram,
       COUNT(*) AS TxnCount, STRING_AGG(c.NearRef, ', ') AS Refs,
       MAX(c.JoinCnt) AS JoinCnt, (SELECT COUNT(*) FROM M) AS PkgCnt
FROM C c
LEFT JOIN CusCustomer cu ON cu.Id = c.CustomerId
GROUP BY c.CustomerId, cu.Name, UPPER(c.CcyPair), c.Direction, c.NearDate, c.FarDate
ORDER BY MaxNearId DESC;
```

DB: `NetTrexFX` · Server: `tcp:192.168.10.211,1433` · User: `trusr` · Pass: `***`


## #118

**Amaç:** Test PM Swap: Vade aralığı Ekim — vade 2026-10-01–2026-10-31. API (ekran) gruplanmış satırları ile karşılaştırma (aynı join/gruplama/oran formülü).

```sql
SET NOCOUNT ON;
DECLARE @LD date = '2026-10-02';
WITH N AS (SELECT * FROM TxnPMSwap WHERE InstrumentId = 1068 AND (StateId & 6) = 2),
F AS (SELECT * FROM TxnPMSwap WHERE InstrumentId = 1069 AND (StateId & 6) = 2 AND ValueDate >= '2026-10-01' AND ValueDate < DATEADD(day, 1, CAST('2026-10-31' AS date))),
P AS (
    SELECT n.PkgNo, n.Id AS NearId, f.Id AS FarId, n.CustomerId, LTRIM(RTRIM(n.CcyPair)) AS CcyPair, n.LogicalReference AS NearRef,
           n.BuyCcy, n.BuyAmount, n.SellCcy, n.SellAmount, n.BuyAmountOunce, n.SellAmountOunce, n.BuyAmountGram, n.SellAmountGram,
           CAST(n.DealRateNet AS float) AS NearRate, CAST(f.DealRateNet AS float) AS FarRate,
           CAST(n.ValueDate AS date) AS NearDate, CAST(f.ValueDate AS date) AS FarDate,
           COUNT(*) OVER () AS JoinCnt,
           ROW_NUMBER() OVER (PARTITION BY n.PkgNo ORDER BY n.Id DESC, f.Id DESC) AS Rn
    FROM N n JOIN F f ON f.PkgNo = n.PkgNo
    WHERE n.PkgNo <> 0
),
M AS (
    SELECT p.*, CASE WHEN UPPER(p.BuyCcy) = UPPER(CASE WHEN CHARINDEX('/', p.CcyPair) > 1 THEN LTRIM(RTRIM(LEFT(p.CcyPair, CHARINDEX('/', p.CcyPair) - 1)))
                                     WHEN LEN(p.CcyPair) >= 6 THEN LEFT(p.CcyPair, 3) ELSE p.BuyCcy END) THEN 1 ELSE 0 END AS BaseBought
    FROM P p WHERE p.Rn = 1
),
C AS (
    SELECT m.*, CASE WHEN BaseBought = 1 THEN 'B/S' ELSE 'S/B' END AS Direction,
           CAST(CASE WHEN BaseBought = 1 THEN SellAmount ELSE BuyAmount END AS float) AS NB,
           CASE WHEN BaseBought = 1 THEN SellCcy ELSE BuyCcy END AS NBCcy,
           CAST(ISNULL(CASE WHEN BaseBought = 1 THEN BuyAmountOunce ELSE SellAmountOunce END, 0) AS float) AS Ounce, CAST(ISNULL(CASE WHEN BaseBought = 1 THEN BuyAmountGram ELSE SellAmountGram END, 0) AS float) AS Gram,
           CASE WHEN NearRate = 0 THEN 0 ELSE (FarRate - NearRate) / NearRate * (360.0 / CASE WHEN DATEDIFF(day, NearDate, FarDate) = 0 THEN 1 ELSE DATEDIFF(day, NearDate, FarDate) END) * 100 END AS SR
    FROM M m
)
SELECT TOP (20) MAX(c.NearId) AS MaxNearId, CAST(cu.Name AS nvarchar(200)) AS CounterpartyName, UPPER(c.CcyPair) AS CcyPair, c.Direction, c.NearDate, c.FarDate,
       DATEDIFF(day, c.NearDate, c.FarDate) AS Tenor,
       CASE WHEN c.FarDate < @LD THEN 0 ELSE DATEDIFF(day, @LD, c.FarDate) END AS DaysToMaturity,
       ROUND(SUM(c.NB), 2) AS TotalAmount, MAX(c.NBCcy) AS TotalAmountCcy,
       CASE WHEN SUM(c.NB) <> 0 THEN SUM(c.NB * c.SR) / SUM(c.NB) ELSE AVG(c.SR) END AS SwapRate,
       MAX(c.SellCcy) AS SoldCcy, ROUND(SUM(c.SellAmount), 2) AS SoldAmount, MAX(c.BuyCcy) AS BoughtCcy, ROUND(SUM(c.BuyAmount), 2) AS BoughtAmount,
       ROUND(SUM(c.Ounce), 2) AS Ounce, ROUND(SUM(c.Gram), 2) AS Gram,
       COUNT(*) AS TxnCount, STRING_AGG(c.NearRef, ', ') AS Refs,
       MAX(c.JoinCnt) AS JoinCnt, (SELECT COUNT(*) FROM M) AS PkgCnt
FROM C c
LEFT JOIN CusCustomer cu ON cu.Id = c.CustomerId
GROUP BY c.CustomerId, cu.Name, UPPER(c.CcyPair), c.Direction, c.NearDate, c.FarDate
ORDER BY MaxNearId DESC;
```

DB: `NetTrexFX` · Server: `tcp:192.168.10.211,1433` · User: `trusr` · Pass: `***`


## #119

**Amaç:** Test PM Swap: Yalnız vade başlangıç 03.10 — vade 2026-10-03–…. API (ekran) gruplanmış satırları ile karşılaştırma (aynı join/gruplama/oran formülü).

```sql
SET NOCOUNT ON;
DECLARE @LD date = '2026-10-02';
WITH N AS (SELECT * FROM TxnPMSwap WHERE InstrumentId = 1068 AND (StateId & 6) = 2),
F AS (SELECT * FROM TxnPMSwap WHERE InstrumentId = 1069 AND (StateId & 6) = 2 AND ValueDate >= '2026-10-03'),
P AS (
    SELECT n.PkgNo, n.Id AS NearId, f.Id AS FarId, n.CustomerId, LTRIM(RTRIM(n.CcyPair)) AS CcyPair, n.LogicalReference AS NearRef,
           n.BuyCcy, n.BuyAmount, n.SellCcy, n.SellAmount, n.BuyAmountOunce, n.SellAmountOunce, n.BuyAmountGram, n.SellAmountGram,
           CAST(n.DealRateNet AS float) AS NearRate, CAST(f.DealRateNet AS float) AS FarRate,
           CAST(n.ValueDate AS date) AS NearDate, CAST(f.ValueDate AS date) AS FarDate,
           COUNT(*) OVER () AS JoinCnt,
           ROW_NUMBER() OVER (PARTITION BY n.PkgNo ORDER BY n.Id DESC, f.Id DESC) AS Rn
    FROM N n JOIN F f ON f.PkgNo = n.PkgNo
    WHERE n.PkgNo <> 0
),
M AS (
    SELECT p.*, CASE WHEN UPPER(p.BuyCcy) = UPPER(CASE WHEN CHARINDEX('/', p.CcyPair) > 1 THEN LTRIM(RTRIM(LEFT(p.CcyPair, CHARINDEX('/', p.CcyPair) - 1)))
                                     WHEN LEN(p.CcyPair) >= 6 THEN LEFT(p.CcyPair, 3) ELSE p.BuyCcy END) THEN 1 ELSE 0 END AS BaseBought
    FROM P p WHERE p.Rn = 1
),
C AS (
    SELECT m.*, CASE WHEN BaseBought = 1 THEN 'B/S' ELSE 'S/B' END AS Direction,
           CAST(CASE WHEN BaseBought = 1 THEN SellAmount ELSE BuyAmount END AS float) AS NB,
           CASE WHEN BaseBought = 1 THEN SellCcy ELSE BuyCcy END AS NBCcy,
           CAST(ISNULL(CASE WHEN BaseBought = 1 THEN BuyAmountOunce ELSE SellAmountOunce END, 0) AS float) AS Ounce, CAST(ISNULL(CASE WHEN BaseBought = 1 THEN BuyAmountGram ELSE SellAmountGram END, 0) AS float) AS Gram,
           CASE WHEN NearRate = 0 THEN 0 ELSE (FarRate - NearRate) / NearRate * (360.0 / CASE WHEN DATEDIFF(day, NearDate, FarDate) = 0 THEN 1 ELSE DATEDIFF(day, NearDate, FarDate) END) * 100 END AS SR
    FROM M m
)
SELECT TOP (20) MAX(c.NearId) AS MaxNearId, CAST(cu.Name AS nvarchar(200)) AS CounterpartyName, UPPER(c.CcyPair) AS CcyPair, c.Direction, c.NearDate, c.FarDate,
       DATEDIFF(day, c.NearDate, c.FarDate) AS Tenor,
       CASE WHEN c.FarDate < @LD THEN 0 ELSE DATEDIFF(day, @LD, c.FarDate) END AS DaysToMaturity,
       ROUND(SUM(c.NB), 2) AS TotalAmount, MAX(c.NBCcy) AS TotalAmountCcy,
       CASE WHEN SUM(c.NB) <> 0 THEN SUM(c.NB * c.SR) / SUM(c.NB) ELSE AVG(c.SR) END AS SwapRate,
       MAX(c.SellCcy) AS SoldCcy, ROUND(SUM(c.SellAmount), 2) AS SoldAmount, MAX(c.BuyCcy) AS BoughtCcy, ROUND(SUM(c.BuyAmount), 2) AS BoughtAmount,
       ROUND(SUM(c.Ounce), 2) AS Ounce, ROUND(SUM(c.Gram), 2) AS Gram,
       COUNT(*) AS TxnCount, STRING_AGG(c.NearRef, ', ') AS Refs,
       MAX(c.JoinCnt) AS JoinCnt, (SELECT COUNT(*) FROM M) AS PkgCnt
FROM C c
LEFT JOIN CusCustomer cu ON cu.Id = c.CustomerId
GROUP BY c.CustomerId, cu.Name, UPPER(c.CcyPair), c.Direction, c.NearDate, c.FarDate
ORDER BY MaxNearId DESC;
```

DB: `NetTrexFX` · Server: `tcp:192.168.10.211,1433` · User: `trusr` · Pass: `***`


## #120

**Amaç:** Test PM Swap: Yalnız vade bitiş 02.10 — vade …–2026-10-02. API (ekran) gruplanmış satırları ile karşılaştırma (aynı join/gruplama/oran formülü).

```sql
SET NOCOUNT ON;
DECLARE @LD date = '2026-10-02';
WITH N AS (SELECT * FROM TxnPMSwap WHERE InstrumentId = 1068 AND (StateId & 6) = 2),
F AS (SELECT * FROM TxnPMSwap WHERE InstrumentId = 1069 AND (StateId & 6) = 2 AND ValueDate < DATEADD(day, 1, CAST('2026-10-02' AS date))),
P AS (
    SELECT n.PkgNo, n.Id AS NearId, f.Id AS FarId, n.CustomerId, LTRIM(RTRIM(n.CcyPair)) AS CcyPair, n.LogicalReference AS NearRef,
           n.BuyCcy, n.BuyAmount, n.SellCcy, n.SellAmount, n.BuyAmountOunce, n.SellAmountOunce, n.BuyAmountGram, n.SellAmountGram,
           CAST(n.DealRateNet AS float) AS NearRate, CAST(f.DealRateNet AS float) AS FarRate,
           CAST(n.ValueDate AS date) AS NearDate, CAST(f.ValueDate AS date) AS FarDate,
           COUNT(*) OVER () AS JoinCnt,
           ROW_NUMBER() OVER (PARTITION BY n.PkgNo ORDER BY n.Id DESC, f.Id DESC) AS Rn
    FROM N n JOIN F f ON f.PkgNo = n.PkgNo
    WHERE n.PkgNo <> 0
),
M AS (
    SELECT p.*, CASE WHEN UPPER(p.BuyCcy) = UPPER(CASE WHEN CHARINDEX('/', p.CcyPair) > 1 THEN LTRIM(RTRIM(LEFT(p.CcyPair, CHARINDEX('/', p.CcyPair) - 1)))
                                     WHEN LEN(p.CcyPair) >= 6 THEN LEFT(p.CcyPair, 3) ELSE p.BuyCcy END) THEN 1 ELSE 0 END AS BaseBought
    FROM P p WHERE p.Rn = 1
),
C AS (
    SELECT m.*, CASE WHEN BaseBought = 1 THEN 'B/S' ELSE 'S/B' END AS Direction,
           CAST(CASE WHEN BaseBought = 1 THEN SellAmount ELSE BuyAmount END AS float) AS NB,
           CASE WHEN BaseBought = 1 THEN SellCcy ELSE BuyCcy END AS NBCcy,
           CAST(ISNULL(CASE WHEN BaseBought = 1 THEN BuyAmountOunce ELSE SellAmountOunce END, 0) AS float) AS Ounce, CAST(ISNULL(CASE WHEN BaseBought = 1 THEN BuyAmountGram ELSE SellAmountGram END, 0) AS float) AS Gram,
           CASE WHEN NearRate = 0 THEN 0 ELSE (FarRate - NearRate) / NearRate * (360.0 / CASE WHEN DATEDIFF(day, NearDate, FarDate) = 0 THEN 1 ELSE DATEDIFF(day, NearDate, FarDate) END) * 100 END AS SR
    FROM M m
)
SELECT TOP (20) MAX(c.NearId) AS MaxNearId, CAST(cu.Name AS nvarchar(200)) AS CounterpartyName, UPPER(c.CcyPair) AS CcyPair, c.Direction, c.NearDate, c.FarDate,
       DATEDIFF(day, c.NearDate, c.FarDate) AS Tenor,
       CASE WHEN c.FarDate < @LD THEN 0 ELSE DATEDIFF(day, @LD, c.FarDate) END AS DaysToMaturity,
       ROUND(SUM(c.NB), 2) AS TotalAmount, MAX(c.NBCcy) AS TotalAmountCcy,
       CASE WHEN SUM(c.NB) <> 0 THEN SUM(c.NB * c.SR) / SUM(c.NB) ELSE AVG(c.SR) END AS SwapRate,
       MAX(c.SellCcy) AS SoldCcy, ROUND(SUM(c.SellAmount), 2) AS SoldAmount, MAX(c.BuyCcy) AS BoughtCcy, ROUND(SUM(c.BuyAmount), 2) AS BoughtAmount,
       ROUND(SUM(c.Ounce), 2) AS Ounce, ROUND(SUM(c.Gram), 2) AS Gram,
       COUNT(*) AS TxnCount, STRING_AGG(c.NearRef, ', ') AS Refs,
       MAX(c.JoinCnt) AS JoinCnt, (SELECT COUNT(*) FROM M) AS PkgCnt
FROM C c
LEFT JOIN CusCustomer cu ON cu.Id = c.CustomerId
GROUP BY c.CustomerId, cu.Name, UPPER(c.CcyPair), c.Direction, c.NearDate, c.FarDate
ORDER BY MaxNearId DESC;
```

DB: `NetTrexFX` · Server: `tcp:192.168.10.211,1433` · User: `trusr` · Pass: `***`


## #121

**Amaç:** Test PM Swap: Tek gün vade 02.10 — vade 2026-10-02–2026-10-02. API (ekran) gruplanmış satırları ile karşılaştırma (aynı join/gruplama/oran formülü).

```sql
SET NOCOUNT ON;
DECLARE @LD date = '2026-10-02';
WITH N AS (SELECT * FROM TxnPMSwap WHERE InstrumentId = 1068 AND (StateId & 6) = 2),
F AS (SELECT * FROM TxnPMSwap WHERE InstrumentId = 1069 AND (StateId & 6) = 2 AND ValueDate >= '2026-10-02' AND ValueDate < DATEADD(day, 1, CAST('2026-10-02' AS date))),
P AS (
    SELECT n.PkgNo, n.Id AS NearId, f.Id AS FarId, n.CustomerId, LTRIM(RTRIM(n.CcyPair)) AS CcyPair, n.LogicalReference AS NearRef,
           n.BuyCcy, n.BuyAmount, n.SellCcy, n.SellAmount, n.BuyAmountOunce, n.SellAmountOunce, n.BuyAmountGram, n.SellAmountGram,
           CAST(n.DealRateNet AS float) AS NearRate, CAST(f.DealRateNet AS float) AS FarRate,
           CAST(n.ValueDate AS date) AS NearDate, CAST(f.ValueDate AS date) AS FarDate,
           COUNT(*) OVER () AS JoinCnt,
           ROW_NUMBER() OVER (PARTITION BY n.PkgNo ORDER BY n.Id DESC, f.Id DESC) AS Rn
    FROM N n JOIN F f ON f.PkgNo = n.PkgNo
    WHERE n.PkgNo <> 0
),
M AS (
    SELECT p.*, CASE WHEN UPPER(p.BuyCcy) = UPPER(CASE WHEN CHARINDEX('/', p.CcyPair) > 1 THEN LTRIM(RTRIM(LEFT(p.CcyPair, CHARINDEX('/', p.CcyPair) - 1)))
                                     WHEN LEN(p.CcyPair) >= 6 THEN LEFT(p.CcyPair, 3) ELSE p.BuyCcy END) THEN 1 ELSE 0 END AS BaseBought
    FROM P p WHERE p.Rn = 1
),
C AS (
    SELECT m.*, CASE WHEN BaseBought = 1 THEN 'B/S' ELSE 'S/B' END AS Direction,
           CAST(CASE WHEN BaseBought = 1 THEN SellAmount ELSE BuyAmount END AS float) AS NB,
           CASE WHEN BaseBought = 1 THEN SellCcy ELSE BuyCcy END AS NBCcy,
           CAST(ISNULL(CASE WHEN BaseBought = 1 THEN BuyAmountOunce ELSE SellAmountOunce END, 0) AS float) AS Ounce, CAST(ISNULL(CASE WHEN BaseBought = 1 THEN BuyAmountGram ELSE SellAmountGram END, 0) AS float) AS Gram,
           CASE WHEN NearRate = 0 THEN 0 ELSE (FarRate - NearRate) / NearRate * (360.0 / CASE WHEN DATEDIFF(day, NearDate, FarDate) = 0 THEN 1 ELSE DATEDIFF(day, NearDate, FarDate) END) * 100 END AS SR
    FROM M m
)
SELECT TOP (20) MAX(c.NearId) AS MaxNearId, CAST(cu.Name AS nvarchar(200)) AS CounterpartyName, UPPER(c.CcyPair) AS CcyPair, c.Direction, c.NearDate, c.FarDate,
       DATEDIFF(day, c.NearDate, c.FarDate) AS Tenor,
       CASE WHEN c.FarDate < @LD THEN 0 ELSE DATEDIFF(day, @LD, c.FarDate) END AS DaysToMaturity,
       ROUND(SUM(c.NB), 2) AS TotalAmount, MAX(c.NBCcy) AS TotalAmountCcy,
       CASE WHEN SUM(c.NB) <> 0 THEN SUM(c.NB * c.SR) / SUM(c.NB) ELSE AVG(c.SR) END AS SwapRate,
       MAX(c.SellCcy) AS SoldCcy, ROUND(SUM(c.SellAmount), 2) AS SoldAmount, MAX(c.BuyCcy) AS BoughtCcy, ROUND(SUM(c.BuyAmount), 2) AS BoughtAmount,
       ROUND(SUM(c.Ounce), 2) AS Ounce, ROUND(SUM(c.Gram), 2) AS Gram,
       COUNT(*) AS TxnCount, STRING_AGG(c.NearRef, ', ') AS Refs,
       MAX(c.JoinCnt) AS JoinCnt, (SELECT COUNT(*) FROM M) AS PkgCnt
FROM C c
LEFT JOIN CusCustomer cu ON cu.Id = c.CustomerId
GROUP BY c.CustomerId, cu.Name, UPPER(c.CcyPair), c.Direction, c.NearDate, c.FarDate
ORDER BY MaxNearId DESC;
```

DB: `NetTrexFX` · Server: `tcp:192.168.10.211,1433` · User: `trusr` · Pass: `***`


## #122

**Amaç:** Test PM Swap: Valör + vade birlikte — valör 2026-10-01–2026-10-01, vade 2026-10-02–2026-10-02. API (ekran) gruplanmış satırları ile karşılaştırma (aynı join/gruplama/oran formülü).

```sql
SET NOCOUNT ON;
DECLARE @LD date = '2026-10-02';
WITH N AS (SELECT * FROM TxnPMSwap WHERE InstrumentId = 1068 AND (StateId & 6) = 2 AND ValueDate >= '2026-10-01' AND ValueDate < DATEADD(day, 1, CAST('2026-10-01' AS date))),
F AS (SELECT * FROM TxnPMSwap WHERE InstrumentId = 1069 AND (StateId & 6) = 2 AND ValueDate >= '2026-10-02' AND ValueDate < DATEADD(day, 1, CAST('2026-10-02' AS date))),
P AS (
    SELECT n.PkgNo, n.Id AS NearId, f.Id AS FarId, n.CustomerId, LTRIM(RTRIM(n.CcyPair)) AS CcyPair, n.LogicalReference AS NearRef,
           n.BuyCcy, n.BuyAmount, n.SellCcy, n.SellAmount, n.BuyAmountOunce, n.SellAmountOunce, n.BuyAmountGram, n.SellAmountGram,
           CAST(n.DealRateNet AS float) AS NearRate, CAST(f.DealRateNet AS float) AS FarRate,
           CAST(n.ValueDate AS date) AS NearDate, CAST(f.ValueDate AS date) AS FarDate,
           COUNT(*) OVER () AS JoinCnt,
           ROW_NUMBER() OVER (PARTITION BY n.PkgNo ORDER BY n.Id DESC, f.Id DESC) AS Rn
    FROM N n JOIN F f ON f.PkgNo = n.PkgNo
    WHERE n.PkgNo <> 0
),
M AS (
    SELECT p.*, CASE WHEN UPPER(p.BuyCcy) = UPPER(CASE WHEN CHARINDEX('/', p.CcyPair) > 1 THEN LTRIM(RTRIM(LEFT(p.CcyPair, CHARINDEX('/', p.CcyPair) - 1)))
                                     WHEN LEN(p.CcyPair) >= 6 THEN LEFT(p.CcyPair, 3) ELSE p.BuyCcy END) THEN 1 ELSE 0 END AS BaseBought
    FROM P p WHERE p.Rn = 1
),
C AS (
    SELECT m.*, CASE WHEN BaseBought = 1 THEN 'B/S' ELSE 'S/B' END AS Direction,
           CAST(CASE WHEN BaseBought = 1 THEN SellAmount ELSE BuyAmount END AS float) AS NB,
           CASE WHEN BaseBought = 1 THEN SellCcy ELSE BuyCcy END AS NBCcy,
           CAST(ISNULL(CASE WHEN BaseBought = 1 THEN BuyAmountOunce ELSE SellAmountOunce END, 0) AS float) AS Ounce, CAST(ISNULL(CASE WHEN BaseBought = 1 THEN BuyAmountGram ELSE SellAmountGram END, 0) AS float) AS Gram,
           CASE WHEN NearRate = 0 THEN 0 ELSE (FarRate - NearRate) / NearRate * (360.0 / CASE WHEN DATEDIFF(day, NearDate, FarDate) = 0 THEN 1 ELSE DATEDIFF(day, NearDate, FarDate) END) * 100 END AS SR
    FROM M m
)
SELECT TOP (20) MAX(c.NearId) AS MaxNearId, CAST(cu.Name AS nvarchar(200)) AS CounterpartyName, UPPER(c.CcyPair) AS CcyPair, c.Direction, c.NearDate, c.FarDate,
       DATEDIFF(day, c.NearDate, c.FarDate) AS Tenor,
       CASE WHEN c.FarDate < @LD THEN 0 ELSE DATEDIFF(day, @LD, c.FarDate) END AS DaysToMaturity,
       ROUND(SUM(c.NB), 2) AS TotalAmount, MAX(c.NBCcy) AS TotalAmountCcy,
       CASE WHEN SUM(c.NB) <> 0 THEN SUM(c.NB * c.SR) / SUM(c.NB) ELSE AVG(c.SR) END AS SwapRate,
       MAX(c.SellCcy) AS SoldCcy, ROUND(SUM(c.SellAmount), 2) AS SoldAmount, MAX(c.BuyCcy) AS BoughtCcy, ROUND(SUM(c.BuyAmount), 2) AS BoughtAmount,
       ROUND(SUM(c.Ounce), 2) AS Ounce, ROUND(SUM(c.Gram), 2) AS Gram,
       COUNT(*) AS TxnCount, STRING_AGG(c.NearRef, ', ') AS Refs,
       MAX(c.JoinCnt) AS JoinCnt, (SELECT COUNT(*) FROM M) AS PkgCnt
FROM C c
LEFT JOIN CusCustomer cu ON cu.Id = c.CustomerId
GROUP BY c.CustomerId, cu.Name, UPPER(c.CcyPair), c.Direction, c.NearDate, c.FarDate
ORDER BY MaxNearId DESC;
```

DB: `NetTrexFX` · Server: `tcp:192.168.10.211,1433` · User: `trusr` · Pass: `***`


## #123

**Amaç:** Test PM Swap: Geniş aralık — valör 2020-01-01–2030-12-31, vade 2020-01-01–2030-12-31. API (ekran) gruplanmış satırları ile karşılaştırma (aynı join/gruplama/oran formülü).

```sql
SET NOCOUNT ON;
DECLARE @LD date = '2026-10-02';
WITH N AS (SELECT * FROM TxnPMSwap WHERE InstrumentId = 1068 AND (StateId & 6) = 2 AND ValueDate >= '2020-01-01' AND ValueDate < DATEADD(day, 1, CAST('2030-12-31' AS date))),
F AS (SELECT * FROM TxnPMSwap WHERE InstrumentId = 1069 AND (StateId & 6) = 2 AND ValueDate >= '2020-01-01' AND ValueDate < DATEADD(day, 1, CAST('2030-12-31' AS date))),
P AS (
    SELECT n.PkgNo, n.Id AS NearId, f.Id AS FarId, n.CustomerId, LTRIM(RTRIM(n.CcyPair)) AS CcyPair, n.LogicalReference AS NearRef,
           n.BuyCcy, n.BuyAmount, n.SellCcy, n.SellAmount, n.BuyAmountOunce, n.SellAmountOunce, n.BuyAmountGram, n.SellAmountGram,
           CAST(n.DealRateNet AS float) AS NearRate, CAST(f.DealRateNet AS float) AS FarRate,
           CAST(n.ValueDate AS date) AS NearDate, CAST(f.ValueDate AS date) AS FarDate,
           COUNT(*) OVER () AS JoinCnt,
           ROW_NUMBER() OVER (PARTITION BY n.PkgNo ORDER BY n.Id DESC, f.Id DESC) AS Rn
    FROM N n JOIN F f ON f.PkgNo = n.PkgNo
    WHERE n.PkgNo <> 0
),
M AS (
    SELECT p.*, CASE WHEN UPPER(p.BuyCcy) = UPPER(CASE WHEN CHARINDEX('/', p.CcyPair) > 1 THEN LTRIM(RTRIM(LEFT(p.CcyPair, CHARINDEX('/', p.CcyPair) - 1)))
                                     WHEN LEN(p.CcyPair) >= 6 THEN LEFT(p.CcyPair, 3) ELSE p.BuyCcy END) THEN 1 ELSE 0 END AS BaseBought
    FROM P p WHERE p.Rn = 1
),
C AS (
    SELECT m.*, CASE WHEN BaseBought = 1 THEN 'B/S' ELSE 'S/B' END AS Direction,
           CAST(CASE WHEN BaseBought = 1 THEN SellAmount ELSE BuyAmount END AS float) AS NB,
           CASE WHEN BaseBought = 1 THEN SellCcy ELSE BuyCcy END AS NBCcy,
           CAST(ISNULL(CASE WHEN BaseBought = 1 THEN BuyAmountOunce ELSE SellAmountOunce END, 0) AS float) AS Ounce, CAST(ISNULL(CASE WHEN BaseBought = 1 THEN BuyAmountGram ELSE SellAmountGram END, 0) AS float) AS Gram,
           CASE WHEN NearRate = 0 THEN 0 ELSE (FarRate - NearRate) / NearRate * (360.0 / CASE WHEN DATEDIFF(day, NearDate, FarDate) = 0 THEN 1 ELSE DATEDIFF(day, NearDate, FarDate) END) * 100 END AS SR
    FROM M m
)
SELECT TOP (20) MAX(c.NearId) AS MaxNearId, CAST(cu.Name AS nvarchar(200)) AS CounterpartyName, UPPER(c.CcyPair) AS CcyPair, c.Direction, c.NearDate, c.FarDate,
       DATEDIFF(day, c.NearDate, c.FarDate) AS Tenor,
       CASE WHEN c.FarDate < @LD THEN 0 ELSE DATEDIFF(day, @LD, c.FarDate) END AS DaysToMaturity,
       ROUND(SUM(c.NB), 2) AS TotalAmount, MAX(c.NBCcy) AS TotalAmountCcy,
       CASE WHEN SUM(c.NB) <> 0 THEN SUM(c.NB * c.SR) / SUM(c.NB) ELSE AVG(c.SR) END AS SwapRate,
       MAX(c.SellCcy) AS SoldCcy, ROUND(SUM(c.SellAmount), 2) AS SoldAmount, MAX(c.BuyCcy) AS BoughtCcy, ROUND(SUM(c.BuyAmount), 2) AS BoughtAmount,
       ROUND(SUM(c.Ounce), 2) AS Ounce, ROUND(SUM(c.Gram), 2) AS Gram,
       COUNT(*) AS TxnCount, STRING_AGG(c.NearRef, ', ') AS Refs,
       MAX(c.JoinCnt) AS JoinCnt, (SELECT COUNT(*) FROM M) AS PkgCnt
FROM C c
LEFT JOIN CusCustomer cu ON cu.Id = c.CustomerId
GROUP BY c.CustomerId, cu.Name, UPPER(c.CcyPair), c.Direction, c.NearDate, c.FarDate
ORDER BY MaxNearId DESC;
```

DB: `NetTrexFX` · Server: `tcp:192.168.10.211,1433` · User: `trusr` · Pass: `***`


## #124

**Amaç:** Test PM Swap: Yalnız referans önek — ref 'TPMSW261001'. API (ekran) gruplanmış satırları ile karşılaştırma (aynı join/gruplama/oran formülü).

```sql
SET NOCOUNT ON;
DECLARE @LD date = '2026-10-02';
WITH N AS (SELECT * FROM TxnPMSwap WHERE InstrumentId = 1068 AND (StateId & 6) = 2),
F AS (SELECT * FROM TxnPMSwap WHERE InstrumentId = 1069 AND (StateId & 6) = 2),
P AS (
    SELECT n.PkgNo, n.Id AS NearId, f.Id AS FarId, n.CustomerId, LTRIM(RTRIM(n.CcyPair)) AS CcyPair, n.LogicalReference AS NearRef,
           n.BuyCcy, n.BuyAmount, n.SellCcy, n.SellAmount, n.BuyAmountOunce, n.SellAmountOunce, n.BuyAmountGram, n.SellAmountGram,
           CAST(n.DealRateNet AS float) AS NearRate, CAST(f.DealRateNet AS float) AS FarRate,
           CAST(n.ValueDate AS date) AS NearDate, CAST(f.ValueDate AS date) AS FarDate,
           COUNT(*) OVER () AS JoinCnt,
           ROW_NUMBER() OVER (PARTITION BY n.PkgNo ORDER BY n.Id DESC, f.Id DESC) AS Rn
    FROM N n JOIN F f ON f.PkgNo = n.PkgNo
    WHERE n.PkgNo <> 0 AND (n.LogicalReference LIKE '%TPMSW261001%' OR f.LogicalReference LIKE '%TPMSW261001%')
),
M AS (
    SELECT p.*, CASE WHEN UPPER(p.BuyCcy) = UPPER(CASE WHEN CHARINDEX('/', p.CcyPair) > 1 THEN LTRIM(RTRIM(LEFT(p.CcyPair, CHARINDEX('/', p.CcyPair) - 1)))
                                     WHEN LEN(p.CcyPair) >= 6 THEN LEFT(p.CcyPair, 3) ELSE p.BuyCcy END) THEN 1 ELSE 0 END AS BaseBought
    FROM P p WHERE p.Rn = 1
),
C AS (
    SELECT m.*, CASE WHEN BaseBought = 1 THEN 'B/S' ELSE 'S/B' END AS Direction,
           CAST(CASE WHEN BaseBought = 1 THEN SellAmount ELSE BuyAmount END AS float) AS NB,
           CASE WHEN BaseBought = 1 THEN SellCcy ELSE BuyCcy END AS NBCcy,
           CAST(ISNULL(CASE WHEN BaseBought = 1 THEN BuyAmountOunce ELSE SellAmountOunce END, 0) AS float) AS Ounce, CAST(ISNULL(CASE WHEN BaseBought = 1 THEN BuyAmountGram ELSE SellAmountGram END, 0) AS float) AS Gram,
           CASE WHEN NearRate = 0 THEN 0 ELSE (FarRate - NearRate) / NearRate * (360.0 / CASE WHEN DATEDIFF(day, NearDate, FarDate) = 0 THEN 1 ELSE DATEDIFF(day, NearDate, FarDate) END) * 100 END AS SR
    FROM M m
)
SELECT TOP (20) MAX(c.NearId) AS MaxNearId, CAST(cu.Name AS nvarchar(200)) AS CounterpartyName, UPPER(c.CcyPair) AS CcyPair, c.Direction, c.NearDate, c.FarDate,
       DATEDIFF(day, c.NearDate, c.FarDate) AS Tenor,
       CASE WHEN c.FarDate < @LD THEN 0 ELSE DATEDIFF(day, @LD, c.FarDate) END AS DaysToMaturity,
       ROUND(SUM(c.NB), 2) AS TotalAmount, MAX(c.NBCcy) AS TotalAmountCcy,
       CASE WHEN SUM(c.NB) <> 0 THEN SUM(c.NB * c.SR) / SUM(c.NB) ELSE AVG(c.SR) END AS SwapRate,
       MAX(c.SellCcy) AS SoldCcy, ROUND(SUM(c.SellAmount), 2) AS SoldAmount, MAX(c.BuyCcy) AS BoughtCcy, ROUND(SUM(c.BuyAmount), 2) AS BoughtAmount,
       ROUND(SUM(c.Ounce), 2) AS Ounce, ROUND(SUM(c.Gram), 2) AS Gram,
       COUNT(*) AS TxnCount, STRING_AGG(c.NearRef, ', ') AS Refs,
       MAX(c.JoinCnt) AS JoinCnt, (SELECT COUNT(*) FROM M) AS PkgCnt
FROM C c
LEFT JOIN CusCustomer cu ON cu.Id = c.CustomerId
GROUP BY c.CustomerId, cu.Name, UPPER(c.CcyPair), c.Direction, c.NearDate, c.FarDate
ORDER BY MaxNearId DESC;
```

DB: `NetTrexFX` · Server: `tcp:192.168.10.211,1433` · User: `trusr` · Pass: `***`


## #125

**Amaç:** Test PM Swap: Tam referans (near, 423 ons paket) — ref 'TPMSW26100100003'. API (ekran) gruplanmış satırları ile karşılaştırma (aynı join/gruplama/oran formülü).

```sql
SET NOCOUNT ON;
DECLARE @LD date = '2026-10-02';
WITH N AS (SELECT * FROM TxnPMSwap WHERE InstrumentId = 1068 AND (StateId & 6) = 2),
F AS (SELECT * FROM TxnPMSwap WHERE InstrumentId = 1069 AND (StateId & 6) = 2),
P AS (
    SELECT n.PkgNo, n.Id AS NearId, f.Id AS FarId, n.CustomerId, LTRIM(RTRIM(n.CcyPair)) AS CcyPair, n.LogicalReference AS NearRef,
           n.BuyCcy, n.BuyAmount, n.SellCcy, n.SellAmount, n.BuyAmountOunce, n.SellAmountOunce, n.BuyAmountGram, n.SellAmountGram,
           CAST(n.DealRateNet AS float) AS NearRate, CAST(f.DealRateNet AS float) AS FarRate,
           CAST(n.ValueDate AS date) AS NearDate, CAST(f.ValueDate AS date) AS FarDate,
           COUNT(*) OVER () AS JoinCnt,
           ROW_NUMBER() OVER (PARTITION BY n.PkgNo ORDER BY n.Id DESC, f.Id DESC) AS Rn
    FROM N n JOIN F f ON f.PkgNo = n.PkgNo
    WHERE n.PkgNo <> 0 AND (n.LogicalReference LIKE '%TPMSW26100100003%' OR f.LogicalReference LIKE '%TPMSW26100100003%')
),
M AS (
    SELECT p.*, CASE WHEN UPPER(p.BuyCcy) = UPPER(CASE WHEN CHARINDEX('/', p.CcyPair) > 1 THEN LTRIM(RTRIM(LEFT(p.CcyPair, CHARINDEX('/', p.CcyPair) - 1)))
                                     WHEN LEN(p.CcyPair) >= 6 THEN LEFT(p.CcyPair, 3) ELSE p.BuyCcy END) THEN 1 ELSE 0 END AS BaseBought
    FROM P p WHERE p.Rn = 1
),
C AS (
    SELECT m.*, CASE WHEN BaseBought = 1 THEN 'B/S' ELSE 'S/B' END AS Direction,
           CAST(CASE WHEN BaseBought = 1 THEN SellAmount ELSE BuyAmount END AS float) AS NB,
           CASE WHEN BaseBought = 1 THEN SellCcy ELSE BuyCcy END AS NBCcy,
           CAST(ISNULL(CASE WHEN BaseBought = 1 THEN BuyAmountOunce ELSE SellAmountOunce END, 0) AS float) AS Ounce, CAST(ISNULL(CASE WHEN BaseBought = 1 THEN BuyAmountGram ELSE SellAmountGram END, 0) AS float) AS Gram,
           CASE WHEN NearRate = 0 THEN 0 ELSE (FarRate - NearRate) / NearRate * (360.0 / CASE WHEN DATEDIFF(day, NearDate, FarDate) = 0 THEN 1 ELSE DATEDIFF(day, NearDate, FarDate) END) * 100 END AS SR
    FROM M m
)
SELECT TOP (20) MAX(c.NearId) AS MaxNearId, CAST(cu.Name AS nvarchar(200)) AS CounterpartyName, UPPER(c.CcyPair) AS CcyPair, c.Direction, c.NearDate, c.FarDate,
       DATEDIFF(day, c.NearDate, c.FarDate) AS Tenor,
       CASE WHEN c.FarDate < @LD THEN 0 ELSE DATEDIFF(day, @LD, c.FarDate) END AS DaysToMaturity,
       ROUND(SUM(c.NB), 2) AS TotalAmount, MAX(c.NBCcy) AS TotalAmountCcy,
       CASE WHEN SUM(c.NB) <> 0 THEN SUM(c.NB * c.SR) / SUM(c.NB) ELSE AVG(c.SR) END AS SwapRate,
       MAX(c.SellCcy) AS SoldCcy, ROUND(SUM(c.SellAmount), 2) AS SoldAmount, MAX(c.BuyCcy) AS BoughtCcy, ROUND(SUM(c.BuyAmount), 2) AS BoughtAmount,
       ROUND(SUM(c.Ounce), 2) AS Ounce, ROUND(SUM(c.Gram), 2) AS Gram,
       COUNT(*) AS TxnCount, STRING_AGG(c.NearRef, ', ') AS Refs,
       MAX(c.JoinCnt) AS JoinCnt, (SELECT COUNT(*) FROM M) AS PkgCnt
FROM C c
LEFT JOIN CusCustomer cu ON cu.Id = c.CustomerId
GROUP BY c.CustomerId, cu.Name, UPPER(c.CcyPair), c.Direction, c.NearDate, c.FarDate
ORDER BY MaxNearId DESC;
```

DB: `NetTrexFX` · Server: `tcp:192.168.10.211,1433` · User: `trusr` · Pass: `***`


## #126

**Amaç:** Test PM Swap: Tam referans (far bacak) — ref 'TPMSW26100100008'. API (ekran) gruplanmış satırları ile karşılaştırma (aynı join/gruplama/oran formülü).

```sql
SET NOCOUNT ON;
DECLARE @LD date = '2026-10-02';
WITH N AS (SELECT * FROM TxnPMSwap WHERE InstrumentId = 1068 AND (StateId & 6) = 2),
F AS (SELECT * FROM TxnPMSwap WHERE InstrumentId = 1069 AND (StateId & 6) = 2),
P AS (
    SELECT n.PkgNo, n.Id AS NearId, f.Id AS FarId, n.CustomerId, LTRIM(RTRIM(n.CcyPair)) AS CcyPair, n.LogicalReference AS NearRef,
           n.BuyCcy, n.BuyAmount, n.SellCcy, n.SellAmount, n.BuyAmountOunce, n.SellAmountOunce, n.BuyAmountGram, n.SellAmountGram,
           CAST(n.DealRateNet AS float) AS NearRate, CAST(f.DealRateNet AS float) AS FarRate,
           CAST(n.ValueDate AS date) AS NearDate, CAST(f.ValueDate AS date) AS FarDate,
           COUNT(*) OVER () AS JoinCnt,
           ROW_NUMBER() OVER (PARTITION BY n.PkgNo ORDER BY n.Id DESC, f.Id DESC) AS Rn
    FROM N n JOIN F f ON f.PkgNo = n.PkgNo
    WHERE n.PkgNo <> 0 AND (n.LogicalReference LIKE '%TPMSW26100100008%' OR f.LogicalReference LIKE '%TPMSW26100100008%')
),
M AS (
    SELECT p.*, CASE WHEN UPPER(p.BuyCcy) = UPPER(CASE WHEN CHARINDEX('/', p.CcyPair) > 1 THEN LTRIM(RTRIM(LEFT(p.CcyPair, CHARINDEX('/', p.CcyPair) - 1)))
                                     WHEN LEN(p.CcyPair) >= 6 THEN LEFT(p.CcyPair, 3) ELSE p.BuyCcy END) THEN 1 ELSE 0 END AS BaseBought
    FROM P p WHERE p.Rn = 1
),
C AS (
    SELECT m.*, CASE WHEN BaseBought = 1 THEN 'B/S' ELSE 'S/B' END AS Direction,
           CAST(CASE WHEN BaseBought = 1 THEN SellAmount ELSE BuyAmount END AS float) AS NB,
           CASE WHEN BaseBought = 1 THEN SellCcy ELSE BuyCcy END AS NBCcy,
           CAST(ISNULL(CASE WHEN BaseBought = 1 THEN BuyAmountOunce ELSE SellAmountOunce END, 0) AS float) AS Ounce, CAST(ISNULL(CASE WHEN BaseBought = 1 THEN BuyAmountGram ELSE SellAmountGram END, 0) AS float) AS Gram,
           CASE WHEN NearRate = 0 THEN 0 ELSE (FarRate - NearRate) / NearRate * (360.0 / CASE WHEN DATEDIFF(day, NearDate, FarDate) = 0 THEN 1 ELSE DATEDIFF(day, NearDate, FarDate) END) * 100 END AS SR
    FROM M m
)
SELECT TOP (20) MAX(c.NearId) AS MaxNearId, CAST(cu.Name AS nvarchar(200)) AS CounterpartyName, UPPER(c.CcyPair) AS CcyPair, c.Direction, c.NearDate, c.FarDate,
       DATEDIFF(day, c.NearDate, c.FarDate) AS Tenor,
       CASE WHEN c.FarDate < @LD THEN 0 ELSE DATEDIFF(day, @LD, c.FarDate) END AS DaysToMaturity,
       ROUND(SUM(c.NB), 2) AS TotalAmount, MAX(c.NBCcy) AS TotalAmountCcy,
       CASE WHEN SUM(c.NB) <> 0 THEN SUM(c.NB * c.SR) / SUM(c.NB) ELSE AVG(c.SR) END AS SwapRate,
       MAX(c.SellCcy) AS SoldCcy, ROUND(SUM(c.SellAmount), 2) AS SoldAmount, MAX(c.BuyCcy) AS BoughtCcy, ROUND(SUM(c.BuyAmount), 2) AS BoughtAmount,
       ROUND(SUM(c.Ounce), 2) AS Ounce, ROUND(SUM(c.Gram), 2) AS Gram,
       COUNT(*) AS TxnCount, STRING_AGG(c.NearRef, ', ') AS Refs,
       MAX(c.JoinCnt) AS JoinCnt, (SELECT COUNT(*) FROM M) AS PkgCnt
FROM C c
LEFT JOIN CusCustomer cu ON cu.Id = c.CustomerId
GROUP BY c.CustomerId, cu.Name, UPPER(c.CcyPair), c.Direction, c.NearDate, c.FarDate
ORDER BY MaxNearId DESC;
```

DB: `NetTrexFX` · Server: `tcp:192.168.10.211,1433` · User: `trusr` · Pass: `***`


## #127

**Amaç:** Test PM Swap: Referans + tarih — valör 2026-10-01–2026-10-31, ref 'TPMSW26100100013'. API (ekran) gruplanmış satırları ile karşılaştırma (aynı join/gruplama/oran formülü).

```sql
SET NOCOUNT ON;
DECLARE @LD date = '2026-10-02';
WITH N AS (SELECT * FROM TxnPMSwap WHERE InstrumentId = 1068 AND (StateId & 6) = 2 AND ValueDate >= '2026-10-01' AND ValueDate < DATEADD(day, 1, CAST('2026-10-31' AS date))),
F AS (SELECT * FROM TxnPMSwap WHERE InstrumentId = 1069 AND (StateId & 6) = 2),
P AS (
    SELECT n.PkgNo, n.Id AS NearId, f.Id AS FarId, n.CustomerId, LTRIM(RTRIM(n.CcyPair)) AS CcyPair, n.LogicalReference AS NearRef,
           n.BuyCcy, n.BuyAmount, n.SellCcy, n.SellAmount, n.BuyAmountOunce, n.SellAmountOunce, n.BuyAmountGram, n.SellAmountGram,
           CAST(n.DealRateNet AS float) AS NearRate, CAST(f.DealRateNet AS float) AS FarRate,
           CAST(n.ValueDate AS date) AS NearDate, CAST(f.ValueDate AS date) AS FarDate,
           COUNT(*) OVER () AS JoinCnt,
           ROW_NUMBER() OVER (PARTITION BY n.PkgNo ORDER BY n.Id DESC, f.Id DESC) AS Rn
    FROM N n JOIN F f ON f.PkgNo = n.PkgNo
    WHERE n.PkgNo <> 0 AND (n.LogicalReference LIKE '%TPMSW26100100013%' OR f.LogicalReference LIKE '%TPMSW26100100013%')
),
M AS (
    SELECT p.*, CASE WHEN UPPER(p.BuyCcy) = UPPER(CASE WHEN CHARINDEX('/', p.CcyPair) > 1 THEN LTRIM(RTRIM(LEFT(p.CcyPair, CHARINDEX('/', p.CcyPair) - 1)))
                                     WHEN LEN(p.CcyPair) >= 6 THEN LEFT(p.CcyPair, 3) ELSE p.BuyCcy END) THEN 1 ELSE 0 END AS BaseBought
    FROM P p WHERE p.Rn = 1
),
C AS (
    SELECT m.*, CASE WHEN BaseBought = 1 THEN 'B/S' ELSE 'S/B' END AS Direction,
           CAST(CASE WHEN BaseBought = 1 THEN SellAmount ELSE BuyAmount END AS float) AS NB,
           CASE WHEN BaseBought = 1 THEN SellCcy ELSE BuyCcy END AS NBCcy,
           CAST(ISNULL(CASE WHEN BaseBought = 1 THEN BuyAmountOunce ELSE SellAmountOunce END, 0) AS float) AS Ounce, CAST(ISNULL(CASE WHEN BaseBought = 1 THEN BuyAmountGram ELSE SellAmountGram END, 0) AS float) AS Gram,
           CASE WHEN NearRate = 0 THEN 0 ELSE (FarRate - NearRate) / NearRate * (360.0 / CASE WHEN DATEDIFF(day, NearDate, FarDate) = 0 THEN 1 ELSE DATEDIFF(day, NearDate, FarDate) END) * 100 END AS SR
    FROM M m
)
SELECT TOP (20) MAX(c.NearId) AS MaxNearId, CAST(cu.Name AS nvarchar(200)) AS CounterpartyName, UPPER(c.CcyPair) AS CcyPair, c.Direction, c.NearDate, c.FarDate,
       DATEDIFF(day, c.NearDate, c.FarDate) AS Tenor,
       CASE WHEN c.FarDate < @LD THEN 0 ELSE DATEDIFF(day, @LD, c.FarDate) END AS DaysToMaturity,
       ROUND(SUM(c.NB), 2) AS TotalAmount, MAX(c.NBCcy) AS TotalAmountCcy,
       CASE WHEN SUM(c.NB) <> 0 THEN SUM(c.NB * c.SR) / SUM(c.NB) ELSE AVG(c.SR) END AS SwapRate,
       MAX(c.SellCcy) AS SoldCcy, ROUND(SUM(c.SellAmount), 2) AS SoldAmount, MAX(c.BuyCcy) AS BoughtCcy, ROUND(SUM(c.BuyAmount), 2) AS BoughtAmount,
       ROUND(SUM(c.Ounce), 2) AS Ounce, ROUND(SUM(c.Gram), 2) AS Gram,
       COUNT(*) AS TxnCount, STRING_AGG(c.NearRef, ', ') AS Refs,
       MAX(c.JoinCnt) AS JoinCnt, (SELECT COUNT(*) FROM M) AS PkgCnt
FROM C c
LEFT JOIN CusCustomer cu ON cu.Id = c.CustomerId
GROUP BY c.CustomerId, cu.Name, UPPER(c.CcyPair), c.Direction, c.NearDate, c.FarDate
ORDER BY MaxNearId DESC;
```

DB: `NetTrexFX` · Server: `tcp:192.168.10.211,1433` · User: `trusr` · Pass: `***`


## #128

**Amaç:** Test PM Swap: Olmayan referans — ref 'YOKBOYLEREF'. API (ekran) gruplanmış satırları ile karşılaştırma (aynı join/gruplama/oran formülü).

```sql
SET NOCOUNT ON;
DECLARE @LD date = '2026-10-02';
WITH N AS (SELECT * FROM TxnPMSwap WHERE InstrumentId = 1068 AND (StateId & 6) = 2),
F AS (SELECT * FROM TxnPMSwap WHERE InstrumentId = 1069 AND (StateId & 6) = 2),
P AS (
    SELECT n.PkgNo, n.Id AS NearId, f.Id AS FarId, n.CustomerId, LTRIM(RTRIM(n.CcyPair)) AS CcyPair, n.LogicalReference AS NearRef,
           n.BuyCcy, n.BuyAmount, n.SellCcy, n.SellAmount, n.BuyAmountOunce, n.SellAmountOunce, n.BuyAmountGram, n.SellAmountGram,
           CAST(n.DealRateNet AS float) AS NearRate, CAST(f.DealRateNet AS float) AS FarRate,
           CAST(n.ValueDate AS date) AS NearDate, CAST(f.ValueDate AS date) AS FarDate,
           COUNT(*) OVER () AS JoinCnt,
           ROW_NUMBER() OVER (PARTITION BY n.PkgNo ORDER BY n.Id DESC, f.Id DESC) AS Rn
    FROM N n JOIN F f ON f.PkgNo = n.PkgNo
    WHERE n.PkgNo <> 0 AND (n.LogicalReference LIKE '%YOKBOYLEREF%' OR f.LogicalReference LIKE '%YOKBOYLEREF%')
),
M AS (
    SELECT p.*, CASE WHEN UPPER(p.BuyCcy) = UPPER(CASE WHEN CHARINDEX('/', p.CcyPair) > 1 THEN LTRIM(RTRIM(LEFT(p.CcyPair, CHARINDEX('/', p.CcyPair) - 1)))
                                     WHEN LEN(p.CcyPair) >= 6 THEN LEFT(p.CcyPair, 3) ELSE p.BuyCcy END) THEN 1 ELSE 0 END AS BaseBought
    FROM P p WHERE p.Rn = 1
),
C AS (
    SELECT m.*, CASE WHEN BaseBought = 1 THEN 'B/S' ELSE 'S/B' END AS Direction,
           CAST(CASE WHEN BaseBought = 1 THEN SellAmount ELSE BuyAmount END AS float) AS NB,
           CASE WHEN BaseBought = 1 THEN SellCcy ELSE BuyCcy END AS NBCcy,
           CAST(ISNULL(CASE WHEN BaseBought = 1 THEN BuyAmountOunce ELSE SellAmountOunce END, 0) AS float) AS Ounce, CAST(ISNULL(CASE WHEN BaseBought = 1 THEN BuyAmountGram ELSE SellAmountGram END, 0) AS float) AS Gram,
           CASE WHEN NearRate = 0 THEN 0 ELSE (FarRate - NearRate) / NearRate * (360.0 / CASE WHEN DATEDIFF(day, NearDate, FarDate) = 0 THEN 1 ELSE DATEDIFF(day, NearDate, FarDate) END) * 100 END AS SR
    FROM M m
)
SELECT TOP (20) MAX(c.NearId) AS MaxNearId, CAST(cu.Name AS nvarchar(200)) AS CounterpartyName, UPPER(c.CcyPair) AS CcyPair, c.Direction, c.NearDate, c.FarDate,
       DATEDIFF(day, c.NearDate, c.FarDate) AS Tenor,
       CASE WHEN c.FarDate < @LD THEN 0 ELSE DATEDIFF(day, @LD, c.FarDate) END AS DaysToMaturity,
       ROUND(SUM(c.NB), 2) AS TotalAmount, MAX(c.NBCcy) AS TotalAmountCcy,
       CASE WHEN SUM(c.NB) <> 0 THEN SUM(c.NB * c.SR) / SUM(c.NB) ELSE AVG(c.SR) END AS SwapRate,
       MAX(c.SellCcy) AS SoldCcy, ROUND(SUM(c.SellAmount), 2) AS SoldAmount, MAX(c.BuyCcy) AS BoughtCcy, ROUND(SUM(c.BuyAmount), 2) AS BoughtAmount,
       ROUND(SUM(c.Ounce), 2) AS Ounce, ROUND(SUM(c.Gram), 2) AS Gram,
       COUNT(*) AS TxnCount, STRING_AGG(c.NearRef, ', ') AS Refs,
       MAX(c.JoinCnt) AS JoinCnt, (SELECT COUNT(*) FROM M) AS PkgCnt
FROM C c
LEFT JOIN CusCustomer cu ON cu.Id = c.CustomerId
GROUP BY c.CustomerId, cu.Name, UPPER(c.CcyPair), c.Direction, c.NearDate, c.FarDate
ORDER BY MaxNearId DESC;
```

DB: `NetTrexFX` · Server: `tcp:192.168.10.211,1433` · User: `trusr` · Pass: `***`


## #129

**Amaç:** Test PM Swap: Input (16) paketin referansı — ref 'TPMSW26100100009'. API (ekran) gruplanmış satırları ile karşılaştırma (aynı join/gruplama/oran formülü).

```sql
SET NOCOUNT ON;
DECLARE @LD date = '2026-10-02';
WITH N AS (SELECT * FROM TxnPMSwap WHERE InstrumentId = 1068 AND (StateId & 6) = 2),
F AS (SELECT * FROM TxnPMSwap WHERE InstrumentId = 1069 AND (StateId & 6) = 2),
P AS (
    SELECT n.PkgNo, n.Id AS NearId, f.Id AS FarId, n.CustomerId, LTRIM(RTRIM(n.CcyPair)) AS CcyPair, n.LogicalReference AS NearRef,
           n.BuyCcy, n.BuyAmount, n.SellCcy, n.SellAmount, n.BuyAmountOunce, n.SellAmountOunce, n.BuyAmountGram, n.SellAmountGram,
           CAST(n.DealRateNet AS float) AS NearRate, CAST(f.DealRateNet AS float) AS FarRate,
           CAST(n.ValueDate AS date) AS NearDate, CAST(f.ValueDate AS date) AS FarDate,
           COUNT(*) OVER () AS JoinCnt,
           ROW_NUMBER() OVER (PARTITION BY n.PkgNo ORDER BY n.Id DESC, f.Id DESC) AS Rn
    FROM N n JOIN F f ON f.PkgNo = n.PkgNo
    WHERE n.PkgNo <> 0 AND (n.LogicalReference LIKE '%TPMSW26100100009%' OR f.LogicalReference LIKE '%TPMSW26100100009%')
),
M AS (
    SELECT p.*, CASE WHEN UPPER(p.BuyCcy) = UPPER(CASE WHEN CHARINDEX('/', p.CcyPair) > 1 THEN LTRIM(RTRIM(LEFT(p.CcyPair, CHARINDEX('/', p.CcyPair) - 1)))
                                     WHEN LEN(p.CcyPair) >= 6 THEN LEFT(p.CcyPair, 3) ELSE p.BuyCcy END) THEN 1 ELSE 0 END AS BaseBought
    FROM P p WHERE p.Rn = 1
),
C AS (
    SELECT m.*, CASE WHEN BaseBought = 1 THEN 'B/S' ELSE 'S/B' END AS Direction,
           CAST(CASE WHEN BaseBought = 1 THEN SellAmount ELSE BuyAmount END AS float) AS NB,
           CASE WHEN BaseBought = 1 THEN SellCcy ELSE BuyCcy END AS NBCcy,
           CAST(ISNULL(CASE WHEN BaseBought = 1 THEN BuyAmountOunce ELSE SellAmountOunce END, 0) AS float) AS Ounce, CAST(ISNULL(CASE WHEN BaseBought = 1 THEN BuyAmountGram ELSE SellAmountGram END, 0) AS float) AS Gram,
           CASE WHEN NearRate = 0 THEN 0 ELSE (FarRate - NearRate) / NearRate * (360.0 / CASE WHEN DATEDIFF(day, NearDate, FarDate) = 0 THEN 1 ELSE DATEDIFF(day, NearDate, FarDate) END) * 100 END AS SR
    FROM M m
)
SELECT TOP (20) MAX(c.NearId) AS MaxNearId, CAST(cu.Name AS nvarchar(200)) AS CounterpartyName, UPPER(c.CcyPair) AS CcyPair, c.Direction, c.NearDate, c.FarDate,
       DATEDIFF(day, c.NearDate, c.FarDate) AS Tenor,
       CASE WHEN c.FarDate < @LD THEN 0 ELSE DATEDIFF(day, @LD, c.FarDate) END AS DaysToMaturity,
       ROUND(SUM(c.NB), 2) AS TotalAmount, MAX(c.NBCcy) AS TotalAmountCcy,
       CASE WHEN SUM(c.NB) <> 0 THEN SUM(c.NB * c.SR) / SUM(c.NB) ELSE AVG(c.SR) END AS SwapRate,
       MAX(c.SellCcy) AS SoldCcy, ROUND(SUM(c.SellAmount), 2) AS SoldAmount, MAX(c.BuyCcy) AS BoughtCcy, ROUND(SUM(c.BuyAmount), 2) AS BoughtAmount,
       ROUND(SUM(c.Ounce), 2) AS Ounce, ROUND(SUM(c.Gram), 2) AS Gram,
       COUNT(*) AS TxnCount, STRING_AGG(c.NearRef, ', ') AS Refs,
       MAX(c.JoinCnt) AS JoinCnt, (SELECT COUNT(*) FROM M) AS PkgCnt
FROM C c
LEFT JOIN CusCustomer cu ON cu.Id = c.CustomerId
GROUP BY c.CustomerId, cu.Name, UPPER(c.CcyPair), c.Direction, c.NearDate, c.FarDate
ORDER BY MaxNearId DESC;
```

DB: `NetTrexFX` · Server: `tcp:192.168.10.211,1433` · User: `trusr` · Pass: `***`


## #130

**Amaç:** Test PM Swap: DeleteVerified (22) XAU/USD — ref 'TPMSW26100100005'. API (ekran) gruplanmış satırları ile karşılaştırma (aynı join/gruplama/oran formülü).

```sql
SET NOCOUNT ON;
DECLARE @LD date = '2026-10-02';
WITH N AS (SELECT * FROM TxnPMSwap WHERE InstrumentId = 1068 AND (StateId & 6) = 2),
F AS (SELECT * FROM TxnPMSwap WHERE InstrumentId = 1069 AND (StateId & 6) = 2),
P AS (
    SELECT n.PkgNo, n.Id AS NearId, f.Id AS FarId, n.CustomerId, LTRIM(RTRIM(n.CcyPair)) AS CcyPair, n.LogicalReference AS NearRef,
           n.BuyCcy, n.BuyAmount, n.SellCcy, n.SellAmount, n.BuyAmountOunce, n.SellAmountOunce, n.BuyAmountGram, n.SellAmountGram,
           CAST(n.DealRateNet AS float) AS NearRate, CAST(f.DealRateNet AS float) AS FarRate,
           CAST(n.ValueDate AS date) AS NearDate, CAST(f.ValueDate AS date) AS FarDate,
           COUNT(*) OVER () AS JoinCnt,
           ROW_NUMBER() OVER (PARTITION BY n.PkgNo ORDER BY n.Id DESC, f.Id DESC) AS Rn
    FROM N n JOIN F f ON f.PkgNo = n.PkgNo
    WHERE n.PkgNo <> 0 AND (n.LogicalReference LIKE '%TPMSW26100100005%' OR f.LogicalReference LIKE '%TPMSW26100100005%')
),
M AS (
    SELECT p.*, CASE WHEN UPPER(p.BuyCcy) = UPPER(CASE WHEN CHARINDEX('/', p.CcyPair) > 1 THEN LTRIM(RTRIM(LEFT(p.CcyPair, CHARINDEX('/', p.CcyPair) - 1)))
                                     WHEN LEN(p.CcyPair) >= 6 THEN LEFT(p.CcyPair, 3) ELSE p.BuyCcy END) THEN 1 ELSE 0 END AS BaseBought
    FROM P p WHERE p.Rn = 1
),
C AS (
    SELECT m.*, CASE WHEN BaseBought = 1 THEN 'B/S' ELSE 'S/B' END AS Direction,
           CAST(CASE WHEN BaseBought = 1 THEN SellAmount ELSE BuyAmount END AS float) AS NB,
           CASE WHEN BaseBought = 1 THEN SellCcy ELSE BuyCcy END AS NBCcy,
           CAST(ISNULL(CASE WHEN BaseBought = 1 THEN BuyAmountOunce ELSE SellAmountOunce END, 0) AS float) AS Ounce, CAST(ISNULL(CASE WHEN BaseBought = 1 THEN BuyAmountGram ELSE SellAmountGram END, 0) AS float) AS Gram,
           CASE WHEN NearRate = 0 THEN 0 ELSE (FarRate - NearRate) / NearRate * (360.0 / CASE WHEN DATEDIFF(day, NearDate, FarDate) = 0 THEN 1 ELSE DATEDIFF(day, NearDate, FarDate) END) * 100 END AS SR
    FROM M m
)
SELECT TOP (20) MAX(c.NearId) AS MaxNearId, CAST(cu.Name AS nvarchar(200)) AS CounterpartyName, UPPER(c.CcyPair) AS CcyPair, c.Direction, c.NearDate, c.FarDate,
       DATEDIFF(day, c.NearDate, c.FarDate) AS Tenor,
       CASE WHEN c.FarDate < @LD THEN 0 ELSE DATEDIFF(day, @LD, c.FarDate) END AS DaysToMaturity,
       ROUND(SUM(c.NB), 2) AS TotalAmount, MAX(c.NBCcy) AS TotalAmountCcy,
       CASE WHEN SUM(c.NB) <> 0 THEN SUM(c.NB * c.SR) / SUM(c.NB) ELSE AVG(c.SR) END AS SwapRate,
       MAX(c.SellCcy) AS SoldCcy, ROUND(SUM(c.SellAmount), 2) AS SoldAmount, MAX(c.BuyCcy) AS BoughtCcy, ROUND(SUM(c.BuyAmount), 2) AS BoughtAmount,
       ROUND(SUM(c.Ounce), 2) AS Ounce, ROUND(SUM(c.Gram), 2) AS Gram,
       COUNT(*) AS TxnCount, STRING_AGG(c.NearRef, ', ') AS Refs,
       MAX(c.JoinCnt) AS JoinCnt, (SELECT COUNT(*) FROM M) AS PkgCnt
FROM C c
LEFT JOIN CusCustomer cu ON cu.Id = c.CustomerId
GROUP BY c.CustomerId, cu.Name, UPPER(c.CcyPair), c.Direction, c.NearDate, c.FarDate
ORDER BY MaxNearId DESC;
```

DB: `NetTrexFX` · Server: `tcp:192.168.10.211,1433` · User: `trusr` · Pass: `***`


## #131

**Amaç:** Test PM Swap: DeleteVerified (22) XAU/TRY — ref 'TPMSW26100100001'. API (ekran) gruplanmış satırları ile karşılaştırma (aynı join/gruplama/oran formülü).

```sql
SET NOCOUNT ON;
DECLARE @LD date = '2026-10-02';
WITH N AS (SELECT * FROM TxnPMSwap WHERE InstrumentId = 1068 AND (StateId & 6) = 2),
F AS (SELECT * FROM TxnPMSwap WHERE InstrumentId = 1069 AND (StateId & 6) = 2),
P AS (
    SELECT n.PkgNo, n.Id AS NearId, f.Id AS FarId, n.CustomerId, LTRIM(RTRIM(n.CcyPair)) AS CcyPair, n.LogicalReference AS NearRef,
           n.BuyCcy, n.BuyAmount, n.SellCcy, n.SellAmount, n.BuyAmountOunce, n.SellAmountOunce, n.BuyAmountGram, n.SellAmountGram,
           CAST(n.DealRateNet AS float) AS NearRate, CAST(f.DealRateNet AS float) AS FarRate,
           CAST(n.ValueDate AS date) AS NearDate, CAST(f.ValueDate AS date) AS FarDate,
           COUNT(*) OVER () AS JoinCnt,
           ROW_NUMBER() OVER (PARTITION BY n.PkgNo ORDER BY n.Id DESC, f.Id DESC) AS Rn
    FROM N n JOIN F f ON f.PkgNo = n.PkgNo
    WHERE n.PkgNo <> 0 AND (n.LogicalReference LIKE '%TPMSW26100100001%' OR f.LogicalReference LIKE '%TPMSW26100100001%')
),
M AS (
    SELECT p.*, CASE WHEN UPPER(p.BuyCcy) = UPPER(CASE WHEN CHARINDEX('/', p.CcyPair) > 1 THEN LTRIM(RTRIM(LEFT(p.CcyPair, CHARINDEX('/', p.CcyPair) - 1)))
                                     WHEN LEN(p.CcyPair) >= 6 THEN LEFT(p.CcyPair, 3) ELSE p.BuyCcy END) THEN 1 ELSE 0 END AS BaseBought
    FROM P p WHERE p.Rn = 1
),
C AS (
    SELECT m.*, CASE WHEN BaseBought = 1 THEN 'B/S' ELSE 'S/B' END AS Direction,
           CAST(CASE WHEN BaseBought = 1 THEN SellAmount ELSE BuyAmount END AS float) AS NB,
           CASE WHEN BaseBought = 1 THEN SellCcy ELSE BuyCcy END AS NBCcy,
           CAST(ISNULL(CASE WHEN BaseBought = 1 THEN BuyAmountOunce ELSE SellAmountOunce END, 0) AS float) AS Ounce, CAST(ISNULL(CASE WHEN BaseBought = 1 THEN BuyAmountGram ELSE SellAmountGram END, 0) AS float) AS Gram,
           CASE WHEN NearRate = 0 THEN 0 ELSE (FarRate - NearRate) / NearRate * (360.0 / CASE WHEN DATEDIFF(day, NearDate, FarDate) = 0 THEN 1 ELSE DATEDIFF(day, NearDate, FarDate) END) * 100 END AS SR
    FROM M m
)
SELECT TOP (20) MAX(c.NearId) AS MaxNearId, CAST(cu.Name AS nvarchar(200)) AS CounterpartyName, UPPER(c.CcyPair) AS CcyPair, c.Direction, c.NearDate, c.FarDate,
       DATEDIFF(day, c.NearDate, c.FarDate) AS Tenor,
       CASE WHEN c.FarDate < @LD THEN 0 ELSE DATEDIFF(day, @LD, c.FarDate) END AS DaysToMaturity,
       ROUND(SUM(c.NB), 2) AS TotalAmount, MAX(c.NBCcy) AS TotalAmountCcy,
       CASE WHEN SUM(c.NB) <> 0 THEN SUM(c.NB * c.SR) / SUM(c.NB) ELSE AVG(c.SR) END AS SwapRate,
       MAX(c.SellCcy) AS SoldCcy, ROUND(SUM(c.SellAmount), 2) AS SoldAmount, MAX(c.BuyCcy) AS BoughtCcy, ROUND(SUM(c.BuyAmount), 2) AS BoughtAmount,
       ROUND(SUM(c.Ounce), 2) AS Ounce, ROUND(SUM(c.Gram), 2) AS Gram,
       COUNT(*) AS TxnCount, STRING_AGG(c.NearRef, ', ') AS Refs,
       MAX(c.JoinCnt) AS JoinCnt, (SELECT COUNT(*) FROM M) AS PkgCnt
FROM C c
LEFT JOIN CusCustomer cu ON cu.Id = c.CustomerId
GROUP BY c.CustomerId, cu.Name, UPPER(c.CcyPair), c.Direction, c.NearDate, c.FarDate
ORDER BY MaxNearId DESC;
```

DB: `NetTrexFX` · Server: `tcp:192.168.10.211,1433` · User: `trusr` · Pass: `***`


## #132

**Amaç:** Test PM Swap: FX + PM birlikte seçili (PM satırları) — valör 2026-10-01–2026-10-31. API (ekran) gruplanmış satırları ile karşılaştırma (aynı join/gruplama/oran formülü).

```sql
SET NOCOUNT ON;
DECLARE @LD date = '2026-10-02';
WITH N AS (SELECT * FROM TxnPMSwap WHERE InstrumentId = 1068 AND (StateId & 6) = 2 AND ValueDate >= '2026-10-01' AND ValueDate < DATEADD(day, 1, CAST('2026-10-31' AS date))),
F AS (SELECT * FROM TxnPMSwap WHERE InstrumentId = 1069 AND (StateId & 6) = 2),
P AS (
    SELECT n.PkgNo, n.Id AS NearId, f.Id AS FarId, n.CustomerId, LTRIM(RTRIM(n.CcyPair)) AS CcyPair, n.LogicalReference AS NearRef,
           n.BuyCcy, n.BuyAmount, n.SellCcy, n.SellAmount, n.BuyAmountOunce, n.SellAmountOunce, n.BuyAmountGram, n.SellAmountGram,
           CAST(n.DealRateNet AS float) AS NearRate, CAST(f.DealRateNet AS float) AS FarRate,
           CAST(n.ValueDate AS date) AS NearDate, CAST(f.ValueDate AS date) AS FarDate,
           COUNT(*) OVER () AS JoinCnt,
           ROW_NUMBER() OVER (PARTITION BY n.PkgNo ORDER BY n.Id DESC, f.Id DESC) AS Rn
    FROM N n JOIN F f ON f.PkgNo = n.PkgNo
    WHERE n.PkgNo <> 0
),
M AS (
    SELECT p.*, CASE WHEN UPPER(p.BuyCcy) = UPPER(CASE WHEN CHARINDEX('/', p.CcyPair) > 1 THEN LTRIM(RTRIM(LEFT(p.CcyPair, CHARINDEX('/', p.CcyPair) - 1)))
                                     WHEN LEN(p.CcyPair) >= 6 THEN LEFT(p.CcyPair, 3) ELSE p.BuyCcy END) THEN 1 ELSE 0 END AS BaseBought
    FROM P p WHERE p.Rn = 1
),
C AS (
    SELECT m.*, CASE WHEN BaseBought = 1 THEN 'B/S' ELSE 'S/B' END AS Direction,
           CAST(CASE WHEN BaseBought = 1 THEN SellAmount ELSE BuyAmount END AS float) AS NB,
           CASE WHEN BaseBought = 1 THEN SellCcy ELSE BuyCcy END AS NBCcy,
           CAST(ISNULL(CASE WHEN BaseBought = 1 THEN BuyAmountOunce ELSE SellAmountOunce END, 0) AS float) AS Ounce, CAST(ISNULL(CASE WHEN BaseBought = 1 THEN BuyAmountGram ELSE SellAmountGram END, 0) AS float) AS Gram,
           CASE WHEN NearRate = 0 THEN 0 ELSE (FarRate - NearRate) / NearRate * (360.0 / CASE WHEN DATEDIFF(day, NearDate, FarDate) = 0 THEN 1 ELSE DATEDIFF(day, NearDate, FarDate) END) * 100 END AS SR
    FROM M m
)
SELECT TOP (20) MAX(c.NearId) AS MaxNearId, CAST(cu.Name AS nvarchar(200)) AS CounterpartyName, UPPER(c.CcyPair) AS CcyPair, c.Direction, c.NearDate, c.FarDate,
       DATEDIFF(day, c.NearDate, c.FarDate) AS Tenor,
       CASE WHEN c.FarDate < @LD THEN 0 ELSE DATEDIFF(day, @LD, c.FarDate) END AS DaysToMaturity,
       ROUND(SUM(c.NB), 2) AS TotalAmount, MAX(c.NBCcy) AS TotalAmountCcy,
       CASE WHEN SUM(c.NB) <> 0 THEN SUM(c.NB * c.SR) / SUM(c.NB) ELSE AVG(c.SR) END AS SwapRate,
       MAX(c.SellCcy) AS SoldCcy, ROUND(SUM(c.SellAmount), 2) AS SoldAmount, MAX(c.BuyCcy) AS BoughtCcy, ROUND(SUM(c.BuyAmount), 2) AS BoughtAmount,
       ROUND(SUM(c.Ounce), 2) AS Ounce, ROUND(SUM(c.Gram), 2) AS Gram,
       COUNT(*) AS TxnCount, STRING_AGG(c.NearRef, ', ') AS Refs,
       MAX(c.JoinCnt) AS JoinCnt, (SELECT COUNT(*) FROM M) AS PkgCnt
FROM C c
LEFT JOIN CusCustomer cu ON cu.Id = c.CustomerId
GROUP BY c.CustomerId, cu.Name, UPPER(c.CcyPair), c.Direction, c.NearDate, c.FarDate
ORDER BY MaxNearId DESC;
```

DB: `NetTrexFX` · Server: `tcp:192.168.10.211,1433` · User: `trusr` · Pass: `***`


## #133

**Amaç:** IL testinde başlık faizi NULL/0 olan iki kredide ekrandaki Getiri Oranı nakit akışının ilk faiz döneminden geliyor (0.539 ve 61.77). 4 günlük 20.000 TL'ye 107,84 faiz yıllık ~%49 eder; TxnCashFlow.Rate yıllık oran mı dönem oranı mı?

```sql
SET NOCOUNT ON;
SELECT TOP (20) cf.Id, cf.TxnId, cf.FlowTypeId, CAST(cf.StartDate AS date) AS StartDate, CAST(cf.EndDate AS date) AS EndDate,
       cf.Rate, cf.CashFlowAmount, l.Rate AS HeaderRate, l.PrincipalAmount, l.BasisCode
FROM TxnCashFlow cf
JOIN TxnLoan l ON l.Id = cf.TxnId
WHERE cf.TxnId IN (1201146, 1201136) AND cf.FlowTypeId = 2
ORDER BY cf.Id DESC;
```

DB: `NetTrexMM` · Server: `tcp:192.168.10.211,1433` · User: `trusr` · Pass: `***`


## #134

**Amaç:** #133 tekrarı (TxnLoan'da BasisCode kolonu yok, çıkarıldı).

```sql
SET NOCOUNT ON;
SELECT TOP (20) cf.Id, cf.TxnId, cf.FlowTypeId, CAST(cf.StartDate AS date) AS StartDate, CAST(cf.EndDate AS date) AS EndDate,
       cf.Rate, cf.CashFlowAmount, l.Rate AS HeaderRate, l.PrincipalAmount
FROM TxnCashFlow cf
JOIN TxnLoan l ON l.Id = cf.TxnId
WHERE cf.TxnId IN (1201146, 1201136) AND cf.FlowTypeId = 2
ORDER BY cf.Id DESC;
```

DB: `NetTrexMM` · Server: `tcp:192.168.10.211,1433` · User: `trusr` · Pass: `***`


## #135

**Amaç:** Swap bacaklari: InstrumentId/PkgNo/TradeDate/ValueDate (FX swap)

```sql
SET NOCOUNT ON; SELECT TOP (20) Id, LogicalReference, InstrumentId, PkgNo, TradeDate, ValueDate, StateId FROM TxnSwap ORDER BY Id DESC;
```

DB: `NetTrexFX` · Server: `tcp:192.168.10.211,1433` · User: `trusr` · Pass: `***`


## #136

**Amaç:** Swap bacaklari: InstrumentId/PkgNo/TradeDate/ValueDate (PM swap)

```sql
SET NOCOUNT ON; SELECT TOP (20) Id, LogicalReference, InstrumentId, PkgNo, TradeDate, ValueDate, StateId FROM TxnPmSwap ORDER BY Id DESC;
```

DB: `NetTrexFX` · Server: `tcp:192.168.10.211,1433` · User: `trusr` · Pass: `***`


## #137

**Amaç:** Rerun #135: FX swap bacaklari, dogru tablo adi TxnFXSwap

```sql
SET NOCOUNT ON; SELECT TOP (12) Id, LogicalReference, InstrumentId, PkgNo, TradeDate, ValueDate, StateId FROM TxnFXSwap ORDER BY Id DESC;
```

DB: `NetTrexFX` · Server: `tcp:192.168.10.211,1433` · User: `trusr` · Pass: `***`


## #138

**Amaç:** ProductInstrument Id 1068/1069 adlari (DailyFlow adi kaynagi)

```sql
SET NOCOUNT ON; SELECT TOP (20) Id, Name FROM ProductInstrument WHERE Id IN (1068,1069) ORDER BY Id DESC;
```

DB: `NetTrexFX` · Server: `tcp:192.168.10.211,1433` · User: `trusr` · Pass: `***`


## #139

**Amaç:** FX swap StateId dagilimi: Active mask (FlowState) ile 6-maskesi farki var mi (GROUP BY, TOP 20 StateId DESC)

```sql
SET NOCOUNT ON; SELECT TOP (20) StateId, COUNT(*) AS Cnt FROM TxnFXSwap WHERE InstrumentId IN (1068,1069) GROUP BY StateId ORDER BY StateId DESC;
```

DB: `NetTrexFX` · Server: `tcp:192.168.10.211,1433` · User: `trusr` · Pass: `***`


## #140

**Amaç:** PM swap StateId dagilimi (ayni amac)

```sql
SET NOCOUNT ON; SELECT TOP (20) StateId, COUNT(*) AS Cnt FROM TxnPmSwap WHERE InstrumentId IN (1068,1069) GROUP BY StateId ORDER BY StateId DESC;
```

DB: `NetTrexFX` · Server: `tcp:192.168.10.211,1433` · User: `trusr` · Pass: `***`


## #141

**Amaç:** Rerun #138: prdInstrument Id 1068/1069 adlari (dogru tablo adi prdInstrument)

```sql
SET NOCOUNT ON; SELECT TOP (20) Id, Code, Name FROM prdInstrument WHERE Id IN (1068,1069) ORDER BY Id DESC;
```

DB: `NetTrexFX` · Server: `tcp:192.168.10.211,1433` · User: `trusr` · Pass: `***`


## #142

**Amaç:** Ekran testi — TxnFXSwap'in TUM bacaklari (aktif + silinmis/onaysiz) ham haliyle; beklenen sonucu DB'den bagimsiz hesaplamak icin. #139'a gore toplam 22 satir, TOP (50) hepsini kapsar.

```sql
SET NOCOUNT ON; SELECT TOP (50) Id, LogicalReference, PkgNo, InstrumentId, CustomerId, CcyPair, BuyCcy, BuyAmount, SellCcy, SellAmount, DealRateNet, ValueDate, StateId FROM TxnFXSwap WHERE InstrumentId IN (1068,1069) ORDER BY Id DESC;
```

DB: `NetTrexFX` · Server: `tcp:192.168.10.211,1433` · User: `trusr` · Pass: `***`


## #143

**Amaç:** Ekran testi — TxnPmSwap'in TUM bacaklari (#140'a gore 28 satir, TOP (50) kapsar).

```sql
SET NOCOUNT ON; SELECT TOP (50) Id, LogicalReference, PkgNo, InstrumentId, CustomerId, CcyPair, BuyCcy, BuyAmount, SellCcy, SellAmount, DealRateNet, ValueDate, StateId FROM TxnPmSwap WHERE InstrumentId IN (1068,1069) ORDER BY Id DESC;
```

DB: `NetTrexFX` · Server: `tcp:192.168.10.211,1433` · User: `trusr` · Pass: `***`


## #144

**Amaç:** Ekran testi — swap musterisi (CustomerId 2095) adini dogrulamak icin musteri tablosunun adini bul.

```sql
SET NOCOUNT ON; SELECT TOP (20) name FROM sys.tables WHERE name LIKE '%Customer%' ORDER BY name;
```

DB: `NetTrexFX` · Server: `tcp:192.168.10.211,1433` · User: `trusr` · Pass: `***`


## #145

**Amaç:** Ekran testi — CusCustomer'da Id 2095 adi (ekrandaki "...ank A.S." tam adini dogrula).

```sql
SET NOCOUNT ON; SELECT TOP (20) Id, Name FROM CusCustomer WHERE Id = 2095 ORDER BY Id DESC;
```

DB: `NetTrexFX` · Server: `tcp:192.168.10.211,1433` · User: `trusr` · Pass: `***`


## #146

**Amaç:** Ekran testi — mantiksal tarih (`Trex:FxLogicalDate`) DB'de hangi tabloda, DaysToMaturity dogrulamasi icin.

```sql
SET NOCOUNT ON; SELECT TOP (20) name FROM sys.tables WHERE name LIKE '%Parameter%' ORDER BY name;
```

DB: `NetTrexFX` · Server: `tcp:192.168.10.211,1433` · User: `trusr` · Pass: `***`


## #147

**Amaç:** `Trex:FxLogicalDate` parametresinin DB degeri (API'nin kullandigi 06.10.2026 ile uyumlu mu).

```sql
SET NOCOUNT ON; SELECT TOP (20) Id, [Key], [Value] FROM FrameworkParameter WHERE [Key] = 'Trex:FxLogicalDate' ORDER BY Id DESC;
```

DB: `NetTrexFX` · Server: `tcp:192.168.10.211,1433` · User: `trusr` · Pass: `***`


## #148

**Amaç:** Rerun #147 oncesi FrameworkParameter kolon adlarini bul.

```sql
SET NOCOUNT ON; SELECT TOP (20) c.name FROM sys.columns c WHERE c.object_id = OBJECT_ID('dbo.FrameworkParameter') ORDER BY c.column_id;
```

DB: `NetTrexFX` · Server: `tcp:192.168.10.211,1433` · User: `trusr` · Pass: `***`


## #149

**Amaç:** Rerun #147 — FX mantiksal tarih parametresi degeri (OptionName 'FxLogicalDate' civari).

```sql
SET NOCOUNT ON; SELECT TOP (20) Id, OptionPath, OptionName, Value, StateDate FROM FrameworkParameter WHERE OptionName LIKE '%LogicalDate%' ORDER BY Id DESC;
```

DB: `NetTrexFX` · Server: `tcp:192.168.10.211,1433` · User: `trusr` · Pass: `***`
