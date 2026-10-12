use [NetTrexAcc]
GO
SET XACT_ABORT ON;

begin transaction;

begin try

    declare @stateMaker nvarchar(80) = 'SYSTEM',
        @stateDate datetime = getdate(),
        @stateId int = 26;

    delete from dbo.AccAccountMap where Path = 'TREX/DV/IRS';
    delete from dbo.AccAccountMap where Path = 'TREX/DV/CCS';

    delete
    from dbo.AccEngineAccountRule
    where ComponentId in (select co.Id
                          from dbo.AccEngineComponent co
                                   inner join dbo.AccEngineGroup gr on co.GroupId = gr.Id
                                   inner join dbo.AccEngineEvent ev on ev.Id = gr.EventId
                                   inner join dbo.AccEngineItem it on it.Id = ev.ItemId
                          where it.Path in ('TREX/DV/IRS/LCYRLCYP/', 'TREX/DV/IRS/FCYRFCYP/'))
    delete
    from dbo.AccEngineComponent
    where GroupId in (select gr.Id
                      from dbo.AccEngineGroup gr
                               inner join dbo.AccEngineEvent ev on ev.Id = gr.EventId
                               inner join dbo.AccEngineItem it on it.Id = ev.ItemId
                      where it.Path in ('TREX/DV/IRS/LCYRLCYP/', 'TREX/DV/IRS/FCYRFCYP/'))
    delete
    from dbo.AccEngineGroup
    where EventId in (select ev.Id
                      from dbo.AccEngineEvent ev
                               inner join dbo.AccEngineItem it on it.Id = ev.ItemId
                      where it.Path in ('TREX/DV/IRS/LCYRLCYP/', 'TREX/DV/IRS/FCYRFCYP/'))

    delete
    from dbo.AccEngineAccountRule
    where ComponentId in (select co.Id
                          from dbo.AccEngineComponent co
                                   inner join dbo.AccEngineGroup gr on co.GroupId = gr.Id
                                   inner join dbo.AccEngineEvent ev on ev.Id = gr.EventId
                                   inner join dbo.AccEngineItem it on it.Id = ev.ItemId
                          where it.Path in ('TREX/DV/CCS/FCYRLCYP/', 'TREX/DV/CCS/LCYRFCYP/', 'TREX/DV/CCS/FCYRFCYP/'))

    delete
    from dbo.AccEngineComponent
    where GroupId in (select gr.Id
                      from dbo.AccEngineGroup gr
                               inner join dbo.AccEngineEvent ev on ev.Id = gr.EventId
                               inner join dbo.AccEngineItem it on it.Id = ev.ItemId
                      where it.Path in ('TREX/DV/CCS/FCYRLCYP/', 'TREX/DV/CCS/LCYRFCYP/', 'TREX/DV/CCS/FCYRFCYP/'))


    delete
    from dbo.AccEngineGroup
    where EventId in (select ev.Id
                      from dbo.AccEngineEvent ev
                               inner join dbo.AccEngineItem it on it.Id = ev.ItemId
                      where it.Path in ('TREX/DV/CCS/FCYRLCYP/', 'TREX/DV/CCS/LCYRFCYP/', 'TREX/DV/CCS/FCYRFCYP/'))

--#region IRS
    update dbo.AccEngineDynamicRule
    set [Rule]=N'((TxnModel.ReceivePeriodEndDate !== null ? TxnModel.ReceivePeriodEndDate.getTime() === TxnModel.LogicalDate.getTime() : false) || (TxnModel.PayPeriodEndDate !== null ? TxnModel.PayPeriodEndDate.getTime() === TxnModel.LogicalDate.getTime() : false)) && TxnModel.NetPeriodEndAmount < 0',
        StateId=@stateId,
        StateMaker=@stateMaker,
        StateDate=@stateDate
    where [Rule] =
          N'TxnModel.ReceivePaymentDate.getTime() === TxnModel.LogicalDate.getTime() || TxnModel.PayPaymentDate.getTime() === TxnModel.LogicalDate.getTime()) && TxnModel.NetPeriodEndAmount < 0'

    update dbo.AccEngineDynamicRule
    set [Rule]=N'((TxnModel.ReceivePeriodEndDate !== null ? TxnModel.ReceivePeriodEndDate.getTime() === TxnModel.LogicalDate.getTime() : false) || (TxnModel.PayPeriodEndDate !== null ? TxnModel.PayPeriodEndDate.getTime() === TxnModel.LogicalDate.getTime() : false)) && TxnModel.NetPeriodEndAmount > 0',
        StateId=@stateId,
        StateMaker=@stateMaker,
        StateDate=@stateDate
    where [Rule] =
          N'TxnModel.ReceivePaymentDate.getTime() === TxnModel.LogicalDate.getTime() || TxnModel.PayPaymentDate.getTime() === TxnModel.LogicalDate.getTime()) && TxnModel.NetPeriodEndAmount > 0'

    update dbo.AccEngineDynamicRule
    set Name       = N'PeriodEndDate = LogicalDate && NetPayment < 0',
        StateId    = @stateId,
        StateMaker = @stateMaker,
        StateDate  = @stateDate
    where Name = N'PaymentDate = LogicalDate && NetPayment < 0'

    update dbo.AccEngineDynamicRule
    set Name       = N'PeriodEndDate = LogicalDate && NetPayment > 0',
        StateId    = @stateId,
        StateMaker = @stateMaker,
        StateDate  = @stateDate
    where Name = N'PaymentDate = LogicalDate && NetPayment > 0'
--#endregion


    commit transaction;
end try
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
    DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
    DECLARE @ErrorState INT = ERROR_STATE();
    DECLARE @ErrorLine INT = ERROR_LINE();

    RAISERROR ('Error on line %d: %s', @ErrorSeverity, @ErrorState, @ErrorLine, @ErrorMessage);
END CATCH