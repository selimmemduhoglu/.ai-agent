# Analiz #1 — MicroUI Mimarisi: Shell · SharedDependency · Ekran Kurulumu (HAM AJAN ÇIKTISI)

**Tarih:** 2026-08-12 · **Taranan repolar:** `Treasy.Shell` · `Treasy.MicroUI.Packages` · `Treasy.MM.UI`

**Aranan cevap:** Paylaşılan bir DevExtreme grid ekran bileşeni MicroUI dünyasında nereye yazılır? Paketten tam ekran çıkabiliyor mu?

**⚠️ Kritik bulgular:**
- ✅ `Treasy.MicroUI.SharedDependency` bir **RCL** (`AddRazorSupportForMvc`) — paketten **tam ekran** (Login/Error) ve **10 adet DevExtreme grid'li ortak bileşen** çıkıyor
- 🔴 `Treasy.MM.UI`'de **ekran bazlı sunucu yetkisi fiilen kapalı** — tek `[CustomAuthorize]` yok
- 🔴 Doküman bayatlığı: MM.UI dokümanları SharedDependency **1.0.3** diyor, gerçek **1.0.4-dev12**

> Bu dosya ajan çıktısının **hamıdır**, kısaltılmamıştır.

---

## A) Treasy.Shell — host/shell uygulaması + YARP reverse proxy

**Ne:** Bağımsız çalışan .NET MVC Micro UI'ları tek host altında toplayan **shell**. iframe **değil**, MVC area **değil** — YARP reverse proxy + HTML response rewrite.

| Konu | Dosya |
|---|---|
| Giriş noktası, pipeline sırası | `Treasy.Shell\Code\Treasy.Shell\Program.cs` |
| Servis kayıtları (`AddShellServices`) | `...\Treasy.Shell.Business\ServiceRegistration.cs` |
| **Ana mekanizma (rewrite/layout/buffer)** | `...\Treasy.Shell.Business\Middlewares\MicroFrontendHtmlRewriteMiddleware.cs` |
| Discovery/health sorgulama | `...\Treasy.Shell.Business\Services\MicroFrontendDiscoveryService.cs` |
| Config modeli | `...\Treasy.Shell.Core\Models\MicroFrontend\{MicroFrontendOption,MicroFrontendRegistration,MicroFrontendInfo,MicroFrontendMenuItem}.cs` |
| Layout modu enum | `...\Treasy.Shell.Core\Enums\ShellLayoutModes.cs` |
| Client-side path rewrite | `...\Treasy.Shell\wwwroot\js\client-side-routing-shim.js` (satır 56: `/menu/getmenu` rewrite'tan muaf) |
| **Uçtan uca akış dokümanı (çok iyi)** | `...\Treasy.Shell\Code\Dokumanlar\Shell-Calisma-Akisi.md` |
| Amaç dokümanı | `...\Treasy.Shell\Documents\Shell-Amaci.md` |

**Micro UI shell'e nasıl bağlanır** — 2 yerde kayıt, `Treasy.Shell\appsettings.json`:
1. `MicroFrontends:Services` (satır ~137-175): `mm` girdisi → `code: "mm"`, `baseAddress: http://micro-ui-mm:80/`, `discoveryPath: /Discovery/Info`, `healthPath: /Discovery/Health`, `forceUseMicroFrontendLayout`
2. `ReverseProxy:Routes.mm` (satır ~200): `Match.Path = /mm/{**catch-all}` + `PathRemovePrefix: /mm` + `RequestHeaderOriginalHost`; `ReverseProxy:Clusters.mm` → `http://nettrex-micro-ui-mm:80/`

Yani **route prefix = `code`** (`/mm/MmTransaction/Index` → micro'ya `/MmTransaction/Index` olarak gider). Shell portu **`5206`** (`...\Treasy.Shell\Properties\launchSettings.json:8`).

**Manifest tarafı (micro UI'nin sözleşmesi):** `Treasy.MM.UI.Web\Controllers\BaseControllers\DiscoveryController.cs` — `[AllowAnonymous]`, `Info()` düz anonim nesne döner: `microCode`, `displayName`, `routes`, `menu`, `healthEndpoint`, `version`. Pakette sözleşme tipi yok (satır 9-11 yorumu). Paket tarafında yalnızca `DiscoveryController.Health()` var (`Treasy.MicroUI.SharedDependency\Controllers\DiscoveryController.cs`) — **`Info` her micro UI'de kendi yazılır**.

**Menü nereden geliyor:** Discovery'deki `menu` listesi Shell modelinde var (`MicroFrontendInfo.Menu`) ama **gerçek menü oradan render edilmiyor**. Gerçek menü:
- Render: `Treasy.MicroUI.SharedDependency\Views\Shared\Templates\Layout\_LayoutMenuDrawerContent.cshtml` — DevExtreme `TreeView`, DataSource `.Controller("Menu").LoadAction("GetMenu")`
- Endpoint: `Treasy.MicroUI.SharedDependency\Controllers\MenuController.cs` → `menuDefinitionApi.GetModuleMenu(request)` yani **Common API'den** gelir; `request.CurrentUserId`, `SkipAuthorization`, `SelectedLanguage`, `ApplicationName` (Shell'in gönderdiği `X-Application-Name` header'ı, satır 13-22) doldurulur.

**Shell↔micro veri taşıma:** ViewBag payload header + session (`Treasy.Shell.Core\Constants\ViewBagPayloadSessionConstants.cs`, `ApplicationHeaderConstants.cs`), Shell layout'a gömme `Views\Shared\_ShellLayoutContainer.cshtml` + `ViewRenderers\RazorPartialRenderer.cs`.

---

## B) Treasy.MicroUI.Packages — 1 tane C# paketi, 12 tane npm paketi

Ölçüm (obj/bin/node_modules hariç dosya sayımı):

| Proje | .cs | .cshtml | .ts | Ne üretiyor |
|---|---|---|---|---|
| **Treasy.MicroUI.SharedDependency** | çok | **47** | var | **NuGet (RCL)** — tek C# paketi. `Version 1.0.4-dev12` |
| Authorization | 0 | 0 | 8 | npm `@treasy/authorization` |
| Builders | 0 | 0 | 16 | npm `@treasy/builders` |
| Components | 0 | 0 | 27 | npm `@treasy/components` |
| Constants | 0 | 0 | 8 | npm `@treasy/constants` |
| Context | 0 | 0 | 6 | npm `@treasy/context` |
| Enums | 0 | 0 | 7 | npm `@treasy/enums` |
| Flow | 0 | 0 | 2 | npm `@treasy/flow` |
| Formatters | 0 | 0 | 4 | npm `@treasy/formatters` |
| Helpers | 0 | 0 | 26 | npm `@treasy/helpers` |
| IdentifiersAndSelectors | 0 | 0 | 12 | npm `@treasy/identifiers-and-selectors` |
| Notification | 0 | 0 | 4 | npm `@treasy/notification` |
| Translation | 0 | 0 | 10 | npm `@treasy/translation` |
| TestKit | 0 | 0 | 66 | npm (Playwright/Vitest kit) |
| Documents | 0 | 0 | 0 | sadece MD (`Microsoft.NET.Sdk`, paketlenmiyor) |

Satellite projeler `Microsoft.NET.Sdk.Razor` SDK'sı kullanıyor ama **içleri tamamen TypeScript** — asıl dağıtım `PublishNpmPackageToNexus` target'ı ile Nexus'a npm publish (ör. `Treasy.MicroUI.Components\Treasy.MicroUI.Components.csproj:17-23`). Nexus: `http://192.168.10.241:8081/repository/treasy-npm/`.

### 🔑 Ortak EKRAN paket olarak dağıtılabiliyor mu? → **EVET**

`Treasy.MicroUI.SharedDependency\Treasy.MicroUI.SharedDependency.csproj`:
```xml
<Project Sdk="Microsoft.NET.Sdk.Razor">
  <AddRazorSupportForMvc>true</AddRazorSupportForMvc>   <!-- satır 7: MVC View'lı RCL -->
  <Version>1.0.4-dev12</Version>
```
- View'lar assembly'ye gömülü + `.AddApplicationPart(typeof(SharedDependencyConfiguration).Assembly)` (`Configurations\SharedDependencyConfiguration.cs:103`) → tüketici projede paketin View'ları/ViewComponent'leri/Controller'ları doğrudan çözülür.
- Static web asset kökü: `~/_content/Treasy.MicroUI.SharedDependency` (`Config.cs:11`, `SHARED_DEPENDENCY_ASSET_PATH`).
- `AddRazorRuntimeCompilation` **tespit edilmedi** (hiçbir yerde yok) — runtime compilation kullanılmıyor.
- MSBuild entegrasyonu paketle geliyor: `buildTransitive\Treasy.MicroUI.SharedDependency.{props,targets}` + `build\vite\treasy-vite-*.mjs` (csproj satır 52-72). Vite entry **auto-discovery** Razor taramasıyla.
- **Paketten çıkan tam ekran örnekleri (precedent):** `Controllers\LoginController.cs:47` → `return View("Pages/Login/Index")` ve `Views\Shared\Pages\Login\Index.cshtml`; `ErrorController.cs:52` → `Views\Shared\Pages\Error\Index.cshtml`.
- **Paketten çıkan ortak grid/form bileşenleri:** `Views\Shared\Components\{AdvanceAndStateFilter,Amortization,AmortizationConfiguration,CurrenciesLookup,CustomerAccounts,LimitCheck,Payment,TransactionDocument,TransactionNote,TransferMessages}\Default.cshtml` + `ViewComponents\*ViewComponent.cs` (4 tane) + `Controllers\Limit\LimitCheckController.cs:22`.
- TagHelper dağıtımı: `TagHelpers\TreasyScriptTagHelper.cs` — `<treasy-script src="..." bundle-mode="...">`; Vite dev server / bundle / `_content/` yolu ayrımını yapıyor (satır 13, 62-73, 259).

**Sonuç:** paketler sadece model/helper/client değil. **Ortak bir ekran (Razor View + ViewComponent + Controller + wwwroot asset) SharedDependency ile dağıtılabiliyor; TS tarafı ise `@treasy/components` npm paketinden gider.**

---

## C) Treasy.MM.UI — bir ekranın tam dosya zinciri (MmTransaction)

Katmanlar: `Core` (model) → `Business` (Refit + VM + AutoMapper) → `Web` (Controller + View + TS). `Web.csproj` yalnızca `Business`'a referans verir.

**MmTransaction tam listesi:**

| Rol | Dosya |
|---|---|
| Controller | `src\Treasy.MM.UI.Web\Controllers\MmTransactionController.cs` (`: ControllerBase` = `Treasy.MicroUI.SharedDependency.Controllers.ControllerBase`, satır 25) |
| Refit ApiReference | `src\Treasy.MM.UI.Business\Services\ApiReferences\IMmTransactionApi.cs` |
| ViewModel | `src\Treasy.MM.UI.Business\ViewModels\Transaction\MmTransaction{IndexVM,FormVM,PreviewVM,RolloverVM,ListFilter}.cs` |
| Core model | `src\Treasy.MM.UI.Core\Models\Transaction\{EntityModel(14),Request(17),Response(14)}\` |
| View | `src\Treasy.MM.UI.Web\Views\MmTransaction\Index.cshtml` · `_Form.cshtml` · `_Preview.cshtml` · `_Rollover.cshtml` |
| View template'leri | `Views\MmTransaction\Templates\_{AdvanceFilters,CustomStateFilter,FileImport,History,PopoverCounterparty,Valuation}.cshtml` |
| TypeScript | `wwwroot\js\pages\mm-transaction\index.ts` · `bridges\index.ts` · `popups\{form,form-events,preview,rollover,multiplePayment}.ts` · `services\index.ts` · `utils\{common,popupOptions}.ts` · `constraints\{createPageComponentsIDs,enums}.ts` · `cashFlowOperations\{index,common}.ts` |
| Localization | `wwwroot\localization\pages\mm-transaction\mm-transaction-{tr,en}.json` |
| CSS | `wwwroot\css\pages\mm-transaction\mm-transaction.css` (Index.cshtml:13) |
| Layout zinciri | `Views\_ViewStart.cshtml` → `Views\Shared\_LayoutProxy.cshtml` (`Layout="_Layout"`, paketten) |
| ViewImports | `Views\_ViewImports.cshtml` — `@addTagHelper *, Treasy.MicroUI.SharedDependency` + `@inherits ...MicroUiRazorPageBase<TModel>` |
| Discovery kaydı | `Controllers\BaseControllers\DiscoveryController.cs:30` → `new("Borrowing and Placement", "/MmTransaction")` |

**DevExtreme:** kullanılıyor — **`Html.DevExtreme()` MVC wrapper (fluent)**, saf jQuery `dxDataGrid()` değil (C# tarafında). Sürüm **22.2.6** (`Treasy.MicroUI.SharedDependency\wwwroot\lib\devextreme\js\dx.all.js` banner). DLL'ler pakette bundle: `Libraries\DevExtreme\DevExtreme.AspNet.{Core,Data}.dll` (csproj satır 75-84, `PackagePath="lib\net10.0"`).

Grid kurulumu — `Views\MmTransaction\Index.cshtml:38-95`:
```razor
@(Html.DevExtreme().DataGrid<MMTransactionSelectModel>()
    .ToTreasyDataGrid("dgMMTransactions")
    .TreasyDataSource(Model.GridModel, loadParams: new { StateFilter = JSHelper.ValueFromDxSelectBox("#sbStateFilter"), ... })
    .FlowColumnsWithMakerChecker(columns => { columns.AddFor(x => x.LogicalReference); ... })
    .TreasyEditing(o => o.TreasyDataGridCustomPopup(p => p.Title(Model.GridModel.PopupTitle))))
```
`ToTreasyDataGrid`/`TreasyDataSource`/`FlowColumnsWithMakerChecker`/`TreasyEditing` → `Treasy.MicroUI.SharedDependency.Helpers.DevExtreme`.
Script bağlama: `Index.cshtml:209` `<treasy-script src="~/js/pages/mm-transaction/index.ts" bundle-mode="Always">`.

**Backend'e gidiş: Refit** (HttpClient elle kullanılmıyor). `IMmTransactionApi.cs:12`:
```csharp
public interface IMmTransactionApi : IClientMmApi   // base interface = hangi backend (MMApi)
{
    [Post("/transaction/select")]
    Task<ApiResponse<MMTransactionSelectResponse>> Select([Body] MMTransactionSelectRequest request);
```
Kayıt otomatik: MM'de hiç `AddRefitClient` yok (`Business\ServiceRegistration.cs` sadece AutoMapper + `SharedDependencyConfiguration.ConfigureServices`); paket `AppDomain` taramasıyla `IClientBaseApi` türevlerini bulup kaydediyor → `Treasy.MicroUI.SharedDependency\Helpers\RefitExtensions.cs:77-124` (`RegisterClientWebApiRefitClients<T>`, `AddRefitClient(apiInterface, refitSettings)` satır 118). Controller'da tüketim deseni: `await api.X(req).ToContentExternal()` + `IsFailed()`.

Bootstrap: `Web\Program.cs` sadece 5 satır — `AddMicroUiWebHost()` / `AddMicroUiServices()` / `UseMicroUiPipeline()`. Portlar: Web **`5104`**, Vite **`6104`** (`Web.csproj:10`).

---

## D) SharedDependency referansı

**Var.** Tek yerde, transitif yayılıyor:

`src\Treasy.MM.UI.Core\Treasy.MM.UI.Core.csproj`:
```xml
<PackageReference Include="Netix.Core.Flow.StateEngine" Version="10.0.0" />
<PackageReference Include="Treasy.MicroUI.SharedDependency" Version="1.0.4-dev12" />
```
`Business` → `Core` project reference, `Web` → `Business`. `Web.csproj`'de doğrudan paket referansı yok; sadece paket property'leri set ediliyor (`TreasyEnableViteBuild`, `TreasyEnableLocalizationBundler`, `TreasyViteDevServerPort=6104`).

> ⚠️ **Doküman bayat:** `Treasy.MM.UI\.ai-agent\PROJECT_CONTEXT.md:14` ve `.ai-agent\inventory\shareddependency-yuzey.md:1` **1.0.3** diyor,
> gerçek referans **1.0.4-dev12**. Ayrıca `Treasy.MM.UI\Directory.Build.targets:1-18` 1.0.3'teki bir MSBuild bug'ı için
> (`_TreasyStaticWebAssetsTasksDir`, VS içi build MSB3755/MSB4036) workaround taşıyor.

**Ne sağlıyor:** layout (`Views\Shared\_Layout.cshtml`), auth/authorization/exception/requestContext middleware'leri, `ControllerBase`/`BaseController`, hazır controller'lar (Login, Menu, Calendar, TransactionNote, TransactionDocument, UserLayout, LimitCheck, Discovery.Health, Error), ortak model namespace'leri, Refit client base'leri + otomatik kayıt, DevExtreme helper'ları + DevExtreme DLL/JS/CSS, ViewComponent'ler, `treasy-script` TagHelper, Vite + localization bundler MSBuild target'ları, tüm frontend shell bundle'ı. Yüzey haritası: `.ai-agent\inventory\shareddependency-yuzey.md`.

npm tarafı (`src\Treasy.MM.UI.Web\package.json`): `@treasy/{builders,components,constants,context,enums,helpers,identifiers-and-selectors,notification,translation}`.

---

## E) Yetkilendirme

**Sunucu tarafı — dinamik permission policy (controller/action bazlı):**

| Parça | Dosya |
|---|---|
| Attribute | `Treasy.MicroUI.SharedDependency\Attributes\CustomAuthorizeAttribute.cs` — `: AuthorizeAttribute`; parametresiz ctor `Policy = "Dynamic"`, string ctor hard-coded permission adı |
| Permission adı sabiti | `Constants\Authorization.cs` — `DeafulPermissionName = "Dynamic"` (**sic**, yazım hatası pakette) |
| Policy üretimi | `Policies\AuthorizationPolicyProvider.cs` — bilinmeyen policy adını lazy olarak `PermissionRequirement`'a çevirir |
| Requirement | `Requirements\PermissionRequirement.cs` |
| **Karar noktası** | `Handlers\PermissionHandler.cs` |
| Middleware | `Middlewares\4. AuthorizationMiddleware.cs` — authenticated user'ı `IUserStore`'a yazar |
| Kayıtlar | `Configurations\SharedDependencyConfiguration.cs:129-137` (`IAuthorizationPolicyProvider`, `IUserManager`, `IUserStore`, `IAuthorizationHandler=PermissionHandler`, `Configure<List<PermissionInfo>>(configuration.GetSection("PermissionInfo"))`) |

`PermissionHandler.HandleRequirementAsync` sırası: static file veya authenticated değil → geç; `ApplicationSettings.Current.SkipAuthorization` → geç; policy `"Dynamic"` ise endpoint metadata'sından `ControllerActionDescriptor` alıp `userManager.HasPermissionAsync(controllerName, actionName)`; değilse `HasPermissionAsync(requirement.Name)`. Reddedilirse: AJAX → `FrameworkPermissionException`, değilse `/AccessDenied/Index` redirect.

> 🔴 **Önemli bulgu:** `FallbackPolicy`/`AddAuthorization`/`RequireAuthorization` **tespit edilmedi** (pakette hiç yok) ve
> **`Treasy.MM.UI` içinde tek bir `[CustomAuthorize]`/`[Authorize]`/`HasPermission` kullanımı yok** (Controllers/ + Views/ grep temiz).
> Yani MM Micro UI'de şu an **ekran bazlı sunucu-taraflı yetki zorlaması aktif değil**; erişim kontrolü fiilen menü üzerinden yapılıyor.
> Ayrıca Shell `appsettings.json` içinde `Framework:Application:SkipAuthorization: true`.

**Menü/ekran bazlı yetki (fiilen çalışan mekanizma):** `MenuController.GetMenu` → `GetModuleMenuRequest { ApplicationName, ModuleName, CurrentUserId, SkipAuthorization, SelectedLanguage, RequestedUrl }` → Common API menü tanımlarını **kullanıcıya göre filtreleyerek** döner. Ek olarak koşullu menü filtresi micro UI'de: `DiscoveryController.cs:24-40` + `Business\Helpers\InterbankLoanModuleHelper.cs` (framework parametresine göre IL girdilerini menüden çıkarıyor).

**İstemci tarafı yetki:** `@treasy/authorization` paketi —
- `Treasy.MicroUI.Authorization\wwwroot\permission\index.ts`: `getMakerCheckerPermissions(dataGrid)` grid seçili satırın `StateId/StateMaker/AvailableActions`'ını `/Base/GetMakerCheckerFlowPermissions/`'a sorar → `CanInput/CanModify/CanDelete/CanVerify/CanReject/CanRejectUndo`
- `Treasy.MicroUI.Authorization\wwwroot\authorization\index.ts`: `authScreen(ScreenType)` — `.create-mode-hidden` / `.update-mode-disabled` / `.display-mode-disabled` CSS sınıflarına göre alan gizleme/disable etme
- Sunucu karşılığı: `Interfaces\Flow\IMakerCheckerFlowPermissions.cs`, `Models\Flow\MakerCheckerFlowPermission.cs`, grid tarafında `FlowColumnsWithMakerChecker`

---

## Ana soru: paylaşılan DevExtreme grid ekran bileşeni nereye yazılır?

Karar tablosu (kaynak: `Treasy.MM.UI\.ai-agent\skills\shared-component-porter.md:26-35`):

| Kapsam | Yer | Precedent |
|---|---|---|
| Tek ekrana özel | `Web\wwwroot\js\pages\<topic>\` + o ekranın View'ı | `tawarruq\popups\swift-message.ts` |
| **MM içinde ortak** (birden fazla MM ekranı) | View: `Web\Views\Shared\Components\<Ad>\Default.cshtml` (+`Form/Preview.cshtml`) · ViewComponent: `Web\ViewComponents\<Ad>ViewComponent.cs` · TS: `Web\wwwroot\js\shared\components\<ad>\*.ts` · VM: `Business\ViewModels\Components\<Ad>\` · Model: `Core\Models\<Ad>\` · CSS: `wwwroot\css\shared\components\<ad>.css` | **CashFlow**: `Web\ViewComponents\CashFlowViewComponent.cs` + `Web\Views\Shared\Components\CashFlow\Default.cshtml` (grid `dgCashFlow`+`uniqueKey`, `NamedTemplate`) + `wwwroot\js\shared\components\cashFlow\cashflow.{component,form,preview,context,constants,selectors,utils,endpoints}.ts`; kullanım `Views\InterbankLoan\_Form.cshtml:463` `@await Component.InvokeAsync("CashFlow", new CashFlowComponentVM {...})`. Ayrıca `TransferMessages` aynı desende. |
| **Modüller arası ortak** (FI/FX/Deriv de kullanacak) | **Pakete:** `Treasy.MicroUI.SharedDependency\Views\Shared\Components\<Ad>\Default.cshtml` + `ViewComponents\<Ad>ViewComponent.cs` + gerekiyorsa `Controllers\` + `Models\ComponentModels\<Ad>\`; asset `wwwroot\...` → `_content/Treasy.MicroUI.SharedDependency`; TS ise `Treasy.MicroUI.Components\wwwroot\<ad>\` → npm `@treasy/components`. csproj'a `<AdditionalFiles Include="Views\Shared\Components\<Ad>\Default.cshtml" />` satırı ekleniyor (SharedDependency.csproj:110-116 deseni). **Sürüm bump + Nexus publish gerekli.** | `Payment`, `CustomerAccounts`, `Amortization`, `LimitCheck`, `AdvanceAndStateFilter`, `TransactionNote` |

Skill dokümanı 3. sınıf için kararı **kullanıcıya bırakıyor** (paket sahibiyle koordinasyon vs. MM'e kopyalama), ve `CLAUDE.md` Hard Rule 5: eklemeden önce `shareddependency-yuzey.md`'ye bakıp pakette karşılığı olup olmadığı doğrulanmalı.

**Dikkat edilecek 2 tuzak (dosyalarda kayıtlı):**
- `CashFlow\Default.cshtml:9-10` — bileşen içinde caption'lar `InterbankLoan.formatMessage(...)` ile **ekran bridge'ine hard-code bağlı**; ikinci ekran kullanacaksa bu prefix **parametrelenmeli**.
- `PROJECT_CONTEXT.md:84-89` — bridge'e verilen fonksiyonlar `export function` olmalı (`export const` ok-fonksiyon bundler'da sessizce `undefined` oluyor).
