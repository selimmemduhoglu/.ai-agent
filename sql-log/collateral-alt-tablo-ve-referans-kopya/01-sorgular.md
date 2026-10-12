# SQL Sorguları — collateral-alt-tablo-ve-referans-kopya

Amaç: (1) Tanım tablolarının ALT tablolarında Id'nin IDENTITY mi DefNumberGen mi olduğunu,
(2) NetTrexMM'de hangi referans tablolarının NetTrexCommon kopyası olduğunu ölçmek.
Hepsi SALT-OKUNUR SELECT.

Bağlantı: `tcp:192.168.10.211,1433` / `NetTrexMM` / `trusr` / `-P '***'`

---

## 1 — Prd*/Def* ailesi + ilgili tabloların Id kolonu IDENTITY mi?

Amaç: `PrdProductDefinitionMarketMap.Id` fiziksel olarak IDENTITY mi? Emsal tablolarla karşılaştır.

```sql
SET NOCOUNT ON;
SELECT TOP (50) t.name AS TableName, c.name AS ColName, ty.name AS DataType, c.is_identity
FROM sys.tables t
JOIN sys.columns c ON c.object_id = t.object_id
JOIN sys.types ty ON ty.user_type_id = c.user_type_id
WHERE c.name = 'Id'
  AND (t.name LIKE 'prd%' OR t.name LIKE 'def%' OR t.name LIKE 'Def%')
ORDER BY t.name;
```

## 2 — NetTrexMM'de Id kolonu IDENTITY OLMAYAN tüm tablolar

Amaç: DefNumberGen deseninin fiili kapsamı.

```sql
SET NOCOUNT ON;
SELECT TOP (50) t.name AS TableName, ty.name AS DataType, c.is_identity
FROM sys.tables t
JOIN sys.columns c ON c.object_id = t.object_id
JOIN sys.types ty ON ty.user_type_id = c.user_type_id
WHERE c.name = 'Id' AND c.is_identity = 0
ORDER BY t.name;
```

## 3 — NetTrexMM tam tablo listesi (sayı + adlar)

Amaç: referans tablosu kopyalarını tespit etmek için envanter.

```sql
SET NOCOUNT ON;
SELECT COUNT(*) AS TabloSayisi FROM sys.tables;
SELECT name FROM sys.tables ORDER BY name;
```

## 4 — NetTrexCommon tablo listesi (aynı sunucu, cross-db SELECT)

Amaç: hangi tabloların hem Common'da hem MM'de olduğunu (= kopya) bulmak.

```sql
SET NOCOUNT ON;
SELECT name FROM NetTrexCommon.sys.tables ORDER BY name;
```

## 5 — İki DB'de ortak tablo adları (kesişim)

Amaç: "kopya referans tablosu" listesinin kesin hali.

```sql
SET NOCOUNT ON;
SELECT m.name AS TableName
FROM sys.tables m
JOIN NetTrexCommon.sys.tables c ON c.name = m.name
ORDER BY m.name;
```

## 6 — prdProductDefinitionMarketMap son 20 satır (Id dizilimi)

Amaç: Id'lerin ardışık mı (IDENTITY) yoksa DefNumberGen sayacından (1000+) mı geldiğini görmek.

```sql
SET NOCOUNT ON;
SELECT TOP (20) Id, ProductDefinitionId, MarketCode, IsDefaultMarket, [Order], IsEnabled
FROM dbo.prdProductDefinitionMarketMap
ORDER BY Id DESC;
```

## 7 — prdProductDefinition son 20 satır Id dizilimi

Amaç: DefNumberGen 'Product Definition Id' = 999 ile gerçek Id'leri karşılaştırmak.

```sql
SET NOCOUNT ON;
SELECT TOP (20) Id, Code, Name, MainProductCode, IsEnabled, StateId
FROM dbo.prdProductDefinition
ORDER BY Id DESC;
```

## 8 — History tablosu olan tablolar + trigger listesi (doğrulama)

Amaç: Prd ailesi / Def ailesi alt tablolarında History var mı.

```sql
SET NOCOUNT ON;
SELECT name FROM sys.tables WHERE name LIKE '%History' ORDER BY name;
SELECT t.name AS TriggerName, OBJECT_NAME(t.parent_id) AS ParentTable, t.is_disabled
FROM sys.triggers t WHERE t.parent_id > 0 ORDER BY t.name;
```

## 9 — Consumer'ın yazdığı tabloların satır sayıları (kopya besleniyor mu)

Amaç: referans kopyalarının gerçekten dolu olup olmadığı.

```sql
SET NOCOUNT ON;
SELECT t.name AS TableName, SUM(p.rows) AS RowCnt
FROM sys.tables t JOIN sys.partitions p ON p.object_id = t.object_id AND p.index_id IN (0,1)
WHERE t.name IN ('cusCustomer','Currency','prfPortfolio','Market','MarketCustomerMap','defTxnType',
                 'defCountry','defCorporateType','Calendar','Holiday','HalfWorkingDay','defDateBasis',
                 'TaxType','TaxRate','TaxRule','Tax','FxRate','FxRateDetail','InterestRate',
                 'InterestRateDetail','Chart','Point','ExternalCustomerMap','ExternalUserMap')
GROUP BY t.name ORDER BY t.name;
```

## 10 — defBitMask / defNotification ailesi var mı (emsal arama)

```sql
SET NOCOUNT ON;
SELECT TOP (50) t.name AS TableName, c.is_identity
FROM sys.tables t JOIN sys.columns c ON c.object_id=t.object_id AND c.name='Id'
WHERE t.name LIKE '%BitMask%' OR t.name LIKE '%Notification%' OR t.name LIKE '%Map'
ORDER BY t.name;
```
