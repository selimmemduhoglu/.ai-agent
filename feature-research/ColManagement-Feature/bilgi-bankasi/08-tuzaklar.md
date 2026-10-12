# 08 — Ölçülmüş Tuzaklar

> Hepsi **ölçüm veya kaynak okumasıyla** doğrulandı, tahmin değil. Collateral'da tekrarlanmayacak.
> **Son güncelleme:** 2026-10-07

---

## A. EF Core / kod

| # | Tuzak | Kaçınma |
|---|---|---|
| A1 | 🔴 **EF config'te `Id`'nin generation davranışı yazılmazsa insert patlıyor.** MM `ProductDefinitionConfiguration` ne `.UseIdentityColumn()` ne `.ValueGeneratedNever()` yazıyor → EF convention'ı `ValueGeneratedOnAdd` sayıyor, kolon IDENTITY olmadığı için `OUTPUT INSERTED.Id` bekleyen insert patlıyor. **Create yolu fiilen kırık.** *(kod-seviyesi çıkarım; veri destekliyor: sayaç 999, gerçek Id'ler 1..11)* | Her entity config'inde üç davranıştan birini **açıkça** yaz |
| A2 | 🔴 **`DefNumberGen` satırı + `EntityColumnType` enum değeri ÇİFT gerekiyor.** Biri eksikse `sp_GetNewNumbers` ilk üretim denemesinde `RAISERROR` | İkisini birlikte ekle |
| A3 | 🔴 **Önek + sayaç `int.Parse` ediliyor.** `int.Parse($"{prefix}{number}")` → iki haneli önekte tavan ~9.999.999, üç hanelide ~999.999 kayıt. Kolon `bigint` olması kurtarmıyor | **İki haneli önek** seç |
| A4 | 🔴 **Required navigation `.Select()` içinde dereference edilirse EF INNER JOIN üretir** → orphan FK'lı satır **sessizce düşer**, `CountAsync()` saymaya devam eder (*"özet N diyor, liste boş"*) | Skaler subquery veya `Any()` |
| A5 | 🔴 **OptionsFX pipeline `AddStep<TStep,…>` içinde `TStep`'i yok sayıyor** — DI çözümü `(TIn,TOut)` imzasından. Aynı imzalı iki step → **yanlış step koşar, derleme hatası yok** | `sp.GetRequiredService<TStep>()` + `AsSelf()` kaydı |
| A6 | **OptionsFX `ExceptionHandlingDecorator` yazılmış ama DI'ya kaydedilmemiş** — ölü kod | Kaydet veya sil |
| A7 | **OptionsFX `LoggingDecorator` input/output'u `LogInformation` ile basıyor** → müşteri/tutar verisi Seq'e düşüyor | Seviye `Debug` veya PII maskele |
| A8 | **`AddScoped<IDataContext, EfDbContext>()` + `AddTreasyDbContext<EfDbContext>()` = AYNI SCOPE'TA İKİ AYRI `DbContext`** (ölçüldü: `ReferenceEquals = False`). `EfDbContext` enjekte eden sınıf repository'lerin tracker'ını **görmez** | Tracker/UnitOfWork işinde **`IDataContext`** al |
| A9 | **Toplu yazma döngüsünde bir satırın `Added` artığı sonraki satırın `Commit`'ine karışıyor** — `InsertAsync` kaydetmiyor, kaydeden `UnitOfWork.CommitAsync()` | Satır başına `ChangeTracker.Clear()` (döngü başında **ve** `catch` içinde) |

---

## B. SQL / şema

| # | Tuzak | Kaçınma |
|---|---|---|
| B1 | 🔴 **`*History` tablosunda IDENTITY `Id`'de DEĞİL `HistoryId`'de.** Üç DB'de istisnasız. "Tabloda IDENTITY kolonu var" ≠ "`Id` IDENTITY" | `sys.columns.is_identity`'ye kolon bazlı bak |
| B2 | 🔴 **Trigger `SELECT * FROM inserted` kolon sırasına bağımlı.** Ana tabloya kolon eklenip History'ye aynı sırada eklenmezse **sessizce yanlış kolona yazar** | **Açık kolon listesi** (`TxnMMTrigger` kalıbı) |
| B3 | 🔴 **İsimsiz `DEFAULT` yazılırsa SQL Server rastgele ad üretir** (`DF__TxnTransa__SendC__3D9E16F4`). DerivSwp DDL'inde **9 adet** var | `DF_<Tablo>_<Kolon>` adı ver |
| B4 | 🔴 **PK tipi `int` ile başlamak.** DerivSwp `int` başladı, v1.30'da **üç migration script'iyle** `bigint`'e çevirmek zorunda kaldı | Baştan `bigint` |
| B5 | 🔴 **Muhasebe KURAL tabloları modül DB'sinde YOK** (`AccAccountMap`, `AccEngineEvent`, `AccountRule`…) — ayrı `NetTrexAcc_*` DB'lerinde. Modül DB'si yalnız **kesilmiş fişi** tutar | `USE` satırını doğrula |
| B6 | **Hangfire `dbo`da değil `Hangfire` şemasında** (büyük H küçük f), 11 tablo | — |
| B7 | ⚠️ **`USE` satırında test DB adı bırakma — canlı emsali var.** DerivSwp v1.31: `USE NetTrexDerivSWP_Amortization` / `USE [NetTrexAcc_Amortization]` | Teslimden önce `USE` satırlarını tara |
| B8 | ⚠️ **`BatchLogDetail`'de aynı kolona iki FK** (`FK_BatchDetailLog_BatchLog` + `FK_BatchLogDetail_BatchLog_BatchLogId`) — kopya artığı | Kopyalarken birini at |
| B9 | ⚠️ **`6-…-DML.sql`'deki `TRUNCATE TABLE` idempotent ama YIKICI** — canlıda tekrar koşmak referans kopyasını sıfırlar | İlk kurulum dışında kullanma |
| B10 | ⚠️ **`sp_FrameworkAddParameter` mevcut değeri EZMEZ** — değer güncellemek için script yetmez, satır elle `UPDATE` edilir. `@OptionName` sınırı **50 karakter**, boş `@Value` yazılamaz | Script'e notu düş |
| B11 | 🔴 **Menü satırı Redis cache'ini invalidate etmiyor** — `ModuleMenu:{UserId}` **8 saat** eski menüyü gösterir. DerivSwp menü script'inde bu not **yok** | Script'e *"Redis `ModuleMenu:*` temizlenmeli"* yaz |
| B12 | ⚠️ **`sp_GetNewNumbers` kurulum script'lerinde YOK** ama kod onsuz çalışmıyor — DB projesinden deploy ediliyor olmalı *(tahmin, doğrulanmalı)* | Kurulumdan önce varlığını kontrol et |

---

## C. Konvansiyon / kaynak güvenilirliği

| # | Tuzak | Kaçınma |
|---|---|---|
| C1 | 🔴 **`PROJECT_CONTEXT.md`'deki "para `decimal(38,2)`" bilgisi YANLIŞTI** — fiziksel DB'de `(38,2)` **hiç yok** (para `38,10`, oran `18,10`). EF config'teki 3 satırdan gelmiş, DB'yi yönetmiyor. 2026-10-02'de düzeltildi | Dokümanla fiziksel şema çelişirse **fiziksel şema** kazanır |
| C2 | 🔴 **`TxnTawarruq` creation script'inde `LastActionId`/`PreviousActionId` YOK ama `FlowEntity` 12 alan tanımlıyor** — kolonlar sonradan eklenmiş. **Script tek kaynak değil, base class asıl kaynak** | Entity base'ini koddan oku |
| C3 | ⚠️ **`db-script.md` "her script idempotent" diyor ama ilk kurulum DDL'i idempotent DEĞİL** (SSMS çıktısı, 0 `IF NOT EXISTS`). İdempotency **artımlı** script'lerde başlıyor | İstisnayı bil |
| C4 | ⚠️ **`db-script.md` "parametre SP ile" diyor ama DerivSwp 18/18 elle `INSERT`** — değer lookup'tan geldiği için | İkisi de meşru, duruma göre |
| C5 | 🔴 **OptionsFX'te `BaseMmRequest.cs` dosyası var, içindeki sınıf `BaseOptionsFXRequest<T>`** — MM'den kopyalanmış, **dosya adı değiştirilmemiş** | Kopyalarken dosya adını da değiştir |
| C6 | 🔴 **Her iki repoda `appsettings.json`'da canlı DB parolaları düz metin** (`Password=fCK2uTCJxC`, `Password=Ph4+Gnr2ut`) | Kopyaladıktan sonra **ilk iş** temizlemek |
| C7 | ⚠️ **OptionsFX `Directory.Packages.props`'ta `NetTrex.Core.Parameter` iki kez** (10.0.4 + 10.0.1) | Kopyalarken düzelt |
| C8 | ⚠️ **MM `Startup.cs` sonunda kayıtsız ölü `Worker : BackgroundService`** sınıfı + bozuk kodlamalı Türkçe yorumlar | Kopyalama |
| C9 | ⚠️ **MM'de 4 Tax Kafka handler'ı ölü kod** (topic'leri yoruma alınmış, `TaxRule` tablosu 0 satır) | Kopyalama |
| C10 | ⚠️ **Kafka consumer handler'ları doğrulama YAPMIYOR.** Ölçülmüş bedeli: `Currency.IsoCode` tutarsız · `Currency.BasisCode='SPOT'` (`DefDateBasis`'te böyle değer yok) · `CusCustomer.ExternalCustomerId` mükerrer | Collateral consumer'ına basit doğrulama katmanı ekle — MM'in **yapmadığı** iyileştirme |

---

## D. İş mantığı / veri modeli

| # | Tuzak | Kaçınma |
|---|---|---|
| D1 | 🔴 **Doküman iki rakip versiyonlama desenini üst üste taşıyordu** — immutable revizyon (`RevisionNo` + parent `ValidFrom/ValidTo`) **ve** effective-dated satır (child `ValidFrom/ValidTo` + `IsActive`). İkisi birlikte *"bu kural X tarihinde geçerli mi"* sorusuna **iki cevap** üretiyor | Excel v4'te child tarafı kaldırıldı, parent revizyonu tek kaynak |
| D2 | 🔴 **`Status` (DRAFT/ACTIVE/INACTIVE) ile `StateId` %70 örtüşüyordu** (`DRAFT≈16`, `ACTIVE≈18`) | `Status` kaldırıldı, `INACTIVE` için `IsEnabled bit` |
| D3 | ⚠️ **`SpreadBps` — kesir mi ham bps mi belirsiz** (150 = %1.5?). 100x hata riski | Kod tarafında NET tanımla |
| D4 | ⚠️ **Değerleme tablosunun idempotency'si DB constraint değil, kod disiplinine bağlı** (MM'de find→delete→insert). Aynı güne ikinci reeskont kesilirse bakiye **iki katı** | Collateral'da `UNIQUE` constraint ile DB seviyesinde güvenceye al |
| D5 | ⚠️ **Eşzamanlı iki Decrease** — bakiye kontrolü yarış koşuluna açık | `CollateralPosition` satırı Verify ile **aynı transaction'da** `WITH (UPDLOCK, ROWLOCK)` okunup güncellenir (`sp_GetNewNumbers`'ın kanıtlanmış kalıbı) |


---

## 🔴 Boş iskelette "build geçti" bağımlılık grafiğini KANITLAMAZ (2026-10-08, yaşandı)

Faz 3'te üretilen csproj'larda **gruplar arası** `ProjectReference` yolu yanlıştı:
`..\<Proje>\` yazılmıştı, doğrusu `..\..\<Grup>\<Proje>\`.
Etkilenen 5 dosya: `Api.Core` · `Accounting.Core` · `Common.Core` · `Batch.Core` · `Consumer.Core`.

🔴 **`dotnet restore` 54/54 geçti, `dotnet build` 0 hata verdi** — çünkü o projelerde referansı
**kullanan kod yoktu**. Hata ancak `Startup.cs` yazılınca çıktı:
*"The type or namespace name 'Data' does not exist in the namespace 'NetTrex.ColManagement'"*.

✅ **Desen:** iskelet üretirken grafiği **koddan bağımsız** doğrula — her csproj'un
`ProjectReference`'larını oku, emsal projeyle satır satır karşılaştır. "Build geçti" iskelette
yalnızca *"sözdizimi doğru"* demektir.

⚠️ Aynı sınıf hata, yolu **doğru ama hedefi yanlış** olsaydı (başka bir var olan projeye işaret
etseydi) build yine geçerdi ve hata **çok daha sonra**, yanlış tipin geldiği yerde çıkardı.


---

## 🔴 `IDateTimeProvider` saat dilimini ÇÖZMEZ — TZ container'dan gelir (2026-10-09, decompile)

`Netix.Core.Helpers.DateTimeHelper.DateTimeProvider.GetCurrentDateTime()` gövdesi **yalnız `return DateTime.Now;`** (ilspycmd).
Kayıt: `Netix.Core.Web.Base` → `AddTransient<IDateTimeProvider, DateTimeProvider>()`. Müşteri saat dilimi **container `TZ`**
ortam değişkeniyle verilir (MM helm `values-*.yaml` → `TZ: Europe/Istanbul`). Provider yine de kullanılır: tek değişim noktası
ve testte sahte saat. İş günü kararı → `GetLogicalDateAsync()`.

## ⚠️ `AddQuant()` = tüm QuGet fiyatlama kütüphanesi — takvim için açma (2026-10-09)

OptionsFX `ICalendarService`'i `Treasy.QuGet`'ten alıyor; `AddQuant` faiz eğrisi, volatilite, opsiyon/FX fiyatlama motorları ve
greek hesaplayıcılarını da kaydediyor. MM QuGet'e **hiç** bağlı değil — kendi `ICalendarHelper`'ı var. Takvim için MM deseni.
