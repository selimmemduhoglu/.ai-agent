# progress-51 — 🟢 FX modülü entegre edildi (4. modül) · FX'te ayrı mirror servisi YOK, motorun kendi `Rediscounted` dalı kullanıldı · namespace çakışması tuzağı

**Tarih:** 2026-09-17 · **Repo:** `NetTrex.Fx` + `NetTrex.Web.UI`
**Test:** FX Manual Rediscount **36/36** ✅ · **Build:** `NetTrex.Fx.sln` 0 Error · `Trex.Web.UI.sln` 0 Error

> `progress-50`'nin tam hali + FX turu. Önceki turların içeriği değişmedi; bu dosya
> **FX modülünün yayılımını** ekler.

---

## Kullanıcının bu turdaki sözleri

| # | Söz | Sonuç |
|---|-----|:-----:|
| 1 | *"Şimdi de Fx projesine Manuel reeskontu uygulayalım. MD'yi oku, orada yeni bir modüle nasıl yazacağımız vardı."* | ✅ `12-modul-yayilim-rehberi.md` izlendi |
| 2 | *"Fx tarafındaki kodları hiç bilmiyorum, baya önce yazılmış, MM'e çok benzemeyebilir, dikkatli ol."* | 🔴 **Doğru çıktı** — bkz. bölüm 1 |
| 3 | *"Fx için manuel reeskont ekranı zamanında yazılmıştı (`/general/ManuelRevaluation/Index`), o geliştirmeyi incele, DB'ye nasıl bağlandığını anla."* | ✅ Eski ekran + 2026-07-27 araştırma MD'leri okundu |
| 4 | 🔴 *"Önceden ManuelReeskont geliştirmesi olduğu için yeni manualrediscount geliştirmesi için **namespace'lere dikkat et**."* | ✅ **Tam isabet** — bkz. bölüm 6 |

---

## 1 — FX, üç modülün hiçbirine benzemiyor

| Konu | MM / OptFX | DerivSwp | **FX** |
|---|---|---|---|
| Ürün sayısı | 1 işlem tablosu | 1 işlem tablosu | 🔴 **4 native + 2 Fimple tablosu**, **5 ayrı valuation tablosu** |
| Reeskont motoru | `IRevaluationAccountingService` | `IOperationFactory.GetOperation(Revaluation)` | `IValuationService.BuildValuationAccounting(...)` |
| Motorun imzası | context alır | txn + tarih alır | 🔴 **satırın statüsünü parametre alır ve içeride dallanır** |
| Ters fiş | ayrı servis | `IAccountingReverseService` | aynı metodun `NotReversed` dalı |
| Ters fiş valörü | context'ten | context'ten | 🔴 **`valuationDate.AddDays(1)` HARDCODE** idi |
| Nötrleme (mirror) | yazıldı | yazıldı | 🟢 **ZATEN VAR** — yazılmadı, bkz. bölüm 3 |
| Veri katmanı | `*DataManager` | `*Repository` | `*Repository` |
| Handler base | `FlowHandler` / `BaseHandler` | `BaseHandler` | `BaseHandler` |
| DI scan | elle kayıt | elle kayıt | **Scrutor** (`Operations` + `Core` + `Repository` assembly taraması) |

---

## 2 — Uygunluk süzgeci: EOD batch'in **7 ayrı** batch item'ı ile birebir

FX'te tek bir "reeskont batch"i yok; `Batch/NetTrex.Fx.Batch.EndOfDay/Reeskont/` altında **7 item** var
ve her biri kendi süzgecini taşıyor. Ekran bunların **birleşimini** gösterir:

| Alt ürün | Kaynak batch item | Süzgeç |
|---|---|---|
| `Fx` | `FxTransactionReeskontBatchItem` + `FxFutureTransactionReeskontBatchItem` | `TradeDate.Date <= d && ValueDate > d && ValueDate.Date > TradeDate.Date && (FWD \|\| FUT \|\| (spotAktif && SPOT))` + ActiveRecords |
| `FXSwap` | `FxSwapTransactionReeskontBatchItem` | aynı tarih üçlüsü, **enstrüman filtresi YOK** |
| `Pm` | `PmTransactionReeskontBatchItem` + `PmFutureTransactionReeskontBatchItem` | `Fx` ile aynı |
| `PmSwap` | `PmSwapTransactionReeskontBatchItem` | `FXSwap` ile aynı |
| `ExternalFWD` / `ExternalSWP` | `ExternalTransactionReeskontBatchItem` | `MaturityDate > d && TransactionDate <= d && State == "Active"` (maker-checker YOK) |

🔴 **Eski ekrandan sapma (bilinçli, `D-4` ilkesi):** eski `ManualRediscountSelectHandler`
`ValueDate.Date > TradeDate.Date` şartını ve enstrüman filtresini **uygulamıyordu** →
batch'in hiç reeskont etmeyeceği satırları listeliyordu. Yeni ekran batch ile aynı kümeyi gösterir.

🟢 **Eski ekranın N+1'i kaldırıldı:** eski kod `AsEnumerable()` sonrası satır başına 2 sorgu
atıyordu (N işlem = 2N+1 sorgu). Yeni sorgu her şeyi **tek SQL projeksiyonunda** (korelasyonlu
alt sorgular) çözüyor. Global sayfalama, alt ürün başına `Take(skip+take)` + bellekte birleştirme
ile yapılıyor — sayımlar **SQL'de**.

---

## 3 — 🟢 FX'e mirror servisi YAZILMADI: motorun kendi `Rediscounted` dalı zaten o işi yapıyor

MM/DerivSwp/OptFX'te `Rediscounted` bir satırı yeniden değerlemek için **ayna + aynanın tersi**
üreten yeni bir servis yazılmıştı. FX'te buna gerek yok:

```
ValuationService.BuildValuationAccounting(..., statusType: Rediscounted)
  └ fxValuationOperation.DeleteValuation(entity, valuationDate)   // valuation + fişi SOFT-DELETE
  └ foreach deletedMainEntry with ReverseId != 0:
        reverse.ValueDate != entry.ValueDate ise → DoForward + DoReverse ile tarih hizala
  └ (early return YOK) → AddValuation + ExecuteAccounting + Fimple sync
```

Yani FX'in "regenerate"i **sil-ve-yeniden-oluştur**, ayna değil. Handler bu dalı kullanıyor:

| Bizim operasyon + statü | FX motoruna geçilen `statusType` | Ters fiş valörü |
|---|---|---|
| Generate / `NotRediscounted` | `NotRediscounted` | — |
| Generate / `NotReversed` | `NotReversed` | kullanıcının seçtiği T+1 / T+0 |
| Generate / `Rediscounted` | *çağrılmaz* → `ALREADY_REDISCOUNTED` | — |
| Regenerate (fiş varsa) | 1. `Rediscounted` → 2. `NotReversed` | 2. aşamada T+1 |
| Regenerate (fiş yoksa) | 1. `NotRediscounted` → 2. `NotReversed` | 2. aşamada T+1 |

---

## 4 — 🔴 `reverseDate` hardcode'u parametreleştirildi

`BuildValuationAccounting`'in üç uygulamasında da satır başında

```csharp
DateTime reverseDate = valuationDate.AddDays(1);   // ESKİ
DateTime reverseDate = reverseValueDate.HasValue ? reverseValueDate.Value.Date : valuationDate.AddDays(1);   // YENİ
```

İmzalara **opsiyonel** `DateTime? reverseValueDate = null` eklendi (3 interface + 3 concrete).
Bu olmadan sözleşmedeki `ReverseValueType = T0` ve Regenerate'in aynı güne ters kesme adımı
uygulanamıyordu.

🟢 **Risk düşük:** `BuildValuationAccounting`'i çağıran **tek yer** eski
`ManualRediscountUpdateHandler` idi (EOD batch'leri bu metodu kullanmıyor, kendi akışlarını
inline yazıyor). Opsiyonel parametre olduğu için eski handler'ın davranışı **birebir aynı**.

---

## 5 — 🔴 `executions` sözleşmesinde alt ürün alanı YOK → referans ön ekinden çözülüyor

`ExecutionItem` yalnız `{ transactionId, logicalReference, currentStatus }` taşıyor. FX'te hangi
tabloya gidileceğini bilmek şart. Çözüm: eski ekranın kullandığı ön ek setiyle birebir

```
TFXSW… → FXSwap   TFX… → Fx   TPMSW… → PmSwap   TPM… → Pm   FWD… → ExternalFWD   SWP… → ExternalSWP
```

Eski koddaki switch **exhaustive değildi** (`SwitchExpressionException` riski); yenisi
tanımadığı ön ekte satırı `OUT_OF_SCOPE` ile düşürüyor, istek patlamıyor.

---

## 6 — 🔴 NAMESPACE ÇAKIŞMASI (kullanıcının uyarısı) — yeni modüllerde tekrarlanabilir

FX'te **zaten** `NetTrex.Fx.Domain.Enums.ManualRediscount` adında bir **sınıf** var
(eski ekranın `RediscountProductTypes` / `RediscountStatusTypes` enum'larını taşıyor).

Yeni kod diğer modüllerdeki gibi `…ResponseRequest.ManualRediscount` **namespace**'iyle açılınca,
`using NetTrex.Fx.Domain.Enums;` taşıyan **eski** dosyalarda `ManualRediscount.RediscountProductTypes`
ifadesi artık namespace'e çözüldü → `CS0234` (4 hata, eski dosyalarda).

**Çözüm:** yeni namespace'lerin son segmenti **çoğul** yapıldı, eski dosyalara dokunulmadı:

```
NetTrex.Fx.ResponseRequest.ManualRediscounts[.Request|.Response]
NetTrex.Fx.Domain.Model.ManualRediscounts
NetTrex.Fx.Repository.Repository.Fx.ManualRediscounts
NetTrex.Fx.Operations.ManualRediscounts
NetTrex.Fx.Business.Fx.Transaction.ManualRediscounts[.Handlers|.Validators]
NetTrex.Fx.Web.API.Controllers.ManualRediscounts
```

Klasör adları `ManualRediscount` (tekil) kaldı — çakışan şey namespace, klasör değil.

> **Kural (yeni modüllere):** modülde `ManualRediscount`/`Rediscount` adında bir **tip** var mı
> diye `grep -rn "class ManualRediscount\|enum Rediscount"` ile bak; varsa namespace segmentini
> çakışmayacak şekilde seç. C# namespace, aynı isimli tipi **gölgeler**.

---

## 7 — 🔴 Aynı DI tuzağı FX'te de var

```csharp
// NetTrex.Fx.Core/Extensions/ServiceCollectionExtension.cs:17
services.AddTreasyDbContext<EfDbContext>(connectionString, configuration);
// NetTrex.Fx.Web.API/Startup.cs:210
services.AddScoped<IDataContext, EfDbContext>();
```

İki AYRI scoped instance. Bu yüzden yeni kodun **hiçbiri** `EfDbContext`'i doğrudan enjekte
etmiyor; `IDataContext` alıp cast ediyor (`ManualRediscountRepository`, `ChangeTrackerService`) —
repository'lerin kullandığı context ile aynı olsun diye.

---

## 8 — Satır izolasyonu (§ 6) FX'te nasıl kuruldu

```
foreach item:
    TransactionScope(RequiresNew)          // FX'in kendi deseni, eski handler'dan
        changeTrackerService.Reset()       // satır başında
        her motor çağrısından sonra: unitOfWork.CommitAsync() + Reset()
        hata → Rollback + Reset, diğer satırlar etkilenmez
```

🔴 Motor **commit etmiyor** (DerivSwp gibi, MM/OptFX'ten farklı) → handler commit ediyor.
Regenerate iki aşamalı olduğu için aşamalar **arasında** commit + `Reset()` şart: ikinci aşama
birinci aşamanın yazdığı fişi geri okuyor.

Ek koruma: `InFlight` guard (`FXTransactions|{txnId}|{yyyyMMdd}`) — çift tıklama.

---

## 9 — `Data` sözlüğü / kolon seti (21 kolon)

`InstrumentName · TxnTypeCode · CcyPair · BuyCcy · BuyAmount · SellCcy · SellAmount · DealRate ·
BenchmarkRate · TradeDate · ValueDate · DaysToMature · ValuationSpotRate · ValuationRate ·
MtmRate · MtmAmount · MtmLcyAmount · MtmCcy · DaysPassed · DaysToMaturity · Info`

Doğrulandı: **config 21 ↔ backend `Data` 21 ↔ tr 21 ↔ en 21**.
14 yeni `mr-col-*` anahtarı 6 lokalizasyon dosyasına eklendi (sayfa tr/en + 2 bundle + 2 devextreme bundle).

**Alt ürün listesi** `treasury.json`'da sabit (`ProvidesSubProducts => false`):
`Fx · FXSwap · Pm · PmSwap · ExternalFWD · ExternalSWP`.
⚠️ Önceki placeholder (`Spot/Forward/SwapNear/SwapFar`, WebUI `ProductType` enum'undan) **değiştirildi** —
o liste FX modülünün reeskont ürün ailelerine karşılık gelmiyordu. Eski FX ekranının kendi
Product filtresiyle birebir aynı set kullanıldı.

---

## 10 — Dosya listesi

**NetTrex.Fx**
- `ResponseRequest/ManualRediscount/` — enums + 3 request + 2 response
- `Domain/Model/ManualRediscount/RediscountEligibleModels.cs`
- `Repository/Repository/Fx/ManualRediscount/{I,}ManualRediscountRepository.cs`
- `Repository/Tracking/{I,}ChangeTrackerService.cs`
- `Operations/ManualRediscount/{I,}FxManualRediscountEngine.cs` — 6 alt ürün dispatcher'ı
- `Business/Fx/Transaction/ManualRediscount/` — resolver + 2 handler + validator
- `Web.API/Controllers/ManualRediscount/ManualRediscountController.cs`
- `Operations/ValuationOperation/{Abstract,Concrete}` — 6 dosyada opsiyonel `reverseValueDate`
- `UnitTest/Api/NetTrex.Fx.Business.Test/ManualRediscount/` — 3 dosya, **36 test**

**NetTrex.Web.UI**
- `Services/ManualRediscount/Modules/Fx/{IManualRediscountFxApi,FxManualRediscountModuleClient}.cs`
  (🔴 marker `IClientFxAPI`, namespace `Trex.WebUI.Services` — OptFX'ten farklı)
- `ManualRediscountRefitRegistration.cs` — `RegisterManualRediscountFxApiTimeout`
- `Startup.cs` — 3 satır
- `treasury.json` — FX bloğu: 6 alt ürün + 21 kolon
- 6 lokalizasyon dosyası — 14'er yeni anahtar

---

## 11 — Açık kalanlar

| # | Konu | Durum |
|---|------|:-----:|
| F-1 | **Uçtan uca doğrulama yapılmadı** — birim testler geçiyor, gerçek fiş/Fimple senkronu görülmedi | ⬜ |
| F-2 | 🔴 `AccEntryMain.TxnId` **4 ayrı işlem tablosunun** Id'sini taşıyor; tek ayırt edici alan `ProductCode`. Grid sorgusu `(ProductCode == null \|\| == kod)` ile ayırıyor, ama `executions` içindeki statü yeniden doğrulaması **ayırmıyor** (eski davranış korundu). External ile native Fx **aynı** ProductCode'u (`FX`) kullanıyor | ⬜ ölçülmeli |
| F-3 | Eski `api/Rediscount/select\|update` ucu ve eski WebUI ekranı **duruyor**; ne zaman kaldırılacağı iş birimi kararı (`C-20`) | ⬜ |
| F-4 | `FX.FutureExternal` altındaki **12 test** ondalık ayraç (locale) yüzünden kırmızı — **bu turdan önce de kırmızıydı**, bu işle ilgisi yok | ⬜ ayrı iş |
| F-5 | Alt ürün listesi iş birimiyle teyit edilmedi (özellikle `Future` ayrı satır olsun mu — şu an `Fx`/`Pm` içinde) | ⬜ |

---

## 12 — Durum

| Modül | Durum |
|---|:---:|
| MM (+InterbankLoan) | ✅ bitti, prod'da |
| DerivSwp | 🧪 test ediliyor |
| OptFX | 🧪 test ediliyor |
| **FX** | 🟢 **kod hazır, build+test yeşil, uçtan uca test bekliyor** |
| FI / InvFund | ⬜ |
