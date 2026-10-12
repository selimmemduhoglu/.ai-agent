---Check Database Name
use NetTrexCommon
GO

--#region Framework Permission

exec sp_FrameworkAddPermissionAction 'DerivSwp_Displayer', 'Trex.WebUI', 'DerivSwp/GetSettlementTypes';
exec sp_FrameworkAddPermissionAction 'DerivSwp_Displayer', 'Trex.WebUI', 'DerivSwp/GetPaymentInstructionTypes';
exec sp_FrameworkAddPermissionAction 'DerivSwp_Displayer', 'Trex.WebUI', 'DerivSwp/GetFinancialInstitutionPaymentOption';
exec sp_FrameworkAddPermissionAction 'DerivSwp_Displayer', 'Trex.WebUI', 'DerivSwp/GetFinancialInstitutionOurCorrespondentBanks';
exec sp_FrameworkAddPermissionAction 'DerivSwp_Displayer', 'Trex.WebUI', 'DerivSwp/GetFinancialInstitutionTheirCorrespondentBanks';
exec sp_FrameworkAddPermissionAction 'DerivSwp_Displayer', 'Trex.WebUI', 'DerivSwp/GetPaymentInstructionTypes';
exec sp_FrameworkAddPermissionAction 'DerivSwp_Displayer', 'Trex.WebUI', 'DerivSwp/GetCashFlowHistoryDetail';

--#endregion

--#region Framework Parameter

DECLARE @stateMaker nvarchar(80) = 'SYSTEM',@stateDate datetime = GETDATE(), @stateId int = 18;

IF NOT EXISTS (SELECT 1
               FROM FrameworkParameter
               WHERE OptionPath = N'DV.ExternalService.Payments' AND OptionName = N'SendPayment')
BEGIN
    INSERT INTO FrameworkParameter (OptionPath, OptionName, ApplicationName, EnvironmentName, ServerName, Value,
                                    IsEncrypted, StateId, StateDate, StateMaker)
    VALUES (N'DV.ExternalService.Payments', N'SendPayment', N'', N'', N'', N'true', 0, @stateId, @stateDate, @stateMaker);
END;

IF NOT EXISTS (SELECT 1
               FROM FrameworkParameter
               WHERE OptionPath = N'DV.Payment.Validation' AND OptionName = N'Level')
BEGIN
    INSERT INTO FrameworkParameter (OptionPath, OptionName, ApplicationName, EnvironmentName, ServerName, Value,
                                    IsEncrypted, StateId, StateDate, StateMaker)
    VALUES (N'DV.Payment.Validation', N'Level', N'', N'', N'', N'0', 0, @stateId, @stateDate, @stateMaker);
END;

IF NOT EXISTS (SELECT 1
               FROM FrameworkParameter
               WHERE OptionPath = N'DV.Payment.Validation.Action' AND OptionName = N'Disabled')
BEGIN
    INSERT INTO FrameworkParameter (OptionPath, OptionName, ApplicationName, EnvironmentName, ServerName, Value,
                                    IsEncrypted, StateId, StateDate, StateMaker)
    VALUES (N'DV.Payment.Validation.Action', N'Disabled', N'', N'', N'', N'false', 0, @stateId, @stateDate, @stateMaker);
END;

IF NOT EXISTS (SELECT 1
               FROM FrameworkParameter
               WHERE OptionPath = N'Payment' AND OptionName = N'DV.OutgoingPaymentAccountingType')
BEGIN
    INSERT INTO FrameworkParameter (OptionPath, OptionName, ApplicationName, EnvironmentName, ServerName, Value,
                                    IsEncrypted, StateId, StateDate, StateMaker)
    VALUES (N'Payment', N'DV.OutgoingPaymentAccountingType', N'', N'', N'', N'TempAcc', 0, @stateId, @stateDate, @stateMaker);
END;

IF NOT EXISTS (SELECT 1
               FROM FrameworkParameter
               WHERE OptionPath = N'Payment' AND OptionName = N'DV.OutgoingPaymentAccountingGLType')
BEGIN
    INSERT INTO FrameworkParameter (OptionPath, OptionName, ApplicationName, EnvironmentName, ServerName, Value,
                                    IsEncrypted, StateId, StateDate, StateMaker)
    VALUES (N'Payment', N'DV.OutgoingPaymentAccountingGLType', N'', N'', N'', N'LedgerAcc', 0, @stateId, @stateDate, @stateMaker);
END;

IF NOT EXISTS (SELECT 1
               FROM FrameworkParameter
               WHERE OptionPath = N'Payment' AND OptionName = N'DV.IncomingPaymentAccountingType')
BEGIN
    INSERT INTO FrameworkParameter (OptionPath, OptionName, ApplicationName, EnvironmentName, ServerName, Value,
                                    IsEncrypted, StateId, StateDate, StateMaker)
    VALUES (N'Payment', N'DV.IncomingPaymentAccountingType', N'', N'', N'', N'TempAcc', 0, @stateId, @stateDate, @stateMaker);
END;

IF NOT EXISTS (SELECT 1
               FROM FrameworkParameter
               WHERE OptionPath = N'Payment' AND OptionName = N'DV.IncomingPaymentAccountingGLType')
BEGIN
    INSERT INTO FrameworkParameter (OptionPath, OptionName, ApplicationName, EnvironmentName, ServerName, Value,
                                    IsEncrypted, StateId, StateDate, StateMaker)
    VALUES (N'Payment', N'DV.IncomingPaymentAccountingGLType', N'', N'', N'', N'LedgerAcc', 0, @stateId, @stateDate, @stateMaker);
END;
--#endregion