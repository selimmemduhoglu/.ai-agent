# 02-ciktilar — interbankloan-muhasebe-ayrimi

## #1
```
name|type|max_length|is_nullable
----|----|----------|-----------
Id|int|4|0
Ccy|nvarchar|6|1
CustomerId|int|4|1
RuleId|int|4|1
Rule2Id|int|4|1
Rule3Id|int|4|1
Rule4Id|int|4|1
Rule5Id|int|4|1
Rule6Id|int|4|1
Rule7Id|int|4|1
Rule8Id|int|4|1
Rule9Id|int|4|1
Rule10Id|int|4|1
Source|nvarchar|1000|1
Path|nvarchar|2000|1
TargetMainGL|nvarchar|1000|1
Target|nvarchar|1000|1
TargetRuleId|int|4|1
IsEnabled|bit|1|1
Order|int|4|1
Description|nvarchar|-1|1
CustomerCodeSourceRuleId|int|4|1
CustomerAccountCodeSourceRuleId|int|4|1
StateId|int|4|0
StateMaker|nvarchar|160|0
StateDate|datetime|8|0
CustomerAccountWorkGroupCodeSourceRuleId|int|4|1
CustomerAccountBranchCodeSourceRuleId|int|4|1
CustomerAccountTypeCodeSourceRuleId|int|4|1
```
## #2
```
Path|Adet
----|----
TREX/BRWPLC1/TWR/PLC/LCY/|3
TREX/BRWPLC1/TWR/PLC/FCY/|3
TREX/BRWPLC1/TWR/BRW/LCY/|3
TREX/BRWPLC1/TWR/BRW/FCY/|3
TREX/BRWPLC1/MONEYMARKET/PLC/LCY|23
TREX/BRWPLC1/MONEYMARKET/PLC/FCY|25
TREX/BRWPLC1/MONEYMARKET/BRW/LCY|40
TREX/BRWPLC1/MONEYMARKET/BRW/FCY|42
TREX/BRWPLC1/LOAN/PLC/LCY|84
TREX/BRWPLC1/LOAN/PLC/FCY|86
TREX/BRWPLC1/LOAN/BRW/LCY|76
TREX/BRWPLC1/LOAN/BRW/FCY|78
TREX/BRWPLC1/LOAN/|32
TREX/BRWPLC1|68
```
## #3
```
Id|ItemCode|ParentId|Path
--|--------|--------|----
2353|PLC|2349|TREX/BRWPLC1/TWR/PLC/
2350|BRW|2349|TREX/BRWPLC1/TWR/BRW/
2349|TWR|2334|TREX/BRWPLC1/TWR/
2346|PLC|2342|TREX/BRWPLC1/LOAN/PLC/
2343|BRW|2342|TREX/BRWPLC1/LOAN/BRW/
2342|LOAN|2334|TREX/BRWPLC1/LOAN/
2339|PLC|2335|TREX/BRWPLC1/MONEYMARKET/PLC/
2336|BRW|2335|TREX/BRWPLC1/MONEYMARKET/BRW/
2335|MONEYMARKET|2334|TREX/BRWPLC1/MONEYMARKET/
2334|BRWPLC1|0|TREX/BRWPLC1/
```
## #4
```
name
----
PrdProductDefinition
PrdProductDefinitionHistory
PrdProductDefinitionMarketMap
PrdProductTxn
TxnLoan
TxnMM
```

## #5
```
Id|Code|AccountingMapCode|MainProductCode|IsEnabled
--|----|-----------------|---------------|---------
11|Post-Financing|LOAN|MM|1
10|Securitization|LOAN|MM|1
9|Syndication|LOAN|MM|1
8|Gil|MONEYMARKET|MM|1
7|Pass|MONEYMARKET|MM|1
6|TermDeposit|TERMDEPOSIT|MM|0
5|Murabaha|LOAN|MM|1
4|Wakale|LOAN|MM|1
3|Issue|ISSUE|MM|1
2|Loan|LOAN|MM|1
1|MoneyMarket|MONEYMARKET|MM|1
```
## #6
```
Tbl|name
---|----
TxnLoan|ProductDefinitionId
TxnMM|TxnMmProductTypeId
```
## #7
```
Id|Source|TargetMainGL|Target|RuleId|Rule2Id|Rule3Id|Order|IsEnabled|Path
--|------|------------|------|------|-------|-------|-----|---------|----
23462|AccruedExpense|36001|36001020|12376|12349|NULL|10|1|TREX/BRWPLC1/LOAN/BRW/LCY
23461|InterestExpense|62401|62401120|12376|12349|NULL|100|1|TREX/BRWPLC1/LOAN/BRW/LCY
23460|InterestExpense|62400|62400120|12376|12349|NULL|10|1|TREX/BRWPLC1/LOAN/BRW/LCY
23459|InterestExpense|62401|62401020|12376|12349|NULL|100|1|TREX/BRWPLC1/LOAN/BRW/LCY
23458|InterestExpense|62400|62400020|12376|12349|NULL|10|1|TREX/BRWPLC1/LOAN/BRW/LCY
23457|InterestExpense|62201|62201120|12376|12349|NULL|100|1|TREX/BRWPLC1/LOAN/BRW/LCY
23456|InterestExpense|62200|62200120|12376|12349|NULL|10|1|TREX/BRWPLC1/LOAN/BRW/LCY
23455|InterestExpense|62201|62201020|12376|12349|NULL|100|1|TREX/BRWPLC1/LOAN/BRW/LCY
23454|InterestExpense|62200|62200020|12376|12349|NULL|10|1|TREX/BRWPLC1/LOAN/BRW/LCY
23453|InterestPaid|62401|62401120|12376|12349|NULL|100|1|TREX/BRWPLC1/LOAN/BRW/LCY
23452|InterestPaid|62400|62400120|12376|12349|NULL|10|1|TREX/BRWPLC1/LOAN/BRW/LCY
23451|InterestPaid|62401|62401020|12376|12349|NULL|100|1|TREX/BRWPLC1/LOAN/BRW/LCY
23450|InterestPaid|62400|62400020|12376|12349|NULL|10|1|TREX/BRWPLC1/LOAN/BRW/LCY
23449|InterestPaid|62201|62201120|12376|12349|NULL|100|1|TREX/BRWPLC1/LOAN/BRW/LCY
23448|InterestPaid|62200|62200120|12376|12349|NULL|10|1|TREX/BRWPLC1/LOAN/BRW/LCY
23447|InterestPaid|62201|62201020|12376|12349|NULL|100|1|TREX/BRWPLC1/LOAN/BRW/LCY
23446|InterestPaid|62200|62200020|12376|12349|NULL|10|1|TREX/BRWPLC1/LOAN/BRW/LCY
23445|AccruedExpense|36001|36001010|12377|12349|NULL|10|1|TREX/BRWPLC1/LOAN/BRW/LCY
23444|InterestExpense|62401|62401110|12377|12349|NULL|100|1|TREX/BRWPLC1/LOAN/BRW/LCY
23443|InterestExpense|62400|62400110|12377|12349|NULL|10|1|TREX/BRWPLC1/LOAN/BRW/LCY
```

## #8
```
Msg 156, Level 15, State 1, Server srv-mssql, Line 1
Incorrect syntax near the keyword 'Rule'.
```
## #9
```
ProductDefinitionId|Adet
-------------------|----
2|96
```
## #10
```
TxnMmProductTypeId|Adet
------------------|----
8|1
7|1
5|111
4|50
3|53
2|12
1|451
```

## #11
```
Id|Name|RuleText
--|----|--------
12377|Murabaha|TxnModel.ProductId === 5
12376|Wakala|TxnModel.ProductId === 4
12349|IsAccountNeeded = 1|TxnModel.IsAccountNeeded === true
```

## #12
```
Id|Code|AccountingMapCode|IsSameDay|IsZeroRate|IsIntraBank|IsCollateralized|IsGenerateFWDAccounting|IsAccountNeeded|IsBorrowing|IsPlacement
--|----|-----------------|---------|----------|-----------|----------------|-----------------------|---------------|-----------|-----------
11|Post-Financing|LOAN|0|0|0|0|0|1|1|1
10|Securitization|LOAN|0|0|0|0|0|1|1|1
9|Syndication|LOAN|0|0|0|0|0|1|1|1
8|Gil|MONEYMARKET|1|1|0|0|0|1|1|0
7|Pass|MONEYMARKET|1|1|0|0|0|1|1|1
6|TermDeposit|TERMDEPOSIT|0|0|0|0|0|1|1|1
5|Murabaha|LOAN|0|0|0|0|0|1|1|1
4|Wakale|LOAN|0|0|0|0|0|1|1|1
3|Issue|ISSUE|0|0|0|0|0|0|1|0
2|Loan|LOAN|0|0|0|0|0|1|1|1
1|MoneyMarket|MONEYMARKET|0|0|0|0|0|1|1|1
```

## #13
```
name|type|max_length
----|----|----------
Id|int|4
Schema|nvarchar|-1
Name|nvarchar|60
StateId|int|4
StateDate|datetime|8
StateMaker|nvarchar|160
```
## #14
```
Id|Name
--|----
175|Options V1 Accounting Model
174|asdasdasd
172|Issue Bond Accounting Model
171|Mm Tawarruq
170|Issue Model
164|Options V1
135|E2EMSSYQZX84MR
134|E2EMSSXKQBB1A6
133|E2EMSSXJVYJ5EA
132|E2EMSSU9ZDH32Y
131|E2EMSSU9E684ZL
130|E2EMSST7NEC5SQ
129|E2EMSST6AK81P7
128|E2EMSSMSUVA4GP
127|E2EMSSMS2EB6B7
126|TESTCODE
123|Borrowing & Placement V1
122|Investment Fund Model
121|BankPortfolioFundAccounting
119|Derivative Swap
```

## #15
```
Id|Name|SchemaLen|PosProductId|PosIsAccountNeeded|PosFundSource|PosTxnReference|Head
--|----|---------|------------|------------------|-------------|---------------|----
123|Borrowing & Placement V1|2289|0|0|0|0|{"type":"object","additionalProperties":true,"properties":{"MaturityDate":{"title":"Maturity Date","type":["string","null"],"format":"date-time"},"CCY":{"title":"Currency","type":["string","null"]},"LocalCCY":{"title":"Local Currency","type":["string","nul
```
