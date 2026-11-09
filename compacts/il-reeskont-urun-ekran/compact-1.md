# Compact — il-reeskont-urun-ekran · #1

**Sohbet:** il-reeskont-urun-ekran (türetildi) · **Tarih:** 2026-11-09 · **Sıra:** 1 (proaktif — uzun kodlama öncesi)
**Kapsanan aralık:** ilk istekten İş 2 onayına kadar

## 1. Kullanıcının istekleri
- **İş 1 (IL reeskont):** InterbankLoan'da işlem InterestMethod = **SimpleInterest** ise reeskont **ürünün (ProductDefinition) AccountingCalculationMethod'una** (SL / IRR-CL) göre; **CompoundAverage** ise **bugünkü** yöntem. Önce mevcut MM/IL reeskontu açıkla, teyit et, plan sun, "beğenirsem yaparsın".
  - 2. turda: *"burada anlattıklarında problem olacak bir şey var mı? biraz daha açık ol"* → **İş 1 henüz ONAYLI DEĞİL**, riskler açık anlatılacak.
- **İş 2 (ProductDefinition):** AccountSelection'ın altına dropdown (çoklu seçim): MoneyMarket / InterbankLoan — ikisi, biri ya da hiçbiri. Ürünün hangi işlem ekranında görüneceğini belirler. **ONAYLANDI.**
  - *"`(x => !x.IsSameDay && !x.IsZeroRate)` bu filtreyi çıkartabilirsin… gerek kalmıyor artık"* → kaldırılacak.
  - Yeni üründe iki ekran **seçili** gelsin.
  - DB script'ini **Claude yazar**: kolon ekleme + **trigger DROP + yeni trigger CREATE**; NetTrexMM'deki **güncel** tablo/trigger durumuna bakılarak.
- **InterbankLoan:Enabled** kuralı: *"her zaman InterbankLoan ile ilgili bir geliştirme yaz dersem bu konuyu ilk ve en önemli önceliğin haline getirmen lazım… MD'lerin içine bunu ekle, araştırmalarında birinci önceliğin olsun."*
- Unit test yaz; sonunda **test rehberi**: ne gireyim, ne bekleyeyim.

## 3. Kararlar
| Karar | Neden |
|---|---|
| 2 `bit` kolon `IsVisibleInMoneyMarket` / `IsVisibleInInterbankLoan` (child table değil) | 2 sabit ekran, ürünün diğer bayrakları bit |
| API Create/Update'te alanlar `bool?` — Create null→true, Update null→mevcut değer korunur | Web.UI `Controllers/MM/ProductDefinitionController.cs` hâlâ MM'e Create/Update atıyor, alanları bilmiyor |
| Overview'a opsiyonel `Screen` filtresi; IL + flag kapalı → `PRODUCT_DISABLED` | Hard Rule 13 (MM.UI) |
| `GET api/product-definition/screens` — IL yalnız flag açıkken | Emsal `ValueMaturityReportProductsHandler` |
| Mevcut satırların başlangıç değeri: MM=1 hepsi; IL=1 yalnız `IsSameDay=0 AND IsZeroRate=0` | Bugünkü listeler aynen korunur |
| İşlem Create'ine backend guard YOK | Görünürlük ayarı; dış akışlar (ExternalMMStp, Eximbank, ThirdPartyOnTheFly) kırılmasın |

## 5. Ölçülen gerçekler
- MM reeskont: `05_RevaluationEngineAccruedCalculateStep.cs:31-33` ürün IRRCL→IRR, değilse SL.
- IL reeskont: `LoanRevaluationEngineResultMapper.cs:34` `AccrualAmount = TotalAmountNPV`; ürün metodu context'e konuyor (`LoanRevaluationEnginePipelineContextMapper.cs:69-71`) ama hiçbir step okumuyor.
- DB (sql-log #2/#3): IL fiş tutarı = TotalAmountNPV (TxnId 1201155: anapara 60.000, SL 355,07, NPV 60.273,98 → fiş 60.273,98).
- DB (#1): açık TxnLoan → 71 sabit+Simple, 1 değişken+Simple, 20 değişken+Compound. Sabit faizlilerin hepsi InterestMethod=1.
- IL SL `CashFlow.PrincipalAmount`, IRR `Transaction.PrincipalAmount` kullanıyor (`SLCalculatorContextMapper` vs `IRRCLCalculatorContextMapper`).
- MM.UI `InterbankLoanController.cs:417-422` sabit `!IsSameDay && !IsZeroRate`; `MmTransactionController.cs:526-530` filtresiz.

## 6. Açık kalanlar
- İş 1 onayı bekliyor (riskler açıklanacak).

## 7. Devir
İş 2 kodlaması: MM backend → DB script → MM.UI → testler → test rehberi.
