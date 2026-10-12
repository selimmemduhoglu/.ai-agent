# 04 — Mimari Karşılaştırma: ColManagement (bizim) ↔ Aret şablonu (FI)

> **Tarih:** 2026-10-11 · **Amaç:** Aret'in "tüm modüller bu mimariyle standart olsun" önerisi konuşulurken elde somut, ölçülmüş
> karşılaştırma olsun. Kullanıcının kararı: **ColManagement bizim mimariyle devam ediyor**; bu doküman ileride tartışma için.
>
> |        | Bizim (`NetTrex.Collateral` → `NetTrex.ColManagement.*`) | Aret (`Old-Projects/Aret-Mimarili-Colmanagement` → `Treasy.ColManagement.*`) |
> | ------ | ------------------------------------------------------------- | --------------------------------------------------------------------------------- |
> | Kaynak | MM + OptionsFX ailesi (Seq MM, gerisi OptionsFX)              | `services/NetTrex.FI` şablonundan scaffold                                     |
> | Durum  | Altyapısı dolu: 54 proje · ~612`.cs`                     | **Boş iskelet**: 22 proje · 49 `.cs` (domain/handler/muhasebe yok)      |
>
> ⚠️ Aret'inki boş iskelet olduğu için karşılaştırma **mimari karar** üzerinedir; "dolu proje vs boş proje" kıyası değildir.

---

## 1. Platformda hangi modül hangi aileden (ölçüldü — csproj adları)

| Aile                                                 | Katman adları                                                                                                                                                                                                                                               | Modüller                                                                                                                                             |
| ---------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ----------------------------------------------------------------------------------------------------------------------------------------------------- |
| **A — Bizimki** (MM/OptionsFX)                | `Data.{Domain,Repository,Abstractions,Model,Core,Mapper,ResponseRequest}` · `Common.{Abstractions,Services,Mapper,Model,Core,ResponseRequest,Kafka}` · `Accounting.*` (6) · `Api/Batch/Consumer.{Core,Model,ResponseRequest,Mapper,Services,Api}` | **MM · OptionsFX · ColManagement**                                                                                                            |
| **B — Aret'inki** (Domain/Operation/Business) | `Common.{Domain,Repository,DapperRepository,Model,Core,InternalApi,Operation,Configuration}` · `Api.{ResponseRequest,Business,Web}` · `Kafka.*` · `Batch.*`                                                                                       | **Common · Fx · DerivSwp · Accounting · FI** (+ toplantıda scaffold'la açıldığı söylenen Reporting, Warrant, entegrasyon servisleri) |

🔴 **Düzeltme:** DerivSwp **B ailesinde** (`Api.Business`, `Common.Domain`, `Common.Operation`, `Kafka.*`) — A değil.
Yani sayıca B daha yaygın; A, en yeni ve en aktif geliştirilen iki modülün (MM, OptionsFX) mimarisi.

---

## 2. Yapı — bağımlılık grafiği

### A — Bizim: grup başına katı zincir

```
Core → Model → ResponseRequest → Abstractions → Mapper → Services → (Host)
```

Her grup (Data · Accounting · Common · Api · Batch · Consumer) aynı zinciri izler; her proje **yalnız bir öncekine** referans verir.
Gruplar arası yön tek: `Data → Accounting → Common → {Api, Batch, Consumer}`. Döngü **yapısal olarak imkânsız**.

### B — Aret: ortak çekirdek + ince host katmanları

```
Domain → Repository → Core → InternalApi → Operation → Configuration → host
                Model ↗                Kafka.Core ↗        Batch.Core ↗
Api:   ResponseRequest → Business → Web
Kafka: RequestResponse → Core → Business → Service
Batch: Model → ResponseRequest → Core → Items → Business → API
```

**Aret'in kendi MD'lerinde yazan kurallar** (`CLAUDE.md` + `README.md`, projedeki tek iki doküman):

- *"Composition root tek yerde"* — ortak servis host `Startup`'ına değil `RegisterCommonServices`'e eklenir; host'ta yalnız
  host'a özgü şey durur (Batch'te Hangfire, Kafka'da `KafkaWorker`).
- *"`Common.Operation` → `Kafka.Core` bağımlılığı bilinçli: operasyonlar Kafka producer'ı kullanır. Ters yönde referans vermeyin."*
- `internal` + `FriendAssemblyDeclaration.cs`; CPM (csproj'da sürüm yazılmaz).
- Doldurulmamış: `RequestCreatorFactory` boş (consumer topic'siz bekler), `ParameterDataProvider` boş liste, `EfDbContext`'te `DbSet` yok, `ICommonApi` boş.
- Port 5111/5112/5113; repo `Treasy.ColManagement`.

Ölçülen referanslardaki **ters yönler** (Aret'in gerekçesi varsa yanında):

| Referans                                                            | Neden sorun                                                                                                                                                                                                                                        |
| ------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `Common.Core → Common.Repository`                                | "Core" en alt katman olmalı; burada repository'ye bağlı → Core'u kullanan herkes EF'e bağımlı                                                                                                                                               |
| `Common.Operation → Kafka.Core`                                  | Ortak çekirdek bir**host grubuna** bağlı. Aret: *bilinçli — operasyonlar producer kullanır.* Gerekçe makul; ama producer bir altyapı parçası olarak `Common`'da dursaydı (bizdeki `Common.Kafka` gibi) ters bağ gerekmezdi |
| `Common.Configuration → Batch.Core`                              | Ortak composition root, Batch'e bağlı → Api ve Kafka host'ları da Batch altyapısını yüklüyor. 🔴 Aret'in**kendi kuralıyla çelişiyor** (*"host'a özgü şey host'ta durur"*)                                                   |
| `Api.Business → Common.Repository` + `Common.DapperRepository` | Handler doğrudan repository'ye erişebiliyor →`Operation` katmanı **atlanabilir** (katman sızıntısı)                                                                                                                                |

---

## 3. Karşılaştırma tablosu

| #  | Konu                                                             | A — Bizim                                                                                                                      | B — Aret                                                                                                                                                                            | Avantaj                                                                                 |
| -- | ---------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | --------------------------------------------------------------------------------------- |
| 1  | **Proje sayısı**                                         | 54 (+13 test)                                                                                                                   | 22 (+1 test)                                                                                                                                                                         | **B** — daha az csproj, daha hızlı build, daha kolay oryantasyon               |
| 2  | **Bağımlılık disiplini**                               | Grup başına katı zincir, döngü imkânsız                                                                                  | 4 ters/çapraz referans (§2)                                                                                                                                                        | **A**                                                                             |
| 3  | **Arayüz ayrımı**                                       | `*.Abstractions` projeleri — sözleşme ayrı, mock kolay                                                                    | Arayüz implementasyonla aynı assembly'de                                                                                                                                           | **A**                                                                             |
| 4  | **Kapsülleme**                                            | Çoğu`public`; bazı `internal` + `InternalsVisibleTo`                                                                   | Bilinçli`internal` + `FriendAssemblyDeclaration` her projede                                                                                                                    | **B** (disiplin olarak)                                                           |
| 5  | **Composition root**                                       | Her host kendi`AddData/AddServices/AddAccounting` çağrılarını yapar (tekrar ama açık; Consumer muhasebeyi yüklemez)   | Tek`RegisterCommonServices` — üç host aynı kaydı alır                                                                                                                        | **B** (DRY) — ama ortak kökün Batch'i çekmesi (§2) bedel                     |
| 6  | **DI kaydı**                                              | İsim konvansiyonu (`*DataManager`, `*Service`, `*Repository`, `*BatchItem`)                                            | Assembly'deki**tüm** sınıflar `AsImplementedInterfaces`, hepsi Scoped                                                                                                     | **A** — B'de istenmeyen tipler de (record, options, IDisposable) kayda girebilir |
| 7  | **Muhasebe**                                               | Ayrı`Accounting` grubu (6 proje) + pipeline step deseni (OptionsFX) + Fimple senkron                                         | **Yok** — `Operation` içine yazılacak                                                                                                                                     | **A** — ColManagement'ın merkezinde muhasebe var (her TxnDetail → fiş)        |
| 8  | **Referans veri (Calendar/Currency/FxRate…)**             | `NetTrex.Core.Data` + `CoreDataSlice`: entity · EF modeli · Kafka topic'i · handler **paketten**, tek listeyle     | Paket yok; her tablo için entity + config + handler**elle** (MM'deki 110 dosyalık durum)                                                                                     | **A**                                                                             |
| 9  | **Kafka consumer**                                         | KafkaFlow (buffer, worker, offset yönetimi kütüphanede)                                                                      | Confluent elle döngü — MM'inkinden**iyi** (`BackgroundService`, `SemaphoreSlim(15)`, düzgün kapanış) ama:                                                           | **A**                                                                             |
|    |                                                                  |                                                                                                                                 | 🔴`EnableAutoCommit = false` ve kodda **hiç `Commit` yok** → offset hiç yazılmıyor, her yeniden başlatmada `Earliest`'ten **tüm mesajlar yeniden işlenir** |                                                                                         |
|    |                                                                  |                                                                                                                                 | 🔴 Mesajlar`Task.Run` ile paralel → aynı anahtarın insert/update **sırası bozulabilir**                                                                                 |                                                                                         |
|    |                                                                  |                                                                                                                                 | ⚠️ Handler hatası`Task.Run` içinde kalıyor, yalnız kapanışta görülür → sessiz kayıp                                                                                   |                                                                                         |
| 10 | **Kafka producer**                                         | Singleton (bizde düzeltildi — H-021)                                                                                          | `AddScoped<IMessageProducer>` + `Lazy` → **istek başına yeni Kafka producer/bağlantı**                                                                                | **A**                                                                             |
| 11 | **Okuma ağırlıklı sorgular**                           | EF; Dapper yalnız sayaç üreticide                                                                                            | Ayrı`DapperRepository` (Dapper.FastCrud) — rapor/okuma için                                                                                                                     | **B**                                                                             |
| 12 | **Mapping**                                                | Mapster                                                                                                                         | AutoMapper 14 (`BaseWebApiController`) + `Netix.Core.Mapping`                                                                                                                    | **A** — AutoMapper 14 bilinen yüksek açık (H-032); 15+ ticari lisans          |
| 13 | **Doküman yönetimi · Fimple muhasebe/veri · bildirim** | Var                                                                                                                             | Yok (`ICommonApi` boş, `ParameterDataProvider` boş liste)                                                                                                                      | **A**                                                                             |
| 14 | **Batch**                                                  | BOD/EOD, Hangfire, SignalR, takvim, logical date hazır                                                                         | Arayüzler + Hangfire item taraması; altyapı yok                                                                                                                                   | **A**                                                                             |
| 15 | **Paketler**                                               | Merkezi (CPM) · OptionsFX sürümleri                                                                                          | Merkezi (CPM) · ayrıca`Microsoft.AspNetCore.Mvc.Core 2.3.9` (ASP.NET Core **2.x** paketi .NET 10'da)                                                                       | **A**                                                                             |
| 16 | **Platform standardı / scaffold**                         | Elle kuruldu (MM/OptionsFX'ten)                                                                                                 | Scaffold aracıyla tek komutta, isim/port/helm/pipeline hazır                                                                                                                       | **B**                                                                             |
| 17 | **Yaygınlık**                                            | 3 modül (MM, OptionsFX, ColManagement)                                                                                         | 5+ modül (Common, Fx, DerivSwp, Accounting, FI, yeniler)                                                                                                                            | **B**                                                                             |
| 18 | **Ortak sorun**                                            | `AddScoped<IDataContext, EfDbContext>` + `AddTreasyDbContext<EfDbContext>` = aynı scope'ta **iki DbContext** (H-035) | **Aynısı**                                                                                                                                                                   | —                                                                                      |

---

## 4. Sonuç

### Bizim mimari (A) ne zaman daha iyi

- **Muhasebe ağırlıklı, işlem üreten modüller** (MM, OptionsFX, ColManagement): Accounting grubu ve pipeline deseni hazır.
- **Kafka'dan çok referans tablo dinleyen modüller**: `CoreDataSlice` yüzlerce satır elle yazılan kodu kaldırıyor.
- **Uzun ömürlü, büyüyecek kod**: katı zincir ve ayrı Abstractions katman sızıntısını yapısal olarak engelliyor.

### Aret'in mimarisi (B) ne zaman daha iyi

- **Küçük/ince servisler** (raporlama, entegrasyon, okuma ağırlıklı): az proje, Dapper hazır, scaffold ile hızlı açılış.
- **Organizasyonel standart**: platformun çoğunluğu bu aileden; scaffold aracı tek tip repo üretiyor.

### ColManagement için

**A daha avantajlı** — modülün özü "her TxnDetail değişikliği → muhasebe fişi" ve referans veri tüketimi; ikisi de A'da hazır, B'de sıfırdan yazılacak.
B'ye geçilirse sıfırdan yazılacaklar: muhasebe grubu (~900 satır), referans veri consumer'ları, Fimple muhasebe/veri/bildirim, Batch altyapısı,
doküman yönetimi; ayrıca §3-9/10'daki Kafka sorunlarının düzeltilmesi.

### Aret ile konuşurken önerilebilecek orta yol

1. **A'ya B'nin iyi yanlarını al:** tek composition root (host'lardan ortak kayıtları tek `AddColManagementCore()` altına toplamak), ayrı `DapperRepository` (rapor uçları için), `internal` + `FriendAssembly` disiplini.
2. **B standart olacaksa önce şablonu düzelt:** Kafka offset commit + sıralı işleme (veya KafkaFlow), producer Singleton, `NetTrex.Core.Data`/`CoreDataSlice` desteği, ayrı Accounting grubu, `Common.Core → Repository` / `Configuration → Batch.Core` ters referanslarının kaldırılması, AutoMapper yerine Mapster.
3. **Ölçüt önerisi:** "muhasebe/işlem üreten modül → A, ince servis → B" ayrımı tek tip standarttan daha az risk taşır.

---

## 5. Kanıt (dosya yolları)

- B composition root: `Code/Common/Treasy.ColManagement.Common.Configuration/Extentions/ServiceCollectionExtentions.cs`
- B consumer: `Code/Kafka/Treasy.ColManagement.Kafka.Core/Consumer/KafkaMessageConsumerManager.cs` (commit yok), `KafkaConsumerBuilder.cs:33` (`EnableAutoCommit = false`)
- B producer ömrü: `Code/Kafka/Treasy.ColManagement.Kafka.Core/Producer/ServiceCollectionExtensions.cs` (`AddScoped<IMessageProducer, KafkaMessageProducer>`)
- B referanslar: `Common.Core.csproj` → `Common.Repository`; `Common.Configuration.csproj` → `Batch.Core`; `Common.Operation.csproj` → `Kafka.Core`
- A zincir ve `CoreDataSlice`: `NetTrex.Collateral/.ai-agent/PROJECT_CONTEXT.md` §3, `Data.Core/ColManagementCoreData.cs`
