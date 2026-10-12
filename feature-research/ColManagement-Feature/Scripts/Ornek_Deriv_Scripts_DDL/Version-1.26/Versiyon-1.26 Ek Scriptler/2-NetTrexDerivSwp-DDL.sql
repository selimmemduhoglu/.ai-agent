use [NetTrexDerivSWP]
GO
IF OBJECT_ID('tempdb..#sp_DropDefaultConstraint', 'P') IS NOT NULL
    DROP PROCEDURE #sp_DropDefaultConstraint;
GO
CREATE PROCEDURE #sp_DropDefaultConstraint @TableName NVARCHAR(128), @ColumnName NVARCHAR(128)
AS
BEGIN
    DECLARE @ConstraintName NVARCHAR(128);
    DECLARE @SQL NVARCHAR(4000);

    SELECT @ConstraintName = dc.name
    FROM sys.default_constraints dc
             INNER JOIN sys.columns c ON dc.parent_object_id = c.object_id AND dc.parent_column_id = c.column_id
    WHERE OBJECT_NAME(dc.parent_object_id) = @TableName COLLATE DATABASE_DEFAULT
      AND c.name = @ColumnName;

    IF @ConstraintName IS NOT NULL
        BEGIN
            SET
                @SQL = 'ALTER TABLE ' + QUOTENAME(@TableName) + ' DROP CONSTRAINT ' + QUOTENAME(@ConstraintName);
            EXEC sp_executesql @SQL;
        END;
END;
GO
SET XACT_ABORT ON;

BEGIN TRANSACTION;

BEGIN TRY

    IF NOT EXISTS (SELECT 1
                   FROM INFORMATION_SCHEMA.COLUMNS
                   WHERE TABLE_NAME = 'TxnCashFlowHistory'
                     AND COLUMN_NAME = 'LogicalReference')
        BEGIN
            ALTER TABLE [dbo].[TxnCashFlowHistory]
                ADD [LogicalReference] NVARCHAR(80) NOT NULL DEFAULT ('');
            exec #sp_DropDefaultConstraint 'TxnCashFlowHistory', 'LogicalReference';
        END;

    IF NOT EXISTS (SELECT 1
                   FROM INFORMATION_SCHEMA.COLUMNS
                   WHERE TABLE_NAME = 'TxnCashFlow'
                     AND COLUMN_NAME = 'LogicalReference')
        BEGIN
            ALTER TABLE [dbo].[TxnCashFlow]
                ADD [LogicalReference] NVARCHAR(80) NOT NULL DEFAULT ('');
            exec #sp_DropDefaultConstraint 'TxnCashFlow', 'LogicalReference';
        END;

    IF NOT EXISTS (SELECT 1
                   FROM INFORMATION_SCHEMA.COLUMNS
                   WHERE TABLE_NAME = 'TxnTransactionHistory'
                     AND COLUMN_NAME = 'ReceivePaymentDate')
        BEGIN
            ALTER TABLE [dbo].[TxnTransactionHistory]
                ADD [ReceivePaymentDate] DATE NOT NULL DEFAULT (CAST(GETDATE() AS DATE));
            exec #sp_DropDefaultConstraint 'TxnTransactionHistory', 'ReceivePaymentDate';
        END;

    IF NOT EXISTS (SELECT 1
                   FROM INFORMATION_SCHEMA.COLUMNS
                   WHERE TABLE_NAME = 'TxnTransactionHistory'
                     AND COLUMN_NAME = 'PayPaymentDate')
        BEGIN
            ALTER TABLE [dbo].[TxnTransactionHistory]
                ADD [PayPaymentDate] DATE NOT NULL DEFAULT (CAST(GETDATE() AS DATE));
            exec #sp_DropDefaultConstraint 'TxnTransactionHistory', 'PayPaymentDate';
        END;

    IF EXISTS (SELECT 1
               FROM INFORMATION_SCHEMA.COLUMNS
               WHERE TABLE_NAME = 'TxnTransactionHistory'
                 AND COLUMN_NAME = 'PaymentDate')
        BEGIN
            ALTER TABLE [dbo].[TxnTransactionHistory]
                DROP
                    COLUMN [PaymentDate];
        END;

    IF NOT EXISTS (SELECT 1
                   FROM INFORMATION_SCHEMA.COLUMNS
                   WHERE TABLE_NAME = 'TxnTransaction'
                     AND COLUMN_NAME = 'ReceivePaymentDate')
        BEGIN
            ALTER TABLE [dbo].[TxnTransaction]
                ADD [ReceivePaymentDate] DATE NOT NULL DEFAULT (CAST(GETDATE() AS DATE));
            exec #sp_DropDefaultConstraint 'TxnTransaction', 'ReceivePaymentDate';
        END;

    IF NOT EXISTS (SELECT 1
                   FROM INFORMATION_SCHEMA.COLUMNS
                   WHERE TABLE_NAME = 'TxnTransaction'
                     AND COLUMN_NAME = 'PayPaymentDate')
        BEGIN
            ALTER TABLE [dbo].[TxnTransaction]
                ADD [PayPaymentDate] DATE NOT NULL DEFAULT (CAST(GETDATE() AS DATE));
            exec #sp_DropDefaultConstraint 'TxnTransaction', 'PayPaymentDate';
        END;

    IF EXISTS (SELECT 1
               FROM INFORMATION_SCHEMA.COLUMNS
               WHERE TABLE_NAME = 'TxnTransaction'
                 AND COLUMN_NAME = 'PaymentDate')
        BEGIN
            ALTER TABLE [dbo].[TxnTransaction]
                DROP
                    COLUMN [PaymentDate];
        END;

    drop table dbo.TxnTax
    create table dbo.TxnTax
    (
        Id      int not null identity (1,1),
        TxnId   int not null,
        TaxId   int not null,
        TaxDate datetime,
        Amount  decimal(38, 10),
        TaxRate decimal(18, 10),
        Flags   int not null,
        Ccy     nvarchar(3),
        constraint PK_TxnTax primary key (Id)
    )
    IF NOT EXISTS (SELECT *
                   FROM sys.columns
                   WHERE object_id = OBJECT_ID('dbo.DerivativesRevaluation')
                     AND name = 'TotalMTMAmountSpotRate')
        BEGIN
            ALTER TABLE dbo.DerivativesRevaluation
                ADD TotalMTMAmountSpotRate decimal(18, 10) NULL;
        END;

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
    DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
    DECLARE @ErrorState INT = ERROR_STATE();
    DECLARE @ErrorLine INT = ERROR_LINE();

    RAISERROR ('Error on line %d: %s', @ErrorSeverity, @ErrorState, @ErrorLine, @ErrorMessage);
END CATCH