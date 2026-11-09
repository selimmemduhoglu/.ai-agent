# progress-26 — InterbankLoan yazma tarafı yazıldı + 🔴 `ProductCode` ayrım açığı kapatıldı + MaxItems 200→10

**Tarih:** 2026-08-18

## Neden

Kullanıcı iki karar sordu, ikisine de "mantıklı olana göre ilerle" dedi:

1. **Çoklu seçim sınırı:** *"kaç mantıklı geliyorsa o kadar maximum item seçebilecek şekilde ayarla fakat
   tek bir işlemin ne kadar süreceğini nereden bileceksin ki tahmini yap o zaman."*
2. **IL Generate:** *"ben MM'i de InterbankLoan'ı da Product olarak göstermek istiyorum… bu ikisinin
   sürecini ben strategy pattern ile yönettim… WebUI'dan parametrik olarak taşıyıp mı backend'e girdikten
   sonra o şekilde mi ilerlemesini istersin… zaten revaluation ve reverse steplerinde de ayrımı ve
   pattern'i görürsün ne yapalım."*

Kullanıcı doğru yere işaret etti — mevcut Strategy pattern incelendi ve **ona uygun** çözüldü.

## Mevcut pattern (okundu, kanıt)

`RevaluationAccountingService.cs` ve `LoanRevaluationAccountingService.cs` **yapısal olarak aynı**:
aynı `IRevaluationAccountingPipeline`, aynı `RevaluationAccountingServiceContext`, aynı `CommitAsync`.
**Tek fark:** transaction'ı hangi tablodan yüklediği (`ITransactionDataManager` → `TxnMmEntity` vs
`ITransactionLoanDataManager` → `TxnLoanEntity`). Pipeline'ın içinde ürün ayrımı Strategy ile:
`IRevaluationAccountingPersister.IsApplicable(ProductSourceType)`.

Yani ev konvansiyonu: **ince servis (veri kaynağı farkı) → paylaşılan pipeline → içinde Strategy persister.**
`RevaluationBatchItem.cs:92-95` (MM) ve `:128-131` (Loan) tam olarak bu dallanmayı yapıyor.

🔑 **Ters fiş (T+1) için dallanma YOK ve gerekmiyor:** `IRevaluationReverseAccountingService`
`AccEntryMain.Id` üzerinden çalışıyor, transaction tablosunu bilmesi gerekmiyor. Batch de her iki ürün
için **aynı** reverse servisini kullanıyor (`ReverseBatchItem.cs:76` ve `:109` — tek alan).
Yani yazılacak iş **sandığımdan küçüktü**: sadece T+0 tarafı.

## 🔴 Yol boyunca bulunan GERÇEK açık — `AccEntryMain` ayrımı yapılmıyordu

Kod yazmadan önce şunu doğruladım (iyi ki):

`AccountingDataManager.GetRevaluationByValueDateAsync` (satır 109-116) yalnız
`TxnId` + `Type` + `IsReverse` + `ValueDate` filtreliyordu — **`ProductCode` YOK**.

Sonra EF konfigürasyonuna baktım — `AccEntryMainConfiguration.cs:72-80`:
```csharp
builder.HasOne(x => x.Transaction)     .WithMany(x => x.AccountingMainEntries).HasForeignKey(x => x.TxnId).IsRequired();
builder.HasOne(x => x.TransactionLoan) .WithMany(x => x.AccountingMainEntries).HasForeignKey(x => x.TxnId).IsRequired();
```
İki navigation **AYNI `TxnId` FK'sını** paylaşıyor, **discriminator/query filter YOK**.

🔴 **Bu, progress-20'de kaydettiğim bir bilgiyi çürütüyor.** MM `MEMORY.md`'de *"nav property'leri EF
tarafında zaten doğru scope'lanmış, LINQ'te elle ProductCode filtrelemeye gerek yok"* yazıyordu —
**YANLIŞ**. O girdi düzeltildi (`NetTrex.MM/.ai-agent/MEMORY.md`).

**Neden bugün patlamıyor:** `TxnMM.Id` (≤553.395) ve `TxnLoan.Id` (≥1.201.069) aralıkları **ayrık**
(daha önce DB'den ölçülmüş). Yani risk **latent** — reseed/veri taşıma/yeni ortamda örtüşürse
**sessizce yanlış fiş** okunur: IL satırı seçilip MM'in fişine ters kesilebilir → **gerçek para hatası**.

**DB doğrulaması denendi ama YAPILAMADI:** `192.168.10.211` erişilemiyor (sorgu ve hata
`sql-log/manuel-reeskont-kodlama/{01,02}` #17'ye kaydedildi). Karar değişmedi — `ProductCode` filtresi
çakışma olsun olmasın **her koşulda doğru** olan davranış, o yüzden doğrulanamaması engel değil.

## Yapılanlar

### 1. `ProductCode` filtresi — 3 yerde

Karşılaştırma **veri-güdümlü**, `'MM'`/`'Loan'` string'i **gömülmedi**: `AccEntryMain.ProductCode` fiş
üretilirken transaction'ın kendi ürün tanımından geliyor
(`RevaluationAccountingPipelineContextMapper.cs:39` / `:104` → `MainProductCode`), o yüzden aynı kaynakla
karşılaştırılıyor.

| Dosya | Değişen |
|---|---|
| `IAccountingDataManager.cs` | `GetRevaluationByValueDateAsync`'e `ProductSourceType sourceType` parametresi (zorunlu) + gerekçe doc'u |
| `AccountingDataManager.cs` | `sourceType`'a göre `x.TransactionLoan.ProductDefinition.MainProductCode == x.ProductCode` / `x.Transaction.Product.MainProductCode == x.ProductCode` |
| `TransactionLoanDataManager.cs` | Manuel Reeskont sorgusundaki `AccountingMainEntries` filtrelerine `ProductCode` eklendi (2 yer: opening kontrolü + durum türetme) |
| `TransactionDataManager.cs` | Aynısı MM tarafı için |

⚠️ **Batch sorgularına DOKUNULMADI** (`GetPendingRevaluationTransactions` vb. aynı desende filtresiz).
Kapsam dışı ve riskli — ayrı iş olarak not edildi. Sadece Manuel Reeskont'un kendi sorguları düzeltildi.

### 2. InterbankLoan yazma tarafı (T+0 dispatch)

`ExecutionsHandler`:
- `ILoanRevaluationAccountingService` **enjekte edildi**
- `ResolveProductSourceType` eklendi — okuma ucuyla (`EligibleTransactionsHandler`) **aynı anahtar sözlüğü**;
  bilinmeyen Product → `PRODUCT_UNKNOWN`, sessizce bir tabloya düşmüyor
- `CreateRevaluationAsync` artık `sourceType`'a göre doğru servisi seçiyor
- `sourceType` tüm zincire geçiriliyor (`ExecuteItemAsync` → `GenerateAsync`/`RegenerateAsync` →
  `GetRevaluationByValueDateAsync`)
- **Ters fiş dallanması YOK** — gerekmiyor (yukarıdaki gerekçe, doc'a yazıldı)
- 🔴 `InFlight` guard anahtarına `productSourceType` **dahil edildi**: Id aralıkları örtüşürse aynı
  anahtar iki farklı işlemi temsil edip birini haksızca "zaten çalışıyor" diye reddederdi

### 3. `MaxItems` 200 → 10 (tahmin gerekçeli)

Kullanıcı *"tek bir işlemin ne kadar süreceğini nereden bileceksin, tahmini yap"* dedi. Tahmin
**ölçüme dayandırıldı**, keyfi değil:

- Canlı log (2026-08-18): tek satır Fimple turu **~6.2-6.7 sn** (Redis cache miss'te +5 sn; bir kez 51.8 sn)
- WebUI→MM Refit client'ında **timeout tanımlı değil** (`RefitExtensions.cs:104-109`) →
  `HttpClient` varsayılanı **100 sn**
- 100 / ~7 ≈ **14 satır** → güvenli pay ile **10** seçildi (bir satır yavaşlarsa hâlâ sığar)

🔴 **Sessiz kırpma kaldırıldı.** Eskiden `request.Items.Take(MaxItems)` vardı: 30 satır seçilirse 20'si
**sessizce yok sayılıyor** ve ekran "işlendi" diyordu. Artık sınır aşılırsa `TOO_MANY_ITEMS` ile
**istek hiç işlenmiyor** ve kullanıcıya kaç satır seçebileceği söyleniyor (yarım iş bırakmak, hiç
yapmamaktan kötü — fiş üreten döngü).

`ExecutionsRequestValidator` sınırı da 200 → 10 hizalandı (iki yerde farklı sınır olması tuzaktı).

Bu bir **tahmin** ve doc'a öyle yazıldı: Fimple yanıt süresi ortama/yüke göre değişir. Daha büyük
partiler gerekirse doğru çözüm **sınırı büyütmek değil, client-side parçalama** (parça başına ayrı
istek + ilerleme göstergesi) — o zaman timeout hiç devreye girmez.

## Test durumu

- `dotnet build` (test projesi) → **0 error**
- `NetTrex.MM.Api.Services.Tests.exe -namespace "*ManualRediscount*"` → **89 test, 0 hata** (83 → 89)
- Yeni 6 test:
  - `Handle_WhenProductUnknown_ShouldFailWithoutTouchingAccounting`
  - `Handle_WhenItemCountExceedsLimit_ShouldProcessNothingAndSayWhy` (sessiz kırpma regresyonu)
  - `Handle_WhenItemCountIsExactlyAtLimit_ShouldProcessAll` (sınır ucu)
  - `Handle_WhenProductIsInterbankLoan_ShouldUseLoanServiceNotMm` ← **yanlış tabloya fiş kesme riskini kilitliyor**
  - `Handle_WhenProductIsMm_ShouldUseMmServiceNotLoan`
  - `Handle_ShouldPassMatchingProductSourceTypeToStatusLookup` (ProductCode ayrımının handler ayağı)
- `VerifyNoAccountingCalls` artık **loan servisini de** kontrol ediyor (guard'lar hiçbir ürün için fiş kesmemeli)
- Regresyon kontrolü: `NetTrex.MM.Data.Tests` **3/3 ✅**, `NetTrex.MM.Data.Repository.Tests` **271/271 ✅**
- `GetRevaluationByValueDateAsync`'in başka çağıranı **yok** (grep'le doğrulandı) — imza değişikliği güvenli
- ⚠️ **Tarayıcıda test edilmedi** — IL satırında Generate/Regenerate kullanıcı testi bekliyor
- ⚠️ DataManager sorguları (LINQ→SQL) **birim testle kapsanmıyor** — bu projede genel boşluk, gerçek DB gerekiyor

## Açık kalan

| Konu | Durum |
|---|---|
| IL Generate tarayıcı testi | Kullanıcı test edecek |
| `TxnMM.Id` ↔ `TxnLoan.Id` çakışma doğrulaması | DB erişilemedi (#17) — erişim gelince teyit edilmeli |
| Batch sorgularında `ProductCode` filtresi eksik | Kapsam dışı bırakıldı, **ayrı iş** |
| `AccruedInterest`/`DailyAccrual` IL'de `null` | progress-20'den beri açık |
| Kafka broker down — fişler NetTrexAcc'de var mı | Kullanıcı kontrol etmeli |
| `FxRate` hardcoded 0 | Fimple kullanıyor mu — doğrulanmalı |
| Para birimi bazlı ondalık (JPY/KWD) | Altyapı boşluğu |
| Execute-hang soruşturması | Parkta (progress-21) |
