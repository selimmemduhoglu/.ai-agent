use NetTrexCommon
go
declare @stateMaker nvarchar(80) = 'SYSTEM',@stateDate datetime = GETDATE(), @stateId int = 18

IF NOT EXISTS (SELECT 1
               FROM FrameworkParameter
               WHERE OptionPath = N'DV.Takasbank'
                 AND OptionName = N'CustomerId')
    BEGIN
        INSERT INTO FrameworkParameter (OptionPath, OptionName, ApplicationName, EnvironmentName, ServerName, Value,
                                        IsEncrypted, StateId, StateDate, StateMaker)
        VALUES (N'DV.Takasbank', N'CustomerId', N'', N'', N'', N'2097', 0, @stateId, @stateDate, @stateMaker);
    END;


UPDATE FrameworkParameter SET Value = 'true' where OptionPath = N'DV.ExternalService' AND OptionName = N'MailPush';