# 05 — Kurulum Script'leri (DerivSwp emsali → Collateral şablonu)

> Kaynak: `../Scripts/Ornek_Deriv_Scripts_DDL/` — DerivSwp modülü ilk yazıldığında kullanılmış
> **gerçek** kurulum script'leri (~68.000 satır).
> 🔑 Kullanıcının notu: *"Bizim için önemli olan **`Kurulum Scriptleri`** klasörü altındakiler;
> diğerlerini olayları anla diye attım. Script hazırlayacağın zaman ona bakman yeterli."*
>
> **Analiz tarihi:** 2026-10-07

---

## 1. Kurulum sırası — 10 adım, 3 ayrı veritabanı

| # | Dosya | DB | Satır | Ne yapar | Genel/Özgü |
|---|---|---|---:|---|---|
| 0 | `0-…_Create-PathGuncellenmelidir.sql` | *master* | 120 | `CREATE DATABASE` + ~30 `ALTER DATABASE SET` | **GENEL** |
| 1 | `1-…-DDL.sql` | modül | 1894 | 59 tablo + 1 SP + 3 trigger + 29 DEFAULT + 3 FK | **%70 genel** |
| 2 | `2- Common-DML.sql` | **Common** | 256 | BatchItem (validation) · Portfolio ağacı · Chart · `DefCountMonitoring` + SP | iskelet genel |
| 3 | `3- Common-Menu-DML.sql` | **Common** | 179 | 4 `FrameworkMenu` satırı | iskelet genel |
| 4 | `4- Common-Parameter-DML.sql` | **Common** | 216 | 18 `FrameworkParameter` | yapı genel |
| 5 | `5- Common-Permission-DML.sql` | **Common** | 109 | 4 rol + ~55 action + Super Admin bağlama | iskelet genel |
| 6 | `6-…-DML.sql` | modül | 210 | referans kopyası · Batch · **`DefNumberGen`** · enum · `ProductDefinition` | ilk yarı genel |
| 7 | `7-…-FLoatingRateType-DML.sql` | modül | 55 | 15 satır seed | **tamamen özgü** |
| 8.0/8.1 | `8.x-NetTrexAcc-{CCS,IRS}-DML.sql` | **NetTrexAcc** | 6574/4586 | muhasebe kural ağacı | **tamamen özgü** |
| 9 | `9-CorrectObjectNames.sql` | modül | 205 | ad normalizasyonu | **tamamen genel** |

### Sıra bağımlılıkları
`2 → 4` (parametreler `Chart.Id`'yi 2'de oluşan satırdan okur) · `2 → 6` (6, Common'dan
`Portfolio`/`Chart` kopyalar) · `6 → 7` · `1 → 9`

---

## 2. `0-…Create` — DB oluşturma

```sql
CREATE DATABASE [NetTrexDerivSWP]
 ON PRIMARY (NAME=…, FILENAME=N'…\DATA\NetTrexDerivSWP.mdf', SIZE=112192KB, FILEGROWTH=20%)
 LOG ON (NAME=…_log, FILENAME=N'…_log.ldf', SIZE=32584KB, MAXSIZE=2048GB, FILEGROWTH=20%)
 collate SQL_Latin1_General_CP1254_CI_AS      -- 🔑 Türkçe collation
```
+ ~30 `ALTER DATABASE SET` (`RECOVERY SIMPLE`, `ENABLE_BROKER`, `PAGE_VERIFY CHECKSUM`,
`READ_COMMITTED_SNAPSHOT OFF`, `QUERY_STORE OFF`…).

**Collateral'da değişen:** yalnız DB adı + 2 `FILENAME` yolu. Dosya adındaki *"PathGuncellenmelidir"*
uyarısı bunun için.

---

## 3. `1-…-DDL.sql` — 59 tablo

### 3.1 Sınıflandırma
- **A) Platform altyapısı (19)** — her modülde birebir: `AccEftAccount` `AccEngineGeneratedAccountRule`
  `AccEntry` `AccEntryMain` `AccEntryType` `BatchItem` `BatchLog` `BatchLogDetail` `BatchSet`
  `DefJobCron(+History)` `DefNumberGen` `DefRefNumGen` `TxnSync` `TxnSyncDetail`
  `TxnDocument(+History)` `TxnNote(+History)`
- **B) Common referans kopyası (24)** — `Branch` `Calendar` `Chart` `Currency` `CurrencyPair`
  `CusCustomer` `DateBasis` `DefCorporate*` `DefCountry` `DefLegalVehicle` `DefTaxOffice`
  `FXRate(Detail)` `HalfWorkingDay` `Holiday` `InterestRate(Detail)` `Point` `PrdInstrument`
  `PrfInstrument` `PrfPortfolio` `Tax*`
- **C) Modül ürün/enum tanımları (9)** — yapı genel, içerik özgü: `ProductDefinition` `RateType`
  `RateAdjustmentType` `PaymentFrequency` `InterestMethod(Frequency)` `LiquidationType` `FlowType`
  `FloatingRateType`
- **D) Modüle özgü işlem tabloları (5)** — `TxnTransaction(+History)` `TxnCashFlow(+History)`
  `DerivativesRevaluation`

### 3.2 Kalıplar (ölçülmüş)

| Konu | Gerçek |
|---|---|
| **Biçim** | SSMS **"Generate Scripts"** ham çıktısı (`/****** Object: Table … Script Date … ******/` + `SET ANSI_NULLS ON`) |
| 🔴 **Idempotency** | **HİÇ YOK** — 0 adet `IF NOT EXISTS`. İkinci koşuda tamamı patlar |
| 🔴 **Transaction/TRY-CATCH/PRINT** | **Hiçbiri yok** |
| **PK** | 59 tabloda `CONSTRAINT [PK_<Tablo>] PRIMARY KEY CLUSTERED` + tam `WITH (…)` bloğu. İstisna: `BatchLog(Detail)` NONCLUSTERED |
| **UNIQUE** | 2 adet inline: `UQ_Currency_Code`, `UQ_FXRateDetail_FXRateId` (composite ama ilk kolon adı) |
| 🔴 **Ayrı index** | **0 adet `CREATE INDEX`** — PK/UQ dışında index yok |
| 🔴 **CHECK** | **0 adet** (MM ölçümüyle aynı) |
| **FK** | **3 adet**, hepsi `BatchLog`/`BatchLogDetail` arası. ⚠️ İkisi **aynı kolona iki FK** (kopya artığı) |
| **DEFAULT** | 29 adet, sonda toplu `ALTER TABLE … ADD CONSTRAINT [DF_…]`. ⚠️ **9'u otomatik adlı** (`DF__TxnTransa__SendC__3D9E16F4`) → script 9 düzeltiyor |
| **IDENTITY** | Yalnız `*History.HistoryId` |
| 🔴 **PK tipi** | Base DDL'de **`int`** → v1.30'da üç script'le **`bigint`**'e migrate edilmiş. **Collateral'da baştan `bigint`** |
| **decimal** | `(38,10)` 44 · `(18,10)` 23 · `(18,8)` 6 · `(26,10)` 1 · `(18,0)` 1 |
| ⚠️ **float** | **2 adet**: `Chart.Duration`, `Currency.Pip` — ikisi de Common kopyası, miras. Yeni kolonda kullanma |
| **History+trigger** | 4 çift. Gövde `INSERT INTO XHistory SELECT * FROM inserted` — **açık kolon listesi YOK, `SET NOCOUNT` YOK** (eski kuşak, kopyalanmaz) |
| 🔴 **Hangfire** | Bu script'te **YOK**, hiçbir kurulum script'inde yok → runtime'da kuruluyor *(tahmin)* |
| 🔴 **`sp_GetNewNumbers`** | **YOK.** Tek SP `sp_InsertTxnSyncDetail`. Sayaç SP'si DB projesinden deploy ediliyor olmalı *(tahmin — doğrulanmalı)* |
| **Extended property** | Yüzlerce `sp_addextendedproperty @name='Description_TR'/'Description_EN'` |

---

## 4. `NetTrexCommon`'a yazan 4 script

### 4.1 `2- Common-DML.sql`
| Tablo | Ne yazılıyor |
|---|---|
| `BatchItem` | **Common'ın `DailyCheck` ağacına** 2 satır: `Deriv Validation` (Composite) + `ValidateDerivTransactionsBatchItem` (`ItemID` = tam .NET tip adı). Id IDENTITY değil → `SELECT TOP 1 @last = Id+1 … ORDER BY Id DESC` |
| `Portfolio` | 4 kademe: `TR` → `GCIB` → `DRV` (`Module='DV'`) → `DRVInterbank`. Id IDENTITY (`SCOPE_IDENTITY()`), `Path` sonradan `UPDATE` ile `0/<tr>/<gcib>/<drv>/` |
| `Chart` | `OIS` + `OISZero` (rate engine eğrileri) |
| `DefCountMonitoring` + `sp_UnverifiedDataCount_TxnDerivSwp` | Ekran rozeti. SP `EXEC('CREATE PROCEDURE …')` ile, cross-DB sorgu + bitmask `(StateId & 2) <> 2 AND (StateId & 1) <> 1` |

🔑 **Modülün Common'da tanınması tek satırla değil, 4 ayrı yerden:**
`Portfolio.Module='DV'` · parametre path öneki `DV.` · `ProductDefinition.ExternalMainProductCode='DV'` ·
Common `DailyCheck` ağacına validation `BatchItem`.
⚠️ `General:AvailableModules` **hiçbir kurulum script'inde güncellenmiyor** — elle yapılıyor olmalı *(tahmin)*.

⚠️ Guard deseni: her lookup'tan sonra `IF @x = 0 THROW 500001, '… is not founded…', 1;`

### 4.2 `3- Common-Menu-DML.sql`
- Parent'lar `MenuKey` ile bulunuyor (`TreasuryKey`, `ReportsKey`) → yoksa `THROW`
- 4 satır: klasör (`MenuType='None'`) + yaprak (`MenuType='ControllerAction'`, `Value='DerivSwp/Index'`)
- Kolonlar: `ApplicationName='Trex.WebUI'` · `Description` · `MenuKey` · `MenuType` · `Value` ·
  `ForcedUrl=null` · `ForcedPermission=null` · `Icon` (FontAwesome: `fa-solid fa-right-left`) ·
  `IsActive=1` · `ItemOrderId` · `ParentId` · `StateId=18` · `StateMaker='SYSTEM'`
- `Id` IDENTITY → `SCOPE_IDENTITY()`
- 🔴 **Redis cache notu YOK** — ama `ModuleMenu:*` 8 saat cache'li (bkz `08-tuzaklar.md`)

### 4.3 `4- Common-Parameter-DML.sql`
🔴 **`sp_FrameworkAddParameter` KULLANILMIYOR** — 18/18 elle `INSERT`.
Gerekçe: iki parametrenin değeri **lookup'tan** geliyor (`DV.DepoRate:IndexChartId` ← `Chart.Id`),
SP sabit string alıyor; ayrıca SP boş `@Value`'da `return` ediyor.

**Path taksonomisi (taşınabilir):**
`DV` → `ReverseType`, `SystemWDFlag` · `DV.ExternalService` → `WorkGroupId`, `MailPush` ·
`DV.ExternalService.Sync` → `AccountingPush`, `TransactionPush` · `DV.ExternalService.Accounting` →
`Code`, `ProcessCode`, `Type` · `DV.FXRate` → `ChartId`, `ChartABM`, `TaxChartId`, `TaxChartABM` ·
`DV.DepoRate` → `IndexChartId`, `FloatingChartId`, … · 🔑 `Trex` → `DerivSwpLogicalDate`
(**logical date modül path'inde değil `Trex` altında**)

### 4.4 `5- Common-Permission-DML.sql`
- 🔑 **Ekran başına ayrı rol üçlüsü:** `DerivSwp_Maker` / `_Checker` / `_Displayer`
  (+ rapor ekranı için yalnız `_Displayer`)
- `exec sp_FrameworkAddPermission '<ad>', 'Trex.WebUI'` — **pozisyonel argüman**
- ~55 `sp_FrameworkAddPermissionAction '<rol>','Trex.WebUI','<Controller>/<Action>'`, **satır başına bir action**
  - Displayer = okuma + tüm `Select*` lookup'ları + `Index/Load/History`
  - Maker = `Create/Insert/Update/Delete/Undo/LoadCreate/UpdateLoad` + hesaplama uçları
  - Checker = yalnız `Verify`/`Reject`
- 🔑 **Sonda Super Admin bağlama:** `FrameworkProfile` lookup → `IF NOT EXISTS` + elle
  `INSERT INTO FrameworkProfilePermission`. **`sp_FrameworkAddProfilePermission` kullanılmıyor.**

---

## 5. `6-…-DML.sql` — modül seed'i

Tek `BEGIN TRANSACTION / TRY / CATCH` bloğu.

**(a) Common'dan referans veri çekme — 15 blok:**
```sql
TRUNCATE TABLE <Tablo>;
INSERT INTO <Tablo> SELECT * FROM [NetTrexCommon].[dbo].[<Tablo>];
```
`SELECT *` olanlar: `Calendar, Currency, CurrencyPair, DateBasis, HalfWorkingDay, InterestRate(Detail),
FXRate(Detail)`.
Açık kolon listesi gerekenler (ad/şema farklı): `Chart` · `DefCountry ← Common.Country` ·
`DefLegalVehicle ← Common.LegalVehicle` · `Point` · `PrfPortfolio ← Common.Portfolio` ·
`CusCustomer ← Common.Customer`
🔴 **`TRUNCATE` → idempotent ama YIKICI**: canlıda tekrar koşmak referans kopyasını sıfırlar.

**(b) Modül seed'i:**
- `BatchSet`: `1=EOD`, `2=BOD`
- `BatchItem`: 17 satır, **elle verilmiş Id** ile ağaç. Composite düğümler
  (`DerivSWP EndOfDay` → `Pre Eod`/`Eod`/`Post Eod`) + yaprakta `ItemID` = **tam .NET tipi**
  (`NetTrex.DerivSwp.Batch.Items.EndOfDay.RevaluationBatchItem`)
- **`DefNumberGen`: `TRUNCATE` + 4 satır** — `(1,0,'Txn_Id')` `(2,0,'AccEntryMain_Id')`
  `(3,0,'AccEntry_Id')` `(4,0,'accEngineGeneratedAccountRule_Id')`. `LastNumber` **0**
- `DefJobCron`: `DerivSwpEod='0 00 19 * * 1-5'`, `DerivSwpBod='0 00 5 * * 1-5'`
- `FlowType`: Principal / Interest / Fee (**nakit akışı bacak tipi**, maker-checker flow'u DEĞİL)
- Enum tabloları: `TRUNCATE` + sabit Id'li satırlar
- **`ProductDefinition`**: IRS (1) ve CCS (2). Kolonlar iş davranışını taşıyor: `IsAccountNeeded`
  `IsSameCurrency` `DoPrincipalAmountTransfer` `IsAllowRollover` `IsAllowLiquidation`
  `AccountingMapCode` `ExternalMainProductCode='DV'` `PortfolioRootPath` `PortfolioDefaultPath` `IsEnabled`
  🔑 Portföy bağı **Id ile değil `Path` string'i ile**

---

## 6. `9-CorrectObjectNames.sql` — ad normalizasyonu

6 bağımsız batch, hepsi **cursor + `sp_rename`**:
1. **Tablo adları** — küçük harfle başlayanı PascalCase'e (`COLLATE Latin1_General_BIN` ile
   case-duyarlı karşılaştırma; DB collation CI olduğu için normal `=` çalışmaz)
2. **Trigger adları** — aynı mantık
3. **DEFAULT** → `DF_<Tablo>_<Kolon>`
4. **UNIQUE index** → `UQ_<Tablo>_<Kolon>`
5. **FK** → `FK_<Tablo>_<Hedef>_<kolonlar>` (`STRING_AGG`)
6. **PK** → `PK_<Tablo>`

**Neden gerekmiş:** script 1 ham SSMS çıktısı; içinde 9 otomatik `DF__…` adı ve `txnNoteHistory`,
`defNumberGen` gibi küçük harfle başlayan nesneler var.

**Collateral'da gerekir mi:** DDL elle konvansiyona uygun yazılırsa **gerekmez** — ama ucuz ve
sonraki sürümlerdeki isimsiz DEFAULT'ları yakalar → **son adım olarak konur**.
🔴 Dikkat: 4. batch'in **şema filtresi yok** (1-2-3-5-6 `dbo` ile sınırlı).

---

## 7. `NetTrexAcc-*` script'leri

- **DB:** `NetTrexAcc` (modül DB'si **değil**). `SET XACT_ABORT ON` + tek transaction + `RAISERROR`
- **CCS ve IRS ayrı iki ürün → ayrı script.** Ortak gövde, farklı `ItemCode` ağacı:
  CCS `TREX/DV/CCS/` → LCYRFCYP · FCYRLCYP · FCYRFCYP (3 para kombinasyonu) ·
  IRS `TREX/DV/IRS/` → LCYRLCYP · FCYRFCYP (2)
- **Organizasyon:** ürün → para kombinasyonu → event (`Opening/Revaluation/Payment/Maturation`).
  Zincir: `AccEngineItem` → `AccEngineEvent` → `AccEngineGroup` → `AccEngineComponent` →
  `AccEngineAccountRule` + `AccAccountMap`
- **Kayıt sayıları:** CCS `AccEngineAccountRule` 130 · `AccAccountMap` 51 · `AccEngineComponent` 42 …
  IRS sırasıyla 68 · 36 · 20
- 🔑 **`NetTrexAcc`'in kendi `DefNumberGen`'i var** — script sonunda 11 sayaç tipini **kendisi `UPDATE`
  ediyor**
- 🔑 **Muhasebe kuralı güncelleme yöntemi:** `DELETE FROM AccAccountMap WHERE Path='TREX/DV/IRS'` →
  tam ağacı **yeniden kur**

**Collateral'da ne zaman:** faz-1'de muhasebe kapsam dışı → **hiç yazılmaz**.
Gerektiğinde **IRS script'i emsal alınır** (daha küçük), CCS değil. Önce `accounting-db-script`
skill'i okunur.

---

## 8. Sürüm klasörü düzeni (Collateral'a kopyalanacak)

`Version-1.NN\` + içinde **1'den** numaralama + ana dizin **kümülatif** + aynı sürüm hotfix'i
`<Sürüm> Ek Scriptler\` alt klasöründe.

| Sürüm | Ne getirdi | Desen notu |
|---|---|---|
| 1.26 | ana kurulum | + `Ek Scriptler\` (hotfix) |
| 1.27 | 12 müşteri hesabı kolonu | kolon ekleme: `IF NOT EXISTS (INFORMATION_SCHEMA.COLUMNS …)` |
| 1.28 | `PaymentFrequency`'ye kolon + backfill | DDL ve DML **ayrı dosya** |
| **1.29** | 🔑 **Flow altyapısı** (Common `FlowSet` Id sabit 5, modülde `FlowTransitionData`) | maker-checker flow **sonradan** gelmiş |
| **1.30** | 🔑 **`int → bigint`** üç migration script'i | en büyük kırılma. Her dosya *"Check if this change has already been applied"* ile başlıyor |
| 1.31 | Amortization + muhasebe kuralları | ⚠️ `USE NetTrexDerivSWP_Amortization` — **test DB adı bırakılmış** |
| 1.33 | 6 `*WorkGroupId` kolonu | `COL_LENGTH('T','C') IS NOT NULL` ile kontrol |
| **1.34** | `Spread` `int → decimal(18,10)` | 🔑 **en olgun başlık bloğu**: `Migration / Branch / Aciklama / ONEMLI (kod deploy'u ile SENKRON) / Idempotent` + ASCII-only |
| 1.35 | yeni ekran | = modül DDL + Common menü/permission **çifti** |

---

## 9. `Duruma Gore\` klasörü

İkisi de **`NetTrexCommon`'a** yazıyor, ikisi de **Bloomberg rate engine** entegrasyonu:
`SymbolMap.sql` → `RateEngineSymbolMap` (219 kayıt) · `SymbolDepositChartMapDefinition.sql` →
`RateEngineSymbolDepositRatesChartMap` (219).

**Neden "duruma göre":** ikisi de `RateEngineDataSource.Code='Bloomberg'` arayıp **yoksa
`THROW 51000` ile duruyor** → müşteride Bloomberg kurulu değilse çalıştırılmaz. Sembol listesi
bankanın abone olduğu veri setine bağlı → **müşteriye özel**.

**Collateral karşılığı:** teminat değerlemesi dış fiyat beslemesi isteyecekse aynı desen;
faz-1'de muhtemelen gerekmez *(tahmin)*.

---

## 10. ✅ Collateral kurulum script'i planı

| # | Dosya | DB | Kopyalanabilirlik |
|---|---|---|---|
| 0 | `0-NetTrexColManagement_Create-PathGuncellenmelidir.sql` | master | **birebir** (ad + 2 `FILENAME`) |
| 1 | `1-NetTrexColManagement-DDL.sql` | Collateral | A/B grubu **birebir** (`int`→**`bigint`** çevrilerek) · C/D **sıfırdan** |
| 2 | `2-NetTrexCommon-DML.sql` | Common | iskelet kopya — Portfolio düğümü (`Module='CM'` ⬜ A-08), DailyCheck BatchItem, `sp_UnverifiedDataCount_TxnTransaction` |
| 3 | `3-NetTrexCommon-Menu-DML.sql` | Common | iskelet kopya |
| 4 | `4-NetTrexCommon-Parameter-DML.sql` | Common | iskelet kopya, `ColManagement` path ağacı + `Trex:ColManagementLogicalDate` |
| 5 | `5-NetTrexCommon-Permission-DML.sql` | Common | iskelet + Super Admin bağlama; action listesi controller'dan türetilir |
| 6 | `6-NetTrexColManagement-DML.sql` | Collateral | referans kopyası + Batch + **`DefNumberGen` 4 satır** + enum + `ProductDefinition` |
| 7 | *(ops.)* modüle özgü büyük seed | Collateral | sıfırdan |
| 8 | *(FAZ 2)* `8-NetTrexAcc-CM-DML.sql` | NetTrexAcc | 🔴 **faz-1'de YAZILMAZ** |
| 9 | `9-CorrectObjectNames.sql` | Collateral | **birebir** (yalnız `USE` değişir) |

### 🔴 Üç pratik uyarı
1. **A/B grubu tablolarını kopyalarken `int` PK'ları doğrudan `bigint` yaz** — DerivSwp bunu
   4 sürüm sonra 3 script'le düzeltmek zorunda kaldı.
2. **`float` iki kolonu** (`Chart.Duration`, `Currency.Pip`) Common kopyası olduğu için şema uyumu
   adına aynen kalır — ama Collateral'ın **kendi** kolonlarında kullanılmaz.
3. **Trigger'ları açık kolon listesiyle yaz**, DerivSwp'un `SELECT *` kuşağını kopyalama.
