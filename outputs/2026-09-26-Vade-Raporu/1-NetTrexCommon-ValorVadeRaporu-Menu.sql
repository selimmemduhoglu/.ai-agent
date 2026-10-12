--=============================================================================================
   --Valor-Vade Raporu (ValueMaturityReport) - Script 1 / MENU (Guncel Sema: ModuleName + Translation kolonlari)
   --Ekran: Treasy.Common.UI  ValueMaturityReport/Index  (Money Market, Interbank Loan, FX/PM Swap)
   --Yer : Reports (ReportsKey) altinda, Upcoming Transactions (30) ile Tax (35) arasi -> ItemOrderId 31
---------------------------------------------------------------------------------------------

USE NetTrexCommon;
GO

BEGIN TRANSACTION;
BEGIN TRY

    DECLARE @ParentId INT;

    PRINT 'Valor-Vade Raporu menu kaydi ekleniyor...';

    ---------------------------------------------------------------------------------------------
    -- 0) Parent: Reports
    ---------------------------------------------------------------------------------------------
    SELECT @ParentId = Id FROM dbo.FrameworkMenu WHERE MenuKey = 'ReportsKey';

    IF @ParentId IS NULL
    BEGIN
        RAISERROR('ReportsKey menude bulunamadi. Menu eklenmedi.', 16, 1);
    END

    PRINT '  = Reports parent bulundu. Id = ' + CAST(@ParentId AS VARCHAR);

    ---------------------------------------------------------------------------------------------
    -- 1) Valor-Vade Raporu
    ---------------------------------------------------------------------------------------------
    IF NOT EXISTS (SELECT 1 FROM dbo.FrameworkMenu WHERE MenuKey = 'ValueMaturityReportKey')
    BEGIN
        INSERT INTO dbo.FrameworkMenu
            (ApplicationName, Description, MenuKey, MenuType, Value, ForcedUrl, ForcedPermission,
             Icon, IsActive, ItemOrderId, ParentId, StateDate, StateId, StateMaker,
             ModuleName, TranslationYatirimEN, TranslationYatirimTR, TranslationKatilimEN, TranslationKatilimTR)
        VALUES
            ('Trex.WebUI', 'Value Maturity Report', 'ValueMaturityReportKey', 'ControllerAction',
             'ValueMaturityReport/Index', NULL, NULL,
             'fa-regular fa-rectangle-list', 1, 31, @ParentId, GETDATE(), 18, 'system',
             'General', 'Value Maturity Report', N'Val' + NCHAR(246) + N'r-Vade Raporu', 'Value Maturity Report', N'Val' + NCHAR(246) + N'r-Vade Raporu');

        PRINT '  + ValueMaturityReport menuye eklendi. Id = ' + CAST(SCOPE_IDENTITY() AS VARCHAR);
    END
    ELSE PRINT '  = ValueMaturityReport menude zaten var.';

    COMMIT TRANSACTION;
    PRINT 'Valor-Vade Raporu menu scripti tamamlandi.';

END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    PRINT 'Hata olustu: ' + ERROR_MESSAGE();
    PRINT 'Satir: ' + CAST(ERROR_LINE() AS VARCHAR);
END CATCH
GO

-- Kontrol (1 satir beklenir, Parent = Reports)
SELECT m.Id, m.ApplicationName, m.MenuKey, m.Description, m.Value, m.ModuleName, m.ItemOrderId, p.Description AS Parent
FROM dbo.FrameworkMenu m
LEFT JOIN dbo.FrameworkMenu p ON p.Id = m.ParentId
WHERE m.MenuKey = 'ValueMaturityReportKey';
GO

-- Not: menu Redis'te ModuleMenu:{UserId} altinda 8 saat cache'li; script sonrasi ModuleMenu:* temizlenmeli.
