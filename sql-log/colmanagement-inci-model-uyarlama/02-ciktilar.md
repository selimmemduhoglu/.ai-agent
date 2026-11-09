# 02 — Ciktilar (colmanagement-inci-model-uyarlama)

## #1 — NetTrexMM
```text
name|create_date
----|-----------
DefCorporateType|2024-07-17 14:55:58.227
DefDateBasis|2020-08-28 16:00:55.167
FloatingRateType|2026-04-09 09:43:24.573
InterestMethod|2026-04-09 09:43:24.690
InterestMethodFrequency|2026-04-09 09:43:24.717
RateType|2026-04-09 09:43:24.613
```

## #2 — NetTrexMM
```text
Tbl|column_id|name|type|max_length|precision|scale|is_nullable|is_identity|Def|DfName
---|---------|----|----|----------|---------|-----|-----------|-----------|---|------
FloatingRateType|1|Id|int|4|10|0|0|0|NULL|NULL
FloatingRateType|2|Code|nvarchar|100|0|0|0|0|NULL|NULL
FloatingRateType|3|Name|nvarchar|100|0|0|1|0|NULL|NULL
FloatingRateType|4|Description|nvarchar|200|0|0|1|0|NULL|NULL
FloatingRateType|5|IsEnabled|bit|1|1|0|1|0|NULL|NULL
FloatingRateType|6|Currency|nvarchar|200|0|0|0|0|NULL|NULL
FloatingRateType|7|PointId|int|4|10|0|0|0|NULL|NULL
FloatingRateType|8|ChartId|int|4|10|0|1|0|NULL|NULL
InterestMethod|1|Id|int|4|10|0|0|0|NULL|NULL
InterestMethod|2|Code|nvarchar|100|0|0|0|0|NULL|NULL
InterestMethod|3|Name|nvarchar|100|0|0|0|0|NULL|NULL
InterestMethod|4|Description|nvarchar|200|0|0|1|0|NULL|NULL
InterestMethod|5|IsEnabled|bit|1|1|0|0|0|NULL|NULL
InterestMethodFrequency|1|Id|int|4|10|0|0|0|NULL|NULL
InterestMethodFrequency|2|Code|nvarchar|100|0|0|0|0|NULL|NULL
InterestMethodFrequency|3|Name|nvarchar|100|0|0|0|0|NULL|NULL
InterestMethodFrequency|4|Description|nvarchar|200|0|0|1|0|NULL|NULL
InterestMethodFrequency|5|IsEnabled|bit|1|1|0|0|0|NULL|NULL
RateType|1|Id|int|4|10|0|0|0|NULL|NULL
RateType|2|Code|nvarchar|100|0|0|1|0|NULL|NULL
RateType|3|Name|nvarchar|100|0|0|1|0|NULL|NULL
RateType|4|Description|nvarchar|200|0|0|1|0|NULL|NULL
RateType|5|IsEnabled|bit|1|1|0|1|0|NULL|NULL
```

## #3 — NetTrexMM
```text
T|Id|Code|Name|Description|IsEnabled
-|--|----|----|-----------|---------
InterestMethod|2|CompoundAverage|CompoundAverage|CashFlow hesaplamalari compound olarak hesaplanir|1
InterestMethod|1|SimpleInterest|SimpleInterest|CashFlow hesaplamalari linear olarak hesaplanir|1
InterestMethodFrequency|6|Daily|Daily|Daily|1
InterestMethodFrequency|5|Weekly|Weekly|Weekly|1
InterestMethodFrequency|4|Monthly|Monthly|Monthly|1
InterestMethodFrequency|3|Quarterly|Quarterly|Quarterly|1
InterestMethodFrequency|2|Semi-Annual|Semi-Annual|Semi-Annual|1
InterestMethodFrequency|1|Annual|Annual|Annual|1
RateType|2|Floating|Floating|Floating Rate|1
RateType|1|Fixed|Fixed|Fixed Rate|1
```

## #4 — NetTrexMM
```text
Id|Code|Name|Description|IsEnabled|Currency|PointId|ChartId
--|----|----|-----------|---------|--------|-------|-------
15|EUR ESTR12M|EUR ESTR12M|ESTR 12M Rate|1|EUR|319|0
14|EUR ESTR6M|EUR ESTR6M|ESTR 6M Rate|1|EUR|29|0
13|EUR ESTR3M|EUR ESTR3M|ESTR 3M Rate|1|EUR|26|0
12|EUR ESTR1M|EUR ESTR1M|ESTR 1M Rate|1|EUR|24|0
11|EUR ESTRON|EUR ESTRON|ESTR ON Rate|1|EUR|21|0
10|TRY TLREF12M|TRY TLREF12M|TLREF 12M Rate|1|TRY|318|0
9|TRY TLREF6M|TRY TLREF6M|TLREF 6M Rate|1|TRY|286|0
8|TRY TLREF3M|TRY TLREF3M|TLREF 3M Rate|1|TRY|283|0
7|TRY TLREF1M|TRY TLREF1M|TLREF 1M Rate|1|TRY|281|0
6|TRY TLREFON|TRY TLREFON|TLREF ON Rate|1|TRY|278|0
5|USD SOFR12M|USD SOFR12M|SOFR 12M Rate|1|USD|319|0
4|USD SOFR6M|USD SOFR6M|SOFR 6M Rate|1|USD|29|0
3|USD SOFR3M|USD SOFR3M|SOFR 3M Rate|1|USD|26|0
2|USD SOFR1M|USD SOFR1M|SOFR 1M Rate|1|USD|24|0
1|USD SOFRON|USD SOFRON|SOFR ON Rate|1|USD|21|0
```

## #5 — NetTrexColManagement
```text
T|N
-|-
Annex|0
AnnexProductScope|0
AnnexMarginRule|0
CollateralDefinition|0
CollateralCashTerms|0
TxnTransaction|0
TxnTransactionCash|0
TxnTransactionDetail|0
CollateralPosition|0
FloatingRateType|0
DateBasis|0
AccEntryMain|0
```

## #6 — NetTrexMM
```text
BasisCode|BasisName|NumberOfDays|Denominator|StateId
---------|---------|------------|-----------|-------
1|ACT / 365|1|365|26
12|Typescript Test|213|1|18
2|ACT / 360|111|360|26
3|ACT / ACT|0|365|18
4|30/360|30|360|18
6|ACT/364|0|364|18
TRY|TRY 360|365|365|22
TST|TST|233|1321|18
```

## #7 — NetTrexColManagement
```text
name|type|max_length|is_nullable
----|----|----------|-----------
BasisCode|nvarchar|8|0
BasisName|nvarchar|160|1
NumberOfDays|smallint|2|1
Denominator|smallint|2|1
StateId|int|4|0
StateMaker|nvarchar|160|1
StateDate|datetime|8|0
```

## #8 — NetTrexMM
```text
column_id|name|type|max_length|is_nullable
---------|----|----|----------|-----------
30|Instructions|nvarchar|2000|1
36|PaymentInstructionTypeId|int|4|1
37|SettlementTypeId|int|4|1
38|IncomingCorrespondentId|int|4|1
39|IncomingCorrespondentAccountNumber|bigint|8|1
40|IncomingCorrespondentAccountGLCode|nvarchar|20|1
41|IncomingPaymentAccountingType|nvarchar|100|1
42|IncomingPaymentAccountingGLType|nvarchar|100|1
43|IncomingPaymentAccountingGL|nvarchar|20|1
44|OutgoingCorrespondentId|int|4|1
45|OutgoingCorrespondentAccountNumber|bigint|8|1
46|OutgoingCorrespondentAccountGLCode|nvarchar|20|1
47|OutgoingPaymentAccountingType|nvarchar|100|1
48|OutgoingPaymentAccountingGLType|nvarchar|100|1
49|OutgoingPaymentAccountingGL|nvarchar|20|1
50|TheirBeneficiaryCorrespondentName|nvarchar|1000|1
51|TheirBeneficiaryCorrespondentSwiftCode|nvarchar|100|1
52|TheirBeneficiaryCorrespondentAccountNumber|nvarchar|1000|1
53|TheirBeneficiaryCorrespondentId|int|4|1
54|TheirBeneficiaryCorrespondentGLCode|nvarchar|20|1
55|TheirSenderCorrespondentName|nvarchar|1000|1
56|TheirSenderCorrespondentSwiftCode|nvarchar|100|1
57|TheirSenderCorrespondentAccountNumber|nvarchar|1000|1
58|TheirSenderCorrespondentId|int|4|1
59|TheirSenderCorrespondentGLCode|nvarchar|20|1
60|SendConfirmation|bit|1|0
61|SendPayment|bit|1|0
62|SendNoticeToReceive|bit|1|0
```

## #9 — NetTrexMM
```text
Tbl|name|type|max_length|is_nullable
---|----|----|----------|-----------
TxnMM|DomesticPaymentMessageStatus|nvarchar|100|1
TxnMM|SwiftConfirmationMessageStatus|nvarchar|100|1
TxnMM|SwiftPaymentMessageStatus|nvarchar|100|1
```

## #10 — NetTrexColManagement
```text
name|type_desc|base_object_name
----|---------|----------------
PortfolioInstrument|USER_TABLE|NULL
Portfolio|USER_TABLE|NULL
PK_PortfolioInstrument|PRIMARY_KEY_CONSTRAINT|NULL
PK_Portfolio|PRIMARY_KEY_CONSTRAINT|NULL
PK_MarketCustomerMap|PRIMARY_KEY_CONSTRAINT|NULL
PK_Customer|PRIMARY_KEY_CONSTRAINT|NULL
PK_CurrencyPair|PRIMARY_KEY_CONSTRAINT|NULL
PK_Currency|PRIMARY_KEY_CONSTRAINT|NULL
PK_CollateralEligibleCurrency|PRIMARY_KEY_CONSTRAINT|NULL
MarketCustomerMap|USER_TABLE|NULL
DF_MarketCustomerMap_ModuleFlags|DEFAULT_CONSTRAINT|NULL
DF_Currency_Pip|DEFAULT_CONSTRAINT|NULL
Customer|USER_TABLE|NULL
CurrencyPair|USER_TABLE|NULL
Currency|USER_TABLE|NULL
CollateralEligibleCurrency|USER_TABLE|NULL

(16 rows affected)
```

## #11 — NetTrexColManagement
```text
T|StateId|Cnt
-|-------|---

(0 rows affected)
```

## #12 — NetTrexMM
```text
Msg 208, Level 16, State 1, Server srv-mssql, Line 1
Invalid object name 'Customer'.
```

## #13 — NetTrexMM
```text
name|type_desc|base_object_name
----|---------|----------------
PrfPortfolio|USER_TABLE|NULL
CusCustomer|USER_TABLE|NULL
Currency|USER_TABLE|NULL

(3 rows affected)
```

## #14 — NetTrexMM
```text
T|Cnt
-|---
PrfPortfolio|29
CusCustomer|111
Currency|56

(3 rows affected)
```

## #15 — NetTrexColManagement
```text
TABLE_NAME|Cols
----------|----
Portfolio|Id:int:NO, Code:nvarchar:NO, Name:nvarchar:YES, ParentId:int:YES, AccountingMethod:int:YES, LocalCcy:nvarchar:YES, CountryCode:nvarchar:YES, InventoryTypeId:int:YES, LegalVehicleId:int:YES, FunctionalCcy:nvarchar:YES, Type:int:NO, Path:nvarchar:YES, Accoun
Customer|Id:int:NO, ShortName:nvarchar:YES, Name:nvarchar:YES, Ccy:nvarchar:YES, BranchId:int:YES, SIC:nvarchar:YES, BusinessSegmentCode:nvarchar:YES, ActiveFromDate:datetime:YES, ActiveToDate:datetime:YES, Language:int:YES, Attention:nvarchar:YES, AccountOfficer:n
Currency|Code:nvarchar:NO, Name:nvarchar:NO, IsHard:bit:YES, IsSynthetic:bit:YES, CanUseOnTxn:bit:YES, ForeignCcy:bit:YES, Disabled:bit:YES, Pip:decimal:NO, BasisCode:nvarchar:NO, StateId:int:NO, StateMaker:nvarchar:NO, StateDate:datetime:NO, Decimals:smallint:YES,

(3 rows affected)
```

## #16 — NetTrexMM
```text
TABLE_NAME|Cols
----------|----
PrfPortfolio|Id:int, Code:nvarchar, Name:nvarchar, ParentId:int, AccountingMethod:int, LocalCcy:nvarchar, CountryCode:nvarchar, InventoryTypeId:int, LegalVehicleId:int, FunctionalCcy:nvarchar, Type:int, Path:nvarchar, StateId:int, StateMaker:nvarchar, StateDate:datetim
CusCustomer|Id:int, ShortName:nvarchar, Name:nvarchar, Ccy:nvarchar, BranchId:int, SIC:nvarchar, BusinessSegmentCode:nvarchar, CustomerRoleFlags:int, ActiveFromDate:datetime, ActiveToDate:datetime, Language:int, Attention:nvarchar, AccountOfficer:nvarchar, Address:nva
Currency|Code:nvarchar, Name:nvarchar, IsHard:bit, IsSynthetic:bit, CanUseOnTxn:bit, ForeignCcy:bit, Disabled:bit, Pip:decimal, BasisCode:nvarchar, StateId:int, StateMaker:nvarchar, StateDate:datetime, Decimals:smallint, IsoCode:nvarchar

(3 rows affected)
```

## #17 — NetTrexColManagement
```text
Msg 468, Level 16, State 9, Server srv-mssql, Line 1
Cannot resolve the collation conflict between "Turkish_CI_AS" and "SQL_Latin1_General_CP1254_CI_AS" in the equal to operation.
```

## #18 — NetTrexColManagement
```text
TABLE_NAME|COLUMN_NAME|IS_NULLABLE|COLUMN_DEFAULT
----------|-----------|-----------|--------------
Portfolio|Module|YES|NULL
Customer|TakasMemberCode|YES|NULL

(2 rows affected)
```

## #19 — NetTrexColManagement
```text
Tbl|name|DstType|DstLen|DstNull|SrcType|SrcLen|SrcNull
---|----|-------|------|-------|-------|------|-------
Portfolio|StateMaker|nvarchar|160|0|nvarchar|160|1
Customer|StateMaker|nvarchar|160|0|nvarchar|160|1
Currency|StateId|int|4|0|int|4|1
Currency|StateMaker|nvarchar|160|0|nvarchar|160|1
Currency|StateDate|datetime|8|0|datetime|8|1

(5 rows affected)
```

## #20 — NetTrexColManagement
```text
name|Child|Parent
----|-----|------

(0 rows affected)
```

## #21 — NetTrexMM
```text
T|NullMaker|NullState|NullDate
-|---------|---------|--------
PrfPortfolio|0|0|0
CusCustomer|0|0|0
Currency|0|0|0

(3 rows affected)
```

## #22 — NetTrexMM
```text
TABLE_NAME|COLUMN_NAME|DATA_TYPE|IS_NULLABLE
----------|-----------|---------|-----------
TxnMM|CreatedBy|nvarchar|NO
TxnMM|CreatedDate|datetime|NO
TxnMM|FlowId|bigint|NO
TxnMM|InputDate|datetime|NO
TxnMM|LastActionId|bigint|NO
TxnMM|LinkedTransactionId|bigint|YES
TxnMM|LinkedTransactionReasonType|int|YES
TxnMM|LinkedTransactionReference|nvarchar|YES
TxnMM|LinkedTransactionTrader|nvarchar|YES
TxnMM|PreviousActionId|bigint|YES
TxnMM|PreviousStateDate|datetime|YES
TxnMM|PreviousStateId|bigint|YES
TxnMM|PreviousStateMaker|nvarchar|YES
TxnMM|StateDate|datetime|NO
TxnMM|StateId|bigint|NO
TxnMM|StateMaker|nvarchar|NO
TxnMM|Trader|nvarchar|NO
TxnMM|TransactionOriginType|int|NO
TxnLoan|CreatedBy|nvarchar|NO
TxnLoan|CreatedDate|datetime|NO

(20 rows affected)
```

## #23 — NetTrexMM
```text
TABLE_NAME|COLUMN_NAME|DATA_TYPE|IS_NULLABLE
----------|-----------|---------|-----------
PrdProductDefinition|StateDate|datetime|NO
PrdProductDefinition|StateId|int|NO
PrdProductDefinition|StateMaker|nvarchar|YES

(3 rows affected)
```

## #24 — NetTrexColManagement
```text
TABLE_NAME|COLUMN_NAME|DATA_TYPE|IS_NULLABLE
----------|-----------|---------|-----------
TxnTransaction|CreatedBy|nvarchar|NO
TxnTransaction|CreatedDate|datetime|NO
TxnTransaction|FlowId|bigint|NO
TxnTransaction|InputDate|datetime|NO
TxnTransaction|LastActionId|bigint|NO
TxnTransaction|PreviousActionId|bigint|YES
TxnTransaction|PreviousStateDate|datetime|YES
TxnTransaction|PreviousStateId|bigint|YES
TxnTransaction|PreviousStateMaker|nvarchar|YES
TxnTransaction|StateDate|datetime|NO
TxnTransaction|StateId|bigint|NO
TxnTransaction|StateMaker|nvarchar|NO
TxnTransaction|Trader|nvarchar|NO
TxnTransaction|TransactionType|nvarchar|NO
CollateralDefinition|CreatedBy|nvarchar|NO
CollateralDefinition|CreatedDate|datetime|NO
CollateralDefinition|StateDate|datetime|NO
CollateralDefinition|StateId|int|NO
CollateralDefinition|StateMaker|nvarchar|NO
Annex|CreatedBy|nvarchar|NO
Annex|CreatedDate|datetime|NO
Annex|StateDate|datetime|NO
Annex|StateId|int|NO
Annex|StateMaker|nvarchar|NO

(24 rows affected)
```

## #25 — NetTrexColManagement
```text
CurrencyCode|Year|Gun
------------|----|---

(0 rows affected)
```

## #26 — NetTrexMM
```text
CurrencyCode|Year|Gun
------------|----|---
A05|2090|363
AED|2077|260
TRY|2075|364
ETB|2061|363
ARA|2060|363
CAD|2050|363
CAD|2036|365
CHF|2036|365
NOK|2036|365
USD|2036|365
GBP|2036|365
CNH|2036|365
TRY|2036|360
RUB|2036|365
EUR|2036|365
DKK|2036|365
JPY|2036|365
SEK|2036|365
SAR|2036|365
EUR|2035|365

(20 rows affected)
```

## #27 — NetTrexColManagement
```text
Tablo|MmSatir
-----|-------
TxnSync|382
TxnNoteHistory|22
TxnNote|30
TxnDocumentHistory|13
TxnDocument|13
SettlementType|2
Point|112
PaymentInstructionType|4
MarketCustomerMap|11
Market|13
InterestRateDetail|371127
InterestRate|4548
Holiday|2810
HalfWorkingDay|2
FXRateDetail|154799
FXRate|5327
FlowTransitionData|4769
DefRefNumGen|409
DefNumberGen|8
CurrencyPair|90
Chart|77
Calendar|160770
BatchSet|5
BatchLogDetail|41770
BatchLog|1697
BatchItem|35
AccEntryMain|5114
AccEntry|11569
AccEngineGeneratedAccountRule|7141

(29 rows affected)
```

## #28 — NetTrexColManagement
```text
Db|name
--|----
MM|DefDateBasis
CM|DateBasis

(2 rows affected)
```

## #29 — NetTrexColManagement
```text
Dst|Kolon|Sorun
---|-----|-----
SettlementType|Name|HEDEF KISA
SettlementType|ExternalCode|NULL->NOT NULL
Portfolio|StateMaker|NULL->NOT NULL
Point|StateId|NULL->NOT NULL
Point|StateMaker|NULL->NOT NULL
Point|StateDate|NULL->NOT NULL
PaymentInstructionType|Name|HEDEF KISA
MarketCustomerMap|StateMaker|NULL->NOT NULL
Market|Name|NULL->NOT NULL
Market|StateMaker|NULL->NOT NULL
Holiday|Date|TIP FARKLI
HalfWorkingDay|HalfWorkingDate|TIP FARKLI
Customer|StateMaker|NULL->NOT NULL
CurrencyPair|IsCalculatedPair|NULL->NOT NULL
CurrencyPair|OrderNo|NULL->NOT NULL
CurrencyPair|IsPM|NULL->NOT NULL
CurrencyPair|StateId|NULL->NOT NULL
CurrencyPair|StateMaker|NULL->NOT NULL
CurrencyPair|StateDate|NULL->NOT NULL
Currency|StateId|NULL->NOT NULL
Currency|StateMaker|NULL->NOT NULL
Currency|StateDate|NULL->NOT NULL
Chart|StateId|NULL->NOT NULL
Chart|StateMaker|NULL->NOT NULL
Chart|StateDate|NULL->NOT NULL
Calendar|Year|NULL->NOT NULL
Calendar|DayOfYear|NULL->NOT NULL

(27 rows affected)
```

## #30 — NetTrexMM
```text
K|Sorunlu
-|-------
SettlementType.Name max|16
SettlementType.ExternalCode|0
Point.State*|0
PaymentInstructionType.Name max|27
MarketCustomerMap.StateMaker|0
Market.Name/StateMaker|0
CurrencyPair.*|0
Chart.State*|0
Calendar.Year/DayOfYear|0

(9 rows affected)
```

## #31 — NetTrexColManagement
```text
T|name|max_length
-|----|----------
SettlementType|Name|100
PaymentInstructionType|Name|100

(2 rows affected)
```

## #32 — NetTrexColManagement
```text
Id|CollateralCode|Ccy|Cash
--|--------------|---|----
40|TST-DEF-2-S20|1|1
39|TST-DEF-2-S19|4|1
38|TST-DEF-2-S18|3|1
37|TST-DEF-2-S17|2|1
36|TST-DEF-2-S16|1|1
35|TST-DEF-2-S15|4|1
34|TST-DEF-2-S14|3|1
33|TST-DEF-2-S13|2|1
32|TST-DEF-2-S12|1|1
31|TST-DEF-2-S11|4|1
30|TST-DEF-2-A10|3|1
29|TST-DEF-2-A09|2|1
28|TST-DEF-2-A08|1|1
27|TST-DEF-2-A07|4|1
26|TST-DEF-2-A06|3|1
25|TST-DEF-2-A05|2|1
24|TST-DEF-2-A04|1|1
23|TST-DEF-2-A03|4|1
22|TST-DEF-2-A02|3|1
21|TST-DEF-2-A01|2|1

(20 rows affected)
```

## #33 — NetTrexColManagement
```text
CollateralCode|StateId|Ccy|Cash|Fixed
--------------|-------|---|----|-----
TST-DEF-3-S20|18|1|1|NULL
TST-DEF-3-S19|18|4|1|NULL
TST-DEF-3-S18|18|3|1|3.4567890000
TST-DEF-3-S17|18|2|1|NULL
TST-DEF-3-S16|18|1|1|NULL
TST-DEF-3-S15|18|4|1|3.4567890000
TST-DEF-3-S14|18|3|1|NULL
TST-DEF-3-S13|18|2|1|NULL
TST-DEF-3-S12|18|1|1|3.4567890000
TST-DEF-3-S11|18|4|1|NULL
TST-DEF-3-A10|18|3|1|NULL
TST-DEF-3-A09|18|2|1|3.4567890000
TST-DEF-3-A08|18|1|1|NULL
TST-DEF-3-A07|18|4|1|NULL
TST-DEF-3-A06|18|3|1|3.4567890000
TST-DEF-3-A05|18|2|1|NULL
TST-DEF-3-A04|18|1|1|NULL
TST-DEF-3-A03|26|1|1|1.2345670000
TST-DEF-3-A02|26|1|1|1.2345670000
TST-DEF-3-A01|26|1|1|1.2345670000

(20 rows affected)
```

## #34 — NetTrexColManagement
```text
TABLE_NAME|COLUMN_NAME
----------|-----------
TxnTransaction|AnnexId
TxnTransaction|DefinitionId
CollateralPosition|DefinitionId
CollateralEligibleCurrency|DefinitionId
CollateralDefinitionHistory|AnnexId
CollateralDefinitionHistory|CollateralCode
CollateralDefinition|AnnexId
CollateralDefinition|CollateralCode
CollateralCashTerms|DefinitionId
AnnexProductScope|AnnexId
AnnexMarginRule|AnnexId
AnnexHistory|AnnexCode
Annex|AnnexCode

(13 rows affected)
```

## #35 — NetTrexColManagement
```text
T|C
-|-
TxnKullanan|0
Definition|60
Annex|30

(3 rows affected)
```
