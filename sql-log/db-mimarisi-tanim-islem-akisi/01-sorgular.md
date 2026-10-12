# SQL Log — Sorgular — db-mimarisi-tanim-islem-akisi

> Amaç (genel): `DefNumberGen`, `ExternalMM`, `accEngineGeneratedAccountRule`, `txnMMTax`, `txnNote`,
> `Market`, `Currency`, `LogicalReferenceType` tabloları tablo-rehberi.md'de henüz işlenmemiş (§18).
> Her biri için şema EF entity/config'ten zaten çıkarıldı; burada **gerçek veri** ile doğrulanıyor
> (satır var mı, kolonlar gerçekten dolu mu, Id aralığı/prefix deseni).
> Bağlantı: `Code/docker-compose.override.yml` → Server `192.168.10.211`, DB `NetTrexMM`, User `trusr`.

| # | Yazma | Durum |
|---|---|---|
| Toplam yazma sorgusu | **0** | yalnız SELECT |

---

### #1 — `defNumberGen` gerçek içerik + sayaç deseni

Amaç: `TransactionFactory`/`NumberGeneratorDataService`'in hardcode ettiği prefix sözlüğü
(`TransactionMM_Id=55`, `TransactionLoan_Id=120`, `TransactionTawarruq_Id=50`, ...) DB'deki
`LastNumber` değerleriyle tutarlı mı, `EntityColumnType` değerlerinin hepsi satır olarak var mı.

```sql
SET NOCOUNT ON;
SELECT TOP (20) EntityColumnType, LastNumber, Definition, LastUpdateDate
FROM dbo.defNumberGen
ORDER BY LastUpdateDate DESC;
```

### #2 — `ExternalMM` son 20 satır

Amaç: Bloomberg STP ara tablosunun gerçekte neyi tuttuğunu (SyncStatusId dağılımı, Product/TransferStatus
dolu mu) somut veriyle doğrulamak.

```sql
SET NOCOUNT ON;
SELECT TOP (20) Id, LEFT(Message,200) AS Message, Reference, CreatedTime, ExternalReferenceSourceId,
       ResendTime, LEFT(ParsedMessage,200) AS ParsedMessage, SyncStatus, LEFT(SyncMessage,200) AS SyncMessage,
       SyncStatusId, Product, TransferStatus
FROM dbo.ExternalMM
ORDER BY Id DESC;
```

### #3 — `accEngineGeneratedAccountRule` son 20 satır

Amaç: Muhasebe kural motorunun ürettiği satır-bazlı kural izinin (`AccEntry`'nin arkasındaki ham kural
çıktısı) gerçek şeklini görmek — `AccEntryMainId`/`MainId` eşleşmesi, `Source`/`TargetMainGL` dolu mu.

```sql
SET NOCOUNT ON;
SELECT TOP (20) Id, PackageNo, ComponentId, RuleId, GLCode, CustomerCode, CustomerAccountCode,
       CustomerAccountWorkGroupCode, DebitCredit, Amount, TxnNo, TxnRef, ReverseRebook,
       AccountingValueDate, AccountingGenerationDate, Ccy, Fcy, LcyEquivalent, FcyEquivalent,
       Comment, StateDate, MainId, AccAccountMapId, Source, TargetMainGL
FROM dbo.accEngineGeneratedAccountRule
ORDER BY Id DESC;
```

### #4 — `txnMMTax` son 20 satır

Amaç: Vergi (stopaj vb.) satırlarının TxnMM'e nasıl bağlandığını (`PeriodId`, `TaxId`, `Flags`) gerçek
veriyle görmek — kaç işlemde hiç vergi satırı var.

```sql
SET NOCOUNT ON;
SELECT TOP (20) Id, TxnId, PeriodId, TaxId, TaxDate, Amount, TaxRate, Flags, Ccy
FROM dbo.txnMMTax
ORDER BY Id DESC;
```

### #5 — `txnNote` son 20 satır

Amaç: Not/yorum tablosunun gerçek kullanım sıklığı ve `ParentId` (yanıt zinciri) dolu mu.

```sql
SET NOCOUNT ON;
SELECT TOP (20) Id, ParentId, TxnId, Title, LEFT(Description,200) AS Description, StateId, StateMaker, StateDate
FROM dbo.txnNote
ORDER BY Id DESC;
```

### #6 — `Market` tüm satırlar

Amaç: Piyasa tanımlarının sayısı/kapsamı (Consumer'dan Kafka ile mi geldiği, kaç tane olduğu).

```sql
SET NOCOUNT ON;
SELECT TOP (20) Code, Name, CustomerRoleFlags, StateId, StateMaker, StateDate
FROM dbo.Market
ORDER BY StateDate DESC;
```

### #7 — `Currency` son 20 satır

Amaç: Kaç para birimi tanımlı, `BasisCode` FK'si `defDateBasis` ile tutarlı mı, `Disabled`/`IsHard` dağılımı.

```sql
SET NOCOUNT ON;
SELECT TOP (20) Code, Name, IsHard, IsSynthetic, CanUseOnTxn, ForeignCcy, Disabled, Pip, BasisCode,
       Decimals, IsoCode, StateId, StateMaker, StateDate
FROM dbo.Currency
ORDER BY StateDate DESC;
```

### #8 — `LogicalReferenceType` tüm satırlar

Amaç: LR önekleri (`TMM`/`TLN`/...) ile `PrdProductDefinition.LogicalReferenceTypeId` eşleşmesini
doğrulamak.

```sql
SET NOCOUNT ON;
SELECT TOP (20) Id, Name, Code, Description, IsEnabled
FROM dbo.LogicalReferenceType
ORDER BY Id DESC;
```

### #9 — `sp_GetNewNumbers` gövdesi (EXEC yasak, `sys.sql_modules` ile)

Amaç: `DefNumberGen.LastNumber`'ın nasıl arttırıldığını (atomik mi, `UPDATE...OUTPUT` mı) görmek —
Collateral köprüsü için "Id üretimi IDENTITY değil, SP tabanlı" gözlemini doğrulamak.

```sql
SET NOCOUNT ON;
SELECT LEFT(m.definition, 4000) AS Body
FROM sys.sql_modules m
JOIN sys.procedures p ON p.object_id = m.object_id
WHERE p.name = 'sp_GetNewNumbers';
```

### #10 — Revaluation tablo doğrulaması: `LoanRevaluation` satır örneği

Amaç: Kod taramasında `LoanRevaluation` adlı AYRI bir tablo bulundu (InterbankLoan reeskontu için,
`TxnMMDailyCalculation`'dan tamamen farklı/denormalize şema). Gerçekten dolu mu, `TxnMMDailyCalculation`
ile şema farkını canlı veriyle teyit etmek.

```sql
SET NOCOUNT ON;
SELECT TOP (20) Id, TxnId, CalculationDate, GenerationDate, LogicalReference, ProductDefinitionId,
       MarketCode, PrincipalAmount, CurrencyCode, PeriodAccrualAmountSL, PeriodAccrualAmountIRR,
       AccEntryMainId
FROM dbo.LoanRevaluation
ORDER BY Id DESC;
```
