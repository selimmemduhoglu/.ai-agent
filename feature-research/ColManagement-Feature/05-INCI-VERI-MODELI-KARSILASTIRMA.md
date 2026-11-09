# 05 — INCI Veri Modeli ↔ NetTrexColManagement Karşılaştırması

> **Tarih:** 2026-10-21
> **Karşılaştırılan:** `INCI-Treasy_Collateral_Veri_Modeli.xlsx` (v0.1, taslak, 20 sheet) ↔
> `Treasy.ColManagement/.ai-agent/outputs/2026-10-14-ColManagement-Kurulum/1-NetTrexColManagement-DDL.sql`
> (16.10, DB bu script'le kuruldu) + `NetTrex.ColManagement.Data.Domain` entity'leri.
> ⚠️ Canlı DB'ye sorgu atılmadı. Script 16.10'dan sonra elle değiştirildiyse fark burada görünmez.
> Ortak tablolar (Customer, Portfolio) kapsam dışı.

---

## 1. Tablo eşlemesi

| INCI | Bizde | Durum |
|---|---|---|
| `CollateralAgreement` | `Annex` (+`AnnexHistory`) | ✅ aynı kavram |
| `CollateralAgreementProduct` | `AnnexProductScope` | ✅ aynı kavram, bir alanın anlamı farklı (§3.2) |
| `CollateralAgreementRule` | `AnnexMarginRule` | 🔴 **bağlandığı yer farklı** (§3.3) |
| `CollateralDefinition` (tek geniş tablo, `Cash*` önekli kolonlar) | `CollateralDefinition` + `CollateralCashTerms` (1:1) + `CollateralEligibleCurrency` (1:N) | 🟡 aynı bilgi, farklı normalizasyon |
| `CollateralTransaction` | `TxnTransaction` + `TxnTransactionCash` (1:1) | 🔴 **başlığın içeriği farklı** (§3.5) |
| `CollateralTransactionDetail` | `TxnTransactionDetail` | ✅ aynı kavram (K-44) |
| `MarginType` (tablo) | `MarginType` **enum string** (`Vm/Im/Ia/Other`) | 🟡 tablo ↔ enum |
| `RateType` (tablo) | `CollateralCashTerms.RateType` **enum** | 🟡 INCI = MM'in tablosu |
| `FloatingRateType` (tablo) | `FloatingRateType` (tablo, bizde `ChartId` fazla) | ✅ tablo aynı, **bağlanış farklı** (Id ↔ Code) |
| `InterestMethod` (tablo) | `CollateralCashTerms.CompoundingMethod` **enum** | 🟡 INCI = MM'in tablosu |
| `InterestMethodFrequency` (tablo) | `CollateralCashTerms.PaymentFrequency` **enum** | 🟡 INCI = MM'in tablosu |
| `DateBasis` (referans) | `DateBasis` (CoreData kopyası, **var**) ama `CashTerms.DayCount` **enum**, tabloya bağlı değil | 🔴 elimizdeki tabloyu kullanmıyoruz |
| — | `CollateralPosition` (bakiye) | INCI'de **yok** |
| — | `AnnexHistory`, `CollateralDefinitionHistory` | INCI'de **yok** |

🔑 **INCI MM'in ev desenini birebir almış:** `RateType` / `InterestMethod` / `InterestMethodFrequency` /
`FloatingRateType` alanları MM entity'leriyle aynı (`Id, Code, Name, Description, IsEnabled`); işlem
tablosundaki 22 alanlık ödeme/muhabir bloğu MM `TxnLoanEntityBase`'deki blokla **alan alan** aynı, yalnız
başına `Cash` öneki eklenmiş; `Swift…MessageStatus` alanları da MM'de var.

---

## 2. Genel farklar (her tabloyu etkileyenler)

| Konu | INCI | Bizde | Değerlendirme |
|---|---|---|---|
| Akış kolonları | Tam `FlowEntity` (11 kolon: `StateId bigint`, `PreviousState*`, `FlowId`, `LastActionId`, `PreviousActionId`) — **Detail dahil her tabloda** | Annex/Definition/Detail: `StateId int` + `StateMaker/Date` + `Created*` (MakerChecker); yalnız `TxnTransaction` tam FlowEntity | 🟡 Detail'ın onaylanması gerekiyorsa INCI'nin yaptığı gibi Detail'da da flow kolonları lazım (K-44: her hareket ayrı onaylanır mı?) |
| Enum saklama | `int` | `nvarchar` (ad olarak) | Tek bir kural seçilmeli (MM'in tercihi bu çalışmada ölçülmedi) |
| Kod/ad uzunlukları | `Code nvarchar(250)`, `Name nvarchar(1000)`, `MasterAgreement 1000` | `50 / 200 / 500` | INCI'nin değerleri gereksiz büyük |
| Müşteri kolonu adı | `CounterpartyId` | `CustomerId` | Ev deseni `CustomerId` (MM `TxnMM.CustomerId`) — bizimki doğru |
| Versiyonlama | yok (Code tekil bile değil) | `RevisionNo` + `UQ(Code, RevisionNo)` | Bizimki K-53 ile uyumlu |
| FK constraint | İlişkiler sheet'inde 18 FK | DDL'de FK constraint **yok** | Karar gerekiyor |
| History tabloları | yok | Annex, Definition var — 🔴 **`TxnTransactionHistory` bizde de yok** | Bizim açığımız |
| Status | `Draft / Aktif / Pasif` | `IsEnabled bit` | 🔴 INCI **K-50'ye aykırı** — PO: *"Bu draft gereksiz bence... Yapay zeka yapmış"* |

---

## 3. Alan alan eşleme

İşaretler: ✅ aynı · 🟡 ad/tip/uzunluk farkı · 🔴 anlam farkı · ➖ karşılığı yok

### 3.1 `CollateralAgreement` ↔ `Annex`

| INCI | Bizde | |
|---|---|---|
| `Id bigint` | `Id bigint IDENTITY` | ✅ |
| `Code nvarchar(250)` | `AnnexCode nvarchar(50)` | 🟡 |
| `Name nvarchar(1000)` | `AnnexName nvarchar(200)` | 🟡 |
| `CounterpartyId int` | `CustomerId int` | 🟡 ad |
| `Status int` (Draft/Aktif/Pasif) | `IsEnabled bit` | 🔴 K-50 |
| `MasterAgreement nvarchar(1000)` | `MasterAgreement nvarchar(500)` | 🟡 |
| `CollateralDocument nvarchar(1000)` | `CollateralDocument nvarchar(500)` | 🟡 |
| `BaseCurrencyCode` | `BaseCurrencyCode` | ✅ |
| `Direction int` | `Direction nvarchar(20)` | 🟡 enum tipi |
| `ValidFrom` / `ValidTo` | aynı | ✅ |
| `DisputeToleranceAmount` / `…CurrencyCode` | aynı | ✅ |
| ➖ | `RevisionNo` | bizde fazla |
| Flow 11 kolon | MakerChecker 5 kolon | 🟡 |

### 3.2 `CollateralAgreementProduct` ↔ `AnnexProductScope`

| INCI | Bizde | |
|---|---|---|
| `CollateralAgreementId` | `AnnexId` | ✅ |
| `ProductCode` / `SubProductCode` | aynı | ✅ |
| `MarginTypeId int` → `MarginType` tablosu | `MarginType nvarchar(15)` enum | 🟡 |
| `IsActive bit` (default true) | `IsIncluded bit` | 🔴 **anlam farklı:** INCI satırı aç/kapat; bizde "kapsama dahil mi / hariç mi" (doküman: hangi ürünler kapsanır, hangileri **exclude** edilir). INCI'de exclude kavramı yok |

### 3.3 `CollateralAgreementRule` ↔ `AnnexMarginRule` — 🔴 en önemli fark

| | INCI | Bizde |
|---|---|---|
| Bağlandığı yer | **`CollateralAgreementId`** (sözleşme) | **`ProductScopeId`** (ürün kapsamı satırı) |
| Tekillik | `Agreement + PartyType` | `ProductScopeId + Party + CurrencyCode` |
| Sözleşme başına kural | 2 satır (Own + Counterparty) | ürün kapsamı × taraf × döviz |

Alanlar: `PartyType int` ↔ `Party nvarchar(20)` 🟡 · `ThresholdAmount` ✅ · `MinimumTransferAmount` ↔
`MtaAmount` 🟡 ad · `RoundingAmount` ✅ · `RoundingMethodType` ↔ `RoundingMethod` 🟡 · `CurrencyCode` ✅

🔑 **INCI'nin modeli patron toplantısındaki itirazla örtüşüyor:** *"AnnexMarginRule kısmında ProductScope'a
bağlı olması ve buna ihtiyaç olunmasını tam anlayamadılar"* (A-24). INCI kuralı sözleşmeye bağlıyor ve iki
taraf için iki satır tutuyor. Patronun önerdiği "8 kolon"un satır karşılığı bu.
⚠️ INCI'de bir çelişki var: `CurrencyCode` kolonu var ama tekillik `Agreement + PartyType` → sözleşme başına
**tek döviz**. Döviz bazında kural gerekiyorsa tekilliğe `CurrencyCode` eklenmeli.

### 3.4 `CollateralDefinition` ↔ `CollateralDefinition` + `CollateralCashTerms` + `CollateralEligibleCurrency`

| INCI | Bizde | |
|---|---|---|
| `Code 250` / `Name 1000` | `CollateralCode 50` / `CollateralName 200` | 🟡 |
| `CollateralAgreementId` (null) | `AnnexId` (null) | ✅ |
| `CounterpartyId` | `CustomerId` | 🟡 ad |
| `CollateralType int` | `CollateralType nvarchar(12)` | 🟡 |
| `Status int` | `IsEnabled bit` | 🔴 K-50 |
| `SettlementInstrumentType` (AccountTransfer/SecurityTransfer) | ➖ | `CollateralType`'tan türetilebilir (Cash→Account, Security→Security), fazlalık |
| `CashEligibilityDirection` (null) | `EligibilityDirection` (NOT NULL, ana tabloda) | 🟡 |
| `CashEligibilityCurrencies nvarchar(1000)` — `;` ile ayrılmış | `CollateralEligibleCurrency` tablosu (satır başına döviz + `FxAdjustmentRate` + `IsActive`) | 🔴 INCI'de **döviz başına haircut tutulamaz**, sorgulanamaz; bizimki doğru normalizasyon |
| `CashValuationCurrencyCode` | `ValuationCurrencyCode` (ana tablo) | ✅ |
| `CashValidFrom` / `CashValidTo` | `ValidFrom` / `ValidTo` (ana tablo) | ✅ |
| `CashSettlementAccountingMapping` (CurrencyBased/DeskSpecific) | ➖ | ⚠️ K-52 ile settlement/account alanları kaldırılmıştı; bu ikisi muhasebe/SSI **eşleme stratejisi**, kaldırılanlarla aynı şey mi PO'ya sorulmalı |
| `CashInterestAccountingMapping` (CurrencyBased/NoMapping) | ➖ | aynı soru |
| `CashDefaultSSIMapping` (CurrencyBasedSSI/CounterpartyDefaultSSI) | ➖ | aynı soru |
| `CashRateTypeId` → `RateType` | `CashTerms.RateType` enum (Floating/Fixed/InterestFree) | 🟡 |
| `CashFloatingRateTypeId` → `FloatingRateType.Id` | `CashTerms.ReferenceRateCode nvarchar(30)` | 🟡 Id yerine Code; `FloatingRateType` tablosu bizde **zaten var** |
| `CashSpread decimal(18,10)` | `SpreadBps decimal(18,10)` | 🔴 **birim farkı:** INCI oran, biz baz puan |
| `CashFixedRate` | `FixedRate` | ✅ |
| `CashInterestMethodId` → `InterestMethod` | `CompoundingMethod` enum | 🟡 |
| `CashDateBasisCode` → `DateBasis.BasisCode` | `DayCount nvarchar(15)` enum | 🔴 elimizde `DateBasis` referans tablosu var, kullanmıyoruz; INCI doğru |
| `CashPaymentFrequencyId` → `InterestMethodFrequency` | `PaymentFrequency` enum | 🟡 |
| `CashBusinessDayRuleType` | `BusinessDayRule` | ✅ |
| `IsNegativeRateAllowed bit NOT NULL default false` | `bit NULL` | 🟡 |

**Yapı tercihi:** INCI tek geniş tablo + `Cash*` öneki (Security gelince `Sec*` kolonları eklenecek). Bizimki ana
tablo + nakit koşulları ayrı tablo. Faz-1 yalnız Cash (K-54) olduğundan ikisi de çalışır.

### 3.5 `CollateralTransaction` ↔ `TxnTransaction` + `TxnTransactionCash` — 🔴 ikinci önemli fark

| INCI | Bizde | |
|---|---|---|
| `CollateralDefinitionId` | `DefinitionId` | ✅ |
| `CounterpartyId` / `PortfolioId` | `CustomerId` / `PortfolioId` | ✅ |
| `InputDateTime` | `InputDate datetime` | ✅ |
| `Trader` / `BusinessKey` | aynı | ✅ |
| `LogicalReference nvarchar(50)` | `nvarchar(80)` | 🟡 |
| `CollateralAgreementId` | `AnnexId` | ✅ |
| ➖ | `CollateralType`, `TransactionType`, `MarginType`, `TradeDate`, `ValueDate`, `Description`, `AccountingReference` + `TxnTransactionCash` (Amount, Currency, Fx…) | 🔴 bkz. aşağı |
| ➖ | `SourceSystem`, `ExternalReference` (+tekillik) | bizde fazla |
| `CashSendConfirmation/Payment/NoticeToReceive` | `SendConfirmation/SendPayment/SendNoticeToReceive` | ✅ |
| `CashPaymentInstructionTypeId` / `CashSettlementTypeId` | `PaymentInstructionTypeId` / `SettlementTypeId` | ✅ |
| `CashInstructions 1000` | `Instructions 500` | 🟡 |
| `CashSwiftConfirmationMessageStatus` · `CashSwiftPaymentMessageStatus` · `CashDomesticPaymentMessageStatus` | ➖ | 🔴 MM'de var. A-26'daki "ödeme mesajı gönderildi" bilgisi **tam bu alanlar** |
| 22 muhabir/ödeme muhasebe alanı (`CashOutgoingCorrespondentId`, `…AccountNumber`, `…GLCode`, `…PaymentAccountingType/GLType/GL`, aynısı Incoming, `TheirBeneficiary*`, `TheirSender*`) | 4 SSI Id'si (`WeSendSsiId`, `TheyReceiveSsiId`, `WeReceiveSsiId`, `TheySendSsiId`) | 🔴 bizimkiler **olmayan bir SSI master tablosuna** işaret ediyor (A-18). INCI MM'deki gibi **snapshot** tutuyor — Fimple'a ödeme/muhasebe giderken ev deseni bu |

🔑 **Başlık–detay ayrımı:** INCI'de başlıkta **hiç hareket alanı yok** (tutar, tip, tarih yok); hepsi Detail'da.
Bu K-44'ün (*"ana Txn hiç değişmeyecek, her işlem TxnDetail'da değişecek"*) en sade karşılığı. Bizde ilk
hareket başlıkta (`TransactionType`, `MarginType`, tarihler + `TxnTransactionCash`) **ve** Detail'ın ilk
satırında duruyor → iki kopya, **ayrışma riski**.

### 3.6 `CollateralTransactionDetail` ↔ `TxnTransactionDetail`

| INCI | Bizde | |
|---|---|---|
| `TransactionId` | `TxnId` | ✅ |
| `TransactionType int` | `nvarchar(12)` | 🟡 |
| `MarginTypeId` (detail seviyesinde) | ➖ (yalnız başlıkta) | 🔴 INCI'de her hareketin kendi margin tipi var |
| `TradeDate` / `ValueDate` | aynı | ✅ |
| `CurrentBalance` (tek alan, "öncesi/sonrası" belirsiz) | `CurrentBalanceBefore` + `CurrentBalanceAfter` | ✅ bizimki daha net |
| `ValuationCurrencyCode` | aynı | ✅ |
| `CashAmount` / `CashCurrencyCode` | `Amount` / `CurrencyCode` | ✅ |
| `CashMinimumAmount` | ➖ | ? anlamı belirsiz (MTA kuraldan gelir) |
| `CashFXRate` | `FxRate` | ✅ |
| `CashFXAdjustment` (**tutar**) | `FxAdjustmentRate` (**oran**) | 🔴 anlam farkı |
| `CashTransactionAmount` | `TransactionValue` | ✅ |
| `CashAdjustmentEligibleAmount` | `AdjustedEligibleValue` | ✅ |
| `IsFxConversionRequired` | aynı | ✅ |
| ➖ | `DetailVersion`, `FxRateSource`, `Description`, `AccountingReference` | bizde fazla |
| Ödeme/muhabir blokları (başlıktakinin aynısı) | SSI Id'leri + bayraklar | §3.5 ile aynı fark |
| Tam FlowEntity | MakerChecker | §2 |
| `Cash*` tutarlar **NULL** | **NOT NULL** | INCI Security için boş bırakıyor; bizde Cash-only (K-54) |

### 3.7 Parametre tabloları

| INCI tablosu | MM'de var mı | Bizde |
|---|---|---|
| `MarginType` (Id, Code, Name, Description, IsActive) + seed VM/IM/IA/Other | yok | enum |
| `RateType` | ✅ birebir | enum |
| `FloatingRateType` | ✅ birebir | tablo var (`+ChartId`) |
| `InterestMethod` | ✅ birebir | enum |
| `InterestMethodFrequency` | ✅ birebir | enum |
| `DateBasis` | ✅ CoreData | tablo var, kullanılmıyor |

---

## 4. Sonuç

**Aynı mantıkta mı?** Evet, iskelet aynı: sözleşme → kapsam + kural → teminat tanımı → işlem başlığı →
işlem detayı. 6 iş tablosunun 6'sının bizde karşılığı var. Farklar dört grupta toplanıyor:

### INCI'nin daha iyi olduğu yerler (bize alınması önerilir)
1. **Margin kuralı sözleşmeye bağlı** (§3.3) — patronun itirazıyla örtüşüyor, A-24'ü kapatır. Döviz bazlı kural gerekiyorsa tekilliğe `CurrencyCode` eklenmeli.
2. **Başlıkta hareket alanı yok** (§3.5) — K-44'ü yapısal olarak garanti eder; bizdeki başlık/Detail çift kopyasını kaldırır.
3. **Ödeme/muhabir alanları MM gibi snapshot + mesaj durum alanları** (§3.5) — var olmayan SSI master'ına bağımlılığı (A-18) kaldırır, Fimple ödeme akışının ev deseni. A-26'nın cevabı `…MessageStatus` alanları.
4. **Faiz parametreleri MM'in tablolarıyla** (`RateType`, `InterestMethod`, `InterestMethodFrequency`, `DateBasis`, `FloatingRateType` Id'si) — elimizdeki `DateBasis` ve `FloatingRateType` tablolarını zaten kullanmıyoruz.
5. **Detail'da `MarginTypeId`** — her hareketin kendi margin tipi.

### Bizim daha iyi olduğumuz yerler (INCI'ye dönülmemeli)
1. **Kabul edilen dövizler ayrı tablo** (`CollateralEligibleCurrency`) — INCI `;` ile tek alana yazıyor; döviz başına haircut tutulamıyor.
2. **`CurrentBalanceBefore/After`** + **`CollateralPosition`** — INCI'de bakiye tablosu yok; eşzamanlı Decrease'te bakiyeyi korumak için gerekli.
3. **Versiyonlama + History** (`RevisionNo`, `AnnexHistory`, `CollateralDefinitionHistory`) — INCI'de yok.
4. **`CustomerId`** adı ve **makul uzunluklar** — ev deseni.
5. **`IsEnabled`** — K-50 (Draft yok) ile uyumlu; INCI'deki `Draft` PO kararına aykırı.
6. **`IsIncluded`** — doküman "hariç tutma"yı istiyor; INCI'nin `IsActive`'i bunu karşılamıyor.

### İkisinde de çözülmesi gerekenler
1. **Detail'ın onay akışı:** INCI her Detail'a tam flow koyuyor, bizde MakerChecker-lite. Her hareket ayrı onaylanacaksa Detail'a flow kolonları gerekir.
2. **Enum saklama tipi** (`int` mi `nvarchar` mı) — tek kural.
3. **FK constraint** konulacak mı — INCI 18 FK tanımlıyor, bizim DDL'de yok.
4. **`TxnTransactionHistory`** bizde yok.
5. **Anlam farkları netleşmeli:** `CashSpread` (oran mı bps mi) · `CashFXAdjustment` (tutar mı oran mı) · `CashMinimumAmount` ne · `Cash*AccountingMapping` / `CashDefaultSSIMapping` K-52'de kaldırılanlarla aynı şey mi.

### INCI Excel'inin kendi içindeki hatalar
- İlişkiler ve UML sheet'lerinde FK adı **`CollateralAggrementId`** (yazım hatası), tablo sheet'inde `CollateralAgreementId`.
- `CollateralAgreementRule`'da `CurrencyCode` var ama tekillik onu içermiyor (§3.3).
- `Status = Draft` K-50'ye aykırı.
- `CurrentBalance` tek alan, açıklaması "öncesi / sonrası" — hangisi olduğu belirsiz.
- Kapak sayfası doldurulmamış (hazırlayan, tarih, müşteri yer tutucu).

---

## 5. Uygulama durumu (2026-10-21)

| §4 "INCI daha iyi" | Durum |
|---|---|
| 1. Margin kuralı sözleşmeye bağlı | ✅ `AnnexMarginRule.AnnexId`, tekillik `(AnnexId, Party, CurrencyCode)` |
| 2. Başlıkta hareket yok | ⏸ Ertelendi — Create/Verify/muhasebe/position/UI akışı baştan kurulmalı, tasarım soruları kullanıcıda |
| 3. Ödeme snapshot + mesaj durumu | ✅ MM `TxnLoan` 22 muhabir alanı + `TxnMM` 3 `*MessageStatus`, SSI Id'leri silindi |
| 4. Faiz parametre tabloları | ✅ `RateType`/`InterestMethod`/`InterestMethodFrequency` açıldı + `FloatingRateType` seed; CashTerms Id/kod kolonları |
| 5. Detail `MarginType` | ✅ `nvarchar(15)` enum string (bizim saklama kuralı; INCI `MarginTypeId`) |

"Bizim daha iyi" listesinin tamamı korundu. Detay → [`progress/28`](progress/28-inci-model-uyarlama.md).
