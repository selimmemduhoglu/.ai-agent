# progress-54 — PO geri bildirimi turu (2026-09-21, aynı gün ikinci tur)

> [progress-53](progress-53.md)'ün ekran testinden dönen 6 madde.

## Durum

🟡 **Kod hazır · WebUI build ✅ · JS 139 testten 138 ✅ (kalan 1 hata turdan ÖNCE de kırıktı) ·
tarayıcı testi bekliyor**

---

## 1 — `TxnId` çakışması uyarısı **GERİ ÇEKİLDİ** ✅

PO teyidi: *"TxnId'ler unique, merak etme. Modüllerin içinde Id oluştururken belirli bir sayı
standardında veriyoruz; Id'ler karışsaydı Acc oluştururken de sorun olurdu."*

→ [progress-53 § 3](progress-53.md)'teki "⚠️ `ProductCode` süzgeci yok" açık kalemi **kapandı**.
`mrOpenAccounting` üzerindeki uyarı yorumu, kimliklerin ayrık aralıklardan üretildiğini söyleyen
nota çevrildi. **Kod değişikliği gerekmedi.**

## 2 — Ürün seçilmemişken grid çok kısa kalıyor

**Kök sebep:** progress-53'te tüm sabit kolonlara `width` verilmişti. DevExtreme artan alanı
**yalnız genişliği verilmemiş** kolonlara dağıtır; hepsi sabitse tablo içerik kadar kalır ve
sağında boş alan olur. Ürün seçilmediğinde ekranda sadece 6 sabit kolon olduğu için etki çok
belirgindi.

**Çözüm:** `ExternalCustomerName` **esneyen kolon** yapıldı — `width` yok, `minWidth: 140` var.
Ürün seçilmemişken tabloyu doldurur; ürün kolonları gelince tabana kadar çekilir.
Yeni test: `` `ExternalCustomerName` esneyen kolon — `width` YOK, `minWidth` var ``.

## 3 — Alt ürün listesinde **Select All** yoktu

**Kök sebep:** progress-53'te `ShowColumnHeaders(false)` verilmişti. DevExtreme'in "tümünü seç"
kutusu **komut kolonunun BAŞLIK hücresinde** durur — başlık kapatılınca kutu da kaybolur.

**Çözüm:** `ShowColumnHeaders(true)` + kolon başlığı boş (`Caption(" ")`), böylece başlık
satırında görünen tek şey seç/bırak kutusu. Ayrıca `SelectAllMode.AllPages` — kutu yalnız görünen
sayfayı değil **listenin tamamını** seçer. (`AllowSelectAll` verilmedi; DevExtreme varsayılanı
zaten açık, ev deseni `Views/FI/SecurityManuelReescont/Index.cshtml:59-63` de öyle.)

## 4 — Muhasebe kolonu: başlık + ikon

- Başlık eklendi: `mr-col-Accounting` → **`Acc.`** (en) / **`Muh.`** (tr). Kolon 42 → **56px**.
- İkon `dx-icon-money` ("güneş" gibi duruyordu) → **`dx-icon-textdocument`**, yani MM Transactions
  ekranındaki `Accounting` butonunun ikonunun aynısı
  (`framework-datagrid-popup-custom.js:909` / `:1439`).

## 5 — 🔴 `Uncaught ReferenceError: coreAccLoad is not defined`

**Kök sebep:** paylaşılan muhasebe partial'ı `Views/Shared/_AccountingDisplay.cshtml`, üçüncü
sekmenin (`Module Accounting`) grid'ini `.OnInitialized("coreAccLoad")` ile bağlıyor. `coreAccLoad`
bir **sayfa global'i** ve her ekran onu kendi ucuna bağlamak zorunda
(`MmTransaction/SelectAcc`, `DerivSwp/AccountingReport`, `InvFundTransaction/AccountingReport` …).
Manuel Reeskont ekranı tanımlamamıştı → pencere açılırken sekme render'ında patlıyordu.
Core Banking sekmesi etkilenmiyordu çünkü verisi partial'a **model'le** geliyor.

**Çözüm iki parçalı:**

| Katman | Ne |
|---|---|
| Uç | `RediscountControllerBase.SelectAcc(int txnId, string product)` — **ürüne göre dağıtım**: `MMTransactions`→`IMMNTransactionAPI` · `InterbankLoanTransactions`→`IInterbankLoanAPI` · `FXTransactions`→`IFxTransactionApi` · `OptFXTransactions`→`IOptCommonApi` · `DerivSwpTransactions`→`IDerivSwpTransactionApi.AccountingReport`. Tanınmayan ürün → **boş liste**, hata değil |
| JS | `window.coreAccLoad` (`manual-rediscount.init.js`) + `mrAccountingContext` + `mrFetchModuleAccounting` |

🔑 **Neden tek uçta dağıtım:** diğer ekranların her biri **tek** modülü listeliyor, Manuel Reeskont
ise tek ekranda beş ürünü listeliyor. Ürün, filtrenin seçili değerinden okunuyor
(`mrCurrentProductOf`) — grid'deki tüm satırlar zaten o ürüne ait.

⚠️ **`mrAccountingContext` İSTEKTEN ÖNCE yazılır**: partial'ın grid'i `onInitialized` sırasında,
yani HTML DOM'a girer girmez `coreAccLoad`'u çağırıyor.

⚠️ Client'lar ctor yerine `HttpContext.RequestServices`'ten çözülüyor (`BaseController.AccApi` ve
`CashFlowController` deseni): aksi halde üç türetilmiş controller'ın da ctor'u değişirdi ve uç
yalnız pencere açılınca çağrılıyor.

⚠️ MM için **`IMMNTransactionAPI`** seçildi, `IMmTransactionApi` değil. Aynı klasörde `SelectAcc`
taşıyan iki arayüz var; `MmTransactionController.SelectAcc`'in fiilen kullandığı ve dolayısıyla
DI'da çalıştığı kanıtlı olan `IMMNTransactionAPI`.

⚠️ `ToContentExternal` uzantısı `Trex.FrameworkCommon.Api`'de — `using` unutulursa 5 adet CS1061.

## 6 — Statü kolonunda boş genişlik

PO: *"Status alanını standart uzunlukta yap ve kolon da ona yakın olsun."*

- `.mr-cell-status .mr-badge` → **sabit `128px`** (en uzun etiket `Not Rediscounted` sığıyor),
  yatay dolgu 14px → 6px.
- Kolon `200px` → **`150px`** (`minWidth: 140`).
- ⚠️ Yalnız **grid hücresi** hedefleniyor. Onay / bilgi pencerelerindeki rozetler
  (`.mr-badge-inline`, `.mr-badge-from`) metin kadar dar kalmalı — `width: auto` ile korundu.
- `önceki → şimdiki` geçişinde iki rozet çıkıyor; `.mr-cell-status` zaten `overflow: visible`
  olduğu için kırpılmıyor.

---

## Değişen dosyalar

**`NetTrex.Web.UI`**
- `Controllers/ManualRediscount/RediscountControllerBase.cs` — **yeni `SelectAcc` ucu**
- `Views/Shared/Components/ManualRediscount/Default.cshtml` — alt ürün grid'i: başlık açık + Select All
- `wwwroot/js/shared/components/manual-rediscount/columns.js` — `Acc.` başlığı · `textdocument` ikonu · Status 150px · `ExternalCustomerName` esnek
- `.../constants.js` — `mrCurrentProductOf`
- `.../actions.js` — `mrAccountingContext` · uyarı notu düzeltildi
- `.../endpoints.js` — `mrFetchModuleAccounting`
- `.../init.js` — `window.coreAccLoad`
- `wwwroot/css/shared/components/manual-rediscount.css` — rozet sabit genişlik · `Acc.` başlık hücresi
- `wwwroot/js/localization/pages/manual-rediscount/*.json` — `mr-col-Accounting`
- `UnitTest/.../manualRediscountComponent.test.js` — esneyen kolon testi

## Açık

- ⬜ Tarayıcı testi: Select All · `Acc.` kolonu · `Module Accounting` sekmesi (5 ürünün her birinde) ·
  statü kolonu genişliği · ürün seçilmemişken grid genişliği.
- ⚠️ `mrSetValueDateInfo` "PascalCase … reverseType" JS testi hâlâ kırık — **iki turdan da önce
  kırıktı**, ilgisiz, dokunulmadı.
