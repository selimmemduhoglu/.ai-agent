# progress-53 — Ekran iyileştirmeleri (PO turu, 2026-09-21)

> Kaynak: PO'nun 5 maddelik isteği + ekran görüntüleri (Manuel Reeskont — Treasury, DailyFlowV2,
> MmTransaction Accounting popup'ı).
> Önceki tur: [progress-52](progress-52.md).

## Durum

🟡 **Kod hazır · MM build ✅ · MM ManualRediscount testleri ✅ · WebUI build ✅ · JS 458/459 ✅
(kalan 1 hata turdan ÖNCE de kırıktı) · tarayıcı testi bekliyor**

---

## 1 — Alt ürün kutusu `TagBox` → `DropDownBox`, kolon filtresi ikonu

**Şikâyet:** *"SubProduct için Product'taki gibi ok yok, bu yüzden içinde 'Select sub product'
yazsa da seçilmesi gerekiyormuş gibi hissettirmiyor."* + *"kolon filtrelerinde 'abc' yazıyor,
DailyFlow'daki gibi büyüteç olsun."*

| Ne | Nasıl |
|---|---|
| Alt ürün kutusu | `TagBox` → `DropDownBox` + `ContentTemplate(TemplateName("MrSubProductGrid"))`. Desen birebir `Views/Report/DailyFlowV2/Templates/_InstrumentTemplate.cshtml` (`sbInstrument`). Şablon kutudan **ÖNCE** basılıyor — DevExtreme şablonu widget kurulurken DOM'da arıyor |
| JS tarafı | `.dxTagBox("instance")` → `.dxDropDownBox("instance")` (3 yer, `manual-rediscount.component.js`) |
| Filtre ikonu | Sabit kolonlardan `selectedFilterOperation: "contains"` **kaldırıldı** |

🔑 **Neden "abc" çıkıyordu:** DevExtreme'de `contains` işleminin ikonu
`dx-icon-filter-operation-contains` = `\f063` ("abc" glifi). İşlem hiç verilmezse string kolonun
**varsayılan** işlemi zaten `contains`'tir ve ikon `dx-icon-filter-operation-default` = `\f027`
(büyüteç) olur. Yani davranış aynı, ikon istenen hâle geldi.
(Doğrulama: `Framework.WebUI/wwwroot/css/custombundle/dx.dark.compact.css:12871-12933`)

## 2 — Kolonlar sola yaslandı, genişlikler daraldı

- Metin **ve tarih** kolonları → `alignment: "left"`. Tutar/oran **SAĞDA kaldı** (ondalık hizası
  bozulursa rakamlar karşılaştırılamaz).
- Genişlik artık `minWidth` değil **`width`**. Yalnız `minWidth` verildiğinde `columnAutoWidth`
  kolonları boş alanı doldurmak için geriyordu ve kısa veri geniş hücrenin içinde kayboluyordu.
  `minWidth` daralma tabanı olarak kaldı (sabit kolonlarda 90-160, ürün kolonlarında 70).
- Sabit kolon genişlikleri: Status 290→200, StatusDescription 260→230, Product 140→120,
  LogicalReference 180→165, CustomerId 150→110, CustomerName 220→190.

## 3 — Satır bazında **Muhasebe** düğmesi

**İstek:** MmTransaction ekranındaki `Accounting` popup'ının (Core Banking / Local / Module
sekmeleri) aynısı Manuel Reeskont'ta da olsun.

| Karar | Gerekçe |
|---|---|
| Toolbar **değil**, satır başına komut kolonu | MmTransaction grid'i **tek** seçimli, toolbar butonu "seçili satır"a çalışıyor. Manuel Reeskont **çoklu** seçimli — "seçili satır" belirsiz |
| Kolonun yeri | Seçim kutusunun hemen sağı, `Status`'tan önce (42px). Satırın kimliği (Status / Referans) hemen yanında kalıyor |
| Uç | `BaseController.Accounting(int txnId)` — `RediscountControllerBase : BaseController` olduğu için **yeni uç yazılmadı**, `/{controllerName}/Accounting` hazır |
| Pencere | Ev standardı `#popupAcc` (`Framework.WebUI/Views/Shared/_FrameworkLayout.cshtml:58`) |

⚠️ **Bilinen sınır:** uç yalnız `AccEntryMain.TxnId` ile sorguluyor, `ProductCode` süzgeci yok.
Farklı modüllerin işlem kimlikleri çakışırsa başka modülün fişi de listeye girebilir. Uygulamadaki
**tüm** ekranlar bu davranışı paylaşıyor; süzgeç eklemek ortak muhasebe ucunu (`NetTrex.Accounting`
→ `GetAccountingFromFimpleHandler`) değiştirmeyi gerektirir → **yapılmadı, PO onayı bekliyor.**

Yeni dosya/alanlar: `mrOpenAccounting` (actions), `mrFetchAccounting` (endpoints),
`mrAccountingCellTemplate` (columns), `.mr-accounting-button` (css),
`mrSetHostSettings(..., { controllerName })` (component ctor — `cellTemplate`'e config geçemiyor).

## 4 — `LogicalReference` filtresi **sunucuda**

**İstek:** *"günde 2000 işlemim olduğunda referansı yazayım ve sadece o gelsin, 2000'i beklemeyeyim."*

- Alt ürünün yanına `mrLogicalReference_{key}` TextBox'ı (`Mode: search`,
  `ValueChangeEvent: "change"` → her tuş vuruşunda değil, Enter/odak kaybında **tek** istek).
- `#buildRequest()` → `Filters: { LogicalReference: ... }`. **Sözleşme zaten vardı**
  (`ManualRediscountColumnFilters`), dört modülün de handler'ı uyguluyor:
  MM / DerivSwp / OptFX / FX → `ResolveFilters(request.Filters)` → veri katmanında
  `x.LogicalReference.Contains(reference)` → **`Skip/Take`'ten ÖNCE**, yani SQL 1 satıra iner.
- `#scopeKey()`'e referans eklendi → değişince önbellek atlanır, sunucuya gidilir.
- 🔑 Referans doluyken **alt ürün seçimi zorunlu değil**: kullanıcı tek işlem arıyor, hangi alt
  üründe olduğunu bilmek zorunda değil. Ürün + tarih hâlâ gerekli (modül yönlendirmesi + durum hesabı).
- `clearFilters()` kutuyu da temizliyor.

## 5 — Kolon seti: blotter ile alan eşitliği

### 5a — Varsayılan kapalı kolonlar
Kolon config'i artık `visible: false` destekliyor (`mrNormalizeColumnConfig`, belirtilmezse açık).
**Kapalı gelenler:** `PortfolioName`, `FundSourceName` (PO isteği), `MarketCode`, `InputDate`,
`AccountNumber`, `CorporateTypeName`, `CorporateDetailTypeName`.

### 5b — `StartDate` → `ValueDate` 🔴
PO sorusu: *"StartDate ne işe yarıyor, ValueDate değil mi o?"* → **Evet.** Kaynak baştan beri
`TxnMm.ValueDate` idi (`TransactionDataManager` projeksiyonu), ad yanlıştı.
`TDMRediscountEligibleResult.StartDate` → `ValueDate`, `Data["StartDate"]` → `Data["ValueDate"]`,
`treasury.json` MM + InterbankLoan blokları güncellendi.
⚠️ `security.json` / `investment.json` hâlâ `StartDate` kullanıyor (FI / InvFund modülleri
yazılmadı) — `mr-col-StartDate` anahtarı bu yüzden localization'da duruyor.

### 5c — Blotter'da olup bizde olmayan alanlar eklendi
Kaynak: `RevaluationReportSelectModelMapper` (MM Revaluation Report).

| Alan | MM kaynağı | InterbankLoan kaynağı |
|---|---|---|
| `MarketCode` | `TxnMm.MarketCode` | `TxnLoan.MarketCode` |
| `InputDate` | `TxnMm.InputDate` | `TxnLoan.InputDateTime` |
| `TradeDate` | `TxnMm.TradeDate` | `TxnLoan.TradeDate` |
| `MaturityAmount` | `TxnMm.MaturityAmount` | **yok** (ödeme planı cash flow'larda) → `null` |
| `PeriodStartDate` / `PeriodEndDate` | `Details.Where(!IsPrincipalAmount)` | o günü kapsayan faiz `CashFlow` |
| `PeriodAmount` | `Details.Where(!IsPrincipalAmount).Amount` | `CashFlow.CashFlowAmount` |
| `DaysToPeriodEndDate` | handler'da hesaplanır (`PeriodEndDate - ExecutionDate`) | aynı |
| `AccountNumber` | `TxnMm.AccountNumber` | `TxnLoan.AccountNumber` |
| `CorporateTypeName` / `CorporateDetailTypeName` | `Customer.CorporateType(.DetailType).Name` — **skaler alt sorgu**, navigation DEĞİL (INNER JOIN satır kaybı riski) | aynı |

`Data` bekçi testi 18 → **28** anahtar.

### 5d — Generate sonrası değerleme kolonları 🔴
PO sorusu: *"Generate'e basınca statü değişiyor ama revaluation kolonlarımızın da dolması
gerekmiyor mu?"* → **Gerekiyor ve DB'de doluyor; ekran görmüyordu.**

`RevaluationAccountingPersister.PersistRevaluationChangesAsync` fiş keserken o güne ait
`TxnMMDailyCalculation` kaydını da yazıyor. Eligible sorgusu değerleme kolonlarını
`Valuations.Where(v => v.CalculationDate == executionDate)` ile okuyor. Ama ekran Execute'tan
sonra **bilinçli olarak** sunucuya gitmiyordu (anlık `Error` overlay'i kaybolmasın diye) —
kolonlar bayat kalıyordu.

**Çözüm:** `refreshKeepingOverlay()`. Önbelleği geçersiz kılar, `#preserveOverlayOnNextLoad`
bayrağını kaldırır ve `grid.refresh()` çağırır; `load` bu turda `mrClearResultOverlay`'i
**atlar**. `execute()`'un `finally`'sinde çağrılıyor. `refresh()` kullanılamazdı — o overlay'i siler.

---

## Ek: `stateStoring` anahtarı `-v2` oldu 🔴

`storageKey: mr-grid-{ProductGroup}` → `mr-grid-{ProductGroup}-v2`.
Ekranı daha önce açmış kullanıcının `localStorage`'daki kolon durumu, yeni kolonları **GİZLİ**
bırakıyor ve `visible: false` varsayılanlarını ezecekti. **Kolon seti her değiştiğinde bu ek
büyütülür.**

---

## Değişen dosyalar

**`NetTrex.MM`**
- `Data.Model/Managers/Transaction/TDMRediscountEligibleResult.cs` — `StartDate`→`ValueDate`, 10 yeni alan
- `Data/Managers/Transaction/TransactionDataManager.cs` — projeksiyon
- `Data/Managers/InterbankLoan/TransactionLoanDataManager.cs` — projeksiyon
- `Api.Services/ManualRediscount/Handlers/EligibleTransactionsHandler.cs` — `Data` sözlüğü
- `UnitTest/.../EligibleTransactionsHandlerTests.cs` — bekçi 28 anahtar

**`NetTrex.Web.UI`**
- `Views/Shared/Components/ManualRediscount/Default.cshtml` — DropDownBox + `MrSubProductGrid` + referans kutusu, `ColCount(4)`
- `wwwroot/js/shared/components/manual-rediscount/` — `constants` · `columns` · `component` · `actions` · `endpoints`
- `wwwroot/css/shared/components/manual-rediscount.css` — `.mr-accounting-button`, `.mr-subproduct-grid`
- `wwwroot/js/config/manual-rediscount/treasury.json` — MM + InterbankLoan kolon blokları
- `wwwroot/js/localization/pages/manual-rediscount/*.json` — 14 yeni anahtar
- `UnitTest/Trex.WebUI.Tests/JSTests/manualRediscountComponent.test.js` — hizalama / genişlik / filtre ikonu / `visible`

## Açık

- 🔴 Tarayıcı testi yapılmadı (özellikle: DropDownBox çoklu seçim + ürün değişince liste tazeleme,
  `#popupAcc` içeriği, referans filtresiyle tek satır dönmesi).
- ⚠️ `mrSetValueDateInfo` "PascalCase ... reverseType" JS testi **bu turdan önce de kırıktı**
  (`mrSetValueDateInfo` `reverseType` alanını hiç yazmıyor). Dokunulmadı.
- ⚠️ Muhasebe ucunun `ProductCode` süzgeci yok (bkz. § 3) — PO kararı bekliyor.
- ⬜ FX / DerivSwp / OptFX kolon blokları blotter eşitliği için gözden geçirilmedi; bu tur yalnız
  MM + InterbankLoan istenmişti.
