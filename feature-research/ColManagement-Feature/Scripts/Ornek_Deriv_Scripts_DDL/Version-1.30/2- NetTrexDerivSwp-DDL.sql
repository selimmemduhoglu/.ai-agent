--Check Database Name
USE NetTrexDerivSWP
GO

BEGIN TRANSACTION;

BEGIN TRY

    --#region PORTFOLIO
    IF NOT EXISTS (SELECT 1
						FROM INFORMATION_SCHEMA.COLUMNS
						WHERE TABLE_NAME = 'PrfPortfolio' AND COLUMN_NAME = 'IsActive')
    BEGIN
        ALTER TABLE [dbo].[PrfPortfolio] ADD IsActive BIT NULL
    END;
    --#endregion

    --#region TXN TRANSITION
    IF NOT EXISTS (SELECT 1
						FROM INFORMATION_SCHEMA.COLUMNS
						WHERE TABLE_NAME = 'TxnTransaction' AND COLUMN_NAME = 'ParticipantCounterpartyId')
    BEGIN
        ALTER TABLE [dbo].[TxnTransaction] ADD [ParticipantCounterpartyId] INT NULL
    END;

    IF NOT EXISTS (SELECT 1
						FROM INFORMATION_SCHEMA.COLUMNS
						WHERE TABLE_NAME = 'TxnTransactionHistory' AND COLUMN_NAME = 'ParticipantCounterpartyId')
    BEGIN
        ALTER TABLE [dbo].[TxnTransactionHistory] ADD [ParticipantCounterpartyId] INT NULL
    END;
    --#endregion

    --#region TXN SYNC
     IF EXISTS (SELECT 1
			FROM INFORMATION_SCHEMA.COLUMNS
			WHERE TABLE_NAME = 'TxnSync' AND COLUMN_NAME = 'Trader')
	BEGIN
		ALTER TABLE [dbo].[TxnSync] ALTER COLUMN [Trader] NVARCHAR(80) NOT NULL
	END
    ELSE
    BEGIN
        ALTER TABLE [dbo].[TxnTransaction] ADD [Trader] NVARCHAR(80) NOT NULL
    END;
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
