# Referans — `0-DOGRULAMA-NetTrexMM.sql`

> Skill: [yuk-testi](../yuk-testi.md) · Kaynak: `repos/.ai-agent/outputs/2026-09-26-ManuelReeskont-YukTesti/`

**Amaç:** `1-NetTrexMM-YukTesti-3000-Islem.sql`'den **önce** koşulan **salt-okunur** kontrol. Hiçbir şey yazmaz,
migration değildir.

| Sorgu | Ne kontrol eder |
|---|---|
| 0 | DB varyantı (`NetTrexMM%`) → yazan script'in `USE` satırı |
| 1 | ⭐ **Şablon seçimi** — verified, `ValueDate <= @D < MaturityDate`, açılış fişi + `@D`'yi kapsayan faiz periyodu olan işlemler; `OncekiReeskont DESC`. Seçilen `LogicalReference` → `@TemplateReference` |
| 2 | `DefNumberGen` 1 (`TransactionMM_Id`) / 2 (`AccountingEntryMain_Id`) |
| 3 | Sayaç sağlam mı: `MAX(Id) < '55' + LastNumber` |
| 4 | `TxnMM` / `txnMMDetail` / `accEntryMain` trigger'ları (`TxnMMTrigger` History yazar) |
| 5 | Mevcut klon (`TMMBRWYT%`) — **0** beklenir, değilse önce GERI-AL |
| 6 | Unique index'ler (`LogicalReference` / `ExternalReference` / `BusinessKey`) |
| 7 | `NetTrexCommon` — `AccountingSync` / `Fimple` parametreleri (yük testinde kapalı olmalı) |

**Parametre:** `@D` (sorgu 1) = test edilecek Execution Date. `USE [NetTrexMM]` ortama göre düzeltilir.

```sql
/* ==================================================================================================
   0 - DOGRULAMA -- NetTrexMM  (SALT-OKUNUR, migration DEGIL)
   --------------------------------------------------------------------------------------------------
   1-NetTrexMM-YukTesti-3000-Islem.sql'den ONCE kosulur. Hicbir sey yazmaz.
   ================================================================================================== */

-- Sorgu 0 -- Dogru DB'de misin? 1 numarali script'teki USE satirini buna gore duzelt.
SELECT name FROM sys.databases WHERE name LIKE 'NetTrexMM%' ORDER BY name;
GO

USE [NetTrexMM]   -- !!! ORTAMA GORE DEGISTIR
GO

-- Sorgu 1 -- SABLON SECIMI. Test edecegin Execution Date (@D) icin listeye girecek bir islem:
-- verified, ValueDate <= @D < MaturityDate, acilis fisi var, @D'yi kapsayan faiz periyodu var.
-- En iyi sablon: daha once reeskontu BASARIYLA kesilmis olan (OncekiReeskont > 0) -> muhasebe
-- kurali / kur o islem icin calisiyor demektir. Secilen LogicalReference'i @TemplateReference'a yaz.
DECLARE @D date = CAST(GETDATE() AS date);   -- test edecegin Execution Date

SELECT TOP (20)
       t.Id, t.LogicalReference, t.TxnMmProductTypeId, p.MainProductCode, t.StateId, t.TxnTypeCode, t.Ccy,
       t.ValueDate, t.MaturityDate, t.CustomerId,
       (SELECT COUNT(*) FROM dbo.txnMMDetail d WHERE d.TxnId = t.Id) AS DetaySayisi,
       (SELECT COUNT(*) FROM dbo.accEntryMain a WHERE a.TxnId = t.Id AND a.Type = 2 AND a.IsReverse = 0) AS OncekiReeskont
FROM dbo.TxnMM t
JOIN dbo.prdProductDefinition p ON p.Id = t.TxnMmProductTypeId
WHERE t.StateId IN (18, 26)
  AND t.ValueDate <= @D
  AND t.MaturityDate > @D
  AND EXISTS (SELECT 1 FROM dbo.accEntryMain a
              WHERE a.TxnId = t.Id AND a.Type = 1 AND a.ProductCode = p.MainProductCode)
  AND EXISTS (SELECT 1 FROM dbo.txnMMDetail d
              WHERE d.TxnId = t.Id AND d.IsPrincipalAmount = 0
                AND d.PeriodStartDate <= @D AND d.PeriodEndDate > @D)
ORDER BY OncekiReeskont DESC, t.Id DESC;
GO

-- Sorgu 2 -- Id sayaclari (1 = TransactionMM_Id, 2 = AccountingEntryMain_Id). Script ikisini de 3000 ilerletir.
SELECT EntityColumnType, LastNumber, Definition, LastUpdateDate
FROM dbo.DefNumberGen
WHERE EntityColumnType IN (1, 2, 3, 4)
ORDER BY EntityColumnType;
GO

-- Sorgu 3 -- Sayaclar saglam mi? En buyuk Id'ler '55' + LastNumber'dan KUCUK olmali.
SELECT 'TxnMM' AS Tablo, MAX(t.Id) AS EnBuyukId,
       (SELECT CAST('55' + CAST(LastNumber AS varchar(12)) AS bigint) FROM dbo.DefNumberGen WHERE EntityColumnType = 1) AS SayacinSonId
FROM dbo.TxnMM t WHERE CAST(t.Id AS varchar(20)) LIKE '55%'
UNION ALL
SELECT 'accEntryMain', MAX(a.Id),
       (SELECT CAST('55' + CAST(LastNumber AS varchar(12)) AS bigint) FROM dbo.DefNumberGen WHERE EntityColumnType = 2)
FROM dbo.accEntryMain a WHERE CAST(a.Id AS varchar(20)) LIKE '55%';
GO

-- Sorgu 4 -- Tetikleyiciler (TxnMMTrigger History'yi yazar; baska tetikleyici var mi?).
SELECT OBJECT_NAME(tr.parent_id) AS TableName, tr.name AS TriggerName, tr.is_disabled
FROM sys.triggers tr
WHERE tr.parent_id IN (OBJECT_ID(N'dbo.TxnMM'), OBJECT_ID(N'dbo.txnMMDetail'), OBJECT_ID(N'dbo.accEntryMain'))
ORDER BY 1, 2;
GO

-- Sorgu 5 -- Daha once klon eklendi mi? (0 beklenir; degilse once 9-GERI-AL)
SELECT COUNT(*) AS MevcutKlon FROM dbo.TxnMM WHERE LogicalReference LIKE N'TMMBRWYT%';
GO

-- Sorgu 6 -- Klonlanan tablolardaki unique index'ler (LogicalReference / ExternalReference / BusinessKey).
SELECT OBJECT_NAME(i.object_id) AS TableName, i.name AS IndexName, i.is_unique, i.filter_definition,
       STRING_AGG(c.name, ', ') AS Columns
FROM sys.indexes i
JOIN sys.index_columns ic ON ic.object_id = i.object_id AND ic.index_id = i.index_id
JOIN sys.columns c ON c.object_id = ic.object_id AND c.column_id = ic.column_id
WHERE i.object_id IN (OBJECT_ID(N'dbo.TxnMM'), OBJECT_ID(N'dbo.accEntryMain')) AND i.is_unique = 1
GROUP BY i.object_id, i.name, i.is_unique, i.filter_definition;
GO

-- Sorgu 7 -- Execute icin dis muhasebe senkronu (NetTrexCommon). Acikken Generate/Regenerate, Fimple'in
-- HIC GORMEDIGI klon referanslariyla gercek Fimple'a gider. Yuk testinde kapali olmasi onerilir.
USE [NetTrexCommon]
GO
SELECT OptionPath, OptionName, Value, ApplicationName, StateId
FROM dbo.FrameworkParameter
WHERE OptionName LIKE '%AccountingSync%' OR OptionName LIKE '%Fimple%'
ORDER BY OptionPath, OptionName;
GO
```
