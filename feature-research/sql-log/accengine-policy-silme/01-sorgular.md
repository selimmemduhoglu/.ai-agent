# 01 — Sorgular · `accengine-policy-silme`

> **Sohbet:** AccountingEngine politika ağaçlarının (FI · MM · TEST · OPT1 · InvFund) silinmesi için
> 5 ayrı script üretimi + skill/MD güncellemesi.
> **Bağlantı:** `tcp:192.168.10.211,1433` · DB `NetTrexAcc` · user `trusr` · `-P '***'`
> Kaynak: `NetTrex.Accounting/Code/docker-compose.override.yml:20`
> **Yazma işlemi:** 0 (yalnız `SELECT`)

| # | Amaç | Tür |
|---|------|-----|
| 1 | `AccEngine*`/`AccAccount*` tabloları + satır sayıları — silme zincirinin hangi tabloları kapsaması gerektiğini bilmek | keşif |
| 2 | Bu tablolar arasında **gerçek FK** var mı — silme sırası zorunlu mu, `ON DELETE` var mı | keşif |
| 3 | `AccEngineItemCode` tam liste — ekrandaki FI/MM/TEST/OPT1/InvFund kodlarının **birebir yazımı** | keşif |
| 4 | `AccEngineItem` kök seviye Path'leri — `LIKE` çapasının başka politikayı yakalayıp yakalamadığı | doğrulama |

---

## #1 — AccEngine*/AccAccount* tabloları + satır sayısı

```sql
SET NOCOUNT ON;
SELECT t.name AS TableName, SUM(p.rows) AS Rows
FROM sys.tables t
JOIN sys.partitions p ON p.object_id = t.object_id AND p.index_id IN (0,1)
WHERE t.name LIKE 'AccEngine%' OR t.name LIKE 'AccAccount%'
GROUP BY t.name
ORDER BY t.name;
```

## #2 — FK ilişkileri

```sql
SET NOCOUNT ON;
SELECT fk.name AS FkName, OBJECT_NAME(fk.parent_object_id) AS ChildTable,
       OBJECT_NAME(fk.referenced_object_id) AS ParentTable, fk.delete_referential_action_desc AS OnDelete
FROM sys.foreign_keys fk
WHERE OBJECT_NAME(fk.parent_object_id) LIKE 'Acc%' OR OBJECT_NAME(fk.referenced_object_id) LIKE 'Acc%'
ORDER BY ChildTable;
```

## #3 — AccEngineItemCode tam liste

```sql
SET NOCOUNT ON;
SELECT Id, Code, Name, ItemTypeId, StateId FROM dbo.AccEngineItemCode ORDER BY Id;
```

## #4 — AccEngineItem kök seviye Path'ler

```sql
SET NOCOUNT ON;
SELECT Path, COUNT(*) AS Adet
FROM dbo.AccEngineItem
WHERE LEN(Path) - LEN(REPLACE(Path,'/','')) <= 2
GROUP BY Path ORDER BY Path;
```

## #5 — Anahtar tabloların kolonları (`AccEngineItem/ItemCode/ComponentAccount/Account/DynamicMap/ItemType`)

**Amaç:** `AccEngineComponentAccount` gerçekten Component'e mi bağlı (silinmeli mi), `AccEngineItem`'ın
hiyerarşi kolonları neler.

```sql
SET NOCOUNT ON;
SELECT OBJECT_NAME(c.object_id) AS Tbl, c.name AS Col, t.name AS Typ
FROM sys.columns c JOIN sys.types t ON t.user_type_id = c.user_type_id
WHERE c.object_id IN (OBJECT_ID('dbo.AccEngineItemCode'),OBJECT_ID('dbo.AccEngineItem'),
      OBJECT_ID('dbo.AccEngineComponentAccount'),OBJECT_ID('dbo.AccEngineAccount'),
      OBJECT_ID('dbo.AccEngineDynamicMap'),OBJECT_ID('dbo.AccEngineItemType'))
ORDER BY Tbl, c.column_id;
```

## #6 — `AccEngineItemCode` tam liste (düzeltilmiş — kolon `ItemTypeCode`)

**Amaç:** FI/MM/TEST/OPT1/InvFund kodlarının birebir yazımı. (#3 `ItemTypeId` ile **hata verdi**.)

```sql
SET NOCOUNT ON;
SELECT Id, Code, Name, ItemTypeCode FROM dbo.AccEngineItemCode ORDER BY Id;
```

## #7 — FI / SEC1 alt ağaçları + kök node'lar

**Amaç:** `TREX/SEC1/FI` diye ayrı bir FI node'u var mı — `LIKE 'TREX/FI%'` çapası onu yakalar mı.

```sql
SET NOCOUNT ON;
SELECT Id, ItemCode, ParentId, Path, ModelDefinitionId, TemplateId FROM dbo.AccEngineItem
WHERE Path LIKE N'TREX/FI%' OR Path LIKE N'TREX/SEC1%' OR Path = N'TREX/' ORDER BY Path;

SELECT LEFT(Path, CHARINDEX('/', Path + '/', 6)) AS Kok, COUNT(*) AS ItemAdet
FROM dbo.AccEngineItem GROUP BY LEFT(Path, CHARINDEX('/', Path + '/', 6)) ORDER BY Kok;

SELECT Id, ItemCode, ParentId, Path FROM dbo.AccEngineItem
WHERE Path IN (N'TREX/SEC1/FI',N'TREX/SEC1/FI/',N'TREX/SEC1',N'TREX/SEC1/',N'TREX/FI',N'TREX/FI/',
               N'TREX/MM/',N'TREX/OPT1/',N'TREX/InvFund/',N'TREX/TEST/',N'TREX/TEST') ORDER BY Path;
```

## #8 — `AccAccountMap` + `AccEngineDynamicMap` Path dağılımı

**Amaç:** Silme çapasının bu iki bağımsız tabloda ne yakaladığı; `Path IS NULL` satırlar var mı (global, dokunulmaz).

```sql
SET NOCOUNT ON;
SELECT LEFT(Path, CHARINDEX('/', Path + '/', 6)) AS Kok, COUNT(*) AS MapAdet
FROM dbo.AccAccountMap WHERE Path IS NOT NULL
GROUP BY LEFT(Path, CHARINDEX('/', Path + '/', 6)) ORDER BY Kok;

SELECT COUNT(*) AS PathNullMap FROM dbo.AccAccountMap WHERE Path IS NULL;

SELECT Id, DynamicRuleId, LEFT(Source,30) AS Src, LEFT(Target,30) AS Tgt, Path
FROM dbo.AccEngineDynamicMap ORDER BY Id;
```

## #9 — `Path`/`ItemId`/`ComponentId`/`GroupId`/`EventId` kolonu olan TÜM tablolar

**Amaç:** Silme zincirinin **yüzeyini kapatmak** — unutulan bağlı tablo kalmasın.

```sql
SET NOCOUNT ON;
SELECT OBJECT_NAME(c.object_id) AS Tbl, c.name AS Col FROM sys.columns c
WHERE c.name IN ('Path','ItemId','ItemCode','ComponentId','GroupId','EventId')
  AND OBJECTPROPERTY(c.object_id,'IsUserTable') = 1
ORDER BY Tbl, c.name;
```

## #10 — 5 politika için zincir sayımları

**Amaç:** Her script'in ne kadar satır sileceğini **önceden** bilmek (beklenen sayılar script başlığına yazılacak).

```sql
SET NOCOUNT ON;
DECLARE @p TABLE(Code NVARCHAR(20));
INSERT INTO @p VALUES(N'FI'),(N'MM'),(N'TEST'),(N'OPT1'),(N'InvFund');
SELECT p.Code, <Item/Event/Group/Component/AccountRule/AccAccountMap/DynamicMap sayımları>
FROM @p p ORDER BY p.Code;   -- tam metin 02-ciktilar.md'de
```

## #11 — Orphan kontrolü

**Amaç:** Zincirde **zaten kopmuş** satır var mı — silme sırasının/joinin güvenilirliği.

```sql
SET NOCOUNT ON;
SELECT 'OrphanEvent', COUNT(*) FROM dbo.AccEngineEvent e WHERE NOT EXISTS(SELECT 1 FROM dbo.AccEngineItem i WHERE i.Id=e.ItemId)
UNION ALL SELECT 'OrphanGroup', COUNT(*) FROM dbo.AccEngineGroup g WHERE NOT EXISTS(SELECT 1 FROM dbo.AccEngineEvent e WHERE e.Id=g.EventId)
UNION ALL SELECT 'OrphanComponent', COUNT(*) FROM dbo.AccEngineComponent c WHERE NOT EXISTS(SELECT 1 FROM dbo.AccEngineGroup g WHERE g.Id=c.GroupId)
UNION ALL SELECT 'OrphanAccountRule', COUNT(*) FROM dbo.AccEngineAccountRule r WHERE NOT EXISTS(SELECT 1 FROM dbo.AccEngineComponent c WHERE c.Id=r.ComponentId)
UNION ALL SELECT 'ItemParentMissing', COUNT(*) FROM dbo.AccEngineItem i WHERE i.ParentId IS NOT NULL AND i.ParentId<>0 AND NOT EXISTS(SELECT 1 FROM dbo.AccEngineItem p WHERE p.Id=i.ParentId);
```

## #12 — Collation + `AccEngineItem.Path` NULL + TEST ağacı

**Amaç:** `LIKE` karşılaştırması case-insensitive mi (`InvFund` yazımı önemli mi), TEST ağacı bu DB'de var mı.

```sql
SET NOCOUNT ON;
SELECT DATABASEPROPERTYEX(DB_NAME(),'Collation') AS DbCollation;
SELECT COUNT(*) AS ItemPathNull FROM dbo.AccEngineItem WHERE Path IS NULL;
SELECT TOP (10) Id, ItemCode, ParentId, Path FROM dbo.AccEngineItem
WHERE ItemCode = N'TEST' OR Path LIKE N'%TEST%' ORDER BY Id DESC;
```

## #13 — `AccEngineAccountRule`/`Component`/`Event`/`Group`/`GeneratedAccountRule` kolonları

**Amaç:** `AccEngineGeneratedAccountRule` bir **kural** mı yoksa **üretilmiş fiş** mi (silinmeli mi).

```sql
SET NOCOUNT ON;
SELECT OBJECT_NAME(c.object_id) AS Tbl, c.name AS Col FROM sys.columns c
WHERE c.object_id IN (OBJECT_ID('dbo.AccEngineAccountRule'),OBJECT_ID('dbo.AccEngineGroup'),
      OBJECT_ID('dbo.AccEngineComponent'),OBJECT_ID('dbo.AccEngineEvent'),
      OBJECT_ID('dbo.AccEngineGeneratedAccountRule'))
ORDER BY Tbl, c.column_id;
```

---

**Toplam:** 13 sorgu · **yazma işlemi: 0** · başarısız: 1 (#3, `Invalid column name 'ItemTypeId'`)

## #14 - `AccEngineGroup` kolonları

**Amaç:** Silme script'indeki "referanssız DynamicRule" raporunda `Group.ValidationRuleId` kolon adı
doğru mu — teslim edilen script'te geçersiz kolon adı kalmasın.

```sql
SET NOCOUNT ON;
SELECT c.name FROM sys.columns c WHERE c.object_id = OBJECT_ID('dbo.AccEngineGroup') ORDER BY c.column_id;
```

---

**Toplam (güncel):** 14 sorgu · **yazma işlemi: 0** · başarısız: 1 (#3)

## #15 - Her `DefNumberGen` tablosunun en buyuk 6 Id'si

**Amac:** "Orustu disi (elle girilmis) Id" hangi tablolarda var - sayaci hangi degere cekecegiz.

```sql
SET NOCOUNT ON;
WITH u AS (
  SELECT 'AccAccountMap' t, Id FROM dbo.AccAccountMap
  UNION ALL SELECT 'AccEngineAccountRule', Id FROM dbo.AccEngineAccountRule
  ... (11 tablo)
), r AS (SELECT t, Id, ROW_NUMBER() OVER(PARTITION BY t ORDER BY Id DESC) rn,
                COUNT(*) OVER(PARTITION BY t) cnt FROM u)
SELECT t, cnt, rn, Id FROM r WHERE rn <= 6 ORDER BY t, rn;
```

## #16 - Ardisik Id'ler arasindaki en buyuk 3 bosluk (tablo basina)

**Amac:** "absurt bosluk" esigini veriye dayandirmak - normal bosluklar ne kadar buyuyor.

```sql
SET NOCOUNT ON;
WITH u AS (...11 tablo...), g AS (SELECT t, Id, Id - LAG(Id) OVER(PARTITION BY t ORDER BY Id) gap FROM u),
     r AS (SELECT t, Id, gap, ROW_NUMBER() OVER(PARTITION BY t ORDER BY gap DESC) rn FROM g WHERE gap IS NOT NULL)
SELECT t, rn, gap, Id FROM r WHERE rn <= 3 ORDER BY t, rn;
```

## #17 - Canli tablo MAX(Id) ile `*History` MAX(Id) karsilastirmasi + `DefNumberGen` kolonlari

**Amac:** Sayac hesabina History dahil edilmeli mi.

```sql
SET NOCOUNT ON;
SELECT 'AccEngineAccountRule' t,(SELECT MAX(Id) FROM dbo.AccEngineAccountRule),
       (SELECT MAX(Id) FROM dbo.AccEngineAccountRuleHistory) UNION ALL ... (10 tablo) ORDER BY t;
SELECT c.name FROM sys.columns c WHERE c.object_id = OBJECT_ID('dbo.DefNumberGen') ORDER BY c.column_id;
```

## #18 - `AccEngineDynamicRuleHistory` 2.000.000'lik Id'ler ne

**Amac:** History'deki 2000290 gercek bir entity Id'si mi, yoksa History'nin kendi PK'si mi.

```sql
SET NOCOUNT ON;
SELECT c.name FROM sys.columns c WHERE c.object_id = OBJECT_ID('dbo.AccEngineDynamicRuleHistory') ORDER BY c.column_id;
SELECT TOP (5) Id, LEFT(Name,40) AS Nm, StateId FROM dbo.AccEngineDynamicRuleHistory ORDER BY Id DESC;
SELECT COUNT(*) AS HistUstu FROM dbo.AccEngineDynamicRuleHistory WHERE Id > 12507;
```

---

**Toplam (guncel):** 18 sorgu - **yazma islemi: 0** - basarisiz: 1 (#3)
