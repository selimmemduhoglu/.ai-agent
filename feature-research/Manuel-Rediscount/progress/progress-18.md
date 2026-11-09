# progress-18 — Treasury ürün ayrımı (MM/InterbankLoan/FX/DerivSwp/OptFX) + gerçek "0 kayıt" kök sebebi bulundu

**Tarih:** 2026-08-17

## Neden

Kullanıcı üç şey istedi: (1) `DailyFlowV2/Index`'teki Product alanının veri kaynağını incele — biz de
öyle mi yapmalıyız bak; (2) Treasury'de `MM/Loan Transactions` tek kalemini **MM** ve **InterbankLoan**
diye ikiye ayır (ikisi de `NetTrex.MM` projesinde ama `TxnMM`/`TxnLoan` diye ayrı tablolar); (3) FX/
DerivSwp/OptFX zaten dropdown'da var, onlara dokunma — modül sahipleri kendi backend'lerini yazacak.
Ayrıca "sen test etmek için DB'ye bağlan, `TransactionDataManager`'daki filtreye hangi tarih uyuyor bul"
dedi.

## Bulgu 1 — DailyFlowV2 Product alanı da hardcoded (bizim yaklaşımımızı doğruluyor)

Agent araştırması: `DailyFlowV2Controller.cs:70-77`'de modül→ürün eşlemesi **statik bir C# dictionary**
(`ModuleConstants.MM => [MoneyMarket, TermDeposit, Vakale, Murabaha, PassGil, InterbankLoan, ...]`
gibi). DB/API'den gelmiyor. Tek dinamik kısım: `General:AvailableModules` FrameworkParameter'ı hangi
modül anahtarlarının döngüye gireceğini filtreliyor (env bazlı açma/kapama). **Bizim Treasury
controller'ımız zaten aynı felsefeyi kullanıyor** (küçük hardcoded liste + config dosyası) — DailyFlowV2
bunun ötesinde bir "canlı katalog" değil, kopyalanacak yeni bir şey yok. Önemli detay: DailyFlowV2'nin
kendi listesinde bile **`InterbankLoan`, `MM` modülünün ALTINDA ayrı bir ürün** olarak duruyor — tam
istenen ayrımın platformda zaten emsali var.

## Bulgu 2 — 🔴 asıl "Total 0 records" sebebi: `treasury.json`'da `MoneyMarket` subproduct'ı hiç yoktu

DB'ye bağlanıp (`NetTrexMM_134`, en güncel varyant — 5 aday arasından `MAX(StateDate)` ile seçildi)
`EligibleTransactionsHandler`/`TransactionDataManager.GetRediscountEligibleTransactionsAsync`'teki
filtreyi (Verified state · `MaturityDate > date` · `ValueDate <= date` · Opening kaydı var ·
faiz dönemi tarihi kapsıyor · ISSUE hariç) SQL'e çevirip 2026-08-01 → 2026-09-05 arası tarandı:

- **Bugün (2026-08-17) dahil pek çok tarihte GERÇEKTEN eligible veri var** (Id 553395,
  `TMMBRW2608140004`, ValueDate 2026-08-15, MaturityDate 2026-09-02).
- Ama bu satırın `TxnMmProductTypeId = 1` → **MoneyMarket**. `treasury.json`'daki MM `subProducts`
  listesi yalnızca `Murabaha`/`Wakala` içeriyordu — **`MoneyMarket` hiç seçenek olarak yoktu.**
  SubProduct zorunlu ve ilk seçenek otomatik seçildiği için (`Murabaha`), DB'de gerçek veri olsa bile
  ekran **hiçbir zaman** eşleşemiyordu — hangi tarih seçilirse seçilsin "Total 0 records".
  Backend (`ResolveSubProductTypeId`) `"MONEYMARKET"`/`"TERMDEPOSIT"`'i **zaten doğru eşliyordu** —
  eksik olan tek şey config'teki 2 seçenekti.

**Fix (uygulandı):** `treasury.json`'a `MoneyMarket` + `TermDeposit` eklendi, ilk sırada
(otomatik seçilen ilk değer artık gerçek veriyle eşleşiyor). Kod değişikliği gerekmedi.

## Bulgu 3 — InterbankLoan'ı gerçekten ayırmak için ne gerekiyor (araştırıldı, henüz YAZILMADI)

| Soru | Cevap (kod+DB'den doğrulandı) |
|---|---|
| `TxnLoanEntity`'nin MM'deki `AccEntryMain`/durum türetme deseni var mı? | ✅ Var — `TxnLoanEntity.AccountingMainEntries` (`ICollection<AccEntryMainEntity>`), MM ile birebir aynı şekil |
| Aynı `AccEntryMain` tablosunda MM/Loan karışır mı (yanlış satır çekme riski)? | Hayır — `AccEntryMain.ProductCode` ayırıyor (`MM` / `TWR` / `Loan`, DB'den doğrulandı). `TxnLoan.Id` aralığı (1.201.069-1.201.125) zaten `TxnMM.Id`'den (≤553.395) tamamen ayrık ama `ProductCode` filtresi yine de doğru/güvenli yol |
| Alt ürün (SubProduct) kaynağı MM'deki gibi sabit enum mu? | **Hayır** — `TxnLoanEntity.ProductDefinition` (DB tablosu `PrdProductDefinition`, dinamik). MM'in `ProductAccountingCodeType` enum'ından **farklı bir mekanizma** |
| Faiz dönemi filtresi (`Details.PeriodStartDate/EndDate`) Loan'da aynı mı? | **Hayır** — Loan `CashFlows` kullanıyor (`TxnCashFlowEntity.StartDate/EndDate` + `FlowTypeId`), MM'in `Details.IsPrincipalAmount/PeriodStartDate/PeriodEndDate`'inden **alan adı ve semantik olarak farklı** |
| Fiş kesme (Generate/Regenerate) MM'in kullandığı `IRevaluationAccountingService`'i Loan da kullanıyor mu? | **Hayır** — Loan'ın kendi **ayrı** arayüzü var: `ILoanRevaluationAccountingService` (`LoanRevaluationAccountingService.cs:13`). `ExecutionsHandler` şu an yalnız `IRevaluationAccountingService`'i constructor'a alıyor — Loan için **yeni bir dispatch katmanı** (ProductSourceType'a göre hangi servisin çağrılacağını seçen) yazılmadan mevcut handler Loan'ı çalıştıramaz |

**Sonuç:** Okuma tarafı (eligible-transactions) için MM'deki deseni **aynı iskeletle ama farklı alan
adlarıyla** yazmak mümkün — riskli değil, salt okunur. Yazma tarafı (Generate/Regenerate → gerçek
Fimple fişi) için ise **yeni bir Strateji dispatch katmanı** gerekiyor (ADR-001'in persister deseniyle
aynı ruhta: `IManualRediscountAccountingDispatcher` gibi, `ProductSourceType`'a göre `IRevaluationAccountingService`
veya `ILoanRevaluationAccountingService`'i seçen) — bu, muhasebe fişi üreten kod olduğu için
(Hard Rule 2 + Hard Rule 3) plan onayı almadan yazılmadı.

## Yapılan (bu turda, kod)

1. `NetTrex.Web.UI` — `TreasuryRediscountController.GetProducts()`: `MMLoanTransactions` (tek kalem)
   → `MMTransactions` + `InterbankLoanTransactions` (ikisi de `ModuleCode=MM`, aynı Refit client'a
   gider — ayrım `Product` string'iyle, ADR-001 ruhuyla backend'de çözülecek). FX/DerivSwp/OptFX
   aynen kaldı.
2. `treasury.json`: `"product"` anahtarı `MMLoanTransactions` → `MMTransactions` (isim artık MM'e özel,
   yanıltıcı "Loan" ifadesi kalktı); `subProducts`'a `MoneyMarket` + `TermDeposit` eklendi (asıl bug fix).
3. `InterbankLoanTransactions` için **henüz config satırı yok** — FX/DerivSwp/OptFX ile aynı muamele,
   seçilince "Bu modül için ekran henüz hazır değil" placeholder'ı çıkacak (progress-16'daki guard
   sayesinde), kırmızı hata yok.

Build: `dotnet build Trex.WebUI.csproj` arka planda çalıştırıldı, sonucu bir sonraki turda teyit edilecek.

## Sıradaki adım — onay bekliyor

InterbankLoan'ın **gerçek** okuma+yazma desteği (yukarıdaki Bulgu 3 tablosu). Önerim:
1. Okuma tarafı: `ITransactionLoanDataManager.GetRediscountEligibleTransactionsAsync` (MM'deki
   metodun CashFlow/ProductDefinition'a uyarlanmış hâli) + `EligibleTransactionsHandler`'a
   `ProductSourceType` bazlı dispatch.
2. Yazma tarafı: yeni bir dispatch arayüzü ile `ExecutionsHandler`'ın hem `IRevaluationAccountingService`
   (MM) hem `ILoanRevaluationAccountingService` (Loan) arasında `ProductSourceType`'a göre seçim yapması.
3. SubProduct listesi: `ProductDefinition` tablosundan **gerçek** InterbankLoan ürünlerini çekip
   `treasury.json`'a sabit liste olarak mı yazayım (M-02 ile tutarlı, config-driven kalır) yoksa
   iş biriminden ürün listesini mi isteyeyim — kullanıcı onayı bekliyor.

Kullanıcı onaylarsa devam edilecek — muhasebe fişi üreten kod olduğu için (gerçek para etkisi)
plan+onay adımı atlanmadı.

---

## Ek — kullanıcı cevabı sonrası (aynı tur)

**Soru:** InterbankLoan SubProduct kaynağı ne olsun (sabit config mi, canlı sorgu mu)?

**Cevap (kullanıcı, 2026-08-17):** MM ve InterbankLoan'ın SubProduct'ları **şu an zaten aynı** ve
**dinamik yönetilebilir** — ikisi de `TxnMmProductTypeId` kolonu üzerinden (hem `TxnMM` hem `TxnLoan`
tablosunda bu kolon var) belirleniyor, kullanıcı bunu zaten "MmTransaction ve InterbankLoan ekranlarından"
bu şekilde çekiyormuş. **FX/DerivSwp/OptFX için ise statik olmak zorunda** (dinamik yönetilmiyor) —
isimler verildi: FX = Spot/Forward/Swap/Future, DerivSwp = Irs/Ccs, OptFX = FxOption (DailyFlowV2
taksonomisiyle hizalı, kullanıcı teyit etti).

**Yapılan:**
- `treasury.json`'a **FXTransactions/DerivSwpTransactions/OptFXTransactions** için yeni product
  blokları eklendi — verilen SubProduct isimleriyle. `revaluationTypes`/`columns` boş bırakıldı
  (backend/kolon şeması hâlâ modül sahibinde, İ-71 — isim uydurmadım).
- 🔴 **`InterbankLoanTransactions` için BİLİNÇLİ OLARAK config bloğu EKLENMEDİ.** Sebep: FX/DerivSwp/
  OptFX'in kendi ayrı `ModuleCode`'u var, resolver adaptör bulamayınca **temiz bir hata** veriyor
  ("modül ucu tanımlı değil"). InterbankLoan'ın `ModuleCode`'u ise **MM ile aynı** (`"MM"`) — eğer
  şimdi config eklersem SubProduct seçilebilir hale gelir, `IsFirstLoad=false` olur, istek GERÇEKTEN
  `EligibleTransactionsHandler`'a gider ve bu handler `Product`'a hiç bakmadan (yalnız `ModuleCode`
  kontrol ediyor) **her zaman `TxnMM`'i sorgular** — yani "Interbank Loan Transactions" seçilince
  sessizce **yanlış tabloyu (TxnMM) InterbankLoan diye gösterirdi**. Bu, "hazır değil" placeholder'ından
  çok daha kötü bir hata (yanlış veri, hata mesajı yok). Handler `ProductSourceType`'a göre dispatch
  etmeden bu config **eklenmeyecek**.

**Sıradaki gerçek iş (henüz yazılmadı):**
1. MM/InterbankLoan SubProduct listesini `TxnMmProductTypeId` üzerinden **dinamik** çekecek mekanizmayı
   bul/yaz — kullanıcı "zaten buradan çekiyordum" dediği için muhtemelen mevcut bir select/dropdown
   ucu var, önce onu bulmak gerekiyor (MM API'de aranacak).
2. `EligibleTransactionsHandler`'a `Product` değerine göre `ProductSourceType` (MoneyMarket/InterbankLoan)
   dispatch'i ekle → `TxnMM` mi `TxnLoan` mı sorgulanacağını buradan belirle.
3. `ITransactionLoanDataManager`'a MM'deki `GetRediscountEligibleTransactionsAsync`'in `TxnLoan`/
   `CashFlow` uyarlanmış hâlini yaz.
4. `ExecutionsHandler`'a `ILoanRevaluationAccountingService` dispatch'i ekle (fiş kesme tarafı).

Bu 4 madde hâlâ **onay bekliyor** — muhasebe fişi üreten kod + gerçek DB sorgusu, tek turda commit
edilecek küçüklükte değil.
