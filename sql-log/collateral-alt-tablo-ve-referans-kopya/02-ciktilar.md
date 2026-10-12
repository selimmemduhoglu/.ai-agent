# SQL Çıktıları — collateral-alt-tablo-ve-referans-kopya

Tarih: 2026-10-02 · DB: `NetTrexMM` @ `192.168.10.211`

---

## 1 — Prd*/Def* ailesinde `Id` kolonu IDENTITY mi?

```
TableName                     |DataType|is_identity
DefAmountSlab                 |int|1
DefCashflow                   |int|1
DefCorporateDetailType        |int|0
DefCorporateType              |int|0
DefExternalReferenceSource    |int|0
DefFundSource                 |int|0
DefJobCron                    |int|1
DefJobCronHistory             |int|0
DefLegalVehicle               |int|0
DefLocation                   |int|0
DefNotification               |int|1
DefNotificationTemplate       |int|1
PrdAccountSelectionType       |int|0
PrdInstrument                 |int|0
PrdProductDefinition          |int|0
PrdProductDefinitionHistory   |int|0
PrdProductDefinitionMarketMap |int|0
```

🔑 `PrdProductDefinitionMarketMap.Id` **IDENTITY DEĞİL** (is_identity = 0).

## 2 — `Id` kolonu IDENTITY olmayan tablolar (65 / 125)

İlk 50 + kalan 15 (birleşik liste):
AccEftAccount, AccEngineGeneratedAccountRule, AccEntry, AccEntryMain, AccEntryType,
AccountingCalculationMethodType, AmortizationConfigurationHistory, BatchItem, BatchSet, Calendar,
Chart, CusCustomer, DefCorporateDetailType, DefCorporateType, DefExternalReferenceSource,
DefFundSource, DefJobCronHistory, DefLegalVehicle, DefLocation, ExternalCustomerMap, ExternalUserMap,
FloatingRateType, FlowTransitionData, FlowType, FXRate, FXRateDetail, HalfWorkingDay, Holiday,
InterestMethod, InterestMethodFrequency, InterestRate, InterestRateDetail, LogicalReferenceType,
MarketCustomerMap, MDL_BANK_LOAN_DEPOSITS, MDL_CREDITS, MDL_CREDITS_CLS, Message, PaymentFrequency,
PaymentInstructionType, Point, PrdAccountSelectionType, PrdInstrument, PrdProductDefinition,
PrdProductDefinitionHistory, PrdProductDefinitionMarketMap, PrfPortfolio, RateSource, RateType,
RolloverType, Server, SettlementType, TaxRate, TaxRule, TaxTax, Term, TxnCashFlowHistory,
TxnDocumentHistory, TxnLoan, TxnLoanHistory, TxnMM, TxnMMHistory, TxnNoteHistory, TxnTawarruq,
TxnTawarruqHistory

```
NonIdentityIdTables = 65
IdentityIdTables    = 34
ToplamTablo         = 125
```

## 6/7 — `PrdProductDefinitionMarketMap` ve `PrdProductDefinition` Id dizilimi

```
Id  |ProductDefinitionId|MarketCode|IsDefaultMarket|Order|IsEnabled
1032|11|OTC  |1|10|1
1031|10|OTC  |1|10|1
1030| 9|OTC  |1|10|1
1029| 5|TCMB |0|40|0
1028| 5|TAKAS|0|30|0
1027| 5|OTC  |1|10|1
1026| 5|BIST |0|10|0
1025| 1|TAKAS|0|30|1
1024| 1|TCMB |0|20|1
1023| 1|BIST |0|40|1
1022| 1|OTC  |1|10|1
 129| 8|OTC  |0|20|0
 128| 8|TCMB |1|10|1
 127| 7|OTC  |1|10|1
 126| 6|OTC  |1|10|1
 125| 3|OTC  |1|10|1
 124| 2|OTC  |1|10|1
 123| 4|OTC  |1|10|1

MapSatirSayisi=18  MinId=123  MaxId=1032
PrdSatir=11        MinId=1    MaxId=11
```

🔑 `MaxId = 1032` = `DefNumberGen.LastNumber` ('Product Definition Market Map Id') → sayaç **canlı ve
fiilen kullanılıyor**. Buna karşılık `PrdProductDefinition` Id'leri 1..11 iken sayacı **999** →
o sayaç **ölü** (kodda çağrısı yorumda).

## 4/5 — NetTrexCommon ↔ NetTrexMM kopya tablolar (prefix normalize edilmiş eşleşme + satır sayısı)

```
MMTablo                |CommonTablo          |MMSatir
BatchItem              |BatchItem            |35
BatchLog               |BatchLog             |1687
BatchLogDetail         |BatchLogDetail       |41401
BatchSet               |BatchSet             |5
Branch                 |Branch               |69
Calendar               |Calendar             |160770
Chart                  |Chart                |77
Currency               |Currency             |56
CurrencyPair           |CurrencyPair         |90
CusCustomer            |Customer             |111
CusSIC                 |SIC                  |513
DefAccrual             |Accrual              |3
DefAmortization        |Amortization         |2
DefAmountSlab          |AmountSlab           |3
DefBitMask             |BitMask              |166
DefBitMaskSet          |BitMaskSet           |32
DefCorporateDetailType |CorporateDetailType  |50
DefCorporateType       |CorporateType        |6
DefCountry             |Country              |16
DefDateBasis           |DateBasis            |7
DefInventoryType       |InventoryType        |3
DefJobCron             |JobCron              |5
DefJobCronHistory      |JobCronHistory       |12
DefLegalVehicle        |LegalVehicle         |8
DefLocation            |Location             |3
DefNotificationTemplate|NotificationTemplate |0
DefTaxOffice           |TaxOffice            |499
FlowTransitionData     |FlowTransitionData   |4725
FXRate                 |FXRate               |9645
FXRateDetail           |FXRateDetail         |374193
HalfWorkingDay         |HalfWorkingDay       |1
Holiday                |Holiday              |2810
InterestRate           |InterestRate         |4479
InterestRateDetail     |InterestRateDetail   |333962
Market                 |Market               |12
MarketCustomerMap      |MarketCustomerMap    |10
Point                  |Point                |112
PrfPortfolio           |Portfolio            |29
RateSource             |RateSource           |7
TaxRate                |TaxRate              |31
TaxRule                |TaxRule              |0
TaxTax                 |TaxTax               |3
TaxType                |TaxType              |4
UsrUserLayout          |UsrUserLayout        |0
```
(+ `DefTxnType` — adı iki DB'de aynı olduğu için prefix-normalizasyonda düştü, ham kesişimde var.)

Hangfire tabloları (`AggregatedCounter, Counter, Hash, Job, JobParameter, JobQueue, List, Schema,
Server, Set, State`) kesişimde çıkıyor ama **referans verisi değil**, elendi.

## 10 — Emsal tabloların PK'sı + IDENTITY

```
Tablo                        |Kolon        |Tip     |is_identity
AmortizationConfiguration    |Id           |bigint  |1
DefBitMask                   |SetNo        |int     |0
DefBitMask                   |RoleNo       |int     |0   (composite PK)
DefBitMaskSet                |SetNo        |int     |1
DefJobCron                   |Id           |int     |1
DefNotification              |Id           |int     |1
DefNotificationTemplate      |Id           |int     |1
DefTxnType                   |TxnTypeCode  |nvarchar|0
PrdAccountSelectionType      |Id           |int     |0
PrdInstrument                |Id           |int     |0
PrdProductDefinitionMarketMap|Id           |int     |0
```

## 11 — Tablo oluşturma tarihleri (konvansiyon zaman çizgisi)

```
AmortizationConfigurationHistory |2026-04-21
AmortizationConfiguration        |2026-04-21
TxnLoan                          |2026-04-10
TxnCashFlow                      |2026-04-09
TxnDocument                      |2024-12-28
TxnNote                          |2024-11-18
PrdProductDefinitionHistory      |2024-10-15
PrdProductDefinition             |2024-10-15
PrdProductDefinitionMarketMap    |2024-02-29
DefNotificationTemplate          |2020-08-28
DefNotification                  |2020-08-28
DefJobCronHistory                |2020-08-28
DefJobCron                       |2020-08-28
DefCashflow                      |2020-08-28
DefAmountSlab                    |2020-08-28
```
