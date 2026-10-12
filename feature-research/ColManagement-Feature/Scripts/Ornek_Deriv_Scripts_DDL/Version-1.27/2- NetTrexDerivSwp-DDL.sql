---Check Database Name
use [NetTrexDerivSWP]
GO

--#region TXN TRANSACTION Cus Account Fields
 IF NOT EXISTS (SELECT 1
                   FROM INFORMATION_SCHEMA.COLUMNS
                   WHERE TABLE_NAME = 'TxnTransaction'
					     AND COLUMN_NAME = 'ReceiveInvestmentAccount')
        BEGIN
            ALTER TABLE [dbo].[TxnTransaction]
				ADD ReceiveInvestmentAccount BIGINT NULL
        END;

 IF NOT EXISTS (SELECT 1
                   FROM INFORMATION_SCHEMA.COLUMNS
                   WHERE TABLE_NAME = 'TxnTransaction'
					     AND COLUMN_NAME = 'ReceiveInvestmentAccountGLCode')
        BEGIN
            ALTER TABLE [dbo].[TxnTransaction]
				ADD ReceiveInvestmentAccountGLCode NVARCHAR(10) NULL
        END;

 IF NOT EXISTS (SELECT 1
                   FROM INFORMATION_SCHEMA.COLUMNS
                   WHERE TABLE_NAME = 'TxnTransaction'
					     AND COLUMN_NAME = 'ReceiveCurrentAccount')
        BEGIN
            ALTER TABLE [dbo].[TxnTransaction]
				ADD ReceiveCurrentAccount BIGINT NULL
        END;

 IF NOT EXISTS (SELECT 1
                   FROM INFORMATION_SCHEMA.COLUMNS
                   WHERE TABLE_NAME = 'TxnTransaction'
					     AND COLUMN_NAME = 'ReceiveCurrentAccountGLCode')
        BEGIN
            ALTER TABLE [dbo].[TxnTransaction]
				ADD ReceiveCurrentAccountGLCode NVARCHAR(10) NULL
        END;

 IF NOT EXISTS (SELECT 1
                   FROM INFORMATION_SCHEMA.COLUMNS
                   WHERE TABLE_NAME = 'TxnTransaction'
					     AND COLUMN_NAME = 'ReceiveWHTAccount')
        BEGIN
            ALTER TABLE [dbo].[TxnTransaction]
				ADD ReceiveWHTAccount BIGINT NULL
        END;

 IF NOT EXISTS (SELECT 1
                   FROM INFORMATION_SCHEMA.COLUMNS
                   WHERE TABLE_NAME = 'TxnTransaction'
					     AND COLUMN_NAME = 'ReceiveWHTAccountGLCode')
        BEGIN
            ALTER TABLE [dbo].[TxnTransaction]
				ADD ReceiveWHTAccountGLCode NVARCHAR(10) NULL
        END;

 IF NOT EXISTS (SELECT 1
                   FROM INFORMATION_SCHEMA.COLUMNS
                   WHERE TABLE_NAME = 'TxnTransaction'
					     AND COLUMN_NAME = 'PayInvestmentAccount')
        BEGIN
            ALTER TABLE [dbo].[TxnTransaction]
				ADD PayInvestmentAccount BIGINT NULL
        END;

 IF NOT EXISTS (SELECT 1
                   FROM INFORMATION_SCHEMA.COLUMNS
                   WHERE TABLE_NAME = 'TxnTransaction'
					     AND COLUMN_NAME = 'PayInvestmentAccountGLCode')
        BEGIN
            ALTER TABLE [dbo].[TxnTransaction]
				ADD PayInvestmentAccountGLCode NVARCHAR(10) NULL
        END;

 IF NOT EXISTS (SELECT 1
                   FROM INFORMATION_SCHEMA.COLUMNS
                   WHERE TABLE_NAME = 'TxnTransaction'
					     AND COLUMN_NAME = 'PayCurrentAccount')
        BEGIN
            ALTER TABLE [dbo].[TxnTransaction]
				ADD PayCurrentAccount BIGINT NULL
        END;

 IF NOT EXISTS (SELECT 1
                   FROM INFORMATION_SCHEMA.COLUMNS
                   WHERE TABLE_NAME = 'TxnTransaction'
					     AND COLUMN_NAME = 'PayCurrentAccountGLCode')
        BEGIN
            ALTER TABLE [dbo].[TxnTransaction]
				ADD PayCurrentAccountGLCode NVARCHAR(10) NULL
        END;

 IF NOT EXISTS (SELECT 1
                   FROM INFORMATION_SCHEMA.COLUMNS
                   WHERE TABLE_NAME = 'TxnTransaction'
					     AND COLUMN_NAME = 'PayWHTAccount')
        BEGIN
            ALTER TABLE [dbo].[TxnTransaction]
				ADD PayWHTAccount BIGINT NULL
        END;

 IF NOT EXISTS (SELECT 1
                   FROM INFORMATION_SCHEMA.COLUMNS
                   WHERE TABLE_NAME = 'TxnTransaction'
					     AND COLUMN_NAME = 'PayWHTAccountGLCode')
        BEGIN
            ALTER TABLE [dbo].[TxnTransaction]
				ADD PayWHTAccountGLCode NVARCHAR(10) NULL
        END;

--#endregion

--#region TXN TRANSACTION HISTORY Cus Account Fields
 IF NOT EXISTS (SELECT 1
                   FROM INFORMATION_SCHEMA.COLUMNS
                   WHERE TABLE_NAME = 'TxnTransactionHistory'
					     AND COLUMN_NAME = 'ReceiveInvestmentAccount')
        BEGIN
            ALTER TABLE [dbo].[TxnTransactionHistory]
				ADD ReceiveInvestmentAccount BIGINT NULL
        END;

 IF NOT EXISTS (SELECT 1
                   FROM INFORMATION_SCHEMA.COLUMNS
                   WHERE TABLE_NAME = 'TxnTransactionHistory'
					     AND COLUMN_NAME = 'ReceiveInvestmentAccountGLCode')
        BEGIN
            ALTER TABLE [dbo].[TxnTransactionHistory]
				ADD ReceiveInvestmentAccountGLCode NVARCHAR(10) NULL
        END;

 IF NOT EXISTS (SELECT 1
                   FROM INFORMATION_SCHEMA.COLUMNS
                   WHERE TABLE_NAME = 'TxnTransactionHistory'
					     AND COLUMN_NAME = 'ReceiveCurrentAccount')
        BEGIN
            ALTER TABLE [dbo].[TxnTransactionHistory]
				ADD ReceiveCurrentAccount BIGINT NULL
        END;

 IF NOT EXISTS (SELECT 1
                   FROM INFORMATION_SCHEMA.COLUMNS
                   WHERE TABLE_NAME = 'TxnTransactionHistory'
					     AND COLUMN_NAME = 'ReceiveCurrentAccountGLCode')
        BEGIN
            ALTER TABLE [dbo].[TxnTransactionHistory]
				ADD ReceiveCurrentAccountGLCode NVARCHAR(10) NULL
        END;

 IF NOT EXISTS (SELECT 1
                   FROM INFORMATION_SCHEMA.COLUMNS
                   WHERE TABLE_NAME = 'TxnTransactionHistory'
					     AND COLUMN_NAME = 'ReceiveWHTAccount')
        BEGIN
            ALTER TABLE [dbo].[TxnTransactionHistory]
				ADD ReceiveWHTAccount BIGINT NULL
        END;

 IF NOT EXISTS (SELECT 1
                   FROM INFORMATION_SCHEMA.COLUMNS
                   WHERE TABLE_NAME = 'TxnTransactionHistory'
					     AND COLUMN_NAME = 'ReceiveWHTAccountGLCode')
        BEGIN
            ALTER TABLE [dbo].[TxnTransactionHistory]
				ADD ReceiveWHTAccountGLCode NVARCHAR(10) NULL
        END;

 IF NOT EXISTS (SELECT 1
                   FROM INFORMATION_SCHEMA.COLUMNS
                   WHERE TABLE_NAME = 'TxnTransactionHistory'
					     AND COLUMN_NAME = 'PayInvestmentAccount')
        BEGIN
            ALTER TABLE [dbo].[TxnTransactionHistory]
				ADD PayInvestmentAccount BIGINT NULL
        END;

IF NOT EXISTS (SELECT 1
                   FROM INFORMATION_SCHEMA.COLUMNS
                   WHERE TABLE_NAME = 'TxnTransactionHistory'
					     AND COLUMN_NAME = 'PayInvestmentAccountGLCode')
        BEGIN
            ALTER TABLE [dbo].[TxnTransactionHistory]
				ADD PayInvestmentAccountGLCode NVARCHAR(10) NULL
        END;
	
 IF NOT EXISTS (SELECT 1
                   FROM INFORMATION_SCHEMA.COLUMNS
                   WHERE TABLE_NAME = 'TxnTransactionHistory'
					     AND COLUMN_NAME = 'PayCurrentAccount')
        BEGIN
            ALTER TABLE [dbo].[TxnTransactionHistory]
				ADD PayCurrentAccount BIGINT NULL
        END;

 IF NOT EXISTS (SELECT 1
                   FROM INFORMATION_SCHEMA.COLUMNS
                   WHERE TABLE_NAME = 'TxnTransactionHistory'
					     AND COLUMN_NAME = 'PayCurrentAccountGLCode')
        BEGIN
            ALTER TABLE [dbo].[TxnTransactionHistory]
				ADD PayCurrentAccountGLCode NVARCHAR(10) NULL
        END;

 IF NOT EXISTS (SELECT 1
                   FROM INFORMATION_SCHEMA.COLUMNS
                   WHERE TABLE_NAME = 'TxnTransactionHistory'
					     AND COLUMN_NAME = 'PayWHTAccount')
        BEGIN
            ALTER TABLE [dbo].[TxnTransactionHistory]
				ADD PayWHTAccount BIGINT NULL
        END;

 IF NOT EXISTS (SELECT 1
                   FROM INFORMATION_SCHEMA.COLUMNS
                   WHERE TABLE_NAME = 'TxnTransactionHistory'
					     AND COLUMN_NAME = 'PayWHTAccountGLCode')
    BEGIN
        ALTER TABLE [dbo].[TxnTransactionHistory]
			ADD PayWHTAccountGLCode NVARCHAR(10) NULL
    END;

--#endregion

--#region TXN TRANSACTION Correspandent fields set nullable
 IF EXISTS (SELECT 1
                   FROM INFORMATION_SCHEMA.COLUMNS
                   WHERE TABLE_NAME = 'TxnTransaction'
					     AND COLUMN_NAME = 'OutgoingCorrespondentId')
    BEGIN
        ALTER TABLE [dbo].[TxnTransaction]
			ALTER COLUMN OutgoingCorrespondentId INT NULL
    END;

 IF EXISTS (SELECT 1
                   FROM INFORMATION_SCHEMA.COLUMNS
                   WHERE TABLE_NAME = 'TxnTransaction'
					     AND COLUMN_NAME = 'OutgoingCorrespondentAccountNumber')
    BEGIN
        ALTER TABLE TxnTransaction
			ALTER COLUMN OutgoingCorrespondentAccountNumber BIGINT NULL;
    END;

 IF EXISTS (SELECT 1
                   FROM INFORMATION_SCHEMA.COLUMNS
                   WHERE TABLE_NAME = 'TxnTransaction'
					     AND COLUMN_NAME = 'TheirBeneficiaryCorrespondentName')
    BEGIN
        ALTER TABLE [dbo].[TxnTransaction]
			ALTER COLUMN TheirBeneficiaryCorrespondentName NVARCHAR(500) NULL
    END;

 IF EXISTS (SELECT 1
                   FROM INFORMATION_SCHEMA.COLUMNS
                   WHERE TABLE_NAME = 'TxnTransaction'
					     AND COLUMN_NAME = 'TheirBeneficiaryCorrespondentSwiftCode')
    BEGIN
        ALTER TABLE [dbo].[TxnTransaction]
			ALTER COLUMN TheirBeneficiaryCorrespondentSwiftCode NVARCHAR(50) NULL
    END;

IF EXISTS (SELECT 1
                   FROM INFORMATION_SCHEMA.COLUMNS
                   WHERE TABLE_NAME = 'TxnTransaction'
					     AND COLUMN_NAME = 'TheirBeneficiaryCorrespondentAccountNumber')
    BEGIN
        ALTER TABLE [dbo].[TxnTransaction]
			ALTER COLUMN TheirBeneficiaryCorrespondentAccountNumber NVARCHAR(500) NULL
    END;

IF EXISTS (SELECT 1
                   FROM INFORMATION_SCHEMA.COLUMNS
                   WHERE TABLE_NAME = 'TxnTransaction'
					     AND COLUMN_NAME = 'TheirSenderCorrespondentName')
    BEGIN
        ALTER TABLE [dbo].[TxnTransaction]
			ALTER COLUMN TheirSenderCorrespondentName NVARCHAR(500) NULL
    END;

IF EXISTS (SELECT 1
                   FROM INFORMATION_SCHEMA.COLUMNS
                   WHERE TABLE_NAME = 'TxnTransaction'
					     AND COLUMN_NAME = 'TheirSenderCorrespondentSwiftCode')
    BEGIN
        ALTER TABLE [dbo].[TxnTransaction]
			ALTER COLUMN TheirSenderCorrespondentSwiftCode NVARCHAR(50) NULL
    END;

IF EXISTS (SELECT 1
                   FROM INFORMATION_SCHEMA.COLUMNS
                   WHERE TABLE_NAME = 'TxnTransaction'
					     AND COLUMN_NAME = 'TheirSenderCorrespondentAccountNumber')
    BEGIN
        ALTER TABLE [dbo].[TxnTransaction]
			ALTER COLUMN TheirSenderCorrespondentAccountNumber NVARCHAR(500) NULL
    END;

IF EXISTS (SELECT 1
                   FROM INFORMATION_SCHEMA.COLUMNS
                   WHERE TABLE_NAME = 'TxnTransaction'
					     AND COLUMN_NAME = 'IncomingCorrespondentId')
    BEGIN
        ALTER TABLE [dbo].[TxnTransaction]
			ALTER COLUMN IncomingCorrespondentId INT NULL
    END;

IF EXISTS (SELECT 1
                   FROM INFORMATION_SCHEMA.COLUMNS
                   WHERE TABLE_NAME = 'TxnTransaction'
					     AND COLUMN_NAME = 'IncomingCorrespondentAccountNumber')
    BEGIN
        ALTER TABLE [dbo].[TxnTransaction]
			ALTER COLUMN IncomingCorrespondentAccountNumber BIGINT NULL
    END;
--#endregion

--#region TXN TRANSACTION HISTORY Correspandent fields set nullable
 IF EXISTS (SELECT 1
                   FROM INFORMATION_SCHEMA.COLUMNS
                   WHERE TABLE_NAME = 'TxnTransactionHistory'
					     AND COLUMN_NAME = 'OutgoingCorrespondentId')
    BEGIN
        ALTER TABLE [dbo].[TxnTransactionHistory]
			ALTER COLUMN OutgoingCorrespondentId INT NULL
    END;

 IF EXISTS (SELECT 1
                   FROM INFORMATION_SCHEMA.COLUMNS
                   WHERE TABLE_NAME = 'TxnTransactionHistory'
					     AND COLUMN_NAME = 'OutgoingCorrespondentAccountNumber')
    BEGIN
        ALTER TABLE [TxnTransactionHistory]
			ALTER COLUMN OutgoingCorrespondentAccountNumber BIGINT NULL;
    END;

 IF EXISTS (SELECT 1
                   FROM INFORMATION_SCHEMA.COLUMNS
                   WHERE TABLE_NAME = 'TxnTransactionHistory'
					     AND COLUMN_NAME = 'TheirBeneficiaryCorrespondentName')
    BEGIN
        ALTER TABLE [dbo].[TxnTransactionHistory]
			ALTER COLUMN TheirBeneficiaryCorrespondentName NVARCHAR(500) NULL
    END;

 IF EXISTS (SELECT 1
                   FROM INFORMATION_SCHEMA.COLUMNS
                   WHERE TABLE_NAME = 'TxnTransactionHistory'
					     AND COLUMN_NAME = 'TheirBeneficiaryCorrespondentSwiftCode')
    BEGIN
        ALTER TABLE [dbo].[TxnTransactionHistory]
			ALTER COLUMN TheirBeneficiaryCorrespondentSwiftCode NVARCHAR(50) NULL
    END;

IF EXISTS (SELECT 1
                   FROM INFORMATION_SCHEMA.COLUMNS
                   WHERE TABLE_NAME = 'TxnTransactionHistory'
					     AND COLUMN_NAME = 'TheirBeneficiaryCorrespondentAccountNumber')
    BEGIN
        ALTER TABLE [dbo].[TxnTransactionHistory]
			ALTER COLUMN TheirBeneficiaryCorrespondentAccountNumber NVARCHAR(500) NULL
    END;

IF EXISTS (SELECT 1
                   FROM INFORMATION_SCHEMA.COLUMNS
                   WHERE TABLE_NAME = 'TxnTransactionHistory'
					     AND COLUMN_NAME = 'TheirSenderCorrespondentName')
    BEGIN
        ALTER TABLE [dbo].[TxnTransactionHistory]
			ALTER COLUMN TheirSenderCorrespondentName NVARCHAR(500) NULL
    END;

IF EXISTS (SELECT 1
                   FROM INFORMATION_SCHEMA.COLUMNS
                   WHERE TABLE_NAME = 'TxnTransactionHistory'
					     AND COLUMN_NAME = 'TheirSenderCorrespondentSwiftCode')
    BEGIN
        ALTER TABLE [dbo].[TxnTransactionHistory]
			ALTER COLUMN TheirSenderCorrespondentSwiftCode NVARCHAR(50) NULL
    END;

IF EXISTS (SELECT 1
                   FROM INFORMATION_SCHEMA.COLUMNS
                   WHERE TABLE_NAME = 'TxnTransactionHistory'
					     AND COLUMN_NAME = 'TheirSenderCorrespondentAccountNumber')
    BEGIN
        ALTER TABLE [dbo].[TxnTransactionHistory]
			ALTER COLUMN TheirSenderCorrespondentAccountNumber NVARCHAR(500) NULL
    END;

IF EXISTS (SELECT 1
                   FROM INFORMATION_SCHEMA.COLUMNS
                   WHERE TABLE_NAME = 'TxnTransactionHistory'
					     AND COLUMN_NAME = 'IncomingCorrespondentId')
    BEGIN
        ALTER TABLE [dbo].[TxnTransactionHistory]
			ALTER COLUMN IncomingCorrespondentId INT NULL
    END;

IF EXISTS (SELECT 1
                   FROM INFORMATION_SCHEMA.COLUMNS
                   WHERE TABLE_NAME = 'TxnTransactionHistory'
					     AND COLUMN_NAME = 'IncomingCorrespondentAccountNumber')
    BEGIN
        ALTER TABLE [dbo].[TxnTransactionHistory]
			ALTER COLUMN IncomingCorrespondentAccountNumber BIGINT NULL
    END;
--#endregion

--#region TXN DOCUMENT Create
IF NOT EXISTS (SELECT 1 
					  FROM sys.objects 
					  WHERE object_id = OBJECT_ID(N'[dbo].[TxnDocument]') AND type in (N'U'))
BEGIN
		CREATE TABLE [dbo].[TxnDocument](
		[Id] [int] IDENTITY(1,1) NOT NULL,
		[TxnId] [int] NOT NULL,
		[CustomerId] [int] NULL,
		[FileName] [nvarchar](500) NOT NULL,
		[FileExtension] [nvarchar](10) NULL,
		[Version] [int] NULL,
		[Status] [int] NULL,
		[Guid] [nvarchar](100) NULL,
		[ReferenceGuid] [nvarchar](100) NULL,
		[ReferenceId] [int] NULL,
		[DocumentTypeId] [int] NULL,
		[StateId] [int] NULL,
		[StateMaker] [nvarchar](100) NULL,
		[StateDate] [datetime] NULL,
	 CONSTRAINT [PK_TxnDocument] PRIMARY KEY CLUSTERED 
	(
		[Id] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
	) ON [PRIMARY]
END;

IF NOT EXISTS (SELECT 1 
					  FROM sys.objects 
					  WHERE object_id = OBJECT_ID(N'[dbo].[TxnDocumentHistory]') AND type in (N'U'))
BEGIN
		CREATE TABLE [dbo].[TxnDocumentHistory](
		[HistoryId] [int] IDENTITY(1,1) NOT NULL,
		[Id] [int] NOT NULL,
		[TxnId] [int] NOT NULL,
		[CustomerId] [int] NULL,
		[FileName] [nvarchar](500) NOT NULL,
		[FileExtension] [nvarchar](10) NULL,
		[Version] [int] NULL,
		[Status] [int] NULL,
		[Guid] [nvarchar](100) NULL,
		[ReferenceGuid] [nvarchar](100) NULL,
		[ReferenceId] [int] NULL,
		[DocumentTypeId] [int] NULL,
		[StateId] [int] NULL,
		[StateMaker] [nvarchar](100) NULL,
		[StateDate] [datetime] NULL,
	 CONSTRAINT [PK_TxnDocumentHistory] PRIMARY KEY CLUSTERED 
	(
		[HistoryId] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
	) ON [PRIMARY]
END;


SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER TRIGGER [dbo].[TxnDocumentTrigger] ON [dbo].[TxnDocument]
FOR INSERT, UPDATE
AS
INSERT INTO [dbo].[TxnDocumentHistory] SELECT * FROM inserted
GO

ALTER TABLE [dbo].[TxnDocument] ENABLE TRIGGER [TxnDocumentTrigger]
GO

--#endregion

--#region Txn Note Create
IF NOT EXISTS (SELECT 1 
					  FROM sys.objects 
					  WHERE object_id = OBJECT_ID(N'[dbo].[TxnNote]') AND type in (N'U'))
BEGIN
	CREATE TABLE [dbo].[TxnNote](
		[Id] [int] IDENTITY(1,1) NOT NULL,
		[ParentId] [int] NULL,
		[TxnId] [int] NOT NULL,
		[Title] [nvarchar](100) NOT NULL,
		[Description] [nvarchar](max) NULL,
		[StateId] [int] NOT NULL,
		[StateDate] [datetime] NOT NULL,
		[StateMaker] [nvarchar](80) NOT NULL,
	 CONSTRAINT [PK_TxnNote] PRIMARY KEY CLUSTERED 
	(
		[Id] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
	) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END;

IF NOT EXISTS (SELECT 1 
					  FROM sys.objects 
					  WHERE object_id = OBJECT_ID(N'[dbo].[TxnNoteHistory]') AND type in (N'U'))
BEGIN
	CREATE TABLE [dbo].[TxnNoteHistory](
		[HistoryId] [int] IDENTITY(1,1) NOT NULL,
		[Id] [int] NULL,
		[ParentId] [int] NULL,
		[TxnId] [int] NOT NULL,
		[Title] [nvarchar](100) NOT NULL,
		[Description] [nvarchar](max) NULL,
		[StateId] [int] NOT NULL,
		[StateDate] [datetime] NOT NULL,
		[StateMaker] [nvarchar](80) NOT NULL,
	 CONSTRAINT [PK_TxnNoteHistory] PRIMARY KEY CLUSTERED 
	(
		[HistoryId] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
	) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END;

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE OR ALTER TRIGGER [dbo].[TxnNoteTrigger] ON [dbo].[TxnNote]
	FOR INSERT, UPDATE
	AS
	INSERT INTO [dbo].[txnNoteHistory] SELECT * FROM inserted
--#endregion

