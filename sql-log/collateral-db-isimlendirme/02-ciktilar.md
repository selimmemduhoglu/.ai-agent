# SQL Log — Çıktılar — collateral-db-isimlendirme

### #1 / #2 — ilk deneme BAŞARISIZ

```
Sqlcmd: The -W and the -y/-Y options are mutually exclusive.
```
Yorum: komut satırı hatası, sunucuya hiç gidilmedi. `-W` kaldırılıp `-y 0` ile tekrar çalıştırıldı (aynı SQL).

### #1

```
125|AccEftAccount, AccEngineGeneratedAccountRule, AccEntry, AccEntryMain, AccEntryType, AccountingCalculationMethodType, AggregatedCounter, AmortizationConfiguration, AmortizationConfigurationHistory, AmortizationType, BatchItem, BatchLog, BatchLogDetail, BatchSet, Branch, Calendar, Chart, Counter, Currency, CurrencyPair, CusAccount, CusCustomer, CusSIC, DefAccrual, DefAmortization, DefAmountSlab, DefBitMask, DefBitMaskSet, DefCashflow, DefCorporateDetailType, DefCorporateType, DefCountry, DefDateBasis, DefExternalReferenceSource, DefFundSource, DefInventoryType, DefJobCron, DefJobCronHistory, DefLegalVehicle, DefLocation, DefNotification, DefNotificationTemplate, DefNumberGen, DefRefNumGen, DefTaxOffice, DefTxnType, ExternalCustomerMap, ExternalMM, ExternalUserMap, FloatingRateType, FlowTransitionData, FlowType, FXRate, FXRateDetail, HalfWorkingDay, Hash, Holiday, InterestMethod, InterestMethodFrequency, InterestRate, InterestRateDetail, Job, JobParameter, JobQueue, LiquidationType, List, LoanRevaluation, LogicalReferenceType, Market, MarketCustomerMap, MDL_BANK_LOAN_DEPOSITS, MDL_CREDITS, MDL_CREDITS_CLS, Message, PaymentFrequency, PaymentInstructionType, PaymentMessage, Point, PrdAccountSelectionType, PrdInstrument, PrdProductDefinition, PrdProductDefinitionHistory, PrdProductDefinitionMarketMap, PrdProductTxn, PrdSubType, PrfInstrument, PrfPortfolio, RateSource, RateType, RolloverType, Schema, Server, Set, SettlementType, State, TaxRate, TaxRule, TaxTax, TaxType, Term, TxnCashFlow, TxnCashFlowHistory, TxnDocument, TxnDocumentHistory, TxnLoan, TxnLoanHistory, TxnLoanSync, TxnLoanTax, TxnMM, TxnMmDailyCalculation, TxnMMDetail, TxnMMHistory, TxnMMTax, TxnNote, TxnNoteHistory, TxnState, TxnSync, TxnTawarruq, TxnTawarruqHistory, TxnTax, UsrUserFavoriteField, UsrUserFavoritesMenu, UsrUserLayout, UsrUserNotifications, UsrUserPreferences
```

### #2

```
bigint|0|11|AmortizationConfigurationHistory, ExternalCustomerMap, FlowTransitionData, Message, TxnCashFlowHistory, TxnLoan, TxnLoanHistory, TxnMM, TxnMMHistory, TxnTawarruq, TxnTawarruqHistory
int|0|50|AccEftAccount, AccEngineGeneratedAccountRule, AccEntry, AccEntryMain, AccEntryType, AccountingCalculationMethodType, BatchItem, BatchSet, Calendar, Chart, CusCustomer, DefCorporateDetailType, DefCorporateType, DefExternalReferenceSource, DefFundSource, DefJobCronHistory, DefLegalVehicle, DefLocation, ExternalUserMap, FloatingRateType, FlowType, FXRate, FXRateDetail, HalfWorkingDay, Holiday, InterestMethod, InterestMethodFrequency, InterestRate, InterestRateDetail, LogicalReferenceType, MarketCustomerMap, PaymentFrequency, PaymentInstructionType, Point, PrdAccountSelectionType, PrdInstrument, PrdProductDefinition, PrdProductDefinitionHistory, PrdProductDefinitionMarketMap, PrfPortfolio, RateSource, RateType, RolloverType, SettlementType, TaxRate, TaxRule, TaxTax, Term, TxnDocumentHistory, TxnNoteHistory
numeric|0|3|MDL_BANK_LOAN_DEPOSITS, MDL_CREDITS, MDL_CREDITS_CLS
nvarchar|0|1|Server
bigint|1|14|AmortizationConfiguration, AmortizationType, Counter, Job, JobQueue, List, LoanRevaluation, PaymentMessage, State, TxnCashFlow, TxnLoanSync, TxnLoanTax, TxnMMDetail, TxnSync
int|1|20|BatchLog, BatchLogDetail, Branch, DefAmountSlab, DefCashflow, DefJobCron, DefNotification, DefNotificationTemplate, ExternalMM, LiquidationType, TaxType, TxnDocument, TxnMmDailyCalculation, TxnMMTax, TxnNote, TxnState, UsrUserFavoriteField, UsrUserLayout, UsrUserNotifications, UsrUserPreferences
```

### #3

```
decimal|38,10|62
decimal|18,10|22
decimal|18,2|7
decimal|36,18|4
decimal|18,4|1
numeric|22,6|64
numeric|18,9|16
numeric|1,0|16
numeric|5,0|9
numeric|8,0|9
numeric|2,0|5
numeric|3,0|4
numeric|15,0|4
numeric|7,4|3
numeric|12,0|3
numeric|13,0|2
numeric|5,2|2
numeric|18,0|2
numeric|10,0|1
nvarchar|50|154
nvarchar|10|103
nvarchar|80|100
nvarchar|3|78
nvarchar|500|56
nvarchar|100|45
nvarchar|4|33
nvarchar|1|25
nvarchar|250|24
nvarchar|-1|21
nvarchar|30|20
nvarchar|150|16
nvarchar|200|14
nvarchar|20|13
nvarchar|255|12
nvarchar|1000|10
nvarchar|6|7
nvarchar|2|7
nvarchar|5|6
nvarchar|36|6
nvarchar|40|4
nvarchar|300|3
nvarchar|32|2
nvarchar|25|2
nvarchar|11|2
nvarchar|15|2
nvarchar|16|1
nvarchar|18|1
nvarchar|26|1
nvarchar|350|1
nvarchar|256|1
```

### #4

```
diger|38|ExcludeProxy, Accountable, AccountingEnable, HandOffEnable, FCCLPortfolio, BalanceSheet, SendConfirmation, SendPayment, SendNoticeToReceive, SendConfirmation, SendPayment, SendNoticeToReceive, SendPaymentMessage, SendConfirmationMessage, SendNoticeToReceiveMessage, State, SendConfirmation, SendPayment, SendNoticeToReceive, CustomerIsFinancialInstitution, SendPaymentMessage, SendConfirmationMessage, SendNoticeToReceiveMessage, ExcludeProxy, SendConfirmation, SendPayment, SendNoticeToReceive, CustomerIsFinancialInstitution, SendConfirmation, SendPayment, SendNoticeToReceive, CanUseOnTxn, ForeignCcy, Disabled, SendConfirmation, SendPayment, SendNoticeToReceive, ReverseRebook
Use*|6|UseFundSource, UseSubFundSource, UseOnUnitValue, UseFundSource, UseSubFundSource, UseOnUnitValue
Is* (sayi)|87|NULL
```

### #5

```
StateDate|56
StateId|55
StateMaker|54
IsEnabled|23
LastActionId|6
CreatedBy|6
CreatedDate|6
FlowId|6
IsActive|1
```

### #6

```
PK/UQ|PK_AccEntryMain|AccEntryMain
PK/UQ|PK_AmortizationType|AmortizationType
PK/UQ|PK_AccEngineGeneratedAccountRule|AccEngineGeneratedAccountRule
PK/UQ|PK_DefCountry|DefCountry
PK/UQ|PK_AmortizationConfigurationHistory|AmortizationConfigurationHistory
PK/UQ|PK_TxnDocumentHistory|TxnDocumentHistory
PK/UQ|PK_DefDateBasis|DefDateBasis
PK/UQ|PK_TxnMmDailyCalculation|TxnMmDailyCalculation
PK/UQ|PK_AmortizationConfiguration|AmortizationConfiguration
PK/UQ|PK_TxnDocument|TxnDocument
PK/UQ|PK_UsrUserNotifications|UsrUserNotifications
PK/UQ|PK_PrdProductDefinitionMarketMap|PrdProductDefinitionMarketMap
PK/UQ|PK_Market|Market
PK/UQ|PK_PrdAccountSelectionType|PrdAccountSelectionType
PK/UQ|PK_AccountingCalculationMethodType|AccountingCalculationMethodType
PK/UQ|PK_ExternalUserMap|ExternalUserMap
PK/UQ|PK_DefBitMask|DefBitMask
PK/UQ|UQ_LogicalReferenceType_Code|LogicalReferenceType
PK/UQ|PK_LogicalReferenceType|LogicalReferenceType
PK/UQ|PK_Branch|Branch
FK|FK_PrdProductDefinition_LogicalReferenceType_LogicalReferenceTypeId|PrdProductDefinition|LogicalReferenceType
FK|FK_PrdProductDefinitionHistory_LogicalReferenceType_LogicalReferenceTypeId|PrdProductDefinitionHistory|LogicalReferenceType
FK|FK_BatchLogDetail_BatchLog_BatchLogId|BatchLogDetail|BatchLog
FK|FK_TxnMM_RolloverType_RolloverTypeId|TxnMM|RolloverType
FK|FK_PrdProductDefinitionMarketMap_PrdProductDefinition_ProductDefinitionId|PrdProductDefinitionMarketMap|PrdProductDefinition
FK|FK_UsrUserNotifications_DefNotification_NotificationId|UsrUserNotifications|DefNotification
FK|FK_PrdProductDefinition_PrdAccountSelectionType_AccountSelectionTypeId|PrdProductDefinition|PrdAccountSelectionType
FK|FK_PrdProductDefinition_AccountingCalculationMethodType_AccountingCalculationMethodTypeId|PrdProductDefinition|AccountingCalculationMethodType
FK|FK_HangFire_JobParameter_Job|JobParameter|Job
FK|FK_PrdProductDefinitionMarketMap_Market_MarketCode|PrdProductDefinitionMarketMap|Market
FK|FK_HangFire_State_Job|State|Job
FK|FK_PrdProductDefinitionHistory_PrdAccountSelectionType_AccountSelectionTypeId|PrdProductDefinitionHistory|PrdAccountSelectionType
FK|FK_DefNotificationTemplate_DefNotification_NotificationId|DefNotificationTemplate|DefNotification
FK|FK_DefBitMask_DefBitMaskSet_SetNo|DefBitMask|DefBitMaskSet
FK|FK_BatchLog_BatchSet_BatchSetId|BatchLog|BatchSet
FK|FK_BatchLogDetail_BatchItem_BatchItemId|BatchLogDetail|BatchItem
IX|IX_AccEntry_AccEntryMainId|AccEntry
IX|IX_CusCustomer_ExternalCustomerId|CusCustomer
IX|IX_TxnMM_MaturityDate|TxnMM
IX|IX_TxnMM_ValueDate|TxnMM
IX|IX_TxnMM_StateDate|TxnMM
IX|IX_FXRateDetail_FxRateId_FromCurrency_ToCurrency|FXRateDetail
IX|IX_InterestRateDetail_InterestRateId_Point_Ccy|InterestRateDetail
IX|IX_InterestRateDetail_InterestRateId_Point_Ccy_Inc|InterestRateDetail
IX|IX_HangFire_AggregatedCounter_ExpireAt|AggregatedCounter
IX|IX_HangFire_Hash_ExpireAt|Hash
IX|IX_HangFire_Set_ExpireAt|Set
IX|IX_HangFire_Set_Score|Set
IX|IX_HangFire_List_ExpireAt|List
IX|IX_HangFire_Server_LastHeartbeat|Server
IX|IX_Calendar_Year_CurrencyCode_DayOfYear_Inc|Calendar
IX|IX_Calendar_CurrencyCode_Year_DayOfYear|Calendar
IX|IX_HangFire_State_CreatedAt|State
IX|UQ_TxnTawarruq_LogicalReference|TxnTawarruq
IX|IX_HangFire_Job_ExpireAt|Job
IX|IX_HangFire_Job_StateName|Job
DF|DF_ExternalCustomerMap_StateDate|ExternalCustomerMap
DF|DF_DefCountry_Enabled|DefCountry
DF|DF_ExternalCustomerMap_StateMaker|ExternalCustomerMap
DF|DF_ExternalCustomerMap_StateId|ExternalCustomerMap
DF|DF_ExternalUserMap_PortfolioId|ExternalUserMap
DF|DF_PrdProductDefinitionMarketMap_IsEnabled|PrdProductDefinitionMarketMap
DF|DF_ExternalUserMap_StateDate|ExternalUserMap
DF|DF_ExternalUserMap_StateMaker|ExternalUserMap
DF|DF_ExternalUserMap_StateId|ExternalUserMap
DF|DF_BatchLogDetail_Status|BatchLogDetail
DF|DF_BatchItem_StateDate|BatchItem
DF|DF_BatchItem_StateId|BatchItem
DF|DF_BatchItem_IsTransactional|BatchItem
DF|DF_BatchItem_ItemOrder|BatchItem
DF|DF_BatchSet_StateDate|BatchSet
DF|DF_BatchSet_StateId|BatchSet
DF|DF_TxnState_LogicalDate|TxnState
DF|DF_ExternalMM_ExternalReferenceSourceId|ExternalMM
DF|DF_TxnLoan_IsMatured|TxnLoan
DF|DF_ExternalMM_CreatedTime|ExternalMM
```

### #7

```
decimal(18,2)|7|TxnLoanTax.Amount, TxnMMTax.Amount, AmortizationConfiguration.AmortizationAmount, AmortizationConfiguration.AmortizationPercentage, AmortizationConfigurationHistory.AmortizationAmount, AmortizationConfigurationHistory.AmortizationPercentage, CusCustomer.CounterpartyLimit
decimal(18,4)|1|Message.Amount
decimal(18,10)|22|LoanRevaluation.Rate, LoanRevaluation.Spread, LoanRevaluation.PeriodRate, LoanRevaluation.PeriodSpread, LoanRevaluation.PeriodAccrualRate, TxnCashFlow.Rate, TxnCashFlow.Spread, TxnCashFlowHistory.Rate, TxnCashFlowHistory.Spread, TxnMMTax.TaxRate, TxnLoanTax.TaxRate, LoanRevaluation.AccrualSpotRate, TxnLoan.Rate, TxnLoan.Spread, TxnLoan.LiquidationPrice, TxnLoan.LiquidationAmount, TxnLoan.Fee, TxnLoanHistory.Rate, TxnLoanHistory.Spread, TxnLoanHistory.LiquidationPrice, TxnLoanHistory.LiquidationAmount, TxnLoanHistory.Fee
decimal(36,18)|4|TxnMMDetail.Amount, TxnMmDailyCalculation.AccrualAmount, TxnMmDailyCalculation.AccrualAmountSL, TxnMmDailyCalculation.AccrualAmountIRR
decimal(38,10)|62|TxnMmDailyCalculation.AccrualAmountLCY, TxnMmDailyCalculation.FXRate, TxnMmDailyCalculation.BaseAmount, AccEntry.Amount, AccEntry.LcyEquivalent, AccEntry.FcyEquivalent, AccEntry.FxRate, TxnLoan.PrincipalAmount, AccEngineGeneratedAccountRule.Amount, AccEngineGeneratedAccountRule.LcyEquivalent, AccEngineGeneratedAccountRule.FcyEquivalent, Currency.Pip, TxnLoanHistory.PrincipalAmount, TxnLoanSync.Leg1Amount, TxnLoanSync.Leg2Amount, TxnLoanSync.Rate, TxnTax.Amount, TxnTax.TaxRate, InterestRateDetail.AskRate, InterestRateDetail.BidRate, InterestRateDetail.MidRate, FXRateDetail.AskRate, FXRateDetail.MidRate, FXRateDetail.BidRate, BatchLogDetail.Duration, TxnMMDetail.InterestRate, TxnMMHistory.DealAmount, TxnMMHistory.MaturityAmount, TxnSync.Leg1Amount, TxnSync.Leg2Amount, TxnSync.Rate, TxnTawarruqHistory.OunceDealRate, TxnTawarruqHistory.OunceAmount, TxnTawarruqHistory.GramAmount, TxnTawarruqHistory.ExternalTxnAmount, TxnMM.DealAmount, TxnMM.MaturityAmount, TxnCashFlowHistory.CashFlowAmount, LoanRevaluation.PrincipalAmount, TxnCashFlow.CashFlowAmount, TxnCashFlowHistory.PrincipalAmount, TxnTawarruq.OunceDealRate, TxnTawarruq.OunceAmount, TxnTawarruq.GramAmount, TxnTawarruq.ExternalTxnAmount, PrdInstrument.PerUnit, TaxRate.Rate, DefAmountSlab.FromAmt, DefAmountSlab.ToAmt, PaymentMessage.Amount, LoanRevaluation.PeriodAccrualAmountIRR, LoanRevaluation.PeriodAccrualAmountIRRLCY, LoanRevaluation.PeriodAccrualAmountSL, LoanRevaluation.PeriodAccrualAmountSLLCY, LoanRevaluation.PrincipalAmountNPV, LoanRevaluation.PrincipalAmountNPVLCY, LoanRevaluation.TotalAmountNPV, LoanRevaluation.TotalAmountNPVLCY, LoanRevaluation.PeriodAmount, LoanRevaluation.PeriodAmountLCY, LoanRevaluation.PeriodPrincipalAmount, TxnCashFlow.PrincipalAmount
datetime2|7
datetime|117
date|98
```

## Yorum (özet)

- **#1:** 125 tablo. Fiziksel adların **tamamı PascalCase prefix** (`CusCustomer`, `DefDateBasis`, `TxnMMTax`, `TxnNote`, `AccEntryMain`, `PrdProductDefinition`, `PrfPortfolio`). EF `ToTable("cusCustomer")` gibi küçük harfli string'ler yalnız koddaki yazım farkı (SQL Server CI collation). Tek case sapması: `TxnMmDailyCalculation` (diğerleri `TxnMM*`). Legacy `MDL_*` (UPPER_SNAKE) ve HangFire tabloları (`Job`, `State`, `Set`...) house convention dışı.
- **#2:** Txn başlık/history tabloları `bigint` (IDENTITY yok, DefNumberGen), alt/satır tabloları `bigint IDENTITY`, tanım tabloları `int` (çoğu IDENTITY değil). İstisna: `AccEntry`/`AccEntryMain` int.
- **#3/#7:** `decimal(38,2)` **fiziksel DB'de HİÇ YOK** — para ağırlıklı `decimal(38,10)` (62 kolon), oran `decimal(18,10)` (22). EF'teki `HasPrecision(38,2)` (TxnLoan/TxnCashFlow) DB ile uyuşmuyor. nvarchar en sık 50/10/80/3/500/100.
- **#4:** 87 bit kolon `Is*`; 38 istisna (`Send*`, `*Enable`, `Accountable`, `CanUseOnTxn`, `Disabled`...), 6 `Use*`.
- **#5:** `StateId/StateMaker/StateDate` ~55 tablo; `CreatedBy/CreatedDate/FlowId/LastActionId` yalnız 6 (Flow tabloları). `IsEnabled` 23, `IsActive` 1.
- **#6:** PK `PK_<Tablo>`, FK `FK_<Tablo>_<HedefTablo>_<FkKolon>` (EF default), IX `IX_<Tablo>_<Kolon1>_<Kolon2>[_Inc]`, UQ `UQ_<Tablo>_<Kolon>`, DF `DF_<Tablo>_<Kolon>`.
