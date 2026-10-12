# analiz-6 — WebUI base component desenleri (paymentComponent / LimitCheck / CashFlow)

**Tarih:** 2026-08-12
**Repolar:** `NetTrex.Web.UI`
**Soru:** Kullanıcı mimariyi değiştirdi (Common iptal, WebUI → modül direkt). Base component'i WebUI'de
yazacağız. Kullanıcının emsal gösterdiği yapılar: `paymentComponent.js` (MM/InterbankLoan/Fx/Deriv'de
kullanılıyor), **Limit entegrasyonu** component'i, `ViewComponents/` ve `wwwroot/js/shared/`.
Hangi desen yeni base component için model olmalı, ve modüle istek WebUI'den nasıl atılır?
**⚠️ Bu araştırma ajanla değil doğrudan yapıldı** (kullanıcı ajan istemedi) — çıktısı ham haliyle burada.

**🔴 Kritik bulgu:** `settings.baseUrl` bir **modül adresi değil**, uygulamanın kendi kök yolu.
UI'den doğrudan modül API'sine gidilemez → modül seçimi **zorunlu olarak sunucu tarafında**.
`moduleCode` ise **zaten house convention** (`CashFlowComponent.settings.moduleCode`).

---

## 1. Envanter — nerede ne var

### ViewComponent'ler (`Trex.WebUI/ViewComponents/`)

```
AdvanceAndStateFilterViewComponent.cs        LiveRateViewComponent.cs
DataPickerViewComponent.cs                   TransactionDocumentViewComponent.cs
FavoriteFieldsViewComponent.cs               TransactionNoteViewComponent.cs
FxPaymentViewComponent.cs                    UserFavoritesMenuViewComponent.cs
CurrenciesLookupViewComponent.cs             WorldClockTimeViewComponent.cs
ExcelImportExportViewComponent.cs            CurrencyHolCalendarViewComponent.cs
StpTransactionViewComponent.cs
Payment/PaymentViewComponent.cs              Payment/PaymentPreviewViewComponent.cs
Amortization/AmortizationViewComponent.cs    Amortization/AmortizationPreviewViewComponent.cs
AmortizationConfiguration/…ViewComponent.cs  AmortizationConfiguration/…PreviewViewComponent.cs
CustomerAccounts/…ViewComponent.cs           CustomerAccounts/…PreviewViewComponent.cs
CashFlow/CashFlowViewComponent.cs            TransferMessages/TransferMessagesViewComponent.cs
LimitCheck/LimitCheckViewComponent.cs
```

### shared JS (`wwwroot/js/shared/`)

| Grup | Dosyalar |
|---|---|
| `utils/` | `ajax.js`, `date.js`, `general.js`, `instance.js`, `currency-input.js`, `portfolio.js`, `session-check.js` |
| kök | `common-constants.js`, `netix-widgets.js`, `notification.js`, `accounting.js` |
| `components/` (nesil 1 — tek dosya) | `paymentComponent.js`, `customerPaymentComponent.js`, `tawarruqAgentComponent.js`, `amortizationComponent.js`, `amortization-configuration.component.js`, `customerAccountsComponent.js`, `excelExportImport.js` |
| `components/limit-check/` (nesil 2) | `limit-check.component.js`, `.constants.js`, `.endpoints.js`, `.popup.js` |
| `components/cashFlow/` (nesil 3) | `cashflow.component.js`, `.constants.js`, `.context.js`, `.endpoints.js`, `.form.js`, `.preview.js`, `.selectors.js`, `.utils.js` |
| diğer | `constraints/payment/enums.js`, `swift-messages/`, `transfer-messages/`, `partialview/`, `userfavoritemenu/` |

---

## 2. `ajax.js` — TÜM isteklerin geçtiği yer (tam kaynak)

`wwwroot/js/shared/utils/ajax.js`:

```js
const post = async (url, requestData, baseUrl = settings.baseUrl) => {
    let response = null;
    const fullUrl = baseUrl + url;
    try {
        response = await $.ajax({
            url: fullUrl, type: "POST", dataType: "json",
            contentType: "application/json", data: JSON.stringify(requestData)
        });
    } catch (error) {
        notifyError(error);
        throw new Error("Request failed!");
    }
    if (response.IsSuccess === false)
        return null;                      // ⚠️ HATA YUTULUYOR
    return response;
}
const get = async (url, requestData = {}, baseUrl = settings.baseUrl) => {
    // ... queryString kurar, aynı IsSuccess === false → null davranışı
}
```

### `settings.baseUrl` nedir

`Views/Shared/_ErrorLayout.cshtml:54-56` (ve `_FrameworkDependencies` aynı şekli basıyor):

```js
var settings = {
    baseUrl: '@Url.Content("~")',
    language: '@LanguageProvider.GetSelectedLanguage(Context)',
    ...
};
```

→ **uygulamanın kök yolu** (virtual directory desteği). Modül adresi **değil**.

### `baseUrl` 3. parametresi kullanılıyor mu → HAYIR

`cashflow.endpoints.js` üç fonksiyonda tanımlamış:

```js
const generateCashFlow    = (requestBody, baseUrl) => post('/CashFlow/GenerateCashFlow',    requestBody, baseUrl);
const reGenerateCashFlow  = (requestBody, baseUrl) => post('/CashFlow/ReGenerateCashFlow',  requestBody, baseUrl);
const fetchCompoundCashFlows = (requestBody, baseUrl) => post('/CashFlow/GetCompoundCashFlows', requestBody, baseUrl);
```

Ama **hiçbir çağıran ikinci argümanı geçmiyor**:

- `cashflow.component.js:992` → `await generateCashFlow(request)`
- `cashflow.component.js:508` → `await reGenerateCashFlow(request)`
- `cashflow.component.js:571` → `await fetchCompoundCashFlows(request)`
- `cashflow.form.js:990` → `await reGenerateCashFlow(request)`
- `interbank-loan/popups/form.js:894` → `await cashflowComponent.generateCashFlow(request, generatorType)` (2. arg = generatorType, baseUrl değil)

→ **kullanılmayan esneklik.** Dokümanın `baseUrl` alanı da aynı yanılgının izi olabilir.

**Sonuç (mimari için belirleyici):** Her component isteği `/{Controller}/{Action}` yani **kendi WebUI
controller'ına** gider. Modül dağıtımı UI'de yapılamaz → **Controller'da** yapılacak.

---

## 3. Nesil 3 — `CashFlowComponent` (yeni base component için REFERANS)

`cashflow.component.js:1-120` başlığı desenin tamamını anlatıyor:

```js
/**
 * CashFlowComponent
 * A configurable and reusable cash flow grid engine built on top of DevExtreme.
 * The component works with a deep-merge configuration model.
 * Consumers may override only the necessary parts of the default config.
 *
 * Key Features:
 * - Pluggable dataSource (static or remote)
 * - Customizable editing lifecycle callbacks
 * - Theme-aware styling (light/dark)
 *
 * Usage:
 *   new CashFlowComponent({
 *       settings: { moduleCode: "DV", productId: 12 },
 *       editing: { insert: { enabled: false } }
 *   });
 */
```

JSDoc `@typedef CashFlowComponentConfig` ile config sözleşmesi **yazılı**:
`uniqueKey`, `settings.{logicalDate, defaultCurrencyCode, showCurrentPeriod, disableExpiredPeriods,
transactionCode, moduleCode, productId}`, `customer.externalCustomerId`,
`payment.{enabled, enabledSendNoticeToReceive, …}`, `dataSource.key`, `validation.enabled`,
`editing.insert.{enabled, callbackFunc}`, `exporting.enabled`, `masterDetail.enabled`,
`summary.enabled`, `styles`.

Sınıf iskeleti:

```js
class CashFlowComponent {
    #grid; #gridId; #btnAddCashFlow; #logicalDate;
    #validationErrors = [];
    #rowState = { startField: "StartDate", endField: "EndDate", paymentField: "PaymentDate",
                  isPaymentField: "IsPaymentCompleted", directionField: "PaymentDirection" }

    #gridConfig = {
        uniqueKey: "",
        mode: GridModeType.Edit,
        settings: {
            logicalDate: new Date(), defaultCurrencyCode: "TRY",
            showCurrentPeriod: true, disableExpiredPeriods: true,
            transactionCode: "", moduleCode: "", productId: null,
            allowFlowTypes: [FlowType.Principal, FlowType.Interest, FlowType.Fee]
        },
        customer: { externalCustomerId: null, dropDownBox: null, dataGrid: null /* … */ },
        // dataSource / validation / editing / exporting / masterDetail / summary / styles …
    }
}
```

### 🔴 En değerli iki detay

**(a) `moduleCode` config'te ZATEN var** — `settings.moduleCode: ""`, kullanım `moduleCode: "DV"`.
Request'e de basılıyor (`:982-986`):

```js
let request = {
    Module: this.#gridConfig.settings.moduleCode,
    GeneratorType: generatorType,
    Params: data
}
```

→ Dokümandaki `baseUrl` alanını `moduleCode`'a çevirme kararı **house convention'a uyuyor**, icat değil.

**(b) Config-driven endpoint override** (`:990-992`):

```js
const response = !isNullOrEmpty(this.#gridConfig.dataSource.generate.url)
    ? await post(this.#gridConfig.dataSource.generate.url, request)   // tüketicinin verdiği url
    : await generateCashFlow(request);                                 // varsayılan endpoint
```

→ Base component'in "ürün ekibi kendi ucunu verebilir" ihtiyacı bu desenle karşılanır.

**(c) `contextCashFlow` — ayrı state sınıfı** (`cashflow.context.js`): `getState`/`getStateByKey`/
`setState` (dizi ve nesne için **merge**)/`removeState`/`clear`. Immutable-ish (`{...this.state}`).
Manuel Reeskont'ta seçili satırlar + filtre state'i için aynısı kullanılabilir.

---

## 4. Nesil 2 — `LimitCheck` (modül-bazlı aktiflik deseni)

`ViewComponents/LimitCheck/LimitCheckViewComponent.cs` — **tam kaynak**:

```csharp
public class LimitCheckViewComponent(IFrameworkParameterHelper frameworkParameterHelper) : ViewComponent
{
    public async Task<IViewComponentResult> InvokeAsync(LimitCheckComponentViewModel model)
    {
        await ApplyModuleParametersAsync(model);
        return View("~/Views/Shared/Components/LimitCheck/Default.cshtml", model);
    }

    /// Modül bazlı aktiflik ve excluded market kodlarını framework parametrelerden okur.
    /// Bu değerler kart içindeki hidden alanlara yazılır; component tüm kararlarını istemcide,
    /// ek istek atmadan bu değerler üzerinden verir. Modül verilmemişse veya parametre tanımlı
    /// değilse component aktif kabul edilir.
    private async Task ApplyModuleParametersAsync(LimitCheckComponentViewModel model)
    {
        if (string.IsNullOrWhiteSpace(model.Module)) return;

        var enabled = await frameworkParameterHelper.GetFrameworkParameterAsync(
            string.Format(FrameworkParameterConstants.LimitCheckModuleEnabled, model.Module));
        model.IsModuleEnabled = IsEnabled(enabled);

        model.ExcludedMarkets = await frameworkParameterHelper.GetFrameworkParameterAsync(
            string.Format(FrameworkParameterConstants.LimitCheckExcludedMarkets, model.Module)) ?? string.Empty;
    }

    /// Parametre yoksa/boşsa aktif kabul edilir; yalnızca açıkça "false"/"0" ise pasiftir.
    private static bool IsEnabled(string value)
    {
        if (string.IsNullOrWhiteSpace(value)) return true;
        var normalized = value.Trim();
        return !normalized.Equals("false", StringComparison.OrdinalIgnoreCase) && normalized != "0";
    }
}
```

**Alınacak dersler:**

1. `model.Module` → **modül parametreli ViewComponent**. Manuel Reeskont'ta `ProductGroup` aynı rolü oynayacak.
2. Framework parametresi **sunucuda okunup hidden alana basılıyor** → JS ek istek atmıyor.
   Manuel Reeskont'un kolon config'i de aynı yolla basılabilir (ekstra roundtrip yok).
3. **"Parametre yoksa AKTİF"** — platform genelinde bilinçli tercih (versiyon skew).
   MM'de `GetIsEnabledTawarruqModule()` de aynı gerekçeyle default `true`.

`limit-check.constants.js` — prefix disiplini (`CLC_` = **C**ustom **L**imit **C**heck):

```js
const CLC_BTN_REFRESH = "#btnRefreshLimitStatus";
const CLC_CARD = "#limitCard_";              // ← sonuna uniqueKey ekleniyor
const CLC_MODULE_ENABLED = "#limitModuleEnabled_";   // ViewComponent'in bastığı hidden alan
const CLC_EXCLUDED_MARKETS = "#limitExcludedMarkets_";
```

Enum + CSS eşleme deseni (Manuel Reeskont Status badge'leri için birebir aynısı):

```js
const LimitStateType = Object.freeze({
    CHECKING:    { Value: 0, Code: 'Checking' },
    NOT_CHECKED: { Value: 1, Code: 'NotChecked' },
    AVAILABLE:   { Value: 2, Code: 'Available' },
    NEAR_LIMIT:  { Value: 3, Code: 'NearLimit' },
    EXCEEDED:    { Value: 4, Code: 'Exceeded' },
    ERROR:       { Value: 5, Code: 'Error' }
})
const LimitStateCssClass = Object.freeze({
    [LimitStateType.NOT_CHECKED.Code]: 'not-checked',
    [LimitStateType.AVAILABLE.Code]:   'success',
    [LimitStateType.NEAR_LIMIT.Code]:  'warning',
    [LimitStateType.EXCEEDED.Code]:    'error',
    [LimitStateType.ERROR.Code]:       'error',
    [LimitStateType.CHECKING.Code]:    'checking'
})
```

Localization deseni:

```js
const applyLocalization = () => {
    $('.data-localization').each(function (index) {
        let localizationKey = $(this).data('localization-key');
        $(this).html(formatMessage(localizationKey))
    });
}
```

Para/oran formatlama — **`toFixed` değil DevExtreme**:

```js
const formatLimitMoney = (value, symbol = "$") =>
    (value === null || value === undefined || isNaN(value)) ? "-"
    : DevExpress.localization.formatNumber(Number(value), `${symbol}#,##0.00`);
```

`limit-check.endpoints.js` — endpoint'ler ayrı dosyada, hepsi **kendi WebUI controller'ına**:

```js
const fetchLimitDetailsForm = (uniqueKey) => get("/LimitCheck/Detail", { uniqueKey });
const checkLimit            = (requestBody) => post("/LimitCheck/LimitCheck", requestBody);
const fetchLimitDetails     = (requestData) => get("/LimitCheck/LimitDetails", requestData);
const fetchLimitProductInfo = (requestData) => get("/LimitCheck/LimitProductInfo", requestData);
```

---

## 5. `CashFlowViewComponent` — en ince hâli

```csharp
public class CashFlowViewComponent : ViewComponent
{
    public async Task<IViewComponentResult> InvokeAsync(CashFlowComponentViewModel model)
        => await Task.FromResult(View("Default", model));
}
```

→ ViewComponent'in **sunucuda iş yapması zorunlu değil**; sadece model taşıyabilir.
Manuel Reeskont'ta kolon config'i sunucuda basmak istiyorsak LimitCheck deseni, istemcide
JS'ten yüklemek istiyorsak CashFlow deseni.

---

## 6. Modül API'sine WebUI'den erişim (Refit)

`Trex.WebUI/Startup.cs:58-75` — **tam liste**:

```csharp
services.RegisterClientWebApiRefitClients<IClientFiAPI>(Configuration.GetValue<string>("FIApi"));
services.RegisterClientWebApiRefitClients<IClientFiBatchAPI>(Configuration.GetValue<string>("FIBatchApi"));
services.RegisterClientWebApiRefitClients<IClientMMAPI>(Configuration.GetValue<string>("MMApi"));
services.RegisterClientWebApiRefitClients<IClientMmBatchAPI>(Configuration.GetValue<string>("MMBatchApi"));
services.RegisterClientWebApiRefitClients<IClientFxAPI>(Configuration.GetValue<string>("FXApi"));
services.RegisterClientWebApiRefitClients<IClientDerivSWPAPI>(Configuration.GetValue<string>("DerivSwpApi"));
services.RegisterClientWebApiRefitClients<IClientDerivSWPBatchAPI>(Configuration.GetValue<string>("DerivSWPBatchAPI"));
services.RegisterClientWebApiRefitClients<IClientFxBatchAPI>(Configuration.GetValue<string>("FXBatchApi"));
services.RegisterClientWebApiRefitClients<IClientFundsAPI>(Configuration.GetValue<string>("FundsApi"));
services.RegisterClientWebApiRefitClients<IClientFundsBatchAPI>(Configuration.GetValue<string>("FundsBatchApi"));
services.RegisterClientWebApiRefitClients<IClientWarrantAPI>(Configuration.GetValue<string>("WarrantApi"));
services.RegisterClientWebApiRefitClients<IClientCommonAPI>(Configuration.GetValue<string>("CommonApi"));
services.RegisterClientWebApiRefitClients<IClientCommonBatchAPI>(Configuration.GetValue<string>("CommonBatchApi"));
services.RegisterClientWebApiRefitClients<IClientAccountingAPI>(Configuration.GetValue<string>("AccountingApi"));
services.RegisterClientWebApiRefitClients<IClientOptFXApi>(Configuration.GetValue<string>("OptFXApi"));
services.RegisterClientWebApiRefitClients<IClientOptFXBatchApi>(Configuration.GetValue<string>("OptFXBatchApi"));
services.RegisterClientWebApiRefitClients<IClientLimitApi>(Configuration.GetValue<string>("LimitApi"));
services.RegisterClientWebApiRefitClients<IClientLimitBatchApi>(Configuration.GetValue<string>("LimitBatchApi"));
```

Marker interface'leri (`Trex.WebUI/Services/Abstract/`) — hepsi `: IClientBaseAPI`:

| Marker | Not |
|---|---|
| `IClientMMAPI`, `IClientMmBatchAPI` | MM |
| `IClientFxAPI`, `IClientFxBatchAPI` | FX |
| `IClientFiAPI`, `IClientFiBatchAPI` | FI |
| `IClientFundsAPI`, `IClientFundsBatchAPI` | **InvFund** — adı `Funds` |
| `IClientDerivSWPAPI`, `IClientDerivSWPBatchAPI` | Deriv |
| `IClientCommonAPI`, `IClientCommonBatchAPI` | Common |
| `IClientWarrantAPI`, `IClientNeTrexFrameworkAPI` | |
| `IClientOptFXApi` / `IClientLimitApi` / `IClientAccountingAPI` | ⚠️ `Services/Abstract/` **glob'unda çıkmadı** — başka klasörde tanımlı; `Api` vs `API` yazımı da farklı |

### 🔴 Manuel Reeskont için 4 modülün durumu

| Modül | Marker | Durum |
|---|---|---|
| MM | `IClientMMAPI` | ✅ hazır |
| Fx | `IClientFxAPI` | ✅ hazır |
| FI | `IClientFiAPI` | ✅ marker hazır — **backend repo `repos/` altında bulunamadı** |
| InvFund | `IClientFundsAPI` | ✅ hazır (isim `Funds`) |
| OptionsFX | `IClientOptFXApi` | ✅ kayıtlı ama `Services/Abstract/` altında değil |

→ **Common için ayrıca bir şey yapmaya gerek yok, çünkü Common devre dışı.**
4 modüle de **doğrudan** interface yazılabilir; `RegisterClientWebApiRefitClients` taramayla
bulduğu için **ek DI kaydı gerekmez**.

---

## 7. Mevcut (eski) Manuel Reeskont ekranı — tam kaynak

`Controllers/ManuelReescont/ManuelRevaluationController.cs` (⚠️ `namespace Trex.WebUI.Controllers.FX.Report`):

```csharp
public class ManuelRevaluationController : BaseController
{
    private readonly ManuelReescontApi fxReescontApi;
    public ManuelRevaluationController(ManuelReescontApi fxReescontApi) { this.fxReescontApi = fxReescontApi; }

    public async Task<IActionResult> Index(string param)
    {
        var model = new ManuelReescontViewModel
        {
            GridModel = new GridCrudModel { ControllerName = "ManuelRevaluation", LoadAction = nameof(Load) },
            Product = new List<string> { ((int)ManualRediscount.RediscountProductTypes.Fx).ToString() },
            ReescontType = ((int)ManualRediscount.RediscountStatusTypes.All).ToString(),
            DateFilter = _DateTimeProvider.GetCurrentDateTime().Date,
            ReescontTypes = Enum.GetValues(typeof(ManualRediscount.RediscountStatusTypes))
                .Cast<ManualRediscount.RediscountStatusTypes>()
                .Select(e => new ReescontTypes { TypeCode = ((int)e).ToString(), TypeName = e.GetDisplayName() }).ToList(),
            Products = Enum.GetValues(typeof(ManualRediscount.RediscountProductTypes))
                .Cast<ManualRediscount.RediscountProductTypes>()
                .Select(e => new ManuelReescontProduct { ProductCode = ((int)e).ToString(), ProductName = e.GetDisplayName() }).ToList()
        };
        return View("~/Views/ManuelReescont/Index.cshtml", model);
    }

    public async Task<IActionResult> Load(ManuelReescontSelectReqest request)
    {
        //var mockData = ManuelReescontMockData.GetMockFxTransactions();
        //return Json(mockData);
        request.RediscountProductType = request.RediscountProducts
            .Split(',', StringSplitOptions.RemoveEmptyEntries)
            .Select(x => (ManualRediscount.RediscountProductTypes)Enum.Parse(typeof(ManualRediscount.RediscountProductTypes), x))
            .ToList();
        var response = await fxReescontApi.Select(request).ToContentExternal();
        return response.IsFailed() ? Json(response) : Json(response.Data.Rediscounts);
    }

    public async Task<IActionResult> CreateReescont([FromBody] CreateReescontRequest request)
    {
        var response = await fxReescontApi.CreateReescont(request).ToContentExternal();
        return Json(response);
    }
}
```

### Eski ekranın tespit edilen kusurları (yeni ekranda tekrarlanmayacak)

| # | Kusur |
|---|---|
| 1 | **Fx'e hardwired** — `ManuelReescontApi` tek modül, `Product` default `Fx`, sınıf adı `fxReescontApi` |
| 2 | `Load` **iki farklı şekil** döner (hata → response objesi, başarı → liste) |
| 3 | `RediscountProducts` **virgülle ayrılmış string** → `Split` + `Enum.Parse`; geçersiz değerde `Enum.Parse` **fırlatır**, `TryParse` yok |
| 4 | **Mock data yorum satırı olarak duruyor** (`ManuelReescontMockData.GetMockFxTransactions()`) |
| 5 | `Index` ve `Load` **`async` ama `await` yok** (`Index`) → derleyici uyarısı |
| 6 | Klasör adı **`ManuelReescont`** (yazım hatası), namespace **`FX.Report`** — üçü de tutarsız |
| 7 | `RediscountStatusTypes.**All**` var → dokümandaki "All yok" ifadesiyle çelişiyor (**C-01**'e ek kanıt) |
| 8 | Yetki: tek controller → doküman §9'un ekran-başına yetkisi bu yapıyla **karşılanamaz** |
| 9 | Server-side paging yok |
| 10 | Satır-bazlı hata gösterimi yok (`CreateReescont` tek response) |

⚠️ **`RediscountStatusTypes` içinde `All` VAR** — mevcut Fx ekranı `All` ile çalışıyor. Doküman
§3.5'te *"tek seçim, All yok"*, §4.7'de *"All eklenir"* diyor. Yani C-01 çelişkisinde **mevcut kod
"All var" tarafını destekliyor**. İş birimine bu bilgiyle git.

---

## 8. Yeni base component için sentez

| İhtiyaç (doküman) | Karşılığı olan mevcut desen | Kaynak |
|---|---|---|
| 3 ekran, tek component | `ProductGroup` parametreli ViewComponent | `LimitCheckViewComponent.model.Module` |
| Ürüne özel kolon config'i | ViewComponent sunucuda okuyup **hidden alana basar** (roundtrip yok) | `ApplyModuleParametersAsync` |
| Ürün ekibi kendi ucunu verebilsin | `dataSource.<op>.url` **override** | `cashflow.component.js:990` |
| `moduleCode` | `settings.moduleCode` — **zaten var** | `cashflow.component.js:112`, `:983` |
| Status badge + renk | `Object.freeze` enum + `CssClass` eşleme haritası | `limit-check.constants.js:39-73` |
| Aynı sayfada çoklu instance | `uniqueKey` + selector suffix'i (`#limitCard_`) | ikisinde de |
| Seçili satır / filtre state | ayrı `Context` sınıfı (merge'li `setState`) | `cashflow.context.js` |
| Modüle istek | **WebUI Controller** + modül başına Refit interface | `Startup.cs:58-75` |
| Ekran başına yetki | **3 ayrı Controller** (yetki = Controller/Action) | `BaseController` → framework `[CustomAuthorize]` |
| Para formatı | `DevExpress.localization.formatNumber` | `limit-check.constants.js:97` |
| Localization | `.data-localization` + `data-localization-key` + `formatMessage` | `limit-check.constants.js:85` |
| Sabit çakışmasını önleme | **prefix** (`CLC_`, `CF_`) → bizde `MR_` | Hard Rule 4 |

### Reddedilenler ve nedeni

| Reddedilen | Neden |
|---|---|
| `paymentComponent.js` deseni (nesil 1) | Tek dosya + global `const` → base component olarak ölçeklenmez, `const` çakışma riski. Kullanıcı emsal gösterdi ama **cashFlow daha ileri**; ikisi de incelendi, cashFlow seçildi |
| `ajax.js`'in `get`/`post`'una satır-bazlı hata için güvenmek | `IsSuccess === false` → `null`, **hata yutulur** |
| `Load`'un iki-şekilli response'u | Tutarsız; grid sessizce boşalır |
| UI'den `baseUrl` ile modül seçmek | `settings.baseUrl` **uygulama kökü**; modül adresi değil |

---

## 9. Açık kalan / doğrulanmayan

- `Views/Shared/Components/CashFlow/Default.cshtml` ve `LimitCheck/Default.cshtml` **okunmadı** —
  hidden alan + DevExtreme widget yerleşimi kodlanırken okunmalı.
- `FrameworkParameterConstants` tam listesi okunmadı — Manuel Reeskont için parametre eklenecekse
  buradaki adlandırma konvansiyonuna bakılmalı.
- `Framework.WebUI.Controllers.BaseController` NuGet içinde; `[CustomAuthorize]`'ın failure davranışı
  (redirect mi 403 mü) **doğrulanmadı**.
- `IClientOptFXApi` / `IClientLimitApi` / `IClientAccountingAPI` tanım dosyaları `Services/Abstract/`
  altında **değil** — nerede olduğu tespit edilmedi (Manuel Reeskont Faz 1'i etkilemiyor).
- `ManuelReescontApi` service wrapper'ının içi okunmadı (hangi marker'ı implemente ediyor,
  hangi endpoint'leri var).
