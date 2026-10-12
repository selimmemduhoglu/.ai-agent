# 01-KIMLIK.md — ColManagement Adlandırma Sözlüğü

> 🔴 **TEK GERÇEK KAYNAK.** Bir ad lazım olduğunda buraya bakılır, uydurulmaz.
> Burada olmayan bir ad gerekiyorsa **önce buraya yazılır**, sonra kullanılır.
>
> **Karar tarihi:** 2026-10-08 (kullanıcı: *"bu modülün ismini ColManagement olarak belirledik
> son kez, bundan sonra bu modüle bu isimle hitap edip oluşturulacak tablolar ve kodları buna göre
> ayarla"*)

---

## 1. Neden `ColManagement`?

✅ **Patron toplantısında kesinleşti (2026-10-08).** `Col` = **Col**lateral'in kısaltması (Collateral
Management). Yazım **`ColManagement`** — iki kelime, PascalCase, `M` büyük (K-42).

Önceki ad `Collateral`'dı. Repo adları hâlâ `NetTrex.Collateral` / `Treasy.Collateral.UI` —
**kullanıcı yeniden adlandıracak**. Bu dosyadaki adlar **hedef** adlardır; repo henüz eski adıyla
duruyorsa yolu ona göre yaz ama **kodda/DDL'de yeni adı kullan**.

---

## 2. Modül kimliği

| Alan | Değer | Durum |
|---|---|---|
| Modül adı (insan) | **ColManagement** — Hazine Teminat Yönetimi | ✅ |
| Backend repo | `NetTrex.ColManagement` | ⬜ kullanıcı rename edecek |
| UI repo | `Treasy.ColManagement.UI` | ⬜ kullanıcı rename edecek |
| Solution | `Code/NetTrex.ColManagement.sln` | ✅ |
| Namespace / assembly kökü | `NetTrex.ColManagement.*` | ✅ |
| Veritabanı | `NetTrexColManagement` | ⬜ A-10 onay |
| Modül kodu (`ModuleCode`) | **`CM`** | ⬜ A-08 onay |
| `ExternalMainProductCode` (Fimple) | **`CM`** | ⬜ A-08 onay |
| `BatchModuleType` enum üyesi | `ColManagement = ?` *(boş değer seçilecek; mevcut: FI=1 FX=2 Common=3 MM=4 DerivSWP=5 InvFund=6 OptFX=9 Limit=10)* | ⬜ |
| `General:AvailableModules` değeri | `COLMANAGEMENT` *(enum adıyla eşleşmeli)* | ⬜ |
| Parametre path'i / öneki | **`CM.`** (ev deseni: `Opt.`, `DV.`, `MM.`) | ⬜ A-08 |
| Logical date parametresi | 🔴 `Trex:ColManagementLogicalDate` — **modül path'inde DEĞİL** (OptionsFX/DerivSwp emsali) | ✅ |
| Token cache anahtarı | `CmAccessTokenFimple` | ⬜ A-08 |
| Kafka consumer group | `colmanagement-consumer` | ⬜ |
| Micro UI route prefix / Shell `code` | `cm` | ⬜ |
| Micro UI portları | `51xx` web / `61xx` vite, son iki hane aynı (MM 5104/6104) | ⬜ |

### Backend proje adları (✅ kuruldu — OptionsFX zinciriyle birebir, `NetTrex.ColManagement.` öneki)

```
Data        Data · Data.Abstractions · Data.Core · Data.Domain · Data.Mapper · Data.Model · Data.Repository · Data.ResponseRequest
Accounting  Accounting · Accounting.Abstractions · Accounting.Core · Accounting.Mapper · Accounting.Model · Accounting.Services
Common      Common.Abstractions · Common.Core · Common.Kafka · Common.Mapper · Common.Model · Common.ResponseRequest · Common.Services
Api         Api · Api.Core · Api.Mapper · Api.Model · Api.ResponseRequest · Api.Services
Batch       Batch.Api · Batch.Core · Batch.Items · Batch.Mapper · Batch.Model · Batch.ResponseRequest · Batch.Services
Consumer    Consumer.Abstractions · Consumer.Api · Consumer.Core · Consumer.Mapper · Consumer.Model · Consumer.ResponseRequest · Consumer.Services
UnitTests   13 proje (boş — K-30)
```
OptionsFX'te olup bizde olmayan tek grup: `CalculatorEngine` (opsiyon fiyatlama).

---

## 3. 🔑 Tablo adlandırma kuralı

**Tablo adı NE TUTTUĞUNU anlatır, projenin adını değil.**

| Kelime | Ne zaman kullanılır |
|---|---|
| **`Collateral`** | **Domain** — satırın tuttuğu şey gerçekten *teminat varlığı* ise (`CollateralDefinition` = bir teminatın tanımı, `CollateralPosition` = teminat bakiyesi) |
| **`ColManagement`** | **Modül kimliği** — repo, namespace, DB, assembly, modül kodu, parametre path'i + ev konvansiyonunun modül adıyla adlandırdığı **iki tablo** |
| **(ön ek yok)** | Modülün kendi tablosu ve adı zaten tekil (`Annex`, `TxnTransaction`) |

**Gerekçe:** DB adı zaten `NetTrexColManagement` — her tabloya modül adını yazmak tekrar.
OptionsFX kuralı: *modülün kendi tablosu jenerik ad alır, miras alınan tablo (`CusCustomer`,
`PrfPortfolio`) eski adını korur.* Ev konvansiyonunda modül adını taşıyan **tek** tablo ailesi
değerleme (`OptionsFXRevaluation`, `DerivativesRevaluation`) ve modül seviyesi log.

### Tam tablo listesi (Excel v5 → ColManagement)

> 🔴 **2026-10-08 patron toplantısı bu listeyi değiştirdi — Excel v6'da işlenecek**
> ([`bilgi-bankasi/10`](bilgi-bankasi/10-toplanti-2026-10-08.md) §4):
> `CollateralRevaluation` / `ColManagementRevaluation` **silindi** (K-41) ·
> **`TxnTransactionDetail` eklenecek** (K-40) · `AnnexMarginRule` **tartışmalı** (A-24 — Annex'e 8 kolon olabilir) ·
> Tax/Message tabloları sorgulandı.

| Excel v5'teki ad | Nihai ad | Not |
|---|---|---|
| `Annex` | `Annex` | — |
| `AnnexProductScope` | `AnnexProductScope` | — |
| `AnnexMarginRule` | `AnnexMarginRule` | — |
| `CollateralDefinition` | `CollateralDefinition` | domain: bir **teminatın** tanımı |
| `CollateralEligibleCurrency` | `CollateralEligibleCurrency` | — |
| `CollateralCashTerms` | `CollateralCashTerms` | — |
| `CollateralSettlementMap` | `CollateralSettlementMap` | — |
| `CollateralSecurityRule` | `CollateralSecurityRule` | — |
| `CollateralSecurityISIN` | `CollateralSecurityISIN` | — |
| `CollateralSecurityTerms` | `CollateralSecurityTerms` | — |
| `ProductDefinition` | `ProductDefinition` | platform ürün kataloğu (2 satır) |
| `TxnTransaction` | `TxnTransaction` | 🔴 ana işlem tablosu |
| `TxnTransactionCash` | `TxnTransactionCash` | 1:1 alt tip |
| `TxnTransactionSecurity` | `TxnTransactionSecurity` | 1:1 alt tip |
| `CollateralRevaluation` | 🔄 **`ColManagementRevaluation`** | ⚠️ **DEĞİŞTİ** — ev konvansiyonunun modül-adı slotu (`OptionsFXRevaluation` emsali); EOD batch bu adı arar |
| `TxnLimitSnapshot` | `TxnLimitSnapshot` | — |
| `TxnPaymentInstruction` | `TxnPaymentInstruction` | — |
| `TxnMessage` | `TxnMessage` | — |
| `TxnMessageEvent` | `TxnMessageEvent` | — |
| `CollateralAuditLog` | 🔄 **`ColManagementAuditLog`** | ⚠️ **DEĞİŞTİ** — modül seviyesi log, tek bir teminata ait değil |
| `CollateralPosition` | `CollateralPosition` | domain: **teminat** bakiyesi |

**History tabloları:** `AnnexHistory` · `CollateralDefinitionHistory` · `TxnTransactionHistory` ·
`ProductDefinitionHistory`

> ⬜ **Tek satırlık onay bekliyor:** yalnız iki tablo değişiyor (`ColManagementRevaluation`,
> `ColManagementAuditLog`). *"Hepsi `ColManagement*` olsun"* dersen Excel v6 ile hepsini çeviririm —
> ama o zaman `ColManagementDefinition` *teminat tanımı* anlamını kaybeder.

---

## 4. Constraint / index / nesne adları

Ev konvansiyonu, tablo adı üzerinden türetilir:

| Nesne | Kalıp | Örnek |
|---|---|---|
| Primary key | `PK_<Tablo>` | `PK_TxnTransaction` |
| Unique | `UQ_<Tablo>_<İlkKolon>` | `UQ_TxnTransaction_LogicalReference` |
| Index | `IX_<Tablo>_<Kolon>[_<Kolon>]` | `IX_TxnTransaction_DefinitionId_ValueDate` |
| Default | `DF_<Tablo>_<Kolon>` | `DF_TxnTransaction_StateId` |
| Foreign key | `FK_<Bağımlı>_<Hedef>_<Kolon>` | `FK_TxnTransaction_CusCustomer_CustomerId` |
| Trigger | `<Tablo>Trigger` | `TxnTransactionTrigger` |
| History | `<Tablo>History` | `TxnTransactionHistory` |

---

## 5. `DefNumberGen` sayaç satırları

| Ect | `EntityColumnType` enum | `Definition` | Tablo |
|---|---|---|---|
| 0 | `None` | — | — |
| 1 | `TransactionId` | `'Txn_Id'` | `TxnTransaction` |
| 2 | `AccountingEntryMainId` | `'AccEntryMain_Id'` | `AccEntryMain` |
| 3 | `AccountingEntryId` | `'AccEntry_Id'` | `AccEntry` |
| 4 | `GeneratedAccountingEntryId` | `'AccEngineGeneratedAccountRule_Id'` | `AccEngineGeneratedAccountRule` |

🔴 **Sayaç satırı VE enum değeri ÇİFT gerekir** — biri eksikse `sp_GetNewNumbers` `RAISERROR` verir.
🔴 **Önek iki haneli olmalı** — `int.Parse($"{prefix}{number}")` tavanı: 2 hane ~9.999.999 kayıt,
3 hane ~999.999. Kolon `bigint` ama üretici `int`; tavan **koddan** geliyor.
Önek değeri ⬜ **A-09** — koda **77** önerisiyle girdi (`NumberGeneratorDataManager.ModulePrefix`). Dolu önekler: FX 11/22/33/44 · MM 50/55/120 · DerivSwp 88 · OptionsFX 99.

**Hangfire / Batch seed anahtarları (koddan):** `defJobCron.Key` = `ColManagementEod` · `ColManagementBod` · `BatchSet.Id` = 1 (EOD) · 2 (BOD) · logical date parametresi `Trex:ColManagementLogicalDate` (Common'a `OptionName = ColManagementLogicalDate` ile gider).
`LastNumber` başlangıç **0** (DerivSwp biçimi).

---

## 6. Yeniden adlandırma doğrulaması (Faz 4'te zorunlu)

OptionsFX'ten kopyalama sonrası **sıfır kalıntı** kanıtlanır:

```bash
grep -ril "optionsfx\|optfx\|options_fx" .          # 0 sonuç olmalı
grep -ril "collateral" . | grep -v "CollateralDefinition\|CollateralPosition\|CollateralEligible\|CollateralCash\|CollateralSettlement\|CollateralSecurity"
```

⚠️ **Derlenir ama runtime'da patlayan yerler** — grep'in yakalaması şart:
- `appsettings.json` → `Assemblies:Handler` / `Assemblies:Validator` **string** assembly adları
- `Startup.cs` → Scrutor tarama assembly'leri
- Kafka topic adları
- Docker servis adları, `docker-compose.override.yml` ortam değişkenleri
- `.sln` içindeki proje GUID'leri değil ama **yolları**

🔴 `appsettings.json`'da OptionsFX'in **canlı DB parolaları düz metin** duruyor
(`Password=Ph4+Gnr2ut`). İlk commit'ten **önce** temizlenir.


---

## 7. Parametre anahtar kataloğu

🔑 Anahtarlar **kodda tek yerde**: `Data.Core/Constraints/FrameworkParameterConstants.cs`.
Kurulum script'i (Faz 4) `4-NetTrexCommon-Parameter-DML.sql` **aynı** adları yazar — ikisi
ayrışırsa parametre runtime'da bulunamaz ve hata **sessiz** olur (varsayılana düşer).

| Sabit | Anahtar |
|---|---|
| `LogicalDate` | `Trex:ColManagementLogicalDate` |
| `Timezone` | `Trex:HangfireJobs.TimeZoneInfoId` |
| `DefaultCurrency` | `Trex:DefaultCurrency` |
| `TenantSwiftCode` | `Tenant:SwiftCode` |
| `ExternalServiceAccessToken` | `CmAccessTokenFimple` |
| `KeyCloakErrorCodes` | `KeyCloak:TokenErrorCodes` |
| `ModuleEnabled` | `CM:Module.IsEnabled` |
| `DefaultPortfolioPath` | `CM:DefaultPortfolioPath` |
| `SystemWDFlag` | `CM:SystemWDFlag` |

⬜ Faz 7-9'da açılacaklar (adları şimdiden sabit, dosyada yorumda):
`CM:StaleRateToleranceMin` · `CM:MtaDeviationPolicy` · `CM:AllowNegativeBalance` ·
`CM.ExternalService.Accounting:Code` · `CM.ExternalService.Sync:AccountingPush` ·
`CM.FXRate.Transaction:ChartId` · `CM.Limit.Customer.TreasuryLimit:Check`
