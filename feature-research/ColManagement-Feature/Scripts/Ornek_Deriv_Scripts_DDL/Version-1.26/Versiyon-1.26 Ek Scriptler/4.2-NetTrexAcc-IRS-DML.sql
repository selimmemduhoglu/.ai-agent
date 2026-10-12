use [NetTrexAcc]
GO
SET XACT_ABORT ON;

begin transaction;

begin try
    DECLARE
        @tempTable TABLE
                   (
                       Id INT
                   );
    DECLARE
        @stateId int=18,
        @stateDate datetime = getdate(),
        @stateMaker nvarchar(80) = 'SYSTEM',
        @number int = 0;
    DECLARE
        @lastAccEngineDynamicRuleId int = 0,
        @accEngineDynamicRuleColumnTypeId int = 1,
        @lastAccEngineAccountRuleId int = 0,
        @accEngineAccountRuleColumnTypeId int = 2,
        @lastAccEngineComponentId int = 0,
        @accEngineComponentColumnTypeId int = 3,
        @lastAccEngineGroupId int = 0,
        @accEngineGroupColumnTypeId int = 4,
        @lastAccEngineEventId int = 0,
        @accEngineEventColumnTypeId int = 5,
        @lastAccEngineItemId int = 0,
        @accEngineItemColumnTypeId int= 7,
        @lastAccEngineItemCodeId int = 0,
        @accEngineItemCodeColumnTypeId int = 8,
        @lastAccEngineItemTypeId int = 0,
        @accEngineItemTypeColumnTypeId int = 9,
        @lastAccEngineModelDefinitionId int = 0,
        @accEngineModelDefinitionColumnTypeId int = 10,
        @lastAccAccountMapId int = 0,
        @accAccountMapColumnTypeId int = 11;
    declare
        @lcyItemId int =0,
        @fcyItemId int = 0;
    declare
        @lcyOpeningEventId int = 0,
        @lcyRevaluationEventId int = 0,
        @lcyPaymentEventId int = 0,
        @lcyMaturationEventId int = 0;
    declare
        @fcyOpeningEventId int = 0,
        @fcyRevaluationEventId int = 0,
        @fcyPaymentEventId int = 0,
        @fcyMaturationEventId int = 0;
    declare
        @lcyOpeningGroup1Id int =0,
        @lcyOpeningGroup2Id int = 0,
        @lcyRevaluationGroupId int = 0,
        @lcyPaymentGroupId int = 0,
        @lcyMaturationGroupId int = 0;
    declare @fcyOpeningGroup1Id int =0,
        @fcyOpeningGroup2Id int = 0,
        @fcyRevaluationGroupId int = 0,
        @fcyPaymentGroupId int = 0,
        @fcyMaturationGroupId int = 0;
    declare
        @lcyOpeningGroup1Component1Id int =0,
        @lcyOpeningGroup1Component2Id int =0,
        @lcyOpeningGroup2Component1Id int = 0,
        @lcyOpeningGroup2Component2Id int = 0,
        @lcyRevaluationGroupComponent1Id int = 0,
        @lcyRevaluationGroupComponent2Id int = 0,
        @lcyPaymentGroupComponent1Id int = 0,
        @lcyPaymentGroupComponent2Id int = 0,
        @lcyMaturationGroupComponent1Id int = 0,
        @lcyMaturationGroupComponent2Id int = 0;
    declare
        @fcyOpeningGroup1Component1Id int =0,
        @fcyOpeningGroup1Component2Id int =0,
        @fcyOpeningGroup2Component1Id int = 0,
        @fcyOpeningGroup2Component2Id int = 0,
        @fcyRevaluationGroupComponent1Id int = 0,
        @fcyRevaluationGroupComponent2Id int = 0,
        @fcyPaymentGroupComponent1Id int = 0,
        @fcyPaymentGroupComponent2Id int = 0,
        @fcyMaturationGroupComponent1Id int = 0,
        @fcyMaturationGroupComponent2Id int = 0;
    declare
        @dynamicRuleValueDateLessThanOrEqualLogicalDateId int = 0,
        @dynamicRuleValueDateGreaterThanLogicalDateId int = 0,
        @dynamicRulePayForeignCurrencyId int = 0,
        @dynamicRulePayLocalCurrencyId int = 0,
        @dynamicRuleReceiveForeignCurrencyId int = 0,
        @dynamicRuleReceiveLocalCurrencyId int = 0,
        @dynamicRuleValueDateGreaterThanTradeDateId int = 0,
        @dynamicRuleValueDateLessThanOrEqualTradeDateId int = 0,
        @dynamicRuleMaturityDateEqualsLogicalDateId int = 0,
        @dynamicRulePeriodEndDateLogicalDateAndNetPaymentPositiveId int = 0,
        @dynamicRulePeriodEndDateLogicalDateAndNetPaymentNegativeId int = 0,
        @dynamicRuleDerivativeSwapMTMProfitId int = 0,
        @dynamicRuleDerivativeSwapMTMLossId int = 0,
        @dynamicRuleDerivativePortfolioTradeId int = 0;

    ------------------------------------------------------------------------------------------------------------------------
    -- Accounting Engine Number Generation
    ------------------------------------------------------------------------------------------------------------------------
--#region DefNumberGen
    ------------------------------------------------------------------------------------------------------------------------
    -- Accounting Engine Dynamic Rule Last Number
    ------------------------------------------------------------------------------------------------------------------------
--#region AccEngineDynamicRule DefNumberGen
    select @lastAccEngineDynamicRuleId = LastNumber + 1
    from dbo.DefNumberGen
    where EntityColumnType = @accEngineDynamicRuleColumnTypeId
      and Definition = N'AccEngineDynamicRule Id'

    if (@lastAccEngineDynamicRuleId = 0)
        throw 500001, 'AccEngineDynamicRule Last Id Not Found', 1
    --#endregion
    ------------------------------------------------------------------------------------------------------------------------
    -- Accounting Engine Account Rule Last Number
    ------------------------------------------------------------------------------------------------------------------------
--#region AccEngineAccountRule DefNumberGen
    select @lastAccEngineAccountRuleId = LastNumber + 1
    from dbo.DefNumberGen
    where EntityColumnType = @accEngineAccountRuleColumnTypeId
      and Definition = N'AccEngineAccountRule Id'

    if (@lastAccEngineAccountRuleId = 0)
        throw 500001, 'AccEngineAccountRule Last Id Not Found', 1
    --#endregion
    ------------------------------------------------------------------------------------------------------------------------
    -- Accounting Engine Component Last Number
    ------------------------------------------------------------------------------------------------------------------------
--#region AccEngineComponent DefNumberGen
    select @lastAccEngineComponentId = LastNumber + 1
    from dbo.DefNumberGen
    where EntityColumnType = @accEngineComponentColumnTypeId
      and Definition = N'AccEngineComponent Id'

    if (@lastAccEngineComponentId = 0)
        throw 500001, 'AccEngineComponent Last Id Not Found', 1
    --#endregion
    ------------------------------------------------------------------------------------------------------------------------
    -- Accounting Engine Group Last Number
    ------------------------------------------------------------------------------------------------------------------------
--#region AccEngineGroup DefNumberGen
    select @lastAccEngineGroupId = LastNumber + 1
    from dbo.DefNumberGen
    where EntityColumnType = @accEngineGroupColumnTypeId
      and Definition = N'AccEngineGroup Id'

    if (@lastAccEngineGroupId = 0)
        throw 500001, 'AccEngineGroup Last Id Not Found', 1
    --#endregion
    ------------------------------------------------------------------------------------------------------------------------
    -- Accounting Engine Event Last Number
    ------------------------------------------------------------------------------------------------------------------------
--#region AccEngineEvent DefNumberGen
    select @lastAccEngineEventId = LastNumber + 1
    from dbo.DefNumberGen
    where EntityColumnType = @accEngineEventColumnTypeId
      and Definition = N'AccEngineEvent Id'

    if (@lastAccEngineEventId = 0)
        throw 500001, 'AccEngineEvent Last Id Not Found', 1
    --#endregion
    ------------------------------------------------------------------------------------------------------------------------
    -- Accounting Engine Item Last Number
    ------------------------------------------------------------------------------------------------------------------------
--#region AccEngineItem DefNumberGen
    select @lastAccEngineItemId = LastNumber + 1
    from dbo.DefNumberGen
    where EntityColumnType = @accEngineItemColumnTypeId
      and Definition = N'AccEngineItem Id'

    if (@lastAccEngineItemId = 0)
        throw 500001, 'AccEngineItem Last Id Not Found', 1
    --#endregion
    ------------------------------------------------------------------------------------------------------------------------
    -- Accounting Engine Item Code Last Number
    ------------------------------------------------------------------------------------------------------------------------
--#region AccEngineItemCode DefNumberGen
    select @lastAccEngineItemCodeId = LastNumber + 1
    from dbo.DefNumberGen
    where EntityColumnType = @accEngineItemCodeColumnTypeId
      and Definition = N'AccEngineItemCode Id'

    if (@lastAccEngineItemCodeId = 0)
        throw 500001, 'AccEngineItemCode Last Id Not Found', 1
    --#endregion AccEngineItemCode
    ------------------------------------------------------------------------------------------------------------------------
    -- Accounting Engine Item Type Last Number
    ------------------------------------------------------------------------------------------------------------------------
--#region AccEngineItemType DefNumberGen
    select @lastAccEngineItemTypeId = LastNumber + 1
    from dbo.DefNumberGen
    where EntityColumnType = @accEngineItemTypeColumnTypeId
      and Definition = N'AccEngineItemType Id'

    if (@lastAccEngineItemTypeId = 0)
        throw 500001, 'AccEngineItemType Last Id Not Found', 1
    --#endregion
    ------------------------------------------------------------------------------------------------------------------------
    -- Accounting Engine Model Definition Last Number
    ------------------------------------------------------------------------------------------------------------------------
--#region AccEngineModelDefinition DefNumberGen
    select @lastAccEngineModelDefinitionId = LastNumber + 1
    from dbo.DefNumberGen
    where EntityColumnType = @accEngineModelDefinitionColumnTypeId
      and Definition = N'AccEngineModelDefinition Id'

    if (@lastAccEngineModelDefinitionId = 0)
        throw 500001, 'AccEngineModelDefinition Last Id Not Found', 1
    --#endregion
    ------------------------------------------------------------------------------------------------------------------------
    -- Accounting Account Map Last Number
    ------------------------------------------------------------------------------------------------------------------------
--#region AccAccountMap
    select @lastAccAccountMapId = LastNumber + 1
    from dbo.DefNumberGen
    where EntityColumnType = @accAccountMapColumnTypeId
      and Definition = N'AccAccountMap Id'

    if (@lastAccAccountMapId = 0)
        throw 500001, 'AccAccountMap Last Id Not Found', 1
    --#endregion
--#endregion
    ------------------------------------------------------------------------------------------------------------------------
    -- Accounting Engine Account
    ------------------------------------------------------------------------------------------------------------------------
--#region AccEngineAccount
    IF NOT EXISTS (SELECT 1
                   FROM dbo.AccEngineAccount
                   WHERE GLCode = N'38000500')
        BEGIN
            INSERT INTO dbo.AccEngineAccount (GLCode, ApaCode, TurkishDesc, EnglishDesc, CBTDesc, StateId, StateDate,
                                              StateMaker, MainGLCode, Flags, Type)
            VALUES (N'38000500', null, null, null, null, @stateId, @stateDate, @stateMaker, null, null, null);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.AccEngineAccount
                   WHERE GLCode = N'83000000')
        BEGIN
            INSERT INTO dbo.AccEngineAccount (GLCode, ApaCode, TurkishDesc, EnglishDesc, CBTDesc, StateId, StateDate,
                                              StateMaker, MainGLCode, Flags, Type)
            VALUES (N'83000000', null, null, null, null, @stateId, @stateDate, @stateMaker, null, null, null);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.AccEngineAccount
                   WHERE GLCode = N'CapitalGainFCY')
        BEGIN
            INSERT INTO dbo.AccEngineAccount (GLCode, ApaCode, TurkishDesc, EnglishDesc, CBTDesc, StateId, StateDate,
                                              StateMaker, MainGLCode, Flags, Type)
            VALUES (N'CapitalGainFCY', null, @stateMaker, @stateMaker, @stateMaker, @stateId, @stateDate, @stateMaker,
                    null,
                    null, null);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.AccEngineAccount
                   WHERE GLCode = N'CapitalGainLCY')
        BEGIN
            INSERT INTO dbo.AccEngineAccount (GLCode, ApaCode, TurkishDesc, EnglishDesc, CBTDesc, StateId, StateDate,
                                              StateMaker, MainGLCode, Flags, Type)
            VALUES (N'CapitalGainLCY', null, @stateMaker, @stateMaker, @stateMaker, @stateId, @stateDate, @stateMaker,
                    null,
                    null, null);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.AccEngineAccount
                   WHERE GLCode = N'CapitalLossFCY')
        BEGIN
            INSERT INTO dbo.AccEngineAccount (GLCode, ApaCode, TurkishDesc, EnglishDesc, CBTDesc, StateId, StateDate,
                                              StateMaker, MainGLCode, Flags, Type)
            VALUES (N'CapitalLossFCY', null, @stateMaker, @stateMaker, @stateMaker, @stateId, @stateDate, @stateMaker,
                    null,
                    null, null);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.AccEngineAccount
                   WHERE GLCode = N'CapitalLossLCY')
        BEGIN
            INSERT INTO dbo.AccEngineAccount (GLCode, ApaCode, TurkishDesc, EnglishDesc, CBTDesc, StateId, StateDate,
                                              StateMaker, MainGLCode, Flags, Type)
            VALUES (N'CapitalLossLCY', null, @stateMaker, @stateMaker, @stateMaker, @stateId, @stateDate, @stateMaker,
                    null,
                    null, null);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.AccEngineAccount
                   WHERE GLCode = N'FXPositionLCY')
        BEGIN
            INSERT INTO dbo.AccEngineAccount (GLCode, ApaCode, TurkishDesc, EnglishDesc, CBTDesc, StateId, StateDate,
                                              StateMaker, MainGLCode, Flags, Type)
            VALUES (N'FXPositionLCY', null, @stateMaker, @stateMaker, @stateMaker, @stateId, @stateDate, @stateMaker,
                    null,
                    null, null);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.AccEngineAccount
                   WHERE GLCode = N'FXPositionPay')
        BEGIN
            INSERT INTO dbo.AccEngineAccount (GLCode, ApaCode, TurkishDesc, EnglishDesc, CBTDesc, StateId, StateDate,
                                              StateMaker, MainGLCode, Flags, Type)
            VALUES (N'FXPositionPay', null, @stateMaker, @stateMaker, @stateMaker, @stateId, @stateDate, @stateMaker,
                    null,
                    null, null);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.AccEngineAccount
                   WHERE GLCode = N'FXPositionRec')
        BEGIN
            INSERT INTO dbo.AccEngineAccount (GLCode, ApaCode, TurkishDesc, EnglishDesc, CBTDesc, StateId, StateDate,
                                              StateMaker, MainGLCode, Flags, Type)
            VALUES (N'FXPositionRec', null, @stateMaker, @stateMaker, @stateMaker, @stateId, @stateDate, @stateMaker,
                    null,
                    null, null);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.AccEngineAccount
                   WHERE GLCode = N'IncomingPaymentFCY')
        BEGIN
            INSERT INTO dbo.AccEngineAccount (GLCode, ApaCode, TurkishDesc, EnglishDesc, CBTDesc, StateId, StateDate,
                                              StateMaker, MainGLCode, Flags, Type)
            VALUES (N'IncomingPaymentFCY', null,
                    N'Gelen Ödemeler için çalışacak Alias. Geçici yada Kasa hesabı çalışacaktır.', null, null, @stateId,
                    N'2024-12-20 10:32:28.557', @stateMaker, null, null, null);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.AccEngineAccount
                   WHERE GLCode = N'IncomingPaymentLCY')
        BEGIN
            INSERT INTO dbo.AccEngineAccount (GLCode, ApaCode, TurkishDesc, EnglishDesc, CBTDesc, StateId, StateDate,
                                              StateMaker, MainGLCode, Flags, Type)
            VALUES (N'IncomingPaymentLCY', null,
                    N'Gelen Ödemeler için çalıştırılacak Alias. Geçici yada kasa hesabı dönecektir.',
                    N'IncomingPaymentLCY',
                    null, @stateId, N'2024-12-20 10:32:30.297', @stateMaker, null, null, null);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.AccEngineAccount
                   WHERE GLCode = N'InterestExpense')
        BEGIN
            INSERT INTO dbo.AccEngineAccount (GLCode, ApaCode, TurkishDesc, EnglishDesc, CBTDesc, StateId, StateDate,
                                              StateMaker, MainGLCode, Flags, Type)
            VALUES (N'InterestExpense', null, @stateMaker, @stateMaker, @stateMaker, @stateId, @stateDate, @stateMaker,
                    null, null, null);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.AccEngineAccount
                   WHERE GLCode = N'InterestIncome')
        BEGIN
            INSERT INTO dbo.AccEngineAccount (GLCode, ApaCode, TurkishDesc, EnglishDesc, CBTDesc, StateId, StateDate,
                                              StateMaker, MainGLCode, Flags, Type)
            VALUES (N'InterestIncome', null, @stateMaker, @stateMaker, @stateMaker, @stateId, @stateDate, @stateMaker,
                    null,
                    null, null);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.AccEngineAccount
                   WHERE GLCode = N'MatPayContingent')
        BEGIN
            INSERT INTO dbo.AccEngineAccount (GLCode, ApaCode, TurkishDesc, EnglishDesc, CBTDesc, StateId, StateDate,
                                              StateMaker, MainGLCode, Flags, Type)
            VALUES (N'MatPayContingent', null, N'SWAP PARA ALIM İŞLEMLERİ BORÇLAR- DÖVİZ-DÖVİZ', null, null, @stateId,
                    @stateDate, @stateMaker, null, null, null);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.AccEngineAccount
                   WHERE GLCode = N'MatPayContingentOffset')
        BEGIN
            INSERT INTO dbo.AccEngineAccount (GLCode, ApaCode, TurkishDesc, EnglishDesc, CBTDesc, StateId, StateDate,
                                              StateMaker, MainGLCode, Flags, Type)
            VALUES (N'MatPayContingentOffset', null, N'SWAP PARA ALIM İŞLEMLERİ ALACAKLAR - DÖVİZ - DÖVİZ', null, null,
                    @stateId, @stateDate, @stateMaker, null, null, null);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.AccEngineAccount
                   WHERE GLCode = N'MatRecContingent')
        BEGIN
            INSERT INTO dbo.AccEngineAccount (GLCode, ApaCode, TurkishDesc, EnglishDesc, CBTDesc, StateId, StateDate,
                                              StateMaker, MainGLCode, Flags, Type)
            VALUES (N'MatRecContingent', null, N'SWAP PARA ALIM İŞLEMLERİ ALACAKLAR - DÖVİZ - DÖVİZ', null, null,
                    @stateId,
                    @stateDate, @stateMaker, null, null, null);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.AccEngineAccount
                   WHERE GLCode = N'MatRecContingentOffset')
        BEGIN
            INSERT INTO dbo.AccEngineAccount (GLCode, ApaCode, TurkishDesc, EnglishDesc, CBTDesc, StateId, StateDate,
                                              StateMaker, MainGLCode, Flags, Type)
            VALUES (N'MatRecContingentOffset', null, N'SWAP PARA ALIM İŞLEMLERİ BORÇLAR- DÖVİZ-DÖVİZ', null, null,
                    @stateId,
                    @stateDate, @stateMaker, null, null, null);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.AccEngineAccount
                   WHERE GLCode = N'OutgoingPaymentFCY')
        BEGIN
            INSERT INTO dbo.AccEngineAccount (GLCode, ApaCode, TurkishDesc, EnglishDesc, CBTDesc, StateId, StateDate,
                                              StateMaker, MainGLCode, Flags, Type)
            VALUES (N'OutgoingPaymentFCY', null,
                    N'Giden ödemeler için çalışacak Alias. Geçici yada Kasa Hesabı çalışacaktır.', null, null, @stateId,
                    N'2024-12-20 10:32:31.547', @stateMaker, null, null, null);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.AccEngineAccount
                   WHERE GLCode = N'OutgoingPaymentLCY')
        BEGIN
            INSERT INTO dbo.AccEngineAccount (GLCode, ApaCode, TurkishDesc, EnglishDesc, CBTDesc, StateId, StateDate,
                                              StateMaker, MainGLCode, Flags, Type)
            VALUES (N'OutgoingPaymentLCY', null,
                    N'Giden ödemeler için çalışacak Alias. Geçici yada Kasa Hesabı çalışacaktır.', null, null, @stateId,
                    N'2024-12-20 10:32:32.810', @stateMaker, null, null, null);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.AccEngineAccount
                   WHERE GLCode = N'TotalMTMLoss')
        BEGIN
            INSERT INTO dbo.AccEngineAccount (GLCode, ApaCode, TurkishDesc, EnglishDesc, CBTDesc, StateId, StateDate,
                                              StateMaker, MainGLCode, Flags, Type)
            VALUES (N'TotalMTMLoss', null, N'Derivative Swap', N'Derivative Swap', null, @stateId, @stateDate,
                    @stateMaker,
                    null, null, null);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.AccEngineAccount
                   WHERE GLCode = N'TotalMTMProfit')
        BEGIN
            INSERT INTO dbo.AccEngineAccount (GLCode, ApaCode, TurkishDesc, EnglishDesc, CBTDesc, StateId, StateDate,
                                              StateMaker, MainGLCode, Flags, Type)
            VALUES (N'TotalMTMProfit', null, N'Derivative Swap', N'Derivative Swap', null, @stateId, @stateDate,
                    @stateMaker, null, null, null);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.AccEngineAccount
                   WHERE GLCode = N'ValPayContingent')
        BEGIN
            INSERT INTO dbo.AccEngineAccount (GLCode, ApaCode, TurkishDesc, EnglishDesc, CBTDesc, StateId, StateDate,
                                              StateMaker, MainGLCode, Flags, Type)
            VALUES (N'ValPayContingent', null, N'SWAP PARA ALIM İŞLEMLERİ ALACAKLAR - DÖVİZ - DÖVİZ', null, null,
                    @stateId,
                    @stateDate, @stateMaker, null, null, null);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.AccEngineAccount
                   WHERE GLCode = N'ValPayContingentOffset')
        BEGIN
            INSERT INTO dbo.AccEngineAccount (GLCode, ApaCode, TurkishDesc, EnglishDesc, CBTDesc, StateId, StateDate,
                                              StateMaker, MainGLCode, Flags, Type)
            VALUES (N'ValPayContingentOffset', null, N'SWAP PARA ALIM İŞLEMLERİ BORÇLAR- DÖVİZ-DÖVİZ', null, null,
                    @stateId,
                    @stateDate, @stateMaker, null, null, null);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.AccEngineAccount
                   WHERE GLCode = N'ValRecContingent')
        BEGIN
            INSERT INTO dbo.AccEngineAccount (GLCode, ApaCode, TurkishDesc, EnglishDesc, CBTDesc, StateId, StateDate,
                                              StateMaker, MainGLCode, Flags, Type)
            VALUES (N'ValRecContingent', null, N'SWAP PARA ALIM İŞLEMLERİ BORÇLAR- DÖVİZ-DÖVİZ', null, null, @stateId,
                    @stateDate, @stateMaker, null, null, null);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.AccEngineAccount
                   WHERE GLCode = N'ValRecContingentOffset')
        BEGIN
            INSERT INTO dbo.AccEngineAccount (GLCode, ApaCode, TurkishDesc, EnglishDesc, CBTDesc, StateId, StateDate,
                                              StateMaker, MainGLCode, Flags, Type)
            VALUES (N'ValRecContingentOffset', null, N'SWAP PARA ALIM İŞLEMLERİ ALACAKLAR - DÖVİZ - DÖVİZ', null, null,
                    @stateId, @stateDate, @stateMaker, null, null, null);
        END;
    --#endregion
    ------------------------------------------------------------------------------------------------------------------------
    -- Accounting Engine Number Generation
    ------------------------------------------------------------------------------------------------------------------------
--#region AccEngineComponentType

    IF NOT EXISTS (SELECT 1
                   FROM dbo.AccEngineComponentType
                   WHERE Name = N'BITT Tax'
                     AND Code = N'110')
        BEGIN
            INSERT INTO dbo.AccEngineComponentType (Name, Code, StateId, StateDate, StateMaker)
            VALUES (N'BITT Tax', N'110', @stateId, @stateDate, @stateDate);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.AccEngineComponentType
                   WHERE Name = N'Value Date Contingent'
                     AND Code = N'500')
        BEGIN
            INSERT INTO dbo.AccEngineComponentType (Name, Code, StateId, StateDate, StateMaker)
            VALUES (N'Value Date Contingent', N'500', @stateId, @stateDate, @stateMaker);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.AccEngineComponentType
                   WHERE Name = N'Maturity Date Contingent'
                     AND Code = N'501')
        BEGIN
            INSERT INTO dbo.AccEngineComponentType (Name, Code, StateId, StateDate, StateMaker)
            VALUES (N'Maturity Date Contingent', N'501', @stateId, @stateDate, @stateMaker);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.AccEngineComponentType
                   WHERE Name = N'Cashflow Payment Incoming'
                     AND Code = N'506')
        BEGIN
            INSERT INTO dbo.AccEngineComponentType (Name, Code, StateId, StateDate, StateMaker)
            VALUES (N'Cashflow Payment Incoming', N'506', @stateId, @stateDate, @stateMaker);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.AccEngineComponentType
                   WHERE Name = N'Cashflow Payment Outgoing'
                     AND Code = N'507')
        BEGIN
            INSERT INTO dbo.AccEngineComponentType (Name, Code, StateId, StateDate, StateMaker)
            VALUES (N'Cashflow Payment Outgoing', N'507', @stateId, @stateDate, @stateMaker);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.AccEngineComponentType
                   WHERE Name = N'Revaluation MTM Profit'
                     AND Code = N'508')
        BEGIN
            INSERT INTO dbo.AccEngineComponentType (Name, Code, StateId, StateDate, StateMaker)
            VALUES (N'Revaluation MTM Profit', N'508', @stateId, @stateDate, @stateMaker);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.AccEngineComponentType
                   WHERE Name = N'Revaluation MTM Loss'
                     AND Code = N'509')
        BEGIN
            INSERT INTO dbo.AccEngineComponentType (Name, Code, StateId, StateDate, StateMaker)
            VALUES (N'Revaluation MTM Loss', N'509', @stateId, @stateDate, @stateMaker);
        END;

    --#endregion
    ------------------------------------------------------------------------------------------------------------------------
    -- Accounting Engine Model Definition
    ------------------------------------------------------------------------------------------------------------------------
--#region AccEngineModelDefinition

    if not exists(select 1
                  from dbo.accEngineModelDefinition
                  where Name = N'Derivative Swap')
        begin
            INSERT INTO dbo.AccEngineModelDefinition (Id, [Schema], Name, StateId, StateDate, StateMaker)
            OUTPUT INSERTED.Id INTO @tempTable
            VALUES (@lastAccEngineModelDefinitionId,
                    N'{"title":"DerivSWPAccountingModel","type":"object","properties":{"NetPeriodEndAmount":{"title":"Net Period End Amount","type":"number"},"NetPeriodEndAmountLCY":{"title":"Net Period End Amount LCY","type":"number"},"ReceivePeriodAmount":{"title":"Receive Period End Amount","type":"number"},"ReceivePeriodAmountLCY":{"title":"Receive Period End Amount LCY","type":"number"},"PayPeriodAmount":{"title":"Pay Period End Amount","type":"number"},"PayPeriodAmountLCY":{"title":"Pay Period End Amount LCY","type":"number"},"ReceivePrincipalAmount":{"title":"Receive Amount","type":["number","null"]},"PayPrincipalAmount":{"title":"Pay Amount","type":["number","null"]},"TotalMTMAmount":{"title":"MTM Amount","type":["number","null"]},"TotalMTMAmountCCY":{"title":"MTM Amount CCY","type":["string","null"]},"TotalMTMAmountLCY":{"title":"MTM Amount LCY","type":["number","null"]},"TotalMTMAmountLCYCode":{"title":"MTM Amount LCY Code","type":["string","null"]},"WeakAmountLCY":{"title":"Weak Amount LCY","type":["number","null"]},"WeakAmountCCY":{"title":"Weak Amount CCY","type":["string","null"]},"TaxAmount":{"title":"Tax Amount","type":"number"},"PayCurrency":{"title":"Pay Currency","type":["string","null"]},"ReceiveCurrency":{"title":"Receive Currency","type":["string","null"]},"LocalCCY":{"title":"Local CCY","type":["string","null"]},"LogicalDate":{"title":"Logical Date","type":"string","format":"date-time"},"NextWorkingLogicalDate":{"title":"Next Working Logical Date","type":"string","format":"date-time"},"PreviousWorkingLogicalDate":{"title":"Previous Working Logical Date","type":"string","format":"date-time"},"ExternalCustomerId":{"title":"External Customer Id","type":["string","null"]},"TxnReference":{"title":"Transaction Reference","description":"Transaction String Reference","type":["string","null"]},"TxnNo":{"title":"Transaction Number","type":"integer"},"AccountingGenerationDate":{"title":"Accounting Generation Date","type":"string","format":"date-time"},"Comment":{"title":"Comment","type":["string","null"]},"ApplicationName":{"title":"Application Name","type":["string","null"]},"TemplateId":{"title":"Template Id","type":"integer"},"PathRuleId":{"title":"Path Rule Id","type":"integer"}},"required":["NetPeriodEndAmount","NetPeriodEndAmountLCY","ReceivePeriodAmount","ReceivePeriodAmountLCY","PayPeriodAmount","PayPeriodAmountLCY","ReceivePrincipalAmount","PayPrincipalAmount","TotalMTMAmount","TotalMTMAmountCCY","TotalMTMAmountLCY","TotalMTMAmountLCYCode","WeakAmountLCY","WeakAmountCCY","TaxAmount","PayCurrency","ReceiveCurrency","LocalCCY","LogicalDate","NextWorkingLogicalDate","PreviousWorkingLogicalDate","ExternalCustomerId","TxnReference","TxnNo","AccountingGenerationDate","Comment","ApplicationName","TemplateId","PathRuleId"]}',
                    N'Derivative Swap', @StateId, @stateDate, @stateMaker);
            SELECT @lastAccEngineModelDefinitionId = Id FROM @tempTable;
            delete from @tempTable
        end
    else
        begin
            UPDATE dbo.AccEngineModelDefinition
            SET [Schema]   = N'{"title":"DerivSWPAccountingModel","type":"object","properties":{"NetPeriodEndAmount":{"title":"Net Period End Amount","type":"number"},"NetPeriodEndAmountLCY":{"title":"Net Period End Amount LCY","type":"number"},"ReceivePeriodAmount":{"title":"Receive Period End Amount","type":"number"},"ReceivePeriodAmountLCY":{"title":"Receive Period End Amount LCY","type":"number"},"PayPeriodAmount":{"title":"Pay Period End Amount","type":"number"},"PayPeriodAmountLCY":{"title":"Pay Period End Amount LCY","type":"number"},"ReceivePrincipalAmount":{"title":"Receive Amount","type":["number","null"]},"PayPrincipalAmount":{"title":"Pay Amount","type":["number","null"]},"TotalMTMAmount":{"title":"MTM Amount","type":["number","null"]},"TotalMTMAmountCCY":{"title":"MTM Amount CCY","type":["string","null"]},"TotalMTMAmountLCY":{"title":"MTM Amount LCY","type":["number","null"]},"TotalMTMAmountLCYCode":{"title":"MTM Amount LCY Code","type":["string","null"]},"WeakAmountLCY":{"title":"Weak Amount LCY","type":["number","null"]},"WeakAmountCCY":{"title":"Weak Amount CCY","type":["string","null"]},"TaxAmount":{"title":"Tax Amount","type":"number"},"PayCurrency":{"title":"Pay Currency","type":["string","null"]},"ReceiveCurrency":{"title":"Receive Currency","type":["string","null"]},"LocalCCY":{"title":"Local CCY","type":["string","null"]},"LogicalDate":{"title":"Logical Date","type":"string","format":"date-time"},"NextWorkingLogicalDate":{"title":"Next Working Logical Date","type":"string","format":"date-time"},"PreviousWorkingLogicalDate":{"title":"Previous Working Logical Date","type":"string","format":"date-time"},"ExternalCustomerId":{"title":"External Customer Id","type":["string","null"]},"TxnReference":{"title":"Transaction Reference","description":"Transaction String Reference","type":["string","null"]},"TxnNo":{"title":"Transaction Number","type":"integer"},"AccountingGenerationDate":{"title":"Accounting Generation Date","type":"string","format":"date-time"},"Comment":{"title":"Comment","type":["string","null"]},"ApplicationName":{"title":"Application Name","type":["string","null"]},"TemplateId":{"title":"Template Id","type":"integer"},"PathRuleId":{"title":"Path Rule Id","type":"integer"}},"required":["NetPeriodEndAmount","NetPeriodEndAmountLCY","ReceivePeriodAmount","ReceivePeriodAmountLCY","PayPeriodAmount","PayPeriodAmountLCY","ReceivePrincipalAmount","PayPrincipalAmount","TotalMTMAmount","TotalMTMAmountCCY","TotalMTMAmountLCY","TotalMTMAmountLCYCode","WeakAmountLCY","WeakAmountCCY","TaxAmount","PayCurrency","ReceiveCurrency","LocalCCY","LogicalDate","NextWorkingLogicalDate","PreviousWorkingLogicalDate","ExternalCustomerId","TxnReference","TxnNo","AccountingGenerationDate","Comment","ApplicationName","TemplateId","PathRuleId"]}',
                StateId    = 26,
                StateDate  = @stateDate,
                StateMaker = @stateMaker
            OUTPUT INSERTED.Id INTO @tempTable
            WHERE Name = N'Derivative Swap';
            SELECT @lastAccEngineModelDefinitionId = Id FROM @tempTable;
            delete from @tempTable
        end

    --#endregion
    ------------------------------------------------------------------------------------------------------------------------
    -- Accounting Engine Dynamic Rule
    ------------------------------------------------------------------------------------------------------------------------
--#region AccEngineDynamicRule

    IF NOT EXISTS (SELECT 1
                   FROM dbo.AccEngineDynamicRule
                   WHERE [Rule] = N'TxnModel.ReceiveValueDate.getTime() <= TxnModel.LogicalDate.getTime()')
        BEGIN
            INSERT INTO dbo.AccEngineDynamicRule (Id, Name, [Rule], Type, Description, StateId, StateDate, StateMaker)
            output inserted.Id into @tempTable
            VALUES (@lastAccEngineDynamicRuleId, N'ValueDate <= LogicalDate',
                    N'TxnModel.ReceiveValueDate.getTime() <= TxnModel.LogicalDate.getTime()', 0, N'', @stateId,
                    @stateDate,
                    @stateMaker);
            SELECT @dynamicRuleValueDateLessThanOrEqualLogicalDateId = Id FROM @tempTable;
            delete from @tempTable
            select @lastAccEngineDynamicRuleId = @lastAccEngineDynamicRuleId + 1
        END;
    else
        begin
            select @dynamicRuleValueDateLessThanOrEqualLogicalDateId = Id
            from dbo.AccEngineDynamicRule
            WHERE [Rule] = N'TxnModel.ReceiveValueDate.getTime() <= TxnModel.LogicalDate.getTime()'
        end

    IF NOT EXISTS (SELECT 1
                   FROM dbo.AccEngineDynamicRule
                   WHERE [Rule] = N'TxnModel.ReceiveValueDate.getTime() > TxnModel.LogicalDate.getTime()')
        BEGIN
            INSERT INTO dbo.AccEngineDynamicRule (Id, Name, [Rule], Type, Description, StateId, StateDate, StateMaker)
            output inserted.Id into @tempTable
            VALUES (@lastAccEngineDynamicRuleId, N'ValueDate > LogicalDate',
                    N'TxnModel.ReceiveValueDate.getTime() > TxnModel.LogicalDate.getTime()', 0, N'', @stateId,
                    @stateDate,
                    @stateMaker);
            SELECT @dynamicRuleValueDateGreaterThanLogicalDateId = Id FROM @tempTable;
            delete from @tempTable
            select @lastAccEngineDynamicRuleId = @lastAccEngineDynamicRuleId + 1
        END;
    else
        begin
            select @dynamicRuleValueDateGreaterThanLogicalDateId = Id
            from dbo.AccEngineDynamicRule
            WHERE [Rule] = N'TxnModel.ReceiveValueDate.getTime() > TxnModel.LogicalDate.getTime()'
        end

    IF NOT EXISTS (SELECT 1
                   FROM dbo.AccEngineDynamicRule
                   WHERE [Rule] = N'TxnModel.PayCurrency !== TxnModel.LocalCCY')
        BEGIN
            INSERT INTO dbo.AccEngineDynamicRule (Id, Name, [Rule], Type, Description, StateId, StateDate, StateMaker)
            output inserted.Id into @tempTable
            VALUES (@lastAccEngineDynamicRuleId, N'Pay Foreign Currency', N'TxnModel.PayCurrency !== TxnModel.LocalCCY',
                    0,
                    N'', @stateId,
                    @stateDate, @stateMaker);
            SELECT @dynamicRulePayForeignCurrencyId = Id FROM @tempTable;
            delete from @tempTable
            select @lastAccEngineDynamicRuleId = @lastAccEngineDynamicRuleId + 1
        END;
    else
        begin
            select @dynamicRulePayForeignCurrencyId = Id
            from dbo.AccEngineDynamicRule
            WHERE [Rule] = N'TxnModel.PayCurrency !== TxnModel.LocalCCY'
        end

    IF NOT EXISTS (SELECT 1
                   FROM dbo.AccEngineDynamicRule
                   WHERE [Rule] = N'TxnModel.PayCurrency === TxnModel.LocalCCY')
        BEGIN
            INSERT INTO dbo.AccEngineDynamicRule (Id, Name, [Rule], Type, Description, StateId, StateDate, StateMaker)
            output inserted.Id into @tempTable
            VALUES (@lastAccEngineDynamicRuleId, N'Pay Local Currency', N'TxnModel.PayCurrency === TxnModel.LocalCCY',
                    0,
                    N'', @stateId,
                    @stateDate, @stateMaker);
            SELECT @dynamicRulePayLocalCurrencyId = Id FROM @tempTable;
            delete from @tempTable
            select @lastAccEngineDynamicRuleId = @lastAccEngineDynamicRuleId + 1
        END;
    else
        begin
            select @dynamicRulePayLocalCurrencyId = Id
            from dbo.AccEngineDynamicRule
            WHERE [Rule] = N'TxnModel.PayCurrency === TxnModel.LocalCCY'
        end

    IF NOT EXISTS (SELECT 1
                   FROM dbo.AccEngineDynamicRule
                   WHERE [Rule] = N'TxnModel.ReceiveCurrency !== TxnModel.LocalCCY')
        BEGIN
            INSERT INTO dbo.AccEngineDynamicRule (Id, Name, [Rule], Type, Description, StateId, StateDate, StateMaker)
            output inserted.Id into @tempTable
            VALUES (@lastAccEngineDynamicRuleId, N'Receive Foreign Currency',
                    N'TxnModel.ReceiveCurrency !== TxnModel.LocalCCY', 0, N'', @stateId,
                    @stateDate, @stateMaker);
            SELECT @dynamicRuleReceiveForeignCurrencyId = Id FROM @tempTable;
            delete from @tempTable
            select @lastAccEngineDynamicRuleId = @lastAccEngineDynamicRuleId + 1
        END;
    else
        begin
            select @dynamicRuleReceiveForeignCurrencyId = Id
            from dbo.AccEngineDynamicRule
            WHERE [Rule] = N'TxnModel.ReceiveCurrency !== TxnModel.LocalCCY'
        end

    IF NOT EXISTS (SELECT 1
                   FROM dbo.AccEngineDynamicRule
                   WHERE [Rule] = N'TxnModel.ReceiveCurrency === TxnModel.LocalCCY')
        BEGIN
            INSERT INTO dbo.AccEngineDynamicRule (Id, Name, [Rule], Type, Description, StateId, StateDate, StateMaker)
            output inserted.Id into @tempTable
            VALUES (@lastAccEngineDynamicRuleId, N'Receive Local Currency',
                    N'TxnModel.ReceiveCurrency === TxnModel.LocalCCY', 0, N'', @stateId,
                    @stateDate, @stateMaker);
            SELECT @dynamicRuleReceiveLocalCurrencyId = Id FROM @tempTable;
            delete from @tempTable
            select @lastAccEngineDynamicRuleId = @lastAccEngineDynamicRuleId + 1
        END;
    else
        begin
            select @dynamicRuleReceiveLocalCurrencyId = Id
            from dbo.AccEngineDynamicRule
            WHERE [Rule] = N'TxnModel.ReceiveCurrency === TxnModel.LocalCCY'
        end

    IF NOT EXISTS (SELECT 1
                   FROM dbo.AccEngineDynamicRule
                   WHERE [Rule] = N'TxnModel.ReceiveValueDate.getTime() > TxnModel.TradeDate.getTime()')
        BEGIN
            INSERT INTO dbo.AccEngineDynamicRule (Id, Name, [Rule], Type, Description, StateId, StateDate, StateMaker)
            output inserted.Id into @tempTable
            VALUES (@lastAccEngineDynamicRuleId, N'ValueDate > TradeDate',
                    N'TxnModel.ReceiveValueDate.getTime() > TxnModel.TradeDate.getTime()',
                    0, N'', @stateId, @stateDate, @stateMaker);
            SELECT @dynamicRuleValueDateGreaterThanTradeDateId = Id FROM @tempTable;
            delete from @tempTable
            select @lastAccEngineDynamicRuleId = @lastAccEngineDynamicRuleId + 1
        END;
    else
        begin
            select @dynamicRuleValueDateGreaterThanTradeDateId = Id
            from dbo.AccEngineDynamicRule
            WHERE [Rule] = N'TxnModel.ReceiveValueDate.getTime() > TxnModel.TradeDate.getTime()'
        end

    IF NOT EXISTS (SELECT 1
                   FROM dbo.AccEngineDynamicRule
                   WHERE [Rule] = N'TxnModel.ReceiveValueDate.getTime() <= TxnModel.TradeDate.getTime()')
        BEGIN
            INSERT INTO dbo.AccEngineDynamicRule (Id, Name, [Rule], Type, Description, StateId, StateDate, StateMaker)
            output inserted.Id into @tempTable
            VALUES (@lastAccEngineDynamicRuleId, N'ValueDate <= TradeDate',
                    N'TxnModel.ReceiveValueDate.getTime() <= TxnModel.TradeDate.getTime()',
                    0, N'', @stateId, @stateDate, @stateMaker);
            SELECT @dynamicRuleValueDateLessThanOrEqualTradeDateId = Id FROM @tempTable;
            delete from @tempTable
            select @lastAccEngineDynamicRuleId = @lastAccEngineDynamicRuleId + 1
        END;
    else
        begin
            select @dynamicRuleValueDateLessThanOrEqualTradeDateId = Id
            from dbo.AccEngineDynamicRule
            WHERE [Rule] = N'TxnModel.ReceiveValueDate.getTime() <= TxnModel.TradeDate.getTime()'
        end

    IF NOT EXISTS (SELECT 1
                   FROM dbo.AccEngineDynamicRule
                   WHERE [Rule] = N'TxnModel.ReceiveMaturityDate.getTime() === TxnModel.LogicalDate.getTime()')
        BEGIN
            INSERT INTO dbo.AccEngineDynamicRule (Id, Name, [Rule], Type, Description, StateId, StateDate, StateMaker)
            output inserted.Id into @tempTable
            VALUES (@lastAccEngineDynamicRuleId, N'MaturityDate = LogicalDate',
                    N'TxnModel.ReceiveMaturityDate.getTime() === TxnModel.LogicalDate.getTime()', 0, N'', @stateId,
                    @stateDate, @stateMaker);
            SELECT @dynamicRuleMaturityDateEqualsLogicalDateId = Id FROM @tempTable;
            delete from @tempTable
            select @lastAccEngineDynamicRuleId = @lastAccEngineDynamicRuleId + 1
        END;
    else
        begin
            select @dynamicRuleMaturityDateEqualsLogicalDateId = Id
            from dbo.AccEngineDynamicRule
            WHERE [Rule] = N'TxnModel.ReceiveMaturityDate.getTime() === TxnModel.LogicalDate.getTime()'
        end

    IF NOT EXISTS (SELECT 1
                   FROM dbo.AccEngineDynamicRule
                   WHERE [Rule] =
                         N'((TxnModel.ReceivePeriodEndDate !== null ? TxnModel.ReceivePeriodEndDate.getTime() === TxnModel.LogicalDate.getTime() : false) || (TxnModel.PayPeriodEndDate !== null ? TxnModel.PayPeriodEndDate.getTime() === TxnModel.LogicalDate.getTime() : false)) && TxnModel.NetPeriodEndAmount > 0')
        BEGIN
            INSERT INTO dbo.AccEngineDynamicRule (Id, Name, [Rule], Type, Description, StateId, StateDate, StateMaker)
            output inserted.Id into @tempTable
            VALUES (@lastAccEngineDynamicRuleId, N'PeriodEndDate = LogicalDate && NetPayment > 0',
                    N'((TxnModel.ReceivePeriodEndDate !== null ? TxnModel.ReceivePeriodEndDate.getTime() === TxnModel.LogicalDate.getTime() : false) || (TxnModel.PayPeriodEndDate !== null ? TxnModel.PayPeriodEndDate.getTime() === TxnModel.LogicalDate.getTime() : false)) && TxnModel.NetPeriodEndAmount > 0',
                    0, N'', @stateId, @stateDate, @stateMaker);
            SELECT @dynamicRulePeriodEndDateLogicalDateAndNetPaymentPositiveId = Id FROM @tempTable;
            delete from @tempTable
            select @lastAccEngineDynamicRuleId = @lastAccEngineDynamicRuleId + 1
        END;
    else
        begin
            select @dynamicRulePeriodEndDateLogicalDateAndNetPaymentPositiveId = Id
            from dbo.AccEngineDynamicRule
            WHERE [Rule] =
                  N'((TxnModel.ReceivePeriodEndDate !== null ? TxnModel.ReceivePeriodEndDate.getTime() === TxnModel.LogicalDate.getTime() : false) || (TxnModel.PayPeriodEndDate !== null ? TxnModel.PayPeriodEndDate.getTime() === TxnModel.LogicalDate.getTime() : false)) && TxnModel.NetPeriodEndAmount > 0'
        end

    IF NOT EXISTS (SELECT 1
                   FROM dbo.AccEngineDynamicRule
                   WHERE [Rule] =
                         N'((TxnModel.ReceivePeriodEndDate !== null ? TxnModel.ReceivePeriodEndDate.getTime() === TxnModel.LogicalDate.getTime() : false) || (TxnModel.PayPeriodEndDate !== null ? TxnModel.PayPeriodEndDate.getTime() === TxnModel.LogicalDate.getTime() : false)) && TxnModel.NetPeriodEndAmount < 0')
        BEGIN
            INSERT INTO dbo.AccEngineDynamicRule (Id, Name, [Rule], Type, Description, StateId, StateDate, StateMaker)
            output inserted.Id into @tempTable
            VALUES (@lastAccEngineDynamicRuleId, N'PeriodEndDate = LogicalDate && NetPayment < 0',
                    N'((TxnModel.ReceivePeriodEndDate !== null ? TxnModel.ReceivePeriodEndDate.getTime() === TxnModel.LogicalDate.getTime() : false) || (TxnModel.PayPeriodEndDate !== null ? TxnModel.PayPeriodEndDate.getTime() === TxnModel.LogicalDate.getTime() : false)) && TxnModel.NetPeriodEndAmount < 0',
                    0, N'', @stateId, @stateDate, @stateMaker);
            SELECT @dynamicRulePeriodEndDateLogicalDateAndNetPaymentNegativeId = Id FROM @tempTable;
            delete from @tempTable
            select @lastAccEngineDynamicRuleId = @lastAccEngineDynamicRuleId + 1
        END;
    else
        begin
            select @dynamicRulePeriodEndDateLogicalDateAndNetPaymentNegativeId = Id
            from dbo.AccEngineDynamicRule
            WHERE [Rule] =
                  N'((TxnModel.ReceivePeriodEndDate !== null ? TxnModel.ReceivePeriodEndDate.getTime() === TxnModel.LogicalDate.getTime() : false) || (TxnModel.PayPeriodEndDate !== null ? TxnModel.PayPeriodEndDate.getTime() === TxnModel.LogicalDate.getTime() : false)) && TxnModel.NetPeriodEndAmount < 0'
        end

    IF NOT EXISTS (SELECT 1
                   FROM dbo.AccEngineDynamicRule
                   WHERE [Rule] = N'TxnModel.TotalMTMAmount >= 0')
        BEGIN
            INSERT INTO dbo.AccEngineDynamicRule (Id, Name, [Rule], Type, Description, StateId, StateDate, StateMaker)
            output inserted.Id into @tempTable
            VALUES (@lastAccEngineDynamicRuleId, N'Derivative Swap MTM Profit', N'TxnModel.TotalMTMAmount >= 0', 0, N'',
                    @stateId, @stateDate,
                    @stateMaker);
            SELECT @dynamicRuleDerivativeSwapMTMProfitId = Id FROM @tempTable;
            delete from @tempTable
            select @lastAccEngineDynamicRuleId = @lastAccEngineDynamicRuleId + 1
        END;
    else
        begin
            select @dynamicRuleDerivativeSwapMTMProfitId = Id
            from dbo.AccEngineDynamicRule
            WHERE [Rule] = N'TxnModel.TotalMTMAmount >= 0'
        end

    IF NOT EXISTS (SELECT 1
                   FROM dbo.AccEngineDynamicRule
                   WHERE Name = N'Derivatives Portfolio = Trade'
                     AND [Rule] = N'1===1')
        BEGIN
            INSERT INTO dbo.AccEngineDynamicRule (Id, Name, [Rule], Type, Description, StateId, StateDate, StateMaker)
            output inserted.Id into @tempTable
            VALUES (@lastAccEngineDynamicRuleId, N'Derivatives Portfolio = Trade',
                    N'1===1', 0, N'', @stateId,
                    @stateDate, @stateMaker);
            SELECT @dynamicRuleDerivativePortfolioTradeId = Id FROM @tempTable;
            delete from @tempTable
            select @lastAccEngineDynamicRuleId = @lastAccEngineDynamicRuleId + 1
        END;
    else
        begin
            select @dynamicRuleDerivativePortfolioTradeId = Id
            from dbo.AccEngineDynamicRule
            WHERE Name = N'Derivatives Portfolio = Trade'
              AND [Rule] = N'1===1'
        end

    IF NOT EXISTS (SELECT 1
                   FROM dbo.AccEngineDynamicRule
                   WHERE [Rule] = N'TxnModel.TotalMTMAmount < 0')
        BEGIN
            INSERT INTO dbo.AccEngineDynamicRule (Id, Name, [Rule], Type, Description, StateId, StateDate, StateMaker)
            output inserted.Id into @tempTable
            VALUES (@lastAccEngineDynamicRuleId, N'Derivative Swap MTM Loss', N'TxnModel.TotalMTMAmount < 0', 0, N'',
                    @stateId, @stateDate,
                    @stateMaker);
            SELECT @dynamicRuleDerivativeSwapMTMLossId = Id FROM @tempTable;
            delete from @tempTable
        END;
    else
        begin
            select @dynamicRuleDerivativeSwapMTMLossId = Id
            from dbo.AccEngineDynamicRule
            WHERE [Rule] = N'TxnModel.TotalMTMAmount < 0'
        end
    --#endregion
    ------------------------------------------------------------------------------------------------------------------------
    -- Accounting Engine Item Type
    ------------------------------------------------------------------------------------------------------------------------
--#region AccEngineItemType
    if not exists(select 1
                  from dbo.AccEngineItemType
                  where Code = N'Prd')
        begin
            INSERT INTO dbo.AccEngineItemType (Id, Code, Name, IsLocked, IsRoot, ApplicationCode, StateId, StateDate,
                                               StateMaker)
            VALUES (@lastAccEngineItemTypeId, N'Prd', N'Product', 0, null, 'TREX', @stateId,
                    @stateDate,
                    @stateMaker);
            select @lastAccEngineItemTypeId = @lastAccEngineItemTypeId + 1
        end
    if not exists(select 1
                  from dbo.AccEngineItemType
                  where Code = N'DerivativesDirection')
        begin
            INSERT INTO dbo.AccEngineItemType (Id, Code, Name, IsLocked, IsRoot, ApplicationCode, StateId, StateDate,
                                               StateMaker)
            VALUES (@lastAccEngineItemTypeId, N'DerivativesDirection', N'Derivatives Direction', 0, null, 'TREX',
                    @stateId,
                    @stateDate,
                    @stateMaker);
            select @lastAccEngineItemTypeId = @lastAccEngineItemTypeId + 1
        end
    if not exists(select 1
                  from dbo.AccEngineItemType
                  where Code = N'TxnType')
        begin
            INSERT INTO dbo.AccEngineItemType (Id, Code, Name, IsLocked, IsRoot, ApplicationCode, StateId,
                                               StateDate, StateMaker)
            VALUES (@lastAccEngineItemTypeId, N'TxnType', N'Transaction Type', 0, null, N'TREX', @stateId, @stateDate,
                    @stateMaker);
        end
    --#endregion
    ------------------------------------------------------------------------------------------------------------------------
    -- Accounting Engine Item Code
    ------------------------------------------------------------------------------------------------------------------------
--#region AccEngineItemCode
    if not exists(select 1
                  from dbo.AccEngineItemCode
                  where Code = N'DV')
        begin
            INSERT INTO dbo.AccEngineItemCode (Id, Code, Name, ItemTypeCode, StateId, StateDate, StateMaker)
            VALUES (@lastAccEngineItemCodeId, N'DV', N'Derivatives', N'Prd', @stateId, @stateDate, @stateMaker);
            select @lastAccEngineItemCodeId = @lastAccEngineItemCodeId + 1
        end
    if not exists(select 1
                  from dbo.AccEngineItemCode
                  where Code = N'IRS')
        begin
            INSERT INTO dbo.AccEngineItemCode (Id, Code, Name, ItemTypeCode, StateId, StateDate, StateMaker)
            VALUES (@lastAccEngineItemCodeId, N'IRS', N'Interest Rate Swap', N'TxnType', @stateId, @stateDate,
                    @stateMaker);
            select @lastAccEngineItemCodeId = @lastAccEngineItemCodeId + 1
        end
    if not exists(select 1
                  from dbo.AccEngineItemCode
                  where Code = N'LCYRLCYP')
        begin
            INSERT INTO dbo.AccEngineItemCode (Id, Code, Name, ItemTypeCode, StateId, StateDate, StateMaker)
            VALUES (@lastAccEngineItemCodeId, N'LCYRLCYP', N'LCY Receive LCY Pay ', N'DerivativesDirection', @stateId,
                    @stateDate,
                    @stateMaker);
            select @lastAccEngineItemCodeId = @lastAccEngineItemCodeId + 1
        end
    if not exists(select 1
                  from dbo.AccEngineItemCode
                  where Code = N'FCYRFCYP')
        begin
            INSERT INTO dbo.AccEngineItemCode (Id, Code, Name, ItemTypeCode, StateId, StateDate, StateMaker)
            VALUES (@lastAccEngineItemCodeId, N'FCYRFCYP', N'FCY Receive FCY Pay', N'DerivativesDirection', @stateId,
                    @stateDate, @stateMaker);
        end
    --#endregion
    ------------------------------------------------------------------------------------------------------------------------
    -- Accounting Account Map
    ------------------------------------------------------------------------------------------------------------------------
--#region AccAccountMap
    declare @lastAccAccountMapOrderNo int = 10;

    if not exists (select 1
                   from dbo.AccAccountMap
                   where Path = N'TREX/DV/IRS'
                     and Source = N'ValPayContingent'
                     and Target = N'96410200')
        begin
            INSERT INTO dbo.AccAccountMap (Id, Ccy, CustomerId, RuleId, Rule2Id, Rule3Id, Rule4Id, Rule5Id, Rule6Id,
                                           Rule7Id,
                                           Rule8Id, Rule9Id, Rule10Id, Source, Path, TargetMainGL, Target, TargetRuleId,
                                           IsEnabled,
                                           [Order], Description, CustomerCodeSourceRuleId,
                                           CustomerAccountCodeSourceRuleId,
                                           StateId,
                                           StateMaker, StateDate)
            VALUES (@lastAccAccountMapId, null, null, null, null, @dynamicRulePayLocalCurrencyId,
                    @dynamicRuleDerivativePortfolioTradeId, null,
                    null, null, null, null, null, N'ValPayContingent', N'TREX/DV/IRS', N'964', N'96410200', null, 1,
                    @lastAccAccountMapOrderNo,
                    N'',
                    null,
                    null, @stateId, @stateMaker, @stateDate);

            select @lastAccAccountMapId = @lastAccAccountMapId + 1
            select @lastAccAccountMapOrderNo = @lastAccAccountMapOrderNo + 10
        end

    if not exists (select 1
                   from dbo.AccAccountMap
                   where Path = N'TREX/DV/IRS'
                     and Source = N'ValPayContingentOffset'
                     and Target = N'96610200')
        begin
            INSERT INTO dbo.AccAccountMap (Id, Ccy, CustomerId, RuleId, Rule2Id, Rule3Id, Rule4Id, Rule5Id, Rule6Id,
                                           Rule7Id,
                                           Rule8Id, Rule9Id, Rule10Id, Source, Path, TargetMainGL, Target, TargetRuleId,
                                           IsEnabled,
                                           [Order], Description, CustomerCodeSourceRuleId,
                                           CustomerAccountCodeSourceRuleId,
                                           StateId,
                                           StateMaker, StateDate)
            VALUES (@lastAccAccountMapId, null, null, null, null, @dynamicRulePayLocalCurrencyId,
                    @dynamicRuleDerivativePortfolioTradeId, null,
                    null, null, null, null, null, N'ValPayContingentOffset', N'TREX/DV/IRS', N'966', N'96610200', null,
                    1, @lastAccAccountMapOrderNo,
                    N'',
                    null, null, @stateId, @stateMaker, @stateDate);

            select @lastAccAccountMapId = @lastAccAccountMapId + 1
            select @lastAccAccountMapOrderNo = @lastAccAccountMapOrderNo + 10
        end

    if not exists (select 1
                   from dbo.AccAccountMap
                   where Path = N'TREX/DV/IRS'
                     and Source = N'ValRecContingentOffset'
                     and Target = N'96410300')
        begin
            INSERT INTO dbo.AccAccountMap (Id, Ccy, CustomerId, RuleId, Rule2Id, Rule3Id, Rule4Id, Rule5Id, Rule6Id,
                                           Rule7Id,
                                           Rule8Id, Rule9Id, Rule10Id, Source, Path, TargetMainGL, Target, TargetRuleId,
                                           IsEnabled,
                                           [Order], Description, CustomerCodeSourceRuleId,
                                           CustomerAccountCodeSourceRuleId,
                                           StateId,
                                           StateMaker, StateDate)
            VALUES (@lastAccAccountMapId, null, null, null, null, @dynamicRuleReceiveLocalCurrencyId,
                    @dynamicRuleDerivativePortfolioTradeId,
                    null,
                    null, null, null, null, null, N'ValRecContingentOffset', N'TREX/DV/IRS', N'964', N'96410300', null,
                    1, @lastAccAccountMapOrderNo,
                    N'',
                    null, null, @stateId, @stateMaker, @stateDate);

            select @lastAccAccountMapId = @lastAccAccountMapId + 1
            select @lastAccAccountMapOrderNo = @lastAccAccountMapOrderNo + 10
        end

    if not exists (select 1
                   from dbo.AccAccountMap
                   where Path = N'TREX/DV/IRS'
                     and Source = N'ValRecContingent'
                     and Target = N'96610300')
        begin
            INSERT INTO dbo.AccAccountMap (Id, Ccy, CustomerId, RuleId, Rule2Id, Rule3Id, Rule4Id, Rule5Id, Rule6Id,
                                           Rule7Id,
                                           Rule8Id, Rule9Id, Rule10Id, Source, Path, TargetMainGL, Target, TargetRuleId,
                                           IsEnabled,
                                           [Order], Description, CustomerCodeSourceRuleId,
                                           CustomerAccountCodeSourceRuleId,
                                           StateId,
                                           StateMaker, StateDate)
            VALUES (@lastAccAccountMapId, null, null, null, null, @dynamicRuleReceiveLocalCurrencyId,
                    @dynamicRuleDerivativePortfolioTradeId,
                    null,
                    null, null, null, null, null, N'ValRecContingent', N'TREX/DV/IRS', N'966', N'96610300', null, 1,
                    @lastAccAccountMapOrderNo,
                    N'',
                    null,
                    null, @stateId, @stateMaker, @stateDate);

            select @lastAccAccountMapId = @lastAccAccountMapId + 1
            select @lastAccAccountMapOrderNo = @lastAccAccountMapOrderNo + 10
        end

    if not exists (select 1
                   from dbo.AccAccountMap
                   where Path = N'TREX/DV/IRS'
                     and Source = N'MatPayContingentOffset'
                     and Target = N'96410300')
        begin
            INSERT INTO dbo.AccAccountMap (Id, Ccy, CustomerId, RuleId, Rule2Id, Rule3Id, Rule4Id, Rule5Id, Rule6Id,
                                           Rule7Id,
                                           Rule8Id, Rule9Id, Rule10Id, Source, Path, TargetMainGL, Target, TargetRuleId,
                                           IsEnabled,
                                           [Order], Description, CustomerCodeSourceRuleId,
                                           CustomerAccountCodeSourceRuleId,
                                           StateId,
                                           StateMaker, StateDate)
            VALUES (@lastAccAccountMapId, null, null, null, null, @dynamicRulePayLocalCurrencyId,
                    @dynamicRuleDerivativePortfolioTradeId, null,
                    null, null, null, null, null, N'MatPayContingentOffset', N'TREX/DV/IRS', N'964', N'96410300', null,
                    1, @lastAccAccountMapOrderNo,
                    N'',
                    null, null, @stateId, @stateMaker, @stateDate);

            select @lastAccAccountMapId = @lastAccAccountMapId + 1
            select @lastAccAccountMapOrderNo = @lastAccAccountMapOrderNo + 10
        end

    if not exists (select 1
                   from dbo.AccAccountMap
                   where Path = N'TREX/DV/IRS'
                     and Source = N'MatPayContingent'
                     and Target = N'96610300')
        begin
            INSERT INTO dbo.AccAccountMap (Id, Ccy, CustomerId, RuleId, Rule2Id, Rule3Id, Rule4Id, Rule5Id, Rule6Id,
                                           Rule7Id,
                                           Rule8Id, Rule9Id, Rule10Id, Source, Path, TargetMainGL, Target, TargetRuleId,
                                           IsEnabled,
                                           [Order], Description, CustomerCodeSourceRuleId,
                                           CustomerAccountCodeSourceRuleId,
                                           StateId,
                                           StateMaker, StateDate)
            VALUES (@lastAccAccountMapId, null, null, null, null, @dynamicRulePayLocalCurrencyId,
                    @dynamicRuleDerivativePortfolioTradeId, null,
                    null, null, null, null, null, N'MatPayContingent', N'TREX/DV/IRS', N'966', N'96610300', null, 1,
                    @lastAccAccountMapOrderNo,
                    N'',
                    null,
                    null, @stateId, @stateMaker, @stateDate);

            select @lastAccAccountMapId = @lastAccAccountMapId + 1
            select @lastAccAccountMapOrderNo = @lastAccAccountMapOrderNo + 10
        end

    if not exists (select 1
                   from dbo.AccAccountMap
                   where Path = N'TREX/DV/IRS'
                     and Source = N'MatRecContingent'
                     and Target = N'96410200')
        begin
            INSERT INTO dbo.AccAccountMap (Id, Ccy, CustomerId, RuleId, Rule2Id, Rule3Id, Rule4Id, Rule5Id, Rule6Id,
                                           Rule7Id,
                                           Rule8Id, Rule9Id, Rule10Id, Source, Path, TargetMainGL, Target, TargetRuleId,
                                           IsEnabled,
                                           [Order], Description, CustomerCodeSourceRuleId,
                                           CustomerAccountCodeSourceRuleId,
                                           StateId,
                                           StateMaker, StateDate)
            VALUES (@lastAccAccountMapId, null, null, null, null, @dynamicRuleReceiveLocalCurrencyId,
                    @dynamicRuleDerivativePortfolioTradeId,
                    null,
                    null, null, null, null, null, N'MatRecContingent', N'TREX/DV/IRS', N'964', N'96410200', null, 1,
                    @lastAccAccountMapOrderNo,
                    N'',
                    null,
                    null, @stateId, @stateMaker, @stateDate);

            select @lastAccAccountMapId = @lastAccAccountMapId + 1
            select @lastAccAccountMapOrderNo = @lastAccAccountMapOrderNo + 10
        end

    if not exists (select 1
                   from dbo.AccAccountMap
                   where Path = N'TREX/DV/IRS'
                     and Source = N'MatRecContingentOffset'
                     and Target = N'96610200')
        begin
            INSERT INTO dbo.AccAccountMap (Id, Ccy, CustomerId, RuleId, Rule2Id, Rule3Id, Rule4Id, Rule5Id, Rule6Id,
                                           Rule7Id,
                                           Rule8Id, Rule9Id, Rule10Id, Source, Path, TargetMainGL, Target, TargetRuleId,
                                           IsEnabled,
                                           [Order], Description, CustomerCodeSourceRuleId,
                                           CustomerAccountCodeSourceRuleId,
                                           StateId,
                                           StateMaker, StateDate)
            VALUES (@lastAccAccountMapId, null, null, null, null, @dynamicRuleReceiveLocalCurrencyId,
                    @dynamicRuleDerivativePortfolioTradeId,
                    null,
                    null, null, null, null, null, N'MatRecContingentOffset', N'TREX/DV/IRS', N'966', N'96610200', null,
                    1, @lastAccAccountMapOrderNo,
                    N'',
                    null, null, @stateId, @stateMaker, @stateDate);

            select @lastAccAccountMapId = @lastAccAccountMapId + 1
            select @lastAccAccountMapOrderNo = @lastAccAccountMapOrderNo + 10
        end

    if not exists (select 1
                   from dbo.AccAccountMap
                   where Path = N'TREX/DV/IRS'
                     and Source = N'ValPayContingent'
                     and Target = N'96510500')
        begin
            INSERT INTO dbo.AccAccountMap (Id, Ccy, CustomerId, RuleId, Rule2Id, Rule3Id, Rule4Id, Rule5Id, Rule6Id,
                                           Rule7Id,
                                           Rule8Id, Rule9Id, Rule10Id, Source, Path, TargetMainGL, Target, TargetRuleId,
                                           IsEnabled,
                                           [Order], Description, CustomerCodeSourceRuleId,
                                           CustomerAccountCodeSourceRuleId,
                                           StateId,
                                           StateMaker, StateDate)
            VALUES (@lastAccAccountMapId, null, null, null, null, @dynamicRulePayForeignCurrencyId,
                    @dynamicRuleDerivativePortfolioTradeId,
                    null,
                    null, null, null, null, null, N'ValPayContingent', N'TREX/DV/IRS', N'965', N'96510500', null, 1,
                    @lastAccAccountMapOrderNo,
                    N'',
                    null,
                    null, @stateId, @stateMaker, @stateDate);

            select @lastAccAccountMapId = @lastAccAccountMapId + 1
            select @lastAccAccountMapOrderNo = @lastAccAccountMapOrderNo + 10
        end

    if not exists (select 1
                   from dbo.AccAccountMap
                   where Path = N'TREX/DV/IRS'
                     and Source = N'ValPayContingentOffset'
                     and Target = N'96710500')
        begin
            INSERT INTO dbo.AccAccountMap (Id, Ccy, CustomerId, RuleId, Rule2Id, Rule3Id, Rule4Id, Rule5Id, Rule6Id,
                                           Rule7Id,
                                           Rule8Id, Rule9Id, Rule10Id, Source, Path, TargetMainGL, Target, TargetRuleId,
                                           IsEnabled,
                                           [Order], Description, CustomerCodeSourceRuleId,
                                           CustomerAccountCodeSourceRuleId,
                                           StateId,
                                           StateMaker, StateDate)
            VALUES (@lastAccAccountMapId, null, null, null, null, @dynamicRulePayForeignCurrencyId,
                    @dynamicRuleDerivativePortfolioTradeId,
                    null,
                    null, null, null, null, null, N'ValPayContingentOffset', N'TREX/DV/IRS', N'967', N'96710500', null,
                    1, @lastAccAccountMapOrderNo,
                    N'',
                    null, null, @stateId, @stateMaker, @stateDate);

            select @lastAccAccountMapId = @lastAccAccountMapId + 1
            select @lastAccAccountMapOrderNo = @lastAccAccountMapOrderNo + 10
        end

    if not exists (select 1
                   from dbo.AccAccountMap
                   where Path = N'TREX/DV/IRS'
                     and Source = N'ValRecContingentOffset'
                     and Target = N'96510700')
        begin
            INSERT INTO dbo.AccAccountMap (Id, Ccy, CustomerId, RuleId, Rule2Id, Rule3Id, Rule4Id, Rule5Id, Rule6Id,
                                           Rule7Id,
                                           Rule8Id, Rule9Id, Rule10Id, Source, Path, TargetMainGL, Target, TargetRuleId,
                                           IsEnabled,
                                           [Order], Description, CustomerCodeSourceRuleId,
                                           CustomerAccountCodeSourceRuleId,
                                           StateId,
                                           StateMaker, StateDate)
            VALUES (@lastAccAccountMapId, null, null, null, null, @dynamicRuleReceiveForeignCurrencyId,
                    @dynamicRuleDerivativePortfolioTradeId,
                    null, null, null, null, null, null, N'ValRecContingentOffset', N'TREX/DV/IRS', N'965', N'96510700',
                    null, 1,
                    @lastAccAccountMapOrderNo,
                    N'', null, null, @stateId, @stateMaker, @stateDate);

            select @lastAccAccountMapId = @lastAccAccountMapId + 1
            select @lastAccAccountMapOrderNo = @lastAccAccountMapOrderNo + 10
        end

    if not exists (select 1
                   from dbo.AccAccountMap
                   where Path = N'TREX/DV/IRS'
                     and Source = N'ValRecContingent'
                     and Target = N'96710700')
        begin
            INSERT INTO dbo.AccAccountMap (Id, Ccy, CustomerId, RuleId, Rule2Id, Rule3Id, Rule4Id, Rule5Id, Rule6Id,
                                           Rule7Id,
                                           Rule8Id, Rule9Id, Rule10Id, Source, Path, TargetMainGL, Target, TargetRuleId,
                                           IsEnabled,
                                           [Order], Description, CustomerCodeSourceRuleId,
                                           CustomerAccountCodeSourceRuleId,
                                           StateId,
                                           StateMaker, StateDate)
            VALUES (@lastAccAccountMapId, null, null, null, null, @dynamicRuleReceiveForeignCurrencyId,
                    @dynamicRuleDerivativePortfolioTradeId,
                    null, null, null, null, null, null, N'ValRecContingent', N'TREX/DV/IRS', N'967', N'96710700', null,
                    1, @lastAccAccountMapOrderNo,
                    N'',
                    null, null, @stateId, @stateMaker, @stateDate);

            select @lastAccAccountMapId = @lastAccAccountMapId + 1
            select @lastAccAccountMapOrderNo = @lastAccAccountMapOrderNo + 10
        end

    if not exists (select 1
                   from dbo.AccAccountMap
                   where Path = N'TREX/DV/IRS'
                     and Source = N'MatPayContingentOffset'
                     and Target = N'96510700')
        begin
            INSERT INTO dbo.AccAccountMap (Id, Ccy, CustomerId, RuleId, Rule2Id, Rule3Id, Rule4Id, Rule5Id, Rule6Id,
                                           Rule7Id,
                                           Rule8Id, Rule9Id, Rule10Id, Source, Path, TargetMainGL, Target, TargetRuleId,
                                           IsEnabled,
                                           [Order], Description, CustomerCodeSourceRuleId,
                                           CustomerAccountCodeSourceRuleId,
                                           StateId,
                                           StateMaker, StateDate)
            VALUES (@lastAccAccountMapId, null, null, null, null, @dynamicRulePayForeignCurrencyId,
                    @dynamicRuleDerivativePortfolioTradeId,
                    null,
                    null, null, null, null, null, N'MatPayContingentOffset', N'TREX/DV/IRS', N'965', N'96510700', null,
                    1, @lastAccAccountMapOrderNo,
                    N'',
                    null, null, @stateId, @stateMaker, @stateDate);

            select @lastAccAccountMapId = @lastAccAccountMapId + 1
            select @lastAccAccountMapOrderNo = @lastAccAccountMapOrderNo + 10
        end

    if not exists (select 1
                   from dbo.AccAccountMap
                   where Path = N'TREX/DV/IRS'
                     and Source = N'MatPayContingent'
                     and Target = N'96710700')
        begin
            INSERT INTO dbo.AccAccountMap (Id, Ccy, CustomerId, RuleId, Rule2Id, Rule3Id, Rule4Id, Rule5Id, Rule6Id,
                                           Rule7Id,
                                           Rule8Id, Rule9Id, Rule10Id, Source, Path, TargetMainGL, Target, TargetRuleId,
                                           IsEnabled,
                                           [Order], Description, CustomerCodeSourceRuleId,
                                           CustomerAccountCodeSourceRuleId,
                                           StateId,
                                           StateMaker, StateDate)
            VALUES (5013, null, null, null, null, @dynamicRulePayForeignCurrencyId,
                    @dynamicRuleDerivativePortfolioTradeId,
                    null,
                    null, null, null, null, null, N'MatPayContingent', N'TREX/DV/IRS', N'967', N'96710700', null, 1,
                    @lastAccAccountMapOrderNo,
                    N'',
                    null,
                    null, @stateId, @stateMaker, @stateDate);

            select @lastAccAccountMapId = @lastAccAccountMapId + 1
            select @lastAccAccountMapOrderNo = @lastAccAccountMapOrderNo + 10
        end

    if not exists (select 1
                   from dbo.AccAccountMap
                   where Path = N'TREX/DV/IRS'
                     and Source = N'MatRecContingent'
                     and Target = N'96510500')
        begin
            INSERT INTO dbo.AccAccountMap (Id, Ccy, CustomerId, RuleId, Rule2Id, Rule3Id, Rule4Id, Rule5Id, Rule6Id,
                                           Rule7Id,
                                           Rule8Id, Rule9Id, Rule10Id, Source, Path, TargetMainGL, Target, TargetRuleId,
                                           IsEnabled,
                                           [Order], Description, CustomerCodeSourceRuleId,
                                           CustomerAccountCodeSourceRuleId,
                                           StateId,
                                           StateMaker, StateDate)
            VALUES (@lastAccAccountMapId, null, null, null, null, @dynamicRuleReceiveForeignCurrencyId,
                    @dynamicRuleDerivativePortfolioTradeId,
                    null, null, null, null, null, null, N'MatRecContingent', N'TREX/DV/IRS', N'965', N'96510500', null,
                    1, @lastAccAccountMapOrderNo,
                    N'',
                    null, null, @stateId, @stateMaker, @stateDate);

            select @lastAccAccountMapId = @lastAccAccountMapId + 1
            select @lastAccAccountMapOrderNo = @lastAccAccountMapOrderNo + 10
        end

    if not exists (select 1
                   from dbo.AccAccountMap
                   where Path = N'TREX/DV/IRS'
                     and Source = N'MatRecContingentOffset'
                     and Target = N'96710500')
        begin
            INSERT INTO dbo.AccAccountMap (Id, Ccy, CustomerId, RuleId, Rule2Id, Rule3Id, Rule4Id, Rule5Id, Rule6Id,
                                           Rule7Id,
                                           Rule8Id, Rule9Id, Rule10Id, Source, Path, TargetMainGL, Target, TargetRuleId,
                                           IsEnabled,
                                           [Order], Description, CustomerCodeSourceRuleId,
                                           CustomerAccountCodeSourceRuleId,
                                           StateId,
                                           StateMaker, StateDate)
            VALUES (@lastAccAccountMapId, null, null, null, null, @dynamicRuleReceiveForeignCurrencyId,
                    @dynamicRuleDerivativePortfolioTradeId,
                    null, null, null, null, null, null, N'MatRecContingentOffset', N'TREX/DV/IRS', N'967', N'96710500',
                    null, 1,
                    @lastAccAccountMapOrderNo,
                    N'', null, null, @stateId, @stateMaker, @stateDate);

            select @lastAccAccountMapId = @lastAccAccountMapId + 1
            select @lastAccAccountMapOrderNo = @lastAccAccountMapOrderNo + 10
        end

    if not exists (select 1
                   from dbo.AccAccountMap
                   where Path = N'TREX/DV/IRS'
                     and Source = N'IncomingPaymentFCY'
                     and Target = N'39300800')
        begin
            INSERT INTO dbo.AccAccountMap (Id, Ccy, CustomerId, RuleId, Rule2Id, Rule3Id, Rule4Id, Rule5Id, Rule6Id,
                                           Rule7Id,
                                           Rule8Id, Rule9Id, Rule10Id, Source, Path, TargetMainGL, Target, TargetRuleId,
                                           IsEnabled,
                                           [Order], Description, CustomerCodeSourceRuleId,
                                           CustomerAccountCodeSourceRuleId,
                                           StateId,
                                           StateMaker, StateDate)
            VALUES (@lastAccAccountMapId, null, null, null, null, @dynamicRuleReceiveForeignCurrencyId,
                    @dynamicRuleDerivativePortfolioTradeId,
                    null, null, null, null, null, null, N'IncomingPaymentFCY', N'TREX/DV/IRS', N'393', N'39300800',
                    null, 1, @lastAccAccountMapOrderNo,
                    N'', null, null, @stateId, @stateMaker, @stateDate);

            select @lastAccAccountMapId = @lastAccAccountMapId + 1
            select @lastAccAccountMapOrderNo = @lastAccAccountMapOrderNo + 10
        end

    if not exists (select 1
                   from dbo.AccAccountMap
                   where Path = N'TREX/DV/IRS'
                     and Source = N'FXPositionRec'
                     and Target = N'29500000')
        begin
            INSERT INTO dbo.AccAccountMap (Id, Ccy, CustomerId, RuleId, Rule2Id, Rule3Id, Rule4Id, Rule5Id, Rule6Id,
                                           Rule7Id,
                                           Rule8Id, Rule9Id, Rule10Id, Source, Path, TargetMainGL, Target, TargetRuleId,
                                           IsEnabled,
                                           [Order], Description, CustomerCodeSourceRuleId,
                                           CustomerAccountCodeSourceRuleId,
                                           StateId,
                                           StateMaker, StateDate)
            VALUES (@lastAccAccountMapId, null, null, null, null, @dynamicRuleReceiveForeignCurrencyId,
                    @dynamicRuleDerivativePortfolioTradeId,
                    null, null, null, null, null, null, N'FXPositionRec', N'TREX/DV/IRS', N'295', N'29500000', null, 1,
                    @lastAccAccountMapOrderNo, N'',
                    null, null, @stateId, @stateMaker, @stateDate);

            select @lastAccAccountMapId = @lastAccAccountMapId + 1
            select @lastAccAccountMapOrderNo = @lastAccAccountMapOrderNo + 10
        end

    if not exists (select 1
                   from dbo.AccAccountMap
                   where Path = N'TREX/DV/IRS'
                     and Source = N'FXPositionLCY'
                     and Target = N'29400')
        begin
            INSERT INTO dbo.AccAccountMap (Id, Ccy, CustomerId, RuleId, Rule2Id, Rule3Id, Rule4Id, Rule5Id, Rule6Id,
                                           Rule7Id,
                                           Rule8Id, Rule9Id, Rule10Id, Source, Path, TargetMainGL, Target, TargetRuleId,
                                           IsEnabled,
                                           [Order], Description, CustomerCodeSourceRuleId,
                                           CustomerAccountCodeSourceRuleId,
                                           StateId,
                                           StateMaker, StateDate)
            VALUES (@lastAccAccountMapId, null, null, null, null, null, @dynamicRuleDerivativePortfolioTradeId, null,
                    null, null, null,
                    null,
                    null,
                    N'FXPositionLCY', N'TREX/DV/IRS', N'294', N'29400', null, 1, @lastAccAccountMapOrderNo, N'', null,
                    null, @stateId,
                    @stateMaker,
                    @stateDate);

            select @lastAccAccountMapId = @lastAccAccountMapId + 1
            select @lastAccAccountMapOrderNo = @lastAccAccountMapOrderNo + 10
        end

    if not exists (select 1
                   from dbo.AccAccountMap
                   where Path = N'TREX/DV/IRS'
                     and Source = N'InterestIncome'
                     and Target = N'59909000')
        begin
            INSERT INTO dbo.AccAccountMap (Id, Ccy, CustomerId, RuleId, Rule2Id, Rule3Id, Rule4Id, Rule5Id, Rule6Id,
                                           Rule7Id,
                                           Rule8Id, Rule9Id, Rule10Id, Source, Path, TargetMainGL, Target, TargetRuleId,
                                           IsEnabled,
                                           [Order], Description, CustomerCodeSourceRuleId,
                                           CustomerAccountCodeSourceRuleId,
                                           StateId,
                                           StateMaker, StateDate)
            VALUES (@lastAccAccountMapId, null, null, null, null, @dynamicRuleReceiveForeignCurrencyId,
                    @dynamicRuleDerivativePortfolioTradeId,
                    null,
                    null, null, null, null, null, N'InterestIncome', N'TREX/DV/IRS', N'599', N'59909000', null, 1,
                    @lastAccAccountMapOrderNo,
                    N'',
                    null,
                    null, @stateId, @stateMaker, @stateDate);

            select @lastAccAccountMapId = @lastAccAccountMapId + 1
            select @lastAccAccountMapOrderNo = @lastAccAccountMapOrderNo + 10
        end

    if not exists (select 1
                   from dbo.AccAccountMap
                   where Path = N'TREX/DV/IRS'
                     and Source = N'FXPositionPay'
                     and Target = N'29500000')
        begin
            INSERT INTO dbo.AccAccountMap (Id, Ccy, CustomerId, RuleId, Rule2Id, Rule3Id, Rule4Id, Rule5Id, Rule6Id,
                                           Rule7Id,
                                           Rule8Id, Rule9Id, Rule10Id, Source, Path, TargetMainGL, Target, TargetRuleId,
                                           IsEnabled,
                                           [Order], Description, CustomerCodeSourceRuleId,
                                           CustomerAccountCodeSourceRuleId,
                                           StateId,
                                           StateMaker, StateDate)
            VALUES (@lastAccAccountMapId, null, null, null, null, @dynamicRulePayForeignCurrencyId,
                    @dynamicRuleDerivativePortfolioTradeId,
                    null,
                    null, null, null, null, null, N'FXPositionPay', N'TREX/DV/IRS', N'295', N'29500000', null, 1,
                    @lastAccAccountMapOrderNo,
                    N'',
                    null,
                    null, @stateId, @stateMaker, @stateDate);

            select @lastAccAccountMapId = @lastAccAccountMapId + 1
            select @lastAccAccountMapOrderNo = @lastAccAccountMapOrderNo + 10
        end

    if not exists (select 1
                   from dbo.AccAccountMap
                   where Path = N'TREX/DV/IRS'
                     and Source = N'FXPositionLCY'
                     and Target = N'29400')
        begin
            INSERT INTO dbo.AccAccountMap (Id, Ccy, CustomerId, RuleId, Rule2Id, Rule3Id, Rule4Id, Rule5Id, Rule6Id,
                                           Rule7Id,
                                           Rule8Id, Rule9Id, Rule10Id, Source, Path, TargetMainGL, Target, TargetRuleId,
                                           IsEnabled,
                                           [Order], Description, CustomerCodeSourceRuleId,
                                           CustomerAccountCodeSourceRuleId,
                                           StateId,
                                           StateMaker, StateDate)
            VALUES (@lastAccAccountMapId, null, null, null, null, null, @dynamicRuleDerivativePortfolioTradeId, null,
                    null, null, null,
                    null,
                    null,
                    N'FXPositionLCY', N'TREX/DV/IRS', N'294', N'29400', null, 1, @lastAccAccountMapOrderNo, N'', null,
                    null, @stateId,
                    @stateMaker,
                    @stateDate);

            select @lastAccAccountMapId = @lastAccAccountMapId + 1
            select @lastAccAccountMapOrderNo = @lastAccAccountMapOrderNo + 10
        end

    if not exists (select 1
                   from dbo.AccAccountMap
                   where Path = N'TREX/DV/IRS'
                     and Source = N'OutgoingPaymentFCY'
                     and Target = N'39300800')
        begin
            INSERT INTO dbo.AccAccountMap (Id, Ccy, CustomerId, RuleId, Rule2Id, Rule3Id, Rule4Id, Rule5Id, Rule6Id,
                                           Rule7Id,
                                           Rule8Id, Rule9Id, Rule10Id, Source, Path, TargetMainGL, Target, TargetRuleId,
                                           IsEnabled,
                                           [Order], Description, CustomerCodeSourceRuleId,
                                           CustomerAccountCodeSourceRuleId,
                                           StateId,
                                           StateMaker, StateDate)
            VALUES (@lastAccAccountMapId, null, null, null, null, @dynamicRulePayForeignCurrencyId,
                    @dynamicRuleDerivativePortfolioTradeId,
                    null,
                    null, null, null, null, null, N'OutgoingPaymentFCY', N'TREX/DV/IRS', N'393', N'39300800', null, 1,
                    @lastAccAccountMapOrderNo, N'',
                    null, null, @stateId, @stateMaker, @stateDate);

            select @lastAccAccountMapId = @lastAccAccountMapId + 1
            select @lastAccAccountMapOrderNo = @lastAccAccountMapOrderNo + 10
        end

    if not exists (select 1
                   from dbo.AccAccountMap
                   where Path = N'TREX/DV/IRS'
                     and Source = N'InterestExpense'
                     and Target = N'69909000')
        begin
            INSERT INTO dbo.AccAccountMap (Id, Ccy, CustomerId, RuleId, Rule2Id, Rule3Id, Rule4Id, Rule5Id, Rule6Id,
                                           Rule7Id,
                                           Rule8Id, Rule9Id, Rule10Id, Source, Path, TargetMainGL, Target, TargetRuleId,
                                           IsEnabled,
                                           [Order], Description, CustomerCodeSourceRuleId,
                                           CustomerAccountCodeSourceRuleId,
                                           StateId,
                                           StateMaker, StateDate)
            VALUES (@lastAccAccountMapId, null, null, null, null, @dynamicRulePayForeignCurrencyId,
                    @dynamicRuleDerivativePortfolioTradeId, null,
                    null, null, null, null, null, N'InterestExpense', N'TREX/DV/IRS', N'699', N'69909000', null, 1,
                    @lastAccAccountMapOrderNo,
                    N'',
                    null,
                    null, @stateId, @stateMaker, @stateDate);

            select @lastAccAccountMapId = @lastAccAccountMapId + 1
            select @lastAccAccountMapOrderNo = @lastAccAccountMapOrderNo + 10
        end

    if not exists (select 1
                   from dbo.AccAccountMap
                   where Path = N'TREX/DV/IRS'
                     and Source = N'IncomingPaymentLCY'
                     and Target = N'39200800')
        begin
            INSERT INTO dbo.AccAccountMap (Id, Ccy, CustomerId, RuleId, Rule2Id, Rule3Id, Rule4Id, Rule5Id, Rule6Id,
                                           Rule7Id,
                                           Rule8Id, Rule9Id, Rule10Id, Source, Path, TargetMainGL, Target, TargetRuleId,
                                           IsEnabled,
                                           [Order], Description, CustomerCodeSourceRuleId,
                                           CustomerAccountCodeSourceRuleId,
                                           StateId,
                                           StateMaker, StateDate)
            VALUES (@lastAccAccountMapId, null, null, null, null, @dynamicRuleReceiveLocalCurrencyId,
                    @dynamicRuleDerivativePortfolioTradeId,
                    null,
                    null, null, null, null, null, N'IncomingPaymentLCY', N'TREX/DV/IRS', N'392', N'39200800', null, 1,
                    @lastAccAccountMapOrderNo, N'',
                    null, null, @stateId, @stateMaker, @stateDate);

            select @lastAccAccountMapId = @lastAccAccountMapId + 1
            select @lastAccAccountMapOrderNo = @lastAccAccountMapOrderNo + 10
        end

    if not exists (select 1
                   from dbo.AccAccountMap
                   where Path = N'TREX/DV/IRS'
                     and Source = N'InterestIncome'
                     and Target = N'59809000')
        begin
            INSERT INTO dbo.AccAccountMap (Id, Ccy, CustomerId, RuleId, Rule2Id, Rule3Id, Rule4Id, Rule5Id, Rule6Id,
                                           Rule7Id,
                                           Rule8Id, Rule9Id, Rule10Id, Source, Path, TargetMainGL, Target, TargetRuleId,
                                           IsEnabled,
                                           [Order], Description, CustomerCodeSourceRuleId,
                                           CustomerAccountCodeSourceRuleId,
                                           StateId,
                                           StateMaker, StateDate)
            VALUES (@lastAccAccountMapId, null, null, null, null, @dynamicRuleReceiveLocalCurrencyId,
                    @dynamicRuleDerivativePortfolioTradeId,
                    null,
                    null, null, null, null, null, N'InterestIncome', N'TREX/DV/IRS', N'598', N'59809000', null, 1,
                    @lastAccAccountMapOrderNo,
                    N'',
                    null,
                    null, @stateId, @stateMaker, @stateDate);

            select @lastAccAccountMapId = @lastAccAccountMapId + 1
            select @lastAccAccountMapOrderNo = @lastAccAccountMapOrderNo + 10
        end

    if not exists (select 1
                   from dbo.AccAccountMap
                   where Path = N'TREX/DV/IRS'
                     and Source = N'InterestExpense'
                     and Target = N'69809000')
        begin
            INSERT INTO dbo.AccAccountMap (Id, Ccy, CustomerId, RuleId, Rule2Id, Rule3Id, Rule4Id, Rule5Id, Rule6Id,
                                           Rule7Id,
                                           Rule8Id, Rule9Id, Rule10Id, Source, Path, TargetMainGL, Target, TargetRuleId,
                                           IsEnabled,
                                           [Order], Description, CustomerCodeSourceRuleId,
                                           CustomerAccountCodeSourceRuleId,
                                           StateId,
                                           StateMaker, StateDate)
            VALUES (@lastAccAccountMapId, null, null, null, null, @dynamicRulePayLocalCurrencyId,
                    @dynamicRuleDerivativePortfolioTradeId, null,
                    null, null, null, null, null, N'InterestExpense', N'TREX/DV/IRS', N'698', N'69809000', null, 1,
                    @lastAccAccountMapOrderNo,
                    N'',
                    null,
                    null, @stateId, @stateMaker, @stateDate);

            select @lastAccAccountMapId = @lastAccAccountMapId + 1
            select @lastAccAccountMapOrderNo = @lastAccAccountMapOrderNo + 10
        end

    if not exists (select 1
                   from dbo.AccAccountMap
                   where Path = N'TREX/DV/IRS'
                     and Source = N'OutgoingPaymentLCY'
                     and Target = N'39200800')
        begin
            INSERT INTO dbo.AccAccountMap (Id, Ccy, CustomerId, RuleId, Rule2Id, Rule3Id, Rule4Id, Rule5Id, Rule6Id,
                                           Rule7Id,
                                           Rule8Id, Rule9Id, Rule10Id, Source, Path, TargetMainGL, Target, TargetRuleId,
                                           IsEnabled,
                                           [Order], Description, CustomerCodeSourceRuleId,
                                           CustomerAccountCodeSourceRuleId,
                                           StateId,
                                           StateMaker, StateDate)
            VALUES (@lastAccAccountMapId, null, null, null, null, @dynamicRulePayLocalCurrencyId,
                    @dynamicRuleDerivativePortfolioTradeId, null,
                    null, null, null, null, null, N'OutgoingPaymentLCY', N'TREX/DV/IRS', N'392', N'39200800', null, 1,
                    @lastAccAccountMapOrderNo, N'',
                    null, null, @stateId, @stateMaker, @stateDate);

            select @lastAccAccountMapId = @lastAccAccountMapId + 1
            select @lastAccAccountMapOrderNo = @lastAccAccountMapOrderNo + 10
        end

    if not exists (select 1
                   from dbo.AccAccountMap
                   where Path = N'TREX/DV/IRS'
                     and Source = N'TotalMTMProfit'
                     and Target = N'22500200')
        begin
            INSERT INTO dbo.AccAccountMap (Id, Ccy, CustomerId, RuleId, Rule2Id, Rule3Id, Rule4Id, Rule5Id, Rule6Id,
                                           Rule7Id,
                                           Rule8Id, Rule9Id, Rule10Id, Source, Path, TargetMainGL, Target, TargetRuleId,
                                           IsEnabled,
                                           [Order], Description, CustomerCodeSourceRuleId,
                                           CustomerAccountCodeSourceRuleId,
                                           StateId,
                                           StateMaker, StateDate)
            VALUES (@lastAccAccountMapId, null, null, null, null, @dynamicRuleReceiveForeignCurrencyId,
                    @dynamicRuleDerivativePortfolioTradeId,
                    null, null, null, null, null, null, N'TotalMTMProfit', N'TREX/DV/IRS', N'225', N'22500200', null, 1,
                    @lastAccAccountMapOrderNo,
                    N'',
                    null, null, @stateId, @stateMaker, @stateDate);

            select @lastAccAccountMapId = @lastAccAccountMapId + 1
            select @lastAccAccountMapOrderNo = @lastAccAccountMapOrderNo + 10
        end

    if not exists (select 1
                   from dbo.AccAccountMap
                   where Path = N'TREX/DV/IRS'
                     and Source = N'CapitalGainFCY'
                     and Target = N'75301100')
        begin
            INSERT INTO dbo.AccAccountMap (Id, Ccy, CustomerId, RuleId, Rule2Id, Rule3Id, Rule4Id, Rule5Id, Rule6Id,
                                           Rule7Id,
                                           Rule8Id, Rule9Id, Rule10Id, Source, Path, TargetMainGL, Target, TargetRuleId,
                                           IsEnabled,
                                           [Order], Description, CustomerCodeSourceRuleId,
                                           CustomerAccountCodeSourceRuleId,
                                           StateId,
                                           StateMaker, StateDate)
            VALUES (@lastAccAccountMapId, null, null, null, null, null, @dynamicRuleDerivativePortfolioTradeId, null,
                    null, null, null,
                    null,
                    null,
                    N'CapitalGainFCY', N'TREX/DV/IRS', N'753', N'75301100', null, 1, @lastAccAccountMapOrderNo, N'',
                    null, null, @stateId,
                    @stateMaker,
                    @stateDate);

            select @lastAccAccountMapId = @lastAccAccountMapId + 1
            select @lastAccAccountMapOrderNo = @lastAccAccountMapOrderNo + 10
        end

    if not exists (select 1
                   from dbo.AccAccountMap
                   where Path = N'TREX/DV/IRS'
                     and Source = N'TotalMTMLoss'
                     and Target = N'36500200')
        begin
            INSERT INTO dbo.AccAccountMap (Id, Ccy, CustomerId, RuleId, Rule2Id, Rule3Id, Rule4Id, Rule5Id, Rule6Id,
                                           Rule7Id,
                                           Rule8Id, Rule9Id, Rule10Id, Source, Path, TargetMainGL, Target, TargetRuleId,
                                           IsEnabled,
                                           [Order], Description, CustomerCodeSourceRuleId,
                                           CustomerAccountCodeSourceRuleId,
                                           StateId,
                                           StateMaker, StateDate)
            VALUES (@lastAccAccountMapId, null, null, null, null, @dynamicRuleReceiveForeignCurrencyId,
                    @dynamicRuleDerivativePortfolioTradeId,
                    null, null, null, null, null, null, N'TotalMTMLoss', N'TREX/DV/IRS', N'365', N'36500200', null, 1,
                    @lastAccAccountMapOrderNo, N'',
                    null, null, @stateId, @stateMaker, @stateDate);

            select @lastAccAccountMapId = @lastAccAccountMapId + 1
            select @lastAccAccountMapOrderNo = @lastAccAccountMapOrderNo + 10
        end

    if not exists (select 1
                   from dbo.AccAccountMap
                   where Path = N'TREX/DV/IRS'
                     and Source = N'CapitalLossFCY'
                     and Target = N'87301100')
        begin
            INSERT INTO dbo.AccAccountMap (Id, Ccy, CustomerId, RuleId, Rule2Id, Rule3Id, Rule4Id, Rule5Id, Rule6Id,
                                           Rule7Id,
                                           Rule8Id, Rule9Id, Rule10Id, Source, Path, TargetMainGL, Target, TargetRuleId,
                                           IsEnabled,
                                           [Order], Description, CustomerCodeSourceRuleId,
                                           CustomerAccountCodeSourceRuleId,
                                           StateId,
                                           StateMaker, StateDate)
            VALUES (@lastAccAccountMapId, null, null, null, null, null, @dynamicRuleDerivativePortfolioTradeId, null,
                    null, null, null,
                    null,
                    null,
                    N'CapitalLossFCY', N'TREX/DV/IRS', N'873', N'87301100', null, 1, @lastAccAccountMapOrderNo, N'',
                    null, null, @stateId,
                    @stateMaker,
                    @stateDate);

            select @lastAccAccountMapId = @lastAccAccountMapId + 1
            select @lastAccAccountMapOrderNo = @lastAccAccountMapOrderNo + 10
        end

    if not exists (select 1
                   from dbo.AccAccountMap
                   where Path = N'TREX/DV/IRS'
                     and Source = N'TotalMTMProfit'
                     and Target = N'22400200')
        begin
            INSERT INTO dbo.AccAccountMap (Id, Ccy, CustomerId, RuleId, Rule2Id, Rule3Id, Rule4Id, Rule5Id, Rule6Id,
                                           Rule7Id,
                                           Rule8Id, Rule9Id, Rule10Id, Source, Path, TargetMainGL, Target, TargetRuleId,
                                           IsEnabled,
                                           [Order], Description, CustomerCodeSourceRuleId,
                                           CustomerAccountCodeSourceRuleId,
                                           StateId,
                                           StateMaker, StateDate)
            VALUES (@lastAccAccountMapId, null, null, null, null, @dynamicRuleReceiveLocalCurrencyId,
                    @dynamicRuleDerivativePortfolioTradeId,
                    null,
                    null, null, null, null, null, N'TotalMTMProfit', N'TREX/DV/IRS', N'224', N'22400200', null, 1,
                    @lastAccAccountMapOrderNo,
                    N'',
                    null,
                    null, @stateId, @stateMaker, @stateDate);

            select @lastAccAccountMapId = @lastAccAccountMapId + 1
            select @lastAccAccountMapOrderNo = @lastAccAccountMapOrderNo + 10
        end

    if not exists (select 1
                   from dbo.AccAccountMap
                   where Path = N'TREX/DV/IRS'
                     and Source = N'CapitalGainLCY'
                     and Target = N'75201100')
        begin
            INSERT INTO dbo.AccAccountMap (Id, Ccy, CustomerId, RuleId, Rule2Id, Rule3Id, Rule4Id, Rule5Id, Rule6Id,
                                           Rule7Id,
                                           Rule8Id, Rule9Id, Rule10Id, Source, Path, TargetMainGL, Target, TargetRuleId,
                                           IsEnabled,
                                           [Order], Description, CustomerCodeSourceRuleId,
                                           CustomerAccountCodeSourceRuleId,
                                           StateId,
                                           StateMaker, StateDate)
            VALUES (@lastAccAccountMapId, null, null, null, null, null, @dynamicRuleDerivativePortfolioTradeId, null,
                    null, null, null,
                    null,
                    null,
                    N'CapitalGainLCY', N'TREX/DV/IRS', N'752', N'75201100', null, 1, @lastAccAccountMapOrderNo, N'',
                    null, null, @stateId,
                    @stateMaker,
                    @stateDate);

            select @lastAccAccountMapId = @lastAccAccountMapId + 1
            select @lastAccAccountMapOrderNo = @lastAccAccountMapOrderNo + 10
        end

    if not exists (select 1
                   from dbo.AccAccountMap
                   where Path = N'TREX/DV/IRS'
                     and Source = N'CapitalLossLCY'
                     and Target = N'87201100')
        begin
            INSERT INTO dbo.AccAccountMap (Id, Ccy, CustomerId, RuleId, Rule2Id, Rule3Id, Rule4Id, Rule5Id, Rule6Id,
                                           Rule7Id,
                                           Rule8Id, Rule9Id, Rule10Id, Source, Path, TargetMainGL, Target, TargetRuleId,
                                           IsEnabled,
                                           [Order], Description, CustomerCodeSourceRuleId,
                                           CustomerAccountCodeSourceRuleId,
                                           StateId,
                                           StateMaker, StateDate)
            VALUES (@lastAccAccountMapId, null, null, null, null, null, @dynamicRuleDerivativePortfolioTradeId, null,
                    null, null, null,
                    null,
                    null,
                    N'CapitalLossLCY', N'TREX/DV/IRS', N'872', N'87201100', null, 1, @lastAccAccountMapOrderNo, N'',
                    null, null, @stateId,
                    @stateMaker,
                    @stateDate);

            select @lastAccAccountMapId = @lastAccAccountMapId + 1
            select @lastAccAccountMapOrderNo = @lastAccAccountMapOrderNo + 10
        end

    if not exists (select 1
                   from dbo.AccAccountMap
                   where Path = N'TREX/DV/IRS'
                     and Source = N'TotalMTMLoss'
                     and Target = N'36400200')
        begin
            INSERT INTO dbo.AccAccountMap (Id, Ccy, CustomerId, RuleId, Rule2Id, Rule3Id, Rule4Id, Rule5Id, Rule6Id,
                                           Rule7Id,
                                           Rule8Id, Rule9Id, Rule10Id, Source, Path, TargetMainGL, Target, TargetRuleId,
                                           IsEnabled,
                                           [Order], Description, CustomerCodeSourceRuleId,
                                           CustomerAccountCodeSourceRuleId,
                                           StateId,
                                           StateMaker, StateDate)
            VALUES (@lastAccAccountMapId, null, null, null, null, @dynamicRuleReceiveLocalCurrencyId,
                    @dynamicRuleDerivativePortfolioTradeId,
                    null,
                    null, null, null, null, null, N'TotalMTMLoss', N'TREX/DV/IRS', N'364', N'36400200', null, 1,
                    @lastAccAccountMapOrderNo,
                    N'', null,
                    null, @stateId, @stateMaker, @stateDate);
        end

    --#endregion
    ------------------------------------------------------------------------------------------------------------------------
    -- Accounting Engine Item
    ------------------------------------------------------------------------------------------------------------------------
--#region accEngineItem
    if not exists(select 1
                  from dbo.accEngineItem
                  where Path = N'TREX/DV/')
        begin
            INSERT INTO dbo.AccEngineItem (Id, ItemCode, ParentId, Path, ModelDefinitionId, StateId, StateDate,
                                           StateMaker,
                                           TemplateId)
            VALUES (@lastAccEngineItemId, N'DV', 0, N'TREX/DV/', null, @stateId, @stateDate, @stateMaker, 1);
            select @lastAccEngineItemId = @lastAccEngineItemId + 1
        end
    if not exists(select 1
                  from dbo.accEngineItem
                  where Path = N'TREX/DV/IRS/')
        begin
            select @number = Id from dbo.accEngineItem where Path = N'TREX/DV/'
            INSERT INTO dbo.AccEngineItem (Id, ItemCode, ParentId, Path, ModelDefinitionId, StateId, StateDate,
                                           StateMaker,
                                           TemplateId)
            VALUES (@lastAccEngineItemId, N'IRS', @number, N'TREX/DV/IRS/', null, @stateId, @stateDate, @stateMaker, 1);
            select @lastAccEngineItemId = @lastAccEngineItemId + 1
        end
    if not exists(select 1
                  from dbo.accEngineItem
                  where Path = N'TREX/DV/IRS/LCYRLCYP/')
        begin
            select @number = Id from dbo.accEngineItem where Path = N'TREX/DV/IRS/'
            INSERT INTO dbo.AccEngineItem (Id, ItemCode, ParentId, Path, ModelDefinitionId, StateId, StateDate,
                                           StateMaker,
                                           TemplateId)
            output inserted.Id into @tempTable
            VALUES (@lastAccEngineItemId, N'LCYRLCYP', @number, N'TREX/DV/IRS/LCYRLCYP/',
                    @lastAccEngineModelDefinitionId,
                    @stateId, @stateDate,
                    @stateMaker, 1);
            SELECT @lcyItemId = Id FROM @tempTable;
            delete from @tempTable
            select @lastAccEngineItemId = @lastAccEngineItemId + 1
        end
    else
        begin
            select @lcyItemId = Id from dbo.AccEngineItem where Path = N'TREX/DV/IRS/LCYRLCYP/'
        end
    if not exists(select 1
                  from dbo.accEngineItem
                  where Path = N'TREX/DV/IRS/FCYRFCYP/')
        begin
            select @number = Id from dbo.accEngineItem where Path = N'TREX/DV/IRS/'
            INSERT INTO dbo.AccEngineItem (Id, ItemCode, ParentId, Path, ModelDefinitionId, StateId, StateDate,
                                           StateMaker,
                                           TemplateId)
            output inserted.Id into @tempTable
            VALUES (@lastAccEngineItemId, N'FCYRFCYP', @number, N'TREX/DV/IRS/FCYRFCYP/',
                    @lastAccEngineModelDefinitionId,
                    @stateId, @stateDate,
                    @stateMaker, 1);
            SELECT @fcyItemId = Id FROM @tempTable;
            delete from @tempTable
        end
    else
        begin
            select @fcyItemId = Id from dbo.AccEngineItem where Path = N'TREX/DV/IRS/FCYRFCYP/'
        end
    --#endregion
    ------------------------------------------------------------------------------------------------------------------------
    -- Accounting Engine Event Type
    ------------------------------------------------------------------------------------------------------------------------
--#region AccEngineEventType
    IF NOT EXISTS (SELECT 1
                   FROM dbo.AccEngineEventType
                   WHERE Code = N'OnMaturation')
        BEGIN
            INSERT INTO dbo.AccEngineEventType (Name, Code)
            VALUES (N'OnMaturation', N'OnMaturation');
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.AccEngineEventType
                   WHERE Code = N'OnOpening')
        BEGIN
            INSERT INTO dbo.AccEngineEventType (Name, Code)
            VALUES (N'OnOpening', N'OnOpening');
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.AccEngineEventType
                   WHERE Code = N'OnPayment')
        BEGIN
            INSERT INTO dbo.AccEngineEventType (Name, Code)
            VALUES (N'OnPayment', N'OnPayment');
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.AccEngineEventType
                   WHERE Code = N'OnRevaluation')
        BEGIN
            INSERT INTO dbo.AccEngineEventType (Name, Code)
            VALUES (N'OnRevaluation', N'OnRevaluation');
        END;

    --#endregion
    ------------------------------------------------------------------------------------------------------------------------
    -- Accounting Engine Event
    ------------------------------------------------------------------------------------------------------------------------
--#region accEngineEvent
------------------------------------------------------------------------------------------------------------------------
-- Acc Engine Event LCY
------------------------------------------------------------------------------------------------------------------------
    if not exists(select 1
                  from dbo.accEngineEvent
                  where ItemId = @lcyItemId
                    and EventTypeCode = N'OnOpening')
        begin
            INSERT INTO dbo.AccEngineEvent (Id, ItemId, EventTypeCode, ModifiedBy, ModifiedDate,
                                            EventDescriptionDynamicRuleId)
            output inserted.Id into @tempTable
            VALUES (@lastAccEngineEventId, @lcyItemId, N'OnOpening', @stateMaker, @stateDate, null);
            SELECT @lcyOpeningEventId = Id FROM @tempTable;
            delete from @tempTable
            select @lastAccEngineEventId = @lastAccEngineEventId + 1
        end
    else
        begin
            select @lcyOpeningEventId = Id
            from dbo.AccEngineEvent
            where ItemId = @lcyItemId
              and EventTypeCode = N'OnOpening'
        end
    if not exists(select 1
                  from dbo.accEngineEvent
                  where ItemId = @lcyItemId
                    and EventTypeCode = N'OnRevaluation')
        begin
            INSERT INTO dbo.AccEngineEvent (Id, ItemId, EventTypeCode, ModifiedBy, ModifiedDate,
                                            EventDescriptionDynamicRuleId)
            output inserted.Id into @tempTable
            VALUES (@lastAccEngineEventId, @lcyItemId, N'OnRevaluation', @stateMaker, @stateDate, null);
            SELECT @lcyRevaluationEventId = Id FROM @tempTable;
            delete from @tempTable
            select @lastAccEngineEventId = @lastAccEngineEventId + 1
        end
    else
        begin
            select @lcyRevaluationEventId = Id
            from dbo.AccEngineEvent
            where ItemId = @lcyItemId
              and EventTypeCode = N'OnRevaluation'
        end
    if not exists(select 1
                  from dbo.accEngineEvent
                  where ItemId = @lcyItemId
                    and EventTypeCode = N'OnPayment')
        begin
            INSERT INTO dbo.AccEngineEvent (Id, ItemId, EventTypeCode, ModifiedBy, ModifiedDate,
                                            EventDescriptionDynamicRuleId)
            output inserted.Id into @tempTable
            VALUES (@lastAccEngineEventId, @lcyItemId, N'OnPayment', @stateMaker, @stateDate, null);
            SELECT @lcyPaymentEventId = Id FROM @tempTable;
            delete from @tempTable
            select @lastAccEngineEventId = @lastAccEngineEventId + 1
        end
    else
        begin
            select @lcyPaymentEventId = Id
            from dbo.AccEngineEvent
            where ItemId = @lcyItemId
              and EventTypeCode = N'OnPayment'
        end
    if not exists(select 1
                  from dbo.accEngineEvent
                  where ItemId = @lcyItemId
                    and EventTypeCode = N'OnMaturation')
        begin
            INSERT INTO dbo.AccEngineEvent (Id, ItemId, EventTypeCode, ModifiedBy, ModifiedDate,
                                            EventDescriptionDynamicRuleId)
            output inserted.Id into @tempTable
            VALUES (@lastAccEngineEventId, @lcyItemId, N'OnMaturation', @stateMaker, @stateDate, null);
            SELECT @lcyMaturationEventId = Id FROM @tempTable;
            delete from @tempTable
            select @lastAccEngineEventId = @lastAccEngineEventId + 1
        end
    else
        begin
            select @lcyMaturationEventId = Id
            from dbo.AccEngineEvent
            where ItemId = @lcyItemId
              and EventTypeCode = N'OnMaturation'
        end

    ------------------------------------------------------------------------------------------------------------------------
-- Acc Engine Event FCY
------------------------------------------------------------------------------------------------------------------------
    if not exists(select 1
                  from dbo.accEngineEvent
                  where ItemId = @fcyItemId
                    and EventTypeCode = N'OnOpening')
        begin
            INSERT INTO dbo.AccEngineEvent (Id, ItemId, EventTypeCode, ModifiedBy, ModifiedDate,
                                            EventDescriptionDynamicRuleId)
            output inserted.Id into @tempTable
            VALUES (@lastAccEngineEventId, @fcyItemId, N'OnOpening', @stateMaker, @stateDate, null);
            SELECT @fcyOpeningEventId = Id FROM @tempTable;
            delete from @tempTable
            select @lastAccEngineEventId = @lastAccEngineEventId + 1
        end
    else
        begin
            select @fcyOpeningEventId = Id
            from dbo.AccEngineEvent
            where ItemId = @fcyItemId
              and EventTypeCode = N'OnOpening'
        end
    if not exists(select 1
                  from dbo.accEngineEvent
                  where ItemId = @fcyItemId
                    and EventTypeCode = N'OnRevaluation')
        begin
            INSERT INTO dbo.AccEngineEvent (Id, ItemId, EventTypeCode, ModifiedBy, ModifiedDate,
                                            EventDescriptionDynamicRuleId)
            output inserted.Id into @tempTable
            VALUES (@lastAccEngineEventId, @fcyItemId, N'OnRevaluation', @stateMaker, @stateDate, null);
            SELECT @fcyRevaluationEventId = Id FROM @tempTable;
            delete from @tempTable
            select @lastAccEngineEventId = @lastAccEngineEventId + 1
        end
    else
        begin
            select @fcyRevaluationEventId = Id
            from dbo.AccEngineEvent
            where ItemId = @fcyItemId
              and EventTypeCode = N'OnRevaluation'
        end
    if not exists(select 1
                  from dbo.accEngineEvent
                  where ItemId = @fcyItemId
                    and EventTypeCode = N'OnPayment')
        begin
            INSERT INTO dbo.AccEngineEvent (Id, ItemId, EventTypeCode, ModifiedBy, ModifiedDate,
                                            EventDescriptionDynamicRuleId)
            output inserted.Id into @tempTable
            VALUES (@lastAccEngineEventId, @fcyItemId, N'OnPayment', @stateMaker, @stateDate, null);
            SELECT @fcyPaymentEventId = Id FROM @tempTable;
            delete from @tempTable
            select @lastAccEngineEventId = @lastAccEngineEventId + 1
        end
    else
        begin
            select @fcyPaymentEventId = Id
            from dbo.AccEngineEvent
            where ItemId = @fcyItemId
              and EventTypeCode = N'OnPayment'
        end
    if not exists(select 1
                  from dbo.accEngineEvent
                  where ItemId = @fcyItemId
                    and EventTypeCode = N'OnMaturation')
        begin
            INSERT INTO dbo.AccEngineEvent (Id, ItemId, EventTypeCode, ModifiedBy, ModifiedDate,
                                            EventDescriptionDynamicRuleId)
            output inserted.Id into @tempTable
            VALUES (@lastAccEngineEventId, @fcyItemId, N'OnMaturation', @stateMaker, @stateDate, null);
            SELECT @fcyMaturationEventId = Id FROM @tempTable;
            delete from @tempTable
        end
    else
        begin
            select @fcyMaturationEventId = Id
            from dbo.AccEngineEvent
            where ItemId = @fcyItemId
              and EventTypeCode = N'OnMaturation'
        end
    --#endregion
    ------------------------------------------------------------------------------------------------------------------------
    -- Accounting Engine Group
    ------------------------------------------------------------------------------------------------------------------------
--#region AccEngineGroup
------------------------------------------------------------------------------------------------------------------------
-- Accounting Engine Group LCY
------------------------------------------------------------------------------------------------------------------------
    if not exists(select 1
                  from dbo.accEngineGroup
                  where EventId = @lcyOpeningEventId
                    and ValidationRuleId = @dynamicRuleValueDateGreaterThanLogicalDateId)
        begin
            INSERT INTO dbo.AccEngineGroup (Id, EventId, ValidationRuleId, [Order],
                                            ModifiedBy,
                                            ModifiedDate,
                                            StateId,
                                            StateDate,
                                            StateMaker)
            output inserted.Id into @tempTable
            VALUES (@lastAccEngineGroupId, @lcyOpeningEventId, @dynamicRuleValueDateGreaterThanLogicalDateId, 1,
                    @stateMaker,
                    @stateDate,
                    @stateId,
                    @stateDate,
                    @stateMaker);
            SELECT @lcyOpeningGroup1Id = Id FROM @tempTable;
            delete from @tempTable
            select @lastAccEngineGroupId = @lastAccEngineGroupId + 1
        end
    else
        begin
            select @lcyOpeningGroup1Id = Id
            from dbo.AccEngineGroup
            where EventId = @lcyOpeningEventId
              and ValidationRuleId = @dynamicRuleValueDateGreaterThanLogicalDateId
        end
    if not exists(select 1
                  from dbo.accEngineGroup
                  where EventId = @lcyOpeningEventId
                    and ValidationRuleId = @dynamicRuleValueDateLessThanOrEqualLogicalDateId)
        begin
            INSERT INTO dbo.AccEngineGroup (Id, EventId, ValidationRuleId, [Order],
                                            ModifiedBy,
                                            ModifiedDate,
                                            StateId,
                                            StateDate,
                                            StateMaker)
            output inserted.Id into @tempTable
            VALUES (@lastAccEngineGroupId, @lcyOpeningEventId, @dynamicRuleValueDateLessThanOrEqualLogicalDateId, 2,
                    @stateMaker,
                    @stateDate,
                    @stateId,
                    @stateDate,
                    @stateMaker);
            SELECT @lcyOpeningGroup2Id = Id FROM @tempTable;
            delete from @tempTable
            select @lastAccEngineGroupId = @lastAccEngineGroupId + 1
        end
    else
        begin
            select @lcyOpeningGroup2Id = Id
            from dbo.AccEngineGroup
            where EventId = @lcyOpeningEventId
              and ValidationRuleId = @dynamicRuleValueDateLessThanOrEqualLogicalDateId
        end
    if not exists(select 1
                  from dbo.accEngineGroup
                  where EventId = @lcyRevaluationEventId
                    and ValidationRuleId is null)
        begin
            INSERT INTO dbo.AccEngineGroup (Id, EventId, ValidationRuleId, [Order],
                                            ModifiedBy,
                                            ModifiedDate,
                                            StateId,
                                            StateDate,
                                            StateMaker)
            output inserted.Id into @tempTable
            VALUES (@lastAccEngineGroupId, @lcyRevaluationEventId, null, 1,
                    @stateMaker,
                    @stateDate,
                    @stateId,
                    @stateDate,
                    @stateMaker);
            SELECT @lcyRevaluationGroupId = Id FROM @tempTable;
            delete from @tempTable
            select @lastAccEngineGroupId = @lastAccEngineGroupId + 1
        end
    else
        begin
            select @lcyRevaluationGroupId = Id
            from dbo.AccEngineGroup
            where EventId = @lcyRevaluationEventId
              and ValidationRuleId is null
        end
    if not exists(select 1
                  from dbo.accEngineGroup
                  where EventId = @lcyPaymentEventId
                    and ValidationRuleId is null)
        begin
            INSERT INTO dbo.AccEngineGroup (Id, EventId, ValidationRuleId, [Order],
                                            ModifiedBy,
                                            ModifiedDate,
                                            StateId,
                                            StateDate,
                                            StateMaker)
            output inserted.Id into @tempTable
            VALUES (@lastAccEngineGroupId, @lcyPaymentEventId, null, 1,
                    @stateMaker,
                    @stateDate,
                    @stateId,
                    @stateDate,
                    @stateMaker);
            SELECT @lcyPaymentGroupId = Id FROM @tempTable;
            delete from @tempTable
            select @lastAccEngineGroupId = @lastAccEngineGroupId + 1
        end
    else
        begin
            select @lcyPaymentGroupId = Id
            from dbo.AccEngineGroup
            where EventId = @lcyPaymentEventId
              and ValidationRuleId is null
        end
    if not exists(select 1
                  from dbo.accEngineGroup
                  where EventId = @lcyMaturationEventId
                    and ValidationRuleId = @dynamicRuleMaturityDateEqualsLogicalDateId)
        begin
            INSERT INTO dbo.AccEngineGroup (Id, EventId, ValidationRuleId, [Order],
                                            ModifiedBy,
                                            ModifiedDate,
                                            StateId,
                                            StateDate,
                                            StateMaker)
            output inserted.Id into @tempTable
            VALUES (@lastAccEngineGroupId, @lcyMaturationEventId, @dynamicRuleMaturityDateEqualsLogicalDateId, 1,
                    @stateMaker,
                    @stateDate,
                    @stateId,
                    @stateDate,
                    @stateMaker);
            SELECT @lcyMaturationGroupId = Id FROM @tempTable;
            delete from @tempTable
            select @lastAccEngineGroupId = @lastAccEngineGroupId + 1
        end
    else
        begin
            select @lcyMaturationGroupId = Id
            from dbo.AccEngineGroup
            where EventId = @lcyMaturationEventId
              and ValidationRuleId = @dynamicRuleMaturityDateEqualsLogicalDateId
        end
    ------------------------------------------------------------------------------------------------------------------------
-- Accounting Engine Group FCY
------------------------------------------------------------------------------------------------------------------------
    if not exists(select 1
                  from dbo.accEngineGroup
                  where EventId = @fcyOpeningEventId
                    and ValidationRuleId = @dynamicRuleValueDateGreaterThanLogicalDateId)
        begin
            INSERT INTO dbo.AccEngineGroup (Id, EventId, ValidationRuleId, [Order],
                                            ModifiedBy,
                                            ModifiedDate,
                                            StateId,
                                            StateDate,
                                            StateMaker)
            output inserted.Id into @tempTable
            VALUES (@lastAccEngineGroupId, @fcyOpeningEventId, @dynamicRuleValueDateGreaterThanLogicalDateId, 1,
                    @stateMaker,
                    @stateDate,
                    @stateId,
                    @stateDate,
                    @stateMaker);
            SELECT @fcyOpeningGroup1Id = Id FROM @tempTable;
            delete from @tempTable
            select @lastAccEngineGroupId = @lastAccEngineGroupId + 1
        end
    else
        begin
            select @fcyOpeningGroup1Id = Id
            from dbo.AccEngineGroup
            where EventId = @fcyOpeningEventId
              and ValidationRuleId = @dynamicRuleValueDateGreaterThanLogicalDateId
        end
    if not exists(select 1
                  from dbo.accEngineGroup
                  where EventId = @fcyOpeningEventId
                    and ValidationRuleId = @dynamicRuleValueDateLessThanOrEqualLogicalDateId)
        begin
            INSERT INTO dbo.AccEngineGroup (Id, EventId, ValidationRuleId, [Order],
                                            ModifiedBy,
                                            ModifiedDate,
                                            StateId,
                                            StateDate,
                                            StateMaker)
            output inserted.Id into @tempTable
            VALUES (@lastAccEngineGroupId, @fcyOpeningEventId, @dynamicRuleValueDateLessThanOrEqualLogicalDateId, 2,
                    @stateMaker,
                    @stateDate,
                    @stateId,
                    @stateDate,
                    @stateMaker);
            SELECT @fcyOpeningGroup2Id = Id FROM @tempTable;
            delete from @tempTable
            select @lastAccEngineGroupId = @lastAccEngineGroupId + 1
        end
    else
        begin
            select @fcyOpeningGroup2Id = Id
            from dbo.AccEngineGroup
            where EventId = @fcyOpeningEventId
              and ValidationRuleId = @dynamicRuleValueDateLessThanOrEqualLogicalDateId
        end
    if not exists(select 1
                  from dbo.accEngineGroup
                  where EventId = @fcyRevaluationEventId
                    and ValidationRuleId is null)
        begin
            INSERT INTO dbo.AccEngineGroup (Id, EventId, ValidationRuleId, [Order],
                                            ModifiedBy,
                                            ModifiedDate,
                                            StateId,
                                            StateDate,
                                            StateMaker)
            output inserted.Id into @tempTable
            VALUES (@lastAccEngineGroupId, @fcyRevaluationEventId, null, 1,
                    @stateMaker,
                    @stateDate,
                    @stateId,
                    @stateDate,
                    @stateMaker);
            SELECT @fcyRevaluationGroupId = Id FROM @tempTable;
            delete from @tempTable
            select @lastAccEngineGroupId = @lastAccEngineGroupId + 1
        end
    else
        begin
            select @fcyRevaluationGroupId = Id
            from dbo.AccEngineGroup
            where EventId = @fcyRevaluationEventId
              and ValidationRuleId is null
        end
    if not exists(select 1
                  from dbo.accEngineGroup
                  where EventId = @fcyPaymentEventId
                    and ValidationRuleId is null)
        begin
            INSERT INTO dbo.AccEngineGroup (Id, EventId, ValidationRuleId, [Order],
                                            ModifiedBy,
                                            ModifiedDate,
                                            StateId,
                                            StateDate,
                                            StateMaker)
            output inserted.Id into @tempTable
            VALUES (@lastAccEngineGroupId, @fcyPaymentEventId, null, 1,
                    @stateMaker,
                    @stateDate,
                    @stateId,
                    @stateDate,
                    @stateMaker);
            SELECT @fcyPaymentGroupId = Id FROM @tempTable;
            delete from @tempTable
            select @lastAccEngineGroupId = @lastAccEngineGroupId + 1
        end
    else
        begin
            select @fcyPaymentGroupId = Id
            from dbo.AccEngineGroup
            where EventId = @fcyPaymentEventId
              and ValidationRuleId is null
        end
    if not exists(select 1
                  from dbo.accEngineGroup
                  where EventId = @fcyMaturationEventId
                    and ValidationRuleId = @dynamicRuleMaturityDateEqualsLogicalDateId)
        begin
            INSERT INTO dbo.AccEngineGroup (Id, EventId, ValidationRuleId, [Order],
                                            ModifiedBy,
                                            ModifiedDate,
                                            StateId,
                                            StateDate,
                                            StateMaker)
            output inserted.Id into @tempTable
            VALUES (@lastAccEngineGroupId, @fcyMaturationEventId, @dynamicRuleMaturityDateEqualsLogicalDateId, 1,
                    @stateMaker,
                    @stateDate,
                    @stateId,
                    @stateDate,
                    @stateMaker);
            SELECT @fcyMaturationGroupId = Id FROM @tempTable;
            delete from @tempTable
        end
    else
        begin
            select @fcyMaturationGroupId = Id
            from dbo.AccEngineGroup
            where EventId = @fcyMaturationEventId
              and ValidationRuleId = @dynamicRuleMaturityDateEqualsLogicalDateId
        end
    --#endregion
    ------------------------------------------------------------------------------------------------------------------------
    -- Accounting Engine Component
    ------------------------------------------------------------------------------------------------------------------------
--#region AccEngineComponent
    ------------------------------------------------------------------------------------------------------------------------
    -- Accounting Engine Component LCY
    ------------------------------------------------------------------------------------------------------------------------

    if not exists (select 1
                   from dbo.accEngineComponent
                   where GroupId = @lcyOpeningGroup1Id
                     and ComponentTypeCode = N'500')
        begin
            INSERT INTO dbo.AccEngineComponent (Id, GroupId, ComponentTypeCode, ValidationRuleId, [Order],
                                                ModifiedBy,
                                                ModifiedDate)
            output inserted.Id into @tempTable
            VALUES (@lastAccEngineComponentId, @lcyOpeningGroup1Id, N'500', null, 1,
                    @stateMaker,
                    @stateDate);
            SELECT @lcyOpeningGroup1Component1Id = Id FROM @tempTable;
            delete from @tempTable
            select @lastAccEngineComponentId = @lastAccEngineComponentId + 1
        end
    else
        begin
            select @lcyOpeningGroup1Component1Id = Id
            from dbo.AccEngineComponent
            where GroupId = @lcyOpeningGroup1Id
              and ComponentTypeCode = N'500'
        end

    if not exists (select 1
                   from dbo.accEngineComponent
                   where GroupId = @lcyOpeningGroup1Id
                     and ComponentTypeCode = N'501')
        begin
            INSERT INTO dbo.AccEngineComponent (Id, GroupId, ComponentTypeCode, ValidationRuleId, [Order],
                                                ModifiedBy,
                                                ModifiedDate)
            output inserted.Id into @tempTable
            VALUES (@lastAccEngineComponentId, @lcyOpeningGroup1Id, N'501', null, 2,
                    @stateMaker,
                    @stateDate);
            SELECT @lcyOpeningGroup1Component2Id = Id FROM @tempTable;
            delete from @tempTable
            select @lastAccEngineComponentId = @lastAccEngineComponentId + 1
        end
    else
        begin
            select @lcyOpeningGroup1Component2Id = Id
            from dbo.AccEngineComponent
            where GroupId = @lcyOpeningGroup1Id
              and ComponentTypeCode = N'501'
        end

    if not exists (select 1
                   from dbo.accEngineComponent
                   where GroupId = @lcyOpeningGroup2Id
                     and ComponentTypeCode = N'500')
        begin
            INSERT INTO dbo.AccEngineComponent (Id, GroupId, ComponentTypeCode, ValidationRuleId, [Order], ModifiedBy,
                                                ModifiedDate)
            output inserted.Id into @tempTable
            VALUES (@lastAccEngineComponentId, @lcyOpeningGroup2Id, N'500', @dynamicRuleValueDateGreaterThanTradeDateId,
                    1,
                    @stateMaker,
                    @stateDate);
            SELECT @lcyOpeningGroup2Component1Id = Id FROM @tempTable;
            delete from @tempTable
            select @lastAccEngineComponentId = @lastAccEngineComponentId + 1
        end
    else
        begin
            select @lcyOpeningGroup2Component1Id = Id
            from dbo.AccEngineComponent
            where GroupId = @lcyOpeningGroup2Id
              and ComponentTypeCode = N'500'
        end

    if not exists (select 1
                   from dbo.accEngineComponent
                   where GroupId = @lcyOpeningGroup2Id
                     and ComponentTypeCode = N'501')
        begin
            INSERT INTO dbo.AccEngineComponent (Id, GroupId, ComponentTypeCode, ValidationRuleId, [Order], ModifiedBy,
                                                ModifiedDate)
            output inserted.Id into @tempTable
            VALUES (@lastAccEngineComponentId, @lcyOpeningGroup2Id, N'501',
                    @dynamicRuleValueDateLessThanOrEqualTradeDateId,
                    2,
                    @stateMaker,
                    @stateDate);
            SELECT @lcyOpeningGroup2Component2Id = Id FROM @tempTable;
            delete from @tempTable
            select @lastAccEngineComponentId = @lastAccEngineComponentId + 1
        end
    else
        begin
            select @lcyOpeningGroup2Component2Id = Id
            from dbo.AccEngineComponent
            where GroupId = @lcyOpeningGroup2Id
              and ComponentTypeCode = N'501'
        end

    IF NOT exists(select 1
                  from dbo.accEngineComponent
                  where GroupId = @lcyRevaluationGroupId
                    and ComponentTypeCode = N'508')
        begin
            INSERT INTO dbo.AccEngineComponent (Id, GroupId, ComponentTypeCode, ValidationRuleId, [Order], ModifiedBy,
                                                ModifiedDate)
            output inserted.Id into @tempTable
            VALUES (@lastAccEngineComponentId, @lcyRevaluationGroupId, N'508', @dynamicRuleDerivativeSwapMTMProfitId, 1,
                    @stateMaker,
                    @stateDate);
            SELECT @lcyRevaluationGroupComponent1Id = Id FROM @tempTable;
            delete from @tempTable
            select @lastAccEngineComponentId = @lastAccEngineComponentId + 1
        end
    else
        begin
            select @lcyRevaluationGroupComponent1Id = Id
            from dbo.AccEngineComponent
            where GroupId = @lcyRevaluationGroupId
              and ComponentTypeCode = N'508'
        end

    IF NOT exists(select 1
                  from dbo.accEngineComponent
                  where GroupId = @lcyRevaluationGroupId
                    and ComponentTypeCode = N'509')
        begin
            INSERT INTO dbo.AccEngineComponent (Id, GroupId, ComponentTypeCode, ValidationRuleId, [Order], ModifiedBy,
                                                ModifiedDate)
            output inserted.Id into @tempTable
            VALUES (@lastAccEngineComponentId, @lcyRevaluationGroupId, N'509', @dynamicRuleDerivativeSwapMTMLossId, 2,
                    @stateMaker, @stateDate);
            SELECT @lcyRevaluationGroupComponent2Id = Id FROM @tempTable;
            delete from @tempTable
            select @lastAccEngineComponentId = @lastAccEngineComponentId + 1
        end
    else
        begin
            select @lcyRevaluationGroupComponent2Id = Id
            from dbo.AccEngineComponent
            where GroupId = @lcyRevaluationGroupId
              and ComponentTypeCode = N'509'
        end

    IF NOT exists(select 1
                  from dbo.accEngineComponent
                  where GroupId = @lcyPaymentGroupId
                    and ComponentTypeCode = N'506')
        begin
            INSERT INTO dbo.AccEngineComponent (Id, GroupId, ComponentTypeCode, ValidationRuleId, [Order], ModifiedBy,
                                                ModifiedDate)
            output inserted.Id into @tempTable
            VALUES (@lastAccEngineComponentId, @lcyPaymentGroupId, N'506',
                    @dynamicRulePeriodEndDateLogicalDateAndNetPaymentPositiveId,
                    1,
                    @stateMaker,
                    @stateDate);
            SELECT @lcyPaymentGroupComponent1Id = Id FROM @tempTable;
            delete from @tempTable
            select @lastAccEngineComponentId = @lastAccEngineComponentId + 1
        end
    else
        begin
            select @lcyPaymentGroupComponent1Id = Id
            from dbo.AccEngineComponent
            where GroupId = @lcyPaymentGroupId
              and ComponentTypeCode = N'506'
        end

    IF NOT exists(select 1
                  from dbo.accEngineComponent
                  where GroupId = @lcyPaymentGroupId
                    and ComponentTypeCode = N'507')
        begin
            INSERT INTO dbo.AccEngineComponent (Id, GroupId, ComponentTypeCode, ValidationRuleId, [Order], ModifiedBy,
                                                ModifiedDate)
            output inserted.Id into @tempTable
            VALUES (@lastAccEngineComponentId, @lcyPaymentGroupId, N'507',
                    @dynamicRulePeriodEndDateLogicalDateAndNetPaymentNegativeId,
                    2,
                    @stateMaker,
                    @stateDate);
            SELECT @lcyPaymentGroupComponent2Id = Id FROM @tempTable;
            delete from @tempTable
            select @lastAccEngineComponentId = @lastAccEngineComponentId + 1
        end
    else
        begin
            select @lcyPaymentGroupComponent2Id = Id
            from dbo.AccEngineComponent
            where GroupId = @lcyPaymentGroupId
              and ComponentTypeCode = N'507'
        end

    IF NOT exists(select 1
                  from dbo.accEngineComponent
                  where GroupId = @lcyMaturationGroupId
                    and ComponentTypeCode = N'501')
        begin
            INSERT INTO dbo.AccEngineComponent (Id, GroupId, ComponentTypeCode, ValidationRuleId, [Order],
                                                ModifiedBy,
                                                ModifiedDate)
            output inserted.Id into @tempTable
            VALUES (@lastAccEngineComponentId, @lcyMaturationGroupId, N'501',
                    null,
                    1,
                    @stateMaker,
                    @stateDate);
            SELECT @lcyMaturationGroupComponent1Id = Id FROM @tempTable;
            delete from @tempTable
            select @lastAccEngineComponentId = @lastAccEngineComponentId + 1
        end
    else
        begin
            select @lcyMaturationGroupComponent1Id = Id
            from dbo.AccEngineComponent
            where GroupId = @lcyMaturationGroupId
              and ComponentTypeCode = N'501'
        end

    if not exists (select 1
                   from dbo.accEngineComponent
                   where GroupId = @lcyMaturationGroupId
                     and ComponentTypeCode = N'110')
        begin
            INSERT INTO dbo.AccEngineComponent (Id, GroupId, ComponentTypeCode, ValidationRuleId, [Order], ModifiedBy,
                                                ModifiedDate)
            output inserted.Id into @tempTable
            VALUES (@lastAccEngineComponentId, @lcyMaturationGroupId,
                    N'110',
                    null,
                    4,
                    @stateMaker,
                    @stateDate);
            SELECT @lcyMaturationGroupComponent2Id = Id FROM @tempTable;
            delete from @tempTable
            select @lastAccEngineComponentId = @lastAccEngineComponentId + 1
        end
    else
        begin
            select @lcyMaturationGroupComponent2Id = Id
            from dbo.AccEngineComponent
            where GroupId = @lcyMaturationGroupId
              and ComponentTypeCode = N'110'
        end

    ------------------------------------------------------------------------------------------------------------------------
    -- Accounting Engine Component FCY
    ------------------------------------------------------------------------------------------------------------------------

    if not exists (select 1
                   from dbo.accEngineComponent
                   where GroupId = @fcyOpeningGroup1Id
                     and ComponentTypeCode = N'500')
        begin
            INSERT INTO dbo.AccEngineComponent (Id, GroupId, ComponentTypeCode, ValidationRuleId, [Order],
                                                ModifiedBy,
                                                ModifiedDate)
            output inserted.Id into @tempTable
            VALUES (@lastAccEngineComponentId, @fcyOpeningGroup1Id, N'500', null, 1,
                    @stateMaker,
                    @stateDate);
            SELECT @fcyOpeningGroup1Component1Id = Id FROM @tempTable;
            delete from @tempTable
            select @lastAccEngineComponentId = @lastAccEngineComponentId + 1
        end
    else
        begin
            select @fcyOpeningGroup1Component1Id = Id
            from dbo.AccEngineComponent
            where GroupId = @fcyOpeningGroup1Id
              and ComponentTypeCode = N'500'
        end

    if not exists (select 1
                   from dbo.accEngineComponent
                   where GroupId = @fcyOpeningGroup1Id
                     and ComponentTypeCode = N'501')
        begin
            INSERT INTO dbo.AccEngineComponent (Id, GroupId, ComponentTypeCode, ValidationRuleId, [Order],
                                                ModifiedBy,
                                                ModifiedDate)
            output inserted.Id into @tempTable
            VALUES (@lastAccEngineComponentId, @fcyOpeningGroup1Id, N'501', null, 2,
                    @stateMaker,
                    @stateDate);
            SELECT @fcyOpeningGroup1Component2Id = Id FROM @tempTable;
            delete from @tempTable
            select @lastAccEngineComponentId = @lastAccEngineComponentId + 1
        end
    else
        begin
            select @fcyOpeningGroup1Component2Id = Id
            from dbo.AccEngineComponent
            where GroupId = @fcyOpeningGroup1Id
              and ComponentTypeCode = N'501'
        end

    if not exists (select 1
                   from dbo.accEngineComponent
                   where GroupId = @fcyOpeningGroup2Id
                     and ComponentTypeCode = N'500')
        begin
            INSERT INTO dbo.AccEngineComponent (Id, GroupId, ComponentTypeCode, ValidationRuleId, [Order], ModifiedBy,
                                                ModifiedDate)
            output inserted.Id into @tempTable
            VALUES (@lastAccEngineComponentId, @fcyOpeningGroup2Id, N'500', @dynamicRuleValueDateGreaterThanTradeDateId,
                    1,
                    @stateMaker,
                    @stateDate);
            SELECT @fcyOpeningGroup2Component1Id = Id FROM @tempTable;
            delete from @tempTable
            select @lastAccEngineComponentId = @lastAccEngineComponentId + 1
        end
    else
        begin
            select @fcyOpeningGroup2Component1Id = Id
            from dbo.AccEngineComponent
            where GroupId = @fcyOpeningGroup2Id
              and ComponentTypeCode = N'500'
        end

    if not exists (select 1
                   from dbo.accEngineComponent
                   where GroupId = @fcyOpeningGroup2Id
                     and ComponentTypeCode = N'501')
        begin
            INSERT INTO dbo.AccEngineComponent (Id, GroupId, ComponentTypeCode, ValidationRuleId, [Order], ModifiedBy,
                                                ModifiedDate)
            output inserted.Id into @tempTable
            VALUES (@lastAccEngineComponentId, @fcyOpeningGroup2Id, N'501',
                    @dynamicRuleValueDateLessThanOrEqualTradeDateId,
                    2,
                    @stateMaker,
                    @stateDate);
            SELECT @fcyOpeningGroup2Component2Id = Id FROM @tempTable;
            delete from @tempTable
            select @lastAccEngineComponentId = @lastAccEngineComponentId + 1
        end
    else
        begin
            select @fcyOpeningGroup2Component2Id = Id
            from dbo.AccEngineComponent
            where GroupId = @fcyOpeningGroup2Id
              and ComponentTypeCode = N'501'
        end

    IF NOT exists(select 1
                  from dbo.accEngineComponent
                  where GroupId = @fcyRevaluationGroupId
                    and ComponentTypeCode = N'508')
        begin
            INSERT INTO dbo.AccEngineComponent (Id, GroupId, ComponentTypeCode, ValidationRuleId, [Order], ModifiedBy,
                                                ModifiedDate)
            output inserted.Id into @tempTable
            VALUES (@lastAccEngineComponentId, @fcyRevaluationGroupId, N'508', @dynamicRuleDerivativeSwapMTMProfitId, 1,
                    @stateMaker,
                    @stateDate);
            SELECT @fcyRevaluationGroupComponent1Id = Id FROM @tempTable;
            delete from @tempTable
            select @lastAccEngineComponentId = @lastAccEngineComponentId + 1
        end
    else
        begin
            select @fcyRevaluationGroupComponent1Id = Id
            from dbo.AccEngineComponent
            where GroupId = @fcyRevaluationGroupId
              and ComponentTypeCode = N'508'
        end

    IF NOT exists(select 1
                  from dbo.accEngineComponent
                  where GroupId = @fcyRevaluationGroupId
                    and ComponentTypeCode = N'509')
        begin
            INSERT INTO dbo.AccEngineComponent (Id, GroupId, ComponentTypeCode, ValidationRuleId, [Order], ModifiedBy,
                                                ModifiedDate)
            output inserted.Id into @tempTable
            VALUES (@lastAccEngineComponentId, @fcyRevaluationGroupId, N'509', @dynamicRuleDerivativeSwapMTMLossId, 2,
                    @stateMaker, @stateDate);
            SELECT @fcyRevaluationGroupComponent2Id = Id FROM @tempTable;
            delete from @tempTable
            select @lastAccEngineComponentId = @lastAccEngineComponentId + 1
        end
    else
        begin
            select @fcyRevaluationGroupComponent2Id = Id
            from dbo.AccEngineComponent
            where GroupId = @fcyRevaluationGroupId
              and ComponentTypeCode = N'509'
        end

    IF NOT exists(select 1
                  from dbo.accEngineComponent
                  where GroupId = @fcyPaymentGroupId
                    and ComponentTypeCode = N'506')
        begin
            INSERT INTO dbo.AccEngineComponent (Id, GroupId, ComponentTypeCode, ValidationRuleId, [Order], ModifiedBy,
                                                ModifiedDate)
            output inserted.Id into @tempTable
            VALUES (@lastAccEngineComponentId, @fcyPaymentGroupId, N'506',
                    @dynamicRulePeriodEndDateLogicalDateAndNetPaymentPositiveId,
                    1,
                    @stateMaker,
                    @stateDate);
            SELECT @fcyPaymentGroupComponent1Id = Id FROM @tempTable;
            delete from @tempTable
            select @lastAccEngineComponentId = @lastAccEngineComponentId + 1
        end
    else
        begin
            select @fcyPaymentGroupComponent1Id = Id
            from dbo.AccEngineComponent
            where GroupId = @fcyPaymentGroupId
              and ComponentTypeCode = N'506'
        end

    IF NOT exists(select 1
                  from dbo.accEngineComponent
                  where GroupId = @fcyPaymentGroupId
                    and ComponentTypeCode = N'507')
        begin
            INSERT INTO dbo.AccEngineComponent (Id, GroupId, ComponentTypeCode, ValidationRuleId, [Order], ModifiedBy,
                                                ModifiedDate)
            output inserted.Id into @tempTable
            VALUES (@lastAccEngineComponentId, @fcyPaymentGroupId, N'507',
                    @dynamicRulePeriodEndDateLogicalDateAndNetPaymentNegativeId,
                    2,
                    @stateMaker,
                    @stateDate);
            SELECT @fcyPaymentGroupComponent2Id = Id FROM @tempTable;
            delete from @tempTable
            select @lastAccEngineComponentId = @lastAccEngineComponentId + 1
        end
    else
        begin
            select @fcyPaymentGroupComponent2Id = Id
            from dbo.AccEngineComponent
            where GroupId = @fcyPaymentGroupId
              and ComponentTypeCode = N'507'
        end

    IF NOT exists(select 1
                  from dbo.accEngineComponent
                  where GroupId = @fcyMaturationGroupId
                    and ComponentTypeCode = N'501')
        begin
            INSERT INTO dbo.AccEngineComponent (Id, GroupId, ComponentTypeCode, ValidationRuleId, [Order],
                                                ModifiedBy,
                                                ModifiedDate)
            output inserted.Id into @tempTable
            VALUES (@lastAccEngineComponentId, @fcyMaturationGroupId, N'501',
                    null,
                    1,
                    @stateMaker,
                    @stateDate);
            SELECT @fcyMaturationGroupComponent1Id = Id FROM @tempTable;
            delete from @tempTable
            select @lastAccEngineComponentId = @lastAccEngineComponentId + 1
        end
    else
        begin
            select @fcyMaturationGroupComponent1Id = Id
            from dbo.AccEngineComponent
            where GroupId = @fcyMaturationGroupId
              and ComponentTypeCode = N'501'
        end

    if not exists (select 1
                   from dbo.accEngineComponent
                   where GroupId = @fcyMaturationGroupId
                     and ComponentTypeCode = N'110')
        begin
            INSERT INTO dbo.AccEngineComponent (Id, GroupId, ComponentTypeCode, ValidationRuleId, [Order], ModifiedBy,
                                                ModifiedDate)
            output inserted.Id into @tempTable
            VALUES (@lastAccEngineComponentId, @fcyMaturationGroupId,
                    N'110',
                    null,
                    2,
                    @stateMaker,
                    @stateDate);
            SELECT @fcyMaturationGroupComponent2Id = Id FROM @tempTable;
            delete from @tempTable
            select @lastAccEngineComponentId = @lastAccEngineComponentId + 1
        end
    else
        begin
            select @fcyMaturationGroupComponent2Id = Id
            from dbo.AccEngineComponent
            where GroupId = @fcyMaturationGroupId
              and ComponentTypeCode = N'110'
        end

    --#endregion
    ------------------------------------------------------------------------------------------------------------------------
    -- Accounting Engine Rule
    ------------------------------------------------------------------------------------------------------------------------
--#region AccEngineAccountRule
    ------------------------------------------------------------------------------------------------------------------------
    -- Accounting Engine Rule LCY
    ------------------------------------------------------------------------------------------------------------------------

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @lcyOpeningGroup1Component1Id
                    and GLCode = N'ValPayContingent')
        begin
            INSERT INTO dbo.AccEngineAccountRule (Id, ComponentId, GLCode, CustomerCodeSource,
                                                  CustomerAccountCodeSource,
                                                  DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                  ValueDateSource, TxnDateSource, CcySource, FcySource, LcyEqvtSource,
                                                  FcyAmtSource, ReverseRebook, CommentSource, CommentRuleId, ModifiedBy,
                                                  ModifiedDate, ReverseTxnDateSource, ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @lcyOpeningGroup1Component1Id, N'ValPayContingent', null, null,
                    N'Debit',
                    null, N'PayPrincipalAmount', N'TxnNo', N'LogicalDate', N'LogicalDate', N'PayCurrency',
                    N'PayCurrency',
                    N'PayPrincipalAmount', N'PayPrincipalAmount', 0, null, null, @stateMaker, @stateDate, null, null);
            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @lcyOpeningGroup1Component1Id
                    and GLCode = N'ValPayContingentOffset')
        begin
            INSERT INTO dbo.AccEngineAccountRule (Id, ComponentId, GLCode, CustomerCodeSource,
                                                  CustomerAccountCodeSource,
                                                  DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                  ValueDateSource,
                                                  TxnDateSource, CcySource, FcySource, LcyEqvtSource, FcyAmtSource,
                                                  ReverseRebook,
                                                  CommentSource, CommentRuleId, ModifiedBy, ModifiedDate,
                                                  ReverseTxnDateSource,
                                                  ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @lcyOpeningGroup1Component1Id, N'ValPayContingentOffset', null, null,
                    N'Credit',
                    null, N'PayPrincipalAmount', N'TxnNo', N'LogicalDate', N'LogicalDate', N'PayCurrency',
                    N'PayCurrency',
                    N'PayPrincipalAmount', N'PayPrincipalAmount', 0, null, null, @stateMaker, @stateDate, null, null);
            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @lcyOpeningGroup1Component1Id
                    and GLCode = N'ValRecContingentOffset')
        begin
            INSERT INTO dbo.AccEngineAccountRule (Id, ComponentId, GLCode, CustomerCodeSource,
                                                  CustomerAccountCodeSource,
                                                  DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                  ValueDateSource,
                                                  TxnDateSource, CcySource, FcySource, LcyEqvtSource, FcyAmtSource,
                                                  ReverseRebook,
                                                  CommentSource, CommentRuleId, ModifiedBy, ModifiedDate,
                                                  ReverseTxnDateSource,
                                                  ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @lcyOpeningGroup1Component1Id, N'ValRecContingentOffset', null, null,
                    N'Debit',
                    null, N'ReceivePrincipalAmount', N'TxnNo', N'LogicalDate', N'LogicalDate', N'ReceiveCurrency',
                    N'ReceiveCurrency', N'ReceivePrincipalAmount', N'ReceivePrincipalAmount', 0, null, null,
                    @stateMaker,
                    @stateDate, null, null);
            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @lcyOpeningGroup1Component1Id
                    and GLCode = N'ValRecContingent')
        begin
            INSERT INTO dbo.AccEngineAccountRule (Id, ComponentId, GLCode, CustomerCodeSource,
                                                  CustomerAccountCodeSource,
                                                  DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                  ValueDateSource,
                                                  TxnDateSource, CcySource, FcySource, LcyEqvtSource, FcyAmtSource,
                                                  ReverseRebook,
                                                  CommentSource, CommentRuleId, ModifiedBy, ModifiedDate,
                                                  ReverseTxnDateSource,
                                                  ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @lcyOpeningGroup1Component1Id, N'ValRecContingent', null, null,
                    N'Credit',
                    null,
                    N'ReceivePrincipalAmount', N'TxnNo', N'LogicalDate', N'LogicalDate', N'ReceiveCurrency',
                    N'ReceiveCurrency',
                    N'ReceivePrincipalAmount', N'ReceivePrincipalAmount', 0, null, null, @stateMaker, @stateDate, null,
                    null);
            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @lcyOpeningGroup1Component2Id
                    and GLCode = N'MatPayContingentOffset')
        begin
            INSERT INTO dbo.AccEngineAccountRule (Id, ComponentId, GLCode, CustomerCodeSource,
                                                  CustomerAccountCodeSource,
                                                  DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                  ValueDateSource,
                                                  TxnDateSource, CcySource, FcySource, LcyEqvtSource, FcyAmtSource,
                                                  ReverseRebook,
                                                  CommentSource, CommentRuleId, ModifiedBy, ModifiedDate,
                                                  ReverseTxnDateSource,
                                                  ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @lcyOpeningGroup1Component2Id, N'MatPayContingentOffset', null, null,
                    N'Debit',
                    null, N'PayPrincipalAmount', N'TxnNo', N'PayValueDate', N'PayValueDate', N'PayCurrency',
                    N'PayCurrency',
                    N'PayPrincipalAmount', N'PayPrincipalAmount', 0, null, null, @stateMaker, @stateDate, null, null);
            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @lcyOpeningGroup1Component2Id
                    and GLCode = N'MatPayContingent')
        begin
            INSERT INTO dbo.AccEngineAccountRule (Id, ComponentId, GLCode, CustomerCodeSource,
                                                  CustomerAccountCodeSource,
                                                  DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                  ValueDateSource,
                                                  TxnDateSource, CcySource, FcySource, LcyEqvtSource, FcyAmtSource,
                                                  ReverseRebook,
                                                  CommentSource, CommentRuleId, ModifiedBy, ModifiedDate,
                                                  ReverseTxnDateSource,
                                                  ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @lcyOpeningGroup1Component2Id, N'MatPayContingent', null, null,
                    N'Credit',
                    null,
                    N'PayPrincipalAmount', N'TxnNo', N'PayValueDate', N'PayValueDate', N'PayCurrency', N'PayCurrency',
                    N'PayPrincipalAmount', N'PayPrincipalAmount', 0, null, null, @stateMaker, @stateDate, null, null);
            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @lcyOpeningGroup1Component2Id
                    and GLCode = N'MatRecContingent')
        begin
            INSERT INTO dbo.AccEngineAccountRule (Id, ComponentId, GLCode, CustomerCodeSource,
                                                  CustomerAccountCodeSource,
                                                  DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                  ValueDateSource,
                                                  TxnDateSource, CcySource, FcySource, LcyEqvtSource, FcyAmtSource,
                                                  ReverseRebook,
                                                  CommentSource, CommentRuleId, ModifiedBy, ModifiedDate,
                                                  ReverseTxnDateSource,
                                                  ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @lcyOpeningGroup1Component2Id, N'MatRecContingent', null, null,
                    N'Debit',
                    null,
                    N'ReceivePrincipalAmount', N'TxnNo', N'LogicalDate', N'LogicalDate', N'ReceiveCurrency',
                    N'ReceiveCurrency',
                    N'ReceivePrincipalAmount', N'ReceivePrincipalAmount', 0, null, null, @stateMaker, @stateDate, null,
                    null);
            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @lcyOpeningGroup1Component2Id
                    and GLCode = N'MatRecContingentOffset')
        begin
            INSERT INTO dbo.AccEngineAccountRule (Id, ComponentId, GLCode, CustomerCodeSource,
                                                  CustomerAccountCodeSource,
                                                  DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                  ValueDateSource,
                                                  TxnDateSource, CcySource, FcySource, LcyEqvtSource, FcyAmtSource,
                                                  ReverseRebook,
                                                  CommentSource, CommentRuleId, ModifiedBy, ModifiedDate,
                                                  ReverseTxnDateSource,
                                                  ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @lcyOpeningGroup1Component2Id, N'MatRecContingentOffset', null, null,
                    N'Credit',
                    null, N'ReceivePrincipalAmount', N'TxnNo', N'LogicalDate', N'LogicalDate', N'ReceiveCurrency',
                    N'ReceiveCurrency', N'ReceivePrincipalAmount', N'ReceivePrincipalAmount', 0, null, null,
                    @stateMaker,
                    @stateDate, null, null);
            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @lcyOpeningGroup2Component1Id
                    and GLCode = N'ValPayContingentOffset')
        begin
            INSERT INTO dbo.AccEngineAccountRule (Id, ComponentId, GLCode, CustomerCodeSource,
                                                  CustomerAccountCodeSource,
                                                  DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                  ValueDateSource,
                                                  TxnDateSource, CcySource, FcySource, LcyEqvtSource, FcyAmtSource,
                                                  ReverseRebook,
                                                  CommentSource, CommentRuleId, ModifiedBy, ModifiedDate,
                                                  ReverseTxnDateSource,
                                                  ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @lcyOpeningGroup2Component1Id, N'ValPayContingentOffset', null, null,
                    N'Debit',
                    null, N'PayPrincipalAmount', N'TxnNo', N'LogicalDate', N'LogicalDate', N'PayCurrency',
                    N'PayCurrency',
                    N'PayPrincipalAmount', N'PayPrincipalAmount', 0, null, null, @stateMaker, @stateDate, null, null);
            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @lcyOpeningGroup2Component1Id
                    and GLCode = N'ValPayContingent')
        begin
            INSERT INTO dbo.AccEngineAccountRule (Id, ComponentId, GLCode, CustomerCodeSource,
                                                  CustomerAccountCodeSource,
                                                  DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                  ValueDateSource,
                                                  TxnDateSource, CcySource, FcySource, LcyEqvtSource, FcyAmtSource,
                                                  ReverseRebook,
                                                  CommentSource, CommentRuleId, ModifiedBy, ModifiedDate,
                                                  ReverseTxnDateSource,
                                                  ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @lcyOpeningGroup2Component1Id, N'ValPayContingent', null, null,
                    N'Credit',
                    null,
                    N'PayPrincipalAmount', N'TxnNo', N'LogicalDate', N'LogicalDate', N'PayCurrency', N'PayCurrency',
                    N'PayPrincipalAmount', N'PayPrincipalAmount', 0, null, null, @stateMaker, @stateDate, null, null);
            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @lcyOpeningGroup2Component1Id
                    and GLCode = N'ValRecContingent')
        begin
            INSERT INTO dbo.AccEngineAccountRule (Id, ComponentId, GLCode, CustomerCodeSource,
                                                  CustomerAccountCodeSource,
                                                  DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                  ValueDateSource,
                                                  TxnDateSource, CcySource, FcySource, LcyEqvtSource, FcyAmtSource,
                                                  ReverseRebook,
                                                  CommentSource, CommentRuleId, ModifiedBy, ModifiedDate,
                                                  ReverseTxnDateSource,
                                                  ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @lcyOpeningGroup2Component1Id, N'ValRecContingent', null, null,
                    N'Debit',
                    null,
                    N'ReceivePrincipalAmount', N'TxnNo', N'LogicalDate', N'LogicalDate', N'ReceiveCurrency',
                    N'ReceiveCurrency',
                    N'ReceivePrincipalAmount', N'ReceivePrincipalAmount', 0, null, null, @stateMaker, @stateDate, null,
                    null);
            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @lcyOpeningGroup2Component1Id
                    and GLCode = N'ValRecContingentOffset')
        begin
            INSERT INTO dbo.AccEngineAccountRule (Id, ComponentId, GLCode, CustomerCodeSource,
                                                  CustomerAccountCodeSource,
                                                  DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                  ValueDateSource,
                                                  TxnDateSource, CcySource, FcySource, LcyEqvtSource, FcyAmtSource,
                                                  ReverseRebook,
                                                  CommentSource, CommentRuleId, ModifiedBy, ModifiedDate,
                                                  ReverseTxnDateSource,
                                                  ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @lcyOpeningGroup2Component1Id, N'ValRecContingentOffset', null, null,
                    N'Credit',
                    null, N'ReceivePrincipalAmount', N'TxnNo', N'LogicalDate', N'LogicalDate', N'ReceiveCurrency',
                    N'ReceiveCurrency', N'ReceivePrincipalAmount', N'ReceivePrincipalAmount', 0, null, null,
                    @stateMaker,
                    @stateDate, null, null);
            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @lcyOpeningGroup2Component2Id
                    and GLCode = N'MatPayContingentOffset')
        begin
            INSERT INTO dbo.AccEngineAccountRule (Id, ComponentId, GLCode, CustomerCodeSource,
                                                  CustomerAccountCodeSource,
                                                  DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                  ValueDateSource,
                                                  TxnDateSource, CcySource, FcySource, LcyEqvtSource, FcyAmtSource,
                                                  ReverseRebook,
                                                  CommentSource, CommentRuleId, ModifiedBy, ModifiedDate,
                                                  ReverseTxnDateSource,
                                                  ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @lcyOpeningGroup2Component2Id, N'MatPayContingentOffset', null, null,
                    N'Debit',
                    null, N'PayPrincipalAmount', N'TxnNo', N'LogicalDate', N'LogicalDate', N'PayCurrency',
                    N'PayCurrency',
                    N'PayPrincipalAmount', N'PayPrincipalAmount', 0, null, null, @stateMaker, @stateDate, null, null);
            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @lcyOpeningGroup2Component2Id
                    and GLCode = N'MatPayContingent')
        begin
            INSERT INTO dbo.AccEngineAccountRule (Id, ComponentId, GLCode, CustomerCodeSource,
                                                  CustomerAccountCodeSource,
                                                  DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                  ValueDateSource,
                                                  TxnDateSource, CcySource, FcySource, LcyEqvtSource, FcyAmtSource,
                                                  ReverseRebook,
                                                  CommentSource, CommentRuleId, ModifiedBy, ModifiedDate,
                                                  ReverseTxnDateSource,
                                                  ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @lcyOpeningGroup2Component2Id, N'MatPayContingent', null, null,
                    N'Credit',
                    null,
                    N'PayPrincipalAmount', N'TxnNo', N'LogicalDate', N'LogicalDate', N'PayCurrency', N'PayCurrency',
                    N'PayPrincipalAmount', N'PayPrincipalAmount', 0, null, null, @stateMaker, @stateDate, null, null);
            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @lcyOpeningGroup2Component2Id
                    and GLCode = N'MatRecContingent')
        begin
            INSERT INTO dbo.AccEngineAccountRule (Id, ComponentId, GLCode, CustomerCodeSource,
                                                  CustomerAccountCodeSource,
                                                  DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                  ValueDateSource,
                                                  TxnDateSource, CcySource, FcySource, LcyEqvtSource, FcyAmtSource,
                                                  ReverseRebook,
                                                  CommentSource, CommentRuleId, ModifiedBy, ModifiedDate,
                                                  ReverseTxnDateSource,
                                                  ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @lcyOpeningGroup2Component2Id, N'MatRecContingent', null, null,
                    N'Debit',
                    null,
                    N'ReceivePrincipalAmount', N'TxnNo', N'LogicalDate', N'LogicalDate', N'ReceiveCurrency',
                    N'ReceiveCurrency',
                    N'ReceivePrincipalAmount', N'ReceivePrincipalAmount', 0, null, null, @stateMaker, @stateDate, null,
                    null);
            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @lcyOpeningGroup2Component2Id
                    and GLCode = N'MatRecContingentOffset')
        begin
            INSERT INTO dbo.AccEngineAccountRule (Id, ComponentId, GLCode, CustomerCodeSource,
                                                  CustomerAccountCodeSource,
                                                  DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                  ValueDateSource,
                                                  TxnDateSource, CcySource, FcySource, LcyEqvtSource, FcyAmtSource,
                                                  ReverseRebook,
                                                  CommentSource, CommentRuleId, ModifiedBy, ModifiedDate,
                                                  ReverseTxnDateSource,
                                                  ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @lcyOpeningGroup2Component2Id, N'MatRecContingentOffset', null, null,
                    N'Credit',
                    null, N'ReceivePrincipalAmount', N'TxnNo', N'LogicalDate', N'LogicalDate', N'ReceiveCurrency',
                    N'ReceiveCurrency', N'ReceivePrincipalAmount', N'ReceivePrincipalAmount', 0, null, null,
                    @stateMaker,
                    @stateDate, null, null);
            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @lcyRevaluationGroupComponent1Id
                    and GLCode = N'TotalMTMProfit')
        begin
            INSERT INTO dbo.AccEngineAccountRule (Id, ComponentId, GLCode, CustomerCodeSource,
                                                  CustomerAccountCodeSource,
                                                  DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                  ValueDateSource,
                                                  TxnDateSource, CcySource, FcySource, LcyEqvtSource, FcyAmtSource,
                                                  ReverseRebook,
                                                  CommentSource, CommentRuleId, ModifiedBy, ModifiedDate,
                                                  ReverseTxnDateSource,
                                                  ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @lcyRevaluationGroupComponent1Id, N'TotalMTMProfit', null, null,
                    N'Debit',
                    null,
                    N'TotalMTMAmount', N'TxnNo', N'LogicalDate', N'LogicalDate', N'LocalCCY', N'LocalCCY',
                    N'TotalMTMAmount',
                    N'TotalMTMAmount', 0, null, null, @stateMaker, N'2025-01-15 15:21:59.690', null, null);
            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @lcyRevaluationGroupComponent1Id
                    and GLCode = N'CapitalGainLCY')
        begin
            INSERT INTO dbo.AccEngineAccountRule (Id, ComponentId, GLCode, CustomerCodeSource,
                                                  CustomerAccountCodeSource,
                                                  DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                  ValueDateSource,
                                                  TxnDateSource, CcySource, FcySource, LcyEqvtSource, FcyAmtSource,
                                                  ReverseRebook,
                                                  CommentSource, CommentRuleId, ModifiedBy, ModifiedDate,
                                                  ReverseTxnDateSource,
                                                  ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @lcyRevaluationGroupComponent1Id, N'CapitalGainLCY', null, null,
                    N'Credit',
                    null,
                    N'TotalMTMAmount', N'TxnNo', N'LogicalDate', N'LogicalDate', N'LocalCCY', N'LocalCCY',
                    N'TotalMTMAmount',
                    N'TotalMTMAmount', 0, null, null, @stateMaker, N'2025-01-15 15:21:59.693', null, null);
            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @lcyRevaluationGroupComponent2Id
                    and GLCode = N'CapitalLossLCY')
        begin
            INSERT INTO dbo.AccEngineAccountRule (Id, ComponentId, GLCode, CustomerCodeSource,
                                                  CustomerAccountCodeSource,
                                                  DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                  ValueDateSource,
                                                  TxnDateSource, CcySource, FcySource, LcyEqvtSource, FcyAmtSource,
                                                  ReverseRebook,
                                                  CommentSource, CommentRuleId, ModifiedBy, ModifiedDate,
                                                  ReverseTxnDateSource,
                                                  ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @lcyRevaluationGroupComponent2Id, N'CapitalLossLCY', null, null,
                    N'Debit',
                    null,
                    N'TotalMTMAmount', N'TxnNo', N'LogicalDate', N'LogicalDate', N'LocalCCY', N'LocalCCY',
                    N'TotalMTMAmount',
                    N'TotalMTMAmount', 0, null, null, @stateMaker, N'2025-01-15 15:21:59.710', null, null);
            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @lcyRevaluationGroupComponent2Id
                    and GLCode = N'TotalMTMLoss')
        begin
            INSERT INTO dbo.AccEngineAccountRule (Id, ComponentId, GLCode, CustomerCodeSource,
                                                  CustomerAccountCodeSource,
                                                  DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                  ValueDateSource,
                                                  TxnDateSource, CcySource, FcySource, LcyEqvtSource, FcyAmtSource,
                                                  ReverseRebook,
                                                  CommentSource, CommentRuleId, ModifiedBy, ModifiedDate,
                                                  ReverseTxnDateSource,
                                                  ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @lcyRevaluationGroupComponent2Id, N'TotalMTMLoss', null, null,
                    N'Credit',
                    null,
                    N'TotalMTMAmount', N'TxnNo', N'LogicalDate', N'LogicalDate', N'LocalCCY', N'LocalCCY',
                    N'TotalMTMAmount',
                    N'TotalMTMAmount', 0, null, null, @stateMaker, N'2025-01-15 15:21:59.713', null, null);
            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @lcyPaymentGroupComponent1Id
                    and GLCode = N'IncomingPaymentLCY')
        begin
            INSERT INTO dbo.AccEngineAccountRule (Id, ComponentId, GLCode, CustomerCodeSource,
                                                  CustomerAccountCodeSource,
                                                  DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                  ValueDateSource,
                                                  TxnDateSource, CcySource, FcySource, LcyEqvtSource, FcyAmtSource,
                                                  ReverseRebook,
                                                  CommentSource, CommentRuleId, ModifiedBy, ModifiedDate,
                                                  ReverseTxnDateSource,
                                                  ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @lcyPaymentGroupComponent1Id, N'IncomingPaymentLCY', null, null,
                    N'Debit',
                    null,
                    N'NetPeriodEndAmount', N'TxnNo', N'LogicalDate', N'LogicalDate', N'ReceiveCurrency',
                    N'ReceiveCurrency',
                    N'NetPeriodEndAmount', N'NetPeriodEndAmount', 0, null, null, @stateMaker,
                    N'2025-01-19 20:06:26.360',
                    null, null);
            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @lcyPaymentGroupComponent1Id
                    and GLCode = N'InterestIncome')
        begin
            INSERT INTO dbo.AccEngineAccountRule (Id, ComponentId, GLCode, CustomerCodeSource,
                                                  CustomerAccountCodeSource,
                                                  DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                  ValueDateSource,
                                                  TxnDateSource, CcySource, FcySource, LcyEqvtSource, FcyAmtSource,
                                                  ReverseRebook,
                                                  CommentSource, CommentRuleId, ModifiedBy, ModifiedDate,
                                                  ReverseTxnDateSource,
                                                  ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @lcyPaymentGroupComponent1Id, N'InterestIncome', null, null, N'Credit',
                    null,
                    N'NetPeriodEndAmountLCY', N'TxnNo', N'LogicalDate', N'LogicalDate', N'ReceiveCurrency',
                    N'ReceiveCurrency',
                    N'NetPeriodEndAmountLCY', N'NetPeriodEndAmountLCY', 0, null, null, @stateMaker,
                    N'2025-01-19 20:06:26.600', null,
                    null);
            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @lcyPaymentGroupComponent2Id
                    and GLCode = N'InterestExpense')
        begin
            INSERT INTO dbo.AccEngineAccountRule (Id, ComponentId, GLCode, CustomerCodeSource,
                                                  CustomerAccountCodeSource,
                                                  DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                  ValueDateSource,
                                                  TxnDateSource, CcySource, FcySource, LcyEqvtSource, FcyAmtSource,
                                                  ReverseRebook,
                                                  CommentSource, CommentRuleId, ModifiedBy, ModifiedDate,
                                                  ReverseTxnDateSource,
                                                  ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @lcyPaymentGroupComponent2Id, N'InterestExpense', null, null, N'Debit',
                    null,
                    N'NetPeriodEndAmountLCY', N'TxnNo', N'LogicalDate', N'LogicalDate', N'PayCurrency', N'PayCurrency',
                    N'NetPeriodEndAmountLCY', N'NetPeriodEndAmountLCY', 0, null, null, @stateMaker,
                    N'2025-01-19 20:06:27.047', null,
                    null);
            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @lcyPaymentGroupComponent2Id
                    and GLCode = N'OutgoingPaymentLCY')
        begin
            INSERT INTO dbo.AccEngineAccountRule (Id, ComponentId, GLCode, CustomerCodeSource,
                                                  CustomerAccountCodeSource,
                                                  DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                  ValueDateSource,
                                                  TxnDateSource, CcySource, FcySource, LcyEqvtSource, FcyAmtSource,
                                                  ReverseRebook,
                                                  CommentSource, CommentRuleId, ModifiedBy, ModifiedDate,
                                                  ReverseTxnDateSource,
                                                  ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @lcyPaymentGroupComponent2Id, N'OutgoingPaymentLCY', null, null,
                    N'Credit',
                    null,
                    N'NetPeriodEndAmount', N'TxnNo', N'LogicalDate', N'LogicalDate', N'PayCurrency', N'PayCurrency',
                    N'NetPeriodEndAmount', N'NetPeriodEndAmount', 0, null, null, @stateMaker,
                    N'2025-01-19 20:06:27.243',
                    null, null);
            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @lcyMaturationGroupComponent1Id
                    and GLCode = N'MatPayContingent')
        begin
            INSERT INTO dbo.AccEngineAccountRule (Id, ComponentId, GLCode, CustomerCodeSource,
                                                  CustomerAccountCodeSource,
                                                  DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                  ValueDateSource,
                                                  TxnDateSource, CcySource, FcySource, LcyEqvtSource, FcyAmtSource,
                                                  ReverseRebook,
                                                  CommentSource, CommentRuleId, ModifiedBy, ModifiedDate,
                                                  ReverseTxnDateSource,
                                                  ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @lcyMaturationGroupComponent1Id, N'MatPayContingent', null, null,
                    N'Debit',
                    null,
                    N'PayPrincipalAmount', N'TxnNo', N'LogicalDate', N'LogicalDate', N'PayCurrency', N'PayCurrency',
                    N'PayPrincipalAmount', N'PayPrincipalAmount', 0, null, null, @stateMaker,
                    N'2024-12-23 11:43:20.667',
                    null,
                    null);
            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @lcyMaturationGroupComponent1Id
                    and GLCode = N'MatRecContingentOffset')
        begin
            INSERT INTO dbo.AccEngineAccountRule (Id, ComponentId, GLCode, CustomerCodeSource,
                                                  CustomerAccountCodeSource,
                                                  DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                  ValueDateSource,
                                                  TxnDateSource, CcySource, FcySource, LcyEqvtSource, FcyAmtSource,
                                                  ReverseRebook,
                                                  CommentSource, CommentRuleId, ModifiedBy, ModifiedDate,
                                                  ReverseTxnDateSource,
                                                  ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @lcyMaturationGroupComponent1Id, N'MatRecContingentOffset', null, null,
                    N'Debit',
                    null, N'ReceivePrincipalAmount', N'TxnNo', N'LogicalDate', N'LogicalDate', N'ReceiveCurrency',
                    N'ReceiveCurrency', N'ReceivePrincipalAmount', N'ReceivePrincipalAmount', 0, null, null,
                    @stateMaker,
                    N'2024-12-23 11:43:20.670', null, null);
            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @lcyMaturationGroupComponent1Id
                    and GLCode = N'MatPayContingentOffset')
        begin
            INSERT INTO dbo.AccEngineAccountRule (Id, ComponentId, GLCode, CustomerCodeSource,
                                                  CustomerAccountCodeSource,
                                                  DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                  ValueDateSource,
                                                  TxnDateSource, CcySource, FcySource, LcyEqvtSource, FcyAmtSource,
                                                  ReverseRebook,
                                                  CommentSource, CommentRuleId, ModifiedBy, ModifiedDate,
                                                  ReverseTxnDateSource,
                                                  ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @lcyMaturationGroupComponent1Id, N'MatPayContingentOffset', null, null,
                    N'Credit',
                    null, N'PayPrincipalAmount', N'TxnNo', N'LogicalDate', N'LogicalDate', N'PayCurrency',
                    N'PayCurrency',
                    N'PayPrincipalAmount', N'PayPrincipalAmount', 0, null, null, @stateMaker,
                    N'2024-12-23 11:43:20.670',
                    null,
                    null);
            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @lcyMaturationGroupComponent1Id
                    and GLCode = N'MatRecContingent')
        begin
            INSERT INTO dbo.AccEngineAccountRule (Id, ComponentId, GLCode, CustomerCodeSource,
                                                  CustomerAccountCodeSource,
                                                  DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                  ValueDateSource,
                                                  TxnDateSource, CcySource, FcySource, LcyEqvtSource, FcyAmtSource,
                                                  ReverseRebook,
                                                  CommentSource, CommentRuleId, ModifiedBy, ModifiedDate,
                                                  ReverseTxnDateSource,
                                                  ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @lcyMaturationGroupComponent1Id, N'MatRecContingent', null, null,
                    N'Credit',
                    null,
                    N'ReceivePrincipalAmount', N'TxnNo', N'LogicalDate', N'LogicalDate', N'ReceiveCurrency',
                    N'ReceiveCurrency',
                    N'ReceivePrincipalAmount', N'ReceivePrincipalAmount', 0, null, null, @stateMaker,
                    N'2024-12-23 11:43:20.673',
                    null, null);
            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @lcyMaturationGroupComponent2Id
                    and GLCode = N'83000000')
        begin
            INSERT INTO dbo.accEngineAccountRule(Id, ComponentId, GLCode, CustomerCodeSource, CustomerAccountCodeSource,
                                                 DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                 ValueDateSource, TxnDateSource, CcySource, FcySource, LcyEqvtSource,
                                                 FcyAmtSource, ReverseRebook, CommentSource, CommentRuleId, ModifiedBy,
                                                 ModifiedDate, ReverseTxnDateSource, ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @lcyMaturationGroupComponent2Id, N'83000000', null, null,
                    N'Debit', null, N'TaxAmount', N'TxnNo', N'LogicalDate', N'LogicalDate', N'LocalCCY', N'LocalCCY',
                    N'TaxAmount', N'TaxAmount', 0, null, null, @stateMaker, @stateDate, null, null);

            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @lcyMaturationGroupComponent2Id
                    and GLCode = N'38000500')
        begin
            INSERT INTO dbo.accEngineAccountRule(Id, ComponentId, GLCode, CustomerCodeSource, CustomerAccountCodeSource,
                                                 DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                 ValueDateSource, TxnDateSource, CcySource, FcySource, LcyEqvtSource,
                                                 FcyAmtSource, ReverseRebook, CommentSource, CommentRuleId, ModifiedBy,
                                                 ModifiedDate, ReverseTxnDateSource, ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @lcyMaturationGroupComponent2Id, N'38000500', null, null,
                    N'Credit', null, N'TaxAmount', N'TxnNo', N'LogicalDate', N'LogicalDate', N'LocalCCY', N'LocalCCY',
                    N'TaxAmount', N'TaxAmount', 0, null, null, @stateMaker, @stateDate, null, null);

            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    ------------------------------------------------------------------------------------------------------------------------
    -- Accounting Engine Rule FCY
    ------------------------------------------------------------------------------------------------------------------------

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @fcyOpeningGroup1Component1Id
                    and GLCode = N'ValPayContingent')
        begin
            INSERT INTO dbo.AccEngineAccountRule (Id, ComponentId, GLCode, CustomerCodeSource,
                                                  CustomerAccountCodeSource,
                                                  DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                  ValueDateSource, TxnDateSource, CcySource, FcySource, lcyEqvtSource,
                                                  FcyAmtSource, ReverseRebook, CommentSource, CommentRuleId, ModifiedBy,
                                                  ModifiedDate, ReverseTxnDateSource, ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @fcyOpeningGroup1Component1Id, N'ValPayContingent', null, null,
                    N'Debit',
                    null, N'PayPrincipalAmount', N'TxnNo', N'LogicalDate', N'LogicalDate', N'PayCurrency',
                    N'PayCurrency',
                    N'PayPrincipalAmount', N'PayPrincipalAmount', 0, null, null, @stateMaker, @stateDate, null, null);
            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @fcyOpeningGroup1Component1Id
                    and GLCode = N'ValPayContingentOffset')
        begin
            INSERT INTO dbo.AccEngineAccountRule (Id, ComponentId, GLCode, CustomerCodeSource,
                                                  CustomerAccountCodeSource,
                                                  DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                  ValueDateSource,
                                                  TxnDateSource, CcySource, FcySource, lcyEqvtSource, FcyAmtSource,
                                                  ReverseRebook,
                                                  CommentSource, CommentRuleId, ModifiedBy, ModifiedDate,
                                                  ReverseTxnDateSource,
                                                  ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @fcyOpeningGroup1Component1Id, N'ValPayContingentOffset', null, null,
                    N'Credit',
                    null, N'PayPrincipalAmount', N'TxnNo', N'LogicalDate', N'LogicalDate', N'PayCurrency',
                    N'PayCurrency',
                    N'PayPrincipalAmount', N'PayPrincipalAmount', 0, null, null, @stateMaker, @stateDate, null, null);
            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @fcyOpeningGroup1Component1Id
                    and GLCode = N'ValRecContingentOffset')
        begin
            INSERT INTO dbo.AccEngineAccountRule (Id, ComponentId, GLCode, CustomerCodeSource,
                                                  CustomerAccountCodeSource,
                                                  DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                  ValueDateSource,
                                                  TxnDateSource, CcySource, FcySource, lcyEqvtSource, FcyAmtSource,
                                                  ReverseRebook,
                                                  CommentSource, CommentRuleId, ModifiedBy, ModifiedDate,
                                                  ReverseTxnDateSource,
                                                  ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @fcyOpeningGroup1Component1Id, N'ValRecContingentOffset', null, null,
                    N'Debit',
                    null, N'ReceivePrincipalAmount', N'TxnNo', N'LogicalDate', N'LogicalDate', N'ReceiveCurrency',
                    N'ReceiveCurrency', N'ReceivePrincipalAmount', N'ReceivePrincipalAmount', 0, null, null,
                    @stateMaker,
                    @stateDate, null, null);
            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @fcyOpeningGroup1Component1Id
                    and GLCode = N'ValRecContingent')
        begin
            INSERT INTO dbo.AccEngineAccountRule (Id, ComponentId, GLCode, CustomerCodeSource,
                                                  CustomerAccountCodeSource,
                                                  DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                  ValueDateSource,
                                                  TxnDateSource, CcySource, FcySource, lcyEqvtSource, FcyAmtSource,
                                                  ReverseRebook,
                                                  CommentSource, CommentRuleId, ModifiedBy, ModifiedDate,
                                                  ReverseTxnDateSource,
                                                  ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @fcyOpeningGroup1Component1Id, N'ValRecContingent', null, null,
                    N'Credit',
                    null,
                    N'ReceivePrincipalAmount', N'TxnNo', N'LogicalDate', N'LogicalDate', N'ReceiveCurrency',
                    N'ReceiveCurrency',
                    N'ReceivePrincipalAmount', N'ReceivePrincipalAmount', 0, null, null, @stateMaker, @stateDate, null,
                    null);
            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @fcyOpeningGroup1Component2Id
                    and GLCode = N'MatPayContingentOffset')
        begin
            INSERT INTO dbo.AccEngineAccountRule (Id, ComponentId, GLCode, CustomerCodeSource,
                                                  CustomerAccountCodeSource,
                                                  DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                  ValueDateSource,
                                                  TxnDateSource, CcySource, FcySource, lcyEqvtSource, FcyAmtSource,
                                                  ReverseRebook,
                                                  CommentSource, CommentRuleId, ModifiedBy, ModifiedDate,
                                                  ReverseTxnDateSource,
                                                  ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @fcyOpeningGroup1Component2Id, N'MatPayContingentOffset', null, null,
                    N'Debit',
                    null, N'PayPrincipalAmount', N'TxnNo', N'PayValueDate', N'PayValueDate', N'PayCurrency',
                    N'PayCurrency',
                    N'PayPrincipalAmount', N'PayPrincipalAmount', 0, null, null, @stateMaker, @stateDate, null, null);
            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @fcyOpeningGroup1Component2Id
                    and GLCode = N'MatPayContingent')
        begin
            INSERT INTO dbo.AccEngineAccountRule (Id, ComponentId, GLCode, CustomerCodeSource,
                                                  CustomerAccountCodeSource,
                                                  DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                  ValueDateSource,
                                                  TxnDateSource, CcySource, FcySource, lcyEqvtSource, FcyAmtSource,
                                                  ReverseRebook,
                                                  CommentSource, CommentRuleId, ModifiedBy, ModifiedDate,
                                                  ReverseTxnDateSource,
                                                  ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @fcyOpeningGroup1Component2Id, N'MatPayContingent', null, null,
                    N'Credit',
                    null,
                    N'PayPrincipalAmount', N'TxnNo', N'PayValueDate', N'PayValueDate', N'PayCurrency', N'PayCurrency',
                    N'PayPrincipalAmount', N'PayPrincipalAmount', 0, null, null, @stateMaker, @stateDate, null, null);
            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @fcyOpeningGroup1Component2Id
                    and GLCode = N'MatRecContingent')
        begin
            INSERT INTO dbo.AccEngineAccountRule (Id, ComponentId, GLCode, CustomerCodeSource,
                                                  CustomerAccountCodeSource,
                                                  DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                  ValueDateSource,
                                                  TxnDateSource, CcySource, FcySource, lcyEqvtSource, FcyAmtSource,
                                                  ReverseRebook,
                                                  CommentSource, CommentRuleId, ModifiedBy, ModifiedDate,
                                                  ReverseTxnDateSource,
                                                  ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @fcyOpeningGroup1Component2Id, N'MatRecContingent', null, null,
                    N'Debit',
                    null,
                    N'ReceivePrincipalAmount', N'TxnNo', N'LogicalDate', N'LogicalDate', N'ReceiveCurrency',
                    N'ReceiveCurrency',
                    N'ReceivePrincipalAmount', N'ReceivePrincipalAmount', 0, null, null, @stateMaker, @stateDate, null,
                    null);
            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @fcyOpeningGroup1Component2Id
                    and GLCode = N'MatRecContingentOffset')
        begin
            INSERT INTO dbo.AccEngineAccountRule (Id, ComponentId, GLCode, CustomerCodeSource,
                                                  CustomerAccountCodeSource,
                                                  DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                  ValueDateSource,
                                                  TxnDateSource, CcySource, FcySource, lcyEqvtSource, FcyAmtSource,
                                                  ReverseRebook,
                                                  CommentSource, CommentRuleId, ModifiedBy, ModifiedDate,
                                                  ReverseTxnDateSource,
                                                  ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @fcyOpeningGroup1Component2Id, N'MatRecContingentOffset', null, null,
                    N'Credit',
                    null, N'ReceivePrincipalAmount', N'TxnNo', N'LogicalDate', N'LogicalDate', N'ReceiveCurrency',
                    N'ReceiveCurrency', N'ReceivePrincipalAmount', N'ReceivePrincipalAmount', 0, null, null,
                    @stateMaker,
                    @stateDate, null, null);
            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @fcyOpeningGroup2Component1Id
                    and GLCode = N'ValPayContingentOffset')
        begin
            INSERT INTO dbo.AccEngineAccountRule (Id, ComponentId, GLCode, CustomerCodeSource,
                                                  CustomerAccountCodeSource,
                                                  DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                  ValueDateSource,
                                                  TxnDateSource, CcySource, FcySource, lcyEqvtSource, FcyAmtSource,
                                                  ReverseRebook,
                                                  CommentSource, CommentRuleId, ModifiedBy, ModifiedDate,
                                                  ReverseTxnDateSource,
                                                  ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @fcyOpeningGroup2Component1Id, N'ValPayContingentOffset', null, null,
                    N'Debit',
                    null, N'PayPrincipalAmount', N'TxnNo', N'LogicalDate', N'LogicalDate', N'PayCurrency',
                    N'PayCurrency',
                    N'PayPrincipalAmount', N'PayPrincipalAmount', 0, null, null, @stateMaker, @stateDate, null, null);
            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @fcyOpeningGroup2Component1Id
                    and GLCode = N'ValPayContingent')
        begin
            INSERT INTO dbo.AccEngineAccountRule (Id, ComponentId, GLCode, CustomerCodeSource,
                                                  CustomerAccountCodeSource,
                                                  DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                  ValueDateSource,
                                                  TxnDateSource, CcySource, FcySource, lcyEqvtSource, FcyAmtSource,
                                                  ReverseRebook,
                                                  CommentSource, CommentRuleId, ModifiedBy, ModifiedDate,
                                                  ReverseTxnDateSource,
                                                  ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @fcyOpeningGroup2Component1Id, N'ValPayContingent', null, null,
                    N'Credit',
                    null,
                    N'PayPrincipalAmount', N'TxnNo', N'LogicalDate', N'LogicalDate', N'PayCurrency', N'PayCurrency',
                    N'PayPrincipalAmount', N'PayPrincipalAmount', 0, null, null, @stateMaker, @stateDate, null, null);
            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @fcyOpeningGroup2Component1Id
                    and GLCode = N'ValRecContingent')
        begin
            INSERT INTO dbo.AccEngineAccountRule (Id, ComponentId, GLCode, CustomerCodeSource,
                                                  CustomerAccountCodeSource,
                                                  DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                  ValueDateSource,
                                                  TxnDateSource, CcySource, FcySource, lcyEqvtSource, FcyAmtSource,
                                                  ReverseRebook,
                                                  CommentSource, CommentRuleId, ModifiedBy, ModifiedDate,
                                                  ReverseTxnDateSource,
                                                  ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @fcyOpeningGroup2Component1Id, N'ValRecContingent', null, null,
                    N'Debit',
                    null,
                    N'ReceivePrincipalAmount', N'TxnNo', N'LogicalDate', N'LogicalDate', N'ReceiveCurrency',
                    N'ReceiveCurrency',
                    N'ReceivePrincipalAmount', N'ReceivePrincipalAmount', 0, null, null, @stateMaker, @stateDate, null,
                    null);
            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @fcyOpeningGroup2Component1Id
                    and GLCode = N'ValRecContingentOffset')
        begin
            INSERT INTO dbo.AccEngineAccountRule (Id, ComponentId, GLCode, CustomerCodeSource,
                                                  CustomerAccountCodeSource,
                                                  DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                  ValueDateSource,
                                                  TxnDateSource, CcySource, FcySource, lcyEqvtSource, FcyAmtSource,
                                                  ReverseRebook,
                                                  CommentSource, CommentRuleId, ModifiedBy, ModifiedDate,
                                                  ReverseTxnDateSource,
                                                  ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @fcyOpeningGroup2Component1Id, N'ValRecContingentOffset', null, null,
                    N'Credit',
                    null, N'ReceivePrincipalAmount', N'TxnNo', N'LogicalDate', N'LogicalDate', N'ReceiveCurrency',
                    N'ReceiveCurrency', N'ReceivePrincipalAmount', N'ReceivePrincipalAmount', 0, null, null,
                    @stateMaker,
                    @stateDate, null, null);
            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @fcyOpeningGroup2Component2Id
                    and GLCode = N'MatPayContingentOffset')
        begin
            INSERT INTO dbo.AccEngineAccountRule (Id, ComponentId, GLCode, CustomerCodeSource,
                                                  CustomerAccountCodeSource,
                                                  DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                  ValueDateSource,
                                                  TxnDateSource, CcySource, FcySource, lcyEqvtSource, FcyAmtSource,
                                                  ReverseRebook,
                                                  CommentSource, CommentRuleId, ModifiedBy, ModifiedDate,
                                                  ReverseTxnDateSource,
                                                  ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @fcyOpeningGroup2Component2Id, N'MatPayContingentOffset', null, null,
                    N'Debit',
                    null, N'PayPrincipalAmount', N'TxnNo', N'LogicalDate', N'LogicalDate', N'PayCurrency',
                    N'PayCurrency',
                    N'PayPrincipalAmount', N'PayPrincipalAmount', 0, null, null, @stateMaker, @stateDate, null, null);
            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @fcyOpeningGroup2Component2Id
                    and GLCode = N'MatPayContingent')
        begin
            INSERT INTO dbo.AccEngineAccountRule (Id, ComponentId, GLCode, CustomerCodeSource,
                                                  CustomerAccountCodeSource,
                                                  DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                  ValueDateSource,
                                                  TxnDateSource, CcySource, FcySource, lcyEqvtSource, FcyAmtSource,
                                                  ReverseRebook,
                                                  CommentSource, CommentRuleId, ModifiedBy, ModifiedDate,
                                                  ReverseTxnDateSource,
                                                  ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @fcyOpeningGroup2Component2Id, N'MatPayContingent', null, null,
                    N'Credit',
                    null,
                    N'PayPrincipalAmount', N'TxnNo', N'LogicalDate', N'LogicalDate', N'PayCurrency', N'PayCurrency',
                    N'PayPrincipalAmount', N'PayPrincipalAmount', 0, null, null, @stateMaker, @stateDate, null, null);
            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @fcyOpeningGroup2Component2Id
                    and GLCode = N'MatRecContingent')
        begin
            INSERT INTO dbo.AccEngineAccountRule (Id, ComponentId, GLCode, CustomerCodeSource,
                                                  CustomerAccountCodeSource,
                                                  DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                  ValueDateSource,
                                                  TxnDateSource, CcySource, FcySource, lcyEqvtSource, FcyAmtSource,
                                                  ReverseRebook,
                                                  CommentSource, CommentRuleId, ModifiedBy, ModifiedDate,
                                                  ReverseTxnDateSource,
                                                  ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @fcyOpeningGroup2Component2Id, N'MatRecContingent', null, null,
                    N'Debit',
                    null,
                    N'ReceivePrincipalAmount', N'TxnNo', N'LogicalDate', N'LogicalDate', N'ReceiveCurrency',
                    N'ReceiveCurrency',
                    N'ReceivePrincipalAmount', N'ReceivePrincipalAmount', 0, null, null, @stateMaker, @stateDate, null,
                    null);
            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @fcyOpeningGroup2Component2Id
                    and GLCode = N'MatRecContingentOffset')
        begin
            INSERT INTO dbo.AccEngineAccountRule (Id, ComponentId, GLCode, CustomerCodeSource,
                                                  CustomerAccountCodeSource,
                                                  DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                  ValueDateSource,
                                                  TxnDateSource, CcySource, FcySource, lcyEqvtSource, FcyAmtSource,
                                                  ReverseRebook,
                                                  CommentSource, CommentRuleId, ModifiedBy, ModifiedDate,
                                                  ReverseTxnDateSource,
                                                  ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @fcyOpeningGroup2Component2Id, N'MatRecContingentOffset', null, null,
                    N'Credit',
                    null, N'ReceivePrincipalAmount', N'TxnNo', N'LogicalDate', N'LogicalDate', N'ReceiveCurrency',
                    N'ReceiveCurrency', N'ReceivePrincipalAmount', N'ReceivePrincipalAmount', 0, null, null,
                    @stateMaker,
                    @stateDate, null, null);
            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @fcyRevaluationGroupComponent1Id
                    and GLCode = N'TotalMTMProfit')
        begin
            INSERT INTO dbo.AccEngineAccountRule (Id, ComponentId, GLCode, CustomerCodeSource,
                                                  CustomerAccountCodeSource,
                                                  DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                  ValueDateSource,
                                                  TxnDateSource, CcySource, FcySource, LcyEqvtSource, FcyAmtSource,
                                                  ReverseRebook,
                                                  CommentSource, CommentRuleId, ModifiedBy, ModifiedDate,
                                                  ReverseTxnDateSource,
                                                  ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @fcyRevaluationGroupComponent1Id, N'TotalMTMProfit', null, null,
                    N'Debit',
                    null,
                    N'TotalMTMAmount', N'TxnNo', N'LogicalDate', N'LogicalDate', N'TotalMTMAmountCCY',
                    N'TotalMTMAmountCCY',
                    N'TotalMTMAmount', N'TotalMTMAmount', 0, null, null, @stateMaker, @stateDate, null, null);
            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @fcyRevaluationGroupComponent1Id
                    and GLCode = N'FXPositionRec')
        begin
            INSERT INTO dbo.AccEngineAccountRule (Id, ComponentId, GLCode, CustomerCodeSource,
                                                  CustomerAccountCodeSource,
                                                  DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                  ValueDateSource,
                                                  TxnDateSource, CcySource, FcySource, LcyEqvtSource, FcyAmtSource,
                                                  ReverseRebook,
                                                  CommentSource, CommentRuleId, ModifiedBy, ModifiedDate,
                                                  ReverseTxnDateSource,
                                                  ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @fcyRevaluationGroupComponent1Id, N'FXPositionRec', null, null,
                    N'Credit',
                    null,
                    N'TotalMTMAmount', N'TxnNo', N'LogicalDate', N'LogicalDate', N'TotalMTMAmountCCY',
                    N'TotalMTMAmountCCY',
                    N'TotalMTMAmount', N'TotalMTMAmount', 0, null, null, @stateMaker, @stateDate, null, null);
            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @fcyRevaluationGroupComponent1Id
                    and GLCode = N'FXPositionLCY')
        begin
            INSERT INTO dbo.AccEngineAccountRule (Id, ComponentId, GLCode, CustomerCodeSource,
                                                  CustomerAccountCodeSource,
                                                  DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                  ValueDateSource,
                                                  TxnDateSource, CcySource, FcySource, LcyEqvtSource, FcyAmtSource,
                                                  ReverseRebook,
                                                  CommentSource, CommentRuleId, ModifiedBy, ModifiedDate,
                                                  ReverseTxnDateSource,
                                                  ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @fcyRevaluationGroupComponent1Id, N'FXPositionLCY', null, null,
                    N'Debit',
                    null,
                    N'TotalMTMAmountLCY', N'TxnNo', N'LogicalDate', N'LogicalDate', N'LocalCCY', N'TotalMTMAmountCCY',
                    N'TotalMTMAmountLCY',
                    N'TotalMTMAmountLCY', 0, null, null, @stateMaker, @stateDate, null, null);
            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @fcyRevaluationGroupComponent1Id
                    and GLCode = N'CapitalGainFCY')
        begin
            INSERT INTO dbo.AccEngineAccountRule (Id, ComponentId, GLCode, CustomerCodeSource,
                                                  CustomerAccountCodeSource,
                                                  DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                  ValueDateSource,
                                                  TxnDateSource, CcySource, FcySource, LcyEqvtSource, FcyAmtSource,
                                                  ReverseRebook,
                                                  CommentSource, CommentRuleId, ModifiedBy, ModifiedDate,
                                                  ReverseTxnDateSource,
                                                  ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @fcyRevaluationGroupComponent1Id, N'CapitalGainFCY', null, null,
                    N'Credit',
                    null,
                    N'TotalMTMAmountLCY', N'TxnNo', N'LogicalDate', N'LogicalDate', N'LocalCCY', N'LocalCCY',
                    N'TotalMTMAmountLCY',
                    N'TotalMTMAmountLCY', 0, null, null, @stateMaker, @stateDate, null, null);
            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @fcyRevaluationGroupComponent2Id
                    and GLCode = N'FXPositionPay')
        begin
            INSERT INTO dbo.AccEngineAccountRule (Id, ComponentId, GLCode, CustomerCodeSource,
                                                  CustomerAccountCodeSource,
                                                  DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                  ValueDateSource,
                                                  TxnDateSource, CcySource, FcySource, LcyEqvtSource, FcyAmtSource,
                                                  ReverseRebook,
                                                  CommentSource, CommentRuleId, ModifiedBy, ModifiedDate,
                                                  ReverseTxnDateSource,
                                                  ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @fcyRevaluationGroupComponent2Id, N'FXPositionPay', null, null,
                    N'Debit',
                    null,
                    N'TotalMTMAmount', N'TxnNo', N'LogicalDate', N'LogicalDate', N'TotalMTMAmountCCY', N'LocalCCY',
                    N'TotalMTMAmount', N'TotalMTMAmount', 0, null, null, @stateMaker, @stateDate, null, null);
            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @fcyRevaluationGroupComponent2Id
                    and GLCode = N'TotalMTMLoss')
        begin
            INSERT INTO dbo.AccEngineAccountRule (Id, ComponentId, GLCode, CustomerCodeSource,
                                                  CustomerAccountCodeSource,
                                                  DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                  ValueDateSource,
                                                  TxnDateSource, CcySource, FcySource, LcyEqvtSource, FcyAmtSource,
                                                  ReverseRebook,
                                                  CommentSource, CommentRuleId, ModifiedBy, ModifiedDate,
                                                  ReverseTxnDateSource,
                                                  ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @fcyRevaluationGroupComponent2Id, N'TotalMTMLoss', null, null,
                    N'Credit',
                    null,
                    N'TotalMTMAmount', N'TxnNo', N'LogicalDate', N'LogicalDate', N'TotalMTMAmountCCY',
                    N'TotalMTMAmountCCY',
                    N'TotalMTMAmount', N'TotalMTMAmount', 0, null, null, @stateMaker, @stateDate, null, null);
            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @fcyRevaluationGroupComponent2Id
                    and GLCode = N'CapitalLossFCY')
        begin
            INSERT INTO dbo.AccEngineAccountRule (Id, ComponentId, GLCode, CustomerCodeSource,
                                                  CustomerAccountCodeSource,
                                                  DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                  ValueDateSource,
                                                  TxnDateSource, CcySource, FcySource, LcyEqvtSource, FcyAmtSource,
                                                  ReverseRebook,
                                                  CommentSource, CommentRuleId, ModifiedBy, ModifiedDate,
                                                  ReverseTxnDateSource,
                                                  ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @fcyRevaluationGroupComponent2Id, N'CapitalLossFCY', null, null,
                    N'Debit',
                    null,
                    N'TotalMTMAmountLCY', N'TxnNo', N'LogicalDate', N'LogicalDate', N'LocalCCY', N'LocalCCY',
                    N'TotalMTMAmountLCY',
                    N'TotalMTMAmountLCY', 0, null, null, @stateMaker, @stateDate, null, null);
            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @fcyRevaluationGroupComponent2Id
                    and GLCode = N'FXPositionLCY')
        begin
            INSERT INTO dbo.AccEngineAccountRule (Id, ComponentId, GLCode, CustomerCodeSource,
                                                  CustomerAccountCodeSource,
                                                  DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                  ValueDateSource,
                                                  TxnDateSource, CcySource, FcySource, LcyEqvtSource, FcyAmtSource,
                                                  ReverseRebook,
                                                  CommentSource, CommentRuleId, ModifiedBy, ModifiedDate,
                                                  ReverseTxnDateSource,
                                                  ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @fcyRevaluationGroupComponent2Id, N'FXPositionLCY', null, null,
                    N'Credit',
                    null,
                    N'TotalMTMAmountLCY', N'TxnNo', N'LogicalDate', N'LogicalDate', N'LocalCCY', N'TotalMTMAmountCCY',
                    N'TotalMTMAmountLCY',
                    N'TotalMTMAmountLCY', 0, null, null, @stateMaker, @stateDate, null, null);
            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @fcyPaymentGroupComponent1Id
                    and GLCode = N'IncomingPaymentFCY')
        begin
            INSERT INTO dbo.AccEngineAccountRule (Id, ComponentId, GLCode, CustomerCodeSource,
                                                  CustomerAccountCodeSource,
                                                  DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                  ValueDateSource,
                                                  TxnDateSource, CcySource, FcySource, LcyEqvtSource, FcyAmtSource,
                                                  ReverseRebook,
                                                  CommentSource, CommentRuleId, ModifiedBy, ModifiedDate,
                                                  ReverseTxnDateSource,
                                                  ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @fcyPaymentGroupComponent1Id, N'IncomingPaymentFCY', null, null,
                    N'Debit',
                    null,
                    N'NetPeriodEndAmount', N'TxnNo', N'LogicalDate', N'LogicalDate', N'ReceiveCurrency',
                    N'ReceiveCurrency',
                    N'NetPeriodEndAmount', N'NetPeriodEndAmount', 0, null, null, @stateMaker, @stateDate, null, null);
            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @fcyPaymentGroupComponent1Id
                    and GLCode = N'FXPositionRec')
        begin
            INSERT INTO dbo.AccEngineAccountRule (Id, ComponentId, GLCode, CustomerCodeSource,
                                                  CustomerAccountCodeSource,
                                                  DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                  ValueDateSource,
                                                  TxnDateSource, CcySource, FcySource, LcyEqvtSource, FcyAmtSource,
                                                  ReverseRebook,
                                                  CommentSource, CommentRuleId, ModifiedBy, ModifiedDate,
                                                  ReverseTxnDateSource,
                                                  ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @fcyPaymentGroupComponent1Id, N'FXPositionRec', null, null, N'Credit',
                    null,
                    N'NetPeriodEndAmount', N'TxnNo', N'LogicalDate', N'LogicalDate', N'ReceiveCurrency',
                    N'ReceiveCurrency',
                    N'NetPeriodEndAmount', N'NetPeriodEndAmount', 0, null, null, @stateMaker, @stateDate, null, null);
            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @fcyPaymentGroupComponent1Id
                    and GLCode = N'FXPositionLCY')
        begin
            INSERT INTO dbo.AccEngineAccountRule (Id, ComponentId, GLCode, CustomerCodeSource,
                                                  CustomerAccountCodeSource,
                                                  DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                  ValueDateSource,
                                                  TxnDateSource, CcySource, FcySource, LcyEqvtSource, FcyAmtSource,
                                                  ReverseRebook,
                                                  CommentSource, CommentRuleId, ModifiedBy, ModifiedDate,
                                                  ReverseTxnDateSource,
                                                  ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @fcyPaymentGroupComponent1Id, N'FXPositionLCY', null, null, N'Debit',
                    null,
                    N'NetPeriodEndAmountLCY', N'TxnNo', N'LogicalDate', N'LogicalDate', N'LocalCCY', N'ReceiveCurrency',
                    N'NetPeriodEndAmountLCY', N'NetPeriodEndAmountLCY', 0, null, null, @stateMaker, @stateDate, null,
                    null);
            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @fcyPaymentGroupComponent1Id
                    and GLCode = N'InterestIncome')
        begin
            INSERT INTO dbo.AccEngineAccountRule (Id, ComponentId, GLCode, CustomerCodeSource,
                                                  CustomerAccountCodeSource,
                                                  DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                  ValueDateSource,
                                                  TxnDateSource, CcySource, FcySource, LcyEqvtSource, FcyAmtSource,
                                                  ReverseRebook,
                                                  CommentSource, CommentRuleId, ModifiedBy, ModifiedDate,
                                                  ReverseTxnDateSource,
                                                  ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @fcyPaymentGroupComponent1Id, N'InterestIncome', null, null, N'Credit',
                    null,
                    N'NetPeriodEndAmountLCY', N'TxnNo', N'LogicalDate', N'LogicalDate', N'LocalCCY',
                    N'LocalCCY',
                    N'NetPeriodEndAmountLCY', N'NetPeriodEndAmountLCY', 0, null, null, @stateMaker, @stateDate, null,
                    null);
            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @fcyPaymentGroupComponent2Id
                    and GLCode = N'FXPositionPay')
        begin
            INSERT INTO dbo.AccEngineAccountRule (Id, ComponentId, GLCode, CustomerCodeSource,
                                                  CustomerAccountCodeSource,
                                                  DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                  ValueDateSource,
                                                  TxnDateSource, CcySource, FcySource, LcyEqvtSource, FcyAmtSource,
                                                  ReverseRebook,
                                                  CommentSource, CommentRuleId, ModifiedBy, ModifiedDate,
                                                  ReverseTxnDateSource,
                                                  ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @fcyPaymentGroupComponent2Id, N'FXPositionPay', null, null, N'Debit',
                    null,
                    N'NetPeriodEndAmount', N'TxnNo', N'LogicalDate', N'LogicalDate', N'PayCurrency', N'PayCurrency',
                    N'NetPeriodEndAmount', N'NetPeriodEndAmount', 0, null, null, @stateMaker, @stateDate, null, null);
            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @fcyPaymentGroupComponent2Id
                    and GLCode = N'OutgoingPaymentFCY')
        begin
            INSERT INTO dbo.AccEngineAccountRule (Id, ComponentId, GLCode, CustomerCodeSource,
                                                  CustomerAccountCodeSource,
                                                  DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                  ValueDateSource,
                                                  TxnDateSource, CcySource, FcySource, LcyEqvtSource, FcyAmtSource,
                                                  ReverseRebook,
                                                  CommentSource, CommentRuleId, ModifiedBy, ModifiedDate,
                                                  ReverseTxnDateSource,
                                                  ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @fcyPaymentGroupComponent2Id, N'OutgoingPaymentFCY', null, null,
                    N'Credit',
                    null,
                    N'NetPeriodEndAmount', N'TxnNo', N'LogicalDate', N'LogicalDate', N'PayCurrency', N'PayCurrency',
                    N'NetPeriodEndAmount', N'NetPeriodEndAmount', 0, null, null, @stateMaker, @stateDate, null, null);
            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @fcyPaymentGroupComponent2Id
                    and GLCode = N'InterestExpense')
        begin
            INSERT INTO dbo.AccEngineAccountRule (Id, ComponentId, GLCode, CustomerCodeSource,
                                                  CustomerAccountCodeSource,
                                                  DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                  ValueDateSource,
                                                  TxnDateSource, CcySource, FcySource, LcyEqvtSource, FcyAmtSource,
                                                  ReverseRebook,
                                                  CommentSource, CommentRuleId, ModifiedBy, ModifiedDate,
                                                  ReverseTxnDateSource,
                                                  ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @fcyPaymentGroupComponent2Id, N'InterestExpense', null, null, N'Debit',
                    null,
                    N'NetPeriodEndAmountLCY', N'TxnNo', N'LogicalDate', N'LogicalDate', N'LocalCCY', N'LocalCCY',
                    N'NetPeriodEndAmountLCY', N'NetPeriodEndAmountLCY', 0, null, null, @stateMaker, @stateDate, null,
                    null);
            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @fcyPaymentGroupComponent2Id
                    and GLCode = N'FXPositionLCY')
        begin
            INSERT INTO dbo.AccEngineAccountRule (Id, ComponentId, GLCode, CustomerCodeSource,
                                                  CustomerAccountCodeSource,
                                                  DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                  ValueDateSource,
                                                  TxnDateSource, CcySource, FcySource, LcyEqvtSource, FcyAmtSource,
                                                  ReverseRebook,
                                                  CommentSource, CommentRuleId, ModifiedBy, ModifiedDate,
                                                  ReverseTxnDateSource,
                                                  ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @fcyPaymentGroupComponent2Id, N'FXPositionLCY', null, null, N'Credit',
                    null,
                    N'NetPeriodEndAmountLCY', N'TxnNo', N'LogicalDate', N'LogicalDate', N'LocalCCY', N'ReceiveCurrency',
                    N'NetPeriodEndAmountLCY', N'NetPeriodEndAmountLCY', 0, null, null, @stateMaker, @stateDate, null,
                    null);
            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @fcyMaturationGroupComponent1Id
                    and GLCode = N'MatPayContingent')
        begin
            INSERT INTO dbo.AccEngineAccountRule (Id, ComponentId, GLCode, CustomerCodeSource,
                                                  CustomerAccountCodeSource,
                                                  DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                  ValueDateSource,
                                                  TxnDateSource, CcySource, FcySource, LcyEqvtSource, FcyAmtSource,
                                                  ReverseRebook,
                                                  CommentSource, CommentRuleId, ModifiedBy, ModifiedDate,
                                                  ReverseTxnDateSource,
                                                  ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @fcyMaturationGroupComponent1Id, N'MatPayContingent', null, null,
                    N'Debit',
                    null,
                    N'PayPrincipalAmount', N'TxnNo', N'LogicalDate', N'LogicalDate', N'PayCurrency', N'PayCurrency',
                    N'PayPrincipalAmount', N'PayPrincipalAmount', 0, null, null, @stateMaker, @stateDate, null, null);
            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @fcyMaturationGroupComponent1Id
                    and GLCode = N'MatPayContingentOffset')
        begin
            INSERT INTO dbo.AccEngineAccountRule (Id, ComponentId, GLCode, CustomerCodeSource,
                                                  CustomerAccountCodeSource,
                                                  DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                  ValueDateSource,
                                                  TxnDateSource, CcySource, FcySource, LcyEqvtSource, FcyAmtSource,
                                                  ReverseRebook,
                                                  CommentSource, CommentRuleId, ModifiedBy, ModifiedDate,
                                                  ReverseTxnDateSource,
                                                  ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @fcyMaturationGroupComponent1Id, N'MatPayContingentOffset', null, null,
                    N'Credit',
                    null, N'PayPrincipalAmount', N'TxnNo', N'LogicalDate', N'LogicalDate', N'PayCurrency',
                    N'PayCurrency',
                    N'PayPrincipalAmount', N'PayPrincipalAmount', 0, null, null, @stateMaker, @stateDate, null, null);
            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @fcyMaturationGroupComponent1Id
                    and GLCode = N'MatRecContingentOffset')
        begin
            INSERT INTO dbo.AccEngineAccountRule (Id, ComponentId, GLCode, CustomerCodeSource,
                                                  CustomerAccountCodeSource,
                                                  DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                  ValueDateSource,
                                                  TxnDateSource, CcySource, FcySource, LcyEqvtSource, FcyAmtSource,
                                                  ReverseRebook,
                                                  CommentSource, CommentRuleId, ModifiedBy, ModifiedDate,
                                                  ReverseTxnDateSource,
                                                  ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @fcyMaturationGroupComponent1Id, N'MatRecContingentOffset', null, null,
                    N'Debit',
                    null, N'ReceivePrincipalAmount', N'TxnNo', N'LogicalDate', N'LogicalDate', N'ReceiveCurrency',
                    N'ReceiveCurrency', N'ReceivePrincipalAmount', N'ReceivePrincipalAmount', 0, null, null,
                    @stateMaker,
                    @stateDate, null, null);
            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @fcyMaturationGroupComponent1Id
                    and GLCode = N'MatRecContingent')
        begin
            INSERT INTO dbo.AccEngineAccountRule (Id, ComponentId, GLCode, CustomerCodeSource,
                                                  CustomerAccountCodeSource,
                                                  DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                  ValueDateSource,
                                                  TxnDateSource, CcySource, FcySource, LcyEqvtSource, FcyAmtSource,
                                                  ReverseRebook,
                                                  CommentSource, CommentRuleId, ModifiedBy, ModifiedDate,
                                                  ReverseTxnDateSource,
                                                  ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @fcyMaturationGroupComponent1Id, N'MatRecContingent', null, null,
                    N'Credit',
                    null,
                    N'ReceivePrincipalAmount', N'TxnNo', N'LogicalDate', N'LogicalDate', N'ReceiveCurrency',
                    N'ReceiveCurrency',
                    N'ReceivePrincipalAmount', N'ReceivePrincipalAmount', 0, null, null, @stateMaker, @stateDate, null,
                    null);
            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @fcyMaturationGroupComponent2Id
                    and GLCode = N'83000000')
        begin
            INSERT INTO dbo.accEngineAccountRule(Id, ComponentId, GLCode, CustomerCodeSource, CustomerAccountCodeSource,
                                                 DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                 ValueDateSource, TxnDateSource, CcySource, FcySource, LcyEqvtSource,
                                                 FcyAmtSource, ReverseRebook, CommentSource, CommentRuleId, ModifiedBy,
                                                 ModifiedDate, ReverseTxnDateSource, ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @fcyMaturationGroupComponent2Id, N'83000000', null, null,
                    N'Debit', null, N'TaxAmount', N'TxnNo', N'LogicalDate', N'LogicalDate', N'LocalCCY', N'LocalCCY',
                    N'TaxAmount', N'TaxAmount', 0, null, null, @stateMaker, @stateDate, null, null);

            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @fcyMaturationGroupComponent2Id
                    and GLCode = N'38000500')
        begin
            INSERT INTO dbo.accEngineAccountRule(Id, ComponentId, GLCode, CustomerCodeSource, CustomerAccountCodeSource,
                                                 DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                 ValueDateSource, TxnDateSource, CcySource, FcySource, LcyEqvtSource,
                                                 FcyAmtSource, ReverseRebook, CommentSource, CommentRuleId, ModifiedBy,
                                                 ModifiedDate, ReverseTxnDateSource, ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @fcyMaturationGroupComponent2Id, N'38000500', null, null,
                    N'Credit', null, N'TaxAmount', N'TxnNo', N'LogicalDate', N'LogicalDate', N'LocalCCY', N'LocalCCY',
                    N'TaxAmount', N'TaxAmount', 0, null, null, @stateMaker, @stateDate, null, null);
        end

    --#endregion

--#region defNumberGen

    update dbo.defNumberGen
    set LastNumber     = @lastAccEngineDynamicRuleId,
        LastUpdateDate = @stateDate
    where EntityColumnType = @accEngineDynamicRuleColumnTypeId

    update dbo.defNumberGen
    set LastNumber     = @lastAccEngineAccountRuleId,
        LastUpdateDate = @stateDate
    where EntityColumnType = @accEngineAccountRuleColumnTypeId

    update dbo.defNumberGen
    set LastNumber     = @lastAccEngineComponentId,
        LastUpdateDate = @stateDate
    where EntityColumnType = @accEngineComponentColumnTypeId

    update dbo.defNumberGen
    set LastNumber     = @lastAccEngineGroupId,
        LastUpdateDate = @stateDate
    where EntityColumnType = @accEngineGroupColumnTypeId

    update dbo.defNumberGen
    set LastNumber     = @lastAccEngineEventId,
        LastUpdateDate = @stateDate
    where EntityColumnType = @accEngineEventColumnTypeId

    update dbo.defNumberGen
    set LastNumber     = @lastAccEngineItemId,
        LastUpdateDate = @stateDate
    where EntityColumnType = @accEngineItemColumnTypeId

    update dbo.defNumberGen
    set LastNumber     = @lastAccEngineItemCodeId,
        LastUpdateDate = @stateDate
    where EntityColumnType = @accEngineItemCodeColumnTypeId

    update dbo.defNumberGen
    set LastNumber     = @lastAccEngineItemTypeId,
        LastUpdateDate = @stateDate
    where EntityColumnType = @accEngineItemTypeColumnTypeId

    update dbo.defNumberGen
    set LastNumber     = @lastAccEngineModelDefinitionId,
        LastUpdateDate = @stateDate
    where EntityColumnType = @accEngineModelDefinitionColumnTypeId

    update dbo.defNumberGen
    set LastNumber     = @lastAccAccountMapId,
        LastUpdateDate = @stateDate
    where EntityColumnType = @accAccountMapColumnTypeId

--#endregion

    commit transaction;
end try
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
    DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
    DECLARE @ErrorState INT = ERROR_STATE();
    DECLARE @ErrorLine INT = ERROR_LINE();

    RAISERROR ('Error on line %d: %s', @ErrorSeverity, @ErrorState, @ErrorLine, @ErrorMessage);
END CATCH
