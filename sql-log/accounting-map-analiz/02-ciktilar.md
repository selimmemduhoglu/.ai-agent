# 02-ciktilar — accounting-map-analiz

DB: NetTrexAcc @192.168.10.211 (sqlcmd, salt-okunur). Çıktılar ham.

## #1
```
Source|Path|Order|Adet
------|----|-----|----
CounterPartyGLAccount|TREX/BRWPLC1/LOAN/PLC/FCY|10|25
CounterPartyGLAccount|TREX/BRWPLC1/LOAN/PLC/LCY|10|25
CouponAssetAmount|TREX/SEC1|10|18
CouponAssetAmount|TREX/SEC1|15|18
CouponAssetAmount|TREX/SEC1|999|18
MaturityAssetAmount|TREX/SEC1|10|18
MaturityAssetAmount|TREX/SEC1|15|18
MaturityAssetAmount|TREX/SEC1|999|18
MTM|TREX/SEC1|10|14
MTM|TREX/SEC1|15|14
MTM|TREX/SEC1|20|14
MTM|TREX/SEC1|25|14
MTM|TREX/SEC1|30|14
CounterPartyGLAccount|TREX/BRWPLC1/LOAN/BRW/FCY|10|13
CounterPartyGLAccount|TREX/BRWPLC1/LOAN/BRW/LCY|10|13
AccrualPnL|TREX/SEC1|25|12
AccrualPnL|TREX/SEC1|20|12
AccrualPnL|TREX/SEC1|15|12
AccrualPnL|TREX/SEC1|999|12
AmortizationPnL|TREX/SEC1|15|12
```

## #2
```
Sekil|Adet
-----|----
slash-siz|3737
slash-sonlu|228
NULL|16
```

## #3
```
Tip|Adet|MinOrder|MaxOrder
---|----|--------|--------
kurali|3311|0|1100
kuralsiz|670|10|10
```

## #4
```
Ccy_Durum|Adet
---------|----
dolu|14
NULL|3967
```

## #5
```
ZincirliSatir
-------------
34
```

## #6
İlk çalıştırmada çıktı yazılamadı (yol hatası); aynı sorgu tekrar çalıştırıldı.
```
StateId|Adet
-------|----
18|3885
26|93
22|2
25|1
```

## #7
```
GolgelenenKuralliSatir
----------------------
0
```

## #8
```
Id|Source|Ccy|Path|Target|Order
--|------|---|----|------|-----
12376128|NULL|AED|NULL|NULL|NULL
11569|FXPositionLCY|XAG|NULL|28400200|40
11568|FXPositionLCY|XAU|NULL|28400100|30
11567|FXPositionLCY|EUR|NULL|29400200|20
11566|FXPositionLCY|USD|NULL|29400100|10
11565|FXPosition|XAG|NULL|28500000 |40
11564|FXPosition|XAU|NULL|28500000 |30
11563|FXPosition|EUR|NULL|29500000|20
11562|FXPosition|USD|NULL|29500000|10
6|29400|GBP|NULL|29400300|0
5|29400|EUR|NULL|29400200|0
4|29400|USD|NULL|29400100|0
2|28400|XAG|NULL|28400200|0
1|28400|XAU|NULL|28400100|0
```

## #9
```
Id|Source|Path|Order|Target|TargetRuleId|RuleId|Rule2Id|Rule3Id|Rule4Id|Rule5Id|Rule6Id|Rule7Id|Rule8Id|Rule9Id|Rule10Id|StateId
--|------|----|-----|------|------------|------|-------|-------|-------|-------|-------|-------|-------|-------|--------|-------
23253|FxPositionLCY|TREX/BRWPLC1/MONEYMARKET/BRW/FCY|10|29400|NULL|NULL|NULL|NULL|NULL|NULL|NULL|NULL|NULL|NULL|NULL|18
```

## #10
TOP (20) ile kırpıldı; Ccy kolonu sqlcmd -W genişliği yüzünden `NUL` görünüyor (değer NULL).
```
Id|Source|Path|Order|Ccy|Target
--|------|----|-----|---|------
26348|FxPositionLCY|TREX/OPT1/FX/SELL/PUT/PMFCY|10|NUL|29400
26329|FxPositionLCY|TREX/OPT1/FX/SELL/PUT/FCYPM|10|NUL|29400
26306|FxPositionLCY|TREX/OPT1/FX/SELL/PUT/PMLCY|10|NUL|29400
26280|FxPositionLCY|TREX/OPT1/FX/SELL/PUT/LCYPM|10|NUL|29400
26258|FxPositionLCY|TREX/OPT1/FX/SELL/PUT/FCYFCY|10|NUL|29400
26235|FxPositionLCY|TREX/OPT1/FX/SELL/PUT/FCYLCY|10|NUL|29400
26209|FxPositionLCY|TREX/OPT1/FX/SELL/PUT/LCYFCY|10|NUL|29400
26187|FxPositionLCY|TREX/OPT1/FX/SELL/CALL/PMFCY|10|NUL|29400
26168|FxPositionLCY|TREX/OPT1/FX/SELL/CALL/FCYPM|10|NUL|29400
26145|FxPositionLCY|TREX/OPT1/FX/SELL/CALL/PMLCY|10|NUL|29400
26119|FxPositionLCY|TREX/OPT1/FX/SELL/CALL/LCYPM|10|NUL|29400
26097|FxPositionLCY|TREX/OPT1/FX/SELL/CALL/FCYFCY|10|NUL|29400
26074|FxPositionLCY|TREX/OPT1/FX/SELL/CALL/FCYLCY|10|NUL|29400
26048|FxPositionLCY|TREX/OPT1/FX/SELL/CALL/LCYFCY|10|NUL|29400
26026|FxPositionLCY|TREX/OPT1/FX/BUY/PUT/PMFCY|10|NUL|29400
26007|FxPositionLCY|TREX/OPT1/FX/BUY/PUT/FCYPM|10|NUL|29400
25984|FxPositionLCY|TREX/OPT1/FX/BUY/PUT/PMLCY|10|NUL|29400
25958|FxPositionLCY|TREX/OPT1/FX/BUY/PUT/LCYPM|10|NUL|29400
25936|FxPositionLCY|TREX/OPT1/FX/BUY/PUT/FCYFCY|10|NUL|29400
25913|FxPositionLCY|TREX/OPT1/FX/BUY/PUT/FCYLCY|10|NUL|29400
```
