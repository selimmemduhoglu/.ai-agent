USE NetTrexDerivSWP;
GO

/***************************************************************************************************
* This script is designed to change the data type of primary key column and add state columns
* for the PRODUCT DEFINITION
***************************************************************************************************/

BEGIN TRANSACTION;

BEGIN TRY

DECLARE 
	@StateId int=18,
    @stateDate datetime = getdate(),
    @stateMaker nvarchar(80) = N'SYSTEM';

--1.Check if this change has already been applied -------------------------------------------------------------------------------
IF COLUMNPROPERTY(OBJECT_ID('dbo.ProductDefinition'), 'Id', 'IsIdentity') = 1
BEGIN
	PRINT 'Identity has already been made.';
	RETURN;
END

--2.Dropping Primary Key Constraints-----------------------------------------------------------------------------------------------
IF OBJECT_ID('dbo.PK_ProductDefinition', 'PK') IS NOT NULL
	ALTER TABLE dbo.ProductDefinition DROP CONSTRAINT PK_ProductDefinition;

--3.Migrating tables with IDENTITY columns------------------------------------------------------------------------------------------------
CREATE TABLE [dbo].[ProductDefinition_Temp](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Code] [nvarchar](10) NULL,
	[Name] [nvarchar](50) NOT NULL,
	[ExternalMainProductCode] [nvarchar](50) NOT NULL,
	[ExternalSubProductCode] [nvarchar](50) NOT NULL,
	[AccountingMapCode] [nvarchar](50) NOT NULL,
	[Description] [nvarchar](255) NULL,
	[IsAccountNeeded] [bit] NOT NULL,
	[IsSameCurrency] [bit] NOT NULL,
	[DoPrincipalAmountTransfer] [bit] NOT NULL,
	[HasPeriodPrincipalAmountTransferType] [bit] NOT NULL,
	[IsAllowRollover] [bit] NOT NULL,
	[IsAllowLiquidation] [bit] NOT NULL,
	[PortfolioRootPath] [nvarchar](100) NULL,
	[PortfolioDefaultPath] [nvarchar](100) NULL,
	[IsEnabled] [bit] NOT NULL,
	[StateId] [int] NOT NULL,
	[StateMaker] [nvarchar](80) NOT NULL,
	[StateDate] [datetime] NOT NULL
) 

SET IDENTITY_INSERT [dbo].[ProductDefinition_Temp] ON;

INSERT INTO  [dbo].[ProductDefinition_Temp](
	[Id],[Code],[Name],[ExternalMainProductCode] ,[ExternalSubProductCode],[AccountingMapCode] ,[Description],[IsAccountNeeded],[IsSameCurrency],
	[DoPrincipalAmountTransfer],[HasPeriodPrincipalAmountTransferType] ,[IsAllowRollover],[IsAllowLiquidation],[PortfolioRootPath],[PortfolioDefaultPath],
	[IsEnabled],[StateId],[StateMaker],[StateDate]
)

SELECT
	[Id],[Code],[Name],[ExternalMainProductCode] ,[ExternalSubProductCode],[AccountingMapCode] ,[Description],[IsAccountNeeded],[IsSameCurrency],
	[DoPrincipalAmountTransfer],[HasPeriodPrincipalAmountTransferType] ,[IsAllowRollover],[IsAllowLiquidation],[PortfolioRootPath],[PortfolioDefaultPath],
	[IsEnabled],@StateId,@StateMaker,@stateDate 
FROM
	[dbo].[ProductDefinition]

SET IDENTITY_INSERT [dbo].[ProductDefinition_Temp] OFF;
DROP TABLE dbo.[ProductDefinition];
EXEC sp_rename 'dbo.ProductDefinition_Temp', 'ProductDefinition'

--4.Re-creating Primary Key Constraints-------------------------------------------------------------------------------------------------

ALTER TABLE dbo.[ProductDefinition] ADD CONSTRAINT PK_ProductDefinition PRIMARY KEY CLUSTERED (Id);

--5.Product Definition History Table------------------------------------------------------------------------------------------------
IF OBJECT_ID('dbo.ProductDefinitionHistory', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.ProductDefinitionHistory
    (
        HistoryId                            INT IDENTITY(1,1) NOT NULL
            CONSTRAINT PK_ProductDefinitionHistory PRIMARY KEY,
        Id                                   INT            NOT NULL,
        Code                                 NVARCHAR(10)   NULL,
        Name                                 NVARCHAR(50)   NOT NULL,
        ExternalMainProductCode              NVARCHAR(50)   NOT NULL,
        ExternalSubProductCode               NVARCHAR(50)   NOT NULL,
        AccountingMapCode                    NVARCHAR(50)   NOT NULL,
        Description                          NVARCHAR(255)  NULL,
        IsAccountNeeded                      BIT            NOT NULL,
        IsSameCurrency                       BIT            NOT NULL,
        DoPrincipalAmountTransfer            BIT            NOT NULL,
        HasPeriodPrincipalAmountTransferType BIT            NOT NULL,
        IsAllowRollover                      BIT            NOT NULL,
        IsAllowLiquidation                   BIT            NOT NULL,
        PortfolioRootPath                    NVARCHAR(100)  NULL,
        PortfolioDefaultPath                 NVARCHAR(100)  NULL,
        IsEnabled                            BIT            NOT NULL,
        StateId                              INT            NOT NULL,
        StateMaker                           NVARCHAR(80)   NOT NULL,
        StateDate                            DATETIME       NOT NULL
    );

    PRINT '-- dbo.ProductDefinitionHistory olusturuldu';
END

--6.Re-creating Trigger-------------------------------------------------------------------------------------------------------------
EXEC('CREATE TRIGGER [dbo].[ProductDefinitionTrigger] ON [dbo].[ProductDefinition]
		FOR INSERT, UPDATE
		AS
		INSERT INTO [dbo].[ProductDefinitionHistory] SELECT * FROM inserted;');

COMMIT TRANSACTION;
PRINT 'Script completed successfully. All changes have been committed.';

END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    PRINT 'An error occurred during execution. All changes have been rolled back.';
    
    THROW;
END CATCH;
GO