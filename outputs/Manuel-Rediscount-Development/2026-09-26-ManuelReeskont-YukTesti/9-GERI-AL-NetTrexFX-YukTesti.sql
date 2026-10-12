/* ==================================================================================================
   9 - GERI AL -- NetTrexFX  --  Yuk testi klonlarini ve testte uretilen reeskont kayitlarini siler
   --------------------------------------------------------------------------------------------------
   Silinenler (yalniz @RefPrefix ile baslayan klon islemlere bagli satirlar):
     txnFxValuation -> accEngineGeneratedAccountRule -> accEntry -> accEntryMain -> txnFXHistory -> txnFX
   SILINMEYENLER: Kafka ile NetTrexAcc'a gitmis muhasebe kopyalari, Fimple'a gitmis fisler
   (Fimple sync acikken test yapildiysa), defNumberGen sayaclari (geri sarilmaz, bosluk kalir -- zararsiz).

   Idempotent: klon yoksa her adim 0 satir siler.
   !!! Canli/UAT'ta DEGIL, yalniz yuk testi ortaminda kosulmali.
   ================================================================================================== */

USE [NetTrexFX]   -- !!! ORTAMA GORE DEGISTIR
GO

SET NOCOUNT ON;
SET XACT_ABORT ON;

DECLARE @RefPrefix varchar(20) = 'TFXFWYT';   -- 2 numarali script'teki ile AYNI olmali

BEGIN TRY
    BEGIN TRANSACTION;

    IF OBJECT_ID('tempdb..#Clones') IS NOT NULL DROP TABLE #Clones;
    SELECT Id INTO #Clones FROM dbo.txnFX WHERE LogicalReference LIKE @RefPrefix + '%';
    PRINT 'Klon islem: ' + CAST(@@ROWCOUNT AS varchar(10));

    IF OBJECT_ID('tempdb..#Mains') IS NOT NULL DROP TABLE #Mains;
    SELECT a.Id INTO #Mains FROM dbo.accEntryMain a JOIN #Clones c ON c.Id = a.TxnId;

    DELETE v FROM dbo.txnFxValuation v JOIN #Clones c ON c.Id = v.TxnId;
    PRINT 'txnFxValuation silindi: ' + CAST(@@ROWCOUNT AS varchar(10));

    IF COL_LENGTH('dbo.accEngineGeneratedAccountRule', 'MainId') IS NOT NULL
    BEGIN
        DELETE g FROM dbo.accEngineGeneratedAccountRule g JOIN #Mains m ON m.Id = g.MainId;
        PRINT 'accEngineGeneratedAccountRule silindi: ' + CAST(@@ROWCOUNT AS varchar(10));
    END
    ELSE
        PRINT 'accEngineGeneratedAccountRule.MainId kolonu yok, atlandi (motor satirlari yetim kalir -- zararsiz).';

    DELETE e FROM dbo.accEntry e JOIN #Mains m ON m.Id = e.AccEntryMainId;
    PRINT 'accEntry silindi: ' + CAST(@@ROWCOUNT AS varchar(10));

    -- ReverseId kendi tablosuna FK: cift tek ifadede silinir.
    DELETE a FROM dbo.accEntryMain a JOIN #Mains m ON m.Id = a.Id;
    PRINT 'accEntryMain silindi: ' + CAST(@@ROWCOUNT AS varchar(10));

    IF OBJECT_ID(N'dbo.txnFXHistory') IS NOT NULL
    BEGIN
        DELETE h FROM dbo.txnFXHistory h JOIN #Clones c ON c.Id = h.Id;
        PRINT 'txnFXHistory silindi: ' + CAST(@@ROWCOUNT AS varchar(10));
    END

    DELETE t FROM dbo.txnFX t JOIN #Clones c ON c.Id = t.Id;
    PRINT 'txnFX silindi: ' + CAST(@@ROWCOUNT AS varchar(10));

    COMMIT TRANSACTION;
    PRINT 'GERI ALMA BASARILI -- NetTrexFX';
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
