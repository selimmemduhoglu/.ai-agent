---Check Database Name
---Check Common Database Name and Change
Use NetTrexDerivSWP
GO
BEGIN TRANSACTION;

BEGIN TRY

---BEGIN COMMON TABLOLARINI NETTREXCOMMON DATABASEDEN ALIP DOLDURMA

---CALENDAR
   TRUNCATE TABLE Calendar;
   INSERT INTO Calendar SELECT * FROM [NetTrexCommon].[dbo].[Calendar];

---CHART
   TRUNCATE TABLE Chart;
   INSERT INTO Chart ([Id], [Name] ,[Description] ,[StateId] ,[StateMaker] ,[StateDate] ,[Code] ,[IsSystemDefinedChart] ,[IsUserAnalytics],[IsAdHocChart])
   SELECT [Id], [Name] ,COALESCE([Description], [Name]) ,[StateId] ,[StateMaker] ,[StateDate] ,[Code] ,[IsSystemDefinedChart] ,[IsUserAnalytics],[IsAdHocChart]
   FROM [NetTrexCommon].[dbo].Chart;

---CURRENCY
	TRUNCATE TABLE Currency;
	INSERT INTO Currency SELECT * FROM [NetTrexCommon].[dbo].Currency;

---CURRENCY PAIR
	TRUNCATE TABLE CurrencyPair;
	INSERT INTO CurrencyPair SELECT * FROM [NetTrexCommon].[dbo].CurrencyPair;

---DATEBASIS
	TRUNCATE TABLE DateBasis;
	INSERT INTO DateBasis SELECT * FROM [NetTrexCommon].[dbo].DateBasis;

---DEFCOUNTRY
	TRUNCATE TABLE DefCountry;
	INSERT INTO DefCountry SELECT * FROM [NetTrexCommon].[dbo].Country;

--DEF LEGAL VEHICLE
	TRUNCATE TABLE DefLegalVehicle;
	INSERT INTO DefLegalVehicle SELECT * FROM [NetTrexCommon].[dbo].LegalVehicle ;

---HALFWORKING DAY
	TRUNCATE TABLE HalfWorkingDay;
	INSERT INTO HalfWorkingDay SELECT * FROM [NetTrexCommon].[dbo].HalfWorkingDay;

---INTEREST RATE
	TRUNCATE TABLE InterestRate;
	INSERT INTO InterestRate SELECT * FROM [NetTrexCommon].[dbo].InterestRate;

---INTEREST RATE DETAIL
	TRUNCATE TABLE InterestRateDetail;
	INSERT INTO InterestRateDetail SELECT * FROM [NetTrexCommon].[dbo].InterestRateDetail;

---FX RATE
   TRUNCATE TABLE FXRate;
   INSERT INTO FXRate SELECT * FROM [NetTrexCommon].[dbo].FXRate;

---FX RATE DETAIL
   TRUNCATE TABLE FXRateDetail;
   INSERT INTO FXRateDetail SELECT * FROM [NetTrexCommon].[dbo].FXRateDetail;

---POINT
	TRUNCATE TABLE Point;
	INSERT INTO Point (Id, Name, Days, IsSystem, SetNo, DayType, ListOrder, StateId, StateMaker, StateDate, PointCode)
	SELECT Id, Name, Days, IsSystem, SetNo, DayType, ListOrder, StateId, StateMaker, StateDate, PointCode FROM [NetTrexCommon].[dbo].Point;

--PRF PORTFOLIO
	TRUNCATE TABLE PrfPortfolio;
	INSERT INTO PrfPortfolio (Id, Code, [Name], ParentId, AccountingMethod, LocalCcy, CountryCode, InventoryTypeId
	      ,LegalVehicleId, FunctionalCcy, [Type], [Path],StateId ,StateMaker,StateDate ,AccountingEnable,HandOffEnable,FCCLPortfolio)
	SELECT Id, Code, [Name], ParentId, AccountingMethod, LocalCcy, CountryCode, InventoryTypeId
	      ,LegalVehicleId, FunctionalCcy, [Type], [Path],StateId ,StateMaker,StateDate ,AccountingEnable,HandOffEnable,FCCLPortfolio
	FROM [NetTrexCommon].[dbo].Portfolio;

--CUS CUSTOMER
	 TRUNCATE TABLE CusCustomer;
	 INSERT INTO CusCustomer ([Id],[ShortName],[Name],[Ccy],[BranchId],[SIC],[BusinessSegmentCode],[CustomerRoleFlags],[ActiveFromDate]
      ,[ActiveToDate],[Language],[Attention],[AccountOfficer],[Address],[City],[AccountNumber],[CountryCode],[FaxNo],[Email],[SWIFTID]
      ,[PreferenceFlags],[TaxCode],[TaxOfficeCode],[LastImportDate],[ReportTypeFlags],[BankCode],[BankId],[SSN],[Block],[StateId],[StateMaker]
      ,[StateDate],[IBAN],[LEICode],[ExternalCustomerId],[SectorOffShore],[InvestorTypeId],[MKKNo],[SuitabilityTestScore],[IsFinancialInstitution]
      ,[CustomerTypeId],[SectorTypeId],[CorporateTypeId],[CorporateDetailTypeId],[BaseNo]) 
	  SELECT [Id],[ShortName],[Name],[Ccy],[BranchId],[SIC],[BusinessSegmentCode],[CustomerRoleFlags],[ActiveFromDate]
      ,[ActiveToDate],[Language],[Attention],[AccountOfficer],[Address],[City],[AccountNumber],[CountryCode],[FaxNo],[Email],[SWIFTID]
      ,[PreferenceFlags],[TaxCode],[TaxOfficeCode],[LastImportDate],[ReportTypeFlags],[BankCode],[BankId],[SSN],[Block],[StateId],[StateMaker]
      ,[StateDate],[IBAN],[LEICode],[ExternalCustomerId],[SectorOffShore],[InvestorTypeId],[MKKNo],[SuitabilityTestScore],[IsFinancialInstitution]
      ,[CustomerTypeId],[SectorTypeId],[CorporateTypeId],[CorporateDetailTypeId],[BaseNo] FROM [NetTrexCommon].[dbo].[Customer];

---END COMMON TABLOLARINI NETTREXCOMMON DATABASEDEN ALIP DOLDURMA

---BATCH SET
    INSERT INTO [dbo].[BatchSet] ([Id],[Name],[Description],[StateId],[StateMaker],[StateDate])
    VALUES  (1, N'EOD', N'Derivative Swap EOD', 18, N'System', GETDATE()),
			(2, N'BOD', N'Derivative Swap BOD', 18, N'System', GETDATE());

---BATCH ITEM
    INSERT INTO [dbo].BatchItem (Id,ItemOrder,ItemID,Name,Severity,State,ParentItemNo,BatchSetId,IsTransactional,StateId,StateMaker,StateDate) VALUES
	 (1,1,N'Composite',N'DerivSWP EndOfDay',0,1,0,1,0,18,N'SYSTEM',GETDATE()),
	 (2,1,N'Composite',N'Pre Eod',0,0,1,1,0,18,N'SYSTEM',GETDATE()),
	 (3,2,N'Composite',N'Eod',1,1,1,1,0,18,N'SYSTEM',GETDATE()),
	 (4,3,N'Composite',N'Post Eod',0,1,1,1,0,18,N'SYSTEM',GETDATE()),
	 (5,1,N'NetTrex.DerivSwp.Batch.Items.Common.DateTimeCheckBatchItem',N'Date Time Check',0,1,2,1,0,18,N'SYSTEM',GETDATE()),
	 (6,1,N'NetTrex.DerivSwp.Batch.Items.EndOfDay.LogicalDateUpdateBatchItem',N'Logical Date Update',1,1,4,1,0,18,N'SYSTEM',GETDATE()),
	 (7,3,N'NetTrex.DerivSwp.Batch.Items.EndOfDay.RevaluationBatchItem',N'Revaluation',1,1,3,1,0,18,N'SYSTEM',GETDATE()),
	 (8,1,N'NetTrex.DerivSwp.Batch.Items.EndOfDay.ReverseBatchItem',N'Reverse',1,1,3,1,0,18,N'SYSTEM',GETDATE()),
	 (9,1,N'Composite',N'DerivSWP BeginOfDay',0,1,0,2,0,18,N'SYSTEM',GETDATE()),
	 (10,1,N'Composite',N'Pre Bod',0,1,9,2,0,18,N'SYSTEM',GETDATE()),
	 (11,2,N'Composite',N'Bod',1,1,9,2,0,18,N'SYSTEM',GETDATE()),
	 (12,1,N'NetTrex.DerivSwp.Batch.Items.Common.DateTimeCheckBatchItem',N'Date Time Check',0,1,10,2,0,18,N'SYSTEM',GETDATE()),
	 (13,1,N'NetTrex.DerivSwp.Batch.Items.BeginOfDay.CashFlowReGenerateBatchItem',N'CashFlow Regenerate',1,1,11,2,0,18,N'SYSTEM',GETDATE()),
	 (14,1,N'NetTrex.DerivSwp.Batch.Items.BeginOfDay.ForwardBatchItem',N'Forward',1,1,11,2,0,18,N'SYSTEM',GETDATE()),
	 (15,2,N'NetTrex.DerivSwp.Batch.Items.BeginOfDay.ReverseBatchItem',N'Reverse',1,1,11,2,0,18,N'SYSTEM',GETDATE()),
	 (16,3,N'NetTrex.DerivSwp.Batch.Items.BeginOfDay.PaymentBatchItem',N'Payment',1,1,11,2,0,18,N'SYSTEM',GETDATE()),
	 (17,4,N'NetTrex.DerivSwp.Batch.Items.BeginOfDay.MaturationBatchItem',N'Matured',1,1,11,2,0,18,N'SYSTEM',GETDATE());

---DEF NUMBER GEN
   TRUNCATE TABLE DefNumberGen;
   INSERT INTO dbo.DefNumberGen (EntityColumnType, LastNumber, Definition, LastUpdateDate)
   VALUES (1, 0, N'Txn_Id', GETDATE()),
          (2, 0, N'AccEntryMain_Id', GETDATE()),
          (3, 0, N'AccEntry_Id', GETDATE()),
          (4, 0, N'accEngineGeneratedAccountRule_Id', GETDATE());

--DEF JOB CRON
   TRUNCATE TABLE DefJobCron;
   INSERT INTO dbo.DefJobCron ([Key], Value, StateId, StateMaker, StateDate)
   VALUES (N'DerivSwpEod', N'0 00 19 * * 1-5', 18, N'SYSTEM',  GETDATE()),
          (N'DerivSwpBod', N'0 00 5 * * 1-5', 18, N'SYSTEM',  GETDATE());

---FLOW TYPE
    TRUNCATE TABLE FlowType;
	INSERT INTO dbo.FlowType (Id, Code, Name, Description, IsEnabled)
	VALUES (1, N'Principal', N'Principal', N'Principal', 1),
		   (2, N'Interest', N'Interest', N'Interest', 1),
	       (3, N'Fee', N'Fee', N'Fee', 1);

---INTEREST METHOD
    TRUNCATE TABLE InterestMethod;
	INSERT INTO dbo.InterestMethod (Id, Code, Name, Description, IsEnabled)
    VALUES (1, N'SimpleInterest', N'SimpleInterest', 'CashFlow hesaplamaları linear olarak hesaplanır', 1),
           (2, N'CompoundAverage', N'CompoundAverage', 'CashFlow hesaplamaları compound olarak hesaplanır', 1);

---INTEREST METHOD FREQUENCY
     TRUNCATE TABLE InterestMethodFrequency;
     INSERT INTO dbo.InterestMethodFrequency (Id, Code, Name, Description, IsEnabled)
     VALUES (1, N'Annual', N'Annual', N'Annual', 1),
		    (2, N'Semi-Annual', N'Semi-Annual', N'Semi-Annual', 1),
		    (3, N'Quarterly', N'Quarterly', N'Quarterly', 1),
		    (4, N'Monthly', N'Monthly', N'Monthly', 1),
		    (5, N'Weekly', N'Weekly', N'Weekly', 1),
		    (6, N'Daily', N'Daily', N'Daily', 1);

---LIQUIDATION TYPE
	  TRUNCATE TABLE LiquidationType;
	  INSERT INTO dbo.LiquidationType (Code, Name, Description, IsEnabled)
	  VALUES (N'Complete', N'Complete', N'Complete', 1),
			 (N'Partial', N'Partial', N'Partial', 1);

---PAYMENT FREQUENCY
      TRUNCATE TABLE PaymentFrequency;
	  INSERT INTO dbo.PaymentFrequency (Id, Code, Name, Description, IsEnabled)
      VALUES (1, N'Annual', N'Annual', N'Annual', 1),
      (2, N'Semi-Annual', N'Semi-Annual', N'Semi-Annual', 1),
      (3, N'Quarterly', N'Quarterly', N'Quarterly', 1),
      (4, N'Monthly', N'Monthly', N'Monthly', 1);

---PRODUCT DEFINITION
    TRUNCATE TABLE ProductDefinition;
     DECLARE @derivRootPortfolioPath nvarchar(250)  = '',
     @derivPortfolioPath nvarchar(250)  = '';

    SELECT TOP 1 @derivRootPortfolioPath = [Path] from PrfPortfolio where Code = 'DRV' and [Name] = 'DRV Root';
    SELECT TOP 1 @derivPortfolioPath = [Path] from PrfPortfolio where Code = 'DRVInterbank' and [Name] = 'Interbank';

    ---IRS PRODUCT
    IF NOT EXISTS (SELECT 1 FROM dbo.ProductDefinition WHERE Code = N'IRS')
    BEGIN
        INSERT INTO dbo.ProductDefinition (Id, Code, Name, ExternalMainProductCode, ExternalSubProductCode, AccountingMapCode, Description,
        IsAccountNeeded, IsSameCurrency, DoPrincipalAmountTransfer, HasPeriodPrincipalAmountTransferType, IsAllowRollover, IsAllowLiquidation,
        PortfolioRootPath, PortfolioDefaultPath, IsEnabled)
        VALUES (1, N'IRS', N'Interest Rate Swap', N'DV', N'IRS', N'IRS', '', 0, 1, 1, 0, 0, 0, @derivRootPortfolioPath, @derivPortfolioPath, 1);
    END

    ---CCS PRODUCT
    IF NOT EXISTS (SELECT 1 FROM dbo.ProductDefinition WHERE Code = N'CCS')
	BEGIN
		INSERT INTO dbo.ProductDefinition (Id, Code, Name, ExternalMainProductCode, ExternalSubProductCode, AccountingMapCode, Description,
			 IsAccountNeeded, IsSameCurrency, DoPrincipalAmountTransfer, HasPeriodPrincipalAmountTransferType, IsAllowRollover, IsAllowLiquidation,
			 PortfolioRootPath, PortfolioDefaultPath, IsEnabled)
			 VALUES (2, N'CCS', N'Cross Currency Rate Swap', N'DV', N'CCS', N'CCS', N'Cross Currency Rate Swap', 0, 0, 1, 1, 0, 0, @derivRootPortfolioPath, @derivPortfolioPath, 1);
	END

---RATE ADJUSTMENT TYPE
    TRUNCATE TABLE RateAdjustmentType;
    INSERT INTO dbo.RateAdjustmentType (Id, Code, Name, Description, IsEnabled)
    VALUES (1, N'Lookback', N'Lookback', N'Faiz, belirtilen lookback günü kadar önceki günün oranı dikkate alınarak hesaplanması. Lookback günü 3 olarak belirlenmiş ise, günlük getiri hesaplamasında örn. 4 Şubatın getirisi için 1 Şubattaki RFR oranı kullanılır.', 1),
		   (2, N'Lockout', N'Lockout', N'Lockout günü kadar vade tarihinden önceki oranın cut-off rate olarak belirlenip tekrarlanması. Vade tarihi 1 Şubat, lockout gün sayısı 3 olarak belirlenmiş ise, 30 Ocak ve 1 Şubat tarihleri arası getiri hesaplaması yapılırken 29 Ocak tarihindeki oran sabit tutulur.', 1);

---RATE TYPE
    TRUNCATE TABLE RateType;
	INSERT INTO dbo.RateType (Id, Code, Name, Description, IsEnabled)
    VALUES (1, N'Fixed', N'Fixed', N'Fixed Rate', 1),
		   (2, N'Floating', N'Floating', N'Floating Rate', 1);

     COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    PRINT 'rollback';
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;
    PRINT ERROR_MESSAGE();
    throw;
END CATCH;