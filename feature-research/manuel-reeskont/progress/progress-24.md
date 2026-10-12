# progress-24 — Canlı test sonrası 8 maddelik sağlık denetimi: 3 fix + 6 bulgu

**Tarih:** 2026-08-18

## Neden

Kullanıcı reeskont ve ters fişi ekrandan başarıyla kesti, ardından 8 maddelik bir sağlık denetimi
istedi: batch ile aynı yoldan mı gidiyoruz, Kafka/DB kaydı tam mı, Fimple hassasiyeti (2 hane) korunuyor
mu, loading/kilitleme/notification doğru mu, `T+0`/`T+1` etiketleri mantıklı mı, `Revaluation Type`
nereden geliyor, JSON config'ler ne işe yarıyor. Ayrıca notification'ların kendiliğinden kapanmaması
istendi.

## Bu turda YAPILAN (kod değişikliği)

### 1. Notification'lar kalıcı hâle getirildi (kullanıcı isteği)

`DevExpress.ui.notify(..., ms)` **3 saniyede kendiliğinden kayboluyordu** — fiş kesme gibi kritik bir
işlemin sonucu gözden kaçabiliyordu. 4 çağrı `framework.notify` muadillerine çevrildi:

| Yer | Önce | Sonra |
|---|---|---|
| İşlem başarılı (`actions.js`) | `DevExpress.ui.notify(...,"success",3000)` | `notifySuccess(...)` |
| Seçim yok (`component.js`) | `DevExpress.ui.notify(...,"warning",2000)` | `notifyWarning(...)` |
| Select-all kısmi (`component.js`) | `DevExpress.ui.notify(...,"info",3000)` | `notifyInfo(...)` |
| Seçim sayısı yetersiz (`component.js`) | `DevExpress.ui.notify(...,"warning",3000)` | `notifyWarning(...)` |

Gerekçe (`framework_notify.js`): satır 127 `×` butonlu Bootstrap alert üretiyor, otomatik kapanma kodu
**satır 129-131'de yorumda**, satır 1-8 ekranda başka yere tıklanınca kapatıyor. MM Transaction
ekranının kullandığı mekanizmanın aynısı (`pages/treasury/money-market/.../mm/index.js:502`).
`dialog.alert` (satır bazlı hata dökümü) **dokunulmadı** — kullanıcı o şablonu beğendi.
Ekran artık içeride de tutarlı: hata yolu (`notifyError`) zaten bu mekanizmayı kullanıyordu.

**Test:** 8 JS dosyası `node --check` → hepsi geçti. ⚠️ jest koşulamadı (`node_modules` yok).

## Denetim sonuçları

### Q1 — Batch ile aynı yol mu? Kafka/DB tam mı? → ✅ EVET

Pipeline seviyesinde **fark yok**: manuel (`ExecutionsHandler.cs:282-284`, `:298-314`) ve batch
(`RevaluationBatchItem.cs:92-95`, `ReverseBatchItem.cs:69-76`) **aynı** `IRevaluationAccountingService` /
`IRevaluationReverseAccountingService` → aynı pipeline → aynı step'ler.

**Revaluation (6 step):** `01` Prepare → `05` Accrual (motor) → `10` fiş satırları (bellek) →
`15` **Fimple** → `20` 🔴 **DB** (`AccEntryMain`+`AccEntry`+`AccEngineGeneratedAccountRule`+`TxnMMDailyCalculation`) →
`25` 🔴 **Kafka** (main 1 mesaj + her entry 1 mesaj)

**Reverse (4 step):** `01` Fimple → `05` ters fiş üretimi → `10` 🔴 DB (+orijinalin `ReverseId` update) →
`15` 🔴 **Kafka** (4 tur: orijinal main+entry'ler, ters main+entry'ler)

Kafka **pipeline'ın parçası**, ayrı consumer/batch işi değil. Topic'ler `KafkaTopicConstants.cs:5-8`:
`accounting-entry-main-insert`, `accounting-entry-insert`. `CommitAsync` pipeline'ın **dışında, en sonda**
(`RevaluationAccountingService.cs:29`).

### Q1b / Q5b — 🔵 Fimple 2 hane hassasiyeti → ✅ UYUYOR (ama tek noktaya bağlı)

Kuralı sağlayan **tek** yer motor katmanı:
- `Calculators/Core/SLCalculator.cs:19` → `return totalAccruedAmount.RoundAwayFromZero();`
- `Calculators/Core/IRRCLCalculator.cs:30` → aynı
- LCY: `Engines/Revaluation/Steps/05_RevaluationEngineAccruedCalculateStep.cs:45-46` →
  `DivideAndRoundUp`/`MultiplyAndRoundUp`
- Hane kaynağı: `Common.Core/Constants/SystemConstants.cs:7` → **`AmountRoundingDigits = 2`**,
  mod `MidpointRounding.AwayFromZero` (`MathExtension.cs:20-23`)

Manuel ekranın **kendi tutar hesabı/yuvarlaması yok** — mevcut motoru tetikliyor
(`ExecutionsHandler.cs:284`). `EligibleTransactionsHandler.cs:175-180`'deki `RoundAwayFromZero(2)`
sadece **grid'de gösterilen** değerler için, fiş yolunda değil.

🔴 **4 uyarı (round eden yer BULUNAMAYAN noktalar):**
1. **Fimple sınırında savunma katmanı YOK.** `FimpleAccountingDetailModelMapper.cs:61-62` ham `Amount`'ı
   `Debit`/`Credit`'e basıyor. `Code/Accounting/` altındaki tüm projelerde **tek bir `Math.Round` yok**.
   2 hane garantisi tamamen yukarıdaki 2 calculator satırına bağlı — yeni bir hesap yolu 3+ haneli tutar
   üretirse Fimple'a **yuvarlanmadan** gider ve derleme/test bunu görmez.
2. 🔴 **`FxRate` HER ZAMAN 0 gidiyor** — `AccountingEntryMainModelMapper.cs:62` **hardcoded `FxRate: 0`**.
   Kullanıcının kendi Fimple logu bunu doğruluyor (`"FxRate": 0.0`). TRY/TRY'de zararsız olabilir ama
   grid'de **USD işlemler var** (TMMBRW2607240005, TMMBRW2607060003). `FxRateRoundingDigits = 10` sabiti
   bu akışta **hiç kullanılmıyor**. Fimple bu alanı kullanıyorsa ayrı bir hata.
3. 🔴 **Para birimi bazlı ondalık hane desteği YOK.** `CurrencyEntity.Decimals` kolonu **var**
   (`CurrencyEntity.cs:14`, EF config `CurrencyConfiguration.cs:53`) ama kod içinde **hiçbir yerde
   okunmuyor**. JPY (0 hane) / KWD (3 hane) için de sabit 2 hane gönderilir.
4. **Yuvarlama sonrası 0.00 riski:** `AccountingService.cs:28` sıfır tutarlı satırları eliyor, `:32-33`
   `AccountingException("All generated accounting entries have a zero (0) amount.")` fırlatıyor. Çok
   küçük anapara/kısa vadede tahakkuk 2 haneye yuvarlanıp 0.00 olursa Manuel Reeskont **hata ile düşer** —
   bu davranış ekran için doğru mu, iş birimiyle doğrulanmalı.

Not: Fimple'a **yalnız** `Debit`/`Credit`/`FxRate` gidiyor; `LcyEquivalent`/`FcyEquivalent` Fimple
modelinde **yok**. Ters fiş isteği hiç tutar göndermiyor (`FimpleAccountingService.cs:179-206` →
`AccountingModel: null`), sadece `ReverseMessageKey` alıyor.

### Q1c — 🔴 Kafka'da 2 gerçek tuzak (bizim değil, altyapıda — batch'i de etkiliyor)

1. **Publish, commit'ten ÖNCE.** Step 25/15 çalıştığında `CommitAsync` henüz çağrılmamış. Commit
   patlarsa Kafka mesajı **yine gitmiş** olur → NetTrexAcc'de MM'de olmayan fiş.
2. **Fire-and-forget + hata yutma.** `MessagingService.cs:22`: `_ = kafkaProducerService.SendAsync(...)`
   — **await edilmiyor**; `KafkaProducerService.cs:45-48` exception'ı `LogInformation` ile **yutuyor**.
   Broker erişilemezse ekran **başarılı görünür**, kayıt NetTrexAcc'ye **hiç gitmez**, hata yüzeye çıkmaz.
   ⚠️ Kullanıcının loglarında `localhost:9092 Connection refused` sürekli tekrarlıyor — yani test edilen
   fişler NetTrexAcc'ye **gitmemiş olabilir**, kontrol edilmeli.

Tüketici tarafı `NetTrex.MM` içinde **tespit edilmedi** (NetTrex.Accounting'de olması bekleniyor,
o repo bu incelemenin kapsamında değildi).

### Q2 — 🔴 Loading göstergesi HİÇ YOK

`manual-rediscount` klasöründe `LoadPanel`/`LoadIndicator`/`showLoader` **tek kullanım yok**. Tek yapılan
`mrLockToolbar` → yalnız **aksiyon butonlarını** disable ediyor. 6-52 saniyelik Fimple çağrısı boyunca
kullanıcı sadece grileşmiş buton görüyor.

Platform deseni **hazır ve erişilebilir**: `site.js:397-404` → `showLoader()`/`hideLoader()`,
`#DefaultLoadPanel` ana layout'ta tanımlı (`Framework.WebUI/Views/Shared/_FrameworkLayout.cshtml:124-125`).
Fix: `try` öncesi `showLoader()`, `finally`'de `hideLoader()`. **Henüz yapılmadı — kullanıcı onayı bekliyor.**

### Q3 — Kilitleme kısmen var

| Katman | Durum |
|---|---|
| Aksiyon butonları | ✅ `mrLockToolbar` ile kilitleniyor |
| Backend çift-tıklama guard'ı | ✅ `InFlight` (`TransactionId\|tarih`) — ⚠️ **process-içi**, çok pod'da korumaz |
| Ekranın geri kalanı (filtre/grid/tarih/menü) | 🔴 **Serbest** |

`showLoader()` bunu da çözer (`dxLoadPanel` shading tüm ekranı overlay'ler) — Q2 fix'i bu maddeyi de kapatıyor.

### Q3b — 🔴 Çoklu seçimde TIMEOUT riski (kritik, kullanıcı da işaret etti)

- `ExecutionsHandler` satırları **sırayla** işliyor — doğru karar (Fimple idempotent değil).
- Ölçülen satır süresi: **6.2-6.7 sn** (bir kez 51.8 sn).
- WebUI→MM Refit client'ında **timeout tanımlı DEĞİL** (`RefitExtensions.cs:104-109`) → `HttpClient`
  varsayılanı **100 sn**.
- `MaxItems = 200` (`ExecutionsHandler.cs:34`).

**Aritmetik: 100 ÷ ~6.5 = ~15 satır.** Bunun üstünde client timeout'a düşer ama backend `MaxItems=200`'e
izin veriyor → **sözleşme kendi kendisiyle çelişiyor**.

Timeout anında: WebUI hata verir, **MM çalışmaya devam eder** (`ManualRediscountController.Executions`'da
`Mediator.Send(request)`'e `CancellationToken` **geçilmiyor**), kullanıcı **hangi satırların kesildiğini
bilmez** (`Succeeded[]`/`Failed[]` kaybolur).

✅ **Çift fiş koruması ÇALIŞIYOR:** `ExecuteItemAsync` her satırda DB'den durumu yeniden doğruluyor
(`GetRevaluationByValueDateAsync` → `DeriveStatus`); uyuşmazsa `StatusChanged` ile reddediyor.
`finally { this.refresh() }` grid'i yenilediği için tekrar denemede durumlar güncel. **Para riski yok**,
operasyonel karmaşa riski var.

**3 seçenek kullanıcıya sunuldu (karar bekliyor):** (A) UI'da seçim sınırı ~15, (B) client-side chunk +
progress göstergesi *(önerilen)*, (C) explicit timeout artırımı *(tek başına yetersiz — Kestrel/proxy yine koparır)*.

### Q4 — BusinessKey / MessageKey

**Reeskont (T+0):**
- `MessageKey` ← ✅ **Fimple response'undan** (`AccountingEntryMainEntityMapper.cs:112`)
- `BusinessKey` ← ⚠️ Fimple'dan **DEĞİL**; step 20'de elle eziliyor
  (`20_RevaluationAccountingPersistChangeStep.cs:32` → `Transaction.BusinessKey`, yani `TxnMm`/`TxnLoan`'ın)
- ⚠️ `AccEntry` **detay satırlarının** `BusinessKey`'i sabit **0** (`AccountingEntryMainEntityMapper.cs:153`)

**Ters fiş:** `ReverseMessageKey` ← ✅ Fimple'dan (`01_...ExternalSyncStep.cs:38` → mapper →
`AccountingReverseFactory.cs:27` → DB). `BusinessKey` orijinal fişten kopyalanıyor (`:26`).

🔴 **Kritik tuzak:** `01_RevaluationReverseAccountingExternalSyncStep.cs:23` →
`if (!accountingSyncState || MessageKey == 0) return stepContext;`
Orijinal fişin `MessageKey`'i **0 ise Fimple adımı komple atlanır** — ters fiş MM DB'sine yazılır ama
Fimple'a **hiç gitmez**, sessizce. Reeskont fişi Fimple'a gidememişse `MessageKey=0` kalır → ters fiş de
Fimple'sız kesilir → **iki sistem arasında sessiz sapma**. Batch'te de aynı, ama manuel ekranda kullanıcı
hızlı Generate'e bastığı için daha kolay tetiklenir.

### Q5 — Fimple hata metni ekranda

MM tarafı **sağlam**: kullanıcının VS ekran görüntüsü `RefitExtension.cs:44`'ün doğru metni ürettiğini
gösteriyor (`Fimple Error => Code: 3058, Message: Hesap tanımında defter türündeki...`), bu metin
`ExecutionsHandler`'ın catch'inde `Failed[].ReasonDetail`'e yazılıyor.

Kopma WebUI'daydı, **progress-23'te düzeltildi**. Kullanıcı hâlâ "Execution failed." görüyorsa sebebi
WebUI container'ının **yeniden build/restart edilmemiş** olması (fix C# tarafında).

**"Bu hata gösterilmeli mi?" → EVET.** Fimple'ın metni eyleme geçirilebilir bir iş kuralı hatası
(`36099200` defter hesabı için referans türü/no boş olmalı → `AccAccountMap` konfigürasyon hatası).
Batch'te ve MM Transaction ekranında da gösteriliyor, tutarlı olan bu.

### Q6 — 🔴 `T+0`/`T+1` etiketleri YANILTICI

`en.json:4191-4192` / `tr.json:3594-3595`:
```json
"mr-confirm-ExecutionDate": "Voucher value date (T+0)",
"mr-confirm-ReverseValueDate": "Reverse voucher value date (T+1)",
```
`(T+0)`/`(T+1)` **localization metninin içine gömülü sabit** — hesaplanmıyor. Kullanıcı Reverse Value
Date'i Date ile **aynı** (18.08.2026) seçti, etiket hâlâ "(T+1)" diyor ve yanında 18.08.2026 yazıyor →
**kendi kendisiyle çelişen ekran**.

Davranış doğru: `ExecutionsHandler.cs:116` → `request.ReverseValueDate ?? executionDate.AddDays(1)` —
T+1 sadece **boş bırakılırsa** uygulanan varsayılan; açık değer aynen kullanılıyor. **Sadece etiket yalan
söylüyor.** Öneri: `(T+0)`/`(T+1)` etiketten çıkarılsın. **Karar bekliyor.**

### Q7 — 🔴 Revaluation Type: filtreyi seçersen GRID BOŞALIR (bug)

İki taraf **farklı sözlük** kullanıyor:
- **Backend** (`EligibleTransactionsHandler.cs:135-151`): `helper.GetRevaluationReverseType()` →
  `"Eod"` / `"Bod"` / `"Atomic"` — yani **ters fiş kesim zamanlaması**. Canlı yanıtta `"RevaluationType":"Atomic"`.
- **Frontend** (`treasury.json:18-20`): `{ "value": "InterestAccrual", "text": "Interest Accrual" }`

**Çarpışma** (`EligibleTransactionsHandler.cs:96-100`): `request.RevaluationTypes` doluysa ve
`revaluationType`'ı içermiyorsa `items = []`. `"InterestAccrual" ≠ "Atomic"` → **grid komple boşalır**,
`TotalCount` de 0 olur (`:105`), hata mesajı bile yok.

Bugüne kadar patlamamasının sebebi: loglarda `"RevaluationTypes":[]` — filtre **hiç seçilmemiş**.

Ayrıca **A yorumu anlamsız**: `GetRevaluationReverseType()` **global framework parametresi**, tüm satırlar
için aynı → filtre olarak hiçbir işe yaramaz (ya hepsi gelir ya hiçbiri).

**Öneri:** MM için `treasury.json`'daki `revaluationTypes`'ı **boşalt** (`[]`) → `#syncRevaluationTypes`
(`component.js:306`) alanı otomatik **gizler**, bug kalkar. Backend'in `RevaluationType` alanı bilgi
amaçlı yanıtta kalır. FX/DerivSwp/OptFX'te modül sahibi gerçek türleri eklerken **backend'de aynı
sözlüğü** kullanmak zorunda — sözleşmeye yazılmalı. **Karar bekliyor.**

### Q8 — JSON config'lerin işlevi

`wwwroot/js/config/manual-rediscount/treasury.json` (+ diğer 2 ekran). Üç ekran **tek JS bileşenini**
paylaşıyor; ekranlar arası fark kodda değil bu JSON'larda (ADR-MR-016 config-driven tasarım).

| Alan | Etkisi | Yanlış değer verirsen |
|---|---|---|
| `product` | Product dropdown değeri; backend'de `TxnMM`/`TxnLoan` seçimini belirler (`ResolveProductSourceType`) | 🔴 `PRODUCT_UNKNOWN` hatası |
| `moduleCode` | Hangi modül API'sine gidilecek (`RediscountModuleCodes`) | 🔴 "modül için uç tanımlı değil" |
| `subProducts[].value` | Backend'de `ResolveSubProductTypeId` ile Id'ye çevrilir | ⚠️ Switch'te yoksa **filtre uygulanmaz**, hepsi gelir (sessiz) |
| `revaluationTypes[]` | Filtre; **boşsa alan gizlenir** | 🔴 Q7 bug'ının kaynağı |
| `columns[].key` | Backend'in `Data` sözlüğündeki anahtarla eşleşir | ⚠️ Uyuşmazsa **boş hücre** (hata vermez → yazım hatası fark edilmez) |
| `columns[].dataType` | `money`→`#,##0.00`, `rate`→`#,##0.#######`, `date`, `string` | Yanlış biçim |
| `columns[].caption` | Localization **anahtarı** (metin değil) | Anahtar yoksa başlıkta `mr-col-Xyz` görünür |

⚠️ **İki-kaynak kırılganlığı:** Product dropdown'ının **kendisi** JSON'dan değil
`TreasuryRediscountController.GetProducts()`'tan (C#) geliyor. JSON'a ürün eklemek dropdown'a eklemez —
ikisi birlikte güncellenmeli.

## 🔴 Bu turda ortaya çıkan EN ACİL bulgu — IL Generate butonu kırık ve AÇIK

`ExecutionsHandler` ctor'unda (`:27-31`) yalnız `IRevaluationAccountingService` var;
**`ILoanRevaluationAccountingService` enjekte edilmemiş** ve `Product` bazlı dispatch **yok** (sadece
`ModuleCode == "MM"` kontrolü). Batch ikisini de çağırıyor (`RevaluationBatchItem.cs:25`, `:131`).

**Benim hatam:** progress-20'de bunu "açık kalem" diye not ettim, ama **aynı turda `treasury.json`'a
`InterbankLoanTransactions` bloğunu ekledim** (okuma tarafı çalıştığı için). Sonuç: kullanıcı ekranda IL
seçip satır görebiliyor ve **Generate'e basabiliyor** — arka uçta MM'in servisi TxnLoan id'siyle
çağrılıyor, muhtemelen "transaction bulunamadı" ile patlıyor. Okuma için config eklerken yazma tarafının
kırık olduğunu bilerek kapıyı açık bırakmak **yanlış karardı**.

**İki seçenek kullanıcıya sunuldu:** (A) `treasury.json`'dan IL bloğunu geçici çıkar *(hemen, güvenli)*,
(B) `ExecutionsHandler`'a `ILoanRevaluationAccountingService` + dispatch yaz *(gerçek muhasebe fişi
ürettiği için ayrı onay gerekiyor)*. **Karar bekliyor.**

## Ek kapsam farkı — IssueBond

Batch `ProductId == ISSUE` için pipeline'ı **hiç kullanmıyor**, ayrı
`issueBondRevaluationOperationBase.RevaluationExecute(...)` yoluna sapıyor (`RevaluationBatchItem.cs:73-85`).
Manuel ekranın böyle bir dalı **yok** → bir IssueBond işlemi Execute'a gelirse **batch'ten farklı muhasebe**
üretir. Kullanıcının isteğiyle `TxnMmProductTypeId != ISSUE` filtresi kaldırıldığı için (progress-20)
artık ekranda **görünebilir**. "MM'e IssueBond girilmeyecek" dendiği için şu an veri yok — **latent risk**.

## Ölü kod / ad tutarsızlıkları (düşük öncelik, kayda değer)

- `IRevaluationAccountingProductPersister` — **hiç implementasyonu yok**, `20_...:38-43` bloğu hiç
  çalışmıyor (ölü dal).
- `05_RevaluationAccountingAccrualStep.cs` içindeki sınıf adı **`PaymentAccountingAccrualStep`** —
  kopyala-yapıştır kalıntısı.
- Dosya `AccountingReverseReverseFactory.cs`, içindeki sınıf `AccountingReverseFactory` — ad uyuşmazlığı.
- `RevaluationReverseAccountingPipelineContextMapper.cs:18` `ProductSourceType`'ı **sabit `MoneyMarket`**
  yazıyor. Ters fişte source'a bağlı persister kullanılmadığı için şu an zararsız, ama source'a bakan bir
  step eklenirse **sessizce yanlış** davranır.

## Test durumu

- JS: 8 dosya `node --check` → **hepsi geçti**.
- ⚠️ jest **koşulmadı** (`node_modules` yok, bilinen altyapı boşluğu).
- ⚠️ WebUI build bu turda **koşulmadı** (yalnız JS değişti, C# değişmedi).
- ⚠️ Notification davranışı **tarayıcıda doğrulanmadı** — kullanıcı test edecek.

## Açık kalan / karar bekleyen

| Konu | Durum |
|---|---|
| IL Generate kırık — A mı B mi | 🔴 **Karar bekliyor** |
| Loading göstergesi (`showLoader`) | Onay bekliyor |
| Çoklu seçim timeout — A/B/C | Karar bekliyor |
| `T+0`/`T+1` etiketi | Karar bekliyor |
| `revaluationTypes` boşaltma (Q7 bug) | Karar bekliyor |
| Kafka broker erişilemez (`localhost:9092`) | Kullanıcı kontrol etmeli — fişler NetTrexAcc'ye gitmemiş olabilir |
| `FxRate` hardcoded 0 | Fimple bu alanı kullanıyor mu — doğrulanmalı |
| Para birimi bazlı ondalık (JPY/KWD) | Altyapı boşluğu, ayrı iş |
| Execute-hang soruşturması | Parkta (progress-21) |
