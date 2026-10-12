/* =============================================================================================
   Manuel Reeskont — Treasy.Common.UI Menu Script
   ---------------------------------------------------------------------------------------------
   Tarih : 2026-09-22
   DB    : TrexFramework (dbo.FrameworkMenu)
   Desen : NetTrex.Common\DB\TrexFramework\sql_changes\SecurityDepotMapping_Menu.sql

   🔴 CALISTIRILMADI + 🔴 EKSIK BILGIYLE YAZILDI — asagidaki TODO'yu doldurmadan calistirmayin.

   Bu oturumda TrexFramework'e canli baglanti kurulamadi (connection string ne Common.UI'de ne
   docker-compose'ta bulundu). Bu yuzden 3 ekranin menude HANGI ust grubun altina girecegini
   (@ParentMenuKey) bilmiyorum — Treasy.Common.UI'nin kendi menu agacinda JobCron/TaxRule gibi
   ekranlarin nereye oturdugunu gormeden tahmin yurutup yanlis yere eklemek istemedim.

   ---------------------------------------------------------------------------------------------
   🔴 TODO — CALISTIRMADAN ONCE DOLDURUN
   ---------------------------------------------------------------------------------------------
   @ParentMenuKey degiskenini, Manuel Reeskont'un altina girmesini istediginiz mevcut ust menunun
   `MenuKey`'i ile degistirin. Bulmak icin (SELECT — salt okunur):

       SELECT MenuKey, Description, ParentId, ItemOrderId
       FROM dbo.FrameworkMenu
       WHERE ApplicationName = 'Treasy.Common.UI'
       ORDER BY ParentId, ItemOrderId;

   Ust grup yoksa / ekranlar EN UST seviyede duracaksa @ParentMenuKey'i NULL birakip asagidaki
   `WHERE [MenuKey] = @ParentMenuKey` satirini kaldirin, @ParentId'i dogrudan NULL yapin.
   ============================================================================================= */

USE TrexFramework
GO

DECLARE @ParentMenuKey NVARCHAR(200) = N'TODO_DOLDUR';  -- <-- ust menunun MenuKey'i
DECLARE @ParentId INT;

SELECT TOP (1) @ParentId = [ParentId]
FROM [dbo].[FrameworkMenu]
WHERE [ApplicationName] = N'Treasy.Common.UI'
  AND [MenuKey] = @ParentMenuKey;

-- Treasury
IF NOT EXISTS (
    SELECT 1 FROM [dbo].[FrameworkMenu]
    WHERE [ApplicationName] = N'Treasy.Common.UI' AND [MenuKey] = N'TreasuryRediscountKey'
)
BEGIN
    INSERT INTO [dbo].[FrameworkMenu]
        ([ApplicationName], [Description], [MenuKey], [MenuType], [Value], [ForcedUrl],
         [ForcedPermission], [Icon], [IsActive], [ItemOrderId], [ParentId],
         [StateDate], [StateId], [StateMaker], [ModuleName])
    VALUES
        (N'Treasy.Common.UI', N'Manual Rediscount — Treasury', N'TreasuryRediscountKey',
         N'ControllerAction', N'TreasuryRediscount/Index', NULL,
         NULL, NULL, 1, 1, @ParentId,
         GETDATE(), 18, N'system', N'Common');
END

-- Security
IF NOT EXISTS (
    SELECT 1 FROM [dbo].[FrameworkMenu]
    WHERE [ApplicationName] = N'Treasy.Common.UI' AND [MenuKey] = N'SecurityRediscountKey'
)
BEGIN
    INSERT INTO [dbo].[FrameworkMenu]
        ([ApplicationName], [Description], [MenuKey], [MenuType], [Value], [ForcedUrl],
         [ForcedPermission], [Icon], [IsActive], [ItemOrderId], [ParentId],
         [StateDate], [StateId], [StateMaker], [ModuleName])
    VALUES
        (N'Treasy.Common.UI', N'Manual Rediscount — Security', N'SecurityRediscountKey',
         N'ControllerAction', N'SecurityRediscount/Index', NULL,
         NULL, NULL, 1, 2, @ParentId,
         GETDATE(), 18, N'system', N'Common');
END

-- Investment
IF NOT EXISTS (
    SELECT 1 FROM [dbo].[FrameworkMenu]
    WHERE [ApplicationName] = N'Treasy.Common.UI' AND [MenuKey] = N'InvestmentRediscountKey'
)
BEGIN
    INSERT INTO [dbo].[FrameworkMenu]
        ([ApplicationName], [Description], [MenuKey], [MenuType], [Value], [ForcedUrl],
         [ForcedPermission], [Icon], [IsActive], [ItemOrderId], [ParentId],
         [StateDate], [StateId], [StateMaker], [ModuleName])
    VALUES
        (N'Treasy.Common.UI', N'Manual Rediscount — Investment', N'InvestmentRediscountKey',
         N'ControllerAction', N'InvestmentRediscount/Index', NULL,
         NULL, NULL, 1, 3, @ParentId,
         GETDATE(), 18, N'system', N'Common');
END
GO

-- Dogrulama
SELECT MenuKey, Description, Value, ParentId, ItemOrderId
FROM dbo.FrameworkMenu
WHERE ApplicationName = 'Treasy.Common.UI'
  AND MenuKey IN ('TreasuryRediscountKey', 'SecurityRediscountKey', 'InvestmentRediscountKey');
GO
