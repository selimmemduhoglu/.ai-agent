/***************************************************************************************************
* This script is designed to update DerivSwp AccEngineEvent Description
***************************************************************************************************/

USE NetTrexAcc
GO

BEGIN TRY
    BEGIN TRANSACTION;

    /********** 1. STEP: PARAMETER DEFINITION **********************************/
    BEGIN
        DECLARE
            @tempTable TABLE (Id INT);

        DECLARE
            @pathDV NVARCHAR(20) = 'TREX/DV/';

        DECLARE
            @stateId INT=18,
            @stateDate datetime = getdate(),
            @stateMaker nvarchar(80) = N'SYSTEM';

        DECLARE
            @lastAccEngineDynamicRuleId INT = 0,
            @accEngineDynamicRuleColumnTypeId INT = 1;

        DECLARE
            @dynamicRuleIdOpening INT = 0,
            @dynamicRuleIdMaturation INT = 0,
            @dynamicRuleIdPayment INT = 0,
            @dynamicRuleIdRevaluation INT = 0,
            @dynamicRuleIdAmortization INT = 0,
            @dynamicRuleIdFee INT = 0;


        DECLARE @i INT = 1, @count INT;

        ------------------------------------------------------------------------------------------------------------------------
        -- Definition Number Generation
        ------------------------------------------------------------------------------------------------------------------------
        -- #region Accounting Engine Dynamic Rule Last Number
        ------------------------------------------------------------------------------------------------------------------------
        SELECT @lastAccEngineDynamicRuleId = LastNumber + 1
        FROM dbo.DefNumberGen
        WHERE EntityColumnType = @accEngineDynamicRuleColumnTypeId
          AND Definition = N'AccEngineDynamicRule Id'

        IF (@lastAccEngineDynamicRuleId = 0)
            THROW 500001, 'AccEngineDynamicRule Last Id Not Found', 1
        ------------------------------------------------------------------------------------------------------------------------
        --#endregion
        ------------------------------------------------------------------------------------------------------------------------ 
    END

    /********** 2. STEP: DYNAMIC RULES *****************************************/
    BEGIN
        ------------------------------------------------------------------------------------------------------------------------   
        -- Accounting Engine Dynamic Rule
        ------------------------------------------------------------------------------------------------------------------------
        -- DV Opening Accounting Description
        ------------------------------------------------------------------------------------------------------------------------
        IF NOT EXISTS (SELECT 1
                       FROM dbo.AccEngineDynamicRule
                       WHERE [Name] = N'DV Opening Accounting Description')
            BEGIN
                INSERT INTO dbo.AccEngineDynamicRule (Id, Name, [Rule], Type, Description, StateId, StateDate, StateMaker)
                OUTPUT inserted.Id INTO @tempTable
                VALUES (@lastAccEngineDynamicRuleId, N'DV Opening Accounting Description',
                        N'`${TxnModel.CustomerName} ile yapılan ${TxnModel.TxnReference} referanslı ${TxnModel.ReceiveCurrency} / ${TxnModel.PayCurrency} ${TxnModel.ProductCode} işlemi açılış fişi`',
                        1, N'', @StateId, @stateDate, @stateMaker);
                SELECT @dynamicRuleIdOpening = Id FROM @tempTable;
                DELETE FROM @tempTable
                SELECT @lastAccEngineDynamicRuleId = @lastAccEngineDynamicRuleId + 1
            END;
        ELSE
            BEGIN
                SELECT @dynamicRuleIdOpening = Id
                FROM dbo.AccEngineDynamicRule
                WHERE [Name] = N'DV Opening Accounting Description'
            END
        ------------------------------------------------------------------------------------------------------------------------

        ------------------------------------------------------------------------------------------------------------------------
        -- DV Maturation Accounting Description
        ------------------------------------------------------------------------------------------------------------------------
        IF NOT EXISTS (SELECT 1
                       FROM dbo.AccEngineDynamicRule
                       WHERE [Name] = N'DV Maturation Accounting Description')
            BEGIN
                INSERT INTO dbo.AccEngineDynamicRule (Id, Name, [Rule], Type, Description, StateId, StateDate, StateMaker)
                OUTPUT inserted.Id INTO @tempTable
                VALUES (@lastAccEngineDynamicRuleId, N'DV Maturation Accounting Description',
                        N'`${TxnModel.CustomerName} ile yapılan ${TxnModel.TxnReference} referanslı ${TxnModel.ReceiveCurrency} / ${TxnModel.PayCurrency} ${TxnModel.ProductCode} işlemi kapanış fişi`',
                        1, N'', @StateId, @stateDate, @stateMaker);
                SELECT @dynamicRuleIdMaturation = Id FROM @tempTable;
                DELETE FROM @tempTable
                SELECT @lastAccEngineDynamicRuleId = @lastAccEngineDynamicRuleId + 1
            END;
        ELSE
            BEGIN
                SELECT @dynamicRuleIdMaturation = Id
                FROM dbo.AccEngineDynamicRule
                WHERE [Name] = N'DV Maturation Accounting Description'
            END
        ------------------------------------------------------------------------------------------------------------------------

        ------------------------------------------------------------------------------------------------------------------------
        -- DV Payment Accounting Description
        ------------------------------------------------------------------------------------------------------------------------
        IF NOT EXISTS (SELECT 1
                       FROM dbo.AccEngineDynamicRule
                       WHERE [Name] = N'DV Payment Accounting Description')
            BEGIN
                INSERT INTO dbo.AccEngineDynamicRule (Id, Name, [Rule], Type, Description, StateId, StateDate, StateMaker)
                OUTPUT inserted.Id INTO @tempTable
                VALUES (@lastAccEngineDynamicRuleId, N'DV Payment Accounting Description',
                        N'`${TxnModel.CustomerName} ile yapılan ${TxnModel.TxnReference} referanslı ${TxnModel.ReceiveCurrency} / ${TxnModel.PayCurrency} ${TxnModel.ProductCode} işlemi dönem ödemesi`',
                        1, N'', @StateId, @stateDate, @stateMaker);
                SELECT @dynamicRuleIdPayment = Id FROM @tempTable;
                DELETE FROM @tempTable
                SELECT @lastAccEngineDynamicRuleId = @lastAccEngineDynamicRuleId + 1
            END;
        ELSE
            BEGIN
                SELECT @dynamicRuleIdPayment = Id
                FROM dbo.AccEngineDynamicRule
                WHERE [Name] = N'DV Payment Accounting Description'
            END
        ------------------------------------------------------------------------------------------------------------------------

         ------------------------------------------------------------------------------------------------------------------------
        -- DV Revaluation Accounting Description
        ------------------------------------------------------------------------------------------------------------------------
        IF NOT EXISTS (SELECT 1
                       FROM dbo.AccEngineDynamicRule
                       WHERE [Name] = N'DV Revaluation Accounting Description')
            BEGIN
                INSERT INTO dbo.AccEngineDynamicRule (Id, Name, [Rule], Type, Description, StateId, StateDate, StateMaker)
                OUTPUT inserted.Id INTO @tempTable
                VALUES (@lastAccEngineDynamicRuleId, N'DV Revaluation Accounting Description',
                        N'`${TxnModel.CustomerName} ile yapılan ${TxnModel.TxnReference} referanslı ${TxnModel.ReceiveCurrency} / ${TxnModel.PayCurrency} ${TxnModel.ProductCode} işlemi reeskont fişi`',
                        1, N'', @StateId, @stateDate, @stateMaker);
                SELECT @dynamicRuleIdRevaluation = Id FROM @tempTable;
                DELETE FROM @tempTable
                SELECT @lastAccEngineDynamicRuleId = @lastAccEngineDynamicRuleId + 1
            END;
        ELSE
            BEGIN
                SELECT @dynamicRuleIdRevaluation = Id
                FROM dbo.AccEngineDynamicRule
                WHERE [Name] = N'DV Revaluation Accounting Description'
            END
        ------------------------------------------------------------------------------------------------------------------------

        ------------------------------------------------------------------------------------------------------------------------
        -- DV Amortization Accounting Description
        ------------------------------------------------------------------------------------------------------------------------
        IF NOT EXISTS (SELECT 1
                       FROM dbo.AccEngineDynamicRule
                       WHERE [Name] = N'DV Amortization Accounting Description')
            BEGIN
                INSERT INTO dbo.AccEngineDynamicRule (Id, Name, [Rule], Type, Description, StateId, StateDate, StateMaker)
                OUTPUT inserted.Id INTO @tempTable
                VALUES (@lastAccEngineDynamicRuleId, N'DV Amortization Accounting Description',
                        N'`${TxnModel.CustomerName} ile yapılan ${TxnModel.TxnReference} referanslı ${TxnModel.ReceiveCurrency} / ${TxnModel.PayCurrency} ${TxnModel.ProductCode} işlemi amortisman ödemesi`',
                        1, N'', @StateId, @stateDate, @stateMaker);
                SELECT @dynamicRuleIdAmortization = Id FROM @tempTable;
                DELETE FROM @tempTable
                SELECT @lastAccEngineDynamicRuleId = @lastAccEngineDynamicRuleId + 1
            END;
        ELSE
            BEGIN
                SELECT @dynamicRuleIdAmortization = Id
                FROM dbo.AccEngineDynamicRule
                WHERE [Name] = N'DV Amortization Accounting Description'
            END
        ------------------------------------------------------------------------------------------------------------------------

        ------------------------------------------------------------------------------------------------------------------------
        -- DV Fee Accounting Description
        ------------------------------------------------------------------------------------------------------------------------
        IF NOT EXISTS (SELECT 1
                       FROM dbo.AccEngineDynamicRule
                       WHERE [Name] = N'DV Fee Accounting Description')
            BEGIN
                INSERT INTO dbo.AccEngineDynamicRule (Id, Name, [Rule], Type, Description, StateId, StateDate, StateMaker)
                OUTPUT inserted.Id INTO @tempTable
                VALUES (@lastAccEngineDynamicRuleId, N'DV Fee Accounting Description',
                        N'`${TxnModel.CustomerName} ile yapılan ${TxnModel.TxnReference} referanslı ${TxnModel.ReceiveCurrency} / ${TxnModel.PayCurrency} ${TxnModel.ProductCode} işlemi fee ödemesi`',
                        1, N'', @StateId, @stateDate, @stateMaker);
                SELECT @dynamicRuleIdFee = Id FROM @tempTable;
                DELETE FROM @tempTable
                SELECT @lastAccEngineDynamicRuleId = @lastAccEngineDynamicRuleId + 1
            END;
        ELSE
            BEGIN
                SELECT @dynamicRuleIdFee = Id
                FROM dbo.AccEngineDynamicRule
                WHERE [Name] = N'DV Fee Accounting Description'
            END
        ------------------------------------------------------------------------------------------------------------------------
    END

    /********** 3. STEP: UPDATE ACC ENGINE EVENTS ******************************/
    BEGIN 
		PRINT N'AccEngineEvent - EventDescriptionDynamicRuleId update starting..'

		DECLARE @tempEvent TABLE (Id INT IDENTITY(1,1), RuleId INT, EventTypeCode NVARCHAR(255));
		INSERT INTO @tempEvent VALUES
        (@dynamicRuleIdOpening, 'OnOpening'),
        (@dynamicRuleIdMaturation, 'OnMaturation'),
        (@dynamicRuleIdPayment, 'OnPayment'),
        (@dynamicRuleIdRevaluation, 'OnRevaluation'),
        (@dynamicRuleIdFee, 'OnFee'),
        (@dynamicRuleIdAmortization, 'OnAmortization'),
        (@dynamicRuleIdPayment, 'OnCustomerPaymentIncoming'),
        (@dynamicRuleIdPayment, 'OnCustomerPaymentOutgoing');
                                                      
        DECLARE @EventTypeCode NVARCHAR(255);
        DECLARE @RuleId INT;
        SELECT @count = COUNT(*) FROM @tempEvent;

		SET @i= 1;
		WHILE @i <= @count
		BEGIN

            SELECT @RuleId = RuleId, @EventTypeCode = EventTypeCode FROM @tempEvent WHERE Id = @i;

            UPDATE ae SET ae.EventDescriptionDynamicRuleId = @RuleId
            FROM AccEngineEvent ae
            INNER JOIN AccEngineItem ai ON ae.ItemId = ai.Id
            WHERE ai.Path LIKE 'TREX/DV/%' and ae.EventTypeCode = @EventTypeCode;

            SET @i += 1;
		END
		
        PRINT N'AccEngineEvent - EventDescriptionDynamicRuleId update FINISH'
	END

    /********** 4. STEP: NUMBER GENERATION UPDATE ******************************/
    BEGIN
        ------------------------------------------------------------------------------------------------------------------------
        -- Definition Number Generation Update
        ------------------------------------------------------------------------------------------------------------------------
        update dbo.defNumberGen
        SET LastNumber     = @lastAccEngineDynamicRuleId,
            LastUpdateDate = @stateDate
        WHERE EntityColumnType = @accEngineDynamicRuleColumnTypeId;
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

