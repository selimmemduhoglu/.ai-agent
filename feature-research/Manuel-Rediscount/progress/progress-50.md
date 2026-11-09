# progress-50 — 🔴 AYNA ÇİFTİ: `Rediscounted` regenerate artık ters fiş KESMİYOR (Fimple reddi) · orphan mantığı SİLİNDİ · kolon sırası + hizalama

**Tarih:** 2026-09-01 · **Repo:** `NetTrex.MM` + `NetTrex.Web.UI`
**Test:** MM **225/225** · JS **438/438** · **Build:** 3 proje 0 Error

> `progress-49`'un tam hali. 🔴 **Bölüm 18 (`HALF_NEUTRALIZED`) ARTIK GEÇERSİZ — kod silindi**,
> tarihsel kayıt olarak bırakıldı; yerine **20** (ayna çifti) + **21** (kaldırılanlar) +
> **22** (pencere hizalama + kolon sırası) geldi.

---

## Kullanıcının soruları (1-3 üç tur önce · 4-6 iki tur önce · 7-8 önceki tur · 9-11 bu tur)

| # | Soru | Sonuç |
|---|------|:-----:|
| 1 | *"`o tarihte aktif faiz dönemi var` şartı gerçekten gerekli miydi?"* | ✅ **Zorunlu**, iki bağımsız gerekçe |
| 2 | *"`isReverse` ve `reverseId` yeterli değil, T+1 durumuna da bakmak lazım"* | 🔴 **KULLANICI HAKLIYDI** |
| 3 | *"Motoru okuyup kesin sonucu çıkar"* (mutlak mı delta mı) | 🔴 **MUTLAK** — çift tahakkuk onarıldı |
| 4 | Dar ekranda buton/alan çakışması | ✅ **bölüm 8** |
| 5 | MM ↔ InterbankLoan tablo izolasyonu | ✅ **bölüm 9** |
| 6 | 5 maddelik UX revizesi | ✅ **bölüm 10** |
| 7 | *"Tracker'a müdahale etmek yerine Transient kullansak olmuyor muydu?"* | ✅ Kullanıcının teşhisi **DOĞRU**, Transient etkisi **sıfır** — **bölüm 17** |
| 8 | *"Orphan'a gerçekten gerek var mıydı, sayfayı yenileyip devam edemez miydim?"* | 🔴 O an **hayır** — ama 9. soru guard'ı **gereksiz** kıldı |
| 9 | 🔴 *"Orphan mantığını SİL. Fimple zaten `bacak 1'in tersi var` hatası veriyor. Bacak 1'in bilgilerini alıp ters çevirip **normal reeskont** oluşturacağız, onun tersini de **bacak 2'nin ValueDate**'i ile keseceğiz — bacak 1 ve 2'ye hiç dokunmadan."* | ✅ **Uygulandı — bölüm 20/21** |
| 10 | *"Açıklamaları aynı hizada başlat, görünümü güzelleştir"* | ✅ **bölüm 22.1** |
| 11 | *"Status ve Status Description başa alınsın; `ExternalCustomerId` → Customer Id"* | ✅ **bölüm 22.2** (⚠️ bir varsayım) |

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

## 11 — 🔴 EF tracking hatası: `AccEntryEntity ... already being tracked`

**Kullanıcı:** *"Batch yapısında nasıl bir yapı kullanılıyor, orada bu hata neden hiç alınmadı?"*

### Batch aynı yeri kullanıyor — izolasyonu başka yerden alıyor

`RevaluationBatchItem` döngüsü **yapısal olarak AYNI**: `foreach` + aynı
`accountingService.ExecuteAsync` + işlem başına `catch` + tek enjekte servis (= tek scope = tek
`DbContext`) · `ChangeTracker.Clear()` **yok**.

🔑 **Fark tek ve belirleyici:** batch her işlem için **TEK** muhasebe servisi çağırıyor ve
**reeskont ile ters fiş AYRI batch item** (`RevaluationBatchItem` / `ReverseBatchItem`) — ayrı DI
scope, ayrı `DbContext`. Manuel Reeskont satır başına **1-4** muhasebe servisini **aynı** scope'ta
zincirleyen **ilk yer**.

### Yol üstünde bulunan daha ciddi hata

`IRepository.InsertAsync` **kaydetmiyor**; kaydeden tek yer `unitOfWork.CommitAsync()`.

> Bir satır Commit'ten **önce** patlarsa fişleri tracker'da `Added` **kalır**, dış `catch` sonraki
> satıra geçer ve **sonraki satırın Commit'i o fişleri de INSERT eder** → kullanıcının *"hata"*
> gördüğü satır gerçekte **fiş kesmiş** olabilir.

### Düzeltme — batch'in item başına sağladığı izolasyon, satır başına

| Dosya | Değişiklik |
|---|---|
| **yeni** `Data.Abstractions/Tracking/IChangeTrackerDataService.cs` | `Reset()` + `DescribeAccountingEntries()` |
| **yeni** `Data/Tracking/ChangeTrackerDataService.cs` | `ChangeTracker.Clear()` · `Entries<AccEntryEntity>()` dökümü. Adı `DataService` ile bittiği için **Scrutor otomatik kaydediyor** — DI satırı yok |
| `ExecutionsHandler` | döngü başında `Reset()` **ve** `catch` içinde `Reset()` · hata mesajına **tracker dökümü** |

✅ Teşhis artık mümkün: EF hangi Id'nin çakıştığını **söylemiyor**,
`EnableSensitiveDataLogging` canlıya açılamaz — döküm `ReasonDetail`'e yazılıyor
(`AccEntry Id=... AccEntryMainId=... TxnId=... State=Added`).

Yeni testler: `Reset` satır başına tam bir kez (3 satır → 3 çağrı) · patlayan satırda 2 çağrı ·
tracker dökümü `ReasonDetail`'e giriyor.

### ⚠ Çürütülen iki hipotez (bir daha aranmasın)

1. `sp_GetNewNumbers` mükerrer numara veriyor → **HAYIR**: `UPDATE ... WITH (ROWLOCK, UPDLOCK)`,
   tek ifadede `SET @degisken = Kolon = Kolon + @count`. Monoton.
2. Sayaç tablonun `MAX(Id)`'sinin gerisinde → **HAYIR**: `accEntry` sayaç 12300 → sonraki Id
   5512301, MAX **5512296**. Üç sayaç da **önde** (`sql-log` #51/#54).

⚠ Kullanıcının gönderdiği `DefNumberGen` dökümü **`NetTrexAcc`**'ten — Accounting modülünün
messaging ile beslenen **kendi kopyası**; MM'in sayaçları `NetTrexMM`'de (`EntityColumnType` 1-4).

---

## 12 — Regenerate + `Rediscounted`: ne yapıyor

*"Zaten T+0'da reeskont ve T+1'de tersi var; nasıl reeskontu kesip bir de tersini ters mi
kesiyoruz?"*

**Ters fişin tersi kesilmiyor.** Her mevcut fiş için **kendi valörüne** bir **karşı fiş**
kesiliyor — muhasebe fişi **silinemez**.

```
Mevcut:  R1   T+0            +A     Rev1  (R1'in tersi)    kendi valörü  -A
Kesilen: CR1  R1'in valörü  -A     CRev1 (Rev1'in karşısı) Rev1'in valörü +A
         R2   T+0            +A'    Rev2                   T+1           -A'
```

🔴 **İki karşı kayıt şart** çünkü motor **mutlak (kümülatif)** tahakkuk basıyor, delta değil:
yalnız `CR1` kesilirse gün T doğru olur, **Rev1'in gününde `-A` artık kayıt kalır**.

**Ters fiş nasıl bulunuyor:** `+1 gün` varsayılmıyor — `rediscount.ReverseId` →
`GetWithIdAsync(previousReverseId)` → o satırın `ValueDate`'i.

**Ekran:** dört fiş iki **AŞAMA** başlığına bölündü (önce kapat · sonra yeniden kes) + *"fişler
SİLİNMEZ, aynı valöre ters işaretli karşı fiş"* notu.

---

## 13 — Buton genişliği + pasif/aktif ayrımı (🔴 CSS SIRA hatası)

**Kullanıcı:** *"Generate etrafındaki border kesikli ve buton boş dururken neden Regenerate farklı
şekilde?"*

🔴 **Kök neden — CSS kaynak sırası.** `.dx-button.mr-btn-generate.dx-state-disabled` (3 sınıf) ile
`.dx-button.mr-btn-regenerate.dx-button-mode-contained` (3 sınıf) **eşit** specificity'de. Pasif blok
Generate bölümünün içine yazılmış, dolu turuncu kural dosyada **sonra** geldiği için onu
**eziyordu** → seçim yokken Generate çerçeveli, **Regenerate dolu turuncu**.

✅ İki buton tek blokta toplandı, blok **dolu-zemin kurallarının hepsinden SONRAYA** alındı.
✅ `min-width: 165px`.
✅ Statü anlamları penceresinde Generate/Regenerate **kendi buton renkleriyle** basılıyor.

---

## 14 — 🔴 ONAY PENCERESİ = KOD DENETİMİ (kullanıcı: *"kanıtla"*)

| Onay penceresi | Kod | Sonuç |
|---|---|---|
| **Gen / NotRediscounted**: 1 fiş, reeskont T+0 · execDate → `Not Reversed` | `CreateRevaluationAsync(execDate)`; fişin valörü = `AccountingEngine.LogicalDate` = execDate | ✅ |
| **Gen / NotReversed T+1**: 1 fiş → `Rediscounted` | `CreateReverseAsync(existing, T+1)` · `IsCancellingReverse` false | ✅ |
| **Gen / NotReversed T+0**: 1 fiş + **İPTAL** notu → `Not Rediscounted` | valör = execDate · `IsCancellingReverse(exec, exec)` true | ✅ |
| **Gen / Rediscounted**: fiş kesilmez | `Fail(AlreadyRediscounted)` | ✅ |
| **Regen / NotRediscounted**: 2 fiş | nötrleme yok + `CreateRevaluation` + `CreateReverse(T+1)` | ✅ |
| **Regen / NotReversed**: 3 fiş, karşı fiş T+0 · execDate | `CreateReverseAsync(existing, executionDate)` | ✅ |
| **Regen / Rediscounted**: 4 fiş | (1) `rediscount.ValueDate` (== execDate) · (2) **`previousReverse.ValueDate`** · (3)(4) yeni çift | 🔴 **(2)** |
| Foot: ters fiş valörü **T+1 (sabit)** | Regenerate `ReverseValueType`'i yok sayıp `ResolveNextDay` | ✅ |
| Seçili kayıt: N | `request.Items` | ✅ |

### 🔴 Bulgu 1 — karşı kaydın valörü T+1 DEĞİL

`Rediscounted` yalnız **`ReverseValueDate > ExecutionDate`** ister. **Canlı veride T+3 çift var:**
`555960` (ValueDate **28.08.2026**, `ReverseId=555961`) ↔ `555961` (`IsReverse=1`, ValueDate
**31.08.2026**) — hafta sonu atlanmış. Aynı desen `555957` ↔ `555963`.

Pencere `ExecutionDate + 1` yazıyordu → **ekran T+1 der, defter T+3 olur.**

✅ Gerçek tarih **sözleşmeye** eklendi: `ManualRediscountItem.ReverseValueDate` → WebUI DTO
kopyası **aynı turda** (R-11 tuzağı) → JS `row.ReverseValueDate`. WebUI yanıtı olduğu gibi
geçiriyor (`return external.Data`), mapping kodu gerekmedi.
✅ Seçimdeki satırlar farklı tarihler taşıyorsa tek tarih basmak yine yanlış → valörün **ne
olduğu** yazılır, tarih yazılmaz (`mrCommonReverseValueDate`).

### 🔴 Bulgu 2 — `Generate` fiş kesilmese de "başarılı" diyordu

`GenerateAsync` / `NotRediscounted` koşulsuz `Success(NotReversed)` dönüyordu. Tahakkuk yoksa
pipeline sessizce **hiçbir fiş üretmiyor** (`RegenerateAsync` bu ihtimali **zaten** kontrol
ediyordu). Sonuç: pencere *"1 fiş kesilecek"*, ekran *"başarılı"*, defterde fiş **YOK**.

✅ Artık `GetRevaluationByValueDateAsync` ile doğrulanıyor; üretilmediyse `NO_ACCRUAL`.
⚠ Bu değişiklik test mock'unu da gerçeğe uydurmayı gerektirdi: `SetupNoVoucher` artık **işlem
bazında** (`HashSet<long>`) fiş üretimini modelliyor — tek `bool` olsa birinci satırın fişi ikinci
satırın ön kontrolünü bozup `STATUS_CHANGED` üretiyordu.

ℹ Pencerenin **söylemediği** ama mümkün tek durum: `STATUS_CHANGED`. Bir **hata satırı**, sessiz
başka bir iş değil — aksiyon ⓘ'sinde yazılı.

---

## 15 — `DateTime.Today` → `IDateTimeProvider`

**Kullanıcı:** *"Yurt dışı bankalarımız var, bu tehlikeli olabilir mi?"* — **Haklı.**

`DateTime.Today` **sunucunun yerel** saati. Platformun **UAE (+04)** kurulumu var (git log:
`IIBUAE-886`). API konteyneri UTC koşarken UAE'de yerel 01:00 = 21:00 UTC **önceki gün**:

- `ExecutionsRequestValidator` → kullanıcı *bugünü* seçince **haksızca**
  *"ExecutionDate cannot be a future date"*
- `BuildCatchUpDates` → aralık bir gün **eksik/fazla** → gerçek muhasebe fişi

✅ İkisi de `IDateTimeProvider.GetCurrentDateTime().Date` kullanıyor — MM'in **muhasebe katmanının
zaten kullandığı** kaynak (`AccountingReverseFactory` fişin `StateDate`'ini bununla damgalıyor).
FluentValidation validator'ları ctor injection destekliyor (emsal
`IssueBondCreateRequestValidator`). WebUI'da `RediscountControllerBase` **10.1'de** zaten
geçirilmişti, Razor'dan `DateTime.Today` kaldırılmıştı.

---

## 16 — Ekran önerileri — ve bir BUG adayı

🔴 **Bug adayı (öneri değil):** ekran görüntüsünde `Product = Interbank Loan Transactions`
seçilince `Sub Product` **"This module's screen is not ready yet"** ile pasif. Oysa
`TreasuryRediscountController:21` o ürünü `RediscountModuleCodes.MM`'e bağlıyor ve MM
InterbankLoan'ı **destekliyor** (`ProductSourceType.InterbankLoan`, `TxnLoan`'da 95 satır). O metin
`mrResolveSubProducts` **boş döndüğünde** basılıyor → MM'in alt ürün ucu boş liste dönmüş.
**Sebep tespit edilmedi** — sıradaki iş.

Düşük maliyetli iyileştirme önerileri: statü pill'lerine **sayı** (`Not Rediscounted (3)`; sayılar
özet şeridinde **zaten** hesaplı) · `Execution Date` yanına varsayılanın **dün** olduğunu söyleyen
kısa ipucu. Diğer fikirler bilinçli olarak **önerilmedi**.

---

## 17 — 🔴 Transient neden çözmez (DI lifetime + change tracker)

Kullanıcının teşhisi **doğruydu**: *"transient yapsak bile tek nesne üzerinden tracking yapıp hata
alınca o nesne track ediliyor ve sonra hata veriyor."* Ölçülen gerekçeler:

### 17.1 Lifetime BULAŞICI değil

Bir servisi Transient yapmak **bağımlılıklarının** lifetime'ını değiştirmez. Container Transient
nesneyi kurarken ctor parametrelerini **aynı scope'tan** çözer; parametre Scoped kayıtlıysa scope
cache'inden **aynı örnek** gelir. `AddRepository` kayıtları
(`Code/Data/NetTrex.MM.Data.Repository/Extensions/RepositoryExtensions.cs`):

| Kayıt | Lifetime |
|---|---|
| `IUnitOfWork` → `UnitOfWork` | **Scoped** |
| `IDataContext` → `EfDbContext` | **Scoped** |
| `IRepository<>` → `Repository<>` | **Scoped** |
| `EfDbContext` (`AddDbContext`) | **Scoped** (varsayılan) |

→ 4 muhasebe servisini Transient yapsan **4 taze servis nesnesi, 1 `DbContext`**. Change tracker
`DbContext`'in içinde. **Etkisi matematiksel olarak sıfır.**

### 17.2 `DbContext`'i transient yapmak sistemi KIRAR

```
IRepository<AccEntryMainEntity>  →  DbContext A     ← InsertAsync buraya
IRepository<AccEntryEntity>      →  DbContext B     ← başka context
IUnitOfWork                      →  DbContext C     ← CommitAsync BURAYI kaydeder
```

`InsertAsync` A'ya ekler, `CommitAsync` C'yi kaydeder → **diske hiçbir şey gitmez, hata da vermez**.
Unit-of-Work tanımı gereği "çok repository, tek context, tek commit". Ayrıca her çözümleme kendi
bağlantısını açar ve değişiklik `AddRepository`'de, yani MM'in **her ucunun** geçtiği paylaşılan yol
(2026-08-19 kuralına aykırı).

### 17.3 Hatanın iki ayrı sonucu — biri susan

Tracker bir identity map: `key = (EntityType, PrimaryKey)` → `(nesne, State)`. 🔴 Bir `DbContext` bir
`(tip, key)` için **en fazla bir** nesne izleyebilir; hata bu kuralın bekçisi. `SaveChanges` anında
*"Id=X satırının durumu nedir?"* sorusunun **tek** cevabı olmalı.

| | Arıza | Görünürlük |
|---|---|---|
| **A** | `InsertAsync` kaydetmiyor → patlayan satırın `Added` fişleri tracker'da kalıp **sonraki satırın `Commit`'i** ile diske gidiyor | 🔴 **SESSİZ** — "hata" görülen satır fiş kesmiş |
| **B** | identity-map çakışması (`already being tracked`) | bağırıyor |

### 17.4 Tracked okuma yüzeyi — ölçüldü

`AccountingDataManager`'da `AsNoTracking()` **olmayan** üç yol var; hatanın tipi (`AccEntryEntity`)
ilk ikisinin `Include` ettiği çocuk:

| Metot | Tracking |
|---|---|
| 🔴 `GetNonReverseRevaluationWithTransactionIdAsync` (`:144-157`) | **TRACKED** + `Include(AccountingEntries)` — ters fiş akışının *"terslenecek fişi bul"* sorgusu |
| 🔴 `GetNonReversedOpeningWithTransactionIdAsync` (`:159-172`) | **TRACKED** + `Include` |
| `UpdateReverseIdAsync` (`:78-87`) | **TRACKED** — tasarım gereği |
| diğer 7 okuma | `AsNoTracking` ✅ |

İki muhtemel tetikleyici: (a) aynı satır içinde tracked okuma Id=X'i koyuyor, zincirdeki sonraki
servis aynı mantıksal satırı **başka bir nesne** olarak sokuyor; (b) Arıza A'nın artığı dururken
sonraki satır aynı Id'yi farklı nesneyle ekliyor.
⚠ **Hangi satırın ikinci nesneyi ürettiği tespit EDİLMEDİ** — `ex.Message` Id yazmıyor,
`EnableSensitiveDataLogging` canlıya açılamaz. Bu yüzden `catch`'e **tracker dökümü** kondu; bir
daha olursa `ReasonDetail` Id + FK + `State` listesini verir.

### 17.5 Batch izolasyonu SCOPE'tan alıyor — lifetime'dan değil

```
EOD BATCH                                  MANUEL REESKONT
RevaluationBatchItem → yeni scope → Ctx#1  1 HTTP isteği = 1 scope
ReverseBatchItem     → yeni scope → Ctx#2  satır başına 1-4 servis, HEPSİ Ctx#1
```

🔑 Yeni `DbContext` yalnız yeni **scope** (ya da `IDbContextFactory`) ile doğar. Transient bu
izolasyonu **üretemez**.

### 17.6 Dört araç

| Araç | Bizim durum |
|---|---|
| `AsNoTracking()` | okumalarda doğru varsayılan; **yazma** akışı tracker'a mecbur |
| `ChangeTracker.Clear()` | ✅ **seçilen** — EF Core'un **kendi public API'si**, tam olarak toplu iş yapan context'ler için; "müdahale" değil |
| satır başına yeni scope | batch'in yaptığı; ~20 satır plumbing, ekstra fayda yok (scope'ta `DbContext` dışında durum yok) |
| `IDbContextFactory<T>` | UnitOfWork/Repository kayıtlarını baştan yazmak gerekir → paylaşılan yol |

Uygulanan desen — **iki** `Reset()` gerekli (① satır temiz başlasın, ② artık sonraki satırın
commit'ine karışmasın):

```csharp
foreach (var item in request.Items)
{
    changeTrackerDataService.Reset();      // ①
    try { ... }
    catch (Exception ex)
    {
        response.Failed.Add(Fail(item, ..., $"{ex.Message} | tracker: {...}"));
        changeTrackerDataService.Reset();  // ②
    }
}
```

---

## 18 — ❌ GEÇERSİZ (tarihsel) — Yarım kalmış nötrleme: `HALF_NEUTRALIZED` guard'ı

> 🔴 **Bu bölümün kodu 2026-09-01'de SİLİNDİ** (kullanıcı kararı). Sebep: **bölüm 20**'nin
> ayna çifti `R1.ReverseId`'yi hiç ezmediği için orphan imzası **doğamıyor**. Bölüm tarihsel
> kayıt olarak duruyor — teşhis yöntemi (asimetri) başka bir yerde işe yarayabilir.

Kullanıcının yönlendirmesi: *"biz zaten `ReverseId` ve `IsReverse`'e göre ilerlemiyor muyuz…
bunlara göre gitmek lazım."* Doğru — eksik olan tek parça **iki ters kayıt türünün** ayrımıydı.

### 18.1 Açık gerçek miydi? — EVET

`Regenerate` + `Rediscounted` **4 bacaklı** (4 Fimple çağrısı, dağıtık transaction **yok**):

```
bacak 1: R1'in karşı fişi  → R1'in valörü      (gün T sıfırlanır)
bacak 2: Rev1'in karşı fişi → Rev1'in valörü   (gün T+n sıfırlanır)
bacak 3: yeni reeskont R2
bacak 4: yeni ters fiş Rev2
```

Bacak 1'den sonra kesilirse:

```
gün T:    R1 +A, CR1 −A          → net 0    ✅
gün T+n:  Rev1 −A                 → net −A   🔴 AÇIKTA
```

🔴 **Sayfayı yenilemek kaldığın yerden devam ETTİRMİYOR.** Statü türetimi `R1`'i bulur,
`R1.ReverseId` → `CR1`, `CR1.ValueDate == executionDate` (nötrleyici) → **`NotRediscounted`**.
Ekran *"reeskont yok, kes"* diyor; doğal aksiyon **Generate**:

```
gün T:    R1 +A, CR1 −A, R2 +A            → net +A   ✅
gün T+n:  Rev1 −A (ÖKSÜZ), Rev2 −A        → net −2A  🔴 İKİ KATI
```

Ekranın görememesinin sebebi: `R1.ReverseId` **ezildiği** için `Rev1`'e giden bağ kopmuş, hiçbir
sorgu `Rev1`'i aramıyor.

### 18.2 İki ters kayıt türünü `ValueDate` ayırır

| | `IsReverse` | `ReverseId` | `ValueDate` |
|---|---|---|---|
| **tamamlayıcı ters fiş** | 1 | reeskontu | reeskonttan **SONRA** |
| **nötrleyen karşı fiş** | 1 | kapattığı fişi | kapattığı fişle **AYNI** |

`ReverseId` **çift yönlü** olduğu için asimetri imzası çıkıyor:

```
NORMAL           R1 ──→ Rev1   ve   Rev1 ──→ R1     SİMETRİK  ✅
BACAK 1 SONRASI  R1 ──→ CR1    ama  Rev1 ──→ R1     ASİMETRİK 🔴
```

### 18.3 Uygulama — yeni tablo/flag YOK, üç kolon

`IAccountingDataManager.GetOrphanCompletingReverseAsync(rediscountId, rediscountValueDate,
rediscountReverseId)`:

```csharp
x.IsReverse
&& x.Type == Revaluation
&& x.ReverseId == rediscountId          // REESKONTU tersliyor
&& x.ValueDate > rediscountValueDate    // TAMAMLAYICI (nötrleyici aynı valöre kesilir)
&& x.Id != rediscountReverseId          // reeskont GERİ İŞARET ETMİYOR → bağ kopmuş
```

`ExecutionsHandler.RejectIfHalfNeutralizedAsync(...)` → `Generate`/`NotRediscounted` dalının
**başında** ve `RegenerateAsync`'te Processing/Error kontrolünden **sonra**. Bulunca **fiş
kesilmiyor**, `HALF_NEUTRALIZED` + açıktaki fişin Id'si ve valörü yazılıyor.

🔴 **Otomatik onarım YAPILMADI — bilerek:** karşı fiş kesmek gerçek para hareketi, kararı kullanıcı
verir. İstenirse tek satır (`CreateReverseAsync(orphan, ..., orphan.ValueDate)`).

**Yanlış pozitif olamaz:** R1'den ikinci bir **meşru** tamamlayıcı ters fiş hiçbir akıştan doğamıyor
— batch `IsReverse == false && ReverseId == 0` süzüyor
(`TransactionDataManager.GetPendingRevaluationReverseTransactions`), `Generate` `Rediscounted`'ı
reddediyor, `Regenerate`'in karşı fişleri ya aynı valöre kesiliyor ya `Rev1`'i gösteriyor.

### 18.4 Guard'ın yaptığı / yapmadığı

| | |
|---|---|
| ✅ | *sessiz çift kayıt* → *yüksek sesle red*; açıktaki fişi Id + tarihle isimlendirir |
| ❌ | kesilmeyi **önlemez** (4 bacak, dağıtık transaction yok) |
| ❌ | **onarmaz** — bilinçli |

### 18.5 Canlıda böyle bir öksüz var mı — kontrol sorgusu (koşulmadı)

```sql
SET NOCOUNT ON;
SELECT TOP (20) rev.Id, rev.TxnId, rev.ValueDate, rev.ReverseId,
       src.Id AS SrcId, src.ValueDate AS SrcValueDate, src.ReverseId AS SrcReverseId
FROM   accEntryMain rev
JOIN   accEntryMain src ON src.Id = rev.ReverseId
WHERE  rev.IsReverse = 1 AND rev.Type = 2
  AND  rev.ValueDate > src.ValueDate
  AND  src.ReverseId <> rev.Id
ORDER BY rev.Id DESC;
```

### 18.6 Dokunulan dosyalar (bölüm 18)

| Dosya | Ne |
|---|---|
| `NetTrex.MM.Api.ResponseRequest/.../ExecutionsResponse.cs` | `HalfNeutralized = "HALF_NEUTRALIZED"` |
| `NetTrex.MM.Data.Abstractions/Managers/Accounting/IAccountingDataManager.cs` | yeni metot + kural dokümantasyonu |
| `NetTrex.MM.Data/Managers/Accounting/AccountingDataManager.cs` | sorgu (`AsNoTracking`) |
| `NetTrex.MM.Api.Services/ManualRediscount/Handlers/ExecutionsHandler.cs` | `RejectIfHalfNeutralizedAsync` + 2 dalda guard |
| `manual-rediscount-{en,tr}.json` | `mr-reason-HALF_NEUTRALIZED` |
| `ExecutionsHandlerTests.cs` | `SetupOrphanReverse` + **3 yeni test** (225 → **228**) |

---

## 19 — Onay penceresi: iki trim (kullanıcı isteği)

1. *"neden parantez içinde `on its own value date` yazmışsın, direkt DB'den bakabiliyorsun"* →
   `mrConfirmEntry` artık `[valueTag, date]` parçalarının **boş olmayanlarını** birleştiriyor;
   karşı kayıt **gerçek tarihi** basıyor (`mrCommonReverseValueDate`), metin yalnız tarih **hiç
   bilinmiyorsa** düşüyor. Regenerate foot'unda artık `T+1 · -` yok.
2. *"`Existing entries are never deleted…` notunu siler misin, bilinen bir gerçek"* → `closeNote`
   iki gruptan da kaldırıldı, `mr-confirm-NoteCounterEntry` anahtarı **iki dilden** silindi.

---
## 20 — 🔴 AYNA ÇİFTİ (kullanıcı kararı 2026-09-01) — `Rediscounted` regenerate

### 20.1 Kullanıcının verdiği bilgi (koddan çıkarılamazdı)

> *"Bacak 1 ve bacak 2'nin tersini almıyacağız çünkü Core banking sistemimiz olan Fimple buna karşı
> çıkıyor, zaten `bacak 1'in tersi var` hatası veriyor. O yüzden bacak 1'deki bilgileri alıp ters
> çevirip **normal reeskont** oluşturmamız gerekiyor… ve bacak 1'in tersi bacak 2'ydi ya, bu sefer
> **bacak 2'deki ValueDate**'i alıp yeni ürettiğimiz reeskontun tersini keseceğiz."*

🔑 **Bu bilgi kodda YOK.** `IRevaluationReverseAccountingService` mekanik olarak sorunsuz görünüyor;
kısıt Fimple'ın **kendi state machine**'inde (bir fiş **bir kez** terslenebilir). Ben bu duvara
çarpmadan guard yazıyordum.

### 20.2 Defter

```
gün T      R1   +A   ← DOKUNULMAZ (`ReverseId`'si de EZİLMEZ)
           R1'  −A   ← YENİ, NORMAL reeskont (IsReverse=0, ReverseId=0), valör = R1.ValueDate
gün T+n    Rev1 −A   ← DOKUNULMAZ
           Rev1' +A  ← R1'in TERSİ, valör = Rev1.ValueDate (DB'den, HESAPLANMAZ)
sonra      R2 / Rev2 (bacak 3-4 değişmedi)
```

### 20.3 Neden bu tasarım daha iyi (değerlendirme)

| Boyut | Sonuç |
|---|---|
**Matematik** | Birebir aynı — "ters almak" zaten *borç/alacak yönü çevrilmiş fiş* demek; `IsReverse` **bizim** kolonumuz, Fimple'ın kuralı değil |
**Kısıt** | Kısıtı çözmüyor, **konusu olmaktan çıkıyor**: Fimple'a ters fiş **komutu** hiç gitmiyor (`SendRevaluationAccountingAsync` = normal fiş) |
**Denetim izi** | 🔑 **Asıl kazanç.** Karşı-fiş yöntemi `R1.ReverseId`'yi **eziyordu** = defterdeki DOĞRU bilgiyi yok ediyordu (orphan avının kökü buydu). Ayna hiçbir satırı değiştirmiyor → *düzeltme eklemelidir, silici değil* ilkesi |
**Makine** | Yeni varlık/statü/flag **yok**; düzeltme kendisi **normal bir reeskont döngüsü**, ikinci bacak **mevcut ve kanıtlanmış** reverse servisinden (EOD'nin kullandığı yol) geçiyor |
**Kod hacmi** | Karşı-fiş yönteminden **az** |

### 20.4 `ValueDate`'i bacak 2'den okumak = şemanın DOĞRULUK KOŞULU

Ayna çifti orijinal çiftin **aynı iki gününe** düşmezse nötrlemez, dengesizliği **taşır**.
Canlı veriyle:

```
R1 555960 valör 28.08   ·   Rev1 555961 valör 31.08   (T+3 — hafta sonu atlanmış)

T+1 varsayımı:  Rev1' → 29.08  →  29.08: +A FAZLA · 31.08: −A AÇIKTA   🔴
DB'den okuma:   Rev1' → 31.08  →  iki gün de 0                        ✅
```

### 20.5 Uygulama

**Yeni dosyalar** (paylaşılan dosyaya dokunulmadı):

| Dosya | Ne |
|---|---|
`NetTrex.MM.Common.Model/Accounting/RevaluationMirror/Contexts/RevaluationMirrorAccountingServiceContext.cs` | `SourceAccountingEntryMainId` · `LogicalReference` · `MirrorValueDate` · `MirrorReverseValueDate` |
`NetTrex.MM.Common.Abstractions/Accounting/RevaluationMirror/IRevaluationMirrorAccountingService.cs` | `IAccountingService<>` türevi |
`NetTrex.MM.Common.Services/Accounting/RevaluationMirror/RevaluationMirrorAccountingService.cs` | Fimple → INSERT → Kafka → Commit → tersi |

🔑 **DI satırı YAZILMADI** — `DependencyInjectionExtension.cs`'teki Scrutor taraması
(`AddClasses(c => c.AssignableTo(typeof(IAccountingService<>))).AsMatchingInterface()`)
otomatik kaydediyor. Paylaşılan DI dosyası **bit-bit orijinal**.

**Pipeline kurulmadı** (bilinçli): adımlar doğrusal ve dallanmasız. Pipeline + context + mapper +
4 step dosyası = fayda sağlamayan tören.

**Ayna fişinin kaynaktan tek farkı** `DebitCredit` yönü. Tutar, GL, müşteri, ccy, kur, `SeqNumber`,
`RuleId`, `AccAccountMapId` — hepsi aynı. Detay satırlarında `AccEntry.ReverseId = kaynak satırın Id`
(ters fiş fabrikasının **zaten** yaptığı şey; **ana fiş** seviyesinde bağ yok).
⚠️ Ölçüldü: detay seviyesindeki `ReverseId` **hiçbir yerde filtre edilmiyor** — tüm
`x.ReverseId == 0` filtreleri `AccEntryMainEntity` üzerinde.

**Handler** ([ExecutionsHandler.cs](../../../NetTrex.MM/Code/Api/NetTrex.MM.Api.Services/ManualRediscount/Handlers/ExecutionsHandler.cs)):
`NeutralizeCompletedCycleAsync` iki `CreateReverseAsync` yerine **tek** ayna çağrısı yapıyor;
`previousReverse`'ü okuma ihtiyacı da kalktı (valör `GetEntryValueDateAsync` ile zaten DB'den
geliyordu).

**Regresyon testi** `Handle_RegenerateOnRediscounted_ShouldNeutralizeWithMirrorPairNotByReversing`:
ayna bir kez · doğru iki valör · ters fiş servisi **yalnız yeni çift için bir kez** ·
`555801`/`555809` (mevcut fişler) **hiç terslenmiyor**.
⚠️ Fixture düzeltmesi gerekti: `BuildVoucher` her zaman `Id = 555801` döndürüyordu, yeni reeskont da
aynı Id'yi alıyordu → *"kaynağı terslemedik"* iddiası **ölçülemiyordu**. `BuildVoucher(reverseId, id)`
opsiyonel parametre; yeni fiş `555850`.

### 20.6 🔴 Kalan risk — şekli değişti, kaybolmadı

4 bacak + dağıtık transaction yokluğu duruyor. **Ayna çifti kesilip R2 kesilmeden** hata alınırsa:

```
defter TEMİZ:  gün T: R1 +A, R1' −A = 0   ·   gün T+n: Rev1 −A, Rev1' +A = 0
ama STATÜ:     T'deki en yeni ters-olmayan fiş = R1', ReverseId → Rev1' (valör > T)
               → `Rediscounted` (oysa doğru iş "nötrleme atla, yalnız yeni çift kes")
tekrar Regenerate → R1' aynalanır → gün T: +A −A +A +A = +2A   🔴
```

Sebep: `R1` ile `R1'` **`accEntryMain` kolonlarında birebir aynı** (`IsReverse=0`, aynı valör,
`ReverseId` dolu). Tutarlar tabloda değil **detayda**.

**Önerilen guard (kullanıcı kararı bekliyor, tek sorgu):** detay `ReverseId` bağı zaten kuruldu →
Regenerate başında `EXISTS(AccEntry e WHERE e.ReverseId IN (R1'in detay Id'leri))` → *"bu fiş zaten
aynalanmış"* → satırı `NotRediscounted` gibi işle (nötrleme atla). **Yeni kolon/tablo/marker yok.**

### 20.7 Bedeller (dürüst liste)

| Bedel | Not |
|---|---|
Gün T'de fiş birikiyor (R1, R1', R2, R2', R3…) | Append-only düzeltmenin doğal sonucu; muhasebe ekranında satır artar |
`R1` ↔ `R1'` kolonlardan ayırt edilemiyor | 20.6'daki açık |
🔴 **Fimple'ın ters yönlü reeskont fişini kabul edeceği KANITLANMADI** | Yapısal olarak normal fiş (EOD de T valörlü reeskont kesiyor) ama GL/hesap eşleme kuralı yön hassas olabilir (`Code 3058` sınıfı) → **duman testi şart** |
`MessageKey` | Ayna **kendi** MessageKey'ini alıyor, tersi onu referans ediyor. Sync kapalıysa `MessageKey = 0` ve reverse step'in `MessageKey == 0` guard'ı Fimple'ı atlıyor → tutarlı, dış durum öksüz kalmıyor |

### 20.8 Alternatiflerle kıyas (neden bu)

| Yöntem | Neden daha kötü |
|---|---|
**Delta fiş** (tek çift, `A2−A1`) | Para farkını **biz** hesaplarız, işaret dönebilir, denetim izi okunmaz, doküman § 4.3'ten sapar |
**Sil + yeniden yaz** | Muhasebe fişi silinmez; Fimple da izin vermez |
**Fimple'ı zorlamak** | Resmi defterle dövüşmek |
**Karşı fiş (eski)** | Fimple **reddediyor** + `R1.ReverseId`'yi **eziyor** |

---

## 21 — Kaldırılanlar (bölüm 18 geçersiz)

| Silinen | Yer |
|---|---|
`RejectIfHalfNeutralizedAsync` + 2 çağrı noktası | `ExecutionsHandler` |
`GetOrphanCompletingReverseAsync` (sorgu + arayüz + doküman) | `AccountingDataManager` · `IAccountingDataManager` |
`RediscountReasonCodes.HalfNeutralized` | `ExecutionsResponse` |
`mr-reason-HALF_NEUTRALIZED` | TR + EN localization |
`SetupOrphanReverse` + 3 test | `ExecutionsHandlerTests` (228 → **225**) |
`mr-confirm-EntryCounterReverse` · `mr-confirm-StageClosePair` | TR + EN (yerine `EntryMirrorRediscount`, `EntryMirrorReverse`, `StageMirror`) |

🔑 **Neden guard gereksiz oldu:** orphan imzası `R1.ReverseId`'nin **ezilmesinden** doğuyordu. Ayna
yönteminde o kolon **hiç değişmiyor** → asimetri **doğamıyor**. Guard bir semptomu koruyordu; yeni
tasarım semptomun **sebebini** kaldırdı.

**Onay penceresi** artık gerçekten yapılanı yazıyor: *"Ters işaretli yeni reeskont fişi — mevcut
reeskontu nötrler"* + *"Onun ters fişi — mevcut ters fişi nötrler"*, aşama başlığı *"mevcut fişlere
dokunulmaz"*. JS testleri yeni metinlere göre güncellendi (438/438).

---

## 22 — Ekran (iki ara mesaj)

### 22.1 Pencere açıklamaları aynı hizada

Kullanıcı: *"açıklamalardaki yazıları aynı hizada başlat, hizaya önem ver… güzelleştir."*

Kök neden: `.mr-info-row` **flex**'ti → rozet genişliği satır satır değiştiği için metin her satırda
başka bir x'te başlıyordu (`Not Rediscounted` vs `Error`).

✅ **grid** (`grid-template-columns: 152px 1fr`): rozet/buton sütunu sabit + `width:100%` ile
ortalanmış → **tüm metinler aynı hizada**. Satırlara hafif zemin (`rgba(31,56,100,.035)`) +
`border-radius`, `.mr-info-list` gap 10→6px, dipnotlarda madde işareti asılı
(`padding-left:12px; text-indent:-12px`) → ikinci satır da hizada.
⚠️ `.mr-meaning-btn`'in `flex: 0 0 104px`'i grid'de **hiçbir şey yapmıyor** → `width: 100%`.

Üç pencere de aynı kuralı paylaşıyor: statü anlamları · Generate ⓘ · Regenerate ⓘ.

### 22.2 Kolon sırası + isimler

```
Status · Status Description · Product · Logical Reference · Customer Id · Customer Name · [ürün kolonları]
```

`mrBuildFixedColumns` dizisinde `Status` + `StatusDescription` blokları **başa** taşındı
(JS array literal'de trailing comma serbest olduğu için blok sırası bloklara dokunmadan değişti).

`External Customer Id` → **Customer Id**, `External Customer Name` → **Customer Name** (EN;
TR zaten `Müşteri No` / `Müşteri Adı`).

⚠️ **VARSAYIM:** kullanıcı *"`ExternalCustomer no` da Customer No olsun"* dedi ama ekranda
`ExternalCustomerNo` diye bir kolon **YOK** — `ExternalCustomerId` ve `ExternalCustomerName` var.
"External" ön eki ikisinden de atıldı. Gerçekten "Customer No" isteniyorsa tek satır.

⚠️ Kolon sırası testi (`kolonlar dokümandaki sırayla üretilir`) beklenen listede `StatusDescription`'ı
**iki kez** taşıyordu (yeni sıradan sonra ortaya çıktı) — düzeltildi.

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

### Bu turun doğrulamaları (bölüm 18-19)

8. Onay penceresinde karşı kayıt satırı **gerçek tarihi** basıyor mu (`(on its own value date)` metni
   yalnız tarih bilinmiyorken düşüyor)? Regenerate foot'unda `T+1 · -` **yok** mu?
9. `Existing entries are never deleted…` notu **kalktı** mı?
10. 🔴 **MM API yeniden başlatılmalı** — `HALF_NEUTRALIZED` guard'ı ve sözleşme değişti.
    Öksüz durum **canlıda yoksa test edilemez**; bölüm 18.5 sorgusuyla bakılabilir.

### Bu turun doğrulamaları (bölüm 20-22)

11. 🔴 **MM API durdur → derle → başlat** (yeni servis + Common.Services değişti).
12. `Rediscounted` satır + Regenerate → onay penceresinde *"Ters işaretli yeni reeskont fişi"* ve
    *"Onun ters fişi"* yazıyor mu; *"Counter entry closing…"* dili **kalktı** mı?
13. 🔴 **ASIL RİSK:** Fimple ayna fişini (ters yönlü reeskont, T valörü) **kabul ediyor mu**?
    Reddederse `Code`'u ve mesajı al — GL/hesap eşleme kuralı yön hassas olabilir.
14. `accEntryMain`'de ayna çifti: `R1'` (`IsReverse=0`, `ReverseId` → `Rev1'`) ve `Rev1'`
    (`IsReverse=1`, valör = **eski** `Rev1`'in valörü). `R1.ReverseId` **değişmemiş** olmalı.
15. Pencerelerde açıklamalar **aynı hizada** başlıyor mu; rozet/buton sütunu eşit genişlikte mi?
16. Grid'de kolon sırası `Status · Status Description · Product · Log. Ref. · Customer Id ·
    Customer Name` mi; başlıklarda "External" **kalmadı** mı?
