/* =============================================================================================
   Manuel Reeskont — Treasy.Common.UI Permission Script
   ---------------------------------------------------------------------------------------------
   Tarih : 2026-09-22
   DB    : NetTrexCommon
   Desen : 2026-08-24-manuel-reeskont-permission-script.sql (Trex.WebUI icin yazilmisti) ile
           BIREBIR AYNI yapi — yalniz ApplicationName ve action listesi Common.UI'ye uyarlandi.

   🔴 CALISTIRILMADI — kullanici uygular. Bu oturumda TrexFramework/NetTrexCommon'a canli
   baglanti kurulamadi (connection string bu repoda/Common.UI'de bulunamadi, muhtemelen
   user-secrets/deploy-time enjeksiyon) — script GECMISTEKI CALISAN ORNEGIN deseni + Common.UI'nin
   kendi kod tabanindan (RediscountControllerBase.cs) DOGRULANAN action listesiyle yazildi.
   Calistirmadan once `sp_FrameworkAddPermission`/`sp_FrameworkAddPermissionAction`'in
   NetTrexCommon'da hala aynı imzada oldugunu teyit edin.

   ---------------------------------------------------------------------------------------------
   KAPSAM — RediscountControllerBase.cs'te DOGRULANAN action'lar (bu oturumda okundu)
   ---------------------------------------------------------------------------------------------
       Index       (GET)   ekrani ac
       Load        (POST)  uygun islemleri listele
       Execute     (POST)  🔴 GERCEK MUHASEBE FISI KESER, Fimple'a gider
       Accounting  (POST)  muhasebe penceresi — Core Banking + Local sekmeleri (salt-okunur)
       SelectAcc   (GET)   muhasebe penceresi — Module Accounting sekmesi (salt-okunur)

   Uc ekran ayni base'den turuyor: TreasuryRediscount · SecurityRediscount · InvestmentRediscount

   ---------------------------------------------------------------------------------------------
   ROL AYRIMI — WebUI script'iyle ayni mantik
   ---------------------------------------------------------------------------------------------
       *_Displayer -> Index, Load, Accounting, SelectAcc  (hepsi salt-okunur)
       *_Maker     -> Execute (+ Displayer'in tum action'lari, listeyi görüp secebilsin diye)
       *_Checker   -> YOK (maker-checker akisi yok, WebUI'deki gerekce aynen gecerli)

   ⚠️ WebUI script'indeki "5) SUB PRODUCT — yabanci controller action'i" bolumunun KARSILIGI YOK:
      Common.UI'de SubProduct listesi `IManualRediscountSubProductApi` uzerinden DOGRUDAN modul
      API'sine gidiyor (tarayici baska bir controller'a hic gitmiyor) — WebUI'deki
      "MmTransaction/GetProductDefinitions" gibi yabanci-controller-permission ihtiyaci burada yok.
   ============================================================================================= */

USE NetTrexCommon
GO

-- =============================================================================================
-- 1) TEMEL ROLLER
-- =============================================================================================

EXEC sp_FrameworkAddPermission @PermissionName = 'TreasuryReeskont_Displayer',   @ApplicationName = 'Treasy.Common.UI';
EXEC sp_FrameworkAddPermission @PermissionName = 'TreasuryReeskont_Maker',       @ApplicationName = 'Treasy.Common.UI';

EXEC sp_FrameworkAddPermission @PermissionName = 'InvestmentReeskont_Displayer', @ApplicationName = 'Treasy.Common.UI';
EXEC sp_FrameworkAddPermission @PermissionName = 'InvestmentReeskont_Maker',     @ApplicationName = 'Treasy.Common.UI';

EXEC sp_FrameworkAddPermission @PermissionName = 'SecurityReeskont_Displayer',   @ApplicationName = 'Treasy.Common.UI';
EXEC sp_FrameworkAddPermission @PermissionName = 'SecurityReeskont_Maker',       @ApplicationName = 'Treasy.Common.UI';

GO

-- =============================================================================================
-- 2) TREASURY
-- =============================================================================================

exec sp_FrameworkAddPermissionAction 'TreasuryReeskont_Displayer', 'Treasy.Common.UI', 'TreasuryRediscount/Index'
exec sp_FrameworkAddPermissionAction 'TreasuryReeskont_Displayer', 'Treasy.Common.UI', 'TreasuryRediscount/Load'
exec sp_FrameworkAddPermissionAction 'TreasuryReeskont_Displayer', 'Treasy.Common.UI', 'TreasuryRediscount/Accounting'
exec sp_FrameworkAddPermissionAction 'TreasuryReeskont_Displayer', 'Treasy.Common.UI', 'TreasuryRediscount/SelectAcc'

exec sp_FrameworkAddPermissionAction 'TreasuryReeskont_Maker', 'Treasy.Common.UI', 'TreasuryRediscount/Execute'
exec sp_FrameworkAddPermissionAction 'TreasuryReeskont_Maker', 'Treasy.Common.UI', 'TreasuryRediscount/Index'
exec sp_FrameworkAddPermissionAction 'TreasuryReeskont_Maker', 'Treasy.Common.UI', 'TreasuryRediscount/Load'
exec sp_FrameworkAddPermissionAction 'TreasuryReeskont_Maker', 'Treasy.Common.UI', 'TreasuryRediscount/Accounting'
exec sp_FrameworkAddPermissionAction 'TreasuryReeskont_Maker', 'Treasy.Common.UI', 'TreasuryRediscount/SelectAcc'

GO

-- =============================================================================================
-- 3) INVESTMENT
-- =============================================================================================

exec sp_FrameworkAddPermissionAction 'InvestmentReeskont_Displayer', 'Treasy.Common.UI', 'InvestmentRediscount/Index'
exec sp_FrameworkAddPermissionAction 'InvestmentReeskont_Displayer', 'Treasy.Common.UI', 'InvestmentRediscount/Load'
exec sp_FrameworkAddPermissionAction 'InvestmentReeskont_Displayer', 'Treasy.Common.UI', 'InvestmentRediscount/Accounting'
exec sp_FrameworkAddPermissionAction 'InvestmentReeskont_Displayer', 'Treasy.Common.UI', 'InvestmentRediscount/SelectAcc'

exec sp_FrameworkAddPermissionAction 'InvestmentReeskont_Maker', 'Treasy.Common.UI', 'InvestmentRediscount/Execute'
exec sp_FrameworkAddPermissionAction 'InvestmentReeskont_Maker', 'Treasy.Common.UI', 'InvestmentRediscount/Index'
exec sp_FrameworkAddPermissionAction 'InvestmentReeskont_Maker', 'Treasy.Common.UI', 'InvestmentRediscount/Load'
exec sp_FrameworkAddPermissionAction 'InvestmentReeskont_Maker', 'Treasy.Common.UI', 'InvestmentRediscount/Accounting'
exec sp_FrameworkAddPermissionAction 'InvestmentReeskont_Maker', 'Treasy.Common.UI', 'InvestmentRediscount/SelectAcc'

GO

-- =============================================================================================
-- 4) SECURITY
-- =============================================================================================

exec sp_FrameworkAddPermissionAction 'SecurityReeskont_Displayer', 'Treasy.Common.UI', 'SecurityRediscount/Index'
exec sp_FrameworkAddPermissionAction 'SecurityReeskont_Displayer', 'Treasy.Common.UI', 'SecurityRediscount/Load'
exec sp_FrameworkAddPermissionAction 'SecurityReeskont_Displayer', 'Treasy.Common.UI', 'SecurityRediscount/Accounting'
exec sp_FrameworkAddPermissionAction 'SecurityReeskont_Displayer', 'Treasy.Common.UI', 'SecurityRediscount/SelectAcc'

exec sp_FrameworkAddPermissionAction 'SecurityReeskont_Maker', 'Treasy.Common.UI', 'SecurityRediscount/Execute'
exec sp_FrameworkAddPermissionAction 'SecurityReeskont_Maker', 'Treasy.Common.UI', 'SecurityRediscount/Index'
exec sp_FrameworkAddPermissionAction 'SecurityReeskont_Maker', 'Treasy.Common.UI', 'SecurityRediscount/Load'
exec sp_FrameworkAddPermissionAction 'SecurityReeskont_Maker', 'Treasy.Common.UI', 'SecurityRediscount/Accounting'
exec sp_FrameworkAddPermissionAction 'SecurityReeskont_Maker', 'Treasy.Common.UI', 'SecurityRediscount/SelectAcc'

GO

-- =============================================================================================
-- 5) DOGRULAMA
-- =============================================================================================

SELECT PermissionName, ApplicationName, IsEnabled
FROM FrameworkPermission
WHERE ApplicationName = 'Treasy.Common.UI'
  AND PermissionName IN (
      'TreasuryReeskont_Displayer',   'TreasuryReeskont_Maker',
      'InvestmentReeskont_Displayer', 'InvestmentReeskont_Maker',
      'SecurityReeskont_Displayer',   'SecurityReeskont_Maker')
ORDER BY PermissionName;

SELECT PermissionName, ActionType, ActionValue, IsAllowed
FROM FrameworkPermissionAction
WHERE ApplicationName = 'Treasy.Common.UI'
  AND PermissionName IN (
      'TreasuryReeskont_Displayer',   'TreasuryReeskont_Maker',
      'InvestmentReeskont_Displayer', 'InvestmentReeskont_Maker',
      'SecurityReeskont_Displayer',   'SecurityReeskont_Maker')
ORDER BY PermissionName, ActionValue;

GO

/* =============================================================================================
   BEKLENEN: 6 permission · 24 action satiri (4 action x 3 ekran x Displayer + 5 action x 3 x Maker)

   ---------------------------------------------------------------------------------------------
   🔴 SCRIPT SONRASI — 2 ADIM DAHA (WebUI script'inde de aynen vardi)
   ---------------------------------------------------------------------------------------------
   1) PROFILE ATAMASI — script permission'i TANIMLAR, kullaniciya/profile ATAMAZ.
   2) 🔴 REDIS CACHE — `GetModuleMenuHandler` menuyu 8 saat cache'liyor, temizlenmezse kullanici
      8 saat eski listeyi gorur.
   ============================================================================================= */
