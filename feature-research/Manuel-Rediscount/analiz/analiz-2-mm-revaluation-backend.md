# Analiz #2 — MM Revaluation / Reeskont Backend Altyapısı (HAM AJAN ÇIKTISI)

**Tarih:** 2026-08-12 · **Taranan repo:** `c:\Users\Treasy-70\source\repos\NetTrex.MM` (bin/obj/.vs/node_modules hariç)

**Aranan cevap:** NetTrex.Fx'teki Manuel Reeskont ekranı generic hale gelecek ve MM de kendi ürünleri (MM/Loan — Murabaha, Wakala) için 2 endpoint sağlayacak. MM tarafında bunun altyapısı var mı, ne kadarı var? **Özellikle: MM'de TERS FİŞ kavramı var mı?**

**⚠️ Kritik bulgu:** MM tarafında altyapının **~%85'i hazır**. **T+0 fiş + ters fiş deseni MM'de ZATEN VAR** ve NetTrex.Fx ile aynı `accEntryMain`/`accEntry` şemasını kullanıyor. Eksik olan tek şey: bu altyapıyı tetikleyen **2 API endpoint'i** (şu an sadece batch item'lar tetikliyor).

> Bu dosya ajan çıktısının **hamıdır**, kısaltılmamıştır. Özet/karar → [`../03-mm-backend-envanteri.md`](../03-mm-backend-envanteri.md)

---

## A) Günlük değerleme / accrual hesabı

**Zincir (MM / MoneyMarket):**
`RevaluationBatchItem` → `RevaluationAccountingService` → `RevaluationAccountingPipeline` (5 step) → step 05 `RevaluationAccountingPersister` → `RevaluationEngineService` → `CalculatorService` (SL / IRRCL).

| Sınıf | Yol | Not |
|---|---|---|
| `RevaluationAccountingService` | `Code\Common\NetTrex.MM.Common.Services\Accounting\Revaluation\Services\RevaluationAccountingService.cs:9-31` | Tek giriş noktası. `RevaluationAccountingServiceContext(TransactionId, LogicalDate)` alır, transaction'ı çeker, pipeline'ı koşturur, `unitOfWork.CommitAsync()`. **API endpoint'i buna bağlanacak.** |
| `LoanRevaluationAccountingService` | `...\Accounting\Revaluation\Services\LoanRevaluationAccountingService.cs` | InterbankLoan muadili |
| `RevaluationAccountingPipeline` | `...\Accounting\Revaluation\RevaluationAccountingPipeline.cs` | Step'ler: 01 Prepare, 05 Accrual, 10 AccountingEntry, 15 Sync(Fimple), 20 PersistChange, 25 InternalSync(Kafka) |
| `RevaluationEngineAccruedCalculateStep` | `...\Engines\Revaluation\Steps\05_RevaluationEngineAccruedCalculateStep.cs:31-33` | SL ve IRRCL'i **ikisini de** hesaplar; `Product.CalculationMethodType == AccountingCalculationMethodType.IRRCL` ise IRR'yi seçer |
| `SLCalculator` | `...\Calculators\Core\SLCalculator.cs:8-20` | Basit doğrusal: `Principal * (Rate*PassedDay/(DaysInYear*100) + Spread*PassedDay/(DaysInYear*SwapPointFactor))` |
| `IRRCLCalculator` | `...\Calculators\Core\IRRCLCalculator.cs:8-31` | Bileşik: `(1+rate+spread)^(PassedDay/TotalDays) - 1` × Principal |
| `CalculatorService` | `...\Calculators\CalculatorService.cs` | Facade (`SLCalculate` / `IRRCLCalculate`) |

**Günlük hesap hangi entity'ye yazılıyor:**
- MM: `TxnMMDailyCalculationEntity` → `Code\Data\NetTrex.MM.Data.Domain\Entities\Accounting\TxnMMDailyCalculationEntity.cs`. Alanlar: `CalculationDate`, `AccrualDay`, `AccrualAmount`, `AccrualAmountSL`, `AccrualAmountIRR`, `AccrualAmountLCY`, **`AccEntryMainId`** (fişe bağ), `FXRate`, `BaseAmount`.
- InterbankLoan: `LoanRevaluationEntity` → `...\Entities\InterbankLoan\LoanRevaluationEntity.cs` (çok daha geniş, ~70 alan + `AccEntryMainId:74`, NPV alanları)

Yazma noktası: `RevaluationAccountingPersister.PersistRevaluationChangesAsync` — `Code\Common\NetTrex.MM.Common.Services\Accounting\Revaluation\Persisters\RevaluationAccountingPersister.cs:36-50`. **Delete-then-insert**: aynı gün için kayıt varsa siler, yeniden yazar (`FindBydAndDateAsync` → `DeleteAsync` → `InsertAsync`). Loan muadili: `LoanRevaluationAccountingPersister.cs:35-49`.

---

## B) Muhasebe fişi modeli

**Var ve NetTrex.Fx ile birebir aynı isim/alan yapısında — ama MM'in kendi tablosu.**

`AccEntryMainEntity` → `Code\Data\NetTrex.MM.Data.Domain\Entities\Accounting\AccEntryMainEntity.cs`, tablo adı `accEntryMain` (`...\Data.Repository\DbContext\EfConfiguration\Accounting\AccEntryMainConfiguration.cs:7`).

Sorulan tüm alanlar mevcut:
```csharp
public long MessageKey { get; set; }      // satır 11 - Fimple fiş kimliği (idempotency anahtarı)
public long BusinessKey { get; set; }     // satır 10
public bool IsReverse { get; set; }       // satır 14
public int ReverseId { get; set; }        // satır 15 - çift yönlü bağ
public string? ExternalState { get; set; }// satır 16
public string ProductCode { get; set; }   // satır 21
public int Type { get; set; }             // satır 22 - AccountingType enum'ı
```
+ Navigasyonlar: `AccountingEntries` (`ICollection<AccEntryEntity>`), `Valuation` (`TxnMMDailyCalculationEntity`), `Transaction`/`TransactionLoan` (satır 29-37).

`AccEntryEntity` → aynı dizin, `AccEntryEntity.cs`. **Debit/Credit tek string alanda**: `public string DebitCredit` (satır 13, değerler `"Debit"` / `"Credit"`), `Amount:14`, `GLCode:15`, `LcyEquivalent:25`, `FcyEquivalent:26`, `ReverseId:30`, `ExtendedText1..5:41-45`.

> ⚠️ Not: `AccEntryMainConfiguration.cs:72-80` — hem `Transaction` hem `TransactionLoan` **aynı `TxnId` FK'sı** üzerinden bağlanıyor (MM/Loan tek tabloyu paylaşıyor; generic endpoint tasarımında dikkat).

---

## C) TERS FİŞ — **VAR, tam kurulu**

`RevaluationReverse` diye ayrı bir pipeline var: `Code\Common\NetTrex.MM.Common.Services\Accounting\RevaluationReverse\`

| Dosya | Ne yapıyor |
|---|---|
| `RevaluationReverseAccountingService.cs:13-24` | Giriş noktası. Context: `(AccountingEntryMainId, LogicalReference, BusinessKey, MessageKey, LogicalDate)` — `...\Common.Model\Accounting\RevaluationReverse\Contexts\RevaluationReverseAccountingServiceContext.cs:5-11` |
| `Steps\01_...ExternalSyncStep.cs:25-39` | Fimple'a `SendRevaluationReverseAccountingAsync` → dönen `ReverseMessageKey`'i alır. **`MessageKey == 0` ise atlar** (satır 23) |
| `Steps\05_...ReverseStep.cs:23-43` | Orijinal fişi çeker, `AccountingReverseFactory` ile ters fişi üretir. **Hardcoded `18` (StateId) ve `"SYSTEM"` (StateMaker)** — satır 32-33 |
| `Steps\10_...PersistChangeStep.cs:18-25` | Ters fişi insert eder + orijinal fişin `ReverseId`'sini günceller (`UpdateReverseIdAsync`) |
| `Steps\15_...InternalSyncStep.cs` | Hem orijinal hem ters fişi Kafka'ya basar |

**Ters fiş üretici:** `AccountingReverseFactory` → `Code\Common\NetTrex.MM.Common.Services\Factories\AccountingReverseReverseFactory.cs`
(⚠️ **dosya adı sınıf adıyla uyuşmuyor** — sınıf `AccountingReverseFactory`). Kritik satırlar:
```csharp
Description = localCountry == "TR" ? $"Ters Fiş: {input.AccountingEntity.Description}" : ...  // 24
ValueDate = input.LogicalDate;                        // 25 (ters fişin kendi tarihi)
IsReverse = true;                                     // 30
ReverseId = input.AccountingEntity.Id;                // 31
DebitCredit = entry.DebitCredit == "Debit" ? "Credit" : "Debit";   // 52  <-- borç/alacak takla
```

**Desen: T+0 fiş + ters fiş — ama ters fişin ZAMANI parametrik (cumulative accrual DEĞİL).**
`RevaluationReverseType` enum'ı → `Code\Api\NetTrex.MM.Api.IssueBond\Common\Domain\RevaluationReverseType.cs`:
- `Eod = 1` — tüm ters fişler aynı gün EOD'de
- `Bod = 2` — ters fişler ertesi gün BOD'da (klasik T+1)
- `Atomic = 3` — periyot sonuna denk geliyorsa EOD, değilse BOD

Seçim `helper.GetRevaluationReverseType()` framework parametresiyle; iki batch item bu parametreye göre kendini devre dışı bırakıyor (`EndOfDay\ReverseBatchItem.cs:35-37`, `BeginOfDay\ReverseBatchItem.cs:41-43`).

Ayrıca **işlem iptalinde** de revaluation tersleniyor: `...\Accounting\Delete\Steps\10_DeleteAccountingReverseRevaluationStep.cs` (aynı `AccountingReverseFactory`'yi kullanıyor).

> ⚠️ IssueBond'un **ayrı, eski tarz** bir implementasyonu var: `Code\Api\NetTrex.MM.Api.IssueBond\Operations\AccountingOperation\Services\AccountingReverse\AccountingReverseService.cs` (`PerformReverse`/`PerformReverseAsync`, manuel `NumberGenerator` ile Id üretiyor — satır 141-209). Generic tasarımda buna **dokunmamak** daha güvenli.

---

## D) EOD revaluation batch item

**Dosya:** `Code\Batch\NetTrex.MM.Batch.Items\EndOfDay\RevaluationBatchItem.cs`

Adım adım:
1. `Start` (satır 31-45): çalışma günü değilse ve `SystemWDFlag == WeekdaysOnly` ise **Fail** döner.
2. `Run` (47-58): `RunRevaluationTransactions` → sonra `helper.GetIsEnabledInterbankLoanModule()` true ise `RunInterbankLoanRevaluationTransactions`.
3. **MM seçimi** (satır 62): `transactionDataManager.GetPendingRevaluationTransactions(ExecDate)` → `Code\Data\NetTrex.MM.Data\Managers\Transaction\TransactionDataManager.cs:411-458`. Filtreler:
   - `StateId ∈ VerifiedStatesId`
   - `MaturityDate > logicalDate && ValueDate <= logicalDate` (yani **açık** transaction)
   - Opening fişi kesilmiş olmalı (`AccountingType.Opening`)
   - Aktif periyot var: `Details.Any(!IsPrincipalAmount && PeriodStartDate <= d < PeriodEndDate)`
   - Sonra **UNION** iki küme (satır 426-450): **(a)** o gün için hiç non-reverse revaluation fişi olmayanlar, **(b)** o gün revaluation'ı kesilip **aynı gün terslenmiş** olanlar
4. Ürün ayrımı (satır 73-96): `ProductId == ProductAccountingCodeType.ISSUE` ise `issueBondRevaluationOperationBase.RevaluationExecute(...)`, değilse `RevaluationAccountingService.ExecuteAsync(...)`.
5. `ZeroRemainingNominalException` → skip log; diğer exception → `LogWarning` ve **sonraki transaction'a devam** (satır 98-105). Tek işlem patlarsa batch durmuyor.
6. **Loan seçimi** (satır 116): `transactionLoanDataManager.GetPendingRevaluationTransactions(ExecDate)`.

**Gün içinde tekrar çalıştırılabilir mi?** Kısmen:
- **Seçim seviyesinde idempotent**: 3. adımdaki UNION sorgusu, o gün fişi kesilmiş ve terslenmemiş transaction'ları listeye almaz → ikinci koşuşta atlanır. ✔
- **Persist seviyesinde delete-then-recreate**: `RevaluationAccountingPersister.cs:38-49` aynı `(TransactionId, CalculationDate)` kaydını siler ve yeniden yazar. Yani hesap kaydı çift oluşmaz.
- **AMA `accEntryMain` fişi her koşuda YENİ insert** (`20_RevaluationAccountingPersistChangeStep.cs:33`). Yani fiş kesildikten sonra terslenirse ikinci koşuş yeni bir fiş üretir (istenen davranış), fakat terslenmemiş fiş varsa sorgu zaten dışlar.
- **🔴 Fimple çağrısı idempotent DEĞİL**: `FimpleAccountingService.cs:281` → `idempotencyKey: Guid.NewGuid().ToString()`. Her istek yeni key.

---

## E) Fimple'a muhasebe gönderimi

**Servis:** `FimpleAccountingService` → `Code\Common\NetTrex.MM.Common.Services\External\FimpleAccountingService.cs`
**Arayüz:** `Code\Common\NetTrex.MM.Common.Abstractions\External\IFimpleAccountingService.cs` — ⚠️ dikkat, **`internal interface`** (satır 5). API katmanından doğrudan inject edilemez; endpoint'ler `IRevaluationAccountingService` üzerinden gitmeli.

Revaluation'la ilgili 2 metot:
- `SendRevaluationAccountingAsync` (satır 143-177): `DoAccounting = model != null`, `DoReverseAccounting = false`, `AccountingType = "Rediscount"`, `AccountingTransactionDate = LogicalDate`
- `SendRevaluationReverseAccountingAsync` (satır 179-206): `DoAccounting = false`, **`DoReverseAccounting = true`**, `ReverseMessageKey = context.MessageKey`, `ReversAccountingTransactionDate = LogicalDate`, `AccountingModel = null`

**`DoAccounting` / `DoReverseAccounting`** → request record'unda: `Code\Common\NetTrex.MM.Common.ResponseRequest\External\Fimple\Accounting\SendAccounting\FimpleSendAccountingRequest.cs:11-12`.

**Enum'lar:**
1. `FimpleAccountingType` (Fimple'a giden string) → `Code\Common\NetTrex.MM.Common.Core\Enums\External\FimpleAccountingType.cs`:
   `None=0, Rediscount=1 (Reeskont Fişi), Coupon=2, Closing=3, Deleting=4, Opening=5`. **Reeskont = `Rediscount`.**
2. `AccountingType` (iç, `accEntryMain.Type`) → `Code\Data\NetTrex.MM.Data.Core\Enums\AccountingType.cs`:
   `Opening=1, Revaluation=2, Payment=3, Maturation=4, Manuel=5, Amortization=6, Fee=7`. **`Manuel=5` zaten tanımlı** ama sadece IssueBond açıklama üretiminde kullanılıyor (`Api.IssueBond\Accounting\Base\Abstract\AccountingExecutorBase.cs:267`). ⚠️ Aynı enum **3 yerde duplike**: `Data.Core`, `Accounting.Core`, `Common.Core\Enums\Accounting`.
3. `ProductAccountingCodeType` → aşağı, (G).

**Idempotency / MessageKey yönetimi:**
- Fimple çağrısı **idempotent değil**: `SendAccountingAsync` (satır 274-283) her seferinde `Guid.NewGuid()` idempotency key üretir. `helper.GetExternalUseDirectAccountingAsync()` true ise `SendDirectAccountingAsync` (key'siz), false ise `SendAccountingAsync(idempotencyKey, ...)`.
- Dönen `MessageKey` DB'ye `AccountingEntryMainEntityMapper` ile yazılıyor: `Code\Common\NetTrex.MM.Common.Mapper\Accounting\Base\AccountingEntryMainEntityMapper.cs:112` → `MessageKey = sendTransactionResult?.MessageKey ?? 0`.
- Ters fiş için: orijinalin `MessageKey`'i Fimple'a `ReverseMessageKey` olarak gider, Fimple dönüşteki `ReverseMessageKey` ters fişin `MessageKey`'i olur (`01_RevaluationReverseAccountingExternalSyncStep.cs:38`, `AccountingReverseReverseFactory.cs:27`).
- **Kill-switch:** `helper.GetExternalAccountingSyncStateAsync()` — false ise Fimple'a hiç gitmez, sadece iç fiş yazılır (`15_RevaluationAccountingSyncStep.cs:19`, `01_RevaluationReverseAccountingExternalSyncStep.cs:21-23`).

---

## F) Mevcut Revaluation API'leri

**3+ endpoint var, hepsi salt-okunur (select/report). Fiş kesen/tersleyen endpoint TESPİT EDİLMEDİ.**

| Endpoint | Controller | Handler |
|---|---|---|
| `POST api/revaluation-report/select` | `Code\Api\NetTrex.MM.Api\Controllers\Reports\Revaluation\RevaluationReportController.cs:9-14` | `Code\Api\NetTrex.MM.Api.Services\Reports\Revaluation\RevaluationReportSelectHandler.cs` — `TxnMMDailyCalculation`'dan `(ReportDate, MarketCode?)` ile okur |
| `POST api/interbank-loan/revaluation-report` | `...\Controllers\Reports\Revaluation\InterbankLoanRevaluationReportController.cs:9-14` | `...\Reports\Revaluation\InterbankLoanRevaluationReportHandler.cs` |
| `GET api/transaction/valuation` | `...\Controllers\Transaction\TransactionController.cs:121-128` | `...\Reports\Revaluation\MMTransactionRevaluationQueryHandler.cs` — `(TransactionId, StartDate, EndDate)` |
| `GET api/interbankloan/valuation` | `...\Controllers\InterbankLoan\InterbankLoanController.cs:96` | `...\Reports\Revaluation\InterbankLoanRevaluationQueryHandler.cs` |
| `POST api/issuebondvaluation/issuebond-daily-calculation` | `...\Controllers\IssueBond\IssueBondValuationController.cs:10-16` | IssueBond günlük hesap sorgusu |

**Endpoint yazmak için hazır olanlar:**
- `IRevaluationAccountingService`, `ILoanRevaluationAccountingService`, `IRevaluationReverseAccountingService` — hepsi `public interface`, Scrutor ile otomatik kayıtlı (`Code\Common\NetTrex.MM.Common.Services\Extensions\DependencyInjectionExtension.cs:69` → `AssignableTo(typeof(IAccountingService<>)), publicOnly: false`).
- `NetTrex.MM.Api.csproj:18` → `NetTrex.MM.Common.Services`'e referansı **var**. Yani controller/handler'dan doğrudan inject edilebilir.
- Manuel ters fiş için gereken "hangi fişi tersleyeceğim" sorgusu da hazır: `IAccountingDataManager.GetLastActiveRevaluationAsync(txnId, logicalDate)` ve `GetNonReverseRevaluationWithTransactionIdAsync(transactionId)` → `Code\Data\NetTrex.MM.Data.Abstractions\Managers\Accounting\IAccountingDataManager.cs:16-31`.
- "Açık transaction listesi" sorgusu da hazır: `GetPendingRevaluationTransactions` / `GetPendingRevaluationReverseTransactions` (`TransactionDataManager.cs:411, 461`).

---

## G) Ürün / alt-ürün temsili

MM'de **tek bir "SubProduct" enum'ı yok**; 4 ayrı temsil paralel duruyor:

**1) `ProductDefinitionEntity` (asıl kaynak, DB tablosu)** → `Code\Data\NetTrex.MM.Data.Domain\Entities\ProductDefinition\ProductDefinitionEntity.cs`
```csharp
public string Code { get; set; }                      // 6
public string Name { get; set; }                      // 7
public string MainProductCode { get; set; }           // 9   <-- iç ana ürün kodu
public string ExternalMainProductCode { get; set; }   // 10  <-- Fimple'a giden
public string ExternalSubProductCode { get; set; }    // 11  <-- ALT ÜRÜN (Murabaha/Wakala burada)
public bool IsAllowTawarruq { get; set; }             // 20
```
Transaction'daki bağ: `TxnMmEntity.TxnMmProductTypeId` (`...\Entities\Transaction\TxnMmEntity.cs:7`) + navigasyon `public ProductDefinitionEntity Product` (satır 100). Loan tarafında: `LoanRevaluationEntity.ProductDefinitionId` (satır 16).

Fimple'a gönderilen transaction kodu bu üçünün birleşimi:
```csharp
var transactionCode = $"{product.ExternalMainProductCode}{product.ExternalSubProductCode}{model.TxnTypeCode}";
// Code\MarketIntegration\NetTrex.MM.MarketIntegration.Services\Shared\TransactionCreator.cs:28
// aynısı: Code\Api\NetTrex.MM.Api.Services\MM\FileOperation\CreateMmFileHandler.cs:113
```

**2) `ProductAccountingCodeType` enum** → `Code\Data\NetTrex.MM.Data.Core\Enums\ProductAccountingCodeType.cs` — **Murabaha ve Wakala burada explicit:**
```csharp
MONEYMARKET = 1, LOAN = 2, ISSUE = 3,
WAKALE = 4,      // Display "Wakale"
MURABAHA = 5,
TERMDEPOSIT = 6
```
Kullanımı: `RevaluationBatchItem.cs:73` (ürün dallanması), `Code\Common\NetTrex.MM.Common.Services\Calculators\Tax\TaxCalculator.cs:29-30` (WAKALE/MURABAHA → `TaxConstants.Default`). **`accEntryMain.ProductCode`** (string, max 10) bu ailenin kodunu taşıyor.

**3) `ProductSourceType` enum (pipeline dallanması)** → `Code\Data\NetTrex.MM.Data.Core\Enums\ProductSourceType.cs`:
```csharp
MoneyMarket = 1, InterbankLoan = 2   // sadece 2 değer!
```
Revaluation pipeline'ı **bu enum'a göre** persister seçiyor: `RevaluationAccountingPersister.IsApplicable(sourceType) => sourceType == ProductSourceType.MoneyMarket` (satır 20-23), `LoanRevaluationAccountingPersister` → `InterbankLoan` (satır 19-22). `RevaluationAccountingPipelineContext.Source` (`...\Common.Model\Accounting\Revaluation\Contexts\RevaluationAccountingPipelineContext.cs:15`).

**4) `DailyFlowProductType`** (raporlama/UI filtresi) → `Code\Common\NetTrex.MM.Common.Core\Enums\DailyFlow\DailyFlowProductType.cs` — **en zengin liste:** `MoneyMarket=1, InterbankLoan=2, Issue=3, Vakale=4, Murabaha=5, TermDeposit=6, PassGil/Pass=7, Gil=8, Syndication=9, Securitization=10, PostFinancing=11`.
> 💡 Dokümandaki **SubProduct dropdown'ı için en yakın hazır enum bu.**

---

## Generic endpoint için pratik değerlendirme

**Hazır (yeniden yazılmayacak):**
- Hesap motoru + fiş üretimi: `IRevaluationAccountingService` / `ILoanRevaluationAccountingService`
- Ters fiş: `IRevaluationReverseAccountingService` + `AccountingReverseFactory`
- Fimple entegrasyonu: `Rediscount` + `DoReverseAccounting` yolları
- Aday transaction sorguları: `GetPendingRevaluationTransactions` / `GetPendingRevaluationReverseTransactions`
- Fiş bulma: `GetLastActiveRevaluationAsync`, `GetNonReverseRevaluationWithTransactionIdAsync`
- Api → Common.Services proje referansı

**Yazılacak:**
1. `POST api/.../revaluation/execute` — `IRevaluationAccountingService.ExecuteAsync(new RevaluationAccountingServiceContext(txnId, logicalDate))`. Ürün seçimi için `ProductSourceType`'a göre MM vs Loan servisi ayırt edilmeli (batch item'daki `ProductAccountingCodeType.ISSUE` dallanması örnek).
2. `POST api/.../revaluation/reverse` — `IRevaluationReverseAccountingService.ExecuteAsync(new RevaluationReverseAccountingServiceContext(accEntryMainId, logicalReference, businessKey, messageKey, logicalDate))`. Bu 4 alanı `GetLastActiveRevaluationAsync`'ten doldurabilirsin.

**Dikkat edilecek noktalar:**
- `05_RevaluationReverseAccountingReverseStep.cs:32-33` — `StateId = 18` ve `StateMaker = "SYSTEM"` **hardcoded**. Manuel ekrandan gelen kullanıcı için parametrik olmalı.
- Fimple çağrıları **idempotent değil** (her seferinde yeni `Guid` key). Manuel ekranda **çift-tıklama koruması API tarafında gerekli**.
- `Manuel = 5` `AccountingType`'ı var ama revaluation akışı `Revaluation = 2` yazıyor; manuel kesilen fişin `Type`'ının ne olacağı **iş kararı**.
- `RevaluationReverseType` (Eod/Bod/Atomic) framework parametresi manuel ekranda **anlamsız** — ters fişin `ValueDate`'i kullanıcının verdiği `LogicalDate` olacak.
- `ProductSourceType` sadece 2 değer içeriyor (MoneyMarket, InterbankLoan). **Murabaha/Wakala ayrı bir `ProductSourceType` DEĞİL**; `ProductDefinition.ExternalSubProductCode` üzerinden ayrışıyor ve revaluation pipeline'ı bunları MoneyMarket olarak işliyor.
