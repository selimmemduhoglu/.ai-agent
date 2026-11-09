# progress-13 — 🔤 KOD ADI İNGİLİZCELEŞTİ: `ManuelReeskont` → `ManualRediscount` · ölü modül client'ları silindi

**Tarih:** 2026-08-13 · **Önceki:** [progress-12.md](progress-12.md)
**Tetikleyen istek:** Kullanıcının 4 sorusu — (1) IssueBond soyutlaması var mı, silinsin mi ·
(2) *"reeskont kelimesi türkçe bir kelime mi… Reeskont yerine başka bir kelime mi kullansak"* ·
(3) *"bu kadar dinamik yapmaya gerek yok sanki ne diyorsun"* (modül resolver) ·
(4) *"önceki manuel reeskont ile karıştırılmasın… bu yeni ismimizin aynı olması sorun olmaz mı"*

**Kullanıcı kararları:** ✅ **`ManualRediscount`** (İngilizce) · ✅ FX/FI/InvFund client'ları **silinsin**, MM kalsın.

```text
=== MM ===
dotnet build Code\NetTrex.MM.sln                                       → 0 Error(s)
NetTrex.MM.Api.Services.Tests.exe -namespace "*ManualRediscount*"      → Total: 74, Errors: 0, Failed: 0

=== Web.UI ===
dotnet build Code/Web/UI/Trex.WebUI/Trex.WebUI.csproj                  → 0 Error(s)
npx jest --testPathPattern manualRediscount                            → 34 passed
npx jest  (tüm suite)                                                  → 334 passed
```

⚠️ **progress-12'deki "tüm suite 368" YANLIŞTI** — doğrusu **334** (bizim 34 test o toplamın içinde;
yanlışlıkla iki kez saymıştım). Living doc'lar (`00-PANO`, `09-…-raporu`) düzeltildi.

---

## 1. Soru 1 — IssueBond soyutlaması

**Bulgu: soyutlama YOK, silinecek bir katman yok.** Manuel Reeskont kodunda IssueBond'a 3 dokunuş var:

| Yer | Ne | Karar |
|---|---|---|
| `TransactionDataManager.cs:43-46` | `x.TxnMmProductTypeId != ProductAccountingCodeType.ISSUE` — **dışlama filtresi** | 🔴 **KALIYOR** |
| `EligibleTransactionsHandler.ResolveRevaluationType` | Yorum: `RevaluationReverseType` enum'ı `Api.IssueBond`'da, referans **verilmiyor**, değer elle eşleniyor | Kalıyor (yorum) |
| `EligibleTransactionsRequest.cs` XML doc | `IssueBondSelectRequest`'i `IQueryFilterRequest` emsali olarak anıyor | Kalıyor (yorum) |

**Filtre neden silinmedi:** progress-8'de yakalanan bug'ın fix'i — o satır olmadan `TISBRW…` referanslı
tahvil işlemleri MM ekranında **görünüyordu**. IssueBond kalktığında filtre kendiliğinden no-op olur;
`ProductAccountingCodeType.ISSUE` enum değeri silindiği gün **derleme hatası verip kendini hatırlatır**.
Bugün silmek çalışan bir davranışı geri almak olurdu.

## 2. Soru 2 — "Reeskont" Türkçe mi?

`Reeskont` Fransızca *réescompte*'tan gelme Türkçe kelime; İngilizce karşılığı **rediscount** — gerçek
finans terimi (Fed'in "rediscount rate"i). Yani İngilizceleştirmek uydurma değil, **doğru terime geçmek**.

`ManualRevaluation` **seçilmedi**: eski FX ekranının controller'ı zaten `ManuelRevaluationController`
(`Controllers/ManuelReescont/`) — isim benzerliği sürerdi. `ManualRediscount` ayrıca kodda **zaten** var
olan `RediscountStatus` / `RediscountOperation` / `RediscountReasonCodes` ile hizalanıyor.

**Zamanlama gerekçesi:** menü + permission scriptleri **henüz uygulanmamıştı** → permission adlarını
sonradan düzeltme maliyeti doğmadan yapıldı.

## 3. Soru 3 — modül resolver fazla mı dinamik?

**Ayrım yapıldı:** resolver (20 satır) base component'in modül-agnostikliğinin **tek** taşıyıcısı → kaldı.
Karşılığı olmayan 3 adaptör + 3 Refit arayüzü **silindi**.

**Somut kazanç:** eskiden Security ekranı FI'ya gidiyor → **404** → *"modüle erişilemedi: …"* (yanıltıcı).
Şimdi resolver `null` dönüyor → *"'FI' modülü için Manuel Reeskont ucu tanımlı değil."*

Silinen: `IManualRediscountModuleApis.cs` (3 arayüz) + `Fx/Fi/InvFund…ModuleClient` sınıfları + 3 DI satırı.
Geri ekleme şablonu `ManualRediscountModuleResolver.cs` başındaki yorumda **adım adım** duruyor.

## 4. Soru 4 — eski ekranla çakışma

Runtime çakışması yoktu (route/permission ayrı) ama klasör adları **tek harf** farklıydı
(`ManuelRee**sc**ont` ↔ `ManuelRee**sk**ont`). Rename bunu tamamen bitirdi.

### 🔴 Rename sırasında GERÇEK bir çakışma çıktı

`ManualRediscount` adı **zaten kullanılıyordu**: `Trex.Common.Models.Enums.ManualRediscount` — eski
FX/FI reeskont ekranlarının **nested enum kabı sınıfı** (`RediscountProductTypes`, `RediscountStatusTypes`).

Yeni **namespace** segmenti (`…Models.ManualRediscount`, `Trex.WebUI.Controllers.ManualRediscount`) o
sınıfın basit adını gölgeledi; C# namespace'i önce çözdüğü için eski dosyalar **14 hata** verdi:

```text
error CS0234: The type or namespace name 'RediscountProductTypes' does not exist in the
namespace 'Trex.Web.Business.Models.Models.ManualRediscount'
error CS0234: … does not exist in the namespace 'Trex.WebUI.Controllers.ManualRediscount'
```

**Çözüm:** eski 4 dosyada 13 satır **tam nitelendirildi**
(`ManualRediscount.RediscountX` → `Trex.Common.Models.Enums.ManualRediscount.RediscountX`).
Sadece tip niteleme; davranış değişmedi. Dosyalar: `SecurityManuelReescontSelectRequest.cs` ·
`CreateReescontRequest.cs` · `ManuelReescontSelectReqest.cs` · `ManuelRevaluationController.cs`.

> **Ders:** yeni bir namespace segmenti seçerken aynı adda **sınıf** olup olmadığı da kontrol edilmeli —
> namespace, using ile gelen sınıf adını gölgeler ve hata **başka dosyalarda** patlar.

---

## 5. Yeni ↔ eski ad haritası

### NetTrex.MM

| Eski | Yeni |
|---|---|
| `Api.ResponseRequest/ManuelReeskont/` | `Api.ResponseRequest/ManualRediscount/` |
| `Api.Services/ManuelReeskont/` | `Api.Services/ManualRediscount/` |
| `Api/Controllers/ManuelReeskont/ManuelReeskontController.cs` | `…/ManualRediscount/ManualRediscountController.cs` |
| `ManuelReeskontEnums.cs` | `ManualRediscountEnums.cs` |
| `ManuelReeskontItem` · `ManuelReeskontStatusSummary` | `ManualRediscountItem` · `ManualRediscountStatusSummary` |
| `ReeskontReasonCodes` | `RediscountReasonCodes` |
| 🔴 `POST api/manuel-reeskont/{eligible-transactions,executions}` | 🔴 `POST api/manual-rediscount/{…}` |
| `UnitTest/…/ManuelReeskont/` | `UnitTest/…/ManualRediscount/` |

### NetTrex.Web.UI

| Eski | Yeni |
|---|---|
| `Models/ManuelReeskont/` | `Models/ManualRediscount/` |
| `Controllers/ManuelReeskont/ReeskontControllerBase.cs` | `Controllers/ManualRediscount/RediscountControllerBase.cs` |
| 🔴 `TreasuryReeskont` · `SecurityReeskont` · `InvestmentReeskont` (controller + **permission** + **menü**) | 🔴 `TreasuryRediscount` · `SecurityRediscount` · `InvestmentRediscount` |
| `Services/ManuelReeskont/` (5 dosya) | `Services/ManualRediscount/` (4 dosya — biri silindi) |
| `ViewComponents/…/ManuelReeskontViewComponent` | `…/ManualRediscountViewComponent` |
| `Extensions/ManuelReeskont/…` · `Html.DevExtreme().ManuelReeskont()` | `Extensions/ManualRediscount/…` · `Html.DevExtreme().ManualRediscount()` |
| `Views/ManuelReeskont/{Treasury,Security,Investment}/` | `Views/ManualRediscount/…` |
| `Views/Shared/Components/ManuelReeskont/Default.cshtml` | `…/Components/ManualRediscount/Default.cshtml` |
| `wwwroot/js/shared/components/manuel-reeskont/manuel-reeskont.*.js` (8) | `…/manual-rediscount/manual-rediscount.*.js` (8) |
| `wwwroot/js/config/manuel-reeskont/*.json` | `wwwroot/js/config/manual-rediscount/*.json` |
| `localization/pages/manuel-reeskont/manuel-reeskont-{tr,en}.json` | `…/manual-rediscount/manual-rediscount-{tr,en}.json` |
| `css/shared/components/manuel-reeskont.css` | `…/manual-rediscount.css` |
| JS global `ManuelReeskont.init()` · `ManuelReeskontComponent` | `ManualRediscount.init()` · `ManualRediscountComponent` |
| `JSTests/manuelReeskontComponent.test.js` | `JSTests/manualRediscountComponent.test.js` |

**Değişmeyenler:** `mr-` / `MR_` JS önekleri (Manual Rediscount'a da uyuyor) · localization anahtarları
(`mr-col-*`, `mr-status-*` …) · `RediscountStatus` / `RediscountOperation` enum'ları · Türkçe menü
etiketleri (*"Manuel Reeskont - Hazine"* vb.) · `.ai-agent/manuel-reeskont/` **doküman klasörü**
(iş adı Türkçe kalıyor; kod adı İngilizce — bilinçli ayrım).

### SQL scriptleri (⚠️ **yeniden adlandırıldı — eskisini uygulama**)

| Eski | Yeni |
|---|---|
| `outputs/2026-08-13-ManuelReeskont-Menu-Script.sql` | `outputs/2026-08-13-ManualRediscount-Menu-Script.sql` |
| `outputs/2026-08-13-ManuelReeskont-Permission-Script.sql` | `outputs/2026-08-13-ManualRediscount-Permission-Script.sql` |

İçerik: `MenuKey` → `TreasuryRediscountKey` … · `ControllerAction` → `TreasuryRediscount/Index` … ·
permission adları → `TreasuryRediscount_Displayer` / `_Maker` …

---

## 6. Doğrulanan / açık

✅ Localization bundle (`wwwroot/bundles/localization/{tr,en}.json`) build ile **otomatik** yenilendi —
yeni `mr-*` anahtarları (`mr-col-Product`, `mr-summary-Total`, `mr-select-All`) bundle'da **var**.

⚠️ **Tarayıcı testinde yeni URL:** `/TreasuryRediscount/Index` (eskisi `/TreasuryReeskont/Index`).

⚠️ Rename **derleme + birim test** ile doğrulandı; **tarayıcıda çalıştırılmadı**. Razor runtime
compilation açık olduğu için view yolları derlemede de kontrol edildi (0 error), ama asset yolları
(`~/js/shared/components/manual-rediscount/…`) yalnız çalışma anında doğrulanır → ekran testinde
F12 → Network'te **404 olmadığını** kontrol et.

Açık kalemler değişmedi → [progress-12.md § 5](progress-12.md).
