use [NetTrexAcc]
GO
SET XACT_ABORT ON;

BEGIN TRANSACTION;

BEGIN TRY
    DECLARE
        @tempTable TABLE
                   (
                       Id INT
                   );
    DECLARE
        @StateId INT=18,
        @stateDate datetime = getdate(),
        @stateMaker nvarchar(80) = N'SYSTEM';

    DECLARE
        @lastAccEngineDynamicRuleId INT = 0,
        @accEngineDynamicRuleColumnTypeId INT = 1,
        @lastAccEngineAccountRuleId INT = 0,
        @accEngineAccountRuleColumnTypeId INT = 2,
        @lastAccEngineComponentId INT = 0,
        @accEngineComponentColumnTypeId INT = 3,
        @lastAccEngineGroupId INT = 0,
        @accEngineGroupColumnTypeId INT = 4,
        @lastAccEngineEventId INT = 0,
        @accEngineEventColumnTypeId INT = 5,
        @lastAccEngineItemId INT = 0,
        @accEngineItemColumnTypeId INT= 7,
        @lastAccEngineItemCodeId INT = 0,
        @accEngineItemCodeColumnTypeId INT = 8,
        @lastAccEngineItemTypeId INT = 0,
        @accEngineItemTypeColumnTypeId INT = 9,
        @lastAccEngineModelDefinitionId INT = 0,
        @accEngineModelDefinitionColumnTypeId INT = 10;

    DECLARE
        @dynamicRulePaymentCCYEqualLocalCCY INT = 0,
        @dynamicRulePaymentCCYNotEqualLocalCCY INT = 0;

    DECLARE
        @dvItemId INT = 0,
        @dvIRSLCYRLCYPItemId INT = (SELECT Id FROM dbo.AccEngineItem WHERE Path = N'TREX/DV/IRS/LCYRLCYP/'),
        @dvIRSFCYRFCYPItemId INT = (SELECT Id FROM dbo.AccEngineItem WHERE Path = N'TREX/DV/IRS/FCYRFCYP/'),
        @dvCCSLCYRFCYPItemId INT = (SELECT Id FROM dbo.AccEngineItem WHERE Path = N'TREX/DV/CCS/LCYRFCYP/'),
        @dvCCSFCYRLCYPItemId INT = (SELECT Id FROM dbo.AccEngineItem WHERE Path = N'TREX/DV/CCS/FCYRLCYP/'),
        @dvCCSFCYRFCYPItemId INT = (SELECT Id FROM dbo.AccEngineItem WHERE Path = N'TREX/DV/CCS/FCYRFCYP/');

    DECLARE @tableItemIds TABLE (Id INT IDENTITY(1,1), ItemId INT);
    INSERT INTO @tableItemIds (ItemId)
    VALUES
        (@dvIRSLCYRLCYPItemId),
        (@dvIRSFCYRFCYPItemId),
        (@dvCCSLCYRFCYPItemId),
        (@dvCCSFCYRLCYPItemId),
        (@dvCCSFCYRFCYPItemId);

    DECLARE
        @dvCustomerPaymentIncomingEventId INT = 0,
        @dvCustomerPaymentOutgoingEventId INT = 0;

    DECLARE
        @dvCustomerPaymentIncomingEventGroupId INT = 0,
        @dvCustomerPaymentOutgoingEventGroupId INT = 0;

    DECLARE
        @dvCustomerPaymentIncomingEventGroupComponent1Id INT = 0,
        @dvCustomerPaymentIncomingEventGroupComponent2Id INT = 0,
        @dvCustomerPaymentOutgoingEventGroupComponent1Id INT = 0,
        @dvCustomerPaymentOutgoingEventGroupComponent2Id INT = 0

    ------------------------------------------------------------------------------------------------------------------------
    -- Definition Number Generation
    ------------------------------------------------------------------------------------------------------------------------
    --#region DefNumberGen
    ------------------------------------------------------------------------------------------------------------------------
    -- Accounting Engine Account Rule Last Number
    ------------------------------------------------------------------------------------------------------------------------
    SELECT @lastAccEngineAccountRuleId = LastNumber + 1
    FROM dbo.DefNumberGen
    WHERE EntityColumnType = @accEngineAccountRuleColumnTypeId
      AND Definition = N'AccEngineAccountRule Id'

    IF (@lastAccEngineAccountRuleId = 0)
        THROW 500001, 'AccEngineAccountRule Last Id Not Found', 1
    ------------------------------------------------------------------------------------------------------------------------
    -- Accounting Engine Dynamic Rule Last Number
    ------------------------------------------------------------------------------------------------------------------------
    SELECT @lastAccEngineDynamicRuleId = LastNumber + 1
    FROM dbo.DefNumberGen
    WHERE EntityColumnType = @accEngineDynamicRuleColumnTypeId
      AND Definition = N'AccEngineDynamicRule Id'

    IF (@lastAccEngineDynamicRuleId = 0)
        THROW 500001, 'AccEngineDynamicRule Last Id Not Found', 1
    ------------------------------------------------------------------------------------------------------------------------
    -- Accounting Engine Component Last Number
    ------------------------------------------------------------------------------------------------------------------------
    SELECT @lastAccEngineComponentId = LastNumber + 1
    FROM dbo.DefNumberGen
    WHERE EntityColumnType = @accEngineComponentColumnTypeId
      AND Definition = N'AccEngineComponent Id'

    IF (@lastAccEngineComponentId = 0)
        THROW 500001, 'AccEngineComponent Last Id Not Found', 1
    ------------------------------------------------------------------------------------------------------------------------
    -- Accounting Engine Group Last Number
    ------------------------------------------------------------------------------------------------------------------------
    SELECT @lastAccEngineGroupId = LastNumber + 1
    FROM dbo.DefNumberGen
    WHERE EntityColumnType = @accEngineGroupColumnTypeId
      AND Definition = N'AccEngineGroup Id'

    IF (@lastAccEngineGroupId = 0)
        THROW 500001, 'AccEngineGroup Last Id Not Found', 1
    ------------------------------------------------------------------------------------------------------------------------
    -- Accounting Engine Event Last Number
    ------------------------------------------------------------------------------------------------------------------------
    SELECT @lastAccEngineEventId = LastNumber + 1
    FROM dbo.DefNumberGen
    WHERE EntityColumnType = @accEngineEventColumnTypeId
      AND Definition = N'AccEngineEvent Id'

    IF (@lastAccEngineEventId = 0)
        THROW 500001, 'AccEngineEvent Last Id Not Found', 1
    ------------------------------------------------------------------------------------------------------------------------
    -- Accounting Engine Item Last Number
    ------------------------------------------------------------------------------------------------------------------------
    SELECT @lastAccEngineItemId = LastNumber + 1
    FROM dbo.DefNumberGen
    WHERE EntityColumnType = @accEngineItemColumnTypeId
      AND Definition = N'AccEngineItem Id'

    IF (@lastAccEngineItemId = 0)
        THROW 500001, 'AccEngineItem Last Id Not Found', 1
    ------------------------------------------------------------------------------------------------------------------------
    -- Accounting Engine Item Code Last Number
    ------------------------------------------------------------------------------------------------------------------------
    SELECT @lastAccEngineItemCodeId = LastNumber + 1
    FROM dbo.DefNumberGen
    WHERE EntityColumnType = @accEngineItemCodeColumnTypeId
      AND Definition = N'AccEngineItemCode Id'

    IF (@lastAccEngineItemCodeId = 0)
        THROW 500001, 'AccEngineItemCode Last Id Not Found', 1
    ------------------------------------------------------------------------------------------------------------------------
    -- Accounting Engine Item Type Last Number
    ------------------------------------------------------------------------------------------------------------------------
    SELECT @lastAccEngineItemTypeId = LastNumber + 1
    FROM dbo.DefNumberGen
    WHERE EntityColumnType = @accEngineItemTypeColumnTypeId
      AND Definition = N'AccEngineItemType Id'

    IF (@lastAccEngineItemTypeId = 0)
        THROW 500001, 'AccEngineItemType Last Id Not Found', 1
    ------------------------------------------------------------------------------------------------------------------------
    -- Accounting Engine Model Definition Last Number
    ------------------------------------------------------------------------------------------------------------------------
    SELECT @lastAccEngineModelDefinitionId = LastNumber + 1
    FROM dbo.DefNumberGen
    WHERE EntityColumnType = @accEngineModelDefinitionColumnTypeId
      AND Definition = N'AccEngineModelDefinition Id'

    IF (@lastAccEngineModelDefinitionId = 0)
        THROW 500001, 'AccEngineModelDefinition Last Id Not Found', 1
    --#endregion
    ------------------------------------------------------------------------------------------------------------------------   
   -- Accounting Engine Dynamic Rule
    ------------------------------------------------------------------------------------------------------------------------
    --#region AccEngineDynamicRule
    ------------------------------------------------------------------------------------------------------------------------
    -- PaymentCCY = LocalCCY
    -- TxnModel.PaymentCCY === TxnModel.LocalCCY
    ------------------------------------------------------------------------------------------------------------------------
    IF NOT EXISTS (SELECT 1
                   FROM dbo.AccEngineDynamicRule
                   WHERE [Rule] = N'TxnModel.PaymentCCY === TxnModel.LocalCCY')
        BEGIN
            INSERT INTO dbo.AccEngineDynamicRule (Id, Name, [Rule], Type, Description, StateId, StateDate, StateMaker)
            OUTPUT inserted.Id INTO @tempTable
            VALUES (@lastAccEngineDynamicRuleId, N'PaymentCCY = LocalCCY',
                    N'TxnModel.PaymentCCY === TxnModel.LocalCCY',
                    0, N'', @StateId, @stateDate, @stateMaker);
            SELECT @dynamicRulePaymentCCYEqualLocalCCY = Id FROM @tempTable;
            DELETE FROM @tempTable
            SELECT @lastAccEngineDynamicRuleId = @lastAccEngineDynamicRuleId + 1
        END;
    ELSE
        BEGIN
            SELECT @dynamicRulePaymentCCYEqualLocalCCY = Id
            FROM dbo.AccEngineDynamicRule
            WHERE [Rule] = N'TxnModel.PaymentCCY === TxnModel.LocalCCY'
        END
    ------------------------------------------------------------------------------------------------------------------------
    -- PaymentCCY != LocalCCY
    -- TxnModel.PaymentCCY !== TxnModel.LocalCCY
    ------------------------------------------------------------------------------------------------------------------------
    IF NOT EXISTS (SELECT 1
                   FROM dbo.AccEngineDynamicRule
                   WHERE [Rule] = N'TxnModel.PaymentCCY !== TxnModel.LocalCCY')
        BEGIN
            INSERT INTO dbo.AccEngineDynamicRule (Id, Name, [Rule], Type, Description, StateId, StateDate, StateMaker)
            OUTPUT inserted.Id INTO @tempTable
            VALUES (@lastAccEngineDynamicRuleId, N'PaymentCCY != LocalCCY',
                    N'TxnModel.PaymentCCY !== TxnModel.LocalCCY',
                    0, N'', @StateId, @stateDate, @stateMaker);
            SELECT @dynamicRulePaymentCCYNotEqualLocalCCY = Id FROM @tempTable;
            DELETE FROM @tempTable
            SELECT @lastAccEngineDynamicRuleId = @lastAccEngineDynamicRuleId + 1
        END;
    ELSE
        BEGIN
            SELECT @dynamicRulePaymentCCYNotEqualLocalCCY = Id
            FROM dbo.AccEngineDynamicRule
            WHERE [Rule] = N'TxnModel.PaymentCCY !== TxnModel.LocalCCY'
        END
    ------------------------------------------------------------------------------------------------------------------------
    --#endregion
    ------------------------------------------------------------------------------------------------------------------------
    -- Accounting Engine Model Definition
    ------------------------------------------------------------------------------------------------------------------------
    --#region AccEngineModelDefinition
    IF NOT EXISTS(SELECT 1
                  FROM dbo.accEngineModelDefinition
                  WHERE Name = N'Derivative Swap')
        BEGIN
            INSERT INTO dbo.AccEngineModelDefinition (Id, [Schema], Name, StateId, StateDate, StateMaker)
            OUTPUT INSERTED.Id INTO @tempTable
            VALUES (@lastAccEngineModelDefinitionId,
                    N'{"title":"DerivSWPAccountingModel","type":"object","properties":{"NetPeriodEndAmount":{"title":"Net Period End Amount","type":"number"},"NetPeriodEndAmountLCY":{"title":"Net Period End Amount LCY","type":"number"},"ReceivePeriodAmount":{"title":"Receive Period End Amount","type":"number"},"ReceivePeriodAmountLCY":{"title":"Receive Period End Amount LCY","type":"number"},"PayPeriodAmount":{"title":"Pay Period End Amount","type":"number"},"PayPeriodAmountLCY":{"title":"Pay Period End Amount LCY","type":"number"},"ReceivePrincipalAmount":{"title":"Receive Amount","type":["number","null"]},"PayPrincipalAmount":{"title":"Pay Amount","type":["number","null"]},"TotalMTMAmount":{"title":"MTM Amount","type":["number","null"]},"TotalMTMAmountCCY":{"title":"MTM Amount CCY","type":["string","null"]},"TotalMTMAmountLCY":{"title":"MTM Amount LCY","type":["number","null"]},"TotalMTMAmountLCYCode":{"title":"MTM Amount LCY Code","type":["string","null"]},"WeakAmountLCY":{"title":"Weak Amount LCY","type":["number","null"]},"WeakAmountCCY":{"title":"Weak Amount CCY","type":["string","null"]},"TaxAmount":{"title":"Tax Amount","type":"number"},"PayCurrency":{"title":"Pay Currency","type":["string","null"]},"ReceiveCurrency":{"title":"Receive Currency","type":["string","null"]},"LocalCCY":{"title":"Local CCY","type":["string","null"]},"LogicalDate":{"title":"Logical Date","type":"string","format":"date-time"},"NextWorkingLogicalDate":{"title":"Next Working Logical Date","type":"string","format":"date-time"},"PreviousWorkingLogicalDate":{"title":"Previous Working Logical Date","type":"string","format":"date-time"},"ExternalCustomerId":{"title":"External Customer Id","type":["string","null"]},"TxnReference":{"title":"Transaction Reference","description":"Transaction String Reference","type":["string","null"]},"TxnNo":{"title":"Transaction Number","type":"integer"},"AccountingGenerationDate":{"title":"Accounting Generation Date","type":"string","format":"date-time"},"Comment":{"title":"Comment","type":["string","null"]},"ApplicationName":{"title":"Application Name","type":["string","null"]},"TemplateId":{"title":"Template Id","type":"integer"},"PathRuleId":{"title":"Path Rule Id","type":"integer"}},"required":["NetPeriodEndAmount","NetPeriodEndAmountLCY","ReceivePeriodAmount","ReceivePeriodAmountLCY","PayPeriodAmount","PayPeriodAmountLCY","ReceivePrincipalAmount","PayPrincipalAmount","TotalMTMAmount","TotalMTMAmountCCY","TotalMTMAmountLCY","TotalMTMAmountLCYCode","WeakAmountLCY","WeakAmountCCY","TaxAmount","PayCurrency","ReceiveCurrency","LocalCCY","LogicalDate","NextWorkingLogicalDate","PreviousWorkingLogicalDate","ExternalCustomerId","TxnReference","TxnNo","AccountingGenerationDate","Comment","ApplicationName","TemplateId","PathRuleId"]}',
                    N'Derivative Swap', @StateId, @stateDate, @stateMaker);
            SELECT @lastAccEngineModelDefinitionId = Id FROM @tempTable;
            DELETE FROM @tempTable
        END
    ELSE
        BEGIN
            UPDATE dbo.AccEngineModelDefinition
            SET [Schema]   = N'{"title":"DerivSWPAccountingModel","type":"object","properties":{"NetPeriodEndAmount":{"title":"Net Period End Amount","type":"number"},"NetPeriodEndAmountLCY":{"title":"Net Period End Amount LCY","type":"number"},"ReceivePeriodAmount":{"title":"Receive Period End Amount","type":"number"},"ReceivePeriodAmountLCY":{"title":"Receive Period End Amount LCY","type":"number"},"PayPeriodAmount":{"title":"Pay Period End Amount","type":"number"},"PayPeriodAmountLCY":{"title":"Pay Period End Amount LCY","type":"number"},"ReceivePrincipalAmount":{"title":"Receive Amount","type":["number","null"]},"PayPrincipalAmount":{"title":"Pay Amount","type":["number","null"]},"TotalMTMAmount":{"title":"MTM Amount","type":["number","null"]},"TotalMTMAmountCCY":{"title":"MTM Amount CCY","type":["string","null"]},"TotalMTMAmountLCY":{"title":"MTM Amount LCY","type":["number","null"]},"TotalMTMAmountLCYCode":{"title":"MTM Amount LCY Code","type":["string","null"]},"WeakAmountLCY":{"title":"Weak Amount LCY","type":["number","null"]},"WeakAmountCCY":{"title":"Weak Amount CCY","type":["string","null"]},"TaxAmount":{"title":"Tax Amount","type":"number"},"PayCurrency":{"title":"Pay Currency","type":["string","null"]},"ReceiveCurrency":{"title":"Receive Currency","type":["string","null"]},"LocalCCY":{"title":"Local CCY","type":["string","null"]},"LogicalDate":{"title":"Logical Date","type":"string","format":"date-time"},"NextWorkingLogicalDate":{"title":"Next Working Logical Date","type":"string","format":"date-time"},"PreviousWorkingLogicalDate":{"title":"Previous Working Logical Date","type":"string","format":"date-time"},"ExternalCustomerId":{"title":"External Customer Id","type":["string","null"]},"TxnReference":{"title":"Transaction Reference","description":"Transaction String Reference","type":["string","null"]},"TxnNo":{"title":"Transaction Number","type":"integer"},"AccountingGenerationDate":{"title":"Accounting Generation Date","type":"string","format":"date-time"},"Comment":{"title":"Comment","type":["string","null"]},"ApplicationName":{"title":"Application Name","type":["string","null"]},"TemplateId":{"title":"Template Id","type":"integer"},"PathRuleId":{"title":"Path Rule Id","type":"integer"}},"required":["NetPeriodEndAmount","NetPeriodEndAmountLCY","ReceivePeriodAmount","ReceivePeriodAmountLCY","PayPeriodAmount","PayPeriodAmountLCY","ReceivePrincipalAmount","PayPrincipalAmount","TotalMTMAmount","TotalMTMAmountCCY","TotalMTMAmountLCY","TotalMTMAmountLCYCode","WeakAmountLCY","WeakAmountCCY","TaxAmount","PayCurrency","ReceiveCurrency","LocalCCY","LogicalDate","NextWorkingLogicalDate","PreviousWorkingLogicalDate","ExternalCustomerId","TxnReference","TxnNo","AccountingGenerationDate","Comment","ApplicationName","TemplateId","PathRuleId"]}',
                StateId    = 26,
                StateDate  = @stateDate,
                StateMaker = @stateMaker
            OUTPUT INSERTED.Id INTO @tempTable
            WHERE Name = N'Derivative Swap';
            SELECT @lastAccEngineModelDefinitionId = Id FROM @tempTable;
            DELETE FROM @tempTable
        END
    --#endregion
    ------------------------------------------------------------------------------------------------------------------------
    -- Accounting Engine Event Type
    ------------------------------------------------------------------------------------------------------------------------
    --#region AccEngineEventType
    IF NOT EXISTS (SELECT 1
                   FROM dbo.AccEngineEventType
                   WHERE Code = N'OnCustomerPaymentIncoming')
        BEGIN
            INSERT INTO dbo.AccEngineEventType (Name, Code)
            VALUES (N'OnCustomerPaymentIncoming', N'OnCustomerPaymentIncoming');
        END;
    IF NOT EXISTS (SELECT 1
                   FROM dbo.AccEngineEventType
                   WHERE Code = N'OnCustomerPaymentOutgoing')
        BEGIN
            INSERT INTO dbo.AccEngineEventType (Name, Code)
            VALUES (N'OnCustomerPaymentOutgoing', N'OnCustomerPaymentOutgoing');
        END;
    --#endregion
    ------------------------------------------------------------------------------------------------------------------------
    -- Accounting Engine Component Type
    ------------------------------------------------------------------------------------------------------------------------
    --#region AccEngineComponentType
    IF NOT EXISTS (SELECT 1
                   FROM dbo.AccEngineComponentType
                   WHERE Name = N'Customer Payment Incoming'
                     AND Code = N'513')
        BEGIN
            INSERT INTO dbo.AccEngineComponentType (Name, Code, StateId, StateDate, StateMaker)
            VALUES (N'Customer Payment Incoming', N'513', @stateId, @stateDate, @stateDate);
        END;
    IF NOT EXISTS (SELECT 1
                   FROM dbo.AccEngineComponentType
                   WHERE Name = N'Customer Payment Outgoing'
                     AND Code = N'514')
        BEGIN
            INSERT INTO dbo.AccEngineComponentType (Name, Code, StateId, StateDate, StateMaker)
            VALUES (N'Customer Payment Outgoing', N'514', @stateId, @stateDate, @stateDate);
        END;
    --#endregion





    ------------------------------------------------------------------------------------------------------------------------
     --#region CUSTOMER PAYMENT
    ------------------------------------------------------------------------------------------------------------------------
    DECLARE @i INT = 1, @count INT, @itemId INT;
    SELECT @count = COUNT(*) FROM @tableItemIds;
    WHILE @i <= @count
    BEGIN
        SELECT @dvItemId = ItemId FROM @tableItemIds WHERE Id = @i;


        --#region AccEngineEvent
        ------------------------------------------------------------------------------------------------------------------------
        -- Acc Engine Event OnCustomerPaymentIncoming
        ------------------------------------------------------------------------------------------------------------------------
        IF NOT EXISTS(SELECT 1
                        FROM dbo.accEngineEvent
                        WHERE ItemId = @dvItemId
                        AND EventTypeCode = N'OnCustomerPaymentIncoming')
            BEGIN
                INSERT INTO dbo.AccEngineEvent (Id, ItemId, EventTypeCode, ModifiedBy, ModifiedDate,
                                                EventDescriptionDynamicRuleId)
                OUTPUT inserted.Id INTO @tempTable
                VALUES (@lastAccEngineEventId, @dvItemId, N'OnCustomerPaymentIncoming', @stateMaker, @stateDate,
                        null);
                SELECT @dvCustomerPaymentIncomingEventId = Id FROM @tempTable;
                DELETE FROM @tempTable
                SELECT @lastAccEngineEventId = @lastAccEngineEventId + 1
            END
        ELSE
            BEGIN
                SELECT @dvCustomerPaymentIncomingEventId = Id
                FROM dbo.AccEngineEvent
                WHERE ItemId = @dvItemId
                    AND EventTypeCode = N'OnCustomerPaymentIncoming'
            END
        ------------------------------------------------------------------------------------------------------------------------
        -- Acc Engine Event OnCustomerPaymentOutgoing
        ------------------------------------------------------------------------------------------------------------------------
        IF NOT EXISTS(SELECT 1
                        FROM dbo.accEngineEvent
                        WHERE ItemId = @dvItemId
                        AND EventTypeCode = N'OnCustomerPaymentOutgoing')
            BEGIN
                INSERT INTO dbo.AccEngineEvent (Id, ItemId, EventTypeCode, ModifiedBy, ModifiedDate,
                                                EventDescriptionDynamicRuleId)
                OUTPUT inserted.Id INTO @tempTable
                VALUES (@lastAccEngineEventId, @dvItemId, N'OnCustomerPaymentOutgoing', @stateMaker, @stateDate,
                        null);
                SELECT @dvCustomerPaymentOutgoingEventId = Id FROM @tempTable;
                DELETE FROM @tempTable
                SELECT @lastAccEngineEventId = @lastAccEngineEventId + 1
            END
        ELSE
            BEGIN
                SELECT @dvCustomerPaymentOutgoingEventId = Id
                FROM dbo.AccEngineEvent
                WHERE ItemId = @dvItemId
                    AND EventTypeCode = N'OnCustomerPaymentOutgoing'
            END
        --#endregion
        ------------------------------------------------------------------------------------------------------------------------
        -- Accounting Engine Group 
        ------------------------------------------------------------------------------------------------------------------------
        --#region AccEngineGroup
        ------------------------------------------------------------------------------------------------------------------------
        -- OnCustomerPaymentIncoming Event Group
        ------------------------------------------------------------------------------------------------------------------------
        IF NOT EXISTS(SELECT 1
                        FROM dbo.accEngineGroup
                        WHERE EventId = @dvCustomerPaymentIncomingEventId
                        AND ValidationRuleId is null)
            BEGIN
                INSERT INTO dbo.AccEngineGroup (Id, EventId, ValidationRuleId, [Order],
                                                ModifiedBy,
                                                ModifiedDate,
                                                StateId,
                                                StateDate,
                                                StateMaker)
                OUTPUT inserted.Id INTO @tempTable
                VALUES (@lastAccEngineGroupId, @dvCustomerPaymentIncomingEventId,
                        null, 1,
                        @stateMaker,
                        @stateDate,
                        @StateId,
                        @stateDate,
                        @stateMaker);
                SELECT @dvCustomerPaymentIncomingEventGroupId = Id FROM @tempTable;
                DELETE FROM @tempTable
                SELECT @lastAccEngineGroupId = @lastAccEngineGroupId + 1
            END
        ELSE
            BEGIN
                SELECT @dvCustomerPaymentIncomingEventGroupId = Id
                FROM dbo.AccEngineGroup
                WHERE EventId = @dvCustomerPaymentIncomingEventId
                    AND ValidationRuleId is null
            END
        ------------------------------------------------------------------------------------------------------------------------
        -- OnCustomerPaymentOutgoing Event Group
        ------------------------------------------------------------------------------------------------------------------------
        IF NOT EXISTS(SELECT 1
                        FROM dbo.accEngineGroup
                        WHERE EventId = @dvCustomerPaymentOutgoingEventId
                        AND ValidationRuleId is null)
            BEGIN
                INSERT INTO dbo.AccEngineGroup (Id, EventId, ValidationRuleId, [Order],
                                                ModifiedBy,
                                                ModifiedDate,
                                                StateId,
                                                StateDate,
                                                StateMaker)
                OUTPUT inserted.Id INTO @tempTable
                VALUES (@lastAccEngineGroupId, @dvCustomerPaymentOutgoingEventId,
                        null, 1,
                        @stateMaker,
                        @stateDate,
                        @StateId,
                        @stateDate,
                        @stateMaker);
                SELECT @dvCustomerPaymentOutgoingEventGroupId = Id FROM @tempTable;
                DELETE FROM @tempTable
                SELECT @lastAccEngineGroupId = @lastAccEngineGroupId + 1
            END
        ELSE
            BEGIN
                SELECT @dvCustomerPaymentOutgoingEventGroupId = Id
                FROM dbo.AccEngineGroup
                WHERE EventId = @dvCustomerPaymentOutgoingEventId
                    AND ValidationRuleId is null
            END
        --#endregion   
        ------------------------------------------------------------------------------------------------------------------------
        -- Accounting Engine Component
        ------------------------------------------------------------------------------------------------------------------------
        --#region AccEngineComponent
        ------------------------------------------------------------------------------------------------------------------------
        -- Accounting Engine Component DV CustomerPaymentIncoming Event Group Component 1
        ------------------------------------------------------------------------------------------------------------------------
        IF NOT EXISTS (SELECT 1
                        FROM dbo.accEngineComponent
                        WHERE GroupId = @dvCustomerPaymentIncomingEventGroupId
                            AND ValidationRuleId = @dynamicRulePaymentCCYEqualLocalCCY
                            AND ComponentTypeCode = N'513')
            BEGIN
                INSERT INTO dbo.AccEngineComponent (Id, GroupId, ComponentTypeCode, ValidationRuleId, [Order],
                                                    ModifiedBy,
                                                    ModifiedDate)
                OUTPUT inserted.Id INTO @tempTable
                VALUES (@lastAccEngineComponentId, @dvCustomerPaymentIncomingEventGroupId, N'513',
                        @dynamicRulePaymentCCYEqualLocalCCY,
                        1,
                        @stateMaker,
                        @stateDate);
                SELECT @dvCustomerPaymentIncomingEventGroupComponent1Id = Id FROM @tempTable;
                DELETE FROM @tempTable
                SELECT @lastAccEngineComponentId = @lastAccEngineComponentId + 1
            END
        ELSE
            BEGIN
                SELECT @dvCustomerPaymentIncomingEventGroupComponent1Id = Id
                FROM dbo.AccEngineComponent
                WHERE GroupId = @dvCustomerPaymentIncomingEventGroupId
                    AND ValidationRuleId = @dynamicRulePaymentCCYEqualLocalCCY
                    AND ComponentTypeCode = N'513'
            END

        ------------------------------------------------------------------------------------------------------------------------
        -- Accounting Engine Component DV CustomerPaymentIncoming Event Group Component 2
        ------------------------------------------------------------------------------------------------------------------------
        IF NOT EXISTS (SELECT 1
                        FROM dbo.accEngineComponent
                        WHERE GroupId = @dvCustomerPaymentIncomingEventGroupId
                            AND ValidationRuleId = @dynamicRulePaymentCCYNotEqualLocalCCY
                            AND ComponentTypeCode = N'513')
            BEGIN
                INSERT INTO dbo.AccEngineComponent (Id, GroupId, ComponentTypeCode, ValidationRuleId, [Order],
                                                    ModifiedBy,
                                                    ModifiedDate)
                OUTPUT inserted.Id INTO @tempTable
                VALUES (@lastAccEngineComponentId, @dvCustomerPaymentIncomingEventGroupId, N'513',
                        @dynamicRulePaymentCCYNotEqualLocalCCY,
                        2,
                        @stateMaker,
                        @stateDate);
                SELECT @dvCustomerPaymentIncomingEventGroupComponent2Id = Id FROM @tempTable;
                DELETE FROM @tempTable
                SELECT @lastAccEngineComponentId = @lastAccEngineComponentId + 1
            END
        ELSE
            BEGIN
                SELECT @dvCustomerPaymentIncomingEventGroupComponent2Id = Id
                FROM dbo.AccEngineComponent
                WHERE GroupId = @dvCustomerPaymentIncomingEventGroupId
                    AND ValidationRuleId = @dynamicRulePaymentCCYNotEqualLocalCCY
                    AND ComponentTypeCode = N'513'
            END
            
            
        ------------------------------------------------------------------------------------------------------------------------
        -- Accounting Engine Component DV CustomerPaymentOutgoing Event Group Component 1
        ------------------------------------------------------------------------------------------------------------------------
        IF NOT EXISTS (SELECT 1
                        FROM dbo.accEngineComponent
                        WHERE GroupId = @dvCustomerPaymentOutgoingEventGroupId
                            AND ValidationRuleId = @dynamicRulePaymentCCYEqualLocalCCY
                            AND ComponentTypeCode = N'514')
            BEGIN
                INSERT INTO dbo.AccEngineComponent (Id, GroupId, ComponentTypeCode, ValidationRuleId, [Order],
                                                    ModifiedBy,
                                                    ModifiedDate)
                OUTPUT inserted.Id INTO @tempTable
                VALUES (@lastAccEngineComponentId, @dvCustomerPaymentOutgoingEventGroupId, N'514',
                        @dynamicRulePaymentCCYEqualLocalCCY,
                        1,
                        @stateMaker,
                        @stateDate);
                SELECT @dvCustomerPaymentOutgoingEventGroupComponent1Id = Id FROM @tempTable;
                DELETE FROM @tempTable
                SELECT @lastAccEngineComponentId = @lastAccEngineComponentId + 1
            END
        ELSE
            BEGIN
                SELECT @dvCustomerPaymentOutgoingEventGroupComponent1Id = Id
                FROM dbo.AccEngineComponent
                WHERE GroupId = @dvCustomerPaymentOutgoingEventGroupId
                    AND ValidationRuleId = @dynamicRulePaymentCCYEqualLocalCCY
                    AND ComponentTypeCode = N'514'
            END
        ------------------------------------------------------------------------------------------------------------------------
        -- Accounting Engine Component DV CustomerPaymentOutgoing Event Group Component 2
        ------------------------------------------------------------------------------------------------------------------------
        IF NOT EXISTS (SELECT 1
                        FROM dbo.accEngineComponent
                        WHERE GroupId = @dvCustomerPaymentOutgoingEventGroupId
                            AND ValidationRuleId = @dynamicRulePaymentCCYNotEqualLocalCCY
                            AND ComponentTypeCode = N'514')
            BEGIN
                INSERT INTO dbo.AccEngineComponent (Id, GroupId, ComponentTypeCode, ValidationRuleId, [Order],
                                                    ModifiedBy,
                                                    ModifiedDate)
                OUTPUT inserted.Id INTO @tempTable
                VALUES (@lastAccEngineComponentId, @dvCustomerPaymentOutgoingEventGroupId, N'514',
                        @dynamicRulePaymentCCYNotEqualLocalCCY,
                        2,
                        @stateMaker,
                        @stateDate);
                SELECT @dvCustomerPaymentOutgoingEventGroupComponent2Id = Id FROM @tempTable;
                DELETE FROM @tempTable
                SELECT @lastAccEngineComponentId = @lastAccEngineComponentId + 1
            END
        ELSE
            BEGIN
                SELECT @dvCustomerPaymentOutgoingEventGroupComponent2Id = Id
                FROM dbo.AccEngineComponent
                WHERE GroupId = @dvCustomerPaymentOutgoingEventGroupId
                    AND ValidationRuleId = @dynamicRulePaymentCCYNotEqualLocalCCY
                    AND ComponentTypeCode = N'514'
            END

        --#endregion
        ------------------------------------------------------------------------------------------------------------------------
        -- Accounting Engine Rule
        ------------------------------------------------------------------------------------------------------------------------
        --#region AccEngineAccountRule
        ------------------------------------------------------------------------------------------------------------------------
        -- Accounting Engine Rule DV CustomerPaymentIncoming Event Group Component 1 Rule LCY
        ------------------------------------------------------------------------------------------------------------------------
        IF NOT EXISTS(SELECT 1
                        FROM dbo.accEngineAccountRule
                        WHERE ComponentId = @dvCustomerPaymentIncomingEventGroupComponent1Id
                        AND GLCode = N'IncomingPaymentCustomerLCY')
            BEGIN
                INSERT INTO dbo.AccEngineAccountRule(Id, ComponentId, GLCode, CustomerCodeSource, CustomerAccountCodeSource,
                                                        DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                        ValueDateSource, TxnDateSource, CcySource, FcySource, LcyEqvtSource,
                                                        FcyAmtSource, ReverseRebook, CommentSource, CommentRuleId, ModifiedBy,
                                                        ModifiedDate, ReverseTxnDateSource, ReverseValueDateSource)
                VALUES (@lastAccEngineAccountRuleId, @dvCustomerPaymentIncomingEventGroupComponent1Id, N'IncomingPaymentCustomerLCY',
                        null,
                        null,
                        N'Debit', null, N'PaymentAmount', N'TxnNo', N'LogicalDate', N'LogicalDate', N'PaymentCCY',
                        N'PaymentCCY', N'PaymentAmount', N'PaymentAmount', 0, null, null, @stateMaker,
                        @stateDate, null, null);

                SELECT @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
            END

        IF NOT EXISTS(SELECT 1
                        FROM dbo.accEngineAccountRule
                        WHERE ComponentId = @dvCustomerPaymentIncomingEventGroupComponent1Id
                        AND GLCode = N'IncomingPaymentLCY')
            BEGIN
                INSERT INTO dbo.AccEngineAccountRule(Id, ComponentId, GLCode, CustomerCodeSource, CustomerAccountCodeSource,
                                                        DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                        ValueDateSource, TxnDateSource, CcySource, FcySource, LcyEqvtSource,
                                                        FcyAmtSource, ReverseRebook, CommentSource, CommentRuleId, ModifiedBy,
                                                        ModifiedDate, ReverseTxnDateSource, ReverseValueDateSource)
                VALUES (@lastAccEngineAccountRuleId, @dvCustomerPaymentIncomingEventGroupComponent1Id, N'IncomingPaymentLCY', null,
                        null,
                        N'Credit', null, N'PaymentAmount', N'TxnNo', N'LogicalDate', N'LogicalDate', N'PaymentCCY',
                        N'PaymentCCY', N'PaymentAmount', N'PaymentAmount', 0, null, null, @stateMaker,
                        @stateDate, null, null);

                SELECT @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
            END
        ------------------------------------------------------------------------------------------------------------------------
        -- Accounting Engine Rule DV CustomerPaymentIncoming Event Group Component 2 Rule FCY
        ------------------------------------------------------------------------------------------------------------------------
        IF NOT EXISTS(SELECT 1
                        FROM dbo.accEngineAccountRule
                        WHERE ComponentId = @dvCustomerPaymentIncomingEventGroupComponent2Id
                        AND GLCode = N'IncomingPaymentCustomerFCY')
            BEGIN
                INSERT INTO dbo.AccEngineAccountRule(Id, ComponentId, GLCode, CustomerCodeSource, CustomerAccountCodeSource,
                                                        DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                        ValueDateSource, TxnDateSource, CcySource, FcySource, LcyEqvtSource,
                                                        FcyAmtSource, ReverseRebook, CommentSource, CommentRuleId, ModifiedBy,
                                                        ModifiedDate, ReverseTxnDateSource, ReverseValueDateSource)
                VALUES (@lastAccEngineAccountRuleId, @dvCustomerPaymentIncomingEventGroupComponent2Id, N'IncomingPaymentCustomerFCY',
                        null,
                        null,
                        N'Debit', null, N'PaymentAmount', N'TxnNo', N'LogicalDate', N'LogicalDate', N'PaymentCCY',
                        N'PaymentCCY', N'PaymentAmount', N'PaymentAmount', 0, null, null, @stateMaker,
                        @stateDate, null, null);

                SELECT @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
            END
        IF NOT EXISTS(SELECT 1
                        FROM dbo.accEngineAccountRule
                        WHERE ComponentId = @dvCustomerPaymentIncomingEventGroupComponent2Id
                        AND GLCode = N'IncomingPaymentFCY')
            BEGIN
                INSERT INTO dbo.AccEngineAccountRule(Id, ComponentId, GLCode, CustomerCodeSource, CustomerAccountCodeSource,
                                                        DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                        ValueDateSource, TxnDateSource, CcySource, FcySource, LcyEqvtSource,
                                                        FcyAmtSource, ReverseRebook, CommentSource, CommentRuleId, ModifiedBy,
                                                        ModifiedDate, ReverseTxnDateSource, ReverseValueDateSource)
                VALUES (@lastAccEngineAccountRuleId, @dvCustomerPaymentIncomingEventGroupComponent2Id, N'IncomingPaymentFCY', null,
                        null,
                        N'Credit', null, N'PaymentAmount', N'TxnNo', N'LogicalDate', N'LogicalDate', N'PaymentCCY',
                        N'PaymentCCY', N'PaymentAmount', N'PaymentAmount', 0, null, null, @stateMaker,
                        @stateDate, null, null);

                SELECT @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
            END
        ------------------------------------------------------------------------------------------------------------------------
        -- Accounting Engine Rule DV CustomerPaymentOutgoing Event Group Component 1 Rule LCY
        ------------------------------------------------------------------------------------------------------------------------
        IF NOT EXISTS(SELECT 1
                        FROM dbo.accEngineAccountRule
                        WHERE ComponentId = @dvCustomerPaymentOutgoingEventGroupComponent1Id
                        AND GLCode = N'OutgoingPaymentCustomerLCY')
            BEGIN
                INSERT INTO dbo.AccEngineAccountRule(Id, ComponentId, GLCode, CustomerCodeSource, CustomerAccountCodeSource,
                                                        DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                        ValueDateSource, TxnDateSource, CcySource, FcySource, LcyEqvtSource,
                                                        FcyAmtSource, ReverseRebook, CommentSource, CommentRuleId, ModifiedBy,
                                                        ModifiedDate, ReverseTxnDateSource, ReverseValueDateSource)
                VALUES (@lastAccEngineAccountRuleId, @dvCustomerPaymentOutgoingEventGroupComponent1Id, N'OutgoingPaymentCustomerLCY',
                        null,
                        null,
                        N'Credit', null, N'PaymentAmount', N'TxnNo', N'LogicalDate', N'LogicalDate', N'PaymentCCY',
                        N'PaymentCCY', N'PaymentAmount', N'PaymentAmount', 0, null, null, @stateMaker,
                        @stateDate, null, null);

                SELECT @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
            END
        IF NOT EXISTS(SELECT 1
                        FROM dbo.accEngineAccountRule
                        WHERE ComponentId = @dvCustomerPaymentOutgoingEventGroupComponent1Id
                        AND GLCode = N'OutgoingPaymentLCY')
            BEGIN
                INSERT INTO dbo.AccEngineAccountRule(Id, ComponentId, GLCode, CustomerCodeSource, CustomerAccountCodeSource,
                                                        DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                        ValueDateSource, TxnDateSource, CcySource, FcySource, LcyEqvtSource,
                                                        FcyAmtSource, ReverseRebook, CommentSource, CommentRuleId, ModifiedBy,
                                                        ModifiedDate, ReverseTxnDateSource, ReverseValueDateSource)
                VALUES (@lastAccEngineAccountRuleId, @dvCustomerPaymentOutgoingEventGroupComponent1Id, N'OutgoingPaymentLCY', null,
                        null,
                        N'Debit', null, N'PaymentAmount', N'TxnNo', N'LogicalDate', N'LogicalDate', N'PaymentCCY',
                        N'PaymentCCY', N'PaymentAmount', N'PaymentAmount', 0, null, null, @stateMaker,
                        @stateDate, null, null);

                SELECT @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
            END
        ------------------------------------------------------------------------------------------------------------------------
        -- Accounting Engine Rule DV CustomerPaymentOutgoing Event Group Component 2 Rule FCY
        ------------------------------------------------------------------------------------------------------------------------
        IF NOT EXISTS(SELECT 1
                        FROM dbo.accEngineAccountRule
                        WHERE ComponentId = @dvCustomerPaymentOutgoingEventGroupComponent2Id
                        AND GLCode = N'OutgoingPaymentCustomerFCY')
            BEGIN
                INSERT INTO dbo.AccEngineAccountRule(Id, ComponentId, GLCode, CustomerCodeSource, CustomerAccountCodeSource,
                                                        DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                        ValueDateSource, TxnDateSource, CcySource, FcySource, LcyEqvtSource,
                                                        FcyAmtSource, ReverseRebook, CommentSource, CommentRuleId, ModifiedBy,
                                                        ModifiedDate, ReverseTxnDateSource, ReverseValueDateSource)
                VALUES (@lastAccEngineAccountRuleId, @dvCustomerPaymentOutgoingEventGroupComponent2Id, N'OutgoingPaymentCustomerFCY',
                        null,
                        null,
                        N'Credit', null, N'PaymentAmount', N'TxnNo', N'LogicalDate', N'LogicalDate', N'PaymentCCY',
                        N'PaymentCCY', N'PaymentAmount', N'PaymentAmount', 0, null, null, @stateMaker,
                        @stateDate, null, null);

                SELECT @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
            END
        IF NOT EXISTS(SELECT 1
                        FROM dbo.accEngineAccountRule
                        WHERE ComponentId = @dvCustomerPaymentOutgoingEventGroupComponent2Id
                        AND GLCode = N'OutgoingPaymentFCY')
            BEGIN
                INSERT INTO dbo.AccEngineAccountRule(Id, ComponentId, GLCode, CustomerCodeSource, CustomerAccountCodeSource,
                                                        DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                        ValueDateSource, TxnDateSource, CcySource, FcySource, LcyEqvtSource,
                                                        FcyAmtSource, ReverseRebook, CommentSource, CommentRuleId, ModifiedBy,
                                                        ModifiedDate, ReverseTxnDateSource, ReverseValueDateSource)
                VALUES (@lastAccEngineAccountRuleId, @dvCustomerPaymentOutgoingEventGroupComponent2Id, N'OutgoingPaymentFCY', null,
                        null,
                        N'Debit', null, N'PaymentAmount', N'TxnNo', N'LogicalDate', N'LogicalDate', N'PaymentCCY',
                        N'PaymentCCY', N'PaymentAmount', N'PaymentAmount', 0, null, null, @stateMaker,
                        @stateDate, null, null);

                SELECT @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
            END
        --#endregion

        SET @i += 1;
    END
    --#endregion CUSTOMER PAYMENT




    ------------------------------------------------------------------------------------------------------------------------
    -- Definition Number Generation Update
    ------------------------------------------------------------------------------------------------------------------------
    --#region DefNumberGen
    update dbo.defNumberGen
    SET LastNumber     = @lastAccEngineDynamicRuleId,
        LastUpdateDate = @stateDate
    WHERE EntityColumnType = @accEngineDynamicRuleColumnTypeId

    update dbo.defNumberGen
    SET LastNumber     = @lastAccEngineAccountRuleId,
        LastUpdateDate = @stateDate
    WHERE EntityColumnType = @accEngineAccountRuleColumnTypeId

    update dbo.defNumberGen
    SET LastNumber     = @lastAccEngineComponentId,
        LastUpdateDate = @stateDate
    WHERE EntityColumnType = @accEngineComponentColumnTypeId

    update dbo.defNumberGen
    SET LastNumber     = @lastAccEngineGroupId,
        LastUpdateDate = @stateDate
    WHERE EntityColumnType = @accEngineGroupColumnTypeId

    update dbo.defNumberGen
    SET LastNumber     = @lastAccEngineEventId,
        LastUpdateDate = @stateDate
    WHERE EntityColumnType = @accEngineEventColumnTypeId

    update dbo.defNumberGen
    SET LastNumber     = @lastAccEngineItemId,
        LastUpdateDate = @stateDate
    WHERE EntityColumnType = @accEngineItemColumnTypeId

    update dbo.defNumberGen
    SET LastNumber     = @lastAccEngineItemCodeId,
        LastUpdateDate = @stateDate
    WHERE EntityColumnType = @accEngineItemCodeColumnTypeId

    update dbo.defNumberGen
    SET LastNumber     = @lastAccEngineItemTypeId,
        LastUpdateDate = @stateDate
    WHERE EntityColumnType = @accEngineItemTypeColumnTypeId

    update dbo.defNumberGen
    SET LastNumber     = @lastAccEngineModelDefinitionId,
        LastUpdateDate = @stateDate
    WHERE EntityColumnType = @accEngineModelDefinitionColumnTypeId
    --#endregion

    COMMIT TRANSACTION
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