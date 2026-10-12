USE NetTrexDerivSWP;
GO

/***************************************************************************************************
* This script is designed to change the data type of primary and foreign key columns from INT to BIGINT
* for the TXN SYNC, TXN SYNC DETAIL, DERIVATIVES REVALUATION, TXN DOCUMENT, TXN NOTE, ACC ENTRY MAIN, ACC ENTRY, FLOW TRANSITION DATA, TXN TAX tables.
***************************************************************************************************/

BEGIN TRANSACTION;

BEGIN TRY

--1.Check if this change has already been applied ---------------------------------------------------------------------------------
    
	IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'TxnSync' AND COLUMN_NAME = 'Id' AND DATA_TYPE = 'bigint')
	BEGIN
		 PRINT 'The change of primary and foreign key columns from INT to BIGINT has already been made.';
		 RETURN;
	END

--2.Dropping Primary Key Constraints-----------------------------------------------------------------------------------------------

    IF OBJECT_ID('dbo.PK_TxnSync', 'PK') IS NOT NULL
	    ALTER TABLE dbo.TxnSync DROP CONSTRAINT PK_TxnSync;

	IF OBJECT_ID('dbo.PK_TxnSyncDetail', 'PK') IS NOT NULL
	    ALTER TABLE dbo.TxnSyncDetail DROP CONSTRAINT PK_TxnSyncDetail;

    IF OBJECT_ID('dbo.PK_DerivativesRevaluation', 'PK') IS NOT NULL
	    ALTER TABLE dbo.DerivativesRevaluation DROP CONSTRAINT PK_DerivativesRevaluation;

    IF OBJECT_ID('dbo.PK_TxnTax', 'PK') IS NOT NULL
        ALTER TABLE dbo.TxnTax DROP CONSTRAINT PK_TxnTax;

--3.Migrating tables with IDENTITY columns to use BIGINT------------------------------------------------------------------------------
    
	--Table TxnDocument
	ALTER TABLE [dbo].[TxnDocument] ALTER COLUMN [TxnId] BIGINT NOT NULL;

	--Table TxnNote
	ALTER TABLE [dbo].[TxnNote] ALTER COLUMN [TxnId] BIGINT NOT NULL;

	--Table AccEntryMain
	ALTER TABLE [dbo].[AccEntryMain] ALTER COLUMN [TxnId] BIGINT NOT NULL;

    --Table AccEntry
	ALTER TABLE [dbo].[AccEntry] ALTER COLUMN [TxnId] BIGINT NOT NULL;

    --Table FlowTransitionData
	ALTER TABLE [dbo].[FlowTransitionData] ALTER COLUMN [FlowSetId] BIGINT NOT NULL;

	--Table TxnSync 
    CREATE TABLE [dbo].[TxnSync_Temp](
		[Id] [bigint] IDENTITY(1,1) NOT NULL,
		[BusinessKey] [bigint] NOT NULL,
		[TransactionId] [bigint] NOT NULL,
		[PackageNumber] [int] NOT NULL,
		[LogicalReference] [nvarchar](100) NOT NULL,
		[CounterPartyReference] [bigint] NOT NULL,
		[Product] [nvarchar](3) NOT NULL,
		[ProductSubType] [nvarchar](10) NOT NULL,
		[TransactionType] [nvarchar](4) NOT NULL,
		[InputDate] [datetime] NOT NULL,
		[ValueDate] [date] NOT NULL,
		[TradeDate] [date] NOT NULL,
		[MaturityDate] [date] NOT NULL,
		[BaseCCYPair] [nvarchar](7) NOT NULL,
		[Leg1Amount] [decimal](38, 10) NOT NULL,
		[Leg1CCY] [nvarchar](3) NOT NULL,
		[Leg2Amount] [decimal](38, 10) NOT NULL,
		[Leg2CCY] [nvarchar](3) NOT NULL,
		[Rate] [decimal](26, 10) NOT NULL,
		[Market] [nvarchar](6) NOT NULL,
		[Instruction] [nvarchar](250) NULL,
		[InternalInstruction] [nvarchar](250) NULL,
		[Trader] [nvarchar](80) NOT NULL,
		[StateId] [int] NOT NULL,
		[StateMaker] [nvarchar](80) NOT NULL,
		[StateDate] [datetime] NOT NULL,
		[Leg1CorrespondentAccount] [bigint] NULL,
		[Leg2CorrespondentAccount] [bigint] NULL,
		[Leg1CounterpartCorrespondentName] [nvarchar](500) NULL,
		[Leg1CounterpartCorrespondentSwiftCode] [nvarchar](50) NULL,
		[Leg1CounterpartCorrespondentAccount] [nvarchar](500) NULL,
		[Leg2CounterpartCorrespondentName] [nvarchar](500) NULL,
		[Leg2CounterpartCorrespondentSwiftCode] [nvarchar](50) NULL,
		[Leg2CounterpartCorrespondentAccount] [nvarchar](500) NULL,
		[DayCount] [nvarchar](20) NOT NULL,
		[PaymentInstructionType] [nvarchar](50) NULL,
		[ReconciliationType] [nvarchar](50) NULL,
		[SendPaymentMessage] [bit] NOT NULL,
		[SendConfirmationMessage] [bit] NOT NULL,
		[SendNoticeToReceiveMessage] [bit] NOT NULL,
		[OutgoingPaymentAccountingType] [nvarchar](50) NULL,
		[OutgoingPaymentAccountingGLType] [nvarchar](50) NULL,
		[OutgoingPaymentAccountingGL] [nvarchar](10) NULL,
		[IncomingPaymentAccountingType] [nvarchar](50) NULL,
		[IncomingPaymentAccountingGLType] [nvarchar](50) NULL,
		[IncomingPaymentAccountingGL] [nvarchar](10) NULL,
		[TheirBeneficiaryCorrespondentId] [int] NULL,
		[TheirBeneficiaryCorrespondentGLCode] [nvarchar](10) NULL,
		[TheirSenderCorrespondentId] [int] NULL,
		[TheirSenderCorrespondentGLCode] [nvarchar](10) NULL
	)

	SET IDENTITY_INSERT [dbo].[TxnSync_Temp] ON;
	INSERT INTO [dbo].[TxnSync_Temp] (
		Id, BusinessKey, TransactionId, PackageNumber, LogicalReference, CounterPartyReference, Product, ProductSubType, TransactionType, InputDate, ValueDate, 
		TradeDate, MaturityDate, BaseCCYPair, Leg1Amount, Leg1CCY, Leg2Amount, Leg2CCY, Rate, Market, Instruction, InternalInstruction, Trader, StateId, StateMaker, 
		StateDate, Leg1CorrespondentAccount, Leg2CorrespondentAccount, Leg1CounterpartCorrespondentName, Leg1CounterpartCorrespondentSwiftCode, 
		Leg1CounterpartCorrespondentAccount, Leg2CounterpartCorrespondentName, Leg2CounterpartCorrespondentSwiftCode, Leg2CounterpartCorrespondentAccount, DayCount, 
		PaymentInstructionType, ReconciliationType, SendPaymentMessage, SendConfirmationMessage, SendNoticeToReceiveMessage, OutgoingPaymentAccountingType, 
		OutgoingPaymentAccountingGLType, OutgoingPaymentAccountingGL, IncomingPaymentAccountingType, IncomingPaymentAccountingGLType, IncomingPaymentAccountingGL, 
		TheirBeneficiaryCorrespondentId, TheirBeneficiaryCorrespondentGLCode, TheirSenderCorrespondentId, TheirSenderCorrespondentGLCode
	)
	SELECT
		Id, BusinessKey, TransactionId, PackageNumber, LogicalReference, CounterPartyReference, Product, ProductSubType, TransactionType, InputDate, ValueDate, 
		TradeDate, MaturityDate, BaseCCYPair, Leg1Amount, Leg1CCY, Leg2Amount, Leg2CCY, Rate, Market, Instruction, InternalInstruction, Trader, StateId, StateMaker, 
		StateDate, Leg1CorrespondentAccount, Leg2CorrespondentAccount, Leg1CounterpartCorrespondentName, Leg1CounterpartCorrespondentSwiftCode, 
		Leg1CounterpartCorrespondentAccount, Leg2CounterpartCorrespondentName, Leg2CounterpartCorrespondentSwiftCode, Leg2CounterpartCorrespondentAccount, DayCount, 
		PaymentInstructionType, ReconciliationType, SendPaymentMessage, SendConfirmationMessage, SendNoticeToReceiveMessage, OutgoingPaymentAccountingType, 
		OutgoingPaymentAccountingGLType, OutgoingPaymentAccountingGL, IncomingPaymentAccountingType, IncomingPaymentAccountingGLType, IncomingPaymentAccountingGL, 
		TheirBeneficiaryCorrespondentId, TheirBeneficiaryCorrespondentGLCode, TheirSenderCorrespondentId, TheirSenderCorrespondentGLCode
	FROM [dbo].[TxnSync];
	SET IDENTITY_INSERT [dbo].[TxnSync_Temp] OFF;

	DROP TABLE dbo.TxnSync;
    EXEC sp_rename 'dbo.TxnSync_Temp', 'TxnSync';

	--Table TxnSyncDetail
	CREATE TABLE [dbo].[TxnSyncDetail_Temp](
		[Id] [bigint] IDENTITY(1,1) NOT NULL,
		[TxnSyncId] [bigint] NULL,
		[BusinessKey] [bigint] NOT NULL,
		[TransactionId] [bigint] NOT NULL,
		[PackageNo] [int] NULL,
		[SwiftKey] [nvarchar](50) NULL,
		[SwiftMessageState] [nvarchar](50) NULL,
		[SwiftMessageDescription] [nvarchar](100) NULL,
		[EftKey] [nvarchar](50) NULL,
		[EftMessageState] [nvarchar](50) NULL,
		[EftMessageDescription] [nvarchar](100) NULL,
		[StateId] [int] NULL,
		[StateMaker] [nvarchar](80) NULL,
		[StateDate] [datetime] NULL
	)

	SET IDENTITY_INSERT [dbo].[TxnSyncDetail_Temp] ON;
	INSERT INTO [dbo].[TxnSyncDetail_Temp] (
		Id, TxnSyncId, BusinessKey, TransactionId, PackageNo, SwiftKey, SwiftMessageState, SwiftMessageDescription, EftKey, EftMessageState, EftMessageDescription, 
		StateId, StateMaker, StateDate
	)
	SELECT
		Id, TxnSyncId, BusinessKey, TransactionId, PackageNo, SwiftKey, SwiftMessageState, SwiftMessageDescription, EftKey, EftMessageState, EftMessageDescription, 
		StateId, StateMaker, StateDate
	FROM [dbo].[TxnSyncDetail];
	SET IDENTITY_INSERT [dbo].[TxnSyncDetail_Temp] OFF;

	DROP TABLE dbo.TxnSyncDetail;
    EXEC sp_rename 'dbo.TxnSyncDetail_Temp', 'TxnSyncDetail';

	--Table DerivativesRevaluation
	CREATE TABLE [dbo].[DerivativesRevaluation_Temp](
		[Id] [bigint] IDENTITY(1,1) NOT NULL,
		[CalculationDate] [date] NOT NULL,
		[GenerationDate] [datetime] NOT NULL,
		[TxnId] [bigint] NOT NULL,
		[LogicalReference] [nvarchar](80) NOT NULL,
		[ProductTypeId] [int] NOT NULL,
		[CounterpartyId] [int] NOT NULL,
		[InputDateTime] [datetime] NOT NULL,
		[ReceiveValueDate] [date] NOT NULL,
		[ReceiveMaturityDate] [date] NOT NULL,
		[PayValueDate] [date] NOT NULL,
		[PayMaturityDate] [date] NOT NULL,
		[PayOfUpdate] [date] NULL,
		[Trader] [nvarchar](80) NOT NULL,
		[ReceivePrincipalAmount] [decimal](38, 10) NOT NULL,
		[ReceiveCurrency] [nvarchar](3) NOT NULL,
		[ReceiveRateTypeId] [int] NOT NULL,
		[ReceiveRate] [decimal](18, 10) NULL,
		[ReceiveFloatingRateTypeId] [int] NULL,
		[ReceiveSpread] [int] NOT NULL,
		[ReceivePaymentFrequencyId] [int] NOT NULL,
		[ReceiveInterestMethodsId] [int] NOT NULL,
		[ReceiveInterestMethodsFrequencyId] [int] NOT NULL,
		[ReceiveDateBasisCode] [nvarchar](4) NOT NULL,
		[ReceiveIndexChartId] [int] NOT NULL,
		[ReceiveDaysInYear] [int] NOT NULL,
		[ReceivePaymentLagDays] [int] NOT NULL,
		[ReceiveFixingLagDays] [int] NOT NULL,
		[ReceiveAccrualSpotRate] [decimal](18, 10) NOT NULL,
		[ReceivePeriodNumber] [int] NOT NULL,
		[ReceivePeriodFixingDate] [date] NULL,
		[ReceivePeriodStartDate] [date] NOT NULL,
		[ReceivePeriodEndDate] [date] NOT NULL,
		[ReceivePeriodPaymentDate] [date] NOT NULL,
		[ReceivePeriodDaysInYear] [int] NOT NULL,
		[ReceivePeriodPrincipalAmount] [decimal](38, 10) NOT NULL,
		[ReceivePeriodDays] [int] NOT NULL,
		[ReceivePeriodDaysPassed] [int] NOT NULL,
		[ReceivePeriodDaysToMaturity] [int] NOT NULL,
		[ReceivePeriodRateTypeId] [int] NOT NULL,
		[ReceivePeriodRate] [decimal](18, 10) NOT NULL,
		[ReceivePeriodFloatingRateTypeId] [int] NULL,
		[ReceivePeriodSpread] [int] NOT NULL,
		[ReceivePeriodCCY] [nvarchar](3) NOT NULL,
		[ReceivePeriodAmount] [decimal](38, 10) NOT NULL,
		[ReceivePeriodLCY] [nvarchar](3) NOT NULL,
		[ReceivePeriodAmountLCY] [decimal](38, 10) NOT NULL,
		[ReceivePeriodAccrualRate] [decimal](18, 10) NOT NULL,
		[ReceivePeriodAccrualAmountIRR] [decimal](38, 10) NOT NULL,
		[ReceivePeriodAccrualAmountSL] [decimal](38, 10) NOT NULL,
		[ReceivePeriodAccrualAmountCCY] [nvarchar](3) NOT NULL,
		[ReceivePeriodAccrualAmountLCYIRR] [decimal](38, 10) NOT NULL,
		[ReceivePeriodAccrualAmountLCYSL] [decimal](38, 10) NOT NULL,
		[ReceivePeriodAccrualAmountLCY] [nvarchar](3) NOT NULL,
		[ReceivePrincipalAmountNPV] [decimal](38, 10) NOT NULL,
		[ReceivePrincipalAmountNPVCCY] [nvarchar](3) NOT NULL,
		[ReceivePrincipalAmountNPVLCY] [decimal](38, 10) NOT NULL,
		[ReceivePrincipalAmountNPVLCYCode] [nvarchar](3) NOT NULL,
		[ReceiveTotalAmountNPV] [decimal](38, 10) NOT NULL,
		[ReceiveTotalAmountNPVCCY] [nvarchar](3) NOT NULL,
		[ReceiveTotalAmountNPVLCY] [decimal](38, 10) NOT NULL,
		[ReceiveTotalAmountNPVLCYCode] [nvarchar](3) NOT NULL,
		[PayPrincipalAmount] [decimal](38, 10) NOT NULL,
		[PayCurrency] [nvarchar](3) NOT NULL,
		[PayRateTypeId] [int] NOT NULL,
		[PayRate] [decimal](18, 10) NULL,
		[PayFloatingRateTypeId] [int] NULL,
		[PaySpread] [int] NOT NULL,
		[PayPaymentFrequencyId] [int] NOT NULL,
		[PayInterestMethodsId] [int] NOT NULL,
		[PayInterestMethodsFrequencyId] [int] NOT NULL,
		[PayDateBasisCode] [nvarchar](4) NOT NULL,
		[PayIndexChartId] [int] NOT NULL,
		[PayDaysInYear] [int] NOT NULL,
		[PayPaymentLagDays] [int] NOT NULL,
		[PayFixingLagDays] [int] NOT NULL,
		[PayAccrualSpotRate] [decimal](18, 10) NOT NULL,
		[PayPeriodNumber] [int] NOT NULL,
		[PayPeriodFixingDate] [date] NULL,
		[PayPeriodStartDate] [date] NOT NULL,
		[PayPeriodEndDate] [date] NOT NULL,
		[PayPeriodPaymentDate] [date] NOT NULL,
		[PayPeriodDaysInYear] [int] NOT NULL,
		[PayPeriodPrincipalAmount] [decimal](38, 10) NOT NULL,
		[PayPeriodDays] [int] NOT NULL,
		[PayPeriodDaysPassed] [int] NOT NULL,
		[PayPeriodDaysToMaturity] [int] NOT NULL,
		[PayPeriodRateTypeId] [int] NOT NULL,
		[PayPeriodRate] [decimal](18, 10) NOT NULL,
		[PayPeriodFloatingRateTypeId] [int] NULL,
		[PayPeriodSpread] [int] NOT NULL,
		[PayPeriodCCY] [nvarchar](3) NOT NULL,
		[PayPeriodAmount] [decimal](38, 10) NOT NULL,
		[PayPeriodLCY] [nvarchar](3) NOT NULL,
		[PayPeriodAmountLCY] [decimal](38, 10) NOT NULL,
		[PayPeriodAccrualRate] [decimal](18, 10) NOT NULL,
		[PayPeriodAccrualAmountIRR] [decimal](38, 10) NOT NULL,
		[PayPeriodAccrualAmountSL] [decimal](38, 10) NOT NULL,
		[PayPeriodAccrualAmountCCY] [nvarchar](3) NOT NULL,
		[PayPeriodAccrualAmountLCYIRR] [decimal](38, 10) NOT NULL,
		[PayPeriodAccrualAmountLCYSL] [decimal](38, 10) NOT NULL,
		[PayPeriodAccrualAmountLCY] [nvarchar](3) NOT NULL,
		[PayPrincipalAmountNPV] [decimal](38, 10) NOT NULL,
		[PayPrincipalAmountNPVCCY] [nvarchar](3) NOT NULL,
		[PayPrincipalAmountNPVLCY] [decimal](38, 10) NOT NULL,
		[PayPrincipalAmountNPVLCYCode] [nvarchar](3) NOT NULL,
		[PayTotalAmountNPV] [decimal](38, 10) NOT NULL,
		[PayTotalAmountNPVCCY] [nvarchar](3) NOT NULL,
		[PayTotalAmountNPVLCY] [decimal](38, 10) NOT NULL,
		[PayTotalAmountNPVLCYCode] [nvarchar](3) NOT NULL,
		[TotalMTMAmount] [decimal](38, 10) NOT NULL,
		[TotalMTMAmountCCY] [nvarchar](3) NOT NULL,
		[TotalMTMAmountLCY] [decimal](38, 10) NOT NULL,
		[TotalMTMAmountLCYCode] [nvarchar](3) NOT NULL,
		[AccrualSpotRateABM] [nvarchar](1) NOT NULL,
		[AccEntryMainId] [int] NOT NULL,
		[TotalMTMAmountSpotRate] [decimal](18, 10) NULL,
		[ReceivePaymentDate] [date] NOT NULL,
		[PayPaymentDate] [date] NOT NULL
	)

	SET IDENTITY_INSERT [dbo].[DerivativesRevaluation_Temp] ON;
	INSERT INTO [dbo].[DerivativesRevaluation_Temp] (
		Id, CalculationDate, GenerationDate, TxnId, LogicalReference, ProductTypeId, CounterpartyId, InputDateTime, ReceiveValueDate, ReceiveMaturityDate, PayValueDate, 
		PayMaturityDate, PayOfUpdate, Trader, ReceivePrincipalAmount, ReceiveCurrency, ReceiveRateTypeId, ReceiveRate, ReceiveFloatingRateTypeId, ReceiveSpread, 
		ReceivePaymentFrequencyId, ReceiveInterestMethodsId, ReceiveInterestMethodsFrequencyId, ReceiveDateBasisCode, ReceiveIndexChartId, ReceiveDaysInYear, 
		ReceivePaymentLagDays, ReceiveFixingLagDays, ReceiveAccrualSpotRate, ReceivePeriodNumber, ReceivePeriodFixingDate, ReceivePeriodStartDate, ReceivePeriodEndDate, 
		ReceivePeriodPaymentDate, ReceivePeriodDaysInYear, ReceivePeriodPrincipalAmount, ReceivePeriodDays, ReceivePeriodDaysPassed, ReceivePeriodDaysToMaturity,
		ReceivePeriodRateTypeId, ReceivePeriodRate, ReceivePeriodFloatingRateTypeId, ReceivePeriodSpread, ReceivePeriodCCY, ReceivePeriodAmount, ReceivePeriodLCY, 
		ReceivePeriodAmountLCY, ReceivePeriodAccrualRate, ReceivePeriodAccrualAmountIRR, ReceivePeriodAccrualAmountSL, ReceivePeriodAccrualAmountCCY, 
		ReceivePeriodAccrualAmountLCYIRR, ReceivePeriodAccrualAmountLCYSL, ReceivePeriodAccrualAmountLCY, ReceivePrincipalAmountNPV, ReceivePrincipalAmountNPVCCY, 
		ReceivePrincipalAmountNPVLCY, ReceivePrincipalAmountNPVLCYCode, ReceiveTotalAmountNPV, ReceiveTotalAmountNPVCCY, ReceiveTotalAmountNPVLCY, 
		ReceiveTotalAmountNPVLCYCode, PayPrincipalAmount, PayCurrency, PayRateTypeId, PayRate, PayFloatingRateTypeId, PaySpread, PayPaymentFrequencyId, 
		PayInterestMethodsId, PayInterestMethodsFrequencyId, PayDateBasisCode, PayIndexChartId, PayDaysInYear, PayPaymentLagDays, PayFixingLagDays, 
		PayAccrualSpotRate, PayPeriodNumber, PayPeriodFixingDate, PayPeriodStartDate, PayPeriodEndDate, PayPeriodPaymentDate, PayPeriodDaysInYear, 
		PayPeriodPrincipalAmount, PayPeriodDays, PayPeriodDaysPassed, PayPeriodDaysToMaturity, PayPeriodRateTypeId, PayPeriodRate, PayPeriodFloatingRateTypeId, 
		PayPeriodSpread, PayPeriodCCY, PayPeriodAmount, PayPeriodLCY, PayPeriodAmountLCY, PayPeriodAccrualRate, PayPeriodAccrualAmountIRR, PayPeriodAccrualAmountSL, 
		PayPeriodAccrualAmountCCY, PayPeriodAccrualAmountLCYIRR, PayPeriodAccrualAmountLCYSL, PayPeriodAccrualAmountLCY, PayPrincipalAmountNPV, PayPrincipalAmountNPVCCY, 
		PayPrincipalAmountNPVLCY, PayPrincipalAmountNPVLCYCode, PayTotalAmountNPV, PayTotalAmountNPVCCY, PayTotalAmountNPVLCY, PayTotalAmountNPVLCYCode, TotalMTMAmount, 
		TotalMTMAmountCCY, TotalMTMAmountLCY, TotalMTMAmountLCYCode, AccrualSpotRateABM, AccEntryMainId, TotalMTMAmountSpotRate, ReceivePaymentDate, PayPaymentDate
	)
	SELECT
		Id, CalculationDate, GenerationDate, TxnId, LogicalReference, ProductTypeId, CounterpartyId, InputDateTime, ReceiveValueDate, ReceiveMaturityDate, PayValueDate, 
		PayMaturityDate, PayOfUpdate, Trader, ReceivePrincipalAmount, ReceiveCurrency, ReceiveRateTypeId, ReceiveRate, ReceiveFloatingRateTypeId, ReceiveSpread, 
		ReceivePaymentFrequencyId, ReceiveInterestMethodsId, ReceiveInterestMethodsFrequencyId, ReceiveDateBasisCode, ReceiveIndexChartId, ReceiveDaysInYear, 
		ReceivePaymentLagDays, ReceiveFixingLagDays, ReceiveAccrualSpotRate, ReceivePeriodNumber, ReceivePeriodFixingDate, ReceivePeriodStartDate, ReceivePeriodEndDate, 
		ReceivePeriodPaymentDate, ReceivePeriodDaysInYear, ReceivePeriodPrincipalAmount, ReceivePeriodDays, ReceivePeriodDaysPassed, ReceivePeriodDaysToMaturity, 
		ReceivePeriodRateTypeId, ReceivePeriodRate, ReceivePeriodFloatingRateTypeId, ReceivePeriodSpread, ReceivePeriodCCY, ReceivePeriodAmount, ReceivePeriodLCY, 
		ReceivePeriodAmountLCY, ReceivePeriodAccrualRate, ReceivePeriodAccrualAmountIRR, ReceivePeriodAccrualAmountSL, ReceivePeriodAccrualAmountCCY, 
		ReceivePeriodAccrualAmountLCYIRR, ReceivePeriodAccrualAmountLCYSL, ReceivePeriodAccrualAmountLCY, ReceivePrincipalAmountNPV, ReceivePrincipalAmountNPVCCY, 
		ReceivePrincipalAmountNPVLCY, ReceivePrincipalAmountNPVLCYCode, ReceiveTotalAmountNPV, ReceiveTotalAmountNPVCCY, ReceiveTotalAmountNPVLCY, 
		ReceiveTotalAmountNPVLCYCode, PayPrincipalAmount, PayCurrency, PayRateTypeId, PayRate, PayFloatingRateTypeId, PaySpread, PayPaymentFrequencyId, 
		PayInterestMethodsId, PayInterestMethodsFrequencyId, PayDateBasisCode, PayIndexChartId, PayDaysInYear, PayPaymentLagDays, PayFixingLagDays, PayAccrualSpotRate, 
		PayPeriodNumber, PayPeriodFixingDate, PayPeriodStartDate, PayPeriodEndDate, PayPeriodPaymentDate, PayPeriodDaysInYear, PayPeriodPrincipalAmount,
		PayPeriodDays, PayPeriodDaysPassed, PayPeriodDaysToMaturity, PayPeriodRateTypeId, PayPeriodRate, PayPeriodFloatingRateTypeId, PayPeriodSpread, PayPeriodCCY, 
		PayPeriodAmount, PayPeriodLCY, PayPeriodAmountLCY, PayPeriodAccrualRate, PayPeriodAccrualAmountIRR, PayPeriodAccrualAmountSL, PayPeriodAccrualAmountCCY, 
		PayPeriodAccrualAmountLCYIRR, PayPeriodAccrualAmountLCYSL, PayPeriodAccrualAmountLCY, PayPrincipalAmountNPV, PayPrincipalAmountNPVCCY, PayPrincipalAmountNPVLCY, 
		PayPrincipalAmountNPVLCYCode, PayTotalAmountNPV, PayTotalAmountNPVCCY, PayTotalAmountNPVLCY, PayTotalAmountNPVLCYCode, TotalMTMAmount, TotalMTMAmountCCY, 
		TotalMTMAmountLCY, TotalMTMAmountLCYCode, AccrualSpotRateABM, AccEntryMainId, TotalMTMAmountSpotRate, ReceivePaymentDate, PayPaymentDate
	FROM [dbo].[DerivativesRevaluation];
	SET IDENTITY_INSERT [dbo].[DerivativesRevaluation_Temp] OFF;

	DROP TABLE dbo.DerivativesRevaluation;
    EXEC sp_rename 'dbo.DerivativesRevaluation_Temp', 'DerivativesRevaluation';

	--Table TxnTax
	CREATE TABLE [dbo].[TxnTax_Temp](
		[Id] [bigint] IDENTITY(1,1) NOT NULL,
		[TxnId] [bigint] NOT NULL,
		[TaxId] [int] NOT NULL,
		[TaxDate] [datetime] NULL,
		[Amount] [decimal](38, 10) NULL,
		[TaxRate] [decimal](18, 10) NULL,
		[Flags] [int] NOT NULL,
		[Ccy] [nvarchar](3) NULL
	)

	SET IDENTITY_INSERT [dbo].[TxnTax_Temp] ON;
	INSERT INTO [dbo].[TxnTax_Temp] (
		Id, TxnId, TaxId, TaxDate, Amount, TaxRate, Flags, Ccy)
	SELECT
		Id, TxnId, TaxId, TaxDate, Amount, TaxRate, Flags, Ccy
	FROM [dbo].[TxnTax];
	SET IDENTITY_INSERT [dbo].[TxnTax_Temp] OFF;

	DROP TABLE dbo.TxnTax;
    EXEC sp_rename 'dbo.TxnTax_Temp', 'TxnTax';

--4.Re-creating Primary Key Constraints-------------------------------------------------------------------------------------------------

	ALTER TABLE dbo.TxnSync ADD CONSTRAINT PK_TxnSync PRIMARY KEY CLUSTERED (Id);
    ALTER TABLE dbo.TxnSyncDetail ADD CONSTRAINT PK_TxnSyncDetail PRIMARY KEY CLUSTERED (Id);
	ALTER TABLE dbo.DerivativesRevaluation ADD CONSTRAINT PK_DerivativesRevaluation PRIMARY KEY CLUSTERED (Id);
	ALTER TABLE dbo.TxnTax ADD CONSTRAINT PK_TxnTax PRIMARY KEY CLUSTERED (Id);

    COMMIT TRANSACTION;
	PRINT 'Script completed successfully. All changes have been committed.';

END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    PRINT 'An error occurred during execution. All changes have been rolled back.';
    
    THROW;
END CATCH;
GO