# 01-sorgular — mm-il-ekran-dokumani
Sohbet: MM + InterbankLoan ekran dokumani (is birimi). Kullanici DB SELECT iznini verdi (2026-10-25). Sunucu 192.168.10.211 / NetTrexMM, parola maskeli (-P '***').

## #1 — Lookup tablo adlarini kesfet
Amac: RateType/FloatingRateType/PaymentFrequency/InterestMethod/AmortizationType/FlowType/SettlementType vb. tablolarin fiziksel adlarini bulmak.
```sql
SET NOCOUNT ON;
SELECT TOP (50) name FROM sys.tables
WHERE name LIKE '%Rate%' OR name LIKE '%Frequen%' OR name LIKE '%Method%' OR name LIKE '%Amort%' OR name LIKE '%FlowType%' OR name LIKE '%Settlement%' OR name LIKE '%PaymentInstr%' OR name LIKE '%Chart%' OR name LIKE '%Basis%' OR name LIKE '%Calendar%' OR name LIKE '%Holiday%'
ORDER BY name;
```

## #2 — Kucuk lookup tablolarin icerigi (seed dogrulama)
Amac: RateType, FloatingRateType, PaymentFrequency, InterestMethod, InterestMethodFrequency, AmortizationType, FlowType, SettlementType, PaymentInstructionType, DefDateBasis satirlari ve Id degerleri (is birimi dokumanindaki liste degerleri). Tablolar kucuk; hepsi TOP (20) ile, SELECT * (tum kolon gerekli).
```sql
SET NOCOUNT ON;
SELECT TOP (20) * FROM dbo.RateType ORDER BY Id DESC;
SELECT TOP (20) * FROM dbo.PaymentFrequency ORDER BY Id DESC;
SELECT TOP (20) * FROM dbo.InterestMethod ORDER BY Id DESC;
SELECT TOP (20) * FROM dbo.InterestMethodFrequency ORDER BY Id DESC;
SELECT TOP (20) * FROM dbo.AmortizationType ORDER BY Id DESC;
SELECT TOP (20) * FROM dbo.FlowType ORDER BY Id DESC;
SELECT TOP (20) * FROM dbo.SettlementType ORDER BY Id DESC;
SELECT TOP (20) * FROM dbo.PaymentInstructionType ORDER BY Id DESC;
SELECT TOP (20) * FROM dbo.DefDateBasis ORDER BY Id DESC;
```

## #3 — #2'nin duzeltilmisi (DefDateBasis'te Id kolonu yok; ORDER BY 1)
Amac: #2 ile ayni. #2 "Invalid column name 'Id'" ile derleme hatasi verdi, hicbir sorgu kosmadi.
```sql
(#2 ile ayni 8 sorgu) + SELECT TOP (20) * FROM dbo.DefDateBasis ORDER BY 1 DESC;
```

## #4 — FloatingRateType icerigi
Amac: Floating oran tipleri (Currency/PointId/ChartId) — IL'de floating oranin hangi egriden geldigini gostermek.
```sql
SET NOCOUNT ON; SELECT TOP (20) * FROM dbo.FloatingRateType ORDER BY Id DESC;
```
## #5 — Chart listesi
Amac: Index Chart dropdown'unun gercek icerigi (kac chart, Id/Code/Name).
```sql
SET NOCOUNT ON; SELECT TOP (50) * FROM dbo.Chart ORDER BY Id DESC;
```
## #6 — TxnLoan.IndexChartId ve RateTypeId dagilimi
Amac: IL islemlerinde hangi Index Chart / Rate Type gercekten kullaniliyor.
```sql
SET NOCOUNT ON; SELECT TOP (20) IndexChartId, RateTypeId, COUNT(*) AS Adet FROM dbo.TxnLoan GROUP BY IndexChartId, RateTypeId ORDER BY Adet DESC;
```
## #7 — Amortisman kullanimi
Amac: AmortizationConfiguration gercekten kullaniliyor mu; mode dagilimi.
```sql
SET NOCOUNT ON; SELECT TOP (20) AmortizationMode, AmortizationTypeId, AmortizationFrequencyId, COUNT(*) AS Adet FROM dbo.AmortizationConfiguration GROUP BY AmortizationMode, AmortizationTypeId, AmortizationFrequencyId ORDER BY Adet DESC;
```
## #8 — History trigger'lari
Amac: TxnLoan/TxnMM History tablolarini dolduran DB trigger var mi (uygulama kodu doldurmuyor).
```sql
SET NOCOUNT ON; SELECT TOP (20) t.name, OBJECT_NAME(t.parent_id) AS TabloAdi, t.is_disabled FROM sys.triggers t WHERE OBJECT_NAME(t.parent_id) IN ('TxnLoan','TxnMM','TxnCashFlow','txnMMDetail') ORDER BY t.name;
```
## #9 — Calendar kapsami
Amac: Calendar tablosunda para birimi basina yil kapsami (tatil = satir yok kurali).
```sql
SET NOCOUNT ON; SELECT TOP (20) CurrencyCode, [Year], COUNT(*) AS GunSatiri FROM dbo.Calendar WHERE [Year] >= 2026 GROUP BY CurrencyCode, [Year] ORDER BY [Year] DESC, CurrencyCode;
```

## #10 — IL'de kullanilan Chart'larin adi
Amac: #6'da IndexChartId=8 ve 7 gorundu, #5'in ilk 50 satirinda yok; Id 3 (MM FX cevrimi, AccFcyChartNo) de dahil.
```sql
SET NOCOUNT ON; SELECT TOP (20) Id, Code, Name, Description FROM dbo.Chart WHERE Id IN (3,7,8) ORDER BY Id DESC;
```
## #11 — Calendar: 24.10.2026 (Cumartesi, DayOfYear=297) TRY/USD/EUR icin satir var mi
Amac: "tatil = Calendar'da satir yok" kuralini canli veriyle dogrulamak (banner: 2026-10-24 -> 2026-10-26).
```sql
SET NOCOUNT ON; SELECT TOP (20) CurrencyCode, [Year], DayOfYear FROM dbo.Calendar WHERE [Year]=2026 AND DayOfYear IN (296,297,298,299) AND CurrencyCode IN ('TRY','USD','EUR') ORDER BY DayOfYear DESC, CurrencyCode;
```
## #12 — TxnLoanTrigger govdesi (kirpildi)
Amac: History tablosunu trigger mi dolduruyor.
```sql
SET NOCOUNT ON; SELECT LEFT(m.definition, 1500) AS Body FROM sys.sql_modules m JOIN sys.triggers t ON t.object_id=m.object_id WHERE t.name='TxnLoanTrigger';
```
## #13 — InterestRate / FXRate kapsami (Chart bazli adet)
Amac: IL'in kullandigi chart'larda (7,8) ve MM FX chart'inda (3) gercekten oran verisi var mi.
```sql
SET NOCOUNT ON; SELECT TOP (20) ChartId, COUNT(*) AS Baslik, MAX(YieldDate) AS SonTarih FROM dbo.InterestRate GROUP BY ChartId ORDER BY MAX(YieldDate) DESC;
SELECT TOP (20) ChartId, COUNT(*) AS Baslik FROM dbo.FXRate GROUP BY ChartId ORDER BY COUNT(*) DESC;
```

## #14 — Trigger history tablosuna yaziyor mu
Amac: #12 govdesi ilk 1500 karakterde sadece basligi gosterdi; trigger govdesinde 'History' gecen tablo adlarini bulmak.
```sql
SET NOCOUNT ON; SELECT t.name, CASE WHEN m.definition LIKE '%TxnLoanHistory%' THEN 1 ELSE 0 END AS TxnLoanHistory, CASE WHEN m.definition LIKE '%TxnMMHistory%' THEN 1 ELSE 0 END AS TxnMMHistory, CASE WHEN m.definition LIKE '%TxnCashFlowHistory%' THEN 1 ELSE 0 END AS TxnCashFlowHistory FROM sys.sql_modules m JOIN sys.triggers t ON t.object_id=m.object_id WHERE t.name IN ('TxnLoanTrigger','TxnMMTrigger','TxnCashFlowTrigger');
```
## #15 — Chart 2,4,5 adlari
Amac: InterestRate'te en cok/en guncel veri olan chart'larin ne oldugu.
```sql
SET NOCOUNT ON; SELECT TOP (20) Id, Code, Name FROM dbo.Chart WHERE Id IN (2,4,5,151) ORDER BY Id DESC;
```

## #16 — prdProductDefinition kolon listesi
Amac: Urun bayrak kolonlarinin tam adlarini bulmak (#17 icin).
```sql
SET NOCOUNT ON; SELECT c.name FROM sys.columns c WHERE c.object_id = OBJECT_ID('dbo.prdProductDefinition') ORDER BY c.column_id;
```
## #17 — Kucuk lookup'lar: RolloverType, defFundSource, Term
Amac: UI'nin Id'ye sabit bagli oldugu RolloverType (1/2/3), FundSource (UI Id=1 varsayiyor) ve Term kovalarini dogrulamak.
```sql
SET NOCOUNT ON;
SELECT TOP (20) * FROM dbo.RolloverType ORDER BY Id DESC;
SELECT TOP (20) * FROM dbo.defFundSource ORDER BY Id DESC;
SELECT TOP (20) * FROM dbo.Term ORDER BY Id DESC;
```
## #18 — Islem hacmi dagilimi
Amac: MM ve IL'de kac islem var, hangi urun/odeme tipi/state ile (dokumandaki 'gercek kullanim' notlari icin).
```sql
SET NOCOUNT ON;
SELECT TOP (20) TxnMmProductTypeId, PaymentType, StateId, COUNT(*) AS Adet FROM dbo.txnMM GROUP BY TxnMmProductTypeId, PaymentType, StateId ORDER BY Adet DESC;
SELECT TOP (20) ProductDefinitionId, StateId, COUNT(*) AS Adet FROM dbo.TxnLoan GROUP BY ProductDefinitionId, StateId ORDER BY Adet DESC;
```

## #19 — Urun tanimlari ve bayraklari
Amac: MM formunda hangi urunler listelenir, IL'de hangileri (IsSameDay/IsZeroRate suzgeci), her urunun bayraklari (is birimi icin urun bazli davranis tablosu).
```sql
SET NOCOUNT ON; SELECT TOP (20) Id, Code, Name, MainProductCode, ExternalMainProductCode, ExternalSubProductCode, IsEnabled, StateId, IsBorrowing, IsPlacement, IsSameDay, IsZeroRate, IsMultiplePayment, UseFundSource, UseSubFundSource, IsAllowRollover, IsAllowTawarruq, IsGenerateFWDAccounting, IsAccountNeeded, IsTaxApplicable, AccountingCalculationMethodTypeId, LogicalReferenceTypeId FROM dbo.prdProductDefinition ORDER BY Id DESC;
```
## #20 — Logical reference tipleri ve hesaplama yontemi tipleri
Amac: LogicalReference onekinin kaynagi (LogicalReferenceType.Code) ve AccountingCalculationMethodType (SL/IRRCL) degerleri.
```sql
SET NOCOUNT ON; SELECT TOP (20) * FROM dbo.LogicalReferenceType ORDER BY Id DESC; SELECT TOP (20) * FROM dbo.AccountingCalculationMethodType ORDER BY Id DESC;
```
## #21 — Ornek LogicalReference'lar
Amac: LogicalReference formatinin canli ornegi (MM ve IL).
```sql
SET NOCOUNT ON; SELECT TOP (3) LogicalReference FROM dbo.txnMM ORDER BY Id DESC; SELECT TOP (3) LogicalReference FROM dbo.TxnLoan ORDER BY Id DESC;
```

## #22 — Sunucudaki veritabani adlari
Amac: LN.DepoRate / MM:AccFcyChartNo parametreleri Common DB'de (FrameworkParameter); hangi DB oldugunu bulmak.
```sql
SET NOCOUNT ON; SELECT TOP (20) name FROM sys.databases ORDER BY name;
```

## #23 — NetTrex/Trex ile baslayan DB adlari (#22 ilk 20 ile kirpildi)
Amac: Common/Framework DB adini bulmak.
```sql
SET NOCOUNT ON; SELECT TOP (20) name FROM sys.databases WHERE name LIKE 'NetTrex%' OR name LIKE 'Trex%' ORDER BY name;
```

## #24 — Common DB adi kesin eslesme
Amac: NetTrexCommon / TrexCommon adli DB var mi.
```sql
SET NOCOUNT ON; SELECT TOP (20) name FROM sys.databases WHERE name IN ('NetTrexCommon','TrexCommon','NetTrexFramework','TrexFramework') ORDER BY name;
```

## #25 — Framework parametreleri (NetTrexCommon.dbo.FrameworkParameter)
Amac: Ekran davranisini belirleyen parametrelerin gercek degerleri: LN.DepoRate (Index/Floating chart + ABM), MM:AccFcyChartNo/ABM, Trex:MMLogicalDate/DefaultCurrency, SystemWDFlag, PortfolioPath:*, MM.Payment.Validation:Level, SendPayment default, InterbankLoan:Enabled, Limit.LimitCheck:*, Revaluation:MM.ReverseType. (Parola/gizli deger tasiyan parametre secilmedi.)
```sql
SET NOCOUNT ON; SELECT TOP (50) OptionPath, OptionName, LEFT(CONVERT(nvarchar(200),Value),120) AS Value FROM dbo.FrameworkParameter WHERE (OptionPath='LN.DepoRate') OR (OptionPath='MM' AND OptionName IN ('AccFcyChartNo','AccFcyChartABM','SystemWDFlag')) OR (OptionPath='Trex' AND OptionName IN ('MMLogicalDate','DefaultCurrency')) OR (OptionPath='PortfolioPath') OR (OptionPath LIKE 'MM.Payment.Validation%') OR (OptionPath='MM.ExternalService.Payments' AND OptionName='SendPayment') OR (OptionName='Enabled' AND OptionPath IN ('InterbankLoan','feature:Tawarruq')) OR (OptionPath LIKE 'Limit.LimitCheck%') OR (OptionPath='Revaluation') ORDER BY OptionPath, OptionName;
```

## #26 — Amortismanli bir IL isleminin nakit akisi satirlari
Amac: Amortisman satirlari (IsAmortization), PrincipalAmount dusmesi, Principal/Interest satir yapisi ve faiz tutari formul kontrolu.
```sql
SET NOCOUNT ON; SELECT TOP (20) c.TxnId, c.OrderNumber, c.PeriodNumber, c.FlowTypeId, c.IsAmortization, c.PrincipalAmount, c.StartDate, c.EndDate, c.PaymentDate, c.Days, c.Rate, c.Spread, c.CashFlowAmount, c.PaymentDirection, c.DaysInYear FROM dbo.TxnCashFlow c WHERE c.TxnId = (SELECT TOP (1) TxnId FROM dbo.AmortizationConfiguration ORDER BY Id DESC) ORDER BY c.OrderNumber;
```
## #27 — CurrencyPair.SwapPointFactor dagilimi
Amac: Spread bps bolenin 10000 disinda oldugu cift var mi.
```sql
SET NOCOUNT ON; SELECT TOP (20) SwapPointFactor, COUNT(*) AS Adet FROM dbo.CurrencyPair GROUP BY SwapPointFactor ORDER BY Adet DESC;
```
## #28 — MM gunluk reeskont ornek satirlari (AccrualDay anlami)
Amac: AccrualDay sabit mi (donem toplami) yoksa 1,2,3 mu (gecen gun).
```sql
SET NOCOUNT ON; SELECT TOP (6) TxnId, CalculationDate, AccrualDay, AccrualAmount, AccrualAmountSL, FXRate FROM dbo.txnMmDailyCalculation WHERE TxnId = (SELECT TOP (1) TxnId FROM dbo.txnMmDailyCalculation ORDER BY Id DESC) ORDER BY Id DESC;
```
## #29 — TxnLoan.PaymentDate ile son TxnCashFlow.PaymentDate farki
Amac: Header odeme tarihi ile motorun son satir odeme tarihi farkli cikan kayit var mi (takvim gunu / is gunu lag farki).
```sql
SET NOCOUNT ON; SELECT COUNT(*) AS Farkli, (SELECT COUNT(*) FROM dbo.TxnLoan) AS Toplam FROM dbo.TxnLoan l CROSS APPLY (SELECT MAX(PaymentDate) AS LastPay FROM dbo.TxnCashFlow WHERE TxnId = l.Id) x WHERE l.PaymentDate <> x.LastPay;
SELECT TOP (10) l.Id, l.MaturityDate, l.PaymentLagDays, l.PaymentDate AS HeaderPay, x.LastPay FROM dbo.TxnLoan l CROSS APPLY (SELECT MAX(PaymentDate) AS LastPay FROM dbo.TxnCashFlow WHERE TxnId = l.Id) x WHERE l.PaymentDate <> x.LastPay ORDER BY l.Id DESC;
```
## #30 — Floating faiz satirlari ornegi
Amac: Floating satirlarda Rate/Spread/Days/CashFlowAmount ve InterestMethodId; Compound'da Rate donem getirisi mi.
```sql
SET NOCOUNT ON; SELECT TOP (10) c.TxnId, c.PeriodNumber, c.InterestMethodId, c.FloatingRateTypeId, c.PrincipalAmount, c.Days, c.Rate, c.Spread, c.CashFlowAmount, c.DaysInYear FROM dbo.TxnCashFlow c WHERE c.FloatingRateTypeId > 0 AND c.FlowTypeId = 2 ORDER BY c.Id DESC;
```

## #31 — CurrencyPair swap point factor olagan disi satirlar
Amac: SwapPointFactor 0/1/100/diger olan cift var mi, Verified mi (Spread/factor bolmesi: factor 0 => DivideByZero; 100 => bps anlami kayar). Kod denetimi (bug avi).
```sql
SET NOCOUNT ON; SELECT TOP (20) FromCurrency, ToCurrency, SwapPointFactor, StateId FROM dbo.CurrencyPair WHERE SwapPointFactor <> 10000 ORDER BY Id DESC;
```
## #32 — MM gunluk reeskont kolon adlari
Amac: #28 'TxnId' kolonu yok hatasi verdi; gercek kolon adlarini bulmak.
```sql
SET NOCOUNT ON; SELECT c.name FROM sys.columns c WHERE c.object_id = OBJECT_ID('dbo.txnMmDailyCalculation') ORDER BY c.column_id;
```

## #33 — #31'in duzeltilmisi (CurrencyPair'de Id kolonu yok; ORDER BY 1)
```sql
SET NOCOUNT ON; SELECT TOP (20) FromCurrency, ToCurrency, SwapPointFactor, StateId FROM dbo.CurrencyPair WHERE SwapPointFactor <> 10000 ORDER BY 1 DESC;
```
## #34 — #28'in duzeltilmisi: MM gunluk reeskont ornegi (kolon TxnMmId)
Amac: AccrualDay sabit mi 1,2,3 mu; AccrualAmount kumulatif mi.
```sql
SET NOCOUNT ON; SELECT TOP (6) TxnMmId, CalculationDate, AccrualDay, AccrualAmount, AccrualAmountSL, AccrualAmountIRR, FXRate FROM dbo.txnMmDailyCalculation WHERE TxnMmId = (SELECT TOP (1) TxnMmId FROM dbo.txnMmDailyCalculation ORDER BY Id DESC) ORDER BY Id DESC;
```

## #35 — Ayni islem icin birden fazla Opening muhasebe fisi
Amac: MM Verify'da HasOpeningAccounting korumasi yok (IL'de var); Edit->Verify turunda ayni islem icin 2. acilis fisi uretiliyor mu (kod denetimi, bug avi). Type=1 Opening, IsReverse=0.
```sql
SET NOCOUNT ON; SELECT TOP (20) TxnId, ProductCode, COUNT(*) AS OpeningFisSayisi FROM dbo.AccEntryMain WHERE Type = 1 AND IsReverse = 0 GROUP BY TxnId, ProductCode HAVING COUNT(*) > 1 ORDER BY TxnId DESC;
```
## #36 — Opening fis toplam sayilari (kontrol)
Amac: #35 bos donerse sorgunun dogru calistigini gostermek icin Opening fis ve urun bazli toplam.
```sql
SET NOCOUNT ON; SELECT TOP (20) ProductCode, Type, IsReverse, COUNT(*) AS Adet, COUNT(DISTINCT TxnId) AS FarkliIslem FROM dbo.AccEntryMain GROUP BY ProductCode, Type, IsReverse ORDER BY Adet DESC;
```

## #37 — Onayli (state 18/26) IL islemlerinden acilis fisi OLMAYAN var mi
Amac: IL'de 52 adet state 18 islem var ama 'Loan' Opening fisi 19; kac onayli IL islemin Opening fisi yok (Verify bastan fis uretmemis mi / ProductCode farkli mi).
```sql
SET NOCOUNT ON;
SELECT COUNT(*) AS OnayliIL, SUM(CASE WHEN EXISTS (SELECT 1 FROM dbo.AccEntryMain a WHERE a.TxnId = l.Id AND a.Type = 1 AND a.IsReverse = 0) THEN 1 ELSE 0 END) AS FisiOlan FROM dbo.TxnLoan l WHERE l.StateId IN (18, 26);
SELECT TOP (10) a.ProductCode, a.Type, a.IsReverse, COUNT(*) AS Adet FROM dbo.AccEntryMain a WHERE a.TxnId IN (SELECT Id FROM dbo.TxnLoan) GROUP BY a.ProductCode, a.Type, a.IsReverse ORDER BY Adet DESC;
```

## #38 — #37'nin duzeltilmisi (SUM icinde EXISTS yasak; ic sorguya alindi)
```sql
SET NOCOUNT ON;
SELECT COUNT(*) AS OnayliIL, SUM(t.v) AS FisiOlan FROM (SELECT CASE WHEN EXISTS (SELECT 1 FROM dbo.AccEntryMain a WHERE a.TxnId = l.Id AND a.Type = 1 AND a.IsReverse = 0) THEN 1 ELSE 0 END AS v FROM dbo.TxnLoan l WHERE l.StateId IN (18, 26)) t;
SELECT TOP (10) a.ProductCode, a.Type, a.IsReverse, COUNT(*) AS Adet FROM dbo.AccEntryMain a WHERE a.TxnId IN (SELECT Id FROM dbo.TxnLoan) GROUP BY a.ProductCode, a.Type, a.IsReverse ORDER BY Adet DESC;
```

## #39 — IL islemlerinde 1'den fazla Opening fisi / onayli ama fissiz IL islemleri
Amac: #38'de IL icin 54 Opening fisi vs 48 fisli onayli islem; fazlalik kimden, ve fissiz 4 onayli islem hangisi (state, valor).
```sql
SET NOCOUNT ON;
SELECT TOP (20) a.TxnId, COUNT(*) AS OpeningFis, MIN(l.StateId) AS StateId FROM dbo.AccEntryMain a JOIN dbo.TxnLoan l ON l.Id = a.TxnId WHERE a.Type = 1 AND a.IsReverse = 0 GROUP BY a.TxnId HAVING COUNT(*) > 1 ORDER BY a.TxnId DESC;
SELECT TOP (10) l.Id, l.StateId, l.ValueDate, l.TradeDate, l.LogicalReference FROM dbo.TxnLoan l WHERE l.StateId IN (18, 26) AND NOT EXISTS (SELECT 1 FROM dbo.AccEntryMain a WHERE a.TxnId = l.Id AND a.Type = 1 AND a.IsReverse = 0) ORDER BY l.Id DESC;
```

## #40 — MM islem 553197: iki Opening fisinin ayrintisi ve durum gecmisi
Amac: Cift Opening fisi Edit->Verify'dan mi (ters fis yok) geliyor; fislerin valor/ters durumu ve txnMMHistory durum gecmisi. Kod denetimi (bug avi), tek islem.
```sql
SET NOCOUNT ON;
SELECT TOP (10) Id, TxnId, Type, IsReverse, ReverseId, ValueDate FROM dbo.AccEntryMain WHERE TxnId = 553197 ORDER BY Id DESC;
SELECT TOP (10) Id, StateId, StateMaker, StateDate, DealAmount, MaturityAmount, ValueDate FROM dbo.txnMMHistory WHERE Id = 553197 ORDER BY StateDate DESC;
SELECT TOP (1) Id, StateId, DealAmount, MaturityAmount, LogicalReference FROM dbo.txnMM WHERE Id = 553197;
```

## #41 — txnMMHistory kolon listesi (Update ile silinen alan var mi hipotezi icin)
Amac: Update'in yeni entity kurup tamamen degistirdigi (alan silme) hipotezini test etmek; hangi kolonlar tabloda var.
```sql
SET NOCOUNT ON; SELECT c.name FROM sys.columns c WHERE c.object_id = OBJECT_ID('dbo.txnMMHistory') ORDER BY c.column_id;
```

## #42 — 553197 Edit/Verify gecmisinde alan kaybi var mi
Amac: Update'te alan silinir mi (AccountNumber, GLCode, BusinessKey, LogicalReference, Incoming/OutgoingPaymentAccountingGL, InputDate, CreatedBy, TransactionOriginType) — ardisik snapshot'lari karsilastirmak.
```sql
SET NOCOUNT ON; SELECT TOP (10) HistoryId, StateId, StateDate, AccountNumber, GLCode, BusinessKey, LogicalReference, TxnTypeCode, InputDate, CreatedBy, Trader, OutgoingPaymentAccountingGL, IncomingPaymentAccountingGL, TransactionOriginType, LinkedTransactionId FROM dbo.txnMMHistory WHERE Id = 553197 ORDER BY HistoryId DESC;
```

## #43 — Ayni snapshot'larda kalan kolonlar (hangi alanlar Update ile siliniyor)
Amac: #42'de AccountNumber/GLCode/Incoming-OutgoingGL silindigi ve BusinessKey bozuldugu goruldu; diger kolonlardan hangileri 18->24 gecisinde degisiyor (swift durumlari, ExternalReference, muhabir alanlari, IsMatured...).
```sql
SET NOCOUNT ON; SELECT TOP (6) HistoryId, StateId, IsMatured, SwiftConfirmationMessageStatus AS SwConf, SwiftPaymentMessageStatus AS SwPay, DomesticPaymentMessageStatus AS DomPay, ExternalReference, ExternalReferenceSourceId AS ExtSrc, OutgoingCorrespondentId AS OutCorr, IncomingCorrespondentId AS InCorr, IncomingCorrespondentAccountNumber AS InAcc, IncomingPaymentAccountingType AS InPAT, IncomingPaymentAccountingGLType AS InPGLT, OutgoingPaymentAccountingType AS OutPAT, SettlementTypeId, PaymentInstructionTypeId AS PIT, SendConfirmation AS SC, SendPayment AS SP, TermId, CustomerLocation AS CustLoc, PreviousStateId AS PrevSt, LastActionId AS LastAct FROM dbo.txnMMHistory WHERE Id = 553197 ORDER BY HistoryId DESC;
```
## #44 — Edit/Verify edilmis MM islemlerinde ayni islem icin birden fazla Fimple hesabi izi
Amac: 553197'de iki farkli AccountNumber (332235, 332236) goruldu; genel olarak txnMMHistory'de ayni Id icin 1'den fazla farkli AccountNumber olan islem sayisi (musteri hesabi sizintisi olcusu).
```sql
SET NOCOUNT ON; SELECT TOP (20) Id, COUNT(DISTINCT AccountNumber) AS FarkliHesap, COUNT(*) AS Snapshot FROM dbo.txnMMHistory WHERE AccountNumber IS NOT NULL GROUP BY Id HAVING COUNT(DISTINCT AccountNumber) > 1 ORDER BY Id DESC;
SELECT COUNT(*) AS GuncelKayitHesapsiz FROM dbo.txnMM m WHERE m.StateId IN (18,26) AND m.AccountNumber IS NULL AND EXISTS (SELECT 1 FROM dbo.txnMMHistory h WHERE h.Id = m.Id AND h.AccountNumber IS NOT NULL);
```

## #45 — Guncel txnMM satirinda Update sonrasi alan durumu + genel olcum
Amac: (a) 553197 guncel satirinda payment accounting type/GL ve hesap alanlari NULL mi (Update'in 'korunan alanlar' kodu ise yaramiyor mu); (b) Edit gecmisi olan (history'de state 24 satiri bulunan) onayli MM islemlerinde AccountNumber/IncomingPaymentAccountingType NULL orani.
```sql
SET NOCOUNT ON;
SELECT Id, StateId, AccountNumber, GLCode, BusinessKey, IncomingPaymentAccountingType AS InPAT, IncomingPaymentAccountingGLType AS InPGLT, IncomingPaymentAccountingGL AS InPGL, OutgoingPaymentAccountingType AS OutPAT FROM dbo.txnMM WHERE Id IN (553197, 553183, 551966);
SELECT TOP (1) COUNT(*) AS EditliVeOnayli, SUM(CASE WHEN m.AccountNumber IS NULL THEN 1 ELSE 0 END) AS HesapsizOlan, SUM(CASE WHEN m.IncomingPaymentAccountingType IS NULL THEN 1 ELSE 0 END) AS InPATnull FROM dbo.txnMM m WHERE m.StateId IN (18,26) AND EXISTS (SELECT 1 FROM dbo.txnMMHistory h WHERE h.Id = m.Id AND h.StateId = 24);
```

## #46 — Onayli MM islemlerinden Opening fisi olmayanlar (backdated verify hipotezi, V-02)
Amac: MM Opening adimi ValueDate != LogicalDate && !IsGenerateFWDAccounting ise fis basmiyor; onay gunu valorden sonra olan islemlerde Opening fisi eksik mi? Onayli (18/26) islemlerden Opening olmayan sayisi ve ilk 10 ornek (ValueDate, StateDate).
```sql
SET NOCOUNT ON;
SELECT COUNT(*) AS OnayliMM, SUM(t.v) AS OpeningOlan FROM (SELECT CASE WHEN EXISTS (SELECT 1 FROM dbo.AccEntryMain a WHERE a.TxnId = m.Id AND a.Type = 1 AND a.IsReverse = 0) THEN 1 ELSE 0 END AS v FROM dbo.txnMM m WHERE m.StateId IN (18,26)) t;
SELECT TOP (10) m.Id, m.LogicalReference, m.ValueDate, CAST(m.StateDate AS date) AS OnayGunu, m.TxnMmProductTypeId AS Urun FROM dbo.txnMM m WHERE m.StateId IN (18,26) AND NOT EXISTS (SELECT 1 FROM dbo.AccEntryMain a WHERE a.TxnId = m.Id AND a.Type = 1 AND a.IsReverse = 0) ORDER BY m.Id DESC;
```

## #47 — Batch ile ilgili tablolar (IL test plani: batch sirasi/tanimi)
Amac: Batch item tanimlarinin ve calisma sirasinin tutuldugu tablolari bulmak.
```sql
SET NOCOUNT ON; SELECT TOP (30) name FROM sys.tables WHERE name LIKE '%Batch%' ORDER BY name;
```

## #48 — BatchSet ve BatchItem tanimlari (kolonlar)
Amac: Batch set/item kolon adlarini bulmak (siralama, tip, aktif, modul).
```sql
SET NOCOUNT ON; SELECT OBJECT_NAME(c.object_id) AS Tablo, c.name FROM sys.columns c WHERE c.object_id IN (OBJECT_ID('dbo.BatchSet'), OBJECT_ID('dbo.BatchItem')) ORDER BY c.object_id, c.column_id;
```

## #49 — BatchSet listesi
Amac: Hangi batch set'ler var (BOD/EOD adlari, Id).
```sql
SET NOCOUNT ON; SELECT TOP (20) Id, Name, Description, StateId FROM dbo.BatchSet ORDER BY Id DESC;
```
## #50 — BatchItem'lar sirasiyla (Set, ItemOrder, Name, State)
Amac: BOD/EOD'de hangi item hangi sirayla kosuyor, hangileri aktif (State/StateId) — IL test siralamasi icin.
```sql
SET NOCOUNT ON; SELECT TOP (50) BatchSetId, ItemOrder, ItemID, Name, State, StateId, IsTransactional, ParentItemNo FROM dbo.BatchItem ORDER BY BatchSetId, ItemOrder;
```

## #51 — IL test ortami: Fimple senkron / muhasebe / reeskont parametreleri (NetTrexCommon.FrameworkParameter)
Amac: Odeme mesaji ve muhasebe testinin on kosullari: Fimple sync anahtarlari (kapaliysa IsPaymentCompleted hemen true olur), UseDirect*, Reeskont ters fis tipi (zaten #25'te 3), hesap kapatma, Tawarruq. Gizli deger icermeyen parametreler.
```sql
SET NOCOUNT ON; SELECT TOP (40) OptionPath, OptionName, LEFT(CONVERT(nvarchar(200),Value),80) AS Value FROM dbo.FrameworkParameter WHERE (OptionPath='Trex' AND OptionName IN ('FimpleMmTreasuryTransactionSync','MmAccountingSync','FxRateCarryNextDay','DepositRateCarryNextDay')) OR (OptionPath LIKE 'MM.ExternalService.API%') OR (OptionPath='MM.Account.Close') OR (OptionPath LIKE 'Payment' AND OptionName LIKE 'MM.%') OR (OptionPath='MM' AND OptionName LIKE '%Wd%') OR (OptionPath LIKE 'feature:Tawarruq%') ORDER BY OptionPath, OptionName;
```
