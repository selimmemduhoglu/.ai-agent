# SQL Log — productdefinition-edit-fix — Sorgular

| # | Amaç | Yazma? |
|---|------|--------|
| 1 | `PrdProductDefinition` Order kolonunda çift değer var mı — kullanıcı Edit+Save'de "30 already exists" hatası alıyor, Order=30 gerçekten iki satırda mı yoksa validator kendi kaydını hariç tutamıyor mu anlamak için | Hayır |
| 2 | Order=30 olan satır(lar)ın Id, Code, Order değerleri — validator'ın `IsOrderUniqueAsync(order, id)` self-exclude mantığının doğru çalışıp çalışmadığını netleştirmek için | Hayır |

## Sorgu #1

```sql
SET NOCOUNT ON;
SELECT [Order], COUNT(*) AS Adet
FROM dbo.PrdProductDefinition
GROUP BY [Order]
HAVING COUNT(*) > 1
ORDER BY [Order];
```

## Sorgu #2

```sql
SET NOCOUNT ON;
SELECT TOP (20) Id, Code, Name, [Order], StateId, IsEnabled
FROM dbo.PrdProductDefinition
ORDER BY Id DESC;
```
