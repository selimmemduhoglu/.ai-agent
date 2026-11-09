
CREATE TABLE [dbo].[CollateralAgreement](
	[Id] [bigint] NOT NULL, --PK
	[Code] [nvarchar](250) NOT NULL,
	[Name] [nvarchar](1000) NOT NULL,
    [CounterpartyId] [int] NOT NULL,
	[Status] [int] NOT NULL, -- Enum (Draft/Aktif/Pasif)
	[MasterAgreement] [nvarchar](1000) NOT NULL,
	[CollateralDocument] [nvarchar](1000) NOT NULL,
	[BaseCurrencyCode] [nvarchar](3) NOT NULL,
	[Direction] [int] NOT NULL, -- Enum (Both/PostOnly/ReceiveOnly)
	[ValidFrom] [date] NOT NULL,
	[ValidTo] [date] NULL,
	DisputeToleranceAmount [decimal](38, 10) NOT NULL, 
	DisputeToleranceCurrencyCode [nvarchar](3) NOT NULL,
	--Flow Fields
	[StateId] [bigint] NOT NULL,
	[StateMaker] [nvarchar](80) NOT NULL,
	[StateDate] [datetime] NOT NULL,
	[CreatedBy] [nvarchar](80) NOT NULL,
	[CreatedDate] [datetime] NOT NULL,
	[PreviousStateId] [bigint] NULL,
	[PreviousStateMaker] [nvarchar](80) NULL,
	[PreviousStateDate] [datetime] NULL,
	[FlowId] [bigint] NOT NULL,
	[LastActionId] [bigint] NOT NULL,
	[PreviousActionId] [bigint] NULL
)


CREATE TABLE [dbo].[CollateralAgreementProduct](
	[Id] [bigint] NOT NULL, --PK
	[CollateralAgreementId] [bigint] NOT NULL, --FK
	[ProductCode] [nvarchar](50) NOT NULL,
	[SubProductCode] [nvarchar](50) NOT NULL,
	[MarginTypeId] [int] NOT NULL, --FK
    [IsActive] [bit] NOT NULL, --Default true
)

CREATE TABLE [dbo].[MarginType](
	[Id] [int] NOT NULL, --PK
	[Code] [nvarchar](50) NOT NULL,
	[Name] [nvarchar](500) NOT NULL,
	[Description] [nvarchar](1000) NULL,
    [IsActive] [bit] NOT NULL, --Default true
)

/* Margin Types
VM - Variation Margin
IM - Initial Margin
IA - Independent Amount
Other - Other
*/

CREATE TABLE [dbo].[CollateralAgreementRule](
	[Id] [bigint] NOT NULL, --PK
	[CollateralAgreementId] [bigint] NOT NULL, --FK
	[PartyType] [int] NOT NULL, -- Enum (Own/Counterparty)
	[ThresholdAmount] [decimal](38, 10) NOT NULL, 
	[MinimumTransferAmount] [decimal](38, 10) NOT NULL, 
	[RoundingAmount] [decimal](38, 10) NOT NULL, 
	[RoundingMethodType] [int] NOT NULL, -- Enum (Nearest/Up/Down)
	[CurrencyCode] [nvarchar](3) NOT NULL
)

CREATE TABLE [dbo].[CollateralDefinition](
	[Id] [bigint] NOT NULL, --PK
	[Code] [nvarchar](250) NOT NULL,
	[Name] [nvarchar](1000) NOT NULL,
	[CollateralAgreementId] [bigint] NULL,
	[CounterpartyId] [int] NOT NULL,
	[CollateralType] [int] NOT NULL, -- Enum (Cash/Security)
	[Status] [int] NOT NULL, -- Enum (Draft/Aktif/Pasif)
	[SettlementInstrumentType] [int] NOT NULL, -- Enum (AccountTransfer/SecurityTransfer)

	--CashFields
	[CashEligibilityDirection] [int] NULL, -- Enum (Both/PostOnly/ReceiveOnly)
    [CashEligibilityCurrencies] [nvarchar](1000) NULL, -- Muti ccy with ;
	[CashValuationCurrencyCode] [nvarchar](3) NULL,
	[CashValidFrom] [date] NULL,
	[CashValidTo] [date] NULL,
	[CashSettlementAccountingMapping] [int] NULL, -- Enum (CurrencyBased/DeskSpecific)
	[CashInterestAccountingMapping] [int] NULL, -- Enum (CurrencyBased/NoMapping)
	[CashDefaultSSIMapping] [int] NULL, -- Enum (CurrencyBasedSSI/CounterpartyDefaultSSI)
	[CashRateTypeId] [int] NULL, -- FK RateType
	[CashFloatingRateTypeId] [int] NULL, -- FK FloatingRateType
	[CashSpread] [decimal](18, 10) NULL,
	[CashFixedRate] [decimal](18, 10) NULL,
	[CashInterestMethodId] [int] NULL, -- FK InterestMethod
    [CashDateBasisCode] [nvarchar](4) NULL,
	[CashPaymentFrequencyId] [int] NULL,
	[CashBusinessDayRuleType] [int] NULL, -- Enum (ModifiedFollowing/Following/Preceding)
    [IsNegativeRateAllowed] [bit] NOT NULL, --default false


	--Flow Fields
	[StateId] [bigint] NOT NULL,
	[StateMaker] [nvarchar](80) NOT NULL,
	[StateDate] [datetime] NOT NULL,
	[CreatedBy] [nvarchar](80) NOT NULL,
	[CreatedDate] [datetime] NOT NULL,
	[PreviousStateId] [bigint] NULL,
	[PreviousStateMaker] [nvarchar](80) NULL,
	[PreviousStateDate] [datetime] NULL,
	[FlowId] [bigint] NOT NULL,
	[LastActionId] [bigint] NOT NULL,
	[PreviousActionId] [bigint] NULL
)



CREATE TABLE [dbo].[RateType](
	[Id] [int] NOT NULL,
	[Code] [nvarchar](50) NULL,
	[Name] [nvarchar](50) NULL,
	[Description] [nvarchar](100) NULL,
	[IsEnabled] [bit] NULL
)


CREATE TABLE [dbo].[FloatingRateType](
	[Id] [int] NOT NULL,
	[Code] [nvarchar](50) NOT NULL,
	[Name] [nvarchar](50) NULL,
	[Description] [nvarchar](100) NULL,
	[IsEnabled] [bit] NULL,
	[Currency] [nvarchar](100) NOT NULL,
	[PointId] [int] NOT NULL
)

CREATE TABLE [dbo].[InterestMethod](
	[Id] [int] NOT NULL,
	[Code] [nvarchar](50) NULL,
	[Name] [nvarchar](50) NULL,
	[Description] [nvarchar](100) NULL,
	[IsEnabled] [bit] NULL
)

CREATE TABLE [dbo].[InterestMethodFrequency](
	[Id] [int] NOT NULL,
	[Code] [nvarchar](50) NULL,
	[Name] [nvarchar](50) NULL,
	[Description] [nvarchar](100) NULL,
	[IsEnabled] [bit] NULL
)

CREATE TABLE [dbo].[DateBasis](
	[BasisCode] [nvarchar](4) NOT NULL,
	[BasisName] [nvarchar](80) NULL,
	[NumberOfDays] [smallint] NULL,
	[Denominator] [smallint] NULL,
	[StateId] [int] NOT NULL,
	[StateMaker] [nvarchar](80) NULL,
	[StateDate] [datetime] NOT NULL
)



CREATE TABLE [dbo].[CollateralTransaction](
	[Id] [bigint] NOT NULL, --PK
	[CollateralDefinitionId] [bigint] NOT NULL, --FK
	[CounterpartyId] [int] NOT NULL,
	[PortfolioId] [int] NOT NULL,
	[InputDateTime] [datetime] NOT NULL,
	[Trader] [nvarchar](80) NOT NULL,
	[LogicalReference] [nvarchar](50) NOT NULL,
	[BusinessKey] [bigint] NOT NULL,
	[CollateralAgreementId] [bigint] NULL, --FK
	--Payment Fields
	[CashSendConfirmation] [bit] NOT NULL,
	[CashSendPayment] [bit] NOT NULL,
	[CashSendNoticeToReceive] [bit] NOT NULL,
	[CashPaymentInstructionTypeId] [int] NULL,
	[CashSettlementTypeId] [int] NULL,
	[CashInstructions] [nvarchar](1000) NULL,
	[CashSwiftConfirmationMessageStatus] [nvarchar](50) NULL,
	[CashSwiftPaymentMessageStatus] [nvarchar](50) NULL,
	[CashDomesticPaymentMessageStatus] [nvarchar](50) NULL,
	[CashOutgoingCorrespondentId] [int] NULL,
	[CashOutgoingCorrespondentAccountNumber] [bigint] NULL,
	[CashOutgoingCorrespondentAccountGLCode] [nvarchar](50) NULL,
	[CashOutgoingPaymentAccountingType] [nvarchar](10) NULL,
	[CashOutgoingPaymentAccountingGLType] [nvarchar](50) NULL,
	[CashOutgoingPaymentAccountingGL] [nvarchar](50) NULL,
	[CashIncomingCorrespondentId] [int] NULL,
	[CashIncomingCorrespondentAccountNumber] [bigint] NULL,
	[CashIncomingCorrespondentAccountGLCode] [nvarchar](50) NULL,
	[CashIncomingPaymentAccountingType] [nvarchar](10) NULL,
	[CashIncomingPaymentAccountingGLType] [nvarchar](50) NULL,
	[CashIncomingPaymentAccountingGL] [nvarchar](50) NULL,
	[CashTheirBeneficiaryCorrespondentName] [nvarchar](500) NULL,
	[CashTheirBeneficiaryCorrespondentSwiftCode] [nvarchar](50) NULL,
	[CashTheirBeneficiaryCorrespondentAccountNumber] [nvarchar](500) NULL,
	[CashTheirBeneficiaryCorrespondentId] [int] NULL,
	[CashTheirBeneficiaryCorrespondentGLCode] [nvarchar](50) NULL,
	[CashTheirSenderCorrespondentName] [nvarchar](500) NULL,
	[CashTheirSenderCorrespondentSwiftCode] [nvarchar](50) NULL,
	[CashTheirSenderCorrespondentAccountNumber] [nvarchar](500) NULL,
	[CashTheirSenderCorrespondentId] [int] NULL,
	[CashTheirSenderCorrespondentGLCode] [nvarchar](50) NULL,
	--Flow Fields
	[StateId] [bigint] NOT NULL,
	[StateMaker] [nvarchar](80) NOT NULL,
	[StateDate] [datetime] NOT NULL,
	[CreatedBy] [nvarchar](80) NOT NULL,
	[CreatedDate] [datetime] NOT NULL,
	[PreviousStateId] [bigint] NULL,
	[PreviousStateMaker] [nvarchar](80) NULL,
	[PreviousStateDate] [datetime] NULL,
	[FlowId] [bigint] NOT NULL,
	[LastActionId] [bigint] NOT NULL,
	[PreviousActionId] [bigint] NULL
)

CREATE TABLE [dbo].[CollateralTransactionDetail](
	[Id] [bigint] NOT NULL, --PK
	[TransactionId] [bigint] NOT NULL, --FK
	[TransactionType] [int] NOT NULL, -- Enum (Increase/Decrease)
	[MarginTypeId] [int] NOT NULL, --FK
	[TradeDate] [date] NOT NULL,
	[ValueDate] [date] NOT NULL,
	[CurrentBalance] [decimal](38, 10) NULL,
	[ValuationCurrencyCode] [nvarchar](3) NULL,
	--Cash Fields
	[CashAmount] [decimal](38, 10) NULL,
	[CashCurrencyCode] [nvarchar](3) NULL,
	[CashMinimumAmount] [decimal](38, 10) NULL,
	[CashFXRate] [decimal](38, 10) NULL,
	[CashFXAdjustment] [decimal](38, 10) NULL,
	[CashTransactionAmount] [decimal](38, 10) NULL,
	[CashAdjustmentEligibleAmount] [decimal](38, 10) NULL,
	[IsFxConversionRequired] [bit] NOT NULL, -- default false
	--Payment Fields
	[CashSendConfirmation] [bit] NOT NULL,
	[CashSendPayment] [bit] NOT NULL,
	[CashSendNoticeToReceive] [bit] NOT NULL,
	[CashPaymentInstructionTypeId] [int] NULL,
	[CashSettlementTypeId] [int] NULL,
	[CashInstructions] [nvarchar](1000) NULL,
	[CashSwiftConfirmationMessageStatus] [nvarchar](50) NULL,
	[CashSwiftPaymentMessageStatus] [nvarchar](50) NULL,
	[CashDomesticPaymentMessageStatus] [nvarchar](50) NULL,
	[CashOutgoingCorrespondentId] [int] NULL,
	[CashOutgoingCorrespondentAccountNumber] [bigint] NULL,
	[CashOutgoingCorrespondentAccountGLCode] [nvarchar](50) NULL,
	[CashOutgoingPaymentAccountingType] [nvarchar](10) NULL,
	[CashOutgoingPaymentAccountingGLType] [nvarchar](50) NULL,
	[CashOutgoingPaymentAccountingGL] [nvarchar](50) NULL,
	[CashIncomingCorrespondentId] [int] NULL,
	[CashIncomingCorrespondentAccountNumber] [bigint] NULL,
	[CashIncomingCorrespondentAccountGLCode] [nvarchar](50) NULL,
	[CashIncomingPaymentAccountingType] [nvarchar](10) NULL,
	[CashIncomingPaymentAccountingGLType] [nvarchar](50) NULL,
	[CashIncomingPaymentAccountingGL] [nvarchar](50) NULL,
	[CashTheirBeneficiaryCorrespondentName] [nvarchar](500) NULL,
	[CashTheirBeneficiaryCorrespondentSwiftCode] [nvarchar](50) NULL,
	[CashTheirBeneficiaryCorrespondentAccountNumber] [nvarchar](500) NULL,
	[CashTheirBeneficiaryCorrespondentId] [int] NULL,
	[CashTheirBeneficiaryCorrespondentGLCode] [nvarchar](50) NULL,
	[CashTheirSenderCorrespondentName] [nvarchar](500) NULL,
	[CashTheirSenderCorrespondentSwiftCode] [nvarchar](50) NULL,
	[CashTheirSenderCorrespondentAccountNumber] [nvarchar](500) NULL,
	[CashTheirSenderCorrespondentId] [int] NULL,
	[CashTheirSenderCorrespondentGLCode] [nvarchar](50) NULL,
	--Flow Fields
	[StateId] [bigint] NOT NULL,
	[StateMaker] [nvarchar](80) NOT NULL,
	[StateDate] [datetime] NOT NULL,
	[CreatedBy] [nvarchar](80) NOT NULL,
	[CreatedDate] [datetime] NOT NULL,
	[PreviousStateId] [bigint] NULL,
	[PreviousStateMaker] [nvarchar](80) NULL,
	[PreviousStateDate] [datetime] NULL,
	[FlowId] [bigint] NOT NULL,
	[LastActionId] [bigint] NOT NULL,
	[PreviousActionId] [bigint] NULL
)

CREATE TABLE [dbo].[Portfolio](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Code] [nvarchar](40) NOT NULL,
	[Name] [nvarchar](80) NULL,
	[ParentId] [int] NULL,
	[AccountingMethod] [int] NULL,
	[LocalCcy] [nvarchar](3) NULL,
	[CountryCode] [nvarchar](3) NULL,
	[InventoryTypeId] [int] NULL,
	[LegalVehicleId] [int] NULL,
	[FunctionalCcy] [nvarchar](3) NULL,
	[Type] [int] NOT NULL,
	[Path] [nvarchar](250) NULL,
	[StateId] [int] NULL,
	[StateMaker] [nvarchar](80) NULL,
	[StateDate] [datetime] NULL,
	[AccountingEnable] [bit] NULL,
	[HandOffEnable] [bit] NULL,
	[FCCLPortfolio] [bit] NULL,
	[Module] [nvarchar](25) NULL,
	[IsActive] [bit] NULL,
)


CREATE TABLE [dbo].[Customer](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[ShortName] [nvarchar](255) NULL,
	[Name] [nvarchar](255) NULL,
	[Ccy] [nvarchar](3) NULL,
	[BranchId] [int] NULL,
	[SIC] [nvarchar](3) NULL,
	[BusinessSegmentCode] [nvarchar](16) NULL,
	[CustomerRoleFlags] [int] NULL,
	[ActiveFromDate] [datetime] NULL,
	[ActiveToDate] [datetime] NULL,
	[Language] [int] NULL,
	[Attention] [nvarchar](255) NULL,
	[AccountOfficer] [nvarchar](200) NULL,
	[Address] [nvarchar](250) NULL,
	[City] [nvarchar](200) NULL,
	[AccountNumber] [nvarchar](20) NULL,
	[CountryCode] [nvarchar](3) NULL,
	[FaxNo] [nvarchar](18) NULL,
	[Email] [nvarchar](200) NULL,
	[SWIFTID] [nvarchar](20) NULL,
	[PreferenceFlags] [int] NULL,
	[TaxCode] [nvarchar](10) NULL,
	[TaxOfficeCode] [nvarchar](25) NULL,
	[LastImportDate] [datetime] NULL,
	[ReportTypeFlags] [int] NULL,
	[BankCode] [nvarchar](3) NULL,
	[BankId] [int] NULL,
	[SSN] [nvarchar](15) NULL,
	[Block] [int] NULL,
	[StateId] [int] NOT NULL,
	[StateMaker] [nvarchar](80) NOT NULL,
	[StateDate] [datetime] NOT NULL,
	[IBAN] [nvarchar](50) NULL,
	[LEICode] [nvarchar](30) NULL,
	[ExternalCustomerId] [bigint] NULL,
	[SectorOffShore] [nvarchar](10) NULL,
	[InvestorTypeId] [int] NULL,
	[MKKNo] [nvarchar](50) NULL,
	[SuitabilityTestScore] [nvarchar](50) NULL,
	[IsFinancialInstitution] [bit] NULL,
	[CustomerTypeId] [int] NULL,
	[SectorTypeId] [int] NULL,
	[CorporateTypeId] [int] NULL,
	[CorporateDetailTypeId] [int] NULL,
	[BaseNo] [nvarchar](30) NULL,
	[TakasMemberCode] [nvarchar](25) NULL,
	[BankEftCode] [nvarchar](6) NULL,
	[NaceCode] [nvarchar](10) NULL,
	[CounterpartyLimit] [decimal](18, 2) NULL,
	[TawarruqContractDate] [date] NULL,
	[AccountName] [nvarchar](300) NULL
)

