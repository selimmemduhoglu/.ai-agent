# 06 — V2 Revize Analizi (2026-11-02)

**Kaynaklar** (`Treasury Collateral Management/`):
- `Collateral Faz 1 - Ekranlar - Business ve Fonksiyonel Analiz.docx` (TRS-COL-FA-001 v0.2, İnci Korkmaz, 02.11.2026)
- `Analysis Documents/Treasy_Collateral_Veri_Modeli.xlsx` (v0.1) — **tablo/kolon/tip için tek kaynak**
- `Analysis Documents/Demo/Collateral_Demo.html` — ekran yerleşimi, varsayılanlar, validasyon ve mesaj metinleri
- `Analysis Documents/CollateralManagementDDL.sql` — **ESKİ** (CollateralAgreement adları); Excel bunun yerini aldı, kullanılmaz

## 1. Tablo karşılaştırması (mevcut → v2)

| Mevcut (v1) | v2 (Excel) | Değişim |
|---|---|---|
| `Annex` | `CollateralAnnex` | Ad değişti. `AnnexCode/AnnexName` → `Code(100)/Name(250)`, `CustomerId` → `CounterpartyId`, `IsEnabled` → `Status int (1 Aktif / 2 Pasif)`, `Direction` string → **int** (1 Both / 2 PostOnly / 3 ReceiveOnly). **Silinen:** `RevisionNo`, `DisputeToleranceCurrencyCode`. Akış kolonları **tam FlowEntity** (PreviousState*, FlowId, LastActionId, PreviousActionId) |
| `AnnexProductScope` | `CollateralAnnexProduct` | `AnnexId` → `CollateralAnnexId`, `MarginType` string → `MarginTypeId int FK MarginType` |
| `AnnexMarginRule` | `CollateralAnnexRule` | `Party` → `PartyType int`, `MtaAmount` → `MinimumTransferAmount`, `RoundingMethod` → `RoundingMethodType int`. Tekil: (CollateralAnnexId, PartyType) |
| `CollateralDefinition` + `CollateralCashTerms` + `CollateralEligibleCurrency` | `CollateralDefinition` (düz, 34 kolon) | Alt tablolar **kalkıyor**. `CashEligibilityCurrencies nvarchar(1000)` `;` ile. `Cash*` önekli faiz kolonları, `IsInterestCalculated`, `InterestSettlementType int`, `CashPaymentFrequencyId` (InterestMethodFrequency yerine), `CashBusinessDayRuleType int`, `CollateralTypeId FK`. `CollateralCode/Name` → `Code(50)/Name`. Tam FlowEntity |
| `CollateralPosition` | — | **Kalkıyor.** Bakiye = onaylı detail'lerin valör sırasıyla toplamı |
| `TxnTransaction` + `TxnTransactionCash` | `TxnTransaction` (20 kolon, yalnız başlık) | Hareket ve ödeme alanları detail'e taşınıyor. `DefinitionId` → `CollateralDefinitionId`, `AnnexId` → `CollateralAnnexId`, `CustomerId` → `CounterpartyId`, `InputDate` → `InputDateTime` |
| `TxnTransactionDetail` | `TxnTransactionDetail` (56 kolon) | Her satır bir **hareket**: `TransactionId`, `TransactionType int` (1 Increase / 2 Decrease), `MarginTypeId`, `AmountTypeId`, `CurrencyCode`, `Amount`, `FXRate` null, `TransactionAmount`, `CurrentBalance`, `ValuationCurrencyCode`, `IsSettlementRequired` + bütün ödeme alanları + tam FlowEntity |
| — | `CollateralDailyCalculation` | Yeni (gün sonu faiz, doküman kapsamı dışı) → **yalnız tablo** |
| `InterestMethodFrequency` | `PaymentFrequency` (+Month, Period) | Yeniden adlandırma + kolon |
| `CollateralMarginType` (lookup) | `MarginType` (Id, Code, Name, Description, IsEnabled) | Gerçek parametre tablosu |
| — | `CollateralType`, `CollateralAmountType` | Yeni parametre tabloları |
| `RateType`, `FloatingRateType`, `InterestMethod` | aynı + `Description/IsEnabled`, FloatingRateType'a `CurrencyCode` | Kolon uyumu |
| `CollateralDirection`, `CollateralMarginParty`, `CollateralRoundingMethod`, `CollateralBusinessDayRule` (lookup) | Excel'de **enum int** | Karar bekliyor (Soru 4) |

## 2. Ekran / iş mantığı farkları

| Konu | v1 (mevcut) | v2 |
|---|---|---|
| Annex formu | 2 tab | **Tek sayfa, 3 bölüm**: General Information → Product Information → Margin Terms. Satır ekleme alt pencereyle (Product Scope [New/Edit], Add/Edit Margin Rule) |
| Annex kilitleri | — | Definition'da kullanılıyorsa Code, Counterparty, Base Currency salt okunur; silinemez |
| Margin Rule | serbest | Taraf başına en fazla 1 kural; ikisi tanımlıysa Add Rule pasif. Currency = Base Currency (kilitli, değişince bütün kurallar güncellenir) |
| Kayıt kuralı | — | En az 1 Included ürün + en az 1 margin rule |
| Definition formu | 3 kart | General Information (Eligible Currencies burada), Cash Eligibility, Cash Interest Terms (Interest Calculated anahtarı; kapalıyken faiz alanları pasif ve boş) |
| Fixed / Floating | iki ayrı alan | Aynı hücre: Rate Type'a göre biri görünür. Fixed → Simple Linear, Floating → Daily Compounded. Floating Index, Valuation Currency'ye göre süzülür |
| Date Basis | boş | Varsayılan = Valuation Currency'nin `Currency.BasisCode` değeri |
| Annex → Definition | Counterparty / Valid / Direction / ValCcy kilitli | **Valid To kilitli değil** (varsayılan gelir, değiştirilebilir); Eligible Currencies boşsa Base Currency önerilir |
| Transaction | Header'da hareket | **Kalıcı pozisyon**: tanım + portföy başına tek transaction. New = header + ilk hareket; Edit = yeni hareket ekle. Hareket değiştirilemez ve silinemez |
| Transaction formu | tek ekran | 2 tab: **Transaction** (General, Detail Information, Limit status, Payment Instructions akordeon) + **Transaction Detail** (hareket gridi + **Movement Preview**) |
| Transaction Type | Increase/Decrease/… | Increase / Decrease. Amount Type: Collateral / Nema (Nema → Margin Type VM ise Other) |
| FX Rate | elle | Currency = ValCcy ise boş ve kilitli; değilse `FxRateChartId` tablosundan Trade Date kuru (çapraz TRY), değiştirilebilir |
| Bakiye | CollateralPosition | Yalnız InputVerified hareketler, Value Date + giriş zamanı sırasıyla. Sunucu yeniden hesaplar |
| Grid | — | Txn listesi: Current Balance (yeşil/kırmızı), Pending, Last Movement / Amount Type / Amount / Ccy / Trade Date |

## 3. Yapılmayacaklar (doküman kapsam dışı)
Developer Mode (A-29: canlıda görünmez; bizim (i) yardım ikonları kalır) · gün sonu faiz hesabı (yalnız tablo) ·
Fimple ödeme iletimi · Limit verisi (bileşen bilgi amaçlı, rakamlar `-`).

## 4. Varsayılan seçilen açık maddeler (doküman "karar gelmezse" sütunu)
A-03 onay bekleyen harekette öngörülen bakiye yazılır · A-07 oran yüzde saklanır · A-08 Decrease için bakiye kısıtı yok ·
A-25 Trade Date = **logical date** · A-26 kur yoksa en yakın önceki tarihin kuru, o da yoksa boş · A-27 işlemi olan tanımda
Valuation Currency kilitli · A-28 Logical Reference önek `CTX` · A-36 en az 1 ürün + 1 kural zorunlu · A-37 yalnız 3 alan kilitli · A-38 Definition Valid To, Annex Valid To'yu aşabilir.

## 5. DB v2 script seti
`Treasy.ColManagement/.ai-agent/outputs/2026-11-02-ColManagement-Kurulum-v2/` — v1 setinin (2026-10-14 + 10-21 + 10-22 ekleri)
**baştan yazılmış tek parça** hali; boş DB'ye uygulanır. Referans veri kopyası (14 tablo) ve lookup/parametre seed'leri dahil.
