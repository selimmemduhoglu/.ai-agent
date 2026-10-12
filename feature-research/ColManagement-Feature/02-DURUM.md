# 02-DURUM.md — NEREDE KALDIK

> 🔴 **BU DOSYA CANLI DURUMUN TEK KAYNAĞIDIR.** Faz durumları, açık uçlar ve kullanıcının
> kendi sözleri burada. Plan dosyaları ([`00-YOL-HARITASI.md`](00-YOL-HARITASI.md),
> [`fazlar/`](fazlar/)) **statiktir** — durum oralarda tekrarlanmaz, iki kopya ayrışır.
>
> **Son güncelleme:** 2026-10-09
>
> 🔴 **Taşırken görülen açıklar DÜZELTİLMEZ** — MM (öncelikli) / OptionsFX'teki gibi aynen taşınır, açık
> [`03-HATA-KAYDI.md`](03-HATA-KAYDI.md)'ye numaralı yazılır (K-46). Kullanıcı geliştirme bitince bakacak.

---

## 🔴 ŞU AN

| | |
|---|---|
| **Güncel faz** | **Faz 5 — Backend temel yapısı ✅** + OptionsFX hizalaması ✅ + **OptionsFX altyapı portu** ✅ (2026-10-09). 54 proje · 250 `.cs` · build **0 hata** |
| **Son biten iş** | Push: `main-creation-branch` → **`Treasy.ColManagement`** (eski `NetTrex.Collateral` sunucuda yok; TF401019). Mimari karşılaştırma A (bizim) ↔ B (Aret/FI şablonu) → [`04-MIMARI-KARSILASTIRMA.md`](04-MIMARI-KARSILASTIRMA.md). Kullanıcı: ColManagement **bizim mimariyle** devam |
| **Sıradaki adım** | Tablodan bağımsız backend işi **bitti** (A ✅ · B ✅). Kalan hepsi tablo/iş kararına bağlı: Annex/Collateral/Txn+TxnDetail entity → uçlar → TxnDetail muhasebe olayı · grid filtreleri · Reconciliation/DailyFlow · EOD batch item'ları · Faz 4 DB script'leri. UI fazında route/ad kararı (K-47: OptionsFX) |
| **Bloke eden** | Excel v6 → `A-24` (MarginRule) · `A-27` (Detail kolonları) · Faz 4 → `A-08`/`A-09`/`A-10` · Muhasebe → `A-25` (nazım) · `A-26` (ödeme) |
| **Bekleyen onay** | `A-09` sayaç öneki **77** önerildi · `A-26` ödeme bayrağı · `A-24` MarginRule · `A-25` nazım · `A-22` ⏸ ertelendi |
| ✅ **Klasör** | `Colleteral-Feature/` → **`ColManagement-Feature/`** (2026-10-09) — tüm referanslar güncellendi |
| ⚠️ **Doğrulanmadı** | Hiçbir servis **ayağa kalkmadı** — DB · Kafka · Redis · Seq yok. Derleniyor, çalıştırılmadı |
| 🔴 **UNIT TEST YOK** | Kullanıcı kararı. 13 test projesi boş iskelet |

## 1. Faz durumları

| Faz | Kapsam | Durum | Kayıt |
|---|---|---|---|
| **0** | Kimlik & isimlendirme | 🟡 Modül adı ✅ **ColManagement** (2026-10-08 toplantı). `A-08`/`A-09`/`A-10` bekliyor | [`bilgi-bankasi/10`](bilgi-bankasi/10-toplanti-2026-10-08.md) §1 |
| **1** | Repo iskeleti + MD omurgası | ✅ 2026-10-05 | [`progress/01-repo-iskeleti.md`](progress/01-repo-iskeleti.md) |
| **2** | Veri modeli — Excel **v5** | ✅ 2026-10-07 | [`progress/02-excel-v5.md`](progress/02-excel-v5.md) |
| **3** | **Backend iskeleti** | ✅ 2026-10-08 — 54 proje, build 0 hata | [`progress/04-backend-iskelet.md`](progress/04-backend-iskelet.md) |
| **4** | DB kurulum script'leri | ⬜ **SIRADAKİ** — Excel'i ve Faz 0 kararlarını bekliyor | — |
| **5** | Backend temel yapısı | ✅ **TAMAM** 2026-10-08 · 🔄 2026-10-09 OptionsFX'e hizalandı (K-39) | [`progress/05`](progress/05-backend-altyapi.md) · [`06`](progress/06-auth-fimple-consumer.md) · [`07`](progress/07-mm-tabani-ve-loglama.md) · [`08`](progress/08-temel-yapi-tamam.md) · [`09`](progress/09-optionsfx-hizalama.md) |
| **6** | Annex ucu | ⬜ | — |
| **7** | CollateralDefinition ucu | ⬜ | — |
| **8** | TxnTransaction + bakiye | ⬜ | — |
| **9** | Değerleme · Limit · Muhasebe · Mesaj | ⬜ | — |
| **10** | UI iskeleti | ⬜ | — |
| **11** | UI ekranları | ⬜ | — |
| **12** | Uçtan uca + teslim | ⬜ | — |

---

## 2. 🔴 Açık uçlar

### Kullanıcı cevaplayacak — Faz 4'ü (script) BLOKE EDİYOR
| # | Soru | Öneri |
|---|---|---|
| **A-08** | Modül kodu | **`CM`** (MM=`MM`, DerivSwp=`DV`) — ⚠️ kod iskeletinde **şimdiden** kullanılıyor |
| **A-09** | `DefNumberGen` sayaç öneki | **iki haneli zorunlu** — MM 55/50/120, OptionsFX 99 dolu |
| **A-10** | DB adı | **`NetTrexColManagement`** |
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
