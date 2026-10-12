# 11 — Takvim MM'e Döndü, QuGet Çıktı, DateTimeProvider Ölçüldü

**Tarih:** 2026-10-09 · **Faz:** 5 (devamı) · `dotnet build -t:Rebuild` **0 hata**

## 0. Kullanıcı kararı (K-45 — K-39'u netleştirir)

*"Kafanın karıştığı yerlerde MM ne yaptıysa onu yapmanı istiyorum. Bakıyorum da Option tarafı kafanı
karıştırıyor bazı yerlerde, ben MM projesinde hiç sorunlarla karşılaşmadım, kafan karışınca MM kodlarını kullan.
Accounting tarafı Option'daki gibi olsun ama zaten MM'de Option'da Accounting tarafı aynı, sadece Option'unki bir
design pattern daha ekleyerek daha iyi hale getirmiş."*

| Durum | Kaynak |
|---|---|
| Seq / Serilog | MM |
| Muhasebe (Accounting) | OptionsFX (MM ile aynı + pipeline pattern) |
| Proje/paket yapısı | OptionsFX |
| **Belirsiz / OptionsFX'in kütüphaneye yaslandığı yer** | **MM** |

## 1. `AddQuant()` → MM'in `CalendarHelper`'ı

**Kullanıcının sorusu:** *"AddQuant summary'si: faiz eğrisi, volatilite ve takvim servisleri, opsiyon/FX fiyatlama
motorları, greek hesaplayıcıları… Bu option/fx için yazılmamış mı, bizim kullanmamız mantıklı mı? MM'de nasıl
çözmüşüz?"*

**Ölçüm:** MM `Treasy.QuGet`'i **hiç referans almıyor** (kodda/csproj'da 0 eşleşme). Takvimi kendi
`ICalendarHelper`'ı ile çözüyor: `ICalendarRepository` üzerinden `Calendar` tablosunda
`DayOfYear + CurrencyCode + Year` satırı **var mı** (Calendar = çalışma günleri listesi, Common'dan Kafka ile kopya).
→ Bizde `ICalendarService` için tüm fiyatlama kütüphanesini (`AddQuant`) açmak yanlıştı. **Haklıydın.**

| Değişiklik | |
|---|---|
| ➕ MM'den | `ICalendarHelper` + `CalendarHelper` (19 metot: IsWorkingDay, Next/PreWorkingDay, X iş günü, aralık) · `ICalendarRepository` · `IHalfWorkingDayRepository` (+impl) · `CalendarModel` |
| 🔄 MM'e döndü | `BatchDataProvider.IsWorkingDay/IsHalfWorkingDay` (MM birebir) · `DateTimeCheckBatchItem` (MM birebir, yalnız parametre anahtarı `FrameworkParameterConstants.SystemWDFlag`) |
| ➖ Kaldırıldı | `AddQuant()` (yorumda) · `Treasy.QuGet` paket referansı (2 csproj + `Directory.Packages.props`) · 4 `global using Treasy.QuGet.Core.Enums` (kullanılmıyordu). Restore sonrası **dolaylı bağımlılık olarak da gelmiyor** (`project.assets.json` 0) |

🔑 Entity'ler (`CalendarEntity`, `HalfWorkingDayEntity`) MM'deki gibi modülün kopyası değil, `NetTrex.Core.Data`
paketinden (`CoreDataSlice`); repository'ler MM deseninde, Scrutor `*Repository` taramasıyla kayıtlı.

## 2. `DateTime.Now` vs `IDateTimeProvider` — ölçüldü

**Kullanıcının sorusu:** *"DateTimeProvider nereden besleniyor, daha mı sağlıklı? Ülke içinde de yurt dışında da
saat farklı müşterilerimiz var."*

`ilspycmd` ile decompile (`Netix.Core.dll`):
```csharp
public DateTime GetCurrentDateTime() => DateTime.Now;     // başka hiçbir şey yok
```
Kaydı framework yapıyor: `Netix.Core.Web.Base` → `services.AddTransient<IDateTimeProvider, DateTimeProvider>()`.

**Saat dilimi nereden geliyor:** `DateTime.Now` = **container'ın** yerel saati. MM bunu container seviyesinde
çözüyor: `helm/nettrex-mm/values-*.yaml` → `TZ: Europe/Istanbul`, `docker-compose.override.yml` → `TZ=Europe/Istanbul`.
UAE kurulumunda helm değeri `Asia/Dubai` olur, kod değişmez. Bizim `docker-compose.override.yml`'de **zaten var** (3 servis).

| Karar | Mekanizma |
|---|---|
| Kayıt damgası (`CreatedDate`, `EndDate`…) | **`IDateTimeProvider`** — bugün `DateTime.Now` ile aynı sonucu verir ama **tek nokta**: ileride TZ-farkında bir uygulama gerekirse tek DI satırıyla değişir, testte sahte saat verilir |
| İş günü kararı (valör, "bugünün işlemleri") | **`GetLogicalDateAsync()`** — parametreden gelir, TZ'den bağımsız |
| Müşteri saat dilimi | **Container `TZ`** (helm/compose) — MM deseni |
| Hangfire zamanlaması | `Trex:HangfireJobs.TimeZoneInfoId` (`Helper.GetTimeZoneInfo`) |

→ Kalan son `DateTime.Now` (`BatchDataProvider.UpdateBatchLog` → `EndDate`) `IDateTimeProvider`'a çevrildi.
Modülde `DateTime.Now/UtcNow/Today` **0**.

## 3. Batch'te MM'e dönülen diğer yerler

| Dosya | OptionsFX | MM | Bizde |
|---|---|---|---|
| `BatchNotificationFacade` | Batch set'i log listesinin ilk elemanından okuyor (boşsa patlar) · bildirim kodu dalı (türev formu için) | Batch set'i **DB'den** (`BatchLog`) okuyor · mail gövdesine başlık (tarih + kök batch adı) | **MM** (başlık `ColManagement - {tarih} - {batch}`) |
| `BatchSignalRStrategy` | — | Her gönderimden sonra `Thread.Sleep(200)` — *"its for signalr concurrency problem"* | **MM** |
| `Helper.GetBatchNotificationCode` | OptionsFX'e özel (türev formu) | yok | **kaldırıldı** |

### Bildirilen, dokunulmayan
| Konu | OptionsFX | MM |
|---|:-:|:-:|
| Kafka ile mail gönderilemezse Fimple API'sine düşen `catch` **hiç çalışmıyor**: `KafkaProducerService` hatayı kendi içinde yutuyor, `catch (BatchServiceException)` / `catch (InternalServiceException)`'a hiçbir şey ulaşmıyor. Bizde ölü `catch` kaldırıldı | 🔴 | 🔴 |
| `DateTimeCheckBatchItem` yalnız `WeekdaysOnly (1)`'i kontrol ediyor; `HolidaysButNotWeekends (2)` için guard yok (workspace MEMORY'de "bilinen batch bug adayı") | 🔴 | 🔴 |
| `DateTimeCheckBatchItem` `int.Parse(SystemWDFlag)` — parametre yoksa patlar | — | 🔴 (MM birebir alındı) |
| `CalendarHelper.IsWorkingDay` `Calendar` satırlarında `StateId` filtresi yok | — | 🔴 (Common'dan doğrulanmış satır geldiği varsayımı) |

## 4. Doğrulama
```
dotnet restore → QuGet çözümde yok (project.assets.json: 0)
dotnet build -t:Rebuild → 0 Error(s); kod uyarısı 2 (FlowEntity — paket sözleşmesi, progress/10)
grep DateTime.(Now|UtcNow|Today) → 0
```
⚠️ Çalıştırılmadı.
