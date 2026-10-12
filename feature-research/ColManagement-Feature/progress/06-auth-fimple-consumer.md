# 06 — Auth / Keycloak / Fimple + Consumer Altyapısı

**Tarih:** 2026-10-08 · **Faz:** 5 (devamı) · **Çıktı:** 88 `.cs` dosyası · `dotnet build` **0 hata**

---

## 1. Dış entegrasyon katmanı (OptionsFX'ten alındı)

| Proje | Dosya | Ne |
|---|---|---|
| `Common.Core` | `Exceptions/` ×3 | `ExternalApiException` · `InternalApiException` · `ServiceException` |
| `Common.ResponseRequest` | `External/Fimple/Shared/` | `FimpleResponseBase<T>` · `FimpleErrorBase` — Fimple'ın `Value`/`Reasons`/`Success` zarfı |
| `Common.ResponseRequest` | `External/Fimple/Auth/KeyCloak/` | `FimpleKeyCloakRequest` (`ClientId`/`ClientSecret`/`GrantType`, `[Required]`) · `FimpleKeyCloakResponse` (snake_case `JsonProperty`) |
| `Common.ResponseRequest` | `External/Fimple/Auth/Login/` | `FimpleLoginResponse` |
| `Common.Abstractions` | `Refit/External/` | `IFimpleKeyClockApi` (`POST /token`) · `IFimpleAuthApi` (`InitiateApplicationClientSession`) · `IFimpleApi` (boş, Faz 9) |
| `Common.Abstractions` | `External/IFimpleAuthService.cs` | — |
| `Common.Services` | `Extensions/RefitDefaultsExtension.cs` | PascalCase + camelCase `RefitSettings` (Newtonsoft) |
| `Common.Services` | `Extensions/RefitExtension.cs` | Fimple/internal zarf açıcılar + `RegisterRefitClient` |
| `Common.Services` | `Extensions/LoggerExtensions.cs` | `[LoggerMessage]` kaynak üreticili 5 olay |
| `Common.Services` | `Handlers/ExternalTokenDelegateHandler.cs` | Redis'ten token → yoksa login → **401'de yeniden login + tek retry** |
| `Common.Services` | `Handlers/ExternalHttpLoggingDelegateHandler.cs` | İstek/cevap gövdesi loglama |
| `Common.Services` | `External/FimpleAuthService.cs` | Keycloak `client_credentials` → Fimple session → token Redis'e, **TTL = `expires_in`** |
| `Data.Core` | `Constraints/FrameworkParameterConstants.cs` | Parametre anahtar kataloğu |

### Token akışı
```
ExternalTokenDelegateHandler
  └─ Redis'te token var mı?  ── yok ──> FimpleAuthService.Login()
                                          ├─ Keycloak /token (form-urlencoded, client_credentials)
                                          ├─ Fimple InitiateApplicationClientSession(accessToken)
                                          └─ Redis'e yaz, TTL = expires_in saniye
  └─ Authorization: Bearer <token>
  └─ cevap 401 ise → token sil, tekrar login, isteği BİR kez yinele
```

---

## 2. 🔴 OptionsFX'ten alırken DÜZELTİLEN iki ölçülmüş tuzak

### (a) `client_secret` düz metin loglanıyordu
`ExternalHttpLoggingDelegateHandler` gövdeyi **ham** logluyor. Token ucu `application/x-www-form-urlencoded`
gönderdiği için `client_id=…&client_secret=…` **düz metin** olarak Seq'e yazılıyor.

✅ **Düzeltme:** `GeneratedRegex` ile maskeleme —
`client_secret` · `clientSecret` · `password` · `access_token` · `refresh_token` → `$1***`.
Hem `=` (form) hem `:` (JSON) ayracını yakalıyor.

### (b) Hata gövdesi koşulsuz JSON sanılıyordu → gerçek hata gizleniyordu
`GetFimpleContentOrThrowAsync` HTTP başarısız olduğunda `Error.Content`'i doğrudan
`JsonConvert.DeserializeObject`'e veriyor. Gateway düz metin döndürünce (`Not Found`, HTML)
Newtonsoft ilk karakter **`N`**'yi görüp **`NaN`** parse etmeye çalışıyor:
*"Error parsing NaN value. Path '', line 1, position 1"* → ve `catch (JsonException)` bunu
*"Failed to parse the API response"* diye sarıyor. **HTTP durum kodu ve gövde hiçbir yere yazılmıyor** —
yani parse hatası değil, **teşhis kaybı**.

✅ **Düzeltme:** parse etmeden önce `body.TrimStart()[0]` `{`/`[` mi diye bak; değilse
`HTTP {kod} ({durum}). Body: {ilk 500 karakter}` ile fırlat. `catch (JsonException)` mesajına da
`ex.Message` eklendi.

---

## 3. Consumer (Kafka) altyapısı

| Proje | Dosya | Ne |
|---|---|---|
| `Common.Kafka` | `Extensions/…AddKafkaConsumerServices` | KafkaFlow cluster + consumer · buffer 10 · 3 worker · `JsonCoreDeserializer` + `MessageTypeResolver` + `MediatrDispatchMiddleware` |
| `Common.Kafka` | `StartKafkaConsumerService` | `ApplicationStarted` olayında bus'ı başlatır |
| `Common.Kafka` | `Services/Resolvers/MessageTypeResolver.cs` | topic → tip; bulunamazsa `KafkaThrowHelper.ThrowTopicTypeNotFound` |
| `Common.Kafka` | `Services/Handlers/MediatrDispatchMiddleware.cs` | 🔑 Mesajı **yeni bir DI scope'ta** `IMediator.Send`'e veriyor |
| `Common.Kafka` | `Core/{Exceptions,Helpers,Serialization}` | `KafkaException` · throw helper · `PropertyNameCaseInsensitive` |
| `Consumer.Abstractions` | `IKafkaConsumerSettingsFactory` | — |
| `Consumer.Services` | `KafkaConsumerSettingsFactory` | `ConsumerBuilder<string,string>` |
| `Consumer.Services` | `KafkaConsumerTopicFactory` | 🔑 Modül topic'leri + **`CoreDataTopics.For(Slices)`** birleşimi, `FrozenDictionary` |
| `Consumer.Services` | `…AddConsumerServices` | `AddCoreDataConsumer(Slices)` + `AddKafkaConsumerServices` |
| `Consumer.Mapper` | `…AddConsumerMapping` | Mapster |
| `Consumer.Api` | `Startup.cs` · `HealthCheckController` | Localization (`en-US`) · cookie policy · CORS · `StartConsumerService` |

🔑 **Tek liste iki işi yapıyor:** `ColManagementCoreData.Slices` hem `EfDbContext` modelini
(`ApplyCoreDataModel`) hem Kafka topic aboneliklerini (`CoreDataTopics.For`) besliyor →
ikisinin ayrışması **yapısal olarak imkânsız**. MM'de bunlar iki ayrı elle yazılmış liste.

⚠️ `ColManagementTopics` sözlüğü **şimdilik boş** — modüle özel topic'ler (OptionsFX'te
`portfolio-insert`, `customer-insert`, `corporate-type-insert`) Faz 6'dan itibaren eklenecek.
Referans verisi topic'leri **zaten otomatik** geliyor.

---

## 4. OptionsFX'e özgü olup bize gerekmeyen konfigürasyonlar — **yorum satırında bırakıldı**

Kullanıcı isteği: *"OptionFX'in kendi için yazdığı bize uygulanmasına gerek olmayan
configuration'larını da yaz ama yorum satırı halinde bırak."*

| Yer | Yorumda duran |
|---|---|
| `Api/Startup.cs` | `AddDocumentManagementDI` + `IDocumentManagementService` (teminat belgesi gerekirse) · `AddSchemaValidation<EfDbContext>` · `ITxnNoteOperation` |
| `Api/Startup.cs` · `Consumer.Api/Startup.cs` | `QueryableExtension.SetCalendar(...)` — Treasy.QuGet takvimi, iş günü hesabı başlayınca (Faz 7) |
| `Common.Services/…AddExternalIntegration` | `IFimpleDocumentApi` · `IFimpleCatalogApi` · `IFimpleNotificationApi` · `ILimitApi` · `IFimpleAccountingService` · `IFimpleDataService` |
| `Data.Core/FrameworkParameterConstants` | `StaleRateToleranceMin` · `MtaDeviationPolicy` · `AllowNegativeBalance` · muhasebe/FX/limit anahtarları |
| `Data/…AddData` | `IFrameworkParameterHelper` · `IAccountingEngineDataFactory` · `IFlowEngine`/`IFlowOperation` · Refit `CommonApi`/`AccountingApi` |

🔑 **`// Faz N:` yorumları geçici** — tüm kod yazıldıktan sonra **silinecek**. Şimdilik hangi fazda
neyin açılacağını gösteren referans olarak duruyorlar (kullanıcı onayı 2026-10-08).

---

## 5. 🔴 UNIT TEST YAZILMADI — bilinçli karar

**Kullanıcının sözü (2026-10-08):** *"Unit testler şimdilik kalsın, tüm projeyi yazdıktan sonra
unit testleri yazacağız, ben sana söyleyeceğim zaten. Hiçbir şekilde unit testlere zaman harcayamayız."*

- 13 test projesi **iskelet olarak duruyor** (`UnitTests/<Grup>/…Tests`), **içleri boş**
- Workspace `CLAUDE.md` Hard Rule 10 *"davranış karar taşıyorsa test yaz"* diyor →
  **bu iş için kullanıcı kararıyla askıya alındı**, kural ihlali değil **bilinçli istisna**
- ⚠️ Risk kabul edildi: iş kuralları (bakiye kilidi, muhasebe idempotency, bitmask durum türetimi)
  testsiz yazılacak. Test turu geldiğinde bu alanlar **öncelikli**

---

## 6. Doğrulama

```
dotnet build NetTrex.ColManagement.sln → Build succeeded, 0 Error(s)
```

- ✅ 88 `.cs` dosyası
- ✅ Sır taraması temiz — `appsettings.json`'ların üçünde de yalnız `__PLACEHOLDER__`
- ⚠️ **Çalıştırılmadı** — DB ve Kafka yok. Derleniyor, ayağa kalkma testi Faz 4 sonrası

---

## 7. Açık kalanlar

| # | Ne |
|---|---|
| `A-08` | Modül kodu — koda **`CM.`** parametre öneki olarak girdi, onay bekliyor |
| — | `Batch.Api/Startup.cs` hâlâ minimum (Faz 9) |
| — | `appsettings.Development.json` · `docker-compose.override.yml` · Serilog/Seq yapılandırması yok |
| — | Kafka `GroupId` = `colmanagement-consumer` varsayıldı |
