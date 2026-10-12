# progress-57 — PO geri bildirimi, 5. tur (2026-09-22)

> [progress-56](progress-56.md)'nin ekran testinden dönen 3 madde (3. madde ekran görüntüsü kesik
> geldi, PO'dan tekrar istendi) + sohbet sırasında gelen 1 ek istek (Column Chooser).

## Durum

🟡 **Kod hazır · MM etkilenmedi (WebUI-only) · WebUI build ✅ (0 hata) · JS 139/140 ✅ · tarayıcı testi bekliyor**

---

## 1 — 🔴 SubProduct açılır listesi %100/%125 zoom'da kırpılıyor

PO ekran görüntüsü: liste açık ama satırlar ("Interbank Loan", "Post-Financing" …) yarım kesiliyor.
Zoom out'ta (görsel 3, tarayıcı zoom farklı) sorun yok — müşteri ekranı **%100/%125**'te kullanacak.

**Kök sebep:** `DropDownBox`'ın açılır penceresi için genişlik **açıkça verilmemişti** — DevExtreme
varsayılanda popup'ı **kutunun kendi genişliğine** oturtuyor. Kutunun piksel genişliği zoom/DPI
yuvarlamasıyla değişince (140–180px gibi dar bir değere düşünce) popup da o kadar dar açılıyor;
içindeki liste (`.mr-subproduct-grid { min-width: 260px }`) o dar popup'ın içine SIĞMIYOR ve
taşan kısım kırpılıyor.

**Çözüm:** `Default.cshtml` → SubProduct `DropDownBox`'a `.DropDownOptions(o => o.Width(300))`
eklendi. Popup genişliği artık kutunun piksel genişliğinden **bağımsız**, sabit 300px — zoom
seviyesi ne olursa olsun liste tam görünür.

## 2 — 🟡 Araç butonları: Yenile + Export kaldırıldı/taşındı, filtre kutuları genişledi

PO: *"refresh butonu... zaten data grid içinde de refresh var"* — **haklı, ama tam olarak aynı iş
değildi**: grid'in kendi ikonu ONBELLEKTEN okuyordu (`refresh()`), dışarıdaki buton SUNUCUDAN
yeniden çekiyordu (`hardRefresh()`). İki ayrı davranış aynı ekranda iki ayrı "yenile" ikonu olarak
duruyordu — kullanıcı ikisini ayırt edemez.

**Çözüm — tek toolbar'a toplama:**
- Dışarıdaki `.mr-tools` (Yenile + Export kapları) **tamamen kaldırıldı** (`Default.cshtml`).
- Grid'in kendi üst toolbar'ındaki (`onToolbarPreparing`) ikon artık **`hardRefresh()`** çağırıyor
  — yani eski dışarıdaki butonun yaptığı iş, TEK ikonda.
- Export ikonu (Excel) **aynı toolbar'a** üçüncü ikon olarak eklendi (`mrExportToExcel` — aynı
  fonksiyon, çağrıldığı yer değişti). `exporting.enabled` bayrağına hâlâ uyuyor.
- Sonuç: `.mr-header` artık yalnız filtre Form'unu taşıyor → **Execution Date / Product / Sub
  Product / Logical Reference kutuları için daha fazla yatay alan** kalıyor.
- `mr-filter-LogicalReference` (İngilizce) **"Logical Reference" → "Log. Ref."** kısaltıldı (aynı
  istek — kutu etiketi kısalınca kutuya daha fazla pay kalıyor). Türkçe zaten "Referans" — kısa,
  dokunulmadı.

**Temizlenen ölü kod:** `mrRenderRefreshButton`, `mrRenderExportButton` (actions.js) ·
`MR_REFRESH_BUTTON`, `MR_EXPORT_BUTTON` (constants.js) · `.mr-tools` / `.mr-btn-refresh` kuralları
(CSS).

## 3 — ⚠️ PO'nun 3. maddesi eksik geldi

Mesaj `"3 -"` ile bitti, içerik gelmedi (ekran görüntüsü kesilmiş olabilir). **Koda dokunulmadı,
PO'dan tekrar istendi.**

## 4 — 🟢 Column Chooser: Txn Id kolonu eklendi, varsayılan KAPALI

PO (sohbet sırasında, ek istek): *"Column Chooser'a defaultta false olacak şekilde bu
transactionların id'lerini koyamaz mıyız"*.

`mrBuildFixedColumns`'a yeni sabit kolon: `TransactionId` (caption **"Txn Id"** /
**"İşlem No"**), `visible: false` — günlük kullanımda görünmüyor ama kolon seçiciden (huni ikonu
değil, kolon başlığı sağ tık / toolbar'daki kolon seçici ikonu) açılabiliyor. Destek/hata ayıklama
senaryosu için (Acc. düğmesinin arkasında kullanılan aynı kimlik).

`ExternalCustomerId` ile aynı muamele: `dataType: "string"` — sayısal ID binlik ayraçla
biçimlenmesin, arama/karşılaştırma metin gibi yapılsın.

`stateStoring.storageKey` **`v2` → `v3`** (kolon seti değişti — bkz. daha önceki turların kuralı:
sürüm bumplanmazsa eski `localStorage` durumu yeni kolonu gizli bırakır).

---

## Değişen dosyalar

**`NetTrex.Web.UI`**
- `Views/Shared/Components/ManualRediscount/Default.cshtml` — SubProduct `DropDownOptions(Width:300)` ·
  `.mr-tools` kaldırıldı
- `.../manual-rediscount.component.js` — `onToolbarPreparing` üç ikonlu (Yenile→`hardRefresh`,
  Clear filters, Export) · dışarıdaki buton çağrıları silindi · `storageKey` `-v3`
- `.../manual-rediscount.actions.js` — `mrRenderRefreshButton`/`mrRenderExportButton` silindi,
  `mrExportToExcel` korundu
- `.../manual-rediscount.constants.js` — `MR_REFRESH_BUTTON`/`MR_EXPORT_BUTTON` silindi
- `.../manual-rediscount.columns.js` — `TransactionId` sabit kolonu (`visible:false`)
- `wwwroot/css/shared/components/manual-rediscount.css` — `.mr-tools` ve türevleri silindi
- `wwwroot/js/localization/pages/manual-rediscount/manual-rediscount-en.json` —
  `mr-filter-LogicalReference` → "Log. Ref." · yeni `mr-col-TransactionId`
- `wwwroot/js/localization/pages/manual-rediscount/manual-rediscount-tr.json` — yeni
  `mr-col-TransactionId`
- `Code/UnitTest/Trex.WebUI.Tests/JSTests/manualRediscountComponent.test.js` — sabit kolon sırası
  listesine `TransactionId` eklendi + yeni "varsayılan gizli" testi

## Açık

- ⬜ Tarayıcı testi: %100/%125 zoom'da SubProduct listesinin tam görünmesi · grid toolbar'ındaki
  tek Yenile ikonunun sunucuya gittiğinin doğrulanması · Export'un yeni yerden çalışması · Txn Id
  kolonunun kolon seçiciden açılabilmesi.
- ⬜ PO'nun eksik gelen 3. maddesi bekleniyor.
- ❓ Önceki turlardan devam eden iki soru: InterbankLoan `MaturityAmount` hangi toplam ·
  FX `MessageKey` kolonu isteniyor mu?
- ⚠️ `mrSetValueDateInfo` "PascalCase … reverseType" JS testi hâlâ kırık — ilgisiz, dokunulmadı.
