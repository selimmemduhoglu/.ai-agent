/* =====================================================================================
   GERI ALMA — 01-backfill-interest-rate.sql'in ekledigi satirlari siler.
   🔴 SADECE TEST ORTAMINDA. Prod'da calistirma.

   Guvenlik: yalnizca @StateMaker damgasi script'e ait olan satirlari siler. Gercek
   market data yukleyicisinin urettigi satirlarda bu damga YOKTUR, onlara dokunulmaz.
   ===================================================================================== */

SET NOCOUNT ON;
SET XACT_ABORT ON;

DECLARE @ChartId    int           = 7;
DECLARE @StateMaker nvarchar(160) = N'SCRIPT.BACKFILL@TEST';   -- 01 numarali script ile AYNI olmali

-------------------------------------------------------------------------------
-- 1) Once ne silinecegini GOSTER (silme yok)
-------------------------------------------------------------------------------
PRINT N'--- silinecek basliklar ---';

SELECT ir.Id, ir.ChartId, ir.YieldDate, ir.StateMaker,
       DetailCount = (SELECT COUNT(1) FROM InterestRateDetail d WHERE d.InterestRateId = ir.Id)
FROM InterestRate ir
WHERE ir.ChartId = @ChartId AND ir.StateMaker = @StateMaker
ORDER BY ir.YieldDate;

-------------------------------------------------------------------------------
-- 2) SILME — yukaridaki listeyi kontrol ettikten SONRA bu blogu ac
-------------------------------------------------------------------------------
/*
BEGIN TRANSACTION;

BEGIN TRY

    DELETE d
    FROM InterestRateDetail d
    JOIN InterestRate ir ON ir.Id = d.InterestRateId
    WHERE ir.ChartId = @ChartId AND ir.StateMaker = @StateMaker;

    PRINT N'Silinen detay: ' + CAST(@@ROWCOUNT AS nvarchar(20));

    DELETE FROM InterestRate
    WHERE ChartId = @ChartId AND StateMaker = @StateMaker;

    PRINT N'Silinen baslik: ' + CAST(@@ROWCOUNT AS nvarchar(20));

    COMMIT TRANSACTION;
    PRINT N'TAMAM — commit edildi.';

END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    PRINT N'HATA — geri alindi: ' + ERROR_MESSAGE();
    THROW;
END CATCH
*/
