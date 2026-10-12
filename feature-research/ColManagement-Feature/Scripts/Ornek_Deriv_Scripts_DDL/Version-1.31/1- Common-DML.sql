---Check Database Name
use NetTrexCommon
GO

--#region Framework Permission

exec sp_FrameworkAddPermissionAction 'DerivSwp_Displayer', 'Trex.WebUI', 'DerivSwp/GetAmortizationTypes';

--#endregion