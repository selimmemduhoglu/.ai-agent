# Analiz #3 — NetTrex.Web.UI: Ortak Yapı · Refit Marker'ları · Runtime Modül Yönlendirme · Yetki (HAM AJAN ÇIKTISI)

**Tarih:** 2026-08-12 · **Taranan repo:** `c:\Users\Treasy-70\source\repos\NetTrex.Web.UI` (bin/obj/.vs/node_modules/dist/bundles hariç)

**Aranan cevap:** Mevcut Manuel Reeskont ekranı FX'e hardwire (`ManuelReescontApi : IClientFxAPI`). Genelleşince MM/FX/Options/Fund/FI hepsi için çalışacak. Web.UI'de modüle-agnostik yapı, paylaşılan bileşen deseni, runtime modül yönlendirme ve yetki nasıl?

**⚠️ Kritik bulgular:**
- 🔴 **Runtime base-URL resolver YOK** — Refit client'lar marker interface'inden compile-time bağlı. Tek desen: modül başına ayrı interface + `IServiceProvider` (canlı örnek: `EodController.cs:364`)
- 🔴 **Permission = ControllerAdı/ActionAdı** → tek generic controller = tüm modüller aynı permission
- 🔴 Marker interface **isimleri tutarsız** (dosya adı ≠ tip adı)
- ⚠️ Mevcut Manuel Reeskont JS'i **inline** (`Index.cshtml` satır 127-298)

> Bu dosya ajan çıktısının **hamıdır**, kısaltılmamıştır. Özet/karar → [`../02-mimari-karar.md`](../02-mimari-karar.md)
>
> **NOT:** Bu analiz **DailyFlow keşfinden ÖNCE** yapıldı. DailyFlow bulgusu (fan-out'un Common'da olduğu) bu analizin
> C bölümündeki "modül başına ayrı Refit interface" önerisini **geçersiz kılıyor** — bkz. [`analiz-5-dailyflow-ui.md`](analiz-5-dailyflow-ui.md).

---

## A) Modüle-agnostik / paylaşılan yapı

**Var.** `Areas/` yok, ama üç ayrı konvansiyon kullanılıyor:

| Klasör | Amaç | Örnek |
|---|---|---|
| `Controllers/Common/` | Modülden bağımsız tanım/ortak ekranlar (CommonApi'ye gider) | `Code\Web\UI\Trex.WebUI\Controllers\Common\Definitions\CurrencyController.cs` |
| `Views/Common/` | Aynı ekranların view'ları (`Views/Common/Definitions/...`, `Views/Common/Rates/...`) | `Code\Web\UI\Trex.WebUI\Views\Common\Definitions\Currency\Index.cshtml` |
| `Views/Shared/Components/` | Çok-modüllü paylaşılan bileşenler | `Code\Web\UI\Trex.WebUI\Views\Shared\Components\LimitCheck\Default.cshtml` |

**Birden çok modülün API'sine giden ortak controller — 2 canlı örnek:**

**1.** `Code\Web\UI\Trex.WebUI\Controllers\Eod\Eod\EodController.cs` — tek ekran, dropdown'dan modül seçimi (`BatchModuleType`), her action içinde `switch` ile `GetRefitClient<IEodMmApi>()` / `<IEodFxApi>()` / `<IEodOptFXApi>()` ...
Resolver: satır **364**
```csharp
public T GetRefitClient<T>() where T : IClientBaseAPI => serviceProvider.GetService<T>();
```

**2.** `Code\Web\UI\Trex.WebUI\Controllers\CashFlow\CashFlowController.cs` — `request.Module` (`ModuleType` enum) üzerinden `switch` + `serviceProvider.GetService<IInterbankLoanCashFlowAPI>()`. Şu an sadece `ModuleType.LN` dolu, diğerleri açık — yani "genelleştirilmiş bileşen controller'ı" iskeleti olarak birebir kopyalanabilir desen.

> Not: Bugünkü `ManuelRevaluationController` bu desene uymuyor — namespace'i `Trex.WebUI.Controllers.FX.Report`, dosyası `Controllers\ManuelReescont\` altında, view'ı `Views\ManuelReescont\Index.cshtml`. **Tutarsız** (namespace/klasör uyuşmuyor).

---

## B) Refit client interface'leri (base marker'lar)

Hepsi **yerel** projelerde, NuGet değil.

Kök marker: `Code\Web\UI\Trex.FrameworkCommon\Api\IClientBaseAPI.cs` (boş interface, sadece marker)

Modül marker'ları — hepsi `Code\Web\UI\Trex.WebUI\Services\Abstract\` altında:

| Dosya | Interface adı (⚠️ dikkat: dosya adı ≠ tip adı) |
|---|---|
| `IClientFxAPI.cs` | `IClientFxAPI` |
| `IClientFxBatchAPI.cs` | `IClientFxBatchAPI` |
| `IClientMmAPI.cs` | **`IClientMMAPI`** (çift M) |
| `IClientMmBatchAPI.cs` | `IClientMmBatchAPI` |
| `IClientFiAPI.cs` | `IClientFiAPI` |
| `IClientFiBatchAPI.cs` | `IClientFiBatchAPI` |
| `IClientFundsAPI.cs` | **`IClientFundsAPI`** (Fund değil, **Funds**) |
| `IClientFundsBatchAPI.cs` | `IClientFundsBatchAPI` |
| `IClientDerivSWPAPI.cs` | `IClientDerivSWPAPI` |
| `IClientDerivSWPBatchAPI.cs` | `IClientDerivSWPBatchAPI` |
| `IClientWarrantAPI.cs` | `IClientWarrantAPI` |
| `IClientCommonAPI.cs` | `IClientCommonAPI` |
| `IClientCommonBatchAPI.cs` | `IClientCommonBatchAPI` |
| `IClientAccountingAPI.cs` | `IClientAccountingAPI` |
| `IClientNeTrexFrameworkAPI.cs` | `IClientNeTrexFrameworkAPI` |
| `Abstract\Options\IClientOptionsFXApi.cs` | **`IClientOptFXApi`** (dosya adıyla uyumsuz) |
| `Abstract\Options\IClientOptFXBatchApi.cs` | `IClientOptFXBatchApi` |
| `Abstract\Limit\IClientLimitApi.cs` | `IClientLimitApi` |
| `Abstract\Limit\IClientLimitBatchApi.cs` | `IClientLimitBatchApi` |

`IClientOptionsApi` / `IClientFundApi` / `IClientFiApi` (küçük i / tekil isimler) **tespit edilmedi** — doğru isimler yukarıdaki tabloda.

Namespace uyarısı: `IClientFxAPI` vb. `namespace Trex.WebUI.Services` içinde (klasör `Services/Abstract` olmasına rağmen); Options/Limit olanlar file-scoped ve farklı namespace'te.

---

## C) Base URL çözümü ve runtime modül yönlendirme

**Kayıt mekanizması:** `Code\Web\UI\Trex.FrameworkCommon\Api\RefitExtensions.cs:78` → `RegisterClientWebApiRefitClients<T>(services, apiUrl)`. `AppDomain`'deki tüm assembly'leri tarar, `T`'den türeyen her interface'i bulur ve `AddRefitClient(...).ConfigureHttpClient(c => c.BaseAddress = new Uri(apiUrl)).AddHttpMessageHandler<RefitHttpMessageHandler>()` ile kaydeder.

Yani `ManuelReescontApi : IClientFxAPI` olduğu için **compile-time'da** FX API'ye bağlanmış durumda; base URL'i `FXApi` config key'inden geliyor.

**Konfigürasyon:** `Code\Web\UI\Trex.WebUI\Startup.cs:58-75` (root-level appsettings key'leri, section yok):
`FIApi`, `FIBatchApi`, `MMApi`, `MMBatchApi`, `FXApi`, `FXBatchApi`, `DerivSwpApi`, `DerivSWPBatchAPI`, `FundsApi`, `FundsBatchApi`, `WarrantApi`, `OptFXApi`, `OptFXBatchApi`, `LimitApi`, `LimitBatchApi`, `CommonApi`, `CommonBatchApi`, `AccountingApi`
Değerler: `Code\Web\UI\Trex.WebUI\appsettings.json:91-109`.

**"Dropdown'dan modül seç → o modülün API'sine git" nasıl yapılır:**
- 🔴 Named HttpClient / custom resolver / factory **tespit edilmedi**. `IHttpClientFactory` doğrudan hiçbir yerde kullanılmıyor (tek istisna `Code\Framework\Framework.SSO\KeyCloak\KeyCloakAuthenticator.cs`, ilgisiz).
- Mevcut tek desen: **her modül için ayrı Refit interface tanımla** (`IRediscountFxApi : IClientFxAPI`, `IRediscountMmApi : IClientMMAPI`, `IRediscountOptApi : IClientOptFXApi`, `IRediscountFundApi : IClientFundsAPI`, `IRediscountFiApi : IClientFiAPI`) → hepsi aynı endpoint imzalarını taşır → controller'da `IServiceProvider.GetService<T>()` ile enum switch'e göre çöz. Aynen `EodController.GetRefitClient<T>()` (satır 364) ve `CashFlowController` yapıyor.
- Alternatif (mevcut altyapıda hazır **değil**, yeni yazılması gerekir): `RegisterClientWebApiRefitClients` içindeki `AddRefitClient` çağrısına isim vermek ya da `RestService.For<T>(httpClient)` ile runtime'da base address seçen bir factory eklemek. **Şu an böyle bir şey yok.**

> 🔑 **SONRADAN GELEN BULGU (analiz #5):** Bu bölümün önerisi **artık geçersiz.** DailyFlow deseni gösteriyor ki
> doğru çözüm modül başına Refit interface **değil**, tek `: IClientCommonAPI` interface'i + fan-out'un **Common backend'de**
> yapılması. Bkz. [`analiz-5-dailyflow-ui.md`](analiz-5-dailyflow-ui.md) § B.

---

## D) Paylaşılan Razor bileşen deseni

**ViewComponent + `Views/Shared/Components/<Name>/Default.cshtml` + `wwwroot/js/shared/components/<name>/` JS modülü.** TagHelper deseni tespit edilmedi.

ViewComponent sınıfları: `Code\Web\UI\Trex.WebUI\ViewComponents\` (**27 adet**). Model'leri `Code\Web\UI\Trex.WebUI\Models\Shared\Components\<Name>\`.

**Birden fazla ekranın kullandığı örnek — LimitCheck (8 view):**
- `Code\Web\UI\Trex.WebUI\ViewComponents\LimitCheck\LimitCheckViewComponent.cs` — `InvokeAsync(LimitCheckComponentViewModel model)`, **`model.Module` string'i** ile framework parametresinden modül bazlı aktiflik okuyor (`LimitCheckModuleEnabled`, `LimitCheckExcludedMarkets`). **Bu, "modül parametreli paylaşılan bileşen" için en yakın hazır örnek.**
- View: `Views\Shared\Components\LimitCheck\Default.cshtml`, `_Detail.cshtml`
- JS: `wwwroot\js\shared\components\limit-check\{limit-check.component.js, .constants.js, .endpoints.js, .popup.js}`
- Kullananlar: `Views\FX\Transaction\FxTransaction\{Spot,Forward}.cshtml`, `Views\FX\Transaction\SwapTransaction\Swap.cshtml`, `Views\FX\Transaction\PmSwapTransaction\Swap.cshtml`, `Views\FX\Transaction\PmTransaction\{Spot,Forward}.cshtml`, `Views\MM\Transaction\_Form.cshtml`, `Views\MM\InterbankLoan\_Form.cshtml`

**DevExtreme grid içeren paylaşılan bileşen — CashFlow (evet, var):**
- `Views\Shared\Components\CashFlow\Default.cshtml` — satır 12 ve 53'te `Html.DevExtreme().DataGrid<CashFlowComponentModel>()` / `DataGrid<CashFlowCompoundModel>()`
- `ViewComponents\CashFlow\CashFlowViewComponent.cs`, ek `Form.cshtml` + `Preview.cshtml` partial'ları
- Controller (partial + AJAX endpoint sağlayıcı, **modül switch'li**): `Controllers\CashFlow\CashFlowController.cs`
- JS: `wwwroot\js\shared\components\cashFlow\cashflow.{component,constants,context,endpoints,form,preview,selectors,utils}.js`
- Kullananlar: `Views\MM\InterbankLoan\_Form.cshtml`, `_Preview.cshtml`

**Genelleştirme için önerilen hedef desen bu üçlü:** ViewComponent (modül parametresi alır) + `Views/Shared/Components/ManualRediscount/Default.cshtml` + `Controllers/Common/...` altında controller + `wwwroot/js/shared/components/manual-rediscount/`.

---

## E) Yetkilendirme

Convention-based, **controller/action adı** üzerinden — attribute'u ekranlara tek tek yazmıyorsunuz:

- `Code\Framework\Framework.WebUI\Controllers\BaseController.cs:31` → sınıfın üstünde `[CustomAuthorize]` var, tüm controller'lar bundan miras alıyor (`Trex.WebUI.Controllers.BaseController` → `Framework.WebUI.Controllers.BaseController`).
- `Code\Framework\Framework.Authorization\CustomAuthorizeAttribute.cs` — parametresiz ctor policy'yi `"Dynamic"` yapar (`Code\Framework\Framework.Abstractions\Constants\Authorization.cs:9` → `DeafulPermissionName = "Dynamic"`).
- `Code\Framework\Framework.Authorization\AuthorizationPolicyProvider\AuthorizationPolicyProvider.cs` — bilinmeyen policy adını runtime'da `PermissionRequirement`'a çevirir.
- **`Code\Framework\Framework.Authorization\Handler\PermissionHandler.cs:43-66`** — `"Dynamic"` ise endpoint'ten `ControllerActionDescriptor` alıp **`userManager.HasPermissionAsync(controllerName, actionName)`**; değilse hardcoded permission adıyla kontrol. Yetkisizse AccessDenied'a redirect.
- DI kaydı: `Code\Framework\Framework.Authorization\Startup.cs`
- Grid buton bazlı yetki: `Code\Web\UI\Trex.WebUI\Extensions\Framework\TreeListGridBuilderExtensions.cs:234-244` — `crudGridModel.UpdateAction/InsertAction/...` için tek tek `HasPermissionAsync`.
- Controller içi manuel kontrol örneği: `Controllers\FI\Customer\SicController.cs:48`, ve `Trex.WebUI\Controllers\BaseController.cs:105` `HasPermission(controllerName, actionName)`.
- Menü: `Code\Web\UI\Trex.WebUI\Controllers\MenuController.cs` — `IModularMenuDefinitionApi.GetModuleMenu(request)`, menü backend'den modül bazlı geliyor. Menü tanım ekranı: `Views\Common\MenuDefinition\Index.cshtml`.

> 🔴 **Genelleştirme etkisi:** permission = `ControllerName/ActionName` olduğu için tek bir `ManualRediscountController` yaparsanız
> tüm modüller/ekranlar **aynı** permission'ı paylaşır. Ekran bazlı yetki isteniyorsa ya action bazında
> `[CustomAuthorize("<hardcoded permission>")]` ya da controller içinde manuel `HasPermission` gerekir.
> → **Karar: 3 ayrı controller** (ADR-MR-003).

---

## F) `wwwroot/js` konvansiyonu

Kök: `Code\Web\UI\Trex.WebUI\wwwroot\js\`

- **Ekran JS'leri:** `wwwroot/js/pages/<domain>/<screen>/index.js` + yanında `constraints/`, `context/`, `popups/`, `services/` alt klasörleri. Örnek: `wwwroot\js\pages\treasury\interbank-loan\index.js` (en olgun/modern örnek), `wwwroot\js\pages\treasury\tawarruq\index.js`. `pages/` altındaki domain'ler: `treasury`, `definitions`, `reports`, `limit`, `market-data`, `quant`, `flow`, `dashboard`, `batch-items`, `swap-points`, `administration`, `daily-flow`, `MKK`, `sukuk-payment`, `sukuk-transfer`, `flow-state`, `error`.
- **Eski/legacy konvansiyon (hâlâ çok yaygın):** modül kökünde düz dosyalar — `wwwroot/js/fx/`, `wwwroot/js/FI/`, `wwwroot/js/fund/`, `wwwroot/js/derivswp/`, `wwwroot/js/warrant/`, `wwwroot/js/reports/`, ör. `wwwroot\js\fund\invfundrevaluationreport.js`.
- **Paylaşılan JS bileşenleri:** `wwwroot\js\shared\components\` — klasörlü (`cashFlow/`, `limit-check/`) veya tek dosyalı (`amortizationComponent.js`, `paymentComponent.js`, `customerAccountsComponent.js`, `excelExportImport.js`, `tawarruqAgentComponent.js`, `amortization-configuration.component.js`). **Yeni bileşenler klasörlü + `<name>.component.js` / `.endpoints.js` / `.constants.js` / `.context.js` şemasında.**
- Diğer shared: `wwwroot\js\shared\utils\` (ajax, date, general, instance, currency-input, portfolio, session-check), `shared\partialview\transaction-document.js`, `shared\netix-widgets.js`, `shared\common-constants.js`, `shared\swift-messages\`, `shared\transfer-messages\`.
- **Localization:** `wwwroot\js\localization\pages\<screen>\<screen>-{tr,en}.json` + `wwwroot\js\localization\global\`. Mevcut ekranın dosyaları: `wwwroot\js\localization\pages\manuel-reescont\manuel-reescont-{tr,en}.json` (key prefix'leri `dgManuelReescont-`, `dxMReescont-`).

> ⚠️ **Mevcut Manuel Reeskont ekranının JS'i ayrı dosyada DEĞİL** — `Views\ManuelReescont\Index.cshtml` içinde
> satır **127-298** arası inline `<script>` (dosya toplam 297 satır). CSS'i ise ayrı:
> `wwwroot\css\pages\reconciliation\manuel-revaluation.css`. Yani genelleştirme sırasında JS'in
> `wwwroot/js/shared/components/manual-rediscount/` altına **çıkarılması gerekecek**.
