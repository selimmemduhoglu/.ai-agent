/***************************************************************************************************
* This script is designed to add Amortization Configuration
***************************************************************************************************/

--Check Database Name
USE NetTrexDerivSWP_Amortization
GO

 /********** 1. STEP: AMORTIZATION CONFIGURATION TABLE *********************************/

------------------------------------------------------------------------------------------------------------------------
-- Amortization Configuration Table
------------------------------------------------------------------------------------------------------------------------
--#region Amortization Configuration
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT 1 
                    FROM sys.objects 
                    WHERE object_id = OBJECT_ID(N'[dbo].[AmortizationConfiguration]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[AmortizationConfiguration](
        [Id] [bigint] IDENTITY(1,1) NOT NULL,
        [TxnId] [bigint] NOT NULL,
        [ReceiveAmortizationTypeId] [bigint] NOT NULL,
        [ReceiveAmortizationMode] [int] NOT NULL,
        [ReceiveAmortizationAmount] [decimal](18, 2) NULL,
        [ReceiveAmortizationPercentage] [decimal](18, 2) NULL,
        [ReceiveAmortizationStartDate] [date] NULL,
        [ReceiveAmortizationStartPeriod] [int] NULL,
        [ReceiveAmortizationEndDate] [date] NULL,
        [ReceiveAmortizationEndPeriod] [int] NULL,
        [ReceiveAmortizationFrequencyId] [int] NOT NULL,
        [PayAmortizationTypeId] [bigint] NOT NULL,
        [PayAmortizationMode] [int] NOT NULL,
        [PayAmortizationAmount] [decimal](18, 2) NULL,
        [PayAmortizationPercentage] [decimal](18, 2) NULL,
        [PayAmortizationStartDate] [date] NULL,
        [PayAmortizationStartPeriod] [int] NULL,
        [PayAmortizationEndDate] [date] NULL,
        [PayAmortizationEndPeriod] [int] NULL,
        [PayAmortizationFrequencyId] [int] NOT NULL,
        [StateId] [bigint] NOT NULL,
        [StateMaker] [nvarchar](80) NOT NULL,
        [StateDate] [datetime] NOT NULL,
    CONSTRAINT [PK_AmortizationConfiguration] PRIMARY KEY CLUSTERED 
    (
        [Id] ASC
    )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
    ) ON [PRIMARY]
END;


IF NOT EXISTS (SELECT 1 
                    FROM sys.objects 
                    WHERE object_id = OBJECT_ID(N'[dbo].[AmortizationConfigurationHistory]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[AmortizationConfigurationHistory](
        [HistoryId] [bigint] IDENTITY(1,1) NOT NULL,
	    [Id] [bigint] NOT NULL,
        [TxnId] [bigint] NOT NULL,
        [ReceiveAmortizationTypeId] [bigint] NOT NULL,
        [ReceiveAmortizationMode] [int] NOT NULL,
        [ReceiveAmortizationAmount] [decimal](18, 2) NULL,
        [ReceiveAmortizationPercentage] [decimal](18, 2) NULL,
        [ReceiveAmortizationStartDate] [date] NULL,
        [ReceiveAmortizationStartPeriod] [int] NULL,
        [ReceiveAmortizationEndDate] [date] NULL,
        [ReceiveAmortizationEndPeriod] [int] NULL,
        [ReceiveAmortizationFrequencyId] [int] NOT NULL,
        [PayAmortizationTypeId] [bigint] NOT NULL,
        [PayAmortizationMode] [int] NOT NULL,
        [PayAmortizationAmount] [decimal](18, 2) NULL,
        [PayAmortizationPercentage] [decimal](18, 2) NULL,
        [PayAmortizationStartDate] [date] NULL,
        [PayAmortizationStartPeriod] [int] NULL,
        [PayAmortizationEndDate] [date] NULL,
        [PayAmortizationEndPeriod] [int] NULL,
        [PayAmortizationFrequencyId] [int] NOT NULL,
        [StateId] [bigint] NOT NULL,
        [StateMaker] [nvarchar](80) NOT NULL,
        [StateDate] [datetime] NOT NULL,
    CONSTRAINT [PK_AmortizationConfigurationHisyory] PRIMARY KEY CLUSTERED 
    (
        [HistoryId] ASC
    )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
    ) ON [PRIMARY]
END;

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TRIGGER [dbo].[AmortizationConfigurationTrigger] ON [dbo].[AmortizationConfiguration]
FOR INSERT, UPDATE
AS
INSERT INTO [dbo].[AmortizationConfigurationHistory] SELECT * FROM inserted
GO
ALTER TABLE [dbo].[AmortizationConfiguration] ENABLE TRIGGER [AmortizationConfigurationTrigger]
--#endregion


/********** 2. STEP: AMORTIZATION TYPE TABLE *********************************/
------------------------------------------------------------------------------------------------------------------------
-- Amortization Type Table
------------------------------------------------------------------------------------------------------------------------
--#region Amortization Type
IF NOT EXISTS (SELECT 1 
                    FROM sys.objects 
                    WHERE object_id = OBJECT_ID(N'[dbo].[AmortizationType]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[AmortizationType](
        [Id] [bigint] IDENTITY(1,1) NOT NULL,
        [Name] [nvarchar](100) NOT NULL,
        [Code] [nvarchar](100) NOT NULL,
        [Description] [nvarchar](500) NULL,
        [IsEnabled] [bit] NOT NULL,
    CONSTRAINT [PK_AmortizationType] PRIMARY KEY CLUSTERED 
    (
        [Id] ASC
    )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
    ) ON [PRIMARY]
END;
--#endregion

/********** 3. STEP: TXN CASHFLOW TABLE *********************************/
------------------------------------------------------------------------------------------------------------------------
-- Txn CashFlow Table
------------------------------------------------------------------------------------------------------------------------
--#region Txn CashFlow
IF NOT EXISTS (SELECT 1
					FROM INFORMATION_SCHEMA.COLUMNS
					WHERE TABLE_NAME = 'TxnCashFlow' AND COLUMN_NAME = 'OrderNumber')
BEGIN
    ALTER TABLE [dbo].[TxnCashFlow] ADD OrderNumber INT NULL;

END;

IF NOT EXISTS (SELECT 1
					FROM INFORMATION_SCHEMA.COLUMNS
					WHERE TABLE_NAME = 'TxnCashFlowHistory' AND COLUMN_NAME = 'OrderNumber')
BEGIN
    ALTER TABLE [dbo].[TxnCashFlowHistory] ADD OrderNumber INT NULL;

END;

IF NOT EXISTS (SELECT 1
					FROM INFORMATION_SCHEMA.COLUMNS
					WHERE TABLE_NAME = 'TxnCashFlow' AND COLUMN_NAME = 'IsAmortization')
BEGIN
    ALTER TABLE [dbo].[TxnCashFlow] ADD [IsAmortization] BIT NOT NULL 
    CONSTRAINT DF_TxnCashFlow_IsAmortization DEFAULT 0;
END;

IF NOT EXISTS (SELECT 1
					FROM INFORMATION_SCHEMA.COLUMNS
					WHERE TABLE_NAME = 'TxnCashFlowHistory' AND COLUMN_NAME = 'IsAmortization')
BEGIN
    ALTER TABLE [dbo].[TxnCashFlowHistory] ADD [IsAmortization] BIT NOT NULL 
    CONSTRAINT DF_TxnCashFlowHistory_IsAmortization DEFAULT 0;
END;

IF NOT EXISTS (SELECT 1
					FROM INFORMATION_SCHEMA.COLUMNS
					WHERE TABLE_NAME = 'TxnCashFlow' AND COLUMN_NAME = 'AmortizationAmount')
BEGIN
    ALTER TABLE [dbo].[TxnCashFlow] ADD [AmortizationAmount] DECIMAL(38, 10) NULL
END;

IF NOT EXISTS (SELECT 1
					FROM INFORMATION_SCHEMA.COLUMNS
					WHERE TABLE_NAME = 'TxnCashFlowHistory' AND COLUMN_NAME = 'AmortizationAmount')
BEGIN
    ALTER TABLE [dbo].[TxnCashFlowHistory] ADD [AmortizationAmount] DECIMAL(38, 10) NULL
END;

IF NOT EXISTS (SELECT 1
					FROM INFORMATION_SCHEMA.COLUMNS
					WHERE TABLE_NAME = 'TxnCashFlow' AND COLUMN_NAME = 'AmortizationPercent')
BEGIN
    ALTER TABLE [dbo].[TxnCashFlow] ADD [AmortizationPercent] DECIMAL(18, 10) NULL
END;

IF NOT EXISTS (SELECT 1
					FROM INFORMATION_SCHEMA.COLUMNS
					WHERE TABLE_NAME = 'TxnCashFlowHistory' AND COLUMN_NAME = 'AmortizationPercent')
BEGIN
    ALTER TABLE [dbo].[TxnCashFlowHistory] ADD [AmortizationPercent] DECIMAL(18, 10) NULL
END
--#endregion

/********** 4. STEP: TXN TRANSACTION TABLE *********************************/
------------------------------------------------------------------------------------------------------------------------
-- Txn Transaction Table
------------------------------------------------------------------------------------------------------------------------
--#region Txn Transaction

IF NOT EXISTS (SELECT 1
					FROM INFORMATION_SCHEMA.COLUMNS
					WHERE TABLE_NAME = 'TxnTransaction' AND COLUMN_NAME = 'AmortizationConfigurationId')
BEGIN
    ALTER TABLE [dbo].[TxnTransaction] ADD [AmortizationConfigurationId] BIGINT NULL
END;

IF NOT EXISTS (SELECT 1
					FROM INFORMATION_SCHEMA.COLUMNS
					WHERE TABLE_NAME = 'TxnTransactionHistory' AND COLUMN_NAME = 'AmortizationConfigurationId')
BEGIN
    ALTER TABLE [dbo].[TxnTransactionHistory] ADD [AmortizationConfigurationId] BIGINT NULL
END

--#endregion
