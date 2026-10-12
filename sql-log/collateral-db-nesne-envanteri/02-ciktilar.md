# SQL Log — Çıktılar — collateral-db-nesne-envanteri

### #1 — Nesne sayımları (NetTrexMM)

```
PROCEDURE|9
FN_scalar|28
IF_inline_tvf|0
TF_table_valued|1
TRIGGER|9
FOREIGN_KEY|16
CHECK_CONSTRAINT|0
DEFAULT_CONSTRAINT|45
PK|117
UQ_constraint|4
UNIQUE_INDEX_nonPK|169   <-- sys.tables JOIN'siz; internal/HangFire dahil. Gercek kullanici tablosu rakami #8'de: 5
TABLE|125
```

### #2 / #3 — Procedure ve function adlari

```
9|GenerateInsert, sp_GetNewNumbers, sp_GetNewRefNumber, sp_InsertTxnSyncDetail, sp_MDL_Credits, sp_MDL_Credits_cls, sp_mdwGetCustomerByBaseNo, sp_MmNovareg, sr_MDL_BankLoanDeposits
SQL_SCALAR_FUNCTION|28|BinaryToDecimal, ConvertToBase, DecimalToBinary, fd_DateBasis, fd_DateBasisDayDiff, fd_LastDayOfMonth, fd_LgDt, fd_NextWD, fd_SmallerDt, fn_Accrual, fn_Amortized, fn_BondRate, fn_BookValue, fn_CalcTaxBITT, fn_CheckMask, fn_ConvertCCY, fn_CouponsPerYear, fn_DivZero, fn_FuncCCY, fn_LocalCCY, fn_MulDiv, fn_TxnValue, fn_Unamortized, fr_AnnualRateBasis, fr_BondIndexRate, fr_CpiRate, fr_IndexPrice, fr_IndexRate
SQL_TABLE_VALUED_FUNCTION|1|fn_StringSplitter
```

### #4 / #5 — FK dagilimi + tam liste

```
CASCADE|CASCADE|2        <-- ikisi de HangFire (3rd party)
NO_ACTION|NO_ACTION|14

FK_BatchLog_BatchSet_BatchSetId|BatchLog|BatchSet|NO_ACTION|0|0
FK_BatchLogDetail_BatchItem_BatchItemId|BatchLogDetail|BatchItem|NO_ACTION|0|0
FK_BatchLogDetail_BatchLog_BatchLogId|BatchLogDetail|BatchLog|NO_ACTION|0|0
FK_DefBitMask_DefBitMaskSet_SetNo|DefBitMask|DefBitMaskSet|NO_ACTION|0|0
FK_DefNotificationTemplate_DefNotification_NotificationId|DefNotificationTemplate|DefNotification|NO_ACTION|0|0
FK_HangFire_JobParameter_Job|JobParameter|Job|CASCADE|0|0
FK_HangFire_State_Job|State|Job|CASCADE|0|0
FK_PrdProductDefinition_AccountingCalculationMethodType_AccountingCalculationMethodTypeId|PrdProductDefinition|AccountingCalculationMethodType|NO_ACTION|0|0
FK_PrdProductDefinition_LogicalReferenceType_LogicalReferenceTypeId|PrdProductDefinition|LogicalReferenceType|NO_ACTION|0|0
FK_PrdProductDefinition_PrdAccountSelectionType_AccountSelectionTypeId|PrdProductDefinition|PrdAccountSelectionType|NO_ACTION|0|0
FK_PrdProductDefinitionHistory_LogicalReferenceType_LogicalReferenceTypeId|PrdProductDefinitionHistory|LogicalReferenceType|NO_ACTION|0|0
FK_PrdProductDefinitionHistory_PrdAccountSelectionType_AccountSelectionTypeId|PrdProductDefinitionHistory|PrdAccountSelectionType|NO_ACTION|0|0
FK_PrdProductDefinitionMarketMap_Market_MarketCode|PrdProductDefinitionMarketMap|Market|NO_ACTION|0|0
FK_PrdProductDefinitionMarketMap_PrdProductDefinition_ProductDefinitionId|PrdProductDefinitionMarketMap|PrdProductDefinition|NO_ACTION|0|0
FK_TxnMM_RolloverType_RolloverTypeId|TxnMM|RolloverType|NO_ACTION|0|0
FK_UsrUserNotifications_DefNotification_NotificationId|UsrUserNotifications|DefNotification|NO_ACTION|0|0
```
Hicbiri `is_not_trusted` / `is_disabled` degil (hepsi 0).

SP create_date'leri (hepsi legacy/entegrasyon):
```
sp_GetNewRefNumber|2025-09-30 | sp_GetNewNumbers|2025-07-27 | sp_mdwGetCustomerByBaseNo|2024-11-13
GenerateInsert|2024-11-13 | sp_MDL_Credits_cls|2024-09-18 | sp_MDL_Credits|2024-09-18
sr_MDL_BankLoanDeposits|2024-05-29 | sp_MmNovareg|2024-02-13 | sp_InsertTxnSyncDetail|2023-08-11
FN create tarih araligi: 2020-08-28 .. 2025-01-17 (29 adet FN+TF)
```

### #6 — CHECK constraint

`sys.check_constraints` = **0 satir**. MM'de hic CHECK constraint yok.

### #7 — DEFAULT constraint

```
((0))|23
(getdate())|7
((1))|4
((18))|4
('')|3
(('system') collate SQL_Latin1_General_CP1254_CI_AS)|2
((10000))|1
([dbo].[fd_LgDt]())|1

DF_kalibi|44
farkli|1
DF__TxnTawarr__Exter__458AE82D|TxnTawarruq|ExternalTxnProductSourceType   <-- isimsiz eklenmis, SQL Server uretti
```

### #8 — PK disi unique index/constraint (yalniz kullanici tablolari)

```
UQ_Currency_Code|Currency|UQC=1|Filtreli=0||Code
UQ_FXRateDetail_FXRateId|FXRateDetail|UQC=1|Filtreli=0||FXRateId, FromCurrency, ToCurrency
UQ_LogicalReferenceType_Code|LogicalReferenceType|UQC=1|Filtreli=0||Code
UQ_TxnMM_LogicalReference|TxnMM|UQC=1|Filtreli=0||LogicalReference
UQ_TxnTawarruq_LogicalReference|TxnTawarruq|UQC=0|Filtreli=0||LogicalReference
```
Filtered (partial) unique index **yok** — `has_filter` hepsinde 0.

### #9 — Trigger + History eslesmesi

```
AmortizationConfigurationTrigger|AmortizationConfiguration|0|HistoryVar=1
DefJobCronTrigger|DefJobCron|0|1
PrdProductDefinitionTrigger|PrdProductDefinition|0|1
TxnCashFlowTrigger|TxnCashFlow|0|1
TxnDocumentTrigger|TxnDocument|0|1
TxnLoanTrigger|TxnLoan|0|1
TxnMMTrigger|TxnMM|0|1
TxnNoteTrigger|TxnNote|0|1
TxnTawarruqTrigger|TxnTawarruq|0|1

History tablolari (9) -> hepsinin trigger'i VAR (1:1 tam eslesme)
AmortizationConfigurationHistory, DefJobCronHistory, PrdProductDefinitionHistory, TxnCashFlowHistory,
TxnDocumentHistory, TxnLoanHistory, TxnMMHistory, TxnNoteHistory, TxnTawarruqHistory

StateId kolonu olan tablo sayisi: 55
AccEntryMain, BatchItem, BatchSet, Branch, Chart, Currency, CurrencyPair, CusCustomer, CusSIC, DefAmountSlab,
DefCorporateType, DefCountry, DefDateBasis, DefExternalReferenceSource, DefJobCron, DefJobCronHistory,
DefLegalVehicle, DefLocation, DefTaxOffice, DefTxnType, ExternalCustomerMap, ExternalUserMap, FXRate,
HalfWorkingDay, InterestRate, Job, Market, MarketCustomerMap, Message, PaymentMessage, Point, PrdInstrument,
PrdProductDefinition, PrdProductDefinitionHistory, PrfPortfolio, RateSource, TaxRate, TaxRule, TaxTax, TaxType,
TxnCashFlow, TxnCashFlowHistory, TxnDocument, TxnDocumentHistory, TxnLoan, TxnLoanHistory, TxnLoanSync, TxnMM,
TxnMMHistory, TxnNote, TxnNoteHistory, TxnState, TxnSync, TxnTawarruq, TxnTawarruqHistory

FlowId / LastActionId kolonu olan tablolar (6'sar):
TxnLoan, TxnLoanHistory, TxnMM, TxnMMHistory, TxnTawarruq, TxnTawarruqHistory
```

### #10 — Trigger govdeleri

```
PrdProductDefinitionTrigger:
CREATE TRIGGER [dbo].[PrdProductDefinitionTrigger] ON [dbo].[PrdProductDefinition]
FOR INSERT, UPDATE AS
INSERT INTO [dbo].[prdProductDefinitionHistory] SELECT * FROM inserted;     <-- ESKI kalip

TxnMMTrigger:
CREATE TRIGGER [dbo].[TxnMMTrigger] ON [dbo].[TxnMM] FOR INSERT, UPDATE AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO [dbo].[TxnMMHistory] ( [AccountNumber], [BasisCode], [BusinessKey], [Ccy],
        [CollateralType], [CorporateCurrentAccountGLCode], ... )                <-- ACIK KOLON LISTESI (yeni kalip)
```

### #11 — DefNumberGen (8 satir, TAM liste)

```
Toplam=8  MaxType=8  MinType=1
EntityColumnType|LastNumber|Definition|LastUpdateDate
8|1168|Txn Loan Id|2026-09-15 17:38:46.097
7|1052|Txn Tawarruq Id|2026-09-24 14:13:41.467
6|1032|Product Definition Market Map Id|2025-12-17 14:41:13.653
5| 999|Product Definition Id|2025-03-23 17:46:00.133
4|8174|Generated Account|2026-10-02 12:23:17.253
3|12694|Account Entry|2026-10-02 12:23:17.247
2|6141|Acc Entry Main Id|2026-10-02 12:23:17.237
1|3412|Txn Mm Id|2026-10-02 12:22:15.347
```

`DefRefNumGen` (ayri tablo, farkli amac): kolonlar `TypeKey nvarchar`, `LastReference int`;
satirlar gunluk referans sayaci (`T250429|7`, `T250430|15`, ...). `sp_GetNewRefNumber @TypeKey` ile artiyor.

`sp_GetNewNumbers @EntityColumnType, @CountToGenerate`: `UPDATE defNumberGen WITH (ROWLOCK, UPDLOCK)
SET @new_last_no = LastNumber = LastNumber + @CountToGenerate, LastUpdateDate = GETDATE()
WHERE EntityColumnType = @EntityColumnType;` — satir yoksa RAISERROR dalina giriyor.

### #11b — NetTrexCommon: sp_UnverifiedDataCount_* ve DefCountMonitoring

```
PROC|112
UnverifiedDataCount_SP|30
CountMonitoringTablo|1
```
30 SP (TUM modullerin): sp_UnverifiedDataCount_AccountEngine, _AccountingEngineAccount,
_AccountingEngineComponentType, _AccountingEngineDynamicMap, _AccountingEngineDynamicRule,
_AccountingEngineItem, _AccountingEngineItemCode, _AccountingEngineItemType,
_AccountingEngineModelDefinition, _AccountingMap, _BistTlrefIndex, _BondPrice, _CusTxn, _FXRate,
_InterestRate, _IssueBond, _Portfolios, _PriceIndex, _secSecurity, _TxnDepo, _TxnDerivSwp, _txnFI,
_TxnFx, _TxnFxSwap, _txnLoan, _txnMM, _TxnPM, _TxnPMSwap, _TxnRepo, _txnTawarruq
+ sr_DashboardChartTransactionCountHourlyFill, sr_DashboardChartUnverifiedCountFill

`DefCountMonitoring` kolonlari (NetTrexCommon):
```
Id|int|NOT NULL
ScreenName|nvarchar(100)|NOT NULL
ScreenUrl|nvarchar(255)|NOT NULL
Query|nvarchar(max)|NOT NULL
Connection|nvarchar(100)|NOT NULL
DefaultUnverifiedStateId|nvarchar(50)|NOT NULL
State|bit|NULL
Toplam satir: 30
```
Son 20 satir:
```
30|Accounting Engine Map|EXEC sp_UnverifiedDataCount_AccountingMap @CurrentUserId|general/AccountingMap/Index|Connection|3|1
29|Accounting Engine Model Definition|EXEC sp_UnverifiedDataCount_AccountingEngineModelDefinition|general/AccountingEngineModelDefinition/Index|Connection|3|1
28|Accounting Engine Item|...|general/AccountingEngineItem/Index|Connection|3|1
27|Accounting Engine Item Type|...|general/AccountingEngineItemType/Index|Connection|3|1
26|Accounting Engine Item Code|...|general/AccountingEngineItemCode/Index|Connection|3|1
25|Accounting Engine Account|...|general/AccountingEngineAccount/Index|Connection|3|1
24|Accounting Engine Dynamic Rule|...|general/AccountingEngineDynamicRule/Index|Connection|3|1
23|Accounting Engine Dynamic Map|...|general/AccountingEngineDynamicMap/Index|Connection|3|1
22|Accounting Engine Component Type|...|general/AccountingEngineComponentType/Index|Connection|3|1
21|Accounting Engine|EXEC sp_UnverifiedDataCount_AccountEngine @CurrentUserId|general/AccountingEngine/Index|Connection|3|1
20|Interbank Loan Transactions|EXEC sp_UnverifiedDataCount_TxnLoan @CurrentUserId|general/InterbankLoan/Index|Connection|3|1
19|Tawarruq Transactions|EXEC sp_UnverifiedDataCount_txnTawarruq @CurrentUserId|general/Tawarruq/Index|Connection|3|1
18|DerivSwp Transactions|...|deriv/DerivSwp/Index|Connection|3|1
17|IssueBond Index|...|general/IssueBond/Index|Connection|3|1
16|Portfolios|...|general/Portfolio/Index|Connection|3|0
15|BIST TLREF Index|...|general/TLREFIndex/Index|Connection|3|1
14|Price Indexes|...|general/PriceIndex/Index|Connection|3|1
13|MM Transactions|EXEC sp_UnverifiedDataCount_txnMM @CurrentUserId|general/MmTransaction/Index|Connection|3|1
12|Deposit Rates|...|general/InterestRate/Index|Connection|3|1
11|Fx Rates|...|general/FXRate/Index|Connection|3|1
```

`sp_UnverifiedDataCount_txnTawarruq` govdesi (kalip):
```sql
CREATE PROCEDURE [dbo].[sp_UnverifiedDataCount_txnTawarruq]
@CurrentUserId NVARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @UnverifiedDataCount INT;
    DECLARE @HavePermission BIT;
    SELECT @HavePermission = dbo.fn_HasPermissionWithUserId(@CurrentUserId, 'Tawarruq\_%');
    IF (@HavePermission = 1)
        BEGIN
            SELECT @UnverifiedDataCount = COUNT(*)
            FROM NetTrexMM.dbo.TxnTawarruq tw WITH (NOLOCK)
            WHERE (tw.StateId & 2) <> 2 AND (tw.StateId & 1) <> 1;
        END
    ELSE
        BEGIN SELECT @UnverifiedDataCount = -1; END
    SELECT @UnverifiedDataCount AS UnverifiedDataCount;
END
```
Not: SP **NetTrexCommon**'da durur ama **cross-database** (`NetTrexMM.dbo.TxnTawarruq`) sorgular.
