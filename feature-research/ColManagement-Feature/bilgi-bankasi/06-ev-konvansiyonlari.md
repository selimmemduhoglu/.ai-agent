# 06 — Ev Konvansiyonları (tek sayfa referans)

> Üç repo (MM · OptionsFX · DerivSWP) ve üç DB ölçülerek çıkarıldı. Collateral'ın her tablosu,
> kolonu ve script'i bu kurallara uyar.
> **Ölçüm tarihi:** 2026-10-07 · Daha ayrıntılı kaynak: `.ai-agent/skills/db-script.md`

---

## 1. Tablo adlandırma

> **Modülün KENDİ sahip olduğu tablo jenerik ad alır. Platformdan MİRAS gelen tablo eski adını korur.**

| Prefix | Anlamı | Örnek |
|---|---|---|
| `Txn` | işlem/ledger ve bağlı her şey | `TxnTransaction`, `TxnTransactionHistory`, `TxnNote`, `TxnSync` |
| `Def` | tanım/referans/sistem | `DefNumberGen`, `DefRefNumGen`, `DefJobCron`, `DefCountry` |
| `Acc` | muhasebe | `AccEntryMain`, `AccEntry` |
| `Cus` / `Prf` / `Prd` | müşteri / portföy / ürün | `CusCustomer`, `PrfPortfolio`, `PrdInstrument` |
| prefix yok | yeni nesil lookup / market verisi | `Currency`, `Calendar`, `ProductDefinition`, `SettlementType` |

- Tablo adları **PascalCase**. Kodda görülen `cusCustomer` / `defNumberGen` gibi küçük harfli yazımlar
  yalnız kod tutarsızlığı; fiziksel şema PascalCase (script 9 bunu düzeltiyor).
- Alt tablo = ana tablo adı + sonek: `TxnTransaction` → `TxnTransactionHistory`
- Saf eşleme tablosu soneki **`Map`**

**Modül adı yalnız değerleme tablosunda kalır** — `OptionsFXRevaluation`, `DerivativesRevaluation`.
Kuralın tek istisnası.

---

## 2. Kolon adlandırma

| Kural | Örnek |
|---|---|
| PK her zaman **`Id`** | — |
| FK → `<Hedef>Id` | `CustomerId`, `PortfolioId`, `DefinitionId` |
| Doğal anahtarlı hedefe FK → `<X>Code` | `CurrencyCode`, `MarketCode`, `DateBasisCode` |
| Ana işleme bağlanan alt tabloda | **`TxnId`** |
| Boolean | `Is<Sıfat>` (`IsEnabled`, `IsActive`). İstisna: eylem bayrakları `Send*`/`Use*` |
| Tarih kolonu soneki | **`...Date`** — `_at` / `Timestamp` kalıbı **YOK** |
| History PK | **`HistoryId`** (IDENTITY); `Id` kaynak satırın Id'sini taşır |

`IsEnabled` standart (23 tabloda), `IsActive` yalnız 1 tabloda. `IsDeleted` **hiç yok** —
silme `StateId`'nin Deleted biti ile.

---

## 3. Tipler

| Veri | Tip |
|---|---|
| **PK (`Id`)** | 🔴 **`bigint`** — ofis kuralı. DerivSwp `int` başlayıp v1.30'da 3 script'le düzeltmek zorunda kaldı |
| Para / tutar / fiyat / nominal / FX kuru | **`decimal(38,10)`** |
| Oran / yüzde / haircut (0..1) | **`decimal(18,10)`** |
| 🔴 `float` / `double` / `real` | **YASAK** (mevcut 2 istisna Common kopyası mirası) |
| Boolean | `bit`, `NOT NULL` + `DEFAULT (0)` tercih |
| İş tarihi (`TradeDate`, `ValueDate`, `ValidFrom`) | `date` |
| Zaman damgası / audit | `datetime` (`datetime2` yalnız Hangfire'da) |
| Döviz kodu | `nvarchar(3)` |
| Kod / ad / dış kod | `nvarchar(50)` |
| Kullanıcı / `LogicalReference` | `nvarchar(80)` |
| Açıklama | `nvarchar(100-200)` · serbest metin `nvarchar(500)` |
| Uzun metin / JSON / hata | `nvarchar(MAX)` (SQL Server'da `jsonb` yok) |
| UUID | `uniqueidentifier` — **yalnız** SWIFT `UETR` gibi zorunlu yerlerde |

⚠️ `decimal(38,2)` MM'de **fiziksel olarak hiç yok** — `PROJECT_CONTEXT.md`'de yazan bilgi yanlıştı,
2026-10-02'de düzeltildi.

---

## 4. Id üretimi — üç farklı davranış

| Tablo tipi | Id | EF config |
|---|---|---|
| **Ana işlem tablosu** (`TxnTransaction`) | `bigint`, **IDENTITY DEĞİL** — `DefNumberGen` Ect 1 | `.ValueGeneratedNever()` |
| **Muhasebe** (`AccEntryMain`, `AccEntry`, `AccEngineGeneratedAccountRule`) | `int`, **IDENTITY DEĞİL** — Ect 2/3/4 | `.ValueGeneratedNever()` |
| **Yardımcı / log / History** (`TxnNote`, `TxnSync`, `BatchLog`, `*History`) | **IDENTITY** | `.UseIdentityColumn()` |
| **Referans kopyası** (`CusCustomer`, `Currency`…) | Common'ın Id'si **taşınır** | `.ValueGeneratedNever()` |

🔴 **EF config'te bu üçünden biri AÇIKÇA yazılmazsa** EF convention'ı `ValueGeneratedOnAdd` sayar ve
insert patlar. MM'de `ProductDefinition` Create yolu bu yüzden kırık.

### `DefNumberGen` seed (yeni biçim)
```sql
TRUNCATE TABLE DefNumberGen;
INSERT INTO DefNumberGen (EntityColumnType, LastNumber, Definition, LastUpdateDate) VALUES
 (1, 0, 'Txn_Id',                           GETDATE()),
 (2, 0, 'AccEntryMain_Id',                  GETDATE()),
 (3, 0, 'AccEntry_Id',                      GETDATE()),
 (4, 0, 'AccEngineGeneratedAccountRule_Id', GETDATE());
```
`EntityColumnType` enum'ı nötr biçimde: `None=0 · TransactionId=1 · AccountingEntryMainId=2 ·
AccountingEntryId=3 · GeneratedAccountingEntryId=4`

🔴 **Sayaç + enum ÇİFT gerekir** — biri eksikse `sp_GetNewNumbers` ilk üretimde `RAISERROR`.
🔴 **Önek iki haneli olmalı** — `int.Parse($"{prefix}{number}")` tavanı: 2 hane → ~9.999.999 kayıt.

---

## 5. Constraint ve index

| Nesne | Biçim |
|---|---|
| Primary key | `PK_<Tablo>` (CLUSTERED) |
| Unique | `UQ_<Tablo>_<İlkKolon>` — **composite olsa bile yalnız ilk kolon ada girer** |
| Non-unique index | `IX_<Tablo>_<Kolon>` |
| Default | `DF_<Tablo>_<Kolon>` — 🔴 **isimsiz `DEFAULT` asla yazılmaz** |
| Foreign key | `FK_<Bağımlı>_<Hedef>_<FkKolon>` |
| Trigger | `<Tablo>Trigger` |

### 🔴 Ne YAZILMAZ
| Nesne | Ölçüm | Kural |
|---|---|---|
| **CHECK constraint** | MM: 0 · DerivSwp DDL: 0 | **yazma** — doğrulama FluentValidation/domain'de |
| **FK (işlem tabloları arası)** | MM: 125 tabloda 14 FK · DerivSwp: 3 FK (hepsi Batch) | **yazma**; yazılacaksa yalnız referans tablosuna, `ON DELETE` **yazma** (NO_ACTION) |
| **Filtered/partial unique** | 3 DB'de **0 adet** | emsalsiz — gerekirse bilinçli sapma kararı |
| **Yeni stored procedure** | MM: 125 tabloya 9 SP | yeni tablo SP gerektirmez. İstisna: `sp_UnverifiedDataCount_<Ekran>` |
| **Yeni function** | 28 legacy var | yazma, mevcutları çağır |

### Varsayılan değerler
`StateId` → `((18))` · `StateDate`/`CreatedDate` → `(getdate())` · `StateMaker` → `('system')` ·
bit → `((0))` (açık olması gerekende `((1))`) · zorunlu `nvarchar` → `('')`

---

## 6. Audit blokları

### `FlowEntity` (12 alan) — ana işlem tabloları
`Id` (long) · `StateId` (**long**) · `StateMaker` · `StateDate` · `CreatedBy` · `CreatedDate` ·
`PreviousStateId` · `PreviousStateMaker` · `PreviousStateDate` · `FlowId` · `LastActionId` ·
`PreviousActionId`
+ işlem tablolarında ayrıca **`Trader`** (`nvarchar(80)`, `CreatedBy`'dan **ayrı** iş alanı)

### `MakerCheckerEntity` (3 alan) — tanım tabloları
`StateId` (**int**) · `StateMaker` · `StateDate`
⚠️ **`CreatedBy`/`CreatedDate` TANIMLAMIYOR** — entity sınıfına elle eklenir.

### `StateId` bitmask
`1` Rejected · `2` Verified · `4` Deleted · `8` Edited · `16` Input
Kombinasyonlar: `16` Input · **`18` Input+Verified (onaylı/aktif)** · `17` Rejected · `20` Delete ·
`22` DeleteVerified · `24` Edit
Test: `FlowStateHelper.CheckState(stateId, FlowState.Verified)` — **`== 18` yazma**, maskeyi kontrol et.

### `FlowTransition` ActionId
`2` Create · `4` Update · `8` Delete · `16` Verify · `32` Reject

---

## 7. History + Trigger

**Kriter:** "`StateId` var" DEĞİL → **"kullanıcının ekrandan düzenlediği entity"**.
(MM'de `StateId` 55 tabloda, History yalnız 9'unda.)

| History VAR | History YOK |
|---|---|
| ana işlem tablosu · ürün tanımı · düzenlenebilir alt kayıtlar (`TxnNote`, `TxnDocument`, `TxnCashFlow`) | referans/enum tabloları · log/append-only · hesaplama çıktıları · muhasebe · **referans kopyaları** |

```sql
CREATE OR ALTER TRIGGER [dbo].[<Tablo>Trigger]
ON [dbo].[<Tablo>] FOR INSERT, UPDATE
AS BEGIN
    SET NOCOUNT ON;
    INSERT INTO [dbo].[<Tablo>History] ([Kolon1],[Kolon2],…)
    SELECT [Kolon1],[Kolon2],… FROM inserted;   -- 🔴 AÇIK KOLON LİSTESİ
END
```
🔴 `SELECT * FROM inserted` **kullanma** — kolon sırasına bağımlı, ana tabloya kolon eklenince
sessizce yanlış kolona yazar. (DerivSwp'un 4 trigger'ı da eski kuşak, kopyalanmaz.)
🔴 `CREATE TRIGGER` batch'in **ilk satırı** olmalı.

---

## 8. Modülün platformda tanınması — 4 ayrı yer

1. `NetTrexCommon.Portfolio.Module = '<KOD>'` (DerivSwp: `DV`)
2. `FrameworkParameter` path öneki `<KOD>.`
3. `ProductDefinition.ExternalMainProductCode = '<KOD>'`
4. Common'ın `DailyCheck` `BatchItem` ağacına validation düğümü

⚠️ `General:AvailableModules` hiçbir kurulum script'inde güncellenmiyor — elle *(tahmin)*.

---

## 9. Ekran rozeti (onay bekleyen sayısı)

**Tablo başına değil, EKRAN başına** bir çift, ikisi de **`NetTrexCommon`'da**:
- `DefCountMonitoring` satırı — `Id = MAX(Id)+1` (IDENTITY değil) · `Query = 'EXEC sp_… @CurrentUserId'` ·
  `ScreenUrl = 'general/<Controller>/Index'` · `Connection = 'Connection'` ·
  `DefaultUnverifiedStateId = '3'` · `State = 1`
- `sp_UnverifiedDataCount_<Ekran>` — `EXEC('CREATE PROCEDURE …')` ile kurulur, **cross-DB** sorgular:
  `FROM NetTrexCollateral.dbo.<Tablo> WITH (NOLOCK) WHERE (StateId & 2) <> 2 AND (StateId & 1) <> 1`

---

## 10. Kod tarafı (OptionsFX deseni)

| Konu | Kural |
|---|---|
| Dikey akış | Controller → Request → Validator → Handler → Mapper → Factory → DataManager → Entity → `UnitOfWork.CommitAsync()` |
| Controller | **ince** — yalnız `Mediator.Send` + `ProducesResponseType(200/400)`. İş mantığı asla içeride |
| Handler tabanı | `TransactionBaseHandler<TReq,TRes>` template-method — ortak kuyruk (limit, bildirim) tek yerde |
| DataManager vs Repository | Bir tabloya **ya** biri **ya** öteki. Sonuç modeli adı açık (`XDataManagerGetResult`), `TDM` kısaltması yok |
| Entity dosya deseni | `XBaseEntity` (scalar) + `XEntity` (navigation) |
| EF config | `XBaseEntityConfiguration<TEntity>` generic base → ana + History tek yerden. Precision/length/nullability **istisnasız** açık |
| Pipeline | OptionsFX fluent builder + 4 düzeltme (bkz `03-uc-proje-karsilastirma.md` §3) |
| Referans verisi | **`CoreDataSlice`** — entity/config/repository/handler **yazılmaz** |
| Kafka | `CoreDataTopics.For(Slices)` — slice listesi DbContext'i ve topic'leri birlikte besler |
| Paket yönetimi | `Directory.Build.props` + `Directory.Packages.props` — **ilk gün** |
| Modül kısaltması | kodda/namespace'te **tam ad**, kısaltma yalnız Oracle şema + slice sabiti |

---

## 11. Script yazma kuralları

| Kural | Not |
|---|---|
| Script **çalıştırılmaz** | `.ai-agent/outputs/<tarih>-<iş>/` altına yazılır, kullanıcı uygular |
| EF Core migration **yok** | şema script'lerle yönetilir |
| İlk kurulum DDL'i | ⚠️ idempotent **değil** (SSMS çıktısı) — idempotency **artımlı** script'lerde başlar |
| Artımlı script | `IF NOT EXISTS` + `BEGIN TRY/TRANSACTION/ROLLBACK/THROW` + **her dalda `PRINT`** |
| `GO` | `TRY/CATCH` içine **giremez**; `CREATE TRIGGER`/`PROCEDURE` batch'in ilk satırı → `EXEC('…')` |
| Türkçe karakter | script gövdesinde **kullanma** (collation farkında bozulur), `PRINT`'lerde ASCII |
| Parametre | `sp_FrameworkAddParameter` tercih — ⚠️ ama değer lookup'tan geliyorsa elle `INSERT` meşru (DerivSwp 18/18 böyle yapmış) |
| Doğrulanmamış değer | uydurma — `0-DOGRULAMA` sorgusuna çevir veya inline `IF @x = 0 THROW` guard'ı koy |
| Sürüm klasörü | `Version-1.NN\` + içinde 1'den numaralama + ana dizin kümülatif |
| Başlık bloğu (olgun hal) | `Migration / Branch / Aciklama / ONEMLI (kod deploy'u ile SENKRON) / Idempotent` |
