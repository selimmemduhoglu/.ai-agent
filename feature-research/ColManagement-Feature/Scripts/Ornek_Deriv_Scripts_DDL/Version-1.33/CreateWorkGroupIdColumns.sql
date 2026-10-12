USE NetTrexDerivSWP


BEGIN TRY
    BEGIN TRANSACTION;

    -- 1. ReceiveInvestmentAccount kontrolü
    IF COL_LENGTH('TxnTransaction', 'ReceiveInvestmentAccount') IS NOT NULL 
       AND COL_LENGTH('TxnTransaction', 'ReceiveInvestmentAccountWorkGroupId') IS NULL
    BEGIN
        ALTER TABLE TxnTransaction ADD ReceiveInvestmentAccountWorkGroupId INT NULL;
        PRINT 'ReceiveInvestmentAccountWorkGroupId eklendi.';
    END

    -- 2. ReceiveCurrentAccount kontrolü
    IF COL_LENGTH('TxnTransaction', 'ReceiveCurrentAccount') IS NOT NULL 
       AND COL_LENGTH('TxnTransaction', 'ReceiveCurrentAccountWorkGroupId') IS NULL
    BEGIN
        ALTER TABLE TxnTransaction ADD ReceiveCurrentAccountWorkGroupId INT NULL;
        PRINT 'ReceiveCurrentAccountWorkGroupId eklendi.';
    END

    -- 3. ReceiveWHTAccount kontrolü
    IF COL_LENGTH('TxnTransaction', 'ReceiveWHTAccount') IS NOT NULL 
       AND COL_LENGTH('TxnTransaction', 'ReceiveWHTAccountWorkGroupId') IS NULL
    BEGIN
        ALTER TABLE TxnTransaction ADD ReceiveWHTAccountWorkGroupId INT NULL;
        PRINT 'ReceiveWHTAccountWorkGroupId eklendi.';
    END

    -- 4. PayInvestmentAccount kontrolü
    IF COL_LENGTH('TxnTransaction', 'PayInvestmentAccount') IS NOT NULL 
       AND COL_LENGTH('TxnTransaction', 'PayInvestmentAccountWorkGroupId') IS NULL
    BEGIN
        ALTER TABLE TxnTransaction ADD PayInvestmentAccountWorkGroupId INT NULL;
        PRINT 'PayInvestmentAccountWorkGroupId eklendi.';
    END

    -- 5. PayCurrentAccount kontrolü
    IF COL_LENGTH('TxnTransaction', 'PayCurrentAccount') IS NOT NULL 
       AND COL_LENGTH('TxnTransaction', 'PayCurrentAccountWorkGroupId') IS NULL
    BEGIN
        ALTER TABLE TxnTransaction ADD PayCurrentAccountWorkGroupId INT NULL;
        PRINT 'PayCurrentAccountWorkGroupId eklendi.';
    END

    -- 6. PayWHTAccount kontrolü
    IF COL_LENGTH('TxnTransaction', 'PayWHTAccount') IS NOT NULL 
       AND COL_LENGTH('TxnTransaction', 'PayWHTAccountWorkGroupId') IS NULL
    BEGIN
        ALTER TABLE TxnTransaction ADD PayWHTAccountWorkGroupId INT NULL;
        PRINT 'PayWHTAccountWorkGroupId eklendi.';
    END

    COMMIT TRANSACTION;
    PRINT 'İşlem başarıyla tamamlandı.';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
    BEGIN
        ROLLBACK TRANSACTION;
    END

    PRINT 'Bir hata oluştu! İşlem geri alındı (Rollback).';
    PRINT 'Hata Mesajı: ' + ERROR_MESSAGE();
END CATCH;