USE NetTrexDerivSWP;
GO

/***************************************************************************************************
* This script is designed to change the data type of primary and foreign key columns from INT to BIGINT
* for the TXN CASHFLOW and TXN CASHFLOW HISTORY tables.
***************************************************************************************************/

BEGIN TRANSACTION;

BEGIN TRY

--1.Check if this change has already been applied ---------------------------------------------------------------------------------
    
	IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'TxnCashFlow' AND COLUMN_NAME = 'Id' AND DATA_TYPE = 'bigint')
	BEGIN
		 PRINT 'The change of primary and foreign key columns from INT to BIGINT has already been made.';
		 RETURN;
	END

--2.Dropping Trigger---------------------------------------------------------------------------------------------------------------
	
	IF OBJECT_ID('dbo.TxnCashFlowTrigger', 'TR') IS NOT NULL
        DROP TRIGGER dbo.TxnCashFlowTrigger;

--3.Dropping Primary Key Constraints-----------------------------------------------------------------------------------------------

    IF OBJECT_ID('dbo.PK_TxnCashFlow', 'PK') IS NOT NULL
	    ALTER TABLE dbo.TxnCashFlow DROP CONSTRAINT PK_TxnCashFlow;

    IF OBJECT_ID('dbo.PK_TxnCashFlowHistory', 'PK') IS NOT NULL
	    ALTER TABLE dbo.TxnCashFlowHistory DROP CONSTRAINT PK_TxnCashFlowHistory;

--4.Migrating tables with IDENTITY columns to use BIGINT------------------------------------------------------------------------------

    CREATE TABLE [dbo].[TxnCashFlow_Temp](
		[Id] [bigint] IDENTITY(1,1) NOT NULL,
		[TxnId] [bigint] NOT NULL,
		[PeriodNumber] [int] NULL,
		[PrincipalAmount] [decimal](38, 10) NOT NULL,
		[FlowTypeId] [int] NOT NULL,
		[FixingDate] [date] NULL,
		[StartDate] [date] NULL,
		[EndDate] [date] NULL,
		[PaymentDate] [date] NULL,
		[Days] [int] NOT NULL,
		[Rate] [decimal](18, 10) NOT NULL,
		[Spread] [int] NOT NULL,
		[CashFlowAmount] [decimal](38, 10) NOT NULL,
		[CashFlowLegType] [nvarchar](20) NOT NULL,
		[Currency] [nvarchar](3) NOT NULL,
		[RateTypeId] [int] NOT NULL,
		[FloatingRateTypeId] [int] NULL,
		[PaymentFrequencyId] [int] NOT NULL,
		[InterestMethodsId] [int] NOT NULL,
		[InterestMethodsFrequencyId] [int] NOT NULL,
		[DateBasisCode] [nvarchar](4) NOT NULL,
		[DaysInYear] [int] NOT NULL,
		[PaymentLagDays] [int] NOT NULL,
		[FixingLagDays] [int] NOT NULL,
		[IsCompound] [bit] NOT NULL,
		[OutgoingCorrespondentId] [int] NULL,
		[OutgoingCorrespondentAccountNumber] [bigint] NULL,
		[TheirBeneficiaryCorrespondentName] [nvarchar](500) NULL,
		[TheirBeneficiaryCorrespondentSwiftCode] [nvarchar](50) NULL,
		[TheirBeneficiaryCorrespondentAccountNumber] [nvarchar](500) NULL,
		[TheirSenderCorrespondentName] [nvarchar](500) NULL,
		[TheirSenderCorrespondentSwiftCode] [nvarchar](50) NULL,
		[TheirSenderCorrespondentAccountNumber] [nvarchar](500) NULL,
		[IncomingCorrespondentId] [int] NULL,
		[IncomingCorrespondentAccountNumber] [bigint] NULL,
		[Instructions] [nvarchar](1000) NULL,
		[StateId] [int] NOT NULL,
		[StateMaker] [nvarchar](80) NOT NULL,
		[StateDate] [datetime] NOT NULL,
		[LogicalReference] [nvarchar](80) NULL,
		[SendConfirmation] [bit] NULL,
		[SendPayment] [bit] NULL,
		[SendNoticeToReceive] [bit] NULL,
		[PaymentInstructionTypeId] [int] NULL,
		[SettlementTypeId] [int] NULL,
		[OutgoingCorrespondentAccountGLCode] [nvarchar](10) NULL,
		[OutgoingPaymentAccountingType] [nvarchar](50) NULL,
		[OutgoingPaymentAccountingGLType] [nvarchar](50) NULL,
		[OutgoingPaymentAccountingGL] [nvarchar](10) NULL,
		[IncomingCorrespondentAccountGLCode] [nvarchar](10) NULL,
		[IncomingPaymentAccountingType] [nvarchar](50) NULL,
		[IncomingPaymentAccountingGLType] [nvarchar](50) NULL,
		[IncomingPaymentAccountingGL] [nvarchar](10) NULL,
		[TheirSenderCorrespondentId] [int] NULL,
		[TheirSenderCorrespondentGLCode] [nvarchar](10) NULL,
		[TheirBeneficiaryCorrespondentId] [int] NULL,
		[TheirBeneficiaryCorrespondentGLCode] [nvarchar](10) NULL,
		[IsPaymentCompleted] [bit] NOT NULL,
		[PaymentDirection] [nvarchar](10) NOT NULL
	)

	SET IDENTITY_INSERT [dbo].[TxnCashFlow_Temp] ON;
	INSERT INTO [dbo].[TxnCashFlow_Temp] (
		Id, TxnId, PeriodNumber, PrincipalAmount, FlowTypeId, FixingDate, StartDate, EndDate, PaymentDate, Days, Rate, Spread, CashFlowAmount, 
		CashFlowLegType, Currency, RateTypeId, FloatingRateTypeId, PaymentFrequencyId, InterestMethodsId, InterestMethodsFrequencyId, DateBasisCode, DaysInYear,
		PaymentLagDays, FixingLagDays, IsCompound, OutgoingCorrespondentId, OutgoingCorrespondentAccountNumber, TheirBeneficiaryCorrespondentName, 
		TheirBeneficiaryCorrespondentSwiftCode, TheirBeneficiaryCorrespondentAccountNumber, TheirSenderCorrespondentName, TheirSenderCorrespondentSwiftCode, 
		TheirSenderCorrespondentAccountNumber, IncomingCorrespondentId, IncomingCorrespondentAccountNumber, Instructions, StateId, StateMaker, StateDate, LogicalReference, 
		SendConfirmation, SendPayment, SendNoticeToReceive, PaymentInstructionTypeId, SettlementTypeId, OutgoingCorrespondentAccountGLCode, OutgoingPaymentAccountingType, 
		OutgoingPaymentAccountingGLType, OutgoingPaymentAccountingGL, IncomingCorrespondentAccountGLCode, IncomingPaymentAccountingType, IncomingPaymentAccountingGLType, 
		IncomingPaymentAccountingGL, TheirSenderCorrespondentId, TheirSenderCorrespondentGLCode, TheirBeneficiaryCorrespondentId, TheirBeneficiaryCorrespondentGLCode, 
		IsPaymentCompleted, PaymentDirection
	)
	SELECT
		Id, TxnId, PeriodNumber, PrincipalAmount, FlowTypeId, FixingDate, StartDate, EndDate, PaymentDate, Days, Rate, Spread, CashFlowAmount, 
		CashFlowLegType, Currency, RateTypeId, FloatingRateTypeId, PaymentFrequencyId, InterestMethodsId, InterestMethodsFrequencyId, DateBasisCode, DaysInYear,
		PaymentLagDays, FixingLagDays, IsCompound, OutgoingCorrespondentId, OutgoingCorrespondentAccountNumber, TheirBeneficiaryCorrespondentName, 
		TheirBeneficiaryCorrespondentSwiftCode, TheirBeneficiaryCorrespondentAccountNumber, TheirSenderCorrespondentName, TheirSenderCorrespondentSwiftCode, 
		TheirSenderCorrespondentAccountNumber, IncomingCorrespondentId, IncomingCorrespondentAccountNumber, Instructions, StateId, StateMaker, StateDate, LogicalReference, 
		SendConfirmation, SendPayment, SendNoticeToReceive, PaymentInstructionTypeId, SettlementTypeId, OutgoingCorrespondentAccountGLCode, OutgoingPaymentAccountingType,
		OutgoingPaymentAccountingGLType, OutgoingPaymentAccountingGL, IncomingCorrespondentAccountGLCode, IncomingPaymentAccountingType, IncomingPaymentAccountingGLType, 
		IncomingPaymentAccountingGL, TheirSenderCorrespondentId, TheirSenderCorrespondentGLCode, TheirBeneficiaryCorrespondentId, TheirBeneficiaryCorrespondentGLCode, 
		IsPaymentCompleted, PaymentDirection
	FROM [dbo].[TxnCashFlow];
	SET IDENTITY_INSERT [dbo].[TxnCashFlow_Temp] OFF;

	DROP TABLE dbo.TxnCashFlow;
    EXEC sp_rename 'dbo.TxnCashFlow_Temp', 'TxnCashFlow';


	CREATE TABLE [dbo].[TxnCashFlowHistory_Temp](
		[HistoryId] [bigint] IDENTITY(1,1) NOT NULL,
		[Id] [bigint] NOT NULL,
		[TxnId] [bigint] NOT NULL,
		[PeriodNumber] [int] NULL,
		[PrincipalAmount] [decimal](38, 10) NOT NULL,
		[FlowTypeId] [int] NOT NULL,
		[FixingDate] [date] NULL,
		[StartDate] [date] NULL,
		[EndDate] [date] NULL,
		[PaymentDate] [date] NULL,
		[Days] [int] NOT NULL,
		[Rate] [decimal](18, 10) NOT NULL,
		[Spread] [int] NOT NULL,
		[CashFlowAmount] [decimal](38, 10) NOT NULL,
		[CashFlowLegType] [nvarchar](20) NOT NULL,
		[Currency] [nvarchar](3) NOT NULL,
		[RateTypeId] [int] NOT NULL,
		[FloatingRateTypeId] [int] NULL,
		[PaymentFrequencyId] [int] NOT NULL,
		[InterestMethodsId] [int] NOT NULL,
		[InterestMethodsFrequencyId] [int] NOT NULL,
		[DateBasisCode] [nvarchar](4) NOT NULL,
		[DaysInYear] [int] NOT NULL,
		[PaymentLagDays] [int] NOT NULL,
		[FixingLagDays] [int] NOT NULL,
		[IsCompound] [bit] NOT NULL,
		[OutgoingCorrespondentId] [int] NULL,
		[OutgoingCorrespondentAccountNumber] [bigint] NULL,
		[TheirBeneficiaryCorrespondentName] [nvarchar](500) NULL,
		[TheirBeneficiaryCorrespondentSwiftCode] [nvarchar](50) NULL,
		[TheirBeneficiaryCorrespondentAccountNumber] [nvarchar](500) NULL,
		[TheirSenderCorrespondentName] [nvarchar](500) NULL,
		[TheirSenderCorrespondentSwiftCode] [nvarchar](50) NULL,
		[TheirSenderCorrespondentAccountNumber] [nvarchar](500) NULL,
		[IncomingCorrespondentId] [int] NULL,
		[IncomingCorrespondentAccountNumber] [bigint] NULL,
		[Instructions] [nvarchar](1000) NULL,
		[StateId] [int] NOT NULL,
		[StateMaker] [nvarchar](80) NOT NULL,
		[StateDate] [datetime] NOT NULL,
		[LogicalReference] [nvarchar](80) NULL,
		[SendConfirmation] [bit] NULL,
		[SendPayment] [bit] NULL,
		[SendNoticeToReceive] [bit] NULL,
		[PaymentInstructionTypeId] [int] NULL,
		[SettlementTypeId] [int] NULL,
		[OutgoingCorrespondentAccountGLCode] [nvarchar](10) NULL,
		[OutgoingPaymentAccountingType] [nvarchar](50) NULL,
		[OutgoingPaymentAccountingGLType] [nvarchar](50) NULL,
		[OutgoingPaymentAccountingGL] [nvarchar](10) NULL,
		[IncomingCorrespondentAccountGLCode] [nvarchar](10) NULL,
		[IncomingPaymentAccountingType] [nvarchar](50) NULL,
		[IncomingPaymentAccountingGLType] [nvarchar](50) NULL,
		[IncomingPaymentAccountingGL] [nvarchar](10) NULL,
		[TheirSenderCorrespondentId] [int] NULL,
		[TheirSenderCorrespondentGLCode] [nvarchar](10) NULL,
		[TheirBeneficiaryCorrespondentId] [int] NULL,
		[TheirBeneficiaryCorrespondentGLCode] [nvarchar](10) NULL,
		[IsPaymentCompleted] [bit] NOT NULL,
		[PaymentDirection] [nvarchar](10) NOT NULL
	)

	SET IDENTITY_INSERT [dbo].[TxnCashFlowHistory_Temp] ON;

	INSERT INTO [dbo].[TxnCashFlowHistory_Temp] (
		HistoryId, Id, TxnId, PeriodNumber, PrincipalAmount, FlowTypeId, FixingDate, StartDate, EndDate, PaymentDate, Days, Rate, Spread, CashFlowAmount, 
		CashFlowLegType, Currency, RateTypeId, FloatingRateTypeId, PaymentFrequencyId, InterestMethodsId, InterestMethodsFrequencyId, DateBasisCode, DaysInYear,
		PaymentLagDays, FixingLagDays, IsCompound, OutgoingCorrespondentId, OutgoingCorrespondentAccountNumber, TheirBeneficiaryCorrespondentName, 
		TheirBeneficiaryCorrespondentSwiftCode, TheirBeneficiaryCorrespondentAccountNumber, TheirSenderCorrespondentName, TheirSenderCorrespondentSwiftCode, 
		TheirSenderCorrespondentAccountNumber, IncomingCorrespondentId, IncomingCorrespondentAccountNumber, Instructions, StateId, StateMaker, StateDate, LogicalReference, 
		SendConfirmation, SendPayment, SendNoticeToReceive, PaymentInstructionTypeId, SettlementTypeId, OutgoingCorrespondentAccountGLCode, OutgoingPaymentAccountingType, 
		OutgoingPaymentAccountingGLType, OutgoingPaymentAccountingGL, IncomingCorrespondentAccountGLCode, IncomingPaymentAccountingType, IncomingPaymentAccountingGLType, 
		IncomingPaymentAccountingGL, TheirSenderCorrespondentId, TheirSenderCorrespondentGLCode, TheirBeneficiaryCorrespondentId, TheirBeneficiaryCorrespondentGLCode, 
		IsPaymentCompleted, PaymentDirection
	)
	SELECT
		HistoryId, Id, TxnId, PeriodNumber, PrincipalAmount, FlowTypeId, FixingDate, StartDate, EndDate, PaymentDate, Days, Rate, Spread, CashFlowAmount, 
		CashFlowLegType, Currency, RateTypeId, FloatingRateTypeId, PaymentFrequencyId, InterestMethodsId, InterestMethodsFrequencyId, DateBasisCode, DaysInYear,
		PaymentLagDays, FixingLagDays, IsCompound, OutgoingCorrespondentId, OutgoingCorrespondentAccountNumber, TheirBeneficiaryCorrespondentName, 
		TheirBeneficiaryCorrespondentSwiftCode, TheirBeneficiaryCorrespondentAccountNumber, TheirSenderCorrespondentName, TheirSenderCorrespondentSwiftCode, 
		TheirSenderCorrespondentAccountNumber, IncomingCorrespondentId, IncomingCorrespondentAccountNumber, Instructions, StateId, StateMaker, StateDate, LogicalReference, 
		SendConfirmation, SendPayment, SendNoticeToReceive, PaymentInstructionTypeId, SettlementTypeId, OutgoingCorrespondentAccountGLCode, OutgoingPaymentAccountingType,
		OutgoingPaymentAccountingGLType, OutgoingPaymentAccountingGL, IncomingCorrespondentAccountGLCode, IncomingPaymentAccountingType, IncomingPaymentAccountingGLType, 
		IncomingPaymentAccountingGL, TheirSenderCorrespondentId, TheirSenderCorrespondentGLCode, TheirBeneficiaryCorrespondentId, TheirBeneficiaryCorrespondentGLCode, 
		IsPaymentCompleted, PaymentDirection
	FROM [dbo].[TxnCashFlowHistory];

	SET IDENTITY_INSERT [dbo].[TxnCashFlowHistory_Temp] OFF;

	DROP TABLE dbo.TxnCashFlowHistory;
    EXEC sp_rename 'dbo.TxnCashFlowHistory_Temp', 'TxnCashFlowHistory';

--5.Re-creating Primary Key Constraints-------------------------------------------------------------------------------------------------

	ALTER TABLE dbo.TxnCashFlow ADD CONSTRAINT PK_TxnCashFlow PRIMARY KEY CLUSTERED (Id);
    ALTER TABLE dbo.TxnCashFlowHistory ADD CONSTRAINT PK_TxnCashFlowHistory PRIMARY KEY CLUSTERED (HistoryId);

--6.Re-creating Trigger-------------------------------------------------------------------------------------------------------------
    EXEC('CREATE TRIGGER [dbo].[TxnCashFlowTrigger] ON [dbo].[TxnCashFlow]
			FOR INSERT, UPDATE
			AS
			INSERT INTO [dbo].[TxnCashFlowHistory] SELECT * FROM inserted;');


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