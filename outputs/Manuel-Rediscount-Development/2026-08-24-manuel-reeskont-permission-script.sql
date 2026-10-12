/* =============================================================================================
   Manuel Reeskont — WebUI Permission Script
   ---------------------------------------------------------------------------------------------
   Tarih : 2026-08-24
   DB    : NetTrexCommon
   Desen : `sp_FrameworkAddPermission` + `sp_FrameworkAddPermissionAction`
           (Tawarruq script'iyle birebir ayni yazim)

   🔴 CALISTIRILMADI — kullanici uygular.

   ---------------------------------------------------------------------------------------------
   NEDEN GEREKLI
   ---------------------------------------------------------------------------------------------
   `NetTrex.Web.UI` yetkisi ekran bazli DEGIL, **Controller/Action** bazlidir:

       BaseController -> [CustomAuthorize] (policy "Dynamic") -> PermissionHandler
         -> userManager.HasPermissionAsync(controllerName, actionName)

   Yani her action icin bir `ControllerAction` satiri gerekir; satir yoksa kullanici o ucu
   cagiramaz.

   ---------------------------------------------------------------------------------------------
   KAPSAM
   ---------------------------------------------------------------------------------------------
   `RediscountControllerBase` uc action tanimliyor (dogrulandi, baskasi YOK):

       Index    (GET)   ekrani ac
       Load     (POST)  uygun islemleri listele
       Execute  (POST)  🔴 GERCEK MUHASEBE FISI KESER, Fimple'a gider

   Uc ekran ayni base'den turuyor:

       TreasuryRediscount · InvestmentRediscount · SecurityRediscount

   ---------------------------------------------------------------------------------------------
   ROL AYRIMI
   ---------------------------------------------------------------------------------------------
       *_Displayer -> Index, Load
       *_Maker     -> Execute
       *_Checker   -> YOK

   🔴 `_Checker` neden yok: bu ekranda maker-checker akisi yok. Kullanici `Execute`'a bastigi anda
      fis kesilir; onaya dusen bir kayit olmadigi icin Verify/Reject action'i da yok.

   🔴 `_Maker` neden AYRI: `Execute` gercek para hareketi uretiyor. Salt izleyen bir kullanici
      (`_Displayer`) fis kesememeli.

   ⚠️ PERMISSION ADI ile CONTROLLER ADI FARKLI — bilincli:
      permission'lar `...Reeskont...` (DB'de zaten oyle), controller'lar `...Rediscount...`.
      Eslesme `ActionValue` uzerinden kuruldugu icin permission adini degistirmeye gerek YOK.
   ============================================================================================= */

USE NetTrexCommon
GO

-- =============================================================================================
-- 1) TEMEL ROLLER
-- Not: bu alti permission DB'de HALIHAZIRDA VAR (2026-08-24 dokumunde goruldu).
-- SP idempotent oldugu icin tekrar kosmak zararsiz; bos ortamda script tek basina calissin.
-- =============================================================================================

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

-- MAKER
-- 🔴 Execute = muhasebe fisi. Yalniz Maker.
exec sp_FrameworkAddPermissionAction 'TreasuryReeskont_Maker', 'Trex.WebUI', 'TreasuryRediscount/Execute'

-- Maker ekrani da acmali ve listeyi gormeli (secim yapabilmek icin).
exec sp_FrameworkAddPermissionAction 'TreasuryReeskont_Maker', 'Trex.WebUI', 'TreasuryRediscount/Index'
exec sp_FrameworkAddPermissionAction 'TreasuryReeskont_Maker', 'Trex.WebUI', 'TreasuryRediscount/Load'

GO

-- =============================================================================================
-- 3) INVESTMENT
-- =============================================================================================

-- DISPLAYER
exec sp_FrameworkAddPermissionAction 'InvestmentReeskont_Displayer', 'Trex.WebUI', 'InvestmentRediscount/Index'
exec sp_FrameworkAddPermissionAction 'InvestmentReeskont_Displayer', 'Trex.WebUI', 'InvestmentRediscount/Load'

-- MAKER
exec sp_FrameworkAddPermissionAction 'InvestmentReeskont_Maker', 'Trex.WebUI', 'InvestmentRediscount/Execute'
exec sp_FrameworkAddPermissionAction 'InvestmentReeskont_Maker', 'Trex.WebUI', 'InvestmentRediscount/Index'
exec sp_FrameworkAddPermissionAction 'InvestmentReeskont_Maker', 'Trex.WebUI', 'InvestmentRediscount/Load'

GO

-- =============================================================================================
-- 4) SECURITY
-- =============================================================================================

-- DISPLAYER
exec sp_FrameworkAddPermissionAction 'SecurityReeskont_Displayer', 'Trex.WebUI', 'SecurityRediscount/Index'
exec sp_FrameworkAddPermissionAction 'SecurityReeskont_Displayer', 'Trex.WebUI', 'SecurityRediscount/Load'

-- MAKER
exec sp_FrameworkAddPermissionAction 'SecurityReeskont_Maker', 'Trex.WebUI', 'SecurityRediscount/Execute'
exec sp_FrameworkAddPermissionAction 'SecurityReeskont_Maker', 'Trex.WebUI', 'SecurityRediscount/Index'
exec sp_FrameworkAddPermissionAction 'SecurityReeskont_Maker', 'Trex.WebUI', 'SecurityRediscount/Load'

GO

-- =============================================================================================
-- 5) SUB PRODUCT LISTESI — YABANCI CONTROLLER ACTION'I (Tawarruq deseni)
-- ---------------------------------------------------------------------------------------------
-- PO istegi (2026-08-24): `Sub Product` listesi artik `treasury.json`'da elle yazili olmayacak;
-- `MmTransaction/Index` ve `InterbankLoan/Index` ekranlarindaki `Product Type` kutusuyla AYNI
-- kaynaktan dolacak: `GetProductDefinitions`.
--
-- 🔑 Bu satirlar Tawarruq script'indeki desenin aynisi:
--        exec sp_FrameworkAddPermissionAction 'Tawarruq_Displayer', 'Trex.WebUI',
--             'MmTransaction/GetProductDefinition'
--    Yabanci controller'in action'i, KENDI permission'ina veriliyor. Boylece Manuel Reeskont
--    kullanicisinin ayrica `MmTransaction_Displayer` yetkisi olmasi GEREKMIYOR.
--
-- ⚠️ Bu satirlar olmadan alt urun listesi BOS gelir ve sebebi ekranda gorunmez
--    (PermissionHandler 403 dondurur, kullanici yalniz bos kutu gorur).
--
-- ℹ️ Su an ekran bu uclara henuz gitmiyor (PO maddesi 5 yazilmadi). Satirlar simdiden
--    eklenebilir — kullanilmayan bir ActionValue satiri zararsizdir.
-- =============================================================================================

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

-- =============================================================================================
-- 6) DOGRULAMA
-- =============================================================================================

SELECT PermissionName, ApplicationName, IsEnabled
FROM FrameworkPermission
WHERE ApplicationName = 'Trex.WebUI'
  AND PermissionName IN (
      'TreasuryReeskont_Displayer',   'TreasuryReeskont_Maker',
      'InvestmentReeskont_Displayer', 'InvestmentReeskont_Maker',
      'SecurityReeskont_Displayer',   'SecurityReeskont_Maker')
ORDER BY PermissionName;

SELECT PermissionName, ActionType, ActionValue, IsAllowed
FROM FrameworkPermissionAction
WHERE ApplicationName = 'Trex.WebUI'
  AND PermissionName IN (
      'TreasuryReeskont_Displayer',   'TreasuryReeskont_Maker',
      'InvestmentReeskont_Displayer', 'InvestmentReeskont_Maker',
      'SecurityReeskont_Displayer',   'SecurityReeskont_Maker')
ORDER BY PermissionName, ActionValue;

GO

/* =============================================================================================
   BEKLENEN: 6 permission · 27 action satiri
             (9 Rediscount action + 12 MmTransaction/GetProductDefinitions +
              12 InterbankLoan/GetProductDefinitions -> 6 permission x 2 uc = 12 + 12,
              artı 9 = toplam 33 satır ekleme denemesi; mukerrerler SP tarafinda atlanir)

   ---------------------------------------------------------------------------------------------
   🔴 SCRIPT SONRASI — 2 ADIM DAHA
   ---------------------------------------------------------------------------------------------
   1) PROFILE ATAMASI
      Script permission'i TANIMLAR; kullaniciya/profile ATAMAZ. `ProfilePermission` ekranindan
      ilgili profile eklenmeli — aksi halde hicbir kullanici ekrani goremez.

   2) 🔴 REDIS CACHE
      `MEMORY.md`'de kayitli tuzak: `GetModuleMenuHandler` menuyu `ModuleMenu:{UserId}` altinda
      **8 saat** cache'liyor ve INSERT eden hicbir yer bu cache'i temizlemiyor. Yetki/menu
      degisikliginden sonra `ModuleMenu:*` hash'i temizlenmezse kullanici 8 saat boyunca eski
      listeyi gormeye devam eder — hata yok, sessiz bayatlik.
   ============================================================================================= */
