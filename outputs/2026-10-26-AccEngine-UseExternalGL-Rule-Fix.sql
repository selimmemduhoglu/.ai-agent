/*
  AccEngineDynamicRule 12660 / 12661: JS 'TxnModel.UseExternalGLCode' kullaniyor, MM AccountingEngineModel'de
  bu property YOK (dogrusu UseExternalGLAccount; bkz. kural 12347/12348). undefined === true/false -> her zaman false
  -> CounterPartyGLAccount map satirlari (110 aktif satir, LOAN + MONEYMARKET) hic secilmiyor.
  Calistirdiktan sonra map/rule cache temizlenmeli (Accounting Sync ucu ya da Redis:
  Netix.DynamicRuleDefinition + Netix.AccAccountingMapDefinition).
*/
USE [__DB_ADINI_YAZ__];
GO

SET NOCOUNT ON;

BEGIN TRY
    BEGIN TRAN;

    IF EXISTS (SELECT 1 FROM dbo.AccEngineDynamicRule WHERE Id = 12660 AND CAST([Rule] AS NVARCHAR(MAX)) = N'TxnModel.UseExternalGLCode === true')
    BEGIN
        UPDATE dbo.AccEngineDynamicRule SET [Rule] = N'TxnModel.UseExternalGLAccount === true' WHERE Id = 12660;
        PRINT 'Rule 12660 guncellendi.';
    END
    ELSE PRINT 'Rule 12660 zaten duzgun / beklenen metinde degil - atlandi.';

    IF EXISTS (SELECT 1 FROM dbo.AccEngineDynamicRule WHERE Id = 12661 AND CAST([Rule] AS NVARCHAR(MAX)) = N'TxnModel.UseExternalGLCode === false')
    BEGIN
        UPDATE dbo.AccEngineDynamicRule SET [Rule] = N'TxnModel.UseExternalGLAccount === false' WHERE Id = 12661;
        PRINT 'Rule 12661 guncellendi.';
    END
    ELSE PRINT 'Rule 12661 zaten duzgun / beklenen metinde degil - atlandi.';

    COMMIT TRAN;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRAN;
    THROW;
END CATCH
GO

SELECT Id, Name, CAST([Rule] AS NVARCHAR(200)) AS [Rule] FROM dbo.AccEngineDynamicRule WHERE Id IN (12660, 12661, 12347, 12348);
GO
