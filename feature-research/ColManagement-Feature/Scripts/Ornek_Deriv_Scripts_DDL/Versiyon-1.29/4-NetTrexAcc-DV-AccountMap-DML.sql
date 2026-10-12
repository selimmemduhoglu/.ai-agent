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
        @path NVARCHAR(80) = 'TREX/DV';

    DECLARE
        @lastAccEngineDynamicRuleId INT = 0,
        @accEngineDynamicRuleColumnTypeId INT = 1,
        @lastAccAccountMapId INT = 0,
        @accAccountMapColumnTypeId INT = 11;

    DECLARE
        @dynamicRuleExternalCustomerId INT = 0,
        @dynamicRuleIsCustomerId INT = 0,
        @dynamicRuleIsFinancialInstitutionId INT = 0,
        @dynamicRuleIsimmediateIncomingPaymentId INT = 0,
        @dynamicRuleIsimmediateOutgoingPaymentId INT = 0,
        @dynamicRuleIsDeferredIncomingPaymentId INT = 0,
        @dynamicRuleIsDeferredOutgoingPaymentId INT = 0,
        @dynamicRuleIncomingExternalCustomerGLAccountId INT = 0,
        @dynamicRuleIncomingExternalCustomerAccountNoId INT = 0,
        @dynamicRuleOutgoingExternalCustomerAccountNoId INT = 0,
        @dynamicRuleOutgoingExternalCustomerGLAccountId INT = 0,
        @dynamicRuleIncomingPaymentInstructionTypeEqualB2BId INT = 0,
        @dynamicRuleOutgoingPaymentInstructionTypeEqualB2BId INT = 0,
        @dynamicRuleIncomingPaymentInstructionTypeEqualA2AId INT = 0,
        @dynamicRuleOutgoingPaymentInstructionTypeEqualA2AId INT = 0,
        @dynamicRuleIncomingPaymentInstructionTypeEqualV2VId INT = 0,
        @dynamicRuleOutgoingPaymentInstructionTypeEqualV2VId INT = 0,
        @dynamicRuleIncomingSettlementTypeEqualGrossId INT = 0,
        @dynamicRuleOutgoingSettlementTypeEqualGrossId INT = 0,
        @dynamicRuleIncomingSettlementTypeEqualNettingId INT = 0,
        @dynamicRuleOutgoingSettlementTypeEqualNettingId INT = 0;

    ------------------------------------------------------------------------------------------------------------------------
    -- Definition Number Generation
    ------------------------------------------------------------------------------------------------------------------------
    --#region DefNumberGen
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
    -- Accounting Account Map Last Number
    ------------------------------------------------------------------------------------------------------------------------
    SELECT @lastAccAccountMapId = LastNumber + 1
    FROM dbo.DefNumberGen
    WHERE EntityColumnType = @accAccountMapColumnTypeId
      AND Definition = N'AccAccountMap Id'

    IF (@lastAccEngineDynamicRuleId = 0)
        THROW 500001, 'AccAccountMap Last Id Not Found', 1
    --#endregion
    ------------------------------------------------------------------------------------------------------------------------
    -- Accounting Engine Dynamic Rule
    ------------------------------------------------------------------------------------------------------------------------
    --#region AccEngineDynamicRule
    ------------------------------------------------------------------------------------------------------------------------
    -- ExternalCustomerNo => TxnModel.ExternalCustomerNo
    ------------------------------------------------------------------------------------------------------------------------
    IF NOT EXISTS (SELECT 1 FROM dbo.AccEngineDynamicRule WHERE [Rule] = N'TxnModel.ExternalCustomerNo')
        BEGIN
            INSERT INTO dbo.AccEngineDynamicRule (Id, Name, [Rule], Type, Description, StateId, StateDate, StateMaker)
            OUTPUT inserted.Id INTO @tempTable
            VALUES (@lastAccEngineDynamicRuleId, N'ExternalCustomerNo',
                    N'TxnModel.ExternalCustomerNo', 1,
                    N'', @StateId, @stateDate, @stateMaker);
            SELECT @dynamicRuleExternalCustomerId = Id FROM @tempTable;
            DELETE FROM @tempTable;
            SET @lastAccEngineDynamicRuleId = @lastAccEngineDynamicRuleId + 1;
        END
    ELSE
        BEGIN
            SELECT @dynamicRuleExternalCustomerId = Id
            FROM dbo.AccEngineDynamicRule
            WHERE [Rule] = N'TxnModel.ExternalCustomerNo';
        END;
    ------------------------------------------------------------------------------------------------------------------------
    -- IsCustomer => TxnModel.IsFinancialInstitution === false
    ------------------------------------------------------------------------------------------------------------------------
    IF NOT EXISTS (SELECT 1 FROM dbo.AccEngineDynamicRule WHERE [Rule] = N'TxnModel.IsFinancialInstitution === false')
        BEGIN
            INSERT INTO dbo.AccEngineDynamicRule (Id, Name, [Rule], Type, Description, StateId, StateDate, StateMaker)
            OUTPUT inserted.Id INTO @tempTable
            VALUES (@lastAccEngineDynamicRuleId, N'IsCustomer', N'TxnModel.IsFinancialInstitution === false', 0,
                    N'', @StateId, @stateDate, @stateMaker);
            SELECT @dynamicRuleIsCustomerId = Id FROM @tempTable;
            DELETE FROM @tempTable;
            SET @lastAccEngineDynamicRuleId = @lastAccEngineDynamicRuleId + 1;
        END
    ELSE
        BEGIN
            SELECT @dynamicRuleIsCustomerId = Id
            FROM dbo.AccEngineDynamicRule
            WHERE [Rule] = N'TxnModel.IsFinancialInstitution === false';
        END;
    ------------------------------------------------------------------------------------------------------------------------
    -- IsFinancialInstitution => TxnModel.IsFinancialInstitution === true
    ------------------------------------------------------------------------------------------------------------------------
    IF NOT EXISTS (SELECT 1 FROM dbo.AccEngineDynamicRule WHERE [Rule] = N'TxnModel.IsFinancialInstitution === true')
        BEGIN
            INSERT INTO dbo.AccEngineDynamicRule (Id, Name, [Rule], Type, Description, StateId, StateDate, StateMaker)
            OUTPUT inserted.Id INTO @tempTable
            VALUES (@lastAccEngineDynamicRuleId, N'IsFinancialInstitution', N'TxnModel.IsFinancialInstitution === true',
                    0,
                    N'', @StateId, @stateDate, @stateMaker);
            SELECT @dynamicRuleIsFinancialInstitutionId = Id FROM @tempTable;
            DELETE FROM @tempTable;
            SET @lastAccEngineDynamicRuleId = @lastAccEngineDynamicRuleId + 1;
        END
    ELSE
        BEGIN
            SELECT @dynamicRuleIsFinancialInstitutionId = Id
            FROM dbo.AccEngineDynamicRule
            WHERE [Rule] = N'TxnModel.IsFinancialInstitution === true';
        END;
    ------------------------------------------------------------------------------------------------------------------------
    -- IsImmediateIncomingPayment => TxnModel.IsImmediateIncomingPayment === true
    ------------------------------------------------------------------------------------------------------------------------
    IF NOT EXISTS (SELECT 1
                   FROM dbo.AccEngineDynamicRule
                   WHERE [Rule] = N'TxnModel.IsImmediateIncomingPayment === true')
        BEGIN
            INSERT INTO dbo.AccEngineDynamicRule (Id, Name, [Rule], Type, Description, StateId, StateDate, StateMaker)
            OUTPUT inserted.Id INTO @tempTable
            VALUES (@lastAccEngineDynamicRuleId, N'IsImmediateIncomingPayment',
                    N'TxnModel.IsImmediateIncomingPayment === true', 0,
                    N'', @StateId, @stateDate, @stateMaker);
            SELECT @dynamicRuleIsimmediateIncomingPaymentId = Id FROM @tempTable;
            DELETE FROM @tempTable;
            SET @lastAccEngineDynamicRuleId = @lastAccEngineDynamicRuleId + 1;
        END
    ELSE
        BEGIN
            SELECT @dynamicRuleIsimmediateIncomingPaymentId = Id
            FROM dbo.AccEngineDynamicRule
            WHERE [Rule] = N'TxnModel.IsImmediateIncomingPayment === true';
        END;
    ------------------------------------------------------------------------------------------------------------------------
    -- IsImmediateOutgoingPayment => TxnModel.IsImmediateOutgoingPayment === true
    ------------------------------------------------------------------------------------------------------------------------
    IF NOT EXISTS (SELECT 1
                   FROM dbo.AccEngineDynamicRule
                   WHERE [Rule] = N'TxnModel.IsImmediateOutgoingPayment === true')
        BEGIN
            INSERT INTO dbo.AccEngineDynamicRule (Id, Name, [Rule], Type, Description, StateId, StateDate, StateMaker)
            OUTPUT inserted.Id INTO @tempTable
            VALUES (@lastAccEngineDynamicRuleId, N'IsImmediateOutgoingPayment',
                    N'TxnModel.IsImmediateOutgoingPayment === true', 0,
                    N'', @StateId, @stateDate, @stateMaker);
            SELECT @dynamicRuleIsimmediateOutgoingPaymentId = Id FROM @tempTable;
            DELETE FROM @tempTable;
            SET @lastAccEngineDynamicRuleId = @lastAccEngineDynamicRuleId + 1;
        END
    ELSE
        BEGIN
            SELECT @dynamicRuleIsimmediateOutgoingPaymentId = Id
            FROM dbo.AccEngineDynamicRule
            WHERE [Rule] = N'TxnModel.IsImmediateOutgoingPayment === true';
        END;
    ------------------------------------------------------------------------------------------------------------------------
    -- IsDeferredIncomingPayment => TxnModel.IsImmediateIncomingPayment === false
    ------------------------------------------------------------------------------------------------------------------------
    IF NOT EXISTS (SELECT 1 FROM dbo.AccEngineDynamicRule WHERE [Rule] = N'TxnModel.IsImmediateIncomingPayment === false')
        BEGIN
            INSERT INTO dbo.AccEngineDynamicRule (Id, Name, [Rule], Type, Description, StateId, StateDate, StateMaker)
            OUTPUT inserted.Id INTO @tempTable
            VALUES (@lastAccEngineDynamicRuleId, N'IsDeferredIncomingPayment',
                    N'TxnModel.IsImmediateIncomingPayment === false', 0,
                    N'', @StateId, @stateDate, @stateMaker);
            SELECT @dynamicRuleIsDeferredIncomingPaymentId = Id FROM @tempTable;
            DELETE FROM @tempTable;
            SET @lastAccEngineDynamicRuleId = @lastAccEngineDynamicRuleId + 1;
        END
    ELSE
        BEGIN
            SELECT @dynamicRuleIsDeferredIncomingPaymentId = Id
            FROM dbo.AccEngineDynamicRule
            WHERE [Rule] = N'TxnModel.IsImmediateIncomingPayment === false';
        END;
    ------------------------------------------------------------------------------------------------------------------------
    -- IsDeferredOutgoingPayment => TxnModel.IsImmediateOutgoingPayment === false
    ------------------------------------------------------------------------------------------------------------------------
    IF NOT EXISTS (SELECT 1 FROM dbo.AccEngineDynamicRule WHERE [Rule] = N'TxnModel.IsImmediateOutgoingPayment === false')
        BEGIN
            INSERT INTO dbo.AccEngineDynamicRule (Id, Name, [Rule], Type, Description, StateId, StateDate, StateMaker)
            OUTPUT inserted.Id INTO @tempTable
            VALUES (@lastAccEngineDynamicRuleId, N'IsDeferredOutgoingPayment',
                    N'TxnModel.IsImmediateOutgoingPayment === false', 0,
                    N'', @StateId, @stateDate, @stateMaker);
            SELECT @dynamicRuleIsDeferredOutgoingPaymentId = Id FROM @tempTable;
            DELETE FROM @tempTable;
            SET @lastAccEngineDynamicRuleId = @lastAccEngineDynamicRuleId + 1;
        END
    ELSE
        BEGIN
            SELECT @dynamicRuleIsDeferredOutgoingPaymentId = Id
            FROM dbo.AccEngineDynamicRule
            WHERE [Rule] = N'TxnModel.IsImmediateOutgoingPayment === false';
        END;
    ------------------------------------------------------------------------------------------------------------------------
    -- IncomingExternalCustomerGLAccount => TxnModel.IncomingExternalCustomerGLAccount
    ------------------------------------------------------------------------------------------------------------------------
    IF NOT EXISTS (SELECT 1 FROM dbo.AccEngineDynamicRule WHERE [Rule] = N'TxnModel.IncomingExternalCustomerGLAccount')
        BEGIN
            INSERT INTO dbo.AccEngineDynamicRule (Id, Name, [Rule], Type, Description, StateId, StateDate, StateMaker)
            OUTPUT inserted.Id INTO @tempTable
            VALUES (@lastAccEngineDynamicRuleId, N'IncomingExternalCustomerGLAccount',
                    N'TxnModel.IncomingExternalCustomerGLAccount', 1,
                    N'', @StateId, @stateDate, @stateMaker);
            SELECT @dynamicRuleIncomingExternalCustomerGLAccountId = Id FROM @tempTable;
            DELETE FROM @tempTable;
            SET @lastAccEngineDynamicRuleId = @lastAccEngineDynamicRuleId + 1;
        END
    ELSE
        BEGIN
            SELECT @dynamicRuleIncomingExternalCustomerGLAccountId = Id
            FROM dbo.AccEngineDynamicRule
            WHERE [Rule] = N'TxnModel.IncomingExternalCustomerGLAccount';
        END;
    ------------------------------------------------------------------------------------------------------------------------
    -- IncomingExternalCustomerAccountNo => TxnModel.IncomingExternalCustomerAccountNo
    ------------------------------------------------------------------------------------------------------------------------
    IF NOT EXISTS (SELECT 1 FROM dbo.AccEngineDynamicRule WHERE [Rule] = N'TxnModel.IncomingExternalCustomerAccountNo')
        BEGIN
            INSERT INTO dbo.AccEngineDynamicRule (Id, Name, [Rule], Type, Description, StateId, StateDate, StateMaker)
            OUTPUT inserted.Id INTO @tempTable
            VALUES (@lastAccEngineDynamicRuleId, N'IncomingExternalCustomerAccountNo',
                    N'TxnModel.IncomingExternalCustomerAccountNo', 1,
                    N'', @StateId, @stateDate, @stateMaker);
            SELECT @dynamicRuleIncomingExternalCustomerAccountNoId = Id FROM @tempTable;
            DELETE FROM @tempTable;
            SET @lastAccEngineDynamicRuleId = @lastAccEngineDynamicRuleId + 1;
        END
    ELSE
        BEGIN
            SELECT @dynamicRuleIncomingExternalCustomerAccountNoId = Id
            FROM dbo.AccEngineDynamicRule
            WHERE [Rule] = N'TxnModel.IncomingExternalCustomerAccountNo';
        END;
    ------------------------------------------------------------------------------------------------------------------------
    -- OutgoingExternalCustomerAccountNo => TxnModel.OutgoingExternalCustomerAccountNo
    ------------------------------------------------------------------------------------------------------------------------
    IF NOT EXISTS (SELECT 1 FROM dbo.AccEngineDynamicRule WHERE [Rule] = N'TxnModel.OutgoingExternalCustomerAccountNo')
        BEGIN
            INSERT INTO dbo.AccEngineDynamicRule (Id, Name, [Rule], Type, Description, StateId, StateDate, StateMaker)
            OUTPUT inserted.Id INTO @tempTable
            VALUES (@lastAccEngineDynamicRuleId, N'OutgoingExternalCustomerAccountNo',
                    N'TxnModel.OutgoingExternalCustomerAccountNo', 1,
                    N'', @StateId, @stateDate, @stateMaker);
            SELECT @dynamicRuleOutgoingExternalCustomerAccountNoId = Id FROM @tempTable;
            DELETE FROM @tempTable;
            SET @lastAccEngineDynamicRuleId = @lastAccEngineDynamicRuleId + 1;
        END
    ELSE
        BEGIN
            SELECT @dynamicRuleOutgoingExternalCustomerAccountNoId = Id
            FROM dbo.AccEngineDynamicRule
            WHERE [Rule] = N'TxnModel.OutgoingExternalCustomerAccountNo';
        END;
    ------------------------------------------------------------------------------------------------------------------------
    -- OutgoingExternalCustomerGLAccount => TxnModel.OutgoingExternalCustomerGLAccount
    ------------------------------------------------------------------------------------------------------------------------
    IF NOT EXISTS (SELECT 1 FROM dbo.AccEngineDynamicRule WHERE [Rule] = N'TxnModel.OutgoingExternalCustomerGLAccount')
        BEGIN
            INSERT INTO dbo.AccEngineDynamicRule (Id, Name, [Rule], Type, Description, StateId, StateDate, StateMaker)
            OUTPUT inserted.Id INTO @tempTable
            VALUES (@lastAccEngineDynamicRuleId, N'OutgoingExternalCustomerGLAccount',
                    N'TxnModel.OutgoingExternalCustomerGLAccount', 1,
                    N'', @StateId, @stateDate, @stateMaker);
            SELECT @dynamicRuleOutgoingExternalCustomerGLAccountId = Id FROM @tempTable;
            DELETE FROM @tempTable;
            SET @lastAccEngineDynamicRuleId = @lastAccEngineDynamicRuleId + 1;
        END
    ELSE
        BEGIN
            SELECT @dynamicRuleOutgoingExternalCustomerGLAccountId = Id
            FROM dbo.AccEngineDynamicRule
            WHERE [Rule] = N'TxnModel.OutgoingExternalCustomerGLAccount';
        END;
    ------------------------------------------------------------------------------------------------------------------------
    -- IncomingPaymentInstructionType = B2B => TxnModel.IncomingPaymentInstructionTypeId === 1
    ------------------------------------------------------------------------------------------------------------------------
    IF NOT EXISTS (SELECT 1
                   FROM dbo.AccEngineDynamicRule
                   WHERE [Rule] = N'TxnModel.IncomingPaymentInstructionTypeId === 1')
        BEGIN
            INSERT INTO dbo.AccEngineDynamicRule (Id, Name, [Rule], Type, Description, StateId, StateDate, StateMaker)
            OUTPUT inserted.Id INTO @tempTable
            VALUES (@lastAccEngineDynamicRuleId, N'IncomingPaymentInstructionType = B2B',
                    N'TxnModel.IncomingPaymentInstructionTypeId === 1', 0,
                    N'', @StateId, @stateDate, @stateMaker);
            SELECT @dynamicRuleIncomingPaymentInstructionTypeEqualB2BId = Id FROM @tempTable;
            DELETE FROM @tempTable;
            SET @lastAccEngineDynamicRuleId = @lastAccEngineDynamicRuleId + 1;
        END
    ELSE
        BEGIN
            SELECT @dynamicRuleIncomingPaymentInstructionTypeEqualB2BId = Id
            FROM dbo.AccEngineDynamicRule
            WHERE [Rule] = N'TxnModel.IncomingPaymentInstructionTypeId === 1';
        END;
    ------------------------------------------------------------------------------------------------------------------------
    -- OutgoingPaymentInstructionType = B2B => TxnModel.OutgoingPaymentInstructionTypeId === 1
    ------------------------------------------------------------------------------------------------------------------------
    IF NOT EXISTS (SELECT 1
                   FROM dbo.AccEngineDynamicRule
                   WHERE [Rule] = N'TxnModel.OutgoingPaymentInstructionTypeId === 1')
        BEGIN
            INSERT INTO dbo.AccEngineDynamicRule (Id, Name, [Rule], Type, Description, StateId, StateDate, StateMaker)
            OUTPUT inserted.Id INTO @tempTable
            VALUES (@lastAccEngineDynamicRuleId, N'OutgoingPaymentInstructionTypeId = B2B',
                    N'TxnModel.OutgoingPaymentInstructionTypeId === 1', 0,
                    N'', @StateId, @stateDate, @stateMaker);
            SELECT @dynamicRuleOutgoingPaymentInstructionTypeEqualB2BId = Id FROM @tempTable;
            DELETE FROM @tempTable;
            SET @lastAccEngineDynamicRuleId = @lastAccEngineDynamicRuleId + 1;
        END
    ELSE
        BEGIN
            SELECT @dynamicRuleOutgoingPaymentInstructionTypeEqualB2BId = Id
            FROM dbo.AccEngineDynamicRule
            WHERE [Rule] = N'TxnModel.OutgoingPaymentInstructionTypeId === 1';
        END;
    ------------------------------------------------------------------------------------------------------------------------
    -- IncomingPaymentInstructionType = A2A => TxnModel.IncomingPaymentInstructionTypeId === 2
    ------------------------------------------------------------------------------------------------------------------------
    IF NOT EXISTS (SELECT 1
                   FROM dbo.AccEngineDynamicRule
                   WHERE [Rule] = N'TxnModel.IncomingPaymentInstructionTypeId === 2')
        BEGIN
            INSERT INTO dbo.AccEngineDynamicRule (Id, Name, [Rule], Type, Description, StateId, StateDate, StateMaker)
            OUTPUT inserted.Id INTO @tempTable
            VALUES (@lastAccEngineDynamicRuleId, N'IncomingPaymentInstructionType = A2A',
                    N'TxnModel.IncomingPaymentInstructionTypeId === 2', 0,
                    N'', @StateId, @stateDate, @stateMaker);
            SELECT @dynamicRuleIncomingPaymentInstructionTypeEqualA2AId = Id FROM @tempTable;
            DELETE FROM @tempTable;
            SET @lastAccEngineDynamicRuleId = @lastAccEngineDynamicRuleId + 1;
        END
    ELSE
        BEGIN
            SELECT @dynamicRuleIncomingPaymentInstructionTypeEqualA2AId = Id
            FROM dbo.AccEngineDynamicRule
            WHERE [Rule] = N'TxnModel.IncomingPaymentInstructionTypeId === 2';
        END;
    ------------------------------------------------------------------------------------------------------------------------
    -- OutgoingPaymentInstructionType = A2A => TxnModel.OutgoingPaymentInstructionTypeId === 2
    ------------------------------------------------------------------------------------------------------------------------
    IF NOT EXISTS (SELECT 1
                   FROM dbo.AccEngineDynamicRule
                   WHERE [Rule] = N'TxnModel.OutgoingPaymentInstructionTypeId === 2')
        BEGIN
            INSERT INTO dbo.AccEngineDynamicRule (Id, Name, [Rule], Type, Description, StateId, StateDate, StateMaker)
            OUTPUT inserted.Id INTO @tempTable
            VALUES (@lastAccEngineDynamicRuleId, N'OutgoingPaymentInstructionType = A2A',
                    N'TxnModel.OutgoingPaymentInstructionTypeId === 2', 0,
                    N'', @StateId, @stateDate, @stateMaker);
            SELECT @dynamicRuleOutgoingPaymentInstructionTypeEqualA2AId = Id FROM @tempTable;
            DELETE FROM @tempTable;
            SET @lastAccEngineDynamicRuleId = @lastAccEngineDynamicRuleId + 1;
        END
    ELSE
        BEGIN
            SELECT @dynamicRuleOutgoingPaymentInstructionTypeEqualA2AId = Id
            FROM dbo.AccEngineDynamicRule
            WHERE [Rule] = N'TxnModel.OutgoingPaymentInstructionTypeId === 2';
        END;
    ------------------------------------------------------------------------------------------------------------------------
    -- IncomingPaymentInstructionType = V2V => TxnModel.IncomingPaymentInstructionTypeId === 3
    ------------------------------------------------------------------------------------------------------------------------
    IF NOT EXISTS (SELECT 1
                   FROM dbo.AccEngineDynamicRule
                   WHERE [Rule] = N'TxnModel.IncomingPaymentInstructionTypeId === 3')
        BEGIN
            INSERT INTO dbo.AccEngineDynamicRule (Id, Name, [Rule], Type, Description, StateId, StateDate, StateMaker)
            OUTPUT inserted.Id INTO @tempTable
            VALUES (@lastAccEngineDynamicRuleId, N'IncomingPaymentInstructionType = V2V',
                    N'TxnModel.IncomingPaymentInstructionTypeId === 3', 0,
                    N'', @StateId, @stateDate, @stateMaker);
            SELECT @dynamicRuleIncomingPaymentInstructionTypeEqualV2VId = Id FROM @tempTable;
            DELETE FROM @tempTable;
            SET @lastAccEngineDynamicRuleId = @lastAccEngineDynamicRuleId + 1;
        END
    ELSE
        BEGIN
            SELECT @dynamicRuleIncomingPaymentInstructionTypeEqualV2VId = Id
            FROM dbo.AccEngineDynamicRule
            WHERE [Rule] = N'TxnModel.IncomingPaymentInstructionTypeId === 3';
        END;
    ------------------------------------------------------------------------------------------------------------------------
    -- OutgoingPaymentInstructionType = V2V => TxnModel.OutgoingPaymentInstructionTypeId === 3
    ------------------------------------------------------------------------------------------------------------------------
    IF NOT EXISTS (SELECT 1
                   FROM dbo.AccEngineDynamicRule
                   WHERE [Rule] = N'TxnModel.OutgoingPaymentInstructionTypeId === 3')
        BEGIN
            INSERT INTO dbo.AccEngineDynamicRule (Id, Name, [Rule], Type, Description, StateId, StateDate, StateMaker)
            OUTPUT inserted.Id INTO @tempTable
            VALUES (@lastAccEngineDynamicRuleId, N'OutgoingPaymentInstructionType = V2V',
                    N'TxnModel.OutgoingPaymentInstructionTypeId === 3', 0,
                    N'', @StateId, @stateDate, @stateMaker);
            SELECT @dynamicRuleOutgoingPaymentInstructionTypeEqualV2VId = Id FROM @tempTable;
            DELETE FROM @tempTable;
            SET @lastAccEngineDynamicRuleId = @lastAccEngineDynamicRuleId + 1;
        END
    ELSE
        BEGIN
            SELECT @dynamicRuleOutgoingPaymentInstructionTypeEqualV2VId = Id
            FROM dbo.AccEngineDynamicRule
            WHERE [Rule] = N'TxnModel.OutgoingPaymentInstructionTypeId === 3';
        END;
    ------------------------------------------------------------------------------------------------------------------------
    -- IncomingSettlementType = Gross => TxnModel.IncomingSettlementTypeId === 1
    ------------------------------------------------------------------------------------------------------------------------
    IF NOT EXISTS (SELECT 1 FROM dbo.AccEngineDynamicRule WHERE [Rule] = N'TxnModel.IncomingSettlementTypeId === 1')
        BEGIN
            INSERT INTO dbo.AccEngineDynamicRule (Id, Name, [Rule], Type, Description, StateId, StateDate, StateMaker)
            OUTPUT inserted.Id INTO @tempTable
            VALUES (@lastAccEngineDynamicRuleId, N'IncomingSettlementType = Gross',
                    N'TxnModel.IncomingSettlementTypeId === 1', 0,
                    N'', @StateId, @stateDate, @stateMaker);
            SELECT @dynamicRuleIncomingSettlementTypeEqualGrossId = Id FROM @tempTable;
            DELETE FROM @tempTable;
            SET @lastAccEngineDynamicRuleId = @lastAccEngineDynamicRuleId + 1;
        END
    ELSE
        BEGIN
            SELECT @dynamicRuleIncomingSettlementTypeEqualGrossId = Id
            FROM dbo.AccEngineDynamicRule
            WHERE [Rule] = N'TxnModel.IncomingSettlementTypeId === 1';
        END;
    ------------------------------------------------------------------------------------------------------------------------
    -- OutgoingSettlementType = Gross => TxnModel.OutgoingSettlementTypeId === 1
    ------------------------------------------------------------------------------------------------------------------------
    IF NOT EXISTS (SELECT 1 FROM dbo.AccEngineDynamicRule WHERE [Rule] = N'TxnModel.OutgoingSettlementTypeId === 1')
        BEGIN
            INSERT INTO dbo.AccEngineDynamicRule (Id, Name, [Rule], Type, Description, StateId, StateDate, StateMaker)
            OUTPUT inserted.Id INTO @tempTable
            VALUES (@lastAccEngineDynamicRuleId, N'OutgoingSettlementType = Gross',
                    N'TxnModel.OutgoingSettlementTypeId === 1', 0,
                    N'', @StateId, @stateDate, @stateMaker);
            SELECT @dynamicRuleOutgoingSettlementTypeEqualGrossId = Id FROM @tempTable;
            DELETE FROM @tempTable;
            SET @lastAccEngineDynamicRuleId = @lastAccEngineDynamicRuleId + 1;
        END
    ELSE
        BEGIN
            SELECT @dynamicRuleOutgoingSettlementTypeEqualGrossId = Id
            FROM dbo.AccEngineDynamicRule
            WHERE [Rule] = N'TxnModel.OutgoingSettlementTypeId === 1';
        END;
    ------------------------------------------------------------------------------------------------------------------------
    -- IncomingSettlementType = Netting => TxnModel.IncomingSettlementTypeId === 2
    ------------------------------------------------------------------------------------------------------------------------
    IF NOT EXISTS (SELECT 1 FROM dbo.AccEngineDynamicRule WHERE [Rule] = N'TxnModel.IncomingSettlementTypeId === 2')
        BEGIN
            INSERT INTO dbo.AccEngineDynamicRule (Id, Name, [Rule], Type, Description, StateId, StateDate, StateMaker)
            OUTPUT inserted.Id INTO @tempTable
            VALUES (@lastAccEngineDynamicRuleId, N'IncomingSettlementType = Netting',
                    N'TxnModel.IncomingSettlementTypeId === 2', 0,
                    N'', @StateId, @stateDate, @stateMaker);
            SELECT @dynamicRuleIncomingSettlementTypeEqualNettingId = Id FROM @tempTable;
            DELETE FROM @tempTable;
            SET @lastAccEngineDynamicRuleId = @lastAccEngineDynamicRuleId + 1;
        END
    ELSE
        BEGIN
            SELECT @dynamicRuleIncomingSettlementTypeEqualNettingId = Id
            FROM dbo.AccEngineDynamicRule
            WHERE [Rule] = N'TxnModel.IncomingSettlementTypeId === 2';
        END;
    ------------------------------------------------------------------------------------------------------------------------
    -- OutgoingSettlementType = Netting => TxnModel.OutgoingSettlementTypeId === 2
    ------------------------------------------------------------------------------------------------------------------------
    IF NOT EXISTS (SELECT 1 FROM dbo.AccEngineDynamicRule WHERE [Rule] = N'TxnModel.OutgoingSettlementTypeId === 2')
        BEGIN
            INSERT INTO dbo.AccEngineDynamicRule (Id, Name, [Rule], Type, Description, StateId, StateDate, StateMaker)
            OUTPUT inserted.Id INTO @tempTable
            VALUES (@lastAccEngineDynamicRuleId, N'OutgoingSettlementType = Netting',
                    N'TxnModel.OutgoingSettlementTypeId === 2', 0,
                    N'', @StateId, @stateDate, @stateMaker);
            SELECT @dynamicRuleOutgoingSettlementTypeEqualNettingId = Id FROM @tempTable;
            DELETE FROM @tempTable;
            SET @lastAccEngineDynamicRuleId = @lastAccEngineDynamicRuleId + 1;
        END
    ELSE
        BEGIN
            SELECT @dynamicRuleOutgoingSettlementTypeEqualNettingId = Id
            FROM dbo.AccEngineDynamicRule
            WHERE [Rule] = N'TxnModel.OutgoingSettlementTypeId === 2';
        END;
    --#endregion
   
   
   
   ------------------------------------------------------------------------------------------------------------------------
    -- Accounting Account Map
    ------------------------------------------------------------------------------------------------------------------------
    --#region AccAccountMap

    ------------------------------------------------------------------------------------------------------------------------
    -- IncomingPaymentLCY
    ------------------------------------------------------------------------------------------------------------------------
    IF NOT EXISTS(SELECT 1
                  FROM dbo.AccAccountMap
                  WHERE RuleId IS NULL
                    AND Rule2Id = @dynamicRuleIsCustomerId
                    AND Rule3Id = @dynamicRuleIsimmediateIncomingPaymentId
                    AND Rule4Id IS NULL
                    AND Rule5Id IS NULL
                    AND Rule6Id IS NULL
                    AND Rule7Id IS NULL
                    AND Rule8Id IS NULL
                    AND Rule9Id IS NULL
                    AND Rule10Id IS NULL
                    AND Source = N'IncomingPaymentLCY'
                    AND Path = @path
                    AND TargetMainGL IS NULL
                    AND Target IS NULL
                    AND TargetRuleId = @dynamicRuleIncomingExternalCustomerGLAccountId
                    AND CustomerCodeSourceRuleId = @dynamicRuleExternalCustomerId
                    AND CustomerAccountCodeSourceRuleId = @dynamicRuleIncomingExternalCustomerAccountNoId)
        BEGIN
            INSERT INTO dbo.AccAccountMap (Id, Ccy, CustomerId, RuleId, Rule2Id, Rule3Id, Rule4Id, Rule5Id, Rule6Id,
                                           Rule7Id, Rule8Id, Rule9Id, Rule10Id, Source, Path, TargetMainGL, Target,
                                           TargetRuleId, IsEnabled, [Order], Description, CustomerCodeSourceRuleId,
                                           CustomerAccountCodeSourceRuleId, StateId, StateMaker, StateDate)
            VALUES (@lastAccAccountMapId, NULL, NULL, NULL,
                    @dynamicRuleIsCustomerId, @dynamicRuleIsimmediateIncomingPaymentId, NULL, NULL, NULL, NULL,
                    NULL, NULL, NULL, N'IncomingPaymentLCY', @path, NULL, NULL,
                    @dynamicRuleIncomingExternalCustomerGLAccountId, 1,
                    10, N'', @dynamicRuleExternalCustomerId, @dynamicRuleIncomingExternalCustomerAccountNoId, @stateId,
                    @stateMaker,
                    @stateDate);

            select @lastAccAccountMapId = @lastAccAccountMapId + 1
        END;
    IF NOT EXISTS(SELECT 1
                  FROM dbo.AccAccountMap
                  WHERE RuleId IS NULL
                    AND Rule2Id = @dynamicRuleIsCustomerId
                    AND Rule3Id = @dynamicRuleIsDeferredIncomingPaymentId
                    AND Rule4Id IS NULL
                    AND Rule5Id IS NULL
                    AND Rule6Id IS NULL
                    AND Rule7Id IS NULL
                    AND Rule8Id IS NULL
                    AND Rule9Id IS NULL
                    AND Rule10Id IS NULL
                    AND Source = N'IncomingPaymentLCY'
                    AND Path = @path
                    AND TargetMainGL = N'392'
                    AND Target = N'39200800'
                    AND TargetRuleId IS NULL
                    AND CustomerCodeSourceRuleId IS NULL
                    AND CustomerAccountCodeSourceRuleId IS NULL)
        BEGIN
            INSERT INTO dbo.AccAccountMap (Id, Ccy, CustomerId, RuleId, Rule2Id, Rule3Id, Rule4Id, Rule5Id, Rule6Id,
                                           Rule7Id, Rule8Id, Rule9Id, Rule10Id, Source, Path, TargetMainGL, Target,
                                           TargetRuleId, IsEnabled, [Order], Description, CustomerCodeSourceRuleId,
                                           CustomerAccountCodeSourceRuleId, StateId, StateMaker, StateDate)
            VALUES (@lastAccAccountMapId, NULL, NULL, NULL,
                    @dynamicRuleIsCustomerId, @dynamicRuleIsDeferredIncomingPaymentId, NULL, NULL, NULL, NULL,
                    NULL, NULL, NULL, N'IncomingPaymentLCY', @path, N'392', N'39200800', NULL, 1,
                    10, N'', NULL, NULL, @stateId, @stateMaker,
                    @stateDate);

            select @lastAccAccountMapId = @lastAccAccountMapId + 1
        END;

    ------------------------------------------------------------------------------------------------------------------------
    -- OutgoingPaymentLCY
    ------------------------------------------------------------------------------------------------------------------------
    IF NOT EXISTS(SELECT 1
                  FROM dbo.AccAccountMap
                  WHERE RuleId IS NULL
                    AND Rule2Id = @dynamicRuleIsCustomerId
                    AND Rule3Id = @dynamicRuleIsimmediateOutgoingPaymentId
                    AND Rule4Id IS NULL
                    AND Rule5Id IS NULL
                    AND Rule6Id IS NULL
                    AND Rule7Id IS NULL
                    AND Rule8Id IS NULL
                    AND Rule9Id IS NULL
                    AND Rule10Id IS NULL
                    AND Source = N'OutgoingPaymentLCY'
                    AND Path = @path
                    AND TargetMainGL IS NULL
                    AND Target IS NULL
                    AND TargetRuleId = @dynamicRuleOutgoingExternalCustomerGLAccountId
                    AND CustomerCodeSourceRuleId = @dynamicRuleExternalCustomerId
                    AND CustomerAccountCodeSourceRuleId = @dynamicRuleOutgoingExternalCustomerAccountNoId)
        BEGIN
            INSERT INTO dbo.AccAccountMap (Id, Ccy, CustomerId, RuleId, Rule2Id, Rule3Id, Rule4Id, Rule5Id, Rule6Id,
                                           Rule7Id, Rule8Id, Rule9Id, Rule10Id, Source, Path, TargetMainGL, Target,
                                           TargetRuleId, IsEnabled, [Order], Description, CustomerCodeSourceRuleId,
                                           CustomerAccountCodeSourceRuleId, StateId, StateMaker, StateDate)
            VALUES (@lastAccAccountMapId, NULL, NULL, NULL,
                    @dynamicRuleIsCustomerId, @dynamicRuleIsimmediateOutgoingPaymentId, NULL, NULL, NULL, NULL,
                    NULL, NULL, NULL, N'OutgoingPaymentLCY', @path, NULL, NULL,
                    @dynamicRuleOutgoingExternalCustomerGLAccountId, 1,
                    10, N'', @dynamicRuleExternalCustomerId, @dynamicRuleOutgoingExternalCustomerAccountNoId, @stateId,
                    @stateMaker,
                    @stateDate);

            select @lastAccAccountMapId = @lastAccAccountMapId + 1
        END;
    IF NOT EXISTS(SELECT 1
                  FROM dbo.AccAccountMap
                  WHERE RuleId IS NULL
                    AND Rule2Id = @dynamicRuleIsCustomerId
                    AND Rule3Id = @dynamicRuleIsDeferredOutgoingPaymentId
                    AND Rule4Id IS NULL
                    AND Rule5Id IS NULL
                    AND Rule6Id IS NULL
                    AND Rule7Id IS NULL
                    AND Rule8Id IS NULL
                    AND Rule9Id IS NULL
                    AND Rule10Id IS NULL
                    AND Source = N'OutgoingPaymentLCY'
                    AND Path = @path
                    AND TargetMainGL = N'392'
                    AND Target = N'39200800'
                    AND TargetRuleId IS NULL
                    AND CustomerCodeSourceRuleId IS NULL
                    AND CustomerAccountCodeSourceRuleId IS NULL)
        BEGIN
            INSERT INTO dbo.AccAccountMap (Id, Ccy, CustomerId, RuleId, Rule2Id, Rule3Id, Rule4Id, Rule5Id, Rule6Id,
                                           Rule7Id, Rule8Id, Rule9Id, Rule10Id, Source, Path, TargetMainGL, Target,
                                           TargetRuleId, IsEnabled, [Order], Description, CustomerCodeSourceRuleId,
                                           CustomerAccountCodeSourceRuleId, StateId, StateMaker, StateDate)
            VALUES (@lastAccAccountMapId, NULL, NULL, NULL,
                    @dynamicRuleIsCustomerId, @dynamicRuleIsDeferredOutgoingPaymentId, NULL, NULL, NULL, NULL,
                    NULL, NULL, NULL, N'OutgoingPaymentLCY', @path, N'392', N'39200800', NULL, 1,
                    10, N'', NULL, NULL, @stateId, @stateMaker,
                    @stateDate);

            select @lastAccAccountMapId = @lastAccAccountMapId + 1
        END;

    ------------------------------------------------------------------------------------------------------------------------
    -- IncomingPaymentFCY
    ------------------------------------------------------------------------------------------------------------------------
    IF NOT EXISTS(SELECT 1
                  FROM dbo.AccAccountMap
                  WHERE RuleId IS NULL
                    AND Rule2Id = @dynamicRuleIsCustomerId
                    AND Rule3Id = @dynamicRuleIsimmediateIncomingPaymentId
                    AND Rule4Id IS NULL
                    AND Rule5Id IS NULL
                    AND Rule6Id IS NULL
                    AND Rule7Id IS NULL
                    AND Rule8Id IS NULL
                    AND Rule9Id IS NULL
                    AND Rule10Id IS NULL
                    AND Source = N'IncomingPaymentFCY'
                    AND Path = @path
                    AND TargetMainGL IS NULL
                    AND Target IS NULL
                    AND TargetRuleId = @dynamicRuleIncomingExternalCustomerGLAccountId
                    AND CustomerCodeSourceRuleId = @dynamicRuleExternalCustomerId
                    AND CustomerAccountCodeSourceRuleId = @dynamicRuleIncomingExternalCustomerAccountNoId)
        BEGIN
            INSERT INTO dbo.AccAccountMap (Id, Ccy, CustomerId, RuleId, Rule2Id, Rule3Id, Rule4Id, Rule5Id, Rule6Id,
                                           Rule7Id, Rule8Id, Rule9Id, Rule10Id, Source, Path, TargetMainGL, Target,
                                           TargetRuleId, IsEnabled, [Order], Description, CustomerCodeSourceRuleId,
                                           CustomerAccountCodeSourceRuleId, StateId, StateMaker, StateDate)
            VALUES (@lastAccAccountMapId, NULL, NULL, NULL,
                    @dynamicRuleIsCustomerId, @dynamicRuleIsimmediateIncomingPaymentId, NULL, NULL, NULL, NULL,
                    NULL, NULL, NULL, N'IncomingPaymentFCY', @path, NULL, NULL,
                    @dynamicRuleIncomingExternalCustomerGLAccountId, 1,
                    10, N'', @dynamicRuleExternalCustomerId, @dynamicRuleIncomingExternalCustomerAccountNoId, @stateId,
                    @stateMaker,
                    @stateDate);

            select @lastAccAccountMapId = @lastAccAccountMapId + 1
        END;
    IF NOT EXISTS(SELECT 1
                  FROM dbo.AccAccountMap
                  WHERE RuleId IS NULL
                    AND Rule2Id = @dynamicRuleIsCustomerId
                    AND Rule3Id = @dynamicRuleIsDeferredIncomingPaymentId
                    AND Rule4Id IS NULL
                    AND Rule5Id IS NULL
                    AND Rule6Id IS NULL
                    AND Rule7Id IS NULL
                    AND Rule8Id IS NULL
                    AND Rule9Id IS NULL
                    AND Rule10Id IS NULL
                    AND Source = N'IncomingPaymentFCY'
                    AND Path = @path
                    AND TargetMainGL = N'393'
                    AND Target = N'39300800'
                    AND TargetRuleId IS NULL
                    AND CustomerCodeSourceRuleId IS NULL
                    AND CustomerAccountCodeSourceRuleId IS NULL)
        BEGIN
            INSERT INTO dbo.AccAccountMap (Id, Ccy, CustomerId, RuleId, Rule2Id, Rule3Id, Rule4Id, Rule5Id, Rule6Id,
                                           Rule7Id, Rule8Id, Rule9Id, Rule10Id, Source, Path, TargetMainGL, Target,
                                           TargetRuleId, IsEnabled, [Order], Description, CustomerCodeSourceRuleId,
                                           CustomerAccountCodeSourceRuleId, StateId, StateMaker, StateDate)
            VALUES (@lastAccAccountMapId, NULL, NULL, NULL,
                    @dynamicRuleIsCustomerId, @dynamicRuleIsDeferredIncomingPaymentId, NULL, NULL, NULL, NULL,
                    NULL, NULL, NULL, N'IncomingPaymentFCY', @path, N'393', N'39300800', NULL, 1,
                    10, N'', NULL, NULL, @stateId, @stateMaker,
                    @stateDate);

            select @lastAccAccountMapId = @lastAccAccountMapId + 1
        END;

    ------------------------------------------------------------------------------------------------------------------------
    -- OutgoingPaymentFCY
    ------------------------------------------------------------------------------------------------------------------------
    IF NOT EXISTS(SELECT 1
                  FROM dbo.AccAccountMap
                  WHERE RuleId IS NULL
                    AND Rule2Id = @dynamicRuleIsCustomerId
                    AND Rule3Id = @dynamicRuleIsimmediateOutgoingPaymentId
                    AND Rule4Id IS NULL
                    AND Rule5Id IS NULL
                    AND Rule6Id IS NULL
                    AND Rule7Id IS NULL
                    AND Rule8Id IS NULL
                    AND Rule9Id IS NULL
                    AND Rule10Id IS NULL
                    AND Source = N'OutgoingPaymentFCY'
                    AND Path = @path
                    AND TargetMainGL IS NULL
                    AND Target IS NULL
                    AND TargetRuleId = @dynamicRuleOutgoingExternalCustomerGLAccountId
                    AND CustomerCodeSourceRuleId = @dynamicRuleExternalCustomerId
                    AND CustomerAccountCodeSourceRuleId = @dynamicRuleOutgoingExternalCustomerAccountNoId)
        BEGIN
            INSERT INTO dbo.AccAccountMap (Id, Ccy, CustomerId, RuleId, Rule2Id, Rule3Id, Rule4Id, Rule5Id, Rule6Id,
                                           Rule7Id, Rule8Id, Rule9Id, Rule10Id, Source, Path, TargetMainGL, Target,
                                           TargetRuleId, IsEnabled, [Order], Description, CustomerCodeSourceRuleId,
                                           CustomerAccountCodeSourceRuleId, StateId, StateMaker, StateDate)
            VALUES (@lastAccAccountMapId, NULL, NULL, NULL,
                    @dynamicRuleIsCustomerId, @dynamicRuleIsimmediateOutgoingPaymentId, NULL, NULL, NULL, NULL,
                    NULL, NULL, NULL, N'OutgoingPaymentFCY', @path, NULL, NULL,
                    @dynamicRuleOutgoingExternalCustomerGLAccountId, 1,
                    10, N'', @dynamicRuleExternalCustomerId, @dynamicRuleOutgoingExternalCustomerAccountNoId, @stateId,
                    @stateMaker,
                    @stateDate);

            select @lastAccAccountMapId = @lastAccAccountMapId + 1
        END;
    IF NOT EXISTS(SELECT 1
                  FROM dbo.AccAccountMap
                  WHERE RuleId IS NULL
                    AND Rule2Id = @dynamicRuleIsCustomerId
                    AND Rule3Id = @dynamicRuleIsDeferredOutgoingPaymentId
                    AND Rule4Id IS NULL
                    AND Rule5Id IS NULL
                    AND Rule6Id IS NULL
                    AND Rule7Id IS NULL
                    AND Rule8Id IS NULL
                    AND Rule9Id IS NULL
                    AND Rule10Id IS NULL
                    AND Source = N'OutgoingPaymentFCY'
                    AND Path = @path
                    AND TargetMainGL = N'393'
                    AND Target = N'39300800'
                    AND TargetRuleId IS NULL
                    AND CustomerCodeSourceRuleId IS NULL
                    AND CustomerAccountCodeSourceRuleId IS NULL)
        BEGIN
            INSERT INTO dbo.AccAccountMap (Id, Ccy, CustomerId, RuleId, Rule2Id, Rule3Id, Rule4Id, Rule5Id, Rule6Id,
                                           Rule7Id, Rule8Id, Rule9Id, Rule10Id, Source, Path, TargetMainGL, Target,
                                           TargetRuleId, IsEnabled, [Order], Description, CustomerCodeSourceRuleId,
                                           CustomerAccountCodeSourceRuleId, StateId, StateMaker, StateDate)
            VALUES (@lastAccAccountMapId, NULL, NULL, NULL,
                    @dynamicRuleIsCustomerId, @dynamicRuleIsDeferredOutgoingPaymentId, NULL, NULL, NULL, NULL,
                    NULL, NULL, NULL, N'OutgoingPaymentFCY', @path, N'393', N'39300800', NULL, 1,
                    10, N'', NULL, NULL, @stateId, @stateMaker,
                    @stateDate);

            select @lastAccAccountMapId = @lastAccAccountMapId + 1
        END;

    ------------------------------------------------------------------------------------------------------------------------
    -- IncomingPaymentCustomerLCY
    ------------------------------------------------------------------------------------------------------------------------
    IF NOT EXISTS(SELECT 1
                  FROM dbo.AccAccountMap
                  WHERE RuleId IS NULL
                    AND Rule2Id IS NULL
                    AND Rule3Id IS NULL
                    AND Rule4Id IS NULL
                    AND Rule5Id IS NULL
                    AND Rule6Id IS NULL
                    AND Rule7Id IS NULL
                    AND Rule8Id IS NULL
                    AND Rule9Id IS NULL
                    AND Rule10Id IS NULL
                    AND Source = N'IncomingPaymentCustomerLCY'
                    AND Path = @path
                    AND TargetMainGL IS NULL
                    AND Target IS NULL
                    AND TargetRuleId = @dynamicRuleIncomingExternalCustomerGLAccountId
                    AND CustomerCodeSourceRuleId = @dynamicRuleExternalCustomerId
                    AND CustomerAccountCodeSourceRuleId = @dynamicRuleIncomingExternalCustomerAccountNoId)
        BEGIN
            INSERT INTO dbo.AccAccountMap (Id, Ccy, CustomerId, RuleId, Rule2Id, Rule3Id, Rule4Id, Rule5Id, Rule6Id,
                                           Rule7Id, Rule8Id, Rule9Id, Rule10Id, Source, Path, TargetMainGL, Target,
                                           TargetRuleId, IsEnabled, [Order], Description, CustomerCodeSourceRuleId,
                                           CustomerAccountCodeSourceRuleId, StateId, StateMaker, StateDate)
            VALUES (@lastAccAccountMapId, NULL, NULL, NULL,
                    NULL, NULL, NULL, NULL, NULL, NULL,
                    NULL, NULL, NULL, N'IncomingPaymentCustomerLCY', @path, NULL, NULL,
                    @dynamicRuleIncomingExternalCustomerGLAccountId, 1,
                    10, N'', @dynamicRuleExternalCustomerId, @dynamicRuleIncomingExternalCustomerAccountNoId, @stateId,
                    @stateMaker,
                    @stateDate);

            select @lastAccAccountMapId = @lastAccAccountMapId + 1
        END;

    ------------------------------------------------------------------------------------------------------------------------
    -- IncomingPaymentCustomerLCY
    ------------------------------------------------------------------------------------------------------------------------
   IF NOT EXISTS(SELECT 1
                  FROM dbo.AccAccountMap
                  WHERE RuleId IS NULL
                    AND Rule2Id IS NULL
                    AND Rule3Id IS NULL
                    AND Rule4Id IS NULL
                    AND Rule5Id IS NULL
                    AND Rule6Id IS NULL
                    AND Rule7Id IS NULL
                    AND Rule8Id IS NULL
                    AND Rule9Id IS NULL
                    AND Rule10Id IS NULL
                    AND Source = N'IncomingPaymentCustomerFCY'
                    AND Path = @path
                    AND TargetMainGL IS NULL
                    AND Target IS NULL
                    AND TargetRuleId = @dynamicRuleIncomingExternalCustomerGLAccountId
                    AND CustomerCodeSourceRuleId = @dynamicRuleExternalCustomerId
                    AND CustomerAccountCodeSourceRuleId = @dynamicRuleIncomingExternalCustomerAccountNoId)
        BEGIN
            INSERT INTO dbo.AccAccountMap (Id, Ccy, CustomerId, RuleId, Rule2Id, Rule3Id, Rule4Id, Rule5Id, Rule6Id,
                                           Rule7Id, Rule8Id, Rule9Id, Rule10Id, Source, Path, TargetMainGL, Target,
                                           TargetRuleId, IsEnabled, [Order], Description, CustomerCodeSourceRuleId,
                                           CustomerAccountCodeSourceRuleId, StateId, StateMaker, StateDate)
            VALUES (@lastAccAccountMapId, NULL, NULL, NULL,
                    NULL, NULL, NULL, NULL, NULL, NULL,
                    NULL, NULL, NULL, N'IncomingPaymentCustomerFCY', @path, NULL, NULL,
                    @dynamicRuleIncomingExternalCustomerGLAccountId, 1,
                    10, N'', @dynamicRuleExternalCustomerId, @dynamicRuleIncomingExternalCustomerAccountNoId, @stateId,
                    @stateMaker,
                    @stateDate);

            select @lastAccAccountMapId = @lastAccAccountMapId + 1
        END;

    ------------------------------------------------------------------------------------------------------------------------
    -- OutgoingPaymentCustomerLCY
    ------------------------------------------------------------------------------------------------------------------------
   IF NOT EXISTS(SELECT 1
                  FROM dbo.AccAccountMap
                  WHERE RuleId IS NULL
                    AND Rule2Id IS NULL
                    AND Rule3Id IS NULL
                    AND Rule4Id IS NULL
                    AND Rule5Id IS NULL
                    AND Rule6Id IS NULL
                    AND Rule7Id IS NULL
                    AND Rule8Id IS NULL
                    AND Rule9Id IS NULL
                    AND Rule10Id IS NULL
                    AND Source = N'OutgoingPaymentCustomerLCY'
                    AND Path = @path
                    AND TargetMainGL IS NULL
                    AND Target IS NULL
                    AND TargetRuleId = @dynamicRuleOutgoingExternalCustomerGLAccountId
                    AND CustomerCodeSourceRuleId = @dynamicRuleExternalCustomerId
                    AND CustomerAccountCodeSourceRuleId = @dynamicRuleOutgoingExternalCustomerAccountNoId)
        BEGIN
            INSERT INTO dbo.AccAccountMap (Id, Ccy, CustomerId, RuleId, Rule2Id, Rule3Id, Rule4Id, Rule5Id, Rule6Id,
                                           Rule7Id, Rule8Id, Rule9Id, Rule10Id, Source, Path, TargetMainGL, Target,
                                           TargetRuleId, IsEnabled, [Order], Description, CustomerCodeSourceRuleId,
                                           CustomerAccountCodeSourceRuleId, StateId, StateMaker, StateDate)
            VALUES (@lastAccAccountMapId, NULL, NULL, NULL,
                    NULL, NULL, NULL, NULL, NULL, NULL,
                    NULL, NULL, NULL, N'OutgoingPaymentCustomerLCY', @path, NULL, NULL,
                    @dynamicRuleOutgoingExternalCustomerGLAccountId, 1,
                    10, N'', @dynamicRuleExternalCustomerId, @dynamicRuleOutgoingExternalCustomerAccountNoId, @stateId,
                    @stateMaker,
                    @stateDate);

            select @lastAccAccountMapId = @lastAccAccountMapId + 1
        END;

    ------------------------------------------------------------------------------------------------------------------------
    -- OutgoingPaymentCustomerFCY
    ------------------------------------------------------------------------------------------------------------------------
     IF NOT EXISTS(SELECT 1
                  FROM dbo.AccAccountMap
                  WHERE RuleId IS NULL
                    AND Rule2Id IS NULL
                    AND Rule3Id IS NULL
                    AND Rule4Id IS NULL
                    AND Rule5Id IS NULL
                    AND Rule6Id IS NULL
                    AND Rule7Id IS NULL
                    AND Rule8Id IS NULL
                    AND Rule9Id IS NULL
                    AND Rule10Id IS NULL
                    AND Source = N'OutgoingPaymentCustomerFCY'
                    AND Path = @path
                    AND TargetMainGL IS NULL
                    AND Target IS NULL
                    AND TargetRuleId = @dynamicRuleOutgoingExternalCustomerGLAccountId
                    AND CustomerCodeSourceRuleId = @dynamicRuleExternalCustomerId
                    AND CustomerAccountCodeSourceRuleId = @dynamicRuleOutgoingExternalCustomerAccountNoId)
        BEGIN
            INSERT INTO dbo.AccAccountMap (Id, Ccy, CustomerId, RuleId, Rule2Id, Rule3Id, Rule4Id, Rule5Id, Rule6Id,
                                           Rule7Id, Rule8Id, Rule9Id, Rule10Id, Source, Path, TargetMainGL, Target,
                                           TargetRuleId, IsEnabled, [Order], Description, CustomerCodeSourceRuleId,
                                           CustomerAccountCodeSourceRuleId, StateId, StateMaker, StateDate)
            VALUES (@lastAccAccountMapId, NULL, NULL, NULL,
                    NULL, NULL, NULL, NULL, NULL, NULL,
                    NULL, NULL, NULL, N'OutgoingPaymentCustomerFCY', @path, NULL, NULL,
                    @dynamicRuleOutgoingExternalCustomerGLAccountId, 1,
                    10, N'', @dynamicRuleExternalCustomerId, @dynamicRuleOutgoingExternalCustomerAccountNoId, @stateId,
                    @stateMaker,
                    @stateDate);

            select @lastAccAccountMapId = @lastAccAccountMapId + 1
        END;

    ------------------------------------------------------------------------------------------------------------------------
    -- OutgoingPaymentLCY
    ------------------------------------------------------------------------------------------------------------------------
    IF NOT EXISTS(SELECT 1
                  FROM dbo.AccAccountMap
                  WHERE Ccy IS NULL
                    AND CustomerId IS NULL
                    AND RuleId IS NULL
                    AND Rule2Id = @dynamicRuleIsFinancialInstitutionId
                    AND Rule3Id IS NULL
                    AND Rule4Id IS NULL
                    AND Rule5Id IS NULL
                    AND Rule6Id IS NULL
                    AND Rule7Id IS NULL
                    AND Rule8Id IS NULL
                    AND Rule9Id IS NULL
                    AND Rule10Id IS NULL
                    AND Source = N'OutgoingPaymentLCY'
                    AND Path = @path
                    AND TargetMainGL = N'392'
                    AND Target = N'39200800'
                    AND TargetRuleId IS NULL
                    AND CustomerCodeSourceRuleId IS NULL
                    AND CustomerAccountCodeSourceRuleId IS NULL)
    BEGIN

        INSERT INTO dbo.AccAccountMap (Id, Ccy, CustomerId, RuleId, Rule2Id, Rule3Id, Rule4Id, Rule5Id, Rule6Id, Rule7Id,
                                       Rule8Id, Rule9Id, Rule10Id, [Source], [Path], TargetMainGL, Target, TargetRuleId,
                                       IsEnabled, [Order], Description, CustomerCodeSourceRuleId,
                                       CustomerAccountCodeSourceRuleId, StateId, StateDate, StateMaker)
        VALUES (@lastAccAccountMapId, NULL, NULL, NULL, @dynamicRuleIsFinancialInstitutionId, NULL, NULL, NULL, NULL, NULL,
                NULL, NULL, NULL, 'OutgoingPaymentLCY', @path, '392', '39200800', NULL, 0, 1, 'Payment', NULL, NULL,
                @stateId, @stateDate, @stateMaker);

        select @lastAccAccountMapId = @lastAccAccountMapId + 1
    END;

    IF NOT EXISTS(SELECT 1
                  FROM dbo.AccAccountMap
                  WHERE Ccy IS NULL
                    AND CustomerId IS NULL
                    AND RuleId IS NULL
                    AND Rule2Id = @dynamicRuleIsFinancialInstitutionId
                    AND Rule3Id IS NULL
                    AND Rule4Id = @dynamicRuleOutgoingPaymentInstructionTypeEqualB2BId
                    AND Rule5Id = @dynamicRuleOutgoingSettlementTypeEqualGrossId
                    AND Rule6Id = 10005
                    AND Rule7Id = 10009
                    AND Rule8Id IS NULL
                    AND Rule9Id IS NULL
                    AND Rule10Id IS NULL
                    AND Source = N'OutgoingPaymentLCY'
                    AND Path = @path
                    AND TargetMainGL = N'392'
                    AND Target = N'39200800'
                    AND TargetRuleId IS NULL
                    AND CustomerCodeSourceRuleId = 10014
                    AND CustomerAccountCodeSourceRuleId = 10015)
    BEGIN

        INSERT INTO dbo.AccAccountMap (Id, Ccy, CustomerId, RuleId, Rule2Id, Rule3Id, Rule4Id, Rule5Id, Rule6Id, Rule7Id,
                                       Rule8Id, Rule9Id, Rule10Id, [Source], [Path], TargetMainGL, Target, TargetRuleId,
                                       IsEnabled, [Order], Description, CustomerCodeSourceRuleId,
                                       CustomerAccountCodeSourceRuleId, StateId, StateDate, StateMaker)
        VALUES (@lastAccAccountMapId, NULL, NULL, NULL, @dynamicRuleIsFinancialInstitutionId, NULL,
                @dynamicRuleOutgoingPaymentInstructionTypeEqualB2BId, @dynamicRuleOutgoingSettlementTypeEqualGrossId, 10005,
                10009, NULL, NULL, NULL, 'OutgoingPaymentLCY', @path, '392', '39200800', NULL, 1, 5, 'Payment', 10014,
                10015, @stateId, @stateDate, @stateMaker);

        select @lastAccAccountMapId = @lastAccAccountMapId + 1
    END;

    IF NOT EXISTS(SELECT 1
              FROM dbo.AccAccountMap
              WHERE Ccy IS NULL
                AND CustomerId IS NULL
                AND RuleId IS NULL
                AND Rule2Id = @dynamicRuleIsFinancialInstitutionId
                AND Rule3Id IS NULL
                AND Rule4Id = @dynamicRuleOutgoingPaymentInstructionTypeEqualB2BId
                AND Rule5Id = @dynamicRuleOutgoingSettlementTypeEqualGrossId
                AND Rule6Id = 10005
                AND Rule7Id = 10010
                AND Rule8Id IS NULL
                AND Rule9Id IS NULL
                AND Rule10Id IS NULL
                AND Source = N'OutgoingPaymentLCY'
                AND Path = @path
                AND TargetMainGL = N'392'
                AND Target = N'39200800'
                AND TargetRuleId IS NULL
                AND CustomerCodeSourceRuleId IS NULL
                AND CustomerAccountCodeSourceRuleId IS NULL)
    BEGIN

    INSERT INTO dbo.AccAccountMap (Id, Ccy, CustomerId, RuleId, Rule2Id, Rule3Id, Rule4Id, Rule5Id, Rule6Id, Rule7Id,
                                   Rule8Id, Rule9Id, Rule10Id, [Source], [Path], TargetMainGL, Target, TargetRuleId,
                                   IsEnabled, [Order], Description, CustomerCodeSourceRuleId,
                                   CustomerAccountCodeSourceRuleId, StateId, StateDate, StateMaker)
    VALUES (@lastAccAccountMapId, NULL, NULL, NULL, @dynamicRuleIsFinancialInstitutionId, NULL,
            @dynamicRuleOutgoingPaymentInstructionTypeEqualB2BId, @dynamicRuleOutgoingSettlementTypeEqualGrossId, 10005,
            10010, NULL, NULL, NULL, 'OutgoingPaymentLCY', @path, '392', '39200800', NULL, 1, 10, '', NULL, NULL,
            @stateId, @stateDate, @stateMaker);

    select @lastAccAccountMapId = @lastAccAccountMapId + 1
    END;

    IF NOT EXISTS(SELECT 1
              FROM dbo.AccAccountMap
              WHERE Ccy IS NULL
                AND CustomerId IS NULL
                AND RuleId IS NULL
                AND Rule2Id = @dynamicRuleIsFinancialInstitutionId
                AND Rule3Id IS NULL
                AND Rule4Id = @dynamicRuleOutgoingPaymentInstructionTypeEqualB2BId
                AND Rule5Id = @dynamicRuleOutgoingSettlementTypeEqualGrossId
                AND Rule6Id = 10006
                AND Rule7Id IS NULL
                AND Rule8Id IS NULL
                AND Rule9Id IS NULL
                AND Rule10Id IS NULL
                AND Source = N'OutgoingPaymentLCY'
                AND Path = @path
                AND TargetMainGL = N''
                AND Target = N''
                AND TargetRuleId = 10013
                AND CustomerCodeSourceRuleId = 10014
                AND CustomerAccountCodeSourceRuleId = 10015)
    BEGIN

    INSERT INTO dbo.AccAccountMap (Id, Ccy, CustomerId, RuleId, Rule2Id, Rule3Id, Rule4Id, Rule5Id, Rule6Id, Rule7Id,
                                   Rule8Id, Rule9Id, Rule10Id, [Source], [Path], TargetMainGL, Target, TargetRuleId,
                                   IsEnabled, [Order], Description, CustomerCodeSourceRuleId,
                                   CustomerAccountCodeSourceRuleId, StateId, StateDate, StateMaker)
    VALUES (@lastAccAccountMapId, NULL, NULL, NULL, @dynamicRuleIsFinancialInstitutionId, NULL,
            @dynamicRuleOutgoingPaymentInstructionTypeEqualB2BId, @dynamicRuleOutgoingSettlementTypeEqualGrossId, 10006,
            NULL, NULL, NULL, NULL, 'OutgoingPaymentLCY', @path, '', '', 10013, 1, 15, '', 10014, 10015, @stateId,
            @stateDate, @stateMaker);

    select @lastAccAccountMapId = @lastAccAccountMapId + 1
    END;

    IF NOT EXISTS(SELECT 1
              FROM dbo.AccAccountMap
              WHERE Ccy IS NULL
                AND CustomerId IS NULL
                AND RuleId IS NULL
                AND Rule2Id = @dynamicRuleIsFinancialInstitutionId
                AND Rule3Id IS NULL
                AND Rule4Id = @dynamicRuleOutgoingPaymentInstructionTypeEqualB2BId
                AND Rule5Id = @dynamicRuleOutgoingSettlementTypeEqualNettingId
                AND Rule6Id IS NULL
                AND Rule7Id = 10009
                AND Rule8Id IS NULL
                AND Rule9Id IS NULL
                AND Rule10Id IS NULL
                AND Source = N'OutgoingPaymentLCY'
                AND Path = @path
                AND TargetMainGL = N'392'
                AND Target = N'39200800'
                AND TargetRuleId IS NULL
                AND CustomerCodeSourceRuleId = 10014
                AND CustomerAccountCodeSourceRuleId = 10015)
    BEGIN

    INSERT INTO dbo.AccAccountMap (Id, Ccy, CustomerId, RuleId, Rule2Id, Rule3Id, Rule4Id, Rule5Id, Rule6Id, Rule7Id,
                                   Rule8Id, Rule9Id, Rule10Id, [Source], [Path], TargetMainGL, Target, TargetRuleId,
                                   IsEnabled, [Order], Description, CustomerCodeSourceRuleId,
                                   CustomerAccountCodeSourceRuleId, StateId, StateDate, StateMaker)
    VALUES (@lastAccAccountMapId, NULL, NULL, NULL, @dynamicRuleIsFinancialInstitutionId, NULL,
            @dynamicRuleOutgoingPaymentInstructionTypeEqualB2BId, @dynamicRuleOutgoingSettlementTypeEqualNettingId,
            NULL, 10009, NULL, NULL, NULL, 'OutgoingPaymentLCY', @path, '392', '39200800', NULL, 1, 20, '', 10014,
            10015, @stateId, @stateDate, @stateMaker);

    select @lastAccAccountMapId = @lastAccAccountMapId + 1
    END;

    IF NOT EXISTS(SELECT 1
              FROM dbo.AccAccountMap
              WHERE Ccy IS NULL
                AND CustomerId IS NULL
                AND RuleId IS NULL
                AND Rule2Id = @dynamicRuleIsFinancialInstitutionId
                AND Rule3Id IS NULL
                AND Rule4Id = @dynamicRuleOutgoingPaymentInstructionTypeEqualB2BId
                AND Rule5Id = @dynamicRuleOutgoingSettlementTypeEqualNettingId
                AND Rule6Id IS NULL
                AND Rule7Id = 10010
                AND Rule8Id IS NULL
                AND Rule9Id IS NULL
                AND Rule10Id IS NULL
                AND Source = N'OutgoingPaymentLCY'
                AND Path = @path
                AND TargetMainGL = N'392'
                AND Target = N'39200800'
                AND TargetRuleId IS NULL
                AND CustomerCodeSourceRuleId IS NULL
                AND CustomerAccountCodeSourceRuleId IS NULL)
    BEGIN
    INSERT INTO dbo.AccAccountMap (Id, Ccy, CustomerId, RuleId, Rule2Id, Rule3Id, Rule4Id, Rule5Id, Rule6Id, Rule7Id,
                                   Rule8Id, Rule9Id, Rule10Id, [Source], [Path], TargetMainGL, Target, TargetRuleId,
                                   IsEnabled, [Order], Description, CustomerCodeSourceRuleId,
                                   CustomerAccountCodeSourceRuleId, StateId, StateDate, StateMaker)
    VALUES (@lastAccAccountMapId, NULL, NULL, NULL, @dynamicRuleIsFinancialInstitutionId, NULL,
            @dynamicRuleOutgoingPaymentInstructionTypeEqualB2BId, @dynamicRuleOutgoingSettlementTypeEqualNettingId,
            NULL, 10010, NULL, NULL, NULL, 'OutgoingPaymentLCY', @path, '392', '39200800', NULL, 1, 25, '', NULL, NULL,
            @stateId, @stateDate, @stateMaker);

    select @lastAccAccountMapId = @lastAccAccountMapId + 1
    END;

    IF NOT EXISTS(SELECT 1
              FROM dbo.AccAccountMap
              WHERE Ccy IS NULL
                AND CustomerId IS NULL
                AND RuleId IS NULL
                AND Rule2Id = @dynamicRuleIsFinancialInstitutionId
                AND Rule3Id IS NULL
                AND Rule4Id = @dynamicRuleOutgoingPaymentInstructionTypeEqualA2AId
                AND Rule5Id = @dynamicRuleOutgoingSettlementTypeEqualGrossId
                AND Rule6Id = 10005
                AND Rule7Id = 10009
                AND Rule8Id IS NULL
                AND Rule9Id IS NULL
                AND Rule10Id IS NULL
                AND Source = N'OutgoingPaymentLCY'
                AND Path = @path
                AND TargetMainGL = N'392'
                AND Target = N'39200800'
                AND TargetRuleId IS NULL
                AND CustomerCodeSourceRuleId = 10014
                AND CustomerAccountCodeSourceRuleId = 10015)
    BEGIN

    INSERT INTO dbo.AccAccountMap (Id, Ccy, CustomerId, RuleId, Rule2Id, Rule3Id, Rule4Id, Rule5Id, Rule6Id, Rule7Id,
                                   Rule8Id, Rule9Id, Rule10Id, [Source], [Path], TargetMainGL, Target, TargetRuleId,
                                   IsEnabled, [Order], Description, CustomerCodeSourceRuleId,
                                   CustomerAccountCodeSourceRuleId, StateId, StateDate, StateMaker)
    VALUES (@lastAccAccountMapId, NULL, NULL, NULL, @dynamicRuleIsFinancialInstitutionId, NULL,
            @dynamicRuleOutgoingPaymentInstructionTypeEqualA2AId, @dynamicRuleOutgoingSettlementTypeEqualGrossId, 10005,
            10009, NULL, NULL, NULL, 'OutgoingPaymentLCY', @path, '392', '39200800', NULL, 1, 30, '', 10014, 10015,
            @stateId, @stateDate, @stateMaker);

    select @lastAccAccountMapId = @lastAccAccountMapId + 1
    END;

    IF NOT EXISTS(SELECT 1
              FROM dbo.AccAccountMap
              WHERE Ccy IS NULL
                AND CustomerId IS NULL
                AND RuleId IS NULL
                AND Rule2Id = @dynamicRuleIsFinancialInstitutionId
                AND Rule3Id IS NULL
                AND Rule4Id = @dynamicRuleOutgoingPaymentInstructionTypeEqualA2AId
                AND Rule5Id = @dynamicRuleOutgoingSettlementTypeEqualGrossId
                AND Rule6Id = 10005
                AND Rule7Id = 10010
                AND Rule8Id IS NULL
                AND Rule9Id IS NULL
                AND Rule10Id IS NULL
                AND Source = N'OutgoingPaymentLCY'
                AND Path = @path
                AND TargetMainGL = N'392'
                AND Target = N'39200800'
                AND TargetRuleId IS NULL
                AND CustomerCodeSourceRuleId IS NULL
                AND CustomerAccountCodeSourceRuleId IS NULL)
    BEGIN

    INSERT INTO dbo.AccAccountMap (Id, Ccy, CustomerId, RuleId, Rule2Id, Rule3Id, Rule4Id, Rule5Id, Rule6Id, Rule7Id,
                                   Rule8Id, Rule9Id, Rule10Id, [Source], [Path], TargetMainGL, Target, TargetRuleId,
                                   IsEnabled, [Order], Description, CustomerCodeSourceRuleId,
                                   CustomerAccountCodeSourceRuleId, StateId, StateDate, StateMaker)
    VALUES (@lastAccAccountMapId, NULL, NULL, NULL, @dynamicRuleIsFinancialInstitutionId, NULL,
            @dynamicRuleOutgoingPaymentInstructionTypeEqualA2AId, @dynamicRuleOutgoingSettlementTypeEqualGrossId, 10005,
            10010, NULL, NULL, NULL, 'OutgoingPaymentLCY', @path, '392', '39200800', NULL, 1, 35, '', NULL, NULL,
            @stateId, @stateDate, @stateMaker);

    select @lastAccAccountMapId = @lastAccAccountMapId + 1
    END;

    IF NOT EXISTS(SELECT 1
              FROM dbo.AccAccountMap
              WHERE Ccy IS NULL
                AND CustomerId IS NULL
                AND RuleId IS NULL
                AND Rule2Id = @dynamicRuleIsFinancialInstitutionId
                AND Rule3Id IS NULL
                AND Rule4Id = @dynamicRuleOutgoingPaymentInstructionTypeEqualA2AId
                AND Rule5Id = @dynamicRuleOutgoingSettlementTypeEqualGrossId
                AND Rule6Id = 10006
                AND Rule7Id IS NULL
                AND Rule8Id IS NULL
                AND Rule9Id IS NULL
                AND Rule10Id IS NULL
                AND Source = N'OutgoingPaymentLCY'
                AND Path = @path
                AND TargetMainGL = N''
                AND Target = N''
                AND TargetRuleId = 10013
                AND CustomerCodeSourceRuleId = 10014
                AND CustomerAccountCodeSourceRuleId = 10015)
    BEGIN

    INSERT INTO dbo.AccAccountMap (Id, Ccy, CustomerId, RuleId, Rule2Id, Rule3Id, Rule4Id, Rule5Id, Rule6Id, Rule7Id,
                                   Rule8Id, Rule9Id, Rule10Id, [Source], [Path], TargetMainGL, Target, TargetRuleId,
                                   IsEnabled, [Order], Description, CustomerCodeSourceRuleId,
                                   CustomerAccountCodeSourceRuleId, StateId, StateDate, StateMaker)
    VALUES (@lastAccAccountMapId, NULL, NULL, NULL, @dynamicRuleIsFinancialInstitutionId, NULL,
            @dynamicRuleOutgoingPaymentInstructionTypeEqualA2AId, @dynamicRuleOutgoingSettlementTypeEqualGrossId, 10006,
            NULL, NULL, NULL, NULL, 'OutgoingPaymentLCY', @path, '', '', 10013, 1, 40, '', 10014, 10015, @stateId,
            @stateDate, @stateMaker);

    select @lastAccAccountMapId = @lastAccAccountMapId + 1
    END;

    IF NOT EXISTS(SELECT 1
              FROM dbo.AccAccountMap
              WHERE Ccy IS NULL
                AND CustomerId IS NULL
                AND RuleId IS NULL
                AND Rule2Id = @dynamicRuleIsFinancialInstitutionId
                AND Rule3Id IS NULL
                AND Rule4Id = @dynamicRuleOutgoingPaymentInstructionTypeEqualA2AId
                AND Rule5Id = @dynamicRuleOutgoingSettlementTypeEqualNettingId
                AND Rule6Id IS NULL
                AND Rule7Id = 10009
                AND Rule8Id IS NULL
                AND Rule9Id IS NULL
                AND Rule10Id IS NULL
                AND Source = N'OutgoingPaymentLCY'
                AND Path = @path
                AND TargetMainGL = N'392'
                AND Target = N'39200800'
                AND TargetRuleId IS NULL
                AND CustomerCodeSourceRuleId = 10014
                AND CustomerAccountCodeSourceRuleId = 10015)
    BEGIN

    INSERT INTO dbo.AccAccountMap (Id, Ccy, CustomerId, RuleId, Rule2Id, Rule3Id, Rule4Id, Rule5Id, Rule6Id, Rule7Id,
                                   Rule8Id, Rule9Id, Rule10Id, [Source], [Path], TargetMainGL, Target, TargetRuleId,
                                   IsEnabled, [Order], Description, CustomerCodeSourceRuleId,
                                   CustomerAccountCodeSourceRuleId, StateId, StateDate, StateMaker)
    VALUES (@lastAccAccountMapId, NULL, NULL, NULL, @dynamicRuleIsFinancialInstitutionId, NULL,
            @dynamicRuleOutgoingPaymentInstructionTypeEqualA2AId, @dynamicRuleOutgoingSettlementTypeEqualNettingId,
            NULL, 10009, NULL, NULL, NULL, 'OutgoingPaymentLCY', @path, '392', '39200800', NULL, 1, 45, '', 10014,
            10015, @stateId, @stateDate, @stateMaker);

    select @lastAccAccountMapId = @lastAccAccountMapId + 1
    END;

    IF NOT EXISTS(SELECT 1
              FROM dbo.AccAccountMap
              WHERE Ccy IS NULL
                AND CustomerId IS NULL
                AND RuleId IS NULL
                AND Rule2Id = @dynamicRuleIsFinancialInstitutionId
                AND Rule3Id IS NULL
                AND Rule4Id = @dynamicRuleOutgoingPaymentInstructionTypeEqualA2AId
                AND Rule5Id = @dynamicRuleOutgoingSettlementTypeEqualNettingId
                AND Rule6Id IS NULL
                AND Rule7Id = 10010
                AND Rule8Id IS NULL
                AND Rule9Id IS NULL
                AND Rule10Id IS NULL
                AND Source = N'OutgoingPaymentLCY'
                AND Path = @path
                AND TargetMainGL = N'392'
                AND Target = N'39200800'
                AND TargetRuleId IS NULL
                AND CustomerCodeSourceRuleId IS NULL
                AND CustomerAccountCodeSourceRuleId IS NULL)
    BEGIN

    INSERT INTO dbo.AccAccountMap (Id, Ccy, CustomerId, RuleId, Rule2Id, Rule3Id, Rule4Id, Rule5Id, Rule6Id, Rule7Id,
                                   Rule8Id, Rule9Id, Rule10Id, [Source], [Path], TargetMainGL, Target, TargetRuleId,
                                   IsEnabled, [Order], Description, CustomerCodeSourceRuleId,
                                   CustomerAccountCodeSourceRuleId, StateId, StateDate, StateMaker)
    VALUES (@lastAccAccountMapId, NULL, NULL, NULL, @dynamicRuleIsFinancialInstitutionId, NULL,
            @dynamicRuleOutgoingPaymentInstructionTypeEqualA2AId, @dynamicRuleOutgoingSettlementTypeEqualNettingId,
            NULL, 10010, NULL, NULL, NULL, 'OutgoingPaymentLCY', @path, '392', '39200800', NULL, 1, 50, '', NULL, NULL,
            @stateId, @stateDate, @stateMaker);

    select @lastAccAccountMapId = @lastAccAccountMapId + 1
    END;

    IF NOT EXISTS(SELECT 1
              FROM dbo.AccAccountMap
              WHERE Ccy IS NULL
                AND CustomerId IS NULL
                AND RuleId IS NULL
                AND Rule2Id = @dynamicRuleIsFinancialInstitutionId
                AND Rule3Id IS NULL
                AND Rule4Id = @dynamicRuleOutgoingPaymentInstructionTypeEqualV2VId
                AND Rule5Id = @dynamicRuleOutgoingSettlementTypeEqualGrossId
                AND Rule6Id = 10005
                AND Rule7Id = 10009
                AND Rule8Id IS NULL
                AND Rule9Id IS NULL
                AND Rule10Id IS NULL
                AND Source = N'OutgoingPaymentLCY'
                AND Path = @path
                AND TargetMainGL = N'392'
                AND Target = N'39200800'
                AND TargetRuleId IS NULL
                AND CustomerCodeSourceRuleId = 10023
                AND CustomerAccountCodeSourceRuleId = 10024)
    BEGIN

    INSERT INTO dbo.AccAccountMap (Id, Ccy, CustomerId, RuleId, Rule2Id, Rule3Id, Rule4Id, Rule5Id, Rule6Id, Rule7Id,
                                   Rule8Id, Rule9Id, Rule10Id, [Source], [Path], TargetMainGL, Target, TargetRuleId,
                                   IsEnabled, [Order], Description, CustomerCodeSourceRuleId,
                                   CustomerAccountCodeSourceRuleId, StateId, StateDate, StateMaker)
    VALUES (@lastAccAccountMapId, NULL, NULL, NULL, @dynamicRuleIsFinancialInstitutionId, NULL,
            @dynamicRuleOutgoingPaymentInstructionTypeEqualV2VId, @dynamicRuleOutgoingSettlementTypeEqualGrossId, 10005,
            10009, NULL, NULL, NULL, 'OutgoingPaymentLCY', @path, '392', '39200800', NULL, 1, 55, '', 10023, 10024,
            @stateId, @stateDate, @stateMaker);

    select @lastAccAccountMapId = @lastAccAccountMapId + 1
    END;

    IF NOT EXISTS(SELECT 1
              FROM dbo.AccAccountMap
              WHERE Ccy IS NULL
                AND CustomerId IS NULL
                AND RuleId IS NULL
                AND Rule2Id = @dynamicRuleIsFinancialInstitutionId
                AND Rule3Id IS NULL
                AND Rule4Id = @dynamicRuleOutgoingPaymentInstructionTypeEqualV2VId
                AND Rule5Id = @dynamicRuleOutgoingSettlementTypeEqualGrossId
                AND Rule6Id = 10005
                AND Rule7Id = 10010
                AND Rule8Id IS NULL
                AND Rule9Id IS NULL
                AND Rule10Id IS NULL
                AND Source = N'OutgoingPaymentLCY'
                AND Path = @path
                AND TargetMainGL = N'392'
                AND Target = N'39200800'
                AND TargetRuleId IS NULL
                AND CustomerCodeSourceRuleId IS NULL
                AND CustomerAccountCodeSourceRuleId IS NULL)
    BEGIN

    INSERT INTO dbo.AccAccountMap (Id, Ccy, CustomerId, RuleId, Rule2Id, Rule3Id, Rule4Id, Rule5Id, Rule6Id, Rule7Id,
                                   Rule8Id, Rule9Id, Rule10Id, [Source], [Path], TargetMainGL, Target, TargetRuleId,
                                   IsEnabled, [Order], Description, CustomerCodeSourceRuleId,
                                   CustomerAccountCodeSourceRuleId, StateId, StateDate, StateMaker)
    VALUES (@lastAccAccountMapId, NULL, NULL, NULL, @dynamicRuleIsFinancialInstitutionId, NULL,
            @dynamicRuleOutgoingPaymentInstructionTypeEqualV2VId, @dynamicRuleOutgoingSettlementTypeEqualGrossId, 10005,
            10010, NULL, NULL, NULL, 'OutgoingPaymentLCY', @path, '392', '39200800', NULL, 1, 60, '', NULL, NULL,
            @stateId, @stateDate, @stateMaker);

    select @lastAccAccountMapId = @lastAccAccountMapId + 1
    END;

    IF NOT EXISTS(SELECT 1
              FROM dbo.AccAccountMap
              WHERE Ccy IS NULL
                AND CustomerId IS NULL
                AND RuleId IS NULL
                AND Rule2Id = @dynamicRuleIsFinancialInstitutionId
                AND Rule3Id IS NULL
                AND Rule4Id = @dynamicRuleOutgoingPaymentInstructionTypeEqualV2VId
                AND Rule5Id = @dynamicRuleOutgoingSettlementTypeEqualGrossId
                AND Rule6Id = 10006
                AND Rule7Id IS NULL
                AND Rule8Id IS NULL
                AND Rule9Id IS NULL
                AND Rule10Id IS NULL
                AND Source = N'OutgoingPaymentLCY'
                AND Path = @path
                AND TargetMainGL = N''
                AND Target = N''
                AND TargetRuleId = 10022
                AND CustomerCodeSourceRuleId = 10023
                AND CustomerAccountCodeSourceRuleId = 10024)
    BEGIN
    INSERT INTO dbo.AccAccountMap (Id, Ccy, CustomerId, RuleId, Rule2Id, Rule3Id, Rule4Id, Rule5Id, Rule6Id, Rule7Id,
                                   Rule8Id, Rule9Id, Rule10Id, [Source], [Path], TargetMainGL, Target, TargetRuleId,
                                   IsEnabled, [Order], Description, CustomerCodeSourceRuleId,
                                   CustomerAccountCodeSourceRuleId, StateId, StateDate, StateMaker)
    VALUES (@lastAccAccountMapId, NULL, NULL, NULL, @dynamicRuleIsFinancialInstitutionId, NULL,
            @dynamicRuleOutgoingPaymentInstructionTypeEqualV2VId, @dynamicRuleOutgoingSettlementTypeEqualGrossId, 10006,
            NULL, NULL, NULL, NULL, 'OutgoingPaymentLCY', @path, '', '', 10022, 1, 65, '', 10023, 10024, @stateId,
            @stateDate, @stateMaker);

    select @lastAccAccountMapId = @lastAccAccountMapId + 1
    END;

    IF NOT EXISTS(SELECT 1
              FROM dbo.AccAccountMap
              WHERE Ccy IS NULL
                AND CustomerId IS NULL
                AND RuleId IS NULL
                AND Rule2Id = @dynamicRuleIsFinancialInstitutionId
                AND Rule3Id IS NULL
                AND Rule4Id = @dynamicRuleOutgoingPaymentInstructionTypeEqualV2VId
                AND Rule5Id = @dynamicRuleOutgoingSettlementTypeEqualNettingId
                AND Rule6Id IS NULL
                AND Rule7Id = 10009
                AND Rule8Id IS NULL
                AND Rule9Id IS NULL
                AND Rule10Id IS NULL
                AND Source = N'OutgoingPaymentLCY'
                AND Path = @path
                AND TargetMainGL = N'392'
                AND Target = N'39200800'
                AND TargetRuleId IS NULL
                AND CustomerCodeSourceRuleId = 10023
                AND CustomerAccountCodeSourceRuleId = 10024)
    BEGIN

    INSERT INTO dbo.AccAccountMap (Id, Ccy, CustomerId, RuleId, Rule2Id, Rule3Id, Rule4Id, Rule5Id, Rule6Id, Rule7Id,
                                   Rule8Id, Rule9Id, Rule10Id, [Source], [Path], TargetMainGL, Target, TargetRuleId,
                                   IsEnabled, [Order], Description, CustomerCodeSourceRuleId,
                                   CustomerAccountCodeSourceRuleId, StateId, StateDate, StateMaker)
    VALUES (@lastAccAccountMapId, NULL, NULL, NULL, @dynamicRuleIsFinancialInstitutionId, NULL,
            @dynamicRuleOutgoingPaymentInstructionTypeEqualV2VId, @dynamicRuleOutgoingSettlementTypeEqualNettingId,
            NULL, 10009, NULL, NULL, NULL, 'OutgoingPaymentLCY', @path, '392', '39200800', NULL, 1, 70, '', 10023,
            10024, @stateId, @stateDate, @stateMaker);

    select @lastAccAccountMapId = @lastAccAccountMapId + 1
    END;

    IF NOT EXISTS(SELECT 1
              FROM dbo.AccAccountMap
              WHERE Ccy IS NULL
                AND CustomerId IS NULL
                AND RuleId IS NULL
                AND Rule2Id = @dynamicRuleIsFinancialInstitutionId
                AND Rule3Id IS NULL
                AND Rule4Id = @dynamicRuleOutgoingPaymentInstructionTypeEqualV2VId
                AND Rule5Id = @dynamicRuleOutgoingSettlementTypeEqualNettingId
                AND Rule6Id IS NULL
                AND Rule7Id = 10010
                AND Rule8Id IS NULL
                AND Rule9Id IS NULL
                AND Rule10Id IS NULL
                AND Source = N'OutgoingPaymentLCY'
                AND Path = @path
                AND TargetMainGL = N'392'
                AND Target = N'39200800'
                AND TargetRuleId IS NULL
                AND CustomerCodeSourceRuleId IS NULL
                AND CustomerAccountCodeSourceRuleId IS NULL)
    BEGIN
    INSERT INTO dbo.AccAccountMap (Id, Ccy, CustomerId, RuleId, Rule2Id, Rule3Id, Rule4Id, Rule5Id, Rule6Id, Rule7Id,
                                   Rule8Id, Rule9Id, Rule10Id, [Source], [Path], TargetMainGL, Target, TargetRuleId,
                                   IsEnabled, [Order], Description, CustomerCodeSourceRuleId,
                                   CustomerAccountCodeSourceRuleId, StateId, StateDate, StateMaker)
    VALUES (@lastAccAccountMapId, NULL, NULL, NULL, @dynamicRuleIsFinancialInstitutionId, NULL,
            @dynamicRuleOutgoingPaymentInstructionTypeEqualV2VId, @dynamicRuleOutgoingSettlementTypeEqualNettingId,
            NULL, 10010, NULL, NULL, NULL, 'OutgoingPaymentLCY', @path, '392', '39200800', NULL, 1, 75, '', NULL, NULL,
            @stateId, @stateDate, @stateMaker);

    select @lastAccAccountMapId = @lastAccAccountMapId + 1
    END;

    ------------------------------------------------------------------------------------------------------------------------
    -- OutgoingPaymentFCY
    ------------------------------------------------------------------------------------------------------------------------
    IF NOT EXISTS(SELECT 1
              FROM dbo.AccAccountMap
              WHERE Ccy IS NULL
                AND CustomerId IS NULL
                AND RuleId IS NULL
                AND Rule2Id = @dynamicRuleIsFinancialInstitutionId
                AND Rule3Id IS NULL
                AND Rule4Id IS NULL
                AND Rule5Id IS NULL
                AND Rule6Id IS NULL
                AND Rule7Id IS NULL
                AND Rule8Id IS NULL
                AND Rule9Id IS NULL
                AND Rule10Id IS NULL
                AND Source = N'OutgoingPaymentFCY'
                AND Path = @path
                AND TargetMainGL = N'392'
                AND Target = N'39200800'
                AND TargetRuleId IS NULL
                AND CustomerCodeSourceRuleId IS NULL
                AND CustomerAccountCodeSourceRuleId IS NULL)
    BEGIN

    INSERT INTO dbo.AccAccountMap (Id, Ccy, CustomerId, RuleId, Rule2Id, Rule3Id, Rule4Id, Rule5Id, Rule6Id, Rule7Id,
                                   Rule8Id, Rule9Id, Rule10Id, [Source], [Path], TargetMainGL, Target, TargetRuleId,
                                   IsEnabled, [Order], Description, CustomerCodeSourceRuleId,
                                   CustomerAccountCodeSourceRuleId, StateId, StateDate, StateMaker)
    VALUES (@lastAccAccountMapId, NULL, NULL, NULL, @dynamicRuleIsFinancialInstitutionId, NULL, NULL, NULL, NULL, NULL,
            NULL, NULL, NULL, 'OutgoingPaymentFCY', @path, '392', '39200800', NULL, 0, 1, 'Payment ', NULL, NULL,
            @stateId, @stateDate, @stateMaker);

    select @lastAccAccountMapId = @lastAccAccountMapId + 1
    END;

    IF NOT EXISTS(SELECT 1
              FROM dbo.AccAccountMap
              WHERE Ccy IS NULL
                AND CustomerId IS NULL
                AND RuleId IS NULL
                AND Rule2Id = @dynamicRuleIsFinancialInstitutionId
                AND Rule3Id IS NULL
                AND Rule4Id = @dynamicRuleOutgoingPaymentInstructionTypeEqualB2BId
                AND Rule5Id = @dynamicRuleOutgoingSettlementTypeEqualGrossId
                AND Rule6Id = 10005
                AND Rule7Id = 10009
                AND Rule8Id IS NULL
                AND Rule9Id IS NULL
                AND Rule10Id IS NULL
                AND Source = N'OutgoingPaymentFCY'
                AND Path = @path
                AND TargetMainGL = N'393'
                AND Target = N'39300800'
                AND TargetRuleId IS NULL
                AND CustomerCodeSourceRuleId = 10014
                AND CustomerAccountCodeSourceRuleId = 10015)
    BEGIN
    INSERT INTO dbo.AccAccountMap (Id, Ccy, CustomerId, RuleId, Rule2Id, Rule3Id, Rule4Id, Rule5Id, Rule6Id, Rule7Id,
                                   Rule8Id, Rule9Id, Rule10Id, [Source], [Path], TargetMainGL, Target, TargetRuleId,
                                   IsEnabled, [Order], Description, CustomerCodeSourceRuleId,
                                   CustomerAccountCodeSourceRuleId, StateId, StateDate, StateMaker)
    VALUES (@lastAccAccountMapId, NULL, NULL, NULL, @dynamicRuleIsFinancialInstitutionId, NULL,
            @dynamicRuleOutgoingPaymentInstructionTypeEqualB2BId, @dynamicRuleOutgoingSettlementTypeEqualGrossId, 10005,
            10009, NULL, NULL, NULL, 'OutgoingPaymentFCY', @path, '393', '39300800', NULL, 1, 5, '', 10014, 10015,
            @stateId, @stateDate, @stateMaker);

    select @lastAccAccountMapId = @lastAccAccountMapId + 1
    END;

    IF NOT EXISTS(SELECT 1
              FROM dbo.AccAccountMap
              WHERE Ccy IS NULL
                AND CustomerId IS NULL
                AND RuleId IS NULL
                AND Rule2Id = @dynamicRuleIsFinancialInstitutionId
                AND Rule3Id IS NULL
                AND Rule4Id = @dynamicRuleOutgoingPaymentInstructionTypeEqualB2BId
                AND Rule5Id = @dynamicRuleOutgoingSettlementTypeEqualGrossId
                AND Rule6Id = 10005
                AND Rule7Id = 10010
                AND Rule8Id IS NULL
                AND Rule9Id IS NULL
                AND Rule10Id IS NULL
                AND Source = N'OutgoingPaymentFCY'
                AND Path = @path
                AND TargetMainGL = N'393'
                AND Target = N'39300800'
                AND TargetRuleId IS NULL
                AND CustomerCodeSourceRuleId IS NULL
                AND CustomerAccountCodeSourceRuleId IS NULL)
    BEGIN
    INSERT INTO dbo.AccAccountMap (Id, Ccy, CustomerId, RuleId, Rule2Id, Rule3Id, Rule4Id, Rule5Id, Rule6Id, Rule7Id,
                                   Rule8Id, Rule9Id, Rule10Id, [Source], [Path], TargetMainGL, Target, TargetRuleId,
                                   IsEnabled, [Order], Description, CustomerCodeSourceRuleId,
                                   CustomerAccountCodeSourceRuleId, StateId, StateDate, StateMaker)
    VALUES (@lastAccAccountMapId, NULL, NULL, NULL, @dynamicRuleIsFinancialInstitutionId, NULL,
            @dynamicRuleOutgoingPaymentInstructionTypeEqualB2BId, @dynamicRuleOutgoingSettlementTypeEqualGrossId, 10005,
            10010, NULL, NULL, NULL, 'OutgoingPaymentFCY', @path, '393', '39300800', NULL, 1, 10, '', NULL, NULL,
            @stateId, @stateDate, @stateMaker);

    select @lastAccAccountMapId = @lastAccAccountMapId + 1
    END;

    IF NOT EXISTS(SELECT 1
              FROM dbo.AccAccountMap
              WHERE Ccy IS NULL
                AND CustomerId IS NULL
                AND RuleId IS NULL
                AND Rule2Id = @dynamicRuleIsFinancialInstitutionId
                AND Rule3Id IS NULL
                AND Rule4Id = @dynamicRuleOutgoingPaymentInstructionTypeEqualB2BId
                AND Rule5Id = @dynamicRuleOutgoingSettlementTypeEqualGrossId
                AND Rule6Id = 10006
                AND Rule7Id IS NULL
                AND Rule8Id IS NULL
                AND Rule9Id IS NULL
                AND Rule10Id IS NULL
                AND Source = N'OutgoingPaymentFCY'
                AND Path = @path
                AND TargetMainGL = ''
                AND Target = ''
                AND TargetRuleId = 10013
                AND CustomerCodeSourceRuleId = 10014
                AND CustomerAccountCodeSourceRuleId = 10015)
    BEGIN
    INSERT INTO dbo.AccAccountMap (Id, Ccy, CustomerId, RuleId, Rule2Id, Rule3Id, Rule4Id, Rule5Id, Rule6Id, Rule7Id,
                                   Rule8Id, Rule9Id, Rule10Id, [Source], [Path], TargetMainGL, Target, TargetRuleId,
                                   IsEnabled, [Order], Description, CustomerCodeSourceRuleId,
                                   CustomerAccountCodeSourceRuleId, StateId, StateDate, StateMaker)
    VALUES (@lastAccAccountMapId, NULL, NULL, NULL, @dynamicRuleIsFinancialInstitutionId, NULL,
            @dynamicRuleOutgoingPaymentInstructionTypeEqualB2BId, @dynamicRuleOutgoingSettlementTypeEqualGrossId, 10006,
            NULL, NULL, NULL, NULL, 'OutgoingPaymentFCY', @path, '', '', 10013, 1, 15, '', 10014, 10015, @stateId,
            @stateDate, @stateMaker);

    select @lastAccAccountMapId = @lastAccAccountMapId + 1
    END;

    IF NOT EXISTS(SELECT 1
              FROM dbo.AccAccountMap
              WHERE Ccy IS NULL
                AND CustomerId IS NULL
                AND RuleId IS NULL
                AND Rule2Id = @dynamicRuleIsFinancialInstitutionId
                AND Rule3Id IS NULL
                AND Rule4Id = @dynamicRuleOutgoingPaymentInstructionTypeEqualB2BId
                AND Rule5Id = @dynamicRuleOutgoingSettlementTypeEqualNettingId
                AND Rule6Id IS NULL
                AND Rule7Id = 10009
                AND Rule8Id IS NULL
                AND Rule9Id IS NULL
                AND Rule10Id IS NULL
                AND Source = N'OutgoingPaymentFCY'
                AND Path = @path
                AND TargetMainGL = '393'
                AND Target = '39300800'
                AND TargetRuleId IS NULL
                AND CustomerCodeSourceRuleId = 10014
                AND CustomerAccountCodeSourceRuleId = 10015)
    BEGIN
    INSERT INTO dbo.AccAccountMap (Id, Ccy, CustomerId, RuleId, Rule2Id, Rule3Id, Rule4Id, Rule5Id, Rule6Id, Rule7Id,
                                   Rule8Id, Rule9Id, Rule10Id, [Source], [Path], TargetMainGL, Target, TargetRuleId,
                                   IsEnabled, [Order], Description, CustomerCodeSourceRuleId,
                                   CustomerAccountCodeSourceRuleId, StateId, StateDate, StateMaker)
    VALUES (@lastAccAccountMapId, NULL, NULL, NULL, @dynamicRuleIsFinancialInstitutionId, NULL,
            @dynamicRuleOutgoingPaymentInstructionTypeEqualB2BId, @dynamicRuleOutgoingSettlementTypeEqualNettingId,
            NULL, 10009, NULL, NULL, NULL, 'OutgoingPaymentFCY', @path, '393', '39300800', NULL, 1, 20, '', 10014,
            10015, @stateId, @stateDate, @stateMaker);

    select @lastAccAccountMapId = @lastAccAccountMapId + 1
    END;

    IF NOT EXISTS(SELECT 1
              FROM dbo.AccAccountMap
              WHERE Ccy IS NULL
                AND CustomerId IS NULL
                AND RuleId IS NULL
                AND Rule2Id = @dynamicRuleIsFinancialInstitutionId
                AND Rule3Id IS NULL
                AND Rule4Id = @dynamicRuleOutgoingPaymentInstructionTypeEqualB2BId
                AND Rule5Id = @dynamicRuleOutgoingSettlementTypeEqualNettingId
                AND Rule6Id IS NULL
                AND Rule7Id = 10010
                AND Rule8Id IS NULL
                AND Rule9Id IS NULL
                AND Rule10Id IS NULL
                AND Source = N'OutgoingPaymentFCY'
                AND Path = @path
                AND TargetMainGL = '393'
                AND Target = '39300800'
                AND TargetRuleId IS NULL
                AND CustomerCodeSourceRuleId IS NULL
                AND CustomerAccountCodeSourceRuleId IS NULL)
    BEGIN
    INSERT INTO dbo.AccAccountMap (Id, Ccy, CustomerId, RuleId, Rule2Id, Rule3Id, Rule4Id, Rule5Id, Rule6Id, Rule7Id,
                                   Rule8Id, Rule9Id, Rule10Id, [Source], [Path], TargetMainGL, Target, TargetRuleId,
                                   IsEnabled, [Order], Description, CustomerCodeSourceRuleId,
                                   CustomerAccountCodeSourceRuleId, StateId, StateDate, StateMaker)
    VALUES (@lastAccAccountMapId, NULL, NULL, NULL, @dynamicRuleIsFinancialInstitutionId, NULL,
            @dynamicRuleOutgoingPaymentInstructionTypeEqualB2BId, @dynamicRuleOutgoingSettlementTypeEqualNettingId,
            NULL, 10010, NULL, NULL, NULL, 'OutgoingPaymentFCY', @path, '393', '39300800', NULL, 1, 25, '', NULL, NULL,
            @stateId, @stateDate, @stateMaker);

    select @lastAccAccountMapId = @lastAccAccountMapId + 1
    END;

    IF NOT EXISTS(SELECT 1
              FROM dbo.AccAccountMap
              WHERE Ccy IS NULL
                AND CustomerId IS NULL
                AND RuleId IS NULL
                AND Rule2Id = @dynamicRuleIsFinancialInstitutionId
                AND Rule3Id IS NULL
                AND Rule4Id = @dynamicRuleOutgoingPaymentInstructionTypeEqualA2AId
                AND Rule5Id = @dynamicRuleOutgoingSettlementTypeEqualGrossId
                AND Rule6Id = 10005
                AND Rule7Id = 10009
                AND Rule8Id IS NULL
                AND Rule9Id IS NULL
                AND Rule10Id IS NULL
                AND Source = N'OutgoingPaymentFCY'
                AND Path = @path
                AND TargetMainGL = '393'
                AND Target = '39300800'
                AND TargetRuleId IS NULL
                AND CustomerCodeSourceRuleId = 10014
                AND CustomerAccountCodeSourceRuleId = 10015)
    BEGIN
    INSERT INTO dbo.AccAccountMap (Id, Ccy, CustomerId, RuleId, Rule2Id, Rule3Id, Rule4Id, Rule5Id, Rule6Id, Rule7Id,
                                   Rule8Id, Rule9Id, Rule10Id, [Source], [Path], TargetMainGL, Target, TargetRuleId,
                                   IsEnabled, [Order], Description, CustomerCodeSourceRuleId,
                                   CustomerAccountCodeSourceRuleId, StateId, StateDate, StateMaker)
    VALUES (@lastAccAccountMapId, NULL, NULL, NULL, @dynamicRuleIsFinancialInstitutionId, NULL,
            @dynamicRuleOutgoingPaymentInstructionTypeEqualA2AId, @dynamicRuleOutgoingSettlementTypeEqualGrossId, 10005,
            10009, NULL, NULL, NULL, 'OutgoingPaymentFCY', @path, '393', '39300800', NULL, 1, 30, '', 10014, 10015,
            @stateId, @stateDate, @stateMaker);

    select @lastAccAccountMapId = @lastAccAccountMapId + 1
    END;

    IF NOT EXISTS(SELECT 1
              FROM dbo.AccAccountMap
              WHERE Ccy IS NULL
                AND CustomerId IS NULL
                AND RuleId IS NULL
                AND Rule2Id = @dynamicRuleIsFinancialInstitutionId
                AND Rule3Id IS NULL
                AND Rule4Id = @dynamicRuleOutgoingPaymentInstructionTypeEqualA2AId
                AND Rule5Id = @dynamicRuleOutgoingSettlementTypeEqualGrossId
                AND Rule6Id = 10005
                AND Rule7Id = 10010
                AND Rule8Id IS NULL
                AND Rule9Id IS NULL
                AND Rule10Id IS NULL
                AND Source = N'OutgoingPaymentFCY'
                AND Path = @path
                AND TargetMainGL = '393'
                AND Target = '39300800'
                AND TargetRuleId IS NULL
                AND CustomerCodeSourceRuleId IS NULL
                AND CustomerAccountCodeSourceRuleId IS NULL)
    BEGIN
    INSERT INTO dbo.AccAccountMap (Id, Ccy, CustomerId, RuleId, Rule2Id, Rule3Id, Rule4Id, Rule5Id, Rule6Id, Rule7Id,
                                   Rule8Id, Rule9Id, Rule10Id, [Source], [Path], TargetMainGL, Target, TargetRuleId,
                                   IsEnabled, [Order], Description, CustomerCodeSourceRuleId,
                                   CustomerAccountCodeSourceRuleId, StateId, StateDate, StateMaker)
    VALUES (@lastAccAccountMapId, NULL, NULL, NULL, @dynamicRuleIsFinancialInstitutionId, NULL,
            @dynamicRuleOutgoingPaymentInstructionTypeEqualA2AId, @dynamicRuleOutgoingSettlementTypeEqualGrossId, 10005,
            10010, NULL, NULL, NULL, 'OutgoingPaymentFCY', @path, '393', '39300800', NULL, 1, 35, '', NULL, NULL,
            @stateId, @stateDate, @stateMaker);

    select @lastAccAccountMapId = @lastAccAccountMapId + 1
    END;

    IF NOT EXISTS(SELECT 1
              FROM dbo.AccAccountMap
              WHERE Ccy IS NULL
                AND CustomerId IS NULL
                AND RuleId IS NULL
                AND Rule2Id = @dynamicRuleIsFinancialInstitutionId
                AND Rule3Id IS NULL
                AND Rule4Id = @dynamicRuleOutgoingPaymentInstructionTypeEqualA2AId
                AND Rule5Id = @dynamicRuleOutgoingSettlementTypeEqualGrossId
                AND Rule6Id = 10006
                AND Rule7Id IS NULL
                AND Rule8Id IS NULL
                AND Rule9Id IS NULL
                AND Rule10Id IS NULL
                AND Source = N'OutgoingPaymentFCY'
                AND Path = @path
                AND TargetMainGL = ''
                AND Target = ''
                AND TargetRuleId = 10013
                AND CustomerCodeSourceRuleId = 10014
                AND CustomerAccountCodeSourceRuleId = 10015)
    BEGIN
    INSERT INTO dbo.AccAccountMap (Id, Ccy, CustomerId, RuleId, Rule2Id, Rule3Id, Rule4Id, Rule5Id, Rule6Id, Rule7Id,
                                   Rule8Id, Rule9Id, Rule10Id, [Source], [Path], TargetMainGL, Target, TargetRuleId,
                                   IsEnabled, [Order], Description, CustomerCodeSourceRuleId,
                                   CustomerAccountCodeSourceRuleId, StateId, StateDate, StateMaker)
    VALUES (@lastAccAccountMapId, NULL, NULL, NULL, @dynamicRuleIsFinancialInstitutionId, NULL,
            @dynamicRuleOutgoingPaymentInstructionTypeEqualA2AId, @dynamicRuleOutgoingSettlementTypeEqualGrossId, 10006,
            NULL, NULL, NULL, NULL, 'OutgoingPaymentFCY', @path, '', '', 10013, 1, 40, '', 10014, 10015, @stateId,
            @stateDate, @stateMaker);

    select @lastAccAccountMapId = @lastAccAccountMapId + 1
    END;

    IF NOT EXISTS(SELECT 1
              FROM dbo.AccAccountMap
              WHERE Ccy IS NULL
                AND CustomerId IS NULL
                AND RuleId IS NULL
                AND Rule2Id = @dynamicRuleIsFinancialInstitutionId
                AND Rule3Id IS NULL
                AND Rule4Id = @dynamicRuleOutgoingPaymentInstructionTypeEqualA2AId
                AND Rule5Id = @dynamicRuleOutgoingSettlementTypeEqualNettingId
                AND Rule6Id IS NULL
                AND Rule7Id = 10009
                AND Rule8Id IS NULL
                AND Rule9Id IS NULL
                AND Rule10Id IS NULL
                AND Source = N'OutgoingPaymentFCY'
                AND Path = @path
                AND TargetMainGL = '393'
                AND Target = '39300800'
                AND TargetRuleId IS NULL
                AND CustomerCodeSourceRuleId = 10014
                AND CustomerAccountCodeSourceRuleId = 10015)
    BEGIN
    INSERT INTO dbo.AccAccountMap (Id, Ccy, CustomerId, RuleId, Rule2Id, Rule3Id, Rule4Id, Rule5Id, Rule6Id, Rule7Id,
                                   Rule8Id, Rule9Id, Rule10Id, [Source], [Path], TargetMainGL, Target, TargetRuleId,
                                   IsEnabled, [Order], Description, CustomerCodeSourceRuleId,
                                   CustomerAccountCodeSourceRuleId, StateId, StateDate, StateMaker)
    VALUES (@lastAccAccountMapId, NULL, NULL, NULL, @dynamicRuleIsFinancialInstitutionId, NULL,
            @dynamicRuleOutgoingPaymentInstructionTypeEqualA2AId, @dynamicRuleOutgoingSettlementTypeEqualNettingId,
            NULL, 10009, NULL, NULL, NULL, 'OutgoingPaymentFCY', @path, '393', '39300800', NULL, 1, 45, '', 10014,
            10015, @stateId, @stateDate, @stateMaker);

    select @lastAccAccountMapId = @lastAccAccountMapId + 1
    END;

    IF NOT EXISTS(SELECT 1
              FROM dbo.AccAccountMap
              WHERE Ccy IS NULL
                AND CustomerId IS NULL
                AND RuleId IS NULL
                AND Rule2Id = @dynamicRuleIsFinancialInstitutionId
                AND Rule3Id IS NULL
                AND Rule4Id = @dynamicRuleOutgoingPaymentInstructionTypeEqualA2AId
                AND Rule5Id = @dynamicRuleOutgoingSettlementTypeEqualNettingId
                AND Rule6Id IS NULL
                AND Rule7Id = 10010
                AND Rule8Id IS NULL
                AND Rule9Id IS NULL
                AND Rule10Id IS NULL
                AND Source = N'OutgoingPaymentFCY'
                AND Path = @path
                AND TargetMainGL = '393'
                AND Target = '39300800'
                AND TargetRuleId IS NULL
                AND CustomerCodeSourceRuleId IS NULL
                AND CustomerAccountCodeSourceRuleId IS NULL)
    BEGIN
    INSERT INTO dbo.AccAccountMap (Id, Ccy, CustomerId, RuleId, Rule2Id, Rule3Id, Rule4Id, Rule5Id, Rule6Id, Rule7Id,
                                   Rule8Id, Rule9Id, Rule10Id, [Source], [Path], TargetMainGL, Target, TargetRuleId,
                                   IsEnabled, [Order], Description, CustomerCodeSourceRuleId,
                                   CustomerAccountCodeSourceRuleId, StateId, StateDate, StateMaker)
    VALUES (@lastAccAccountMapId, NULL, NULL, NULL, @dynamicRuleIsFinancialInstitutionId, NULL,
            @dynamicRuleOutgoingPaymentInstructionTypeEqualA2AId, @dynamicRuleOutgoingSettlementTypeEqualNettingId,
            NULL, 10010, NULL, NULL, NULL, 'OutgoingPaymentFCY', @path, '393', '39300800', NULL, 1, 50, '', NULL, NULL,
            @stateId, @stateDate, @stateMaker);

    select @lastAccAccountMapId = @lastAccAccountMapId + 1
    END;

    IF NOT EXISTS(SELECT 1
              FROM dbo.AccAccountMap
              WHERE Ccy IS NULL
                AND CustomerId IS NULL
                AND RuleId IS NULL
                AND Rule2Id = @dynamicRuleIsFinancialInstitutionId
                AND Rule3Id IS NULL
                AND Rule4Id = @dynamicRuleOutgoingPaymentInstructionTypeEqualV2VId
                AND Rule5Id = @dynamicRuleOutgoingSettlementTypeEqualGrossId
                AND Rule6Id = 10005
                AND Rule7Id = 10009
                AND Rule8Id IS NULL
                AND Rule9Id IS NULL
                AND Rule10Id IS NULL
                AND Source = N'OutgoingPaymentFCY'
                AND Path = @path
                AND TargetMainGL = '393'
                AND Target = '39300800'
                AND TargetRuleId IS NULL
                AND CustomerCodeSourceRuleId = 10023
                AND CustomerAccountCodeSourceRuleId = 10024)
    BEGIN
    INSERT INTO dbo.AccAccountMap (Id, Ccy, CustomerId, RuleId, Rule2Id, Rule3Id, Rule4Id, Rule5Id, Rule6Id, Rule7Id,
                                   Rule8Id, Rule9Id, Rule10Id, [Source], [Path], TargetMainGL, Target, TargetRuleId,
                                   IsEnabled, [Order], Description, CustomerCodeSourceRuleId,
                                   CustomerAccountCodeSourceRuleId, StateId, StateDate, StateMaker)
    VALUES (@lastAccAccountMapId, NULL, NULL, NULL, @dynamicRuleIsFinancialInstitutionId, NULL,
            @dynamicRuleOutgoingPaymentInstructionTypeEqualV2VId, @dynamicRuleOutgoingSettlementTypeEqualGrossId, 10005,
            10009, NULL, NULL, NULL, 'OutgoingPaymentFCY', @path, '393', '39300800', NULL, 1, 55, '', 10023, 10024,
            @stateId, @stateDate, @stateMaker);

    select @lastAccAccountMapId = @lastAccAccountMapId + 1
    END;

    IF NOT EXISTS(SELECT 1
              FROM dbo.AccAccountMap
              WHERE Ccy IS NULL
                AND CustomerId IS NULL
                AND RuleId IS NULL
                AND Rule2Id = @dynamicRuleIsFinancialInstitutionId
                AND Rule3Id IS NULL
                AND Rule4Id = @dynamicRuleOutgoingPaymentInstructionTypeEqualV2VId
                AND Rule5Id = @dynamicRuleOutgoingSettlementTypeEqualGrossId
                AND Rule6Id = 10005
                AND Rule7Id = 10010
                AND Rule8Id IS NULL
                AND Rule9Id IS NULL
                AND Rule10Id IS NULL
                AND Source = N'OutgoingPaymentFCY'
                AND Path = @path
                AND TargetMainGL = '393'
                AND Target = '39300800'
                AND TargetRuleId IS NULL
                AND CustomerCodeSourceRuleId IS NULL
                AND CustomerAccountCodeSourceRuleId IS NULL)
    BEGIN
    INSERT INTO dbo.AccAccountMap (Id, Ccy, CustomerId, RuleId, Rule2Id, Rule3Id, Rule4Id, Rule5Id, Rule6Id, Rule7Id,
                                   Rule8Id, Rule9Id, Rule10Id, [Source], [Path], TargetMainGL, Target, TargetRuleId,
                                   IsEnabled, [Order], Description, CustomerCodeSourceRuleId,
                                   CustomerAccountCodeSourceRuleId, StateId, StateDate, StateMaker)
    VALUES (@lastAccAccountMapId, NULL, NULL, NULL, @dynamicRuleIsFinancialInstitutionId, NULL,
            @dynamicRuleOutgoingPaymentInstructionTypeEqualV2VId, @dynamicRuleOutgoingSettlementTypeEqualGrossId, 10005,
            10010, NULL, NULL, NULL, 'OutgoingPaymentFCY', @path, '393', '39300800', NULL, 1, 60, '', NULL, NULL,
            @stateId, @stateDate, @stateMaker);

    select @lastAccAccountMapId = @lastAccAccountMapId + 1
    END;

    IF NOT EXISTS(SELECT 1
              FROM dbo.AccAccountMap
              WHERE Ccy IS NULL
                AND CustomerId IS NULL
                AND RuleId IS NULL
                AND Rule2Id = @dynamicRuleIsFinancialInstitutionId
                AND Rule3Id IS NULL
                AND Rule4Id = @dynamicRuleOutgoingPaymentInstructionTypeEqualV2VId
                AND Rule5Id = @dynamicRuleOutgoingSettlementTypeEqualGrossId
                AND Rule6Id = 10006
                AND Rule7Id IS NULL
                AND Rule8Id IS NULL
                AND Rule9Id IS NULL
                AND Rule10Id IS NULL
                AND Source = N'OutgoingPaymentFCY'
                AND Path = @path
                AND TargetMainGL = ''
                AND Target = ''
                AND TargetRuleId = 10022
                AND CustomerCodeSourceRuleId = 10023
                AND CustomerAccountCodeSourceRuleId = 10024)
    BEGIN
    INSERT INTO dbo.AccAccountMap (Id, Ccy, CustomerId, RuleId, Rule2Id, Rule3Id, Rule4Id, Rule5Id, Rule6Id, Rule7Id,
                                   Rule8Id, Rule9Id, Rule10Id, [Source], [Path], TargetMainGL, Target, TargetRuleId,
                                   IsEnabled, [Order], Description, CustomerCodeSourceRuleId,
                                   CustomerAccountCodeSourceRuleId, StateId, StateDate, StateMaker)
    VALUES (@lastAccAccountMapId, NULL, NULL, NULL, @dynamicRuleIsFinancialInstitutionId, NULL,
            @dynamicRuleOutgoingPaymentInstructionTypeEqualV2VId, @dynamicRuleOutgoingSettlementTypeEqualGrossId, 10006,
            NULL, NULL, NULL, NULL, 'OutgoingPaymentFCY', @path, '', '', 10022, 1, 65, '', 10023, 10024, @stateId,
            @stateDate, @stateMaker);

    select @lastAccAccountMapId = @lastAccAccountMapId + 1
    END;

    IF NOT EXISTS(SELECT 1
              FROM dbo.AccAccountMap
              WHERE Ccy IS NULL
                AND CustomerId IS NULL
                AND RuleId IS NULL
                AND Rule2Id = @dynamicRuleIsFinancialInstitutionId
                AND Rule3Id IS NULL
                AND Rule4Id = @dynamicRuleOutgoingPaymentInstructionTypeEqualV2VId
                AND Rule5Id = @dynamicRuleOutgoingSettlementTypeEqualNettingId
                AND Rule6Id IS NULL
                AND Rule7Id = 10009
                AND Rule8Id IS NULL
                AND Rule9Id IS NULL
                AND Rule10Id IS NULL
                AND Source = N'OutgoingPaymentFCY'
                AND Path = @path
                AND TargetMainGL = '393'
                AND Target = '39300800'
                AND TargetRuleId IS NULL
                AND CustomerCodeSourceRuleId = 10023
                AND CustomerAccountCodeSourceRuleId = 10024)
    BEGIN
    INSERT INTO dbo.AccAccountMap (Id, Ccy, CustomerId, RuleId, Rule2Id, Rule3Id, Rule4Id, Rule5Id, Rule6Id, Rule7Id,
                                   Rule8Id, Rule9Id, Rule10Id, [Source], [Path], TargetMainGL, Target, TargetRuleId,
                                   IsEnabled, [Order], Description, CustomerCodeSourceRuleId,
                                   CustomerAccountCodeSourceRuleId, StateId, StateDate, StateMaker)
    VALUES (@lastAccAccountMapId, NULL, NULL, NULL, @dynamicRuleIsFinancialInstitutionId, NULL,
            @dynamicRuleOutgoingPaymentInstructionTypeEqualV2VId, @dynamicRuleOutgoingSettlementTypeEqualNettingId,
            NULL, 10009, NULL, NULL, NULL, 'OutgoingPaymentFCY', @path, '393', '39300800', NULL, 1, 70, '', 10023,
            10024, @stateId, @stateDate, @stateMaker);

    select @lastAccAccountMapId = @lastAccAccountMapId + 1
    END;

    IF NOT EXISTS(SELECT 1
              FROM dbo.AccAccountMap
              WHERE Ccy IS NULL
                AND CustomerId IS NULL
                AND RuleId IS NULL
                AND Rule2Id = @dynamicRuleIsFinancialInstitutionId
                AND Rule3Id IS NULL
                AND Rule4Id = @dynamicRuleOutgoingPaymentInstructionTypeEqualV2VId
                AND Rule5Id = @dynamicRuleOutgoingSettlementTypeEqualNettingId
                AND Rule6Id IS NULL
                AND Rule7Id = 10010
                AND Rule8Id IS NULL
                AND Rule9Id IS NULL
                AND Rule10Id IS NULL
                AND Source = N'OutgoingPaymentFCY'
                AND Path = @path
                AND TargetMainGL = '393'
                AND Target = '39300800'
                AND TargetRuleId IS NULL
                AND CustomerCodeSourceRuleId IS NULL
                AND CustomerAccountCodeSourceRuleId IS NULL)
    BEGIN
    INSERT INTO dbo.AccAccountMap (Id, Ccy, CustomerId, RuleId, Rule2Id, Rule3Id, Rule4Id, Rule5Id, Rule6Id, Rule7Id,
                                   Rule8Id, Rule9Id, Rule10Id, [Source], [Path], TargetMainGL, Target, TargetRuleId,
                                   IsEnabled, [Order], Description, CustomerCodeSourceRuleId,
                                   CustomerAccountCodeSourceRuleId, StateId, StateDate, StateMaker)
    VALUES (@lastAccAccountMapId, NULL, NULL, NULL, @dynamicRuleIsFinancialInstitutionId, NULL,
            @dynamicRuleOutgoingPaymentInstructionTypeEqualV2VId, @dynamicRuleOutgoingSettlementTypeEqualNettingId,
            NULL, 10010, NULL, NULL, NULL, 'OutgoingPaymentFCY', @path, '393', '39300800', NULL, 1, 75, '', NULL, NULL,
            @stateId, @stateDate, @stateMaker);

    select @lastAccAccountMapId = @lastAccAccountMapId + 1
    END;

    ------------------------------------------------------------------------------------------------------------------------
    -- IncomingPaymentLCY
    ------------------------------------------------------------------------------------------------------------------------
    IF NOT EXISTS (SELECT 1
               FROM dbo.AccAccountMap
               WHERE Ccy IS NULL
                 AND CustomerId IS NULL
                 AND RuleId IS NULL
                 AND Rule2Id = @dynamicRuleIsFinancialInstitutionId
                 AND Rule3Id IS NULL
                 AND Rule4Id IS NULL
                 AND Rule5Id IS NULL
                 AND Rule6Id IS NULL
                 AND Rule7Id IS NULL
                 AND Rule8Id IS NULL
                 AND Rule9Id IS NULL
                 AND Rule10Id IS NULL
                 AND Source = N'IncomingPaymentLCY'
                 AND Path = @path
                 AND TargetMainGL = '280'
                 AND Target = '39200800'
                 AND TargetRuleId IS NULL
                 AND CustomerCodeSourceRuleId IS NULL
                 AND CustomerAccountCodeSourceRuleId IS NULL)
    BEGIN
    INSERT INTO dbo.AccAccountMap (Id, Ccy, CustomerId, RuleId, Rule2Id, Rule3Id, Rule4Id, Rule5Id, Rule6Id, Rule7Id,
                                   Rule8Id, Rule9Id, Rule10Id, [Source], [Path], TargetMainGL, Target, TargetRuleId,
                                   IsEnabled, [Order], Description, CustomerCodeSourceRuleId,
                                   CustomerAccountCodeSourceRuleId, StateId, StateDate, StateMaker)
    VALUES (@lastAccAccountMapId, NULL, NULL, NULL, @dynamicRuleIsFinancialInstitutionId, NULL, NULL, NULL, NULL, NULL,
            NULL, NULL, NULL, 'IncomingPaymentLCY', @path, '280', '39200800', NULL, 0, 1, 'Payment ', NULL, NULL,
            @stateId, @stateDate, @stateMaker);

    select @lastAccAccountMapId = @lastAccAccountMapId + 1
    END;

    IF NOT EXISTS (SELECT 1
               FROM dbo.AccAccountMap
               WHERE Ccy IS NULL
                 AND CustomerId IS NULL
                 AND RuleId IS NULL
                 AND Rule2Id = @dynamicRuleIsFinancialInstitutionId
                 AND Rule3Id IS NULL
                 AND Rule4Id = @dynamicRuleIncomingPaymentInstructionTypeEqualB2BId
                 AND Rule5Id = @dynamicRuleIncomingSettlementTypeEqualGrossId
                 AND Rule6Id = 10007
                 AND Rule7Id = 10011
                 AND Rule8Id IS NULL
                 AND Rule9Id IS NULL
                 AND Rule10Id IS NULL
                 AND Source = N'IncomingPaymentLCY'
                 AND Path = @path
                 AND TargetMainGL = '392'
                 AND Target = '39200800'
                 AND TargetRuleId IS NULL
                 AND CustomerCodeSourceRuleId = 10017
                 AND CustomerAccountCodeSourceRuleId = 10018)
    BEGIN
    INSERT INTO dbo.AccAccountMap (Id, Ccy, CustomerId, RuleId, Rule2Id, Rule3Id, Rule4Id, Rule5Id, Rule6Id, Rule7Id,
                                   Rule8Id, Rule9Id, Rule10Id, [Source], [Path], TargetMainGL, Target, TargetRuleId,
                                   IsEnabled, [Order], Description, CustomerCodeSourceRuleId,
                                   CustomerAccountCodeSourceRuleId, StateId, StateDate, StateMaker)
    VALUES (@lastAccAccountMapId, NULL, NULL, NULL, @dynamicRuleIsFinancialInstitutionId, NULL,
            @dynamicRuleIncomingPaymentInstructionTypeEqualB2BId, @dynamicRuleIncomingSettlementTypeEqualGrossId, 10007,
            10011, NULL, NULL, NULL, 'IncomingPaymentLCY', @path, '392', '39200800', NULL, 1, 5, 'Payment ', 10017,
            10018, @stateId, @stateDate, @stateMaker);

    select @lastAccAccountMapId = @lastAccAccountMapId + 1
    END;

    IF NOT EXISTS (SELECT 1
               FROM dbo.AccAccountMap
               WHERE Ccy IS NULL
                 AND CustomerId IS NULL
                 AND RuleId IS NULL
                 AND Rule2Id = @dynamicRuleIsFinancialInstitutionId
                 AND Rule3Id IS NULL
                 AND Rule4Id = @dynamicRuleIncomingPaymentInstructionTypeEqualB2BId
                 AND Rule5Id = @dynamicRuleIncomingSettlementTypeEqualGrossId
                 AND Rule6Id = 10007
                 AND Rule7Id = 10012
                 AND Rule8Id IS NULL
                 AND Rule9Id IS NULL
                 AND Rule10Id IS NULL
                 AND Source = N'IncomingPaymentLCY'
                 AND Path = @path
                 AND TargetMainGL = '392'
                 AND Target = '39200800'
                 AND TargetRuleId IS NULL
                 AND CustomerCodeSourceRuleId IS NULL
                 AND CustomerAccountCodeSourceRuleId IS NULL)
    BEGIN
    INSERT INTO dbo.AccAccountMap (Id, Ccy, CustomerId, RuleId, Rule2Id, Rule3Id, Rule4Id, Rule5Id, Rule6Id, Rule7Id,
                                   Rule8Id, Rule9Id, Rule10Id, [Source], [Path], TargetMainGL, Target, TargetRuleId,
                                   IsEnabled, [Order], Description, CustomerCodeSourceRuleId,
                                   CustomerAccountCodeSourceRuleId, StateId, StateDate, StateMaker)
    VALUES (@lastAccAccountMapId, NULL, NULL, NULL, @dynamicRuleIsFinancialInstitutionId, NULL,
            @dynamicRuleIncomingPaymentInstructionTypeEqualB2BId, @dynamicRuleIncomingSettlementTypeEqualGrossId, 10007,
            10012, NULL, NULL, NULL, 'IncomingPaymentLCY', @path, '392', '39200800', NULL, 1, 10, '', NULL, NULL,
            @stateId, @stateDate, @stateMaker);

    select @lastAccAccountMapId = @lastAccAccountMapId + 1
    END;

    IF NOT EXISTS (SELECT 1
               FROM dbo.AccAccountMap
               WHERE Ccy IS NULL
                 AND CustomerId IS NULL
                 AND RuleId IS NULL
                 AND Rule2Id = @dynamicRuleIsFinancialInstitutionId
                 AND Rule3Id IS NULL
                 AND Rule4Id = @dynamicRuleIncomingPaymentInstructionTypeEqualB2BId
                 AND Rule5Id = @dynamicRuleIncomingSettlementTypeEqualGrossId
                 AND Rule6Id = 10008
                 AND Rule7Id IS NULL
                 AND Rule8Id IS NULL
                 AND Rule9Id IS NULL
                 AND Rule10Id IS NULL
                 AND Source = N'IncomingPaymentLCY'
                 AND Path = @path
                 AND TargetMainGL = ''
                 AND Target = ''
                 AND TargetRuleId = 10016
                 AND CustomerCodeSourceRuleId = 10017
                 AND CustomerAccountCodeSourceRuleId = 10018)
    BEGIN
    INSERT INTO dbo.AccAccountMap (Id, Ccy, CustomerId, RuleId, Rule2Id, Rule3Id, Rule4Id, Rule5Id, Rule6Id, Rule7Id,
                                   Rule8Id, Rule9Id, Rule10Id, [Source], [Path], TargetMainGL, Target, TargetRuleId,
                                   IsEnabled, [Order], Description, CustomerCodeSourceRuleId,
                                   CustomerAccountCodeSourceRuleId, StateId, StateDate, StateMaker)
    VALUES (@lastAccAccountMapId, NULL, NULL, NULL, @dynamicRuleIsFinancialInstitutionId, NULL,
            @dynamicRuleIncomingPaymentInstructionTypeEqualB2BId, @dynamicRuleIncomingSettlementTypeEqualGrossId, 10008,
            NULL, NULL, NULL, NULL, 'IncomingPaymentLCY', @path, '', '', 10016, 1, 15, '', 10017, 10018, @stateId,
            @stateDate, @stateMaker);

    select @lastAccAccountMapId = @lastAccAccountMapId + 1
    END;

    IF NOT EXISTS (SELECT 1
               FROM dbo.AccAccountMap
               WHERE Ccy IS NULL
                 AND CustomerId IS NULL
                 AND RuleId IS NULL
                 AND Rule2Id = @dynamicRuleIsFinancialInstitutionId
                 AND Rule3Id IS NULL
                 AND Rule4Id = @dynamicRuleIncomingPaymentInstructionTypeEqualB2BId
                 AND Rule5Id = @dynamicRuleIncomingSettlementTypeEqualNettingId
                 AND Rule6Id = 10011
                 AND Rule7Id IS NULL
                 AND Rule8Id IS NULL
                 AND Rule9Id IS NULL
                 AND Rule10Id IS NULL
                 AND Source = N'IncomingPaymentLCY'
                 AND Path = @path
                 AND TargetMainGL = '392'
                 AND Target = '39200800'
                 AND TargetRuleId IS NULL
                 AND CustomerCodeSourceRuleId = 10017
                 AND CustomerAccountCodeSourceRuleId = 10018)
    BEGIN
    INSERT INTO dbo.AccAccountMap (Id, Ccy, CustomerId, RuleId, Rule2Id, Rule3Id, Rule4Id, Rule5Id, Rule6Id, Rule7Id,
                                   Rule8Id, Rule9Id, Rule10Id, [Source], [Path], TargetMainGL, Target, TargetRuleId,
                                   IsEnabled, [Order], Description, CustomerCodeSourceRuleId,
                                   CustomerAccountCodeSourceRuleId, StateId, StateDate, StateMaker)
    VALUES (@lastAccAccountMapId, NULL, NULL, NULL, @dynamicRuleIsFinancialInstitutionId, NULL,
            @dynamicRuleIncomingPaymentInstructionTypeEqualB2BId, @dynamicRuleIncomingSettlementTypeEqualNettingId,
            NULL, 10011, NULL, NULL, NULL, 'IncomingPaymentLCY', @path, '392', '39200800', NULL, 1, 20, '', 10017,
            10018, @stateId, @stateDate, @stateMaker);

    select @lastAccAccountMapId = @lastAccAccountMapId + 1
    END;

    IF NOT EXISTS (SELECT 1
               FROM dbo.AccAccountMap
               WHERE Ccy IS NULL
                 AND CustomerId IS NULL
                 AND RuleId IS NULL
                 AND Rule2Id = @dynamicRuleIsFinancialInstitutionId
                 AND Rule3Id IS NULL
                 AND Rule4Id = @dynamicRuleIncomingPaymentInstructionTypeEqualB2BId
                 AND Rule5Id = @dynamicRuleIncomingSettlementTypeEqualNettingId
                 AND Rule6Id = 10012
                 AND Rule7Id IS NULL
                 AND Rule8Id IS NULL
                 AND Rule9Id IS NULL
                 AND Rule10Id IS NULL
                 AND Source = N'IncomingPaymentLCY'
                 AND Path = @path
                 AND TargetMainGL = '392'
                 AND Target = '39200800'
                 AND TargetRuleId IS NULL
                 AND CustomerCodeSourceRuleId IS NULL
                 AND CustomerAccountCodeSourceRuleId IS NULL)
    BEGIN
    INSERT INTO dbo.AccAccountMap (Id, Ccy, CustomerId, RuleId, Rule2Id, Rule3Id, Rule4Id, Rule5Id, Rule6Id, Rule7Id,
                                   Rule8Id, Rule9Id, Rule10Id, [Source], [Path], TargetMainGL, Target, TargetRuleId,
                                   IsEnabled, [Order], Description, CustomerCodeSourceRuleId,
                                   CustomerAccountCodeSourceRuleId, StateId, StateDate, StateMaker)
    VALUES (@lastAccAccountMapId, NULL, NULL, NULL, @dynamicRuleIsFinancialInstitutionId, NULL,
            @dynamicRuleIncomingPaymentInstructionTypeEqualB2BId, @dynamicRuleIncomingSettlementTypeEqualNettingId,
            NULL, 10012, NULL, NULL, NULL, 'IncomingPaymentLCY', @path, '392', '39200800', NULL, 1, 25, '', NULL, NULL,
            @stateId, @stateDate, @stateMaker);

    select @lastAccAccountMapId = @lastAccAccountMapId + 1
    END;

    IF NOT EXISTS (
        SELECT 1
        FROM dbo.AccAccountMap
        WHERE Ccy IS NULL
          AND CustomerId IS NULL
          AND RuleId IS NULL
          AND Rule2Id = @dynamicRuleIsFinancialInstitutionId
          AND Rule3Id IS NULL
          AND Rule4Id = @dynamicRuleIncomingPaymentInstructionTypeEqualA2AId
          AND Rule5Id = @dynamicRuleIncomingSettlementTypeEqualGrossId
          AND Rule6Id = 10007
          AND Rule7Id = 10011
          AND Rule8Id IS NULL
          AND Rule9Id IS NULL
          AND Rule10Id IS NULL
          AND Source = N'IncomingPaymentLCY'
          AND Path = @path
          AND TargetMainGL = N'392'
          AND Target = N'39200800'
          AND TargetRuleId IS NULL
          AND CustomerCodeSourceRuleId = 10017
          AND CustomerAccountCodeSourceRuleId = 10018
    )
    BEGIN
    INSERT INTO dbo.AccAccountMap (Id, Ccy, CustomerId, RuleId, Rule2Id, Rule3Id, Rule4Id, Rule5Id, Rule6Id, Rule7Id,
                                   Rule8Id, Rule9Id, Rule10Id, [Source], [Path], TargetMainGL, Target, TargetRuleId,
                                   IsEnabled, [Order], Description, CustomerCodeSourceRuleId,
                                   CustomerAccountCodeSourceRuleId, StateId, StateDate, StateMaker)
    VALUES (@lastAccAccountMapId, NULL, NULL, NULL, @dynamicRuleIsFinancialInstitutionId, NULL,
            @dynamicRuleIncomingPaymentInstructionTypeEqualA2AId, @dynamicRuleIncomingSettlementTypeEqualGrossId, 10007,
            10011, NULL, NULL, NULL, 'IncomingPaymentLCY', @path, '392', '39200800', NULL, 1, 30, '', 10017, 10018,
            @stateId, @stateDate, @stateMaker);

    select @lastAccAccountMapId = @lastAccAccountMapId + 1
    END;

    IF NOT EXISTS (
        SELECT 1
        FROM dbo.AccAccountMap
        WHERE Ccy IS NULL
          AND CustomerId IS NULL
          AND RuleId IS NULL
          AND Rule2Id = @dynamicRuleIsFinancialInstitutionId
          AND Rule3Id IS NULL
          AND Rule4Id = @dynamicRuleIncomingPaymentInstructionTypeEqualA2AId
          AND Rule5Id = @dynamicRuleIncomingSettlementTypeEqualGrossId
          AND Rule6Id = 10007
          AND Rule7Id = 10012
          AND Rule8Id IS NULL
          AND Rule9Id IS NULL
          AND Rule10Id IS NULL
          AND Source = N'IncomingPaymentLCY'
          AND Path = @path
          AND TargetMainGL = N'392'
          AND Target = N'39200800'
          AND TargetRuleId IS NULL
          AND CustomerCodeSourceRuleId IS NULL
          AND CustomerAccountCodeSourceRuleId IS NULL)
    BEGIN
    INSERT INTO dbo.AccAccountMap (Id, Ccy, CustomerId, RuleId, Rule2Id, Rule3Id, Rule4Id, Rule5Id, Rule6Id, Rule7Id,
                                   Rule8Id, Rule9Id, Rule10Id, [Source], [Path], TargetMainGL, Target, TargetRuleId,
                                   IsEnabled, [Order], Description, CustomerCodeSourceRuleId,
                                   CustomerAccountCodeSourceRuleId, StateId, StateDate, StateMaker)
    VALUES (@lastAccAccountMapId, NULL, NULL, NULL, @dynamicRuleIsFinancialInstitutionId, NULL,
            @dynamicRuleIncomingPaymentInstructionTypeEqualA2AId, @dynamicRuleIncomingSettlementTypeEqualGrossId, 10007,
            10012, NULL, NULL, NULL, 'IncomingPaymentLCY', @path, '392', '39200800', NULL, 1, 35, '', NULL, NULL,
            @stateId, @stateDate, @stateMaker);

    select @lastAccAccountMapId = @lastAccAccountMapId + 1
    END;

    IF NOT EXISTS (
        SELECT 1
        FROM dbo.AccAccountMap
        WHERE Ccy IS NULL
          AND CustomerId IS NULL
          AND RuleId IS NULL
          AND Rule2Id = @dynamicRuleIsFinancialInstitutionId
          AND Rule3Id IS NULL
          AND Rule4Id = @dynamicRuleIncomingPaymentInstructionTypeEqualA2AId
          AND Rule5Id = @dynamicRuleIncomingSettlementTypeEqualGrossId
          AND Rule6Id = 10008
          AND Rule7Id IS NULL
          AND Rule8Id IS NULL
          AND Rule9Id IS NULL
          AND Rule10Id IS NULL
          AND Source = N'IncomingPaymentLCY'
          AND Path = @path
          AND TargetMainGL = ''
          AND Target = ''
          AND TargetRuleId = 10016
          AND CustomerCodeSourceRuleId = 10017
          AND CustomerAccountCodeSourceRuleId = 10018
    )
    BEGIN
    INSERT INTO dbo.AccAccountMap (Id, Ccy, CustomerId, RuleId, Rule2Id, Rule3Id, Rule4Id, Rule5Id, Rule6Id, Rule7Id,
                                   Rule8Id, Rule9Id, Rule10Id, [Source], [Path], TargetMainGL, Target, TargetRuleId,
                                   IsEnabled, [Order], Description, CustomerCodeSourceRuleId,
                                   CustomerAccountCodeSourceRuleId, StateId, StateDate, StateMaker)
    VALUES (@lastAccAccountMapId, NULL, NULL, NULL, @dynamicRuleIsFinancialInstitutionId, NULL,
            @dynamicRuleIncomingPaymentInstructionTypeEqualA2AId, @dynamicRuleIncomingSettlementTypeEqualGrossId, 10008,
            NULL, NULL, NULL, NULL, 'IncomingPaymentLCY', @path, '', '', 10016, 1, 40, '', 10017, 10018, @stateId,
            @stateDate, @stateMaker);

    select @lastAccAccountMapId = @lastAccAccountMapId + 1
    END;

    IF NOT EXISTS (
        SELECT 1
        FROM dbo.AccAccountMap
        WHERE Ccy IS NULL
          AND CustomerId IS NULL
          AND RuleId IS NULL
          AND Rule2Id = @dynamicRuleIsFinancialInstitutionId
          AND Rule3Id IS NULL
          AND Rule4Id = @dynamicRuleIncomingPaymentInstructionTypeEqualA2AId
          AND Rule5Id = @dynamicRuleIncomingSettlementTypeEqualNettingId
          AND Rule6Id IS NULL
          AND Rule7Id = 10011
          AND Rule8Id IS NULL
          AND Rule9Id IS NULL
          AND Rule10Id IS NULL
          AND Source = N'IncomingPaymentLCY'
          AND Path = @path
          AND TargetMainGL = '392'
          AND Target = '39200800'
          AND TargetRuleId IS NULL
          AND CustomerCodeSourceRuleId = 10017
          AND CustomerAccountCodeSourceRuleId = 10018
    )
    BEGIN
    INSERT INTO dbo.AccAccountMap (Id, Ccy, CustomerId, RuleId, Rule2Id, Rule3Id, Rule4Id, Rule5Id, Rule6Id, Rule7Id,
                                   Rule8Id, Rule9Id, Rule10Id, [Source], [Path], TargetMainGL, Target, TargetRuleId,
                                   IsEnabled, [Order], Description, CustomerCodeSourceRuleId,
                                   CustomerAccountCodeSourceRuleId, StateId, StateDate, StateMaker)
    VALUES (@lastAccAccountMapId, NULL, NULL, NULL, @dynamicRuleIsFinancialInstitutionId, NULL,
            @dynamicRuleIncomingPaymentInstructionTypeEqualA2AId, @dynamicRuleIncomingSettlementTypeEqualNettingId,
            NULL, 10011, NULL, NULL, NULL, 'IncomingPaymentLCY', @path, '392', '39200800', NULL, 1, 45, '', 10017,
            10018, @stateId, @stateDate, @stateMaker);

    select @lastAccAccountMapId = @lastAccAccountMapId + 1
    END;

    IF NOT EXISTS (
        SELECT 1
        FROM dbo.AccAccountMap
        WHERE Ccy IS NULL
          AND CustomerId IS NULL
          AND RuleId IS NULL
          AND Rule2Id = @dynamicRuleIsFinancialInstitutionId
          AND Rule3Id IS NULL
          AND Rule4Id = @dynamicRuleIncomingPaymentInstructionTypeEqualA2AId
          AND Rule5Id = @dynamicRuleIncomingSettlementTypeEqualNettingId
          AND Rule6Id IS NULL
          AND Rule7Id = 10012
          AND Rule8Id IS NULL
          AND Rule9Id IS NULL
          AND Rule10Id IS NULL
          AND Source = N'IncomingPaymentLCY'
          AND Path = @path
          AND TargetMainGL = '392'
          AND Target = '39200800'
          AND TargetRuleId IS NULL
          AND CustomerCodeSourceRuleId IS NULL
          AND CustomerAccountCodeSourceRuleId IS NULL
    )
    BEGIN
    INSERT INTO dbo.AccAccountMap (Id, Ccy, CustomerId, RuleId, Rule2Id, Rule3Id, Rule4Id, Rule5Id, Rule6Id, Rule7Id,
                                   Rule8Id, Rule9Id, Rule10Id, [Source], [Path], TargetMainGL, Target, TargetRuleId,
                                   IsEnabled, [Order], Description, CustomerCodeSourceRuleId,
                                   CustomerAccountCodeSourceRuleId, StateId, StateDate, StateMaker)
    VALUES (@lastAccAccountMapId, NULL, NULL, NULL, @dynamicRuleIsFinancialInstitutionId, NULL,
            @dynamicRuleIncomingPaymentInstructionTypeEqualA2AId, @dynamicRuleIncomingSettlementTypeEqualNettingId,
            NULL, 10012, NULL, NULL, NULL, 'IncomingPaymentLCY', @path, '392', '39200800', NULL, 1, 50, '', NULL, NULL,
            @stateId, @stateDate, @stateMaker);

    select @lastAccAccountMapId = @lastAccAccountMapId + 1
    END;

    IF NOT EXISTS (
        SELECT 1
        FROM dbo.AccAccountMap
        WHERE Ccy IS NULL
          AND CustomerId IS NULL
          AND RuleId IS NULL
          AND Rule2Id = @dynamicRuleIsFinancialInstitutionId
          AND Rule3Id IS NULL
          AND Rule4Id = @dynamicRuleIncomingPaymentInstructionTypeEqualV2VId
          AND Rule5Id = @dynamicRuleIncomingSettlementTypeEqualGrossId
          AND Rule6Id = 10007
          AND Rule7Id = 10011
          AND Rule8Id IS NULL
          AND Rule9Id IS NULL
          AND Rule10Id IS NULL
          AND Source = N'IncomingPaymentLCY'
          AND Path = @path
          AND TargetMainGL = '392'
          AND Target = '39200800'
          AND TargetRuleId IS NULL
          AND CustomerCodeSourceRuleId = 10020
          AND CustomerAccountCodeSourceRuleId = 10021
    )
    BEGIN
    INSERT INTO dbo.AccAccountMap (Id, Ccy, CustomerId, RuleId, Rule2Id, Rule3Id, Rule4Id, Rule5Id, Rule6Id, Rule7Id,
                                   Rule8Id, Rule9Id, Rule10Id, [Source], [Path], TargetMainGL, Target, TargetRuleId,
                                   IsEnabled, [Order], Description, CustomerCodeSourceRuleId,
                                   CustomerAccountCodeSourceRuleId, StateId, StateDate, StateMaker)
    VALUES (@lastAccAccountMapId, NULL, NULL, NULL, @dynamicRuleIsFinancialInstitutionId, NULL,
            @dynamicRuleIncomingPaymentInstructionTypeEqualV2VId, @dynamicRuleIncomingSettlementTypeEqualGrossId, 10007,
            10011, NULL, NULL, NULL, 'IncomingPaymentLCY', @path, '392', '39200800', NULL, 1, 55, '', 10020, 10021,
            @stateId, @stateDate, @stateMaker);

    select @lastAccAccountMapId = @lastAccAccountMapId + 1
    END;

    IF NOT EXISTS (
        SELECT 1
        FROM dbo.AccAccountMap
        WHERE Ccy IS NULL
          AND CustomerId IS NULL
          AND RuleId IS NULL
          AND Rule2Id = @dynamicRuleIsFinancialInstitutionId
          AND Rule3Id IS NULL
          AND Rule4Id = @dynamicRuleIncomingPaymentInstructionTypeEqualV2VId
          AND Rule5Id = @dynamicRuleIncomingSettlementTypeEqualGrossId
          AND Rule6Id = 10007
          AND Rule7Id = 10012
          AND Rule8Id IS NULL
          AND Rule9Id IS NULL
          AND Rule10Id IS NULL
          AND Source = N'IncomingPaymentLCY'
          AND Path = @path
          AND TargetMainGL = '392'
          AND Target = '39200800'
          AND TargetRuleId IS NULL
          AND CustomerCodeSourceRuleId IS NULL
          AND CustomerAccountCodeSourceRuleId IS NULL
    )
    BEGIN
    INSERT INTO dbo.AccAccountMap (Id, Ccy, CustomerId, RuleId, Rule2Id, Rule3Id, Rule4Id, Rule5Id, Rule6Id, Rule7Id,
                                   Rule8Id, Rule9Id, Rule10Id, [Source], [Path], TargetMainGL, Target, TargetRuleId,
                                   IsEnabled, [Order], Description, CustomerCodeSourceRuleId,
                                   CustomerAccountCodeSourceRuleId, StateId, StateDate, StateMaker)
    VALUES (@lastAccAccountMapId, NULL, NULL, NULL, @dynamicRuleIsFinancialInstitutionId, NULL,
            @dynamicRuleIncomingPaymentInstructionTypeEqualV2VId, @dynamicRuleIncomingSettlementTypeEqualGrossId, 10007,
            10012, NULL, NULL, NULL, 'IncomingPaymentLCY', @path, '392', '39200800', NULL, 1, 60, '', NULL, NULL,
            @stateId, @stateDate, @stateMaker);

    select @lastAccAccountMapId = @lastAccAccountMapId + 1
    END;

    IF NOT EXISTS (
        SELECT 1
        FROM dbo.AccAccountMap
        WHERE Ccy IS NULL
          AND CustomerId IS NULL
          AND RuleId IS NULL
          AND Rule2Id = @dynamicRuleIsFinancialInstitutionId
          AND Rule3Id IS NULL
          AND Rule4Id = @dynamicRuleIncomingPaymentInstructionTypeEqualV2VId
          AND Rule5Id = @dynamicRuleIncomingSettlementTypeEqualGrossId
          AND Rule6Id = 10008
          AND Rule7Id IS NULL
          AND Rule8Id IS NULL
          AND Rule9Id IS NULL
          AND Rule10Id IS NULL
          AND Source = N'IncomingPaymentLCY'
          AND Path = @path
          AND TargetMainGL = ''
          AND Target = ''
          AND TargetRuleId = 10019
          AND CustomerCodeSourceRuleId = 10020
          AND CustomerAccountCodeSourceRuleId = 10021
    )
    BEGIN
    INSERT INTO dbo.AccAccountMap (Id, Ccy, CustomerId, RuleId, Rule2Id, Rule3Id, Rule4Id, Rule5Id, Rule6Id, Rule7Id,
                                   Rule8Id, Rule9Id, Rule10Id, [Source], [Path], TargetMainGL, Target, TargetRuleId,
                                   IsEnabled, [Order], Description, CustomerCodeSourceRuleId,
                                   CustomerAccountCodeSourceRuleId, StateId, StateDate, StateMaker)
    VALUES (@lastAccAccountMapId, NULL, NULL, NULL, @dynamicRuleIsFinancialInstitutionId, NULL,
            @dynamicRuleIncomingPaymentInstructionTypeEqualV2VId, @dynamicRuleIncomingSettlementTypeEqualGrossId, 10008,
            NULL, NULL, NULL, NULL, 'IncomingPaymentLCY', @path, '', '', 10019, 1, 65, '', 10020, 10021, @stateId,
            @stateDate, @stateMaker);

    select @lastAccAccountMapId = @lastAccAccountMapId + 1
    END;

    IF NOT EXISTS (
        SELECT 1
        FROM dbo.AccAccountMap
        WHERE Ccy IS NULL
          AND CustomerId IS NULL
          AND RuleId IS NULL
          AND Rule2Id = @dynamicRuleIsFinancialInstitutionId
          AND Rule3Id IS NULL
          AND Rule4Id = @dynamicRuleIncomingPaymentInstructionTypeEqualV2VId
          AND Rule5Id = @dynamicRuleIncomingSettlementTypeEqualNettingId
          AND Rule6Id IS NULL
          AND Rule7Id = 10011
          AND Rule8Id IS NULL
          AND Rule9Id IS NULL
          AND Rule10Id IS NULL
          AND Source = N'IncomingPaymentLCY'
          AND Path = @path
          AND TargetMainGL = '392'
          AND Target = '39200800'
          AND TargetRuleId IS NULL
          AND CustomerCodeSourceRuleId = 10020
          AND CustomerAccountCodeSourceRuleId = 10021
    )
    BEGIN
    INSERT INTO dbo.AccAccountMap (Id, Ccy, CustomerId, RuleId, Rule2Id, Rule3Id, Rule4Id, Rule5Id, Rule6Id, Rule7Id,
                                   Rule8Id, Rule9Id, Rule10Id, [Source], [Path], TargetMainGL, Target, TargetRuleId,
                                   IsEnabled, [Order], Description, CustomerCodeSourceRuleId,
                                   CustomerAccountCodeSourceRuleId, StateId, StateDate, StateMaker)
    VALUES (@lastAccAccountMapId, NULL, NULL, NULL, @dynamicRuleIsFinancialInstitutionId, NULL,
            @dynamicRuleIncomingPaymentInstructionTypeEqualV2VId, @dynamicRuleIncomingSettlementTypeEqualNettingId,
            NULL, 10011, NULL, NULL, NULL, 'IncomingPaymentLCY', @path, '392', '39200800', NULL, 1, 70, '', 10020,
            10021, @stateId, @stateDate, @stateMaker);

    select @lastAccAccountMapId = @lastAccAccountMapId + 1
    END;

    IF NOT EXISTS (
        SELECT 1
        FROM dbo.AccAccountMap
        WHERE Ccy IS NULL
          AND CustomerId IS NULL
          AND RuleId IS NULL
          AND Rule2Id = @dynamicRuleIsFinancialInstitutionId
          AND Rule3Id IS NULL
          AND Rule4Id = @dynamicRuleIncomingPaymentInstructionTypeEqualV2VId
          AND Rule5Id = @dynamicRuleIncomingSettlementTypeEqualNettingId
          AND Rule6Id IS NULL
          AND Rule7Id = 10012
          AND Rule8Id IS NULL
          AND Rule9Id IS NULL
          AND Rule10Id IS NULL
          AND Source = N'IncomingPaymentLCY'
          AND Path = @path
          AND TargetMainGL = '392'
          AND Target = '39200800'
          AND TargetRuleId IS NULL
          AND CustomerCodeSourceRuleId IS NULL
          AND CustomerAccountCodeSourceRuleId IS NULL
    )
    BEGIN
    INSERT INTO dbo.AccAccountMap (Id, Ccy, CustomerId, RuleId, Rule2Id, Rule3Id, Rule4Id, Rule5Id, Rule6Id, Rule7Id,
                                   Rule8Id, Rule9Id, Rule10Id, [Source], [Path], TargetMainGL, Target, TargetRuleId,
                                   IsEnabled, [Order], Description, CustomerCodeSourceRuleId,
                                   CustomerAccountCodeSourceRuleId, StateId, StateDate, StateMaker)
    VALUES (@lastAccAccountMapId, NULL, NULL, NULL, @dynamicRuleIsFinancialInstitutionId, NULL,
            @dynamicRuleIncomingPaymentInstructionTypeEqualV2VId, @dynamicRuleIncomingSettlementTypeEqualNettingId,
            NULL, 10012, NULL, NULL, NULL, 'IncomingPaymentLCY', @path, '392', '39200800', NULL, 1, 75, '', NULL, NULL,
            @stateId, @stateDate, @stateMaker);

    select @lastAccAccountMapId = @lastAccAccountMapId + 1
    END;

    ------------------------------------------------------------------------------------------------------------------------
    -- IncomingPaymentFCY
    ------------------------------------------------------------------------------------------------------------------------
    IF NOT EXISTS (SELECT 1
        FROM dbo.AccAccountMap
        WHERE Ccy IS NULL
          AND CustomerId IS NULL
          AND RuleId IS NULL
          AND Rule2Id = @dynamicRuleIsFinancialInstitutionId
          AND Rule3Id IS NULL
          AND Rule4Id IS NULL
          AND Rule5Id IS NULL
          AND Rule6Id IS NULL
          AND Rule7Id IS NULL
          AND Rule8Id IS NULL
          AND Rule9Id IS NULL
          AND Rule10Id IS NULL
          AND Source = N'IncomingPaymentFCY'
          AND Path = @path
          AND TargetMainGL = '393'
          AND Target = '39300800'
          AND TargetRuleId IS NULL
          AND CustomerCodeSourceRuleId IS NULL
          AND CustomerAccountCodeSourceRuleId IS NULL
    )
    BEGIN
    INSERT INTO dbo.AccAccountMap (Id, Ccy, CustomerId, RuleId, Rule2Id, Rule3Id, Rule4Id, Rule5Id, Rule6Id, Rule7Id,
                                   Rule8Id, Rule9Id, Rule10Id, [Source], [Path], TargetMainGL, Target, TargetRuleId,
                                   IsEnabled, [Order], Description, CustomerCodeSourceRuleId,
                                   CustomerAccountCodeSourceRuleId, StateId, StateDate, StateMaker)
    VALUES (@lastAccAccountMapId, NULL, NULL, NULL, @dynamicRuleIsFinancialInstitutionId, NULL, NULL, NULL, NULL, NULL,
            NULL, NULL, NULL, 'IncomingPaymentFCY', @path, '393', '39300800', NULL, 0, 1, 'Payment ', NULL, NULL,
            @stateId, @stateDate, @stateMaker);

    select @lastAccAccountMapId = @lastAccAccountMapId + 1
    END;

    IF NOT EXISTS (
        SELECT 1
        FROM dbo.AccAccountMap
        WHERE Ccy IS NULL
          AND CustomerId IS NULL
          AND RuleId IS NULL
          AND Rule2Id = @dynamicRuleIsFinancialInstitutionId
          AND Rule3Id IS NULL
          AND Rule4Id = @dynamicRuleIncomingPaymentInstructionTypeEqualB2BId
          AND Rule5Id = @dynamicRuleIncomingSettlementTypeEqualGrossId
          AND Rule6Id = 10007
          AND Rule7Id = 10011
          AND Rule8Id IS NULL
          AND Rule9Id IS NULL
          AND Rule10Id IS NULL
          AND Source = N'IncomingPaymentFCY'
          AND Path = @path
          AND TargetMainGL = '393'
          AND Target = '39300800'
          AND TargetRuleId IS NULL
          AND CustomerCodeSourceRuleId = 10017
          AND CustomerAccountCodeSourceRuleId = 10018
    )
    BEGIN
    INSERT INTO dbo.AccAccountMap (Id, Ccy, CustomerId, RuleId, Rule2Id, Rule3Id, Rule4Id, Rule5Id, Rule6Id, Rule7Id,
                                   Rule8Id, Rule9Id, Rule10Id, [Source], [Path], TargetMainGL, Target, TargetRuleId,
                                   IsEnabled, [Order], Description, CustomerCodeSourceRuleId,
                                   CustomerAccountCodeSourceRuleId, StateId, StateDate, StateMaker)
    VALUES (@lastAccAccountMapId, NULL, NULL, NULL, @dynamicRuleIsFinancialInstitutionId, NULL,
            @dynamicRuleIncomingPaymentInstructionTypeEqualB2BId, @dynamicRuleIncomingSettlementTypeEqualGrossId, 10007,
            10011, NULL, NULL, NULL, 'IncomingPaymentFCY', @path, '393', '39300800', NULL, 1, 5, '', 10017, 10018,
            @stateId, @stateDate, @stateMaker);

    select @lastAccAccountMapId = @lastAccAccountMapId + 1
    END;

    IF NOT EXISTS (
        SELECT 1
        FROM dbo.AccAccountMap
        WHERE Ccy IS NULL
          AND CustomerId IS NULL
          AND RuleId IS NULL
          AND Rule2Id = @dynamicRuleIsFinancialInstitutionId
          AND Rule3Id IS NULL
          AND Rule4Id = @dynamicRuleIncomingPaymentInstructionTypeEqualB2BId
          AND Rule5Id = @dynamicRuleIncomingSettlementTypeEqualGrossId
          AND Rule6Id = 10007
          AND Rule7Id = 10012
          AND Rule8Id IS NULL
          AND Rule9Id IS NULL
          AND Rule10Id IS NULL
          AND Source = N'IncomingPaymentFCY'
          AND Path = @path
          AND TargetMainGL = '393'
          AND Target = '39300800'
          AND TargetRuleId IS NULL
          AND CustomerCodeSourceRuleId IS NULL
          AND CustomerAccountCodeSourceRuleId IS NULL
    )
    BEGIN
    INSERT INTO dbo.AccAccountMap (Id, Ccy, CustomerId, RuleId, Rule2Id, Rule3Id, Rule4Id, Rule5Id, Rule6Id, Rule7Id,
                                   Rule8Id, Rule9Id, Rule10Id, [Source], [Path], TargetMainGL, Target, TargetRuleId,
                                   IsEnabled, [Order], Description, CustomerCodeSourceRuleId,
                                   CustomerAccountCodeSourceRuleId, StateId, StateDate, StateMaker)
    VALUES (@lastAccAccountMapId, NULL, NULL, NULL, @dynamicRuleIsFinancialInstitutionId, NULL,
            @dynamicRuleIncomingPaymentInstructionTypeEqualB2BId, @dynamicRuleIncomingSettlementTypeEqualGrossId, 10007,
            10012, NULL, NULL, NULL, 'IncomingPaymentFCY', @path, '393', '39300800', NULL, 1, 10, '', NULL, NULL,
            @stateId, @stateDate, @stateMaker);

    select @lastAccAccountMapId = @lastAccAccountMapId + 1
    END;

    IF NOT EXISTS (
        SELECT 1
        FROM dbo.AccAccountMap
        WHERE Ccy IS NULL
          AND CustomerId IS NULL
          AND RuleId IS NULL
          AND Rule2Id = @dynamicRuleIsFinancialInstitutionId
          AND Rule3Id IS NULL
          AND Rule4Id = @dynamicRuleIncomingPaymentInstructionTypeEqualB2BId
          AND Rule5Id = @dynamicRuleIncomingSettlementTypeEqualGrossId
          AND Rule6Id = 10008
          AND Rule7Id IS NULL
          AND Rule8Id IS NULL
          AND Rule9Id IS NULL
          AND Rule10Id IS NULL
          AND Source = N'IncomingPaymentFCY'
          AND Path = @path
          AND TargetMainGL = ''
          AND Target = ''
          AND TargetRuleId = 10016
          AND CustomerCodeSourceRuleId = 10017
          AND CustomerAccountCodeSourceRuleId = 10018
    )
    BEGIN
    INSERT INTO dbo.AccAccountMap (Id, Ccy, CustomerId, RuleId, Rule2Id, Rule3Id, Rule4Id, Rule5Id, Rule6Id, Rule7Id,
                                   Rule8Id, Rule9Id, Rule10Id, [Source], [Path], TargetMainGL, Target, TargetRuleId,
                                   IsEnabled, [Order], Description, CustomerCodeSourceRuleId,
                                   CustomerAccountCodeSourceRuleId, StateId, StateDate, StateMaker)
    VALUES (@lastAccAccountMapId, NULL, NULL, NULL, @dynamicRuleIsFinancialInstitutionId, NULL,
            @dynamicRuleIncomingPaymentInstructionTypeEqualB2BId, @dynamicRuleIncomingSettlementTypeEqualGrossId, 10008,
            NULL, NULL, NULL, NULL, 'IncomingPaymentFCY', @path, '', '', 10016, 1, 15, '', 10017, 10018, @stateId,
            @stateDate, @stateMaker);

    select @lastAccAccountMapId = @lastAccAccountMapId + 1
    END;

    IF NOT EXISTS (
        SELECT 1
        FROM dbo.AccAccountMap
        WHERE Ccy IS NULL
          AND CustomerId IS NULL
          AND RuleId IS NULL
          AND Rule2Id = @dynamicRuleIsFinancialInstitutionId
          AND Rule3Id IS NULL
          AND Rule4Id = @dynamicRuleIncomingPaymentInstructionTypeEqualB2BId
          AND Rule5Id = @dynamicRuleIncomingSettlementTypeEqualNettingId
          AND Rule6Id IS NULL
          AND Rule7Id = 10011
          AND Rule8Id IS NULL
          AND Rule9Id IS NULL
          AND Rule10Id IS NULL
          AND Source = N'IncomingPaymentFCY'
          AND Path = @path
          AND TargetMainGL = '393'
          AND Target = '39300800'
          AND TargetRuleId IS NULL
          AND CustomerCodeSourceRuleId = 10017
          AND CustomerAccountCodeSourceRuleId = 10018
    )
    BEGIN
    INSERT INTO dbo.AccAccountMap (Id, Ccy, CustomerId, RuleId, Rule2Id, Rule3Id, Rule4Id, Rule5Id, Rule6Id, Rule7Id,
                                   Rule8Id, Rule9Id, Rule10Id, [Source], [Path], TargetMainGL, Target, TargetRuleId,
                                   IsEnabled, [Order], Description, CustomerCodeSourceRuleId,
                                   CustomerAccountCodeSourceRuleId, StateId, StateDate, StateMaker)
    VALUES (@lastAccAccountMapId, NULL, NULL, NULL, @dynamicRuleIsFinancialInstitutionId, NULL,
            @dynamicRuleIncomingPaymentInstructionTypeEqualB2BId, @dynamicRuleIncomingSettlementTypeEqualNettingId,
            NULL, 10011, NULL, NULL, NULL, 'IncomingPaymentFCY', @path, '393', '39300800', NULL, 1, 20, '', 10017,
            10018, @stateId, @stateDate, @stateMaker);

    select @lastAccAccountMapId = @lastAccAccountMapId + 1
    END;

    IF NOT EXISTS (
        SELECT 1
        FROM dbo.AccAccountMap
        WHERE Ccy IS NULL
          AND CustomerId IS NULL
          AND RuleId IS NULL
          AND Rule2Id = @dynamicRuleIsFinancialInstitutionId
          AND Rule3Id IS NULL
          AND Rule4Id = @dynamicRuleIncomingPaymentInstructionTypeEqualB2BId
          AND Rule5Id = @dynamicRuleIncomingSettlementTypeEqualNettingId
          AND Rule6Id IS NULL
          AND Rule7Id = 10012
          AND Rule8Id IS NULL
          AND Rule9Id IS NULL
          AND Rule10Id IS NULL
          AND Source = N'IncomingPaymentFCY'
          AND Path = @path
          AND TargetMainGL = '393'
          AND Target = '39300800'
          AND TargetRuleId IS NULL
          AND CustomerCodeSourceRuleId IS NULL
          AND CustomerAccountCodeSourceRuleId IS NULL
    )
    BEGIN
    INSERT INTO dbo.AccAccountMap (Id, Ccy, CustomerId, RuleId, Rule2Id, Rule3Id, Rule4Id, Rule5Id, Rule6Id, Rule7Id,
                                   Rule8Id, Rule9Id, Rule10Id, [Source], [Path], TargetMainGL, Target, TargetRuleId,
                                   IsEnabled, [Order], Description, CustomerCodeSourceRuleId,
                                   CustomerAccountCodeSourceRuleId, StateId, StateDate, StateMaker)
    VALUES (@lastAccAccountMapId, NULL, NULL, NULL, @dynamicRuleIsFinancialInstitutionId, NULL,
            @dynamicRuleIncomingPaymentInstructionTypeEqualB2BId, @dynamicRuleIncomingSettlementTypeEqualNettingId,
            NULL, 10012, NULL, NULL, NULL, 'IncomingPaymentFCY', @path, '393', '39300800', NULL, 1, 25, '', NULL, NULL,
            @stateId, @stateDate, @stateMaker);

    select @lastAccAccountMapId = @lastAccAccountMapId + 1
    END;

    IF NOT EXISTS (
        SELECT 1
        FROM dbo.AccAccountMap
        WHERE Ccy IS NULL
          AND CustomerId IS NULL
          AND RuleId IS NULL
          AND Rule2Id = @dynamicRuleIsFinancialInstitutionId
          AND Rule3Id IS NULL
          AND Rule4Id = @dynamicRuleIncomingPaymentInstructionTypeEqualA2AId
          AND Rule5Id = @dynamicRuleIncomingSettlementTypeEqualGrossId
          AND Rule6Id = 10007
          AND Rule7Id = 10011
          AND Rule8Id IS NULL
          AND Rule9Id IS NULL
          AND Rule10Id IS NULL
          AND Source = N'IncomingPaymentFCY'
          AND Path = @path
          AND TargetMainGL = '393'
          AND Target = '39300800'
          AND TargetRuleId IS NULL
          AND CustomerCodeSourceRuleId = 10017
          AND CustomerAccountCodeSourceRuleId = 10018
    )
    BEGIN
    INSERT INTO dbo.AccAccountMap (Id, Ccy, CustomerId, RuleId, Rule2Id, Rule3Id, Rule4Id, Rule5Id, Rule6Id, Rule7Id,
                                   Rule8Id, Rule9Id, Rule10Id, [Source], [Path], TargetMainGL, Target, TargetRuleId,
                                   IsEnabled, [Order], Description, CustomerCodeSourceRuleId,
                                   CustomerAccountCodeSourceRuleId, StateId, StateDate, StateMaker)
    VALUES (@lastAccAccountMapId, NULL, NULL, NULL, @dynamicRuleIsFinancialInstitutionId, NULL,
            @dynamicRuleIncomingPaymentInstructionTypeEqualA2AId, @dynamicRuleIncomingSettlementTypeEqualGrossId, 10007,
            10011, NULL, NULL, NULL, 'IncomingPaymentFCY', @path, '393', '39300800', NULL, 1, 30, '', 10017, 10018,
            @stateId, @stateDate, @stateMaker);

    select @lastAccAccountMapId = @lastAccAccountMapId + 1
    END;

    IF NOT EXISTS (
        SELECT 1
        FROM dbo.AccAccountMap
        WHERE Ccy IS NULL
          AND CustomerId IS NULL
          AND RuleId IS NULL
          AND Rule2Id = @dynamicRuleIsFinancialInstitutionId
          AND Rule3Id IS NULL
          AND Rule4Id = @dynamicRuleIncomingPaymentInstructionTypeEqualA2AId
          AND Rule5Id = @dynamicRuleIncomingSettlementTypeEqualGrossId
          AND Rule6Id = 10007
          AND Rule7Id = 10012
          AND Rule8Id IS NULL
          AND Rule9Id IS NULL
          AND Rule10Id IS NULL
          AND Source = N'IncomingPaymentFCY'
          AND Path = @path
          AND TargetMainGL = '393'
          AND Target = '39300800'
          AND TargetRuleId IS NULL
          AND CustomerCodeSourceRuleId IS NULL
          AND CustomerAccountCodeSourceRuleId IS NULL
    )
    BEGIN
    INSERT INTO dbo.AccAccountMap (Id, Ccy, CustomerId, RuleId, Rule2Id, Rule3Id, Rule4Id, Rule5Id, Rule6Id, Rule7Id,
                                   Rule8Id, Rule9Id, Rule10Id, [Source], [Path], TargetMainGL, Target, TargetRuleId,
                                   IsEnabled, [Order], Description, CustomerCodeSourceRuleId,
                                   CustomerAccountCodeSourceRuleId, StateId, StateDate, StateMaker)
    VALUES (@lastAccAccountMapId, NULL, NULL, NULL, @dynamicRuleIsFinancialInstitutionId, NULL,
            @dynamicRuleIncomingPaymentInstructionTypeEqualA2AId, @dynamicRuleIncomingSettlementTypeEqualGrossId, 10007,
            10012, NULL, NULL, NULL, 'IncomingPaymentFCY', @path, '393', '39300800', NULL, 1, 35, '', NULL, NULL,
            @stateId, @stateDate, @stateMaker);

    select @lastAccAccountMapId = @lastAccAccountMapId + 1
    END;

    IF NOT EXISTS (
        SELECT 1
        FROM dbo.AccAccountMap
        WHERE Ccy IS NULL
          AND CustomerId IS NULL
          AND RuleId IS NULL
          AND Rule2Id = @dynamicRuleIsFinancialInstitutionId
          AND Rule3Id IS NULL
          AND Rule4Id = @dynamicRuleIncomingPaymentInstructionTypeEqualA2AId
          AND Rule5Id = @dynamicRuleIncomingSettlementTypeEqualGrossId
          AND Rule6Id = 10008
          AND Rule7Id IS NULL
          AND Rule8Id IS NULL
          AND Rule9Id IS NULL
          AND Rule10Id IS NULL
          AND Source = N'IncomingPaymentFCY'
          AND Path = @path
          AND TargetMainGL = ''
          AND Target = ''
          AND TargetRuleId = 10016
          AND CustomerCodeSourceRuleId = 10017
          AND CustomerAccountCodeSourceRuleId = 10018
    )
    BEGIN
    INSERT INTO dbo.AccAccountMap (Id, Ccy, CustomerId, RuleId, Rule2Id, Rule3Id, Rule4Id, Rule5Id, Rule6Id, Rule7Id,
                                   Rule8Id, Rule9Id, Rule10Id, [Source], [Path], TargetMainGL, Target, TargetRuleId,
                                   IsEnabled, [Order], Description, CustomerCodeSourceRuleId,
                                   CustomerAccountCodeSourceRuleId, StateId, StateDate, StateMaker)
    VALUES (@lastAccAccountMapId, NULL, NULL, NULL, @dynamicRuleIsFinancialInstitutionId, NULL,
            @dynamicRuleIncomingPaymentInstructionTypeEqualA2AId, @dynamicRuleIncomingSettlementTypeEqualGrossId, 10008,
            NULL, NULL, NULL, NULL, 'IncomingPaymentFCY', @path, '', '', 10016, 1, 40, '', 10017, 10018, @stateId,
            @stateDate, @stateMaker);

    select @lastAccAccountMapId = @lastAccAccountMapId + 1
    END;

    IF NOT EXISTS (
        SELECT 1
        FROM dbo.AccAccountMap
        WHERE Ccy IS NULL
          AND CustomerId IS NULL
          AND RuleId IS NULL
          AND Rule2Id = @dynamicRuleIsFinancialInstitutionId
          AND Rule3Id IS NULL
          AND Rule4Id = @dynamicRuleIncomingPaymentInstructionTypeEqualA2AId
          AND Rule5Id = @dynamicRuleIncomingSettlementTypeEqualNettingId
          AND Rule6Id IS NULL
          AND Rule7Id = 10011
          AND Rule8Id IS NULL
          AND Rule9Id IS NULL
          AND Rule10Id IS NULL
          AND Source = N'IncomingPaymentFCY'
          AND Path = @path
          AND TargetMainGL = '393'
          AND Target = '39300800'
          AND TargetRuleId IS NULL
          AND CustomerCodeSourceRuleId = 10017
          AND CustomerAccountCodeSourceRuleId = 10018
    )
    BEGIN
    INSERT INTO dbo.AccAccountMap (Id, Ccy, CustomerId, RuleId, Rule2Id, Rule3Id, Rule4Id, Rule5Id, Rule6Id, Rule7Id,
                                   Rule8Id, Rule9Id, Rule10Id, [Source], [Path], TargetMainGL, Target, TargetRuleId,
                                   IsEnabled, [Order], Description, CustomerCodeSourceRuleId,
                                   CustomerAccountCodeSourceRuleId, StateId, StateDate, StateMaker)
    VALUES (@lastAccAccountMapId, NULL, NULL, NULL, @dynamicRuleIsFinancialInstitutionId, NULL,
            @dynamicRuleIncomingPaymentInstructionTypeEqualA2AId, @dynamicRuleIncomingSettlementTypeEqualNettingId,
            NULL, 10011, NULL, NULL, NULL, 'IncomingPaymentFCY', @path, '393', '39300800', NULL, 1, 45, '', 10017,
            10018, @stateId, @stateDate, @stateMaker);

    select @lastAccAccountMapId = @lastAccAccountMapId + 1
    END;

    IF NOT EXISTS (
        SELECT 1
        FROM dbo.AccAccountMap
        WHERE Ccy IS NULL
          AND CustomerId IS NULL
          AND RuleId IS NULL
          AND Rule2Id = @dynamicRuleIsFinancialInstitutionId
          AND Rule3Id IS NULL
          AND Rule4Id = @dynamicRuleIncomingPaymentInstructionTypeEqualA2AId
          AND Rule5Id = @dynamicRuleIncomingSettlementTypeEqualNettingId
          AND Rule6Id IS NULL
          AND Rule7Id = 10012
          AND Rule8Id IS NULL
          AND Rule9Id IS NULL
          AND Rule10Id IS NULL
          AND Source = N'IncomingPaymentFCY'
          AND Path = @path
          AND TargetMainGL = '393'
          AND Target = '39300800'
          AND TargetRuleId IS NULL
          AND CustomerCodeSourceRuleId IS NULL
          AND CustomerAccountCodeSourceRuleId IS NULL
    )
    BEGIN
    INSERT INTO dbo.AccAccountMap (Id, Ccy, CustomerId, RuleId, Rule2Id, Rule3Id, Rule4Id, Rule5Id, Rule6Id, Rule7Id,
                                   Rule8Id, Rule9Id, Rule10Id, [Source], [Path], TargetMainGL, Target, TargetRuleId,
                                   IsEnabled, [Order], Description, CustomerCodeSourceRuleId,
                                   CustomerAccountCodeSourceRuleId, StateId, StateDate, StateMaker)
    VALUES (@lastAccAccountMapId, NULL, NULL, NULL, @dynamicRuleIsFinancialInstitutionId, NULL,
            @dynamicRuleIncomingPaymentInstructionTypeEqualA2AId, @dynamicRuleIncomingSettlementTypeEqualNettingId,
            NULL, 10012, NULL, NULL, NULL, 'IncomingPaymentFCY', @path, '393', '39300800', NULL, 1, 50, '', NULL, NULL,
            @stateId, @stateDate, @stateMaker);

    select @lastAccAccountMapId = @lastAccAccountMapId + 1
    END;

    IF NOT EXISTS (
        SELECT 1
        FROM dbo.AccAccountMap
        WHERE Ccy IS NULL
          AND CustomerId IS NULL
          AND RuleId IS NULL
          AND Rule2Id = @dynamicRuleIsFinancialInstitutionId
          AND Rule3Id IS NULL
          AND Rule4Id = @dynamicRuleIncomingPaymentInstructionTypeEqualV2VId
          AND Rule5Id = @dynamicRuleIncomingSettlementTypeEqualGrossId
          AND Rule6Id = 10007
          AND Rule7Id = 10011
          AND Rule8Id IS NULL
          AND Rule9Id IS NULL
          AND Rule10Id IS NULL
          AND Source = N'IncomingPaymentFCY'
          AND Path = @path
          AND TargetMainGL = '393'
          AND Target = '39300800'
          AND TargetRuleId IS NULL
          AND CustomerCodeSourceRuleId = 10020
          AND CustomerAccountCodeSourceRuleId = 10021
    )
    BEGIN
    INSERT INTO dbo.AccAccountMap (Id, Ccy, CustomerId, RuleId, Rule2Id, Rule3Id, Rule4Id, Rule5Id, Rule6Id, Rule7Id,
                                   Rule8Id, Rule9Id, Rule10Id, [Source], [Path], TargetMainGL, Target, TargetRuleId,
                                   IsEnabled, [Order], Description, CustomerCodeSourceRuleId,
                                   CustomerAccountCodeSourceRuleId, StateId, StateDate, StateMaker)
    VALUES (@lastAccAccountMapId, NULL, NULL, NULL, @dynamicRuleIsFinancialInstitutionId, NULL,
            @dynamicRuleIncomingPaymentInstructionTypeEqualV2VId, @dynamicRuleIncomingSettlementTypeEqualGrossId, 10007,
            10011, NULL, NULL, NULL, 'IncomingPaymentFCY', @path, '393', '39300800', NULL, 1, 55, '', 10020, 10021,
            @stateId, @stateDate, @stateMaker);

    select @lastAccAccountMapId = @lastAccAccountMapId + 1
    END;

    IF NOT EXISTS (
        SELECT 1
        FROM dbo.AccAccountMap
        WHERE Ccy IS NULL
          AND CustomerId IS NULL
          AND RuleId IS NULL
          AND Rule2Id = @dynamicRuleIsFinancialInstitutionId
          AND Rule3Id IS NULL
          AND Rule4Id = @dynamicRuleIncomingPaymentInstructionTypeEqualV2VId
          AND Rule5Id = @dynamicRuleIncomingSettlementTypeEqualGrossId
          AND Rule6Id = 10007
          AND Rule7Id = 10012
          AND Rule8Id IS NULL
          AND Rule9Id IS NULL
          AND Rule10Id IS NULL
          AND Source = N'IncomingPaymentFCY'
          AND Path = @path
          AND TargetMainGL = '393'
          AND Target = '39300800'
          AND TargetRuleId IS NULL
          AND CustomerCodeSourceRuleId IS NULL
          AND CustomerAccountCodeSourceRuleId IS NULL
    )
    BEGIN
    INSERT INTO dbo.AccAccountMap (Id, Ccy, CustomerId, RuleId, Rule2Id, Rule3Id, Rule4Id, Rule5Id, Rule6Id, Rule7Id,
                                   Rule8Id, Rule9Id, Rule10Id, [Source], [Path], TargetMainGL, Target, TargetRuleId,
                                   IsEnabled, [Order], Description, CustomerCodeSourceRuleId,
                                   CustomerAccountCodeSourceRuleId, StateId, StateDate, StateMaker)
    VALUES (@lastAccAccountMapId, NULL, NULL, NULL, @dynamicRuleIsFinancialInstitutionId, NULL,
            @dynamicRuleIncomingPaymentInstructionTypeEqualV2VId, @dynamicRuleIncomingSettlementTypeEqualGrossId, 10007,
            10012, NULL, NULL, NULL, 'IncomingPaymentFCY', @path, '393', '39300800', NULL, 1, 60, '', NULL, NULL,
            @stateId, @stateDate, @stateMaker);

    select @lastAccAccountMapId = @lastAccAccountMapId + 1
    END;

    IF NOT EXISTS (
        SELECT 1
        FROM dbo.AccAccountMap
        WHERE Ccy IS NULL
          AND CustomerId IS NULL
          AND RuleId IS NULL
          AND Rule2Id = @dynamicRuleIsFinancialInstitutionId
          AND Rule3Id IS NULL
          AND Rule4Id = @dynamicRuleIncomingPaymentInstructionTypeEqualV2VId
          AND Rule5Id = @dynamicRuleIncomingSettlementTypeEqualGrossId
          AND Rule6Id = 10008
          AND Rule7Id IS NULL
          AND Rule8Id IS NULL
          AND Rule9Id IS NULL
          AND Rule10Id IS NULL
          AND Source = N'IncomingPaymentFCY'
          AND Path = @path
          AND TargetMainGL = ''
          AND Target = ''
          AND TargetRuleId = 10019
          AND CustomerCodeSourceRuleId = 10020
          AND CustomerAccountCodeSourceRuleId = 10021
    )
    BEGIN
    INSERT INTO dbo.AccAccountMap (Id, Ccy, CustomerId, RuleId, Rule2Id, Rule3Id, Rule4Id, Rule5Id, Rule6Id, Rule7Id,
                                   Rule8Id, Rule9Id, Rule10Id, [Source], [Path], TargetMainGL, Target, TargetRuleId,
                                   IsEnabled, [Order], Description, CustomerCodeSourceRuleId,
                                   CustomerAccountCodeSourceRuleId, StateId, StateDate, StateMaker)
    VALUES (@lastAccAccountMapId, NULL, NULL, NULL, @dynamicRuleIsFinancialInstitutionId, NULL,
            @dynamicRuleIncomingPaymentInstructionTypeEqualV2VId, @dynamicRuleIncomingSettlementTypeEqualGrossId, 10008,
            NULL, NULL, NULL, NULL, 'IncomingPaymentFCY', @path, '', '', 10019, 1, 65, '', 10020, 10021, @stateId,
            @stateDate, @stateMaker);

    select @lastAccAccountMapId = @lastAccAccountMapId + 1
    END;

    IF NOT EXISTS (
        SELECT 1
        FROM dbo.AccAccountMap
        WHERE Ccy IS NULL
          AND CustomerId IS NULL
          AND RuleId IS NULL
          AND Rule2Id = @dynamicRuleIsFinancialInstitutionId
          AND Rule3Id IS NULL
          AND Rule4Id = @dynamicRuleIncomingPaymentInstructionTypeEqualV2VId
          AND Rule5Id = @dynamicRuleIncomingSettlementTypeEqualNettingId
          AND Rule6Id IS NULL
          AND Rule7Id = 10011
          AND Rule8Id IS NULL
          AND Rule9Id IS NULL
          AND Rule10Id IS NULL
          AND Source = N'IncomingPaymentFCY'
          AND Path = @path
          AND TargetMainGL = '393'
          AND Target = '39300800'
          AND TargetRuleId IS NULL
          AND CustomerCodeSourceRuleId = 10020
          AND CustomerAccountCodeSourceRuleId = 10021
    )
    BEGIN
    INSERT INTO dbo.AccAccountMap (Id, Ccy, CustomerId, RuleId, Rule2Id, Rule3Id, Rule4Id, Rule5Id, Rule6Id, Rule7Id,
                                   Rule8Id, Rule9Id, Rule10Id, [Source], [Path], TargetMainGL, Target, TargetRuleId,
                                   IsEnabled, [Order], Description, CustomerCodeSourceRuleId,
                                   CustomerAccountCodeSourceRuleId, StateId, StateDate, StateMaker)
    VALUES (@lastAccAccountMapId, NULL, NULL, NULL, @dynamicRuleIsFinancialInstitutionId, NULL,
            @dynamicRuleIncomingPaymentInstructionTypeEqualV2VId, @dynamicRuleIncomingSettlementTypeEqualNettingId,
            NULL, 10011, NULL, NULL, NULL, 'IncomingPaymentFCY', @path, '393', '39300800', NULL, 1, 70, '', 10020,
            10021, @stateId, @stateDate, @stateMaker);

    select @lastAccAccountMapId = @lastAccAccountMapId + 1
    END;

    IF NOT EXISTS (
        SELECT 1
        FROM dbo.AccAccountMap
        WHERE Ccy IS NULL
          AND CustomerId IS NULL
          AND RuleId IS NULL
          AND Rule2Id = @dynamicRuleIsFinancialInstitutionId
          AND Rule3Id IS NULL
          AND Rule4Id = @dynamicRuleIncomingPaymentInstructionTypeEqualV2VId
          AND Rule5Id = @dynamicRuleIncomingSettlementTypeEqualNettingId
          AND Rule6Id IS NULL
          AND Rule7Id = 10012
          AND Rule8Id IS NULL
          AND Rule9Id IS NULL
          AND Rule10Id IS NULL
          AND Source = N'IncomingPaymentFCY'
          AND Path = @path
          AND TargetMainGL = '393'
          AND Target = '39300800'
          AND TargetRuleId IS NULL
          AND CustomerCodeSourceRuleId IS NULL
          AND CustomerAccountCodeSourceRuleId IS NULL
    )
    BEGIN
    INSERT INTO dbo.AccAccountMap (Id, Ccy, CustomerId, RuleId, Rule2Id, Rule3Id, Rule4Id, Rule5Id, Rule6Id, Rule7Id,
                                   Rule8Id, Rule9Id, Rule10Id, [Source], [Path], TargetMainGL, Target, TargetRuleId,
                                   IsEnabled, [Order], Description, CustomerCodeSourceRuleId,
                                   CustomerAccountCodeSourceRuleId, StateId, StateDate, StateMaker)
    VALUES (@lastAccAccountMapId, NULL, NULL, NULL, @dynamicRuleIsFinancialInstitutionId, NULL,
            @dynamicRuleIncomingPaymentInstructionTypeEqualV2VId, @dynamicRuleIncomingSettlementTypeEqualNettingId,
            NULL, 10012, NULL, NULL, NULL, 'IncomingPaymentFCY', @path, '393', '39300800', NULL, 1, 75, '', NULL, NULL,
            @stateId, @stateDate, @stateMaker);

    select @lastAccAccountMapId = @lastAccAccountMapId + 1
    END;
    --#endregion
    ------------------------------------------------------------------------------------------------------------------------
    -- Definition Number Generation Update
    ------------------------------------------------------------------------------------------------------------------------
    --#region DefNumberGen
    update dbo.defNumberGen
    SET LastNumber     = @lastAccEngineDynamicRuleId,
        LastUpdateDate = @stateDate
    WHERE EntityColumnType = @accEngineDynamicRuleColumnTypeId
    update dbo.defNumberGen
    SET LastNumber     = @lastAccAccountMapId,
        LastUpdateDate = @stateDate
    WHERE EntityColumnType = @accAccountMapColumnTypeId
    --#endregion

    ------------------------------------------------------------------------------------------------------------------------
    -- AccAccountRule ValRecPrincipal, MatRecPrincipal Update
    ------------------------------------------------------------------------------------------------------------------------
    --#region AccAccountRule
    UPDATE ar
    SET ar.GLCode = CASE
                        WHEN ar.GLCode = 'ValRecPrincipal' AND ai.Path = 'TREX/DV/CCS/LCYRFCYP/' AND
                             ae.EventTypeCode = 'OnOpening'
                            THEN 'OutgoingPaymentLCY'
                        WHEN ar.GLCode = 'ValPayPrincipal' AND ai.Path = 'TREX/DV/CCS/LCYRFCYP/' AND
                             ae.EventTypeCode = 'OnOpening'
                            THEN 'IncomingPaymentFCY'
                        WHEN ar.GLCode = 'MatRecPrincipal' AND ai.Path = 'TREX/DV/CCS/LCYRFCYP/' AND
                             ae.EventTypeCode = 'OnMaturation'
                            THEN 'IncomingPaymentLCY'
                        WHEN ar.GLCode = 'MatPayPrincipal' AND ai.Path = 'TREX/DV/CCS/LCYRFCYP/' AND
                             ae.EventTypeCode = 'OnMaturation'
                            THEN 'OutgoingPaymentFCY'
                        WHEN ar.GLCode = 'ValRecPrincipal' AND ai.Path = 'TREX/DV/CCS/FCYRLCYP/' AND
                             ae.EventTypeCode = 'OnOpening'
                            THEN 'OutgoingPaymentFCY'
                        WHEN ar.GLCode = 'ValPayPrincipal' AND ai.Path = 'TREX/DV/CCS/FCYRLCYP/' AND
                             ae.EventTypeCode = 'OnOpening'
                            THEN 'IncomingPaymentLCY'
                        WHEN ar.GLCode = 'MatRecPrincipal' AND ai.Path = 'TREX/DV/CCS/FCYRLCYP/' AND
                             ae.EventTypeCode = 'OnMaturation'
                            THEN 'IncomingPaymentFCY'
                        WHEN ar.GLCode = 'MatPayPrincipal' AND ai.Path = 'TREX/DV/CCS/FCYRLCYP/' AND
                             ae.EventTypeCode = 'OnMaturation'
                            THEN 'OutgoingPaymentLCY'
                        WHEN ar.GLCode = 'ValRecPrincipal' AND ai.Path = 'TREX/DV/CCS/FCYRFCYP/' AND
                             ae.EventTypeCode = 'OnOpening'
                            THEN 'OutgoingPaymentFCY'
                        WHEN ar.GLCode = 'ValPayPrincipal' AND ai.Path = 'TREX/DV/CCS/FCYRFCYP/' AND
                             ae.EventTypeCode = 'OnOpening'
                            THEN 'IncomingPaymentFCY'
                        WHEN ar.GLCode = 'MatRecPrincipal' AND ai.Path = 'TREX/DV/CCS/FCYRFCYP/' AND
                             ae.EventTypeCode = 'OnMaturation'
                            THEN 'IncomingPaymentFCY'
                        WHEN ar.GLCode = 'MatPayPrincipal' AND ai.Path = 'TREX/DV/CCS/FCYRFCYP/' AND
                             ae.EventTypeCode = 'OnMaturation'
                            THEN 'OutgoingPaymentFCY'
                        ELSE ar.GLCode
        END
    FROM dbo.AccEngineAccountRule ar
             INNER JOIN dbo.AccEngineComponent ac ON ac.Id = ar.ComponentId
             INNER JOIN dbo.AccEngineGroup ag ON ag.Id = ac.GroupId
             INNER JOIN dbo.AccEngineEvent ae ON ae.Id = ag.EventId
             INNER JOIN dbo.AccEngineItem ai ON ai.Id = ae.ItemId
    WHERE ai.Path LIKE 'TREX/DV/CCS%';
	 --#endregion

	------------------------------------------------------------------------------------------------------------------------
    -- AccEngineAccountRule DELETE
    ------------------------------------------------------------------------------------------------------------------------
    --#region AccAccountRule
    DELETE
    FROM AccEngineAccountRule
    WHERE GLCode IN ('ValRecPrincipal', 'ValPayPrincipal', 'MatRecPrincipal', 'MatPayPrincipal')
      AND ComponentId NOT IN (SELECT Id FROM AccEngineComponent);
	  
	
	DELETE ac
	FROM [AccAccountMap] ac
	JOIN [AccEngineDynamicRule] ar ON ar.Id = ac.Rule4Id
	WHERE ac.Path = N'TREX/DV'
	AND ar.Name = N'PaymentInstructionType = B2B';

	DELETE ac
	FROM [AccAccountMap] ac
	JOIN [AccEngineDynamicRule] ar ON ar.Id = ac.Rule4Id
	WHERE ac.Path = N'TREX/DV'
	AND ar.Name = N'PaymentInstructionType = A2A';

	DELETE ac
	FROM [AccAccountMap] ac
	JOIN [AccEngineDynamicRule] ar ON ar.Id = ac.Rule5Id
	WHERE ac.Path = N'TREX/DV'
	AND ar.Name = N'SettlementType = Net';


	DELETE ac
	FROM [AccAccountMap] ac
	JOIN [AccEngineDynamicRule] ar ON ar.Id = ac.Rule5Id
	WHERE ac.Path = N'TREX/DV'
	AND ar.Name = N'SettlementType = Gross';
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