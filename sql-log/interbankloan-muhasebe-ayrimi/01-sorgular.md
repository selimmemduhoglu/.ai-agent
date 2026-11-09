# 01-sorgular — interbankloan-muhasebe-ayrimi

Amaç: InterbankLoan ile MM muhasebesini Accounting Engine tarafında nasıl ayırırız? PathExtensions `TREX/BRWPLC1/{AccountingMapCode}/{Dir}/{CCY}/` üretiyor; Loan ürünü (AccountingMapCode=LOAN) iki ekranda ortak mı, AccAccountMap Path/kolonlarıyla ayrım mümkün mü — gerçek veriden doğrulama.
Bağlantı: sqlcmd -S "tcp:192.168.10.211,1433" -U trusr -P '***' -C (salt-okunur, yalnız SELECT)

## #1 — NetTrexAcc: AccAccountMap kolonları
Amaç: AccAccountMap'te ayrım yapabilecek kolon (Path, ProductCode, ModuleCode, rule vb.) var mı.
```sql
SET NOCOUNT ON;
SELECT c.name, t.name AS type, c.max_length, c.is_nullable
FROM sys.columns c JOIN sys.types t ON t.user_type_id = c.user_type_id
WHERE c.object_id = OBJECT_ID('dbo.AccAccountMap') ORDER BY c.column_id;
```

## #2 — NetTrexAcc: AccAccountMap BRWPLC1 Path dağılımı
Amaç: BRWPLC1 altında hangi Path'lerde kaç map satırı var (LOAN ayrı node mu).
```sql
SET NOCOUNT ON;
SELECT TOP (20) Path, COUNT(*) AS Adet FROM dbo.AccAccountMap
WHERE Path LIKE N'TREX/BRWPLC1%' GROUP BY Path ORDER BY Path DESC;
```

## #3 — NetTrexAcc: AccEngineItem BRWPLC1 ağacı
Amaç: BRWPLC1 altındaki ürün düğümleri (MONEYMARKET / LOAN / TWR ...) ve derinlik.
```sql
SET NOCOUNT ON;
SELECT TOP (50) Id, ItemCode, ParentId, Path FROM dbo.AccEngineItem
WHERE Path = N'TREX/BRWPLC1/' OR Path LIKE N'TREX/BRWPLC1/%' AND Path NOT LIKE N'TREX/BRWPLC1/%/%/%/%' ORDER BY Id DESC;
```

## #4 — NetTrexMM: ürün tablosu adı keşfi
Amaç: ProductDefinition fiziksel tablo adı.
```sql
SET NOCOUNT ON;
SELECT TOP (20) name FROM sys.tables WHERE name LIKE N'%Product%' OR name LIKE N'TxnLoan' OR name LIKE N'TxnMM' ORDER BY name;
```

## #5 — NetTrexMM: PrdProductDefinition ürünleri
Amaç: hangi ürün AccountingMapCode=LOAN, hangileri InterbankLoan ekranına ait (ürün kolonunda ekran ayrımı yok iddiası doğrulama).
```sql
SET NOCOUNT ON;
SELECT TOP (20) Id, Code, AccountingMapCode, MainProductCode, IsEnabled FROM dbo.PrdProductDefinition ORDER BY Id DESC;
```

## #6 — NetTrexMM: TxnLoan / TxnMM ürün kolonları
Amaç: iki işlem tablosunun ürüne bağlanan kolon adları (sonraki dağılım sorgusu için).
```sql
SET NOCOUNT ON;
SELECT TOP (20) OBJECT_NAME(c.object_id) AS Tbl, c.name FROM sys.columns c
WHERE c.object_id IN (OBJECT_ID('dbo.TxnLoan'), OBJECT_ID('dbo.TxnMM')) AND c.name LIKE N'%Product%' ORDER BY Tbl, c.name;
```

## #7 — NetTrexAcc: AccAccountMap LOAN/BRW/LCY satırları
Amaç: map'in Source→Target + RuleId koşullarının gerçek hali; aynı Path içinde koşulla ayrım yapılıyor mu.
```sql
SET NOCOUNT ON;
SELECT TOP (20) Id, Source, TargetMainGL, Target, RuleId, Rule2Id, Rule3Id, [Order], IsEnabled, Path
FROM dbo.AccAccountMap WHERE Path = N'TREX/BRWPLC1/LOAN/BRW/LCY' ORDER BY Id DESC;
```

## #8 — NetTrexAcc: AccAccountMap'in kullandığı DynamicRule'lar
Amaç: RuleId 12376/12377/12349 koşulları ne — TxnModel'in hangi alanına bakıyor; ürün/ekran ayrımı için kullanılabilir mi.
```sql
SET NOCOUNT ON;
SELECT TOP (20) Id, Name, LEFT([Rule], 300) AS Rule FROM dbo.AccEngineDynamicRule WHERE Id IN (12376, 12377, 12349) ORDER BY Id DESC;
```

## #9 — NetTrexMM: ürün başına işlem dağılımı (TxnLoan)
Amaç: hangi ürünler InterbankLoan ekranından (TxnLoan) işlem alıyor.
```sql
SET NOCOUNT ON;
SELECT TOP (20) ProductDefinitionId, COUNT(*) AS Adet FROM dbo.TxnLoan GROUP BY ProductDefinitionId ORDER BY ProductDefinitionId DESC;
```

## #10 — NetTrexMM: ürün başına işlem dağılımı (TxnMM)
Amaç: LOAN-kodlu ürünlerden hangileri TxnMM'e (MM ekranı) yazılıyor — iki ekran aynı AccountingMapCode'u paylaşıyor mu.
```sql
SET NOCOUNT ON;
SELECT TOP (20) TxnMmProductTypeId, COUNT(*) AS Adet FROM dbo.TxnMM GROUP BY TxnMmProductTypeId ORDER BY TxnMmProductTypeId DESC;
```

## #11 — #8'in düzeltilmişi (alias `AS Rule` ayrılmış kelime hatası verdi)
Amaç: aynı — AccAccountMap RuleId koşullarının metni.
```sql
SET NOCOUNT ON;
SELECT TOP (20) Id, Name, LEFT([Rule], 300) AS RuleText FROM dbo.AccEngineDynamicRule WHERE Id IN (12376, 12377, 12349) ORDER BY Id DESC;
```

## #12 — NetTrexMM: PrdProductDefinition bayrak kolonları + değerleri
Amaç: MM ile InterbankLoan ürünlerini ayıran bir bayrak/kolon var mı (IsSameDay, IsZeroRate, IsIntraBank, IsCollateralized, IsGenerateFWDAccounting...). Satır başına 11 ürün, kolon seçili.
```sql
SET NOCOUNT ON;
SELECT TOP (20) Id, Code, AccountingMapCode, IsSameDay, IsZeroRate, IsIntraBank, IsCollateralized, IsGenerateFWDAccounting, IsAccountNeeded, IsBorrowing, IsPlacement
FROM dbo.PrdProductDefinition ORDER BY Id DESC;
```

## #13 — NetTrexAcc: AccEngineModelDefinition kolonları
Amaç: model tanımı alan listesi (JSON/şema) taşıyor mu — MM modeline yeni alan eklenince Accounting DB/modül tarafında da kayıt gerekir mi.
```sql
SET NOCOUNT ON;
SELECT c.name, t.name AS type, c.max_length FROM sys.columns c JOIN sys.types t ON t.user_type_id = c.user_type_id
WHERE c.object_id = OBJECT_ID('dbo.AccEngineModelDefinition') ORDER BY c.column_id;
```

## #14 — NetTrexAcc: AccEngineModelDefinition satırları
Amaç: 'Borrowing & Placement V1' tanımının içeriği (alan listesi var mı, ProductId geçiyor mu).
```sql
SET NOCOUNT ON;
SELECT TOP (20) Id, Name, LEN(CAST(Definition AS NVARCHAR(MAX))) AS DefLen FROM dbo.AccEngineModelDefinition ORDER BY Id DESC;
```

## #15 — NetTrexAcc: 'Borrowing & Placement V1' Schema içeriği (ProductId / JsonIgnore alanları geçiyor mu)
Amaç: Schema JSON'unda ProductId, IsAccountNeeded (modelde [JsonIgnore]) gibi alanlar var mı; yani şema model sınıfından mı üretiliyor, elle mi tutuluyor — yeni alan şemaya da eklenmeli mi.
```sql
SET NOCOUNT ON;
SELECT TOP (20) Id, Name, LEN([Schema]) AS SchemaLen, CHARINDEX(N'ProductId', [Schema]) AS PosProductId,
 CHARINDEX(N'IsAccountNeeded', [Schema]) AS PosIsAccountNeeded, CHARINDEX(N'FundSourceCode', [Schema]) AS PosFundSource,
 CHARINDEX(N'TxnReference', [Schema]) AS PosTxnReference, LEFT([Schema], 300) AS Head
FROM dbo.AccEngineModelDefinition WHERE Id = 123 ORDER BY Id DESC;
```
