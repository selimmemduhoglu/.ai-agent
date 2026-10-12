/***************************************************************************************************
* This script is designed to add Fee Account Rules
***************************************************************************************************/

USE NetTrexAcc_Amortization
GO

BEGIN TRY
    BEGIN TRANSACTION;

    /********** 1. STEP: PARAMETER DEFINITION **********************************/
    BEGIN
        DECLARE
            @tempTable TABLE (Id INT);

        DECLARE
            @path NVARCHAR(80) = 'TREX/DV',
            @pathIRS NVARCHAR(80) = 'TREX/DV/IRS',
            @pathCCS NVARCHAR(80) = 'TREX/DV/CCS';

        DECLARE
            @stateId INT=18,
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
            @accEngineModelDefinitionColumnTypeId INT = 10,
            @lastAccAccountMapId INT = 0,
            @accAccountMapColumnTypeId INT = 11;

        DECLARE
            @dynamicRuleIdReceiveFCY INT = 0,
            @dynamicRuleIdReceiveLCY INT = 0,
            @dynamicRuleIdPayFCY INT = 0,
            @dynamicRuleIdPayLCY INT = 0,
            @dynamicRuleIdTradePortfolio INT = 0;

        DECLARE
            @dynamicRuleIdReceivePaymentDateEqualLogicalDate INT = 0,
            @dynamicRuleIdPayPaymentDateEqualLogicalDate INT = 0,
            @dynamicRuleIdPaymentDateEqualLogicalDateAndNetPaymentLessThanZero INT = 0,
            @dynamicRuleIdPaymentDateEqualLogicalDateAndNetPaymentGratherThanZero INT = 0;

        DECLARE @i INT = 1, @count INT;

        ------------------------------------------------------------------------------------------------------------------------
        -- Definition Number Generation
        ------------------------------------------------------------------------------------------------------------------------
        -- Accounting Account Map Last Number
        ------------------------------------------------------------------------------------------------------------------------
        SELECT @lastAccAccountMapId = LastNumber + 1
        FROM dbo.DefNumberGen
        WHERE EntityColumnType = @accAccountMapColumnTypeId
          AND Definition = N'AccAccountMap Id'

        IF (@lastAccAccountMapId = 0)
            THROW 500001, 'AccAccountMap Last Id Not Found', 1
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

    /********** 2. STEP: MODEL DEFINITION **************************************/
    BEGIN
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
                        N'{"title":"DerivSWPAccountingModel","type":"object","properties":{"NetPeriodEndAmount":{"title":"Net Period End Amount","type":"number"},"NetPeriodEndAmountLCY":{"title":"Net Period End Amount LCY","type":"number"},"ReceivePeriodAmount":{"title":"Receive Period End Amount","type":"number"},"ReceivePeriodAmountLCY":{"title":"Receive Period End Amount LCY","type":"number"},"PayPeriodAmount":{"title":"Pay Period End Amount","type":"number"},"PayPeriodAmountLCY":{"title":"Pay Period End Amount LCY","type":"number"},"ReceivePrincipalAmount":{"title":"Receive Amount","type":["number","null"]},"PayPrincipalAmount":{"title":"Pay Amount","type":["number","null"]},"ReceiveAmortizationAmount":{"title":"Receive Amortization Amount","type":"number"},"ReceiveAmortizationAmountLCY":{"title":"Receive Amortization Amount LCY","type":"number"},"PayAmortizationAmount":{"title":"Pay Amortization Amount","type":"number"},"PayAmortizationAmountLCY":{"title":"Pay Amortization Amount LCY","type":"number"},"NetPeriodFeeAmount":{"title":"Net Period Fee Amount","type":"number"},"NetPeriodFeeAmountLCY":{"title":"Net Period Fee Amount LCY","type":"number"},"ReceiveFeeAmount":{"title":"Receive Fee Amount","type":"number"},"ReceiveFeeAmountLCY":{"title":"Receive Fee Amount LCY","type":"number"},"PayFeeAmount":{"title":"Pay Fee Amount","type":"number"},"PayFeeAmountLCY":{"title":"Pay Fee Amount LCY","type":"number"},"TotalMTMAmount":{"title":"MTM Amount","type":["number","null"]},"TotalMTMAmountCCY":{"title":"MTM Amount CCY","type":["string","null"]},"TotalMTMAmountLCY":{"title":"MTM Amount LCY","type":["number","null"]},"TotalMTMAmountLCYCode":{"title":"MTM Amount LCY Code","type":["string","null"]},"WeakAmountLCY":{"title":"Weak Amount LCY","type":["number","null"]},"WeakAmountCCY":{"title":"Weak Amount CCY","type":["string","null"]},"TaxAmount":{"title":"Tax Amount","type":"number"},"PayCurrency":{"title":"Pay Currency","type":["string","null"]},"ReceiveCurrency":{"title":"Receive Currency","type":["string","null"]},"LocalCCY":{"title":"Local CCY","type":["string","null"]},"LogicalDate":{"title":"Logical Date","type":"string","format":"date-time"},"NextWorkingLogicalDate":{"title":"Next Working Logical Date","type":"string","format":"date-time"},"PreviousWorkingLogicalDate":{"title":"Previous Working Logical Date","type":"string","format":"date-time"},"ExternalCustomerId":{"title":"External Customer Id","type":["string","null"]},"TxnReference":{"title":"Transaction Reference","description":"Transaction String Reference","type":["string","null"]},"TxnNo":{"title":"Transaction Number","type":"integer"},"AccountingGenerationDate":{"title":"Accounting Generation Date","type":"string","format":"date-time"},"Comment":{"title":"Comment","type":["string","null"]},"ApplicationName":{"title":"Application Name","type":["string","null"]},"TemplateId":{"title":"Template Id","type":"integer"},"PathRuleId":{"title":"Path Rule Id","type":"integer"}},"required":["NetPeriodEndAmount","NetPeriodEndAmountLCY","ReceivePeriodAmount","ReceivePeriodAmountLCY","PayPeriodAmount","PayPeriodAmountLCY","ReceivePrincipalAmount","PayPrincipalAmount","TotalMTMAmount","TotalMTMAmountCCY","TotalMTMAmountLCY","TotalMTMAmountLCYCode","WeakAmountLCY","WeakAmountCCY","TaxAmount","PayCurrency","ReceiveCurrency","LocalCCY","LogicalDate","NextWorkingLogicalDate","PreviousWorkingLogicalDate","ExternalCustomerId","TxnReference","TxnNo","AccountingGenerationDate","Comment","ApplicationName","TemplateId","PathRuleId"]}',
                        N'Derivative Swap', @StateId, @stateDate, @stateMaker);
                SELECT @lastAccEngineModelDefinitionId = Id FROM @tempTable;
                DELETE FROM @tempTable
            END
        ELSE
            BEGIN
                UPDATE dbo.AccEngineModelDefinition
                SET [Schema]   = N'{"title":"DerivSWPAccountingModel","type":"object","properties":{"NetPeriodEndAmount":{"title":"Net Period End Amount","type":"number"},"NetPeriodEndAmountLCY":{"title":"Net Period End Amount LCY","type":"number"},"ReceivePeriodAmount":{"title":"Receive Period End Amount","type":"number"},"ReceivePeriodAmountLCY":{"title":"Receive Period End Amount LCY","type":"number"},"PayPeriodAmount":{"title":"Pay Period End Amount","type":"number"},"PayPeriodAmountLCY":{"title":"Pay Period End Amount LCY","type":"number"},"ReceivePrincipalAmount":{"title":"Receive Amount","type":["number","null"]},"PayPrincipalAmount":{"title":"Pay Amount","type":["number","null"]},"ReceiveAmortizationAmount":{"title":"Receive Amortization Amount","type":"number"},"ReceiveAmortizationAmountLCY":{"title":"Receive Amortization Amount LCY","type":"number"},"PayAmortizationAmount":{"title":"Pay Amortization Amount","type":"number"},"PayAmortizationAmountLCY":{"title":"Pay Amortization Amount LCY","type":"number"},"NetPeriodFeeAmount":{"title":"Net Period Fee Amount","type":"number"},"NetPeriodFeeAmountLCY":{"title":"Net Period Fee Amount LCY","type":"number"},"ReceiveFeeAmount":{"title":"Receive Fee Amount","type":"number"},"ReceiveFeeAmountLCY":{"title":"Receive Fee Amount LCY","type":"number"},"PayFeeAmount":{"title":"Pay Fee Amount","type":"number"},"PayFeeAmountLCY":{"title":"Pay Fee Amount LCY","type":"number"},"TotalMTMAmount":{"title":"MTM Amount","type":["number","null"]},"TotalMTMAmountCCY":{"title":"MTM Amount CCY","type":["string","null"]},"TotalMTMAmountLCY":{"title":"MTM Amount LCY","type":["number","null"]},"TotalMTMAmountLCYCode":{"title":"MTM Amount LCY Code","type":["string","null"]},"WeakAmountLCY":{"title":"Weak Amount LCY","type":["number","null"]},"WeakAmountCCY":{"title":"Weak Amount CCY","type":["string","null"]},"TaxAmount":{"title":"Tax Amount","type":"number"},"PayCurrency":{"title":"Pay Currency","type":["string","null"]},"ReceiveCurrency":{"title":"Receive Currency","type":["string","null"]},"LocalCCY":{"title":"Local CCY","type":["string","null"]},"LogicalDate":{"title":"Logical Date","type":"string","format":"date-time"},"NextWorkingLogicalDate":{"title":"Next Working Logical Date","type":"string","format":"date-time"},"PreviousWorkingLogicalDate":{"title":"Previous Working Logical Date","type":"string","format":"date-time"},"ExternalCustomerId":{"title":"External Customer Id","type":["string","null"]},"TxnReference":{"title":"Transaction Reference","description":"Transaction String Reference","type":["string","null"]},"TxnNo":{"title":"Transaction Number","type":"integer"},"AccountingGenerationDate":{"title":"Accounting Generation Date","type":"string","format":"date-time"},"Comment":{"title":"Comment","type":["string","null"]},"ApplicationName":{"title":"Application Name","type":["string","null"]},"TemplateId":{"title":"Template Id","type":"integer"},"PathRuleId":{"title":"Path Rule Id","type":"integer"}},"required":["NetPeriodEndAmount","NetPeriodEndAmountLCY","ReceivePeriodAmount","ReceivePeriodAmountLCY","PayPeriodAmount","PayPeriodAmountLCY","ReceivePrincipalAmount","PayPrincipalAmount","TotalMTMAmount","TotalMTMAmountCCY","TotalMTMAmountLCY","TotalMTMAmountLCYCode","WeakAmountLCY","WeakAmountCCY","TaxAmount","PayCurrency","ReceiveCurrency","LocalCCY","LogicalDate","NextWorkingLogicalDate","PreviousWorkingLogicalDate","ExternalCustomerId","TxnReference","TxnNo","AccountingGenerationDate","Comment","ApplicationName","TemplateId","PathRuleId"]}',
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
                       WHERE Code = N'OnFee')
            BEGIN
                INSERT INTO dbo.AccEngineEventType (Name, Code)
                VALUES (N'OnFee', N'OnFee');
            END;
        --#endregion
        ------------------------------------------------------------------------------------------------------------------------

        ------------------------------------------------------------------------------------------------------------------------
        -- Accounting Engine Component Type
        ------------------------------------------------------------------------------------------------------------------------
        --#region AccEngineComponentType
        IF NOT EXISTS (SELECT 1
                       FROM dbo.AccEngineComponentType
                       WHERE Name = N'Fee Payment Incoming'
                         AND Code = N'602')
        BEGIN
            INSERT INTO dbo.AccEngineComponentType (Name, Code, StateId, StateDate, StateMaker)
            VALUES (N'Fee Payment Incoming', N'602', @stateId, @stateDate, @stateDate);
        END;

        IF NOT EXISTS (SELECT 1
                       FROM dbo.AccEngineComponentType
                       WHERE Name = N'Fee Payment Outgoing'
                         AND Code = N'603')
        BEGIN
            INSERT INTO dbo.AccEngineComponentType (Name, Code, StateId, StateDate, StateMaker)
            VALUES (N'Fee Payment Outgoing', N'603', @stateId, @stateDate, @stateDate);
        END;
        --#endregion
    END

    /********** 3. STEP: FEE GLCODES *******************************************/
    BEGIN 

		PRINT N'Fee GLCode Inserting..'

        DECLARE @tempGLCode TABLE (Id INT IDENTITY(1,1), GLCode NVARCHAR(20));
        INSERT INTO @tempGLCode (GLCode)
        VALUES (N'FeeIncome'), (N'FeeExpense');
        
        DECLARE @GlCode NVARCHAR(20);
        SELECT @count = COUNT(*) FROM @tempGLCode;

        SET @i= 1;
		WHILE @i <= @count
		BEGIN
			SELECT @GlCode = GLCode FROM @tempGLCode WHERE Id = @i;

			IF NOT EXISTS (SELECT 1 FROM accEngineAccount WHERE GLCode = @GlCode)
			BEGIN
				INSERT INTO accEngineAccount VALUES(@GlCode, NULL, NULL, NULL, NULL, @stateId, @stateDate, @stateMaker, NULL, 1, 2);
				PRINT @GlCode + N' GlCode inserted..'
			END

            SET @i += 1;
		END;
        
		PRINT N'Fee GlCode insert FINISH'
	END

    /********** 4. STEP: DYNAMIC RULES *****************************************/
    BEGIN
        ------------------------------------------------------------------------------------------------------------------------   
        -- Accounting Engine Dynamic Rule
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
       
        ------------------------------------------------------------------------------------------------------------------------
        -- PeriodPaymentDate = LogicalDate && NetPayment > 0
        -- ((TxnModel.ReceivePeriodPaymentDate !== null ? TxnModel.ReceivePeriodPaymentDate.getTime() === TxnModel.LogicalDate.getTime() : false) || (TxnModel.PayPeriodPaymentDate !== null ? TxnModel.PayPeriodPaymentDate.getTime() === TxnModel.LogicalDate.getTime() : false)) && TxnModel.NetPeriodFeeAmount > 0
        ------------------------------------------------------------------------------------------------------------------------
        IF NOT EXISTS (SELECT 1
                       FROM dbo.AccEngineDynamicRule
                       WHERE [Rule] = N'((TxnModel.ReceivePeriodPaymentDate !== null ? TxnModel.ReceivePeriodPaymentDate.getTime() === TxnModel.LogicalDate.getTime() : false) || (TxnModel.PayPeriodPaymentDate !== null ? TxnModel.PayPeriodPaymentDate.getTime() === TxnModel.LogicalDate.getTime() : false)) && TxnModel.NetPeriodFeeAmount > 0')
            BEGIN
                INSERT INTO dbo.AccEngineDynamicRule (Id, Name, [Rule], Type, Description, StateId, StateDate, StateMaker)
                OUTPUT inserted.Id INTO @tempTable
                VALUES (@lastAccEngineDynamicRuleId, N'PeriodPaymentDate = LogicalDate && NetPayment > 0',
                        N'((TxnModel.ReceivePeriodPaymentDate !== null ? TxnModel.ReceivePeriodPaymentDate.getTime() === TxnModel.LogicalDate.getTime() : false) || (TxnModel.PayPeriodPaymentDate !== null ? TxnModel.PayPeriodPaymentDate.getTime() === TxnModel.LogicalDate.getTime() : false)) && TxnModel.NetPeriodFeeAmount > 0',
                        0, N'', @stateId, @stateDate, @stateMaker);
                SELECT @dynamicRuleIdPaymentDateEqualLogicalDateAndNetPaymentGratherThanZero = Id FROM @tempTable;
                DELETE FROM @tempTable
                SELECT @lastAccEngineDynamicRuleId = @lastAccEngineDynamicRuleId + 1
            END;
        ELSE
            BEGIN
                SELECT @dynamicRuleIdPaymentDateEqualLogicalDateAndNetPaymentGratherThanZero = Id
                FROM dbo.AccEngineDynamicRule
                WHERE [Rule] = N'((TxnModel.ReceivePeriodPaymentDate !== null ? TxnModel.ReceivePeriodPaymentDate.getTime() === TxnModel.LogicalDate.getTime() : false) || (TxnModel.PayPeriodPaymentDate !== null ? TxnModel.PayPeriodPaymentDate.getTime() === TxnModel.LogicalDate.getTime() : false)) && TxnModel.NetPeriodFeeAmount > 0'
            END
        ------------------------------------------------------------------------------------------------------------------------

        ------------------------------------------------------------------------------------------------------------------------
        -- PeriodPaymentDate = LogicalDate && NetPayment < 0
        -- ((TxnModel.ReceivePeriodPaymentDate !== null ? TxnModel.ReceivePeriodPaymentDate.getTime() === TxnModel.LogicalDate.getTime() : false) || (TxnModel.PayPeriodPaymentDate !== null ? TxnModel.PayPeriodPaymentDate.getTime() === TxnModel.LogicalDate.getTime() : false)) && TxnModel.NetPeriodFeeAmount > 0
        ------------------------------------------------------------------------------------------------------------------------
        IF NOT EXISTS (SELECT 1
                       FROM dbo.AccEngineDynamicRule
                       WHERE [Rule] = N'((TxnModel.ReceivePeriodPaymentDate !== null ? TxnModel.ReceivePeriodPaymentDate.getTime() === TxnModel.LogicalDate.getTime() : false) || (TxnModel.PayPeriodPaymentDate !== null ? TxnModel.PayPeriodPaymentDate.getTime() === TxnModel.LogicalDate.getTime() : false)) && TxnModel.NetPeriodFeeAmount < 0')
            BEGIN
                INSERT INTO dbo.AccEngineDynamicRule (Id, Name, [Rule], Type, Description, StateId, StateDate, StateMaker)
                OUTPUT inserted.Id INTO @tempTable
                VALUES (@lastAccEngineDynamicRuleId, N'PeriodPaymentDate = LogicalDate && NetPayment < 0',
                        N'((TxnModel.ReceivePeriodPaymentDate !== null ? TxnModel.ReceivePeriodPaymentDate.getTime() === TxnModel.LogicalDate.getTime() : false) || (TxnModel.PayPeriodPaymentDate !== null ? TxnModel.PayPeriodPaymentDate.getTime() === TxnModel.LogicalDate.getTime() : false)) && TxnModel.NetPeriodFeeAmount < 0',
                        0, N'', @stateId, @stateDate, @stateMaker);
                SELECT @dynamicRuleIdPaymentDateEqualLogicalDateAndNetPaymentGratherThanZero = Id FROM @tempTable;
                DELETE FROM @tempTable
                SELECT @lastAccEngineDynamicRuleId = @lastAccEngineDynamicRuleId + 1
            END;
        ELSE
            BEGIN
                SELECT @dynamicRuleIdPaymentDateEqualLogicalDateAndNetPaymentGratherThanZero = Id
                FROM dbo.AccEngineDynamicRule
                WHERE [Rule] = N'((TxnModel.ReceivePeriodPaymentDate !== null ? TxnModel.ReceivePeriodPaymentDate.getTime() === TxnModel.LogicalDate.getTime() : false) || (TxnModel.PayPeriodPaymentDate !== null ? TxnModel.PayPeriodPaymentDate.getTime() === TxnModel.LogicalDate.getTime() : false)) && TxnModel.NetPeriodFeeAmount < 0'
            END
        ------------------------------------------------------------------------------------------------------------------------

        ------------------------------------------------------------------------------------------------------------------------
        -- TxnModel.ReceiveCurrency !== TxnModel.LocalCCY
        ------------------------------------------------------------------------------------------------------------------------
        IF NOT EXISTS (SELECT 1 FROM dbo.AccEngineDynamicRule WHERE [Rule] = N'TxnModel.ReceiveCurrency !== TxnModel.LocalCCY')
            BEGIN
                INSERT INTO dbo.AccEngineDynamicRule (Id, Name, [Rule], Type, Description, StateId, StateDate, StateMaker)
                OUTPUT inserted.Id INTO @tempTable
                VALUES (@lastAccEngineDynamicRuleId, N'Receive Foreign Currency',
                        N'TxnModel.ReceiveCurrency !== TxnModel.LocalCCY', 0,
                        N'DerivSWP', @StateId, @stateDate, @stateMaker);
                SELECT @dynamicRuleIdReceiveFCY = Id FROM @tempTable;
                DELETE FROM @tempTable;
                SET @lastAccEngineDynamicRuleId = @lastAccEngineDynamicRuleId + 1;
            END
        ELSE
            BEGIN
                SELECT @dynamicRuleIdReceiveFCY = Id
                FROM dbo.AccEngineDynamicRule
                WHERE [Rule] = N'TxnModel.ReceiveCurrency !== TxnModel.LocalCCY';
            END;
        ------------------------------------------------------------------------------------------------------------------------

        ------------------------------------------------------------------------------------------------------------------------
        -- TxnModel.ReceiveCurrency === TxnModel.LocalCCY
        ------------------------------------------------------------------------------------------------------------------------
        IF NOT EXISTS (SELECT 1 FROM dbo.AccEngineDynamicRule WHERE [Rule] = N'TxnModel.ReceiveCurrency === TxnModel.LocalCCY')
            BEGIN
                INSERT INTO dbo.AccEngineDynamicRule (Id, Name, [Rule], Type, Description, StateId, StateDate, StateMaker)
                OUTPUT inserted.Id INTO @tempTable
                VALUES (@lastAccEngineDynamicRuleId, N'Receive Local Currency',
                        N'TxnModel.ReceiveCurrency === TxnModel.LocalCCY', 0,
                        N'DerivSWP', @StateId, @stateDate, @stateMaker);

                SELECT @dynamicRuleIdReceiveLCY = Id FROM @tempTable;
                DELETE FROM @tempTable;
                SET @lastAccEngineDynamicRuleId = @lastAccEngineDynamicRuleId + 1;
            END
        ELSE
            BEGIN
                SELECT @dynamicRuleIdReceiveLCY = Id
                FROM dbo.AccEngineDynamicRule
                WHERE [Rule] = N'TxnModel.ReceiveCurrency === TxnModel.LocalCCY';
            END;
        ------------------------------------------------------------------------------------------------------------------------

        ------------------------------------------------------------------------------------------------------------------------
        -- TxnModel.PayCurrency !== TxnModel.LocalCCY
        ------------------------------------------------------------------------------------------------------------------------
        IF NOT EXISTS (SELECT 1 FROM dbo.AccEngineDynamicRule WHERE [Rule] = N'TxnModel.PayCurrency !== TxnModel.LocalCCY')
            BEGIN
                INSERT INTO dbo.AccEngineDynamicRule (Id, Name, [Rule], Type, Description, StateId, StateDate, StateMaker)
                OUTPUT inserted.Id INTO @tempTable
                VALUES (@lastAccEngineDynamicRuleId, N'Pay Foreign Currency',
                        N'TxnModel.PayCurrency !== TxnModel.LocalCCY', 0,
                        N'DerivSWP', @StateId, @stateDate, @stateMaker);
                SELECT @dynamicRuleIdPayFCY = Id FROM @tempTable;
                DELETE FROM @tempTable;
                SET @lastAccEngineDynamicRuleId = @lastAccEngineDynamicRuleId + 1;
            END
        ELSE
            BEGIN
                SELECT @dynamicRuleIdPayFCY = Id
                FROM dbo.AccEngineDynamicRule
                WHERE [Rule] = N'TxnModel.PayCurrency !== TxnModel.LocalCCY';
            END;
        ------------------------------------------------------------------------------------------------------------------------

        ------------------------------------------------------------------------------------------------------------------------
        -- TxnModel.PayCurrency === TxnModel.LocalCCY
        ------------------------------------------------------------------------------------------------------------------------
        IF NOT EXISTS (SELECT 1 FROM dbo.AccEngineDynamicRule WHERE [Rule] = N'TxnModel.PayCurrency === TxnModel.LocalCCY')
            BEGIN
                INSERT INTO dbo.AccEngineDynamicRule (Id, Name, [Rule], Type, Description, StateId, StateDate, StateMaker)
                OUTPUT inserted.Id INTO @tempTable
                VALUES (@lastAccEngineDynamicRuleId, N'Pay Local Currency',
                        N'TxnModel.PayCurrency === TxnModel.LocalCCY', 0,
                        N'DerivSWP', @StateId, @stateDate, @stateMaker);

                SELECT @dynamicRuleIdPayLCY = Id FROM @tempTable;
                DELETE FROM @tempTable;
                SET @lastAccEngineDynamicRuleId = @lastAccEngineDynamicRuleId + 1;
            END
        ELSE
            BEGIN
                SELECT @dynamicRuleIdPayLCY = Id
                FROM dbo.AccEngineDynamicRule
                WHERE [Rule] = N'TxnModel.PayCurrency === TxnModel.LocalCCY';
            END;
        ------------------------------------------------------------------------------------------------------------------------

        ------------------------------------------------------------------------------------------------------------------------
        -- Derivatives Portfolio = Trade
        ------------------------------------------------------------------------------------------------------------------------
        IF NOT EXISTS (SELECT 1 FROM dbo.AccEngineDynamicRule WHERE [Name] = N'Derivatives Portfolio = Trade' AND [Rule] = N'1===1')
            BEGIN
                INSERT INTO dbo.AccEngineDynamicRule (Id, Name, [Rule], Type, Description, StateId, StateDate, StateMaker)
                OUTPUT inserted.Id INTO @tempTable
                VALUES (@lastAccEngineDynamicRuleId, N'Derivatives Portfolio = Trade',
                        N'1===1', 0,
                        N'Alým Satým Amaçlý Derivatives Ýþlemleri', @StateId, @stateDate, @stateMaker);
                SELECT @dynamicRuleIdTradePortfolio = Id FROM @tempTable;
                DELETE FROM @tempTable;
                SET @lastAccEngineDynamicRuleId = @lastAccEngineDynamicRuleId + 1;
            END
        ELSE
            BEGIN
                SELECT @dynamicRuleIdTradePortfolio = Id
                FROM dbo.AccEngineDynamicRule
                WHERE [Name] = N'Derivatives Portfolio = Trade' AND [Rule] = N'1===1';
            END;
        ------------------------------------------------------------------------------------------------------------------------
    END

    /********** 4. STEP: ACCOUNT MAP *******************************************/
    BEGIN 

		PRINT N'Fee Account Map Inserting..'
        ------------------------------------------------------------------------------------------------------------------------   
        -- Accounting Engine Account Map
        ------------------------------------------------------------------------------------------------------------------------
        -- FeeIncome IRS LCY
        ------------------------------------------------------------------------------------------------------------------------

        PRINT '1 ' +  CAST(@lastAccAccountMapId AS VARCHAR(50))  + N' AccMapId';
        IF NOT EXISTS(SELECT 1
                FROM dbo.AccAccountMap
                WHERE RuleId IS NULL
                AND Rule2Id IS NULL
                AND Rule3Id = @dynamicRuleIdReceiveLCY
                AND Rule4Id = @dynamicRuleIdTradePortfolio
                AND Rule5Id IS NULL
                AND Rule6Id IS NULL
                AND Rule7Id IS NULL
                AND Rule8Id IS NULL
                AND Rule9Id IS NULL
                AND Rule10Id IS NULL
                AND Source = N'FeeIncome'
                AND Path = @pathIRS
                AND TargetMainGL = N'760'
                AND Target = N'76099000'
                AND TargetRuleId IS NULL
                AND CustomerCodeSourceRuleId IS NULL
                AND CustomerAccountCodeSourceRuleId IS NULL)
        BEGIN
            INSERT INTO dbo.AccAccountMap (Id, Ccy, CustomerId, RuleId, Rule2Id, 
                                           Rule3Id, Rule4Id, Rule5Id, Rule6Id, Rule7Id, Rule8Id, Rule9Id, Rule10Id, 
                                           Source, Path, TargetMainGL, Target,
                                           TargetRuleId, IsEnabled, [Order], Description, CustomerCodeSourceRuleId,
                                           CustomerAccountCodeSourceRuleId, StateId, StateMaker, StateDate)
            VALUES (@lastAccAccountMapId, NULL, NULL, NULL, NULL, 
                    @dynamicRuleIdReceiveLCY, @dynamicRuleIdTradePortfolio, NULL, NULL, NULL, NULL, NULL, NULL, 
                    N'FeeIncome', @pathIRS, N'760', N'76099000',
                    NULL, 1, 10, N'', NULL, NULL, 
                    @stateId, @stateMaker, @stateDate);

            SELECT @lastAccAccountMapId = @lastAccAccountMapId + 1;

            PRINT 2 +  @lastAccAccountMapId;
        END
        ------------------------------------------------------------------------------------------------------------------------
        -- FeeIncome IRS FCY 
        ------------------------------------------------------------------------------------------------------------------------
        IF NOT EXISTS(SELECT 1
                FROM dbo.AccAccountMap
                WHERE RuleId IS NULL
                AND Rule2Id IS NULL
                AND Rule3Id = @dynamicRuleIdReceiveFCY
                AND Rule4Id = @dynamicRuleIdTradePortfolio
                AND Rule5Id IS NULL
                AND Rule6Id IS NULL
                AND Rule7Id IS NULL
                AND Rule8Id IS NULL
                AND Rule9Id IS NULL
                AND Rule10Id IS NULL
                AND Source = N'FeeIncome'
                AND Path = @pathIRS
                AND TargetMainGL = N'761'
                AND Target = N'76199000'
                AND TargetRuleId IS NULL
                AND CustomerCodeSourceRuleId IS NULL
                AND CustomerAccountCodeSourceRuleId IS NULL)
        BEGIN
            INSERT INTO dbo.AccAccountMap (Id, Ccy, CustomerId, RuleId, Rule2Id, 
                                           Rule3Id, Rule4Id, Rule5Id, Rule6Id, Rule7Id, Rule8Id, Rule9Id, Rule10Id, 
                                           Source, Path, TargetMainGL, Target,
                                           TargetRuleId, IsEnabled, [Order], Description, CustomerCodeSourceRuleId,
                                           CustomerAccountCodeSourceRuleId, StateId, StateMaker, StateDate)
            VALUES (@lastAccAccountMapId, NULL, NULL, NULL, NULL, 
                    @dynamicRuleIdReceiveFCY, @dynamicRuleIdTradePortfolio, NULL, NULL, NULL, NULL, NULL, NULL, 
                    N'FeeIncome', @pathIRS, N'761', N'76199000',
                    NULL, 1, 20, N'', NULL, NULL, 
                    @stateId, @stateMaker, @stateDate);

            SELECT @lastAccAccountMapId = @lastAccAccountMapId + 1;

            PRINT 3 +  @lastAccAccountMapId;
        END
       ------------------------------------------------------------------------------------------------------------------------
        -- FeeExpense IRS LCY
        ------------------------------------------------------------------------------------------------------------------------
        IF NOT EXISTS(SELECT 1
                FROM dbo.AccAccountMap
                WHERE RuleId IS NULL
                AND Rule2Id IS NULL
                AND Rule3Id = @dynamicRuleIdPayLCY
                AND Rule4Id = @dynamicRuleIdTradePortfolio
                AND Rule5Id IS NULL
                AND Rule6Id IS NULL
                AND Rule7Id IS NULL
                AND Rule8Id IS NULL
                AND Rule9Id IS NULL
                AND Rule10Id IS NULL
                AND Source = N'FeeExpense'
                AND Path = @pathIRS
                AND TargetMainGL = N'840'
                AND Target = N'84099000'
                AND TargetRuleId IS NULL
                AND CustomerCodeSourceRuleId IS NULL
                AND CustomerAccountCodeSourceRuleId IS NULL)
        BEGIN
            INSERT INTO dbo.AccAccountMap (Id, Ccy, CustomerId, RuleId, Rule2Id, 
                                           Rule3Id, Rule4Id, Rule5Id, Rule6Id, Rule7Id, Rule8Id, Rule9Id, Rule10Id, 
                                           Source, Path, TargetMainGL, Target,
                                           TargetRuleId, IsEnabled, [Order], Description, CustomerCodeSourceRuleId,
                                           CustomerAccountCodeSourceRuleId, StateId, StateMaker, StateDate)
            VALUES (@lastAccAccountMapId, NULL, NULL, NULL, NULL, 
                    @dynamicRuleIdPayLCY, @dynamicRuleIdTradePortfolio, NULL, NULL, NULL, NULL, NULL, NULL, 
                    N'FeeExpense', @pathIRS, N'840', N'84099000',
                    NULL, 1, 10, N'', NULL, NULL, 
                    @stateId, @stateMaker, @stateDate);

            SELECT @lastAccAccountMapId = @lastAccAccountMapId + 1;
        END
        ------------------------------------------------------------------------------------------------------------------------
        -- FeeExpense IRS FCY
        ------------------------------------------------------------------------------------------------------------------------
        IF NOT EXISTS(SELECT 1
                FROM dbo.AccAccountMap
                WHERE RuleId IS NULL
                AND Rule2Id IS NULL
                AND Rule3Id = @dynamicRuleIdPayFCY
                AND Rule4Id = @dynamicRuleIdTradePortfolio
                AND Rule5Id IS NULL
                AND Rule6Id IS NULL
                AND Rule7Id IS NULL
                AND Rule8Id IS NULL
                AND Rule9Id IS NULL
                AND Rule10Id IS NULL
                AND Source = N'FeeExpense'
                AND Path = @pathIRS
                AND TargetMainGL = N'841'
                AND Target = N'84199000'
                AND TargetRuleId IS NULL
                AND CustomerCodeSourceRuleId IS NULL
                AND CustomerAccountCodeSourceRuleId IS NULL)
        BEGIN
            INSERT INTO dbo.AccAccountMap (Id, Ccy, CustomerId, RuleId, Rule2Id, 
                                           Rule3Id, Rule4Id, Rule5Id, Rule6Id, Rule7Id, Rule8Id, Rule9Id, Rule10Id, 
                                           Source, Path, TargetMainGL, Target,
                                           TargetRuleId, IsEnabled, [Order], Description, CustomerCodeSourceRuleId,
                                           CustomerAccountCodeSourceRuleId, StateId, StateMaker, StateDate)
            VALUES (@lastAccAccountMapId, NULL, NULL, NULL, NULL, 
                    @dynamicRuleIdPayFCY, @dynamicRuleIdTradePortfolio, NULL, NULL, NULL, NULL, NULL, NULL, 
                    N'FeeExpense', @pathIRS, N'841', N'84199000',
                    NULL, 1, 20, N'', NULL, NULL, 
                    @stateId, @stateMaker, @stateDate);

            SET @lastAccAccountMapId = @lastAccAccountMapId + 1;
        
        END
        ------------------------------------------------------------------------------------------------------------------------


        ------------------------------------------------------------------------------------------------------------------------
        -- FeeIncome CCS LCY
        ------------------------------------------------------------------------------------------------------------------------
        IF NOT EXISTS(SELECT 1
                FROM dbo.AccAccountMap
                WHERE RuleId IS NULL
                AND Rule2Id IS NULL
                AND Rule3Id = @dynamicRuleIdReceiveLCY
                AND Rule4Id = @dynamicRuleIdTradePortfolio
                AND Rule5Id IS NULL
                AND Rule6Id IS NULL
                AND Rule7Id IS NULL
                AND Rule8Id IS NULL
                AND Rule9Id IS NULL
                AND Rule10Id IS NULL
                AND Source = N'FeeIncome'
                AND Path = @pathCCS
                AND TargetMainGL = N'760'
                AND Target = N'76099000'
                AND TargetRuleId IS NULL
                AND CustomerCodeSourceRuleId IS NULL
                AND CustomerAccountCodeSourceRuleId IS NULL)
        BEGIN
            INSERT INTO dbo.AccAccountMap (Id, Ccy, CustomerId, RuleId, Rule2Id, 
                                           Rule3Id, Rule4Id, Rule5Id, Rule6Id, Rule7Id, Rule8Id, Rule9Id, Rule10Id, 
                                           Source, Path, TargetMainGL, Target,
                                           TargetRuleId, IsEnabled, [Order], Description, CustomerCodeSourceRuleId,
                                           CustomerAccountCodeSourceRuleId, StateId, StateMaker, StateDate)
            VALUES (@lastAccAccountMapId, NULL, NULL, NULL, NULL, 
                    @dynamicRuleIdReceiveLCY, @dynamicRuleIdTradePortfolio, NULL, NULL, NULL, NULL, NULL, NULL, 
                    N'FeeIncome', @pathCCS, N'760', N'76099000',
                    NULL, 1, 10, N'', NULL, NULL, 
                    @stateId, @stateMaker, @stateDate);

            SET @lastAccAccountMapId = @lastAccAccountMapId + 1;
        END
        ------------------------------------------------------------------------------------------------------------------------
        -- FeeIncome CCS FCY 
        ------------------------------------------------------------------------------------------------------------------------
        IF NOT EXISTS(SELECT 1
                FROM dbo.AccAccountMap
                WHERE RuleId IS NULL
                AND Rule2Id IS NULL
                AND Rule3Id = @dynamicRuleIdReceiveFCY
                AND Rule4Id = @dynamicRuleIdTradePortfolio
                AND Rule5Id IS NULL
                AND Rule6Id IS NULL
                AND Rule7Id IS NULL
                AND Rule8Id IS NULL
                AND Rule9Id IS NULL
                AND Rule10Id IS NULL
                AND Source = N'FeeIncome'
                AND Path = @pathCCS
                AND TargetMainGL = N'761'
                AND Target = N'76199000'
                AND TargetRuleId IS NULL
                AND CustomerCodeSourceRuleId IS NULL
                AND CustomerAccountCodeSourceRuleId IS NULL)
        BEGIN
            INSERT INTO dbo.AccAccountMap (Id, Ccy, CustomerId, RuleId, Rule2Id, 
                                           Rule3Id, Rule4Id, Rule5Id, Rule6Id, Rule7Id, Rule8Id, Rule9Id, Rule10Id, 
                                           Source, Path, TargetMainGL, Target,
                                           TargetRuleId, IsEnabled, [Order], Description, CustomerCodeSourceRuleId,
                                           CustomerAccountCodeSourceRuleId, StateId, StateMaker, StateDate)
            VALUES (@lastAccAccountMapId, NULL, NULL, NULL, NULL, 
                    @dynamicRuleIdReceiveFCY, @dynamicRuleIdTradePortfolio, NULL, NULL, NULL, NULL, NULL, NULL, 
                    N'FeeIncome', @pathCCS, N'761', N'76199000',
                    NULL, 1, 20, N'', NULL, NULL, 
                    @stateId, @stateMaker, @stateDate);

            SET @lastAccAccountMapId = @lastAccAccountMapId + 1;
        END
       ------------------------------------------------------------------------------------------------------------------------
        -- FeeExpense CCS LCY
        ------------------------------------------------------------------------------------------------------------------------
        IF NOT EXISTS(SELECT 1
                FROM dbo.AccAccountMap
                WHERE RuleId IS NULL
                AND Rule2Id IS NULL
                AND Rule3Id = @dynamicRuleIdPayLCY
                AND Rule4Id = @dynamicRuleIdTradePortfolio
                AND Rule5Id IS NULL
                AND Rule6Id IS NULL
                AND Rule7Id IS NULL
                AND Rule8Id IS NULL
                AND Rule9Id IS NULL
                AND Rule10Id IS NULL
                AND Source = N'FeeExpense'
                AND Path = @pathCCS
                AND TargetMainGL = N'840'
                AND Target = N'84099000'
                AND TargetRuleId IS NULL
                AND CustomerCodeSourceRuleId IS NULL
                AND CustomerAccountCodeSourceRuleId IS NULL)
        BEGIN
            INSERT INTO dbo.AccAccountMap (Id, Ccy, CustomerId, RuleId, Rule2Id, 
                                           Rule3Id, Rule4Id, Rule5Id, Rule6Id, Rule7Id, Rule8Id, Rule9Id, Rule10Id, 
                                           Source, Path, TargetMainGL, Target,
                                           TargetRuleId, IsEnabled, [Order], Description, CustomerCodeSourceRuleId,
                                           CustomerAccountCodeSourceRuleId, StateId, StateMaker, StateDate)
            VALUES (@lastAccAccountMapId, NULL, NULL, NULL, NULL, 
                    @dynamicRuleIdPayLCY, @dynamicRuleIdTradePortfolio, NULL, NULL, NULL, NULL, NULL, NULL, 
                    N'FeeExpense', @pathCCS, N'840', N'84099000',
                    NULL, 1, 10, N'', NULL, NULL, 
                    @stateId, @stateMaker, @stateDate);

            SET @lastAccAccountMapId = @lastAccAccountMapId + 1;
        END
        ------------------------------------------------------------------------------------------------------------------------
        -- FeeExpense IRS FCY
        ------------------------------------------------------------------------------------------------------------------------
        IF NOT EXISTS(SELECT 1
                FROM dbo.AccAccountMap
                WHERE RuleId IS NULL
                AND Rule2Id IS NULL
                AND Rule3Id = @dynamicRuleIdPayFCY
                AND Rule4Id = @dynamicRuleIdTradePortfolio
                AND Rule5Id IS NULL
                AND Rule6Id IS NULL
                AND Rule7Id IS NULL
                AND Rule8Id IS NULL
                AND Rule9Id IS NULL
                AND Rule10Id IS NULL
                AND Source = N'FeeExpense'
                AND Path = @pathCCS
                AND TargetMainGL = N'841'
                AND Target = N'84199000'
                AND TargetRuleId IS NULL
                AND CustomerCodeSourceRuleId IS NULL
                AND CustomerAccountCodeSourceRuleId IS NULL)
        BEGIN
            INSERT INTO dbo.AccAccountMap (Id, Ccy, CustomerId, RuleId, Rule2Id, 
                                           Rule3Id, Rule4Id, Rule5Id, Rule6Id, Rule7Id, Rule8Id, Rule9Id, Rule10Id, 
                                           Source, Path, TargetMainGL, Target,
                                           TargetRuleId, IsEnabled, [Order], Description, CustomerCodeSourceRuleId,
                                           CustomerAccountCodeSourceRuleId, StateId, StateMaker, StateDate)
            VALUES (@lastAccAccountMapId, NULL, NULL, NULL, NULL, 
                    @dynamicRuleIdPayFCY, @dynamicRuleIdTradePortfolio, NULL, NULL, NULL, NULL, NULL, NULL, 
                    N'FeeExpense', @pathCCS, N'841', N'84199000',
                    NULL, 1, 20, N'', NULL, NULL, 
                    @stateId, @stateMaker, @stateDate);

            SET @lastAccAccountMapId = @lastAccAccountMapId + 1;
        
        END
        ------------------------------------------------------------------------------------------------------------------------

		PRINT N'Fee Account Map insert FINISH'
	END

    /********** 5. STEP: FEE EVENTS ********************************************/
    BEGIN 
		PRINT N'Fee Event insert starting..'

		DECLARE @tempEvent TABLE (Id INT IDENTITY(1,1), ItemPath NVARCHAR(1000), EventTypeCode NVARCHAR(255));
		INSERT INTO @tempEvent VALUES
        (N'TREX/DV/IRS/LCYRLCYP/', 'OnFee'),
        (N'TREX/DV/IRS/FCYRFCYP/', 'OnFee'),
        (N'TREX/DV/CCS/LCYRFCYP/', 'OnFee'),
        (N'TREX/DV/CCS/FCYRLCYP/', 'OnFee'),
        (N'TREX/DV/CCS/FCYRFCYP/', 'OnFee');
       
        DECLARE @EventTypeCode NVARCHAR(255);
        DECLARE @ItemPath NVARCHAR(1000);
        DECLARE @ItemId INT;
        SELECT @count = COUNT(*) FROM @tempEvent;

		SET @i= 1;
		WHILE @i <= @count
		BEGIN

            SELECT @EventTypeCode = EventTypeCode, @ItemPath = ItemPath FROM @tempEvent WHERE Id = @i;
            SELECT @ItemId = Id FROM AccEngineItem WHERE Path = @ItemPath;

			IF NOT EXISTS (SELECT 1 
                           FROM accEngineEvent 
                           WHERE [EventTypeCode] = @EventTypeCode 
                            AND ItemId = @ItemId)
			BEGIN
                INSERT INTO dbo.AccEngineEvent (Id, ItemId, EventTypeCode, ModifiedBy, ModifiedDate,
                                                EventDescriptionDynamicRuleId)
                VALUES(@lastAccEngineEventId, @ItemId, @EventTypeCode, @stateMaker, @stateDate, null);

				SET @lastAccEngineEventId = @lastAccEngineEventId + 1;

                PRINT @ItemPath + N' ' +  @EventTypeCode + ' Event inserted..'
			END

            SET @i += 1;
		END
		
        PRINT N'Fee Event insert FINISH'
	END

    /********** 6. STEP: FEE GROUPS ********************************************/
    BEGIN
        PRINT N'Fee Group insert starting..'

        DECLARE @tempGroup TABLE (Id INT IDENTITY(1,1), ItemPath NVARCHAR(1000), EventTypeCode NVARCHAR(255), GroupPreVal NVARCHAR(255), GroupOrder INT);
		INSERT INTO @tempGroup VALUES
        (N'TREX/DV/IRS/LCYRLCYP/', 'OnFee', NULL, 1),
        (N'TREX/DV/IRS/FCYRFCYP/', 'OnFee', NULL, 1),
        (N'TREX/DV/CCS/LCYRFCYP/', 'OnFee', NULL, 1),
        (N'TREX/DV/CCS/FCYRLCYP/', 'OnFee', NULL, 1),
        (N'TREX/DV/CCS/FCYRFCYP/', 'OnFee', NULL, 1);
       
        DECLARE @GroupValRuleId INT, @GroupOrder INT, @EventId INT;
        DECLARE @GrpPreval NVARCHAR(255);
        SELECT @count = COUNT(*) FROM @tempGroup;

        SET @i= 1;
		WHILE @i <= @count
		BEGIN
            SELECT @ItemPath = ItemPath, @EventTypeCode = EventTypeCode, @GrpPreval = GroupPreVal, @GroupOrder = GroupOrder FROM @tempGroup WHERE Id = @i;

            SELECT @EventId = vnt.Id FROM AccEngineEvent vnt
            JOIN dbo.AccEngineItem item on item.Id = vnt.ItemId 
            WHERE item.Path = @ItemPath
            AND vnt.EventTypeCode = @EventTypeCode;

            SET @GroupValRuleId = COALESCE((SELECT Id FROM dbo.AccEngineDynamicRule WHERE [Name] = @GrpPreval), NULL);

            IF NOT EXISTS (SELECT 1 FROM dbo.AccEngineGroup grp
                            WHERE grp.EventId = @EventId
                                  AND ISNULL(grp.ValidationRuleId, -1) = ISNULL(@GroupValRuleId, -1)
                           )
			BEGIN
                INSERT INTO dbo.AccEngineGroup (Id, EventId, ValidationRuleId, [Order],
                                                ModifiedBy,
                                                ModifiedDate,
                                                StateId,
                                                StateDate,
                                                StateMaker)
                VALUES (@lastAccEngineGroupId, @EventId,
                        @GroupValRuleId, @GroupOrder,
                        @stateMaker,
                        @stateDate,
                        @StateId,
                        @stateDate,
                        @stateMaker);

				SET @lastAccEngineGroupId = @lastAccEngineGroupId + 1;

                PRINT @ItemPath + N' ' +  @EventTypeCode + ' Group inserted..'           
			END

            SET @i += 1;
		END
		
        PRINT N'Fee Group insert FINISH'

    END

    /********** 7. STEP: FEE COMPONENTS ****************************************/
    BEGIN
        PRINT N'Fee Component insert starting..'

        DECLARE @tempComponent TABLE (
            Id INT IDENTITY(1,1),
			ItemPath nvarchar(1000),
			EventTypeCode nvarchar(255),
			GroupPreVal nvarchar(255),
			ComponentTypeCode nvarchar(255),
			ComponentPreVal nvarchar(255),
			ComponentOrder int
		);
		INSERT INTO @tempComponent VALUES
        --IRS FEE Components
        (N'TREX/DV/IRS/LCYRLCYP/', 'OnFee', NULL, '602', 'PeriodPaymentDate = LogicalDate && NetPayment > 0', 1),
        (N'TREX/DV/IRS/LCYRLCYP/', 'OnFee', NULL, '603', 'PeriodPaymentDate = LogicalDate && NetPayment < 0', 2),
        (N'TREX/DV/IRS/FCYRFCYP/', 'OnFee', NULL, '602', 'PeriodPaymentDate = LogicalDate && NetPayment > 0', 1),
        (N'TREX/DV/IRS/FCYRFCYP/', 'OnFee', NULL, '603', 'PeriodPaymentDate = LogicalDate && NetPayment < 0', 2),
        --CCS FEE Components
        (N'TREX/DV/CCS/LCYRFCYP/', 'OnFee', NULL, '602', 'ReceivePeriodPaymentDate = LogicalDate', 1),
        (N'TREX/DV/CCS/LCYRFCYP/', 'OnFee', NULL, '603', 'PayPeriodPaymentDate = LogicalDate', 2),
        (N'TREX/DV/CCS/FCYRLCYP/', 'OnFee', NULL, '602', 'ReceivePeriodPaymentDate = LogicalDate', 1),
        (N'TREX/DV/CCS/FCYRLCYP/', 'OnFee', NULL, '603', 'PayPeriodPaymentDate = LogicalDate', 2),
        (N'TREX/DV/CCS/FCYRFCYP/', 'OnFee', NULL, '602', 'ReceivePeriodPaymentDate = LogicalDate', 1),
        (N'TREX/DV/CCS/FCYRFCYP/', 'OnFee', NULL, '603', 'PayPeriodPaymentDate = LogicalDate', 2);
       
        DECLARE @GroupId INT, @ComponentOrder INT, @ComponentValRuleId INT;
        DECLARE @ComponentTypeCode NVARCHAR(255), @ComponentPreVal NVARCHAR(255);
        SELECT @count = COUNT(*) FROM @tempComponent;

        SET @i= 1;
		WHILE @i <= @count
		BEGIN
            SELECT 
                @ItemPath = ItemPath, 
                @EventTypeCode = EventTypeCode, 
                @GrpPreval = GroupPreVal, 
                @ComponentTypeCode = ComponentTypeCode,
                @ComponentPreVal = ComponentPreVal,
                @ComponentOrder = ComponentOrder
            FROM @tempComponent WHERE Id = @i;

            SET @GroupValRuleId = COALESCE((SELECT Id FROM dbo.AccEngineDynamicRule WHERE [Name] = @GrpPreval), NULL);
            SET @ComponentValRuleId = COALESCE((SELECT Id FROM dbo.AccEngineDynamicRule WHERE [Name] = @ComponentPreVal), NULL);

            SELECT @GroupId = grp.Id FROM dbo.AccEngineGroup grp
            JOIN dbo.AccEngineEvent vnt on vnt.Id = grp.EventId
            JOIN dbo.AccEngineItem item on item.Id = vnt.ItemId
            WHERE item.Path = @ItemPath
            AND vnt.EventTypeCode = @EventTypeCode
            AND ISNULL(grp.ValidationRuleId, -1) = ISNULL(@GroupValRuleId, -1);

            IF NOT EXISTS (SELECT 1 FROM dbo.AccEngineComponent com
                            WHERE com.GroupId = @GroupId
                                  AND com.ComponentTypeCode = @ComponentTypeCode
                                  AND ISNULL(com.ValidationRuleId, -1) = ISNULL(@ComponentValRuleId, -1)
                           )
			BEGIN
                INSERT INTO dbo.AccEngineComponent (Id, GroupId, ComponentTypeCode, ValidationRuleId, [Order],
                                                    ModifiedBy,
                                                    ModifiedDate)
                VALUES (@lastAccEngineComponentId, @GroupId, @ComponentTypeCode,
                        @ComponentValRuleId,
                        @ComponentOrder,
                        @stateMaker,
                        @stateDate);

                SET @lastAccEngineComponentId = @lastAccEngineComponentId + 1

                PRINT @ItemPath + N' ' +  @EventTypeCode +  ' Component inserted..'
			END

            SET @i += 1;
		END
		
        PRINT N'Fee Component insert FINISH'
    END

    /********** 8. STEP: FEE ACCOUNT RULES *************************************/
    BEGIN
        PRINT N'Fee Account Rule insert starting..'

        DECLARE @tempAccRule TABLE (
            Id INT IDENTITY(1,1),
			ItemPath nvarchar(255),
			EventTypeCode nvarchar(255),
			GroupPreVal nvarchar(255),
			ComponentTypeCode nvarchar(255),
			ComponentPreVal nvarchar(255),
			GLCode nvarchar(255),
			DebitCredit nvarchar(255),
			AmountSource nvarchar(255),
			CcySource nvarchar(255)
		);
		INSERT INTO @tempAccRule VALUES
        --IRS LCYRLCYP Rules
        (N'TREX/DV/IRS/LCYRLCYP/', 'OnFee', NULL, '602', N'PeriodPaymentDate = LogicalDate && NetPayment > 0', N'IncomingPaymentLCY', N'Debit', N'NetPeriodFeeAmount', N'ReceiveCurrency'),
        (N'TREX/DV/IRS/LCYRLCYP/', 'OnFee', NULL, '602', N'PeriodPaymentDate = LogicalDate && NetPayment > 0', N'FeeIncome', N'Credit', N'NetPeriodFeeAmountLCY', N'ReceiveCurrency'),

        (N'TREX/DV/IRS/LCYRLCYP/', 'OnFee', NULL, '603', N'PeriodPaymentDate = LogicalDate && NetPayment < 0', N'OutgoingPaymentLCY', N'Credit', N'NetPeriodFeeAmount', N'PayCurrency'),
        (N'TREX/DV/IRS/LCYRLCYP/', 'OnFee', NULL, '603', N'PeriodPaymentDate = LogicalDate && NetPayment < 0', N'FeeExpense', N'Debit', N'NetPeriodFeeAmountLCY', N'PayCurrency'),

        --IRS FCYRFCYP Rules
        (N'TREX/DV/IRS/FCYRFCYP/', 'OnFee', NULL, '602', N'PeriodPaymentDate = LogicalDate && NetPayment > 0', N'IncomingPaymentFCY', N'Debit', N'NetPeriodFeeAmount', N'ReceiveCurrency'),
        (N'TREX/DV/IRS/FCYRFCYP/', 'OnFee', NULL, '602', N'PeriodPaymentDate = LogicalDate && NetPayment > 0', N'FeeIncome', N'Credit', N'NetPeriodFeeAmountLCY', N'ReceiveCurrency'),
        (N'TREX/DV/IRS/FCYRFCYP/', 'OnFee', NULL, '602', N'PeriodPaymentDate = LogicalDate && NetPayment > 0', N'FXPositionRec', N'Credit', N'NetPeriodFeeAmount', N'ReceiveCurrency'),
        (N'TREX/DV/IRS/FCYRFCYP/', 'OnFee', NULL, '602', N'PeriodPaymentDate = LogicalDate && NetPayment > 0', N'FXPositionLCY', N'Debit', N'NetPeriodFeeAmountLCY', N'ReceiveCurrency'),

        (N'TREX/DV/IRS/FCYRFCYP/', 'OnFee', NULL, '603', N'PeriodPaymentDate = LogicalDate && NetPayment < 0', N'OutgoingPaymentFCY', N'Credit', N'NetPeriodFeeAmount', N'PayCurrency'),
        (N'TREX/DV/IRS/FCYRFCYP/', 'OnFee', NULL, '603', N'PeriodPaymentDate = LogicalDate && NetPayment < 0', N'FeeExpense', N'Debit', N'NetPeriodFeeAmountLCY', N'PayCurrency'),
        (N'TREX/DV/IRS/FCYRFCYP/', 'OnFee', NULL, '603', N'PeriodPaymentDate = LogicalDate && NetPayment < 0', N'FXPositionPay', N'Debit', N'NetPeriodFeeAmount', N'PayCurrency'),
        (N'TREX/DV/IRS/FCYRFCYP/', 'OnFee', NULL, '603', N'PeriodPaymentDate = LogicalDate && NetPayment < 0', N'FXPositionLCY', N'Credit', N'NetPeriodFeeAmountLCY', N'PayCurrency'),
        
        --CCS LCYRFCYP Rules
        (N'TREX/DV/CCS/LCYRFCYP/', 'OnFee', NULL, '602', N'ReceivePeriodPaymentDate = LogicalDate', N'IncomingPaymentLCY', N'Debit', N'ReceiveFeeAmount', N'ReceiveCurrency'),
        (N'TREX/DV/CCS/LCYRFCYP/', 'OnFee', NULL, '602', N'ReceivePeriodPaymentDate = LogicalDate', N'FeeIncome', N'Credit', N'ReceiveFeeAmountLCY', N'LocalCCY'),
        (N'TREX/DV/CCS/LCYRFCYP/', 'OnFee', NULL, '603', N'PayPeriodPaymentDate = LogicalDate', N'OutgoingPaymentFCY', N'Credit', N'PayFeeAmount', N'PayCurrency'),
        (N'TREX/DV/CCS/LCYRFCYP/', 'OnFee', NULL, '603', N'PayPeriodPaymentDate = LogicalDate', N'FeeExpense', N'Debit', N'PayFeeAmountLCY', N'LocalCCY'),
        (N'TREX/DV/CCS/LCYRFCYP/', 'OnFee', NULL, '603', N'PayPeriodPaymentDate = LogicalDate', N'FXPositionPay', N'Debit', N'PayFeeAmount', N'PayCurrency'),
        (N'TREX/DV/CCS/LCYRFCYP/', 'OnFee', NULL, '603', N'PayPeriodPaymentDate = LogicalDate', N'FXPositionLCY', N'Credit', N'PayFeeAmountLCY', N'LocalCCY'),

        --CCS FCYRLCYP Rules
        (N'TREX/DV/CCS/FCYRLCYP/', 'OnFee', NULL, '602', N'ReceivePeriodPaymentDate = LogicalDate', N'IncomingPaymentFCY', N'Debit', N'ReceiveFeeAmount', N'ReceiveCurrency'),
        (N'TREX/DV/CCS/FCYRLCYP/', 'OnFee', NULL, '602', N'ReceivePeriodPaymentDate = LogicalDate', N'FeeIncome', N'Credit', N'ReceiveFeeAmountLCY', N'LocalCCY'),
        (N'TREX/DV/CCS/FCYRLCYP/', 'OnFee', NULL, '602', N'ReceivePeriodPaymentDate = LogicalDate', N'FXPositionRec', N'Credit', N'ReceiveFeeAmount', N'ReceiveCurrency'),
        (N'TREX/DV/CCS/FCYRLCYP/', 'OnFee', NULL, '602', N'ReceivePeriodPaymentDate = LogicalDate', N'FXPositionLCY', N'Debit', N'ReceiveFeeAmountLCY', N'LocalCCY'),
        (N'TREX/DV/CCS/FCYRLCYP/', 'OnFee', NULL, '603', N'PayPeriodPaymentDate = LogicalDate', N'OutgoingPaymentLCY', N'Credit', N'PayFeeAmount', N'PayCurrency'),
        (N'TREX/DV/CCS/FCYRLCYP/', 'OnFee', NULL, '603', N'PayPeriodPaymentDate = LogicalDate', N'FeeExpense', N'Debit', N'PayFeeAmount', N'PayCurrency'),

        --CCS FCYRFCYP Rules
        (N'TREX/DV/CCS/FCYRFCYP/', 'OnFee', NULL, '602', N'ReceivePeriodPaymentDate = LogicalDate', N'IncomingPaymentFCY', N'Debit', N'ReceiveFeeAmount', N'ReceiveCurrency'),
        (N'TREX/DV/CCS/FCYRFCYP/', 'OnFee', NULL, '602', N'ReceivePeriodPaymentDate = LogicalDate', N'FXPositionRec', N'Credit', N'ReceiveFeeAmount', N'ReceiveCurrency'),
        (N'TREX/DV/CCS/FCYRFCYP/', 'OnFee', NULL, '602', N'ReceivePeriodPaymentDate = LogicalDate', N'FeeIncome', N'Credit', N'ReceiveFeeAmountLCY', N'LocalCCY'),
        (N'TREX/DV/CCS/FCYRFCYP/', 'OnFee', NULL, '602', N'ReceivePeriodPaymentDate = LogicalDate', N'FXPositionLCY', N'Debit', N'ReceiveFeeAmountLCY', N'LocalCCY'),
        (N'TREX/DV/CCS/FCYRFCYP/', 'OnFee', NULL, '603', N'PayPeriodPaymentDate = LogicalDate', N'OutgoingPaymentFCY', N'Credit', N'PayFeeAmount', N'PayCurrency'),
        (N'TREX/DV/CCS/FCYRFCYP/', 'OnFee', NULL, '603', N'PayPeriodPaymentDate = LogicalDate', N'FXPositionPay', N'Debit', N'PayFeeAmount', N'PayCurrency'),
        (N'TREX/DV/CCS/FCYRFCYP/', 'OnFee', NULL, '603', N'PayPeriodPaymentDate = LogicalDate', N'FeeExpense', N'Debit', N'PayFeeAmountLCY', N'LocalCCY'),
        (N'TREX/DV/CCS/FCYRFCYP/', 'OnFee', NULL, '603', N'PayPeriodPaymentDate = LogicalDate', N'FXPositionLCY', N'Credit', N'PayFeeAmountLCY', N'LocalCCY');
       
        DECLARE @ComponentId INT;
        DECLARE @DebitCredit NVARCHAR(255), @AmountSource NVARCHAR(255), @CcySource NVARCHAR(255);
        SELECT @count = COUNT(*) FROM @tempAccRule;

        SET @i= 1;
		WHILE @i <= @count
		BEGIN
            SELECT 
                @ItemPath = ItemPath, 
                @EventTypeCode = EventTypeCode, 
                @GrpPreval = GroupPreVal, 
                @ComponentTypeCode = ComponentTypeCode,
                @ComponentPreVal = ComponentPreVal,
                @GLCode = GLCode,
                @DebitCredit = DebitCredit,
                @AmountSource = AmountSource,
                @CcySource = CcySource
            FROM @tempAccRule WHERE Id = @i;

            SET @GroupValRuleId = COALESCE((SELECT Id FROM dbo.AccEngineDynamicRule WHERE [Name] = @GrpPreval), NULL);
            SET @ComponentValRuleId = COALESCE((SELECT Id FROM dbo.AccEngineDynamicRule WHERE [Name] = @ComponentPreVal), NULL);

            SELECT @ComponentId = cmp.Id FROM dbo.AccEngineComponent cmp
            JOIN dbo.AccEngineGroup grp on grp.Id = cmp.GroupId
            JOIN dbo.AccEngineEvent vnt on vnt.Id = grp.EventId
            JOIN dbo.AccEngineItem item on item.Id = vnt.ItemId
            WHERE item.Path = @ItemPath
            AND vnt.EventTypeCode = @EventTypeCode
            AND ISNULL(grp.ValidationRuleId, -1) = ISNULL(@GroupValRuleId, -1)
            AND cmp.ComponentTypeCode = @ComponentTypeCode
            AND ISNULL(cmp.ValidationRuleId, -1) = ISNULL(@ComponentValRuleId, -1);

            IF NOT EXISTS (SELECT 1 FROM dbo.AccEngineAccountRule rl
                            WHERE rl.ComponentId = @ComponentId
                                  AND rl.GLCode = @GlCode
                                  AND rl.DebitCredit = @DebitCredit
                                  AND rl.AmountSource = @AmountSource
                                  AND rl.CcySource = @CcySource)
			BEGIN
                INSERT INTO dbo.AccEngineAccountRule(Id, ComponentId, GLCode, CustomerCodeSource, CustomerAccountCodeSource,
                                                    DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                    ValueDateSource, TxnDateSource, CcySource, FcySource, LcyEqvtSource,
                                                    FcyAmtSource, ReverseRebook, CommentSource, CommentRuleId, ModifiedBy,
                                                    ModifiedDate, ReverseTxnDateSource, ReverseValueDateSource)
                VALUES (@lastAccEngineAccountRuleId, @ComponentId, @GLCode, null, null,
                        @DebitCredit, null, @AmountSource, N'TxnNo', 
                        N'LogicalDate', N'LogicalDate', @CcySource, @CcySource, @AmountSource, 
                        @AmountSource, 0, null, null, @stateMaker,
                        @stateDate, null, null);

                SELECT @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1

                PRINT @ItemPath + N' ' +  @EventTypeCode + ' Account Rule inserted..'
			END

            SET @i += 1;
		END
		
        PRINT N'Fee Account Rule insert FINISH'
    END

    /********** 9. STEP: NUMBER GENERATION UPDATE ******************************/
    BEGIN
        ------------------------------------------------------------------------------------------------------------------------
        -- Definition Number Generation Update
        ------------------------------------------------------------------------------------------------------------------------
        update dbo.defNumberGen
        SET LastNumber     = @lastAccEngineDynamicRuleId,
            LastUpdateDate = @stateDate
        WHERE EntityColumnType = @accEngineDynamicRuleColumnTypeId

        update dbo.defNumberGen
        SET LastNumber     = @lastAccAccountMapId,
            LastUpdateDate = @stateDate
        WHERE EntityColumnType = @accAccountMapColumnTypeId

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
    END

	COMMIT TRANSACTION;
END TRY
BEGIN CATCH
	PRINT 'rollback';
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    PRINT ERROR_MESSAGE();
	throw;
END CATCH;

