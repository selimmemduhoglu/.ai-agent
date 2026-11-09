# Analiz #4 — NetTrex.Common Fan-Out Altyapısı (HAM AJAN ÇIKTISI)

**Tarih:** 2026-08-12 · **Taranan repo:** `c:\Users\Treasy-70\source\repos\NetTrex.Common` (bin/obj/.vs/node_modules hariç)

**Aranan cevap:** Yeni generic Manuel Reeskont ekranında WebUI → Common → modüller (MM/FX/Options/Fund/FI/DerivSwp) fan-out'u yapılacak. Common'da bunun hazır bir altyapısı/örneği var mı?

**⚠️ Kritik bulgu:** **Fan-out altyapısı Common'da HAZIR ve ÇALIŞIYOR** — Refit tabanlı, `DailyFlow V2` bunun en olgun örneği.

> Bu dosya ajan çıktısının **hamıdır**, kısaltılmamıştır. Özet/karar → [`../02-mimari-karar.md`](../02-mimari-karar.md)

---

## A) Proje / Solution Yapısı

Solution: `c:\Users\Treasy-70\source\repos\NetTrex.Common\Code\NetTrex.Common.sln`

**Web API dikeyi** (`Code\NetTrex.Web.Api\`):

| Katman | Yol |
|---|---|
| Api (host) | `Code\NetTrex.Web.Api\Web.Api\NetTrex.Common.Web.API\` |
| Business (handler'lar) | `Code\NetTrex.Web.Api\Web.Api\NetTrex.Common.Business\` |
| ResponseRequest (req/res DTO) | `Code\NetTrex.Web.Api\Web.Api\NetTrex.Common.ResponseRequest\` |
| Model (view model / enum) | `Code\NetTrex.Web.Api\Web.Api\NetTrex.Common.Model\` |
| KafkaService | `Code\NetTrex.Web.Api\Web.Api\NetTrex.Common.KafkaService\` |
| **Operations (dış/modül entegrasyon + Refit)** | `Code\NetTrex.Web.Api\Common\NetTrex.Common.Operations\` |
| Repository (EF) | `Code\NetTrex.Web.Api\Common\NetTrex.Common.Repository\` |
| Domain (entity/enum) | `Code\NetTrex.Web.Api\Common\NetTrex.Common.Domain\` |
| Core (constants/helpers/functions) | `Code\NetTrex.Web.Api\Common\NetTrex.Common.Core\` |
| Flow | `Code\NetTrex.Web.Api\Common\NetTrex.Common.Flow\` |

**Batch dikeyi** (`Code\Batch\`): `NetTrex.Common.Batch.WebApi`, `.Business`, `.Business.Models`, `.Core`, `.Integration`
**Gateway**: `Code\Gateway\Gateway.Api\` (Ocelot)
**Testler**: `Code\UnitTest\...`

Not: "Abstractions" isimli ayrı bir katman yok; interface'ler kendi katmanı içinde duruyor (ör. `IDailyFlowOperation` Operations içinde).

---

## B) 🔴 FAN-OUT ALTYAPISI — VAR, TAM OLARAK ARADIĞIMIZ ŞEY

### B.1 Refit interface'leri — `IClientXxxAPI`

Hepsi tek klasörde: `NetTrex.Common\Code\NetTrex.Web.Api\Common\NetTrex.Common.Operations\Refit\ModuleServices\`

| Modül | Dosya | Interface |
|---|---|---|
| MM | `...\ModuleServices\MM\IClientMmAPI.cs:12` | `IClientMmAPI : IClientBaseAPI` |
| FX | `...\ModuleServices\FX\IClientFxAPI.cs:17` | `IClientFxAPI` |
| FI | `...\ModuleServices\FI\IClientFiAPI.cs:16` | `IClientFiAPI` |
| DerivSwp | `...\ModuleServices\Deriv\IClientDerivAPI.cs:11` | `IClientDerivAPI` |
| OptFX | `...\ModuleServices\OptFX\IClientOptFXAPI.cs:11` | `IClientOptFXAPI` |
| **Fund / InvFund** | **tespit edilmedi** | **Refit client'ı YOK** |

Marker interface: `...\Refit\Base\IClientBaseAPI.cs:3` (boş — DI otomatik keşfi için).

MM örneği (`IClientMmAPI.cs:12-28`):
```csharp
public interface IClientMmAPI : IClientBaseAPI
{
    [Post("/ReconTransaction/select")]
    Task<ApiResponse<ReconciliationMMTransactionResponse>> Select([Body] ReconciliationMMTransactionRequest request);

    [Post("/DailyCheck/selectTxnMM")]
    Task<ApiResponse<ValidateTxnMmResponse>> SelectMM();

    [Get("/MmTransaction/select-for-external/{date}")]
    Task<ApiResponse<TransactionSelectForExternalResponse>> SelectForExternal([Query(Format = "yyyy-MM-dd")] DateTime date, [Query] int? stateFilter = null);

    [Post("/DailyFlow/dailyMmFlowSelect")]
    Task<ApiResponse<DailyFlowMmResponse>> DailyFlowMmSelect([Body] DailyFlowMmRequest request);

    [Post("/DailyFlow/dailyMmFlowSelectV2")]
    Task<ApiResponse<DailyFlowV2Response>> DailyMmFlowSelectV2([Body] DailyFlowV2Request request);
}
```

### B.2 DI kaydı + URL key'leri

`NetTrex.Common\Code\NetTrex.Web.Api\Common\NetTrex.Common.Operations\ServiceCollectionExtension.cs:46-50`
```csharp
services.RegisterClientWebApiRefitClients<IClientFxAPI>(configuration.GetValue<string>("FXApi"));
services.RegisterClientWebApiRefitClients<IClientMmAPI>(configuration.GetValue<string>("MMApi"));
services.RegisterClientWebApiRefitClients<IClientFiAPI>(configuration.GetValue<string>("FIApi"));
services.RegisterClientWebApiRefitClients<IClientDerivAPI>(configuration.GetValue<string>("DerivSwpApi"));
services.RegisterClientWebApiRefitClients<IClientOptFXAPI>(configuration.GetValue<string>("OptFXApi"));
```

Kayıt helper'ı: `...\Operations\Refit\RefitExtensions.cs:49-89` — Refit + Newtonsoft camelCase serializer, **`Timeout = 10 dk`**, opsiyonel `ExternalHttpClientHandler` (bearer). `HttpClient` factory Refit'in `AddRefitClient` üzerinden geliyor; ham `IHttpClientFactory` kullanımı Web.API tarafında **tespit edilmedi** (sadece Batch.Integration/Bloomberg'de var: `Code\Batch\NetTrex.Common.Batch.Integration\Bloomberg\Connection\DLRestHttpClient.cs`).

appsettings key adları — `Code\NetTrex.Web.Api\Web.Api\NetTrex.Common.Web.API\appsettings.json:169-173`:
```json
"FXApi": "http://localhost:5014/api",
"MMApi": "http://localhost:5013/api",
"FIApi": "https://localhost:5011/api",
"DerivSwpApi": "http://localhost:5056/api",
"OptFXApi": "http://localhost:5091/api",
```
Aynı key'ler: `Code\Batch\NetTrex.Common.Batch.WebApi\appsettings.json:142-146`, `Code\docker-compose.override.yml:16-25`, `helm\nettrex-common\values-*.yaml:29-32` (**helm'de `OptFXApi` bazı env'lerde eksik**).

### B.3 Gerçek servis örneği — modüle istek atan kod

`NetTrex.Common\Code\NetTrex.Web.Api\Common\NetTrex.Common.Operations\Operations\DailyFlowOperation.cs:15-68`
```csharp
public class DailyFlowOperation: IDailyFlowOperation
{
    private readonly IClientFxAPI clientFxAPIRepository;
    private readonly IClientMmAPI clientMmAPIRepository;
    private readonly IClientFiAPI clientFiAPIRepository;
    private readonly IClientDerivAPI clientDerivAPIRepository;
    private readonly IClientOptFXAPI clientOptFXAPIRepository;

    public async Task<List<DailyFlowModel>> GetMmDailyFlow(DailyFlowMmRequest dailyFlowMmRequest)
    {
        var responseMm = await clientMmAPIRepository.DailyFlowMmSelect(dailyFlowMmRequest).ToContentGeneral();
        return responseMm.DailyFlowMmModelList;
    }

    public async Task<List<DailyFlowModel>> GetDerivDailyFlow(DailyFlowDerivRequest dailyFlowDerivRequest)
    {
        var responseDeriv = await clientDerivAPIRepository.DailyFlow(dailyFlowDerivRequest).ToContentGeneral();
        return responseDeriv.DailyFlowDerivModelList;
    }
    // ... Fx / Fi / OptFx aynı desen
}
```

> 🔴 `.ToContentGeneral()` = `...\Refit\RefitExtensions.cs:30-46` — **hata varsa boş `new T()` dönen "yut" davranışı**
> (hata mesajı kullanıcıya taşınmıyor, satır 39'da yorumlanmış).

**Diğer fan-out yapan operation/handler'lar:**
- `...\Operations\ReconciliationTransactionOperation.cs:25-355` — 5 modül + Fimple; burada hata **yutulmuyor**: `result.Error is not null` → `throw new InvalidOperationException($"MM module API error: ...")` (satır 263-270).
- `Code\NetTrex.Web.Api\Web.Api\NetTrex.Common.Business\External\TransactionSelectForExternalHandler.cs:34-47` — FX/FI/MM paralel.
- `...\Operations\GetSecuritiesFromFIOperation` (Operations klasörü), `IClientFiAPI.SelectSecuritiesRateEngine`.
- Batch tarafı: `Code\Batch\NetTrex.Common.Batch.Business\HangfireJobs\DailyCheck\Validation\Validate*BatchItem.cs` (her modül için bir tane, `IClientMmAPI` vb. inject ediyor).

---

## C) DailyFlow — Common'da VAR, iki nesil (V1 ve V2)

**Endpoint'ler:**

| Endpoint | Controller | Handler |
|---|---|---|
| `POST /api/DailyFlow/dailyFlowSelect` | `...\Controllers\Report\DailyFlow\DailyFlowController.cs:13` | `GetDailyFlowHandler` |
| `POST /api/DailyFlowV2/select` | `...\Controllers\Report\DailyFlow\DailyFlowV2Controller.cs:11` | `GetDailyFlowV2Handler` |
| `POST /api/external-daily-flow/report` | `...\Controllers\Report\DailyFlow\External\ExternalDailyFlowController.cs:14` | `ExternalDailyFlowHandler` |

### C.1 V1 — `if (availableModules.Any(...))` zinciri, sıralı

`Code\NetTrex.Web.Api\Web.Api\NetTrex.Common.Business\Report\DailyFlow\GetDailyFlowHandler.cs:28-93`
```csharp
public async override Task<GetDailyFlowResponse> Handle(GetDailyFlowRequest request, CancellationToken ct)
{
    List<DailyFlowModel> response = [];

    var availableModules = await generalAvailableModulesOperation.GetGeneralAvailableModules();
    if (availableModules.IsNullOrEmpty())
        return new GetDailyFlowResponse { IsSuccess = false, Messages = [new() { Text = "No available modules found." }] };

    if (availableModules.Any(m => m.Module == ModuleConstants.FX))      { var fx = await FXDailyCheck(request);    if (!fx.IsNullOrEmpty()) response.AddRange(fx); }
    if (availableModules.Any(m => m.Module == ModuleConstants.DERIVSWP)){ ... }
    if (availableModules.Any(m => m.Module == ModuleConstants.OPTFX))   { ... }
    if (availableModules.Any(m => m.Module == ModuleConstants.MM))      { var mm = await MMDailyCheck(request);    if (!mm.IsNullOrEmpty()) response.AddRange(mm); }
    if (availableModules.Any(m => m.Module == ModuleConstants.FI))      { ... }

    if (request.MissingWorkday) await CreateResponseWithMissingWorkdaysAsync(response);
    CreateGroupDailyFlow(request.ReportDate.Date, response);
    response.SetSequentialSetId();                       // RowId = 1..n
    return new GetDailyFlowResponse { IsSuccess = true, GetDailyFlowModelList = response };
}
```

### C.2 V2 — ⭐ Strategy + Factory + `Task.WhenAll` (Manuel Reeskont için kopyalanacak desen)

`Code\NetTrex.Web.Api\Common\NetTrex.Common.Operations\Operations\DailyFlowV2\DailyFlowV2Operation.cs:22-86`
```csharp
public async Task<List<DailyFlowV2Model>> GetDailyFlow(DailyFlowV2Request request)
{
    var availableModules = await _generalAvailableModulesOperation.GetGeneralAvailableModules();
    ...
    availableModules = [.. availableModules.Safe()
        .Where(x => x.Module != ModuleConstants.COMMON && x.Module != ModuleConstants.INVFUND)];
    if (availableModules.IsNullOrEmpty()) return [];

    // ortak parametre bağlamı bir kere hazırlanıp tüm modüllere geçiliyor
    var parameterContex = new DailyFlowParameterContext(
        RateABM: rateAbm, FXRateChartId: fXRateChartId, InterestRateChartId: interestRateChartId,
        FxRateDetails: fxRateDetails, CurrencyPairs: currencyPairs);

    var tasks = availableModules
              .Select(module => CreateServiceResponse(request, parameterContex, module))
              .ToList();

    var results = await Task.WhenAll(tasks);          // <-- FAN-OUT

    return results.Where(r => r != null && r.Count > 0).SelectMany(r => r).ToList();  // <-- AGGREGATE
}

private Task<List<DailyFlowV2Model>> CreateServiceResponse(DailyFlowV2Request request,
    DailyFlowParameterContext parameterContext, GetGeneralAvailableModulesValueModel module)
    => dailyFlowStrategyFactory.GetStrategy(module.Module).CreateReportData(request, parameterContext);
```

Factory: `...\DailyFlowV2\Strategy\Factory\DailyFlowStrategyFactory.cs:11-30`
```csharp
public class DailyFlowStrategyFactory(IClientFxAPI clientFxApi, IClientMmAPI clientMMApi,
    IClientFiAPI clientFiApi, IClientDerivAPI clientDerivApi, IClientOptFXAPI clientOptFxApi,
    INumberFunction numberFunction) : IDailyFlowStrategyFactory
{
    public IDailyFlowServiceModuleStrategy GetStrategy(string serviceModule) => serviceModule switch
    {
        ModuleConstants.FX       => new FxDailyFlowServiceModuleStrategy(clientFxApi, numberFunction),
        ModuleConstants.MM       => new MMDailyFlowServiceModuleStrategy(clientMMApi, numberFunction),
        ModuleConstants.FI       => new FiDailyFlowServiceModuleStrategy(clientFiApi, numberFunction),
        ModuleConstants.DERIVSWP => new DerivDailyFlowServiceModuleStrategy(clientDerivApi, numberFunction),
        ModuleConstants.OPTFX    => new OptFxDailyFlowServiceModuleStrategy(clientOptFxApi, numberFunction),
        _                        => new EmptyDailyFlowServiceModuleStrategy(),   // Null-Object
    };
}
```

Strategy sözleşmesi: `...\DailyFlowV2\Strategy\IDailyFlowServiceModuleStrategy.cs:7-11`
→ `Task<List<DailyFlowV2Model>> CreateReportData(DailyFlowV2Request, DailyFlowParameterContext)`

MM strategy (modül çağrısı + post-processing): `...\Strategy\MmDailyFlowServiceModuleStrategy.cs:17-70` — `clientMmApi.DailyMmFlowSelectV2(request).ToContentGeneral()`, ardından Direction filtresi, silinmiş state filtresi, FCY dönüşümü.
Null-object: `...\Strategy\EmptyDailyFlowServiceModuleStrategy.cs:6-12`

> 🔴 **Dikkat:** V2'de tek bir modül patlarsa `Task.WhenAll` **tüm isteği düşürür** — kısmi hata toplama yok (bkz. E).

Ortak DTO'lar (tüm modüllerin paylaştığı sözleşme): `Code\NetTrex.Web.Api\Web.Api\NetTrex.Common.ResponseRequest\Report\DailyFlow\General\DailyFlowV2Request.cs` ve `DailyFlowV2Response.cs`. Modül bazlı V1 DTO'ları: `...\Report\DailyFlow\{Mm,FX,FI,Deriv,OptFX}\{Req,Res}\`.

---

## D) Common'ın WebUI'ye açtığı endpoint grupları

Tümü `Code\NetTrex.Web.Api\Web.Api\NetTrex.Common.Web.API\Controllers\` altında, hepsi `[Route("api/[controller]")]`.

| Grup | Örnek controller'lar |
|---|---|
| **Menü / framework** | `Framework\MenuDefinitionController.cs` (`GET select`, `GET moduleMenu`, `POST selectMenuDefinition/create/update/delete/verify/reject/history/syncRedis`), `Framework\UserController.cs`, `Framework\UserLayoutController.cs` |
| **Parametre / system parameter** | `FrameworkParameter\FrameworkParameterController.cs`, `NetTrex.Common.Business\SystemUserParameter\*` |
| **Referans veri (currency/customer/calendar)** | `Common\Definitions\CurrencyController.cs`, `CurrencyPairController.cs`, `BranchController.cs`, `DateBasisController.cs`, `LocationController.cs`, `CorporateType*`; `Customer\CustomerController.cs`, `Customer\SicController.cs`; `Common\Holiday\Calendar\CalendarController.cs`, `Definitions\HalfWorkingDayController.cs`, `Definitions\CountryController.cs`, `Definitions\MarketController.cs` |
| **Ürün / enstrüman / security** | `Common\Product\ProductInstrumentController.cs`, `Common\Security\SecurityController.cs`, `Common\TxType\TxnTypeController.cs`, `Definitions\EquityDefinitionController.cs` |
| **Oranlar (Rates)** | `Common\Rates\` altında 18 controller: `FXRateController`, `InterestRateController`, `BondPriceController`, `SwapPointController`, `VolatilityRateController`, `InvFundPriceController`, `TlRefIndexController`, `PriceIndexController`, `RateSourceController`, ... |
| **Rate Engine** | `RateEngine\RateEngineController.cs` + 5 yardımcı, `Common\RateEngineDynamicRule\*` |
| **Flow / onay akışı** | `Flow\FlowController.cs`, `FlowSetController`, `FlowStateController`, `FlowTransitionController`, `FlowRequestMapController`, `Common\DynamicRule\FlowDynamicRuleController.cs` |
| **Auth / yetki** | `AuthFacadeController.cs` (`create-token`, `validate-token`, `[AllowAnonymous]`), `Authentication\UserProfileController.cs`, `Authentication\ProfilePermissonController.cs`, `BitMask\BitMaskSetController.cs` |
| **🔴 Cross-module raporlar (fan-out)** | `Report\DailyFlow\DailyFlowController.cs`, `Report\DailyFlow\DailyFlowV2Controller.cs`, `Report\DailyFlow\External\ExternalDailyFlowController.cs`, `Reconciliation\ReconciliationController.cs`, `Report\Monitoring\CountMonitoringReportController.cs`, `Report\UserPermissionReport\*`, `Report\BatchLog\BatchLogController.cs` |
| **Modül bilgisi** | `GeneralAvailableModules\GeneralAvailableModulesController.cs` |
| **Vergi / EOD / diğer** | `Tax\*` (5), `Eod\EodController.cs`, `Portfolio\PortfolioController.cs`, `Quant\QuantController.cs`, `DataSync\DataSyncController.cs`, `HelperController.cs`, `HealtCheckController.cs` |
| **External (Fimple vb.)** | `External\*` (4), `Fimple\RateExternalController.cs`, `Fimple\ExternalSessionManagementController.cs`, `External\TransactionForExternalServiceController.cs` |

İlginç: Common içinde FX modülüne ait controller'lar da var (`Fx\Transaction\FxTransactionController.cs`, `Fx\AccountingEngine\*`) — muhtemelen legacy.

---

## E) Paralel / toplu çağrı + kısmi hata toplama

Repoda **sadece 2 adet `Task.WhenAll`** var:

**1.** `...\Operations\DailyFlowV2\DailyFlowV2Operation.cs:73` — N modüle paralel, **kısmi hata toplama YOK** (bir modül throw ederse hepsi düşer).

**2.** `...\NetTrex.Common.Business\External\TransactionSelectForExternalHandler.cs:34-47`:
```csharp
var fxTransaction = clientFxAPI.SelectForExternal(request.MaturationDate, request.StateFilter).ToContentGeneral();
var fiTransaction = clientFiAPI.SelectForExternal(...).ToContentGeneral();
var mmTransaction = clientMmAPI.SelectForExternal(...).ToContentGeneral();
var transactions = await Task.WhenAll(fxTransaction, fiTransaction, mmTransaction);
foreach (var data in transactions)
    if (data.IsSuccess) response.Data.AddRange(data.Data);   // başarısızları sessizce atlar
```

**Kısmi hata toplamanın en iyi örneği** (sıralı ama modül-başına try/catch + mesaj biriktirme):
`Code\NetTrex.Web.Api\Web.Api\NetTrex.Common.Business\Reconciliation\GetReconTransactionListHandler.cs:68-109`
```csharp
var moduleFetchers = new (string Module, Func<Task<List<ReconciliationTransactionModel>>> Fetch, string EmptyWarning, string ErrorPrefix)[]
{
    (ModuleConstants.FX, () => op.GetReconciliationFxTransaction(new ReconciliationFXTransactionRequest{...}),
        "FX module returned no data for the selected date range.", "FX module reconciliation failed."),
    (ModuleConstants.FI, ...), (ModuleConstants.MM, ...),
    (ModuleConstants.DERIVSWP, ...), (ModuleConstants.OPTFX, ...),
};

foreach (var (module, fetch, emptyWarning, errorPrefix) in moduleFetchers)
{
    if (!availableModules.Any(m => m.Module == module)) continue;
    try
    {
        var list = await fetch();
        if (!list.IsNullOrEmpty()) treasyTransactions.AddRange(list);
    }
    catch (Exception ex)
    {
        handlerResponse.AddError($"{errorPrefix} {ex.Message}");   // kısmi hata -> response.Messages
    }
}
```

> ✅ **Manuel Reeskont için ideal hibrit:** bu handler'ın `AddError`/`AddWarning` disiplini + V2'nin `Task.WhenAll`
> paralelliği (task'ları `try/catch`'e sarıp veya `WhenAll` sonrası `Task.Status` kontrolüyle).

---

## F) Mediator / handler deseni — MM ile aynı

Evet, aynı: `Netix.Core.Handler.BaseHandler<TRequest, TResponse>` + `Netix.Core.Web.Api.Controllers.BaseApiController.Mediator.Send(...)`.

Controller: `...\Controllers\Report\DailyFlow\DailyFlowV2Controller.cs:1-18`
```csharp
[Route("api/[controller]")]
[ApiController]
public class DailyFlowV2Controller : BaseApiController
{
    [HttpPost("select")]
    public async Task<IActionResult> Select(GetDailyFlowV2Request req)
    {
        var response = await Mediator.Send(req);
        return Ok(response);
    }
}
```

Handler: `...\NetTrex.Common.Business\Report\DailyFlow\GetDailyFlowV2Handler.cs:17-62`
```csharp
public class GetDailyFlowV2Handler : BaseHandler<GetDailyFlowV2Request, GetDailyFlowV2Response>
{
    public async override Task<GetDailyFlowV2Response> Handle(GetDailyFlowV2Request request, CancellationToken ct)
    {
        var response = await _dailyFlowOperation.GetDailyFlow(new DailyFlowV2Request { ... });
        if (response.Count == 0)
            return new GetDailyFlowV2Response { IsSuccess = false, Messages = [new() { Text = "No data found." }] };
        ...
        return new GetDailyFlowV2Response { IsSuccess = true, Data = response };
    }
}
```

Yerel base controller (opsiyonel): `...\Controllers\BaseController.cs:8` (`BaseController : BaseApiController`).
Handler assembly'si config'ten: `appsettings.json:16-19` → `"Assemblies": { "Handler": "NetTrex.Common.Business", "Validator": "NetTrex.Common.Business" }`.
Handler doğrulaması: `Startup.cs:129` → `services.ValidateMediatRHandlers();`
`BaseFlowRequest` ailesi (onay akışı için): `...\NetTrex.Common.ResponseRequest\Flow*\Req\Base*Request.cs`, `Flow\FlowAction.cs`; `NetTrex.Common.Flow` projesi + `IFlowEngine`/`ICommonFlowOperation` (`Web.API\Extensions\ServiceCollectionExtension.cs:52-56`).

---

## G) "Modül" kavramı

**1) String sabitler (fan-out'ta fiilen kullanılan)** — `Code\NetTrex.Web.Api\Common\NetTrex.Common.Core\Constants\ModuleConstants.cs:1-11`
```csharp
public static class ModuleConstants
{
    public const string COMMON   = "Common";
    public const string FX       = "FX";
    public const string FI       = "FI";
    public const string MM       = "MM";
    public const string DERIVSWP = "DerivSWP";
    public const string INVFUND  = "InvFund";
    public const string OPTFX    = "OptFX";
}
```

**2) Enum** — `Code\NetTrex.Web.Api\Web.Api\NetTrex.Common.Model\Enums\Eod\BatchModuleType.cs:3-13`
```csharp
public enum BatchModuleType { FI = 1, FX = 2, Common = 3, MM = 4, DerivSWP = 5, InvFund = 6, OptFX = 9, Limit = 10 }
```

**3) Runtime'da aktif modül listesi** — DB/framework parametresinden:
`Code\NetTrex.Web.Api\Common\NetTrex.Common.Operations\GeneralAvailableModules\GeneralAvailableModulesOperation.cs:15-46`
```csharp
var availableModules = await frameworkParameterHelper.GetFrameworkParameterAsync("General:AvailableModules");
if (string.IsNullOrEmpty(availableModules))
    throw new ArgumentException("Parameter is null or empty. Check parameter: 'General:AvailableModules'");
// BatchModuleType enum adlarıyla eşleştirip Id+Module döner; ";" ile ayrılmış liste
```
→ Modül adı string'i `BatchModuleType.ToString()` ile üretiliyor, `ModuleConstants` ile karşılaştırılıyor.
**Yani `ModuleConstants.DERIVSWP = "DerivSWP"` ile enum `DerivSWP` bilinçli olarak birebir aynı yazımda.**

`ProductGroup` enum'u **tespit edilmedi**. Ürün/enstrüman tarafında `DailyFlowProductType` var:
`...\Business\Report\DailyFlow\External\ExternalDailyFlowHandler.cs:155-190` (kod→instrumentId map: spot, frw, swapnear, swapfar, mm, td, vakale, murabaha, passgil, interbank, repo, security, issuebond, irs, ccs, optfx).

---

## H) Authentication / Authorization

**WebUI → Common (gelen istek):**
- Framework tabanlı: `Startup : NetixApiStartup<ApplicationSettings>` (`...\NetTrex.Common.Web.API\Startup.cs:30`) — JWT/authentication pipeline'ı Netix.Core paketinde (bu repoda kaynak yok, `Microsoft.AspNetCore.Authentication.JwtBearer` referansı `NetTrex.Common.Web.API.csproj:20`).
- Authorization altyapısı: `...\Web.API\Extensions\ServiceCollectionExtension.cs:39-42`
```csharp
services.AddTransient<IAuthorizationFacade, AuthorizationFacade>();
services.AddSingleton<IAuthorizationPolicyProvider, AuthorizationPolicyProvider>();
services.AddSingleton<IAuthorizationHandler, HasScopeHandler>();   // Netix.Core.Authorization, scope-based
```
- Token üretimi/doğrulaması: `...\Controllers\AuthFacadeController.cs:13-29` — `POST api/AuthFacade/create-token`, `GET api/AuthFacade/validate-token`, ikisi de `[AllowAnonymous]`.
- CORS tamamen açık: `Startup.cs:44-49` (`AllowAnyOrigin`, `AllowAnyHeader`).
- Controller'larda **açık `[Authorize]` attribute'u tespit edilmedi** — yetki, Netix.Core'un global filter/policy provider'ı + `ProfilePermissonController`/`BitMaskSet` (profil-permission bitmask) üzerinden yürüyor. Kullanıcı kimliği request DTO'sundaki **`CurrentUserId`** alanı ile handler'lara akıyor (yüzlerce yerde `entity.StateMaker = request.CurrentUserId`; alan Netix.Core `BaseRequest`'ten geliyor ve pipeline tarafından dolduruluyor). DB tarafına da geçiyor: `...\NetTrex.Common.Core\Operations\DatabaseOperation.cs:42`.
- `AccessTokenMiddleware` (`...\Web.API\Middleware\AccessTokenMiddleware.cs`) yazılmış ama **devre dışı**: `Startup.cs:39` → `//app.UseAccessTokenMiddleware();` ve içi zaten no-op (satır 28-35 boş `if`).

**Common → modül API'si (giden istek): 🔴 TOKEN TAŞINMIYOR.**
- `RegisterClientWebApiRefitClients<T>(url)` çağrıları `addBearerToken` parametresini **vermiyor** (default `false`), dolayısıyla modül client'larına hiçbir `DelegatingHandler` eklenmiyor — `RefitExtensions.cs:83-86`:
```csharp
if (addBearerToken)
    clientBuilder.AddHttpMessageHandler<ExternalHttpClientHandler>();
```
Sadece `IFimpleApi` (satır 44) `true` geçiyor.
- `ExternalHttpClientHandler` (`...\Refit\ExternalHttpClientHandler.cs:25-57`) yalnızca **Fimple** için: Redis'ten (`RedisParameterConstants.CommonAccessTokenToFimple`) client_credentials token'ı alıp `Authorization: Bearer` ekliyor, 401'de yeniden auth ediyor. Kullanıcı token'ıyla ilgisi yok.
- **Sonuç:** Common→MM/FX/FI/Deriv/OptFX çağrıları **anonim/servis-içi** (cluster-internal, `http://nettrex-mm-web:5041/api`). Kullanıcı kimliği modüle **request body'deki `CurrentUserId` ile** taşınmak zorunda.
- Gateway (`Code\Gateway\Gateway.Api\ocelot.json`) sadece path-based routing yapıyor (`/common/{everything}` → :5050, `/fx/...` → :5014, `/common-batch/...` → :5052); `AuthenticationOptions` **tanımlı değil**, `Program.cs`'de `app.UseAuthorization()` var ama authentication scheme yok.

---

## Ajanın Manuel Reeskont için özet önerisi

1. **Şablon**: `DailyFlow V2` üçlüsünü klonla — `DailyFlowV2Controller` + `GetDailyFlowV2Handler` + `DailyFlowV2Operation` + `Strategy/Factory`.
2. **Refit**: mevcut `IClientMmAPI`/`IClientFxAPI`/... interface'lerine yeni `[Post("/ManualRediscount/...")]` metotları ekle — yeni interface/DI/URL key **gerekmez**, `IClientBaseAPI` sayesinde otomatik kayıtlı.
3. **Eksik modüller**: **Fund/InvFund için Refit client YOK** — `IClientInvFundAPI` + `InvFundApi` config key'i + helm/appsettings girdileri sıfırdan eklenmeli. `OptFXApi` bazı helm values dosyalarında eksik.
4. **Ortak DTO**: `ResponseRequest\Report\DailyFlow\General\DailyFlowV2Request/Response` gibi **tek bir `General` sözleşme** kullan (modül başına ayrı DTO yapan V1 desenini tekrarlama).
5. **Modül seçimi**: `IGeneralAvailableModulesOperation` + `ModuleConstants` (`General:AvailableModules` framework parametresi).
6. **Hata**: `Task.WhenAll` + modül-başına `try/catch` → `response.AddError($"{module} module failed. {ex.Message}")` (Reconciliation handler'ındaki disiplin). `.ToContentGeneral()`'ın hatayı yutmasına **güvenme**; `ReconciliationTransactionOperation`'daki `result.Error is not null → throw` yaklaşımını kullan.
7. **Yetki**: modüle giden çağrıda token yok → **`CurrentUserId`'yi request body'de mutlaka ilet**.
