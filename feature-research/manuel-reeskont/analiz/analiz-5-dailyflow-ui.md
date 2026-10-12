# Analiz #5 — DailyFlow UI Tarafı (HAM AJAN ÇIKTISI)

**Tarih:** 2026-08-12 · **Taranan repo:** `c:\Users\Treasy-70\source\repos\NetTrex.Web.UI` (bin/obj/.vs/node_modules/dist/bundles hariç)

**Aranan cevap (hipotez testi):** DailyFlow, WebUI'den **Common API'ye** gidiyor ve fan-out (modüllere dağıtım) **Common backend'de** mi yapılıyor — UI controller'da modül switch'i var mı yok mu?

**⚠️ Kritik bulgu:** **HİPOTEZ DOĞRULANDI.** UI'de tek Refit interface (`: IClientCommonAPI`), tek endpoint, **modül switch'i YOK**. Fan-out gerçekten Common'da.

**Önemli ön not:** Ekran **iki sürümlü**. `DailyFlow` (V1, eski) ve `DailyFlowV2` (yeni, aktif — Advance Filter komponenti + FCY kolonları + strategy pattern backend). **Şablon olarak V2 alınmalı.**

> Bu dosya ajan çıktısının **hamıdır**, kısaltılmamıştır. Özet/karar → [`../02-mimari-karar.md`](../02-mimari-karar.md)

---

## A) Tam dosya zinciri

### DailyFlowV2 (güncel — şablon adayı)

| Katman | Yol |
|---|---|
| UI Controller | `NetTrex.Web.UI\Code\Web\UI\Trex.WebUI\Controllers\Report\DailyFlow\DailyFlowV2Controller.cs` |
| View (ana) | `...\Trex.WebUI\Views\Report\DailyFlowV2\Index.cshtml` |
| View (filtre) | `...\Views\Report\DailyFlowV2\Templates\_AdvanceFilterTemplate.cshtml` |
| View (dropdown grid) | `...\Views\Report\DailyFlowV2\Templates\_InstrumentTemplate.cshtml` |
| View (dropdown grid) | `...\Views\Report\DailyFlowV2\Templates\_CurrencyTemplate.cshtml` |
| View (dropdown grid) | `...\Views\Report\DailyFlowV2\Templates\_FCurrencyTemplate.cshtml` |
| Refit interface | `...\Trex.WebUI\Services\Report\DailyFlow\IDailyFlowV2Api.cs` |
| ViewModel | `...\Trex.WebUI\Models\Report\DailyFlow\GetDailyFlowV2ViewModel.cs` |
| Request | `...\Code\Web\Common\Trex.Web.Business.Models\Models\Report\DailyFlow\Req\GetDailyFlowV2Request.cs` |
| Response | `...\Trex.Web.Business.Models\Models\Report\DailyFlow\Res\GetDailyFlowV2Response.cs` |
| Grid Model | `...\Trex.Web.Business.Models\Models\Report\DailyFlow\Model\DailyFlowV2Model.cs` |
| Enum (ürün tipi) | `...\Trex.Web.Business.Models\Enums\ProductType.cs` |
| JS | `...\Trex.WebUI\wwwroot\js\pages\daily-flow\daily-flow-v2.js` |
| CSS | `...\Trex.WebUI\wwwroot\css\pages\reports\daily-flow-v2.css` |
| Localization TR | `...\Trex.WebUI\wwwroot\js\localization\pages\reports\daily-flow-v2-tr.json` |
| Localization EN | `...\Trex.WebUI\wwwroot\js\localization\pages\reports\daily-flow-v2-en.json` |
| Refit host kaydı | `...\Trex.WebUI\Startup.cs:69` → `RegisterClientWebApiRefitClients<IClientCommonAPI>(Configuration["CommonApi"])` |

### DailyFlow V1 (eski)

Controller `...\Controllers\Report\DailyFlow\DailyFlowController.cs`, View `...\Views\Report\DailyFlow\Index.cshtml` (tek dosya, inline `@section Scripts` — ayrı js dosyası **yok**), Refit `...\Services\Report\DailyFlow\IGetDailyFlowApi.cs`, ViewModel `...\Models\Report\DailyFlow\GetDailyFlowViewModel.cs` (namespace `Trex.WebUI.Models.DailyFlow` — klasörle uyumsuz), CSS `...\css\pages\reports\daily-flow.css`, loc `daily-flow-tr.json` / `daily-flow-en.json`.

### Common backend (fan-out'un gerçekleştiği yer — `NetTrex.Common` reposu)

- `NetTrex.Common\Code\NetTrex.Web.Api\Web.Api\NetTrex.Common.Web.API\Controllers\Report\DailyFlow\DailyFlowV2Controller.cs`
- `...\NetTrex.Common.Business\Report\DailyFlow\GetDailyFlowV2Handler.cs`
- `...\NetTrex.Common.Operations\Operations\DailyFlowV2\DailyFlowV2Operation.cs`
- `...\DailyFlowV2\Strategy\Factory\DailyFlowStrategyFactory.cs`
- `...\DailyFlowV2\Strategy\{Fx,Mm,Fi,Deriv,OptFx,Empty}DailyFlowServiceModuleStrategy.cs`

---

## B) 🔴 Refit interface + marker + switch var mı? — **HİPOTEZ DOĞRULANDI**

**Marker: `IClientCommonAPI` — tek uç, TEK endpoint. UI controller'da modül switch'i YOK.**

`...\Trex.WebUI\Services\Report\DailyFlow\IDailyFlowV2Api.cs:9-13`:
```csharp
public interface IDailyFlowV2Api  : IClientCommonAPI
{
    [Post("/DailyFlowV2/select")]
    Task<ApiResponse<GetDailyFlowV2Response>> Select([Body] GetDailyFlowV2Request request);
}
```

`DailyFlowV2Controller.cs:48-57` — `Load` içinde tek çağrı, hiçbir modül dallanması yok:
```csharp
public async Task<IActionResult> Load(GetDailyFlowV2Request request)
{
    if (request.IsFirstLoad)
        return Json(new List<DailyFlowV2Model>());

    var response = await _newDailyFlowApi.Select(request).ToContentExternal();
    return response.IsFailed() ? Json(response) : Json(response.Data.Data);
}
```

**Fan-out gerçekten Common backend'de** — `NetTrex.Common\...\DailyFlowV2\Strategy\Factory\DailyFlowStrategyFactory.cs:18-29`:
```csharp
public IDailyFlowServiceModuleStrategy GetStrategy(string serviceModule)
{
    return serviceModule switch
    {
        ModuleConstants.FX      => new FxDailyFlowServiceModuleStrategy(clientFxApi, numberFunction),
        ModuleConstants.MM      => new MMDailyFlowServiceModuleStrategy(clientMMApi, numberFunction),
        ModuleConstants.FI      => new FiDailyFlowServiceModuleStrategy(clientFiApi, numberFunction),
        ModuleConstants.DERIVSWP=> new DerivDailyFlowServiceModuleStrategy(clientDerivApi, numberFunction),
        ModuleConstants.OPTFX   => new OptFxDailyFlowServiceModuleStrategy(clientOptFxApi, numberFunction),
        _ => new EmptyDailyFlowServiceModuleStrategy(),
    };
}
```

`DailyFlowV2Operation.cs:69-80` — paralel fan-out + merge:
```csharp
var tasks = availableModules.Select(module => CreateServiceResponse(request, parameterContex, module)).ToList();
var results = await Task.WhenAll(tasks);
var finalResult = results.Where(r => r != null && r.Count > 0).SelectMany(r => r).ToList();
```

**Tek istisna (switch'e benzeyen ama farklı):** `DailyFlowV2Controller.cs:59-96` `GetAvailableModules()` — burada UI tarafında bir `Dictionary<string, List<ProductType>>` var, ama bu **veri çağrısı için değil, sadece dropdown'ı doldurmak için** modül→ProductType eşlemesi. `IFrameworkParameterHelper.GetFrameworkParameter("General:AvailableModules")` ile lokal parametreden okunuyor (V1'de aynı iş `IFrameworkParameterApi.GetGeneralAvailableModules()` ile HTTP üzerinden yapılıyor — `DailyFlowController.cs:61`).

> 🔴 **Fund/InvFund modülü DailyFlow'da YOK** — `DailyFlowV2Operation.cs:41` `COMMON` ve `INVFUND` modüllerini açıkça dışlıyor.
> Yeni Manuel Reeskont ekranı Fund kapsayacaksa bu şablonda karşılığı yok.

---

## C) Modül/ürün seçimi UI'de nasıl

**V2: çoklu seçim yapan `DropDownBox` + içine gömülü `DataGrid` (`SelectionMode.Multiple`).** Modül değil, **ProductType (instrument) bazlı** seçim.

- `_AdvanceFilterTemplate.cshtml:52-60`: `DataField("Instruments")`, `ID("sbInstrument")`, `Placeholder(global-all)`, `DataSource → Controller("DailyFlowV2").LoadAction("GetAvailableModules")`, `ContentTemplate(new TemplateName("InstrumentGrid"))`
- `_InstrumentTemplate.cshtml:15-23`: `Selection(s => s.Mode(SelectionMode.Multiple))` + `OnSelectionChanged` → `component.option("value", args.selectedRowKeys)` → seçilen `Value`'lar array olarak toplanıyor
- `Index.cshtml:32`: `Instruments = JSHelper.ValueFromDropDownBox("#sbInstrument")`

**Taşıyan enum:** `Trex.Web.Business.Models.Enums.ProductType` (`...\Trex.Web.Business.Models\Enums\ProductType.cs`).
Backend karşılığı: `NetTrex.Common.Model.Enums.DailyFlowProductType` (`NetTrex.Common\...\NetTrex.Common.Model\Enums\DailyFlowProductType.cs`).
**`ModuleType` diye bir enum bu ekranda kullanılmıyor** — modül adları `ModuleConstants.FX/MM/FI/DERIVSWP/OptFX` string sabitleri.

> ⚠️ **Enum drift:** WebUI `ProductType` — `IssueBond=3, Syndication=9, Securitization=10, PostFinancing=11, OptionsFx=1070`;
> Common `DailyFlowProductType` — `IssueBond` FI grubunda, `OptionFx` (**farklı yazım**), Syndication/Securitization/PostFinancing **yok**.
> V2 controller MM listesinde `IssueBond, Syndication, Securitization, PostFinancing` var (`DailyFlowV2Controller.cs:73`), V1'de yok (`DailyFlowController.cs:72`).

**Request'teki alan:** `Instruments` (string, **virgülle birleşik**). Common tarafta `DailyFlowV2Operation.cs:36-39` virgülü noktalı virgüle çeviriyor: `request.Instruments.Replace(",", ";")`. Aynı şey `Currencies` için de yapılıyor (satır 31-34).

**V1'de tek seçim:** `SelectBox` (`#ProductInstrument`) → `InstrumentId` (`int?`) — `Views\Report\DailyFlow\Index.cshtml:31-42, 96`.

---

## D) Grid kurulumu — `Html.DevExtreme().DataGrid()`, kolonlar SABİT, server-side paging YOK

`Views\Report\DailyFlowV2\Index.cshtml:18-37` + `329-339`:
```csharp
@(Html.DevExtreme()
    .DataGrid<DailyFlowV2Model>()
    .ToNetixDataGrid<DailyFlowV2Model>("dgDailyFlowV2")
    .NetixOnContentReady("onDataGridContentReady")
    .NetixOnCellPrepared("onDataGridCellPrepared")
    .NetixDataSource(Model.GridModel, loadParams: new
    {
        IsFirstLoad = JSHelper.IsFirstLoad(),
        Status      = JSHelper.ValueFromDxSelectBox("#sbStatus"),
        EndDate     = JSHelper.ValueFromDxDateBox("#sbEndDate"),
        StartDate   = JSHelper.ValueFromDxDateBox("#sbStartDate"),
        FcyCcy      = JSHelper.ValueFromDropDownBox("#sbFcyCcy"),
        Currencies  = JSHelper.ValueFromDropDownBox("#sbCurrencies"),
        RateCalculationDate = JSHelper.ValueFromDxDateBox("#sbRateCalculationDate"),
        Instruments = JSHelper.ValueFromDropDownBox("#sbInstrument"),
        MissingWorkday = JSHelper.ValueFromDxCheckBox("#sbAddMissingDays"),
        Direction   = JSHelper.ValueFromDxSelectBox("#sbDirection"),
        OnlyVerifiedInterimPaymentRecords = JSHelper.ValueFromDxCheckBox("#sbVerifiedInterimPaymentRecord"),
        ExcludeFcyColumns = JSHelper.ValueFromDxCheckBox("#sbIncludeFcyColumns")
    })
    // ... 23 sabit kolon (satır 38-218)
    .Paging(paging => paging.PageSize(50))
    .Pager(pager => { pager.Visible(true); pager.ShowPageSizeSelector(true);
                      pager.AllowedPageSizes(new List<int> { 50, 100, 500 }); pager.ShowInfo(true); })
    .OnExporting("onExportingSetFileName")
    .Height("65vh"))
```

**Kolonlar sabit** — 23 kolon `AddFor(x => ...)` ile compile-time tanımlı (satır 38-218). Modüle göre kolon eklenip çıkmıyor.
**Dinamiklik sadece visibility düzeyinde:** FCY kolonları (`BuyAmountFcy`, `SellAmountFcy`, `TotalAmountFcy`, `FcyCcy`) checkbox ile client-side gizleniyor — `daily-flow-v2.js:276-283`:
```js
function toggleFCurrencyColumns(){
    const dataGrid = $(DG__DAILY_FLOW_NEW).dxDataGrid("instance");
    if(!dataGrid) return;
    dataGrid.columnOption("BuyAmountFcy", "visible", isFCurrencyColumnsIncluded);
    dataGrid.columnOption("SellAmountFcy", "visible", isFCurrencyColumnsIncluded);
    dataGrid.columnOption("TotalAmountFcy", "visible", isFCurrencyColumnsIncluded);
    dataGrid.columnOption("FcyCcy", "visible", isFCurrencyColumnsIncluded);
}
```

**🔴 Server-side paging YOK.** Kanıt:
1. `DailyFlowV2Controller.cs:56` → `Json(response.Data.Data)` — komple `List<DailyFlowV2Model>` dönüyor, `totalCount`/`skip`/`take` yok
2. `GetDailyFlowV2Request` içinde paging alanı **hiç yok** (bkz. E)
3. `NetixDataSource` → `Framework.WebUI\Extensions\GridBuilderExtensions.cs:282-289` `d.Mvc().Controller(...).LoadAction(...).LoadParams(...)` — `LoadMode` belirtilmemiş; grid `Paging/Pager` client-side çalışıyor
4. `Grouping` + `GroupPanel` + `Summary.GroupItems` (satır 246-327) client-side gruplama/toplam gerektiriyor — server paging ile uyumsuz

**Grid ek özellikler:** `NetixEditing` + popup edit form (satır 219-244, salt-görüntüleme amaçlı), `GroupDateValue` GroupIndex(0) + `Ccy` GroupIndex(1) çift gruplama, `BaseGroupCellTemplate` (`daily-flow-v2.js:18-20`), custom toolbar checkbox'ları ("Expand All", "Colorize Columns" — `daily-flow-v2.js:77-109`), ExcelJS export (`daily-flow-v2.js:22-64`).

---

## E) Request/Response modelleri — alan alan

### `GetDailyFlowV2Request` (WebUI: `...\Models\Report\DailyFlow\Req\GetDailyFlowV2Request.cs`)
`: BaseMakerCheckerRequest<GetDailyFlowV2Response>`

| Alan | Tip | Rol |
|---|---|---|
| `RateCalculationDate` | `DateTime` | FX kur hesap tarihi (zorunlu, ≤ bugün) |
| `Status` | `int` | 1=Only Active, 2=Include Unverified, 3=Only Unverified |
| **`Instruments`** | **`string`** | **Modül/ürün filtresi — virgülle birleşik ProductType id listesi** |
| `StartDate` | `DateTime` | akış başlangıç (zorunlu) |
| `EndDate` | `DateTime` | akış bitiş (opsiyonel, min-date → Common'da `null`'a çevriliyor) |
| `IsFirstLoad` | `bool` | ilk yüklemede boş liste döndürme guard'ı |
| `MissingWorkday` | `bool` | eksik iş günlerini ekle |
| `Currencies` | `string` | virgülle birleşik para birimi listesi |
| `FcyCcy` | `string` | FCY dönüşüm para birimi |
| `OnlyVerifiedInterimPaymentRecords` | `bool` | |
| `Direction` | `int` | 0=All, 1=Input, 2=Output |

**Paging alanı yok. Sorting alanı yok. Dictionary/dynamic yok.**

### Common tarafı ikizi
- `NetTrex.Common\...\Report\DailyFlow\GetDailyFlow\Req\GetDailyFlowV2Request.cs` — birebir aynı (MediatR request, `BaseIdentityRequest<>`)
- `NetTrex.Common\...\Report\DailyFlow\General\DailyFlowV2Request.cs` — **modüllere gönderilen ortak DTO**; tek fark `EndDate` burada `DateTime?`. Yani modül API'lerine giden request UI'nin gönderdiğiyle aynı şekilli — **modüle özel alan yok**.
- Modül bazlı sarmalayıcılar (kullanılan yalnız V1'de): `...\Report\DailyFlow\{FX,Mm,FI,Deriv,OptFX}\Req\DailyFlow*Request.cs`

### `GetDailyFlowV2Response`
```csharp
public class GetDailyFlowV2Response : ResponseBase { public List<DailyFlowV2Model> Data { get; set; } }
```
`totalCount` yok → server paging yok teyidi.

### `DailyFlowV2Model` (44 alan, `: BaseMakerCheckerModel`)
`Id`, `RowId` (grid key), `LogicalReference`, `BusinessKey`, `MarketCode`, `CountryCode`, `InstrumentId`, `CustomerId`, `BuyAmount`, `BuyAmountFcy`, `SellAmount`, `SellAmountFcy`, `FcyRate`, `FcyCcy`, `DealRateGross`, `DealRateNet`, `ImpliedRate`, `TradeDate`, `ValueDate`, `FlowDate`, `MaturityDate`, `GroupDate` (string), `GroupDateValue` (DateTime), `SettleDate`, `BuyCcy`, `SellCcy`, `Instructions`, `InputDate`, `TxnTypeCode`, `CcyPair`, `Ccy`, `Customer` (`CustomerItem`), `TotalAmount`, `TotalAmountFcy`, `ProductInstrumentName`, `MissingWorkday`, `Nominal?` + `BaseMakerCheckerModel`'den `StateId`/`StateIdName`/`StateMaker`/`StateDate`.

**🔑 Modüle özel alanlar nasıl taşınıyor: TAMAMEN SABİT/DÜZLEŞTİRİLMİŞ ALANLAR.** Dictionary, `dynamic`, `JObject`, extra-properties bag **yok**. Tüm modüller (FX/MM/FI/DerivSwp/OptFx) aynı `DailyFlowV2Model` şemasına dolduruluyor; her modülün strategy'si kendi alanlarını bu ortak şemaya map ediyor ve boş bıraktığı alanlar default kalıyor. Örnek: `MmDailyFlowServiceModuleStrategy.cs:41-66` — `BuyAmount != 0` ise `SellAmount`/`SellAmountFcy` sıfırlanıyor, tersi de geçerli; FCY hesabı burada yapılıyor. Ürün ayrımı sadece `ProductInstrumentName` / `InstrumentId` / `TxnTypeCode` string/int alanlarıyla, **kolon şemasıyla değil**.

> **Manuel Reeskont için tasarım kararı:** DailyFlow "en geniş ortak şema" (LCD — lowest common denominator) yaklaşımını
> kullanıyor. Modüle özel alan sayısı fazlaysa bu desen **şişer**; ya aynı şekilde union-model yapılır ya da DailyFlow'dan
> sapılıp **extension bag** eklenir. (Doküman `Data: Dictionary<string,object>` istiyor → sapma gerekli.)

---

## F) ViewComponent mi, tek ekran mı?

**Tek ekran — ViewComponent DEĞİL, başka hiçbir ekran onu kullanmıyor.**

Kanıt: `Code/` altında `DailyFlow` string'i (kendi klasörleri + localization hariç) sadece `daily-flow-v2.js` içinde geçiyor. `DailyFlowV2Model`/`IDailyFlowV2Api` tek tüketicili. `ViewComponent` sınıfı, partial paylaşımı veya başka view'dan `Component.InvokeAsync("DailyFlow...")` çağrısı **tespit edilmedi**.

**Ama tersi doğru: DailyFlowV2, paylaşılan bir ViewComponent'i TÜKETİYOR** — `Index.cshtml:10-17`:
```csharp
Component.InvokeAsync(ComponentConstants.AdvanceAndStateFilterComponentName,
    new AdvanceAndStateFilterComponentModel {
        ShowTitle = false, DataGridId = "dgDailyFlowV2",
        AdvanceFilterTemplateName = "AdvanceFilters", StateFilterTemplateName = "CustomStateFilter",
        TitleKey = "dgDailyFlowV2-AdvancedFilterTitle" })
```
Sabit: `...\Trex.WebUI\Models\Constants\ComponentConstants.cs:5`. Bu komponent repoda **çok yaygın** (ProfilePermission, UserProfile, Branch, Chart, Currency, SymbolMap, DynamicRule, TransactionLimit, … **20+ view**). **Manuel Reeskont için doğrudan yeniden kullanılabilir.**

V2'nin 4 partial'ı (`Templates\_*.cshtml`) yalnız kendi `Index.cshtml`'inden `<partial name="../Report/DailyFlowV2/Templates/...">` ile çağrılıyor (satır 341-344) — paylaşımlı değil, **kopyalanabilir kalıp**.

---

## G) Aynı desende (WebUI → Common API → Common'da fan-out) başka ekranlar

Common backend'de **modül Refit client'larını çoklu enjekte eden yalnızca 3 sınıf** var (`IClientFxAPI|IClientMmAPI|IClientFiAPI|IClientDerivAPI|IClientOptFXAPI` beşlisi):

**1. Reconciliation Transaction** — DailyFlow'a en yakın kardeş ekran
- WebUI Controller: `...\Trex.WebUI\Controllers\Reconciliation\ReconciliationTransactionController.cs` (satır 23-27 tek Refit bağımlılığı, satır 49-60 `Load` — switch yok)
- Refit: `...\Trex.WebUI\Services\Reconciliation\IReconciliationTransactionApi.cs:9-13` → **`IClientCommonAPI`**, `[Post("/Reconciliation/select")]` — tek endpoint
- View: `...\Views\Reconciliation\ReconTransaction\Index.cshtml`
- Fan-out: `NetTrex.Common\...\NetTrex.Common.Operations\Operations\ReconciliationTransactionOperation.cs:27-53` — 5 modül client'ı + `IFimpleApi` ctor enjeksiyonu

**2. DailyFlow V1** (aynı desenin ilk nesli, strategy yerine if-zinciri)
- Refit: `...\Trex.WebUI\Services\Report\DailyFlow\IGetDailyFlowApi.cs:11-15` → **`IClientCommonAPI`**, `[Post("/DailyFlow/dailyFlowSelect")]`
- Fan-out: `NetTrex.Common\...\Report\DailyFlow\GetDailyFlowHandler.cs:38,47,56,65,74` — `if (availableModules.Any(m => m.Module == ModuleConstants.XX))` beş ayrı blok; `DailyFlowOperation.cs:34-66` her modül için ayrı metot (`GetFxDailyFlow`, `GetMmDailyFlow`, `GetFiDailyFlow`, `GetDerivDailyFlow`, `GetOptFxDailyFlow`). **V2'nin strategy factory'si bunun refactor'u** — yeni ekran için V2 deseni tercih edilmeli.

**3. External Transaction Select** (WebUI ekranı değil, dış entegrasyon ucu — bilgi amaçlı)
- `NetTrex.Common\...\NetTrex.Common.Business\External\TransactionSelectForExternalHandler.cs` — `IClientFxAPI + IClientMmAPI + IClientFiAPI`
- İlgili: `...\Report\DailyFlow\External\ExternalDailyFlowHandler.cs`, `...\Controllers\Report\DailyFlow\External\ExternalDailyFlowController.cs`

**Yanlış pozitif olarak dışlananlar:** `ICountMonitoringReportApi` ve `IUserPermissionReportApi` de `IClientCommonAPI`+tek endpoint ama Common'ın **kendi DB'sinden** okuyorlar (`GetCountMonitoringReportListHandler.cs`, `defCountMonitoring.sql`) — modül fan-out'u **yok**.

---

## H) `IClientCommonAPI`'yi kullanan tüm Refit interface'leri (86 adet + marker)

Marker: `...\Trex.WebUI\Services\Abstract\IClientCommonAPI.cs` → `IClientBaseAPI` (Trex.FrameworkCommon.Api). Host: `Startup.cs:69` `Configuration["CommonApi"]`.

Toplam **~740 endpoint**. (`ops` = interface'teki HTTP metot sayısı, `prefix` = route kökü). Tüm yollar `...\Code\Web\UI\Trex.WebUI\` altına relatif.

### Report (5) — DailyFlow'un ait olduğu grup
| Dosya | ops | prefix |
|---|---|---|
| `Services\Report\DailyFlow\IDailyFlowV2Api.cs` | 1 | `/DailyFlowV2` |
| `Services\Report\DailyFlow\IGetDailyFlowApi.cs` | 1 | `/DailyFlow` |
| `Services\Report\Monitoring\ICountMonitoringReportApi.cs` | 1 | `/CountMonitoringReport` |
| `Services\Report\UserPermissionReport\IUserPermissionReportApi.cs` | 1 | `/UserPermissionReport` |
| `Services\Report\BatchLog\IBatchCommonLogApi.cs` | 3 | `/batchlog` |

### Common\Rates (18) — 220 endpoint, en yoğun küme
`IBondPriceApi.cs` (22, `/bondprice`,`/security`,`/symbolMap`) · `IFXRateApi.cs` (19, `/fxrate`) · `IInterestRateApi.cs` (18, `/interestrate`) · `IFutureContractRateApi.cs` (15, `/futurecontractrate`) · `IFxRateSpreadApi.cs` (15, `/fxratespread`) · `IInterestRateSpreadApi.cs` (15, `/interestratespread`) · `IVolatilityRateApi.cs` (15, `/volatilityrate`) · `IBondPriceSpreadApi.cs` (13, `/bondpricespread`) · `IInvFundPriceApi.cs` (12, `/invFundprice`) · `IPriceIndexApi.cs` (10, `/priceindex`) · `ITlRefIndexApi.cs` (10, `/tlrefindex`) · `ITlRefkIndexApi.cs` (10, `/tlrefkIndex`) · `IPointApi.cs` (9, `/point`) · `IRateSourceApi.cs` (9, `/ratesource`) · `ISwapPointApi.cs` (8, `/swappoint`) · `IFXLiveRateApi.cs` (1, `/fxliverate`) · `IFXLiveRateAHLApi.cs` (1, `/fxliverateAHL`) · `IFXRatesHistoryApi.cs` (1, `/fxrateshistory`) · `IValuationRateApi.cs` (1, `/valuationrate`)

### Common\Definitions (20)
`ISymbolMapApi.cs` (13, `/symbolMap`) · `ICurrencyApi.cs` (12, `/currency`) · `ICorporateTypeApi.cs` (11, `/corporatetype`) · `ICurrencyPairApi.cs` (11, `/currencypair`) · `IMarketApi.cs` (10, `/Market`) · `IMenuDefinitionApi.cs` (10, `/MenuDefinition`) · `IBranchApi.cs` (9, `/branch`) · `IChartApi.cs` (9, `/chart`) · `ICorporateTypeMapApi.cs` (9, `/corporatetypemap`) · `ILegalVehicleApi.cs` (9, `/legalvehicle`) · `IHalfWorkingDayApi.cs` (8, `/HalfWorkingDay`) · `IMarketCustomerMapApi.cs` (8, `/marketcustomermap`) · `ISymbolDepositChartMapApi.cs` (8, `/symbolDepositChartMap`) · `ISymbolFXChartMapApi.cs` (8, `/symbolFXChartMap`) · `ISymbolVolatilityChartMapApi.cs` (8, `/symbolVolatilityChartMap`) · `IEquityApi.cs` (7, `/EquityDefinition`) · `ITransactionLimitApi.cs` (7, `/TransactionLimitDefinition`) · `INotificationTemplateApi.cs` (6, `/NotificationTemplate`) · `Product\ISubTypeApi.cs` (5, `/SubType`) · `ISwapPointHandOffDefApi.cs` (4, `/swappointhandoffdef`) · `IExternalSessionApi.cs` (2, `/ExternalSessionManagement`,`/FimpleSessionManagement`)

### FI (namespace FI ama Common API'ye gidiyor — 14)
`IPortfolioApi.cs` (11, `/portfolio`) · `IProductInstrumentApi.cs` (11, `/ProductInstrument`,`/Portfolio`) · `ITaxRuleApi.cs` (10, `/TaxRule`) · `ICountryApi.cs` (9, `/country`) · `IDateBasisApi.cs` (9, `/DateBasis`) · `ILocationApi.cs` (9, `/Location`) · `ITxnTypeApi.cs` (9, `/TxnType`) · `ITaxApi.cs` (9, `/Tax`) · `ITaxRateApi.cs` (9, `/TaxRate`) · `ITaxTypeApi.cs` (8, `/TaxType`) · `IJobCronCommonApi.cs` (8, `/JobCron`) · `IInventoryTypeApi.cs` (4, `/InventoryType`) · `IUserLayoutApi.cs` (4, `/userlayout`) · `IBitMaskSetApi.cs` (3, `/BitMaskSet`)

### Flow / DynamicRule (6)
`IFlowSetApi.cs` (12, `/FlowSet`) · `IFlowStateApi.cs` (11, `/FlowState`) · `IFlowRequestMapApi.cs` (10, `/FlowRequestMap`) · `Common\DynamicRule\IDynamicRuleApi.cs` (10, `/FlowDynamicRule`) · `IFlowTransitionApi.cs` (6, `/FlowTransition`) · `IFlowActionApi.cs` (1, `/FlowAction`) · `IFlowApi.cs` (1, `/Flow`)

### RateEngine (8)
`IRateEngineCurrencyExtensionApi.cs` (8) · `IRateEngineDynamicRuleMapAPi.cs` (8) · `IRateEngineDataSourceApi.cs` (7) · `IRateEngineDynamicRuleAPi.cs` (7) · `IRateEngineFxSpotUpdateRulesApi.cs` (7) · `IRateEngineModuleApi.cs` (7) · `IRateEngineSymbolTypeApi.cs` (7) · `Services\IRateEngineApi.cs` (4, `/RateEngine`)

### Diğer (10)
`IFrameworkParameterApi.cs` (22, `/FrameworkParameter`,`/GeneralAvailableModules`) · `ICustomerApi.cs` (13, `/Customer`) · `IUserProfileApi.cs` (11, `/UserProfile`) · `IQuantCommanApi.cs` (10, `/quant`) · `IProfilePermissionApi.cs` (9, `/ProfilePermisson` — **typo route**) · `IDataSyncApi.cs` (9, `/DataSync`) · `ICalendarApi.cs` (9, `/calendar`) · `ISicApi.cs` (7, `/Sic`) · `IEodCommonApi.cs` (4, `/eod`) · `IReconciliationTransactionApi.cs` (1, `/Reconciliation`) · `IHelperApi.cs` (2, `/helper`) · `IModularMenuDefinitionApi.cs` (2, `/MenuDefinition`)

**Yüzey değerlendirmesi:** Common API, WebUI'nin **en geniş backend yüzeyi** — 86 interface / ~740 endpoint. Tüm ortak tanımlar (currency, market, customer, chart, portfolio, tax, txntype), tüm oran/fiyat verisi (rates: 220 endpoint), tüm framework altyapısı (flow, permission, framework parameter, rate engine, menu) ve cross-module raporlar (DailyFlow, Reconciliation) buradan geçiyor. Karşılaştırma için `Startup.cs`'de kayıtlı diğer 16 marker (`IClientMMAPI`, `IClientFxAPI`, `IClientFiAPI`, `IClientDerivSWPAPI`, `IClientFundsAPI`, `IClientWarrantAPI`, `IClientOptFXApi`, `IClientLimitApi`, `IClientAccountingAPI` + Batch varyantları) modül-özel işlem yüzeyi.
**Yeni generic Manuel Reeskont ekranı cross-module olacaksa Common API'ye tek uç açmak mevcut mimariyle TAM UYUMLU.**

---

## Ajanın Manuel Reeskont için şablon özeti (kritik noktalar)

1. **Refit:** tek interface, `: IClientCommonAPI`, tek `[Post("/<Ekran>/select")]`. Modül switch'ini **UI'ye koymayın** — Common'da strategy factory.
2. **Controller:** `Index()` (GridCrudModel + LogicalDate) + `Load(request)` (`IsFirstLoad` guard → boş liste) + dropdown besleyen `Get*List()` action'ları. `IFrameworkParameterHelper.GetFrameworkParameter("General:AvailableModules")` ile aktif modül listesi (V2 deseni; V1'in HTTP çağrısı yerine bunu kullanın).
3. **Filtre:** `AdvanceAndStateFilter` ViewComponent + `_AdvanceFilterTemplate` + çoklu-seçim `DropDownBox`+embedded grid (`SelectionMode.Multiple`) → request'e virgüllü string.
4. **Grid:** sabit union kolon seti + `columnOption(..., "visible", ...)` ile koşullu görünürlük. Client-side paging (`PageSize(50)`), gruplama + `Summary.GroupItems`.
5. **Dikkat edilecek borçlar:** `ProductType` (WebUI) ↔ `DailyFlowProductType` (Common) **enum drift'i**; `Instruments`/`Currencies` için string+`Replace(",",";")` **hack'i** (`DailyFlowV2Operation.cs:31-39`) — yeni ekranda `List<int>` tercih edilmeli; **server-side paging hiç yok** (büyük veri hacminde risk); `INVFUND`/Fund modülü DailyFlow kapsamı **dışında**.
