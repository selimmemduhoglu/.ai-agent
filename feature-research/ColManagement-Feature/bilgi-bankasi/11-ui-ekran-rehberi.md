# 11 — UI Ekran Rehberi (PO toplantısı #3, 2026-10-12/13)

> **Kaynak:** [`Dinamik-Ekran/index.html`](../Dinamik-Ekran/index.html) (PO'nun kendi hazırladığı, alan-seviyesinde
> çalışan prototip — `data-key`/`data-entry`/`data-control`/`data-source`/`data-required` her alanda işaretli) +
> [`Ses-Kayıtları-transcript/Collateral-toplantı-ses-kaydı-3.docx`](../Ses-Kayıtları-transcript/Collateral-toplantı-ses-kaydı-3.docx)
> (ASR transcript, bozuk yerleri var — iş kararlarında bağlayıcı, K-16) + Excel v5 `00_UML_Diyagram` (revize).
>
> **Amaç:** UI fazına (Faz 10-11) girerken PO'nun anlattıklarını **tekrar anlatmasına gerek kalmasın** diye
> alan listesi + iş kuralları tek dosyada. Backend entity/config yazarken de bu dosya referans alındı.
>
> 🔴 **3 ekran var, TAB DEĞİL — ayrı ekranlar:** Collateral Annex, Collateral Definition, Collateral Transaction.
> Prototipte üstte sekme gibi görünüyorlar ama PO açıkça belirtti: *"bunlar aslında 3 ayrı ekran olacak bunlar
> 1 ekranın tab'i olmayacak"*.

---

## 0. Geçerlilik notu

Prototipteki `Status` alanı `Draft/Active/Inactive` 3 seçenekli gösteriyor ama PO transcript'te **Draft'ı
reddetti**: *"Bu draft gereksiz bence. Active inactive gibi mi kalacak burası? Yapay zeka yapmış çünkü
draftı belli ki."* → **Status = Active / Inactive, 2 seçenek.** Zaten ev konvansiyonu `IsEnabled bit`
(K-14) — bu, prototipteki 3. seçeneğin düşmesini DB tarafında da doğruluyor.

Security (menkul kıymet) tarafı **Faz 1 kapsamı dışı** (K-17). Prototipte Security panelleri var ama PO:
*"Security'i kaldırıyor muyum? Arkada dursun, önde cash olsun sadece şimdilik... Security duracak ama
disable olacak. Seçtirmeyeceğim."* → UI'da Security seçeneği **görünür ama disabled**, seçilemez.

---

## 1. Ekran 1 — Collateral Annex

Sözleşmesel çerçeve (ISDA/CSA benzeri). 4 panel + 1 alt tablo (margin rule, seçili ürün satırına bağlı).

### 1.1 Identity and Legal Framework

| Alan | Kolon | Giriş | Kontrol | Kaynak | Zorunlu |
|---|---|---|---|---|---|
| Annex Code | `AnnexCode` | Yazılır | Text | User | **Evet** |
| Annex Name | `AnnexName` | Yazılır | Text | User | **Evet** |
| Counterparty | `CustomerId` | Listeden seçilir | Select | Counterparty master (`CusCustomer`) | **Evet** |
| Status | `IsEnabled` | Listeden seçilir | Select | Code list | **Evet** |
| Master Agreement | `MasterAgreementText` | Yazılır (serbest metin) | Text | User free text | **Evet** |
| Collateral Document | `CollateralDocumentText` | Yazılır (serbest metin) | Text | User free text | **Evet** |

🔑 PO: *"Annex kodun... String data olacak. Yani ben oraya sayıda girebileceğim, harf de girebileceğim,
çizgiler de girebileceğim."* → `nvarchar`, format validasyonu yok. `AnnexCode` **UK** (tekil), değiştirilemez
(transcript: *"benzersiz tanımlar işlem görmüş kod değiştirilemez"*).
`MasterAgreementText`/`CollateralDocumentText` — **ikisi de elle giriliyor, referans tablo yok**
(*"O da elle giriliyor zaten mecburi. Collateral document yine elle giriliyor."*).

### 1.2 Validity, Call and Dispute Control

| Alan | Kolon | Giriş | Kontrol | Kaynak | Zorunlu |
|---|---|---|---|---|---|
| Base Currency | `BaseCurrencyCode` | Listeden seçilir | Select | Currency master | **Evet** |
| Direction | `Direction` | Listeden seçilir | Select | Code list (sabit) | **Evet** |
| Valid From | `ValidFrom` | Tarih seçilir | Date | User | **Evet** |
| Valid To | `ValidTo` | Tarih seçilir | Date | User | Hayır |
| Dispute Tolerance | `DisputeToleranceAmount` + `DisputeToleranceCurrencyCode` | Yazılır | Decimal + Currency | User | **Evet** |

🔑 **Direction = sabit 3 değerli enum** (`Both` / `Post Only` / `Receive Only`), **`DefTxnType` gibi dinamik
bir yön tablosuna BAĞLANMAZ** — PO açıkça kapattı: *"Şeyden direction'ın ismi değişebilir mi müşteriden
müşteriye?... Hayır biz onu increase ve decrease diyeceğiz. Yani teminat artma veya azalma veya ikisi de."*
Yani Annex.Direction = *bu sözleşme ile teminat verilebilir mi / alınabilir mi / ikisi de mi* — Transaction
ekranındaki `Increase`/`Decrease`'den **ayrı** bir kavram (Annex seviyesinde izin, Transaction seviyesinde
fiili hareket yönü).
⚠️ **Bilinen UI hatası (prototipte, PO fark etti, düzeltilecek):** Dispute Tolerance'ın para birimi Base
Currency'den **bağımsız** seçilebiliyor, varsayılan yanlış geliyordu (TL seçiliyken EUR görünüyordu) —
*"AI yanlış yazmış onu... düzeltirim onları giderken."* UI fazında Dispute Tolerance Currency, Base
Currency'yi **takip etmeli** (otomatik senkron), bağımsız dropdown olmamalı.

### 1.3 Product Scope and Margin Coverage — `AnnexProductScope`

Grid + "Add Product" modal. Annex'e FK.

| Alan | Kolon | Giriş | Kaynak |
|---|---|---|---|
| Product | `ProductCode` | Listeden seçilir | **Karma katalog — bkz. §6** |
| Sub Product | `SubProductCode` | Listeden seçilir | Product'a bağlı alt liste |
| Margin Type | `MarginType` | Listeden seçilir | Code list (`VM`/`IM`/`IA`/`Other`) |
| Included | `IsIncluded` | Listeden seçilir | Boolean code list |

### 1.4 Party Margin Terms — `AnnexMarginRule`

Grid + "Add Rule" modal. **Seçili `AnnexProductScope` satırına bağlı** (ProductScope seçilmeden Add Rule
basılamaz — *"Add Rule always uses the selected Product Scope context"*). **AYRI TABLO, Annex'e 8 kolon
olarak gömülmedi** — A-24 bu toplantıda kapandı:

> PO: *"Burada iki kural varsa diyor böyle bir tablo yapalım mı diyor. Annex'in içine koyalım diyor...
> Sadece iki kural mı tanımlanabiliyor o margin rule'larda?"* → cevap: max 2 (`Own`/`Counterparty`).
> Geliştirici (Selim) kararı: *"Ben ayrı tabloya koyarım yani. Aynı tabloya koymam ben kendim."*
> Gerekçe (aynı konuşmada): *"Böyle olması böyle olunca kontrolü daha kolay olur ayrı tabloda. Aynı
> tabloda olunca burada gösterilmesi de göstermemek için ekstra bir şey yapman lazım."*

| Alan | Kolon | Giriş | Zorunlu |
|---|---|---|---|
| Party | `Party` | Listeden seçilir (`Own`/`Counterparty`) | **Evet** |
| Threshold | `ThresholdAmount` | Yazılır (tutar+para birimi) | **Evet** |
| MTA | `MtaAmount` | Yazılır | **Evet** |
| Rounding Amount | `RoundingAmount` | Yazılır | **Evet** |
| Rounding Method | `RoundingMethod` | Listeden seçilir (`Nearest`/`Up`/`Down`) | **Evet** |
| Currency | `CurrencyCode` | Listeden seçilir | **Evet** |

**UK kural:** `(ProductScopeId, Party, CurrencyCode)` — FK **`AnnexProductScope.Id`'ye**, Annex'e değil
(Excel v5 per-tablo sheet'i, UML özet diyagramından daha güncel/detaylı: *"Pencereye bağlam olarak
taşınır, kullanıcıdan istenmez"*). Satır başına **en çok 2** (Own + Counterparty), transcript PO'nun
kendi tanımıyla: *"Bu benim karşı tarafa tanıdığım istisna. Karşı tarafın bana tanıdığı istisnaları
tanımıyorum ben burada."*

🔑 **Threshold anlamı** (teknik olmayan katılımcıya PO'nun açıklaması, iş mantığı için değerli):
*"taraf arasında fark o tutarı aşarsa uyuşmazlık sürecini tetikler... Minimum gibi olarak düşün"* — yani
Threshold = margin call tetiklenmeden önce göz ardı edilebilecek fark tutarı; MTA = o tutarın altındaki
transferlerin yapılmaması (EFT masrafına değmeyen küçük tutarları engellemek); Rounding = küsuratsız
yuvarlak tutar gönderme kuralı.

---

## 2. Ekran 2 — Collateral Definition

Annex seçilirse bağımlı alanlar **otomatik dolar ve readonly** olur; Annex seçilmezse (*"No Annex /
Standalone"*) kullanıcı hepsini kendi girer. `CollateralType` (`Cash`/`Security`) 2-4 numaralı panelleri
**komple değiştirir** — ikisi birden dolmaz (zaten K-07 gereği CHECK yazılmıyor, validasyon servis katmanında).

### 2.1 Identity and Contract Context

| Alan | Kolon | Giriş | Kaynak | Zorunlu |
|---|---|---|---|---|
| Collateral Code | `CollateralCode` | Yazılır | User | **Evet** |
| Collateral Name | `CollateralName` | Yazılır | User | **Evet** |
| Annex | `AnnexId` | Listeden seçilir | Active Annex | Hayır |
| Counterparty | `CustomerId` | Annex varsa otomatik+readonly; yoksa seçilir | Annex / Counterparty master | **Evet** |
| Collateral Type | `CollateralType` | Listeden seçilir | Code list (`Cash`/`Security`) | **Evet** |
| Eligible Currencies *(Cash)* | `CollateralEligibleCurrency` (çoklu satır) | Çoklu seçilir | Currency master | **Evet** |
| Security Scope *(Security, devre dışı)* | — | Listeden seçilir | Code list (`Eligibility Rule`/`Specific ISIN`) | **Evet** |
| Status | `IsEnabled` | Listeden seçilir | Code list (Active/Inactive) | **Evet** |

🔑 **Eligible Currency'nin anlamı** (PO, teknik olmayan katılımcıya): *"Hangi işlem currency'lerle işlem
girebilirsin sadece... genelde marjin call'a Euro, dolar, GBP ve TL... bütün currency'yi burada
getireceğim mi? Hayır, getireceksin adam seçecek."* → `Currency` master'dan **TÜMÜ** listeye gelir, kullanıcı
multi-select ile **kendi alt kümesini** seçer; Transaction ekranındaki Currency dropdown'ı bu seçilmiş alt
kümeyle sınırlanır (K-08/A-21'den bağımsız, saf UI-filtre kuralı).

### 2.2 Cash Eligibility *(CollateralType=Cash)*

| Alan | Kolon | Giriş | Kaynak | Zorunlu |
|---|---|---|---|---|
| Eligibility Direction | `EligibilityDirection` | Annex varsa otomatik; yoksa seçilir | Annex / User | **Evet** |
| Valuation Currency | `ValuationCurrencyCode` | Annex varsa otomatik; yoksa seçilir | Annex / Currency master | **Evet** |
| Valid From | `ValidFrom` | Tarih seçilir | Annex / User | **Evet** |
| Valid To | `ValidTo` | Tarih seçilir | Annex / User | Hayır |

### 2.3 Cash Interest Terms *(opsiyonel, `CollateralCashTerms`)*

| Alan | Kolon | Giriş | Kaynak | Zorunlu |
|---|---|---|---|---|
| Rate Type | `RateType` | Listeden seçilir (`Floating`/`Fixed`/`Interest Free`) | Code list | Hayır |
| Reference Rate | `ReferenceRateCode` | Listeden seçilir | Rate index master | Koşullu (Floating ise) |
| Spread | `SpreadBps` | Yazılır (bps) | User | Koşullu (Floating) |
| Fixed Rate | `FixedRate` | Yazılır (%) | User | Koşullu (Fixed) |
| Compounding Method | `CompoundingMethod` | Listeden seçilir | Code list | Hayır |
| Day Count | `DayCount` | Listeden seçilir | Code list | Hayır |
| Payment Frequency | `PaymentFrequency` | Listeden seçilir | Code list | Hayır |
| Business Day Rule | `BusinessDayRule` | Listeden seçilir | Code list | Hayır |
| Negative Rate Allowed | `IsNegativeRateAllowed` | İşaretlenir (checkbox) | User | Hayır |

🔴 **Kaldırılan alan:** prototipte vardı, PO sildirdi — **"Cash Settlement and Account"** paneli (nakit
hesap transferi/bank-to-bank seçimi). Gerekçe: bu bilgi zaten Transaction ekranının "Near Payment
Instructions" bölümünde var, burada **tekrar** oluyordu: *"Bence şu cash settlement at account'u silsek
mi? Silelim... Cash interest teriminin altında payment extraction'ı mı koyuyorum? Evet, extraction
transaction ekranda olur."* → **`CollateralCashTerms`'te settlement/account kolonu YOK**, sadece faiz
şartları kalır (yukarıdaki tablo = Excel v5 UML'in güncel hâliyle birebir).

🔑 **Floating rate'in anlamı** (PO açıklaması): referans faiz her zaman **overnight** tenor —
*"bir yurda, bir yurda seçtiğimiz currency'lerin overnight rate'leri gelmesi gerekiyor... sonuçta para en
sonunda işlem bittikten sonra bana geri gelecek ama orada ben sana diyorum ki benim param sende ama atıl
kalmasın, değerlendir bunu."* IRS/Interbank Loan'daki floating-rate alt tablosuyla **aynı mekanizma**,
sadece tenor kataloğu **yalnızca overnight** ile sınırlı (Interbank Loan'daki gibi 3 aylık/6 aylık seçenek
yok).

🔴 **Faiz/tahakkuk hesaplama motoru henüz YOK ve ne zaman geleceği belirsiz** — PO kendi kendine:
*"Peki bunu ne zaman gönderecek bu faiz ödemesini?... yine bu collateral mı bunu üretecek? İşte bunu da
koymasak diyorum... bir cron job'a ihtiyacı var buranın, bence bir şekilde. Akşam veya sabah bakarız."*
**Karar verilmedi** — `CollateralCashTerms` Faz 1'de **yalnızca saklanır** (K-22 zaten böyle diyordu, bu
toplantı teyit etti). Negatif faiz sorusu da aynı şekilde açık bırakıldı (*"faiz negatife düşse bile yine
de şeyin üzerinden bir negatif faiz hesaplayıp dahil edeyim mi etmeyeyim mi ana para üzerine?"*).

### 2.4 Security panelleri (Faz 1'de **disabled**)

Prototipte 2 panel var (Rule-based Eligibility / Specific ISIN, Haircut&Valuation, Settlement&Income) —
alan listesi `index.html`'de hazır duruyor, Excel v5 UML'den de **çıkarıldı** (bu toplantıda). Faz 1'de
UI'da **sadece görünür-ama-tıklanamaz** durur, backend'de tablo/entity **yazılmaz**.

---

## 3. Ekran 3 — Collateral Transaction

İki alt-görünüm: **TRANSACTION** (giriş/edit) ve **TRANSACTION DETAIL** (hareket geçmişi, salt okunur).

### 3.1 Definition and Party

| Alan | Kolon | Giriş | Kaynak | Zorunlu |
|---|---|---|---|---|
| Collateral Code | `DefinitionId` | Listeden seçilir (arama destekli) | Active Collateral Definition | **Evet** |
| Counterparty | — | Otomatik gelir, readonly | Definition | Inherited |
| Collateral Name | — | Otomatik gelir, readonly | Definition | Inherited |
| Collateral Type | — | Otomatik gelir, readonly | Definition | Inherited |
| Portfolio | `PortfolioId` | Listeden seçilir | Portfolio master | **Evet** |
| Trader | — | Otomatik gelir, readonly | Authenticated user | Inherited |
| Input Date | `InputDate` | Otomatik gelir, readonly | System date | Inherited |
| Annex | `AnnexId` | Otomatik gelir, readonly | Definition | Inherited |
| Logical Reference | `LogicalReference` | Yazılır (opsiyonel) | User / Integration | Hayır |

🔑 **400+ collateral arasında arama/filtre gerekiyor** (PO, UI fazı için not — Faz 11'e taşınacak):
*"Dört yüz tane collateral var. Hangisini seçeyim?... Oraya arama yeri koyayım, yazarak filtreleyeyim.
Ya da banka seçelim, bankanın altındakileri getirsin."* → Collateral Code dropdown'ı search-select +
muhtemelen "önce banka seç, sonra o bankanın collateral'ları" iki aşamalı filtre.

🔑 **New'e tıklanınca mevcut transaction'ı Logical Reference ile çekme fikri — ERTELENDİ**: *"Ben new
butonuna tıkladım, oraya logical referansı yazıp enter'a bastığımda o logical referansa ait bilgilerle
dolsun."* PO kendi itiraz etti: *"aynı anda iki kişi girerse... hangisi artıya save'e basarsa"* — race
condition riski görüldü, Faz 11'de ayrıca tasarlanacak, şimdilik normal "var olan transaction'ı listeden aç"
akışı geçerli.

### 3.2 Cash Amount and Currency Conversion *(CollateralType=Cash)*

| Alan | Kolon | Giriş | Kaynak | Zorunlu |
|---|---|---|---|---|
| Transaction Type | `TransactionType` | Listeden seçilir (`Increase`/`Decrease`) | Code list + Annex Direction | **Evet** |
| Margin Type | `MarginType` | Listeden seçilir | Annex Product Scope | **Evet** |
| Trade Date | `TradeDate` | Tarih seçilir | User | **Evet** |
| Value Date | `ValueDate` | Tarih seçilir | User | **Evet** |
| Amount | — | Yazılır | User | **Evet** |
| Currency | — | Listeden seçilir | **Definition'ın Eligible Currencies'i** (tüm currency değil) | **Evet** |
| Current Balance | — | Otomatik gelir, readonly | Transaction ledger | Derived |
| Minimum Amount | — | Otomatik gelir, readonly | Definition (Annex MTA) | Inherited |
| Valuation Currency | — | Otomatik gelir, readonly | Definition / Annex | Inherited |
| FX Conversion Required | — | Hesaplanır, readonly | Currency ≠ Valuation Currency karşılaştırması | Derived |
| FX Rate | `FxRate` | Otomatik gelir, readonly | Market data (elle de girilebilir — bkz. not) | Derived |
| FX Adjustment | `FxAdjustmentRate` | Otomatik gelir, readonly | Definition / Annex | Derived |
| Transaction Value | `TransactionValue` | Hesaplanır, readonly | `Amount × FxRate` | Derived |
| Adjusted Eligible Value | `AdjustedEligibleValue` | Hesaplanır, readonly | `TransactionValue × (1 − FxAdjustment)` | Derived |

🔑 **Formüller (prototip JS'inden ölçüldü — `app.js:528-535`, referans amaçlı, üretim hesaplaması backend'de
olacak):**
```
TransactionValue      = Amount × FxRate
AdjustedEligibleValue = TransactionValue × (1 − FxAdjustmentRate / 100)
```

🔑 **FX senaryosu PO'nun kendi örneğiyle:** Annex/Definition para birimi TL olsa bile kullanıcı farklı para
biriminde (örn. EUR) gönderebilir: *"Ne tanımlarsan tanımla göndermek istediğin currency'i de seçiyorsun...
Global balance'ı senin TL ise TL olarak gibi olacak. TL'ye çevirip düşeceksin."* Yani **running balance
HER ZAMAN Valuation Currency'de tutulur**, işlem farklı bir Currency'de girilse bile FX Rate ile çevrilip
o para birimine yazılır. Rate elle girilir: *"Hangi rate'ten çeviriyorum?... Orayı biz yazacağız. Elle mi?
Evet, disable değil."*

### 3.3 Security Amount and Valuation *(CollateralType=Security, Faz 1'de devre dışı)*

Alan listesi `index.html`'de hazır (Nominal, Price, Market Value, Asset/FX Haircut, Adjusted Eligible
Value). Formül (`app.js:546-548`, referans):
```
MarketValueLocal      = Nominal × Price / 100
MarketValue           = MarketValueLocal × FxRate
AdjustedEligibleValue = MarketValue × (1 − AssetHaircutRate/100) × (1 − FxHaircutRate/100)
```
**Haircut kavramı** (PO, teknik olmayan katılımcıya): *"Sen mesela verdin menkul kıymet yüz ama diyor ki
ben sana verdiğin menkul kıymeti yüz değil doksan kabul ediyorum... Haircut stopaj demek."* Faz 1'de
**yazılmayacak** — Security tamamen K-17 kapsamı dışı.

### 3.4 Limit status (kart, salt okunur)

Counterparty bazlı limit özeti: Country Limit, Total Limit, Used Limit, Available Limit, Risk Amount,
kullanım yüzdesi. Mevcut Limit servis desenine bağlanacak (`A-13` — Faz 1'de olup olmayacağı hâlâ açık,
bu toplantıda konuşulmadı).

### 3.5 Near Payment Instructions — `TxnPaymentInstruction`

| Alan | Kolon | Giriş | Kaynak | Zorunlu |
|---|---|---|---|---|
| Settlement Type | `SettlementTypeId` | Listeden seçilir | Payment configuration | Koşullu |
| Payment Instr. Type | `PaymentInstructionTypeId` | Listeden seçilir | Payment configuration | Koşullu |
| We Send | `WeSendSsiId` | Listeden seçilir | SSI master | Koşullu |
| They Receive | `TheyReceiveSsiId` | Listeden seçilir | Counterparty SSI | Koşullu |
| We Receive | `WeReceiveSsiId` | Listeden seçilir | SSI master | Koşullu |
| They Send | `TheySendSsiId` | Listeden seçilir | Counterparty SSI | Koşullu |
| Send Confirmation / Send Payment / Send Notice To Receive | `SendConfirmation`/`SendPayment`/`SendNoticeToReceive` | İşaretlenir | User / Policy | Hayır |
| Instructions | `Instructions` | Yazılır (serbest metin) | User | Hayır |

🔴 **Excel v5 UML'de bu tablo `(TxnId, InstructionVersion)` ile VERSİYONLU** — her transaction edit'i
(her yeni TxnTransactionDetail satırı) kendi payment-instruction anını yeniden yazabilir; MM'in TxnMM'si
gibi **tek, değişmez set DEĞİL**. Bu, K-44'ün (her edit → yeni detail) payment tarafına yansıması.

🔑 **Increase/Decrease yönüne göre hangi alanların editlenebilir olduğu flip eder** (IRCC'deki Pay/Receive
deseniyle aynı mantık, PO: *"IRCC'de update etmiştik onu... ona göre gelecekler"*):

| Transaction Type | Editlenebilir | Readonly (karşı taraf bilgisi) |
|---|---|---|
| `Increase` (para bana geliyor) | We Receive, They Send | We Send, They Receive |
| `Decrease` (para benden çıkıyor) | We Send, They Receive | We Receive, They Send |

`SendPayment` bayrağı **gelen** parada her zaman `false`/readonly (*"ödeme mesajı bana gelende ödeme
mesajı çıkmaz, gidende çıkar... senin gidende çıkar"*); `SendConfirmation` her iki yönde de seçilebilir.

### 3.6 Security Settlement Instructions *(CollateralType=Security, Faz 1'de devre dışı)*

Settlement Location, Custody Account, Settlement Instruction (SSI), Delivery Type (Transaction Type'tan
türer), Instructions. Faz 1'de yazılmaz.

### 3.7 Transaction Detail (alt sekme — salt okunur geçmiş)

Seçili transaction'ın tüm hareketlerini **kronolojik, running-balance'lı** liste olarak gösterir — K-44'ün
("ana Txn hiç değişmeyecek, her hareket TxnDetail'da") **ekrana yansıması**. Başlık alanları: Collateral
Code, Currency/ISIN, History Start Date, Current Balance (hepsi türetilmiş/salt okunur).

---

## 4. İş akışı kuralları (transcript'ten, kod yazılırken referans)

### 4.1 Verify → Opening fişi; valör kuralı — forward batch YOK

PO: *"Bunun bir accounting'i olacak accounting engine'de değil mi?... Ben gideceğim o bacakları bildiğin
opening fişi gibi bir şey keseceğim."* Her Increase/Decrease hareketi **kendi Opening-tipi fişini** üretir
(MM/OptionsFX'teki "trade açılışı" kavramından farklı — burada her hareket kendi başına bir "açılış").

🔴 **Valör kuralı — MM'den FARKLI, forward batch yok:**
> *"Burada o zaman logical date'le bakacaksın sen. Logical date, value date eşitse mi? Evet. Değilse fiş
> kesmeyeceğim... Verify ettiğin an ilk gidip bakacağım şey value date'i logical date'e eşit mi? Değilse
> ekrana bir pop-up basacağım: value date logical date'e eşit değildir diyeceğim."*
> *"Forward batch'i var mı?... Valörsüz bir şeyi ben forward batch'in değil, niye handle ediyorum ki?"*
> (sonuç: **forward batch YOK**, T+0 zorunlu)

**Kural:** `Verify` action'ı **`ValueDate == LogicalDate`** kontrolü yapar; eşit değilse **reddeder**
(kullanıcı tarihi düzeltmeden Verify edemez). MM'deki gibi "ileri tarihliyi beklet, günü gelince forward
batch fiş kessin" deseni **burada yok** — bu bilinçli bir basitleştirme (K-48, bkz. `07-kararlar-ve-sorular.md`).

### 4.2 Delete + Verify → Reverse (Opening'in tersi)

> *"Delete edebiliyor muyum? Yanlış mı yaptım yani? Evet, edebilirsin. Delete ettikten sonra verify
> edince ne olacak? Tersine dönecek... Açılış var. Ve reverse var... tersini-- açılış ve ters var."*

**Akış:** Verified bir transaction/detail üzerinde `Delete` işaretlenir (maker) → `Verify` edilince
(checker) → o hareketin Opening fişi **Reverse** edilir (Fimple'ın native tek-seferlik reverse komutuyla,
MM/OptionsFX'in **`IAccountingReverseFactory`** ile aynı mekanizma — Debit/Credit flip, `IsReverse=true`,
`ReverseId` = orijinal fişin Id'si). Bu, Collateral'da muhasebe tarafında **gerekli tek ek operasyon**
(reeskont/maturation/ara ödeme **yok** — K-48).

### 4.3 Annex/Definition: Verify sonrası edit — kullanım kilidi

> *"Collateral annex'te artık sen basıp verify ettiğinden edit yok... Annex ve definition transaction'da
> kullanılmadığı takdirde verify'dan sonra değiştirilebilir. Kullanılıyorsa değiştirilemez."*
> *"Edit değil de backend'ten hata dönersin... Child verify edemezsin diye backend'ten hata dönüyor."*

**Kural:** Annex ve CollateralDefinition, Verify'dan **sonra da** editlenebilir (maker-checker tekrar
çalışır — genel flow, Collateral'a özel yeni bir flow tipi **yazılmıyor**). **AMA** en az bir
`TxnTransaction` tarafından referans alınıyorsa (o Annex/Definition kullanılmışsa), edit isteği
**backend'te reddedilir** (UI'da buton gizlenmez — *"edit butonunu override edeyim... bakayım kullanılmış
mı? ... Child verify edemezsin diye backend'ten hata dönüyor"*). Yani kontrol **her zaman backend'de**,
UI yalnız hatayı gösterir.

### 4.4 Collateral'ın "bitişi" — accounting event değil, durum/tarih kontrolü

> *"Kapanıyor. Artık daha mesela benim hiçbir şekilde o şeyim sıfırlanmış oluyor ya, current balance.
> Sıfır olmuş oluyor. Tamam. Aynı zamanda annex sözleşmem de bitmiş oluyor... yani annex varsa collateral
> annex seçtiyse bu annexin valid to'su, annex seçmediyse collateral'ın valid to'su."*

Collateral'ın "itfa/mature" olması; **yeni bir accounting operasyonu değil** — CurrentBalance sıfırlanana
kadar normal Decrease hareketleriyle kapanır, ardından Annex (varsa) veya Definition'ın kendi `ValidTo`
tarihinde sözleşme sona erer. `ValidFrom` **zorunlu**, `ValidTo` **zorunlu değil** (bazı sözleşmeler süresiz
devam eder — *"bazıları sonsuz devam ediyor... swap'ların bitiyor, yenisi başlıyor"*).

---

## 5. Hesap tutma mantığı — running balance örneği (PO'nun kendi senaryosu)

Bu örnek K-40/K-44'ün (master-detail, Txn hiç değişmez) **somut** hâli — ileride TxnTransactionDetail
tasarlanırken referans:

1. Gün 1: `Decrease 5.000.000` → CurrentBalance = **5.000.000** (bana teminat olarak 5M gitti)
2. Gün 4: aynı transaction'ı aç, edit, `Decrease 1.000.000` → CurrentBalance = **6.000.000**
3. Gün 7 (3 gün margin call yapılmamış — *"her gün hesaplıyorsun ama her gün margin call yapmıyorsun,
   küçükse gerek yok"*): `Increase 2.000.000` → CurrentBalance = **4.000.000**

Her adım **yeni bir TxnTransactionDetail satırı** üretir (K-44); `TxnTransaction`'ın kendisi hiç
değişmez, yalnız **türetilen** CurrentBalance güncellenir (nerede tutulduğu — Txn üzerinde mi, son
Detail satırında mı — entity tasarımı aşamasında karara bağlandı, bkz. `fazlar/faz-8-transaction.md`).

---

## 6. Product/SubProduct kataloğu — A-21 bu toplantıda yanıtlandı

> *"Product'larımız mesela FX, MM, FI, Deriv, Option gibi main product'lar... Sub product'larımız da
> Forward Swap, Future, IRS, CCS, Money Market... Money Market'in definition ekranı var, onu dinamik
> çekeceğim. Diğerlerini yine standart hard code basacağım."*

**Karar:** Tek ortak ürün kataloğu tablosu **yok**. Karma kaynak:
- **MM'in ürünleri/alt ürünleri** → MM'in kendi `ProductDefinition`/Product tanım ekranından **canlı**
  (dinamik) çekilir.
- **Diğer modüllerin ürünleri** (FX, Interest Rate/Deriv, Repo, Securities Lending gibi) → ColManagement
  içinde **sabit kodlu** (hardcode) liste — ayrı bir cross-module ürün kataloğu kurulmuyor.

Prototipteki modal listesi (`FX / Interest Rate / Money Market / Repo / Securities Lending`, alt ürünler
`Forward/Swap/NDF / IRS/CCS / Repo/Reverse Repo / Borrowing/Lending`) bu karma modelin ilk hard-code
taslağı — kesinleşmiş değil, UI fazında MM entegrasyonu netleşince gözden geçirilecek.

---

## 7. Geliştirici modu / Field map (prototipin kendi özelliği, referans)

Prototip `Developer mode` toggle'ı ve `Field map` drawer'ı taşıyor — her alanın `data-key` (binding),
`data-control` (DevExtreme karşılığı seçilirken kullanılacak), `data-entry` (TR açıklama) ve `data-required`
değerini canlı gösteriyor. UI fazında ekranları DevExtreme'e dökerken bu attribute'lar **bire bir kaynak**:
yeni bir alan çıkarsa önce `index.html`'e aynı formatta eklenip orada doğrulanması, sonra koda geçilmesi
öneriliyor (PO'nun kendi çalışma şekli de bu — *"sen bu dokümanı bana atarsan ben ilerleteceğim"*).

---

## 8. Entegrasyon sınırı — prototip SADECE referans

`Dinamik-Ekran/README.md`'nin kendi uyarısı: *"The prototype contains sample data and browser-side
calculations only. Production implementation must call the authoritative Annex, Definition, market data,
limit, SSI, ledger, settlement, messaging and audit services... The client must not be treated as the
source of truth for Verify rules or balances."* — yani §3.2/§3.3'teki formüller ve tüm "Otomatik gelir"
alanları **backend'den** gelecek, tarayıcıda yeniden hesaplanmayacak.
