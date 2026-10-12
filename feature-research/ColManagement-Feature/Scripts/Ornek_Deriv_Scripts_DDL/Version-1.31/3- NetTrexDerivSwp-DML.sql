--Check Database Name
USE NetTrexDerivSWP
GO

BEGIN TRANSACTION;

BEGIN TRY

   --#region AMORTIZATION TYPE
   INSERT INTO [dbo].[AmortizationType] ([Name], [Code], [Description], [IsEnabled])
    VALUES
        (N'Linear', N'Linear', N'Simple Linear', 1);
   --#endregion

    --#region TXN CASHFLOW
    IF EXISTS (SELECT 1 FROM TxnCashFlow WHERE OrderNumber is null)
    BEGIN
        WITH OrderedFlows AS
        (
            SELECT 
                Id,
                TxnId,
                CashFlowLegType,
                PaymentDate,
                ROW_NUMBER() OVER (
                    PARTITION BY TxnId, CashFlowLegType
                    ORDER BY PaymentDate
                ) AS NewOrderNo
            FROM TxnCashFlow
        )
        UPDATE t
        SET t.OrderNumber = o.NewOrderNo
        FROM TxnCashFlow t
        JOIN OrderedFlows o ON t.Id = o.Id;
    END;

    ALTER TABLE [dbo].[TxnCashFlow] ALTER COLUMN [OrderNumber] INT NOT NULL;

    UPDATE th  
    SET OrderNumber = (SELECT TOP 1 sub.OrderNumber FROM TxnCashFlow sub WHERE sub.Id = th.Id)
    FROM TxnCashFlowHistory th

    --#endregion

   --#region BATCH ITEM
   DECLARE @BodBatchId INT, @LastBodBatchItemOrder INT, @LastBatchItemId INT;
   
   IF NOT EXISTS (SELECT * FROM BatchItem WHERE ItemID = 'NetTrex.DerivSwp.Batch.Items.BeginOfDay.AmortizationBatchItem')
    BEGIN
        SELECT @BodBatchId = Id FROM BatchItem WHERE NAME = 'Bod'
        IF @BodBatchId IS NULL
            throw 500001, 'BOD Batch item is not found', 1;

        SELECT TOP 1 @LastBodBatchItemOrder = ItemOrder + 1 FROM BatchItem WHERE ParentItemNo = @BodBatchId ORDER BY ItemOrder desc;
        SELECT TOP 1 @LastBatchItemId = Id + 1 FROM BatchItem ORDER BY Id desc;

        INSERT INTO [dbo].BatchItem (Id,ItemOrder,ItemID,Name,Severity,State,ParentItemNo,BatchSetId,IsTransactional,StateId,StateMaker,StateDate) VALUES
            (@LastBatchItemId,@LastBodBatchItemOrder,N'NetTrex.DerivSwp.Batch.Items.BeginOfDay.AmortizationBatchItem',N'Amortization',1,1,@BodBatchId,2,0,18,N'SYSTEM',GETDATE());
    END


   IF NOT EXISTS (SELECT * FROM BatchItem WHERE ItemID = 'NetTrex.DerivSwp.Batch.Items.BeginOfDay.FeeBatchItem')
    BEGIN
        SELECT @BodBatchId = Id FROM BatchItem WHERE NAME = 'Bod'
        IF @BodBatchId IS NULL
            throw 500001, 'BOD Batch item is not found', 1;

        SELECT TOP 1 @LastBodBatchItemOrder = ItemOrder + 1 FROM BatchItem WHERE ParentItemNo = @BodBatchId ORDER BY ItemOrder desc;
        SELECT TOP 1 @LastBatchItemId = Id + 1 FROM BatchItem ORDER BY Id desc;

        INSERT INTO [dbo].BatchItem (Id,ItemOrder,ItemID,Name,Severity,State,ParentItemNo,BatchSetId,IsTransactional,StateId,StateMaker,StateDate) VALUES
            (@LastBatchItemId,@LastBodBatchItemOrder,N'NetTrex.DerivSwp.Batch.Items.BeginOfDay.FeeBatchItem',N'Fee',1,1,@BodBatchId,2,0,18,N'SYSTEM',GETDATE());
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
