# Progress 2 — İş 1 kodlandı (IL reeskont: InterestMethod → ürün metodu)

**Tarih:** 2026-11-09 · **Repo:** NetTrex.MM (UI değişikliği yok, DB script yok)

## Kullanıcı kararları (2026-11-09)
- Karar **işlem kaydındaki** InterestMethod'dan (`TxnLoan.InterestMethodId`) okunur — cash flow'dan değil.
- IL IRR **dönem anaparasına** çekilir (`LoanRevaluation.PeriodAccrualAmountIRR` değeri de değişir).
- Açık test işlemleri önemsiz (prod'a çıkılmadı).

## Yapılanlar
- `LoanRevaluationEngineTransactionModel` + `InterestMethodId`; `LoanRevaluationEnginePipelineContextMapper` işlem kaydından doldurur.
- Yeni `07_LoanRevaluationEngineAccrualAmountStep` (Scrutor `IEngineStep` taraması, DI satırı yok): Compound → NPV, Simple → ürün IRR-CL → IRR / SL → SL (+LCY).
- `LoanRevaluationEngineCalculateStepModel` + `AccrualAmount`/`AccrualAmountLCY`; `LoanRevaluationEngineResultMapper` artık bunları basıyor (eskiden `TotalAmountNPV`).
- `IRRCLCalculatorContextMapper` (yalnız Loan dalı) `PrincipalAmount` ← `CashFlow.PrincipalAmount`. MM dalı değişmedi.
- IL flag: yeni uç/ekran yok; giriş yolları zaten korumalı (`RevaluationBatchItem:43`, `ExecutionsHandler` `PRODUCT_DISABLED` + testleri).
- Testler: `LoanRevaluationEngineAccrualAmountStepTests` (8) + `LoanRevaluationEngineMapperTests` (4) yeşil.
- Test rehberi: `NetTrex.MM/.ai-agent/outputs/2026-11-09-IL-Reeskont-InterestMethod/TEST-REHBERI.md`.

## Açık
- ✅ `NetTrex.MM.Common.Services.Tests` tam koşusu: baseline 292 test 1224 sn, yeni 300 test 1242 sn, ikisi de 0 hata — yavaşlık (16 AutoFixture-ağır muhasebe/cash flow testi) ÖNCEDEN VAR, değişiklikle ilgisi yok.
- `TxnLoan` ↔ `TxnCashFlow` InterestMethod ayrışması (Edit akışı) — ayrı hata adayı, dokunulmadı.
