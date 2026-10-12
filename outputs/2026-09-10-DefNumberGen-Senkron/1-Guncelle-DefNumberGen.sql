/* ---------------------------------------------------------------------------
   DefNumberGen.LastNumber degerlerini tablolarin gercek en buyuk Id'sine esitler.

   Once 0-Kontrol-DefNumberGen.sql calistirilir, "AtilanOruntuDisiSatir" ve
   "OlmasiGereken" kolonlarina bakilir. Dogruysa bu script calistirilir.

   Kural: LastNumber = OruntuMaxId  (elle girilmis absurt Id'ler haric en buyuk Id)
   Tablo bossa o satira DOKUNULMAZ (eski deger korunur).
   --------------------------------------------------------------------------- */

USE [__DB_ADINI_YAZ__];   /* NetTrexAcc / NetTrexAcc_... */
GO

/* Esikler -- gerekirse burayi degistir.
   @Kat      : bir Id, kendinden onceki Id'nin bu kati kadar buyukse "kopus" sayilir.
   @AdaYuzde : kopusun ustunde kalan ada, tablonun bu yuzdesinden buyukse ORUNTU kabul
               edilir (yani atilmaz). Boylece gercek bir Id blogu yanlislikla atilmaz. */
DECLARE @Kat      INT = 10;
DECLARE @AdaYuzde INT = 5;

/* 1) Butun Id'ler tek gecici tabloda toplanir. */
SELECT Tanim, Id
INTO #Id
FROM (
    SELECT N'AccEngineDynamicRule Id'      AS Tanim, Id FROM dbo.AccEngineDynamicRule
    UNION ALL SELECT N'AccEngineAccountRule Id',      Id FROM dbo.AccEngineAccountRule
    UNION ALL SELECT N'AccEngineComponent Id',        Id FROM dbo.AccEngineComponent
    UNION ALL SELECT N'AccEngineGroup Id',            Id FROM dbo.AccEngineGroup
    UNION ALL SELECT N'AccEngineEvent Id',            Id FROM dbo.AccEngineEvent
    UNION ALL SELECT N'AccEngineComponentAccount Id', Id FROM dbo.AccEngineComponentAccount
    UNION ALL SELECT N'AccEngineItem Id',             Id FROM dbo.AccEngineItem
    UNION ALL SELECT N'AccEngineItemCode Id',         Id FROM dbo.AccEngineItemCode
    UNION ALL SELECT N'AccEngineItemType Id',         Id FROM dbo.AccEngineItemType
    UNION ALL SELECT N'AccEngineModelDefinition Id',  Id FROM dbo.AccEngineModelDefinition
    UNION ALL SELECT N'AccAccountMap Id',             Id FROM dbo.AccAccountMap
) x;

/* 2) Kopus noktasi bulunur.
      Ornek (AccAccountMap): ... 24996, 24997, 12376128
      12376128 bir onceki Id'nin 10 katindan buyuk  -> kopus
      ustunde sadece 1 satir var (tablonun %5'inden az) -> elle girilmis, atilir. */
SELECT Tanim, MIN(Id) AS KopusId
INTO #Kopus
FROM (
    SELECT Tanim, Id,
           LAG(Id)     OVER (PARTITION BY Tanim ORDER BY Id)      AS OncekiId,
           COUNT(*)    OVER (PARTITION BY Tanim)                  AS ToplamSatir,
           ROW_NUMBER()OVER (PARTITION BY Tanim ORDER BY Id DESC) AS AdaSatirSayisi
    FROM #Id
) s
WHERE OncekiId IS NOT NULL
  AND Id > @Kat * OncekiId                      /* bosluk absurt mu */
  AND AdaSatirSayisi * 100 <= ToplamSatir * @AdaYuzde   /* ada kucuk mu */
GROUP BY Tanim;

/* 3) Her tanim icin sonuc. OruntuMaxId = atilanlar haric en buyuk Id. */
SELECT i.Tanim,
       COUNT(*)                                                              AS SatirSayisi,
       MAX(i.Id)                                                             AS EnBuyukId,
       MAX(CASE WHEN k.KopusId IS NULL OR i.Id < k.KopusId THEN i.Id END)    AS OruntuMaxId,
       SUM(CASE WHEN k.KopusId IS NOT NULL AND i.Id >= k.KopusId THEN 1 ELSE 0 END) AS AtilanSatir
INTO #Hesap
FROM #Id i
LEFT JOIN #Kopus k ON k.Tanim = i.Tanim
GROUP BY i.Tanim;

/* 4) Degisecek satirlari once yaz. */
SELECT d.[Definition], d.LastNumber AS Eski, h.OruntuMaxId AS Yeni
FROM dbo.DefNumberGen d
INNER JOIN #Hesap h ON h.Tanim = d.[Definition]
WHERE h.OruntuMaxId IS NOT NULL
  AND d.LastNumber <> h.OruntuMaxId;

/* 5) GUNCELLEME */
BEGIN TRANSACTION;
BEGIN TRY

    UPDATE d
    SET LastNumber     = h.OruntuMaxId,
        LastUpdateDate = GETDATE()
    FROM dbo.DefNumberGen d
    INNER JOIN #Hesap h ON h.Tanim = d.[Definition]
    WHERE h.OruntuMaxId IS NOT NULL
      AND d.LastNumber <> h.OruntuMaxId;

    PRINT 'Guncellenen satir: ' + CAST(@@ROWCOUNT AS VARCHAR);

    COMMIT TRANSACTION;
    PRINT 'TAMAM';

END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    PRINT 'HATA: ' + ERROR_MESSAGE() + ' (satir ' + CAST(ERROR_LINE() AS VARCHAR) + ')';
    PRINT 'Hicbir sey degismedi.';
END CATCH

/* 6) Son durum */
SELECT EntityColumnType, [Definition], LastNumber, LastUpdateDate
FROM dbo.DefNumberGen
ORDER BY EntityColumnType;

DROP TABLE #Id, #Kopus, #Hesap;
GO
