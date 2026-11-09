# 01-sorgular.md — colmanagement-db-kurulum-scriptleri

Amac: ColManagement DB kurulum scriptlerini (faz-4) yazarken kod/dokumandan cikarilamayan 4 noktayi
dogrulamak icin. Hepsi SELECT, salt-okunur.

## Q1 — NetTrexCommon: mevcut modullerin FrameworkMenu kok/parent deseni

```sql
SET NOCOUNT ON;
SELECT TOP (20) Id, MenuKey, ApplicationName, MenuType, ParentId, Value, ForcedUrl, IsActive
FROM FrameworkMenu
WHERE ApplicationName = N'Trex.WebUI' AND ParentId IS NULL
ORDER BY Id DESC;
```

## Q2 — NetTrexCommon: General:AvailableModules guncel degeri

```sql
SET NOCOUNT ON;
SELECT TOP (20) Id, OptionPath, OptionName, Value
FROM FrameworkParameter
WHERE OptionPath = N'General' AND OptionName = N'AvailableModules'
ORDER BY Id DESC;
```

## Q3 — NetTrexMM: sp_GetNewNumbers / sp_GetNewRefNumber bu DB'de var mi (TrexFramework'ten mi geliyor)

```sql
SET NOCOUNT ON;
SELECT TOP (20) ROUTINE_NAME, ROUTINE_TYPE, ROUTINE_SCHEMA
FROM INFORMATION_SCHEMA.ROUTINES
WHERE ROUTINE_NAME IN (N'sp_GetNewNumbers', N'sp_GetNewRefNumber')
ORDER BY ROUTINE_NAME DESC;
```

## Q4 — NetTrexOPTFX (erisilebiliyorsa): PrdInstrument kolon tipleri

```sql
SET NOCOUNT ON;
SELECT TOP (20) COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH, IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = N'PrdInstrument'
ORDER BY ORDINAL_POSITION DESC;
```

---

## 2026-10-15 ikinci tur — baglanti geri geldi (TCP test basarili), parola MM'in kendi
docker-compose.override.yml'inden alindi (ayni sunucu/login, farkli DB). Asagidakiler TEKRAR
denendi + yeni sorular eklendi.

## Q5 — NetTrexAcc: AccEntryMain Id araligi (modullerin Id sayac baslangicini anlamak icin,
kullanicinin kendi istegi)

```sql
USE NetTrexAcc;
SET NOCOUNT ON;
SELECT TOP (20) TxnId, Id FROM AccEntryMain ORDER BY Id DESC;
```

## Q5b — NetTrexAcc: TxnId'nin ilk 2 hanesine gore dagilim (hangi modul prefix'i ne kadar yer
kaplamis, 20 satirlik ornek yerine AGREGE ozet — TOP(20) kuralinin amaci ham satir sizdirmamak,
bu GROUP BY zaten ozet)

```sql
USE NetTrexAcc;
SET NOCOUNT ON;
SELECT LEFT(CAST(TxnId AS VARCHAR(20)), 2) AS Prefix2, COUNT(*) AS Cnt, MIN(TxnId) AS MinTxnId, MAX(TxnId) AS MaxTxnId
FROM AccEntryMain
GROUP BY LEFT(CAST(TxnId AS VARCHAR(20)), 2)
ORDER BY Prefix2 ASC;
```

## Q5c — NetTrexAcc: AccEntryMain'de modul ayrimini tasiyan kolon var mi (ProductCode/TxnTypeCode)

```sql
USE NetTrexAcc;
SET NOCOUNT ON;
SELECT TOP (20) ProductCode, TxnTypeCode, COUNT(*) AS Cnt
FROM AccEntryMain
GROUP BY ProductCode, TxnTypeCode
ORDER BY ProductCode ASC;
```

## Q5d — NetTrexAcc: prefix "77" ile baslayan TxnId'lerin ProductCode/TxnTypeCode'u (ColManagement'in
kendi ModulePrefix=77 ile cakisan GERCEK bir modul mu yoksa ColManagement'in kendi onceki test
verisi mi anlamak icin — Q5b'de 114 satir, 775..77994 araligi gorundu)

```sql
USE NetTrexAcc;
SET NOCOUNT ON;
SELECT TOP (20) ProductCode, TxnTypeCode, MIN(TxnId) AS MinTxnId, MAX(TxnId) AS MaxTxnId, COUNT(*) AS Cnt
FROM AccEntryMain
WHERE CAST(TxnId AS VARCHAR(20)) LIKE '77%' AND LEN(CAST(TxnId AS VARCHAR(20))) IN (3,4,5,6,7)
GROUP BY ProductCode, TxnTypeCode
ORDER BY ProductCode ASC;
```

## Q5e — NetTrexAcc: ProductCode bazinda TxnId araligi (Q5d sonrasi dogal devam sorgusu, geriye
donuk eklendi — hangi ProductCode'un hangi prefix'i kullandigini kesinlestirmek icin)

```sql
USE NetTrexAcc;
SET NOCOUNT ON;
SELECT TOP (20) ProductCode, MIN(TxnId) AS MinTxnId, MAX(TxnId) AS MaxTxnId, COUNT(*) AS Cnt
FROM AccEntryMain
GROUP BY ProductCode
ORDER BY Cnt DESC;
```

## Q6 — NetTrexMM: tum stored procedure envanteri (hangi SP'ler var, ColManagement'e hangisi lazim)

```sql
USE NetTrexMM;
SET NOCOUNT ON;
SELECT TOP (20) name, create_date, modify_date
FROM sys.procedures
ORDER BY name ASC;
```

## Q7 — NetTrexMM: sp_GetNewNumbers / sp_GetNewRefNumber tam govdesi (ColManagement'e aynen tasimak icin)

```sql
USE NetTrexMM;
SET NOCOUNT ON;
SELECT OBJECT_DEFINITION(OBJECT_ID(N'dbo.sp_GetNewNumbers')) AS sp_GetNewNumbers_Body,
       OBJECT_DEFINITION(OBJECT_ID(N'dbo.sp_GetNewRefNumber')) AS sp_GetNewRefNumber_Body;
```

## Q8 — NetTrexColManagement: tum tablolarin satir sayisi (kullanicinin az once calistirdigi
kurulum scriptlerinin gercekten olusup olusmadigini dogrulamak icin — 51 ayri TOP(20) yerine
TEK idari sorgu, tablo basina veri degil yalniz satir sayisi donuyor)

```sql
USE NetTrexColManagement;
SET NOCOUNT ON;
SELECT t.name AS TableName, SUM(p.rows) AS RowCnt
FROM sys.tables t
JOIN sys.partitions p ON t.object_id = p.object_id AND p.index_id IN (0,1)
GROUP BY t.name
ORDER BY t.name ASC;
```

## Q9 — NetTrexMM: tum fiziksel tablo listesi ("ortak tablolardan almadigim kalmis mi" kontrolu icin)

```sql
USE NetTrexMM;
SET NOCOUNT ON;
SELECT name FROM sys.tables ORDER BY name ASC;
```

## Q10 (Q1 tekrar) — NetTrexCommon: FrameworkMenu kok/parent deseni

```sql
USE NetTrexCommon;
SET NOCOUNT ON;
SELECT TOP (20) Id, MenuKey, ApplicationName, MenuType, ParentId, Value, ForcedUrl, IsActive
FROM FrameworkMenu
WHERE ApplicationName = N'Trex.WebUI' AND ParentId IS NULL
ORDER BY Id DESC;
```

## Q11 (Q2 tekrar) — NetTrexCommon: General:AvailableModules guncel degeri

```sql
USE NetTrexCommon;
SET NOCOUNT ON;
SELECT TOP (20) Id, OptionPath, OptionName, Value
FROM FrameworkParameter
WHERE OptionPath = N'General' AND OptionName = N'AvailableModules'
ORDER BY Id DESC;
```

## Q13 — NetTrexCommon: FrameworkMenuType gecerli degerler (script 3 FK ihlali -- MenuType=1/2
   kullanilmis, FrameworkMenuType'ta yoklar; kullanicinin canli hata ciktisi geldi 2026-10-15)

```sql
USE NetTrexCommon;
SET NOCOUNT ON;
SELECT TOP (20) * FROM FrameworkMenuType ORDER BY 1 ASC;
```

## Q14 — NetTrexCommon: mevcut MM/root menu satirlarinin gercek MenuType degerleri (root grup
   dugumu mu yoksa ekran dugumu mu hangi MenuType'i kullaniyor)

```sql
USE NetTrexCommon;
SET NOCOUNT ON;
SELECT TOP (20) Id, MenuKey, MenuType, Value, ForcedUrl, ParentId
FROM FrameworkMenu
WHERE Id IN (1,12,13,17,18,19,20) OR MenuKey LIKE N'%Treasury%'
ORDER BY Id ASC;
```

## Q12 (Q4 tekrar) — NetTrexOPTFX: PrdInstrument kolon tipleri

```sql
USE NetTrexOPTFX;
SET NOCOUNT ON;
SELECT TOP (20) COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH, IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = N'PrdInstrument'
ORDER BY ORDINAL_POSITION DESC;
```
