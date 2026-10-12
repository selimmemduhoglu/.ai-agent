# Mimari Karar — Manuel Reeskont Base Component

> Bu dosya: base component **nereye** yazılır, modül yönlendirmesi **nasıl** yapılır, MM'in payı ne.
> Doküman analizi → [`01-dokuman-analizi.md`](01-dokuman-analizi.md) · MM envanteri → [`03-mm-backend-envanteri.md`](03-mm-backend-envanteri.md)
>
> **Durum:** 🟡 **Öneri** — kullanıcı onayı bekliyor (CLAUDE.md Hard Rule 2: mimari değişiklikte plan → onay).
> **Son Güncelleme:** 2026-08-12

---

## 1. Ölçülen Gerçekler (araştırma çıktısı — varsayım değil)

### 1.1 `NetTrex.Web.UI` (monolit)

| Konu | Bulgu |
|------|-------|
| Ortak (Common) yapı | ✅ Var — `Controllers/Common/`, `Views/Common/`, `Views/Shared/Components/`. `Areas/` **yok** |
| **Çok-modüllü tek ekran precedent'i** | ✅ **İKİ canlı örnek:**<br>`Controllers/Eod/Eod/EodController.cs` — dropdown'dan `BatchModuleType`, her action'da `switch` + `GetRefitClient<IEodMmApi>()` / `<IEodFxApi>()` / `<IEodOptFXApi>()`. Resolver satır **364**: `public T GetRefitClient<T>() where T : IClientBaseAPI => serviceProvider.GetService<T>();`<br>`Controllers/CashFlow/CashFlowController.cs` — `request.Module` (`ModuleType` enum) → `switch` + `GetService<IInterbankLoanCashFlowAPI>()`. Şu an yalnız `ModuleType.LN` dolu, diğerleri **açık iskelet** |
| Refit modül marker'ları | ✅ 19 adet, hepsi **yerel** (`Code/Web/UI/Trex.WebUI/Services/Abstract/`): `IClientFxAPI`, **`IClientMMAPI`** (çift M!), `IClientFiAPI`, **`IClientFundsAPI`** (Funds), `IClientDerivSWPAPI`, `IClientWarrantAPI`, `IClientCommonAPI`, `IClientAccountingAPI`, **`IClientOptFXApi`** (dosya adı `IClientOptionsFXApi.cs`!), `IClientLimitApi` + Batch muadilleri |
| Base URL çözümü | Kayıt: `Trex.FrameworkCommon/Api/RefitExtensions.cs:78` → `RegisterClientWebApiRefitClients<T>(services, apiUrl)` — AppDomain taraması, `T`'den türeyen her interface'e `BaseAddress = apiUrl` + `RefitHttpMessageHandler`.<br>Config: `Startup.cs:58-75`, root-level key'ler (`MMApi`, `FXApi`, `FIApi`, `FundsApi`, `OptFXApi`, `DerivSwpApi`, `WarrantApi`, `CommonApi`, `AccountingApi`, `LimitApi` + Batch'ler), değerler `appsettings.json:91-109` |
| 🔴 **Runtime base-URL resolver** | ❌ **TESPİT EDİLMEDİ.** Named HttpClient yok, `IHttpClientFactory` doğrudan kullanılmıyor. Bir Refit interface **compile-time'da** hangi marker'dan türediyse o modüle bağlı |
| Paylaşılan Razor bileşen deseni | ✅ ViewComponent + `Views/Shared/Components/<Ad>/Default.cshtml` + `wwwroot/js/shared/components/<ad>/`. TagHelper deseni **tespit edilmedi** |
| **DevExtreme grid içeren paylaşılan bileşen** | ✅ **CashFlow** — `Views/Shared/Components/CashFlow/Default.cshtml:12,53` `Html.DevExtreme().DataGrid<...>()`; ViewComponent + modül-switch'li controller + 8 dosyalı JS modülü |
| **Modül parametreli paylaşılan bileşen** | ✅ **LimitCheck** — `ViewComponents/LimitCheck/LimitCheckViewComponent.cs`, `model.Module` string'i ile framework parametresinden modül bazlı aktiflik okuyor. 8 view kullanıyor (FX Spot/Forward/Swap/PmSwap/Pm + MM Transaction + IL) |
| Yetkilendirme | Convention-based: `BaseController` üstünde `[CustomAuthorize]` (policy `"Dynamic"`) → `PermissionHandler.cs:43-66` → `userManager.HasPermissionAsync(controllerName, actionName)`. **Permission = ControllerAdı/ActionAdı** |
| 🔴 Yetki sonucu | **Tek generic controller = tüm modüller AYNI permission'ı paylaşır.** Doküman §9 "3 ekran ayrı ayrı yetkilendirilir" istiyor → **3 ayrı controller** (veya action bazında hardcoded permission) gerekli |
| Mevcut FX ekranının JS'i | ⚠️ **Ayrı dosyada DEĐİL** — `Views/ManuelReescont/Index.cshtml` içinde satır **127-298 inline `<script>`** (dosya toplam 297 satır). CSS ayrı: `wwwroot/css/pages/reconciliation/manuel-revaluation.css`. Localization: `wwwroot/js/localization/pages/manuel-reescont/manuel-reescont-{tr,en}.json` |
| Mevcut FX ekranı tutarsızlığı | Namespace `Trex.WebUI.Controllers.FX.Report`, klasör `Controllers/ManuelReescont/`, view `Views/ManuelReescont/` — üçü uyuşmuyor |

### 1.2 MicroUI dünyası

| Konu | Bulgu |
|------|-------|
| `Treasy.Shell` | Host/shell. **iframe değil, MVC area değil** — **YARP reverse proxy + HTML response rewrite** (`MicroFrontendHtmlRewriteMiddleware.cs`). Port `5206` |
| Micro UI kaydı | `Treasy.Shell/appsettings.json` **iki yerde**: `MicroFrontends:Services` (`code`, `baseAddress`, `discoveryPath: /Discovery/Info`, `healthPath`) + `ReverseProxy:Routes/Clusters`. **Route prefix = `code`** (`/mm/MmTransaction/Index` → micro'ya `/MmTransaction/Index`) |
| Menü | Discovery'deki `menu` **render edilmiyor**; gerçek menü `SharedDependency/Controllers/MenuController.cs` → **Common API**'den (`GetModuleMenu`), kullanıcıya göre filtreli |
| **`Treasy.MicroUI.SharedDependency`** | ✅ **Tek C# paketi, RCL** — `Microsoft.NET.Sdk.Razor` + `<AddRazorSupportForMvc>true</AddRazorSupportForMvc>` (csproj:7). Sürüm **1.0.4-dev12**. View'lar assembly'ye gömülü + `.AddApplicationPart(...)` (`SharedDependencyConfiguration.cs:103`). Static asset kökü `~/_content/Treasy.MicroUI.SharedDependency` |
| 🔑 **Paketten TAM EKRAN çıkabiliyor mu?** | ✅ **EVET, precedent var:** `Controllers/LoginController.cs:47` → `return View("Pages/Login/Index")` + `Views/Shared/Pages/Login/Index.cshtml`. Aynısı `ErrorController`. |
| 🔑 **Paketten DevExtreme grid'li ORTAK BİLEŞEN çıkabiliyor mu?** | ✅ **EVET, 10 tane var:** `Views/Shared/Components/{AdvanceAndStateFilter,Amortization,AmortizationConfiguration,CurrenciesLookup,CustomerAccounts,LimitCheck,Payment,TransactionDocument,TransactionNote,TransferMessages}/Default.cshtml` + 4 ViewComponent + `Controllers/Limit/LimitCheckController.cs` |
| TS dağıtımı | 12 npm paketi (`@treasy/components`, `helpers`, `builders`, `constants`, `context`, `enums`, `flow`, `formatters`, `notification`, `translation`, `authorization`, `identifiers-and-selectors`) → Nexus `192.168.10.241:8081/repository/treasy-npm/` |
| Script bağlama | `TagHelpers/TreasyScriptTagHelper.cs` → `<treasy-script src="..." bundle-mode="...">`, Vite dev server / bundle / `_content/` ayrımını yapıyor |
| DevExtreme | **22.2.6**, DLL'ler pakette bundle (`Libraries/DevExtreme/DevExtreme.AspNet.{Core,Data}.dll`). **`Html.DevExtreme()` MVC fluent wrapper** kullanılıyor, saf jQuery değil |
| MM.UI Refit | `IMmTransactionApi : IClientMmApi` → paket AppDomain taramasıyla otomatik kayıt (`RefitExtensions.cs:77-124`). MM.UI'de hiç elle `AddRefitClient` yok (1 istisna: `IClientLimitApi` boşluğu) |
| MM.UI yetki | 🔴 **`Treasy.MM.UI` içinde tek bir `[CustomAuthorize]`/`[Authorize]` YOK** — ekran bazlı sunucu yetkisi fiilen **aktif değil**, erişim menü üzerinden. Shell'de `SkipAuthorization: true` |
| Paylaşılan bileşen karar tablosu | `Treasy.MM.UI/.ai-agent/skills/shared-component-porter.md:26-35` — tek ekran / MM içinde ortak / **modüller arası ortak → pakete** |

### 1.3 Modüllerin bugünkü UI evi

| Modül | Web.UI monolit | MicroUI |
|-------|:--------------:|:-------:|
| **MM** (+InterbankLoan) | ✅ (silinmedi — MM.UI ADR-002) | ✅ `Treasy.MM.UI` (5104) |
| **OptionsFX** | ✅ | ✅ `Treasy.OptionsFX.UI` |
| **FX** | ✅ | ❌ |
| **FI** | ✅ | ❌ |
| **Fund** | ✅ | ❌ |
| **DerivSWP** | ✅ | ❌ |
| **Warrant** | ✅ | ❌ |

> 🔑 **Belirleyici gerçek:** Dokümanın istediği **Treasury ekranı** = FX Transaction + MM/Loan + Options + Derivative.
> Bunların **4'ünden 2'si (FX, Derivative) yalnız Web.UI'de var.** Security (Bond/Repo) ve Investment (FON/Hisse/Warrant)
> ekranlarının modülleri de **tamamen** Web.UI'de.

---

## 2. Kritik Mimari Çatışma — Dokümanın `baseUrl` Varsayımı

Doküman §5.5 + §6.2: kolon config'te **`baseUrl`** var, "UI çağıracağı servis adresini bu bilgiden çözer ve sabit endpoint yolunu ekler".

Bu iki şeyden birini ima eder:

| | Yaklaşım | Sonuç |
|---|----------|-------|
| **(a)** | **Tarayıcı ürün servisini doğrudan çağırır** (`fetch("https://.../mm/manuel-reeskont/...")`) | 🔴 Ne Web.UI'de ne MicroUI'de böyle bir desen **yok**. CORS + tarayıcıya token verme + gateway/route gerekir. Mevcut tüm ekranlar: tarayıcı → UI controller → (Refit, sunucu tarafı) → modül API |
| **(b)** | **UI controller `baseUrl`'ü sunucu tarafında kullanır** | 🔴 **Runtime base-URL resolver TESPİT EDİLMEDİ** (§1.1). Refit client'lar compile-time'da marker interface üzerinden bağlı; `baseUrl`'ü runtime'da değiştirecek altyapı yok |

### ✅ Karar önerisi — ADR-MR-001: `baseUrl` yerine `moduleCode`

`baseUrl`'ü kolon config'inden **çıkar**, yerine **`moduleCode`** koy (`MM`, `FX`, `OPTFX`, `FUNDS`, `FI`, `DERIVSWP`, `WARRANT`).
UI controller bu kodu **zaten kayıtlı** Refit client'a çözer — `EodController.GetRefitClient<T>()` deseniyle birebir.

```csharp
// Controllers/Common/ManualRediscount/  — EodController.cs:364 deseni
private IManualRediscountApi ResolveApi(ManualRediscountModule module) => module switch
{
    ManualRediscountModule.MM       => serviceProvider.GetRequiredService<IManualRediscountMmApi>(),
    ManualRediscountModule.FX       => serviceProvider.GetRequiredService<IManualRediscountFxApi>(),
    ManualRediscountModule.OptFX    => serviceProvider.GetRequiredService<IManualRediscountOptFxApi>(),
    ManualRediscountModule.Funds    => serviceProvider.GetRequiredService<IManualRediscountFundsApi>(),
    ManualRediscountModule.FI       => serviceProvider.GetRequiredService<IManualRediscountFiApi>(),
    _ => throw new NotSupportedException($"Module {module} not registered for Manual Rediscount.")
};
```

Her modül için **aynı imzayı** taşıyan ince bir Refit interface:

```csharp
public interface IManualRediscountApi          // ortak sözleşme (marker DEĞİL, imza sahibi)
{
    [Post("/manuel-reeskont/eligible-transactions")]
    Task<ApiResponse<EligibleTransactionsResponse>> EligibleTransactions([Body] EligibleTransactionsRequest request);

    [Post("/manuel-reeskont/executions")]
    Task<ApiResponse<ExecutionsResponse>> Executions([Body] ExecutionsRequest request);
}

public interface IManualRediscountMmApi    : IManualRediscountApi, IClientMMAPI   { }   // BaseAddress = MMApi
public interface IManualRediscountFxApi    : IManualRediscountApi, IClientFxAPI   { }   // BaseAddress = FXApi
public interface IManualRediscountOptFxApi : IManualRediscountApi, IClientOptFXApi { }
public interface IManualRediscountFundsApi : IManualRediscountApi, IClientFundsAPI { }
public interface IManualRediscountFiApi    : IManualRediscountApi, IClientFiAPI    { }
```

**Kazanç:** CORS yok · token tarayıcıya çıkmıyor · `RefitHttpMessageHandler` (auth/context header) zinciri korunuyor ·
appsettings'te **hiçbir yeni key gerekmiyor** (tüm modül URL'leri zaten kayıtlı) · yeni modül = **1 interface + 1 enum değeri**.

**Bedel:** Yeni modül eklemek UI'de küçük bir kod değişikliği gerektiriyor (dokümanın "UI'de hiç değişiklik olmaz" hedefinden
sapma). Ama `baseUrl` yaklaşımı da **UI deploy'u gerektiriyordu** (config UI'de duruyor — analiz C-15). Yani sapma marjinal.

> ⚠️ **Bu, iş birimine bildirilmesi gereken bir sözleşme değişikliği** (`baseUrl` → `moduleCode`).

---

## 3. Base Component Nereye Yazılır — 4 Seçenek

### Seçenek A — `NetTrex.Web.UI` Common shared component ⭐ **ÖNERİLEN (Faz 1)**

```
Code/Web/UI/Trex.WebUI/
├── Controllers/Common/ManualRediscount/
│   ├── TreasuryRediscountController.cs      ← ProductGroup = Treasury   (permission: TreasuryRediscount/*)
│   ├── SecurityRediscountController.cs      ← ProductGroup = Security
│   └── InvestmentRediscountController.cs    ← ProductGroup = Investment
├── Views/Shared/Components/ManualRediscount/
│   ├── Default.cshtml                       ← filtre çubuğu + DevExtreme grid + toolbar
│   ├── _GenerateConfirm.cshtml              ← onay penceresi
│   ├── _RegenerateConfirm.cshtml            ← durum bazlı özet
│   └── _ReverseValueDate.cshtml             ← T+0 / T+1 seçimi
├── ViewComponents/ManualRediscount/ManualRediscountViewComponent.cs   ← ProductGroup parametresi alır
├── Services/Abstract/ManualRediscount/IManualRediscount*Api.cs       ← modül başına 1 ince interface
├── Models/Shared/Components/ManualRediscount/                        ← sözleşme modelleri
├── wwwroot/js/shared/components/manual-rediscount/
│   ├── manual-rediscount.component.js       ← grid + filtre + toplu seçim
│   ├── manual-rediscount.actions.js         ← Generate / Regenerate / onay akışı
│   ├── manual-rediscount.columns.js         ← kolon config yükleyici + uygulayıcı
│   ├── manual-rediscount.constants.js
│   └── manual-rediscount.endpoints.js
├── wwwroot/js/config/manual-rediscount/     ← ÜRÜN KOLON KONFİGÜRASYONLARI (JSON)
└── wwwroot/js/localization/pages/manual-rediscount/manual-rediscount-{tr,en}.json
```

| ✅ Artı | ❌ Eksi |
|---------|---------|
| Dokümanın teknoloji varsayımı **birebir bu**: ASP.NET MVC + jQuery + DevExtreme, `Html.DevExtreme()` fluent | Monolit — gidiş yönü MicroUI |
| **Hedef modüllerin 5'i (FX, FI, Funds, DerivSWP, Warrant) YALNIZ burada var** | Yeni ekran monolite ekleniyor |
| Tüm modül API base URL'leri **zaten kayıtlı** — yeni altyapı **sıfır** | Web.UI'nin genel teknik borcu (inline script, legacy JS klasörleri) |
| Modül-switch resolver **kanıtlanmış** (`EodController`, `CashFlowController`) | |
| DevExtreme grid'li paylaşılan bileşen precedent'i var (**CashFlow**) | |
| Modül parametreli bileşen precedent'i var (**LimitCheck**) | |
| **3 ekran = 3 controller = 3 ayrı permission** → doküman §9 doğal olarak karşılanır | |
| **FI ve Fund ekipleri kendi ekranlarını buradan tüketebilir** (ikisi de Web.UI'de) — kullanıcının hedefi | |

### Seçenek B — Yeni özel Micro UI (`Treasy.ManualRediscount.UI`)

Shell'e `code: "reeskont"` olarak kaydedilir, `/reeskont/Treasury` · `/reeskont/Security` · `/reeskont/Investment`.

| ✅ Artı | ❌ Eksi |
|---------|---------|
| MicroUI yönüne uygun; bağımsız deploy | 🔴 **Yeni repo + pipeline + helm + Shell config + 7 modül API'si için yeni appsettings key'leri** |
| Cross-module ekran hiçbir modülün MicroUI'sine ait değil — temiz sahiplik | 🔴 Bir cross-module MicroUI, micro-frontend izolasyonunu zaten kırıyor (7 modül API'sine bağımlı) |
| 3 controller = 3 permission | 🔴 MM.UI'de yetki fiilen aktif değil (§1.2) → yeni MicroUI'de de aynı boşluk |
| | 🔴 **FI/Fund ekipleri bunu tüketemez** — onlar Web.UI'de çalışıyor |
| | Solo geliştirici için **en yüksek maliyet** |

### Seçenek C — `Treasy.MicroUI.SharedDependency` paketine, her modül kendi ekranını host eder

| ❌ **Reddedildi** — sebep |
|---|
| Ekran **ProductGroup** kapsamlı, **modül** kapsamlı değil. Treasury ekranı FX + MM + Options + Derivative'i **birlikte** gösteriyor. MM.UI Treasury ekranını host ederse MM.UI'nin FX/Options/Derivative API'lerine gitmesi gerekir → MM.UI cross-module UI'ye dönüşür, micro-frontend izolasyonu çöker |
| Yine de: bileşenin **yeniden kullanılabilir parçaları** (grid + filtre + onay akışı) ileride pakete taşınabilir — bkz. Seçenek D |

### Seçenek D — Hibrit: Web.UI'de yaz, sözleşmeyi sınır tut, sonra pakete çıkar ⭐⭐ **ÖNERİLEN BÜTÜN**

1. **Şimdi (Faz 1):** Seçenek A — `NetTrex.Web.UI` Common shared component. Treasury ekranı çalışır hale gelir.
2. **Sınır disiplini:** UI katmanı **ince** tutulur; tüm iş kuralı ürün servisinde (dokümanın kendi kuralı §4.5).
   JS bileşeni **DOM'a gömülü iş mantığı içermez** → ileride TS'e port edilebilir.
3. **Sonra (Faz 2+):** İhtiyaç doğduğunda bileşen ikiye ayrılır:
   - Razor + ViewComponent → `Treasy.MicroUI.SharedDependency/Views/Shared/Components/ManualRediscount/`
     (precedent: paketten **tam ekran** çıkıyor — `Pages/Login/Index`; ve **10 adet grid'li ortak bileşen** var)
   - JS → TS → `Treasy.MicroUI.Components/wwwroot/manual-rediscount/` → npm `@treasy/components`
4. Dokümanın §6.3'teki **çift entegrasyon** (`Html.DevExtreme().ManuelReeskont()` + `ManuelReeskont.init({...})`)
   zaten iki host'u öngörüyor — bu yol dokümanla **çelişmiyor**.

> **Neden bu:** Backend (MM'in 2 endpoint'i) her iki dünyada **birebir aynı**. Yani UI kararı MM işini
> **bloke etmiyor**. En riskli/en pahalı kısım (yeni MicroUI altyapısı) ihtiyaç kanıtlanana kadar **ertelenir**.

---

## 4. ADR Adayları

| # | Karar | Gerekçe | Durum |
|---|-------|---------|-------|
| **ADR-MR-001** | Kolon config'te `baseUrl` **yerine** `moduleCode`; UI controller `IServiceProvider` ile kayıtlı Refit client'a çözer | Runtime base-URL resolver **yok** (ölçüldü); CORS/token/handler zinciri korunur; yeni appsettings key'i gerekmez; `EodController` precedent'i | 🟡 Öneri |
| **ADR-MR-002** | Base component **`NetTrex.Web.UI` Common shared component** olarak yazılır (ViewComponent + shared JS), pakete çıkarma **ertelenir** | Hedef modüllerin 5'i yalnız Web.UI'de; doküman teknoloji varsayımı bu; FI/Fund ekipleri buradan tüketebilir; sıfır yeni altyapı | 🟡 Öneri |
| **ADR-MR-003** | **3 ayrı controller** (Treasury / Security / Investment), tek ViewComponent | Permission = ControllerAdı/ActionAdı → doküman §9 "3 ekran ayrı yetkilendirilir" ancak böyle karşılanır | 🟡 Öneri |
| **ADR-MR-004** | Tarayıcı **ürün servisine doğrudan gitmez**; her istek UI controller üzerinden proxy'lenir | Mevcut tüm ekranların deseni; auth handler zinciri; CORS yok | 🟡 Öneri |
| **ADR-MR-005** | MM tarafında **yeni hesap motoru yazılmaz** — mevcut `IRevaluationAccountingService` + `IRevaluationReverseAccountingService` tetiklenir | Altyapı hazır (envanter § 8.1); batch ile manuel ekran **aynı** kod yolunu paylaşır (FX'teki desen) | 🟡 Öneri |
| **ADR-MR-006** | `StatusDescription` backend'den **serbest metin olarak değil**, `StatusCode` + `ReasonCode` olarak döner; metni UI localize eder | MicroUI'lerde localization JSON var; backend'den Türkçe metin çoklu dili kırar (analiz C-13) | 🟡 Öneri — **iş birimi onayı gerek** |
| **ADR-MR-007** | `executions` **satır bazlı izole** çalışır: her satır kendi transaction scope'unda, hata satırı diğerlerini düşürmez, `Failed[]`'a düşer | FX'in "`IsSuccess` her zaman true, hatalar yutulur" hatası tekrarlanmasın | 🟡 Öneri |

---

## 5. MM'in Payı — UI kararından bağımsız

| # | İş | Bağımlılık |
|---|----|-----------|
| 1 | `POST /manuel-reeskont/eligible-transactions` — durum türetmeli + sayfalamalı yeni sorgu | Sözleşme dondurulmalı (`04-sozlesme.md`) |
| 2 | `POST /manuel-reeskont/executions` — `Operation` × satır durumu dallanması | Sözleşme + C-08 (birleşik request modeli) |
| 3 | Durum türetme mantığı (`accEntryMain` + `TxnMMDailyCalculation`, "en son aktif hareket") | M-08 |
| 4 | SubProduct eşlemesi (Murabaha/Wakala) | M-02 |
| 5 | `ProductSourceType` ile MM ↔ IL dallanması + `GetIsEnabledInterbankLoanModule()` guard'ı | M-04 |
| 6 | Çift-tıklama / eşzamanlılık koruması (Fimple idempotent değil) | C-11 |
| 7 | Audit (kim/ne zaman/hangi aksiyon/hangi valör) | C-19 |
| 8 | Ters fiş valörü T+0/T+1 → `RevaluationReverseAccountingServiceContext.LogicalDate` | C-08 |
| 9 | Fimple round kuralları (CLAUDE.md Hard Rule 11) | M-05 |

> 🔑 **MM işi hemen başlayabilir** — sözleşme dondurulduğu an. UI'nin nereye yazıldığı MM'i etkilemiyor.

---

## 6. Riskler

| # | Risk | Etki | Azaltma |
|---|------|------|---------|
| R-01 | Doküman **iki tasarım nesli** taşıyor (C-01) — yanlış nesle göre kod yazılırsa baştan yapılır | 🔴 Yüksek | İş birimine sor, sözleşmeyi **kod öncesi dondur** (`04-sozlesme.md`) |
| R-02 | `executions` senkron mu asenkron mu belirsiz (C-07, asenkron bölümü dokümandan düşmüş) | 🔴 Yüksek | 248 kayıt × senkron Fimple = timeout. Karar kod mimarisini **kökten** değiştirir |
| R-03 | Select All (tüm veri kümesi) ↔ `TransactionIds` listesi çelişkisi (C-10) | 🟠 Orta | Sözleşmeye `SelectAll` + filtre alanları eklenmeli |
| R-04 | `baseUrl` sözleşme değişikliği iş birimi tarafından kabul edilmezse | 🟠 Orta | Alternatif: Web.UI'ye runtime base-URL resolver yaz (yeni altyapı, ADR gerekir) |
| R-05 | Diğer modüllerde (FX hariç) ters fiş deseni yoksa | 🟠 Orta | FX ✅ · MM ✅ (doğrulandı). Options/Fund/FI/Deriv **doğrulanmadı** — o ekipler kendi servisini yazacak, bizim sorunumuz değil ama sözleşme tutarlılığı riski |
| R-06 | Kolon config UI'de → yeni ürün eklemek **UI deploy'u** gerektiriyor (C-15) | 🟡 Düşük | Config'i Common API'den servis etme opsiyonu; Faz 1'de kabul edilebilir |
| R-07 | Tek generic controller yapılırsa 3 ekran aynı permission'ı paylaşır | 🟡 Düşük | ADR-MR-003 (3 controller) ile çözülüyor |
| R-08 | Mevcut FX ekranı **silinecek mi, yaşayacak mı?** İkisi paralel çalışırsa aynı transaction'a iki yerden fiş kesilebilir | 🟠 Orta | Karar gerekli (→ yeni soru C-20) |
