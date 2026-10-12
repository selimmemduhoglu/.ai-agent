---Check Database Name
Use NetTrexCommon

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

--FRAMEWORK PERMISSION ACTION
exec sp_FrameworkAddPermissionAction 'DerivSwp_Displayer', 'Trex.WebUI','DerivSwp/SelectCustomerAccounts';
exec sp_FrameworkAddPermissionAction 'DerivSwp_Displayer', 'Trex.WebUI', 'DerivSwp/GetCompoundCashFlow';
exec sp_FrameworkAddPermissionAction 'DerivSwp_Maker', 'Trex.WebUI', 'DerivSwp/GetCompoundCashFlow';
exec sp_FrameworkAddPermissionAction 'DerivSwp_Checker', 'Trex.WebUI', 'DerivSwp/GetCompoundCashFlow';