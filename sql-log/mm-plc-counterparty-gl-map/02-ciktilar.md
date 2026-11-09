# 02-ciktilar — mm-plc-counterparty-gl-map

DB: NetTrexAcc @192.168.10.211 (sqlcmd, salt-okunur). Çıktılar ham.

## #1
```
Id|Source|Path|Order|Target|IsEnabled|StateId|RuleId|Rule2Id|Rule3Id|Rule4Id|Rule5Id|Rule6Id|Rule7Id|Rule8Id|Rule9Id|Rule10Id
12383990|CounterPartyGLAccount|TREX/BRWPLC1/MONEYMARKET/PLC/LCY|10|0400000000|1|18|12378|12349|12661|12355|NULL|NULL|NULL|NULL|NULL|NULL
12383989|CounterPartyGLAccount|TREX/BRWPLC1/MONEYMARKET/PLC/LCY|60|0220150000|1|18|NULL|12349|12661|12355|12351|NULL|NULL|12359|12662|NULL
12383988|...|50|0220140000|1|18|NULL|12349|12661|12355|12351|NULL|NULL|12359|12364|NULL
12383987|...|40|0220130000|1|18|NULL|12349|12661|12355|12351|NULL|NULL|12359|12363|NULL
12383986|...|30|0220120000|1|18|NULL|12349|12661|12355|12351|NULL|NULL|12359|12362|NULL
12383985|...|20|0220110000|1|18|NULL|12349|12661|12355|12351|NULL|NULL|12359|12361|NULL
12383984|...|10|0220100000|1|18|NULL|12349|12661|12355|12351|NULL|NULL|12359|12360|NULL
12383983|CounterPartyGLAccount|TREX/BRWPLC1/MONEYMARKET/PLC/LCY|10||1|18|NULL|12349|12660|NULL|NULL|NULL|NULL|NULL|NULL|NULL
```
(satır 4-7'de Source/Path #1 ile aynı, kısaltıldı)

## #3
```
Id, Name, Rule, Type, Description, StateId, StateDate, StateMaker
```

## #4
```
Id|Name|Type|StateId|Rule
12661|UseExternalGLAccount = 0|0|18|TxnModel.UseExternalGLCode === false
12660|UseExternalGLAccount = 1|0|18|TxnModel.UseExternalGLCode === true
12378|Pas|0|18|TxnModel.ProductId === 7
12360|Kamu Mevduat Bankalari|0|18|TxnModel.CorporateDetailType === 33
12359|Mali Kesim|0|18|TxnModel.CorporateType === 4
12355|Market = OTC|0|18|TxnModel.MarketCode === 'OTC'
12351|Customer Location = DOM|0|18|TxnModel.CustomerLocation === 'DOM'
12349|IsAccountNeeded = 1|0|18|TxnModel.IsAccountNeeded === true
```

## #5
```
Id|Name|StateId|Rule
--|----|-------|----
12661|UseExternalGLAccount = 0|18|TxnModel.UseExternalGLCode === false
12660|UseExternalGLAccount = 1|18|TxnModel.UseExternalGLCode === true
12348|UseExternalGLAccount = 0|18|TxnModel.UseExternalGLAccount === false
12347|UseExternalGLAccount = 1|18|TxnModel.UseExternalGLAccount === true
```

## #6
```
Source|Path|Adet
------|----|----
CounterPartyGLAccount|TREX/BRWPLC1/LOAN/PLC/LCY|27
CounterPartyGLAccount|TREX/BRWPLC1/LOAN/PLC/FCY|27
CounterPartyGLAccount|TREX/BRWPLC1/LOAN/BRW/LCY|17
CounterPartyGLAccount|TREX/BRWPLC1/LOAN/BRW/FCY|17
CounterPartyGLAccount|TREX/BRWPLC1/MONEYMARKET/PLC/LCY|8
CounterPartyGLAccount|TREX/BRWPLC1/MONEYMARKET/PLC/FCY|8
CounterPartyGLAccount|TREX/BRWPLC1/MONEYMARKET/BRW/LCY|3
CounterPartyGLAccount|TREX/BRWPLC1/MONEYMARKET/BRW/FCY|3
```

## #7
```
12383983|NULL|NULL|NULL|12349|12660|NULL|NULL|NULL|NULL|NULL|NULL|NULL|CounterPartyGLAccount|TREX/BRWPLC1/MONEYMARKET/PLC/LCY|||12373|1|10||11144|12372|18|SYSTEM|2026-10-26 10:12:38.700|NULL|NULL|NULL
```

## #8
```
Id,Ccy,CustomerId,RuleId,Rule2Id,Rule3Id,Rule4Id,Rule5Id,Rule6Id,Rule7Id,Rule8Id,Rule9Id,Rule10Id,Source,Path,TargetMainGL,Target,TargetRuleId,IsEnabled,Order,Description,CustomerCodeSourceRuleId,CustomerAccountCodeSourceRuleId,StateId,StateMaker,StateDate,CustomerAccountWorkGroupCodeSourceRuleId,CustomerAccountBranchCodeSourceRuleId,CustomerAccountTypeCodeSourceRuleId,```

## #9
```
Id|Name|Type|StateId|Rule
--|----|----|-------|----
12373|ExternalGLAccount|1|18|TxnModel.ExternalGLAccount
12372|ExternalAccountNo|1|18|TxnModel.ExternalAccountNo
11144|ExternalCustomerNo|1|18|TxnModel.ExternalCustomerNo
```

## #10
```
Tbl|Id|LogicalReference|StateId|GLCode
---|--|----------------|-------|------
TxnMM|553446|TMRBRW2610260008|18|32801000
Tbl|Id|LogicalReference|StateId|GLCode
---|--|----------------|-------|------
```

## #11
```
Id|AccEntryMainId|DebitCredit|Amount|GLCode|CustomerCode|CustomerAccountCode|AccAccountMapId|Source
--|--------------|-----------|------|------|------------|-------------------|---------------|------
5512896|556231|Credit|50000000.0000000000|CounterPartyGLAccount|NULL|NULL|NULL|NULL
5512895|556231|Debit|50000000.0000000000|2809900011|NULL|NULL|12384314|IncomingPaymentLCY
```

## #12
```
Id|Order|Target|TargetRuleId|StateId|RuleId|Rule2Id|Rule3Id|Rule4Id|Rule5Id|Rule6Id|Rule7Id|Rule8Id|Rule9Id|Rule10Id
--|-----|------|------------|-------|------|-------|-------|-------|-------|-------|-------|-------|-------|--------
12383979|10|3380000000|NULL|18|12379|12349|12661|NULL|NULL|NULL|NULL|NULL|NULL|NULL
12383978|10|3380000000|NULL|18|12378|12349|12661|NULL|NULL|NULL|NULL|NULL|NULL|NULL
12383977|10||12373|18|NULL|12349|12660|NULL|NULL|NULL|NULL|NULL|NULL|NULL
```

## #13
```
Id|TxnMmProductTypeId|TxnTypeCode|MarketCode|CustomerLocation|Code|IsUseTxnGLCode|IsAccountNeeded
--|------------------|-----------|----------|----------------|----|--------------|---------------
553446|5|BRW|OTC|DOM|Murabaha|0|1
```

## #12 (yanlış path: MONEYMARKET)
#12/#13 çıktıları yukarıdaki komut çıktısından: #12 = 12383979/78 (ProductId 8/7 + UseExt=0, Target 3380000000), 12383977 (UseExt=1, TargetRule 12373); #13 = TxnMM 553446: ProductTypeId 5, BRW, OTC, DOM, Murabaha, IsUseTxnGLCode 0, IsAccountNeeded 1

## #14
```
Id|Order|Target|TargetRuleId|Kurallar
--|-----|------|------------|--------
12384005|10||12373|TxnModel.IsAccountNeeded === true && TxnModel.UseExternalGLCode === true
12384006|10|3420000000|NULL|TxnModel.IsAccountNeeded === true && TxnModel.CustomerLocation === 'DOM' && TxnModel.TermCode === 'SHORT' && TxnModel.MarketCode === 'OTC' && TxnModel.CorporateType === 4 && [33,34,35,36,37,38,39,40].includes(TxnModel.CorporateDetailType) && TxnModel.Produ
12384008|10|3421000000|NULL|TxnModel.IsAccountNeeded === true && TxnModel.CustomerLocation === 'DOM' && TxnModel.TermCode === 'LONG' && TxnModel.MarketCode === 'OTC' && TxnModel.CorporateType === 4 && [33,34,35,36,37,38,39,40].includes(TxnModel.CorporateDetailType) && TxnModel.Produc
12384010|10|3480020000|NULL|TxnModel.IsAccountNeeded === true && TxnModel.CustomerLocation === 'FRGN' && TxnModel.TermCode === 'SHORT' && TxnModel.MarketCode === 'OTC' && TxnModel.CorporateType === 4 && TxnModel.CorporateDetailType === 43 && TxnModel.ProductId === 4 && TxnModel.UseEx
12384011|10|3481020000|NULL|TxnModel.IsAccountNeeded === true && TxnModel.CustomerLocation === 'FRGN' && TxnModel.TermCode === 'LONG' && TxnModel.MarketCode === 'OTC' && TxnModel.CorporateType === 4 && TxnModel.CorporateDetailType === 43 && TxnModel.ProductId === 4 && TxnModel.UseExt
12384012|10|3420000000|NULL|TxnModel.IsAccountNeeded === true && TxnModel.CustomerLocation === 'DOM' && TxnModel.TermCode === 'SHORT' && TxnModel.MarketCode === 'OTC' && TxnModel.CorporateType === 4 && [33,34,35,36,37,38,39,40].includes(TxnModel.CorporateDetailType) && TxnModel.Produ
12384014|10|3421000000|NULL|TxnModel.IsAccountNeeded === true && TxnModel.CustomerLocation === 'DOM' && TxnModel.TermCode === 'LONG' && TxnModel.MarketCode === 'OTC' && TxnModel.CorporateType === 4 && [33,34,35,36,37,38,39,40].includes(TxnModel.CorporateDetailType) && TxnModel.Produc
12384016|10|3480090000|NULL|TxnModel.IsAccountNeeded === true && TxnModel.CustomerLocation === 'FRGN' && TxnModel.TermCode === 'SHORT' && TxnModel.MarketCode === 'OTC' && TxnModel.CorporateType === 4 && TxnModel.CorporateDetailType === 43 && TxnModel.ProductId === 5 && TxnModel.UseEx
12384017|10|3481090000|NULL|TxnModel.IsAccountNeeded === true && TxnModel.CustomerLocation === 'FRGN' && TxnModel.TermCode === 'LONG' && TxnModel.MarketCode === 'OTC' && TxnModel.CorporateType === 4 && TxnModel.CorporateDetailType === 43 && TxnModel.ProductId === 5 && TxnModel.UseExt
12384018|10|3460000000|NULL|TxnModel.IsAccountNeeded === true && TxnModel.CustomerLocation === 'DOM' && TxnModel.TermCode === 'LONG' && TxnModel.MarketCode === 'OTC' && TxnModel.CorporateType === 4 && [33,34,35,36,37,38,39,40].includes(TxnModel.CorporateDetailType) && TxnModel.UseExt
12384020|10|3460002000|NULL|TxnModel.IsAccountNeeded === true && TxnModel.CustomerLocation === 'FRGN' && TxnModel.TermCode === 'LONG' && TxnModel.MarketCode === 'OTC' && TxnModel.CorporateType === 4 && TxnModel.CorporateDetailType === 43 && TxnModel.UseExternalGLCode === false && Txn
12384007|20|3440000000|NULL|TxnModel.IsAccountNeeded === true && TxnModel.CustomerLocation === 'DOM' && TxnModel.TermCode === 'SHORT' && TxnModel.MarketCode === 'OTC' && TxnModel.ProductId === 4 && TxnModel.UseExternalGLCode === false
12384009|20|3441000000|NULL|TxnModel.IsAccountNeeded === true && TxnModel.CustomerLocation === 'DOM' && TxnModel.TermCode === 'LONG' && TxnModel.MarketCode === 'OTC' && TxnModel.ProductId === 4 && TxnModel.UseExternalGLCode === false
12384013|20|3440000000|NULL|TxnModel.IsAccountNeeded === true && TxnModel.CustomerLocation === 'DOM' && TxnModel.TermCode === 'SHORT' && TxnModel.MarketCode === 'OTC' && TxnModel.ProductId === 5 && TxnModel.UseExternalGLCode === false
12384015|20|3441000000|NULL|TxnModel.IsAccountNeeded === true && TxnModel.CustomerLocation === 'DOM' && TxnModel.TermCode === 'LONG' && TxnModel.MarketCode === 'OTC' && TxnModel.ProductId === 5 && TxnModel.UseExternalGLCode === false
12384019|20|3460001000|NULL|TxnModel.IsAccountNeeded === true && TxnModel.CustomerLocation === 'DOM' && TxnModel.TermCode === 'LONG' && TxnModel.MarketCode === 'OTC' && TxnModel.UseExternalGLCode === false && TxnModel.ProductId === 15
12384021|20|3460003000|NULL|TxnModel.IsAccountNeeded === true && TxnModel.CustomerLocation === 'FRGN' && TxnModel.TermCode === 'LONG' && TxnModel.MarketCode === 'OTC' && TxnModel.UseExternalGLCode === false && TxnModel.ProductId === 15
```

## #15
```
Id|Code|Name|Description|ExternalCode|IsEnabled|IsFinancialInstitutionCompatible
--|----|----|-----------|------------|---------|--------------------------------
4|A2AD|Customer Account to Account|NULL|AccountToAccountDeposit|1|0
3|Vostro|Vostro Account|NULL|AccountToAccountVostro|1|1
2|A2A|Account to Account|NULL|AccountToAccountNostro|1|1
1|B2B|Bank to Bank|NULL|BankToBank|1|1
Id|Code|Name|Description|ExternalCode|IsEnabled
--|----|----|-----------|------------|---------
2|Netting|Net Settlement|NULL|Bulk|1
1|Gross|Gross Settlement|NULL|Single|1
```
