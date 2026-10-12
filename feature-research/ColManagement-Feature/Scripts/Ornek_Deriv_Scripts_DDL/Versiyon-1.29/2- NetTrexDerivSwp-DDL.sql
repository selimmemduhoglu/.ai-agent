--Check Database Name
USE NetTrexDerivSWP
GO

BEGIN TRANSACTION;

BEGIN TRY

    --#region FLOW TRANSITION DATA
    IF NOT EXISTS (SELECT 1 
                        FROM sys.objects 
                        WHERE object_id = OBJECT_ID(N'[dbo].[FlowTransitionData]') AND type in (N'U'))
    BEGIN
        CREATE TABLE [dbo].[FlowTransitionData](
            [Id] [bigint] NOT NULL,
            [FlowSetId] [int] NOT NULL,
            [TransactionType] [nvarchar](100) NOT NULL,
            [TransactionKey] [nvarchar](100) NULL,
            [FlowJson] [nvarchar](max) NOT NULL,
            [CreatedAt] [datetime] NOT NULL,
            [UpdatedAt] [datetime] NULL,
            [LastStateId] [bigint] NOT NULL,
            [LastStateMaker] [nvarchar](80) NOT NULL,
        CONSTRAINT [PK_FlowTansitionData] PRIMARY KEY CLUSTERED 
        (
            [Id] ASC
        )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
        ) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

        ALTER TABLE [dbo].[FlowTransitionData] ADD  CONSTRAINT [DF_CreatedAt]  DEFAULT (getdate()) FOR [CreatedAt]
    END;
    --#endregion

    --#region TxnTransaction FLOW FIELDS 
    IF EXISTS (SELECT 1
						FROM INFORMATION_SCHEMA.COLUMNS
						WHERE TABLE_NAME = 'TxnTransaction' AND COLUMN_NAME = 'StateId')
	BEGIN
		ALTER TABLE [dbo].[TxnTransaction] ALTER COLUMN [StateId] BIGINT NOT NULL
	END
    ELSE
    BEGIN
        ALTER TABLE [dbo].[TxnTransaction] ADD [StateId] BIGINT NOT NULL
    END;

    IF NOT EXISTS (SELECT 1
						FROM INFORMATION_SCHEMA.COLUMNS
						WHERE TABLE_NAME = 'TxnTransaction' AND COLUMN_NAME = 'CreatedBy')
	BEGIN
		ALTER TABLE [dbo].[TxnTransaction] ADD [CreatedBy] NVARCHAR(80) NULL
	END;

    IF NOT EXISTS (SELECT 1
						FROM INFORMATION_SCHEMA.COLUMNS
						WHERE TABLE_NAME = 'TxnTransaction' AND COLUMN_NAME = 'CreatedDate')
	BEGIN
		ALTER TABLE [dbo].[TxnTransaction] ADD [CreatedDate] DATETIME NULL
	END;

    IF NOT EXISTS (SELECT 1
						FROM INFORMATION_SCHEMA.COLUMNS
						WHERE TABLE_NAME = 'TxnTransaction' AND COLUMN_NAME = 'PreviousStateId')
	BEGIN
		ALTER TABLE [dbo].[TxnTransaction] ADD [PreviousStateId] BIGINT NULL
	END;

    IF NOT EXISTS (SELECT 1
						FROM INFORMATION_SCHEMA.COLUMNS
						WHERE TABLE_NAME = 'TxnTransaction' AND COLUMN_NAME = 'PreviousStateMaker')
	BEGIN
		ALTER TABLE [dbo].[TxnTransaction] ADD [PreviousStateMaker] NVARCHAR(80) NULL
	END;

    IF NOT EXISTS (SELECT 1
						FROM INFORMATION_SCHEMA.COLUMNS
						WHERE TABLE_NAME = 'TxnTransaction' AND COLUMN_NAME = 'PreviousStateDate')
	BEGIN
		ALTER TABLE [dbo].[TxnTransaction] ADD [PreviousStateDate] DATETIME NULL
	END;

    IF NOT EXISTS (SELECT 1
						FROM INFORMATION_SCHEMA.COLUMNS
						WHERE TABLE_NAME = 'TxnTransaction' AND COLUMN_NAME = 'FlowId')
	BEGIN
		ALTER TABLE [dbo].[TxnTransaction] ADD FlowId BIGINT NOT NULL DEFAULT 0
	END;
    --#endregion

    --#region TxnTransaction History FLOW FIELDS 
    IF EXISTS (SELECT 1
						FROM INFORMATION_SCHEMA.COLUMNS
						WHERE TABLE_NAME = 'TxnTransactionHistory' AND COLUMN_NAME = 'StateId')
	BEGIN
		ALTER TABLE [dbo].[TxnTransactionHistory] ALTER COLUMN [StateId] BIGINT NOT NULL
	END
    ELSE
    BEGIN
        ALTER TABLE [dbo].[TxnTransactionHistory] ADD [StateId] BIGINT NOT NULL
    END;

    IF NOT EXISTS (SELECT 1
						FROM INFORMATION_SCHEMA.COLUMNS
						WHERE TABLE_NAME = 'TxnTransactionHistory' AND COLUMN_NAME = 'CreatedBy')
	BEGIN
		ALTER TABLE [dbo].[TxnTransactionHistory] ADD [CreatedBy] NVARCHAR(80) NULL
	END;

    IF NOT EXISTS (SELECT 1
						FROM INFORMATION_SCHEMA.COLUMNS
						WHERE TABLE_NAME = 'TxnTransactionHistory' AND COLUMN_NAME = 'CreatedDate')
	BEGIN
		ALTER TABLE [dbo].[TxnTransactionHistory] ADD [CreatedDate] DATETIME NULL
	END;

    IF NOT EXISTS (SELECT 1
						FROM INFORMATION_SCHEMA.COLUMNS
						WHERE TABLE_NAME = 'TxnTransactionHistory' AND COLUMN_NAME = 'PreviousStateId')
	BEGIN
		ALTER TABLE [dbo].[TxnTransactionHistory] ADD [PreviousStateId] BIGINT NULL
	END;

    IF NOT EXISTS (SELECT 1
						FROM INFORMATION_SCHEMA.COLUMNS
						WHERE TABLE_NAME = 'TxnTransactionHistory' AND COLUMN_NAME = 'PreviousStateMaker')
	BEGIN
		ALTER TABLE [dbo].[TxnTransactionHistory] ADD [PreviousStateMaker] NVARCHAR(80) NULL
	END;

    IF NOT EXISTS (SELECT 1
						FROM INFORMATION_SCHEMA.COLUMNS
						WHERE TABLE_NAME = 'TxnTransactionHistory' AND COLUMN_NAME = 'PreviousStateDate')
	BEGIN
		ALTER TABLE [dbo].[TxnTransactionHistory] ADD [PreviousStateDate] DATETIME NULL
	END;

    IF NOT EXISTS (SELECT 1
						FROM INFORMATION_SCHEMA.COLUMNS
						WHERE TABLE_NAME = 'TxnTransactionHistory' AND COLUMN_NAME = 'FlowId')
	BEGIN
		ALTER TABLE [dbo].[TxnTransactionHistory] ADD FlowId BIGINT NOT NULL DEFAULT 0
	END;
    --#endregion

    --#region FLOW MIGRATION

    EXEC sp_executesql N'DISABLE TRIGGER [TxnTransactionTrigger] ON [TxnTransaction]';
    
    EXEC sp_executesql N'
                        UPDATE TxnTransaction SET CreatedBy = ''MIGRATION'' WHERE CreatedBy IS NULL;
                        UPDATE TxnTransaction SET CreatedDate = ''1900-01-01'' WHERE CreatedDate IS NULL;

                        UPDATE TxnTransactionHistory SET CreatedBy = ''MIGRATION'' WHERE CreatedBy IS NULL;
                        UPDATE TxnTransactionHistory SET CreatedDate = ''1900-01-01'' WHERE CreatedDate IS NULL;
                       ';

    EXEC sp_executesql N'ENABLE TRIGGER [TxnTransactionTrigger] ON [TxnTransaction]';

    ALTER TABLE TxnTransaction ALTER COLUMN CreatedBy NVARCHAR(80) NOT NULL;
    ALTER TABLE TxnTransaction ALTER COLUMN CreatedDate DATETIME NOT NULL;
    ALTER TABLE TxnTransactionHistory ALTER COLUMN CreatedBy NVARCHAR(80) NOT NULL;
    ALTER TABLE TxnTransactionHistory ALTER COLUMN CreatedDate DATETIME NOT NULL;

    --#endregion  

   
  --#region TXN CASH FLOW PAYMENT 

    --#region IsPaymentCompleted
    IF NOT EXISTS (SELECT 1
				FROM INFORMATION_SCHEMA.COLUMNS
				WHERE TABLE_NAME = 'TxnCashFlow' AND COLUMN_NAME = 'IsPaymentCompleted')
    BEGIN
        ALTER TABLE [dbo].[TxnCashFlow] ADD IsPaymentCompleted BIT NOT NULL DEFAULT 0
    END;


    IF NOT EXISTS (SELECT 1
                    FROM INFORMATION_SCHEMA.COLUMNS
                    WHERE TABLE_NAME = 'TxnCashFlowHistory' AND COLUMN_NAME = 'IsPaymentCompleted')
    BEGIN
        ALTER TABLE [dbo].[TxnCashFlowHistory] ADD IsPaymentCompleted BIT NOT NULL DEFAULT 0
    END;
    --#endregion

    --#region PaymentDirection
    IF NOT EXISTS (SELECT 1
				FROM INFORMATION_SCHEMA.COLUMNS
				WHERE TABLE_NAME = 'TxnCashFlow' AND COLUMN_NAME = 'PaymentDirection')
    BEGIN
        ALTER TABLE [dbo].[TxnCashFlow] ADD PaymentDirection NVARCHAR(10) NULL
    END;


    IF NOT EXISTS (SELECT 1
                    FROM INFORMATION_SCHEMA.COLUMNS
                    WHERE TABLE_NAME = 'TxnCashFlowHistory' AND COLUMN_NAME = 'PaymentDirection')
    BEGIN
        ALTER TABLE [dbo].[TxnCashFlowHistory] ADD PaymentDirection NVARCHAR(10) NULL
    END;
    --#endregion

    --#region PaymentDirection MIGRATION

    EXEC sp_executesql N'DISABLE TRIGGER [TxnCashFlowTrigger] ON [TxnCashFlow]';
    
    EXEC sp_executesql N'
                        WITH RankedCashFlows AS (
                            SELECT 
                                c.Id,
                                c.CashFlowLegType,
                                t.ProductTypeId,
                                ROW_NUMBER() OVER (
                                    PARTITION BY c.TxnId, c.CashFlowLegType 
                                    ORDER BY c.PaymentDate
                                ) AS rn
                            FROM TxnCashFlow c
                            INNER JOIN TxnTransaction t ON c.TxnId = t.Id
                        )
                        UPDATE c
                        SET PaymentDirection = 
                            CASE 
                                -- IRS (ProductTypeId = 1)
                                WHEN r.ProductTypeId = 1 AND r.CashFlowLegType = ''Receive'' THEN ''Incoming''
                                WHEN r.ProductTypeId = 1 AND r.CashFlowLegType = ''Pay''     THEN ''Outgoing''

                                -- CCS (ProductTypeId = 2)
                                WHEN r.ProductTypeId = 2 AND r.CashFlowLegType = ''Receive'' AND r.rn = 1 THEN ''Outgoing''
                                WHEN r.ProductTypeId = 2 AND r.CashFlowLegType = ''Receive'' AND r.rn > 1 THEN ''Incoming''

                                WHEN r.ProductTypeId = 2 AND r.CashFlowLegType = ''Pay''     AND r.rn = 1 THEN ''Incoming''
                                WHEN r.ProductTypeId = 2 AND r.CashFlowLegType = ''Pay''     AND r.rn > 1 THEN ''Outgoing''
                            END
                        FROM TxnCashFlow c
                        INNER JOIN RankedCashFlows r ON c.Id = r.Id
                        WHERE c.PaymentDirection IS NULL;
                       ';

    EXEC sp_executesql N'ENABLE TRIGGER [TxnCashFlowTrigger] ON [TxnCashFlow]';

    ALTER TABLE TxnCashFlow ALTER COLUMN PaymentDirection NVARCHAR(10) NOT NULL;

    --#endregion  
--#endregion 

--#region DefJobCron
IF NOT EXISTS (SELECT * FROM DefJobCron WHERE [Key] = N'DerivSwpCustomer')
BEGIN
    INSERT INTO dbo.DefJobCron ([Key], Value, StateId, StateMaker, StateDate)
    VALUES (N'DerivSwpCustomer', N'0 30 5 * * 1-5', 18, N'SYSTEM',  GETDATE());
END
--#endregion

--#region BatchItem
   IF NOT EXISTS (SELECT * FROM BatchItem WHERE ItemID = 'NetTrex.DerivSwp.Batch.Items.BeginOfDay.PeriodEndBatchItem')
    BEGIN
        DECLARE @BodBatchId int;
        SELECT @BodBatchId = Id FROM BatchItem WHERE NAME = 'Bod'
        IF @BodBatchId IS NULL
            throw 500001, 'BOD Batch item is not found', 1;

        DELETE FROM BatchItem WHERE ParentItemNo = @BodBatchId;

        INSERT INTO [dbo].BatchItem (Id,ItemOrder,ItemID,Name,Severity,State,ParentItemNo,BatchSetId,IsTransactional,StateId,StateMaker,StateDate) VALUES
            (13,1,N'NetTrex.DerivSwp.Batch.Items.BeginOfDay.CashFlowReGenerateBatchItem',N'CashFlow Regenerate',1,1,@BodBatchId,2,0,18,N'SYSTEM',GETDATE()),
            (14,2,N'NetTrex.DerivSwp.Batch.Items.BeginOfDay.ForwardBatchItem',N'Forward',1,1,@BodBatchId,2,0,18,N'SYSTEM',GETDATE()),
            (15,3,N'NetTrex.DerivSwp.Batch.Items.BeginOfDay.ReverseBatchItem',N'Reverse',1,1,@BodBatchId,2,0,18,N'SYSTEM',GETDATE()),
            (16,4,N'NetTrex.DerivSwp.Batch.Items.BeginOfDay.PeriodEndBatchItem',N'Period End',1,1,@BodBatchId,2,0,18,N'SYSTEM',GETDATE()),
            (17,5,N'NetTrex.DerivSwp.Batch.Items.BeginOfDay.MaturationBatchItem',N'Matured',1,1,@BodBatchId,2,0,18,N'SYSTEM',GETDATE()),
            (18,6,N'NetTrex.DerivSwp.Batch.Items.BeginOfDay.PaymentBatchItem',N'Payment',1,1,@BodBatchId,2,0,18,N'SYSTEM',GETDATE());
    END

    DECLARE @CustomerBachSetId int;

    IF NOT EXISTS (SELECT * FROM [BatchSet] WHERE Name = 'CUSTOMER')
    BEGIN
        DECLARE @lastBatchSetId int;
        SELECT @lastBatchSetId = ISNULL(MAX(Id), 0) FROM [BatchSet];

        SET @CustomerBachSetId = @lastBatchSetId + 1;
        INSERT INTO [dbo].[BatchSet] (Id,Name,Description,StateId,StateMaker,StateDate) 
            VALUES (@CustomerBachSetId, N'CUSTOMER', N'Derivative Swap CUSTOMER', 18, N'SYSTEM', GETDATE());
    END


    IF NOT EXISTS (SELECT * FROM BatchItem WHERE ItemID = N'Composite' and Name = N'DerivSWP Customer Payment' )
    BEGIN
        DECLARE @lastBatchId int;
        SELECT @lastBatchId = ISNULL(MAX(Id), 0) + 1 FROM [BatchItem];

        INSERT INTO [dbo].BatchItem (Id,ItemOrder,ItemID,Name,Severity,State,ParentItemNo,BatchSetId,IsTransactional,StateId,StateMaker,StateDate) VALUES
            (@lastBatchId, 1 ,N'Composite' ,N'DerivSWP Customer Payment', 0, 1, 0, @CustomerBachSetId, 0, 18, N'SYSTEM', GETDATE()),
            (@lastBatchId + 1, 1, N'NetTrex.DerivSwp.Batch.Items.Customer.CustomerPaymentIncomingBatchItem', N'Incoming Customer Payment', 1, 1, @lastBatchId, @CustomerBachSetId, 0, 18, N'SYSTEM', GETDATE()),
            (@lastBatchId + 2, 2, N'NetTrex.DerivSwp.Batch.Items.Customer.CustomerPaymentOutgoingBatchItem', N'Outgoing Customer Payment', 1, 1, @lastBatchId, @CustomerBachSetId, 0, 18, N'SYSTEM', GETDATE());
    END
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
