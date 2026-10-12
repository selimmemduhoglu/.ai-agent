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
| **A-24** | `AnnexMarginRule` ayrı tablo mu, Annex üzerinde Own/Cp × 4 = 8 kolon mu? ProductScope'a bağlı mı? | Patron: hep iki taraf → Annex'e koy. ProductScope bağı tanım ekranında görülmüyor — tekrar sorulacak |
| **A-25** | Nazım hesap (996-998) bacağı faz-1'de mi? | Patron istiyor, analist görmemiş |
| **A-26** | 🟡 Ödeme faz-1 | Kullanıcı eğilimi: ödeme mesajını muhtemelen **Fimple** üretecek; bizde detail'da **"ödeme mesajı gönderildi" bayrağı** — kullanıcı `true` yapıp kaydeder. *"Daha kesin konuşulmadı."* MT299 gibi workaround **yasak** |
| **A-27** | `TxnTransactionDetail` kolonları ve "kapatma" alanı | `IsActive` / `EndDate` / `ClosedByDetailId` — Excel v6'da tasarlanacak |

---

## C. ⚠️ Doğrulanması gereken teknik noktalar

| # | Konu | Nasıl doğrulanır |
|---|---|---|
| ~~D-01~~ | ✅ **KAPANDI 2026-10-08** — DLL gerekmedi, `NetTrex.OptionsFX.Data.Core/OptFxCoreData.cs` kaynakta açık yazıyordu. Üyeler: `DateBasis · Currency · CurrencyPair · Chart · Point · Calendar · Holiday · HalfWorkingDay · FxRate · InterestRate · Volatility` | ColManagement 10 dilim alıyor (`Volatility` hariç) |
| D-02 | `sp_GetNewNumbers` modül DB'sine nasıl geliyor | Kurulum script'lerinde **yok**; DB projesinden (`TrexFramework`) deploy ediliyor olmalı |
| D-03 | Hangfire tablolarının runtime'da kurulduğu | Hiçbir kurulum script'inde yok |
| D-04 | `General:AvailableModules` nasıl güncelleniyor | Hiçbir script'te yok, elle yapılıyor olmalı |
| D-05 | MM `ProductDefinition` Create yolunun kırık olduğu | Kod-seviyesi çıkarım, runtime'da denenmedi |
