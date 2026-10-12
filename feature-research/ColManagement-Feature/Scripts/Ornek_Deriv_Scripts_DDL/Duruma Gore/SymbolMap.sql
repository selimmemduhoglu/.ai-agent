use [NetTrexCommon]
GO
SET XACT_ABORT ON;

BEGIN TRANSACTION;

BEGIN TRY
    declare @stateMaker nvarchar(80) = 'SYSTEM',@stateDate datetime = getdate(),@stateId int = 18
    declare @dataSourceId int = 0,@moduleId int = 0,@symbolTypeOisId int = 0,@symbolTypeOisZeroId int = 0,@lastId int = 0
    select @dataSourceId = Id from dbo.RateEngineDataSource where Code = N'Bloomberg' and IsEnabled = 1

    IF @dataSourceId = 0
        THROW 51000 ,'Data Source => Bloomberg Not Found',1

    PRINT CONCAT('Data Source Bloomberg Id => ', @dataSourceId);


    select @moduleId = Id from dbo.RateEngineModule where Code = N'Deposit' and IsEnabled = 1

    IF @moduleId = 0
        THROW 51000 ,'Module => Deposit Not Found',1

    PRINT CONCAT('Module Deposit Id => ', @moduleId);

    select top 1 @lastId = Id from dbo.RateEngineSymbolType order by Id desc
    select @lastId = @lastId + 1

    IF NOT EXISTS (SELECT 1 FROM dbo.RateEngineSymbolType WHERE [Code] = N'OIS')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolType
            ([Id], [Code], [Name], [IsEnabled], [StateId], [StateMaker], [StateDate])
            VALUES (@lastId, N'OIS ', N'Overnight Indexed Swap', 1, @stateId, @stateMaker, @stateDate);
            select @symbolTypeOisId = @lastId
            select @lastId = @lastId + 1
        END
    ELSE
        BEGIN
            select top 1 @symbolTypeOisId = Id FROM dbo.RateEngineSymbolType WHERE [Code] = N'OIS'
        END

    PRINT CONCAT('OIS Id ', @symbolTypeOisId);

    IF NOT EXISTS (SELECT 1 FROM dbo.RateEngineSymbolType WHERE [Code] = N'OISZero')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolType
            ([Id], [Code], [Name], [IsEnabled], [StateId], [StateMaker], [StateDate])
            VALUES (@lastId, N'OISZero', N'Overnight Indexed Swap Zero', 1, @stateId, @stateMaker, @stateDate);
            select @symbolTypeOisZeroId = @lastId
        END
    ELSE
        BEGIN
            select top 1 @symbolTypeOisZeroId = Id FROM dbo.RateEngineSymbolType WHERE [Code] = N'OISZero'
        END

    PRINT CONCAT('OIS Zero Id ', @symbolTypeOisZeroId);


    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisId
                     AND SymbolCode = N'SOFRRATE Index'
                     AND SymbolName = N'USD SOFRON')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId, ModuleId, SymbolTypeId,
             SymbolCode, SymbolName,
             SymbolGroup, Description, IsEnabled,
             CcyPair, AlternateSymbol,
             StateMaker, StateDate, StateId)
            VALUES (@dataSourceId, @moduleId, @symbolTypeOisId,
                    N'SOFRRATE Index', N'USD SOFRON',
                    '', '', 1,
                    '0', 0,
                    @stateMaker, @stateDate, @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisId
                     AND SymbolCode = N'USOSFR1Z BGN Curncy'
                     AND SymbolName = N'USD SOFR1W')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId, ModuleId, SymbolTypeId,
             SymbolCode, SymbolName,
             SymbolGroup, Description, IsEnabled,
             CcyPair, AlternateSymbol,
             StateMaker, StateDate, StateId)
            VALUES (@dataSourceId, @moduleId, @symbolTypeOisId,
                    N'USOSFR1Z BGN Curncy', N'USD SOFR1W',
                    '', '', 1,
                    '0', 0,
                    @stateMaker, @stateDate, @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisId
                     AND SymbolCode = N'USOSFR2Z BGN Curncy'
                     AND SymbolName = N'USD SOFR2W')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId, ModuleId, SymbolTypeId,
             SymbolCode, SymbolName,
             SymbolGroup, Description, IsEnabled,
             CcyPair, AlternateSymbol,
             StateMaker, StateDate, StateId)
            VALUES (@dataSourceId, @moduleId, @symbolTypeOisId,
                    N'USOSFR2Z BGN Curncy', N'USD SOFR2W',
                    '', '', 1,
                    '0', 0,
                    @stateMaker, @stateDate, @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisId
                     AND SymbolCode = N'USOSFR3Z BGN Curncy'
                     AND SymbolName = N'USD SOFR3W')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId, ModuleId, SymbolTypeId,
             SymbolCode, SymbolName,
             SymbolGroup, Description, IsEnabled,
             CcyPair, AlternateSymbol,
             StateMaker, StateDate, StateId)
            VALUES (@dataSourceId, @moduleId, @symbolTypeOisId,
                    N'USOSFR3Z BGN Curncy', N'USD SOFR3W',
                    '', '', 1,
                    '0', 0,
                    @stateMaker, @stateDate, @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisId
                     AND SymbolCode = N'USOSFRA BGN Curncy'
                     AND SymbolName = N'USD SOFR1M')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId, ModuleId, SymbolTypeId,
             SymbolCode, SymbolName,
             SymbolGroup, Description, IsEnabled,
             CcyPair, AlternateSymbol,
             StateMaker, StateDate, StateId)
            VALUES (@dataSourceId, @moduleId, @symbolTypeOisId,
                    N'USOSFRA BGN Curncy', N'USD SOFR1M',
                    '', '', 1,
                    '0', 0,
                    @stateMaker, @stateDate, @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisId
                     AND SymbolCode = N'USOSFRB BGN Curncy'
                     AND SymbolName = N'USD SOFR2M')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId, ModuleId, SymbolTypeId,
             SymbolCode, SymbolName,
             SymbolGroup, Description, IsEnabled,
             CcyPair, AlternateSymbol,
             StateMaker, StateDate, StateId)
            VALUES (@dataSourceId, @moduleId, @symbolTypeOisId,
                    N'USOSFRB BGN Curncy', N'USD SOFR2M',
                    '', '', 1,
                    '0', 0,
                    @stateMaker, @stateDate, @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisId
                     AND SymbolCode = N'USOSFRC BGN Curncy'
                     AND SymbolName = N'USD SOFR3M')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId, ModuleId, SymbolTypeId,
             SymbolCode, SymbolName,
             SymbolGroup, Description, IsEnabled,
             CcyPair, AlternateSymbol,
             StateMaker, StateDate, StateId)
            VALUES (@dataSourceId, @moduleId, @symbolTypeOisId,
                    N'USOSFRC BGN Curncy', N'USD SOFR3M',
                    '', '', 1,
                    '0', 0,
                    @stateMaker, @stateDate, @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisId
                     AND SymbolCode = N'USOSFRD BGN Curncy'
                     AND SymbolName = N'USD SOFR4M')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId, ModuleId, SymbolTypeId,
             SymbolCode, SymbolName,
             SymbolGroup, Description, IsEnabled,
             CcyPair, AlternateSymbol,
             StateMaker, StateDate, StateId)
            VALUES (@dataSourceId, @moduleId, @symbolTypeOisId,
                    N'USOSFRD BGN Curncy', N'USD SOFR4M',
                    '', '', 1,
                    '0', 0,
                    @stateMaker, @stateDate, @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisId
                     AND SymbolCode = N'USOSFRE BGN Curncy'
                     AND SymbolName = N'USD SOFR5M')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId, ModuleId, SymbolTypeId,
             SymbolCode, SymbolName,
             SymbolGroup, Description, IsEnabled,
             CcyPair, AlternateSymbol,
             StateMaker, StateDate, StateId)
            VALUES (@dataSourceId, @moduleId, @symbolTypeOisId,
                    N'USOSFRE BGN Curncy', N'USD SOFR5M',
                    '', '', 1,
                    '0', 0,
                    @stateMaker, @stateDate, @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisId
                     AND SymbolCode = N'USOSFRF BGN Curncy'
                     AND SymbolName = N'USD SOFR6M')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId, ModuleId, SymbolTypeId,
             SymbolCode, SymbolName,
             SymbolGroup, Description, IsEnabled,
             CcyPair, AlternateSymbol,
             StateMaker, StateDate, StateId)
            VALUES (@dataSourceId, @moduleId, @symbolTypeOisId,
                    N'USOSFRF BGN Curncy', N'USD SOFR6M',
                    '', '', 1,
                    '0', 0,
                    @stateMaker, @stateDate, @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisId
                     AND SymbolCode = N'USOSFRG BGN Curncy'
                     AND SymbolName = N'USD SOFR7M')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId, ModuleId, SymbolTypeId,
             SymbolCode, SymbolName,
             SymbolGroup, Description, IsEnabled,
             CcyPair, AlternateSymbol,
             StateMaker, StateDate, StateId)
            VALUES (@dataSourceId, @moduleId, @symbolTypeOisId,
                    N'USOSFRG BGN Curncy', N'USD SOFR7M',
                    '', '', 1,
                    '0', 0,
                    @stateMaker, @stateDate, @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisId
                     AND SymbolCode = N'USOSFRH BGN Curncy'
                     AND SymbolName = N'USD SOFR8M')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId, ModuleId, SymbolTypeId,
             SymbolCode, SymbolName,
             SymbolGroup, Description, IsEnabled,
             CcyPair, AlternateSymbol,
             StateMaker, StateDate, StateId)
            VALUES (@dataSourceId, @moduleId, @symbolTypeOisId,
                    N'USOSFRH BGN Curncy', N'USD SOFR8M',
                    '', '', 1,
                    '0', 0,
                    @stateMaker, @stateDate, @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisId
                     AND SymbolCode = N'USOSFRI BGN Curncy'
                     AND SymbolName = N'USD SOFR9M')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId, ModuleId, SymbolTypeId,
             SymbolCode, SymbolName,
             SymbolGroup, Description, IsEnabled,
             CcyPair, AlternateSymbol,
             StateMaker, StateDate, StateId)
            VALUES (@dataSourceId, @moduleId, @symbolTypeOisId,
                    N'USOSFRI BGN Curncy', N'USD SOFR9M',
                    '', '', 1,
                    '0', 0,
                    @stateMaker, @stateDate, @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisId
                     AND SymbolCode = N'USOSFRJ BGN Curncy'
                     AND SymbolName = N'USD SOFR10M')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId, ModuleId, SymbolTypeId,
             SymbolCode, SymbolName,
             SymbolGroup, Description, IsEnabled,
             CcyPair, AlternateSymbol,
             StateMaker, StateDate, StateId)
            VALUES (@dataSourceId, @moduleId, @symbolTypeOisId,
                    N'USOSFRJ BGN Curncy', N'USD SOFR10M',
                    '', '', 1,
                    '0', 0,
                    @stateMaker, @stateDate, @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisId
                     AND SymbolCode = N'USOSFRK BGN Curncy'
                     AND SymbolName = N'USD SOFR11M')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId, ModuleId, SymbolTypeId,
             SymbolCode, SymbolName,
             SymbolGroup, Description, IsEnabled,
             CcyPair, AlternateSymbol,
             StateMaker, StateDate, StateId)
            VALUES (@dataSourceId, @moduleId, @symbolTypeOisId,
                    N'USOSFRK BGN Curncy', N'USD SOFR11M',
                    '', '', 1,
                    '0', 0,
                    @stateMaker, @stateDate, @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisId
                     AND SymbolCode = N'USOSFR1 BGN Curncy'
                     AND SymbolName = N'USD SOFR12M')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId, ModuleId, SymbolTypeId,
             SymbolCode, SymbolName,
             SymbolGroup, Description, IsEnabled,
             CcyPair, AlternateSymbol,
             StateMaker, StateDate, StateId)
            VALUES (@dataSourceId, @moduleId, @symbolTypeOisId,
                    N'USOSFR1 BGN Curncy', N'USD SOFR12M',
                    '', '', 1,
                    '0', 0,
                    @stateMaker, @stateDate, @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisId
                     AND SymbolCode = N'USOSFR1F BGN Curncy'
                     AND SymbolName = N'USD SOFR18M')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId, ModuleId, SymbolTypeId,
             SymbolCode, SymbolName,
             SymbolGroup, Description, IsEnabled,
             CcyPair, AlternateSymbol,
             StateMaker, StateDate, StateId)
            VALUES (@dataSourceId, @moduleId, @symbolTypeOisId,
                    N'USOSFR1F BGN Curncy', N'USD SOFR18M',
                    '', '', 1,
                    '0', 0,
                    @stateMaker, @stateDate, @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisId
                     AND SymbolCode = N'USOSFR2 BGN Curncy'
                     AND SymbolName = N'USD SOFR2Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId, ModuleId, SymbolTypeId,
             SymbolCode, SymbolName,
             SymbolGroup, Description, IsEnabled,
             CcyPair, AlternateSymbol,
             StateMaker, StateDate, StateId)
            VALUES (@dataSourceId, @moduleId, @symbolTypeOisId,
                    N'USOSFR2 BGN Curncy', N'USD SOFR2Y',
                    '', '', 1,
                    '0', 0,
                    @stateMaker, @stateDate, @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisId
                     AND SymbolCode = N'USOSFR3 BGN Curncy'
                     AND SymbolName = N'USD SOFR3Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId, ModuleId, SymbolTypeId,
             SymbolCode, SymbolName,
             SymbolGroup, Description, IsEnabled,
             CcyPair, AlternateSymbol,
             StateMaker, StateDate, StateId)
            VALUES (@dataSourceId, @moduleId, @symbolTypeOisId,
                    N'USOSFR3 BGN Curncy', N'USD SOFR3Y',
                    '', '', 1,
                    '0', 0,
                    @stateMaker, @stateDate, @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisId
                     AND SymbolCode = N'USOSFR4 BGN Curncy'
                     AND SymbolName = N'USD SOFR4Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId, ModuleId, SymbolTypeId,
             SymbolCode, SymbolName,
             SymbolGroup, Description, IsEnabled,
             CcyPair, AlternateSymbol,
             StateMaker, StateDate, StateId)
            VALUES (@dataSourceId, @moduleId, @symbolTypeOisId,
                    N'USOSFR4 BGN Curncy', N'USD SOFR4Y',
                    '', '', 1,
                    '0', 0,
                    @stateMaker, @stateDate, @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisId
                     AND SymbolCode = N'USOSFR5 BGN Curncy'
                     AND SymbolName = N'USD SOFR5Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId, ModuleId, SymbolTypeId,
             SymbolCode, SymbolName,
             SymbolGroup, Description, IsEnabled,
             CcyPair, AlternateSymbol,
             StateMaker, StateDate, StateId)
            VALUES (@dataSourceId, @moduleId, @symbolTypeOisId,
                    N'USOSFR5 BGN Curncy', N'USD SOFR5Y',
                    '', '', 1,
                    '0', 0,
                    @stateMaker, @stateDate, @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisId
                     AND SymbolCode = N'USOSFR6 BGN Curncy'
                     AND SymbolName = N'USD SOFR6Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId, ModuleId, SymbolTypeId,
             SymbolCode, SymbolName,
             SymbolGroup, Description, IsEnabled,
             CcyPair, AlternateSymbol,
             StateMaker, StateDate, StateId)
            VALUES (@dataSourceId, @moduleId, @symbolTypeOisId,
                    N'USOSFR6 BGN Curncy', N'USD SOFR6Y',
                    '', '', 1,
                    '0', 0,
                    @stateMaker, @stateDate, @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisId
                     AND SymbolCode = N'USOSFR7 BGN Curncy'
                     AND SymbolName = N'USD SOFR7Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId, ModuleId, SymbolTypeId,
             SymbolCode, SymbolName,
             SymbolGroup, Description, IsEnabled,
             CcyPair, AlternateSymbol,
             StateMaker, StateDate, StateId)
            VALUES (@dataSourceId, @moduleId, @symbolTypeOisId,
                    N'USOSFR7 BGN Curncy', N'USD SOFR7Y',
                    '', '', 1,
                    '0', 0,
                    @stateMaker, @stateDate, @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisId
                     AND SymbolCode = N'USOSFR8 BGN Curncy'
                     AND SymbolName = N'USD SOFR8Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId, ModuleId, SymbolTypeId,
             SymbolCode, SymbolName,
             SymbolGroup, Description, IsEnabled,
             CcyPair, AlternateSymbol,
             StateMaker, StateDate, StateId)
            VALUES (@dataSourceId, @moduleId, @symbolTypeOisId,
                    N'USOSFR8 BGN Curncy', N'USD SOFR8Y',
                    '', '', 1,
                    '0', 0,
                    @stateMaker, @stateDate, @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisId
                     AND SymbolCode = N'USOSFR9 BGN Curncy'
                     AND SymbolName = N'USD SOFR9Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId, ModuleId, SymbolTypeId,
             SymbolCode, SymbolName,
             SymbolGroup, Description, IsEnabled,
             CcyPair, AlternateSymbol,
             StateMaker, StateDate, StateId)
            VALUES (@dataSourceId, @moduleId, @symbolTypeOisId,
                    N'USOSFR9 BGN Curncy', N'USD SOFR9Y',
                    '', '', 1,
                    '0', 0,
                    @stateMaker, @stateDate, @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisId
                     AND SymbolCode = N'USOSFR10 BGN Curncy'
                     AND SymbolName = N'USD SOFR10Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId, ModuleId, SymbolTypeId,
             SymbolCode, SymbolName,
             SymbolGroup, Description, IsEnabled,
             CcyPair, AlternateSymbol,
             StateMaker, StateDate, StateId)
            VALUES (@dataSourceId, @moduleId, @symbolTypeOisId,
                    N'USOSFR10 BGN Curncy', N'USD SOFR10Y',
                    '', '', 1,
                    '0', 0,
                    @stateMaker, @stateDate, @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisId
                     AND SymbolCode = N'USOSFR12 BGN Curncy'
                     AND SymbolName = N'USD SOFR12Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId, ModuleId, SymbolTypeId,
             SymbolCode, SymbolName,
             SymbolGroup, Description, IsEnabled,
             CcyPair, AlternateSymbol,
             StateMaker, StateDate, StateId)
            VALUES (@dataSourceId, @moduleId, @symbolTypeOisId,
                    N'USOSFR12 BGN Curncy', N'USD SOFR12Y',
                    '', '', 1,
                    '0', 0,
                    @stateMaker, @stateDate, @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisId
                     AND SymbolCode = N'USOSFR15 BGN Curncy'
                     AND SymbolName = N'USD SOFR15Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId, ModuleId, SymbolTypeId,
             SymbolCode, SymbolName,
             SymbolGroup, Description, IsEnabled,
             CcyPair, AlternateSymbol,
             StateMaker, StateDate, StateId)
            VALUES (@dataSourceId, @moduleId, @symbolTypeOisId,
                    N'USOSFR15 BGN Curncy', N'USD SOFR15Y',
                    '', '', 1,
                    '0', 0,
                    @stateMaker, @stateDate, @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisId
                     AND SymbolCode = N'USOSFR20 BGN Curncy'
                     AND SymbolName = N'USD SOFR20Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId, ModuleId, SymbolTypeId,
             SymbolCode, SymbolName,
             SymbolGroup, Description, IsEnabled,
             CcyPair, AlternateSymbol,
             StateMaker, StateDate, StateId)
            VALUES (@dataSourceId, @moduleId, @symbolTypeOisId,
                    N'USOSFR20 BGN Curncy', N'USD SOFR20Y',
                    '', '', 1,
                    '0', 0,
                    @stateMaker, @stateDate, @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisId
                     AND SymbolCode = N'USOSFR25 BGN Curncy'
                     AND SymbolName = N'USD SOFR25Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId, ModuleId, SymbolTypeId,
             SymbolCode, SymbolName,
             SymbolGroup, Description, IsEnabled,
             CcyPair, AlternateSymbol,
             StateMaker, StateDate, StateId)
            VALUES (@dataSourceId, @moduleId, @symbolTypeOisId,
                    N'USOSFR25 BGN Curncy', N'USD SOFR25Y',
                    '', '', 1,
                    '0', 0,
                    @stateMaker, @stateDate, @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisId
                     AND SymbolCode = N'USOSFR30 BGN Curncy'
                     AND SymbolName = N'USD SOFR30Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId, ModuleId, SymbolTypeId,
             SymbolCode, SymbolName,
             SymbolGroup, Description, IsEnabled,
             CcyPair, AlternateSymbol,
             StateMaker, StateDate, StateId)
            VALUES (@dataSourceId, @moduleId, @symbolTypeOisId,
                    N'USOSFR30 BGN Curncy', N'USD SOFR30Y',
                    '', '', 1,
                    '0', 0,
                    @stateMaker, @stateDate, @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisId
                     AND SymbolCode = N'USOSFR40 BGN Curncy'
                     AND SymbolName = N'USD SOFR40Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId, ModuleId, SymbolTypeId,
             SymbolCode, SymbolName,
             SymbolGroup, Description, IsEnabled,
             CcyPair, AlternateSymbol,
             StateMaker, StateDate, StateId)
            VALUES (@dataSourceId, @moduleId, @symbolTypeOisId,
                    N'USOSFR40 BGN Curncy', N'USD SOFR40Y',
                    '', '', 1,
                    '0', 0,
                    @stateMaker, @stateDate, @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisId
                     AND SymbolCode = N'USOSFR50 BGN Curncy'
                     AND SymbolName = N'USD SOFR50Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId, ModuleId, SymbolTypeId,
             SymbolCode, SymbolName,
             SymbolGroup, Description, IsEnabled,
             CcyPair, AlternateSymbol,
             StateMaker, StateDate, StateId)
            VALUES (@dataSourceId, @moduleId, @symbolTypeOisId,
                    N'USOSFR50 BGN Curncy', N'USD SOFR50Y',
                    '', '', 1,
                    '0', 0,
                    @stateMaker, @stateDate, @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisId
                     AND SymbolCode = 'TSFR3M Index'
                     AND SymbolName = N'USD TERMSOFR3M')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId, ModuleId, SymbolTypeId,
             SymbolCode, SymbolName,
             SymbolGroup, Description, IsEnabled,
             CcyPair, AlternateSymbol,
             StateMaker, StateDate, StateId)
            VALUES (@dataSourceId, @moduleId, @symbolTypeOisId,
                    'TSFR3M Index', N'USD TERMSOFR3M',
                    '', '', 1,
                    '0', 0,
                    @stateMaker, @stateDate, @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisId
                     AND SymbolCode = 'TSFR6M Index'
                     AND SymbolName = N'USD TERMSOFR6M')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId, ModuleId, SymbolTypeId,
             SymbolCode, SymbolName,
             SymbolGroup, Description, IsEnabled,
             CcyPair, AlternateSymbol,
             StateMaker, StateDate, StateId)
            VALUES (@dataSourceId, @moduleId, @symbolTypeOisId,
                    'TSFR6M Index', N'USD TERMSOFR6M',
                    '', '', 1,
                    '0', 0,
                    @stateMaker, @stateDate, @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisId
                     AND SymbolCode = N'USSO1Z BGN Curncy'
                     AND SymbolName = N'USD OIS1W')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId, ModuleId, SymbolTypeId,
             SymbolCode, SymbolName,
             SymbolGroup, Description, IsEnabled,
             CcyPair, AlternateSymbol,
             StateMaker, StateDate, StateId)
            VALUES (@dataSourceId, @moduleId, @symbolTypeOisId,
                    N'USSO1Z BGN Curncy', N'USD OIS1W',
                    '', '', 1,
                    '0', 0,
                    @stateMaker, @stateDate, @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisId
                     AND SymbolCode = N'USSO2Z BGN Curncy'
                     AND SymbolName = N'USD OIS2W')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId, ModuleId, SymbolTypeId,
             SymbolCode, SymbolName,
             SymbolGroup, Description, IsEnabled,
             CcyPair, AlternateSymbol,
             StateMaker, StateDate, StateId)
            VALUES (@dataSourceId, @moduleId, @symbolTypeOisId,
                    N'USSO2Z BGN Curncy', N'USD OIS2W',
                    '', '', 1,
                    '0', 0,
                    @stateMaker, @stateDate, @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisId
                     AND SymbolCode = N'USSO3Z BGN Curncy'
                     AND SymbolName = N'USD OIS3W')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId, ModuleId, SymbolTypeId,
             SymbolCode, SymbolName,
             SymbolGroup, Description, IsEnabled,
             CcyPair, AlternateSymbol,
             StateMaker, StateDate, StateId)
            VALUES (@dataSourceId, @moduleId, @symbolTypeOisId,
                    N'USSO3Z BGN Curncy', N'USD OIS3W',
                    '', '', 1,
                    '0', 0,
                    @stateMaker, @stateDate, @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisId
                     AND SymbolCode = N'USSOA BGN Curncy'
                     AND SymbolName = N'USD OIS1M')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId, ModuleId, SymbolTypeId,
             SymbolCode, SymbolName,
             SymbolGroup, Description, IsEnabled,
             CcyPair, AlternateSymbol,
             StateMaker, StateDate, StateId)
            VALUES (@dataSourceId, @moduleId, @symbolTypeOisId,
                    N'USSOA BGN Curncy', N'USD OIS1M',
                    '', '', 1,
                    '0', 0,
                    @stateMaker, @stateDate, @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisId
                     AND SymbolCode = N'USSOB BGN Curncy'
                     AND SymbolName = N'USD OIS2M')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId, ModuleId, SymbolTypeId,
             SymbolCode, SymbolName,
             SymbolGroup, Description, IsEnabled,
             CcyPair, AlternateSymbol,
             StateMaker, StateDate, StateId)
            VALUES (@dataSourceId, @moduleId, @symbolTypeOisId,
                    N'USSOB BGN Curncy', N'USD OIS2M',
                    '', '', 1,
                    '0', 0,
                    @stateMaker, @stateDate, @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisId
                     AND SymbolCode = N'USSOC BGN Curncy'
                     AND SymbolName = N'USD OIS3M')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId, ModuleId, SymbolTypeId,
             SymbolCode, SymbolName,
             SymbolGroup, Description, IsEnabled,
             CcyPair, AlternateSymbol,
             StateMaker, StateDate, StateId)
            VALUES (@dataSourceId, @moduleId, @symbolTypeOisId,
                    N'USSOC BGN Curncy', N'USD OIS3M',
                    '', '', 1,
                    '0', 0,
                    @stateMaker, @stateDate, @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisId
                     AND SymbolCode = N'USSOD BGN Curncy'
                     AND SymbolName = N'USD OIS4M')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId, ModuleId, SymbolTypeId,
             SymbolCode, SymbolName,
             SymbolGroup, Description, IsEnabled,
             CcyPair, AlternateSymbol,
             StateMaker, StateDate, StateId)
            VALUES (@dataSourceId, @moduleId, @symbolTypeOisId,
                    N'USSOD BGN Curncy', N'USD OIS4M',
                    '', '', 1,
                    '0', 0,
                    @stateMaker, @stateDate, @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisId
                     AND SymbolCode = N'USSOE BGN Curncy'
                     AND SymbolName = N'USD OIS5M')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId, ModuleId, SymbolTypeId,
             SymbolCode, SymbolName,
             SymbolGroup, Description, IsEnabled,
             CcyPair, AlternateSymbol,
             StateMaker, StateDate, StateId)
            VALUES (@dataSourceId, @moduleId, @symbolTypeOisId,
                    N'USSOE BGN Curncy', N'USD OIS5M',
                    '', '', 1,
                    '0', 0,
                    @stateMaker, @stateDate, @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisId
                     AND SymbolCode = N'USSOF BGN Curncy'
                     AND SymbolName = N'USD OIS6M')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId, ModuleId, SymbolTypeId,
             SymbolCode, SymbolName,
             SymbolGroup, Description, IsEnabled,
             CcyPair, AlternateSymbol,
             StateMaker, StateDate, StateId)
            VALUES (@dataSourceId, @moduleId, @symbolTypeOisId,
                    N'USSOF BGN Curncy', N'USD OIS6M',
                    '', '', 1,
                    '0', 0,
                    @stateMaker, @stateDate, @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisId
                     AND SymbolCode = N'USSOI BGN Curncy'
                     AND SymbolName = N'USD OIS9M')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId, ModuleId, SymbolTypeId,
             SymbolCode, SymbolName,
             SymbolGroup, Description, IsEnabled,
             CcyPair, AlternateSymbol,
             StateMaker, StateDate, StateId)
            VALUES (@dataSourceId, @moduleId, @symbolTypeOisId,
                    N'USSOI BGN Curncy', N'USD OIS9M',
                    '', '', 1,
                    '0', 0,
                    @stateMaker, @stateDate, @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisId
                     AND SymbolCode = N'USSO1 BGN Curncy'
                     AND SymbolName = N'USD OIS12M')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId, ModuleId, SymbolTypeId,
             SymbolCode, SymbolName,
             SymbolGroup, Description, IsEnabled,
             CcyPair, AlternateSymbol,
             StateMaker, StateDate, StateId)
            VALUES (@dataSourceId, @moduleId, @symbolTypeOisId,
                    N'USSO1 BGN Curncy', N'USD OIS12M',
                    '', '', 1,
                    '0', 0,
                    @stateMaker, @stateDate, @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisId
                     AND SymbolCode = N'USSO1F BGN Curncy'
                     AND SymbolName = N'USD OIS18M')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId, ModuleId, SymbolTypeId,
             SymbolCode, SymbolName,
             SymbolGroup, Description, IsEnabled,
             CcyPair, AlternateSymbol,
             StateMaker, StateDate, StateId)
            VALUES (@dataSourceId, @moduleId, @symbolTypeOisId,
                    N'USSO1F BGN Curncy', N'USD OIS18M',
                    '', '', 1,
                    '0', 0,
                    @stateMaker, @stateDate, @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisId
                     AND SymbolCode = 'ESTRON Index'
                     AND SymbolName = N'EUR ESTRON')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId, ModuleId, SymbolTypeId,
             SymbolCode, SymbolName,
             SymbolGroup, Description, IsEnabled,
             CcyPair, AlternateSymbol,
             StateMaker, StateDate, StateId)
            VALUES (@dataSourceId, @moduleId, @symbolTypeOisId,
                    'ESTRON Index', N'EUR ESTRON',
                    '', '', 1,
                    '0', 0,
                    @stateMaker, @stateDate, @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisId
                     AND SymbolCode = N'EESWE1Z BGN Curncy'
                     AND SymbolName = N'EUR ESTR1W')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId, ModuleId, SymbolTypeId,
             SymbolCode, SymbolName,
             SymbolGroup, Description, IsEnabled,
             CcyPair, AlternateSymbol,
             StateMaker, StateDate, StateId)
            VALUES (@dataSourceId, @moduleId, @symbolTypeOisId,
                    N'EESWE1Z BGN Curncy', N'EUR ESTR1W',
                    '', '', 1,
                    '0', 0,
                    @stateMaker, @stateDate, @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisId
                     AND SymbolCode = N'EESWE2Z BGN Curncy'
                     AND SymbolName = N'EUR ESTR2W')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId, ModuleId, SymbolTypeId,
             SymbolCode, SymbolName,
             SymbolGroup, Description, IsEnabled,
             CcyPair, AlternateSymbol,
             StateMaker, StateDate, StateId)
            VALUES (@dataSourceId, @moduleId, @symbolTypeOisId,
                    N'EESWE2Z BGN Curncy', N'EUR ESTR2W',
                    '', '', 1,
                    '0', 0,
                    @stateMaker, @stateDate, @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisId
                     AND SymbolCode = N'EESWEA BGN Curncy'
                     AND SymbolName = N'EUR ESTR1M')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId, ModuleId, SymbolTypeId,
             SymbolCode, SymbolName,
             SymbolGroup, Description, IsEnabled,
             CcyPair, AlternateSymbol,
             StateMaker, StateDate, StateId)
            VALUES (@dataSourceId, @moduleId, @symbolTypeOisId,
                    N'EESWEA BGN Curncy', N'EUR ESTR1M',
                    '', '', 1,
                    '0', 0,
                    @stateMaker, @stateDate, @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisId
                     AND SymbolCode = N'EESWEB BGN Curncy'
                     AND SymbolName = N'EUR ESTR2M')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId, ModuleId, SymbolTypeId,
             SymbolCode, SymbolName,
             SymbolGroup, Description, IsEnabled,
             CcyPair, AlternateSymbol,
             StateMaker, StateDate, StateId)
            VALUES (@dataSourceId, @moduleId, @symbolTypeOisId,
                    N'EESWEB BGN Curncy', N'EUR ESTR2M',
                    '', '', 1,
                    '0', 0,
                    @stateMaker, @stateDate, @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisId
                     AND SymbolCode = N'EESWEC BGN Curncy'
                     AND SymbolName = N'EUR ESTR3M')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId, ModuleId, SymbolTypeId,
             SymbolCode, SymbolName,
             SymbolGroup, Description, IsEnabled,
             CcyPair, AlternateSymbol,
             StateMaker, StateDate, StateId)
            VALUES (@dataSourceId, @moduleId, @symbolTypeOisId,
                    N'EESWEC BGN Curncy', N'EUR ESTR3M',
                    '', '', 1,
                    '0', 0,
                    @stateMaker, @stateDate, @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisId
                     AND SymbolCode = N'EESWED BGN Curncy'
                     AND SymbolName = N'EUR ESTR4M')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId, ModuleId, SymbolTypeId,
             SymbolCode, SymbolName,
             SymbolGroup, Description, IsEnabled,
             CcyPair, AlternateSymbol,
             StateMaker, StateDate, StateId)
            VALUES (@dataSourceId, @moduleId, @symbolTypeOisId,
                    N'EESWED BGN Curncy', N'EUR ESTR4M',
                    '', '', 1,
                    '0', 0,
                    @stateMaker, @stateDate, @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisId
                     AND SymbolCode = N'EESWEE BGN Curncy'
                     AND SymbolName = N'EUR ESTR5M')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId, ModuleId, SymbolTypeId,
             SymbolCode, SymbolName,
             SymbolGroup, Description, IsEnabled,
             CcyPair, AlternateSymbol,
             StateMaker, StateDate, StateId)
            VALUES (@dataSourceId, @moduleId, @symbolTypeOisId,
                    N'EESWEE BGN Curncy', N'EUR ESTR5M',
                    '', '', 1,
                    '0', 0,
                    @stateMaker, @stateDate, @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisId
                     AND SymbolCode = N'EESWEF BGN Curncy'
                     AND SymbolName = N'EUR ESTR6M')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId,
             ModuleId,
             SymbolTypeId,
             SymbolCode,
             SymbolName,
             SymbolGroup,
             Description,
             IsEnabled,
             CcyPair,
             AlternateSymbol,
             StateMaker,
             StateDate,
             StateId)
            VALUES (@dataSourceId,
                    @moduleId,
                    @symbolTypeOisId,
                    N'EESWEF BGN Curncy',
                    N'EUR ESTR6M',
                    '',
                    '',
                    1,
                    '0',
                    0,
                    @stateMaker,
                    @stateDate,
                    @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisId
                     AND SymbolCode = N'EESWEG BGN Curncy'
                     AND SymbolName = N'EUR ESTR7M')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId,
             ModuleId,
             SymbolTypeId,
             SymbolCode,
             SymbolName,
             SymbolGroup,
             Description,
             IsEnabled,
             CcyPair,
             AlternateSymbol,
             StateMaker,
             StateDate,
             StateId)
            VALUES (@dataSourceId,
                    @moduleId,
                    @symbolTypeOisId,
                    N'EESWEG BGN Curncy',
                    N'EUR ESTR7M',
                    '',
                    '',
                    1,
                    '0',
                    0,
                    @stateMaker,
                    @stateDate,
                    @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisId
                     AND SymbolCode = N'EESWEH BGN Curncy'
                     AND SymbolName = N'EUR ESTR8M')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId,
             ModuleId,
             SymbolTypeId,
             SymbolCode,
             SymbolName,
             SymbolGroup,
             Description,
             IsEnabled,
             CcyPair,
             AlternateSymbol,
             StateMaker,
             StateDate,
             StateId)
            VALUES (@dataSourceId,
                    @moduleId,
                    @symbolTypeOisId,
                    N'EESWEH BGN Curncy',
                    N'EUR ESTR8M',
                    '',
                    '',
                    1,
                    '0',
                    0,
                    @stateMaker,
                    @stateDate,
                    @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisId
                     AND SymbolCode = N'EESWEI BGN Curncy'
                     AND SymbolName = N'EUR ESTR9M')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId,
             ModuleId,
             SymbolTypeId,
             SymbolCode,
             SymbolName,
             SymbolGroup,
             Description,
             IsEnabled,
             CcyPair,
             AlternateSymbol,
             StateMaker,
             StateDate,
             StateId)
            VALUES (@dataSourceId,
                    @moduleId,
                    @symbolTypeOisId,
                    N'EESWEI BGN Curncy',
                    N'EUR ESTR9M',
                    '',
                    '',
                    1,
                    '0',
                    0,
                    @stateMaker,
                    @stateDate,
                    @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisId
                     AND SymbolCode = N'EESWEJ BGN Curncy'
                     AND SymbolName = N'EUR ESTR10M')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId,
             ModuleId,
             SymbolTypeId,
             SymbolCode,
             SymbolName,
             SymbolGroup,
             Description,
             IsEnabled,
             CcyPair,
             AlternateSymbol,
             StateMaker,
             StateDate,
             StateId)
            VALUES (@dataSourceId,
                    @moduleId,
                    @symbolTypeOisId,
                    N'EESWEJ BGN Curncy',
                    N'EUR ESTR10M',
                    '',
                    '',
                    1,
                    '0',
                    0,
                    @stateMaker,
                    @stateDate,
                    @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisId
                     AND SymbolCode = N'EESWEK BGN Curncy'
                     AND SymbolName = N'EUR ESTR11M')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId,
             ModuleId,
             SymbolTypeId,
             SymbolCode,
             SymbolName,
             SymbolGroup,
             Description,
             IsEnabled,
             CcyPair,
             AlternateSymbol,
             StateMaker,
             StateDate,
             StateId)
            VALUES (@dataSourceId,
                    @moduleId,
                    @symbolTypeOisId,
                    N'EESWEK BGN Curncy',
                    N'EUR ESTR11M',
                    '',
                    '',
                    1,
                    '0',
                    0,
                    @stateMaker,
                    @stateDate,
                    @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisId
                     AND SymbolCode = N'EESWE1 BGN Curncy'
                     AND SymbolName = N'EUR ESTR12M')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId,
             ModuleId,
             SymbolTypeId,
             SymbolCode,
             SymbolName,
             SymbolGroup,
             Description,
             IsEnabled,
             CcyPair,
             AlternateSymbol,
             StateMaker,
             StateDate,
             StateId)
            VALUES (@dataSourceId,
                    @moduleId,
                    @symbolTypeOisId,
                    N'EESWE1 BGN Curncy',
                    N'EUR ESTR12M',
                    '',
                    '',
                    1,
                    '0',
                    0,
                    @stateMaker,
                    @stateDate,
                    @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisId
                     AND SymbolCode = N'EESWE1F BGN Curncy'
                     AND SymbolName = N'EUR ESTR18M')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId,
             ModuleId,
             SymbolTypeId,
             SymbolCode,
             SymbolName,
             SymbolGroup,
             Description,
             IsEnabled,
             CcyPair,
             AlternateSymbol,
             StateMaker,
             StateDate,
             StateId)
            VALUES (@dataSourceId,
                    @moduleId,
                    @symbolTypeOisId,
                    N'EESWE1F BGN Curncy',
                    N'EUR ESTR18M',
                    '',
                    '',
                    1,
                    '0',
                    0,
                    @stateMaker,
                    @stateDate,
                    @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisId
                     AND SymbolCode = N'EESWE2 BGN Curncy'
                     AND SymbolName = N'EUR ESTR2Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId,
             ModuleId,
             SymbolTypeId,
             SymbolCode,
             SymbolName,
             SymbolGroup,
             Description,
             IsEnabled,
             CcyPair,
             AlternateSymbol,
             StateMaker,
             StateDate,
             StateId)
            VALUES (@dataSourceId,
                    @moduleId,
                    @symbolTypeOisId,
                    N'EESWE2 BGN Curncy',
                    N'EUR ESTR2Y',
                    '',
                    '',
                    1,
                    '0',
                    0,
                    @stateMaker,
                    @stateDate,
                    @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisId
                     AND SymbolCode = N'EESWE3 BGN Curncy'
                     AND SymbolName = N'EUR ESTR3Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId,
             ModuleId,
             SymbolTypeId,
             SymbolCode,
             SymbolName,
             SymbolGroup,
             Description,
             IsEnabled,
             CcyPair,
             AlternateSymbol,
             StateMaker,
             StateDate,
             StateId)
            VALUES (@dataSourceId,
                    @moduleId,
                    @symbolTypeOisId,
                    N'EESWE3 BGN Curncy',
                    N'EUR ESTR3Y',
                    '',
                    '',
                    1,
                    '0',
                    0,
                    @stateMaker,
                    @stateDate,
                    @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisId
                     AND SymbolCode = N'EESWE4 BGN Curncy'
                     AND SymbolName = N'EUR ESTR4Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId,
             ModuleId,
             SymbolTypeId,
             SymbolCode,
             SymbolName,
             SymbolGroup,
             Description,
             IsEnabled,
             CcyPair,
             AlternateSymbol,
             StateMaker,
             StateDate,
             StateId)
            VALUES (@dataSourceId,
                    @moduleId,
                    @symbolTypeOisId,
                    N'EESWE4 BGN Curncy',
                    N'EUR ESTR4Y',
                    '',
                    '',
                    1,
                    '0',
                    0,
                    @stateMaker,
                    @stateDate,
                    @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisId
                     AND SymbolCode = N'EESWE5 BGN Curncy'
                     AND SymbolName = N'EUR ESTR5Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId,
             ModuleId,
             SymbolTypeId,
             SymbolCode,
             SymbolName,
             SymbolGroup,
             Description,
             IsEnabled,
             CcyPair,
             AlternateSymbol,
             StateMaker,
             StateDate,
             StateId)
            VALUES (@dataSourceId,
                    @moduleId,
                    @symbolTypeOisId,
                    N'EESWE5 BGN Curncy',
                    N'EUR ESTR5Y',
                    '',
                    '',
                    1,
                    '0',
                    0,
                    @stateMaker,
                    @stateDate,
                    @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisId
                     AND SymbolCode = N'EESWE6 BGN Curncy'
                     AND SymbolName = N'EUR ESTR6Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId,
             ModuleId,
             SymbolTypeId,
             SymbolCode,
             SymbolName,
             SymbolGroup,
             Description,
             IsEnabled,
             CcyPair,
             AlternateSymbol,
             StateMaker,
             StateDate,
             StateId)
            VALUES (@dataSourceId,
                    @moduleId,
                    @symbolTypeOisId,
                    N'EESWE6 BGN Curncy',
                    N'EUR ESTR6Y',
                    '',
                    '',
                    1,
                    '0',
                    0,
                    @stateMaker,
                    @stateDate,
                    @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisId
                     AND SymbolCode = N'EESWE7 BGN Curncy'
                     AND SymbolName = N'EUR ESTR7Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId,
             ModuleId,
             SymbolTypeId,
             SymbolCode,
             SymbolName,
             SymbolGroup,
             Description,
             IsEnabled,
             CcyPair,
             AlternateSymbol,
             StateMaker,
             StateDate,
             StateId)
            VALUES (@dataSourceId,
                    @moduleId,
                    @symbolTypeOisId,
                    N'EESWE7 BGN Curncy',
                    N'EUR ESTR7Y',
                    '',
                    '',
                    1,
                    '0',
                    0,
                    @stateMaker,
                    @stateDate,
                    @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisId
                     AND SymbolCode = N'EESWE8 BGN Curncy'
                     AND SymbolName = N'EUR ESTR8Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId,
             ModuleId,
             SymbolTypeId,
             SymbolCode,
             SymbolName,
             SymbolGroup,
             Description,
             IsEnabled,
             CcyPair,
             AlternateSymbol,
             StateMaker,
             StateDate,
             StateId)
            VALUES (@dataSourceId,
                    @moduleId,
                    @symbolTypeOisId,
                    N'EESWE8 BGN Curncy',
                    N'EUR ESTR8Y',
                    '',
                    '',
                    1,
                    '0',
                    0,
                    @stateMaker,
                    @stateDate,
                    @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisId
                     AND SymbolCode = N'EESWE9 BGN Curncy'
                     AND SymbolName = N'EUR ESTR9Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId,
             ModuleId,
             SymbolTypeId,
             SymbolCode,
             SymbolName,
             SymbolGroup,
             Description,
             IsEnabled,
             CcyPair,
             AlternateSymbol,
             StateMaker,
             StateDate,
             StateId)
            VALUES (@dataSourceId,
                    @moduleId,
                    @symbolTypeOisId,
                    N'EESWE9 BGN Curncy',
                    N'EUR ESTR9Y',
                    '',
                    '',
                    1,
                    '0',
                    0,
                    @stateMaker,
                    @stateDate,
                    @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisId
                     AND SymbolCode = N'EESWE10 BGN Curncy'
                     AND SymbolName = N'EUR ESTR10Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId,
             ModuleId,
             SymbolTypeId,
             SymbolCode,
             SymbolName,
             SymbolGroup,
             Description,
             IsEnabled,
             CcyPair,
             AlternateSymbol,
             StateMaker,
             StateDate,
             StateId)
            VALUES (@dataSourceId,
                    @moduleId,
                    @symbolTypeOisId,
                    N'EESWE10 BGN Curncy',
                    N'EUR ESTR10Y',
                    '',
                    '',
                    1,
                    '0',
                    0,
                    @stateMaker,
                    @stateDate,
                    @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisId
                     AND SymbolCode = N'EESWE11 BGN Curncy'
                     AND SymbolName = N'EUR ESTR11Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId,
             ModuleId,
             SymbolTypeId,
             SymbolCode,
             SymbolName,
             SymbolGroup,
             Description,
             IsEnabled,
             CcyPair,
             AlternateSymbol,
             StateMaker,
             StateDate,
             StateId)
            VALUES (@dataSourceId,
                    @moduleId,
                    @symbolTypeOisId,
                    N'EESWE11 BGN Curncy',
                    N'EUR ESTR11Y',
                    '',
                    '',
                    1,
                    '0',
                    0,
                    @stateMaker,
                    @stateDate,
                    @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisId
                     AND SymbolCode = N'EESWE12 BGN Curncy'
                     AND SymbolName = N'EUR ESTR12Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId,
             ModuleId,
             SymbolTypeId,
             SymbolCode,
             SymbolName,
             SymbolGroup,
             Description,
             IsEnabled,
             CcyPair,
             AlternateSymbol,
             StateMaker,
             StateDate,
             StateId)
            VALUES (@dataSourceId,
                    @moduleId,
                    @symbolTypeOisId,
                    N'EESWE12 BGN Curncy',
                    N'EUR ESTR12Y',
                    '',
                    '',
                    1,
                    '0',
                    0,
                    @stateMaker,
                    @stateDate,
                    @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisId
                     AND SymbolCode = N'EESWE15 BGN Curncy'
                     AND SymbolName = N'EUR ESTR15Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId,
             ModuleId,
             SymbolTypeId,
             SymbolCode,
             SymbolName,
             SymbolGroup,
             Description,
             IsEnabled,
             CcyPair,
             AlternateSymbol,
             StateMaker,
             StateDate,
             StateId)
            VALUES (@dataSourceId,
                    @moduleId,
                    @symbolTypeOisId,
                    N'EESWE15 BGN Curncy',
                    N'EUR ESTR15Y',
                    '',
                    '',
                    1,
                    '0',
                    0,
                    @stateMaker,
                    @stateDate,
                    @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisId
                     AND SymbolCode = N'EESWE20 BGN Curncy'
                     AND SymbolName = N'EUR ESTR20Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId,
             ModuleId,
             SymbolTypeId,
             SymbolCode,
             SymbolName,
             SymbolGroup,
             Description,
             IsEnabled,
             CcyPair,
             AlternateSymbol,
             StateMaker,
             StateDate,
             StateId)
            VALUES (@dataSourceId,
                    @moduleId,
                    @symbolTypeOisId,
                    N'EESWE20 BGN Curncy',
                    N'EUR ESTR20Y',
                    '',
                    '',
                    1,
                    '0',
                    0,
                    @stateMaker,
                    @stateDate,
                    @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisId
                     AND SymbolCode = N'EESWE25 BGN Curncy'
                     AND SymbolName = N'EUR ESTR25Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId,
             ModuleId,
             SymbolTypeId,
             SymbolCode,
             SymbolName,
             SymbolGroup,
             Description,
             IsEnabled,
             CcyPair,
             AlternateSymbol,
             StateMaker,
             StateDate,
             StateId)
            VALUES (@dataSourceId,
                    @moduleId,
                    @symbolTypeOisId,
                    N'EESWE25 BGN Curncy',
                    N'EUR ESTR25Y',
                    '',
                    '',
                    1,
                    '0',
                    0,
                    @stateMaker,
                    @stateDate,
                    @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisId
                     AND SymbolCode = N'EESWE30 BGN Curncy'
                     AND SymbolName = N'EUR ESTR30Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId,
             ModuleId,
             SymbolTypeId,
             SymbolCode,
             SymbolName,
             SymbolGroup,
             Description,
             IsEnabled,
             CcyPair,
             AlternateSymbol,
             StateMaker,
             StateDate,
             StateId)
            VALUES (@dataSourceId,
                    @moduleId,
                    @symbolTypeOisId,
                    N'EESWE30 BGN Curncy',
                    N'EUR ESTR30Y',
                    '',
                    '',
                    1,
                    '0',
                    0,
                    @stateMaker,
                    @stateDate,
                    @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisId
                     AND SymbolCode = N'EESWE40 BGN Curncy'
                     AND SymbolName = N'EUR ESTR40Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId,
             ModuleId,
             SymbolTypeId,
             SymbolCode,
             SymbolName,
             SymbolGroup,
             Description,
             IsEnabled,
             CcyPair,
             AlternateSymbol,
             StateMaker,
             StateDate,
             StateId)
            VALUES (@dataSourceId,
                    @moduleId,
                    @symbolTypeOisId,
                    N'EESWE40 BGN Curncy',
                    N'EUR ESTR40Y',
                    '',
                    '',
                    1,
                    '0',
                    0,
                    @stateMaker,
                    @stateDate,
                    @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisId
                     AND SymbolCode = N'EESWE50 BGN Curncy'
                     AND SymbolName = N'EUR ESTR50Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId,
             ModuleId,
             SymbolTypeId,
             SymbolCode,
             SymbolName,
             SymbolGroup,
             Description,
             IsEnabled,
             CcyPair,
             AlternateSymbol,
             StateMaker,
             StateDate,
             StateId)
            VALUES (@dataSourceId,
                    @moduleId,
                    @symbolTypeOisId,
                    N'EESWE50 BGN Curncy',
                    N'EUR ESTR50Y',
                    '',
                    '',
                    1,
                    '0',
                    0,
                    @stateMaker,
                    @stateDate,
                    @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisId
                     AND SymbolCode = N'EUR003M BGN Curncy'
                     AND SymbolName = N'EUR IBOR3M')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId,
             ModuleId,
             SymbolTypeId,
             SymbolCode,
             SymbolName,
             SymbolGroup,
             Description,
             IsEnabled,
             CcyPair,
             AlternateSymbol,
             StateMaker,
             StateDate,
             StateId)
            VALUES (@dataSourceId,
                    @moduleId,
                    @symbolTypeOisId,
                    N'EUR003M BGN Curncy',
                    N'EUR IBOR3M',
                    '',
                    '',
                    1,
                    '0',
                    0,
                    @stateMaker,
                    @stateDate,
                    @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisId
                     AND SymbolCode = N'EUSW3V3 BGN Curncy'
                     AND SymbolName = N'EUR IBOR3Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId,
             ModuleId,
             SymbolTypeId,
             SymbolCode,
             SymbolName,
             SymbolGroup,
             Description,
             IsEnabled,
             CcyPair,
             AlternateSymbol,
             StateMaker,
             StateDate,
             StateId)
            VALUES (@dataSourceId,
                    @moduleId,
                    @symbolTypeOisId,
                    N'EUSW3V3 BGN Curncy',
                    N'EUR IBOR3Y',
                    '',
                    '',
                    1,
                    '0',
                    0,
                    @stateMaker,
                    @stateDate,
                    @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisId
                     AND SymbolCode = N'EUSW4V3 BGN Curncy'
                     AND SymbolName = N'EUR IBOR4Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId,
             ModuleId,
             SymbolTypeId,
             SymbolCode,
             SymbolName,
             SymbolGroup,
             Description,
             IsEnabled,
             CcyPair,
             AlternateSymbol,
             StateMaker,
             StateDate,
             StateId)
            VALUES (@dataSourceId,
                    @moduleId,
                    @symbolTypeOisId,
                    N'EUSW4V3 BGN Curncy',
                    N'EUR IBOR4Y',
                    '',
                    '',
                    1,
                    '0',
                    0,
                    @stateMaker,
                    @stateDate,
                    @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisId
                     AND SymbolCode = N'EUSW5V3 BGN Curncy'
                     AND SymbolName = N'EUR IBOR5Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId,
             ModuleId,
             SymbolTypeId,
             SymbolCode,
             SymbolName,
             SymbolGroup,
             Description,
             IsEnabled,
             CcyPair,
             AlternateSymbol,
             StateMaker,
             StateDate,
             StateId)
            VALUES (@dataSourceId,
                    @moduleId,
                    @symbolTypeOisId,
                    N'EUSW5V3 BGN Curncy',
                    N'EUR IBOR5Y',
                    '',
                    '',
                    1,
                    '0',
                    0,
                    @stateMaker,
                    @stateDate,
                    @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisId
                     AND SymbolCode = N'EUSW6V3 BGN Curncy'
                     AND SymbolName = N'EUR IBOR6Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId,
             ModuleId,
             SymbolTypeId,
             SymbolCode,
             SymbolName,
             SymbolGroup,
             Description,
             IsEnabled,
             CcyPair,
             AlternateSymbol,
             StateMaker,
             StateDate,
             StateId)
            VALUES (@dataSourceId,
                    @moduleId,
                    @symbolTypeOisId,
                    N'EUSW6V3 BGN Curncy',
                    N'EUR IBOR6Y',
                    '',
                    '',
                    1,
                    '0',
                    0,
                    @stateMaker,
                    @stateDate,
                    @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisId
                     AND SymbolCode = N'EUSW7V3 BGN Curncy'
                     AND SymbolName = N'EUR IBOR7Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId,
             ModuleId,
             SymbolTypeId,
             SymbolCode,
             SymbolName,
             SymbolGroup,
             Description,
             IsEnabled,
             CcyPair,
             AlternateSymbol,
             StateMaker,
             StateDate,
             StateId)
            VALUES (@dataSourceId,
                    @moduleId,
                    @symbolTypeOisId,
                    N'EUSW7V3 BGN Curncy',
                    N'EUR IBOR7Y',
                    '',
                    '',
                    1,
                    '0',
                    0,
                    @stateMaker,
                    @stateDate,
                    @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisId
                     AND SymbolCode = N'EUSW8V3 BGN Curncy'
                     AND SymbolName = N'EUR IBOR8Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId,
             ModuleId,
             SymbolTypeId,
             SymbolCode,
             SymbolName,
             SymbolGroup,
             Description,
             IsEnabled,
             CcyPair,
             AlternateSymbol,
             StateMaker,
             StateDate,
             StateId)
            VALUES (@dataSourceId,
                    @moduleId,
                    @symbolTypeOisId,
                    N'EUSW8V3 BGN Curncy',
                    N'EUR IBOR8Y',
                    '',
                    '',
                    1,
                    '0',
                    0,
                    @stateMaker,
                    @stateDate,
                    @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisId
                     AND SymbolCode = N'EUSW9V3 BGN Curncy'
                     AND SymbolName = N'EUR IBOR9Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId,
             ModuleId,
             SymbolTypeId,
             SymbolCode,
             SymbolName,
             SymbolGroup,
             Description,
             IsEnabled,
             CcyPair,
             AlternateSymbol,
             StateMaker,
             StateDate,
             StateId)
            VALUES (@dataSourceId,
                    @moduleId,
                    @symbolTypeOisId,
                    N'EUSW9V3 BGN Curncy',
                    N'EUR IBOR9Y',
                    '',
                    '',
                    1,
                    '0',
                    0,
                    @stateMaker,
                    @stateDate,
                    @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisId
                     AND SymbolCode = N'EUSW10V3 BGN Curncy'
                     AND SymbolName = N'EUR IBOR10Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId,
             ModuleId,
             SymbolTypeId,
             SymbolCode,
             SymbolName,
             SymbolGroup,
             Description,
             IsEnabled,
             CcyPair,
             AlternateSymbol,
             StateMaker,
             StateDate,
             StateId)
            VALUES (@dataSourceId,
                    @moduleId,
                    @symbolTypeOisId,
                    N'EUSW10V3 BGN Curncy',
                    N'EUR IBOR10Y',
                    '',
                    '',
                    1,
                    '0',
                    0,
                    @stateMaker,
                    @stateDate,
                    @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisId
                     AND SymbolCode = N'EUSW11V3 BGN Curncy'
                     AND SymbolName = N'EUR IBOR11Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId,
             ModuleId,
             SymbolTypeId,
             SymbolCode,
             SymbolName,
             SymbolGroup,
             Description,
             IsEnabled,
             CcyPair,
             AlternateSymbol,
             StateMaker,
             StateDate,
             StateId)
            VALUES (@dataSourceId,
                    @moduleId,
                    @symbolTypeOisId,
                    N'EUSW11V3 BGN Curncy',
                    N'EUR IBOR11Y',
                    '',
                    '',
                    1,
                    '0',
                    0,
                    @stateMaker,
                    @stateDate,
                    @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisId
                     AND SymbolCode = N'EUSW12V3 BGN Curncy'
                     AND SymbolName = N'EUR IBOR12Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId,
             ModuleId,
             SymbolTypeId,
             SymbolCode,
             SymbolName,
             SymbolGroup,
             Description,
             IsEnabled,
             CcyPair,
             AlternateSymbol,
             StateMaker,
             StateDate,
             StateId)
            VALUES (@dataSourceId,
                    @moduleId,
                    @symbolTypeOisId,
                    N'EUSW12V3 BGN Curncy',
                    N'EUR IBOR12Y',
                    '',
                    '',
                    1,
                    '0',
                    0,
                    @stateMaker,
                    @stateDate,
                    @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisId
                     AND SymbolCode = N'EUSW15V3 BGN Curncy'
                     AND SymbolName = N'EUR IBOR15Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId,
             ModuleId,
             SymbolTypeId,
             SymbolCode,
             SymbolName,
             SymbolGroup,
             Description,
             IsEnabled,
             CcyPair,
             AlternateSymbol,
             StateMaker,
             StateDate,
             StateId)
            VALUES (@dataSourceId,
                    @moduleId,
                    @symbolTypeOisId,
                    N'EUSW15V3 BGN Curncy',
                    N'EUR IBOR15Y',
                    '',
                    '',
                    1,
                    '0',
                    0,
                    @stateMaker,
                    @stateDate,
                    @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisId
                     AND SymbolCode = N'EUSW20V3 BGN Curncy'
                     AND SymbolName = N'EUR IBOR20Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId,
             ModuleId,
             SymbolTypeId,
             SymbolCode,
             SymbolName,
             SymbolGroup,
             Description,
             IsEnabled,
             CcyPair,
             AlternateSymbol,
             StateMaker,
             StateDate,
             StateId)
            VALUES (@dataSourceId,
                    @moduleId,
                    @symbolTypeOisId,
                    N'EUSW20V3 BGN Curncy',
                    N'EUR IBOR20Y',
                    '',
                    '',
                    1,
                    '0',
                    0,
                    @stateMaker,
                    @stateDate,
                    @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisId
                     AND SymbolCode = N'EUSW25V3 BGN Curncy'
                     AND SymbolName = N'EUR IBOR25Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId,
             ModuleId,
             SymbolTypeId,
             SymbolCode,
             SymbolName,
             SymbolGroup,
             Description,
             IsEnabled,
             CcyPair,
             AlternateSymbol,
             StateMaker,
             StateDate,
             StateId)
            VALUES (@dataSourceId,
                    @moduleId,
                    @symbolTypeOisId,
                    N'EUSW25V3 BGN Curncy',
                    N'EUR IBOR25Y',
                    '',
                    '',
                    1,
                    '0',
                    0,
                    @stateMaker,
                    @stateDate,
                    @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisId
                     AND SymbolCode = N'EUSW30V3 BGN Curncy'
                     AND SymbolName = N'EUR IBOR30Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId,
             ModuleId,
             SymbolTypeId,
             SymbolCode,
             SymbolName,
             SymbolGroup,
             Description,
             IsEnabled,
             CcyPair,
             AlternateSymbol,
             StateMaker,
             StateDate,
             StateId)
            VALUES (@dataSourceId,
                    @moduleId,
                    @symbolTypeOisId,
                    N'EUSW30V3 BGN Curncy',
                    N'EUR IBOR30Y',
                    '',
                    '',
                    1,
                    '0',
                    0,
                    @stateMaker,
                    @stateDate,
                    @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisId
                     AND SymbolCode = N'EUSW40V3 BGN Curncy'
                     AND SymbolName = N'EUR IBOR40Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId,
             ModuleId,
             SymbolTypeId,
             SymbolCode,
             SymbolName,
             SymbolGroup,
             Description,
             IsEnabled,
             CcyPair,
             AlternateSymbol,
             StateMaker,
             StateDate,
             StateId)
            VALUES (@dataSourceId,
                    @moduleId,
                    @symbolTypeOisId,
                    N'EUSW40V3 BGN Curncy',
                    N'EUR IBOR40Y',
                    '',
                    '',
                    1,
                    '0',
                    0,
                    @stateMaker,
                    @stateDate,
                    @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisId
                     AND SymbolCode = N'EUSW50V3 BGN Curncy'
                     AND SymbolName = N'EUR IBOR50Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId,
             ModuleId,
             SymbolTypeId,
             SymbolCode,
             SymbolName,
             SymbolGroup,
             Description,
             IsEnabled,
             CcyPair,
             AlternateSymbol,
             StateMaker,
             StateDate,
             StateId)
            VALUES (@dataSourceId,
                    @moduleId,
                    @symbolTypeOisId,
                    N'EUSW50V3 BGN Curncy',
                    N'EUR IBOR50Y',
                    '',
                    '',
                    1,
                    '0',
                    0,
                    @stateMaker,
                    @stateDate,
                    @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisId
                     AND SymbolCode = N'BPSWS1Z BGN Curncy'
                     AND SymbolName = N'GBP SONIA1W')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId,
             ModuleId,
             SymbolTypeId,
             SymbolCode,
             SymbolName,
             SymbolGroup,
             Description,
             IsEnabled,
             CcyPair,
             AlternateSymbol,
             StateMaker,
             StateDate,
             StateId)
            VALUES (@dataSourceId,
                    @moduleId,
                    @symbolTypeOisId,
                    N'BPSWS1Z BGN Curncy',
                    N'GBP SONIA1W',
                    '',
                    '',
                    1,
                    '0',
                    0,
                    @stateMaker,
                    @stateDate,
                    @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisId
                     AND SymbolCode = N'BPSWS2Z BGN Curncy'
                     AND SymbolName = N'GBP SONIA2W')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId,
             ModuleId,
             SymbolTypeId,
             SymbolCode,
             SymbolName,
             SymbolGroup,
             Description,
             IsEnabled,
             CcyPair,
             AlternateSymbol,
             StateMaker,
             StateDate,
             StateId)
            VALUES (@dataSourceId,
                    @moduleId,
                    @symbolTypeOisId,
                    N'BPSWS2Z BGN Curncy',
                    N'GBP SONIA2W',
                    '',
                    '',
                    1,
                    '0',
                    0,
                    @stateMaker,
                    @stateDate,
                    @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisId
                     AND SymbolCode = N'BPSWSA BGN Curncy'
                     AND SymbolName = N'GBP SONIA1M')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId,
             ModuleId,
             SymbolTypeId,
             SymbolCode,
             SymbolName,
             SymbolGroup,
             Description,
             IsEnabled,
             CcyPair,
             AlternateSymbol,
             StateMaker,
             StateDate,
             StateId)
            VALUES (@dataSourceId,
                    @moduleId,
                    @symbolTypeOisId,
                    N'BPSWSA BGN Curncy',
                    N'GBP SONIA1M',
                    '',
                    '',
                    1,
                    '0',
                    0,
                    @stateMaker,
                    @stateDate,
                    @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisId
                     AND SymbolCode = N'BPSWSB BGN Curncy'
                     AND SymbolName = N'GBP SONIA2M')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId,
             ModuleId,
             SymbolTypeId,
             SymbolCode,
             SymbolName,
             SymbolGroup,
             Description,
             IsEnabled,
             CcyPair,
             AlternateSymbol,
             StateMaker,
             StateDate,
             StateId)
            VALUES (@dataSourceId,
                    @moduleId,
                    @symbolTypeOisId,
                    N'BPSWSB BGN Curncy',
                    N'GBP SONIA2M',
                    '',
                    '',
                    1,
                    '0',
                    0,
                    @stateMaker,
                    @stateDate,
                    @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisId
                     AND SymbolCode = N'BPSWSC BGN Curncy'
                     AND SymbolName = N'GBP SONIA3M')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId,
             ModuleId,
             SymbolTypeId,
             SymbolCode,
             SymbolName,
             SymbolGroup,
             Description,
             IsEnabled,
             CcyPair,
             AlternateSymbol,
             StateMaker,
             StateDate,
             StateId)
            VALUES (@dataSourceId,
                    @moduleId,
                    @symbolTypeOisId,
                    N'BPSWSC BGN Curncy',
                    N'GBP SONIA3M',
                    '',
                    '',
                    1,
                    '0',
                    0,
                    @stateMaker,
                    @stateDate,
                    @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisId
                     AND SymbolCode = N'BPSWSD BGN Curncy'
                     AND SymbolName = N'GBP SONIA4M')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId,
             ModuleId,
             SymbolTypeId,
             SymbolCode,
             SymbolName,
             SymbolGroup,
             Description,
             IsEnabled,
             CcyPair,
             AlternateSymbol,
             StateMaker,
             StateDate,
             StateId)
            VALUES (@dataSourceId,
                    @moduleId,
                    @symbolTypeOisId,
                    N'BPSWSD BGN Curncy',
                    N'GBP SONIA4M',
                    '',
                    '',
                    1,
                    '0',
                    0,
                    @stateMaker,
                    @stateDate,
                    @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisId
                     AND SymbolCode = N'BPSWSE BGN Curncy'
                     AND SymbolName = N'GBP SONIA5M')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId,
             ModuleId,
             SymbolTypeId,
             SymbolCode,
             SymbolName,
             SymbolGroup,
             Description,
             IsEnabled,
             CcyPair,
             AlternateSymbol,
             StateMaker,
             StateDate,
             StateId)
            VALUES (@dataSourceId,
                    @moduleId,
                    @symbolTypeOisId,
                    N'BPSWSE BGN Curncy',
                    N'GBP SONIA5M',
                    '',
                    '',
                    1,
                    '0',
                    0,
                    @stateMaker,
                    @stateDate,
                    @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisId
                     AND SymbolCode = N'BPSWSF BGN Curncy'
                     AND SymbolName = N'GBP SONIA6M')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId,
             ModuleId,
             SymbolTypeId,
             SymbolCode,
             SymbolName,
             SymbolGroup,
             Description,
             IsEnabled,
             CcyPair,
             AlternateSymbol,
             StateMaker,
             StateDate,
             StateId)
            VALUES (@dataSourceId,
                    @moduleId,
                    @symbolTypeOisId,
                    N'BPSWSF BGN Curncy',
                    N'GBP SONIA6M',
                    '',
                    '',
                    1,
                    '0',
                    0,
                    @stateMaker,
                    @stateDate,
                    @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisId
                     AND SymbolCode = N'BPSWSG BGN Curncy'
                     AND SymbolName = N'GBP SONIA7M')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId,
             ModuleId,
             SymbolTypeId,
             SymbolCode,
             SymbolName,
             SymbolGroup,
             Description,
             IsEnabled,
             CcyPair,
             AlternateSymbol,
             StateMaker,
             StateDate,
             StateId)
            VALUES (@dataSourceId,
                    @moduleId,
                    @symbolTypeOisId,
                    N'BPSWSG BGN Curncy',
                    N'GBP SONIA7M',
                    '',
                    '',
                    1,
                    '0',
                    0,
                    @stateMaker,
                    @stateDate,
                    @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisId
                     AND SymbolCode = N'BPSWSH BGN Curncy'
                     AND SymbolName = N'GBP SONIA8M')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId,
             ModuleId,
             SymbolTypeId,
             SymbolCode,
             SymbolName,
             SymbolGroup,
             Description,
             IsEnabled,
             CcyPair,
             AlternateSymbol,
             StateMaker,
             StateDate,
             StateId)
            VALUES (@dataSourceId,
                    @moduleId,
                    @symbolTypeOisId,
                    N'BPSWSH BGN Curncy',
                    N'GBP SONIA8M',
                    '',
                    '',
                    1,
                    '0',
                    0,
                    @stateMaker,
                    @stateDate,
                    @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisId
                     AND SymbolCode = N'BPSWSI BGN Curncy'
                     AND SymbolName = N'GBP SONIA9M')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId,
             ModuleId,
             SymbolTypeId,
             SymbolCode,
             SymbolName,
             SymbolGroup,
             Description,
             IsEnabled,
             CcyPair,
             AlternateSymbol,
             StateMaker,
             StateDate,
             StateId)
            VALUES (@dataSourceId,
                    @moduleId,
                    @symbolTypeOisId,
                    N'BPSWSI BGN Curncy',
                    N'GBP SONIA9M',
                    '',
                    '',
                    1,
                    '0',
                    0,
                    @stateMaker,
                    @stateDate,
                    @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisId
                     AND SymbolCode = N'BPSWSJ BGN Curncy'
                     AND SymbolName = N'GBP SONIA10M')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId,
             ModuleId,
             SymbolTypeId,
             SymbolCode,
             SymbolName,
             SymbolGroup,
             Description,
             IsEnabled,
             CcyPair,
             AlternateSymbol,
             StateMaker,
             StateDate,
             StateId)
            VALUES (@dataSourceId,
                    @moduleId,
                    @symbolTypeOisId,
                    N'BPSWSJ BGN Curncy',
                    N'GBP SONIA10M',
                    '',
                    '',
                    1,
                    '0',
                    0,
                    @stateMaker,
                    @stateDate,
                    @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisId
                     AND SymbolCode = N'BPSWSK BGN Curncy'
                     AND SymbolName = N'GBP SONIA11M')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId,
             ModuleId,
             SymbolTypeId,
             SymbolCode,
             SymbolName,
             SymbolGroup,
             Description,
             IsEnabled,
             CcyPair,
             AlternateSymbol,
             StateMaker,
             StateDate,
             StateId)
            VALUES (@dataSourceId,
                    @moduleId,
                    @symbolTypeOisId,
                    N'BPSWSK BGN Curncy',
                    N'GBP SONIA11M',
                    '',
                    '',
                    1,
                    '0',
                    0,
                    @stateMaker,
                    @stateDate,
                    @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisId
                     AND SymbolCode = N'BPSWS1 BGN Curncy'
                     AND SymbolName = N'GBP SONIA12M')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId, ModuleId, SymbolTypeId,
             SymbolCode, SymbolName,
             SymbolGroup, Description, IsEnabled,
             CcyPair, AlternateSymbol,
             StateMaker, StateDate, StateId)
            VALUES (@dataSourceId, @moduleId, @symbolTypeOisId,
                    N'BPSWS1 BGN Curncy', N'GBP SONIA12M',
                    '', '', 1, '0',
                    0, @stateMaker, @stateDate, @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisId
                     AND SymbolCode = N'BPSWS1F BGN Curncy'
                     AND SymbolName = N'GBP SONIA18M')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId, ModuleId, SymbolTypeId,
             SymbolCode, SymbolName,
             SymbolGroup, Description, IsEnabled,
             CcyPair, AlternateSymbol,
             StateMaker, StateDate, StateId)
            VALUES (@dataSourceId, @moduleId, @symbolTypeOisId,
                    N'BPSWS1F BGN Curncy', N'GBP SONIA18M',
                    '', '', 1, '0',
                    0, @stateMaker, @stateDate, @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisId
                     AND SymbolCode = N'BPSWS2 BGN Curncy'
                     AND SymbolName = N'GBP SONIA2Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId, ModuleId, SymbolTypeId,
             SymbolCode, SymbolName,
             SymbolGroup, Description, IsEnabled,
             CcyPair, AlternateSymbol,
             StateMaker, StateDate, StateId)
            VALUES (@dataSourceId, @moduleId, @symbolTypeOisId,
                    N'BPSWS2 BGN Curncy', N'GBP SONIA2Y',
                    '', '', 1,
                    '0', 0, @stateMaker, @stateDate, @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisId
                     AND SymbolCode = N'BPSWS3 BGN Curncy'
                     AND SymbolName = N'GBP SONIA3Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId, ModuleId, SymbolTypeId,
             SymbolCode, SymbolName,
             SymbolGroup, Description, IsEnabled,
             CcyPair, AlternateSymbol,
             StateMaker, StateDate, StateId)
            VALUES (@dataSourceId, @moduleId, @symbolTypeOisId,
                    N'BPSWS3 BGN Curncy', N'GBP SONIA3Y',
                    '', '', 1,
                    '0', 0,
                    @stateMaker, @stateDate, @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisId
                     AND SymbolCode = N'BPSWS4 BGN Curncy'
                     AND SymbolName = N'GBP SONIA4Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId, ModuleId, SymbolTypeId,
             SymbolCode, SymbolName,
             SymbolGroup, Description, IsEnabled,
             CcyPair, AlternateSymbol,
             StateMaker, StateDate, StateId)
            VALUES (@dataSourceId, @moduleId, @symbolTypeOisId,
                    N'BPSWS4 BGN Curncy', N'GBP SONIA4Y',
                    '', '', 1,
                    '0', 0,
                    @stateMaker, @stateDate, @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisId
                     AND SymbolCode = N'BPSWS5 BGN Curncy'
                     AND SymbolName = N'GBP SONIA5Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId, ModuleId, SymbolTypeId,
             SymbolCode, SymbolName,
             SymbolGroup, Description, IsEnabled,
             CcyPair, AlternateSymbol,
             StateMaker, StateDate, StateId)
            VALUES (@dataSourceId, @moduleId, @symbolTypeOisId,
                    N'BPSWS5 BGN Curncy', N'GBP SONIA5Y',
                    '', '', 1,
                    '0', 0,
                    @stateMaker, @stateDate, @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisId
                     AND SymbolCode = N'BPSWS6 BGN Curncy'
                     AND SymbolName = N'GBP SONIA6Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId, ModuleId, SymbolTypeId,
             SymbolCode, SymbolName,
             SymbolGroup, Description, IsEnabled,
             CcyPair, AlternateSymbol,
             StateMaker, StateDate, StateId)
            VALUES (@dataSourceId, @moduleId, @symbolTypeOisId,
                    N'BPSWS6 BGN Curncy', N'GBP SONIA6Y',
                    '', '', 1,
                    '0', 0,
                    @stateMaker, @stateDate, @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisId
                     AND SymbolCode = N'BPSWS7 BGN Curncy'
                     AND SymbolName = N'GBP SONIA7Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId, ModuleId, SymbolTypeId,
             SymbolCode, SymbolName,
             SymbolGroup, Description, IsEnabled,
             CcyPair, AlternateSymbol,
             StateMaker, StateDate, StateId)
            VALUES (@dataSourceId, @moduleId, @symbolTypeOisId,
                    N'BPSWS7 BGN Curncy', N'GBP SONIA7Y',
                    '', '', 1,
                    '0', 0,
                    @stateMaker, @stateDate, @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisId
                     AND SymbolCode = N'BPSWS8 BGN Curncy'
                     AND SymbolName = N'GBP SONIA8Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId, ModuleId, SymbolTypeId,
             SymbolCode, SymbolName,
             SymbolGroup, Description, IsEnabled,
             CcyPair, AlternateSymbol,
             StateMaker, StateDate, StateId)
            VALUES (@dataSourceId, @moduleId, @symbolTypeOisId,
                    N'BPSWS8 BGN Curncy', N'GBP SONIA8Y',
                    '', '', 1,
                    '0', 0,
                    @stateMaker, @stateDate, @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisId
                     AND SymbolCode = N'BPSWS9 BGN Curncy'
                     AND SymbolName = N'GBP SONIA9Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId, ModuleId, SymbolTypeId,
             SymbolCode, SymbolName,
             SymbolGroup, Description, IsEnabled,
             CcyPair, AlternateSymbol,
             StateMaker, StateDate, StateId)
            VALUES (@dataSourceId, @moduleId, @symbolTypeOisId,
                    N'BPSWS9 BGN Curncy', N'GBP SONIA9Y',
                    '', '', 1,
                    '0', 0,
                    @stateMaker, @stateDate, @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisId
                     AND SymbolCode = N'BPSWS10 BGN Curncy'
                     AND SymbolName = N'GBP SONIA10Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId, ModuleId, SymbolTypeId,
             SymbolCode, SymbolName,
             SymbolGroup, Description, IsEnabled,
             CcyPair, AlternateSymbol,
             StateMaker, StateDate, StateId)
            VALUES (@dataSourceId, @moduleId, @symbolTypeOisId,
                    N'BPSWS10 BGN Curncy', N'GBP SONIA10Y',
                    '', '', 1,
                    '0', 0,
                    @stateMaker, @stateDate, @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisId
                     AND SymbolCode = N'BPSWS12 BGN Curncy'
                     AND SymbolName = N'GBP SONIA12Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId, ModuleId, SymbolTypeId,
             SymbolCode, SymbolName,
             SymbolGroup, Description, IsEnabled,
             CcyPair, AlternateSymbol,
             StateMaker, StateDate, StateId)
            VALUES (@dataSourceId, @moduleId, @symbolTypeOisId,
                    N'BPSWS12 BGN Curncy', N'GBP SONIA12Y',
                    '', '', 1,
                    '0', 0,
                    @stateMaker, @stateDate, @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisId
                     AND SymbolCode = N'BPSWS15 BGN Curncy'
                     AND SymbolName = N'GBP SONIA15Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId, ModuleId, SymbolTypeId,
             SymbolCode, SymbolName,
             SymbolGroup, Description, IsEnabled,
             CcyPair, AlternateSymbol,
             StateMaker, StateDate, StateId)
            VALUES (@dataSourceId, @moduleId, @symbolTypeOisId,
                    N'BPSWS15 BGN Curncy', N'GBP SONIA15Y',
                    '', '', 1,
                    '0', 0,
                    @stateMaker, @stateDate, @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisId
                     AND SymbolCode = N'BPSWS20 BGN Curncy'
                     AND SymbolName = N'GBP SONIA20Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId, ModuleId, SymbolTypeId,
             SymbolCode, SymbolName,
             SymbolGroup, Description, IsEnabled,
             CcyPair, AlternateSymbol,
             StateMaker, StateDate, StateId)
            VALUES (@dataSourceId, @moduleId, @symbolTypeOisId,
                    N'BPSWS20 BGN Curncy', N'GBP SONIA20Y',
                    '', '', 1,
                    '0', 0,
                    @stateMaker, @stateDate, @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisId
                     AND SymbolCode = N'BPSWS25 BGN Curncy'
                     AND SymbolName = N'GBP SONIA25Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId, ModuleId, SymbolTypeId,
             SymbolCode, SymbolName,
             SymbolGroup, Description, IsEnabled,
             CcyPair, AlternateSymbol,
             StateMaker, StateDate, StateId)
            VALUES (@dataSourceId, @moduleId, @symbolTypeOisId,
                    N'BPSWS25 BGN Curncy', N'GBP SONIA25Y',
                    '', '', 1,
                    '0', 0,
                    @stateMaker, @stateDate, @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisId
                     AND SymbolCode = N'BPSWS30 BGN Curncy'
                     AND SymbolName = N'GBP SONIA30Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId, ModuleId, SymbolTypeId,
             SymbolCode, SymbolName,
             SymbolGroup, Description, IsEnabled,
             CcyPair, AlternateSymbol,
             StateMaker, StateDate, StateId)
            VALUES (@dataSourceId, @moduleId, @symbolTypeOisId,
                    N'BPSWS30 BGN Curncy', N'GBP SONIA30Y',
                    '', '', 1,
                    '0', 0,
                    @stateMaker, @stateDate, @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisId
                     AND SymbolCode = N'BPSWS40 BGN Curncy'
                     AND SymbolName = N'GBP SONIA40Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId, ModuleId, SymbolTypeId,
             SymbolCode, SymbolName,
             SymbolGroup, Description, IsEnabled,
             CcyPair, AlternateSymbol,
             StateMaker, StateDate, StateId)
            VALUES (@dataSourceId, @moduleId, @symbolTypeOisId,
                    N'BPSWS40 BGN Curncy', N'GBP SONIA40Y',
                    '', '', 1,
                    '0', 0,
                    @stateMaker, @stateDate, @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisId
                     AND SymbolCode = N'BPSWS50 BGN Curncy'
                     AND SymbolName = N'GBP SONIA50Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId, ModuleId, SymbolTypeId,
             SymbolCode, SymbolName,
             SymbolGroup, Description, IsEnabled,
             CcyPair, AlternateSymbol,
             StateMaker, StateDate, StateId)
            VALUES (@dataSourceId, @moduleId, @symbolTypeOisId,
                    N'BPSWS50 BGN Curncy', N'GBP SONIA50Y',
                    '', '', 1,
                    '0', 0,
                    @stateMaker, @stateDate, @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisId
                     AND SymbolCode = N'TYSO1 BGN Curncy'
                     AND SymbolName = N'TRY OIS1Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId, ModuleId, SymbolTypeId,
             SymbolCode, SymbolName,
             SymbolGroup, Description, IsEnabled,
             CcyPair, AlternateSymbol,
             StateMaker, StateDate, StateId)
            VALUES (@dataSourceId, @moduleId, @symbolTypeOisId,
                    N'TYSO1 BGN Curncy', N'TRY OIS1Y',
                    '', '', 1,
                    '0', 0,
                    @stateMaker, @stateDate, @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisId
                     AND SymbolCode = N'TYSO1Z BGN Curncy'
                     AND SymbolName = N'TRY OIS1W')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId, ModuleId, SymbolTypeId,
             SymbolCode, SymbolName,
             SymbolGroup, Description, IsEnabled,
             CcyPair, AlternateSymbol,
             StateMaker, StateDate, StateId)
            VALUES (@dataSourceId, @moduleId, @symbolTypeOisId,
                    N'TYSO1Z BGN Curncy', N'TRY OIS1W',
                    '', '', 1,
                    '0', 0,
                    @stateMaker, @stateDate, @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisId
                     AND SymbolCode = N'TYSO2Z BGN Curncy'
                     AND SymbolName = N'TRY OIS2W')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId, ModuleId, SymbolTypeId,
             SymbolCode, SymbolName,
             SymbolGroup, Description, IsEnabled,
             CcyPair, AlternateSymbol,
             StateMaker, StateDate, StateId)
            VALUES (@dataSourceId, @moduleId, @symbolTypeOisId,
                    N'TYSO2Z BGN Curncy', N'TRY OIS2W',
                    '', '', 1,
                    '0', 0,
                    @stateMaker, @stateDate, @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisId
                     AND SymbolCode = N'TYSOA BGN Curncy'
                     AND SymbolName = N'TRY OIS1M')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId, ModuleId, SymbolTypeId,
             SymbolCode, SymbolName,
             SymbolGroup, Description, IsEnabled,
             CcyPair, AlternateSymbol,
             StateMaker, StateDate, StateId)
            VALUES (@dataSourceId, @moduleId, @symbolTypeOisId,
                    N'TYSOA BGN Curncy', N'TRY OIS1M',
                    '', '', 1,
                    '0', 0,
                    @stateMaker, @stateDate, @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisId
                     AND SymbolCode = N'TYSOB BGN Curncy'
                     AND SymbolName = N'TRY OIS2M')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId, ModuleId, SymbolTypeId,
             SymbolCode, SymbolName,
             SymbolGroup, Description, IsEnabled,
             CcyPair, AlternateSymbol,
             StateMaker, StateDate, StateId)
            VALUES (@dataSourceId, @moduleId, @symbolTypeOisId,
                    N'TYSOB BGN Curncy', N'TRY OIS2M',
                    '', '', 1,
                    '0', 0,
                    @stateMaker, @stateDate, @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisId
                     AND SymbolCode = N'TYSOC BGN Curncy'
                     AND SymbolName = N'TRY OIS3M')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId, ModuleId, SymbolTypeId,
             SymbolCode, SymbolName,
             SymbolGroup, Description, IsEnabled,
             CcyPair, AlternateSymbol,
             StateMaker, StateDate, StateId)
            VALUES (@dataSourceId, @moduleId, @symbolTypeOisId,
                    N'TYSOC BGN Curncy', N'TRY OIS3M',
                    '', '', 1,
                    '0', 0,
                    @stateMaker, @stateDate, @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisId
                     AND SymbolCode = N'TYSOF BGN Curncy'
                     AND SymbolName = N'TRY OIS6M')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId, ModuleId, SymbolTypeId,
             SymbolCode, SymbolName,
             SymbolGroup, Description, IsEnabled,
             CcyPair, AlternateSymbol,
             StateMaker, StateDate, StateId)
            VALUES (@dataSourceId, @moduleId, @symbolTypeOisId,
                    N'TYSOF BGN Curncy', N'TRY OIS6M',
                    '', '', 1,
                    '0', 0,
                    @stateMaker, @stateDate, @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisId
                     AND SymbolCode = N'TYSOI BGN Curncy'
                     AND SymbolName = N'TRY OIS9M')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId, ModuleId, SymbolTypeId,
             SymbolCode, SymbolName,
             SymbolGroup, Description, IsEnabled,
             CcyPair, AlternateSymbol,
             StateMaker, StateDate, StateId)
            VALUES (@dataSourceId, @moduleId, @symbolTypeOisId,
                    N'TYSOI BGN Curncy', N'TRY OIS9M',
                    '', '', 1,
                    '0', 0,
                    @stateMaker, @stateDate, @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisId
                     AND SymbolCode = N'TRYION ICPL Curncy'
                     AND SymbolName = N'TRY OISON')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId, ModuleId, SymbolTypeId,
             SymbolCode, SymbolName,
             SymbolGroup, Description, IsEnabled,
             CcyPair, AlternateSymbol,
             StateMaker, StateDate, StateId)
            VALUES (@dataSourceId, @moduleId, @symbolTypeOisId,
                    N'TRYION ICPL Curncy', N'TRY OISON',
                    '', '', 1,
                    '0', 0,
                    @stateMaker, @stateDate, @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisId
                     AND SymbolCode = N'TYSO1F BGN Curncy'
                     AND SymbolName = N'TRY OIS18M')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId, ModuleId, SymbolTypeId,
             SymbolCode, SymbolName,
             SymbolGroup, Description, IsEnabled,
             CcyPair, AlternateSymbol,
             StateMaker, StateDate, StateId)
            VALUES (@dataSourceId, @moduleId, @symbolTypeOisId,
                    N'TYSO1F BGN Curncy', N'TRY OIS18M',
                    '', '', 1,
                    '0', 0,
                    @stateMaker, @stateDate, @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisId
                     AND SymbolCode = N'TYSO2 BGN Curncy'
                     AND SymbolName = N'TRY OIS2Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId, ModuleId, SymbolTypeId,
             SymbolCode, SymbolName,
             SymbolGroup, Description, IsEnabled,
             CcyPair, AlternateSymbol,
             StateMaker, StateDate, StateId)
            VALUES (@dataSourceId, @moduleId, @symbolTypeOisId,
                    N'TYSO2 BGN Curncy', N'TRY OIS2Y',
                    '', '', 1,
                    '0', 0,
                    @stateMaker, @stateDate, @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisId
                     AND SymbolCode = N'TYSO3 BGN Curncy'
                     AND SymbolName = N'TRY OIS3Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId, ModuleId, SymbolTypeId,
             SymbolCode, SymbolName,
             SymbolGroup, Description, IsEnabled,
             CcyPair, AlternateSymbol,
             StateMaker, StateDate, StateId)
            VALUES (@dataSourceId, @moduleId, @symbolTypeOisId,
                    N'TYSO3 BGN Curncy', N'TRY OIS3Y',
                    '', '', 1,
                    '0', 0,
                    @stateMaker, @stateDate, @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisId
                     AND SymbolCode = N'TYSO4 BGN Curncy'
                     AND SymbolName = N'TRY OIS4Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId, ModuleId, SymbolTypeId,
             SymbolCode, SymbolName,
             SymbolGroup, Description, IsEnabled,
             CcyPair, AlternateSymbol,
             StateMaker, StateDate, StateId)
            VALUES (@dataSourceId, @moduleId, @symbolTypeOisId,
                    N'TYSO4 BGN Curncy', N'TRY OIS4Y',
                    '', '', 1,
                    '0', 0,
                    @stateMaker, @stateDate, @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisId
                     AND SymbolCode = N'TYSO5 BGN Curncy'
                     AND SymbolName = N'TRY OIS5Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId, ModuleId, SymbolTypeId,
             SymbolCode, SymbolName,
             SymbolGroup, Description, IsEnabled,
             CcyPair, AlternateSymbol,
             StateMaker, StateDate, StateId)
            VALUES (@dataSourceId, @moduleId, @symbolTypeOisId,
                    N'TYSO5 BGN Curncy', N'TRY OIS5Y',
                    '', '', 1,
                    '0', 0,
                    @stateMaker, @stateDate, @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisId
                     AND SymbolCode = N'TYSO6 BGN Curncy'
                     AND SymbolName = N'TRY OIS6Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId, ModuleId, SymbolTypeId,
             SymbolCode, SymbolName,
             SymbolGroup, Description, IsEnabled,
             CcyPair, AlternateSymbol,
             StateMaker, StateDate, StateId)
            VALUES (@dataSourceId, @moduleId, @symbolTypeOisId,
                    N'TYSO6 BGN Curncy', N'TRY OIS6Y',
                    '', '', 1,
                    '0', 0,
                    @stateMaker, @stateDate, @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisId
                     AND SymbolCode = N'TYSO7 BGN Curncy'
                     AND SymbolName = N'TRY OIS7Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId, ModuleId, SymbolTypeId,
             SymbolCode, SymbolName,
             SymbolGroup, Description, IsEnabled,
             CcyPair, AlternateSymbol,
             StateMaker, StateDate, StateId)
            VALUES (@dataSourceId, @moduleId, @symbolTypeOisId,
                    N'TYSO7 BGN Curncy', N'TRY OIS7Y',
                    '', '', 1,
                    '0', 0,
                    @stateMaker, @stateDate, @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisId
                     AND SymbolCode = N'TYSO8 BGN Curncy'
                     AND SymbolName = N'TRY OIS8Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId, ModuleId, SymbolTypeId,
             SymbolCode, SymbolName,
             SymbolGroup, Description, IsEnabled,
             CcyPair, AlternateSymbol,
             StateMaker, StateDate, StateId)
            VALUES (@dataSourceId, @moduleId, @symbolTypeOisId,
                    N'TYSO8 BGN Curncy', N'TRY OIS8Y',
                    '', '', 1,
                    '0', 0,
                    @stateMaker, @stateDate, @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisId
                     AND SymbolCode = N'TYSO9 BGN Curncy'
                     AND SymbolName = N'TRY OIS9Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId, ModuleId, SymbolTypeId,
             SymbolCode, SymbolName,
             SymbolGroup, Description, IsEnabled,
             CcyPair, AlternateSymbol,
             StateMaker, StateDate, StateId)
            VALUES (@dataSourceId, @moduleId, @symbolTypeOisId,
                    N'TYSO9 BGN Curncy', N'TRY OIS9Y',
                    '', '', 1,
                    '0', 0,
                    @stateMaker, @stateDate, @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisId
                     AND SymbolCode = N'TYSO10 BGN Curncy'
                     AND SymbolName = N'TRY OIS10Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId, ModuleId, SymbolTypeId,
             SymbolCode, SymbolName,
             SymbolGroup, Description, IsEnabled,
             CcyPair, AlternateSymbol,
             StateMaker, StateDate, StateId)
            VALUES (@dataSourceId, @moduleId, @symbolTypeOisId,
                    N'TYSO10 BGN Curncy', N'TRY OIS10Y',
                    '', '', 1,
                    '0', 0,
                    @stateMaker, @stateDate, @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisZeroId
                     AND SymbolCode = N'S0522Z 1D BLC2 Curncy'
                     AND SymbolName = N'TRY OISZEROON')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId, ModuleId, SymbolTypeId,
             SymbolCode, SymbolName,
             SymbolGroup, Description, IsEnabled,
             CcyPair, AlternateSymbol,
             StateMaker, StateDate, StateId)
            VALUES (@dataSourceId, @moduleId, @symbolTypeOisZeroId,
                    N'S0522Z 1D BLC2 Curncy', N'TRY OISZEROON',
                    '', '', 1,
                    '0', 0,
                    @stateMaker, @stateDate, @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisZeroId
                     AND SymbolCode = N'S0522Z 1W BLC2 Curncy'
                     AND SymbolName = N'TRY OISZERO1W')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId, ModuleId, SymbolTypeId,
             SymbolCode, SymbolName,
             SymbolGroup, Description, IsEnabled,
             CcyPair, AlternateSymbol,
             StateMaker, StateDate, StateId)
            VALUES (@dataSourceId, @moduleId, @symbolTypeOisZeroId,
                    N'S0522Z 1W BLC2 Curncy', N'TRY OISZERO1W',
                    '', '', 1,
                    '0', 0,
                    @stateMaker, @stateDate, @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisZeroId
                     AND SymbolCode = N'S0522Z 2W BLC2 Curncy'
                     AND SymbolName = N'TRY OISZERO2W')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId, ModuleId, SymbolTypeId,
             SymbolCode, SymbolName,
             SymbolGroup, Description, IsEnabled,
             CcyPair, AlternateSymbol,
             StateMaker, StateDate, StateId)
            VALUES (@dataSourceId, @moduleId, @symbolTypeOisZeroId,
                    N'S0522Z 2W BLC2 Curncy', N'TRY OISZERO2W',
                    '', '', 1,
                    '0', 0,
                    @stateMaker, @stateDate, @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisZeroId
                     AND SymbolCode = N'S0522Z 1M BLC2 Curncy'
                     AND SymbolName = N'TRY OISZERO1M')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId, ModuleId, SymbolTypeId,
             SymbolCode, SymbolName,
             SymbolGroup, Description, IsEnabled,
             CcyPair, AlternateSymbol,
             StateMaker, StateDate, StateId)
            VALUES (@dataSourceId, @moduleId, @symbolTypeOisZeroId,
                    N'S0522Z 1M BLC2 Curncy', N'TRY OISZERO1M',
                    '', '', 1,
                    '0', 0,
                    @stateMaker, @stateDate, @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisZeroId
                     AND SymbolCode = N'S0522Z 2M BLC2 Curncy'
                     AND SymbolName = N'TRY OISZERO2M')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId, ModuleId, SymbolTypeId,
             SymbolCode, SymbolName,
             SymbolGroup, Description, IsEnabled,
             CcyPair, AlternateSymbol,
             StateMaker, StateDate, StateId)
            VALUES (@dataSourceId, @moduleId, @symbolTypeOisZeroId,
                    N'S0522Z 2M BLC2 Curncy', N'TRY OISZERO2M',
                    '', '', 1,
                    '0', 0,
                    @stateMaker, @stateDate, @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisZeroId
                     AND SymbolCode = N'S0522Z 3M BLC2 Curncy'
                     AND SymbolName = N'TRY OISZERO3M')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId, ModuleId, SymbolTypeId,
             SymbolCode, SymbolName,
             SymbolGroup, Description, IsEnabled,
             CcyPair, AlternateSymbol,
             StateMaker, StateDate, StateId)
            VALUES (@dataSourceId, @moduleId, @symbolTypeOisZeroId,
                    N'S0522Z 3M BLC2 Curncy', N'TRY OISZERO3M',
                    '', '', 1,
                    '0', 0,
                    @stateMaker, @stateDate, @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisZeroId
                     AND SymbolCode = N'S0522Z 6M BLC2 Curncy'
                     AND SymbolName = N'TRY OISZERO6M')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId, ModuleId, SymbolTypeId,
             SymbolCode, SymbolName,
             SymbolGroup, Description, IsEnabled,
             CcyPair, AlternateSymbol,
             StateMaker, StateDate, StateId)
            VALUES (@dataSourceId, @moduleId, @symbolTypeOisZeroId,
                    N'S0522Z 6M BLC2 Curncy', N'TRY OISZERO6M',
                    '', '', 1,
                    '0', 0,
                    @stateMaker, @stateDate, @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisZeroId
                     AND SymbolCode = N'S0522Z 9M BLC2 Curncy'
                     AND SymbolName = N'TRY OISZERO9M')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId, ModuleId, SymbolTypeId,
             SymbolCode, SymbolName,
             SymbolGroup, Description, IsEnabled,
             CcyPair, AlternateSymbol,
             StateMaker, StateDate, StateId)
            VALUES (@dataSourceId, @moduleId, @symbolTypeOisZeroId,
                    N'S0522Z 9M BLC2 Curncy', N'TRY OISZERO9M',
                    '', '', 1,
                    '0', 0,
                    @stateMaker, @stateDate, @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisZeroId
                     AND SymbolCode = N'S0522Z 1Y BLC2 Curncy'
                     AND SymbolName = N'TRY OISZERO1Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId, ModuleId, SymbolTypeId,
             SymbolCode, SymbolName,
             SymbolGroup, Description, IsEnabled,
             CcyPair, AlternateSymbol,
             StateMaker, StateDate, StateId)
            VALUES (@dataSourceId, @moduleId, @symbolTypeOisZeroId,
                    N'S0522Z 1Y BLC2 Curncy', N'TRY OISZERO1Y',
                    '', '', 1,
                    '0', 0,
                    @stateMaker, @stateDate, @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisZeroId
                     AND SymbolCode = N'S0522Z 18M BLC2 Curncy'
                     AND SymbolName = N'TRY OISZERO18M')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId, ModuleId, SymbolTypeId,
             SymbolCode, SymbolName,
             SymbolGroup, Description, IsEnabled,
             CcyPair, AlternateSymbol,
             StateMaker, StateDate, StateId)
            VALUES (@dataSourceId, @moduleId, @symbolTypeOisZeroId,
                    N'S0522Z 18M BLC2 Curncy', N'TRY OISZERO18M',
                    '', '', 1,
                    '0', 0,
                    @stateMaker, @stateDate, @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisZeroId
                     AND SymbolCode = N'S0522Z 2Y BLC2 Curncy'
                     AND SymbolName = N'TRY OISZERO2Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId, ModuleId, SymbolTypeId,
             SymbolCode, SymbolName,
             SymbolGroup, Description, IsEnabled,
             CcyPair, AlternateSymbol,
             StateMaker, StateDate, StateId)
            VALUES (@dataSourceId, @moduleId, @symbolTypeOisZeroId,
                    N'S0522Z 2Y BLC2 Curncy', N'TRY OISZERO2Y',
                    '', '', 1,
                    '0', 0,
                    @stateMaker, @stateDate, @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisZeroId
                     AND SymbolCode = N'S0522Z 3Y BLC2 Curncy'
                     AND SymbolName = N'TRY OISZERO3Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId, ModuleId, SymbolTypeId,
             SymbolCode, SymbolName,
             SymbolGroup, Description, IsEnabled,
             CcyPair, AlternateSymbol,
             StateMaker, StateDate, StateId)
            VALUES (@dataSourceId, @moduleId, @symbolTypeOisZeroId,
                    N'S0522Z 3Y BLC2 Curncy', N'TRY OISZERO3Y',
                    '', '', 1,
                    '0', 0,
                    @stateMaker, @stateDate, @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisZeroId
                     AND SymbolCode = N'S0522Z 4Y BLC2 Curncy'
                     AND SymbolName = N'TRY OISZERO4Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId, ModuleId, SymbolTypeId,
             SymbolCode, SymbolName,
             SymbolGroup, Description, IsEnabled,
             CcyPair, AlternateSymbol,
             StateMaker, StateDate, StateId)
            VALUES (@dataSourceId, @moduleId, @symbolTypeOisZeroId,
                    N'S0522Z 4Y BLC2 Curncy', N'TRY OISZERO4Y',
                    '', '', 1,
                    '0', 0,
                    @stateMaker, @stateDate, @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisZeroId
                     AND SymbolCode = N'S0522Z 5Y BLC2 Curncy'
                     AND SymbolName = N'TRY OISZERO5Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId, ModuleId, SymbolTypeId,
             SymbolCode, SymbolName,
             SymbolGroup, Description, IsEnabled,
             CcyPair, AlternateSymbol,
             StateMaker, StateDate, StateId)
            VALUES (@dataSourceId, @moduleId, @symbolTypeOisZeroId,
                    N'S0522Z 5Y BLC2 Curncy', N'TRY OISZERO5Y',
                    '', '', 1,
                    '0', 0,
                    @stateMaker, @stateDate, @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisZeroId
                     AND SymbolCode = N'S0522Z 6Y BLC2 Curncy'
                     AND SymbolName = N'TRY OISZERO6Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId, ModuleId, SymbolTypeId,
             SymbolCode, SymbolName,
             SymbolGroup, Description, IsEnabled,
             CcyPair, AlternateSymbol,
             StateMaker, StateDate, StateId)
            VALUES (@dataSourceId, @moduleId, @symbolTypeOisZeroId,
                    N'S0522Z 6Y BLC2 Curncy', N'TRY OISZERO6Y',
                    '', '', 1,
                    '0', 0,
                    @stateMaker, @stateDate, @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisZeroId
                     AND SymbolCode = N'S0522Z 7Y BLC2 Curncy'
                     AND SymbolName = N'TRY OISZERO7Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId, ModuleId, SymbolTypeId,
             SymbolCode, SymbolName,
             SymbolGroup, Description, IsEnabled,
             CcyPair, AlternateSymbol,
             StateMaker, StateDate, StateId)
            VALUES (@dataSourceId, @moduleId, @symbolTypeOisZeroId,
                    N'S0522Z 7Y BLC2 Curncy', N'TRY OISZERO7Y',
                    '', '', 1,
                    '0', 0,
                    @stateMaker, @stateDate, @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisZeroId
                     AND SymbolCode = N'S0522Z 8Y BLC2 Curncy'
                     AND SymbolName = N'TRY OISZERO8Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId, ModuleId, SymbolTypeId,
             SymbolCode, SymbolName,
             SymbolGroup, Description, IsEnabled,
             CcyPair, AlternateSymbol,
             StateMaker, StateDate, StateId)
            VALUES (@dataSourceId, @moduleId, @symbolTypeOisZeroId,
                    N'S0522Z 8Y BLC2 Curncy', N'TRY OISZERO8Y',
                    '', '', 1,
                    '0', 0,
                    @stateMaker, @stateDate, @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisZeroId
                     AND SymbolCode = N'S0522Z 9Y BLC2 Curncy'
                     AND SymbolName = N'TRY OISZERO9Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId, ModuleId, SymbolTypeId,
             SymbolCode, SymbolName,
             SymbolGroup, Description, IsEnabled,
             CcyPair, AlternateSymbol,
             StateMaker, StateDate, StateId)
            VALUES (@dataSourceId,
                    @moduleId,
                    @symbolTypeOisZeroId,
                    N'S0522Z 9Y BLC2 Curncy',
                    N'TRY OISZERO9Y',
                    '',
                    '',
                    1,
                    '0', 0,
                    @stateMaker,
                    @stateDate,
                    @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisZeroId
                     AND SymbolCode = N'S0522Z 10Y BLC2 Curncy'
                     AND SymbolName = N'TRY OISZERO10Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId,
             ModuleId,
             SymbolTypeId,
             SymbolCode,
             SymbolName,
             SymbolGroup,
             Description,
             IsEnabled,
             CcyPair,
             AlternateSymbol,
             StateMaker,
             StateDate,
             StateId)
            VALUES (@dataSourceId,
                    @moduleId,
                    @symbolTypeOisZeroId,
                    N'S0522Z 10Y BLC2 Curncy',
                    N'TRY OISZERO10Y',
                    '',
                    '',
                    1,
                    '0', 0,
                    @stateMaker,
                    @stateDate,
                    @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisZeroId
                     AND SymbolCode = N'S0522Z 11Y BLC2 Curncy'
                     AND SymbolName = N'TRY OISZERO11Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId,
             ModuleId,
             SymbolTypeId,
             SymbolCode,
             SymbolName,
             SymbolGroup,
             Description,
             IsEnabled,
             CcyPair,
             AlternateSymbol,
             StateMaker,
             StateDate,
             StateId)
            VALUES (@dataSourceId,
                    @moduleId,
                    @symbolTypeOisZeroId,
                    N'S0522Z 11Y BLC2 Curncy',
                    N'TRY OISZERO11Y',
                    '',
                    '',
                    1,
                    '0', 0,
                    @stateMaker,
                    @stateDate,
                    @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisZeroId
                     AND SymbolCode = N'S0522Z 12Y BLC2 Curncy'
                     AND SymbolName = N'TRY OISZERO12Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId,
             ModuleId,
             SymbolTypeId,
             SymbolCode,
             SymbolName,
             SymbolGroup,
             Description,
             IsEnabled,
             CcyPair,
             AlternateSymbol,
             StateMaker,
             StateDate,
             StateId)
            VALUES (@dataSourceId,
                    @moduleId,
                    @symbolTypeOisZeroId,
                    N'S0522Z 12Y BLC2 Curncy',
                    N'TRY OISZERO12Y',
                    '',
                    '',
                    1,
                    '0', 0,
                    @stateMaker,
                    @stateDate,
                    @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisZeroId
                     AND SymbolCode = N'S0522Z 13Y BLC2 Curncy'
                     AND SymbolName = N'TRY OISZERO13Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId,
             ModuleId,
             SymbolTypeId,
             SymbolCode,
             SymbolName,
             SymbolGroup,
             Description,
             IsEnabled,
             CcyPair,
             AlternateSymbol,
             StateMaker,
             StateDate,
             StateId)
            VALUES (@dataSourceId,
                    @moduleId,
                    @symbolTypeOisZeroId,
                    N'S0522Z 13Y BLC2 Curncy',
                    N'TRY OISZERO13Y',
                    '',
                    '',
                    1,
                    '0', 0,
                    @stateMaker,
                    @stateDate,
                    @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisZeroId
                     AND SymbolCode = N'S0522Z 14Y BLC2 Curncy'
                     AND SymbolName = N'TRY OISZERO14Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId,
             ModuleId,
             SymbolTypeId,
             SymbolCode,
             SymbolName,
             SymbolGroup,
             Description,
             IsEnabled,
             CcyPair,
             AlternateSymbol,
             StateMaker,
             StateDate,
             StateId)
            VALUES (@dataSourceId,
                    @moduleId,
                    @symbolTypeOisZeroId,
                    N'S0522Z 14Y BLC2 Curncy',
                    N'TRY OISZERO14Y',
                    '',
                    '',
                    1,
                    '0', 0,
                    @stateMaker,
                    @stateDate,
                    @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisZeroId
                     AND SymbolCode = N'S0522Z 15Y BLC2 Curncy'
                     AND SymbolName = N'TRY OISZERO15Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId,
             ModuleId,
             SymbolTypeId,
             SymbolCode,
             SymbolName,
             SymbolGroup,
             Description,
             IsEnabled,
             CcyPair,
             AlternateSymbol,
             StateMaker,
             StateDate,
             StateId)
            VALUES (@dataSourceId,
                    @moduleId,
                    @symbolTypeOisZeroId,
                    N'S0522Z 15Y BLC2 Curncy',
                    N'TRY OISZERO15Y',
                    '',
                    '',
                    1,
                    '0', 0,
                    @stateMaker,
                    @stateDate,
                    @stateId);
        END;


    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisZeroId
                     AND SymbolCode = N'S0490Z 1D BLC2 Curncy'
                     AND SymbolName = N'USD SOFRZEROON')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId,
             ModuleId,
             SymbolTypeId,
             SymbolCode,
             SymbolName,
             SymbolGroup,
             Description,
             IsEnabled,
             CcyPair,
             AlternateSymbol,
             StateMaker,
             StateDate,
             StateId)
            VALUES (@dataSourceId,
                    @moduleId,
                    @symbolTypeOisZeroId,
                    N'S0490Z 1D BLC2 Curncy',
                    N'USD SOFRZEROON',
                    '',
                    '',
                    1,
                    '0', 0,
                    @stateMaker,
                    @stateDate,
                    @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisZeroId
                     AND SymbolCode = N'S0490Z 1W BLC2 Curncy'
                     AND SymbolName = N'USD SOFRZERO1W')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId,
             ModuleId,
             SymbolTypeId,
             SymbolCode,
             SymbolName,
             SymbolGroup,
             Description,
             IsEnabled,
             CcyPair,
             AlternateSymbol,
             StateMaker,
             StateDate,
             StateId)
            VALUES (@dataSourceId,
                    @moduleId,
                    @symbolTypeOisZeroId,
                    N'S0490Z 1W BLC2 Curncy',
                    N'USD SOFRZERO1W',
                    '',
                    '',
                    1,
                    '0', 0,
                    @stateMaker,
                    @stateDate,
                    @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisZeroId
                     AND SymbolCode = N'S0490Z 2W BLC2 Curncy'
                     AND SymbolName = N'USD SOFRZERO2W')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId,
             ModuleId,
             SymbolTypeId,
             SymbolCode,
             SymbolName,
             SymbolGroup,
             Description,
             IsEnabled,
             CcyPair,
             AlternateSymbol,
             StateMaker,
             StateDate,
             StateId)
            VALUES (@dataSourceId,
                    @moduleId,
                    @symbolTypeOisZeroId,
                    N'S0490Z 2W BLC2 Curncy',
                    N'USD SOFRZERO2W',
                    '',
                    '',
                    1,
                    '0', 0,
                    @stateMaker,
                    @stateDate,
                    @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisZeroId
                     AND SymbolCode = N'S0490Z 1M BLC2 Curncy'
                     AND SymbolName = N'USD SOFRZERO1M')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId,
             ModuleId,
             SymbolTypeId,
             SymbolCode,
             SymbolName,
             SymbolGroup,
             Description,
             IsEnabled,
             CcyPair,
             AlternateSymbol,
             StateMaker,
             StateDate,
             StateId)
            VALUES (@dataSourceId,
                    @moduleId,
                    @symbolTypeOisZeroId,
                    N'S0490Z 1M BLC2 Curncy',
                    N'USD SOFRZERO1M',
                    '',
                    '',
                    1,
                    '0', 0,
                    @stateMaker,
                    @stateDate,
                    @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisZeroId
                     AND SymbolCode = N'S0490Z 2M BLC2 Curncy'
                     AND SymbolName = N'USD SOFRZERO2M')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId,
             ModuleId,
             SymbolTypeId,
             SymbolCode,
             SymbolName,
             SymbolGroup,
             Description,
             IsEnabled,
             CcyPair,
             AlternateSymbol,
             StateMaker,
             StateDate,
             StateId)
            VALUES (@dataSourceId,
                    @moduleId,
                    @symbolTypeOisZeroId,
                    N'S0490Z 2M BLC2 Curncy',
                    N'USD SOFRZERO2M',
                    '',
                    '',
                    1,
                    '0', 0,
                    @stateMaker,
                    @stateDate,
                    @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisZeroId
                     AND SymbolCode = N'S0490Z 3M BLC2 Curncy'
                     AND SymbolName = N'USD SOFRZERO3M')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId,
             ModuleId,
             SymbolTypeId,
             SymbolCode,
             SymbolName,
             SymbolGroup,
             Description,
             IsEnabled,
             CcyPair,
             AlternateSymbol,
             StateMaker,
             StateDate,
             StateId)
            VALUES (@dataSourceId,
                    @moduleId,
                    @symbolTypeOisZeroId,
                    N'S0490Z 3M BLC2 Curncy',
                    N'USD SOFRZERO3M',
                    '',
                    '',
                    1,
                    '0', 0,
                    @stateMaker,
                    @stateDate,
                    @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisZeroId
                     AND SymbolCode = N'S0490Z 6M BLC2 Curncy'
                     AND SymbolName = N'USD SOFRZERO6M')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId,
             ModuleId,
             SymbolTypeId,
             SymbolCode,
             SymbolName,
             SymbolGroup,
             Description,
             IsEnabled,
             CcyPair,
             AlternateSymbol,
             StateMaker,
             StateDate,
             StateId)
            VALUES (@dataSourceId,
                    @moduleId,
                    @symbolTypeOisZeroId,
                    N'S0490Z 6M BLC2 Curncy',
                    N'USD SOFRZERO6M',
                    '',
                    '',
                    1,
                    '0', 0,
                    @stateMaker,
                    @stateDate,
                    @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisZeroId
                     AND SymbolCode = N'S0490Z 9M BLC2 Curncy'
                     AND SymbolName = N'USD SOFRZERO9M')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId,
             ModuleId,
             SymbolTypeId,
             SymbolCode,
             SymbolName,
             SymbolGroup,
             Description,
             IsEnabled,
             CcyPair,
             AlternateSymbol,
             StateMaker,
             StateDate,
             StateId)
            VALUES (@dataSourceId,
                    @moduleId,
                    @symbolTypeOisZeroId,
                    N'S0490Z 9M BLC2 Curncy',
                    N'USD SOFRZERO9M',
                    '',
                    '',
                    1,
                    '0', 0,
                    @stateMaker,
                    @stateDate,
                    @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisZeroId
                     AND SymbolCode = N'S0490Z 1Y BLC2 Curncy'
                     AND SymbolName = N'USD SOFRZERO12M')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId,
             ModuleId,
             SymbolTypeId,
             SymbolCode,
             SymbolName,
             SymbolGroup,
             Description,
             IsEnabled,
             CcyPair,
             AlternateSymbol,
             StateMaker,
             StateDate,
             StateId)
            VALUES (@dataSourceId,
                    @moduleId,
                    @symbolTypeOisZeroId,
                    N'S0490Z 1Y BLC2 Curncy',
                    N'USD SOFRZERO12M',
                    '',
                    '',
                    1,
                    '0', 0,
                    @stateMaker,
                    @stateDate,
                    @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisZeroId
                     AND SymbolCode = N'S0490Z 18M BLC2 Curncy'
                     AND SymbolName = N'USD SOFRZERO18M')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId,
             ModuleId,
             SymbolTypeId,
             SymbolCode,
             SymbolName,
             SymbolGroup,
             Description,
             IsEnabled,
             CcyPair,
             AlternateSymbol,
             StateMaker,
             StateDate,
             StateId)
            VALUES (@dataSourceId,
                    @moduleId,
                    @symbolTypeOisZeroId,
                    N'S0490Z 18M BLC2 Curncy',
                    N'USD SOFRZERO18M',
                    '',
                    '',
                    1,
                    '0', 0,
                    @stateMaker,
                    @stateDate,
                    @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisZeroId
                     AND SymbolCode = N'S0490Z 2Y BLC2 Curncy'
                     AND SymbolName = N'USD SOFRZERO2Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId,
             ModuleId,
             SymbolTypeId,
             SymbolCode,
             SymbolName,
             SymbolGroup,
             Description,
             IsEnabled,
             CcyPair,
             AlternateSymbol,
             StateMaker,
             StateDate,
             StateId)
            VALUES (@dataSourceId,
                    @moduleId,
                    @symbolTypeOisZeroId,
                    N'S0490Z 2Y BLC2 Curncy',
                    N'USD SOFRZERO2Y',
                    '',
                    '',
                    1,
                    '0', 0,
                    @stateMaker,
                    @stateDate,
                    @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisZeroId
                     AND SymbolCode = N'S0490Z 3Y BLC2 Curncy'
                     AND SymbolName = N'USD SOFRZERO3Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId,
             ModuleId,
             SymbolTypeId,
             SymbolCode,
             SymbolName,
             SymbolGroup,
             Description,
             IsEnabled,
             CcyPair,
             AlternateSymbol,
             StateMaker,
             StateDate,
             StateId)
            VALUES (@dataSourceId,
                    @moduleId,
                    @symbolTypeOisZeroId,
                    N'S0490Z 3Y BLC2 Curncy',
                    N'USD SOFRZERO3Y',
                    '',
                    '',
                    1,
                    '0', 0,
                    @stateMaker,
                    @stateDate,
                    @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisZeroId
                     AND SymbolCode = N'S0490Z 4Y BLC2 Curncy'
                     AND SymbolName = N'USD SOFRZERO4Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId,
             ModuleId,
             SymbolTypeId,
             SymbolCode,
             SymbolName,
             SymbolGroup,
             Description,
             IsEnabled,
             CcyPair,
             AlternateSymbol,
             StateMaker,
             StateDate,
             StateId)
            VALUES (@dataSourceId,
                    @moduleId,
                    @symbolTypeOisZeroId,
                    N'S0490Z 4Y BLC2 Curncy',
                    N'USD SOFRZERO4Y',
                    '',
                    '',
                    1,
                    '0', 0,
                    @stateMaker,
                    @stateDate,
                    @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisZeroId
                     AND SymbolCode = N'S0490Z 5Y BLC2 Curncy'
                     AND SymbolName = N'USD SOFRZERO5Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId,
             ModuleId,
             SymbolTypeId,
             SymbolCode,
             SymbolName,
             SymbolGroup,
             Description,
             IsEnabled,
             CcyPair,
             AlternateSymbol,
             StateMaker,
             StateDate,
             StateId)
            VALUES (@dataSourceId,
                    @moduleId,
                    @symbolTypeOisZeroId,
                    N'S0490Z 5Y BLC2 Curncy',
                    N'USD SOFRZERO5Y',
                    '',
                    '',
                    1,
                    '0', 0,
                    @stateMaker,
                    @stateDate,
                    @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisZeroId
                     AND SymbolCode = N'S0490Z 6Y BLC2 Curncy'
                     AND SymbolName = N'USD SOFRZERO6Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId,
             ModuleId,
             SymbolTypeId,
             SymbolCode,
             SymbolName,
             SymbolGroup,
             Description,
             IsEnabled,
             CcyPair,
             AlternateSymbol,
             StateMaker,
             StateDate,
             StateId)
            VALUES (@dataSourceId,
                    @moduleId,
                    @symbolTypeOisZeroId,
                    N'S0490Z 6Y BLC2 Curncy',
                    N'USD SOFRZERO6Y',
                    '',
                    '',
                    1,
                    '0', 0,
                    @stateMaker,
                    @stateDate,
                    @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisZeroId
                     AND SymbolCode = N'S0490Z 7Y BLC2 Curncy'
                     AND SymbolName = N'USD SOFRZERO7Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId,
             ModuleId,
             SymbolTypeId,
             SymbolCode,
             SymbolName,
             SymbolGroup,
             Description,
             IsEnabled,
             CcyPair,
             AlternateSymbol,
             StateMaker,
             StateDate,
             StateId)
            VALUES (@dataSourceId,
                    @moduleId,
                    @symbolTypeOisZeroId,
                    N'S0490Z 7Y BLC2 Curncy',
                    N'USD SOFRZERO7Y',
                    '',
                    '',
                    1,
                    '0', 0,
                    @stateMaker,
                    @stateDate,
                    @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisZeroId
                     AND SymbolCode = N'S0490Z 8Y BLC2 Curncy'
                     AND SymbolName = N'USD SOFRZERO8Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId,
             ModuleId,
             SymbolTypeId,
             SymbolCode,
             SymbolName,
             SymbolGroup,
             Description,
             IsEnabled,
             CcyPair,
             AlternateSymbol,
             StateMaker,
             StateDate,
             StateId)
            VALUES (@dataSourceId,
                    @moduleId,
                    @symbolTypeOisZeroId,
                    N'S0490Z 8Y BLC2 Curncy',
                    N'USD SOFRZERO8Y',
                    '',
                    '',
                    1,
                    '0', 0,
                    @stateMaker,
                    @stateDate,
                    @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisZeroId
                     AND SymbolCode = N'S0490Z 9Y BLC2 Curncy'
                     AND SymbolName = N'USD SOFRZERO9Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId,
             ModuleId,
             SymbolTypeId,
             SymbolCode,
             SymbolName,
             SymbolGroup,
             Description,
             IsEnabled,
             CcyPair,
             AlternateSymbol,
             StateMaker,
             StateDate,
             StateId)
            VALUES (@dataSourceId,
                    @moduleId,
                    @symbolTypeOisZeroId,
                    N'S0490Z 9Y BLC2 Curncy',
                    N'USD SOFRZERO9Y',
                    '',
                    '',
                    1,
                    '0', 0,
                    @stateMaker,
                    @stateDate,
                    @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisZeroId
                     AND SymbolCode = N'S0490Z 10Y BLC2 Curncy'
                     AND SymbolName = N'USD SOFRZERO10Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId,
             ModuleId,
             SymbolTypeId,
             SymbolCode,
             SymbolName,
             SymbolGroup,
             Description,
             IsEnabled,
             CcyPair,
             AlternateSymbol,
             StateMaker,
             StateDate,
             StateId)
            VALUES (@dataSourceId,
                    @moduleId,
                    @symbolTypeOisZeroId,
                    N'S0490Z 10Y BLC2 Curncy',
                    N'USD SOFRZERO10Y',
                    '',
                    '',
                    1,
                    '0', 0,
                    @stateMaker,
                    @stateDate,
                    @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisZeroId
                     AND SymbolCode = N'S0490Z 11Y BLC2 Curncy'
                     AND SymbolName = N'USD SOFRZERO11Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId,
             ModuleId,
             SymbolTypeId,
             SymbolCode,
             SymbolName,
             SymbolGroup,
             Description,
             IsEnabled,
             CcyPair,
             AlternateSymbol,
             StateMaker,
             StateDate,
             StateId)
            VALUES (@dataSourceId,
                    @moduleId,
                    @symbolTypeOisZeroId,
                    N'S0490Z 11Y BLC2 Curncy',
                    N'USD SOFRZERO11Y',
                    '',
                    '',
                    1,
                    '0', 0,
                    @stateMaker,
                    @stateDate,
                    @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisZeroId
                     AND SymbolCode = N'S0490Z 12Y BLC2 Curncy'
                     AND SymbolName = N'USD SOFRZERO12Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId,
             ModuleId,
             SymbolTypeId,
             SymbolCode,
             SymbolName,
             SymbolGroup,
             Description,
             IsEnabled,
             CcyPair,
             AlternateSymbol,
             StateMaker,
             StateDate,
             StateId)
            VALUES (@dataSourceId,
                    @moduleId,
                    @symbolTypeOisZeroId,
                    N'S0490Z 12Y BLC2 Curncy',
                    N'USD SOFRZERO12Y',
                    '',
                    '',
                    1,
                    '0', 0,
                    @stateMaker,
                    @stateDate,
                    @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisZeroId
                     AND SymbolCode = N'S0490Z 13Y BLC2 Curncy'
                     AND SymbolName = N'USD SOFRZERO13Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId,
             ModuleId,
             SymbolTypeId,
             SymbolCode,
             SymbolName,
             SymbolGroup,
             Description,
             IsEnabled,
             CcyPair,
             AlternateSymbol,
             StateMaker,
             StateDate,
             StateId)
            VALUES (@dataSourceId,
                    @moduleId,
                    @symbolTypeOisZeroId,
                    N'S0490Z 13Y BLC2 Curncy',
                    N'USD SOFRZERO13Y',
                    '',
                    '',
                    1,
                    '0', 0,
                    @stateMaker,
                    @stateDate,
                    @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisZeroId
                     AND SymbolCode = N'S0490Z 14Y BLC2 Curncy'
                     AND SymbolName = N'USD SOFRZERO14Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId,
             ModuleId,
             SymbolTypeId,
             SymbolCode,
             SymbolName,
             SymbolGroup,
             Description,
             IsEnabled,
             CcyPair,
             AlternateSymbol,
             StateMaker,
             StateDate,
             StateId)
            VALUES (@dataSourceId,
                    @moduleId,
                    @symbolTypeOisZeroId,
                    N'S0490Z 14Y BLC2 Curncy',
                    N'USD SOFRZERO14Y',
                    '',
                    '',
                    1,
                    '0', 0,
                    @stateMaker,
                    @stateDate,
                    @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisZeroId
                     AND SymbolCode = N'S0490Z 15Y BLC2 Curncy'
                     AND SymbolName = N'USD SOFRZERO15Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId,
             ModuleId,
             SymbolTypeId,
             SymbolCode,
             SymbolName,
             SymbolGroup,
             Description,
             IsEnabled,
             CcyPair,
             AlternateSymbol,
             StateMaker,
             StateDate,
             StateId)
            VALUES (@dataSourceId,
                    @moduleId,
                    @symbolTypeOisZeroId,
                    N'S0490Z 15Y BLC2 Curncy',
                    N'USD SOFRZERO15Y',
                    '',
                    '',
                    1,
                    '0', 0,
                    @stateMaker,
                    @stateDate,
                    @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisZeroId
                     AND SymbolCode = N'S0514Z 1D BLC2 Curncy'
                     AND SymbolName = N'EUR ESTRZEROON')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId,
             ModuleId,
             SymbolTypeId,
             SymbolCode,
             SymbolName,
             SymbolGroup,
             Description,
             IsEnabled,
             CcyPair,
             AlternateSymbol,
             StateMaker,
             StateDate,
             StateId)
            VALUES (@dataSourceId,
                    @moduleId,
                    @symbolTypeOisZeroId,
                    N'S0514Z 1D BLC2 Curncy',
                    N'EUR ESTRZEROON',
                    '',
                    '',
                    1,
                    '0', 0,
                    @stateMaker,
                    @stateDate,
                    @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisZeroId
                     AND SymbolCode = N'S0045Z 1W BLC2 Curncy'
                     AND SymbolName = N'EUR ZERO1W')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId,
             ModuleId,
             SymbolTypeId,
             SymbolCode,
             SymbolName,
             SymbolGroup,
             Description,
             IsEnabled,
             CcyPair,
             AlternateSymbol,
             StateMaker,
             StateDate,
             StateId)
            VALUES (@dataSourceId,
                    @moduleId,
                    @symbolTypeOisZeroId,
                    N'S0045Z 1W BLC2 Curncy',
                    N'EUR ZERO1W',
                    '',
                    '',
                    1,
                    '0', 0,
                    @stateMaker,
                    @stateDate,
                    @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisZeroId
                     AND SymbolCode = N'S0045Z 2W BLC2 Curncy'
                     AND SymbolName = N'EUR ZERO2W')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId,
             ModuleId,
             SymbolTypeId,
             SymbolCode,
             SymbolName,
             SymbolGroup,
             Description,
             IsEnabled,
             CcyPair,
             AlternateSymbol,
             StateMaker,
             StateDate,
             StateId)
            VALUES (@dataSourceId,
                    @moduleId,
                    @symbolTypeOisZeroId,
                    N'S0045Z 2W BLC2 Curncy',
                    N'EUR ZERO2W',
                    '',
                    '',
                    1,
                    '0', 0,
                    @stateMaker,
                    @stateDate,
                    @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisZeroId
                     AND SymbolCode = N'S0045Z 1M BLC2 Curncy'
                     AND SymbolName = N'EUR ZERO1M')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId,
             ModuleId,
             SymbolTypeId,
             SymbolCode,
             SymbolName,
             SymbolGroup,
             Description,
             IsEnabled,
             CcyPair,
             AlternateSymbol,
             StateMaker,
             StateDate,
             StateId)
            VALUES (@dataSourceId,
                    @moduleId,
                    @symbolTypeOisZeroId,
                    N'S0045Z 1M BLC2 Curncy',
                    N'EUR ZERO1M',
                    '',
                    '',
                    1,
                    '0', 0,
                    @stateMaker,
                    @stateDate,
                    @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisZeroId
                     AND SymbolCode = N'S0045Z 2M BLC2 Curncy'
                     AND SymbolName = N'EUR ZERO2M')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId,
             ModuleId,
             SymbolTypeId,
             SymbolCode,
             SymbolName,
             SymbolGroup,
             Description,
             IsEnabled,
             CcyPair,
             AlternateSymbol,
             StateMaker,
             StateDate,
             StateId)
            VALUES (@dataSourceId,
                    @moduleId,
                    @symbolTypeOisZeroId,
                    N'S0045Z 2M BLC2 Curncy',
                    N'EUR ZERO2M',
                    '',
                    '',
                    1,
                    '0', 0,
                    @stateMaker,
                    @stateDate,
                    @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisZeroId
                     AND SymbolCode = N'S0045Z 3M BLC2 Curncy'
                     AND SymbolName = N'EUR ZERO3M')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId,
             ModuleId,
             SymbolTypeId,
             SymbolCode,
             SymbolName,
             SymbolGroup,
             Description,
             IsEnabled,
             CcyPair,
             AlternateSymbol,
             StateMaker,
             StateDate,
             StateId)
            VALUES (@dataSourceId,
                    @moduleId,
                    @symbolTypeOisZeroId,
                    N'S0045Z 3M BLC2 Curncy',
                    N'EUR ZERO3M',
                    '',
                    '',
                    1,
                    '0', 0,
                    @stateMaker,
                    @stateDate,
                    @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisZeroId
                     AND SymbolCode = N'S0045Z 6M BLC2 Curncy'
                     AND SymbolName = N'EUR ZERO6M')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId,
             ModuleId,
             SymbolTypeId,
             SymbolCode,
             SymbolName,
             SymbolGroup,
             Description,
             IsEnabled,
             CcyPair,
             AlternateSymbol,
             StateMaker,
             StateDate,
             StateId)
            VALUES (@dataSourceId,
                    @moduleId,
                    @symbolTypeOisZeroId,
                    N'S0045Z 6M BLC2 Curncy',
                    N'EUR ZERO6M',
                    '',
                    '',
                    1,
                    '0', 0,
                    @stateMaker,
                    @stateDate,
                    @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisZeroId
                     AND SymbolCode = N'S0045Z 9M BLC2 Curncy'
                     AND SymbolName = N'EUR ZERO9M')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId,
             ModuleId,
             SymbolTypeId,
             SymbolCode,
             SymbolName,
             SymbolGroup,
             Description,
             IsEnabled,
             CcyPair,
             AlternateSymbol,
             StateMaker,
             StateDate,
             StateId)
            VALUES (@dataSourceId,
                    @moduleId,
                    @symbolTypeOisZeroId,
                    N'S0045Z 9M BLC2 Curncy',
                    N'EUR ZERO9M',
                    '',
                    '',
                    1,
                    '0', 0,
                    @stateMaker,
                    @stateDate,
                    @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisZeroId
                     AND SymbolCode = N'S0045Z 1Y BLC2 Curncy'
                     AND SymbolName = N'EUR ZERO1Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId,
             ModuleId,
             SymbolTypeId,
             SymbolCode,
             SymbolName,
             SymbolGroup,
             Description,
             IsEnabled,
             CcyPair,
             AlternateSymbol,
             StateMaker,
             StateDate,
             StateId)
            VALUES (@dataSourceId,
                    @moduleId,
                    @symbolTypeOisZeroId,
                    N'S0045Z 1Y BLC2 Curncy',
                    N'EUR ZERO1Y',
                    '',
                    '',
                    1,
                    '0', 0,
                    @stateMaker,
                    @stateDate,
                    @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisZeroId
                     AND SymbolCode = N'S0045Z 18M BLC2 Curncy'
                     AND SymbolName = N'EUR ZERO18M')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId,
             ModuleId,
             SymbolTypeId,
             SymbolCode,
             SymbolName,
             SymbolGroup,
             Description,
             IsEnabled,
             CcyPair,
             AlternateSymbol,
             StateMaker,
             StateDate,
             StateId)
            VALUES (@dataSourceId,
                    @moduleId,
                    @symbolTypeOisZeroId,
                    N'S0045Z 18M BLC2 Curncy',
                    N'EUR ZERO18M',
                    '',
                    '',
                    1,
                    '0', 0,
                    @stateMaker,
                    @stateDate,
                    @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisZeroId
                     AND SymbolCode = N'S0045Z 2Y BLC2 Curncy'
                     AND SymbolName = N'EUR ZERO2Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId,
             ModuleId,
             SymbolTypeId,
             SymbolCode,
             SymbolName,
             SymbolGroup,
             Description,
             IsEnabled,
             CcyPair,
             AlternateSymbol,
             StateMaker,
             StateDate,
             StateId)
            VALUES (@dataSourceId,
                    @moduleId,
                    @symbolTypeOisZeroId,
                    N'S0045Z 2Y BLC2 Curncy',
                    N'EUR ZERO2Y',
                    '',
                    '',
                    1,
                    '0', 0,
                    @stateMaker,
                    @stateDate,
                    @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisZeroId
                     AND SymbolCode = N'S0045Z 3Y BLC2 Curncy'
                     AND SymbolName = N'EUR ZERO3Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId,
             ModuleId,
             SymbolTypeId,
             SymbolCode,
             SymbolName,
             SymbolGroup,
             Description,
             IsEnabled,
             CcyPair,
             AlternateSymbol,
             StateMaker,
             StateDate,
             StateId)
            VALUES (@dataSourceId,
                    @moduleId,
                    @symbolTypeOisZeroId,
                    N'S0045Z 3Y BLC2 Curncy',
                    N'EUR ZERO3Y',
                    '',
                    '',
                    1,
                    '0', 0,
                    @stateMaker,
                    @stateDate,
                    @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisZeroId
                     AND SymbolCode = N'S0045Z 4Y BLC2 Curncy'
                     AND SymbolName = N'EUR ZERO4Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId,
             ModuleId,
             SymbolTypeId,
             SymbolCode,
             SymbolName,
             SymbolGroup,
             Description,
             IsEnabled,
             CcyPair,
             AlternateSymbol,
             StateMaker,
             StateDate,
             StateId)
            VALUES (@dataSourceId,
                    @moduleId,
                    @symbolTypeOisZeroId,
                    N'S0045Z 4Y BLC2 Curncy',
                    N'EUR ZERO4Y',
                    '',
                    '',
                    1,
                    '0', 0,
                    @stateMaker,
                    @stateDate,
                    @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisZeroId
                     AND SymbolCode = N'S0045Z 5Y BLC2 Curncy'
                     AND SymbolName = N'EUR ZERO5Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId,
             ModuleId,
             SymbolTypeId,
             SymbolCode,
             SymbolName,
             SymbolGroup,
             Description,
             IsEnabled,
             CcyPair,
             AlternateSymbol,
             StateMaker,
             StateDate,
             StateId)
            VALUES (@dataSourceId,
                    @moduleId,
                    @symbolTypeOisZeroId,
                    N'S0045Z 5Y BLC2 Curncy',
                    N'EUR ZERO5Y',
                    '',
                    '',
                    1,
                    '0', 0,
                    @stateMaker,
                    @stateDate,
                    @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisZeroId
                     AND SymbolCode = N'S0045Z 6Y BLC2 Curncy'
                     AND SymbolName = N'EUR ZERO6Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId,
             ModuleId,
             SymbolTypeId,
             SymbolCode,
             SymbolName,
             SymbolGroup,
             Description,
             IsEnabled,
             CcyPair,
             AlternateSymbol,
             StateMaker,
             StateDate,
             StateId)
            VALUES (@dataSourceId,
                    @moduleId,
                    @symbolTypeOisZeroId,
                    N'S0045Z 6Y BLC2 Curncy',
                    N'EUR ZERO6Y',
                    '',
                    '',
                    1,
                    '0', 0,
                    @stateMaker,
                    @stateDate,
                    @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisZeroId
                     AND SymbolCode = N'S0045Z 7Y BLC2 Curncy'
                     AND SymbolName = N'EUR ZERO7Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId,
             ModuleId,
             SymbolTypeId,
             SymbolCode,
             SymbolName,
             SymbolGroup,
             Description,
             IsEnabled,
             CcyPair,
             AlternateSymbol,
             StateMaker,
             StateDate,
             StateId)
            VALUES (@dataSourceId,
                    @moduleId,
                    @symbolTypeOisZeroId,
                    N'S0045Z 7Y BLC2 Curncy',
                    N'EUR ZERO7Y',
                    '',
                    '',
                    1,
                    '0', 0,
                    @stateMaker,
                    @stateDate,
                    @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisZeroId
                     AND SymbolCode = N'S0045Z 8Y BLC2 Curncy'
                     AND SymbolName = N'EUR ZERO8Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId,
             ModuleId,
             SymbolTypeId,
             SymbolCode,
             SymbolName,
             SymbolGroup,
             Description,
             IsEnabled,
             CcyPair,
             AlternateSymbol,
             StateMaker,
             StateDate,
             StateId)
            VALUES (@dataSourceId,
                    @moduleId,
                    @symbolTypeOisZeroId,
                    N'S0045Z 8Y BLC2 Curncy',
                    N'EUR ZERO8Y',
                    '',
                    '',
                    1,
                    '0', 0,
                    @stateMaker,
                    @stateDate,
                    @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisZeroId
                     AND SymbolCode = N'S0045Z 9Y BLC2 Curncy'
                     AND SymbolName = N'EUR ZERO9Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId,
             ModuleId,
             SymbolTypeId,
             SymbolCode,
             SymbolName,
             SymbolGroup,
             Description,
             IsEnabled,
             CcyPair,
             AlternateSymbol,
             StateMaker,
             StateDate,
             StateId)
            VALUES (@dataSourceId,
                    @moduleId,
                    @symbolTypeOisZeroId,
                    N'S0045Z 9Y BLC2 Curncy',
                    N'EUR ZERO9Y',
                    '',
                    '',
                    1,
                    '0', 0,
                    @stateMaker,
                    @stateDate,
                    @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisZeroId
                     AND SymbolCode = N'S0045Z 10Y BLC2 Curncy'
                     AND SymbolName = N'EUR ZERO10Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId,
             ModuleId,
             SymbolTypeId,
             SymbolCode,
             SymbolName,
             SymbolGroup,
             Description,
             IsEnabled,
             CcyPair,
             AlternateSymbol,
             StateMaker,
             StateDate,
             StateId)
            VALUES (@dataSourceId,
                    @moduleId,
                    @symbolTypeOisZeroId,
                    N'S0045Z 10Y BLC2 Curncy',
                    N'EUR ZERO10Y',
                    '',
                    '',
                    1,
                    '0', 0,
                    @stateMaker,
                    @stateDate,
                    @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisZeroId
                     AND SymbolCode = N'S0045Z 11Y BLC2 Curncy'
                     AND SymbolName = N'EUR ZERO11Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId,
             ModuleId,
             SymbolTypeId,
             SymbolCode,
             SymbolName,
             SymbolGroup,
             Description,
             IsEnabled,
             CcyPair,
             AlternateSymbol,
             StateMaker,
             StateDate,
             StateId)
            VALUES (@dataSourceId,
                    @moduleId,
                    @symbolTypeOisZeroId,
                    N'S0045Z 11Y BLC2 Curncy',
                    N'EUR ZERO11Y',
                    '',
                    '',
                    1,
                    '0', 0,
                    @stateMaker,
                    @stateDate,
                    @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisZeroId
                     AND SymbolCode = N'S0045Z 12Y BLC2 Curncy'
                     AND SymbolName = N'EUR ZERO12Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId,
             ModuleId,
             SymbolTypeId,
             SymbolCode,
             SymbolName,
             SymbolGroup,
             Description,
             IsEnabled,
             CcyPair,
             AlternateSymbol,
             StateMaker,
             StateDate,
             StateId)
            VALUES (@dataSourceId,
                    @moduleId,
                    @symbolTypeOisZeroId,
                    N'S0045Z 12Y BLC2 Curncy',
                    N'EUR ZERO12Y',
                    '',
                    '',
                    1,
                    '0', 0,
                    @stateMaker,
                    @stateDate,
                    @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisZeroId
                     AND SymbolCode = N'S0045Z 13Y BLC2 Curncy'
                     AND SymbolName = N'EUR ZERO13Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId,
             ModuleId,
             SymbolTypeId,
             SymbolCode,
             SymbolName,
             SymbolGroup,
             Description,
             IsEnabled,
             CcyPair,
             AlternateSymbol,
             StateMaker,
             StateDate,
             StateId)
            VALUES (@dataSourceId,
                    @moduleId,
                    @symbolTypeOisZeroId,
                    N'S0045Z 13Y BLC2 Curncy',
                    N'EUR ZERO13Y',
                    '',
                    '',
                    1,
                    '0', 0,
                    @stateMaker,
                    @stateDate,
                    @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisZeroId
                     AND SymbolCode = N'S0045Z 14Y BLC2 Curncy'
                     AND SymbolName = N'EUR ZERO14Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId,
             ModuleId,
             SymbolTypeId,
             SymbolCode,
             SymbolName,
             SymbolGroup,
             Description,
             IsEnabled,
             CcyPair,
             AlternateSymbol,
             StateMaker,
             StateDate,
             StateId)
            VALUES (@dataSourceId,
                    @moduleId,
                    @symbolTypeOisZeroId,
                    N'S0045Z 14Y BLC2 Curncy',
                    N'EUR ZERO14Y',
                    '',
                    '',
                    1,
                    '0', 0,
                    @stateMaker,
                    @stateDate,
                    @stateId);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolTypeId = @symbolTypeOisZeroId
                     AND SymbolCode = N'S0045Z 15Y BLC2 Curncy'
                     AND SymbolName = N'EUR ZERO15Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolMap
            (DataSourceId,
             ModuleId,
             SymbolTypeId,
             SymbolCode,
             SymbolName,
             SymbolGroup,
             Description,
             IsEnabled,
             CcyPair,
             AlternateSymbol,
             StateMaker,
             StateDate,
             StateId)
            VALUES (@dataSourceId,
                    @moduleId,
                    @symbolTypeOisZeroId,
                    N'S0045Z 15Y BLC2 Curncy',
                    N'EUR ZERO15Y',
                    '',
                    '',
                    1,
                    '0',
                    0,
                    @stateMaker,
                    @stateDate,
                    @stateId);
        END;


    COMMIT TRANSACTION;

END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
    DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
    DECLARE @ErrorState INT = ERROR_STATE();
    DECLARE @ErrorLine INT = ERROR_LINE();

    RAISERROR ('Error on line %d: %s', @ErrorSeverity, @ErrorState, @ErrorLine, @ErrorMessage);
END CATCH