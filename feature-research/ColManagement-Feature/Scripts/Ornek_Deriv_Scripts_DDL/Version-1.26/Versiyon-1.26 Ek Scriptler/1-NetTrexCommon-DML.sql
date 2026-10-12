use NetTrexCommon
go
declare @stateMaker nvarchar(80) = 'SYSTEM',@stateDate datetime = getdate(),@stateId int = 18

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