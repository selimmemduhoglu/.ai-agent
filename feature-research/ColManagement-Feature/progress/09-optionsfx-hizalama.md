# 09 — Toplantı Sonrası: Kaynak Kuralı Değişti, Kod OptionsFX'e Hizalandı

**Tarih:** 2026-10-09 · **Faz:** 5 (revizyon) · `dotnet build` **0 hata, 0 kod uyarısı**

---

## 1. Kullanıcının kararı (K-39 — K-33 ve K-37'nin yerine geçer)

*"Accounting, Consumer, Auth, Keycloak ve dependency ve reference ve projeleri OptionFX projesindeki gibi yap.
Seq loglamasını da MM'deki gibi yap demiştim senden… Yani Seq loglamaları MM'deki gibi olsun, onun dışındaki
her yer OptionFx'teki gibi olsun. Projeleri ona göre aç, proje referanslarını ve package'ları ve sürümlerini
ona göre ver… geçirirken de hatalı gördüğün ya da boşluk gördüğün yerleri de bana bildirip düzelt. Radikal
değişiklikler yapma ama küçük düzeltmelerle toparla, çok sıkıntılı ise bana haber ver."*

| Alan | Kaynak |
|---|---|
| Seq / Serilog (appsettings `Serilog` bölümü, `ExternalHttpLoggingDelegateHandler`) | **MM** (+ 2026-10-08 iyileştirmeleri) |
| Geri kalan her şey | **OptionsFX** |

Toplantı notları → [`../bilgi-bankasi/10-toplanti-2026-10-08.md`](../bilgi-bankasi/10-toplanti-2026-10-08.md)

---

## 2. Ölçüm — ne zaten OptionsFX'ti, ne değildi

| Katman | Ölçüm | Sonuç |
|---|---|---|
| Proje listesi | 54 csproj, normalize adla eşleştirildi | ✅ birebir (yalnız OptionsFX'e özel `CalculatorEngine` yok — opsiyon fiyatlama motoru) |
| `ProjectReference` | 54 csproj karşılaştırıldı | ✅ **fark 0** |
| `PackageReference` + sürüm | aynı | ✅ **fark 0** |
| `Directory.Packages.props` | diff | ✅ yalnız OptionsFX'teki **mükerrer** `NetTrex.Core.Parameter 10.0.1` satırı yok |
| `Directory.Build.props` · `NuGet.config` | diff | ✅ aynı (yalnız satır sonu) |
| `.cs` dosyaları | 95 dosya OptionsFX karşılığıyla diff'lendi | 🔄 MM'den gelenler aşağıda değiştirildi |

## 3. OptionsFX'e çevrilenler

| Dosya | Önce (MM) | Şimdi (OptionsFX) |
|---|---|---|
| `Startup.cs` ×3 | Localization + cookie policy + zengin Swagger + `AddGlobalSettings` + `AddControllers().AddViewLocalization()` | OptionsFX'in biçimi birebir; OptionsFX'e özel satırlar (`DocumentManagement`, `AddSchemaValidation`) **yorumda** |
| `AddData_AfterConfigure` | MM deseni (Data katmanından) | **Kaldırıldı** — OptionsFX gibi `Startup.AfterConfigure`'da `QueryableExtension.SetCalendar(...)` |
| `Data` DI | Faz 6 notu | OptionsFX'in kayıt listesi **yorumda** (`IHelper`, `IFlowEngine`, Refit `CommonApi`/`AccountingApi`…) |
| `FimpleAuthService` · `ExternalTokenDelegateHandler` · `RefitDefaultsExtension` · `RefitExtension` · `LoggerExtensions` · `GlobalUsings` | MM biçimi | OptionsFX dosyaları (namespace değişti) |
| `Common.Services` DI | MM kayıt sırası, `IFimpleApi` **camelCase** kaydı | OptionsFX sırası; `IFimpleApi` OptionsFX gibi `RegisterRefitClient`; OptionsFX'e özel Fimple/Limit kayıtları **yorumda** |
| `Batch.Services` DI | MM deseni `*Service` taraması | OptionsFX'in açık kayıt listesi (sınıflar henüz yok → yorumda) |
| `Api.Mapper` DI + `Api.Core` | — | OptionsFX'teki `IResolver<,>` taraması + `IResolver` · `ApiServiceException` eklendi |

**Korunan (MM — Seq):** `ExternalHttpLoggingDelegateHandler` (`>>>>>>>>>` biçimi + maskeleme) ·
`appsettings` `Serilog` bölümü (enricher'lar, filtreler, destructure) · `reference/logging.md`.

---

## 4. 🔴 OptionsFX'te bulunan açıklar — bildirildi ve düzeltildi

| # | Yer | OptionsFX'teki hâli | Sonucu | Bizde |
|---|---|---|---|---|
| 1 | `QueryableExtension.SetCalendar` | `app.ApplicationServices.CreateScope()` — scope **hiç kapatılmıyor**, içinden çözülen scoped `IHelper` **statik** tutuluyor | Tek bir `DbContext` uygulama ömrü boyunca **tüm isteklere paylaştırılır** (thread-safe değil) | Kök provider tutulur, her çağrıda **yeni scope** (MM'deki düzeltilmiş hâli) |
| 2 | `Batch.Api/Startup` | `DatabaseProvider.PostgreSql` — Api ve Consumer `MsSql` | Batch farklı SQL lehçesi üretir | `MsSql` |
| 3 | `Batch.Api/Startup` | CORS + localization `AfterConfigure`'da (Api ve Consumer'da `BeforeConfigure`'da) | Endpoint'ler eşlendikten sonra eklenen middleware **etkisiz** kalabilir | `BeforeConfigure` (OptionsFX'in diğer iki Startup'ı gibi) |
| 4 | `Batch.Api/Startup` | `locOptions.Value` null kontrolsüz · `en-US` **iki kez** | — | düzeltildi |
| 5 | `Consumer.Api/Startup` | `StartKafkaConsumerService()` **ve** `StartConsumerService()` — ikincisi birincisini çağırıyor | KafkaFlow bus'ı **iki kez** kuruluyor → aynı grupta çift consumer | **tek** çağrı |
| 6 | `Consumer.Api/Startup` | `AddConsumerMapping()` **iki kez** | — | tek |
| 7 | `IKafkaConsumerSettingsFactory` + `KafkaConsumerSettingsFactory` | Kayıtlı ama **hiçbir yerde kullanılmıyor** (KafkaFlow yerini almış) | Ölü kod | **silindi** |
| 8 | `Batch.Services/BatchDataProvider` *(henüz port edilmedi)* | `IsWorkingDay` / `IsHalfWorkingDay` **sabit `true`** dönüyor, gerçek kontrol yorumda | 🔴 Batch **tatil günlerinde de koşar** | Port edilirken MM'in `ICalendarHelper` uygulaması alınacak |
| 9 | `RefitExtension` | JSON olmayan hata gövdesi Newtonsoft'ta `NaN` hatasına dönüyor; HTTP kodu ve gövde kayboluyor (2026-08-20 MM'de yaşandı) | Teşhis kaybı | Guard + `HTTP {kod} Body: {ilk 500}` |
| 10 | `RefitExtension` | Genel `catch` iç istisnayı **atıyor** | Kök neden kaybolur | `ex` iç istisna olarak taşınıyor |
| 11 | `ExternalTokenDelegateHandler` | 401 yanıtı retry'dan önce dispose edilmiyor | Bağlantı sızıntısı | `response.Dispose()` |
| 12 | `ExceptionHandler` (OptionsFX **ve** MM) | Hatayı yakalayıp `999` döner, **hiç log'lamaz** | 🔴 İstisna Seq'e **hiç düşmez** — 2026-09-04'te Manuel Reeskont'ta bu yüzden elle `LogError` eklenmişti | `logger.LogError(ex, ...)` + `RequestName` |
| 13 | `LoggingDecorator` | Her pipeline adımının **girdisini ve çıktısını** `Information`'da log'luyor | Seq seli + hassas veri | Alınmadı (Seq kuralı MM'den) |
| 14 | `RegisterPipelineSteps` | `IPipelineBuilder<>` **iki kez** kaydediliyor | Zararsız tekrar | Tek |
| 15 | `appsettings` (yer tutucu) | Keycloak adresi `.../auth/realms/...` | Bizim yer tutucuda `/auth` yoktu | `/auth` eklendi |

### Bildirilen, düzeltilmeyen
| # | Konu | Neden dokunulmadı |
|---|---|---|
| a | `RefitSettings` ve `RefitSettingsPascalCase` **ikisi de** property adını olduğu gibi yazıyor; `RegisterRefitClientCamelCase` adı yanıltıcı (camelCase üretmiyor) | OptionsFX birebir istendi; ad değişikliği tüm modüllerde |
| b | NuGet açık uyarıları: `AutoMapper 14.0.0` (high), `Microsoft.OpenApi 2.4.1` (high), `SixLabors.ImageSharp 2.1.11`, `System.Security.Cryptography.Xml 8.0.2` | **Geçişli** — Netix/NetTrex framework paketlerinden geliyor; OptionsFX'te de aynı |
| c | `FimpleAuthService` eşzamanlı ilk isteklerde **paralel login** yapar (kilit yok) | Zararsız (son yazan kazanır); OptionsFX ve MM aynı |
| d | OptionsFX Api'de klasör `Controller` (tekil), Batch/Consumer'da `Controllers` | Bizde üçü de `Controllers` |
| e | `ExceptionHandler`'da `ExternalApiException` dalı genel dalla aynı yanıtı üretiyor | Log mesajı ayrıştığı için dal korundu |

---

## 5. Port edilmeyen OptionsFX altyapısı — sıradaki adaylar

| Parça | Boyut | Neden şimdi değil |
|---|---|---|
| **Batch çalıştırma altyapısı** (`BatchRunOperation`, `BatchDataProvider`, `BatchNotificationFacade`, SignalR, Hangfire job factory, `BatchDbContext` + 4 batch entity, `BatchRunController`) | ~800 satır | `BatchDataProvider` → `ICalendarHelper` → `IHelper` (290 satır) zincirine bağlı; Data helper katmanıyla **birlikte** gelmeli |
| **Data helper'ları** (`IHelper`, `FlowDataProvider`, `AccountingEngineDataFactory`, `FrameworkParameterHelper`) | ~600 satır | Logical date / flow / muhasebe verisi — iş tablolarından bağımsız, **port edilebilir** |
| **Muhasebe** (`AccountingService`, `AccountingManager`, path builder, validator'lar, engine modeli) | ~900 satır | Olay tipleri (Opening/Premium/…) ve path (`Side/OptionType`) **opsiyona özel**. ColManagement'ın olayı "detail değişikliği" + nazım bacağı (A-25) — iş kararı gelmeden yazılırsa yeniden yazılır |

---

## 6. Doğrulama

```
dotnet build NetTrex.ColManagement.sln → Build succeeded, 0 Error(s)
dotnet build --no-restore | grep warning | grep -v NU → (boş)
```
- ✅ 54 csproj'un referans + paket + sürümü OptionsFX ile **fark 0**
- ✅ `AddData_AfterConfigure` · `AddGlobalSettings` · `KafkaConsumerSettingsFactory` → kalıntı yok
- ⚠️ **Çalıştırılmadı** — DB · Kafka · Redis · Seq yok

## 7. Yapılamayan

- 🔴 `feature-research/Colleteral-Feature/` → `ColManagement-Feature/` yeniden adlandırması **`Permission denied`**
  (klasörde açık dosya var — v5 Excel'in `~$` kilit dosyası duruyor). Excel/PDF kapatılınca yapılacak; tüm
  MD bağlantıları ve hafıza dosyaları aynı turda güncellenecek.
- Repo klasörleri (`NetTrex.Collateral`, `Treasy.Collateral.UI`) — kullanıcı yeniden adlandıracak.
