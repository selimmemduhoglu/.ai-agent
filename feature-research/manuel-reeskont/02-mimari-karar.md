# Mimari Karar — Manuel Reeskont Base Component

> Ekran **nereye** yazılır, modüllere **nasıl** gidilir, hangi repoda ne iş var.
> Doküman analizi → [`01-dokuman-analizi.md`](01-dokuman-analizi.md) · MM envanteri → [`03-mm-backend-envanteri.md`](03-mm-backend-envanteri.md) · Sorular → [`04-sorular.md`](04-sorular.md)
> Ham ölçümler → [`analiz/`](analiz/_index.md)
>
> **Durum:** ✅ Ana mimari **kullanıcı kararıyla** belirlendi (2026-08-12, **v2**) · 🟡 ADR detayları onay bekliyor
> **Son Güncelleme:** 2026-08-12 (v2 — Common çıkarıldı)

---

## 0. 🔴 DEĞİŞİKLİK KAYDI — v1 → v2 (2026-08-12)

Bu dosyanın **iki önceki sürümü** var; ikisi de arşiv değeri taşıyor:

| Sürüm | Karar | Durum |
|---|---|---|
| **v0** (ilk taslak) | 4 seçenekli analiz, fan-out UI controller'da | ❌ Arşiv → [`analiz/analiz-0-ilk-mimari-taslak-SUPERSEDED.md`](analiz/analiz-0-ilk-mimari-taslak-SUPERSEDED.md) |
| **v1** | WebUI → **`NetTrex.Common`** → Common'da Strategy Factory ile modüllere fan-out (DailyFlow V2 klonu) | ❌ **İPTAL** — ADR-MR-015 |
| **v2** ⬅️ **GEÇERLİ** | WebUI base component → **WebUI Controller'dan modüllere DİREKT** (MM · Fx · FI · InvFund). **Common yok.** | ✅ Geçerli |

**Kullanıcının v2 kararı (kendi kelimeleriyle):**

> *"WebUI'da base component'imiz olacak ve Controller'dan backend projelerine istekler gönderilecek ve gelen
> datalar kullanılacak. **Bu mimaride Common projesine ihtiyacımız yok.** WebUI projesi ile backend projeleri
> (MM-Fx-FI-InvFund) üzerinden gidecek şimdilik. Sonrasında ise WebUI'daki base component'i
> Treasy.MicroUI.Packages projesine alacağız ve MicroUI projelerine aldıktan sonra MicroUI projelerinden gidecek.
> Yani anlayacağın **Common projesini hiçbir şekilde kullanmayacağız**. (…) **Common yok — MicroUI projeleri yok
> — package projesi yok şimdilik.**"*

⚠️ **v1'in ölçümleri silinmedi** — DailyFlow V2 fan-out kanıtları (`analiz-4`, `analiz-5`) ve
`F-01`…`F-12` bulguları **emsal/referans** olarak duruyor. Bazıları v2'de de geçerli
(`F-06` paging, `F-07` union model, `F-09` enum drift, `F-11` permission), bazıları **artık konu dışı**
(`F-01` InvFund Common client'ı, `F-03` `Task.WhenAll`, `F-04` `ToContentGeneral`, `F-05` Common token).
Hangisi hangisi → § 1.4 tablosunda işaretli.

---

## 1. Karar — Tek Cümle

**WebUI'de tek base component (3 ekran) → her ekranın kendi WebUI Controller'ı → Controller'dan modül
API'lerine (MM · Fx · FI · InvFund) Refit ile DİREKT fan-out.** Ara katman yok.

```text
┌─ Tarayıcı ─────────────────────────────────────────────────────────────────────┐
│  /TreasuryReeskont  ·  /SecurityReeskont  ·  /InvestmentReeskont               │
│  DevExtreme grid + filtre + toplu seçim + onay penceresi (BASE COMPONENT)      │
│  new ManuelReeskontComponent({ settings: { productGroup: "Treasury" } })       │
└──────────────────────────────┬────────────────────────────────────────────────┘
                               │ POST /{Ekran}/Load        ← ajax.js, settings.baseUrl = APP KÖKÜ
                               │ POST /{Ekran}/Execute        (modül adresi UI'de YOK)
┌──────────────────────────────▼────────────────────────────────────────────────┐
│  NetTrex.Web.UI  —  Controllers/ManuelReeskont/                               │
│    TreasuryReeskontController · SecurityReeskontController · Investment…       │
│         │  (3 controller = 3 ayrı permission — ADR-MR-003)                     │
│         ▼                                                                      │
│    IManuelReeskontModuleResolver  →  moduleCode → doğru Refit client'ı         │
│         │                                                                      │
│         ▼  Task.WhenAll + MODÜL-BAŞINA try/catch  →  AGGREGATE + kısmi hata    │
└──┬──────────────┬──────────────┬──────────────┬───────────────────────────────┘
   │              │              │              │
   ▼              ▼              ▼              ▼
IClientMMAPI  IClientFxAPI  IClientFiAPI  IClientFundsAPI      ← HEPSİ HAZIR
   │              │              │              │                (Startup.cs:58-75)
   ▼              ▼              ▼              ▼
NetTrex.MM    NetTrex.Fx    FI (repo?)    InvFund
POST /api/manuel-reeskont/eligible-transactions
POST /api/manuel-reeskont/executions
```

### Neden bu mimari çalışır (ölçülmüş)

| Gerekçe | Kanıt |
|---|---|
| WebUI'de **4 modülün Refit marker'ı zaten kayıtlı** — yeni DI/config gerekmiyor | `Startup.cs:58-75` · [analiz-6 § 6](analiz/analiz-6-webui-base-component-desenleri.md) |
| `RegisterClientWebApiRefitClients<T>` AppDomain'i tarar → **yeni interface yazmak yeterli** | aynı |
| **Modül seçimi zorunlu olarak sunucuda** — `settings.baseUrl` uygulama kökü, modül adresi değil | `_ErrorLayout.cshtml:54-56`, `ajax.js:1-49` |
| `moduleCode` **house convention** — icat değil | `cashflow.component.js:112`, `:983` |
| Config-driven endpoint override deseni **mevcut** | `cashflow.component.js:990-992` |
| Modül-parametreli ViewComponent deseni **mevcut** | `LimitCheckViewComponent.cs` |

### Kaybedilen (Common'ın sağladığı ama artık kullanılmayan) şeyler

| Kayıp | Sonuç / telafi |
|---|---|
| `IGeneralAvailableModulesOperation` (`General:AvailableModules` framework parametresi) | WebUI'de `IFrameworkParameterHelper` var → aynı parametre **oradan okunabilir**. ⚠️ **Doğrulanmadı** → `F-14` |
| Common'ın `ModuleConstants` sabitleri | WebUI'de karşılığı **tespit edilmedi** → `F-15`. Yeni sabit sınıfı yazılacak |
| Modüller-arası tek noktadan sözleşme yönetimi | Sözleşme DTO'ları artık **Web.UI'de** yaşar; modüller kendi kopyasını tutar → sürüm sapma riski `R-11` |
| Başka çağıranların (MicroUI, dış sistem) aynı fan-out'u kullanabilmesi | Faz 3'te base component pakete taşınırken **paket** ortak ev olacak (ADR-MR-017) |

---

## 2. Base Component Tasarımı

### 2.1 Referans desen — `cashFlow/` (nesil 3) ⭐

WebUI'de üç desen nesli var; **nesil 3** taban alınacak (detay → [analiz-6 § 3](analiz/analiz-6-webui-base-component-desenleri.md)):

| Nesil | Örnek | Karar |
|---|---|---|
| 1 — tek dosya, global `const`/`function` | `paymentComponent.js`, `customerPaymentComponent.js`, `amortizationComponent.js`, `tawarruqAgentComponent.js` | ❌ Base component için model **değil** (`const` çakışma riski, ölçeklenmiyor). Kullanıcı emsal gösterdi; incelendi, daha ilerisi seçildi |
| 2 — çok dosya, modüler + prefix disiplini | `limit-check/` | ✅ **Dosya bölümlemesi + prefix + ViewComponent hidden-alan deseni** buradan |
| 3 — `class` + deep-merge config + JSDoc typedef | `cashFlow/` (7 dosya) | ✅ **İskelet buradan** |

### 2.2 Config sözleşmesi (öneri)

```js
new ManuelReeskontComponent({
    uniqueKey: "trs",                        // aynı sayfada çoklu instance
    settings: {
        productGroup: "Treasury",            // Treasury | Security | Investment
        logicalDate: new Date(),
        modules: ["MM", "FX"],               // boş → sunucu aktif modülleri belirler
        pageSize: 50
    },
    dataSource: {
        key: "TransactionId",
        load:    { url: "" },                // boş → varsayılan /{Ekran}/Load
        execute: { url: "" }                 //        /{Ekran}/Execute
    },
    columns: {                               // ürün-özel kolonlar (Data dictionary'e bakar)
        config: null,                        // null → ViewComponent'in bastığı hidden alandan okunur
        url: ""                              // veya uzaktan yükle
    },
    actions: {
        generate:   { enabled: true, confirm: true },
        regenerate: { enabled: true, confirm: true, toToday: false }
    },
    selection: { bulk: true, selectAll: true },
    exporting: { enabled: true },
    styles: {}
})
```

Prefix: **`MR_`** (Hard Rule 4 — `CLC_`/`CF_` ile çakışmasın).

### 2.3 Fiziksel yerleşim — `NetTrex.Web.UI`

```text
Code/Web/UI/Trex.WebUI/
├── Controllers/ManuelReeskont/                    ← YENİ klasör (doğru yazım)
│   ├── TreasuryReeskontController.cs              ← ProductGroup=Treasury  (permission: TreasuryReeskont/*)
│   ├── SecurityReeskontController.cs              ← ProductGroup=Security
│   └── InvestmentReeskontController.cs            ← ProductGroup=Investment
│        ⚠️ Mevcut Controllers/ManuelReescont/ (yazım hatalı, Fx'e hardwired) DOKUNULMAZ — C-20 kararına kadar yaşar
├── Services/ManuelReeskont/
│   ├── IManuelReeskontModuleResolver.cs           ← moduleCode → Refit client (fan-out burada, controller'da DEĞİL)
│   ├── ManuelReeskontModuleResolver.cs
│   ├── IManuelReeskontMmApi.cs                    ← : IClientMMAPI
│   ├── IManuelReeskontFxApi.cs                    ← : IClientFxAPI
│   ├── IManuelReeskontFiApi.cs                    ← : IClientFiAPI
│   └── IManuelReeskontInvFundApi.cs               ← : IClientFundsAPI   (dikkat: Funds)
├── ViewComponents/ManuelReeskont/ManuelReeskontViewComponent.cs   ← ProductGroup parametresi + kolon config'i hidden alana basar
├── Views/Shared/Components/ManuelReeskont/
│   ├── Default.cshtml                             ← filtre + DevExtreme grid + toolbar
│   ├── _GenerateConfirm.cshtml
│   ├── _RegenerateConfirm.cshtml
│   ├── _ReverseValueDate.cshtml                   ← T+0 / T+1  (C-08'e bağlı)
│   └── Templates/_{AdvanceFilter,Product,SubProduct,RevaluationType}Template.cshtml
├── Views/ManuelReeskont/{Treasury,Security,Investment}/Index.cshtml   ← her biri ViewComponent'i Invoke eder
├── Models/Shared/Components/ManuelReeskont/       ← ViewComponent VM
├── Models/ManuelReeskont/                         ← sözleşme DTO'ları (request/response/item/error)
├── wwwroot/js/shared/components/manuel-reeskont/
│   ├── manuel-reeskont.component.js               ← class, grid + filtre + toplu seçim
│   ├── manuel-reeskont.actions.js                 ← Generate / Regenerate / onay akışı
│   ├── manuel-reeskont.columns.js                 ← kolon config yükleyici + uygulayıcı (Data dictionary)
│   ├── manuel-reeskont.context.js                 ← seçili satır + filtre state (cashflow.context.js deseni)
│   ├── manuel-reeskont.constants.js               ← MR_ prefix'li selector + Status enum + CssClass haritası
│   └── manuel-reeskont.endpoints.js
├── wwwroot/js/config/manuel-reeskont/*.json       ← ÜRÜN KOLON KONFİGÜRASYONLARI (C-15'e bağlı)
├── wwwroot/js/localization/pages/manuel-reeskont/manuel-reeskont-{tr,en}.json
└── wwwroot/css/shared/components/manuel-reeskont.css
```

### 2.4 `NetTrex.MM` — 2 endpoint (v1'den değişmedi)

```text
Code/Api/NetTrex.MM.Api/Controllers/ManuelReeskont/ManuelReeskontController.cs
   POST api/manuel-reeskont/eligible-transactions
   POST api/manuel-reeskont/executions
Code/Api/NetTrex.MM.Api.Services/ManuelReeskont/{Handlers,Validators}/
Code/Api/NetTrex.MM.Api.ResponseRequest/ManuelReeskont/{Request,Response}/
Code/Data/NetTrex.MM.Data/Managers/...  → durum-türetmeli + sayfalamalı sorgu
```

Motor **yazılmayacak** — mevcut `IRevaluationAccountingService` + `IRevaluationReverseAccountingService`
tetiklenir. Detay → [`03-mm-backend-envanteri.md`](03-mm-backend-envanteri.md) § 8.

### 2.5 Faz 3 — `Treasy.MicroUI.Packages` + MicroUI (ŞİMDİLİK YOK)

Kullanıcı: *"Common yok — MicroUI projeleri yok — package projesi yok **şimdilik**."*
Faz 1 bittikten sonra base component `Treasy.MicroUI.SharedDependency` (RCL) + `@treasy/components`'e
taşınır; MicroUI'ler `@await Component.InvokeAsync("ManuelReeskont", …)` ile **import eder**.
Kullanıcı: *"işimiz kolay olacak kodları direkt geçiririz."*
Emsal güçlü — paketten **tam ekran** (`Views/Shared/Pages/Login/Index.cshtml`) + **10 DevExtreme grid'li
ortak bileşen** zaten çıkıyor ([analiz-1](analiz/analiz-1-microui-shell-paketler.md)).

⚠️ **Faz 3'ü kolaylaştırmak için Faz 1'de uyulacak kurallar:**

1. Component JS'i **Web.UI'ye özel global'lere bağımlı olmasın** — `settings`, `formatMessage`,
   `notifyError`, `get`/`post` dışında dış bağımlılık yaratma; bunlar da paket tarafında karşılığı var/olacak.
2. **Endpoint yolları config'ten** gelsin (`dataSource.*.url`) — hardcoded `/TreasuryReeskont/Load` yazma.
3. Razor bileşeni **`Views/Shared/Components/`** altında dursun (RCL'ye taşınabilir yol).
4. CSS ve localization **ayrı dosyada** olsun, inline değil.

---

## 3. ADR'ler

> v1'de yazılan ADR'ler **korunmuştur**; v2'de geçersiz kalanlar **❌ İPTAL** ile işaretli,
> değişenler **♻️ REVİZE** ile. Numaralar **yeniden kullanılmaz** (kayıt izlenebilirliği).

| # | Karar | Gerekçe | Durum |
|---|---|---|---|
| **ADR-MR-001** | ~~Fan-out `NetTrex.Common`'da yapılır (DailyFlow V2 klonu)~~ | Kullanıcı v2'de Common'ı tamamen çıkardı | ❌ **İPTAL** → ADR-MR-015 |
| **ADR-MR-002** | Kolon config'te `baseUrl` **yok**, yerine **`moduleCode`**. Config yalnız **sunum** bilgisi taşır (`productGroup`, `product`, `columns`) | UI hiçbir modül adresi bilmiyor (`settings.baseUrl` = app kökü, modül adresi değil). `moduleCode` house convention (`cashflow.component.js:112`). İş birimine sözleşme değişikliği olarak bildirilecek | ✅ **Karar** (kullanıcı onayı) |
| **ADR-MR-003** | **3 ayrı controller** (Treasury / Security / Investment), **tek** ViewComponent | `F-11`: permission = **ControllerAdı/ActionAdı**. Tek controller olsa 3 ekran aynı permission'ı paylaşır → doküman §9 karşılanmaz. **v2'de daha da kritik** (yetki tek katmanda) | 🟡 Öneri |
| **ADR-MR-004** | ♻️ Tarayıcı modül servisine **doğrudan gitmez**; her istek **UI controller → modül** zinciriyle proxy'lenir | v1'de "UI → Common → modül" idi, ara adım kalktı. Teknik zorunluluk: `settings.baseUrl` app kökü | ✅ **Karar** |
| **ADR-MR-005** | MM'de **yeni hesap motoru yazılmaz** — mevcut `IRevaluationAccountingService` + `IRevaluationReverseAccountingService` tetiklenir; batch ile manuel ekran **aynı** kod yolunu paylaşır | Altyapı hazır (envanter § 8.1); FX'te de aynı desen | 🟡 Öneri |
| **ADR-MR-006** | `StatusDescription` backend'den serbest metin **değil**, `StatusCode` + `ReasonCode` olarak döner; metni UI localize eder | Backend'den Türkçe metin çoklu dili kırar; `.data-localization` + `formatMessage` deseni mevcut | 🟡 Öneri — **iş birimi onayı** |
| **ADR-MR-007** | `executions` **satır bazlı izole** çalışır; hata satırı diğerlerini düşürmez, `Failed[]`'a düşer | FX'in "`IsSuccess` her zaman true, hatalar yutulur" hatası tekrarlanmasın | 🟡 Öneri |
| **ADR-MR-008** | ♻️ **Fan-out `Task.WhenAll` + MODÜL-BAŞINA `try/catch`** ile **WebUI service katmanında** yapılır; hatalar response'ta biriktirilir. **`ajax.js`'in `get`/`post`'una satır-bazlı hata için güvenilmez** (`IsSuccess === false → null`, hata yutulur) | v1'de bu iş Common'daydı (`F-03`/`F-04`); v2'de WebUI'ye taşındı. WebUI'nin kendi yutma tuzağı: `ajax.js:20`, `:45` + `Load`'un iki-şekilli response'u | 🟡 Öneri |
| **ADR-MR-009** | 🔴 **Server-side paging** (`Skip`/`Take`/`TotalCount`) | `F-06`. Doküman zorunlu kılıyor; 248+ kayıt gerçek senaryo; eski FX ekranında paging **yok** | 🟡 Öneri |
| **ADR-MR-010** | 🔴 Ürüne özel alanlar **`Data: Dictionary<string,object>`** ile taşınır (union model **değil**) | `F-07`. Kolon seti ürün başına farklı (doküman §5.5); union model her yeni üründe ortak modeli değiştirir | 🟡 Öneri |
| **ADR-MR-011** | Modül/ürün filtreleri **`List<string>`** taşınır; virgüllü string + `Split`/`Enum.Parse` **kullanılmaz** | `F-08` + `F-09` (enum drift). Eski ekran `RediscountProducts.Split(',')` + `Enum.Parse` yapıyor → **geçersiz değerde fırlatıyor** (`TryParse` yok) | 🟡 Öneri |
| **ADR-MR-012** | ♻️ Kullanıcı kimliği request body'de **`CurrentUserId`** ile taşınır | v1 gerekçesi: Common → modül token taşımıyor (`F-05`). v2'de **WebUI → modül token durumu doğrulanmadı** (`F-13`) → `CurrentUserId` **her iki durumda da güvenli**. MM'deki hardcoded `StateMaker = "SYSTEM"` (T-01) bununla değişecek | 🟡 Öneri |
| **ADR-MR-013** | ♻️ Aktif modül listesi **framework parametresinden** okunur; kapalı modül fan-out'a **hiç girmez** | v1: Common'ın `IGeneralAvailableModulesOperation`'ı. v2: WebUI'de `IFrameworkParameterHelper` var, `General:AvailableModules` oradan okunabilir — ⚠️ **doğrulanmadı** (`F-14`). Ek olarak `LimitCheckViewComponent` deseni: **parametre yoksa AKTİF** | 🟡 Öneri |
| **ADR-MR-014** | ♻️ Faz 1'de **MicroUI'ye ve pakete dokunulmaz** | Kullanıcı: *"Common yok — MicroUI projeleri yok — package projesi yok şimdilik."* Faz 1 hedefi: Treasury ekranı + MM ucu çalışsın | ✅ **Karar** |
| **ADR-MR-015** ⭐ | 🔴 **`NetTrex.Common` HİÇBİR ŞEKİLDE kullanılmaz.** Fan-out **WebUI Controller/service katmanında**, modül Refit client'larıyla **direkt** | **Kullanıcı kararı** (2026-08-12): *"bu mimaride Common projesine ihtiyacımız yok… Common projesini hiçbir şekilde kullanmayacağız."* Teknik olarak da uygulanabilir: 4 modülün marker'ı WebUI'de zaten kayıtlı (`Startup.cs:58-75`), ek DI/config gerekmiyor. Kazanç: bir hop az, tek deploy birimi, sözleşme tek yerde. Bedel: fan-out başka çağıranlarca yeniden kullanılamaz (Faz 3'te paket bunu çözer) | ✅ **Karar** |
| **ADR-MR-016** ⭐ | Base component **nesil 3** deseniyle yazılır: `class` + `#private` field + **deep-merge config** + JSDoc `@typedef` + `settings.moduleCode`/`productGroup` + `dataSource.<op>.url` override + ayrı `Context` sınıfı. Dosya bölümlemesi ve **`MR_` prefix** disiplini nesil 2'den (`limit-check/`) | `cashFlow/` platformdaki en olgun yeniden kullanılabilir bileşen; config-driven endpoint override ve `moduleCode` **zaten orada var**. `paymentComponent.js` (nesil 1) tek dosya + global `const` → base component olarak ölçeklenmez ve Hard Rule 4 ihlali riski taşır | 🟡 Öneri |
| **ADR-MR-017** ⭐ | **Faz sırası:** (1) Web.UI base component + Treasury ekranı + **MM** ucu → (2) diğer modüller (Fx, FI, InvFund) + Security/Investment ekranları → (3) `Treasy.MicroUI.Packages`'a taşıma + MicroUI import | Kullanıcı kararı: *"öncelikli olarak WebUI ve MM projesine yaz ve sonra da diğer projelere ekleyeceğiz."* Faz 3 için Faz 1'de 4 taşınabilirlik kuralı uygulanacak (§2.5) | ✅ **Karar** |
| **ADR-MR-018** ⭐ | Modül seçimi **Controller gövdesinde değil**, `IManuelReeskontModuleResolver` servisinde yapılır; her modül için ayrı Refit interface (`: IClient<Modul>API`) | 3 controller aynı fan-out mantığını kullanacak → tekrar olmasın. Faz 3'te pakete taşınacak parça **service**, controller değil. Refit interface'leri `IClientBaseAPI` sayesinde **DI kaydı gerektirmiyor** | 🟡 Öneri |
| **ADR-MR-019** ⭐ | 🔴 **Grid kolon filtreleri SUNUCUDA uygulanır** — sözleşmeye `Filters` (`LogicalReference` / `ExternalCustomerId` / `ExternalCustomerName` / `SearchText`) eklendi. Yalnız **sabit** kolonlar filtrelenebilir; `Data` sözlüğündeki ürüne özel kolonlarda UI filtre kutusu **açmaz** | Grid `remoteOperations.paging` ile çalışıyor: tarayıcıda süzmek yalnız **yüklü sayfayı** süzer → "3 kayıt var" yanılgısı + `TotalCount` ve durum özeti (§ 5.3) filtreyle çelişir. Ürüne özel kolonlar modülün projeksiyonunda **türetiliyor** → SQL'de filtrelenemez; boş kutu göstermek "filtrelenebilir" yalanı olur. **Bedel:** Fx/FI/InvFund uçları aynı alanları uygulamazsa filtre **sessizce yok sayılır** (`R-11`) | ✅ **Karar** (kullanıcı 2026-08-20) |
| **ADR-MR-020** ❌ | ~~İlerleme göstergesi ayrı bir salt-okunur uçla (`executions/progress`) çözülür~~ → 🔴 **GERİ ALINDI (2026-08-21, kullanıcı kararı).** Tüm poll altyapısı (tracker · uç · DTO'lar · WebUI plumbing · JS poll döngüsü · testler) **silindi** | Kullanıcının sözleri: *"Polling ile yaptığın tüm geliştirmeleri kaldır, Faz 1 için gerekli değilmiş; daha sonra daha güzel bir yapı kurulacak."* Ölçülen maliyet ~550 satır (çalışan kısım ~300) ve bunun büyük bölümü tek bir `int`i dışa açmak için platform plumbing'iydi. Ekran Execute sırasında yalnız **kapsam** yazıyor ("N kayıt işleniyor…") + `Processing` rozetleri; hangi satırda olduğu **gösterilmiyor**. `Execute` hala **tek istek** (2026-08-19 kararı değişmedi) | ❌ **Geri alındı** (2026-08-21) |
| **ADR-MR-021** ❌ | ~~T+1 hesabı `MMSystemWDFlag`'e bağlıdır (`WeekdaysOnly`→iş günü, diğerleri→takvim günü)~~ → 🔴 **DEĞİŞTİ — bkz. `ADR-MR-027`** | Batch ölçümü doğruydu ve **kayıtta duruyor** (aşağıdaki not), ama kullanıcı ekranın batch'i taklit etmesini **istemedi**: *"NextWorkingDay'e de bakma SystemWDFlag'ine de bakma, direkt +1 gün."* | ❌ **Değişti** (2026-08-21) |
| **ADR-MR-022** | Excel export butonu **grid toolbar'ının dışında**, sayfanın sağ üst köşesinde durur; grid'in kendi `export` özelliği **kapalı**, export grid API'siyle (`exportDataGrid`) yapılır | DevExtreme `export.enabled` verildiğinde grid'in **kendi toolbar satırını** açıyor ve **tablo bir satır aşağı kayıyor** (kullanıcı bulgusu). Konumlama emsali `MmTransaction/Index` → `.mm-import-wrapper` (mutlak konumlu, akışta yer tutmuyor). Dosya içeriği değişmiyor — görünen kolonlar + formatlar korunur. ⚠️ Export **görünen sayfayı** yazar (sunucu taraflı sayfalama); buton ipucu bunu söylüyor | ✅ **Karar** (kullanıcı 2026-08-20) |
| **ADR-MR-023** | Generate/Regenerate butonlarının köşesinde **bilgi (i) ikonu**: durum bazında ne yaptıklarını anlatan pencere açar. İkon **pasif buton üzerinde de tıklanabilir** | Kullanıcı: *"müşteri bu butonların ne işe yaradıklarını anlamayabilir."* Metinler `ExecutionsHandler` dallanmasından **birebir** türetildi (uydurma değil): Generate bir adım ilerletir ve `Rediscounted` satırda **hata verir**; Regenerate her durumdan `Rediscounted`'a götürür. İkonun pasifken de çalışması önemli: "neden pasif" sorusunun cevabı da o metinde | ✅ **Karar** (kullanıcı 2026-08-20) |
| **ADR-MR-024** ❌ | ~~Durum (`Status`) filtresi **sunucuda kalır** — tüm veriyi çekip UI'da süzmeye geçilmez~~ → 🔴 **GERİ ALINDI — bkz. `ADR-MR-028`** | Kullanıcı kararı 2026-08-21: *"her seferinde statüs filtrelerinde sunucuya gitmek istemiyorum, tarih için her statüdeki datayı getirip statülere göre filtrelemeni istiyorum."* Bu ADR'nin **bayat durum** kaygısı haklıydı ama yanlış yerde çözülmüştü: gerçek koruma modülün `STATUS_CHANGED` reddi (§ 4.5), tarayicının taze veri tutması değil | ❌ **Geri alındı** (2026-08-21) |
| **ADR-MR-025** ⭐ | 🔴 **Ters fiş valörünün hesabı TEK SINIFTA**: `ManualRediscountValueDateResolver`. Hem `executions` (fiş keserken) hem `eligible-transactions` (ekrana önizleme verirken) **aynı** sınıfı çağırır; ikinci bir kopya **yazılmaz** | İki yerde ayrı hesap = ekran bir tarih gösterip modülün başka tarihe fiş kesmesi; hata mesajı yok, fark **defterde** görülür. Kural değiştiğinde (bu turda iki kez değişti) tek dosya değişiyor. Fx/FI/InvFund uygularken bu kuralı tekrarlamalı | ✅ **Karar** (2026-08-21) |
| **ADR-MR-026** | Valör **önizlemesi** satır verisinde değil **yanıt seviyesinde** taşınır (`ValueDates: { ExecutionDate, NextDate, ReverseType }`) ve UI'da **hiç hesaplanmaz**; grid kolonu `dataField` **taşımaz**, filtre/sıralama **kapalı** | Tarih tek bir kurala bağlı olduğu için satır başına taşımak boşuna yer. UI'da hesaplamak ise **yasak**: hesabın tek evi modül (`ADR-MR-025`); UI kopyası sessiz sapma üretir. Kolon sunucuda **yok** → filtre/sıralama açmak sessiz yanlış sonuç olurdu. Modül bloğu vermezse kolon **boş** kalır | ✅ **Karar** (2026-08-21) |
| **ADR-MR-027** ⭐ | 🔴 **T+1 = ExecutionDate + 1 TAKVİM GÜNÜ.** Takvim servisi (`ICalendarHelper`) ve `MMSystemWDFlag` **okunmaz**; hafta sonu/tatil kaydirmasi **yok**. `ADR-MR-021`'in yerine geçer | **Kullanıcı kararı 2026-08-21** (kendi sözleriyle): *"Reverse için T+1 konusu için NextWorkingDay'e de bakma SystemWDFlag'ine de bakma, direkt +1 gün deyip ilerleyelim… takvim günü olarak öyle ilerleyelim, bu kesin bilgidir, her zaman 1 gün sonra olsun."* **Bilinçli ödün:** batch ters fişi kendi koşu gününe kesiyor ve o gün `SystemWDFlag`'e göre değişiyor → `WeekdaysOnly` kurulu bir müşteride ekran Cumartesi'ye, batch Pazartesi'ye kesebilir. Kullanıcı bunu bilerek seçti (tek ve öngörülebilir kural). Emsal: FX manuel reeskontu **zaten** `valuationDate.AddDays(1)` yapıyor (`ValuationService.cs:329`) | ✅ **Karar** (2026-08-21) |
| **ADR-MR-028** ⭐ | 🔴 **GRID TAMAMEN CLIENT-SIDE.** Bir `ExecutionDate + Product + SubProduct` kapsamı için **tüm statüler tek istekte** çekilir (`Take = 2000`); statü pill'i, kolon filtresi, sıralama, sayfalama, başlık filtresi (huni) **tarayicıda** uygulanır. `remoteOperations: false`. Ekran artık `Status` ve `Filters` **göndermiyor** (sözleşme alanları duruyor) | **Kullanıcı kararı 2026-08-21.** Kazanç: pill/filtre/sıralama **anında** (ağır sorgu — 4 `COUNT` + sayfa — tekrar koşmuyor) · huni ve kolon sıralaması **doğru** oldu (tarayıcı tüm kümeyi görüyor; `ADR-MR-019`'un yasağının sebebi ortadan kalktı) · ürüne özel (`Data.*`) kolonlar da artık filtrelenip sıralanabiliyor. **Bedeli ve karşılığı:** (a) kapsam 2000 satırı aşarsa liste eksik → ekran **yüksek sesle** uyarır (şerit + notify), sessiz kesme **yok**; (b) veri kapsam boyunca **bayatlar** → fiş kesmenin güvenliği buna dayanmıyor: modül her satırın durumunu yeniden doğrulayıp `STATUS_CHANGED` ile reddediyor (§ 4.5) **ve** Execute'tan sonra önbellek **geçersiz** kılınıyor | ✅ **Karar** (2026-08-21) |
| **ADR-MR-029** | 🔴 **Özet şerit tarayıcıda hesaplanır** (`mrCountStatuses`); sunucunun `StatusSummary` alanı **kullanılmıyor** (sözleşmede duruyor). Sayımlar **kolon filtresi uygulanmış, statü süzgeci uygulanmamış** küme üzerinden | İki kaynak = *"Toplam 248 diyor, grid 3 satır gösteriyor"* çelişkisi (bu işte iki kez yaşandı). Tek kaynak tarayıcı olunca şerit ile grid **asla** ayrışmıyor. Statü süzgecinin sayıma girmemesi bilinçli: pill'ler *"bu filtrede her statüden kaçar var"* sorusunu cevaplamalı | ✅ **Karar** (2026-08-21) |
| **ADR-MR-030** | 🔴 **Host'a özel hiçbir değer bileşenin içinde sabit değildir.** Uygulama kökü (`baseUrl`) ve muhasebe fişi ekranının yolu (`accountingEntryUrl`) **konfigürasyondan** gelir (`mrSetHostSettings` → instance bazında); `settings` global'i yalnız **son çare**. Filtre olayları (`mrOnFilterChanged`/`mrOnProductChanged`) view'da değil **`init.js`**'te yaşar ve instance'ı **`uniqueKey`** ile çözer | Base component denetiminde (kullanıcı isteği 2026-08-21) iki gerçek kusur bulundu: (1) `window.mrInstance` **tek global slot** — aynı sayfada iki instance olursa ikincisi birincinin üzerine yazıyor ve filtre değişimi **yanlış grid**'e gidiyordu (bileşen `uniqueKey` ile çok instance'ı açıkça destekliyor); (2) `AccountingEntry/Index` yolu sabitti — Faz 3'te MicroUI'ye taşınınca **kırılırdı**. ⚠️ Kalan Faz 3 dikişi: `showLoader`/`notify*`/`formatMessage`/`ExcelJS`/`saveAs` platform global'leri — ince bir host adaptörüne alınmalı (bu turda **dokunulmadı**) | ✅ **Karar** (2026-08-21) |
| **ADR-MR-031** ⭐ | 🔴 **Kesilmiş bir fişin tarihi ASLA türetilmez.** Ters fiş varsa valörü `accEntryMain.ValueDate`'den okunur (`ReverseValueDate`); yoksa T+1 **önizlemesi** gösterilir ve **önizleme olduğu görsel olarak belli edilir** (italik/soluk + ipuçu) | **Kullanıcı bulgusu 2026-08-21:** bir satıra **T+0** ile ters fiş kesildi, ekran valör kolonunda **T+1** gösteriyordu — yani **onaylanmış bir muhasebe kaydı hakkında yanlış bilgi**. Sebep: kolon her zaman yanıt seviyesindeki önizlemeyi (T+1 kuralı) yazıyordu; oysa T+0/T+1 seçimi **kullanıcıya ait** ve gerçeği yalnız fiş bilir. 🔑 Genel kural: **geçmiş = kayıttan, gelecek = kuraldan.** Sorgu `Any(...)` (EXISTS) ile yazıldı — required navigation dereference INNER JOIN üretip satır düşürüyor (`MEMORY.md` tuzağı) | ✅ **Karar** (2026-08-21) |
| **ADR-MR-032** | Kolon genişlikleri `width` değil **`minWidth`**; başlıklar sığmazsa CSS ile **iki satıra sarar**, kesinlikle **kirpilmaz**. Bedeli: geniş tabloda yatay kaydırma | Kullanıcı isteği 2026-08-21: *"kolon isimleri tam olarak gözüksün"*. Sabit `width` kolonu kilitliyor ve DevExtreme başlığı `"Vouch..."` / `"Maturit..."` diye kirpiyordu. `minWidth` + `columnAutoWidth: true` ikilisi tabanı korur, kolonu **içerik + başlık** kadar genişletir. Kirpilmış başlık yerine yatay kaydırma **bilinçli** tercih — kullanıcı kolonun ne olduğunu okuyamazsa filtreyi/sıralamayı yanlış kolona uygular | ✅ **Karar** (2026-08-21) |

---

## 4. Yazılacak İşin Repo Dağılımı (v2)

| Repo | İş | Bağımlılık |
|---|---|---|
| **`NetTrex.Web.UI`** | 3 controller + 1 ViewComponent + shared Razor bileşeni (5 view) + **6 JS dosyası** + `IManuelReeskontModuleResolver` + **4 Refit interface** + sözleşme DTO'ları + kolon config JSON'ları + localization (tr/en) + CSS | Sözleşme + C-01/C-02 |
| **`NetTrex.MM`** | 2 endpoint + durum-türetmeli sayfalı sorgu + satır bazlı hata toplama + audit + çift-tıklama guard'ı | Sözleşme (**UI kararından bağımsız → paralel başlayabilir**) |
| **`NetTrex.Fx`** | 2 endpoint — mevcut `RediscountController` sözleşmeye uyarlanacak veya yeni uç | Sözleşme · **kim yazacak? → açık soru** |
| FI · InvFund · (OptFX · Deriv) | 2 endpoint — **ürün ekipleri** | Sözleşme + kolon config teslimi |
| ~~`NetTrex.Common`~~ | ❌ **İŞ YOK** — ADR-MR-015 | — |
| ~~`Treasy.MicroUI.Packages`~~ | ⏸️ **Faz 3** — ADR-MR-017 | Faz 1 bitmeli |

> 🔑 **İki iş paralel başlayabilir:** Web.UI base component ve MM'in 2 endpoint'i.
> İkisini de bağlayan tek şey **`06-sozlesme.md`**.

---

## 5. Riskler (v2)

| # | Risk | Etki | Azaltma |
|---|---|---|---|
| **R-01** | Doküman **iki tasarım nesli** taşıyor (C-01) | 🔴 Yüksek | İş birimine sor, sözleşmeyi **kod öncesi dondur**. ⚠️ Eski Fx ekranında `RediscountStatusTypes.**All**` **VAR** → "All var" tarafına kanıt |
| **R-02** | `executions` senkron mu asenkron mu belirsiz (C-07) | 🔴 Yüksek | 248 kayıt × senkron Fimple = timeout. **v2'de Common'ın 10 dk Refit timeout'u da yok** → WebUI Refit timeout'u **doğrulanmalı** (`F-16`) |
| **R-03** | ♻️ Kısmi hata: `ajax.js` `IsSuccess === false → null` (hata yutulur) + `Load`'un iki-şekilli response'u | 🔴 Yüksek | ADR-MR-008 — tek tip response şekli, `ajax.js`'e güvenme |
| **R-04** | WebUI → modül çağrısında token durumu **doğrulanmadı** (`F-13`) → audit/`StateMaker` boş kalabilir | 🟠 Orta | ADR-MR-012 (`CurrentUserId` her durumda güvenli) |
| **R-05** | ~~Fund/InvFund Common'da hiç yok~~ → v2'de **`IClientFundsAPI` WebUI'de HAZIR** | ✅ Kapandı | `Startup.cs:66` |
| **R-06** | Select All (tüm veri kümesi) ↔ `TransactionIds` çelişkisi (C-10) | 🟠 Orta | Sözleşmeye `SelectAll` + filtre alanları |
| **R-07** | Mevcut FX ekranı paralel yaşarsa aynı transaction'a iki yerden fiş kesilebilir (C-20) | 🟠 Orta | İş birimi kararı. Yeni klasör (`ManuelReeskont`) eskiye (`ManuelReescont`) dokunmuyor → paralel yaşam **teknik olarak mümkün** |
| **R-08** | Diğer modüllerde (FX ✅, MM ✅ dışında) ters fiş deseni **doğrulanmadı** | 🟠 Orta | O ekiplerin işi ama sözleşme tutarlılığı riski |
| **R-09** | Enum drift (`F-09`) yeni ekranda tekrarlanabilir | 🟡 Düşük | ADR-MR-011 (string) |
| **R-10** | Kolon config UI'de → yeni ürün eklemek UI deploy'u gerektiriyor (C-15) | 🟡 Düşük | Faz 1'de kabul; Faz 2'de uzaktan servis etme opsiyonu (`columns.url` config'te **hazır** bırakılıyor) |
| **R-11** ⭐ | **v2'ye özel:** sözleşme DTO'ları Web.UI'de yaşıyor, her modül kendi kopyasını tutuyor → **sürüm sapması** (bir modül alan ekler, UI bilmez) | 🟠 Orta | `06-sozlesme.md` **tek gerçek kaynak**; alan eklemede cross-repo etki zinciri yazılacak (workspace Hard Rule 9) |
| **R-12** ⭐ | **v2'ye özel:** Faz 3'te pakete taşırken component Web.UI global'lerine bağımlı çıkarsa taşıma pahalanır | 🟠 Orta | §2.5'teki 4 taşınabilirlik kuralı Faz 1'de uygulanacak |

---

## 6. Doğrulanacaklar (v2 ile açılan yeni boşluklar)

| # | Ne | Neden önemli |
|---|---|---|
| **F-13** | WebUI → modül Refit çağrısında **bearer token taşınıyor mu?** (`RegisterClientWebApiRefitClients` içi okunmadı) | Audit / `StateMaker` / yetki. ADR-MR-012 bunu by-pass ediyor ama bilinmesi gerek |
| **F-14** | WebUI'den **`General:AvailableModules`** framework parametresi okunabiliyor mu? (`IFrameworkParameterHelper` ile) | Kapalı modülün fan-out'a girmemesi (ADR-MR-013) |
| **F-15** | WebUI'de Common'ın `ModuleConstants` karşılığı **var mı?** | `moduleCode` sabitleri nereden gelecek |
| **F-16** | WebUI Refit **timeout** değeri nedir? (Common'da 10 dk idi) | `executions` senkron olursa (C-07) timeout kritik |
| **F-17** | `Views/Shared/Components/{CashFlow,LimitCheck}/Default.cshtml` **okunmadı** | Hidden alan + widget yerleşimi kodlanırken gerekli |
| **F-18** | `ManuelReescontApi` service wrapper'ının içi **okunmadı** (hangi marker, hangi endpoint'ler) | Eski ekranın Fx ucu sözleşmeye uyarlanacaksa gerekli |
