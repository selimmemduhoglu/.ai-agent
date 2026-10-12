---Check Database Name
use NetTrexCommon

Declare @menuDerivId int = 0,
@menuDerivReportId int = 0,
@menuTreasuryId int = 0,
@menuReportId int = 0;

SELECT @menuTreasuryId = Id FROM FrameworkMenu WHERE ApplicationName = N'Trex.WebUI' AND MenuKey = N'TreasuryKey'

IF @menuTreasuryId = 0
  throw 500001, 'Treasury parent menu is not founded. Please check framework menu table', 1;


SELECT @menuReportId = Id FROM FrameworkMenu WHERE ApplicationName = N'Trex.WebUI' AND MenuKey = N'ReportsKey'

IF @menuReportId = 0
  throw 500001, 'Report parent menu is not founded. Please check framework menu table', 1;

SELECT @menuTreasuryId = Id FROM FrameworkMenu WHERE ApplicationName = N'Trex.WebUI' AND MenuKey = N'TreasuryKey'

--#region Derivative Parent Menu
IF NOT EXISTS (SELECT 1
               FROM FrameworkMenu
               WHERE ApplicationName = N'Trex.WebUI'
                     AND MenuKey = N'DerivativesKey')
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
			N'Derivatives',
			N'DerivativesKey',
			N'None',
			null,
			null,
			null,
			N'fa-solid fa-right-left',
			1,
			25,
			@menuTreasuryId,
			GETDATE(),
			18,
			'SYSTEM');

	Set @menuDerivId = SCOPE_IDENTITY();
END
ELSE
BEGIN
    SELECT TOP 1 @menuDerivId = Id FROM FrameworkMenu WHERE ApplicationName = N'Trex.WebUI' AND MenuKey = N'DerivativesKey'
END;
--#endregion

--#region IRS-CCS Sub Menu
IF NOT EXISTS (SELECT 1
               FROM FrameworkMenu
               WHERE ApplicationName = N'Trex.WebUI'
                     AND MenuKey = N'IRSAndCIRSKey')
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
			N'IRS & CCS',
			N'IRSAndCIRSKey',
			N'ControllerAction',
			N'DerivSwp/Index',
			null,
			null,
			N'fa-solid fa-right-left',
			1,
			5,
			@menuDerivId,
			GETDATE(),
			18,
			'SYSTEM');
END;
--#endregion

--#region Menu DerivativeReports
IF NOT EXISTS (SELECT 1
               FROM FrameworkMenu
               WHERE ApplicationName = N'Trex.WebUI'
                     AND MenuKey = N'DerivativeReportsKey')
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
			N'Derivatives',
			N'DerivativeReportsKey',
			N'None',
			null,
			null,
			null,
			N'fa-regular fa-rectangle-list',
			1,
			17,
			@menuReportId,
			GETDATE(),
			18,
			'SYSTEM');

	Set @menuDerivReportId = SCOPE_IDENTITY();
END
ELSE
BEGIN
    SELECT TOP 1 @menuDerivReportId = Id FROM FrameworkMenu WHERE ApplicationName = N'Trex.WebUI' AND MenuKey = N'DerivativeReportsKey'
END;

---#region Menu DerivativeSwapReport
IF NOT EXISTS (SELECT 1
               FROM FrameworkMenu
               WHERE ApplicationName = N'Trex.WebUI'
                     AND MenuKey = N'DerivativeSwapReportKey')
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
        N'IRS & CCS Revaluation',
        N'DerivativeSwapReportKey',
        N'ControllerAction',
        N'DerivSwpRevaluationReport/Index',
        null,
        null,
        N'fa-solid fa-chart-area',
        1,
        5,
        @menuDerivReportId,
        GETDATE(),
        18,
        'SYSTEM');
END;
--#endregion