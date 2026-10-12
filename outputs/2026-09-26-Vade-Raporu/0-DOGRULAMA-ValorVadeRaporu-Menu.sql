/* ==================================================================================================
   0 - NetTrexCommon  --  DOGRULAMA (SALT-OKUNUR, MIGRATION DEGIL)
   --------------------------------------------------------------------------------------------------
   Valor-Vade Raporu (ValueMaturityReport) menu / permission script'lerinden ONCE ve SONRA kosulabilir. Hicbir sey yazmaz.
   Yerlesim 2026-10-01'de canli FrameworkMenu'den secildi (sql-log/swap-mm-rapor #20-#22):
     Reports (ReportsKey) > Valor-Vade Raporu, ItemOrderId 31 (Upcoming Transactions 30 ile Tax 35 arasi).
   ================================================================================================== */

USE NetTrexCommon
GO

-- DOGRULAMA 1: Parent var mi (1 satir beklenir)
SELECT Id, ApplicationName, MenuKey, Description, ModuleName, ItemOrderId, IsActive
FROM dbo.FrameworkMenu
WHERE MenuKey = 'ReportsKey';

-- DOGRULAMA 2: Reports altindaki kardesler ve siralari (31 bos mu)
SELECT TOP (50) m.Id, m.MenuKey, m.Description, m.MenuType, m.Value, m.ItemOrderId, m.ModuleName
FROM dbo.FrameworkMenu m
JOIN dbo.FrameworkMenu p ON p.Id = m.ParentId
WHERE p.MenuKey = 'ReportsKey'
ORDER BY m.ItemOrderId;

-- DOGRULAMA 3: Valor-Vade Raporu menu satiri (script oncesi 0, sonrasi 1 satir)
SELECT Id, ApplicationName, MenuKey, Description, Value, ParentId, ItemOrderId, ModuleName, IsActive
FROM dbo.FrameworkMenu
WHERE MenuKey = 'ValueMaturityReportKey' OR Value = 'ValueMaturityReport/Index';

-- DOGRULAMA 4: Permission (script oncesi 0, sonrasi 1 rol + 2 action)
SELECT p.PermissionName, p.ApplicationName, a.ActionValue, a.IsAllowed
FROM dbo.FrameworkPermission p
LEFT JOIN dbo.FrameworkPermissionAction a
       ON a.PermissionName = p.PermissionName AND a.ApplicationName = p.ApplicationName
WHERE p.PermissionName = 'ValueMaturityReport_Displayer';
GO
