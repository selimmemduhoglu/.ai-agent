# SQL Çıktıları — eximbank-fundsource-flag

---

## #1 — Murabaha ürününün fon kaynağı kolonları

```text
Id|Code|Name|UseFundSource|UseSubFundSource|IsEnabled
11|Post-Financing|Post-Financing|0|0|1
10|Securitization|Securitization|0|0|1
9|Syndication|Syndication|0|0|1
8|Gil|Gil|0|0|1
7|Pass|Pas|0|0|1
6|TermDeposit|Term Deposit|0|0|0
5|Murabaha|Murabaha|0|0|1
4|Wakale|Wakale|0|0|1
3|Issue|Bond Issue|0|0|1
2|Loan|Interbank Loan|0|0|1
1|MoneyMarket|Money Market|0|0|1
```

🔴 **Bulgu:** `PrdProductDefinition` tablosunda **hiçbir üründe** `UseFundSource` / `UseSubFundSource`
açık değil — 11 ürünün tamamı `0`. Murabaha (Id 5) ve Wakale (Id 4) dahil.

Sonuç: `product.UseFundSource && settings.UseFundSource` biçimindeki AND koşulu Eximbank akışında
**hiçbir zaman** sağlanamaz → yeni parametre işlevsiz kalır.

---

## #2 — Eximbank kaynaklı işlemlerde FundSourceId geçmişi

```text
Id|LogicalReference|ExternalReference|TxnMmProductTypeId|FundSourceId|SubFundSourceCode|CreatedDate
553404|TMRBRW2609300004|EXIM-TEST-007|5|NULL|NULL|2026-09-30 17:09:07.450
553403|TMRBRW2609300003|EXIM-TEST-006|5|NULL|NULL|2026-09-30 17:08:28.127
553402|TMRBRW2609300002|EXIM-TEST-005|5|NULL|NULL|2026-09-30 17:06:45.403
553401|TMRBRW2609300001|EXIM-TEST-004|5|NULL|NULL|2026-09-30 17:04:50.617
```

**Bulgu:** Bu kaynaktan açılmış **tüm** işlemlerde `FundSourceId` ve `SubFundSourceCode` NULL.
Yani davranış yeni bayrak geliştirmesinden **önce de** böyleydi — regresyon değil, ürün tanımı
kolonları zaten kapalı olduğu için `FundSourceId` hiç yazılmamış.

---

## #3 — DefFundSource referans satırları

```text
Id|Code|Name|ExternalCode|IsEnabled
4|InvestmentAgency|Investment Agency|DPI|1
3|PrivateFunds|Private Funds|DPS|0
2|ParticipationAccounts|Participation Accounts|DPD|1
1|EquityCapital|Equity Capital|EQC|1
```

**Bulgu:** `Eximbank:MM.FundSourceCode = 'EquityCapital'` parametresinin karşılığı var (Id 1) ve
aktif. Bayrak açıldığında lookup başarılı olacak, `FundSourceId = 1` yazılabilir.
