# 02 — Veri Modeli

> Tek gerçek kaynak: **`../2026-10-07-Collateral-DB-Sema-v5.xlsx`** (32 sheet).
> Bu dosya Excel'in **durumunu, geçmişini ve açık noktalarını** anlatır; kolon listelerini **tekrarlamaz**.
> **Son güncelleme:** 2026-10-07

---

## 1. Excel'in yapısı

| Sheet | İçerik |
|---|---|
| `00_Surum_Gecmisi` | v1→v4 ne değişti, neden. 🔑 **Her geliştirme yeni sürüm olarak buraya işlenir** |
| `00_Genel_Bakis` | 3 ekran · tablo kategorileri · Id stratejisi · açık karar noktaları |
| `00_Tip_Kurallari` | Ofis tip standardı (PK bigint, para 38,10, oran 18,10, float yasak) |
| `00_Sabitler` | StateId bitmask · ActionId · 29 kod listesi · FrameworkParameter satırları |
| `00_DB_Nesneleri` | Tablo dışı 12 kalem (History+Trigger, DefNumberGen, FlowSet, SP, menü…) |
| `00_Constraint_Index` | PK/UQ/IX/DF adları + "DB zorlayamaz" servis invariant'ları |
| `00_Referans_Kopyalari` | ⚠️ **ARTIK GEÇERSİZ** — bkz §4 |
| `00_Iliskiler` | FK→PK haritası (iç + dış) |
| `00_UML_Diyagram` | Formülle tablo sheet'lerinden beslenen ER diyagramı |
| 20 tablo sheet'i | `Kolon Adı · Tip · Null · Default · Index/Constraint · FK Hedefi · Açıklama` |

---

## 2. Tablolar — 20 iş tablosu

| Grup | Tablolar |
|---|---|
| **Annex (3)** | `Annex` · `AnnexProductScope` · `AnnexMarginRule` |
| **Definition (7)** | `CollateralDefinition` + `…EligibleCurrency` · `…CashTerms` · `…SettlementMap` · `…SecurityRule` · `…SecurityISIN` · `…SecurityTerms` |
| **Transaction (3)** | `TxnTransaction` · `TxnTransactionCash` · `TxnTransactionSecurity` |
| **Destek/audit (6)** | `CollateralRevaluation` · `TxnLimitSnapshot` · `TxnPaymentInstruction` · `TxnMessage` · `TxnMessageEvent` · `CollateralAuditLog` |
| **Bakiye (1)** | `CollateralPosition` — 🔴 opsiyonel değil, eşzamanlı Decrease kontrolü için zorunlu |

### ⚠️ Excel'de sheet'i OLMAYAN ama gereken tablolar
1. **3 History tablosu** — `AnnexHistory` · `CollateralDefinitionHistory` · `TxnTransactionHistory`
   (META satırlarında "ZORUNLU" yazıyor ama kolon listeleri yok). Yapı: parent'ın **tüm** kolonları +
   `HistoryId bigint IDENTITY` PK
2. **45 platform tablosu** — Hangfire (11) · Accounting (3) · Batch (6) · Flow (2) · Framework (2) ·
   işlem yardımcıları (5) · referans (18). Detay: `04-db-envanteri.md` §3

**Gerçek tablo sayısı 20 değil, ~68.**

---

## 3. Id stratejisi

| Tablo tipi | Id | EF config |
|---|---|---|
| `TxnTransaction` (ana işlem) | `bigint`, **IDENTITY DEĞİL** — `DefNumberGen` Ect 1 | `.ValueGeneratedNever()` |
| Diğer tüm Collateral tabloları | `bigint IDENTITY(1,1)` | `.UseIdentityColumn()` |
| `AccEntryMain`/`AccEntry`/`AccEngineGeneratedAccountRule` | `int`, **IDENTITY DEĞİL** — Ect 2/3/4 | `.ValueGeneratedNever()` |
| Referans kopyaları | Common'ın Id'si **taşınır** | `.ValueGeneratedNever()` |

🔴 Üçünden biri EF config'te **açıkça yazılmazsa** insert patlar (bkz `08-tuzaklar.md` A1).

---

## 4. 🔴 `00_Referans_Kopyalari` sheet'i artık geçersiz

Sheet "12 referans tablosu + 12 Kafka handler yaz" diyor. **Yanlış.**
OptionsFX bunları **`CoreDataSlice`** ile paketten alıyor — entity/config/repository/handler **hiç
yazılmıyor** (`Data.Domain` 120 → 30 dosya).

**Doğrusu:** slice listesine 7-8 değer yazılır, gerisi `NetTrex.Core.Data` paketinden gelir.
Tablolar DB'de fiziksel olarak **yine var** — yazılmayan şey **kod**.
Detay: `03-uc-proje-karsilastirma.md` §7.

---

## 5. 🔴 Transcript ile çelişkiler — Excel GÜNCELLENMELİ

Toplantı ses kaydı analizi (2026-10-07) Excel'de **düzeltilmesi gereken** şunları buldu.
İş kararlarında **transcript bağlayıcı** (dokümanın DB bölümü AI üretimi ve analist tarafından
sahiplenilmiyor — bkz `01-is-analizi.md` başı).

### Eklenecek
| # | Ne | Kanıt |
|---|---|---|
| 1 | 🔴 **`TxnTransactionDetail` tablosu** (hareket defteri) — `TxnId` `SeqNo` `TradeDate` `ValueDate` `TransactionType` `Amount` `CurrencyCode` `FxRate` `TransactionValue` `BalanceAfter` **`AccountingReference`** `MessageId` `CreatedBy/Date`. `TxnTransaction` **master** semantiğine çevrilir | transcript 736-763 |
| 2 | 🔴 **`TxnTransaction.Description`/`Memo`** `nvarchar(500)` NULL — SPK_1 istedi, SPK_3 kabul etti. ⚠️ `PaymentInstruction.Instructions` **değil**, açıkça dışlandı | 1226-1251 |
| 3 | **Kur kaynağı** — `FxRateSource` (SYSTEM/MANUAL) veya `IsManualFxRate bit` | 885-893 |
| 4 | `MarginType`'a **`ALL`** (veya "UI 4 satır üretir" notu) | 164 |
| 5 | `SettlementLocationCode` örneklerine **MKK** | 608-610 |
| 6 | `AnnexMarginRule` → `UQ(ProductScopeId, Party, CurrencyCode)` — *"maksimum iki satır"* | 251-255 |
| 7 | `CollateralPosition`'a **base-ccy global balance** ayrımı (veya not) | 293-303, 506-509 |

### Kaldırılacak / faz etiketlenecek
| # | Ne | Kanıt |
|---|---|---|
| 8 | 🔴 `CollateralCashTerms` → **kaldır** veya "FAZ-2 — toplantıda kaldırıldı" | 518-542 |
| 9 | Tüm Security tabloları → **"FAZ-2 / doğrulanmadı"** etiketi | 14-16, 497, 596 |
| 10 | `CollateralRevaluation.SnapshotStage = EOD` → "faz-1'de üretilmez" notu | 1005-1010 |

### Not düşülecek (kolon değişikliği yok)
| # | Kural | Kanıt |
|---|---|---|
| 11 | **Annex yoksa Threshold/MTA/Rounding validasyonu çalışmaz**; Annex varsa UI gösterir, backend karar verir | 650-658 |
| 12 | **Collateral Definition başına en fazla 1 aktif Transaction** | 760-763 |
| 13 | **TradeDate = ValueDate default (T+0)** | 660-661 |
| 14 | `Annex`'te `MasterAgreementText`/`CollateralDocumentText`/`DisputeTolerance*` zorunluluğu (`Null=No`) **sorgulanmalı** — transcript *"çoğu free text alan"* diyor, dispute tolerance hiç konuşulmadı | 153 |

---

## 6. ✅ Transcript ile ÖRTÜŞEN (değişiklik gerekmez)

| Konu | Durum |
|---|---|
| Margin tipleri VM/IM/IA/Other | ✅ |
| Threshold / MTA / Rounding kolonları + `Party` OWN/COUNTERPARTY | ✅ **tam örtüşüyor** |
| `IsIncluded` bit — "FX hariç tüm ürünler" senaryosu | ✅ |
| **Yön semantiği** — INCREASE para bize gelir → `WeReceiveSsiId` zorunlu, `SendPayment` yalnız DECREASE | ✅ **doğru** |
| `CollateralDefinition.AnnexId` nullable (standalone definition) | ✅ |
| `TxnMessage` + `MessageEvent` — Fimple'ın 56 state'ini 5'e indirme talebi | ✅ **tam karşılıyor** |
| Route önce, mesaj tipi sonra (`PaymentRouteCode` + "kullanıcı seçmez") | ✅ doküman+Excel+transcript hizalı |
| `SettlementTypeId` Gross/Netting · `PaymentInstructionTypeId` B2B/A2A/Vostro | ✅ |
| Cash Settlement/Interest panelleri tamamen opsiyonel (Null=Yes) | ✅ |
| Ayrı Margin Call ekranı/tablosu yok | ✅ |
| `EconomicVersion` (reversal/amendment zinciri) | ✅ var — ama tetikleyici alan seti tanımsız |

---

## 7. v4'e kadar verilmiş veri modeli kararları

| # | Karar | Gerekçe |
|---|---|---|
| 1 | Tüm PK'ler **bigint** | ofis kuralı; DerivSwp `int` başlayıp 3 script'le düzeltmek zorunda kaldı |
| 2 | Para `decimal(38,10)` · oran `decimal(18,10)` · **float yasak** | fiziksel DB ölçümü |
| 3 | **CHECK constraint yazılmaz**, FK yalnız referans tablolarına | MM 0 CHECK/14 FK · DerivSwp 0 CHECK/3 FK |
| 4 | Child tablolardan `ValidFrom`/`ValidTo` **kaldırıldı** | iki rakip versiyonlama deseni üst üsteydi; parent revizyonu tek kaynak |
| 5 | `Status` → **`IsEnabled bit`** | `DRAFT≈StateId 16`, `ACTIVE≈18` — %70 tekrardı |
| 6 | `ActiveFlow` kaldırıldı (PaymentInstruction) | `TxnTransaction.TransactionType` ile birebir tekrar |
| 7 | `BusinessKey` kaldırıldı | Fimple/muhasebe faz-1 dışı; gerekçesiz eklenmişti |
| 8 | `CollateralPosition` **zorunlu** | eşzamanlı Decrease için tek deterministik yol (UPDLOCK) |
| 9 | `UETR` **`uniqueidentifier`** | SWIFT'in zorunlu kıldığı gerçek UUID — ev kuralının tek istisnası |
| 10 | `SettlementTypeId`/`PaymentInstructionTypeId` → MM'in **mevcut** tablolarına FK | değer kümeleri örtüşüyor, yeni tablo açılmaz |

---

## 8. İsimlendirme — açık karar

v4'teki adlar MM tarzı (`TxnTransaction`). Kullanıcı **OptionsFX tarzını** istedi.
OptionsFX kuralı: *modülün kendi tablosu jenerik ad alır, miras tablo eski adını korur.*

| v4 | OptionsFX tarzı öneri |
|---|---|
| `Annex` | `Annex` |
| `AnnexProductScope` | `AnnexProductScope` |
| `AnnexMarginRule` | `AnnexMarginRule` |
| `CollateralDefinition` | `CollateralDefinition` |
| `TxnTransaction` | **`TxnTransaction`** (OPTFX + DerivSWP ortak adı) |
| `TxnTransactionCash` / `…Security` | `TxnTransactionCash` / `TxnTransactionSecurity` |
| `CollateralRevaluation` | `CollateralRevaluation` (modül adının kaldığı tek yer) |

⚠️ **Karar verilmedi** — `07-kararlar-ve-sorular.md` A-07.
