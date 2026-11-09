# progress-44 — Geçici durum artık "nereden geldiğini" söylüyor · "External system error" kalktı · filtreler genişledi

**Tarih:** 2026-08-25 · **Repolar:** `NetTrex.Web.UI` (tek repo)

---

## Kullanıcının 2 maddesi

| # | İstek | Durum |
|---|-------|:-----:|
| 1a | *"`External system error` buna gerek yok, bunu silelim, bu ibareyi istemiyorum"* (işlem adı `Regenerate` **kalsın**) | ✅ |
| 1b | *"Error statüsünde bu transaction ama hangi statüden buraya geldiğini anlayamıyorum … müşteri 10 tane işlem seçmiş olabilir"* → rozete **iki statü** | ✅ |
| 2 | *"Execution Date, Product, Sub Product alanlarını biraz daha genişletsek; bu dropdown'ların genişlikleri arasında fazla boşluk var gibi"* | ✅ |

**JS 416/416** · `Trex.WebUI` build **0 Error**.

---

## 1a — Genel kategori etiketi bastırıldı

Eski metin:

```
Regenerate — External system error — Fimple Error => Code: 100, Message: Üçüncü taraf
hazine işlemi (ThirdPartyTransaction) (TMMBRW2608210004) mevcut değil.
```

`EXTERNAL_ERROR` bir **sınıflandırma**, bilgi değil: dış sistemin kendi mesajı zaten hem hangi
sistem olduğunu (*Fimple*) hem ne olduğunu söylüyor. Önüne kategori etiketi koymak satırı
uzatıp okunurluğu düşürüyordu.

Yeni metin:

```
Regenerate — Fimple Error => Code: 100, Message: Üçüncü taraf hazine işlemi
(ThirdPartyTransaction) (TMMBRW2608210004) mevcut değil.
```

İşlem adı **kaldı** — kullanıcının kendi sözü: *"bu hangi execute yapıldığıyla alakalı değil mi,
bu kalsın güzel."*

### Kural genel değil, seçici

`MR_GENERIC_REASON_CODES = ["EXTERNAL_ERROR", "UNKNOWN"]` — **yalnız kategori kodları**.

⚠️ `STATUS_CHANGED`, `NO_ACCRUAL`, `OUT_OF_SCOPE`, `DUPLICATE_REQUEST` gibi kodlar **bilgi
taşıyor** ve yazılmaya devam ediyor. *"Satır liste yüklendikten sonra değişti"* ile *"Fimple
patladı"* aynı şey değil; ikincisinde etiket gereksiz, birincisinde **tek bilgi kaynağı**.

⚠️ Detay boşsa `EXTERNAL_ERROR` etiketi **yine yazılıyor** — aksi halde satır tamamen sessiz
kalırdı.

---

## 1b — Rozette iki statü: `önceki → şimdiki`

### Neden gerekli

`Processing` ve `Error` **kalıcı değil** — DB'ye yazılmıyor, yalnız o turun gösteriminde
yaşıyor. Sayfa yenilenince satır kendi DB durumuna döner.

🔑 Sonuç: bir turda 10 satır işlenmişse *"bu Error hangi statüden geldi"* sorusunun cevabı
**başka hiçbir yerde yok**. İşlemi yapan kişi tek satırda tahmin edebilir; 10 satırlık karışık
bir seçimde edemez.

### Nasıl

Bilgi zaten elimizdeydi: istek gönderilirken her satırın durumu `CurrentStatus` olarak
hesaplanıyor (`mrEffectiveStatus`) ve overlay'de `dbStatus` alanı **var**. Eksik olan tek şey,
ilk turda bu alanın **doldurulmamasıydı** (`undefined` kalıyordu). Davranış aynıydı çünkü
`mrEffectiveStatus` `row.Status`'e düşüyordu — ama bilgi **ekranda yoktu**.

```js
dbStatus: previous?.dbStatus ?? item.CurrentStatus
```

Yeni uç, yeni DTO, yeni istek **yok** — tek satır.

### Görünüm

| Satır | Rozet |
|---|---|
| Normal | `Not Rediscounted` |
| İşlemde | `Not Rediscounted` → `Processing` |
| Hatalı | `Not Rediscounted` → `Error` ⓘ |
| Başarılı | `Rediscounted` *(tek rozet)* |

Önceki durum **soluk ve küçük** (`opacity .6`, 11px) — geçmiş bilgisi, şimdiki durumla
yarışmamalı. Renkler paletten geldiği için kullanıcı metni okumadan **renkten** tanıyor.
Kolon daralırsa tam geçiş `title` tooltip'inde okunur.

Başarılı satırda ikinci rozet **yok**: kalıcı bir sonuçta "nereden geldi" bilgisi
`Status Description` metninde zaten yazıyor, rozeti kalabalık etmenin değeri yok.
Önceki durum şimdikiyle **aynıysa** da yazılmıyor (`Error → Error` anlamsız).

`Status` kolonu `minWidth` 190 → **290** (iki rozet + ok + ⓘ).

---

## 2 — Filtre alanları genişledi

`ColCount(4)` → **`ColCount(3)`**.

Üç filtre dört kolonlu bir ızgaraya konulmuştu: alanlar satırın **dörtte üçüne** sığıyor,
dördüncü çeyrek boş kalıyordu. Yani boşluk alanların *arasında* değil **sağ tarafta**
birikiyordu ve editörler ihtiyaçtan dar duruyordu — en çok da çoklu seçim yapılan
`Sub Product` (`TagBox`) sıkışıyordu.

⚠️ Bu, **17 Ağustos'taki kendi notumun tersi** (*"ColCount(3) alanları fazla genişletiyor,
ekran boş görünüyordu"*). O not tek seçimli `SelectBox` dönemine ait; `TagBox`'ta birden çok
etiket yan yana durduğu için geniş alan artık **gerekli**. Notu view'da güncelledim ki bir
sonraki tur eski gerekçeyi doğru sanmasın.

---

## Test tarafında bir düzeltme

İlk yazdığım iki test **yanlış sebeple** geçiyordu: `load()` varsayılanında `formatMessage`
anahtarı geri döndürüyor, bu yüzden `mrText` fallback'e düşüyor ve *"External system error"*
metni **hiç üretilmiyor**. Yani "bu metin yok" iddiası bastırma mantığını değil, **test
altyapısını** ölçüyordu.

Gerçek metinleri enjekte ettim:

```js
const localized = () => load({ formatMessage: (key) => MESSAGES[key] || key });
```

🔑 Ders: bir metnin **yokluğunu** test ediyorsan, o metnin üretilebildiği bir ortamda test et —
yoksa test her koşulda yeşil kalır.

---

## Dokunulan dosyalar

| Dosya | Ne |
|-------|-----|
| `manual-rediscount.constants.js` | `MR_GENERIC_REASON_CODES` |
| `manual-rediscount.actions.js` | `mrDescribeFailure` bastırma · `mrSetPendingOverlay` → `dbStatus` |
| `manual-rediscount.columns.js` | `mrResolvePreviousStatus` · `mrStatusBadgeHtml` · iki rozet · `minWidth` 290 |
| `manual-rediscount.css` | `.mr-badge-from` · `.mr-status-arrow` |
| `Views/Shared/Components/ManualRediscount/Default.cshtml` | `ColCount(3)` |
| `JSTests/manualRediscountComponent.test.js` | 12 yeni test |

---

## Test öncesi

`Ctrl+F5` yeterli — bu turda C# **değişmedi** (yalnız `.cshtml` + JS + CSS). Ama `.cshtml`
derlendiği için WebUI'yi yeniden başlatmak gerekiyorsa build çıktısı hazır.

Kontrol listesi:
- Hata popup'ında *"External system error"* **yok**, *"Regenerate — Fimple Error…"* **var**
- Error satırının rozetinde `Not Rediscounted → Error`
- Generate'e basıldığı an rozet `Not Rediscounted → Processing`
- Başarılı satırda **tek** rozet
- Üç filtre satırın tamamını kaplıyor, `Sub Product` etiketleri sıkışmıyor
