# Faz 4 — DB Kurulum Script'leri

**Durum:** ⬜ · **Ön koşul:** Faz 3 (backend iskeleti)
**Bloke eden:** Faz 0 kararları (`A-08` modül kodu · `A-09` sayaç öneki · `A-10` DB adı) **+ Excel'in kesinleşmesi**

> 🔴 **Ertelendi (2026-10-08, kullanıcı kararı):** *"bugün patrona sunacağım DB'yi, belki birkaç küçük
> değişiklik olabilir"* → Excel v5 sunum sonrası değişebilir. Script şemadan **doğrudan** türediği
> için şema oturmadan yazılmaz; yazılırsa iki kez yazılır.

---

## 1. Amaç

`NetTrexColManagement` veritabanını **sıfırdan** kuran, `NetTrexCommon`'a modülü tanıtan ve ikinci
kez koşturulabilen bir script seti üretmek. Faz sonunda kullanıcı script'leri sırayla çalıştırıp
boş ama **çalışmaya hazır** bir modül DB'si elde eder.

🔴 **Script ÇALIŞTIRILMAZ.** `.ai-agent/outputs/<tarih>-ColManagement-Kurulum/` altına yazılır,
yolu bildirilir, **kullanıcı uygular**.

---

## 2. Önce oku

| Dosya | Niçin |
|---|---|
| 🔴 [`skills/db-script.md`](../../../skills/db-script.md) | **ZORUNLU** — idempotency iskeleti, isim konvansiyonu, "ne YAZILMAZ" listesi, `DefNumberGen`/History/Trigger kalıpları |
| 🔑 [`../bilgi-bankasi/05-kurulum-scriptleri.md`](../bilgi-bankasi/05-kurulum-scriptleri.md) | DerivSwp'un gerçek script'lerinin anatomisi + §10 dosya planı |
| [`../bilgi-bankasi/06-ev-konvansiyonlari.md`](../bilgi-bankasi/06-ev-konvansiyonlari.md) | Tip/isim/constraint/audit kuralları tek sayfa |
| [`../01-KIMLIK.md`](../01-KIMLIK.md) | Adlar — uydurma, buradan al |
| 🔑 [`../2026-10-07-Collateral-DB-Sema-v5.xlsx`](../2026-10-07-Collateral-DB-Sema-v5.xlsx) | **DDL'in tek kaynağı** |
| [`../Scripts/Ornek_Deriv_Scripts_DDL/Kurulum Scriptleri/`](../Scripts/Ornek_Deriv_Scripts_DDL/) | Ham emsal — biçim için bakılır, **kusurları kopyalanmaz** |

---

## 3. Alt fazlar

Hepsini tek turda yazma. Her alt faz kendi başına gözden geçirilebilir olmalı.

### 3a — `0` DB oluşturma
`0-NetTrexColManagement_Create-PathGuncellenmelidir.sql`
- DerivSwp'den **birebir**; değişen: DB adı + 2 `FILENAME` yolu
- 🔑 `collate SQL_Latin1_General_CP1254_CI_AS` (Türkçe) · `RECOVERY SIMPLE` · `ENABLE_BROKER`
- Dosya adındaki *"PathGuncellenmelidir"* uyarısı bilinçli — yol kullanıcının sunucusuna göre

### 3b — `1` DDL (en büyük parça)
`1-NetTrexColManagement-DDL.sql`

Dört grup, **ayrı ayrı** üretilir:

| Grup | İçerik | Kaynak | Not |
|---|---|---|---|
| **A** Platform altyapısı (~19 tablo) | `AccEntryMain` `AccEntry` `AccEngineGeneratedAccountRule` `AccEntryType` `AccEftAccount` `BatchItem` `BatchLog(Detail)` `BatchSet` `DefJobCron(+History)` `DefNumberGen` `DefRefNumGen` `TxnSync(Detail)` `TxnDocument(+History)` `TxnNote(+History)` | DerivSwp birebir | 🔴 **`int` PK'ları doğrudan `bigint` yaz** |
| **B** Common referans kopyası | `Currency` `CurrencyPair` `FXRate(Detail)` `Calendar` `Holiday` `HalfWorkingDay` `DateBasis` `CusCustomer` `PrfPortfolio` `Chart` `Point` … | DerivSwp birebir | Liste `A-11` (`CoreDataSlice`) ile kesinleşir. ⚠️ `Chart.Duration` / `Currency.Pip` `float` — **miras**, aynen kalır |
| **C** Ürün/enum tanımları | `ProductDefinition` (+History) | Excel v5 | DerivSwp'un 8 enum tablosunun Collateral karşılığı **yok** — kod listeleri C# enum olarak yaşıyor |
| **D** Modüle özgü (21 tablo) | `Annex`* · `CollateralDefinition`* · `TxnTransaction`* · `ColManagementRevaluation` · `CollateralPosition` … | 🔑 **Excel v5'ten üretilir** | Tam liste [`../01-KIMLIK.md`](../01-KIMLIK.md) §3 |

**Her tablo için üretilecekler:** `CREATE TABLE` + `PK_` + `UQ_` + `IX_` + `DF_` +
(gerekiyorsa) `<T>History` + `<T>Trigger`.

### 3c — `2`-`5` NetTrexCommon'a yazanlar
| # | Dosya | İçerik |
|---|---|---|
| 2 | `2-NetTrexCommon-DML.sql` | Portföy ağacı (`Module='CM'`) · `DailyCheck` ağacına validation `BatchItem` · `DefCountMonitoring` + `sp_UnverifiedDataCount_TxnTransaction` |
| 3 | `3-NetTrexCommon-Menu-DML.sql` | `FrameworkMenu` satırları — parent `MenuKey` ile bulunur, yoksa `THROW` |
| 4 | `4-NetTrexCommon-Parameter-DML.sql` | `ColManagement` path'i altındaki parametreler **+ `Trex:ColManagementLogicalDate`** |
| 5 | `5-NetTrexCommon-Permission-DML.sql` | Roller + action listesi + Super Admin bağlama |

⚠️ **Sıra bağımlılığı:** `2 → 4` (parametre değeri 2'de oluşan satırın `Id`'sini okuyor) ·
`2 → 6` · `1 → 9`.

### 3d — `6` modül seed
`6-NetTrexColManagement-DML.sql`
- Common'dan referans kopyalama (`Portfolio`, `Chart`…)
- `BatchItem` / `BatchSet` satırları
- 🔴 **`DefNumberGen` 4 satır** (`Txn_Id` · `AccEntryMain_Id` · `AccEntry_Id` · `AccEngineGeneratedAccountRule_Id`), `LastNumber = 0`
- `ProductDefinition` 2 satır: `CASH`, `SECURITY`
- `FlowSet` / `FlowState` / `FlowTransition` / `FlowSetTransition` seed

### 3e — `9` ad normalizasyonu
`9-CorrectObjectNames.sql` — DerivSwp'den **birebir** (yalnız `USE` değişir).
Otomatik adlı `DF__Xxx__Yyy__3D9E16F4` constraint'lerini `DF_<Tablo>_<Kolon>`'a çevirir.
🔑 Bizde zaten hepsi açık adlı yazılacağı için **boş geçebilir** — yine de tutarlılık için konur.

### 3f — `8` muhasebe (🔴 BU FAZDA YAZILMAZ)
`8-NetTrexAcc-CM-DML.sql` → **Faz 9**. Muhasebe **kural** ağacı modül DB'sinde değil
`NetTrexAcc`'te yaşıyor; iş kuralları netleşmeden yazılamaz.
⚠️ Ama `AccEntryMain` / `AccEntry` / `AccEngineGeneratedAccountRule` **tabloları** 3b'de kurulur —
üçü de aynı sayaçtan besleniyor, sonradan eklemek bağımlılığı baştan kurmak demek.

---

## 4. 🔴 DerivSwp'den KOPYALANMAYACAK kusurlar

Emsal script'ler SSMS "Generate Scripts" ham çıktısı. Biçim alınır, **şu 6 kusur alınmaz**:

| # | DerivSwp'te | Bizde |
|---|---|---|
| 1 | 🔴 **0 adet `IF NOT EXISTS`** — ikinci koşuda tamamı patlar | **Her nesne idempotent** (`db-script.md` iskeleti) |
| 2 | 🔴 Hiç `TRY/CATCH`, `PRINT`, transaction yok | `PRINT` dalları (`oluşturuldu` / `zaten var`) + hata yakalama |
| 3 | 🔴 PK'ler `int` → v1.30'da 3 migration script'iyle `bigint`'e çevrilmiş | **Baştan `bigint`** |
| 4 | Trigger gövdesi `INSERT INTO XHistory SELECT * FROM inserted` | 🔴 **Açık kolon listesi** + `SET NOCOUNT ON` + `FOR UPDATE, DELETE` + `FROM deleted` |
| 5 | 9 DEFAULT **otomatik adlı** → script 9 düzeltiyor | Hepsi `DF_<Tablo>_<Kolon>` açık adlı |
| 6 | `BatchLog`/`BatchLogDetail` arasında **aynı kolona iki FK** (kopya artığı) | Tek FK |

⚠️ **`GO` `TRY/CATCH` içine giremez** — idempotency iskeletini buna göre kur.

---

## 5. Tuzaklar (ölçülmüş)

- 🔴 **`FrameworkMenu`'ye satır eklemek YETMEZ:** `ModuleMenu:{UserId}` Redis hash'i **8 saat TTL**
  ile bayat kalır, menü görünmez. Script'e *"Redis `ModuleMenu:*` temizlenmeli"* notu düşülür.
  (`FrameworkMenu`'ye yazan hiçbir yer cache'i invalidate etmiyor — ölçüldü.)
- 🔴 **`General:AvailableModules` hiçbir kurulum script'inde güncellenmiyor** — elle yapılıyor
  (`D-04`). Script'e **not** olarak yazılır, sessizce atlanmaz.
- 🔴 **`sp_GetNewNumbers` kurulum script'lerinde YOK** (`D-02`) — `TrexFramework` DB projesinden
  deploy ediliyor olmalı. **Doğrulanmadan** modül DB'si çalışmaz; Faz 3'te doğrula.
- 🔴 **Hangfire tabloları hiçbir script'te yok** (`D-03`) — runtime'da kuruluyor olmalı.
- 🔴 **Parametreye `Id` değil `Code` yaz.** ⚠️ `Name` de olmaz, `ExternalCode` de olmaz
  (üçü üç ayrı kelime olabiliyor) — ama **dış sisteme giden** çağrıda `ExternalCode` kullanılır.
- 🔴 **`sp_FrameworkAddParameter` sınırları:** `@OptionName` 50 karakter · mevcut değeri **EZMEZ** ·
  boş `@Value` ile `return` eder. Değer bir lookup'tan geliyorsa elle `INSERT` meşru
  (DerivSwp 18/18 böyle yapmış).
- ⚠️ **`Txn*` tablosunun `Id`'si IDENTITY DEĞİL** — seed/test verisi yazarken `DefNumberGen`'den alınır.
- ⚠️ Lookup guard deseni: her lookup'tan sonra `IF @x = 0 THROW 500001, '… is not founded…', 1;`

---

## 6. Bitiş kriteri

1. ✅ Tüm script'ler `.ai-agent/outputs/<tarih>-ColManagement-Kurulum/` altında + `00-OKU-BENI.md`
   (çalıştırma sırası, hangi DB'ye, ön koşullar, geri alma)
2. ✅ Her script **iki kez** koşturulabilir (idempotency) — gözle doğrulanır
3. ✅ Excel v5'teki **her** tablo DDL'de var; fazlası yok → karşılaştırma tablosu yazılır
4. ✅ `DefNumberGen` 4 satır + `EntityColumnType` enum değerleri **eşleşiyor**
5. ✅ Her `*History` tablosu için trigger var ve **açık kolon listesi** kullanıyor
6. ✅ `grep -i "float\|real\|decimal(38,2)"` → yalnız iki miras kolonda (`Chart.Duration`, `Currency.Pip`)
7. ✅ `D-02` (`sp_GetNewNumbers` nereden geliyor) **cevaplanmış**

---

## 7. Çıktı

```
NetTrex.ColManagement/.ai-agent/outputs/<tarih>-ColManagement-Kurulum/
├── 00-OKU-BENI.md
├── 0-NetTrexColManagement_Create-PathGuncellenmelidir.sql
├── 1-NetTrexColManagement-DDL.sql
├── 2-NetTrexCommon-DML.sql
├── 3-NetTrexCommon-Menu-DML.sql
├── 4-NetTrexCommon-Parameter-DML.sql
├── 5-NetTrexCommon-Permission-DML.sql
├── 6-NetTrexColManagement-DML.sql
└── 9-CorrectObjectNames.sql
```
+ [`../progress/NN-db-kurulum-scriptleri.md`](../progress/)
