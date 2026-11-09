# 02 — Çıktılar (colmanagement-entity-revizyon)

## #1 — `NetTrexOptFX.dbo.TxnTransaction` (TOP 20, ORDER BY Id DESC)

Kırpıldı — 90+ kolonlu wide table, satır verisi gerekli değildi (sadece şema/kolon yapısı inceleniyordu).
**Kolon listesi** (ilk 20, tam liste `TxnTransactionBaseEntity.cs`'le birebir eşleşti):
`Id, LogicalReference, BusinessKey, InputDateTime, Trader, CustomerId, PortfolioId, ProductDefinitionId,
SideType, OptionType, TradeDate, ValueDate, MaturityDate, SettlementDate, ExerciseType,
SettlementModeType, SpotRate, StrikeRate, UseCutOff, CutOffTime, ...` + `Premium*`/`Exercise*`
correspondent-banka alanları (`PremiumOutgoingCorrespondentId`, `PremiumIncomingCorrespondentId`,
`PremiumTheirBeneficiaryCorrespondentId`, `PremiumTheirSenderCorrespondentId` vb.) **doğrudan ana tabloda**
— ayrı bir payment-instruction tablosu **yok**.

**Sonuç:** OptionsFX ödeme/correspondent alanlarını yanal (embed) tutuyor, ayrı tabloya bölmüyor.

## #2 — `NetTrexMM.dbo.TxnMM` (TOP 20, ORDER BY Id DESC)

Kırpıldı — 82 kolon. Tam liste:
`Id, CustomerId, TxnMmProductTypeId, FundSourceId, SubFundSourceCode, PortfolioId, BasisCode, DaysInYear,
TermId, TxnTypeCode, CollateralType, BusinessKey, LogicalReference, MarketCode, Ccy, InputDate, TradeDate,
ValueDate, MaturityDate, DealAmount, MaturityAmount, PaymentType, CustomerLocation, Instructions,
IsMatured, AccountNumber, GLCode, StateId, StateMaker, StateDate, SwiftConfirmationMessageStatus,
SwiftPaymentMessageStatus, DomesticPaymentMessageStatus, OutgoingCorrespondentId,
OutgoingCorrespondentAccountNumber, OutgoingCorrespondentAccountGLCode,
TheirBeneficiaryCorrespondentName, TheirBeneficiaryCorrespondentSwiftCode,
TheirBeneficiaryCorrespondentAccountNumber, TheirSenderCorrespondentName,
TheirSenderCorrespondentSwiftCode, TheirSenderCorrespondentAccountNumber, IncomingCorrespondentId,
IncomingCorrespondentAccountNumber, IncomingCorrespondentAccountGLCode, PaymentInstructionTypeId,
SecurityId, ExternalReference, ExternalReferenceSourceId, SendConfirmation, SendPayment,
SendNoticeToReceive, OutgoingPaymentAccountingType, SettlementTypeId, OutgoingPaymentAccountingGLType,
OutgoingPaymentAccountingGL, IncomingPaymentAccountingType, IncomingPaymentAccountingGLType,
IncomingPaymentAccountingGL, TheirBeneficiaryCorrespondentId, TheirBeneficiaryCorrespondentGLCode,
TheirSenderCorrespondentId, TheirSenderCorrespondentGLCode, CreatedBy, CreatedDate, PreviousStateId,
PreviousStateMaker, PreviousStateDate, FlowId, RolloverTypeId, Trader, CorporateCurrentAccountNumber,
CorporateCurrentAccountGLCode, CustomerIsFinancialInstitution, CorporateCurrentAccountWorkGroupId,
LastActionId, PreviousActionId, TransactionOriginType, LinkedTransactionId, LinkedTransactionReference,
LinkedTransactionTrader, LinkedTransactionReasonType`

**Sonuç:** MM de aynı — tek wide tablo, We Send/We Receive/They Send/They Receive + Settlement/
PaymentInstructionType kolonları **ana tabloda**, ayrı tablo yok.

## Karar

İki platformun da canlı şeması **tutarlı**: payment/correspondent alanları ana transaction tablosuna
**yanal genişletilerek** eklenir, ayrı tabloya bölünmez. ColManagement'teki ayrı `TxnPaymentInstruction`
tablosu Excel'in icadıydı — kaldırıldı, alanları `TxnTransactionDetail`'e taşınacak (bkz. sohbet notu).
