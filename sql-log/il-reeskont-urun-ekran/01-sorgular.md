# SQL Log — il-reeskont-urun-ekran — Sorgular

Sohbet: InterbankLoan reeskontunun InterestMethod'a göre ürün CalculationMethod'unu kullanması + ProductDefinition'a ekran görünürlük alanı (2026-11-09).
DB: `192.168.10.211` / `NetTrexMM` (kullanıcı `trusr`, parola maskeli). Hepsi salt-okunur SELECT.

| # | Amaç | Yazma? |
|---|------|--------|
| 1 | `TxnLoan` RateTypeId × InterestMethodId dağılımı — sabit faizli IL işlemlerinde InterestMethod ne kayıtlı; yeni kural (SimpleInterest → ürün metodu) mevcut açık işlemlerin kaçını etkiler | Hayır |
| 2 | Son 10 `LoanRevaluation` satırı — SL / IRR / TotalAmountNPV değerleri ve bağlı `AccEntryMainId`; koddaki "IL fişine TotalAmountNPV gider" tespitini veriyle doğrulamak | Hayır |
| 3 | #2'deki AccEntryMain'lerin `accEntry` bacak tutarları — fişteki tutarın SL mi, IRR mi, TotalAmountNPV mi olduğunu görmek | Hayır |

## Sorgu #1

```sql
SET NOCOUNT ON;
SELECT RateTypeId, InterestMethodId, IsMatured, COUNT(*) AS Adet
FROM dbo.TxnLoan
GROUP BY RateTypeId, InterestMethodId, IsMatured
ORDER BY RateTypeId, InterestMethodId, IsMatured;
```

## Sorgu #2

```sql
SET NOCOUNT ON;
SELECT TOP (10) Id, TxnId, CalculationDate, RateTypeId, InterestMethodId, PrincipalAmount,
       PeriodAccrualAmountSL, PeriodAccrualAmountIRR, TotalAmountNPV, PrincipalAmountNPV, AccEntryMainId
FROM dbo.LoanRevaluation
ORDER BY Id DESC;
```

## Sorgu #3

```sql
SET NOCOUNT ON;
SELECT TOP (20) e.Id, e.AccEntryMainId, e.TxnId, e.GLCode, e.Amount
FROM dbo.accEntry e
WHERE e.AccEntryMainId IN (SELECT TOP (5) AccEntryMainId FROM dbo.LoanRevaluation ORDER BY Id DESC)
ORDER BY e.Id DESC;
```

| # | Amaç | Yazma? |
|---|------|--------|
| 4 | `PrdProductDefinition` + `PrdProductDefinitionHistory` kolon listesi (sıra, tip, null, identity) — yeni trigger'ı açık kolon listesiyle yazmak ve History'ye aynı kolonları eklemek için | Hayır |
| 5 | `PrdProductDefinition` üzerindeki trigger(lar)ın adı, durumu ve tam tanımı — kullanıcı trigger'ın drop+create edilmesini istedi, güncel hali alınacak | Hayır |
| 6 | Ürünlerin `IsSameDay`/`IsZeroRate` değerleri — yeni `IsVisibleInInterbankLoan` backfill'inin hangi ürünleri 0 yapacağını görmek | Hayır |

## Sorgu #4

```sql
SET NOCOUNT ON;
SELECT OBJECT_NAME(c.object_id) AS Tbl, c.column_id, c.name, t.name AS type, c.max_length, c.precision, c.scale, c.is_nullable, c.is_identity
FROM sys.columns c JOIN sys.types t ON t.user_type_id = c.user_type_id
WHERE c.object_id IN (OBJECT_ID('dbo.PrdProductDefinition'), OBJECT_ID('dbo.PrdProductDefinitionHistory'))
ORDER BY Tbl, c.column_id;
```
(Kolon metadatası — satır sayısı tablo genişliği kadar, TOP uygulanmadı.)

## Sorgu #5

```sql
SET NOCOUNT ON;
SELECT tr.name, tr.is_disabled, OBJECT_DEFINITION(tr.object_id) AS Def
FROM sys.triggers tr WHERE tr.parent_id = OBJECT_ID('dbo.PrdProductDefinition');
```

## Sorgu #6

```sql
SET NOCOUNT ON;
SELECT TOP (20) Id, Code, IsSameDay, IsZeroRate, IsEnabled, StateId
FROM dbo.PrdProductDefinition
ORDER BY Id DESC;
```

| # | Amaç | Yazma? |
|---|------|--------|
| 7 | #4 tekrarı — #4-#6 `sqlcmd` istemci hatasıyla (`-W` ile `-y` birlikte) sunucuya HİÇ gitmeden düştü | Hayır |
| 8 | #5 tekrarı (trigger tanımı; uzun metin için `-y 0`, `-W` yok) | Hayır |
| 9 | #6 tekrarı | Hayır |

SQL metinleri #4 / #5 / #6 ile birebir aynı.

| # | Amaç | Yazma? |
|---|------|--------|
| 10 | Son 5 IL reeskont fişinin (`LoanRevaluation.AccEntryMainId`) ters fişi var mı, valörü ne — İş 1 geçiş günü riskinin (NPV fişi terslenmezse yeni SL/IRR fişiyle üst üste biner) doğrulanması | Hayır |
| 11 | Açık IL işlemleri: ürünün `AccountingCalculationMethodTypeId` × `InterestMethodId` dağılımı — İş 1'de kaç işlemin SL'ye, kaçının IRR'ye geçeceği | Hayır |
| 12 | Açık IL işlemlerinde faiz cash flow anaparası işlem anaparasından farklı olan (amortismanlı) işlem sayısı — IRR hesabının `TxnLoan.PrincipalAmount` kullanma riskinin ölçüsü | Hayır |

## Sorgu #10

```sql
SET NOCOUNT ON;
SELECT TOP (20) m.Id, m.TxnId, m.ValueDate, m.IsReverse, m.ReverseId, r.Id AS RevId, r.ValueDate AS RevValueDate, r.IsReverse AS RevIsReverse
FROM dbo.accEntryMain m
LEFT JOIN dbo.accEntryMain r ON r.Id = m.ReverseId
WHERE m.Id IN (SELECT TOP (5) AccEntryMainId FROM dbo.LoanRevaluation ORDER BY Id DESC)
ORDER BY m.Id DESC;
```

## Sorgu #11

```sql
SET NOCOUNT ON;
SELECT p.AccountingCalculationMethodTypeId, t.InterestMethodId, t.RateTypeId, COUNT(*) AS Adet
FROM dbo.TxnLoan t JOIN dbo.PrdProductDefinition p ON p.Id = t.ProductDefinitionId
WHERE t.IsMatured = 0
GROUP BY p.AccountingCalculationMethodTypeId, t.InterestMethodId, t.RateTypeId
ORDER BY 1, 2, 3;
```

## Sorgu #12

```sql
SET NOCOUNT ON;
SELECT COUNT(DISTINCT t.Id) AS AmortismanliAcikIslem
FROM dbo.TxnLoan t
JOIN dbo.TxnCashFlow c ON c.TxnId = t.Id AND c.FlowTypeId = 2
WHERE t.IsMatured = 0 AND c.PrincipalAmount <> t.PrincipalAmount;
```

| # | Amaç | Yazma? |
|---|------|--------|
| 13 | `TxnLoan.InterestMethodId` ile o işlemin faiz cash flow'larındaki `InterestMethodId` ayrışıyor mu — İş 1 kararının hangi alandan okunacağı (Update'te InterestMethod değişirse cash flow eski değerde kalabilir mi) | Hayır |

## Sorgu #13

```sql
SET NOCOUNT ON;
SELECT t.InterestMethodId AS TxnMethod, c.InterestMethodId AS CashFlowMethod, COUNT(DISTINCT t.Id) AS Islem
FROM dbo.TxnLoan t
JOIN dbo.TxnCashFlow c ON c.TxnId = t.Id AND c.FlowTypeId = 2
GROUP BY t.InterestMethodId, c.InterestMethodId
ORDER BY 1, 2;
```
