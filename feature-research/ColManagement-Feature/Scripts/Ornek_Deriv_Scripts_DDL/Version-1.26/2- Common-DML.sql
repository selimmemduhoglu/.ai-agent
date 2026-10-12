---Check Database Name
use NetTrexCommon

--PORTFOLIO DEFINITION
Declare @trPortfolioId int = 0,
@gcibPortfolioId int = 0,
@derivPortfolioId int = 0,
@derivInterbankPortfolioId int = 0;


--#region TR Portfolio
IF NOT EXISTS (SELECT 1
               FROM Portfolio
               WHERE Code = N'TR' AND [Name] = N'Turkey')
BEGIN
	INSERT INTO Portfolio (Code, [Name], ParentId, AccountingMethod, LocalCcy, CountryCode, InventoryTypeId,
		LegalVehicleId, FunctionalCcy, [Type], [Path], StateId, StateMaker, StateDate, AccountingEnable, 
		HandOffEnable, FCCLPortfolio, Module) 
	Values(N'TR', N'Turkey', NULL, 1, N'TRY', N'TR', 1, 1, N'USD', 0, N'0/', 18, N'System', GETDATE(), 0, 0, NULL, NULL)

	SET @trPortfolioId = SCOPE_IDENTITY();

	UPDATE Portfolio SET [Path] = CONCAT(N'0/', @trPortfolioId, N'/') where Id = @trPortfolioId
END
ELSE
BEGIN 
 SELECT TOP 1 @trPortfolioId = Id FROM Portfolio WHERE Code = N'TR' AND [Name] = N'Turkey'
END

IF @trPortfolioId = 0 THROW 50001, 'TR portfolio bulunamadı', 1;
--#endregion


--#region GCIB
IF NOT EXISTS (SELECT 1
               FROM Portfolio
               WHERE Code = N'GCIB' AND [Name] = N'GCIB')
BEGIN
    INSERT INTO Portfolio (Code, [Name], ParentId, AccountingMethod, LocalCcy, CountryCode, InventoryTypeId,
        LegalVehicleId, FunctionalCcy, [Type], [Path], StateId, StateMaker, StateDate, AccountingEnable, 
		HandOffEnable, FCCLPortfolio, Module) 
    Values(N'GCIB', N'GCIB', @trPortfolioId, 1, N'TRY', N'TR', 1, 1, N'USD', 1, N'0/', 18, N'System', GETDATE(), 0, 0, NULL, NULL)

	SET @gcibPortfolioId = SCOPE_IDENTITY();

	UPDATE Portfolio SET [Path] = CONCAT(N'0/', @trPortfolioId, N'/', @gcibPortfolioId,  N'/') where Id = @gcibPortfolioId
END
ELSE
BEGIN 
 SELECT TOP 1 @gcibPortfolioId = Id FROM Portfolio WHERE Code = N'GCIB' AND [Name] = N'GCIB'
END

IF @gcibPortfolioId = 0 THROW 50001, 'GCIB portfolio bulunamadı', 1;
--#endregion

--#region DRV Root
IF NOT EXISTS (SELECT 1
            FROM Portfolio
            WHERE Code = N'DRV' AND [Name] = N'DRV Root')
BEGIN
    INSERT INTO Portfolio (Code, [Name], ParentId, AccountingMethod, LocalCcy, CountryCode, InventoryTypeId
        ,LegalVehicleId, FunctionalCcy, [Type], [Path],StateId ,StateMaker,StateDate ,AccountingEnable,HandOffEnable,FCCLPortfolio, Module) 
    Values(N'DRV', N'DRV Root', @gcibPortfolioId, NULL, N'TRY', N'TR', NULL, NULL, NULL, 3, N'0/', 18, N'System', GETDATE(), 1, NULL, NULL,  N'DV')

	SET @derivPortfolioId = SCOPE_IDENTITY();

	UPDATE Portfolio SET [Path] = CONCAT(N'0/',  @trPortfolioId, N'/', @gcibPortfolioId, N'/', @derivPortfolioId, N'/') where Id = @derivPortfolioId
END
ELSE
BEGIN 
 SELECT TOP 1 @derivPortfolioId = Id FROM Portfolio WHERE Code = N'DRV' AND [Name] = N'DRV Root'
END

IF @derivPortfolioId = 0 THROW 50001, 'DRV Root portfolio bulunamadı', 1;
--#endregion

--#region DRV Interbank Root
IF NOT EXISTS (SELECT 1
            FROM Portfolio
            WHERE Code = N'DRVInterbank' AND [Name] = N'Interbank')
BEGIN
    INSERT INTO Portfolio (Code, [Name], ParentId, AccountingMethod, LocalCcy, CountryCode, InventoryTypeId
        ,LegalVehicleId, FunctionalCcy, [Type], [Path],StateId ,StateMaker,StateDate ,AccountingEnable,HandOffEnable,FCCLPortfolio, Module) 
    Values(N'DRVInterbank', N'Interbank', @derivPortfolioId, NULL, N'TRY', N'TR', NULL, NULL, NULL, 3, N'0/', 18, N'System', GETDATE(), 1, NULL, NULL,  N'DV')

	SET @derivInterbankPortfolioId = SCOPE_IDENTITY();

	UPDATE Portfolio SET [Path] = CONCAT(N'0/',  @trPortfolioId, N'/', @gcibPortfolioId, N'/', @derivPortfolioId, N'/', @derivInterbankPortfolioId, N'/') where Id = @derivInterbankPortfolioId
END
ELSE
BEGIN 
 SELECT TOP 1 @derivInterbankPortfolioId = Id FROM Portfolio WHERE Code = N'DRVInterbank' AND [Name] = N'Interbank'
END

IF @derivInterbankPortfolioId = 0 THROW 50001, 'DRV Root portfolio bulunamadı', 1;
--#endregion



--CHART DEFINITION
declare
    @stateMaker nvarchar(80) = 'SYSTEM',
    @stateId int = 18,
    @stateDate datetime = getdate(),
    @oisChartId int = 0,
    @oisZeroChartId int = 0;


--#region Chart
IF NOT EXISTS (SELECT 1
               FROM dbo.Chart
               WHERE Code = N'OIS')
    BEGIN
        INSERT INTO dbo.Chart (Name, Description, StateId, StateMaker, StateDate, Code, IsSystemDefinedChart, IsUserAnalytics,
                               IsAdHocChart)
        VALUES (N'OIS Rates', N'Overnight Indexed Swap Rates', @stateId, @stateMaker, @stateDate, N'OIS', 1, NULL, 1);
        SET @oisChartId = SCOPE_IDENTITY();
    END
else
    select @oisChartId = Id from dbo.Chart where Code = N'OIS';

IF NOT EXISTS (SELECT 1
               FROM dbo.Chart
               WHERE Code = N'OISZero')
    BEGIN
        INSERT INTO dbo.Chart (Name, Description, StateId, StateMaker, StateDate, Code, IsSystemDefinedChart, IsUserAnalytics,
                               IsAdHocChart)
        VALUES (N'OIS Zero Rates', N'Overnight Indexed Swap Zero Rates', @stateId, @stateMaker, @stateDate, N'OISZero', 1, NULL, 0);
        SET @oisZeroChartId = SCOPE_IDENTITY();
    END
else
    select @oisZeroChartId = Id from dbo.Chart where Code = N'OISZero';
--#endregion