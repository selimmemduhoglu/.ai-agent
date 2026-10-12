# progress-19 — SubProduct listeleri `Trex.Web.Business.Models.Enums.ProductType` ile birebir hizalandı (statik, kullanıcı kararı)

**Tarih:** 2026-08-17

## Neden

Kullanıcı önceki turdaki "MM/InterbankLoan SubProduct'ı dinamik çekelim" fikrinden **vazgeçti**:
*"MM ürünlerini dinamik almana gerek yok şimdilik statik alalım ilerde dinamik hale getiririz benim
isteğim ve onayımla."* İstek: WebUI'deki `Trex.Web.Business.Models.Enums.ProductType` enum'ındaki
ürünleri **aynen** kullan.

## Yapılan

`Trex.Web.Business.Models.Enums.ProductType` (`Code/Web/Common/Trex.Web.Business.Models/Enums/ProductType.cs`)
okundu — FX/MM/FI/DerivSWP/OptFX gruplu, `Display(Order=...)` ile sıralı tek enum. Bundan:

1. **`treasury.json` MM subProducts** → `MoneyMarket(1)`, `TermDeposit(6)`, `Murabaha(5)`, `Wakale(4)`,
   `PassGil(7)`, `Syndication(9)`, `Securitization(10)`, `PostFinancing(11)` — enum'daki `Order`
   sırasıyla (MoneyMarket zaten ilk sırada kaldı, gerçek test verisiyle örtüşüyor — bkz. progress-18).
   `InterbankLoan(2)` ve `IssueBond(3)` **kasıtlı dışında**: ilki artık ayrı Product
   (`InterbankLoanTransactions`, henüz backend'i yok), ikincisi zaten sorgudan filtreleniyor
   (`TxnMmProductTypeId != ISSUE`).
2. **`treasury.json` FX subProducts** düzeltildi: önceki turda kullanıcının sözlü verdiği
   "Swap/Future" yerine enum'daki gerçek değerler kondu — `Spot(69)`, `Forward(70)`,
   `SwapNear(1068, "Swap (Near)")`, `SwapFar(1069, "Swap (Far)")`. "Future" enum'da yok, kaldırıldı.
3. **`treasury.json` DerivSwp/OptFX** — değer/etiket enum'la birebir: `IRS(14)`, `CCS(15)`,
   `OptionsFx(1070, "Options Fx")`.
4. **MM backend — `EligibleTransactionsHandler.ResolveSubProductTypeId`** genişletildi: `PASSGIL=>7`,
   `SYNDICATION=>9`, `SECURITIZATION=>10`, `POSTFINANCING=>11` eklendi (bu 4 değerin
   `ProductAccountingCodeType`'ta adlandırılmış karşılığı yok — MM'in kendi enum'u yalnız 6 değer
   taşıyor, WebUI'nin `ProductType`'ından ham sayı olarak alındı). **Bu genişletme yapılmasaydı**
   kullanıcı "Pass/Gil" gibi bir SubProduct seçtiğinde switch `_ => null`'a düşer, filtre hiç
   uygulanmaz, ekran sessizce **TÜM MM alt ürünlerini** gösterirdi (yanlış/yanıltıcı sonuç) — sadece
   config'e eklemek yetmiyordu, backend'in de bu değerleri tanıması gerekiyordu.
5. **`ResolveSubProductName`** (satır bazında SubProduct/Product kolonunun görünen adı) aynı 4 değer
   için isim eşlemesi aldı — yoksa grid'de "7"/"9"/"10"/"11" gibi çıplak sayı görünürdü.
6. **Test:** `EligibleTransactionsHandlerTests.cs`'teki `Handle_WhenSubProductGiven_...` teorisine
   `MoneyMarket`/`TermDeposit`/`PassGil`/`Syndication`/`Securitization`/`PostFinancing` `InlineData`'ları
   eklendi (önceden yalnız Murabaha/Wakala test ediliyordu).

## Test durumu

`dotnet build Code/NetTrex.MM.sln` arka planda çalıştırıldı — sonucu bu dosyaya işlenmedi, sonraki
turda teyit edilecek. Test exe'si (`NetTrex.MM.Api.Services.Tests.exe -namespace "*ManualRediscount*"`)
henüz **koşulmadı** — build bitince koşulacak.

## Açık kalan

- `InterbankLoanTransactions` hâlâ config'siz (progress-18'deki güvenlik gerekçesiyle — backend
  `Product`'a göre `TxnMM`/`TxnLoan` dispatch'i yapmadan config eklenmeyecek).
- FX/DerivSwp/OptFX'in gerçek backend'i hâlâ yok — bu tur yalnızca **isimlendirme** düzeltildi.
