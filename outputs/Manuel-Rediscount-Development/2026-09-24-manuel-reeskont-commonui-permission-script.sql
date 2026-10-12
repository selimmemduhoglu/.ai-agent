/* =============================================================================================
   Manuel Reeskont — Treasy.Common.UI Permission Script
   ---------------------------------------------------------------------------------------------
   Tarih : 2026-09-24
   DB    : NetTrexCommon
   Desen : Kullanicinin Tawarruq icin verdigi ornek (sp_FrameworkAddPermission +
           sp_FrameworkAddPermissionAction, dogrudan cagri, IF NOT EXISTS sarmalayici YOK —
           SP'ler zaten idempotent) ile BIREBIR AYNI yazim.

   🔴 CALISTIRILMADI — kullanici uygular.

   Bu dosya `2026-09-22-manuel-reeskont-commonui-permission-script.sql`'in YERINE gecer —
   o dosya `TreasuryRediscount/Accounting` action'ini icermisti, ama controller'daki action
   bu oturumda `AccountingDetails` olarak degistirilmisti (eski isim JSON-only ajax helper'i
   ile catisiyordu, kok neden — bkz. sohbet gecmisi). Kullanici canli ortamda tam da bu eksik
   permission'i (`TreasuryRediscount/Accounting`) test ederken 403 aldi:
       "You don't have permission.TreasuryRediscount/Accounting"
   Eski dosya silinebilir/yok sayilabilir — action adi zaten yanlisti, hic calistirilmamisti.

   ---------------------------------------------------------------------------------------------
   KAPSAM — RediscountControllerBase.cs'te DOGRULANAN action'lar (bu oturumda dosyadan okundu)
   ---------------------------------------------------------------------------------------------
       Index              (GET)   ekrani ac
       Load               (POST)  uygun islemleri listele
       Execute            (POST)  🔴 GERCEK MUHASEBE FISI KESER, Fimple'a gider
       AccountingDetails  (POST)  muhasebe penceresi — Core Banking + Local sekmeleri (salt-okunur)
       SelectAcc          (GET)   muhasebe penceresi — Module Accounting sekmesi (salt-okunur)

   Uc ekran ayni base'den turuyor, controller adlari ASP.NET Core convention'i ile sinif adindan
   turer (ayri [Route] yok, TreasuryRediscountController -> "TreasuryRediscount" v.b.):

       TreasuryRediscount · SecurityRediscount · InvestmentRediscount

   ---------------------------------------------------------------------------------------------
   ROL AYRIMI — WebUI script'iyle (2026-08-24) ayni mantik
   ---------------------------------------------------------------------------------------------
       *_Displayer -> Index, Load, AccountingDetails, SelectAcc  (hepsi salt-okunur)
       *_Maker     -> Execute (+ Displayer'in tum action'lari, listeyi görüp secebilsin diye)
       *_Checker   -> YOK (maker-checker akisi yok — Execute'a basinca fis aninda kesilir,
                      onaya dusen bir kayit yok, Verify/Reject action'i da yok)

   ⚠️ PERMISSION ADI ile CONTROLLER ADI FARKLI — bilincli, WebUI script'inden devralindi:
      permission'lar `...Reeskont...`, controller'lar `...Rediscount...`. Eslesme `ActionValue`
      uzerinden kuruldugu icin permission adini degistirmeye gerek YOK; ayrica ayni kullanici
      grubu hem WebUI hem Common.UI ekranini kullanabilecekse permission ADLARININ ortak olmasi
      (uygulamalar `ApplicationName` ile zaten ayristigi icin) profil yonetimini kolaylastirir.

   ⚠️ WebUI script'indeki "5) SUB PRODUCT — yabanci controller action'i" bolumunun KARSILIGI YOK:
      Common.UI'de SubProduct listesi `IManualRediscountSubProductApi` uzerinden DOGRUDAN modul
      API'sine gidiyor (tarayici baska bir Common.UI controller'ina hic gitmiyor) — WebUI'deki
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

-- DISPLAYER
exec sp_FrameworkAddPermissionAction 'TreasuryReeskont_Displayer', 'Treasy.Common.UI', 'TreasuryRediscount/Index'
exec sp_FrameworkAddPermissionAction 'TreasuryReeskont_Displayer', 'Treasy.Common.UI', 'TreasuryRediscount/Load'
exec sp_FrameworkAddPermissionAction 'TreasuryReeskont_Displayer', 'Treasy.Common.UI', 'TreasuryRediscount/AccountingDetails'
exec sp_FrameworkAddPermissionAction 'TreasuryReeskont_Displayer', 'Treasy.Common.UI', 'TreasuryRediscount/SelectAcc'

-- MAKER
-- 🔴 Execute = muhasebe fisi. Yalniz Maker.
exec sp_FrameworkAddPermissionAction 'TreasuryReeskont_Maker', 'Treasy.Common.UI', 'TreasuryRediscount/Execute'

-- Maker ekrani da acmali ve listeyi/muhasebe penceresini gormeli (secim yapabilmek icin).
exec sp_FrameworkAddPermissionAction 'TreasuryReeskont_Maker', 'Treasy.Common.UI', 'TreasuryRediscount/Index'
exec sp_FrameworkAddPermissionAction 'TreasuryReeskont_Maker', 'Treasy.Common.UI', 'TreasuryRediscount/Load'
exec sp_FrameworkAddPermissionAction 'TreasuryReeskont_Maker', 'Treasy.Common.UI', 'TreasuryRediscount/AccountingDetails'
exec sp_FrameworkAddPermissionAction 'TreasuryReeskont_Maker', 'Treasy.Common.UI', 'TreasuryRediscount/SelectAcc'

GO

-- =============================================================================================
-- 3) INVESTMENT
-- =============================================================================================

-- DISPLAYER
exec sp_FrameworkAddPermissionAction 'InvestmentReeskont_Displayer', 'Treasy.Common.UI', 'InvestmentRediscount/Index'
exec sp_FrameworkAddPermissionAction 'InvestmentReeskont_Displayer', 'Treasy.Common.UI', 'InvestmentRediscount/Load'
exec sp_FrameworkAddPermissionAction 'InvestmentReeskont_Displayer', 'Treasy.Common.UI', 'InvestmentRediscount/AccountingDetails'
exec sp_FrameworkAddPermissionAction 'InvestmentReeskont_Displayer', 'Treasy.Common.UI', 'InvestmentRediscount/SelectAcc'

-- MAKER
exec sp_FrameworkAddPermissionAction 'InvestmentReeskont_Maker', 'Treasy.Common.UI', 'InvestmentRediscount/Execute'
exec sp_FrameworkAddPermissionAction 'InvestmentReeskont_Maker', 'Treasy.Common.UI', 'InvestmentRediscount/Index'
exec sp_FrameworkAddPermissionAction 'InvestmentReeskont_Maker', 'Treasy.Common.UI', 'InvestmentRediscount/Load'
exec sp_FrameworkAddPermissionAction 'InvestmentReeskont_Maker', 'Treasy.Common.UI', 'InvestmentRediscount/AccountingDetails'
exec sp_FrameworkAddPermissionAction 'InvestmentReeskont_Maker', 'Treasy.Common.UI', 'InvestmentRediscount/SelectAcc'

GO

-- =============================================================================================
-- 4) SECURITY
-- =============================================================================================

-- DISPLAYER
exec sp_FrameworkAddPermissionAction 'SecurityReeskont_Displayer', 'Treasy.Common.UI', 'SecurityRediscount/Index'
exec sp_FrameworkAddPermissionAction 'SecurityReeskont_Displayer', 'Treasy.Common.UI', 'SecurityRediscount/Load'
exec sp_FrameworkAddPermissionAction 'SecurityReeskont_Displayer', 'Treasy.Common.UI', 'SecurityRediscount/AccountingDetails'
exec sp_FrameworkAddPermissionAction 'SecurityReeskont_Displayer', 'Treasy.Common.UI', 'SecurityRediscount/SelectAcc'

-- MAKER
exec sp_FrameworkAddPermissionAction 'SecurityReeskont_Maker', 'Treasy.Common.UI', 'SecurityRediscount/Execute'
exec sp_FrameworkAddPermissionAction 'SecurityReeskont_Maker', 'Treasy.Common.UI', 'SecurityRediscount/Index'
exec sp_FrameworkAddPermissionAction 'SecurityReeskont_Maker', 'Treasy.Common.UI', 'SecurityRediscount/Load'
exec sp_FrameworkAddPermissionAction 'SecurityReeskont_Maker', 'Treasy.Common.UI', 'SecurityRediscount/AccountingDetails'
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
   BEKLENEN: 6 permission · 27 action satiri
             (4 action x 3 ekran x Displayer = 12) + (5 action x 3 ekran x Maker = 15) = 27

   ---------------------------------------------------------------------------------------------
   🔴 SCRIPT SONRASI — 2 ADIM DAHA (WebUI script'inde de aynen vardi)
   ---------------------------------------------------------------------------------------------
   1) PROFILE ATAMASI — script permission'i TANIMLAR, kullaniciya/profile ATAMAZ.
      `ProfilePermission` ekranindan ilgili profile eklenmeli, aksi halde hicbir kullanici
      ekrani goremez.
   2) 🔴 REDIS CACHE — `GetModuleMenuHandler` menuyu `ModuleMenu:{UserId}` altinda 8 saat
      cache'liyor, temizlenmezse kullanici 8 saat eski listeyi/eski permission durumunu gorur.
   ============================================================================================= */
