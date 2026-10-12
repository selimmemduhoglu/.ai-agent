# 04 — Üç DB'nin Envanteri ve Id Stratejisi

> Canlı DB ölçümü (**salt-okunur**, `192.168.10.211`). Ölçüm tarihi **2026-10-07**.
> `NetTrexMM` (125 tablo) · `NetTrexOPTFX` (53) · `NetTrexDerivSWP` (78).
> Denetim kaydı: `repos/.ai-agent/sql-log/collateral-db-tablo-id-stratejisi/`
>
> ⚠️ Sunucuda **`%Collateral%` adlı DB yok** — sıfırdan kurulacak.

---

## 1. `DefNumberGen` — üç DB karşılaştırması

Şema üçünde de birebir aynı: `EntityColumnType int` (PK) · `Definition nvarchar` · `LastNumber int` ·
`LastUpdateDate datetime`. **`Id` kolonu yok.**

| Ect | NetTrexMM | NetTrexOPTFX | NetTrexDerivSWP |
|---|---|---|---|
| 1 | `Txn Mm Id` — 3416 (2026-10-07) | `Txn_Id` — 129 | `Txn_Id` — 171 |
| 2 | `Acc Entry Main Id` — 6154 | `AccEntryMain_Id` — 137 | `AccEntryMain_Id` — 1184 (2026-10-06) |
| 3 | `Account Entry` — 12720 | `AccEntry_Id` — 807 | `AccEntry_Id` — 2908 (2026-10-06) |
| 4 | `Generated Account` — 8190 | `AccEngineGeneratedAccountRule_Id` — 659 | `accEngineGeneratedAccountRule_Id` — 2360 (2026-10-06) |
| 5 | `Product Definition Id` — 999 (**2025-03-23, ÖLÜ**) | — | — |
| 6 | `Product Definition Market Map Id` — 1032 | — | — |
| 7 | `Txn Tawarruq Id` — 1052 | — | — |
| 8 | `Txn Loan Id` — 1168 | — | — |

### 🔑 Çürütülen hipotez
*"OPTFX/DerivSWP sayacı pek kullanmıyor"* → **YANLIŞ.** İkisi de **aktif** kullanıyor; DerivSWP'nin
muhasebe sayaçları **2026-10-06'da** güncellenmiş. Kullanım azalmıyor, **kapsamı dar**: 4 çekirdek satır.
MM'in 8 satırı modüle özgü ekstralardan (ürün tanımı, Tawarruq, Loan).

### Adlandırma biçimi — iki kuşak
- **MM (eski):** boşluklu Title Case → `Txn Mm Id`, `LastNumber` başlangıç **1000**
- **OPTFX/DerivSWP (yeni):** alt tireli → `Txn_Id`, `LastNumber` başlangıç **0**
→ **Collateral yeni biçimi alır.**

### `EntityColumnType` enum — iki repo farklı
```csharp
// MM — modül adı + _Id soneki
None=0 · TransactionMM_Id=1 · AccountingEntryMain_Id=2 · AccountingEntry_Id=3
· GeneratedAccountingEntry_Id=4 · ProductDefinition_Id=5 · ProductDefinitionMarket_Id=6
· TransactionTawarruq_Id=7 · TransactionLoan_Id=8

// OptionsFX — nötr, soneksiz  ← COLLATERAL BUNU ALIR
None=0 · TransactionId=1 · AccountingEntryMainId=2 · AccountingEntryId=3 · GeneratedAccountingEntryId=4
```
1–4 sayısal değerleri **birebir aynı**.

### 🔴 Sayaç önekinin `int` tavanı (hesaplandı, tahmin değil)
`GetNewNumbersWithPrefixAsync` → `int.Parse($"{prefix}{number}")`.

| Önek | Tavan |
|---|---|
| iki haneli (MM `55`, OptionsFX `99`) | ~**9.999.999 kayıt** |
| üç haneli (MM Loan `120`) | ~**999.999 kayıt** |

Kolon `bigint` ama üretici `int` — tavan **koddan** geliyor. **İki haneli önek seçilmeli.**

---

## 2. IDENTITY haritası

| DB | Tablo | IDENTITY kolonu olan | Olmayan | Hangfire |
|---|---|---|---|---|
| NetTrexMM | 125 | 45 | 80 | 11 |
| NetTrexOPTFX | 53 | 17 | 36 | 11 |
| NetTrexDerivSWP | 78 | 27 | 51 | 11 |

### 🔴 Tuzak: "IDENTITY kolonu var" ≠ "`Id` IDENTITY"
**Tüm `*History` tablolarında** (3 DB, istisnasız) IDENTITY kolonu **`HistoryId`**'dir; `Id` kaynak
satırın Id'sini **taşır**. `sys.columns.is_identity` ile tablo bazlı bakarsan yanlış sonuç çıkarırsın.

### Ana işlem tablosu — üç modülde de aynı
| DB | Tablo | `Id` | `is_identity` | Kaynak |
|---|---|---|---|---|
| MM | `TxnMM` | bigint | **0** | sayaç Ect 1 |
| OPTFX | `TxnTransaction` | bigint | **0** | sayaç Ect 1 |
| DerivSWP | `TxnTransaction` | bigint | **0** | sayaç Ect 1 |

### Kural
| Sayaçtan (IDENTITY **değil**) | IDENTITY (sayaç satırı **açılmaz**) |
|---|---|
| Ana işlem tablosu — **bigint** · `AccEntryMain` · `AccEntry` · `AccEngineGeneratedAccountRule` — **int** | `TxnNote` · `TxnDocument` · `TxnSync` · `TxnCashFlow` · `BatchLog` · `BatchLogDetail` · `DefJobCron` · tüm `*History` |

### ⚠️ `ProductDefinition` — ev geleneği YOK
| MM | OPTFX | DerivSWP |
|---|---|---|
| IDENTITY değil + sayaç satırı var ama **kodu ölü** | IDENTITY **değil**, sayaç satırı **yok** (1 satır, elle) | **IDENTITY** (2 satır) |

Üç modül üç farklı çözüm. **Collateral'da karar verilmesi gereken tek yer burası.**

### Referans/kopya tabloları
`Id` kolonu **var ama IDENTITY değil** — Common'dan senkron geliyor:
`Calendar` · `Holiday` · `HalfWorkingDay` · `FXRate(Detail)` · `InterestRate(Detail)` · `Chart` ·
`Point` · `PrfPortfolio` · `CusCustomer` · `SettlementType` · `PaymentInstructionType` ·
`DefCorporateType(DetailType)` · `Term` · `RateType` · `RateSource` · `FloatingRateType` …

`Id` kolonu **hiç yok**, doğal anahtar: `Currency` (PK `Code`) · `CurrencyPair` (`From,To`) ·
`DefCountry` (`CountryCode`) · `DefDateBasis` (`BasisCode`) · `Market` (`Code`) ·
`DefNumberGen` (`EntityColumnType`) · `DefRefNumGen` (`TypeKey`) · `DefBitMask`

---

## 3. Üç DB'nin kesişimi — 45 tablo (Collateral'da **kesinlikle olmalı**)

| Kategori | Tablolar |
|---|---|
| **Hangfire (11)** 🔑 `Hangfire` şemasında (`dbo` değil) | `AggregatedCounter` `Counter` `Hash` `Job` `JobParameter` `JobQueue` `List` `Schema` `Server` `Set` `State` |
| **Accounting (3)** | `AccEntryMain` · `AccEntry` · `AccEngineGeneratedAccountRule` |
| **Batch (6)** | `BatchItem` · `BatchSet` · `BatchLog` · `BatchLogDetail` · `DefJobCron` (+`History`) |
| **Flow (1-2)** | `FlowTransitionData` (+ `FlowType` 2/3'te) |
| **Framework (2)** | `DefNumberGen` · `DefRefNumGen` |
| **İşlem yardımcı (5)** | `TxnNote`(+`History`) · `TxnDocument`(+`History`) · `TxnSync` |
| **Referans/kopya (18)** | `Calendar` `Holiday` `HalfWorkingDay` `Currency` `CurrencyPair` `FXRate` `FXRateDetail` `InterestRate` `InterestRateDetail` `Chart` `Point` `PrfPortfolio` `CusCustomer` `SettlementType` `PaymentInstructionType` `DefCorporateType` `DefCorporateDetailType` |

### İkisinde olan (muhtemelen gerekli)
- **MM + DerivSWP:** `AmortizationConfiguration(+History)` · `AmortizationType` · `TxnCashFlow(+History)` ·
  `LiquidationType` · `FloatingRateType` · `InterestMethod(Frequency)` · `PaymentFrequency` · `RateType` ·
  `FlowType` · `DefCountry` · `DefLegalVehicle` · `DefTaxOffice` · `Tax*` ailesi · `Branch` · `PrdInstrument`
- **OPTFX + DerivSWP** (yeni-nesil desen): 🔑 `TxnTransaction` · `TxnTransactionHistory` ·
  `ProductDefinition` · `DateBasis`

### Yalnız birinde (Collateral'a **alınmaz**)
MM: `TxnMM*` `TxnLoan*` `TxnTawarruq*` `TxnMmDailyCalculation` `ExternalMM` `LoanRevaluation`
`PaymentMessage` `Market*` `Prd*` ailesi `MDL_*` `Usr*` …
OPTFX: `VolatilityRate(Detail)` `OptionsFXRevaluation` `sysdiagrams`
DerivSWP: `DerivativesRevaluation` `RateAdjustmentType` `TxnSyncDetail`

---

## 4. Hangfire ve Accounting

**Hangfire:** üçünde de **`Hangfire` şemasında** (büyük H küçük f), **11 tablo**, aynı set.
MM ve DerivSWP dolu, **OPTFX'in hepsi 0 satır** (kurulu ama kullanılmıyor).
⚠️ Hiçbir kurulum script'inde yok → runtime'da kendi kuruyor *(tahmin)*.

**`Acc*` — modül DB'sinde yalnız FİŞ, KURAL değil:**

| Tablo | MM | OPTFX | DerivSWP |
|---|---|---|---|
| `AccEntryMain` | 5.044 | 107 | 847 |
| `AccEntry` | 11.407 | 608 | 2.152 |
| `AccEngineGeneratedAccountRule` | 7.033 | 598 | 2.360 |
| `AccEftAccount` / `AccEntryType` | 0 / 0 | ✗ | 0 / 0 |

🔑 **`AccAccountMap`, `AccEngineEvent`, `AccEngineComponent`, `AccountRule`, `AccEngineDynamicMap`
modül DB'lerinin HİÇBİRİNDE yok** — ayrı `NetTrexAcc_*` DB'lerinde (sunucuda 50+ kopya).

→ Faz-1'de muhasebe kapsam dışı olsa bile `AccEntryMain` + `AccEntry` +
`AccEngineGeneratedAccountRule` **şimdiden kurulur** (üçü de aynı sayaçtan besleniyor).
`AccEftAccount`/`AccEntryType` üç DB'de de boş → **atlanır**.

---

## 5. `DefNumberGen` kod kullanımı

**MM** — `INumberGeneratorDataService`, iki metot (`GetNewNumbersWithPrefixAsync` / `GetNewNumbersAsync`):
| Dosya | Enum |
|---|---|
| `Common.Services/Factories/TransactionFactory.cs:36` | `TransactionMM_Id` |
| `Common.Services/Factories/TawarruqFactory.cs:28` | `TransactionTawarruq_Id` |
| `Common.Services/Factories/InterbankLoanFactory.cs:32` | `TransactionLoan_Id` |
| `Api.Services/MM/FileOperation/CreateMmFileHandler.cs:157` | `TransactionMM_Id` |
| `Data/Managers/Accounting/AccountingDataManager.cs:23,28,33,58,61` | Acc* üçlüsü |
| `Api.Services/ProductDefinition/ProductDefinitionUpdateHandler.cs:75` | `ProductDefinitionMarket_Id` (öneksiz) |
| `…/ProductDefinitionCreateHandler.cs:41,62` | 🔴 **YORUM SATIRI** (`prdDefinitionId = 0`) |

**OptionsFX** — `INumberGeneratorDataManager`, **tek metot** (öneksiz sürüm yok):
`Common.Services/Factories/TransactionFactory.cs:29` → `TransactionId` ·
`Data/Managers/Accounting/AccountingDataManager.cs` → Acc* üçlüsü

Altyapı ikisinde de aynı: `NumberGeneratorQueryResolver` → MSSQL `dbo.sp_GetNewNumbers` /
Oracle `{schema}.SP_GET_NEW_NUMBERS` (Dapper SP çağrısı, EF değil).

🔴 **`sp_GetNewNumbers` modül DB'sinde bulunmak ZORUNDA** — ama DerivSwp kurulum script'lerinde
**yok**; DB projesinden (`TrexFramework`) deploy ediliyor olmalı *(tahmin, doğrulanmalı)*.

---

## 6. ÖZET — `NetTrexCollateral`'da olması gereken tablolar

| Kategori | Tablo | Gerekçe | Id stratejisi |
|---|---|---|---|
| Framework | `DefNumberGen` | 3/3 | PK `EntityColumnType` · **4 satırla seed** |
| Framework | `DefRefNumGen` | 3/3 | PK `TypeKey` |
| Framework | `sp_GetNewNumbers` (SP) | kodda zorunlu | — |
| Ana işlem | `TxnTransaction` | OPTFX+DerivSWP ortak adı | 🔑 **bigint, IDENTITY DEĞİL** — Ect 1 |
| Ana işlem | `TxnTransactionHistory` | 2/3 | `HistoryId` IDENTITY · `Id` kaynaktan |
| Accounting | `AccEntryMain` · `AccEntry` · `AccEngineGeneratedAccountRule` | 3/3 | **int, IDENTITY DEĞİL** — Ect 2/3/4 |
| Batch | `BatchItem` · `BatchSet` | 3/3 | int, IDENTITY değil (seed) |
| Batch | `BatchLog` · `BatchLogDetail` · `DefJobCron`(+`History`) | 3/3 | **IDENTITY** |
| Flow | `FlowTransitionData` · `FlowType` | 3/3, 2/3 | IDENTITY değil |
| İşlem yardımcı | `TxnNote`(+H) · `TxnDocument`(+H) · `TxnSync` | 3/3 | `Id` IDENTITY · `HistoryId` IDENTITY |
| Referans/kopya | 18 tablo (§3) | 3/3 | **IDENTITY değil** — Common'dan senkron |
| Hangfire | 11 tablo, `Hangfire` şeması | 3/3 | kendi kurar |
| 🔴 Karar | `ProductDefinition`(+`History`) | 2/3, **3 farklı çözüm** | ev geleneği yok |
| 🔴 Karar | `TxnCashFlow`(+`History`) | 2/3 (MM+DerivSWP) | `Id` IDENTITY |
| ALINMAZ | `AccEftAccount` · `AccEntryType` · `MDL_*` · modüle özgü her şey | boş / tek-modüllük | — |

**Tahmin olarak işaretlenenler:** Hangfire'ın runtime'da kurulduğu · `MDL_*`'ın Oracle taşıma
kalıntısı olduğu · referans tabloların "Common'dan senkron" geldiği (Id'nin IDENTITY olmaması bunu
güçlü biçimde ima ediyor ama senkron mekanizması bu turda okunmadı).
