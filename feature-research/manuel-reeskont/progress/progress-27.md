# progress-27 — Çoklu seçim: client-side parçalama + FX ekranıyla karşılaştırma

**Tarih:** 2026-08-18
**Tetikleyen:**
1. *"2 tane item'a bastım ve generate dedim ama çok uzun bekledi ve 100 saniyeyi geçtiği için hata verdi… sınırlayacaksak 10 saniye yapalım ne diyorsun mantıklı mı"*
2. *"tam olarak birden fazla transaction'a basıp generation ya da regeneration yaparsam ne oluyor, bu sorunu nasıl çözdük. Not: generate ve regenerate arasındaki farkı da söyle."*
3. *"Fx tarafında nasıl çalışıyormuş mevcut reeskont ekranı… orada birden fazla seçilip gönderildiği zaman tam olarak nasıl çalışıyor ve burada biz nasıl çalışacak şekilde yaptık."*
4. *"Fimple tarafında çok fazla hata alınırsa 20 item'ı birden yapmak zorunda kalabiliriz ya da bunu bölüp 2 kerede de gönderebiliriz değil mi… araştır ve bana güncel durumu ve ne yapılabilir araştırmalarınla gel."*

---

## Yapılanlar (Done)

### 1. 🔴 Timeout çözümü — item sınırı DEĞİL, **istek boyutu** küçültüldü

Kullanıcının önerisi "10 saniye / 10 item sınırı" idi. **Reddedildi, gerekçesi ölçüme dayanıyor:**

| Ölçüm | Kaynak |
|---|---|
| WebUI→MM Refit client'ında `Timeout` **tanımlı değil** | `RefitExtensions.cs:104-109` |
| → `HttpClient` varsayılanı **100 saniye** | .NET default |
| Satır başına Fimple turu: hızlı koşuda ~6-7 sn, yavaş koşuda **~50 sn** | Canlı Seq logu 2026-08-18 |
| Kullanıcı testinde **2 satır** 100 sn'yi aştı | *"The request was canceled due to the configured HttpClient.Timeout of 100 seconds elapsing"* |

Tek satır 50 sn sürebiliyorsa **hiçbir item sınırı** güvenli değil (sınırı 1 yapmak absürt). Doğru çözüm
**isteği küçültmek**: her HTTP çağrısı **1 satır** taşır → tek satır 100 sn'lik pencerede yalnız yarışır →
timeout **yapısal olarak** ortadan kalkar ve kaç satır seçildiği (2 · 10 · 20 · 100) timeout açısından
**önemsiz** hale gelir.

> ⚠️ Kullanıcı düzeltmesi: *"tek item 50 sn sürmüyor, benim makinem localde çalıştığım için güçsüz olduğundan böyle."*
> Tasarım değişmedi — parçalama **ortamdan bağımsız** çalışır (6 sn de olsa 50 sn de olsa).

**Kod:**

| Dosya | Değişen |
|---|---|
| `manual-rediscount.constants.js:143` | `MR_EXECUTE_CHUNK_SIZE = 1` + uzun gerekçe doc'u ("büyütmeden önce düşün") |
| `manual-rediscount.component.js` | `execute()` → `baseRequest` + `items` + `await this.#executeChunked(...)`; `finally`'de `hideLoader` → hint temizle → toolbar aç → `refresh()` |
| `manual-rediscount.component.js` | **yeni** `#executeChunked(baseRequest, items)` — döngü, birikim, ilerleme, transport hatasında `break` |
| `ExecutionsHandler.cs:41-61` | `MaxItems` doc'u yeniden yazıldı: artık **emniyet ağı**, birincil mekanizma UI'da |
| 4 localization dosyası | `mr-progress-Processing` |

**`#executeChunked` davranışı:**
- Satırlar **sıralı** (paralel değil) — Fimple idempotent değil, paralel çağrı çift fiş riskini büyütür
- `succeeded[]` / `failed[]` / `messages[]` **parçalar arası birikir**
- İlerleme: `Processing 3/10…` (`mrSetActionHint`) — 1'den fazla satır varsa
- Üst seviye guard mesajı (`PRODUCT_UNKNOWN`, `TOO_MANY_ITEMS`) tekrarı bastırılıyor
- **Transport hatası** (ağ/HTTP/timeout) → `console.error` + `break`. Kalan parçalar denenmez: aynı hata
  büyük olasılıkla tekrarlanır ve her denemede 100 sn daha beklenir. Buraya kadar birikmiş sonuç
  **gösterilir** (eskiden timeout'ta `Succeeded[]`/`Failed[]` **komple kayboluyordu**)
- **Satır bazlı iş hatası** (`failed[]`, 200 içinde gelir) döngüyü **kesmez** — sonraki satırlar işlenir
- Sonunda **tek** `mrShowExecutionResult` çağrısı → birleşik dialog

### 2. Doc çelişkisi düzeltildi

`manual-rediscount.component.js` doc'u "bir parça patlarsa kalanlar denenmeye devam eder" diyordu ama kod
transport hatasında `break` ediyor. İki hata sınıfının farkı doc'a açıkça yazıldı (transport → dur,
satır bazlı iş hatası → devam).

### 3. FX mevcut reeskont ekranı incelendi (kanıt toplandı)

| Katman | Dosya |
|---|---|
| Ekran | `NetTrex.Web.UI/.../Views/ManuelReescont/Index.cshtml:196-236` |
| Controller | `Controllers/ManuelReescont/ManuelRevaluationController.cs:80-84` |
| Refit | `Services/ManuelReescont/ManuelReescontApi.cs:14-15` → `POST /Rediscount/update` |
| Backend | `NetTrex.Fx/.../Business/Fx/Transaction/Rediscount/ManualRediscountUpdateHandler.cs:97-256` |

**FX nasıl çalışıyor:**
- Ekran **TÜM** seçili satırları **tek** POST'ta gönderiyor (`LogicalReferences[]` + `Date`) — parçalama yok, sınır yok
- Backend `foreach` ile satır satır işliyor; her satır **kendi `TransactionScope(RequiresNew)`** içinde,
  kendi `unitOfWork.CommitAsync()` + hata halinde `unitOfWork.Rollback()` → **satır izolasyonu var** ✅
- Ürün ayrımı `item.RediscountProductType` ile 6 dalda (`FXSwap`/`Fx`/`PmSwap`/`Pm`/`ExternalFWD`/`ExternalSWP`)

**FX'in 4 açığı (bizim ekranda yok):**

1. 🔴 **`IsSuccess = true` her zaman** (`:255`) — 20 satırın 20'si de patlasa yanıt "başarılı" diyor
2. 🔴 **Hata mesajı hangi satırın olduğunu söylemiyor** (`:243`): `refList = request.LogicalReferences`'in
   **tamamı** — yani her hata mesajı bütün seçili referansları listeliyor
3. 🔴 **Mesajda ham `StackTrace` + `InnerException`** var → kullanıcıya gösterilecek metin değil
4. 🔴 **Ekran hatayı HİÇ göstermiyor**: `success` bloğunun içi **boş** (`:226-230`), `error` handler **yok**.
   `complete` sadece grid'i yeniliyor → kullanıcı yalnız rozetin `Error`'a döndüğünü görüyor, **sebebi göremiyor**

> Bu, progress-23'teki tespitin teyidi: FX ekranından **alınacak hata gösterme deseni yok**.
> Alınan tek şey satır bazlı izolasyon fikri (bizde de var), ki onu batch'ten de aldık.

### 4. Batch ile karşılaştırma tazelendi

`RevaluationBatchItem.cs:68-111` (MM) / `:122-142` (Loan): satır satır `foreach` + **satır başına try/catch**,
hata `LogWarning` ile loglanıyor, döngü devam ediyor. `TransactionScope`/`Rollback` **yok** —
`RevaluationAccountingService.cs:29` her satırda `unitOfWork.CommitAsync()` çağırıyor.

**Bizim handler bununla birebir aynı şekilde davranıyor** (kullanıcının "aynı olsun" isteği) —
`ExecutionsHandler.cs:189-239`.

🔑 **Parçalamanın beklenmeyen kazancı:** her HTTP isteği ayrı DI scope → ayrı `DbContext`. Yani chunk=1 ile
her satır **kendi change tracker'ında** çalışıyor; batch'te tek scope tüm döngüyü kapsıyor. Bu yönden
manuel ekran artık batch'ten **daha izole**.

---

## Yapılıyor (In Progress)

Yok — bu turda yazılan her şey tamamlandı ve doğrulandı.

---

## Yapılacaklar (TODO)

### 🔴 Kullanıcı aksiyonu (kod işi değil)

| # | Konu | Neden |
|---|---|---|
| 1 | **Kafka broker down** (`localhost:9092 Connection refused`) | `MessagingService.cs:22` fire-and-forget + `KafkaProducerService.cs:45-48` hatayı `LogInformation` ile yutuyor → kesilen fişler NetTrexAcc'ye **gitmemiş olabilir**, hiçbir yere hata düşmedi. `AccEntryMain.Id` ile karşılık kontrol edilmeli |
| 2 | **`AccAccountMap` konfigürasyon hatası** — `36099200` için Fimple 3058 "referans türü/no boş olmalı" | Şu an fiş kesilemiyor; muhasebe konfigürasyonu |
| 3 | **DB erişimi** (`192.168.10.211` timeout) | `TxnMM.Id` ↔ `TxnLoan.Id` çakışma doğrulaması (#17) yapılamadı |

### 🟡 Karar/onay bekleyen kod açıkları

| # | Konu | Not |
|---|---|---|
| 4 | **Uzun koşuyu iptal edememe** | 20 satır ≈ 2-17 dk sürebilir; `#executeChunked` döngüsünde **iptal yok**. Kullanıcı sekmeyi kapatırsa kalanlar işlenmez (grid gerçeği gösterir ama uyarı yok). Çözüm: onay penceresine tahmini süre + "Cancel" butonu (`AbortController` + döngü başında bayrak) |
| 5 | **`FxRate` hardcoded 0** (`AccountingEntryMainModelMapper.cs:62`) | Fimple bu alanı kullanıyor mu — mevcut altyapı, bizim eklediğimiz değil |
| 6 | **Para birimi bazlı ondalık yok** | `CurrencyEntity.Decimals` **hiç okunmuyor** → JPY (0 hane) / KWD (3 hane) için de 2 hane gönderiliyor |
| 7 | **Kafka publish `CommitAsync`'ten önce** | Altyapı seviyesi, batch'i de etkiliyor — ayrı iş |
| 8 | **Batch sorgularında `ProductCode` filtresi eksik** | Manuel Reeskont'unkiler progress-26'da düzeltildi; batch kapsam dışı bırakıldı |
| 9 | **`AccruedInterest`/`DailyAccrual` IL'de `null`** | `LoanRevaluationEngineService` formülü anlaşılmadan doldurulmadı (Hard Rule 3) |
| 10 | **Execute-hang soruşturması** | Kullanıcı isteğiyle parkta (progress-21). Tek kalan iz: `DistKey: ObjectKey=null` — kaynağı repolarda olmayan derlenmiş Netix.Core paketi |

### 🟢 Tarayıcı testi bekleyen

- Parçalama + `Processing N/M` ilerleme göstergesi (2 · 10 · 20 satır)
- IL satırında Generate/Regenerate (progress-26 dispatch'i)
- Loading overlay (tüm ekran gri) + kalıcı notification'lar
- Birleşik sonuç dialog'u (kısmi başarı: hem başarılı hem başarısız bölüm)
- Reverse date `Min` kısıtı (aynı gün seçilemiyor)
- Gizlenmiş `Revaluation Type` alanı

### ⚠️ Test altyapısı boşlukları

- WebUI controller/service test harness'i **yok** → `#executeChunked` birim testle kapsanmıyor
- JS jest `node_modules` **yok** (`npm install` gerekiyor)
- DataManager LINQ→SQL sorguları birim testle kapsanmıyor (gerçek DB gerekiyor)

---

## Test durumu

- 8 JS dosyası `node --check` → **8/8 OK**
- 4 localization JSON → **4/4 geçerli**
- MM test projesi build → **0 error**
- `NetTrex.MM.Api.Services.Tests.exe -namespace "*ManualRediscount*"` → **89 test, 0 hata**
- ⚠️ Parçalama **tarayıcıda test edilmedi** — kullanıcı testi bekliyor
