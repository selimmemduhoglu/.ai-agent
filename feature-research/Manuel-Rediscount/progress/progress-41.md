# progress-41 — Grid CLIENT-SIDE · onay toplamları kalktı · sonuç Excel'i tüm kolonlar · base component denetimi

**Tarih:** 2026-08-21 · **Tur:** 10 · **Repolar:** `NetTrex.MM` · `NetTrex.Web.UI`

Kullanıcının bu turdaki dört isteği:
> **(1)** *"Buradaki 'select eligible rows' ne işe yarıyor, benim zaten tüm satırları seçecek tikim vardı.
> Ekstra bir işe mi yarıyor?"* (soru)
> **(2)** *"Butonların onay popup'larındaki nominal ve interest satırları gereksiz, silelim; güzel bir iş
> olmadı, her transaction kendine ait çünkü."*
> **(3)** *"Ben grid için her seferinde statüs filtrelerinde sunucuya gitmek istemiyorum; tarih için her
> statüdeki datayı getirip statülere göre filtrelemeni istiyorum. Grid sorusunun cevabı olarak veriyorum bunu."*
> **(4)** *"WebUI'daki tüm manuel reeskont kodlarına bak, bunu base component olarak yazmış olmamız lazım —
> ileride MicroUI'ye de geçireceğim. `paymentComponent.js` gibi component'ler var, o mantıkta mı yaptın?"*
> **(5)** (tur içinde) *"Sonuçlanan için Excel butonu var ya — sonuçlananın tüm manuel reeskont ekranındaki
> kolonlarını Excel'e bassın."*

---

## 1. Grid tamamen CLIENT-SIDE (`ADR-MR-028`)

**Önce:** `remoteOperations: { paging: true, filtering: true, sorting: false }`. Her statü pill'i, her
filtre, her sayfa **bir HTTP isteği** demekti — ve sorgu hafif değil (4 `COUNT` + sayfa).

**Şimdi:** bir `ExecutionDate + Product + SubProduct` kapsamı için **tüm statüler tek istekte** gelir
(`Take = 2000`), sonrası tarayıcıda.

| Ne | Nerede uygulanıyor |
|---|---|
| Statü pill'i | tarayıcı (`#applyStatusFilter`) — **HTTP yok** |
| Kolon filtresi · başlık filtresi (huni) · sıralama · sayfalama · gruplama | DevExtreme (tarayıcı) |
| Durum özeti şeridi | tarayıcı (`mrCountStatuses`) — `ADR-MR-029` |
| Yeni istek **yalnızca** | kapsam değişince (tarih/ürün/alt ürün) **veya** Execute sonrası |

**Yan kazanç — dün kapatılan iki şey artık dürüst oldu:**
- **Sıralama açıldı** (6 sabit + tüm `Data.*` kolon). Dün kapalıydı çünkü DevExtreme yalnız yüklü
  sayfayı sıralıyordu (`ADR-MR-019` tuzağı) — artık tarayıcı tüm kümeyi görüyor.
- **Huni (`headerFilter`) açıldı.** Değer listesi artık tüm kümeden çıkıyor; Treasy ev grid'inin
  (`ToNetixDataGrid` → `HeaderFilter.Visible(true)`) davranışı bu.
- **Ürüne özel (`Data.*`) kolonlar filtrelenebilir ve sıralanabilir** oldu — "tutara göre sırala,
  para birimine göre süz" ekranın en çok istenen özelliğiydi ve SQL'de yapılamıyordu.
- `filterOperations: ["contains"]` kısıtı kalktı (sunucu tek operatör yapabiliyordu, tarayıcı hepsini).
- Tutar/oran kolonlarına `dataType: "number"` **açık** yazıldı: yazılmazsa DevExtreme ilk satırda `null`
  görürse string sanıp filtreye TextBox koyuyor ve **alfabetik** sıralıyor (1.000 < 900).

**Silinen ölü kod:** `mrBuildServerFilters` · `mrIsFilterOperator` · `mrWarnUnsupportedFilters` ·
`mrWarnedUnsupportedFilters` · `mrHasColumnFilters` · `MR_FILTERABLE_FIELDS` ·
`MR_SUPPORTED_FILTER_OPERATIONS` · `MR_MAX_PAGE_SIZE` + 10 testi + `mr-warn-FilterUnsupported`.
Sunucu tarafı filtre çevirisi (ifade ağacı → 4 alan) artık **hiç çağrılmıyor**; sözleşmedeki `Filters`
bloğu **duruyor** (modül destekliyor, başka tüketici kullanabilir) ama bu ekran göndermiyor.

### 1.1 İki riski nasıl kapattık (bunlar bilinçli, dokümanlı)

🔴 **(a) Kırpılma — sessiz eksik liste.** MM `MaxTake` **200 → 2000**. Kapsam bunu aşarsa sunucunun
`TotalCount`'u gelen satır sayısından büyük olur ve ekran **yüksek sesle** uyarır: özet şeritte kırmızı
*"⚠ Yalnızca ilk 2000 / 5300 kayıt"* + notify + "kapsamı daraltın" ipucu. Sessizce kesmek yok.

🔴 **(b) Bayat durum.** `ADR-MR-024` bunu gerekçe göstererek "sunucuda kal" demişti; kaygı haklı ama
çözüm yeri yanlıştı. Gerçek koruma **modülde**: her satırın durumu fiş kesilirken yeniden doğrulanıyor
ve uyuşmazsa `STATUS_CHANGED` ile **reddediliyor** (§ 4.5) → bayat durumla çift tahakkuk **imkânsız**.
Ekran tarafında iki ek önlem: Execute sonrası önbellek **geçersiz** kılınıyor (sonraki pill/filtre
hareketi sunucuya gider) ve istek `mrEffectiveStatus` (overlay'deki son bilinen kalıcı durum) gönderiyor.
**Kalan kabul edilmiş davranış:** başka bir kullanıcı/batch arada fiş kesmişse ekran tazelenene kadar
eski durumu gösterir — ama fiş **kesilmez**, modül reddeder.

---

## 2. Onay penceresindeki toplamlar SİLİNDİ

`mrConfirmTotals` + iki çağrı + `.mr-confirm-total` CSS + 2 localization anahtarı + 3 test kaldırıldı.

Gerekçe (kullanıcının kendi tespiti, katılıyorum): bu ekran **satır bazında** fiş kesiyor
(`ADR-MR-007` — satır başına `try/catch`, biri patlarsa diğerleri devam eder). Toplam nominal hiçbir
kararın girdisi değil; onay anında bakılan şey **kaç satır** ve **hangi durumda**. Ölçek hissi veren
ama karar taşımayan bir süslemeydi. Tutar bilgisi **seçim özeti şeridinde** duruyor (image3).

---

## 3. Sonuç Excel'i artık ekranın TÜM kolonlarını yazıyor

**Önce** 4 kolon (Referans/Sonuç/Durum/Ayrıntı) → **şimdi** 3 sonuç kolonu (Sonuç · Durum · Ayrıntı) +
grid'de **görünen her kolon** (ürüne özel `Data.*` dahil).

- Kolon listesi **grid'den** okunuyor (`getVisibleColumns`) — elle tutulan bir liste Faz 2'de
  (FX/FI/InvFund kendi kolonlarını getirince) sessizce eskirdi. Kullanıcı bir kolonu gizlerse dosyada
  da çıkmaz.
- `Status`/`StatusDescription` atlanıyor: sonuç kolonlarında **o turun anlık** değeri var; grid
  verisindeki DB değerini ikinci kez yazmak yanıltıcı olurdu.
- Değerler **ham** yazılıyor (sayı sayı, tarih `Date`) — Excel'de toplanabilsin/sıralanabilsin diye.
  Biçim hücre tipinden geliyor.
- Grid API'si okunamazsa dosya **3 sonuç kolonuyla** oluşuyor; export **patlamıyor** (bir turun
  sonucunu kaybetmek, eksik kolonla kaydetmekten kötü).

---

## 4. Base component denetimi (kullanıcı isteği) — iki gerçek kusur bulundu ve düzeltildi

**Denetimin sonucu: yapı zaten base component'ti** — hatta `paymentComponent.js`'ten (nesil 1: tek
dosya + global `const`) daha disiplinli, çünkü `cashFlow/` nesli seçilmişti (`ADR-MR-016`):

| Katman | Durum |
|---|---|
| Razor | **1** ViewComponent + **1** `Views/Shared/Components/ManualRediscount/Default.cshtml` |
| Ekran view'ları | Treasury/Security/Investment → **3 satır** (`Html.ManualRediscount().ProductGroup(...)`), mantık **yok** |
| JS | **1** sınıf (`ManualRediscountComponent`) + `ManualRediscount.init({...})` girişi, 8 dosyaya bölünmüş |
| Controller | `RediscountControllerBase` + 3 ince türev (**yalnız** permission granülaritesi için — `ADR-MR-003`) |
| Ekrana özel şey | **kod değil, veri**: `wwwroot/js/config/manual-rediscount/{treasury\|security\|investment}.json` |
| CSS | `wwwroot/css/shared/components/manual-rediscount.css` |

**🔴 K-A — `window.mrInstance`: tek global slot (gerçek bug).** `Default.cshtml` instance'ı
`window.mrInstance`'a yazıyor, filtre olayları da oradan okuyordu. Bileşen `uniqueKey` ile **çok
instance'ı açıkça destekliyor** (`init.js` → `instances` sözlüğü); aynı sayfada iki grid olsa ikincisi
birincinin üzerine yazar ve **filtre değişimi yanlış grid'i** tazelerdi. Ayrıca partial iki kez render
edilirse olay fonksiyonları da ikinci kez tanımlanıyordu.
✅ Olay yönlendiricileri **`init.js`**'e taşındı; instance, olayın geldiği editörün id'sinden
(`mrExecutionDate_trs` → `trs`) çözülüyor, bulunamazsa tek instance'a düşüyor, o da yoksa **konsola
yazıyor** (sessizce yutmuyor). `window.mrInstance` **kaldırıldı** (dışarıda kullanan yok — iki repo tarandı).

**🔴 K-B — host'a özel yol bileşenin içinde sabitti.** `MR_ACCOUNTING_ENTRY_URL = "AccountingEntry/Index"`
ve `settings.baseUrl` doğrudan okunuyordu → Faz 3'te MicroUI'ye taşınınca **kırılırdı**.
✅ İkisi de **konfigürasyon**: `mrSetHostSettings(uniqueKey, { baseUrl, accountingEntryUrl })`,
okuma sırası **instance ayarı → `settings` global'i → varsayılan**. `settings` MicroUI'de olmayabilir
diye `typeof` guard'lı. Değerleri `Default.cshtml` veriyor (`@Url.Content("~/")`).

**⚠️ Kalan Faz 3 dikişi (bu turda BİLEREK dokunulmadı — kullanıcı: *"şimdilik MicroUI için aksiyon alma"*):**
`showLoader`/`hideLoader` · `notifyError`/`notifyWarning`/`notifyInfo`/`notifySuccess` · `formatMessage` ·
`ExcelJS`/`saveAs` — ~30 çağrı, hepsi Web.UI platform global'i. MicroUI'de karşılıkları `@treasy/*`
paketlerinde. Doğru hamle: ince bir host adaptörü (`baseUrl()` · `notify()` · `loader()` · `text()`),
Faz 3'ün ilk işi. Bugün taşınsa 8 dosyada gürültü, sıfır kazanç.

---

## 5. Madde 1'in cevabı — "Select eligible rows" ne işe yarıyor?

Başlıktaki tik ile **aynı şey değil**, ve grid client-side olduktan sonra farkı **büyüdü**:

1. **Generate tek statü ister** (`D-10`). Başlık tiki görünen her satırı seçer; `All` sekmesinde bu
   karışık statü demek → Generate pasif/reddediyor. Buton seçimi **tek kovaya** indirger (önce
   `Not Rediscounted`, yoksa `Not Reversed`; `Rediscounted` **hiç** seçilmez).
2. **Tavan uygular.** Client-side grid'de başlık tiki artık **tüm kapsamı** seçiyor (600 satır olabilir);
   Execute `MR_MAX_EXECUTE_ITEMS = 50` üstünü **hiçbir şey yapmadan** reddeder ve kullanıcı nedenini
   anlamaz. Buton en fazla 50 seçer ve *"kalan: N"* yazar.

Bu turda ayrıca **filtrelenmiş tam küme** üzerinden çalışacak hâle getirildi (eskiden yalnız yüklü
sayfaya bakıyordu) — component `#filteredRows()` veriyor.

---

## 6. Test / build

| | Önce | Şimdi |
|---|---|---|
| MM | 210 | **210** ✅ (clamp testi 200 → 2000) |
| JS (Manuel Reeskont) | 92 | **108** ✅ |
| JS (tüm suite) | 392 | **403** ✅ |
| Build | ✅ | MM 0 error · WebUI 0 error |

**Yeni test grupları:** client-side filtre/sıralama izinleri (6) · `mrCountStatuses` (3) ·
`mrApplyLocalFilter` (3) · `mrTruncationNotice` (2) · `mrGridHasFilter` (2) · `MR_MAX_LOAD_ROWS` (1) ·
host ayarları (5) · `mrResultExportColumns` (4) · `mrResultExportValue` (4) · akıllı seçim (5, tavan dahil).
**Silinen:** `mrBuildServerFilters` (10) · `mrConfirmTotals` (3) · `mrHasColumnFilters` (1) ·
"sıralama KAPALI" (1, tersine döndü).

**Tarayıcıda DENENMEDİ** → [`08-test-rehberi.md`](../08-test-rehberi.md) § 20 (16 madde).
En kritik üçü: **(1)** pill geçişlerinde **Network'te yeni istek olmaması** · **(7)** Execute'tan sonra
pill'e basınca durumların **taze** gelmesi · **(8)** 2000 aşımında **kırmızı uyarı**.

---

## 7. Açık kaçaklar (değişmedi)

| Kaçak | Durum |
|---|---|
| K-1 Regenerate'in üç ayrı commit'i (dış transaction yok) | ⬜ açık — karar bekliyor |
| K-2 Fimple sync yerel commit'ten önce | ⬜ açık |
| K-3 mükerrer guard process-içi (cluster kilidi yok) | ⬜ açık |
| K-4 döngü ortasında iptal | ⬜ açık |
| K-7 T+1 hafta sonuna düşebilir (Fimple kabul eder mi) | ⬜ **canlı testte ölçülecek** |
| K-5 · K-6 | ✅ kapandı (progress-40) |
