# SQL Çıktıları — misyon-corporate-mm-api

---

## #1 — Corporate MM işlemleri canlıda nasıl dolu

```text
Id|LogicalReference|TxnTypeCode|PrdId|CustomerId|CorpAccNo|CorpGL|CorpWG|OutCorr|PIT|STId|Ccy|DealAmount|StateId
553330|TMMBRW2608100006|BRW|1|1009|27068|32000002|2|NULL|4|1|TRY|1000000|16
553307|TMMPLC2607240006|PLC|1|1086|27316|32000002|2|NULL|4|1|TRY|5000000|16
553305|TMMBRW2607240004|BRW|1|1086|27316|32000002|2|NULL|4|1|TRY|3333333|16
553289|TISBRW2607140001|BRW|3|2104|NULL|NULL|NULL|NULL|NULL|NULL|TRY|9000000|22
... (20 satır, kalanlar aynı desende: CustomerId 1086 → CorpAccNo 27316)
```

🔑 **Bulgular:**
- Corporate'ta `CorporateCurrentAccountNumber` **dolu ve müşteriye göre değişiyor**
  (CustomerId 1009 → 27068 · CustomerId 1086 → 27316). Interbank'ta bu alan NULL.
- `CorporateCurrentAccountGLCode = 32000002` ve `WorkGroupId = 2` bu kurulumda **sabit** görünüyor
  (tüm corporate satırlarda aynı) — ama tek kurulumdan genelleme yapılamaz.
- `OutgoingCorrespondentId` ve diğer muhabir alanları corporate'ta **NULL** — Eximbank'ta dolu.
- `PaymentInstructionTypeId = 4` (corporate) ↔ Eximbank işlemlerinde `1`. Farklı ödeme talimat tipi.
- Ürün hep `1` (MoneyMarket); Issue (3) satırında corporate hesap alanları da NULL.

---

## #2 — Corporate / interbank dağılımı

```text
IsFI|PrdId|TxnTypeCode|Adet
1|1|PLC|203      1|1|BRW|200     1|5|BRW|101     1|3|BRW|42      1|4|BRW|34
0|1|BRW|29       0|1|PLC|22      1|5|PLC|19      1|15|BRW|18     1|4|PLC|17
0|3|BRW|11       1|2|BRW|9       0|4|PLC|4       1|2|PLC|3       0|4|BRW|2
1|7|BRW|1        1|8|BRW|1
```

🔑 **Bulgular:**
- Corporate (IsFI=0) toplam **68 işlem**: MoneyMarket 51 · Issue 11 · Wakale 6.
- 🔴 **Murabaha (PrdId 5) corporate'ta HİÇ YOK** — 120 Murabaha işleminin tamamı interbank.
  Misyon'un istediği kombinasyon (Murabaha + Corporate) bu kurulumda **hiç denenmemiş**.
- Corporate hem BRW hem PLC yönünde kullanılıyor.

---

## #3 — Dış kaynaklı işlemlerin müşteri tipi

```text
SrcId|IsFI|Adet|Son
130|1|133|2026-03-16 11:58:09   (Bloomberg)
160|1|10 |2026-09-30 17:37:24   (Eximbank - bizim uç)
110|1|2  |2026-08-10 15:46:54   (Takasbank)
1324679|1|1|2026-09-12 18:25:16  (⚠️ tanımsız/kirli değer)
```

🔑 **Bulgu:** Dış kaynaktan açılmış işlemlerin **tamamı interbank** (IsFI=1). Corporate bir dış-sistem
entegrasyonu bu platformda **henüz hiç yapılmamış** — Misyon talebi yeni bir yüzey açıyor.
⚠️ `ExternalReferenceSourceId = 1324679` tanımlı kaynak listesinde yok; veri kirliliği, ayrıca bakılmalı.
