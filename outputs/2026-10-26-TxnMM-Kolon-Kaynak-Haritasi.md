# TxnMM kolonları — ekran alanı / sunucu kaynağı haritası (2026-10-26)

Ekran: MM "Borrowing and Placement" popup'ı (`Treasy.MM.UI` `mm-transaction/popups/form.ts`; Web.UI muadili `paymentComponent.js`).
Örnek satır: `TMMPLC2610260009` (TxnMM `553447`). Kod yolu: UI → `TransactionCreateModel` (`TransactionBaseModel`) → `TransactionCreateCommand`
(Mapster, ad eşleşmesi; yeniden adlandırılanlar: `DirectionCode→TxnTypeCode`, `ProductId→TxnMmProductTypeId`, `CurrencyCode→Ccy`)
→ `TransactionFactory.CreateAsync` (sunucu alanları) → insert. Verify'da `MmOpeningAccountingPersister` birkaç kolonu günceller.

Doğrulama düzeyi: **[K]** kodda okundu · **[Ç]** çıkarım · **[?]** bulunamadı/doğrulanmadı.

## 1. Ana form alanları

| TxnMM kolonu | Ekran alanı | Not |
|---|---|---|
| `CustomerId` | **Counterparty** | Müşteri tablosu Id'si (Fimple `ExternalCustomerId` değil; o ayrı gider) [K] |
| `TxnMmProductTypeId` | **Product Type** | `ProductId` olarak gider [K] |
| `TxnTypeCode` | **Direction** (BRW/PLC) | `DirectionCode` [K] |
| `PortfolioId` | **Portfolio** | [K] |
| `MarketCode` | **Market** | OTC vb. [K] |
| `Ccy` | **Currency** | `CurrencyCode` [K] |
| `BasisCode` | **Date Basis** (ACT/365 …) | örnekte `1` [K] |
| `DaysInYear` | **Days in Year** | [K] |
| `PaymentType` | **Payment Type** (salt okunur, "Single") | [K] |
| `InputDate` | **Input Date** (salt okunur) | formda mantıksal tarih basılır [K] |
| `TradeDate` / `ValueDate` / `MaturityDate` | **Trade / Value / Maturity Date** | [K] |
| `DealAmount` | **Amount** | [K] |
| `MaturityAmount` | **Maturity Amount** | profit ↔ maturity karşılıklı hesap (form.ts:100) [K] |
| `Instructions` | **Instructions** (metin kutusu) | [K] |
| — | **Rate**, **Interest Amount**, **Day Count** | `TxnMM`'de **kolonu yok**; CashFlow/`TxnMMDetail` satırlarına yazılır (`CashFlow` listesi) [K] |
| `FundSourceId`, `SubFundSourceCode` | Fund Source seçimi (ürün `UseFundSource=1` ise görünür) | MoneyMarket ürününde 0 → örnekte `NULL` [Ç] |
| `CollateralType` | formda görünmüyor | örnekte `0` [?] |
| `SecurityId` | bu ekranda yok | menkul bağlantılı akış, `NULL` [?] |
| `CustomerIsFinancialInstitution` | seçilen Counterparty'nin tipi (FI mı kurumsal mı) | UI state `counterpartyType`; kurumsalda payment bloğu değişir [K/Ç] |

## 2. Sunucunun yazdıkları (ekranda karşılığı yok) — `TransactionFactory.cs`

| Kolon | Nasıl |
|---|---|
| `Id` | `DefNumberGen` sayacı (`TransactionMM_Id`) [K] |
| `BusinessKey` | `IBusinessKeyGenerator` (request'ten gelse de `.Ignore`) [K] |
| `LogicalReference` | `IReferenceGeneratorDataService` — ürün + `TxnTypeCode` (örn. `TMMPLC…`) [K] |
| `TermId` | `ITermRepository.GetTermIdByDayCount(ValueDate, MaturityDate)` (SHORT/LONG) [K] |
| `CustomerLocation` | müşterinin rol bayrağı `& 32 == 32` ise `FRGN`, değilse `DOM` [K] |
| `Trader` | `CreatedBy` → yoksa `StateMaker` → yoksa `SYSTEM` (ekrandaki **Trader** salt okunur, aynı kullanıcı) [K] |
| `Incoming/OutgoingPaymentAccountingType`, `…GLType` | framework parametresi (`Helper.Get…Async`); `SettlementTypeId==2` ve `CashAcc` ise **ikisi de `TempAcc`** yapılır [K] |
| `StateId`, `StateMaker`, `StateDate`, `CreatedBy`, `CreatedDate`, `PreviousState*`, `FlowId`, `LastActionId`, `PreviousActionId` | `entity.UpdateStates(...)` / Flow altyapısı [K] |
| `TransactionOriginType` | rollover handler'da `Generated`; normal kayıtta varsayılan [K] |
| `LinkedTransaction*`, `RolloverTypeId` | rollover / bağlı işlem akışı; normal Create'te `NULL` [K/Ç] |
| `ExternalReference`, `ExternalReferenceSourceId` | yalnız dış sistem (Eximbank) booking ucu; ekrandan gelmez [K] |
| `IsMatured` | vade işlemi (batch); Create'te `0` [Ç] |
| `Swift/…MessageStatus` (3 kolon) | Create/Verify yolunda **yazan kod bulunamadı** [?] |

## 3. Verify'da yazılanlar — `MmOpeningAccountingPersister` → `TDMUpdateForOpeningModel`

| Kolon | Kaynak |
|---|---|
| `AccountNumber`, `GLCode` | Fimple `OpenAccount` sonucu (`CreateAccountResult`); örnekte `346532` / `32801000` — ürün `IsAccountNeeded=1` ise [K] |
| `OutgoingPaymentAccountingGL`, `IncomingPaymentAccountingGL` | muhasebe motorunun ürettiği bacaklardan `Source` içinde `OutgoingPayment/IncomingPayment` olanın **GL'i** (`PaymentClearingGL`); örnekte `3929900011` [K] |
| `StateId/…/FlowId`, `BusinessKey` | akış + Fimple'dan dönen `BusinessKey` [K] |

## 4. Payment Instructions bloğu

Ortak (tipten bağımsız):

| TxnMM kolonu | Ekran alanı |
|---|---|
| `SettlementTypeId` | **Settlement Type** (1 Gross / 2 Net) |
| `PaymentInstructionTypeId` | **Payment Instr. Type** (1 B2B / 2 A2A / 3 Vostro) |
| `SendConfirmation` / `SendPayment` / `SendNoticeToReceive` | üç **onay kutusu** |
| `Instructions` | **Instructions** |

Onay kutuları (`paymentComponent.js:116-146`): **Net** → hepsi `false` + pasif; **Gross + B2B** → Send Payment ve Notice **açık**; **A2A / Vostro** → Send Payment ve Notice `false` + pasif.

Muhabir alanları (her biri bir **satır seçimidir**; seçilen grid satırının alanları kolonlara kopyalanır — `getPayload`, `paymentComponent.js:719-755`):

| Ekran | Kolon ← grid satırı alanı |
|---|---|
| **We Send** | `OutgoingCorrespondentId` ← `CustomerId` · `…AccountNumber` ← `AccountNumber` · `…AccountGLCode` ← `AccountGLCode` |
| **We Receive** | `IncomingCorrespondentId/AccountNumber/AccountGLCode` ← aynı üç alan |
| **They Send** | `TheirSenderCorrespondentId` ← `FinancialInstitutionCustomerId` · `…Name` ← `BankName` · `…SwiftCode` ← `SwiftCode` · `…AccountNumber` ← `AccountNumber` · `…GLCode` ← `AccountGLCode` |
| **They Receive** | `TheirBeneficiaryCorrespondent…` ← aynı beş alan |

Listelerin içeriği: Fimple `GetOurCorrespondentBanks` (We Send/Receive) ve `GetTheirCorrespondentBanks` (They Send/Receive); her liste **seçilen talimat tipinin `ExternalCode`'una göre süzülür**
(`BankToBank` / `AccountToAccountNostro` / `AccountToAccountVostro`), ilk `IsDefault` satır otomatik seçilir.

### Tip matrisi

| | **B2B** (Id 1, `BankToBank`) | **A2A = Nostro** (Id 2) | **Vostro** (Id 3, Excel'de "V2V") |
|---|---|---|---|
| We Send / We Receive (`Outgoing*`, `Incoming*`) | **zorunlu**, dolu | **zorunlu**, dolu; liste ayrıca **karşı tarafın kendi `ExternalCustomerId`'sine** süzülür (nostro hesabımız karşı bankanın yanında, `paymentComponent.js:417-423`) | doğrulama **kapalı** → `NULL` |
| They Send / They Receive (`TheirSender*`, `TheirBeneficiary*`) | **zorunlu** (UI); sunucu validator'ı Id+Ad+SWIFT ister; AccountNumber/GL dolu **olabilir** (satırdan gelir) ama sunucu zorunlu tutmaz | doğrulama **kapalı** → `NULL` | **zorunlu**; sunucu **AccountNumber + GLCode** da ister (`validator:94-102`) |
| Muhasebe map'inin okuduğu | `Outgoing/Incoming…` | `Outgoing/Incoming…` | `TheirBeneficiary…` / `TheirSender…` |
| Send Payment / Notice | Gross'ta açık | kapalı | kapalı |

Örnek (`TMMPLC2610260009`, B2B): `Outgoing/IncomingCorrespondentId=27207`, `AccountNumber=90766`, `GLCode=02200000`;
`TheirSender/Beneficiary` Id=`27106` (karşı bankanın kendisi), Ad=`Osman TRY`, SWIFT=`W21321ASDFF`, AccountNumber=IBAN (`TR46…`), GL=`NULL`.

## 5. Kurumsal (FI olmayan) müşteri

Payment bloğu yerine `form.ts:398-416` → `customerSetDataForUpdate`: `CorporateCurrentAccountNumber`, `CorporateCurrentAccountGLCode`, `CorporateCurrentAccountWorkGroupId`
(sunucu validator: üçü de zorunlu, `TransactionCreateRequestValidator.cs:105-110`). FI müşteride `NULL`. Bu ekran görüntüsünde (FI akışı) bu alanlar yok.

## 6. Doğrulanmayanlar

- `CollateralType`, `SecurityId`, `FundSourceId` için ekran alanı birebir bağlama satırı okunmadı.
- `Swift/…MessageStatus` kolonlarını kim yazıyor — MM Create/Verify yolunda yok.
- `IsMatured` TxnMM için hangi akışta `1` oluyor (kodda yalnız TxnLoan yolu görüldü, `TransactionLoanDataManager.cs:283`).
- Kurumsal müşteride `Outgoing/Incoming…ExternalCustomerWorkGroupId` map alanının dolduğu yer (açılışta `null` geçiyor).
