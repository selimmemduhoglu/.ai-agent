# SQL Log — il-reeskont-urun-ekran — Çıktılar

## Çıktı #1 (ham)

```
RateTypeId|InterestMethodId|IsMatured|Adet
1|1|0|71
1|1|1|3
2|1|0|1
2|2|0|20
2|2|1|1
```
Yorum: sabit faizli (RateType 1) IL işlemlerinin **hepsi** InterestMethod=1 (SimpleInterest). Açık işlem: 71 sabit+Simple, 1 değişken+Simple, 20 değişken+Compound.

## Çıktı #2 (ham)

```
Id|TxnId|CalculationDate|RateTypeId|InterestMethodId|PrincipalAmount|PeriodAccrualAmountSL|PeriodAccrualAmountIRR|TotalAmountNPV|PrincipalAmountNPV|AccEntryMainId
208|1201155|2026-06-18|1|1|60000.0000000000|355.0700000000|355.0700000000|60273.9800000000|59918.9100000000|555481
207|1201149|2026-06-18|1|1|20000.0000000000|72.3300000000|72.1000000000|18150.7000000000|18078.3700000000|555480
206|1201078|2026-06-15|1|1|100000.0000000000|1674.5800000000|1660.5600000000|94751.3500000000|93076.7700000000|555463
204|1201135|2026-06-12|1|1|100000.0000000000|27.4000000000|27.3900000000|99676.9100000000|99649.5100000000|555454
203|1201134|2026-06-12|1|1|1000000.0000000000|273.9700000000|273.9000000000|996769.1200000000|996495.1500000000|555453
202|1201133|2026-06-12|1|1|100000.0000000000|27.4000000000|27.3900000000|99676.9100000000|99649.5100000000|555452
201|1201078|2026-06-12|1|1|100000.0000000000|1592.2200000000|1578.2500000000|94348.6900000000|92756.4700000000|555451
200|1201136|2026-06-12|2|2|1000000.0000000000|1345.2900000000|612723.0200000000|1067975.6900000000|1066630.4000000000|555443
195|1201075|2026-06-12|1|1|80000.0000000000|9997.0200000000|9368.1700000000|92542.0900000000|82545.0700000000|555438
194|1201073|2026-06-12|1|1|80000.0000000000|4997.2600000000|4830.4900000000|82775.3900000000|77778.1300000000|555437
```

## Çıktı #3 (ham)

```
Id|AccEntryMainId|TxnId|GLCode|Amount
5511176|555481|1201155|36001000|60273.9800000000
5511175|555481|1201155|62201000|60273.9800000000
5511174|555480|1201149|36001000|18150.7000000000
5511173|555480|1201149|62201000|18150.7000000000
5511140|555463|1201078|36001000|94751.3500000000
5511139|555463|1201078|62200000|94751.3500000000
5511120|555454|1201135|36001000|99676.9100000000
5511119|555454|1201135|62200000|99676.9100000000
5511118|555453|1201134|36001000|996769.1200000000
5511117|555453|1201134|62200000|996769.1200000000
```
Yorum: fiş tutarı **birebir `TotalAmountNPV`** (60273.98 = #2 satır 208). SL/IRR fişe gitmiyor → kod tespiti doğrulandı.
## Çıktı #4 (ham)
```
Sqlcmd: The -W and the -y/-Y options are mutually exclusive.
```

## Çıktı #5 (ham)
```
Sqlcmd: The -W and the -y/-Y options are mutually exclusive.
```

## Çıktı #6 (ham)
```
Sqlcmd: The -W and the -y/-Y options are mutually exclusive.
```

## Çıktı #7 (ham)
```
Tbl|column_id|name|type|max_length|precision|scale|is_nullable|is_identity
---|---------|----|----|----------|---------|-----|-----------|-----------
PrdProductDefinition|1|Id|int|4|10|0|0|0
PrdProductDefinition|2|Code|nvarchar|100|0|0|0|0
PrdProductDefinition|3|Name|nvarchar|100|0|0|0|0
PrdProductDefinition|4|AccountingMapCode|nvarchar|100|0|0|0|0
PrdProductDefinition|5|MainProductCode|nvarchar|100|0|0|0|0
PrdProductDefinition|6|ExternalMainProductCode|nvarchar|100|0|0|0|0
PrdProductDefinition|7|UseFundSource|bit|1|1|0|0|0
PrdProductDefinition|8|UseSubFundSource|bit|1|1|0|0|0
PrdProductDefinition|9|UseOnUnitValue|bit|1|1|0|0|0
PrdProductDefinition|10|IsBorrowing|bit|1|1|0|0|0
PrdProductDefinition|11|IsPlacement|bit|1|1|0|0|0
PrdProductDefinition|12|IsAccountNeeded|bit|1|1|0|0|0
PrdProductDefinition|13|IsAllowRollover|bit|1|1|0|0|0
PrdProductDefinition|14|IsAllowBrokerage|bit|1|1|0|0|0
PrdProductDefinition|15|IsMultiplePayment|bit|1|1|0|0|0
PrdProductDefinition|16|IsTaxApplicable|bit|1|1|0|0|0
PrdProductDefinition|17|IsUseTxnGLCode|bit|1|1|0|0|0
PrdProductDefinition|18|IsCollateralized|bit|1|1|0|0|0
PrdProductDefinition|19|IsIntraBank|bit|1|1|0|0|0
PrdProductDefinition|20|IsSameDay|bit|1|1|0|0|0
PrdProductDefinition|21|IsZeroRate|bit|1|1|0|0|0
PrdProductDefinition|22|IsGenerateFWDAccounting|bit|1|1|0|0|0
PrdProductDefinition|23|IsDefaultProduction|bit|1|1|0|0|0
PrdProductDefinition|24|AccountSelectionTypeId|int|4|10|0|0|0
PrdProductDefinition|25|AccountingCalculationMethodTypeId|int|4|10|0|0|0
PrdProductDefinition|26|Order|int|4|10|0|0|0
PrdProductDefinition|27|IsEnabled|bit|1|1|0|0|0
PrdProductDefinition|28|StateId|int|4|10|0|0|0
PrdProductDefinition|29|StateMaker|nvarchar|160|0|0|1|0
PrdProductDefinition|30|StateDate|datetime|8|23|3|0|0
PrdProductDefinition|31|ExternalSubProductCode|nvarchar|100|0|0|0|0
PrdProductDefinition|32|LogicalReferenceTypeId|int|4|10|0|0|0
PrdProductDefinition|33|IsMarketCommissionApplicable|bit|1|1|0|0|0
PrdProductDefinition|34|IsAllowTawarruq|bit|1|1|0|0|0
PrdProductDefinitionHistory|1|HistoryId|int|4|10|0|0|1
PrdProductDefinitionHistory|2|Id|int|4|10|0|0|0
PrdProductDefinitionHistory|3|Code|nvarchar|100|0|0|0|0
PrdProductDefinitionHistory|4|Name|nvarchar|100|0|0|0|0
PrdProductDefinitionHistory|5|AccountingMapCode|nvarchar|100|0|0|0|0
PrdProductDefinitionHistory|6|MainProductCode|nvarchar|100|0|0|0|0
PrdProductDefinitionHistory|7|ExternalMainProductCode|nvarchar|100|0|0|0|0
PrdProductDefinitionHistory|8|UseFundSource|bit|1|1|0|0|0
PrdProductDefinitionHistory|9|UseSubFundSource|bit|1|1|0|0|0
PrdProductDefinitionHistory|10|UseOnUnitValue|bit|1|1|0|0|0
PrdProductDefinitionHistory|11|IsBorrowing|bit|1|1|0|0|0
PrdProductDefinitionHistory|12|IsPlacement|bit|1|1|0|0|0
PrdProductDefinitionHistory|13|IsAccountNeeded|bit|1|1|0|0|0
PrdProductDefinitionHistory|14|IsAllowRollover|bit|1|1|0|0|0
PrdProductDefinitionHistory|15|IsAllowBrokerage|bit|1|1|0|0|0
PrdProductDefinitionHistory|16|IsMultiplePayment|bit|1|1|0|0|0
PrdProductDefinitionHistory|17|IsTaxApplicable|bit|1|1|0|0|0
PrdProductDefinitionHistory|18|IsUseTxnGLCode|bit|1|1|0|0|0
PrdProductDefinitionHistory|19|IsCollateralized|bit|1|1|0|0|0
PrdProductDefinitionHistory|20|IsIntraBank|bit|1|1|0|0|0
PrdProductDefinitionHistory|21|IsSameDay|bit|1|1|0|0|0
PrdProductDefinitionHistory|22|IsZeroRate|bit|1|1|0|0|0
PrdProductDefinitionHistory|23|IsGenerateFWDAccounting|bit|1|1|0|0|0
PrdProductDefinitionHistory|24|IsDefaultProduction|bit|1|1|0|0|0
PrdProductDefinitionHistory|25|AccountSelectionTypeId|int|4|10|0|0|0
PrdProductDefinitionHistory|26|AccountingCalculationMethodTypeId|int|4|10|0|0|0
PrdProductDefinitionHistory|27|Order|int|4|10|0|0|0
PrdProductDefinitionHistory|28|IsEnabled|bit|1|1|0|0|0
PrdProductDefinitionHistory|29|StateId|int|4|10|0|0|0
PrdProductDefinitionHistory|30|StateMaker|nvarchar|160|0|0|1|0
PrdProductDefinitionHistory|31|StateDate|datetime|8|23|3|0|0
PrdProductDefinitionHistory|32|ExternalSubProductCode|nvarchar|100|0|0|0|0
PrdProductDefinitionHistory|33|LogicalReferenceTypeId|int|4|10|0|0|0
PrdProductDefinitionHistory|34|IsMarketCommissionApplicable|bit|1|1|0|0|0
PrdProductDefinitionHistory|35|IsAllowTawarruq|bit|1|1|0|1|0
```

## Çıktı #8 (ham)
```
PrdProductDefinitionTrigger|0|
CREATE TRIGGER [dbo].[PrdProductDefinitionTrigger]
ON [dbo].[PrdProductDefinition]
FOR INSERT, UPDATE
AS
INSERT INTO [dbo].[prdProductDefinitionHistory] SELECT * FROM inserted;
```

## Çıktı #9 (ham)
```
Id|Code|IsSameDay|IsZeroRate|IsEnabled|StateId
--|----|---------|----------|---------|-------
15|Subordinated-Loan|0|0|1|26
14|Mudaraba|0|0|1|18
13|CD|0|0|1|18
12|OMF|0|0|1|18
11|Post-Financing|0|0|1|18
10|Securitization|0|0|1|18
9|Syndication|0|0|1|18
8|Gil|1|1|1|18
7|Pass|1|1|1|18
6|TermDeposit|0|0|0|18
5|Murabaha|0|0|1|26
4|Wakale|0|0|1|26
3|Issue|0|0|1|18
2|Loan|0|0|1|26
1|MoneyMarket|0|0|1|26
```

## Çıktı #10 (ham)
```
Id|TxnId|ValueDate|IsReverse|ReverseId|RevId|RevValueDate|RevIsReverse
--|-----|---------|---------|---------|-----|------------|------------
555481|1201155|2026-06-18|0|555482|555482|2026-06-19|1
555480|1201149|2026-06-18|0|0|NULL|NULL|NULL
555463|1201078|2026-06-15|0|0|NULL|NULL|NULL
555454|1201135|2026-06-12|0|555460|555460|2026-06-15|1
555453|1201134|2026-06-12|0|555459|555459|2026-06-15|1
```

## Çıktı #11 (ham)
```
AccountingCalculationMethodTypeId|InterestMethodId|RateTypeId|Adet
---------------------------------|----------------|----------|----
2|1|1|71
2|1|2|1
2|2|2|20
```

## Çıktı #12 (ham)
```
AmortismanliAcikIslem
---------------------
5
```

## Çıktı #13 (ham)
```
TxnMethod|CashFlowMethod|Islem
---------|--------------|-----
1|1|70
2|1|1
2|2|18
```
