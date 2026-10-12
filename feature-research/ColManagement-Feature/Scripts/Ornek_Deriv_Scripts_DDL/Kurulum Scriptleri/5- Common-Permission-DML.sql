---Check Database Name
Use NetTrexCommon

---FRAMEWORK PERMISSION
--Transaction
exec sp_FrameworkAddPermission 'DerivSwp_Checker', 'Trex.WebUI'
exec sp_FrameworkAddPermission 'DerivSwp_Displayer', 'Trex.WebUI'
exec sp_FrameworkAddPermission 'DerivSwp_Maker', 'Trex.WebUI'
--Revaluation Report
exec sp_FrameworkAddPermission 'DerivSwpRevaluationReport_Displayer', 'Trex.WebUI'

--FRAMEWORK PERMISSION ACTION
exec sp_FrameworkAddPermissionAction 'DerivSwp_Checker', 'Trex.WebUI', 'DerivSwp/Reject';
exec sp_FrameworkAddPermissionAction 'DerivSwp_Checker', 'Trex.WebUI', 'DerivSwp/Verify';
exec sp_FrameworkAddPermissionAction 'DerivSwp_Displayer', 'Trex.WebUI', 'DerivSwp/CalculateCashFlow';
exec sp_FrameworkAddPermissionAction 'DerivSwp_Displayer', 'Trex.WebUI', 'DerivSwp/CheckWorkingDay';
exec sp_FrameworkAddPermissionAction 'DerivSwp_Displayer', 'Trex.WebUI', 'DerivSwp/CopyInsertLoad';
exec sp_FrameworkAddPermissionAction 'DerivSwp_Displayer', 'Trex.WebUI', 'DerivSwp/CorrespondentBank';
exec sp_FrameworkAddPermissionAction 'DerivSwp_Displayer', 'Trex.WebUI', 'DerivSwp/CustomerFkeyList';
exec sp_FrameworkAddPermissionAction 'DerivSwp_Displayer', 'Trex.WebUI', 'DerivSwp/GenerateCashFlow';
exec sp_FrameworkAddPermissionAction 'DerivSwp_Displayer', 'Trex.WebUI', 'DerivSwp/Get';
exec sp_FrameworkAddPermissionAction 'DerivSwp_Displayer', 'Trex.WebUI', 'DerivSwp/GetWorkingDay';
exec sp_FrameworkAddPermissionAction 'DerivSwp_Displayer', 'Trex.WebUI', 'DerivSwp/CheckWorkingDay';
exec sp_FrameworkAddPermissionAction 'DerivSwp_Displayer', 'Trex.WebUI', 'DerivSwp/History';
exec sp_FrameworkAddPermissionAction 'DerivSwp_Displayer', 'Trex.WebUI', 'DerivSwp/HistoryDetail';
exec sp_FrameworkAddPermissionAction 'DerivSwp_Displayer', 'Trex.WebUI', 'DerivSwp/Index';
exec sp_FrameworkAddPermissionAction 'DerivSwp_Displayer', 'Trex.WebUI', 'DerivSwp/Load';
exec sp_FrameworkAddPermissionAction 'DerivSwp_Displayer', 'Trex.WebUI', 'DerivSwp/ReGenerateCashFlow';
exec sp_FrameworkAddPermissionAction 'DerivSwp_Displayer', 'Trex.WebUI', 'DerivSwp/SelectChart';
exec sp_FrameworkAddPermissionAction 'DerivSwp_Displayer', 'Trex.WebUI', 'DerivSwp/SelectCurrency';
exec sp_FrameworkAddPermissionAction 'DerivSwp_Displayer', 'Trex.WebUI', 'DerivSwp/SelectCurrencyPair';
exec sp_FrameworkAddPermissionAction 'DerivSwp_Displayer', 'Trex.WebUI', 'DerivSwp/SelectCustomer';
exec sp_FrameworkAddPermissionAction 'DerivSwp_Displayer', 'Trex.WebUI', 'DerivSwp/SelectDateBasis';
exec sp_FrameworkAddPermissionAction 'DerivSwp_Displayer', 'Trex.WebUI', 'DerivSwp/SelectFloatingRateType';
exec sp_FrameworkAddPermissionAction 'DerivSwp_Displayer', 'Trex.WebUI', 'DerivSwp/SelectFlowType';
exec sp_FrameworkAddPermissionAction 'DerivSwp_Displayer', 'Trex.WebUI', 'DerivSwp/SelectInterestMethod';
exec sp_FrameworkAddPermissionAction 'DerivSwp_Displayer', 'Trex.WebUI', 'DerivSwp/SelectInterestMethodFraq';
exec sp_FrameworkAddPermissionAction 'DerivSwp_Displayer', 'Trex.WebUI', 'DerivSwp/SelectLiquidationType';
exec sp_FrameworkAddPermissionAction 'DerivSwp_Displayer', 'Trex.WebUI', 'DerivSwp/SelectPaymentFreq';
exec sp_FrameworkAddPermissionAction 'DerivSwp_Displayer', 'Trex.WebUI', 'DerivSwp/SelectPortfolio';
exec sp_FrameworkAddPermissionAction 'DerivSwp_Displayer', 'Trex.WebUI', 'DerivSwp/SelectProductType';
exec sp_FrameworkAddPermissionAction 'DerivSwp_Displayer', 'Trex.WebUI', 'DerivSwp/SelectRateAdjustmented';
exec sp_FrameworkAddPermissionAction 'DerivSwp_Displayer', 'Trex.WebUI', 'DerivSwp/SelectRateType';
exec sp_FrameworkAddPermissionAction 'DerivSwp_Maker', 'Trex.WebUI', 'DerivSwp/CalculateCashFlow';
exec sp_FrameworkAddPermissionAction 'DerivSwp_Maker', 'Trex.WebUI', 'DerivSwp/CalculateCashFlowAmount';
exec sp_FrameworkAddPermissionAction 'DerivSwp_Maker', 'Trex.WebUI', 'DerivSwp/CopyInsertLoad';
exec sp_FrameworkAddPermissionAction 'DerivSwp_Maker', 'Trex.WebUI', 'DerivSwp/Create';
exec sp_FrameworkAddPermissionAction 'DerivSwp_Maker', 'Trex.WebUI', 'DerivSwp/Delete';
exec sp_FrameworkAddPermissionAction 'DerivSwp_Maker', 'Trex.WebUI', 'DerivSwp/GenerateCashFlow';
exec sp_FrameworkAddPermissionAction 'DerivSwp_Maker', 'Trex.WebUI', 'DerivSwp/GetCompoundCashFlow';
exec sp_FrameworkAddPermissionAction 'DerivSwp_Maker', 'Trex.WebUI', 'DerivSwp/Insert';
exec sp_FrameworkAddPermissionAction 'DerivSwp_Maker', 'Trex.WebUI', 'DerivSwp/LoadCreate';
exec sp_FrameworkAddPermissionAction 'DerivSwp_Maker', 'Trex.WebUI', 'DerivSwp/ReGenerateCashFlow';
exec sp_FrameworkAddPermissionAction 'DerivSwp_Maker', 'Trex.WebUI', 'DerivSwp/Undo';
exec sp_FrameworkAddPermissionAction 'DerivSwp_Maker', 'Trex.WebUI', 'DerivSwp/Update';
exec sp_FrameworkAddPermissionAction 'DerivSwp_Maker', 'Trex.WebUI', 'DerivSwp/UpdateLoad';
exec sp_FrameworkAddPermissionAction 'DerivSwp_Displayer', 'Trex.WebUI', 'DerivSwp/Accounting';
exec sp_FrameworkAddPermissionAction 'DerivSwp_Displayer', 'Trex.WebUI', 'DerivSwp/AccountingReport';
exec sp_FrameworkAddPermissionAction 'DerivSwp_Displayer', 'Trex.WebUI', 'DerivSwp/Valuation';
exec sp_FrameworkAddPermissionAction 'DerivSwp_Maker', 'Trex.WebUI', 'DerivSwp/CalculateNetCashFlow';
exec sp_FrameworkAddPermissionAction 'DerivSwp_Displayer', 'Trex.WebUI', 'DerivSwp/CalculateNetCashFlow';
exec sp_FrameworkAddPermissionAction 'DerivSwp_Displayer', 'Trex.WebUI','DerivSwp/SelectCustomerAccounts';
exec sp_FrameworkAddPermissionAction 'DerivSwp_Displayer', 'Trex.WebUI', 'DerivSwp/GetCompoundCashFlow';
exec sp_FrameworkAddPermissionAction 'DerivSwp_Checker', 'Trex.WebUI', 'DerivSwp/GetCompoundCashFlow';

--RevaluationReport
exec sp_FrameworkAddPermissionAction 'DerivSwpRevaluationReport_Displayer', 'Trex.WebUI', 'DerivSwpRevaluationReport/Load';
exec sp_FrameworkAddPermissionAction 'DerivSwpRevaluationReport_Displayer', 'Trex.WebUI', 'DerivSwpRevaluationReport/Index';


--Permission Profile
--Super admin profiline ekleme

DECLARE @superAdminProfileId int = 0,
@applicationName nvarchar(100) = 'Trex.WebUI';

SELECT @superAdminProfileId = ProfileId FROM [NetTrexCommon].[dbo].[FrameworkProfile] where ProfileName = 'Super Admin'

IF @superAdminProfileId > 0
BEGIN
	IF NOT EXISTS (SELECT 1
               FROM [FrameworkProfilePermission]
               WHERE [ProfileId] = @superAdminProfileId AND [PermissionName] = N'DerivSwp_Displayer' AND ApplicationName = @applicationName)
    BEGIN
		INSERT INTO [FrameworkProfilePermission]
				([ApplicationName], [ProfileId], [PermissionName], [StateId], [StateMaker], [StateDate])
		VALUES (@applicationName, @superAdminProfileId, N'DerivSwp_Displayer',18, N'System', GETDATE());		
		PRINT 'ProfilePermissionAction Inserted - Super Admin / DerivSwp_Displayer';
	END;

	IF NOT EXISTS (SELECT 1
               FROM [FrameworkProfilePermission]
               WHERE [ProfileId] = @superAdminProfileId AND [PermissionName] = N'DerivSwp_Maker' AND ApplicationName = @applicationName)
    BEGIN
		INSERT INTO [dbo].[FrameworkProfilePermission]
				([ApplicationName], [ProfileId], [PermissionName], [StateId], [StateMaker], [StateDate])
		VALUES (@applicationName, @superAdminProfileId, N'DerivSwp_Maker',18, N'System', GETDATE());
		PRINT 'ProfilePermissionAction Inserted - Super Admin / DerivSwp_Maker';
	END;

	IF NOT EXISTS (SELECT 1
               FROM [FrameworkProfilePermission]
               WHERE [ProfileId] = @superAdminProfileId AND [PermissionName] = N'DerivSwp_Checker' AND ApplicationName = @applicationName)
    BEGIN
		INSERT INTO [dbo].[FrameworkProfilePermission]
				([ApplicationName], [ProfileId], [PermissionName], [StateId], [StateMaker], [StateDate])
		VALUES (@applicationName, @superAdminProfileId, N'DerivSwp_Checker',18, N'System', GETDATE());
		PRINT 'ProfilePermissionAction Inserted - Super Admin / DerivSwp_Checker';
	END;
END;