# progress-17 — "[object Object]" grid hatası bulundu/düzeltildi + iş birimi release notu

**Tarih:** 2026-08-17

## Neden

Kullanıcı tarayıcı testinde 3 yeni ekran görüntüsü paylaştı: grid içinde kırmızı zeminde **"[object
Object]"** yazan bir satır (No data'nın üstünde) görüldü. Ayrıca ekranın **iş birimine nasıl
aktarılacağını** sordu (release note + görsellerle rapor) ve alan bazlı veri kaynaklarının **hardcode
olmadığından emin olmak** istedi.

## Bulgu — "[object Object]" kök sebep

`manual-rediscount.endpoints.js` → `mrFetchEligibleTransactions`/`mrExecute` çıplak `$.ajax(...)`
kullanıyor (bilinçli — `ajax.js` sarmalayıcısı `IsSuccess:false`'u yutuyor, bkz. dosya başındaki not).
Ama `$.ajax` bir HTTP/ağ hatasında (4xx/5xx/timeout) **ham jqXHR objesiyle reject** eder — `.message`
alanı olmayan düz bir obje. `manual-rediscount.component.js` → `#createStore().load` bu ajax çağrısını
**try/catch'siz** `await` ediyordu; `isSuccess === false` kontrolü yalnız **HTTP 200 + iş hatası**
durumunu yakalıyordu, ağ/HTTP seviyesi hatayı değil. Reject edilen ham obje DevExtreme grid'in
kendi hata gösterimine düşüyor, `String(object)` = `"[object Object]"` basılıyor.

`Execute` yolunda (`#executeAction`, `component.js:198-207`) bu zaten **doğru** yapılmıştı
(`try { await mrExecute(...) } catch { notifyError(...) }`) — `Load` yolunda unutulmuştu, asimetri.

## Fix

`#createStore().load` içine `mrFetchEligibleTransactions` çağrısı `try/catch`'e alındı — hata
durumunda `Execute` ile aynı desen: `notifyError("Kayıtlar getirilemedi.")` + boş grid, ham obje
DevExtreme'e hiç ulaşmıyor.

**Not:** Kullanıcının ekranında o anki HTTP hatasının GERÇEK tetikleyicisi (5xx mi, network mi,
geçici docker/ortam sorunu mu) ayrıca doğrulanmadı — network sekmesi/log yakalanmadı. Düzeltilen şey
"hata OLURSA nasıl görüneceği", hatanın kendisinin neden oluştuğu değil. İleride tekrarlarsa
`docker logs` + tarayıcı network sekmesiyle asıl tetikleyici ayrıca incelenmeli.

## Diğer iş: iş birimi release notu

`.ai-agent/manuel-reeskont/10-is-birimi-release-notu.md` yazıldı — ekranın ne işe yaradığı, her
alanın **veri kaynağı** (Date/Product/SubProduct/RevaluationType/ReverseValueDate — hangisi kod,
hangisi config dosyası, hangisi sunucu hesaplaması), durum modeli, buton davranışları (Generate/
Regenerate ne zaman aktif/pasif, ne yapar), bilinen sınırlamalar, bugünkü 2 düzeltme ve doküman
uyumluluk özeti (43/46 = %93) madde madde anlatıldı. Ekran görüntüleri **yer tutucu** olarak
işaretlendi — Claude sohbette paylaşılan görselleri diske yazamıyor, kullanıcı kendi görsellerini
belirtilen yerlere ekleyecek.

**Kullanıcının "hardcoded mi" sorusuna net cevap:** Product listesi (hangi ürünler ekranda görünür)
küçük bir C# listesi (kod) — bilinçli, çünkü modül yönlendirmesi güvenlik/sunucu kararı. Sub Product,
Revaluation Type ve grid kolonları ise **tamamen** `wwwroot/js/config/manual-rediscount/*.json`
dosyalarından geliyor — kod değişikliği gerektirmeden, ürün ekibi dosyayı güncelleyerek yönetebiliyor.
Bu ayrım kasıtlı (sözleşme M-02), kaçırılmış bir "hepsini config'e taşımalıydım" durumu değil.

## Test durumu

- `dotnet build` → arka planda çalıştırıldı (sonucu bu dosyaya işlenmedi, bir sonraki turda teyit
  edilecek — JS-only değişiklik olduğu için derleme riski yok ama sağlık kontrolü olarak koşuldu).
- Jest yine koşulamadı (bkz. progress-16 — infra sorunu devam ediyor, kullanıcı kendi ortamında
  doğrulamalı).

## Açık kalan

- `[object Object]`'in asıl tetikleyicisi (hangi HTTP hatası) doğrulanmadı.
- Release notundaki `[GÖRSEL-N]` yer tutucuları kullanıcı tarafından doldurulacak.
- DevExtreme reflection fix hâlâ uncommitted (compact-3/4'ten beri).
