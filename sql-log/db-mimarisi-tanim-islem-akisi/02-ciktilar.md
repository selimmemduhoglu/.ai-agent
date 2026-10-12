# SQL Log — Çıktılar — db-mimarisi-tanim-islem-akisi

### #1 — `defNumberGen`

```
EntityColumnType|LastNumber|Definition|LastUpdateDate
3|12674|Account Entry|2026-10-01 09:03:38.130
2|6133|Acc Entry Main Id|2026-10-01 09:03:38.097
4|8166|Generated Account|2026-09-30 17:38:03.103
1|3410|Txn Mm Id|2026-09-30 17:37:24.347
7|1052|Txn Tawarruq Id|2026-09-24 14:13:41.467
8|1168|Txn Loan Id|2026-09-15 17:38:46.097
6|1032|Product Definition Market Map Id|2025-12-17 14:41:13.653
5|999|Product Definition Id|2025-03-23 17:46:00.133
```
Yorum: **8 satır, 8 `EntityColumnType` değerinin hepsi var** (`None=0` hariç — o kullanılmıyor).
`TransactionMM_Id`(1)=3410, `TransactionLoan_Id`(8)=1168, `AccountingEntry_Id`(3)=12674,
`AccountingEntryMain_Id`(2)=6133, `GeneratedAccountingEntry_Id`(4)=8166 — hepsi `NumberGeneratorDataService`
içindeki hardcode prefix sözlüğüyle eşleşiyor. `ProductDefinition_Id`(5) ve
`ProductDefinitionMarket_Id`(6) sözlükte **YOK** ama tabloda satırları var — bu ikisi yalnız
`GetNewNumbersAsync` (prefix'siz) ile çağrılıyor, `GetNewNumbersWithPrefixAsync` ile çağrılırsa
`DataServiceException` fırlatır.

### #2 — `ExternalMM`

Yorum: **174 satıra kadar veri var** (en yeni Id=174). Ham çıktı `Message` kolonunun içinde gerçek
newline karakterleri olduğu için tablo görünümü satır satır bozuluyor — **kırpıldı**, yalnız özet:
`ExternalReferenceSourceId=130` (Bloomberg) ağırlıklı, `Product=1/2`, `TransferStatus=0`,
`SyncStatusId` 1 (Error) ve 2 (Success) karışık, `SyncMessage` dolu örnekleri: *"Connection refused
(localhost:5050)"*, *"An error occurred while sending the request."* — STP'nin retry mekanizmasının
gerçekte tetiklendiğinin kanıtı. `ParsedMessage` örneği: `{"CustomerId":2095,"ProductId":1,
"PortfolioId":1,"BasisCode":"2","DaysInYear":360,"TxnTypeCode":"BRW","MarketCode":"OTC","Ccy":"TRY",
"Trader":"FATMA.YILDIRIM@INVEST..."}` — yani normalize edilmiş dahili create-request payload'ı.

### #3 — `accEngineGeneratedAccountRule`

```
Id|PackageNo|ComponentId|RuleId|GLCode|CustomerCode|CustomerAccountCode|DebitCredit|Amount|TxnNo|TxnRef|Source|TargetMainGL
558166|0|15586|33391|32801000|27253|346488|Credit|50000000.00|553410|TMRBRW2609300010|CounterPartyGLAccount|NULL
558165|0|15586|33390|39200840|NULL|NULL|Debit|50000000.00|553410|TMRBRW2609300010|IncomingPaymentLCY|392
558158|0|15568|33340|36099200|27253|346484|Credit|88.53|553400|TMMBRW2609280003|AccruedExpense|NULL
558157|0|15568|33339|62600000|27253|346484|Debit|88.53|553400|TMMBRW2609280003|InterestExpense|NULL
... (20 satır, `TxnRef`/`GLCode`/`DebitCredit`/`Amount` değerleri `AccEntry` ile birebir örtüşüyor)
```
Yorum: Satırlar **`AccEntry` ile aynı ekonomik içeriği** taşıyor (`GLCode`, `DebitCredit`, `Amount`,
`Source`, `TargetMainGL`). Kod okumasıyla doğrulandı (`AccountingDataManager.InsertAsync`):
`accEntryEntities[i].EngineId = acgRuleIds[i]` ve `accountingGeneratedRuleEntities[i].Id = acgRuleIds[i]`
— **aynı Id** iki tabloya da yazılıyor. Yani bu tablo `AccEntry`'nin **1:1 ham motor izi**'dir
(`ComponentId`/`RuleId`/`PackageNo` gibi muhasebe kural motoruna özgü alanlar taşır), `AccEntry` ise
ledger'a giden normalize satırdır.

### #4 — `txnMMTax`

```
Id|TxnId|PeriodId|TaxId|TaxDate|Amount|TaxRate|Flags|Ccy
110|553398|1|3|2026-09-30|5.48|0.01|0|TRY
99|552875|1|3|2025-11-20|117.74|0.01|0|USD
```
Yorum: **110 satır var**, tamamı `TaxId=3`, `TaxRate=0.01` (**%1 stopaj**, ölçüldü — tek tip vergi
kodu kullanılıyor), `PeriodId` hep `1`. `TxnMM` işlemlerinin küçük bir alt kümesinde (yalnız
`ProductDefinition.IsTaxApplicable=1` olanlarda) üretiliyor — `TaxDataManager.InsertAsync` tek
metotlu, `IsExists` kontrolü **yok**.

### #5 — `txnNote`

```
Id|ParentId|TxnId|Title|Description|StateId|StateMaker|StateDate
32|NULL|1201103|Note|Note eklendi|18|INCI|2026-04-28
31|0|1201024|sd|asda|18|SELIM2@INVESTMENTBANK.COM|2026-04-14
```
Yorum: **32 satıra kadar** — düşük kullanım. `ParentId` bazen `NULL` bazen `0` (tutarsız, ikisi de
"kök not" anlamına geliyor gibi — tekil bir "kök" sentinel'i yok). `StateId` **hepsi `18`**
(Input, onaysız — not özelliği maker-checker akışına hiç girmemiş, hep "Input" kalmış).
`TxnId` hem MM hem Loan referanslarına karışık işaret ediyor (`TxnNoteEntity.LoanTransaction`
navigation'ı ayrı ama FK kolonu ortak — ayrım yok, tabloda hangi kaynağa ait olduğu **içerik
dışından anlaşılmıyor**).

### #6 — `Market`

```
Code|Name|CustomerRoleFlags|StateId|StateMaker|StateDate
OTC|Over the Counter|0|18|system|1753-01-01
INB|Interbank market|16|18|system|1753-01-01
COR|Corporate|6|18|system|1753-01-01
BIST|Istanbul Exchange|0|18|system|1753-01-01
AUC|Auction|16|18|system|1753-01-01
TVSB|TAKASBANK-TPP|16|18|System|2024-05-07
ISE|Istanbul Exchange|0|22|HAZINEBIR@...|2024-06-10
VIOP|VIOP|1|26|HAZINEIKI@...|2024-07-25
TCMB|Türkiye Cumhuriyet Merkez Bankasi|3|26|PARTNER.TREASY.002@...|2026-09-11
TAKAS|Takasbank|3|26|PARTNER.TREASY.002@...|2026-09-11
TEST|TEST|16|22|PARTNER.TREASY.006@...|2026-09-18
TEST23|TEST233|1|26|PARTNER.TREASY.005@...|2026-09-21
```
Yorum: **12 satır (toplam)** — `TOP(20)` tüm tabloyu kapsıyor. 5 sistem satırı (`1753-01-01` =
.NET/SQL "min date" seed deseni, `StateMaker='system'`) + gerçek borsalar (`ISE`/`VIOP`/`TCMB`/`TAKAS`)
+ 2 test satırı. `CustomerRoleFlags` bitmask (`Market` bazında hangi müşteri rolü işlem açabilir).

### #7 — `Currency`

```
Code|Name|IsHard|Disabled|BasisCode|Decimals|IsoCode|StateId
USD|US Dolar|1|0|2|2|840|18
TRY|Türk Lirasi|1|0|1|5|223|26
XAU|Altin|1|1|1|2|NULL|26
C70|2.5 Gramlik|1|0|SPOT|4|C70|18
```
Yorum: Para birimi listesi yalnızca ISO 4217 değil — **kıymetli maden/emtia "para birimleri"**
(`C70`/`C75`/`C80`/`C87`/`A10`/`XAU`/`GMS`/`SLM`) `Currency` tablosunda yaşıyor. ⚠️ **Veri kalitesi:**
`C70` satırının `BasisCode='SPOT'` — `defDateBasis` tablosunda böyle bir kod **yok** (geçerli kodlar
`1/2/3/4/6/TRY`, bkz. tablo-rehberi §12); FK ihlali DB seviyesinde **önlenmiyor olmalı** ya da
`defDateBasis`'e sonradan `SPOT` eklenmiş — doğrulanmadı. `IsoCode` bazı satırlarda sayısal ISO kodu
(`"840"`), bazılarında metin kısaltması (`"AED"`), bazılarında `NULL` — tutarsız.

### #8 — `LogicalReferenceType`

```
Id|Name|Code|Description|IsEnabled
1|Money Market|MM|NULL|1
2|Issue|IS|NULL|1
3|Interbank Loan|LN|NULL|1
4|Wakala|WA|NULL|1
5|Murabaha|MR|NULL|1
6|Term Deposit|TD|NULL|1
7|Syndication|SY|NULL|1
8|Securitization|SZ|NULL|1
9|Post-Financing|PF|NULL|1
```
Yorum: **9 satır, hepsi `IsEnabled=1`**. `Code` = LogicalReference'ın T'den sonraki ilk harfleri
değil — gerçek LR üretimi `ReferenceGeneratorDataService.GetNewReference(productCode, directionCode, ...)`
ile `T{productCode}{directionCode}{yyMMdd}{sayaç}` formatında (örn. `TMMBRW260928...`,
`TMRBRW260930...` — `MR`=Murabaha/Tawarruq, `MM`=MoneyMarket, `LN`=Loan, kod bu akışta **ürün kodu**
olarak kullanılıyor, `LogicalReferenceType.Code` ekranda görünmüyor, yalnız referans üretiminde dolaylı
kullanılıyor — `PrdProductDefinition.LogicalReferenceTypeId` → `LogicalReferenceType.Code` okunup LR
string'ine gömülüyor).

### #9 — `sp_GetNewNumbers` gövdesi

```sql
CREATE PROCEDURE [dbo].[sp_GetNewNumbers] @EntityColumnType int, @CountToGenerate int
AS
BEGIN
    SET NOCOUNT ON;
    IF @EntityColumnType IS NULL OR @CountToGenerate IS NULL OR @CountToGenerate <= 0
        RAISERROR(...);
    DECLARE @new_last_no int;
    UPDATE dbo.defNumberGen WITH (ROWLOCK, UPDLOCK)
    SET @new_last_no = LastNumber = LastNumber + @CountToGenerate, LastUpdateDate = GETDATE()
    WHERE EntityColumnType = @EntityColumnType;
    IF @@ROWCOUNT = 0 RAISERROR('Unknown Number Generation EntityColumnType: ...', 16, 1);
    DECLARE @start_no int = @new_last_no - @CountToGenerate + 1;
    -- @start_no..@new_last_no arası ardışık sayı dizisi recursive CTE ile üretilip SELECT edilir
END
```
Yorum: **IDENTITY değil, satır-bazlı sayaç + `ROWLOCK/UPDLOCK` ile atomik `UPDATE...SET x=x+n`**
deseni. Tek satırda N adet ID tek seferde (`@CountToGenerate`) rezerve edilebiliyor (toplu insert
senaryosu — yük testi script'lerinin dayandığı mekanizma budur). `EntityColumnType` tabloda yoksa
(`@@ROWCOUNT=0`) hata fırlatıyor — bu yüzden #1'deki 8 satırın **tamamı** önceden seed edilmiş olmalı.

### #10 — `LoanRevaluation`

```
Id|TxnId|CalculationDate|GenerationDate|LogicalReference|ProductDefinitionId|MarketCode|PrincipalAmount|CurrencyCode|PeriodAccrualAmountSL|PeriodAccrualAmountIRR|AccEntryMainId
208|1201155|2026-06-18|2026-06-23|TLNBRW2606230003|2|OTC|60000.00|TRY|355.07|355.07|555481
200|1201136|2026-06-12|2026-06-12|TLNBRW2606120006|2|NULL|1000000.00|TRY|1345.29|612723.02|555443
```
Yorum: **Ayrı ve dolu bir tablo** — `TxnMMDailyCalculation`'dan tamamen farklı şema: tek satırda
**işlemin o günkü TÜM statik alanları da kopyalanmış** (`ProductDefinitionId`, `MarketCode`,
`PrincipalAmount`, `RateTypeId`, `PaymentFrequencyId`, dönem/NPV alanları — bkz. kod okuması).
`TxnMMDailyCalculation` ise yalnız (`TxnMmId`, `CalculationDate`, `AccrualDay`, `AccrualAmount`,
`AccEntryMainId`) gibi ince bir tahakkuk satırı — asıl işlem verisini `Transaction` navigation'ı ile
**join** ederek okuyor (`GetForReportAsync` `.Include(x => x.Transaction)`).
🔴 **`PeriodAccrualAmountIRR` bazı satırlarda `AccrualAmountSL`'den onlarca kat büyük** (Id=200:
355→612723) — muhtemelen IRR (iç verim) hesabının NPV bileşenini de içermesi; bu doküman kapsamında
daha fazla kazılmadı, yalnız veri şekli not edildi.
