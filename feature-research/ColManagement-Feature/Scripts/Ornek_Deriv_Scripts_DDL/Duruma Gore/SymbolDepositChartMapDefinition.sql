use [NetTrexCommon]
GO
SET XACT_ABORT ON;

BEGIN TRANSACTION;

BEGIN TRY
    declare @stateMaker nvarchar(80) = 'SYSTEM',@stateDate datetime = getdate(),@stateId int = 18
    declare @dataSourceId int = 0,@moduleId int = 0,@chartOisId int = 0,@chartOisZeroId int = 0

    select @dataSourceId = Id from dbo.RateEngineDataSource where Code = N'Bloomberg' and IsEnabled = 1

    IF @dataSourceId = 0
        THROW 51000 ,'Data Source => Bloomberg Not Found',1

    PRINT CONCAT('Data Source Bloomberg Id => ', @dataSourceId);

    declare @pointTemp table
                       (
                           TenorId   int,
                           TenorDays int,
                           TenorCode nvarchar(10),
                           SetNo     int
                       )
    declare @pointRowTemp table
                          (
                              TenorId   int,
                              TenorDays int,
                              TenorCode nvarchar(10),
                              SetNo     int
                          )

    insert into @pointTemp(TenorId, TenorDays, TenorCode, SetNo)
    select Id, Days, PointCode, SetNo
    from dbo.Point
    where SetNo in (2, 4)

    select @moduleId = Id from dbo.RateEngineModule where Code = N'Deposit' and IsEnabled = 1

    IF @moduleId = 0
        THROW 51000 ,'Module => Deposit Not Found',1

    PRINT CONCAT('Module Deposit Id => ', @moduleId);

    IF NOT EXISTS (SELECT 1 FROM dbo.Chart WHERE Code = N'OIS')
        BEGIN
            INSERT INTO dbo.Chart
            (Name, Description, StateId, StateMaker, StateDate, Code, IsSystemDefinedChart, IsUserAnalytics,
             IsAdHocChart)
            VALUES (N'OIS Rates',
                    N'Overnight Indexed Swap Rates',
                    @stateId,
                    @stateMaker,
                    @stateDate,
                    N'OIS',
                    1,
                    NULL,
                    1);
            select top 1 @chartOisId = Id from dbo.Chart where Code = N'OIS'
        END;
    ELSE
        BEGIN
            select top 1 @chartOisId = Id FROM dbo.Chart WHERE [Code] = N'OIS'
        END

    IF @chartOisId = 0
        THROW 51000 ,'Chart => OIS Not Found',1

    PRINT CONCAT('Chart OIS Id => ', @chartOisId);

    IF NOT EXISTS (SELECT 1 FROM dbo.Chart WHERE Code = N'OISZero')
        BEGIN
            INSERT INTO dbo.Chart
            (Name,
             Description,
             StateId,
             StateMaker,
             StateDate,
             Code,
             IsSystemDefinedChart,
             IsUserAnalytics,
             IsAdHocChart)
            VALUES (N'OIS Zero Rates',
                    N'Overnight Indexed Swap Zero Rates',
                    @stateId,
                    @stateMaker,
                    @stateDate,
                    N'OISZero',
                    1,
                    NULL,
                    0);
            select top 1 @chartOisZeroId = Id from dbo.Chart where Code = N'OISZero'
        END;
    ELSE
        BEGIN
            select top 1 @chartOisZeroId = Id FROM dbo.Chart WHERE [Code] = N'OISZero'
        END

    IF @chartOisZeroId = 0
        THROW 51000 ,'Chart => OIS Zero Not Found',1

    PRINT CONCAT('Chart OIS Zero Id => ', @chartOisZeroId);

    insert into @pointRowTemp(TenorId, TenorDays, TenorCode, SetNo)
    select *
    from @pointTemp
    where SetNo = 2
      and TenorCode = N'O/N'

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 2, TenorCode = O/N',1;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolDepositRatesChartMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolName = N'USD SOFRON'
                     AND CCY = N'USD'
                     AND TenorCode = N'O/N')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUEs (@dataSourceId,
                    @moduleId,
                    N'USD SOFRON',
                    @chartOisId,
                    N'USD',
                    (select TenorId from @pointRowTemp),
                    (select TenorDays from @pointRowTemp),
                    (select TenorCode from @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate)
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 2
      AND TenorCode = N'1W';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 2, TenorCode = 1W',1;

    IF NOT EXISTS
        (SELECT 1
         FROM dbo.RateEngineSymbolDepositRatesChartMap
         WHERE DataSourceId = @dataSourceId
           AND ModuleId = @moduleId
           AND SymbolName = N'USD SOFR1W'
           AND CCY = N'USD'
           AND TenorCode = N'1W')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'USD SOFR1W',
                    @chartOisId,
                    N'USD',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 2
      AND TenorCode = N'2W';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 2, TenorCode = 2W',1;

    IF NOT EXISTS
        (SELECT 1
         FROM dbo.RateEngineSymbolDepositRatesChartMap
         WHERE DataSourceId = @dataSourceId
           AND ModuleId = @moduleId
           AND SymbolName = N'USD SOFR2W'
           AND CCY = N'USD'
           AND TenorCode = N'2W')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'USD SOFR2W',
                    @chartOisId,
                    N'USD',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 2
      AND TenorCode = N'3W';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 2, TenorCode = 3W',1;

    IF NOT EXISTS
        (SELECT 1
         FROM dbo.RateEngineSymbolDepositRatesChartMap
         WHERE DataSourceId = @dataSourceId
           AND ModuleId = @moduleId
           AND SymbolName = N'USD SOFR3W'
           AND CCY = N'USD'
           AND TenorCode = N'3W')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'USD SOFR3W',
                    @chartOisId,
                    N'USD',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 2
      AND TenorCode = N'1M';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 2, TenorCode = 1M',1;

    IF NOT EXISTS
        (SELECT 1
         FROM dbo.RateEngineSymbolDepositRatesChartMap
         WHERE DataSourceId = @dataSourceId
           AND ModuleId = @moduleId
           AND SymbolName = N'USD SOFR1M'
           AND CCY = N'USD'
           AND TenorCode = N'1M')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'USD SOFR1M',
                    @chartOisId,
                    N'USD',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 2
      AND TenorCode = N'2M';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 2, TenorCode = 2M',1;

    IF NOT EXISTS
        (SELECT 1
         FROM dbo.RateEngineSymbolDepositRatesChartMap
         WHERE DataSourceId = @dataSourceId
           AND ModuleId = @moduleId
           AND SymbolName = N'USD SOFR2M'
           AND CCY = N'USD'
           AND TenorCode = N'2M')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'USD SOFR2M',
                    @chartOisId,
                    N'USD',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 2
      AND TenorCode = N'3M';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 2, TenorCode = 3M',1;

    IF NOT EXISTS
        (SELECT 1
         FROM dbo.RateEngineSymbolDepositRatesChartMap
         WHERE DataSourceId = @dataSourceId
           AND ModuleId = @moduleId
           AND SymbolName = N'USD SOFR3M'
           AND CCY = N'USD'
           AND TenorCode = N'3M')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'USD SOFR3M',
                    @chartOisId,
                    N'USD',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 2
      AND TenorCode = N'4M';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 2, TenorCode = 4M',1;

    IF NOT EXISTS
        (SELECT 1
         FROM dbo.RateEngineSymbolDepositRatesChartMap
         WHERE DataSourceId = @dataSourceId
           AND ModuleId = @moduleId
           AND SymbolName = N'USD SOFR4M'
           AND CCY = N'USD'
           AND TenorCode = N'4M')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'USD SOFR4M',
                    @chartOisId,
                    N'USD',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 2
      AND TenorCode = N'5M';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 2, TenorCode = 5M',1;

    IF NOT EXISTS
        (SELECT 1
         FROM dbo.RateEngineSymbolDepositRatesChartMap
         WHERE DataSourceId = @dataSourceId
           AND ModuleId = @moduleId
           AND SymbolName = N'USD SOFR5M'
           AND CCY = N'USD'
           AND TenorCode = N'5M')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'USD SOFR5M',
                    @chartOisId,
                    N'USD',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 2
      AND TenorCode = N'6M';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 2, TenorCode = 6M',1;

    IF NOT EXISTS
        (SELECT 1
         FROM dbo.RateEngineSymbolDepositRatesChartMap
         WHERE DataSourceId = @dataSourceId
           AND ModuleId = @moduleId
           AND SymbolName = N'USD SOFR6M'
           AND CCY = N'USD'
           AND TenorCode = N'6M')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'USD SOFR6M',
                    @chartOisId,
                    N'USD',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 2
      AND TenorCode = N'7M';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 2, TenorCode = 7M',1;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolDepositRatesChartMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolName = N'USD SOFR7M'
                     AND CCY = N'USD'
                     AND TenorCode = N'7M')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'USD SOFR7M',
                    @chartOisId,
                    N'USD',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 2
      AND TenorCode = N'8M';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 2, TenorCode = 8M',1;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolDepositRatesChartMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolName = N'USD SOFR8M'
                     AND CCY = N'USD'
                     AND TenorCode = N'8M')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'USD SOFR8M',
                    @chartOisId,
                    N'USD',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 2
      AND TenorCode = N'9M';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 2, TenorCode = 9M',1;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolDepositRatesChartMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolName = N'USD SOFR9M'
                     AND CCY = N'USD'
                     AND TenorCode = N'9M')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'USD SOFR9M',
                    @chartOisId,
                    N'USD',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 2
      AND TenorCode = N'10M';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 2, TenorCode = 10M',1;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolDepositRatesChartMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolName = N'USD SOFR10M'
                     AND CCY = N'USD'
                     AND TenorCode = N'10M')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'USD SOFR10M',
                    @chartOisId,
                    N'USD',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 2
      AND TenorCode = N'11M';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 2, TenorCode = 11M',1;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolDepositRatesChartMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolName = N'USD SOFR11M'
                     AND CCY = N'USD'
                     AND TenorCode = N'11M')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'USD SOFR11M',
                    @chartOisId,
                    N'USD',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 2
      AND TenorCode = N'12M';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 2, TenorCode = 12M',1;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolDepositRatesChartMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolName = N'USD SOFR12M'
                     AND CCY = N'USD'
                     AND TenorCode = N'12M')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'USD SOFR12M',
                    @chartOisId,
                    N'USD',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 2
      AND TenorCode = N'18M';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 2, TenorCode = 18M',1;

    IF NOT EXISTS
        (SELECT 1
         FROM dbo.RateEngineSymbolDepositRatesChartMap
         WHERE DataSourceId = @dataSourceId
           AND ModuleId = @moduleId
           AND SymbolName = N'USD SOFR18M'
           AND CCY = N'USD'
           AND TenorCode = N'18M')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'USD SOFR18M',
                    @chartOisId,
                    N'USD',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 2
      AND TenorCode = N'2Y';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 2, TenorCode = 2Y',1;

    IF NOT EXISTS
        (SELECT 1
         FROM dbo.RateEngineSymbolDepositRatesChartMap
         WHERE DataSourceId = @dataSourceId
           AND ModuleId = @moduleId
           AND SymbolName = N'USD SOFR2Y'
           AND CCY = N'USD'
           AND TenorCode = N'2Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'USD SOFR2Y',
                    @chartOisId,
                    N'USD',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 2
      AND TenorCode = N'3Y';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 2, TenorCode = 3Y',1;

    IF NOT EXISTS
        (SELECT 1
         FROM dbo.RateEngineSymbolDepositRatesChartMap
         WHERE DataSourceId = @dataSourceId
           AND ModuleId = @moduleId
           AND SymbolName = N'USD SOFR3Y'
           AND CCY = N'USD'
           AND TenorCode = N'3Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'USD SOFR3Y',
                    @chartOisId,
                    N'USD',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 2
      AND TenorCode = N'4Y';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 2, TenorCode = 4Y',1;

    IF NOT EXISTS
        (SELECT 1
         FROM dbo.RateEngineSymbolDepositRatesChartMap
         WHERE DataSourceId = @dataSourceId
           AND ModuleId = @moduleId
           AND SymbolName = N'USD SOFR4Y'
           AND CCY = N'USD'
           AND TenorCode = N'4Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'USD SOFR4Y',
                    @chartOisId,
                    N'USD',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
            DELETE FROM @pointRowTemp;
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 2
      AND TenorCode = N'5Y';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 2, TenorCode = 5Y',1;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolDepositRatesChartMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolName = N'USD SOFR5Y'
                     AND CCY = N'USD'
                     AND TenorCode = N'5Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'USD SOFR5Y',
                    @chartOisId,
                    N'USD',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
            DELETE FROM @pointRowTemp;
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 2
      AND TenorCode = N'6Y';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 2, TenorCode = 6Y',1;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolDepositRatesChartMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolName = N'USD SOFR6Y'
                     AND CCY = N'USD'
                     AND TenorCode = N'6Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'USD SOFR6Y',
                    @chartOisId,
                    N'USD',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 2
      AND TenorCode = N'7Y';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 2, TenorCode = 7Y',1;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolDepositRatesChartMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolName = N'USD SOFR7Y'
                     AND CCY = N'USD'
                     AND TenorCode = N'7Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'USD SOFR7Y',
                    @chartOisId,
                    N'USD',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 2
      AND TenorCode = N'8Y';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 2, TenorCode = 8Y',1;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolDepositRatesChartMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolName = N'USD SOFR8Y'
                     AND CCY = N'USD'
                     AND TenorCode = N'8Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'USD SOFR8Y',
                    @chartOisId,
                    N'USD',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 2
      AND TenorCode = N'9Y';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 2, TenorCode = 9Y',1;

    IF NOT EXISTS(SELECT 1
                  FROM dbo.RateEngineSymbolDepositRatesChartMap
                  WHERE DataSourceId = @dataSourceId
                    AND ModuleId = @moduleId
                    AND SymbolName = N'USD SOFR9Y'
                    AND CCY = N'USD'
                    AND TenorCode = N'9Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'USD SOFR9Y',
                    @chartOisId,
                    N'USD',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 2
      AND TenorCode = N'10Y';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 2, TenorCode = 10Y',1;

    IF NOT EXISTS(SELECT 1
                  FROM dbo.RateEngineSymbolDepositRatesChartMap
                  WHERE DataSourceId = @dataSourceId
                    AND ModuleId = @moduleId
                    AND SymbolName = N'USD SOFR10Y'
                    AND CCY = N'USD'
                    AND TenorCode = N'10Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'USD SOFR10Y',
                    @chartOisId,
                    N'USD',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 2
      AND TenorCode = N'12Y';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 2, TenorCode = 12Y',1;

    IF NOT EXISTS(SELECT 1
                  FROM dbo.RateEngineSymbolDepositRatesChartMap
                  WHERE DataSourceId = @dataSourceId
                    AND ModuleId = @moduleId
                    AND SymbolName = N'USD SOFR12Y'
                    AND CCY = N'USD'
                    AND TenorCode = N'12Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'USD SOFR12Y',
                    @chartOisId,
                    N'USD',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 2
      AND TenorCode = N'15Y';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 2, TenorCode = 15Y',1;

    IF NOT EXISTS(SELECT 1
                  FROM dbo.RateEngineSymbolDepositRatesChartMap
                  WHERE DataSourceId = @dataSourceId
                    AND ModuleId = @moduleId
                    AND SymbolName = N'USD SOFR15Y'
                    AND CCY = N'USD'
                    AND TenorCode = N'15Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'USD SOFR15Y',
                    @chartOisId,
                    N'USD',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 2
      AND TenorCode = N'20Y';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 2, TenorCode = 20Y',1;

    IF NOT EXISTS(SELECT 1
                  FROM dbo.RateEngineSymbolDepositRatesChartMap
                  WHERE DataSourceId = @dataSourceId
                    AND ModuleId = @moduleId
                    AND SymbolName = N'USD SOFR20Y'
                    AND CCY = N'USD'
                    AND TenorCode = N'20Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'USD SOFR20Y',
                    @chartOisId,
                    N'USD',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 2
      AND TenorCode = N'25Y';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 2, TenorCode = 25Y',1;

    IF NOT EXISTS(SELECT 1
                  FROM dbo.RateEngineSymbolDepositRatesChartMap
                  WHERE DataSourceId = @dataSourceId
                    AND ModuleId = @moduleId
                    AND SymbolName = N'USD SOFR25Y'
                    AND CCY = N'USD'
                    AND TenorCode = N'25Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'USD SOFR25Y',
                    @chartOisId,
                    N'USD',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 2
      AND TenorCode = N'30Y';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 2, TenorCode = 30Y',1;

    IF NOT EXISTS(SELECT 1
                  FROM dbo.RateEngineSymbolDepositRatesChartMap
                  WHERE DataSourceId = @dataSourceId
                    AND ModuleId = @moduleId
                    AND SymbolName = N'USD SOFR30Y'
                    AND CCY = N'USD'
                    AND TenorCode = N'30Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'USD SOFR30Y',
                    @chartOisId,
                    N'USD',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 2
      AND TenorCode = N'40Y';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 2, TenorCode = 40Y',1;

    IF NOT EXISTS(SELECT 1
                  FROM dbo.RateEngineSymbolDepositRatesChartMap
                  WHERE DataSourceId = @dataSourceId
                    AND ModuleId = @moduleId
                    AND SymbolName = N'USD SOFR40Y'
                    AND CCY = N'USD'
                    AND TenorCode = N'40Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'USD SOFR40Y',
                    @chartOisId,
                    N'USD',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 2
      AND TenorCode = N'50Y';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 2, TenorCode = 50Y',1;

    IF NOT EXISTS(SELECT 1
                  FROM dbo.RateEngineSymbolDepositRatesChartMap
                  WHERE DataSourceId = @dataSourceId
                    AND ModuleId = @moduleId
                    AND SymbolName = N'USD SOFR50Y'
                    AND CCY = N'USD'
                    AND TenorCode = N'50Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'USD SOFR50Y',
                    @chartOisId,
                    N'USD',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 2
      AND TenorCode = N'3M';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 2, TenorCode = 3M',1;

    IF NOT EXISTS(SELECT 1
                  FROM dbo.RateEngineSymbolDepositRatesChartMap
                  WHERE DataSourceId = @dataSourceId
                    AND ModuleId = @moduleId
                    AND SymbolName = N'USD TERMSOFR3M'
                    AND CCY = N'USD'
                    AND TenorCode = N'3M')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'USD TERMSOFR3M',
                    @chartOisId,
                    N'USD',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 2
      AND TenorCode = N'6M';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 2, TenorCode = 6M',1;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolDepositRatesChartMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolName = N'USD TERMSOFR6M'
                     AND CCY = N'USD'
                     AND TenorCode = N'6M')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'USD TERMSOFR6M',
                    @chartOisId,
                    N'USD',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 2
      AND TenorCode = N'1W';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 2, TenorCode = 1W',1;

    IF NOT EXISTS(SELECT 1
                  FROM dbo.RateEngineSymbolDepositRatesChartMap
                  WHERE DataSourceId = @dataSourceId
                    AND ModuleId = @moduleId
                    AND SymbolName = N'USD OIS1W'
                    AND CCY = N'USD'
                    AND TenorCode = N'1W')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'USD OIS1W',
                    @chartOisId,
                    N'USD',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 2
      AND TenorCode = N'2W';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 2, TenorCode = 2W',1;

    IF NOT EXISTS(SELECT 1
                  FROM dbo.RateEngineSymbolDepositRatesChartMap
                  WHERE DataSourceId = @dataSourceId
                    AND ModuleId = @moduleId
                    AND SymbolName = N'USD OIS2W'
                    AND CCY = N'USD'
                    AND TenorCode = N'2W')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'USD OIS2W',
                    @chartOisId,
                    N'USD',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 2
      AND TenorCode = N'3W';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 2, TenorCode = 3W',1;

    IF NOT EXISTS(SELECT 1
                  FROM dbo.RateEngineSymbolDepositRatesChartMap
                  WHERE DataSourceId = @dataSourceId
                    AND ModuleId = @moduleId
                    AND SymbolName = N'USD OIS3W'
                    AND CCY = N'USD'
                    AND TenorCode = N'3W')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'USD OIS3W',
                    @chartOisId,
                    N'USD',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 2
      AND TenorCode = N'1M';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 2, TenorCode = 1M',1;

    IF NOT EXISTS(SELECT 1
                  FROM dbo.RateEngineSymbolDepositRatesChartMap
                  WHERE DataSourceId = @dataSourceId
                    AND ModuleId = @moduleId
                    AND SymbolName = N'USD OIS1M'
                    AND CCY = N'USD'
                    AND TenorCode = N'1M')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'USD OIS1M',
                    @chartOisId,
                    N'USD',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
            DELETE FROM @pointRowTemp;
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 2
      AND TenorCode = N'2M';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 2, TenorCode = 2M',1;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolDepositRatesChartMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolName = N'USD OIS2M'
                     AND CCY = N'USD'
                     AND TenorCode = N'2M')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'USD OIS2M',
                    @chartOisId,
                    N'USD',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
            DELETE FROM @pointRowTemp;
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 2
      AND TenorCode = N'3M';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 2, TenorCode = 3M',1;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolDepositRatesChartMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolName = N'USD OIS3M'
                     AND CCY = N'USD'
                     AND TenorCode = N'3M')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'USD OIS3M',
                    @chartOisId,
                    N'USD',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 2
      AND TenorCode = N'4M';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 2, TenorCode = 4M',1;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolDepositRatesChartMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolName = N'USD OIS4M'
                     AND CCY = N'USD'
                     AND TenorCode = N'4M')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'USD OIS4M',
                    @chartOisId,
                    N'USD',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 2
      AND TenorCode = N'5M';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 2, TenorCode = 5M',1;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolDepositRatesChartMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolName = N'USD OIS5M'
                     AND CCY = N'USD'
                     AND TenorCode = N'5M')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'USD OIS5M',
                    @chartOisId,
                    N'USD',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 2
      AND TenorCode = N'6M';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 2, TenorCode = 6M',1;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolDepositRatesChartMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolName = N'USD OIS6M'
                     AND CCY = N'USD'
                     AND TenorCode = N'6M')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'USD OIS6M',
                    @chartOisId,
                    N'USD',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 2
      AND TenorCode = N'9M';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 2, TenorCode = 9M',1;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolDepositRatesChartMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolName = N'USD OIS9M'
                     AND CCY = N'USD'
                     AND TenorCode = N'9M')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'USD OIS9M',
                    @chartOisId,
                    N'USD',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 2
      AND TenorCode = N'12M';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 2, TenorCode = 12M',1;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolDepositRatesChartMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolName = N'USD OIS12M'
                     AND CCY = N'USD'
                     AND TenorCode = N'12M')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'USD OIS12M',
                    @chartOisId,
                    N'USD',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 2
      AND TenorCode = N'18M';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 2, TenorCode = 18M',1;

    IF NOT EXISTS(SELECT 1
                  FROM dbo.RateEngineSymbolDepositRatesChartMap
                  WHERE DataSourceId = @dataSourceId
                    AND ModuleId = @moduleId
                    AND SymbolName = N'USD OIS18M'
                    AND CCY = N'USD'
                    AND TenorCode = N'18M')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'USD OIS18M',
                    @chartOisId,
                    N'USD',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 2
      AND TenorCode = N'O/N';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 2, TenorCode = O/N',1;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolDepositRatesChartMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolName = N'EUR ESTRON'
                     AND CCY = N'EUR'
                     AND TenorCode = N'O/N')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'EUR ESTRON',
                    @chartOisId,
                    N'EUR',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 2
      AND TenorCode = N'1W';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 2, TenorCode = 1W',1;

    IF NOT EXISTS(SELECT 1
                  FROM dbo.RateEngineSymbolDepositRatesChartMap
                  WHERE DataSourceId = @dataSourceId
                    AND ModuleId = @moduleId
                    AND SymbolName = N'EUR ESTR1W'
                    AND CCY = N'EUR'
                    AND TenorCode = N'1W')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'EUR ESTR1W',
                    @chartOisId,
                    N'EUR',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 2
      AND TenorCode = N'2W';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 2, TenorCode = 2W',1;

    IF NOT EXISTS(SELECT 1
                  FROM dbo.RateEngineSymbolDepositRatesChartMap
                  WHERE DataSourceId = @dataSourceId
                    AND ModuleId = @moduleId
                    AND SymbolName = N'EUR ESTR2W'
                    AND CCY = N'EUR'
                    AND TenorCode = N'2W')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'EUR ESTR2W',
                    @chartOisId,
                    N'EUR',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 2
      AND TenorCode = N'1M';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 2, TenorCode = 1M',1;

    IF NOT EXISTS(SELECT 1
                  FROM dbo.RateEngineSymbolDepositRatesChartMap
                  WHERE DataSourceId = @dataSourceId
                    AND ModuleId = @moduleId
                    AND SymbolName = N'EUR ESTR1M'
                    AND CCY = N'EUR'
                    AND TenorCode = N'1M')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'EUR ESTR1M',
                    @chartOisId,
                    N'EUR',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 2
      AND TenorCode = N'2M';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 2, TenorCode = 2M',1;

    IF NOT EXISTS(SELECT 1
                  FROM dbo.RateEngineSymbolDepositRatesChartMap
                  WHERE DataSourceId = @dataSourceId
                    AND ModuleId = @moduleId
                    AND SymbolName = N'EUR ESTR2M'
                    AND CCY = N'EUR'
                    AND TenorCode = N'2M')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'EUR ESTR2M',
                    @chartOisId,
                    N'EUR',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 2
      AND TenorCode = N'3M';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 2, TenorCode = 3M',1;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolDepositRatesChartMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolName = N'EUR ESTR3M'
                     AND CCY = N'EUR'
                     AND TenorCode = N'3M')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'EUR ESTR3M',
                    @chartOisId,
                    N'EUR',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 2
      AND TenorCode = N'4M';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 2, TenorCode = 4M',1;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolDepositRatesChartMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolName = N'EUR ESTR4M'
                     AND CCY = N'EUR'
                     AND TenorCode = N'4M')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'EUR ESTR4M',
                    @chartOisId,
                    N'EUR',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 2
      AND TenorCode = N'5M';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 2, TenorCode = 5M',1;

    IF NOT EXISTS(SELECT 1
                  FROM dbo.RateEngineSymbolDepositRatesChartMap
                  WHERE DataSourceId = @dataSourceId
                    AND ModuleId = @moduleId
                    AND SymbolName = N'EUR ESTR5M'
                    AND CCY = N'EUR'
                    AND TenorCode = N'5M')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'EUR ESTR5M',
                    @chartOisId,
                    N'EUR',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 2
      AND TenorCode = N'6M';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 2, TenorCode = 6M',1;

    IF NOT EXISTS(SELECT 1
                  FROM dbo.RateEngineSymbolDepositRatesChartMap
                  WHERE DataSourceId = @dataSourceId
                    AND ModuleId = @moduleId
                    AND SymbolName = N'EUR ESTR6M'
                    AND CCY = N'EUR'
                    AND TenorCode = N'6M')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'EUR ESTR6M',
                    @chartOisId,
                    N'EUR',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 2
      AND TenorCode = N'7M';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 2, TenorCode = 7M',1;

    IF NOT EXISTS(SELECT 1
                  FROM dbo.RateEngineSymbolDepositRatesChartMap
                  WHERE DataSourceId = @dataSourceId
                    AND ModuleId = @moduleId
                    AND SymbolName = N'EUR ESTR7M'
                    AND CCY = N'EUR'
                    AND TenorCode = N'7M')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'EUR ESTR7M',
                    @chartOisId,
                    N'EUR',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 2
      AND TenorCode = N'8M';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 2, TenorCode = 8M',1;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolDepositRatesChartMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolName = N'EUR ESTR8M'
                     AND CCY = N'EUR'
                     AND TenorCode = N'8M')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'EUR ESTR8M',
                    @chartOisId,
                    N'EUR',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 2
      AND TenorCode = N'9M';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 2, TenorCode = 9M',1;

    IF NOT EXISTS(SELECT 1
                  FROM dbo.RateEngineSymbolDepositRatesChartMap
                  WHERE DataSourceId = @dataSourceId
                    AND ModuleId = @moduleId
                    AND SymbolName = N'EUR ESTR9M'
                    AND CCY = N'EUR'
                    AND TenorCode = N'9M')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'EUR ESTR9M',
                    @chartOisId,
                    N'EUR',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 2
      AND TenorCode = N'10M';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 2, TenorCode = 10M',1;

    IF NOT EXISTS
        (SELECT 1
         FROM dbo.RateEngineSymbolDepositRatesChartMap
         WHERE DataSourceId = @dataSourceId
           AND ModuleId = @moduleId
           AND SymbolName = N'EUR ESTR10M'
           AND CCY = N'EUR'
           AND TenorCode = N'10M')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'EUR ESTR10M',
                    @chartOisId,
                    N'EUR',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 2
      AND TenorCode = N'11M';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 2, TenorCode = 11M',1;

    IF NOT EXISTS(SELECT 1
                  FROM dbo.RateEngineSymbolDepositRatesChartMap
                  WHERE DataSourceId = @dataSourceId
                    AND ModuleId = @moduleId
                    AND SymbolName = N'EUR ESTR11M'
                    AND CCY = N'EUR'
                    AND TenorCode = N'11M')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'EUR ESTR11M',
                    @chartOisId,
                    N'EUR',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 2
      AND TenorCode = N'12M';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 2, TenorCode = 12M',1;

    IF NOT EXISTS(SELECT 1
                  FROM dbo.RateEngineSymbolDepositRatesChartMap
                  WHERE DataSourceId = @dataSourceId
                    AND ModuleId = @moduleId
                    AND SymbolName = N'EUR ESTR12M'
                    AND CCY = N'EUR'
                    AND TenorCode = N'12M')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'EUR ESTR12M',
                    @chartOisId,
                    N'EUR',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 2
      AND TenorCode = N'18M';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 2, TenorCode = 18M',1;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolDepositRatesChartMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolName = N'EUR ESTR18M'
                     AND CCY = N'EUR'
                     AND TenorCode = N'18M')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'EUR ESTR18M',
                    @chartOisId,
                    N'EUR',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 2
      AND TenorCode = N'2Y';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 2, TenorCode = 2Y',1;

    IF NOT EXISTS(SELECT 1
                  FROM dbo.RateEngineSymbolDepositRatesChartMap
                  WHERE DataSourceId = @dataSourceId
                    AND ModuleId = @moduleId
                    AND SymbolName = N'EUR ESTR2Y'
                    AND CCY = N'EUR'
                    AND TenorCode = N'2Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'EUR ESTR2Y',
                    @chartOisId,
                    N'EUR',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 2
      AND TenorCode = N'3Y';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 2, TenorCode = 3Y',1;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolDepositRatesChartMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolName = N'EUR ESTR3Y'
                     AND CCY = N'EUR'
                     AND TenorCode = N'3Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'EUR ESTR3Y',
                    @chartOisId,
                    N'EUR',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 2
      AND TenorCode = N'4Y';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 2, TenorCode = 4Y',1;

    IF NOT EXISTS(SELECT 1
                  FROM dbo.RateEngineSymbolDepositRatesChartMap
                  WHERE DataSourceId = @dataSourceId
                    AND ModuleId = @moduleId
                    AND SymbolName = N'EUR ESTR4Y'
                    AND CCY = N'EUR'
                    AND TenorCode = N'4Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'EUR ESTR4Y',
                    @chartOisId,
                    N'EUR',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 2
      AND TenorCode = N'5Y';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 2, TenorCode = 5Y',1;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolDepositRatesChartMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolName = N'EUR ESTR5Y'
                     AND CCY = N'EUR'
                     AND TenorCode = N'5Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'EUR ESTR5Y',
                    @chartOisId,
                    N'EUR',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 2
      AND TenorCode = N'6Y';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 2, TenorCode = 6Y',1;

    IF NOT EXISTS(SELECT 1
                  FROM dbo.RateEngineSymbolDepositRatesChartMap
                  WHERE DataSourceId = @dataSourceId
                    AND ModuleId = @moduleId
                    AND SymbolName = N'EUR ESTR6Y'
                    AND CCY = N'EUR'
                    AND TenorCode = N'6Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'EUR ESTR6Y',
                    @chartOisId,
                    N'EUR',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 2
      AND TenorCode = N'7Y';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 2, TenorCode = 7Y',1;

    IF NOT EXISTS(SELECT 1
                  FROM dbo.RateEngineSymbolDepositRatesChartMap
                  WHERE DataSourceId = @dataSourceId
                    AND ModuleId = @moduleId
                    AND SymbolName = N'EUR ESTR7Y'
                    AND CCY = N'EUR'
                    AND TenorCode = N'7Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'EUR ESTR7Y',
                    @chartOisId,
                    N'EUR',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 2
      AND TenorCode = N'8Y';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 2, TenorCode = 8Y',1;

    IF NOT EXISTS(SELECT 1
                  FROM dbo.RateEngineSymbolDepositRatesChartMap
                  WHERE DataSourceId = @dataSourceId
                    AND ModuleId = @moduleId
                    AND SymbolName = N'EUR ESTR8Y'
                    AND CCY = N'EUR'
                    AND TenorCode = N'8Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'EUR ESTR8Y',
                    @chartOisId,
                    N'EUR',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 2
      AND TenorCode = N'9Y';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 2, TenorCode = 9Y',1;

    IF NOT EXISTS(SELECT 1
                  FROM dbo.RateEngineSymbolDepositRatesChartMap
                  WHERE DataSourceId = @dataSourceId
                    AND ModuleId = @moduleId
                    AND SymbolName = N'EUR ESTR9Y'
                    AND CCY = N'EUR'
                    AND TenorCode = N'9Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'EUR ESTR9Y',
                    @chartOisId,
                    N'EUR',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 2
      AND TenorCode = N'10Y';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 2, TenorCode = 10Y',1;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolDepositRatesChartMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolName = N'EUR ESTR10Y'
                     AND CCY = N'EUR'
                     AND TenorCode = N'10Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'EUR ESTR10Y',
                    @chartOisId,
                    N'EUR',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 2
      AND TenorCode = N'11Y';

    IF NOT EXISTS (SELECT 1
                   FROM @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 2, TenorCode = 11Y',1;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolDepositRatesChartMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolName = N'EUR ESTR11Y'
                     AND CCY = N'EUR'
                     AND TenorCode = N'11Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'EUR ESTR11Y',
                    @chartOisId,
                    N'EUR',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 2
      AND TenorCode = N'12Y';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 2, TenorCode = 12Y',1;

    IF NOT EXISTS(SELECT 1
                  FROM dbo.RateEngineSymbolDepositRatesChartMap
                  WHERE DataSourceId = @dataSourceId
                    AND ModuleId = @moduleId
                    AND SymbolName = N'EUR ESTR12Y'
                    AND CCY = N'EUR'
                    AND TenorCode = N'12Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'EUR ESTR12Y',
                    @chartOisId,
                    N'EUR',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 2
      AND TenorCode = N'15Y';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 2, TenorCode = 15Y',1;

    IF NOT EXISTS(SELECT 1
                  FROM dbo.RateEngineSymbolDepositRatesChartMap
                  WHERE DataSourceId = @dataSourceId
                    AND ModuleId = @moduleId
                    AND SymbolName = N'EUR ESTR15Y'
                    AND CCY = N'EUR'
                    AND TenorCode = N'15Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'EUR ESTR15Y',
                    @chartOisId,
                    N'EUR',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 2
      AND TenorCode = N'20Y';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 2, TenorCode = 20Y',1;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolDepositRatesChartMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolName = N'EUR ESTR20Y'
                     AND CCY = N'EUR'
                     AND TenorCode = N'20Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'EUR ESTR20Y',
                    @chartOisId,
                    N'EUR',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 2
      AND TenorCode = N'25Y';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 2, TenorCode = 25Y',1;

    IF NOT EXISTS(SELECT 1
                  FROM dbo.RateEngineSymbolDepositRatesChartMap
                  WHERE DataSourceId = @dataSourceId
                    AND ModuleId = @moduleId
                    AND SymbolName = N'EUR ESTR25Y'
                    AND CCY = N'EUR'
                    AND TenorCode = N'25Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'EUR ESTR25Y',
                    @chartOisId,
                    N'EUR',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 2
      AND TenorCode = N'30Y';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 2, TenorCode = 30Y',1;

    IF NOT EXISTS(SELECT 1
                  FROM dbo.RateEngineSymbolDepositRatesChartMap
                  WHERE DataSourceId = @dataSourceId
                    AND ModuleId = @moduleId
                    AND SymbolName = N'EUR ESTR30Y'
                    AND CCY = N'EUR'
                    AND TenorCode = N'30Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'EUR ESTR30Y',
                    @chartOisId,
                    N'EUR',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 2
      AND TenorCode = N'40Y';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 2, TenorCode = 40Y',1;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolDepositRatesChartMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolName = N'EUR ESTR40Y'
                     AND CCY = N'EUR'
                     AND TenorCode = N'40Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'EUR ESTR40Y',
                    @chartOisId,
                    N'EUR',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 2
      AND TenorCode = N'50Y';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 2, TenorCode = 50Y',1;

    IF NOT EXISTS(SELECT 1
                  FROM dbo.RateEngineSymbolDepositRatesChartMap
                  WHERE DataSourceId = @dataSourceId
                    AND ModuleId = @moduleId
                    AND SymbolName = N'EUR ESTR50Y'
                    AND CCY = N'EUR'
                    AND TenorCode = N'50Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'EUR ESTR50Y',
                    @chartOisId,
                    N'EUR',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 2
      AND TenorCode = N'3M';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 2, TenorCode = 3M',1;

    IF NOT EXISTS(SELECT 1
                  FROM dbo.RateEngineSymbolDepositRatesChartMap
                  WHERE DataSourceId = @dataSourceId
                    AND ModuleId = @moduleId
                    AND SymbolName = N'EUR IBOR3M'
                    AND CCY = N'EUR'
                    AND TenorCode = N'3M')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'EUR IBOR3M',
                    @chartOisId,
                    N'EUR',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 2
      AND TenorCode = N'3Y';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 2, TenorCode = 3Y',1;

    IF NOT EXISTS(SELECT 1
                  FROM dbo.RateEngineSymbolDepositRatesChartMap
                  WHERE DataSourceId = @dataSourceId
                    AND ModuleId = @moduleId
                    AND SymbolName = N'EUR IBOR3Y'
                    AND CCY = N'EUR'
                    AND TenorCode = N'3Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'EUR IBOR3Y',
                    @chartOisId,
                    N'EUR',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 2
      AND TenorCode = N'4Y';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 2, TenorCode = 4Y',1;

    IF NOT EXISTS(SELECT 1
                  FROM dbo.RateEngineSymbolDepositRatesChartMap
                  WHERE DataSourceId = @dataSourceId
                    AND ModuleId = @moduleId
                    AND SymbolName = N'EUR IBOR4Y'
                    AND CCY = N'EUR'
                    AND TenorCode = N'4Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'EUR IBOR4Y',
                    @chartOisId,
                    N'EUR',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 2
      AND TenorCode = N'5Y';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 2, TenorCode = 5Y',1;

    IF NOT EXISTS(SELECT 1
                  FROM dbo.RateEngineSymbolDepositRatesChartMap
                  WHERE DataSourceId = @dataSourceId
                    AND ModuleId = @moduleId
                    AND SymbolName = N'EUR IBOR5Y'
                    AND CCY = N'EUR'
                    AND TenorCode = N'5Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'EUR IBOR5Y',
                    @chartOisId,
                    N'EUR',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 2
      AND TenorCode = N'6Y';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 2, TenorCode = 6Y',1;

    IF NOT EXISTS(SELECT 1
                  FROM dbo.RateEngineSymbolDepositRatesChartMap
                  WHERE DataSourceId = @dataSourceId
                    AND ModuleId = @moduleId
                    AND SymbolName = N'EUR IBOR6Y'
                    AND CCY = N'EUR'
                    AND TenorCode = N'6Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'EUR IBOR6Y',
                    @chartOisId,
                    N'EUR',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 2
      AND TenorCode = N'7Y';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 2, TenorCode = 7Y',1;

    IF NOT EXISTS(SELECT 1
                  FROM dbo.RateEngineSymbolDepositRatesChartMap
                  WHERE DataSourceId = @dataSourceId
                    AND ModuleId = @moduleId
                    AND SymbolName = N'EUR IBOR7Y'
                    AND CCY = N'EUR'
                    AND TenorCode = N'7Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'EUR IBOR7Y',
                    @chartOisId,
                    N'EUR',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 2
      AND TenorCode = N'8Y';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 2, TenorCode = 8Y',1;

    IF NOT EXISTS(SELECT 1
                  FROM dbo.RateEngineSymbolDepositRatesChartMap
                  WHERE DataSourceId = @dataSourceId
                    AND ModuleId = @moduleId
                    AND SymbolName = N'EUR IBOR8Y'
                    AND CCY = N'EUR'
                    AND TenorCode = N'8Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'EUR IBOR8Y',
                    @chartOisId,
                    N'EUR',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 2
      AND TenorCode = N'9Y';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 2, TenorCode = 9Y',1;

    IF NOT EXISTS(SELECT 1
                  FROM dbo.RateEngineSymbolDepositRatesChartMap
                  WHERE DataSourceId = @dataSourceId
                    AND ModuleId = @moduleId
                    AND SymbolName = N'EUR IBOR9Y'
                    AND CCY = N'EUR'
                    AND TenorCode = N'9Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'EUR IBOR9Y',
                    @chartOisId,
                    N'EUR',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 2
      AND TenorCode = N'10Y';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 2, TenorCode = 10Y',1;

    IF NOT EXISTS(SELECT 1
                  FROM dbo.RateEngineSymbolDepositRatesChartMap
                  WHERE DataSourceId = @dataSourceId
                    AND ModuleId = @moduleId
                    AND SymbolName = N'EUR IBOR10Y'
                    AND CCY = N'EUR'
                    AND TenorCode = N'10Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'EUR IBOR10Y',
                    @chartOisId,
                    N'EUR',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 2
      AND TenorCode = N'11Y';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 2, TenorCode = 11Y',1;

    IF NOT EXISTS(SELECT 1
                  FROM dbo.RateEngineSymbolDepositRatesChartMap
                  WHERE DataSourceId = @dataSourceId
                    AND ModuleId = @moduleId
                    AND SymbolName = N'EUR IBOR11Y'
                    AND CCY = N'EUR'
                    AND TenorCode = N'11Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'EUR IBOR11Y',
                    @chartOisId,
                    N'EUR',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 2
      AND TenorCode = N'12Y';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 2, TenorCode = 12Y',1;

    IF NOT EXISTS(SELECT 1
                  FROM dbo.RateEngineSymbolDepositRatesChartMap
                  WHERE DataSourceId = @dataSourceId
                    AND ModuleId = @moduleId
                    AND SymbolName = N'EUR IBOR12Y'
                    AND CCY = N'EUR'
                    AND TenorCode = N'12Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'EUR IBOR12Y',
                    @chartOisId,
                    N'EUR',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 2
      AND TenorCode = N'15Y';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 2, TenorCode = 15Y',1;

    IF NOT EXISTS(SELECT 1
                  FROM dbo.RateEngineSymbolDepositRatesChartMap
                  WHERE DataSourceId = @dataSourceId
                    AND ModuleId = @moduleId
                    AND SymbolName = N'EUR IBOR15Y'
                    AND CCY = N'EUR'
                    AND TenorCode = N'15Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'EUR IBOR15Y',
                    @chartOisId,
                    N'EUR',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 2
      AND TenorCode = N'20Y';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 2, TenorCode = 20Y',1;

    IF NOT EXISTS(SELECT 1
                  FROM dbo.RateEngineSymbolDepositRatesChartMap
                  WHERE DataSourceId = @dataSourceId
                    AND ModuleId = @moduleId
                    AND SymbolName = N'EUR IBOR20Y'
                    AND CCY = N'EUR'
                    AND TenorCode = N'20Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'EUR IBOR20Y',
                    @chartOisId,
                    N'EUR',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 2
      AND TenorCode = N'25Y';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 2, TenorCode = 25Y',1;

    IF NOT EXISTS(SELECT 1
                  FROM dbo.RateEngineSymbolDepositRatesChartMap
                  WHERE DataSourceId = @dataSourceId
                    AND ModuleId = @moduleId
                    AND SymbolName = N'EUR IBOR25Y'
                    AND CCY = N'EUR'
                    AND TenorCode = N'25Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'EUR IBOR25Y',
                    @chartOisId,
                    N'EUR',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 2
      AND TenorCode = N'30Y';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 2, TenorCode = 30Y',1;

    IF NOT EXISTS(SELECT 1
                  FROM dbo.RateEngineSymbolDepositRatesChartMap
                  WHERE DataSourceId = @dataSourceId
                    AND ModuleId = @moduleId
                    AND SymbolName = N'EUR IBOR30Y'
                    AND CCY = N'EUR'
                    AND TenorCode = N'30Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'EUR IBOR30Y',
                    @chartOisId,
                    N'EUR',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 2
      AND TenorCode = N'40Y';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 2, TenorCode = 40Y',1;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolDepositRatesChartMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolName = N'EUR IBOR40Y'
                     AND CCY = N'EUR'
                     AND TenorCode = N'40Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'EUR IBOR40Y',
                    @chartOisId,
                    N'EUR',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 2
      AND TenorCode = N'50Y';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 2, TenorCode = 50Y',1;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolDepositRatesChartMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolName = N'EUR IBOR50Y'
                     AND CCY = N'EUR'
                     AND TenorCode = N'50Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'EUR IBOR50Y',
                    @chartOisId,
                    N'EUR',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 4
      AND TenorCode = N'1W';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 2, TenorCode = 1W',1;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolDepositRatesChartMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolName = N'GBP SONIA1W'
                     AND CCY = N'GBP'
                     AND TenorCode = N'1W')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'GBP SONIA1W',
                    @chartOisId,
                    N'GBP',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 4
      AND TenorCode = N'2W';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 2, TenorCode = 2W',1;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolDepositRatesChartMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolName = N'GBP SONIA2W'
                     AND CCY = N'GBP'
                     AND TenorCode = N'2W')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'GBP SONIA2W',
                    @chartOisId,
                    N'GBP',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 4
      AND TenorCode = N'1M';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 2, TenorCode = 1M',1;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolDepositRatesChartMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolName = N'GBP SONIA1M'
                     AND CCY = N'GBP'
                     AND TenorCode = N'1M')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'GBP SONIA1M',
                    @chartOisId,
                    N'GBP',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 4
      AND TenorCode = N'2M';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 2, TenorCode = 2M',1;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolDepositRatesChartMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolName = N'GBP SONIA2M'
                     AND CCY = N'GBP'
                     AND TenorCode = N'2M')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'GBP SONIA2M',
                    @chartOisId,
                    N'GBP',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 4
      AND TenorCode = N'3M';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 2, TenorCode = 3M',1;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolDepositRatesChartMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolName = N'GBP SONIA3M'
                     AND CCY = N'GBP'
                     AND TenorCode = N'3M')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'GBP SONIA3M',
                    @chartOisId,
                    N'GBP',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 4
      AND TenorCode = N'4M';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 2, TenorCode = 4M',1;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolDepositRatesChartMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolName = N'GBP SONIA4M'
                     AND CCY = N'GBP'
                     AND TenorCode = N'4M')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'GBP SONIA4M',
                    @chartOisId,
                    N'GBP',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 4
      AND TenorCode = N'5M';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 2, TenorCode = 5M',1;

    IF NOT EXISTS(SELECT 1
                  FROM dbo.RateEngineSymbolDepositRatesChartMap
                  WHERE DataSourceId = @dataSourceId
                    AND ModuleId = @moduleId
                    AND SymbolName = N'GBP SONIA5M'
                    AND CCY = N'GBP'
                    AND TenorCode = N'5M')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'GBP SONIA5M',
                    @chartOisId,
                    N'GBP',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 4
      AND TenorCode = N'6M';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 2, TenorCode = 6M',1;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolDepositRatesChartMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolName = N'GBP SONIA6M'
                     AND CCY = N'GBP'
                     AND TenorCode = N'6M')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'GBP SONIA6M',
                    @chartOisId,
                    N'GBP',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 4
      AND TenorCode = N'7M';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 2, TenorCode = 7M',1;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolDepositRatesChartMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolName = N'GBP SONIA7M'
                     AND CCY = N'GBP'
                     AND TenorCode = N'7M')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'GBP SONIA7M',
                    @chartOisId,
                    N'GBP',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 4
      AND TenorCode = N'8M';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 2, TenorCode = 8M',1;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolDepositRatesChartMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolName = N'GBP SONIA8M'
                     AND CCY = N'GBP'
                     AND TenorCode = N'8M')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'GBP SONIA8M',
                    @chartOisId,
                    N'GBP',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 4
      AND TenorCode = N'9M';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 2, TenorCode = 9M',1;

    IF NOT EXISTS(SELECT 1
                  FROM dbo.RateEngineSymbolDepositRatesChartMap
                  WHERE DataSourceId = @dataSourceId
                    AND ModuleId = @moduleId
                    AND SymbolName = N'GBP SONIA9M'
                    AND CCY = N'GBP'
                    AND TenorCode = N'9M')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'GBP SONIA9M',
                    @chartOisId,
                    N'GBP',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 4
      AND TenorCode = N'10M';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 2, TenorCode = 10M',1;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolDepositRatesChartMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolName = N'GBP SONIA10M'
                     AND CCY = N'GBP'
                     AND TenorCode = N'10M')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'GBP SONIA10M',
                    @chartOisId,
                    N'GBP',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 4
      AND TenorCode = N'11M';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 2, TenorCode = 11M',1;

    IF NOT EXISTS(SELECT 1
                  FROM dbo.RateEngineSymbolDepositRatesChartMap
                  WHERE DataSourceId = @dataSourceId
                    AND ModuleId = @moduleId
                    AND SymbolName = N'GBP SONIA11M'
                    AND CCY = N'GBP'
                    AND TenorCode = N'11M')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'GBP SONIA11M',
                    @chartOisId,
                    N'GBP',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 4
      AND TenorCode = N'12M';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 2, TenorCode = 12M',1;

    IF NOT EXISTS(SELECT 1
                  FROM dbo.RateEngineSymbolDepositRatesChartMap
                  WHERE DataSourceId = @dataSourceId
                    AND ModuleId = @moduleId
                    AND SymbolName = N'GBP SONIA12M'
                    AND CCY = N'GBP'
                    AND TenorCode = N'12M')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'GBP SONIA12M',
                    @chartOisId,
                    N'GBP',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 4
      AND TenorCode = N'18M';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 2, TenorCode = 18M',1;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolDepositRatesChartMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolName = N'GBP SONIA18M'
                     AND CCY = N'GBP'
                     AND TenorCode = N'18M')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'GBP SONIA18M',
                    @chartOisId,
                    N'GBP',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 4
      AND TenorCode = N'2Y';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 2, TenorCode = 2Y',1;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolDepositRatesChartMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolName = N'GBP SONIA2Y'
                     AND CCY = N'GBP'
                     AND TenorCode = N'2Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'GBP SONIA2Y',
                    @chartOisId,
                    N'GBP',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 4
      AND TenorCode = N'3Y';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 2, TenorCode = 3Y',1;

    IF NOT EXISTS(SELECT 1
                  FROM dbo.RateEngineSymbolDepositRatesChartMap
                  WHERE DataSourceId = @dataSourceId
                    AND ModuleId = @moduleId
                    AND SymbolName = N'GBP SONIA3Y'
                    AND CCY = N'GBP'
                    AND TenorCode = N'3Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'GBP SONIA3Y',
                    @chartOisId,
                    N'GBP',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 4
      AND TenorCode = N'4Y';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 2, TenorCode = 4Y',1;

    IF NOT EXISTS(SELECT 1
                  FROM dbo.RateEngineSymbolDepositRatesChartMap
                  WHERE DataSourceId = @dataSourceId
                    AND ModuleId = @moduleId
                    AND SymbolName = N'GBP SONIA4Y'
                    AND CCY = N'GBP'
                    AND TenorCode = N'4Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'GBP SONIA4Y',
                    @chartOisId,
                    N'GBP',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 4
      AND TenorCode = N'5Y';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 2, TenorCode = 5Y',1;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolDepositRatesChartMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolName = N'GBP SONIA5Y'
                     AND CCY = N'GBP'
                     AND TenorCode = N'5Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'GBP SONIA5Y',
                    @chartOisId,
                    N'GBP',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 4
      AND TenorCode = N'6Y';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 2, TenorCode = 6Y',1;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolDepositRatesChartMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolName = N'GBP SONIA6Y'
                     AND CCY = N'GBP'
                     AND TenorCode = N'6Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'GBP SONIA6Y',
                    @chartOisId,
                    N'GBP',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 4
      AND TenorCode = N'7Y';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 2, TenorCode = 7Y',1;

    IF NOT EXISTS(SELECT 1
                  FROM dbo.RateEngineSymbolDepositRatesChartMap
                  WHERE DataSourceId = @dataSourceId
                    AND ModuleId = @moduleId
                    AND SymbolName = N'GBP SONIA7Y'
                    AND CCY = N'GBP'
                    AND TenorCode = N'7Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'GBP SONIA7Y',
                    @chartOisId,
                    N'GBP',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 4
      AND TenorCode = N'8Y';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 2, TenorCode = 8Y',1;

    IF NOT EXISTS(SELECT 1
                  FROM dbo.RateEngineSymbolDepositRatesChartMap
                  WHERE DataSourceId = @dataSourceId
                    AND ModuleId = @moduleId
                    AND SymbolName = N'GBP SONIA8Y'
                    AND CCY = N'GBP'
                    AND TenorCode = N'8Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'GBP SONIA8Y',
                    @chartOisId,
                    N'GBP',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 4
      AND TenorCode = N'9Y';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 2, TenorCode = 9Y',1;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolDepositRatesChartMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolName = N'GBP SONIA9Y'
                     AND CCY = N'GBP'
                     AND TenorCode = N'9Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'GBP SONIA9Y',
                    @chartOisId,
                    N'GBP',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 4
      AND TenorCode = N'10Y';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 2, TenorCode = 10Y',1;

    IF NOT EXISTS(SELECT 1
                  FROM dbo.RateEngineSymbolDepositRatesChartMap
                  WHERE DataSourceId = @dataSourceId
                    AND ModuleId = @moduleId
                    AND SymbolName = N'GBP SONIA10Y'
                    AND CCY = N'GBP'
                    AND TenorCode = N'10Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'GBP SONIA10Y',
                    @chartOisId,
                    N'GBP',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 4
      AND TenorCode = N'12Y';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 2, TenorCode = 12Y',1;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolDepositRatesChartMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolName = N'GBP SONIA12Y'
                     AND CCY = N'GBP'
                     AND TenorCode = N'12Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'GBP SONIA12Y',
                    @chartOisId,
                    N'GBP',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 4
      AND TenorCode = N'15Y';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 2, TenorCode = 15Y',1;

    IF NOT EXISTS(SELECT 1
                  FROM dbo.RateEngineSymbolDepositRatesChartMap
                  WHERE DataSourceId = @dataSourceId
                    AND ModuleId = @moduleId
                    AND SymbolName = N'GBP SONIA15Y'
                    AND CCY = N'GBP'
                    AND TenorCode = N'15Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'GBP SONIA15Y',
                    @chartOisId,
                    N'GBP',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 4
      AND TenorCode = N'20Y';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 2, TenorCode = 20Y',1;

    IF NOT EXISTS(SELECT 1
                  FROM dbo.RateEngineSymbolDepositRatesChartMap
                  WHERE DataSourceId = @dataSourceId
                    AND ModuleId = @moduleId
                    AND SymbolName = N'GBP SONIA20Y'
                    AND CCY = N'GBP'
                    AND TenorCode = N'20Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'GBP SONIA20Y',
                    @chartOisId,
                    N'GBP',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 4
      AND TenorCode = N'25Y';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 2, TenorCode = 25Y',1;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolDepositRatesChartMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolName = N'GBP SONIA25Y'
                     AND CCY = N'GBP'
                     AND TenorCode = N'25Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'GBP SONIA25Y',
                    @chartOisId,
                    N'GBP',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 4
      AND TenorCode = N'30Y';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 2, TenorCode = 30Y',1;

    IF NOT EXISTS(SELECT 1
                  FROM dbo.RateEngineSymbolDepositRatesChartMap
                  WHERE DataSourceId = @dataSourceId
                    AND ModuleId = @moduleId
                    AND SymbolName = N'GBP SONIA30Y'
                    AND CCY = N'GBP'
                    AND TenorCode = N'30Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'GBP SONIA30Y',
                    @chartOisId,
                    N'GBP',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 4
      AND TenorCode = N'40Y';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 2, TenorCode = 40Y',1;

    IF NOT EXISTS(SELECT 1
                  FROM dbo.RateEngineSymbolDepositRatesChartMap
                  WHERE DataSourceId = @dataSourceId
                    AND ModuleId = @moduleId
                    AND SymbolName = N'GBP SONIA40Y'
                    AND CCY = N'GBP'
                    AND TenorCode = N'40Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'GBP SONIA40Y',
                    @chartOisId,
                    N'GBP',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 4
      AND TenorCode = N'50Y';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 2, TenorCode = 50Y',1;

    IF NOT EXISTS(SELECT 1
                  FROM dbo.RateEngineSymbolDepositRatesChartMap
                  WHERE DataSourceId = @dataSourceId
                    AND ModuleId = @moduleId
                    AND SymbolName = N'GBP SONIA50Y'
                    AND CCY = N'GBP'
                    AND TenorCode = N'50Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'GBP SONIA50Y',
                    @chartOisId,
                    N'GBP',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 4
      AND TenorCode = N'O/N';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 4, TenorCode = O/N',1;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolDepositRatesChartMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolName = N'TRY OISON'
                     AND CCY = N'TRY'
                     AND TenorCode = N'O/N')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'TRY OISON',
                    @chartOisId,
                    N'TRY',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 4
      AND TenorCode = N'1W';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 4, TenorCode = 1W',1;

    IF NOT EXISTS(SELECT 1
                  FROM dbo.RateEngineSymbolDepositRatesChartMap
                  WHERE DataSourceId = @dataSourceId
                    AND ModuleId = @moduleId
                    AND SymbolName = N'TRY OIS1W'
                    AND CCY = N'TRY'
                    AND TenorCode = N'1W')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'TRY OIS1W',
                    @chartOisId,
                    N'TRY',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 4
      AND TenorCode = N'2W';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 4, TenorCode = 2W',1;

    IF NOT EXISTS(SELECT 1
                  FROM dbo.RateEngineSymbolDepositRatesChartMap
                  WHERE DataSourceId = @dataSourceId
                    AND ModuleId = @moduleId
                    AND SymbolName = N'TRY OIS2W'
                    AND CCY = N'TRY'
                    AND TenorCode = N'2W')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'TRY OIS2W',
                    @chartOisId,
                    N'TRY',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 4
      AND TenorCode = N'1M';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 4, TenorCode = 1M',1;

    IF NOT EXISTS(SELECT 1
                  FROM dbo.RateEngineSymbolDepositRatesChartMap
                  WHERE DataSourceId = @dataSourceId
                    AND ModuleId = @moduleId
                    AND SymbolName = N'TRY OIS1M'
                    AND CCY = N'TRY'
                    AND TenorCode = N'1M')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'TRY OIS1M',
                    @chartOisId,
                    N'TRY',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 4
      AND TenorCode = N'2M';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 4, TenorCode = 2M',1;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolDepositRatesChartMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolName = N'TRY OIS2M'
                     AND CCY = N'TRY'
                     AND TenorCode = N'2M')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'TRY OIS2M',
                    @chartOisId,
                    N'TRY',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 4
      AND TenorCode = N'3M';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 4, TenorCode = 3M',1;

    IF NOT EXISTS(SELECT 1
                  FROM dbo.RateEngineSymbolDepositRatesChartMap
                  WHERE DataSourceId = @dataSourceId
                    AND ModuleId = @moduleId
                    AND SymbolName = N'TRY OIS3M'
                    AND CCY = N'TRY'
                    AND TenorCode = N'3M')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'TRY OIS3M',
                    @chartOisId,
                    N'TRY',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 4
      AND TenorCode = N'6M';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 4, TenorCode = 6M',1;

    IF NOT EXISTS(SELECT 1
                  FROM dbo.RateEngineSymbolDepositRatesChartMap
                  WHERE DataSourceId = @dataSourceId
                    AND ModuleId = @moduleId
                    AND SymbolName = N'TRY OIS6M'
                    AND CCY = N'TRY'
                    AND TenorCode = N'6M')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'TRY OIS6M',
                    @chartOisId,
                    N'TRY',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 4
      AND TenorCode = N'9M';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 4, TenorCode = 9M',1;

    IF NOT EXISTS(SELECT 1
                  FROM dbo.RateEngineSymbolDepositRatesChartMap
                  WHERE DataSourceId = @dataSourceId
                    AND ModuleId = @moduleId
                    AND SymbolName = N'TRY OIS9M'
                    AND CCY = N'TRY'
                    AND TenorCode = N'9M')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'TRY OIS9M',
                    @chartOisId,
                    N'TRY',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 4
      AND TenorCode = N'1Y';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 4, TenorCode = 1Y',1;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolDepositRatesChartMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolName = N'TRY OIS1Y'
                     AND CCY = N'TRY'
                     AND TenorCode = N'1Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'TRY OIS1Y',
                    @chartOisId,
                    N'TRY',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 4
      AND TenorCode = N'18M';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 4, TenorCode = 18M',1;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolDepositRatesChartMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolName = N'TRY OIS18M'
                     AND CCY = N'TRY'
                     AND TenorCode = N'18M')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'TRY OIS18M',
                    @chartOisId,
                    N'TRY',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 4
      AND TenorCode = N'2Y';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 4, TenorCode = 2Y',1;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolDepositRatesChartMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolName = N'TRY OIS2Y'
                     AND CCY = N'TRY'
                     AND TenorCode = N'2Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'TRY OIS2Y',
                    @chartOisId,
                    N'TRY',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 4
      AND TenorCode = N'3Y';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 4, TenorCode = 3Y',1;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolDepositRatesChartMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolName = N'TRY OIS3Y'
                     AND CCY = N'TRY'
                     AND TenorCode = N'3Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'TRY OIS3Y',
                    @chartOisId,
                    N'TRY',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 4
      AND TenorCode = N'4Y';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 4, TenorCode = 4Y',1;

    IF NOT EXISTS(SELECT 1
                  FROM dbo.RateEngineSymbolDepositRatesChartMap
                  WHERE DataSourceId = @dataSourceId
                    AND ModuleId = @moduleId
                    AND SymbolName = N'TRY OIS4Y'
                    AND CCY = N'TRY'
                    AND TenorCode = N'4Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'TRY OIS4Y',
                    @chartOisId,
                    N'TRY',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 4
      AND TenorCode = N'5Y';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 4, TenorCode = 5Y',1;

    IF NOT EXISTS(SELECT 1
                  FROM dbo.RateEngineSymbolDepositRatesChartMap
                  WHERE DataSourceId = @dataSourceId
                    AND ModuleId = @moduleId
                    AND SymbolName = N'TRY OIS5Y'
                    AND CCY = N'TRY'
                    AND TenorCode = N'5Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'TRY OIS5Y',
                    @chartOisId,
                    N'TRY',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 4
      AND TenorCode = N'6Y';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 2, TenorCode = 6Y',1;

    IF NOT EXISTS(SELECT 1
                  FROM dbo.RateEngineSymbolDepositRatesChartMap
                  WHERE DataSourceId = @dataSourceId
                    AND ModuleId = @moduleId
                    AND SymbolName = N'TRY OIS6Y'
                    AND CCY = N'TRY'
                    AND TenorCode = N'6Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'TRY OIS6Y',
                    @chartOisId,
                    N'TRY',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 4
      AND TenorCode = N'7Y';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 4, TenorCode = 7Y',1;

    IF NOT EXISTS(SELECT 1
                  FROM dbo.RateEngineSymbolDepositRatesChartMap
                  WHERE DataSourceId = @dataSourceId
                    AND ModuleId = @moduleId
                    AND SymbolName = N'TRY OIS7Y'
                    AND CCY = N'TRY'
                    AND TenorCode = N'7Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'TRY OIS7Y',
                    @chartOisId,
                    N'TRY',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 4
      AND TenorCode = N'8Y';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 4, TenorCode = 8Y',1;

    IF NOT EXISTS(SELECT 1
                  FROM dbo.RateEngineSymbolDepositRatesChartMap
                  WHERE DataSourceId = @dataSourceId
                    AND ModuleId = @moduleId
                    AND SymbolName = N'TRY OIS8Y'
                    AND CCY = N'TRY'
                    AND TenorCode = N'8Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'TRY OIS8Y',
                    @chartOisId,
                    N'TRY',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 4
      AND TenorCode = N'9Y';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 4, TenorCode = 9Y',1;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolDepositRatesChartMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolName = N'TRY OIS9Y'
                     AND CCY = N'TRY'
                     AND TenorCode = N'9Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'TRY OIS9Y',
                    @chartOisId,
                    N'TRY',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 4
      AND TenorCode = N'10Y';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 4, TenorCode = 10Y',1;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolDepositRatesChartMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolName = N'TRY OIS10Y'
                     AND CCY = N'TRY'
                     AND TenorCode = N'10Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'TRY OIS10Y',
                    @chartOisId,
                    N'TRY',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 4
      AND TenorCode = N'O/N';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 4, TenorCode = O/N',1;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolDepositRatesChartMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolName = N'TRY OISZEROON'
                     AND CCY = N'TRY'
                     AND TenorCode = N'O/N')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'TRY OISZEROON',
                    @chartOisZeroId,
                    N'TRY',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 4
      AND TenorCode = N'1W';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 4, TenorCode = 1W',1;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolDepositRatesChartMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolName = N'TRY OISZERO1W'
                     AND CCY = N'TRY'
                     AND TenorCode = N'1W')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'TRY OISZERO1W',
                    @chartOisZeroId,
                    N'TRY',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 4
      AND TenorCode = N'2W';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 4, TenorCode = 2W',1;

    IF NOT EXISTS(SELECT 1
                  FROM dbo.RateEngineSymbolDepositRatesChartMap
                  WHERE DataSourceId = @dataSourceId
                    AND ModuleId = @moduleId
                    AND SymbolName = N'TRY OISZERO2W'
                    AND CCY = N'TRY'
                    AND TenorCode = N'2W')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'TRY OISZERO2W',
                    @chartOisZeroId,
                    N'TRY',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 4
      AND TenorCode = N'1M';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 4, TenorCode = 1M',1;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolDepositRatesChartMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolName = N'TRY OISZERO1M'
                     AND CCY = N'TRY'
                     AND TenorCode = N'1M')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'TRY OISZERO1M',
                    @chartOisZeroId,
                    N'TRY',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 4
      AND TenorCode = N'2M';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 4, TenorCode = 2M',1;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolDepositRatesChartMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolName = N'TRY OISZERO2M'
                     AND CCY = N'TRY'
                     AND TenorCode = N'2M')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'TRY OISZERO2M',
                    @chartOisZeroId,
                    N'TRY',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 4
      AND TenorCode = N'3M';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 4, TenorCode = 3M',1;

    IF NOT EXISTS(SELECT 1
                  FROM dbo.RateEngineSymbolDepositRatesChartMap
                  WHERE DataSourceId = @dataSourceId
                    AND ModuleId = @moduleId
                    AND SymbolName = N'TRY OISZERO3M'
                    AND CCY = N'TRY'
                    AND TenorCode = N'3M')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'TRY OISZERO3M',
                    @chartOisZeroId,
                    N'TRY',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 4
      AND TenorCode = N'6M';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 4, TenorCode = 6M',1;

    IF NOT EXISTS(SELECT 1
                  FROM dbo.RateEngineSymbolDepositRatesChartMap
                  WHERE DataSourceId = @dataSourceId
                    AND ModuleId = @moduleId
                    AND SymbolName = N'TRY OISZERO6M'
                    AND CCY = N'TRY'
                    AND TenorCode = N'6M')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'TRY OISZERO6M',
                    @chartOisZeroId,
                    N'TRY',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 4
      AND TenorCode = N'9M';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 4, TenorCode = 9M',1;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolDepositRatesChartMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolName = N'TRY OISZERO9M'
                     AND CCY = N'TRY'
                     AND TenorCode = N'9M')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'TRY OISZERO9M',
                    @chartOisZeroId,
                    N'TRY',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 4
      AND TenorCode = N'1Y';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 4, TenorCode = 1Y',1;

    IF NOT EXISTS(SELECT 1
                  FROM dbo.RateEngineSymbolDepositRatesChartMap
                  WHERE DataSourceId = @dataSourceId
                    AND ModuleId = @moduleId
                    AND SymbolName = N'TRY OISZERO1Y'
                    AND CCY = N'TRY'
                    AND TenorCode = N'1Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'TRY OISZERO1Y',
                    @chartOisZeroId,
                    N'TRY',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 4
      AND TenorCode = N'18M';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 4, TenorCode = 18M',1;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolDepositRatesChartMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolName = N'TRY OISZERO18M'
                     AND CCY = N'TRY'
                     AND TenorCode = N'18M')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'TRY OISZERO18M',
                    @chartOisZeroId,
                    N'TRY',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 4
      AND TenorCode = N'2Y';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 4, TenorCode = 2Y',1;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolDepositRatesChartMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolName = N'TRY OISZERO2Y'
                     AND CCY = N'TRY'
                     AND TenorCode = N'2Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'TRY OISZERO2Y',
                    @chartOisZeroId,
                    N'TRY',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 4
      AND TenorCode = N'3Y';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 4, TenorCode = 3Y',1;

    IF NOT EXISTS(SELECT 1
                  FROM dbo.RateEngineSymbolDepositRatesChartMap
                  WHERE DataSourceId = @dataSourceId
                    AND ModuleId = @moduleId
                    AND SymbolName = N'TRY OISZERO3Y'
                    AND CCY = N'TRY'
                    AND TenorCode = N'3Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'TRY OISZERO3Y',
                    @chartOisZeroId,
                    N'TRY',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 4
      AND TenorCode = N'4Y';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 4, TenorCode = 4Y',1;

    IF NOT EXISTS(SELECT 1
                  FROM dbo.RateEngineSymbolDepositRatesChartMap
                  WHERE DataSourceId = @dataSourceId
                    AND ModuleId = @moduleId
                    AND SymbolName = N'TRY OISZERO4Y'
                    AND CCY = N'TRY'
                    AND TenorCode = N'4Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'TRY OISZERO4Y',
                    @chartOisZeroId,
                    N'TRY',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 4
      AND TenorCode = N'5Y';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 4, TenorCode = 5Y',1;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolDepositRatesChartMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolName = N'TRY OISZERO5Y'
                     AND CCY = N'TRY'
                     AND TenorCode = N'5Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'TRY OISZERO5Y',
                    @chartOisZeroId,
                    N'TRY',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 4
      AND TenorCode = N'6Y';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 4, TenorCode = 6Y',1;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolDepositRatesChartMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolName = N'TRY OISZERO6Y'
                     AND CCY = N'TRY'
                     AND TenorCode = N'6Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'TRY OISZERO6Y',
                    @chartOisZeroId,
                    N'TRY',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 4
      AND TenorCode = N'7Y';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 4, TenorCode = 7Y',1;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolDepositRatesChartMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolName = N'TRY OISZERO7Y'
                     AND CCY = N'TRY'
                     AND TenorCode = N'7Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'TRY OISZERO7Y',
                    @chartOisZeroId,
                    N'TRY',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 4
      AND TenorCode = N'8Y';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 4, TenorCode = 8Y',1;

    IF NOT EXISTS(SELECT 1
                  FROM dbo.RateEngineSymbolDepositRatesChartMap
                  WHERE DataSourceId = @dataSourceId
                    AND ModuleId = @moduleId
                    AND SymbolName = N'TRY OISZERO8Y'
                    AND CCY = N'TRY'
                    AND TenorCode = N'8Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'TRY OISZERO8Y',
                    @chartOisZeroId,
                    N'TRY',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 4
      AND TenorCode = N'9Y';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 4, TenorCode = 9Y',1;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolDepositRatesChartMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolName = N'TRY OISZERO9Y'
                     AND CCY = N'TRY'
                     AND TenorCode = N'9Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'TRY OISZERO9Y',
                    @chartOisZeroId,
                    N'TRY',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 4
      AND TenorCode = N'10Y';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 4, TenorCode = 10Y',1;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolDepositRatesChartMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolName = N'TRY OISZERO10Y'
                     AND CCY = N'TRY'
                     AND TenorCode = N'10Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'TRY OISZERO10Y',
                    @chartOisZeroId,
                    N'TRY',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 4
      AND TenorCode = N'11Y';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 4, TenorCode = 11Y',1;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolDepositRatesChartMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolName = N'TRY OISZERO11Y'
                     AND CCY = N'TRY'
                     AND TenorCode = N'11Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'TRY OISZERO11Y',
                    @chartOisZeroId,
                    N'TRY',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 4
      AND TenorCode = N'12Y';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 4, TenorCode = 12Y',1;

    IF NOT EXISTS(SELECT 1
                  FROM dbo.RateEngineSymbolDepositRatesChartMap
                  WHERE DataSourceId = @dataSourceId
                    AND ModuleId = @moduleId
                    AND SymbolName = N'TRY OISZERO12Y'
                    AND CCY = N'TRY'
                    AND TenorCode = N'12Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'TRY OISZERO12Y',
                    @chartOisZeroId,
                    N'TRY',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 4
      AND TenorCode = N'13Y';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 4, TenorCode = 13Y',1;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolDepositRatesChartMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolName = N'TRY OISZERO13Y'
                     AND CCY = N'TRY'
                     AND TenorCode = N'13Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'TRY OISZERO13Y',
                    @chartOisZeroId,
                    N'TRY',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 4
      AND TenorCode = N'14Y';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 4, TenorCode = 14Y',1;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolDepositRatesChartMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolName = N'TRY OISZERO14Y'
                     AND CCY = N'TRY'
                     AND TenorCode = N'14Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'TRY OISZERO14Y',
                    @chartOisZeroId,
                    N'TRY',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 4
      AND TenorCode = N'15Y';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 4, TenorCode = 15Y',1;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolDepositRatesChartMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolName = N'TRY OISZERO15Y'
                     AND CCY = N'TRY'
                     AND TenorCode = N'15Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'TRY OISZERO15Y',
                    @chartOisZeroId,
                    N'TRY',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 2
      AND TenorCode = N'O/N';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 2, TenorCode = O/N',1;

    IF NOT EXISTS(SELECT 1
                  FROM dbo.RateEngineSymbolDepositRatesChartMap
                  WHERE DataSourceId = @dataSourceId
                    AND ModuleId = @moduleId
                    AND SymbolName = N'USD SOFRZEROON'
                    AND CCY = N'USD'
                    AND TenorCode = N'O/N')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'USD SOFRZEROON',
                    @chartOisZeroId,
                    N'USD',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 2
      AND TenorCode = N'1W';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 2, TenorCode = 1W',1;

    IF NOT EXISTS(SELECT 1
                  FROM dbo.RateEngineSymbolDepositRatesChartMap
                  WHERE DataSourceId = @dataSourceId
                    AND ModuleId = @moduleId
                    AND SymbolName = N'USD SOFRZERO1W'
                    AND CCY = N'USD'
                    AND TenorCode = N'1W')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'USD SOFRZERO1W',
                    @chartOisZeroId,
                    N'USD',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 2
      AND TenorCode = N'2W';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 2, TenorCode = 2W',1;

    IF NOT EXISTS(SELECT 1
                  FROM dbo.RateEngineSymbolDepositRatesChartMap
                  WHERE DataSourceId = @dataSourceId
                    AND ModuleId = @moduleId
                    AND SymbolName = N'USD SOFRZERO2W'
                    AND CCY = N'USD'
                    AND TenorCode = N'2W')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'USD SOFRZERO2W',
                    @chartOisZeroId,
                    N'USD',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 2
      AND TenorCode = N'1M';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 2, TenorCode = 1M',1;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolDepositRatesChartMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolName = N'USD SOFRZERO1M'
                     AND CCY = N'USD'
                     AND TenorCode = N'1M')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'USD SOFRZERO1M',
                    @chartOisZeroId,
                    N'USD',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 2
      AND TenorCode = N'2M';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 2, TenorCode = 2M',1;

    IF NOT EXISTS(SELECT 1
                  FROM dbo.RateEngineSymbolDepositRatesChartMap
                  WHERE DataSourceId = @dataSourceId
                    AND ModuleId = @moduleId
                    AND SymbolName = N'USD SOFRZERO2M'
                    AND CCY = N'USD'
                    AND TenorCode = N'2M')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'USD SOFRZERO2M',
                    @chartOisZeroId,
                    N'USD',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 2
      AND TenorCode = N'3M';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 2, TenorCode = 3M',1;

    IF NOT EXISTS(SELECT 1
                  FROM dbo.RateEngineSymbolDepositRatesChartMap
                  WHERE DataSourceId = @dataSourceId
                    AND ModuleId = @moduleId
                    AND SymbolName = N'USD SOFRZERO3M'
                    AND CCY = N'USD'
                    AND TenorCode = N'3M')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'USD SOFRZERO3M',
                    @chartOisZeroId,
                    N'USD',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 2
      AND TenorCode = N'6M';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 2, TenorCode = 6M',1;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolDepositRatesChartMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolName = N'USD SOFRZERO6M'
                     AND CCY = N'USD'
                     AND TenorCode = N'6M')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'USD SOFRZERO6M',
                    @chartOisZeroId,
                    N'USD',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 2
      AND TenorCode = N'9M';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 2, TenorCode = 9M',1;

    IF NOT EXISTS(SELECT 1
                  FROM dbo.RateEngineSymbolDepositRatesChartMap
                  WHERE DataSourceId = @dataSourceId
                    AND ModuleId = @moduleId
                    AND SymbolName = N'USD SOFRZERO9M'
                    AND CCY = N'USD'
                    AND TenorCode = N'9M')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'USD SOFRZERO9M',
                    @chartOisZeroId,
                    N'USD',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 2
      AND TenorCode = N'12M';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 2, TenorCode = 12M',1;

    IF NOT EXISTS(SELECT 1
                  FROM dbo.RateEngineSymbolDepositRatesChartMap
                  WHERE DataSourceId = @dataSourceId
                    AND ModuleId = @moduleId
                    AND SymbolName = N'USD SOFRZERO12M'
                    AND CCY = N'USD'
                    AND TenorCode = N'12M')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'USD SOFRZERO12M',
                    @chartOisZeroId,
                    N'USD',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 2
      AND TenorCode = N'18M';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 2, TenorCode = 18M',1;

    IF NOT EXISTS(SELECT 1
                  FROM dbo.RateEngineSymbolDepositRatesChartMap
                  WHERE DataSourceId = @dataSourceId
                    AND ModuleId = @moduleId
                    AND SymbolName = N'USD SOFRZERO18M'
                    AND CCY = N'USD'
                    AND TenorCode = N'18M')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'USD SOFRZERO18M',
                    @chartOisZeroId,
                    N'USD',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 2
      AND TenorCode = N'2Y';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 2, TenorCode = 2Y',1;

    IF NOT EXISTS(SELECT 1
                  FROM dbo.RateEngineSymbolDepositRatesChartMap
                  WHERE DataSourceId = @dataSourceId
                    AND ModuleId = @moduleId
                    AND SymbolName = N'USD SOFRZERO2Y'
                    AND CCY = N'USD'
                    AND TenorCode = N'2Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'USD SOFRZERO2Y',
                    @chartOisZeroId,
                    N'USD',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 2
      AND TenorCode = N'3Y';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 2, TenorCode = 3Y',1;

    IF NOT EXISTS(SELECT 1
                  FROM dbo.RateEngineSymbolDepositRatesChartMap
                  WHERE DataSourceId = @dataSourceId
                    AND ModuleId = @moduleId
                    AND SymbolName = N'USD SOFRZERO3Y'
                    AND CCY = N'USD'
                    AND TenorCode = N'3Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'USD SOFRZERO3Y',
                    @chartOisZeroId,
                    N'USD',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 2
      AND TenorCode = N'4Y';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 2, TenorCode = 4Y',1;

    IF NOT EXISTS(SELECT 1
                  FROM dbo.RateEngineSymbolDepositRatesChartMap
                  WHERE DataSourceId = @dataSourceId
                    AND ModuleId = @moduleId
                    AND SymbolName = N'USD SOFRZERO4Y'
                    AND CCY = N'USD'
                    AND TenorCode = N'4Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'USD SOFRZERO4Y',
                    @chartOisZeroId,
                    N'USD',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 2
      AND TenorCode = N'5Y';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 2, TenorCode = 5Y',1;

    IF NOT EXISTS(SELECT 1
                  FROM dbo.RateEngineSymbolDepositRatesChartMap
                  WHERE DataSourceId = @dataSourceId
                    AND ModuleId = @moduleId
                    AND SymbolName = N'USD SOFRZERO5Y'
                    AND CCY = N'USD'
                    AND TenorCode = N'5Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'USD SOFRZERO5Y',
                    @chartOisZeroId,
                    N'USD',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 2
      AND TenorCode = N'6Y';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 2, TenorCode = 6Y',1;

    IF NOT EXISTS(SELECT 1
                  FROM dbo.RateEngineSymbolDepositRatesChartMap
                  WHERE DataSourceId = @dataSourceId
                    AND ModuleId = @moduleId
                    AND SymbolName = N'USD SOFRZERO6Y'
                    AND CCY = N'USD'
                    AND TenorCode = N'6Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'USD SOFRZERO6Y',
                    @chartOisZeroId,
                    N'USD',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 2
      AND TenorCode = N'7Y';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 2, TenorCode = 7Y',1;

    IF NOT EXISTS(SELECT 1
                  FROM dbo.RateEngineSymbolDepositRatesChartMap
                  WHERE DataSourceId = @dataSourceId
                    AND ModuleId = @moduleId
                    AND SymbolName = N'USD SOFRZERO7Y'
                    AND CCY = N'USD'
                    AND TenorCode = N'7Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'USD SOFRZERO7Y',
                    @chartOisZeroId,
                    N'USD',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 2
      AND TenorCode = N'8Y';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 2, TenorCode = 8Y',1;

    IF NOT EXISTS(SELECT 1
                  FROM dbo.RateEngineSymbolDepositRatesChartMap
                  WHERE DataSourceId = @dataSourceId
                    AND ModuleId = @moduleId
                    AND SymbolName = N'USD SOFRZERO8Y'
                    AND CCY = N'USD'
                    AND TenorCode = N'8Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'USD SOFRZERO8Y',
                    @chartOisZeroId,
                    N'USD',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 2
      AND TenorCode = N'9Y';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 2, TenorCode = 9Y',1;

    IF NOT EXISTS(SELECT 1
                  FROM dbo.RateEngineSymbolDepositRatesChartMap
                  WHERE DataSourceId = @dataSourceId
                    AND ModuleId = @moduleId
                    AND SymbolName = N'USD SOFRZERO9Y'
                    AND CCY = N'USD'
                    AND TenorCode = N'9Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'USD SOFRZERO9Y',
                    @chartOisZeroId,
                    N'USD',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 2
      AND TenorCode = N'10Y';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 2, TenorCode = 10Y',1;

    IF NOT EXISTS(SELECT 1
                  FROM dbo.RateEngineSymbolDepositRatesChartMap
                  WHERE DataSourceId = @dataSourceId
                    AND ModuleId = @moduleId
                    AND SymbolName = N'USD SOFRZERO10Y'
                    AND CCY = N'USD'
                    AND TenorCode = N'10Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'USD SOFRZERO10Y',
                    @chartOisZeroId,
                    N'USD',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 2
      AND TenorCode = N'11Y';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 2, TenorCode = 11Y',1;

    IF NOT EXISTS(SELECT 1
                  FROM dbo.RateEngineSymbolDepositRatesChartMap
                  WHERE DataSourceId = @dataSourceId
                    AND ModuleId = @moduleId
                    AND SymbolName = N'USD SOFRZERO11Y'
                    AND CCY = N'USD'
                    AND TenorCode = N'11Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'USD SOFRZERO11Y',
                    @chartOisZeroId,
                    N'USD',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 2
      AND TenorCode = N'12Y';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 2, TenorCode = 12Y',1;

    IF NOT EXISTS(SELECT 1
                  FROM dbo.RateEngineSymbolDepositRatesChartMap
                  WHERE DataSourceId = @dataSourceId
                    AND ModuleId = @moduleId
                    AND SymbolName = N'USD SOFRZERO12Y'
                    AND CCY = N'USD'
                    AND TenorCode = N'12Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'USD SOFRZERO12Y',
                    @chartOisZeroId,
                    N'USD',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 2
      AND TenorCode = N'13Y';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 2, TenorCode = 13Y',1;

    IF NOT EXISTS(SELECT 1
                  FROM dbo.RateEngineSymbolDepositRatesChartMap
                  WHERE DataSourceId = @dataSourceId
                    AND ModuleId = @moduleId
                    AND SymbolName = N'USD SOFRZERO13Y'
                    AND CCY = N'USD'
                    AND TenorCode = N'13Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'USD SOFRZERO13Y',
                    @chartOisZeroId,
                    N'USD',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 2
      AND TenorCode = N'14Y';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 2, TenorCode = 14Y',1;

    IF NOT EXISTS(SELECT 1
                  FROM dbo.RateEngineSymbolDepositRatesChartMap
                  WHERE DataSourceId = @dataSourceId
                    AND ModuleId = @moduleId
                    AND SymbolName = N'USD SOFRZERO14Y'
                    AND CCY = N'USD'
                    AND TenorCode = N'14Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'USD SOFRZERO14Y',
                    @chartOisZeroId,
                    N'USD',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 2
      AND TenorCode = N'15Y';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 2, TenorCode = 15Y',1;

    IF NOT EXISTS(SELECT 1
                  FROM dbo.RateEngineSymbolDepositRatesChartMap
                  WHERE DataSourceId = @dataSourceId
                    AND ModuleId = @moduleId
                    AND SymbolName = N'USD SOFRZERO15Y'
                    AND CCY = N'USD'
                    AND TenorCode = N'15Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'USD SOFRZERO15Y',
                    @chartOisZeroId,
                    N'USD',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 2
      AND TenorCode = N'O/N';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 2, TenorCode = O/N',1;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolDepositRatesChartMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolName = N'EUR ESTRZEROON'
                     AND CCY = N'EUR'
                     AND TenorCode = N'O/N')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'EUR ESTRZEROON',
                    @chartOisZeroId,
                    N'EUR',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 2
      AND TenorCode = N'1W';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 2, TenorCode = 1W',1;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolDepositRatesChartMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolName = N'EUR ZERO1W'
                     AND CCY = N'EUR'
                     AND TenorCode = N'1W')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'EUR ZERO1W',
                    @chartOisZeroId,
                    N'EUR',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 2
      AND TenorCode = N'2W';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 2, TenorCode = 2W',1;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolDepositRatesChartMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolName = N'EUR ZERO2W'
                     AND CCY = N'EUR'
                     AND TenorCode = N'2W')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'EUR ZERO2W',
                    @chartOisZeroId,
                    N'EUR',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 2
      AND TenorCode = N'1M';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 2, TenorCode = 1M',1;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolDepositRatesChartMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolName = N'EUR ZERO1M'
                     AND CCY = N'EUR'
                     AND TenorCode = N'1M')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'EUR ZERO1M',
                    @chartOisZeroId,
                    N'EUR',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 2
      AND TenorCode = N'2M';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 2, TenorCode = 2M',1;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolDepositRatesChartMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolName = N'EUR ZERO2M'
                     AND CCY = N'EUR'
                     AND TenorCode = N'2M')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'EUR ZERO2M',
                    @chartOisZeroId,
                    N'EUR',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 2
      AND TenorCode = N'3M';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 2, TenorCode = 3M',1;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolDepositRatesChartMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolName = N'EUR ZERO3M'
                     AND CCY = N'EUR'
                     AND TenorCode = N'3M')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'EUR ZERO3M',
                    @chartOisZeroId,
                    N'EUR',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 2
      AND TenorCode = N'6M';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 2, TenorCode = 6M',1;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolDepositRatesChartMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolName = N'EUR ZERO6M'
                     AND CCY = N'EUR'
                     AND TenorCode = N'6M')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'EUR ZERO6M',
                    @chartOisZeroId,
                    N'EUR',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 2
      AND TenorCode = N'9M';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 2, TenorCode = 9M',1;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolDepositRatesChartMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolName = N'EUR ZERO9M'
                     AND CCY = N'EUR'
                     AND TenorCode = N'9M')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'EUR ZERO9M',
                    @chartOisZeroId,
                    N'EUR',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 2
      AND TenorCode = N'1Y';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 2, TenorCode = 1Y',1;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolDepositRatesChartMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolName = N'EUR ZERO1Y'
                     AND CCY = N'EUR'
                     AND TenorCode = N'1Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'EUR ZERO1Y',
                    @chartOisZeroId,
                    N'EUR',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 2
      AND TenorCode = N'18M';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 2, TenorCode = 18M',1;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolDepositRatesChartMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolName = N'EUR ZERO18M'
                     AND CCY = N'EUR'
                     AND TenorCode = N'18M')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'EUR ZERO18M',
                    @chartOisZeroId,
                    N'EUR',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 2
      AND TenorCode = N'2Y';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 2, TenorCode = 2Y',1;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolDepositRatesChartMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolName = N'EUR ZERO2Y'
                     AND CCY = N'EUR'
                     AND TenorCode = N'2Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'EUR ZERO2Y',
                    @chartOisZeroId,
                    N'EUR',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 2
      AND TenorCode = N'3Y';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 2, TenorCode = 3Y',1;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolDepositRatesChartMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolName = N'EUR ZERO3Y'
                     AND CCY = N'EUR'
                     AND TenorCode = N'3Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'EUR ZERO3Y',
                    @chartOisZeroId,
                    N'EUR',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 2
      AND TenorCode = N'4Y';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 2, TenorCode = 4Y',1;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolDepositRatesChartMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolName = N'EUR ZERO4Y'
                     AND CCY = N'EUR'
                     AND TenorCode = N'4Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'EUR ZERO4Y',
                    @chartOisZeroId,
                    N'EUR',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 2
      AND TenorCode = N'5Y';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 2, TenorCode = 5Y',1;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolDepositRatesChartMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolName = N'EUR ZERO5Y'
                     AND CCY = N'EUR'
                     AND TenorCode = N'5Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'EUR ZERO5Y',
                    @chartOisZeroId,
                    N'EUR',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 2
      AND TenorCode = N'6Y';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 2, TenorCode = 6Y',1;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolDepositRatesChartMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolName = N'EUR ZERO6Y'
                     AND CCY = N'EUR'
                     AND TenorCode = N'6Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'EUR ZERO6Y',
                    @chartOisZeroId,
                    N'EUR',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 2
      AND TenorCode = N'7Y';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 2, TenorCode = 7Y',1;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolDepositRatesChartMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolName = N'EUR ZERO7Y'
                     AND CCY = N'EUR'
                     AND TenorCode = N'7Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'EUR ZERO7Y',
                    @chartOisZeroId,
                    N'EUR',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 2
      AND TenorCode = N'8Y';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 2, TenorCode = 8Y',1;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolDepositRatesChartMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolName = N'EUR ZERO8Y'
                     AND CCY = N'EUR'
                     AND TenorCode = N'8Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'EUR ZERO8Y',
                    @chartOisZeroId,
                    N'EUR',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 2
      AND TenorCode = N'9Y';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 2, TenorCode = 9Y',1;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolDepositRatesChartMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolName = N'EUR ZERO9Y'
                     AND CCY = N'EUR'
                     AND TenorCode = N'9Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'EUR ZERO9Y',
                    @chartOisZeroId,
                    N'EUR',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 2
      AND TenorCode = N'10Y';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 2, TenorCode = 10Y',1;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolDepositRatesChartMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolName = N'EUR ZERO10Y'
                     AND CCY = N'EUR'
                     AND TenorCode = N'10Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'EUR ZERO10Y',
                    @chartOisZeroId,
                    N'EUR',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 2
      AND TenorCode = N'11Y';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 2, TenorCode = 11Y',1;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolDepositRatesChartMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolName = N'EUR ZERO11Y'
                     AND CCY = N'EUR'
                     AND TenorCode = N'11Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId,
             ModuleId,
             SymbolName,
             ChartId,
             CCY,
             TenorId,
             TenorDays,
             TenorCode,
             IsSynthetic,
             StateId,
             StateMaker,
             StateDate)
            VALUES (@dataSourceId,
                    @moduleId,
                    N'EUR ZERO11Y',
                    @chartOisZeroId,
                    N'EUR',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0,
                    @stateId,
                    @stateMaker,
                    @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 2
      AND TenorCode = N'12Y';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 2, TenorCode = 12Y',1;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolDepositRatesChartMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolName = N'EUR ZERO12Y'
                     AND CCY = N'EUR'
                     AND TenorCode = N'12Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId, ModuleId, SymbolName, ChartId, CCY,
             TenorId, TenorDays, TenorCode, IsSynthetic, StateId, StateMaker, StateDate)
            VALUES (@dataSourceId, @moduleId, N'EUR ZERO12Y', @chartOisZeroId, N'EUR',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0, @stateId, @stateMaker, @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 2
      AND TenorCode = N'13Y';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 2, TenorCode = 13Y',1;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolDepositRatesChartMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolName = N'EUR ZERO13Y'
                     AND CCY = N'EUR'
                     AND TenorCode = N'13Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId, ModuleId, SymbolName, ChartId, CCY,
             TenorId, TenorDays, TenorCode, IsSynthetic, StateId, StateMaker, StateDate)
            VALUES (@dataSourceId, @moduleId, N'EUR ZERO13Y', @chartOisZeroId, N'EUR',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0, @stateId, @stateMaker, @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 2
      AND TenorCode = N'14Y';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 2, TenorCode = 14Y',1;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolDepositRatesChartMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolName = N'EUR ZERO14Y'
                     AND CCY = N'EUR'
                     AND TenorCode = N'14Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId, ModuleId, SymbolName, ChartId, CCY,
             TenorId, TenorDays, TenorCode, IsSynthetic, StateId, StateMaker, StateDate)
            VALUES (@dataSourceId, @moduleId, N'EUR ZERO14Y', @chartOisZeroId, N'EUR',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0, @stateId, @stateMaker, @stateDate);
        END;

    delete from @pointRowTemp

    INSERT INTO @pointRowTemp (TenorId, TenorDays, TenorCode, SetNo)
    SELECT *
    FROM @pointTemp
    WHERE SetNo = 2
      AND TenorCode = N'15Y';

    if not exists (select 1 from @pointRowTemp)
        THROW 51000,'Point Not Found => Set No 2, TenorCode = 15Y',1;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.RateEngineSymbolDepositRatesChartMap
                   WHERE DataSourceId = @dataSourceId
                     AND ModuleId = @moduleId
                     AND SymbolName = N'EUR ZERO15Y'
                     AND CCY = N'EUR'
                     AND TenorCode = N'15Y')
        BEGIN
            INSERT INTO dbo.RateEngineSymbolDepositRatesChartMap
            (DataSourceId, ModuleId, SymbolName, ChartId, CCY,
             TenorId, TenorDays, TenorCode, IsSynthetic, StateId, StateMaker, StateDate)
            VALUES (@dataSourceId, @moduleId, N'EUR ZERO15Y', @chartOisZeroId, N'EUR',
                    (SELECT TenorId FROM @pointRowTemp),
                    (SELECT TenorDays FROM @pointRowTemp),
                    (SELECT TenorCode FROM @pointRowTemp),
                    0, @stateId, @stateMaker, @stateDate);
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

