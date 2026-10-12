/* ==================================================================================================
   9 - GERI AL -- NetTrexMM  --  Yuk testi klonlarini ve testte uretilen reeskont kayitlarini siler
   --------------------------------------------------------------------------------------------------
   Silinenler (yalniz @RefPrefix ile baslayan klon islemlere bagli satirlar):
     txnMmDailyCalculation -> accEngineGeneratedAccountRule -> accEntry -> accEntryMain
     -> txnMMDetail -> TxnMMHistory -> TxnMM
   SILINMEYENLER: Kafka ile NetTrexAcc'a gitmis muhasebe kopyalari, Fimple'a gitmis fisler
   (Fimple sync acikken test yapildiysa), DefNumberGen sayaclari (geri sarilmaz, bosluk kalir -- zararsiz).

   Idempotent: klon yoksa her adim 0 satir siler.
   !!! Canli/UAT'ta DEGIL, yalniz yuk testi ortaminda kosulmali.
   ================================================================================================== */

USE [NetTrexMM]   -- !!! ORTAMA GORE DEGISTIR
GO

SET NOCOUNT ON;
SET XACT_ABORT ON;

DECLARE @RefPrefix nvarchar(20) = N'TMMBRWYT';   -- 1 numarali script'teki ile AYNI olmali

BEGIN TRY
    BEGIN TRANSACTION;

    IF OBJECT_ID('tempdb..#Clones') IS NOT NULL DROP TABLE #Clones;
    SELECT Id INTO #Clones FROM dbo.TxnMM WHERE LogicalReference LIKE @RefPrefix + N'%';
    PRINT 'Klon islem: ' + CAST(@@ROWCOUNT AS varchar(10));

    IF OBJECT_ID('tempdb..#Mains') IS NOT NULL DROP TABLE #Mains;
    SELECT a.Id INTO #Mains FROM dbo.accEntryMain a JOIN #Clones c ON c.Id = a.TxnId;

    -- accEntryMain'e bagli (AccEntryMainId) -> once.
    DELETE d FROM dbo.txnMmDailyCalculation d JOIN #Clones c ON c.Id = d.TxnMmId;
    PRINT 'txnMmDailyCalculation silindi: ' + CAST(@@ROWCOUNT AS varchar(10));

    -- Motor satirlari accEntry.EngineId ile bagli.
    DELETE g FROM dbo.accEngineGeneratedAccountRule g
    WHERE g.Id IN (SELECT e.EngineId FROM dbo.accEntry e JOIN #Mains m ON m.Id = e.AccEntryMainId);
    PRINT 'accEngineGeneratedAccountRule silindi: ' + CAST(@@ROWCOUNT AS varchar(10));

    DELETE e FROM dbo.accEntry e JOIN #Mains m ON m.Id = e.AccEntryMainId;
    PRINT 'accEntry silindi: ' + CAST(@@ROWCOUNT AS varchar(10));

    -- ReverseId ciftleri tek ifadede silinir.
    DELETE a FROM dbo.accEntryMain a JOIN #Mains m ON m.Id = a.Id;
    PRINT 'accEntryMain silindi: ' + CAST(@@ROWCOUNT AS varchar(10));

    DELETE d FROM dbo.txnMMDetail d JOIN #Clones c ON c.Id = d.TxnId;
    PRINT 'txnMMDetail silindi: ' + CAST(@@ROWCOUNT AS varchar(10));

    IF OBJECT_ID(N'dbo.TxnMMHistory') IS NOT NULL
    BEGIN
        DELETE h FROM dbo.TxnMMHistory h JOIN #Clones c ON c.Id = h.Id;
        PRINT 'TxnMMHistory silindi: ' + CAST(@@ROWCOUNT AS varchar(10));
    END

    DELETE t FROM dbo.TxnMM t JOIN #Clones c ON c.Id = t.Id;
    PRINT 'TxnMM silindi: ' + CAST(@@ROWCOUNT AS varchar(10));

    COMMIT TRANSACTION;
    PRINT 'GERI ALMA BASARILI -- NetTrexMM';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    PRINT '*** HATA -- Script geri alindi. ***';
    PRINT 'Hata No    : ' + CAST(ERROR_NUMBER() AS NVARCHAR(10));
    PRINT 'Hata Mesaji: ' + ERROR_MESSAGE();
    PRINT 'Satir No   : ' + CAST(ERROR_LINE() AS NVARCHAR(10));
    THROW;
END CATCH;
GO
