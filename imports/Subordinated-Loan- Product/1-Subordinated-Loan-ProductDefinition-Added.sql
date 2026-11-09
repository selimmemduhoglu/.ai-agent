USE [NetTrexMM];
GO

IF NOT EXISTS (SELECT 1 FROM dbo.LogicalReferenceType WHERE Id = 10 OR Code = N'SL')
BEGIN
    INSERT INTO dbo.LogicalReferenceType (Id, [Name], Code, [Description], IsEnabled)
    VALUES (10, N'Subordinated-Loan', N'SL', N'Subordinated-Loan Reference', 1);
END
GO

DECLARE @NewOrder INT = (SELECT ISNULL(MAX([Order]), 0) + 5 FROM dbo.PrdProductDefinition);

IF NOT EXISTS (SELECT 1 FROM dbo.PrdProductDefinition WHERE Id = 15 OR Code = N'Subordinated-Loan')
BEGIN
    INSERT INTO dbo.PrdProductDefinition (
        Id, Code, [Name], AccountingMapCode, MainProductCode, ExternalMainProductCode,
        ExternalSubProductCode, UseFundSource, UseSubFundSource, UseOnUnitValue,
        IsBorrowing, IsPlacement, IsAccountNeeded, IsAllowRollover, IsAllowBrokerage,
        IsMultiplePayment, IsTaxApplicable, IsUseTxnGLCode, IsCollateralized, IsIntraBank,
        IsSameDay, IsZeroRate, IsGenerateFWDAccounting, IsDefaultProduction,
        AccountSelectionTypeId, AccountingCalculationMethodTypeId, [Order], IsEnabled,
        StateId, StateDate, LogicalReferenceTypeId, IsMarketCommissionApplicable,
        IsAllowTawarruq, StateMaker
    )
    VALUES (
        15, N'Subordinated-Loan', N'Subordinated-Loan', N'LOAN', N'MM', N'MM',
        N'MLN', 0, 0, 0,
        1, 1, 1, 1, 0,
        0, 1, 1, 0, 0,
        0, 0, 0, 0,
        2, 2, @NewOrder, 1,
        18, GETDATE(), 10, 0,
        1, N'SYSTEM'
    );
END
GO


GO

BEGIN TRANSACTION;

BEGIN TRY
    DECLARE @ProductCode NVARCHAR(50) = N'Subordinated-Loan';
    DECLARE @MarketCode NVARCHAR(10) = N'OTC';
    DECLARE @ProductId INT;
    DECLARE @NewMarketMapId INT;

    -- 1. Ürün Id'sini al
    SELECT @ProductId = Id 
    FROM dbo.PrdProductDefinition 
    WHERE Code = @ProductCode OR Id = 15;

    IF @ProductId IS NULL
    BEGIN
        RAISERROR(N'Ürün (Subordinated-Loan) bulunamadı!', 16, 1);
    END

    -- 2. Kayıt daha önce eklenmemişse işlemi yap
    IF NOT EXISTS (
        SELECT 1 
        FROM dbo.PrdProductDefinitionMarketMap 
        WHERE ProductDefinitionId = @ProductId AND MarketCode = @MarketCode
    )
    BEGIN
        -- DefNumberGen tablosunda LastNumber'ı 1 artır ve yeni Id'yi değişkene ata
        UPDATE dbo.DefNumberGen
        SET @NewMarketMapId = LastNumber = LastNumber + 1,
            LastUpdateDate = GETDATE()
        WHERE Definition = N'Product Definition Market Map Id';
    

        -- PrdProductDefinitionMarketMap tablosuna yeni kaydı ekle
        INSERT INTO dbo.PrdProductDefinitionMarketMap (
            Id,
            ProductDefinitionId,
            MarketCode,
            [Order],
            IsDefaultMarket,
            IsEnabled
        )
        VALUES (
            @NewMarketMapId,
            @ProductId,
            @MarketCode,
            10,  -- Order
            1,   -- IsDefaultMarket
            1    -- IsEnabled
        );

        PRINT CONCAT(N'Kayıt başarıyla eklendi. Yeni MarketMap Id: ', @NewMarketMapId);
    END
    ELSE
    BEGIN
        PRINT N'Bu ürün için OTC market kaydı zaten mevcut.';
    END

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    THROW;
END CATCH;
GO
