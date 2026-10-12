# 🔴 Fimple 3058 — defter hesabına referans alanı gönderiliyor (`36099200`)

**Tarih:** 2026-08-20
**Kaynak:** Kullanıcının Seq log'ları · `TMMBRW2608170002` (`TxnId 553336`), Execution Date `2026-08-20`
**Durum:** 🟥 **KONFİGÜRASYON sorunu — kod değişikliği YAPILMADI, kullanıcı onayı bekliyor**

---

## 1. Fimple'ın döndüğü hata

```json
{
  "TransactionId": 553336,
  "LogicalReference": "TMMBRW2608170002",
  "NewStatus": 1,
  "ReasonCode": "EXTERNAL_ERROR",
  "ReasonDetail": "Fimple Error => Code: 3058, Message: Hesap tanımında defter türündeki
                   muhasebe hesapları için referans türü ve referans no alanları boş olmalıdır.
                   Defter hesabı: (36099200)"
}
```

🟢 **İyi haber:** bu mesaj artık **doğru** görünüyor. Dünkü `Error parsing NaN value` /
*"Failed to parse the API response"* gizlemesi kalktı; Fimple'ın kendi iş hatası olduğu gibi
yukarı çıkıyor (`RefitExtension` düzeltmesi çalıştı — kullanıcı doğruladı).

## 2. Gönderilen gövde (log'dan)

```json
"Details": [
  { "SequenceNumber": 1, "GLAccount": "62600000", "CustomerId": "27253",
    "ReferenceType": "TreasuryAccount", "ReferenceNumber": "346178", "Debit": 20.42 },
  { "SequenceNumber": 2, "GLAccount": "36099200", "CustomerId": "27253",
    "ReferenceType": "TreasuryAccount", "ReferenceNumber": "346178", "Credit": 20.42 }
]
```

🔴 **2. satır** — `36099200` Fimple'da **defter (ledger) türü** bir hesap. Defter hesabı için
`ReferenceType` ve `ReferenceNumber` **boş** olmak zorunda; biz `TreasuryAccount` / `346178`
gönderiyoruz → Fimple **3058** ile reddediyor.

## 3. Kök sebep — nerede doluyor

`NetTrex.MM.Common.Mapper/External/Accounting/FimpleAccountingDetailModelMapper.cs:46-57`

```csharp
var isReferenceType = accountingEntryModel.CustomerAccountCode != null;

var referenceType = !isReferenceType ? null
    : !isPaymentGL ? nameof(FimpleAccountingReferenceType.TreasuryAccount)
    : fimpleAccountingReferenceType.ToString();

return new FimpleAccountingDetailModel(
    …
    ReferenceType:   referenceType,
    ReferenceNumber: accountingEntryModel.CustomerAccountCode,
    …);
```

🔑 **Kural tek bir şeye bakıyor: `CustomerAccountCode` null mı değil mi.** GL'in **defter hesabı
olup olmadığına bakmıyor** — bakamaz da, o bilgi Fimple'da.

Log'daki muhasebe kaydına bakınca iki satırın **ikisinde de** `CustomerAccountCode` dolu:

| Sıra | GL | `Source` | `AccAccountMapId` | `CustomerAccountCode` |
|---|---|---|---|---|
| 1 | `62600000` | `InterestExpense` | `23294` | `346178` |
| 2 | 🔴 **`36099200`** | `AccruedExpense` | 🔴 **`23298`** | 🔴 **`346178`** ← olmamalı |

Yani muhasebe motoru (`AccAccountMap` / rule `33340`) **defter hesabı için de müşteri hesap
kodu üretiyor**; mapper de görevini yapıp referans alanlarını dolduruyor.

## 4. 🔴 Bu Manuel Reeskont'a ÖZEL DEĞİL

Kullanıcının sorusunun kesin cevabı: **manuel mi batch mi hiç fark etmiyor.**

```
Manuel Reeskont Execute ──┐
                          ├─► RevaluationAccountingService
EOD Batch (RevaluationBatchItem) ──┘        │
                                            ▼
                             15_RevaluationAccountingSyncStep
                                            ▼
                     FimpleAccountingService.SendRevaluationAccountingAsync
                                            ▼
                          FimpleAccountingDetailModelMapper   ← hata BURADAN geçiyor
```

Mapper ve servis **paylaşılan**. Aynı transaction EOD batch'te de çalıştırılsa **aynı 3058**
hatasını alır. Bu bir Manuel Reeskont bug'ı **değil**, `AccAccountMap` konfigürasyonu sorunu.

⚠️ Bu kalem `00-PANO.md`'de **zaten açık** duruyordu: *"`AccAccountMap` config errors
(`36099200`/`36199200`)"*. Log bunu **doğruladı** — yeni bir bulgu değil, teyit.

## 5. Çözüm — doğru ev KONFİGÜRASYON

### ✅ Önerilen: `AccAccountMap` `23298` müşteri hesabı üretmesin

`36099200` defter hesabı olduğu için o kural satırının `CustomerAccountCode` üretmemesi gerekir.
`CustomerAccountCode` `null` olduğunda mapper **kendiliğinden** doğru davranıyor:

```csharp
var isReferenceType = accountingEntryModel.CustomerAccountCode != null;   // false
var referenceType = !isReferenceType ? null : …                          // null
ReferenceNumber: accountingEntryModel.CustomerAccountCode                // null
```

→ `ReferenceType: null`, `ReferenceNumber: null` → Fimple kabul eder. **Kod değişikliği YOK.**

🔵 Kontrol edilecek: `AccAccountMap.Id = 23298` satırı ve onu üreten kural (`RuleId 33340`,
`ComponentId 15568`) — `IsAccountNeeded` / hesap eşlemesi neden dolu geliyor.
Aynı soru `36199200` için de geçerli (aynı aileden, PANO'da birlikte açılmış).

### ⚠️ Alternatif (önerilmez): mapper'a defter hesabı listesi

Mapper'a "şu GL'ler defter hesabı" bilgisi verilebilirdi — ama:
- O bilgi **Fimple'ın** hesap tanımında; MM'de ikinci bir kopya tutmak **kaçınılmaz sapma** üretir
- `FimpleAccountingDetailModelMapper` **tüm** MM muhasebe akışlarında ortak (transaction, term
  payment, revaluation, reverse) → davranış değişikliği hepsini etkiler
- 2026-08-19 kuralı: *"paylaşılan dosyaya davranış değiştiren dokunuş yok"*

Bu yüzden **kod değiştirilmedi.**

## 6. Yan bulgu — `FxRate: 0`

Log'daki her iki detayda `"FxRate": 0.0`. TRY/TRY işlemde zararsız görünüyor ama
**PANO'daki açık kalem** (`FxRate` 0). Yabancı para bir reeskontta bu değer 0 giderse Fimple
tarafında kur hesabı yanlış olabilir. Ayrı olarak takip edilmeli.

## 7. Doğrulama adımı

`AccAccountMap` düzeltildikten sonra aynı transaction'ı tekrar dene. Log'da beklenen:

```json
{ "GLAccount": "36099200", "ReferenceType": null, "ReferenceNumber": null, "Credit": 20.42 }
```

ve sonuç `Succeeded` + statü `Not Reversed`.
