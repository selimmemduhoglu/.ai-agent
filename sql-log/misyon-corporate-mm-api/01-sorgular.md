# SQL Sorguları — misyon-corporate-mm-api

Bağlantı: `tcp:192.168.10.211,1433` · DB `NetTrexMM` · user `trusr` · `-P '***'`

**Bağlam:** Misyon Yatırım Bankası, Eximbank'a benzer bir API entegrasyonu istiyor ama **Corporate**
MM işlemi için (Eximbank interbank'tı). Corporate işlemin canlıda hangi alanlarla açıldığını
görmek, API sözleşmesinde hangi alanların istenmesi gerektiğini belirleyecek.

---

## #1 — Corporate MM işlemleri canlıda nasıl dolu

**Amaç:** `CustomerIsFinancialInstitution = 0` olan (corporate) işlemlerde hangi alanlar dolu,
hangileri null. Özellikle `CorporateCurrentAccountNumber` / `GLCode` / `WorkGroupId` üçlüsü ile
muhabir (correspondent) alanlarının corporate'ta boş kalıp kalmadığı.

```sql
SET NOCOUNT ON;
SELECT TOP (20) Id, LogicalReference, TxnTypeCode, TxnMmProductTypeId, CustomerId,
       CorporateCurrentAccountNumber, CorporateCurrentAccountGLCode, CorporateCurrentAccountWorkGroupId,
       OutgoingCorrespondentId, PaymentInstructionTypeId, SettlementTypeId,
       Ccy, DealAmount, StateId, CreatedDate
FROM dbo.TxnMM
WHERE CustomerIsFinancialInstitution = 0
ORDER BY Id DESC;
```

---

## #2 — Corporate / interbank dağılımı ve ürün kırılımı

**Amaç:** Corporate işlem bu kurulumda gerçekten kullanılıyor mu, hangi ürün ve yönle. Murabaha
corporate'ta açılıyor mu (Misyon murabaha istiyor).

```sql
SET NOCOUNT ON;
SELECT CustomerIsFinancialInstitution, TxnMmProductTypeId, TxnTypeCode, COUNT(*) AS Adet
FROM dbo.TxnMM
GROUP BY CustomerIsFinancialInstitution, TxnMmProductTypeId, TxnTypeCode
ORDER BY Adet DESC;
```

---

## #3 — Dış kaynaklı işlem kaynakları

**Amaç:** Hangi `ExternalReferenceSourceId` değerleri kullanımda — Misyon için yeni bir kaynak Id
gerekecek, mevcutları ve çakışmayı görmek lazım.

```sql
SET NOCOUNT ON;
SELECT ExternalReferenceSourceId, CustomerIsFinancialInstitution, COUNT(*) AS Adet,
       MIN(CreatedDate) AS Ilk, MAX(CreatedDate) AS Son
FROM dbo.TxnMM
WHERE ExternalReferenceSourceId IS NOT NULL
GROUP BY ExternalReferenceSourceId, CustomerIsFinancialInstitution
ORDER BY Adet DESC;
```
