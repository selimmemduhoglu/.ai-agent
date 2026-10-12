/* ---------------------------------------------------------------------------
   MM politika agacini siler  ->  TREX/MM

   Silme sirasi (yapraktan koke):
       AccountRule -> Component -> Group -> Event -> AccAccountMap
                   -> DynamicMap -> Item (once cocuklar, sonra kok)

   AccEngineItemCode SILINMEZ (kullanici karari).
   AccEngineDynamicRule SILINMEZ (paylasilan kural havuzu).

   Once 0-Kontrol-Sayimlari.sql calistirilip sayilara bakilir.
   --------------------------------------------------------------------------- */

USE [__PROD_DB_ADINI_YAZ__];   /* prod DB adini yaz */
GO

/* Silinecek Id'ler ONCE toplanir.
   Sebep: tablolar arasinda FK yok. Item silindikten sonra Event/Group/Component'e
   giden yol kopar ve o satirlar sahipsiz kalir. */
SELECT Id INTO #Item
FROM dbo.AccEngineItem
WHERE Path IN (N'TREX/MM', N'TREX/MM/') OR Path LIKE N'TREX/MM/%';

SELECT Id INTO #Event
FROM dbo.AccEngineEvent
WHERE ItemId IN (SELECT Id FROM #Item);

SELECT Id INTO #Grup
FROM dbo.AccEngineGroup
WHERE EventId IN (SELECT Id FROM #Event);

SELECT Id INTO #Component
FROM dbo.AccEngineComponent
WHERE GroupId IN (SELECT Id FROM #Grup);
GO

BEGIN TRANSACTION;
BEGIN TRY

    DELETE FROM dbo.AccEngineAccountRule WHERE ComponentId IN (SELECT Id FROM #Component);
    PRINT '1) AccEngineAccountRule : ' + CAST(@@ROWCOUNT AS VARCHAR);

    DELETE FROM dbo.AccEngineComponent   WHERE Id IN (SELECT Id FROM #Component);
    PRINT '2) AccEngineComponent   : ' + CAST(@@ROWCOUNT AS VARCHAR);

    DELETE FROM dbo.AccEngineGroup       WHERE Id IN (SELECT Id FROM #Grup);
    PRINT '3) AccEngineGroup       : ' + CAST(@@ROWCOUNT AS VARCHAR);

    DELETE FROM dbo.AccEngineEvent       WHERE Id IN (SELECT Id FROM #Event);
    PRINT '4) AccEngineEvent       : ' + CAST(@@ROWCOUNT AS VARCHAR);

    DELETE FROM dbo.AccAccountMap
    WHERE Path IN (N'TREX/MM', N'TREX/MM/') OR Path LIKE N'TREX/MM/%';
    PRINT '5) AccAccountMap        : ' + CAST(@@ROWCOUNT AS VARCHAR);

    DELETE FROM dbo.AccEngineDynamicMap
    WHERE Path IN (N'TREX/MM', N'TREX/MM/') OR Path LIKE N'TREX/MM/%';
    PRINT '6) AccEngineDynamicMap  : ' + CAST(@@ROWCOUNT AS VARCHAR);

    DELETE FROM dbo.AccEngineItem WHERE Path LIKE N'TREX/MM/%';
    PRINT '7) AccEngineItem (alt)  : ' + CAST(@@ROWCOUNT AS VARCHAR);

    DELETE FROM dbo.AccEngineItem WHERE Path IN (N'TREX/MM', N'TREX/MM/');
    PRINT '8) AccEngineItem (kok)  : ' + CAST(@@ROWCOUNT AS VARCHAR);

    COMMIT TRANSACTION;
    PRINT 'TAMAM - TREX/MM silindi.';

END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    PRINT 'HATA: ' + ERROR_MESSAGE() + ' (satir ' + CAST(ERROR_LINE() AS VARCHAR) + ')';
    PRINT 'Hicbir sey silinmedi.';
END CATCH
GO

DROP TABLE #Item, #Event, #Grup, #Component;
GO
