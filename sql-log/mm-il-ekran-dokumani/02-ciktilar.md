# 02-ciktilar ‚Äî mm-il-ekran-dokumani

## #1
```
name
----
AccEngineGeneratedAccountRule
AccountingCalculationMethodType
AmortizationConfiguration
AmortizationConfigurationHistory
AmortizationType
Calendar
Chart
DefAmortization
DefCorporateDetailType
DefCorporateType
DefDateBasis
FloatingRateType
FlowType
FXRate
FXRateDetail
Holiday
InterestMethod
InterestMethodFrequency
InterestRate
InterestRateDetail
PaymentFrequency
PaymentInstructionType
RateSource
RateType
SettlementType
TaxRate
```

## #2
```
Msg 207, Level 16, State 1, Server srv-mssql, Line 10
Invalid column name 'Id'.
```

## #3
```
Id|Code|Name|Description|IsEnabled
--|----|----|-----------|---------
2|Floating|Floating|Floating Rate|1
1|Fixed|Fixed|Fixed Rate|1
Id|Code|Name|Description|IsEnabled|Month|Period
--|----|----|-----------|---------|-----|------
4|Monthly|Monthly|Monthly|1|1|12
3|Quarterly|Quarterly|Quarterly|1|3|4
2|Semi-Annual|Semi-Annual|Semi-Annual|1|6|2
1|Annual|Annual|Annual|1|12|1
Id|Code|Name|Description|IsEnabled
--|----|----|-----------|---------
2|CompoundAverage|CompoundAverage|CashFlow hesaplamalari compound olarak hesaplanir|1
1|SimpleInterest|SimpleInterest|CashFlow hesaplamalari linear olarak hesaplanir|1
Id|Code|Name|Description|IsEnabled
--|----|----|-----------|---------
6|Daily|Daily|Daily|1
5|Weekly|Weekly|Weekly|1
4|Monthly|Monthly|Monthly|1
3|Quarterly|Quarterly|Quarterly|1
2|Semi-Annual|Semi-Annual|Semi-Annual|1
1|Annual|Annual|Annual|1
Id|Name|Code|Description|IsEnabled
--|----|----|-----------|---------
1|Linear|Linear|Simple Linear|1
Id|Code|Name|Description|IsEnabled
--|----|----|-----------|---------
3|Fee|Fee|Fee|1
2|Interest|Interest|Interest|1
1|Principal|Principal|Principal|1
Id|Code|Name|Description|ExternalCode|IsEnabled
--|----|----|-----------|------------|---------
2|Netting|Net Settlement|NULL|Bulk|1
1|Gross|Gross Settlement|NULL|Single|1
Id|Code|Name|Description|ExternalCode|IsEnabled|IsFinancialInstitutionCompatible
--|----|----|-----------|------------|---------|--------------------------------
4|A2AD|Customer Account to Account|NULL|AccountToAccountDeposit|1|0
3|Vostro|Vostro Account|NULL|AccountToAccountVostro|1|1
2|A2A|Account to Account|NULL|AccountToAccountNostro|1|1
1|B2B|Bank to Bank|NULL|BankToBank|1|1
BasisCode|BasisName|NumberOfDays|Denominator|StateId|StateMaker|StateDate
---------|---------|------------|-----------|-------|----------|---------
TST|TST|233|1321|18|PARTNER.TREASY.006@INVESTMENTBANK.COM|2026-09-18 17:15:59.820
TRY|TRY 360|365|365|22|PARTNER_NETIX_001@INVESTMENTBANK.COM|2025-06-25 12:07:23.497
6|ACT/364|0|364|18|PARTNER_NETIX_002@INVESTMENTBANK.COM|2025-08-01 19:49:34.540
4|30/360|30|360|18|system |1753-01-01 00:00:00.000
3|ACT / ACT|0|365|18|system |1753-01-01 00:00:00.000
2|ACT / 360|111|360|26|PARTNER_NETIX_002@INVESTMENTBANK.COM|2025-08-01 15:01:40.250
12|Typescript Test|213|1|18|PARTNER.TREASY.006@INVESTMENTBANK.COM|2026-10-04 17:30:07.257
1|ACT / 365|1|365|26|SYSTEM|2025-10-12 12:36:40.107
```

## #4
```
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

## #5
```
Id|Name|Description|StateId|StateMaker|StateDate|Code|IsSystemDefinedChart|IsUserAnalytics|IsAdHocChart
--|----|-----------|-------|----------|---------|----|--------------------|---------------|------------
171|TEST|NULL|18|PARTNER.TREASY.006@INVESTMENTBANK.COM|2026-09-18 16:40:36.810|TEST|1|1|1
169|Carry Price|YÅrÅtme fiyati tutulan veri chartidir|18|SHEPHERD|2026-06-22 09:49:42.697|3721|0|0|0
168|tamer1|NULL|18|PARTNER.TREASY.002@INVESTMENTBANK.COM|2026-06-11 17:19:35.793|tamer1|1|0|0
167|tamer1|NULL|22|PARTNER.TREASY.002@INVESTMENTBANK.COM|2026-06-11 17:19:22.503|tamer1|1|0|0
166|tamer|NULL|26|PARTNER.TREASY.002@INVESTMENTBANK.COM|2026-06-11 17:18:33.950|tamer|1|0|0
165|Manual Rates|NULL|26|OZGE.TEKER@INVESTMENTBANK.COM|2026-06-09 15:42:40.593|MNL|0|0|0
155|tamer|NULL|22|PARTNER.TREASY.002@INVESTMENTBANK.COM|2026-06-11 17:18:00.470|tamer|1|0|0
154|Revaulation Prices|NULL|16|PARTNER_NETIX_005@INVESTMENTBANK.COM|2025-12-08 15:57:55.120|Revaulatio|0|0|0
153|Bloomberg Prices|NULL|16|PARTNER_NETIX_005@INVESTMENTBANK.COM|2025-12-08 15:55:27.140|Bloomberg|0|0|0
152|Borálanma Araálari Piyasasi Verileri|NULL|16|PARTNER_NETIX_005@INVESTMENTBANK.COM|2025-12-08 14:18:52.570|BapChart|0|0|0
151|Customer Auto Repo|GÅn sonu otomatik mÅsteri repolari iáin kullanilacaktir.|26|SELME2@INVESTMENTBANK.COM|2025-12-09 22:33:37.927|Autorepo|0|0|0
150|Banka Kurlari Manuel Yînetim Sistemi|Bu chart'taki girilmis olan kurlar data providerdan alinmayacak ve bu charttaki veri kullanilarak banka kurlari Åretilecektir|18|FATMA.YILDIRIM@INVESTMENTBANK.COM|2025-12-01 15:53:08.063|MANUALBANK|0|0|0
148|Cpi Indeks Montly|Aylik Cpi Endekleri bu chartta tutuluyor|18|PARTNER_NETIX_005@INVESTMENTBANK.COM|2025-08-06 11:15:53.330|CpiEndeks|0|0|0
147|LBMA Altin Tahvili|Altin tahvili îdemelerinde kullanilacak|18|PARTNER_NETIX_002@INVESTMENTBANK.COM|2025-07-22 14:36:18.143|LBMA|0|0|0
146|Invesment Fund Prices|Invesment Fund Prices|18|PARTNER_NETIX_004@INVESTMENTBANK.COM|2025-06-26 13:36:12.320|InvFund|1|0|0
145|Def Chart|sadfsdf|16|PARTNER_NETIX_002@INVESTMENTBANK.COM|2025-06-02 16:57:45.640|DEF|0|0|0
125|Customer Repo Rates|NULL|18|FATMA.YILDIRIM@INVESTMENTBANK.COM|2025-04-18 10:52:33.067|CusRepo|0|0|0
120|tset|test|16|PARTNER_NETIX_002@INVESTMENTBANK.COM|2025-04-15 09:28:52.700|test|1|1|0
119|denemen|denemen|16|PARTNER_NETIX_001@INVESTMENTBANK.COM|2025-02-28 17:26:50.820|denemen|1|1|0
113|test deneme|test deneme|18|HAZINEBIR@INVESTMENTBANK.COM|2024-11-27 10:57:13.957|Deneme|1|0|0
112|test deneme|test deneme|22|HAZINEIKI@INVESTMENTBANK.COM|2024-11-27 10:55:09.980|Deneme|1|0|0
111|test deneme|test deneme|22|HAZINEIKI@INVESTMENTBANK.COM|2024-10-15 17:07:21.960|Deneme|1|0|0
110|sait|gg|18|HAZINEIKI@INVESTMENTBANK.COM|2024-10-15 15:54:57.380|sait|0|0|0
106|deneme|deneme kaffka|18|HAZINEIKI@INVESTMENTBANK.COM|2024-07-08 16:31:56.073|asd|1|0|1
105|test|test amacli yazilmistir|18|HAZINEIKI@INVESTMENTBANK.COM|2024-09-26 14:09:03.490|test2123|0|0|0
55|xxx|xxx|16|HAZINEBIR@INVESTMENTBANK.COM|2024-07-01 14:44:17.553|xx|1|NULL|NULL
54|denememe|denememe|22|HAZINEIKI@INVESTMENTBANK.COM|2024-10-25 17:02:07.953|denememe|NULL|NULL|NULL
53|USD SOFR CURVE||18|HAZINEBIR@INVESTMENTBANK.COM|2024-05-27 13:32:42.970|SOFR|NULL|NULL|NULL
52|Netix Rates & Prices|Netix Rates and Prices|16|HAZINEBIR@INVESTMENTBANK.COM|2024-04-25 15:00:41.067|NTXRTS260|1|NULL|NULL
51|Netrex Rates & Prices|Netrex Rates and Prices|16|HAZINEBIR@INVESTMENTBANK.COM|2024-04-25 14:57:01.353|NTRRTS638|1|NULL|NULL
50|Netix Rates & Prices|Netix Rates and Prices|16|HAZINEBIR@INVESTMENTBANK.COM|2024-04-25 08:33:44.953|NTXRTS210|1|NULL|NULL
49|Netrex Rates & Prices|Netrex Rates and Prices|18|HAZINEIKI@INVESTMENTBANK.COM|2024-09-26 14:08:22.860|NTRRTS381|1|NULL|NULL
48|Netix Rates & Prices|Netix Rates and Prices|30|HAZINEIKI@INVESTMENTBANK.COM|2024-03-28 15:51:51.553|NTXRTS485|0|NULL|NULL
47|Netix Rates and Prices|Netix Rates and Prices|30|HAZINEIKI@INVESTMENTBANK.COM|2024-03-28 15:45:55.423|NTXRTS736|0|NULL|NULL
46|Netix Rates & Prices|Netix Rates and Prices|16|HAZINEBIR@INVESTMENTBANK.COM|2024-03-28 15:05:24.733|NTXRTS702|1|NULL|NULL
45|Netix Rates & Prices|Netix Rates and Prices|16|HAZINEBIR@INVESTMENTBANK.COM|2024-03-28 15:03:30.993|NTXRTS404|1|NULL|NULL
44|Netix Rates & Prices|Netix Rates and Prices|16|HAZINEBIR@INVESTMENTBANK.COM|2024-03-28 15:01:50.663|NTXRTS208|1|NULL|NULL
43|Netix Rates & Prices|Netix Rates and Prices|16|HAZINEBIR@INVESTMENTBANK.COM|2024-03-28 15:00:21.510|NTXRTS61|1|NULL|NULL
42|Netix Rates & Prices|Netix Rates and Prices|16|HAZINEBIR@INVESTMENTBANK.COM|2024-03-28 14:52:34.090|NTXRTS964|1|NULL|NULL
41|Netix Rates & Prices|Netix Rates and Prices|16|HAZINEBIR@INVESTMENTBANK.COM|2024-03-28 14:47:06.460|NTXRTS822|1|NULL|NULL
40|Netix Rates & Prices|Netix Rates and Prices|16|HAZINEBIR@INVESTMENTBANK.COM|2024-03-28 14:43:33.680|NTXRTS954|1|NULL|NULL
39|Netix Rates & Prices|Netix Rates and Prices|16|HAZINEBIR@INVESTMENTBANK.COM|2024-03-28 14:40:19.683|NTXRTS18|1|NULL|NULL
38|Netix Rates & Prices|Netix Rates and Prices|16|HAZINEBIR@INVESTMENTBANK.COM|2024-03-28 14:39:13.113|NTXRTS127|1|NULL|NULL
37|Netix Rates & Prices|Netix Rates and Prices|16|HAZINEBIR@INVESTMENTBANK.COM|2024-03-28 14:37:39.637|NTXRTS35|1|NULL|NULL
36|Netix Rates & Prices|Netix Rates and Prices|16|HAZINEBIR@INVESTMENTBANK.COM|2024-03-28 14:35:34.743|NTXRTS54|1|NULL|NULL
35|Netix Rates & Prices|Netix Rates and Prices|16|HAZINEBIR@INVESTMENTBANK.COM|2024-03-28 14:34:02.217|NTXRTS919|1|NULL|NULL
34|Netix Rates & Prices|Netix Rates and Prices|18|HAZINEIKI@INVESTMENTBANK.COM|2024-03-28 14:31:49.150|NTXRTS59|1|NULL|NULL
33|Netix Rates & Prices|Netix Rates and Prices|18|HAZINEIKI@INVESTMENTBANK.COM|2024-03-28 14:30:12.683|NTXRTS84|1|NULL|NULL
32|Netrex Rates & Prices|Netrex Rates and Prices|16|HAZINEBIR@INVESTMENTBANK.COM|2024-03-28 10:47:16.657|NTRRTS|1|NULL|NULL
31|Netrex Rates & Prices|Netrex Rates and Prices|16|HAZINEBIR@INVESTMENTBANK.COM|2024-03-28 09:24:55.990|NTRRTS|1|NULL|NULL
```

## #6
```
IndexChartId|RateTypeId|Adet
------------|----------|----
8|1|73
8|2|22
7|1|1
```

## #7
```
AmortizationMode|AmortizationTypeId|AmortizationFrequencyId|Adet
----------------|------------------|-----------------------|----
0|1|1|3
0|1|4|2
0|1|3|2
```

## #8
```
name|TabloAdi|is_disabled
----|--------|-----------
TxnCashFlowTrigger|TxnCashFlow|0
TxnLoanTrigger|TxnLoan|0
TxnMMTrigger|TxnMM|0
```

## #9
```
CurrencyCode|Year|GunSatiri
------------|----|---------
A05|2090|363
AED|2077|260
TRY|2075|364
ETB|2061|363
ARA|2060|363
CAD|2050|363
CAD|2036|365
CHF|2036|365
CNH|2036|365
DKK|2036|365
EUR|2036|365
GBP|2036|365
JPY|2036|365
NOK|2036|365
RUB|2036|365
SAR|2036|365
SEK|2036|365
TRY|2036|360
USD|2036|365
CAD|2035|365
```

## #10
```
Id|Code|Name|Description
--|----|----|-----------
8|OISZero|OIS Zero Rates|Overnight Indexed Swap Zero Rates
7|OIS|OIS Rates|Overnight Indexed Swap Rates1
3|CBT|Daily CBT Prices|NULL
```

## #11
```
CurrencyCode|Year|DayOfYear
------------|----|---------
EUR|2026|299
TRY|2026|299
USD|2026|299
EUR|2026|296
TRY|2026|296
USD|2026|296
```

## #12
```
Body
----

-- =============================================================
-- 3) Trigger'i yeni kolonlar sona eklenmis sekilde yeniden olustur
-- =============================================================
CREATE TRIGGER [dbo].[TxnLoanTrigger]
    ON dbo.Txn
```

## #13
```
ChartId|Baslik|SonTarih
-------|------|--------
2|909|2026-10-25 00:00:00.000
4|890|2026-10-23 00:00:00.000
5|890|2026-10-23 00:00:00.000
7|768|2026-10-07 00:00:00.000
8|715|2026-10-07 00:00:00.000
151|293|2026-10-07 00:00:00.000
103|8|2026-09-10 00:00:00.000
101|30|2026-09-10 00:00:00.000
9|5|2026-05-13 00:00:00.000
125|3|2026-03-26 00:00:00.000
155|3|2026-03-17 00:00:00.000
105|8|2026-01-16 00:00:00.000
102|6|2025-08-28 00:00:00.000
100|5|2025-08-14 00:00:00.000
113|1|2025-05-15 00:00:00.000
110|3|2024-12-25 00:00:00.000
11|5|2024-11-14 00:00:00.000
112|4|2024-11-11 00:00:00.000
10|2|2024-11-04 00:00:00.000
1|1|2024-11-04 00:00:00.000
ChartId|Baslik
-------|------
2|1041
4|1031
3|989
5|977
10|761
11|202
161|47
162|47
163|47
101|45
102|41
103|41
104|38
165|4
105|3
9|3
100|3
155|2
6|2
147|2
```

## #14
```
name|TxnLoanHistory|TxnMMHistory|TxnCashFlowHistory
----|--------------|------------|------------------
TxnCashFlowTrigger|0|0|1
TxnLoanTrigger|1|0|0
TxnMMTrigger|0|1|0
```

## #15
```
Id|Code|Name
--|----|----
151|Autorepo|Customer Auto Repo
5|Bank|Bank Rates
4|Benchmark|Benchmark Rates & Prices
2|RateSheet|Market Rates & Prices
```

## #16
```
name
----
Id
Code
Name
AccountingMapCode
MainProductCode
ExternalMainProductCode
UseFundSource
UseSubFundSource
UseOnUnitValue
IsBorrowing
IsPlacement
IsAccountNeeded
IsAllowRollover
IsAllowBrokerage
IsMultiplePayment
IsTaxApplicable
IsUseTxnGLCode
IsCollateralized
IsIntraBank
IsSameDay
IsZeroRate
IsGenerateFWDAccounting
IsDefaultProduction
AccountSelectionTypeId
AccountingCalculationMethodTypeId
Order
IsEnabled
StateId
StateMaker
StateDate
ExternalSubProductCode
LogicalReferenceTypeId
IsMarketCommissionApplicable
IsAllowTawarruq
```

## #17
```
Id|Name|Description|IsEnabled
--|----|-----------|---------
3|Other|NULL|1
2|Full Amount & Interest|NULL|1
1|Full Amount|NULL|1
Id|Code|Name|Description|ExternalCode|Alias|IsEnabled
--|----|----|-----------|------------|-----|---------
4|InvestmentAgency|Investment Agency|NULL|DPI|InvestmentProxy|1
3|PrivateFunds|Private Funds|NULL|DPS|InvestmentProxy|0
2|ParticipationAccounts|Participation Accounts|NULL|DPD|Standart|1
1|EquityCapital|Equity Capital|NULL|EQC|Equity Capital|1
Id|Code|Name|Description|AccountingMapCode|ExternalCode|FromDays|ToDays|IsEnabled
--|----|----|-----------|-----------------|------------|--------|------|---------
4|SameDay|SameDay|NULL|SHORT|ShortTerm|0|0|1
3|LongTerm|Long Term|NULL|LONG|LongTerm|366|3650|1
2|MidLongTerm|Mid-Long Term|NULL|MIDLONG|midLongTerm|366|1825|0
1|ShortTerm|Short Term|NULL|SHORT|ShortTerm|1|365|1
```

## #18
```
TxnMmProductTypeId|PaymentType|StateId|Adet
------------------|-----------|-------|----
1|Single|18|288
1|Single|16|126
5|Single|16|58
5|Single|18|53
4|Single|16|41
3|Multiple|22|35
1|Single|22|25
3|Zero|22|18
4|Single|18|14
2|Single|18|8
15|Single|18|8
1|Single|30|5
1|Single|20|4
15|Single|16|4
2|Single|16|3
1|Single|24|3
5|Single|22|2
8|Single|16|1
7|Single|16|1
5|Single|30|1
ProductDefinitionId|StateId|Adet
-------------------|-------|----
2|18|52
2|16|33
2|24|6
2|22|4
2|20|1
```

## #19
```
Id|Code|Name|MainProductCode|ExternalMainProductCode|ExternalSubProductCode|IsEnabled|StateId|IsBorrowing|IsPlacement|IsSameDay|IsZeroRate|IsMultiplePayment|UseFundSource|UseSubFundSource|IsAllowRollover|IsAllowTawarruq|IsGenerateFWDAccounting|IsAccountNeeded|IsTaxApplicable|AccountingCalculationMethodTypeId|LogicalReferenceTypeId
--|----|----|---------------|-----------------------|----------------------|---------|-------|-----------|-----------|---------|----------|-----------------|-------------|----------------|---------------|---------------|-----------------------|---------------|---------------|---------------------------------|----------------------
15|Subordinated-Loan|Subordinated-Loan|MM|MM|MLN|1|26|1|1|0|0|0|0|0|1|1|0|1|1|2|10
14|Mudaraba|Mudaraba|MM|MM|MBH|1|18|0|1|0|0|0|0|0|1|1|0|1|1|2|5
13|CD|CD|MM|MM|MBH|1|18|0|1|0|0|0|0|0|1|1|0|1|1|2|5
12|OMF|OMF|MM|MM|MBH|1|18|0|1|0|0|0|0|0|1|1|0|1|1|2|5
11|Post-Financing|Post-Financing|MM|MM|MLN|1|18|1|1|0|0|0|0|0|1|0|0|1|1|2|9
10|Securitization|Securitization|MM|MM|MLN|1|18|1|1|0|0|0|0|0|1|0|0|1|1|2|8
9|Syndication|Syndication|MM|MM|MLN|1|18|1|1|0|0|0|0|0|1|0|0|1|1|2|7
8|Gil|Gil|MM|MM|BMM|1|18|1|0|1|1|0|0|0|0|0|0|1|0|1|1
7|Pass|Pas|MM|MM|BMM|1|18|1|1|1|1|0|0|0|0|0|0|1|0|1|1
6|TermDeposit|Term Deposit|MM|MM|DPO|0|18|1|1|0|0|0|0|0|0|0|0|1|1|1|6
5|Murabaha|Murabaha|MM|MM|MBH|1|26|1|1|0|0|0|0|0|1|1|0|1|1|2|5
4|Wakale|Wakale|MM|MM|VEK|1|26|1|1|0|0|0|0|0|1|1|0|1|1|2|4
3|Issue|Bond Issue|MM|MM|ACU|1|18|1|0|0|0|0|0|0|1|0|0|0|0|1|2
2|Loan|Interbank Loan|MM|MM|MLN|1|26|1|1|0|0|0|0|0|1|1|0|1|1|2|3
1|MoneyMarket|Money Market|MM|MM|BMM|1|26|1|1|0|0|0|0|0|1|1|0|1|1|2|1
```

## #20
```
Id|Name|Code|Description|IsEnabled
--|----|----|-----------|---------
10|Subordinated-Loan|SL|Subordinated-Loan Reference|1
9|Post-Financing|PF|Post-Financing Reference|1
8|Securitization|SZ|Securitization Reference|1
7|Syndication|SY|Syndication Reference|1
6|Term Deposit|TD|NULL|1
5|Murabaha|MR|NULL|1
4|Wakala|WA|NULL|1
3|Interbank Loan|LN|NULL|1
2|Issue|IS|NULL|1
1|Money Market|MM|NULL|1
Id|Code|Name|Description|IsEnabled
--|----|----|-----------|---------
2|IRR-CL|IRR-CL Rediscount|NULL|1
1|SL|SL Rediscount|NULL|1
```

## #21
```
LogicalReference
----------------
TSLBRW2610210017
TWABRW2610210016
TWABRW2610210015
LogicalReference
----------------
TLNBRW2609150005
TLNBRW2608060019
TLNBRW2608060017
```

## #22
```
name
----
Bistech_CitiBackup
Citi_CommercialCardClientRisk
Citi_EftRecon
Citi_ThirdPartyLogging
CitiApplication
CitiBase_CitiBackup
CitiCore
CitiPricingAutomation
CitiPricingAutomation_Dev
EasyCommon
EasyFx
EasyMM
EasyRate
ESign
ESign_Dev
EsignDemo
EsignFramework
Flex
Framework
FxRawRate
```

## #23
```
name
----
NetTrexAcc
NetTrexAcc_132
NetTrexAcc_132_Dev
NetTrexAcc_133
NetTrexAcc_133_Dev
NetTrexAcc_133_Test_Sukru
NetTrexAcc_134
NetTrexAcc_134_Dev
NetTrexAcc_134_Test_Selim
NetTrexAcc_135
NetTrexAcc_135_Dev
NetTrexAcc_135_Test
NetTrexAcc_136
NetTrexAcc_136_Dev
NetTrexAcc_136_Test
NetTrexAcc_20001026_Test
NetTrexAcc_240226_S
NetTrexAcc_260226_S
NetTrexAcc_Amortization
NetTrexAcc_Auto
```

## #24
```
name
----
NetTrexCommon
TrexCommon
```

## #25 (DB: NetTrexCommon)
```
OptionPath|OptionName|Value
----------|----------|-----
Limit.LimitCheck|DV.Enabled|true
Limit.LimitCheck|DV.ExcludedMarkets|TAKAS;BIST
Limit.LimitCheck|FX.Enabled|false
Limit.LimitCheck|FX.ExcludedMarkets|TAKAS;BIST
Limit.LimitCheck|LN.Enabled|true
Limit.LimitCheck|LN.ExcludedMarkets|TAKAS;BIST
Limit.LimitCheck|MM.Enabled|true
Limit.LimitCheck|MM.ExcludedMarkets|TAKAS;BIST
LN.DepoRate|FloatingChartABM|B
LN.DepoRate|FloatingChartId|7
LN.DepoRate|IndexChartABM|B
LN.DepoRate|IndexChartId|8
MM|AccFcyChartABM|A
MM|AccFcyChartNo|3
MM|SystemWDFlag|0
MM.ExternalService.Payments|SendPayment|true
MM.Payment.Validation|Level|2
MM.Payment.Validation.Action|Disabled|true
PortfolioPath|AFSRoot|0/1/2/3/5/
PortfolioPath|FIRoot|0/1/2/3/
PortfolioPath|FutureDefault|0/1/2/6/174/
PortfolioPath|FXDefault|0/1/2/6/69/
PortfolioPath|FXRoot|0/1/2/6/
PortfolioPath|HTMRoot|0/1/2/3/15/
PortfolioPath|ISSUERoot|0/1/2/3/171/
PortfolioPath|MMDefault|0/1/2/0/
PortfolioPath|MMInterbankLoanDefault|0/1/2/0/
PortfolioPath|MMInterbankLoanRoot|0/1/
PortfolioPath|MMRoot|0/1/
PortfolioPath|TRDRoot|0/1/2/3/4/
Revaluation|FI.ReverseType|3
Revaluation|FX.ReverseType|3
Revaluation|MM.ReverseType|3
Trex|DefaultCurrency|TRY
Trex|MMLogicalDate|23.10.2026
```

## #26
```
TxnId|OrderNumber|PeriodNumber|FlowTypeId|IsAmortization|PrincipalAmount|StartDate|EndDate|PaymentDate|Days|Rate|Spread|CashFlowAmount|PaymentDirection|DaysInYear
-----|-----------|------------|----------|--------------|---------------|---------|-------|-----------|----|----|------|--------------|----------------|----------
1201137|1|NULL|1|0|6000000.0000000000|NULL|NULL|2026-06-19|0|.0000000000|.0000000000|6000000.0000000000|Outgoing|0
1201137|2|1|2|0|6000000.0000000000|2026-06-12|2026-09-14|2026-09-21|94|49.1030006400|200.0000000000|789646.3700000000|Incoming|365
1201137|3|2|2|0|6000000.0000000000|2026-09-14|2026-12-14|2026-12-21|91|51.0796759781|200.0000000000|794013.7800000000|Incoming|365
1201137|4|NULL|1|1|6000000.0000000000|NULL|NULL|2026-12-21|0|.0000000000|.0000000000|100000.0000000000|Incoming|0
1201137|5|3|2|0|5900000.0000000000|2026-12-14|2027-03-12|2027-03-19|88|48.2021959755|200.0000000000|714109.0500000000|Incoming|365
1201137|6|4|2|0|5900000.0000000000|2027-03-12|2027-06-14|2027-06-21|94|45.0696702895|200.0000000000|715201.0700000000|Incoming|365
1201137|7|5|2|0|5900000.0000000000|2027-06-14|2027-09-13|2027-09-20|91|42.2258238692|200.0000000000|650543.6900000000|Incoming|365
1201137|8|6|2|0|5900000.0000000000|2027-09-13|2027-12-13|2027-12-20|91|40.5499171228|200.0000000000|625891.7900000000|Incoming|365
1201137|9|7|2|0|5900000.0000000000|2027-12-13|2028-03-13|2028-03-20|91|38.8865558604|200.0000000000|601424.4300000000|Incoming|365
1201137|10|8|2|0|5900000.0000000000|2028-03-13|2028-06-15|2028-06-22|94|37.8573067589|200.0000000000|605612.6700000000|Incoming|365
1201137|11|NULL|1|0|5900000.0000000000|NULL|NULL|2028-06-22|0|.0000000000|.0000000000|5900000.0000000000|Incoming|0
```

## #27
```
SwapPointFactor|Adet
---------------|----
10000|68
100|14
0|3
1|2
321123|1
100000|1
45455|1
```

## #28
```
Msg 207, Level 16, State 1, Server srv-mssql, Line 1
Invalid column name 'TxnId'.
Msg 207, Level 16, State 1, Server srv-mssql, Line 1
Invalid column name 'TxnId'.
Msg 207, Level 16, State 1, Server srv-mssql, Line 1
Invalid column name 'TxnId'.
```

## #29
```
Farkli|Toplam
------|------
24|96
Id|MaturityDate|PaymentLagDays|HeaderPay|LastPay
--|------------|--------------|---------|-------
1201165|2026-12-16|10|2026-12-28|2026-12-30
1201164|2026-12-16|10|2026-12-28|2026-12-30
1201162|2026-07-21|5|2026-07-27|2026-07-28
1201160|2026-07-06|10|2026-07-16|2026-07-21
1201137|2028-06-15|5|2028-06-20|2028-06-22
1201136|2029-06-15|2|2029-06-18|2029-06-19
1201124|2026-05-21|5|2026-05-26|2026-06-02
1201107|2026-09-11|2|2026-09-14|2026-09-15
1201101|2026-04-28|7|2026-05-05|2026-05-07
1201100|2026-04-28|1|2026-04-29|2026-05-07
```

## #30
```
TxnId|PeriodNumber|InterestMethodId|FloatingRateTypeId|PrincipalAmount|Days|Rate|Spread|CashFlowAmount|DaysInYear
-----|------------|----------------|------------------|---------------|----|----|------|--------------|----------
1201146|1|2|6|20000.0000000000|4|.5392019300|.0000000000|107.8400000000|365
1201137|8|1|6|5900000.0000000000|94|37.8573067589|200.0000000000|605612.6700000000|365
1201137|7|1|6|5900000.0000000000|91|38.8865558604|200.0000000000|601424.4300000000|365
1201137|6|1|6|5900000.0000000000|91|40.5499171228|200.0000000000|625891.7900000000|365
1201137|5|1|6|5900000.0000000000|91|42.2258238692|200.0000000000|650543.6900000000|365
1201137|4|1|6|5900000.0000000000|94|45.0696702895|200.0000000000|715201.0700000000|365
1201137|3|1|6|5900000.0000000000|88|48.2021959755|200.0000000000|714109.0500000000|365
1201137|2|1|6|6000000.0000000000|91|51.0796759781|200.0000000000|794013.7800000000|365
1201137|1|1|6|6000000.0000000000|94|49.1030006400|200.0000000000|789646.3700000000|365
1201136|3|2|6|900000.0000000000|368|43.1019722200|.0000000000|387917.7500000000|365
```

## #31
```
Msg 207, Level 16, State 1, Server srv-mssql, Line 1
Invalid column name 'Id'.
```

## #32
```
name
----
Id
CalculationDate
GenerationDate
State
TxnMmId
PeriodId
AccrualDay
AccrualAmount
AccrualAmountSL
AccrualAmountIRR
AccrualAmountLCY
AccEntryMainId
Ccy
FXRate
BaseAmount
```

## #33
```
FromCurrency|ToCurrency|SwapPointFactor|StateId
------------|----------|---------------|-------
XPT|USD|100|18
XPT|TRY|100|18
XPT|EUR|100|18
XPD|USD|100|18
XPD|TRY|100|18
XPD|EUR|100|18
XAU|XAG|100|18
XAU|USD|100|18
XAU|TRY|100|18
XAU|EUR|100|18
XAU|AED|1|18
XAG|USD|100|18
XAG|TRY|100|18
XAG|EUR|100|18
JPY|TRY|100000|18
EUR|RON|0|18
C75|TRY|100|18
C70|USD|0|18
C70|TRY|0|18
AED|CNH|1|18
```

## #34
```
TxnMmId|CalculationDate|AccrualDay|AccrualAmount|AccrualAmountSL|AccrualAmountIRR|FXRate
-------|---------------|----------|-------------|---------------|----------------|------
553427|2026-10-21|562|24180.400000000000000000|27777.780000000000000000|24180.400000000000000000|NULL
```

## #35
```
TxnId|ProductCode|OpeningFisSayisi
-----|-----------|----------------
553197|MM|2
501024|TWR|2
501023|TWR|2
501020|TWR|2
501019|TWR|2
501016|TWR|2
501015|TWR|2
501013|TWR|2
501012|TWR|2
501010|TWR|2
501008|TWR|2
501007|TWR|2
501006|TWR|2
501004|TWR|2
501003|TWR|2
```

## #36
```
ProductCode|Type|IsReverse|Adet|FarkliIslem
-----------|----|---------|----|-----------
MM|2|0|2222|297
MM|2|1|2114|277
MM|1|0|472|471
MM|4|0|199|199
TWR|1|0|42|28
MM|3|0|27|18
Loan|1|0|19|19
MM|1|1|16|16
TWR|1|1|7|5
Loan|1|1|1|1
```

## #37
```
Msg 130, Level 15, State 1, Server srv-mssql, Line 1
Cannot perform an aggregate function on an expression containing an aggregate or a subquery.
```

## #37 (hata: aggregate icinde subquery) ve #38
```
Msg 130, Level 15, State 1, Server srv-mssql, Line 1
Cannot perform an aggregate function on an expression containing an aggregate or a subquery.
---
OnayliIL|FisiOlan
--------|--------
52|48
ProductCode|Type|IsReverse|Adet
-----------|----|---------|----
MM|2|0|195
MM|2|1|168
MM|1|0|54
MM|4|0|4
MM|1|1|1
```

## #39
```
TxnId|OpeningFis|StateId
-----|----------|-------
Id|StateId|ValueDate|TradeDate|LogicalReference
--|-------|---------|---------|----------------
1201146|18|2026-06-15|2026-06-18|TLNBRW2606200001
1201119|18|2026-05-14|2026-05-11|TLNBRW2605140004
1201076|18|2026-04-16|2026-04-16|TLNPLC2604160016
1201072|18|2026-04-16|2026-04-16|TLNPLC2604160012
```

## #40
```
Id|TxnId|Type|IsReverse|ReverseId|ValueDate
--|-----|----|---------|---------|---------
554908|553197|1|0|0|2026-04-21
554907|553197|1|0|0|2026-04-21
Id|StateId|StateMaker|StateDate|DealAmount|MaturityAmount|ValueDate
--|-------|----------|---------|----------|--------------|---------
553197|24|PARTNER.TREASY.005@INVESTMENTBANK.COM|2026-04-21 08:53:24.173|1518586631.0000000000|1519418733.2600000000|2026-04-21
553197|24|PARTNER.TREASY.005@INVESTMENTBANK.COM|2026-04-21 08:53:24.173|1518586631.0000000000|1519418733.2600000000|2026-04-21
553197|18|PARTNER.TREASY.003@INVESTMENTBANK.COM|2026-04-21 08:52:44.403|1518586631.0000000000|1519418733.2600000000|2026-04-21
553197|24|PARTNER.TREASY.004@INVESTMENTBANK.COM|2026-04-21 08:51:05.537|1518586631.0000000000|1519418733.2600000000|2026-04-21
553197|18|PARTNER.TREASY.004@INVESTMENTBANK.COM|2026-04-21 08:50:14.173|1518586631.0000000000|1519418733.2600000000|2026-04-21
553197|16|PARTNER.TREASY.003@INVESTMENTBANK.COM|2026-04-21 08:49:57.223|1518586631.0000000000|1519418733.2600000000|2026-04-21
Id|StateId|DealAmount|MaturityAmount|LogicalReference
--|-------|----------|--------------|----------------
553197|24|1518586631.0000000000|1519418733.2600000000|TMMBRW2604210001
```

## #41
```
name
----
HistoryId
Id
CustomerId
TxnMmProductTypeId
FundSourceId
SubFundSourceCode
PortfolioId
BasisCode
DaysInYear
TermId
TxnTypeCode
CollateralType
BusinessKey
LogicalReference
MarketCode
Ccy
InputDate
TradeDate
ValueDate
MaturityDate
DealAmount
MaturityAmount
PaymentType
CustomerLocation
Instructions
IsMatured
AccountNumber
GLCode
StateId
StateMaker
StateDate
SwiftConfirmationMessageStatus
SwiftPaymentMessageStatus
DomesticPaymentMessageStatus
OutgoingCorrespondentId
OutgoingCorrespondentAccountNumber
OutgoingCorrespondentAccountGLCode
TheirBeneficiaryCorrespondentName
TheirBeneficiaryCorrespondentSwiftCode
TheirBeneficiaryCorrespondentAccountNumber
TheirSenderCorrespondentName
TheirSenderCorrespondentSwiftCode
TheirSenderCorrespondentAccountNumber
IncomingCorrespondentId
IncomingCorrespondentAccountNumber
IncomingCorrespondentAccountGLCode
PaymentInstructionTypeId
SecurityId
ExternalReference
ExternalReferenceSourceId
SendConfirmation
SendPayment
SendNoticeToReceive
OutgoingPaymentAccountingType
SettlementTypeId
OutgoingPaymentAccountingGLType
OutgoingPaymentAccountingGL
IncomingPaymentAccountingType
IncomingPaymentAccountingGLType
IncomingPaymentAccountingGL
TheirBeneficiaryCorrespondentId
TheirBeneficiaryCorrespondentGLCode
TheirSenderCorrespondentId
TheirSenderCorrespondentGLCode
CreatedBy
CreatedDate
PreviousStateId
PreviousStateMaker
PreviousStateDate
FlowId
RolloverTypeId
Trader
CorporateCurrentAccountNumber
CorporateCurrentAccountGLCode
CustomerIsFinancialInstitution
CorporateCurrentAccountWorkGroupId
LastActionId
PreviousActionId
TransactionOriginType
LinkedTransactionId
LinkedTransactionReference
LinkedTransactionTrader
LinkedTransactionReasonType
```

## #42
```
HistoryId|StateId|StateDate|AccountNumber|GLCode|BusinessKey|LogicalReference|TxnTypeCode|InputDate|CreatedBy|Trader|OutgoingPaymentAccountingGL|IncomingPaymentAccountingGL|TransactionOriginType|LinkedTransactionId
---------|-------|---------|-------------|------|-----------|----------------|-----------|---------|---------|------|---------------------------|---------------------------|---------------------|-------------------
24068|24|2026-04-21 08:53:24.173|NULL|NULL|657988175864676400|TMMBRW2604210001|BRW|2026-04-21 08:53:16.000|PARTNER.TREASY.003@INVESTMENTBANK.COM|PARTNER.TREASY.003@INVESTMENTBANK.COM|NULL|NULL|1|NULL
3378|24|2026-04-21 08:53:24.173|NULL|NULL|657988175864676400|TMMBRW2604210001|BRW|2026-04-21 08:53:16.000|PARTNER.TREASY.003@INVESTMENTBANK.COM|PARTNER.TREASY.003@INVESTMENTBANK.COM|NULL|NULL|1|NULL
3377|18|2026-04-21 08:52:44.403|332236|32801000|657988175864676353|TMMBRW2604210001|BRW|2026-04-21 08:50:58.000|PARTNER.TREASY.003@INVESTMENTBANK.COM|PARTNER.TREASY.003@INVESTMENTBANK.COM|NULL|NULL|1|NULL
3376|24|2026-04-21 08:51:05.537|NULL|NULL|657988175864676400|TMMBRW2604210001|BRW|2026-04-21 08:50:58.000|PARTNER.TREASY.003@INVESTMENTBANK.COM|PARTNER.TREASY.003@INVESTMENTBANK.COM|NULL|NULL|1|NULL
3375|18|2026-04-21 08:50:14.173|332235|32801000|657988175864676353|TMMBRW2604210001|BRW|2026-04-21 08:49:42.723|PARTNER.TREASY.003@INVESTMENTBANK.COM|PARTNER.TREASY.003@INVESTMENTBANK.COM|NULL|39200840|1|NULL
3374|16|2026-04-21 08:49:57.223|NULL|NULL|2046466448933076992|TMMBRW2604210001|BRW|2026-04-21 08:49:42.723|PARTNER.TREASY.003@INVESTMENTBANK.COM|PARTNER.TREASY.003@INVESTMENTBANK.COM|NULL|NULL|1|NULL
```

## #43
```
HistoryId|StateId|IsMatured|SwConf|SwPay|DomPay|ExternalReference|ExtSrc|OutCorr|InCorr|InAcc|InPAT|InPGLT|OutPAT|SettlementTypeId|PIT|SC|SP|TermId|CustLoc|PrevSt|LastAct
---------|-------|---------|------|-----|------|-----------------|------|-------|------|-----|-----|------|------|----------------|---|--|--|------|-------|------|-------
24068|24|0|NULL|NULL|NULL|NULL|NULL|NULL|NULL|NULL|NULL|NULL|NULL|1|1|1|1|1|DOM|24|4
3378|24|0|NULL|NULL|NULL|NULL|NULL|NULL|NULL|NULL|NULL|NULL|NULL|1|1|1|1|1|DOM|24|4
3377|18|0|NULL|NULL|NULL|NULL|NULL|27207|27207|90766|NULL|NULL|NULL|1|1|1|1|1|DOM|18|4
3376|24|0|NULL|NULL|NULL|NULL|NULL|27207|27207|90766|NULL|NULL|NULL|1|1|1|1|1|DOM|24|4
3375|18|0|NULL|NULL|NULL|NULL|NULL|27207|27207|90766|TempAcc|LedgerAcc|TempAcc|1|1|1|1|1|DOM|18|2
3374|16|0|NULL|NULL|NULL|NULL|NULL|27207|27207|90766|TempAcc|LedgerAcc|TempAcc|1|1|1|1|1|DOM|16|2
```

## #44
```
Id|FarkliHesap|Snapshot
--|-----------|--------
553197|2|2
553183|2|3
551966|2|6
GuncelKayitHesapsiz
-------------------
0
```

## #45
```
Id|StateId|AccountNumber|GLCode|BusinessKey|InPAT|InPGLT|InPGL|OutPAT
--|-------|-------------|------|-----------|-----|------|-----|------
551966|18|332200|34300000|597889461747134465|TempAcc|LedgerAcc|NULL|TempAcc
553183|18|302115|32801000|0|TempAcc|LedgerAcc|NULL|TempAcc
553197|24|NULL|NULL|657988175864676400|NULL|NULL|NULL|NULL
EditliVeOnayli|HesapsizOlan|InPATnull
--------------|------------|---------
1|0|0
```

## #46
```
OnayliMM|OpeningOlan
--------|-----------
382|339
Id|LogicalReference|ValueDate|OnayGunu|Urun
--|----------------|---------|--------|----
553411|TMRBRW2610020001|2026-10-02|2026-10-05|5
553409|TMRBRW2609300009|2026-09-30|2026-10-05|5
553388|TMMPLC2609170001|2026-09-16|2026-09-17|1
553381|TMMPLC2609120001|2026-09-11|2026-09-12|1
553340|TMRBRW2608200004|2026-08-21|2026-08-20|5
553328|TMMPLC2608100004|2025-10-15|2026-08-10|1
553267|TMMBRW2607020012|2026-07-20|2026-07-02|1
553198|TMMBRW2604220005|2026-04-27|2026-04-22|1
553168|TMMBRW2603160003|2026-02-10|2026-03-16|1
553148|TMRBRW2603030003|2026-03-02|2026-03-03|5
```

## #47
```
name
----
BatchItem
BatchLog
BatchLogDetail
BatchSet
```

## #48
```
Tablo|name
-----|----
BatchItem|Id
BatchItem|ItemOrder
BatchItem|ItemID
BatchItem|Name
BatchItem|Severity
BatchItem|State
BatchItem|ParentItemNo
BatchItem|BatchSetId
BatchItem|IsTransactional
BatchItem|StateId
BatchItem|StateMaker
BatchItem|StateDate
BatchSet|Id
BatchSet|Name
BatchSet|Description
BatchSet|StateId
BatchSet|StateMaker
BatchSet|StateDate
```

## #49
```
Id|Name|Description|StateId
--|----|-----------|-------
5|MMStpBloomberg|MM StpBloomberg|18
4|MMAO|MM Account Operation|18
3|PassGil|MM Pass Gil|18
2|Bod|Mm Bod|18
1|Eod|Mm Eod|18
```

## #50
```
BatchSetId|ItemOrder|ItemID|Name|State|StateId|IsTransactional|ParentItemNo
----------|---------|------|----|-----|-------|---------------|------------
1|1|NetTrex.MM.Batch.Items.EndOfDay.ReverseBatchItem|Reverse Accountings|1|26|0|3
1|1|Composite|Pre Eod|1|26|0|1
1|1|Composite|BRW & PLC EndOfDay|1|26|0|0
1|1|NetTrex.MM.Batch.Items.Common.DateTimeCheckBatchItem|Date Time Check|1|26|0|2
1|1|NeTrex.MM.Batch.EndOfDay.Validation.FxRateValidationBatchItem|FX Rate Validation|1|18|0|6
1|2|Composite|Validation|0|26|0|2
1|2|Composite|Eod|1|18|0|1
1|3|NetTrex.MM.Batch.Items.EndOfDay.RevaluationBatchItem|Revaluation Transactions|1|26|0|3
1|3|Composite|Post Eod|1|18|0|1
1|5|NeTrex.MM.Batch.EndOfDay.Validation.MmTransactionsValidationBatchItem|Transaction Validation|1|18|0|6
1|9|NeTrex.MM.Batch.EndOfDay.Validation.InterestRateValidationBatchItem|Interest Rate Validation|1|18|0|6
1|10|NetTrex.MM.Batch.Items.EndOfDay.LogicalDateUpdateBatchItem|Logical Date Update|0|26|0|4
1|11|NetTrex.MM.Batch.Items.EndOfDay.EodVerificationBatchItem|Eod Verification|1|18|0|4
2|1|Composite|BRW & PLC BeginOfDay|1|26|0|0
2|1|Composite|Pre Bod|1|26|0|16
2|1|NetTrex.MM.Batch.Items.BeginOfDay.CashFlowReGenerateBatchItem|CashFlow Regenerate|0|18|0|24
2|1|NetTrex.MM.Batch.Items.Common.DateTimeCheckBatchItem|Date Time Check|1|26|0|23
2|2|Composite|Bod|1|26|0|16
2|2|NetTrex.MM.Batch.Items.BeginOfDay.ForwardBatchItem|Forward Transactions|0|26|0|24
2|3|NetTrex.MM.Batch.Items.BeginOfDay.PeriodEndBatchItem|Period End Transactions|0|26|0|24
2|4|NetTrex.MM.Batch.Items.BeginOfDay.ReverseBatchItem|Reverse Accoutings|1|26|0|24
2|5|NetTrex.MM.Batch.Items.BeginOfDay.MaturationBatchItem|Maturation Transactions|1|26|0|24
2|6|NetTrex.MM.Batch.Items.BeginOfDay.PaymentBatchItem|Payment Transactions|0|18|0|24
2|7|NetTrex.MM.Batch.Items.BeginOfDay.AmortizationBatchItem|Amortization|0|18|0|24
2|8|NetTrex.MM.Batch.Items.BeginOfDay.FeeBatchItem|Fee|0|18|0|24
3|1|NetTrex.MM.Batch.Items.PassGil.MaturationBatchItem|Maturited Settlement|1|26|0|29
3|1|Composite|Pass & Gil|1|26|0|26
3|1|NetTrex.MM.Batch.Items.Common.DateTimeCheckBatchItem|Date Time Check|1|26|0|27
3|1|Composite|Pre Pass & Gil|1|26|0|26
3|1|Composite|Pass & Gil|1|26|0|0
4|1|NetTrex.MM.Batch.Items.AccountOperation.AllCloseAccountsBatchItem|All Close Accounts|0|18|0|31
4|1|NetTrex.MM.Batch.Items.AccountOperation.DailyCloseAccountsBatchItem|Daily Close Accounts|1|18|0|31
4|1|Composite|BRW & PLC Account Operation|1|18|0|0
5|1|NetTrex.MM.Batch.Items.Stp.Bloomberg.StpBloombergBatchItem|MM Bloomberg Files Execution|1|18|0|34
5|1|Composite|MM Stp Bloomberg|1|18|0|0
```

## #51 (NetTrexCommon)
```
OptionPath|OptionName|Value
----------|----------|-----
MM|SystemWDFlag|0
MM.Account.Close|AfterFailedVerify|true
MM.Account.Close|AfterMaturation|true
MM.ExternalService.API|UseDirectAccounting|true
MM.ExternalService.API|UseDirectCreate|true
Payment|MM.IncomingPaymentAccountingGLType|LedgerAcc
Payment|MM.IncomingPaymentAccountingType|TempAcc
Payment|MM.OutgoingPaymentAccountingGLType|LedgerAcc
Payment|MM.OutgoingPaymentAccountingType|TempAcc
Trex|DepositRateCarryNextDay|2;4;5;7;8;151
Trex|DepositRateCarryNextDay|2;4;5;7;8
Trex|DepositRateCarryNextDay|2;4;5;7;8
Trex|DepositRateCarryNextDay|2;4;5;7;8
Trex|FimpleMmTreasuryTransactionSync|true
Trex|FxRateCarryNextDay| 2;3;4;5;10
Trex|FxRateCarryNextDay| 2;3;4;5;10
Trex|FxRateCarryNextDay| 2;3;4;5;10
Trex|FxRateCarryNextDay| 2;3;4;5;10
Trex|MmAccountingSync|true
```
