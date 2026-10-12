# MEMORY.md — Cross-Repo Karar / Tuzak / Tercih

> **Bu dosya bir gelen kutusudur, arşiv değil.** Her girdiye **tarih** koy.
>
> **Promotion rule:** Bir girdi 2+ oturumda geçerliliğini korumuşsa **kalıcı evine taşı ve buradan sil**:
> | Girdi tipi | Kalıcı evi |
> |---|---|
> | Cross-repo mimari gerçeği / topoloji | `PROJECT_CONTEXT.md` |
> | Prosedür tuzağı | İlgili skill dosyasının **Gotcha** bölümü |
> | Evrensel kısıt | `CLAUDE.md` Hard Rule |
> | Yalnız tarihsel detay | Session arşivinde bırak, buradan sil |
> | **Tek repoya özel** her şey | O reponun kendi `.ai-agent/MEMORY.md`'si |
>
> Bu dosya her istekte yüklenir — büyümesi her göreve vergi. Kısa tut.

---

## Kullanıcı Tercihleri

- **Solo geliştirici (2026-08-12).** Tüm Treasury platformu Selim'in sorumluluğunda. Ekip konvansiyonu kaygısı yok,
  kişisel verimlilik önceliklidir. `.ai-agent/` ve `CLAUDE.md` dosyaları git'e gönderilmez.
- **Türkçe iletişim**, teknik terimler İngilizce.
- 🔴 **Claude ASLA commit / push / PR yapmaz (2026-10-01, kullanıcı kararı):** *"commitleri ben atıcam sen hiç bir
  zaman commit atmayacaksın"*. Onay verilmiş gibi görünse de yapılmaz; "commit atayım mı" diye sorulmaz.
  Claude dosyaları değiştirir, kullanıcı commit/push/PR'ı kendisi yapar.
- 🔴 **MM'e dokunan her iş `InterbankLoan:Enabled`'a göre davranır (2026-10-01):** kapalıysa Interbank Loan
  dropdown'lara gelmez (MM `.../products` ucu), backend `PRODUCT_DISABLED` döner, `TxnLoan`'a gidilmez.
  Ayrıntı: `Treasy.MM.UI/CLAUDE.md` Hard Rule 13.
- **Büyük çıktıyı sohbete basma** — dosyaya yaz, yolu bildir (`.ai-agent/outputs/`, `feature-research/`).
- 🔴 **KOD YORUMU KISA — `<summary>` yeterli, `<remarks>` YAZMA (2026-08-26, kullanıcı kararı):**
  Kullanıcının sözü: *"bu kadar uzun yazma yorum satırlarını, remark yazma summary yaz yeterli…
  bu kadar yorum satırı istemiyorum daha az ve net olsun."*
  **Uygulama:** tip/üye başına **tek satır** `<summary>`. `<remarks>`, `<para>`, çok paragraflı
  gerekçe anlatımı, mimari tartışması **yazılmaz**. Bir karar gerekçe istiyorsa yeri **kod değil
  tasarım dokümanı** (`feature-research/`, `MEMORY.md`) — koda en fazla tek satırlık `//` uyarısı.
  Emsal (aşırıya kaçmış hal, temizlendi): `TradeCaptureController` · `TradeCaptureMmProcessor`.
- 🔴 **"Release note yaz" → DAİMA [`skills/release-note.md`](skills/release-note.md) (2026-09-09,
  kullanıcı kararı):** Kullanıcı release note'u **Markdown dosyasına değil**, bir DevOps board work
  item formunun alanlarına yapıştırıyor (`Title`/`Summary`/`Testing Information`/`Impact Analysis`/
  `How To?`/`Definition and configuration`/`Scopekey Information`/`Process Changes`/
  `Customer Action Required`, hepsi TR+EN çifti). Kullanıcının sözü: *"bu başlıklara uygun olacak
  şekilde... yapay zekanın yazdığın belli olmayacak şekilde yaz."* Önceki tur ürettiği prose/madde
  işaretli Markdown döküman (`NetTrex.MM/.ai-agent/outputs/2026-08-31-Eximbank-Teslim/2-Release-Note-Is-Birimi.md`)
  **artık kullanılmıyor** — yeni istekte o dosyanın üslubu **taklit edilmez**, skill uygulanır.
  ✅ Skill dosyası: alan sırası + kim doldurur tablosu + üslup kuralları (düz metin, markdown yok,
  emoji yok, kısa teknik geçmiş-zaman cümleleri) + `Customer`/`Jira Id`/`DevOps Item Id` **uydurulmaz**.
- **SQL script konvansiyonu → [`skills/db-script.md`](skills/db-script.md) (2026-08-26):**
  Kullanıcının canlıda koşan emsal script'leri `NetTrex.MM/.ai-agent/imports/Örnek_Scriptler/`
  altında. Script yazacağın her seferde **o skill'i oku** — kullanıcı emsalleri tekrar göstermek
  istemiyor. Özet: parametre `sp_FrameworkAddParameter` **SP'si ile** eklenir (elle `INSERT` değil),
  `Txn*` tablosunun `Id`'si IDENTITY **değil** (`DefNumberGen`), `GO` `TRY/CATCH` içine giremez.
- **MD metodolojisi `ai-agent-context-kit`'ten (2026-08-12):** `repos/ai-agent-context-kit` bu md yapısının
  kaynak kiti (kullanıcının kendi ürettiği, MIT). Konvansiyon adları oradan: `START-HERE.md` ·
  `PROJECT_CONTEXT.md` · `MEMORY.md` + promotion rule · `progress/` (append-only numaralı) · `compacts/` ·
  `sessions/` · `skills/`. **Yeni bir md yapısı kurarken önce kit'in `docs/`'una bak**, isim uydurma.
  Boyut hedefleri: `CLAUDE.md` 1-2 ekran · `PROJECT_CONTEXT.md` 2-3 ekran · `MEMORY.md` 1-3 ekran · skill 1-3 ekran.
- **Workspace md katmanı istendi (2026-08-12):** Manuel Reeskont gibi **cross-repo** işler çoğaldığı için
  `repos/CLAUDE.md` + `repos/.ai-agent/` katmanı kuruldu. Gerekçe (kullanıcının kendi sözleri): her istekte
  genel mimarinin ve "hangi modülü nasıl kullanacağım"ın yüklü olması. Repo-özel `CLAUDE.md`'ler **kaldırılmadı** —
  iki katman birlikte yükleniyor, çakışmada repo-özel kazanır.

---

## Cross-Repo Kararlar

- 🔴 **Paylaşılan framework dosyalarına DAVRANIŞ değiştiren dokunuş YOK (2026-08-19, kullanıcı kararı):**
  Bir ekranın ihtiyacı, `Trex.FrameworkCommon` / `Framework.WebUI` gibi **tüm ekranların geçtiği**
  dosyaları değiştirmeyi gerektiriyorsa **değiştirilmez** — ayar/override **ekranın kendi klasörüne**
  yazılır ve `Startup.cs`'te tek satırla, **yalnız o tipe** bağlanır. Kullanıcının sözü:
  *"radikal bir şekilde benim yapımdaki timeout durumlarını falan ellemişsin galiba, bu isteyeceğim
  bir şey değil, side effect'inin ne olacağını bilemem, çok detaylı test gerekir, genel olarak bunu
  radikal değişiklik yaparsak bakamam."* Gerekçe: solo geliştirici, regresyon yüzeyi 19 Refit
  marker + ~200 ekran; ölçülemeyen yan etki kabul edilemez.
  **Uygulanışı:** Manuel Reeskont Execute timeout'u → `ManualRediscountRefitRegistration.cs`
  (`RefitExtensions.cs` bit-bit orijinal). Emsal olarak kullan.

- 🔴 **Manuel Reeskont: `NetTrex.Common` KULLANILMIYOR — WebUI'den modüllere DİREKT (2026-08-12, kullanıcı kararı v2):**
  Aynı gün **iki kez** karar değişti; geçerli olan **v2**.
  - **v1 (İPTAL):** WebUI genel ekran → `NetTrex.Common` → Common'da Strategy Factory ile fan-out (DailyFlow V2 klonu).
    Kodda doğrulanmıştı, çalışan bir desendi — ama kullanıcı bunu **gereksiz bir hop** olarak gördü.
  - **v2 (GEÇERLİ):** Ekran + base component **WebUI'de**; **WebUI Controller/service'ten modül API'lerine
    (MM · Fx · FI · InvFund) Refit ile DİREKT** fan-out. Kullanıcının sözü: *"bu mimaride Common projesine
    ihtiyacımız yok… Common projesini hiçbir şekilde kullanmayacağız."*
  - **Uygulanabilirlik ölçüldü:** 4 modülün Refit marker'ı Web.UI'de **zaten kayıtlı** (`Trex.WebUI/Startup.cs:58-75`),
    `RegisterClientWebApiRefitClients<T>` AppDomain'i taradığı için **yeni DI kaydı/config key gerekmiyor** —
    sadece marker'ı implemente eden interface yazmak yeterli.
  - **Faz sırası (kullanıcı):** (1) Web.UI base component + **MM** ucu → (2) diğer modüller → (3) base component
    `Treasy.MicroUI.Packages`'a taşınır ve MicroUI'ler **import eder**. *"Common yok — MicroUI projeleri yok —
    package projesi yok **şimdilik**."*
  - **v2'nin bedeli:** fan-out başka çağıranlarca yeniden kullanılamaz + sözleşme DTO'ları Web.UI'de yaşadığı için
    modül-UI **sürüm sapma riski** (`R-11`). Azaltma: `06-sozlesme.md` tek gerçek kaynak.
  Detay + 18 ADR → [`manuel-reeskont/02-mimari-karar.md`](manuel-reeskont/02-mimari-karar.md) (`ADR-MR-015`, `-017`, `-018`)
- **`baseUrl` → `moduleCode` (2026-08-12, kullanıcı onayı):** Doküman'ın kolon konfigürasyonundaki `baseUrl`
  alanı yerine `moduleCode` kullanılacak; iş birimine **sözleşme değişikliği** olarak bildirilecek.
  Gerekçe iki katmanlı: (a) Web.UI'de runtime base-URL resolver **yok**; (b) `settings.baseUrl`
  **uygulamanın kök yolu** (`@Url.Content("~")`), modül adresi **değil** — yani UI'den modül adresi vermek
  teknik olarak da anlamsız. Ayrıca `moduleCode` **zaten house convention**: `CashFlowComponent`'in
  config'inde `settings.moduleCode` var ve request'e `Module` olarak basılıyor (`cashflow.component.js:112`, `:983`).
- **Base component referans deseni = `cashFlow/` (nesil 3) (2026-08-12):** Web.UI'de üç desen nesli var —
  (1) tek dosya + global `const` (`paymentComponent.js` ve kardeşleri), (2) çok dosya + prefix disiplini
  (`limit-check/`), (3) `class` + `#private` + deep-merge config + JSDoc typedef + config-driven endpoint
  override (`cashFlow/`). Kullanıcı emsal olarak `paymentComponent.js`'i ve Limit entegrasyonunu gösterdi;
  ikisi de incelendi, **iskelet nesil 3'ten, dosya bölümlemesi + prefix nesil 2'den** alınacak (`ADR-MR-016`).
  Ham envanter → [`manuel-reeskont/analiz/analiz-6-webui-base-component-desenleri.md`](manuel-reeskont/analiz/analiz-6-webui-base-component-desenleri.md)
- **`baseUrl` → `moduleCode` (2026-08-12, kullanıcı onayı):** Doküman'ın kolon konfigürasyonundaki `baseUrl`
  alanı yerine `moduleCode` kullanılacak; iş birimine **sözleşme değişikliği** olarak bildirilecek.
  Gerekçe: Web.UI'de runtime base-URL resolver **yok** (ölçüldü) — Refit client'lar `IClientXxxAPI` marker'ından
  compile-time bağlı. Tarayıcının ürün servisini doğrudan çağırması hiçbir ekranda kullanılan bir desen değil.

---

## Bilinen Tuzaklar (cross-repo)

- 🔴 **DIS UCA MAKULLUK SINIRI KOYMAZSAN BUYUK BIR DEGER PROCESS'I DUSURUR (2026-09-04, olculdu):**
  Eximbank ucunda `amount: 67677676766776.67` gonderilince gateway **500** dondu:
  *"An error occurred while sending the request"* — ve **arkasindan gelen istek 0.24 sn'de**
  *"Connection refused (nx-mmwebapi:5000)"* aldi. Yani MM API process'i **coktu**. `100.000.000.000`
  ile tekrar uretildi; `50.000.000` sorunsuz calisiyor.
  🔑 **Teshis sirasi (tekrar kullanilabilir):** (1) **mukerrer referansla** saglik kontrolu at —
  hicbir sey yazmaz ama API'nin ayakta oldugunu kanitlar; (2) alanlari **tek tek izole** et
  (`rate` 11 ondalik → **kabul edildi**, tetikleyici degil); (3) cokmeden **sonraki** istegin
  hata metni degisiyorsa (`sending the request` → `Connection refused`) process olmus demektir.
  ⚠️ **DB kolonlarini ELE:** tum `decimal` kolonlar tarandi — `decimal(38,10)` (tam kisim 28) ve
  `decimal(36,18)` (18) 1e11'i **rahatca aliyor**. Ustelik SQL tasmasi `try/catch` ile yakalanip
  `DATABASE_ERROR` donerdi; **process cokmezdi**. Yani sebep kod icinde (yakalanamayan
  `StackOverflow`/`OutOfMemory`) ya da konteyner kill'i.
  🔑 **KOK SEBEP BULUNDU (ayni gun, iki adimda):**
  **(1) Asama ayirimi:** `AutoVerify` **kapaliyken** (islem `Input`'ta kalir, muhasebe ve Fimple
  **hic kosmaz**) ayni tutar **yine cokertti** → sebep `Verify` degil **`Create`**.
  **(2) Esik hesabi:** tutar `decimal(36,18)` kolonuna yazilirken **scale 18'e genisliyor**; .NET
  `decimal` 96-bit mantissa ile **28 anlamli basamak** tasiyor. `1e9` → 10+18 = **28** hane
  (olculdu: **gecti**), `1e11` → 12+18 = **30** hane (olculdu: **cokertti**). Esik `1e10`.
  ⚠️ Tespit edilemeyen: tasmanin neden `try/catch`'e dusmedigi (`OverflowException` beklenirdi).
  🔴 **CANLI TESTIN YAKALADIGI BOSLUK:** sinir once yalniz `amount`'a konmustu. `amount` **guvenli**
  (50 milyon) + `interestAmount: 1e11` → **yine cokti** — cunku `decimal(36,18)` kolonuna yazilan
  deger **faiz tutari** (`TxnMMDetail.Amount`), ana para degil. Birim test bu boslugu **gormedi**:
  test de kuralin yazildigi alani dogruluyordu.
  ✅ **Desen:** bir sinir kurali yazarken *"AYNI KOLONA yazan baska hangi alanlar var"* diye sor ve
  testi o alanlarin **hepsi** icin yaz. Sinir uc tutara birlikte konur.
  🔴 **AMA SINIR KALDIRILDI (ayni gun, kullanici karari):** *"bu sekilde bir sinir veremezsin,
  limit vermeyelim amount olarak."* **Gerekce hakli:** 1 milyar bir banka icin buyuk bir tutar
  degil — bir uc mesru bir islemin onune sabit is siniri koyamaz. Sinir semptomu gizler,
  sebebi cozmez ve gun gelir mesru bir islemi reddeder.
  ✅ **Tasinabilir ders:** dis bir ucta buyuk deger cokme uretiyorsa dogru cevap **is siniri
  degil kok sebep**. Sinir yalnizca (a) kok sebep aranirken **gecici**, (b) sinir **teknik
  kapasiteyle** birebir ortusuyorsa (kolon genisligi gibi) mesru — ikisinde de gerekcesi
  yaziyla durmali. Bu iste kok sebep hala **tespit edilemedi** ve risk **acik** biliniyor.

- ⚠️ **API GECIDI kendi zarfini ekliyor ve `IsSuccess`'i EZIYOR (2026-09-04, olculdu):**
  Fimple gateway (`hazine-investment-apigateway...`) cevabimizi `Value` altina koyup `ResponseBase`
  alanlarini (`messageId`, `isSuccess`, `messages`, `message`) **disa tasiyor** — ama disa yazdigi
  `IsSuccess` **bizim degerimiz degil**, gecidin HTTP sonucu. Mukerrer istekte bizim uc
  `isSuccess: false` uretirken zarf **`IsSuccess: true`** gosterdi; `Value` icinde `isSuccess`
  alani **hic yok**.
  🔑 **Sonuc:** gecit arkasindaki bir cagiran `isSuccess`'e bakarak karar **veremez**. Dis sozlesmede
  dallanma **`errorCode` + `actionRequired` + `transactionId`** uzerinden tanimlanmali — tek bir
  bool'a bagli sozlesme, arada bir zarf varsa **sessizce yanlis** okunur.
  ⚠️ Zarf bizim kodda **yok**: `ExternalBusinessRef` ne kaynakta ne `Netix*.dll`'lerde arandi, bulunamadi.
  ✅ **KANIT (2026-09-04, kesin):** ayni uca **gecitsiz** (dogrudan `localhost:5041`) istek atildi →
  cevap `{...,"messageId":null,"isSuccess":false,"messages":[],"message":""}` — **`Value` sarmalayicisi
  YOK, `isSuccess` DOGRU**. Yani zarf ve yanlis `IsSuccess` **tamamen gecidin**.
  ✅ **COZUM DESENI:** gecidin **tanimadigi bir adla** ikinci bir alan ekle
  (`Success => IsSuccess`, `[JsonPropertyOrder(-100)]` ile **ilk** alan) — `ResponseBase` adlari
  (`messageId` · `isSuccess` · `messages` · `message`) zarfa **tasindigi** icin `Value` icinde
  gorunmuyor, farkli bir ad ise bozulmadan kaliyor.
  🔑 Alan **get-only turetilmis** olmali (iki setter = biri guncellenip oteki unutulur;
  bu uctan `IsSuccess`'i **uc ayri yer** yaziyor: handler · errorMapper · processor).
  ⚠️ **Dogrulanmadi:** gecit `Value` icindeki **bilinmeyen** alani tasiyor mu yoksa kendi DTO'suna
  deserialize edip dusuruyor mu — deploy sonrasi gecit uzerinden bir istekle gorulecek.
  ℹ️ Alternatif: is hatalarinda HTTP 4xx donmek gecidin `IsSuccess`'ini kendiliginden `false`
  yapar; kullanici **200'de kalmayi** tercih etti.


- 🔴 **System.Text.Json `DateTime` YALNIZ ISO 8601 kabul eder - nokta ayrach tarih 400 verir
  ve ZARFA HIC GIRMEZ (2026-09-04, olculdu):** Eximbank ucunda musteri `"04.09.2026"` ve
  `"2026.09.04"` gonderdi, ikisi de **400 Bad Request**:
  *"The JSON value could not be converted to System.DateTime. Path: $.tradeDate"*.
  Olcum matrisi (`JsonSerializerDefaults.Web`, ozel converter yok):
  | Gonderilen | Sonuc |
  |---|---|
  | `2026-09-04` | ✅ |
  | `2026-09-04T00:00:00` / `...Z` / `...+03:00` | ✅ |
  | `2026-9-4` | ❌ **sifir dolgusu ZORUNLU** |
  | `04.09.2026` · `2026.09.04` · `04/09/2026` · `20260904` · `2026-09-04 00:00:00` | ❌ |
  🔑 **Iki katmanli sonuc:** parse hatasinda `[ApiController]` **otomatik 400 ProblemDetails**
  uretir - istek `Mediator`'a **hic ulasmaz**, bizim `errorCode`/`actionRequired` semamiz
  devreye **girmez**. Yani sozlesmede tanimli hata sozlugu bu durumda **ise yaramaz**.
  ⚠️ **STJ ILK hatada durur:** uc tarih de bozuksa cevapta yalniz `$.tradeDate` gorunur.
  Musteri onu duzeltir, sonra `valueDate` patlar - **alan basina bir tur**.
  🔴 **Offset'li gonderimde GUN KAYABILIR (olculdu):** STJ offset'i **sunucunun yerel
  saatine cevirir** ve `Kind = Local` yapar. `+03` sunucuda `"2026-09-04T00:00:00+04:00"`
  → **`2026-09-03`**. Kod `.Date` aldigi icin saat atiliyor, kayma **sessizce kalici** oluyor.
  ✅ **Cozum: alanin tipini `DateOnly` yap** (olculdu) - saat/offset/nokta **hepsini** reddeder,
  yalniz `yyyy-MM-dd` gecer. Belirsizligi dogrulama koduyla degil **tipin kendisiyle** kapatir.
  ⚠️ `DateOnly` de gonderilmezse `default` (`0001-01-01`) olur - `DateOnly?` + zorunluluk
  kontrolu birlikte gerekir.


- 🔴 **FIMPLE BIR FISI BIR KEZ TERSLER — duzeltme "ters isaretli YENI normal fis" olarak
  kesilir (2026-09-01, kullanici bilgisi):** Terslenmis bir fisi tekrar terslemeye kalkinca Fimple
  *"bacak 1'in tersi var"* diye reddediyor — cunku ters alma bir **komut**
  (`SendRevaluationReverseAccounting(MessageKey)`) ve Fimple'in state machine'inde fis basina **bir**
  kez calisir. Bu bilgi **KODDA YOK**: `IRevaluationReverseAccountingService` mekanik olarak sorunsuz
  gorunuyor.
  ✅ **Desen (AYNA CIFTI):** kaynagin **borc/alacak yonu cevrilmis kopyasi NORMAL fis** olarak
  kesilir (`SendRevaluationAccountingAsync`), tersi de **mevcut ters fisin valorune**. Iki gun de net
  sifir olur; kaynak fisler ve `ReverseId`'leri **hic degismez**.
  🔑 **Bu sadece bir bypass degil, DAHA DOGRU:** karsi fis kesmek kaynagin `ReverseId`'sini
  **eziyor** = defterdeki dogru bilgiyi (R1↔Rev1) **yok ediyor**. Muhasebede duzeltme
  **eklemelidir, silici degil**. Ezme yuzunden ekran yanlis statu turetiyordu (orphan avinin koku).
  ⚠ **Ayna cifti orijinal ciftin AYNI IKI GUNUNE dusmek zorunda** — yoksa notrlemez,
  dengesizligi **tasir**. Valorler **DB'den okunur** (`ReverseId` → o satirin `ValueDate`'i);
  T+1 varsayimi canli T+3 ciftte (`555960` 28.08 ↔ `555961` 31.08) iki yanlis gun uretiyordu.
  ⚠ Bedel: ayna ile kaynak `accEntryMain` **kolonlarinda birebir ayni** gorunuyor (tutar detayda)
  → yarida kalma + tekrar deneme cift kayit uretebilir. Tespit icin detay `AccEntry.ReverseId`
  bagi kullanilir (ters fis fabrikasi zaten dolduruyor; kolon **hicbir yerde filtre edilmiyor**).
  Emsal: `NetTrex.MM` `RevaluationMirrorAccountingService` (+ Scrutor `IAccountingService<>` taramasi
  sayesinde **DI satiri yok**).

- 🔴 **TOPLU (ÇOK SATIRLI) YAZMA DÖNGÜSÜ: bir satirin `Added` artigi SONRAKI satirin
  `Commit`'ine karisir (2026-09-01, yaşandı):**
  Istek basina tek (scoped) `DbContext` var. `IRepository.InsertAsync` **kaydetmiyor**; kaydeden tek
  yer `IUnitOfWork.CommitAsync()`. Bir satir Commit'ten **once** patlarsa entity'leri tracker'da
  `Added` **kalir**; disaridaki `catch` sonraki satira gecer ve **sonraki satirin Commit'i o
  fisleri de INSERT eder**. Yani kullanicinin *"hata"* gordugu satir gercekte **fis kesmis** olabilir.
  Ayni artik durum EF'i *"The instance of entity type 'X' cannot be tracked because another instance
  with the same key value for {'Id'} is already being tracked"* hatasina da surukluyor.
  🔑 **EOD batch'inde bu HIC olmuyor** — ve sebebi `ChangeTracker.Clear()` degil:
  batch her islem icin **TEK** muhasebe servisi cagiriyor ve **reeskont ile ters fis AYRI batch
  item** (= ayri DI scope = ayri `DbContext`). Manuel Reeskont, satir basina **1-4** muhasebe
  servisini **ayni scope'ta zincirleyen ilk yer**.
  ✅ **Desen:** yeni bir toplu yazma ucu yazarken *"batch bu isi nasil izole ediyor"* diye bak.
  Batch item basina izole ediyorsa sen de **satir basina** izole et: dongu basinda
  `ChangeTracker.Clear()` **ve** `catch` icinde tekrar.
  ✅ **Teshis:** `ex.Message` yetmez — EF hangi Id'nin cakistigini **soylemiyor** ve
  `EnableSensitiveDataLogging` canliya acilamaz. Tracker dokumunu (`ChangeTracker.Entries<T>()` →
  Id + FK + `State`) hata satirina **ekle**; bir dahaki olusumda dogrudan gorunur.
  Emsal: `NetTrex.MM` `IChangeTrackerDataService` (adi `DataService` ile bittigi icin Scrutor
  otomatik kaydediyor, DI satiri yok) + `ExecutionsHandler`.
  ⚠ **Cürütülen iki hipotez** (bir daha aranmasin): `sp_GetNewNumbers` sayaci
  `UPDATE ... WITH (ROWLOCK, UPDLOCK)` ile **monoton** — mukerrer Id **uretemez**; ve sayaclar
  tablonun `MAX(Id)`'sinin **onunde** — var olan Id **dagitilmiyor** (`sql-log` #51/#54).
  🔑 **`Transient` BU HATAYI COZMEZ** (2026-09-01, olculdu): DI'da lifetime **bulasici degil** —
  container Transient nesnenin ctor parametrelerini **ayni scope'tan** cozer ve `AddRepository`
  `IUnitOfWork` / `IDataContext` / `IRepository<>` / `EfDbContext`'i **tamami Scoped** kaydeder
  (`NetTrex.MM.Data.Repository/Extensions/RepositoryExtensions.cs`) → N taze servis, **1 `DbContext`**,
  tracker onun icinde. `DbContext`'i transient yapmak ise UnitOfWork'u **kirar**: repository A'ya
  yazar, `CommitAsync` C'yi kaydeder → **diske hicbir sey gitmez, hata da vermez**.
  ✅ Izolasyon **scope**'tan gelir (batch'in item basina yeni scope acmasi gibi) — yeni `DbContext`
  yalniz yeni scope ya da `IDbContextFactory` ile dogar. `ChangeTracker.Clear()` bir hack degil,
  **EF Core'un toplu is icin sundugu public API'si**.
  ⚠ Ayni yerde ikinci olcum: `AccountingDataManager`'in **3 yolu `AsNoTracking` DEGIL**
  (`GetNonReverseRevaluationWithTransactionIdAsync` ve `GetNonReversedOpeningWithTransactionIdAsync`
  `Include(AccountingEntries)` ile **cocuklari da** izliyor) — cakisan tip tam olarak `AccEntryEntity`.


- 🔴 **Reeskontun ters fisi T+1 OLMAK ZORUNDA DEGIL — valor `ReverseId` ile DB'den okunur
  (2026-09-01, canli veriyle dogrulandi):**
  `Rediscounted` statusu yalniz **`ReverseValueDate > ExecutionDate`** ister. Canli `accEntryMain`'de
  T+3 cift **var**: `555960` (ValueDate **28.08.2026**, `ReverseId=555961`) ↔ `555961`
  (`IsReverse=1`, ValueDate **31.08.2026**) — hafta sonu atlanmis. Ayni desen `555957`↔`555963`.
  Yani ters fisin gunu EOD'nin **kendi kosu gunune** bagli (`Revaluation:*.ReverseType`, `SystemWDFlag`).
  ✅ Bir fisin tersi **hesaplanmaz, BULUNUR**: `IsReverse` ters mi oldugunu, `ReverseId` **neyin**
  tersi oldugunu soyler; valor o satirin `ValueDate`'idir.
  🔴 **UI bu tarihi ASLA hesaplamaz.** Manuel Reeskont onay penceresi karsi kaydin valorune
  `ExecutionDate + 1` yaziyordu — modul ise `previousReverse.ValueDate`'e kesiyordu: **ekran T+1
  der, defter T+3 olur**. Cozum: tarihi **sozlesmeye** ekle
  (`ManualRediscountItem.ReverseValueDate`) ve pencere onu **bassin**; secimdeki satirlar farkli
  tarihler tasiyorsa tek tarih basmak yine yanlis → valorun **ne oldugunu** yaz, tarih yazma.
  🔴 **COK BACAKLI muhasebe duzeltmesi yarida kalirsa EKRAN BUNU GORMEZ — asimetriyi ara
  (2026-09-01):** Regenerate 4 bacakli (2 karsi fis + yeni reeskont + yeni ters fis), dagitik
  transaction **yok**. Bacak 1'den sonra kesilirse `R1.ReverseId` **ezilmis** olur ve `Rev1`'e giden
  bag kopar → **hicbir sorgu `Rev1`'i aramaz**, statu turetimi `NotRediscounted` der. Kullanici
  sayfayi yenileyip Generate'e basar: gun T dogru cikar ama **gun T+n `-2A`, yani IKI KATI**.
  Yani *"yarida kalirsa sayfayi yenileyip devam ederim"* **calismaz** — ekran yanlis statu soyler.
  ✅ Tespit yeni tablo/flag istemez, **uc kolon**: `IsReverse` + `ReverseId == reeskontId` +
  `ValueDate > reeskontun valoru` + `Id != R1.ReverseId`. Ayrimi yapan sey **tamamlayici ters fisin
  valoru SONRA, notrleyen karsi fisin valoru AYNI**.
  ✅ **Tespit et ve REDDET** (`HALF_NEUTRALIZED`), otomatik onarma: karsi fis kesmek gercek para
  hareketi. Emsal: `ExecutionsHandler.RejectIfHalfNeutralizedAsync` +
  `IAccountingDataManager.GetOrphanCompletingReverseAsync`.


- ℹ️ **Tarih kaynağı kuralı `CLAUDE.md` Hard Rule 12'ye TAŞINDI (2026-09-04).** Burada yalnız ölçüm
  kalıyor: `DateTimeProvider.GetCurrentDateTime()` reflection'la koşturuldu → `DateTime.Now` ile **birebir**
  aynı, `Kind = Local` (`11:12:28 Local` / `Now 11:12:28` / `UtcNow 08:12:28`). Yani provider
  UAE (+04) senaryosunu **çözmüyor**; TZ'den bagımsız gün gerekiyorsa `GetLogicalDateAsync()`.
  ⚠️ Tetikleyen olay: MM Manuel Reeskont validator'ü `DateTime.Today` ile *"future date"* reddi
  yapıyordu (`IIBUAE-886` UAE kurulumu).
- ⚠ **CSS'te esit specificity'de KAYNAK SIRASI kazanir — "pasif buton" kurali dolu-zemin
  kurallarinin HEPSINDEN sonra durmali (2026-09-01, yaşandı):**
  `.dx-button.mr-btn-generate.dx-state-disabled` (3 sinif) ile
  `.dx-button.mr-btn-regenerate.dx-button-mode-contained` (3 sinif) **esit** agirlikta. Pasif blok
  Generate bolumunun icine yazilmis, dolu turuncu Regenerate kurali dosyada **sonra** geldigi icin
  pasif kurali eziyordu → secim yokken Generate cerceveli, **Regenerate DOLU TURUNCU** goruniyordu.
  ✅ Iki butonu ayni deseni paylasan tek blokta topla ve o blogu **en sona** koy.


- 🔴 **Web.UI'nin çok dosyalı JS bileşenlerinde top-level `const` ADI İKİ KEZ TANIMLANAMAZ —
  ekran hiç açılmaz (2026-08-26, yaşandı):**
  `manual-rediscount/*.js` gibi bir bileşenin dosyaları ayrı `<script>` etiketleriyle yükleniyor
  ama **module değil**; klasik script'lerin top-level `let`/`const`'ları **paylaşılan global
  lexical environment**'a giriyor. Aynı adı ikinci dosyada tanımlamak
  `SyntaxError: Identifier 'X' has already been declared` → **ikinci dosya HIÇ çalışmaz**,
  ekran boş/500 gelir. `var` olsaydı sessizce ezerdi (daha kötüsü).
  Yaşanan: rozet üreticisi `mrStatusBadgeHtml` `columns.js:137`'de **zaten vardı** (farklı imzayla),
  ikincisi `actions.js`'e yazıldı.
  ✅ **Desen:** bileşene yeni bir global fonksiyon eklemeden **önce adını grep'le**; aynı işi yapan
  biri varsa **onu genişlet** (opsiyonel param), ikinci kopya yazma. İki farklı iş ise adını
  ayır (`mrInlineStatusBadge`).
  🔑 **JS testleri bunu YAKALIYOR** çünkü harness aynı dosyaları `new Function` gövdesinde
  **birleştirip** yüklüyor — tarayıcıyla aynı kural. Bu bileşende JS testi koşmak
  "davranış doğru mu"dan önce **"ekran açılıyor mu"** sorusunu cevaplıyor.

- 🔴 **`DevExpress.localization.formatDate(d, "shortDate")` EV STANDARDI DEĞİL — aynı ekranda iki
  tarih biçimi üretir (2026-08-26, yaşandı):**
  `"shortDate"` DevExtreme'in **yerel** kısa biçimi; dile göre `8/26/2026` olabiliyor. Ev standardı
  ise `UIConstants.DateFormat = "dd.MM.yyyy"` (`Trex.Common.Models/Models/Base/UIConstants.cs:5`) ve
  `ToNetixDateBox` **onu** `DisplayFormat` olarak veriyor. Sonuç: filtre kutusu ve grid `26.08.2026`,
  onay penceresi `8/26/2026` — kullanıcı *"yazılar bizim tarih formatımızda olsun (sıralanış VE
  ayraç)"* diye bildirdi.
  ✅ Ekranın tarih biçimini **tek sabitte** tut (`MR_DATE_FORMAT`) ve **her** yazan yer oradan geçsin;
  iki formatlayıcı yaşarsa biri güncellenip diğeri unutulur (bu işte tam bu olmuştu).
  ⚠ **DevExtreme grid tarih kolonunda `format` YAZILMAZSA** da aynı yerel biçime düşüyor. Kolon
  config'ini JSON'dan okuyan bir bileşende varsayılanı **koda** koy (`column.format || MR_DATE_FORMAT`),
  config'lere tek tek yazma — Manuel Reeskont'ta `treasury.json` veriyordu,
  `investment.json`/`security.json` **vermiyordu** ve üç ekran ayrışıyordu.

- ⚠ **Onay penceresi "kural" yazarsa kullanıcı kendi satırına ne olacağını anlamıyor (2026-08-26,
  kullanıcı isteği):** Kullanıcının sözü: *"Confirm pop-up'larında direkt yapılacak işlem yazsın...
  ben o an yapılacak işlemi görmek istiyorum."* Manuel Reeskont onay gövdesi seçimde ne varsa
  bakmadan **her zaman** *"Reeskont: Not Rediscounted kayıtlar için oluşturulur"* + *"Ters fiş:
  Not Reversed kayıtlar için oluşturulur"* yazıyordu.
  ✅ **Desen:** onay penceresi seçimin **kendi durumundan** türetilir ve **kesilecek kayıtları
  numaralı** yazar + her satırda **gerçek valor tarihi** + `[geldiği durum] → [varılacak durum]`.
  Boş grup **hiç basılmaz**.
  🔑 Bunu yapmayı mümkün kılan şey buton kapısıydı (Generate yalnız **tek statülü** seçimde aktif) —
  yani "ne olacak" onay anında **belli**. Karışık seçime izin veren aksiyonda (Regenerate) grup başına
  ayrı liste basılır.
  ⚠ Tarih **UI'de yeniden HESAPLANMAZ**: bilinmiyorsa `-` yazılır. T+1 kuralı modülde tek sınıfta
  (`ManualRediscountValueDateResolver`); UI'de ikinci kopya = ekran bir tarih gösterip modül başkasına
  fiş keser.

- ⚠ **Mutlak konumlu bir ⓘ/rozeti AKIŞTA kullanmak için `position` AÇIKCA ezilmeli (2026-08-26):**
  `.mr-info-badge` buton **köşesine** oturmak için `position: absolute; top:-6px; right:-6px`.
  Aynı sınıf bir etiketin yanında kullanılınca `top/right` yüzünden **etiketin üstüne biniyor**.
  ✅ `position: static; top: auto; right: auto` veren ayrı bir `-inline` sınıfı yaz.
  ⚠ Ayrı tuzak, aynı aileden: `.mr-dialog .dx-popup-content div/span` gibi **iki sınıflı** kurallar
  pencere içindeki her metne renk basıyor; tek sınıflı kendi kuralın **ezilir**. Pencerede özel renk
  istiyorsan seciciyi `.mr-dialog .dx-popup-content .senin-sinifin` diye yaz.


- 🔴 **Sistem parametresine tablo Id'si YAZILMAZ — `Code` yazılır (2026-08-28, kullanıcı kararı):**
  Bir framework parametresi referans tablosuna işaret ediyorsa değeri o tablonun **`Code`**
  kolonu olur. Id ortamdan ortama değişir (dev/test/canlı); `Code` değişmez ve parametreye
  bakan kişi `MM.PortfolioId = 1` yerine `MM.PortfolioCode = TR` gördüğünde **ne olduğunu anlar**.
  Kullanıcının sözü: *"Id yerine Code üzerinden gidelim"*.
  ⚠️ **`Name` de olmaz:** `PrdProductDefinition` Id 7 → `Code 'Pass'` ama `Name 'Pas'`.
  ⚠️ **`ExternalCode` de olmaz:** o **dış sistemin** (Fimple) dili. `SettlementType` Id 1 →
  `Code 'Gross'` / `Name 'Gross Settlement'` / `ExternalCode 'Single'` — **üç ayrı kelime, tek satır**.
  🔑 **Ama dış sisteme giden süzme/istekte `ExternalCode` kullanılır.** Yani lookup
  metodu yalnız Id döndürmemeli — **satırın tamamını** döndürmeli: `Id` bizim işlemimize,
  `ExternalCode` dış çağrıya gider. İkisini karıştırmak sessiz bir "sonuç boş" hatası üretir.
  ✅ Emsal: `NetTrex.MM` Eximbank ucu — `MM.SettlementTypeCode = 'Gross'` parametresi,
  Fimple muhabir süzmesi çözülen satırın `ExternalCode`'u (`BankToBank`) ile.


- 🔴 **DOKUMANI OKUDUM demek YETMEZ — kuralın ZATEN KOŞAN kod karşılığını ara (2026-08-26, yaşandı):**
  Manuel Reeskont'ta statü türetmeyi *"reeskont fişinin tersi var mı"* diye yazdım; dökümanın
  *"ters fiş kaydı **(t+1)** mevcuttur"* parantezini **yalnızca tanımlayıcı** saydım. Yanlıştı.
  Aynı repoda **her gece koşan** EOD sorgusu (`TransactionDataManager.GetPendingRevaluationTransactions`)
  kuralı zaten uyguluyordu: "bugun reeskont kesilecekler" kümesine, o güne fişi olup **tersi de aynı
  güne** kesilmiş satırları da katıyor — metodun **kendi XML yorumu** bunu yazıyor:
  *"or whose revaluation was reversed on the same date"*.
  ✅ **Desen:** yeni bir uca iş kuralı yazarken *"aynı kavramı hesaplayan bir BATCH/rapor var mı"* diye
  ara ve **onun sorgusunu oku**. Döküman yorumlanır, çalışan kod **yorumlanmaz**.
  🔑 Kullanıcı *"dökümanda net olmayan/yanlış şeyler olabilir"* dediğinde bu, kodu **ikinci kez**
  taramanın izni değil **emri**dir — döküman ile çalışan kod çeliştiğinde **çalışan kod** kazanır,
  çünkü canlı defteri o üretiyor.

- 🔴 **Tahakkuk motoru MUTLAK tutar basıyorsa "yeniden üret" = ÇİFT KAYIT (2026-08-26, yaşandı):**
  `NetTrex.MM`'de reeskont fişinin tutarı **kümülatif**: `SLCalculatorContextMapper` →
  `PassedDay = LogicalDate - CashFlow.StartDate + 1`, yani **dönem başından** o güne birikmiş toplam.
  Delta **değil**. Ve `20_RevaluationAccountingPersistChangeStep` **koşulsuz `InsertAsync`** yapıyor —
  o güne fiş var mı diye **bakmıyor**.
  🔴 Sonuç: aynı güne ikinci bir reeskont kesilirse gün-T bakiyesi `A1 + A2` ≈ **iki katı**.
  Hata mesajı yok, birim test görmez, fark **defterde** çıkar.
  ✅ **Desen:** bir muhasebe akışına "yeniden üret / düzelt" aksiyonu eklerken **ÖNCE** motorun tutar
  semantiğini ölç (mutlak mı delta mı) ve persist adımının **idempotent** olup olmadığına bak.
  Mutlak + idempotent-değil ise "yeniden üret" mevcut çifti **karşı kayıtlarla kapatmak zorundadır**.
  🔴 **GUNCELLEME 2026-09-01: karsi kayit YONTEMI TERK EDILDI** — Fimple ikinci
  terslemeyi reddediyor; yerine **ayna cifti** kesiliyor (yukaridaki kayit). Asagidaki iki-bacak
  gerekcesi **gecerli** (gun T ve gun T+n ayri ayri kapatilmali), yalnizca **nasil** kesildigi degisti.
  ⚠️ Tamamlanmış bir reeskont–ters çiftini geri almak **İKİ** karşı kayıt ister: reeskontun kendi
  valörüne (gün-T'yi sıfırlar) **ve** ters fişin kendi valörüne (gün-T+1'i sıfırlar). Yalnız birincisi
  yapılırsa T doğru olur, T+1'de fazladan kayıt kalır.
  ⚠️ MM'de bu **yeni bir hareket türü**: muhasebe **silme** akışı bile yalnız `ReverseId == 0` olanı
  tersliyor. Mekanizma (`IRevaluationReverseAccountingService`) guard'sız olduğu için mekanik olarak
  çalışıyor, ama **Fimple kabulü denenmeden** canlıya alınmamalı.
  ℹ️ Yan etki ölçüldü: ters fiş kesmek kaynağın `ReverseId`'sini **eziyor**
  (`10_RevaluationReverseAccountingPersistChangeStep`). Tüm okuyucular tarandı — hepsi `== 0` / `!= 0`
  testi yapıyor ya da o tarihin **en son** fişini alıyor; kimse `R1 ↔ Rev1` kimliğini yürümüyor.

- ⚠️ **Ekranın "uygun işlem" ŞARTLARI, işi FIİLEN YAPAN servisin ÖN KOŞULUDUR (2026-08-26):**
  Manuel Reeskont kapsam sorgusundaki *"o tarihte aktif faiz dönemi var"* şartı kozmetik değil:
  motor işlemi `GetTransactionForRevaluationEngineAsync` ile **filtreli `Include`** ediyor
  (`PeriodStartDate <= date < PeriodEndDate`, `!IsPrincipalAmount`) ve mapper **guard'sız**
  `transactionEntity.Details.First()` çağırıyor (`RevaluationEnginePipelineContextMapper:23`).
  Şart kaldırılırsa ekran, **butona basılınca `InvalidOperationException: Sequence contains no
  elements` ile patlayacak** satırları listeler; kullanıcı anlamsız bir `EXTERNAL_ERROR` görür.
  ✅ Uygunluk filtresi yazarken, o işlemi **yürüten** servisin veri çekme sorgusunu oku: filtre en az
  onun kadar dar olmalı.

- 🔴 **Bir metnin YOKLUGUNU test ediyorsan, o metnin URETILEBILDIGI ortamda test et (2026-08-25, yaşandı):**
  Manuel Reeskont JS testlerinde `load()` varsayılanı `formatMessage`'i **anahtarı geri döndüren**
  bir stub ile kuruyor. `mrText` bu durumda fallback'e düşüyor, yani *"External system error"*
  metni **hiç üretilmiyor**. `expect(text).not.toContain("External system error")` bu yüzden
  bastırma mantığını değil **test altyapısını** ölçüyordu — kod geri alınsa bile test **yeşil**
  kalırdı.
  ✅ Gerçek metinleri enjekte et: `load({ formatMessage: (key) => MESSAGES[key] || key })`.
  🔑 Genel kural: **negatif iddia** (bu yok / bu yazılmaz) test edilirken, pozitif halin
  üretilebildiğini de **aynı testte** kanıtla — yoksa test her koşulda geçer.

- 🔴 **DevExtreme `Form` içindeki editöre SADECE ÇALIŞMA ANINDA verilen `dataSource` KAYBOLUYOR (2026-08-25, yaşandı):**
  Manuel Reeskont'ta alt ürün `TagBox`'ının listesi yalnız JS'ten veriliyordu
  (`instance.option("dataSource", …)`); Razor'da `DataSource` **hiç yoktu**. Editör kendi
  başlangıç seçenekleriyle yeniden kurulduğunda çalışma-anı ayarlarının **tamamı** Razor haline
  dönüyor: `dataSource` **boş**, `value` **silinmiş**, `placeholder` ve `disabled` **eski**.
  Belirti kullanıcının gözünde üç ayrı hata gibi görünüyor: *"dropdown No data to display diyor"* +
  *"generate'ten sonra seçimlerim boşalmış"* + *"ürünü değiştirip geri gelince düzeliyor"*.
  ⚠️ **Tetikleyici koddan izole edilemedi** — `#syncSubProducts` yalnız ctor + ürün değişiminden
  çağrılıyor ve ikisi de listeyi **dolduruyor**; kutuya dokunan başka satır yok.
  ✅ **Desen (tetikleyiciyi bilmeye ihtiyaç bırakmaz):** (1) başlangıç listesini **Razor'dan** ver —
  yeniden kurulmada yerinde kalır; (2) ürün/bağlam değişiminde JS yenile; (3) editör`onOpened`'da
  eksiği **tamamla** ve tamamlarken **seçimi SILME** — silme kararı çağıranın olmalı
  (`sync(resetValue)`), aksi halde "listeyi onarırken kullanıcının seçimini sil" hatası kurulur.
  🔑 Onarma anına **konsol uyarısı** bırak: bir daha olursa tetikleyici stack trace'ten yakalanır.

- 🔴 **DevExtreme `noDataText` GRID'IN KAYDIRMA GENISLIGINE gore konumlanir — geniş grid'de metin ekrandan kaçar (2026-08-25):**
  24 kolonlu bir grid'de *"Select product, sub-product and execution date"* metni görünür alanın
  ortasına değil **tüm kaydırma genişliğinin** ortasına düşüyor; sağa kaydırınca sol kenarda
  yarım görünüyor (kullanıcı: *"bu yazı yanlış yerde yazıyor galiba ya da kaldır"*).
  ✅ **Ayrım:** metin **veri** hakkındaysa (*"bu tarihte kayıt yok"*) grid'de kalabilir; **FILTRE**
  hakkındaysa (*"önce şunu seç"*) evi filtre/özet şeridi — sabit konum, hiç kaymaz. Grid o durumda
  `noDataText: ""` ile **sessiz** kalır.
  ⚠️ Ayrı tuzak: `noDataText` dallarından biri **güncellenmezse** grid önceki dalın metnini
  göstermeye devam eder — 8 alt ürün seçili haldeyken *"filtre seç"* yazması böyle oldu.
  Başarısız istek ile boş sonuç **aynı şey değil**; hata yolunda da metin yazılmalı.

- 🔴 **Sözleşmeye alan eklerken WEB.UI'DAKİ DTO KOPYASI UNUTULUYOR — hata EN SONDA çıkıyor (2026-08-24, yaşandı):**
  Manuel Reeskont'ta `EligibleTransactionsRequest`'e `SubProducts` alanı eklendi (MM tarafı), ama
  `Trex.Web.Business.Models/Models/ManualRediscount/Req/EligibleTransactionsRequest.cs`
  **güncellenmedi**. Zincir sessizce kırıldı:
  JS `SubProducts` gönderiyor → **model binder alanı yutuyor** (bilinmeyen alan hata değil) →
  Refit modüle `null` taşıyor → modülün validator'ı *"At least one SubProduct is required."*
  ile reddediyor. **Hiçbir katman "eksik alan" demiyor**; hata en uçta, hem de alâkasız görünen
  bir doğrulama mesajı olarak çıkıyor.
  ✅ **Kural:** modül sözleşmesine alan eklerken **aynı turda** Web.UI kopyasını da güncelle.
  Alan adı JS → WebUI DTO → Refit → modül DTO → validator zincirinin **tamamında** birebir olmalı.
  🔑 Bu, `manuel-reeskont/02-mimari-karar.md`'deki `R-11` riskinin (*"sözleşme DTO'ları Web.UI'de
  yaşadığı için sürüm sapma riski"*) fiilen gerçekleşmesi — teorik bir kaygı değil.

- **DevExtreme `TagBox` + `ApplyValueMode.UseButtons` = seçim OK'a basılmadan uygulanmaz (2026-08-24):**
  Kullanıcı tikleri işaretleyip listeyi kapatıyor, hiçbir şey seçilmemiş gibi görünüyor
  (*"birden çok seçiyorum ama dropdown içine yazmıyor"*). `UseButtons` bilinçli bir onay adımı
  ister; çoklu **filtre** kutusunda beklenen davranış **`Instantly`**.
  ⚠️ Ayrı bir tuzak: `TagBox`'ta değer **dizi** olduğu için `option("value", ...)` referans farkı
  yüzünden `onValueChanged`'i **her zaman** tetikler — `SelectBox`'ta aynı skaler değer tekrar
  atandığında olay bastırılıyordu. Programatik atamada handler'ı geçici olarak `null`'a çekmek
  gerekiyor, yoksa (a) constructor içinde henüz kayıtlı olmayan instance aranır (konsola
  *"Olayin sahibi instance bulunamadi"*), (b) her ürün değişiminde **çift yükleme** olur.

- **`PrdProductDefinition`: `Code` ile `Name` bir harf farkla ayrışıyor — `Pass` / `Pas` (2026-08-24):**
  MM ürün tanımlarında `Id 7` → `Code = 'Pass'` (**çift `s`**) ama `Name = 'Pas'` (tek `s`).
  Kullanıcı/iş birimi ekranda gördüğü **`Pas`**'ı söylüyor; kodda filtre yazarken `Code` esas
  alınmalı. `Name` ile yazılan bir dışlama filtresi (`!= "Pas"`) **sessizce çalışmaz** — kayıt
  listede kalır ve kimse fark etmez.
  ⚠️ Tabloda `ModuleCode` kolonu **YOK**; modül ayrımı `MainProductCode` ile ve MM'in **11 ürün
  tanımının tamamı** `MainProductCode = 'MM'`. Yani "MM Transactions" ile "InterbankLoan
  Transactions" ayrımı bu kolonda **yapılamaz** — ayrım ürün tanımı seviyesinde (`Loan` = Id 2).
  Referans: `MmTransactionController.GetProductDefinitions` **filtre uygulamıyor**;
  `InterbankLoanController` `!IsSameDay && !IsZeroRate` süzüyor.


- 🔴 **MD dosyasına Python'la yazarken `open(p,'w')` KULLANMA — hata anında dosyayı YOK EDER (2026-08-21, yaşandı):**
  `io.open(p, 'w')` içeriği **yazmadan önce truncate** ediyor. Yazma sırasında bir istisna çıkarsa
  (bende `UnicodeEncodeError: surrogates not allowed` — emoji `🔴` biçiminde escape edilmişti)
  dosya **0 byte** kalıyor. `.ai-agent/` git'te olmadığı için geri dönüş yok.
  ✅ **Desen:** geçici dosyaya yaz → içeriği **oku ve doğrula** (beklenen anahtar metinler var mı) →
  `os.replace(tmp, p)`. Ayrıca dokunmadan önce `cp` ile yedek al.
  🔑 **Kurtarma yolu (işe yaradı):** dosyanın tam içeriği önceki oturumların Claude Code
  transkriptinde duruyor → `~/.claude/projects/<proje-slug>/<session>.jsonl` içinde `tool_result`
  bloklarını tara, dosyaya özgü iki ayrı metni (ör. `ADR-MR-001` **ve** `ADR-MR-018`) birlikte içeren
  **en büyük** bloğu al. Doğrulama: kurtarılan metindeki satır numaraları canlı dosyada gördüklerinle
  eşleşiyor mu (`grep -n`). `02-mimari-karar.md` böyle **tam** geri getirildi.
  ⚠️ Emoji yazacaksan Python kaynağında `\U0001F534` (tek kaçış) kullan; `🔴` (surrogate çifti)
  Python'da **yazılamaz** metin üretir.

- 🔴 **Sunucu taraflı sayfalı grid'de DevExtreme filtresi YALNIZ YÜKLÜ SAYFAYI süzer (2026-08-20/21):**
  `remoteOperations: { paging: true, filtering: false }` iken `filterRow`/`searchPanel` açmak filtreyi
  **tarayıcıda** uygular → kullanıcı "3 kayıt var" sanır, oysa diğer sayfalarda daha vardır; `TotalCount`
  ve grid üstündeki özet şeridi filtreyle **çelişir**. Finansal ekranda kabul edilemez.
  ✅ `filtering: true` + filtreyi sunucu sözleşmesine çevir (`loadOptions.filter` bir **ifade ağacı**:
  tek koşul · `and` zinciri · aynı değerli `or` = arama kutusu). Çevrilemeyen ifadeyi **sessizce yok
  sayma** — uygulanmadığını kullanıcıya söyle, yoksa "veri yok" sanır.
  ✅ Kolonlara `filterOperations: ["contains"]` ver: sunucunun yapamadığı operatörü (`=`, `between`)
  kullanıcıya sunmak **sessiz yanlış sonuç** demek. Sayısal ama metin olarak aranan alana
  (`ExternalCustomerId`) `dataType: "string"` **açık** yazılmalı, aksi halde DevExtreme NumberBox + `=`
  seçip sunucunun `LIKE` davranışıyla ayrışır.
  🔴 Filtreyi **sayımlardan ÖNCE** uygula (aksi halde "Toplam 248" derken grid 3 satır gösterir) ve
  müşteri/ilişki alanlarını **EXISTS (`Any`)** ile filtrele — required navigation dereference `INNER JOIN`
  üretip orphan FK'lı satırı sessizce siler (bu tuzak aynı işte iki kez yaşandı).
  ✅ **Türetilmiş kolonda filtre kutusu HİÇ AÇMA** (`allowFiltering: false`): boş kutu "filtrelenebilir"
  yalanıdır. Manuel Reeskont'ta `Data.*` (tahakkuk, dönem faizi, portföy) ve `Status Description` böyle.
  🔑 **NİHAİ ÇÖZÜM (2026-08-21, kullanıcı kararı) — sunucu taraflı sayfalamadan ÇIKMAK:**
  Manuel Reeskont'ta bu tuzakla üç tur boğuşuldu (filtreyi sunucuya çevir → sıralamayı kapat → huniyi kapat → türetilmiş kolonlarda kutu açma). Sonunda kullanıcı *"her seferinde statüs filtrelerinde sunucuya gitmek istemiyorum"* diyerek **grid'i tamamen client-side** yaptırdı: kapsam (tarih + ürün + alt ürün) **tek istekte** gelir, filtre/sıralama/sayfalama/huni DevExtreme'e bırakılır. **Üç şartı var** — biri eksikse yapma:
  (1) sunucuda bir **tavan** (`Take`) olsun ve aşıldığında `TotalCount > dönen satır` karşılaştırmasıyla **yüksek sesle uyar** — sessiz eksik liste, sunucu filtresinden **daha** tehlikeli;
  (2) özet/sayaç şeridini de **tarayicıda** hesapla — sunucu sayimi + tarayici filtresi = *"Toplam 248 diyor, grid 3 satır gösteriyor"*;
  (3) veri **bayatlayacağı** için yazma yolunun güvenliği UI tazeliğine dayanmasin — sunucu her satırın durumunu yeniden doğrulayıp reddetmeli (`STATUS_CHANGED`) ve aksiyondan sonra önbellek **geçersiz** kılınmalı.
  ✅ Kazanç büyük: huni (başlık filtresi), kolon sıralaması ve **türetilmiş kolonlarda filtre** kendiliğinden doğru hale geliyor — sunucuda yapılamayan her şey tarayıcıda bedava.
  Detay: `manuel-reeskont/02-mimari-karar.md` → `ADR-MR-028`/`-029`.

- 🔴 **Manuel Reeskont T+1 = +1 TAKVİM GÜNÜ (kullanıcı kararı 2026-08-21) — batch taklit EDİLMİYOR:**
  Kullanıcının sözleri: *"NextWorkingDay'e de bakma SystemWDFlag'ine de bakma, direkt +1 gün deyip
  ilerleyelim… bu kesin bilgidir, her zaman 1 gün sonra olsun."* Uygulama:
  `ManualRediscountValueDateResolver.ResolveNextDay(date) => date.Date.AddDays(1)`; `ICalendarHelper`
  ve `MMSystemWDFlag` handler ctor'larından **çıkarıldı**. Baz her zaman **ExecutionDate**.
  ✅ **Taşınabilir desen:** bu hesap **tek sınıfta** durur ve **hem fiş kesen hem önizleme veren uç**
  aynısını çağırır. İki kopya = ekran bir tarih gösterip modül başkasına fiş keser; hata mesajı yok,
  fark **defterde** görülür. (Kural bu işte **iki turda iki kez** değişti — tek dosya olduğu için
  ikinci değişiklik 3 satırlık oldu.)
  ℹ️ **Batch'in gerçeği (ölçüldü, artık taklit edilmiyor):** ters fiş hesaplanan bir ileri tarihe değil
  `ReverseBatchItem`'ın **kendi koşu gününe** kesiliyor (MM **ve** FX'te aynı). Aynı güne mi sonraki
  güne mi kesildiğini `Revaluation:MM.ReverseType` (`Eod`→aynı gün · `Bod`→sonraki koşu günü ·
  `Atomic`→dönem sonu BOD/diğerleri EOD), hangi günlerde koştuğunu `SystemWDFlag` belirliyor
  (`WeekdaysOnly`→guard `Fail` → yalnız iş günleri · diğerleri→her gün).
  🔴 **Bilinçli ödün:** `WeekdaysOnly` kurulu müşteride ekran hafta sonuna, batch bir sonraki iş
  gününe kesebilir. Fimple/muhasebe hafta sonu valörünü reddederse kural yeniden konuşulacak.
  ⚠️ FX manuel reeskontu **zaten** `valuationDate.AddDays(1)` yapıyor (`ValuationService.cs:329`) —
  yeni kural FX ile hizalı. FX'in işe yarar ayrı deseni: regenerate'te yeni ters fişin tarihi
  **mevcut ters fişten** okunuyor (`reverseDate = reverse.ValueDate`), yeniden hesaplanmıyor.
  ⚠️ Bilinen batch bug adayı: `HolidaysButNotWeekends` (2) için guard **eksik** (yalnız `WeekdaysOnly`
  kontrol ediliyor) → o müşteride batch hafta sonu da koşuyor.
  ⚠️ **Tespit edilmedi:** EOD içinde `RevaluationBatchItem` ↔ `ReverseBatchItem` sırası DB'den geliyor.

- 🔴 **Özellik geri alınabilir — "platform plumbing"i önce ÖLÇ, sonra yaz (2026-08-21, yaşandı):**
  Manuel Reeskont'a "hangi transaction işleniyor" göstergesi için poll altyapısı yazıldı (~550 satır:
  process-içi tracker + uç + 2 DTO + WebUI DTO kopyası + Refit + resolver + query service + controller
  action + JS poll döngüsü + 9 test) ve **aynı gün kullanıcı kararıyla tamamen kaldırıldı**:
  *"Faz 1 için gerekli değilmiş, daha sonra daha güzel bir yapı kurulacak."*
  🔑 **Ders:** bu platformda tek bir `int`i dışa açmak **7 dosyaya** dokunmak demek
  (`RequestBase`/`ResponseBase` çifti · handler · controller · WebUI DTO kopyası · Refit metodu ·
  resolver · query service). Küçük bir UX kazanımı için bu maliyeti **önce söyle**, sonra yaz —
  kullanıcı "değer mi?" sorusunu koddan sonra deyil **önce** cevaplamak istiyor.
  ✅ İşe yarayan taraf: özellik **izole** yazılmıştı (5 yeni dosya + opsiyonel alan) → geri alma
  sözleşmeyi kırmadı, 20 dakikada temizlendi. Yeni bir "belki istenmez" özelliği **hep böyle** yaz.

- **DevExtreme `export: { enabled: true }` grid'in ÜSTÜNE bir toolbar satırı ekler → tablo aşağı kayar (2026-08-20):**
  Kullanıcı bunu "tablo bir satır aşağı inmiş" diye fark etti. Buton grid dışında isteniyorsa:
  `export.enabled = false` + kendi butonun + `DevExpress.excelExporter.exportDataGrid` (exceljs +
  FileSaver Web.UI ana layout'ında **zaten yüklü**: `_FrameworkDependencies.cshtml:71-72`).
  Konumlama emsali: `MmTransaction/Index` → `.mm-import-wrapper` (`position: absolute`, akışta yer
  tutmuyor, grid'i kaydırmıyor).
  ⚠️ Sunucu taraflı sayfalı grid'de export **yalnız görünen sayfayı** yazar — buton ipucunda söyle.

- **Web.UI'de grid'i sayfa boyunca uzatmanın house pattern'i (2026-08-20):**
  Yükseklik **`.dx-gridbase-container`**'a verilir, grid div'ine değil:
  `#dgX .dx-gridbase-container { height: calc(100vh - 210px); min-height: 400px; }`
  (`money-market.css:1-5`). Dış div'e vermek pager'ı grid içine gömüyor. Dinamik id'li bileşenlerde
  seçici `[id^="mrGrid_"]` gibi prefix'le yazılır (tek kural, 3 ekran). Çıkarılan pay ekranın grid'inin
  **nerede başladığına** göre ayarlanır (filtre/pill/özet şeritleri varsa 340px gibi).
- 🔴 **Fimple: DEFTER (ledger) hesabına `ReferenceType`/`ReferenceNumber` gönderilemez — `Code 3058` (2026-08-20):**
  *"Hesap tanımında defter türündeki muhasebe hesapları için referans türü ve referans no alanları
  boş olmalıdır. Defter hesabı: (36099200)"*
  `NetTrex.MM.Common.Mapper/.../FimpleAccountingDetailModelMapper.cs:46` referans alanlarını
  **yalnız `CustomerAccountCode != null`** koşuluna bakarak doldurur; GL'in defter hesabı olup
  olmadığına **bakmaz** (o bilgi Fimple'da). Muhasebe kuralı (`AccAccountMap`) defter hesabı için
  de müşteri hesap kodu üretirse mapper görevini yapar ve Fimple reddeder.
  ✅ **Çözümün doğru evi KONFİGÜRASYON:** ilgili `AccAccountMap` satırı müşteri hesabı üretmesin →
  `CustomerAccountCode` null → mapper kendiliğinden `ReferenceType: null` gönderir. **Kod
  değişikliği gerekmez.** Mapper'a "defter hesabı listesi" koymak Fimple'ın hesap tanımının
  ikinci bir kopyasını MM'de tutmak olur → kaçınılmaz sapma.
  ⚠️ Mapper ve `FimpleAccountingService` **tüm MM muhasebe akışlarında ortak** (transaction, term
  payment, revaluation, reverse) — yani hata **ekrana özel değil**, EOD batch de aynısını alır.
  🔑 *"Ekranda patlıyor ama batch'te çalışıyor"* izlenimine kapılmadan önce **iki yolun aynı
  servisten geçip geçmediğine** bak; Manuel Reeskont'ta ikisi de `15_RevaluationAccountingSyncStep`.

- **DevExtreme dialog'u iki temada da okunur yapmanın yolu: dark'a özel kural DEĞİL, dialog'u kendi kendine yeterli kılmak (2026-08-20):**
  `dxPopup` gövdesinin zemini temadan gelir; içine açık tema için sabitlenmiş metin renkleri
  (`#333` gibi) yazarsan **dark mode'da koyu zemin + koyu yazı** olur ve okunmaz. Seçili bir
  öğeye açık zemin verdiysen (`#EAF3FC`) metin rengini de yazmazsan dark'ta **beyaz yazı**
  düşer — o da okunmaz.
  ✅ Dokümanda sabit bir tasarımı olan dialog için `@media (prefers-color-scheme)` /
  `.dx-theme-dark` seçicisi **yazma**: `dx-popup-content` zeminini, metin rengini, alt toolbar'ı
  ve seçili öğe renklerini **açıkça** ver. Tek kural seti iki temada da aynı sonucu verir.
  ⚠️ Bu yaklaşım **grid için geçerli değil** — grid temayla uyumlu kalmalı; yalnız tasarımı
  sabitlenmiş pencereler için.

- 🔴 **DevExtreme `columnFixing: { enabled: true }` — hiçbir kolon sabit değilken BAŞLIKLARI SİLER (2026-08-20):**
  Kolon sabitleme açılınca DevExtreme ayrı bir `.dx-datagrid-content-fixed` tablosu üretiyor.
  **Hiçbir kolon `fixed: true` değilse** bu tablonun başlık hücreleri **boş** kalıyor ve gerçek
  başlığın üstünü örtüyor. Belirti çok karakteristik: **seçim checkbox'ı görünür** (o sabit
  tabloda), **kolon adları görünmez**, veri satırları normal.
  ⚠️ Konsola hata yazılmıyor, JS testleri göremiyor.
  **Kural:** `columnFixing`'i yalnız en az bir kolona `fixed: true` verirken aç.
  🔑 **Daha genel ders:** bir grid'e **aynı turda birden çok davranış ayarı eklenmez**
  (`columnFixing` + `rowAlternationEnabled` + `allowColumnResizing` + `columnResizingMode` +
  `columnMinWidth` + `wordWrapEnabled` birlikte gitti) — hangisinin ekranı bozduğu tarayıcıda
  tek tek denenmeden anlaşılmıyor ve hepsini geri almak gerekiyor.

- 🔴 **`RefitExtension.GetFimpleContentOrThrowAsync` hata gövdesini koşulsuz JSON sanıyordu → GERÇEK HATA GİZLENİYORDU (2026-08-20):**
  `NetTrex.MM.Common.Services/Extensions/RefitExtension.cs:30-31` HTTP başarısız olduğunda
  `apiResponse.Error.Content`'i doğrudan `JsonConvert.DeserializeObject`'e veriyordu. Gateway/proxy
  düz metin döndürünce (`Not Found`, HTML) Newtonsoft ilk karakter **`N`**'yi görüp **`NaN`** parse
  etmeye çalışıyor: *"Error parsing NaN value. Path '', line 1, position 1"*. (`I` ile başlayan
  gövdede aynı şey `Infinity` için olur.)
  🔴 Sonra `catch (JsonException)` bunu *"Failed to parse the API response"* diye sarıyordu →
  **HTTP durum kodu ve gövde hiçbir yere yazılmıyordu**. Ekranda "parse edemedim" görünüyor,
  gerçek olay "Fimple 404 döndü" olabiliyor. Yani parse hatası değil, **teşhis kaybı**.
  ✅ **Desen:** parse etmeden önce `TrimStart()[0]` `{`/`[` mi diye bak; değilse
  `HTTP {kod} ({durum}). Body: {ilk 500 karakter}` ile fırlat. `catch (JsonException)` mesajına da
  `ex.Message` ekle. JSON gövde yolu ve başarılı yanıt yolu **değişmez**.


- **Log handler'ları JSON varsayıyor → form-urlencoded gövde first-chance exception yağdırıyor (2026-08-20):**
  `NetTrex.MM.Common.Services/Handlers/ExternalHttpLoggingDelegateHandler.cs` giden **her** isteğin
  gövdesini `JsonDocument.Parse` ile güzelleştiriyordu. Fimple'ın **token** ucu ise
  `application/x-www-form-urlencoded` gönderiyor (`FimpleAuthService.cs:29` →
  `client_id=…&client_secret=…&grant_type=…`) → `'c' is an invalid start of a value.
  LineNumber: 0 | BytePositionInLine: 0`.
  ⚠️ **Hata gibi görünüyor ama değil:** `try/catch` vardı, gövde ham dönüyordu, akış bozulmuyordu.
  Kullanıcı **first-chance exception** görüyordu — Manuel Reeskont satır başına Fimple'a gittiği
  için çok sıklaştı ve debug'ı boğdu.
  ✅ **Desen:** parse etmeden **önce** ucuz bir kontrol — `TrimStart()[0]` `{` veya `[` mi?
  `catch` yine kalsın (bozuk JSON mümkün). Çıktı **değişmez**, yalnız exception atılmaz.
  🟥 **Aynı yerde ayrı bir sorun:** parse başarısız olunca gövde **ham** loglanıyor →
  `client_secret` **düz metin** olarak log'a yazılıyor. Maskelenmesi gerek; handler MM'in tüm
  Fimple çağrılarını kapsadığı için kullanıcı onayı bekliyor.

- 🔴 **DevExtreme `int` alanı `number` sayıp KOLONU SAĞA YASLIYOR — başlık dahil (2026-08-20):**
  `dataField: "Status"` (alan `int`) için `alignment` **yazılmazsa** DevExtreme tipi `number`
  çıkarıp hücreyi **ve başlığı** sağa yaslıyor. Manuel Reeskont'ta rozet kolonu bu yüzden sağa
  kaçmıştı; ekran görüntüsünde "Status" başlığı tek başına sağda duruyordu.
  ⚠️ Finansal ekranda **sağa yaslı kolon "tutar" okunur** → müşteri numarası / durum kodu gibi
  sayısal-ama-tutar-olmayan alanlarda hizalamayı **açık yaz**. `cellTemplate` bunu düzeltmez
  (template hücre içeriğini üretir, hizalamayı kolon ayarı belirler).

- 🔴 **Web.UI → modül Refit çağrılarında TIMEOUT AYARLI DEĞİL → sessiz 100 saniye duvarı (2026-08-19):**
  `Trex.WebUI/Trex.FrameworkCommon/Api/RefitExtensions.cs` → `RegisterClientWebApiRefitClients<T>`
  yalnız `BaseAddress` ayarlıyor, **`Timeout` ayarlamıyor** → `HttpClient` varsayılanı **100 sn**.
  Ekranların çoğu için yeterli; ama **dış sistemde (Fimple) iş yapan** uçlar satır başına
  ~6-50 sn sürüyor → 3-4 satırlık tek bir istek yapısal olarak patlıyor:
  *"The request was canceled due to the configured HttpClient.Timeout of 100 seconds elapsing"*.
  🔴 **İptal işi geri almıyor:** WebUI beklemeyi bırakıyor, modül döngüsü **arka planda devam edip
  fiş kesmeye devam ediyor** — kullanıcı sonucu göremiyor. Yani bu bir "yavaşlık" değil,
  **yanlış sonuç raporlama** sorunu.
  ✅ **Çözüm deseni** (Manuel Reeskont'ta uygulandı): ilgili arayüz için `AddRefitClient`'ı **ikinci
  kez** çağır ve yalnız `Timeout`'u yaz — `IHttpClientFactory` adlandırılmış istemci ayarları
  **eklemeli** olduğu için ilk kaydın `BaseAddress` delegesi ve handler zinciri korunur:
  `services.AddRefitClient(typeof(IXxxApi), <AYNI RefitSettings>).ConfigureHttpClient(c => c.Timeout = …)`,
  ilgili `RegisterClientWebApiRefitClients` çağrısından **SONRA**.
  🔴 **Bu kodu `Trex.FrameworkCommon/Api/RefitExtensions.cs`'e YAZMA** — kullanıcı kararı 2026-08-19:
  o dosya 19 marker'ın tamamının geçtiği paylaşılan yol, yan etkisi ancak her ekran tek tek test
  edilerek görülebilir (*"benim yapımdaki timeout durumlarını ellemişsin, bu isteyeceğim bir şey
  değil… side effect'inin ne olacağını bilemem"*). **Ayarı ekranın kendi klasörüne koy.**
  Emsal: `Trex.WebUI/Services/ManualRediscount/ManualRediscountRefitRegistration.cs` +
  `Startup.cs`'te tek satır tam nitelendirilmiş çağrı. Blast radius = **1 arayüz**.
  ⚠️ İkinci kayıtta **`RefitSettings`'i geçmek ZORUNLU** (Newtonsoft + camelCase) — DI kaydı
  yenilendiği için geçilmezse Refit varsayılan serializer'a düşer, gövde PascalCase gider ve
  modül alanları `null` okur.
  ⚠️ Re-register'da **`AddHttpMessageHandler` ÇAĞIRMA** — aynı handler zincire ikinci kez eklenir
  ve iki kez koşar (auth header iki kez yazılır).
  ⚠️ Genel `RegisterClientWebApiRefitClients`'a global timeout **koymayın** — 19 marker'ın tamamını
  etkiler ve asılı kalan çağrıları gizler.

- 🔴 **`dotnet test` VSTest ile MM testlerini BULAMIYOR — `xunit.v3` (2026-08-19):**
  `NetTrex.MM.Api.Services.Tests` `xunit.v3` kullanıyor → **Microsoft Testing Platform**, test dll'i
  **doğrudan çalıştırılabilir**. `dotnet test <csproj>` (filtreyle ya da filtresiz) build'i yapıyor
  ama *"No test is available … Make sure that test discoverer & executors are registered"* diyor —
  **hata gibi görünüyor, aslında yanlış koşucu**. Doğrusu:
  `cd Code/UnitTest/Api/NetTrex.MM.Api.Services.Tests/bin/Debug/net10.0 && ./NetTrex.MM.Api.Services.Tests.exe`
  (190 test, ~7 sn). "Testler kayboldu / hiç test yok" izlenimine kapılma.


- 🔴 **EF Core: `IsRequired()` navigation'ı `.Select()` projeksiyonunda dereference etmek SATIRI SESSİZCE SİLER (2026-08-18):**
  Required navigation → EF **INNER JOIN** üretir ve `x.Nav != null` guard'ını **sadeleştirip atar**.
  FK dolu ama karşılığı yoksa (**orphan**) satır sonuç kümesinden **sessizce düşer** — hata/log yok.
  🔴 `CountAsync()` o join'i yapmadığı için **saymaya devam eder** → **sayım ile liste ayrışır**.
  Canlı örnek (Manuel Reeskont, `NetTrex.MM`): ekranın özet şeridi *"1 Not Reversed"* derken grid'de
  satır yoktu; API'de `totalCount = 1` / `items = 0` (aynı sorgu). Sebep: `TxnMM.CustomerId = 1086`
  → `cusCustomer`'da yok, `Customer` navigation'ı `IsRequired()`.
  ✅ **Desen:** alanı navigation'dan değil **skaler subquery**'den oku —
  `repo.Queryable().Where(c => c.Id == x.FkId).Select(c => c.Name).FirstOrDefault()`.
  ⚠️ Birim test ve derleme bunu **göremez** (gerçek DB + orphan veri gerekir). Bir grid'de
  *"özet N diyor ama liste boş"* görürsen **önce buraya bak**. Detay → `NetTrex.MM/.ai-agent/MEMORY.md`.
  🔴 **İKİNCİ VE DAHA TEHLİKELİ VARYANTI (2026-08-19):** aynı desen `Where(...)` içinde, bir kaydın
  **var olup olmadığını** sorgulayan yerde kullanılırsa sonuç satır kaybı değil **MÜKERRER KAYIT**
  olur. Manuel Reeskont'ta `AccountingDataManager.GetRevaluationByValueDateAsync`
  MM/InterbankLoan ayrımını `x.TransactionLoan.ProductDefinition.MainProductCode == x.ProductCode`
  ile yapıyordu; zincirin tamamı required → INNER JOIN. Transaction ya da ürün tanımı satırı eksikse
  **mevcut fiş bulunamıyor**, durum `NotRediscounted` türetiliyor ve aynı güne **İKİNCİ bir reeskont
  fişi** kesiliyor — gerçek para, hata mesajı yok.
  ✅ Bu durumda çözüm **EXISTS**: `repo.Queryable().Any(t => t.Id == x.FkId && t.Nav.Field == …)`.
  `Any(...)` join üretmez; eksik satır yalnız koşulu `false` yapar.

- 🔴 **DevExtreme `WidgetFactory` içinden `IHtmlHelper`'ı reflection ile çekmek — `GetFields` YETMEZ (2026-08-14):**
  `Html.DevExtreme().X()` biçiminde kendi bileşenini yazmak için `WidgetFactory<TModel>`'den `IHtmlHelper`'a
  ulaşmak gerekir (ViewComponent çağırmak `ViewContext` ister). Helper **field değil**: base sınıftaki
  **non-public `Html` property**'sinin döndürdüğü `HtmlHelperAdapter`'ın `_html` field'ında
  (`Framework.WebUI/Extensions/DevxReflectionExtension.cs:25,34` bunu zaten belgeliyor).
  `factory.GetType().GetFields(NonPublic)` ne property'leri ne de **base sınıfın private field**'larını döndürür
  → `null` → runtime `InvalidOperationException` → **ekran 500**.
  ⚠️ **Derleme ve birim testler bunu GÖREMEZ** — Manuel Rediscount'ta 0 derleme hatası + 74 MM + 334 JS test
  yeşilken ekran tarayıcıda ilk açılışta 500 verdi.
  **Kural:** böyle bir bileşen için önce **reflection'sız `this IHtmlHelper` overload**'ını yaz ve view'larda
  **onu** kullan; `Html.DevExtreme().X()` biçimini isteyen varsa ikinci overload olarak dursun.
  Reflection şart olduğunda **kalıtım zincirini yürü** ve hem field hem property bak.
- 🔴 **Deploy edilmiş modül API'si kaynaktan geri kalabilir — 404 → NullReference (2026-08-14):**
  `NetTrex.Web.UI` login'i `POST {CommonApi}/UserProfile/check-user-profiles-and-claims` çağırıyor
  (`LoginController.cs:78`), yanıtı `:83`'te `userClaims.Data.HaveAnyClaim` diye **null kontrolsüz** okuyor.
  `192.168.10.173:5051`'deki Common deploy'unda bu uç **yoktu** (swagger'da `verify`/`reject`/`history`/
  `check-user-profiles-and-claims` **hiçbiri yok**, kaynakta hepsi var) → 404 → `Data` null → **login komple 500**.
  **Kural:** "ekran/uygulama sebepsiz patladı" derken önce **hangi dış API'ye gidiyor** ve o deploy'un
  **swagger'ı ucu içeriyor mu** bak (`curl {api}/swagger/v1/swagger.json`). Docker'da adresler
  `Code/docker-compose.override.yml`'de (`Framework__Application__CommonApi`, `CommonApi`, `MMApi`, …) —
  çoğunun local karşılığı yorum satırında hazır duruyor.
- 🔴 **`FrameworkMenu`'ye satır eklemek yetmez — Redis menü cache'i invalidate olmuyor (2026-08-17):**
  `NetTrex.Common/.../Business/Common/Definitions/MenuDefinition/GetModuleMenuHandler.cs` kullanıcı bazlı
  menü listesini Redis'te cache'liyor (`ModuleMenu:{UserId}`, hash field `{MODULE}:{LANG}:{scheme}`,
  **TTL 8 saat** — `RedisParameterConstants.cs:65`). `FrameworkMenu` tablosuna INSERT/UPDATE yapan hiçbir
  yer (script veya kod) bu cache'i **temizlemiyor**. Sonuç: DB'ye yeni menü satırı eklensen bile (IsActive=1,
  ParentId doğru, her şey kurallara uygun) kullanıcı o modülü **daha önce en az bir kez** açtıysa 8 saat
  boyunca (ya da Redis flush'a kadar) eski listeyi görmeye devam eder — hata yok, sessiz bayatlık.
  Manuel Reeskont'ta 3 yeni menü satırı (`TreasuryReeskontKey` vb.) tam bu sebeple görünmüyordu.
  ⚠️ **Yanlış iz:** `ModuleName` kolonunun case'i (`'General'` vs `'GENERAL'`) şüpheliydi ama filtre
  `StringComparison.InvariantCultureIgnoreCase` kullanıyor — case **hiç önemli değil**, red herring.
  **Kural:** Menüye yeni satır eklerken (script veya UI) **Redis'teki `ModuleMenu:*` hash'ini de temizle**
  (ya da kullanıcıya "8 saat bekle / cache flush" de) — DB doğru göründüğünde bile menünün gelmemesi
  önce **cache**'ten şüphelenilmeli, koddan/DB'den değil.
- **Refit marker interface isimleri tutarsız (2026-08-12):** `NetTrex.Web.UI/Code/Web/UI/Trex.WebUI/Services/Abstract/`
  altında dosya adı ile tip adı **uyuşmuyor**:
  `IClientMmAPI.cs` → tip **`IClientMMAPI`** (çift M) · `IClientFundsAPI.cs` → tip **`IClientFundsAPI`** (Fund değil, **Funds**)
  · `Abstract/Options/IClientOptionsFXApi.cs` → tip **`IClientOptFXApi`**.
  `IClientOptionsApi` / `IClientFundApi` diye bir tip **yok**. Yeni bir modül client'ı yazarken tip adını
  **dosyadan değil, dosya içinden** doğrula.
- **Web.UI'de runtime base-URL resolver YOK (2026-08-12):** `Trex.FrameworkCommon/Api/RefitExtensions.cs:78`
  `RegisterClientWebApiRefitClients<T>` AppDomain'i tarayıp `T`'den türeyen her interface'e sabit `BaseAddress`
  atıyor. Named HttpClient yok, `IHttpClientFactory` doğrudan kullanılmıyor. Bir ekranın **runtime'da** farklı
  modül API'sine gitmesi için tek mevcut desen: **modül başına ayrı ince Refit interface** + `IServiceProvider`
  ile çözüm. Canlı örnek: `Controllers/Eod/Eod/EodController.cs:364` `GetRefitClient<T>()`.
- **Web.UI permission = ControllerAdı/ActionAdı (2026-08-12):** `BaseController` üstünde `[CustomAuthorize]`
  (policy `"Dynamic"`) → `PermissionHandler` `userManager.HasPermissionAsync(controllerName, actionName)` çağırıyor.
  **Sonuç:** tek generic controller yazılırsa tüm modüller/ekranlar **aynı** permission'ı paylaşır. Ekran bazlı
  yetki isteniyorsa **ekran başına ayrı controller** (veya action'da hardcoded permission adı) gerekir.
- **`Treasy.MM.UI`'de ekran bazlı sunucu yetkisi fiilen KAPALI (2026-08-12):** MM Micro UI'de tek bir
  `[CustomAuthorize]`/`[Authorize]` kullanımı **yok**; erişim kontrolü fiilen menü üzerinden yapılıyor
  (menü Common API'den kullanıcıya göre filtreli geliyor). Shell `appsettings.json`'da
  `Framework:Application:SkipAuthorization: true`. MicroUI'ye yeni ekran eklerken bu boşluğu bilerek ilerle.
- 🔴 **Compact hook'ları REPO BAŞINA kurulur — MM'de hiç yoktu (2026-08-12):** `PreCompact` ve
  `SessionStart:compact` hook'ları `.claude/settings.local.json`'da, **yalnızca Claude Code o reponun
  klasöründe başlatıldığında** çalışır. `Treasy.MM.UI`'de kurulu olduğu için oradaki compact'ler diske yazıldı;
  **`NetTrex.MM`'de `hooks` bloğu hiç yoktu** → o repodan yürütülen tüm sohbetlerin compact'leri **kayboldu**
  (kural MD'de yazılıydı ama tetiklenmedi — kullanıcı fark edip uyardı).
  **Kurulum 2026-08-12:** `NetTrex.MM` ✅ · `NetTrex.Web.UI` ✅ · `Treasy.MM.UI` ⚠️ `PreCompact` var
  (kendi instruction dosyasını okuyor, yeni formata güncellendi) ama **`SessionStart:compact` eklenemedi** —
  `settings.local.json`'a yazma **classifier tarafından engellendi**, kullanıcıya JSON verildi.
  **Ders:** `PreCompact` tek başına yetmez — sıkıştırmadan **önce** tetiklendiği için yazacak tur kalmayabilir.
  Asıl yazma anı **`SessionStart` matcher `compact`**: sıkıştırmadan hemen sonra, özet context'te, tur var.
  Yeni repoda çalışmaya başlarken şablon: `NetTrex.MM/.claude/settings.local.json`.
- 🔴 **`ManualRediscount` adı Web.UI'de ZATEN DOLU — namespace, using ile gelen sınıfı gölgeler (2026-08-13):**
  `Trex.Common.Models.Enums.ManualRediscount` eski FX/FI reeskont ekranlarının **nested enum kabı sınıfı**
  (`RediscountProductTypes`, `RediscountStatusTypes`). Manuel Reeskont'u İngilizceleştirirken
  `…Models.ManualRediscount` / `Trex.WebUI.Controllers.ManualRediscount` **namespace**'leri açıldı →
  eski dosyalarda bare `ManualRediscount.RediscountX` artık **namespace**'e çözülüp 14 derleme hatası verdi:
  `CS0234: The type or namespace name 'RediscountProductTypes' does not exist in the namespace '…ManualRediscount'`.
  Çözüm: eski 4 dosyada 13 satır tam nitelendirildi (`Trex.Common.Models.Enums.ManualRediscount.RediscountX`).
  **Kural:** yeni bir **namespace segmenti** seçmeden önce aynı adda **sınıf** olup olmadığını da ara —
  namespace, `using` ile gelen sınıf adını gölgeler ve hata **dokunmadığın dosyalarda** patlar.
  Ayrıca `Trex.Web.Business.Models.Enums` içinde de **aynı adlı** `RediscountProductTypes`/`RediscountStatusTypes`
  enum'ları var (Common'daki nested olanlardan **ayrı**) — reeskont enum'ı ararken hangisini bulduğunu doğrula.
- 🔴 **Eski ekranla doküman çelişirse DOKÜMAN kazanır (2026-08-13, Manuel Reeskont dersi):** Manuel Reeskont'ta
  rozet renkleri **mevcut FX ekranından** (`Views/ManuelReescont/Index.cshtml:246-275`) kopyalanmıştı; doküman § 7.1
  `Processing` **mavi** / `NotReversed` **sarı** derken eski ekran sarı/mor kullanıyordu → iki renk **yanlış** çıktı.
  Aynı tur içinde ikinci örnek: `Regenerate` + `NotRediscounted` eski mantıkla **fail** ediyordu, oysa görsel
  (`image6`) *"yeni değerleme oluşturulur"* diyor — **davranış hatası**. **Kural:** mevcut ekrandan desen/kod
  kopyalamak meşru, ama **iş kuralı ve görsel spesifikasyon dokümandan** alınır; çelişki görülünce doküman esas.
- **Web.UI'de JS birim testi ALTYAPISI VAR ama kurulu değil (2026-08-13):** `NetTrex.Web.UI/Code/UnitTest/Trex.WebUI.Tests/JSTests/`
  altında jest + jsdom yapılandırması hazır, ama `node_modules` **repoda yok** → `npm install` gerekiyor.
  Çalıştırma: `JS_ROOT` **Windows biçiminde** verilmeli (`C:\\Users\\…\\NetTrex.Web.UI\\Code`) — POSIX yolu
  (`c:/Users/...`) verilince `testMatch` **hiçbir dosyayı bulamıyor** ("0 matches", ölçüldü).
  `npx jest --testPathPattern <ad>` ile tek dosya koşulur. Desen: düz tarayıcı betiklerini `new Function`
  gövdesinde yükleyip bağımlılıkları (`$`, `formatMessage`, `DevExpress`, `console`) parametre olarak enjekte etmek
  (`require` modül kapsamında bırakır, `vm.runInThisContext` ikinci yüklemede "already declared" ile patlar).
  `jsCoverage.test.js` her JS dosyasını parse ediyor → **yeni JS dosyası eklerken bu test bedava sözdizimi kontrolü**.
- **`Html.DevExtreme().X()` uzantısı yazmak için tip `WidgetFactory<TModel>`, namespace `DevExtreme.AspNet.Mvc.Factories` (2026-08-13):**
  `using DevExtreme.AspNet.Mvc;` **yetmez** → `CS0246: 'WidgetFactory<>' could not be found`. Ayrıca DevExtreme
  `IHtmlHelper`'ı **public açmıyor**; ViewComponent çağırmak için `ViewContext` gerektiğinden **reflection** şart
  (framework'te emsali var: `Framework.WebUI/Extensions/DevxReflectionExtension.cs`). `IViewComponentHelper`
  `Microsoft.AspNetCore.Mvc` namespace'inde ve Razor dışından çağrılırken `((IViewContextAware)helper).Contextualize(...)`
  **zorunlu**.
- **Web.UI JSON serileştirmesi PascalCase (2026-08-13):** `Framework.WebUI/MvcStartup.cs:154` →
  `AddNewtonsoftJson` + `DefaultContractResolver` → property adları **olduğu gibi** gider. Bu yüzden DevExtreme
  grid `dataField`'ları PascalCase (`"LogicalReference"`) yazılır. ⚠️ Anonim objede `new { isSuccess = … }`
  yazarsan **küçük harf kalır** — controller'da karışık kullanım var, JS tarafında hangisinin geldiğini
  **anonim objenin yazımından** doğrula.
- **`Treasy.MM.UI` doküman bayatlığı — SharedDependency sürümü (2026-08-12):**
  `Treasy.MM.UI/.ai-agent/PROJECT_CONTEXT.md:14` ve `inventory/shareddependency-yuzey.md:1` **1.0.3** diyor,
  gerçek referans (`src/Treasy.MM.UI.Core/Treasy.MM.UI.Core.csproj`) **1.0.4-dev12**. Paket yüzeyi hakkında
  karar verirken sürümü **csproj'dan** doğrula, dokümandan değil.

---

- 🔴 **"Base component" iddiasını view'daki bir GLOBAL bozar (2026-08-21, yaşandı):** Manuel Reeskont bileşeni çok instance'ı `uniqueKey` ile açıkça destekliyordu, ama partial'ın içindeki `window.mrInstance = ...` **tek slot** olduğu için aynı sayfada iki ekran açılsa filtre değişimi **yanlış grid'e** giderdi. DevExtreme `OnValueChanged("ad")` bir **global fonksiyon adı** istediği için bu tuzak kolay kuruluyor.
  ✅ **Desen:** olay yönlendiricisi bileşenin **kendi giriş dosyasında** (`*.init.js`) yaşar ve instance'ı **olayın geldiği editörün id'sinden** (`mrExecutionDate_trs` → `trs`) çözer; view yalnız `init({...})` çağırır.
  🔑 Aynı denetimin ikinci bulgusu: **host'a özel yol** (`AccountingEntry/Index`, uygulama kökü) bileşenin içinde sabitse o bileşen başka bir host'a (MicroUI) **taşınamaz** — konfigürasyona al, `settings` global'ine yalnız **son çare** olarak düş (`typeof` guard'lı).

- 🔴 **Seq'te LOCAL ve CLUSTER AYNI sunucuya yaziyor ve ayirt edici property YOK — olaylari
  ConnectionId + Kafka gurultusu ile ayir (2026-09-04, olculdu):** Launch profile
  `Serilog:WriteTo:0:Args:serverUrl` cluster Seq'ini (`192.168.10.191:30180`) gosterdigi icin local MM de
  oraya yaziyor. Olay property'leri **tam olarak** `ActionId, ActionName, Application, ApplicationName,
  ConnectionId, Environment, RequestId, RequestPath, SourceContext` — makine/pod alani **yok**, ve
  `Environment` her iki tarafta `Development` (`appsettings.json` oyle yaziyor, cluster ezmiyor).
  ✅ **Ayirt etme deseni:** (a) Kestrel `ConnectionId`'nin ilk ~11 karakteri **process kimligidir** —
  ayni prefix = ayni process; (b) hangi process kimin oldugunu **Kafka gurultusu** soyler:
  `localhost:9094` hatasi yagan local (launch profile), `9092`/sessiz olan cluster; (c) `RequestPath`
  hostu (`http://nettrex-mm-web:5041/...`) cluster'i kesinlestirir.
  ⚠ **Zaman penceresiyle ayirmak YETMEZ** — bu isde bir DB satirinin (`accEntryMain 556002`) cluster
  tarafindan yazildigini sandim, process eslemesi yapinca **local**'in yazdigi cikti; o yanlis esleme
  "cluster once basardi sonra patladi" diye tamamen yanlis bir kok-neden hikayesi uretmisti.
  🔑 Sorgu: `/api/events?count=&render=&fromDateUtc=&toDateUtc=&filter=` + `X-Seq-ApiKey`;
  PowerShell'de `Invoke-WebRequest -UseBasicParsing` **zorunlu** (yoksa NonInteractive hatasi).

- ⚠ **`AccEntryEntity ... already being tracked` (cluster'da patliyor, local'de gecmiyor) — CURUTULEN
  HIPOTEZLER, bir daha aranmasin (2026-09-04):** Ayni commit + ayni DB + ayni satir + ayni tarihte
  cluster patliyor, local geciyor (olculdu). Elenenler: mukerrer `accEntry.Id` (yok) ·
  `sp_GetNewNumbers` (tek `UPDATE ... WITH (ROWLOCK, UPDLOCK)`, tam `@CountToGenerate` kadar **tekil**
  sayi → kisa/mukerrer liste uretemez) · captive DI (MM'in tum Scrutor kayitlari `WithScopedLifetime`) ·
  `AutoInclude` (repoda hic kullanilmiyor) · hosted service / background consumer (API'de yok) · Kafka ·
  Fimple flag (loglarda Fimple cagrisi yok) · timezone (status dogru eslesti → container +03) ·
  **process'te birikme** (her iki cluster pod'unda **ilk** istek zaten patliyor).
  🔑 Hata Agustos'tan beri **yalnizca** `/api/manual-rediscount/executions` yolunda; EOD batch dahil
  hicbir MM ucunda yok. Firlatma noktasi **tespit edilmedi** — Manuel Reeskont yolundaki her okuma
  `AsNoTracking`, o yuzden statik analizle bulunamiyor. Sonraki adim: `ExecutionsHandler` catch'inde
  `logger.LogError(ex, ...)` ile **tam stack** Seq'e yaziliyor (2026-09-04 eklendi) → bir sonraki
  olusumda firlatma noktasi ve cakisan `Id` dogrudan gorunecek.

- 🔴 **MUHASEBE MOTORUNDA SILME: zincirde FK YOK, yanlis sira ORPHAN uretir - hata vermez
  (2026-09-10, olculdu):** `NetTrexAcc`'te tum `Acc*` tablolarinda **6 FK** var ve zincirin
  **tek**i `Group.EventId`. `Event.ItemId` - `Component.GroupId` - `AccountRule.ComponentId`
  **FK degil** -> ustten silersen alt seviyeye join ile **ulasilamaz**, satirlar **sessizce**
  sahipsiz kalir. Olcum: DB'de hali hazirda **454 sahipsiz `AccountRule`, 80 `Component`,
  5 `Event`** duruyor (gecmiste boyle olusmus).
  ✅ **Desen:** kademe kademe join yerine **once SNAPSHOT** (Id'leri tablo degiskenlerine topla),
  sonra `Id IN (...)` ile yaprak->kok sil. Sonda **kalinti sayimi 0 degilse `THROW`**.
  🔴 **Path capasi `LIKE 'TREX/X%'` YETMEZ:** kok Path'ler karisik (`TREX/FI` slash'siz,
  `TREX/MM/` slash'li) ve capa `TREX/MMXYZ`'ye uzanir. Dogrusu
  `= 'TREX/X' OR = 'TREX/X/' OR LIKE 'TREX/X/%'`. Ayrica ayni `ItemCode` **baska agacin
  altinda** olabilir (`TREX/SEC1/FI`, ParentId 1000) - script dokunmadiklarini **ekrana bassin**.
  🔴 **Iki tablo unutuluyor:** `AccEngineDynamicMap` (kendi `Path`'i var; eski
  `tumyapiyiSilmeScript`'te **yoktu**, cunku BRWPLC1'in satiri yoktu) ve tersi -
  `AccEngineGeneratedAccountRule` **silinmemeli** (kural degil, `Amount`/`AccountingValueDate`
  tasiyan **uretilmis fis**). `AccEngineComponentAccount`'ta `ComponentId` **yok**
  (`ComponentTypeCode`+`GLCode`) - paylasilan tablo, dokunma.
  ✅ **Prod silme script'i sablonu:** `USE [__PROD_DB_ADINI_YAZ__]` (bilerek gecersiz - unutulursa
  hemen durur) + `@DryRun BIT = 1` (rollback'li deneme turu) + agac bulunamazsa dur + uretilmis fis
  varsa dur. Emsal: `.ai-agent/outputs/2026-09-10-AccEngine-Politika-Silme/` (5 script + `00-OKU-BENI.md`).
  Detay -> `skills/accounting-db-script.md` §4.9 ve `NetTrex.MM/.ai-agent/feature-research/Accounting-Engine-research.md` §4.8.

- 🔴 **LOCALIZATION SÖZLÜĞÜ KÖR UYGULANMAZ — çeviri kaynağı `(EN metni + KEY bağlamı)` çiftidir
  (2026-09-10, ölçüldü):** İş biriminin Excel sözlüğü (`imports/localization-dictionary-en-tr 1.xlsx`,
  Yatırım + Katılım sekmeleri) `EN → TR` haritası veriyor. FX'te uygulanmış hâli (PR 11994 →
  `3de0ddaec`) ile karşılaştırıldı: **586/602 birebir (%97,3)**, ama sapan 16 satırın **hepsi**
  kör lookup'ın yanlış çeviri üreteceği yerler:
  (a) **`Rate` → sözlük `'Kur'`** (döviz kuru sanıyor) ama key `*InterestRate` ise doğru karşılık
  **`Faiz Oranı`** / katılımda `Getiri Oranı`. MM'de 16 kolon "Kur" yazacaktı.
  (b) **`No` → sözlük `'Hayır'`** ama key `*AccountNumber` ise `Hesap Numarası`. Kısaltmalar
  sekmesi bunu **zaten söylüyor**: `No → Numara (Acc No = Hesap Numarası)`.
  (c) **EN dosyası bozuk olabiliyor** — `dgPmTransactionValuation-MtmAmount` EN değeri `'Deal Rate'`,
  `formTxnSwap-SellAmnt` EN değeri `'Buy Amount'` (değerler bir satır **kaymış**). FX'i yazan kişi
  **key'e** göre çevirmiş. Yani EN'e körü körüne güvenilmez.
  (d) Sözlük iki farklı EN terimine aynı TR'yi verebiliyor (`Forward` ve `Future` → `Vadeli İşlem`);
  ekranda ayırmak gerekiyor.
  ✅ **Desen:** script + **override tablosu** (gerekçesi kodda tek satır yorum) + şüpheli satır
  heuristic'i (key kuyruğu ile EN metninin kelime örtüşmesi yok → işaretle; kısa/genel EN → işaretle).
  ✅ **Yazma biçimi:** JSON'u parse edip yeniden serialize **etme** — `"key": "value"` satırında
  yalnız değeri değiştir. Key sırası, `//` yorumları, BOM, girinti korunur; diff yalnız gerçek
  değişikliği gösterir (MM'de 749/749, tek satır fazlası yok).
  Emsal + script: `.ai-agent/outputs/2026-09-10-Localization-Excel-Uyarlama/` (`scripts/apply-mm.py`).

- 🔴 **`Trex.WebUI/Program.cs` localization bundler'ı ŞEMA DOSYALARINI DÜZ DİL BUNDLE'INA SIZDIRIYOR
  (2026-09-10, kanıtlandı):** `Program.cs:172` `Directory.GetFiles(dir, $"*{language}.json")` →
  `*tr.json` globu `main-menu-katilim.tr.json`'u da yakalıyor, düz `tr` bundle'ına karışıyor,
  alfabetik sırada **son yazan (yatirim) kazanıyor**.
  **Kanıt:** `mainMenu-QuantKey` + `mainMenu-VolSmileDeltaPlot` **yalnız** `main-menu-yatirim.tr.json`'da
  var ama `bundle.messages.tr.json`'da **duruyorlar**; `mainMenu-REPOTransactionsKey` katılımda
  *"Commitment-Based Sukuk Transactions"* iken düz `tr` bundle'ında *"REPO Transactions"*.
  ⚠️ Bugün gözle görünmüyor çünkü şema dosyalarının çoğu değeri baz ile aynı — ayrışan değerler
  girildiği an sızıyor.
  🔴 **İkinci kusur:** `dx.messages.loader.js` `bundle.messages.katilim.tr.json` istiyor, bundler
  `bundle.messages.katilim.json` üretiyor (2 byte `{}`) → şema dosyaları **hiçbir bundle'a girmiyor**,
  loader elle konmuş bayat dosyayı okuyor. **PR 11994'ün glob fix'i (`*-{language}.json`) bunu ÇÖZMÜYOR**
  ve o PR 2026-09-10'da revert edildi (`67ea683c`, PR 12136) — revert gerekçesi **tespit edilmedi**.
  ✅ **Çözüm 2 satır:** `LanguageList = { "tr","en","katilim.tr","katilim.en","yatirim.tr","yatirim.en" }`
  **+** glob `*-{language}.json`. Mevcut `bundle.messages.{0}.json` template'i o zaman loader'ın
  istediği adı üretiyor ve `*-tr.json` şemaları yakalamıyor.
  ✅ **Doğru emsal repoda var:** `Treasy.MicroUI.Packages/Treasy.MicroUI.SharedDependency/
  buildTransitive/Treasy.MicroUI.SharedDependency.targets` → `TreasyBundleLocalizationFiles`:
  son `-`'den sonrası **tek nokta** içeriyorsa `{scheme}.{lang}` grubu, hiç nokta yoksa düz dil →
  sızma **yapısal olarak imkânsız**. Yeni bir bundler yazarken buna bak.
  ⚠️ Banka tipi anahtarı (`Framework:Application:PreferredLanguageScheme` → `LanguageProvider` →
  `settings.languageScheme` → loader) **kurulu ve testli**; eksik olan yalnız bundler + veri.
  MicroUI tarafında da şema dosyaları `{}` — **anahtar takılı, kutu boş**.

## Açık İşler (cross-repo, oturumlar-üstü)

| İş | Durum | Pano |
|----|-------|------|
| **Manuel Reeskont — generic base component** | 🟡 Mimari **v2** (Common yok, WebUI→modül direkt) · sözleşme **dondurulmadı** · iş birimine 16 soru + Selim'e 7 teknik karar bekliyor · Faz 1 = Web.UI + MM | [`manuel-reeskont/00-PANO.md`](manuel-reeskont/00-PANO.md) |

- 🔴 **`AddScoped<IDataContext, EfDbContext>()` + `AddTreasyDbContext<EfDbContext>()` = AYNI SCOPE'TA
  IKI AYRI DbContext (2026-09-10, OLCULDU):** MM `AddRepository` ikisini birlikte kaydediyor.
  `IDataContext` kaydi container'a `EfDbContext`'i **kendisi aktive ettiriyor**; `AddTreasyDbContext`
  (= `AddDbContext`, pooling yok) ise **ikinci** bir kayit. Netix.Core.EfCoreRepository **10.0.4** ile
  MM'in kayit sirasi birebir taklit edilip olculdu:
  `IDataContext -> ctx=34d258b1...:0` · `EfDbContext -> ctx=5f3c4789...:0` · `ReferenceEquals = False`.
  🔑 **Sonuc:** `EfDbContext` enjekte eden bir sinif **repository'lerin tracker'ini GORMEZ**. Bu yuzden
  `ChangeTrackerDataService(EfDbContext context)` icindeki `ChangeTracker.Clear()` **bos bir context'i**
  temizliyordu — `AccEntryEntity ... already being tracked` hatasina karsi eklenen fix **hicbir branch'te
  (main dahil) fiilen aktif olmadi**, ve `DescribeContext()` her zaman `tracked=0 []` yaziyordu.
  ✅ Dogrusu: `IChangeTrackerDataService` **`IDataContext`** alir (`(DbContext)dataContext`).
  ⚠ **Ev deseni bunu zaten itiraf ediyor:** `CustomerRepository(IDataContext context, EfDbContext dbContext)`
  ikisini **birlikte** enjekte ediyor — ayni nesne olsalardi ikinci parametre anlamsiz olurdu.
  🔑 **Tasinabilir kural:** bir tracker/UnitOfWork teshisi yazarken *"repository hangi context tipini
  enjekte ediyor"* diye bak ve **ayni tipi** al. Yanlis context'ten alinan dokum sessizce **bos** doner
  ve "sorun yok" gibi okunur — testsizlikten daha tehlikeli.
  ⚠ Ayrica olculdu: step 20 mapper'i (`AccountingEntryMainEntityMapper`) her `AccEntryEntity`'yi
  `Id = 0` ile **sifirdan** kuruyor ve **hicbir navigation'i doldurmuyor** → tek bir `InsertAsync`'in
  grafigi temiz; cakisma **ayni scope'ta daha once kosan baska bir insert**'ten gelmek zorunda.

- 🔴 **`AccEntryEntity ... already being tracked`: TEMIZ CONTEXT KANITLA PATLAMIYOR — hata mutlaka
  KIRLI context'ten geliyor (2026-09-10, gercek modelle olculdu):** `NetTrex.MM.Data.Repository`'ye
  referans veren bir harness kuruldu; **gercek `EfDbContext`** (DI'dan, `AddSchemaMapping` +
  `MSSQLMappingAdapter` ile, yani `ApplyMappingFixes` **uygulanmis**), **gercek Netix
  `Repository<T>`** ve **canli Id'ler** kullanildi.
  | Senaryo | Sonuc |
  |---|---|
  | 2 bacak, tekil Id (canli 15:39: main 556009 / entry 5512391,5512392) | ✅ OK |
  | 4 bacak, tekil Id (canli 11:52) | ✅ OK |
  | 2 bacak, **ikisi ayni Id** | 🔴 **birebir prod hatasi** |
  | 2 bacak, Id = 0 | ✅ OK (`ValueGenerated=OnAdd` → temp key) |
  | sayac 1 numara eksik verirse (kuyruk Id=0) | ❌ **BASKA** hata: *"property 'AccEntryEntity.Id' is part of a key"* |
  | ayni main ikinci kez `InsertAsync` | ✅ OK (idempotent) |
  🔑 `Netix.Core.EfCoreRepository.Repository<T>.InsertAsync` = **`DbSet.Attach` + root'u `Added`**;
  cocuklar `Unchanged` kalir → `AccountingDataManager`'in ikinci satiri (`InsertRangeAsync`) **sart**.
  🔑 Model dogrulandi: `AccEntry` **1 key**, **3 FK** (`AccEntryMainId`→Main, `TxnId`→TxnMm **ve**
  `TxnId`→TxnLoan — ayni FK'da iki required iliski, ama hatanin sebebi **degil**).
  ⚠ **Sayac tarafi da kapatildi:** `sp_GetNewNumbers` tam govdesi okundu — tek `UPDATE ... ROWLOCK,UPDLOCK`
  + `@start = @new - @count + 1` ardisik CTE → **mukerrer uretemez**. Canli olcum: 15:39 istegi
  **tek** cagri yapti (Main +1, Entry +2, GeneratedAccount +2) → Id'ler **5512391/5512392**, tekil.
  🔴 **ACIK KALAN:** o iki tekil Id'den birini tasiyan **ikinci instance** context'e nasil girdi.
  Cakisan Id'ler o istekte **ilk kez** uretildigi icin ne DB okumasi ne de request'ler arasi
  paylasilan context bunu aciklamiyor. Teshis dokumu **yanlis context'i** okudugu icin (bkz. ustteki
  `IDataContext`/`EfDbContext` kaydi) hata ani **hic gorulmedi**.
  ✅ **Sonraki adim kod degil KONFIG:** Serilog'da `Microsoft.EntityFrameworkCore` seviyesini bir
  test icin `Information`'a cek → o istekteki **her SQL** gorunur (`EnableSensitiveDataLogging`
  gerekmez). MM loglarinda su an `Database.Command` olayi **hic yok**, suzuluyor.
