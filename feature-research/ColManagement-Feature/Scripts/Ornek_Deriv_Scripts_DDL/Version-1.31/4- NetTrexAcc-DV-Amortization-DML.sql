/***************************************************************************************************
* This script is designed to add Amortization acc rules
***************************************************************************************************/

use [NetTrexAcc_Amortization]
GO
SET XACT_ABORT ON;

BEGIN TRANSACTION;

BEGIN TRY

    /********** 1. STEP: DEGISKEN TANIMLARI *********************************/
    BEGIN
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
            @accEngineItemColumnTypeId INT= 7,
            @accEngineItemCodeColumnTypeId INT = 8,
            @accEngineItemTypeColumnTypeId INT = 9,
            @lastAccEngineModelDefinitionId INT = 0,
            @accEngineModelDefinitionColumnTypeId INT = 10;

        DECLARE 
            @accComponentCodeMaturityDateContingent NVARCHAR(50) = N'501';

        DECLARE
            @dynamicRuleIdReceivePaymentDateEqualLogicalDate INT = 0,
            @dynamicRuleIdPayPaymentDateEqualLogicalDate INT = 0;

        DECLARE
            @dvItemId INT = (SELECT Id FROM dbo.AccEngineItem WHERE Path = N'TREX/DV/'),
            @dvIRSLCYRLCYPItemId INT = (SELECT Id FROM dbo.AccEngineItem WHERE Path = N'TREX/DV/IRS/LCYRLCYP/'),
            @dvIRSFCYRFCYPItemId INT = (SELECT Id FROM dbo.AccEngineItem WHERE Path = N'TREX/DV/IRS/FCYRFCYP/'),
            @dvCCSLCYRFCYPItemId INT = (SELECT Id FROM dbo.AccEngineItem WHERE Path = N'TREX/DV/CCS/LCYRFCYP/'),
            @dvCCSFCYRLCYPItemId INT = (SELECT Id FROM dbo.AccEngineItem WHERE Path = N'TREX/DV/CCS/FCYRLCYP/'),
            @dvCCSFCYRFCYPItemId INT = (SELECT Id FROM dbo.AccEngineItem WHERE Path = N'TREX/DV/CCS/FCYRFCYP/');

        DECLARE
            @dvAmortizationEventId INT = 0,
            @dvFeeEventId INT = 0;

        DECLARE
            @dvAmortizationEventGroupId INT = 0,
            @dvFeeEventGroupId INT = 0;

        DECLARE
            @dvAmortizationEventGroupComponentReceiveId INT = 0,
            @dvAmortizationEventGroupComponentPayId INT = 0,
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
    END

    /********** 2. STEP: GENEL TANIMLAR *************************************/
    BEGIN
        ------------------------------------------------------------------------------------------------------------------------   
        -- Accounting Engine Dynamic Rule
        ------------------------------------------------------------------------------------------------------------------------
        --#region AccEngineDynamicRule
        ------------------------------------------------------------------------------------------------------------------------
        -- ReceivePeriodPaymentDate = LogicalDate
        -- TxnModel.ReceivePeriodPaymentDate === TxnModel.LocalDate
        ------------------------------------------------------------------------------------------------------------------------
        IF NOT EXISTS (SELECT 1
                       FROM dbo.AccEngineDynamicRule
                       WHERE [Rule] = N'TxnModel.ReceivePeriodPaymentDate !== null ? TxnModel.ReceivePeriodPaymentDate.getTime() === TxnModel.LogicalDate.getTime() : false')
            BEGIN
                INSERT INTO dbo.AccEngineDynamicRule (Id, Name, [Rule], Type, Description, StateId, StateDate, StateMaker)
                OUTPUT inserted.Id INTO @tempTable
                VALUES (@lastAccEngineDynamicRuleId, N'ReceivePeriodPaymentDate = LogicalDate',
                        N'TxnModel.ReceivePeriodPaymentDate !== null ? TxnModel.ReceivePeriodPaymentDate.getTime() === TxnModel.LogicalDate.getTime() : false',
                        0, N'', @StateId, @stateDate, @stateMaker);
                SELECT @dynamicRuleIdReceivePaymentDateEqualLogicalDate = Id FROM @tempTable;
                DELETE FROM @tempTable
                SELECT @lastAccEngineDynamicRuleId = @lastAccEngineDynamicRuleId + 1
            END;
        ELSE
            BEGIN
                SELECT @dynamicRuleIdReceivePaymentDateEqualLogicalDate = Id
                FROM dbo.AccEngineDynamicRule
                WHERE [Rule] = N'TxnModel.ReceivePeriodPaymentDate !== null ? TxnModel.ReceivePeriodPaymentDate.getTime() === TxnModel.LogicalDate.getTime() : false'
            END
        ------------------------------------------------------------------------------------------------------------------------
        -- PayPeriodPaymentDate = LogicalDate
        -- TxnModel.PayPeriodPaymentDate === TxnModel.LocalDate
        ------------------------------------------------------------------------------------------------------------------------
        IF NOT EXISTS (SELECT 1
                       FROM dbo.AccEngineDynamicRule
                       WHERE [Rule] = N'TxnModel.PayPeriodPaymentDate !== null ? TxnModel.PayPeriodPaymentDate.getTime() === TxnModel.LogicalDate.getTime() : false')
            BEGIN
                INSERT INTO dbo.AccEngineDynamicRule (Id, Name, [Rule], Type, Description, StateId, StateDate, StateMaker)
                OUTPUT inserted.Id INTO @tempTable
                VALUES (@lastAccEngineDynamicRuleId, N'PayPeriodPaymentDate = LogicalDate',
                        N'TxnModel.PayPeriodPaymentDate !== null ? TxnModel.PayPeriodPaymentDate.getTime() === TxnModel.LogicalDate.getTime() : false',
                        0, N'', @StateId, @stateDate, @stateMaker);
                SELECT @dynamicRuleIdPayPaymentDateEqualLogicalDate = Id FROM @tempTable;
                DELETE FROM @tempTable
                SELECT @lastAccEngineDynamicRuleId = @lastAccEngineDynamicRuleId + 1
            END;
        ELSE
            BEGIN
                SELECT @dynamicRuleIdPayPaymentDateEqualLogicalDate = Id
                FROM dbo.AccEngineDynamicRule
                WHERE [Rule] = N'TxnModel.PayPeriodPaymentDate !== null ? TxnModel.PayPeriodPaymentDate.getTime() === TxnModel.LogicalDate.getTime() : false'
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
                        N'{"title":"DerivSWPAccountingModel","type":"object","properties":{"NetPeriodEndAmount":{"title":"Net Period End Amount","type":"number"},"NetPeriodEndAmountLCY":{"title":"Net Period End Amount LCY","type":"number"},"ReceivePeriodAmount":{"title":"Receive Period End Amount","type":"number"},"ReceivePeriodAmountLCY":{"title":"Receive Period End Amount LCY","type":"number"},"PayPeriodAmount":{"title":"Pay Period End Amount","type":"number"},"PayPeriodAmountLCY":{"title":"Pay Period End Amount LCY","type":"number"},"ReceivePrincipalAmount":{"title":"Receive Amount","type":["number","null"]},"PayPrincipalAmount":{"title":"Pay Amount","type":["number","null"]},"ReceiveAmortizationAmount":{"title":"Receive Amortization Amount","type":"number"},"ReceiveAmortizationAmountLCY":{"title":"Receive Amortization Amount LCY","type":"number"},"PayAmortizationAmount":{"title":"Pay Amortization Amount","type":"number"},"PayAmortizationAmountLCY":{"title":"Pay Amortization Amount LCY","type":"number"},"TotalMTMAmount":{"title":"MTM Amount","type":["number","null"]},"TotalMTMAmountCCY":{"title":"MTM Amount CCY","type":["string","null"]},"TotalMTMAmountLCY":{"title":"MTM Amount LCY","type":["number","null"]},"TotalMTMAmountLCYCode":{"title":"MTM Amount LCY Code","type":["string","null"]},"WeakAmountLCY":{"title":"Weak Amount LCY","type":["number","null"]},"WeakAmountCCY":{"title":"Weak Amount CCY","type":["string","null"]},"TaxAmount":{"title":"Tax Amount","type":"number"},"PayCurrency":{"title":"Pay Currency","type":["string","null"]},"ReceiveCurrency":{"title":"Receive Currency","type":["string","null"]},"LocalCCY":{"title":"Local CCY","type":["string","null"]},"LogicalDate":{"title":"Logical Date","type":"string","format":"date-time"},"NextWorkingLogicalDate":{"title":"Next Working Logical Date","type":"string","format":"date-time"},"PreviousWorkingLogicalDate":{"title":"Previous Working Logical Date","type":"string","format":"date-time"},"ExternalCustomerId":{"title":"External Customer Id","type":["string","null"]},"TxnReference":{"title":"Transaction Reference","description":"Transaction String Reference","type":["string","null"]},"TxnNo":{"title":"Transaction Number","type":"integer"},"AccountingGenerationDate":{"title":"Accounting Generation Date","type":"string","format":"date-time"},"Comment":{"title":"Comment","type":["string","null"]},"ApplicationName":{"title":"Application Name","type":["string","null"]},"TemplateId":{"title":"Template Id","type":"integer"},"PathRuleId":{"title":"Path Rule Id","type":"integer"}},"required":["NetPeriodEndAmount","NetPeriodEndAmountLCY","ReceivePeriodAmount","ReceivePeriodAmountLCY","PayPeriodAmount","PayPeriodAmountLCY","ReceivePrincipalAmount","PayPrincipalAmount","TotalMTMAmount","TotalMTMAmountCCY","TotalMTMAmountLCY","TotalMTMAmountLCYCode","WeakAmountLCY","WeakAmountCCY","TaxAmount","PayCurrency","ReceiveCurrency","LocalCCY","LogicalDate","NextWorkingLogicalDate","PreviousWorkingLogicalDate","ExternalCustomerId","TxnReference","TxnNo","AccountingGenerationDate","Comment","ApplicationName","TemplateId","PathRuleId"]}',
                        N'Derivative Swap', @StateId, @stateDate, @stateMaker);
                SELECT @lastAccEngineModelDefinitionId = Id FROM @tempTable;
                DELETE FROM @tempTable
            END
        ELSE
            BEGIN
                UPDATE dbo.AccEngineModelDefinition
                SET [Schema]   = N'{"title":"DerivSWPAccountingModel","type":"object","properties":{"NetPeriodEndAmount":{"title":"Net Period End Amount","type":"number"},"NetPeriodEndAmountLCY":{"title":"Net Period End Amount LCY","type":"number"},"ReceivePeriodAmount":{"title":"Receive Period End Amount","type":"number"},"ReceivePeriodAmountLCY":{"title":"Receive Period End Amount LCY","type":"number"},"PayPeriodAmount":{"title":"Pay Period End Amount","type":"number"},"PayPeriodAmountLCY":{"title":"Pay Period End Amount LCY","type":"number"},"ReceivePrincipalAmount":{"title":"Receive Amount","type":["number","null"]},"PayPrincipalAmount":{"title":"Pay Amount","type":["number","null"]},"ReceiveAmortizationAmount":{"title":"Receive Amortization Amount","type":"number"},"ReceiveAmortizationAmountLCY":{"title":"Receive Amortization Amount LCY","type":"number"},"PayAmortizationAmount":{"title":"Pay Amortization Amount","type":"number"},"PayAmortizationAmountLCY":{"title":"Pay Amortization Amount LCY","type":"number"},"TotalMTMAmount":{"title":"MTM Amount","type":["number","null"]},"TotalMTMAmountCCY":{"title":"MTM Amount CCY","type":["string","null"]},"TotalMTMAmountLCY":{"title":"MTM Amount LCY","type":["number","null"]},"TotalMTMAmountLCYCode":{"title":"MTM Amount LCY Code","type":["string","null"]},"WeakAmountLCY":{"title":"Weak Amount LCY","type":["number","null"]},"WeakAmountCCY":{"title":"Weak Amount CCY","type":["string","null"]},"TaxAmount":{"title":"Tax Amount","type":"number"},"PayCurrency":{"title":"Pay Currency","type":["string","null"]},"ReceiveCurrency":{"title":"Receive Currency","type":["string","null"]},"LocalCCY":{"title":"Local CCY","type":["string","null"]},"LogicalDate":{"title":"Logical Date","type":"string","format":"date-time"},"NextWorkingLogicalDate":{"title":"Next Working Logical Date","type":"string","format":"date-time"},"PreviousWorkingLogicalDate":{"title":"Previous Working Logical Date","type":"string","format":"date-time"},"ExternalCustomerId":{"title":"External Customer Id","type":["string","null"]},"TxnReference":{"title":"Transaction Reference","description":"Transaction String Reference","type":["string","null"]},"TxnNo":{"title":"Transaction Number","type":"integer"},"AccountingGenerationDate":{"title":"Accounting Generation Date","type":"string","format":"date-time"},"Comment":{"title":"Comment","type":["string","null"]},"ApplicationName":{"title":"Application Name","type":["string","null"]},"TemplateId":{"title":"Template Id","type":"integer"},"PathRuleId":{"title":"Path Rule Id","type":"integer"}},"required":["NetPeriodEndAmount","NetPeriodEndAmountLCY","ReceivePeriodAmount","ReceivePeriodAmountLCY","PayPeriodAmount","PayPeriodAmountLCY","ReceivePrincipalAmount","PayPrincipalAmount","TotalMTMAmount","TotalMTMAmountCCY","TotalMTMAmountLCY","TotalMTMAmountLCYCode","WeakAmountLCY","WeakAmountCCY","TaxAmount","PayCurrency","ReceiveCurrency","LocalCCY","LogicalDate","NextWorkingLogicalDate","PreviousWorkingLogicalDate","ExternalCustomerId","TxnReference","TxnNo","AccountingGenerationDate","Comment","ApplicationName","TemplateId","PathRuleId"]}',
                    StateId    = 26,
                    StateDate  = @stateDate,
                    StateMaker = @stateMaker
                WHERE Name = N'Derivative Swap';
            END
        --#endregion
        ------------------------------------------------------------------------------------------------------------------------

        ------------------------------------------------------------------------------------------------------------------------
        -- Accounting Engine Event Type
        ------------------------------------------------------------------------------------------------------------------------
        --#region AccEngineEventType
        IF NOT EXISTS (SELECT 1
                       FROM dbo.AccEngineEventType
                       WHERE Code = N'OnAmortization')
            BEGIN
                INSERT INTO dbo.AccEngineEventType (Name, Code)
                VALUES (N'OnAmortization', N'OnAmortization');
            END;
        --#endregion
        ------------------------------------------------------------------------------------------------------------------------
        ------------------------------------------------------------------------------------------------------------------------
        -- Accounting Engine Component Type
        ------------------------------------------------------------------------------------------------------------------------
        --#region AccEngineComponentType
        IF NOT EXISTS (SELECT 1
                       FROM dbo.AccEngineComponentType
                       WHERE Name = N'Amortization Payment Incoming'
                         AND Code = N'600')
        BEGIN
            INSERT INTO dbo.AccEngineComponentType (Name, Code, StateId, StateDate, StateMaker)
            VALUES (N'Amortization Payment Incoming', N'600', @stateId, @stateDate, @stateDate);
        END;

        IF NOT EXISTS (SELECT 1
                       FROM dbo.AccEngineComponentType
                       WHERE Name = N'Amortization Payment Outgoing'
                         AND Code = N'601')
        BEGIN
            INSERT INTO dbo.AccEngineComponentType (Name, Code, StateId, StateDate, StateMaker)
            VALUES (N'Amortization Payment Outgoing', N'601', @stateId, @stateDate, @stateDate);
        END;
        --#endregion
    END

    /********** 3. STEP: IRS LCYRLCYP AMORTIZATION **************************/
    BEGIN
        PRINT 'IRS LCYRLCYP Amortization Started...';
  
        --#region AccEngineEvent
        ------------------------------------------------------------------------------------------------------------------------
        -- Event IRS LCYRLCYP OnAmortization
        ------------------------------------------------------------------------------------------------------------------------
        IF NOT EXISTS(SELECT 1
                      FROM dbo.accEngineEvent
                      WHERE ItemId = @dvIRSLCYRLCYPItemId
                        AND EventTypeCode = N'OnAmortization')
            BEGIN
                INSERT INTO dbo.AccEngineEvent (Id, ItemId, EventTypeCode, ModifiedBy, ModifiedDate,
                                                EventDescriptionDynamicRuleId)
                OUTPUT inserted.Id INTO @tempTable
                VALUES (@lastAccEngineEventId, @dvIRSLCYRLCYPItemId, N'OnAmortization', @stateMaker, @stateDate, null);
            
                SELECT @dvAmortizationEventId = Id FROM @tempTable;
                DELETE FROM @tempTable
                SELECT @lastAccEngineEventId = @lastAccEngineEventId + 1
            END
        ELSE
            BEGIN
                SELECT @dvAmortizationEventId = Id
                FROM dbo.AccEngineEvent
                WHERE ItemId = @dvIRSLCYRLCYPItemId
                  AND EventTypeCode = N'OnAmortization'
            END
        --#endregion
        ------------------------------------------------------------------------------------------------------------------------

        ------------------------------------------------------------------------------------------------------------------------
        --#region AccEngineGroup
        ------------------------------------------------------------------------------------------------------------------------
        -- Group OnAmortization
        ------------------------------------------------------------------------------------------------------------------------
        IF NOT EXISTS(SELECT 1
                        FROM dbo.accEngineGroup
                        WHERE EventId = @dvAmortizationEventId
                        AND ValidationRuleId is null)
            BEGIN
                INSERT INTO dbo.AccEngineGroup (Id, EventId, ValidationRuleId, [Order],
                                                ModifiedBy,
                                                ModifiedDate,
                                                StateId,
                                                StateDate,
                                                StateMaker)
                OUTPUT inserted.Id INTO @tempTable
                VALUES (@lastAccEngineGroupId, @dvAmortizationEventId,
                        null, 1,
                        @stateMaker,
                        @stateDate,
                        @StateId,
                        @stateDate,
                        @stateMaker);
                SELECT @dvAmortizationEventGroupId = Id FROM @tempTable;
                DELETE FROM @tempTable
                SELECT @lastAccEngineGroupId = @lastAccEngineGroupId + 1
            END
        ELSE
            BEGIN
                SELECT @dvAmortizationEventGroupId = Id
                FROM dbo.AccEngineGroup
                WHERE EventId = @dvAmortizationEventId
                    AND ValidationRuleId is null
            END
        --#endregion   
        ------------------------------------------------------------------------------------------------------------------------

        ------------------------------------------------------------------------------------------------------------------------
        --#region AccEngineComponent
        ------------------------------------------------------------------------------------------------------------------------
        -- Component Amortization Receive
        ------------------------------------------------------------------------------------------------------------------------
        IF NOT EXISTS (SELECT 1
                        FROM dbo.accEngineComponent
                        WHERE GroupId = @dvAmortizationEventGroupId
                            AND ValidationRuleId = @dynamicRuleIdReceivePaymentDateEqualLogicalDate
                            AND ComponentTypeCode = @accComponentCodeMaturityDateContingent)
            BEGIN
                INSERT INTO dbo.AccEngineComponent (Id, GroupId, ComponentTypeCode, ValidationRuleId, [Order],
                                                    ModifiedBy,
                                                    ModifiedDate)
                OUTPUT inserted.Id INTO @tempTable
                VALUES (@lastAccEngineComponentId, @dvAmortizationEventGroupId, @accComponentCodeMaturityDateContingent,
                        @dynamicRuleIdReceivePaymentDateEqualLogicalDate,
                        1,
                        @stateMaker,
                        @stateDate);
                SELECT @dvAmortizationEventGroupComponentReceiveId = Id FROM @tempTable;
                DELETE FROM @tempTable
                SELECT @lastAccEngineComponentId = @lastAccEngineComponentId + 1
            END
        ELSE
            BEGIN
                SELECT @dvAmortizationEventGroupComponentReceiveId = Id
                FROM dbo.AccEngineComponent
                WHERE GroupId = @dvAmortizationEventGroupId
                    AND ValidationRuleId = @dynamicRuleIdReceivePaymentDateEqualLogicalDate
                    AND ComponentTypeCode = @accComponentCodeMaturityDateContingent
            END

        ------------------------------------------------------------------------------------------------------------------------
        -- Component Amortization Pay
        ------------------------------------------------------------------------------------------------------------------------
        IF NOT EXISTS (SELECT 1
                        FROM dbo.accEngineComponent
                        WHERE GroupId = @dvAmortizationEventGroupId
                            AND ValidationRuleId = @dynamicRuleIdPayPaymentDateEqualLogicalDate
                            AND ComponentTypeCode = @accComponentCodeMaturityDateContingent)
            BEGIN
                INSERT INTO dbo.AccEngineComponent (Id, GroupId, ComponentTypeCode, ValidationRuleId, [Order],
                                                    ModifiedBy,
                                                    ModifiedDate)
                OUTPUT inserted.Id INTO @tempTable
                VALUES (@lastAccEngineComponentId, @dvAmortizationEventGroupId, @accComponentCodeMaturityDateContingent,
                        @dynamicRuleIdPayPaymentDateEqualLogicalDate,
                        1,
                        @stateMaker,
                        @stateDate);
                SELECT @dvAmortizationEventGroupComponentPayId = Id FROM @tempTable;
                DELETE FROM @tempTable
                SELECT @lastAccEngineComponentId = @lastAccEngineComponentId + 1
            END
        ELSE
            BEGIN
                SELECT @dvAmortizationEventGroupComponentPayId = Id
                FROM dbo.AccEngineComponent
                WHERE GroupId = @dvAmortizationEventGroupId
                    AND ValidationRuleId = @dynamicRuleIdPayPaymentDateEqualLogicalDate
                    AND ComponentTypeCode = @accComponentCodeMaturityDateContingent
            END
        ------------------------------------------------------------------------------------------------------------------------
        --#endregion 
        ------------------------------------------------------------------------------------------------------------------------

        ------------------------------------------------------------------------------------------------------------------------
        --#region AccEngineAccountRule
        ------------------------------------------------------------------------------------------------------------------------
        -- Rule MatPayContingent, MatPayContingentOffset
        ------------------------------------------------------------------------------------------------------------------------
        IF NOT EXISTS(SELECT 1
                        FROM dbo.accEngineAccountRule
                        WHERE ComponentId = @dvAmortizationEventGroupComponentPayId
                        AND GLCode = N'MatPayContingent')
        BEGIN
            INSERT INTO dbo.AccEngineAccountRule(Id, ComponentId, GLCode, CustomerCodeSource, CustomerAccountCodeSource,
                                                    DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                    ValueDateSource, TxnDateSource, CcySource, FcySource, LcyEqvtSource,
                                                    FcyAmtSource, ReverseRebook, CommentSource, CommentRuleId, ModifiedBy,
                                                    ModifiedDate, ReverseTxnDateSource, ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @dvAmortizationEventGroupComponentPayId, N'MatPayContingent',
                    null,
                    null,
                    N'Debit', null, N'PayAmortizationAmount', N'TxnNo', N'PayValueDate', N'LogicalDate', N'PayCurrency',
                    N'PayCurrency', N'PayAmortizationAmount', N'PayAmortizationAmount', 0, null, null, @stateMaker,
                    @stateDate, null, null);

            SELECT @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        END

        IF NOT EXISTS(SELECT 1
                        FROM dbo.accEngineAccountRule
                        WHERE ComponentId = @dvAmortizationEventGroupComponentPayId
                        AND GLCode = N'MatPayContingentOffset')
        BEGIN
            INSERT INTO dbo.AccEngineAccountRule(Id, ComponentId, GLCode, CustomerCodeSource, CustomerAccountCodeSource,
                                                    DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                    ValueDateSource, TxnDateSource, CcySource, FcySource, LcyEqvtSource,
                                                    FcyAmtSource, ReverseRebook, CommentSource, CommentRuleId, ModifiedBy,
                                                    ModifiedDate, ReverseTxnDateSource, ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @dvAmortizationEventGroupComponentPayId, N'MatPayContingentOffset',
                    null,
                    null,
                    N'Credit', null, N'PayAmortizationAmount', N'TxnNo', N'PayValueDate', N'LogicalDate', N'PayCurrency',
                    N'PayCurrency', N'PayAmortizationAmount', N'PayAmortizationAmount', 0, null, null, @stateMaker,
                    @stateDate, null, null);

            SELECT @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        END

        ------------------------------------------------------------------------------------------------------------------------
        -- Rule MatRecContingent, MatRecContingentOffset
        ------------------------------------------------------------------------------------------------------------------------
        IF NOT EXISTS(SELECT 1
                        FROM dbo.accEngineAccountRule
                        WHERE ComponentId = @dvAmortizationEventGroupComponentReceiveId
                        AND GLCode = N'MatRecContingent')
        BEGIN
            INSERT INTO dbo.AccEngineAccountRule(Id, ComponentId, GLCode, CustomerCodeSource, CustomerAccountCodeSource,
                                                    DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                    ValueDateSource, TxnDateSource, CcySource, FcySource, LcyEqvtSource,
                                                    FcyAmtSource, ReverseRebook, CommentSource, CommentRuleId, ModifiedBy,
                                                    ModifiedDate, ReverseTxnDateSource, ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @dvAmortizationEventGroupComponentReceiveId, N'MatRecContingent',
                    null,
                    null,
                    N'Credit', null, N'ReceiveAmortizationAmount', N'TxnNo', N'LogicalDate', N'LogicalDate', N'ReceiveCurrency',
                    N'ReceiveCurrency', N'ReceiveAmortizationAmount', N'ReceiveAmortizationAmount', 0, null, null, @stateMaker,
                    @stateDate, null, null);

            SELECT @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        END

        IF NOT EXISTS(SELECT 1
                        FROM dbo.accEngineAccountRule
                        WHERE ComponentId = @dvAmortizationEventGroupComponentReceiveId
                        AND GLCode = N'MatRecContingentOffset')
        BEGIN
            INSERT INTO dbo.AccEngineAccountRule(Id, ComponentId, GLCode, CustomerCodeSource, CustomerAccountCodeSource,
                                                    DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                    ValueDateSource, TxnDateSource, CcySource, FcySource, LcyEqvtSource,
                                                    FcyAmtSource, ReverseRebook, CommentSource, CommentRuleId, ModifiedBy,
                                                    ModifiedDate, ReverseTxnDateSource, ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @dvAmortizationEventGroupComponentReceiveId, N'MatRecContingentOffset',
                    null,
                    null,
                    N'Debit', null, N'ReceiveAmortizationAmount', N'TxnNo', N'LogicalDate', N'LogicalDate', N'ReceiveCurrency',
                    N'ReceiveCurrency', N'ReceiveAmortizationAmount', N'ReceiveAmortizationAmount', 0, null, null, @stateMaker,
                    @stateDate, null, null);

            SELECT @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        END
        ------------------------------------------------------------------------------------------------------------------------
        --#endregion 
        ------------------------------------------------------------------------------------------------------------------------
    END   

    /********** 4. STEP: IRS FCYRFCYP AMORTIZATION **************************/
    BEGIN
        PRINT 'IRS FCYRFCYP Amortization Started...';

        ------------------------------------------------------------------------------------------------------------------------
        --#region AccEngineEvent
        ------------------------------------------------------------------------------------------------------------------------
        -- Event IRS FCYRFCYP OnAmortization
        ------------------------------------------------------------------------------------------------------------------------   
        IF NOT EXISTS(SELECT 1
                      FROM dbo.accEngineEvent
                      WHERE ItemId = @dvIRSFCYRFCYPItemId
                        AND EventTypeCode = N'OnAmortization')
            BEGIN
                INSERT INTO dbo.AccEngineEvent (Id, ItemId, EventTypeCode, ModifiedBy, ModifiedDate,
                                                EventDescriptionDynamicRuleId)
                OUTPUT inserted.Id INTO @tempTable
                VALUES (@lastAccEngineEventId, @dvIRSFCYRFCYPItemId, N'OnAmortization', @stateMaker, @stateDate, null);
            
                SELECT @dvAmortizationEventId = Id FROM @tempTable;
                DELETE FROM @tempTable
                SELECT @lastAccEngineEventId = @lastAccEngineEventId + 1
            END
        ELSE
            BEGIN
                SELECT @dvAmortizationEventId = Id
                FROM dbo.AccEngineEvent
                WHERE ItemId = @dvIRSFCYRFCYPItemId
                  AND EventTypeCode = N'OnAmortization'
            END
        --#endregion
        ------------------------------------------------------------------------------------------------------------------------

        ------------------------------------------------------------------------------------------------------------------------
        --#region AccEngineGroup
        ------------------------------------------------------------------------------------------------------------------------
        -- Group OnAmortization
        ------------------------------------------------------------------------------------------------------------------------
        IF NOT EXISTS(SELECT 1
                        FROM dbo.accEngineGroup
                        WHERE EventId = @dvAmortizationEventId
                        AND ValidationRuleId is null)
            BEGIN
                INSERT INTO dbo.AccEngineGroup (Id, EventId, ValidationRuleId, [Order],
                                                ModifiedBy,
                                                ModifiedDate,
                                                StateId,
                                                StateDate,
                                                StateMaker)
                OUTPUT inserted.Id INTO @tempTable
                VALUES (@lastAccEngineGroupId, @dvAmortizationEventId,
                        null, 1,
                        @stateMaker,
                        @stateDate,
                        @StateId,
                        @stateDate,
                        @stateMaker);
                SELECT @dvAmortizationEventGroupId = Id FROM @tempTable;
                DELETE FROM @tempTable
                SELECT @lastAccEngineGroupId = @lastAccEngineGroupId + 1
            END
        ELSE
            BEGIN
                SELECT @dvAmortizationEventGroupId = Id
                FROM dbo.AccEngineGroup
                WHERE EventId = @dvAmortizationEventId
                    AND ValidationRuleId is null
            END
        --#endregion   
        ------------------------------------------------------------------------------------------------------------------------

        ------------------------------------------------------------------------------------------------------------------------
        --#region AccEngineComponent
        ------------------------------------------------------------------------------------------------------------------------
        -- Component Amortization Receive
        ------------------------------------------------------------------------------------------------------------------------
        IF NOT EXISTS (SELECT 1
                        FROM dbo.accEngineComponent
                        WHERE GroupId = @dvAmortizationEventGroupId
                            AND ValidationRuleId = @dynamicRuleIdReceivePaymentDateEqualLogicalDate
                            AND ComponentTypeCode = @accComponentCodeMaturityDateContingent)
            BEGIN
                INSERT INTO dbo.AccEngineComponent (Id, GroupId, ComponentTypeCode, ValidationRuleId, [Order],
                                                    ModifiedBy,
                                                    ModifiedDate)
                OUTPUT inserted.Id INTO @tempTable
                VALUES (@lastAccEngineComponentId, @dvAmortizationEventGroupId, @accComponentCodeMaturityDateContingent,
                        @dynamicRuleIdReceivePaymentDateEqualLogicalDate,
                        1,
                        @stateMaker,
                        @stateDate);
                SELECT @dvAmortizationEventGroupComponentReceiveId = Id FROM @tempTable;
                DELETE FROM @tempTable
                SELECT @lastAccEngineComponentId = @lastAccEngineComponentId + 1
            END
        ELSE
            BEGIN
                SELECT @dvAmortizationEventGroupComponentReceiveId = Id
                FROM dbo.AccEngineComponent
                WHERE GroupId = @dvAmortizationEventGroupId
                    AND ValidationRuleId = @dynamicRuleIdReceivePaymentDateEqualLogicalDate
                    AND ComponentTypeCode = @accComponentCodeMaturityDateContingent
            END

        ------------------------------------------------------------------------------------------------------------------------
        -- Component Amortization Pay
        ------------------------------------------------------------------------------------------------------------------------
        IF NOT EXISTS (SELECT 1
                        FROM dbo.accEngineComponent
                        WHERE GroupId = @dvAmortizationEventGroupId
                            AND ValidationRuleId = @dynamicRuleIdPayPaymentDateEqualLogicalDate
                            AND ComponentTypeCode = @accComponentCodeMaturityDateContingent)
            BEGIN
                INSERT INTO dbo.AccEngineComponent (Id, GroupId, ComponentTypeCode, ValidationRuleId, [Order],
                                                    ModifiedBy,
                                                    ModifiedDate)
                OUTPUT inserted.Id INTO @tempTable
                VALUES (@lastAccEngineComponentId, @dvAmortizationEventGroupId, @accComponentCodeMaturityDateContingent,
                        @dynamicRuleIdPayPaymentDateEqualLogicalDate,
                        1,
                        @stateMaker,
                        @stateDate);
                SELECT @dvAmortizationEventGroupComponentPayId = Id FROM @tempTable;
                DELETE FROM @tempTable
                SELECT @lastAccEngineComponentId = @lastAccEngineComponentId + 1
            END
        ELSE
            BEGIN
                SELECT @dvAmortizationEventGroupComponentPayId = Id
                FROM dbo.AccEngineComponent
                WHERE GroupId = @dvAmortizationEventGroupId
                    AND ValidationRuleId = @dynamicRuleIdPayPaymentDateEqualLogicalDate
                    AND ComponentTypeCode = @accComponentCodeMaturityDateContingent
            END
        ------------------------------------------------------------------------------------------------------------------------
        --#endregion 
        ------------------------------------------------------------------------------------------------------------------------

        ------------------------------------------------------------------------------------------------------------------------
        -- Accounting Engine Rule
        ------------------------------------------------------------------------------------------------------------------------
        --#region AccEngineAccountRule
        ------------------------------------------------------------------------------------------------------------------------
        -- Rule MatPayContingent, MatPayContingentOffset
        ------------------------------------------------------------------------------------------------------------------------
        IF NOT EXISTS(SELECT 1
                        FROM dbo.accEngineAccountRule
                        WHERE ComponentId = @dvAmortizationEventGroupComponentPayId
                        AND GLCode = N'MatPayContingent')
        BEGIN
            INSERT INTO dbo.AccEngineAccountRule(Id, ComponentId, GLCode, CustomerCodeSource, CustomerAccountCodeSource,
                                                    DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                    ValueDateSource, TxnDateSource, CcySource, FcySource, LcyEqvtSource,
                                                    FcyAmtSource, ReverseRebook, CommentSource, CommentRuleId, ModifiedBy,
                                                    ModifiedDate, ReverseTxnDateSource, ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @dvAmortizationEventGroupComponentPayId, N'MatPayContingent',
                    null,
                    null,
                    N'Debit', null, N'PayAmortizationAmount', N'TxnNo', N'PayValueDate', N'LogicalDate', N'PayCurrency',
                    N'PayCurrency', N'PayAmortizationAmount', N'PayAmortizationAmount', 0, null, null, @stateMaker,
                    @stateDate, null, null);

            SELECT @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        END

        IF NOT EXISTS(SELECT 1
                        FROM dbo.accEngineAccountRule
                        WHERE ComponentId = @dvAmortizationEventGroupComponentPayId
                        AND GLCode = N'MatPayContingentOffset')
        BEGIN
            INSERT INTO dbo.AccEngineAccountRule(Id, ComponentId, GLCode, CustomerCodeSource, CustomerAccountCodeSource,
                                                    DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                    ValueDateSource, TxnDateSource, CcySource, FcySource, LcyEqvtSource,
                                                    FcyAmtSource, ReverseRebook, CommentSource, CommentRuleId, ModifiedBy,
                                                    ModifiedDate, ReverseTxnDateSource, ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @dvAmortizationEventGroupComponentPayId, N'MatPayContingentOffset',
                    null,
                    null,
                    N'Credit', null, N'PayAmortizationAmount', N'TxnNo', N'PayValueDate', N'LogicalDate', N'PayCurrency',
                    N'PayCurrency', N'PayAmortizationAmount', N'PayAmortizationAmount', 0, null, null, @stateMaker,
                    @stateDate, null, null);

            SELECT @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        END

        ------------------------------------------------------------------------------------------------------------------------
        -- Rule MatRecContingent, MatRecContingentOffset
        ------------------------------------------------------------------------------------------------------------------------
        IF NOT EXISTS(SELECT 1
                        FROM dbo.accEngineAccountRule
                        WHERE ComponentId = @dvAmortizationEventGroupComponentReceiveId
                        AND GLCode = N'MatRecContingent')
        BEGIN
            INSERT INTO dbo.AccEngineAccountRule(Id, ComponentId, GLCode, CustomerCodeSource, CustomerAccountCodeSource,
                                                    DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                    ValueDateSource, TxnDateSource, CcySource, FcySource, LcyEqvtSource,
                                                    FcyAmtSource, ReverseRebook, CommentSource, CommentRuleId, ModifiedBy,
                                                    ModifiedDate, ReverseTxnDateSource, ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @dvAmortizationEventGroupComponentReceiveId, N'MatRecContingent',
                    null,
                    null,
                    N'Credit', null, N'ReceiveAmortizationAmount', N'TxnNo', N'PayValueDate', N'LogicalDate', N'ReceiveCurrency',
                    N'ReceiveCurrency', N'ReceiveAmortizationAmount', N'ReceiveAmortizationAmount', 0, null, null, @stateMaker,
                    @stateDate, null, null);

            SELECT @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        END

        IF NOT EXISTS(SELECT 1
                        FROM dbo.accEngineAccountRule
                        WHERE ComponentId = @dvAmortizationEventGroupComponentReceiveId
                        AND GLCode = N'MatRecContingentOffset')
        BEGIN
            INSERT INTO dbo.AccEngineAccountRule(Id, ComponentId, GLCode, CustomerCodeSource, CustomerAccountCodeSource,
                                                    DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                    ValueDateSource, TxnDateSource, CcySource, FcySource, LcyEqvtSource,
                                                    FcyAmtSource, ReverseRebook, CommentSource, CommentRuleId, ModifiedBy,
                                                    ModifiedDate, ReverseTxnDateSource, ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @dvAmortizationEventGroupComponentReceiveId, N'MatRecContingentOffset',
                    null,
                    null,
                    N'Debit', null, N'ReceiveAmortizationAmount', N'TxnNo', N'PayValueDate', N'LogicalDate', N'ReceiveCurrency',
                    N'ReceiveCurrency', N'ReceiveAmortizationAmount', N'ReceiveAmortizationAmount', 0, null, null, @stateMaker,
                    @stateDate, null, null);

            SELECT @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        END
    END

    /********** 5. STEP: CCS FCYRFCYP AMORTIZATION **************************/
    BEGIN
        PRINT 'CCS FCYRFCYP Amortization Started...';
  
        --#region AccEngineEvent
        ------------------------------------------------------------------------------------------------------------------------
        -- Event CCS FCYRFCYP OnAmortization
        ------------------------------------------------------------------------------------------------------------------------
        IF NOT EXISTS(SELECT 1
                      FROM dbo.accEngineEvent
                      WHERE ItemId = @dvCCSFCYRFCYPItemId
                        AND EventTypeCode = N'OnAmortization')
            BEGIN
                INSERT INTO dbo.AccEngineEvent (Id, ItemId, EventTypeCode, ModifiedBy, ModifiedDate,
                                                EventDescriptionDynamicRuleId)
                OUTPUT inserted.Id INTO @tempTable
                VALUES (@lastAccEngineEventId, @dvCCSFCYRFCYPItemId, N'OnAmortization', @stateMaker, @stateDate, null);
            
                SELECT @dvAmortizationEventId = Id FROM @tempTable;
                DELETE FROM @tempTable
                SELECT @lastAccEngineEventId = @lastAccEngineEventId + 1
            END
        ELSE
            BEGIN
                SELECT @dvAmortizationEventId = Id
                FROM dbo.AccEngineEvent
                WHERE ItemId = @dvCCSFCYRFCYPItemId
                  AND EventTypeCode = N'OnAmortization'
            END
        --#endregion
        ------------------------------------------------------------------------------------------------------------------------

        ------------------------------------------------------------------------------------------------------------------------
        --#region AccEngineGroup
        ------------------------------------------------------------------------------------------------------------------------
        -- Group OnAmortization
        ------------------------------------------------------------------------------------------------------------------------
        IF NOT EXISTS(SELECT 1
                        FROM dbo.accEngineGroup
                        WHERE EventId = @dvAmortizationEventId
                        AND ValidationRuleId is null)
            BEGIN
                INSERT INTO dbo.AccEngineGroup (Id, EventId, ValidationRuleId, [Order],
                                                ModifiedBy,
                                                ModifiedDate,
                                                StateId,
                                                StateDate,
                                                StateMaker)
                OUTPUT inserted.Id INTO @tempTable
                VALUES (@lastAccEngineGroupId, @dvAmortizationEventId,
                        null, 1,
                        @stateMaker,
                        @stateDate,
                        @StateId,
                        @stateDate,
                        @stateMaker);
                SELECT @dvAmortizationEventGroupId = Id FROM @tempTable;
                DELETE FROM @tempTable
                SELECT @lastAccEngineGroupId = @lastAccEngineGroupId + 1
            END
        ELSE
            BEGIN
                SELECT @dvAmortizationEventGroupId = Id
                FROM dbo.AccEngineGroup
                WHERE EventId = @dvAmortizationEventId
                    AND ValidationRuleId is null
            END
        --#endregion   
        ------------------------------------------------------------------------------------------------------------------------

        ------------------------------------------------------------------------------------------------------------------------
        --#region AccEngineComponent
        ------------------------------------------------------------------------------------------------------------------------
        -- Component Receive Maturity Date Contingent
        ------------------------------------------------------------------------------------------------------------------------
        IF NOT EXISTS (SELECT 1
                        FROM dbo.accEngineComponent
                        WHERE GroupId = @dvAmortizationEventGroupId
                            AND ValidationRuleId = @dynamicRuleIdReceivePaymentDateEqualLogicalDate
                            AND ComponentTypeCode = @accComponentCodeMaturityDateContingent)
            BEGIN
                INSERT INTO dbo.AccEngineComponent (Id, GroupId, ComponentTypeCode, ValidationRuleId, [Order],
                                                    ModifiedBy,
                                                    ModifiedDate)
                OUTPUT inserted.Id INTO @tempTable
                VALUES (@lastAccEngineComponentId, @dvAmortizationEventGroupId, @accComponentCodeMaturityDateContingent,
                        @dynamicRuleIdReceivePaymentDateEqualLogicalDate,
                        2,
                        @stateMaker,
                        @stateDate);
                SELECT @dvAmortizationEventGroupComponentReceiveId = Id FROM @tempTable;
                DELETE FROM @tempTable
                SELECT @lastAccEngineComponentId = @lastAccEngineComponentId + 1
            END
        ELSE
            BEGIN
                SELECT @dvAmortizationEventGroupComponentReceiveId = Id
                FROM dbo.AccEngineComponent
                WHERE GroupId = @dvAmortizationEventGroupId
                    AND ValidationRuleId = @dynamicRuleIdReceivePaymentDateEqualLogicalDate
                    AND ComponentTypeCode = @accComponentCodeMaturityDateContingent
            END
        ------------------------------------------------------------------------------------------------------------------------
        --#endregion 
        ------------------------------------------------------------------------------------------------------------------------

        ------------------------------------------------------------------------------------------------------------------------
        --#region AccEngineAccountRule
        ------------------------------------------------------------------------------------------------------------------------
        -- Rule MatRecContingent, MatRecContingentOffset
        ------------------------------------------------------------------------------------------------------------------------
        IF NOT EXISTS(SELECT 1
                        FROM dbo.accEngineAccountRule
                        WHERE ComponentId = @dvAmortizationEventGroupComponentReceiveId
                        AND GLCode = N'MatRecContingent')
        BEGIN
            INSERT INTO dbo.AccEngineAccountRule(Id, ComponentId, GLCode, CustomerCodeSource, CustomerAccountCodeSource,
                                                    DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                    ValueDateSource, TxnDateSource, CcySource, FcySource, LcyEqvtSource,
                                                    FcyAmtSource, ReverseRebook, CommentSource, CommentRuleId, ModifiedBy,
                                                    ModifiedDate, ReverseTxnDateSource, ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @dvAmortizationEventGroupComponentReceiveId, N'MatRecContingent',
                    null,
                    null,
                    N'Credit', null, N'ReceiveAmortizationAmount', N'TxnNo', N'LogicalDate', N'LogicalDate', N'ReceiveCurrency',
                    N'ReceiveCurrency', N'ReceiveAmortizationAmount', N'ReceiveAmortizationAmount', 0, null, null, @stateMaker,
                    @stateDate, null, null);

            SELECT @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        END

        IF NOT EXISTS(SELECT 1
                        FROM dbo.accEngineAccountRule
                        WHERE ComponentId = @dvAmortizationEventGroupComponentReceiveId
                        AND GLCode = N'MatRecContingentOffset')
        BEGIN
            INSERT INTO dbo.AccEngineAccountRule(Id, ComponentId, GLCode, CustomerCodeSource, CustomerAccountCodeSource,
                                                    DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                    ValueDateSource, TxnDateSource, CcySource, FcySource, LcyEqvtSource,
                                                    FcyAmtSource, ReverseRebook, CommentSource, CommentRuleId, ModifiedBy,
                                                    ModifiedDate, ReverseTxnDateSource, ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @dvAmortizationEventGroupComponentReceiveId, N'MatRecContingentOffset',
                    null,
                    null,
                    N'Debit', null, N'ReceiveAmortizationAmount', N'TxnNo', N'LogicalDate', N'LogicalDate', N'ReceiveCurrency',
                    N'ReceiveCurrency', N'ReceiveAmortizationAmount', N'ReceiveAmortizationAmount', 0, null, null, @stateMaker,
                    @stateDate, null, null);

            SELECT @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        END
        ------------------------------------------------------------------------------------------------------------------------
        --#endregion 
        ------------------------------------------------------------------------------------------------------------------------

        ------------------------------------------------------------------------------------------------------------------------
        -- Component Receive Amortization Payment
        ------------------------------------------------------------------------------------------------------------------------
        IF NOT EXISTS (SELECT 1
                        FROM dbo.accEngineComponent
                        WHERE GroupId = @dvAmortizationEventGroupId
                            AND ValidationRuleId = @dynamicRuleIdReceivePaymentDateEqualLogicalDate
                            AND ComponentTypeCode = N'600')
            BEGIN
                INSERT INTO dbo.AccEngineComponent (Id, GroupId, ComponentTypeCode, ValidationRuleId, [Order],
                                                    ModifiedBy,
                                                    ModifiedDate)
                OUTPUT inserted.Id INTO @tempTable
                VALUES (@lastAccEngineComponentId, @dvAmortizationEventGroupId, N'600',
                        @dynamicRuleIdReceivePaymentDateEqualLogicalDate,
                        1,
                        @stateMaker,
                        @stateDate);
                SELECT @dvAmortizationEventGroupComponentReceiveId = Id FROM @tempTable;
                DELETE FROM @tempTable
                SELECT @lastAccEngineComponentId = @lastAccEngineComponentId + 1
            END
        ELSE
            BEGIN
                SELECT @dvAmortizationEventGroupComponentReceiveId = Id
                FROM dbo.AccEngineComponent
                WHERE GroupId = @dvAmortizationEventGroupId
                    AND ValidationRuleId = @dynamicRuleIdReceivePaymentDateEqualLogicalDate
                    AND ComponentTypeCode = N'600'
            END
        ------------------------------------------------------------------------------------------------------------------------
        --#endregion 
        ------------------------------------------------------------------------------------------------------------------------

        ------------------------------------------------------------------------------------------------------------------------
        --#region AccEngineAccountRule
        ------------------------------------------------------------------------------------------------------------------------
        -- Rule IncomingPaymentFCY, FXPositionRec, FXPositionLCY
        ------------------------------------------------------------------------------------------------------------------------
        IF NOT EXISTS(SELECT 1
                        FROM dbo.accEngineAccountRule
                        WHERE ComponentId = @dvAmortizationEventGroupComponentReceiveId
                        AND GLCode = N'IncomingPaymentFCY')
        BEGIN
            INSERT INTO dbo.AccEngineAccountRule(Id, ComponentId, GLCode, CustomerCodeSource, CustomerAccountCodeSource,
                                                    DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                    ValueDateSource, TxnDateSource, CcySource, FcySource, LcyEqvtSource,
                                                    FcyAmtSource, ReverseRebook, CommentSource, CommentRuleId, ModifiedBy,
                                                    ModifiedDate, ReverseTxnDateSource, ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @dvAmortizationEventGroupComponentReceiveId, N'IncomingPaymentFCY',
                    null,
                    null,
                    N'Debit', null, N'ReceiveAmortizationAmount', N'TxnNo', N'LogicalDate', N'LogicalDate', N'ReceiveCurrency',
                    N'ReceiveCurrency', N'ReceiveAmortizationAmount', N'ReceiveAmortizationAmount', 0, null, null, @stateMaker,
                    @stateDate, null, null);

            SELECT @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        END

        IF NOT EXISTS(SELECT 1
                        FROM dbo.accEngineAccountRule
                        WHERE ComponentId = @dvAmortizationEventGroupComponentReceiveId
                        AND GLCode = N'FXPositionRec')
        BEGIN
            INSERT INTO dbo.AccEngineAccountRule(Id, ComponentId, GLCode, CustomerCodeSource, CustomerAccountCodeSource,
                                                    DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                    ValueDateSource, TxnDateSource, CcySource, FcySource, LcyEqvtSource,
                                                    FcyAmtSource, ReverseRebook, CommentSource, CommentRuleId, ModifiedBy,
                                                    ModifiedDate, ReverseTxnDateSource, ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @dvAmortizationEventGroupComponentReceiveId, N'FXPositionRec',
                    null,
                    null,
                    N'Credit', null, N'ReceiveAmortizationAmount', N'TxnNo', N'LogicalDate', N'LogicalDate', N'ReceiveCurrency',
                    N'ReceiveCurrency', N'ReceiveAmortizationAmount', N'ReceiveAmortizationAmount', 0, null, null, @stateMaker,
                    @stateDate, null, null);

            SELECT @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        END

        IF NOT EXISTS(SELECT 1
                        FROM dbo.accEngineAccountRule
                        WHERE ComponentId = @dvAmortizationEventGroupComponentReceiveId
                        AND GLCode = N'FXPositionLCY')
        BEGIN
            INSERT INTO dbo.AccEngineAccountRule(Id, ComponentId, GLCode, CustomerCodeSource, CustomerAccountCodeSource,
                                                    DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                    ValueDateSource, TxnDateSource, CcySource, FcySource, LcyEqvtSource,
                                                    FcyAmtSource, ReverseRebook, CommentSource, CommentRuleId, ModifiedBy,
                                                    ModifiedDate, ReverseTxnDateSource, ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @dvAmortizationEventGroupComponentReceiveId, N'FXPositionLCY',
                    null,
                    null,
                    N'Debit', null, N'WeakAmountLCY', N'TxnNo', N'LogicalDate', N'LogicalDate', N'LocalCCY',
                    N'LocalCCY', N'WeakAmountLCY', N'WeakAmountLCY', 0, null, null, @stateMaker,
                    @stateDate, null, null);

            SELECT @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        END
        ------------------------------------------------------------------------------------------------------------------------
        --#endregion 
        ------------------------------------------------------------------------------------------------------------------------

        ------------------------------------------------------------------------------------------------------------------------
        --#region AccEngineComponent
        ------------------------------------------------------------------------------------------------------------------------
        -- Component Pay Maturity Date Contingent
        ------------------------------------------------------------------------------------------------------------------------
        IF NOT EXISTS (SELECT 1
                        FROM dbo.accEngineComponent
                        WHERE GroupId = @dvAmortizationEventGroupId
                            AND ValidationRuleId = @dynamicRuleIdPayPaymentDateEqualLogicalDate
                            AND ComponentTypeCode = @accComponentCodeMaturityDateContingent)
            BEGIN
                INSERT INTO dbo.AccEngineComponent (Id, GroupId, ComponentTypeCode, ValidationRuleId, [Order],
                                                    ModifiedBy,
                                                    ModifiedDate)
                OUTPUT inserted.Id INTO @tempTable
                VALUES (@lastAccEngineComponentId, @dvAmortizationEventGroupId, @accComponentCodeMaturityDateContingent,
                        @dynamicRuleIdPayPaymentDateEqualLogicalDate,
                        4,
                        @stateMaker,
                        @stateDate);
                SELECT @dvAmortizationEventGroupComponentPayId = Id FROM @tempTable;
                DELETE FROM @tempTable
                SELECT @lastAccEngineComponentId = @lastAccEngineComponentId + 1
            END
        ELSE
            BEGIN
                SELECT @dvAmortizationEventGroupComponentPayId = Id
                FROM dbo.AccEngineComponent
                WHERE GroupId = @dvAmortizationEventGroupId
                    AND ValidationRuleId = @dynamicRuleIdPayPaymentDateEqualLogicalDate
                    AND ComponentTypeCode = @accComponentCodeMaturityDateContingent
            END
        ------------------------------------------------------------------------------------------------------------------------
        --#endregion 
        ------------------------------------------------------------------------------------------------------------------------

        ------------------------------------------------------------------------------------------------------------------------
        --#region AccEngineAccountRule
        ------------------------------------------------------------------------------------------------------------------------
        -- Rule MatPayContingent, MatPayContingentOffset
        ------------------------------------------------------------------------------------------------------------------------
        IF NOT EXISTS(SELECT 1
                        FROM dbo.accEngineAccountRule
                        WHERE ComponentId = @dvAmortizationEventGroupComponentPayId
                        AND GLCode = N'MatPayContingent')
        BEGIN
            INSERT INTO dbo.AccEngineAccountRule(Id, ComponentId, GLCode, CustomerCodeSource, CustomerAccountCodeSource,
                                                    DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                    ValueDateSource, TxnDateSource, CcySource, FcySource, LcyEqvtSource,
                                                    FcyAmtSource, ReverseRebook, CommentSource, CommentRuleId, ModifiedBy,
                                                    ModifiedDate, ReverseTxnDateSource, ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @dvAmortizationEventGroupComponentPayId, N'MatPayContingent',
                    null,
                    null,
                    N'Debit', null, N'PayAmortizationAmount', N'TxnNo', N'PayValueDate', N'LogicalDate', N'PayCurrency',
                    N'PayCurrency', N'PayAmortizationAmount', N'PayAmortizationAmount', 0, null, null, @stateMaker,
                    @stateDate, null, null);

            SELECT @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        END

        IF NOT EXISTS(SELECT 1
                        FROM dbo.accEngineAccountRule
                        WHERE ComponentId = @dvAmortizationEventGroupComponentPayId
                        AND GLCode = N'MatPayContingentOffset')
        BEGIN
            INSERT INTO dbo.AccEngineAccountRule(Id, ComponentId, GLCode, CustomerCodeSource, CustomerAccountCodeSource,
                                                    DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                    ValueDateSource, TxnDateSource, CcySource, FcySource, LcyEqvtSource,
                                                    FcyAmtSource, ReverseRebook, CommentSource, CommentRuleId, ModifiedBy,
                                                    ModifiedDate, ReverseTxnDateSource, ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @dvAmortizationEventGroupComponentPayId, N'MatPayContingentOffset',
                    null,
                    null,
                    N'Credit', null, N'PayAmortizationAmount', N'TxnNo', N'PayValueDate', N'LogicalDate', N'PayCurrency',
                    N'PayCurrency', N'PayAmortizationAmount', N'PayAmortizationAmount', 0, null, null, @stateMaker,
                    @stateDate, null, null);

            SELECT @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        END
        ------------------------------------------------------------------------------------------------------------------------
        --#endregion 
        ------------------------------------------------------------------------------------------------------------------------

        ------------------------------------------------------------------------------------------------------------------------
        --#region AccEngineComponent
        ------------------------------------------------------------------------------------------------------------------------
        -- Component Pay Amortization Payment
        ------------------------------------------------------------------------------------------------------------------------
        IF NOT EXISTS (SELECT 1
                        FROM dbo.accEngineComponent
                        WHERE GroupId = @dvAmortizationEventGroupId
                            AND ValidationRuleId = @dynamicRuleIdPayPaymentDateEqualLogicalDate
                            AND ComponentTypeCode = N'601')
            BEGIN
                INSERT INTO dbo.AccEngineComponent (Id, GroupId, ComponentTypeCode, ValidationRuleId, [Order],
                                                    ModifiedBy,
                                                    ModifiedDate)
                OUTPUT inserted.Id INTO @tempTable
                VALUES (@lastAccEngineComponentId, @dvAmortizationEventGroupId, N'601',
                        @dynamicRuleIdPayPaymentDateEqualLogicalDate,
                        3,
                        @stateMaker,
                        @stateDate);
                SELECT @dvAmortizationEventGroupComponentPayId = Id FROM @tempTable;
                DELETE FROM @tempTable
                SELECT @lastAccEngineComponentId = @lastAccEngineComponentId + 1
            END
        ELSE
            BEGIN
                SELECT @dvAmortizationEventGroupComponentPayId = Id
                FROM dbo.AccEngineComponent
                WHERE GroupId = @dvAmortizationEventGroupId
                    AND ValidationRuleId = @dynamicRuleIdPayPaymentDateEqualLogicalDate
                    AND ComponentTypeCode = N'601'
            END
        ------------------------------------------------------------------------------------------------------------------------
        --#endregion 
        ------------------------------------------------------------------------------------------------------------------------

        ------------------------------------------------------------------------------------------------------------------------
        --#region AccEngineAccountRule
        ------------------------------------------------------------------------------------------------------------------------
        -- Rule OutgoingPaymentFCY, FXPositionPay, FXPositionLCY
        ------------------------------------------------------------------------------------------------------------------------
        IF NOT EXISTS(SELECT 1
                        FROM dbo.accEngineAccountRule
                        WHERE ComponentId = @dvAmortizationEventGroupComponentPayId
                        AND GLCode = N'OutgoingPaymentFCY')
        BEGIN
            INSERT INTO dbo.AccEngineAccountRule(Id, ComponentId, GLCode, CustomerCodeSource, CustomerAccountCodeSource,
                                                    DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                    ValueDateSource, TxnDateSource, CcySource, FcySource, LcyEqvtSource,
                                                    FcyAmtSource, ReverseRebook, CommentSource, CommentRuleId, ModifiedBy,
                                                    ModifiedDate, ReverseTxnDateSource, ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @dvAmortizationEventGroupComponentPayId, N'OutgoingPaymentFCY',
                    null,
                    null,
                    N'Credit', null, N'PayAmortizationAmount', N'TxnNo', N'PayValueDate', N'LogicalDate', N'PayCurrency',
                    N'PayCurrency', N'PayAmortizationAmount', N'PayAmortizationAmount', 0, null, null, @stateMaker,
                    @stateDate, null, null);

            SELECT @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        END

        IF NOT EXISTS(SELECT 1
                        FROM dbo.accEngineAccountRule
                        WHERE ComponentId = @dvAmortizationEventGroupComponentPayId
                        AND GLCode = N'FXPositionPay')
        BEGIN
            INSERT INTO dbo.AccEngineAccountRule(Id, ComponentId, GLCode, CustomerCodeSource, CustomerAccountCodeSource,
                                                    DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                    ValueDateSource, TxnDateSource, CcySource, FcySource, LcyEqvtSource,
                                                    FcyAmtSource, ReverseRebook, CommentSource, CommentRuleId, ModifiedBy,
                                                    ModifiedDate, ReverseTxnDateSource, ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @dvAmortizationEventGroupComponentPayId, N'FXPositionPay',
                    null,
                    null,
                    N'Debit', null, N'PayAmortizationAmount', N'TxnNo', N'PayValueDate', N'LogicalDate', N'PayCurrency',
                    N'PayCurrency', N'PayAmortizationAmount', N'PayAmortizationAmount', 0, null, null, @stateMaker,
                    @stateDate, null, null);

            SELECT @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        END

        IF NOT EXISTS(SELECT 1
                        FROM dbo.accEngineAccountRule
                        WHERE ComponentId = @dvAmortizationEventGroupComponentPayId
                        AND GLCode = N'FXPositionLCY')
        BEGIN
            INSERT INTO dbo.AccEngineAccountRule(Id, ComponentId, GLCode, CustomerCodeSource, CustomerAccountCodeSource,
                                                    DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                    ValueDateSource, TxnDateSource, CcySource, FcySource, LcyEqvtSource,
                                                    FcyAmtSource, ReverseRebook, CommentSource, CommentRuleId, ModifiedBy,
                                                    ModifiedDate, ReverseTxnDateSource, ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @dvAmortizationEventGroupComponentPayId, N'FXPositionLCY',
                    null,
                    null,
                    N'Credit', null, N'WeakAmountLCY', N'TxnNo', N'PayValueDate', N'LogicalDate', N'LocalCCY',
                    N'LocalCCY', N'WeakAmountLCY', N'WeakAmountLCY', 0, null, null, @stateMaker,
                    @stateDate, null, null);

            SELECT @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        END
        ------------------------------------------------------------------------------------------------------------------------
        --#endregion 
        ------------------------------------------------------------------------------------------------------------------------
    END

    /********** 6. STEP: CCS FCYRLCYP AMORTIZATION **************************/
    BEGIN
        PRINT 'CCS FCYRLCYP Amortization Started...';
  
        --#region AccEngineEvent
        ------------------------------------------------------------------------------------------------------------------------
        -- Event CCS FCYRLCYP OnAmortization
        ------------------------------------------------------------------------------------------------------------------------
        IF NOT EXISTS(SELECT 1
                      FROM dbo.accEngineEvent
                      WHERE ItemId = @dvCCSFCYRLCYPItemId
                        AND EventTypeCode = N'OnAmortization')
            BEGIN
                INSERT INTO dbo.AccEngineEvent (Id, ItemId, EventTypeCode, ModifiedBy, ModifiedDate,
                                                EventDescriptionDynamicRuleId)
                OUTPUT inserted.Id INTO @tempTable
                VALUES (@lastAccEngineEventId, @dvCCSFCYRLCYPItemId, N'OnAmortization', @stateMaker, @stateDate, null);
            
                SELECT @dvAmortizationEventId = Id FROM @tempTable;
                DELETE FROM @tempTable
                SELECT @lastAccEngineEventId = @lastAccEngineEventId + 1
            END
        ELSE
            BEGIN
                SELECT @dvAmortizationEventId = Id
                FROM dbo.AccEngineEvent
                WHERE ItemId = @dvCCSFCYRLCYPItemId
                  AND EventTypeCode = N'OnAmortization'
            END
        --#endregion
        ------------------------------------------------------------------------------------------------------------------------

        ------------------------------------------------------------------------------------------------------------------------
        --#region AccEngineGroup
        ------------------------------------------------------------------------------------------------------------------------
        -- Group OnAmortization
        ------------------------------------------------------------------------------------------------------------------------
        IF NOT EXISTS(SELECT 1
                        FROM dbo.accEngineGroup
                        WHERE EventId = @dvAmortizationEventId
                        AND ValidationRuleId is null)
            BEGIN
                INSERT INTO dbo.AccEngineGroup (Id, EventId, ValidationRuleId, [Order],
                                                ModifiedBy,
                                                ModifiedDate,
                                                StateId,
                                                StateDate,
                                                StateMaker)
                OUTPUT inserted.Id INTO @tempTable
                VALUES (@lastAccEngineGroupId, @dvAmortizationEventId,
                        null, 1,
                        @stateMaker,
                        @stateDate,
                        @StateId,
                        @stateDate,
                        @stateMaker);
                SELECT @dvAmortizationEventGroupId = Id FROM @tempTable;
                DELETE FROM @tempTable
                SELECT @lastAccEngineGroupId = @lastAccEngineGroupId + 1
            END
        ELSE
            BEGIN
                SELECT @dvAmortizationEventGroupId = Id
                FROM dbo.AccEngineGroup
                WHERE EventId = @dvAmortizationEventId
                    AND ValidationRuleId is null
            END
        --#endregion   
        ------------------------------------------------------------------------------------------------------------------------

        ------------------------------------------------------------------------------------------------------------------------
        --#region AccEngineComponent
        ------------------------------------------------------------------------------------------------------------------------
        -- Component Receive Maturity Date Contingent
        ------------------------------------------------------------------------------------------------------------------------
        IF NOT EXISTS (SELECT 1
                        FROM dbo.accEngineComponent
                        WHERE GroupId = @dvAmortizationEventGroupId
                            AND ValidationRuleId = @dynamicRuleIdReceivePaymentDateEqualLogicalDate
                            AND ComponentTypeCode = @accComponentCodeMaturityDateContingent)
            BEGIN
                INSERT INTO dbo.AccEngineComponent (Id, GroupId, ComponentTypeCode, ValidationRuleId, [Order],
                                                    ModifiedBy,
                                                    ModifiedDate)
                OUTPUT inserted.Id INTO @tempTable
                VALUES (@lastAccEngineComponentId, @dvAmortizationEventGroupId, @accComponentCodeMaturityDateContingent,
                        @dynamicRuleIdReceivePaymentDateEqualLogicalDate,
                        2,
                        @stateMaker,
                        @stateDate);
                SELECT @dvAmortizationEventGroupComponentReceiveId = Id FROM @tempTable;
                DELETE FROM @tempTable
                SELECT @lastAccEngineComponentId = @lastAccEngineComponentId + 1
            END
        ELSE
            BEGIN
                SELECT @dvAmortizationEventGroupComponentReceiveId = Id
                FROM dbo.AccEngineComponent
                WHERE GroupId = @dvAmortizationEventGroupId
                    AND ValidationRuleId = @dynamicRuleIdReceivePaymentDateEqualLogicalDate
                    AND ComponentTypeCode = @accComponentCodeMaturityDateContingent
            END
        ------------------------------------------------------------------------------------------------------------------------
        --#endregion 
        ------------------------------------------------------------------------------------------------------------------------

        ------------------------------------------------------------------------------------------------------------------------
        --#region AccEngineAccountRule
        ------------------------------------------------------------------------------------------------------------------------
        -- Rule MatRecContingent, MatRecContingentOffset
        ------------------------------------------------------------------------------------------------------------------------
        IF NOT EXISTS(SELECT 1
                        FROM dbo.accEngineAccountRule
                        WHERE ComponentId = @dvAmortizationEventGroupComponentReceiveId
                        AND GLCode = N'MatRecContingent')
        BEGIN
            INSERT INTO dbo.AccEngineAccountRule(Id, ComponentId, GLCode, CustomerCodeSource, CustomerAccountCodeSource,
                                                    DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                    ValueDateSource, TxnDateSource, CcySource, FcySource, LcyEqvtSource,
                                                    FcyAmtSource, ReverseRebook, CommentSource, CommentRuleId, ModifiedBy,
                                                    ModifiedDate, ReverseTxnDateSource, ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @dvAmortizationEventGroupComponentReceiveId, N'MatRecContingent',
                    null,
                    null,
                    N'Credit', null, N'ReceiveAmortizationAmount', N'TxnNo', N'LogicalDate', N'LogicalDate', N'ReceiveCurrency',
                    N'ReceiveCurrency', N'ReceiveAmortizationAmount', N'ReceiveAmortizationAmount', 0, null, null, @stateMaker,
                    @stateDate, null, null);

            SELECT @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        END

        IF NOT EXISTS(SELECT 1
                        FROM dbo.accEngineAccountRule
                        WHERE ComponentId = @dvAmortizationEventGroupComponentReceiveId
                        AND GLCode = N'MatRecContingentOffset')
        BEGIN
            INSERT INTO dbo.AccEngineAccountRule(Id, ComponentId, GLCode, CustomerCodeSource, CustomerAccountCodeSource,
                                                    DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                    ValueDateSource, TxnDateSource, CcySource, FcySource, LcyEqvtSource,
                                                    FcyAmtSource, ReverseRebook, CommentSource, CommentRuleId, ModifiedBy,
                                                    ModifiedDate, ReverseTxnDateSource, ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @dvAmortizationEventGroupComponentReceiveId, N'MatRecContingentOffset',
                    null,
                    null,
                    N'Debit', null, N'ReceiveAmortizationAmount', N'TxnNo', N'LogicalDate', N'LogicalDate', N'ReceiveCurrency',
                    N'ReceiveCurrency', N'ReceiveAmortizationAmount', N'ReceiveAmortizationAmount', 0, null, null, @stateMaker,
                    @stateDate, null, null);

            SELECT @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        END
        ------------------------------------------------------------------------------------------------------------------------
        --#endregion 
        ------------------------------------------------------------------------------------------------------------------------

        ------------------------------------------------------------------------------------------------------------------------
        -- Component Receive Amortization Payment
        ------------------------------------------------------------------------------------------------------------------------
        IF NOT EXISTS (SELECT 1
                        FROM dbo.accEngineComponent
                        WHERE GroupId = @dvAmortizationEventGroupId
                            AND ValidationRuleId = @dynamicRuleIdReceivePaymentDateEqualLogicalDate
                            AND ComponentTypeCode = N'600')
            BEGIN
                INSERT INTO dbo.AccEngineComponent (Id, GroupId, ComponentTypeCode, ValidationRuleId, [Order],
                                                    ModifiedBy,
                                                    ModifiedDate)
                OUTPUT inserted.Id INTO @tempTable
                VALUES (@lastAccEngineComponentId, @dvAmortizationEventGroupId, N'600',
                        @dynamicRuleIdReceivePaymentDateEqualLogicalDate,
                        1,
                        @stateMaker,
                        @stateDate);
                SELECT @dvAmortizationEventGroupComponentReceiveId = Id FROM @tempTable;
                DELETE FROM @tempTable
                SELECT @lastAccEngineComponentId = @lastAccEngineComponentId + 1
            END
        ELSE
            BEGIN
                SELECT @dvAmortizationEventGroupComponentReceiveId = Id
                FROM dbo.AccEngineComponent
                WHERE GroupId = @dvAmortizationEventGroupId
                    AND ValidationRuleId = @dynamicRuleIdReceivePaymentDateEqualLogicalDate
                    AND ComponentTypeCode = N'600'
            END
        ------------------------------------------------------------------------------------------------------------------------
        --#endregion 
        ------------------------------------------------------------------------------------------------------------------------

        ------------------------------------------------------------------------------------------------------------------------
        --#region AccEngineAccountRule
        ------------------------------------------------------------------------------------------------------------------------
        -- Rule IncomingPaymentFCY, FXPositionRec, FXPositionLCY
        ------------------------------------------------------------------------------------------------------------------------
        IF NOT EXISTS(SELECT 1
                        FROM dbo.accEngineAccountRule
                        WHERE ComponentId = @dvAmortizationEventGroupComponentReceiveId
                        AND GLCode = N'IncomingPaymentFCY')
        BEGIN
            INSERT INTO dbo.AccEngineAccountRule(Id, ComponentId, GLCode, CustomerCodeSource, CustomerAccountCodeSource,
                                                    DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                    ValueDateSource, TxnDateSource, CcySource, FcySource, LcyEqvtSource,
                                                    FcyAmtSource, ReverseRebook, CommentSource, CommentRuleId, ModifiedBy,
                                                    ModifiedDate, ReverseTxnDateSource, ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @dvAmortizationEventGroupComponentReceiveId, N'IncomingPaymentFCY',
                    null,
                    null,
                    N'Debit', null, N'ReceiveAmortizationAmount', N'TxnNo', N'LogicalDate', N'LogicalDate', N'ReceiveCurrency',
                    N'ReceiveCurrency', N'ReceiveAmortizationAmount', N'ReceiveAmortizationAmount', 0, null, null, @stateMaker,
                    @stateDate, null, null);

            SELECT @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        END

        IF NOT EXISTS(SELECT 1
                        FROM dbo.accEngineAccountRule
                        WHERE ComponentId = @dvAmortizationEventGroupComponentReceiveId
                        AND GLCode = N'FXPositionRec')
        BEGIN
            INSERT INTO dbo.AccEngineAccountRule(Id, ComponentId, GLCode, CustomerCodeSource, CustomerAccountCodeSource,
                                                    DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                    ValueDateSource, TxnDateSource, CcySource, FcySource, LcyEqvtSource,
                                                    FcyAmtSource, ReverseRebook, CommentSource, CommentRuleId, ModifiedBy,
                                                    ModifiedDate, ReverseTxnDateSource, ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @dvAmortizationEventGroupComponentReceiveId, N'FXPositionRec',
                    null,
                    null,
                    N'Credit', null, N'ReceiveAmortizationAmount', N'TxnNo', N'LogicalDate', N'LogicalDate', N'ReceiveCurrency',
                    N'ReceiveCurrency', N'ReceiveAmortizationAmount', N'ReceiveAmortizationAmount', 0, null, null, @stateMaker,
                    @stateDate, null, null);

            SELECT @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        END

        IF NOT EXISTS(SELECT 1
                        FROM dbo.accEngineAccountRule
                        WHERE ComponentId = @dvAmortizationEventGroupComponentReceiveId
                        AND GLCode = N'FXPositionLCY')
        BEGIN
            INSERT INTO dbo.AccEngineAccountRule(Id, ComponentId, GLCode, CustomerCodeSource, CustomerAccountCodeSource,
                                                    DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                    ValueDateSource, TxnDateSource, CcySource, FcySource, LcyEqvtSource,
                                                    FcyAmtSource, ReverseRebook, CommentSource, CommentRuleId, ModifiedBy,
                                                    ModifiedDate, ReverseTxnDateSource, ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @dvAmortizationEventGroupComponentReceiveId, N'FXPositionLCY',
                    null,
                    null,
                    N'Debit', null, N'PayAmortizationAmount', N'TxnNo', N'LogicalDate', N'LogicalDate', N'LocalCCY',
                    N'LocalCCY', N'PayAmortizationAmount', N'PayAmortizationAmount', 0, null, null, @stateMaker,
                    @stateDate, null, null);

            SELECT @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        END
        ------------------------------------------------------------------------------------------------------------------------
        --#endregion 
        ------------------------------------------------------------------------------------------------------------------------

        ------------------------------------------------------------------------------------------------------------------------
        --#region AccEngineComponent
        ------------------------------------------------------------------------------------------------------------------------
        -- Component Pay Maturity Date Contingent
        ------------------------------------------------------------------------------------------------------------------------
        IF NOT EXISTS (SELECT 1
                        FROM dbo.accEngineComponent
                        WHERE GroupId = @dvAmortizationEventGroupId
                            AND ValidationRuleId = @dynamicRuleIdPayPaymentDateEqualLogicalDate
                            AND ComponentTypeCode = N'601')
            BEGIN
                INSERT INTO dbo.AccEngineComponent (Id, GroupId, ComponentTypeCode, ValidationRuleId, [Order],
                                                    ModifiedBy,
                                                    ModifiedDate)
                OUTPUT inserted.Id INTO @tempTable
                VALUES (@lastAccEngineComponentId, @dvAmortizationEventGroupId, N'601',
                        @dynamicRuleIdPayPaymentDateEqualLogicalDate,
                        4,
                        @stateMaker,
                        @stateDate);
                SELECT @dvAmortizationEventGroupComponentPayId = Id FROM @tempTable;
                DELETE FROM @tempTable
                SELECT @lastAccEngineComponentId = @lastAccEngineComponentId + 1
            END
        ELSE
            BEGIN
                SELECT @dvAmortizationEventGroupComponentPayId = Id
                FROM dbo.AccEngineComponent
                WHERE GroupId = @dvAmortizationEventGroupId
                    AND ValidationRuleId = @dynamicRuleIdPayPaymentDateEqualLogicalDate
                    AND ComponentTypeCode = N'601'
            END
        ------------------------------------------------------------------------------------------------------------------------
        --#endregion 
        ------------------------------------------------------------------------------------------------------------------------

        ------------------------------------------------------------------------------------------------------------------------
        --#region AccEngineAccountRule
        ------------------------------------------------------------------------------------------------------------------------
        -- Rule MatPayContingent, MatPayContingentOffset
        ------------------------------------------------------------------------------------------------------------------------
        IF NOT EXISTS(SELECT 1
                        FROM dbo.accEngineAccountRule
                        WHERE ComponentId = @dvAmortizationEventGroupComponentPayId
                        AND GLCode = N'MatPayContingent')
        BEGIN
            INSERT INTO dbo.AccEngineAccountRule(Id, ComponentId, GLCode, CustomerCodeSource, CustomerAccountCodeSource,
                                                    DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                    ValueDateSource, TxnDateSource, CcySource, FcySource, LcyEqvtSource,
                                                    FcyAmtSource, ReverseRebook, CommentSource, CommentRuleId, ModifiedBy,
                                                    ModifiedDate, ReverseTxnDateSource, ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @dvAmortizationEventGroupComponentPayId, N'MatPayContingent',
                    null,
                    null,
                    N'Debit', null, N'PayAmortizationAmount', N'TxnNo', N'PayValueDate', N'LogicalDate', N'PayCurrency',
                    N'PayCurrency', N'PayAmortizationAmount', N'PayAmortizationAmount', 0, null, null, @stateMaker,
                    @stateDate, null, null);

            SELECT @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        END

        IF NOT EXISTS(SELECT 1
                        FROM dbo.accEngineAccountRule
                        WHERE ComponentId = @dvAmortizationEventGroupComponentPayId
                        AND GLCode = N'MatPayContingentOffset')
        BEGIN
            INSERT INTO dbo.AccEngineAccountRule(Id, ComponentId, GLCode, CustomerCodeSource, CustomerAccountCodeSource,
                                                    DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                    ValueDateSource, TxnDateSource, CcySource, FcySource, LcyEqvtSource,
                                                    FcyAmtSource, ReverseRebook, CommentSource, CommentRuleId, ModifiedBy,
                                                    ModifiedDate, ReverseTxnDateSource, ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @dvAmortizationEventGroupComponentPayId, N'MatPayContingentOffset',
                    null,
                    null,
                    N'Credit', null, N'PayAmortizationAmount', N'TxnNo', N'PayValueDate', N'LogicalDate', N'PayCurrency',
                    N'PayCurrency', N'PayAmortizationAmount', N'PayAmortizationAmount', 0, null, null, @stateMaker,
                    @stateDate, null, null);

            SELECT @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        END
        ------------------------------------------------------------------------------------------------------------------------
        --#endregion 
        ------------------------------------------------------------------------------------------------------------------------

        ------------------------------------------------------------------------------------------------------------------------
        --#region AccEngineComponent
        ------------------------------------------------------------------------------------------------------------------------
        -- Component Pay Amortization Payment
        ------------------------------------------------------------------------------------------------------------------------
        IF NOT EXISTS (SELECT 1
                        FROM dbo.accEngineComponent
                        WHERE GroupId = @dvAmortizationEventGroupId
                            AND ValidationRuleId = @dynamicRuleIdPayPaymentDateEqualLogicalDate
                            AND ComponentTypeCode = N'600')
            BEGIN
                INSERT INTO dbo.AccEngineComponent (Id, GroupId, ComponentTypeCode, ValidationRuleId, [Order],
                                                    ModifiedBy,
                                                    ModifiedDate)
                OUTPUT inserted.Id INTO @tempTable
                VALUES (@lastAccEngineComponentId, @dvAmortizationEventGroupId, N'600',
                        @dynamicRuleIdPayPaymentDateEqualLogicalDate,
                        3,
                        @stateMaker,
                        @stateDate);
                SELECT @dvAmortizationEventGroupComponentPayId = Id FROM @tempTable;
                DELETE FROM @tempTable
                SELECT @lastAccEngineComponentId = @lastAccEngineComponentId + 1
            END
        ELSE
            BEGIN
                SELECT @dvAmortizationEventGroupComponentPayId = Id
                FROM dbo.AccEngineComponent
                WHERE GroupId = @dvAmortizationEventGroupId
                    AND ValidationRuleId = @dynamicRuleIdPayPaymentDateEqualLogicalDate
                    AND ComponentTypeCode = N'600'
            END
        ------------------------------------------------------------------------------------------------------------------------
        --#endregion 
        ------------------------------------------------------------------------------------------------------------------------

        ------------------------------------------------------------------------------------------------------------------------
        --#region AccEngineAccountRule
        ------------------------------------------------------------------------------------------------------------------------
        -- Rule OutgoingPaymentLCY
        ------------------------------------------------------------------------------------------------------------------------
        IF NOT EXISTS(SELECT 1
                        FROM dbo.accEngineAccountRule
                        WHERE ComponentId = @dvAmortizationEventGroupComponentPayId
                        AND GLCode = N'OutgoingPaymentLCY')
        BEGIN
            INSERT INTO dbo.AccEngineAccountRule(Id, ComponentId, GLCode, CustomerCodeSource, CustomerAccountCodeSource,
                                                    DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                    ValueDateSource, TxnDateSource, CcySource, FcySource, LcyEqvtSource,
                                                    FcyAmtSource, ReverseRebook, CommentSource, CommentRuleId, ModifiedBy,
                                                    ModifiedDate, ReverseTxnDateSource, ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @dvAmortizationEventGroupComponentPayId, N'OutgoingPaymentLCY',
                    null,
                    null,
                    N'Credit', null, N'PayAmortizationAmount', N'TxnNo', N'PayValueDate', N'LogicalDate', N'PayCurrency',
                    N'PayCurrency', N'PayAmortizationAmount', N'PayAmortizationAmount', 0, null, null, @stateMaker,
                    @stateDate, null, null);

            SELECT @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        END
        ------------------------------------------------------------------------------------------------------------------------
        --#endregion 
        ------------------------------------------------------------------------------------------------------------------------
    END

    /********** 7. STEP: CCS LCYRFCYP AMORTIZATION **************************/
    BEGIN
        PRINT 'CCS LCYRFCYP Amortization Started...';
  
        --#region AccEngineEvent
        ------------------------------------------------------------------------------------------------------------------------
        -- Event CCS FCYRFCYP OnAmortization
        ------------------------------------------------------------------------------------------------------------------------
        IF NOT EXISTS(SELECT 1
                      FROM dbo.accEngineEvent
                      WHERE ItemId = @dvCCSLCYRFCYPItemId
                        AND EventTypeCode = N'OnAmortization')
            BEGIN
                INSERT INTO dbo.AccEngineEvent (Id, ItemId, EventTypeCode, ModifiedBy, ModifiedDate,
                                                EventDescriptionDynamicRuleId)
                OUTPUT inserted.Id INTO @tempTable
                VALUES (@lastAccEngineEventId, @dvCCSLCYRFCYPItemId, N'OnAmortization', @stateMaker, @stateDate, null);
            
                SELECT @dvAmortizationEventId = Id FROM @tempTable;
                DELETE FROM @tempTable
                SELECT @lastAccEngineEventId = @lastAccEngineEventId + 1
            END
        ELSE
            BEGIN
                SELECT @dvAmortizationEventId = Id
                FROM dbo.AccEngineEvent
                WHERE ItemId = @dvCCSLCYRFCYPItemId
                  AND EventTypeCode = N'OnAmortization'
            END
        --#endregion
        ------------------------------------------------------------------------------------------------------------------------

        ------------------------------------------------------------------------------------------------------------------------
        --#region AccEngineGroup
        ------------------------------------------------------------------------------------------------------------------------
        -- Group OnAmortization
        ------------------------------------------------------------------------------------------------------------------------
        IF NOT EXISTS(SELECT 1
                        FROM dbo.accEngineGroup
                        WHERE EventId = @dvAmortizationEventId
                        AND ValidationRuleId is null)
            BEGIN
                INSERT INTO dbo.AccEngineGroup (Id, EventId, ValidationRuleId, [Order],
                                                ModifiedBy,
                                                ModifiedDate,
                                                StateId,
                                                StateDate,
                                                StateMaker)
                OUTPUT inserted.Id INTO @tempTable
                VALUES (@lastAccEngineGroupId, @dvAmortizationEventId,
                        null, 1,
                        @stateMaker,
                        @stateDate,
                        @StateId,
                        @stateDate,
                        @stateMaker);
                SELECT @dvAmortizationEventGroupId = Id FROM @tempTable;
                DELETE FROM @tempTable
                SELECT @lastAccEngineGroupId = @lastAccEngineGroupId + 1
            END
        ELSE
            BEGIN
                SELECT @dvAmortizationEventGroupId = Id
                FROM dbo.AccEngineGroup
                WHERE EventId = @dvAmortizationEventId
                    AND ValidationRuleId is null
            END
        --#endregion   
        ------------------------------------------------------------------------------------------------------------------------

        ------------------------------------------------------------------------------------------------------------------------
        --#region AccEngineComponent
        ------------------------------------------------------------------------------------------------------------------------
        -- Component Receive Maturity Date Contingent
        ------------------------------------------------------------------------------------------------------------------------
        IF NOT EXISTS (SELECT 1
                        FROM dbo.accEngineComponent
                        WHERE GroupId = @dvAmortizationEventGroupId
                            AND ValidationRuleId = @dynamicRuleIdReceivePaymentDateEqualLogicalDate
                            AND ComponentTypeCode = @accComponentCodeMaturityDateContingent)
            BEGIN
                INSERT INTO dbo.AccEngineComponent (Id, GroupId, ComponentTypeCode, ValidationRuleId, [Order],
                                                    ModifiedBy,
                                                    ModifiedDate)
                OUTPUT inserted.Id INTO @tempTable
                VALUES (@lastAccEngineComponentId, @dvAmortizationEventGroupId, @accComponentCodeMaturityDateContingent,
                        @dynamicRuleIdReceivePaymentDateEqualLogicalDate,
                        2,
                        @stateMaker,
                        @stateDate);
                SELECT @dvAmortizationEventGroupComponentReceiveId = Id FROM @tempTable;
                DELETE FROM @tempTable
                SELECT @lastAccEngineComponentId = @lastAccEngineComponentId + 1
            END
        ELSE
            BEGIN
                SELECT @dvAmortizationEventGroupComponentReceiveId = Id
                FROM dbo.AccEngineComponent
                WHERE GroupId = @dvAmortizationEventGroupId
                    AND ValidationRuleId = @dynamicRuleIdReceivePaymentDateEqualLogicalDate
                    AND ComponentTypeCode = @accComponentCodeMaturityDateContingent
            END
        ------------------------------------------------------------------------------------------------------------------------
        --#endregion 
        ------------------------------------------------------------------------------------------------------------------------

        ------------------------------------------------------------------------------------------------------------------------
        --#region AccEngineAccountRule
        ------------------------------------------------------------------------------------------------------------------------
        -- Rule MatRecContingent, MatRecContingentOffset
        ------------------------------------------------------------------------------------------------------------------------
        IF NOT EXISTS(SELECT 1
                        FROM dbo.accEngineAccountRule
                        WHERE ComponentId = @dvAmortizationEventGroupComponentReceiveId
                        AND GLCode = N'MatRecContingent')
        BEGIN
            INSERT INTO dbo.AccEngineAccountRule(Id, ComponentId, GLCode, CustomerCodeSource, CustomerAccountCodeSource,
                                                    DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                    ValueDateSource, TxnDateSource, CcySource, FcySource, LcyEqvtSource,
                                                    FcyAmtSource, ReverseRebook, CommentSource, CommentRuleId, ModifiedBy,
                                                    ModifiedDate, ReverseTxnDateSource, ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @dvAmortizationEventGroupComponentReceiveId, N'MatRecContingent',
                    null,
                    null,
                    N'Debit', null, N'ReceiveAmortizationAmount', N'TxnNo', N'LogicalDate', N'LogicalDate', N'ReceiveCurrency',
                    N'ReceiveCurrency', N'ReceiveAmortizationAmount', N'ReceiveAmortizationAmount', 0, null, null, @stateMaker,
                    @stateDate, null, null);

            SELECT @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        END

        IF NOT EXISTS(SELECT 1
                        FROM dbo.accEngineAccountRule
                        WHERE ComponentId = @dvAmortizationEventGroupComponentReceiveId
                        AND GLCode = N'MatRecContingentOffset')
        BEGIN
            INSERT INTO dbo.AccEngineAccountRule(Id, ComponentId, GLCode, CustomerCodeSource, CustomerAccountCodeSource,
                                                    DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                    ValueDateSource, TxnDateSource, CcySource, FcySource, LcyEqvtSource,
                                                    FcyAmtSource, ReverseRebook, CommentSource, CommentRuleId, ModifiedBy,
                                                    ModifiedDate, ReverseTxnDateSource, ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @dvAmortizationEventGroupComponentReceiveId, N'MatRecContingentOffset',
                    null,
                    null,
                    N'Credit', null, N'ReceiveAmortizationAmount', N'TxnNo', N'LogicalDate', N'LogicalDate', N'ReceiveCurrency',
                    N'ReceiveCurrency', N'ReceiveAmortizationAmount', N'ReceiveAmortizationAmount', 0, null, null, @stateMaker,
                    @stateDate, null, null);

            SELECT @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        END
        ------------------------------------------------------------------------------------------------------------------------
        --#endregion 
        ------------------------------------------------------------------------------------------------------------------------

        ------------------------------------------------------------------------------------------------------------------------
        -- Component Receive Amortization Payment
        ------------------------------------------------------------------------------------------------------------------------
        IF NOT EXISTS (SELECT 1
                        FROM dbo.accEngineComponent
                        WHERE GroupId = @dvAmortizationEventGroupId
                            AND ValidationRuleId = @dynamicRuleIdReceivePaymentDateEqualLogicalDate
                            AND ComponentTypeCode = N'600')
            BEGIN
                INSERT INTO dbo.AccEngineComponent (Id, GroupId, ComponentTypeCode, ValidationRuleId, [Order],
                                                    ModifiedBy,
                                                    ModifiedDate)
                OUTPUT inserted.Id INTO @tempTable
                VALUES (@lastAccEngineComponentId, @dvAmortizationEventGroupId, N'600',
                        @dynamicRuleIdReceivePaymentDateEqualLogicalDate,
                        1,
                        @stateMaker,
                        @stateDate);
                SELECT @dvAmortizationEventGroupComponentReceiveId = Id FROM @tempTable;
                DELETE FROM @tempTable
                SELECT @lastAccEngineComponentId = @lastAccEngineComponentId + 1
            END
        ELSE
            BEGIN
                SELECT @dvAmortizationEventGroupComponentReceiveId = Id
                FROM dbo.AccEngineComponent
                WHERE GroupId = @dvAmortizationEventGroupId
                    AND ValidationRuleId = @dynamicRuleIdReceivePaymentDateEqualLogicalDate
                    AND ComponentTypeCode = N'600'
            END
        ------------------------------------------------------------------------------------------------------------------------
        --#endregion 
        ------------------------------------------------------------------------------------------------------------------------

        ------------------------------------------------------------------------------------------------------------------------
        --#region AccEngineAccountRule
        ------------------------------------------------------------------------------------------------------------------------
        -- Rule IncomingPaymentLCY
        ------------------------------------------------------------------------------------------------------------------------
        IF NOT EXISTS(SELECT 1
                        FROM dbo.accEngineAccountRule
                        WHERE ComponentId = @dvAmortizationEventGroupComponentReceiveId
                        AND GLCode = N'IncomingPaymentLCY')
        BEGIN
            INSERT INTO dbo.AccEngineAccountRule(Id, ComponentId, GLCode, CustomerCodeSource, CustomerAccountCodeSource,
                                                    DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                    ValueDateSource, TxnDateSource, CcySource, FcySource, LcyEqvtSource,
                                                    FcyAmtSource, ReverseRebook, CommentSource, CommentRuleId, ModifiedBy,
                                                    ModifiedDate, ReverseTxnDateSource, ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @dvAmortizationEventGroupComponentReceiveId, N'IncomingPaymentLCY',
                    null,
                    null,
                    N'Debit', null, N'ReceiveAmortizationAmount', N'TxnNo', N'LogicalDate', N'LogicalDate', N'ReceiveCurrency',
                    N'ReceiveCurrency', N'ReceiveAmortizationAmount', N'ReceiveAmortizationAmount', 0, null, null, @stateMaker,
                    @stateDate, null, null);

            SELECT @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        END
        ------------------------------------------------------------------------------------------------------------------------
        --#endregion 
        ------------------------------------------------------------------------------------------------------------------------

        ------------------------------------------------------------------------------------------------------------------------
        --#region AccEngineComponent
        ------------------------------------------------------------------------------------------------------------------------
        -- Component Pay Maturity Date Contingent
        ------------------------------------------------------------------------------------------------------------------------
        IF NOT EXISTS (SELECT 1
                        FROM dbo.accEngineComponent
                        WHERE GroupId = @dvAmortizationEventGroupId
                            AND ValidationRuleId = @dynamicRuleIdPayPaymentDateEqualLogicalDate
                            AND ComponentTypeCode = @accComponentCodeMaturityDateContingent)
            BEGIN
                INSERT INTO dbo.AccEngineComponent (Id, GroupId, ComponentTypeCode, ValidationRuleId, [Order],
                                                    ModifiedBy,
                                                    ModifiedDate)
                OUTPUT inserted.Id INTO @tempTable
                VALUES (@lastAccEngineComponentId, @dvAmortizationEventGroupId, @accComponentCodeMaturityDateContingent,
                        @dynamicRuleIdPayPaymentDateEqualLogicalDate,
                        4,
                        @stateMaker,
                        @stateDate);
                SELECT @dvAmortizationEventGroupComponentPayId = Id FROM @tempTable;
                DELETE FROM @tempTable
                SELECT @lastAccEngineComponentId = @lastAccEngineComponentId + 1
            END
        ELSE
            BEGIN
                SELECT @dvAmortizationEventGroupComponentPayId = Id
                FROM dbo.AccEngineComponent
                WHERE GroupId = @dvAmortizationEventGroupId
                    AND ValidationRuleId = @dynamicRuleIdPayPaymentDateEqualLogicalDate
                    AND ComponentTypeCode = @accComponentCodeMaturityDateContingent
            END
        ------------------------------------------------------------------------------------------------------------------------
        --#endregion 
        ------------------------------------------------------------------------------------------------------------------------

        ------------------------------------------------------------------------------------------------------------------------
        --#region AccEngineAccountRule
        ------------------------------------------------------------------------------------------------------------------------
        -- Rule MatPayContingent, MatPayContingentOffset
        ------------------------------------------------------------------------------------------------------------------------
        IF NOT EXISTS(SELECT 1
                        FROM dbo.accEngineAccountRule
                        WHERE ComponentId = @dvAmortizationEventGroupComponentPayId
                        AND GLCode = N'MatPayContingent')
        BEGIN
            INSERT INTO dbo.AccEngineAccountRule(Id, ComponentId, GLCode, CustomerCodeSource, CustomerAccountCodeSource,
                                                    DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                    ValueDateSource, TxnDateSource, CcySource, FcySource, LcyEqvtSource,
                                                    FcyAmtSource, ReverseRebook, CommentSource, CommentRuleId, ModifiedBy,
                                                    ModifiedDate, ReverseTxnDateSource, ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @dvAmortizationEventGroupComponentPayId, N'MatPayContingent',
                    null,
                    null,
                    N'Debit', null, N'PayAmortizationAmount', N'TxnNo', N'PayValueDate', N'LogicalDate', N'PayCurrency',
                    N'PayCurrency', N'PayAmortizationAmount', N'PayAmortizationAmount', 0, null, null, @stateMaker,
                    @stateDate, null, null);

            SELECT @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        END

        IF NOT EXISTS(SELECT 1
                        FROM dbo.accEngineAccountRule
                        WHERE ComponentId = @dvAmortizationEventGroupComponentPayId
                        AND GLCode = N'MatPayContingentOffset')
        BEGIN
            INSERT INTO dbo.AccEngineAccountRule(Id, ComponentId, GLCode, CustomerCodeSource, CustomerAccountCodeSource,
                                                    DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                    ValueDateSource, TxnDateSource, CcySource, FcySource, LcyEqvtSource,
                                                    FcyAmtSource, ReverseRebook, CommentSource, CommentRuleId, ModifiedBy,
                                                    ModifiedDate, ReverseTxnDateSource, ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @dvAmortizationEventGroupComponentPayId, N'MatPayContingentOffset',
                    null,
                    null,
                    N'Credit', null, N'PayAmortizationAmount', N'TxnNo', N'PayValueDate', N'LogicalDate', N'PayCurrency',
                    N'PayCurrency', N'PayAmortizationAmount', N'PayAmortizationAmount', 0, null, null, @stateMaker,
                    @stateDate, null, null);

            SELECT @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        END
        ------------------------------------------------------------------------------------------------------------------------
        --#endregion 
        ------------------------------------------------------------------------------------------------------------------------

        ------------------------------------------------------------------------------------------------------------------------
        --#region AccEngineComponent
        ------------------------------------------------------------------------------------------------------------------------
        -- Component Pay Amortization Payment
        ------------------------------------------------------------------------------------------------------------------------
        IF NOT EXISTS (SELECT 1
                        FROM dbo.accEngineComponent
                        WHERE GroupId = @dvAmortizationEventGroupId
                            AND ValidationRuleId = @dynamicRuleIdPayPaymentDateEqualLogicalDate
                            AND ComponentTypeCode = N'601')
            BEGIN
                INSERT INTO dbo.AccEngineComponent (Id, GroupId, ComponentTypeCode, ValidationRuleId, [Order],
                                                    ModifiedBy,
                                                    ModifiedDate)
                OUTPUT inserted.Id INTO @tempTable
                VALUES (@lastAccEngineComponentId, @dvAmortizationEventGroupId, N'601',
                        @dynamicRuleIdPayPaymentDateEqualLogicalDate,
                        3,
                        @stateMaker,
                        @stateDate);
                SELECT @dvAmortizationEventGroupComponentPayId = Id FROM @tempTable;
                DELETE FROM @tempTable
                SELECT @lastAccEngineComponentId = @lastAccEngineComponentId + 1
            END
        ELSE
            BEGIN
                SELECT @dvAmortizationEventGroupComponentPayId = Id
                FROM dbo.AccEngineComponent
                WHERE GroupId = @dvAmortizationEventGroupId
                    AND ValidationRuleId = @dynamicRuleIdPayPaymentDateEqualLogicalDate
                    AND ComponentTypeCode = N'601'
            END
        ------------------------------------------------------------------------------------------------------------------------
        --#endregion 
        ------------------------------------------------------------------------------------------------------------------------

        ------------------------------------------------------------------------------------------------------------------------
        --#region AccEngineAccountRule
        ------------------------------------------------------------------------------------------------------------------------
        -- Rule OutgoingPaymentFCY, FXPositionPay, FXPositionLCY
        ------------------------------------------------------------------------------------------------------------------------
        IF NOT EXISTS(SELECT 1
                        FROM dbo.accEngineAccountRule
                        WHERE ComponentId = @dvAmortizationEventGroupComponentPayId
                        AND GLCode = N'OutgoingPaymentFCY')
        BEGIN
            INSERT INTO dbo.AccEngineAccountRule(Id, ComponentId, GLCode, CustomerCodeSource, CustomerAccountCodeSource,
                                                    DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                    ValueDateSource, TxnDateSource, CcySource, FcySource, LcyEqvtSource,
                                                    FcyAmtSource, ReverseRebook, CommentSource, CommentRuleId, ModifiedBy,
                                                    ModifiedDate, ReverseTxnDateSource, ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @dvAmortizationEventGroupComponentPayId, N'OutgoingPaymentFCY',
                    null,
                    null,
                    N'Credit', null, N'PayAmortizationAmount', N'TxnNo', N'PayValueDate', N'LogicalDate', N'PayCurrency',
                    N'PayCurrency', N'PayAmortizationAmount', N'PayAmortizationAmount', 0, null, null, @stateMaker,
                    @stateDate, null, null);

            SELECT @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        END

        IF NOT EXISTS(SELECT 1
                        FROM dbo.accEngineAccountRule
                        WHERE ComponentId = @dvAmortizationEventGroupComponentPayId
                        AND GLCode = N'FXPositionPay')
        BEGIN
            INSERT INTO dbo.AccEngineAccountRule(Id, ComponentId, GLCode, CustomerCodeSource, CustomerAccountCodeSource,
                                                    DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                    ValueDateSource, TxnDateSource, CcySource, FcySource, LcyEqvtSource,
                                                    FcyAmtSource, ReverseRebook, CommentSource, CommentRuleId, ModifiedBy,
                                                    ModifiedDate, ReverseTxnDateSource, ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @dvAmortizationEventGroupComponentPayId, N'FXPositionPay',
                    null,
                    null,
                    N'Debit', null, N'PayAmortizationAmount', N'TxnNo', N'PayValueDate', N'LogicalDate', N'PayCurrency',
                    N'PayCurrency', N'PayAmortizationAmount', N'PayAmortizationAmount', 0, null, null, @stateMaker,
                    @stateDate, null, null);

            SELECT @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        END

        IF NOT EXISTS(SELECT 1
                        FROM dbo.accEngineAccountRule
                        WHERE ComponentId = @dvAmortizationEventGroupComponentPayId
                        AND GLCode = N'FXPositionLCY')
        BEGIN
            INSERT INTO dbo.AccEngineAccountRule(Id, ComponentId, GLCode, CustomerCodeSource, CustomerAccountCodeSource,
                                                    DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                    ValueDateSource, TxnDateSource, CcySource, FcySource, LcyEqvtSource,
                                                    FcyAmtSource, ReverseRebook, CommentSource, CommentRuleId, ModifiedBy,
                                                    ModifiedDate, ReverseTxnDateSource, ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @dvAmortizationEventGroupComponentPayId, N'FXPositionLCY',
                    null,
                    null,
                    N'Credit', null, N'ReceiveAmortizationAmount', N'TxnNo', N'LogicalDate', N'LogicalDate', N'LocalCCY',
                    N'LocalCCY', N'ReceiveAmortizationAmount', N'ReceiveAmortizationAmount', 0, null, null, @stateMaker,
                    @stateDate, null, null);

            SELECT @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        END
        ------------------------------------------------------------------------------------------------------------------------
        --#endregion 
        ------------------------------------------------------------------------------------------------------------------------
    END

    /********** 8. STEP: NUMBER GENERATION UPDATE **************************/
    BEGIN
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
        SET LastNumber     = @lastAccEngineModelDefinitionId,
            LastUpdateDate = @stateDate
        WHERE EntityColumnType = @accEngineModelDefinitionColumnTypeId
        --#endregion
    END

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