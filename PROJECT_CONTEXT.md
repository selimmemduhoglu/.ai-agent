# PROJECT_CONTEXT.md — Treasy / NetTrex Genel Mimari

> **Workspace katmanı.** Tüm platformun topolojisi: hangi modül hangi repoda, ne konuşuyor, hangi porttan.
> Her oturumda `repos/CLAUDE.md`'den `@import` ile **otomatik yüklenir** → **kısa ve yüksek-sinyal** tut.
> Repo-içi mimari detay o reponun kendi `.ai-agent/PROJECT_CONTEXT.md`'sinde.
>
> **Son Güncelleme:** 2026-08-12

---

## 1. Platform Nedir

**Treasy / NetTrex** = katılım + yatırım bankaları için **treasury (hazine) platformu**.
Modüler: her finansal ürün ailesi kendi **backend mikroservisi**, ekranlar ya monolit UI'de ya kendi **Micro UI**'sinde.
Dış dünyaya bağlantı: **Fimple** (core banking / resmi defter) · **Kafka** · **Bloomberg** · **SWIFT**.

**Stack:** .NET 10 · EF Core · Refit · MediatR (`Netix.Core.Handler`) · FluentValidation · Scrutor · Mapster/AutoMapper
· ASP.NET MVC + jQuery + **DevExtreme 22.2.6** (UI) · Vite + TypeScript (Micro UI) · Kubernetes + Helm

---

## 2. Modül → Repo → API Haritası

| Modül | Backend repo | Web.UI config key | Web.UI Refit marker | Micro UI |
|-------|--------------|-------------------|---------------------|----------|
| **Common** (ortak/referans) | `NetTrex.Common` | `CommonApi` | `IClientCommonAPI` | — (paket layout'u) |
| **MM** (Money Market + InterbankLoan + IssueBond) | `NetTrex.MM` | `MMApi` | **`IClientMMAPI`** ⚠️ | `Treasy.MM.UI` |
| **FX** (+ PM / kıymetli maden) | `NetTrex.Fx` | `FXApi` | `IClientFxAPI` | ❌ |
| **FI** (Fixed Income) | *(tespit edilmedi — doğrulanacak)* | `FIApi` | `IClientFiAPI` | ❌ |
| **OptFX** (FX Opsiyon) | `NetTrex.OptionsFX` | `OptFXApi` | **`IClientOptFXApi`** ⚠️ | `Treasy.OptionsFX.UI` |
| **DerivSWP** (Türev/Swap) | `NetTrex.DerivSwp` | `DerivSwpApi` | `IClientDerivSWPAPI` | `Treasy.MicroUI.Deriv` |
| **InvFund** (Yatırım Fonu) | `NetTrex.InvFund` | `FundsApi` | **`IClientFundsAPI`** ⚠️ | ❌ |
| **Warrant** | *(tespit edilmedi)* | `WarrantApi` | `IClientWarrantAPI` | ❌ |
| **Accounting** | `NetTrex.Accounting` | `AccountingApi` | `IClientAccountingAPI` | ❌ |
| **Limit** | *(tespit edilmedi)* | `LimitApi` | `IClientLimitApi` | ❌ |

Her modülün ayrıca `*BatchApi` muadili var (`MMBatchApi`, `FXBatchApi`, …).

> ⚠️ **Marker isimleri tutarsız** — dosya adı ≠ tip adı. Yeni client yazarken tip adını **dosya içinden** doğrula.
> `IClientOptionsApi` / `IClientFundApi` diye bir tip **yok**.

---

## 3. Topoloji — Kim Kimi Çağırıyor

```
                       ┌──────────────┐
   Kullanıcı ─────────►│ Treasy.Shell │  (Micro UI host, port 5206)
                       │  YARP proxy  │  route prefix = micro code (/mm/... → /...)
                       └───┬──────┬───┘
                           │      │
            ┌──────────────┘      └──────────────┐
            ▼                                     ▼
   ┌─────────────────┐                  ┌───────────────────┐
   │ Treasy.MM.UI    │ 5104/6104        │ Treasy.OptionsFX  │
   │ Treasy.Deriv    │                  │ .UI               │
   └────────┬────────┘                  └─────────┬─────────┘
            │ Refit (IClientMmApi → MMApi)         │
            │                                      │
   Kullanıcı ──────► NetTrex.Web.UI (monolit, :5032) ─────────┐
                            │ Refit, 19 marker              │
                            │                               │
      ┌─────────────────────┼───────────────────────────────┐│
      ▼                     ▼                               ▼▼
  NetTrex.Common ────► modül API'leri (fan-out, Refit)   modül API'leri (doğrudan)
  (CommonApi)          MM · FX · FI · Deriv · OptFX      MM · FX · FI · Funds · …
      │                       │
      │                       ▼
      └──────────────────► Fimple (core banking) · Kafka · Bloomberg · SWIFT
```

**Üç farklı çağrı yolu var — hangisi ne zaman:**

| Yol | Ne zaman | Örnek |
|-----|----------|-------|
| **Web.UI → modül API** (doğrudan) | Ekran **tek modüle** ait | `MmTransactionController` → `IClientMMAPI` |
| **Web.UI → Common → modüller** (fan-out) | Ekran **cross-module** ve fan-out'un başka çağıranlarca da (MicroUI, dış sistem) kullanılması bekleniyor | `DailyFlowV2Controller` → `IClientCommonAPI` → Common'da `Task.WhenAll` |
| **Web.UI → çok modül** (doğrudan fan-out) | Ekran cross-module ama fan-out **yalnız o ekrana ait**; bir hop eksiltmek isteniyor | **Manuel Reeskont** (`ADR-MR-015`, 2026-08-12) — controller/service'te `Task.WhenAll` + modül-başına `try/catch` |

> 🔑 **ADR-WS-001 (aşağıda):** Cross-module ekran **genelde** Common üzerinden fan-out eder.
> ⚠️ **Bilinen istisna:** Manuel Reeskont. Kullanıcı kararıyla Common çıkarıldı; teknik dayanak: 4 modülün
> Refit marker'ı Web.UI'de **zaten kayıtlı** (`Trex.WebUI/Startup.cs:58-75`) ve
> `RegisterClientWebApiRefitClients<T>` AppDomain'i taradığı için **yeni DI kaydı/config key gerekmiyor**.
> **Bedeli:** fan-out yeniden kullanılamaz + sözleşme DTO'ları UI'de yaşar (sürüm sapma riski).
> Yeni bir cross-module ekranda hangi yolu seçeceğine bu ödünleşmeye bakarak karar ver.

**Cluster:** modül API'leri `192.168.10.191` üzerinde NodePort'lu (Web.UI `appsettings.json:91-109`).
Common → modül çağrıları cluster-internal (`http://nettrex-mm-web:5041/api`).

---

## 4. Micro UI Mimarisi

- **`Treasy.Shell`** — host. **iframe değil, MVC area değil** → **YARP reverse proxy + HTML response rewrite**
  (`MicroFrontendHtmlRewriteMiddleware`). Port `5206`.
  Kayıt **2 yerde**: `MicroFrontends:Services` (code, baseAddress, `/Discovery/Info`, `/Discovery/Health`) +
  `ReverseProxy:Routes/Clusters`. **Route prefix = `code`**.
- **`Treasy.MicroUI.Packages`** — **1 C# paketi + 12 npm paketi**:
  - `Treasy.MicroUI.SharedDependency` — **RCL** (`AddRazorSupportForMvc`). Layout, middleware'ler, `ControllerBase`,
    hazır controller'lar (Login/Menu/Calendar/LimitCheck/Discovery.Health/Error), DevExtreme helper'ları + DLL/JS/CSS,
    `treasy-script` TagHelper, Vite + localization bundler MSBuild target'ları, **10 adet grid'li ortak ViewComponent**.
    Asset kökü: `~/_content/Treasy.MicroUI.SharedDependency`.
    🔑 **Paketten TAM EKRAN çıkabiliyor** (precedent: `Views/Shared/Pages/Login/Index.cshtml`).
  - npm: `@treasy/{authorization,builders,components,constants,context,enums,flow,formatters,helpers,identifiers-and-selectors,notification,translation}`
    → Nexus `192.168.10.241:8081/repository/treasy-npm/`
- **Menü** Discovery'den değil, `SharedDependency/MenuController` → **Common API** `GetModuleMenu`'den gelir (kullanıcıya göre filtreli).
- **Micro UI portları:** `Treasy.MM.UI` web `5104` / vite `6104` (konvansiyon: `51xx` ↔ `61xx`, son iki hane aynı).

---

## 5. Yetkilendirme

| Katman | Mekanizma |
|--------|-----------|
| **`NetTrex.Web.UI`** | `BaseController` üstünde `[CustomAuthorize]` (policy `"Dynamic"`) → `PermissionHandler` → **`HasPermissionAsync(controllerName, actionName)`**. 🔴 **Permission = ControllerAdı/ActionAdı** → ekran bazlı yetki için **ekran başına ayrı controller** gerekir |
| **Micro UI** | Aynı `CustomAuthorize`/`PermissionHandler` altyapısı **pakette var** ama 🔴 `Treasy.MM.UI`'de **hiç kullanılmıyor** — erişim fiilen **menü** üzerinden. Shell'de `SkipAuthorization: true` |
| **Modül API** | Netix.Core global policy + scope-based `HasScopeHandler`; controller'larda açık `[Authorize]` **tespit edilmedi** |
| **Common → modül** | 🔴 **Token TAŞINMIYOR** — çağrılar anonim/cluster-internal. Kullanıcı kimliği **request body'deki `CurrentUserId`** ile taşınır (`entity.StateMaker = request.CurrentUserId` deseni) |

---

## 6. Aktif Modül Keşfi

Hangi modüllerin **o müşteride** kurulu olduğu framework parametresinden gelir:

```
General:AvailableModules        →  ";" ayraçlı liste, BatchModuleType enum adlarıyla eşleşir
```
Okuyucu: `NetTrex.Common.Operations/GeneralAvailableModules/GeneralAvailableModulesOperation.cs:15-46`
Sabitler: `NetTrex.Common.Core/Constants/ModuleConstants.cs` → `COMMON, FX, FI, MM, DERIVSWP, INVFUND, OPTFX`
Enum: `NetTrex.Common.Model/Enums/Eod/BatchModuleType.cs` → `FI=1, FX=2, Common=3, MM=4, DerivSWP=5, InvFund=6, OptFX=9, Limit=10`

**Modül-içi opsiyonel özellikler** ayrı flag'lerle: MM'de `InterbankLoan:Enabled` (kapalı müşteride **TxnLoan tablosu DB'de yok**),
`feature:Tawarruq:Enable`. Cross-module bir ekran **iki katmanı da** kontrol etmeli.

---

## 7. ADR (Workspace)

### ADR-WS-001 — Cross-module ekran fan-out'u `NetTrex.Common`'da yapılır

- **Karar:** Birden çok modülün verisini/işlemini tek ekranda birleştiren bir ekran, UI controller'da modül
  switch'i yapmaz. UI **tek uç**a gider (`: IClientCommonAPI`), fan-out `NetTrex.Common`'da
  **Strategy + Factory + `Task.WhenAll`** ile yapılır.
- **Kanıt/precedent:** `DailyFlowV2` (`DailyFlowStrategyFactory` + `DailyFlowV2Operation`), `ReconciliationTransaction`.
- **Gerekçe:** Web.UI'de **runtime base-URL resolver yok** (Refit marker'ları compile-time bağlı) · tarayıcı hiçbir
  modül adresi bilmez (CORS/token yok) · yeni modül UI'de değişiklik gerektirmez · Common zaten WebUI'nin en geniş
  yüzeyi (86 interface / ~740 endpoint).
- **Sonuç:** Yeni cross-module ekranda **Common'a controller+handler+operation+strategy factory** yazılır; modül
  Refit client'ına 1-2 metot eklenir (yeni interface/DI/config key **gerekmez** — `IClientBaseAPI` otomatik kayıt).
- **Bilinen tuzaklar:** `Task.WhenAll` **kısmi hata toplamıyor** (modül-başına `try/catch` şart) ·
  `.ToContentGeneral()` hatayı **yutuyor** (`result.Error is not null → throw` kullan) ·
  **InvFund için Refit client yok** · Common→modül çağrısında **token yok** (`CurrentUserId` body'de).

### ADR-WS-002 — Modüller arası ortak UI bileşeni pakete taşınır

- **Karar:** İkiden fazla modülün kullanacağı bir UI bileşeni `Treasy.MicroUI.SharedDependency`
  (Razor + ViewComponent) + `@treasy/components` (TS) üzerinden dağıtılır.
- **Kapsam eşiği:** tek ekran → o ekranın klasörü · tek modülde ortak → o modülün `Views/Shared/Components/` ·
  **modüller arası → pakete** (sürüm bump + Nexus publish).
- **Precedent:** `Payment`, `CustomerAccounts`, `Amortization`, `LimitCheck`, `AdvanceAndStateFilter`, `TransactionNote`.
- **Not:** Monolit `NetTrex.Web.UI`'nin muadil deseni `Views/Shared/Components/<Ad>/` + `ViewComponents/` +
  `wwwroot/js/shared/components/<ad>/` (örnek: `CashFlow` — DevExtreme grid'li, `LimitCheck` — modül parametreli).

---

## 8. Repo Haritası (kısa)

```
repos/
├── NetTrex.Common       Ortak/referans veri · menü · parametre · rate engine · CROSS-MODULE FAN-OUT
├── NetTrex.MM           Money Market + InterbankLoan + IssueBond      (Api 5041 · Batch 5043 · Consumer 5044)
├── NetTrex.Fx           FX + PM
├── NetTrex.OptionsFX    FX Opsiyon
├── NetTrex.DerivSwp     Türev / Swap
├── NetTrex.InvFund      Yatırım Fonu
├── NetTrex.Accounting   Muhasebe motoru
├── NetTrex.Web.UI       MONOLİT UI (Trex.WebUI, :5032) — tüm modüllerin ekranları
├── Treasy.Shell         Micro UI host (YARP, :5206)
├── Treasy.MicroUI.Packages   SharedDependency (RCL, 1.0.4-dev12) + 12 npm paketi
├── Treasy.MicroUI.Base       Micro UI iskeleti + sıfırdan kurma rehberi
├── Treasy.MM.UI              MM Micro UI (5104/6104)
├── Treasy.OptionsFX.UI       OptionsFX Micro UI (ilk örnek, pattern referansı)
├── Treasy.MicroUI.Deriv      Deriv Micro UI
├── PlayWright                E2E test paketi
└── ai-agent-context-kit      Bu md metodolojisinin kaynağı
```

---

## 10. Çalışma tarzı — kod yorumu ve yanıt formatı (2026-09-22, sıkılaştırıldı 2026-09-29)

**Kod yorumu — NADİR ve KISA (kullanıcı 2026-09-29'da tekrar uyardı: "çok yazıyorsun"):**
- Varsayılan: yorum YOK. Yalnız NEDEN koddan çıkarılamıyorsa (bir hatayı/tuzağı önlüyor) tek satır yaz.
- Kodun NE yaptığını anlatan yorum yazma — isimler zaten söylüyor. Çok satırlı gerekçe blokları yazma.
- `<summary>`/`<remarks>` XML doc etiketleri VARSAYILAN YOK. Gerekiyorsa tek satır.
- 🔴 **İş/PO kararı referansı koda HİÇ girmez:** "PO isteği", "PO kararı", "PO sunumu", "(PO 2026-..)", tarihli karar
  notu, "kullanıcı istedi" vb. — ne yorumda ne string'de. O bilgi progress/MD dosyalarının ve commit mesajının yeridir.
- Emoji (🔴/⚠️ vb.) koda girmez.
- Subagent/ajan görevlendirirken bu kuralı prompt'a AÇIKÇA yaz — ajanlar bu dosyayı okumuyor.
- Manuel Reeskont kodundaki eski "PO ..." referansları 2026-09-29'da temizlendi; yenisi eklenmez.

**Yanıt formatı — teknik açıklama zorunlu:**
- Kullanıcı yazılımcı; her yanıt neyin yapıldığını ve HANGİ TEKNİK/DESENLE yapıldığını açıklar (ör. race condition, flex-grow ile konumlandırma, Refit base interface convention'ı).
- Terse üslup korunur (fazlalık yok) ama teknik derinlik atlanmaz.

---

## 9. Doğrulanacaklar (tespit edilmedi)

| Konu | Not |
|------|-----|
| **FI** modülünün backend reposu | `FIApi` config key'i var ama `NetTrex.FI` diye repo yok |
| **Warrant** modülünün backend reposu | `WarrantApi` var, repo yok |
| **Limit** modülünün backend reposu | `LimitApi` var, repo yok (`Treasy.MM.UI`'de port 5095 geçiyor) |
| `Treasy.Shell` ↔ `NetTrex.Web.UI` ilişkisi | Shell monolit ekranlara da proxy yapıyor mu, yoksa sadece Micro UI'lere mi? |
