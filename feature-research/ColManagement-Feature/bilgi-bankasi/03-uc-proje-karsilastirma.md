# 03 — MM ↔ OptionsFX ↔ DerivSWP Karşılaştırması

> Collateral hangi projeyi örnek alacak? Üç repo ve üç DB kaynaktan okunarak çıkarıldı.
> **Ölçüm tarihi:** 2026-10-07 · Kullanıcının yönergesi: *"En günceli OptionsFX, oradaki kod yapısı ve
> isimlendirmeyi alacağız. MM'e çok hakimim ve MM ile OptionsFX çok benzer. Üçünde ortak olanlar bizde
> de olması gerekenlerdir."*

---

## 0. Tek cümlelik sonuç

**Kod yapısı, isimlendirme ve proje ağacı için OptionsFX örnek alınır.** MM yalnız (a) kullanıcının
aşina olduğu referans, (b) OptionsFX'in atladığı bir şeyi yakalamak için karşılaştırma kaynağı.
DerivSWP ise **kurulum script'lerinin** emsali.

---

## 1. Proje / çözüm yapısı

| | MM | OptionsFX |
|---|---|---|
| csproj sayısı | 59 | 52 |
| Üst klasörler | `Accounting · Api · Batch · Common · Consumer · Data · MarketIntegration · Tools` + `UnitTest/` | `Accounting · Api · Batch · Common · Consumer · Data` + `UnitTests/` |
| Merkezi paket yönetimi | ❌ **yok** (her csproj kendi sürümünü yazar) | ✅ `Directory.Build.props` + `Directory.Packages.props` |
| Test ortak props | ❌ | ✅ `UnitTests/Directory.Build.props` |
| Kafka altyapısı | Consumer içinde dağınık | ✅ ayrı `Common.Kafka` projesi (Api + Consumer ortak) |
| Market verisi | `MarketIntegration/` (5 proje, Bloomberg) | `Treasy.QuGet` NuGet'i (`AddQuant`) |
| Consumer mapper | `Consumer.Mapping` | `Consumer.Mapper` (diğer katmanlarla tutarlı) |

**→ Collateral:** OptionsFX ağacı. `Directory.*.props` **ilk gün** konur (MM'e sonradan 59 csproj'a
uygulamak imkânsız hale gelmiş). `MarketIntegration` ve `Tools` **kurulmaz**.

---

## 2. 🔑 İsimlendirme

### 2.1 Fiziksel tablo adları

| Kavram | MM | OptionsFX | DerivSWP |
|---|---|---|---|
| **Ana işlem** | `TxnMM` | **`TxnTransaction`** | **`TxnTransaction`** |
| İşlem geçmişi | `TxnMMHistory` | `TxnTransactionHistory` | `TxnTransactionHistory` |
| Değerleme | `LoanRevaluation` | `OptionsFXRevaluation` | `DerivativesRevaluation` |
| Ürün tanımı | `PrdProductDefinition` | **`ProductDefinition`** | **`ProductDefinition`** |
| Not/Doküman/Sync | `TxnNote` · `TxnDocument` · `TxnSync` | **aynı** | **aynı** |
| Muhasebe | `accEntry` · `accEntryMain` | `accEntry` · `AccEntryMain` | aynı |
| Müşteri / cron | `cusCustomer` · `defJobCron` | **aynı** (legacy korunmuş) | **aynı** |

### 🔑 Çıkarılan kural
> **Modülün KENDİ sahip olduğu tablo jenerik ad alır** (`TxnTransaction`, `ProductDefinition`).
> **Platformdan MİRAS gelen tablo eski adını korur** (`cusCustomer`, `accEntry`, `defJobCron`, `PrfPortfolio`, `BatchItem`).
> Modül adı yalnız **değerleme tablosunda** kalıyor (`OptionsFXRevaluation`, `DerivativesRevaluation`) —
> kuralın tek istisnası.

MM'de bu ayrım **yok** — her şeye `MM` sokulmuş (eski desen).

### 2.2 Kod tarafı
- Namespace'ler tam modül adıyla (`NetTrex.OptionsFX.…`). `OptFx` kısaltması **yalnız 2 yerde**:
  `OptFxCoreData.Slices` sabiti ve Oracle şema adı.
- MM'de `Data.Domain/Entities/...` ara klasörü var, OptionsFX'te **yok** (daha sığ).
- Controller: MM `Controllers/` + tekil ad · OptionsFX `Controller/` (tekil klasör) + **çoğul** ad
  (`CustomersController`). İkisi de kendi içinde tutarsız; OptionsFX REST'e daha yakın.

---

## 3. 🔑 Pipeline / Accounting — en büyük mimari fark

### MM
`IAccountingStep<T>` → `int Order { get; }` + `ExecuteAsync(T stepContext, …)`.
Operation başına marker interface (`IOpeningAccountingStep`), Scrutor toplar,
`steps.OrderBy(x => x.Order)` çalıştırır. Dosyalar `01_`, `05_`, `10_` önekli.
Her step **aynı mutable context** nesnesini alıp döndürür.

### OptionsFX
Jenerik, **tiplenmiş fluent** pipeline:
```csharp
IPipelineStep<in TIn, TOut>  →  ValueTask<TOut> ExecuteAsync(TIn, ct)
IPipelineBuilder<TContext>.AddStep<TStep, TIn, TOut>(inputSelector, outputCombiner)
IPipelineRunner<TContext>.ExecuteAsync(ctx)
```
Adımlar **kod içinde sırayla** zincirleniyor; her `AddStep` (a) context'ten girdiyi seçen lambda,
(b) çıktıyı context'e yazan lambda alıyor. `Order` yok, dosya öneki yok, marker interface yok.
`LoggingDecorator<,>` Scrutor `Decorate` ile **tüm** step'lere otomatik takılı.

### Karşılaştırma

| | MM (`Order` + marker) | OptionsFX (fluent builder) |
|---|---|---|
| Sıra nerede görünür | 7 dosyaya dağılmış `Order => 1/5/10…` | **tek dosyada okunur liste** |
| Sıra değiştirme | iki dosyada sayı değiştir + çakışmayı gözle kontrol | satırı taşı |
| Step girdisi | tüm context (her şeyi görür, her şeyi bozabilir) | **yalnız ihtiyacı olan tuple** |
| Test edilebilirlik | `StepContext` kurmak gerekir | tuple ver, çıktıyı assert et |
| Step yeniden kullanımı | operation'a kilitli | ✅ operation'dan bağımsız |
| Çapraz kesen log | yok | `Decorate` ile bedava |
| Hata telafisi | ✅ `catch`'te compensating `CloseAccount` | ❌ yok |

### 🔴 OptionsFX pipeline'ının 3 kusuru — Collateral'a KOPYALANMAZ
1. **`AddStep<TStep,…>` `TStep`'i yok sayıyor.** DI çözümü `(TIn,TOut)` imzasından yapılıyor
   (`sp.GetRequiredService<IPipelineStep<TStepIn, TStepOut>>()`). Aynı imzalı iki step yazılırsa
   **yanlış step koşar, derleme hatası vermez.** Bugün patlamamasının sebebi tuple'ların kazara
   benzersiz olması. → `sp.GetRequiredService<TStep>()` ile düzelt.
2. **`ExceptionHandlingDecorator<,>` yazılmış ama DI'ya hiç kaydedilmemiş** — ölü kod.
3. **`LoggingDecorator` input/output'u `LogInformation` ile basıyor** → müşteri/tutar verisi Seq'e
   düşüyor. Seviye `Debug` olmalı veya PII maskelenmeli.

**→ Collateral:** OptionsFX'in fluent pipeline'ı + 4 düzeltme (yukarıdaki 3 + MM'in compensating
action'ı `OnFailure` kancası olarak).

---

## 4. Handler / Request-Response / Validator

**Ortak (fark yok):** `BaseApiController` + `Mediator.Send`; `FlowHandler<TReq,TRes>` /
`BaseFlowRequest<T>` / `BaseFlowResponse` Netix paketlerinden; FluentValidation; validator'lar
handler'la aynı klasörde; `appsettings.Assemblies.Handler/Validator` ile tarama.

| | MM | OptionsFX |
|---|---|---|
| Modül request tabanı | `BaseMmRequest<T>` | `BaseOptionsFXRequest<T>` — 🔴 dosya adı hâlâ `BaseMmRequest.cs` |
| Ara handler tabanı | ❌ yok | ✅ **`TransactionBaseHandler<TReq,TRes>`** — `Handle` `sealed override`, alt sınıf `HandleTransactionAsync` yazar; taban başarıdan sonra **limit bildirimini** çalıştırıp uyarıyı `response.Messages`'a ekler |
| Controller | iş mantığı içeride, `ProducesResponseType` yok | ince; her action'da `ProducesResponseType(200/400)` |

**→ Collateral:** OptionsFX. Özellikle **template-method deseni** — ortak kuyruk (limit, bildirim,
audit) tek yerde; MM'de her handler'a elle kopyalanıyor.

---

## 5. DataManager / Repository

| | MM | OptionsFX |
|---|---|---|
| DataManager | **72** | **42** |
| Repository | **81** | **28** |
| Yerleşim | karışık; aynı tablo için **hem** DataManager **hem** Repository | net ayrım: Repository = sahipli tablolarda CRUD · DataManager = sorgu/projeksiyon |
| Sonuç modeli adı | `TDM*` (kısaltma) | `TransactionDataManagerGetResult` (açık ad) |

Sayı farkının asıl sebebi `CoreDataSlice` (§7) — ortak referans tabloları artık modülde yaşamıyor.

**→ Collateral:** Bir tabloya **ya** Repository **ya** DataManager, ikisi birden değil.
Sonuç modeli adı açık yazılır, `TDM` kısaltması kullanılmaz.

---

## 6. Entity base'leri ve EF config

`FlowEntity` ve `MakerCheckerEntity` ikisinde de aynı. MM `LastActionId`/`PreviousActionId`'ye
`[OracleMapping]` vermiş, OptionsFX **kasten vermemiş** (*"no backing Oracle column"*).

**MM'in iki-dosya deseni** (`XEntityBase` scalar + `XEntity` navigation) OptionsFX'te daha disiplinli:
`TxnTransactionBaseEntity` → tüm scalar'lar base'de, navigation'lar türeyende.

### 🔴 EF config — `Id` üretimi: ikisi de yetersiz
**İkisinde de ana işlem tablosunun `Id`'si için `UseIdentityColumn()`/`ValueGeneratedNever()`
yazılmıyor.** Id sayaçtan dışarıdan atanıyor ama EF'e söylenmiyor → `ValueGenerated = OnAdd`
varsayılanı kalıyor.
MM'de ayrıca karışıklık: bazı tablolarda `ValueGeneratedNever()`, bazılarında `UseIdentityColumn()`.

**OptionsFX'in net üstünlüğü — precision disiplini:** `TxnTransactionBaseEntityConfiguration`
80+ alanın **hepsine** `HasPrecision` / `HasMaxLength` / `HasColumnType("date")` / `IsRequired(false)`
açıkça yazıyor, ve bunu **abstract generic** config'te toplayıp hem ana tablo hem History için
**tek yerden** veriyor.

**→ Collateral:** OptionsFX'in generic base-config deseni + **her ikisinden üstün kural**:
her entity config'inde `Id` için `UseIdentityColumn()` **veya** `ValueGeneratedNever()` **zorunlu**.

---

## 7. 🔑 `NetTrex.Core.Data` + `CoreDataSlice` — en yüksek getirili tek madde

```csharp
// EfDbContext.OnModelCreating
modelBuilder.ApplyCoreDataModel(CoreDataDbRole.KafkaReplica, OptFxCoreData.Slices);

OptFxCoreData.Slices = DateBasis | Currency | CurrencyPair | Chart | Point
                     | Calendar | Holiday | HalfWorkingDay | FxRate | InterestRate | Volatility
```

Ortak referans verisi modülün `Data.Domain`'inde **yaşamıyor**; paketten "slice" olarak model'e
enjekte ediliyor.

**Ölçülen sonuç: `Data.Domain` MM'de 120 dosya → OptionsFX'te 30 dosya.**
Currency/Calendar/Holiday/FxRate/InterestRate entity'leri, config'leri, repository'leri, consumer
handler'ları ve mapper'ları **hiç yazılmıyor**.

Aynı slice listesi Kafka topic'lerini de besliyor:
```csharp
foreach (var (topic, type) in CoreDataTopics.For(OptFxCoreData.Slices)) topics.Add(topic, type);
```
→ DbContext ile topic listesinin ayrışması **yapısal olarak imkânsız**. MM'de bunlar iki ayrı elle liste.

⚠️ **Tablolar DB'de fiziksel olarak yine var** (3 DB'de de ölçüldü) — yazılmayan şey **kod**.
🔴 **Açık:** `NetTrex.Core.Data` paketinin içi okunamadı (NuGet, kaynak yok) — `CoreDataSlice`
enum'ının tam üye listesi bilinmiyor, slice seçimi yapılmadan önce DLL'e bakılmalı.

---

## 8. Consumer (Kafka)

| | MM | OptionsFX |
|---|---|---|
| Ortak topic'ler | elle, 19 satır `Dictionary` | `CoreDataTopics.For(Slices)` — **otomatik türüyor** |
| Sözlük | her çağrıda `new Dictionary` | `static readonly FrozenDictionary` |
| Bilinmeyen topic | sessiz atlanıyor olabilir *(tahmin)* | açık exception (`ThrowTopicTypeNotFound`) |
| Kafka altyapısı | Consumer'a gömülü | ayrı paylaşılan proje |
| Scope | *(tahmin)* | **mesaj başına `AsyncScope`** (`ChangeTracker` sızıntısı yok) |

MM'de 4 Tax handler'ı **ölü kod** (topic'leri yoruma alınmış), anahtar biçimi tutarsız
(`fxratedetail-insert` kebab ↔ `ExternalUserMap-insert` PascalCase).

**→ Collateral:** OptionsFX, tartışmasız.

---

## 9. Startup / DI

**MM `Startup.cs` ~190 satır:** `RequestLocalization`, Swagger `PreSerializeFilters`,
`AddNetTrexCorePaging()`, `AddStpServices()` — ve 🔴 dosyanın sonunda **tamamen ölü bir
`public class Worker : BackgroundService`** (kayıtlı değil). Türkçe yorumlar bozuk kodlamayla.

**OptionsFX `Startup.cs` ~95 satır:** aynı `NetixApiStartup<ApplicationSettings>` tabanı, ölü kod yok,
composition root 6 çağrı: `AddApiMapper() · AddData(cfg) · AddServices(cfg) · AddAccounting() ·
AddApiServices()` (+`AddDocumentManagementDI`).

⚠️ **Her iki repoda da `appsettings.json`'da canlı DB parolaları düz metin**
(`Password=fCK2uTCJxC`, `Password=Ph4+Gnr2ut`) — Collateral'a **kopyalanmaz**.

⚠️ OptionsFX `Directory.Packages.props`'ta `NetTrex.Core.Parameter` **iki kez** listeli
(10.0.4 ve 10.0.1) — kopyalarken temizle.

---

## 10. KARAR TABLOSU

| # | Konu | Seçim | Gerekçe |
|---|---|---|---|
| 1 | Proje ağacı | **OptionsFX** | daha sığ, `Entities/` ara katmanı yok |
| 2 | Merkezi paket yönetimi | **OptionsFX** | MM'de hiç yok, sonradan 59 csproj'a uygulanamaz |
| 3 | `Common.Kafka` ayrı proje | **OptionsFX** | Api + Consumer ortak kullanır |
| 4 | `MarketIntegration` / `Tools` | **ikisi de değil** | Collateral'da gereksiz 6 proje |
| 5 | Tablo adlandırma felsefesi | **OptionsFX** | "kendi tablosu jenerik, miras tablo eski ad" |
| 6 | Modül kısaltması (`Coll`) | **kullanılmaz** | OptionsFX `OptFx`'i yalnız 2 yerde kullanıyor |
| 7 | Accounting pipeline | **OptionsFX + 4 düzeltme** | §3 |
| 8 | Numaralı dosya öneki (`01_`) | **kullanılmaz** | builder sırayı zaten gösteriyor |
| 9 | Handler tabanı | **OptionsFX** | template-method ile ortak kuyruk tek yerde |
| 10 | Controller | **OptionsFX** | ince, `ProducesResponseType` zorunlu |
| 11 | DataManager vs Repository | **OptionsFX** | bir tabloya biri, ikisi değil |
| 12 | Entity base dosya deseni | **OptionsFX** | scalar base'de, navigation türeyende |
| 13 | EF config generic base | **OptionsFX** | ana + history tek yerden |
| 14 | `Id` üretim stratejisi | **kendi kuralımız** | her config'de açıkça yazılır (§6) |
| 15 | Precision / MaxLength | **OptionsFX** | 80+ alanın hepsinde açık |
| 16 | `Startup.cs` | **OptionsFX** | ölü kod yok |
| 17 | `CoreDataSlice` | **OptionsFX** 🔑 | `Data.Domain` 120 → 30 dosya |
| 18 | Kafka topic sözlüğü | **OptionsFX** | slice listesi ikisini birlikte besler |
| 19 | `appsettings` parola | **ikisi de değil** | secret/env |
| 20 | **Kurulum script'leri** | **DerivSWP** | tek tam emsal (bkz `05-kurulum-scriptleri.md`) |

---

## 11. Ölçülmeyenler

- `NetTrex.Core.Data` paketinin içi (`CoreDataSlice` tam enum listesi) — **DLL'e bakılmalı**
- MM Consumer'ın bilinmeyen topic'te davranışı
- Batch katmanı (`*.Batch.Items`) iki repoda karşılaştırılmadı — Collateral'da EOD gerekirse ayrı tur
- UI tarafı (`Treasy.MM.UI` ↔ `Treasy.OptionsFX.UI`) — OptionsFX.UI bu makinede **klonlu değil**
