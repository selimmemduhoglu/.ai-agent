# Swap & Money Market Raporu — Analiz (AD-8945)

> Tarih: 2026-09-25 · Branch (3 repo): `main-swap-mm-report-development` (main'den, güncel)
> Repolar: `Treasy.Common.UI` · `NetTrex.MM` · `NetTrex.Fx` — WebUI YOK (v1.37 ile Common.UI)
> Referans mimari: Manuel Reeskont (Common.UI `Controllers/ManualRediscount/` + `12-modul-yayilim-rehberi.md`)
> 🔴 **2026-09-26:** Bu analizdeki `SwapMmReport` / `swap-mm-report` adları uygulamada **`MaturityReport` / `maturity-report`** oldu, branch `main-maturity-report-development`. Güncel durum → **§ 10**.

---

## 1. İş tanımı (kaynaklar birleştirilmiş)

| Kaynak | Ne diyor |
|---|---|
| Jira AD-8945 metni | Swap + MM için tarih filtreli rapor. İki "between" filtre: **Input Date** ve **Maturity Date**. Sol boş → `≤ sağ`, sağ boş → `≥ sol`. Filtre sonrası belirlenen formatta export. |
| Kullanıcı yorumu | Input Date = bizim **ValueDate**. Ürünler: **Money Market**, **Interbank Loan**, **FX/PM Swap** (3 ürün, hard-coded). Ürün seçilince o modüle istek, kolonlar ürüne göre değişir (MR'deki JSON config). |
| Görsel 1 (01.09.2025) — SWAP | Karşı Kurum · Toplam Tutar · Başlangıç · Bitiş · Orijinal Vade (gün) · Vadeye Kalan (gün, negatif olabilir) · Oran · Getiri Tutarı · Satılan Döviz · Alınan Döviz |
| Görsel 2 (01.09.2025) — MONEY MARKET | Karşı Kurum · Tutar · Başlangıç · Bitiş · Orijinal Vade · Vadeye Kalan (−28 → vadesi geçmiş işlem de listede) · Getiri Oranı · Getiri Tutarı |
| Jira yorumu (07.04.2026) + `Swap Raporu.xlsx` | 🔴 **Gruplama kuralı:** aynı karşı kurum + aynı parite + aynı başlangıç + aynı bitiş + aynı yön → tek satır; alınan/satılan tutar **toplam**, oran **ağırlıklı ortalama**. Excel ayrıca daha zengin kolon + filtre seti öneriyor (§ 1.1). |

### 1.1 Excel'in (Nisan 2026) görsellerden farkı

**Filtreler:** 1) Input Date aralığı · 2) Near Maturity Date aralığı · 3) Far Maturity Date aralığı · 4) Parite (tümü/seçim) · 5) "Açık Swap İşlemleri" as-of tarihi (diğer filtreleri ezer: `near ≤ D AND far > D`).

**Swap kolonları:** Karşı Kurum · Parite · İşlem Yönü (B/S, S/B) · Baz Tutar Near (OZ) · Baz Tutar Near (Gr) · Baz Olmayan Tutar (Near) · Near Maturity · Far Maturity · Orijinal Vade Gün · Vadeye Kalan (`Far − Today`) · Swap Oranı · Kar(+)/Zarar(−) · Swap Tipi (FX Swap / PM Swap).

**Formüller (Excel hücrelerinden okundu):**
```
ForwardRate   = Spot + SwapPoints / 10000   (FX)   | / 100 (PM)   → pratikte far leg DealRate
SwapOranı     = (Forward / Spot − 1) / Gün × 360
Kar/Zarar     = −(BazOlmayanTutarNear × OrijinalVadeGün × SwapOranı) / 360
```
Görsel 1 doğrulaması: 406.700.000 × %99 × 182 / 360 = **203.553.350** ✅ (Getiri Tutarı = aynı formül, işaretsiz).
Görsel 2 doğrulaması: 200.000.000 × %41,75 × 3 / **365** = **686.301** ✅ → MM getirisi 360 değil, işlemin kendi baz günüyle **saklanan faiz tutarı**.

---

## 2. Manuel Reeskont'tan devralınan yapı

```
Tarayıcı (TS)  ──POST {Controller}/Load──►  Common.UI MVC Controller
   ▲  JSON config (ürün → kolonlar)              │  ModuleCode → Refit client seç
   │  hidden input ile sayfaya basılır           ▼
   │                                   MM modülü  /api/...   FX modülü  /api/...
   └──── { data:[{ sabit alanlar, Data:{…} }] } ◄┘  (her modül kendi repo pattern'i)
```

| MR parçası | Dosya | Bu işte karşılığı |
|---|---|---|
| Ürün listesi hard-coded + `ModuleCode` | `TreasuryRediscountController.GetProducts()` | 3 ürün: `MoneyMarket`/MM, `InterbankLoan`/MM, `FxPmSwap`/FX |
| Modül fan-out | `RediscountControllerBase.ResolveModuleApi` | aynı switch (MM, FX) |
| Refit sözleşmesi | `IManualRediscountApi` + `IManualRediscountMmApi : IClientMmApi` | `ISwapMmReportApi` + `…MmApi : IClientMmApi` + `…FxApi : IClientFxApi` (Treasy.Pure marker → **DI kaydı yok**) |
| Kolon config JSON | `wwwroot/js/config/manual-rediscount/treasury.json` → ViewComponent okur → `<input hidden>` | `wwwroot/js/config/swap-mm-report/swap-mm-report.json` |
| Kolon motoru | `columns.ts` `mrBuildDataColumns` (`dataField: Data.{key}`, tip: money/rate/date/string) | aynı motor + yeni tip `days` (int, sağa yaslı) |
| Ürün değişince | `onProductChanged` → grid boşalt → kolonları yeniden kur (sunucuya gitmez) | aynı |
| Search | `applyFilters` → validate → boş store → grid load → Load | aynı |
| Önbellek | `#scopeKey` (filtre parmak izi) | aynı: `Module|Product|VD from/to|MD from/to` |
| Sınır | Take ≤ 2000 + kırpılma uyarısı | Take ≤ 5000 önerisi + uyarı |
| Excel | `mrExportToExcel` (ExcelJS + `DevExpress.excelExporter`) | aynı + Jira formatı (başlık bandı, renkli başlık) |
| Bridge | `exposeNamespacedApi("ManualRediscount", …)` | `exposeNamespacedApi("SwapMmReport", …)` |
| Modül ucu | MM/FX: Controller → MediatR Handler → DataManager/Repository (EF LINQ, `AsNoTracking`) | aynı |

**Almayacağımız MR parçaları:** statü pill'leri, Generate/Regenerate, overlay, muhasebe popup'ı, SubProduct DropDownBox, ExecutionDate, Treasury/Security/Investment ayrımı. Rapor salt-okunur.

**Karar:** MR klasöründen **import yok** — yeni sayfa kendi küçük helper'larını taşır (`smr` öneki). MR'nin page-klasörü ona özel; çapraz bağımlılık MR'yi değiştirenin raporu kırmasına yol açar.

---

## 3. Sözleşme (her iki modülde birebir)

### `POST /api/swap-mm-report/transactions`

**İstek** `SwapMmReportRequest`
| Alan | Tip | Anlam |
|---|---|---|
| `ModuleCode` | string | `MM` \| `FX` — modül doğrular, uymazsa `MODULE_MISMATCH` |
| `Product` | string | `MoneyMarket` \| `InterbankLoan` \| `FxPmSwap` — tanınmazsa `PRODUCT_UNKNOWN` |
| `ValueDateFrom` / `ValueDateTo` | date? | Başlangıç aralığı. Swap'ta **near leg ValueDate** |
| `MaturityDateFrom` / `MaturityDateTo` | date? | Bitiş aralığı. Swap'ta **far leg ValueDate** |
| `SwapTypes` | string[]? | Yalnız `FxPmSwap`: `FxSwap`, `PmSwap` (boş = ikisi) |
| `IsFirstLoad` | bool | `true` → sorgu yok |
| `Take` | int | Varsayılan/üst sınır 5000 |
| `CurrentUserId` | string | Common.UI basar |

**Tarih kuralı (4 kutu da opsiyonel, aralık başına):**
```
from != null  → x.Date >= from.Date
to   != null  → x.Date <= to.Date
ikisi de null → o tarih süzülmez
```
🔴 En az **bir** tarih kutusu dolu olmalı (UI validasyonu + modül validator'ı) — aksi halde tüm tarihçe çekilir.

**Yanıt** `SwapMmReportResponse : ResponseBase`
```jsonc
{
  "isSuccess": true,
  "totalCount": 12,
  "items": [{
    "key": "553336",                 // MM/Loan: TxnId · Swap grubu: grup anahtarı hash'i
    "product": "Money Market",       // alt ürün adı
    "logicalReference": "TMMBRW…",   // Swap grubunda: referanslar virgüllü
    "counterpartyName": "İş Bankası",
    "data": { "PrincipalAmount": 200000000, "InterestRate": 41.75, … }
  }]
}
```

---

## 4. Ürün bazlı kolonlar (`Data` anahtarları)

### 4.1 Money Market & Interbank Loan (aynı kolon seti)

| Key | Başlık (TR) | Tip | Kaynak MM | Kaynak Loan | Görünür |
|---|---|---|---|---|---|
| `CounterpartyName` | Karşı Kurum | string | `Customer.Name` | `Customer.Name` | ✅ |
| `PrincipalAmount` | Tutar | money | `DealAmount` | `PrincipalAmount` | ✅ |
| `Currency` | Döviz | string | `Ccy` | `CurrencyCode` | ✅ (görselde yok ama tutar döviz'siz anlamsız) |
| `ValueDate` | Başlangıç | date | `ValueDate` | `ValueDate` | ✅ |
| `MaturityDate` | Bitiş | date | `MaturityDate` | `MaturityDate` | ✅ |
| `OriginalTenorDays` | Orijinal Vade (Gün) | days | `Maturity − Value` | aynı | ✅ |
| `DaysToMaturity` | Vadeye Kalan (Gün) | days | `Maturity − LogicalDate` (negatif olabilir) | aynı | ✅ |
| `InterestRate` | Getiri Oranı | rate | MR'deki kaynak (`TxnMMDetail.InterestRate`, faiz satırı) | `Rate` | ✅ |
| `InterestAmount` | Getiri Tutarı | money | faiz detay satırı(ları) `Amount` | `Σ TxnCashFlow.CashFlowAmount (FlowTypeId=2)` | ✅ |
| `LogicalReference` | Referans | string | | | ⬜ gizli |
| `Direction` | Yön | string | PLC/BRW adı | aynı | ⬜ gizli |
| `SubProductName` | Alt Ürün | string | ProductDefinition.Name | aynı | ⬜ gizli |

Kapsam: aktif kayıt (`StateId ∈ {18, 26}`), silinmiş hariç, MM'de **ISSUE** (ihraç) alt ürünleri hariç (MM listesiyle aynı), vadesi geçmiş **dahil** (görselde −28 gün).

### 4.2 FX/PM Swap

Tablolar: `txnFXSwap` (`TxnSwaps`) + `txnPMSwap` (`TxnPmSwaps`). Bacaklar `PkgNo` ile eşleşir, `InstrumentId` NEAR=1068 / FAR=1069. Aktif: `(StateId & 6) == 2`.

| Key | Başlık (TR) | Tip | Kaynak | Görünür |
|---|---|---|---|---|
| `CounterpartyName` | Karşı Kurum | string | `Customer.Name` | ✅ |
| `CcyPair` | Parite | string | `CcyPair` | ✅ (gruplama anahtarı) |
| `Direction` | İşlem Yönü | string | near leg: base alındıysa `B/S`, satıldıysa `S/B` | ✅ (gruplama anahtarı) |
| `SwapType` | Swap Tipi | string | FX Swap / PM Swap | ✅ |
| `TotalAmount` | Toplam Tutar | money | **baz olmayan** para, near leg (USD/TRY → TRY; XAG/USD → USD) | ✅ |
| `TotalAmountCcy` | Toplam Tutar Döviz | string | | ✅ |
| `NearValueDate` | Başlangıç | date | near `ValueDate` | ✅ |
| `FarValueDate` | Bitiş | date | far `ValueDate` | ✅ |
| `OriginalTenorDays` | Orijinal Vade (Gün) | days | `Far − Near` | ✅ |
| `DaysToMaturity` | Vadeye Kalan (Gün) | days | `Far − LogicalDate` | ✅ |
| `SwapRate` | Oran | rate | `(FarDeal / NearDeal − 1) / OrijinalVade × 360` (ağırlıklı ort., § 4.3) | ✅ |
| `YieldAmount` | Getiri Tutarı | money | `TotalAmount × SwapRate × OrijinalVade / 360` | ✅ |
| `SoldCcy` / `SoldAmount` | Satılan Döviz | string / money | near leg Sell | ✅ |
| `BoughtCcy` / `BoughtAmount` | Alınan Döviz | string / money | near leg Buy | ✅ |
| `ProfitLoss` | Kar(+)/Zarar(−) | money | Excel: `−(BazOlmayan × Gün × Oran)/360` (yön işaretli) | ⬜ gizli |
| `BaseAmountOunce` / `BaseAmountGram` | Baz Tutar OZ / Gr | money | PM swap near `*AmountOunce/Gram` | ⬜ gizli |
| `TransactionCount` | İşlem Adedi | days | grup büyüklüğü | ✅ |
| `LogicalReference` | Referanslar | string | near leg referansları, virgüllü | ⬜ gizli |

### 4.3 🔴 Gruplama (Jira 07.04.2026)

```
Anahtar = CounterpartyId + CcyPair + NearValueDate + FarValueDate + Direction (+ SwapType)
BoughtAmount = Σ   SoldAmount = Σ   TotalAmount = Σ
SwapRate     = Σ(TotalAmount_i × SwapRate_i) / Σ TotalAmount_i      ← baz olmayan tutarla ağırlıklı
YieldAmount  = TotalAmount × SwapRate × OrijinalVade / 360          ← gruptan yeniden hesap
```
Gruplama **FX modülünde** yapılır (UI ham bacak görmez). MM/Loan gruplanmaz (kural "swaplar" diyor).

### 4.4 🔴 Mevcut oran hesabıyla fark

`NetTrex.Fx.Common/NetTrex.Fx.Core/Helpers/SwapInterestRateCalculator.cs` (AD-8942) formülü doğru ama swap listeleri onu `nearValueDate` parametresine **LogicalDate** geçirerek çağırıyor (`SwapTransactionSelectHandler.cs:83`, `SelectPagedSwapTransactionListHandler.cs:178`) → gün = `Far − Bugün`. Excel ve Görsel 1'in getiri tutarı **orijinal vadeyle** tutuyor. Rapor aynı helper'ı **near ValueDate** ile çağıracak; mevcut listelere dokunulmayacak.

---

## 5. Ekran (Common.UI)

```
┌ Swap & Money Market Raporu ─────────────────────────────────────────────────────┐
│ Ürün [Money Market ▾]   Başlangıç [__.__.____] – [__.__.____]                    │
│ Swap Tipi [FX Swap, PM Swap ▾]*   Bitiş [__.__.____] – [__.__.____]    [Ara]    │
├──────────────────────────────────────────────────────────────── ⟳  ⬇ Excel ──────┤
│ grid: filterRow · headerFilter · groupPanel · columnChooser · summary (toplamlar)│
└─────────────────────────────────────────────────────────────────────────────────┘
 * yalnız FxPmSwap seçiliyken görünür
```
- Ürün SelectBox (tekil, zorunlu) — kolon setleri farklı olduğundan çoklu seçim yok.
- Tarih kutuları: 4 `DateBox`, `ShowClearButton(true)`; `from > to` ise uyarı.
- Grid `remoteOperations: false`, toplam satırı (Tutar, Getiri Tutarı toplamı).
- Parite filtresi (Excel filtre 4) ayrı kutu yerine grid'in header filter'ı ile karşılanır.

**Excel formatı** (Jira görselleri): 1. satır ürün adı bandı (lacivert, beyaz, birleşik hücre: "SWAP" / "MONEY MARKET"), 2. satır kolon başlıkları (kırmızı zemin, beyaz yazı), tarih `dd/MM/yyyy`, oran `%0.00`, tutar `#,##0`, gün `0 "Gün"`. Dosya: `SwapMmReport_{Product}_{ddMMyyyy}.xlsx`.

---

## 6. Dosya planı

### Treasy.Common.UI
| Katman | Dosya |
|---|---|
| Model | `Core/Models/SwapMmReport/{Req/SwapMmReportRequest.cs, Res/SwapMmReportResponse.cs, Model/SwapMmReportConstants.cs, Model/SwapMmReportLookupItem.cs}` |
| Refit | `Business/Services/ApiReferences/SwapMmReport/{Base/ISwapMmReportApi.cs, ISwapMmReportMmApi.cs, ISwapMmReportFxApi.cs}` |
| VM | `Business/ViewModels/SwapMmReport/SwapMmReportVM.cs` |
| Controller | `Web/Controllers/SwapMmReport/SwapMmReportController.cs` — `Index`, `Load` |
| View | `Web/Views/SwapMmReport/Index.cshtml` (config JSON'u controller okur; tek ekran → ViewComponent gereksiz) |
| Config | `Web/wwwroot/js/config/swap-mm-report/swap-mm-report.json` |
| TS | `Web/wwwroot/js/pages/swap-mm-report/{swap-mm-report.ts, bridges/swap-mm-report.ts, component.ts, columns.ts, constants.ts, endpoints.ts, export.ts}` |
| CSS | `Web/wwwroot/css/pages/swap-mm-report/swap-mm-report.css` |
| i18n | `Web/wwwroot/localization/pages/swap-mm-report/swap-mm-report-{tr,en}.json` (`smr-*`) |

### NetTrex.MM
| Katman | Dosya |
|---|---|
| Controller | `Api/NetTrex.MM.Api/Controllers/Reports/SwapMmReportController.cs` → `[Route("api/swap-mm-report")]`, `POST transactions` |
| DTO | `Api/NetTrex.MM.Api.ResponseRequest/Reports/SwapMmReport/{Request,Response}/…` |
| Handler | `Api/NetTrex.MM.Api.Services/Reports/SwapMmReport/Handlers/SwapMmReportHandler.cs` (+ Validator) |
| Veri | `Data/…/Managers/Reports/{ISwapMmReportDataManager, SwapMmReportDataManager}.cs` (Scrutor: `*DataManager` otomatik) — `TxnMM` ve `TxnLoan` ayrı sorgu |
| Veri modeli | `Data/NetTrex.MM.Data.Model/Managers/Reports/TDMSwapMmReportResult.cs` |
| Test | `UnitTest/…/Reports/SwapMmReport/*` |

### NetTrex.Fx
| Katman | Dosya |
|---|---|
| Controller | `Web.API/Controllers/Reports/SwapMmReportController.cs` → `[Route("api/swap-mm-report")]` |
| DTO | `ResponseRequest/SwapMmReport/…` — 🔴 namespace segmenti **çoğul** (`…SwapMmReports`), FX'te isim gölgeleme tuzağı (rehber § 8c.5) |
| Handler | `Business/Fx/Report/SwapMmReport/…` (MediatR otomatik) |
| Repository | `Common/NetTrex.Fx.Repository/Repository/Fx/SwapMmReport/{I,}SwapMmReportRepository.cs` (Scrutor otomatik; `IDataContext` al, `EfDbContext`'e cast — rehber § 8c.6) |
| Hesap | `SwapInterestRateCalculator` yeniden kullanılır (near ValueDate ile) |
| Test | `UnitTest/…/NetTrex.Fx.Business.Test/SwapMmReport/*` (koşucu: `dotnet <dll> -namespace …`) |

---

## 7. Menü & Permission (kod bittikten sonra)

- **Menü:** `mssql-read` ile `FrameworkMenu` üzerinde `ApplicationName = 'Treasy.Common.UI'` ağacı + mevcut rapor grupları SELECT → en mantıklı parent seçilir. 🔴 Önceki Common.UI menü taslağı DB'yi `TrexFramework` sanıyordu, kullanıcı örneği `NetTrexCommon` — **canlıdan doğrulanacak**.
- **Permission:** `SwapMmReport_Displayer` (App `Treasy.Common.UI`) → `SwapMmReport/Index`, `SwapMmReport/Load`. Rapor salt-okunur → Maker/Checker yok. SP'ler: `sp_FrameworkAddPermission` + `sp_FrameworkAddPermissionAction`. Sonunda Redis menü cache hatırlatması.
- Çıktılar: `.ai-agent/outputs/2026-09-xx-swap-mm-report-{menu,permission}-script.sql`.

---

## 8. Açık sorular — varsayılan önerilerle

| # | Soru | Önerim (onaylarsan bununla giderim) |
|---|---|---|
| S1 | Swap kolonları: Görsel 1 mi, Excel (Nisan 2026) mı? | Görsel 1 görünür set + Excel'den **Parite, İşlem Yönü, Swap Tipi, İşlem Adedi** görünür, **Kar/Zarar, OZ/Gr, Referanslar** gizli (column chooser ile açılır) |
| S2 | Excel'in ek filtreleri (Near/Far ayrı aralık, Parite, "Açık Swap as-of") | Kapsam dışı. Near = Başlangıç, Far = Bitiş aralığı zaten karşılıyor; Parite grid filtresinden |
| S3 | Swap oranı gün sayısı | Orijinal vade (`Far − Near`) — Excel + görsel tutuyor. Mevcut listelere dokunulmaz |
| S4 | Gruplama | Her zaman açık, FX modülünde; `İşlem Adedi` + `Referanslar` kolonu |
| S5 | External SWP (Fimple) swapları dahil mi? | Hayır — yalnız native FX Swap + PM Swap |
| S6 | MM/Loan getiri tutarı | Saklanan faiz tutarı (Görsel 2 365 bazıyla birebir tutuyor), yeniden hesap yok |
| S7 | En az bir tarih zorunlu mu? | Evet |
| S8 | Swap Tipi alt filtresi (FX Swap / PM Swap) | Var, varsayılan ikisi seçili, yalnız FxPmSwap'ta görünür |
| S9 | Permission | Yalnız `SwapMmReport_Displayer` |

---

## 9. Faz planı

| Faz | İş | Model önerisi |
|---|---|---|
| F1 | MM ucu + testler | Sonnet |
| F2 | FX ucu + gruplama + testler | **Opus** (gruplama + oran mantığı) |
| F3 | Common.UI controller/Refit/DTO/view | Sonnet |
| F4 | TS component + JSON config + i18n + Excel formatı | Opus |
| F5 | Build (3 repo) + uçtan uca kontrol | — |
| F6 | Menü SELECT + menü/permission script | — |
| F7 | PR'lar (main'e, 3 repo) | — |

---

## 10. Uygulama — 2026-09-26 ✅

### 10.1 İsimlendirme (kullanıcı kararı)
Ortak, modülden bağımsız isim: **`MaturityReport` (Vade Raporu)**. MM kodunda "Swap", FX kodunda "MoneyMarket" **geçmez**.
Branch (3 repo): `main-maturity-report-development`. Route: `POST api/maturity-report/transactions` (MM + FX).
Common.UI: `MaturityReport/Index`, `MaturityReport/Load`; JS/CSS/i18n klasörü `maturity-report`, anahtar öneki `mtr-`.

### 10.2 Sözleşme (§ 3'ün son hali)
İstek: `ModuleCode, Product, ValueDateFrom/To, MaturityDateFrom/To, SwapTypes (yalnız FX), IsFirstLoad, Take, CurrentUserId`.
Yanıt: `TotalCount, IsTruncated, Items[{ Key, Product, LogicalReference, CounterpartyName, Data{} }]`.
`IsTruncated` eklendi: FX'te gruplama yüzünden `TotalCount > satır` karşılaştırması tek başına kırpılmayı göstermiyor.
Common.UI `ModuleCode`'u ekrandan almaz, ürün tanımından çözer. Tarihler UI'dan `yyyy-MM-dd` string gider (UTC kayması yok).

### 10.3 Birimler / formüller (doğrulandı)
- MM/Loan faiz oranı **yüzde** saklanıyor (kod `/100` ile kullanıyor) → rapor olduğu gibi gösterir + `%`.
- Swap oranı **yüzde** döner: `(Far/Near − 1) × 360 / (FarValue − NearValue) × 100` (`SwapInterestRateCalculator`, near valör ile).
- Getiri = `ToplamTutar × Oran/100 × Gün/360`; Kar/Zarar = B/S → +, S/B → −.
- Testler Excel + Jira görsel sayılarıyla: 203.553.350 ✅ · %39,650067 ✅ · PM %4,6507 ✅.
  Excel O4 hücresindeki oran elle yuvarlanmış (0,3965); tam oranla getiri 392.800 (Excel 392.799,33).

### 10.4 Test / build
| Repo | Build | Test |
|---|---|---|
| NetTrex.MM | ✅ | 20/20 (`…Tests.Reports.MaturityReport`) |
| NetTrex.Fx | ✅ | 29/29 (`NetTrex.Fx.Business.Test.MaturityReport`) |
| Treasy.Common.UI | ✅ | `tsc --noEmit` 0 hata |

### 10.5 Script'ler — `.ai-agent/outputs/2026-09-26-Vade-Raporu/`
`0-DOGRULAMA` (salt-okunur) → `1-Menu` → `2-Permission`. Canlı DB erişilemedi (sql-log `swap-mm-rapor` #1-#4 başarısız).
Menü: `ModuleName = 'General'` (NetTrex.Common `GetModuleMenuHandler` → `/general/{Value}`), parent çalışma anında çözülür,
tek aday yoksa **eklemez**. Permission: `MaturityReport_Displayer` (App `Treasy.Common.UI`) → Index, Load.

### 10.6 Açık
- Canlı veriyle uçtan uca test (DB erişimi yoktu).
- Menü parent'ı (`@ParentMenuKey`) — 0-DOGRULAMA sonucu ile kesinleşecek.
- Commit / PR henüz yok.

### 10.7 Review — 2026-09-26
| # | Bulgu | Önem | Durum |
|---|---|---|---|
| R1 | Swap Tipi `form.itemOption(..., "visible")` kök item'da formu baştan çiziyor → dataField'sız editörler ilk değere dönüyor (Ürün "Money Market"e geri düşer, tarihler sıfırlanır). DevExtreme 25.2.8 `form.js` `_tryChangeLayoutManagerItemOption` ile doğrulandı | 🔴 Yüksek | ✅ `cssClass` (yeniden çizmeyen action) ile gizle/göster |
| R2 | FX kırpılma sınırı bir grubu ikiye bölebilir (yarım toplam) | 🟠 Orta | ✅ Kırpılmışsa son near tarihinin paketleri atılır (`CompletePairs`) |
| R3 | Swap kolon sırası Jira görselinden farklı | 🟠 Orta | ✅ Görsel sırası + Excel ekleri sonda |
| R4 | İstek sürerken filtre değişirse geç yanıt eski veriyi basar | 🟡 Düşük | ✅ `#requestSeq` |
| R5 | Aynı PkgNo'da iki aktif bacak → çift sayım | 🟡 Düşük | ✅ `(SwapType, PkgNo)` tekilleştirme |
| R6 | Loan `Rate = 0` saklanmışsa oran %0 | 🟡 Düşük | ✅ 0/NULL → faiz cash flow oranı |
| R7 | Tarih zorunluluğu yalnız validator'da | 🟡 Düşük | ✅ Handler guard (`DATE_REQUIRED`), MM + FX |
| R8 | Kullanılmayan `data-mtr-logical-date` / `VM.LogicalDate` | 🟡 Düşük | ✅ Kaldırıldı |
| R9 | CcyPair boşsa yön B/S'e düşer | 🟡 Düşük | ⚪ Kabul — CcyPair oluşturmada zorunlu |
| R10 | EF sorgu testleri yok | 🟡 Düşük | ⚪ DB erişimi gerekiyor |

Sonuç: MM 21/21 · FX 33/33 · Common.UI tsc 0 · 3 repo build ✅.

### 10.8 Canlı veri testi + düzeltmeler — 2026-10-01

| # | Konu | Bulgu | Durum |
|---|---|---|---|
| L1 | Ekranda ham çeviri anahtarları (`mtr-pageTitle`) | `wwwroot/bundles/localization/*.json` build'de üretiliyor (`TreasyBundleLocalizationJson`, BeforeTargets=Build). Eski bundle 30.09, `mtr-*` dosyaları 01.10 09:05 → build alınmamıştı. Build sonrası tr/en'de 58 anahtar var | ✅ build; docker image yeniden build edilmeli |
| L2 | Boş grid kısalıyor | `#mtrGrid .dx-gridbase-container { height: calc(100vh - 340px); min-height: 380px }` + MR grid görünümü (padding, zebra, başlık sarma, filtre satırı) | ✅ |
| L3 | Pager | `[10, 20, 50, 100]`, varsayılan 50 | ✅ |
| L4 | MM ISSUE dışlama | `TxnMmProductTypeId != 3` ürün Id'sini enum ile karşılaştırıyordu; DB'de Id 3 = Bond Issue (tesadüfen doğru). Kullanıcı kararı (2026-10-01): bu sürümle MM'de Issue işlemi girilmeyecek → filtre tamamen kaldırıldı | ✅ |
| L5 | MM'de Murabaha/Wakale | TxnMM'de Murabaha (50), Wakale (10) onaylı işlem var, AccountingMapCode = LOAN → Money Market raporunda çıkıyor | ❓ kullanıcıya soruldu |
| L6 | FX state filtresi | Swap kayıtlarının çoğu StateId 16 (Input). `GetFlow(1)` probe: yalnız 18/26 aktif = `(StateId & 6) = 2` | ✅ doğru, değişiklik yok |
| L7 | FX veri | NetTrexFX'te swap 0 satır; NetTrexFX_Dev'de 60/42 satır, onaylı yalnız 1 FX çifti (PkgNo 254) | ℹ️ test verisi eksik |
| L8 | Uçtan uca | MM :5041 MoneyMarket (Eylül 21 kayıt) + InterbankLoan (Haziran 17) HTTP 200, 12 alan dolu; FX :5011 HTTP 200 (0 kayıt) | ✅ |
| L9 | Menü/permission | ApplicationName `Trex.WebUI` (MR örneği); menü Reports (ReportsKey) altında ItemOrderId 31 | ✅ script yenilendi |
| L10 | İsim çakışması | Menüde `MaturityDateReport/Index` (FX & PM, Id 40) zaten var → `MaturityReport` çok yakın | ❓ kullanıcı isim seçecek |

### 10.9 İsim + Interbank Loan flag + vadeye kalan gün — 2026-10-01

| # | Karar / değişiklik | Durum |
|---|---|---|
| N1 | İsim `MaturityReport` → **`ValueMaturityReport`** (kullanıcı seçimi; menüdeki `MaturityDateReport` ile karışıyordu). Route `api/value-maturity-report`, JS/CSS/çeviri öneki `mtr` → `vmr`, ekran "Valör-Vade Raporu". 43 dosya `git mv` ile taşındı, branch `main-value-maturity-report-development` (3 repo, lokal) | ✅ |
| N2 | **Vadeye Kalan Gün** vadesi geçmişse **0** (kullanıcı kararı; önceki negatif değer Jira görselinden kopyalanmıştı). MM handler + FX aggregator `Math.Max(0, …)` | ✅ |
| N3 | **InterbankLoan:Enabled** (MM WebApi appsettings): MM `GET api/value-maturity-report/products` (flag açıksa IL dahil) + Common.UI Index ürün listesini buna göre süzüyor (MM'e ulaşılamazsa IL gizli). MM handler IL + flag kapalı → `PRODUCT_DISABLED`, veri katmanına gidilmez. Emsal: Manuel Reeskont `ProductsHandler` | ✅ |
| N4 | ISSUE filtresi kaldırıldı (kullanıcı: bu sürümle MM'de Issue işlemi girilmeyecek) | ✅ |
| N5 | Kural `Treasy.MM.UI/CLAUDE.md` Hard Rule 13'e yazıldı | ✅ |
| N6 | Swap = FX Swap (`TxnFXSwap`) + PM Swap (`TxnPMSwap`) birlikte; Swap Tipi kutusunda ikisi varsayılan seçili, biri kaldırılabilir | ℹ️ |
| N7 | Scriptler: `ValueMaturityReportKey`, `ValueMaturityReport/Index`, `ValueMaturityReport_Displayer` (`outputs/2026-09-26-Vade-Raporu/*ValorVadeRaporu*`) | ✅ |

### 10.10 Alt ürün + Log. Ref. + kullanıcı düzeltmeleri — 2026-10-01

| # | Değişiklik | Not |
|---|---|---|
| S1 | **Sub Product** (Manuel Reeskont deseni: DropDownBox + checkbox grid, tümünü seç). MM/IL alt ürünleri `POST product-definition/select` (IsEnabled, Order) → `SubProductsJson`; Swap alt ürünleri config `subProducts` = FX Swap / PM Swap. Ürün değişince yeni listenin tümü seçili gelir | MR'den fark: MR boş başlar ve Pass/Gil'i dışlar; rapor "ne varsa" kuralıyla hepsini getirir |
| S2 | **Log. Ref.** filtresi en sonda (Search kutusu, Enter = ara) + grid'de LogicalReference kolonu görünür ve son sırada | MM: `LogicalReference.Contains`; FX: near **veya** far bacak `Contains` |
| S3 | Filtre semantiği: dolu her alan AND; tarih **ya da** referans zorunlu; alt ürün **ya da** referans zorunlu (UI) | Backend: alt ürün boş = tümü |
| S4 | MM alt ürün kodu → Id: `GetSubProductIdByCodeAsync("MM", code)` (MR ile aynı); hiçbiri çözülmezse sorgu atılmaz | |
| S5 | Ürün tanımı `IsEnabled = false` olan ürünlerin işlemleri gelmez (TxnMM `Product.IsEnabled`, TxnLoan `ProductDefinition.IsEnabled`) | DB #23: yalnız Term Deposit kapalı (0 işlem) |
| S6 | Ürün adı "FX / PM Swap" → "Swap"; önceki "Swap Tipi" TagBox'ı kaldırıldı (yerini S1 aldı) | |
| S7 | Varsayılan tarih: Valör ayın 1'i–son günü (DateTimeProvider), vade boş — 4 alan AND olduğu için hepsini doldurmak uzun vadeli işlemleri gizlerdi | |
| S8 | Light mod hover/odaklı satır: zebra kuralı `:not(.dx-state-hover):not(.dx-selection):not(.dx-row-focused)` — odaklı satır temada `#35baf6` + beyaz yazı, id seçici zemini eziyordu | |
| S9 | Test: MM 30/30, FX 36/36, Common.UI build + tsc 0 hata | |
