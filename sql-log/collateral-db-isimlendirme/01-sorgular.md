# SQL Log — Sorgular — collateral-db-isimlendirme

> Amaç (genel): Collateral modülü DB'si (`NetTrexCollateral`) için MM'in tablo/kolon/constraint
> isimlendirme konvansiyonunu **fiziksel şemadan** doğrulamak (EF `ToTable` string'i ≠ fiziksel yazım olabilir).
> Yalnız `sys.*` katalog görünümleri, aggregate sorgular — iş verisi çekilmiyor.
> Bağlantı: `NetTrex.MM/Code/docker-compose.override.yml` → Server `192.168.10.211`, DB `NetTrexMM`, User `trusr`.

| # | Yazma | Durum |
|---|---|---|
| Toplam sorgu | **7** (+1 başarısız komut denemesi) | |
| Toplam yazma sorgusu | **0** | yalnız SELECT |

---

### #1 — Fiziksel tablo adları (case dahil), tek satır STRING_AGG

Amaç: `defDateBasis`/`cusCustomer`/`txnMMTax` gibi küçük harf prefix'lerin fiziksel yazımını ve tüm prefix ailelerini görmek.
Tek satır döner (aggregate), TOP gereksiz.

```sql
SET NOCOUNT ON;
SELECT COUNT(*) AS Adet,
       STRING_AGG(CAST(name AS nvarchar(max)), ', ') WITHIN GROUP (ORDER BY name) AS Tablolar
FROM sys.tables;
```

### #2 — `Id` kolonlarının tip + identity dağılımı

Amaç: PK `Id` int mi bigint mi, IDENTITY mi — tablo bazında gruplu.

```sql
SET NOCOUNT ON;
SELECT t.name AS Tip, c.is_identity, COUNT(*) AS Adet,
       STRING_AGG(CAST(OBJECT_NAME(c.object_id) AS nvarchar(max)), ', ') WITHIN GROUP (ORDER BY OBJECT_NAME(c.object_id)) AS Tablolar
FROM sys.columns c JOIN sys.types t ON t.user_type_id = c.user_type_id
JOIN sys.tables tb ON tb.object_id = c.object_id
WHERE c.name = 'Id'
GROUP BY t.name, c.is_identity;
```

### #3 — nvarchar uzunluk dağılımı + decimal precision/scale dağılımı

Amaç: nvarchar için standart uzunluk var mı; para/oran decimal'leri gerçekte hangi (p,s).

```sql
SET NOCOUNT ON;
SELECT 'nvarchar' AS Tur, CAST(CASE WHEN c.max_length = -1 THEN -1 ELSE c.max_length/2 END AS varchar(10)) AS Boyut, COUNT(*) AS Adet
FROM sys.columns c JOIN sys.types t ON t.user_type_id = c.user_type_id JOIN sys.tables tb ON tb.object_id = c.object_id
WHERE t.name = 'nvarchar' GROUP BY c.max_length
UNION ALL
SELECT t.name, CONCAT(c.precision, ',', c.scale), COUNT(*)
FROM sys.columns c JOIN sys.types t ON t.user_type_id = c.user_type_id JOIN sys.tables tb ON tb.object_id = c.object_id
WHERE t.name IN ('decimal','numeric','money') GROUP BY t.name, c.precision, c.scale
ORDER BY Tur, Adet DESC;
```

### #4 — bit kolonlarında `Is` öneki tutarlılığı

Amaç: Boolean kolonlar hep `Is*` mi; `Is` ile başlamayan bit kolon adları neler.

```sql
SET NOCOUNT ON;
SELECT CASE WHEN c.name LIKE 'Is%' THEN 'Is*' WHEN c.name LIKE 'Use%' THEN 'Use*' WHEN c.name LIKE 'Has%' THEN 'Has*' ELSE 'diger' END AS Kalip,
       COUNT(*) AS Adet,
       STRING_AGG(CAST(c.name AS nvarchar(max)), ', ') AS Kolonlar
FROM sys.columns c JOIN sys.types t ON t.user_type_id = c.user_type_id JOIN sys.tables tb ON tb.object_id = c.object_id
WHERE t.name = 'bit' AND c.name NOT LIKE 'Is%'
GROUP BY CASE WHEN c.name LIKE 'Is%' THEN 'Is*' WHEN c.name LIKE 'Use%' THEN 'Use*' WHEN c.name LIKE 'Has%' THEN 'Has*' ELSE 'diger' END
UNION ALL
SELECT 'Is* (sayi)', COUNT(*), NULL
FROM sys.columns c JOIN sys.types t ON t.user_type_id = c.user_type_id JOIN sys.tables tb ON tb.object_id = c.object_id
WHERE t.name = 'bit' AND c.name LIKE 'Is%';
```

### #5 — Audit kolonlarının tablo sayısı

Amaç: `CreatedBy/CreatedDate` vs `StateMaker/StateDate` vs `Modified*/Updated*` hangi tablolarda.

```sql
SET NOCOUNT ON;
SELECT c.name AS Kolon, COUNT(*) AS TabloAdedi
FROM sys.columns c JOIN sys.tables tb ON tb.object_id = c.object_id
WHERE c.name IN ('CreatedBy','CreatedDate','StateMaker','StateDate','StateId','FlowId','LastActionId','ModifiedBy','ModifiedDate','UpdatedBy','UpdatedDate','UpdateDate','InsertDate','IsEnabled','IsActive','IsDeleted')
GROUP BY c.name ORDER BY TabloAdedi DESC;
```

### #6 — Constraint / index ad örnekleri (her türden en fazla 20)

Amaç: PK/FK/UQ/DF/IX isim kalıbı.

```sql
SET NOCOUNT ON;
SELECT TOP (20) 'PK/UQ' AS Tur, kc.name, OBJECT_NAME(kc.parent_object_id) AS Tablo FROM sys.key_constraints kc ORDER BY kc.object_id DESC;
SELECT TOP (20) 'FK' AS Tur, fk.name, OBJECT_NAME(fk.parent_object_id) AS Tablo, OBJECT_NAME(fk.referenced_object_id) AS Hedef FROM sys.foreign_keys fk ORDER BY fk.object_id DESC;
SELECT TOP (20) 'IX' AS Tur, i.name, OBJECT_NAME(i.object_id) AS Tablo FROM sys.indexes i JOIN sys.tables tb ON tb.object_id = i.object_id WHERE i.is_primary_key = 0 AND i.is_unique_constraint = 0 AND i.type > 0 ORDER BY i.object_id DESC;
SELECT TOP (20) 'DF' AS Tur, d.name, OBJECT_NAME(d.parent_object_id) AS Tablo FROM sys.default_constraints d ORDER BY d.object_id DESC;
```

> Komut: `sqlcmd -S "tcp:192.168.10.211,1433" -d NetTrexMM -U trusr -P '***' -C -l 20 -W -s "|" -Q "..."`

### #7 — decimal/numeric (p,s) gruplarının hangi tablolarda olduğu + tarih tipi dağılımı

Amaç: #3'te çıkan `numeric(22,6)` x64 / `numeric(18,9)` x16 legacy mi (MDL_*?) yoksa MM'in kendi tabloları mı; `(38,2)` hiç yok mu; tarih kolonları date mi datetime mı.

```sql
SET NOCOUNT ON;
SELECT CONCAT(t.name,'(',c.precision,',',c.scale,')') AS Tip, COUNT(*) AS Adet,
       STRING_AGG(CAST(CONCAT(OBJECT_NAME(c.object_id),'.',c.name) AS nvarchar(max)), ', ') AS Kolonlar
FROM sys.columns c JOIN sys.types t ON t.user_type_id = c.user_type_id JOIN sys.tables tb ON tb.object_id = c.object_id
WHERE t.name IN ('decimal','numeric') AND OBJECT_NAME(c.object_id) NOT LIKE 'MDL[_]%'
GROUP BY t.name, c.precision, c.scale;
SELECT t.name AS Tip, COUNT(*) AS Adet FROM sys.columns c JOIN sys.types t ON t.user_type_id = c.user_type_id JOIN sys.tables tb ON tb.object_id = c.object_id
WHERE t.name IN ('date','datetime','datetime2','smalldatetime','datetimeoffset') GROUP BY t.name;
```
