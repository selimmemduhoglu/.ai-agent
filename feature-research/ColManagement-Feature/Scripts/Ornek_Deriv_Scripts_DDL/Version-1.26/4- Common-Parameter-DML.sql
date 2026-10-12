use NetTrexCommon
go
declare @stateMaker nvarchar(80) = 'SYSTEM',@stateDate datetime = GETDATE(), @stateId int = 18

IF NOT EXISTS (SELECT 1
               FROM FrameworkParameter
               WHERE OptionPath = N'Trex'
                 AND OptionName = N'DerivSwpLogicalDate')
    BEGIN
        INSERT INTO FrameworkParameter (OptionPath, OptionName, ApplicationName, EnvironmentName, ServerName, Value,
                                        IsEncrypted, StateId, StateDate, StateMaker)
        VALUES (N'Trex', N'DerivSwpLogicalDate', N'', N'', N'', FORMAT(@stateDate, 'dd.MM.yyyy'), 0, @stateId,
                @stateDate,
                @stateMaker);
    END;

IF NOT EXISTS (SELECT 1
               FROM FrameworkParameter
               WHERE OptionPath = N'DV.ExternalService.Sync'
                 AND OptionName = N'AccountingPush')
    BEGIN
        INSERT INTO FrameworkParameter (OptionPath, OptionName, ApplicationName, EnvironmentName, ServerName, Value,
                                        IsEncrypted, StateId, StateDate, StateMaker)
        VALUES (N'DV.ExternalService.Sync', N'AccountingPush', N'', N'', N'', N'false', 0, @stateId, @stateDate,
                @stateMaker);
    END;

IF NOT EXISTS (SELECT 1
               FROM FrameworkParameter
               WHERE OptionPath = N'DV.ExternalService.Sync'
                 AND OptionName = N'TransactionPush')
    BEGIN
        INSERT INTO FrameworkParameter (OptionPath, OptionName, ApplicationName, EnvironmentName, ServerName, Value,
                                        IsEncrypted, StateId, StateDate, StateMaker)
        VALUES (N'DV.ExternalService.Sync', N'TransactionPush', N'', N'', N'', N'false', 0, @stateId, @stateDate,
                @stateMaker);
    END;

IF NOT EXISTS (SELECT 1
               FROM FrameworkParameter
               WHERE OptionPath = N'DV.ExternalService'
                 AND OptionName = N'WorkGroupId')
    BEGIN
        INSERT INTO FrameworkParameter (OptionPath, OptionName, ApplicationName, EnvironmentName, ServerName, Value,
                                        IsEncrypted, StateId, StateDate, StateMaker)
        VALUES (N'DV.ExternalService', N'WorkGroupId', N'', N'', N'', N'2', 0, @stateId, @stateDate,
                @stateMaker);
    END;

IF NOT EXISTS (SELECT 1
               FROM FrameworkParameter
               WHERE OptionPath = N'DV.ExternalService.Accounting'
                 AND OptionName = N'Code')
    BEGIN
        INSERT INTO FrameworkParameter (OptionPath, OptionName, ApplicationName, EnvironmentName, ServerName, Value,
                                        IsEncrypted, StateId, StateDate, StateMaker)
        VALUES (N'DV.ExternalService.Accounting', N'Code', N'', N'', N'', N'ThirdPartyEntry', 0, @stateId, @stateDate,
                @stateMaker);
    END;

IF NOT EXISTS (SELECT 1
               FROM FrameworkParameter
               WHERE OptionPath = N'DV.ExternalService.Accounting'
                 AND OptionName = N'ProcessCode')
    BEGIN
        INSERT INTO FrameworkParameter (OptionPath, OptionName, ApplicationName, EnvironmentName, ServerName, Value,
                                        IsEncrypted, StateId, StateDate, StateMaker)
        VALUES (N'DV.ExternalService.Accounting', N'ProcessCode', N'', N'', N'', N'ThirdPartyTreasuryAccounting', 0, @stateId,
                @stateDate,
                @stateMaker);
    END;

IF NOT EXISTS (SELECT 1
               FROM FrameworkParameter
               WHERE OptionPath = N'DV.ExternalService.Accounting'
                 AND OptionName = N'Type')
    BEGIN
        INSERT INTO FrameworkParameter (OptionPath, OptionName, ApplicationName, EnvironmentName, ServerName, Value,
                                        IsEncrypted, StateId, StateDate, StateMaker)
        VALUES (N'DV.ExternalService.Accounting', N'Type', N'', N'', N'', N'Interbank', 0, @stateId, @stateDate,
                @stateMaker);
    END;

IF NOT EXISTS (SELECT 1
               FROM FrameworkParameter
               WHERE OptionPath = N'DV.ExternalService.Transaction'
                 AND OptionName = N'RowVersion')
    BEGIN
        INSERT INTO FrameworkParameter (OptionPath, OptionName, ApplicationName, EnvironmentName, ServerName, Value,
                                        IsEncrypted, StateId, StateDate, StateMaker)
        VALUES (N'DV.ExternalService.Transaction', N'RowVersion', N'', N'', N'', N'1', 0, @stateId, @stateDate,
                @stateMaker);
    END;

IF NOT EXISTS (SELECT 1
               FROM FrameworkParameter
               WHERE OptionPath = N'DV.ExternalService'
                 AND OptionName = N'MailPush')
    BEGIN
        INSERT INTO FrameworkParameter (OptionPath, OptionName, ApplicationName, EnvironmentName, ServerName, Value,
                                        IsEncrypted, StateId, StateDate, StateMaker)
        VALUES (N'DV.ExternalService', N'MailPush', N'', N'', N'', N'false', 0, @stateId, @stateDate,
                @stateMaker);
    END;

IF NOT EXISTS (SELECT 1
               FROM FrameworkParameter
               WHERE OptionPath = N'DV'
                 AND OptionName = N'ReverseType')
    BEGIN
        INSERT INTO FrameworkParameter (OptionPath, OptionName, ApplicationName, EnvironmentName, ServerName, Value,
                                        IsEncrypted, StateId, StateDate, StateMaker)
        VALUES (N'DV', N'ReverseType', N'', N'', N'', N'3', 0, @stateId, @stateDate,
                @stateMaker);
    END;

IF NOT EXISTS (SELECT 1
               FROM FrameworkParameter
               WHERE OptionPath = N'DV'
                 AND OptionName = N'SystemWDFlag')
    BEGIN
        INSERT INTO FrameworkParameter (OptionPath, OptionName, ApplicationName, EnvironmentName, ServerName, Value,
                                        IsEncrypted, StateId, StateDate, StateMaker)
        VALUES (N'DV', N'SystemWDFlag', N'', N'', N'', N'1', 0, @stateId, @stateDate,
                @stateMaker);
    END;

IF NOT EXISTS (SELECT 1
               FROM FrameworkParameter
               WHERE OptionPath = N'DV.FXRate'
                 AND OptionName = N'ChartId')
    BEGIN
        INSERT INTO FrameworkParameter (OptionPath, OptionName, ApplicationName, EnvironmentName, ServerName, Value,
                                        IsEncrypted, StateId, StateDate, StateMaker)
        VALUES (N'DV.FXRate', N'ChartId', N'', N'', N'', N'3', 0, @stateId, @stateDate,
                @stateMaker);
    END;

IF NOT EXISTS (SELECT 1
               FROM FrameworkParameter
               WHERE OptionPath = N'DV.FXRate'
                 AND OptionName = N'ChartABM')
    BEGIN
        INSERT INTO FrameworkParameter (OptionPath, OptionName, ApplicationName, EnvironmentName, ServerName, Value,
                                        IsEncrypted, StateId, StateDate, StateMaker)
        VALUES (N'DV.FXRate', N'ChartABM', N'', N'', N'', N'B', 0, @stateId, @stateDate,
                @stateMaker);
    END;

IF NOT EXISTS (SELECT 1
               FROM FrameworkParameter
               WHERE OptionPath = N'DV.DepoRate'
                 AND OptionName = N'IndexChartId')
    BEGIN
        DECLARE @oisZeroChartId int = 0;
        SELECT @oisZeroChartId = Id from dbo.Chart where Code = N'OISZero';
        INSERT INTO FrameworkParameter (OptionPath, OptionName, ApplicationName, EnvironmentName, ServerName, Value,
                                        IsEncrypted, StateId, StateDate, StateMaker)
        VALUES (N'DV.DepoRate', N'IndexChartId', N'', N'', N'', @oisZeroChartId, 0, @stateId, @stateDate, @stateMaker);
    END;

IF NOT EXISTS (SELECT 1
               FROM FrameworkParameter
               WHERE OptionPath = N'DV.DepoRate'
                 AND OptionName = N'FloatingChartId')
    BEGIN
        DECLARE @oisChartId int = 0;
        SELECT @oisChartId = Id from dbo.Chart where Code = N'OIS';
        INSERT INTO FrameworkParameter (OptionPath, OptionName, ApplicationName, EnvironmentName, ServerName, Value,
                                        IsEncrypted, StateId, StateDate, StateMaker)
        VALUES (N'DV.DepoRate', N'FloatingChartId', N'', N'', N'', @oisChartId, 0, @stateId, @stateDate,
                @stateMaker);
    END;

IF NOT EXISTS (SELECT 1
               FROM FrameworkParameter
               WHERE OptionPath = N'DV.DepoRate'
                 AND OptionName = N'IndexChartABM')
    BEGIN
        INSERT INTO FrameworkParameter (OptionPath, OptionName, ApplicationName, EnvironmentName, ServerName, Value,
                                        IsEncrypted, StateId, StateDate, StateMaker)
        VALUES (N'DV.DepoRate', N'IndexChartABM', N'', N'', N'', N'B', 0, @stateId, @stateDate,
                @stateMaker);
    END;

IF NOT EXISTS (SELECT 1
               FROM FrameworkParameter
               WHERE OptionPath = N'DV.DepoRate'
                 AND OptionName = N'FloatingChartABM')
    BEGIN
        INSERT INTO FrameworkParameter (OptionPath, OptionName, ApplicationName, EnvironmentName, ServerName, Value,
                                        IsEncrypted, StateId, StateDate, StateMaker)
        VALUES (N'DV.DepoRate', N'FloatingChartABM', N'', N'', N'', N'B', 0, @stateId, @stateDate,
                @stateMaker);
    END;

IF NOT EXISTS (SELECT 1
               FROM FrameworkParameter
               WHERE OptionPath = N'DV.FXRate'
                 AND OptionName = N'TaxChartId')
    BEGIN
        INSERT INTO FrameworkParameter (OptionPath, OptionName, ApplicationName, EnvironmentName, ServerName, Value,
                                        IsEncrypted, StateId, StateDate, StateMaker)
        VALUES (N'DV.FXRate', N'TaxChartId', N'', N'', N'', '3', 0, @stateId, @stateDate,
                @stateMaker);
    END;

IF NOT EXISTS (SELECT 1
               FROM FrameworkParameter
               WHERE OptionPath = N'DV.FXRate'
                 AND OptionName = N'TaxChartABM')
    BEGIN
        INSERT INTO FrameworkParameter (OptionPath, OptionName, ApplicationName, EnvironmentName, ServerName, Value,
                                        IsEncrypted, StateId, StateDate, StateMaker)
        VALUES (N'DV.FXRate', N'TaxChartABM', N'', N'', N'', 'B', 0, @stateId, @stateDate,
                @stateMaker);
    END;