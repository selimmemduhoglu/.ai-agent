# Faz 2 — Excel v5 (DB şeması kesinleşti)

**Tarih:** 2026-10-07
**Çıktı:** `repos/.ai-agent/feature-research/ColManagement-Feature/2026-10-07-Collateral-DB-Sema-v5.xlsx` (32 sheet)
**Önceki:** `2026-10-04-...-v4.xlsx` (29 sheet) — **silinmedi**, yerinde duruyor

---

## Yöntem

v4 sıfırdan yeniden üretilmedi, **dönüştürüldü**: kullanıcının 6 Ekim'de kendi eklediği
`00_UML_Diyagram` sheet'i, `UQ1`/`UQ2`/`UQ3` composite notasyonu ve temizlediği satırlar korunsun diye.

| Adım | Ne yapıldı |
|---|---|
| 1 | 63 formül **statikleştirildi** — sheet adları değiştiği için referansları kırılacaktı (değerler korundu) |
| 2 | 20 adlandırma kuralı **tüm hücre metinlerine** uygulandı → 433 hücre (constraint adları da otomatik düzeldi: `PK_TxnCollateral` → `PK_TxnTransaction`) |
| 3 | 19 sheet yeniden adlandırıldı, her birinin `B1`'ine *"v4 adı: X"* notu düşüldü |
| 4 | Yeni kolon/sheet'ler eklendi, `00_Referans_Kopyalari` kaldırıldı |

⚠️ **Sıra kritikti:** `DefCollateralAnnexProductScope` → `DefCollateralAnnex` → `DefCollateral`.
Kısa olan önce uygulansaydı `DefCollateralAnnex` → `CollateralDefinitionAnnex` olurdu.

⚠️ **ExcelJS tuzağı:** `cell.value.formula` kontrolü **yetmiyor** — paylaşılan formüllerde
(`sharedFormula`) master hücre değiştirilince kayıt sırasında
`Shared Formula master must exist above and or left of clone` hatası alınıyor. İkisi birden kontrol edilmeli.

---

## Yapılan değişiklikler

### 1. İsimlendirme — ev konvansiyonu

OptionsFX kuralı: **modülün kendi tablosu jenerik ad alır, miras alınan tablo eski adını korur.**
DB adı zaten `NetTrexCollateral` — her tabloya "Collateral" yazmak tekrar.

| v4 | v5 |
|---|---|
| `TxnCollateral` | **`TxnTransaction`** |
| `TxnCollateralCash` / `…Security` | `TxnTransactionCash` / `TxnTransactionSecurity` |
| `DefCollateralAnnex` (+ProductScope/MarginRule) | `Annex` · `AnnexProductScope` · `AnnexMarginRule` |
| `DefCollateral` | `CollateralDefinition` |
| `DefCollateralEligibleCurrency` / `CashTerms` / `SettlementMap` / `Security*` | `Collateral…` (Def öneki düştü) |
| `TxnCollateralValuation` | `CollateralRevaluation` |
| `TxnCollateralPosition` | `CollateralPosition` |
| `TxnCollateralLimit` | `TxnLimitSnapshot` |
| `TxnCollateralPaymentInstruction` | `TxnPaymentInstruction` |
| `TxnCollateralMessage` / `…Event` | `TxnMessage` / `TxnMessageEvent` |

**İki alt kural:**
- **1:1 alt tipler** `TxnTransaction*` — işlemin kendisinin tipli parçası
- **1:N yardımcılar** `Txn*` — ev deseni `TxnNote`/`TxnSync`/`TxnCashFlow`.
  Ayrıca `TxnTransactionPaymentInstruction` **32 karakter**, Excel sheet adı sınırı **31**.
- `CollateralRevaluation` modül adının kaldığı **tek** yer — `OptionsFXRevaluation`/`DerivativesRevaluation` emsali.

### 2. Ses kaydından gelen kolonlar

| Tablo | Kolon | Neden |
|---|---|---|
| `TxnTransaction` | `Description nvarchar(500) NULL` | Operasyon notu. 🔑 `TxnPaymentInstruction.Instructions` **değil** — o mesaja giden ödeme talimatı |
| `TxnTransaction` | `AccountingReference nvarchar(50) NULL` + IX | Muhasebe fişi/iş numarası. Mutabakatta *"bu hareketin fişi hangisi"* sorusunun tek cevabı |
| `TxnTransactionCash` | `FxRateSource nvarchar(20) NOT NULL DEFAULT('SYSTEM')` | SYSTEM/MANUAL. Yalnız `FxRate` tutulursa *"bu kuru sistem mi verdi kullanıcı mı"* sonradan cevaplanamaz |
| `CollateralSettlementMap` | `SettlementLocationCode` örneklerine **MKK** | Menkul saklama tarafı |
| `AnnexMarginRule` | `UQ (ProductScopeId, Party, CurrencyCode)` | Bir kapsam + taraf + döviz için tek kural satırı |

### 3. Yeni tablo — `ProductDefinition`

`CollateralDefinition` ile **karıştırılmaması** gereken ayrı bir şey:

| | `CollateralDefinition` | `ProductDefinition` |
|---|---|---|
| Ne | Kullanıcının girdiği **iş** verisi | Modülün **platform** konfigürasyonu |
| İçerik | Hangi müşteriyle hangi varlık teminat kabul edilir | `ExternalMainProductCode` · `PortfolioRootPath` · `AccountingMapCode` |
| Satır sayısı | Yüzlerce | **2** (CASH, SECURITY) |

🔴 `Id` **IDENTITY** — `DefNumberGen` değil. MM'deki sayaç **ölçüldü**: `LastNumber 999` ama gerçek
Id'ler `1..11` ve Create handler'ın sayaç çağrısı yorum satırında → sayaç **ölü**. v3'te bunu emsal
alıp yanlış karar vermiştim, v4'te düzeltilmişti.

### 4. Yeni/kaldırılan sheet'ler

| Sheet | Durum |
|---|---|
| `ProductDefinition` | 🆕 |
| `00_History_Tablolari` | 🆕 — 4 History tablosu + trigger kuralları. Ayrı sheet açılmadı çünkü mekanikler: parent'ın tüm kolonları + `HistoryId bigint IDENTITY` |
| `00_CoreDataSlice` | 🆕 — referans verisinin paketten geldiği, **kod yazılmadığı** |
| `00_Platform_Tablolari` | 🆕 — Flow · DefNumberGen · muhasebe fişi · Hangfire + modülün platformda tanındığı 4 yer |
| `00_Referans_Kopyalari` | 🔴 **KALDIRILDI** — *"12 referans tablosu + handler yaz"* diyordu; `CoreDataSlice` ile tek satır kod yazılmıyor |
| `00_Sabitler` | E/F/G bölümleri eklendi (v5 kod listeleri · `DefNumberGen`+`EntityColumnType` seed · logical date tuzağı) |

---

## Kapanan kararlar

`A-01` transaction modeli (hareket başına satır) · `A-02` ana tablo adı · `A-03` CashTerms kalır ·
`A-04` Security faz-1'de · `A-05` ProductDefinition olacak · `A-06` MarginType ALL eklenmez ·
`A-07` tablo ailesi adlandırması → `bilgi-bankasi/07-kararlar-ve-sorular.md` `K-18`…`K-25`

🔴 **`MarginType = ALL` enum'a EKLENMEDİ:** UI "All" seçilince **4 ayrı satır** yazar.
`ALL` enum'a girseydi her sorgu `= @x OR = 'ALL'` yazmak zorunda kalırdı ve bir yerde unutulurdu —
unutulan yer **sessizce eksik sonuç** döndürür, hata vermez.

## Açık kalanlar

`A-08` sayaç öneki (iki haneli olmalı) · `A-09` modül kodu (`CL`?) · `A-10` DB adı ·
`A-11` `CoreDataSlice` üye listesi (`D-01`) · **`A-21` 🆕** Annex'in `ProductCode`/`SubProductCode`
hangi katalogdan — `ProductDefinition` **değil**, teminatlandırılan işlem FX/Repo/IR olabilir.

➡️ **Faz 3 (DB kurulum script'leri) bu cevaplar olmadan başlayamaz** — sayaç öneki ve modül kodu
script'in içine gömülüyor.
