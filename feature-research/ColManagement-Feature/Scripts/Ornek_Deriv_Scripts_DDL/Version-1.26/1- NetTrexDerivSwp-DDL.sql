---Check Database Name
USE [NetTrexDerivSWP]

GO

/****** Object:  Table [dbo].[AccEftAccount]    Script Date: 24.01.2025 18:29:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AccEftAccount](
	[Id] [int] NOT NULL,
	[Ccy] [nvarchar](3) NULL,
	[EftAccount] [nvarchar](20) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[AccEngineGeneratedAccountRule]    Script Date: 24.01.2025 18:29:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AccEngineGeneratedAccountRule](
	[Id] [int] NOT NULL,
	[PackageNo] [int] NULL,
	[ComponentId] [int] NOT NULL,
	[RuleId] [int] NOT NULL,
	[GLCode] [nvarchar](30) NOT NULL,
	[CustomerCode] [nvarchar](30) NULL,
	[CustomerAccountCode] [nvarchar](30) NULL,
	[DebitCredit] [nvarchar](10) NOT NULL,
	[Amount] [decimal](38, 10) NOT NULL,
	[TxnNo] [int] NOT NULL,
	[TxnRef] [nvarchar](50) NOT NULL,
	[ReverseRebook] [bit] NOT NULL,
	[AccountingValueDate] [date] NOT NULL,
	[AccountingGenerationDate] [date] NOT NULL,
	[Ccy] [nvarchar](3) NOT NULL,
	[Fcy] [nvarchar](3) NOT NULL,
	[LcyEquivalent] [decimal](38, 10) NOT NULL,
	[FcyEquivalent] [decimal](38, 10) NOT NULL,
	[Comment] [nvarchar](250) NOT NULL,
	[StateDate] [datetime] NOT NULL,
	[MainId] [int] NULL,
	[AccAccountMapId] [int] NULL,
	[Source] [nvarchar](500) NULL,
	[TargetMainGL] [nvarchar](500) NULL,
 CONSTRAINT [PK_AccEngineGeneratedAccountRule] PRIMARY KEY CLUSTERED
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[AccEntry]    Script Date: 24.01.2025 18:29:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AccEntry](
	[Id] [int] NOT NULL,
	[EngineId] [int] NOT NULL,
	[TxnId] [int] NOT NULL,
	[BondId] [int] NULL,
	[TxnTypeCode] [nvarchar](10) NOT NULL,
	[DebitCredit] [nvarchar](20) NOT NULL,
	[Amount] [decimal](38, 10) NOT NULL,
	[GLCode] [nvarchar](30) NOT NULL,
	[CustomerCode] [nvarchar](30) NULL,
	[CustomerAccountCode] [nvarchar](30) NULL,
	[GenerationDate] [date] NOT NULL,
	[ValueDate] [date] NOT NULL,
	[Ccy] [nvarchar](3) NOT NULL,
	[HandoffDate] [datetime] NULL,
	[DeleteDate] [datetime] NULL,
	[Comment] [nvarchar](250) NOT NULL,
	[LcyEquivalent] [decimal](38, 10) NOT NULL,
	[FcyEquivalent] [decimal](38, 10) NOT NULL,
	[RuleId] [int] NOT NULL,
	[Fcy] [nvarchar](3) NOT NULL,
	[Notes] [nvarchar](250) NULL,
	[ReverseId] [int] NULL,
	[StateDate] [datetime] NOT NULL,
	[BusinessKey] [bigint] NOT NULL,
	[AccEntryMainId] [int] NOT NULL,
	[FxRate] [decimal](18, 0) NULL,
	[StatisticCode] [nvarchar](250) NULL,
	[SeqNumber] [int] NOT NULL,
	[Type] [int] NOT NULL,
	[Flag] [int] NULL,
	[AccAccountMapId] [int] NULL,
	[Source] [nvarchar](500) NULL,
	[TargetMainGL] [nvarchar](500) NULL,
 CONSTRAINT [PK_AccEntry] PRIMARY KEY CLUSTERED
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[AccEntryMain]    Script Date: 24.01.2025 18:29:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AccEntryMain](
	[Id] [int] NOT NULL,
	[Description] [nvarchar](500) NOT NULL,
	[ValueDate] [date] NOT NULL,
	[BusinessKey] [bigint] NOT NULL,
	[MessageKey] [bigint] NOT NULL,
	[TxnId] [int] NOT NULL,
	[TxnTypeCode] [nvarchar](10) NOT NULL,
	[IsReverse] [bit] NOT NULL,
	[ReverseId] [int] NOT NULL,
	[ExternalState] [nvarchar](50) NULL,
	[ExternalStateDescription] [nvarchar](500) NULL,
	[StateId] [int] NOT NULL,
	[StateDate] [datetime] NOT NULL,
	[StateMaker] [nvarchar](80) NOT NULL,
	[ProductCode] [nvarchar](10) NOT NULL,
	[Type] [int] NOT NULL,
	[Flag] [int] NULL,
 CONSTRAINT [PK_AccEntryMain] PRIMARY KEY CLUSTERED
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[AccEntryType]    Script Date: 24.01.2025 18:29:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AccEntryType](
	[Id] [int] NULL,
	[Code] [nvarchar](255) NULL,
	[Name] [nvarchar](255) NULL,
	[ExternalCode] [nvarchar](255) NULL,
	[Description] [nvarchar](255) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[BatchItem]    Script Date: 24.01.2025 18:29:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BatchItem](
	[Id] [int] NOT NULL,
	[ItemOrder] [int] NOT NULL,
	[ItemID] [nvarchar](250) NOT NULL,
	[Name] [nvarchar](250) NOT NULL,
	[Severity] [int] NOT NULL,
	[State] [bit] NOT NULL,
	[ParentItemNo] [int] NOT NULL,
	[BatchSetId] [int] NOT NULL,
	[IsTransactional] [bit] NOT NULL,
	[StateId] [int] NOT NULL,
	[StateMaker] [nvarchar](80) NULL,
	[StateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_BatchItem] PRIMARY KEY CLUSTERED
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[BatchLog]    Script Date: 24.01.2025 18:29:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BatchLog](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[BatchSetId] [int] NOT NULL,
	[StartDate] [datetime] NOT NULL,
	[EndDate] [datetime] NULL,
	[ExecDate] [date] NOT NULL,
	[Status] [int] NOT NULL,
 CONSTRAINT [PK_BatchLog] PRIMARY KEY NONCLUSTERED
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[BatchLogDetail]    Script Date: 24.01.2025 18:29:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BatchLogDetail](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[BatchLogId] [int] NOT NULL,
	[BatchItemId] [int] NOT NULL,
	[Message] [text] NOT NULL,
	[LogDate] [datetime] NOT NULL,
	[ExecDate] [date] NOT NULL,
	[Status] [int] NOT NULL,
	[LogType] [int] NOT NULL,
	[Duration] [float] NULL,
 CONSTRAINT [PK_BatchLogDetail] PRIMARY KEY NONCLUSTERED
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[BatchSet]    Script Date: 24.01.2025 18:29:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BatchSet](
	[Id] [int] NOT NULL,
	[Name] [nvarchar](50) NOT NULL,
	[Description] [nvarchar](250) NULL,
	[StateId] [int] NULL,
	[StateMaker] [nvarchar](80) NULL,
	[StateDate] [datetime] NULL,
 CONSTRAINT [PK_BatchSet] PRIMARY KEY CLUSTERED
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Branch]    Script Date: 24.01.2025 18:29:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Branch](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Code] [nvarchar](20) NOT NULL,
	[LegalVehicleId] [int] NULL,
	[Name] [nvarchar](40) NULL,
	[Note] [nvarchar](250) NULL,
	[Attention] [nvarchar](80) NULL,
	[Address] [nvarchar](250) NULL,
	[City] [nvarchar](40) NULL,
	[ZipCode] [nvarchar](10) NULL,
	[Phone] [nvarchar](11) NULL,
	[Fax] [nvarchar](11) NULL,
	[Email] [nvarchar](80) NULL,
	[StateId] [int] NULL,
	[StateMaker] [nvarchar](80) NULL,
	[StateDate] [datetime] NULL,
 CONSTRAINT [PK_Branch] PRIMARY KEY CLUSTERED
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Calendar]    Script Date: 24.01.2025 18:29:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Calendar](
	[Id] [int] NOT NULL,
	[CurrencyCode] [nvarchar](3) NOT NULL,
	[Year] [int] NULL,
	[DayOfYear] [int] NULL,
	[CalNo] [int] NULL,
 CONSTRAINT [PK_Calendar] PRIMARY KEY CLUSTERED
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Chart]    Script Date: 24.01.2025 18:29:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Chart](
	[Id] [int] NOT NULL,
	[Name] [nvarchar](80) NOT NULL,
	[Description] [nvarchar](300) NULL,
	[StateId] [int] NULL,
	[StateMaker] [nvarchar](80) NULL,
	[StateDate] [datetime] NULL,
	[Code] [nvarchar](10) NOT NULL,
	[IsSystemDefinedChart] [bit] NULL,
	[IsUserAnalytics] [bit] NULL,
	[IsAdHocChart] [bit] NULL,
 CONSTRAINT [PK_Chart] PRIMARY KEY CLUSTERED
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Currency]    Script Date: 24.01.2025 18:29:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Currency](
	[Code] [nvarchar](3) NOT NULL,
	[Name] [nvarchar](50) NOT NULL,
	[IsHard] [bit] NULL,
	[IsSynthetic] [bit] NULL,
	[CanUseOnTxn] [bit] NULL,
	[ForeignCcy] [bit] NULL,
	[Disabled] [bit] NULL,
	[Pip] [float] NOT NULL,
	[BasisCode] [nvarchar](4) NOT NULL,
	[StateId] [int] NULL,
	[StateMaker] [nvarchar](80) NULL,
	[StateDate] [datetime] NULL,
	[Decimals] [smallint] NULL,
	[IsoCode] [nvarchar](3) NULL,
 CONSTRAINT [PK_Currency] PRIMARY KEY CLUSTERED
(
	[Code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [UQ_Currency_Code] UNIQUE NONCLUSTERED
(
	[Code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[CurrencyPair]    Script Date: 24.01.2025 18:29:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CurrencyPair](
	[FromCurrency] [nvarchar](3) NOT NULL,
	[ToCurrency] [nvarchar](3) NOT NULL,
	[SpotDays] [int] NOT NULL,
	[IsHardCurrency] [bit] NOT NULL,
	[IsCalculatedPair] [bit] NULL,
	[OrderNo] [int] NULL,
	[IsPM] [bit] NOT NULL,
	[StateId] [int] NULL,
	[StateMaker] [nvarchar](80) NULL,
	[StateDate] [datetime] NULL,
	[SwapPointFactor] [int] NULL,
 CONSTRAINT [PK_CurrencyPair] PRIMARY KEY CLUSTERED
(
	[FromCurrency] ASC,
	[ToCurrency] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[CusCustomer]    Script Date: 24.01.2025 18:29:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CusCustomer](
	[Id] [int] NOT NULL,
	[ShortName] [nvarchar](80) NULL,
	[Name] [nvarchar](255) NULL,
	[Ccy] [nvarchar](3) NULL,
	[BranchId] [int] NULL,
	[SIC] [nvarchar](3) NULL,
	[BusinessSegmentCode] [nvarchar](5) NULL,
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
	[StateMaker] [nvarchar](80) NULL,
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
 CONSTRAINT [PK_CusCustomer] PRIMARY KEY CLUSTERED
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DateBasis]    Script Date: 24.01.2025 18:29:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DateBasis](
	[BasisCode] [nvarchar](4) NOT NULL,
	[BasisName] [nvarchar](80) NULL,
	[NumberOfDays] [smallint] NULL,
	[Denominator] [smallint] NULL,
	[StateId] [int] NOT NULL,
	[StateMaker] [nvarchar](80) NULL,
	[StateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_DateBasis] PRIMARY KEY CLUSTERED
(
	[BasisCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DefCorporateDetailType]    Script Date: 24.01.2025 18:29:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DefCorporateDetailType](
	[Id] [int] NOT NULL,
	[CorporateTypeId] [int] NOT NULL,
	[Name] [nvarchar](255) NOT NULL,
	[Description] [nvarchar](500) NULL,
	[IsEnabled] [bit] NOT NULL,
	[CustomerRoleFlags] [int] NULL,
	[NotCustomerRoleFlags] [int] NULL,
 CONSTRAINT [PK_DefCorporateDetailType] PRIMARY KEY CLUSTERED
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DefCorporateType]    Script Date: 24.01.2025 18:29:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DefCorporateType](
	[Id] [int] NOT NULL,
	[Name] [nvarchar](255) NOT NULL,
	[Description] [nvarchar](500) NULL,
	[IsEnabled] [bit] NOT NULL,
	[StateId] [int] NOT NULL,
	[StateMaker] [nvarchar](80) NOT NULL,
	[StateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_DefCorporateType] PRIMARY KEY CLUSTERED
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DefCountry]    Script Date: 24.01.2025 18:29:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DefCountry](
	[CountryCode] [nvarchar](3) NOT NULL,
	[LocalCcy] [nvarchar](3) NOT NULL,
	[CountryName] [nvarchar](200) NULL,
	[FunctionalCcy] [nvarchar](3) NOT NULL,
	[Enabled] [smallint] NULL,
	[StateId] [int] NOT NULL,
	[StateMaker] [nvarchar](80) NULL,
	[StateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_DefCountry] PRIMARY KEY CLUSTERED
(
	[CountryCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DefJobCron]    Script Date: 24.01.2025 18:29:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DefJobCron](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Key] [nvarchar](50) NOT NULL,
	[Value] [nvarchar](100) NULL,
	[StateId] [int] NOT NULL,
	[StateMaker] [nvarchar](80) NULL,
	[StateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_DefJobCron] PRIMARY KEY CLUSTERED
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DefJobCronHistory]    Script Date: 24.01.2025 18:29:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DefJobCronHistory](
	[HistoryId] [int] IDENTITY(1,1) NOT NULL,
	[Id] [int] NULL,
	[Key] [nvarchar](50) NOT NULL,
	[Value] [nvarchar](100) NULL,
	[StateId] [int] NOT NULL,
	[StateMaker] [nvarchar](80) NULL,
	[StateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_DefJobCronHistory] PRIMARY KEY CLUSTERED
(
	[HistoryId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DefLegalVehicle]    Script Date: 24.01.2025 18:29:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DefLegalVehicle](
	[Id] [int] NOT NULL,
	[Code] [nvarchar](4) NOT NULL,
	[CountryCode] [nvarchar](3) NULL,
	[Name] [nvarchar](80) NULL,
	[CALMCode] [nvarchar](5) NULL,
	[Path] [nvarchar](250) NULL,
	[StateId] [int] NOT NULL,
	[StateMaker] [nvarchar](80) NULL,
	[StateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_DefLegalVehicle] PRIMARY KEY CLUSTERED
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DefNumberGen]    Script Date: 24.01.2025 18:29:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DefNumberGen](
	[EntityColumnType] [int] NOT NULL,
	[LastNumber] [int] NULL,
	[Definition] [nvarchar](255) NULL,
	[LastUpdateDate] [datetime] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DefRefNumGen]    Script Date: 24.01.2025 18:29:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DefRefNumGen](
	[TypeKey] [nvarchar](30) NOT NULL,
	[LastReference] [int] NULL,
 CONSTRAINT [PK_DefRefNumGen] PRIMARY KEY CLUSTERED
(
	[TypeKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DefTaxOffice]    Script Date: 24.01.2025 18:29:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DefTaxOffice](
	[Code] [nvarchar](25) NOT NULL,
	[CountryCode] [nvarchar](3) NULL,
	[Name] [nvarchar](200) NULL,
	[StateId] [int] NOT NULL,
	[StateMaker] [nvarchar](80) NULL,
	[StateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_DefTaxOffice] PRIMARY KEY CLUSTERED
(
	[Code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DerivativesRevaluation]    Script Date: 24.01.2025 18:29:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DerivativesRevaluation](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[CalculationDate] [date] NOT NULL,
	[GenerationDate] [datetime] NOT NULL,
	[TxnId] [int] NOT NULL,
	[LogicalReference] [nvarchar](80) NOT NULL,
	[ProductTypeId] [int] NOT NULL,
	[CounterpartyId] [int] NOT NULL,
	[InputDateTime] [datetime] NOT NULL,
	[ReceiveValueDate] [date] NOT NULL,
	[ReceiveMaturityDate] [date] NOT NULL,
	[PayValueDate] [date] NOT NULL,
	[PayMaturityDate] [date] NOT NULL,
	[PayOfUpdate] [date] NULL,
	[Trader] [nvarchar](80) NOT NULL,
	[ReceivePrincipalAmount] [decimal](38, 10) NOT NULL,
	[ReceiveCurrency] [nvarchar](3) NOT NULL,
	[ReceiveRateTypeId] [int] NOT NULL,
	[ReceiveRate] [decimal](18, 10) NULL,
	[ReceiveFloatingRateTypeId] [int] NULL,
	[ReceiveSpread] [int] NOT NULL,
	[ReceivePaymentFrequencyId] [int] NOT NULL,
	[ReceiveInterestMethodsId] [int] NOT NULL,
	[ReceiveInterestMethodsFrequencyId] [int] NOT NULL,
	[ReceiveDateBasisCode] [nvarchar](4) NOT NULL,
	[ReceiveIndexChartId] [int] NOT NULL,
	[ReceiveDaysInYear] [int] NOT NULL,
	[ReceivePaymentLagDays] [int] NOT NULL,
	[ReceiveFixingLagDays] [int] NOT NULL,
	[ReceiveAccrualSpotRate] [decimal](18, 10) NOT NULL,
	[ReceivePeriodNumber] [int] NOT NULL,
	[ReceivePeriodFixingDate] [date] NULL,
	[ReceivePeriodStartDate] [date] NOT NULL,
	[ReceivePeriodEndDate] [date] NOT NULL,
	[ReceivePeriodPaymentDate] [date] NOT NULL,
	[ReceivePeriodDaysInYear] [int] NOT NULL,
	[ReceivePeriodPrincipalAmount] [decimal](38, 10) NOT NULL,
	[ReceivePeriodDays] [int] NOT NULL,
	[ReceivePeriodDaysPassed] [int] NOT NULL,
	[ReceivePeriodDaysToMaturity] [int] NOT NULL,
	[ReceivePeriodRateTypeId] [int] NOT NULL,
	[ReceivePeriodRate] [decimal](18, 10) NOT NULL,
	[ReceivePeriodFloatingRateTypeId] [int] NULL,
	[ReceivePeriodSpread] [int] NOT NULL,
	[ReceivePeriodCCY] [nvarchar](3) NOT NULL,
	[ReceivePeriodAmount] [decimal](38, 10) NOT NULL,
	[ReceivePeriodLCY] [nvarchar](3) NOT NULL,
	[ReceivePeriodAmountLCY] [decimal](38, 10) NOT NULL,
	[ReceivePeriodAccrualRate] [decimal](18, 10) NOT NULL,
	[ReceivePeriodAccrualAmountIRR] [decimal](38, 10) NOT NULL,
	[ReceivePeriodAccrualAmountSL] [decimal](38, 10) NOT NULL,
	[ReceivePeriodAccrualAmountCCY] [nvarchar](3) NOT NULL,
	[ReceivePeriodAccrualAmountLCYIRR] [decimal](38, 10) NOT NULL,
	[ReceivePeriodAccrualAmountLCYSL] [decimal](38, 10) NOT NULL,
	[ReceivePeriodAccrualAmountLCY] [nvarchar](3) NOT NULL,
	[ReceivePrincipalAmountNPV] [decimal](38, 10) NOT NULL,
	[ReceivePrincipalAmountNPVCCY] [nvarchar](3) NOT NULL,
	[ReceivePrincipalAmountNPVLCY] [decimal](38, 10) NOT NULL,
	[ReceivePrincipalAmountNPVLCYCode] [nvarchar](3) NOT NULL,
	[ReceiveTotalAmountNPV] [decimal](38, 10) NOT NULL,
	[ReceiveTotalAmountNPVCCY] [nvarchar](3) NOT NULL,
	[ReceiveTotalAmountNPVLCY] [decimal](38, 10) NOT NULL,
	[ReceiveTotalAmountNPVLCYCode] [nvarchar](3) NOT NULL,
	[PayPrincipalAmount] [decimal](38, 10) NOT NULL,
	[PayCurrency] [nvarchar](3) NOT NULL,
	[PayRateTypeId] [int] NOT NULL,
	[PayRate] [decimal](18, 10) NULL,
	[PayFloatingRateTypeId] [int] NULL,
	[PaySpread] [int] NOT NULL,
	[PayPaymentFrequencyId] [int] NOT NULL,
	[PayInterestMethodsId] [int] NOT NULL,
	[PayInterestMethodsFrequencyId] [int] NOT NULL,
	[PayDateBasisCode] [nvarchar](4) NOT NULL,
	[PayIndexChartId] [int] NOT NULL,
	[PayDaysInYear] [int] NOT NULL,
	[PayPaymentLagDays] [int] NOT NULL,
	[PayFixingLagDays] [int] NOT NULL,
	[PayAccrualSpotRate] [decimal](18, 10) NOT NULL,
	[PayPeriodNumber] [int] NOT NULL,
	[PayPeriodFixingDate] [date] NULL,
	[PayPeriodStartDate] [date] NOT NULL,
	[PayPeriodEndDate] [date] NOT NULL,
	[PayPeriodPaymentDate] [date] NOT NULL,
	[PayPeriodDaysInYear] [int] NOT NULL,
	[PayPeriodPrincipalAmount] [decimal](38, 10) NOT NULL,
	[PayPeriodDays] [int] NOT NULL,
	[PayPeriodDaysPassed] [int] NOT NULL,
	[PayPeriodDaysToMaturity] [int] NOT NULL,
	[PayPeriodRateTypeId] [int] NOT NULL,
	[PayPeriodRate] [decimal](18, 10) NOT NULL,
	[PayPeriodFloatingRateTypeId] [int] NULL,
	[PayPeriodSpread] [int] NOT NULL,
	[PayPeriodCCY] [nvarchar](3) NOT NULL,
	[PayPeriodAmount] [decimal](38, 10) NOT NULL,
	[PayPeriodLCY] [nvarchar](3) NOT NULL,
	[PayPeriodAmountLCY] [decimal](38, 10) NOT NULL,
	[PayPeriodAccrualRate] [decimal](18, 10) NOT NULL,
	[PayPeriodAccrualAmountIRR] [decimal](38, 10) NOT NULL,
	[PayPeriodAccrualAmountSL] [decimal](38, 10) NOT NULL,
	[PayPeriodAccrualAmountCCY] [nvarchar](3) NOT NULL,
	[PayPeriodAccrualAmountLCYIRR] [decimal](38, 10) NOT NULL,
	[PayPeriodAccrualAmountLCYSL] [decimal](38, 10) NOT NULL,
	[PayPeriodAccrualAmountLCY] [nvarchar](3) NOT NULL,
	[PayPrincipalAmountNPV] [decimal](38, 10) NOT NULL,
	[PayPrincipalAmountNPVCCY] [nvarchar](3) NOT NULL,
	[PayPrincipalAmountNPVLCY] [decimal](38, 10) NOT NULL,
	[PayPrincipalAmountNPVLCYCode] [nvarchar](3) NOT NULL,
	[PayTotalAmountNPV] [decimal](38, 10) NOT NULL,
	[PayTotalAmountNPVCCY] [nvarchar](3) NOT NULL,
	[PayTotalAmountNPVLCY] [decimal](38, 10) NOT NULL,
	[PayTotalAmountNPVLCYCode] [nvarchar](3) NOT NULL,
	[TotalMTMAmount] [decimal](38, 10) NOT NULL,
	[TotalMTMAmountCCY] [nvarchar](3) NOT NULL,
	[TotalMTMAmountLCY] [decimal](38, 10) NOT NULL,
	[TotalMTMAmountLCYCode] [nvarchar](3) NOT NULL,
    [TotalMTMAmountSpotRate] [decimal](18,10) null,
	[AccrualSpotRateABM] [nvarchar](1) NOT NULL,
	[AccEntryMainId] [int] NOT NULL,
 CONSTRAINT [PK_DerivativesRevaluation] PRIMARY KEY CLUSTERED
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[FloatingRateType]    Script Date: 24.01.2025 18:29:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FloatingRateType](
	[Id] [int] NOT NULL,
	[Code] [nvarchar](50) NOT NULL,
	[Name] [nvarchar](50) NULL,
	[Description] [nvarchar](100) NULL,
	[IsEnabled] [bit] NULL,
	[Currency] [nvarchar](100) NOT NULL,
	[PointId] [int] NOT NULL,
	[ChartId] [int] NULL,
 CONSTRAINT [PK_FloatingRateType] PRIMARY KEY CLUSTERED
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[FlowType]    Script Date: 24.01.2025 18:29:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FlowType](
	[Id] [int] NOT NULL,
	[Code] [nvarchar](50) NULL,
	[Name] [nvarchar](50) NULL,
	[Description] [nvarchar](100) NULL,
	[IsEnabled] [bit] NULL,
 CONSTRAINT [PK_FlowType] PRIMARY KEY CLUSTERED
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[FXRate]    Script Date: 24.01.2025 18:29:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FXRate](
	[Id] [int] NOT NULL,
	[ChartId] [int] NOT NULL,
	[YieldDate] [datetime] NOT NULL,
	[Description] [nvarchar](250) NULL,
	[StateId] [int] NOT NULL,
	[StateMaker] [nvarchar](80) NULL,
	[StateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_FXRate] PRIMARY KEY CLUSTERED
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[FXRateDetail]    Script Date: 24.01.2025 18:29:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FXRateDetail](
	[Id] [int] NOT NULL,
	[FXRateId] [int] NOT NULL,
	[FromCurrency] [nvarchar](3) NOT NULL,
	[ToCurrency] [nvarchar](3) NOT NULL,
	[AskRate] [decimal](18, 8) NULL,
	[MidRate] [decimal](18, 8) NULL,
	[BidRate] [decimal](18, 8) NULL,
	[RateSourceId] [int] NULL,
 CONSTRAINT [PK_FXRateDetail] PRIMARY KEY CLUSTERED
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [UQ_FXRateDetail_FXRateId] UNIQUE NONCLUSTERED
(
	[FXRateId] ASC,
	[FromCurrency] ASC,
	[ToCurrency] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[HalfWorkingDay]    Script Date: 24.01.2025 18:29:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[HalfWorkingDay](
	[Id] [int] NOT NULL,
	[Name] [nvarchar](100) NOT NULL,
	[HalfWorkingDate] [datetime] NOT NULL,
	[Description] [nvarchar](250) NULL,
	[StateId] [int] NOT NULL,
	[StateMaker] [nvarchar](80) NULL,
	[StateDate] [datetime] NOT NULL,
 CONSTRAINT [PK_HalfWorkingDay] PRIMARY KEY CLUSTERED
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Holiday]    Script Date: 24.01.2025 18:29:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Holiday](
	[Id] [int] NOT NULL,
	[CurrencyCode] [nvarchar](3) NOT NULL,
	[DayOfYear] [int] NOT NULL,
	[Date] [datetime] NOT NULL,
	[Description] [nvarchar](300) NULL,
	[CalNo] [int] NULL,
 CONSTRAINT [PK_Holiday] PRIMARY KEY CLUSTERED
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[InterestMethod]    Script Date: 24.01.2025 18:29:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[InterestMethod](
	[Id] [int] NOT NULL,
	[Code] [nvarchar](50) NULL,
	[Name] [nvarchar](50) NULL,
	[Description] [nvarchar](100) NULL,
	[IsEnabled] [bit] NULL,
 CONSTRAINT [PK_InterestMethod] PRIMARY KEY CLUSTERED
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[InterestMethodFrequency]    Script Date: 24.01.2025 18:29:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[InterestMethodFrequency](
	[Id] [int] NOT NULL,
	[Code] [nvarchar](50) NULL,
	[Name] [nvarchar](50) NULL,
	[Description] [nvarchar](100) NULL,
	[IsEnabled] [bit] NULL,
 CONSTRAINT [PK_InterestMethodFrequency] PRIMARY KEY CLUSTERED
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[InterestRate]    Script Date: 24.01.2025 18:29:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[InterestRate](
	[Id] [int] NOT NULL,
	[ChartId] [int] NOT NULL,
	[YieldDate] [datetime] NOT NULL,
	[Description] [nvarchar](250) NULL,
	[StateId] [int] NOT NULL,
	[StateMaker] [nvarchar](80) NULL,
	[StateDate] [datetime] NULL,
 CONSTRAINT [PK_InterestRate] PRIMARY KEY CLUSTERED
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[InterestRateDetail]    Script Date: 24.01.2025 18:29:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[InterestRateDetail](
	[Id] [int] NOT NULL,
	[InterestRateId] [int] NOT NULL,
	[PointId] [int] NOT NULL,
	[PointDate] [datetime] NOT NULL,
	[AskRate] [decimal](18, 8) NULL,
	[BidRate] [decimal](18, 8) NULL,
	[MidRate] [decimal](18, 8) NULL,
	[Source] [nvarchar](10) NULL,
	[Ccy] [nvarchar](3) NULL,
	[SymbolName] [nvarchar](1000) NULL,
	[LastUpdate] [datetime] NOT NULL,
 CONSTRAINT [PK_InterestRateDetail] PRIMARY KEY CLUSTERED
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[LiquidationType]    Script Date: 24.01.2025 18:29:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[LiquidationType](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Code] [nvarchar](50) NULL,
	[Name] [nvarchar](50) NULL,
	[Description] [nvarchar](100) NULL,
	[IsEnabled] [bit] NULL,
 CONSTRAINT [PK_LiquidationType] PRIMARY KEY CLUSTERED
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PaymentFrequency]    Script Date: 24.01.2025 18:29:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PaymentFrequency](
	[Id] [int] NOT NULL,
	[Code] [nvarchar](50) NULL,
	[Name] [nvarchar](50) NULL,
	[Description] [nvarchar](100) NULL,
	[IsEnabled] [bit] NULL,
 CONSTRAINT [PK_PaymentFrequency] PRIMARY KEY CLUSTERED
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Point]    Script Date: 24.01.2025 18:29:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Point](
	[Id] [int] NOT NULL,
	[Name] [nvarchar](20) NULL,
	[Days] [int] NULL,
	[IsSystem] [bit] NULL,
	[SetNo] [int] NULL,
	[DayType] [int] NULL,
	[ListOrder] [int] NULL,
	[StateId] [int] NULL,
	[StateMaker] [nvarchar](80) NULL,
	[StateDate] [datetime] NULL,
	[PointCode] [nvarchar](10) NULL,
 CONSTRAINT [PK_Point] PRIMARY KEY CLUSTERED
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PrdInstrument]    Script Date: 24.01.2025 18:29:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PrdInstrument](
	[Id] [int] NOT NULL,
	[Code] [nvarchar](80) NOT NULL,
	[Name] [nvarchar](80) NULL,
	[ProductSubType] [nvarchar](10) NOT NULL,
	[AmortizationMethod] [nvarchar](4) NULL,
	[AccrualMethod] [nvarchar](4) NULL,
	[PerUnit] [decimal](38, 10) NULL,
	[IsSystem] [smallint] NULL,
	[FaceCurrency] [nvarchar](3) NULL,
	[AccountingCurrency] [nvarchar](3) NULL,
	[RevalPoint] [int] NULL,
	[RepricePoint] [int] NULL,
	[IndexCurrency] [nvarchar](3) NULL,
	[BasisCode] [nvarchar](4) NULL,
	[CacheDays] [int] NULL,
	[Accountable] [bit] NULL,
	[IsEuroBond] [bit] NULL,
	[IsUsTBill] [bit] NULL,
	[IsEuroTBill] [bit] NULL,
	[StateId] [int] NOT NULL,
	[StateMaker] [nvarchar](80) NULL,
	[StateDate] [datetime] NOT NULL,
	[Prd] [nvarchar](3) NULL,
 CONSTRAINT [PK_PrdInstrument] PRIMARY KEY CLUSTERED
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PrfInstrument]    Script Date: 24.01.2025 18:29:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PrfInstrument](
	[PortfolioId] [int] NOT NULL,
	[InstrumentId] [int] NOT NULL,
 CONSTRAINT [PK_PrfInstrument] PRIMARY KEY CLUSTERED
(
	[PortfolioId] ASC,
	[InstrumentId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PrfPortfolio]    Script Date: 24.01.2025 18:29:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PrfPortfolio](
	[Id] [int] NOT NULL,
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
	[StateId] [int] NOT NULL,
	[StateMaker] [nvarchar](80) NULL,
	[StateDate] [datetime] NOT NULL,
	[AccountingEnable] [bit] NULL,
	[HandOffEnable] [bit] NULL,
	[FCCLPortfolio] [bit] NULL,
	[IsCustomer] [bit] NULL,
 CONSTRAINT [PK_PrfPortfolio] PRIMARY KEY CLUSTERED
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ProductDefinition]    Script Date: 24.01.2025 18:29:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ProductDefinition](
	[Id] [int] NOT NULL,
	[Code] [nvarchar](10) NULL,
	[Name] [nvarchar](50) NOT NULL,
	[ExternalMainProductCode] [nvarchar](50) NOT NULL,
	[ExternalSubProductCode] [nvarchar](50) NOT NULL,
	[AccountingMapCode] [nvarchar](50) NOT NULL,
	[Description] [nvarchar](255) NULL,
	[IsAccountNeeded] [bit] NOT NULL,
	[IsSameCurrency] [bit] NOT NULL,
	[DoPrincipalAmountTransfer] [bit] NOT NULL,
	[HasPeriodPrincipalAmountTransferType] [bit] NOT NULL,
	[IsAllowRollover] [bit] NOT NULL,
	[IsAllowLiquidation] [bit] NOT NULL,
	[PortfolioRootPath] [nvarchar](100) NULL,
	[PortfolioDefaultPath] [nvarchar](100) NULL,
	[IsEnabled] [bit] NOT NULL,
 CONSTRAINT [PK_ProductDefinition] PRIMARY KEY CLUSTERED
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[RateAdjustmentType]    Script Date: 24.01.2025 18:29:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RateAdjustmentType](
	[Id] [int] NOT NULL,
	[Code] [nvarchar](50) NULL,
	[Name] [nvarchar](50) NULL,
	[Description] [nvarchar](max) NULL,
	[IsEnabled] [bit] NULL,
 CONSTRAINT [PK_RateAdjustmentType] PRIMARY KEY CLUSTERED
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[RateType]    Script Date: 24.01.2025 18:29:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RateType](
	[Id] [int] NOT NULL,
	[Code] [nvarchar](50) NULL,
	[Name] [nvarchar](50) NULL,
	[Description] [nvarchar](100) NULL,
	[IsEnabled] [bit] NULL,
 CONSTRAINT [PK_RateType] PRIMARY KEY CLUSTERED
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[TaxRate]    Script Date: 24.01.2025 18:29:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TaxRate](
	[Id] [int] NOT NULL,
	[SlabId] [int] NOT NULL,
	[RuleId] [int] NOT NULL,
	[Rate] [decimal](38, 10) NULL,
	[ActiveFromDate] [datetime] NULL,
	[ActiveToDate] [datetime] NULL,
	[StateId] [int] NOT NULL,
	[StateDate] [datetime] NOT NULL,
	[StateMaker] [nvarchar](80) NULL,
 CONSTRAINT [PK_TaxRate] PRIMARY KEY CLUSTERED
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[TaxRule]    Script Date: 24.01.2025 18:29:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TaxRule](
	[Id] [int] NOT NULL,
	[Name] [nvarchar](80) NULL,
	[InstrumentId] [int] NULL,
	[ClientRole] [int] NULL,
	[NotClientRole] [int] NULL,
	[MarketCode] [nvarchar](6) NULL,
	[TaxId] [int] NULL,
	[ClassCode] [nvarchar](10) NULL,
	[CountryCode] [nvarchar](3) NULL,
	[BrokerId] [int] NULL,
	[Tenor] [int] NULL,
	[TxnTypeCode] [nvarchar](4) NULL,
	[Ccy1Flag] [int] NULL,
	[Ccy2Flag] [int] NULL,
	[NotCcy1Flag] [int] NULL,
	[NotCcy2Flag] [int] NULL,
	[TxnFlags] [int] NULL,
	[NotTxnFlags] [int] NULL,
	[StateId] [int] NULL,
	[StateMaker] [nvarchar](80) NULL,
	[StateDate] [datetime] NULL,
 CONSTRAINT [PK_TaxRule] PRIMARY KEY CLUSTERED
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[TaxTax]    Script Date: 24.01.2025 18:29:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TaxTax](
	[Id] [int] NOT NULL,
	[Code] [nvarchar](80) NULL,
	[Name] [nvarchar](200) NULL,
	[Type] [int] NOT NULL,
	[IsTier] [bit] NOT NULL,
	[StateId] [int] NULL,
	[StateMaker] [nvarchar](80) NULL,
	[StateDate] [datetime] NULL,
 CONSTRAINT [PK_TaxTax] PRIMARY KEY CLUSTERED
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[TaxType]    Script Date: 24.01.2025 18:29:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TaxType](
	[Code] [nvarchar](20) NOT NULL,
	[Description] [nvarchar](255) NULL,
	[StateId] [int] NULL,
	[StateMaker] [nvarchar](80) NULL,
	[StateDate] [datetime] NULL,
	[Id] [int] IDENTITY(1,1) NOT NULL,
 CONSTRAINT [PK_TaxType] PRIMARY KEY CLUSTERED
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[TxnCashFlow]    Script Date: 24.01.2025 18:29:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TxnCashFlow](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[TxnId] [int] NOT NULL,
	[PeriodNumber] [int] NULL,
	[PrincipalAmount] [decimal](38, 10) NOT NULL,
	[FlowTypeId] [int] NOT NULL,
	[FixingDate] [date] NULL,
	[StartDate] [date] NULL,
	[EndDate] [date] NULL,
	[PaymentDate] [date] NULL,
	[Days] [int] NOT NULL,
	[Rate] [decimal](18, 10) NOT NULL,
	[Spread] [int] NOT NULL,
	[CashFlowAmount] [decimal](38, 10) NOT NULL,
	[CashFlowLegType] [nvarchar](20) NOT NULL,
	[Currency] [nvarchar](3) NOT NULL,
	[RateTypeId] [int] NOT NULL,
	[FloatingRateTypeId] [int] NULL,
	[PaymentFrequencyId] [int] NOT NULL,
	[InterestMethodsId] [int] NOT NULL,
	[InterestMethodsFrequencyId] [int] NOT NULL,
	[DateBasisCode] [nvarchar](4) NOT NULL,
	[DaysInYear] [int] NOT NULL,
	[PaymentLagDays] [int] NOT NULL,
	[FixingLagDays] [int] NOT NULL,
	[IsCompound] [bit] NOT NULL,
	[OutgoingCorrespondentId] [int] NULL,
	[OutgoingCorrespondentAccountNumber] [bigint] NULL,
	[TheirBeneficiaryCorrespondentName] [nvarchar](500) NULL,
	[TheirBeneficiaryCorrespondentSwiftCode] [nvarchar](50) NULL,
	[TheirBeneficiaryCorrespondentAccountNumber] [nvarchar](500) NULL,
	[TheirSenderCorrespondentName] [nvarchar](500) NULL,
	[TheirSenderCorrespondentSwiftCode] [nvarchar](50) NULL,
	[TheirSenderCorrespondentAccountNumber] [nvarchar](500) NULL,
	[IncomingCorrespondentId] [int] NULL,
	[IncomingCorrespondentAccountNumber] [bigint] NULL,
	[Instructions] [nvarchar](1000) NULL,
	[StateId] [int] NOT NULL,
	[StateMaker] [nvarchar](80) NOT NULL,
	[StateDate] [datetime] NOT NULL,
    [LogicalReference] [nvarchar](80) NOT NULL,
 CONSTRAINT [PK_TxnCashFlow] PRIMARY KEY CLUSTERED
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[TxnCashFlowHistory]    Script Date: 24.01.2025 18:29:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TxnCashFlowHistory](
	[HistoryId] [int] IDENTITY(1,1) NOT NULL,
	[Id] [int] NOT NULL,
	[TxnId] [int] NOT NULL,
	[PeriodNumber] [int] NULL,
	[PrincipalAmount] [decimal](38, 10) NOT NULL,
	[FlowTypeId] [int] NOT NULL,
	[FixingDate] [date] NULL,
	[StartDate] [date] NULL,
	[EndDate] [date] NULL,
	[PaymentDate] [date] NULL,
	[Days] [int] NOT NULL,
	[Rate] [decimal](18, 10) NOT NULL,
	[Spread] [int] NOT NULL,
	[CashFlowAmount] [decimal](38, 10) NOT NULL,
	[CashFlowLegType] [nvarchar](20) NOT NULL,
	[Currency] [nvarchar](3) NOT NULL,
	[RateTypeId] [int] NOT NULL,
	[FloatingRateTypeId] [int] NULL,
	[PaymentFrequencyId] [int] NOT NULL,
	[InterestMethodsId] [int] NOT NULL,
	[InterestMethodsFrequencyId] [int] NOT NULL,
	[DateBasisCode] [nvarchar](20) NOT NULL,
	[DaysInYear] [int] NOT NULL,
	[PaymentLagDays] [int] NOT NULL,
	[FixingLagDays] [int] NOT NULL,
	[IsCompound] [bit] NOT NULL,
	[OutgoingCorrespondentId] [int] NULL,
	[OutgoingCorrespondentAccountNumber] [bigint] NULL,
	[TheirBeneficiaryCorrespondentName] [nvarchar](500) NULL,
	[TheirBeneficiaryCorrespondentSwiftCode] [nvarchar](50) NULL,
	[TheirBeneficiaryCorrespondentAccountNumber] [nvarchar](500) NULL,
	[TheirSenderCorrespondentName] [nvarchar](500) NULL,
	[TheirSenderCorrespondentSwiftCode] [nvarchar](50) NULL,
	[TheirSenderCorrespondentAccountNumber] [nvarchar](500) NULL,
	[IncomingCorrespondentId] [int] NULL,
	[IncomingCorrespondentAccountNumber] [bigint] NULL,
	[Instructions] [nvarchar](1000) NULL,
	[StateId] [int] NOT NULL,
	[StateMaker] [nvarchar](80) NOT NULL,
	[StateDate] [datetime] NOT NULL,
    [LogicalReference] [nvarchar](80) NOT NULL,
 CONSTRAINT [PK_TxnCashFlowHistory] PRIMARY KEY CLUSTERED
(
	[HistoryId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[TxnSync]    Script Date: 24.01.2025 18:29:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TxnSync](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[BusinessKey] [bigint] NOT NULL,
	[TransactionId] [int] NOT NULL,
	[PackageNumber] [int] NOT NULL,
	[LogicalReference] [nvarchar](100) NOT NULL,
	[CounterPartyReference] [bigint] NOT NULL,
	[Product] [nvarchar](3) NOT NULL,
	[ProductSubType] [nvarchar](10) NOT NULL,
	[TransactionType] [nvarchar](4) NOT NULL,
	[InputDate] [datetime] NOT NULL,
	[ValueDate] [date] NOT NULL,
	[TradeDate] [date] NOT NULL,
	[MaturityDate] [date] NOT NULL,
	[BaseCCYPair] [nvarchar](7) NOT NULL,
	[Leg1Amount] [decimal](38, 10) NOT NULL,
	[Leg1CCY] [nvarchar](3) NOT NULL,
	[Leg2Amount] [decimal](38, 10) NOT NULL,
	[Leg2CCY] [nvarchar](3) NOT NULL,
	[Rate] [decimal](26, 10) NOT NULL,
	[Market] [nvarchar](6) NOT NULL,
	[Instruction] [nvarchar](250) NULL,
	[InternalInstruction] [nvarchar](250) NULL,
	[Trader] [int] NOT NULL,
	[StateId] [int] NOT NULL,
	[StateMaker] [nvarchar](80) NOT NULL,
	[StateDate] [datetime] NOT NULL,
	[Leg1CorrespondentAccount] [bigint] NULL,
	[Leg2CorrespondentAccount] [bigint] NULL,
	[Leg1CounterpartCorrespondentName] [nvarchar](500) NULL,
	[Leg1CounterpartCorrespondentSwiftCode] [nvarchar](50) NULL,
	[Leg1CounterpartCorrespondentAccount] [nvarchar](500) NULL,
	[Leg2CounterpartCorrespondentName] [nvarchar](500) NULL,
	[Leg2CounterpartCorrespondentSwiftCode] [nvarchar](50) NULL,
	[Leg2CounterpartCorrespondentAccount] [nvarchar](500) NULL,
	[DayCount] [nvarchar](20) NOT NULL,
 CONSTRAINT [PK_TxnSync] PRIMARY KEY CLUSTERED
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[TxnSyncDetail]    Script Date: 24.01.2025 18:29:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TxnSyncDetail](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[TxnSyncId] [int] NULL,
	[BusinessKey] [bigint] NOT NULL,
	[TransactionId] [int] NOT NULL,
	[PackageNo] [int] NULL,
	[SwiftKey] [nvarchar](50) NULL,
	[SwiftMessageState] [nvarchar](50) NULL,
	[SwiftMessageDescription] [nvarchar](100) NULL,
	[EftKey] [nvarchar](50) NULL,
	[EftMessageState] [nvarchar](50) NULL,
	[EftMessageDescription] [nvarchar](100) NULL,
	[StateId] [int] NULL,
	[StateMaker] [nvarchar](80) NULL,
	[StateDate] [datetime] NULL,
 CONSTRAINT [PK_TxnSyncDetail] PRIMARY KEY CLUSTERED
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[TxnTax]    Script Date: 24.01.2025 18:29:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create table [dbo].[TxnTax]
(
    Id      int not null identity (1,1),
    TxnId   int not null,
    TaxId   int not null,
    TaxDate datetime,
    Amount  decimal(38, 10),
    TaxRate decimal(18, 10),
    Flags   int not null,
    Ccy     nvarchar(3),
    constraint PK_TxnTax primary key (Id)
)
GO
/****** Object:  Table [dbo].[TxnTransaction]    Script Date: 24.01.2025 18:29:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TxnTransaction](
	[Id] [int] NOT NULL,
	[LogicalReference] [nvarchar](80) NOT NULL,
	[TradeDate] [date] NOT NULL,
	[InputDateTime] [datetime] NOT NULL,
	[ReceiveValueDate] [date] NOT NULL,
	[PayValueDate] [date] NOT NULL,
	[ReceiveMaturityDate] [date] NOT NULL,
	[PayMaturityDate] [date] NOT NULL,
	[Trader] [nvarchar](80) NOT NULL,
	[CounterpartyId] [int] NOT NULL,
	[PortfolioId] [int] NOT NULL,
	[ProductTypeId] [int] NOT NULL,
	[PayOfUpdate] [date] NULL,
	[B2BRefTransaction] [nvarchar](1000) NULL,
	[ReceivePrincipalAmount] [decimal](38, 10) NOT NULL,
	[ReceiveCurrency] [nvarchar](3) NOT NULL,
	[ReceiveRateTypeId] [int] NOT NULL,
	[ReceiveRate] [decimal](18, 10) NULL,
	[ReceiveFloatingRateTypeId] [int] NULL,
	[ReceiveSpread] [int] NOT NULL,
	[ReceivePaymentFrequencyId] [int] NOT NULL,
	[ReceiveInterestMethodsId] [int] NOT NULL,
	[ReceiveInterestMethodsFrequencyId] [int] NOT NULL,
	[ReceiveDateBasisCode] [nvarchar](4) NOT NULL,
	[ReceiveIndexChartId] [int] NOT NULL,
	[ReceiveDaysInYear] [int] NOT NULL,
	[ReceivePaymentLagDays] [int] NOT NULL,
	[ReceiveFixingLagDays] [int] NOT NULL,
	[PayPrincipalAmount] [decimal](38, 10) NOT NULL,
	[PayCurrency] [nvarchar](3) NOT NULL,
	[PayRateTypeId] [int] NOT NULL,
	[PayRate] [decimal](18, 10) NULL,
	[PayFloatingRateTypeId] [int] NULL,
	[PaySpread] [int] NOT NULL,
	[PayPaymentFrequencyId] [int] NOT NULL,
	[PayInterestMethodsId] [int] NOT NULL,
	[PayInterestMethodsFrequencyId] [int] NOT NULL,
	[PayDateBasisCode] [nvarchar](4) NOT NULL,
	[PayIndexChartId] [int] NOT NULL,
	[PayPaymentLagDays] [int] NOT NULL,
	[PayDaysInYear] [int] NOT NULL,
	[PayFixingLagDays] [int] NOT NULL,
	[Instructions] [nvarchar](1000) NULL,
	[LiquidationDate] [date] NULL,
	[LiquidationTypeId] [int] NULL,
	[LiquidationPrice] [decimal](18, 10) NULL,
	[LiquidationReceiveAmount] [decimal](18, 10) NULL,
	[LiquidationPayAmount] [decimal](18, 10) NULL,
	[Fee] [decimal](18, 10) NULL,
	[StateId] [int] NOT NULL,
	[StateMaker] [nvarchar](80) NOT NULL,
	[StateDate] [datetime] NOT NULL,
	[IsFinancialInstitution] [bit] NOT NULL,
	[SwiftConfirmationMessageStatus] [nvarchar](50) NULL,
	[SwiftPaymentMessageStatus] [nvarchar](50) NULL,
	[DomesticPaymentMessageStatus] [nvarchar](50) NULL,
	[OutgoingCorrespondentId] [int] NOT NULL,
	[OutgoingCorrespondentAccountNumber] [bigint] NOT NULL,
	[TheirBeneficiaryCorrespondentName] [nvarchar](500) NOT NULL,
	[TheirBeneficiaryCorrespondentSwiftCode] [nvarchar](50) NOT NULL,
	[TheirBeneficiaryCorrespondentAccountNumber] [nvarchar](500) NOT NULL,
	[TheirSenderCorrespondentName] [nvarchar](500) NOT NULL,
	[TheirSenderCorrespondentSwiftCode] [nvarchar](50) NOT NULL,
	[TheirSenderCorrespondentAccountNumber] [nvarchar](500) NOT NULL,
	[IncomingCorrespondentId] [int] NOT NULL,
	[IncomingCorrespondentAccountNumber] [bigint] NOT NULL,
	[SendConformation] [bit] NOT NULL,
	[SendPayment] [bit] NOT NULL,
	[SendNoticeToReceive] [bit] NOT NULL,
	[BusinessKey] [bigint] NOT NULL,    
	[ReceivePaymentDate] [date] NOT NULL,
    [PayPaymentDate] [date] NOT NULL,
 CONSTRAINT [PK_TxnTransaction] PRIMARY KEY CLUSTERED
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[TxnTransactionHistory]    Script Date: 24.01.2025 18:29:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TxnTransactionHistory](
	[HistoryId] [int] IDENTITY(1,1) NOT NULL,
	[Id] [int] NOT NULL,
	[LogicalReference] [nvarchar](80) NOT NULL,
	[TradeDate] [date] NOT NULL,
	[InputDateTime] [datetime] NOT NULL,
	[ReceiveValueDate] [date] NOT NULL,
	[PayValueDate] [date] NOT NULL,
	[ReceiveMaturityDate] [date] NOT NULL,
	[PayMaturityDate] [date] NOT NULL,
	[Trader] [nvarchar](80) NOT NULL,
	[CounterpartyId] [int] NOT NULL,
	[PortfolioId] [int] NOT NULL,
	[ProductTypeId] [int] NOT NULL,
	[PayOfUpdate] [date] NULL,
	[B2BRefTransaction] [nvarchar](1000) NULL,
	[ReceivePrincipalAmount] [decimal](38, 10) NOT NULL,
	[ReceiveCurrency] [nvarchar](3) NOT NULL,
	[ReceiveRateTypeId] [int] NOT NULL,
	[ReceiveRate] [decimal](18, 10) NULL,
	[ReceiveFloatingRateTypeId] [int] NULL,
	[ReceiveSpread] [int] NOT NULL,
	[ReceivePaymentFrequencyId] [int] NOT NULL,
	[ReceiveInterestMethodsId] [int] NOT NULL,
	[ReceiveInterestMethodsFrequencyId] [int] NOT NULL,
	[ReceiveDateBasisCode] [nvarchar](4) NOT NULL,
	[ReceiveIndexChartId] [int] NOT NULL,
	[ReceiveDaysInYear] [int] NOT NULL,
	[ReceivePaymentLagDays] [int] NOT NULL,
	[ReceiveFixingLagDays] [int] NOT NULL,
	[PayPrincipalAmount] [decimal](38, 10) NOT NULL,
	[PayCurrency] [nvarchar](3) NOT NULL,
	[PayRateTypeId] [int] NOT NULL,
	[PayRate] [decimal](18, 10) NULL,
	[PayFloatingRateTypeId] [int] NULL,
	[PaySpread] [int] NOT NULL,
	[PayPaymentFrequencyId] [int] NOT NULL,
	[PayInterestMethodsId] [int] NOT NULL,
	[PayInterestMethodsFrequencyId] [int] NOT NULL,
	[PayDateBasisCode] [nvarchar](4) NOT NULL,
	[PayIndexChartId] [int] NOT NULL,
	[PayPaymentLagDays] [int] NOT NULL,
	[PayDaysInYear] [int] NOT NULL,
	[PayFixingLagDays] [int] NOT NULL,
	[Instructions] [nvarchar](1000) NULL,
	[LiquidationDate] [date] NULL,
	[LiquidationTypeId] [int] NULL,
	[LiquidationPrice] [decimal](18, 10) NULL,
	[LiquidationReceiveAmount] [decimal](18, 10) NULL,
	[LiquidationPayAmount] [decimal](18, 10) NULL,
	[Fee] [decimal](18, 10) NULL,
	[StateId] [int] NOT NULL,
	[StateMaker] [nvarchar](80) NOT NULL,
	[StateDate] [datetime] NOT NULL,
	[IsFinancialInstitution] [bit] NOT NULL,
	[SwiftConfirmationMessageStatus] [nvarchar](50) NULL,
	[SwiftPaymentMessageStatus] [nvarchar](50) NULL,
	[DomesticPaymentMessageStatus] [nvarchar](50) NULL,
	[OutgoingCorrespondentId] [int] NOT NULL,
	[OutgoingCorrespondentAccountNumber] [bigint] NOT NULL,
	[TheirBeneficiaryCorrespondentName] [nvarchar](500) NOT NULL,
	[TheirBeneficiaryCorrespondentSwiftCode] [nvarchar](50) NOT NULL,
	[TheirBeneficiaryCorrespondentAccountNumber] [nvarchar](500) NOT NULL,
	[TheirSenderCorrespondentName] [nvarchar](500) NOT NULL,
	[TheirSenderCorrespondentSwiftCode] [nvarchar](50) NOT NULL,
	[TheirSenderCorrespondentAccountNumber] [nvarchar](500) NOT NULL,
	[IncomingCorrespondentId] [int] NOT NULL,
	[IncomingCorrespondentAccountNumber] [bigint] NOT NULL,
	[SendConformation] [bit] NOT NULL,
	[SendPayment] [bit] NOT NULL,
	[SendNoticeToReceive] [bit] NOT NULL,
	[BusinessKey] [bigint] NOT NULL,    
	[ReceivePaymentDate] [date] NOT NULL,
    [PayPaymentDate] [date] NOT NULL,
 CONSTRAINT [PK_TxnTransactionHistory] PRIMARY KEY CLUSTERED
(
	[HistoryId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[AccEngineGeneratedAccountRule] ADD  CONSTRAINT [DF_AccEngineGeneratedAccountRule_ReverseRebook]  DEFAULT ((0)) FOR [ReverseRebook]
GO
ALTER TABLE [dbo].[AccEntryMain] ADD  CONSTRAINT [DF_AccEntryMain_IsReverse]  DEFAULT ((0)) FOR [IsReverse]
GO
ALTER TABLE [dbo].[AccEntryMain] ADD  CONSTRAINT [DF_AccEntryMain_ReverseId]  DEFAULT ((0)) FOR [ReverseId]
GO
ALTER TABLE [dbo].[BatchItem] ADD  CONSTRAINT [DF_BatchItem_ItemOrder]  DEFAULT ((0)) FOR [ItemOrder]
GO
ALTER TABLE [dbo].[BatchItem] ADD  CONSTRAINT [DF_BatchItem_IsTransactional]  DEFAULT ((0)) FOR [IsTransactional]
GO
ALTER TABLE [dbo].[BatchItem] ADD  CONSTRAINT [DF_BatchItem_StateId]  DEFAULT ((18)) FOR [StateId]
GO
ALTER TABLE [dbo].[BatchItem] ADD  CONSTRAINT [DF_BatchItem_StateDate]  DEFAULT (getdate()) FOR [StateDate]
GO
ALTER TABLE [dbo].[BatchLog] ADD  CONSTRAINT [DF_BatchLog_Status]  DEFAULT ((0)) FOR [Status]
GO
ALTER TABLE [dbo].[BatchLogDetail] ADD  CONSTRAINT [DF_BatchLogDetail_Status]  DEFAULT ((0)) FOR [Status]
GO
ALTER TABLE [dbo].[BatchLogDetail] ADD  CONSTRAINT [DF_BatchLogDetail_LogType]  DEFAULT ((0)) FOR [LogType]
GO
ALTER TABLE [dbo].[Currency] ADD  CONSTRAINT [DF_Currency_Pip]  DEFAULT ((0)) FOR [Pip]
GO
ALTER TABLE [dbo].[DefCountry] ADD  CONSTRAINT [DF_DefCountry_Enabled]  DEFAULT ((1)) FOR [Enabled]
GO
ALTER TABLE [dbo].[InterestRateDetail] ADD  CONSTRAINT [DF__InterestR__LastU__44801EAD]  DEFAULT (getdate()) FOR [LastUpdate]
GO
ALTER TABLE [dbo].[PrfPortfolio] ADD  CONSTRAINT [DF_PrfPortfolio_IsCustomer]  DEFAULT ((0)) FOR [IsCustomer]
GO
ALTER TABLE [dbo].[TaxTax] ADD  CONSTRAINT [DF_TaxTax_IsTier]  DEFAULT ((0)) FOR [IsTier]
GO
ALTER TABLE [dbo].[TxnTransaction] ADD  CONSTRAINT [DF_TxnTransaction_LiquidationTypeId]  DEFAULT ((0)) FOR [LiquidationTypeId]
GO
ALTER TABLE [dbo].[TxnTransaction] ADD  CONSTRAINT [DF_TxnTransaction_LiquidationPrice]  DEFAULT ((0)) FOR [LiquidationPrice]
GO
ALTER TABLE [dbo].[TxnTransaction] ADD  CONSTRAINT [DF_TxnTransaction_LiquidationReceiveAmount]  DEFAULT ((0)) FOR [LiquidationReceiveAmount]
GO
ALTER TABLE [dbo].[TxnTransaction] ADD  CONSTRAINT [DF_TxnTransaction_LiquidationPayAmount]  DEFAULT ((0)) FOR [LiquidationPayAmount]
GO
ALTER TABLE [dbo].[TxnTransaction] ADD  CONSTRAINT [DF__TxnTransa__SendC__3D9E16F4]  DEFAULT ((0)) FOR [SendConformation]
GO
ALTER TABLE [dbo].[TxnTransaction] ADD  CONSTRAINT [DF__TxnTransa__SendP__3E923B2D]  DEFAULT ((0)) FOR [SendPayment]
GO
ALTER TABLE [dbo].[TxnTransaction] ADD  CONSTRAINT [DF__TxnTransa__SendN__3F865F66]  DEFAULT ((0)) FOR [SendNoticeToReceive]
GO
ALTER TABLE [dbo].[TxnTransactionHistory] ADD  CONSTRAINT [DF__TxnTransa__Liqui__4A03EDD9]  DEFAULT ((0)) FOR [LiquidationTypeId]
GO
ALTER TABLE [dbo].[TxnTransactionHistory] ADD  CONSTRAINT [DF__TxnTransa__Liqui__4AF81212]  DEFAULT ((0)) FOR [LiquidationPrice]
GO
ALTER TABLE [dbo].[TxnTransactionHistory] ADD  CONSTRAINT [DF__TxnTransa__Liqui__4BEC364B]  DEFAULT ((0)) FOR [LiquidationReceiveAmount]
GO
ALTER TABLE [dbo].[TxnTransactionHistory] ADD  CONSTRAINT [DF__TxnTransa__Liqui__4CE05A84]  DEFAULT ((0)) FOR [LiquidationPayAmount]
GO
ALTER TABLE [dbo].[TxnTransactionHistory] ADD  CONSTRAINT [DF__TxnTransa__SendC__4DD47EBD]  DEFAULT ((0)) FOR [SendConformation]
GO
ALTER TABLE [dbo].[TxnTransactionHistory] ADD  CONSTRAINT [DF__TxnTransa__SendP__4EC8A2F6]  DEFAULT ((0)) FOR [SendPayment]
GO
ALTER TABLE [dbo].[TxnTransactionHistory] ADD  CONSTRAINT [DF__TxnTransa__SendN__4FBCC72F]  DEFAULT ((0)) FOR [SendNoticeToReceive]
GO
ALTER TABLE [dbo].[BatchLog]  WITH CHECK ADD  CONSTRAINT [FK_BatchLog_BatchSet_BatchSetId] FOREIGN KEY([BatchSetId])
REFERENCES [dbo].[BatchSet] ([Id])
GO
ALTER TABLE [dbo].[BatchLog] CHECK CONSTRAINT [FK_BatchLog_BatchSet_BatchSetId]
GO
ALTER TABLE [dbo].[BatchLogDetail]  WITH CHECK ADD  CONSTRAINT [FK_BatchDetailLog_BatchLog] FOREIGN KEY([BatchLogId])
REFERENCES [dbo].[BatchLog] ([Id])
GO
ALTER TABLE [dbo].[BatchLogDetail] CHECK CONSTRAINT [FK_BatchDetailLog_BatchLog]
GO
ALTER TABLE [dbo].[BatchLogDetail]  WITH CHECK ADD  CONSTRAINT [FK_BatchLogDetail_BatchLog_BatchLogId] FOREIGN KEY([BatchLogId])
REFERENCES [dbo].[BatchLog] ([Id])
GO
ALTER TABLE [dbo].[BatchLogDetail] CHECK CONSTRAINT [FK_BatchLogDetail_BatchLog_BatchLogId]
GO

/****** Object:  StoredProcedure [dbo].[sp_InsertTxnSyncDetail]    Script Date: 24.01.2025 18:29:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_InsertTxnSyncDetail]
    @TxnSyncId int,
    @BusinessKey nvarchar(50),
    @TransactionId int,
    @PackageNo int,
    @SwiftKey nvarchar(50),
    @SwiftMessageState nvarchar(50),
    @SwiftMessageDescription nvarchar(200),
    @EftKey nvarchar(50),
    @EftMessageState nvarchar(50),
    @EftMessageDescription nvarchar(200),
    @StateMaker nvarchar(80),
    @StateDate datetime
AS
BEGIN
    INSERT INTO TxnSyncDetail (
        TxnSyncId, BusinessKey, TransactionId, PackageNo, SwiftKey,
        SwiftMessageState, SwiftMessageDescription, EftKey, EftMessageState,
        EftMessageDescription, StateId, StateMaker, StateDate
    )
    VALUES (
        @TxnSyncId, @BusinessKey, @TransactionId, @PackageNo, @SwiftKey,
        @SwiftMessageState, @SwiftMessageDescription, @EftKey, @EftMessageState,
        @EftMessageDescription, 18, @StateMaker, @StateDate
    );
END;
GO
/****** Object:  Trigger [dbo].[TxnCashFlowTrigger]    Script Date: 24.01.2025 18:29:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [dbo].[TxnCashFlowTrigger] ON [dbo].[TxnCashFlow]
FOR INSERT, UPDATE
AS
INSERT INTO [dbo].[TxnCashFlowHistory] SELECT * FROM inserted
GO
ALTER TABLE [dbo].[TxnCashFlow] ENABLE TRIGGER [TxnCashFlowTrigger]
GO
/****** Object:  Trigger [dbo].[TxnTransactionTrigger]    Script Date: 24.01.2025 18:29:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [dbo].[TxnTransactionTrigger] ON [dbo].[TxnTransaction]
		FOR INSERT, UPDATE
		AS
		INSERT INTO [dbo].[TxnTransactionHistory] SELECT * FROM inserted
GO
ALTER TABLE [dbo].[TxnTransaction] ENABLE TRIGGER [TxnTransactionTrigger]
GO
EXEC sys.sp_addextendedproperty @name=N'Description_TR', @value=N'Gün içinde yapilan islerin baslama ve bitis süreleri tutan log tablosu.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BatchLog'
GO
EXEC sys.sp_addextendedproperty @name=N'Description_TR', @value=N'Gün içinde yapilan islerin durumunu BatchLog tablosuna göre daha detayli gösteren log tablosu.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BatchLogDetail'
GO
EXEC sys.sp_addextendedproperty @name=N'Description_TR', @value=N'Gün içinde çalistirilan gerekli islerin grup tip tanim tablosu.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BatchSet'
GO
EXEC sys.sp_addextendedproperty @name=N'Description_EN', @value=N'currency code' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Currency', @level2type=N'COLUMN',@level2name=N'Code'
GO
EXEC sys.sp_addextendedproperty @name=N'Description_TR', @value=N'para birimi' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Currency', @level2type=N'COLUMN',@level2name=N'Code'
GO
EXEC sys.sp_addextendedproperty @name=N'Description_EN', @value=N'currency s name' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Currency', @level2type=N'COLUMN',@level2name=N'Name'
GO
EXEC sys.sp_addextendedproperty @name=N'Description_TR', @value=N'para birimi adı' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Currency', @level2type=N'COLUMN',@level2name=N'Name'
GO
EXEC sys.sp_addextendedproperty @name=N'Description_EN', @value=N'is hard currency?' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Currency', @level2type=N'COLUMN',@level2name=N'IsHard'
GO
EXEC sys.sp_addextendedproperty @name=N'Description_TR', @value=N'baskın olan döviz birimi mi?' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Currency', @level2type=N'COLUMN',@level2name=N'IsHard'
GO
EXEC sys.sp_addextendedproperty @name=N'Description_EN', @value=N'is syntetic?' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Currency', @level2type=N'COLUMN',@level2name=N'IsSynthetic'
GO
EXEC sys.sp_addextendedproperty @name=N'Description_TR', @value=N'sonradan yapılma mı?' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Currency', @level2type=N'COLUMN',@level2name=N'IsSynthetic'
GO
EXEC sys.sp_addextendedproperty @name=N'Description_EN', @value=N'can use on txn?' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Currency', @level2type=N'COLUMN',@level2name=N'CanUseOnTxn'
GO
EXEC sys.sp_addextendedproperty @name=N'Description_TR', @value=N'işlem üzerinde kullanılabilir mi?' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Currency', @level2type=N'COLUMN',@level2name=N'CanUseOnTxn'
GO
EXEC sys.sp_addextendedproperty @name=N'Description_EN', @value=N'is foreign currency?' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Currency', @level2type=N'COLUMN',@level2name=N'ForeignCcy'
GO
EXEC sys.sp_addextendedproperty @name=N'Description_TR', @value=N'döviz birimi mi?' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Currency', @level2type=N'COLUMN',@level2name=N'ForeignCcy'
GO
EXEC sys.sp_addextendedproperty @name=N'Description_EN', @value=N'is disabled?' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Currency', @level2type=N'COLUMN',@level2name=N'Disabled'
GO
EXEC sys.sp_addextendedproperty @name=N'Description_TR', @value=N'hala kullanımda mı?' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Currency', @level2type=N'COLUMN',@level2name=N'Disabled'
GO
EXEC sys.sp_addextendedproperty @name=N'Description_EN', @value=N'Point In Percentage' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Currency', @level2type=N'COLUMN',@level2name=N'Pip'
GO
EXEC sys.sp_addextendedproperty @name=N'Description_TR', @value=N'parite hareket aralığı' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Currency', @level2type=N'COLUMN',@level2name=N'Pip'
GO
EXEC sys.sp_addextendedproperty @name=N'Description_EN', @value=N'financial year-to-date basis code' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Currency', @level2type=N'COLUMN',@level2name=N'BasisCode'
GO
EXEC sys.sp_addextendedproperty @name=N'Description_TR', @value=N'mali yıl esası kodu' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Currency', @level2type=N'COLUMN',@level2name=N'BasisCode'
GO
EXEC sys.sp_addextendedproperty @name=N'Description_EN', @value=N'record state status info for the application see: (input, input verified, edit, edit rejected etc.)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Currency', @level2type=N'COLUMN',@level2name=N'StateId'
GO
EXEC sys.sp_addextendedproperty @name=N'Description_TR', @value=N'uygulama için kayıt durum bilgisi. Bkz:( yeni kayıt, onaylanmış yeni kayıt, güncellenmiş, reddedilmiş güncelleme vb.)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Currency', @level2type=N'COLUMN',@level2name=N'StateId'
GO
EXEC sys.sp_addextendedproperty @name=N'Description_EN', @value=N'the user info who last changed the record status  see : usrUser' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Currency', @level2type=N'COLUMN',@level2name=N'StateMaker'
GO
EXEC sys.sp_addextendedproperty @name=N'Description_TR', @value=N'kayıt uzerinde en son işlem yapmış kullanıcı bilgisi. bkz : usrUser' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Currency', @level2type=N'COLUMN',@level2name=N'StateMaker'
GO
EXEC sys.sp_addextendedproperty @name=N'Description_EN', @value=N'the last changed time of the status' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Currency', @level2type=N'COLUMN',@level2name=N'StateDate'
GO
EXEC sys.sp_addextendedproperty @name=N'Description_TR', @value=N'kaydın statüsünün en son değiştirilme zamanı' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Currency', @level2type=N'COLUMN',@level2name=N'StateDate'
GO
EXEC sys.sp_addextendedproperty @name=N'Description_EN', @value=N'decimal precision' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Currency', @level2type=N'COLUMN',@level2name=N'Decimals'
GO
EXEC sys.sp_addextendedproperty @name=N'Description_TR', @value=N'ondalik duyarlılık' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Currency', @level2type=N'COLUMN',@level2name=N'Decimals'
GO
EXEC sys.sp_addextendedproperty @name=N'Description_EN', @value=N'Currency definition table.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Currency'
GO
EXEC sys.sp_addextendedproperty @name=N'Description_TR', @value=N'Para birimi tanim tablosu.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Currency'