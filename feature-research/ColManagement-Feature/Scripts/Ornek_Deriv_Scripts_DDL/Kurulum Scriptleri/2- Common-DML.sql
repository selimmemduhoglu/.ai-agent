---Check Database Name
use NetTrexCommon

--PORTFOLIO DEFINITION
Declare @trPortfolioId int = 0,
@gcibPortfolioId int = 0,
@derivPortfolioId int = 0,
@derivInterbankPortfolioId int = 0;

DECLARE @dailyCheckBatchItemId int = 0;
DECLARE @derivValidationBatchItemId int = 0;
DECLARE @lastBatchItemId int = 1;
DECLARE @batchSetId int = 0;
DECLARE @stateId int = 18;
DECLARE @stateMaker nvarchar(80) = 'system';
DECLARE @stateDate datetime = GETDATE();

  --Get DailyCheck Id
  SELECT TOP 1 @dailyCheckBatchItemId = Id, @batchSetId = BatchSetId from [BatchItem] where [Name] = N'DailyCheck'
  IF @dailyCheckBatchItemId = 0
	throw 500001, 'DailyCheck Batch Item is not founded. Please check BatchItem table', 1;

  SELECT TOP 1 @lastBatchItemId = Id + 1 from [BatchItem]  order by Id desc;  

  --#region Batch Item Deriv Validation
  IF NOT EXISTS (SELECT 1
               FROM [BatchItem]
               WHERE [Name] = N'Deriv Validation' and ItemID = N'Composite')

  BEGIN
  INSERT INTO [dbo].[BatchItem]
           ([Id]
           ,[ItemOrder]
           ,[ItemID]
           ,[Name]
           ,[Severity]
           ,[State]
           ,[ParentItemNo]
           ,[BatchSetId]
           ,[IsTransactional]
           ,[StateId]
           ,[StateMaker]
           ,[StateDate])
     VALUES
           (@lastBatchItemId
           ,1
           ,N'Composite'
           ,N'Deriv Validation'
           ,0
           ,1
           ,@dailyCheckBatchItemId
           ,@batchSetId
           ,0
           ,@stateId
           ,@stateMaker
           ,@stateDate)
	END;

   SELECT @derivValidationBatchItemId = Id FROM [BatchItem] WHERE [Name] = N'Deriv Validation' and ItemID = N'Composite';
  --#endregion

   --#region Batch Item ValidateDerivTransactionsBatchItem
   SELECT TOP 1 @lastBatchItemId = Id + 1 from [BatchItem]  order by Id desc;  

  IF NOT EXISTS (SELECT 1
               FROM [BatchItem]
               WHERE [Name] = N'ValidateDerivTransactionsBatchItem')

  BEGIN
  INSERT INTO [dbo].[BatchItem]
           ([Id]
           ,[ItemOrder]
           ,[ItemID]
           ,[Name]
           ,[Severity]
           ,[State]
           ,[ParentItemNo]
           ,[BatchSetId]
           ,[IsTransactional]
           ,[StateId]
           ,[StateMaker]
           ,[StateDate])
     VALUES
           (@lastBatchItemId
           ,25
           ,N'NetTrex.Common.Batch.Business.HangfireJobs.DailyCheck.Validation.ValidateDerivTransactionsBatchItem'
           ,N'ValidateDerivTransactionsBatchItem'
           ,0
           ,1
           ,@derivValidationBatchItemId
           ,@batchSetId
           ,0
           ,@stateId
           ,@stateMaker
           ,@stateDate)
	END;
  --#endregion


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

IF NOT EXISTS (SELECT 1
               FROM DefCountMonitoring
               WHERE ScreenName = N'DerivSwp Transactions')
BEGIN
    DECLARE @lastID int;
	SELECT top 1 @lastID = Id from DefCountMonitoring order by Id desc
    INSERT INTO DefCountMonitoring ([Id], [ScreenName], [Query], [ScreenUrl], [Connection], [DefaultUnverifiedStateId], [State])
    VALUES (@lastID + 1, N'DerivSwp Transactions', N'EXEC sp_UnverifiedDataCount_TxnDerivSwp',
			N'DerivSwp/Index', N'Connection', 3, 1);
END;

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT 1 
				FROM INFORMATION_SCHEMA.ROUTINES 
				WHERE ROUTINE_TYPE = 'PROCEDURE' 
				  AND ROUTINE_SCHEMA = 'dbo' 
				  AND ROUTINE_NAME = 'sp_UnverifiedDataCount_TxnDerivSwp')
BEGIN
	EXEC('
		CREATE   PROCEDURE [dbo].[sp_UnverifiedDataCount_TxnDerivSwp]
		AS
		BEGIN
			SET NOCOUNT ON;
			DECLARE @UnverifiedDataCount INT;
			SELECT @UnverifiedDataCount = COUNT(*)
			FROM NetTrexDerivSWP.dbo.TxnTransaction tt
			WHERE (tt.StateId & 2) <> 2
			  AND (tt.StateId & 1) <> 1;
			SELECT @UnverifiedDataCount AS UnverifiedDataCount;
		END'
	)
END;