# SQL Sorgu Kaydı — mm-revaluation-report-manuel-kayit

> Bağlantı: `sqlcmd -S "tcp:192.168.10.211,1433" -d NetTrexMM -U trusr -P '***' -C -l 20 -W -s "|"`
> Amaç (sohbet): MmRevaluationReport ekranına manuel reeskont satırı eklemek için `txnMmDailyCalculation` fiziksel şemasını doğrulamak.

## #1 — Kolonlar + Identity
Amaç: `Id` gerçekten IDENTITY mi, kolon tipleri/nullable EF config ile aynı mı.
```sql
SET NOCOUNT ON;
SELECT c.name, t.name AS type, c.precision, c.scale, c.is_nullable, c.is_identity
FROM sys.columns c JOIN sys.types t ON t.user_type_id = c.user_type_id
WHERE c.object_id = OBJECT_ID('dbo.txnMmDailyCalculation') ORDER BY c.column_id;
```

## #2 — Foreign key + trigger + default constraint
Amaç: `AccEntryMainId` / `TxnMmId` için fiziksel FK var mı (insert'te accEntryMain satırı zorunlu mu), tabloda trigger var mı.
```sql
SET NOCOUNT ON;
SELECT TOP (20) fk.name, COL_NAME(fkc.parent_object_id, fkc.parent_column_id) AS col, OBJECT_NAME(fk.referenced_object_id) AS ref_table, fk.is_disabled
FROM sys.foreign_keys fk JOIN sys.foreign_key_columns fkc ON fkc.constraint_object_id = fk.object_id
WHERE fk.parent_object_id = OBJECT_ID('dbo.txnMmDailyCalculation') ORDER BY fk.name;
SELECT TOP (20) name, is_disabled FROM sys.triggers WHERE parent_id = OBJECT_ID('dbo.txnMmDailyCalculation') ORDER BY name;
SELECT TOP (20) i.name, i.is_unique, i.is_primary_key FROM sys.indexes i WHERE i.object_id = OBJECT_ID('dbo.txnMmDailyCalculation') ORDER BY i.index_id;
```

## #3 — Örnek satırlar (TRY ve döviz)
Amaç: `State`, `FXRate`, `AccrualAmountLCY`, `GenerationDate` gerçekte nasıl doluyor.
```sql
SET NOCOUNT ON;
SELECT TOP (10) Id, CalculationDate, GenerationDate, State, TxnMmId, PeriodId, AccrualDay, AccrualAmount, AccrualAmountSL, AccrualAmountIRR, AccrualAmountLCY, AccEntryMainId, Ccy, FXRate, BaseAmount
FROM dbo.txnMmDailyCalculation ORDER BY Id DESC;
SELECT Ccy, COUNT(*) AS Adet, SUM(CASE WHEN FXRate IS NULL THEN 1 ELSE 0 END) AS FxNull, SUM(CASE WHEN AccEntryMainId = 0 THEN 1 ELSE 0 END) AS AccMain0
FROM dbo.txnMmDailyCalculation GROUP BY Ccy ORDER BY Adet DESC;
```

## #4 — Döviz (USD) örnek satırları
Amaç: döviz işlemde `FXRate` / `AccrualAmountLCY` ilişkisi (çarpım mı bölüm mü) gerçek veride nasıl.
```sql
SET NOCOUNT ON;
SELECT TOP (5) Id, CalculationDate, TxnMmId, PeriodId, AccrualDay, AccrualAmount, AccrualAmountSL, AccrualAmountIRR, AccrualAmountLCY, AccEntryMainId, Ccy, FXRate, BaseAmount
FROM dbo.txnMmDailyCalculation WHERE Ccy = 'USD' ORDER BY Id DESC;
```

## #5 — Müşteri SELECT script'inin dev DB'de sözdizimi doğrulaması
Amaç: müşteriye gidecek `NetTrex.MM/.ai-agent/outputs/2026-10-09-MmRevaluationReport-Manuel-Kayit/1-SELECT-Musteriden-Istenecek.sql`
dosyasının kolon/tablo adlarının doğru olduğunu görmek. Dosya **aynen** koşuldu; yalnız `USE` satırı çıkarıldı ve
`@LogicalReference` dev işlemi `TxnMM.Id = 553400`'ün referansı, `@CalcDate = 2026-10-01` yapıldı. Yalnız SELECT.

## #6 — INSERT script'inin HESAP kısmı, dev işlem 553400 @2026-10-01 (insert yok, yalnız DECLARE/SELECT)
Amaç: SQL formülü engine'in yazdığı 95.89 / 95.35 ile birebir mi.
```sql
SET NOCOUNT ON; DECLARE @CalcDate DATE='2026-10-01', @TxnId BIGINT=553400; DECLARE @DealAmount DECIMAL(28,10), @DaysInYear INT, @Method INT, @PeriodStart DATE, @PeriodEnd DATE, @Rate DECIMAL(28,10); SELECT @DealAmount=m.DealAmount, @DaysInYear=m.DaysInYear, @Method=p.AccountingCalculationMethodTypeId FROM dbo.TxnMM m JOIN dbo.prdProductDefinition p ON p.Id=m.TxnMmProductTypeId WHERE m.Id=@TxnId; SELECT TOP (1) @PeriodStart=d.PeriodStartDate, @PeriodEnd=d.PeriodEndDate, @Rate=d.InterestRate FROM dbo.txnMMDetail d WHERE d.TxnId=@TxnId AND d.IsPrincipalAmount=0 AND d.PeriodStartDate<=@CalcDate AND d.PeriodEndDate>@CalcDate ORDER BY d.PeriodStartDate; DECLARE @PassedDay INT=DATEDIFF(DAY,@PeriodStart,@CalcDate)+1; DECLARE @AccrualDay INT=DATEDIFF(DAY,@PeriodStart,@PeriodEnd); DECLARE @SL DECIMAL(36,18)=ROUND(@DealAmount*@Rate*@PassedDay/(@DaysInYear*100.0),2); DECLARE @IRR DECIMAL(36,18)=ROUND(CAST((POWER(CAST(1+@Rate*@AccrualDay/(@DaysInYear*100.0) AS FLOAT),CAST(@PassedDay AS FLOAT)/@AccrualDay)-1) AS DECIMAL(38,18))*@DealAmount,2); SELECT @PassedDay AS PassedDay, @AccrualDay AS AccrualDay, @SL AS SL, @IRR AS IRR, @Method AS Method;
```

## #7 — Aynı hesap, müşteri işleminin ekran değerleri literal (tabloya dokunmaz)
Amaç: 1e9 tutarda SQL decimal/float hesabı 27554794.52 / 26534306.89 veriyor mu.
```sql
SET NOCOUNT ON; DECLARE @CalcDate DATE='2026-09-30', @DealAmount DECIMAL(28,10)=1000000000, @DaysInYear INT=365, @PeriodStart DATE='2026-09-04', @PeriodEnd DATE='2026-12-17', @Rate DECIMAL(28,10)=37.25; DECLARE @PassedDay INT=DATEDIFF(DAY,@PeriodStart,@CalcDate)+1; DECLARE @AccrualDay INT=DATEDIFF(DAY,@PeriodStart,@PeriodEnd); DECLARE @SL DECIMAL(36,18)=ROUND(@DealAmount*@Rate*@PassedDay/(@DaysInYear*100.0),2); DECLARE @IRR DECIMAL(36,18)=ROUND(CAST((POWER(CAST(1+@Rate*@AccrualDay/(@DaysInYear*100.0) AS FLOAT),CAST(@PassedDay AS FLOAT)/@AccrualDay)-1) AS DECIMAL(38,18))*@DealAmount,2); SELECT @PassedDay AS PassedDay, @AccrualDay AS AccrualDay, @SL AS SL, @IRR AS IRR;
```

## #8 — #6 ve #7 tekrar, IRR tabanı FLOAT ile (decimal bölme scale 6'ya kırpıyordu: #7 IRR 26534305.37 ≠ beklenen 26534306.89)
```sql
SET NOCOUNT ON; DECLARE @CalcDate DATE='2026-10-01', @TxnId BIGINT=553400; DECLARE @DealAmount DECIMAL(28,10), @DaysInYear INT, @PeriodStart DATE, @PeriodEnd DATE, @Rate DECIMAL(28,10); SELECT @DealAmount=m.DealAmount, @DaysInYear=m.DaysInYear FROM dbo.TxnMM m WHERE m.Id=@TxnId; SELECT TOP (1) @PeriodStart=d.PeriodStartDate, @PeriodEnd=d.PeriodEndDate, @Rate=d.InterestRate FROM dbo.txnMMDetail d WHERE d.TxnId=@TxnId AND d.IsPrincipalAmount=0 AND d.PeriodStartDate<=@CalcDate AND d.PeriodEndDate>@CalcDate ORDER BY d.PeriodStartDate; DECLARE @PassedDay INT=DATEDIFF(DAY,@PeriodStart,@CalcDate)+1; DECLARE @AccrualDay INT=DATEDIFF(DAY,@PeriodStart,@PeriodEnd); SELECT ROUND(CAST((POWER(1 + CAST(@Rate AS FLOAT) * @AccrualDay / (@DaysInYear * 100.0), CAST(@PassedDay AS FLOAT) / @AccrualDay) - 1) AS DECIMAL(38,18)) * @DealAmount, 2) AS IRR;

SET NOCOUNT ON; DECLARE @CalcDate DATE='2026-09-30', @DealAmount DECIMAL(28,10)=1000000000, @DaysInYear INT=365, @PeriodStart DATE='2026-09-04', @PeriodEnd DATE='2026-12-17', @Rate DECIMAL(28,10)=37.25; DECLARE @PassedDay INT=DATEDIFF(DAY,@PeriodStart,@CalcDate)+1; DECLARE @AccrualDay INT=DATEDIFF(DAY,@PeriodStart,@PeriodEnd); SELECT ROUND(CAST((POWER(1 + CAST(@Rate AS FLOAT) * @AccrualDay / (@DaysInYear * 100.0), CAST(@PassedDay AS FLOAT) / @AccrualDay) - 1) AS DECIMAL(38,18)) * @DealAmount, 2) AS IRR;
```

## #9 — Revize `0-DOGRULAMA-Musteri-Verisi.sql` (10 sonuç seti) dev DB'de sözdizimi doğrulaması
Amaç: müşteriye gidecek son hâlin tablo/kolon adları (`StateId`, `BasisCode`, `defTxnType`, `cusCustomer` dahil) doğru mu.
Dosya aynen koşuldu; yalnız `USE` satırı çıkarıldı, `@LogicalReference = 'TMMBRW2609280003'` (dev, TxnMM.Id 553400),
`@CalcDate = '2026-10-01'`. Yalnız SELECT (sys.* + tablo okumaları).

## #10 — `0-ON-KONTROL-Batch-Yeniden-Kosum.sql` dev DB'de sözdizimi doğrulaması
Amaç: batch seçim sorgularının ([A] GetPendingRevaluationTransactions(30.09), [B] GetPendingRevaluationReverseTransactions(01.10))
SQL karşılığının kolon/tablo adları doğru mu; dev'de 30.09/01.10 için kaç aday dönüyor. Dosya aynen koşuldu, yalnız `USE` satırı çıkarıldı.
Yalnız SELECT.

## #11 — Batch log: Revaluation/Reverse aday sayıları + accEntryMain.ValueDate tipi + aynı güne mükerrer reeskont
Amaç: kullanıcı 'Reverse kapalı, Revaluation açık koşunca o günün tüm reeskontlarını kesiyor gibi' dedi. Log'daki N değerleri, ValueDate kolon tipi (saat taşıyor mu) ve aynı işleme aynı güne birden çok reeskont kesilmiş mi.
```sql
SET NOCOUNT ON;
SELECT TOP (30) Id, ExecDate, LogDate, LEFT(Message, 120) AS Message FROM dbo.BatchLogDetail WHERE Message LIKE 'Revaluation started for % transactions.' OR Message LIKE 'There is no record for Revaluation%' OR Message LIKE 'Revaluation Reverse started for % transactions.' OR Message LIKE 'There is no record for Revaluation Reverse%' ORDER BY Id DESC;
SELECT c.name, t.name AS type FROM sys.columns c JOIN sys.types t ON t.user_type_id = c.user_type_id WHERE c.object_id = OBJECT_ID('dbo.accEntryMain') AND c.name IN ('ValueDate');
SELECT TOP (20) a.ValueDate, COUNT(*) AS Fis, COUNT(DISTINCT a.TxnId) AS Islem FROM dbo.accEntryMain a WHERE a.Type = 2 AND a.IsReverse = 0 AND a.ProductCode = 'MM' GROUP BY a.ValueDate HAVING COUNT(*) > COUNT(DISTINCT a.TxnId) ORDER BY a.ValueDate DESC;
```

## #12 — 01.10 ikinci koşusunun (12:01) detay log'u + 30.09/01.10 valörlü tüm reeskont/ters fişler
Amaç: 'Revaluation started for 9' tekrar koşularında gerçekten fiş kesildi mi, yoksa hata alıp geri mi alındı.
```sql
SET NOCOUNT ON;
SELECT TOP (50) Id, LogDate, Status, LEFT(Message, 160) AS Message FROM dbo.BatchLogDetail WHERE Id BETWEEN 45124 AND 45140 ORDER BY Id DESC;
SELECT TOP (40) Id, TxnId, ValueDate, IsReverse, ReverseId, StateId, MessageKey, ExternalState, LEFT(BusinessKey, 20) AS BK FROM dbo.accEntryMain WHERE Type = 2 AND ValueDate IN ('2026-09-30','2026-10-01') ORDER BY Id DESC;
```
