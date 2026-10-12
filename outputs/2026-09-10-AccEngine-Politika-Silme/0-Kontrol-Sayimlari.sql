/* ---------------------------------------------------------------------------
   Silmeden ONCE calistir. Hicbir sey degistirmez, sadece sayar.
   Cikan sayilar 1..5 numarali silme scriptlerinin silecegi satir sayisidir.
   --------------------------------------------------------------------------- */

USE [__PROD_DB_ADINI_YAZ__];   /* prod DB adini yaz */
GO

DECLARE @kod NVARCHAR(50) = N'MM';   /* FI | MM | TEST | OPT1 | InvFund */

DECLARE @kok  NVARCHAR(100) = N'TREX/' + @kod;
DECLARE @kokS NVARCHAR(100) = N'TREX/' + @kod + N'/';
DECLARE @alt  NVARCHAR(100) = N'TREX/' + @kod + N'/%';

SELECT Id INTO #Item      FROM dbo.AccEngineItem      WHERE Path IN (@kok, @kokS) OR Path LIKE @alt;
SELECT Id INTO #Event     FROM dbo.AccEngineEvent     WHERE ItemId  IN (SELECT Id FROM #Item);
SELECT Id INTO #Grup      FROM dbo.AccEngineGroup     WHERE EventId IN (SELECT Id FROM #Event);
SELECT Id INTO #Component FROM dbo.AccEngineComponent WHERE GroupId IN (SELECT Id FROM #Grup);

SELECT
    (SELECT COUNT(*) FROM #Item)      AS Item,
    (SELECT COUNT(*) FROM #Event)     AS Event_,
    (SELECT COUNT(*) FROM #Grup)      AS Grup,
    (SELECT COUNT(*) FROM #Component) AS Component,
    (SELECT COUNT(*) FROM dbo.AccEngineAccountRule WHERE ComponentId IN (SELECT Id FROM #Component)) AS AccountRule,
    (SELECT COUNT(*) FROM dbo.AccAccountMap        WHERE Path IN (@kok, @kokS) OR Path LIKE @alt)    AS AccAccountMap,
    (SELECT COUNT(*) FROM dbo.AccEngineDynamicMap  WHERE Path IN (@kok, @kokS) OR Path LIKE @alt)    AS DynamicMap;

/* Bu politikanin component'leri ile URETILMIS fis var mi?
   0 degilse: o fisler silmeden sonra sahipsiz kalir. Silmeden once konusulmali. */
SELECT COUNT(*) AS UretilmisFis
FROM dbo.AccEngineGeneratedAccountRule
WHERE ComponentId IN (SELECT Id FROM #Component);

/* Ayni kod baska agaclarin altinda da geciyor mu? Bunlara DOKUNULMAZ. */
SELECT DISTINCT Path AS DokunulmayanPath
FROM dbo.AccEngineItem
WHERE Path LIKE N'%/' + @kod + N'/%' AND Id NOT IN (SELECT Id FROM #Item)
ORDER BY Path;

DROP TABLE #Item, #Event, #Grup, #Component;
GO
