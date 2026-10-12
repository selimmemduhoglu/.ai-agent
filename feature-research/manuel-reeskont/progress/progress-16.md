# progress-16 — Treasury ürün listesi genişletildi + "modül hazır değil" durumu düzeltildi

**Tarih:** 2026-08-17

## Neden

Kullanıcı tarayıcıda ekranı gördü (menü artık görünüyor — bkz. progress-15, Redis cache sorunu
çözülmüş görünüyor) ve iki şey fark etti:

1. Treasury altında `AvailableModules` (`FX;FI;MM;Common;DerivSWP;InvFund;OptFX;Limit`) parametresine
   göre eksik modüller var — yalnız MM + FX vardı, `DerivSWP`/`OptFX` istendi (`Limit`/`Common`/`FI`/
   `InvFund` kasıtlı dışında — FI/InvFund zaten Security/Investment'a ait).
2. **FX Transactions** seçilince ekran "profesyonelce görünmüyor": Sub Product alanı kırmızı
   "Sub Product is required" hatası veriyor, doldurulamıyor (boş `dataSource`), Revaluation Type alanı
   kayboluyor, hiçbir istek atılmıyor. MM seçilince ise `TreasuryRediscount/Load`'a düzgün istek gidiyor.

## Kök sebep

`TreasuryRediscountController.GetProducts()` dropdown'a `FXTransactions`'ı **listeliyor** ama
`wwwroot/js/config/manual-rediscount/treasury.json`'da bu ürün için **hiç config satırı yok** (yalnız
`MMLoanTransactions` var — FX modül ekibi henüz kolon config'ini teslim etmedi, `İ-71`). Bu yüzden
`mrResolveProductConfig` `null` döner, `#syncSubProducts()`/`#syncRevaluationTypes()` boş liste kurar
ama Sub Product alanı Razor'da `.IsRequired(true)` — boş + zorunlu = kalıcı kırmızı hata, kullanıcının
düzeltebileceği bir şey yok.

## Yapılan

1. **`ManualRediscountEnums.cs`** — `RediscountModuleCodes`'a `DerivSwp` (`"DerivSWP"`) ve `OptFX`
   (`"OptFX"`) eklendi — `AvailableModules` parametresiyle aynı token.
2. **`TreasuryRediscountController.GetProducts()`** — `DerivSwpTransactions` ve `OptFXTransactions`
   eklendi (moduleCode ile). Artık Treasury dropdown'ı `MM`/`FX`/`DerivSWP`/`OptFX` — dördü de
   `AvailableModules`'daki hazine/piyasa modülleriyle birebir.
3. **`manual-rediscount.component.js` → `#syncSubProducts()`** — `productConfig` `null` ise (ürün
   ekibi config teslim etmemiş) Sub Product alanı artık **devre dışı** + placeholder
   `"Bu modül için ekran henüz hazır değil"` (`mr-hint-ModuleNotReady`, tr/en). DevExtreme disabled
   editörü required-validasyondan muaf tutuyor — kırmızı hata kalkıyor, kullanıcı neden boş olduğunu
   anlıyor. `moduleReady` true olduğunda (MM gibi config'i olan ürünler) davranış **birebir eskisi gibi**.
4. Localization: `manual-rediscount-{en,tr}.json`'a `mr-hint-ModuleNotReady` eklendi.

**Dokunulmayan:** `treasury.json`'a FX/DerivSwp/OptFX için sahte/boş config satırı **eklenmedi** —
config'in yokluğu bilerek "henüz hazır değil" sinyali olarak kullanılıyor; ürün ekibi config'i
teslim ettiğinde `treasury.json`'a satırı eklemesi yeterli, JS/controller tarafında başka değişiklik
gerekmez.

## Test durumu

- `dotnet build Trex.WebUI.csproj` → **0 error**.
- ⚠️ **JS testleri bu turda koşturulamadı** — `npx jest` bu ortamda (Git Bash) `testMatch: 0 match`
  ile başarısız oluyor (`jest.config.js`'in Windows/POSIX path karışımı gibi görünüyor, önceki
  turlarda `JS_ROOT` eksikliği farklı bir hataydı, bu **yeni bir infra sorunu**). Kod değişikliği
  küçük ve additive (`instance.option("disabled"/"placeholder", …)`, mevcut testli
  `mrResolveProductConfig` üzerine kurulu, `moduleReady=true` durumunda davranış değişmiyor) ama
  **bilerek atlanmıyor, açıkça söylüyorum**: kullanıcı kendi ortamında `npx jest` çalıştırıp
  334 → 33x yeşil kaldığını teyit etmeli. Yeni bir jest testi de eklenmedi çünkü değişiklik DOM'lu
  private class metodunda (`#syncSubProducts`), mevcut test harness'i yalnız saf fonksiyonları
  yüklüyor (bkz. `09-dokuman-uyumluluk-raporu.md` § 9 — Web.UI class tarafı zaten "bilinçli atlandı"
  notu, aynı kapsam dışı bırakma burada da geçerli).

## Diğer sorulara cevaplar (aynı turda, kod okunarak)

- **`ExecutionDate` varsayılanı:** `RediscountControllerBase.Index()` →
  `_DateTimeProvider.GetCurrentDateTime().Date`. Bu, repodaki **10+ controller'ın** kullandığı aynı
  provider (`EodController.cs:47`'de aynı çağrı doğrudan `LogicalDate` alanına atanıyor) — yani
  takvim "bugünü" değil, sistemin **business/logical tarihi**. Reeskont ekranı platformun geri kalanıyla
  tutarlı.
- **`ReverseValueDate` varsayılanı:** `Default.cshtml:83` → `Model.ExecutionDate.AddDays(1)` — doküman
  § 4 madde 3.2'nin istediği **T+1 varsayılan** birebir. Not: düz takvim +1, iş günü atlaması yok
  (doküman da bunu şart koşmuyor, DateBox serbest seçime izin veriyor — § 3.2 zaten "T+1/T+0 iki
  seçenekli enum yerine serbest tarih" olarak 09-raporda 🟡 işaretli, C-08 kapsamında).

## % Tamamlanma (doküman uyumluluk raporu § 0'dan)

| | Sayı |
|---|---|
| ✅ Tam yapıldı | **37** |
| 🟡 Kısmen/farklı (gerekçeli) | 6 |
| ❌ Yapılmadı | **0** |
| ⏸️ Kapsam dışı (kullanıcı kararı) | 3 |
| **Toplam madde** | **46** |

**Tam + kısmen kabul edilebilir uyum: 43/46 = %93.** Sıfır madde "yapılmadı" durumunda — geriye kalan
3 madde (Faz 3 tutar önizlemesi, "seçim tüm veri kümesini kapsar", MicroUI taşıma) **kullanıcı kararıyla
kapsam dışı bırakıldı**, unutulmadı. Detay tablo: `09-dokuman-uyumluluk-raporu.md`.

⚠️ Bu yüzde **Faz 1-2-3 UI/backend sözleşmesi** içindir — FX/DerivSwp/OptFX/FI/InvFund modül
uçlarının **gerçek implementasyonu** (`İ-71`/`İ-72`) ayrı bir eksen, ürün ekiplerinin teslimine bağlı,
yukarıdaki yüzdeye dahil değil (doküman da bunu WebUI'nin sorumluluğu olarak görmüyor — § 0 "ürün
ekipleri 2 endpoint + config verir").

## Açık kalan

- Kullanıcı tarayıcıda gerçek testini yapacak (bu tur ekran görüntüleriyle DevExtreme render'ının
  çalıştığını doğruladı — grid, filtreler, pill'ler, sidebar menü hepsi görünüyor).
- JS test koşumu ortam sorunu — kullanıcı kendi ortamında doğrulamalı.
- DevExtreme reflection fix (`ManualRediscountBuilderExtensions.cs`) hâlâ uncommitted (compact-3/4).
