# SQL Sorguları — linked-transaction-development

## #1 — FX: TxnFX kolon tipleri (LinkedTransaction alanları)
**Amaç:** Wiki'deki MSSQL tip tablosu ile gerçek deployed Dev şema birebir mi, MM script'i buna göre yazılacak.
```sql
SET NOCOUNT ON;
SELECT c.name, t.name AS type, c.max_length, c.is_nullable
FROM sys.columns c
JOIN sys.types t ON t.user_type_id = c.user_type_id
WHERE c.object_id = OBJECT_ID('dbo.TxnFX')
  AND c.name IN ('TransactionOriginType','LinkedTransactionId','LinkedTransactionReference','LinkedTransactionTrader','LinkedTransactionReasonType')
ORDER BY c.column_id;
```

## #2 — FX: TxnFX son 20 kayıt (LinkedTransaction alanları)
**Amaç:** Gerçek veride None kalıcı mı yazılıyor mu, Generated satırlarda 4 alan dolu mu, görmek.
```sql
SET NOCOUNT ON;
SELECT TOP (20) Id, LogicalReference, TransactionOriginType, LinkedTransactionId, LinkedTransactionReference, LinkedTransactionTrader, LinkedTransactionReasonType
FROM dbo.TxnFX
ORDER BY Id DESC;
```

## #3 — FX: TransactionOriginType / LinkedTransactionReasonType dağılımı
**Amaç:** Canlıda hangi enum değerleri kullanılmış (None hiç yazılmamış mı doğrula).
```sql
SET NOCOUNT ON;
SELECT TransactionOriginType, LinkedTransactionReasonType, COUNT(*) AS Adet
FROM dbo.TxnFX
GROUP BY TransactionOriginType, LinkedTransactionReasonType
ORDER BY Adet DESC;
```

## #4 — MM: TxnMM kolon listesi (LinkedTransaction alanları zaten var mı)
**Amaç:** Script'i idempotent yazmak için mevcut şemayı doğrulamak.
```sql
SET NOCOUNT ON;
SELECT c.name, t.name AS type, c.max_length, c.is_nullable
FROM sys.columns c
JOIN sys.types t ON t.user_type_id = c.user_type_id
WHERE c.object_id = OBJECT_ID('dbo.TxnMM')
ORDER BY c.column_id;
```

## #5 — MM: TxnMM ExternalReferenceSourceId dağılımı (backfill kuralı için)
**Amaç:** "None ise dış referansı olan Imported, olmayan Manual" kuralının MM'de kaç satırı nasıl etkileyeceğini ölçmek.
```sql
SET NOCOUNT ON;
SELECT COUNT(*) AS Toplam,
       SUM(CASE WHEN ExternalReferenceSourceId IS NOT NULL THEN 1 ELSE 0 END) AS ImportedOlacak,
       SUM(CASE WHEN ExternalReferenceSourceId IS NULL THEN 1 ELSE 0 END) AS ManualOlacak
FROM dbo.TxnMM;
```

## #6 — MM: txnMMHistory satır sayısı
**Amaç:** History tablosuna aynı backfill'in uygulanabilirliğini (satır sayısı) ölçmek.
```sql
SET NOCOUNT ON;
SELECT COUNT(*) AS Toplam,
       SUM(CASE WHEN ExternalReferenceSourceId IS NOT NULL THEN 1 ELSE 0 END) AS ImportedOlacak,
       SUM(CASE WHEN ExternalReferenceSourceId IS NULL THEN 1 ELSE 0 END) AS ManualOlacak
FROM dbo.txnMMHistory;
```

## #7 — MM: TxnMMTrigger gövdesi
**Amaç:** db-script skill'i TxnMMHistory'nin trigger'la (açık kolon listesiyle) doldurulduğunu söylüyor,
uygulama kodunda Insert çağrısı yok (doğrulandı). Yeni 5 kolonun trigger'a da eklenmesi gerekiyor,
mevcut tam kolon listesini/sırasını almak için gövde okunuyor.
```sql
SELECT m.definition
FROM sys.sql_modules m
JOIN sys.triggers t ON t.object_id = m.object_id
WHERE t.name = 'TxnMMTrigger';
```

## #8 — MM: txnMMHistory satır sayısı migration SONRASI (kirlenme kontrolü)
**Amaç:** Backfill UPDATE'i (`UPDATE dbo.TxnMM SET TransactionOriginType = ...`) eski TxnMMTrigger'ı
FOR INSERT,UPDATE olarak tetikler mi, tetiklerse her satır için gereksiz bir History satırı
üretip üretmediğini doğrulamak. Migration'dan ÖNCE 3887 satırdı.
```sql
SET NOCOUNT ON;
SELECT COUNT(*) AS ToplamSimdi FROM dbo.txnMMHistory;
SELECT CAST(StateDate AS DATE) AS Gun, COUNT(*) AS Adet
FROM dbo.txnMMHistory
WHERE HistoryId > (SELECT MAX(HistoryId) - 1000 FROM dbo.txnMMHistory)
GROUP BY CAST(StateDate AS DATE)
ORDER BY Gun DESC;
```

## #9 — MM: txnMMHistory yeni satirlarin GERCEK olusma zamani (CreatedDate ile)
**Amac:** #8'deki 677 fazla satirin StateDate'e gore dagilmis gorunmesi (eski tarihli) backfill'in
yarattigi "sahte" satirlari gizliyor olabilir -- bu satirlarin TxnMM'den KOPYALANAN CreatedDate'i
degil, trigger'in kendisinin INSERT anini gormek icin HistoryId'nin en sonuncularini CreatedDate'e
gore kontrol ediyorum.
```sql
SET NOCOUNT ON;
SELECT TOP (20) HistoryId, Id, StateDate, CreatedDate, TransactionOriginType
FROM dbo.txnMMHistory
ORDER BY HistoryId DESC;
```

## #10 — MM: txnMMHistory tablosunun kendi trigger'i var mi
**Amac:** Backfill'in txnMMHistory'ye yazan ikinci UPDATE'i de kendi tetiklediği bir
trigger yüzünden benzer bir kirlenme yaratıyor mu, doğrulamak.
```sql
SET NOCOUNT ON;
SELECT t.name, OBJECT_NAME(t.parent_id) AS TabloAdi, t.is_disabled
FROM sys.triggers t
WHERE OBJECT_NAME(t.parent_id) = 'txnMMHistory';
```

## #11 — MM: RolloverParentTransactionId dolu ama LinkedTransactionId bos olan satir sayisi
**Amac:** RolloverParentTransactionId -> LinkedTransactionId konsolidasyonu icin mutabakat script'inin
(2-NetTrexMM-RolloverParentTransactionId-Drop.sql) kac satiri etkileyecegini onceden gormek.
```sql
SET NOCOUNT ON;
SELECT COUNT(*) AS TxnMMEtkilenecek FROM dbo.TxnMM WHERE RolloverParentTransactionId IS NOT NULL AND LinkedTransactionId IS NULL;
SELECT COUNT(*) AS HistoryEtkilenecek FROM dbo.txnMMHistory WHERE RolloverParentTransactionId IS NOT NULL AND LinkedTransactionId IS NULL;
```
