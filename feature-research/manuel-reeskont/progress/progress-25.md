# progress-25 — Kullanıcı onaylarına göre 6 iş yapıldı + tüm metinler İngilizceleştirildi

**Tarih:** 2026-08-18

## Neden

Kullanıcı progress-24'teki 8 maddelik denetime madde madde yorum yazdı ve kararlarını verdi:
- Loading → **ekle**
- `T+0`/`T+1` → **sadece etiket kalsın** (T eki kalksın)
- `Revaluation Type` → **onaylandı**, "biz EOD/BOD/Atomic ile işimiz yok, ters fişi zaten kendimiz
  tetikliyoruz, bu flag'in amacı batch'te nerede kesileceğini belirlemekti"
- Fimple hata metni → **gösterilmeli** ("RefitExtension'daki yapıyı gördüğünde anlarsın, Fimple
  hataları için prefix'imiz var, kendi hatalarımız için yok")
- **YENİ İSTEK:** ekrandaki + backend/frontend'deki **tüm Türkçe** hata/notification metinleri
  **İngilizce** olsun
- Çoklu seçim → "gerçekte 5-30 satır, genelde tek tek ama 10-15 de olur; ben sadece hata veya success
  bittiğinde birden fazla seçimde bunun nasıl ayarlandığını merak ediyorum, ne yapabiliriz sence"

## Yapılanlar

### 1. Tüm kullanıcıya görünen metinler İngilizce

**Neden gerekiyordu:** ekran İngilizce çalışıyor ama backend'den gelen metinler **hardcoded Türkçe**ydi
ve localization'ı **bypass** ediyordu. Kullanıcının ekran görüntüsünde `Status Description` kolonu
"Reeskont işlemi oluşturulmayı bekliyor." yazıyordu — geri kalan her şey İngilizce.

| Dosya | Değişen |
|---|---|
| `EligibleTransactionsHandler.cs` | 5 `StatusDescription` + 2 guard mesajı (`MODULE_MISMATCH`, `PRODUCT_UNKNOWN`) |
| `ExecutionsHandler.cs` | 9 metin (guard'lar + `ReasonDetail` ekleri + kapsam mesajları) |
| `EligibleTransactionsRequestValidator.cs` | 7 validation mesajı |
| `ExecutionsRequestValidator.cs` | 10 validation mesajı |
| `ManualRediscountQueryService.cs` (WebUI) | 5 mesaj (modül erişilemedi / uç tanımlı değil / yanıt alınamadı) |
| `manual-rediscount.{actions,component,filters,columns}.js` | ~20 `mrText` fallback + 2 `console.warn` |

**`tr.json` KASITLI OLARAK TÜRKÇE BIRAKILDI** — o dosya Türkçe locale'in kendisi; İngilizceye
çevirmek Türkçe dil desteğini kırardı. Sorun hardcoded metinlerdeydi, localization'da değil.

**Test:** MM build 0 hata · **83 test yeşil** · testler metne bağlı assertion yapmıyor (grep'le doğrulandı).

### 2. Loading göstergesi eklendi (Q2 + Q3'ü birlikte çözüyor)

`component.js execute()`: `showLoader()` try'dan önce, `hideLoader()` finally'de (`refresh()`'ten **önce**
— grid'in kendi loading'i ile iki overlay üst üste binmesin).

Platform deseni kullanıldı: `site.js:397-404`, `#DefaultLoadPanel` ana layout'ta tanımlı
(`_FrameworkLayout.cshtml:124-125`). `dxLoadPanel` shading **tüm ekranı** overlay'lediği için
kullanıcının Q3'teki "işlem biterken başka şeye basılamasın, batch ekranında gri oluyor" isteği de
**bu fix'le karşılanıyor** — filtreler/grid/menü hepsi erişilemez ve gri olur.

### 3. `T+0`/`T+1` etiketleri kaldırıldı

`(T+0)`/`(T+1)` **4 ayrı yerde** gömülüydü, hepsi temizlendi:
- `bundles/localization/{en,tr}.json` (`mr-confirm-ExecutionDate`, `mr-confirm-ReverseValueDate`)
- `js/devextreme/localization/bundle.messages.{en,tr}.json` (aynı anahtarların ikinci kopyası)
- `mrBuildGenerateConfirmBody` şablonunda `(T+0: tarih)` / `(T+1: tarih)` hardcoded — parantez içi
  sadece tarih olarak bırakıldı
- `mrBuildRegenerateConfirmBody` foot etiketleri

### 4. 🔴 Yol boyunca bulunan YENİ bug: geçersiz `ReverseValueDate` seçilebiliyordu

`ExecutionsRequestValidator.cs:26` → `ReverseValueDate > ExecutionDate` **ZORUNLU** (yorum: "aynı gün
ters fiş muhasebeyi anlamsız kılar"). Ama `Default.cshtml`'deki DateBox'ta **`Min` kısıtı yoktu** —
kullanıcı aynı günü (hatta öncesini) seçebiliyor, onay penceresini geçiyor ve reddi ancak **YES'e
bastıktan sonra** görüyordu. Kullanıcının ekran görüntüsündeki 18.08 = 18.08 seçimi tam bu durumdu.

**Fix:** `.Min(Model.ExecutionDate.AddDays(1))` + yeni `mrOnExecutionDateChanged` fonksiyonu —
ExecutionDate değişince ters fiş valörünün `min`'ini sürüklüyor ve mevcut değer sınırın altındaysa
sınıra çekiyor. Artık geçersiz kombinasyon **hiç kurulamıyor**; backend validator emniyet ağı olarak kalıyor.

### 5. `revaluationTypes` boşaltıldı — Q7 bug'ı kapandı

`treasury.json`'daki MM + IL bloklarında `revaluationTypes: []`. Gerekçe JSON içine `"//revaluationTypes"`
notu olarak yazıldı (backend `Eod`/`Bod`/`Atomic` üretiyor, config `InterestAccrual` diyordu, filtre
seçilince `items = []` → grid sessizce boşalıyordu; ayrıca o flag global parametre olduğu için filtre
olarak zaten anlamsız). Boş dizi → `#syncRevaluationTypes` (`component.js:306`) alanı **gizliyor**.

### 6. Çoklu seçim sonuç gösterimi birleştirildi (kullanıcı sorusuna cevap)

**Eski davranış:** başarı → notification, hata → dialog. Yani 15 satır seçip 10'u geçtiğinde sonuç
**iki ayrı yüzeye bölünüyordu**, kullanıcı bir arada göremiyordu.

**Yeni davranış — üç ayrı şekil:**
1. **Hepsi başarılı** → tek kalıcı notification (dialog açıp kullanıcıyı bir tık için durdurmak anlamsız)
2. **Kısmen başarılı / hepsi başarısız** → **TEK dialog, iki bölüm**: başarılılar (LogicalReference
   listesi) + başarısızlar (`ReasonCode` + `ReasonDetail`). Başlık sayısal özet taşıyor
   (`10 succeeded · 5 failed`) — her satır gerçek bir muhasebe fişi olduğu için sayı yetmez, hangi
   satırın ne olduğu görünmeli
3. **Hiç satır işlenmedi** (transport/üst seviye hata) → `notifyError`

🔴 **Yol boyunca bulunan güvenlik/doğruluk kusuru:** `ReasonDetail` ve `LogicalReference` HTML'e
**escape edilmeden** basılıyordu. `mrEscapeHtml` helper'ı dosyada zaten vardı ama bu satırlarda
kullanılmıyordu. `ReasonDetail` ham Fimple/exception metni — içinde `<` geçen bir dış hata metni
gösterimi bozabilirdi. Escape eklendi.

Yeni CSS (`manual-rediscount.css`): `.mr-result-section`, `.mr-result-head`, `.mr-ok-list`, `.mr-ok-row`.
Yeni localization anahtarları (`mr-result-TitleSucceeded`, `mr-result-TitleFailed`) **4 dosyaya** eklendi.

## Kullanıcının sorularına verilen cevaplar (kod değişikliği yok, açıklama)

### MM'de MoneyMarket ↔ InterbankLoan nasıl ayırt ediliyor

`LogicalReference`'tan **ayırt edilemez** (kullanıcı doğru) ve ikisi de `PrdProductDefinition` kullanıyor.
Ayrım **DB'den değil, ekrandan** geliyor: `request.Product` → `ResolveProductSourceType` →
`MoneyMarket`/`InterbankLoan` → tek DataManager. **Tek tablodan çekiliyor, ikisinden birden değil.**

İş kuralının gerekçesi: (a) iki tablo ayrı ürün, birleşik liste kullanıcıyı yanıltır; (b) `TotalCount`/
`Skip`/`Take` sayfalaması ancak tek kaynakta doğru çalışır (`R-13`); (c) `DailyFlowV2` de InterbankLoan'ı
ayrı ürün olarak listeliyor — platformun mevcut deseni. Yanıtta her satır `ProductSourceType` taşıyor,
hangi tablodan geldiği görünür.

SubProduct filtresi tablo başına farklı kolona gidiyor: `TxnMM.TxnMmProductTypeId` vs
`TxnLoan.ProductDefinitionId` — ama ikisi de aynı `PrdProductDefinition` Id'lerini taşıdığı için
`ResolveSubProductTypeId` eşlemesi değiştirilmeden iki tarafta kullanılabildi.

### Pipeline sıralaması ve açıklar (kullanıcının mantığını doğrulama)

Kullanıcının "Fimple ya da DB'ye yazılamayan bir şey Kafka'yla gidemez" mantığı **doğru** — o yönde
açık yok. Ama **kaçırdığı bir nokta var:**

🔴 **Step 25 (Kafka) çalıştığında DB'ye HENÜZ COMMIT EDİLMEMİŞTİR.** `CommitAsync` pipeline'ın dışında,
en sonda (`RevaluationAccountingService.cs:29`). Step 20 sadece EF context'ine yazıyor. Gerçek sıra:
```
15 Fimple → 20 DB(context, commit YOK) → 25 Kafka publish → CommitAsync ← gerçek DB yazımı
```
`CommitAsync` patlarsa DB'de hiçbir şey yok ama Kafka mesajı **çoktan gitmiş**.

Senaryo tablosu:

| Nerede patlar | Fimple | MM DB | Kafka | Sonuç |
|---|---|---|---|---|
| Step 15 | ❌ | ❌ | ❌ | ✅ Temiz — exception, pipeline durur, commit yok (kullanıcının aldığı 3058 hatası bu) |
| Step 20 | ✅ | ❌ | ❌ | ⚠️ Fimple'da var MM'de yok (kullanıcı farkında) |
| `CommitAsync` | ✅ | ❌ | ✅ | 🔴 **Kafka gitti, DB boş** |
| Kafka broker down | ✅ | ✅ | ❌ | 🔴 **Sessiz** — aşağıya bak |

🔴 **Şu an AKTİF olan durum:** `MessagingService.cs:22` → `_ = kafkaProducerService.SendAsync(...)`
(**await edilmiyor**), `KafkaProducerService.cs:45-48` exception'ı **`LogInformation` ile yutuyor**
(`LogError` bile değil). Kullanıcının loglarında `localhost:9092 Connection refused` **sürekli
tekrarlıyor** → broker erişilemez → **test edilen ve "başarılı" görünen fişler NetTrexAcc'ye gitmemiş
olabilir**, hiçbir yerde hata görünmeden. Kullanıcıya `AccEntryMain.Id` ile NetTrexAcc'de karşılık
kontrolü önerildi. Bu bizim eklediğimiz bir sorun değil, batch de aynı davranıyor.

### IL Generate neden kırık (daha açık anlatım istendi)

Okuma ve yazma tarafları ayrı olgunlukta:

| | `eligible-transactions` | `executions` |
|---|---|---|
| MM | ✅ | ✅ |
| InterbankLoan | ✅ | 🔴 **YOK** |

`ExecutionsHandler` ctor'unda sadece `IRevaluationAccountingService` var (MM'in servisi);
`ILoanRevaluationAccountingService` **enjekte edilmemiş**, `Product` dispatch **yok**. Batch'te doğru
desen **mevcut** (`RevaluationBatchItem.cs:25`, `:131`). Pratikte: IL satırında Generate → MM servisi
TxnLoan id'siyle çağrılır → id `TxnMM`'de yok → hata. Yanlış fiş kesilmez ama kafa karıştıran hata.

**Kullanıcıya 3 seçenek sunuldu (karar bekliyor):** (A) config'den IL bloğunu çıkar, (B) Loan dispatch
yaz (muhasebe fişi ürettiği için ayrı onay), (C) IL için sadece butonları gizle (config'e `readOnly`
gibi bir alan eklemek gerekir).

## Test durumu

- MM: `dotnet build` (test projesi) → **0 error**; `NetTrex.MM.Api.Services.Tests.exe -namespace "*ManualRediscount*"` → **83 test, 0 hata**
- WebUI: `dotnet build Trex.WebUI.csproj` → **0 error** (exit code 0)
- JS: 8 dosya `node --check` → **hepsi geçti**
- JSON: `treasury.json` + 4 localization dosyası → **hepsi geçerli**, `revaluationTypes` boş olduğu doğrulandı
- ⚠️ jest **koşulmadı** (`node_modules` yok — bilinen altyapı boşluğu)
- ⚠️ **Tarayıcıda doğrulanmadı**: loading, kalıcı notification, birleşik sonuç dialog'u, reverse date
  min kısıtı, gizlenen Revaluation Type alanı — hepsi kullanıcı testi bekliyor
- ⚠️ Yeni davranışlar (birleşik dialog, min kısıtı) için **test yazılmadı** — JS test altyapısı yok,
  cshtml/DevExtreme davranışı birim testle kapsanamıyor. Açıkça belirtiliyor.

## Açık kalan

| Konu | Durum |
|---|---|
| IL Generate — A/B/C | 🔴 **Karar bekliyor** |
| Çoklu seçim timeout (100 sn vs `MaxItems=200`) | Sonuç gösterimi düzeltildi ama **timeout riski duruyor** — kullanıcı "5-30 satır" dedi, ~15 üstü hâlâ riskli |
| Kafka broker down — fişler NetTrexAcc'de var mı | Kullanıcı kontrol etmeli |
| `FxRate` hardcoded 0 (`AccountingEntryMainModelMapper.cs:62`) | Fimple bu alanı kullanıyor mu — doğrulanmalı |
| Para birimi bazlı ondalık (JPY/KWD) | Altyapı boşluğu, ayrı iş |
| Kafka publish commit'ten önce + hata yutma | Altyapı seviyesi, batch'i de etkiliyor — ayrı iş |
| Execute-hang soruşturması | Parkta (progress-21) |
