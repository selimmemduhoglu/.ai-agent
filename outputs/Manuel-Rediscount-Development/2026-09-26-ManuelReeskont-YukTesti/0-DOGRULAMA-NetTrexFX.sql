/* ==================================================================================================
   0 - DOGRULAMA -- NetTrexFX  (SALT-OKUNUR, migration DEGIL)
   --------------------------------------------------------------------------------------------------
   2-NetTrexFX-YukTesti-3000-Islem.sql'den ONCE kosulur. Hicbir sey yazmaz.
   ================================================================================================== */

-- Sorgu 0 -- Dogru DB'de misin? 2 numarali script'teki USE satirini buna gore duzelt.
SELECT name FROM sys.databases WHERE name LIKE 'NetTrexFX%' ORDER BY name;
GO

USE [NetTrexFX]   -- !!! ORTAMA GORE DEGISTIR
GO

-- Sorgu 1 -- SABLON SECIMI. Verified, vadesi gelecekte bir FX Forward (70) / Future (71) / Spot (69).
-- En iyi sablon: daha once reeskontu BASARIYLA kesilmis olan (OncekiReeskont > 0) -> ortamin kur/faiz
-- egrisi ve muhasebe kurali o islem icin calisiyor demektir. Secilen LogicalReference'i
-- 2 numarali script'teki @TemplateReference'a yaz.
SELECT TOP (20)
       t.Id, t.LogicalReference, t.InstrumentId, t.StateId, t.TradeDate, t.ValueDate,
       t.CustomerId, t.PortfolioId, t.Direction, t.TxnTypeCode, t.CcyPair, t.BusinessKey,
       (SELECT COUNT(*) FROM dbo.accEntryMain a
         WHERE a.TxnId = t.Id AND a.Type = 2 AND a.IsReverse = 0) AS OncekiReeskont
FROM dbo.txnFX t
WHERE (t.StateId & 6) = 2
  AND t.InstrumentId IN (70, 71, 69)
  AND t.ValueDate > GETDATE()
  AND CAST(t.ValueDate AS date) > CAST(t.TradeDate AS date)
  AND t.LogicalReference NOT LIKE 'TFXSW%'
ORDER BY t.Id DESC;
GO

-- Sorgu 2 -- Id sayaclari (1 = TransactionFx_Id, 11 = FxAccEntry_Id, 12 = GeneratedAccountingEntry_Id,
-- 13 = FxAccEntryMain_Id). Script yalniz 1'i 3000 ilerletir.
SELECT EntityColumnType, LastNumber, Definition, LastUpdateDate
FROM dbo.defNumberGen
WHERE EntityColumnType IN (1, 11, 12, 13)
ORDER BY EntityColumnType;
GO

-- Sorgu 3 -- Sayac saglam mi? En buyuk txnFX Id'si, '11' + LastNumber'dan KUCUK olmali.
SELECT MAX(t.Id) AS EnBuyukTxnFxId,
       CAST('11' + CAST(g.LastNumber AS varchar(12)) AS bigint) AS SayacinSonId
FROM dbo.txnFX t
CROSS JOIN (SELECT LastNumber FROM dbo.defNumberGen WHERE EntityColumnType = 1) g
WHERE t.Id < 2000000000
GROUP BY g.LastNumber;
GO

-- Sorgu 4 -- txnFX tetikleyicileri (History otomatik mi dolacak?).
SELECT tr.name AS TriggerName, tr.is_disabled, OBJECT_DEFINITION(tr.object_id) AS Definition
FROM sys.triggers tr
WHERE tr.parent_id = OBJECT_ID(N'dbo.txnFX');
GO

-- Sorgu 5 -- Daha once klon eklendi mi? (0 beklenir; degilse once 9-GERI-AL)
SELECT COUNT(*) AS MevcutKlon FROM dbo.txnFX WHERE LogicalReference LIKE 'TFXFWYT%';
GO

-- Sorgu 6 -- txnFX kolonlari (script bunlari dinamik okur; bilgi amacli).
SELECT c.column_id, c.name, TYPE_NAME(c.user_type_id) AS type_name, c.max_length, c.is_nullable, c.is_identity
FROM sys.columns c
WHERE c.object_id = OBJECT_ID(N'dbo.txnFX')
ORDER BY c.column_id;
GO

-- Sorgu 7 -- Execute icin ortam parametreleri (NetTrexCommon).
-- Trex:FimpleAccountingSync = true ise Generate/Regenerate, Fimple'in HIC GORMEDIGI klon referanslariyla
-- gercek Fimple'a gider (reddedilir ya da cop kayit acar). Yuk testinde false olmasi onerilir.
USE [NetTrexCommon]
GO
SELECT OptionPath, OptionName, Value, ApplicationName, StateId
FROM dbo.FrameworkParameter
WHERE (OptionPath = 'Trex' AND OptionName IN ('FimpleAccountingSync', 'AccDepoChart', 'AccFcyChart', 'AccFcyChartABM'))
   OR OptionName IN ('SpotReeskonIsActive', 'SystemWDFlag')
ORDER BY OptionPath, OptionName;
GO
