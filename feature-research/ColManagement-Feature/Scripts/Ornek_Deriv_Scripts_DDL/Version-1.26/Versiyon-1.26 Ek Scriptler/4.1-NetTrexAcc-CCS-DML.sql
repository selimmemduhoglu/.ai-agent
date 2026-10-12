use [NetTrexAcc]
GO
SET XACT_ABORT ON;

begin transaction;

begin try
    declare
        @tempTable TABLE
                   (
                       Id INT
                   );

    declare
        @StateId int=18,
        @stateDate datetime = getdate(),
        @stateMaker nvarchar(80) = N'SYSTEM',
        @number int = 0;

    declare
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
        @lcyRFcyPItemId int =0,
        @fcyRLcyPItemId int = 0,
        @fcyRFcyPItemId int = 0;

    declare
        @lcyRFcyPOpeningEventId int = 0,
        @lcyRFcyPRevaluationEventId int = 0,
        @lcyRFcyPPaymentEventId int = 0,
        @lcyRFcyPMaturationEventId int = 0;

    declare
        @fcyRFcyPOpeningEventId int = 0,
        @fcyRFcyPRevaluationEventId int = 0,
        @fcyRFcyPPaymentEventId int = 0,
        @fcyRFcyPMaturationEventId int = 0;

    declare
        @fcyRLcyPOpeningEventId int = 0,
        @fcyRLcyPRevaluationEventId int = 0,
        @fcyRLcyPPaymentEventId int = 0,
        @fcyRLcyPMaturationEventId int = 0;

    declare
        @lcyRFcyPOpeningGroup1Id int =0,
        @lcyRFcyPOpeningGroup2Id int = 0,
        @lcyRFcyPRevaluationGroupId int = 0,
        @lcyRFcyPPaymentGroupId int = 0,
        @lcyRFcyPMaturationGroupId int = 0;

    declare
        @fcyRLcyPOpeningGroup1Id int =0,
        @fcyRLcyPOpeningGroup2Id int = 0,
        @fcyRLcyPRevaluationGroupId int = 0,
        @fcyRLcyPPaymentGroupId int = 0,
        @fcyRLcyPMaturationGroupId int = 0;

    declare
        @fcyRFcyPOpeningGroup1Id int =0,
        @fcyRFcyPOpeningGroup2Id int = 0,
        @fcyRFcyPRevaluationGroupId int = 0,
        @fcyRFcyPPaymentGroupId int = 0,
        @fcyRFcyPMaturationGroupId int = 0;

    declare
        @lcyRFcyPOpeningGroup1Component1Id int = 0,
        @lcyRFcyPOpeningGroup1Component2Id int = 0,
        @lcyRFcyPOpeningGroup2Component1Id int = 0,
        @lcyRFcyPOpeningGroup2Component2Id int = 0,
        @lcyRFcyPOpeningGroup2Component3Id int = 0,
        @lcyRFcyPOpeningGroup2Component4Id int = 0,
        @lcyRFcyPRevaluationGroupComponent1Id int=0,
        @lcyRFcyPRevaluationGroupComponent2Id int=0,
        @lcyRFcyPPaymentGroupComponent1Id int=0,
        @lcyRFcyPPaymentGroupComponent2Id int=0,
        @lcyRFcyPMaturationGroupComponent1Id int = 0,
        @lcyRFcyPMaturationGroupComponent2Id int = 0,
        @lcyRFcyPMaturationGroupComponent3Id int = 0,
        @lcyRFcyPMaturationGroupComponent4Id int = 0;

    declare
        @fcyRLcyPOpeningGroup1Component1Id int = 0,
        @fcyRLcyPOpeningGroup1Component2Id int = 0,
        @fcyRLcyPOpeningGroup2Component1Id int = 0,
        @fcyRLcyPOpeningGroup2Component2Id int = 0,
        @fcyRLcyPOpeningGroup2Component3Id int = 0,
        @fcyRLcyPOpeningGroup2Component4Id int = 0,
        @fcyRLcyPRevaluationGroupComponent1Id int=0,
        @fcyRLcyPRevaluationGroupComponent2Id int=0,
        @fcyRLcyPPaymentGroupComponent1Id int=0,
        @fcyRLcyPPaymentGroupComponent2Id int=0,
        @fcyRLcyPMaturationGroupComponent1Id int = 0,
        @fcyRLcyPMaturationGroupComponent2Id int = 0,
        @fcyRLcyPMaturationGroupComponent3Id int = 0,
        @fcyRLcyPMaturationGroupComponent4Id int = 0;

    declare
        @fcyRFcyPOpeningGroup1Component1Id int = 0,
        @fcyRFcyPOpeningGroup1Component2Id int = 0,
        @fcyRFcyPOpeningGroup2Component1Id int = 0,
        @fcyRFcyPOpeningGroup2Component2Id int = 0,
        @fcyRFcyPOpeningGroup2Component3Id int = 0,
        @fcyRFcyPOpeningGroup2Component4Id int = 0,
        @fcyRFcyPRevaluationGroupComponent1Id int=0,
        @fcyRFcyPRevaluationGroupComponent2Id int=0,
        @fcyRFcyPPaymentGroupComponent1Id int=0,
        @fcyRFcyPPaymentGroupComponent2Id int=0,
        @fcyRFcyPMaturationGroupComponent1Id int = 0,
        @fcyRFcyPMaturationGroupComponent2Id int = 0,
        @fcyRFcyPMaturationGroupComponent3Id int = 0,
        @fcyRFcyPMaturationGroupComponent4Id int = 0;

    declare @dynamicRuleValueDateLessThanOrEqualLogicalDateId int=0,
        @dynamicRuleValueDateGreaterThanLogicalDateId int = 0,
        @dynamicRuleMaturityDateEqualsLogicalDateId int = 0,
        @dynamicRuleValueDateGreaterThanTradeDateId int = 0,
        @dynamicRuleValueDateLessThanOrEqualTradeDateId int = 0,
        @dynamicRuleDerivativeSwapMTMProfitId int = 0,
        @dynamicRuleDerivativeSwapMTMLossId int = 0,
        @dynamicRulePayForeignCurrencyId int = 0,
        @dynamicRuleReceiveForeignCurrencyId int = 0,
        @dynamicRuleDerivativePortfolioTradeId int = 0,
        @dynamicRuleReceiveLocalCurrencyId int = 0,
        @dynamicRulePayLocalCurrencyId int = 0,
        @dynamicRuleReceivePeriodEndDateEqualsLogicalDateId int = 0,
        @dynamicRulePayPeriodEndDateEqualsLogicalDateId int = 0,
        @dynamicRuleMtmAmountCCYEqualLocalCurrencyId int = 0,
        @dynamicRuleMtmAmountCCYEqualForeignCurrencyId int = 0;

    ------------------------------------------------------------------------------------------------------------------------
    -- Definition Number Generation
    ------------------------------------------------------------------------------------------------------------------------
--#region DefNumberGen
    ------------------------------------------------------------------------------------------------------------------------
    -- Accounting Engine Account Rule Last Number
    ------------------------------------------------------------------------------------------------------------------------
--#region AccEngineAccountRule
    select @lastAccEngineAccountRuleId = LastNumber + 1
    from dbo.DefNumberGen
    where EntityColumnType = @accEngineAccountRuleColumnTypeId
      and Definition = N'AccEngineAccountRule Id'

    if (@lastAccEngineAccountRuleId = 0)
        throw 500001, 'AccEngineAccountRule Last Id Not Found', 1
    --#endregion
    ------------------------------------------------------------------------------------------------------------------------
    -- Accounting Engine Dynamic Rule Last Number
    ------------------------------------------------------------------------------------------------------------------------
--#region AccEngineDynamicRule
    select @lastAccEngineDynamicRuleId = LastNumber + 1
    from dbo.DefNumberGen
    where EntityColumnType = @accEngineDynamicRuleColumnTypeId
      and Definition = N'AccEngineDynamicRule Id'

    if (@lastAccEngineDynamicRuleId = 0)
        throw 500001, 'AccEngineDynamicRule Last Id Not Found', 1
    --#endregion
    ------------------------------------------------------------------------------------------------------------------------
    -- Accounting Engine Component Last Number
    ------------------------------------------------------------------------------------------------------------------------
--#region AccEngineComponent
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
--#region AccEngineGroup
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
--#region AccEngineEvent
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
--#region AccEngineItem
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
--#region AccEngineItemCode
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
--#region AccEngineItemType
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
--#region AccEngineModelDefinition
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
            VALUES (N'CapitalGainFCY', null, N'DerivSwp', N'DerivSwp', N'DerivSwp', @stateId, @stateDate, @stateMaker,
                    null, null, null);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.AccEngineAccount
                   WHERE GLCode = N'CapitalGainLCY')
        BEGIN
            INSERT INTO dbo.AccEngineAccount (GLCode, ApaCode, TurkishDesc, EnglishDesc, CBTDesc, StateId, StateDate,
                                              StateMaker, MainGLCode, Flags, Type)
            VALUES (N'CapitalGainLCY', null, N'DerivSwp', N'DerivSwp', N'DerivSwp', @stateId,
                    N'2025-01-03 10:08:43.170', @stateMaker, null, null, null);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.AccEngineAccount
                   WHERE GLCode = N'CapitalLossFCY')
        BEGIN
            INSERT INTO dbo.AccEngineAccount (GLCode, ApaCode, TurkishDesc, EnglishDesc, CBTDesc, StateId, StateDate,
                                              StateMaker, MainGLCode, Flags, Type)
            VALUES (N'CapitalLossFCY', null, N'DerivSwp', N'DerivSwp', N'DerivSwp', @stateId, @stateDate, @stateMaker,
                    null, null, null);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.AccEngineAccount
                   WHERE GLCode = N'CapitalLossLCY')
        BEGIN
            INSERT INTO dbo.AccEngineAccount (GLCode, ApaCode, TurkishDesc, EnglishDesc, CBTDesc, StateId, StateDate,
                                              StateMaker, MainGLCode, Flags, Type)
            VALUES (N'CapitalLossLCY', null, N'DerivSwp', N'DerivSwp', N'DerivSwp', @stateId,
                    N'2025-01-03 10:08:44.577', @stateMaker, null, null, null);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.AccEngineAccount
                   WHERE GLCode = N'FXPositionLCY')
        BEGIN
            INSERT INTO dbo.AccEngineAccount (GLCode, ApaCode, TurkishDesc, EnglishDesc, CBTDesc, StateId, StateDate,
                                              StateMaker, MainGLCode, Flags, Type)
            VALUES (N'FXPositionLCY', null, N'DerivSwp', N'DerivSwp', N'DerivSwp', @stateId, @stateDate, @stateMaker,
                    null, null, null);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.AccEngineAccount
                   WHERE GLCode = N'FXPositionPay')
        BEGIN
            INSERT INTO dbo.AccEngineAccount (GLCode, ApaCode, TurkishDesc, EnglishDesc, CBTDesc, StateId, StateDate,
                                              StateMaker, MainGLCode, Flags, Type)
            VALUES (N'FXPositionPay', null, N'DerivSwp', N'DerivSwp', N'DerivSwp', @stateId, @stateDate, @stateMaker,
                    null, null, null);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.AccEngineAccount
                   WHERE GLCode = N'FXPositionRec')
        BEGIN
            INSERT INTO dbo.AccEngineAccount (GLCode, ApaCode, TurkishDesc, EnglishDesc, CBTDesc, StateId, StateDate,
                                              StateMaker, MainGLCode, Flags, Type)
            VALUES (N'FXPositionRec', null, N'DerivSwp', N'DerivSwp', N'DerivSwp', @stateId, @stateDate, @stateMaker,
                    null, null, null);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.AccEngineAccount
                   WHERE GLCode = N'IncomingPaymentFCY')
        BEGIN
            INSERT INTO dbo.AccEngineAccount (GLCode, ApaCode, TurkishDesc, EnglishDesc, CBTDesc, StateId, StateDate,
                                              StateMaker, MainGLCode, Flags, Type)
            VALUES (N'IncomingPaymentFCY', null,
                    N'Gelen Ödemeler için çalışacak Alias. Geçici yada Kasa hesabı çalışacaktır.', null, null, @stateId,
                    @stateDate, @stateMaker, null, null, null);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.AccEngineAccount
                   WHERE GLCode = N'IncomingPaymentLCY')
        BEGIN
            INSERT INTO dbo.AccEngineAccount (GLCode, ApaCode, TurkishDesc, EnglishDesc, CBTDesc, StateId, StateDate,
                                              StateMaker, MainGLCode, Flags, Type)
            VALUES (N'IncomingPaymentLCY', null,
                    N'Gelen Ödemeler için çalıştırılacak Alias. Geçici yada kasa hesabı dönecektir.',
                    N'IncomingPaymentLCY', null, @stateId, @stateDate, @stateMaker, null, null, null);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.AccEngineAccount
                   WHERE GLCode = N'InterestExpense')
        BEGIN
            INSERT INTO dbo.AccEngineAccount (GLCode, ApaCode, TurkishDesc, EnglishDesc, CBTDesc, StateId, StateDate,
                                              StateMaker, MainGLCode, Flags, Type)
            VALUES (N'InterestExpense', null, N'DerivSwp', N'DerivSwp', N'DerivSwp', @stateId, @stateDate, @stateMaker,
                    null, null, null);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.AccEngineAccount
                   WHERE GLCode = N'InterestIncome')
        BEGIN
            INSERT INTO dbo.AccEngineAccount (GLCode, ApaCode, TurkishDesc, EnglishDesc, CBTDesc, StateId, StateDate,
                                              StateMaker, MainGLCode, Flags, Type)
            VALUES (N'InterestIncome', null, N'DerivSwp', N'DerivSwp', N'DerivSwp', @stateId, @stateDate, @stateMaker,
                    null, null, null);
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
                   WHERE GLCode = N'MatPayPrincipal')
        BEGIN
            INSERT INTO dbo.AccEngineAccount (GLCode, ApaCode, TurkishDesc, EnglishDesc, CBTDesc, StateId, StateDate,
                                              StateMaker, MainGLCode, Flags, Type)
            VALUES (N'MatPayPrincipal', null, N'SWAP PARA ALIM İŞLEMLERİ ALACAKLAR - DÖVİZ - DÖVİZ', null, null,
                    @stateId, @stateDate, @stateMaker, null, null, null);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.AccEngineAccount
                   WHERE GLCode = N'MatRecContingent')
        BEGIN
            INSERT INTO dbo.AccEngineAccount (GLCode, ApaCode, TurkishDesc, EnglishDesc, CBTDesc, StateId, StateDate,
                                              StateMaker, MainGLCode, Flags, Type)
            VALUES (N'MatRecContingent', null, N'SWAP PARA ALIM İŞLEMLERİ ALACAKLAR - DÖVİZ - DÖVİZ', null, null,
                    @stateId, @stateDate, @stateMaker, null, null, null);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.AccEngineAccount
                   WHERE GLCode = N'MatRecContingentOffset')
        BEGIN
            INSERT INTO dbo.AccEngineAccount (GLCode, ApaCode, TurkishDesc, EnglishDesc, CBTDesc, StateId, StateDate,
                                              StateMaker, MainGLCode, Flags, Type)
            VALUES (N'MatRecContingentOffset', null, N'SWAP PARA ALIM İŞLEMLERİ BORÇLAR- DÖVİZ-DÖVİZ', null, null,
                    @stateId, @stateDate, @stateMaker, null, null, null);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.AccEngineAccount
                   WHERE GLCode = N'MatRecPrincipal')
        BEGIN
            INSERT INTO dbo.AccEngineAccount (GLCode, ApaCode, TurkishDesc, EnglishDesc, CBTDesc, StateId, StateDate,
                                              StateMaker, MainGLCode, Flags, Type)
            VALUES (N'MatRecPrincipal', null, N'SWAP PARA ALIM İŞLEMLERİ BORÇLAR- DÖVİZ-DÖVİZ', null, null, @stateId,
                    @stateDate, N'DerivSwp', null, null, null);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.AccEngineAccount
                   WHERE GLCode = N'OutgoingPaymentFCY')
        BEGIN
            INSERT INTO dbo.AccEngineAccount (GLCode, ApaCode, TurkishDesc, EnglishDesc, CBTDesc, StateId, StateDate,
                                              StateMaker, MainGLCode, Flags, Type)
            VALUES (N'OutgoingPaymentFCY', null,
                    N'Giden ödemeler için çalışacak Alias. Geçici yada Kasa Hesabı çalışacaktır.', null, null, @stateId,
                    @stateDate, @stateMaker, null, null, null);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.AccEngineAccount
                   WHERE GLCode = N'TotalMTMLoss')
        BEGIN
            INSERT INTO dbo.AccEngineAccount (GLCode, ApaCode, TurkishDesc, EnglishDesc, CBTDesc, StateId, StateDate,
                                              StateMaker, MainGLCode, Flags, Type)
            VALUES (N'TotalMTMLoss', null, N'Derivative Swap', N'Derivative Swap', null, @stateId, @stateDate,
                    @stateMaker, null, null, null);
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
                    @stateId, @stateDate, @stateMaker, null, null, null);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.AccEngineAccount
                   WHERE GLCode = N'ValPayContingentOffset')
        BEGIN
            INSERT INTO dbo.AccEngineAccount (GLCode, ApaCode, TurkishDesc, EnglishDesc, CBTDesc, StateId, StateDate,
                                              StateMaker, MainGLCode, Flags, Type)
            VALUES (N'ValPayContingentOffset', null, N'SWAP PARA ALIM İŞLEMLERİ BORÇLAR- DÖVİZ-DÖVİZ', null, null,
                    @stateId, @stateDate, @stateMaker, null, null, null);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.AccEngineAccount
                   WHERE GLCode = N'ValPayPrincipal')
        BEGIN
            INSERT INTO dbo.AccEngineAccount (GLCode, ApaCode, TurkishDesc, EnglishDesc, CBTDesc, StateId, StateDate,
                                              StateMaker, MainGLCode, Flags, Type)
            VALUES (N'ValPayPrincipal', null, N'FX İŞLEMLERİ GEÇİCİ HESABI', null, null, @stateId, @stateDate,
                    @stateMaker, null, null, null);
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

    IF NOT EXISTS (SELECT 1
                   FROM dbo.AccEngineAccount
                   WHERE GLCode = N'ValRecPrincipal')
        BEGIN
            INSERT INTO dbo.AccEngineAccount (GLCode, ApaCode, TurkishDesc, EnglishDesc, CBTDesc, StateId, StateDate,
                                              StateMaker, MainGLCode, Flags, Type)
            VALUES (N'ValRecPrincipal', null, N'FX İŞLEMLERİ GEÇİCİ HESABI', null, null, @stateId, @stateDate,
                    @stateMaker, null, null, null);
        END;

    --#endregion
    ------------------------------------------------------------------------------------------------------------------------
    -- Accounting Engine Component Type
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
            VALUES (N'Value Date Contingent', N'500', @StateId, @stateDate, @stateMaker);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.AccEngineComponentType
                   WHERE Name = N'Maturity Date Contingent'
                     AND Code = N'501')
        BEGIN
            INSERT INTO dbo.AccEngineComponentType (Name, Code, StateId, StateDate, StateMaker)
            VALUES (N'Maturity Date Contingent', N'501', @StateId, @stateDate, @stateMaker);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.AccEngineComponentType
                   WHERE Name = N'Value Date Incoming Payment'
                     AND Code = N'502')
        BEGIN
            INSERT INTO dbo.AccEngineComponentType (Name, Code, StateId, StateDate, StateMaker)
            VALUES (N'Value Date Incoming Payment', N'502', @stateId, @stateDate, @stateDate);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.AccEngineComponentType
                   WHERE Name = N'Value Date Outgoing Payment'
                     AND Code = N'503')
        BEGIN
            INSERT INTO dbo.AccEngineComponentType (Name, Code, StateId, StateDate, StateMaker)
            VALUES (N'Value Date Outgoing Payment', N'503', @stateId, @stateDate, @stateDate);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.AccEngineComponentType
                   WHERE Name = N'Maturity Date Outgoing Payment'
                     AND Code = N'504')
        BEGIN
            INSERT INTO dbo.AccEngineComponentType (Name, Code, StateId, StateDate, StateMaker)
            VALUES (N'Maturity Date Outgoing Payment', N'504', @stateId, @stateDate, @stateDate);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.AccEngineComponentType
                   WHERE Name = N'Maturity Date  Incoming Payment'
                     AND Code = N'505')
        BEGIN
            INSERT INTO dbo.AccEngineComponentType (Name, Code, StateId, StateDate, StateMaker)
            VALUES (N'Maturity Date  Incoming Payment', N'505', @stateId, @stateDate, @stateDate);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.AccEngineComponentType
                   WHERE Name = N'Cashflow Payment Incoming'
                     AND Code = N'506')
        BEGIN
            INSERT INTO dbo.AccEngineComponentType (Name, Code, StateId, StateDate, StateMaker)
            VALUES (N'Cashflow Payment Incoming', N'506', @StateId, @stateDate, @stateMaker);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.AccEngineComponentType
                   WHERE Name = N'Cashflow Payment Outgoing'
                     AND Code = N'507')
        BEGIN
            INSERT INTO dbo.AccEngineComponentType (Name, Code, StateId, StateDate, StateMaker)
            VALUES (N'Cashflow Payment Outgoing', N'507', @StateId, @stateDate, @stateMaker);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.AccEngineComponentType
                   WHERE Name = N'Revaluation MTM Profit'
                     AND Code = N'508')
        BEGIN
            INSERT INTO dbo.AccEngineComponentType (Name, Code, StateId, StateDate, StateMaker)
            VALUES (N'Revaluation MTM Profit', N'508', @StateId, @stateDate, @stateMaker);
        END;

    IF NOT EXISTS (SELECT 1
                   FROM dbo.AccEngineComponentType
                   WHERE Name = N'Revaluation MTM Loss'
                     AND Code = N'509')
        BEGIN
            INSERT INTO dbo.AccEngineComponentType (Name, Code, StateId, StateDate, StateMaker)
            VALUES (N'Revaluation MTM Loss', N'509', @StateId, @stateDate, @stateMaker);
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
                   WHERE [Rule] = N'TxnModel.ReceiveValueDate.getTime() > TxnModel.TradeDate.getTime()')
        BEGIN
            INSERT INTO dbo.AccEngineDynamicRule (Id, Name, [Rule], Type, Description, StateId, StateDate, StateMaker)
            output inserted.Id into @tempTable
            VALUES (@lastAccEngineDynamicRuleId, N'ValueDate > TradeDate',
                    N'TxnModel.ReceiveValueDate.getTime() > TxnModel.TradeDate.getTime()',
                    0, N'', @StateId, @stateDate, @stateMaker);
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
                    0, N'', @StateId, @stateDate, @stateMaker);
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
                    N'TxnModel.ReceiveMaturityDate.getTime() === TxnModel.LogicalDate.getTime()', 0, N'', @StateId,
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
                   WHERE [Rule] = N'TxnModel.ReceiveValueDate.getTime() <= TxnModel.LogicalDate.getTime()')
        BEGIN
            INSERT INTO dbo.AccEngineDynamicRule (Id, Name, [Rule], Type, Description, StateId, StateDate, StateMaker)
            output inserted.Id into @tempTable
            VALUES (@lastAccEngineDynamicRuleId, N'ValueDate <= LogicalDate',
                    N'TxnModel.ReceiveValueDate.getTime() <= TxnModel.LogicalDate.getTime()', 0, N'', @StateId,
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
                    N'TxnModel.ReceiveValueDate.getTime() > TxnModel.LogicalDate.getTime()', 0, N'', @StateId,
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
                   WHERE [Rule] = N'TxnModel.TotalMTMAmount >= 0')
        BEGIN
            INSERT INTO dbo.AccEngineDynamicRule (Id, Name, [Rule], Type, Description, StateId, StateDate, StateMaker)
            output inserted.Id into @tempTable
            VALUES (@lastAccEngineDynamicRuleId, N'Derivative Swap MTM Profit', N'TxnModel.TotalMTMAmount >= 0', 0, N'',
                    @StateId, @stateDate,
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
                   WHERE [Rule] = N'TxnModel.TotalMTMAmount < 0')
        BEGIN
            INSERT INTO dbo.AccEngineDynamicRule (Id, Name, [Rule], Type, Description, StateId, StateDate, StateMaker)
            output inserted.Id into @tempTable
            VALUES (@lastAccEngineDynamicRuleId, N'Derivative Swap MTM Loss', N'TxnModel.TotalMTMAmount < 0', 0, N'',
                    @StateId, @stateDate,
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

    IF NOT EXISTS (SELECT 1
                   FROM dbo.AccEngineDynamicRule
                   WHERE [Rule] = N'TxnModel.PayCurrency !== TxnModel.LocalCCY')
        BEGIN
            INSERT INTO dbo.AccEngineDynamicRule (Id, Name, [Rule], Type, Description, StateId, StateDate, StateMaker)
            output inserted.Id into @TempTable
            VALUES (@LastAccEngineDynamicRuleId, N'Pay Foreign Currency', N'TxnModel.PayCurrency !== TxnModel.LocalCCY',
                    0,
                    N'', @StateId,
                    @StateDate, @StateMaker);
            SELECT @dynamicRulePayForeignCurrencyId = Id FROM @TempTable;
            delete from @TempTable
            select @LastAccEngineDynamicRuleId = @LastAccEngineDynamicRuleId + 1
        END;
    else
        begin
            select @dynamicRulePayForeignCurrencyId = Id
            from dbo.AccEngineDynamicRule
            WHERE [Rule] = N'TxnModel.PayCurrency !== TxnModel.LocalCCY'
        end

    IF NOT EXISTS (SELECT 1
                   FROM dbo.AccEngineDynamicRule
                   WHERE [Rule] = N'TxnModel.ReceiveCurrency !== TxnModel.LocalCCY')
        BEGIN
            INSERT INTO dbo.AccEngineDynamicRule (Id, Name, [Rule], Type, Description, StateId, StateDate, StateMaker)
            output inserted.Id into @TempTable
            VALUES (@LastAccEngineDynamicRuleId, N'Receive Foreign Currency',
                    N'TxnModel.ReceiveCurrency !== TxnModel.LocalCCY', 0, N'', @StateId,
                    @StateDate, @StateMaker);
            SELECT @dynamicRuleReceiveForeignCurrencyId = Id FROM @TempTable;
            delete from @TempTable
            select @LastAccEngineDynamicRuleId = @LastAccEngineDynamicRuleId + 1
        END;
    else
        begin
            select @dynamicRuleReceiveForeignCurrencyId = Id
            from dbo.AccEngineDynamicRule
            WHERE [Rule] = N'TxnModel.ReceiveCurrency !== TxnModel.LocalCCY'
        end

    IF NOT EXISTS (SELECT 1
                   FROM dbo.AccEngineDynamicRule
                   WHERE Name = N'Derivatives Portfolio = Trade'
                     AND [Rule] = N'1===1')
        BEGIN
            INSERT INTO dbo.AccEngineDynamicRule (Id, Name, [Rule], Type, Description, StateId, StateDate, StateMaker)
            output inserted.Id into @TempTable
            VALUES (@LastAccEngineDynamicRuleId, N'Derivatives Portfolio = Trade',
                    N'1===1', 0, N'', @StateId,
                    @StateDate, @StateMaker);
            SELECT @dynamicRuleDerivativePortfolioTradeId = Id FROM @TempTable;
            delete from @TempTable
            select @LastAccEngineDynamicRuleId = @LastAccEngineDynamicRuleId + 1
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
                   WHERE [Rule] = N'TxnModel.ReceiveCurrency === TxnModel.LocalCCY')
        BEGIN
            INSERT INTO dbo.AccEngineDynamicRule (Id, Name, [Rule], Type, Description, StateId, StateDate, StateMaker)
            output inserted.Id into @TempTable
            VALUES (@LastAccEngineDynamicRuleId, N'Receive Local Currency',
                    N'TxnModel.ReceiveCurrency === TxnModel.LocalCCY', 0, N'', @StateId,
                    @StateDate, @StateMaker);
            SELECT @dynamicRuleReceiveLocalCurrencyId = Id FROM @TempTable;
            delete from @TempTable
            select @LastAccEngineDynamicRuleId = @LastAccEngineDynamicRuleId + 1
        END;
    else
        begin
            select @dynamicRuleReceiveLocalCurrencyId = Id
            from dbo.AccEngineDynamicRule
            WHERE [Rule] = N'TxnModel.ReceiveCurrency === TxnModel.LocalCCY'
        end

    IF NOT EXISTS (SELECT 1
                   FROM dbo.AccEngineDynamicRule
                   WHERE [Rule] =
                         N'TxnModel.ReceivePeriodEndDate !== null ? TxnModel.ReceivePeriodEndDate.getTime() === TxnModel.LogicalDate.getTime() : false')
        BEGIN
            INSERT INTO dbo.AccEngineDynamicRule (Id, Name, [Rule], Type, Description, StateId, StateDate, StateMaker)
            output inserted.Id into @TempTable
            VALUES (@LastAccEngineDynamicRuleId, N'ReceivePeriodEndDate = LogicalDate',
                    N'TxnModel.ReceivePeriodEndDate !== null ? TxnModel.ReceivePeriodEndDate.getTime() === TxnModel.LogicalDate.getTime() : false',
                    0, N'', @StateId,
                    @StateDate, @StateMaker);
            SELECT @dynamicRuleReceivePeriodEndDateEqualsLogicalDateId = Id FROM @TempTable;
            delete from @TempTable
            select @LastAccEngineDynamicRuleId = @LastAccEngineDynamicRuleId + 1
        END;
    else
        begin
            select @dynamicRuleReceivePeriodEndDateEqualsLogicalDateId = Id
            from dbo.AccEngineDynamicRule
            WHERE [Rule] =
                  N'TxnModel.ReceivePeriodEndDate !== null ? TxnModel.ReceivePeriodEndDate.getTime() === TxnModel.LogicalDate.getTime() : false'
        end

    IF NOT EXISTS (SELECT 1
                   FROM dbo.AccEngineDynamicRule
                   WHERE [Rule] =
                         N'TxnModel.PayPeriodEndDate !== null ? TxnModel.PayPeriodEndDate.getTime() === TxnModel.LogicalDate.getTime() : false')
        BEGIN
            INSERT INTO dbo.AccEngineDynamicRule (Id, Name, [Rule], Type, Description, StateId, StateDate, StateMaker)
            output inserted.Id into @TempTable
            VALUES (@LastAccEngineDynamicRuleId, N'PayPeriodEndDate = LogicalDate',
                    N'TxnModel.PayPeriodEndDate !== null ? TxnModel.PayPeriodEndDate.getTime() === TxnModel.LogicalDate.getTime() : false',
                    0, N'', @StateId,
                    @StateDate, @StateMaker);
            SELECT @dynamicRulePayPeriodEndDateEqualsLogicalDateId = Id FROM @TempTable;
            delete from @TempTable
            select @LastAccEngineDynamicRuleId = @LastAccEngineDynamicRuleId + 1
        END;
    else
        begin
            select @dynamicRulePayPeriodEndDateEqualsLogicalDateId = Id
            from dbo.AccEngineDynamicRule
            WHERE [Rule] =
                  N'TxnModel.PayPeriodEndDate !== null ? TxnModel.PayPeriodEndDate.getTime() === TxnModel.LogicalDate.getTime() : false'
        end

    IF NOT EXISTS (SELECT 1
                   FROM dbo.AccEngineDynamicRule
                   WHERE [Rule] =
                         N'TxnModel.TotalMTMAmountCCY === TxnModel.LocalCCY')
        BEGIN
            INSERT INTO dbo.AccEngineDynamicRule (Id, Name, [Rule], Type, Description, StateId, StateDate, StateMaker)
            output inserted.Id into @TempTable
            VALUES (@LastAccEngineDynamicRuleId, N'MTM Local Currency',
                    N'TxnModel.TotalMTMAmountCCY === TxnModel.LocalCCY',
                    0, N'', @StateId,
                    @StateDate, @StateMaker);
            SELECT @dynamicRuleMtmAmountCCYEqualLocalCurrencyId = Id FROM @TempTable;
            delete from @TempTable
            select @LastAccEngineDynamicRuleId = @LastAccEngineDynamicRuleId + 1
        END;
    else
        begin
            select @dynamicRuleMtmAmountCCYEqualLocalCurrencyId = Id
            from dbo.AccEngineDynamicRule
            WHERE [Rule] =
                  N'TxnModel.TotalMTMAmountCCY === TxnModel.LocalCCY'
        end

    IF NOT EXISTS (SELECT 1
                   FROM dbo.AccEngineDynamicRule
                   WHERE [Rule] =
                         N'TxnModel.TotalMTMAmountCCY !== TxnModel.LocalCCY')
        BEGIN
            INSERT INTO dbo.AccEngineDynamicRule (Id, Name, [Rule], Type, Description, StateId, StateDate, StateMaker)
            output inserted.Id into @TempTable
            VALUES (@LastAccEngineDynamicRuleId, N'MTM Foreign Currency',
                    N'TxnModel.TotalMTMAmountCCY !== TxnModel.LocalCCY',
                    0, N'', @StateId,
                    @StateDate, @StateMaker);
            SELECT @dynamicRuleMtmAmountCCYEqualForeignCurrencyId = Id FROM @TempTable;
            delete from @TempTable
            select @LastAccEngineDynamicRuleId = @LastAccEngineDynamicRuleId + 1
        END;
    else
        begin
            select @dynamicRuleMtmAmountCCYEqualForeignCurrencyId = Id
            from dbo.AccEngineDynamicRule
            WHERE [Rule] =
                  N'TxnModel.TotalMTMAmountCCY !== TxnModel.LocalCCY'
        end

    IF NOT EXISTS (SELECT 1
                   FROM dbo.AccEngineDynamicRule
                   WHERE [Rule] = N'TxnModel.PayCurrency === TxnModel.LocalCCY')
        BEGIN
            INSERT INTO dbo.AccEngineDynamicRule (Id, Name, [Rule], Type, Description, StateId, StateDate, StateMaker)
            output inserted.Id into @TempTable
            VALUES (@LastAccEngineDynamicRuleId, N'Pay Local Currency', N'TxnModel.PayCurrency === TxnModel.LocalCCY',
                    0,
                    N'', @StateId,
                    @StateDate, @StateMaker);
            SELECT @dynamicRulePayLocalCurrencyId = Id FROM @TempTable;
            delete from @TempTable
            select @LastAccEngineDynamicRuleId = @LastAccEngineDynamicRuleId + 1
        END;
    else
        begin
            select @dynamicRulePayLocalCurrencyId = Id
            from dbo.AccEngineDynamicRule
            WHERE [Rule] = N'TxnModel.PayCurrency === TxnModel.LocalCCY'
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
            VALUES (@lastAccEngineItemTypeId, N'Prd', N'Product', 0, null, 'TREX', @StateId,
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
                    @StateId,
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
            VALUES (@lastAccEngineItemTypeId, N'TxnType', N'Transaction Type', 0, null, N'TREX', @StateId, @stateDate,
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
            VALUES (@lastAccEngineItemCodeId, N'DV', N'Derivatives', N'Prd', @StateId, @stateDate, @stateMaker);
            select @lastAccEngineItemCodeId = @lastAccEngineItemCodeId + 1
        end

    if not exists(select 1
                  from dbo.AccEngineItemCode
                  where Code = N'CCS')
        begin
            INSERT INTO dbo.AccEngineItemCode (Id, Code, Name, ItemTypeCode, StateId, StateDate, StateMaker)
            VALUES (@lastAccEngineItemCodeId, N'CCS', N'Cross Currency Swap', N'TxnType', @StateId, @stateDate,
                    @stateMaker);
            select @lastAccEngineItemCodeId = @lastAccEngineItemCodeId + 1
        end

    if not exists(select 1
                  from dbo.AccEngineItemCode
                  where Code = N'LCYRFCYP')
        begin
            INSERT INTO dbo.AccEngineItemCode (Id, Code, Name, ItemTypeCode, StateId, StateDate, StateMaker)
            VALUES (@lastAccEngineItemCodeId, N'LCYRFCYP', N'LCY Receive FCY Pay', N'DerivativesDirection', @StateId,
                    @stateDate, @stateMaker);
            select @lastAccEngineItemCodeId = @lastAccEngineItemCodeId + 1
        end

    if not exists(select 1
                  from dbo.AccEngineItemCode
                  where Code = N'FCYRLCYP')
        begin
            INSERT INTO dbo.AccEngineItemCode (Id, Code, Name, ItemTypeCode, StateId, StateDate, StateMaker)
            VALUES (@lastAccEngineItemCodeId, N'FCYRLCYP', N'FCY Receive LCY Pay ', N'DerivativesDirection', @StateId,
                    @stateDate,
                    @stateMaker);
            select @lastAccEngineItemCodeId = @lastAccEngineItemCodeId + 1
        end

    if not exists(select 1
                  from dbo.AccEngineItemCode
                  where Code = N'FCYRFCYP')
        begin
            INSERT INTO dbo.AccEngineItemCode (Id, Code, Name, ItemTypeCode, StateId, StateDate, StateMaker)
            VALUES (@lastAccEngineItemCodeId, N'FCYRFCYP', N'FCY Receive FCY Pay', N'DerivativesDirection', @StateId,
                    @stateDate, @stateMaker);
        end

    --#endregion
    ------------------------------------------------------------------------------------------------------------------------
    -- Accounting Account Map
    ------------------------------------------------------------------------------------------------------------------------
--#region AccAccountMap
    declare @lastAccAccountMapOrderNo int = 10;
    IF NOT EXISTS(select 1
                  from dbo.AccAccountMap
                  where Path = N'TREX/DV/CCS'
                    and Source = N'CapitalGainFCY'
                    and Target = N'75301000')
        BEGIN
            INSERT INTO dbo.AccAccountMap (Id, Ccy, CustomerId, RuleId, Rule2Id, Rule3Id, Rule4Id, Rule5Id, Rule6Id,
                                           Rule7Id, Rule8Id, Rule9Id, Rule10Id, Source, Path, TargetMainGL, Target,
                                           TargetRuleId, IsEnabled, [Order], Description, CustomerCodeSourceRuleId,
                                           CustomerAccountCodeSourceRuleId, StateId, StateMaker, StateDate)
            VALUES (@lastAccAccountMapId, null, null, null, null, null, @dynamicRuleDerivativePortfolioTradeId, null,
                    null, null, null, null, null, N'CapitalGainFCY', N'TREX/DV/CCS', N'753', N'75301000', null, 1,
                    @lastAccAccountMapOrderNo, N'', null, null, @stateId, @stateMaker, @stateDate);

            select @lastAccAccountMapId = @lastAccAccountMapId + 1
            select @lastAccAccountMapOrderNo = @lastAccAccountMapOrderNo + 10
        END

    IF NOT EXISTS(select 1
                  from dbo.AccAccountMap
                  where Path = N'TREX/DV/CCS'
                    and Source = N'CapitalGainLCY'
                    and Target = N'75201000')
        BEGIN
            INSERT INTO dbo.AccAccountMap (Id, Ccy, CustomerId, RuleId, Rule2Id, Rule3Id, Rule4Id, Rule5Id, Rule6Id,
                                           Rule7Id, Rule8Id, Rule9Id, Rule10Id, Source, Path, TargetMainGL, Target,
                                           TargetRuleId, IsEnabled, [Order], Description, CustomerCodeSourceRuleId,
                                           CustomerAccountCodeSourceRuleId, StateId, StateMaker, StateDate)
            VALUES (@lastAccAccountMapId, null, null, null, null, null, @dynamicRuleDerivativePortfolioTradeId, null,
                    null, null, null, null, null, N'CapitalGainLCY', N'TREX/DV/CCS', N'752', N'75201000', null, 1,
                    @lastAccAccountMapOrderNo, N'', null, null, @stateId, @stateMaker, @stateDate);

            select @lastAccAccountMapId = @lastAccAccountMapId + 1
            select @lastAccAccountMapOrderNo = @lastAccAccountMapOrderNo + 10
        END

    IF NOT EXISTS(select 1
                  from dbo.AccAccountMap
                  where Path = N'TREX/DV/CCS'
                    and Source = N'CapitalLossFCY'
                    and Target = N'87301000')
        BEGIN
            INSERT INTO dbo.AccAccountMap (Id, Ccy, CustomerId, RuleId, Rule2Id, Rule3Id, Rule4Id, Rule5Id, Rule6Id,
                                           Rule7Id, Rule8Id, Rule9Id, Rule10Id, Source, Path, TargetMainGL, Target,
                                           TargetRuleId, IsEnabled, [Order], Description, CustomerCodeSourceRuleId,
                                           CustomerAccountCodeSourceRuleId, StateId, StateMaker, StateDate)
            VALUES (@lastAccAccountMapId, null, null, null, null, null, @dynamicRuleDerivativePortfolioTradeId, null,
                    null, null, null, null, null, N'CapitalLossFCY', N'TREX/DV/CCS', N'873', N'87301000', null, 1,
                    @lastAccAccountMapOrderNo, N'', null, null, @stateId, @stateMaker, @stateDate);

            select @lastAccAccountMapId = @lastAccAccountMapId + 1
            select @lastAccAccountMapOrderNo = @lastAccAccountMapOrderNo + 10
        END

    IF NOT EXISTS(select 1
                  from dbo.AccAccountMap
                  where Path = N'TREX/DV/CCS'
                    and Source = N'CapitalLossLCY'
                    and Target = N'87201000')
        BEGIN
            INSERT INTO dbo.AccAccountMap (Id, Ccy, CustomerId, RuleId, Rule2Id, Rule3Id, Rule4Id, Rule5Id, Rule6Id,
                                           Rule7Id, Rule8Id, Rule9Id, Rule10Id, Source, Path, TargetMainGL, Target,
                                           TargetRuleId, IsEnabled, [Order], Description, CustomerCodeSourceRuleId,
                                           CustomerAccountCodeSourceRuleId, StateId, StateMaker, StateDate)
            VALUES (@lastAccAccountMapId, null, null, null, null, null, @dynamicRuleDerivativePortfolioTradeId, null,
                    null, null, null, null, null, N'CapitalLossLCY', N'TREX/DV/CCS', N'872', N'87201000', null, 1,
                    @lastAccAccountMapOrderNo, N'', null, null, @stateId, @stateMaker, @stateDate);

            select @lastAccAccountMapId = @lastAccAccountMapId + 1
            select @lastAccAccountMapOrderNo = @lastAccAccountMapOrderNo + 10
        END

    IF NOT EXISTS(select 1
                  from dbo.AccAccountMap
                  where Path = N'TREX/DV/CCS'
                    and Source = N'FXPositionLCY'
                    and Target = N'29400')
        BEGIN
            INSERT INTO dbo.AccAccountMap (Id, Ccy, CustomerId, RuleId, Rule2Id, Rule3Id, Rule4Id, Rule5Id, Rule6Id,
                                           Rule7Id, Rule8Id, Rule9Id, Rule10Id, Source, Path, TargetMainGL, Target,
                                           TargetRuleId, IsEnabled, [Order], Description, CustomerCodeSourceRuleId,
                                           CustomerAccountCodeSourceRuleId, StateId, StateMaker, StateDate)
            VALUES (@lastAccAccountMapId, null, null, null, null, null, @dynamicRuleDerivativePortfolioTradeId, null,
                    null, null, null, null, null, N'FXPositionLCY', N'TREX/DV/CCS', N'294', N'29400', null, 1,
                    @lastAccAccountMapOrderNo, N'', null, null, @stateId, @stateMaker, @stateDate);

            select @lastAccAccountMapId = @lastAccAccountMapId + 1
            select @lastAccAccountMapOrderNo = @lastAccAccountMapOrderNo + 10
        END

    IF NOT EXISTS(select 1
                  from dbo.AccAccountMap
                  where Path = N'TREX/DV/CCS'
                    and Source = N'FXPositionPay'
                    and Target = N'29500000')
        BEGIN
            INSERT INTO dbo.AccAccountMap (Id, Ccy, CustomerId, RuleId, Rule2Id, Rule3Id, Rule4Id, Rule5Id, Rule6Id,
                                           Rule7Id, Rule8Id, Rule9Id, Rule10Id, Source, Path, TargetMainGL, Target,
                                           TargetRuleId, IsEnabled, [Order], Description, CustomerCodeSourceRuleId,
                                           CustomerAccountCodeSourceRuleId, StateId, StateMaker, StateDate)
            VALUES (@lastAccAccountMapId, null, null, null, null, @dynamicRulePayForeignCurrencyId,
                    @dynamicRuleDerivativePortfolioTradeId, null, null, null, null, null, null, N'FXPositionPay',
                    N'TREX/DV/CCS', N'295', N'29500000', null, 1, @lastAccAccountMapOrderNo, N'', null, null, @stateId,
                    @stateMaker, @stateDate);

            select @lastAccAccountMapId = @lastAccAccountMapId + 1
            select @lastAccAccountMapOrderNo = @lastAccAccountMapOrderNo + 10
        END

    IF NOT EXISTS(select 1
                  from dbo.AccAccountMap
                  where Path = N'TREX/DV/CCS'
                    and Source = N'FXPositionRec'
                    and Target = N'29500000')
        BEGIN
            INSERT INTO dbo.AccAccountMap (Id, Ccy, CustomerId, RuleId, Rule2Id, Rule3Id, Rule4Id, Rule5Id, Rule6Id,
                                           Rule7Id, Rule8Id, Rule9Id, Rule10Id, Source, Path, TargetMainGL, Target,
                                           TargetRuleId, IsEnabled, [Order], Description, CustomerCodeSourceRuleId,
                                           CustomerAccountCodeSourceRuleId, StateId, StateMaker, StateDate)
            VALUES (@lastAccAccountMapId, null, null, null, null, @dynamicRuleReceiveForeignCurrencyId,
                    @dynamicRuleDerivativePortfolioTradeId, null, null, null, null, null, null, N'FXPositionRec',
                    N'TREX/DV/CCS', N'295', N'29500000', null, 1, @lastAccAccountMapOrderNo, N'', null, null, @stateId,
                    @stateMaker, @stateDate);

            select @lastAccAccountMapId = @lastAccAccountMapId + 1
            select @lastAccAccountMapOrderNo = @lastAccAccountMapOrderNo + 10
        END

    IF NOT EXISTS(select 1
                  from dbo.AccAccountMap
                  where Path = N'TREX/DV/CCS'
                    and Source = N'IncomingPaymentFCY'
                    and Target = N'39300800')
        BEGIN
            INSERT INTO dbo.AccAccountMap (Id, Ccy, CustomerId, RuleId, Rule2Id, Rule3Id, Rule4Id, Rule5Id, Rule6Id,
                                           Rule7Id, Rule8Id, Rule9Id, Rule10Id, Source, Path, TargetMainGL, Target,
                                           TargetRuleId, IsEnabled, [Order], Description, CustomerCodeSourceRuleId,
                                           CustomerAccountCodeSourceRuleId, StateId, StateMaker, StateDate)
            VALUES (@lastAccAccountMapId, null, null, null, null, @dynamicRuleReceiveForeignCurrencyId,
                    @dynamicRuleDerivativePortfolioTradeId, null, null, null, null, null, null, N'IncomingPaymentFCY',
                    N'TREX/DV/CCS', N'393', N'39300800', null, 1, @lastAccAccountMapOrderNo, N'', null, null, @stateId,
                    @stateMaker, @stateDate);

            select @lastAccAccountMapId = @lastAccAccountMapId + 1
            select @lastAccAccountMapOrderNo = @lastAccAccountMapOrderNo + 10
        END

    IF NOT EXISTS(select 1
                  from dbo.AccAccountMap
                  where Path = N'TREX/DV/CCS'
                    and Source = N'IncomingPaymentLCY'
                    and Target = N'39200800')
        BEGIN
            INSERT INTO dbo.AccAccountMap (Id, Ccy, CustomerId, RuleId, Rule2Id, Rule3Id, Rule4Id, Rule5Id, Rule6Id,
                                           Rule7Id, Rule8Id, Rule9Id, Rule10Id, Source, Path, TargetMainGL, Target,
                                           TargetRuleId, IsEnabled, [Order], Description, CustomerCodeSourceRuleId,
                                           CustomerAccountCodeSourceRuleId, StateId, StateMaker, StateDate)
            VALUES (@lastAccAccountMapId, null, null, null, null, @dynamicRuleReceiveLocalCurrencyId,
                    @dynamicRuleDerivativePortfolioTradeId, null, null, null, null, null, null, N'IncomingPaymentLCY',
                    N'TREX/DV/CCS', N'392', N'39200800', null, 1, @lastAccAccountMapOrderNo, N'', null, null, @stateId,
                    @stateMaker, @stateDate);

            select @lastAccAccountMapId = @lastAccAccountMapId + 1
            select @lastAccAccountMapOrderNo = @lastAccAccountMapOrderNo + 10
        END

    IF NOT EXISTS(select 1
                  from dbo.AccAccountMap
                  where Path = N'TREX/DV/CCS'
                    and Source = N'InterestExpense'
                    and Target = N'69909000')
        BEGIN
            INSERT INTO dbo.AccAccountMap (Id, Ccy, CustomerId, RuleId, Rule2Id, Rule3Id, Rule4Id, Rule5Id, Rule6Id,
                                           Rule7Id, Rule8Id, Rule9Id, Rule10Id, Source, Path, TargetMainGL, Target,
                                           TargetRuleId, IsEnabled, [Order], Description, CustomerCodeSourceRuleId,
                                           CustomerAccountCodeSourceRuleId, StateId, StateMaker, StateDate)
            VALUES (@lastAccAccountMapId, null, null, null, null, @dynamicRulePayForeignCurrencyId,
                    @dynamicRuleDerivativePortfolioTradeId, null, null, null, null, null, null, N'InterestExpense',
                    N'TREX/DV/CCS', N'699', N'69909000', null, 1, @lastAccAccountMapOrderNo, N'', null, null, @stateId,
                    @stateMaker, @stateDate);

            select @lastAccAccountMapId = @lastAccAccountMapId + 1
            select @lastAccAccountMapOrderNo = @lastAccAccountMapOrderNo + 10
        END

    IF NOT EXISTS(select 1
                  from dbo.AccAccountMap
                  where Path = N'TREX/DV/CCS'
                    and Source = N'InterestExpense'
                    and Target = N'69809000')
        BEGIN
            INSERT INTO dbo.AccAccountMap (Id, Ccy, CustomerId, RuleId, Rule2Id, Rule3Id, Rule4Id, Rule5Id, Rule6Id,
                                           Rule7Id, Rule8Id, Rule9Id, Rule10Id, Source, Path, TargetMainGL, Target,
                                           TargetRuleId, IsEnabled, [Order], Description, CustomerCodeSourceRuleId,
                                           CustomerAccountCodeSourceRuleId, StateId, StateMaker, StateDate)
            VALUES (@lastAccAccountMapId, null, null, null, null, @dynamicRulePayLocalCurrencyId,
                    @dynamicRuleDerivativePortfolioTradeId, null, null, null, null, null, null, N'InterestExpense',
                    N'TREX/DV/CCS', N'698', N'69809000', null, 1, @lastAccAccountMapOrderNo, N'', null, null, @stateId,
                    @stateMaker, @stateDate);

            select @lastAccAccountMapId = @lastAccAccountMapId + 1
            select @lastAccAccountMapOrderNo = @lastAccAccountMapOrderNo + 10
        END

    IF NOT EXISTS(select 1
                  from dbo.AccAccountMap
                  where Path = N'TREX/DV/CCS'
                    and Source = N'InterestIncome'
                    and Target = N'59909000')
        BEGIN
            INSERT INTO dbo.AccAccountMap (Id, Ccy, CustomerId, RuleId, Rule2Id, Rule3Id, Rule4Id, Rule5Id, Rule6Id,
                                           Rule7Id, Rule8Id, Rule9Id, Rule10Id, Source, Path, TargetMainGL, Target,
                                           TargetRuleId, IsEnabled, [Order], Description, CustomerCodeSourceRuleId,
                                           CustomerAccountCodeSourceRuleId, StateId, StateMaker, StateDate)
            VALUES (@lastAccAccountMapId, null, null, null, null, @dynamicRuleReceiveForeignCurrencyId,
                    @dynamicRuleDerivativePortfolioTradeId, null, null, null, null, null, null, N'InterestIncome',
                    N'TREX/DV/CCS', N'599', N'59909000', null, 1, @lastAccAccountMapOrderNo, N'', null, null, @stateId,
                    @stateMaker, @stateDate);

            select @lastAccAccountMapId = @lastAccAccountMapId + 1
            select @lastAccAccountMapOrderNo = @lastAccAccountMapOrderNo + 10
        END

    IF NOT EXISTS(select 1
                  from dbo.AccAccountMap
                  where Path = N'TREX/DV/CCS'
                    and Source = N'InterestIncome'
                    and Target = N'59809000')
        BEGIN
            INSERT INTO dbo.AccAccountMap (Id, Ccy, CustomerId, RuleId, Rule2Id, Rule3Id, Rule4Id, Rule5Id, Rule6Id,
                                           Rule7Id, Rule8Id, Rule9Id, Rule10Id, Source, Path, TargetMainGL, Target,
                                           TargetRuleId, IsEnabled, [Order], Description, CustomerCodeSourceRuleId,
                                           CustomerAccountCodeSourceRuleId, StateId, StateMaker, StateDate)
            VALUES (@lastAccAccountMapId, null, null, null, null, @dynamicRuleReceiveLocalCurrencyId,
                    @dynamicRuleDerivativePortfolioTradeId, null, null, null, null, null, null, N'InterestIncome',
                    N'TREX/DV/CCS', N'598', N'59809000', null, 1, @lastAccAccountMapOrderNo, N'', null, null, @stateId,
                    @stateMaker, @stateDate);

            select @lastAccAccountMapId = @lastAccAccountMapId + 1
            select @lastAccAccountMapOrderNo = @lastAccAccountMapOrderNo + 10
        END

    ------------------------------------------------------------------------------------------------------------------------
    -- MatPayContingent
    ------------------------------------------------------------------------------------------------------------------------
--#region MatPayContingent

    IF NOT EXISTS(select 1
                  from dbo.AccAccountMap
                  where Path = N'TREX/DV/CCS'
                    and Source = N'MatPayContingent'
                    and Target = N'96710300')
        BEGIN
            INSERT INTO dbo.AccAccountMap (Id, Ccy, CustomerId, RuleId, Rule2Id, Rule3Id, Rule4Id, Rule5Id, Rule6Id,
                                           Rule7Id, Rule8Id, Rule9Id, Rule10Id, Source, Path, TargetMainGL, Target,
                                           TargetRuleId, IsEnabled, [Order], Description, CustomerCodeSourceRuleId,
                                           CustomerAccountCodeSourceRuleId, StateId, StateMaker, StateDate)
            VALUES (@lastAccAccountMapId, null, null, null, null, @dynamicRulePayForeignCurrencyId,
                    @dynamicRuleDerivativePortfolioTradeId, @dynamicRuleReceiveForeignCurrencyId, null, null, null,
                    null, null, N'MatPayContingent',
                    N'TREX/DV/CCS', N'967', N'96710300', null, 1, @lastAccAccountMapOrderNo, N'', null, null, @stateId,
                    @stateMaker, @stateDate);

            select @lastAccAccountMapId = @lastAccAccountMapId + 1
            select @lastAccAccountMapOrderNo = @lastAccAccountMapOrderNo + 10
        END

    IF NOT EXISTS(select 1
                  from dbo.AccAccountMap
                  where Path = N'TREX/DV/CCS'
                    and Source = N'MatPayContingent'
                    and Target = N'96610100')
        BEGIN
            INSERT INTO dbo.AccAccountMap (Id, Ccy, CustomerId, RuleId, Rule2Id, Rule3Id, Rule4Id, Rule5Id, Rule6Id,
                                           Rule7Id, Rule8Id, Rule9Id, Rule10Id, Source, Path, TargetMainGL, Target,
                                           TargetRuleId, IsEnabled, [Order], Description, CustomerCodeSourceRuleId,
                                           CustomerAccountCodeSourceRuleId, StateId, StateMaker, StateDate)
            VALUES (@lastAccAccountMapId, null, null, null, null, @dynamicRulePayLocalCurrencyId,
                    @dynamicRuleDerivativePortfolioTradeId, null, null, null, null, null, null, N'MatPayContingent',
                    N'TREX/DV/CCS', N'966', N'96610100', null, 1, @lastAccAccountMapOrderNo, N'', null, null, @stateId,
                    @stateMaker, @stateDate);

            select @lastAccAccountMapId = @lastAccAccountMapId + 1
            select @lastAccAccountMapOrderNo = @lastAccAccountMapOrderNo + 10
        END

    IF NOT EXISTS(select 1
                  from dbo.AccAccountMap
                  where Path = N'TREX/DV/CCS'
                    and Source = N'MatPayContingent'
                    and Target = N'96710200')
        BEGIN
            INSERT INTO dbo.AccAccountMap (Id, Ccy, CustomerId, RuleId, Rule2Id, Rule3Id, Rule4Id, Rule5Id, Rule6Id,
                                           Rule7Id, Rule8Id, Rule9Id, Rule10Id, Source, Path, TargetMainGL, Target,
                                           TargetRuleId, IsEnabled, [Order], Description, CustomerCodeSourceRuleId,
                                           CustomerAccountCodeSourceRuleId, StateId, StateMaker, StateDate)
            VALUES (@lastAccAccountMapId, null, null, null, null, @dynamicRulePayForeignCurrencyId,
                    @dynamicRuleDerivativePortfolioTradeId, @dynamicRuleReceiveLocalCurrencyId, null, null, null, null,
                    null, N'MatPayContingent',
                    N'TREX/DV/CCS', N'967', N'96710200', null, 1, @lastAccAccountMapOrderNo, N'', null, null, @stateId,
                    @stateMaker, @stateDate);

            select @lastAccAccountMapId = @lastAccAccountMapId + 1
            select @lastAccAccountMapOrderNo = @lastAccAccountMapOrderNo + 10
        END

    --#endregion
    ------------------------------------------------------------------------------------------------------------------------
    -- MatPayContingentOffset
    ------------------------------------------------------------------------------------------------------------------------
--#region MatPayContingentOffset

    IF NOT EXISTS(select 1
                  from dbo.AccAccountMap
                  where Path = N'TREX/DV/CCS'
                    and Source = N'MatPayContingentOffset'
                    and Target = N'96510300')
        BEGIN
            INSERT INTO dbo.AccAccountMap (Id, Ccy, CustomerId, RuleId, Rule2Id, Rule3Id, Rule4Id, Rule5Id, Rule6Id,
                                           Rule7Id, Rule8Id, Rule9Id, Rule10Id, Source, Path, TargetMainGL, Target,
                                           TargetRuleId, IsEnabled, [Order], Description, CustomerCodeSourceRuleId,
                                           CustomerAccountCodeSourceRuleId, StateId, StateMaker, StateDate)
            VALUES (@lastAccAccountMapId, null, null, null, null, @dynamicRulePayForeignCurrencyId,
                    @dynamicRuleDerivativePortfolioTradeId, @dynamicRuleReceiveForeignCurrencyId, null, null, null,
                    null, null,
                    N'MatPayContingentOffset', N'TREX/DV/CCS', N'965', N'96510300', null, 1, @lastAccAccountMapOrderNo,
                    N'', null, null, @stateId, @stateMaker, @stateDate);

            select @lastAccAccountMapId = @lastAccAccountMapId + 1
            select @lastAccAccountMapOrderNo = @lastAccAccountMapOrderNo + 10
        END

    IF NOT EXISTS(select 1
                  from dbo.AccAccountMap
                  where Path = N'TREX/DV/CCS'
                    and Source = N'MatPayContingentOffset'
                    and Target = N'96410100')
        BEGIN
            INSERT INTO dbo.AccAccountMap (Id, Ccy, CustomerId, RuleId, Rule2Id, Rule3Id, Rule4Id, Rule5Id, Rule6Id,
                                           Rule7Id, Rule8Id, Rule9Id, Rule10Id, Source, Path, TargetMainGL, Target,
                                           TargetRuleId, IsEnabled, [Order], Description, CustomerCodeSourceRuleId,
                                           CustomerAccountCodeSourceRuleId, StateId, StateMaker, StateDate)
            VALUES (@lastAccAccountMapId, null, null, null, null, @dynamicRulePayLocalCurrencyId,
                    @dynamicRuleDerivativePortfolioTradeId, null, null, null, null, null, null,
                    N'MatPayContingentOffset', N'TREX/DV/CCS', N'964', N'96410100', null, 1, @lastAccAccountMapOrderNo,
                    N'', null, null, @stateId, @stateMaker, @stateDate);

            select @lastAccAccountMapId = @lastAccAccountMapId + 1
            select @lastAccAccountMapOrderNo = @lastAccAccountMapOrderNo + 10
        END

    IF NOT EXISTS(select 1
                  from dbo.AccAccountMap
                  where Path = N'TREX/DV/CCS'
                    and Source = N'MatPayContingentOffset'
                    and Target = N'96510200')
        BEGIN
            INSERT INTO dbo.AccAccountMap (Id, Ccy, CustomerId, RuleId, Rule2Id, Rule3Id, Rule4Id, Rule5Id, Rule6Id,
                                           Rule7Id, Rule8Id, Rule9Id, Rule10Id, Source, Path, TargetMainGL, Target,
                                           TargetRuleId, IsEnabled, [Order], Description, CustomerCodeSourceRuleId,
                                           CustomerAccountCodeSourceRuleId, StateId, StateMaker, StateDate)
            VALUES (@lastAccAccountMapId, null, null, null, null, @dynamicRulePayForeignCurrencyId,
                    @dynamicRuleDerivativePortfolioTradeId, @dynamicRuleReceiveLocalCurrencyId, null, null, null, null,
                    null,
                    N'MatPayContingentOffset', N'TREX/DV/CCS', N'965', N'96510200', null, 1, @lastAccAccountMapOrderNo,
                    N'', null, null, @stateId, @stateMaker, @stateDate);

            select @lastAccAccountMapId = @lastAccAccountMapId + 1
            select @lastAccAccountMapOrderNo = @lastAccAccountMapOrderNo + 10
        END

--#endregion

    IF NOT EXISTS(select 1
                  from dbo.AccAccountMap
                  where Path = N'TREX/DV/CCS'
                    and Source = N'MatPayPrincipal'
                    and Target = N'39300800')
        BEGIN
            INSERT INTO dbo.AccAccountMap (Id, Ccy, CustomerId, RuleId, Rule2Id, Rule3Id, Rule4Id, Rule5Id, Rule6Id,
                                           Rule7Id, Rule8Id, Rule9Id, Rule10Id, Source, Path, TargetMainGL, Target,
                                           TargetRuleId, IsEnabled, [Order], Description, CustomerCodeSourceRuleId,
                                           CustomerAccountCodeSourceRuleId, StateId, StateMaker, StateDate)
            VALUES (@lastAccAccountMapId, null, null, null, null, @dynamicRulePayForeignCurrencyId,
                    @dynamicRuleDerivativePortfolioTradeId, null, null, null, null, null, null, N'MatPayPrincipal',
                    N'TREX/DV/CCS', N'393', N'39300800', null, 1, @lastAccAccountMapOrderNo, N'', null, null, @stateId,
                    @stateMaker, @stateDate);

            select @lastAccAccountMapId = @lastAccAccountMapId + 1
            select @lastAccAccountMapOrderNo = @lastAccAccountMapOrderNo + 10
        END

    IF NOT EXISTS(select 1
                  from dbo.AccAccountMap
                  where Path = N'TREX/DV/CCS'
                    and Source = N'MatPayPrincipal'
                    and Target = N'39200800')
        BEGIN
            INSERT INTO dbo.AccAccountMap (Id, Ccy, CustomerId, RuleId, Rule2Id, Rule3Id, Rule4Id, Rule5Id, Rule6Id,
                                           Rule7Id, Rule8Id, Rule9Id, Rule10Id, Source, Path, TargetMainGL, Target,
                                           TargetRuleId, IsEnabled, [Order], Description, CustomerCodeSourceRuleId,
                                           CustomerAccountCodeSourceRuleId, StateId, StateMaker, StateDate)
            VALUES (@lastAccAccountMapId, null, null, null, null, @dynamicRulePayLocalCurrencyId,
                    @dynamicRuleDerivativePortfolioTradeId, null, null, null, null, null, null, N'MatPayPrincipal',
                    N'TREX/DV/CCS', N'392', N'39200800', null, 1, @lastAccAccountMapOrderNo, N'', null, null, @stateId,
                    @stateMaker, @stateDate);

            select @lastAccAccountMapId = @lastAccAccountMapId + 1
            select @lastAccAccountMapOrderNo = @lastAccAccountMapOrderNo + 10
        END
    ------------------------------------------------------------------------------------------------------------------------
    -- MatRecContingent
    ------------------------------------------------------------------------------------------------------------------------
--#region MatRecContingent

    IF NOT EXISTS(select 1
                  from dbo.AccAccountMap
                  where Path = N'TREX/DV/CCS'
                    and Source = N'MatRecContingent'
                    and Target = N'96510100')
        BEGIN
            INSERT INTO dbo.AccAccountMap (Id, Ccy, CustomerId, RuleId, Rule2Id, Rule3Id, Rule4Id, Rule5Id, Rule6Id,
                                           Rule7Id, Rule8Id, Rule9Id, Rule10Id, Source, Path, TargetMainGL, Target,
                                           TargetRuleId, IsEnabled, [Order], Description, CustomerCodeSourceRuleId,
                                           CustomerAccountCodeSourceRuleId, StateId, StateMaker, StateDate)
            VALUES (@lastAccAccountMapId, null, null, null, null, @dynamicRuleReceiveForeignCurrencyId,
                    @dynamicRuleDerivativePortfolioTradeId, @dynamicRulePayForeignCurrencyId, null, null, null, null,
                    null, N'MatRecContingent',
                    N'TREX/DV/CCS', N'965', N'96510100', null, 1, @lastAccAccountMapOrderNo, N'', null, null, @stateId,
                    @stateMaker, @stateDate);

            select @lastAccAccountMapId = @lastAccAccountMapId + 1
            select @lastAccAccountMapOrderNo = @lastAccAccountMapOrderNo + 10
        END

    IF NOT EXISTS(select 1
                  from dbo.AccAccountMap
                  where Path = N'TREX/DV/CCS'
                    and Source = N'MatRecContingent'
                    and Target = N'96510000')
        BEGIN
            INSERT INTO dbo.AccAccountMap (Id, Ccy, CustomerId, RuleId, Rule2Id, Rule3Id, Rule4Id, Rule5Id, Rule6Id,
                                           Rule7Id, Rule8Id, Rule9Id, Rule10Id, Source, Path, TargetMainGL, Target,
                                           TargetRuleId, IsEnabled, [Order], Description, CustomerCodeSourceRuleId,
                                           CustomerAccountCodeSourceRuleId, StateId, StateMaker, StateDate)
            VALUES (@lastAccAccountMapId, null, null, null, null, @dynamicRuleReceiveForeignCurrencyId,
                    @dynamicRuleDerivativePortfolioTradeId, @dynamicRulePayLocalCurrencyId, null, null, null, null,
                    null, N'MatRecContingent',
                    N'TREX/DV/CCS', N'965', N'96510000', null, 1, @lastAccAccountMapOrderNo, N'', null, null, @stateId,
                    @stateMaker, @stateDate);

            select @lastAccAccountMapId = @lastAccAccountMapId + 1
            select @lastAccAccountMapOrderNo = @lastAccAccountMapOrderNo + 10
        END

    IF NOT EXISTS(select 1
                  from dbo.AccAccountMap
                  where Path = N'TREX/DV/CCS'
                    and Source = N'MatRecContingent'
                    and Target = N'96410000')
        BEGIN
            INSERT INTO dbo.AccAccountMap (Id, Ccy, CustomerId, RuleId, Rule2Id, Rule3Id, Rule4Id, Rule5Id, Rule6Id,
                                           Rule7Id, Rule8Id, Rule9Id, Rule10Id, Source, Path, TargetMainGL, Target,
                                           TargetRuleId, IsEnabled, [Order], Description, CustomerCodeSourceRuleId,
                                           CustomerAccountCodeSourceRuleId, StateId, StateMaker, StateDate)
            VALUES (@lastAccAccountMapId, null, null, null, null, @dynamicRuleReceiveLocalCurrencyId,
                    @dynamicRuleDerivativePortfolioTradeId, null, null, null, null, null, null, N'MatRecContingent',
                    N'TREX/DV/CCS', N'964', N'96410000', null, 1, @lastAccAccountMapOrderNo, N'', null, null, @stateId,
                    @stateMaker, @stateDate);

            select @lastAccAccountMapId = @lastAccAccountMapId + 1
            select @lastAccAccountMapOrderNo = @lastAccAccountMapOrderNo + 10
        END

    --#endregion
    ------------------------------------------------------------------------------------------------------------------------
    -- MatRecContingentOffset
    ------------------------------------------------------------------------------------------------------------------------
--#region MatRecContingentOffset

    IF NOT EXISTS(select 1
                  from dbo.AccAccountMap
                  where Path = N'TREX/DV/CCS'
                    and Source = N'MatRecContingentOffset'
                    and Target = N'96710100')
        BEGIN
            INSERT INTO dbo.AccAccountMap (Id, Ccy, CustomerId, RuleId, Rule2Id, Rule3Id, Rule4Id, Rule5Id, Rule6Id,
                                           Rule7Id, Rule8Id, Rule9Id, Rule10Id, Source, Path, TargetMainGL, Target,
                                           TargetRuleId, IsEnabled, [Order], Description, CustomerCodeSourceRuleId,
                                           CustomerAccountCodeSourceRuleId, StateId, StateMaker, StateDate)
            VALUES (@lastAccAccountMapId, null, null, null, null, @dynamicRuleReceiveForeignCurrencyId,
                    @dynamicRuleDerivativePortfolioTradeId, @dynamicRulePayForeignCurrencyId, null, null, null, null, null,
                    N'MatRecContingentOffset', N'TREX/DV/CCS', N'967', N'96710100', null, 1, @lastAccAccountMapOrderNo,
                    N'', null, null, @stateId, @stateMaker, @stateDate);

            select @lastAccAccountMapId = @lastAccAccountMapId + 1
            select @lastAccAccountMapOrderNo = @lastAccAccountMapOrderNo + 10
        END

    IF NOT EXISTS(select 1
                  from dbo.AccAccountMap
                  where Path = N'TREX/DV/CCS'
                    and Source = N'MatRecContingentOffset'
                    and Target = N'96710000')
        BEGIN
            INSERT INTO dbo.AccAccountMap (Id, Ccy, CustomerId, RuleId, Rule2Id, Rule3Id, Rule4Id, Rule5Id, Rule6Id,
                                           Rule7Id, Rule8Id, Rule9Id, Rule10Id, Source, Path, TargetMainGL, Target,
                                           TargetRuleId, IsEnabled, [Order], Description, CustomerCodeSourceRuleId,
                                           CustomerAccountCodeSourceRuleId, StateId, StateMaker, StateDate)
            VALUES (@lastAccAccountMapId, null, null, null, null, @dynamicRuleReceiveForeignCurrencyId,
                    @dynamicRuleDerivativePortfolioTradeId, @dynamicRulePayLocalCurrencyId, null, null, null, null, null,
                    N'MatRecContingentOffset', N'TREX/DV/CCS', N'967', N'96710000', null, 1, @lastAccAccountMapOrderNo,
                    N'', null, null, @stateId, @stateMaker, @stateDate);

            select @lastAccAccountMapId = @lastAccAccountMapId + 1
            select @lastAccAccountMapOrderNo = @lastAccAccountMapOrderNo + 10
        END

    IF NOT EXISTS(select 1
                  from dbo.AccAccountMap
                  where Path = N'TREX/DV/CCS'
                    and Source = N'MatRecContingentOffset'
                    and Target = N'96610000')
        BEGIN
            INSERT INTO dbo.AccAccountMap (Id, Ccy, CustomerId, RuleId, Rule2Id, Rule3Id, Rule4Id, Rule5Id, Rule6Id,
                                           Rule7Id, Rule8Id, Rule9Id, Rule10Id, Source, Path, TargetMainGL, Target,
                                           TargetRuleId, IsEnabled, [Order], Description, CustomerCodeSourceRuleId,
                                           CustomerAccountCodeSourceRuleId, StateId, StateMaker, StateDate)
            VALUES (@lastAccAccountMapId, null, null, null, null, @dynamicRuleReceiveLocalCurrencyId,
                    @dynamicRuleDerivativePortfolioTradeId, null, null, null, null, null, null,
                    N'MatRecContingentOffset', N'TREX/DV/CCS', N'966', N'96610000', null, 1, @lastAccAccountMapOrderNo,
                    N'', null, null, @stateId, @stateMaker, @stateDate);

            select @lastAccAccountMapId = @lastAccAccountMapId + 1
            select @lastAccAccountMapOrderNo = @lastAccAccountMapOrderNo + 10
        END

    --#endregion
    ------------------------------------------------------------------------------------------------------------------------
    -- MatRecPrincipal
    ------------------------------------------------------------------------------------------------------------------------
--#region MatRecPrincipal

    IF NOT EXISTS(select 1
                  from dbo.AccAccountMap
                  where Path = N'TREX/DV/CCS'
                    and Source = N'MatRecPrincipal'
                    and Target = N'39300800')
        BEGIN
            INSERT INTO dbo.AccAccountMap (Id, Ccy, CustomerId, RuleId, Rule2Id, Rule3Id, Rule4Id, Rule5Id, Rule6Id,
                                           Rule7Id, Rule8Id, Rule9Id, Rule10Id, Source, Path, TargetMainGL, Target,
                                           TargetRuleId, IsEnabled, [Order], Description, CustomerCodeSourceRuleId,
                                           CustomerAccountCodeSourceRuleId, StateId, StateMaker, StateDate)
            VALUES (@lastAccAccountMapId, null, null, null, null, @dynamicRuleReceiveForeignCurrencyId,
                    @dynamicRuleDerivativePortfolioTradeId, null, null, null, null, null, null, N'MatRecPrincipal',
                    N'TREX/DV/CCS', N'393', N'39300800', null, 1, @lastAccAccountMapOrderNo, N'', null, null, @stateId,
                    @stateMaker, @stateDate);

            select @lastAccAccountMapId = @lastAccAccountMapId + 1
            select @lastAccAccountMapOrderNo = @lastAccAccountMapOrderNo + 10
        END

    IF NOT EXISTS(select 1
                  from dbo.AccAccountMap
                  where Path = N'TREX/DV/CCS'
                    and Source = N'MatRecPrincipal'
                    and Target = N'39200800')
        BEGIN
            INSERT INTO dbo.AccAccountMap (Id, Ccy, CustomerId, RuleId, Rule2Id, Rule3Id, Rule4Id, Rule5Id, Rule6Id,
                                           Rule7Id, Rule8Id, Rule9Id, Rule10Id, Source, Path, TargetMainGL, Target,
                                           TargetRuleId, IsEnabled, [Order], Description, CustomerCodeSourceRuleId,
                                           CustomerAccountCodeSourceRuleId, StateId, StateMaker, StateDate)
            VALUES (@lastAccAccountMapId, null, null, null, null, @dynamicRuleReceiveLocalCurrencyId,
                    @dynamicRuleDerivativePortfolioTradeId, null, null, null, null, null, null, N'MatRecPrincipal',
                    N'TREX/DV/CCS', N'392', N'39200800', null, 1, @lastAccAccountMapOrderNo, N'', null, null, @stateId,
                    @stateMaker, @stateDate);

            select @lastAccAccountMapId = @lastAccAccountMapId + 1
            select @lastAccAccountMapOrderNo = @lastAccAccountMapOrderNo + 10
        END
--#endregion

    IF NOT EXISTS(select 1
                  from dbo.AccAccountMap
                  where Path = N'TREX/DV/CCS'
                    and Source = N'OutgoingPaymentFCY'
                    and Target = N'39300800')
        BEGIN
            INSERT INTO dbo.AccAccountMap (Id, Ccy, CustomerId, RuleId, Rule2Id, Rule3Id, Rule4Id, Rule5Id, Rule6Id,
                                           Rule7Id, Rule8Id, Rule9Id, Rule10Id, Source, Path, TargetMainGL, Target,
                                           TargetRuleId, IsEnabled, [Order], Description, CustomerCodeSourceRuleId,
                                           CustomerAccountCodeSourceRuleId, StateId, StateMaker, StateDate)
            VALUES (@lastAccAccountMapId, null, null, null, null, @dynamicRulePayForeignCurrencyId,
                    @dynamicRuleDerivativePortfolioTradeId, null, null, null, null, null, null, N'OutgoingPaymentFCY',
                    N'TREX/DV/CCS', N'393', N'39300800', null, 1, @lastAccAccountMapOrderNo, N'', null, null, @stateId,
                    @stateMaker, @stateDate);

            select @lastAccAccountMapId = @lastAccAccountMapId + 1
            select @lastAccAccountMapOrderNo = @lastAccAccountMapOrderNo + 10
        END

    IF NOT EXISTS(select 1
                  from dbo.AccAccountMap
                  where Path = N'TREX/DV/CCS'
                    and Source = N'OutgoingPaymentLCY'
                    and Target = N'39200800')
        BEGIN
            INSERT INTO dbo.AccAccountMap (Id, Ccy, CustomerId, RuleId, Rule2Id, Rule3Id, Rule4Id, Rule5Id, Rule6Id,
                                           Rule7Id, Rule8Id, Rule9Id, Rule10Id, Source, Path, TargetMainGL, Target,
                                           TargetRuleId, IsEnabled, [Order], Description, CustomerCodeSourceRuleId,
                                           CustomerAccountCodeSourceRuleId, StateId, StateMaker, StateDate)
            VALUES (@lastAccAccountMapId, null, null, null, null, @dynamicRulePayLocalCurrencyId,
                    @dynamicRuleDerivativePortfolioTradeId, null, null, null, null, null, null, N'OutgoingPaymentLCY',
                    N'TREX/DV/CCS', N'392', N'39200800', null, 1, @lastAccAccountMapOrderNo, N'', null, null, @stateId,
                    @stateMaker, @stateDate);

            select @lastAccAccountMapId = @lastAccAccountMapId + 1
            select @lastAccAccountMapOrderNo = @lastAccAccountMapOrderNo + 10
        END

    IF NOT EXISTS(select 1
                  from dbo.AccAccountMap
                  where Path = N'TREX/DV/CCS'
                    and Source = N'TotalMTMLoss'
                    and Target = N'36500200')
        BEGIN
            INSERT INTO dbo.AccAccountMap (Id, Ccy, CustomerId, RuleId, Rule2Id, Rule3Id, Rule4Id, Rule5Id, Rule6Id,
                                           Rule7Id, Rule8Id, Rule9Id, Rule10Id, Source, Path, TargetMainGL, Target,
                                           TargetRuleId, IsEnabled, [Order], Description, CustomerCodeSourceRuleId,
                                           CustomerAccountCodeSourceRuleId, StateId, StateMaker, StateDate)
            VALUES (@lastAccAccountMapId, null, null, null, null, @dynamicRuleMtmAmountCCYEqualForeignCurrencyId,
                    @dynamicRuleDerivativePortfolioTradeId, null,
                    null, null, null, null, null, N'TotalMTMLoss', N'TREX/DV/CCS', N'365', N'36500200', null, 1,
                    @lastAccAccountMapOrderNo, N'', null, null, @stateId, @stateMaker, @stateDate);

            select @lastAccAccountMapId = @lastAccAccountMapId + 1
            select @lastAccAccountMapOrderNo = @lastAccAccountMapOrderNo + 10
        END

    IF NOT EXISTS(select 1
                  from dbo.AccAccountMap
                  where Path = N'TREX/DV/CCS'
                    and Source = N'TotalMTMLoss'
                    and Target = N'36400200')
        BEGIN
            INSERT INTO dbo.AccAccountMap (Id, Ccy, CustomerId, RuleId, Rule2Id, Rule3Id, Rule4Id, Rule5Id, Rule6Id,
                                           Rule7Id, Rule8Id, Rule9Id, Rule10Id, Source, Path, TargetMainGL, Target,
                                           TargetRuleId, IsEnabled, [Order], Description, CustomerCodeSourceRuleId,
                                           CustomerAccountCodeSourceRuleId, StateId, StateMaker, StateDate)
            VALUES (@lastAccAccountMapId, null, null, null, null, @dynamicRuleMtmAmountCCYEqualLocalCurrencyId,
                    @dynamicRuleDerivativePortfolioTradeId, null,
                    null, null, null, null, null, N'TotalMTMLoss', N'TREX/DV/CCS', N'364', N'36400200', null, 1,
                    @lastAccAccountMapOrderNo, N'', null, null, @stateId, @stateMaker, @stateDate);

            select @lastAccAccountMapId = @lastAccAccountMapId + 1
            select @lastAccAccountMapOrderNo = @lastAccAccountMapOrderNo + 10
        END

    IF NOT EXISTS(select 1
                  from dbo.AccAccountMap
                  where Path = N'TREX/DV/CCS'
                    and Source = N'TotalMTMProfit'
                    and Target = N'22500200')
        BEGIN
            INSERT INTO dbo.AccAccountMap (Id, Ccy, CustomerId, RuleId, Rule2Id, Rule3Id, Rule4Id, Rule5Id, Rule6Id,
                                           Rule7Id, Rule8Id, Rule9Id, Rule10Id, Source, Path, TargetMainGL, Target,
                                           TargetRuleId, IsEnabled, [Order], Description, CustomerCodeSourceRuleId,
                                           CustomerAccountCodeSourceRuleId, StateId, StateMaker, StateDate)
            VALUES (@lastAccAccountMapId, null, null, null, null, @dynamicRuleMtmAmountCCYEqualForeignCurrencyId,
                    @dynamicRuleDerivativePortfolioTradeId, null, null, null, null, null, null,
                    N'TotalMTMProfit', N'TREX/DV/CCS', N'225', N'22500200', null, 1, @lastAccAccountMapOrderNo, N'',
                    null, null, @stateId, @stateMaker, @stateDate);

            select @lastAccAccountMapId = @lastAccAccountMapId + 1
            select @lastAccAccountMapOrderNo = @lastAccAccountMapOrderNo + 10
        END

    IF NOT EXISTS(select 1
                  from dbo.AccAccountMap
                  where Path = N'TREX/DV/CCS'
                    and Source = N'TotalMTMProfit'
                    and Target = N'22400200')
        BEGIN
            INSERT INTO dbo.AccAccountMap (Id, Ccy, CustomerId, RuleId, Rule2Id, Rule3Id, Rule4Id, Rule5Id, Rule6Id,
                                           Rule7Id, Rule8Id, Rule9Id, Rule10Id, Source, Path, TargetMainGL, Target,
                                           TargetRuleId, IsEnabled, [Order], Description, CustomerCodeSourceRuleId,
                                           CustomerAccountCodeSourceRuleId, StateId, StateMaker, StateDate)
            VALUES (@lastAccAccountMapId, null, null, null, null, @dynamicRuleMtmAmountCCYEqualLocalCurrencyId,
                    @dynamicRuleDerivativePortfolioTradeId, null,
                    null, null, null, null, null, N'TotalMTMProfit', N'TREX/DV/CCS', N'224', N'22400200', null, 1,
                    @lastAccAccountMapOrderNo, N'', null, null, @stateId, @stateMaker, @stateDate);

            select @lastAccAccountMapId = @lastAccAccountMapId + 1
            select @lastAccAccountMapOrderNo = @lastAccAccountMapOrderNo + 10
        END

    ------------------------------------------------------------------------------------------------------------------------
    -- ValPayContingent
    ------------------------------------------------------------------------------------------------------------------------
--#region ValPayContingent

    IF NOT EXISTS(select 1
                  from dbo.AccAccountMap
                  where Path = N'TREX/DV/CCS'
                    and Source = N'ValPayContingent'
                    and Target = N'96510100')
        BEGIN
            INSERT INTO dbo.AccAccountMap (Id, Ccy, CustomerId, RuleId, Rule2Id, Rule3Id, Rule4Id, Rule5Id, Rule6Id,
                                           Rule7Id, Rule8Id, Rule9Id, Rule10Id, Source, Path, TargetMainGL, Target,
                                           TargetRuleId, IsEnabled, [Order], Description, CustomerCodeSourceRuleId,
                                           CustomerAccountCodeSourceRuleId, StateId, StateMaker, StateDate)
            VALUES (@lastAccAccountMapId, null, null, null, null, @dynamicRulePayForeignCurrencyId,
                    @dynamicRuleDerivativePortfolioTradeId, @dynamicRuleReceiveForeignCurrencyId, null, null, null,
                    null, null, N'ValPayContingent',
                    N'TREX/DV/CCS', N'965', N'96510100', null, 1, @lastAccAccountMapOrderNo, N'', null, null, @stateId,
                    @stateMaker, @stateDate);

            select @lastAccAccountMapId = @lastAccAccountMapId + 1
            select @lastAccAccountMapOrderNo = @lastAccAccountMapOrderNo + 10
        END

    IF NOT EXISTS(select 1
                  from dbo.AccAccountMap
                  where Path = N'TREX/DV/CCS'
                    and Source = N'ValPayContingent'
                    and Target = N'96510000')
        BEGIN
            INSERT INTO dbo.AccAccountMap (Id, Ccy, CustomerId, RuleId, Rule2Id, Rule3Id, Rule4Id, Rule5Id, Rule6Id,
                                           Rule7Id, Rule8Id, Rule9Id, Rule10Id, Source, Path, TargetMainGL, Target,
                                           TargetRuleId, IsEnabled, [Order], Description, CustomerCodeSourceRuleId,
                                           CustomerAccountCodeSourceRuleId, StateId, StateMaker, StateDate)
            VALUES (@lastAccAccountMapId, null, null, null, null, @dynamicRulePayForeignCurrencyId,
                    @dynamicRuleDerivativePortfolioTradeId, @dynamicRuleReceiveLocalCurrencyId, null, null, null, null,
                    null, N'ValPayContingent',
                    N'TREX/DV/CCS', N'965', N'96510000', null, 1, @lastAccAccountMapOrderNo, N'', null, null, @stateId,
                    @stateMaker, @stateDate);

            select @lastAccAccountMapId = @lastAccAccountMapId + 1
            select @lastAccAccountMapOrderNo = @lastAccAccountMapOrderNo + 10
        END

    IF NOT EXISTS(select 1
                  from dbo.AccAccountMap
                  where Path = N'TREX/DV/CCS'
                    and Source = N'ValPayContingent'
                    and Target = N'96410000')
        BEGIN
            INSERT INTO dbo.AccAccountMap (Id, Ccy, CustomerId, RuleId, Rule2Id, Rule3Id, Rule4Id, Rule5Id, Rule6Id,
                                           Rule7Id, Rule8Id, Rule9Id, Rule10Id, Source, Path, TargetMainGL, Target,
                                           TargetRuleId, IsEnabled, [Order], Description, CustomerCodeSourceRuleId,
                                           CustomerAccountCodeSourceRuleId, StateId, StateMaker, StateDate)
            VALUES (@lastAccAccountMapId, null, null, null, null, @dynamicRulePayLocalCurrencyId,
                    @dynamicRuleDerivativePortfolioTradeId, null, null, null, null, null, null, N'ValPayContingent',
                    N'TREX/DV/CCS', N'964', N'96410000', null, 1, @lastAccAccountMapOrderNo, N'', null, null, @stateId,
                    @stateMaker, @stateDate);

            select @lastAccAccountMapId = @lastAccAccountMapId + 1
            select @lastAccAccountMapOrderNo = @lastAccAccountMapOrderNo + 10
        END

    --#endregion
    ------------------------------------------------------------------------------------------------------------------------
    -- ValPayContingentOffset
    ------------------------------------------------------------------------------------------------------------------------
--#region ValPayContingentOffset

    IF NOT EXISTS(select 1
                  from dbo.AccAccountMap
                  where Path = N'TREX/DV/CCS'
                    and Source = N'ValPayContingentOffset'
                    and Target = N'96710100')
        BEGIN
            INSERT INTO dbo.AccAccountMap (Id, Ccy, CustomerId, RuleId, Rule2Id, Rule3Id, Rule4Id, Rule5Id, Rule6Id,
                                           Rule7Id, Rule8Id, Rule9Id, Rule10Id, Source, Path, TargetMainGL, Target,
                                           TargetRuleId, IsEnabled, [Order], Description, CustomerCodeSourceRuleId,
                                           CustomerAccountCodeSourceRuleId, StateId, StateMaker, StateDate)
            VALUES (@lastAccAccountMapId, null, null, null, null, @dynamicRulePayForeignCurrencyId,
                    @dynamicRuleDerivativePortfolioTradeId, @dynamicRuleReceiveForeignCurrencyId, null, null, null,
                    null, null,
                    N'ValPayContingentOffset', N'TREX/DV/CCS', N'967', N'96710100', null, 1, @lastAccAccountMapOrderNo,
                    N'', null, null, @stateId, @stateMaker, @stateDate);

            select @lastAccAccountMapId = @lastAccAccountMapId + 1
            select @lastAccAccountMapOrderNo = @lastAccAccountMapOrderNo + 10
        END

    IF NOT EXISTS(select 1
                  from dbo.AccAccountMap
                  where Path = N'TREX/DV/CCS'
                    and Source = N'ValPayContingentOffset'
                    and Target = N'96610000')
        BEGIN
            INSERT INTO dbo.AccAccountMap (Id, Ccy, CustomerId, RuleId, Rule2Id, Rule3Id, Rule4Id, Rule5Id, Rule6Id,
                                           Rule7Id, Rule8Id, Rule9Id, Rule10Id, Source, Path, TargetMainGL, Target,
                                           TargetRuleId, IsEnabled, [Order], Description, CustomerCodeSourceRuleId,
                                           CustomerAccountCodeSourceRuleId, StateId, StateMaker, StateDate)
            VALUES (@lastAccAccountMapId, null, null, null, null, @dynamicRulePayLocalCurrencyId,
                    @dynamicRuleDerivativePortfolioTradeId, null, null, null, null, null, null,
                    N'ValPayContingentOffset', N'TREX/DV/CCS', N'966', N'96610000', null, 1, @lastAccAccountMapOrderNo,
                    N'', null, null, @stateId, @stateMaker, @stateDate);

            select @lastAccAccountMapId = @lastAccAccountMapId + 1
            select @lastAccAccountMapOrderNo = @lastAccAccountMapOrderNo + 10
        END

    IF NOT EXISTS(select 1
                  from dbo.AccAccountMap
                  where Path = N'TREX/DV/CCS'
                    and Source = N'ValPayContingentOffset'
                    and Target = N'96710000')
        BEGIN
            INSERT INTO dbo.AccAccountMap (Id, Ccy, CustomerId, RuleId, Rule2Id, Rule3Id, Rule4Id, Rule5Id, Rule6Id,
                                           Rule7Id, Rule8Id, Rule9Id, Rule10Id, Source, Path, TargetMainGL, Target,
                                           TargetRuleId, IsEnabled, [Order], Description, CustomerCodeSourceRuleId,
                                           CustomerAccountCodeSourceRuleId, StateId, StateMaker, StateDate)
            VALUES (@lastAccAccountMapId, null, null, null, null, @dynamicRulePayForeignCurrencyId,
                    @dynamicRuleDerivativePortfolioTradeId, @dynamicRuleReceiveLocalCurrencyId, null, null, null, null,
                    null,
                    N'ValPayContingentOffset', N'TREX/DV/CCS', N'967', N'96710000', null, 1, @lastAccAccountMapOrderNo,
                    N'', null, null, @stateId, @stateMaker, @stateDate);

            select @lastAccAccountMapId = @lastAccAccountMapId + 1
            select @lastAccAccountMapOrderNo = @lastAccAccountMapOrderNo + 10
        END

    --#endregion
    ------------------------------------------------------------------------------------------------------------------------
    -- ValPayPrincipal
    ------------------------------------------------------------------------------------------------------------------------
--#region ValPayPrincipal

    IF NOT EXISTS(select 1
                  from dbo.AccAccountMap
                  where Path = N'TREX/DV/CCS'
                    and Source = N'ValPayPrincipal'
                    and Target = N'39200800')
        BEGIN
            INSERT INTO dbo.AccAccountMap (Id, Ccy, CustomerId, RuleId, Rule2Id, Rule3Id, Rule4Id, Rule5Id, Rule6Id,
                                           Rule7Id, Rule8Id, Rule9Id, Rule10Id, Source, Path, TargetMainGL, Target,
                                           TargetRuleId, IsEnabled, [Order], Description, CustomerCodeSourceRuleId,
                                           CustomerAccountCodeSourceRuleId, StateId, StateMaker, StateDate)
            VALUES (@lastAccAccountMapId, null, null, null, null, @dynamicRulePayLocalCurrencyId,
                    @dynamicRuleDerivativePortfolioTradeId, null, null, null, null, null, null, N'ValPayPrincipal',
                    N'TREX/DV/CCS', N'392', N'39200800', null, 1, @lastAccAccountMapOrderNo, N'', null, null, @stateId,
                    @stateMaker, @stateDate);

            select @lastAccAccountMapId = @lastAccAccountMapId + 1
            select @lastAccAccountMapOrderNo = @lastAccAccountMapOrderNo + 10
        END

    IF NOT EXISTS(select 1
                  from dbo.AccAccountMap
                  where Path = N'TREX/DV/CCS'
                    and Source = N'ValPayPrincipal'
                    and Target = N'39300800')
        BEGIN
            INSERT INTO dbo.AccAccountMap (Id, Ccy, CustomerId, RuleId, Rule2Id, Rule3Id, Rule4Id, Rule5Id, Rule6Id,
                                           Rule7Id, Rule8Id, Rule9Id, Rule10Id, Source, Path, TargetMainGL, Target,
                                           TargetRuleId, IsEnabled, [Order], Description, CustomerCodeSourceRuleId,
                                           CustomerAccountCodeSourceRuleId, StateId, StateMaker, StateDate)
            VALUES (@lastAccAccountMapId, null, null, null, null, @dynamicRulePayForeignCurrencyId,
                    @dynamicRuleDerivativePortfolioTradeId, null, null, null, null, null, null, N'ValPayPrincipal',
                    N'TREX/DV/CCS', N'393', N'39300800', null, 1, @lastAccAccountMapOrderNo, N'', null, null, @stateId,
                    @stateMaker, @stateDate);

            select @lastAccAccountMapId = @lastAccAccountMapId + 1
            select @lastAccAccountMapOrderNo = @lastAccAccountMapOrderNo + 10
        END

    --#endregion
    ------------------------------------------------------------------------------------------------------------------------
    -- ValRecContingent
    ------------------------------------------------------------------------------------------------------------------------
--#region ValRecContingent

    IF NOT EXISTS(select 1
                  from dbo.AccAccountMap
                  where Path = N'TREX/DV/CCS'
                    and Source = N'ValRecContingent'
                    and Target = N'96710300')
        BEGIN
            INSERT INTO dbo.AccAccountMap (Id, Ccy, CustomerId, RuleId, Rule2Id, Rule3Id, Rule4Id, Rule5Id, Rule6Id,
                                           Rule7Id, Rule8Id, Rule9Id, Rule10Id, Source, Path, TargetMainGL, Target,
                                           TargetRuleId, IsEnabled, [Order], Description, CustomerCodeSourceRuleId,
                                           CustomerAccountCodeSourceRuleId, StateId, StateMaker, StateDate)
            VALUES (@lastAccAccountMapId, null, null, null, null, @dynamicRuleReceiveForeignCurrencyId,
                    @dynamicRuleDerivativePortfolioTradeId, @dynamicRulePayForeignCurrencyId, null, null, null, null,
                    null, N'ValRecContingent',
                    N'TREX/DV/CCS', N'967', N'96710300', null, 1, @lastAccAccountMapOrderNo, N'', null, null, @stateId,
                    @stateMaker, @stateDate);

            select @lastAccAccountMapId = @lastAccAccountMapId + 1
            select @lastAccAccountMapOrderNo = @lastAccAccountMapOrderNo + 10
        END

    IF NOT EXISTS(select 1
                  from dbo.AccAccountMap
                  where Path = N'TREX/DV/CCS'
                    and Source = N'ValRecContingent'
                    and Target = N'96710200')
        BEGIN
            INSERT INTO dbo.AccAccountMap (Id, Ccy, CustomerId, RuleId, Rule2Id, Rule3Id, Rule4Id, Rule5Id, Rule6Id,
                                           Rule7Id, Rule8Id, Rule9Id, Rule10Id, Source, Path, TargetMainGL, Target,
                                           TargetRuleId, IsEnabled, [Order], Description, CustomerCodeSourceRuleId,
                                           CustomerAccountCodeSourceRuleId, StateId, StateMaker, StateDate)
            VALUES (@lastAccAccountMapId, null, null, null, null, @dynamicRuleReceiveForeignCurrencyId,
                    @dynamicRuleDerivativePortfolioTradeId, @dynamicRulePayLocalCurrencyId, null, null, null, null,
                    null, N'ValRecContingent',
                    N'TREX/DV/CCS', N'967', N'96710200', null, 1, @lastAccAccountMapOrderNo, N'', null, null, @stateId,
                    @stateMaker, @stateDate);

            select @lastAccAccountMapId = @lastAccAccountMapId + 1
            select @lastAccAccountMapOrderNo = @lastAccAccountMapOrderNo + 10
        END

    IF NOT EXISTS(select 1
                  from dbo.AccAccountMap
                  where Path = N'TREX/DV/CCS'
                    and Source = N'ValRecContingent'
                    and Target = N'96610100')
        BEGIN
            INSERT INTO dbo.AccAccountMap (Id, Ccy, CustomerId, RuleId, Rule2Id, Rule3Id, Rule4Id, Rule5Id, Rule6Id,
                                           Rule7Id, Rule8Id, Rule9Id, Rule10Id, Source, Path, TargetMainGL, Target,
                                           TargetRuleId, IsEnabled, [Order], Description, CustomerCodeSourceRuleId,
                                           CustomerAccountCodeSourceRuleId, StateId, StateMaker, StateDate)
            VALUES (@lastAccAccountMapId, null, null, null, null, @dynamicRuleReceiveLocalCurrencyId,
                    @dynamicRuleDerivativePortfolioTradeId, null, null, null, null, null, null, N'ValRecContingent',
                    N'TREX/DV/CCS', N'966', N'96610100', null, 1, @lastAccAccountMapOrderNo, N'', null, null, @stateId,
                    @stateMaker, @stateDate);

            select @lastAccAccountMapId = @lastAccAccountMapId + 1
            select @lastAccAccountMapOrderNo = @lastAccAccountMapOrderNo + 10
        END

    --#endregion
    ------------------------------------------------------------------------------------------------------------------------
    -- ValRecContingentOffset
    ------------------------------------------------------------------------------------------------------------------------
--#region ValRecContingentOffset

    IF NOT EXISTS(select 1
                  from dbo.AccAccountMap
                  where Path = N'TREX/DV/CCS'
                    and Source = N'ValRecContingentOffset'
                    and Target = N'96510300')
        BEGIN
            INSERT INTO dbo.AccAccountMap (Id, Ccy, CustomerId, RuleId, Rule2Id, Rule3Id, Rule4Id, Rule5Id, Rule6Id,
                                           Rule7Id, Rule8Id, Rule9Id, Rule10Id, Source, Path, TargetMainGL, Target,
                                           TargetRuleId, IsEnabled, [Order], Description, CustomerCodeSourceRuleId,
                                           CustomerAccountCodeSourceRuleId, StateId, StateMaker, StateDate)
            VALUES (@lastAccAccountMapId, null, null, null, null, @dynamicRuleReceiveForeignCurrencyId,
                    @dynamicRuleDerivativePortfolioTradeId, @dynamicRulePayForeignCurrencyId, null, null, null, null,
                    null,
                    N'ValRecContingentOffset', N'TREX/DV/CCS', N'965', N'96510300', null, 1, @lastAccAccountMapOrderNo,
                    N'', null, null, @stateId, @stateMaker, @stateDate);

            select @lastAccAccountMapId = @lastAccAccountMapId + 1
            select @lastAccAccountMapOrderNo = @lastAccAccountMapOrderNo + 10
        END

    IF NOT EXISTS(select 1
                  from dbo.AccAccountMap
                  where Path = N'TREX/DV/CCS'
                    and Source = N'ValRecContingentOffset'
                    and Target = N'96510200')
        BEGIN
            INSERT INTO dbo.AccAccountMap (Id, Ccy, CustomerId, RuleId, Rule2Id, Rule3Id, Rule4Id, Rule5Id, Rule6Id,
                                           Rule7Id, Rule8Id, Rule9Id, Rule10Id, Source, Path, TargetMainGL, Target,
                                           TargetRuleId, IsEnabled, [Order], Description, CustomerCodeSourceRuleId,
                                           CustomerAccountCodeSourceRuleId, StateId, StateMaker, StateDate)
            VALUES (@lastAccAccountMapId, null, null, null, null, @dynamicRuleReceiveForeignCurrencyId,
                    @dynamicRuleDerivativePortfolioTradeId, @dynamicRulePayLocalCurrencyId, null, null, null, null,
                    null,
                    N'ValRecContingentOffset', N'TREX/DV/CCS', N'965', N'96510200', null, 1, @lastAccAccountMapOrderNo,
                    N'', null, null, @stateId, @stateMaker, @stateDate);

            select @lastAccAccountMapId = @lastAccAccountMapId + 1
            select @lastAccAccountMapOrderNo = @lastAccAccountMapOrderNo + 10
        END

    IF NOT EXISTS(select 1
                  from dbo.AccAccountMap
                  where Path = N'TREX/DV/CCS'
                    and Source = N'ValRecContingentOffset'
                    and Target = N'96410100')
        BEGIN
            INSERT INTO dbo.AccAccountMap (Id, Ccy, CustomerId, RuleId, Rule2Id, Rule3Id, Rule4Id, Rule5Id, Rule6Id,
                                           Rule7Id, Rule8Id, Rule9Id, Rule10Id, Source, Path, TargetMainGL, Target,
                                           TargetRuleId, IsEnabled, [Order], Description, CustomerCodeSourceRuleId,
                                           CustomerAccountCodeSourceRuleId, StateId, StateMaker, StateDate)
            VALUES (@lastAccAccountMapId, null, null, null, null, @dynamicRuleReceiveLocalCurrencyId,
                    @dynamicRuleDerivativePortfolioTradeId, null, null, null, null, null, null,
                    N'ValRecContingentOffset', N'TREX/DV/CCS', N'964', N'96410100', null, 1, @lastAccAccountMapOrderNo,
                    N'', null, null, @stateId, @stateMaker, @stateDate);

            select @lastAccAccountMapId = @lastAccAccountMapId + 1
            select @lastAccAccountMapOrderNo = @lastAccAccountMapOrderNo + 10
        END

    --#endregion
    ------------------------------------------------------------------------------------------------------------------------
    -- ValRecPrincipal
    ------------------------------------------------------------------------------------------------------------------------
--#region ValRecPrincipal
    IF NOT EXISTS(select 1
                  from dbo.AccAccountMap
                  where Path = N'TREX/DV/CCS'
                    and Source = N'ValRecPrincipal'
                    and Target = N'39300800')
        BEGIN
            INSERT INTO dbo.AccAccountMap (Id, Ccy, CustomerId, RuleId, Rule2Id, Rule3Id, Rule4Id, Rule5Id, Rule6Id,
                                           Rule7Id, Rule8Id, Rule9Id, Rule10Id, Source, Path, TargetMainGL, Target,
                                           TargetRuleId, IsEnabled, [Order], Description, CustomerCodeSourceRuleId,
                                           CustomerAccountCodeSourceRuleId, StateId, StateMaker, StateDate)
            VALUES (@lastAccAccountMapId, null, null, null, null, @dynamicRuleReceiveForeignCurrencyId,
                    @dynamicRuleDerivativePortfolioTradeId, null, null, null, null, null, null, N'ValRecPrincipal',
                    N'TREX/DV/CCS', N'393', N'39300800', null, 1, @lastAccAccountMapOrderNo, N'', null, null, @stateId,
                    @stateMaker, @stateDate);

            select @lastAccAccountMapId = @lastAccAccountMapId + 1
            select @lastAccAccountMapOrderNo = @lastAccAccountMapOrderNo + 10
        END

    IF NOT EXISTS(select 1
                  from dbo.AccAccountMap
                  where Path = N'TREX/DV/CCS'
                    and Source = N'ValRecPrincipal'
                    and Target = N'39200800')
        BEGIN
            INSERT INTO dbo.AccAccountMap (Id, Ccy, CustomerId, RuleId, Rule2Id, Rule3Id, Rule4Id, Rule5Id, Rule6Id,
                                           Rule7Id, Rule8Id, Rule9Id, Rule10Id, Source, Path, TargetMainGL, Target,
                                           TargetRuleId, IsEnabled, [Order], Description, CustomerCodeSourceRuleId,
                                           CustomerAccountCodeSourceRuleId, StateId, StateMaker, StateDate)
            VALUES (@lastAccAccountMapId, null, null, null, null, @dynamicRuleReceiveLocalCurrencyId,
                    @dynamicRuleDerivativePortfolioTradeId, null, null, null, null, null, null, N'ValRecPrincipal',
                    N'TREX/DV/CCS', N'392', N'39200800', null, 1, @lastAccAccountMapOrderNo, N'', null, null, @stateId,
                    @stateMaker, @stateDate);
        END
    --#endregion

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
            VALUES (@lastAccEngineItemId, N'DV', 0, N'TREX/DV/', null, @StateId, @stateDate, @stateMaker, 1);
            select @lastAccEngineItemId = @lastAccEngineItemId + 1
        end
    if not exists(select 1
                  from dbo.accEngineItem
                  where Path = N'TREX/DV/CCS/')
        begin
            select @number = Id from dbo.accEngineItem where Path = N'TREX/DV/'
            INSERT INTO dbo.AccEngineItem (Id, ItemCode, ParentId, Path, ModelDefinitionId, StateId, StateDate,
                                           StateMaker,
                                           TemplateId)
            VALUES (@lastAccEngineItemId, N'CCS', @number, N'TREX/DV/CCS/', null, @StateId, @stateDate, @stateMaker, 1);
            select @lastAccEngineItemId = @lastAccEngineItemId + 1
        end
    if not exists(select 1
                  from dbo.accEngineItem
                  where Path = N'TREX/DV/CCS/LCYRFCYP/')
        begin
            select @number = Id from dbo.accEngineItem where Path = N'TREX/DV/CCS/'
            INSERT INTO dbo.AccEngineItem (Id, ItemCode, ParentId, Path, ModelDefinitionId, StateId, StateDate,
                                           StateMaker,
                                           TemplateId)
            output inserted.Id into @tempTable
            VALUES (@lastAccEngineItemId, N'LCYRFCYP', @number, N'TREX/DV/CCS/LCYRFCYP/',
                    @lastAccEngineModelDefinitionId,
                    @StateId, @stateDate,
                    @stateMaker, 1);
            SELECT @lcyRFcyPItemId = Id FROM @tempTable;
            delete from @tempTable
            select @lastAccEngineItemId = @lastAccEngineItemId + 1
        end
    else
        begin
            select @lcyRFcyPItemId = Id from dbo.AccEngineItem where Path = N'TREX/DV/CCS/LCYRFCYP/'
        end
    if not exists(select 1
                  from dbo.accEngineItem
                  where Path = N'TREX/DV/CCS/FCYRLCYP/')
        begin
            select @number = Id from dbo.accEngineItem where Path = N'TREX/DV/CCS/'
            INSERT INTO dbo.AccEngineItem (Id, ItemCode, ParentId, Path, ModelDefinitionId, StateId, StateDate,
                                           StateMaker,
                                           TemplateId)
            output inserted.Id into @tempTable
            VALUES (@lastAccEngineItemId, N'FCYRLCYP', @number, N'TREX/DV/CCS/FCYRLCYP/',
                    @lastAccEngineModelDefinitionId,
                    @StateId, @stateDate,
                    @stateMaker, 1);
            SELECT @fcyRLcyPItemId = Id FROM @tempTable;
            delete from @tempTable
            select @lastAccEngineItemId = @lastAccEngineItemId + 1
        end
    else
        begin
            select @fcyRLcyPItemId = Id from dbo.AccEngineItem where Path = N'TREX/DV/CCS/FCYRLCYP/'
        end
    if not exists(select 1
                  from dbo.accEngineItem
                  where Path = N'TREX/DV/CCS/FCYRFCYP/')
        begin
            select @number = Id from dbo.accEngineItem where Path = N'TREX/DV/CCS/'
            INSERT INTO dbo.AccEngineItem (Id, ItemCode, ParentId, Path, ModelDefinitionId, StateId, StateDate,
                                           StateMaker,
                                           TemplateId)
            output inserted.Id into @tempTable
            VALUES (@lastAccEngineItemId, N'FCYRFCYP', @number, N'TREX/DV/CCS/FCYRFCYP/',
                    @lastAccEngineModelDefinitionId,
                    @StateId, @stateDate,
                    @stateMaker, 1);
            SELECT @fcyRfcyPItemId = Id FROM @tempTable;
            delete from @tempTable
        end
    else
        begin
            select @fcyRFcyPItemId = Id from dbo.AccEngineItem where Path = N'TREX/DV/CCS/FCYRFCYP/'
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
    -- Acc Engine Event LCYRFCYP
    ------------------------------------------------------------------------------------------------------------------------
    if not exists(select 1
                  from dbo.accEngineEvent
                  where ItemId = @lcyRFcyPItemId
                    and EventTypeCode = N'OnOpening')
        begin
            INSERT INTO dbo.AccEngineEvent (Id, ItemId, EventTypeCode, ModifiedBy, ModifiedDate,
                                            EventDescriptionDynamicRuleId)
            output inserted.Id into @tempTable
            VALUES (@lastAccEngineEventId, @lcyRFcyPItemId, N'OnOpening', @stateMaker, @stateDate, null);
            SELECT @lcyRFcyPOpeningEventId = Id FROM @tempTable;
            delete from @tempTable
            select @lastAccEngineEventId = @lastAccEngineEventId + 1
        end
    else
        begin
            select @lcyRFcyPOpeningEventId = Id
            from dbo.AccEngineEvent
            where ItemId = @lcyRFcyPItemId
              and EventTypeCode = N'OnOpening'
        end
    if not exists(select 1
                  from dbo.accEngineEvent
                  where ItemId = @lcyRFcyPItemId
                    and EventTypeCode = N'OnMaturation')
        begin
            INSERT INTO dbo.AccEngineEvent (Id, ItemId, EventTypeCode, ModifiedBy, ModifiedDate,
                                            EventDescriptionDynamicRuleId)
            output inserted.Id into @tempTable
            VALUES (@lastAccEngineEventId, @lcyRFcyPItemId, N'OnMaturation', @stateMaker, @stateDate, null);
            SELECT @lcyRFcyPMaturationEventId = Id FROM @tempTable;
            delete from @tempTable
            select @lastAccEngineEventId = @lastAccEngineEventId + 1
        end
    else
        begin
            select @lcyRFcyPMaturationEventId = Id
            from dbo.AccEngineEvent
            where ItemId = @lcyRFcyPItemId
              and EventTypeCode = N'OnMaturation'
        end
    if not exists(select 1
                  from dbo.accEngineEvent
                  where ItemId = @lcyRFcyPItemId
                    and EventTypeCode = N'OnPayment')
        begin
            INSERT INTO dbo.AccEngineEvent (Id, ItemId, EventTypeCode, ModifiedBy, ModifiedDate,
                                            EventDescriptionDynamicRuleId)
            output inserted.Id into @tempTable
            VALUES (@lastAccEngineEventId, @lcyRFcyPItemId, N'OnPayment', @stateMaker, @stateDate, null);
            SELECT @lcyRFcyPPaymentEventId = Id FROM @tempTable;
            delete from @tempTable
            select @lastAccEngineEventId = @lastAccEngineEventId + 1
        end
    else
        begin
            select @lcyRFcyPPaymentEventId = Id
            from dbo.AccEngineEvent
            where ItemId = @lcyRFcyPItemId
              and EventTypeCode = N'OnPayment'
        end
    if not exists(select 1
                  from dbo.accEngineEvent
                  where ItemId = @lcyRFcyPItemId
                    and EventTypeCode = N'OnRevaluation')
        begin
            INSERT INTO dbo.AccEngineEvent (Id, ItemId, EventTypeCode, ModifiedBy, ModifiedDate,
                                            EventDescriptionDynamicRuleId)
            output inserted.Id into @tempTable
            VALUES (@lastAccEngineEventId, @lcyRFcyPItemId, N'OnRevaluation', @stateMaker, @stateDate, null);
            SELECT @lcyRFcyPRevaluationEventId = Id FROM @tempTable;
            delete from @tempTable
            select @lastAccEngineEventId = @lastAccEngineEventId + 1
        end
    else
        begin
            select @lcyRFcyPRevaluationEventId = Id
            from dbo.AccEngineEvent
            where ItemId = @lcyRFcyPItemId
              and EventTypeCode = N'OnRevaluation'
        end
    ------------------------------------------------------------------------------------------------------------------------
    -- Acc Engine Event FCYRLCYP
    ------------------------------------------------------------------------------------------------------------------------
    if not exists(select 1
                  from dbo.accEngineEvent
                  where ItemId = @fcyRLcyPItemId
                    and EventTypeCode = N'OnOpening')
        begin
            INSERT INTO dbo.AccEngineEvent (Id, ItemId, EventTypeCode, ModifiedBy, ModifiedDate,
                                            EventDescriptionDynamicRuleId)
            output inserted.Id into @tempTable
            VALUES (@lastAccEngineEventId, @fcyRLcyPItemId, N'OnOpening', @stateMaker, @stateDate, null);
            SELECT @fcyRLcyPOpeningEventId = Id FROM @tempTable;
            delete from @tempTable
            select @lastAccEngineEventId = @lastAccEngineEventId + 1
        end
    else
        begin
            select @fcyRLcyPOpeningEventId = Id
            from dbo.AccEngineEvent
            where ItemId = @fcyRLcyPItemId
              and EventTypeCode = N'OnOpening'
        end
    if not exists(select 1
                  from dbo.accEngineEvent
                  where ItemId = @fcyRLcyPItemId
                    and EventTypeCode = N'OnMaturation')
        begin
            INSERT INTO dbo.AccEngineEvent (Id, ItemId, EventTypeCode, ModifiedBy, ModifiedDate,
                                            EventDescriptionDynamicRuleId)
            output inserted.Id into @tempTable
            VALUES (@lastAccEngineEventId, @fcyRLcyPItemId, N'OnMaturation', @stateMaker, @stateDate, null);
            SELECT @fcyRLcyPMaturationEventId = Id FROM @tempTable;
            delete from @tempTable
            select @lastAccEngineEventId = @lastAccEngineEventId + 1
        end
    else
        begin
            select @fcyRLcyPMaturationEventId = Id
            from dbo.AccEngineEvent
            where ItemId = @fcyRLcyPItemId
              and EventTypeCode = N'OnMaturation'
        end
    if not exists(select 1
                  from dbo.accEngineEvent
                  where ItemId = @fcyRLcyPItemId
                    and EventTypeCode = N'OnPayment')
        begin
            INSERT INTO dbo.AccEngineEvent (Id, ItemId, EventTypeCode, ModifiedBy, ModifiedDate,
                                            EventDescriptionDynamicRuleId)
            output inserted.Id into @tempTable
            VALUES (@lastAccEngineEventId, @fcyRLcyPItemId, N'OnPayment', @stateMaker, @stateDate, null);
            SELECT @fcyRLcyPPaymentEventId = Id FROM @tempTable;
            delete from @tempTable
            select @lastAccEngineEventId = @lastAccEngineEventId + 1
        end
    else
        begin
            select @fcyRLcyPPaymentEventId = Id
            from dbo.AccEngineEvent
            where ItemId = @fcyRLcyPItemId
              and EventTypeCode = N'OnPayment'
        end
    if not exists(select 1
                  from dbo.accEngineEvent
                  where ItemId = @fcyRLcyPItemId
                    and EventTypeCode = N'OnRevaluation')
        begin
            INSERT INTO dbo.AccEngineEvent (Id, ItemId, EventTypeCode, ModifiedBy, ModifiedDate,
                                            EventDescriptionDynamicRuleId)
            output inserted.Id into @tempTable
            VALUES (@lastAccEngineEventId, @fcyRLcyPItemId, N'OnRevaluation', @stateMaker, @stateDate, null);
            SELECT @fcyRLcyPRevaluationEventId = Id FROM @tempTable;
            delete from @tempTable
            select @lastAccEngineEventId = @lastAccEngineEventId + 1
        end
    else
        begin
            select @fcyRLcyPRevaluationEventId = Id
            from dbo.AccEngineEvent
            where ItemId = @fcyRLcyPItemId
              and EventTypeCode = N'OnRevaluation'
        end
    ------------------------------------------------------------------------------------------------------------------------
    -- Acc Engine Event FCYRFCYP
    ------------------------------------------------------------------------------------------------------------------------
    if not exists(select 1
                  from dbo.accEngineEvent
                  where ItemId = @fcyRFcyPItemId
                    and EventTypeCode = N'OnOpening')
        begin
            INSERT INTO dbo.AccEngineEvent (Id, ItemId, EventTypeCode, ModifiedBy, ModifiedDate,
                                            EventDescriptionDynamicRuleId)
            output inserted.Id into @tempTable
            VALUES (@lastAccEngineEventId, @fcyRFcyPItemId, N'OnOpening', @stateMaker, @stateDate, null);
            SELECT @fcyRFcyPOpeningEventId = Id FROM @tempTable;
            delete from @tempTable
            select @lastAccEngineEventId = @lastAccEngineEventId + 1
        end
    else
        begin
            select @fcyRFcyPOpeningEventId = Id
            from dbo.AccEngineEvent
            where ItemId = @fcyRFcyPItemId
              and EventTypeCode = N'OnOpening'
        end
    if not exists(select 1
                  from dbo.accEngineEvent
                  where ItemId = @fcyRFcyPItemId
                    and EventTypeCode = N'OnMaturation')
        begin
            INSERT INTO dbo.AccEngineEvent (Id, ItemId, EventTypeCode, ModifiedBy, ModifiedDate,
                                            EventDescriptionDynamicRuleId)
            output inserted.Id into @tempTable
            VALUES (@lastAccEngineEventId, @fcyRFcyPItemId, N'OnMaturation', @stateMaker, @stateDate, null);
            SELECT @fcyRFcyPMaturationEventId = Id FROM @tempTable;
            delete from @tempTable
            select @lastAccEngineEventId = @lastAccEngineEventId + 1
        end
    else
        begin
            select @fcyRFcyPMaturationEventId = Id
            from dbo.AccEngineEvent
            where ItemId = @fcyRFcyPItemId
              and EventTypeCode = N'OnMaturation'
        end
    if not exists(select 1
                  from dbo.accEngineEvent
                  where ItemId = @fcyRFcyPItemId
                    and EventTypeCode = N'OnPayment')
        begin
            INSERT INTO dbo.AccEngineEvent (Id, ItemId, EventTypeCode, ModifiedBy, ModifiedDate,
                                            EventDescriptionDynamicRuleId)
            output inserted.Id into @tempTable
            VALUES (@lastAccEngineEventId, @fcyRFcyPItemId, N'OnPayment', @stateMaker, @stateDate, null);
            SELECT @fcyRFcyPPaymentEventId = Id FROM @tempTable;
            delete from @tempTable
            select @lastAccEngineEventId = @lastAccEngineEventId + 1
        end
    else
        begin
            select @fcyRFcyPPaymentEventId = Id
            from dbo.AccEngineEvent
            where ItemId = @fcyRFcyPItemId
              and EventTypeCode = N'OnPayment'
        end
    if not exists(select 1
                  from dbo.accEngineEvent
                  where ItemId = @fcyRFcyPItemId
                    and EventTypeCode = N'OnRevaluation')
        begin
            INSERT INTO dbo.AccEngineEvent (Id, ItemId, EventTypeCode, ModifiedBy, ModifiedDate,
                                            EventDescriptionDynamicRuleId)
            output inserted.Id into @tempTable
            VALUES (@lastAccEngineEventId, @fcyRFcyPItemId, N'OnRevaluation', @stateMaker, @stateDate, null);
            SELECT @fcyRFcyPRevaluationEventId = Id FROM @tempTable;
            delete from @tempTable
            select @lastAccEngineEventId = @lastAccEngineEventId + 1
        end
    else
        begin
            select @fcyRFcyPRevaluationEventId = Id
            from dbo.AccEngineEvent
            where ItemId = @fcyRFcyPItemId
              and EventTypeCode = N'OnRevaluation'
        end
    --#endregion
    ------------------------------------------------------------------------------------------------------------------------
    -- Accounting Engine Group
    ------------------------------------------------------------------------------------------------------------------------
--#region AccEngineGroup
    ------------------------------------------------------------------------------------------------------------------------
    -- Accounting Engine Group LCYRFCYP
    ------------------------------------------------------------------------------------------------------------------------
    if not exists(select 1
                  from dbo.accEngineGroup
                  where EventId = @lcyRFcyPOpeningEventId
                    and ValidationRuleId = @dynamicRuleValueDateGreaterThanLogicalDateId)
        begin
            INSERT INTO dbo.AccEngineGroup (Id, EventId, ValidationRuleId, [Order],
                                            ModifiedBy,
                                            ModifiedDate,
                                            StateId,
                                            StateDate,
                                            StateMaker)
            output inserted.Id into @tempTable
            VALUES (@lastAccEngineGroupId, @lcyRFcyPOpeningEventId, @dynamicRuleValueDateGreaterThanLogicalDateId, 1,
                    @stateMaker,
                    @stateDate,
                    @StateId,
                    @stateDate,
                    @stateMaker);
            SELECT @lcyRFcyPOpeningGroup1Id = Id FROM @tempTable;
            delete from @tempTable
            select @lastAccEngineGroupId = @lastAccEngineGroupId + 1
        end
    else
        begin
            select @lcyRFcyPOpeningGroup1Id = Id
            from dbo.AccEngineGroup
            where EventId = @lcyRFcyPOpeningEventId
              and ValidationRuleId = @dynamicRuleValueDateGreaterThanLogicalDateId
        end
    if not exists(select 1
                  from dbo.accEngineGroup
                  where EventId = @lcyRFcyPOpeningEventId
                    and ValidationRuleId = @dynamicRuleValueDateLessThanOrEqualLogicalDateId)
        begin
            INSERT INTO dbo.AccEngineGroup (Id, EventId, ValidationRuleId, [Order],
                                            ModifiedBy,
                                            ModifiedDate,
                                            StateId,
                                            StateDate,
                                            StateMaker)
            output inserted.Id into @tempTable
            VALUES (@lastAccEngineGroupId, @lcyRFcyPOpeningEventId, @dynamicRuleValueDateLessThanOrEqualLogicalDateId,
                    2,
                    @stateMaker,
                    @stateDate,
                    @StateId,
                    @stateDate,
                    @stateMaker);
            SELECT @lcyRFcyPOpeningGroup2Id = Id FROM @tempTable;
            delete from @tempTable
            select @lastAccEngineGroupId = @lastAccEngineGroupId + 1
        end
    else
        begin
            select @lcyRFcyPOpeningGroup2Id = Id
            from dbo.AccEngineGroup
            where EventId = @lcyRFcyPOpeningEventId
              and ValidationRuleId = @dynamicRuleValueDateLessThanOrEqualLogicalDateId
        end
    if not exists(select 1
                  from dbo.accEngineGroup
                  where EventId = @lcyRFcyPRevaluationEventId
                    and ValidationRuleId is null)
        begin
            INSERT INTO dbo.AccEngineGroup (Id, EventId, ValidationRuleId, [Order],
                                            ModifiedBy,
                                            ModifiedDate,
                                            StateId,
                                            StateDate,
                                            StateMaker)
            output inserted.Id into @tempTable
            VALUES (@lastAccEngineGroupId, @lcyRFcyPRevaluationEventId, null, 1,
                    @stateMaker,
                    @stateDate,
                    @StateId,
                    @stateDate,
                    @stateMaker);
            SELECT @lcyrfcyPRevaluationGroupId = Id FROM @tempTable;
            delete from @tempTable
            select @lastAccEngineGroupId = @lastAccEngineGroupId + 1
        end
    else
        begin
            select @lcyrfcyPRevaluationGroupId = Id
            from dbo.AccEngineGroup
            where EventId = @lcyRFcyPRevaluationEventId
              and ValidationRuleId is null
        end
    if not exists(select 1
                  from dbo.accEngineGroup
                  where EventId = @lcyRFcyPPaymentEventId
                    and ValidationRuleId is null)
        begin
            INSERT INTO dbo.AccEngineGroup (Id, EventId, ValidationRuleId, [Order],
                                            ModifiedBy,
                                            ModifiedDate,
                                            StateId,
                                            StateDate,
                                            StateMaker)
            output inserted.Id into @tempTable
            VALUES (@lastAccEngineGroupId, @lcyRFcyPPaymentEventId, null, 1,
                    @stateMaker,
                    @stateDate,
                    @StateId,
                    @stateDate,
                    @stateMaker);
            SELECT @lcyRFcyPPaymentGroupId = Id FROM @tempTable;
            delete from @tempTable
            select @lastAccEngineGroupId = @lastAccEngineGroupId + 1
        end
    else
        begin
            select @lcyRFcyPPaymentGroupId = Id
            from dbo.AccEngineGroup
            where EventId = @lcyRFcyPPaymentEventId
              and ValidationRuleId is null
        end
    if not exists(select 1
                  from dbo.accEngineGroup
                  where EventId = @lcyRFcyPMaturationEventId
                    and ValidationRuleId = @dynamicRuleMaturityDateEqualsLogicalDateId)
        begin
            INSERT INTO dbo.AccEngineGroup (Id, EventId, ValidationRuleId, [Order],
                                            ModifiedBy,
                                            ModifiedDate,
                                            StateId,
                                            StateDate,
                                            StateMaker)
            output inserted.Id into @tempTable
            VALUES (@lastAccEngineGroupId, @lcyRFcyPMaturationEventId, @dynamicRuleMaturityDateEqualsLogicalDateId, 1,
                    @stateMaker,
                    @stateDate,
                    @StateId,
                    @stateDate,
                    @stateMaker);
            SELECT @lcyRFcyPMaturationGroupId = Id FROM @tempTable;
            delete from @tempTable
            select @lastAccEngineGroupId = @lastAccEngineGroupId + 1
        end
    else
        begin
            select @lcyRFcyPMaturationGroupId = Id
            from dbo.AccEngineGroup
            where EventId = @lcyRFcyPMaturationEventId
              and ValidationRuleId = @dynamicRuleMaturityDateEqualsLogicalDateId
        end
    ------------------------------------------------------------------------------------------------------------------------
    -- Accounting Engine Group FCYRLCYP
    ------------------------------------------------------------------------------------------------------------------------
    if not exists(select 1
                  from dbo.accEngineGroup
                  where EventId = @fcyRLcyPOpeningEventId
                    and ValidationRuleId = @dynamicRuleValueDateGreaterThanLogicalDateId)
        begin
            INSERT INTO dbo.AccEngineGroup (Id, EventId, ValidationRuleId, [Order],
                                            ModifiedBy,
                                            ModifiedDate,
                                            StateId,
                                            StateDate,
                                            StateMaker)
            output inserted.Id into @tempTable
            VALUES (@lastAccEngineGroupId, @fcyRLcyPOpeningEventId, @dynamicRuleValueDateGreaterThanLogicalDateId, 1,
                    @stateMaker,
                    @stateDate,
                    @StateId,
                    @stateDate,
                    @stateMaker);
            SELECT @fcyRLcyPOpeningGroup1Id = Id FROM @tempTable;
            delete from @tempTable
            select @lastAccEngineGroupId = @lastAccEngineGroupId + 1
        end
    else
        begin
            select @fcyRLcyPOpeningGroup1Id = Id
            from dbo.AccEngineGroup
            where EventId = @fcyRLcyPOpeningEventId
              and ValidationRuleId = @dynamicRuleValueDateGreaterThanLogicalDateId
        end
    if not exists(select 1
                  from dbo.accEngineGroup
                  where EventId = @fcyRLcyPOpeningEventId
                    and ValidationRuleId = @dynamicRuleValueDateLessThanOrEqualLogicalDateId)
        begin
            INSERT INTO dbo.AccEngineGroup (Id, EventId, ValidationRuleId, [Order],
                                            ModifiedBy,
                                            ModifiedDate,
                                            StateId,
                                            StateDate,
                                            StateMaker)
            output inserted.Id into @tempTable
            VALUES (@lastAccEngineGroupId, @fcyRLcyPOpeningEventId, @dynamicRuleValueDateLessThanOrEqualLogicalDateId,
                    2,
                    @stateMaker,
                    @stateDate,
                    @StateId,
                    @stateDate,
                    @stateMaker);
            SELECT @fcyRLcyPOpeningGroup2Id = Id FROM @tempTable;
            delete from @tempTable
            select @lastAccEngineGroupId = @lastAccEngineGroupId + 1
        end
    else
        begin
            select @fcyRLcyPOpeningGroup2Id = Id
            from dbo.AccEngineGroup
            where EventId = @fcyRLcyPOpeningEventId
              and ValidationRuleId = @dynamicRuleValueDateLessThanOrEqualLogicalDateId
        end
    if not exists(select 1
                  from dbo.accEngineGroup
                  where EventId = @fcyRLcyPRevaluationEventId
                    and ValidationRuleId is null)
        begin
            INSERT INTO dbo.AccEngineGroup (Id, EventId, ValidationRuleId, [Order],
                                            ModifiedBy,
                                            ModifiedDate,
                                            StateId,
                                            StateDate,
                                            StateMaker)
            output inserted.Id into @tempTable
            VALUES (@lastAccEngineGroupId, @fcyRLcyPRevaluationEventId, null, 1,
                    @stateMaker,
                    @stateDate,
                    @StateId,
                    @stateDate,
                    @stateMaker);
            SELECT @fcyRLcyPRevaluationGroupId = Id FROM @tempTable;
            delete from @tempTable
            select @lastAccEngineGroupId = @lastAccEngineGroupId + 1
        end
    else
        begin
            select @fcyRLcyPRevaluationGroupId = Id
            from dbo.AccEngineGroup
            where EventId = @fcyRLcyPRevaluationEventId
              and ValidationRuleId is null
        end
    if not exists(select 1
                  from dbo.accEngineGroup
                  where EventId = @fcyRLcyPPaymentEventId
                    and ValidationRuleId is null)
        begin
            INSERT INTO dbo.AccEngineGroup (Id, EventId, ValidationRuleId, [Order],
                                            ModifiedBy,
                                            ModifiedDate,
                                            StateId,
                                            StateDate,
                                            StateMaker)
            output inserted.Id into @tempTable
            VALUES (@lastAccEngineGroupId, @fcyRLcyPPaymentEventId, null, 1,
                    @stateMaker,
                    @stateDate,
                    @StateId,
                    @stateDate,
                    @stateMaker);
            SELECT @fcyRLcyPPaymentGroupId = Id FROM @tempTable;
            delete from @tempTable
            select @lastAccEngineGroupId = @lastAccEngineGroupId + 1
        end
    else
        begin
            select @fcyRLcyPPaymentGroupId = Id
            from dbo.AccEngineGroup
            where EventId = @fcyRLcyPPaymentEventId
              and ValidationRuleId is null
        end
    if not exists(select 1
                  from dbo.accEngineGroup
                  where EventId = @fcyRLcyPMaturationEventId
                    and ValidationRuleId = @dynamicRuleMaturityDateEqualsLogicalDateId)
        begin
            INSERT INTO dbo.AccEngineGroup (Id, EventId, ValidationRuleId, [Order],
                                            ModifiedBy,
                                            ModifiedDate,
                                            StateId,
                                            StateDate,
                                            StateMaker)
            output inserted.Id into @tempTable
            VALUES (@lastAccEngineGroupId, @fcyRLcyPMaturationEventId, @dynamicRuleMaturityDateEqualsLogicalDateId, 1,
                    @stateMaker,
                    @stateDate,
                    @StateId,
                    @stateDate,
                    @stateMaker);
            SELECT @fcyRLcyPMaturationGroupId = Id FROM @tempTable;
            delete from @tempTable
            select @lastAccEngineGroupId = @lastAccEngineGroupId + 1
        end
    else
        begin
            select @fcyRLcyPMaturationGroupId = Id
            from dbo.AccEngineGroup
            where EventId = @fcyRLcyPMaturationEventId
              and ValidationRuleId = @dynamicRuleMaturityDateEqualsLogicalDateId
        end
    ------------------------------------------------------------------------------------------------------------------------
    -- Accounting Engine Group FCYRFCYP
    ------------------------------------------------------------------------------------------------------------------------
    if not exists(select 1
                  from dbo.accEngineGroup
                  where EventId = @fcyRFcyPOpeningEventId
                    and ValidationRuleId = @dynamicRuleValueDateGreaterThanLogicalDateId)
        begin
            INSERT INTO dbo.AccEngineGroup (Id, EventId, ValidationRuleId, [Order],
                                            ModifiedBy,
                                            ModifiedDate,
                                            StateId,
                                            StateDate,
                                            StateMaker)
            output inserted.Id into @tempTable
            VALUES (@lastAccEngineGroupId, @fcyRFcyPOpeningEventId, @dynamicRuleValueDateGreaterThanLogicalDateId, 1,
                    @stateMaker,
                    @stateDate,
                    @StateId,
                    @stateDate,
                    @stateMaker);
            SELECT @fcyRFcyPOpeningGroup1Id = Id FROM @tempTable;
            delete from @tempTable
            select @lastAccEngineGroupId = @lastAccEngineGroupId + 1
        end
    else
        begin
            select @fcyRFcyPOpeningGroup1Id = Id
            from dbo.AccEngineGroup
            where EventId = @fcyRFcyPOpeningEventId
              and ValidationRuleId = @dynamicRuleValueDateGreaterThanLogicalDateId
        end
    if not exists(select 1
                  from dbo.accEngineGroup
                  where EventId = @fcyRFcyPOpeningEventId
                    and ValidationRuleId = @dynamicRuleValueDateLessThanOrEqualLogicalDateId)
        begin
            INSERT INTO dbo.AccEngineGroup (Id, EventId, ValidationRuleId, [Order],
                                            ModifiedBy,
                                            ModifiedDate,
                                            StateId,
                                            StateDate,
                                            StateMaker)
            output inserted.Id into @tempTable
            VALUES (@lastAccEngineGroupId, @fcyRFcyPOpeningEventId, @dynamicRuleValueDateLessThanOrEqualLogicalDateId,
                    2,
                    @stateMaker,
                    @stateDate,
                    @StateId,
                    @stateDate,
                    @stateMaker);
            SELECT @fcyRFcyPOpeningGroup2Id = Id FROM @tempTable;
            delete from @tempTable
            select @lastAccEngineGroupId = @lastAccEngineGroupId + 1
        end
    else
        begin
            select @fcyRFcyPOpeningGroup2Id = Id
            from dbo.AccEngineGroup
            where EventId = @fcyRFcyPOpeningEventId
              and ValidationRuleId = @dynamicRuleValueDateLessThanOrEqualLogicalDateId
        end
    if not exists(select 1
                  from dbo.accEngineGroup
                  where EventId = @fcyRFcyPRevaluationEventId
                    and ValidationRuleId is null)
        begin
            INSERT INTO dbo.AccEngineGroup (Id, EventId, ValidationRuleId, [Order],
                                            ModifiedBy,
                                            ModifiedDate,
                                            StateId,
                                            StateDate,
                                            StateMaker)
            output inserted.Id into @tempTable
            VALUES (@lastAccEngineGroupId, @fcyRFcyPRevaluationEventId, null, 1,
                    @stateMaker,
                    @stateDate,
                    @StateId,
                    @stateDate,
                    @stateMaker);
            SELECT @fcyRFcyPRevaluationGroupId = Id FROM @tempTable;
            delete from @tempTable
            select @lastAccEngineGroupId = @lastAccEngineGroupId + 1
        end
    else
        begin
            select @fcyRFcyPRevaluationGroupId = Id
            from dbo.AccEngineGroup
            where EventId = @fcyRFcyPRevaluationEventId
              and ValidationRuleId is null
        end
    if not exists(select 1
                  from dbo.accEngineGroup
                  where EventId = @fcyRFcyPPaymentEventId
                    and ValidationRuleId is null)
        begin
            INSERT INTO dbo.AccEngineGroup (Id, EventId, ValidationRuleId, [Order],
                                            ModifiedBy,
                                            ModifiedDate,
                                            StateId,
                                            StateDate,
                                            StateMaker)
            output inserted.Id into @tempTable
            VALUES (@lastAccEngineGroupId, @fcyRFcyPPaymentEventId, null, 1,
                    @stateMaker,
                    @stateDate,
                    @StateId,
                    @stateDate,
                    @stateMaker);
            SELECT @fcyRFcyPPaymentGroupId = Id FROM @tempTable;
            delete from @tempTable
            select @lastAccEngineGroupId = @lastAccEngineGroupId + 1
        end
    else
        begin
            select @fcyRFcyPPaymentGroupId = Id
            from dbo.AccEngineGroup
            where EventId = @fcyRFcyPPaymentEventId
              and ValidationRuleId is null
        end
    if not exists(select 1
                  from dbo.accEngineGroup
                  where EventId = @fcyRFcyPMaturationEventId
                    and ValidationRuleId = @dynamicRuleMaturityDateEqualsLogicalDateId)
        begin
            INSERT INTO dbo.AccEngineGroup (Id, EventId, ValidationRuleId, [Order],
                                            ModifiedBy,
                                            ModifiedDate,
                                            StateId,
                                            StateDate,
                                            StateMaker)
            output inserted.Id into @tempTable
            VALUES (@lastAccEngineGroupId, @fcyRFcyPMaturationEventId, @dynamicRuleMaturityDateEqualsLogicalDateId, 1,
                    @stateMaker,
                    @stateDate,
                    @StateId,
                    @stateDate,
                    @stateMaker);
            SELECT @fcyRFcyPMaturationGroupId = Id FROM @tempTable;
            delete from @tempTable
        end
    else
        begin
            select @fcyRFcyPMaturationGroupId = Id
            from dbo.AccEngineGroup
            where EventId = @fcyRFcyPMaturationEventId
              and ValidationRuleId = @dynamicRuleMaturityDateEqualsLogicalDateId
        end
    --#endregion
    ------------------------------------------------------------------------------------------------------------------------
    -- Accounting Engine Component
    ------------------------------------------------------------------------------------------------------------------------
--#region AccEngineComponent
    ------------------------------------------------------------------------------------------------------------------------
    -- Accounting Engine Component LCYRFCYP
    ------------------------------------------------------------------------------------------------------------------------
    if not exists (select 1
                   from dbo.accEngineComponent
                   where GroupId = @lcyRFcyPOpeningGroup1Id
                     and ComponentTypeCode = N'500')
        begin
            INSERT INTO dbo.AccEngineComponent (Id, GroupId, ComponentTypeCode, ValidationRuleId, [Order],
                                                ModifiedBy,
                                                ModifiedDate)
            output inserted.Id into @tempTable
            VALUES (@lastAccEngineComponentId, @lcyRFcyPOpeningGroup1Id, N'500',
                    null,
                    1,
                    @stateMaker,
                    @stateDate);
            SELECT @lcyRFcyPOpeningGroup1Component1Id = Id FROM @tempTable;
            delete from @tempTable
            select @lastAccEngineComponentId = @lastAccEngineComponentId + 1
        end
    else
        begin
            select @lcyRFcyPOpeningGroup1Component1Id = Id
            from dbo.AccEngineComponent
            where GroupId = @lcyRFcyPOpeningGroup1Id
              and ComponentTypeCode = N'500'
        end
    if not exists (select 1
                   from dbo.accEngineComponent
                   where GroupId = @lcyRFcyPOpeningGroup1Id
                     and ComponentTypeCode = N'501')
        begin
            INSERT INTO dbo.AccEngineComponent (Id, GroupId, ComponentTypeCode, ValidationRuleId, [Order],
                                                ModifiedBy,
                                                ModifiedDate)
            output inserted.Id into @tempTable
            VALUES (@lastAccEngineComponentId, @lcyRFcyPOpeningGroup1Id, N'501',
                    null,
                    2,
                    @stateMaker,
                    @stateDate);
            SELECT @lcyRFcyPOpeningGroup1Component2Id = Id FROM @tempTable;
            delete from @tempTable
            select @lastAccEngineComponentId = @lastAccEngineComponentId + 1
        end
    else
        begin
            select @lcyRFcyPOpeningGroup1Component2Id = Id
            from dbo.AccEngineComponent
            where GroupId = @lcyRFcyPOpeningGroup1Id
              and ComponentTypeCode = N'501'
        end
    if not exists (select 1
                   from dbo.accEngineComponent
                   where GroupId = @lcyRFcyPOpeningGroup2Id
                     and ComponentTypeCode = N'503')
        begin
            INSERT INTO dbo.AccEngineComponent (Id, GroupId, ComponentTypeCode, ValidationRuleId, [Order], ModifiedBy,
                                                ModifiedDate)
            output inserted.Id into @tempTable
            VALUES (@lastAccEngineComponentId, @lcyRFcyPOpeningGroup2Id, N'503', null,
                    1,
                    @stateMaker,
                    @stateDate);
            SELECT @lcyRFcyPOpeningGroup2Component1Id = Id FROM @tempTable;
            delete from @tempTable
            select @lastAccEngineComponentId = @lastAccEngineComponentId + 1
        end
    else
        begin
            select @lcyRFcyPOpeningGroup2Component1Id = Id
            from dbo.AccEngineComponent
            where GroupId = @lcyRFcyPOpeningGroup2Id
              and ComponentTypeCode = N'503'
        end
    if not exists (select 1
                   from dbo.accEngineComponent
                   where GroupId = @lcyRFcyPOpeningGroup2Id
                     and ComponentTypeCode = N'502')
        begin
            INSERT INTO dbo.AccEngineComponent (Id, GroupId, ComponentTypeCode, ValidationRuleId, [Order], ModifiedBy,
                                                ModifiedDate)
            output inserted.Id into @tempTable
            VALUES (@lastAccEngineComponentId, @lcyRFcyPOpeningGroup2Id, N'502', null,
                    2,
                    @stateMaker,
                    @stateDate);
            SELECT @lcyRFcyPOpeningGroup2Component2Id = Id FROM @tempTable;
            delete from @tempTable
            select @lastAccEngineComponentId = @lastAccEngineComponentId + 1
        end
    else
        begin
            select @lcyRFcyPOpeningGroup2Component2Id = Id
            from dbo.AccEngineComponent
            where GroupId = @lcyRFcyPOpeningGroup2Id
              and ComponentTypeCode = N'502'
        end
    if not exists (select 1
                   from dbo.accEngineComponent
                   where GroupId = @lcyRFcyPOpeningGroup2Id
                     and ComponentTypeCode = N'500')
        begin
            INSERT INTO dbo.AccEngineComponent (Id, GroupId, ComponentTypeCode, ValidationRuleId, [Order], ModifiedBy,
                                                ModifiedDate)
            output inserted.Id into @tempTable
            VALUES (@lastAccEngineComponentId, @lcyRFcyPOpeningGroup2Id, N'500',
                    @dynamicRuleValueDateGreaterThanTradeDateId,
                    3,
                    @stateMaker,
                    @stateDate);
            SELECT @lcyRFcyPOpeningGroup2Component3Id = Id FROM @tempTable;
            delete from @tempTable
            select @lastAccEngineComponentId = @lastAccEngineComponentId + 1
        end
    else
        begin
            select @lcyRFcyPOpeningGroup2Component3Id = Id
            from dbo.AccEngineComponent
            where GroupId = @lcyRFcyPOpeningGroup2Id
              and ComponentTypeCode = N'500'
        end
    if not exists (select 1
                   from dbo.accEngineComponent
                   where GroupId = @lcyRFcyPOpeningGroup2Id
                     and ComponentTypeCode = N'501')
        begin
            INSERT INTO dbo.AccEngineComponent (Id, GroupId, ComponentTypeCode, ValidationRuleId, [Order], ModifiedBy,
                                                ModifiedDate)
            output inserted.Id into @tempTable
            VALUES (@lastAccEngineComponentId, @lcyRFcyPOpeningGroup2Id, N'501',
                    @dynamicRuleValueDateLessThanOrEqualTradeDateId,
                    4,
                    @stateMaker,
                    @stateDate);
            SELECT @lcyRFcyPOpeningGroup2Component4Id = Id FROM @tempTable;
            delete from @tempTable
            select @lastAccEngineComponentId = @lastAccEngineComponentId + 1
        end
    else
        begin
            select @lcyRFcyPOpeningGroup2Component4Id = Id
            from dbo.AccEngineComponent
            where GroupId = @lcyRFcyPOpeningGroup2Id
              and ComponentTypeCode = N'501'
        end
    if not exists (select 1
                   from dbo.accEngineComponent
                   where GroupId = @lcyRFcyPRevaluationGroupId
                     and ComponentTypeCode = N'508')
        begin
            INSERT INTO dbo.AccEngineComponent (Id, GroupId, ComponentTypeCode, ValidationRuleId, [Order], ModifiedBy,
                                                ModifiedDate)
            output inserted.Id into @tempTable
            VALUES (@lastAccEngineComponentId, @lcyRFcyPRevaluationGroupId, N'508',
                    @dynamicRuleDerivativeSwapMTMProfitId,
                    1,
                    @stateMaker,
                    @stateDate);
            SELECT @lcyRFcyPRevaluationGroupComponent1Id = Id FROM @tempTable;
            delete from @tempTable
            select @lastAccEngineComponentId = @lastAccEngineComponentId + 1
        end
    else
        begin
            select @lcyRFcyPRevaluationGroupComponent1Id = Id
            from dbo.AccEngineComponent
            where GroupId = @lcyRFcyPRevaluationGroupId
              and ComponentTypeCode = N'508'
        end
    if not exists (select 1
                   from dbo.accEngineComponent
                   where GroupId = @lcyRFcyPRevaluationGroupId
                     and ComponentTypeCode = N'509')
        begin
            INSERT INTO dbo.AccEngineComponent (Id, GroupId, ComponentTypeCode, ValidationRuleId, [Order], ModifiedBy,
                                                ModifiedDate)
            output inserted.Id into @tempTable
            VALUES (@lastAccEngineComponentId, @lcyRFcyPRevaluationGroupId,
                    N'509',
                    @dynamicRuleDerivativeSwapMTMLossId,
                    2,
                    @stateMaker,
                    @stateDate);
            SELECT @lcyRFcyPRevaluationGroupComponent2Id = Id FROM @tempTable;
            delete from @tempTable
            select @lastAccEngineComponentId = @lastAccEngineComponentId + 1
        end
    else
        begin
            select @lcyRFcyPRevaluationGroupComponent2Id = Id
            from dbo.AccEngineComponent
            where GroupId = @lcyRFcyPRevaluationGroupId
              and ComponentTypeCode = N'509'
        end
    if not exists (select 1
                   from dbo.accEngineComponent
                   where GroupId = @lcyRFcyPPaymentGroupId
                     and ComponentTypeCode = N'506')
        begin
            INSERT INTO dbo.AccEngineComponent (Id, GroupId, ComponentTypeCode, ValidationRuleId, [Order], ModifiedBy,
                                                ModifiedDate)
            output inserted.Id into @tempTable
            VALUES (@lastAccEngineComponentId, @lcyRFcyPPaymentGroupId,
                    N'506',
                    @dynamicRuleReceivePeriodEndDateEqualsLogicalDateId,
                    1,
                    @stateMaker,
                    @stateDate);
            SELECT @lcyRFcyPPaymentGroupComponent1Id = Id FROM @tempTable;
            delete from @tempTable
            select @lastAccEngineComponentId = @lastAccEngineComponentId + 1
        end
    else
        begin
            select @lcyRFcyPPaymentGroupComponent1Id = Id
            from dbo.AccEngineComponent
            where GroupId = @lcyRFcyPPaymentGroupId
              and ComponentTypeCode = N'506'
        end
    if not exists (select 1
                   from dbo.accEngineComponent
                   where GroupId = @lcyRFcyPPaymentGroupId
                     and ComponentTypeCode = N'507')
        begin
            INSERT INTO dbo.AccEngineComponent (Id, GroupId, ComponentTypeCode, ValidationRuleId, [Order], ModifiedBy,
                                                ModifiedDate)
            output inserted.Id into @tempTable
            VALUES (@lastAccEngineComponentId, @lcyRFcyPPaymentGroupId,
                    N'507',
                    @dynamicRulePayPeriodEndDateEqualsLogicalDateId,
                    2,
                    @stateMaker,
                    @stateDate);
            SELECT @lcyRFcyPPaymentGroupComponent2Id = Id FROM @tempTable;
            delete from @tempTable
            select @lastAccEngineComponentId = @lastAccEngineComponentId + 1
        end
    else
        begin
            select @lcyRFcyPPaymentGroupComponent2Id = Id
            from dbo.AccEngineComponent
            where GroupId = @lcyRFcyPPaymentGroupId
              and ComponentTypeCode = N'507'
        end
    if not exists (select 1
                   from dbo.accEngineComponent
                   where GroupId = @lcyRFcyPMaturationGroupId
                     and ComponentTypeCode = N'504')
        begin
            INSERT INTO dbo.AccEngineComponent (Id, GroupId, ComponentTypeCode, ValidationRuleId, [Order], ModifiedBy,
                                                ModifiedDate)
            output inserted.Id into @tempTable
            VALUES (@lastAccEngineComponentId, @lcyRFcyPMaturationGroupId,
                    N'504',
                    null,
                    1,
                    @stateMaker,
                    @stateDate);
            SELECT @lcyRFcyPMaturationGroupComponent1Id = Id FROM @tempTable;
            delete from @tempTable
            select @lastAccEngineComponentId = @lastAccEngineComponentId + 1
        end
    else
        begin
            select @lcyRFcyPMaturationGroupComponent1Id = Id
            from dbo.AccEngineComponent
            where GroupId = @lcyRFcyPMaturationGroupId
              and ComponentTypeCode = N'504'
        end
    if not exists (select 1
                   from dbo.accEngineComponent
                   where GroupId = @lcyRFcyPMaturationGroupId
                     and ComponentTypeCode = N'505')
        begin
            INSERT INTO dbo.AccEngineComponent (Id, GroupId, ComponentTypeCode, ValidationRuleId, [Order], ModifiedBy,
                                                ModifiedDate)
            output inserted.Id into @tempTable
            VALUES (@lastAccEngineComponentId, @lcyRFcyPMaturationGroupId,
                    N'505',
                    null,
                    2,
                    @stateMaker,
                    @stateDate);
            SELECT @lcyRFcyPMaturationGroupComponent2Id = Id FROM @tempTable;
            delete from @tempTable
            select @lastAccEngineComponentId = @lastAccEngineComponentId + 1
        end
    else
        begin
            select @lcyRFcyPMaturationGroupComponent2Id = Id
            from dbo.AccEngineComponent
            where GroupId = @lcyRFcyPMaturationGroupId
              and ComponentTypeCode = N'505'
        end
    if not exists (select 1
                   from dbo.accEngineComponent
                   where GroupId = @lcyRFcyPMaturationGroupId
                     and ComponentTypeCode = N'501')
        begin
            INSERT INTO dbo.AccEngineComponent (Id, GroupId, ComponentTypeCode, ValidationRuleId, [Order], ModifiedBy,
                                                ModifiedDate)
            output inserted.Id into @tempTable
            VALUES (@lastAccEngineComponentId, @lcyRFcyPMaturationGroupId,
                    N'501',
                    null,
                    3,
                    @stateMaker,
                    @stateDate);
            SELECT @lcyRFcyPMaturationGroupComponent3Id = Id FROM @tempTable;
            delete from @tempTable
            select @lastAccEngineComponentId = @lastAccEngineComponentId + 1
        end
    else
        begin
            select @lcyRFcyPMaturationGroupComponent3Id = Id
            from dbo.AccEngineComponent
            where GroupId = @lcyRFcyPMaturationGroupId
              and ComponentTypeCode = N'501'
        end
    if not exists (select 1
                   from dbo.accEngineComponent
                   where GroupId = @lcyRFcyPMaturationGroupId
                     and ComponentTypeCode = N'110')
        begin
            INSERT INTO dbo.AccEngineComponent (Id, GroupId, ComponentTypeCode, ValidationRuleId, [Order], ModifiedBy,
                                                ModifiedDate)
            output inserted.Id into @tempTable
            VALUES (@lastAccEngineComponentId, @lcyRFcyPMaturationGroupId,
                    N'110',
                    null,
                    4,
                    @stateMaker,
                    @stateDate);
            SELECT @lcyRFcyPMaturationGroupComponent4Id = Id FROM @tempTable;
            delete from @tempTable
            select @lastAccEngineComponentId = @lastAccEngineComponentId + 1
        end
    else
        begin
            select @lcyRFcyPMaturationGroupComponent4Id = Id
            from dbo.AccEngineComponent
            where GroupId = @lcyRFcyPMaturationGroupId
              and ComponentTypeCode = N'110'
        end
    ------------------------------------------------------------------------------------------------------------------------
    -- Accounting Engine Component FCYRLCYP
    ------------------------------------------------------------------------------------------------------------------------
    if not exists (select 1
                   from dbo.accEngineComponent
                   where GroupId = @fcyRLcyPOpeningGroup1Id
                     and ComponentTypeCode = N'500')
        begin
            INSERT INTO dbo.AccEngineComponent (Id, GroupId, ComponentTypeCode, ValidationRuleId, [Order],
                                                ModifiedBy,
                                                ModifiedDate)
            output inserted.Id into @tempTable
            VALUES (@lastAccEngineComponentId, @fcyRLcyPOpeningGroup1Id, N'500',
                    null,
                    1,
                    @stateMaker,
                    @stateDate);
            SELECT @fcyRLcyPOpeningGroup1Component1Id = Id FROM @tempTable;
            delete from @tempTable
            select @lastAccEngineComponentId = @lastAccEngineComponentId + 1
        end
    else
        begin
            select @fcyRLcyPOpeningGroup1Component1Id = Id
            from dbo.AccEngineComponent
            where GroupId = @fcyRLcyPOpeningGroup1Id
              and ComponentTypeCode = N'500'
        end
    if not exists (select 1
                   from dbo.accEngineComponent
                   where GroupId = @fcyRLcyPOpeningGroup1Id
                     and ComponentTypeCode = N'501')
        begin
            INSERT INTO dbo.AccEngineComponent (Id, GroupId, ComponentTypeCode, ValidationRuleId, [Order],
                                                ModifiedBy,
                                                ModifiedDate)
            output inserted.Id into @tempTable
            VALUES (@lastAccEngineComponentId, @fcyRLcyPOpeningGroup1Id, N'501',
                    null,
                    2,
                    @stateMaker,
                    @stateDate);
            SELECT @fcyRLcyPOpeningGroup1Component2Id = Id FROM @tempTable;
            delete from @tempTable
            select @lastAccEngineComponentId = @lastAccEngineComponentId + 1
        end
    else
        begin
            select @fcyRLcyPOpeningGroup1Component2Id = Id
            from dbo.AccEngineComponent
            where GroupId = @fcyRLcyPOpeningGroup1Id
              and ComponentTypeCode = N'501'
        end
    if not exists (select 1
                   from dbo.accEngineComponent
                   where GroupId = @fcyRLcyPOpeningGroup2Id
                     and ComponentTypeCode = N'503')
        begin
            INSERT INTO dbo.AccEngineComponent (Id, GroupId, ComponentTypeCode, ValidationRuleId, [Order], ModifiedBy,
                                                ModifiedDate)
            output inserted.Id into @tempTable
            VALUES (@lastAccEngineComponentId, @fcyRLcyPOpeningGroup2Id, N'503', null,
                    1,
                    @stateMaker,
                    @stateDate);
            SELECT @fcyRLcyPOpeningGroup2Component1Id = Id FROM @tempTable;
            delete from @tempTable
            select @lastAccEngineComponentId = @lastAccEngineComponentId + 1
        end
    else
        begin
            select @fcyRLcyPOpeningGroup2Component1Id = Id
            from dbo.AccEngineComponent
            where GroupId = @fcyRLcyPOpeningGroup2Id
              and ComponentTypeCode = N'503'
        end
    if not exists (select 1
                   from dbo.accEngineComponent
                   where GroupId = @fcyRLcyPOpeningGroup2Id
                     and ComponentTypeCode = N'502')
        begin
            INSERT INTO dbo.AccEngineComponent (Id, GroupId, ComponentTypeCode, ValidationRuleId, [Order], ModifiedBy,
                                                ModifiedDate)
            output inserted.Id into @tempTable
            VALUES (@lastAccEngineComponentId, @fcyRLcyPOpeningGroup2Id, N'502', null,
                    2,
                    @stateMaker,
                    @stateDate);
            SELECT @fcyRLcyPOpeningGroup2Component2Id = Id FROM @tempTable;
            delete from @tempTable
            select @lastAccEngineComponentId = @lastAccEngineComponentId + 1
        end
    else
        begin
            select @fcyRLcyPOpeningGroup2Component2Id = Id
            from dbo.AccEngineComponent
            where GroupId = @fcyRLcyPOpeningGroup2Id
              and ComponentTypeCode = N'502'
        end
    if not exists (select 1
                   from dbo.accEngineComponent
                   where GroupId = @fcyRLcyPOpeningGroup2Id
                     and ComponentTypeCode = N'500')
        begin
            INSERT INTO dbo.AccEngineComponent (Id, GroupId, ComponentTypeCode, ValidationRuleId, [Order], ModifiedBy,
                                                ModifiedDate)
            output inserted.Id into @tempTable
            VALUES (@lastAccEngineComponentId, @fcyRLcyPOpeningGroup2Id, N'500',
                    @dynamicRuleValueDateGreaterThanTradeDateId,
                    3,
                    @stateMaker,
                    @stateDate);
            SELECT @fcyRLcyPOpeningGroup2Component3Id = Id FROM @tempTable;
            delete from @tempTable
            select @lastAccEngineComponentId = @lastAccEngineComponentId + 1
        end
    else
        begin
            select @fcyRLcyPOpeningGroup2Component3Id = Id
            from dbo.AccEngineComponent
            where GroupId = @fcyRLcyPOpeningGroup2Id
              and ComponentTypeCode = N'500'
        end
    if not exists (select 1
                   from dbo.accEngineComponent
                   where GroupId = @fcyRLcyPOpeningGroup2Id
                     and ComponentTypeCode = N'501')
        begin
            INSERT INTO dbo.AccEngineComponent (Id, GroupId, ComponentTypeCode, ValidationRuleId, [Order], ModifiedBy,
                                                ModifiedDate)
            output inserted.Id into @tempTable
            VALUES (@lastAccEngineComponentId, @fcyRLcyPOpeningGroup2Id, N'501',
                    @dynamicRuleValueDateLessThanOrEqualTradeDateId,
                    4,
                    @stateMaker,
                    @stateDate);
            SELECT @fcyRLcyPOpeningGroup2Component4Id = Id FROM @tempTable;
            delete from @tempTable
            select @lastAccEngineComponentId = @lastAccEngineComponentId + 1
        end
    else
        begin
            select @fcyRLcyPOpeningGroup2Component4Id = Id
            from dbo.AccEngineComponent
            where GroupId = @fcyRLcyPOpeningGroup2Id
              and ComponentTypeCode = N'501'
        end
    if not exists (select 1
                   from dbo.accEngineComponent
                   where GroupId = @fcyRLcyPRevaluationGroupId
                     and ComponentTypeCode = N'508')
        begin
            INSERT INTO dbo.AccEngineComponent (Id, GroupId, ComponentTypeCode, ValidationRuleId, [Order], ModifiedBy,
                                                ModifiedDate)
            output inserted.Id into @tempTable
            VALUES (@lastAccEngineComponentId, @fcyRLcyPRevaluationGroupId, N'508',
                    @dynamicRuleDerivativeSwapMTMProfitId,
                    1,
                    @stateMaker,
                    @stateDate);
            SELECT @fcyRLcyPRevaluationGroupComponent1Id = Id FROM @tempTable;
            delete from @tempTable
            select @lastAccEngineComponentId = @lastAccEngineComponentId + 1
        end
    else
        begin
            select @fcyRLcyPRevaluationGroupComponent1Id = Id
            from dbo.AccEngineComponent
            where GroupId = @fcyRLcyPRevaluationGroupId
              and ComponentTypeCode = N'508'
        end
    if not exists (select 1
                   from dbo.accEngineComponent
                   where GroupId = @fcyRLcyPRevaluationGroupId
                     and ComponentTypeCode = N'509')
        begin
            INSERT INTO dbo.AccEngineComponent (Id, GroupId, ComponentTypeCode, ValidationRuleId, [Order], ModifiedBy,
                                                ModifiedDate)
            output inserted.Id into @tempTable
            VALUES (@lastAccEngineComponentId, @fcyRLcyPRevaluationGroupId,
                    N'509',
                    @dynamicRuleDerivativeSwapMTMLossId,
                    2,
                    @stateMaker,
                    @stateDate);
            SELECT @fcyRLcyPRevaluationGroupComponent2Id = Id FROM @tempTable;
            delete from @tempTable
            select @lastAccEngineComponentId = @lastAccEngineComponentId + 1
        end
    else
        begin
            select @fcyRLcyPRevaluationGroupComponent2Id = Id
            from dbo.AccEngineComponent
            where GroupId = @fcyRLcyPRevaluationGroupId
              and ComponentTypeCode = N'509'
        end
    if not exists (select 1
                   from dbo.accEngineComponent
                   where GroupId = @fcyRLcyPPaymentGroupId
                     and ComponentTypeCode = N'506')
        begin
            INSERT INTO dbo.AccEngineComponent (Id, GroupId, ComponentTypeCode, ValidationRuleId, [Order], ModifiedBy,
                                                ModifiedDate)
            output inserted.Id into @tempTable
            VALUES (@lastAccEngineComponentId, @fcyRLcyPPaymentGroupId,
                    N'506',
                    @dynamicRuleReceivePeriodEndDateEqualsLogicalDateId,
                    1,
                    @stateMaker,
                    @stateDate);
            SELECT @fcyRLcyPPaymentGroupComponent1Id = Id FROM @tempTable;
            delete from @tempTable
            select @lastAccEngineComponentId = @lastAccEngineComponentId + 1
        end
    else
        begin
            select @fcyRLcyPPaymentGroupComponent1Id = Id
            from dbo.AccEngineComponent
            where GroupId = @fcyRLcyPPaymentGroupId
              and ComponentTypeCode = N'506'
        end
    if not exists (select 1
                   from dbo.accEngineComponent
                   where GroupId = @fcyRLcyPPaymentGroupId
                     and ComponentTypeCode = N'507')
        begin
            INSERT INTO dbo.AccEngineComponent (Id, GroupId, ComponentTypeCode, ValidationRuleId, [Order], ModifiedBy,
                                                ModifiedDate)
            output inserted.Id into @tempTable
            VALUES (@lastAccEngineComponentId, @fcyRLcyPPaymentGroupId,
                    N'507',
                    @dynamicRulePayPeriodEndDateEqualsLogicalDateId,
                    2,
                    @stateMaker,
                    @stateDate);
            SELECT @fcyRLcyPPaymentGroupComponent2Id = Id FROM @tempTable;
            delete from @tempTable
            select @lastAccEngineComponentId = @lastAccEngineComponentId + 1
        end
    else
        begin
            select @fcyRLcyPPaymentGroupComponent2Id = Id
            from dbo.AccEngineComponent
            where GroupId = @fcyRLcyPPaymentGroupId
              and ComponentTypeCode = N'507'
        end
    if not exists (select 1
                   from dbo.accEngineComponent
                   where GroupId = @fcyRLcyPMaturationGroupId
                     and ComponentTypeCode = N'505')
        begin
            INSERT INTO dbo.AccEngineComponent (Id, GroupId, ComponentTypeCode, ValidationRuleId, [Order], ModifiedBy,
                                                ModifiedDate)
            output inserted.Id into @tempTable
            VALUES (@lastAccEngineComponentId, @fcyRLcyPMaturationGroupId,
                    N'505',
                    null,
                    1,
                    @stateMaker,
                    @stateDate);
            SELECT @fcyRLcyPMaturationGroupComponent1Id = Id FROM @tempTable;
            delete from @tempTable
            select @lastAccEngineComponentId = @lastAccEngineComponentId + 1
        end
    else
        begin
            select @fcyRLcyPMaturationGroupComponent1Id = Id
            from dbo.AccEngineComponent
            where GroupId = @fcyRLcyPMaturationGroupId
              and ComponentTypeCode = N'505'
        end
    if not exists (select 1
                   from dbo.accEngineComponent
                   where GroupId = @fcyRLcyPMaturationGroupId
                     and ComponentTypeCode = N'504')
        begin
            INSERT INTO dbo.AccEngineComponent (Id, GroupId, ComponentTypeCode, ValidationRuleId, [Order], ModifiedBy,
                                                ModifiedDate)
            output inserted.Id into @tempTable
            VALUES (@lastAccEngineComponentId, @fcyRLcyPMaturationGroupId,
                    N'504',
                    null,
                    2,
                    @stateMaker,
                    @stateDate);
            SELECT @fcyRLcyPMaturationGroupComponent2Id = Id FROM @tempTable;
            delete from @tempTable
            select @lastAccEngineComponentId = @lastAccEngineComponentId + 1
        end
    else
        begin
            select @fcyRLcyPMaturationGroupComponent2Id = Id
            from dbo.AccEngineComponent
            where GroupId = @fcyRLcyPMaturationGroupId
              and ComponentTypeCode = N'504'
        end
    if not exists (select 1
                   from dbo.accEngineComponent
                   where GroupId = @fcyRLcyPMaturationGroupId
                     and ComponentTypeCode = N'501')
        begin
            INSERT INTO dbo.AccEngineComponent (Id, GroupId, ComponentTypeCode, ValidationRuleId, [Order], ModifiedBy,
                                                ModifiedDate)
            output inserted.Id into @tempTable
            VALUES (@lastAccEngineComponentId, @fcyRLcyPMaturationGroupId,
                    N'501',
                    null,
                    3,
                    @stateMaker,
                    @stateDate);
            SELECT @fcyRLcyPMaturationGroupComponent3Id = Id FROM @tempTable;
            delete from @tempTable
            select @lastAccEngineComponentId = @lastAccEngineComponentId + 1
        end
    else
        begin
            select @fcyRLcyPMaturationGroupComponent3Id = Id
            from dbo.AccEngineComponent
            where GroupId = @fcyRLcyPMaturationGroupId
              and ComponentTypeCode = N'501'
        end
    if not exists (select 1
                   from dbo.accEngineComponent
                   where GroupId = @fcyRLcyPMaturationGroupId
                     and ComponentTypeCode = N'110')
        begin
            INSERT INTO dbo.AccEngineComponent (Id, GroupId, ComponentTypeCode, ValidationRuleId, [Order], ModifiedBy,
                                                ModifiedDate)
            output inserted.Id into @tempTable
            VALUES (@lastAccEngineComponentId, @fcyRLcyPMaturationGroupId,
                    N'110',
                    null,
                    4,
                    @stateMaker,
                    @stateDate);
            SELECT @fcyRLcyPMaturationGroupComponent4Id = Id FROM @tempTable;
            delete from @tempTable
            select @lastAccEngineComponentId = @lastAccEngineComponentId + 1
        end
    else
        begin
            select @fcyRLcyPMaturationGroupComponent4Id = Id
            from dbo.AccEngineComponent
            where GroupId = @fcyRLcyPMaturationGroupId
              and ComponentTypeCode = N'110'
        end
    ------------------------------------------------------------------------------------------------------------------------
    -- Accounting Engine Component FCYRFCYP
    ------------------------------------------------------------------------------------------------------------------------
    if not exists (select 1
                   from dbo.accEngineComponent
                   where GroupId = @fcyRFcyPOpeningGroup1Id
                     and ComponentTypeCode = N'500')
        begin
            INSERT INTO dbo.AccEngineComponent (Id, GroupId, ComponentTypeCode, ValidationRuleId, [Order],
                                                ModifiedBy,
                                                ModifiedDate)
            output inserted.Id into @tempTable
            VALUES (@lastAccEngineComponentId, @fcyRFcyPOpeningGroup1Id, N'500',
                    null,
                    1,
                    @stateMaker,
                    @stateDate);
            SELECT @fcyRFcyPOpeningGroup1Component1Id = Id FROM @tempTable;
            delete from @tempTable
            select @lastAccEngineComponentId = @lastAccEngineComponentId + 1
        end
    else
        begin
            select @fcyRFcyPOpeningGroup1Component1Id = Id
            from dbo.AccEngineComponent
            where GroupId = @fcyRFcyPOpeningGroup1Id
              and ComponentTypeCode = N'500'
        end
    if not exists (select 1
                   from dbo.accEngineComponent
                   where GroupId = @fcyRFcyPOpeningGroup1Id
                     and ComponentTypeCode = N'501')
        begin
            INSERT INTO dbo.AccEngineComponent (Id, GroupId, ComponentTypeCode, ValidationRuleId, [Order],
                                                ModifiedBy,
                                                ModifiedDate)
            output inserted.Id into @tempTable
            VALUES (@lastAccEngineComponentId, @fcyRFcyPOpeningGroup1Id, N'501',
                    null,
                    2,
                    @stateMaker,
                    @stateDate);
            SELECT @fcyRFcyPOpeningGroup1Component2Id = Id FROM @tempTable;
            delete from @tempTable
            select @lastAccEngineComponentId = @lastAccEngineComponentId + 1
        end
    else
        begin
            select @fcyRFcyPOpeningGroup1Component2Id = Id
            from dbo.AccEngineComponent
            where GroupId = @fcyRFcyPOpeningGroup1Id
              and ComponentTypeCode = N'501'
        end
    if not exists (select 1
                   from dbo.accEngineComponent
                   where GroupId = @fcyRFcyPOpeningGroup2Id
                     and ComponentTypeCode = N'503')
        begin
            INSERT INTO dbo.AccEngineComponent (Id, GroupId, ComponentTypeCode, ValidationRuleId, [Order], ModifiedBy,
                                                ModifiedDate)
            output inserted.Id into @tempTable
            VALUES (@lastAccEngineComponentId, @fcyRFcyPOpeningGroup2Id, N'503', null,
                    1,
                    @stateMaker,
                    @stateDate);
            SELECT @fcyRFcyPOpeningGroup2Component1Id = Id FROM @tempTable;
            delete from @tempTable
            select @lastAccEngineComponentId = @lastAccEngineComponentId + 1
        end
    else
        begin
            select @fcyRFcyPOpeningGroup2Component1Id = Id
            from dbo.AccEngineComponent
            where GroupId = @fcyRFcyPOpeningGroup2Id
              and ComponentTypeCode = N'503'
        end
    if not exists (select 1
                   from dbo.accEngineComponent
                   where GroupId = @fcyRFcyPOpeningGroup2Id
                     and ComponentTypeCode = N'502')
        begin
            INSERT INTO dbo.AccEngineComponent (Id, GroupId, ComponentTypeCode, ValidationRuleId, [Order], ModifiedBy,
                                                ModifiedDate)
            output inserted.Id into @tempTable
            VALUES (@lastAccEngineComponentId, @fcyRFcyPOpeningGroup2Id, N'502', null,
                    2,
                    @stateMaker,
                    @stateDate);
            SELECT @fcyRFcyPOpeningGroup2Component2Id = Id FROM @tempTable;
            delete from @tempTable
            select @lastAccEngineComponentId = @lastAccEngineComponentId + 1
        end
    else
        begin
            select @fcyRFcyPOpeningGroup2Component2Id = Id
            from dbo.AccEngineComponent
            where GroupId = @fcyRFcyPOpeningGroup2Id
              and ComponentTypeCode = N'502'
        end
    if not exists (select 1
                   from dbo.accEngineComponent
                   where GroupId = @fcyRFcyPOpeningGroup2Id
                     and ComponentTypeCode = N'500')
        begin
            INSERT INTO dbo.AccEngineComponent (Id, GroupId, ComponentTypeCode, ValidationRuleId, [Order], ModifiedBy,
                                                ModifiedDate)
            output inserted.Id into @tempTable
            VALUES (@lastAccEngineComponentId, @fcyRFcyPOpeningGroup2Id, N'500',
                    @dynamicRuleValueDateGreaterThanTradeDateId,
                    3,
                    @stateMaker,
                    @stateDate);
            SELECT @fcyRFcyPOpeningGroup2Component3Id = Id FROM @tempTable;
            delete from @tempTable
            select @lastAccEngineComponentId = @lastAccEngineComponentId + 1
        end
    else
        begin
            select @fcyRFcyPOpeningGroup2Component3Id = Id
            from dbo.AccEngineComponent
            where GroupId = @fcyRFcyPOpeningGroup2Id
              and ComponentTypeCode = N'500'
        end
    if not exists (select 1
                   from dbo.accEngineComponent
                   where GroupId = @fcyRFcyPOpeningGroup2Id
                     and ComponentTypeCode = N'501')
        begin
            INSERT INTO dbo.AccEngineComponent (Id, GroupId, ComponentTypeCode, ValidationRuleId, [Order], ModifiedBy,
                                                ModifiedDate)
            output inserted.Id into @tempTable
            VALUES (@lastAccEngineComponentId, @fcyRFcyPOpeningGroup2Id, N'501',
                    @dynamicRuleValueDateLessThanOrEqualTradeDateId,
                    4,
                    @stateMaker,
                    @stateDate);
            SELECT @fcyRFcyPOpeningGroup2Component4Id = Id FROM @tempTable;
            delete from @tempTable
            select @lastAccEngineComponentId = @lastAccEngineComponentId + 1
        end
    else
        begin
            select @fcyRFcyPOpeningGroup2Component4Id = Id
            from dbo.AccEngineComponent
            where GroupId = @fcyRFcyPOpeningGroup2Id
              and ComponentTypeCode = N'501'
        end
    if not exists (select 1
                   from dbo.accEngineComponent
                   where GroupId = @fcyRFcyPRevaluationGroupId
                     and ComponentTypeCode = N'508')
        begin
            INSERT INTO dbo.AccEngineComponent (Id, GroupId, ComponentTypeCode, ValidationRuleId, [Order], ModifiedBy,
                                                ModifiedDate)
            output inserted.Id into @tempTable
            VALUES (@lastAccEngineComponentId, @fcyRFcyPRevaluationGroupId, N'508',
                    @dynamicRuleDerivativeSwapMTMProfitId,
                    1,
                    @stateMaker,
                    @stateDate);
            SELECT @fcyRFcyPRevaluationGroupComponent1Id = Id FROM @tempTable;
            delete from @tempTable
            select @lastAccEngineComponentId = @lastAccEngineComponentId + 1
        end
    else
        begin
            select @fcyRFcyPRevaluationGroupComponent1Id = Id
            from dbo.AccEngineComponent
            where GroupId = @fcyRFcyPRevaluationGroupId
              and ComponentTypeCode = N'508'
        end
    if not exists (select 1
                   from dbo.accEngineComponent
                   where GroupId = @fcyRFcyPRevaluationGroupId
                     and ComponentTypeCode = N'509')
        begin
            INSERT INTO dbo.AccEngineComponent (Id, GroupId, ComponentTypeCode, ValidationRuleId, [Order], ModifiedBy,
                                                ModifiedDate)
            output inserted.Id into @tempTable
            VALUES (@lastAccEngineComponentId, @fcyRFcyPRevaluationGroupId,
                    N'509',
                    @dynamicRuleDerivativeSwapMTMLossId,
                    2,
                    @stateMaker,
                    @stateDate);
            SELECT @fcyRFcyPRevaluationGroupComponent2Id = Id FROM @tempTable;
            delete from @tempTable
            select @lastAccEngineComponentId = @lastAccEngineComponentId + 1
        end
    else
        begin
            select @fcyRFcyPRevaluationGroupComponent2Id = Id
            from dbo.AccEngineComponent
            where GroupId = @fcyRFcyPRevaluationGroupId
              and ComponentTypeCode = N'509'
        end
    if not exists (select 1
                   from dbo.accEngineComponent
                   where GroupId = @fcyRFcyPPaymentGroupId
                     and ComponentTypeCode = N'506')
        begin
            INSERT INTO dbo.AccEngineComponent (Id, GroupId, ComponentTypeCode, ValidationRuleId, [Order], ModifiedBy,
                                                ModifiedDate)
            output inserted.Id into @tempTable
            VALUES (@lastAccEngineComponentId, @fcyRFcyPPaymentGroupId,
                    N'506',
                    @dynamicRuleReceivePeriodEndDateEqualsLogicalDateId,
                    1,
                    @stateMaker,
                    @stateDate);
            SELECT @fcyRFcyPPaymentGroupComponent1Id = Id FROM @tempTable;
            delete from @tempTable
            select @lastAccEngineComponentId = @lastAccEngineComponentId + 1
        end
    else
        begin
            select @fcyRFcyPPaymentGroupComponent1Id = Id
            from dbo.AccEngineComponent
            where GroupId = @fcyRFcyPPaymentGroupId
              and ComponentTypeCode = N'506'
        end
    if not exists (select 1
                   from dbo.accEngineComponent
                   where GroupId = @fcyRFcyPPaymentGroupId
                     and ComponentTypeCode = N'507')
        begin
            INSERT INTO dbo.AccEngineComponent (Id, GroupId, ComponentTypeCode, ValidationRuleId, [Order], ModifiedBy,
                                                ModifiedDate)
            output inserted.Id into @tempTable
            VALUES (@lastAccEngineComponentId, @fcyRFcyPPaymentGroupId,
                    N'507',
                    @dynamicRulePayPeriodEndDateEqualsLogicalDateId,
                    2,
                    @stateMaker,
                    @stateDate);
            SELECT @fcyRFcyPPaymentGroupComponent2Id = Id FROM @tempTable;
            delete from @tempTable
            select @lastAccEngineComponentId = @lastAccEngineComponentId + 1
        end
    else
        begin
            select @fcyRFcyPPaymentGroupComponent2Id = Id
            from dbo.AccEngineComponent
            where GroupId = @fcyRFcyPPaymentGroupId
              and ComponentTypeCode = N'507'
        end
    if not exists (select 1
                   from dbo.accEngineComponent
                   where GroupId = @fcyRFcyPMaturationGroupId
                     and ComponentTypeCode = N'505')
        begin
            INSERT INTO dbo.AccEngineComponent (Id, GroupId, ComponentTypeCode, ValidationRuleId, [Order], ModifiedBy,
                                                ModifiedDate)
            output inserted.Id into @tempTable
            VALUES (@lastAccEngineComponentId, @fcyRFcyPMaturationGroupId,
                    N'505',
                    null,
                    1,
                    @stateMaker,
                    @stateDate);
            SELECT @fcyRFcyPMaturationGroupComponent1Id = Id FROM @tempTable;
            delete from @tempTable
            select @lastAccEngineComponentId = @lastAccEngineComponentId + 1
        end
    else
        begin
            select @fcyRFcyPMaturationGroupComponent1Id = Id
            from dbo.AccEngineComponent
            where GroupId = @fcyRFcyPMaturationGroupId
              and ComponentTypeCode = N'505'
        end
    if not exists (select 1
                   from dbo.accEngineComponent
                   where GroupId = @fcyRFcyPMaturationGroupId
                     and ComponentTypeCode = N'504')
        begin
            INSERT INTO dbo.AccEngineComponent (Id, GroupId, ComponentTypeCode, ValidationRuleId, [Order], ModifiedBy,
                                                ModifiedDate)
            output inserted.Id into @tempTable
            VALUES (@lastAccEngineComponentId, @fcyRFcyPMaturationGroupId,
                    N'504',
                    null,
                    2,
                    @stateMaker,
                    @stateDate);
            SELECT @fcyRFcyPMaturationGroupComponent2Id = Id FROM @tempTable;
            delete from @tempTable
            select @lastAccEngineComponentId = @lastAccEngineComponentId + 1
        end
    else
        begin
            select @fcyRFcyPMaturationGroupComponent2Id = Id
            from dbo.AccEngineComponent
            where GroupId = @fcyRFcyPMaturationGroupId
              and ComponentTypeCode = N'504'
        end
    if not exists (select 1
                   from dbo.accEngineComponent
                   where GroupId = @fcyRFcyPMaturationGroupId
                     and ComponentTypeCode = N'501')
        begin
            INSERT INTO dbo.AccEngineComponent (Id, GroupId, ComponentTypeCode, ValidationRuleId, [Order], ModifiedBy,
                                                ModifiedDate)
            output inserted.Id into @tempTable
            VALUES (@lastAccEngineComponentId, @fcyRFcyPMaturationGroupId,
                    N'501',
                    null,
                    3,
                    @stateMaker,
                    @stateDate);
            SELECT @fcyRFcyPMaturationGroupComponent3Id = Id FROM @tempTable;
            delete from @tempTable
            select @lastAccEngineComponentId = @lastAccEngineComponentId + 1
        end
    else
        begin
            select @fcyRFcyPMaturationGroupComponent3Id = Id
            from dbo.AccEngineComponent
            where GroupId = @fcyRFcyPMaturationGroupId
              and ComponentTypeCode = N'501'
        end
    if not exists (select 1
                   from dbo.accEngineComponent
                   where GroupId = @fcyRFcyPMaturationGroupId
                     and ComponentTypeCode = N'110')
        begin
            INSERT INTO dbo.AccEngineComponent (Id, GroupId, ComponentTypeCode, ValidationRuleId, [Order], ModifiedBy,
                                                ModifiedDate)
            output inserted.Id into @tempTable
            VALUES (@lastAccEngineComponentId, @fcyRFcyPMaturationGroupId,
                    N'110',
                    null,
                    4,
                    @stateMaker,
                    @stateDate);
            SELECT @fcyRFcyPMaturationGroupComponent4Id = Id FROM @tempTable;
            delete from @tempTable
            select @lastAccEngineComponentId = @lastAccEngineComponentId + 1
        end
    else
        begin
            select @fcyRFcyPMaturationGroupComponent4Id = Id
            from dbo.AccEngineComponent
            where GroupId = @fcyRFcyPMaturationGroupId
              and ComponentTypeCode = N'110'
        end
    --#endregion
    ------------------------------------------------------------------------------------------------------------------------
    -- Accounting Engine Rule
    ------------------------------------------------------------------------------------------------------------------------
--#region AccEngineAccountRule
    ------------------------------------------------------------------------------------------------------------------------
    -- Accounting Engine Rule LCYRFCYP
    ------------------------------------------------------------------------------------------------------------------------
    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @lcyRFcyPOpeningGroup1Component1Id
                    and GLCode = N'ValPayContingent')
        begin
            INSERT INTO dbo.AccEngineAccountRule(Id, ComponentId, GLCode, CustomerCodeSource, CustomerAccountCodeSource,
                                                 DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                 ValueDateSource, TxnDateSource, CcySource, FcySource, LcyEqvtSource,
                                                 FcyAmtSource, ReverseRebook, CommentSource, CommentRuleId, ModifiedBy,
                                                 ModifiedDate, ReverseTxnDateSource, ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @lcyRFcyPOpeningGroup1Component1Id, N'ValPayContingent', null, null,
                    N'Debit', null, N'PayPrincipalAmount', N'TxnNo', N'LogicalDate', N'LogicalDate', N'PayCurrency',
                    N'PayCurrency', N'PayPrincipalAmount', N'PayPrincipalAmount', 0, null, null, @stateMaker,
                    @stateDate, null, null);

            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @lcyRFcyPOpeningGroup1Component1Id
                    and GLCode = N'ValPayContingentOffset')
        begin
            INSERT INTO dbo.AccEngineAccountRule(Id, ComponentId, GLCode, CustomerCodeSource, CustomerAccountCodeSource,
                                                 DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                 ValueDateSource, TxnDateSource, CcySource, FcySource, LcyEqvtSource,
                                                 FcyAmtSource, ReverseRebook, CommentSource, CommentRuleId, ModifiedBy,
                                                 ModifiedDate, ReverseTxnDateSource, ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @lcyRFcyPOpeningGroup1Component1Id, N'ValPayContingentOffset', null,
                    null, N'Credit', null, N'PayPrincipalAmount', N'TxnNo', N'LogicalDate', N'LogicalDate',
                    N'PayCurrency', N'PayCurrency', N'PayPrincipalAmount', N'PayPrincipalAmount', 0, null, null,
                    @stateMaker, @stateDate, null, null);

            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @lcyRFcyPOpeningGroup1Component1Id
                    and GLCode = N'ValRecContingentOffset')
        begin
            INSERT INTO dbo.AccEngineAccountRule(Id, ComponentId, GLCode, CustomerCodeSource, CustomerAccountCodeSource,
                                                 DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                 ValueDateSource, TxnDateSource, CcySource, FcySource, LcyEqvtSource,
                                                 FcyAmtSource, ReverseRebook, CommentSource, CommentRuleId, ModifiedBy,
                                                 ModifiedDate, ReverseTxnDateSource, ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @lcyRFcyPOpeningGroup1Component1Id, N'ValRecContingentOffset', null,
                    null, N'Debit', null, N'ReceivePrincipalAmount', N'TxnNo', N'LogicalDate', N'LogicalDate',
                    N'ReceiveCurrency', N'ReceiveCurrency', N'ReceivePrincipalAmount', N'ReceivePrincipalAmount', 0,
                    null, null, @stateMaker, @stateDate, null, null);

            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @lcyRFcyPOpeningGroup1Component1Id
                    and GLCode = N'ValRecContingent')
        begin
            INSERT INTO dbo.AccEngineAccountRule(Id, ComponentId, GLCode, CustomerCodeSource, CustomerAccountCodeSource,
                                                 DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                 ValueDateSource, TxnDateSource, CcySource, FcySource, LcyEqvtSource,
                                                 FcyAmtSource, ReverseRebook, CommentSource, CommentRuleId, ModifiedBy,
                                                 ModifiedDate, ReverseTxnDateSource, ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @lcyRFcyPOpeningGroup1Component1Id, N'ValRecContingent', null, null,
                    N'Credit', null, N'ReceivePrincipalAmount', N'TxnNo', N'LogicalDate', N'LogicalDate',
                    N'ReceiveCurrency', N'ReceiveCurrency', N'ReceivePrincipalAmount', N'ReceivePrincipalAmount', 0,
                    null, null, @stateMaker, @stateDate, null, null);

            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @lcyRFcyPOpeningGroup1Component2Id
                    and GLCode = N'MatPayContingentOffset')
        begin
            INSERT INTO dbo.accEngineAccountRule(Id, ComponentId, GLCode, CustomerCodeSource, CustomerAccountCodeSource,
                                                 DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                 ValueDateSource, TxnDateSource, CcySource, FcySource, LcyEqvtSource,
                                                 FcyAmtSource, ReverseRebook, CommentSource, CommentRuleId, ModifiedBy,
                                                 ModifiedDate, ReverseTxnDateSource, ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @lcyRFcyPOpeningGroup1Component2Id, N'MatPayContingentOffset', null,
                    null, N'Debit', null, N'PayPrincipalAmount', N'TxnNo', N'PayValueDate', N'PayValueDate',
                    N'PayCurrency', N'PayCurrency', N'PayPrincipalAmount', N'PayPrincipalAmount', 0, null, null,
                    @stateMaker, @stateDate, null, null);

            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @lcyRFcyPOpeningGroup1Component2Id
                    and GLCode = N'MatPayContingent')
        begin
            INSERT INTO dbo.accEngineAccountRule(Id, ComponentId, GLCode, CustomerCodeSource, CustomerAccountCodeSource,
                                                 DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                 ValueDateSource, TxnDateSource, CcySource, FcySource, LcyEqvtSource,
                                                 FcyAmtSource, ReverseRebook, CommentSource, CommentRuleId, ModifiedBy,
                                                 ModifiedDate, ReverseTxnDateSource, ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @lcyRFcyPOpeningGroup1Component2Id, N'MatPayContingent', null, null,
                    N'Credit', null, N'PayPrincipalAmount', N'TxnNo', N'PayValueDate', N'PayValueDate', N'PayCurrency',
                    N'PayCurrency', N'PayPrincipalAmount', N'PayPrincipalAmount', 0, null, null, @stateMaker,
                    @stateDate, null, null);

            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @lcyRFcyPOpeningGroup1Component2Id
                    and GLCode = N'MatRecContingent')
        begin
            INSERT INTO dbo.accEngineAccountRule(Id, ComponentId, GLCode, CustomerCodeSource, CustomerAccountCodeSource,
                                                 DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                 ValueDateSource, TxnDateSource, CcySource, FcySource, LcyEqvtSource,
                                                 FcyAmtSource, ReverseRebook, CommentSource, CommentRuleId, ModifiedBy,
                                                 ModifiedDate, ReverseTxnDateSource, ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @lcyRFcyPOpeningGroup1Component2Id, N'MatRecContingent', null, null,
                    N'Debit', null, N'ReceivePrincipalAmount', N'TxnNo', N'LogicalDate', N'LogicalDate',
                    N'ReceiveCurrency', N'ReceiveCurrency', N'ReceivePrincipalAmount', N'ReceivePrincipalAmount', 0,
                    null, null, @stateMaker, @stateDate, null, null);

            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @lcyRFcyPOpeningGroup1Component2Id
                    and GLCode = N'MatRecContingentOffset')
        begin
            INSERT INTO dbo.accEngineAccountRule(Id, ComponentId, GLCode, CustomerCodeSource, CustomerAccountCodeSource,
                                                 DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                 ValueDateSource, TxnDateSource, CcySource, FcySource, LcyEqvtSource,
                                                 FcyAmtSource, ReverseRebook, CommentSource, CommentRuleId, ModifiedBy,
                                                 ModifiedDate, ReverseTxnDateSource, ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @lcyRFcyPOpeningGroup1Component2Id, N'MatRecContingentOffset', null,
                    null, N'Credit', null, N'ReceivePrincipalAmount', N'TxnNo', N'LogicalDate', N'LogicalDate',
                    N'ReceiveCurrency', N'ReceiveCurrency', N'ReceivePrincipalAmount', N'ReceivePrincipalAmount', 0,
                    null, null, @stateMaker, @stateDate, null, null);

            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @lcyRFcyPOpeningGroup2Component1Id
                    and GLCode = N'ValRecPrincipal')
        begin
            INSERT INTO dbo.accEngineAccountRule(Id, ComponentId, GLCode, CustomerCodeSource, CustomerAccountCodeSource,
                                                 DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                 ValueDateSource, TxnDateSource, CcySource, FcySource, LcyEqvtSource,
                                                 FcyAmtSource, ReverseRebook, CommentSource, CommentRuleId, ModifiedBy,
                                                 ModifiedDate, ReverseTxnDateSource, ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @lcyRFcyPOpeningGroup2Component1Id, N'ValRecPrincipal', null, null,
                    N'Credit', null, N'ReceivePrincipalAmount', N'TxnNo', N'LogicalDate', N'LogicalDate',
                    N'ReceiveCurrency', N'ReceiveCurrency', N'ReceivePrincipalAmount', N'ReceivePrincipalAmount', 0,
                    null, null, @stateMaker, @stateDate, null, null);

            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @lcyRFcyPOpeningGroup2Component2Id
                    and GLCode = N'ValPayPrincipal')
        begin
            INSERT INTO dbo.accEngineAccountRule(Id, ComponentId, GLCode, CustomerCodeSource, CustomerAccountCodeSource,
                                                 DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                 ValueDateSource, TxnDateSource, CcySource, FcySource, LcyEqvtSource,
                                                 FcyAmtSource, ReverseRebook, CommentSource, CommentRuleId, ModifiedBy,
                                                 ModifiedDate, ReverseTxnDateSource, ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @lcyRFcyPOpeningGroup2Component2Id, N'ValPayPrincipal', null, null,
                    N'Debit', null, N'PayPrincipalAmount', N'TxnNo', N'LogicalDate', N'LogicalDate', N'PayCurrency',
                    N'PayCurrency', N'PayPrincipalAmount', N'PayPrincipalAmount', 0, null, null, @stateMaker,
                    @stateDate, null, null);

            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @lcyRFcyPOpeningGroup2Component2Id
                    and GLCode = N'FXPositionPay')
        begin
            INSERT INTO dbo.accEngineAccountRule(Id, ComponentId, GLCode, CustomerCodeSource, CustomerAccountCodeSource,
                                                 DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                 ValueDateSource, TxnDateSource, CcySource, FcySource, LcyEqvtSource,
                                                 FcyAmtSource, ReverseRebook, CommentSource, CommentRuleId, ModifiedBy,
                                                 ModifiedDate, ReverseTxnDateSource, ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @lcyRFcyPOpeningGroup2Component2Id, N'FXPositionPay', null, null,
                    N'Credit', null, N'PayPrincipalAmount', N'TxnNo', N'LogicalDate', N'LogicalDate', N'PayCurrency',
                    N'PayCurrency', N'PayPrincipalAmount', N'PayPrincipalAmount', 0, null, null, @stateMaker,
                    @stateDate, null, null);

            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @lcyRFcyPOpeningGroup2Component2Id
                    and GLCode = N'FXPositionLCY')
        begin
            INSERT INTO dbo.accEngineAccountRule(Id, ComponentId, GLCode, CustomerCodeSource, CustomerAccountCodeSource,
                                                 DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                 ValueDateSource, TxnDateSource, CcySource, FcySource, LcyEqvtSource,
                                                 FcyAmtSource, ReverseRebook, CommentSource, CommentRuleId, ModifiedBy,
                                                 ModifiedDate, ReverseTxnDateSource, ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @lcyRFcyPOpeningGroup2Component2Id, N'FXPositionLCY', null, null,
                    N'Debit', null, N'ReceivePrincipalAmount', N'TxnNo', N'LogicalDate', N'LogicalDate', N'LocalCCY',
                    N'PayCurrency', N'ReceivePrincipalAmount', N'ReceivePrincipalAmount', 0, null, null, @stateMaker,
                    @stateDate, null, null);

            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @lcyRFcyPOpeningGroup2Component3Id
                    and GLCode = N'ValPayContingentOffset')
        begin
            INSERT INTO dbo.accEngineAccountRule(Id, ComponentId, GLCode, CustomerCodeSource, CustomerAccountCodeSource,
                                                 DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                 ValueDateSource, TxnDateSource, CcySource, FcySource, LcyEqvtSource,
                                                 FcyAmtSource, ReverseRebook, CommentSource, CommentRuleId, ModifiedBy,
                                                 ModifiedDate, ReverseTxnDateSource, ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @lcyRFcyPOpeningGroup2Component3Id, N'ValPayContingentOffset', null,
                    null, N'Debit', null, N'PayPrincipalAmount', N'TxnNo', N'LogicalDate', N'LogicalDate',
                    N'PayCurrency', N'PayCurrency', N'PayPrincipalAmount', N'PayPrincipalAmount', 0, null, null,
                    @stateMaker, @stateDate, null, null);

            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @lcyRFcyPOpeningGroup2Component3Id
                    and GLCode = N'ValPayContingent')
        begin
            INSERT INTO dbo.accEngineAccountRule(Id, ComponentId, GLCode, CustomerCodeSource, CustomerAccountCodeSource,
                                                 DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                 ValueDateSource, TxnDateSource, CcySource, FcySource, LcyEqvtSource,
                                                 FcyAmtSource, ReverseRebook, CommentSource, CommentRuleId, ModifiedBy,
                                                 ModifiedDate, ReverseTxnDateSource, ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @lcyRFcyPOpeningGroup2Component3Id, N'ValPayContingent', null, null,
                    N'Credit', null, N'PayPrincipalAmount', N'TxnNo', N'LogicalDate', N'LogicalDate', N'PayCurrency',
                    N'PayCurrency', N'PayPrincipalAmount', N'PayPrincipalAmount', 0, null, null, @stateMaker,
                    @stateDate, null, null);

            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @lcyRFcyPOpeningGroup2Component3Id
                    and GLCode = N'ValRecContingent')
        begin
            INSERT INTO dbo.accEngineAccountRule(Id, ComponentId, GLCode, CustomerCodeSource, CustomerAccountCodeSource,
                                                 DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                 ValueDateSource, TxnDateSource, CcySource, FcySource, LcyEqvtSource,
                                                 FcyAmtSource, ReverseRebook, CommentSource, CommentRuleId, ModifiedBy,
                                                 ModifiedDate, ReverseTxnDateSource, ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @lcyRFcyPOpeningGroup2Component3Id, N'ValRecContingent', null, null,
                    N'Debit', null, N'ReceivePrincipalAmount', N'TxnNo', N'LogicalDate', N'LogicalDate',
                    N'ReceiveCurrency', N'ReceiveCurrency', N'ReceivePrincipalAmount', N'ReceivePrincipalAmount', 0,
                    null, null, @stateMaker, @stateDate, null, null);

            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @lcyRFcyPOpeningGroup2Component3Id
                    and GLCode = N'ValRecContingentOffset')
        begin
            INSERT INTO dbo.accEngineAccountRule(Id, ComponentId, GLCode, CustomerCodeSource, CustomerAccountCodeSource,
                                                 DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                 ValueDateSource, TxnDateSource, CcySource, FcySource, LcyEqvtSource,
                                                 FcyAmtSource, ReverseRebook, CommentSource, CommentRuleId, ModifiedBy,
                                                 ModifiedDate, ReverseTxnDateSource, ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @lcyRFcyPOpeningGroup2Component3Id, N'ValRecContingentOffset', null,
                    null, N'Credit', null, N'ReceivePrincipalAmount', N'TxnNo', N'LogicalDate', N'LogicalDate',
                    N'ReceiveCurrency', N'ReceiveCurrency', N'ReceivePrincipalAmount', N'ReceivePrincipalAmount', 0,
                    null, null, @stateMaker, @stateDate, null, null);

            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @lcyRFcyPOpeningGroup2Component4Id
                    and GLCode = N'MatPayContingentOffset')
        begin
            INSERT INTO dbo.accEngineAccountRule(Id, ComponentId, GLCode, CustomerCodeSource, CustomerAccountCodeSource,
                                                 DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                 ValueDateSource, TxnDateSource, CcySource, FcySource, LcyEqvtSource,
                                                 FcyAmtSource, ReverseRebook, CommentSource, CommentRuleId, ModifiedBy,
                                                 ModifiedDate, ReverseTxnDateSource, ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @lcyRFcyPOpeningGroup2Component4Id, N'MatPayContingentOffset', null,
                    null, N'Debit', null, N'PayPrincipalAmount', N'TxnNo', N'LogicalDate', N'LogicalDate',
                    N'PayCurrency', N'PayCurrency', N'PayPrincipalAmount', N'PayPrincipalAmount', 0, null, null,
                    @stateMaker, @stateDate, null, null);

            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @lcyRFcyPOpeningGroup2Component4Id
                    and GLCode = N'MatPayContingent')
        begin
            INSERT INTO dbo.accEngineAccountRule(Id, ComponentId, GLCode, CustomerCodeSource, CustomerAccountCodeSource,
                                                 DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                 ValueDateSource, TxnDateSource, CcySource, FcySource, LcyEqvtSource,
                                                 FcyAmtSource, ReverseRebook, CommentSource, CommentRuleId, ModifiedBy,
                                                 ModifiedDate, ReverseTxnDateSource, ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @lcyRFcyPOpeningGroup2Component4Id, N'MatPayContingent', null, null,
                    N'Credit', null, N'PayPrincipalAmount', N'TxnNo', N'LogicalDate', N'LogicalDate', N'PayCurrency',
                    N'PayCurrency', N'PayPrincipalAmount', N'PayPrincipalAmount', 0, null, null, @stateMaker,
                    @stateDate, null, null);

            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @lcyRFcyPOpeningGroup2Component4Id
                    and GLCode = N'MatRecContingent')
        begin
            INSERT INTO dbo.accEngineAccountRule(Id, ComponentId, GLCode, CustomerCodeSource, CustomerAccountCodeSource,
                                                 DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                 ValueDateSource, TxnDateSource, CcySource, FcySource, LcyEqvtSource,
                                                 FcyAmtSource, ReverseRebook, CommentSource, CommentRuleId, ModifiedBy,
                                                 ModifiedDate, ReverseTxnDateSource, ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @lcyRFcyPOpeningGroup2Component4Id, N'MatRecContingent', null, null,
                    N'Debit', null, N'ReceivePrincipalAmount', N'TxnNo', N'LogicalDate', N'LogicalDate',
                    N'ReceiveCurrency', N'ReceiveCurrency', N'ReceivePrincipalAmount', N'ReceivePrincipalAmount', 0,
                    null, null, @stateMaker, @stateDate, null, null);

            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @lcyRFcyPOpeningGroup2Component4Id
                    and GLCode = N'MatRecContingentOffset')
        begin
            INSERT INTO dbo.accEngineAccountRule(Id, ComponentId, GLCode, CustomerCodeSource, CustomerAccountCodeSource,
                                                 DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                 ValueDateSource, TxnDateSource, CcySource, FcySource, LcyEqvtSource,
                                                 FcyAmtSource, ReverseRebook, CommentSource, CommentRuleId, ModifiedBy,
                                                 ModifiedDate, ReverseTxnDateSource, ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @lcyRFcyPOpeningGroup2Component4Id, N'MatRecContingentOffset', null,
                    null, N'Credit', null, N'ReceivePrincipalAmount', N'TxnNo', N'LogicalDate', N'LogicalDate',
                    N'ReceiveCurrency', N'ReceiveCurrency', N'ReceivePrincipalAmount', N'ReceivePrincipalAmount', 0,
                    null, null, @stateMaker, @stateDate, null, null);

            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @lcyRFcyPRevaluationGroupComponent1Id
                    and GLCode = N'TotalMTMProfit')
        begin
            INSERT INTO dbo.accEngineAccountRule(Id, ComponentId, GLCode, CustomerCodeSource, CustomerAccountCodeSource,
                                                 DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                 ValueDateSource, TxnDateSource, CcySource, FcySource, LcyEqvtSource,
                                                 FcyAmtSource, ReverseRebook, CommentSource, CommentRuleId, ModifiedBy,
                                                 ModifiedDate, ReverseTxnDateSource, ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @lcyRFcyPRevaluationGroupComponent1Id, N'TotalMTMProfit', null, null,
                    N'Debit', null, N'TotalMTMAmount', N'TxnNo', N'LogicalDate', N'LogicalDate', N'TotalMTMAmountCCY',
                    N'TotalMTMAmountCCY', N'TotalMTMAmount', N'TotalMTMAmount', 0, null, null, @stateMaker, @stateDate,
                    null, null);

            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @lcyRFcyPRevaluationGroupComponent1Id
                    and GLCode = N'CapitalGainLCY')
        begin
            INSERT INTO dbo.accEngineAccountRule(Id, ComponentId, GLCode, CustomerCodeSource, CustomerAccountCodeSource,
                                                 DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                 ValueDateSource, TxnDateSource, CcySource, FcySource, LcyEqvtSource,
                                                 FcyAmtSource, ReverseRebook, CommentSource, CommentRuleId, ModifiedBy,
                                                 ModifiedDate, ReverseTxnDateSource, ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @lcyRFcyPRevaluationGroupComponent1Id, N'CapitalGainLCY', null, null,
                    N'Credit', null, N'TotalMTMAmountLCY', N'TxnNo', N'LogicalDate', N'LogicalDate', N'LocalCCY',
                    N'LocalCCY', N'TotalMTMAmountLCY', N'TotalMTMAmountLCY', 0, null, null, @stateMaker, @stateDate,
                    null, null);

            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @lcyRFcyPRevaluationGroupComponent2Id
                    and GLCode = N'TotalMTMLoss')
        begin
            INSERT INTO dbo.accEngineAccountRule(Id, ComponentId, GLCode, CustomerCodeSource, CustomerAccountCodeSource,
                                                 DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                 ValueDateSource, TxnDateSource, CcySource, FcySource, LcyEqvtSource,
                                                 FcyAmtSource, ReverseRebook, CommentSource, CommentRuleId, ModifiedBy,
                                                 ModifiedDate, ReverseTxnDateSource, ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @lcyRFcyPRevaluationGroupComponent2Id, N'TotalMTMLoss', null, null,
                    N'Credit', null, N'TotalMTMAmount', N'TxnNo', N'LogicalDate', N'LogicalDate', N'TotalMTMAmountCCY',
                    N'TotalMTMAmountCCY', N'TotalMTMAmount', N'TotalMTMAmount', 0, null, null, @stateMaker, @stateDate,
                    null, null);

            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @lcyRFcyPRevaluationGroupComponent2Id
                    and GLCode = N'CapitalLossLCY')
        begin
            INSERT INTO dbo.accEngineAccountRule(Id, ComponentId, GLCode, CustomerCodeSource, CustomerAccountCodeSource,
                                                 DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                 ValueDateSource, TxnDateSource, CcySource, FcySource, LcyEqvtSource,
                                                 FcyAmtSource, ReverseRebook, CommentSource, CommentRuleId, ModifiedBy,
                                                 ModifiedDate, ReverseTxnDateSource, ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @lcyRFcyPRevaluationGroupComponent2Id, N'CapitalLossLCY', null, null,
                    N'Debit', null, N'TotalMTMAmountLCY', N'TxnNo', N'LogicalDate', N'LogicalDate', N'LocalCCY',
                    N'LocalCCY', N'TotalMTMAmountLCY', N'TotalMTMAmountLCY', 0, null, null, @stateMaker, @stateDate,
                    null, null);

            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @lcyRFcyPPaymentGroupComponent1Id
                    and GLCode = N'IncomingPaymentLCY')
        begin
            INSERT INTO dbo.accEngineAccountRule(Id, ComponentId, GLCode, CustomerCodeSource, CustomerAccountCodeSource,
                                                 DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                 ValueDateSource, TxnDateSource, CcySource, FcySource, LcyEqvtSource,
                                                 FcyAmtSource, ReverseRebook, CommentSource, CommentRuleId, ModifiedBy,
                                                 ModifiedDate, ReverseTxnDateSource, ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @lcyRFcyPPaymentGroupComponent1Id, N'IncomingPaymentLCY', null, null,
                    N'Debit', null, N'ReceivePeriodAmount', N'TxnNo', N'LogicalDate', N'LogicalDate',
                    N'ReceiveCurrency', N'ReceiveCurrency', N'ReceivePeriodAmount', N'ReceivePeriodAmount', 0, null,
                    null, @stateMaker, @stateDate, null, null);

            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @lcyRFcyPPaymentGroupComponent1Id
                    and GLCode = N'InterestIncome')
        begin
            INSERT INTO dbo.accEngineAccountRule(Id, ComponentId, GLCode, CustomerCodeSource, CustomerAccountCodeSource,
                                                 DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                 ValueDateSource, TxnDateSource, CcySource, FcySource, LcyEqvtSource,
                                                 FcyAmtSource, ReverseRebook, CommentSource, CommentRuleId, ModifiedBy,
                                                 ModifiedDate, ReverseTxnDateSource, ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @lcyRFcyPPaymentGroupComponent1Id, N'InterestIncome', null, null,
                    N'Credit', null, N'ReceivePeriodAmountLCY', N'TxnNo', N'LogicalDate', N'LogicalDate',
                    N'LocalCCY', N'LocalCCY', N'ReceivePeriodAmountLCY', N'ReceivePeriodAmountLCY', 0,
                    null, null, @stateMaker, @stateDate, null, null);

            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @lcyRFcyPPaymentGroupComponent2Id
                    and GLCode = N'FXPositionPay')
        begin
            INSERT INTO dbo.accEngineAccountRule(Id, ComponentId, GLCode, CustomerCodeSource, CustomerAccountCodeSource,
                                                 DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                 ValueDateSource, TxnDateSource, CcySource, FcySource, LcyEqvtSource,
                                                 FcyAmtSource, ReverseRebook, CommentSource, CommentRuleId, ModifiedBy,
                                                 ModifiedDate, ReverseTxnDateSource, ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @lcyRFcyPPaymentGroupComponent2Id, N'FXPositionPay', null, null,
                    N'Debit', null, N'PayPeriodAmount', N'TxnNo', N'LogicalDate', N'LogicalDate', N'PayCurrency',
                    N'PayCurrency', N'PayPeriodAmount', N'PayPeriodAmount', 0, null, null, @stateMaker, @stateDate,
                    null, null);

            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @lcyRFcyPPaymentGroupComponent2Id
                    and GLCode = N'OutgoingPaymentFCY')
        begin
            INSERT INTO dbo.accEngineAccountRule(Id, ComponentId, GLCode, CustomerCodeSource, CustomerAccountCodeSource,
                                                 DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                 ValueDateSource, TxnDateSource, CcySource, FcySource, LcyEqvtSource,
                                                 FcyAmtSource, ReverseRebook, CommentSource, CommentRuleId, ModifiedBy,
                                                 ModifiedDate, ReverseTxnDateSource, ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @lcyRFcyPPaymentGroupComponent2Id, N'OutgoingPaymentFCY', null, null,
                    N'Credit', null, N'PayPeriodAmount', N'TxnNo', N'LogicalDate', N'LogicalDate', N'PayCurrency',
                    N'PayCurrency', N'PayPeriodAmount', N'PayPeriodAmount', 0, null, null, @stateMaker, @stateDate,
                    null, null);

            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @lcyRFcyPPaymentGroupComponent2Id
                    and GLCode = N'InterestExpense')
        begin
            INSERT INTO dbo.accEngineAccountRule(Id, ComponentId, GLCode, CustomerCodeSource, CustomerAccountCodeSource,
                                                 DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                 ValueDateSource, TxnDateSource, CcySource, FcySource, LcyEqvtSource,
                                                 FcyAmtSource, ReverseRebook, CommentSource, CommentRuleId, ModifiedBy,
                                                 ModifiedDate, ReverseTxnDateSource, ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @lcyRFcyPPaymentGroupComponent2Id, N'InterestExpense', null, null,
                    N'Debit', null, N'PayPeriodAmountLCY', N'TxnNo', N'LogicalDate', N'LogicalDate', N'LocalCCY',
                    N'LocalCCY', N'PayPeriodAmountLCY', N'PayPeriodAmountLCY', 0, null, null, @stateMaker,
                    @stateDate, null, null);

            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @lcyRFcyPPaymentGroupComponent2Id
                    and GLCode = N'FXPositionLCY')
        begin
            INSERT INTO dbo.accEngineAccountRule(Id, ComponentId, GLCode, CustomerCodeSource, CustomerAccountCodeSource,
                                                 DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                 ValueDateSource, TxnDateSource, CcySource, FcySource, LcyEqvtSource,
                                                 FcyAmtSource, ReverseRebook, CommentSource, CommentRuleId, ModifiedBy,
                                                 ModifiedDate, ReverseTxnDateSource, ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @lcyRFcyPPaymentGroupComponent2Id, N'FXPositionLCY', null, null,
                    N'Credit', null, N'PayPeriodAmountLCY', N'TxnNo', N'LogicalDate', N'LogicalDate', N'LocalCCY',
                    N'PayCurrency', N'PayPeriodAmountLCY', N'PayPeriodAmountLCY', 0, null, null, @stateMaker, @stateDate,
                    null, null);

            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @lcyRFcyPMaturationGroupComponent1Id
                    and GLCode = N'MatPayPrincipal')
        begin
            INSERT INTO dbo.accEngineAccountRule(Id, ComponentId, GLCode, CustomerCodeSource, CustomerAccountCodeSource,
                                                 DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                 ValueDateSource, TxnDateSource, CcySource, FcySource, LcyEqvtSource,
                                                 FcyAmtSource, ReverseRebook, CommentSource, CommentRuleId, ModifiedBy,
                                                 ModifiedDate, ReverseTxnDateSource, ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @lcyRFcyPMaturationGroupComponent1Id, N'MatPayPrincipal', null, null,
                    N'Credit', null, N'PayPrincipalAmount', N'TxnNo', N'LogicalDate', N'LogicalDate', N'PayCurrency',
                    N'PayCurrency', N'PayPrincipalAmount', N'PayPrincipalAmount', 0, null, null, @stateMaker,
                    @stateDate, null, null);

            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @lcyRFcyPMaturationGroupComponent1Id
                    and GLCode = N'FXPositionPay')
        begin
            INSERT INTO dbo.accEngineAccountRule(Id, ComponentId, GLCode, CustomerCodeSource, CustomerAccountCodeSource,
                                                 DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                 ValueDateSource, TxnDateSource, CcySource, FcySource, LcyEqvtSource,
                                                 FcyAmtSource, ReverseRebook, CommentSource, CommentRuleId, ModifiedBy,
                                                 ModifiedDate, ReverseTxnDateSource, ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @lcyRFcyPMaturationGroupComponent1Id, N'FXPositionPay', null, null,
                    N'Debit', null, N'PayPrincipalAmount', N'TxnNo', N'LogicalDate', N'LogicalDate', N'PayCurrency',
                    N'PayCurrency', N'PayPrincipalAmount', N'PayPrincipalAmount', 0, null, null, @stateMaker,
                    @stateDate, null, null);

            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @lcyRFcyPMaturationGroupComponent1Id
                    and GLCode = N'FXPositionLCY')
        begin
            INSERT INTO dbo.accEngineAccountRule(Id, ComponentId, GLCode, CustomerCodeSource, CustomerAccountCodeSource,
                                                 DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                 ValueDateSource, TxnDateSource, CcySource, FcySource, LcyEqvtSource,
                                                 FcyAmtSource, ReverseRebook, CommentSource, CommentRuleId, ModifiedBy,
                                                 ModifiedDate, ReverseTxnDateSource, ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @lcyRFcyPMaturationGroupComponent1Id, N'FXPositionLCY', null, null,
                    N'Credit', null, N'ReceivePrincipalAmount', N'TxnNo', N'LogicalDate', N'LogicalDate', N'LocalCCY',
                    N'PayCurrency', N'ReceivePrincipalAmount', N'ReceivePrincipalAmount', 0, null, null, @stateMaker,
                    @stateDate, null, null);

            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @lcyRFcyPMaturationGroupComponent3Id
                    and GLCode = N'MatPayContingentOffset')
        begin
            INSERT INTO dbo.accEngineAccountRule(Id, ComponentId, GLCode, CustomerCodeSource, CustomerAccountCodeSource,
                                                 DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                 ValueDateSource, TxnDateSource, CcySource, FcySource, LcyEqvtSource,
                                                 FcyAmtSource, ReverseRebook, CommentSource, CommentRuleId, ModifiedBy,
                                                 ModifiedDate, ReverseTxnDateSource, ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @lcyRFcyPMaturationGroupComponent3Id, N'MatPayContingentOffset', null,
                    null, N'Credit', null, N'PayPrincipalAmount', N'TxnNo', N'LogicalDate', N'LogicalDate',
                    N'PayCurrency', N'PayCurrency', N'PayPrincipalAmount', N'PayPrincipalAmount', 0, null, null,
                    @stateMaker, @stateDate, null, null);

            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @lcyRFcyPMaturationGroupComponent2Id
                    and GLCode = N'MatRecPrincipal')
        begin
            INSERT INTO dbo.accEngineAccountRule(Id, ComponentId, GLCode, CustomerCodeSource, CustomerAccountCodeSource,
                                                 DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                 ValueDateSource, TxnDateSource, CcySource, FcySource, LcyEqvtSource,
                                                 FcyAmtSource, ReverseRebook, CommentSource, CommentRuleId, ModifiedBy,
                                                 ModifiedDate, ReverseTxnDateSource, ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @lcyRFcyPMaturationGroupComponent2Id, N'MatRecPrincipal', null, null,
                    N'Debit', null, N'ReceivePrincipalAmount', N'TxnNo', N'LogicalDate', N'LogicalDate',
                    N'ReceiveCurrency', N'ReceiveCurrency', N'ReceivePrincipalAmount', N'ReceivePrincipalAmount', 0,
                    null, null, @stateMaker, @stateDate, null, null);

            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @lcyRFcyPMaturationGroupComponent3Id
                    and GLCode = N'MatPayContingent')
        begin
            INSERT INTO dbo.accEngineAccountRule(Id, ComponentId, GLCode, CustomerCodeSource, CustomerAccountCodeSource,
                                                 DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                 ValueDateSource, TxnDateSource, CcySource, FcySource, LcyEqvtSource,
                                                 FcyAmtSource, ReverseRebook, CommentSource, CommentRuleId, ModifiedBy,
                                                 ModifiedDate, ReverseTxnDateSource, ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @lcyRFcyPMaturationGroupComponent3Id, N'MatPayContingent', null, null,
                    N'Debit', null, N'PayPrincipalAmount', N'TxnNo', N'LogicalDate', N'LogicalDate', N'PayCurrency',
                    N'PayCurrency', N'PayPrincipalAmount', N'PayPrincipalAmount', 0, null, null, @stateMaker,
                    @stateDate, null, null);

            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @lcyRFcyPMaturationGroupComponent3Id
                    and GLCode = N'MatRecContingentOffset')
        begin
            INSERT INTO dbo.accEngineAccountRule(Id, ComponentId, GLCode, CustomerCodeSource, CustomerAccountCodeSource,
                                                 DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                 ValueDateSource, TxnDateSource, CcySource, FcySource, LcyEqvtSource,
                                                 FcyAmtSource, ReverseRebook, CommentSource, CommentRuleId, ModifiedBy,
                                                 ModifiedDate, ReverseTxnDateSource, ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @lcyRFcyPMaturationGroupComponent3Id, N'MatRecContingentOffset', null,
                    null, N'Debit', null, N'ReceivePrincipalAmount', N'TxnNo', N'LogicalDate', N'LogicalDate',
                    N'ReceiveCurrency', N'ReceiveCurrency', N'ReceivePrincipalAmount', N'ReceivePrincipalAmount', 0,
                    null, null, @stateMaker, @stateDate, null, null);

            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @lcyRFcyPMaturationGroupComponent3Id
                    and GLCode = N'MatRecContingent')
        begin
            INSERT INTO dbo.accEngineAccountRule(Id, ComponentId, GLCode, CustomerCodeSource, CustomerAccountCodeSource,
                                                 DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                 ValueDateSource, TxnDateSource, CcySource, FcySource, LcyEqvtSource,
                                                 FcyAmtSource, ReverseRebook, CommentSource, CommentRuleId, ModifiedBy,
                                                 ModifiedDate, ReverseTxnDateSource, ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @lcyRFcyPMaturationGroupComponent3Id, N'MatRecContingent', null, null,
                    N'Credit', null, N'ReceivePrincipalAmount', N'TxnNo', N'LogicalDate', N'LogicalDate',
                    N'ReceiveCurrency', N'ReceiveCurrency', N'ReceivePrincipalAmount', N'ReceivePrincipalAmount', 0,
                    null, null, @stateMaker, @stateDate, null, null);

            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @lcyRFcyPMaturationGroupComponent4Id
                    and GLCode = N'83000000')
        begin
            INSERT INTO dbo.accEngineAccountRule(Id, ComponentId, GLCode, CustomerCodeSource, CustomerAccountCodeSource,
                                                 DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                 ValueDateSource, TxnDateSource, CcySource, FcySource, LcyEqvtSource,
                                                 FcyAmtSource, ReverseRebook, CommentSource, CommentRuleId, ModifiedBy,
                                                 ModifiedDate, ReverseTxnDateSource, ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @lcyRFcyPMaturationGroupComponent4Id, N'83000000', null, null,
                    N'Debit', null, N'TaxAmount', N'TxnNo', N'LogicalDate', N'LogicalDate', N'LocalCCY', N'LocalCCY',
                    N'TaxAmount', N'TaxAmount', 0, null, null, @stateMaker, @stateDate, null, null);

            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @lcyRFcyPMaturationGroupComponent4Id
                    and GLCode = N'38000500')
        begin
            INSERT INTO dbo.accEngineAccountRule(Id, ComponentId, GLCode, CustomerCodeSource, CustomerAccountCodeSource,
                                                 DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                 ValueDateSource, TxnDateSource, CcySource, FcySource, LcyEqvtSource,
                                                 FcyAmtSource, ReverseRebook, CommentSource, CommentRuleId, ModifiedBy,
                                                 ModifiedDate, ReverseTxnDateSource, ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @lcyRFcyPMaturationGroupComponent4Id, N'38000500', null, null,
                    N'Credit', null, N'TaxAmount', N'TxnNo', N'LogicalDate', N'LogicalDate', N'LocalCCY', N'LocalCCY',
                    N'TaxAmount', N'TaxAmount', 0, null, null, @stateMaker, @stateDate, null, null);

            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    ------------------------------------------------------------------------------------------------------------------------
    -- Accounting Engine Rule FCYRLCYP
    ------------------------------------------------------------------------------------------------------------------------

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @fcyRLcyPOpeningGroup1Component1Id
                    and GLCode = N'ValPayContingent')
        begin
            INSERT INTO dbo.accEngineAccountRule(Id, ComponentId, GLCode, CustomerCodeSource, CustomerAccountCodeSource,
                                                 DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                 ValueDateSource, TxnDateSource, CcySource, FcySource, LcyEqvtSource,
                                                 FcyAmtSource, ReverseRebook, CommentSource, CommentRuleId, ModifiedBy,
                                                 ModifiedDate, ReverseTxnDateSource, ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @fcyRLcyPOpeningGroup1Component1Id, N'ValPayContingent', null, null,
                    N'Debit', null, N'PayPrincipalAmount', N'TxnNo', N'LogicalDate', N'LogicalDate', N'PayCurrency',
                    N'PayCurrency', N'PayPrincipalAmount', N'PayPrincipalAmount', 0, null, null, @stateMaker,
                    @stateDate, null, null);

            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @fcyRLcyPOpeningGroup1Component1Id
                    and GLCode = N'ValPayContingentOffset')
        begin
            INSERT INTO dbo.accEngineAccountRule(Id, ComponentId, GLCode, CustomerCodeSource, CustomerAccountCodeSource,
                                                 DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                 ValueDateSource, TxnDateSource, CcySource, FcySource, LcyEqvtSource,
                                                 FcyAmtSource, ReverseRebook, CommentSource, CommentRuleId, ModifiedBy,
                                                 ModifiedDate, ReverseTxnDateSource, ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @fcyRLcyPOpeningGroup1Component1Id, N'ValPayContingentOffset', null,
                    null, N'Credit', null, N'PayPrincipalAmount', N'TxnNo', N'LogicalDate', N'LogicalDate',
                    N'PayCurrency', N'PayCurrency', N'PayPrincipalAmount', N'PayPrincipalAmount', 0, null, null,
                    @stateMaker, @stateDate, null, null);

            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @fcyRLcyPOpeningGroup1Component1Id
                    and GLCode = N'ValRecContingentOffset')
        begin
            INSERT INTO dbo.accEngineAccountRule(Id, ComponentId, GLCode, CustomerCodeSource, CustomerAccountCodeSource,
                                                 DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                 ValueDateSource, TxnDateSource, CcySource, FcySource, LcyEqvtSource,
                                                 FcyAmtSource, ReverseRebook, CommentSource, CommentRuleId, ModifiedBy,
                                                 ModifiedDate, ReverseTxnDateSource, ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @fcyRLcyPOpeningGroup1Component1Id, N'ValRecContingentOffset', null,
                    null, N'Debit', null, N'ReceivePrincipalAmount', N'TxnNo', N'LogicalDate', N'LogicalDate',
                    N'ReceiveCurrency', N'ReceiveCurrency', N'ReceivePrincipalAmount', N'ReceivePrincipalAmount', 0,
                    null, null, @stateMaker, @stateDate, null, null);

            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @fcyRLcyPOpeningGroup1Component1Id
                    and GLCode = N'ValRecContingent')
        begin
            INSERT INTO dbo.accEngineAccountRule(Id, ComponentId, GLCode, CustomerCodeSource, CustomerAccountCodeSource,
                                                 DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                 ValueDateSource, TxnDateSource, CcySource, FcySource, LcyEqvtSource,
                                                 FcyAmtSource, ReverseRebook, CommentSource, CommentRuleId, ModifiedBy,
                                                 ModifiedDate, ReverseTxnDateSource, ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @fcyRLcyPOpeningGroup1Component1Id, N'ValRecContingent', null, null,
                    N'Credit', null, N'ReceivePrincipalAmount', N'TxnNo', N'LogicalDate', N'LogicalDate',
                    N'ReceiveCurrency', N'ReceiveCurrency', N'ReceivePrincipalAmount', N'ReceivePrincipalAmount', 0,
                    null, null, @stateMaker, @stateDate, null, null);

            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @fcyRLcyPOpeningGroup1Component2Id
                    and GLCode = N'MatPayContingentOffset')
        begin
            INSERT INTO dbo.accEngineAccountRule(Id, ComponentId, GLCode, CustomerCodeSource, CustomerAccountCodeSource,
                                                 DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                 ValueDateSource, TxnDateSource, CcySource, FcySource, LcyEqvtSource,
                                                 FcyAmtSource, ReverseRebook, CommentSource, CommentRuleId, ModifiedBy,
                                                 ModifiedDate, ReverseTxnDateSource, ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @fcyRLcyPOpeningGroup1Component2Id, N'MatPayContingentOffset', null,
                    null, N'Debit', null, N'PayPrincipalAmount', N'TxnNo', N'PayValueDate', N'PayValueDate',
                    N'PayCurrency', N'PayCurrency', N'PayPrincipalAmount', N'PayPrincipalAmount', 0, null, null,
                    @stateMaker, @stateDate, null, null);

            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @fcyRLcyPOpeningGroup1Component2Id
                    and GLCode = N'MatPayContingent')
        begin
            INSERT INTO dbo.accEngineAccountRule(Id, ComponentId, GLCode, CustomerCodeSource, CustomerAccountCodeSource,
                                                 DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                 ValueDateSource, TxnDateSource, CcySource, FcySource, LcyEqvtSource,
                                                 FcyAmtSource, ReverseRebook, CommentSource, CommentRuleId, ModifiedBy,
                                                 ModifiedDate, ReverseTxnDateSource, ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @fcyRLcyPOpeningGroup1Component2Id, N'MatPayContingent', null, null,
                    N'Credit', null, N'PayPrincipalAmount', N'TxnNo', N'PayValueDate', N'PayValueDate', N'PayCurrency',
                    N'PayCurrency', N'PayPrincipalAmount', N'PayPrincipalAmount', 0, null, null, @stateMaker,
                    @stateDate, null, null);

            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @fcyRLcyPOpeningGroup1Component2Id
                    and GLCode = N'MatRecContingent')
        begin
            INSERT INTO dbo.accEngineAccountRule(Id, ComponentId, GLCode, CustomerCodeSource, CustomerAccountCodeSource,
                                                 DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                 ValueDateSource, TxnDateSource, CcySource, FcySource, LcyEqvtSource,
                                                 FcyAmtSource, ReverseRebook, CommentSource, CommentRuleId, ModifiedBy,
                                                 ModifiedDate, ReverseTxnDateSource, ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @fcyRLcyPOpeningGroup1Component2Id, N'MatRecContingent', null, null,
                    N'Debit', null, N'ReceivePrincipalAmount', N'TxnNo', N'LogicalDate', N'LogicalDate',
                    N'ReceiveCurrency', N'ReceiveCurrency', N'ReceivePrincipalAmount', N'ReceivePrincipalAmount', 0,
                    null, null, @stateMaker, @stateDate, null, null);

            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @fcyRLcyPOpeningGroup1Component2Id
                    and GLCode = N'MatRecContingentOffset')
        begin
            INSERT INTO dbo.accEngineAccountRule(Id, ComponentId, GLCode, CustomerCodeSource, CustomerAccountCodeSource,
                                                 DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                 ValueDateSource, TxnDateSource, CcySource, FcySource, LcyEqvtSource,
                                                 FcyAmtSource, ReverseRebook, CommentSource, CommentRuleId, ModifiedBy,
                                                 ModifiedDate, ReverseTxnDateSource, ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @fcyRLcyPOpeningGroup1Component2Id, N'MatRecContingentOffset', null,
                    null, N'Credit', null, N'ReceivePrincipalAmount', N'TxnNo', N'LogicalDate', N'LogicalDate',
                    N'ReceiveCurrency', N'ReceiveCurrency', N'ReceivePrincipalAmount', N'ReceivePrincipalAmount', 0,
                    null, null, @stateMaker, @stateDate, null, null);

            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @fcyRLcyPOpeningGroup2Component1Id
                    and GLCode = N'ValRecPrincipal')
        begin
            INSERT INTO dbo.accEngineAccountRule(Id, ComponentId, GLCode, CustomerCodeSource, CustomerAccountCodeSource,
                                                 DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                 ValueDateSource, TxnDateSource, CcySource, FcySource, LcyEqvtSource,
                                                 FcyAmtSource, ReverseRebook, CommentSource, CommentRuleId, ModifiedBy,
                                                 ModifiedDate, ReverseTxnDateSource, ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @fcyRLcyPOpeningGroup2Component1Id, N'ValRecPrincipal', null, null,
                    N'Credit', null, N'ReceivePrincipalAmount', N'TxnNo', N'LogicalDate', N'LogicalDate',
                    N'ReceiveCurrency', N'ReceiveCurrency', N'ReceivePrincipalAmount', N'ReceivePrincipalAmount', 0,
                    null, null, @stateMaker, @stateDate, null, null);

            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @fcyRLcyPOpeningGroup2Component1Id
                    and GLCode = N'FXPositionRec')
        begin
            INSERT INTO dbo.accEngineAccountRule(Id, ComponentId, GLCode, CustomerCodeSource, CustomerAccountCodeSource,
                                                 DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                 ValueDateSource, TxnDateSource, CcySource, FcySource, LcyEqvtSource,
                                                 FcyAmtSource, ReverseRebook, CommentSource, CommentRuleId, ModifiedBy,
                                                 ModifiedDate, ReverseTxnDateSource, ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @fcyRLcyPOpeningGroup2Component1Id, N'FXPositionRec', null, null,
                    N'Debit', null, N'ReceivePrincipalAmount', N'TxnNo', N'LogicalDate', N'LogicalDate',
                    N'ReceiveCurrency', N'ReceiveCurrency', N'ReceivePrincipalAmount', N'ReceivePrincipalAmount', 0,
                    null, null, @stateMaker, @stateDate, null, null);

            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @fcyRLcyPOpeningGroup2Component1Id
                    and GLCode = N'FXPositionLCY')
        begin
            INSERT INTO dbo.accEngineAccountRule(Id, ComponentId, GLCode, CustomerCodeSource, CustomerAccountCodeSource,
                                                 DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                 ValueDateSource, TxnDateSource, CcySource, FcySource, LcyEqvtSource,
                                                 FcyAmtSource, ReverseRebook, CommentSource, CommentRuleId, ModifiedBy,
                                                 ModifiedDate, ReverseTxnDateSource, ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @fcyRLcyPOpeningGroup2Component1Id, N'FXPositionLCY', null, null,
                    N'Credit', null, N'PayPrincipalAmount', N'TxnNo', N'LogicalDate', N'LogicalDate', N'LocalCCY',
                    N'ReceiveCurrency', N'PayPrincipalAmount', N'PayPrincipalAmount', 0, null, null, @stateMaker, @stateDate,
                    null, null);

            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @fcyRLcyPOpeningGroup2Component2Id
                    and GLCode = N'ValPayPrincipal')
        begin
            INSERT INTO dbo.accEngineAccountRule(Id, ComponentId, GLCode, CustomerCodeSource, CustomerAccountCodeSource,
                                                 DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                 ValueDateSource, TxnDateSource, CcySource, FcySource, LcyEqvtSource,
                                                 FcyAmtSource, ReverseRebook, CommentSource, CommentRuleId, ModifiedBy,
                                                 ModifiedDate, ReverseTxnDateSource, ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @fcyRLcyPOpeningGroup2Component2Id, N'ValPayPrincipal', null, null,
                    N'Debit', null, N'PayPrincipalAmount', N'TxnNo', N'LogicalDate', N'LogicalDate', N'PayCurrency',
                    N'PayCurrency', N'PayPrincipalAmount', N'PayPrincipalAmount', 0, null, null, @stateMaker,
                    @stateDate, null, null);

            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @fcyRLcyPOpeningGroup2Component3Id
                    and GLCode = N'ValPayContingentOffset')
        begin
            INSERT INTO dbo.accEngineAccountRule(Id, ComponentId, GLCode, CustomerCodeSource, CustomerAccountCodeSource,
                                                 DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                 ValueDateSource, TxnDateSource, CcySource, FcySource, LcyEqvtSource,
                                                 FcyAmtSource, ReverseRebook, CommentSource, CommentRuleId, ModifiedBy,
                                                 ModifiedDate, ReverseTxnDateSource, ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @fcyRLcyPOpeningGroup2Component3Id, N'ValPayContingentOffset', null,
                    null, N'Debit', null, N'PayPrincipalAmount', N'TxnNo', N'LogicalDate', N'LogicalDate',
                    N'PayCurrency', N'PayCurrency', N'PayPrincipalAmount', N'PayPrincipalAmount', 0, null, null,
                    @stateMaker, @stateDate, null, null);

            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @fcyRLcyPOpeningGroup2Component3Id
                    and GLCode = N'ValPayContingent')
        begin
            INSERT INTO dbo.accEngineAccountRule(Id, ComponentId, GLCode, CustomerCodeSource, CustomerAccountCodeSource,
                                                 DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                 ValueDateSource, TxnDateSource, CcySource, FcySource, LcyEqvtSource,
                                                 FcyAmtSource, ReverseRebook, CommentSource, CommentRuleId, ModifiedBy,
                                                 ModifiedDate, ReverseTxnDateSource, ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @fcyRLcyPOpeningGroup2Component3Id, N'ValPayContingent', null, null,
                    N'Credit', null, N'PayPrincipalAmount', N'TxnNo', N'LogicalDate', N'LogicalDate', N'PayCurrency',
                    N'PayCurrency', N'PayPrincipalAmount', N'PayPrincipalAmount', 0, null, null, @stateMaker,
                    @stateDate, null, null);

            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @fcyRLcyPOpeningGroup2Component3Id
                    and GLCode = N'ValRecContingent')
        begin
            INSERT INTO dbo.accEngineAccountRule(Id, ComponentId, GLCode, CustomerCodeSource, CustomerAccountCodeSource,
                                                 DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                 ValueDateSource, TxnDateSource, CcySource, FcySource, LcyEqvtSource,
                                                 FcyAmtSource, ReverseRebook, CommentSource, CommentRuleId, ModifiedBy,
                                                 ModifiedDate, ReverseTxnDateSource, ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @fcyRLcyPOpeningGroup2Component3Id, N'ValRecContingent', null, null,
                    N'Debit', null, N'ReceivePrincipalAmount', N'TxnNo', N'LogicalDate', N'LogicalDate',
                    N'ReceiveCurrency', N'ReceiveCurrency', N'ReceivePrincipalAmount', N'ReceivePrincipalAmount', 0,
                    null, null, @stateMaker, @stateDate, null, null);

            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @fcyRLcyPOpeningGroup2Component3Id
                    and GLCode = N'ValRecContingentOffset')
        begin
            INSERT INTO dbo.accEngineAccountRule(Id, ComponentId, GLCode, CustomerCodeSource, CustomerAccountCodeSource,
                                                 DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                 ValueDateSource, TxnDateSource, CcySource, FcySource, LcyEqvtSource,
                                                 FcyAmtSource, ReverseRebook, CommentSource, CommentRuleId, ModifiedBy,
                                                 ModifiedDate, ReverseTxnDateSource, ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @fcyRLcyPOpeningGroup2Component3Id, N'ValRecContingentOffset', null,
                    null, N'Credit', null, N'ReceivePrincipalAmount', N'TxnNo', N'LogicalDate', N'LogicalDate',
                    N'ReceiveCurrency', N'ReceiveCurrency', N'ReceivePrincipalAmount', N'ReceivePrincipalAmount', 0,
                    null, null, @stateMaker, @stateDate, null, null);

            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @fcyRLcyPOpeningGroup2Component4Id
                    and GLCode = N'MatPayContingentOffset')
        begin
            INSERT INTO dbo.accEngineAccountRule(Id, ComponentId, GLCode, CustomerCodeSource, CustomerAccountCodeSource,
                                                 DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                 ValueDateSource, TxnDateSource, CcySource, FcySource, LcyEqvtSource,
                                                 FcyAmtSource, ReverseRebook, CommentSource, CommentRuleId, ModifiedBy,
                                                 ModifiedDate, ReverseTxnDateSource, ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @fcyRLcyPOpeningGroup2Component4Id, N'MatPayContingentOffset', null,
                    null, N'Debit', null, N'PayPrincipalAmount', N'TxnNo', N'LogicalDate', N'LogicalDate',
                    N'PayCurrency', N'PayCurrency', N'PayPrincipalAmount', N'PayPrincipalAmount', 0, null, null,
                    @stateMaker, @stateDate, null, null);

            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @fcyRLcyPOpeningGroup2Component4Id
                    and GLCode = N'MatPayContingent')
        begin
            INSERT INTO dbo.accEngineAccountRule(Id, ComponentId, GLCode, CustomerCodeSource, CustomerAccountCodeSource,
                                                 DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                 ValueDateSource, TxnDateSource, CcySource, FcySource, LcyEqvtSource,
                                                 FcyAmtSource, ReverseRebook, CommentSource, CommentRuleId, ModifiedBy,
                                                 ModifiedDate, ReverseTxnDateSource, ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @fcyRLcyPOpeningGroup2Component4Id, N'MatPayContingent', null, null,
                    N'Credit', null, N'PayPrincipalAmount', N'TxnNo', N'LogicalDate', N'LogicalDate', N'PayCurrency',
                    N'PayCurrency', N'PayPrincipalAmount', N'PayPrincipalAmount', 0, null, null, @stateMaker,
                    @stateDate, null, null);

            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @fcyRLcyPOpeningGroup2Component4Id
                    and GLCode = N'MatRecContingent')
        begin
            INSERT INTO dbo.accEngineAccountRule(Id, ComponentId, GLCode, CustomerCodeSource, CustomerAccountCodeSource,
                                                 DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                 ValueDateSource, TxnDateSource, CcySource, FcySource, LcyEqvtSource,
                                                 FcyAmtSource, ReverseRebook, CommentSource, CommentRuleId, ModifiedBy,
                                                 ModifiedDate, ReverseTxnDateSource, ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @fcyRLcyPOpeningGroup2Component4Id, N'MatRecContingent', null, null,
                    N'Debit', null, N'ReceivePrincipalAmount', N'TxnNo', N'LogicalDate', N'LogicalDate',
                    N'ReceiveCurrency', N'ReceiveCurrency', N'ReceivePrincipalAmount', N'ReceivePrincipalAmount', 0,
                    null, null, @stateMaker, @stateDate, null, null);

            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @fcyRLcyPOpeningGroup2Component4Id
                    and GLCode = N'MatRecContingentOffset')
        begin
            INSERT INTO dbo.accEngineAccountRule(Id, ComponentId, GLCode, CustomerCodeSource, CustomerAccountCodeSource,
                                                 DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                 ValueDateSource, TxnDateSource, CcySource, FcySource, LcyEqvtSource,
                                                 FcyAmtSource, ReverseRebook, CommentSource, CommentRuleId, ModifiedBy,
                                                 ModifiedDate, ReverseTxnDateSource, ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @fcyRLcyPOpeningGroup2Component4Id, N'MatRecContingentOffset', null,
                    null, N'Credit', null, N'ReceivePrincipalAmount', N'TxnNo', N'LogicalDate', N'LogicalDate',
                    N'ReceiveCurrency', N'ReceiveCurrency', N'ReceivePrincipalAmount', N'ReceivePrincipalAmount', 0,
                    null, null, @stateMaker, @stateDate, null, null);

            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @fcyRLcyPRevaluationGroupComponent1Id
                    and GLCode = N'TotalMTMProfit')
        begin
            INSERT INTO dbo.accEngineAccountRule(Id, ComponentId, GLCode, CustomerCodeSource, CustomerAccountCodeSource,
                                                 DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                 ValueDateSource, TxnDateSource, CcySource, FcySource, LcyEqvtSource,
                                                 FcyAmtSource, ReverseRebook, CommentSource, CommentRuleId, ModifiedBy,
                                                 ModifiedDate, ReverseTxnDateSource, ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @fcyRLcyPRevaluationGroupComponent1Id, N'TotalMTMProfit', null, null,
                    N'Debit', null, N'TotalMTMAmountLCY', N'TxnNo', N'LogicalDate', N'LogicalDate',
                    N'TotalMTMAmountCCY', N'TotalMTMAmountCCY', N'TotalMTMAmountLCY', N'TotalMTMAmountLCY', 0, null,
                    null, @stateMaker, @stateDate, null, null);

            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @fcyRLcyPRevaluationGroupComponent1Id
                    and GLCode = N'CapitalGainLCY')
        begin
            INSERT INTO dbo.accEngineAccountRule(Id, ComponentId, GLCode, CustomerCodeSource, CustomerAccountCodeSource,
                                                 DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                 ValueDateSource, TxnDateSource, CcySource, FcySource, LcyEqvtSource,
                                                 FcyAmtSource, ReverseRebook, CommentSource, CommentRuleId, ModifiedBy,
                                                 ModifiedDate, ReverseTxnDateSource, ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @fcyRLcyPRevaluationGroupComponent1Id, N'CapitalGainLCY', null, null,
                    N'Credit', null, N'TotalMTMAmountLCY', N'TxnNo', N'LogicalDate', N'LogicalDate', N'LocalCCY',
                    N'LocalCCY', N'TotalMTMAmountLCY', N'TotalMTMAmountLCY', 0, null, null, @stateMaker, @stateDate,
                    null, null);

            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @fcyRLcyPRevaluationGroupComponent2Id
                    and GLCode = N'TotalMTMLoss')
        begin
            INSERT INTO dbo.accEngineAccountRule(Id, ComponentId, GLCode, CustomerCodeSource, CustomerAccountCodeSource,
                                                 DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                 ValueDateSource, TxnDateSource, CcySource, FcySource, LcyEqvtSource,
                                                 FcyAmtSource, ReverseRebook, CommentSource, CommentRuleId, ModifiedBy,
                                                 ModifiedDate, ReverseTxnDateSource, ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @fcyRLcyPRevaluationGroupComponent2Id, N'TotalMTMLoss', null, null,
                    N'Credit', null, N'TotalMTMAmountLCY', N'TxnNo', N'LogicalDate', N'LogicalDate',
                    N'TotalMTMAmountCCY', N'TotalMTMAmountCCY', N'TotalMTMAmountLCY', N'TotalMTMAmountLCY', 0, null,
                    null, @stateMaker, @stateDate, null, null);

            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @fcyRLcyPRevaluationGroupComponent2Id
                    and GLCode = N'CapitalLossLCY')
        begin
            INSERT INTO dbo.accEngineAccountRule(Id, ComponentId, GLCode, CustomerCodeSource, CustomerAccountCodeSource,
                                                 DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                 ValueDateSource, TxnDateSource, CcySource, FcySource, LcyEqvtSource,
                                                 FcyAmtSource, ReverseRebook, CommentSource, CommentRuleId, ModifiedBy,
                                                 ModifiedDate, ReverseTxnDateSource, ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @fcyRLcyPRevaluationGroupComponent2Id, N'CapitalLossLCY', null, null,
                    N'Debit', null, N'TotalMTMAmountLCY', N'TxnNo', N'LogicalDate', N'LogicalDate', N'LocalCCY',
                    N'LocalCCY', N'TotalMTMAmountLCY', N'TotalMTMAmountLCY', 0, null, null, @stateMaker, @stateDate,
                    null, null);

            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @fcyRLcyPPaymentGroupComponent1Id
                    and GLCode = N'IncomingPaymentFCY')
        begin
            INSERT INTO dbo.accEngineAccountRule(Id, ComponentId, GLCode, CustomerCodeSource, CustomerAccountCodeSource,
                                                 DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                 ValueDateSource, TxnDateSource, CcySource, FcySource, LcyEqvtSource,
                                                 FcyAmtSource, ReverseRebook, CommentSource, CommentRuleId, ModifiedBy,
                                                 ModifiedDate, ReverseTxnDateSource, ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @fcyRLcyPPaymentGroupComponent1Id, N'IncomingPaymentFCY', null, null,
                    N'Debit', null, N'ReceivePeriodAmount', N'TxnNo', N'LogicalDate', N'LogicalDate',
                    N'ReceiveCurrency', N'ReceiveCurrency', N'ReceivePeriodAmount', N'ReceivePeriodAmount', 0, null,
                    null, @stateMaker, @stateDate, null, null);

            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @fcyRLcyPPaymentGroupComponent1Id
                    and GLCode = N'FXPositionRec')
        begin
            INSERT INTO dbo.accEngineAccountRule(Id, ComponentId, GLCode, CustomerCodeSource, CustomerAccountCodeSource,
                                                 DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                 ValueDateSource, TxnDateSource, CcySource, FcySource, LcyEqvtSource,
                                                 FcyAmtSource, ReverseRebook, CommentSource, CommentRuleId, ModifiedBy,
                                                 ModifiedDate, ReverseTxnDateSource, ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @fcyRLcyPPaymentGroupComponent1Id, N'FXPositionRec', null, null,
                    N'Credit', null, N'ReceivePeriodAmount', N'TxnNo', N'LogicalDate', N'LogicalDate',
                    N'ReceiveCurrency', N'ReceiveCurrency', N'ReceivePeriodAmount', N'ReceivePeriodAmount', 0, null,
                    null, @stateMaker, @stateDate, null, null);

            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @fcyRLcyPPaymentGroupComponent1Id
                    and GLCode = N'FXPositionLCY')
        begin
            INSERT INTO dbo.accEngineAccountRule(Id, ComponentId, GLCode, CustomerCodeSource, CustomerAccountCodeSource,
                                                 DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                 ValueDateSource, TxnDateSource, CcySource, FcySource, LcyEqvtSource,
                                                 FcyAmtSource, ReverseRebook, CommentSource, CommentRuleId, ModifiedBy,
                                                 ModifiedDate, ReverseTxnDateSource, ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @fcyRLcyPPaymentGroupComponent1Id, N'FXPositionLCY', null, null,
                    N'Debit', null, N'ReceivePeriodAmountLCY', N'TxnNo', N'LogicalDate', N'LogicalDate', N'LocalCCY',
                    N'ReceiveCurrency', N'ReceivePeriodAmountLCY', N'ReceivePeriodAmountLCY', 0, null, null, @stateMaker,
                    @stateDate, null, null);

            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @fcyRLcyPPaymentGroupComponent1Id
                    and GLCode = N'InterestIncome')
        begin
            INSERT INTO dbo.accEngineAccountRule(Id, ComponentId, GLCode, CustomerCodeSource, CustomerAccountCodeSource,
                                                 DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                 ValueDateSource, TxnDateSource, CcySource, FcySource, LcyEqvtSource,
                                                 FcyAmtSource, ReverseRebook, CommentSource, CommentRuleId, ModifiedBy,
                                                 ModifiedDate, ReverseTxnDateSource, ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @fcyRLcyPPaymentGroupComponent1Id, N'InterestIncome', null, null,
                    N'Credit', null, N'ReceivePeriodAmountLCY', N'TxnNo', N'LogicalDate', N'LogicalDate',
                    N'LocalCCY', N'LocalCCY', N'ReceivePeriodAmountLCY', N'ReceivePeriodAmountLCY', 0,
                    null, null, @stateMaker, @stateDate, null, null);

            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @fcyRLcyPPaymentGroupComponent2Id
                    and GLCode = N'OutgoingPaymentFCY')
        begin
            INSERT INTO dbo.accEngineAccountRule(Id, ComponentId, GLCode, CustomerCodeSource, CustomerAccountCodeSource,
                                                 DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                 ValueDateSource, TxnDateSource, CcySource, FcySource, LcyEqvtSource,
                                                 FcyAmtSource, ReverseRebook, CommentSource, CommentRuleId, ModifiedBy,
                                                 ModifiedDate, ReverseTxnDateSource, ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @fcyRLcyPPaymentGroupComponent2Id, N'OutgoingPaymentLCY', null, null,
                    N'Credit', null, N'PayPeriodAmount', N'TxnNo', N'LogicalDate', N'LogicalDate', N'PayCurrency',
                    N'PayCurrency', N'PayPeriodAmount', N'PayPeriodAmount', 0, null, null, @stateMaker, @stateDate,
                    null, null);

            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @fcyRLcyPPaymentGroupComponent2Id
                    and GLCode = N'InterestExpense')
        begin
            INSERT INTO dbo.accEngineAccountRule(Id, ComponentId, GLCode, CustomerCodeSource, CustomerAccountCodeSource,
                                                 DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                 ValueDateSource, TxnDateSource, CcySource, FcySource, LcyEqvtSource,
                                                 FcyAmtSource, ReverseRebook, CommentSource, CommentRuleId, ModifiedBy,
                                                 ModifiedDate, ReverseTxnDateSource, ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @fcyRLcyPPaymentGroupComponent2Id, N'InterestExpense', null, null,
                    N'Debit', null, N'PayPeriodAmountLCY', N'TxnNo', N'LogicalDate', N'LogicalDate', N'PayCurrency',
                    N'PayCurrency', N'PayPeriodAmountLCY', N'PayPeriodAmountLCY', 0, null, null, @stateMaker,
                    @stateDate, null, null);

            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @fcyRLcyPMaturationGroupComponent1Id
                    and GLCode = N'MatPayPrincipal')
        begin
            INSERT INTO dbo.accEngineAccountRule(Id, ComponentId, GLCode, CustomerCodeSource, CustomerAccountCodeSource,
                                                 DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                 ValueDateSource, TxnDateSource, CcySource, FcySource, LcyEqvtSource,
                                                 FcyAmtSource, ReverseRebook, CommentSource, CommentRuleId, ModifiedBy,
                                                 ModifiedDate, ReverseTxnDateSource, ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @fcyRLcyPMaturationGroupComponent1Id, N'MatPayPrincipal', null, null,
                    N'Credit', null, N'PayPrincipalAmount', N'TxnNo', N'LogicalDate', N'LogicalDate', N'PayCurrency',
                    N'PayCurrency', N'PayPrincipalAmount', N'PayPrincipalAmount', 0, null, null, @stateMaker, @stateDate, null, null);

            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @fcyRLcyPMaturationGroupComponent2Id
                    and GLCode = N'MatRecPrincipal')
        begin
            INSERT INTO dbo.accEngineAccountRule(Id, ComponentId, GLCode, CustomerCodeSource, CustomerAccountCodeSource,
                                                 DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                 ValueDateSource, TxnDateSource, CcySource, FcySource, LcyEqvtSource,
                                                 FcyAmtSource, ReverseRebook, CommentSource, CommentRuleId, ModifiedBy,
                                                 ModifiedDate, ReverseTxnDateSource, ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @fcyRLcyPMaturationGroupComponent2Id, N'MatRecPrincipal', null, null,
                    N'Debit', null, N'ReceivePrincipalAmount', N'TxnNo', N'LogicalDate', N'LogicalDate',
                    N'ReceiveCurrency', N'ReceiveCurrency', N'ReceivePrincipalAmount', N'ReceivePrincipalAmount', 0,
                    null, null, @stateMaker, @stateDate, null, null);

            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @fcyRLcyPMaturationGroupComponent2Id
                    and GLCode = N'FXPositionRec')
        begin
            INSERT INTO dbo.accEngineAccountRule(Id, ComponentId, GLCode, CustomerCodeSource, CustomerAccountCodeSource,
                                                 DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                 ValueDateSource, TxnDateSource, CcySource, FcySource, LcyEqvtSource,
                                                 FcyAmtSource, ReverseRebook, CommentSource, CommentRuleId, ModifiedBy,
                                                 ModifiedDate, ReverseTxnDateSource, ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @fcyRLcyPMaturationGroupComponent2Id, N'FXPositionRec', null, null,
                    N'Credit', null, N'ReceivePrincipalAmount', N'TxnNo', N'LogicalDate', N'LogicalDate',
                    N'ReceiveCurrency', N'ReceiveCurrency', N'ReceivePrincipalAmount', N'ReceivePrincipalAmount', 0,
                    null, null, @stateMaker, @stateDate, null, null);

            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @fcyRLcyPMaturationGroupComponent2Id
                    and GLCode = N'FXPositionLCY')
        begin
            INSERT INTO dbo.accEngineAccountRule(Id, ComponentId, GLCode, CustomerCodeSource, CustomerAccountCodeSource,
                                                 DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                 ValueDateSource, TxnDateSource, CcySource, FcySource, LcyEqvtSource,
                                                 FcyAmtSource, ReverseRebook, CommentSource, CommentRuleId, ModifiedBy,
                                                 ModifiedDate, ReverseTxnDateSource, ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @fcyRLcyPMaturationGroupComponent2Id, N'FXPositionLCY', null, null,
                    N'Debit', null, N'PayPrincipalAmount', N'TxnNo', N'LogicalDate', N'LogicalDate', N'LocalCCY',
                    N'ReceiveCurrency', N'PayPrincipalAmount', N'PayPrincipalAmount', 0, null, null, @stateMaker, @stateDate,
                    null, null);

            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @fcyRLcyPMaturationGroupComponent3Id
                    and GLCode = N'MatPayContingent')
        begin
            INSERT INTO dbo.accEngineAccountRule(Id, ComponentId, GLCode, CustomerCodeSource, CustomerAccountCodeSource,
                                                 DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                 ValueDateSource, TxnDateSource, CcySource, FcySource, LcyEqvtSource,
                                                 FcyAmtSource, ReverseRebook, CommentSource, CommentRuleId, ModifiedBy,
                                                 ModifiedDate, ReverseTxnDateSource, ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @fcyRLcyPMaturationGroupComponent3Id, N'MatPayContingent', null, null,
                    N'Debit', null, N'PayPrincipalAmount', N'TxnNo', N'LogicalDate', N'LogicalDate', N'PayCurrency',
                    N'PayCurrency', N'PayPrincipalAmount', N'PayPrincipalAmount', 0, null, null, @stateMaker,
                    @stateDate, null, null);

            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @fcyRLcyPMaturationGroupComponent3Id
                    and GLCode = N'MatPayContingentOffset')
        begin
            INSERT INTO dbo.accEngineAccountRule(Id, ComponentId, GLCode, CustomerCodeSource, CustomerAccountCodeSource,
                                                 DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                 ValueDateSource, TxnDateSource, CcySource, FcySource, LcyEqvtSource,
                                                 FcyAmtSource, ReverseRebook, CommentSource, CommentRuleId, ModifiedBy,
                                                 ModifiedDate, ReverseTxnDateSource, ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @fcyRLcyPMaturationGroupComponent3Id, N'MatPayContingentOffset', null,
                    null, N'Credit', null, N'PayPrincipalAmount', N'TxnNo', N'LogicalDate', N'LogicalDate',
                    N'PayCurrency', N'PayCurrency', N'PayPrincipalAmount', N'PayPrincipalAmount', 0, null, null,
                    @stateMaker, @stateDate, null, null);

            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @fcyRLcyPMaturationGroupComponent3Id
                    and GLCode = N'MatRecContingentOffset')
        begin
            INSERT INTO dbo.accEngineAccountRule(Id, ComponentId, GLCode, CustomerCodeSource, CustomerAccountCodeSource,
                                                 DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                 ValueDateSource, TxnDateSource, CcySource, FcySource, LcyEqvtSource,
                                                 FcyAmtSource, ReverseRebook, CommentSource, CommentRuleId, ModifiedBy,
                                                 ModifiedDate, ReverseTxnDateSource, ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @fcyRLcyPMaturationGroupComponent3Id, N'MatRecContingentOffset', null,
                    null, N'Debit', null, N'ReceivePrincipalAmount', N'TxnNo', N'LogicalDate', N'LogicalDate',
                    N'ReceiveCurrency', N'ReceiveCurrency', N'ReceivePrincipalAmount', N'ReceivePrincipalAmount', 0,
                    null, null, @stateMaker, @stateDate, null, null);

            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @fcyRLcyPMaturationGroupComponent3Id
                    and GLCode = N'MatRecContingent')
        begin
            INSERT INTO dbo.accEngineAccountRule(Id, ComponentId, GLCode, CustomerCodeSource, CustomerAccountCodeSource,
                                                 DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                 ValueDateSource, TxnDateSource, CcySource, FcySource, LcyEqvtSource,
                                                 FcyAmtSource, ReverseRebook, CommentSource, CommentRuleId, ModifiedBy,
                                                 ModifiedDate, ReverseTxnDateSource, ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @fcyRLcyPMaturationGroupComponent3Id, N'MatRecContingent', null, null,
                    N'Credit', null, N'ReceivePrincipalAmount', N'TxnNo', N'LogicalDate', N'LogicalDate',
                    N'ReceiveCurrency', N'ReceiveCurrency', N'ReceivePrincipalAmount', N'ReceivePrincipalAmount', 0,
                    null, null, @stateMaker, @stateDate, null, null);
            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @fcyRLcyPMaturationGroupComponent4Id
                    and GLCode = N'83000000')
        begin
            INSERT INTO dbo.accEngineAccountRule(Id, ComponentId, GLCode, CustomerCodeSource, CustomerAccountCodeSource,
                                                 DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                 ValueDateSource, TxnDateSource, CcySource, FcySource, LcyEqvtSource,
                                                 FcyAmtSource, ReverseRebook, CommentSource, CommentRuleId, ModifiedBy,
                                                 ModifiedDate, ReverseTxnDateSource, ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @fcyRLcyPMaturationGroupComponent4Id, N'83000000', null, null,
                    N'Debit', null, N'TaxAmount', N'TxnNo', N'LogicalDate', N'LogicalDate', N'LocalCCY', N'LocalCCY',
                    N'TaxAmount', N'TaxAmount', 0, null, null, @stateMaker, @stateDate, null, null);

            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @fcyRLcyPMaturationGroupComponent4Id
                    and GLCode = N'38000500')
        begin
            INSERT INTO dbo.accEngineAccountRule(Id, ComponentId, GLCode, CustomerCodeSource, CustomerAccountCodeSource,
                                                 DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                 ValueDateSource, TxnDateSource, CcySource, FcySource, LcyEqvtSource,
                                                 FcyAmtSource, ReverseRebook, CommentSource, CommentRuleId, ModifiedBy,
                                                 ModifiedDate, ReverseTxnDateSource, ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @fcyRLcyPMaturationGroupComponent4Id, N'38000500', null, null,
                    N'Credit', null, N'TaxAmount', N'TxnNo', N'LogicalDate', N'LogicalDate', N'LocalCCY', N'LocalCCY',
                    N'TaxAmount', N'TaxAmount', 0, null, null, @stateMaker, @stateDate, null, null);

            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    ------------------------------------------------------------------------------------------------------------------------
    -- Accounting Engine Rule FCYRFCYP
    ------------------------------------------------------------------------------------------------------------------------

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @fcyRFcyPOpeningGroup1Component1Id
                    and GLCode = N'ValPayContingent')
        begin
            INSERT INTO dbo.accEngineAccountRule(Id, ComponentId, GLCode, CustomerCodeSource, CustomerAccountCodeSource,
                                                 DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                 ValueDateSource,
                                                 TxnDateSource, CcySource, FcySource, LcyEqvtSource, FcyAmtSource,
                                                 ReverseRebook, CommentSource, CommentRuleId, ModifiedBy, ModifiedDate,
                                                 ReverseTxnDateSource, ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @fcyRFcyPOpeningGroup1Component1Id, N'ValPayContingent', null, null,
                    N'Debit', null, N'PayPrincipalAmount', N'TxnNo', N'LogicalDate', N'LogicalDate', N'PayCurrency',
                    N'PayCurrency', N'PayPrincipalAmount', N'PayPrincipalAmount', 0, null, null, @stateMaker,
                    @stateDate,
                    null, null);

            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @fcyRFcyPOpeningGroup1Component1Id
                    and GLCode = N'ValPayContingentOffset')
        begin
            INSERT INTO dbo.accEngineAccountRule(Id, ComponentId, GLCode, CustomerCodeSource, CustomerAccountCodeSource,
                                                 DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                 ValueDateSource,
                                                 TxnDateSource, CcySource, FcySource, LcyEqvtSource, FcyAmtSource,
                                                 ReverseRebook, CommentSource, CommentRuleId, ModifiedBy, ModifiedDate,
                                                 ReverseTxnDateSource, ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @fcyRFcyPOpeningGroup1Component1Id, N'ValPayContingentOffset', null,
                    null,
                    N'Credit', null, N'PayPrincipalAmount', N'TxnNo', N'LogicalDate', N'LogicalDate', N'PayCurrency',
                    N'PayCurrency', N'PayPrincipalAmount', N'PayPrincipalAmount', 0, null, null, @stateMaker,
                    @stateDate,
                    null, null);

            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @fcyRFcyPOpeningGroup1Component1Id
                    and GLCode = N'ValRecContingentOffset')
        begin
            INSERT INTO dbo.accEngineAccountRule(Id, ComponentId, GLCode, CustomerCodeSource, CustomerAccountCodeSource,
                                                 DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                 ValueDateSource,
                                                 TxnDateSource, CcySource, FcySource, LcyEqvtSource, FcyAmtSource,
                                                 ReverseRebook, CommentSource, CommentRuleId, ModifiedBy, ModifiedDate,
                                                 ReverseTxnDateSource, ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @fcyRFcyPOpeningGroup1Component1Id, N'ValRecContingentOffset', null,
                    null,
                    N'Debit', null, N'ReceivePrincipalAmount', N'TxnNo', N'LogicalDate', N'LogicalDate',
                    N'ReceiveCurrency',
                    N'ReceiveCurrency', N'ReceivePrincipalAmount', N'ReceivePrincipalAmount', 0, null, null,
                    @stateMaker,
                    @stateDate, null, null);

            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @fcyRFcyPOpeningGroup1Component1Id
                    and GLCode = N'ValRecContingent')
        begin
            INSERT INTO dbo.accEngineAccountRule(Id, ComponentId, GLCode, CustomerCodeSource, CustomerAccountCodeSource,
                                                 DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                 ValueDateSource,
                                                 TxnDateSource, CcySource, FcySource, LcyEqvtSource, FcyAmtSource,
                                                 ReverseRebook, CommentSource, CommentRuleId, ModifiedBy, ModifiedDate,
                                                 ReverseTxnDateSource, ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @fcyRFcyPOpeningGroup1Component1Id, N'ValRecContingent', null, null,
                    N'Credit', null, N'ReceivePrincipalAmount', N'TxnNo', N'LogicalDate', N'LogicalDate',
                    N'ReceiveCurrency', N'ReceiveCurrency', N'ReceivePrincipalAmount', N'ReceivePrincipalAmount', 0,
                    null,
                    null, @stateMaker, @stateDate, null, null);

            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @fcyRFcyPOpeningGroup1Component2Id
                    and GLCode = N'MatPayContingentOffset')
        begin
            INSERT INTO dbo.accEngineAccountRule(Id, ComponentId, GLCode, CustomerCodeSource, CustomerAccountCodeSource,
                                                 DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                 ValueDateSource,
                                                 TxnDateSource, CcySource, FcySource, LcyEqvtSource, FcyAmtSource,
                                                 ReverseRebook, CommentSource, CommentRuleId, ModifiedBy, ModifiedDate,
                                                 ReverseTxnDateSource, ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @fcyRFcyPOpeningGroup1Component2Id, N'MatPayContingentOffset', null,
                    null,
                    N'Debit', null, N'PayPrincipalAmount', N'TxnNo', N'PayValueDate', N'PayValueDate', N'PayCurrency',
                    N'PayCurrency', N'PayPrincipalAmount', N'PayPrincipalAmount', 0, null, null, @stateMaker,
                    @stateDate,
                    null, null);

            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @fcyRFcyPOpeningGroup1Component2Id
                    and GLCode = N'MatPayContingent')
        begin
            INSERT INTO dbo.accEngineAccountRule(Id, ComponentId, GLCode, CustomerCodeSource, CustomerAccountCodeSource,
                                                 DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                 ValueDateSource,
                                                 TxnDateSource, CcySource, FcySource, LcyEqvtSource, FcyAmtSource,
                                                 ReverseRebook, CommentSource, CommentRuleId, ModifiedBy, ModifiedDate,
                                                 ReverseTxnDateSource, ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @fcyRFcyPOpeningGroup1Component2Id, N'MatPayContingent', null, null,
                    N'Credit', null, N'PayPrincipalAmount', N'TxnNo', N'PayValueDate', N'PayValueDate', N'PayCurrency',
                    N'PayCurrency', N'PayPrincipalAmount', N'PayPrincipalAmount', 0, null, null, @stateMaker,
                    @stateDate,
                    null, null);

            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @fcyRFcyPOpeningGroup1Component2Id
                    and GLCode = N'MatRecContingent')
        begin
            INSERT INTO dbo.accEngineAccountRule(Id, ComponentId, GLCode, CustomerCodeSource, CustomerAccountCodeSource,
                                                 DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                 ValueDateSource,
                                                 TxnDateSource, CcySource, FcySource, LcyEqvtSource, FcyAmtSource,
                                                 ReverseRebook, CommentSource, CommentRuleId, ModifiedBy, ModifiedDate,
                                                 ReverseTxnDateSource, ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @fcyRFcyPOpeningGroup1Component2Id, N'MatRecContingent', null, null,
                    N'Debit', null, N'ReceivePrincipalAmount', N'TxnNo', N'LogicalDate', N'LogicalDate',
                    N'ReceiveCurrency',
                    N'ReceiveCurrency', N'ReceivePrincipalAmount', N'ReceivePrincipalAmount', 0, null, null,
                    @stateMaker,
                    @stateDate, null, null);

            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @fcyRFcyPOpeningGroup1Component2Id
                    and GLCode = N'MatRecContingentOffset')
        begin
            INSERT INTO dbo.accEngineAccountRule(Id, ComponentId, GLCode, CustomerCodeSource, CustomerAccountCodeSource,
                                                 DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                 ValueDateSource,
                                                 TxnDateSource, CcySource, FcySource, LcyEqvtSource, FcyAmtSource,
                                                 ReverseRebook, CommentSource, CommentRuleId, ModifiedBy, ModifiedDate,
                                                 ReverseTxnDateSource, ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @fcyRFcyPOpeningGroup1Component2Id, N'MatRecContingentOffset', null,
                    null,
                    N'Credit', null, N'ReceivePrincipalAmount', N'TxnNo', N'LogicalDate', N'LogicalDate',
                    N'ReceiveCurrency', N'ReceiveCurrency', N'ReceivePrincipalAmount', N'ReceivePrincipalAmount', 0,
                    null,
                    null, @stateMaker, @stateDate, null, null);

            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @fcyRFcyPOpeningGroup2Component1Id
                    and GLCode = N'ValRecPrincipal')
        begin
            INSERT INTO dbo.accEngineAccountRule(Id, ComponentId, GLCode, CustomerCodeSource, CustomerAccountCodeSource,
                                                 DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                 ValueDateSource,
                                                 TxnDateSource, CcySource, FcySource, LcyEqvtSource, FcyAmtSource,
                                                 ReverseRebook, CommentSource, CommentRuleId, ModifiedBy, ModifiedDate,
                                                 ReverseTxnDateSource, ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @fcyRFcyPOpeningGroup2Component1Id, N'ValRecPrincipal', null, null,
                    N'Credit', null, N'ReceivePrincipalAmount', N'TxnNo', N'LogicalDate', N'LogicalDate',
                    N'ReceiveCurrency', N'ReceiveCurrency', N'ReceivePrincipalAmount', N'ReceivePrincipalAmount', 0,
                    null,
                    null, @stateMaker, @stateDate, null, null);

            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @fcyRFcyPOpeningGroup2Component1Id
                    and GLCode = N'FXPositionRec')
        begin
            INSERT INTO dbo.accEngineAccountRule(Id, ComponentId, GLCode, CustomerCodeSource, CustomerAccountCodeSource,
                                                 DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                 ValueDateSource,
                                                 TxnDateSource, CcySource, FcySource, LcyEqvtSource, FcyAmtSource,
                                                 ReverseRebook, CommentSource, CommentRuleId, ModifiedBy, ModifiedDate,
                                                 ReverseTxnDateSource, ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @fcyRFcyPOpeningGroup2Component1Id, N'FXPositionRec', null, null,
                    N'Debit',
                    null, N'ReceivePrincipalAmount', N'TxnNo', N'LogicalDate', N'LogicalDate', N'ReceiveCurrency',
                    N'ReceiveCurrency', N'ReceivePrincipalAmount', N'ReceivePrincipalAmount', 0, null, null,
                    @stateMaker,
                    @stateDate, null, null);

            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @fcyRFcyPOpeningGroup2Component1Id
                    and GLCode = N'FXPositionLCY')
        begin
            INSERT INTO dbo.accEngineAccountRule(Id, ComponentId, GLCode, CustomerCodeSource, CustomerAccountCodeSource,
                                                 DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                 ValueDateSource,
                                                 TxnDateSource, CcySource, FcySource, LcyEqvtSource, FcyAmtSource,
                                                 ReverseRebook, CommentSource, CommentRuleId, ModifiedBy, ModifiedDate,
                                                 ReverseTxnDateSource, ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @fcyRFcyPOpeningGroup2Component1Id, N'FXPositionLCY', null, null,
                    N'Credit', null, N'WeakAmountLCY', N'TxnNo', N'LogicalDate', N'LogicalDate', N'LocalCCY',
                    N'WeakAmountCCY',
                    N'WeakAmountLCY', N'WeakAmountLCY', 0, null, null, @stateMaker, @stateDate, null, null);

            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @fcyRFcyPOpeningGroup2Component2Id
                    and GLCode = N'ValPayPrincipal')
        begin
            INSERT INTO dbo.accEngineAccountRule(Id, ComponentId, GLCode, CustomerCodeSource, CustomerAccountCodeSource,
                                                 DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                 ValueDateSource,
                                                 TxnDateSource, CcySource, FcySource, LcyEqvtSource, FcyAmtSource,
                                                 ReverseRebook, CommentSource, CommentRuleId, ModifiedBy, ModifiedDate,
                                                 ReverseTxnDateSource, ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @fcyRFcyPOpeningGroup2Component2Id, N'ValPayPrincipal', null, null,
                    N'Debit', null, N'PayPrincipalAmount', N'TxnNo', N'LogicalDate', N'LogicalDate', N'PayCurrency',
                    N'PayCurrency', N'PayPrincipalAmount', N'PayPrincipalAmount', 0, null, null, @stateMaker,
                    @stateDate,
                    null, null);

            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @fcyRFcyPOpeningGroup2Component2Id
                    and GLCode = N'FXPositionPay')
        begin
            INSERT INTO dbo.accEngineAccountRule(Id, ComponentId, GLCode, CustomerCodeSource, CustomerAccountCodeSource,
                                                 DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                 ValueDateSource,
                                                 TxnDateSource, CcySource, FcySource, LcyEqvtSource, FcyAmtSource,
                                                 ReverseRebook, CommentSource, CommentRuleId, ModifiedBy, ModifiedDate,
                                                 ReverseTxnDateSource, ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @fcyRFcyPOpeningGroup2Component2Id, N'FXPositionPay', null, null,
                    N'Credit', null, N'PayPrincipalAmount', N'TxnNo', N'LogicalDate', N'LogicalDate', N'PayCurrency',
                    N'PayCurrency', N'PayPrincipalAmount', N'PayPrincipalAmount', 0, null, null, @stateMaker,
                    @stateDate,
                    null, null);

            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @fcyRFcyPOpeningGroup2Component2Id
                    and GLCode = N'FXPositionLCY')
        begin
            INSERT INTO dbo.accEngineAccountRule(Id, ComponentId, GLCode, CustomerCodeSource, CustomerAccountCodeSource,
                                                 DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                 ValueDateSource,
                                                 TxnDateSource, CcySource, FcySource, LcyEqvtSource, FcyAmtSource,
                                                 ReverseRebook, CommentSource, CommentRuleId, ModifiedBy, ModifiedDate,
                                                 ReverseTxnDateSource, ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @fcyRFcyPOpeningGroup2Component2Id, N'FXPositionLCY', null, null,
                    N'Debit',
                    null, N'WeakAmountLCY', N'TxnNo', N'LogicalDate', N'LogicalDate', N'LocalCCY', N'WeakAmountCCY',
                    N'WeakAmountLCY', N'WeakAmountLCY', 0, null, null, @stateMaker, @stateDate, null, null);

            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @fcyRFcyPOpeningGroup2Component3Id
                    and GLCode = N'ValPayContingentOffset')
        begin
            INSERT INTO dbo.accEngineAccountRule(Id, ComponentId, GLCode, CustomerCodeSource, CustomerAccountCodeSource,
                                                 DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                 ValueDateSource,
                                                 TxnDateSource, CcySource, FcySource, LcyEqvtSource, FcyAmtSource,
                                                 ReverseRebook, CommentSource, CommentRuleId, ModifiedBy, ModifiedDate,
                                                 ReverseTxnDateSource, ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @fcyRFcyPOpeningGroup2Component3Id, N'ValPayContingentOffset', null,
                    null,
                    N'Debit', null, N'PayPrincipalAmount', N'TxnNo', N'LogicalDate', N'LogicalDate', N'PayCurrency',
                    N'PayCurrency', N'PayPrincipalAmount', N'PayPrincipalAmount', 0, null, null, @stateMaker,
                    @stateDate,
                    null, null);

            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @fcyRFcyPOpeningGroup2Component3Id
                    and GLCode = N'ValPayContingent')
        begin
            INSERT INTO dbo.accEngineAccountRule(Id, ComponentId, GLCode, CustomerCodeSource, CustomerAccountCodeSource,
                                                 DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                 ValueDateSource,
                                                 TxnDateSource, CcySource, FcySource, LcyEqvtSource, FcyAmtSource,
                                                 ReverseRebook, CommentSource, CommentRuleId, ModifiedBy, ModifiedDate,
                                                 ReverseTxnDateSource, ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @fcyRFcyPOpeningGroup2Component3Id, N'ValPayContingent', null, null,
                    N'Credit', null, N'PayPrincipalAmount', N'TxnNo', N'LogicalDate', N'LogicalDate', N'PayCurrency',
                    N'PayCurrency', N'PayPrincipalAmount', N'PayPrincipalAmount', 0, null, null, @stateMaker,
                    @stateDate,
                    null, null);

            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @fcyRFcyPOpeningGroup2Component3Id
                    and GLCode = N'ValRecContingent')
        begin
            INSERT INTO dbo.accEngineAccountRule(Id, ComponentId, GLCode, CustomerCodeSource, CustomerAccountCodeSource,
                                                 DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                 ValueDateSource,
                                                 TxnDateSource, CcySource, FcySource, LcyEqvtSource, FcyAmtSource,
                                                 ReverseRebook, CommentSource, CommentRuleId, ModifiedBy, ModifiedDate,
                                                 ReverseTxnDateSource, ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @fcyRFcyPOpeningGroup2Component3Id, N'ValRecContingent', null, null,
                    N'Debit', null, N'ReceivePrincipalAmount', N'TxnNo', N'LogicalDate', N'LogicalDate',
                    N'ReceiveCurrency',
                    N'ReceiveCurrency', N'ReceivePrincipalAmount', N'ReceivePrincipalAmount', 0, null, null,
                    @stateMaker,
                    @stateDate, null, null);

            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @fcyRFcyPOpeningGroup2Component3Id
                    and GLCode = N'ValRecContingentOffset')
        begin
            INSERT INTO dbo.accEngineAccountRule(Id, ComponentId, GLCode, CustomerCodeSource, CustomerAccountCodeSource,
                                                 DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                 ValueDateSource,
                                                 TxnDateSource, CcySource, FcySource, LcyEqvtSource, FcyAmtSource,
                                                 ReverseRebook, CommentSource, CommentRuleId, ModifiedBy, ModifiedDate,
                                                 ReverseTxnDateSource, ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @fcyRFcyPOpeningGroup2Component3Id, N'ValRecContingentOffset', null,
                    null,
                    N'Credit', null, N'ReceivePrincipalAmount', N'TxnNo', N'LogicalDate', N'LogicalDate',
                    N'ReceiveCurrency', N'ReceiveCurrency', N'ReceivePrincipalAmount', N'ReceivePrincipalAmount', 0,
                    null,
                    null, @stateMaker, @stateDate, null, null);

            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @fcyRFcyPOpeningGroup2Component4Id
                    and GLCode = N'MatPayContingentOffset')
        begin
            INSERT INTO dbo.accEngineAccountRule(Id, ComponentId, GLCode, CustomerCodeSource, CustomerAccountCodeSource,
                                                 DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                 ValueDateSource,
                                                 TxnDateSource, CcySource, FcySource, LcyEqvtSource, FcyAmtSource,
                                                 ReverseRebook, CommentSource, CommentRuleId, ModifiedBy, ModifiedDate,
                                                 ReverseTxnDateSource, ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @fcyRFcyPOpeningGroup2Component4Id, N'MatPayContingentOffset', null,
                    null,
                    N'Debit', null, N'PayPrincipalAmount', N'TxnNo', N'LogicalDate', N'LogicalDate', N'PayCurrency',
                    N'PayCurrency', N'PayPrincipalAmount', N'PayPrincipalAmount', 0, null, null, @stateMaker,
                    @stateDate,
                    null, null);

            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @fcyRFcyPOpeningGroup2Component4Id
                    and GLCode = N'MatPayContingent')
        begin
            INSERT INTO dbo.accEngineAccountRule(Id, ComponentId, GLCode, CustomerCodeSource, CustomerAccountCodeSource,
                                                 DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                 ValueDateSource,
                                                 TxnDateSource, CcySource, FcySource, LcyEqvtSource, FcyAmtSource,
                                                 ReverseRebook, CommentSource, CommentRuleId, ModifiedBy, ModifiedDate,
                                                 ReverseTxnDateSource, ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @fcyRFcyPOpeningGroup2Component4Id, N'MatPayContingent', null, null,
                    N'Credit', null, N'PayPrincipalAmount', N'TxnNo', N'LogicalDate', N'LogicalDate', N'PayCurrency',
                    N'PayCurrency', N'PayPrincipalAmount', N'PayPrincipalAmount', 0, null, null, @stateMaker,
                    @stateDate,
                    null, null);

            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @fcyRFcyPOpeningGroup2Component4Id
                    and GLCode = N'MatRecContingent')
        begin
            INSERT INTO dbo.accEngineAccountRule(Id, ComponentId, GLCode, CustomerCodeSource, CustomerAccountCodeSource,
                                                 DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                 ValueDateSource,
                                                 TxnDateSource, CcySource, FcySource, LcyEqvtSource, FcyAmtSource,
                                                 ReverseRebook, CommentSource, CommentRuleId, ModifiedBy, ModifiedDate,
                                                 ReverseTxnDateSource, ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @fcyRFcyPOpeningGroup2Component4Id, N'MatRecContingent', null, null,
                    N'Debit', null, N'ReceivePrincipalAmount', N'TxnNo', N'LogicalDate', N'LogicalDate',
                    N'ReceiveCurrency',
                    N'ReceiveCurrency', N'ReceivePrincipalAmount', N'ReceivePrincipalAmount', 0, null, null,
                    @stateMaker,
                    @stateDate, null, null);

            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @fcyRFcyPOpeningGroup2Component4Id
                    and GLCode = N'MatRecContingentOffset')
        begin
            INSERT INTO dbo.accEngineAccountRule(Id, ComponentId, GLCode, CustomerCodeSource, CustomerAccountCodeSource,
                                                 DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                 ValueDateSource,
                                                 TxnDateSource, CcySource, FcySource, LcyEqvtSource, FcyAmtSource,
                                                 ReverseRebook, CommentSource, CommentRuleId, ModifiedBy, ModifiedDate,
                                                 ReverseTxnDateSource, ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @fcyRFcyPOpeningGroup2Component4Id, N'MatRecContingentOffset', null,
                    null,
                    N'Credit', null, N'ReceivePrincipalAmount', N'TxnNo', N'LogicalDate', N'LogicalDate',
                    N'ReceiveCurrency', N'ReceiveCurrency', N'ReceivePrincipalAmount', N'ReceivePrincipalAmount', 0,
                    null,
                    null, @stateMaker, @stateDate, null, null);

            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @fcyRFcyPRevaluationGroupComponent1Id
                    and GLCode = N'TotalMTMProfit')
        begin
            INSERT INTO dbo.accEngineAccountRule(Id, ComponentId, GLCode, CustomerCodeSource, CustomerAccountCodeSource,
                                                 DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                 ValueDateSource,
                                                 TxnDateSource, CcySource, FcySource, LcyEqvtSource, FcyAmtSource,
                                                 ReverseRebook, CommentSource, CommentRuleId, ModifiedBy, ModifiedDate,
                                                 ReverseTxnDateSource, ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @fcyRFcyPRevaluationGroupComponent1Id, N'TotalMTMProfit', null, null,
                    N'Debit', null, N'TotalMTMAmount', N'TxnNo', N'LogicalDate', N'LogicalDate', N'TotalMTMAmountCCY',
                    N'TotalMTMAmountCCY', N'TotalMTMAmount', N'TotalMTMAmount', 0, null, null, @stateMaker, @stateDate,
                    null, null);

            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @fcyRFcyPRevaluationGroupComponent1Id
                    and GLCode = N'FXPositionRec')
        begin
            INSERT INTO dbo.accEngineAccountRule(Id, ComponentId, GLCode, CustomerCodeSource, CustomerAccountCodeSource,
                                                 DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                 ValueDateSource,
                                                 TxnDateSource, CcySource, FcySource, LcyEqvtSource, FcyAmtSource,
                                                 ReverseRebook, CommentSource, CommentRuleId, ModifiedBy, ModifiedDate,
                                                 ReverseTxnDateSource, ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @fcyRFcyPRevaluationGroupComponent1Id, N'FXPositionRec', null, null,
                    N'Credit', null, N'TotalMTMAmount', N'TxnNo', N'LogicalDate', N'LogicalDate', N'TotalMTMAmountCCY',
                    N'TotalMTMAmountCCY', N'TotalMTMAmount', N'TotalMTMAmount', 0, null, null, @stateMaker, @stateDate,
                    null, null);

            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @fcyRFcyPRevaluationGroupComponent1Id
                    and GLCode = N'FXPositionLCY')
        begin
            INSERT INTO dbo.accEngineAccountRule(Id, ComponentId, GLCode, CustomerCodeSource, CustomerAccountCodeSource,
                                                 DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                 ValueDateSource,
                                                 TxnDateSource, CcySource, FcySource, LcyEqvtSource, FcyAmtSource,
                                                 ReverseRebook, CommentSource, CommentRuleId, ModifiedBy, ModifiedDate,
                                                 ReverseTxnDateSource, ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @fcyRFcyPRevaluationGroupComponent1Id, N'FXPositionLCY', null, null,
                    N'Debit', null, N'TotalMTMAmountLCY', N'TxnNo', N'LogicalDate', N'LogicalDate', N'LocalCCY',
                    N'TotalMTMAmountCCY', N'TotalMTMAmountLCY', N'TotalMTMAmountLCY', 0, null, null, @stateMaker, @stateDate,
                    null,
                    null);

            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @fcyRFcyPRevaluationGroupComponent1Id
                    and GLCode = N'CapitalGainFCY')
        begin
            INSERT INTO dbo.accEngineAccountRule(Id, ComponentId, GLCode, CustomerCodeSource, CustomerAccountCodeSource,
                                                 DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                 ValueDateSource,
                                                 TxnDateSource, CcySource, FcySource, LcyEqvtSource, FcyAmtSource,
                                                 ReverseRebook, CommentSource, CommentRuleId, ModifiedBy, ModifiedDate,
                                                 ReverseTxnDateSource, ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @fcyRFcyPRevaluationGroupComponent1Id, N'CapitalGainFCY', null, null,
                    N'Credit', null, N'TotalMTMAmountLCY', N'TxnNo', N'LogicalDate', N'LogicalDate', N'LocalCCY',
                    N'LocalCCY', N'TotalMTMAmountLCY', N'TotalMTMAmountLCY', 0, null, null, @stateMaker, @stateDate,
                    null,
                    null);

            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @fcyRFcyPRevaluationGroupComponent2Id
                    and GLCode = N'FXPositionPay')
        begin
            INSERT INTO dbo.accEngineAccountRule(Id, ComponentId, GLCode, CustomerCodeSource, CustomerAccountCodeSource,
                                                 DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                 ValueDateSource,
                                                 TxnDateSource, CcySource, FcySource, LcyEqvtSource, FcyAmtSource,
                                                 ReverseRebook, CommentSource, CommentRuleId, ModifiedBy, ModifiedDate,
                                                 ReverseTxnDateSource, ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @fcyRFcyPRevaluationGroupComponent2Id, N'FXPositionPay', null, null,
                    N'Debit', null, N'TotalMTMAmount', N'TxnNo', N'LogicalDate', N'LogicalDate', N'TotalMTMAmountCCY',
                    N'LocalCCY', N'TotalMTMAmount', N'TotalMTMAmount', 0, null, null, @stateMaker, @stateDate, null,
                    null);

            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @fcyRFcyPRevaluationGroupComponent2Id
                    and GLCode = N'TotalMTMLoss')
        begin
            INSERT INTO dbo.accEngineAccountRule(Id, ComponentId, GLCode, CustomerCodeSource, CustomerAccountCodeSource,
                                                 DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                 ValueDateSource,
                                                 TxnDateSource, CcySource, FcySource, LcyEqvtSource, FcyAmtSource,
                                                 ReverseRebook, CommentSource, CommentRuleId, ModifiedBy, ModifiedDate,
                                                 ReverseTxnDateSource, ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @fcyRFcyPRevaluationGroupComponent2Id, N'TotalMTMLoss', null, null,
                    N'Credit', null, N'TotalMTMAmount', N'TxnNo', N'LogicalDate', N'LogicalDate', N'TotalMTMAmountCCY',
                    N'TotalMTMAmountCCY', N'TotalMTMAmount', N'TotalMTMAmount', 0, null, null, @stateMaker, @stateDate,
                    null, null);

            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @fcyRFcyPRevaluationGroupComponent2Id
                    and GLCode = N'CapitalLossFCY')
        begin
            INSERT INTO dbo.accEngineAccountRule(Id, ComponentId, GLCode, CustomerCodeSource, CustomerAccountCodeSource,
                                                 DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                 ValueDateSource,
                                                 TxnDateSource, CcySource, FcySource, LcyEqvtSource, FcyAmtSource,
                                                 ReverseRebook, CommentSource, CommentRuleId, ModifiedBy, ModifiedDate,
                                                 ReverseTxnDateSource, ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @fcyRFcyPRevaluationGroupComponent2Id, N'CapitalLossFCY', null, null,
                    N'Debit', null, N'TotalMTMAmountLCY', N'TxnNo', N'LogicalDate', N'LogicalDate', N'LocalCCY',
                    N'LocalCCY', N'TotalMTMAmountLCY', N'TotalMTMAmountLCY', 0, null, null, @stateMaker, @stateDate,
                    null,
                    null);

            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @fcyRFcyPRevaluationGroupComponent2Id
                    and GLCode = N'FXPositionLCY')
        begin
            INSERT INTO dbo.accEngineAccountRule(Id, ComponentId, GLCode, CustomerCodeSource, CustomerAccountCodeSource,
                                                 DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                 ValueDateSource,
                                                 TxnDateSource, CcySource, FcySource, LcyEqvtSource, FcyAmtSource,
                                                 ReverseRebook, CommentSource, CommentRuleId, ModifiedBy, ModifiedDate,
                                                 ReverseTxnDateSource, ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @fcyRFcyPRevaluationGroupComponent2Id, N'FXPositionLCY', null, null,
                    N'Credit', null, N'TotalMTMAmountLCY', N'TxnNo', N'LogicalDate', N'LogicalDate', N'LocalCCY',
                    N'TotalMTMAmountCCY', N'TotalMTMAmountLCY', N'TotalMTMAmountLCY', 0, null, null, @stateMaker, @stateDate,
                    null,
                    null);

            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @fcyRFcyPPaymentGroupComponent1Id
                    and GLCode = N'IncomingPaymentFCY')
        begin
            INSERT INTO dbo.accEngineAccountRule(Id, ComponentId, GLCode, CustomerCodeSource, CustomerAccountCodeSource,
                                                 DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                 ValueDateSource,
                                                 TxnDateSource, CcySource, FcySource, LcyEqvtSource, FcyAmtSource,
                                                 ReverseRebook, CommentSource, CommentRuleId, ModifiedBy, ModifiedDate,
                                                 ReverseTxnDateSource, ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @fcyRFcyPPaymentGroupComponent1Id, N'IncomingPaymentFCY', null, null,
                    N'Debit', null, N'ReceivePeriodAmount', N'TxnNo', N'LogicalDate', N'LogicalDate',
                    N'ReceiveCurrency',
                    N'ReceiveCurrency', N'ReceivePeriodAmount', N'ReceivePeriodAmount', 0, null, null, @stateMaker,
                    @stateDate, null, null);

            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @fcyRFcyPPaymentGroupComponent1Id
                    and GLCode = N'FXPositionRec')
        begin
            INSERT INTO dbo.accEngineAccountRule(Id, ComponentId, GLCode, CustomerCodeSource, CustomerAccountCodeSource,
                                                 DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                 ValueDateSource,
                                                 TxnDateSource, CcySource, FcySource, LcyEqvtSource, FcyAmtSource,
                                                 ReverseRebook, CommentSource, CommentRuleId, ModifiedBy, ModifiedDate,
                                                 ReverseTxnDateSource, ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @fcyRFcyPPaymentGroupComponent1Id, N'FXPositionRec', null, null,
                    N'Credit',
                    null, N'ReceivePeriodAmount', N'TxnNo', N'LogicalDate', N'LogicalDate', N'ReceiveCurrency',
                    N'ReceiveCurrency', N'ReceivePeriodAmount', N'ReceivePeriodAmount', 0, null, null, @stateMaker,
                    @stateDate, null, null);

            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @fcyRFcyPPaymentGroupComponent1Id
                    and GLCode = N'FXPositionLCY')
        begin
            INSERT INTO dbo.accEngineAccountRule(Id, ComponentId, GLCode, CustomerCodeSource, CustomerAccountCodeSource,
                                                 DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                 ValueDateSource,
                                                 TxnDateSource, CcySource, FcySource, LcyEqvtSource, FcyAmtSource,
                                                 ReverseRebook, CommentSource, CommentRuleId, ModifiedBy, ModifiedDate,
                                                 ReverseTxnDateSource, ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @fcyRFcyPPaymentGroupComponent1Id, N'FXPositionLCY', null, null,
                    N'Debit',
                    null, N'ReceivePeriodAmountLCY', N'TxnNo', N'LogicalDate', N'LogicalDate', N'LocalCCY', N'ReceiveCurrency',
                    N'ReceivePeriodAmountLCY', N'ReceivePeriodAmountLCY', 0, null, null, @stateMaker, @stateDate, null,
                    null);

            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @fcyRFcyPPaymentGroupComponent1Id
                    and GLCode = N'InterestIncome')
        begin
            INSERT INTO dbo.accEngineAccountRule(Id, ComponentId, GLCode, CustomerCodeSource, CustomerAccountCodeSource,
                                                 DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                 ValueDateSource,
                                                 TxnDateSource, CcySource, FcySource, LcyEqvtSource, FcyAmtSource,
                                                 ReverseRebook, CommentSource, CommentRuleId, ModifiedBy, ModifiedDate,
                                                 ReverseTxnDateSource, ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @fcyRFcyPPaymentGroupComponent1Id, N'InterestIncome', null, null,
                    N'Credit', null, N'ReceivePeriodAmountLCY', N'TxnNo', N'LogicalDate', N'LogicalDate',
                    N'LocalCCY', N'LocalCCY', N'ReceivePeriodAmountLCY', N'ReceivePeriodAmountLCY', 0,
                    null,
                    null, @stateMaker, @stateDate, null, null);

            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @fcyRFcyPPaymentGroupComponent2Id
                    and GLCode = N'FXPositionPay')
        begin
            INSERT INTO dbo.accEngineAccountRule(Id, ComponentId, GLCode, CustomerCodeSource, CustomerAccountCodeSource,
                                                 DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                 ValueDateSource,
                                                 TxnDateSource, CcySource, FcySource, LcyEqvtSource, FcyAmtSource,
                                                 ReverseRebook, CommentSource, CommentRuleId, ModifiedBy, ModifiedDate,
                                                 ReverseTxnDateSource, ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @fcyRFcyPPaymentGroupComponent2Id, N'FXPositionPay', null, null,
                    N'Debit',
                    null, N'PayPeriodAmount', N'TxnNo', N'LogicalDate', N'LogicalDate', N'PayCurrency', N'PayCurrency',
                    N'PayPeriodAmount', N'PayPeriodAmount', 0, null, null, @stateMaker, @stateDate, null, null);

            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @fcyRFcyPPaymentGroupComponent2Id
                    and GLCode = N'OutgoingPaymentFCY')
        begin
            INSERT INTO dbo.accEngineAccountRule(Id, ComponentId, GLCode, CustomerCodeSource, CustomerAccountCodeSource,
                                                 DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                 ValueDateSource,
                                                 TxnDateSource, CcySource, FcySource, LcyEqvtSource, FcyAmtSource,
                                                 ReverseRebook, CommentSource, CommentRuleId, ModifiedBy, ModifiedDate,
                                                 ReverseTxnDateSource, ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @fcyRFcyPPaymentGroupComponent2Id, N'OutgoingPaymentFCY', null, null,
                    N'Credit', null, N'PayPeriodAmount', N'TxnNo', N'LogicalDate', N'LogicalDate', N'PayCurrency',
                    N'PayCurrency', N'PayPeriodAmount', N'PayPeriodAmount', 0, null, null, @stateMaker, @stateDate,
                    null,
                    null);

            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @fcyRFcyPPaymentGroupComponent2Id
                    and GLCode = N'InterestExpense')
        begin
            INSERT INTO dbo.accEngineAccountRule(Id, ComponentId, GLCode, CustomerCodeSource, CustomerAccountCodeSource,
                                                 DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                 ValueDateSource,
                                                 TxnDateSource, CcySource, FcySource, LcyEqvtSource, FcyAmtSource,
                                                 ReverseRebook, CommentSource, CommentRuleId, ModifiedBy, ModifiedDate,
                                                 ReverseTxnDateSource, ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @fcyRFcyPPaymentGroupComponent2Id, N'InterestExpense', null, null,
                    N'Debit', null, N'PayPeriodAmountLCY', N'TxnNo', N'LogicalDate', N'LogicalDate', N'LocalCCY',
                    N'LocalCCY', N'PayPeriodAmountLCY', N'PayPeriodAmountLCY', 0, null, null, @stateMaker,
                    @stateDate,
                    null, null);

            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @fcyRFcyPPaymentGroupComponent2Id
                    and GLCode = N'FXPositionLCY')
        begin
            INSERT INTO dbo.accEngineAccountRule(Id, ComponentId, GLCode, CustomerCodeSource, CustomerAccountCodeSource,
                                                 DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                 ValueDateSource,
                                                 TxnDateSource, CcySource, FcySource, LcyEqvtSource, FcyAmtSource,
                                                 ReverseRebook, CommentSource, CommentRuleId, ModifiedBy, ModifiedDate,
                                                 ReverseTxnDateSource, ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @fcyRFcyPPaymentGroupComponent2Id, N'FXPositionLCY', null, null,
                    N'Credit',
                    null, N'PayPeriodAmountLCY', N'TxnNo', N'LogicalDate', N'LogicalDate', N'LocalCCY', N'PayCurrency',
                    N'PayPeriodAmountLCY', N'PayPeriodAmountLCY', 0, null, null, @stateMaker, @stateDate, null, null);

            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @fcyRFcyPMaturationGroupComponent1Id
                    and GLCode = N'MatPayPrincipal')
        begin
            INSERT INTO dbo.accEngineAccountRule(Id, ComponentId, GLCode, CustomerCodeSource, CustomerAccountCodeSource,
                                                 DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                 ValueDateSource,
                                                 TxnDateSource, CcySource, FcySource, LcyEqvtSource, FcyAmtSource,
                                                 ReverseRebook, CommentSource, CommentRuleId, ModifiedBy, ModifiedDate,
                                                 ReverseTxnDateSource, ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @fcyRFcyPMaturationGroupComponent1Id, N'MatPayPrincipal', null, null,
                    N'Credit', null, N'PayPrincipalAmount', N'TxnNo', N'LogicalDate', N'LogicalDate', N'PayCurrency',
                    N'PayCurrency', N'PayPrincipalAmount', N'PayPrincipalAmount', 0, null, null, @stateMaker,
                    @stateDate,
                    null, null);

            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @fcyRFcyPMaturationGroupComponent1Id
                    and GLCode = N'FXPositionPay')
        begin
            INSERT INTO dbo.accEngineAccountRule(Id, ComponentId, GLCode, CustomerCodeSource, CustomerAccountCodeSource,
                                                 DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                 ValueDateSource,
                                                 TxnDateSource, CcySource, FcySource, LcyEqvtSource, FcyAmtSource,
                                                 ReverseRebook, CommentSource, CommentRuleId, ModifiedBy, ModifiedDate,
                                                 ReverseTxnDateSource, ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @fcyRFcyPMaturationGroupComponent1Id, N'FXPositionPay', null, null,
                    N'Debit', null, N'PayPrincipalAmount', N'TxnNo', N'LogicalDate', N'LogicalDate', N'PayCurrency',
                    N'PayCurrency', N'PayPrincipalAmount', N'PayPrincipalAmount', 0, null, null, @stateMaker,
                    @stateDate,
                    null, null);

            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @fcyRFcyPMaturationGroupComponent1Id
                    and GLCode = N'FXPositionLCY')
        begin
            INSERT INTO dbo.accEngineAccountRule(Id, ComponentId, GLCode, CustomerCodeSource, CustomerAccountCodeSource,
                                                 DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                 ValueDateSource,
                                                 TxnDateSource, CcySource, FcySource, LcyEqvtSource, FcyAmtSource,
                                                 ReverseRebook, CommentSource, CommentRuleId, ModifiedBy, ModifiedDate,
                                                 ReverseTxnDateSource, ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @fcyRFcyPMaturationGroupComponent1Id, N'FXPositionLCY', null, null,
                    N'Credit', null, N'WeakAmountLCY', N'TxnNo', N'LogicalDate', N'LogicalDate', N'WeakAmountCCY',
                    N'LocalCCY',
                    N'WeakAmountLCY', N'WeakAmountLCY', 0, null, null, @stateMaker, @stateDate, null, null);

            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @fcyRFcyPMaturationGroupComponent2Id
                    and GLCode = N'MatRecPrincipal')
        begin
            INSERT INTO dbo.accEngineAccountRule(Id, ComponentId, GLCode, CustomerCodeSource, CustomerAccountCodeSource,
                                                 DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                 ValueDateSource,
                                                 TxnDateSource, CcySource, FcySource, LcyEqvtSource, FcyAmtSource,
                                                 ReverseRebook, CommentSource, CommentRuleId, ModifiedBy, ModifiedDate,
                                                 ReverseTxnDateSource, ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @fcyRFcyPMaturationGroupComponent2Id, N'MatRecPrincipal', null, null,
                    N'Debit', null, N'ReceivePrincipalAmount', N'TxnNo', N'LogicalDate', N'LogicalDate',
                    N'ReceiveCurrency',
                    N'ReceiveCurrency', N'ReceivePrincipalAmount', N'ReceivePrincipalAmount', 0, null, null,
                    @stateMaker,
                    @stateDate, null, null);

            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @fcyRFcyPMaturationGroupComponent2Id
                    and GLCode = N'FXPositionRec')
        begin
            INSERT INTO dbo.accEngineAccountRule(Id, ComponentId, GLCode, CustomerCodeSource, CustomerAccountCodeSource,
                                                 DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                 ValueDateSource,
                                                 TxnDateSource, CcySource, FcySource, LcyEqvtSource, FcyAmtSource,
                                                 ReverseRebook, CommentSource, CommentRuleId, ModifiedBy, ModifiedDate,
                                                 ReverseTxnDateSource, ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @fcyRFcyPMaturationGroupComponent2Id, N'FXPositionRec', null, null,
                    N'Credit', null, N'ReceivePrincipalAmount', N'TxnNo', N'LogicalDate', N'LogicalDate',
                    N'ReceiveCurrency', N'ReceiveCurrency', N'ReceivePrincipalAmount', N'ReceivePrincipalAmount', 0,
                    null,
                    null, @stateMaker, @stateDate, null, null);

            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @fcyRFcyPMaturationGroupComponent2Id
                    and GLCode = N'FXPositionLCY')
        begin
            INSERT INTO dbo.accEngineAccountRule(Id, ComponentId, GLCode, CustomerCodeSource, CustomerAccountCodeSource,
                                                 DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                 ValueDateSource,
                                                 TxnDateSource, CcySource, FcySource, LcyEqvtSource, FcyAmtSource,
                                                 ReverseRebook, CommentSource, CommentRuleId, ModifiedBy, ModifiedDate,
                                                 ReverseTxnDateSource, ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @fcyRFcyPMaturationGroupComponent2Id, N'FXPositionLCY', null, null,
                    N'Debit', null, N'WeakAmountLCY', N'TxnNo', N'LogicalDate', N'LogicalDate', N'WeakAmountCCY',
                    N'LocalCCY',
                    N'WeakAmountLCY', N'WeakAmountLCY', 0, null, null, @stateMaker, @stateDate, null, null);

            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @fcyRFcyPMaturationGroupComponent3Id
                    and GLCode = N'MatPayContingent')
        begin
            INSERT INTO dbo.accEngineAccountRule(Id, ComponentId, GLCode, CustomerCodeSource, CustomerAccountCodeSource,
                                                 DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                 ValueDateSource,
                                                 TxnDateSource, CcySource, FcySource, LcyEqvtSource, FcyAmtSource,
                                                 ReverseRebook, CommentSource, CommentRuleId, ModifiedBy, ModifiedDate,
                                                 ReverseTxnDateSource, ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @fcyRFcyPMaturationGroupComponent3Id, N'MatPayContingent', null, null,
                    N'Debit', null, N'PayPrincipalAmount', N'TxnNo', N'LogicalDate', N'LogicalDate', N'PayCurrency',
                    N'PayCurrency', N'PayPrincipalAmount', N'PayPrincipalAmount', 0, null, null, @stateMaker,
                    @stateDate,
                    null, null);

            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @fcyRFcyPMaturationGroupComponent3Id
                    and GLCode = N'MatPayContingentOffset')
        begin
            INSERT INTO dbo.accEngineAccountRule(Id, ComponentId, GLCode, CustomerCodeSource, CustomerAccountCodeSource,
                                                 DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                 ValueDateSource,
                                                 TxnDateSource, CcySource, FcySource, LcyEqvtSource, FcyAmtSource,
                                                 ReverseRebook, CommentSource, CommentRuleId, ModifiedBy, ModifiedDate,
                                                 ReverseTxnDateSource, ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @fcyRFcyPMaturationGroupComponent3Id, N'MatPayContingentOffset', null,
                    null, N'Credit', null, N'PayPrincipalAmount', N'TxnNo', N'LogicalDate', N'LogicalDate',
                    N'PayCurrency',
                    N'PayCurrency', N'PayPrincipalAmount', N'PayPrincipalAmount', 0, null, null, @stateMaker,
                    @stateDate,
                    null, null);

            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @fcyRFcyPMaturationGroupComponent3Id
                    and GLCode = N'MatRecContingentOffset')
        begin
            INSERT INTO dbo.accEngineAccountRule(Id, ComponentId, GLCode, CustomerCodeSource, CustomerAccountCodeSource,
                                                 DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                 ValueDateSource,
                                                 TxnDateSource, CcySource, FcySource, LcyEqvtSource, FcyAmtSource,
                                                 ReverseRebook, CommentSource, CommentRuleId, ModifiedBy, ModifiedDate,
                                                 ReverseTxnDateSource, ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @fcyRFcyPMaturationGroupComponent3Id, N'MatRecContingentOffset', null,
                    null, N'Debit', null, N'ReceivePrincipalAmount', N'TxnNo', N'LogicalDate', N'LogicalDate',
                    N'ReceiveCurrency', N'ReceiveCurrency', N'ReceivePrincipalAmount', N'ReceivePrincipalAmount', 0,
                    null,
                    null, @stateMaker, @stateDate, null, null);

            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @fcyRFcyPMaturationGroupComponent3Id
                    and GLCode = N'MatRecContingent')
        begin
            INSERT INTO dbo.accEngineAccountRule(Id, ComponentId, GLCode, CustomerCodeSource, CustomerAccountCodeSource,
                                                 DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                 ValueDateSource,
                                                 TxnDateSource, CcySource, FcySource, LcyEqvtSource, FcyAmtSource,
                                                 ReverseRebook, CommentSource, CommentRuleId, ModifiedBy, ModifiedDate,
                                                 ReverseTxnDateSource, ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @fcyRFcyPMaturationGroupComponent3Id, N'MatRecContingent', null, null,
                    N'Credit', null, N'ReceivePrincipalAmount', N'TxnNo', N'LogicalDate', N'LogicalDate',
                    N'ReceiveCurrency', N'ReceiveCurrency', N'ReceivePrincipalAmount', N'ReceivePrincipalAmount', 0,
                    null,
                    null, @stateMaker, @stateDate, null, null);

            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @fcyRFcyPMaturationGroupComponent4Id
                    and GLCode = N'83000000')
        begin
            INSERT INTO dbo.accEngineAccountRule(Id, ComponentId, GLCode, CustomerCodeSource, CustomerAccountCodeSource,
                                                 DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                 ValueDateSource,
                                                 TxnDateSource, CcySource, FcySource, LcyEqvtSource, FcyAmtSource,
                                                 ReverseRebook, CommentSource, CommentRuleId, ModifiedBy, ModifiedDate,
                                                 ReverseTxnDateSource, ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @fcyRFcyPMaturationGroupComponent4Id, N'83000000', null, null,
                    N'Debit',
                    null, N'TaxAmount', N'TxnNo', N'LogicalDate', N'LogicalDate', N'LocalCCY', N'LocalCCY',
                    N'TaxAmount',
                    N'TaxAmount', 0, null, null, @stateMaker, @stateDate, null, null);

            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    if not exists(select 1
                  from dbo.accEngineAccountRule
                  where ComponentId = @fcyRFcyPMaturationGroupComponent4Id
                    and GLCode = N'38000500')
        begin
            INSERT INTO dbo.accEngineAccountRule(Id, ComponentId, GLCode, CustomerCodeSource, CustomerAccountCodeSource,
                                                 DebitCredit, CalculationRuleId, AmountSource, TxnNoSource,
                                                 ValueDateSource,
                                                 TxnDateSource, CcySource, FcySource, LcyEqvtSource, FcyAmtSource,
                                                 ReverseRebook, CommentSource, CommentRuleId, ModifiedBy, ModifiedDate,
                                                 ReverseTxnDateSource, ReverseValueDateSource)
            VALUES (@lastAccEngineAccountRuleId, @fcyRFcyPMaturationGroupComponent4Id, N'38000500', null, null,
                    N'Credit',
                    null, N'TaxAmount', N'TxnNo', N'LogicalDate', N'LogicalDate', N'LocalCCY', N'LocalCCY',
                    N'TaxAmount',
                    N'TaxAmount', 0, null, null, @stateMaker, @stateDate, null, null);

            select @lastAccEngineAccountRuleId = @lastAccEngineAccountRuleId + 1
        end

    --#endregion
    ------------------------------------------------------------------------------------------------------------------------
    -- defNumberGen Update
    ------------------------------------------------------------------------------------------------------------------------
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