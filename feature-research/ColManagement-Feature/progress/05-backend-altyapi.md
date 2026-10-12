# 05 — Backend Altyapı (Faz 5)

**Tarih:** 2026-10-08 · **Faz:** 5 · **Repo:** `NetTrex.Collateral` (hedef `NetTrex.ColManagement`)
**Çıktı:** DI omurgası + `EfDbContext` + pipeline altyapısı · `dotnet build` **0 hata**

---

## Yapılanlar

| Katman | Dosya | Ne |
|---|---|---|
| **Data.Core** | `ColManagementCoreData.cs` | 🔑 `CoreDataSlice` seçimi — **tek liste**, hem DbContext modelini hem Kafka topic'lerini besler |
| **Data.Repository** | `DbContext/EfDbContext/EfDbContext.cs` | `DataContext` türevi · `ApplyConfigurationsFromAssembly` · `ApplyCoreDataModel(KafkaReplica, Slices)` · `UseSqlOutputClause(false)` · `ApplyMappingFixes` |
| **Data.Repository** | `Extensions/…AddRepository` | `IUnitOfWork` · `IDataContext` · `IRepository<>` · `AddTreasyDbContext` · Scrutor `*Repository` |
| **Data** | `Extensions/…AddData` | `AddCoreData` · `AddCurrencyPairCache` · Scrutor `*DataManager` + `*DataService` · `AddRepository` · `AddStateEngine` |
| **Common.Model/Abstractions/Services** | `Shared/Pipeline/*` | `PipelineContext` · `IPipelineStep` · `IPipelineBuilder` · `IPipelineRunner` · `PipelineBuilder` · `PipelineRunner` · `LoggingDecorator` · `ExceptionHandlingDecorator` |
| **Common.Mapper** | `…AddCommonMapping` | Mapster `GlobalSettings` + `Flexible` eşleme |
| **Common.Services** | `…AddServices` | Scrutor `*Service` · `AddCommonMapping` · `RegisterPipelineSteps` (+ `Decorate` ile logging) |
| **Accounting.Mapper / .Services / Accounting** | `…AddMapper` · `…AddServices` · `…AddAccounting` | `AddAccountingEngine` · Scrutor `IValidator<>` |
| **Api.Mapper** | `…AddApiMapper` | Mapster + (ileride `IResolver<,>` taraması) |
| **Api.Services** | `Handlers/ExceptionHandler.cs` + `…AddApiServices` | MediatR `IPipelineBehavior` — istisnayı `ResponseBase.IsSuccess=false` + `MessageCode 999`'a çevirir |
| **Api** | `Startup.cs` · `GlobalUsings.cs` · `appsettings.json` | `NetixApiStartup<ApplicationSettings>` · CORS · Swagger · `AddSchemaMapping` · 5 katman DI çağrısı |
| **10 proje** | `Properties/AssemblyInfo.cs` | `InternalsVisibleTo` — `internal` DI uzantıları host projeden görünsün |
| **14 proje** | `Properties/AssemblyReference.cs` | Scrutor tarama işareti |

🔴 **`appsettings.json`'da parola YOK** — `__SERVER__` / `__USER__` / `__PASSWORD__` / `__SECRET__` yer tutucu.
(OptionsFX'in dosyasında canlı parolalar düz metin duruyor; kopyalanmadı.)

---

## ✅ `D-01` / `A-11` KAPANDI — `CoreDataSlice` üyeleri

`NetTrex.OptionsFX.Data.Core/OptFxCoreData.cs` okundu. Enum üyeleri:

```
DateBasis · Currency · CurrencyPair · Chart · Point · Calendar
Holiday · HalfWorkingDay · FxRate · InterestRate · Volatility
```

**ColManagement seçimi (10 dilim):**

| Dilim | Niçin |
|---|---|
| `Currency` · `CurrencyPair` · `FxRate` | Her tutarın yanındaki `CurrencyCode`; `TxnTransactionCash.FxRate` kaynağı (`FxRateSource = SYSTEM` yolu) |
| `Calendar` · `Holiday` · `HalfWorkingDay` | İş günü / valör hesabı |
| `DateBasis` | `CollateralCashTerms.DayCount` |
| `Chart` · `Point` · `InterestRate` | `CollateralCashTerms` faiz tarafı (Faz 7) |
| ❌ `Volatility` | **Alınmadı** — opsiyon fiyatlaması bu modülde yok |

🔑 Dilim listesi aynı zamanda **hangi referans tablosunun DB'de kurulacağını** söylüyor → Faz 4 DDL'ini de besliyor.

---

## 🔴 Yakalanan tuzak — gruplar arası `ProjectReference` yolu

Faz 3'te üretilen csproj'larda **gruplar arası** referanslar `..\<Proje>\` yazılmıştı; doğrusu
`..\..\<Grup>\<Proje>\`. Etkilenen 5 dosya: `Api.Core` · `Accounting.Core` · `Common.Core` ·
`Batch.Core` · `Consumer.Core`.

🔴 **Neden tehlikeli:** `dotnet restore` **54/54 geçti**, `dotnet build` **0 hata** verdi —
çünkü o projelerde henüz referansı kullanan **kod yoktu**. Hata ancak `Startup.cs` yazılınca
*"`Data` does not exist in the namespace `NetTrex.ColManagement`"* diye ortaya çıktı.

✅ **Taşınabilir ders:** boş bir iskelette "build geçti" **bağımlılık grafiğinin doğru olduğunu
kanıtlamaz**. Graf, kod yazılmadan **ayrıca** doğrulanmalı — her csproj'un `ProjectReference`'ları
okunup emsal projeyle karşılaştırılarak. Bu işte karşılaştırma yapıldı ve graf OptionsFX ile
**birebir** aynı çıktı.

---

## Doğrulama

```
dotnet build NetTrex.ColManagement.sln → Build succeeded, 0 Error(s)
```

- ✅ Bağımlılık grafiği OptionsFX ile **birebir** (41 proje tek tek karşılaştırıldı)
- ✅ `appsettings.json`'da parola/bağlantı sırrı yok
- ⚠️ **Çalıştırılmadı** — `NetTrexColManagement` DB'si henüz yok (Faz 4). Ayağa kalkma testi
  script'ler uygulandıktan sonra yapılacak

---

## Bilinçli kapsam dışı (Faz 9'a bırakıldı)

| Ne | Niçin |
|---|---|
| Fimple / Limit / Accounting Refit client'ları | İş sözleşmesi netleşmeden yazılmaz |
| `ExternalTokenDelegateHandler` · `ExternalHttpLoggingDelegateHandler` | Fimple'a bağlı |
| `BatchDbContext` | Batch entity'leri yok |
| `IAccountingManager` · `IAccountingService` · `IAccountingPathBuilder` | Muhasebe kuralları Faz 9 |
| `IFlowEngine` · `IFlowOperation` · `IFrameworkParameterHelper` | İlk entity ile birlikte (Faz 6) |

---

## Açık kalanlar

| # | Ne |
|---|---|
| — | API'nin **gerçekten ayağa kalktığı** doğrulanmadı — DB yok |
| — | `appsettings.Development.json` / `docker-compose.override.yml` yazılmadı |
| `A-08` | Modül kodu — kodda henüz kullanılmıyor |
| — | `Serilog` yapılandırması `appsettings`'e eklenmedi (OptionsFX'inki Seq API key içeriyor, kopyalanmadı) |
