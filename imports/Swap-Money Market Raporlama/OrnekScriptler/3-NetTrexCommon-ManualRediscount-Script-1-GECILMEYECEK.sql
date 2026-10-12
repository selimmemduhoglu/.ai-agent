--=============================================================================================
   --Manuel Rediscount — Script 1 / MENÜ (Güncel Şema: ModuleName + Translation kolonları)
---------------------------------------------------------------------------------------------

USE NetTrexCommon;
GO

BEGIN TRANSACTION;
BEGIN TRY

    DECLARE @ParentId INT;

    PRINT 'Manuel Rediscount menü kayıtları ekleniyor...';

    ---------------------------------------------------------------------------------------------
    -- 0) Parent: Manuel Rediscount
    ---------------------------------------------------------------------------------------------
    IF NOT EXISTS (SELECT 1 FROM dbo.FrameworkMenu WHERE MenuKey = 'ManuelRediscountKey')
    BEGIN
        INSERT INTO dbo.FrameworkMenu
            (ApplicationName, Description, MenuKey, MenuType, Value, ForcedUrl, ForcedPermission,
             Icon, IsActive, ItemOrderId, ParentId, StateDate, StateId, StateMaker,
             ModuleName, TranslationYatirimEN, TranslationYatirimTR, TranslationKatilimEN, TranslationKatilimTR)
        VALUES
            ('Trex.WebUI', 'Manuel Rediscount', 'ManuelRediscountKey', 'None',
             'None', NULL, NULL,
             'fa-solid fa-chart-line', 1, 69, 129, GETDATE(), 18, 'system',
             'General', 'Manuel Rediscount', 'Manuel Rediscount', 'Manuel Rediscount', 'Manuel Rediscount');

        SET @ParentId = SCOPE_IDENTITY();
        PRINT '  + ManuelRediscount menüye eklendi. Id = ' + CAST(@ParentId AS VARCHAR);
    END
    ELSE
    BEGIN
        SELECT @ParentId = Id FROM dbo.FrameworkMenu WHERE MenuKey = 'ManuelRediscountKey';
        PRINT '  = ManuelRediscount menüde zaten var. Id = ' + CAST(@ParentId AS VARCHAR);
    END

    ---------------------------------------------------------------------------------------------
    -- 1) Treasury
    ---------------------------------------------------------------------------------------------
    IF NOT EXISTS (SELECT 1 FROM dbo.FrameworkMenu WHERE MenuKey = 'TreasuryRediscountKey')
    BEGIN
        INSERT INTO dbo.FrameworkMenu
            (ApplicationName, Description, MenuKey, MenuType, Value, ForcedUrl, ForcedPermission,
             Icon, IsActive, ItemOrderId, ParentId, StateDate, StateId, StateMaker,
             ModuleName, TranslationYatirimEN, TranslationYatirimTR, TranslationKatilimEN, TranslationKatilimTR)
        VALUES
            ('Trex.WebUI', 'Treasury', 'TreasuryRediscountKey', 'ControllerAction',
             'TreasuryRediscount/Index', NULL, NULL,
             'fa-solid fa-chart-line', 1, 66, @ParentId, GETDATE(), 18, 'system',
             'General', 'Treasury', 'Treasury', 'Treasury', 'Treasury');

        PRINT '  + TreasuryRediscount menüye eklendi.';
    END
    ELSE PRINT '  = TreasuryRediscount menüde zaten var.';

    ---------------------------------------------------------------------------------------------
    -- 2) Security
    ---------------------------------------------------------------------------------------------
    IF NOT EXISTS (SELECT 1 FROM dbo.FrameworkMenu WHERE MenuKey = 'SecurityRediscountKey')
    BEGIN
        INSERT INTO dbo.FrameworkMenu
            (ApplicationName, Description, MenuKey, MenuType, Value, ForcedUrl, ForcedPermission,
             Icon, IsActive, ItemOrderId, ParentId, StateDate, StateId, StateMaker,
             ModuleName, TranslationYatirimEN, TranslationYatirimTR, TranslationKatilimEN, TranslationKatilimTR)
        VALUES
            ('Trex.WebUI', 'Security', 'SecurityRediscountKey', 'ControllerAction',
             'SecurityRediscount/Index', NULL, NULL,
             'fa-solid fa-chart-line', 1, 67, @ParentId, GETDATE(), 18, 'system',
             'General', 'Security', 'Security', 'Security', 'Security');

        PRINT '  + SecurityRediscount menüye eklendi.';
    END
    ELSE PRINT '  = SecurityRediscount menüde zaten var.';

    ---------------------------------------------------------------------------------------------
    -- 3) Investment
    ---------------------------------------------------------------------------------------------
    IF NOT EXISTS (SELECT 1 FROM dbo.FrameworkMenu WHERE MenuKey = 'InvestmentRediscountKey')
    BEGIN
        INSERT INTO dbo.FrameworkMenu
            (ApplicationName, Description, MenuKey, MenuType, Value, ForcedUrl, ForcedPermission,
             Icon, IsActive, ItemOrderId, ParentId, StateDate, StateId, StateMaker,
             ModuleName, TranslationYatirimEN, TranslationYatirimTR, TranslationKatilimEN, TranslationKatilimTR)
        VALUES
            ('Trex.WebUI', 'Investment', 'InvestmentRediscountKey', 'ControllerAction',
             'InvestmentRediscount/Index', NULL, NULL,
             'fa-solid fa-chart-line', 1, 68, @ParentId, GETDATE(), 18, 'system',
             'General', 'Investment', 'Investment', 'Investment', 'Investment');

        PRINT '  + InvestmentRediscount menüye eklendi.';
    END
    ELSE PRINT '  = InvestmentRediscount menüde zaten var.';

    COMMIT TRANSACTION;
    PRINT '✅ Manuel Rediscount menü scripti tamamlandi.';

END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    PRINT '❌ Hata olustu: ' + ERROR_MESSAGE();
    PRINT 'Satir: ' + CAST(ERROR_LINE() AS VARCHAR);
END CATCH
GO

