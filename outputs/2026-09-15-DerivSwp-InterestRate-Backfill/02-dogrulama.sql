/* =====================================================================================
   DOGRULAMA — salt okunur. Backfill'den ONCE ve SONRA calistir, ciktilari karsilastir.
   ===================================================================================== */

SET NOCOUNT ON;

DECLARE @ChartId int  = 7;
DECLARE @From    date = '2026-06-29';
DECLARE @To      date = '2026-09-16';

-------------------------------------------------------------------------------
-- D-1) Gun bazinda doluluk — bos gun kaldi mi
-------------------------------------------------------------------------------
PRINT N'--- D-1: gun bazinda detay sayisi ---';

SELECT
    ir.YieldDate,
    ir.Id                AS RateId,
    ir.StateId,
    DetailCount          = (SELECT COUNT(1) FROM InterestRateDetail d WHERE d.InterestRateId = ir.Id),
    CcyList              = STUFF((SELECT DISTINCT N', ' + d2.Ccy
                                  FROM InterestRateDetail d2
                                  WHERE d2.InterestRateId = ir.Id
                                  FOR XML PATH('')), 1, 2, '')
FROM InterestRate ir
WHERE ir.ChartId = @ChartId
  AND ir.YieldDate BETWEEN @From AND @To
ORDER BY ir.YieldDate;

-------------------------------------------------------------------------------
-- D-2) Hala EKSIK olan gunler
-------------------------------------------------------------------------------
PRINT N'--- D-2: hala eksik gunler ---';

;WITH Dates AS (
    SELECT CAST(@From AS date) AS D
    UNION ALL SELECT DATEADD(DAY, 1, D) FROM Dates WHERE D < @To
)
SELECT D AS MissingYieldDate
FROM Dates
WHERE NOT EXISTS (SELECT 1 FROM InterestRate ir
                  WHERE ir.ChartId = @ChartId AND ir.YieldDate = D)
ORDER BY D
OPTION (MAXRECURSION 0);

-------------------------------------------------------------------------------
-- D-3) Para birimi bazinda ilk/son tarih
-------------------------------------------------------------------------------
PRINT N'--- D-3: para birimi kirilimi ---';

SELECT
    d.Ccy,
    PointCount  = COUNT(DISTINCT d.PointId),
    DetailCount = COUNT(d.Id),
    FirstYield  = MIN(ir.YieldDate),
    LastYield   = MAX(ir.YieldDate)
FROM InterestRateDetail d
JOIN InterestRate ir ON ir.Id = d.InterestRateId
WHERE ir.ChartId = @ChartId
GROUP BY d.Ccy
ORDER BY d.Ccy;

-------------------------------------------------------------------------------
-- D-4) Id cakismasi var mi (script MAX+1 uretiyor — kontrol)
-------------------------------------------------------------------------------
PRINT N'--- D-4: mukerrer Id kontrolu (bos donmeli) ---';

SELECT Id, COUNT(1) AS Adet FROM InterestRate       GROUP BY Id HAVING COUNT(1) > 1;
SELECT Id, COUNT(1) AS Adet FROM InterestRateDetail GROUP BY Id HAVING COUNT(1) > 1;

-------------------------------------------------------------------------------
-- D-5) Ayni gun icin mukerrer baslik (ChartId + YieldDate) — bos donmeli
-------------------------------------------------------------------------------
PRINT N'--- D-5: ayni chart+gun icin cift baslik (bos donmeli) ---';

SELECT ChartId, YieldDate, COUNT(1) AS Adet
FROM InterestRate
GROUP BY ChartId, YieldDate
HAVING COUNT(1) > 1;

-------------------------------------------------------------------------------
-- D-6) Reeskont testinde kullanilacak islemler — hangi chart/ccy ikilisini istiyorlar
-------------------------------------------------------------------------------
PRINT N'--- D-6: acik DerivSwp islemlerinin chart/ccy ihtiyaci ---';

SELECT TOP (50)
    t.LogicalReference,
    t.ReceiveCurrency, t.ReceiveIndexChartId,
    t.PayCurrency,     t.PayIndexChartId,
    t.ReceiveValueDate, t.ReceiveMaturityDate
FROM TxnTransaction t
WHERE t.ReceiveMaturityDate > @To
ORDER BY t.Id DESC;
