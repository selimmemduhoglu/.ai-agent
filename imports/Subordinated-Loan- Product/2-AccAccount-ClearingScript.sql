USE NetTrexAcc


BEGIN TRANSACTION;
BEGIN TRY

    PRINT 'BRWPLC1 Dynamic Script içerik temizliği başlıyor...';
    PRINT '(Sadece AccAccountMap siliniyor, diğer tüm yapı korunuyor)';

    -- Sadece AccAccountMap temizle
    DELETE FROM dbo.AccAccountMap 
    WHERE Path LIKE 'TREX/BRWPLC1%';
    PRINT 'AccAccountMap silindi: ' + CAST(@@ROWCOUNT AS VARCHAR) + ' kayıt';

    COMMIT TRANSACTION;
    PRINT '✅ Temizlik tamamlandı. Dynamic Script (Script 2) tekrar çalıştırılabilir.';

END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    PRINT '❌ Hata oluştu: ' + ERROR_MESSAGE();
    PRINT 'Satır: ' + CAST(ERROR_LINE() AS VARCHAR);
END CATCH

