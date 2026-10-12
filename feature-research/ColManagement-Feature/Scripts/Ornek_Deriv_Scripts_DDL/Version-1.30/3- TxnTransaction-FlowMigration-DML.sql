USE NetTrexDerivSWP;
GO

/***************************************************************************************************
* This script is designed to change the data type of primary and foreign key columns from INT to BIGINT
* for the TXN TRANSACTION and TXN TRANSACTION HISTORY tables.
***************************************************************************************************/

BEGIN TRANSACTION;

BEGIN TRY

--1.Check if this change has already been applied ---------------------------------------------------------------------------------
    
	IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'TxnTransaction' AND COLUMN_NAME = 'Id' AND DATA_TYPE = 'bigint')
	BEGIN
		 PRINT 'The change of primary and foreign key columns from INT to BIGINT has already been made.';
		 RETURN;
	END


--2.Dropping Primary Key Constraints-----------------------------------------------------------------------------------------------

    IF OBJECT_ID('dbo.PK_TxnTransaction', 'PK') IS NOT NULL
	    ALTER TABLE dbo.TxnTransaction DROP CONSTRAINT PK_TxnTransaction;

    IF OBJECT_ID('dbo.PK_TxnTransactionHistory', 'PK') IS NOT NULL
	    ALTER TABLE dbo.TxnTransactionHistory DROP CONSTRAINT PK_TxnTransactionHistory;

--3.Migrating tables with IDENTITY columns to use BIGINT------------------------------------------------------------------------------

    ALTER TABLE [dbo].[TxnTransaction] ALTER COLUMN [Id] BIGINT NOT NULL;

    ALTER TABLE [dbo].[TxnTransaction] ADD CONSTRAINT [PK_TxnTransaction] PRIMARY KEY CLUSTERED ([Id]);


    CREATE TABLE [dbo].[TxnTransactionHistory_Temp](
		[HistoryId] [bigint] IDENTITY(1,1) NOT NULL,
		[Id] [bigint] NOT NULL,
		[LogicalReference] [nvarchar](80) NOT NULL,
		[TradeDate] [date] NOT NULL,
		[InputDateTime] [datetime] NOT NULL,
		[ReceiveValueDate] [date] NOT NULL,
		[PayValueDate] [date] NOT NULL,
		[ReceiveMaturityDate] [date] NOT NULL,
		[PayMaturityDate] [date] NOT NULL,
		[Trader] [nvarchar](80) NOT NULL,
		[CounterpartyId] [int] NOT NULL,
		[PortfolioId] [int] NOT NULL,
		[ProductTypeId] [int] NOT NULL,
		[PayOfUpdate] [date] NULL,
		[B2BRefTransaction] [nvarchar](1000) NULL,
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
		[PayPaymentLagDays] [int] NOT NULL,
		[PayDaysInYear] [int] NOT NULL,
		[PayFixingLagDays] [int] NOT NULL,
		[Instructions] [nvarchar](1000) NULL,
		[LiquidationDate] [date] NULL,
		[LiquidationTypeId] [int] NULL,
		[LiquidationPrice] [decimal](18, 10) NULL,
		[LiquidationReceiveAmount] [decimal](18, 10) NULL,
		[LiquidationPayAmount] [decimal](18, 10) NULL,
		[Fee] [decimal](18, 10) NULL,
		[StateId] [bigint] NOT NULL,
		[StateMaker] [nvarchar](80) NOT NULL,
		[StateDate] [datetime] NOT NULL,
		[IsFinancialInstitution] [bit] NOT NULL,
		[SwiftConfirmationMessageStatus] [nvarchar](50) NULL,
		[SwiftPaymentMessageStatus] [nvarchar](50) NULL,
		[DomesticPaymentMessageStatus] [nvarchar](50) NULL,
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
		[SendConfirmation] [bit] NULL,
		[SendPayment] [bit] NULL,
		[SendNoticeToReceive] [bit] NULL,
		[BusinessKey] [bigint] NOT NULL,
		[ReceivePaymentDate] [date] NOT NULL,
		[PayPaymentDate] [date] NOT NULL,
		[ReceiveInvestmentAccount] [bigint] NULL,
		[ReceiveInvestmentAccountGLCode] [nvarchar](10) NULL,
		[ReceiveCurrentAccount] [bigint] NULL,
		[ReceiveCurrentAccountGLCode] [nvarchar](10) NULL,
		[ReceiveWHTAccount] [bigint] NULL,
		[ReceiveWHTAccountGLCode] [nvarchar](10) NULL,
		[PayInvestmentAccount] [bigint] NULL,
		[PayInvestmentAccountGLCode] [nvarchar](10) NULL,
		[PayCurrentAccount] [bigint] NULL,
		[PayCurrentAccountGLCode] [nvarchar](10) NULL,
		[PayWHTAccount] [bigint] NULL,
		[PayWHTAccountGLCode] [nvarchar](10) NULL,
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
		[CreatedBy] [nvarchar](80) NOT NULL,
		[CreatedDate] [datetime] NOT NULL,
		[PreviousStateId] [bigint] NULL,
		[PreviousStateMaker] [nvarchar](80) NULL,
		[PreviousStateDate] [datetime] NULL,
		[FlowId] [bigint] NOT NULL,
		[ParticipantCounterpartyId] [int] NULL
	)

	SET IDENTITY_INSERT [dbo].[TxnTransactionHistory_Temp] ON;

	INSERT INTO [dbo].[TxnTransactionHistory_Temp] (
		HistoryId, Id, LogicalReference, TradeDate, InputDateTime, ReceiveValueDate, PayValueDate, ReceiveMaturityDate, PayMaturityDate, Trader, CounterpartyId, 
		PortfolioId, ProductTypeId, PayOfUpdate, B2BRefTransaction, ReceivePrincipalAmount, ReceiveCurrency, ReceiveRateTypeId, ReceiveRate, ReceiveFloatingRateTypeId, 
		ReceiveSpread, ReceivePaymentFrequencyId, ReceiveInterestMethodsId, ReceiveInterestMethodsFrequencyId, ReceiveDateBasisCode, ReceiveIndexChartId, 
		ReceiveDaysInYear, ReceivePaymentLagDays, ReceiveFixingLagDays, PayPrincipalAmount, PayCurrency, PayRateTypeId, PayRate, PayFloatingRateTypeId, PaySpread, 
		PayPaymentFrequencyId, PayInterestMethodsId, PayInterestMethodsFrequencyId, PayDateBasisCode, PayIndexChartId, PayPaymentLagDays, PayDaysInYear, PayFixingLagDays, 
		Instructions, LiquidationDate, LiquidationTypeId, LiquidationPrice, LiquidationReceiveAmount, LiquidationPayAmount, Fee, StateId, StateMaker, StateDate, 
		IsFinancialInstitution, SwiftConfirmationMessageStatus, SwiftPaymentMessageStatus, DomesticPaymentMessageStatus, OutgoingCorrespondentId, 
		OutgoingCorrespondentAccountNumber, TheirBeneficiaryCorrespondentName, TheirBeneficiaryCorrespondentSwiftCode, TheirBeneficiaryCorrespondentAccountNumber, 
		TheirSenderCorrespondentName, TheirSenderCorrespondentSwiftCode, TheirSenderCorrespondentAccountNumber, IncomingCorrespondentId, IncomingCorrespondentAccountNumber, 
		SendConfirmation, SendPayment, SendNoticeToReceive, BusinessKey, ReceivePaymentDate, PayPaymentDate, ReceiveInvestmentAccount, ReceiveInvestmentAccountGLCode, 
		ReceiveCurrentAccount, ReceiveCurrentAccountGLCode, ReceiveWHTAccount, ReceiveWHTAccountGLCode, PayInvestmentAccount, PayInvestmentAccountGLCode, PayCurrentAccount, 
		PayCurrentAccountGLCode, PayWHTAccount, PayWHTAccountGLCode, PaymentInstructionTypeId, SettlementTypeId, OutgoingCorrespondentAccountGLCode, 
		OutgoingPaymentAccountingType, OutgoingPaymentAccountingGLType, OutgoingPaymentAccountingGL, IncomingCorrespondentAccountGLCode, IncomingPaymentAccountingType, 
		IncomingPaymentAccountingGLType, IncomingPaymentAccountingGL, TheirSenderCorrespondentId, TheirSenderCorrespondentGLCode, TheirBeneficiaryCorrespondentId, 
		TheirBeneficiaryCorrespondentGLCode, CreatedBy, CreatedDate, PreviousStateId, PreviousStateMaker, PreviousStateDate, FlowId, ParticipantCounterpartyId
	)
	SELECT
		HistoryId, Id, LogicalReference, TradeDate, InputDateTime, ReceiveValueDate, PayValueDate, ReceiveMaturityDate, PayMaturityDate, Trader, CounterpartyId, 
		PortfolioId, ProductTypeId, PayOfUpdate, B2BRefTransaction, ReceivePrincipalAmount, ReceiveCurrency, ReceiveRateTypeId, ReceiveRate, ReceiveFloatingRateTypeId, 
		ReceiveSpread, ReceivePaymentFrequencyId, ReceiveInterestMethodsId, ReceiveInterestMethodsFrequencyId, ReceiveDateBasisCode, ReceiveIndexChartId, 
		ReceiveDaysInYear, ReceivePaymentLagDays, ReceiveFixingLagDays, PayPrincipalAmount, PayCurrency, PayRateTypeId, PayRate, PayFloatingRateTypeId, PaySpread, 
		PayPaymentFrequencyId, PayInterestMethodsId, PayInterestMethodsFrequencyId, PayDateBasisCode, PayIndexChartId, PayPaymentLagDays, PayDaysInYear, PayFixingLagDays,
		Instructions, LiquidationDate, LiquidationTypeId, LiquidationPrice, LiquidationReceiveAmount, LiquidationPayAmount, Fee, StateId, StateMaker, StateDate, 
		IsFinancialInstitution, SwiftConfirmationMessageStatus, SwiftPaymentMessageStatus, DomesticPaymentMessageStatus, OutgoingCorrespondentId, 
		OutgoingCorrespondentAccountNumber, TheirBeneficiaryCorrespondentName, TheirBeneficiaryCorrespondentSwiftCode, TheirBeneficiaryCorrespondentAccountNumber, 
		TheirSenderCorrespondentName, TheirSenderCorrespondentSwiftCode, TheirSenderCorrespondentAccountNumber, IncomingCorrespondentId, IncomingCorrespondentAccountNumber, 
		SendConfirmation, SendPayment, SendNoticeToReceive, BusinessKey, ReceivePaymentDate, PayPaymentDate, ReceiveInvestmentAccount, ReceiveInvestmentAccountGLCode, 
		ReceiveCurrentAccount, ReceiveCurrentAccountGLCode, ReceiveWHTAccount, ReceiveWHTAccountGLCode, PayInvestmentAccount, PayInvestmentAccountGLCode, PayCurrentAccount, 
		PayCurrentAccountGLCode, PayWHTAccount, PayWHTAccountGLCode, PaymentInstructionTypeId, SettlementTypeId, OutgoingCorrespondentAccountGLCode,
		OutgoingPaymentAccountingType, OutgoingPaymentAccountingGLType, OutgoingPaymentAccountingGL, IncomingCorrespondentAccountGLCode, IncomingPaymentAccountingType, 
		IncomingPaymentAccountingGLType, IncomingPaymentAccountingGL, TheirSenderCorrespondentId, TheirSenderCorrespondentGLCode, TheirBeneficiaryCorrespondentId, 
		TheirBeneficiaryCorrespondentGLCode, CreatedBy, CreatedDate, PreviousStateId, PreviousStateMaker, PreviousStateDate, FlowId, ParticipantCounterpartyId
	FROM [dbo].[TxnTransactionHistory];

	SET IDENTITY_INSERT [dbo].[TxnTransactionHistory_Temp] OFF;

	DROP TABLE [dbo].[TxnTransactionHistory];
	EXEC sp_rename 'dbo.TxnTransactionHistory_Temp', 'TxnTransactionHistory';

	ALTER TABLE [dbo].[TxnTransactionHistory] ADD CONSTRAINT PK_TxnTransactionHistory PRIMARY KEY CLUSTERED (HistoryId);

--4.Adding New Flow Columns-------------------------------------------------------------------------------------------------------------
	IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'TxnTransaction' AND COLUMN_NAME = 'LastActionId')
		ALTER TABLE [dbo].[TxnTransaction] ADD [LastActionId] BIGINT NOT NULL DEFAULT 0;

	IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'TxnTransaction' AND COLUMN_NAME = 'PreviousActionId')
		ALTER TABLE [dbo].[TxnTransaction] ADD [PreviousActionId] BIGINT NULL;

	IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'TxnTransactionHistory' AND COLUMN_NAME = 'LastActionId')
		ALTER TABLE [dbo].[TxnTransactionHistory] ADD [LastActionId] BIGINT NOT NULL DEFAULT 0;

	IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'TxnTransactionHistory' AND COLUMN_NAME = 'PreviousActionId')
		ALTER TABLE [dbo].[TxnTransactionHistory] ADD [PreviousActionId] BIGINT NULL;

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