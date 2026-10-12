--=============================================================================================
   --Valor-Vade Raporu (ValueMaturityReport) - Script 2 / PERMISSION
   --Common.UI ValueMaturityReportController action'lari: Index (ekran), Load (raporu getir -> MM / FX)
   --Excel export tarayicida uretiliyor, ayri action yok. Rapor salt-okunur -> yalniz Displayer.
---------------------------------------------------------------------------------------------

USE NetTrexCommon

GO

-- =============================================================================================
-- 1) ROL
-- =============================================================================================

EXEC sp_FrameworkAddPermission @PermissionName = 'ValueMaturityReport_Displayer', @ApplicationName = 'Trex.WebUI';

GO

-- =============================================================================================
-- 2) MATURITY REPORT
-- =============================================================================================

-- DISPLAYER
exec sp_FrameworkAddPermissionAction 'ValueMaturityReport_Displayer', 'Trex.WebUI', 'ValueMaturityReport/Index'
exec sp_FrameworkAddPermissionAction 'ValueMaturityReport_Displayer', 'Trex.WebUI', 'ValueMaturityReport/Load'

GO

-- Kontrol (1 rol, 2 action beklenir)
SELECT p.PermissionName, p.ApplicationName, a.ActionValue, a.IsAllowed
FROM dbo.FrameworkPermission p
LEFT JOIN dbo.FrameworkPermissionAction a
       ON a.PermissionName = p.PermissionName AND a.ApplicationName = p.ApplicationName
WHERE p.PermissionName = 'ValueMaturityReport_Displayer';
GO

-- Not: ValueMaturityReport_Displayer rolu ilgili profil(ler)e baglanmali (sp_FrameworkAddProfilePermission);
--      ardindan Redis'teki kullanici permission cache'i temizlenmeli.
