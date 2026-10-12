---Check Database Name
use NetTrexDerivSWP

declare
    @oisChartId int = 0,
    @point0N int = 1,
    @pointForeign1M int = 30,
    @pointForeign3M int = 90,
    @pointForeign6M int = 180,
    @pointForeign12M int = 360,
    @pointLocal1M int = 31,
    @pointLocal3M int = 92,
    @pointLocal6M int = 183,
    @pointLocal12M int = 365;
select * from dbo.Point
declare @tempForeignPointTable table
                               (
                                   Id   int,
                                   Days int
                               );
declare @tempLocalPointTable table
                             (
                                 Id   int,
                                 Days int
                             );

insert into @tempForeignPointTable(Id, Days)
select Id, Days
from dbo.Point
where SetNo = 2
insert into @tempLocalPointTable(Id, Days)
select Id, Days
from dbo.Point
where SetNo = 4

select top 1 @oisChartId = Id
from dbo.Chart
where Code = N'OIS';

truncate table dbo.floatingRateType
INSERT INTO dbo.FloatingRateType (Id, Code, Name, Description, IsEnabled, Currency, PointId, ChartId)
VALUES (1, N'USD SOFRON', N'USD SOFRON', N'SOFR ON Rate', 1, N'USD', (select top 1 Id from @tempForeignPointTable where Days=@point0N), @oisChartId),
       (2, N'USD SOFR1M', N'USD SOFR1M', N'SOFR 1M Rate', 1, N'USD', (select top 1 Id from @tempForeignPointTable where Days=@pointForeign1M), @oisChartId),
       (3, N'USD SOFR3M', N'USD SOFR3M', N'SOFR 3M Rate', 1, N'USD', (select top 1 Id from @tempForeignPointTable where Days=@pointForeign3M), @oisChartId),
       (4, N'USD SOFR6M', N'USD SOFR6M', N'SOFR 6M Rate', 1, N'USD', (select top 1 Id from @tempForeignPointTable where Days=@pointForeign6M), @oisChartId),
       (5, N'USD SOFR12M', N'USD SOFR12M', N'SOFR 12M Rate', 1, N'USD', (select top 1 Id from @tempForeignPointTable where Days=@pointForeign12M), @oisChartId),
       (6, N'TRY TLREFON', N'TRY TLREFON', N'TLREF ON Rate', 1, N'TRY', (select top 1 Id from @tempLocalPointTable where Days=@point0N), @oisChartId),
       (7, N'TRY TLREF1M', N'TRY TLREF1M', N'TLREF 1M Rate', 1, N'TRY', (select top 1 Id from @tempLocalPointTable where Days=@pointLocal1M), @oisChartId),
       (8, N'TRY TLREF3M', N'TRY TLREF3M', N'TLREF 3M Rate', 1, N'TRY', (select top 1 Id from @tempLocalPointTable where Days=@pointLocal3M), @oisChartId),
       (9, N'TRY TLREF6M', N'TRY TLREF6M', N'TLREF 6M Rate', 1, N'TRY', (select top 1 Id from @tempLocalPointTable where Days=@pointLocal6M), @oisChartId),
       (10, N'TRY TLREF12M', N'TRY TLREF12M', N'TLREF 12M Rate', 1, N'TRY', (select top 1 Id from @tempLocalPointTable where Days=@pointLocal12M), @oisChartId),
       (11, N'EUR ESTRON', N'EUR ESTRON', N'ESTR ON Rate', 1, N'EUR', (select top 1 Id from @tempForeignPointTable where Days=@point0N), @oisChartId),
       (12, N'EUR ESTR1M', N'EUR ESTR1M', N'ESTR 1M Rate', 1, N'EUR', (select top 1 Id from @tempForeignPointTable where Days=@pointForeign1M), @oisChartId),
       (13, N'EUR ESTR3M', N'EUR ESTR3M', N'ESTR 3M Rate', 1, N'EUR', (select top 1 Id from @tempForeignPointTable where Days=@pointForeign3M), @oisChartId),
       (14, N'EUR ESTR6M', N'EUR ESTR6M', N'ESTR 6M Rate', 1, N'EUR', (select top 1 Id from @tempForeignPointTable where Days=@pointForeign6M), @oisChartId),
       (15, N'EUR ESTR12M', N'EUR ESTR12M', N'ESTR 12M Rate', 1, N'EUR', (select top 1 Id from @tempForeignPointTable where Days=@pointForeign12M), @oisChartId);