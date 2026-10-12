# Faz 5 — Backend Altyapı

**Durum:** ✅ **TAMAM 2026-10-08** · **Kayıt:** [`05`](../progress/05-backend-altyapi.md) · [`06`](../progress/06-auth-fimple-consumer.md) · [`07`](../progress/07-mm-tabani-ve-loglama.md) · [`08`](../progress/08-temel-yapi-tamam.md)

> ⚠️ **Bitiş kriterlerinin 2'si DOĞRULANMADI:** API ayağa kalkmadı ve DB'ye bağlanmadı —
> `NetTrexColManagement` henüz **yok** (Faz 4). Kod derleniyor, çalıştırılmadı.
> Script'ler uygulandıktan sonra bu iki madde **ayrıca** doğrulanacak.

## 1. Amaç

Boş iskelet, **ayağa kalkan** bir API olsun: DbContext bağlanıyor, DI çözülüyor, Swagger açılıyor,
referans verisi geliyor. Hâlâ iş ucu yok.

## 2. Önce oku
- [`../bilgi-bankasi/03-uc-proje-karsilastirma.md`](../bilgi-bankasi/03-uc-proje-karsilastirma.md) — pipeline ve `CoreDataSlice`
- [`../bilgi-bankasi/08-tuzaklar.md`](../bilgi-bankasi/08-tuzaklar.md) — A grubu (EF/kod tuzakları)

## 3. Adımlar

| # | Adım | Not |
|---|---|---|
| 1 | `Program.cs` / `Startup.cs` | OptionsFX deseni, 95 satır |
| 2 | `EfDbContext` + şema eşleme | 🔴 `AddSchemaMapping` + `MSSQLMappingAdapter` |
| 3 | `CoreDataSlice` seçimi | `modelBuilder.ApplyCoreDataModel(CoreDataDbRole.KafkaReplica, ColMgmtCoreData.Slices)` — **aynı liste** Kafka topic'lerini de besler → ayrışma yapısal olarak imkânsız |
| 4 | Entity base'leri | `FlowEntity` (12 alan, `StateId` **long**, `PreviousActionId` dahil) · `MakerCheckerEntity` (3 alan, `StateId` **int**, `CreatedBy`/`CreatedDate` **declare etmiyor** → elle ekle) |
| 5 | Repository / UnitOfWork / DataManager tabanı | |
| 6 | MediatR + FluentValidation + Mapster + Scrutor kayıtları | |
| 7 | `DefNumberGen` servisi + `EntityColumnType` enum | 🔴 Enum değeri **ve** DB satırı çift gerekir |
| 8 | Hata sözlüğü / `ResponseBase` | |

## 4. 🔴 Tuzaklar (ölçülmüş — tekrarlanmasın)

- 🔴 **`AddScoped<IDataContext, EfDbContext>()` + `AddTreasyDbContext<EfDbContext>()` = aynı scope'ta
  İKİ AYRI `DbContext`** (ölçüldü, `ReferenceEquals = False`). `EfDbContext` enjekte eden bir sınıf
  repository'lerin tracker'ını **görmez**. Teşhis/tracker servisleri **`IDataContext`** almalı.
- 🔴 **EF config'te `Id` için `.UseIdentityColumn()` veya `.ValueGeneratedNever()` AÇIKÇA yazılacak.**
  Yazılmazsa EF convention'ı `ValueGeneratedOnAdd` sayıp insert'i patlatır
  (MM'de `ProductDefinition` Create yolunun kırık olmasının sebebi).
  `TxnTransaction` → **`ValueGeneratedNever()`** (sayaçtan geliyor).
- 🔴 **Referans kopyalarında `Id` IDENTITY değil** → `.ValueGeneratedNever()`.
- 🔴 **`IsRequired()` navigation'ı `.Select()` içinde dereference etme** — EF INNER JOIN üretir,
  orphan FK'lı satır **sessizce düşer**, `CountAsync()` saymaya devam eder → **özet N der, liste boş**.
  Skaler subquery veya `EXISTS` kullan.
- ⚠️ **Toplu yazma döngüsünde** bir satırın `Added` artığı sonraki satırın `Commit`'ine karışır.
  Satır başına `ChangeTracker.Clear()` (döngü başında **ve** `catch` içinde).

## 5. Bitiş kriteri
1. ✅ API ayağa kalkıyor, Swagger açılıyor
2. ✅ `NetTrexColManagement`'a bağlanıyor, referans tablolarından okuyor
3. ✅ `DefNumberGen` sayacından numara alınabiliyor (tek uçlu smoke test)

## 6. Çıktı
`../progress/05-backend-altyapi.md`
