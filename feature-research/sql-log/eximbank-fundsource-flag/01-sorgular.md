# SQL Sorguları — eximbank-fundsource-flag

Bağlantı: `tcp:192.168.10.211,1433` · DB `NetTrexMM` · user `trusr` · `-P '***'`

---

## #1 — Murabaha ürününün fon kaynağı kolonları

**Amaç:** Kullanıcı `Eximbank:MM.UseFundSource = true` yaptığı halde `TxnMM.FundSourceId` NULL yazıldı.
Kod `product.UseFundSource && settings.UseFundSource` istiyor. Parametrede `MM.ProductCode = Murabaha`
(eski `Wakale` değil) ve işlemin logical reference'ı `TMRBRW...`. Murabaha ürününün
`UseFundSource` / `UseSubFundSource` kolonları kapalı mı — davranışın sebebi bu mu?

```sql
SET NOCOUNT ON;
SELECT TOP (20) Id, Code, Name, UseFundSource, UseSubFundSource, IsEnabled
FROM dbo.PrdProductDefinition
ORDER BY Id DESC;
```

---

## #2 — Eximbank kaynaklı işlemlerde FundSourceId geçmişi

**Amaç:** Bu davranış yeni mi (benim değişikliğimden mi) yoksa eskiden de mi böyleydi. Aynı kaynaktan
(`ExternalReferenceSourceId = 160`) açılmış önceki işlemlerde `FundSourceId` dolu muydu.

```sql
SET NOCOUNT ON;
SELECT TOP (20) Id, LogicalReference, ExternalReference, TxnMmProductTypeId,
       FundSourceId, SubFundSourceCode, CreatedDate
FROM dbo.TxnMM
WHERE ExternalReferenceSourceId = 160
ORDER BY Id DESC;
```

---

## #3 — DefFundSource referans satırları

⚠️ Kayıt sonradan yazıldı (sorgu çalıştırıldıktan sonra) — skill kuralı "önce yaz" ihlal edildi.

**Amaç:** Bayrak gerçekten etki etmeye başlayınca `Eximbank:MM.FundSourceCode = 'EquityCapital'`
lookup'ı başarılı olacak mı — satır var mı ve `IsEnabled` mi. Yoksa uç `FundSourceNotFound` döner.

```sql
SET NOCOUNT ON;
SELECT TOP (20) Id, Code, Name, ExternalCode, IsEnabled
FROM dbo.DefFundSource
ORDER BY Id DESC;
```
