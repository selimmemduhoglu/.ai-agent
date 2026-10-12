---Check Database Name
Use NetTrexDerivSWP
GO
BEGIN TRANSACTION;

BEGIN TRY 

--#region PAYMENT FREQUENCY
    UPDATE PaymentFrequency SET [Month] = 12, [Period] = 1 WHERE [Code] = N'Annual';
    UPDATE PaymentFrequency SET [Month] = 6, [Period] = 2 WHERE [Code] = N'Semi-Annual';
    UPDATE PaymentFrequency SET [Month] = 3, [Period] = 4 WHERE [Code] = N'Quarterly';
    UPDATE PaymentFrequency SET [Month] = 1, [Period] = 12 WHERE [Code] = N'Monthly';
--#endregion

--#region SETTLEMENT TYPE
IF NOT EXISTS (SELECT * FROM [dbo].[SettlementType])
BEGIN
	INSERT INTO [dbo].[SettlementType] ([Id],[Code],[Name],[Description],[ExternalCode],[IsEnabled])
	VALUES
		(1, 'Gross', 'Gross Settlement', NULL, 'Single', 1),
		(2, 'Netting', 'Net Settlement', NULL, 'Bulk', 1)
END;
--#endregion

--#region PAYMENT INSTRUCTION TYPE
IF NOT EXISTS (SELECT * FROM [dbo].[PaymentInstructionType])
BEGIN
	INSERT INTO [dbo].[PaymentInstructionType]([Id],[Code],[Name],[Description],[ExternalCode],[IsEnabled])
	VALUES
		(1, 'B2B', 'Bank to Bank', NULL, 'BankToBank', 1),
		(2, 'A2A', 'Account to Account', NULL, 'AccountToAccountNostro', 1),
		(3, 'Vostro', 'Vostro Account', NULL, 'AccountToAccountVostro', 1)
END;
--#endregion

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    PRINT 'rollback';
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;
    PRINT ERROR_MESSAGE();
    throw;
END CATCH;