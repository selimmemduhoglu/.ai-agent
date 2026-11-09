# 07 — Kararlar ve Açık Sorular

> **Son güncelleme:** 2026-10-07 · Repo-özel kararlar ayrıca
> `NetTrex.Collateral/.ai-agent/00-FAZ-PLANI.md` §5'te

---

## A. VERİLMİŞ KARARLAR

### Yöntem / mimari

| # | Karar | Gerekçe |
|---|---|---|
| K-01 | **OptionsFX'ten dosya kopyalanacak**, Claude temizlik + yeniden adlandırma + doğrulama yapacak | İlk itiraz *"sırlar TFS geçmişine girer"* idi; kullanıcı **dosya** kopyalıyor, `git clone` yapmıyor → geçmiş taşınmıyor. 50+ csproj'u elle yazmak için paket sürümlerini yine OptionsFX'ten okumak gerekiyor |
| K-02 | **Emsal OptionsFX** (MM değil) | merkezi paket yönetimi · `CoreDataSlice` · fluent pipeline · ölü kod yok · DataManager/Repository 72+81 → 42+28 |
| K-03 | **Kurulum script'leri emsali DerivSWP** | tek tam emsal (`Kurulum Scriptleri/` 0-9 sırası) |
| K-04 | İş sırası: **Excel → script → backend → UI** | kullanıcı belirledi; kod script'ten önce yazılmaz |

### Veri modeli

| # | Karar | Gerekçe |
|---|---|---|
| K-05 | Tüm PK'ler **`bigint`** | ofis kuralı; DerivSwp `int` başlayıp v1.30'da 3 script'le düzeltmek zorunda kaldı |
| K-06 | Para `decimal(38,10)` · oran `decimal(18,10)` · **`float` yasak** | 3 DB fiziksel ölçümü. ⚠️ `decimal(38,2)` **hiç yok** |
| K-07 | **CHECK constraint yazılmaz**; FK yalnız referans tablolarına, `NO_ACTION` | MM 0 CHECK/14 FK · DerivSwp 0 CHECK/3 FK |
| K-08 | Ana işlem tablosu + 3 muhasebe tablosu **`DefNumberGen`'den**; gerisi **IDENTITY** | 3/3 modülde istisnasız ölçüldü |
| K-09 | Sayaç adı **alt tireli yeni biçim** (`Txn_Id`), `EntityColumnType` **nötr** (`TransactionId=1`) | OPTFX/DerivSWP biçimi; MM'inki eski |
| K-10 | `*History`'de IDENTITY **`HistoryId`**'de, `Id` kaynaktan taşınır | 3 DB'de istisnasız |
| K-11 | Muhasebe **kural** tabloları modül DB'sinde **yok** — yalnız `AccEntryMain`/`AccEntry`/`AccEngineGeneratedAccountRule` (fiş). Üçü **şimdiden** kurulur | aynı sayaçtan besleniyorlar; sonradan eklemek bağımlılığı yeniden kurmak demek |
| K-12 | Referans verisi **`CoreDataSlice`** ile paketten; entity/config/handler **yazılmaz** | `Data.Domain` 120 → 30 dosya |
| K-13 | Child tablolardan `ValidFrom`/`ValidTo` kaldırıldı | iki rakip versiyonlama deseni; parent revizyonu tek kaynak |
| K-14 | `Status` → **`IsEnabled bit`** | `DRAFT≈16`, `ACTIVE≈18` — %70 tekrardı |
| K-15 | `CollateralPosition` **zorunlu** (opsiyonel değil) | eşzamanlı Decrease için tek deterministik yol |
| K-18 | **Ana tablo `TxnTransaction`** · `Def` öneki modülün KENDİ tanım tablolarından kaldırıldı (`Annex`, `CollateralDefinition`) | OptionsFX kuralı: modülün kendi tablosu jenerik ad alır, **miras alınan** tablo (`CusCustomer`, `PrfPortfolio`) eski adını korur. DB adı zaten `NetTrexCollateral` — her tabloya "Collateral" yazmak tekrar |
| K-19 | 1:1 alt tipler **`TxnTransaction*`** · 1:N yardımcılar **`Txn*`** (`TxnPaymentInstruction`, `TxnMessage`, `TxnLimitSnapshot`) | Ev deseni: `TxnNote` / `TxnSync` / `TxnCashFlow`. Ayrıca `TxnTransactionPaymentInstruction` **32 karakter** — Excel sheet adı sınırı 31 |
| K-20 | Değerleme **`CollateralRevaluation`** — modül adının kaldığı **tek** yer | `OptionsFXRevaluation` / `DerivativesRevaluation` emsali; EOD batch bu adı arıyor |
| K-21 | **Security tabloları Faz 1'de kurulur** | Kullanıcı kararı. Tablo kurmak ucuz, sonradan ana işlem tablosuna kolon eklemek pahalı |
| K-22 | **`CollateralCashTerms` kalır** (silinmedi) | Doküman istiyor, transcript'te "kaldırıldı" belirsiz. ⚠️ Faz-1'de yalnız **saklanır**, hesaplama motoru yazılmaz |
| K-23 | **`ProductDefinition` tablosu eklendi** (2 satır: CASH, SECURITY) | `CollateralDefinition` kullanıcının girdiği **iş** verisi; `ProductDefinition` modülün **platform** konfigürasyonu (`ExternalMainProductCode`, `PortfolioRootPath`, `AccountingMapCode`). 3 modülde de var |
| K-24 | 🔴 **`MarginType = ALL` enum'a EKLENMEZ** — UI 4 satır yazar | `ALL` enum'a girerse her sorgu `= @x OR = 'ALL'` yazmak zorunda kalır ve bir yerde unutulur; unutulan yer **sessizce eksik sonuç** döndürür |
| K-25 | ~~Transaction modeli: doküman esas~~ → 🔄 **K-40 ile değişti** | Transcript'in istediği "defter" zaten bu modelde var: aynı `CollateralDefinition`'ın `TxnTransaction` satırları = detay sekmesi. Eksik olan iki alan eklendi: `Description`, `AccountingReference` |

### Patron toplantısı sonrası (2026-10-09) → [`10-toplanti-2026-10-08.md`](10-toplanti-2026-10-08.md)

| # | Karar | Gerekçe |
|---|---|---|
| K-39 | 🔴 **Kod kaynağı: Seq/Serilog MM'den, geri kalan HER ŞEY OptionsFX'ten** (K-33 ve K-37'nin yerine) | Kullanıcı: *"Seq loglamaları MM'deki gibi olsun, onun dışındaki her yer OptionFx'teki gibi olsun."* OptionsFX'in 15 açığı düzeltilerek alındı → `progress/09` |
| K-40 | 🔴 **Master-detail: `TxnTransaction` + `TxnTransactionDetail`** (K-25'in yerine) | Patron: her ekle/çıkar/artır/azalt **yeni detail satırı**, öncekiler kapatılır; *"history değil, change"*. İleride detail'lara işlemler N-M bağlanacak |
| K-41 | **`CollateralRevaluation` SİLİNDİ** (K-20'nin yerine) | Patron: *"Revaluation falan yok."* Değerleme menkul kıymet fazında (1.5) geri gelebilir |
| K-42 | **Modül adı yazımı `ColManagement`** (büyük M) | `Col` = Collateral kısaltması, `Management` ayrı kelime → PascalCase. Kullanıcı 2026-10-09: *"ColManagement olsun karar verdiğimiz gibi"* |
| K-43 | 🔴 **Fimple TAMAMEN kullanılıyor** (A-23 kapandı) | Kullanıcı: *"Fimple tamamiyle kullanılacak, onu yanlış anlamışsın; sadece ödeme mesajlarını biz mi yapacağız Fimple'da mı yapılacak anlamındaki konuşmaydı."* Auth/muhasebe senkronu/bildirim diğer modüller gibi |
| K-44 | 🔴 **3 ekran; `TxnTransaction` açıldıktan sonra DEĞİŞMEZ, her hareket yeni `TxnTransactionDetail`** | Kullanıcı: *"ana Txn hiç değişmeyecek ve her işlem TxnDetail'da değişecek"* — işin özü. Muhasebe detail'dan doğar. Tahta → `10-toplanti` §6b |
| K-55 | 🔑 **K-44 netleşti (2026-10-22):** Txn **Collateral Definition'a göre** girilir, **Verify'a kadar** normal Edit. **Verify'dan sonra** her giriş/çıkış (para hareketi) bir **`TxnTransactionDetail`** oluşturur; verify sonrası Txn edit'i doğrudan Detail olarak yansır. **Detail'lar maker-checker**'dan geçer · **muhasebe fişi Detail başına** · **başlıktaki cash alanları KALIR** (`TxnTransactionCash` silinmez) | Kullanıcı: *"bir transaction Collateral Definition'a göre girilecek ve sonra da Edit yapılabilecek ve Verify olduktan sonra da eğer ki giriş çıkış yapıldığı zaman Detail oluşacak… Detail'larda maker ve checker onayından geçecek… Muhasebe fişi de her hareket için ayrı kesilecek. Detail'a bağlı olarak… olan cash alanları kalacak."* · INCI §4 madde 2 bu karara göre uygulanacak (henüz kod yok) |
| K-56 | 🔑 Annex ve CollateralDefinition **maker-checker tanım** olarak kalır (MM `PrdProductDefinition` gibi); flow engine/FlowId/Trader/Previous* eklenmez (2026-10-22) | Kullanıcı: *"MM in ekranındaki gibi kalsın… MM de ki ProductDefinition tablosu gibi olsun"* |
| K-57 | 🔑 Definition'da Annex **opsiyonel**; seçilirse Counterparty, Valid From/To, Eligibility Direction, Valuation Currency Annex'ten gelir ve **disabled**; seçilmezse elle (2026-10-22) | Kullanıcı: *"COllateralmanagement Annex'e bağlı olabilir veya olmayabilir"* |
| K-58 | 🔑 **V2 revize (2026-11-02): yeni analiz dokümanı + `Treasy_Collateral_Veri_Modeli.xlsx` + Demo tek kaynak.** Tablolar Excel'deki ad ve tiplerle yeniden kurulur (`CollateralAnnex`, `CollateralAnnexProduct`, `CollateralAnnexRule`, düz `CollateralDefinition`, başlık `TxnTransaction` + hareket `TxnTransactionDetail`). **K-55 güncellendi:** Txn = tanım + portföy için kalıcı pozisyon; New = başlık + ilk hareket, Edit = yeni hareket; hareket değiştirilmez/silinmez; `TxnTransactionCash` ve `CollateralPosition` **kalkar**. **K-56 kapandı:** Annex/Definition da tam FlowEntity (Excel). Analiz → [`../06-V2-REVIZE-ANALIZ.md`](../06-V2-REVIZE-ANALIZ.md) | Kullanıcı: *"bu attığım döküman, excel ve Demo yapısında ki html ve Rule'ları inceleyerek … bu yapıya uygun değişiklikler yap"* · akış kolonu sorusuna "Excel'e uy" |
| K-59 | Annex Product/Sub Product **modülün kendi DB'sinde** (`CollateralProduct` / `CollateralSubProduct`, demodaki 5 ürünle seed). MM API ürün çağrısı kalkar (A-21 eski kararı geçersiz) | Doküman §6.4 · kullanıcı seçimi 2026-11-02 |
| K-60 | Muhasebe **Detail (hareket) başına**: her hareket Verify'da Opening pipeline'ı o hareketle; Transaction Delete-Verify'da onaylı hareketlerin ters fişi (K-48/K-55 korunur) | Kullanıcı seçimi 2026-11-02 |
| K-61 | Enum alanlar Excel gibi **int kolon**; dropdown adları **lookup tablolarından** (Id = enum değeri). Eksik lookup'lar eklenir (InterestSettlement, TransactionType, RecordStatus) | Kullanıcı seçimi 2026-11-02 (önceki "dropdown'lar DB'den" isteği korunur) |
| K-45 | 🔑 **Belirsizlikte MM** | Kullanıcı: *"kafan karışınca MM kodlarını kullan"*. Seq MM · Accounting OptionsFX · yapı OptionsFX · kütüphaneye yaslanan/belirsiz yer MM. İlk uygulama: `AddQuant` (QuGet fiyatlama kütüphanesi) yerine MM `CalendarHelper` |
| K-46 | 🔴 **Açık düzeltilmez, kayda yazılır** | Kullanıcı: *"MM'i önceliklendirerek aynısını geçir gitsin… açık gördüğün yerleri yaz, sonra bakacağım"*. 2026-10-09 sonrası bulunan açıklar `03-HATA-KAYDI.md`'ye; önceki düzeltmeler orada ✅ işaretli |
| K-47 | **Route adları OptionsFX** (`currencies/f-key` …); UI'da da OptionsFX adları muhtemel — UI fazında konuşulacak · Dağıtım: ortamlar/pipeline **MM**, port **5061-63**, image **MM deseni**, Elasticsearch **OFX gibi secret** | Kullanıcı cevapları 2026-10-09 (`progress/15`) |

### Kaynak güvenilirliği

| # | Karar | Gerekçe |
|---|---|---|
| K-16 | 🔴 **İş kararlarında transcript bağlayıcı**, doküman ikincil | İş analisti dokümanın DB bölümünü sahiplenmiyor: *"Buralar yanlış olabilir"* (1577-1600). O bölüm AI üretimi |
| K-17 | **Faz 1 = yalnız NAKİT** | *"Biz nakit tarafını yapacağız"* (15). Menkul tasarımda durur, geliştirmesini başka ekip yapar |

---

## B. 🔴 AÇIK SORULAR — kullanıcı kararı bekliyor

### ✅ Öncelik 1 — KAPANDI (Excel **v5**, 2026-10-07)

| # | Soru | Verilen cevap |
|---|---|---|
| ~~A-01~~ | Transaction modeli: master+detail mi, hareket başına satır mı? | ✅ **Hareket başına satır** (doküman modeli). Transcript'in "defter"i bu satırların `CollateralDefinition` bazında sıralanmış hâli. → `K-25` |
| ~~A-02~~ | Ana tablo adı | ✅ **`TxnTransaction`** → `K-18` |
| ~~A-03~~ | `CollateralCashTerms` kalsın mı? | ✅ **Kalır**, Faz-1'de yalnız saklanır → `K-22` |
| ~~A-04~~ | Security tabloları | ✅ **Faz 1'de kurulur** → `K-21` |
| ~~A-05~~ | `ProductDefinition` olacak mı | ✅ **Olacak**, 2 satır → `K-23`. ⚠️ Annex'in `ProductCode`/`SubProductCode`'u **buraya bağlanmaz** — o başka modüllerin ürünü (FX/Repo/IR); kataloğun kaynağı hâlâ açık (yeni **A-21**) |
| ~~A-06~~ | `MarginType = ALL` | ✅ **Enum'a eklenmedi**, UI 4 satır yazar → `K-24` |

### Öncelik 2 — script yazmadan önce

| # | Soru | Not |
|---|---|---|
| **A-07** | **Sayaç öneki** | İki haneli olmalı (`int.Parse` tavanı: 2 hane → ~9.999.999 kayıt, 3 hane → ~999.999). Hangi iki hane? |
| **A-08** | **Modül kodu** | DerivSwp `DV`, MM `MM`. Collateral `CL`? `CLT`? Portfolio.Module, parametre path öneki ve `ExternalMainProductCode`'da kullanılacak |
| **A-09** | **DB adı** | `NetTrexCollateral` varsayıldı. Sunucuda `%Collateral%` DB'si yok |
| **A-10** | **`TxnCashFlow` gerekli mi** | MM+DerivSWP'de var, OPTFX'te yok |
| ~~A-11~~ | ✅ **KAPANDI** — 10 dilim: `DateBasis·Currency·CurrencyPair·Calendar·Holiday·HalfWorkingDay·FxRate·Chart·Point·InterestRate`. `Volatility` **alınmadı** (opsiyon fiyatlaması yok). `Chart·Point·InterestRate` CashTerms faiz tarafı için |

### Öncelik 3 — mimari, sonraki fazlarda da sorulabilir

| # | Soru | Not |
|---|---|---|
| **A-12** | 🔴 **Mesaj tabloları nerede yaşasın?** | SPK_1: *"ödeme mesajlarının ara bir tablosu… **ortak bir yerde**"* (1490-1494). Excel Collateral DB'sine koyuyor. Ödeme altyapısı **ilk kez burada kuruluyor** ve *"bu modülün iki katı kadar iş"* (1358) |
| **A-13** | **Limit servisi faz-1'de mi?** | Doküman §6.3 + Excel `TxnLimitSnapshot` detaylı; transcript'te **teyit yok** |
| **A-14** | **Confirmation mesajı üretilecek mi?** | Transcript 1388-1394 "bildirme yok" diyor gibi ama **ASR çok bozuk**, belirsiz |
| **A-15** | **Dinamik kural motoru** | SPK_1 istedi (275-282), cevap alınmadı. Threshold/MTA sabit kolon mu, kural ifadesi mi? |
| **A-16** | `CollateralAuditLog` kalacak mı | MM'de polymorphic audit emsali yok (tablo başına `History`+trigger). Doküman tek tablo istiyor. İkisi birlikte de olabilir |
| **A-17** | `AnnexMarginRule` History alacak mı | Parasal şart taşıyor ama parent revizyonu immutable'sa gerekmez |
| **A-18** | **Security/SSI/Account/Rating master'ları nerede** | MM'de yok. Collateral içinde mi, ortak modülde mi? En büyük dış bağımlılık |
| **A-19** | Filtered unique index | 3 DB'de emsali **yok**. `UQ_TxnTransaction_SourceSystem` için ya sapma ya `NOT NULL DEFAULT('')` |
| **A-21** | 🔴 **Annex `ProductCode`/`SubProductCode` hangi katalogdan?** | `ProductDefinition` **değil** (o Collateral'ın kendi 2 satırı). Teminatlandırılan işlem FX/Repo/IR olabilir → ortak bir ürün kataloğu mu, modül başına mı? Toplantıda sorulacak |
| **A-20** | `DisputeTolerance*` zorunlu mu | Doküman detaylı, transcript'te **hiç geçmiyor**. Excel'de `Null=No` |

### Patron toplantısından doğanlar (2026-10-08) → [`10-toplanti-2026-10-08.md`](10-toplanti-2026-10-08.md)

| # | Soru | Not |
|---|---|---|
| **A-22** | ⏸ Platformun yeni **mikroservis scaffolding**'i ile iskelet karşılaştırması | **Ertelendi** — kullanıcı: *"bu konu bir dursun sonra bakıcaz"* |
| ~~A-23~~ | ✅ **KAPANDI → K-43** — Fimple tamamen kullanılıyor | — |
| ~~A-24~~ | ✅ **KAPANDI (2026-10-12 toplantı #3)** — `AnnexMarginRule` **AYRI TABLO**, `AnnexProductScope`'a bağlı (seçili scope satırı context'inde "Add Rule"). Selim: *"Ben ayrı tabloya koyarım yani. Aynı tabloya koymam ben kendim."* Max 2 satır/scope (`Own`/`Counterparty`) | `11-ui-ekran-rehberi.md` §1.4 |
| **A-25** | Nazım hesap (996-998) bacağı faz-1'de mi? | Patron istiyor, analist görmemiş — **bu toplantıda konuşulmadı, hâlâ açık** |
| **A-26** | 🟡 Ödeme faz-1 | Kullanıcı eğilimi: ödeme mesajını muhtemelen **Fimple** üretecek; bizde detail'da **"ödeme mesajı gönderildi" bayrağı** — kullanıcı `true` yapıp kaydeder. **Toplantı #3 ile netleşen kısım:** `TxnPaymentInstruction` ayrı, `(TxnId, InstructionVersion)` ile **versiyonlu** bir tablo (Excel v5 UML'de kesinleşti); alanları We/They Send/Receive SSI'leri, Settlement/PaymentInstruction tipi, 3 bayrak, Instructions — MM'in TxnMM'sine gömülü (versiyonsuz) modelinden **bilinçli sapma**, çünkü K-44 her edit'te yeni versiyon istiyor |
| **A-27** | `TxnTransactionDetail` kolonları ve "kapatma" alanı | Excel v5 UML'de **hâlâ yok** — toplantı #3'te de konuşulmadı. Entity tasarımı Selim'in kendi kararıyla yapıldı, bkz. `fazlar/faz-8-transaction.md` |
| ~~A-21~~ | ✅ **KAPANDI (2026-10-12 toplantı #3)** — Annex `ProductCode`/`SubProductCode` kataloğu: **MM'in ürünleri MM'den dinamik çekilir**, diğer modüllerin (FX/Deriv/Option/Repo/Securities Lending) ürünleri ColManagement içinde **hardcode** — ortak bir cross-module ürün kataloğu kurulmuyor | `11-ui-ekran-rehberi.md` §6 |

### Toplantı #3'ten doğanlar (2026-10-12/13) → [`11-ui-ekran-rehberi.md`](11-ui-ekran-rehberi.md)

| # | Karar | Gerekçe |
|---|---|---|
| **K-48** | 🔴 **Collateral muhasebesinde yalnız Opening + Opening'in Reverse'i var.** Reeskont (Revaluation), Maturation, ara ödeme (interim payment) **YOK**. | Selim: *"Openin tarafını yazmıştın ya reeskont, maturation ve ara ödeme olmayacak ama opening fişinin reverse'ü kesilecek."* Her Increase/Decrease hareketi kendi Opening-tipi fişini keser; "Delete+Verify" aksiyonu o fişi Reverse'ler (MM/OptionsFX'in `IAccountingReverseFactory` mirror-flip deseniyle, aynen) |
| **K-49** | 🔴 **Forward batch YOK — Verify, `ValueDate == LogicalDate` değilse reddeder.** | PO: *"Valörsüz bir şeyi ben forward batch'in değil, niye handle ediyorum ki?... Değilse fiş kesmeyeceğim, ekrana pop-up basacağım."* MM'deki "ileri tarihliyi beklet" deseni bilinçli olarak alınmadı |
| **K-50** | Status = **Active/Inactive, 2 seçenek** (Draft yok) — Annex ve Definition'ın ikisinde de | PO: *"Bu draft gereksiz bence... Yapay zeka yapmış çünkü draftı belli ki."* K-14 (`IsEnabled bit`) ile zaten uyumlu |
| **K-51** | `Annex.Direction` ve `TxnTransaction.TransactionType` **sabit enum**, `DefTxnType` gibi dinamik bir yön-master tablosuna **bağlanmaz** | PO: *"Hayır biz onu increase ve decrease diyeceğiz."* — müşteriden müşteriye terim değişse de (placement/lending gibi) iş kuralı sabit kalıyor |
| **K-52** | `CollateralCashTerms`'ten **Cash Settlement/Account alanları kaldırıldı** — bilgi Transaction ekranının "Near Payment Instructions"ına taşındı, tekrar oluyordu | PO: *"Bence şu cash settlement at account'u silsek mi? Silelim."* Excel v5 UML'de zaten bu alanlar yok |
| **K-53** | Annex/CollateralDefinition **Verify sonrası da editlenebilir** (genel flow, yeni flow tipi yazılmaz) — **ama** bir `TxnTransaction` tarafından referans alınıyorsa backend edit'i **reddeder** (UI buton gizlemez, hata backend'den döner) | PO: *"Annex ve definition transaction'da kullanılmadığı takdirde verify'dan sonra değiştirilebilir. Kullanılıyorsa değiştirilemez... Child verify edemezsin diye backend'ten hata dönüyor."* |
| 🔴 **K-54** | **Security (menkul kıymet) teminat tipi tamamen KAPSAM DIŞI — Faz 1 yalnız Cash.** `CollateralType.Security` enum değeri koddan **kaldırılmadı** (CollateralDefinition/TxnTransaction ekranlarında zaten seçim yok) ama Security'ye özel hiçbir entity/handler/UI yazılmayacak. 2026-10-14'te bir tur Security-side backend (CollateralSecurityEligibility/Valuation/Settlement entity'leri, TxnTransactionSecurity, Factory/Verify/Update/Get dallanması) yazılıp **aynı oturumda tamamen geri alındı**. | Kullanıcı: *"Security ile alakalı hiç bir geliştirme yapmana gerek yok istemiyorum gerek olmadığına kanaat getirdik"* → *"security kısımlarını istemiyorum onlardan vazgeçtik... sadece Cash yapısıyla devam edicez"* |

---

## C. ⚠️ Doğrulanması gereken teknik noktalar

| # | Konu | Nasıl doğrulanır |
|---|---|---|
| ~~D-01~~ | ✅ **KAPANDI 2026-10-08** — DLL gerekmedi, `NetTrex.OptionsFX.Data.Core/OptFxCoreData.cs` kaynakta açık yazıyordu. Üyeler: `DateBasis · Currency · CurrencyPair · Chart · Point · Calendar · Holiday · HalfWorkingDay · FxRate · InterestRate · Volatility` | ColManagement 10 dilim alıyor (`Volatility` hariç) |
| D-02 | `sp_GetNewNumbers` modül DB'sine nasıl geliyor | Kurulum script'lerinde **yok**; DB projesinden (`TrexFramework`) deploy ediliyor olmalı |
| D-03 | Hangfire tablolarının runtime'da kurulduğu | Hiçbir kurulum script'inde yok |
| D-04 | `General:AvailableModules` nasıl güncelleniyor | Hiçbir script'te yok, elle yapılıyor olmalı |
| D-05 | MM `ProductDefinition` Create yolunun kırık olduğu | Kod-seviyesi çıkarım, runtime'da denenmedi |
