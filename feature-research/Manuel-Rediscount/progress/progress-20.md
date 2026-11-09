# progress-20 — InterbankLoan okuma ucu yazıldı: TxnLoan dispatch'i canlı, fiş kesme hâlâ MM'de

**Tarih:** 2026-08-17

## Neden

Kullanıcı üç şey istedi aynı turda:
1. `TransactionDataManager`'daki `TxnMmProductTypeId != ISSUE` filtresini **şimdi sil** (önce "kalsın"
   demişti, sonra fikrini değiştirdi — IssueBond zaten MM'e girilmiyor).
2. **InterbankLoan'ın okuma ucunu gerçekten yaz** — "MM için TxnMM'e, Loan için TxnLoan'a gitmen lazım,
   bunu nasıl ayırt ediyorsun" sorusunun cevabı olarak.
3. `ResolveSubProductName`'e neden switch eklediğimi açıkla (kozmetik — sayı yerine isim).

## 🔴 Yol boyunca bulunan gerçek bir hata: kullanıcının "TxnMmProductTypeId hem TxnMM hem TxnLoan'da var" iddiası YANLIŞ

Kullanıcı SubProduct kaynağını netleştirirken "ikisi de `TxnMmProductTypeId` kolonu üzerinden" dedi.
Kod (`TxnLoanEntityBase`) ve DB (`sys.columns`, `NetTrexMM_134.TxnLoan`) ikisi de bunu **doğrulamadı** —
TxnLoan'da böyle bir kolon **yok**, onun yerine `ProductDefinitionId` (FK → `PrdProductDefinition`) var.
Yazmadan önce durdum, DB'den doğruladım, kullanıcıya söylemeden ilerlemedim (Hard Rule: "emin değilsen
dur, sor — uydurma").

**Kurtarıcı bulgu:** `PrdProductDefinition` tablosu (`Id 1-11`) **MM'in `TxnMmProductTypeId`/
`ProductAccountingCodeType` enum'uyla AYNI numaralandırmayı** taşıyor (1=MoneyMarket, 2=Loan,
4=Wakale, 5=Murabaha, 6=TermDeposit, 7=Pass, 8=Gil, 9=Syndication, 10=Securitization,
11=Post-Financing). Yani kullanıcının niyeti ("aynı ürün kataloğu") **teknik olarak doğruydu**, sadece
kolon adı yanlış hatırlanmıştı — `ProductDefinitionId` ile aynı sayısal Id'leri kullanarak MM'in
mevcut `ResolveSubProductTypeId` eşlemesi **hiç değişmeden** Loan tarafına da uygulanabildi.

DB'den ayrıca görüldü: bu ortamdaki 57 `TxnLoan` satırının **tamamı** `ProductDefinitionId=2`
("Interbank Loan") kullanıyor — bugün için alt ürün çeşitliliği yok, ama filtre mekanizması doğru
kurulduğu için ileride Murabaha/Wakala tipi bir interbank loan girilirse otomatik doğru çalışır.

## Yapılan

### 1. ISSUE filtresi kaldırıldı

`TransactionDataManager.GetRediscountEligibleTransactionsAsync`'teki
`query = query.Where(x => x.TxnMmProductTypeId != (int)ProductAccountingCodeType.ISSUE);` satırı
silindi. İlgili yorum/dokümantasyon (`EligibleTransactionsHandler.ResolveSubProductTypeId` remarks)
güncellendi. **Test yok, silinecek test de yoktu** — bu filtre hiçbir zaman otomatik testle
kapsanmamış, 2026-08-13'teki "testte yakalandı" ifadesi canlı DB analizine referanstı, xUnit'e değil.

### 2. InterbankLoan okuma ucu — yeni kod

- **`ITransactionLoanDataManager`** — yeni metod: `GetRediscountEligibleTransactionsAsync` (MM'in
  aynı isimli metoduyla birebir imza).
- **`TransactionLoanDataManager`** — implementasyon, MM'in sorgusuyla aynı iskelet, TxnLoan'a uyarlanmış:
  - Faiz dönemi filtresi: `Details.PeriodStartDate/PeriodEndDate` yerine
    `CashFlows.Where(FlowTypeId == FlowType.Interest && StartDate <= date && EndDate > date)`.
  - Alt ürün filtresi: `TxnMmProductTypeId` yerine `ProductDefinitionId` (yukarıdaki bulgu).
  - Durum türetme (`AccEntryMain.ReverseId` → NotRediscounted/NotReversed/Rediscounted): **MM ile
    birebir aynı** — `TxnLoanEntity.AccountingMainEntries` EF tarafında zaten `ProductCode='Loan'`
    ile doğru scope'lanıyor (DB'den doğrulandı, `AccEntryMain.ProductCode` değerleri: `MM`/`TWR`/`Loan`).
  - 🔴 **`AccruedInterest`/`DailyAccrual` bilerek `null`** — MM'deki `Valuations` (günlük tahakkuk kaydı
    tablosu) TxnLoan'da yok, `LoanRevaluationEngineService` bunu ayrı bir pipeline'da hesaplıyor,
    buraya kopyalanmadı (yanlış sayı üretme riski — Hard Rule 3, financial precision). Grid bu 2
    kolonda IL satırları için **boş hücre** gösterir, mevcut "config'de olup veride olmayan key"
    deseniyle aynı, veri kaybı değil.
- **`EligibleTransactionsHandler`** — `request.Product`'a göre dispatch:
  `"MMTransactions"` → `ITransactionDataManager` (TxnMM), `"InterbankLoanTransactions"` →
  `ITransactionLoanDataManager` (TxnLoan). Bilinmeyen/boş `Product` → `PRODUCT_UNKNOWN` hatası,
  **hiçbir tabloya sessizce düşmez**. `ManualRediscountItem.ProductSourceType` artık gerçek kaynağı
  yansıtıyor (`"MoneyMarket"` / `"InterbankLoan"`) — önceden hep sabit `"MoneyMarket"` yazıyordu.

### 3. WebUI

- `TreasuryRediscountController.cs` doc yorumu güncellendi (IL artık "hazır" ✅, fiş kesme hâlâ ⬜).
- `treasury.json`'a **`InterbankLoanTransactions`** product bloğu eklendi — MM ile **birebir aynı**
  SubProduct/RevaluationType/kolon listesi (kullanıcı onayı: "MM'deki gibi aynı ürünler gelsin").
  Artık IL seçilince "hazır değil" placeholder'ı **kalkıyor**, gerçek `TxnLoan` sorgusu çalışıyor.

## Test durumu

- `dotnet build Code/NetTrex.MM.sln` → **0 error**.
- `NetTrex.MM.Api.Services.Tests.exe -namespace "*ManualRediscount*"` → **82 test, 0 hata**
  (80 → 82: 2 yeni test — `Handle_WhenProductUnknown_ShouldFailAndNeverQueryEitherDataManager`,
  `Handle_WhenProductIsInterbankLoan_ShouldQueryLoanDataManagerNotMm`. İkincisi tam olarak "yanlış
  tabloya düşme" riskini kilitliyor — Loan seçilince Loan DataManager'ının çağrıldığını, MM'in
  **hiç çağrılmadığını** doğruluyor).
- `NetTrex.MM.Data.Tests.exe` → 3 test, 0 hata (ilgisiz, regresyon yok).
- `dotnet build Trex.WebUI.csproj` → sonucu bir sonraki bildirimde teyit edilecek.
- ⚠️ `TransactionLoanDataManager.GetRediscountEligibleTransactionsAsync`'in kendisi için **DataManager
  seviyesinde test yazılmadı** — MM'in aynı metodu da (LINQ-to-SQL, EF sorgusu) hiç test edilmemiş,
  bilinen bir boşluk (bu proje genelinde DataManager query metodları unit test kapsamı dışında,
  gerçek DB'ye ihtiyaç duyuyor). Bilerek atlanıyor, sessizce geçmiyorum.

## Açık kalan (fiş kesme — yazma tarafı, henüz yazılmadı)

`ExecutionsHandler` (`Generate`/`Regenerate`) hâlâ yalnız MM'in `IRevaluationAccountingService`'ini
kullanıyor. IL için `Product="InterbankLoanTransactions"` ile Execute çağrılırsa şu an **ne olacağı
test edilmedi/yazılmadı** — muhtemelen MM'in servisini TxnLoan transactionId'siyle çağırıp hataya
düşer (transactionId TxnMM'de bulunamaz). Bu, **gerçek muhasebe fişi kesen kod** olduğu için ayrı bir
onay turu gerektiriyor — bu turda dokunulmadı.
