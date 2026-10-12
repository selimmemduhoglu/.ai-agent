/* =====================================================================================
   DerivSwp — Getiri Egrisi (Interest Rate) Backfill
   DB      : NetTrexDerivSWP
   Amac    : Manuel Reeskont / EOD Revaluation testleri icin eksik gunlerin getiri
             egrisini, var olan saglam bir gunu KLONLAYARAK uretmek.
   Neden   : InterestRateDetailRepository.GetListByFilter -> "YieldDate == calculateDate.Date"
             TAM esitlik arar, onceki gune DUSMEZ. O gun egri yoksa liste bos doner ve
             TotalNpvStep "interestRateDetailList is null" firlatir.

   GUVENLIK
   - Tek transaction; hata olursa tamami geri alinir.
   - Idempotent: hedef tarihte zaten baslik varsa o gun ATLANIR, ikinci kez calistirilabilir.
   - Sadece @ChartId'ye dokunur; baska chart'a, baska tabloya yazmaz.
   - InterestRate.Id ve InterestRateDetail.Id IDENTITY DEGILDIR -> script MAX(Id)+1 uretir.
     DefNumberGen'de bu tablolar icin sayac YOKTUR (kontrol edildi), numarator bozulmaz.

   KULLANIM: asagidaki degiskenleri ayarla, calistir.
   ===================================================================================== */

SET NOCOUNT ON;
SET XACT_ABORT ON;

-------------------------------------------------------------------------------
-- 1) PARAMETRELER
-------------------------------------------------------------------------------
DECLARE @ChartId          int          = 7;              -- DerivSwp islemlerinin ReceiveIndexChartId / PayIndexChartId degeri
DECLARE @SourceYieldDate  date         = '2026-09-15';   -- KLONLANACAK saglam gun (78 detay: TRY+EUR+USD)
DECLARE @FromDate         date         = '2026-06-29';   -- doldurulacak ilk gun
DECLARE @ToDate           date         = '2026-09-14';   -- doldurulacak son gun
DECLARE @IncludeWeekends  bit          = 1;              -- 1 = hafta sonu dahil (EOD hafta sonu da kosuyor), 0 = sadece hafta ici
DECLARE @StateId          int          = 18;             -- 18 = InputVerified — SORGU BU DURUMU ARAR, degistirme
DECLARE @StateMaker       nvarchar(160)= N'SCRIPT.BACKFILL@TEST';
DECLARE @Description      nvarchar(500)= N'Test backfill - klonlandi: ';

-------------------------------------------------------------------------------
-- 2) ON KONTROL — kaynak gun gercekten dolu mu
-------------------------------------------------------------------------------
DECLARE @SourceRateId int, @SourceDetailCount int;

SELECT @SourceRateId = ir.Id
FROM InterestRate ir
WHERE ir.ChartId = @ChartId AND ir.YieldDate = @SourceYieldDate;

IF @SourceRateId IS NULL
BEGIN
    DECLARE @SrcText nvarchar(20) = CONVERT(nvarchar(10), @SourceYieldDate, 120);
    RAISERROR(N'Kaynak gun bulunamadi: ChartId=%d, YieldDate=%s. @SourceYieldDate degerini duzelt.',
              16, 1, @ChartId, @SrcText);
    RETURN;
END

SELECT @SourceDetailCount = COUNT(1) FROM InterestRateDetail WHERE InterestRateId = @SourceRateId;

IF @SourceDetailCount = 0
BEGIN
    RAISERROR(N'Kaynak gunun detayi yok (InterestRateId=%d). Baska bir gun sec.', 16, 1, @SourceRateId);
    RETURN;
END

PRINT N'Kaynak: InterestRateId=' + CAST(@SourceRateId AS nvarchar(20))
    + N', detay sayisi=' + CAST(@SourceDetailCount AS nvarchar(20));

-------------------------------------------------------------------------------
-- 3) HEDEF TARIH LISTESI — zaten dolu olan gunler haric
-------------------------------------------------------------------------------
IF OBJECT_ID('tempdb..#Targets') IS NOT NULL DROP TABLE #Targets;

;WITH Dates AS (
    SELECT CAST(@FromDate AS date) AS D
    UNION ALL
    SELECT DATEADD(DAY, 1, D) FROM Dates WHERE D < @ToDate
)
SELECT D AS YieldDate
INTO #Targets
FROM Dates
-- Hafta sonu testi DATEFIRST'ten BAGIMSIZ: 1905-01-01 Pazar -> 0=Pazar, 6=Cumartesi
WHERE (@IncludeWeekends = 1 OR DATEDIFF(DAY, '19050101', D) % 7 NOT IN (0, 6))
OPTION (MAXRECURSION 0);

-- zaten baslik olan gunleri cikar (idempotent)
DELETE t
FROM #Targets t
WHERE EXISTS (SELECT 1 FROM InterestRate ir
              WHERE ir.ChartId = @ChartId AND ir.YieldDate = t.YieldDate);

DECLARE @TargetCount int = (SELECT COUNT(1) FROM #Targets);
PRINT N'Eklenecek gun sayisi: ' + CAST(@TargetCount AS nvarchar(20));

IF @TargetCount = 0
BEGIN
    PRINT N'Yapilacak is yok — istenen araligin tamami zaten dolu.';
    DROP TABLE #Targets;
    RETURN;
END

-------------------------------------------------------------------------------
-- 4) YAZMA
-------------------------------------------------------------------------------
BEGIN TRANSACTION;

BEGIN TRY

    ---------------------------------------------------------------------------
    -- 4a) Basliklar
    ---------------------------------------------------------------------------
    DECLARE @NextRateId int = (SELECT ISNULL(MAX(Id), 0) + 1 FROM InterestRate);

    IF OBJECT_ID('tempdb..#NewHeaders') IS NOT NULL DROP TABLE #NewHeaders;

    SELECT
        NewRateId = @NextRateId + ROW_NUMBER() OVER (ORDER BY t.YieldDate) - 1,
        t.YieldDate
    INTO #NewHeaders
    FROM #Targets t;

    INSERT INTO InterestRate (Id, ChartId, YieldDate, Description, StateId, StateMaker, StateDate)
    SELECT
        h.NewRateId,
        @ChartId,
        h.YieldDate,
        @Description + CONVERT(nvarchar(10), @SourceYieldDate, 120),
        @StateId,
        @StateMaker,
        GETDATE()
    FROM #NewHeaders h;

    PRINT N'Eklenen baslik: ' + CAST(@@ROWCOUNT AS nvarchar(20));

    ---------------------------------------------------------------------------
    -- 4b) Detaylar — kaynak gunun satirlari birebir klonlanir
    --     PointDate kaynakta sabit '1900-01-01' (kullanilmayan alan), aynen tasinir.
    ---------------------------------------------------------------------------
    DECLARE @NextDetailId int = (SELECT ISNULL(MAX(Id), 0) + 1 FROM InterestRateDetail);

    INSERT INTO InterestRateDetail
        (Id, InterestRateId, PointId, PointDate, AskRate, BidRate, MidRate, Source, Ccy, SymbolName, LastUpdate)
    SELECT
        @NextDetailId + ROW_NUMBER() OVER (ORDER BY h.NewRateId, s.Id) - 1,
        h.NewRateId,
        s.PointId,
        s.PointDate,
        s.AskRate,
        s.BidRate,
        s.MidRate,
        s.Source,
        s.Ccy,
        s.SymbolName,
        GETDATE()
    FROM #NewHeaders h
    CROSS JOIN InterestRateDetail s
    WHERE s.InterestRateId = @SourceRateId;

    PRINT N'Eklenen detay: ' + CAST(@@ROWCOUNT AS nvarchar(20));

    COMMIT TRANSACTION;
    PRINT N'TAMAM — commit edildi.';

END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    PRINT N'HATA — geri alindi: ' + ERROR_MESSAGE();
    THROW;
END CATCH

IF OBJECT_ID('tempdb..#NewHeaders') IS NOT NULL DROP TABLE #NewHeaders;
IF OBJECT_ID('tempdb..#Targets')    IS NOT NULL DROP TABLE #Targets;
