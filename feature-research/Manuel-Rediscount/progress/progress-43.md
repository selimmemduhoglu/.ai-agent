# progress-43 — Alt ürün kutusu kendini onarıyor · filtre ipucu grid'den çıktı · kolon sırası anlamlandı

**Tarih:** 2026-08-25 · **Repolar:** `NetTrex.Web.UI` (tek repo)

---

## Kullanıcının 4 maddesi

| # | İstek | Durum |
|---|-------|:-----:|
| 1 | *"Ekran boş olunca neden `Select product, sub-product and execution date to list records.` yazıyor — bu yazı yanlış yerde yazıyorsun galiba, ya da kaldır."* | ✅ |
| 2 | *"Generate/Regenerate'ten sonra SubProduct'larım boşalmış, sanki hiç seçmemişim gibi."* | ✅ |
| 3 | *"SubProduct'ın içi tamamen boşalmış, seçemiyorum da; Product'ı değiştirip eski Product'ı seçince SubProduct'lar geliyor."* | ✅ |
| 4 | *"MM Transaction ve InterbankLoan için kolon sıralamasına bak — FX Rate en sonda, Interest Rate'in yanında olmaz mı?"* | ✅ |

Doğrulama: **JS 404/404** · `Trex.WebUI` build **0 Error**.

---

## 1 — Filtre ipucu grid'in İÇİNDEN çıktı

**Kök sebep:** DevExtreme'in `noDataText` öğesi grid'in **kaydırılabilir içeriğine** göre
konumlanıyor. Manuel Reeskont'ta 24 kolon var, tablo ekrandan geniş → metin *görünür alanın*
ortasına değil, **tüm kaydırma genişliğinin** ortasına düşüyordu. Kullanıcının iki ekran
görüntüsü tam bunu gösteriyor: soldayken sağa kaçık, sağa kaydırınca sol kenarda yarım.

🔑 Daha önemli tespit: **bu metin veri hakkında değil, FİLTRE hakkında.** Evi de filtrelerin
yanı. Grid artık ilk açılışta **tamamen sessiz** (`noDataText = ""`), ipucu özet şeridinde
(`mrRenderFilterGuidance`) yazılıyor — sabit konum, hiç kaymıyor.

Aynı turda **kaybolmuş bir düzeltme** de geri geldi: `loadFailed` dalı. (Kaybolma sebebi:
20 Ağustos'ta `filters.js`'i onarırken o blok geri gelmemiş; `grep loadFailed` bugün **hiçbir
şey** döndürdü.) Artık istek başarısızsa grid *"filtre seç"* demiyor — 8 alt ürün seçili
haldeyken "filtre seç" yazması **yanıltıcıydı**.

| Durum | Grid metni |
|---|---|
| İlk açılış (filtre yok) | *(boş)* — ipucu filtre şeridinde |
| İstek başarısız | "Records could not be retrieved. Try again." |
| Kolon filtresi eşleşmedi | "No records match the current filter or search." |
| Durum filtresi boş | "No records in this status for the selected date." |
| Gerçekten kayıt yok | "There is no transaction awaiting rediscount for this date." |

---

## 2+3 — Alt ürün kutusu: üç katmanlı savunma

İki madde **aynı kök sebebe** çıktı.

### Kök sebep

Alt ürün listesi **yalnız JS çalışma anında** veriliyordu:

```js
instance.option("dataSource", subProducts);
```

DevExtreme `Form` editörü kendi **başlangıç seçenekleriyle** yeniden kurulduğunda bu
çalışma-anı ayarı **kayboluyor** — `dataSource`, `value` ve `placeholder` hepsi Razor haline
dönüyor. Razor'da TagBox'ın `DataSource`'u **hiç yoktu** → liste boşalıyor, dropdown
*"No data to display"* diyor, seçim silinmiş görünüyor, placeholder Razor'ın metnine dönüyor.

Kullanıcının gözlemlerinin **tamamı** bu tabloya oturuyor:

| Gözlem | Açıklama |
|---|---|
| Dropdown *"No data to display"* | `dataSource` Razor haline döndü = boş |
| Kutu **devre dışı değil** | `disabled` ayarı da çalışma-anıydı, o da geri döndü |
| Placeholder yine *"Select sub product"* | Razor'ın metni |
| Seçimler kayboldu | `value` da geri döndü |
| Ürünü değiştirip geri gelmek düzeltiyor | `onProductChanged` → JS listeyi yeniden kuruyor |

⚠️ **Tetikleyicinin kendisini koddan kesin izole edemedim.** `#syncSubProducts` yalnız iki
yerden çağrılıyor (ctor + ürün değişimi) ve ikisi de listeyi **doluyor**; execute akışında
kutuya dokunan tek satır yok. Yani editörü yeniden kuran şey bizim kodumuz değil, dışarıdan
bir `Form`/framework davranışı. Bu yüzden **tetikleyiciyi bilmeye ihtiyaç bırakmayan** bir
çözüm seçtim.

### Çözüm — üç katman

| # | Katman | Ne kazandırır | Tek başına neden yetmez |
|---|--------|---------------|--------------------------|
| 1 | **Razor `DataSource`** (`Model.InitialSubProducts`) | Editör yeniden kurulsa bile liste **yerinde kalır** | Ürün değişince geçersiz kalır |
| 2 | **Ürün değişiminde JS yeniler** (mevcut davranış) | Doğru ürünün listesi | Editör sonradan yeniden kurulursa yine kaybolur |
| 3 | **`onOpened` → `ensureSubProducts()`** | Kutu her açıldığında eksik varsa **tamamlar** | Kutuya dokunulana kadar boş görünür |

Ayrıca `#syncSubProducts` artık **seçimi silme kararını çağırana bırakıyor**:

```js
#syncSubProducts(resetValue)   // true  → ürün değişti, seçim geçersiz
                               // false → seçim KORUNUR (yeni listede olmayan kodlar atılır)
```

Çağrı yerleri: ctor `false` · `onProductChanged` `true` · `ensureSubProducts` `false` ·
execute `finally` → `ensureSubProducts()`.

🔑 Bu ayrım olmasa kendi kendini onarma **kullanıcının seçimini silerdi** — yani 3. madde
düzeltilirken 2. madde geri gelirdi.

Teşhis için `ensureSubProducts` liste eksik bulduğunda konsola **uyarı** yazıyor:
`[ManualRediscount] Alt urun listesi bos/eksik bulundu, yeniden kuruldu. {expected, current}`
Bir daha olursa tetikleyiciyi bu satırın **stack trace'inden** yakalayabiliriz.

### Yan düzeltme

Hazır durumda placeholder **boşaltılmıyordu** artık: `moduleReady` iken `""` yazılıyordu.
Varsayılan seçim kalktığından beri *"Select sub product"* ipucu kullanıcıya ne yapması
gerektiğini söyleyen **tek metin** — silinmemeli.

### C# tarafı

- `ManualRediscountComponentViewModel.InitialSubProducts` — ilk ürünün listesi (Razor `DataSource`).
- `BuildSubProductsAsync` artık `Dictionary<string, IList<RediscountLookupItem>>` döndürüyor;
  JSON projeksiyonu (`value`/`text` **küçük harf**) `Index()`'te yapılıyor.
- `ResolveInitialSubProducts` — seçili ürün `Products[0]`, listesi yoksa boş.

⚠️ Alan adları küçük harf olmak **zorunda**: `ValueExpr("value")`/`DisplayExpr("text")` ile
birebir aynı olmalı, yoksa liste dolu ama öğeler **metinsiz** basılır.

---

## 4 — Kolon sırası

Eski sıra, alanların **sözleşmeye eklendiği** sıraydı: önce temel alanlar, blotter kolonları
sonradan **sona** eklendi. Sonuç: aynı işe yarayan alanlar ekranın iki ucunda kalıyordu —
`InterestRate` 6., `FxRate` **19.** kolondu; `AccruedInterest`/`DailyAccrual` tahakkuk
tutarlarından 7 kolon uzaktaydı.

Yeni sıra **anlam bloklarına** göre (her iki MM ürününde aynı):

| Blok | Kolonlar |
|------|----------|
| Sınıflandırma (metin, solda) | `TxnType` · `Direction` · `Portfolio` · `Fund Source` |
| Sözleşme | `Currency` · `Principal Amount` · **`Interest Rate` · `FX Rate`** |
| Vade / gün | `Start Date` · `Maturity Date` · `Day Count Basis` · `Days To Mature` · `Accrual Day` |
| Tahakkuk | `Accrued Interest` · `Daily Accrual` · `Accrual Amount SL` · `IRR (CL)` · `LCY` |

`FxRate` → `InterestRate`'in yanına alındı: ikisi de oran, ikisi de 6 haneli format, ikisi de
sözleşmenin fiyat tarafı. Metin kolonları solda toplandığı için sayısal alanlar da kesintisiz
bir blok oluşturuyor.

⚠️ Kullanıcı grid'de `stateStoring` açık olan bir kolon düzeni kaydettiyse **eski sırayı
görmeye devam eder** — grid araç çubuğundaki silgi (filtre temizleme) bunu sıfırlamıyor,
tarayıcı localStorage'ındaki kayıt siliniyor ya da kolon seçiciden elle düzeltiliyor.

---

## Dokunulan dosyalar

**`NetTrex.Web.UI`** (tek repo — MM'e dokunulmadı)

| Dosya | Ne |
|-------|-----|
| `Models/Shared/Components/ManualRediscount/ManualRediscountComponentViewModel.cs` | `InitialSubProducts` |
| `Controllers/ManualRediscount/RediscountControllerBase.cs` | `ResolveInitialSubProducts` + JSON projeksiyonu |
| `Views/Shared/Components/ManualRediscount/Default.cshtml` | TagBox `DataSource` + `OnOpened` |
| `wwwroot/js/.../manual-rediscount.component.js` | `#syncSubProducts(resetValue)` · `ensureSubProducts()` · `loadFailed` · filtre ipucu |
| `wwwroot/js/.../manual-rediscount.filters.js` | `mrRenderFilterGuidance` · `mrResolveNoDataText` |
| `wwwroot/js/.../manual-rediscount.init.js` | `mrOnSubProductOpened` |
| `wwwroot/css/shared/components/manual-rediscount.css` | `.mr-filter-guidance` |
| `wwwroot/js/config/manual-rediscount/treasury.json` | 2 ürünün kolon sırası |
| `wwwroot/js/localization/pages/manual-rediscount/*.json` | `mr-nodata-LoadFailed` |
| `UnitTest/.../JSTests/manualRediscountComponent.test.js` | 4 test (1 güncellendi, 3 yeni) |

---

## Test öncesi

🔴 **WebUI yeniden başlatılmalı** — C# tarafı değişti (ViewModel + controller base).
Ardından `Ctrl+F5`.

Kontrol listesi:
- Ekran boş açılınca ipucu **filtre şeridinde**, grid sessiz; sağa kaydırınca metin kaymıyor
- Alt ürün seç → Generate → **seçimler kutuda duruyor**, liste dolu
- Alt ürün kutusunu aç-kapa → liste her zaman dolu geliyor
- Ürünü değiştir → liste yenilenip **seçim sıfırlanıyor** (kasıtlı)
- Konsolda `Alt urun listesi bos/eksik bulundu` uyarısı çıkarsa **bana söyle** — tetikleyiciyi
  o stack trace'ten yakalarız
- Kolon sırası: `Interest Rate` ile `FX Rate` **yan yana**
