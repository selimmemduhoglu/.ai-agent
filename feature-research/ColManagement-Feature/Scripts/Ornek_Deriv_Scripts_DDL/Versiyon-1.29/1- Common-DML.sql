---Check Database Name
use NetTrexCommon
GO

--Deriv Flow Set Id 5 olarak verilecek
DECLARE @flowSetId int = 5,
@errorMsg NVARCHAR(200);

--#region FLOW SET
 IF EXISTS (SELECT 1 
                        FROM sys.objects 
                        WHERE object_id = OBJECT_ID(N'[dbo].[FlowSet]') AND type in (N'U'))
BEGIN
    IF EXISTS (SELECT 1 FROM FlowSet WHERE Name <> N'Flow Set DerivSwp' and Id = @flowSetId)
    BEGIN
        SET @errorMsg = 'Flow Set DerivSwp Id must be ' + CAST(@flowSetId AS NVARCHAR) + '. Please check Flow Set definition';
        throw 500001, @errorMsg, 1;
    END    

    IF NOT EXISTS (SELECT 1 FROM FlowSet WHERE Name = N'Flow Set DerivSwp' and Id = @flowSetId)
    BEGIN
        INSERT INTO [FlowSet]
            ([Id]
            ,[Name]
            ,[Description]
            ,[StateId]
            ,[StateMaker]
            ,[StateDate]
            ,[CreatedBy]
            ,[CreatedDate]
            ,[PreviousStateId]
            ,[PreviousStateMaker]
            ,[PreviousStateDate]
            ,[FlowId]) 
        VALUES 
            (@flowSetId, N'Flow Set DerivSwp',N'Flow Set DerivSwp', 18, N'System', GETDATE(),N'System', GETDATE(), NULL, NULL, NULL, 0);
    END;
END;
--#endregion

--#region FLOW REQUEST MAP
IF NOT EXISTS (SELECT 1 FROM FlowRequestMap WHERE FlowNamespace = N'DvTransactionRequest' and FlowSetId = @flowSetId)
BEGIN
    INSERT INTO [dbo].[FlowRequestMap]
           ([FlowNamespace]
           ,[FlowSetId]
           ,[StateId]
           ,[StateMaker]
           ,[StateDate]
           ,[CreatedBy]
           ,[CreatedDate]
           ,[PreviousStateId]
           ,[PreviousStateMaker]
           ,[PreviousStateDate]
           ,[FlowId])
    VALUES (N'DvTransactionRequest', @flowSetId, 18, N'System', GETDATE(),N'System', GETDATE(), NULL, NULL, NULL, 0 );
END;
--#endregion


--#region DERIVSWP FLOW TRANSACTION Data
IF NOT EXISTS (SELECT 1 FROM FlowTransition WHERE FlowSetId = @flowSetId)
BEGIN
    INSERT INTO [dbo].[FlowTransition]
               ([FlowSetId]
               ,[FromStateId]
               ,[ActionId]
               ,[ValidationDynamicRule1]
               ,[ValidationDynamicRule2]
               ,[ValidationDynamicRule3]
               ,[ValidationDynamicRule4]
               ,[ValidationDynamicRule5]
               ,[ValidationDynamicRule6]
               ,[ValidationDynamicRule7]
               ,[ValidationDynamicRule8]
               ,[ValidationDynamicRule9]
               ,[ValidationDynamicRule10]
               ,[ToStateId]
               ,[RunPostTransaction])
    VALUES
        (@flowSetId, 0,    2,  3,    NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1136, 1),
        (@flowSetId, 1136, 16, 4,    7,    NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 2352, 1),
        (@flowSetId, 1136, 32, 4,    NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1680, 1),
        (@flowSetId, 1136, 4,  4,    7,    NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 2352, 1),
        (@flowSetId, 1680, 16, 3,    7,    NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1136, 1),
        (@flowSetId, 1680, 8,  3,    7,    NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 22,   1),
        (@flowSetId, 1680, 4,  3,    7,    NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1136, 1),
        (@flowSetId, 2352, 16, 4,    7,    NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 18,   1),
        (@flowSetId, 2352, 32, 4,    NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 2480, 1),
        (@flowSetId, 2480, 16, 4,    7,    NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 2352, 1),
        (@flowSetId, 2480, 32, 4,    NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1680, 1),
        (@flowSetId, 2480, 4,  4,    NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 2352, 1),
        (@flowSetId, 18,   8,  4,    NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1428, 1),
        (@flowSetId, 20,   16, 3,    7,    NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 22,   1),
        (@flowSetId, 20,   32, 3,    NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 18,   1),
        (@flowSetId, 1428, 16, 4,    7,    NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 20,   1),
        (@flowSetId, 1428, 32, 4,    7,    NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 18,   1),
        (@flowSetId, 18,   4,  NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 2352, 1);
END

--#endregion