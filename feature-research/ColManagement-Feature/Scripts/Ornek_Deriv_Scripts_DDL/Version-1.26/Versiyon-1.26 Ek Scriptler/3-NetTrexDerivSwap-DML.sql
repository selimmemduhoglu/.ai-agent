---Check Database Name
Use NetTrexDerivSWP
GO
SET XACT_ABORT ON;

BEGIN TRANSACTION;

BEGIN TRY

    --#region CashFlow LogicalReference
    UPDATE cashflow
    SET cashflow.LogicalReference = txntransaction.LogicalReference
    FROM [dbo].[TxnCashFlow] cashflow
             INNER JOIN [dbo].[TxnTransaction] txntransaction ON cashflow.TxnId = txntransaction.Id;

    UPDATE history
    SET history.LogicalReference = cashFlow.LogicalReference
    FROM [dbo].TxnCashFlowHistory history
             INNER JOIN [dbo].TxnCashFlow cashFlow ON cashFlow.Id = history.Id;
    --#endregion

    --#region TxnTransaction Receive-Pay PaymentDate
    UPDATE TxnTransaction
    SET ReceivePaymentDate = DATEADD(DAY, ReceivePaymentLagDays, ReceiveMaturityDate),
        PayPaymentDate     = DATEADD(DAY, PayPaymentLagDays, PayMaturityDate);

    UPDATE TxnTransactionHistory
    SET ReceivePaymentDate = DATEADD(DAY, ReceivePaymentLagDays, ReceiveMaturityDate),
        PayPaymentDate     = DATEADD(DAY, PayPaymentLagDays, PayMaturityDate);

    --#endregion

    --#region CCS PRODUCT DEFINITION
    DECLARE @derivRootPortfolioPath nvarchar(250) = '',
        @derivPortfolioPath nvarchar(250) = '';

    SELECT @derivRootPortfolioPath = PortfolioRootPath, @derivPortfolioPath = PortfolioDefaultPath
    from dbo.ProductDefinition
    WHERE Code = N'IRS'

    IF NOT EXISTS (SELECT 1 FROM dbo.ProductDefinition WHERE Code = N'CCS')
        BEGIN
            INSERT INTO dbo.ProductDefinition (Id, Code, Name, ExternalMainProductCode, ExternalSubProductCode,
                                               AccountingMapCode, Description,
                                               IsAccountNeeded, IsSameCurrency, DoPrincipalAmountTransfer,
                                               HasPeriodPrincipalAmountTransferType, IsAllowRollover,
                                               IsAllowLiquidation,
                                               PortfolioRootPath, PortfolioDefaultPath, IsEnabled)
            VALUES (2, N'CCS', N'Cross Currency Rate Swap', N'DV', N'CCS', N'CCS', N'Cross Currency Rate Swap', 0, 0, 1,
                    1, 0, 0, @derivRootPortfolioPath, @derivPortfolioPath, 1);
        END
    --#endregion

    --#region Batch Item Update
    TRUNCATE TABLE BatchItem;
    INSERT INTO [dbo].BatchItem (Id, ItemOrder, ItemID, Name, Severity, State, ParentItemNo, BatchSetId,
                                 IsTransactional, StateId, StateMaker, StateDate)
    VALUES (1, 1, N'Composite', N'DerivSWP EndOfDay', 0, 1, 0, 1, 0, 18, N'SYSTEM', GETDATE()),
           (2, 1, N'Composite', N'Pre Eod', 0, 0, 1, 1, 0, 18, N'SYSTEM', GETDATE()),
           (3, 2, N'Composite', N'Eod', 1, 1, 1, 1, 0, 18, N'SYSTEM', GETDATE()),
           (4, 3, N'Composite', N'Post Eod', 0, 1, 1, 1, 0, 18, N'SYSTEM', GETDATE()),
           (5, 1, N'NetTrex.DerivSwp.Batch.Items.Common.DateTimeCheckBatchItem', N'Date Time Check', 0, 1, 2, 1, 0, 18,
            N'SYSTEM', GETDATE()),
           (6, 1, N'NetTrex.DerivSwp.Batch.Items.EndOfDay.LogicalDateUpdateBatchItem', N'Logical Date Update', 1, 1, 4,
            1, 0, 18, N'SYSTEM', GETDATE()),
           (7, 3, N'NetTrex.DerivSwp.Batch.Items.EndOfDay.RevaluationBatchItem', N'Revaluation', 1, 1, 3, 1, 0, 18,
            N'SYSTEM', GETDATE()),
           (8, 1, N'NetTrex.DerivSwp.Batch.Items.EndOfDay.ReverseBatchItem', N'Reverse', 1, 1, 3, 1, 0, 18, N'SYSTEM',
            GETDATE()),
           (9, 1, N'Composite', N'DerivSWP BeginOfDay', 0, 1, 0, 2, 0, 18, N'SYSTEM', GETDATE()),
           (10, 1, N'Composite', N'Pre Bod', 0, 1, 9, 2, 0, 18, N'SYSTEM', GETDATE()),
           (11, 2, N'Composite', N'Bod', 1, 1, 9, 2, 0, 18, N'SYSTEM', GETDATE()),
           (12, 1, N'NetTrex.DerivSwp.Batch.Items.Common.DateTimeCheckBatchItem', N'Date Time Check', 0, 1, 10, 2, 0,
            18, N'SYSTEM', GETDATE()),
           (13, 1, N'NetTrex.DerivSwp.Batch.Items.BeginOfDay.CashFlowReGenerateBatchItem', N'CashFlow Regenerate', 1, 1,
            11, 2, 0, 18, N'SYSTEM', GETDATE()),
           (14, 1, N'NetTrex.DerivSwp.Batch.Items.BeginOfDay.ForwardBatchItem', N'Forward', 1, 1, 11, 2, 0, 18,
            N'SYSTEM', GETDATE()),
           (15, 2, N'NetTrex.DerivSwp.Batch.Items.BeginOfDay.ReverseBatchItem', N'Reverse', 1, 1, 11, 2, 0, 18,
            N'SYSTEM', GETDATE()),
           (16, 3, N'NetTrex.DerivSwp.Batch.Items.BeginOfDay.PaymentBatchItem', N'Payment', 1, 1, 11, 2, 0, 18,
            N'SYSTEM', GETDATE()),
           (17, 4, N'NetTrex.DerivSwp.Batch.Items.BeginOfDay.MaturationBatchItem', N'Matured', 1, 1, 11, 2, 0, 18,
            N'SYSTEM', GETDATE());
    --#endregion

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