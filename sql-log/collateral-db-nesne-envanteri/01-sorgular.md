# SQL Log — Sorgular — collateral-db-nesne-envanteri

> Amaç (genel): `NetTrexMM` DB'sindeki **stored procedure / function / FK / CHECK / DEFAULT /
> UNIQUE index / trigger** envanterini çıkarmak. Yeni "Collateral" modülünün ~20 tablosu için
> hangi DB nesnelerinin **zorunlu** olduğunu belirlemek.
> Yalnız `sys.*` katalog görünümleri + 2 küçük konfigürasyon tablosu (`DefNumberGen`,
> `DefCountMonitoring`). İş verisi çekilmiyor, yazma yok.
> Bağlantı: `NetTrex.MM/Code/docker-compose.override.yml` → Server `192.168.10.211`,
> DB `NetTrexMM`, User `trusr`.
> Komut şablonu: `sqlcmd -S "tcp:192.168.10.211,1433" -d NetTrexMM -U trusr -P '***' -C -l 20 -y 0 -s "|" -Q "..."`
> Not: `-W` ile `-y` birlikte kullanılamıyor; STRING_AGG çıktıları kırpılmasın diye `-y 0` seçildi.

| | |
|---|---|
| Toplam sorgu | 11 |
| Yazma sorgusu | **0** |

---

### #1 — Nesne tipi sayımları (tek satır özet)

Amaç: MM'de kaç SP / function / trigger / FK / CHECK / DEFAULT / unique index var — "hiç yok mu"
sorusunu tek sorguda cevaplamak.

```sql
SET NOCOUNT ON;
SELECT 'PROCEDURE' AS Tur, COUNT(*) AS Adet FROM sys.procedures
UNION ALL SELECT 'FN_scalar', COUNT(*) FROM sys.objects WHERE type = 'FN'
UNION ALL SELECT 'IF_inline_tvf', COUNT(*) FROM sys.objects WHERE type = 'IF'
UNION ALL SELECT 'TF_table_valued', COUNT(*) FROM sys.objects WHERE type = 'TF'
UNION ALL SELECT 'TRIGGER', COUNT(*) FROM sys.triggers WHERE parent_class = 1
UNION ALL SELECT 'FOREIGN_KEY', COUNT(*) FROM sys.foreign_keys
UNION ALL SELECT 'CHECK_CONSTRAINT', COUNT(*) FROM sys.check_constraints
UNION ALL SELECT 'DEFAULT_CONSTRAINT', COUNT(*) FROM sys.default_constraints
UNION ALL SELECT 'PK', COUNT(*) FROM sys.key_constraints WHERE type = 'PK'
UNION ALL SELECT 'UQ_constraint', COUNT(*) FROM sys.key_constraints WHERE type = 'UQ'
UNION ALL SELECT 'UNIQUE_INDEX_nonPK', COUNT(*) FROM sys.indexes WHERE is_unique = 1 AND is_primary_key = 0
UNION ALL SELECT 'TABLE', COUNT(*) FROM sys.tables;
```

### #2 — Tüm stored procedure adları (tek satır STRING_AGG)

Amaç: SP envanteri; `sp_UnverifiedDataCount_*`, sayaç SP'leri, rapor SP'leri gruplaması.

```sql
SET NOCOUNT ON;
SELECT COUNT(*) AS Adet,
       STRING_AGG(CAST(name AS nvarchar(max)), ', ') WITHIN GROUP (ORDER BY name) AS Procedurler
FROM sys.procedures;
```

### #3 — Function adları (varsa)

Amaç: MM function kullanıyor mu; kullanıyorsa adları.

```sql
SET NOCOUNT ON;
SELECT type_desc, COUNT(*) AS Adet,
       STRING_AGG(CAST(name AS nvarchar(max)), ', ') WITHIN GROUP (ORDER BY name) AS Adlar
FROM sys.objects WHERE type IN ('FN','IF','TF','FS','FT') GROUP BY type_desc;
```

### #4 — FK: referential action dağılımı + şema ailesi dağılımı

Amaç: ON DELETE CASCADE mı NO_ACTION mı; FK'lar hangi tablo ailelerinde yoğunlaşıyor.

```sql
SET NOCOUNT ON;
SELECT fk.delete_referential_action_desc AS OnDelete,
       fk.update_referential_action_desc AS OnUpdate,
       COUNT(*) AS Adet
FROM sys.foreign_keys fk
GROUP BY fk.delete_referential_action_desc, fk.update_referential_action_desc;
SELECT CASE WHEN OBJECT_NAME(fk.parent_object_id) LIKE 'Txn%' THEN 'Txn*'
            WHEN OBJECT_NAME(fk.parent_object_id) LIKE 'Prd%' THEN 'Prd*'
            WHEN OBJECT_NAME(fk.parent_object_id) LIKE 'Cus%' THEN 'Cus*'
            WHEN OBJECT_NAME(fk.parent_object_id) LIKE 'Acc%' THEN 'Acc*'
            WHEN OBJECT_NAME(fk.parent_object_id) LIKE 'Def%' THEN 'Def*'
            WHEN OBJECT_NAME(fk.parent_object_id) LIKE 'Batch%' THEN 'Batch*'
            ELSE 'diger' END AS Aile,
       COUNT(*) AS Adet,
       STRING_AGG(CAST(OBJECT_NAME(fk.parent_object_id) AS nvarchar(max)), ', ') AS Tablolar
FROM sys.foreign_keys fk GROUP BY CASE WHEN OBJECT_NAME(fk.parent_object_id) LIKE 'Txn%' THEN 'Txn*'
            WHEN OBJECT_NAME(fk.parent_object_id) LIKE 'Prd%' THEN 'Prd*'
            WHEN OBJECT_NAME(fk.parent_object_id) LIKE 'Cus%' THEN 'Cus*'
            WHEN OBJECT_NAME(fk.parent_object_id) LIKE 'Acc%' THEN 'Acc*'
            WHEN OBJECT_NAME(fk.parent_object_id) LIKE 'Def%' THEN 'Def*'
            WHEN OBJECT_NAME(fk.parent_object_id) LIKE 'Batch%' THEN 'Batch*'
            ELSE 'diger' END;
```

### #5 — FK isim kalıbı uyumu + `is_not_trusted` / `is_disabled`

Amaç: isim kalıbı `FK_<Tablo>_<Hedef>_<Kolon>` mi (EF default'u); kaç tanesi kalıba uyuyor.

```sql
SET NOCOUNT ON;
SELECT CASE WHEN fk.name = CONCAT('FK_', OBJECT_NAME(fk.parent_object_id), '_',
                                  OBJECT_NAME(fk.referenced_object_id), '_',
                                  (SELECT TOP 1 c.name FROM sys.foreign_key_columns fkc
                                     JOIN sys.columns c ON c.object_id = fkc.parent_object_id AND c.column_id = fkc.parent_column_id
                                    WHERE fkc.constraint_object_id = fk.object_id ORDER BY fkc.constraint_column_id))
            THEN 'EF_kalibi' ELSE 'farkli' END AS Kalip,
       COUNT(*) AS Adet,
       SUM(CAST(fk.is_not_trusted AS int)) AS NotTrusted,
       SUM(CAST(fk.is_disabled AS int)) AS Disabled
FROM sys.foreign_keys fk
GROUP BY CASE WHEN fk.name = CONCAT('FK_', OBJECT_NAME(fk.parent_object_id), '_',
                                  OBJECT_NAME(fk.referenced_object_id), '_',
                                  (SELECT TOP 1 c.name FROM sys.foreign_key_columns fkc
                                     JOIN sys.columns c ON c.object_id = fkc.parent_object_id AND c.column_id = fkc.parent_column_id
                                    WHERE fkc.constraint_object_id = fk.object_id ORDER BY fkc.constraint_column_id))
            THEN 'EF_kalibi' ELSE 'farkli' END;
SELECT name FROM sys.foreign_keys ORDER BY name;
```

### #6 — CHECK constraint'ler (ad + tanım)

Amaç: MM'de CHECK var mı, varsa ne tip kontroller.

```sql
SET NOCOUNT ON;
SELECT TOP (50) cc.name, OBJECT_NAME(cc.parent_object_id) AS Tablo,
       LEFT(cc.definition, 200) AS Tanim
FROM sys.check_constraints cc ORDER BY cc.name;
```

### #7 — DEFAULT constraint: tanım dağılımı + isim kalıbı uyumu

Amaç: en yaygın default değerler; `DF_<Tablo>_<Kolon>` kalıbı gerçekten uygulanıyor mu.

```sql
SET NOCOUNT ON;
SELECT LEFT(d.definition, 60) AS Tanim, COUNT(*) AS Adet
FROM sys.default_constraints d GROUP BY LEFT(d.definition, 60) ORDER BY Adet DESC;
SELECT CASE WHEN d.name = CONCAT('DF_', OBJECT_NAME(d.parent_object_id), '_',
                                 COL_NAME(d.parent_object_id, d.parent_column_id))
            THEN 'DF_kalibi' ELSE 'farkli' END AS Kalip, COUNT(*) AS Adet
FROM sys.default_constraints d
GROUP BY CASE WHEN d.name = CONCAT('DF_', OBJECT_NAME(d.parent_object_id), '_',
                                 COL_NAME(d.parent_object_id, d.parent_column_id))
            THEN 'DF_kalibi' ELSE 'farkli' END;
SELECT TOP (20) d.name, OBJECT_NAME(d.parent_object_id) AS Tablo FROM sys.default_constraints d
WHERE d.name <> CONCAT('DF_', OBJECT_NAME(d.parent_object_id), '_', COL_NAME(d.parent_object_id, d.parent_column_id))
ORDER BY d.name;
```

### #8 — PK dışı unique index/constraint listesi + filtered olanlar

Amaç: `UQ_*` mi `IX_*` mi; composite var mı; filtered (partial) unique index emsali var mı.

```sql
SET NOCOUNT ON;
SELECT i.name AS IndexAdi, OBJECT_NAME(i.object_id) AS Tablo,
       i.is_unique_constraint AS UQConstraint, i.has_filter AS Filtreli,
       LEFT(ISNULL(i.filter_definition,''), 120) AS Filtre,
       (SELECT COUNT(*) FROM sys.index_columns ic WHERE ic.object_id = i.object_id AND ic.index_id = i.index_id AND ic.is_included_column = 0) AS KolonSayisi,
       STUFF((SELECT ', ' + c.name FROM sys.index_columns ic JOIN sys.columns c ON c.object_id = ic.object_id AND c.column_id = ic.column_id
              WHERE ic.object_id = i.object_id AND ic.index_id = i.index_id AND ic.is_included_column = 0
              ORDER BY ic.key_ordinal FOR XML PATH('')), 1, 2, '') AS Kolonlar
FROM sys.indexes i JOIN sys.tables t ON t.object_id = i.object_id
WHERE i.is_unique = 1 AND i.is_primary_key = 0
ORDER BY OBJECT_NAME(i.object_id), i.name;
```

### #9 — Trigger listesi + History tablosu eşleşmesi

Amaç: trigger adları `<Tablo>Trigger` kalıbında mı; hangi tablolarda `*History` var ama trigger yok
(veya tersi); `StateId` kolonu olan tablolarla ilişkisi.

```sql
SET NOCOUNT ON;
SELECT tr.name AS TriggerAdi, OBJECT_NAME(tr.parent_id) AS Tablo, tr.is_disabled,
       CASE WHEN EXISTS (SELECT 1 FROM sys.tables h WHERE h.name = OBJECT_NAME(tr.parent_id) + 'History') THEN 1 ELSE 0 END AS HistoryVar
FROM sys.triggers tr WHERE tr.parent_class = 1 ORDER BY tr.name;
SELECT t.name AS HistoryTablo,
       CASE WHEN EXISTS (SELECT 1 FROM sys.triggers tr WHERE tr.parent_id = OBJECT_ID('dbo.' + REPLACE(t.name,'History',''))) THEN 1 ELSE 0 END AS TriggerVar
FROM sys.tables t WHERE t.name LIKE '%History' ORDER BY t.name;
SELECT COUNT(*) AS StateIdliTabloAdedi,
       STRING_AGG(CAST(OBJECT_NAME(c.object_id) AS nvarchar(max)), ', ') AS Tablolar
FROM sys.columns c JOIN sys.tables t ON t.object_id = c.object_id WHERE c.name = 'StateId';
```

### #10 — Bir trigger gövdesi + bir `sp_UnverifiedDataCount_*` gövdesi

Amaç: trigger `SELECT * FROM inserted` mi açık kolon listesi mi; UnverifiedDataCount SP'sinin kalıbı.

```sql
SET NOCOUNT ON;
SELECT LEFT(m.definition, 1200) AS Govde FROM sys.sql_modules m
JOIN sys.triggers tr ON tr.object_id = m.object_id WHERE tr.name = 'TxnMMTrigger';
SELECT TOP (2) OBJECT_NAME(m.object_id) AS Ad, LEFT(m.definition, 1500) AS Govde
FROM sys.sql_modules m WHERE OBJECT_NAME(m.object_id) LIKE 'sp[_]UnverifiedDataCount%'
ORDER BY OBJECT_NAME(m.object_id);
```

### #11 — `DefNumberGen` ve `DefCountMonitoring` satır formatı

Amaç: yeni Txn tablosu için eklenecek `DefNumberGen` satırının birebir formatı;
`DefCountMonitoring` tablosu MM'de mi Common'da mı, satır formatı ne.
TOP (50) gerekçesi: sayaç tablosu küçük (tahmini <60 satır) ve **tam listesi** gerekiyor —
yeni modülün alacağı `EntityColumnType` değerini ve `Definition` yazım kalıbını belirlemek için.

```sql
SET NOCOUNT ON;
SELECT TOP (50) EntityColumnType, LastNumber, Definition, LastUpdateDate
FROM DefNumberGen ORDER BY EntityColumnType DESC;
SELECT COUNT(*) AS DefNumberGenToplam, MAX(EntityColumnType) AS MaxType FROM DefNumberGen;
SELECT name FROM sys.tables WHERE name LIKE '%CountMonitoring%' OR name LIKE '%RefNumGen%';
```

#### #11b — `DefCountMonitoring` (NetTrexCommon DB'sinde)

```sql
-- -d NetTrexCommon
SET NOCOUNT ON;
SELECT TOP (50) Id, ModuleName, TableName, ProcedureName, Description FROM DefCountMonitoring ORDER BY Id DESC;
```
(kolon adları önce `sys.columns` ile doğrulandı — bkz. çıktı)
