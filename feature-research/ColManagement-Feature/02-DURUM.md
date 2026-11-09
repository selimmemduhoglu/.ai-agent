# 02-DURUM.md — NEREDE KALDIK

> 🔴 **BU DOSYA CANLI DURUMUN TEK KAYNAĞIDIR.** Faz durumları, açık uçlar ve kullanıcının
> kendi sözleri burada. Plan dosyaları ([`00-YOL-HARITASI.md`](00-YOL-HARITASI.md),
> [`fazlar/`](fazlar/)) **statiktir** — durum oralarda tekrarlanmaz, iki kopya ayrışır.
>
> **Son güncelleme:** 2026-11-02 (V2 revize: backend + DB script v2 — progress/34 — **ve ardından
> UI (Annex+CollateralDefinition+TxnTransaction) de tamamlandı — progress/35**). Build (backend+UI)
> 0 hata; kullanıcı DB'yi v2 script setiyle sıfırdan kurup tarayıcıda deneyecek, sıradaki iş bu.
>
> 🔴 **Taşırken görülen açıklar DÜZELTİLMEZ** — MM (öncelikli) / OptionsFX'teki gibi aynen taşınır, açık
> [`03-HATA-KAYDI.md`](03-HATA-KAYDI.md)'ye numaralı yazılır (K-46). Kullanıcı geliştirme bitince bakacak.

---

## 🔴 ŞU AN

| | |
|---|---|
| 🔴 **2026-11-02 V2 revize** | Kullanıcı yeni analiz dokümanı (TRS-COL-FA-001 v0.2) + `Treasy_Collateral_Veri_Modeli.xlsx` + `Collateral_Demo.html` getirdi, mevcut koda uyarlanmasını istedi. Analiz → [`06-V2-REVIZE-ANALIZ.md`](06-V2-REVIZE-ANALIZ.md). 4 soru soruldu, kararlar K-58..K-61. **Backend (Data/Common/Api) tamamen yeniden yazıldı, tüm `.sln` 0 hata.** Tablo adları/kolonlar değişti: `Annex`→`CollateralAnnex`, `CollateralDefinition` düzleşti, `TxnTransaction`=başlık/`TxnTransactionDetail`=hareket (K-55 bu revizeyle koda geçti), yeni lookup'lar. **DB script seti v2** yazıldı (`Treasy.ColManagement/.ai-agent/outputs/2026-11-02-ColManagement-Kurulum-v2/`) — kullanıcı DB'yi silip bu setle kuracak. Kayıt → [`progress/34`](progress/34-v2-revize-backend-db.md). ✅ **UI de aynı oturumda tamamlandı** (Annex tek sayfa, Definition düzleşti+IsInterestCalculated/Fixed-Floating toggle, TxnTransaction 2 tab+Movement Preview popup) — `CollateralType` f-key ucu bu turda eklendi, SettlementType/PaymentInstructionType v1 TODO'su bağlandı. Build (backend+UI) 0 hata, tarayıcıda denenmedi → [`progress/35`](progress/35-v2-revize-ui.md) |
| **Güncel faz** | Faz 5 Backend temel yapısı ✅ · **repo rename → `Treasy.ColManagement`** ✅ (2026-10-11) · Docker/helm/gitignore audit ✅ · Opening muhasebe pipeline portu ✅ (tek-para-birimine çevrildi, 2026-10-14) · 4 numaralı iş (Consumer/Batch/Docker) ✅ · **PO toplantısı #3** ✅ (2026-10-12/13) — Annex/Definition/Transaction alan speki + Opening-Reverse muhasebe kararı kesinleşti · **Treasy.ColManagement.UI Faz 10+11** ✅ (2026-10-14) · **Annex + CollateralDefinition + TxnTransaction backend CRUD tamamı** ✅ (2026-10-14) · **Faz 4 (DB kurulum script'leri) YAZILDI** ✅ (2026-10-14, bkz. aşağıdaki satır) |
| **Son biten iş** | DB script'leri **MM'in gerçek kodu + canlı DB'siyle** tekrar doğrulandı (kullanıcı talimatı: "DerivSwp değil, MM ve OptionsFX'e göre"). Bulunan/düzeltilen gerçek hatalar: Calendar/Holiday'de MM'de olmayan `CalNo` kolonu silindi · `Currency.Pip` float→decimal(38,10) · 8 referans tablosunda eksik `NOT NULL` (StateId/StateMaker/StateDate) · `defJobCron.Id` IDENTITY oldu (MM'de IDENTITY+History ölçüldü) · **`ModulePrefix` 77→60** (canlı `NetTrexAcc.AccEntryMain` verisinde 77'nin NetTrex.InvFund tarafından zaten kullanıldığı bulundu) · `DefRefNumGen.TypeKey` 30→50 (gerçek SP parametresiyle uyumlu) · `sp_GetNewNumbers`/`sp_GetNewRefNumber` NetTrexMM'den birebir kopyalanıp script 7 olarak eklendi · FrameworkMenu `@parentMenuKey` **'TreasuryKey'** olarak doğrulandı (eski tahmin 'Treasury' yanlıştı) · `TxnTransactionFactory`'e MM'deki Trader fallback deseni eklendi. Ayrıca: `Treasy.ColManagement.sln`'deki yanlışlıkla eklenmiş `Treasy.MM.UI.Business/Core` proje referansları temizlendi · DI eksikleri (`ITxnTransactionFactory`, `IMarketDataCacheInvalidator`) giderildi · docker-compose şifre/secret placeholder'ları dolduruldu · ColManagement.UI'nin Docker build'i kıran 2 gerçek hata bulundu (`@types/jquery` eksik, `vitest` 0 testte patlıyordu) düzeltildi. **Sonuç: WebApi+ConsumerApi+BatchWebApi+UI 4'ü de ayakta ve sağlıklı.** |
| **2026-10-21 analiz + uyarlama** | INCI veri modeli (`INCI-Treasy_Collateral_Veri_Modeli.xlsx`) karşılaştırıldı → [`05-INCI-VERI-MODELI-KARSILASTIRMA.md`](05-INCI-VERI-MODELI-KARSILASTIRMA.md). Kullanıcı: *"Excel'in daha iyi olduğu yerler… al ve bizim daha iyi olduğumuz yerler içinde bizim ki kalsın… FloatingRateType ve benzeri tabloları al"*. **Uygulandı** (§4 madde 1/3/4/5): MM faiz parametre tabloları + CashTerms Id/kod kolonları · `AnnexMarginRule` → `AnnexId` · Txn/Detail SSI → MM ödeme snapshot bloğu · Detail `MarginType`. Backend+UI build 0 hata. Script: `Treasy.ColManagement/.ai-agent/outputs/2026-10-21-ColManagement-InciModelUyarlama/` (0→1→2→0) — 🔴 **kullanıcı çalıştıracak**. **Ertelendi:** madde 2 (başlıkta hareket yok, K-44) → tasarım soruları kullanıcıda. Onay bekleyen: MM'de olmayan seed `RateType 3 InterestFree` + `InterestMethodFrequency 7 OnReturn` → [`progress/28`](progress/28-inci-model-uyarlama.md) |
| **2026-10-22 ekran düzeltmeleri** | Kullanıcı lokalde açtı: `+` → `Cannot read properties of undefined (reading 'option') at populateDropdowns`, grid başlıkları key olarak görünüyor, "State" yerine MmTransaction'daki **Records to be listed** isteniyor. **Yapıldı:** popup `show()` editörlere erişimden önce (MM sırası, 3 ekran) · 3 ekranda eksik 54 localization key (en+tr) · MmTransaction State deseni (`StateHelper.Rates.GetFxRateWithParamStates(param,"MM")` + `_CustomStateFilter`) + backend `ApplyStateFilter`/`ApplyMakerCheckerStateFilter` (MM port) · UI Refit rotaları backend'e hizalandı (H-098 kapandı) + `annex/f-key`, `collateral-definition/f-key` yeni uçlar + Currency dropdown'ları. Build 0 hata. 🔴 **DB'de `Currency`/`Customer`/`Portfolio` BOŞ** → kopya script'i `Treasy.ColManagement/.ai-agent/outputs/2026-10-22-ColManagement-ReferansVeri/` (kullanıcı çalıştıracak). Seed'ler (InterestFree/OnReturn) kullanıcı: *"şimdilik kalsın"*. K-44 cevaplandı → **K-55** · [`progress/29`](progress/29-ekran-duzeltmeleri-state-filtre.md) |
| **2026-10-22 Annex UX turu** | Kullanıcı 11 madde: Annex **tab'sız tek ekran** (2×2 kart) · Direction/MarginType/Party/RoundingMethod **DB'den** (yeni 4 lookup tablosu, Id = enum değeri, iş kolonları değişmedi) · Product/SubProduct **Manuel Reeskont gibi** (MM API ürün tanımları) · ValidFrom varsayılan = mantıksal ayın 1'i · Included Yes/No · kopya script Msg 447 düzeltildi. Validator'lar `Handlers/`+`Validators/` klasörlerine ayrıldı. Rebuild backend+UI **0 hata**. 🔴 Kullanıcı koşacak: `2026-10-22-ColManagement-ReferansVeri` (düzeltilmiş) + `2026-10-22-ColManagement-LookupTablolari` → [`progress/30`](progress/30-annex-ekran-ux-lookup-tablolari.md) |
| **Bundan önceki iş** | `.ai-agent/outputs/2026-10-14-ColManagement-Kurulum/` — `NetTrexColManagement` DB'sini sıfırdan kuran tam script seti ilk yazımı (DerivSwp bazlı, bkz. yukarı — bu turda MM'e göre düzeltildi) → [`progress/21`](progress/21-db-kurulum-scriptleri.md) |
| 🔴 **K-54 (2026-10-14)** | **Security kapsam dışı — Faz 1 yalnız Cash.** Annex ProductScope/MarginRule CRUD (backend, Cash/Annex kapsamında) eklendi · `CollateralPosition` artık gerçekten çalışıyor: Create okur (CurrentBalanceBefore), Verify günceller (increase/decrease + Delete-verify'da ters çevirir), Get okur (CurrentBalance) — hepsi **Cash-only**. Bir tur Security-side backend yazılıp **aynı oturumda tamamen geri alındı**, detay → `bilgi-bankasi/07` K-54 |
| **Sıradaki adım** | Kullanıcı referans veri script'ini koşup ekranları test edecek (alan değişiklikleri test sırasında söylenecek) · `TxnTransactionDetail` akışı **K-55**'e göre (Verify sonrası hareket = Detail, Detail maker-checker, Detail başına fiş) |
| **Bloke eden** | Faz 4 (DB script) → `A-08`/`A-09`/`A-10` hâlâ açık. Muhasebe → `A-25` (nazım, bu toplantıda da konuşulmadı). `A-26` TxnPaymentInstruction şekli netleşti ama Fimple/manuel ayrımı **hâlâ** açık |
| **Bekleyen onay** | `A-09` sayaç öneki **77** önerildi · `A-25` nazım · `A-22` ⏸ ertelendi · **yeni:** entity isim/tip onayı (kullanıcı: *"ben isimlendiremelerine ve tiplerine baktıktan sonra da Db'ye script ile atarız"*) |
| ✅ **Klasör** | `Colleteral-Feature/` → **`ColManagement-Feature/`** (2026-10-09) — tüm referanslar güncellendi |
| ✅ **Ayakta** | 2026-10-15: WebApi (5061) + ConsumerApi (5063, Kafka'ya bağlı) + BatchWebApi (5062, Hangfire çalışıyor) + ColManagement.UI (5105, `/Login`'e dönüyor) — 4'ü de docker'da sağlıklı. DB `NetTrexColManagement` kullanıcı tarafından kuruldu (51 tablo + seed, doğrulandı) |
| 🔴 **UNIT TEST YOK** | Kullanıcı kararı. 13 test projesi boş iskelet |

## 1. Faz durumları

| Faz | Kapsam | Durum | Kayıt |
|---|---|---|---|
| **0** | Kimlik & isimlendirme | 🟡 Modül adı ✅ **ColManagement** (2026-10-08 toplantı). `A-08`/`A-09`/`A-10` bekliyor | [`bilgi-bankasi/10`](bilgi-bankasi/10-toplanti-2026-10-08.md) §1 |
| **1** | Repo iskeleti + MD omurgası | ✅ 2026-10-05 | [`progress/01-repo-iskeleti.md`](progress/01-repo-iskeleti.md) |
| **2** | Veri modeli — Excel **v5** | ✅ 2026-10-07 | [`progress/02-excel-v5.md`](progress/02-excel-v5.md) |
| **3** | **Backend iskeleti** | ✅ 2026-10-08 — 54 proje, build 0 hata | [`progress/04-backend-iskelet.md`](progress/04-backend-iskelet.md) |
| **4** | DB kurulum script'leri | ✅ **YAZILDI** 2026-10-14 — Excel silindiği için gerçek EF entity/config'lerden türetildi; kullanıcı henüz **çalıştırmadı** | `Treasy.ColManagement/.ai-agent/outputs/2026-10-14-ColManagement-Kurulum/CREATION_SCRIPT.md` (farklı repo, workspace dışı) |
| **5** | Backend temel yapısı | ✅ **TAMAM** 2026-10-08 · 🔄 2026-10-09 OptionsFX'e hizalandı (K-39) | [`progress/05`](progress/05-backend-altyapi.md) · [`06`](progress/06-auth-fimple-consumer.md) · [`07`](progress/07-mm-tabani-ve-loglama.md) · [`08`](progress/08-temel-yapi-tamam.md) · [`09`](progress/09-optionsfx-hizalama.md) |
| **6** | Annex ucu | ✅ **TAMAM** 2026-10-14 — Entity+EF config+Repository+9 Handler+Controller (Select/Get/Create/Update/Delete/Verify/Reject/Undo/History) | [`progress/18`](progress/18-verify-ui-iskelet-annex-crud.md) |
| **7** | CollateralDefinition ucu | ✅ **TAMAM** 2026-10-14 — Entity+EF config+Repository+9 Handler+Controller (Select/Get/Create/Update/Delete/Verify/Reject/Undo/History), Annex deseni birebir | [`progress/19`](progress/19-definition-transaction-crud.md) |
| **8** | TxnTransaction + bakiye | 🟡 Entity+EF config+**8 Handler/Controller ✅** (Select/Get/DetailList/Create/Update/Delete/Verify/Reject — Undo yok, FlowEntity deseni) · **`CollateralPosition` artık gerçekten çalışıyor** (Create okur, Verify günceller, Get okur) 2026-10-14, Cash-only (K-54) · `TxnTransactionDetail` yazılmadı (A-27 açık, K-44 beklemede) · Select state filtresi ✅ (2026-10-22, `ApplyStateFilter`) | [`progress/20`](progress/20-annex-grid-ui-security-geri-alma.md) |
| **9** | Değerleme · Limit · Muhasebe · Mesaj | 🟡 Muhasebe: Opening ✅ (tek-para-birimli, 2026-10-14) + Opening-Reverse ✅ (`Accounting/Delete`), reeskont/maturation/ara ödeme **yok** (K-48) · Değerleme/Limit/Mesaj ⬜ | [`progress/18`](progress/18-verify-ui-iskelet-annex-crud.md) |
| **10** | UI iskeleti | ✅ **TAMAM** 2026-10-14 — `Treasy.ColManagement.UI` (Core/Business/Web + Docker), MM.UI güncel (`Treasy.Pure.*`) emsal alındı | [`progress/18`](progress/18-verify-ui-iskelet-annex-crud.md) |
| **11** | UI ekranları | ✅ **TAMAM** 2026-10-14 — Annex/CollateralDefinition/TxnTransaction + **Annex Product Scope/Margin Rule grid'leri** (aynı gün eklendi, DevExtreme popup-edit mode, Add-modal yerine), build+typecheck 0 yeni hata | [`progress/20`](progress/20-annex-grid-ui-security-geri-alma.md) |
| **12** | Uçtan uca + teslim | ⬜ | — |

---

## 2. 🔴 Açık uçlar

### Kullanıcı cevaplayacak — artık Faz 4'ü BLOKE ETMİYOR (kodda zaten kullanılan değerle yazıldı, onay yine de bekleniyor)
| # | Soru | Öneri / fiilen kullanılan |
|---|---|---|
| **A-08** | Modül kodu | **`CM`** (MM=`MM`, DerivSwp=`DV`) — kod iskeletinde kullanılıyor, script'lerde (`2-4-6`) de **`CM`** yazıldı |
| ~~A-09~~ | `DefNumberGen` sayaç öneki | ✅ **60** (2026-10-15 düzeltildi) — eski değer **77** canlı `NetTrexAcc.AccEntryMain` verisinde NetTrex.InvFund tarafından zaten kullanılıyordu (çakışma), `NumberGeneratorDataManager.cs` güncellendi |
| **A-10** | DB adı | **`NetTrexColManagement`** — `docker-compose.override.yml`'de zaten bu, script'ler de bunu kullanıyor |
| **—** | Tablo adlandırma onayı | `ColManagementRevaluation` **düştü** (Revaluation silindi, K-41). Kalan tek: `ColManagementAuditLog` |
| ~~—~~ | ~~Modül adının nihai onayı~~ | ✅ **ColManagement** — patron toplantısı 2026-10-08 (K-42) |

### Patron toplantısından doğanlar — Excel v6'yı ve muhasebeyi etkiliyor
`A-22` ⏸ ertelendi · ~~`A-23`~~ ✅ Fimple kullanılıyor · `A-24` MarginRule ayrı tablo mu Annex'te
8 kolon mu · `A-25` nazım bacağı · `A-26` ödeme manuel mi disable mı · `A-27` Detail kolonları →
[`bilgi-bankasi/10`](bilgi-bankasi/10-toplanti-2026-10-08.md) §8

### İş birimi toplantısında sorulacak — Faz 6-9'u etkiliyor
`A-13` limit servisi faz-1'de mi · `A-14` confirmation mesajı üretilecek mi · `A-15` dinamik kural
motoru (Threshold/MTA sabit kolon mu, kural ifadesi mi) · `A-20` DisputeTolerance zorunlu mu ·
`A-21` Annex `ProductCode`/`SubProductCode` hangi katalogdan ·
`A-12` mesaj tabloları Collateral'da mı ortak yerde mi · `A-18` Security/SSI/Account/Rating master'ları nerede

### Ölçülecek (kod/DLL/DB'den)
| # | Konu |
|---|---|
| ~~A-11 / D-01~~ | ✅ **KAPANDI** — `OptFxCoreData.cs`'ten okundu. Üyeler: `DateBasis · Currency · CurrencyPair · Chart · Point · Calendar · Holiday · HalfWorkingDay · FxRate · InterestRate · Volatility`. ColManagement **10 dilim** alıyor (`Volatility` hariç) |
| **D-02** | `sp_GetNewNumbers` modül DB'sine nereden geliyor (kurulum script'lerinde **yok**) |
| **D-03** | Hangfire tabloları runtime'da mı kuruluyor |
| **D-04** | `General:AvailableModules` nasıl güncelleniyor (hiçbir script'te yok) |

Tam liste + gerekçeler → [`bilgi-bankasi/07-kararlar-ve-sorular.md`](bilgi-bankasi/07-kararlar-ve-sorular.md)

---

## 3. 🔑 Kullanıcının kendi sözleri (compact'te EN ÇOK bunlar kayboluyor)

> Özetleme bunları yeniden ifade eder ve niyet kayar. **Birebir** saklanıyorlar.

| Tarih | Söz | Sonucu |
|---|---|---|
| 2026-10-14 | *"NetTrexColManager için backend ve Frontend kodları yazdık ya artık script yazma zamanına geldik... Ornek_Deriv_Scripts_DDL bu kurulum scirtplerine bak ve DB de şu an NetTrexColManager Db'si yok bu Db yi kurmamız lazım sonra da önceden konuştuğumuz gibi ortak Tabloları da Create etmemiz lazım sonra da ColManager için belirlediğimiz tabloları da Configuration'alra göre tabloları İnsert edecek tabloları yaz... biz çok defa bu scirtpler üzerinde değişiklik yapıcaz bu yüzden de CREATION_SCRIPt diye bir md dosyan olsun"* | DB kurulum script seti + `CREATION_SCRIPT.md` yazıldı (bu satır) — "ortak tablolar" = Faz-4 Grup B (CoreDataSlice paket kopyaları + Customer/Portfolio/CorporateType/…), Excel yerine **gerçek EF kod** kaynak alındı |
| 2026-10-14 | *"Security ile alakalı hiç bir geliştirme yapmana gerek yok istemiyorum gerek olmadığına kanaat getirdik"* → *"security kısımlarını istemiyorum onlardan vazgeçtik bu dediğimi md'lerde de değiştirebilirsin sadece Cash yapısıyla devam edicez"* | `K-54` — Security tamamen kapsam dışı, Faz 1 yalnız Cash |
| 2026-10-13 | *"Openin tarafını yazmıştın ya reeskont, maturation ve ara ödeme olmayacak ama opening fişinin reverse'ü kesilecek bu yüzden de reverse'ü de entegre et burada ki Accounting yapısına sonra da entity ve configuration'ları yazmaya başla bağlantıları ile birlikte."* | `K-48` — muhasebede yalnız Opening+Reverse |
| 2026-10-13 | *"DB'ye script yazmayacağız ama Entity'lerini oluşturabiliriz, sonra ben isimlendirmelerine ve tiplerine baktıktan sonra da DB'ye script ile atarız. Configuration ve entity'lerini yazmaya başlayalım bence."* | Entity/config yazımı **onaylı**, DB script **sonra**, isim/tip onayı **kullanıcıdan bekliyor** |
| 2026-10-13 | *"Collateral Annex, Collateral Definition ve Collateral Transaction... bunlar aslında 3 ayrı ekran olacak bunlar 1 ekranın tab'i olmayacak bunu söyleyeyim baştan."* | 3 ayrı ekran, tab değil → `11-ui-ekran-rehberi.md` |
| 2026-10-13 (PO) | *"Bu draft gereksiz bence. Active inactive gibi mi kalacak burası?"* · *"Hayır biz onu increase ve decrease diyeceğiz."* · *"Delete ettikten sonra verify edince ne olacak? Tersine dönecek."* · *"Burada o zaman logical date'le bakacaksın sen... değilse fiş kesmeyeceğim."* | `K-50`/`K-51`/`K-48`/`K-49` |
| 2026-10-11 | *"ben MM-OptionFx-Deriv ve ColManagement için bizim şu an kullandığımız mimariyi kullanıyorum… Aret Abi… projelerin tüm modüllerin standart bir hale getirmek için bu mimariyi kullanalım dedi… ben zaten şu anki ColManagement projesinin mimarisinde devam edeceğim… hangisinin daha iyi ve daha kötü olduğu noktalar hangileri"* | `04-MIMARI-KARSILASTIRMA.md` |
| 2026-10-09 | *"MM'de helm nasılsa ya da Docker dosyaları nasılsa sen de buraya aynı şekilde koy… MM projesiyle karşılaştır bakalım gerçekten bitmiş mi, biz doğru yansıtmış mıyız"* | `progress/16` |
| 2026-10-09 | *"routing adları da Option'dan alınsın? senin bu şekilde bunlar nereden alınsın diye sormanı sevdim sor bana. UI'da da adları aynı şekilde Option'dan alabilirsin ama dediğin gibi UI'a geçince konuşalım"* | `K-47` route = OptionsFX · MM/OFX farkında **sor** |
| 2026-10-09 | *"Consumer tarafını tamamen bitir sonra da Data ve Common projelerini yapacaksın… MM ve Option'da kullanılan ve bende de kesinlikle kullanılacakları al… sonra da Common'daki Accounting yapısını alırsın. Backend projesini bir düzenleyelim sonra da UI projesine de biraz bakarız"* | `progress/13` — MM ∩ OFX kuralı |
| 2026-10-09 | *"Bildirdiğim ama dokunmadıklarım bu tip noktaları ayrı bir dosyada tutar mısın… hem yavaşlamamak hem de neden bu şekilde yapıldığını bilmiyorum, belki bilinçlidir belki bilinçsizdir; sen MM ve Option'daki gibi yap, MM'i önceliklendirerek aynısını geçir gitsin… ben sonra bakacağım ve mantıklı olanları yapacağız"* | 🔑 `K-46` → [`03-HATA-KAYDI.md`](03-HATA-KAYDI.md) |
| 2026-10-09 | *"Kafanın karıştığı yerlerde MM ne yaptıysa onu yapmanı istiyorum… ben MM projesinde hiç sorunlarla karşılaşmadım, kafan karışınca MM kodlarını kullan. Accounting tarafı Option'daki gibi olsun… Option'unki bir design pattern daha ekleyerek daha iyi hale getirmiş"* | 🔑 `K-45` |
| 2026-10-09 | *"AddQuant… bu option/fx için yazılmamış mı bizim bunu kullanmamız mantıklı mı… MM tarafında biz bunu nasıl çözmüşüz"* · *"DateTime.Now yerine DateTimeProvider… nereden besleniyor… saat farklı olan müşterilerimiz var"* | `progress/11` §1-2 |
| 2026-10-09 | *"sorun gördüğün yerleri de fix'le radikal olmayacak şekilde çünkü başka sorunlar oluşabilir"* | Küçük, yerel düzeltme |
| 2026-10-09 | *"Fimple tamamiyle kullanılacak onu yanlış anlamışsın sadece Ödeme mesajlarını biz kendi tarafımızda mı yapıcaz yoksa Fimple'da mı yapılacak anlamında ki konuşmaydı o… Sen altyapıdan yazmaya devam et konuştuğumuz gibi"* | `K-43`; altyapı portu → `progress/10` |
| 2026-10-09 | *"3 tane ekranımız olacak… Txn ekranında her işlem için işleme girip edit yapılmayacak, TxnDetail olacak ve o detail'a yansıyacak yani ana Txn hiç değişmeyecek ve her işlem TxnDetail'da değişecek"* | 🔑 `K-44` — işin özü · tahta `bilgi-bankasi/10` §6b |
| 2026-10-09 | *"Ödeme mesajları işine girişirsek ColManagement modülü geliştirmesini de geçer… bizim tarafa ödeme mesajı diye bir alan koyabiliriz… alanı true yaparlar ve kaydedilirse ödeme mesajı gitmiştir diyebiliriz şimdilik"* | `A-26` |
| 2026-10-09 | *"Scaffolding bu konu bir dursun sonra bakıcaz"* · *"ColManagement olsun karar verdiğimiz gibi"* | `A-22` ⏸ · `K-42` |
| 2026-10-09 | *"bu bulduğun açıkları OptionFx'te bakıp orada da var mı sonra da MM'de bakıp orada da var mı demen de çok güzel mantıklı"* | Taşırken bulunan her açık **iki repoda** kontrol edilip tabloya yazılır |
| 2026-10-09 | *"Accounting, Consumer, Auth, Keycloak ve dependency ve reference ve projeleri OptionFX projesindeki gibi yap… Seq loglamaları MM'deki gibi olsun, onun dışındaki her yer OptionFx'teki gibi olsun… geçirirken de hatalı gördüğün ya da boşluk gördüğün yerleri de bana bildirip düzelt. Radikal değişiklikler yapma ama küçük düzeltmelerle toparla, çok sıkıntılı ise bana haber ver"* | `K-39` → [`progress/09`](progress/09-optionsfx-hizalama.md) |
| 2026-10-09 | *"modülün ismi kesinlikle ColManagement oldu yani artık Collateral olmayacak hiç bir yerde… Col kelimesi collateral kısaltması olduğu için Management'teki M büyük olmalı"* | `K-42` |
| 2026-10-09 | *"Annex tablosu mantıklı, Annex ProductScope mantıklı da AnnexMarginRule kısmında Product scope'a bağlı olması ve buna ihtiyaç olunmasını tam anlayamadılar… Şimdilik tablolar kesin değil o yüzden de tabloları şimdilik bırakalım ve geriye kalan işleri yapalım"* | `A-24`; entity/repo bekliyor |
| 2026-10-08 (patron) | *"Annex'in tanımlarından başlayın, database'leri bir tanımlayın"* · *"Revaluation falan yok"* · *"History değil, change — giden gelen bir şey"* · *"Fimple burada hiç olmayacak"* | [`bilgi-bankasi/10`](bilgi-bankasi/10-toplanti-2026-10-08.md) |
| 2026-10-08 | *"bu modülün ismini de Collateral değilse **ColManagement** olarak belirledik son kez bundan sonra bu modüle bu isimle hitap edip oluşturulacak tablolar ve kodları buna göre ayarla"* | Modül adı sabit → [`01-KIMLIK.md`](01-KIMLIK.md) |
| 2026-10-08 | *"OptionsFX yapısı ve kodları MM'den daha safe ve güncel ama ben MM'i daha iyi bildiğim için demiştim; yeni modül yazdığımız zaman **zayıf hatlarının olmamasını** istediğim için Consumer'ı da OptionsFX'ten alabilirsin"* | `K-37` |
| 2026-10-08 | *"Accounting yapısını Option'dan alıp geriye kalanını MM'den al, ama alırken sistemi ve kodları **daha iyi hale getirerek** almanı istiyorum çünkü tüm yapıyı görerek alıyorsun"* | `K-33` |
| 2026-10-08 | *"ben 1,5 yıldır MM'de geliştirme yapıyorum, Seq yapısını güzel bir hale getirdim… Seq'ten daha rahat search ettiğim zaman logları daha rahat görebileceğim bir şekilde log sistemini daha güzel bir hale getirebiliyorsak getirelim"* | `K-34` |
| 2026-10-08 | *"projelerin appsettings'leri var, orada aynı parametreler isimlendirilirken bile farklı isimlendirilmiş, sonra da ben bunları docker-compose override'ta kullanıyorum — aynı olsun tüm projelerde"* | `K-35` |
| 2026-10-08 | *"ColManagement geliştirmesinde çok çok gerekmediği sürece yorum satırı yazma"* | Yorumlar budandı; yalnız yorumlanmış kod satırları + koddan çıkarılamayan tek satırlık uyarılar kaldı |
| 2026-10-08 | *"Unit testler şimdilik kalsın tüm projeyi yazdıktan sonra unit testleri yazıcaz ben sana söylicem zaten, hiç bir şekilde unit testlere zaman harcayamayız"* | `K-30` |
| 2026-10-08 | *"OptionFx'in kendi için yazdığı bize uygulanmasına gerek olmayan configuration'larını da yaz ama yorum satırı halinde bırak"* | `K-31` |
| 2026-10-08 | *"`// Faz 9:` yazmışsın ya bunları en son sileriz değil mi, tüm kodu yazdıktan sonra; şimdilik sen daha iyi kodu yazman için referans olabilir"* | `// Faz N:` yorumları geçici |
| 2026-10-08 | *"tüm temel yapıyı bitir, ondan sonra Controller'lardan başlayıp, tabloları kesinleştirince de entity'lerden repolarla başlarız"* | Faz 6 sırası: temel → controller → (tablolar kesinleşince) entity/repo |
| 2026-10-08 | *"DbScriptlerinden önce backend iskeletini yapalım yerlerini değiştirdim"* | Faz 3 ↔ 4 yer değiştirdi |
| 2026-10-08 | *"şu anlık excel bir kalsın sonra değiştiriz ama sen kod yapısını ColManagement'e göre yap, sonra da ben patronla toplantıdan sonra kesinlikle ama kesinlikle isim bu oldu ve tüm kod, repo ismi, tablo isimleri falan hepsini buna göre yap diyeceğim"* | Kod **şimdiden** ColManagement; Excel v6 toplantı sonrası |
| 2026-10-08 | *"bu yapay zeka dosyalarını atmayacağım sadece localde kalacak, git takip etmesin"* | `.ai-agent/` · `CLAUDE.md` · `.claude/` **iki repoda da** gitignore'da |
| 2026-10-08 | *"burada da işlem oluşturmalar, muhasebe oluşturma işleri olacağı için temelde diğer dediğim modüllerin çok benzeri olacak ama içerde business değişecek"* | 🔑 **Yapı aynı, logic farklı** — OptionsFX/MM katman akışı birebir alınır |
| 2026-10-08 | *"ben her compact dediğim zaman sen sıkıştırınca içerdeki önemli detayların kaybolmasını istemiyorum"* | Bu dosya + §5 compact protokolü |
| 2026-10-07 | *"her excel güncellemende versiyonu 1 arttır"* | Excel v+1 + yeni dosya adı kuralı |
| 2026-10-07 | *"Transaction modeli için dökümanı baz alıp ses kaydının transcript'i ile harmanlayarak çıktı oluşturucaz"* | `K-25` |
| 2026-10-07 | *"Ana tablomuz **TxnTransaction** olsun"* | `K-18` |
| 2026-10-07 | *"security tablosu da Faz 1'de kurulsun"* | `K-21` |
| 2026-10-07 | *"dökümanda verilen tablolar ve kolonlar ne kadar doğru bilmiyorum ama biz de bu tablolar ve kolonları **mantıklı bir şekilde** oluşturup, tiplerini, ayarlamalarını, birbirleriyle bağlantılarını, sp'lerini, fonk'larını, key'lerini hazırlamamız lazım"* | Doküman körü körüne alınmaz, mantıklı hâle getirilir |
| 2026-10-07 | *"ben sana Deriv scriptlerini attım ama o scriptlerden bizim için önemli olan **Kurulum Scriptleri** klasörü altında olanlar"* | Faz 3 şablonu |
| 2026-10-05 | *"bu işi fazlandırmanı istiyorum"* · *"md dosyalarına step by step yaz"* | Bu yapı |
| 2026-10-01 | *"commitleri ben atıcam sen hiç bir zaman commit atmayacaksın"* | Claude commit/push/PR yapmaz, **önermez de** |
| 2026-09-29 | *"çok yazıyorsun"* (kod yorumu) | Yorum nadir ve kısa, `<remarks>` yok, "PO kararı" referansı **hiç** yok |
| 2026-10-02 | *"ben Primary key olan Id'leri **long** olarak oluşturmak zorundayım"* · *"**float ve double** alan da kullanmıyorum **decimal** kullanıyorum"* | `K-05`, `K-06` |

---

## 4. Son kararlar (kronolojik, en yeni üstte)

| Tarih | Karar | Nerede |
|---|---|---|
| 2026-10-13 | `K-48`..`K-53` — PO toplantısı #3: Opening+Reverse dışında muhasebe yok · forward batch yok (Verify valör kontrolü) · Status 2 seçenekli · Direction sabit enum · CashTerms'ten settlement/account çıktı · Annex/Definition verify-sonrası-edit kuralı. `A-21`/`A-24` kapandı | [`bilgi-bankasi/11-ui-ekran-rehberi.md`](bilgi-bankasi/11-ui-ekran-rehberi.md) · [`bilgi-bankasi/07`](bilgi-bankasi/07-kararlar-ve-sorular.md) |
| 2026-10-09 | 🔑 **K-45 Belirsizlikte MM:** Seq → MM · Accounting → OptionsFX · proje/paket → OptionsFX · OptionsFX'in kütüphaneye yaslandığı/kafa karıştıran yer → **MM**. İlk uygulama: QuGet çıktı, takvim MM | [`progress/11`](progress/11-mm-takvim-ve-quget.md) |
| 2026-10-09 | 🔴 **K-43** Fimple tamamen kullanılıyor (A-23 kapandı) · 🔑 **K-44** Txn değişmez, her hareket TxnDetail | [`bilgi-bankasi/10`](bilgi-bankasi/10-toplanti-2026-10-08.md) §6/§6b |
| 2026-10-09 | OptionsFX altyapısı taşındı; 18 açık (çift-repo kontrollü) düzeltildi — sayaç öneki 77 önerisi, Hangfire anahtarları `ColManagementEod/Bod` | [`progress/10`](progress/10-optionsfx-altyapi-portu.md) |
| 2026-10-09 | 🔴 **K-39 Seq/Serilog MM'den, geri kalan her şey OptionsFX'ten** — K-33 ve K-37'nin **yerine geçer**. Csproj/referans/paket zaten birebirdi (fark 0); Startup ×3, Auth/Fimple, Data/Batch DI OptionsFX'e çevrildi; OptionsFX'in 15 açığı düzeltildi (çift Kafka bus, sızan scope, PostgreSql, tatil kontrolü, log'lanmayan istisna…) | [`progress/09`](progress/09-optionsfx-hizalama.md) |
| 2026-10-09 | **K-40** Master-detail `TxnTransaction` + `TxnTransactionDetail` (K-25 yerine) · **K-41** `CollateralRevaluation` silindi · **K-42** ad yazımı `ColManagement` | [`bilgi-bankasi/07`](bilgi-bankasi/07-kararlar-ve-sorular.md) |
| 2026-10-08 | ~~🔑 K-37 Kaynak seçim ilkesi~~ → **K-39 ile değişti**: OptionsFX ölçülebilir biçimde daha güvenli/güncelse **OptionsFX**; kullanıcının bilinçle oturttuğu şeyde (Seq log biçimi, Swagger) **MM**; eşitse MM; ikisi de kusurluysa **düzelterek al** | [`progress/08`](progress/08-temel-yapi-tamam.md) §1 |
| 2026-10-08 | **K-38** Dockerfile'daki `COPY` listesi **elle değil çözüm ağacından üretildi** (Api 26 · Batch 27 · Consumer 28 proje). MM'de elle bakılıyor ve proje eklenince sessizce bayatlıyor | aynı §2 |
| 2026-10-08 | **K-33** Taban **MM**, yalnız **Accounting + pipeline OptionsFX**'ten. Alırken 8 kusur düzeltildi (düz metin kimlik bilgisi, ölü kod, `EnableSensitiveDbLogs`, null kontrolü…) | [`progress/07-mm-tabani-ve-loglama.md`](progress/07-mm-tabani-ve-loglama.md) |
| 2026-10-08 | **K-34** Loglamada 9 açık kapatıldı — hepsi **konfigürasyon**, yeni paket yok. En önemlisi `WithMachineName`/`WithEnvironmentName`: *"bu log'u hangi process yazdı"* sorusu 2026-09-04'te yanlış kök-neden üretmişti | `.ai-agent/reference/logging.md` |
| 2026-10-08 | **K-35** Üç projenin `appsettings` **anahtar seti birebir aynı** (56/56). MM'de aynı değer iki ayrı adla set ediliyordu | `.ai-agent/reference/configuration.md` |
| 2026-10-08 | **K-36** 🔴 Consumer **OptionsFX'te kaldı** (KafkaFlow + CoreDataSlice). MM'inkinde `async void`, thread-per-topic, `throw ex`, üç kez `Build()`; ayrıca 110 dosya vs 36 | [`progress/07`](progress/07-mm-tabani-ve-loglama.md) §4 |
| 2026-10-08 | 🔴 **K-30 UNIT TEST YAZILMIYOR** — tüm proje bitene kadar. 13 test projesi boş iskelet duruyor; kullanıcı haber verince yazılacak | [`progress/06-auth-fimple-consumer.md`](progress/06-auth-fimple-consumer.md) §5 |
| 2026-10-08 | **K-31** OptionsFX'in bize gerekmeyen konfigürasyonları **silinmedi, yorum satırında** bırakıldı (referans olsun diye). `// Faz N:` yorumları proje bitince **silinecek** | aynı §4 |
| 2026-10-08 | **K-32** OptionsFX'ten alırken 2 ölçülmüş tuzak düzeltildi: `client_secret` log maskesi + JSON olmayan hata gövdesi guard'ı | aynı §2 |
| 2026-10-08 | **K-29** `CoreDataSlice` = 10 dilim (`Volatility` hariç — opsiyon fiyatlaması yok). Liste hem DbContext'i hem Kafka topic'lerini besliyor | [`progress/05-backend-altyapi.md`](progress/05-backend-altyapi.md) |
| 2026-10-08 | **K-26** 🔄 K-01 revize: OptionsFX'ten **dosya kopyalanmadı**, yapı **ölçülüp üretildi** — parola/ölü kod/kalıntı riski tamamen kalktı | [`progress/04-backend-iskelet.md`](progress/04-backend-iskelet.md) |
| 2026-10-08 | **K-27** Tüm gruplar (Batch·Consumer dahil) şimdi kuruldu — zincir mimarinin kendisi, boş csproj bedava | aynı |
| 2026-10-08 | **K-28** `NuGet.config` **OptionsFX'ten** (MM'de `TreasyNuget` feed'i yok → `Treasy.QuGet` restore edilemezdi) | aynı |
| 2026-10-08 | Faz **3 ↔ 4** yer değiştirdi: backend iskeleti script'ten önce | [`00-YOL-HARITASI.md`](00-YOL-HARITASI.md) §3 |
| 2026-10-08 | Modül adı **ColManagement**; tablo adında `Collateral`=domain, `ColManagement`=modül kimliği | [`01-KIMLIK.md`](01-KIMLIK.md) §3 |
| 2026-10-08 | İşin ana evi **workspace** `ColManagement-Feature/`; repo-içi `.ai-agent`'ler ince pointer | [`00-YOL-HARITASI.md`](00-YOL-HARITASI.md) §6 |
| 2026-10-07 | `K-18`…`K-25`: `TxnTransaction` · `Def` öneki düştü · 1:N yardımcılar `Txn*` · `CollateralRevaluation` · Security faz-1'de · CashTerms kalır · `ProductDefinition` eklendi · `MarginType=ALL` **enum'a eklenmedi** | [`bilgi-bankasi/07-kararlar-ve-sorular.md`](bilgi-bankasi/07-kararlar-ve-sorular.md) |
| 2026-10-07 | `K-01` **revize**: OptionsFX'ten **dosya kopyalanacak** (eski itiraz "sırlar TFS geçmişine girer" düştü — `git clone` yapılmıyor) | [`fazlar/faz-3-backend-iskelet.md`](fazlar/faz-3-backend-iskelet.md) |
| 2026-10-05 | İş sırası: **Excel → script → backend → EN SON UI**. Kod script'ten önce yazılmaz | [`00-YOL-HARITASI.md`](00-YOL-HARITASI.md) §3 |

---

## 5. 🔴 COMPACT PROTOKOLÜ

Kullanıcı *"compact"* dediğinde ya da bağlam ~%70'e geldiğinde — **sıkıştırmayı bekleme**:

| Sıra | Ne yapılır |
|---|---|
| **1** | 🔴 **Bu dosyayı (`02-DURUM.md`) güncelle** — ŞU AN bloğu, faz tablosu, açık uçlar, yeni çıkan kullanıcı sözleri |
| **2** | Yarım kalmış iş varsa ilgili `fazlar/faz-N-*.md` dosyasına **nerede kalındığını** yaz |
| **3** | `<repo>/.ai-agent/compacts/<chat-slug>/compact-<n>.md` — **yeni numaralı** dosya (öncekilere dokunma). İçine: çalıştırılan komutlar, **hatanın birebir metni**, karar gerekçeleri, ölçüm çıktıları |
| **4** | Anlamlı iş bittiyse `progress/NN-*.md` (append-only) |

### Compact özetine ASLA güvenilmeyecek şeyler
Özet bunları yeniden ifade eder ve **anlam kayar** — bu yüzden dosyaya yazılır:

- **Kullanıcının birebir cümleleri** → §3
- **Hata mesajlarının tam metni** → `compacts/`
- **Ölçüm çıktıları** (hangi sorgu, hangi sonuç) → `bilgi-bankasi/04-db-envanteri.md` + `sql-log/`
- **Bir kararın NEDEN alındığı** (alternatifi ve neden reddedildiği) → `bilgi-bankasi/07`
- **Çürütülmüş hipotezler** ("bu bakılacak yer değil") → `bilgi-bankasi/08-tuzaklar.md`
- **Yarım kalan işin tam olarak nerede kaldığı** → §ŞU AN + faz dosyası

---

## 6. Yeni bir sohbete başlarken — 4 adım

1. **Bu dosyayı oku** → nerede kaldığımızı öğren
2. [`00-YOL-HARITASI.md`](00-YOL-HARITASI.md) → iş ne, kurallar ne
3. İlgili [`fazlar/faz-N-*.md`](fazlar/) → o fazın adımları ve tuzakları
4. Faz dosyasının *"Önce oku"* bölümündeki **1-2** bilgi dosyası
   (🔴 [`bilgi-bankasi/`](bilgi-bankasi/)'nın onunu birden **okuma**)
