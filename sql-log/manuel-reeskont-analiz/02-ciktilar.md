# SQL Çıktıları — Sohbet: `manuel-reeskont-analiz`

> 🔴 **Denetim kaydı.** [`01-sorgular.md`](01-sorgular.md) ile **aynı `#` numarası** ile eşleşir.
> Çıktı **ham** yazılır — kırpılmışsa açıkça belirtilir.
> Kullanıcının talimatı: *"her SQL'e bağlanıp sorduğun soruyu ve response'unu görmek istiyorum,
> **istisnasız hepsinin**"*

---

## 8 — Veritabanları ✅

Sunucuda **çok sayıda** DB var. `NetTrex%` filtresiyle ilgili olanlar (kısaltıldı):

```text
NetTrexAcc, NetTrexAcc_132…_135, NetTrexAcc_Dev, NetTrexAcc_P, NetTrexAcc_<müşteri>…  (~50 varyant)
NetTrexArchive
NetTrexCommon, NetTrexCommon_132…  
NetTrexMM, NetTrexMM_Dev  (bkz. #6)
```

**Yorum:** Her modülün **kendi DB'si** var (`NetTrexMM`, `NetTrexAcc`, `NetTrexCommon`, `NetTrexFx`…)
ve her biri için müşteri/sürüm varyantları (`_132`, `_Dev`, `_HedefProd`, `_P`…).
🔴 **Doğru varyantı seçmek kritik** — `NetTrexAcc` ile `NetTrexAcc_Dev` farklı veri taşır.

---

## 9-10 — `NetTrexAcc` tablo envanteri ✅

**43 tablo.** Kayıt sayısına göre ilk 30:

```text
TableName                        Kayit
AccEntry                        163886   ← fiş SATIRLARI (borç/alacak)
AccEntryMain                     44715   ← fiş BAŞLIKLARI
AccEngineAccountRuleHistory      12689
AccEngineAccountRule              8655   ← GL KURALLARI
AccEngineComponentHistory         4490
AccAccountMapHistory              4462
AccAccountMap                     4030
AccEngineComponent                3655
AccEngineGroupHistory             2046
AccEngineEventHistory             1313
AccEngineGroup                    1139
AccEngineComponentAccount         1072
AccEngineAccount                   853
AccEngineEvent                     591   ← OLAYLAR
AccEngineItem                      521   ← ÜRÜN AĞACI
AccEngineDynamicRuleHistory        474
AccEngineItemHistory               426
AccEngineDynamicRule               419
AccEngineComponentType             153
AccEngineItemCode                   88
CurrencyPair                        78
AccEngineModelDefinitionHistory     71
Currency                            45
AccEngineModelDefinition            23
AccEngineAccountHistory             20
AccEngineEventType                  18
AccEngineItemType                   18
AccEngineDynamicMap                 11
DefNumberGen                        11
AccEngineItemCodeHistory             5
```

**Yorum:** `NetTrexAcc` bir **muhasebe kural motoru** — her tanım tablosunun bir `*History` ikizi var
(maker-checker/versiyonlama).

---

## 11 — `AccEngineEvent` (ilk deneme ❌, sonra ✅)

❌ İlk sorgu hata verdi — kolon adları tahmin edilmişti:

```text
Msg 207: Invalid column name 'Name'.
Msg 207: Invalid column name 'Code'.
Msg 207: Invalid column name 'EventTypeId'.
```

✅ Gerçek şema:

```text
AccEngineEvent:  Id · ItemId · EventTypeCode · ModifiedBy · ModifiedDate · EventDescriptionDynamicRuleId
AccEngineItem:   Id · ItemCode · ParentId · Path · ModelDefinitionId · StateId/Date/Maker · TemplateId
AccEngineGroup:  Id · EventId · ValidationRuleId · Order · ModifiedBy/Date · StateId/Date/Maker
AccEngineComponent: Id · GroupId · ComponentTypeCode · ValidationRuleId · Order · ModifiedBy/Date
AccEngineAccountRule: Id · ComponentId · GLCode · CustomerCodeSource · CustomerAccountCodeSource ·
                      DebitCredit · CalculationRuleId · AmountSource · TxnNoSource · ValueDateSource ·
                      TxnDateSource · CcySource · FcySource · LcyEqvtSource · FcyAmtSource ·
                      ReverseRebook · CommentSource · CommentRuleId
```

**`EventTypeCode` dağılımı:**

```text
OnInsert 169 · OnEODDaily 91 · OnEOD 64 · OnBOD 64 · OnOpening 64 ·
OnRevaluation 36 ← REESKONT · OnMaturation 33 · OnPayment 13 ·
OnPremiumSettlement 12 · OnExerciseSettlement 12 · OnAmortization 10 · OnFee 9 ·
OnCustomerPaymentOutgoing 5 · OnCustomerPaymentIncoming 5 · OnCouponPayment 4
```

---

## 12 — `NetTrexAcc.AccEntryMain` şeması ✅ (MM ile karşılaştırma)

```text
Id int · Description nvarchar · ValueDate datetime · BusinessKey bigint · MessageKey bigint ·
TxnId int · TxnTypeCode nvarchar · IsReverse bit · ReverseId int · ExternalState nvarchar ·
ExternalStateDescription nvarchar · StateId int · StateDate datetime · StateMaker nvarchar ·
ProductCode nvarchar · Type int · Flags int · ExtendedText1..5 nvarchar
```

🔴 **MM'deki ile 3 FARK:**

| Kolon | `NetTrexMM` | `NetTrexAcc` |
|---|---|---|
| `ValueDate` | **`date`** | **`datetime`** |
| `TxnId` | **`bigint`** | **`int`** |
| Bayrak kolonu | **`Flag`** | **`Flags`** (çoğul) |

→ İki şema **kopya ama birebir değil**. Manuel Reeskont MM'in kendi `AccEntryMain`'ine yazıyor.

---

## 15-16 — Muhasebe motoru ürün ağacı ve `OnRevaluation` ✅

**`OnRevaluation` kuralı olan ürünler (ilk 25):**

```text
TREX/BRWPLC1/LOAN/BRW/{FCY,LCY}/            ← MM Loan borçlanma
TREX/BRWPLC1/LOAN/PLC/{FCY,LCY}/            ← MM Loan plasman
TREX/BRWPLC1/MONEYMARKET/BRW/{FCY,LCY}/     ← MM borçlanma
TREX/BRWPLC1/MONEYMARKET/PLC/{FCY,LCY}/     ← MM plasman
TREX/DV/CCS/… · TREX/DV/IRS/…               ← Türev
TREX/InvFund/BUY/{FCY,LCY}/                 ← Yatırım fonu
TREX/OPT1/FX/{BUY,SELL}/{CALL,PUT}/…        ← FX opsiyon
```

**`TREX/MM/` ağacı:**

```text
TREX/MM/                              (Id 427)
TREX/MM/ISSUE/ → BRW → {LCY,FCY}      ← tahvil ihraç
TREX/MM/LOAN/BRW/{DOM,FRGN}/{LONG,SHRT}/{LCY,FCY}/
TREX/MM/MURABAHA/                     (Id 1012)
```

🔴 **En önemli bulgu:** `TREX/MM/…` ağacında **`OnRevaluation` olayı YOK**; reeskont GL kuralları
**`TREX/BRWPLC1/…`** (politika bazlı ayrı ağaç) altında tanımlı.
`ItemCode IN ('MM','MURABAHA') AND EventTypeCode='OnRevaluation'` sorgusu **0 satır** döndürdü —
bu bir hata değil, **kurgunun kendisi**: ürün ağacı ile muhasebe-politika ağacı **ayrı**.

---

## 7 — Veri olan tarihler ✅

```text
ValueDate|Adet
---------|----
2025-10-29|1
2025-10-28|2
2025-10-27|14
2025-10-26|8
2025-10-25|5
2025-10-24|10
2024-10-13|6
2024-10-12|11
2024-10-07|2
2024-10-06|4
2024-10-05|4
2024-10-04|4
2024-10-03|4
2024-10-02|4
2024-10-01|2
```

**Yorum:** `NetTrexMM_Dev`'de en yeni reeskont **2025-10-29**. Faz 1 testi **2025-10-27** ile yapıldı
(14 fiş) → uç 4 uygun işlem döndürdü, sayfalama ve durum türetme doğrulandı.

---

## 6 — Test veritabanı kontrolü ✅

```text
RevaluationKayitSayisi
----------------------
81
```

**Yorum:** `NetTrexMM_Dev`'de 81 revaluation kaydı var → **Faz 1 testi bu DB ile yapılabilir**.
(`NetTrexMM`'de 4008 kayıt vardı; `launchSettings.json` `NetTrexMM_Dev`'e bakıyor, o kullanılacak.)

---

## 1 — Bağlantı testi ❌ BAŞARISIZ

```text
Sqlcmd: Error: Microsoft ODBC Driver 17 for SQL Server : Named Pipes Provider: Could not open a connection to SQL Server [64]. .
Sqlcmd: Error: Microsoft ODBC Driver 17 for SQL Server : Login timeout expired.
Sqlcmd: Error: Microsoft ODBC Driver 17 for SQL Server : A network-related or instance-specific error has occurred while establishing a connection to SQL Server. Server is not found or not accessible. Check if instance name is correct and if SQL Server is configured to allow remote connections. For more information see SQL Server Books Online..
```

**Yorum:** Veriye erişilmedi. Kök neden: `-S` içinde `tcp:` öneki + port yok.

---

## 2 — Bağlantı testi ✅

```text
name
----
AccEftAccount
AccEngineGeneratedAccountRule
AccEntry
AccEntryMain
AccEntryType
```

**Yorum:** Bağlantı çalışıyor. Muhasebe tabloları `AccEntry` / `AccEntryMain`.

---

## 3 — `AccEntryMain` dağılımı ✅

```text
Type|IsReverse|Adet|ReverseIdNull|MsgKeyNull
----|---------|----|-------------|----------
1|0|480|0|0
1|1|23|0|0
2|0|2050|0|0
2|1|1958|0|0
3|0|27|0|0
4|0|197|0|0
```

**Yorum (M-08'in temeli):**

- `Type = 2` (Revaluation): **2050** fiş · **1958** ters fiş → **92 ters alınmamış** (= `NotReversed`)
- `ReverseIdNull = 0` ve `MsgKeyNull = 0` her satırda → **iki kolon da NOT NULL**, yokluk **`0`** ile ifade ediliyor
  → durum türetmede `IS NULL` **kullanılamaz**, `= 0` kullanılmalı
- `Type = 1` (Opening) ters fişi çok az (23/480) · `Type = 3`, `4` hiç ters fiş içermiyor

---

## 4 — `AccEntryMain` kolon şeması ✅

```text
Kolon
-----
Id int
Description nvarchar
ValueDate date
BusinessKey bigint
MessageKey bigint
TxnId bigint
TxnTypeCode nvarchar
IsReverse bit
ReverseId int
ExternalState nvarchar
ExternalStateDescription nvarchar
StateId int
StateDate datetime
StateMaker nvarchar
ProductCode nvarchar
Type int
Flag int
ExtendedText1 nvarchar
ExtendedText2 nvarchar
ExtendedText3 nvarchar
ExtendedText4 nvarchar
ExtendedText5 nvarchar
```

**Yorum:**

- `ValueDate` **`date`** (saat yok) → sözleşmedeki `ExecutionDate` de tarih olarak eşleşmeli
- `MessageKey` / `BusinessKey` **`bigint`** → C# tarafında **`long`** zorunlu (`FT-02`: Fimple yanıtında string geliyor)
- `ReverseId` **`int`**, `TxnId` **`bigint`** → `ReverseId` başka bir `AccEntryMain.Id`'sini işaret ediyor
- `ExtendedText1..5` serbest alanlar — reeskont akışında kullanılmıyor

---

## 5 — Son 20 revaluation kaydı ✅

```text
Id|TxnId|ValueDate|IsReverse|ReverseId|MessageKey|ExternalState|ProductCode|TxnTypeCode|StateMaker
--|-----|---------|---------|---------|----------|-------------|-----------|-----------|----------
555811|553292|2026-08-05|0|0|696424450086973440|NULL|MM|BRW|PARTNER.TREASY.002@INVESTMENTBANK.COM
555810|553292|2026-08-04|0|0|696177430499733504|NULL|MM|BRW|PARTNER.TREASY.002@INVESTMENTBANK.COM
555809|553292|2026-08-04|1|555801|696177313281519616|NULL|MM|BRW|SYSTEM
555808|553217|2026-06-04|0|0|0|NULL|MM|BRW|SELIM2@INVESTMENTBANK.COM
555807|553216|2026-06-04|0|0|0|NULL|MM|BRW|SELIM2@INVESTMENTBANK.COM
555806|553215|2026-06-04|0|0|0|NULL|MM|BRW|SELIM2@INVESTMENTBANK.COM
555805|553214|2026-06-04|0|0|0|NULL|MM|BRW|SELIM2@INVESTMENTBANK.COM
555804|553200|2026-06-04|1|555325|0|NULL|MM|BRW|SYSTEM
555803|552959|2026-06-04|1|555324|0|NULL|MM|BRW|SYSTEM
555802|553209|2026-06-04|1|555326|0|NULL|MM|BRW|SYSTEM
555801|553292|2026-07-31|0|555809|695090587964321792|NULL|MM|BRW|PARTNER.TREASY.002@INVESTMENTBANK.COM
555800|553306|2026-07-31|1|555798|695090171725787136|NULL|MM|BRW|SYSTEM
555799|553283|2026-07-31|1|555797|695090160422137856|NULL|MM|BRW|SYSTEM
555798|553306|2026-07-31|0|555800|694728368171274240|NULL|MM|BRW|PARTNER.TREASY.002@INVESTMENTBANK.COM
555797|553283|2026-07-31|0|555799|694728084606963712|NULL|MM|BRW|PARTNER.TREASY.002@INVESTMENTBANK.COM
555796|553306|2026-07-31|1|555794|694727816934871040|NULL|MM|BRW|SYSTEM
555795|553283|2026-07-31|1|555793|694727804951744512|NULL|MM|BRW|SYSTEM
555794|553306|2026-07-30|0|555796|694366319707013120|NULL|MM|BRW|PARTNER.TREASY.002@INVESTMENTBANK.COM
555793|553283|2026-07-30|0|555795|694366004609925120|NULL|MM|BRW|PARTNER.TREASY.002@INVESTMENTBANK.COM
555792|553292|2026-07-30|1|555790|694365494691610624|NULL|MM|BRW|SYSTEM
```

**Yorum — bu çıktı `06-sozlesme.md` § 6'yı doğrudan üretti:**

| Gözlem | Sonuç |
|---|---|
| `555801 (IsReverse=0, ReverseId=555809)` ⇄ `555809 (IsReverse=1, ReverseId=555801)` | Zincir **çift yönlü** |
| `555810`, `555811` → `IsReverse=0`, **`ReverseId=0`** | **Ters alınmamış** = `NotReversed` |
| Aynı `TxnId=553292` → 07-30, 07-31, 08-04, 08-05 tarihlerinde ayrı kayıt | **Tarih filtresi zorunlu**; "son aktif hareket" tek başına yetmez |
| `IsReverse=0` satırlarda `StateMaker` = gerçek kullanıcı · `IsReverse=1` satırlarda **`SYSTEM`** | **`T-01` canlıda doğrulandı** — ters fiş adımı `StateMaker`'ı hardcode ediyor |
| 2026-06-04 kayıtlarında `MessageKey = 0` | O tarihte Fimple'a gönderilmemiş/eski veri → `MessageKey = 0` **"Fimple'a gitmedi"** demek |
| `ExternalState` **hepsinde NULL** | Kolon kullanılmıyor |
| `ProductCode = 'MM'`, `TxnTypeCode = 'BRW'` | `ProductCode` MM/IL ayrımı için kullanılabilir (`G-08`) |
| Ters fişin `ValueDate`'i orijinalden farklı (`555801` 07-31 → `555809` 08-04) | **Ters fiş valörü ayrı bir tarih** → `ReverseValueDate` alanı gerekli (**C-08 kanıtı**) |
