--Check Database Name
USE NetTrexDerivSWP
GO

BEGIN TRANSACTION;

BEGIN TRY

--#region PAYMENT FREQUENCY FIELDS
IF NOT EXISTS (
    SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'PaymentFrequency' AND COLUMN_NAME = 'Month'
)
BEGIN
    ALTER TABLE [PaymentFrequency]
    ADD [Month] INT NOT NULL DEFAULT(0);
END

IF NOT EXISTS (
    SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'PaymentFrequency' AND COLUMN_NAME = 'Period'
)
BEGIN
    ALTER TABLE [PaymentFrequency]
    ADD [Period] INT NOT NULL DEFAULT(0);
END
--#endregion

--#region SETTLEMENT TYPE
IF NOT EXISTS (SELECT 1 
					  FROM sys.objects 
					  WHERE object_id = OBJECT_ID(N'[dbo].[SettlementType]') AND type in (N'U'))
BEGIN
		CREATE TABLE [dbo].[SettlementType](
		[Id] [int] NOT NULL,
		[Code] [nvarchar](50) NOT NULL,
		[Name] [nvarchar](100) NOT NULL,
		[Description] [nvarchar](500) NULL,
		[ExternalCode] [nvarchar](50) NULL,
		[IsEnabled] [bit] NOT NULL,
	CONSTRAINT [PK_SettlementType] PRIMARY KEY CLUSTERED 
	(
		[Id] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
	) ON [PRIMARY]
END;
--#endregion

--#region PAYMENT INSTRUCTION TYPE
IF NOT EXISTS (SELECT 1 
					  FROM sys.objects 
					  WHERE object_id = OBJECT_ID(N'[dbo].[PaymentInstructionType]') AND type in (N'U'))
BEGIN
	CREATE TABLE [dbo].[PaymentInstructionType](
		[Id] [int] NOT NULL,
		[Code] [nvarchar](50) NOT NULL,
		[Name] [nvarchar](100) NOT NULL,
		[Description] [nvarchar](500) NULL,
		[ExternalCode] [nvarchar](50) NULL,
		[IsEnabled] [bit] NOT NULL,
	CONSTRAINT [PK_PaymentInstructionType] PRIMARY KEY CLUSTERED 
	(
		[Id] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
	) ON [PRIMARY]
END;
--#endregion

--#region TXN TRANSACTION PAYMENT FIELDS
	DECLARE @ConstraintName NVARCHAR(1000);
	DECLARE @Sql NVARCHAR(MAX);

		--#region SendConfirmation
		SELECT @ConstraintName = df.name
		FROM sys.default_constraints df
		INNER JOIN sys.columns c ON c.default_object_id = df.object_id
		WHERE 
			c.object_id = OBJECT_ID('dbo.TxnTransaction') AND c.name = 'SendConformation';

		IF @ConstraintName IS NOT NULL
		BEGIN
			SET @Sql = N'ALTER TABLE [dbo].[TxnTransaction] DROP CONSTRAINT [' + @ConstraintName + ']';
			EXEC sp_executesql @Sql;
		END;

		IF EXISTS (SELECT 1
						   FROM INFORMATION_SCHEMA.COLUMNS
						   WHERE TABLE_NAME = 'TxnTransaction' AND COLUMN_NAME = 'SendConformation')
		BEGIN
			EXEC sp_rename 'TxnTransaction.SendConformation', 'SendConfirmation', 'COLUMN';
			ALTER TABLE TxnTransaction ALTER COLUMN SendConfirmation BIT NULL;
		END;

		SELECT @ConstraintName = df.name
		FROM sys.default_constraints df
		INNER JOIN sys.columns c ON c.default_object_id = df.object_id
		WHERE 
			c.object_id = OBJECT_ID('dbo.TxnTransactionHistory') AND c.name = 'SendConformation';

		IF @ConstraintName IS NOT NULL
		BEGIN
			SET @Sql = N'ALTER TABLE [dbo].[TxnTransactionHistory] DROP CONSTRAINT [' + @ConstraintName + ']';
			EXEC sp_executesql @Sql;
		END;

		IF EXISTS (SELECT 1
						   FROM INFORMATION_SCHEMA.COLUMNS
						   WHERE TABLE_NAME = 'TxnTransactionHistory' AND COLUMN_NAME = 'SendConformation')
		BEGIN
			EXEC sp_rename 'TxnTransactionHistory.SendConformation', 'SendConfirmation', 'COLUMN';
			ALTER TABLE TxnTransactionHistory ALTER COLUMN SendConfirmation BIT NULL;
		END;
		--#endregion

		--#region SendPayment
		SELECT @ConstraintName = df.name
		FROM sys.default_constraints df
		INNER JOIN sys.columns c ON c.default_object_id = df.object_id
		WHERE 
			c.object_id = OBJECT_ID('dbo.TxnTransaction') AND c.name = 'SendPayment';

		IF @ConstraintName IS NOT NULL
		BEGIN
			SET @Sql = N'ALTER TABLE [dbo].[TxnTransaction] DROP CONSTRAINT [' + @ConstraintName + ']';
			EXEC sp_executesql @Sql;
		END;

		IF EXISTS (SELECT 1
						   FROM INFORMATION_SCHEMA.COLUMNS
						   WHERE TABLE_NAME = 'TxnTransaction' AND COLUMN_NAME = 'SendPayment')
		BEGIN
			ALTER TABLE TxnTransaction ALTER COLUMN SendPayment BIT NULL;
		END;

		SELECT @ConstraintName = df.name
		FROM sys.default_constraints df
		INNER JOIN sys.columns c ON c.default_object_id = df.object_id
		WHERE 
			c.object_id = OBJECT_ID('dbo.TxnTransactionHistory') AND c.name = 'SendPayment';

		IF @ConstraintName IS NOT NULL
		BEGIN
			SET @Sql = N'ALTER TABLE [dbo].[TxnTransactionHistory] DROP CONSTRAINT [' + @ConstraintName + ']';
			EXEC sp_executesql @Sql;
		END;

		IF EXISTS (SELECT 1
						   FROM INFORMATION_SCHEMA.COLUMNS
						   WHERE TABLE_NAME = 'TxnTransactionHistory' AND COLUMN_NAME = 'SendPayment')
		BEGIN
			ALTER TABLE TxnTransactionHistory ALTER COLUMN SendPayment BIT NULL;
		END;
		--#endregion

		--#region SendNoticeToReceive
		SELECT @ConstraintName = df.name
		FROM sys.default_constraints df
		INNER JOIN sys.columns c ON c.default_object_id = df.object_id
		WHERE 
			c.object_id = OBJECT_ID('dbo.TxnTransaction') AND c.name = 'SendNoticeToReceive';

		IF @ConstraintName IS NOT NULL
		BEGIN
			SET @Sql = N'ALTER TABLE [dbo].[TxnTransaction] DROP CONSTRAINT [' + @ConstraintName + ']';
			EXEC sp_executesql @Sql;
		END;

		IF EXISTS (SELECT 1
						   FROM INFORMATION_SCHEMA.COLUMNS
						   WHERE TABLE_NAME = 'TxnTransaction' AND COLUMN_NAME = 'SendNoticeToReceive')
		BEGIN
			ALTER TABLE [dbo].[TxnTransaction] ALTER COLUMN SendNoticeToReceive BIT NULL;
		END;

		SELECT @ConstraintName = df.name
		FROM sys.default_constraints df
		INNER JOIN sys.columns c ON c.default_object_id = df.object_id
		WHERE 
			c.object_id = OBJECT_ID('dbo.TxnTransactionHistory') AND c.name = 'SendNoticeToReceive';

		IF @ConstraintName IS NOT NULL
		BEGIN
			SET @Sql = N'ALTER TABLE [dbo].[TxnTransactionHistory] DROP CONSTRAINT [' + @ConstraintName + ']';
			EXEC sp_executesql @Sql;
		END;

		IF EXISTS (SELECT 1
						   FROM INFORMATION_SCHEMA.COLUMNS
						   WHERE TABLE_NAME = 'TxnTransactionHistory' AND COLUMN_NAME = 'SendNoticeToReceive')
		BEGIN
			ALTER TABLE [dbo].[TxnTransactionHistory] ALTER COLUMN SendNoticeToReceive BIT NULL;
		END;
		--#endregion

		--#region PaymentInstructionTypeId
		IF NOT EXISTS (SELECT 1
						   FROM INFORMATION_SCHEMA.COLUMNS
						   WHERE TABLE_NAME = 'TxnTransaction' AND COLUMN_NAME = 'PaymentInstructionTypeId')
		BEGIN
			ALTER TABLE [dbo].[TxnTransaction] ADD PaymentInstructionTypeId INT NULL
		END;

		IF NOT EXISTS (SELECT 1
						   FROM INFORMATION_SCHEMA.COLUMNS
						   WHERE TABLE_NAME = 'TxnTransactionHistory' AND COLUMN_NAME = 'PaymentInstructionTypeId')
		BEGIN
			ALTER TABLE [dbo].[TxnTransactionHistory] ADD PaymentInstructionTypeId INT NULL
		END;
		--#endregion

		--#region SettlementTypeId
		IF NOT EXISTS (SELECT 1
						   FROM INFORMATION_SCHEMA.COLUMNS
						   WHERE TABLE_NAME = 'TxnTransaction' AND COLUMN_NAME = 'SettlementTypeId')
		BEGIN
			ALTER TABLE [dbo].[TxnTransaction] ADD SettlementTypeId INT NULL
		END;

		IF NOT EXISTS (SELECT 1
						   FROM INFORMATION_SCHEMA.COLUMNS
						   WHERE TABLE_NAME = 'TxnTransactionHistory' AND COLUMN_NAME = 'SettlementTypeId')
		BEGIN
			ALTER TABLE [dbo].[TxnTransactionHistory] ADD SettlementTypeId INT NULL
		END;
		--#endregion

		--#region OutgoingCorrespondentAccountGLCode
		IF NOT EXISTS (SELECT 1
						   FROM INFORMATION_SCHEMA.COLUMNS
						   WHERE TABLE_NAME = 'TxnTransaction' AND COLUMN_NAME = 'OutgoingCorrespondentAccountGLCode')
		BEGIN
			ALTER TABLE [dbo].[TxnTransaction] ADD OutgoingCorrespondentAccountGLCode NVARCHAR(10) NULL
		END;

		IF NOT EXISTS (SELECT 1
						   FROM INFORMATION_SCHEMA.COLUMNS
						   WHERE TABLE_NAME = 'TxnTransactionHistory' AND COLUMN_NAME = 'OutgoingCorrespondentAccountGLCode')
		BEGIN
			ALTER TABLE [dbo].[TxnTransactionHistory] ADD OutgoingCorrespondentAccountGLCode NVARCHAR(10) NULL
		END;
		--#endregion

		--#region OutgoingPaymentAccountingType
		IF NOT EXISTS (SELECT 1
						   FROM INFORMATION_SCHEMA.COLUMNS
						   WHERE TABLE_NAME = 'TxnTransaction' AND COLUMN_NAME = 'OutgoingPaymentAccountingType')
		BEGIN
			ALTER TABLE [dbo].[TxnTransaction] ADD OutgoingPaymentAccountingType NVARCHAR(50) NULL
		END;

		IF NOT EXISTS (SELECT 1
						   FROM INFORMATION_SCHEMA.COLUMNS
						   WHERE TABLE_NAME = 'TxnTransactionHistory' AND COLUMN_NAME = 'OutgoingPaymentAccountingType')
		BEGIN
			ALTER TABLE [dbo].[TxnTransactionHistory] ADD OutgoingPaymentAccountingType NVARCHAR(50) NULL
		END;
		--#endregion

		--#region OutgoingPaymentAccountingGLType
		IF NOT EXISTS (SELECT 1
						   FROM INFORMATION_SCHEMA.COLUMNS
						   WHERE TABLE_NAME = 'TxnTransaction' AND COLUMN_NAME = 'OutgoingPaymentAccountingGLType')
		BEGIN
			ALTER TABLE [dbo].[TxnTransaction] ADD OutgoingPaymentAccountingGLType NVARCHAR(50) NULL
		END;

		IF NOT EXISTS (SELECT 1
						   FROM INFORMATION_SCHEMA.COLUMNS
						   WHERE TABLE_NAME = 'TxnTransactionHistory' AND COLUMN_NAME = 'OutgoingPaymentAccountingGLType')
		BEGIN
			ALTER TABLE [dbo].[TxnTransactionHistory] ADD OutgoingPaymentAccountingGLType NVARCHAR(50) NULL
		END;
		--#endregion

		--#region OutgoingPaymentAccountingGL
		IF NOT EXISTS (SELECT 1
						   FROM INFORMATION_SCHEMA.COLUMNS
						   WHERE TABLE_NAME = 'TxnTransaction' AND COLUMN_NAME = 'OutgoingPaymentAccountingGL')
		BEGIN
			ALTER TABLE [dbo].[TxnTransaction] ADD OutgoingPaymentAccountingGL NVARCHAR(10) NULL
		END;

		IF NOT EXISTS (SELECT 1
						   FROM INFORMATION_SCHEMA.COLUMNS
						   WHERE TABLE_NAME = 'TxnTransactionHistory' AND COLUMN_NAME = 'OutgoingPaymentAccountingGL')
		BEGIN
			ALTER TABLE [dbo].[TxnTransactionHistory] ADD OutgoingPaymentAccountingGL NVARCHAR(10) NULL
		END;
		--#endregion

		--#region IncomingCorrespondentAccountGLCode
		IF NOT EXISTS (SELECT 1
						   FROM INFORMATION_SCHEMA.COLUMNS
						   WHERE TABLE_NAME = 'TxnTransaction' AND COLUMN_NAME = 'IncomingCorrespondentAccountGLCode')
		BEGIN
			ALTER TABLE [dbo].[TxnTransaction] ADD IncomingCorrespondentAccountGLCode NVARCHAR(10) NULL
		END;

		IF NOT EXISTS (SELECT 1
						   FROM INFORMATION_SCHEMA.COLUMNS
						   WHERE TABLE_NAME = 'TxnTransactionHistory' AND COLUMN_NAME = 'IncomingCorrespondentAccountGLCode')
		BEGIN
			ALTER TABLE [dbo].[TxnTransactionHistory] ADD IncomingCorrespondentAccountGLCode NVARCHAR(10) NULL
		END;
		--#endregion

		--#region IncomingPaymentAccountingType
		IF NOT EXISTS (SELECT 1
						   FROM INFORMATION_SCHEMA.COLUMNS
						   WHERE TABLE_NAME = 'TxnTransaction' AND COLUMN_NAME = 'IncomingPaymentAccountingType')
		BEGIN
			ALTER TABLE [dbo].[TxnTransaction] ADD IncomingPaymentAccountingType NVARCHAR(50) NULL
		END;

		IF NOT EXISTS (SELECT 1
						   FROM INFORMATION_SCHEMA.COLUMNS
						   WHERE TABLE_NAME = 'TxnTransactionHistory' AND COLUMN_NAME = 'IncomingPaymentAccountingType')
		BEGIN
			ALTER TABLE [dbo].[TxnTransactionHistory] ADD IncomingPaymentAccountingType NVARCHAR(50) NULL
		END;
		--#endregion

		--#region IncomingPaymentAccountingGLType
		IF NOT EXISTS (SELECT 1
						   FROM INFORMATION_SCHEMA.COLUMNS
						   WHERE TABLE_NAME = 'TxnTransaction' AND COLUMN_NAME = 'IncomingPaymentAccountingGLType')
		BEGIN
			ALTER TABLE [dbo].[TxnTransaction] ADD IncomingPaymentAccountingGLType NVARCHAR(50) NULL
		END;

		IF NOT EXISTS (SELECT 1
						   FROM INFORMATION_SCHEMA.COLUMNS
						   WHERE TABLE_NAME = 'TxnTransactionHistory' AND COLUMN_NAME = 'IncomingPaymentAccountingGLType')
		BEGIN
			ALTER TABLE [dbo].[TxnTransactionHistory] ADD IncomingPaymentAccountingGLType NVARCHAR(50) NULL
		END;
		--#endregion

		--#region IncomingPaymentAccountingGL
		IF NOT EXISTS (SELECT 1
						   FROM INFORMATION_SCHEMA.COLUMNS
						   WHERE TABLE_NAME = 'TxnTransaction' AND COLUMN_NAME = 'IncomingPaymentAccountingGL')
		BEGIN
			ALTER TABLE [dbo].[TxnTransaction] ADD IncomingPaymentAccountingGL NVARCHAR(10) NULL
		END;

		IF NOT EXISTS (SELECT 1
						   FROM INFORMATION_SCHEMA.COLUMNS
						   WHERE TABLE_NAME = 'TxnTransactionHistory' AND COLUMN_NAME = 'IncomingPaymentAccountingGL')
		BEGIN
			ALTER TABLE [dbo].[TxnTransactionHistory] ADD IncomingPaymentAccountingGL NVARCHAR(10) NULL
		END;
		--#endregion

		--#region TheirSenderCorrespondentId
		IF NOT EXISTS (SELECT 1
						   FROM INFORMATION_SCHEMA.COLUMNS
						   WHERE TABLE_NAME = 'TxnTransaction' AND COLUMN_NAME = 'TheirSenderCorrespondentId')
		BEGIN
			ALTER TABLE [dbo].[TxnTransaction] ADD TheirSenderCorrespondentId INT NULL
		END;

		IF NOT EXISTS (SELECT 1
						   FROM INFORMATION_SCHEMA.COLUMNS
						   WHERE TABLE_NAME = 'TxnTransactionHistory' AND COLUMN_NAME = 'TheirSenderCorrespondentId')
		BEGIN
			ALTER TABLE [dbo].[TxnTransactionHistory] ADD TheirSenderCorrespondentId INT NULL
		END;
		--#endregion

		--#region TheirSenderCorrespondentGLCode
		IF NOT EXISTS (SELECT 1
						   FROM INFORMATION_SCHEMA.COLUMNS
						   WHERE TABLE_NAME = 'TxnTransaction' AND COLUMN_NAME = 'TheirSenderCorrespondentGLCode')
		BEGIN
			ALTER TABLE [dbo].[TxnTransaction] ADD TheirSenderCorrespondentGLCode NVARCHAR(10) NULL
		END;

		IF NOT EXISTS (SELECT 1
						   FROM INFORMATION_SCHEMA.COLUMNS
						   WHERE TABLE_NAME = 'TxnTransactionHistory' AND COLUMN_NAME = 'TheirSenderCorrespondentGLCode')
		BEGIN
			ALTER TABLE [dbo].[TxnTransactionHistory] ADD TheirSenderCorrespondentGLCode NVARCHAR(10) NULL
		END;
		--#endregion

		--#region TheirBeneficiaryCorrespondentId
		IF NOT EXISTS (SELECT 1
						   FROM INFORMATION_SCHEMA.COLUMNS
						   WHERE TABLE_NAME = 'TxnTransaction' AND COLUMN_NAME = 'TheirBeneficiaryCorrespondentId')
		BEGIN
			ALTER TABLE [dbo].[TxnTransaction] ADD TheirBeneficiaryCorrespondentId INT NULL
		END;

		IF NOT EXISTS (SELECT 1
						   FROM INFORMATION_SCHEMA.COLUMNS
						   WHERE TABLE_NAME = 'TxnTransactionHistory' AND COLUMN_NAME = 'TheirBeneficiaryCorrespondentId')
		BEGIN
			ALTER TABLE [dbo].[TxnTransactionHistory] ADD TheirBeneficiaryCorrespondentId INT NULL
		END;
		--#endregion

		--#region TheirBeneficiaryCorrespondentGLCode
		IF NOT EXISTS (SELECT 1
						   FROM INFORMATION_SCHEMA.COLUMNS
						   WHERE TABLE_NAME = 'TxnTransaction' AND COLUMN_NAME = 'TheirBeneficiaryCorrespondentGLCode')
		BEGIN
			ALTER TABLE [dbo].[TxnTransaction] ADD TheirBeneficiaryCorrespondentGLCode NVARCHAR(10) NULL
		END;

		IF NOT EXISTS (SELECT 1
						   FROM INFORMATION_SCHEMA.COLUMNS
						   WHERE TABLE_NAME = 'TxnTransactionHistory' AND COLUMN_NAME = 'TheirBeneficiaryCorrespondentGLCode')
		BEGIN
			ALTER TABLE [dbo].[TxnTransactionHistory] ADD TheirBeneficiaryCorrespondentGLCode NVARCHAR(10) NULL
		END;
		--#endregion
--#endregion

--#region TXN CASHFLOW PAYMENT FIELDS
		--#region SendConfirmation
		IF NOT EXISTS (SELECT 1
						   FROM INFORMATION_SCHEMA.COLUMNS
						   WHERE TABLE_NAME = 'TxnCashFlow' AND COLUMN_NAME = 'SendConfirmation')
		BEGIN
			ALTER TABLE [dbo].[TxnCashFlow] ADD SendConfirmation BIT NULL
		END;

		IF NOT EXISTS (SELECT 1
						   FROM INFORMATION_SCHEMA.COLUMNS
						   WHERE TABLE_NAME = 'TxnCashFlowHistory' AND COLUMN_NAME = 'SendConfirmation')
		BEGIN
			ALTER TABLE [dbo].[TxnCashFlowHistory] ADD SendConfirmation BIT NULL
		END;
		--#endregion

		--#region SendPayment
		IF NOT EXISTS (SELECT 1
						   FROM INFORMATION_SCHEMA.COLUMNS
						   WHERE TABLE_NAME = 'TxnCashFlow' AND COLUMN_NAME = 'SendPayment')
		BEGIN
			ALTER TABLE [dbo].[TxnCashFlow] ADD SendPayment BIT NULL
		END;

		IF NOT EXISTS (SELECT 1
						   FROM INFORMATION_SCHEMA.COLUMNS
						   WHERE TABLE_NAME = 'TxnCashFlowHistory' AND COLUMN_NAME = 'SendPayment')
		BEGIN
			ALTER TABLE [dbo].[TxnCashFlowHistory] ADD SendPayment BIT NULL
		END;
		--#endregion

		--#region SendNoticeToReceive
		IF NOT EXISTS (SELECT 1
						   FROM INFORMATION_SCHEMA.COLUMNS
						   WHERE TABLE_NAME = 'TxnCashFlow' AND COLUMN_NAME = 'SendNoticeToReceive')
		BEGIN
			ALTER TABLE [dbo].[TxnCashFlow] ADD SendNoticeToReceive BIT NULL
		END;

		IF NOT EXISTS (SELECT 1
						   FROM INFORMATION_SCHEMA.COLUMNS
						   WHERE TABLE_NAME = 'TxnCashFlowHistory' AND COLUMN_NAME = 'SendNoticeToReceive')
		BEGIN
			ALTER TABLE [dbo].[TxnCashFlowHistory] ADD SendNoticeToReceive BIT NULL
		END;
		--#endregion

		--#region PaymentInstructionTypeId
		IF NOT EXISTS (SELECT 1
						   FROM INFORMATION_SCHEMA.COLUMNS
						   WHERE TABLE_NAME = 'TxnCashFlow' AND COLUMN_NAME = 'PaymentInstructionTypeId')
		BEGIN
			ALTER TABLE [dbo].[TxnCashFlow] ADD PaymentInstructionTypeId INT NULL
		END;

		IF NOT EXISTS (SELECT 1
						   FROM INFORMATION_SCHEMA.COLUMNS
						   WHERE TABLE_NAME = 'TxnCashFlowHistory' AND COLUMN_NAME = 'PaymentInstructionTypeId')
		BEGIN
			ALTER TABLE [dbo].[TxnCashFlowHistory] ADD PaymentInstructionTypeId INT NULL
		END;
		--#endregion

		--#region SettlementTypeId
		IF NOT EXISTS (SELECT 1
						   FROM INFORMATION_SCHEMA.COLUMNS
						   WHERE TABLE_NAME = 'TxnCashFlow' AND COLUMN_NAME = 'SettlementTypeId')
		BEGIN
			ALTER TABLE [dbo].[TxnCashFlow] ADD SettlementTypeId INT NULL
		END;

		IF NOT EXISTS (SELECT 1
						   FROM INFORMATION_SCHEMA.COLUMNS
						   WHERE TABLE_NAME = 'TxnCashFlowHistory' AND COLUMN_NAME = 'SettlementTypeId')
		BEGIN
			ALTER TABLE [dbo].[TxnCashFlowHistory] ADD SettlementTypeId INT NULL
		END;
		--#endregion

		--#region OutgoingCorrespondentId
		IF NOT EXISTS (SELECT 1
						   FROM INFORMATION_SCHEMA.COLUMNS
						   WHERE TABLE_NAME = 'TxnCashFlow' AND COLUMN_NAME = 'OutgoingCorrespondentId')
			BEGIN
				ALTER TABLE [dbo].[TxnCashFlow] ADD OutgoingCorrespondentId INT NULL		
			END;

		IF NOT EXISTS (SELECT 1
						   FROM INFORMATION_SCHEMA.COLUMNS
						   WHERE TABLE_NAME = 'TxnCashFlowHistory' AND COLUMN_NAME = 'OutgoingCorrespondentId')
			BEGIN
				ALTER TABLE [dbo].[TxnCashFlowHistory] ADD OutgoingCorrespondentId INT NULL		
			END;
		--#endregion

		--#region OutgoingCorrespondentAccountNumber
		IF NOT EXISTS (SELECT 1
						   FROM INFORMATION_SCHEMA.COLUMNS
						   WHERE TABLE_NAME = 'TxnCashFlow' AND COLUMN_NAME = 'OutgoingCorrespondentAccountNumber')
			BEGIN
				ALTER TABLE [dbo].[TxnCashFlow] ADD OutgoingCorrespondentAccountNumber BIGINT NULL		
			END;

		IF NOT EXISTS (SELECT 1
						   FROM INFORMATION_SCHEMA.COLUMNS
						   WHERE TABLE_NAME = 'TxnCashFlowHistory' AND COLUMN_NAME = 'OutgoingCorrespondentAccountNumber')
			BEGIN
				ALTER TABLE [dbo].[TxnCashFlowHistory] ADD OutgoingCorrespondentAccountNumber BIGINT NULL		
			END;
		--#endregion

		--#region OutgoingCorrespondentAccountGLCode
		IF NOT EXISTS (SELECT 1
						   FROM INFORMATION_SCHEMA.COLUMNS
						   WHERE TABLE_NAME = 'TxnCashFlow' AND COLUMN_NAME = 'OutgoingCorrespondentAccountGLCode')
		BEGIN
			ALTER TABLE [dbo].[TxnCashFlow] ADD OutgoingCorrespondentAccountGLCode NVARCHAR(10) NULL
		END;

		IF NOT EXISTS (SELECT 1
						   FROM INFORMATION_SCHEMA.COLUMNS
						   WHERE TABLE_NAME = 'TxnCashFlowHistory' AND COLUMN_NAME = 'OutgoingCorrespondentAccountGLCode')
		BEGIN
			ALTER TABLE [dbo].[TxnCashFlowHistory] ADD OutgoingCorrespondentAccountGLCode NVARCHAR(10) NULL
		END;
		--#endregion

		--#region OutgoingPaymentAccountingType
		IF NOT EXISTS (SELECT 1
						   FROM INFORMATION_SCHEMA.COLUMNS
						   WHERE TABLE_NAME = 'TxnCashFlow' AND COLUMN_NAME = 'OutgoingPaymentAccountingType')
		BEGIN
			ALTER TABLE [dbo].[TxnCashFlow] ADD OutgoingPaymentAccountingType NVARCHAR(50) NULL
		END;

		IF NOT EXISTS (SELECT 1
						   FROM INFORMATION_SCHEMA.COLUMNS
						   WHERE TABLE_NAME = 'TxnCashFlowHistory' AND COLUMN_NAME = 'OutgoingPaymentAccountingType')
		BEGIN
			ALTER TABLE [dbo].[TxnCashFlowHistory] ADD OutgoingPaymentAccountingType NVARCHAR(50) NULL
		END;
		--#endregion

		--#region OutgoingPaymentAccountingGLType
		IF NOT EXISTS (SELECT 1
						   FROM INFORMATION_SCHEMA.COLUMNS
						   WHERE TABLE_NAME = 'TxnCashFlow' AND COLUMN_NAME = 'OutgoingPaymentAccountingGLType')
		BEGIN
			ALTER TABLE [dbo].[TxnCashFlow] ADD OutgoingPaymentAccountingGLType NVARCHAR(50) NULL
		END;

		IF NOT EXISTS (SELECT 1
						   FROM INFORMATION_SCHEMA.COLUMNS
						   WHERE TABLE_NAME = 'TxnCashFlowHistory' AND COLUMN_NAME = 'OutgoingPaymentAccountingGLType')
		BEGIN
			ALTER TABLE [dbo].[TxnCashFlowHistory] ADD OutgoingPaymentAccountingGLType NVARCHAR(50) NULL
		END;
		--#endregion

		--#region OutgoingPaymentAccountingGL
		IF NOT EXISTS (SELECT 1
						   FROM INFORMATION_SCHEMA.COLUMNS
						   WHERE TABLE_NAME = 'TxnCashFlow' AND COLUMN_NAME = 'OutgoingPaymentAccountingGL')
		BEGIN
			ALTER TABLE [dbo].[TxnCashFlow] ADD OutgoingPaymentAccountingGL NVARCHAR(10) NULL
		END;

		IF NOT EXISTS (SELECT 1
						   FROM INFORMATION_SCHEMA.COLUMNS
						   WHERE TABLE_NAME = 'TxnCashFlowHistory' AND COLUMN_NAME = 'OutgoingPaymentAccountingGL')
		BEGIN
			ALTER TABLE [dbo].[TxnCashFlowHistory] ADD OutgoingPaymentAccountingGL NVARCHAR(10) NULL
		END;
		--#endregion

		--#region IncomingCorrespondentId
		IF NOT EXISTS (SELECT 1
						   FROM INFORMATION_SCHEMA.COLUMNS
						   WHERE TABLE_NAME = 'TxnCashFlow' AND COLUMN_NAME = 'IncomingCorrespondentId')
			BEGIN
				ALTER TABLE [dbo].[TxnCashFlow] ADD IncomingCorrespondentId INT NULL		
			END;

		IF NOT EXISTS (SELECT 1
						   FROM INFORMATION_SCHEMA.COLUMNS
						   WHERE TABLE_NAME = 'TxnCashFlowHistory' AND COLUMN_NAME = 'IncomingCorrespondentId')
			BEGIN
				ALTER TABLE [dbo].[TxnCashFlowHistory] ADD IncomingCorrespondentId INT NULL		
			END;
		--#endregion

		--#region IncomingCorrespondentAccountNumber
		IF NOT EXISTS (SELECT 1
						   FROM INFORMATION_SCHEMA.COLUMNS
						   WHERE TABLE_NAME = 'TxnCashFlow' AND COLUMN_NAME = 'IncomingCorrespondentAccountNumber')
			BEGIN
				ALTER TABLE [dbo].[TxnCashFlow] ADD IncomingCorrespondentAccountNumber BIGINT NULL		
			END;

		IF NOT EXISTS (SELECT 1
						   FROM INFORMATION_SCHEMA.COLUMNS
						   WHERE TABLE_NAME = 'TxnCashFlowHistory' AND COLUMN_NAME = 'IncomingCorrespondentAccountNumber')
			BEGIN
				ALTER TABLE [dbo].[TxnCashFlowHistory] ADD IncomingCorrespondentAccountNumber BIGINT NULL		
			END;
		--#endregion

		--#region IncomingCorrespondentAccountGLCode
		IF NOT EXISTS (SELECT 1
						   FROM INFORMATION_SCHEMA.COLUMNS
						   WHERE TABLE_NAME = 'TxnCashFlow' AND COLUMN_NAME = 'IncomingCorrespondentAccountGLCode')
		BEGIN
			ALTER TABLE [dbo].[TxnCashFlow] ADD IncomingCorrespondentAccountGLCode NVARCHAR(10) NULL
		END;

		IF NOT EXISTS (SELECT 1
						   FROM INFORMATION_SCHEMA.COLUMNS
						   WHERE TABLE_NAME = 'TxnCashFlowHistory' AND COLUMN_NAME = 'IncomingCorrespondentAccountGLCode')
		BEGIN
			ALTER TABLE [dbo].[TxnCashFlowHistory] ADD IncomingCorrespondentAccountGLCode NVARCHAR(10) NULL
		END;
		--#endregion

		--#region IncomingPaymentAccountingType
		IF NOT EXISTS (SELECT 1
						   FROM INFORMATION_SCHEMA.COLUMNS
						   WHERE TABLE_NAME = 'TxnCashFlow' AND COLUMN_NAME = 'IncomingPaymentAccountingType')
		BEGIN
			ALTER TABLE [dbo].[TxnCashFlow] ADD IncomingPaymentAccountingType NVARCHAR(50) NULL
		END;

		IF NOT EXISTS (SELECT 1
						   FROM INFORMATION_SCHEMA.COLUMNS
						   WHERE TABLE_NAME = 'TxnCashFlowHistory' AND COLUMN_NAME = 'IncomingPaymentAccountingType')
		BEGIN
			ALTER TABLE [dbo].[TxnCashFlowHistory] ADD IncomingPaymentAccountingType NVARCHAR(50) NULL
		END;
		--#endregion

		--#region IncomingPaymentAccountingGLType
		IF NOT EXISTS (SELECT 1
						   FROM INFORMATION_SCHEMA.COLUMNS
						   WHERE TABLE_NAME = 'TxnCashFlow' AND COLUMN_NAME = 'IncomingPaymentAccountingGLType')
		BEGIN
			ALTER TABLE [dbo].[TxnCashFlow] ADD IncomingPaymentAccountingGLType NVARCHAR(50) NULL
		END;

		IF NOT EXISTS (SELECT 1
						   FROM INFORMATION_SCHEMA.COLUMNS
						   WHERE TABLE_NAME = 'TxnCashFlowHistory' AND COLUMN_NAME = 'IncomingPaymentAccountingGLType')
		BEGIN
			ALTER TABLE [dbo].[TxnCashFlowHistory] ADD IncomingPaymentAccountingGLType NVARCHAR(50) NULL
		END;
		--#endregion

		--#region IncomingPaymentAccountingGL
		IF NOT EXISTS (SELECT 1
						   FROM INFORMATION_SCHEMA.COLUMNS
						   WHERE TABLE_NAME = 'TxnCashFlow' AND COLUMN_NAME = 'IncomingPaymentAccountingGL')
		BEGIN
			ALTER TABLE [dbo].[TxnCashFlow] ADD IncomingPaymentAccountingGL NVARCHAR(10) NULL
		END;

		IF NOT EXISTS (SELECT 1
						   FROM INFORMATION_SCHEMA.COLUMNS
						   WHERE TABLE_NAME = 'TxnCashFlowHistory' AND COLUMN_NAME = 'IncomingPaymentAccountingGL')
		BEGIN
			ALTER TABLE [dbo].[TxnCashFlowHistory] ADD IncomingPaymentAccountingGL NVARCHAR(10) NULL
		END;
		--#endregion

		--#region TheirSenderCorrespondentId
		IF NOT EXISTS (SELECT 1
						   FROM INFORMATION_SCHEMA.COLUMNS
						   WHERE TABLE_NAME = 'TxnCashFlow' AND COLUMN_NAME = 'TheirSenderCorrespondentId')
		BEGIN
			ALTER TABLE [dbo].[TxnCashFlow] ADD TheirSenderCorrespondentId INT NULL
		END;

		IF NOT EXISTS (SELECT 1
						   FROM INFORMATION_SCHEMA.COLUMNS
						   WHERE TABLE_NAME = 'TxnCashFlowHistory' AND COLUMN_NAME = 'TheirSenderCorrespondentId')
		BEGIN
			ALTER TABLE [dbo].[TxnCashFlowHistory] ADD TheirSenderCorrespondentId INT NULL
		END;
		--#endregion

		--#region TheirSenderCorrespondentGLCode
		IF NOT EXISTS (SELECT 1
						   FROM INFORMATION_SCHEMA.COLUMNS
						   WHERE TABLE_NAME = 'TxnCashFlow' AND COLUMN_NAME = 'TheirSenderCorrespondentGLCode')
		BEGIN
			ALTER TABLE [dbo].[TxnCashFlow] ADD TheirSenderCorrespondentGLCode NVARCHAR(10) NULL
		END;

		IF NOT EXISTS (SELECT 1
						   FROM INFORMATION_SCHEMA.COLUMNS
						   WHERE TABLE_NAME = 'TxnCashFlowHistory' AND COLUMN_NAME = 'TheirSenderCorrespondentGLCode')
		BEGIN
			ALTER TABLE [dbo].[TxnCashFlowHistory] ADD TheirSenderCorrespondentGLCode NVARCHAR(10) NULL
		END;
		--#endregion

		--#region TheirSenderCorrespondentName
		IF NOT EXISTS (SELECT 1
						   FROM INFORMATION_SCHEMA.COLUMNS
						   WHERE TABLE_NAME = 'TxnCashFlow' AND COLUMN_NAME = 'TheirSenderCorrespondentName')
			BEGIN
				ALTER TABLE [dbo].[TxnCashFlow] ADD TheirSenderCorrespondentName NVARCHAR(500) NULL		
			END;

		IF NOT EXISTS (SELECT 1
						   FROM INFORMATION_SCHEMA.COLUMNS
						   WHERE TABLE_NAME = 'TxnCashFlowHistory' AND COLUMN_NAME = 'TheirSenderCorrespondentName')
			BEGIN
				ALTER TABLE [dbo].[TxnCashFlowHistory] ADD TheirSenderCorrespondentName NVARCHAR(500) NULL		
			END;
		--#endregion

		--#region TheirSenderCorrespondentSwiftCode
		IF NOT EXISTS (SELECT 1
						   FROM INFORMATION_SCHEMA.COLUMNS
						   WHERE TABLE_NAME = 'TxnCashFlow' AND COLUMN_NAME = 'TheirSenderCorrespondentSwiftCode')
			BEGIN
				ALTER TABLE [dbo].[TxnCashFlow] ADD TheirSenderCorrespondentSwiftCode NVARCHAR(50) NULL		
			END;

		IF NOT EXISTS (SELECT 1
						   FROM INFORMATION_SCHEMA.COLUMNS
						   WHERE TABLE_NAME = 'TxnCashFlowHistory' AND COLUMN_NAME = 'TheirSenderCorrespondentSwiftCode')
			BEGIN
				ALTER TABLE [dbo].[TxnCashFlowHistory] ADD TheirSenderCorrespondentSwiftCode NVARCHAR(50) NULL		
			END;
		--#endregion

		--#region TheirSenderCorrespondentAccountNumber
		IF NOT EXISTS (SELECT 1
						   FROM INFORMATION_SCHEMA.COLUMNS
						   WHERE TABLE_NAME = 'TxnCashFlow' AND COLUMN_NAME = 'TheirSenderCorrespondentAccountNumber')
			BEGIN
				ALTER TABLE [dbo].[TxnCashFlow] ADD TheirSenderCorrespondentAccountNumber NVARCHAR(500) NULL		
			END;

		IF NOT EXISTS (SELECT 1
						   FROM INFORMATION_SCHEMA.COLUMNS
						   WHERE TABLE_NAME = 'TxnCashFlowHistory' AND COLUMN_NAME = 'TheirSenderCorrespondentAccountNumber')
			BEGIN
				ALTER TABLE [dbo].[TxnCashFlowHistory] ADD TheirSenderCorrespondentAccountNumber NVARCHAR(500) NULL		
			END;
		--#endregion

		--#region TheirBeneficiaryCorrespondentId
		IF NOT EXISTS (SELECT 1
						   FROM INFORMATION_SCHEMA.COLUMNS
						   WHERE TABLE_NAME = 'TxnCashFlow' AND COLUMN_NAME = 'TheirBeneficiaryCorrespondentId')
		BEGIN
			ALTER TABLE [dbo].[TxnCashFlow] ADD TheirBeneficiaryCorrespondentId INT NULL
		END;

		IF NOT EXISTS (SELECT 1
						   FROM INFORMATION_SCHEMA.COLUMNS
						   WHERE TABLE_NAME = 'TxnCashFlowHistory' AND COLUMN_NAME = 'TheirBeneficiaryCorrespondentId')
		BEGIN
			ALTER TABLE [dbo].[TxnCashFlowHistory] ADD TheirBeneficiaryCorrespondentId INT NULL
		END;
		--#endregion

		--#region TheirBeneficiaryCorrespondentGLCode
		IF NOT EXISTS (SELECT 1
						   FROM INFORMATION_SCHEMA.COLUMNS
						   WHERE TABLE_NAME = 'TxnCashFlow' AND COLUMN_NAME = 'TheirBeneficiaryCorrespondentGLCode')
		BEGIN
			ALTER TABLE [dbo].[TxnCashFlow] ADD TheirBeneficiaryCorrespondentGLCode NVARCHAR(10) NULL
		END;

		IF NOT EXISTS (SELECT 1
						   FROM INFORMATION_SCHEMA.COLUMNS
						   WHERE TABLE_NAME = 'TxnCashFlowHistory' AND COLUMN_NAME = 'TheirBeneficiaryCorrespondentGLCode')
		BEGIN
			ALTER TABLE [dbo].[TxnCashFlowHistory] ADD TheirBeneficiaryCorrespondentGLCode NVARCHAR(10) NULL
		END;
		--#endregion

		--#region TheirBeneficiaryCorrespondentName
		IF NOT EXISTS (SELECT 1
						   FROM INFORMATION_SCHEMA.COLUMNS
						   WHERE TABLE_NAME = 'TxnCashFlow' AND COLUMN_NAME = 'TheirBeneficiaryCorrespondentName')
			BEGIN
				ALTER TABLE [dbo].[TxnCashFlow] ADD TheirBeneficiaryCorrespondentName NVARCHAR(500) NULL		
			END;

		IF NOT EXISTS (SELECT 1
						   FROM INFORMATION_SCHEMA.COLUMNS
						   WHERE TABLE_NAME = 'TxnCashFlowHistory' AND COLUMN_NAME = 'TheirBeneficiaryCorrespondentName')
			BEGIN
				ALTER TABLE [dbo].[TxnCashFlowHistory] ADD TheirBeneficiaryCorrespondentName NVARCHAR(500) NULL
		
			END;
		--#endregion

		--#region TheirBeneficiaryCorrespondentSwiftCode
		IF NOT EXISTS (SELECT 1
						   FROM INFORMATION_SCHEMA.COLUMNS
						   WHERE TABLE_NAME = 'TxnCashFlow' AND COLUMN_NAME = 'TheirBeneficiaryCorrespondentSwiftCode')
			BEGIN
				ALTER TABLE [dbo].[TxnCashFlow] ADD TheirBeneficiaryCorrespondentSwiftCode NVARCHAR(50) NULL		
			END;

		IF NOT EXISTS (SELECT 1
						   FROM INFORMATION_SCHEMA.COLUMNS
						   WHERE TABLE_NAME = 'TxnCashFlowHistory' AND COLUMN_NAME = 'TheirBeneficiaryCorrespondentSwiftCode')
			BEGIN
				ALTER TABLE [dbo].[TxnCashFlowHistory] ADD TheirBeneficiaryCorrespondentSwiftCode NVARCHAR(50) NULL		
			END;
		--#endregion

		--#region TheirBeneficiaryCorrespondentAccountNumber
		IF NOT EXISTS (SELECT 1
						   FROM INFORMATION_SCHEMA.COLUMNS
						   WHERE TABLE_NAME = 'TxnCashFlow' AND COLUMN_NAME = 'TheirBeneficiaryCorrespondentAccountNumber')
			BEGIN
				ALTER TABLE [dbo].[TxnCashFlow] ADD TheirBeneficiaryCorrespondentAccountNumber NVARCHAR(500) NULL		
			END;

		IF NOT EXISTS (SELECT 1
						   FROM INFORMATION_SCHEMA.COLUMNS
						   WHERE TABLE_NAME = 'TxnCashFlowHistory' AND COLUMN_NAME = 'TheirBeneficiaryCorrespondentAccountNumber')
			BEGIN
				ALTER TABLE [dbo].[TxnCashFlowHistory] ADD  TheirBeneficiaryCorrespondentAccountNumber NVARCHAR(500) NULL		
			END;
		--#endregion
--#endregion

--#region TXN SYNC PAYMENT FIELDS      
		--#region PaymentInstructionType
		IF NOT EXISTS (SELECT 1
						   FROM INFORMATION_SCHEMA.COLUMNS
						   WHERE TABLE_NAME = 'TxnSync' AND COLUMN_NAME = 'PaymentInstructionType')
		BEGIN
			ALTER TABLE [dbo].[TxnSync] ADD PaymentInstructionType NVARCHAR(50) NULL
		END;
		--#endregion

		--#region ReconciliationType
		IF NOT EXISTS (SELECT 1
						   FROM INFORMATION_SCHEMA.COLUMNS
						   WHERE TABLE_NAME = 'TxnSync' AND COLUMN_NAME = 'ReconciliationType')
		BEGIN
			ALTER TABLE [dbo].[TxnSync] ADD ReconciliationType NVARCHAR(50) NULL
		END;
		--#endregion

		--#region SendPaymentMessage
		IF NOT EXISTS (SELECT 1
						   FROM INFORMATION_SCHEMA.COLUMNS
						   WHERE TABLE_NAME = 'TxnSync' AND COLUMN_NAME = 'SendPaymentMessage')
			BEGIN
				ALTER TABLE [dbo].[TxnSync] ADD SendPaymentMessage BIT NOT NULL	CONSTRAINT DF_TxnSync_SendPaymentMessage DEFAULT(0)	
			END;
		--#endregion

		--#region SendConfirmationMessage
		IF NOT EXISTS (SELECT 1
						   FROM INFORMATION_SCHEMA.COLUMNS
						   WHERE TABLE_NAME = 'TxnSync' AND COLUMN_NAME = 'SendConfirmationMessage')
			BEGIN
				ALTER TABLE [dbo].[TxnSync] ADD SendConfirmationMessage BIT NOT NULL CONSTRAINT DF_TxnSync_SendConfirmationMessage DEFAULT(0)	
		
			END;
		--#endregion

		--#region SendNoticeToReceiveMessage
		IF NOT EXISTS (SELECT 1
						   FROM INFORMATION_SCHEMA.COLUMNS
						   WHERE TABLE_NAME = 'TxnSync' AND COLUMN_NAME = 'SendNoticeToReceiveMessage')
		BEGIN
			ALTER TABLE [dbo].[TxnSync] ADD SendNoticeToReceiveMessage BIT NOT NULL CONSTRAINT DF_TxnSync_SendNoticeToReceiveMessage DEFAULT(0)
		END;
		--#endregion

		--#region OutgoingPaymentAccountingType
		IF NOT EXISTS (SELECT 1
						   FROM INFORMATION_SCHEMA.COLUMNS
						   WHERE TABLE_NAME = 'TxnSync' AND COLUMN_NAME = 'OutgoingPaymentAccountingType')
		BEGIN
			ALTER TABLE [dbo].[TxnSync] ADD OutgoingPaymentAccountingType NVARCHAR(50) NULL
		END;
		--#endregion

		--#region OutgoingPaymentAccountingGLType
		IF NOT EXISTS (SELECT 1
						   FROM INFORMATION_SCHEMA.COLUMNS
						   WHERE TABLE_NAME = 'TxnSync' AND COLUMN_NAME = 'OutgoingPaymentAccountingGLType')
		BEGIN
			ALTER TABLE [dbo].[TxnSync] ADD OutgoingPaymentAccountingGLType NVARCHAR(50) NULL
		END;
		--#endregion

		--#region OutgoingPaymentAccountingGL
		IF NOT EXISTS (SELECT 1
						   FROM INFORMATION_SCHEMA.COLUMNS
						   WHERE TABLE_NAME = 'TxnSync' AND COLUMN_NAME = 'OutgoingPaymentAccountingGL')
		BEGIN
			ALTER TABLE [dbo].[TxnSync] ADD OutgoingPaymentAccountingGL NVARCHAR(10) NULL
		END;
		--#endregion
		
		--#region IncomingPaymentAccountingType
		IF NOT EXISTS (SELECT 1
						   FROM INFORMATION_SCHEMA.COLUMNS
						   WHERE TABLE_NAME = 'TxnSync' AND COLUMN_NAME = 'IncomingPaymentAccountingType')
		BEGIN
			ALTER TABLE [dbo].[TxnSync] ADD IncomingPaymentAccountingType NVARCHAR(50) NULL
		END;
		--#endregion

		--#region IncomingPaymentAccountingGLType
		IF NOT EXISTS (SELECT 1
						   FROM INFORMATION_SCHEMA.COLUMNS
						   WHERE TABLE_NAME = 'TxnSync' AND COLUMN_NAME = 'IncomingPaymentAccountingGLType')
		BEGIN
			ALTER TABLE [dbo].[TxnSync] ADD IncomingPaymentAccountingGLType NVARCHAR(50) NULL
		END;
		--#endregion

		--#region IncomingPaymentAccountingGL
		IF NOT EXISTS (SELECT 1
						   FROM INFORMATION_SCHEMA.COLUMNS
						   WHERE TABLE_NAME = 'TxnSync' AND COLUMN_NAME = 'IncomingPaymentAccountingGL')
		BEGIN
			ALTER TABLE [dbo].[TxnSync] ADD IncomingPaymentAccountingGL NVARCHAR(10) NULL
		END;
		--#endregion

		--#region TheirBeneficiaryCorrespondentId
		IF NOT EXISTS (SELECT 1
						   FROM INFORMATION_SCHEMA.COLUMNS
						   WHERE TABLE_NAME = 'TxnSync' AND COLUMN_NAME = 'TheirBeneficiaryCorrespondentId')
		BEGIN
			ALTER TABLE [dbo].[TxnSync] ADD TheirBeneficiaryCorrespondentId INT NULL
		END;
		--#endregion

		--#region TheirBeneficiaryCorrespondentGLCode
		IF NOT EXISTS (SELECT 1
						   FROM INFORMATION_SCHEMA.COLUMNS
						   WHERE TABLE_NAME = 'TxnSync' AND COLUMN_NAME = 'TheirBeneficiaryCorrespondentGLCode')
		BEGIN
			ALTER TABLE [dbo].[TxnSync] ADD TheirBeneficiaryCorrespondentGLCode NVARCHAR(10) NULL
		END;
		--#endregion

		--#region TheirSenderCorrespondentId
		IF NOT EXISTS (SELECT 1
						   FROM INFORMATION_SCHEMA.COLUMNS
						   WHERE TABLE_NAME = 'TxnSync' AND COLUMN_NAME = 'TheirSenderCorrespondentId')
		BEGIN
			ALTER TABLE [dbo].[TxnSync] ADD TheirSenderCorrespondentId INT NULL
		END;
		--#endregion

		--#region TheirSenderCorrespondentGLCode
		IF NOT EXISTS (SELECT 1
						   FROM INFORMATION_SCHEMA.COLUMNS
						   WHERE TABLE_NAME = 'TxnSync' AND COLUMN_NAME = 'TheirSenderCorrespondentGLCode')
		BEGIN
			ALTER TABLE [dbo].[TxnSync] ADD TheirSenderCorrespondentGLCode NVARCHAR(10) NULL
		END;
		--#endregion		
--#endregion

  COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    PRINT 'rollback';
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;
    PRINT ERROR_MESSAGE();
    throw;
END CATCH
