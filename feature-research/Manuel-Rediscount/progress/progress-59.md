# progress-59 — PO 7. tur + 🔴 Micro UI taşıması (2026-09-22)

> İki iş: (A) arama/temizle düğmelerinin kutulardan çıkarılması (NetTrex.Web.UI),
> (B) Manuel Reeskont'un **Treasy.Common.UI** Micro UI projesine taşınması.

## Durum

🟡 **A: tamam** (WebUI build ✅ · JS 143/144 ✅) · **B: kod hazır, build doğrulaması sürüyor** · ⬜ tarayıcı testi yok

---

# A — Arama/Temizle düğmeleri kutuların DIŞINA (NetTrex.Web.UI)

PO: *"o büyüteç sanki sadece Log. Ref. için varmış gibi duruyor; kaldır, kutunun dışına bir buton
koy — Execution Date · Product · SubProduct · Log. Ref.'in hepsi için olduğu anlaşılsın. MM
Advance Search'teki CLEAR + SEARCH gibi."*

- Logical Reference kutusunun **içindeki büyüteç kaldırıldı** (`.Buttons(...)` bloğu).
- Form'un ALTINA, sağa yaslı **CLEAR + SEARCH** düğmeleri (`mrRenderFilterActions`,
  `.mr-filter-actions`) — desen: MM `Borrowing and Placement` → Advance Search.
- **SEARCH** = `applyFilters()` (o an dolu olan dört alanı TEK istekte uygular; dual-path kuralı
  `#useServerSideReference` aynen geçerli).
- **CLEAR** = `clearFilters()`; artık **alt ürün seçimini de** temizliyor. ⚠️ `Product` ve
  `Execution Date` KORUNUR: ikisi de zorunlu ve modül yönlendirmesini onlar belirliyor.
- Grid toolbar'ındaki `Temizle` ikonu **kaldırıldı** — aynı işi iki yerden yapmak Yenile'deki
  hatanın aynısı olurdu. Toolbar'da artık Yenile + Export var.
- `mrOnApplyFilters` global'i düştü (düğmeler doğrudan instance metotlarına bağlı).
- Yeni localization: `mr-action-Search` / `mr-action-SearchHint` (EN+TR).

---

# B — 🔴 Micro UI taşıması: `NetTrex.Web.UI` → `Treasy.Common.UI`

Branch: **`main-manuel-reeskont-development`** (Common.UI `main`'den, HEAD `24895e3`).

## Hedef projede bulunan desen

Kaynak playbook `Treasy.MM.UI/.ai-agent/` (MD'ler **bayat**: `Treasy.MicroUI.SharedDependency` /
`@treasy/helpers` artık yok → gerçek yapı `Treasy.Pure.*` + `@treasy/{pure,core,client,devextreme,
localization,notification}`). Referans ekran: **TaxRule**; fan-out deseni: **JobCron**.

## Taşınanlar

| Katman | Dosya |
|---|---|
| **Core** | `Models/ManualRediscount/{Model,Req,Res}` — enum'lar, `RediscountLookupItem`, `EligibleTransactionsRequest`, `ExecutionsRequest`, `ManualRediscountColumnFilters`, `EligibleTransactionsResponse`, `ExecutionsResponse`, + alt ürün için ince `SubProductDefinitionSelect{Request,Response}` |
| **Business** | `ApiReferences/ManualRediscount/Base/IManualRediscountApi.cs` (2 route) + `IManualRediscount{Mm,Fx,DerivSwp,OptFX}Api` + `IManualRediscountSubProductApi` · `ViewModels/ManualRediscount/ManualRediscountComponentVM.cs` |
| **Web** | `Controllers/ManualRediscount/` (base + Treasury/Security/Investment) · `ViewComponents/ManualRediscount/` · `Views/ManualRediscount/{Treasury,Security,Investment}/Index.cshtml` · `Views/Shared/Components/ManualRediscount/Default.cshtml` |
| **Frontend** | `wwwroot/js/pages/manual-rediscount/{manual-rediscount,constants,context,endpoints,columns,filters,actions,component}.ts` + `bridges/manual-rediscount.ts` · `wwwroot/css/pages/manual-rediscount/` · `wwwroot/localization/pages/manual-rediscount/` · `wwwroot/js/config/manual-rediscount/` |

## Taşımada verilen kararlar

1. **Resolver/ModuleClient/QueryService katmanı DÜŞTÜ.** Micro UI'de modül seçimi Controller
   içinde switch (`ResolveModuleApi`) — ev deseni `JobCronController`. Refit client'ları
   `IClientMmApi`/`IClientFxApi`/`IClientDerivSwpApi`/`IClientOptFXApi` base'lerinden türediği için
   **BaseAddress ve DI kaydı paket tarafında otomatik**; monolitteki `ManualRediscountRefitRegistration`
   (4 config key + elle timeout kaydı) tamamen gereksizleşti.
2. **JS → TS, 8 dosya → 9 ES modülü.** Global-scope yerine `import`/`export`. Razor'dan çağrılan
   handler'lar `bridges/manual-rediscount.ts` → `exposeNamespacedApi("ManualRediscount", {...})`
   ile global'e açılıyor; view'da `.OnValueChanged("ManualRediscount.onFilterChanged")`.
   ⚠️ Köprü üyeleri `export function` (ok fonksiyon `undefined` kopyalanıyor — paket tuzağı).
3. **Inline `init` script'i kaldırıldı.** Vite modülü ASENKRON yüklendiği için Razor'daki inline
   `ManualRediscount.init({...})` modülden önce koşup `is not defined` verirdi. Ayarlar artık kök
   div'de `data-mr-*` attribute'larında; giriş modülü kendini başlatıyor.
4. **`showLoader()/hideLoader()`** (Web.UI global'i) → `getLoadPanelInstance()` (`@treasy/core`).
5. **`$.ajax` → `post`/`get`** (`@treasy/client/http`) — paket `post()` gövdeyi JSON gönderiyor,
   `[FromBody]` sözleşmesi korunuyor.
6. **`ToNetixForm/ToNetixDateBox` → `ToTreasyForm/ToTreasyDateBox`**; `ViewBag` → `AddViewBag`;
   gövde `<ShellContent>`; script `<treasy-script … bundle-mode="Always">` (ekran Index'lerinde,
   ViewComponent içinden `@section` tanımlanamıyor).
7. 🔴 **Muhasebe (`Acc.`) kolonu DEVRE DIŞI** — gerekçe aşağıda.

## 🔴 Açık kalan / PO kararı gereken

- **Muhasebe penceresi:** monolitte `Views/Shared/_AccountingDisplay.cshtml` partial'ı (Core Banking /
  Local / Module sekmeleri) + `BaseController.Accounting` üzerinden çalışıyordu; **ikisi de
  Framework.WebUI'ya ait, Treasy.Common.UI'de karşılığı YOK**. Kolon açık bırakılsa düğme 404
  verirdi → `columns.ts`'te yorum bloğuna alındı, uçlar (`endpoints.ts`) imzalarıyla duruyor.
  **Soru:** Micro UI'de muhasebe penceresinin karşılığı ne olacak (Pure'da bir bileşen var mı,
  yoksa yalnız *Module Accounting* mi gösterilecek)?
- **Menü + permission kaydı:** monolitte de bu üç ekran için SQL/menü scripti yoktu; Common.UI'de
  ekranların menüye düşmesi için kayıt gerekecek.
- **FI / INVFUND**: Security ve Investment ekranlarının modül uçları hâlâ yok (monolitte de yoktu) —
  `ResolveModuleApi` `null` döner, ekran sebebini yazar.
- ⚠️ `ManualRediscountValueDatePreview` modelinde **`ReverseType` alanı yok** ama JS tarafı
  (`mrSetValueDateInfo`) okuyor — WebUI'daki kırık JS testinin (`reverseType`) kök sebebi bu.
  Taşımada birebir korundu (davranış değiştirmemek için); düzeltmek ayrı bir karar.

## Doğrulama

- **A:** `Trex.WebUI` build ✅ 0 hata · JS **143/144** (kalan 1 hata turlardan önce de kırıktı).
- **B:** `dotnet build Treasy.Common.UI.slnx` ✅ **0 hata** · `npm run typecheck` (tsc --noEmit)
  ✅ **temiz** · Vite bundle ✅ `wwwroot/bundles/js/pages/manual-rediscount/manual-rediscount.js`
  (127 kB, entry auto-discovery `<treasy-script>`'ten buldu) · localization bundler ✅ `mr-*`
  anahtarları `bundles/localization/{tr,en}.json`'a girdi. ⬜ **Tarayıcı testi yapılmadı.**

### Build sırasında çıkan ve düzeltilen hatalar

1. `ResponseBase.Message` **salt okunur** (Netix.Core) → hata metni `Messages` listesine yazılıyor
   (`Failed`/`FailedExecution`), monolitteki `ManualRediscountQueryService` ile aynı desen.
2. `ResponseOf<T>` üzerinde `Message` yok → transport mesajı `external?.Messages`'tan okunuyor.
3. TS: paketin `post()` dönüşü dar tipli → `endpoints.ts` uçları `Promise<any>`.
4. TS: `DevExpress.localization.formatDate` ambient tipte bildirilmemiş → `as any`.
5. TS: `$(...).dxDataGrid(options).dxDataGrid("instance")` zinciri jQuery eklenti tipiyle
   çakışıyor → `as any` zinciri.
6. TS: `onProductChanged` argümansız → köprüdeki çağrı düzeltildi.

## Commit durumu

⬜ **Commit/push YAPILMADI** — branch `main-manuel-reeskont-development` üzerinde 11 yeni klasör
dosyasız duruyor (`git status`'ta untracked). Commit'i kullanıcı kendisi atacak.
