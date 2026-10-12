# SQL Sorguları — collateral-db-tablo-id-stratejisi

Amaç: Yeni `NetTrexCollateral` DB'si için tablo envanteri ve Id stratejisi (IDENTITY vs `DefNumberGen`)
kararını `NetTrexMM` · `NetTrexOPTFX` · `NetTrexDerivSWP` üzerinden **ölçümle** belirlemek.

Bağlantı: `tcp:192.168.10.211,1433` · User `trusr` · `-P '***'` · SALT-OKUNUR (yalnız SELECT)

---

## #1 — `DefNumberGen` kolon şeması (3 DB)

**Amaç:** Sayaç tablosunun kolonları ne, üç DB'de aynı mı — doğru kolon adlarıyla içerik çekebilmek için.

```sql
SET NOCOUNT ON;
SELECT 'MM' AS Db, c.name, t.name AS Typ FROM NetTrexMM.sys.columns c
 JOIN NetTrexMM.sys.types t ON t.user_type_id=c.user_type_id
 WHERE c.object_id = OBJECT_ID('NetTrexMM.dbo.DefNumberGen')
UNION ALL
SELECT 'OPTFX', c.name, t.name FROM NetTrexOPTFX.sys.columns c
 JOIN NetTrexOPTFX.sys.types t ON t.user_type_id=c.user_type_id
 WHERE c.object_id = OBJECT_ID('NetTrexOPTFX.dbo.DefNumberGen')
UNION ALL
SELECT 'DERIVSWP', c.name, t.name FROM NetTrexDerivSWP.sys.columns c
 JOIN NetTrexDerivSWP.sys.types t ON t.user_type_id=c.user_type_id
 WHERE c.object_id = OBJECT_ID('NetTrexDerivSWP.dbo.DefNumberGen')
ORDER BY Db, name;
```

---

## #2 — `DefNumberGen` içeriği (3 DB)

**Amaç:** Hangi tablolar sayaçtan besleniyor; OPTFX/DerivSWP sayacı fiilen kullanıyor mu (LastNumber > 0?).

```sql
SET NOCOUNT ON;
SELECT 'MM' AS Db, EntityColumnType, Definition, LastNumber, LastUpdateDate FROM NetTrexMM.dbo.DefNumberGen
UNION ALL SELECT 'OPTFX', EntityColumnType, Definition, LastNumber, LastUpdateDate FROM NetTrexOPTFX.dbo.DefNumberGen
UNION ALL SELECT 'DERIVSWP', EntityColumnType, Definition, LastNumber, LastUpdateDate FROM NetTrexDerivSWP.dbo.DefNumberGen
ORDER BY Db, EntityColumnType;
```

---

## #3 — Tablo sayısı + IDENTITY özeti (3 DB)

**Amaç:** Her DB'de kaç tablo var, kaçı IDENTITY kolona sahip — tam listeyi çekmeden önce büyüklüğü ölçmek.

```sql
SET NOCOUNT ON;
SELECT 'MM' AS Db, COUNT(*) AS Tablolar,
       SUM(CASE WHEN EXISTS(SELECT 1 FROM NetTrexMM.sys.columns c WHERE c.object_id=t.object_id AND c.is_identity=1) THEN 1 ELSE 0 END) AS IdentityVar
FROM NetTrexMM.sys.tables t
UNION ALL ... (OPTFX, DERIVSWP aynı)
```

> ❌ **#3 BAŞARISIZ** — `Msg 130: Cannot perform an aggregate function on an expression containing an aggregate or a subquery.`
> (`SUM(CASE WHEN EXISTS(...))` kabul edilmiyor.) → #4 ile türetilmiş tablo kullanılarak tekrarlandı.

---

## #4 — Tablo sayısı + IDENTITY özeti (türetilmiş tablo ile)

**Amaç:** #3 ile aynı.

```sql
SET NOCOUNT ON;
SELECT Db, COUNT(*) AS Tablolar, SUM(HasIdent) AS IdentityVar, SUM(NonDbo) AS DboDisi FROM (
  SELECT 'MM' AS Db, (SELECT COUNT(*) FROM NetTrexMM.sys.identity_columns i WHERE i.object_id=t.object_id) ...
) x GROUP BY Db;
```

---

## #5 — 3 DB'nin TAM tablo listesi, pivot (şema · IDENTITY · satır sayısı)

**Amaç:** Kesişim analizi. Her tablo adı için üç DB'de var mı, IDENTITY mi (`I`/`N`), kaç satır.
Değer biçimi: `I:<satır>` = IDENTITY var · `N:<satır>` = IDENTITY yok · boş = o DB'de tablo yok.

```sql
WITH a AS ( <3 DB için> SELECT Db, SCHEMA_NAME(t.schema_id) Sch, t.name,
  CASE WHEN (SELECT COUNT(*) FROM <db>.sys.identity_columns i WHERE i.object_id=t.object_id)>0 THEN 'I' ELSE 'N' END Ident,
  (SELECT SUM(p.rows) FROM <db>.sys.partitions p WHERE p.object_id=t.object_id AND p.index_id IN (0,1)) Rws
  FROM <db>.sys.tables t )
SELECT Sch, name, MAX(CASE WHEN Db='MM' THEN Ident+':'+CAST(Rws AS varchar) END) MM, ... GROUP BY Sch, name ORDER BY Sch, name;
```

---

## #6 — IDENTITY olmayan tabloların `Id` kolonu var mı (MM)

**Amaç:** IDENTITY olmayanları üç gruba ayırabilmek (sayaçtan beslenen / dışarıdan Id gelen referans tablosu /
Id kolonu hiç olmayan). Id kolonu tipi + PK kolon adları ile.

```sql
SET NOCOUNT ON;
SELECT t.name, ISNULL(ty.name,'YOK') AS IdTip,
  STUFF((SELECT ','+c2.name FROM sys.index_columns ic JOIN sys.columns c2 ON ... FOR XML PATH('')),1,1,'') AS PK
FROM sys.tables t LEFT JOIN sys.columns c ON c.object_id=t.object_id AND c.name='Id' ...
WHERE NOT EXISTS (SELECT 1 FROM sys.identity_columns i WHERE i.object_id=t.object_id)
ORDER BY t.name;
```

---

## #7 — OPTFX / DerivSWP: ana işlem ve muhasebe tablolarının Id tipi + PK

**Amaç:** `TxnTransaction`, `AccEntry*`, `ProductDefinition` Id'si IDENTITY mi sayaç mı — Collateral'ın
`TxnCollateral` kararı buna bağlı.

```sql
SET NOCOUNT ON;
SELECT 'OPTFX' Db, t.name, ty.name IdTip, <is_identity>, <PK> FROM NetTrexOPTFX.sys.tables t ...
WHERE t.name IN ('TxnTransaction','TxnTransactionHistory','AccEntry','AccEntryMain','AccEngineGeneratedAccountRule','ProductDefinition','TxnNote','TxnSync','TxnDocument')
UNION ALL <DerivSWP aynı>;
```

---

## #8 — IDENTITY kolonu hangi kolon (History tabloları tuzağı)

**Amaç:** #5 pivotundaki `I` işareti "Id IDENTITY" demek değil — History tablolarında IDENTITY başka bir
kolonda olabilir. Doğrulamak için IDENTITY kolon adlarını listele.

```sql
SET NOCOUNT ON;
SELECT 'MM' Db, t.name, c.name AS IdentityCol FROM NetTrexMM.sys.tables t JOIN NetTrexMM.sys.identity_columns c ON c.object_id=t.object_id WHERE t.name LIKE '%History%' OR t.name IN ('TxnMMDetail','TxnCashFlow','BatchLog','TxnSync')
UNION ALL <OPTFX, DSWP>;
```

---

## #9 — Sunucudaki NetTrex* veritabanları

**Amaç:** `NetTrexCollateral` zaten var mı; muhasebe motoru DB'leri (`NetTrexAcc*`) ayrı mı.

```sql
SET NOCOUNT ON;
SELECT TOP (50) name, create_date FROM sys.databases WHERE name LIKE 'NetTrex%' ORDER BY name;
```

> #9 çıktısı `NetTrexAcc_*` kopyalarıyla doldu (TOP 50 kesildi) → #10 ile daraltıldı.

## #10 — NetTrex* DB'leri, `NetTrexAcc_*` kopyaları hariç

```sql
SET NOCOUNT ON;
SELECT TOP (50) name FROM sys.databases
WHERE (name LIKE 'NetTrex%' OR name LIKE '%Collateral%') AND name NOT LIKE 'NetTrexAcc[_]%' ORDER BY name;
```

> #10 çıktısı da `NetTrexCommon_*` kopyalarıyla doldu → #11 ile yalnız Collateral arandı.

## #11 — `%Collateral%` adlı DB var mı

```sql
SET NOCOUNT ON;
SELECT TOP (20) name FROM sys.databases WHERE name LIKE '%Collateral%' ORDER BY name;
```
