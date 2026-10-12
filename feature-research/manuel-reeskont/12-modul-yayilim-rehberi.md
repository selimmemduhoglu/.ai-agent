# Manuel Reeskont — Modül Yayılım Rehberi

> **Bu dosyanın işi:** "Manuel Reeskont'u şu modüle yaz" dendiğinde açılacak tek talimat dosyası.
> MM + InterbankLoan referans uygulamasından çıkarıldı (2026-08/09, PR 11646 → 12271).
> Sıradaki modüller: **DerivSwp → OptionsFX → FX**.
>
> Okuma sırası: § 1 (mimari) → § 3 (sözleşme, DEĞİŞMEZ) → § 5 (modül checklist) → § 8 (modülün kendi tuzakları).

---

## 1. Mimari — tek ekran, N modül

```
                    ┌─────────────────────────────────────────┐
 Kullanıcı ──────►  │ NetTrex.Web.UI                          │
                    │  TreasuryRediscount/Index               │
                    │  (Security / Investment ekranları aynı) │
                    └───────────────┬─────────────────────────┘
                                    │ Product seçimi → ModuleCode
                    ┌───────────────▼─────────────────────────┐
                    │ ManualRediscountQueryService            │
                    │ → IManualRediscountModuleResolver       │
                    │   .Resolve(moduleCode)                  │
                    └───────────────┬─────────────────────────┘
          ┌──────────────┬──────────┴────────┬──────────────┐
          ▼              ▼                   ▼              ▼
    MM modülü      DerivSwp modülü      OptFX modülü    FX modülü
  /api/manual-     /api/manual-         (yazılacak)    (yazılacak)
   rediscount/*     rediscount/*
```

**Kural:** ekran hiçbir modülün iç yapısını bilmez. Tek bildiği `ModuleCode` ve § 3'teki sözleşme.
Her modül **kendi repo'sunda, kendi pattern'iyle** iki uç yazar. Ortak kod paylaşımı YOKTUR — bilinçli
karar (modüllerin code base'leri ve accounting pipeline'ları birbirine benzemiyor).

### Ürün → modül eşlemesi

`TreasuryRediscountController.GetProducts()` — Web.UI:

| Product (Value) | ModuleCode | Repo | Durum |
|---|---|---|---|
| `MMTransactions` | `MM` | NetTrex.MM | ✅ bitti |
| `InterbankLoanTransactions` | `MM` | NetTrex.MM | ✅ bitti |
| `DerivSwpTransactions` | `DerivSWP` | NetTrex.DerivSwp | ✅ yazıldı, 🧪 test |
| `OptFXTransactions` | `OptFX` | NetTrex.OptionsFX | ✅ yazıldı, 🧪 test |
| `FXTransactions` | `FX` | NetTrex.Fx | ✅ yazıldı (2026-09-17, § 8c), ⬜ uçtan uca test |

🔴 **İki ürün aynı modüle düşebilir** (MM + InterbankLoan). Modül içinde ayrım `Product` alanıyla
yapılır, `ModuleCode` ile DEĞİL. MM'de bu ayrım `ProductSourceType` enum'u + strategy ile yapıldı.

---

## 2. Referans uygulama — MM dosya haritası

Yeni modül yazarken **bire bir karşılığını** üreteceğin dosyalar:

| Katman | MM dosyası | Satır |
|---|---|---|
| Controller | `Code/Api/NetTrex.MM.Api/Controllers/ManualRediscount/ManualRediscountController.cs` | 25 |
| Request | `…Api.ResponseRequest/ManualRediscount/Request/EligibleTransactionsRequest.cs` | 60 |
| Request | `…Api.ResponseRequest/ManualRediscount/Request/ExecutionsRequest.cs` | 45 |
| Request | `…Api.ResponseRequest/ManualRediscount/Request/ManualRediscountColumnFilters.cs` | ~25 |
| Response | `…Api.ResponseRequest/ManualRediscount/Response/EligibleTransactionsResponse.cs` | ~110 |
| Response | `…Api.ResponseRequest/ManualRediscount/Response/ExecutionsResponse.cs` | ~25 |
| Enum | `…Api.ResponseRequest/ManualRediscount/ManualRediscountEnums.cs` | 40 |
| Handler | `…Api.Services/ManualRediscount/Handlers/EligibleTransactionsHandler.cs` | **248** |
| Handler | `…Api.Services/ManualRediscount/Handlers/ExecutionsHandler.cs` | **477** |
| Saf kural | `…Api.Services/ManualRediscount/ManualRediscountStatusResolver.cs` | 35 |
| Saf kural | `…Api.Services/ManualRediscount/ManualRediscountValueDateResolver.cs` | 8 |
| Validator | `…Api.Services/ManualRediscount/Validators/*.cs` | 120 |
| Veri | `…Data/Managers/Transaction/TransactionDataManager.GetRediscountEligibleTransactionsAsync` | ~230 |
| Veri | `…Data/Managers/InterbankLoan/TransactionLoanDataManager` (aynı metot) | ~230 |
| Veri modeli | `…Data.Model/Managers/Transaction/TDMRediscountEligibleResult.cs` | 57 |
| Test | `…UnitTest/Api/…/ManualRediscount/**` | ~1400 |

Web.UI tarafı (modül başına dokunulacak):

| Dosya | Ne için |
|---|---|
| `Services/Abstract/IClient<Modul>API.cs` | **zaten var** — Refit base URL'i |
| `Services/ManualRediscount/IManualRediscount<Modul>Api.cs` | **yeni** — 2 endpoint |
| `Services/ManualRediscount/ManualRediscountModuleResolver.cs` | **yeni client sınıfı** eklenecek |
| `Services/ManualRediscount/ManualRediscountRefitRegistration.cs` | 5 dk timeout kaydı |
| `Startup.cs` (~satır 77-85) | DI kaydı |
| `wwwroot/js/config/manual-rediscount/treasury.json` | ürün bloğu + `columns` |
| `wwwroot/js/localization/pages/manual-rediscount/manual-rediscount-{tr,en}.json` | yeni `mr-col-*` anahtarları |

---

## 3. SÖZLEŞME — DEĞİŞMEZ

🔴 Bu bölümdeki alan adları/anlamları **hiçbir modülde değişmez**. Ekran tek bir şekil bilir.

### 3.1 `POST /api/manual-rediscount/eligible-transactions`

**İstek** (`EligibleTransactionsRequest`):

| Alan | Tip | Anlam |
|---|---|---|
| `ProductGroup` | string | `Treasury` \| `Security` \| `Investment` |
| `ModuleCode` | string | Modül kendi kodunu doğrular, uymazsa `MODULE_MISMATCH` |
| `Product` | string | Ürün (tekil, zorunlu). Modül tanımadıysa `PRODUCT_UNKNOWN` |
| `SubProduct` | string? | Tekil — yalnız doğrudan çağıranlar (Swagger/script) için |
| `SubProducts` | string[]? | 🔴 **Ekranın gönderdiği alan** (çoklu seçim, PO 2026-08-24) |
| `RevaluationTypes` | string[] | Değerleme türü filtresi |
| `ExtraFilters` | dict? | Ürüne özgü ek filtre — **ürün başına request türetme** |
| `ExecutionDate` | date | T+0 fiş valörü = tarih filtresi |
| `Status` | int? | `RediscountStatus` (1/3/4), null = tümü |
| `Filters` | obj? | `LogicalReference`, `ExternalCustomerId`, `ExternalCustomerName`, `SearchText` |
| `IsFirstLoad` | bool | `true` → **sorgu çalışmaz**, boş liste döner |
| `Skip` / `Take` | int | Sayfalama. `Take` varsayılan 50, modül üst sınırı uygular (MM: 2000) |

**Yanıt** (`EligibleTransactionsResponse`):

```jsonc
{
  "isSuccess": true,
  "totalCount": 7,
  "items": [{
    "transactionId": 553336,
    "product": "Money Market",           // alt ürün adı
    "logicalReference": "TMMBRW2608170002",
    "externalCustomerId": 27253,
    "externalCustomerName": "İş Bankası",
    "status": 1,                         // RediscountStatus
    "statusDescription": "Waiting for the rediscount entry to be created.",
    "subProduct": "Money Market",
    "statusReasonCode": null,
    "productSourceType": "MoneyMarket",  // modül içi ayrım, UI sadece taşır
    "revaluationType": "Eod",            // Eod | Bod | Atomic
    "reverseValueDate": null,            // 🔴 GERÇEK valör, T+1 varsayma
    "data": {                            // ⬅ ürüne özel kolonlar, SERBEST
      "TxnTypeCode": "BRW", "Currency": "TRY", "PrincipalAmount": 50000.00
    }
  }],
  "statusSummary": { "total": 7, "notRediscounted": 7, "notReversed": 0, "rediscounted": 0 },
  "valueDates": { "executionDate": "...", "nextDate": "...", "reverseType": "Eod" }
}
```

🔴 **`data` sözlüğü tek esneklik noktası.** Grid'de görünmesini istediğin her ürün-özel kolon buraya
girer; hangisinin çizileceğini `treasury.json` söyler. Sabit kolonlara (Status, StatusDescription,
Product, LogicalReference, Customer…) **dokunulmaz**.

### 3.2 `POST /api/manual-rediscount/executions`

| Alan | Tip | Anlam |
|---|---|---|
| `Operation` | int | `1 = Generate` · `2 = Regenerate` |
| `ExecutionDate` | date | T+0 fiş valörü |
| `ReverseValueType` | int? | `1 = T+1` (varsayılan) · `2 = T+0` |
| `ReverseValueDate` | date? | Açık tarih (tip verilmediyse) |
| `RegenerateToToday` | bool | Yalnız Regenerate'te; seçilen günden bugüne kadar her günü yeniden değerler |
| `Items[]` | list | `{ transactionId, logicalReference, currentStatus }` |

**Yanıt:** `{ isSuccess, succeeded[], failed[] }`, her biri
`{ transactionId, logicalReference, newStatus, reasonCode, reasonDetail }`.

🔴 `isSuccess = (failed.Count == 0)`. **Kısmi başarı başarı değildir.**

### 3.3 Sebep kodları (`RediscountReasonCodes`)

`StatusChanged` · `AlreadyRediscounted` · `NoAccrual` · `OutOfScope` · `DuplicateRequest` ·
`ExternalError`. Metnini **UI localize eder**; modül kodu yollar, cümle yollamaz
(`reasonDetail` teknik ek bilgi olarak serbest).

### 3.4 Hata mesaj kodları

`MODULE_MISMATCH` · `PRODUCT_UNKNOWN` · `TOO_MANY_ITEMS` · `INVALID_OPERATION` · `RANGE_TOO_LARGE`.

---

## 4. İş mantığı — statü ve operasyon kuralları

### 4.1 Statü, DB'de tutulmaz — **türetilir**

Tek kaynak: `ManualRediscountStatusResolver.Resolve(reverseId, reverseValueDate, executionDate)`

| Girdi | Statü |
|---|---|
| O tarihte ters-olmayan reeskont fişi **yok** (`reverseId == null`) | `NotRediscounted (1)` |
| Fiş var, `reverseId == 0` (tersi kesilmemiş) | `NotReversed (3)` |
| Fiş + ters var ama ters fiş **bulunamıyor** | `NotReversed (3)` — sessizce "tamam" demek yanlış |
| Ters valörü **≤** ExecutionDate (aynı gün/geri) → döngü **iptal** | `NotRediscounted (1)` |
| Ters valörü **>** ExecutionDate → döngü **tamam** | `Rediscounted (4)` |

`Processing (2)` ve `Error (0)` **kalıcı değil** — yalnız UI'nin anlık overlay'i.

> Bu tablo modülden bağımsızdır. Modülün `AccEntryMain` benzeri tablosunda
> `Type / IsReverse / ReverseId / ValueDate` varsa **aynen** uygulanır.
> (Doğrulandı: DerivSwp `TransactionEntity.AccountingMainEntries` bu dört alana sahip.)

### 4.2 Generate

| Mevcut statü | Yapılan | Yeni statü |
|---|---|---|
| `NotRediscounted` | Revaluation (T+0) fişi kes. Fiş oluşmadıysa → `NoAccrual` | `NotReversed` |
| `NotReversed` | Ters fiş kes (T+1 ya da kullanıcının seçtiği T+0) | T+0 ise `NotRediscounted`, T+1 ise `Rediscounted` |
| `Rediscounted` | **Yapılmaz** → `AlreadyRediscounted` | — |
| `Processing`/`Error` | Kapsam dışı → `OutOfScope` | — |

### 4.3 Regenerate — iki aşama

**1. aşama — gün-T'yi net sıfıra indir:**

| Statü | Aksiyon |
|---|---|
| `NotRediscounted` | Bir şey yapma — bakiye zaten net sıfır |
| `NotReversed` | **Aynı güne (T+0)** ters fiş kes |
| `Rediscounted` | 🔴 Tamamlanmış çift: gün-T'de +A, gün-T+1'de −A var. **İKİ karşı kayıt** gerekir → MM'de `RevaluationMirrorAccountingService` |

**2. aşama:** yeniden değerle (yeni T+0 fişi) + T+1 tersi → `Rediscounted`.

`RegenerateToToday = true` ise `ExecutionDate`'ten bugüne **her gün** 1. + 2. aşama tekrarlanır
(üst sınır `MaxCatchUpDays = 31`). Bir gün patlarsa zincir durur — sonraki günler o güne dayanıyor.

### 4.4 Sınırlar

| Sabit | Değer | Nerede |
|---|---|---|
| `MaxItems` | **50** | İstek başına satır. UI ikizi `MR_MAX_EXECUTE_ITEMS`. Aşılırsa **hiç işlenmez** (sessiz kırpma yok) |
| `MaxCatchUpDays` | **31** | `RegenerateToToday` geriye gidiş sınırı |
| `MaxTake` | **2000** | Liste ucu üst sınırı |
| Refit timeout | **5 dk** | `ManualRediscountRefitRegistration.ExecuteTimeout` |

---

## 5. Modül backend checklist

> Sırayı bozma. Her adım bir öncekine dayanıyor.

### Adım 1 — Ürün kodunu ve kapsamı netleştir
- `Product` string'i ne olacak? (`DerivSwpTransactions`, `OptFXTransactions`, `FXTransactions` —
  **zaten Web.UI'de tanımlı**, değiştirme)
- Modül **kaç ürün** karşılıyor? Birden fazlaysa MM'deki `ProductSourceType` gibi enum + strategy kur.
- Alt ürün (`SubProduct`) kaynağı ne? (ProductDefinition tablosu mu, sabit liste mi)

### Adım 2 — "Uygun işlem" sorgusunu bul, YENİDEN YAZMA
🔴 **En kritik adım.** Modülün EOD revaluation batch'i hangi sorguyla işlem topluyorsa ekran da
**aynısını** kullanmalı — yoksa ekran ile batch farklı kümeler görür ve kullanıcı "batch'in kestiği
fişi ekranda göremiyorum" der.

| Modül | Kaynak metot |
|---|---|
| MM | `TransactionDataManager.GetPendingRevaluationTransactions` |
| InterbankLoan | `TransactionLoanDataManager` karşılığı |
| **DerivSwp** | `TransactionRepository.GetPendingRevaluationTransactions(logicalDate)` — `Common.Repository/Repository/DerivSwap/TransactionRepository.cs:81` |

Bu sorgunun üstüne **sadece** şunları ekle: alt ürün filtresi, kolon filtreleri, statü filtresi,
sayfalama, statü özeti sayımları.

### Adım 3 — Statü türetmesini sorguya göm
MM deseni (`TransactionDataManager.cs:88-125`):
1. **1. aşama** — o güne ait EN SON ters-olmayan revaluation fişinin `ReverseId`'si
2. **2. aşama** — `ReverseId != 0` ise o fişin `ValueDate`'i
3. Statü filtresi bu iki türetilmiş alan üzerinde uygulanır
4. `TotalCount` + üç sayım **filtre uygulandıktan sonra**, sayfalamadan **önce**

⚠️ `SELECT` projeksiyonunda required navigation dereference etme (MM'de not düşülmüş) — EF sessiz
yanlış çeviri üretebiliyor.

### Adım 4 — `EligibleTransactionsHandler` yaz
MM'i kopyala, şunları değiştir:
- `ExpectedModuleCode` sabiti
- `ResolveProductSourceType` switch'i
- `MapItem` → `Data` sözlüğünün içeriği (§ 7)
- `ResolveRevaluationType` — modülün `ReverseType` framework parametresi

### Adım 5 — `ExecutionsHandler` yaz
MM'i kopyala. Modüle göre değişecek **tek** şey, şu üç çağrının karşılığı:

| MM | Ne yapar | DerivSwp karşılığı |
|---|---|---|
| `IRevaluationAccountingService.ExecuteAsync(ctx)` | T+0 reeskont fişi | `IOperationFactory.GetOperation(OperationType.Revaluation).Execute(txn, date)` |
| `IRevaluationReverseAccountingService.ExecuteAsync(ctx)` | Ters fiş | `IAccountingReverseService.ExecuteAsync(AccountingReverseContext)` — **model alır**, `LogicalDate` = ters fiş valörü |
| `IRevaluationMirrorAccountingService.ExecuteAsync(ctx)` | Tamamlanmış çifti nötrle | **YOK** → § 8.3 |

🔴 Ayrıca korunacak üç şey:
1. **`InFlight` guard** — `{product}|{transactionId}|{date}` anahtarıyla çift tıklama kilidi
2. **Statü yeniden doğrulama** — UI'nin gönderdiği `CurrentStatus` DB ile uyuşmuyorsa `StatusChanged`
3. **Satır izolasyonu** — § 6

### Adım 6 — Validator'lar
`EligibleTransactionsRequestValidator` + `ExecutionsRequestValidator` (FluentValidation).
Zorunlu: `ProductGroup`, `ModuleCode`, `Product`, `ExecutionDate`; `Items` 1..50;
`Operation` geçerli enum; `RegenerateToToday` yalnız Regenerate ile.

### Adım 7 — Controller

```csharp
[Route("api/manual-rediscount")]
[ApiController]
public class ManualRediscountController : BaseApiController
{
    [HttpPost("eligible-transactions")]
    public async Task<IActionResult> EligibleTransactions([FromBody] EligibleTransactionsRequest request)
        => Ok(await Mediator.Send(request));

    [HttpPost("executions")]
    public async Task<IActionResult> Executions([FromBody] ExecutionsRequest request)
        => Ok(await Mediator.Send(request));
}
```

⚠️ Handler base sınıfı modülden modüle değişir: MM `FlowHandler<,>` (`Netix.Core.Flow.Model`),
DerivSwp `BaseHandler<,>` (`Netix.Core.Handler`). **Modülün kendi deseni kullanılır.**

### Adım 8 — Web.UI bağlantısı
1. `IManualRediscount<Modul>Api : IClient<Modul>API` — iki `[Post]`
2. `<Modul>ManualRediscountModuleClient : IManualRediscountModuleClient`
   → `ModuleCode` property + `SubProductsAsync(product)` implementasyonu
3. `Startup.cs`: `AddScoped<IManualRediscountModuleClient, <Modul>…Client>()`
   (resolver `IEnumerable<IManualRediscountModuleClient>` alıyor — **ek kayıt yeter**, resolver'a dokunma)
4. `RegisterManualRediscount<Modul>ApiTimeout` — 5 dk
5. `treasury.json` → ürünün `columns` dizisini doldur
6. `manual-rediscount-{tr,en}.json` → yeni `mr-col-*` anahtarları

### Adım 9 — Testler
MM'de 327 test var; minimum kopyalanacak senaryolar § 9'da.

### Adım 10 — Menü / permission
Ekran zaten var (`TreasuryRediscountKey`, FrameworkMenu Id 2551). Yeni ürün için **menü işi yok**.

---

## 6. 🔴 Satır izolasyonu — atlanırsa prod'da patlar

**Yaşandı (2026-09, MM):** `System.InvalidOperationException: The instance of entity type
'AccEntryEntity' cannot be tracked because another instance with the same key value for {'Id'}
is already being tracked.`

**Sebep:** `executions` ucu **tek HTTP isteğinde N satır** işler. ASP.NET Core'da istek = **tek DI
scope** = **tek `DbContext`**. `SaveChanges` tracker'ı boşaltmaz; bir satırın fişleri `Unchanged`
olarak tracker'da kalır ve sonraki satırın `Attach`'ine karışır.

**Batch'lerde neden yok:** batch de tek context paylaşıyor (ölçüldü — `MaturationBatchItem` scope
açmıyor), ama batch **yazdığını geri okumuyor**: her tur yeni Id üretir, çakışacak örnek oluşmaz.
Manuel Reeskont ise aynı istekte *yaz → `AsNoTracking` ile geri oku → ters kes → güncelle* yapıyor;
`AsNoTracking` identity resolution'ı kapattığı için aynı Id'nin **ikinci bir nesne örneği** doğuyor.

**Ölçüm (prod, 2026-09-12, tek istek, 3 satır, aynı `ctx=b27ebdda…`):**

| Sıra | Item | tracked | TrackerBefore |
|---|---|---|---|
| 1 | 553336 | 0 | boş |
| 2 | 553306 | 6 | AccEntry 5512427-28 → Main 556022 → Txn **553336** |
| 3 | 553283 | 10 | AccEntry 5512429-32 → Main 556023 → Txn **553306** |

**Çözüm (her modülde uygulanacak):**

```csharp
foreach (var item in request.Items)
{
    changeTrackerDataService.Reset();   // ChangeTracker.Clear() — satır başında
    try { … }
    catch (Exception ex) { …; changeTrackerDataService.Reset(); }   // patlayan satırın Added artığı diske düşmesin
}
```

⚠️ **DI tuzağı:** servisin ctor'u repository'lerin kullandığı context'i almalı.
MM'de `AddScoped<IDataContext, EfDbContext>` + `AddTreasyDbContext<EfDbContext>` **iki ayrı instance**
üretiyordu; servis `EfDbContext` aldığı için `Reset()` boş bir context'i temizliyor, teşhis dökümü de
hep `tracked=0` yazıyordu (**körlük**, temizlik değil). Yeni modülde context kaydını **ölç**, varsayma.

⚠️ **Hâlâ açık:** satırın içindeki `catchUpDates` gün döngüsünde `Reset()` **yok**. Kalıcı çözüm
satır (tercihen **gün**) başına `IServiceScopeFactory.CreateAsyncScope()` — batch'in bedavaya aldığı
izolasyonu elle kurmak. Yeni modülde **baştan böyle yazılması önerilir.**

⚠️ **Commit sorumluluğu modülden modüle değişir:**
- **MM:** accounting **servisleri** kendi içinde `unitOfWork.CommitAsync()` çağırıyor → handler commit etmez.
- **DerivSwp:** operation/servis commit **etmiyor**; çağıran (`RevaluationBatchItem`) `_unitOfWork.Commit()`
  diyor → **yeni handler her satırdan sonra açıkça commit etmeli.**

---

## 7. `Data` sözlüğü ve kolonlar

Backend `MapItem` içinde doldurur, UI `treasury.json` ile çizer. **İkisi elle senkron tutulur.**

Config şeması (`treasury.json` → `products[].columns[]`):

```jsonc
{ "key": "PrincipalAmount",             // ⬅ Data sözlüğündeki anahtarla BİREBİR
  "caption": "mr-col-PrincipalAmount",  // ⬅ localization anahtarı
  "dataType": "money",                  // money | rate | date | (diğer → string)
  "width": 140, "order": 7, "format": "#,##0.00" }
```

| `dataType` | Hizalama | Davranış |
|---|---|---|
| `money` | sağ | `mrFormatMoney`, varsayılan format `#,##0.00` |
| `rate` | sağ | `mrFormatRate`, `#,##0.000000` |
| `date` | orta | DevExtreme date, `dd.MM.yyyy` |
| diğer | orta | Düz metin |

⚠️ Config'de olup `Data`'da olmayan anahtar → kolon **boş çizilir** ve konsola
`[ManualRediscount] Key(s) defined in the column config but not present in the data: …` uyarısı düşer.
Geliştirirken konsolu aç.

MM'in kolon seti (referans): `TxnTypeCode`, `Direction`, `PortfolioName`, `FundSourceName`,
`Currency`, `PrincipalAmount`, `InterestRate`, `FxRate`, `StartDate`, `MaturityDate`,
`DayCountBasis`, `DaysToMature`, `AccrualDay`, `AccruedInterest`, `DailyAccrual`,
`AccrualAmountSL`, `AccrualAmountIRR`, `AccrualAmountLCY`.

---

## 8. DerivSwp — ön analiz (kod okundu, 2026-09-15)

### 8.1 Yapı farkları (MM'e göre)

| Konu | MM | DerivSwp |
|---|---|---|
| Veri katmanı | `NetTrex.MM.Data` + `*DataManager` | `Common.Repository` + `*Repository` |
| Handler base | `FlowHandler<,>` (`Netix.Core.Flow.Model`) | `BaseHandler<,>` (`Netix.Core.Handler`) |
| Reeskont akışı | `IRevaluationAccountingService` + step pipeline (01→25) | `IOperationFactory.GetOperation(OperationType.Revaluation)` → `RevaluationOperation.Execute` |
| Ters fiş | `IRevaluationReverseAccountingService` (Id alır) | `IAccountingReverseService.ExecuteAsync(AccountingReverseContext)` — model alır |
| Commit | Servis içinde | **Çağıran yapar** (`IUnitOfWork.Commit()`) |
| Numara üretimi | `sp_GetNewNumbers` (ROWLOCK/UPDLOCK) | `INumberGenerator.GetLastNumber/IncrementNumber/UpdateLastNumber` (read-modify-write) |
| Nötrleme (mirror) | `RevaluationMirrorAccountingService` var | **YOK** |

### 8.2 İyi haber — sözleşme birebir oturuyor

`TransactionEntity.AccountingMainEntries` üzerinde `Type` / `IsReverse` / `ReverseId` / `ValueDate`
**hepsi mevcut** (`TransactionRepository.cs:60-116`). Yani § 4.1 statü algoritması **değişmeden**
uygulanır. `ProductDefinitionEntity` de `Code` / `Name` / `IsEnabled` taşıyor → alt ürün listesi
MM'deki gibi ürün tanımından çekilebilir (şu an `treasury.json`'da IRS/CCS **sabit yazılı**).

### 8.3 ✅ Kararlar (kullanıcı onayı — 2026-09-15)

| # | Konu | **Karar** | Gerekçe |
|---|---|---|---|
| D-1 | İki bacak | **Her iki bacak ayrı kolon blokları** (`Receive*` → `Pay*`) | Ev konvansiyonu bu: `Views/DerivSwp/Index.cshtml:36-67` ana grid'i ve `dgDerivSwpValuation` değerleme grid'i (`:283+`) zaten iki bacağı yan yana yazıyor. Reeskont ekranı farklı davranırsa kullanıcı iki ekranı karşılaştıramaz |
| D-2 | Regenerate / `Rediscounted` | **DerivSwp'ye mirror servisi yazılacak** | MM ile tam parite. `RevaluationMirrorAccountingService` muadili |
| D-3 | Alt ürün | **`treasury.json`'daki sabit liste kalır** (IRS / CCS) | Ek uç yazılmayacak. ⚠️ Yeni alt ürün tanımlanırsa `treasury.json` **elle** güncellenir |
| D-4 | Uygunluk kriteri | **EOD sorgusuyla birebir** | `GetPendingRevaluationTransactions` ne getiriyorsa ekran onu gösterir. `HasOpeningAccountingById` şartı **eklenmez** — ekran ile batch ayrışmasın |
| D-5 | Muhasebe giriş noktası | **Batch'in gittiği yere bağlanılacak** | `RevaluationBatchItem` → `IOperationFactory.GetOperation(OperationType.Revaluation)` → `RevaluationOperation.Execute(txn, date)`. Handler kendi muhasebe kodunu yazmaz, **aynı kapıdan** girer |

### 8.4 `Data` sözlüğü — DerivSwp kolon seti

Kaynak: `DerivSwpRevaluationReportQueryModel` (Web.UI, `Views/DerivSwp/Index.cshtml:272+`).
Reeskont grid'i bunun **özeti** olmalı — rapor 60+ kolon, reeskont ekranı seçili bir alt küme.

Ortak (bacaksız): `ProductTypeName` · `CounterpartyName` · `CalculationDate`

| Receive bacağı | Pay bacağı | `dataType` |
|---|---|---|
| `ReceiveCurrency` | `PayCurrency` | string |
| `ReceivePrincipalAmount` | `PayPrincipalAmount` | money |
| `ReceiveRate` | `PayRate` | rate |
| `ReceiveSpread` | `PaySpread` | rate |
| `ReceiveValueDate` | `PayValueDate` | date |
| `ReceiveMaturityDate` | `PayMaturityDate` | date |
| `ReceiveDateBasisCode` | `PayDateBasisCode` | string |
| `ReceivePeriodDaysPassed` | `PayPeriodDaysPassed` | string |
| `ReceivePeriodAccrualAmountSL` | `PayPeriodAccrualAmountSL` | money |
| `ReceivePeriodAccrualAmountIRR` | `PayPeriodAccrualAmountIRR` | money |
| `ReceivePeriodAccrualAmountLCY` | `PayPeriodAccrualAmountLCY` | money |

⚠️ Kolon adları rapor modeliyle **birebir** tutulacak — iki ekranın aynı alana farklı ad vermesi
en sık yaşanan karışıklık. `treasury.json` + `mr-col-*` anahtarları da bu adlarla açılır.

⚠️ Bu liste **öneri**; iş birimiyle doğrulanmadan kilitlenmez. Reeskont tutarının hangi bacaktan
geldiğini kullanıcı görmeli — asgari zorunlu kolonlar: iki bacağın CCY / PrincipalAmount / Rate /
AccrualAmount'ı.

### 8.5 Muhasebe bağlantısı — D-5'in kod karşılığı

```
RevaluationBatchItem.Run (EOD)                    ExecutionsHandler (yeni)
  └ transactionRepository                           └ (ekran seçili satırı verir)
      .GetPendingRevaluationTransactions(date)          ⇣  aynı transaction
  └ mapper.Map<AccountingTransactionModel>           └ mapper.Map<AccountingTransactionModel>
  └ operationFactory                                 └ operationFactory
      .GetOperation(OperationType.Revaluation)           .GetOperation(OperationType.Revaluation)
      .Execute(transaction, logicalDate)                 .Execute(transaction, executionDate)
  └ _unitOfWork.Commit()                             └ UnitOfWork.Commit()      ⬅ 🔴 unutma
```

Ters fiş için aynı şekilde `BeginOfDay/ReverseBatchItem` deseni:
`IAccountingReverseService.ExecuteAsync(new AccountingReverseContext(...))`.
🔴 `AccountingReverseContext.LogicalDate` **ters fişin valörüdür** — T+1/T+0 seçimi buraya yazılır
(`AccountingReverseService.ProcessAccountingEntries`: `reverseAccEntryMainEntity.ValueDate = logicalDate`).

### 8.6 MM'e göre eksik envanteri

> 🔴 **Prensip:** WebUI yalnız *"şu işlemi şu tarihte reeskont et"* der. Handler kendi muhasebe kodunu
> **yazmaz** — batch'in kullandığı engine'e bağlanır, gerisini engine halleder. İki bacak bu yüzden
> `executions` ucunda **sorun değildir**; bacak yalnız `eligible-transactions`'ın grid kolonlarında
> yaşar (§ 8.4).

**✅ VAR — sadece bağlanacak**

| İhtiyaç | DerivSwp karşılığı |
|---|---|
| Reeskont engine | `IOperationFactory.GetOperation(OperationType.Revaluation)` → `RevaluationOperation.Execute` |
| Ters fiş | `IAccountingReverseService.ExecuteAsync(AccountingReverseContext)` |
| Uygun işlem sorgusu (temel) | `TransactionRepository.GetPendingRevaluationTransactions(date)` |
| `AccEntryMain` okuma (kısmi) | `IAccEntryMainRepository.GetNonReversedRevaluationAsync(txnId)` |
| Eod/Bod/Atomic | `IFrameworkParameterHelper.Get<int>(FrameworkParameterConstants.ReverseType)` + `ReverseType` enum (MM ile aynı değerler) |
| Altyapı | `BaseHandler`, `BaseApiController` + `Mediator`, `IUnitOfWork`, `IDateTimeProvider`, `ProductDefinition` |

**❌ YOK — yazılacak**

| MM'de | DerivSwp durumu | Yük |
|---|---|---|
| `GetRediscountEligibleTransactionsAsync` (sayfalama + statü türetme + 3 sayım + kolon filtreleri) | **yok** — mevcut metot düz `List<>` dönüyor | 🔴 ~230 satır, **en büyük iş** |
| `GetRevaluationByValueDateAsync(txnId, valueDate)` | **yok** — `GetNonReversedRevaluationAsync` **tarihsiz** | küçük |
| `GetEntryValueDateAsync(reverseId)` | **yok** | küçük |
| `RevaluationMirrorAccountingService` | **yok** (D-2) | 🔴 yüksek |
| `IChangeTrackerDataService` (`Reset`) | **yok** | küçük, **zorunlu** (§ 6) |
| Request / Response / Enums / `RediscountReasonCodes` | yok | kopyala |
| `EligibleTransactionsHandler` + `ExecutionsHandler` | yok | kopyala + uyarla |
| Validator ×2 · Controller | yok | kopyala |

**⚠️ VAR ama imzası farklı — uyarlama şart**

1. **Ters fiş servisi entity değil MODEL alıyor.** MM `mainEntryId` yeterken DerivSwp
   `AccountingMainModel` istiyor. Handler transaction'ı `Include(AccountingMainEntries)` ile çekip
   map'lemeli — BOD `ReverseBatchItem`'ın `transaction.Accounting!.Value` deseni.
2. **`AccountingReverseContext.LogicalDate` = ters fişin valörü.** Ayrı alan yok; T+1/T+0 seçimi
   buraya yazılır.
3. **Commit handler'da.** `RevaluationOperation` commit etmiyor; her satırdan sonra
   `UnitOfWork.Commit()` — yoksa hiçbir fiş diske düşmez.

### 8.7 Uygulama durumu (2026-09-15)

**DerivSwp — yazıldı, iki solution da 0 error:**

| Katman | Dosya |
|---|---|
| Sözleşme | `Api.ResponseRequest/ManualRediscount/**` (enum + 2 request + 2 response + kolon filtreleri) |
| Veri modeli | `Common.Model/ManualRediscount/RediscountEligibleModels.cs` |
| Sorgu | `Common.Repository/.../TransactionRepository.GetRediscountEligibleTransactionsAsync` |
| Sorgu | `TransactionRepository.GetForRediscountRevaluationAsync` / `GetForRediscountReverseAsync` |
| Sorgu | `AccEntryMainRepository.GetRevaluationByValueDateAsync` / `GetValueDateAsync` |
| Satır izolasyonu | `Common.Abstractions/.../IChangeTrackerService` + `Common.Repository/.../ChangeTrackerService` |
| Kural | `Api.Business/ManualRediscount/ManualRediscountStatusResolver.cs` |
| Handler | `Api.Business/ManualRediscount/Handlers/{Eligible,Executions}Handler.cs` |
| Validator | `Api.Business/ManualRediscount/Validators/ManualRediscountValidators.cs` |
| Controller | `Api.WebApi/Controllers/ManualRediscount/ManualRediscountController.cs` |
| Mirror | `Common.Abstractions/Services/Accounting/Mirror/IRevaluationMirrorService.cs` |
| Mirror | `Common.Operation/Services/Accounting/Mirror/RevaluationMirrorService.cs` |
| Mirror | `Common.Model/Services/RevaluationMirror/RevaluationMirrorContext.cs` |
| Test | `UnitTest/Api/NetTrex.DerivSwp.Api.Business.Tests` — **yeni proje**, 38 test |

**Web.UI:**

| Dosya | Değişiklik |
|---|---|
| `Services/ManualRediscount/IManualRediscountDerivSwpApi.cs` | yeni — 2 uç |
| `Services/ManualRediscount/ManualRediscountModuleResolver.cs` | `DerivSwpManualRediscountModuleClient` eklendi |
| `Services/ManualRediscount/ManualRediscountRefitRegistration.cs` | ortak `RegisterWithExecuteTimeout` + DerivSwp kaydı |
| `Startup.cs` | 2 satır (Refit timeout + client DI) |
| `wwwroot/js/config/manual-rediscount/treasury.json` | 30 kolon |
| `manual-rediscount-{tr,en}.json` | 30 anahtar (config ↔ localization ↔ backend `Data` üçü de doğrulandı) |

🔴 **Doğrulanan tuzak:** `Receive/PayPeriodAccrualAmountCCY` ve `...LCY` entity'de <b>string</b> —
tutar değil <b>para birimi kodu</b>. Tutarlar `...IRR` / `...SL` / `...LCYIRR` / `...LCYSL`.

### 8.8 🔴 Mirror yazılırken çıkan ikinci tracking tuzağı

`RevaluationMirrorService` aynayı yazıp **commit** ediyor, sonra aynı fişi `AccountingMainModel`'e
map'leyip `IAccountingReverseService`'e veriyor. Ters fiş servisi o modelden **yeni bir**
`AccEntryMainEntity` örneği üretip `Update` ediyor — ama commit tracker'ı boşaltmadığı için ayna
hâlâ `Unchanged` olarak izleniyor. Aynı Id, iki örnek → **`already being tracked`**.

Çözüm: her `Commit()` sonrası `changeTrackerService.Reset()`. Üç yerde uygulandı:
`RevaluationMirrorService.ExecuteAsync`, `ExecutionsHandler.CreateRevaluationAsync`,
`ExecutionsHandler.CreateReverseAsync`.

> **Kural:** *bir fişi yazdıktan sonra aynı fişi modelden yeniden kurup başka bir servise
> verecekseniz, araya `Reset()` koyun.* Bu desen MM'de fark edilmemişti ve prod'da patladı.

Ayrıca `BaseHandler.UnitOfWork` **protected** — test edilemiyor. `ExecutionsHandler` `IUnitOfWork`'ü
ctor'dan alıyor (mirror servisiyle aynı desen); yeni modülde de böyle yapın.

### 8.9 Açık kalan nokta

**Uçtan uca doğrulama yapılmadı.** Birim testler geçiyor, ama Fimple senkronu ve `INumberGenerator`
(read-modify-write, `sp_GetNewNumbers` gibi kilitli değil) gerçek ortamda görülmeli. Özellikle
mirror akışı tek istekte **4 fiş** üretir (ayna + aynanın tersi + yeni reeskont + yeni ters);
numara çakışması riski burada en yüksektir.

---

## 8b. OptFX — uygulandı (2026-09-16)

OptFX mimarisi **MM'e DerivSwp'den çok daha yakın**: adım hattı (`IPipelineStep`), `IRevaluationAccountingService` /
`IRevaluationReverseAccountingService` servis çifti, `*DataManager` veri katmanı. Bu yüzden entegrasyon
DerivSwp'den hızlı geçti (ilk derlemede 0 hata).

### 8b.1 Bağlanılan motor

| Adım | Servis | Valör nereden |
|---|---|---|
| Reeskont (T+0) | `IRevaluationAccountingService.ExecuteAsync` | `ServiceContext.LogicalDate` |
| Ters fiş | `IRevaluationReverseAccountingService.ExecuteAsync` | `ServiceContext.LogicalDate` → `AccountingReverseFactory` bunu `ValueDate`'e yazar |
| Nötrleme | yeni `IRevaluationMirrorAccountingService` | ayna = kaynağın valörü, aynanın tersi = mevcut ters fişin valörü |

🔴 Her iki servis de **kendi içinde `CommitAsync` ediyor** (MM gibi, DerivSwp'den farklı) — handler commit etmez.
Ama commit tracker'ı boşaltmaz: her çağrıdan sonra `Reset()` yine gerekli.

### 8b.2 Uygunluk süzgeci

`TransactionDataManager.GetPendingRevaluationTransactions` ile birebir:

```
Verified && !Deleted && MaturityDate > d && TradeDate <= d
&& AccountingEntryMains.Any(Type == Opening)
```

🔴 OptFX'e özgü: **açılış fişi (Opening) yoksa satır listelenmez**. Diğer modüllerde böyle bir kapı yok.

### 8b.3 Yapısal farklar ve verilen kararlar

| Konu | Karar |
|---|---|
| Alt ürün | DB'de **tek** tanım var: `ProductDefinition.Code = FXOtc`. `treasury.json`'da sabit liste, `ProvidesSubProducts => false` |
| Veri erişimi | `TransactionDataManager` partial ama ctor'una bağımlılık eklenemiyor → ayrı `ManualRediscountDataManager` yazıldı (Scrutor `*DataManager` taramasıyla otomatik kayıtlı) |
| Değerleme alanları | `TxnRevaluation` **tek alt sorgu** ile alınır (DerivSwp'deki alan başına ayrı korelasyondan daha iyi) |
| `Product` kolonu | `OptionType / SideType` (`Call / Buy`) — tek bakışta okunur |
| Greekler | `Delta/Gamma/Vega/Theta/Rho` grid'e eklendi; değerleme kaydından gelir, reeskont kesilmemiş satırda boş |
| `CustomerIsFinancialInstitution` | `TxnTransaction` üzerinde doğrudan var; ters fiş ve ayna bunu ister — okunamıyorsa satır `TRANSACTION_NOT_FOUND` ile düşer |

### 8b.4 🔴 Aynı DI tuzağı OptFX'te de var

```csharp
serviceCollection.AddScoped<IDataContext, EfDbContext>();
serviceCollection.AddTreasyDbContext<EfDbContext>(connectionString, configuration);
```

İki AYRI instance. `ChangeTrackerDataService` `IDataContext` alır, `EfDbContext` **almaz**.

### 8b.5 Kolon sayısı

config 42 ↔ backend `Data` 42 ↔ tr/en 42. Üçü de eşleşiyor.

### 8b.6 Test

`NetTrex.OptionsFX.Api.Services.Tests` **mevcut projeye** eklendi (Moq + Shouldly + AutoFixture).
18 yeni test, toplam 44/44 geçiyor.

### 8b.7 Dosya listesi

**NetTrex.OptionsFX**
- `Api.ResponseRequest/ManualRediscount/` — enums + 3 request + 2 response
- `Api.Services/ManualRediscount/` — resolver, 2 handler, validators
- `Api/Controller/ManualRediscount/ManualRediscountController.cs`
- `Data.Model/Managers/Transaction/ManualRediscount/RediscountEligibleModels.cs`
- `Data.Abstractions/Managers/ManualRediscount/IManualRediscountDataManager.cs`
- `Data/Managers/ManualRediscount/ManualRediscountDataManager.cs`
- `Data.Abstractions/Tracking/IChangeTrackerDataService.cs` + `Data/Tracking/ChangeTrackerDataService.cs`
- `Common.Model/Accounting/RevaluationMirror/RevaluationMirrorContexts.cs`
- `Common.Abstractions/Accounting/RevaluationMirror/IRevaluationMirrorAccountingService.cs`
- `Common.Services/Accounting/RevaluationMirror/RevaluationMirrorAccountingService.cs`
- `UnitTests/Api/NetTrex.OptionsFX.Api.Services.Tests/ManualRediscount/` — 2 test dosyası

**NetTrex.Web.UI**
- `Services/ManualRediscount/IManualRediscountOptFxApi.cs` (yeni) — 🔴 marker `IClientOptFXApi`, namespace `Services.Abstract.Options` (MM/DerivSwp'den farklı, `Services.Abstract` değil)
- `ManualRediscountModuleResolver.cs` — `OptFxManualRediscountModuleClient`
- `ManualRediscountRefitRegistration.cs` — 1 metot
- `Startup.cs` — 2 satır
- `treasury.json` — 42 kolon + sabit alt ürün listesi (`FXOtc`)
- localization tr/en + bundle dosyaları — 40'ar anahtar


## 8c. FX — uygulandı (2026-09-17)

🔴 **FX, önceki üç modülün hiçbirine benzemiyor.** Yeni modüle geçmeden önce § 8c.1'i oku.

### 8c.1 Yapı farkları

| Konu | MM / OptFX | DerivSwp | **FX** |
|---|---|---|---|
| Ürün sayısı | 1 işlem tablosu | 1 işlem tablosu | 🔴 **4 native + 2 Fimple tablosu**, **5 valuation tablosu** |
| Reeskont motoru | `IRevaluationAccountingService` | `IOperationFactory.GetOperation(Revaluation)` | `IValuationService.BuildValuationAccounting(...)` |
| Motorun imzası | context alır | txn + tarih alır | 🔴 **satırın statüsünü parametre alır, içeride dallanır** |
| Ters fiş | ayrı servis | `IAccountingReverseService` | aynı metodun `NotReversed` dalı |
| Nötrleme (mirror) | yazıldı | yazıldı | 🟢 **ZATEN VAR** — § 8c.3 |
| Commit | serviste | çağıranda | **çağıranda** (handler) |
| DI | elle kayıt | elle kayıt | **Scrutor** assembly taraması (`Operations`/`Core`/`Repository`) |

### 8c.2 Uygunluk süzgeci — EOD'de **7 ayrı** batch item var

`Batch/NetTrex.Fx.Batch.EndOfDay/Reeskont/` altında 7 item, her biri kendi süzgeciyle.
Ekran bunların **birleşimini** gösterir:

| Alt ürün | Batch item | Süzgeç |
|---|---|---|
| `Fx` | `FxTransactionReeskontBatchItem` + `FxFutureTransactionReeskontBatchItem` | `TradeDate.Date <= d && ValueDate > d && ValueDate.Date > TradeDate.Date && (FWD \|\| FUT \|\| (spotAktif && SPOT))` + ActiveRecords |
| `FXSwap` | `FxSwapTransactionReeskontBatchItem` | aynı tarih üçlüsü, **enstrüman filtresi YOK** |
| `Pm` / `PmSwap` | `Pm*ReeskontBatchItem` | `Fx` / `FXSwap` ile aynı |
| `ExternalFWD` / `ExternalSWP` | `ExternalTransactionReeskontBatchItem` | `MaturityDate > d && TransactionDate <= d && State == "Active"` (maker-checker YOK) |

🔴 **Eski FX ekranı bu süzgeci uygulamıyordu** — `ValueDate.Date > TradeDate.Date` ve enstrüman
filtresi yoktu, yani batch'in hiç reeskont etmeyeceği satırları listeliyordu. Yeni ekran `D-4`
ilkesine uyar: ekran = batch.

### 8c.3 🟢 Mirror servisi YAZILMADI — motorun kendi dalı o işi yapıyor

```
BuildValuationAccounting(..., statusType: Rediscounted)
  └ DeleteValuation(entity, valuationDate)     // valuation + fişi SOFT-DELETE
  └ ters fişin valörü kaynaktan farklıysa → DoForward + DoReverse ile hizala
  └ AddValuation + ExecuteAccounting + Fimple sync
```

FX'in "regenerate"i **sil-ve-yeniden-oluştur**, ayna değil. Handler eşlemesi:

| Operasyon + statü | Motora geçilen `statusType` | Ters fiş valörü |
|---|---|---|
| Generate / `NotRediscounted` | `NotRediscounted` | — |
| Generate / `NotReversed` | `NotReversed` | kullanıcının seçtiği T+1 / T+0 |
| Generate / `Rediscounted` | *çağrılmaz* → `ALREADY_REDISCOUNTED` | — |
| Regenerate (fiş varsa) | 1. `Rediscounted` → 2. `NotReversed` | 2. aşamada T+1 |
| Regenerate (fiş yoksa) | 1. `NotRediscounted` → 2. `NotReversed` | 2. aşamada T+1 |

🔴 Aşamalar **arasında** `CommitAsync()` + `Reset()` şart — 2. aşama 1. aşamanın yazdığını geri okuyor.

### 8c.4 🔴 `reverseDate` hardcode'du

Üç `BuildValuationAccounting` uygulamasında da `DateTime reverseDate = valuationDate.AddDays(1);`
sabitti → sözleşmedeki `ReverseValueType = T0` uygulanamıyordu. 3 interface + 3 concrete'e
**opsiyonel** `DateTime? reverseValueDate = null` eklendi. Tek çağıran eski
`ManualRediscountUpdateHandler` olduğu için (EOD batch'leri bu metodu kullanmıyor) eski davranış
birebir korundu.

### 8c.5 🔴 NAMESPACE ÇAKIŞMASI — yeni modülde ilk kontrol edilecek şey

FX'te **zaten** `NetTrex.Fx.Domain.Enums.ManualRediscount` adında bir **sınıf** vardı.
Yeni kod `…ResponseRequest.ManualRediscount` namespace'iyle açılınca, C# namespace o sınıfı
**gölgeledi** ve eski dosyalarda `CS0234` çıktı.

**Çözüm:** yeni namespace segmentleri **çoğul** (`…ManualRediscounts`); eski dosyalara dokunulmadı.
Klasör adları tekil kaldı — çakışan şey namespace, klasör değil.

> **Kural:** yeni modüle başlarken `grep -rn "class ManualRediscount\|enum Rediscount"` çalıştır.
> Aynı isimli bir tip varsa namespace segmentini çakışmayacak şekilde seç.

### 8c.6 🔴 Aynı DI tuzağı FX'te de var

```csharp
services.AddTreasyDbContext<EfDbContext>(...);      // NetTrex.Fx.Core/Extensions/ServiceCollectionExtension.cs:17
services.AddScoped<IDataContext, EfDbContext>();    // NetTrex.Fx.Web.API/Startup.cs:210
```

Yeni kodun hiçbiri `EfDbContext`'i doğrudan enjekte **etmiyor** — `IDataContext` alıp cast ediyor.

### 8c.7 `executions`'ta alt ürün alanı yok → referans ön ekinden çözülüyor

`ExecutionItem` yalnız `{transactionId, logicalReference, currentStatus}` taşır; FX'te hangi tabloya
gidileceğini bilmek şart. Ön ek seti eski ekranla birebir:
`TFXSW→FXSwap · TFX→Fx · TPMSW→PmSwap · TPM→Pm · FWD→ExternalFWD · SWP→ExternalSWP`.
Tanınmayan ön ek `OUT_OF_SCOPE` ile düşer (eski koddaki exhaustive-olmayan switch
`SwitchExpressionException` fırlatıyordu).

### 8c.8 Kolon sayısı ve alt ürünler

config **21** ↔ backend `Data` **21** ↔ tr **21** ↔ en **21**.
Alt ürünler `treasury.json`'da sabit (`ProvidesSubProducts => false`):
`Fx · FXSwap · Pm · PmSwap · ExternalFWD · ExternalSWP`.
⚠️ Önceki placeholder (`Spot/Forward/SwapNear/SwapFar`) FX modülünün reeskont ürün ailelerine
karşılık gelmiyordu, değiştirildi.

### 8c.9 Test

`NetTrex.Fx.Business.Test/ManualRediscount/` — 3 dosya, **36 test**, hepsi geçiyor.
⚠️ Koşucu: `dotnet test` yerine `bin/Debug/net10.0/NetTrex.Fx.Business.Test.exe -namespace "..."`.
⚠️ `FX.FutureExternal` altındaki 12 test locale (ondalık ayraç) yüzünden kırmızı — **bu işten önce de kırmızıydı**.

### 8c.10 Dosya listesi

**NetTrex.Fx**
- `ResponseRequest/ManualRediscount/` — enums + 3 request + 2 response
- `Domain/Model/ManualRediscount/RediscountEligibleModels.cs`
- `Repository/Repository/Fx/ManualRediscount/{I,}ManualRediscountRepository.cs`
- `Repository/Tracking/{I,}ChangeTrackerService.cs`
- `Operations/ManualRediscount/{I,}FxManualRediscountEngine.cs` — 6 alt ürün dispatcher'ı
- `Business/Fx/Transaction/ManualRediscount/` — resolver + 2 handler + validator
- `Web.API/Controllers/ManualRediscount/ManualRediscountController.cs`
- `Operations/ValuationOperation/{Abstract,Concrete}` — 6 dosyada opsiyonel `reverseValueDate`

**NetTrex.Web.UI**
- `Services/ManualRediscount/Modules/Fx/` — 2 dosya (🔴 marker `IClientFxAPI`, namespace `Trex.WebUI.Services`)
- `ManualRediscountRefitRegistration.cs` · `Startup.cs` (3 satır)
- `treasury.json` + 6 lokalizasyon dosyası (14'er yeni `mr-col-*`)

### 8c.11 Açık kalan

🔴 `AccEntryMain.TxnId` **4 ayrı işlem tablosunun** Id'sini taşıyor; tek ayırt edici alan
`ProductCode` (`FX` / `SWAPFX` / `PM` / `SWAPPM`; External de `FX` kullanıyor). Grid sorgusu
`(ProductCode == null || == kod)` ile ayırıyor, `executions` içindeki statü yeniden doğrulaması
**ayırmıyor** (eski davranış korundu). Id çakışması gerçek mi, **canlıda ölçülmeli**.

---

## 9. Test matrisi (modül başına minimum)

**`EligibleTransactionsHandler`**
- `IsFirstLoad` → sorgu **hiç** çalışmaz, `TotalCount = 0`
- Yanlış `ModuleCode` → `MODULE_MISMATCH`, veri katmanına gidilmez
- Tanınmayan `Product` → `PRODUCT_UNKNOWN`
- `Take` üst sınırı uygulanır, `Skip < 0` → 0
- `SubProducts` çözülemeyen kod → **sessizce yok sayılmaz**
- Üç statünün de doğru türetilmesi (§ 4.1 tablosunun her satırı)
- `StatusSummary` sayfalamadan bağımsız

**`ExecutionsHandler`**
- `Items.Count > MaxItems` → **hiç işlenmez**
- `RegenerateToToday` + `Generate` → `INVALID_OPERATION`
- `RegenerateToToday` 31 günden geri → `RANGE_TOO_LARGE`
- Aynı anahtarla ikinci istek → `DuplicateRequest`
- UI statüsü ≠ DB statüsü → `StatusChanged`, fiş kesilmez
- Generate/Regenerate karar tablosunun (§ 4.2 / § 4.3) **her hücresi**
- Fiş oluşmadıysa → `NoAccrual`
- 🔴 N satırda `Reset()` **N kez**; patlayan satırda **N+1**
- Bir satır patlasa bile diğerleri işlenir, `isSuccess = false`

---

## 10. Yaşanmış tuzaklar

| # | Tuzak | Sonuç | Çözüm |
|---|---|---|---|
| 1 | ChangeTracker satırlar arası kirlenmesi | Prod'da `already being tracked` | § 6 |
| 2 | Tracker servisi **yanlış** `DbContext`'e bağlıydı | `Reset()` hiç çalışmadı, teşhis hep boş | Ctor `IDataContext` almalı; DI kaydını **ölç** |
| 3 | Alt ürün cache anahtarı **modül** idi | MM ile InterbankLoan aynı listeyi aldı, filtre devreye girmedi | Cache anahtarı **ürün** (`RediscountControllerBase.BuildSubProductsAsync`) |
| 4 | TagBox'a `PascalCase` alan adı | Liste dolu ama satırlar **metinsiz** | `value` / `text` **küçük harf** |
| 5 | `reverseValueDate` T+1 varsayıldı | Regenerate onay penceresi yanlış tarih yazdı | Alan **gerçek valörü** taşır, hesaplama yok |
| 6 | Seq olay gövdesi > 256 KB | Olay **tamamen düşer**, log kaybolur | Büyük dökümleri kırp |
| 7 | Hata dökümü kullanıcıya sızdı | Ekranda `tracker: …` teknik metin | Döküm **loga**, kullanıcıya sade mesaj |
| 8 | Sınır aşımında sessiz `Take` | Kullanıcı kırpıldığını bilmedi | Sınır aşılırsa **hiç işleme**, açık hata dön |
| 9 ⭐ | **Numara üreteci 0 dönüyor** (OptFX, 2026-09-17) | Ters fiş için main + **tüm** detay satırları **aynı** Id'yi (`990`) aldı → EF `another instance with the key value '{Id: 990}' is already being tracked`. Görüntüsü § 6'daki tracker tuzağının aynısı ama **sebebi değil** | OptFX Id'yi `int.Parse($"{99}{Number}")` ile kurar → `Number=0` ise Id `990`. `sp_GetNewNumbers`, `DefNumberGen`'de o `EntityColumnType` satırı **yoksa** `@@ROWCOUNT=0` → `RAISERROR` + `@new_last_no` NULL → 0/NULL döner. **Teşhis:** `SELECT EntityColumnType, LastNumber FROM DefNumberGen` — 2 (`AccEntryMain_Id`) ve 3 (`AccEntry_Id`) satırları var mı, `MAX(Id)` ile uyumlu mu. Script: `outputs/2026-09-17-OptFX-DefNumberGen-Reseed.sql`. Koda guard eklendi (`NumberGeneratorDataManager`: eksik/0 numara → `DataServiceException`) ‖ 🔴 **Yan etki:** Fimple ters fişi oluşturmuştu, lokal yazma patladı → **defterler tutarsız**, tekrar denemeden önce Fimple'daki fiş kontrol edilmeli |
| 10 ⭐ | **Mirror servisi ters fişi commit etmiyordu** (DerivSwp, 2026-09-18) | Regenerate `Rediscounted` satırda 4 yerine **3** fiş yazdı; mirror'ın ters fişi **sessizce kayboldu**, mirror satırının `ReverseId` kalıcı `0` kaldı, ters valör günü defterde **fazla bacak** | DerivSwp `AccountingReverseService.ExecuteAsync` **commit atmaz** — Insert/Update'i tracker'a bırakır, commit sorumluluğu **çağırana** aittir. `RevaluationMirrorService` mirror'ı commit ediyordu ama ters fiş çağrısından sonra commit **yoktu**; dönüşte `ExecutionsHandler.NeutralizeCompletedCycleAsync`'in `changeTrackerService.Reset()`'i (`ChangeTracker.Clear()`) bekleyen insert'i çöpe attı. **Çözüm:** `RevaluationMirrorService.ExecuteAsync` sonuna `unitOfWork.Commit()` + `changeTrackerService.Reset()`. **MM/OptFX'te yok** — orada `RevaluationReverseAccountingService` commit'i **kendi içinde** atıyor. 🔴 **Genel kural:** yeni modülde reverse/mirror servisi eklerken **commit'in kimde olduğunu ölç** — `Reset()` her zaman commit'ten *sonra* gelmeli ‖ **Yan etki:** Fimple ters fişi aldı (sync insert'ten önce), lokal DB almadı → defterler tutarsız |

---

## 11. Definition of Done

- [ ] İki uç Swagger'dan çalışıyor, § 3 sözleşmesine birebir uyuyor
- [ ] Ekran → ürün seçimi → liste geliyor, statü şeridi doğru sayıyor
- [ ] Alt ürün (çoklu) filtresi çalışıyor
- [ ] Generate: `NotRediscounted` → `NotReversed` → `Rediscounted` zinciri
- [ ] Regenerate: üç statü için de § 4.3 davranışı
- [ ] **Çok satırlı** Generate (tek istekte 3+ satır) hatasız — § 6 doğrulaması
- [ ] Hata alan satır diğerlerini düşürmüyor, `isSuccess = false`
- [ ] `treasury.json` kolonları ↔ `Data` anahtarları tam eşleşiyor (konsolda uyarı yok)
- [ ] tr/en localization anahtarları eksiksiz
- [ ] Unit testler § 9 matrisini karşılıyor, solution build 0 error
- [ ] Muhasebe tarafı doğrulandı: kesilen fiş EOD batch'inin kestiğiyle **aynı**

---

## 12. Referanslar

- `.ai-agent/manuel-reeskont/06-sozlesme.md` — sözleşmenin ilk hâli
- `.ai-agent/manuel-reeskont/11-statu-algoritmasi.md` — statü türetmesi detayı
- `.ai-agent/manuel-reeskont/10-veri-secim-kurallari.md` — uygunluk kriterleri
- `.ai-agent/manuel-reeskont/07-fimple-entegrasyon.md` — dış muhasebe senkronu
- MM PR'ları: 11646 → 11701 → 11730 → 11886 → 11966 → 12166 → 12271
- Web.UI PR'ları: 11647 → 11700 → 11731 → 11887
