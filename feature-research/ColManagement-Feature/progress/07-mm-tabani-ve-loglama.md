# 07 — Taban MM'e Çevrildi + Loglama İyileştirmesi

**Tarih:** 2026-10-08 · **Faz:** 5 (devamı) · `dotnet build` **0 hata, 0 uyarı**

---

## Karar: hangi yapı nereden

**Kullanıcı (2026-10-08):** *"Accounting yapısını Option'dan alıp geriye kalanını MM'den al, ama
alırken sistemi ve kodları **daha iyi hale getirerek** almanı istiyorum çünkü tüm yapıyı görerek alıyorsun."*
Gerekçesi: *"ben 1,5 yıldır MM'de geliştirme yapıyorum, Seq yapısını güzel bir hale getirdim."*

| Alan | Kaynak | Not |
|---|---|---|
| Seq / Serilog loglama | **MM** | Biçim korundu, 9 açık kapatıldı (§3) |
| `ExternalHttpLoggingDelegateHandler` | **MM** | `>>>>>>>>>` biçimi + `PrettyPrint` + `StripVerboseFields` aynen; **maskeleme eklendi** |
| `RefitExtension` zarf açıcılar | **MM** | `LooksLikeJson` + `Truncate` guard'ları MM'de **zaten vardı** |
| Auth / Keycloak / Fimple | **MM** | Kayıt sırası ve camelCase/PascalCase ayrımı birebir |
| `Api` / `Batch.Api` Startup | **MM** | Localization · cookie policy · zengin Swagger · `AddGlobalSettings` |
| `AddData_AfterConfigure` | **MM** | Takvim yüklemesi Startup'ta değil Data katmanında |
| `QueryableExtension` | **MM** | Kök provider tutucu; grid durum filtreleri Faz 6 |
| Batch DI deseni | **MM** | `AddBatchItems`/`AddBatchMapper`/`AddBatchServices` |
| **Accounting + pipeline** | **OptionsFX** | `IPipelineStep`/`IPipelineBuilder`/`IPipelineRunner` + `LoggingDecorator` |
| **Referans verisi + Consumer** | **OptionsFX** | 🔴 Gerekçe §4 |

---

## 2. MM'den alırken yapılan iyileştirmeler

| # | MM'deki hâli | Bizde | Niçin |
|---|---|---|---|
| 1 | `appsettings`'te Elasticsearch sink'i, `Authorization=Basic ZWxhc3RpYzpGaTIwMjJAKiE=` | **Sink kaldırıldı** | Base64 **şifreleme değil kodlama** — repoda düz metin kimlik bilgisi |
| 2 | `client_secret` düz metin Seq'e | `Mask()` + `GeneratedRegex` | Token ucu form-urlencoded; `PrettyPrint` JSON olmayan gövdeyi aynen döndürüyor |
| 3 | Dead `Worker : BackgroundService` sınıfı `Startup.cs` içinde (kayıtlı değil) | **Alınmadı** | Ölü kod |
| 4 | `ApplicationSettings:EnableSensitiveDbLogs = true` | **`false`** | Parametre değerleri log'a düşerse müşteri verisi Seq'e sızar |
| 5 | Mojibake yorumlar (`T�m endpoint'leri...`) | Temiz yazıldı | Kodlama bozulması |
| 6 | `supportedCultures` dizisinde `en-US` **iki kez** | Tek | Kopyala-yapıştır artığı |
| 7 | `Consumer`'da `app.UseRequestLocalization(locOptions.Value)` null kontrolsüz | `if (locOptions is not null)` | `GetService` null dönebilir |
| 8 | `Batch`/`Consumer` Startup'ta `base.AfterConfigureService` çağrısı **ortada** | Başta | Taban sınıfın kayıtları önce |

---

## 3. 🔴 Loglama — 9 açık kapatıldı

Tam doküman → **`NetTrex.Collateral/.ai-agent/reference/logging.md`**

🔑 **Hepsi konfigürasyon.** Modülde tek satır Serilog kodu yok (MM'de de yok); framework
`appsettings`'teki `Serilog` bölümünü okuyor. Gereken enricher paketleri **zaten geliyor**
(`Enrichers.Environment` · `Enrichers.CorrelationId` · `Enrichers.ClientInfo` · `Expressions`)
→ **yeni paket eklenmedi, karmaşıklık artmadı**.

| # | Açık | Düzeltme |
|---|---|---|
| 1 | 🔴 **"Bu log'u hangi process yazdı?"** — makine/pod alanı **yok**, `Environment` iki tarafta da `Development`. 2026-09-04'te local'in yazdığı satır cluster'a atfedildi → **tamamen yanlış kök-neden hikâyesi** | `WithMachineName` (K8s'te pod adı) + `WithEnvironmentName` + `WithProcessId` |
| 2 | `Application: "Client"` — üç servis, yedi modül aynı etiket | `ColManagement.Api` / `.Batch` / `.Consumer` + `Module` property'si |
| 3 | HTTP isteği ile ona bağlı Fimple çağrıları Seq'te bağlanmıyor | `WithCorrelationIdHeader("X-Correlation-Id")` — tek arama bütün zinciri getirir |
| 4 | Elasticsearch sink'inde düz metin kimlik bilgisi | Sink kaldırıldı |
| 5 | `MinimumLevel: Verbose` + Seq `restrictedToMinimumLevel: Verbose` = sel | `Information`; teşhis **ortam değişkeniyle** açılır, yeniden derleme yok |
| 6 | EF SQL süzülüyordu — 2026-09-10 teşhizinde gerekti, kimse nasıl açılacağını bilmiyordu | `Database.Command` override'ı `appsettings`'te **görünür**, yorumunda açma komutu yazıyor |
| 7 | Büyük Fimple gövdeleri Seq'i şişiriyor | `Destructure`: depth 6 · string 4000 · collection 50 |
| 8 | `client_secret` düz metin | Maskeleme (§2.2) |
| 9 | Yalnız `/health%` filtreleniyordu | `/swagger%` de eklendi |

**MM'den aynen korunanlar:** `>>>>>>>>> {Method} {Url}` biçimi · `PrettyPrint` · `LooksLikeJson`
guard'ı · `StripVerboseFields` (`ExecutionTrace`) · `Sinks.Async` + Console · `WithExceptionDetails` ·
`[LoggerMessage]` kaynak üreticili loglar.

`logging.md` §4'te **Seq arama tarifleri** var (makine ayrımı, correlation zinciri,
`LogicalReference` ile işlem yaşam döngüsü, yavaş istekler, EF SQL).

---

## 4. 🔴 Consumer OptionsFX'te kaldı — gerekçe

Kullanıcı *"Consumer yapılarını da MM'den al"* dedi, **ama aynı cümlede** *"daha iyi hale getirerek"*
dedi. MM'in Consumer'ı ölçüldü ve **daha iyi hale getirmek = almamak** çıktı:

### MM Consumer'ında ölçülen kusurlar
| # | Dosya | Sorun |
|---|---|---|
| 1 | `KafkaTopicMessageConsumer.StartConsuming` | 🔴 **`public async void`** — içindeki istisna yakalanamaz, **process'i düşürür** |
| 2 | `KafkaMessageConsumerManager` | Topic başına **`new Thread(...)`** — 25 topic = 25 OS thread'i, her biri `Consume()`'da bloke |
| 3 | `KafkaTopicMessageConsumer` | `catch (Exception ex) { throw ex; }` — **stack trace'i sıfırlıyor** (`throw;` korurdu). Üstelik `async void` içinde, hiçbir yere gitmiyor |
| 4 | aynı | `mediator.Send(result).GetAwaiter().GetResult()` — sync-over-async |
| 5 | `KafkaConsumerBuilder.Build()` | `consumerBuilder.Build()` **üç kez** çağrılıyor, ikisi atılıyor → her çağrıda sızan bağlantı |
| 6 | aynı | `adminClient.Build()` sonucu atılıyor, `Dispose` edilmiyor |
| 7 | `KafkaTopicMessageConsumer` | `requestCreator.CreateRequest()` **her mesajda yeni `Dictionary`** üretiyor |
| 8 | `RequestCreatorFactory` | 25 topic→tip eşlemesi **elle** bakılıyor |

### Maliyet farkı (ölçüldü)
| | MM | OptionsFX |
|---|---|---|
| Consumer dosyası | **110 dosya / ~1.980 satır** | 36 dosya |
| Referans verisi handler'ı | Her tablo için elle (`Currency`, `Calendar`, `Holiday`, `DateBasis`, `FxRate`, `FxRateDetail`, `InterestRate`, …) | **0** — `AddCoreDataConsumer(Slices)` paketten getiriyor |
| Topic listesi | Elle, 25 satır | `CoreDataTopics.For(Slices)` — **türetiliyor** |
| Thread/offset/retry | Elle | KafkaFlow |

🔑 **Asıl kazanç tek liste:** `ColManagementCoreData.Slices` hem `EfDbContext` modelini
(`ApplyCoreDataModel`) hem Kafka topic aboneliklerini (`CoreDataTopics.For`) besliyor →
ikisinin ayrışması **yapısal olarak imkânsız**. MM'de bunlar **iki ayrı elle yazılmış liste**;
`Data.Domain` 120 dosya (OptionsFX'te 30).

✅ **Karar:** Consumer **KafkaFlow + CoreDataSlice** kaldı. MM'den alınan: `Consumer.Api/Startup`'ın
**dış kabuğu** (localization · cookie policy · `AddGlobalSettings` · `AddData_AfterConfigure`).

⬜ **Kullanıcı itiraz ederse** MM'in `IHostedService` + `KafkaConsumerBuilder` kabuğuna geçilebilir —
ama o zaman ~15 referans handler'ı + DTO'su + entity'si **elle yazılır**.

---

## 4b. 🔴 appsettings anahtar seti birleştirildi

**Kullanıcı (2026-10-08):** *"projelerin appsettings'leri var, orada aynı parametreler
isimlendirilirken bile farklı isimlendirilmiş; sonra da ben bunları docker-compose override'ta
kullanıyorum — aynı olsun tüm projelerde."*

**MM'de ölçülen tutarsızlık:**

| Kavram | Api | Batch | Consumer |
|---|---|---|---|
| Kafka adresi | `Kafka:BootstrapServers` | aynı | 🔴 `ApplicationSettings:KafkaBootstrapServers` |
| Seq adresi | `Serilog:WriteTo:0:Args:serverUrl` | aynı | 🔴 **ayrıca** `Setting:SerilogSeqLoggerUrl` |
| Redis | `FeatureFlags:Redis:ConnectionUrl` | aynı | 🔴 **ayrıca** `ConnectionStrings:RedisConnectionString` |
| `ApplicationName`/`EnvironmentName` | var | var | 🔴 **yok** |
| Fimple · Keycloak · CommonApi · AccountingApi | var | var | 🔴 **yok** |

🔑 **Sonucu MM'in kendi `docker-compose.override.yml`'inde görünüyor** — aynı değer iki ayrı adla:
```yaml
- ApplicationSettings__KafkaBootstrapServers=192.168.10.191:31192
- Kafka__BootstrapServers=192.168.10.191:31192
- ConnectionStrings__RedisConnectionString=192.168.10.191:30379
- FeatureFlags__Redis__ConnectionUrl=192.168.10.191:30379
```
🔴 Biri güncellenip öteki unutulursa uygulama **eski değeri** okur ve hata vermez.

✅ **Düzeltme:** üç `appsettings.json`'da **56 anahtar, birebir aynı set**. Yalnız 4 anahtarın
**değeri** farklı: `Assemblies:Handler` · `Assemblies:Validator` ·
`ApplicationSettings:ApplicationName` · `Serilog:Properties:Application`.
Doğrulandı: script üç dosyanın anahtar kümelerini karşılaştırıyor, fark **0**.

Ayrıca: Kafka tek yerde (`Kafka:*`), Redis tek yerde, Seq tek yerde.
`docker-compose.yml` + `.override.yml` yazıldı — üç servis **aynı değişken adlarını** kullanıyor,
tüm değerler yer tutucu.

Tam doküman → **`NetTrex.Collateral/.ai-agent/reference/configuration.md`**

---

## 4c. Kod yorumu disiplini

**Kullanıcı (2026-10-08):** *"ColManagement geliştirmesinde çok çok gerekmediği sürece yorum satırı yazma."*

Yazdığım açıklayıcı yorumlar budandı: 14 dosya, prose bloklar kaldırıldı.
**Kalanlar (88 `.cs` dosyasında 46 satır):**
- İleriki fazlarda açılacak **yorumlanmış kod satırları** (kullanıcı bunları açıkça istemişti)
- Koddan çıkarılamayan tek satırlık UYARI: çift `DbContext` kaydı · `client_secret` maskesi ·
  JSON olmayan hata gövdesi · `BatchItem` adlandırma zorunluluğu · logical date'in `Trex` altında olması

`<summary>`/`<remarks>` **yok**.

---

## 5. Doğrulama

```
dotnet build NetTrex.ColManagement.sln → Build succeeded, 0 Error(s), 0 Warning(s)
```
- ✅ Üç `appsettings.json`'ın anahtar kümeleri karşılaştırıldı → **fark 0** (56/56)
- ✅ `appsettings.json` ×3 JSON geçerli
- ✅ Sır taraması temiz — yalnız `__PLACEHOLDER__`
- ⚠️ **Çalıştırılmadı** — DB/Kafka/Seq yok. Log konfigürasyonu ilk ayağa kalkışta doğrulanacak
  (`MachineName`/`CorrelationId` property'leri geliyor mu, maskeleme çalışıyor mu)

---

## 6. Açık kalanlar

| # | Ne |
|---|---|
| — | Framework'ün `FeatureFlags:Serilog:RequestLogging` anahtarının `UseSerilogRequestLogging`'i mi çağırdığı **okunmadı** (paket içi) — `Elapsed` property'si ona bağlı |
| — | `NetTrex.Core.Paging` paketi henüz eklenmedi (MM'de `Api.Services`'te) — grid uçları yazılınca (Faz 6) |
| — | `appsettings.Development.json` · `docker-compose.override.yml` yok |
| `A-08` | Modül kodu — `CM.` olarak koda girdi |
