USE NetTrexCommon;
GO

/***************************************************************************************************
* This script is designed to add Deriv Product Definition Menu and Permission
***************************************************************************************************/

BEGIN TRANSACTION;

BEGIN TRY

--1.Define Deriv Product Definition Menu -------------------------------------------------------------------------------
DECLARE 
	@menuProductTypeId int = 0,
	@menuDerivReportId int = 0,
	@menuTreasuryId int = 0,
	@menuReportId int = 0;

DECLARE
	@stateId int=18,
    @stateDate datetime = getdate(),
    @stateMaker nvarchar(80) = N'SYSTEM';

SELECT @menuProductTypeId = Id FROM FrameworkMenu WHERE ApplicationName = N'Trex.WebUI' AND MenuKey = N'ProductTypesKey'

IF @menuProductTypeId = 0
  throw 500001, 'Product Type parent menu is not founded. Please check framework menu table', 1;

IF NOT EXISTS (SELECT 1 FROM FrameworkMenu WHERE ApplicationName = N'Trex.WebUI' AND MenuKey = N'DerivProductKey')
BEGIN
    INSERT INTO dbo.FrameworkMenu (ApplicationName,
                               Description,
                               MenuKey,
                               MenuType,
                               Value,
                               ForcedUrl,
                               ForcedPermission,
                               Icon,
                               IsActive,
                               ItemOrderId,
                               ParentId,
                               StateDate,
                               StateId,
                               StateMaker)
	VALUES (N'Trex.WebUI',
			N'Derivatives Product Definition',
			N'DerivProductKey',
			N'ControllerAction',
			N'DerivSwpProductDefinition/Index',
			null,
			null,
			N'fa-brands fa-product-hunt',
			1,
			12,
			@menuProductTypeId,
			@stateDate,
			@stateId,
			@stateMaker);
END

--2.Add Deriv Product Definition Permission -------------------------------------------------------------------------------
exec sp_FrameworkAddPermission 'DerivSwpProductDefinition_Checker', 'Trex.WebUI'
exec sp_FrameworkAddPermission 'DerivSwpProductDefinition_Displayer', 'Trex.WebUI'
exec sp_FrameworkAddPermission 'DerivSwpProductDefinition_Maker', 'Trex.WebUI'

--3.Add Deriv Product Definition Permission Actions -------------------------------------------------------------------------------
exec sp_FrameworkAddPermissionAction 'DerivSwpProductDefinition_Displayer', 'Trex.WebUI', 'DerivSwpProductDefinition/Index';
exec sp_FrameworkAddPermissionAction 'DerivSwpProductDefinition_Displayer', 'Trex.WebUI', 'DerivSwpProductDefinition/Load';
exec sp_FrameworkAddPermissionAction 'DerivSwpProductDefinition_Displayer', 'Trex.WebUI', 'DerivSwpProductDefinition/Get';
exec sp_FrameworkAddPermissionAction 'DerivSwpProductDefinition_Displayer', 'Trex.WebUI', 'DerivSwpProductDefinition/Form';
exec sp_FrameworkAddPermissionAction 'DerivSwpProductDefinition_Displayer', 'Trex.WebUI', 'DerivSwpProductDefinition/Preview';
exec sp_FrameworkAddPermissionAction 'DerivSwpProductDefinition_Maker', 'Trex.WebUI', 'DerivSwpProductDefinition/Create';
exec sp_FrameworkAddPermissionAction 'DerivSwpProductDefinition_Maker', 'Trex.WebUI', 'DerivSwpProductDefinition/Update';
exec sp_FrameworkAddPermissionAction 'DerivSwpProductDefinition_Maker', 'Trex.WebUI', 'DerivSwpProductDefinition/Delete';
exec sp_FrameworkAddPermissionAction 'DerivSwpProductDefinition_Maker', 'Trex.WebUI', 'DerivSwpProductDefinition/Copy';
exec sp_FrameworkAddPermissionAction 'DerivSwpProductDefinition_Checker', 'Trex.WebUI', 'DerivSwpProductDefinition/Verify';
exec sp_FrameworkAddPermissionAction 'DerivSwpProductDefinition_Checker', 'Trex.WebUI', 'DerivSwpProductDefinition/Reject';
exec sp_FrameworkAddPermissionAction 'DerivSwpProductDefinition_Maker', 'Trex.WebUI', 'DerivSwpProductDefinition/Undo';
exec sp_FrameworkAddPermissionAction 'DerivSwpProductDefinition_Displayer', 'Trex.WebUI', 'DerivSwpProductDefinition/History';
exec sp_FrameworkAddPermissionAction 'DerivSwpProductDefinition_Displayer', 'Trex.WebUI', 'DerivSwpProductDefinition/GetAccountingMapCodes';
exec sp_FrameworkAddPermissionAction 'DerivSwpProductDefinition_Displayer', 'Trex.WebUI', 'DerivSwpProductDefinition/GetPortfolios';

--4.Add Permissions To Admin Profile -------------------------------------------------------------------------------
DECLARE 
	@superAdminProfileId int = 0,
	@applicationName nvarchar(100) = 'Trex.WebUI';

SELECT @superAdminProfileId = ProfileId FROM [NetTrexCommon].[dbo].[FrameworkProfile] where ProfileName = 'Super Admin'

IF @superAdminProfileId > 0
BEGIN
	IF NOT EXISTS (SELECT 1
               FROM [FrameworkProfilePermission]
               WHERE [ProfileId] = @superAdminProfileId AND [PermissionName] = N'DerivSwpProductDefinition_Displayer' AND ApplicationName = @applicationName)
    BEGIN
		INSERT INTO [FrameworkProfilePermission]
				([ApplicationName], [ProfileId], [PermissionName], [StateId], [StateMaker], [StateDate])
		VALUES (@applicationName, @superAdminProfileId, N'DerivSwpProductDefinition_Displayer',@stateId, @stateMaker, @stateDate);		
		PRINT 'ProfilePermissionAction Inserted - Super Admin / DerivSwpProductDefinition_Displayer';
	END;

	IF NOT EXISTS (SELECT 1
               FROM [FrameworkProfilePermission]
               WHERE [ProfileId] = @superAdminProfileId AND [PermissionName] = N'DerivSwpProductDefinition_Maker' AND ApplicationName = @applicationName)
    BEGIN
		INSERT INTO [dbo].[FrameworkProfilePermission]
				([ApplicationName], [ProfileId], [PermissionName], [StateId], [StateMaker], [StateDate])
		VALUES (@applicationName, @superAdminProfileId, N'DerivSwpProductDefinition_Maker',@stateId, @stateMaker, @stateDate);
		PRINT 'ProfilePermissionAction Inserted - Super Admin / DerivSwpProductDefinition_Maker';
	END;

	IF NOT EXISTS (SELECT 1
               FROM [FrameworkProfilePermission]
               WHERE [ProfileId] = @superAdminProfileId AND [PermissionName] = N'DerivSwpProductDefinition_Checker' AND ApplicationName = @applicationName)
    BEGIN
		INSERT INTO [dbo].[FrameworkProfilePermission]
				([ApplicationName], [ProfileId], [PermissionName], [StateId], [StateMaker], [StateDate])
		VALUES (@applicationName, @superAdminProfileId, N'DerivSwpProductDefinition_Checker',@stateId, @stateMaker, @stateDate);
		PRINT 'ProfilePermissionAction Inserted - Super Admin / DerivSwpProductDefinition_Checker';
	END;
END;

COMMIT TRANSACTION;
PRINT 'Script completed successfully. All changes have been committed.';

END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    PRINT 'An error occurred during execution. All changes have been rolled back.';
    
    THROW;
END CATCH;
GO