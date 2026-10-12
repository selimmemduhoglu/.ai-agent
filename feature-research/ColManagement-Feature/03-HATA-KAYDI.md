# 03-HATA-KAYDI.md — Gördüğüm Hatalar / Eksikler / Düzeltilmesi Gerekenler

> **Amaç:** OptionsFX ve MM'den kod taşırken gördüğüm **her** problem burada numaralı durur.
> Kullanıcı geliştirme bittikten sonra tek tek bakıp hangilerinin düzeltileceğine karar verecek.
>
> 🔴 **Çalışma kuralı (kullanıcı, 2026-10-09):** *"Hem yavaşlamamak hem de neden bu şekilde yapıldığını
> bilmiyorum, belki bilinçlidir belki bilinçsizdir. Sen MM ve Option'daki gibi yap, MM'i önceliklendirerek
> aynısını geçir gitsin… açık gördüğün yerleri bu dosyaya yaz, ben sonra bakacağım ve mantıklı olanları yapacağız."*
> → **2026-10-09'dan itibaren bulunan açık DÜZELTİLMEZ**, kod MM (öncelikli) / OptionsFX'teki gibi taşınır,
> açık **buraya** yazılır. Bu tarihten önce düzeltilmiş olanlar §A'da "✅ bizde düzeltildi" olarak duruyor —
> geri alınması istenirse orada işaretli.
>
> > 🔴 **Kapsam (kullanıcı, 2026-10-09):** *"OptionFx'teki yanlışlar beni ilgilendirmiyor."* → Yalnız **ColManagement kodunu etkileyen**
> açıklar yazılır. OptionsFX'in kendi içindeki, bize taşınmamış kusurları yazılmaz (H-011 · H-075 · H-081 bu yüzden silindi; numaralar boş kalır).
>
> **Yeni madde eklerken:** sıradaki numarayı ver, eski numaraları **değiştirme**. Ölçüm yoksa "tespit edilmedi" yaz.

**Durum sütunu:** ✅ ColManagement'ta düzeltildi · ⏸ aynen taşındı (açık bizde de var) · ➖ taşınmadı · 📝 karar bekliyor
**Repo sütunları:** 🔴 açık orada var · ✅ orada yok/düzgün · — ilgisiz/karşılığı yok

---

## A. Altyapı / DI / Startup

| # | Yer | Sorun | Etkisi | OFX | MM | Durum | Öneri |
|---|---|---|---|:-:|:-:|:-:|---|
| H-001 | `QueryableExtension.SetCalendar` (Startup) | `CreateScope()` hiç kapatılmıyor, scoped `IHelper` statik tutuluyor | Tek `DbContext` uygulama ömrü boyunca tüm isteklere paylaşılır (thread-safe değil) | 🔴 | ✅ | ✅ | Kök provider + çağrı başına scope (MM'in hâli) |
| H-002 | `Batch.Api/Startup` | `DatabaseProvider.PostgreSql`, Api/Consumer `MsSql` | Batch farklı SQL lehçesi üretir | 🔴 | ✅ | ✅ | `MsSql` |
| H-003 | `Batch.Api/Startup` | CORS + localization `AfterConfigure`'da | Endpoint eşlendikten sonra eklenen middleware etkisiz olabilir | 🔴 | ✅ | ✅ | `BeforeConfigure` |
| H-004 | `Batch.Api/Startup` · MM `Consumer` | `locOptions.Value` null kontrolsüz · `en-US` iki kez | Teorik NRE | 🔴 | 🔴 | ✅ | null guard |
| H-005 | `Consumer.Api/Startup` | `StartKafkaConsumerService()` + `StartConsumerService()` → bus iki kez kuruluyor | Aynı grupta çift consumer | 🔴 | — | ✅ | Tek çağrı |
| H-006 | `Consumer.Api/Startup` | `AddConsumerMapping()` iki kez | Zararsız tekrar | 🔴 | — | ✅ | Tek |
| H-007 | `IKafkaConsumerSettingsFactory` | Kayıtlı, hiçbir yerde kullanılmıyor | Ölü kod | 🔴 | — | ✅ silindi | — |
| H-008 | `RegisterPipelineSteps` | `IPipelineBuilder<>` iki kez kaydediliyor | Zararsız tekrar | 🔴 | — | ✅ | Tek |
| H-009 | MM `Startup` | `base.AfterConfigureService` çağrısı metodun ortasında (Batch/Consumer) | Taban kayıtları sonra gelir, override sırası belirsiz | — | 🔴 | ✅ | Başa al |
| H-010 | MM `Startup` | Kayıtsız ölü `Worker : BackgroundService` | Ölü kod | — | 🔴 | ➖ | Sil |
| H-012 | Batch `/health` | OFX `IndexController`'da `/health` var + ayrı `HealthCheckController` eklenirse aynı rota | `AmbiguousMatchException` | — | — | ✅ | Tek uç |

## B. Hata yönetimi / Seq görünürlüğü

| # | Yer | Sorun | Etkisi | OFX | MM | Durum | Öneri |
|---|---|---|---|:-:|:-:|:-:|---|
| H-013 | `Api.Services/Handlers/ExceptionHandler` | Hatayı yakalayıp `999` döner, **log'lamaz** | İstisna Seq'e hiç düşmez (2026-09-04 Manuel Reeskont'ta elle `LogError` eklenmişti) | 🔴 | 🔴 | ✅ | `LogError(ex, RequestName)` |
| H-014 | `ExceptionHandler` | `ExternalApiException` dalı genel dalla aynı yanıtı üretiyor | Ölü dal | 🔴 | 🔴 | 📝 | Ya ayrı `MessageCode` ver ya birleştir |
| H-015 | `LoggingDecorator` (pipeline) | Her adımın girdi/çıktısını `Information`'da log'luyor | Seq seli + hassas veri | 🔴 | — | ✅ alınmadı | Kaldır / `Debug` |
| H-016 | `RefitExtension.GetFimpleContentOrThrowAsync` | JSON olmayan hata gövdesi → Newtonsoft `NaN` hatası; HTTP kodu ve gövde kaybolur | Teşhis kaybı | 🔴 | ✅ (2026-08-20) | ✅ | Guard + `HTTP {kod} Body` |
| H-017 | `RefitExtension` | Genel `catch` iç istisnayı atıyor | Kök neden kaybolur | 🔴 | 🔴 | ✅ | `ex` taşı |
| H-018 | `Data/Refit/RefitExtensions.ToContent()` | API hata dönerse **boş `T`** döner + `throw ex` | Hata yutulur; çağıran boş listeyle devam eder | 🔴 | 🔴 | ✅ | `DataServiceException` (HTTP + gövde) |
| H-019 | `AccountingEngineDataFactory` | `IsSuccess=false` → sessizce boş kural seti | Fiş üretilmez, yanıltıcı "zero amount" hatası | 🔴 | 🔴 | ✅ | Fırlat |
| H-020 | `KafkaProducerService` | Hata `LogInformation(e.Message)` — stack/topic/key yok, Seq'te Error değil | Kafka kaybı görünmez | 🔴 | 🔴 | ✅ | `LogError(e, Topic, Key)` |
| H-021 | `KafkaProducerService` | Scrutor `*Service` taramasıyla **scoped** kaydoluyor | İstek başına yeni Kafka bağlantısı | 🔴 | 🔴 | ✅ | Singleton |
| H-022 | `MessagingService` | `_ = SendAsync(...)` fire-and-forget | Muhasebe/bildirim mesajı kaybolabilir, çağıran bilmez | 🔴 | 🔴 | ✅ | `await` |
| H-023 | `BatchNotificationFacade` | Kafka mail başarısızsa Fimple API'sine düşen `catch` hiç çalışmıyor — producer hatayı yutuyor | Mail hiç gitmez, yedek yol ölü | 🔴 | 🔴 | ⏸ (ölü `catch` kaldırıldı) | Producer'dan hata sonucu dön, yedek yolu ona bağla |
| H-024 | `ScheduleHandler` | Hangfire kayıt hatası yakalanıp log'lanmıyor | Zamanlanmış EOD/BOD kurulmadı, kimse bilmiyor | 🔴 | 🔴 | ✅ | `LogError` |
| H-025 | `LogicalDateUpdateBatchItem` | `(bool)response.Content?.IsSuccess` | HTTP hatasında NRE | 🔴 | ✅ | ✅ | Desen eşleşmesi |

## C. Güvenlik / yapılandırma

| # | Yer | Sorun | Etkisi | OFX | MM | Durum | Öneri |
|---|---|---|---|:-:|:-:|:-:|---|
| H-026 | `appsettings.json` | Canlı DB parolası, Seq apiKey, Keycloak `ClientSecret` repoda | Kimlik bilgisi sızıntısı | 🔴 | 🔴 | ✅ yer tutucu | Secret/ortam değişkeni |
| H-027 | MM `appsettings` Elasticsearch sink | `Authorization=Basic …` (base64 = kodlama, şifre değil) | Kimlik bilgisi sızıntısı | 🔴 (URL) | 🔴 | ✅ sink yok | Kaldır |
| H-028 | `ExternalHttpLoggingDelegateHandler` | Token ucunun form gövdesi (`client_secret`) düz metin log'lanıyor | Seq'te sır | — | 🔴 | ✅ maske | Maskele |
| H-029 | `ApplicationSettings:EnableSensitiveDbLogs` | `true` | SQL parametreleri (müşteri verisi) log'a | 🔴 | 🔴 | ✅ `false` | `false` |
| H-030 | MM `appsettings` ×3 | Aynı değer üç projede farklı adla (`Kafka:BootstrapServers` / `ApplicationSettings:KafkaBootstrapServers`, Redis iki ayrı anahtar…) | Biri güncellenip öteki unutulursa eski değer okunur | — | 🔴 | ✅ 57 anahtar birebir | Tek ad |
| H-031 | Serilog | Makine/pod alanı yok, `Application: "Client"` her serviste aynı, correlation zinciri yok, `Verbose` seli, `/swagger` filtrelenmiyor | "Bu log'u hangi process yazdı" sorulamıyor (2026-09-04 yanlış kök neden) | 🔴 | 🔴 | ✅ (`reference/logging.md`) | Enricher'lar |
| H-032 | NuGet audit | `AutoMapper 14.0.0` (high) · `Microsoft.OpenApi 2.4.1` (high) · `SixLabors.ImageSharp 2.1.11` · `System.Security.Cryptography.Xml 8.0.2` | Bilinen güvenlik açıkları (dolaylı, framework paketlerinden) | 🔴 | 🔴 | ⏸ | Framework paket sürümleri |
| H-033 | `FimpleAuthService` | İlk eşzamanlı isteklerde kilitsiz paralel login | Gereksiz Keycloak çağrısı (zararsız) | 🔴 | 🔴 | ⏸ | `SemaphoreSlim` |
| H-034 | `RefitDefaultsExtension` | `RefitSettings` ve `RefitSettingsPascalCase` ikisi de adları olduğu gibi yazıyor; `RegisterRefitClientCamelCase` camelCase **üretmiyor** | Yanıltıcı ad | 🔴 | 🔴 | ⏸ | Yeniden adlandır |

## D. Veri / EF

| # | Yer | Sorun | Etkisi | OFX | MM | Durum | Öneri |
|---|---|---|---|:-:|:-:|:-:|---|
| H-035 | `AddScoped<IDataContext, EfDbContext>()` + `AddTreasyDbContext<EfDbContext>()` | Aynı scope'ta **iki ayrı** `DbContext` | `EfDbContext` enjekte eden sınıf repository tracker'ını görmez (2026-09-10 ölçüldü) | 🔴 | 🔴 | ⏸ (uyarı yorumu) | Tracker/teşhis kodu `IDataContext` almalı |
| H-036 | EF config: muhasebe ×3 · `BatchItem` · `BatchSet` | DB'de IDENTITY değil ama `ValueGeneratedNever` yok | Insert'te EF Id'yi göndermez / tutarsız | 🔴 | — | ✅ | `ValueGeneratedNever()` |
| H-037 | EF config: `FlowTransitionData` | `ValueGeneratedOnAdd`, ama kod Id'yi kendisi üretiyor ve DB IDENTITY değil | Insert sorunu | 🔴 | — | ✅ | `ValueGeneratedNever()` |
| H-038 | `NumberGeneratorDataManager` | `int.Parse($"{önek}{sayı}")` — 2 haneli önekle ~10 milyon kayıt tavanı; muhasebe Id'leri `int` | Tavan aşılınca `OverflowException` | 🔴 | 🔴 | ⏸ | `long` |
| H-039 | `FlowDataProvider` | Cache boşsa her çağrıda Common API'ye gider, sonucu cache'e yazmaz | Gereksiz HTTP | 🔴 | 🔴 | ⏸ | Yazmayı ekle (ya da Common'ın doldurduğunu doğrula) |
| H-040 | `FlowDataProvider.UpsertFlowData` | `DateTime.Now` | Hard Rule 12 | 🔴 | 🔴 | ✅ | `IDateTimeProvider` |
| H-041 | `FlowEntity.PreviousStateMaker` | `string?`, paketteki `IFlowEntity` non-null | 2 derleme uyarısı | 🔴 | 🔴 | ⏸ | Paket sözleşmesi |
| H-042 | `AccountingEntryMain.Transaction` | Required navigation → `.Select()`'te INNER JOIN, orphan satır sessizce düşer (2026-08-18 MM) | Sayım/liste ayrışır | 🔴 | 🔴 | ⏸ (Txn entity'siyle gelecek) | EXISTS / skaler subquery |
| H-043 | `States.GetStateIdList` / `GetStateName` | Bilinmeyen filtre/Id'de NRE | — | 🔴 | — | ✅ | guard |
| H-044 | `FimpleSendNotificationResponse` | `class X(...)` — primary ctor parametresi property değil | Yanıt alanları hep boş | 🔴 | — | ✅ `record` | — |
| H-045 | `Helper.GetFXRateTransactionChartAbmAsync` | Transaction ABM'si için **Accounting** anahtarını okuyor | Yanlış kur tarafı | 🔴 | — | ✅ | Doğru anahtar |

## E. Batch / takvim

| # | Yer | Sorun | Etkisi | OFX | MM | Durum | Öneri |
|---|---|---|---|:-:|:-:|:-:|---|
| H-046 | `BatchDataProvider.IsWorkingDay/IsHalfWorkingDay` | Sabit `true` | Batch tatil günü de koşar | 🔴 | ✅ | ✅ MM'in hâli | — |
| H-047 | `AddQuant()` | Takvim için tüm QuGet fiyatlama kütüphanesi (eğri, volatilite, greek) açılıyor | Gereksiz bağımlılık | 🔴 | ✅ yok | ✅ MM `CalendarHelper` | — |
| H-048 | `DateTimeCheckBatchItem` | Yalnız `WeekdaysOnly (1)` kontrol ediliyor; `HolidaysButNotWeekends (2)` için guard yok | O müşteride batch hafta sonu koşar | 🔴 | 🔴 | ⏸ | 2 için de kontrol |
| H-049 | `DateTimeCheckBatchItem` (MM) | `int.Parse(GetFrameworkParameter(SystemWDFlag))` | Parametre yoksa `ArgumentNullException` | — | 🔴 | ⏸ | `TryParse` / `IHelper.GetSystemWDFlag` |
| H-050 | `CalendarHelper.IsWorkingDay` | `Calendar` satırında `StateId` filtresi yok | Silinmiş/onaysız takvim satırı çalışma günü sayılır | — | 🔴 | ⏸ | Doğrulanmış durum filtresi (Common'ın ne gönderdiği ölçülmeli) |
| H-051 | `BatchNotificationFacade` (OFX) | Batch set'i log listesinin `First()`'ünden okuyor | Log yoksa patlar | 🔴 | ✅ DB'den | ✅ MM'in hâli | — |
| H-052 | `BatchNotificationFacade` | Mail konusu `DateTime.UtcNow` | Gece yarısından sonra koşan EOD ertesi günün tarihini taşır | 🔴 | 🔴 | ✅ `ExecDate` | — |
| H-053 | `BatchRunOperation` | Kök `BatchItem` yoksa `First()` → "Sequence contains no elements" · 5 kopya metot · BOD'da `PageUID` atanmıyor | Anlamsız hata | 🔴 | 🔴 | ✅ | Tek `Execute` + anlamlı hata |
| H-054 | `BatchSignalRStrategy` | `HubConnectionsEodUrl` yoksa `null` ile bağlantı | Sessiz başarısızlık | 🔴 | 🔴 | ✅ hata + anahtar eklendi | — |
| H-055 | `BatchSignalRStrategy` | `.Wait()` + bağlanamazsa sessizce geçer · `Thread.Sleep(200)` ile eşzamanlılık yaması | Bloklama, log yok | 🔴 | 🔴 | ⏸ (MM gibi) | Kök neden (hub tarafı) |
| H-056 | `IndexController` | `GET /schedule` durum değiştiriyor (Hangfire job'larını yeniden kuruyor) | GET idempotent değil | 🔴 | 🔴 | ⏸ | `POST` (WebUI çağrısı kontrol edilmeli) |
| H-057 | `BatchDataProvider.UpdateBatchLog` | `EndDate = DateTime.Now` | Hard Rule 12 | 🔴 | 🔴 | ✅ | `IDateTimeProvider` |

## F. Kafka Consumer (MM)

| # | Yer | Sorun | Etkisi | OFX | MM | Durum | Öneri |
|---|---|---|---|:-:|:-:|:-:|---|
| H-058 | `KafkaTopicMessageConsumer.StartConsuming` | `public async void` | İçindeki istisna process'i düşürür | ✅ KafkaFlow | 🔴 | ➖ (OFX Consumer alındı) | KafkaFlow |
| H-059 | `KafkaMessageConsumerManager` | Topic başına `new Thread` | 25 topic = 25 bloke thread | ✅ | 🔴 | ➖ | — |
| H-060 | `KafkaTopicMessageConsumer` | `throw ex` (stack sıfırlanır) · sync-over-async · her mesajda yeni `Dictionary` | — | ✅ | 🔴 | ➖ | — |
| H-061 | `KafkaConsumerBuilder.Build()` | `Build()` üç kez, `adminClient` dispose edilmiyor | Bağlantı sızıntısı | ✅ | 🔴 | ➖ | — |
| H-062 | MM referans verisi | Topic listesi ve DbContext modeli iki ayrı elle yazılmış liste | Ayrışma riski | ✅ `CoreDataSlice` | 🔴 | ➖ | — |

## H. Muhasebe (2026-10-09 taşıma)

| # | Yer | Sorun | Etkisi | OFX | MM | Durum | Öneri |
|---|---|---|---|:-:|:-:|:-:|---|
| H-065 | `Accounting.*` (Manager · EngineModel · validator'lar · event/type enum'ları · contexts) | Opsiyon operasyonlarına özel: `Opening/PremiumSettlement/Maturation/Revaluation/ExerciseSettlement`, `AccountingEngineModel` opsiyon alanları (194 satır) | ColManagement'ın olayı (TxnDetail değişikliği, nazım bacağı) yok; şu an derleniyor ama kullanılmıyor | — | — | ⏸ aynen taşındı | Detail olayı + nazım kararı (A-25) gelince ColManagement modeline çevir |
| H-066 | `AccountingPathBuilder` | Path `…/{SIDE}/{OPTIONTYPE}/{ccy}` opsiyon şeması | ColManagement path'i belirsiz | 🔴 (opsiyona özel) | MM kendi `PathExtensions` | ⏸ | ColManagement path'i A-25 ile |
| H-067 | `AccountingPathBuilder` | Kıymetli maden dalı QuGet'e (`IsPreciousMetalLeg`) bağlı · Singleton olup scoped `ICurrencyPairService` alıyordu (captive) | QuGet bağımlılığı | 🔴 | ✅ yalnız LCY/FCY | ✅ MM gibi LCY/FCY (zorunlu: QuGet yok) | — |
| H-068 | `AccountingService.HandleMap` | Her `GenerateAccounting` çağrısında Accounting API'ye `SelectMap` + `.GetAwaiter().GetResult()` (sync-over-async, cache yok) | Fiş başına HTTP; satır sayısıyla yavaşlar | 🔴 | 🔴 | ⏸ | `AccountingEngineDataFactory.GetAccountMapData()` (cache'li) kullan |
| H-069 | `IFimpleApi` / `FimpleDataService` | Opsiyona özgü uçlar da taşındı (müşteri uyum skoru, KKB, birim değer havuzu…) | Kullanılmayan yüzey | 🔴 | 🔴 | ⏸ aynen | Faz sonunda kullanılmayanları temizle |
| H-070 | `IFimpleApi` | Uç yolları `/Fx/TreasuryTransactions/...` | ⚠️ Hata değil: MM de aynı yolu kullanıyor (Fimple'ın ortak hazine ucu) — not olarak | ✅ | ✅ | — | — |

## I. Consumer · Data · Common (2026-10-09 taşıma)

| # | Yer | Sorun | Etkisi | OFX | MM | Durum | Öneri |
|---|---|---|---|:-:|:-:|:-:|---|
| H-071 | `ICountryDataManager` · `IPortfolioRepository` | Arayüz var, implementasyon yok, hiçbir yerde kullanılmıyor | Ölü kod | 🔴 | — | ⏸ aynen | Sil |
| H-072 | `CustomerCreateHandler` / `PortfolioCreateHandler` | `(int)request.Id` — Kafka mesajı `long` Id taşıyor, entity `int` | `int.MaxValue` üstünde sessiz taşma (checked değil) | 🔴 | 🔴 | ⏸ | Common'daki Id tipiyle hizala |
| H-073 | `ProductDefinitionEntity.Id` | `int` — kullanıcı kuralı K-05: PK `long` | Kural ihlali (modülün kendi tablosu) | 🔴 | 🔴 | ⏸ aynen | DB script'i (Faz 4) ile birlikte `long` |
| H-074 | `TransactionDocumentDataManager` | `StateDate = DateTime.Now` (2 yer) | Hard Rule 12 | 🔴 | — | ⏸ | `IDateTimeProvider` |
| H-076 | `RequestTypeCodes` | `OptFXTransactionRequest` sabiti | Flow set adı modüle özel olmalı | — | — | ✅ `ColManagementTransactionRequest` (kimlik değişikliği, düzeltme değil) — Common'da FlowSet kaydı gerekecek | Faz 4 script'i |
| H-077 | `Batch.Api/Startup` | `AddDocumentManagementDI` Batch'te de var (OFX'te yalnız türev formu kullanıyor) | Gereksiz kayıt olabilir | 🔴 | ✅ yok | ⏸ OFX gibi | Batch'te doküman işi yoksa kaldır |
| H-078 | Common `Accounting/Shared` | `PaymentMessageTransactionModel` + mapper'ı ve Opening/Exercise TermPayment mapper'ları opsiyon işlem modeline bağlı | Ödeme mesajı ertelendi (A-26) | — | — | ➖ taşınmadı | Ödeme kararıyla |

## J. Api tanım uçları (2026-10-09 taşıma)

| # | Yer | Sorun | Etkisi | OFX | MM | Durum | Öneri |
|---|---|---|---|:-:|:-:|:-:|---|
| H-079 | Tanım uçlarının route adları | OFX: `currencies/f-key` · `customers/overview` · `portfolios/f-key` — MM: `currency/select-f-key` · `customer/select-f-key` · `portfolio/select-f-key` | 🔴 UI `Treasy.MM.UI`'den kopyalanacak (yol haritası) → MM route'larını çağırır, bizim uçlar OFX adında → **404** | — | — | ⏸ OFX adları | UI fazında karar: route'ları MM'e çevir **ya da** UI'yi OFX adlarına uyarla |
| H-080 | MM'de olup alınmayan uçlar | `ProductDefinition` tam CRUD + maker-checker (13 uç; OFX'te yalnız `overview`) · `PaymentInstructionType/overview-customer` · `Customer/select-corporate-f-key` · `FinancialInstitution/customer-accounts` (OFX'te `customers/accounts`) | UI'de karşılığı aranırsa yok | — | — | ➖ | UI ihtiyacına göre MM'den |
| H-082 | OFX `CalendarCheckWorkingDayHandler` | QuGet `ICalendarService`'e bağlı | QuGet kaldırıldı | 🔴 | ✅ `ICalendarHelper` | ✅ MM'in 4 ucu alındı (`CheckWorkingDay` · `CheckWorkingDays` · `NextWorkingDay` · `GetWorkingDay`) | — |

## K. Dağıtım — helm / pipeline / Docker (2026-10-09 taşıma)

| # | Yer | Sorun | Etkisi | OFX | MM | Durum | Öneri |
|---|---|---|---|:-:|:-:|:-:|---|
| H-083 | `.gitignore` | `helm/` satırı var — MM/OFX'te helm dosyaları **daha önce zorla eklenmiş** olduğu için izleniyor; yeni repoda `helm/` **hiç commit'e girmez** | 🔴 Helm chart'ları kaybolur | 🔴 | 🔴 | ⏸ aynen | Satırı kaldır **ya da** ilk commit'te `git add -f helm` |
| H-084 | MM helm values | Aynı anahtar iki kez: Kafka values'ta `CommonApi`/`AccountingApi`; Api values'ta `Serilog__WriteTo__2__Args__nodeUris` | YAML'da sonuncu kazanır, hangisinin geçerli olduğu belirsiz | — | 🔴 | ⏸ aynen | Tekile indir |
| H-085 | MM/OFX helm values | `KeyCloakConfiguration__ClientSecret` **düz metin** values dosyasında | Repoda sır | 🔴 | 🔴 | ✅ `"__CLIENTSECRET__"` yer tutucu (sır kopyalanmaz) | `envFrom.secretRef` / `secretKeyRef` |
| H-086 | MM helm values / compose | `ApplicationSettings__KafkaBootstrapServers` · `ConnectionStrings__RedisConnectionString` (K-35 ile kaldırılan çift anahtarlar) · `FIApi`/`FXApi` (MM'e özel) — uygulamamız bunları **okumuyor** | Ölü env değişkeni | — | 🔴 | ⏸ **MM ile birebir bırakıldı** (kullanıcı: *"MM'de nasılsa aynı şekilde koy"*) | Temizle |
| H-087 | MM `Dockerfile_sonarqube` | Api `/p:CollectCoverage` (coverlet msbuild), Batch `--collect:"XPlat Code Coverage"` — iki farklı kapsam yöntemi | Rapor tutarsız | — | 🔴 | ✅ bizde üçü de XPlat | — |
| H-088 | `Dockerfile` | `EXPOSE 80`, uygulama `ASPNETCORE_URLS=http://*:5061` ile dinliyor | Yalnız belgeleme farkı | — | 🔴 | ⏸ | `EXPOSE` portu eşitle |

## L. MM karşılaştırması (2026-10-09)

| # | Yer | Sorun | Etkisi | OFX | MM | Durum | Öneri |
|---|---|---|---|:-:|:-:|:-:|---|
| H-089 | MM `Consumer.Api/Dockerfile_sonarqube` | Consumer yerine **Api** projesini restore + build ediyor (kopyala-yapıştır) | Sonar Consumer'ı değil Api'yi tarar | — | 🔴 | ⏸ aynen | Consumer csproj'una çevir |
| H-090 | MM compose ↔ helm portları | Compose: web 5041 · batch **5043** · kafka **5044**; helm: web 5041 · batch **5042** · kafka **5043** | Lokal ve cluster portları farklı | — | 🔴 | ✅ bizde ikisi de 5061/5062/5063 | — |
| H-091 | MM `FxRateValidationBatchItem` · `InterestRateValidationBatchItem` | Gerçek kod yorumda, `Run` → `NotImplementedException` | BatchItem tablosunda tanımlanırsa EOD **patlar** | — | 🔴 | ➖ taşınmadı (kullanıcıya düzeltme bildirildi) | Gerçek kontrolü yaz ya da sil |
| H-092 | OFX `Common.Core/SystemConstant` | `ApplicationName = "BRW & PLC"` (MM kalıntısı) + `Data.Core`'da aynı adlı ikinci `SystemConstant` | Belirsiz referans (CS0104) — `InterestRateService`'te tam adla çözüldü | 🔴 | — | ⏸ | Tek sınıf, ad modüle göre |
| H-093 | `Country` | MM tablo `defCountry` (`Code`/`Name`); OFX tablo `Country` (`CountryCode`/`CountryName`) ve OFX'te **besleyen topic yok** | OFX'te ülke tablosu boş kalır | 🔴 | ✅ topic var | ✅ OFX entity + MM `country-insert` handler'ı + alan eşleyen mapper | Tablo adı Faz 4'te (MM `defCountry` mı OFX `Country` mı) |
| H-094 | `FloatingRateType` | MM'in **kendi modül tablosu**; `InterestRateService.GetFloatingRateAsync` buna bağlı | Tasarımda (Excel) yok | — | — | ⏸ MM'den aynen (entity · config · DataManager) | Excel v6'da tablo kararı |
| H-095 | MM `UiCultureActionFilterAttribute` | Tanımlı, hiçbir yerde kullanılmıyor | Ölü kod | — | 🔴 | ➖ | Sil |

## G. Belirsiz / ölçülmedi

| # | Konu |
|---|---|
| H-063 | Framework'ün `FeatureFlags:Serilog:RequestLogging` anahtarı `UseSerilogRequestLogging`'i mi çağırıyor — **tespit edilmedi** (paket içi) |
| H-064 | Sayaç öneki **77** önerildi — A-09 onayı yok |

---

*Son numara: **H-095**. Yeni madde → H-096.*
