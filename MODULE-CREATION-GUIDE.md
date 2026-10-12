# MODULE-CREATION-GUIDE.md — Yeni Backend Modülü + Micro UI Oluşturma Rehberi

> **Amaç:** Kullanıcı yeni bir modül ismi verdiğinde ("şu modülü kuruyoruz" dediğinde) bu rehber
> **doğrudan referans alınır** ve scaffold (proje iskeleti) bu rehberdeki kopyala/at tablolarına göre üretilir.
> Business logic (entity, handler, ekran) içerik ayrı adımda — kullanıcı iş dökümanını verince yazılır.
>
> **Kaynak:** `NetTrex.MM` (backend) + `Treasy.MM.UI` (frontend) — tek ve tek başına baz alınan repolar.
> Derinlemesine dosya inceleme ile 2026-10-02'de çıkarıldı.
>
> **Eksik/bulunamadı:** `Treasy.MicroUI.Base` reposundaki `docs/sifirdan-micro-ui-olusturma-rehberi.md`
> (resmi "sıfırdan kurma rehberi") bu makinede klonlu değil. Bulunursa bu dosyayla birleştirilmeli.

---

## 0. İsimlendirme kararı (ilk adım, her şeyden önce)

[[feedback_cross_module_naming]] kuralı burada da geçerli: **nötr, modüle özgü olmayan isim**.
Repo adları şu ikiliyi takip eder:

| Katman | Repo adı deseni | Örnek (mevcut) |
|---|---|---|
| Backend | `NetTrex.<Module>` | `NetTrex.MM` |
| Frontend (Micro UI) | `Treasy.<Module>.UI` | `Treasy.MM.UI` |

Modül adı seçilince **hemen güncellenmesi gereken cross-repo sözleşme noktaları** (bkz. `PROJECT_CONTEXT.md` §2,
§6, §9 — workspace'in genel mimari dosyası):

- `NetTrex.Common.Core/Constants/ModuleConstants.cs` → yeni modül sabiti.
- `NetTrex.Common.Model/Enums/Eod/BatchModuleType.cs` → yeni enum değeri (batch/EOD modül keşfi için).
- `General:AvailableModules` framework parametresi → yeni modül adı eklenir (müşteri bazlı aktif/pasif).
- `NetTrex.Web.UI` tarafında yeni config key + Refit marker (örn. `CollateralApi` / `IClientCollateralAPI`) —
  **isim tutarlılığına güvenme**, dosya adı ≠ tip adı sorunu workspace'te zaten var (⚠️ not).
- Micro UI varsa: `Treasy.Shell`'in `MicroFrontends:Services` + `ReverseProxy:Routes/Clusters` kaydı (route
  prefix = micro `code`, bkz §3.6).

---

## 1. Backend scaffold — `NetTrex.<Module>`

### 1.1 Büyük resim

MM kendi başına framework değil — **ince bir business-logic katmanı**, altında paylaşılan NuGet
framework var: `Netix.Core.*` / `NetTrex.Core.*` (feed: `NetixNuget`/`NetTrexNuget`,
`http://192.168.10.241:8081`). `BaseProgram<,>`, `NetixApiStartup<T>`, `BaseApiController`, generic
`IRepository<T>`/`Repository<T>`, `IUnitOfWork`, `FlowHandler<TReq,TRes>`, `ResponseBase`/`RequestBase`/
`Message`, `DataContext`, `[OracleMapping]` — **hepsi repo dışında**, paket DLL'lerinde. Yeni modül bu
framework'ü tüketen MM-şekilli proje klasörleri yazmaktır, framework kodu kopyalamak değil.

> 🔴 Bu makinede `Netix.Core.*` kaynağı yok (yalnız derlenmiş paket). Base class'ların tam üye imzası
> gerekirse ya paket DLL'i decompile edilmeli ya da `Netix.Core` kaynak reposuna erişim lazım.

### 1.2 Solution/proje iskeleti

```
NetTrex.<Module>/
├── .gitignore, README.md
├── azure-pipelines.yml (+ -batch, -kafka varyantları — hangi host'lar varsa)
├── Database/Migrations/*.sql        el yazımı, yyyymmdd_NN_Aciklama.sql (dotnet ef migrations DEĞİL)
├── helm/nettrex-<module>[-batch][-kafka]/   her host için ayrı chart, values-*.yaml per-env
├── pipelines/templates/              ortak ADO step template'leri (symlink gibi repolar arası paylaşılır)
└── Code/
    ├── NetTrex.<Module>.sln
    ├── NuGet.config                  3 kaynak: nuget.org, NetixNuget, NetTrexNuget
    ├── docker-compose.yml/.override.yml/.dcproj, .dockerignore, launchSettings.json
    ├── .sonarlint/
    ├── Api/
    │   ├── NetTrex.<Module>.Api                 (host — Controllers, Program, Startup)
    │   ├── NetTrex.<Module>.Api.Core             (Exceptions, Resolvers)
    │   ├── NetTrex.<Module>.Api.Model            (internal domain modeller, feature-başına)
    │   ├── NetTrex.<Module>.Api.Mapper           (Mapster IRegister profilleri)
    │   ├── NetTrex.<Module>.Api.ResponseRequest  (IRequest<TResponse> DTO'lar)
    │   └── NetTrex.<Module>.Api.Services         (Handler + FluentValidation Validator — gerçek iş mantığı)
    ├── Data/
    │   ├── NetTrex.<Module>.Data.Domain          (EF entity'ler, Entities/<Area>/)
    │   ├── NetTrex.<Module>.Data.Repository      (DbContext + IEntityTypeConfiguration<T>, + basit *Repository)
    │   ├── NetTrex.<Module>.Data.Abstractions    (I<X>DataManager arayüzleri)
    │   ├── NetTrex.<Module>.Data                 (<X>DataManager implementasyonları — asıl inject edilen katman)
    │   ├── NetTrex.<Module>.Data.Model           (DataManager dönüş DTO'ları, TDM-prefix convention)
    │   ├── NetTrex.<Module>.Data.Mapper
    │   ├── NetTrex.<Module>.Data.Core            (enum, FrameworkParameterConstants)
    │   └── NetTrex.<Module>.Data.ResponseRequest
    ├── Common/            (Api/Batch/Consumer arası paylaşılan: Factory, Calculator, Engine, Accounting-entry
    │                        builder'lar, Validator, Refit client arayüzü, Kafka Producer, Fimple entegrasyonu)
    ├── Accounting/         (OPSİYONEL — modül kendi GL kaydı atıyorsa; aynı 6'lı layer split + AddAccounting())
    ├── Batch/              (OPSİYONEL — EOD/scheduled job varsa; .Api kendi Program/Startup'ı ile ayrı host)
    ├── Consumer/           (OPSİYONEL — Kafka tüketimi varsa; .Api kendi Program/Startup'ı ile ayrı host)
    ├── <ModuleSpecific>/   (MM'de "MarketIntegration" gibi — gerçekten modüle özgü ek varsa aynı şekilde ekle)
    └── UnitTest/           (her source projesine 1 test projesi, <X>.Tests — klasör adı "UnitTest" tekil, MM deseni)
```

Her leaf proje aynı 6'lı katman ayrımını tekrarlar: `.Abstractions / .Model / .Mapper / .ResponseRequest /
.Services` (+ üstte bare host). Proje referans yönü: `*.Services → *.Mapper/*.Abstractions → *.Model`;
`*.Repository → *.Domain`; host → Services + cross-module `AddX()` registration extension'ları.

### 1.3 Composition root deseni (her modülde aynı)

Her katman bir statik `AddX(this IServiceCollection, IConfiguration)` extension export eder
(`AddData`, `AddApiServices`, `AddApiMapper`, `AddAccounting`, `AddMarketIntegration`...). Host'un
`Startup.AfterConfigureService` bunları sırayla çağırır. **Yeni modülde bu isimlendirme ve çağrı sırası
deseni birebir kopyalanır**, içerik boş başlar.

```csharp
// Program.cs — her host'ta (Api/Batch.Api/Consumer.Api) birebir aynı
public class Program : BaseProgram<Program, Startup> { public static void Main(args) => RunApplication(args); }

// Startup.cs
public class Startup(IConfiguration configuration)
    : NetixApiStartup<ApplicationSettings>(configuration, DatabaseProvider.MsSql)
{
    // BeforeConfigureService / AfterConfigureService / BeforeConfigure / AfterConfigure override
    // burada Swagger + CORS + AddData()/AddApiServices()/AddApiMapper()/AddAccounting() çağrıları
}
```

### 1.4 CQRS akışı (her transactional entity için tekrar eden 6 fiil)

```
Controller (ince, [Route("api/<kebab-case>")], Mediator.Send(request) → Ok(response))
  → FlowHandler<TRequest,TResponse> (Handle(), sonunda UnitOfWork.CommitAsync())
    → I<X>DataManager (zengin domain sorguları, generic IRepository<TEntity> üstüne kurulu)
      → IRepository<TEntity> (framework, generic, DI: open-generic kayıt)
```

Her transactional entity tipik olarak **Select / Get / Create / Update / Delete / Verify / Reject / History**
fiil setini tekrarlar (maker-checker workflow). Yeni modülün ilk ekranı için bu seti `InterbankLoan`'dan
klonlayıp isim/alan değiştirmek en hızlı yol.

Dosya adı deseni: `<Feature><Action>Request.cs` / `...Response.cs` / `...Handler.cs` /
`...RequestValidator.cs` / `<Feature>Entity.cs` / `<Feature>Configuration.cs` (EF) /
`I<Feature>DataManager.cs` + `<Feature>DataManager.cs`.

### 1.5 Entity base'leri (yeni modülde yeniden türetilir, MM'den literal kopyalanmaz)

- `FlowEntity` — framework tabanlı, state-flow alanları.
- `MakerCheckerEntity : IMakerCheckerEntity` — `StateId/StateMaker/StateDate` (onay akışı olan entity'lerde).
- `TransactionEntityBase : FlowEntity` — `LogicalReference` + accounting entry collection'ları.
- `<Module>EntityBase` (skaler kolonlar) + `<Module>Entity : <Module>EntityBase` (navigation property'ler) —
  **skaler/ilişki ayrımı** convention'ı her modülde tekrarlanır.
- `[OracleMapping("COLUMN_NAME"[, "SCHEMA"])]` attribute'u (`Netix.Core.Repository.SchemaMapping`) — isme
  rağmen SQL Server'da da kullanılıyor, vendor-agnostic şema-eşleme metadata'sı.

### 1.6 Feature flag deseni — [[feedback_mm_interbankloan_flag]] genellemesi

İki stil var, **yeni modülde nested `feature:` stilini tercih et** (daha temiz):

```csharp
// appsettings.json — tercih edilen stil
"feature": { "<Module>": { "Enable": true } }

// Helper.cs — çağıran kod asla IConfiguration'a direkt dokunmaz
public bool GetIsEnabled<Module>Module()
{ try { return configuration.GetValue("feature:<Module>:Enable", true); } catch { return true; } }
```

Runtime'da (deploy'suz, müşteri bazlı) değişmesi gerekiyorsa ayrıca DB framework-parameter yolu:
`FrameworkParameterConstants.IsEnabled<Module>Module = "<Prefix>.Module:IsEnabled"`.
Bu **iki katman da** (appsettings flag + framework parameter + `General:AvailableModules`) cross-module
ekranlarda kontrol edilmeli — MM'nin kendi notu: "Cross-module bir ekran iki katmanı da kontrol etmeli."

### 1.7 Diğer cross-cutting (config'ten, kod yazılmaz)

| Konu | Mekanizma |
|---|---|
| Logging | Serilog, tamamen `appsettings.json` → `Serilog` section'dan (Console/Seq/Elasticsearch sink) |
| Mediator pipeline | `FeatureFlags:Mediatr:{RequestLogging,Flow,TimingLogging}` config flag'leri |
| Validation | `FeatureFlags:FluentValidation:Enable` + `Assemblies:Validator` (convention-scan hedef assembly — **yeni modülde rename edilmesi zorunlu**) |
| Caching | Redis, `Netix.Core.Caching.StackExchange`, `FeatureFlags:Redis:ConnectionUrl` |
| DI convention-scan | Scrutor: `services.Scan(...).AddClasses(t => t.Name.EndsWith("DataManager")).AsMatchingInterface().WithScopedLifetime()` — DataManager/Repository/Mapster IRegister hepsi bu yolla otomatik kayıt |
| Swagger | `CustomSchemaIds(type => type.ToString())` — **DTO isim çakışmasını önler, atlama** |
| Migration | El yazımı SQL, `Database/Migrations/yyyymmdd_NN_Aciklama.sql`, DBA/pipeline ile uygulanır |

### 1.8 Kopyala / At tablosu — Backend

| Ne | Aksiyon |
|---|---|
| `.sln` solution-folder iskeleti, her leaf'in 6'lı layer split'i | Kopyala, isim değiştir |
| `.csproj` iskeleti + `GlobalUsings.cs` | Kopyala, `NetTrex.MM.*` → `NetTrex.<Module>.*`, paket sürümleri MM'deki gibi proje-başına pinlenir (MM'de merkezi CPM dosyası yok) |
| `Program.cs`/`Startup.cs` iskeleti | Kopyala birebir (lokalizasyon, Swagger server-URL rewrite, paging/STP servis kayıtları dahil — MM'nin tamamı mirror edilir) |
| `appsettings.json` iskeleti (ConnectionStrings/Logging/Assemblies/FeatureFlags/Serilog/ApplicationSettings/Kafka/KeyCloak) | Kopyala, `Assemblies:{Handler,Validator}` + connection string + sırlar **yeniden üretilir** (MM'deki gerçek görünen Seq/SendGrid/Keycloak sırları commit'lenmiş — hijyen sorunu, yeni repoya taşıma) |
| `NuGet.config`, `.dockerignore`, `docker-compose*`, `Dockerfile`, `launchSettings.json` | Kopyala |
| `helm/` (3 chart, `templates/` seti) | Kopyala, sadece gerçekten şipilenen host sayısı kadar chart |
| `azure-pipelines*.yml` + `pipelines/templates/` | Kopyala, `image_name`/`dockerfile_path`/`repo_name` değiştir |
| DI convention-scan extension'ları (`AddData`, `AddApiMapper`, vb.) | Şekli kopyala, boş başlat |
| CQRS 6-fiil template (Select/Get/Create/Update/Delete/Verify/Reject/History) | `InterbankLoan` setini klonla, alan listesini güt |
| `FlowEntity`/`MakerCheckerEntity`/`<Module>EntityBase` deseni | Yeniden türet (literal kopya değil) |

**MM'ye özgü (iş mantığı), kesinlikle taşınmaz:**
`InterbankLoan`/`Tawarruq`/`ProductDefinition`/`TransferMessage`/`ManualRediscount`/`Reconciliation`/
`ExternalStp`/`DailyCheck`/`Eod` feature klasörleri · `MarketIntegration*` projeleri (modül kendi piyasa
verisi/rate feed'i gerektirmiyorsa) · MM'ye özgü accounting entry tipleri
(`Opening/Maturation/Revaluation/Fee/Payment/Tawarruq/...`) · `TxnMm*`/`TxnLoan*` entity+DbSet+EfConfiguration ·
migration SQL içerikleri · helm `values-*.yaml` içerikleri.

---

## 2. Frontend scaffold — `Treasy.<Module>.UI`

### 2.1 Büyük resim — bu bir SPA değil

**Webpack Module Federation / React / Angular yok.** Server-rendered **ASP.NET Core MVC (.NET 10)** + Razor
+ DevExtreme widget'ları, sayfa-başına **TypeScript** dosyaları **Vite 8** ile bundle edilir (webpack değil).
"Micro UI" burada: her domain kendi bağımsız deploy edilen ASP.NET Core sitesi, shell/gateway'e HTTP
discovery endpoint'i üzerinden kayıt olur — client-side module federation değil, server-side composition +
reverse-proxy (`Treasy.Shell`, YARP, bkz `PROJECT_CONTEXT.md` §4).

### 2.2 Proje iskeleti

```
Treasy.<Module>.UI/
├── CLAUDE.md
├── Directory.Build.targets          SharedDependency paketleme bug'ı için MSBuild fix — kopyala
├── NuGet.config
├── Treasy.<Module>.UI.sln + .slnx   İKİSİ birden, elle senkron tutulur
├── azure-pipelines.yml
├── helm/nettrex-microui-<module>/
├── pipelines/templates/
└── src/
    ├── Treasy.<Module>.UI.Core/       Models, Enums, Constants — sade, business logic yok
    ├── Treasy.<Module>.UI.Business/   Refit API interface'leri, ViewModel'ler, AutoMapper profilleri, DI
    ├── Treasy.<Module>.UI.Web/        Controller, View, wwwroot (TS/CSS/localization)
    ├── docker-compose.yaml/.override.yaml/-ui.dcproj
```

Bağımlılık yönü: `Web → Business → Core` (transitive). Framework/tooling: `.NET 10`, `Nullable`+
`ImplicitUsings` açık, paketler **private `@treasy/*` npm** (Nexus `192.168.10.241:8081/repository/treasy-npm`)
+ NuGet `Treasy.MicroUI.SharedDependency` (layout, middleware, base controller, DevExtreme grid helper'ları —
**tüm generic altyapı burada, repo içinde değil**). ESLint/Prettier/`.editorconfig` **yok** — sadece
`tsc --noEmit` tip kontrolü.

### 2.3 `Program.cs` — kasıtlı olarak minimal

```csharp
var builder = WebApplication.CreateBuilder(args).AddMicroUiWebHost();
builder.Services.AddMicroUiServices(builder.Configuration);
var app = builder.Build();
app.UseMicroUiPipeline();
app.Run();
```

Tüm generic wiring (auth middleware, layout, static asset, Vite/localization MSBuild target) paket içinde —
bu dosyaya **modüle özgü hiçbir kod eklenmez**.

### 2.4 Modül kaydı — Discovery endpoint (webpack federation'ın yerine geçen mekanizma)

`Controllers/BaseControllers/DiscoveryController.cs`, route `/Discovery/Info`, `[AllowAnonymous]`:

```csharp
{ microCode = "<Module>UI", displayName = "<Module> UI", routes = ["/"],
  menu = [ {title, path}, ... ],   // business/flag'e göre koşullu eklenebilir (InterbankLoanModuleHelper örneği)
  healthEndpoint = "/Health", version = "1.0.0" }
```

Shell bunu poll eder, menü + health'i buradan öğrenir. `appsettings.json` →
`Framework.Application.{ModuleName,WebName}` modülü framework/auth katmanına tanıtır.
**Yeni modülde `Treasy.Shell`'in `MicroFrontends:Services` + `ReverseProxy:Routes/Clusters` kaydı ayrıca
gerekir** (cross-repo, Shell tarafında yapılır).

### 2.5 Refit client pattern — yeni backend'in kendi marker'ı gerekir

Her topic bir Refit interface, paket-sağlı bir marker interface'i extend eder (marker → config key eşleşmesi,
dosya adı ≠ tip adı — doğrulamadan güvenme):

```csharp
[Post("/<topic>/create")] Task<ApiResponse<XCreateResponse>> Create([Body] XCreateRequest request);
// : IClientMmApi (config key "MMApi") gibi, yeni modül için IClient<Module>Api + "<Module>Api" key'i gerekir
```

🔴 **Açık nokta:** `IClient<Module>Api` marker'ı `Treasy.MicroUI.SharedDependency` paketinde tanımlı olmalı
— bu paket bu makinede kaynak olarak yok, muhtemelen ayrı bir repo/pipeline. Yeni modül için bu pakete yeni
marker eklenmesi **cross-team koordinasyon** gerektirir, salt bu repo içinde çözülmez.

### 2.6 Diğer base pattern'ler (paketten gelir, repoda yok — yeniden yazma)

- Grid: `Html.DevExtreme().DataGrid<T>().ToTreasyDataGrid("dgId").TreasyDataSource(...).TreasyEditing(...)` —
  [[feedback_datagrid_fixed_height]] burada da geçerli: **pager/height ekran bazında override edilmez**,
  `ToTreasyDataGrid()` içine gömülü default. Hiçbir MM ekranı override etmiyor — yeni modülde de etme.
- `GridCrudModel` — Key/PopupTitle/ControllerName/LoadAction/.../VerifyAction/RejectAction/HistoryAction,
  maker-checker CRUD sözleşmesi.
- Hazır ViewComponent'ler (tekrar yazma): `AdvanceAndStateFilter`, `TransactionNote`, `CustomerAccounts`,
  `Payment`, `Amortization`.
- `_ViewStart.cshtml` → `_LayoutProxy` (gerçek layout paket içinde, bu sadece IDE IntelliSense shim'i) —
  **verbatim kopyala**.
- View body `<ShellContent>`/`<ShellStyles>`/`<ShellScripts>` tag helper'ları içinde.
- AutoMapper (Mapster değil — backend'den kasıtlı sapma, ekip tercihi, körü körüne kopyalama).

### 2.7 TS/Vite konvansiyonu ve bilinen tuzaklar

- Entry-point otomatik keşif: `<treasy-script src="~/js/pages/.../index.ts">` tag helper'ı Vite MSBuild
  target'ı tarafından taranır — manuel entry listesi yok.
- Sayfa-başına: `index.ts` + `bridges/index.ts` (Razor `onclick` için `window.<Topic>` namespace expose) +
  `popups/` + `constraints/` + `services/` + `utils/`.
- 🔴 **Tuzak:** bridge'den expose edilen fonksiyonlar `export function` olmalı, `export const =>` **olmaz**
  — rolldown bundler function declaration'ı hoist eder, const arrow'u etmez → sessiz `undefined` hatası.
- Localization: `wwwroot/localization/<group>/<file>-{tr,en}.json`, grouping kuralı dosya adının **son `-`
  sonrası**na göre (`mm-transaction-tr.json` → grup `tr`). Proje lokalizasyonu key çakışmasında **paket/shell
  lokalizasyonunu override eder** — yanlış key adı sessizce shell'i bozabilir, dikkat.
- Key convention: `<ekranKısaltma>-<context>-<field>`.
- `npm install` `dotnet build` sırasında otomatik (`TreasyViteAutoInstall=true`); Vite dev server portu
  hem `.csproj` (`TreasyViteDevServerPort`) hem `appsettings.Development.json` içinde **eşleşmeli**.

### 2.8 Kopyala / At tablosu — Frontend

| Ne | Aksiyon |
|---|---|
| `.sln`+`.slnx`, `NuGet.config`, `Directory.Build.targets`, `.gitignore`, `.dockerignore` | Kopyala |
| `azure-pipelines.yml`, `pipelines/templates/` | Kopyala, isim/path değişkenleri değiştir |
| `helm/nettrex-microui-<module>/` | Kopyala, chart adı/values rename |
| `docker-compose*`, `Dockerfile` | Kopyala, servis adı + `.csproj` dosya adları rename |
| `<Module>.UI.Core.csproj` + boş `Constants/Enums/Models` | Kopyala iskelet, model klasörleri boş |
| `<Module>.UI.Business.csproj` + `ServiceRegistration.cs` + boş `Mappings/DefaultMappings.cs` | Kopyala, AutoMapper profile hedefini değiştir |
| `<Module>.UI.Web.csproj` (MSBuild props + yeni benzersiz `TreasyViteDevServerPort`) | Kopyala |
| `Program.cs` | **Verbatim** kopyala |
| `Controllers/BaseControllers/{BaseController,HealthController}.cs` | Verbatim kopyala |
| `Controllers/BaseControllers/DiscoveryController.cs` | **Yeniden yaz** (`microCode`/`displayName`/`menu`) |
| `Views/_ViewStart.cshtml`, `_ViewImports.cshtml`, `Views/Shared/_LayoutProxy.cshtml` | Verbatim kopyala |
| `wwwroot/js/treasy-globals.d.ts`, `wwwroot/js/types/` | Verbatim kopyala |
| `package.json` (aynı `@treasy/*` bağımlılık seti), `tsconfig.json`, `vitest.config.ts`, `.npmrc` | Kopyala, `name` rename |
| `Properties/launchSettings.json` | Kopyala, port çifti değiştir (kullanılmayan bir `51xx`/`61xx` çifti seç), backend env-var bloğunu modülün çağırdığı API'lere indir |
| `appsettings.json`/`.Development.json` | Kopyala, `Framework.Application.{ApplicationName,WebName,ModuleName}` + yeni secret/AES key + backend URL listesi |

**MM'ye özgü, kesinlikle taşınmaz:**
`BaseControllers/` dışındaki tüm `Controllers/*Controller.cs` · tüm `Views/<Topic>/` · tüm
`wwwroot/js/pages/<topic>/`, `css/pages/<topic>/`, `localization/{pages,components}/<topic>/` ·
`wwwroot/js/shared/*` MM-özel helper'lar (cashFlow, transfer-messages, treasury-flow-state) ·
`Business/{ViewModels,Services/ApiReferences}/*`, `Core/Models/*` tüm topic klasörleri ·
`InterbankLoanModuleHelper.cs` · MM'ye özgü `ViewComponents/*`.

---

## 3. İş akışı — bu rehber nasıl kullanılacak

1. Kullanıcı modül adını verir (örn. "Collateral") + iş dökümanını `.ai-agent/feature-research/<Module>-Feature/`
   altına koyar.
2. Bu rehber referans alınır: backend (§1) + frontend (§2) scaffold'ı **kopyala/at tablolarına göre** üretilir
   — henüz business logic yok, sadece iskelet (sln, csproj, Program/Startup, appsettings, Discovery
   controller, boş katmanlar).
3. Kullanıcı business logic'i anlatır (entity alanları, ekranlar, akış) → CQRS 6-fiil template + vertical-slice
   ekran deseni buna göre doldurulur.
4. Cross-repo sözleşme noktaları (§0 tablosu) güncellenir: `ModuleConstants`, `BatchModuleType`,
   `AvailableModules`, Web.UI Refit marker, Shell discovery kaydı.

---

## 4. Açık sorular / takip gereken noktalar

| Soru | Not |
|---|---|
| `Treasy.MicroUI.Base/docs/sifirdan-micro-ui-olusturma-rehberi.md` | Bu makinede yok (path `Treasy-70` makinesine işaret ediyor). Bulunursa bu rehberle karşılaştır/birleştir — resmi kaynak muhtemelen bu. |
| `Netix.Core.*`/`Treasy.MicroUI.SharedDependency` kaynağı | Bu makinede yok, yalnız derlenmiş paket. Base class tam imzası gerekirse decompile veya kaynak repo erişimi lazım. |
| Yeni backend için yeni Refit marker (`IClient<Module>Api`) | `SharedDependency` paketine eklenmesi gerekiyor — bu repo içinde çözülemez, paket sahibiyle koordinasyon. |
| `appsettings.json`'daki görünür sırlar (Seq/SendGrid/Keycloak) | MM'de commit'li görünüyor — yeni repoya **taşınmaz**, secret-manager'dan üretilir. Hijyen sorunu, modül scaffolding'in dışında ama flag edildi. |
