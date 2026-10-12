USE NetTrexCommon
GO

-- =============================================================================================
-- 1) TEMEL ROLLER
-- =============================================================================================

EXEC sp_FrameworkAddPermission @PermissionName = 'TreasuryReeskont_Displayer',   @ApplicationName = 'Trex.WebUI';
EXEC sp_FrameworkAddPermission @PermissionName = 'TreasuryReeskont_Maker',       @ApplicationName = 'Trex.WebUI';
EXEC sp_FrameworkAddPermission @PermissionName = 'TreasuryReeskont_Checker',     @ApplicationName = 'Trex.WebUI';


EXEC sp_FrameworkAddPermission @PermissionName = 'InvestmentReeskont_Displayer', @ApplicationName = 'Trex.WebUI';
EXEC sp_FrameworkAddPermission @PermissionName = 'InvestmentReeskont_Maker',     @ApplicationName = 'Trex.WebUI';
EXEC sp_FrameworkAddPermission @PermissionName = 'InvestmentReeskont_Checker',   @ApplicationName = 'Trex.WebUI';


EXEC sp_FrameworkAddPermission @PermissionName = 'SecurityReeskont_Displayer',   @ApplicationName = 'Trex.WebUI';
EXEC sp_FrameworkAddPermission @PermissionName = 'SecurityReeskont_Maker',       @ApplicationName = 'Trex.WebUI';
EXEC sp_FrameworkAddPermission @PermissionName = 'SecurityReeskont_Checker',     @ApplicationName = 'Trex.WebUI';


GO

-- =============================================================================================
-- 2) TREASURY
-- =============================================================================================

-- DISPLAYER
exec sp_FrameworkAddPermissionAction 'TreasuryReeskont_Displayer', 'Trex.WebUI', 'TreasuryRediscount/Index'
exec sp_FrameworkAddPermissionAction 'TreasuryReeskont_Displayer', 'Trex.WebUI', 'TreasuryRediscount/Load'

-- MAKER
-- 🔴 Execute = muhasebe fisi. Yalniz Maker.
exec sp_FrameworkAddPermissionAction 'TreasuryReeskont_Maker', 'Trex.WebUI', 'TreasuryRediscount/Execute'
exec sp_FrameworkAddPermissionAction 'TreasuryReeskont_Checker', 'Trex.WebUI', 'TreasuryRediscount/Execute'



GO

-- =============================================================================================
-- 3) INVESTMENT
-- =============================================================================================

-- DISPLAYER
exec sp_FrameworkAddPermissionAction 'InvestmentReeskont_Displayer', 'Trex.WebUI', 'InvestmentRediscount/Index'
exec sp_FrameworkAddPermissionAction 'InvestmentReeskont_Displayer', 'Trex.WebUI', 'InvestmentRediscount/Load'

-- MAKER
exec sp_FrameworkAddPermissionAction 'InvestmentReeskont_Maker', 'Trex.WebUI', 'InvestmentRediscount/Execute'
exec sp_FrameworkAddPermissionAction 'InvestmentReeskont_Checker', 'Trex.WebUI', 'TreasuryRediscount/Execute'


GO

-- =============================================================================================
-- 4) SECURITY
-- =============================================================================================

-- DISPLAYER
exec sp_FrameworkAddPermissionAction 'SecurityReeskont_Displayer', 'Trex.WebUI', 'SecurityRediscount/Index'
exec sp_FrameworkAddPermissionAction 'SecurityReeskont_Displayer', 'Trex.WebUI', 'SecurityRediscount/Load'

-- MAKER
exec sp_FrameworkAddPermissionAction 'SecurityReeskont_Maker', 'Trex.WebUI', 'SecurityRediscount/Execute'
exec sp_FrameworkAddPermissionAction 'SecurityReeskont_Checker', 'Trex.WebUI', 'SecurityRediscount/Execute'



GO

-- =============================================================================================
-- 5) SUB PRODUCT LISTESI — YABANCI CONTROLLER ACTION'I (Tawarruq deseni)
-- ---------------------------------------------------------------------------------------------


-- MM Transactions alt urunleri
exec sp_FrameworkAddPermissionAction 'TreasuryReeskont_Displayer',   'Trex.WebUI', 'MmTransaction/GetProductDefinitions'
exec sp_FrameworkAddPermissionAction 'TreasuryReeskont_Maker',       'Trex.WebUI', 'MmTransaction/GetProductDefinitions'

exec sp_FrameworkAddPermissionAction 'InvestmentReeskont_Displayer', 'Trex.WebUI', 'MmTransaction/GetProductDefinitions'
exec sp_FrameworkAddPermissionAction 'InvestmentReeskont_Maker',     'Trex.WebUI', 'MmTransaction/GetProductDefinitions'

exec sp_FrameworkAddPermissionAction 'SecurityReeskont_Displayer',   'Trex.WebUI', 'MmTransaction/GetProductDefinitions'
exec sp_FrameworkAddPermissionAction 'SecurityReeskont_Maker',       'Trex.WebUI', 'MmTransaction/GetProductDefinitions'

-- InterbankLoan alt urunleri (`!IsSameDay && !IsZeroRate` suzgecli liste)
exec sp_FrameworkAddPermissionAction 'TreasuryReeskont_Displayer',   'Trex.WebUI', 'InterbankLoan/GetProductDefinitions'
exec sp_FrameworkAddPermissionAction 'TreasuryReeskont_Maker',       'Trex.WebUI', 'InterbankLoan/GetProductDefinitions'

exec sp_FrameworkAddPermissionAction 'InvestmentReeskont_Displayer', 'Trex.WebUI', 'InterbankLoan/GetProductDefinitions'
exec sp_FrameworkAddPermissionAction 'InvestmentReeskont_Maker',     'Trex.WebUI', 'InterbankLoan/GetProductDefinitions'

exec sp_FrameworkAddPermissionAction 'SecurityReeskont_Displayer',   'Trex.WebUI', 'InterbankLoan/GetProductDefinitions'
exec sp_FrameworkAddPermissionAction 'SecurityReeskont_Maker',       'Trex.WebUI', 'InterbankLoan/GetProductDefinitions'

GO


