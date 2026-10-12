-- tawarruq script - 1

-- BitMask eklendi Common ve MM modüllerine

USE NetTrexCommon

GO
IF EXISTS (
    SELECT 1 
    FROM BitMask 
    WHERE SetNo = 1 
    AND RoleName = 'ELC Customer'
)
BEGIN
    UPDATE BitMask
    SET RoleName='Tawarruq Broker'
    WHERE SetNo = 1 
    AND RoleName = 'ELC Customer'
    
    PRINT 'ELC Customer Role Name i kullanılmadığı için Tawarruq Broker olarak başarıyla bir şekilde değiştirildi.';
END
ELSE
BEGIN
    PRINT 'ELC Customer Role Name BitMask tablosunda bulunamadı.';
END
GO


GO
USE NetTrexCommon

exec sp_FrameworkAddPermissionAction 'MmTransaction_Displayer', 'Trex.WebUI', 'MmTransaction/GetProductDefinition'
exec sp_FrameworkAddPermissionAction 'MmTransaction_Displayer', 'Trex.WebUI', 'MmTransaction/GetMmLogicalDate'

exec sp_FrameworkAddPermissionAction 'MmTransaction_Maker', 'Trex.WebUI', 'MmTransaction/GetProductDefinition'
exec sp_FrameworkAddPermissionAction 'MmTransaction_Maker', 'Trex.WebUI', 'MmTransaction/GetMmLogicalDate'

GO





-- NetTrexMM ------------------------------------------------------------------------------------------------------------

USE NetTrexMM

GO
IF EXISTS (
    SELECT 1 
    FROM DefBitMask 
    WHERE SetNo = 1 
    AND RoleName = 'ELC Customer'
)
BEGIN
    UPDATE DefBitMask
    SET RoleName='Tawarruq Broker'
    WHERE SetNo = 1 
    AND RoleName = 'ELC Customer'
    
    PRINT 'ELC Customer Role Name i kullanılmadığı için Tawarruq Broker olarak başarıyla bir şekilde değiştirildi.';
END
ELSE
BEGIN
    PRINT 'ELC Customer Role Name BitMask tablosunda bulunamadı.';
END
GO

USE NetTrexCommon;
GO

IF NOT EXISTS (
    SELECT 1 
    FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_NAME = 'Customer' 
    AND COLUMN_NAME = 'TawarruqContractDate'
)
BEGIN
    ALTER TABLE Customer
    ADD TawarruqContractDate date NULL;
    
    PRINT 'NetTrexCommon - Customer tablosuna TawarruqContractDate kolonu eklendi.';
END
ELSE
BEGIN
    PRINT 'NetTrexCommon - Customer tablosunda TawarruqContractDate kolonu zaten mevcut.';
END


IF NOT EXISTS (
    SELECT 1 
    FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_NAME = 'CustomerHistory' 
    AND COLUMN_NAME = 'TawarruqContractDate'
)
BEGIN
    ALTER TABLE CustomerHistory
    ADD TawarruqContractDate date NULL;
    
    PRINT 'NetTrexCommon - CustomerHistory tablosuna TawarruqContractDate kolonu başarıyla eklendi.';
END
ELSE
BEGIN
    PRINT 'NetTrexCommon - CustomerHistory tablosunda TawarruqContractDate kolonu zaten mevcut.';
END

GO

-- =============================================
-- 2. Diger DB - CusCustomer Tablosu
-- =============================================

-- TawarruqContractDate

USE NetTrexDerivSWP;
GO

IF NOT EXISTS (
    SELECT 1 
    FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_NAME = 'CusCustomer' 
    AND COLUMN_NAME = 'TawarruqContractDate'
)
BEGIN
    ALTER TABLE CusCustomer
    ADD TawarruqContractDate date NULL;
    
    PRINT 'NetTrexDerivSWP - CusCustomer tablosuna TawarruqContractDate kolonu eklendi.';
END
ELSE
BEGIN
    PRINT 'NetTrexDerivSWP - CusCustomer tablosunda TawarruqContractDate kolonu zaten mevcut.';
END
GO

USE NetTrexFI;
GO

IF NOT EXISTS (
    SELECT 1 
    FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_NAME = 'CusCustomer' 
    AND COLUMN_NAME = 'TawarruqContractDate'
)
BEGIN
    ALTER TABLE CusCustomer
    ADD TawarruqContractDate date NULL;
    
    PRINT 'NetTrexFI - CusCustomer tablosuna TawarruqContractDate kolonu eklendi.';
END
ELSE
BEGIN
    PRINT 'NetTrexFI - CusCustomer tablosunda TawarruqContractDate kolonu zaten mevcut.';
END
GO
USE NetTrexFX;
GO

IF NOT EXISTS (
    SELECT 1 
    FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_NAME = 'CusCustomer' 
    AND COLUMN_NAME = 'TawarruqContractDate'
)
BEGIN
    ALTER TABLE CusCustomer
    ADD TawarruqContractDate date NULL;
    
    PRINT 'NetTrexFX - CusCustomer tablosuna TawarruqContractDate kolonu eklendi.';
END
ELSE
BEGIN
    PRINT 'NetTrexFX - CusCustomer tablosunda TawarruqContractDate kolonu zaten mevcut.';
END
GO

USE NetTrexMM;
GO

IF NOT EXISTS (
    SELECT 1 
    FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_NAME = 'CusCustomer' 
    AND COLUMN_NAME = 'TawarruqContractDate'
)
BEGIN
    ALTER TABLE CusCustomer
    ADD TawarruqContractDate date NULL;
    
    PRINT 'NetTrexMM - CusCustomer tablosuna TawarruqContractDate kolonu eklendi.';
END
ELSE
BEGIN
    PRINT 'NetTrexMM - CusCustomer tablosunda TawarruqContractDate kolonu zaten mevcut.';
END
GO
USE NetTrexOPTFX;
GO

IF NOT EXISTS (
    SELECT 1 
    FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_NAME = 'CusCustomer' 
    AND COLUMN_NAME = 'TawarruqContractDate'
)
BEGIN
    ALTER TABLE CusCustomer
    ADD TawarruqContractDate date NULL;
    
    PRINT 'NetTrexOPTFX - CusCustomer tablosuna TawarruqContractDate kolonu eklendi.';
END
ELSE
BEGIN
    PRINT 'NetTrexOPTFX - CusCustomer tablosunda TawarruqContractDate kolonu zaten mevcut.';
END
GO

USE NetTrexMM

-- 1. TABLO KONTROLÜ
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[TxnTawarruq]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[TxnTawarruq] (
        [Id] [int] NOT NULL,
        [LogicalReference] [nvarchar](80) NOT NULL,
        [BusinessKey] [bigint] NOT NULL,
        [InputDate] [datetime] NOT NULL,
        [ValueDate] [date] NOT NULL,
        [TawarruqContractDate] [date] NOT NULL,
        [PMCCy] [nvarchar](3) NOT NULL,
        [BrokerTicketNo] [nvarchar](100) NOT NULL,
        [Location] [nvarchar](100) NOT NULL,
        [Instructions] [nvarchar](1000) NULL,
        [ExcludeProxy] [bit] NOT NULL,
        [OunceDealRate] [decimal](38, 10) NOT NULL,
        [OunceAmount] [decimal](38, 10) NOT NULL,
        [GramAmount] [decimal](38, 10) NOT NULL,
        [ExternalTxnId] [int] NOT NULL,
        [ExternalTxnCustomerId] [int] NOT NULL,
        [ExternalTxnBusinessKey] [bigint] NOT NULL,
        [ExternalTxnLogicalReference] [nvarchar](80) NOT NULL,
        [ExternalTxnPortfolioId] [int] NOT NULL,
        [ExternalTxnAmount] [decimal](38, 10) NOT NULL,
        [ExternalTxnCurrency] [nvarchar](3) NOT NULL,
        [ExternalTxnDirectionCode] [nvarchar](4) NOT NULL,
        [OurAgentRole] [int] NOT NULL,
        [OurAgentBrokerId] [int] NOT NULL,
        [OurAgentAccountNumber] [bigint] NOT NULL,
        [OurAgentAccountGLCode] [nvarchar](50) NOT NULL,
        [OurAgentAccountCcy] [nvarchar](3) NOT NULL,
        [OurAgentCurrentAccountWorkGroupId] [int] NULL,
        [TheirAgentRole] [int] NOT NULL,
        [TheirAgentBrokerId] [int] NULL,
        [TheirAgentAccountNumber] [bigint] NULL,
        [TheirAgentAccountGLCode] [nvarchar](50) NULL,
        [TheirAgentAccountCcy] [nvarchar](3) NULL,
        [TheirAgentCurrentAccountWorkGroupId] [int] NULL,
        [Trader] [nvarchar](80) NOT NULL CONSTRAINT [DF_TxnTawarruq_Trader] DEFAULT (''),
        [StateId] [bigint] NOT NULL,
        [StateMaker] [nvarchar](80) NOT NULL,
        [StateDate] [datetime] NOT NULL,
        [CreatedBy] [nvarchar](80) NOT NULL,
        [CreatedDate] [datetime] NOT NULL,
        [PreviousStateId] [bigint] NULL,
        [PreviousStateMaker] [nvarchar](80) NULL,
        [PreviousStateDate] [datetime] NULL,
        [FlowId] [bigint] NOT NULL
    );
    PRINT 'TxnTawarruq tablosu olusturuldu.';
END
ELSE
BEGIN
    PRINT 'TxnTawarruq tablosu zaten mevcut.';
END

-- 2. PRIMARY KEY KONTROLÜ
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[TxnTawarruq]') AND name = N'PK_TxnTawarruq')
BEGIN
    ALTER TABLE [dbo].[TxnTawarruq] ADD CONSTRAINT [PK_TxnTawarruq] PRIMARY KEY CLUSTERED ([Id] ASC);
    PRINT 'PK_TxnTawarruq eklendi.';
END

-- 3. UNIQUE INDEX KONTROLÜ
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[TxnTawarruq]') AND name = N'UQ_TxnTawarruq_LogicalReference')
BEGIN
    CREATE UNIQUE NONCLUSTERED INDEX [UQ_TxnTawarruq_LogicalReference] ON [dbo].[TxnTawarruq] ([LogicalReference] ASC);
    PRINT 'UQ_TxnTawarruq_LogicalReference eklendi.';
END
GO

----------------------------------------------------------------------------------------------------------------------------------------------------------------
-- DefNumberGen için
----------------------------------------------------------------------------------------------------------------------------------------------------------------

IF NOT EXISTS (SELECT 1 FROM DefNumberGen WHERE Definition = 'Txn Tawarruq Id')
BEGIN
    DECLARE @NextType INT;
    SELECT @NextType = ISNULL(MAX(EntityColumnType), 0) + 1 FROM DefNumberGen;

    INSERT INTO DefNumberGen (EntityColumnType, LastNumber, Definition, LastUpdateDate)
    VALUES (@NextType, 1000, 'Txn Tawarruq Id', GETDATE());
    
    PRINT 'DefNumberGen kaydi eklendi. Type ID: ' + CAST(@NextType AS VARCHAR(10));
END
ELSE
BEGIN
    PRINT 'DefNumberGen kaydi zaten mevcut.';
END
GO

GO
USE NetTrexMM

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[TxnTawarruqHistory]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[TxnTawarruqHistory] (
        [HistoryId] [int] IDENTITY(1,1) NOT NULL, 
        [Id] [int] NOT NULL,
        [LogicalReference] [nvarchar](80) NOT NULL,
        [BusinessKey] [bigint] NOT NULL,
        [InputDate] [datetime] NOT NULL,
        [ValueDate] [date] NOT NULL,
        [TawarruqContractDate] [date] NOT NULL,
        [PMCCy] [nvarchar](3) NOT NULL,
        [BrokerTicketNo] [nvarchar](100) NOT NULL,
        [Location] [nvarchar](100) NOT NULL,
        [Instructions] [nvarchar](1000) NULL,
        [ExcludeProxy] [bit] NOT NULL,
        [OunceDealRate] [decimal](38, 10) NOT NULL,
        [OunceAmount] [decimal](38, 10) NOT NULL,
        [GramAmount] [decimal](38, 10) NOT NULL,
        [ExternalTxnId] [int] NOT NULL,
        [ExternalTxnCustomerId] [int] NOT NULL,
        [ExternalTxnBusinessKey] [bigint] NOT NULL,
        [ExternalTxnLogicalReference] [nvarchar](80) NOT NULL,
        [ExternalTxnPortfolioId] [int] NOT NULL,
        [ExternalTxnAmount] [decimal](38, 10) NOT NULL,
        [ExternalTxnCurrency] [nvarchar](3) NOT NULL,
        [ExternalTxnDirectionCode] [nvarchar](4) NOT NULL,
        [OurAgentRole] [int] NOT NULL,
        [OurAgentBrokerId] [int] NOT NULL,
        [OurAgentAccountNumber] [bigint] NOT NULL,
        [OurAgentAccountGLCode] [nvarchar](50) NOT NULL,
        [OurAgentAccountCcy] [nvarchar](3) NOT NULL,
        [OurAgentCurrentAccountWorkGroupId] [int] NULL,
        [TheirAgentRole] [int] NOT NULL,
        [TheirAgentBrokerId] [int] NULL,
        [TheirAgentAccountNumber] [bigint] NULL,
        [TheirAgentAccountGLCode] [nvarchar](50) NULL,
        [TheirAgentAccountCcy] [nvarchar](3) NULL,
        [TheirAgentCurrentAccountWorkGroupId] [int] NULL,
        [Trader] [nvarchar](80) NOT NULL,
        [StateId] [bigint] NOT NULL,
        [StateMaker] [nvarchar](80) NOT NULL,
        [StateDate] [datetime] NOT NULL,
        [CreatedBy] [nvarchar](80) NOT NULL,
        [CreatedDate] [datetime] NOT NULL,
        [PreviousStateId] [bigint] NULL,
        [PreviousStateMaker] [nvarchar](80) NULL,
        [PreviousStateDate] [datetime] NULL,
        [FlowId] [bigint] NOT NULL,

        CONSTRAINT [PK_TxnTawarruqHistory] PRIMARY KEY CLUSTERED ([HistoryId] ASC)
    );
    PRINT 'TxnTawarruqHistory tablosu olusturuldu.';
END
GO

--- Trigger için

CREATE OR ALTER TRIGGER [dbo].[TxnTawarruqTrigger]
ON [dbo].[TxnTawarruq]
FOR INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    INSERT INTO [dbo].[TxnTawarruqHistory]
    SELECT * FROM inserted;
END
GO


USE NetTrexMM
GO

-- 1. ANA TABLOYA EKLEME
IF NOT EXISTS (
    SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_NAME = 'PrdProductDefinition' AND COLUMN_NAME = 'IsAllowTawarruq'
)
BEGIN
    ALTER TABLE PrdProductDefinition ADD IsAllowTawarruq bit NOT NULL DEFAULT 0;
    PRINT 'PrdProductDefinition tablosuna IsAllowTawarruq eklendi.';
END
ELSE
BEGIN
PRINT 'PrdProductDefinition tablosunda IsAllowTawarruq kolonu zaten mevcut.';
END
GO

-- 2. HISTORY TABLOSUNA EKLEME
IF NOT EXISTS (
    SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_NAME = 'PrdProductDefinitionHistory' AND COLUMN_NAME = 'IsAllowTawarruq'
)
BEGIN
    ALTER TABLE PrdProductDefinitionHistory ADD IsAllowTawarruq bit NULL; 
    PRINT 'PrdProductDefinitionHistory tablosuna IsAllowTawarruq eklendi.';
END
ELSE
BEGIN
PRINT 'PrdProductDefinitionHistory tablosunda IsAllowTawarruq kolonu zaten mevcut.';
END
GO


USE NetTrexCommon
GO

-- OurAgentDefaultBrokerId ekleme
exec [dbo].[sp_FrameworkAddParameter] 'FTawarruq','OurAgentDefaultBrokerId','0';

-- TheirAgentDefaultBrokerId ekleme
exec [dbo].[sp_FrameworkAddParameter] 'FTawarruq','TheirAgentDefaultBrokerId','0';

-- CurrentAccType ekleme
exec [dbo].[sp_FrameworkAddParameter] 'MM.Tawarruq','CurrentAccType','Vostro';

GO

BEGIN TRANSACTION;

BEGIN TRY

    -- =============================================
    -- 1. FlowDynamicRule: ExcludeProxy = True
    -- =============================================
    IF NOT EXISTS (SELECT 1 FROM FlowDynamicRule WHERE Name = 'ExcludeProxy = True')
    BEGIN
        INSERT INTO FlowDynamicRule (Name, [Rule], Description, StateId, StateDate, StateMaker)
        VALUES (
            'ExcludeProxy = True',
            'TxnModel.context.ExcludeProxy === true',
            'ExcludeProxy is true; single verify step applies.',
            18, GETDATE(), 'SYSTEM'
        );
        PRINT 'FlowDynamicRule (ExcludeProxy = True) basariyla eklendi. Id: ' + CAST(SCOPE_IDENTITY() AS NVARCHAR);
    END
    ELSE
        PRINT 'FlowDynamicRule (ExcludeProxy = True) zaten mevcut, atlandi.';

    DECLARE @ExcludeProxyTrueRuleId BIGINT = (SELECT Id FROM FlowDynamicRule WHERE Name = 'ExcludeProxy = True');

    -- =============================================
    -- 2. FlowDynamicRule: ExcludeProxy = False
    -- =============================================
    IF NOT EXISTS (SELECT 1 FROM FlowDynamicRule WHERE Name = 'ExcludeProxy = False')
    BEGIN
        INSERT INTO FlowDynamicRule (Name, [Rule], Description, StateId, StateDate, StateMaker)
        VALUES (
            'ExcludeProxy = False',
            'TxnModel.context.ExcludeProxy === false || !TxnModel.context.ExcludeProxy',
            'ExcludeProxy is false; double verify step applies.',
            18, GETDATE(), 'SYSTEM'
        );
        PRINT 'FlowDynamicRule (ExcludeProxy = False) basariyla eklendi. Id: ' + CAST(SCOPE_IDENTITY() AS NVARCHAR);
    END
    ELSE
        PRINT 'FlowDynamicRule (ExcludeProxy = False) zaten mevcut, atlandi.';

    DECLARE @ExcludeProxyFalseRuleId BIGINT = (SELECT Id FROM FlowDynamicRule WHERE Name = 'ExcludeProxy = False');

    -- =============================================
    -- 3. FlowState: WaitingApproval (Id = 4112)
    -- =============================================
    IF NOT EXISTS (SELECT 1 FROM FlowState WHERE Id = 4112)
    BEGIN
        INSERT INTO FlowState 
            (Id, StateName, Description, Color, StateId, StateMaker, StateDate, CreatedBy, CreatedDate,
             PreviousStateId, PreviousStateMaker, PreviousStateDate, FlowId, LastActionId, PreviousActionId)
        VALUES 
            (4112, 'WaitingApproval', 'Waiting Approval', '#e67e22',
             18, 'SYSTEM', GETDATE(), 'SYSTEM', GETDATE(),
             NULL, NULL, NULL, 0, 0, NULL);
        PRINT 'FlowState (4112 - WaitingApproval) basariyla eklendi.';
    END
    ELSE
        PRINT 'FlowState (4112) zaten mevcut, atlandi.';

    -- =============================================
    -- 4. FlowSet (Id = 30)
    -- =============================================
    IF NOT EXISTS (SELECT 1 FROM FlowSet WHERE Id = 30)
    BEGIN
        INSERT INTO FlowSet 
            (Id, Name, Description, StateId, StateMaker, StateDate, CreatedBy, CreatedDate,
             PreviousStateId, PreviousStateMaker, PreviousStateDate, FlowId, LastActionId, PreviousActionId)
        VALUES 
            (30, 'TqTransactionFlow', 'A double-verified system with a financial process.',
             18, 'SYSTEM', GETDATE(), 'SYSTEM', GETDATE(),
             16, 'SYSTEM', GETDATE(), 2013154779431780352, 16, 16);
        PRINT 'FlowSet (30 - TqTransactionFlow) basariyla eklendi.';
    END
    ELSE
        PRINT 'FlowSet (30) zaten mevcut, atlandi.';

    -- =============================================
    -- 5. FlowRequestMap
    -- =============================================
    IF NOT EXISTS (SELECT 1 FROM FlowRequestMap WHERE FlowNamespace = 'TqTransactionRequest' AND FlowSetId = 30)
    BEGIN
        INSERT INTO FlowRequestMap 
            (FlowNamespace, FlowSetId, StateId, StateMaker, StateDate, CreatedBy, CreatedDate,
             PreviousStateId, PreviousStateMaker, PreviousStateDate, FlowId, LastActionId, PreviousActionId)
        VALUES 
            ('TqTransactionRequest', 30,
             18, 'SYSTEM', GETDATE(), 'SYSTEM', GETDATE(),
             24, 'SYSTEM', GETDATE(), 2013154779431780352, 16, 4);
        PRINT 'FlowRequestMap (TqTransactionRequest) basariyla eklendi.';
    END
    ELSE
        PRINT 'FlowRequestMap zaten mevcut, atlandi.';

    -- =============================================
    -- 6. FlowTransition (17 adet)
    -- =============================================
    IF NOT EXISTS (SELECT 1 FROM FlowTransition WHERE FlowSetId = 30)
    BEGIN
        INSERT INTO FlowTransition 
            (FlowSetId, 
			FromStateId, 
			ActionId, 
			ToStateId, 
			RunPostTransaction, 
			LastActionId, 
			PreviousActionId,
             ValidationDynamicRule1, ValidationDynamicRule2, ValidationDynamicRule3, ValidationDynamicRule4,
             ValidationDynamicRule5, ValidationDynamicRule6, ValidationDynamicRule7, ValidationDynamicRule8,
             ValidationDynamicRule9, ValidationDynamicRule10)
        VALUES

            -- [ INITIAL → INPUT ]
            (30,  0,    2,  16,   1, 0, NULL, NULL,                     NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),

            -- [ INPUT STATE (16) ]
            -- Update yapılır, Input'ta kalır
            (30, 16,    4,  16,   1, 0, NULL, NULL,                     NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
            -- Direkt silinir
            (30, 16,    8,  22,   1, 0, NULL, NULL,                     NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
            -- Farklı kullanıcı reddeder → DeleteVerified
            (30, 16,   32,  22,   1, 0, NULL, 7,                        NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
            -- ExcludeProxy=True → tek adım verify → InputVerified
            (30, 16,   16,  18,   1, 0, NULL, 7, @ExcludeProxyTrueRuleId,  NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
            -- ExcludeProxy=False → çift verify 1. adım → WaitingApproval
            (30, 16,   16,  4112, 1, 0, NULL, 7, @ExcludeProxyFalseRuleId, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),

            -- [ WAITING APPROVAL (4112) ]
            -- Çift verify 2. adım → InputVerified
            (30, 4112, 16,  18,   1, 0, NULL, 7,                        NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
            -- Onay beklerken düzenleme → Edit
            (30, 4112,  4,  24,   1, 0, NULL, NULL,                     NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
            -- Onay beklerken silme talebi → Delete
            (30, 4112,  8,  20,   1, 0, NULL, NULL,                     NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
            -- Farklı kullanıcı reddeder → InputRejected
            (30, 4112, 32,  20,   1, 0, NULL, 7,                        NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),

            -- [ INPUT VERIFIED (18) ]
            -- Silme talebi açılır → Delete
            (30, 18,    8,  20,   1, 0, NULL, NULL,                     NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
            -- Düzenleme → Edit
            (30, 18,    4,  24,   1, 0, NULL, NULL,                     NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),

            -- [ DELETE STATE (20) ]
            -- Silme iptal, geri döner → InputVerified
            (30, 20,   32,  18,   1, 0, NULL, 7,                        NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
            -- Silme onaylanır → DeleteVerified
            (30, 20,   16,  22,   1, 0, NULL, 7,                        NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),

            -- [ EDIT STATE (24) ]
            -- Update yapılır, Edit'te kalır (self-loop)
            (30, 24,    4,  24,   1, 0, NULL, NULL,                     NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
            -- Silme talebi açılır → Delete
            (30, 24,    8,  20,   1, 0, NULL, NULL,                     NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
            -- Verify edilir → InputVerified (EditVerified kullanılmıyor)
            (30, 24,   16,  18,   1, 0, NULL, 7,                        NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
			-- Reject edilir → Delete (Edit reject ediliyor.)
            (30, 24,   32,  20,   1, 0, NULL, 7,                        NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);

        PRINT 'FlowTransition kayitlari (17 adet) basariyla eklendi.';
    END
    ELSE
        PRINT 'FlowTransition kayitlari zaten mevcut, atlandi.';

    COMMIT TRANSACTION;
    PRINT '============================================';
    PRINT 'Script basariyla tamamlandi.';
    PRINT '============================================';

END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT '============================================';
    PRINT 'HATA OLUSTU! Islem geri alindi (Rollback).';
    PRINT 'Hata Mesaji: ' + ERROR_MESSAGE();
    PRINT '============================================';
END CATCH