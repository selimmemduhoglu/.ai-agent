# MM Backend Envanteri — Manuel Reeskont için Hazır Olan / Yazılacak

> Amaç: Doküman (§6.2) MM'den **2 endpoint** istiyor. Bu dosya: MM'de bu iki ucun altında ne kadar altyapı **hazır**,
> ne **yazılacak**, hangi tuzaklar var.
> Doküman analizi → [`01-dokuman-analizi.md`](01-dokuman-analizi.md)
>
> **Sonuç:** Altyapının **~%85'i hazır**. Eksik olan yalnızca API yüzeyi — bugün bu motoru **sadece batch item'lar** tetikliyor.
> **Son Güncelleme:** 2026-08-12

---

## 0. Kritik Bulgu — MM'de ters fiş deseni VAR

Doküman "tüm modüllerin reeskontu T+0 fiş + ters fiş deseniyle çalışır" varsayıyordu (analiz M-01 olarak 🔴 işaretlenmişti).
**Doğrulandı: MM'de bu desen zaten kurulu ve NetTrex.Fx ile aynı `accEntryMain` / `accEntry` şemasını kullanıyor.**
→ **M-01 kapandı.** MM iş anlamında yeniden tasarım gerektirmiyor.

Ek olarak ters fişin **zamanlaması parametrik**:

`RevaluationReverseType` → `Code/Api/NetTrex.MM.Api.IssueBond/Common/Domain/RevaluationReverseType.cs`

| Değer | Anlam |
|-------|-------|
| `Eod = 1` | Tüm ters fişler aynı gün EOD'de (**T+0**) |
| `Bod = 2` | Ters fişler ertesi gün BOD'da (klasik **T+1**) |
| `Atomic = 3` | Periyot sonuna denk geliyorsa EOD, değilse BOD |

Seçim `helper.GetRevaluationReverseType()` framework parametresiyle; iki batch item bu parametreye göre kendini devre dışı
bırakıyor (`Batch.Items/EndOfDay/ReverseBatchItem.cs:35-37`, `Batch.Items/BeginOfDay/ReverseBatchItem.cs:41-43`).

> 💡 **Dokümanın T+0/T+1 kullanıcı seçimi bu enum'ın manuel karşılığı.** Manuel ekranda framework parametresi
> anlamsız — ters fişin `ValueDate`'i kullanıcının seçtiği valöre göre belirlenecek.

---

## 1. Hesap Zinciri (MM / MoneyMarket)

```
RevaluationBatchItem (EOD)
   └─► RevaluationAccountingService.ExecuteAsync(RevaluationAccountingServiceContext(TransactionId, LogicalDate))
          └─► RevaluationAccountingPipeline  (5 step)
                 01_Prepare
                 05_RevaluationEngineAccruedCalculateStep  ──► RevaluationEngineService ──► CalculatorService
                                                                                             ├─ SLCalculator
                                                                                             └─ IRRCLCalculator
                 10_AccountingEntry
                 15_Sync            ──► Fimple  (AccountingType = "Rediscount", DoAccounting = true)
                 20_PersistChange   ──► accEntryMain + TxnMMDailyCalculation
                 25_InternalSync    ──► Kafka
          └─► unitOfWork.CommitAsync()
```

| Sınıf | Yol |
|-------|-----|
| `RevaluationAccountingService` | `Code/Common/NetTrex.MM.Common.Services/Accounting/Revaluation/Services/RevaluationAccountingService.cs:9-31` |
| `LoanRevaluationAccountingService` (IL muadili) | `.../Accounting/Revaluation/Services/LoanRevaluationAccountingService.cs` |
| `RevaluationAccountingPipeline` | `.../Accounting/Revaluation/RevaluationAccountingPipeline.cs` |
| Accrual step | `.../Engines/Revaluation/Steps/05_RevaluationEngineAccruedCalculateStep.cs:31-33` |
| `SLCalculator` (basit doğrusal) | `.../Calculators/Core/SLCalculator.cs:8-20` |
| `IRRCLCalculator` (bileşik) | `.../Calculators/Core/IRRCLCalculator.cs:8-31` |
| `CalculatorService` (facade) | `.../Calculators/CalculatorService.cs` |

**Hesap yöntemi seçimi:** Step 05, SL ve IRRCL'i **ikisini de** hesaplar; `Product.CalculationMethodType == AccountingCalculationMethodType.IRRCL` ise IRR'yi seçer.

### 1.1 Günlük hesap nereye yazılıyor

| Ürün | Entity | Yol |
|------|--------|-----|
| MM | `TxnMMDailyCalculationEntity` | `Code/Data/NetTrex.MM.Data.Domain/Entities/Accounting/TxnMMDailyCalculationEntity.cs` |
| IL | `LoanRevaluationEntity` (~70 alan, NPV dahil) | `.../Entities/InterbankLoan/LoanRevaluationEntity.cs` (`AccEntryMainId:74`) |

`TxnMMDailyCalculationEntity` alanları: `CalculationDate`, `AccrualDay`, `AccrualAmount`, `AccrualAmountSL`,
`AccrualAmountIRR`, `AccrualAmountLCY`, **`AccEntryMainId`** (fişe bağ), `FXRate`, `BaseAmount`.

**Persist deseni — delete-then-insert:** `RevaluationAccountingPersister.PersistRevaluationChangesAsync`
(`.../Accounting/Revaluation/Persisters/RevaluationAccountingPersister.cs:36-50`) → aynı `(TransactionId, CalculationDate)`
kaydı varsa `FindBydAndDateAsync` → `DeleteAsync` → `InsertAsync`. IL muadili: `LoanRevaluationAccountingPersister.cs:35-49`.

> 💡 Bu, dokümanın **Regenerate** aksiyonu için doğal bir temel — hesap kaydı çift oluşmuyor.

---

## 2. Muhasebe Fişi Modeli

`AccEntryMainEntity` → `Code/Data/NetTrex.MM.Data.Domain/Entities/Accounting/AccEntryMainEntity.cs`, tablo `accEntryMain`
(config: `Data.Repository/DbContext/EfConfiguration/Accounting/AccEntryMainConfiguration.cs:7`).

FX'te aradığımız tüm alanlar **aynı isimlerle** mevcut:

```csharp
public long MessageKey  { get; set; }   // 11 — Fimple fiş kimliği
public long BusinessKey { get; set; }   // 10
public bool IsReverse   { get; set; }   // 14
public int  ReverseId   { get; set; }   // 15 — çift yönlü bağ
public string? ExternalState { get; set; } // 16
public string ProductCode    { get; set; } // 21
public int    Type           { get; set; } // 22 — AccountingType enum'ı
```

Navigasyonlar (satır 29-37): `AccountingEntries` (`ICollection<AccEntryEntity>`), `Valuation` (`TxnMMDailyCalculationEntity`),
`Transaction` / `TransactionLoan`.

`AccEntryEntity` (aynı dizin) — **Debit/Credit tek string alanda**:
`DebitCredit` (satır 13, `"Debit"` / `"Credit"`), `Amount:14`, `GLCode:15`, `LcyEquivalent:25`, `FcyEquivalent:26`,
`ReverseId:30`, `ExtendedText1..5:41-45`.

> ⚠️ **Tuzak:** `AccEntryMainConfiguration.cs:72-80` — hem `Transaction` hem `TransactionLoan` **aynı `TxnId` FK'sı**
> üzerinden bağlanıyor. MM ve IL tek tabloyu paylaşıyor → generic endpoint'te `ProductSourceType` ile ayırmak zorunlu.

---

## 3. Ters Fiş Pipeline'ı

`Code/Common/NetTrex.MM.Common.Services/Accounting/RevaluationReverse/`

| Dosya | Ne yapıyor |
|-------|-----------|
| `RevaluationReverseAccountingService.cs:13-24` | Giriş noktası |
| `Steps/01_...ExternalSyncStep.cs:25-39` | Fimple'a `SendRevaluationReverseAccountingAsync` → dönen `ReverseMessageKey`. **`MessageKey == 0` ise atlar** (satır 23) |
| `Steps/05_...ReverseStep.cs:23-43` | Orijinal fişi çeker, `AccountingReverseFactory` ile ters fişi üretir |
| `Steps/10_...PersistChangeStep.cs:18-25` | Ters fişi insert + orijinalin `ReverseId`'sini güncelle (`UpdateReverseIdAsync`) |
| `Steps/15_...InternalSyncStep.cs` | Hem orijinal hem ters fişi Kafka'ya bas |

**Context:** `RevaluationReverseAccountingServiceContext(AccountingEntryMainId, LogicalReference, BusinessKey, MessageKey, LogicalDate)`
→ `Common.Model/Accounting/RevaluationReverse/Contexts/RevaluationReverseAccountingServiceContext.cs:5-11`

**Ters fiş üretici:** `AccountingReverseFactory`
→ `Code/Common/NetTrex.MM.Common.Services/Factories/AccountingReverseReverseFactory.cs`
(⚠️ dosya adı sınıf adıyla uyuşmuyor — sınıf `AccountingReverseFactory`)

```csharp
Description = localCountry == "TR" ? $"Ters Fiş: {input.AccountingEntity.Description}" : ...  // 24
ValueDate   = input.LogicalDate;                                    // 25  ← ters fişin kendi tarihi
IsReverse   = true;                                                 // 30
ReverseId   = input.AccountingEntity.Id;                            // 31
DebitCredit = entry.DebitCredit == "Debit" ? "Credit" : "Debit";     // 52  ← borç/alacak takla
```

> 💡 Satır 25: `ValueDate = input.LogicalDate` → **T+0/T+1 seçimi burada uygulanacak.** Context'e geçirilen
> `LogicalDate`'i (T+0 = ExecutionDate, T+1 = ExecutionDate + 1 iş günü) değiştirmek yeterli.

**İşlem iptalinde de revaluation terslenir:** `.../Accounting/Delete/Steps/10_DeleteAccountingReverseRevaluationStep.cs`
(aynı factory'yi kullanıyor).

> ⚠️ **IssueBond'un ayrı/eski tarz implementasyonu var:**
> `Code/Api/NetTrex.MM.Api.IssueBond/Operations/AccountingOperation/Services/AccountingReverse/AccountingReverseService.cs`
> (`PerformReverse`/`PerformReverseAsync`, manuel `NumberGenerator` ile Id üretiyor — satır 141-209).
> Generic tasarımda **buna dokunmamak** daha güvenli.

---

## 4. EOD Revaluation Batch Item — Manuel Ekranın Referans Davranışı

`Code/Batch/NetTrex.MM.Batch.Items/EndOfDay/RevaluationBatchItem.cs`

| Adım | Ne olur |
|------|---------|
| `Start` (31-45) | Çalışma günü değil + `SystemWDFlag == WeekdaysOnly` → **Fail** |
| `Run` (47-58) | `RunRevaluationTransactions` → sonra `helper.GetIsEnabledInterbankLoanModule()` true ise `RunInterbankLoanRevaluationTransactions` |
| MM seçimi (62) | `transactionDataManager.GetPendingRevaluationTransactions(ExecDate)` |
| Ürün ayrımı (73-96) | `ProductId == ProductAccountingCodeType.ISSUE` → `issueBondRevaluationOperationBase.RevaluationExecute(...)`, değilse `RevaluationAccountingService.ExecuteAsync(...)` |
| Hata (98-105) | `ZeroRemainingNominalException` → skip log; diğer → `LogWarning`, **sonraki transaction'a devam** |
| IL seçimi (116) | `transactionLoanDataManager.GetPendingRevaluationTransactions(ExecDate)` |

### 4.1 "Reeskonta uygun transaction" filtresi — sözleşmenin `eligible-transactions` karşılığı

`TransactionDataManager.GetPendingRevaluationTransactions` → `Code/Data/NetTrex.MM.Data/Managers/Transaction/TransactionDataManager.cs:411-458`

```
StateId ∈ VerifiedStatesId
MaturityDate >  logicalDate  &&  ValueDate <= logicalDate        // açık transaction
Opening fişi kesilmiş olmalı  (AccountingType.Opening)
Aktif periyot var: Details.Any(!IsPrincipalAmount && PeriodStartDate <= d < PeriodEndDate)
   UNION (satır 426-450):
   (a) o gün için hiç non-reverse revaluation fişi olmayanlar          → ≈ Not Rediscounted
   (b) o gün revaluation'ı kesilip AYNI GÜN terslenmiş olanlar         → tekrar kesilmeli
```

> 🔴 **Kritik uyuşmazlık:** Bu sorgu doğrudan `Not Rediscounted` + "aynı gün terslenmiş" kümesini veriyor —
> ama dokümanın istediği **4 durumlu** (`NotRediscounted` / `NotReversed` / `Rediscounted` / `All`) liste değil.
> `eligible-transactions` için **yeni bir sorgu** (durum türetmeli, sayfalamalı) yazılması gerekiyor.
> Kardeş sorgu `GetPendingRevaluationReverseTransactions` (satır 461) `NotReversed` kümesine karşılık geliyor.

### 4.2 Gün içinde tekrar çalıştırılabilir mi?

| Katman | Durum |
|--------|-------|
| Seçim | ✅ Idempotent — UNION sorgusu o gün fişi kesilip terslenmemiş transaction'ı listeye almaz |
| `TxnMMDailyCalculation` persist | ✅ delete-then-recreate (`Persister.cs:38-49`) → çift kayıt yok |
| `accEntryMain` fişi | ⚠️ **Her koşuda YENİ insert** (`20_RevaluationAccountingPersistChangeStep.cs:33`) |
| Fimple çağrısı | 🔴 **Idempotent DEĞİL** — `FimpleAccountingService.cs:281` her istekte `idempotencyKey: Guid.NewGuid()` |

> 🔴 **Manuel ekran için sonuç:** Çift tıklama / eşzamanlı iki kullanıcı → **çift fiş + Fimple'a çift kayıt**.
> API tarafında koruma zorunlu (analiz C-11).

---

## 5. Fimple Entegrasyonu

**Servis:** `FimpleAccountingService` → `Code/Common/NetTrex.MM.Common.Services/External/FimpleAccountingService.cs`
**Arayüz:** `Code/Common/NetTrex.MM.Common.Abstractions/External/IFimpleAccountingService.cs`

> ⚠️ **`internal interface`** (satır 5) → API katmanından **doğrudan inject edilemez**.
> Endpoint'ler `IRevaluationAccountingService` / `IRevaluationReverseAccountingService` üzerinden gitmek zorunda.

| Metot | Payload |
|-------|---------|
| `SendRevaluationAccountingAsync` (143-177) | `DoAccounting = model != null`, `DoReverseAccounting = false`, `AccountingType = "Rediscount"`, `AccountingTransactionDate = LogicalDate` |
| `SendRevaluationReverseAccountingAsync` (179-206) | `DoAccounting = false`, **`DoReverseAccounting = true`**, `ReverseMessageKey = context.MessageKey`, `ReversAccountingTransactionDate = LogicalDate`, `AccountingModel = null` |

Request record: `Common.ResponseRequest/External/Fimple/Accounting/SendAccounting/FimpleSendAccountingRequest.cs:11-12`

### 5.1 Enum'lar

**1. `FimpleAccountingType`** (Fimple'a giden string) → `Code/Common/NetTrex.MM.Common.Core/Enums/External/FimpleAccountingType.cs`
```csharp
None = 0, Rediscount = 1 /* Reeskont Fişi */, Coupon = 2, Closing = 3, Deleting = 4, Opening = 5
```
Reeskont = **`Rediscount`**. (FX'te `Deleting` kullanan bir tutarsızlık vardı — MM'de o sorun yok.)

**2. `AccountingType`** (iç, `accEntryMain.Type`) → `Code/Data/NetTrex.MM.Data.Core/Enums/AccountingType.cs`
```csharp
Opening = 1, Revaluation = 2, Payment = 3, Maturation = 4, Manuel = 5, Amortization = 6, Fee = 7
```
> ⚠️ `Manuel = 5` **zaten tanımlı** ama yalnız IssueBond açıklama üretiminde kullanılıyor
> (`Api.IssueBond/Accounting/Base/Abstract/AccountingExecutorBase.cs:267`).
> **İş kararı gerekli:** manuel ekrandan kesilen fiş `Revaluation = 2` mi olacak, `Manuel = 5` mi? (→ soru M-07)
> ⚠️ Aynı enum **3 yerde duplike**: `Data.Core`, `Accounting.Core`, `Common.Core/Enums/Accounting`.

### 5.2 Idempotency / MessageKey

- Fimple çağrısı **idempotent değil**: `SendAccountingAsync` (274-283) her seferinde `Guid.NewGuid()` key üretir.
  `helper.GetExternalUseDirectAccountingAsync()` true → `SendDirectAccountingAsync` (key'siz), false → `SendAccountingAsync(idempotencyKey, ...)`.
- Dönen `MessageKey` DB'ye: `Common.Mapper/Accounting/Base/AccountingEntryMainEntityMapper.cs:112`
  → `MessageKey = sendTransactionResult?.MessageKey ?? 0`.
- Ters fiş zinciri: orijinalin `MessageKey`'i Fimple'a `ReverseMessageKey` olarak gider; dönen `ReverseMessageKey`
  ters fişin `MessageKey`'i olur (`01_RevaluationReverseAccountingExternalSyncStep.cs:38`, `AccountingReverseReverseFactory.cs:27`).
- **Kill-switch:** `helper.GetExternalAccountingSyncStateAsync()` false → Fimple'a hiç gitmez, yalnız iç fiş yazılır
  (`15_RevaluationAccountingSyncStep.cs:19`, `01_RevaluationReverseAccountingExternalSyncStep.cs:21-23`).

---

## 6. Mevcut Revaluation API'leri — hepsi salt-okunur

**Fiş kesen / tersleyen endpoint TESPİT EDİLMEDİ.** Bugün motoru yalnız batch item'lar tetikliyor.

| Endpoint | Controller | Handler / Not |
|----------|-----------|---------------|
| `POST api/revaluation-report/select` | `Api/Controllers/Reports/Revaluation/RevaluationReportController.cs:9-14` | `RevaluationReportSelectHandler` — `TxnMMDailyCalculation`'dan `(ReportDate, MarketCode?)` |
| `POST api/interbank-loan/revaluation-report` | `.../InterbankLoanRevaluationReportController.cs:9-14` | `InterbankLoanRevaluationReportHandler` |
| `GET api/transaction/valuation` | `.../Transaction/TransactionController.cs:121-128` | `MMTransactionRevaluationQueryHandler` — `(TransactionId, StartDate, EndDate)` |
| `GET api/interbankloan/valuation` | `.../InterbankLoan/InterbankLoanController.cs:96` | `InterbankLoanRevaluationQueryHandler` |
| `POST api/issuebondvaluation/issuebond-daily-calculation` | `.../IssueBond/IssueBondValuationController.cs:10-16` | IssueBond günlük hesap sorgusu |

---

## 7. Ürün / Alt-Ürün Temsili — Doküman'ın `Product` / `SubProduct`'ı MM'de neye karşılık geliyor

MM'de **tek bir "SubProduct" enum'ı yok**; 4 ayrı temsil paralel duruyor:

### 7.1 `ProductDefinitionEntity` — asıl kaynak (DB tablosu)
`Code/Data/NetTrex.MM.Data.Domain/Entities/ProductDefinition/ProductDefinitionEntity.cs`
```csharp
public string Code                    { get; set; }  // 6
public string Name                    { get; set; }  // 7
public string MainProductCode         { get; set; }  // 9   ← iç ana ürün kodu
public string ExternalMainProductCode { get; set; }  // 10  ← Fimple'a giden
public string ExternalSubProductCode  { get; set; }  // 11  ← ALT ÜRÜN (Murabaha/Wakala BURADA)
public bool   IsAllowTawarruq         { get; set; }  // 20
```
Bağ: `TxnMmEntity.TxnMmProductTypeId` (`Entities/Transaction/TxnMmEntity.cs:7`) + navigasyon `ProductDefinitionEntity Product` (satır 100).
IL tarafı: `LoanRevaluationEntity.ProductDefinitionId` (satır 16).

Fimple'a giden transaction kodu bu üçünün birleşimi:
```csharp
var transactionCode = $"{product.ExternalMainProductCode}{product.ExternalSubProductCode}{model.TxnTypeCode}";
// MarketIntegration.Services/Shared/TransactionCreator.cs:28
// aynısı: Api.Services/MM/FileOperation/CreateMmFileHandler.cs:113
```

### 7.2 `ProductAccountingCodeType` — Murabaha/Wakala explicit
`Code/Data/NetTrex.MM.Data.Core/Enums/ProductAccountingCodeType.cs`
```csharp
MONEYMARKET = 1, LOAN = 2, ISSUE = 3, WAKALE = 4 /* Display "Wakale" */, MURABAHA = 5, TERMDEPOSIT = 6
```
Kullanımı: `RevaluationBatchItem.cs:73` (ürün dallanması), `Calculators/Tax/TaxCalculator.cs:29-30`
(WAKALE/MURABAHA → `TaxConstants.Default`). `accEntryMain.ProductCode` (string, max 10) bu ailenin kodunu taşıyor.

### 7.3 `ProductSourceType` — pipeline dallanması (ADR-001)
`Code/Data/NetTrex.MM.Data.Core/Enums/ProductSourceType.cs` → **yalnız 2 değer**: `MoneyMarket = 1`, `InterbankLoan = 2`.

Revaluation pipeline'ı persister'ı buna göre seçiyor:
`RevaluationAccountingPersister.IsApplicable(sourceType) => sourceType == ProductSourceType.MoneyMarket` (satır 20-23),
`LoanRevaluationAccountingPersister` → `InterbankLoan` (satır 19-22).
Context: `Common.Model/Accounting/Revaluation/Contexts/RevaluationAccountingPipelineContext.cs:15`.

> 🔴 **Murabaha/Wakala ayrı bir `ProductSourceType` DEĞİL** — `ProductDefinition.ExternalSubProductCode` üzerinden
> ayrışıyor ve revaluation pipeline'ı ikisini de **MoneyMarket** olarak işliyor.

### 7.4 `DailyFlowProductType` — en zengin liste (raporlama/UI filtresi)
`Code/Common/NetTrex.MM.Common.Core/Enums/DailyFlow/DailyFlowProductType.cs`
```csharp
MoneyMarket = 1, InterbankLoan = 2, Issue = 3, Vakale = 4, Murabaha = 5, TermDeposit = 6,
PassGil/Pass = 7, Gil = 8, Syndication = 9, Securitization = 10, PostFinancing = 11
```
> 💡 **Dokümandaki SubProduct dropdown'ı için en yakın hazır enum bu.** (→ soru M-02'nin cevap adayı)

---

## 8. Hazır ↔ Yazılacak

### 8.1 Hazır (yeniden yazılmayacak)

| Ne | Nerede |
|----|--------|
| Hesap motoru + fiş üretimi | `IRevaluationAccountingService` / `ILoanRevaluationAccountingService` |
| Ters fiş | `IRevaluationReverseAccountingService` + `AccountingReverseFactory` |
| Fimple entegrasyonu | `Rediscount` + `DoReverseAccounting` yolları, kill-switch, MessageKey zinciri |
| Aday transaction sorguları | `GetPendingRevaluationTransactions` (`TransactionDataManager.cs:411`) · `GetPendingRevaluationReverseTransactions` (`:461`) |
| Fiş bulma | `IAccountingDataManager.GetLastActiveRevaluationAsync(txnId, logicalDate)` · `GetNonReverseRevaluationWithTransactionIdAsync(transactionId)` → `Data.Abstractions/Managers/Accounting/IAccountingDataManager.cs:16-31` |
| DI | Tüm servisler `public interface`, Scrutor otomatik kayıtlı (`Common.Services/Extensions/DependencyInjectionExtension.cs:69` → `AssignableTo(typeof(IAccountingService<>)), publicOnly: false`) |
| Proje referansı | `NetTrex.MM.Api.csproj:18` → `NetTrex.MM.Common.Services` **var** → controller/handler'dan doğrudan inject edilebilir |

### 8.2 Yazılacak

| # | Ne | Nasıl |
|---|----|-------|
| 1 | **`POST /manuel-reeskont/eligible-transactions`** | **Yeni sorgu** gerekli — mevcut `GetPendingRevaluationTransactions` yalnız `NotRediscounted` + "aynı gün terslenmiş" veriyor. İhtiyaç: 4 durumu (`NotRediscounted`/`NotReversed`/`Rediscounted`/`All`) türeten + **sayfalamalı** (`Skip`/`Take`/`TotalCount`) + `Data` sözlüğünü dolduran projeksiyon. FX'in N+1 hatasını **tekrarlamamak** için tek sorguda `LEFT JOIN` + projeksiyon. |
| 2 | **`POST /manuel-reeskont/executions`** | `Operation` + satır durumu → dallanma:<br>• Reeskont kes → `IRevaluationAccountingService.ExecuteAsync(new RevaluationAccountingServiceContext(txnId, logicalDate))`<br>• Ters fiş kes → `IRevaluationReverseAccountingService.ExecuteAsync(new RevaluationReverseAccountingServiceContext(accEntryMainId, logicalReference, businessKey, messageKey, logicalDate))` — 4 alan `GetLastActiveRevaluationAsync`'ten<br>• Ürün seçimi: `ProductSourceType` (MM vs Loan servisi). `ProductAccountingCodeType.ISSUE` dallanması örnek (`RevaluationBatchItem.cs:73`) |
| 3 | Durum türetme mantığı | `accEntryMain` (`Type == Revaluation`, `IsReverse`, `ReverseId`, `MessageKey`) + `TxnMMDailyCalculation` üzerinden. "**En son aktif** hareket esas" (doküman §3.2) |
| 4 | Satır bazlı hata toplama | `Succeeded[]` / `Failed[{TransactionId, LogicalReference, Reason}]` — FX'in "`IsSuccess` her zaman true" hatasını **tekrarlamamak** |
| 5 | Çift-tıklama / eşzamanlılık koruması | Fimple idempotent değil (§5.2) |
| 6 | SubProduct → MM eşlemesi | `DailyFlowProductType` mi, `ProductDefinition.ExternalSubProductCode` mi (→ M-02) |
| 7 | Audit | Kim/ne zaman/hangi aksiyon/hangi valör (→ C-19) |

---

## 9. Tuzaklar (geliştirme sırasında dikkat)

| # | Tuzak | Yer |
|---|-------|-----|
| T-01 | `StateId = 18` ve `StateMaker = "SYSTEM"` **hardcoded** — manuel ekrandan gelen gerçek kullanıcı için parametrik olmalı | `05_RevaluationReverseAccountingReverseStep.cs:32-33` |
| T-02 | Fimple çağrıları idempotent değil (her seferinde yeni `Guid` key) → çift tıklama koruması API'de gerekli | `FimpleAccountingService.cs:281` |
| T-03 | `accEntryMain` her koşuda **yeni insert** — mevcut fişin soft-delete/reverse edilmesi çağıranın sorumluluğu | `20_RevaluationAccountingPersistChangeStep.cs:33` |
| T-04 | `IFimpleAccountingService` **`internal`** → API'den doğrudan inject edilemez | `IFimpleAccountingService.cs:5` |
| T-05 | `accEntryMain` hem `Transaction` hem `TransactionLoan`'a **aynı `TxnId` FK**'sıyla bağlı | `AccEntryMainConfiguration.cs:72-80` |
| T-06 | `AccountingType` enum'ı **3 yerde duplike** (`Data.Core`, `Accounting.Core`, `Common.Core/Enums/Accounting`) | — |
| T-07 | `AccountingReverseFactory` dosya adı sınıf adıyla uyuşmuyor (`AccountingReverseReverseFactory.cs`) | — |
| T-08 | IL modülü **opsiyonel** — `helper.GetIsEnabledInterbankLoanModule()` ile guard'lanmalı, kapalı müşteride TxnLoan tablosu **yok** | `RevaluationBatchItem.cs:52` deseni |
| T-09 | `RevaluationReverseType` (Eod/Bod/Atomic) framework parametresi **manuel ekranda anlamsız** — valör kullanıcıdan gelecek | `RevaluationReverseType.cs` |
| T-10 | IssueBond'un **ayrı/eski tarz** reverse implementasyonu var — generic tasarımda dokunma | `Api.IssueBond/.../AccountingReverse/AccountingReverseService.cs:141-209` |
| T-11 | `01_RevaluationReverseAccountingExternalSyncStep.cs:23` — `MessageKey == 0` ise Fimple'a **hiç gitmez**. Fimple sync kapalıyken kesilmiş fişin ters fişi de Fimple'a gitmez (tutarlı ama bilinmesi gerek) | — |

---

## 10. Açık Soru Güncellemesi (`01-dokuman-analizi.md` § 6.2)

| # | Durum | Not |
|---|-------|-----|
| **M-01** | ✅ **Kapandı** | MM'de T+0 fiş + ters fiş deseni **var**; `RevaluationReverseType` (Eod/Bod/Atomic) ile zamanlaması bile parametrik |
| **M-02** | 🟡 Cevap adayı var | SubProduct için `DailyFlowProductType` (en zengin) veya `ProductDefinition.ExternalSubProductCode`. **Karar gerekli** |
| **M-03** | 🔴 Açık | MM'de `RevaluationType` karşılığı **tespit edilmedi**. En yakın: `AccountingCalculationMethodType` (SL / IRRCL) — ama bu bir hesap yöntemi, "değerleme türü" değil. İş birimine sorulmalı |
| **M-04** | 🔴 Açık | IL ayrı SubProduct mı, MM/Loan içinde mi? `GetIsEnabledInterbankLoanModule()` ile filtrelenmeli |
| **M-05** | 🔴 Açık | Fimple round kuralları hangi alanlara (CLAUDE.md Hard Rule 11) |
| **M-06** | ✅ **Kapandı** | Aynı kod yolu kullanılacak — `IRevaluationAccountingService` / `IRevaluationReverseAccountingService`. Batch ile manuel ekran aynı motoru tetikleyecek (FX'teki desenle aynı) |
| **M-07** | 🔴 **YENİ** | Manuel kesilen fişin `accEntryMain.Type`'ı `Revaluation = 2` mi, `Manuel = 5` mi olacak? İş kararı |
| **M-08** | 🔴 **YENİ** | `eligible-transactions` sorgusu `TxnMMDailyCalculation` + `accEntryMain` üzerinden 4 durumu türetecek. "En son aktif hareket" tanımı netleşmeli: `MAX(accEntryMain.Id)` mi, `MAX(ValueDate)` mi, `CalculationDate == ExecutionDate` filtresi mi? |
| **M-09** | 🔴 **YENİ** | `IssueBond` bu ekrana girecek mi? `RevaluationBatchItem.cs:73` ayrı yola sapıyor (`issueBondRevaluationOperationBase`). Girecekse ayrı Product mı, MM'in SubProduct'ı mı? |
