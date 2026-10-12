USE NetTrexCommon

GO


EXEC sp_FrameworkAddPermission @PermissionName = 'TreasuryReeskont_Displayer',   @ApplicationName = 'Trex.WebUI';
EXEC sp_FrameworkAddPermission @PermissionName = 'TreasuryReeskont_Maker',       @ApplicationName = 'Trex.WebUI';

EXEC sp_FrameworkAddPermission @PermissionName = 'InvestmentReeskont_Displayer', @ApplicationName = 'Trex.WebUI';
EXEC sp_FrameworkAddPermission @PermissionName = 'InvestmentReeskont_Maker',     @ApplicationName = 'Trex.WebUI';

EXEC sp_FrameworkAddPermission @PermissionName = 'SecurityReeskont_Displayer',   @ApplicationName = 'Trex.WebUI';
EXEC sp_FrameworkAddPermission @PermissionName = 'SecurityReeskont_Maker',       @ApplicationName = 'Trex.WebUI';

GO

-- =============================================================================================
-- 2) TREASURY
-- =============================================================================================

-- DISPLAYER
exec sp_FrameworkAddPermissionAction 'TreasuryReeskont_Displayer', 'Trex.WebUI', 'TreasuryRediscount/Index'
exec sp_FrameworkAddPermissionAction 'TreasuryReeskont_Displayer', 'Trex.WebUI', 'TreasuryRediscount/Load'
exec sp_FrameworkAddPermissionAction 'TreasuryReeskont_Displayer', 'Trex.WebUI', 'TreasuryRediscount/Accounting'
exec sp_FrameworkAddPermissionAction 'TreasuryReeskont_Displayer', 'Trex.WebUI', 'TreasuryRediscount/SelectAcc'

-- MAKER
exec sp_FrameworkAddPermissionAction 'TreasuryReeskont_Maker', 'Trex.WebUI', 'TreasuryRediscount/Execute'
exec sp_FrameworkAddPermissionAction 'TreasuryReeskont_Maker', 'Trex.WebUI', 'TreasuryRediscount/Index'
exec sp_FrameworkAddPermissionAction 'TreasuryReeskont_Maker', 'Trex.WebUI', 'TreasuryRediscount/Load'
exec sp_FrameworkAddPermissionAction 'TreasuryReeskont_Maker', 'Trex.WebUI', 'TreasuryRediscount/Accounting'
exec sp_FrameworkAddPermissionAction 'TreasuryReeskont_Maker', 'Trex.WebUI', 'TreasuryRediscount/SelectAcc'

GO

-- =============================================================================================
-- 3) INVESTMENT
-- =============================================================================================

-- DISPLAYER
exec sp_FrameworkAddPermissionAction 'InvestmentReeskont_Displayer', 'Trex.WebUI', 'InvestmentRediscount/Index'
exec sp_FrameworkAddPermissionAction 'InvestmentReeskont_Displayer', 'Trex.WebUI', 'InvestmentRediscount/Load'
exec sp_FrameworkAddPermissionAction 'InvestmentReeskont_Displayer', 'Trex.WebUI', 'InvestmentRediscount/Accounting'
exec sp_FrameworkAddPermissionAction 'InvestmentReeskont_Displayer', 'Trex.WebUI', 'InvestmentRediscount/SelectAcc'

-- MAKER
exec sp_FrameworkAddPermissionAction 'InvestmentReeskont_Maker', 'Trex.WebUI', 'InvestmentRediscount/Execute'
exec sp_FrameworkAddPermissionAction 'InvestmentReeskont_Maker', 'Trex.WebUI', 'InvestmentRediscount/Index'
exec sp_FrameworkAddPermissionAction 'InvestmentReeskont_Maker', 'Trex.WebUI', 'InvestmentRediscount/Load'
exec sp_FrameworkAddPermissionAction 'InvestmentReeskont_Maker', 'Trex.WebUI', 'InvestmentRediscount/Accounting'
exec sp_FrameworkAddPermissionAction 'InvestmentReeskont_Maker', 'Trex.WebUI', 'InvestmentRediscount/SelectAcc'

GO

-- =============================================================================================
-- 4) SECURITY
-- =============================================================================================

-- DISPLAYER
exec sp_FrameworkAddPermissionAction 'SecurityReeskont_Displayer', 'Trex.WebUI', 'SecurityRediscount/Index'
exec sp_FrameworkAddPermissionAction 'SecurityReeskont_Displayer', 'Trex.WebUI', 'SecurityRediscount/Load'
exec sp_FrameworkAddPermissionAction 'SecurityReeskont_Displayer', 'Trex.WebUI', 'SecurityRediscount/Accounting'
exec sp_FrameworkAddPermissionAction 'SecurityReeskont_Displayer', 'Trex.WebUI', 'SecurityRediscount/SelectAcc'

-- MAKER
exec sp_FrameworkAddPermissionAction 'SecurityReeskont_Maker', 'Trex.WebUI', 'SecurityRediscount/Execute'
exec sp_FrameworkAddPermissionAction 'SecurityReeskont_Maker', 'Trex.WebUI', 'SecurityRediscount/Index'
exec sp_FrameworkAddPermissionAction 'SecurityReeskont_Maker', 'Trex.WebUI', 'SecurityRediscount/Load'
exec sp_FrameworkAddPermissionAction 'SecurityReeskont_Maker', 'Trex.WebUI', 'SecurityRediscount/Accounting'
exec sp_FrameworkAddPermissionAction 'SecurityReeskont_Maker', 'Trex.WebUI', 'SecurityRediscount/SelectAcc'

GO

-- =============================================================================================
-- 5) SUB PRODUCT LISTESI 
-- =============================================================================================

-- MM Transactions alt urunleri
exec sp_FrameworkAddPermissionAction 'TreasuryReeskont_Displayer',   'Trex.WebUI', 'MmTransaction/GetProductDefinitions'
exec sp_FrameworkAddPermissionAction 'TreasuryReeskont_Maker',       'Trex.WebUI', 'MmTransaction/GetProductDefinitions'

exec sp_FrameworkAddPermissionAction 'TreasuryReeskont_Displayer',   'Trex.WebUI', 'InterbankLoan/GetProductDefinitions'
exec sp_FrameworkAddPermissionAction 'TreasuryReeskont_Maker',       'Trex.WebUI', 'InterbankLoan/GetProductDefinitions'

GO

