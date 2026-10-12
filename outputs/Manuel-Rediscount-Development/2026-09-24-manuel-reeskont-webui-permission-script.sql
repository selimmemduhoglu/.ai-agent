/* =============================================================================================
   Manuel Reeskont — Trex.WebUI Permission Script (GUNCELLEME)
   ---------------------------------------------------------------------------------------------
   Tarih : 2026-09-24
   DB    : NetTrexCommon
   Desen : `2026-08-24-manuel-reeskont-permission-script.sql` ile AYNI — o dosyanin YERINE gecer.

   🔴 CALISTIRILMADI — kullanici uygular.

   ---------------------------------------------------------------------------------------------
   NEDEN GUNCELLEME GEREKTI — GERCEK EKSIK, KULLANICI CANLIDA YAKALADI
   ---------------------------------------------------------------------------------------------
   2026-08-24 script'i yazildiginda `RediscountControllerBase.cs` (Trex.WebUI) sadece 3 action
   iceriyordu: Index, Load, Execute. O script bu ucune permission verdi.

   SONRADAN (bu oturumdaki Accounting popup calismasi sirasinda, 2026-09-21 civari) ekrana IKI
   action DAHA eklendi ve hicbir permission script'i onlar icin YAZILMADI:

       SelectAcc    (GET,  RediscountControllerBase.cs:166)  — Module Accounting sekmesi
       Accounting   (POST, BaseController.cs:37 — MIRAS ALINIYOR, RediscountControllerBase'te
                     TANIMLI DEGIL ama concrete controller'lar BaseController'dan turedigi icin
                     route yine `{Controller}/Accounting` olarak calisiyor)

   Kullanicinin canli ortamda aldigi hata TAM OLARAK bu eksigi gosteriyor:
       GET/POST .../TreasuryRediscount/Accounting
       "You don't have permission.TreasuryRediscount/Accounting"

   ⚠️ Common.UI'nin action adi `AccountingDetails` (bu oturumda rename edildi, dataType:'json'
   catisiyla ilgisiz bir sebeple) — ama WebUI'ninki hala `Accounting`. IKI SCRIPT DE AYRI
   ApplicationName tasir (`Trex.WebUI` vs `Treasy.Common.UI`), birbirinin yerine GECMEZ, IKISI DE
   calistirilmali (bkz. `2026-09-24-manuel-reeskont-commonui-permission-script.sql`).

   ---------------------------------------------------------------------------------------------
   KAPSAM — GUNCEL 5 action (RediscountControllerBase + miras alinan Accounting)
   ---------------------------------------------------------------------------------------------
       Index       (GET)   ekrani ac
       Load        (POST)  uygun islemleri listele
       Execute     (POST)  🔴 GERCEK MUHASEBE FISI KESER, Fimple'a gider
       Accounting  (POST)  muhasebe penceresi — Core Banking + Local sekmeleri (salt-okunur)
       SelectAcc   (GET)   muhasebe penceresi — Module Accounting sekmesi (salt-okunur)

   ---------------------------------------------------------------------------------------------
   ROL AYRIMI — 2026-08-24 ile ayni mantik, degismedi
   ---------------------------------------------------------------------------------------------
       *_Displayer -> Index, Load, Accounting, SelectAcc  (hepsi salt-okunur)
       *_Maker     -> Execute (+ Displayer'in tum action'lari)
       *_Checker   -> YOK (maker-checker akisi yok — Execute'a basinca fis aninda kesilir)
   ============================================================================================= */

USE NetTrexCommon
GO

-- =============================================================================================
-- 1) TEMEL ROLLER
-- Not: bu alti permission DB'de HALIHAZIRDA VAR (2026-08-24'te olusturuldu). SP idempotent,
-- tekrar kosmak zararsiz.
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
exec sp_FrameworkAddPermissionAction 'TreasuryReeskont_Displayer', 'Trex.WebUI', 'TreasuryRediscount/Accounting'
exec sp_FrameworkAddPermissionAction 'TreasuryReeskont_Displayer', 'Trex.WebUI', 'TreasuryRediscount/SelectAcc'

-- MAKER
-- 🔴 Execute = muhasebe fisi. Yalniz Maker.
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
-- 5) SUB PRODUCT LISTESI — YABANCI CONTROLLER ACTION'I (2026-08-24'ten degismeden tasindi)
-- ---------------------------------------------------------------------------------------------
-- `Sub Product` listesi `MmTransaction/GetProductDefinitions` ve
-- `InterbankLoan/GetProductDefinitions`'a gidiyor — bu satirlar olmadan alt urun listesi BOS
-- gelir (PermissionHandler 403 dondurur, kullanici yalniz bos kutu gorur).
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
   BEKLENEN: 6 permission · 51 action satiri
             Rediscount: (4x3 Displayer=12) + (5x3 Maker=15) = 27
             SubProduct: (2 action x 6 permission) = 12 + 12 = 24
             Toplam: 27 + 24 = 51

   ---------------------------------------------------------------------------------------------
   🔴 SCRIPT SONRASI — 2 ADIM DAHA
   ---------------------------------------------------------------------------------------------
   1) PROFILE ATAMASI — bu satirlar zaten profile atanmis kullanicilar icin GECERLI OLUR
      (permission ayni isimle var oldugu icin ek atama GEREKMEYEBILIR) — ama profile hic
      atanmamissa once atama yapilmali.
   2) 🔴 REDIS CACHE — `GetModuleMenuHandler` / permission cache TEMIZLENMELI, aksi halde
      kullanici saatlerce eski (yetkisiz) durumu gormeye devam eder.
   ============================================================================================= */
