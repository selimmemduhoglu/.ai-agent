# progress-47 — MM/InterbankLoan izolasyon denetimi · **5 UX revizesi** (varsayılan tarih T-1 · statü anlamları · tarih biçimi · onay = kesilecek fişler · sürükle/boyutlandir)

**Tarih:** 2026-08-26 · **Repo:** `NetTrex.Web.UI` (bu turda **MM'e KOD DOKUNULMADI**)
**Test:** JS **431/431** (tamamı) · manualRediscount **131/131** · **Build:** WebUI 0 Error

> `progress-46`'nın tam hali + **bölüm 9** (izolasyon denetimi) + **bölüm 10**
> (kullanıcının 5 maddelik revize isteği).

---

## Kullanıcının soruları (1-3 önceki tur · 4 bu tur)

| # | Soru | Sonuç |
|---|------|:-----:|
| 1 | *"Neden `o tarihte aktif faiz dönemi var` şartına baktık, gerçekten gerekli miydi, önceden yazılmış sorguları referans alıp mı baktın?"* | ✅ Cevaplandı — **zorunlu**, iki bağımsız gerekçe |
| 2 | *"Statü durumlarında değerleme döngüsüne hakim olmak lazım… `isReverse` ve `reverseId`'ye bakman yeterli değil, bir de T+1 durumuna bakmak lazım"* | 🔴 **KULLANICI HAKLIYDI** — kod düzeltildi |
| 3 | *"Reeskont motorunu okuyup kesin sonucu çıkar"* (mutlak mı delta mı) | 🔴 **MUTLAK** — çift tahakkuk hatası doğrulandı ve onarıldı |
| 4 | *"Küçük bir ekranda açınca butonlar çok yan yana olduğu için alanlar birbirinin üstüne biniyor"* | ✅ Düzeltildi — **bölüm 8** |
| 5 | *"MM ve InterbankLoan'ı strategy pattern'le beraber götürüyorum, tabloları ayrı — select ve execute'ta yanlışlıkla birbirinin tablolarına bakıp işlem yapmıyorlar değil mi?"* | ✅ Denetlendi — **bölüm 9** (bakmıyorlar; ama güvence sanılan yerden gelmiyor) |
| 6 | 5 maddelik revize isteği (varsayılan tarih · statü info · tarih formatı · onay metni · sürüklenebilir pencere) | ✅ Tamamı yapıldı — **bölüm 10** |

---

## 1 — 5. şart (`aktif faiz dönemi`) neden zorunlu

**(a) Emsal var, uydurulmadı.** `GetPendingRevaluationTransactions` (EOD batch) aynı şartı
kullanıyor; kalıp **2025-07-16**'dan beri kodda (`git log -S "PeriodEndDate > logicalDate"` →
`fda5e5638`).

**(b) Motorun kendi ön koşulu.** `GetTransactionForRevaluationEngineAsync` işlemin faiz dönemi
satırlarını **tam bu üç koşulla** `Include` ediyor, mapper da **guard'sız** `First()` çağırıyor
(`RevaluationEnginePipelineContextMapper:23`). O tarihi kapsayan dönem yoksa koleksiyon boş →
`InvalidOperationException: Sequence contains no elements`.

🔑 Şart kaldırılsa ekran, **Generate'e basınca patlayacak** satırları listelerdi.

---

## 2 — 🔴 Statü: değerleme döngüsü (v1 YANLIŞTI)

### Önceki (yanlış) kural

```
ReverseId == null → NotRediscounted · == 0 → NotReversed · > 0 → Rediscounted
```

Ters fişin **valörüne hiç bakılmıyordu**. Doküman § 3.2'deki **"(t+1)"** parantezini "yalnızca
tanımlayıcı" saymıştım.

### Kanıt — platformun EOD batch'i kuralı zaten uyguluyor

`TransactionDataManager.GetPendingRevaluationTransactions` (satır 615+), her gece koşan sorgu,
"bugün reeskont kesilecekler" kümesini **iki dalın `Union`**'ı yapıyor:

```csharp
// (a) o güne hiç fiş yok
// (b) o güne fişi VAR ama tersi DE AYNI GÜNE kesilmiş:
.Any(reverseId => x.AccountingMainEntries.Any(f => f.Id == reverseId &&
                                                   f.ValueDate == logicalDate))
```

Metodun **kendi XML yorumu**: *"…or whose revaluation was **reversed on the same date**."*

Yani platform, tersi aynı güne kesilmiş bir reeskontu **"reeskont yok"** sayıp yeniden kesiyor.
Doküman § 3.2 de aynısını söylüyor.

### Defter matematiği

| Senaryo | Gün-T | Gün-T+1 | Anlam |
|---|---|---|---|
| R(T,+A) · ters yok | **+A** | — | `NotReversed` |
| R(T,+A) · Rev(**T+1**,−A) | **+A** | −A | tahakkuk gün-T'de durdu → **`Rediscounted`** |
| R(T,+A) · Rev(**T+0**,−A) | **0** | — | aynı gün açılıp kapandı → **`NotRediscounted`** |

🔑 **T+0 ters fiş bir "tamamlama" değil, bir "geri alma" aksiyonu.** § 4.2'nin T+0 seçeneği ancak
böyle anlam kazanıyor.

⚠️ Doküman § 4.2 (*"T+0 → Rediscounted"*) § 3.2 ve batch ile çelişiyor. **Kullanıcı kararıyla
doküman aleyhine çözüldü:** değerleme döngüsü esas.

### Geçerli algoritma

| Koşul | Durum |
|---|---|
| `ReverseId == null` | `NotRediscounted` |
| `ReverseId == 0` | `NotReversed` |
| `ReverseValueDate == null` (ters fiş satırı yok) | `NotReversed` — veri anomalisi, tahakkuk açıkta |
| `ReverseValueDate > ExecutionDate` | **`Rediscounted`** |
| `ReverseValueDate <= ExecutionDate` | **`NotRediscounted`** (iptal) |

EOD `==` kullanıyor, biz `<=`: valörü T'den **önce** olan ters fiş de gün-T tahakkukunu taşımıyor.

### Kuralın üç kopyası — birlikte değişir

`ManualRediscountStatusResolver` (bellek, tek gerçek kaynak) ·
`TransactionDataManager` (SQL, MM) · `TransactionLoanDataManager` (SQL, Loan).
Katman yönü ters olduğu için ortak sınıfa alınamadı. Ayrışırsa **her satır `STATUS_CHANGED`**.

⚠️ SQL'de üç dal toplamda tüm satırları kapsıyor; `ReverseValueDate == null` açıkça `NotReversed`
kovasına yazıldı ki hiçbir satır "Total'de var, listede yok" olmasın.

---

## 3 — 🔴 Motor MUTLAK tutar basıyor (v1'de doğrulanmamıştı)

`SLCalculatorContextMapper`:
```csharp
.Map(dest => dest.PassedDay, src => (src.LogicalDate - src.CashFlow.StartDate).Days + 1)
```

`PassedDay` = **faiz dönemi başından** o güne kadar. Yani tutar **birikmiş toplam tahakkuk**,
delta **değil**. Bu tutar doğrudan muhasebe fişine gidiyor
(`AccountingManagerRevaluationAccountingContextMapper:31`) ve
`20_RevaluationAccountingPersistChangeStep` **koşulsuz `InsertAsync`** yapıyor.

**Sonuç:** aynı güne ikinci reeskont = gün-T bakiyesi `A1 + A2` ≈ **iki katı**.

ℹ️ Değerleme **tablosu** idempotent (`RevaluationAccountingPersister` aynı gün satırını silip
yeniden yazıyor) — bozulan şey yalnız **muhasebe defteri**.

---

## 4 — `Regenerate` + `Rediscounted` onarıldı

**Eskiden:** statü `Rediscounted` iken hiçbir şey nötrlenmiyor, doğrudan ikinci çift ekleniyordu.

**Şimdi** iki aşamalı (doküman § 4.3):

```
1. AŞAMA — gün-T'yi net sıfıra indir
   NotRediscounted  → yapılacak yok (zaten sıfır)
   NotReversed      → mevcut fişe T+0 ters
   Rediscounted     → İKİ karşı kayıt:
                        (a) R1'in karşı kaydı,   valör = R1.ValueDate   (T)
                        (b) Rev1'in karşı kaydı, valör = Rev1.ValueDate (T+1)
2. AŞAMA — yeni R2(T) + Rev2(T+1)
```

Yalnız (a) yapılsa gün-T doğru olur ama gün-T+1'de fazladan `−A1` kalırdı. **İkisi de şart.**
Nötrleme yapılamıyorsa (ters fiş kayıp) **hiç fiş kesilmiyor**.

### ⚠️ Platformda yeni bir hareket türü

MM'de bugüne kadar hiçbir akış tersi alınmış bir fişi ya da bir ters fişi tekrar terslemiyordu —
muhasebe **silme** akışı bile yalnız `ReverseId == 0` olanı tersliyor.

- **Mekanizma yeni değil:** `IRevaluationReverseAccountingService` guard'sız, herhangi bir fişi
  herhangi bir valörle tersliyor.
- **Kullanımı yeni** → 🔴 **Fimple duman testi yapılmadan canlıya alınmamalı.**
- Blast radius **1 dosya** (`ExecutionsHandler`); paylaşılan servis/factory'ye dokunulmadı.

### Yan etki — tarandı, güvenli

Ters fiş kesmek kaynağın `ReverseId`'sini eziyor → `R1 → Rev1` geri-işaretçisi kayboluyor.
`ReverseId`'nin **tüm** okuyucuları tarandı: hepsi `== 0` / `!= 0` testi yapıyor ya da o tarihin
**en son** fişini alıyor; hiçbiri `R1 ↔ Rev1` kimliğini yürümüyor. EOD de en son fişi (`R2`)
aldığı için doğru davranıyor.

---

## 5 — `Generate` + `NotReversed` + T+0: yeni durum düzeltildi

Eskiden **sabit** `Rediscounted` dönüyordu → T+0 seçen kullanıcıya "değerlendi" yalanı; sayfa
yenilenince satır `NotRediscounted` görünüp çelişiyordu. Artık valöre bağlı:
**T+1 → `Rediscounted` · T+0 → `NotRediscounted`**.

---

## 6 — Kapsam: "50 günlük geçmişten en son fişi mi alıyorsun?"

**Hayır.** Sorgu **yalnız** `ValueDate == ExecutionDate` olan fişlere bakıyor; geçmiş 50 gün
**hiç okunmuyor**. `OrderByDescending(a => a.Id)` sadece **o gün içinde** birden fazla fiş varsa
en sonunu seçmek için. Product/SubProduct süzgeci de muhasebe geçmişinden bağımsız
(`TxnMmProductTypeId` ∈ katalog Id listesi).

---

## Dokunulan dosyalar

| Dosya | Ne |
|---|---|
| `ManualRediscountStatusResolver.cs` | **YENİ** — döngü farkında türetme, tek gerçek kaynak |
| `TDMRediscountEligibleResult.cs` | `ReverseValueDate` alanı |
| `TransactionDataManager.cs` | 2 aşamalı projeksiyon · 3 filtre dalı · 3 sayım |
| `TransactionLoanDataManager.cs` | aynısı (Loan) |
| `IAccountingDataManager` · `AccountingDataManager` | `GetEntryValueDateAsync` |
| `EligibleTransactionsHandler.cs` | resolver'a bağlandı, yerel `DeriveStatus` silindi |
| `ExecutionsHandler.cs` | resolver · T+0 yeni durum · `NeutralizeCompletedCycleAsync` |
| `EligibleTransactionsHandlerTests.cs` | döngü matrisi (6 satır) + iptal açıklaması |
| `ExecutionsHandlerTests.cs` | 8 yeni test (döngü + çift tahakkuk onarımı) |

Detay + kanıt dökümü → [`../11-statu-algoritmasi.md`](../11-statu-algoritmasi.md)

---

## 7 — 🔴 WebUI'da bir yer kalmisti (ayni tur, sonradan bulundu)

"WebUI degismedi" dedigim ilk raporum **eksikti**. Aksiyon butonlarinin ⓘ bilgi metinleri eski
davranisi anlatiyordu:

| Anahtar | Eski (yanlis) | Yeni |
|---|---|---|
| `mr-info-gen-NotReversed` | *"T+1 veya T+0. Kayit **Rediscounted** olur."* | T+1 → `Rediscounted` · **T+0 → IPTAL, `Not Rediscounted`** |
| `mr-info-regen-Rediscounted` | *"yeni reeskont (T+0) ve tersi (T+1) kesilir"* (2 fis) | **Dort fis**: iki karsi kayit (T ve T+1) + yeni cift |

Duzeltildi: `manual-rediscount.actions.js` fallback'leri + `manual-rediscount-{en,tr}.json`.
`node --check` ✅ · JSON parse ✅ · **JS 416/416**.

🔑 Ders: sunucu davranisi degistiginde **ekranin o davranisi ANLATAN metinleri** de degisir.
Sozlesme (DTO) degismedigi icin "UI'a dokunmak gerekmez" dedim — ama **aciklama metni de bir
sozlesmedir**, kullanicinin gordugu tek dokumantasyon o.

---

## 8 — 🔴 Dar ekranda EXPORT butonu Sub Product kutusunun ÜSTÜNE biniyordu

**Repo:** `NetTrex.Web.UI` · **Belirti (ekran görüntüsüyle geldi):** içerik alanı ~1200px'e
düştüğünde `EXPORT` + `Yenile` düğmeleri *"Select sub product"* kutusunun üstünde duruyor;
`REGENERATE`'in köşe bilgi ikonu sağ kenarda kırpılıyor.

### Kök neden — iki ayrı şey

**(1) `.mr-tools` mutlak konumluydu.**

```css
.mr-tools { position: absolute; top: 0; right: 0; z-index: 2; ... }
```

Gerekçesi dosyada yazılıydı: *"akışta yer tutmuyor, böylece görünüp kaybolması filtreleri ve
grid'i aşağı kaydırmıyor"* (Export veri yüklenmeden `hide()` ediliyor — `mrRenderExportButton`).
Ama mutlak konum **çakışmayı görmez**: 3 kolonlu filtre Form'unun 3. kolonu genişlik darınca aynı
piksellere geliyor.

**(2) `.mr-status-bar` `flex-wrap: nowrap` idi.** Pill'ler + iki aksiyon butonu tek satıra
zorlanıyor; butonlar sağdan taşıyor ve `.mr-info-badge` (`right: -6px`, butonun **dışında**)
kenarda kesiliyor.

### Çözüm — CSS + Razor, JS'e dokunulmadı

| Dosya | Değişiklik |
|---|---|
| `Views/Shared/Components/ManualRediscount/Default.cshtml` | Filtre Form'u + `.mr-tools` ortak `.mr-header` sarıcısına alındı (araclar DOM'da artık Form'dan **sonra**) |
| aynı dosya | `.ColCountByScreen(c => c.Xs(1).Sm(1).Md(2).Lg(3))` — ev deseni: `Views/Funds/InvPortfolio/Templates/_AdvanceFilter.cshtml` |
| `wwwroot/css/shared/components/manual-rediscount.css` | `.mr-header` (flex + `flex-wrap: wrap`) · `.mr-filters { flex: 1 1 560px; min-width: 0 }` · `.mr-tools` mutlak → `margin-left: auto` akış öğesi · `.mr-status-bar` `nowrap` → `wrap` + `row-gap` + `padding-right: 8px` · `.mr-toolbar` `flex-wrap: wrap` |

🔑 **Eski gerekçe bozulmadı:** `.mr-tools` artık akışta ama satır yüksekliğini **her zaman
Form** belirliyor — Export gizlendiğinde satır daralmıyor, grid aşağı kaymıyor. Ek güvence:
`.mr-tools { min-height: 34px }`.

### ⚠ `ColCountByScreen` tek başına bu hatayı ÇÖZMEZDİ

DevExtreme'in `screenByWidth`'i **pencere** genişliğine bakıyor, kabın genişliğine değil.
Kullanıcının ekran görüntüsünde pencere ~1600px (→ `lg` → 3 kolon) ama sol menü ~360px aldığı
için içerik alanı ~1200px. Asıl çözüm **flex** (kap göreceli); `ColCountByScreen` yalnız gerçekten
küçük pencerede (tablet/1024) devreye giren ek sigorta.

### Test durumu — kasıtlı olarak test YAZILMADI

Layout değişikliğinin davranış testi yok: CSS + Razor markup'ı jsdom testlerinin görmediği alan
(JS testleri DOM fixture'ını kendileri kuruyor; `.mr-tools` / `.mr-filters` / `mrExport_`
seçicilerini **hiç** kullanmıyorlar — grep ile doğrulanıp yazıldı). Doğrulama **tarayıcıda
gözle** yapılacak. Regresyon güvencesi: WebUI build **0 Error** (Razor build-time derleniyor,
`.ColCountByScreen` ve fluent zincir içindeki Razor yorumu doğrulanmış oldu) + JS **116/116**.

---

## 9 — 🔴 MM / InterbankLoan tablo izolasyonu (DENETİM — kod değişmedi)

**Kullanıcının sorusu:** *"Select ve execute işlemlerinde MM ve InterbankLoan yine ayrı gidiyor
değil mi, yanlışlıkla kod hatasından dolayı birbirinin tablolarına bakıp işlem yapmıyorlar?"*

**Cevap: bakmıyorlar — ama güvence sanıldığı yerden gelmiyor.**

| Katman | Ayrımı fiilen yapan şey |
|---|---|
| Handler dispatch | `ResolveProductSourceType(request.Product)` — tek karar noktası |
| Select (liste) | Ayrı data manager + ayrı repository (`TxnMmEntity` / `TxnLoanEntity`) — tablo seçimi **derleme zamanında** sabit |
| Execute | `GetRevaluationByValueDateAsync(..., sourceType)` |
| Fiş servisi | `sourceType == InterbankLoan ? loanRevaluationAccountingService : revaluationAccountingService` |

🔴 **`ProductCode` filtresi ETKİSİZ.** Kod ayrımı
`a.ProductCode == x.Product.MainProductCode` (MM) / `== x.ProductDefinition.MainProductCode` (Loan)
ile yapıyor. DB'den ölçüldü: `MainProductCode` **11 ürün tanımının tamamında `'MM'`** (sorgu #36)
ve TxnLoan işlemlerinin fişlerinin **tamamı da `ProductCode='MM'`** (#42). Yani o filtre MM ile Loan'ı
**ayirmiyor**; yalnız `'Loan'`/`'TWR'` kodlu eski/öksüz fişleri dışlıyor.

🔴 **Gerçek koruma `accEntryMain.TxnId`'nin ayrıklığı**, ve o **yapısal garanti değil**:

- `accEntryMain.TxnId` **aynı kolon** iki tabloya FK (`AccEntryMainConfiguration.cs:69-77`) — join'de discriminator yok
- `TxnMM.Id` 551002-553350 · `TxnLoan.Id` 1201069-1201167 · kesişim **0** (#37/#38)
- iki kolon da **IDENTITY değil** (#45) · DB'de **hiç SEQUENCE yok** (#48a) · trigger'lar yalnız **history** (#49)
- Id'yi **uygulama** atıyor; **nerede attığı tespit edilemedi**

→ Bugün çakışma yok (aradaki boşluk ~648.000 satır), ama TxnMM 1201069'a ulaşırsa
`GetRevaluationByValueDateAsync` **yanlış fişi** döndürür (gerçek para).

**Yan bulgular:**
- ⚠ `RevaluationReverseAccountingPipelineContextMapper` `ProductSourceType.MoneyMarket`'i **sabit** yazıyor.
  Bugün zararsız (ters fiş adımlarının hiçbiri `Source`'u okumuyor — grep'le doğrulandı), ama reeskont
  pipeline'ı `IsApplicable(PipelineContext.Source)` deseni kullandığı için **mayın**.
- `TxnMM`'de **12 satır** `TxnMmProductTypeId = 2` (Interbank Loan) → aynı etiket **iki farklı küme**
  (TxnMM'de 12, TxnLoan'da 95). Kod hatası değil, iş birimine sorulacak.
- `'Loan'` kodlu **19** açılış fişli işlem ekranda görünmüyor — ama **EOD batch de aynı filtreyi**
  kullanıp onları hiç değerlememiş (#50) → ekran batch ile **tutarlı**, regresyon **değil**.
- `'TWR'` kodlu **46** fişin TxnId'si ne TxnMM'de ne TxnLoan'da — **öksüz FK**.

Denetim kaydı: `sql-log/manuel-reeskont-kodlama/01-sorgular.md` + `02-ciktilar.md` (#37-#50, hepsi `SELECT`).
Bulgular `NetTrex.MM/.ai-agent/MEMORY.md`'ye yazıldı.

---

## 10 — 5 maddelik UX revizesi (kullanıcı isteği 2026-08-26)

Tamamı **`NetTrex.Web.UI`**'de. MM'e dokunulmadı — gerek yoktu: `ExecutionsRequestValidator` zaten
`ExecutionDate <= DateTime.Today` istiyor, yeni varsayılan (T-1) bu sınırın **içinde**.

### 10.1 — `ExecutionDate` varsayılanı **bugün − 1 takvim günü**

Gerekçe (kullanıcı): *"bulunduğumuz gün EOD kesileceği için varsayılan bir gün önceki işlemler
gelsin"*. Bugün de seçilebilir, **bir gün sonrası seçilemez** (eskisi gibi).

| Dosya | Değişiklik |
|---|---|
| `ManualRediscountComponentViewModel.cs` | **yeni** `MaxExecutionDate` (seçilebilir en büyük = bugün) |
| `RediscountControllerBase.cs` | `ExecutionDate = today.AddDays(-1)` · `MaxExecutionDate = today` |
| `Default.cshtml` | `.Max(Model.MaxExecutionDate)` — eski hal `DateTime.Today` kullanıyordu |
| aynı dosya | `settings.logicalDate` → `MaxExecutionDate` (uygulamanın **bugünü**, filtrenin varsayılanı değil) |

🔑 `DateTime.Today` Razor'dan **kaldırıldı**: tarih tek kaynaktan (`IDateTimeProvider`) gelir,
aksi halde varsayılan ile üst sınır ayrı saatlerden hesaplanıp gün dönümünde ayrışabilir.

### 10.2 — Statü anlamları için ⓘ

Gerekçe (kullanıcı): *"statülerin anlamları müşteri ve işlem yapan kişi tarafından
karıştırılıyor... çok basit bir şekilde anlamlarının yazmasını istiyorum"*.

- Statü şeridindeki **`Status:` etiketinin yanına** ⓘ (aksiyon butonlarının ⓘ'si ayrı kalıyor —
  o "bu **buton** ne yapar" diyor, bu "bu **statü** ne demek").
- Yeni `mrBuildStatusInfoBody()` (saf, test edilebilir) + `mrShowStatusInfo()`.
- **Beş** statü, her biri **tek cümle**; altında "Butonlar ne yapar" ile Generate/Regenerate birer satır.
- 14 yeni localization anahtarı (`mr-meaning-*`), TR + EN.
- CSS: `.mr-info-badge-inline` — 🔴 `.mr-info-badge` `position: absolute` (buton köşesi için);
  akışta kullanılırken `position` **ezilmek zorunda**, yoksa etiketin üstüne biner.

### 10.3 — Tarih biçimi: TEK kaynak, ev standardı `dd.MM.yyyy`

🔴 **Bulunan hata:** `mrFormatDate` ve `mrFormatShortDate` **ikisi de**
`DevExpress.localization.formatDate(date, "shortDate")` kullanıyordu — yerel kısa biçim, yani
`8/26/2026` de olabiliyor. Grid `dd.MM.yyyy` yazarken onay penceresi başka biçim yazıyordu:
**aynı ekranda iki ayrı sıralama ve iki ayrı ayraç.**

| Değişiklik | Yer |
|---|---|
| **yeni** `MR_DATE_FORMAT = "dd.MM.yyyy"` (= `UIConstants.DateFormat`, DateBox `DisplayFormat`'ı ile aynı) | `constants.js` |
| `mrFormatShortDate` → `MR_DATE_FORMAT` | `constants.js` |
| `mrFormatDate` → kendi `formatDate` çağrısını **bıraktı**, `mrFormatShortDate`'e delege ediyor (tek fark: boş değerde `-`) | `actions.js` |
| tarih kolonunda `format` yoksa `MR_DATE_FORMAT` yazılıyor | `columns.js` |

🔴 Yan bulgu: `treasury.json` tarih kolonlarına `format` **veriyordu**,
`investment.json` / `security.json` **vermiyordu** → üç ekran ayrışıyordu. Çözüm config'lerde
değil `columns.js`'te (varsayılan), böylece yeni bir ürün config'i eklendiğinde de doğru.

### 10.4 — Onay penceresi: **kural** değil **kesilecek fişler**

Gerekçe (kullanıcı): *"Ben generation'a basıyorum, statüsü Not Rediscounted olan bir işlem için
'T+0 için reeskont kesilecek' yazıyor ve sonrasında 'T+1 için de tersi kesilecek' yazıyor — ben o an
yapılacak işlemi görmek istiyorum."*

**Eski hal:** Generate onay gövdesi seçimde ne varsa bakmadan **her zaman iki maddeyi** yazıyordu.

**Yeni hal:** her durum grubu için o gruba kesilecek fişler **numaralı** ve **gerçek valor tarihiyle**;
yanında `[geldiği durum] → [varılacak durum]` rozetleri. Grup yoksa satır **hiç basılmıyor**.

| Seçim | Generate | Regenerate |
|---|---|---|
| `Not Rediscounted` | **1** fiş: reeskont (T+0) → `Not Reversed` | **2** fiş: yeni reeskont (T+0) + tersi (T+1) |
| `Not Reversed` | **1** fiş: ters fiş (seçilen valor) → T+1'de `Rediscounted`, **T+0'da `Not Rediscounted`** + İPTAL uyarısı | **3** fiş: mevcut reeskontu kapatan karşı fiş (T+0) + yeni çift |
| `Rediscounted` | fiş **kesilmez**, Regenerate'e yönlendirir (buton normalde pasif) | **4** fiş: İKİ karşı kayıt (T+0, T+1) + yeni çift |
| `Processing`/`Error` | kapsam dışı satırı | kapsam dışı satırı |

- Yeni saf fonksiyonlar: `mrConfirmEntry` (tek fiş satırı) · `mrConfirmGroup` (durum grubu) ·
  `mrConfirmOutOfScopeGroup`.
- `mrRegenerateLine` **kaldırıldı** (yerini `mrConfirmGroup` aldı) — testleri de güncellendi.
- Valor seçim penceresindeki radyo etiketlerine de **gerçek tarih** eklendi
  (`mrReverseValueTypeLabel`, `mrAskReverseValueType(rows, uniqueKey)`) — kullanıcı hangi güne fiş
  keseceğini **seçim** anında görüyor, onayı beklemiyor.
- T+1 tarihi bilinmiyorsa `-` yazılıyor, **yerel olarak HESAPLANMIYOR**: T+1 kuralı tek sınıfta
  (`ManualRediscountValueDateResolver`) durmalı, UI'de ikinci kopya = ekran bir tarih gösterip modül
  başkasına fiş keser.

### 10.5 — Pencereler sürüklenebilir + boyutlandirilabilir

`mrShowDialog` → `dragEnabled: true` (eskiden `false`) · `resizeEnabled: true` ·
`dragOutsideBoundary: false` (DevExtreme **22.2.6** ikisini de destekliyor — `dx.all.js`'te doğrulandı).
CSS: başlıkta `cursor: move`, kapat düğmesinde `cursor: pointer`, boyutlandirma tutamacı koyu zeminde
görünür. `hideOnOutsideClick: false` **korundu** (muhasebe fişi onayı).

### 10.6 — 🔴 Yol üstünde bulunan GERÇEK hata: `mrStatusBadgeHtml` İKİ KEZ tanımlanacaktı

Rozet üreticisini `actions.js`'e yazdım; `columns.js:137`'de **aynı adda** (farklı imzalı) bir tane
zaten vardı. Klasik script'lerde top-level `const` **paylaşılan global lexical scope**'a girdiği için
bu bir `SyntaxError: Identifier 'mrStatusBadgeHtml' has already been declared` — yani **ekran hiç
açılmazdı**. JS testleri yakaladı (aynı dosyalar tek fonksiyon gövdesinde yükleniyor).

✅ Çözüm: ikinci kopya yazılmadı — `columns.js`'teki mevcut üretici `labelOverride` paramıyla
**genişletildi**, `actions.js` ince bir sarmalayıcı (`mrInlineStatusBadge`) kullanıyor. Böylece grid
hücresi ile pencereler **aynı** rozeti üretiyor.

🔑 Ders: bu bileşende yeni bir global fonksiyon eklemeden **önce** adı grep'lemek gerekiyor;
dosyalar ayrı ama **scope ortak**.

### 10.7 — Test durumu

| Ölçüm | Sonuç |
|---|---|
| `manualRediscountComponent.test.js` | **131/131** yeşil (önceki 116 → +15) |
| JS suite (tamamı, 5 dosya) | **431/431** yeşil |
| `Trex.WebUI` build | **0 Error** (1554 warning, hepsi önceden vardı) |

**Yeni/güncellenen testler:**
- `mrConfirmGroup` / `mrConfirmEntry` — 0 kayıtlı grup basılmaz · iki rozet · `toStatus: null`'da ok yok ·
  valor + tarih birlikte · tarih yoksa `-`
- `mrBuildGenerateConfirmBody` — dört statü dalı; **`Not Rediscounted` seçiminde "Reverse entry"
  GEÇMEDİĞİ** (eski davranışın regresyon testi) · T+0'da İPTAL uyarısı + `Not Rediscounted` rozeti
- `mrBuildRegenerateConfirmBody` — 2/3/4 fiş dalları; `>3.<` var `>4.<` yok gibi **sayı** iddiaları
- `mrBuildStatusInfoBody` — beş statü + iki aksiyon · localization anahtarı varsa fallback kullanılmaz
- tarih biçimi — `MR_DATE_FORMAT` değeri · DevExtreme'e geçen formatın `"shortDate"` **olmadığı** ·
  `mrFormatDate`'in kendi `formatDate` çağrısını **yapmadığı**
- `mrBuildDataColumns` — tarih kolonunda `format` yoksa ev standardı, config formatı ezer

⚠ **Test yazılmayanlar (kasıtlı):** `dragEnabled`/`resizeEnabled` (DevExtreme seçenek geçişi, jsdom'da
dxPopup yok) · CSS · `mrRenderStatusInfoBadge`'in DOM'a basması (jQuery stub'ı zincir döndürmüyor).
Bunlar **tarayicıda gözle** doğrulanacak.

⚠ Test iddialarında rozet **etiketleri enjekte ediliyor** (`load({ formatMessage })`): varsayılan
harness'te `formatMessage` anahtarı geri döndürüyor ve rozet "Unknown" yazıyor — o halde "varılacak
durum doğru mu" sorusu **ölçülemez**. (Aynı tuzağın bir önceki örneği `MEMORY.md`'de.)

⚠ Rozet **sayarken** `/mr-badge-inline/g` kullanılıyor: düz `/mr-badge/g` her rozette **iki kez**
eşleşiyor (`class="mr-badge mr-badge-inline"`).

---

## Test öncesi

🔴 **MM API yeniden başlatılmalı** (bölüm 1-7'deki C# değişiklikleri için — **bu turda MM'e
dokunulmadı**). **WebUI için `Ctrl+F5`** — CSS/JS `asp-append-version` ile sürümleniyor ama Razor
çıktısı da değişti.

### Bu turun revizeleri (bölüm 10)

1. Ekran açılışında tarih **dün** mı? Takvimde **bugün seçilebiliyor**, **yarın seçilemiyor** mu?
2. `Status:` yanındaki ⓘ → beş statü tek cümleyle yazıyor mu? ⓘ etiketin **üstüne binmiyor** mu?
3. Tüm tarihler `dd.MM.yyyy` mi — grid · onay penceresi · valor seçim penceresi · **Investment ve
   Security ekranlarının** `StartDate`/`MaturityDate` kolonları dahil?
4. `Not Rediscounted` bir satır seçip Generate → onay penceresi **yalnız "1. Reeskont fişi — T+0 ·
   \<tarih\>"** yazıyor, ters fişten **hiç bahsetmiyor** mu?
5. `Not Reversed` satır + T+0 seç → onayda **İPTAL uyarısı** ve varılacak durum **`Reeskont Edilmedi`**
   görünüyor mu?
6. `Rediscounted` satır + Regenerate → onayda **dört** numaralı fiş ve iki farklı valor tarihi var mı?
7. Pencereler başlıktan **sürüklenebiliyor** ve sağ-alt köşeden **boyutlandirilabiliyor** mu?
   Dışarı tıklayınca **kapanmiyor** (bilinçli) mu?

### Önceki turların doğrulamaları (henüz yapılmadıysa)

🔴 **MM API yeniden başlatılmalı** (C# değişti). **WebUI için `Ctrl+F5`** — CSS
`asp-append-version` ile sürümleniyor ama Razor çıktısı da değişti (bölüm 7 + 8).

1. Tersi **T+0** kesilmiş satır ekranda `Not Rediscounted` mı?
2. `Not Reversed` satıra T+0 ile Generate → rozet `Not Rediscounted` mı?
3. `Rediscounted` satıra Regenerate → **üç** ters fiş (2 nötrleme + 1 yeni), Fimple hepsini kabul
   ediyor mu? 🔴 **Ana risk burada.**
4. Regenerate sonrası gün-T defter bakiyesi **çift değil** mi.
5. Özet şeridindeki üç sayının toplamı = Total mı.
6. **Layout (bölüm 8):** pencereyi daralt — (a) `EXPORT` hiçbir genişlikte Sub Product'ın
   üstüne binmiyor · (b) `REGENERATE`'in bilgi ikonu kırpılmıyor · (c) Export görünüp
   kaybolurken grid aşağı zıplamıyor · (d) çok dar pencerede filtreler 2/1 kolona düşüyor.
