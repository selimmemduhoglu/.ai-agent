# progress-55 — PO geri bildirimi, 3. tur (2026-09-21)

> [progress-54](progress-54.md)'ün ekran testinden dönen 5 madde.

## Durum

🟡 **Kod hazır · MM build ✅ + MR testleri ✅ · WebUI build ✅ · JS 138/139 ✅
(kalan 1 hata üç turdan da önce kırıktı) · tarayıcı testi bekliyor**

---

## 1 — Dar ekranda `Not Rediscounted → Processing` rozetleri taşıyor

Statü hücresi Execute sırasında **iki** rozet basıyor; kolon tek rozete göre daraltılmıştı
(progress-54 § 6).

**Çözüm:** kolon **duruma göre genişler**.
`MR_STATUS_COLUMN_MIN_WIDTH = 150` (normal) / `MR_STATUS_COLUMN_MIN_WIDTH_WIDE = 290` (işlem
sırasında). `ManualRediscountComponent.#applyStatusColumnWidth(wide)`
→ `mrSetPendingOverlay` sonrası `true`, `refresh()` (overlay temizlenince) `false`.

Böylece hem PO'nun "boş genişlik kalıyor" şikâyeti hem de taşma çözülüyor: kolon yalnız fiş
kesilirken geniş.

## 2 — Alt ürün listesindeki arama satırı kaldırıldı

PO: *"çok product olmayacağı için arama alanını kaldırsak mı"* + arama kutusunun solundaki boş
hücre "ölü alan" duruyordu (o hücre seçim kolonunun filtre satırı karşılığıydı).

**Çözüm:** `FilterRow` kaldırıldı. Başlık satırı (Select All kutusu) **kalıyor**.

## 3 — Referans filtresinin tetiklenmesi keşfedilemiyordu

PO: *"yazdıktan sonra başka bir yere tıklamayı düşünemeyebilir."*

Enter zaten çalışıyordu (tarayıcı Enter'da `change` üretir, kutunun `valueChangeEvent`'i `change`),
sorun **görünürlüktü**. Üç yerden anlatılıyor artık:

| Ne | Nasıl |
|---|---|
| Enter | `.OnEnterKey("mrOnFilterChanged")` — açıkça bağlandı |
| Düğme | Kutunun içinde `search` ikonlu `dxButton` → `mrOnLogicalReferenceSearch` |
| Metin | Placeholder: **"Referans yazıp Enter'a basın"** / "Type a reference and press Enter" |

⚠️ Düğme `ManualRediscountComponent.applyLogicalReferenceSearch()` çağırır: düğmeye tıklamak
odağı düşürüp `change` üretse de **sıralamaya güvenilmez**, bu yüzden DOM'daki yazılı metin okunup
kutuya sessizce yazılır (`mrWithoutValueChanged`), sonra **tek** tazeleme yapılır.

## 4 — 🔴 `width` GERİ ALINDI, `minWidth`'e dönüldü

PO: *"kolonlar birbiri üstüne geliyor, filtre alanına kolonun ismi geliyor; en kötü eski haline
getir."*

**Kök sebep (iki tur önce yapılan hata):** progress-53'te genişlikler `minWidth` → `width` olmuştu.
İki yan etki:

1. Başlık metni + filtre ikonu dar kolona sığmayıp **yan kolonun üstüne biniyor**.
2. Tüm kolonlar sabitlenince DevExtreme artan alanı dağıtacak kolon bulamıyor → tablo içerik kadar
   kalıyor (progress-54 § 2'deki "grid kısa kalıyor" da bunun sonucuydu; oradaki
   `ExternalCustomerName` esnek kolonu yamasıydı, artık gereksiz).

**Çözüm:** hepsi `minWidth`'e döndü, değerler biraz büyütüldü (Status 150 · StatusDescription 230 ·
Product 130 · LogicalReference 175 · CustomerId 140 · CustomerName 220 · ürün kolonları config
`width`'i). **TEK İSTİSNA** muhasebe komut kolonu: `width: 56` — içinde tek ikon var, esnemesi
anlamsız.

**Korunan:** sola hizalama (progress-53 § 2), büyüteç filtre ikonu, `visible: false` desteği.

## 5 — Kolon kaynakları düzeltildi

### 5a — 🔴 InterbankLoan'ın kolonları MM'inkiler DEĞİL

PO: *"InterbankLoan için eklediğin kolonlar MM'deki revaluation kolonları gibi, ama DB'deki tablolar
farklı."* → **Doğru.**

| Ürün | Değerleme tablosu | Blotter ekranı |
|---|---|---|
| Money Market | `TXN_MM_DAILY_CALCULATION` | `MmRevaluationReport` |
| InterbankLoan | **`LOAN_REVALUATION`** | **`InterbankLoanRevaluationReport`** |

`EligibleTransactionsHandler.MapItem` artık `sourceType`'a göre dallanıyor:
`BuildMoneyMarketData` (28 anahtar) / **`BuildLoanData` (46 anahtar)**.

InterbankLoan kolonları birebir `Views/Report/InterbankLoan/RevaluationReport/Index.cshtml`
listesinden: `CalculationDate` · `PeriodNumber` · `PeriodPaymentDate` · `PeriodRate` ·
`PeriodCCY` · `PeriodAmountLCY` · `PeriodLCY` · `PeriodAccrualRate` · `PeriodAccrualAmountCCY` ·
`PeriodAccrualAmountIRRLCY` · `PeriodAccrualAmountLCY` · `PrincipalAmountNPV(+CCY/LCY/LCYCode)` ·
`TotalAmountNPV(+CCY/LCY/LCYCode)` · `AccrualSpotRateABM` …

⚠️ `PeriodAccrualAmountCCY` / `PeriodAccrualAmountLCY` **tutar değil PARA BİRİMİ KODU**
(entity'de `string`, canlıda `TRY`). Gerçek tutarlar `...IRRLCY` / `...SLLCY`.

🟢 **Bonus — sorgu hafifledi:** eskiden her blotter alanı için ayrı skaler alt sorgu vardı
(5 alan = 5 alt sorgu); 20 alan daha eklenince satır başına 25 alt sorgu olacaktı.
`LoanRevaluation` satırının **tamamı bir kez** çekiliyor, eşleme bellekte yapılıyor —
`OptionsFX`'teki `Revaluation = …FirstOrDefault()` deseninin aynısı.

### 5b — `MaturityAmount`

- **Money Market:** eklendi (`TxnMm.MaturityAmount`) — progress-53'te zaten gelmişti.
- ⚠️ **InterbankLoan: EKLENMEDİ.** `TxnLoan`'da tek bir vade tutarı alanı **yok**; geri ödeme
  planı cash flow'larda ve "vade tutarı"nın hangi toplam olduğu belirsiz (tüm cash flow toplamı mı,
  anapara + son dönem faizi mi?). **Uydurmadım — PO'ya soruldu.**

### 5c — FX kolonları eski `ManuelRevaluation` ekranıyla karşılaştırıldı

Kaynak: `Views/ManuelReescont/Index.cshtml` + `ManuelReescontSelectResponse.FxTransactionModel`.

| Eski ekranın kolonu | Bizde |
|---|---|
| `LogicalReference` · `CustomerName` · `ExternalCustomerId` · `StateDescription` | **sabit kolonlar** (`StatusDescription` adıyla) |
| `RediscountProductType` | `Product` / `SubProduct` |
| `InstrumentName` · `BuyCcy` · `SellCcy` · `BuyAmount` · `SellAmount` · `ValuationSpotRate` · `ValuationRate` · `MtmAmount` · `MtmLcyAmount` · `MtmRate` · `TradeDate` · `ValueDate` · `DealRate` · `BenchmarkRate` · `Info` | ✅ **hepsi var** |
| `PortfolioId` | eski ekranda da **gizliydi** |
| **`MessageKey`** | ⬜ **YOK — tek eksik** |

→ FX kolon seti zaten tam; **`MessageKey`** dışında eklenecek bir şey çıkmadı. `MessageKey`
muhasebe fişine ait bir alan ve artık satırdaki **Acc.** düğmesinden görülebiliyor; ayrı kolon
isteniyorsa FX veri katmanına ayrıca çekilmesi gerekir → **PO kararı bekliyor.**

---

## Değişen dosyalar

**`NetTrex.MM`**
- `Data.Model/…/TDMRediscountEligibleResult.cs` — 20 InterbankLoan alanı (`Loan*` önekli)
- `Data/Managers/InterbankLoan/TransactionLoanDataManager.cs` — projeksiyon tek `LoanRevaluation` satırına indirildi, eşleme bellekte
- `Data/Managers/Transaction/TransactionDataManager.cs` — MM yolunda yeni alanlar `null`
- `Api.Services/…/EligibleTransactionsHandler.cs` — `BuildMoneyMarketData` / `BuildLoanData`
- `UnitTest/…/EligibleTransactionsHandlerTests.cs` — fabrika güncellendi

**`NetTrex.Web.UI`**
- `Views/Shared/Components/ManualRediscount/Default.cshtml` — alt üründe `FilterRow` kaldırıldı · referans kutusuna arama düğmesi + `OnEnterKey`
- `.../columns.js` — `minWidth`'e dönüş · statü kolonu genişlik sabitleri
- `.../component.js` — `#applyStatusColumnWidth` · `applyLogicalReferenceSearch`
- `.../init.js` — `mrOnLogicalReferenceSearch`
- `config/manual-rediscount/treasury.json` — InterbankLoan **46 kolon** (blotter'dan)
- `localization/pages/manual-rediscount/*.json` — 25 + 2 yeni anahtar (toplam 314)
- `UnitTest/.../manualRediscountComponent.test.js` — genişlik testleri eski sözleşmeye döndü

## Açık

- ⬜ Tarayıcı testi: statü kolonunun Execute sırasında genişlemesi · alt ürün listesi (arama yok,
  Select All var) · referans arama düğmesi/Enter · **InterbankLoan'ın 46 kolonu** · kolon
  başlıklarının artık çakışmaması.
- ❓ **PO'ya soru — InterbankLoan `MaturityAmount`:** hangi toplam? (tüm cash flow toplamı /
  anapara + son dönem faizi / başka)
- ❓ **PO'ya soru — FX `MessageKey`:** ayrı kolon isteniyor mu, yoksa Acc. penceresi yeterli mi?
- ⚠️ `mrSetValueDateInfo` "PascalCase … reverseType" JS testi hâlâ kırık — **üç turdan da önce
  kırıktı**, ilgisiz.
