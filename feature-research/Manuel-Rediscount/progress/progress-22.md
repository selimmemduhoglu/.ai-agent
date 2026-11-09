# progress-22 — Fimple/hata mesajları ekranda görünmüyordu: 2 gerçek bug bulundu+düzeltildi

**Tarih:** 2026-08-18

## Neden

Kullanıcı canlı testte gerçek Fimple hatası (`Code 3058`, Türkçe iş kuralı metni: *"Hesap tanımında
defter türündeki muhasebe hesapları için referans türü ve referans no alanları boş olmalıdır..."*) aldı
ama ekranda yalnız jenerik **"Error: Execution failed."** gördü. Sordu: eski (FX) manuel reeskont
ekranı bunu nasıl gösteriyordu, ya da biz ne yapmalıyız — "ne kadar saçma düzelt bunu".

**Karar:** Eski FX ekranına bakmak yerine (kullanıcı ikinci seçeneği de sundu) mevcut ekranın kendi
kodunu uçtan uca izleyip **gerçek kırık noktaları** bulmayı seçtim — zaten `mrShowExecutionResult`
(JS) satır-bazlı hata gösterimi için **doğru tasarlanmış** duruyordu, sorun tasarımda değil iki ayrı
somut bug'daydı.

## Bulunan 2 bug

### 1. 🔴 `RediscountControllerBase.cs` — `response.Message` (tekil) HER ZAMAN boş

`Load` ve `Execute` action'ları JS'e `message = response.IsSuccess ? null : response.Message` gönderiyordu.
`response.Message` (tekil, framework `ResponseBase`'ten) canlı loglarda **hep `""`** — `ExecutionsHandler`/
`EligibleTransactionsHandler`'ın guard clause'ları (`MODULE_MISMATCH`, `PRODUCT_UNKNOWN`, `RANGE_TOO_LARGE`,
`INVALID_OPERATION`) mesajı **`Messages` (çoğul) listesine** yazıyor, `Message`'a değil. JS tarafında
`response.message || fallback` deseni boş string'i falsy sayıp **her zaman jenerik metne düşüyordu** —
guard clause mesajları (satır-bazlı `Failed[]` değil, TÜM isteği reddeden üst seviye hatalar) **hiçbir
zaman** kullanıcıya ulaşmıyordu.

**Fix:** İki action'da da `response.Message` boşsa `response.Messages[0].Text`'e düşülüyor (tip adı
uydurmadan — `response.Messages` compiler'ın zaten bildiği somut tipten, inline erişim).

### 2. 🔴 `manual-rediscount.component.js` — transport hatası SESSİZCE yutuluyordu

`#executeAction`'daki `catch (e) { notifyError(mrText("mr-error-ExecuteFailed", ...)); }` — `e`'ye
**hiç bakmadan** jenerik metin basıyordu. Aynı desen `Load`'un `CustomStore.load` catch'inde de vardı
(kasıtlı olarak "aynı desene çekilmiş", progress-17). Konsola bile yazılmıyordu — devtools'ta bile
gerçek sebep görünmüyordu.

**Önemli ayrım:** Fimple'ın 3058 gibi **satır bazlı** hataları (kullanıcının verdiği örnek) bu catch'e
**düşmüyor zaten** — onlar `ExecutionsHandler` içinde yakalanıp normal 200 içinde `Failed[]` olarak
dönüyor, `mrShowExecutionResult` bunu `item.ReasonDetail` ile **zaten doğru gösteriyordu** (bu fonksiyon
sağlamdı, dokunulmadı). Bu catch bloğu yalnız **transport seviyesi** hatada (ağ/HTTP durum kodu, ör.
WebUI controller'ın kendisi 500 dönerse) devreye giriyor — ama devreye girdiğinde de **hiçbir zaman**
gerçek sebep görünmüyordu, ki bu da "ne kadar saçma" hissinin bir parçası.

**Fix (Execute + Load, iki catch'te de aynı desen):**
- `console.error(...)` eklendi — devtools'ta artık ham hata görünür.
- `e?.responseJSON?.message || e?.responseJSON?.Message` ile sunucunun döndüğü gerçek mesaj (varsa)
  önceleniyor, yoksa mevcut jenerik localize metne düşülüyor (davranış hiçbir zaman eskisinden kötü değil).

## Test durumu

- **C# (`RediscountControllerBase.cs`):** `dotnet build Web/UI/Trex.WebUI/Trex.WebUI.csproj` → **0 error**
  (WebUI container bu turda kilitli değildi, tam build koşulabildi).
- **JS (`manual-rediscount.component.js`):** `node --check` ile sözdizimi doğrulandı — **geçti**.
  ⚠️ **jest/jsCoverage bu turda KOŞULMADI** — `node_modules` bu ortamda kurulu değil (bilinen altyapı
  boşluğu, `MEMORY.md`'de kayıtlı). Bilerek atlanıyor, sessizce geçmiyorum.
- ⚠️ **`RediscountControllerBase` için hiç WebUI controller testi yok** (bu klasörde/projede emsal
  harness bulunamadı — NetTrex.MM'deki `ExecutionsHandlerTests.cs` gibi genişletilebilecek bir iskelet
  yok, sıfırdan `IManualRediscountQueryService` mock + `BaseController`/`RequestContext` bağımlılıkları
  kurmak gerekir). `ResolveMessage` dallanması karar taşıyor (Hard Rule 10) ama bu turda **yazılmadı** —
  ayrı bir onay/kapsam gerektirir, bilerek atlanıyor.

## Açık kalan

- WebUI controller testi altyapısı (varsa genişlet, yoksa kur) — istenirse ayrı iş.
- JS test altyapısı `npm install` bekliyor (`Code/UnitTest/Trex.WebUI.Tests/JSTests/`).
- Execute-hang soruşturması hâlâ parkta (progress-21).
