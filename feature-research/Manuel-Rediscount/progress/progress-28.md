# progress-28 — Doküman baştan sona okundu (7 görsel dahil), 4 sapma düzeltildi, DB'den doğrulandı

**Tarih:** 2026-08-18
**Tetikleyen (kullanıcı):** *"ben döküman okumayı sana bırakmıştım şimdi kendim okuyorum ve bence generate
ve regenerate işlevlerinin üzerine düşmeliyiz gibi hissettim… en baştan sonuna kadar tüm maddeleri ve
görselleri incelemeni istiyorum ve doğru ve mantıklı şekilde kod bu şekilde değilse ona göre ayarlamanı
istiyorum son kez detaylı bak ve bana son durumu raporla. en sonunda da bir test yapıp DB'de gerçekten
nasıl duruyor onu görmeni istiyorum."*

Kullanıcının işaret ettiği 3 nokta + kendi taramam:
1. *"Seçilen kayıtların tamamı aynı Revaluation Type değilse Generate pasif olmalıymış — bizimki şu an böyle mi?"*
2. *"§8.2 … bu kurala dikkat ediyor muyuz? görselde ki gibi soracak şekilde mi ayarladık biz de."*
3. *"3. attığım görselde toplu ya da tekli işlemlerde statüste durumları gözükmeli şekilde ayarladık değil mi"*
4. *"regenerate'te birden fazla aksiyon alacak ya, sonuç için aksiyona göre açıklama yazman gerekmiyor mu…
   bir de bunlar hata aldı ya bunların statüsü değişmedi, değişmesi gerekmiyor muydu"*

---

## Yöntem — bu turda doküman GERÇEKTEN okundu

Önceki turlarda `01-dokuman-analizi.md` (kendi türev özetim) üzerinden çalışıyordum. Bu turda kaynak
`.docx` **ham olarak** açıldı:

- `Manuel Reeskont v1.docx` → `word/document.xml` parse edildi (paragraf + **tablo hücreleri** + inline
  görsel referansları) → **318 satır / ~36 KB düz metin**
- **7 görselin tamamı** (`image1…image7`) çıkarılıp **tek tek incelendi**

🔑 **Ders:** iki sapma (aşağıdaki F-1, F-2) **yalnız görsellerde** ve doküman § 8'in gövde metninde
görünüyordu; kendi türev özetimde ya yoktu ya da yanlış yorumlanmıştı. Kaynağı okumak şart.

---

## Yapılanlar (Done)

### 🔴 F-1 — İşlem sonucu artık GRID'e yazılıyor (doküman § 3.4 / § 5.2 / § 8.4 + image7)

**Sapma neydi:** sonuç yalnız **dialog**'da gösteriliyor, hemen ardından `refresh()` çağrılıyordu →
sunucudan taze veri gelip sonucu **anında siliyordu**. Hata alan satır grid'de eski durumuyla kalıyordu.
Kullanıcının ekran görüntüsü tam bunu gösterdi: dialog *"2 rows failed"* diyor, grid satırları hâlâ
`Not Rediscounted`.

**Doküman ne diyor (birebir):**
- § 5.2: *"Grid üzerinde ayrı bir Action veya Last Result kolonu bulunmaz. İşlem sonuçları ve hata
  bilgileri **Status ve Status Description** alanları üzerinden gösterilir."*
- § 3.4: *"Başarısız kayıtlar **Error** durumunda gösterilir ve hata nedeni **Status Description**
  alanı üzerinden kullanıcıya sunulur."*
- § 8.4 + **image7**: grid'de `Not Reversed` (başarılı) ve `Error` (başarısız) satırlar **yan yana**;
  üstünde şerit: *"İşlem sonucu (anlık): 2 başarılı, 2 hata … Hata bilgisi saklanmaz."*
- § 8.4: *"**Sayfa yenilendiğinde** başarısız kayıt, kalıcı (DB) durumunda görünür."*

**Uygulama:**

| Dosya | Değişen |
|---|---|
| `manual-rediscount.actions.js` | **Sonuç overlay'i** — `mrSetResultOverlay` / `mrGetResultOverlay` / `mrClearResultOverlay`; `uniqueKey → Map(TransactionId → {status, description})` |
| `manual-rediscount.actions.js` | `mrRenderExecutionResultBar` — image7'nin şeridi |
| `manual-rediscount.columns.js` | `Status` ve `StatusDescription` kolonlarına `calculateCellValue` → overlay varsa onu, yoksa satırın DB durumunu gösterir |
| `manual-rediscount.component.js` | `execute()`'ın `finally`'sinden **`refresh()` KALDIRILDI** → yerine `clearSelection()` + `repaint()` |
| `manual-rediscount.component.js` | `refresh()` ve `CustomStore.load` overlay'i **temizler** (§ 8.4) |
| `Default.cshtml` | `mrExecutionResult_{key}` şerit kabı |
| `manual-rediscount.css` | `.mr-execution-result`, `.mr-result-bar-*` |

🔑 **Neden satır verisi değiştirilmedi:** § 3.1 *"Error … veritabanında kalıcı olarak saklanmaz"*.
Bilgi sunucudan gelmediği ve DB'ye yazılmadığı için **görüntü katmanında** tutuluyor. Tazeleme
kullanıcının kendi aksiyonuyla oluyor (filtre / pill / sayfa) — o an overlay silinip DB gerçeği görünüyor.

### 🔴 F-2 — Ters fiş valörü: serbest tarih → **T+1 / T+0 popup**'ı (§ 4.2 / § 6.4.3 / § 8.2 + image4)

**Sapma neydi — ve bu benim iki katlı hatamdı:**
- Ekranda **filtre çubuğunda serbest bir `Reverse Value Date` DateBox**'ı vardı.
- Üstüne progress-25'te `.Min(ExecutionDate.AddDays(1))` **ekledim** → **T+0 tamamen imkansız** hale geldi.
- Aynı turda `(T+0)`/`(T+1)` etiketlerini *"yalan söylüyor"* diyerek **kaldırdım** — gerekçem
  "kullanıcı serbest tarih seçebiliyor" idi. **Doküman serbest tarihe hiç izin vermiyor**; yani
  etiketler doğruydu, **serbest DateBox** yanlıştı. Tam tersini yapmışım.

**Doküman ne diyor (birebir):**
- § 6.4.3: `ReverseValueDate (**enum?**, T1 / T0): **yalnızca Not Reversed'da** gönderilir; diğer durumlarda null.`
- § 8.2: *"Not Reversed durumunda Execute öncesi ters fişin valörü sorulur: T+1 (standart) veya T+0.
  **Diğer durumlarda seçim sorulmaz.**"*
- § 4.2: *"T+1 (Varsayılan): … Execution Date **+ 1 iş günü** valörü ile"*
- **image4**: başlıklı dialog, 2 radyo (T+1 seçili), `Vazgeç` / `Kes`

**Uygulama — backend:**

| Dosya | Değişen |
|---|---|
| `ManualRediscountEnums.cs` | **yeni** `ReverseValueType { T1 = 1, T0 = 2 }` |
| `ExecutionsRequest.cs` (MM) | **yeni** `int? ReverseValueType` (ekranın alanı) · `ReverseValueDate` **kaçış kapısı** olarak kaldı (Swagger/betik) |
| `ExecutionsHandler.cs` | `ICalendarHelper` **enjekte edildi** · **yeni** `ResolveReverseValueDateAsync` (T0 → ExecutionDate · T1 → `NextWorkingDayAsync` · yoksa açık tarih · o da yoksa T+1) |
| `ExecutionsHandler.cs` | 🔴 **`AddDays(1)` bug'ı düzeltildi** — hem tek tarih hem `RegenerateToToday` döngüsündeki günlük ters valör artık **takvimden** |
| `ExecutionsRequestValidator.cs` | `ReverseValueType` aralık kuralı · 🔴 `ReverseValueDate > ExecutionDate` → **`>=`** (T+0 artık geçerli) |

**Uygulama — WebUI:**

| Dosya | Değişen |
|---|---|
| `ExecutionsRequest.cs` (WebUI) | `int? ReverseValueType` (sözleşme aynası) |
| `Default.cshtml` | **`Reverse Value Date` DateBox'ı KALDIRILDI** (§ 5.3 filtre listesinde yok) + artık kullanılmayan `mrOnExecutionDateChanged` silindi |
| `manual-rediscount.constants.js` | `MR_ReverseValueType` · `MR_REVERSE_DATE` seçicisi kaldırıldı |
| `manual-rediscount.actions.js` | **yeni** `mrAskReverseValueType` (image4 popup'ı) + `mrNotReversedRows` |
| `manual-rediscount.component.js` | Generate → seçimde `Not Reversed` **varsa** sorar · Regenerate → **sormaz**, T+1 sabit (§ 4.3/§ 4.6) |
| `manual-rediscount.actions.js` | Onay penceresi tarih değil **valör türü etiketi** gösteriyor |
| `manual-rediscount.css` | `.mr-rvt*` (image4 görünümü) |

🔑 **Onay penceresinde neden kesin tarih yazılmıyor:** T+1 = +1 **iş günü** ve takvim modülde.
UI tarih uydurursa Cuma'da "Cumartesi" yazar, modül Pazartesi'ye keser → **ekran yalan söyler**.

### 🟡 F-3 — Sonuç açıklaması artık **aksiyona göre** (kullanıcının 4. sorusu)

`mrDescribeSuccess(operation, newStatus)`:

| Aksiyon / varılan durum | Metin |
|---|---|
| Generate → `Not Reversed` | "Rediscount entry created." |
| Generate → `Rediscounted` | "Reverse entry created." |
| **Regenerate** (her durum) | "Previous valuation reversed, new rediscount and reverse entries created." |
| Başarısız | § 3.3 biçimi: `<sebep> — <detay>` |

Gerekçe: Generate ile Regenerate **farklı sayıda fiş** kesiyor (`Not Reversed` + Regenerate = **3 fiş**),
tek bir "başarılı" metni bunu gizliyordu. image7'de de metin işi anlatıyor.

### ✅ F-4 — Kullanıcının 1. sorusu: karışık Revaluation Type → Generate pasif **ZATEN VARDI**

`mrIsSingleRevaluationType` + `mrUpdateToolbarState` (`actions.js:64-102`) doküman § 4.6'yı uyguluyor;
buton pasifleşiyor ve **altında kalıcı ipucu** çıkıyor (image3'teki gibi). Generic yazılmış: satır
`RevaluationType` taşımıyorsa kural uygulanmıyor.
⚠️ **MM'de pratikte hiç tetiklenmez** — MM `RevaluationType`'ı **global framework parametresinden**
üretiyor, yani tüm satırlarda aynı. Kural FX gibi satır bazında değişen bir modülde devreye girer.

### Faz etiketleri düzeltildi

`RegenerateToToday` kodda *"Faz 3"* diye yorumlanmıştı; doküman § 0.1 bunu **Faz 2** diyor
(kullanıcı fark etti). Backend hazır ve testli, **ekranda kapalı** (sabit `false`) — yorumlar düzeltildi.

---

## 🔴 DB doğrulaması (kullanıcı isteği) — DB bu turda ERİŞİLEBİLİR

progress-26'da `192.168.10.211` login timeout veriyordu (#17); bu turda **cevap verdi**.
11 sorgu (#18–#28) `sql-log/manuel-reeskont-kodlama/` içine **çalıştırılmadan önce** yazıldı, çıktılar sonra.

### ✅ Ekranın kestiği fişler DB'de DOĞRU duruyor

`TxnId 553337` için **iki tam döngü**:
`555825`(T+0 · 18.08) + `555826`(T+1 · 19.08), ardından `555827`(T+0 · 18.08) + `555828`(T+1 · 19.08).
İkinci çift **Regenerate'in imzası** — doküman § 4.3 ile birebir. `ReverseId` **iki yönlü** bağlı.
**T-01 fix çalışıyor:** ters fişin `StateMaker`'ı `SYSTEM` değil, gerçek kullanıcı.

### 🔴 Bulgu 1 — Hafta sonu valörlü ters fiş: canlıda **%43**

```
Ters fiş valör günü:  Sunday 645 · Tuesday 255 · Monday 235 · Wednesday 232
                      Thursday 222 · Saturday 208 · Friday 186
```
**1983 ters fişin 853'ü hafta sonu.** Örnek: `555770`(Cuma 24.07) → `555772`(**Cumartesi** 25.07).
Bunlar **batch** üretimi (`StateMaker = SYSTEM`) — yani düz `AddDays(1)` davranışı **mevcut sistemde de var**.
Bizim kod artık takvim kullanıyor; **batch düzeltilmedi** (kapsam dışı, ayrı iş).

### ✅ Bulgu 2 — Eski validator kuralım canlı veriyle çürütüldü

`DayDiff = 0` (**aynı gün** ters fiş) satırları canlıda **mevcut** (`555798→555800`, `555797→555799`).
Yani *"aynı gün ters fiş muhasebeyi anlamsız kılar"* gerekçemle koyduğum kural yanlıştı; doküman § 8.2
T+0'ı açıkça sunuyor. Kural `>=`'e çevrildi ve testi de dokümana çekildi.

### ✅ Bulgu 3 — Id örtüşmesi YOK (progress-26'nın açık kalemi KAPANDI)

```
TxnMM   551.002 – 553.337  (631 satır)
TxnLoan 1.201.069 – 1.201.167 (95 satır)   →  kesişim BOŞ
```
Aynı Id iki tabloda **yok**; hiçbir `TxnId`'nin iki farklı `ProductCode` altında fişi **yok**.
"Risk latent" değerlendirmesi artık **ölçülmüş bilgi**.

### 🔴 Bulgu 4 — `ProductCode` TABLOYU GÖSTERMİYOR (progress-26'daki varsayımım yanlıştı)

- `ProductCode='Loan'` fişlerinin **tamamı `TxnMM`**'e ait (20/20)
- `ProductCode='MM'` fişlerinin bir kısmı **`TxnLoan`**'a ait (13 satır, `TxnId ≥ 1.201.069`)

`ProductCode` bir **ürün** sınıflandırması (`PrdProductDefinition.MainProductCode`), tablo göstergesi değil.
**Ayrımı fiilen yapan şey navigation join'in kendisi** (aralıklar ayrık olduğu için yanlış tabloya join tutmuyor).
Eklediğim filtre **tutarlılık kontrolü** olarak doğru ve zararsız, ama aralıklar örtüşürse
**tiebreaker olarak yetmez**. Gerçek çözüm **discriminator kolonu** — ayrı iş.
MM `MEMORY.md`'deki girdi **düzeltildi** (ikinci düzeltme).

### 🟡 Bulgu 5 — Audit yarım (doküman C-19)

T+0 fişinin `StateMaker`'ı **transaction'ın maker'ı** (`PARTNER.TREASY.004` — `TxnMM.StateMaker` ile
doğrulandı), Generate'e basan kişi **değil** (o yalnız T+1'de: `PARTNER_NETIX_001`).
"Bu reeskontu kim manuel tetikledi" bilgisi **yarım** kayıtlı. Muhasebe kaydının sahipliğini değiştirmek
onay gerektirir → **yapılmadı**.

---

## Test durumu

| Ne | Sonuç |
|---|---|
| `NetTrex.MM.Api.Services.Tests` — `*ManualRediscount*` | **100 / 0 hata** (93 → 100, **7 yeni**) |
| `NetTrex.MM.Api.Services.Tests` — tamamı | **190 / 0 hata** |
| `NetTrex.MM.Data.Tests` | **3 / 0** |
| `NetTrex.MM.Data.Repository.Tests` | **271 / 0** |
| `Trex.Web.UI.sln` build | **0 error** |
| 8 JS dosyası `node --check` | **8/8 OK** |
| 4 localization JSON | **4/4 geçerli** (13 yeni anahtar × 4) |

**Yeni testler (7):**
- `Handle_WhenReverseValueTypeIsT0_ShouldUseExecutionDateAsReverseValue`
- `Handle_WhenReverseValueTypeIsT1_ShouldUseCalendarNextWorkingDayNotPlusOneDay` ← **iş günü bug'ını kilitliyor**
- `Handle_WhenNeitherReverseValueTypeNorDateGiven_ShouldFallBackToCalendarNextWorkingDay`
- `Handle_WhenBothReverseValueTypeAndDateGiven_TypeShouldWin`
- `Validate_WhenReverseValueDateIsSameAsExecutionDate_ShouldNotHaveError` ← eski yanlış kuralın yerine
- `Validate_WhenReverseValueDateIsBeforeExecutionDate_ShouldHaveError`
- `Validate_WhenReverseValueTypeIsValid/OutOfRange/IsNull_*` (Theory'ler)

⚠️ **Değiştirilen test:** `Validate_WhenReverseValueDateIsNotAfterExecutionDate_ShouldHaveError`
**kasıtlı olarak** kaldırıldı — benim yanlış kuralımı kilitliyordu (doküman T+0'a izin veriyor).

⚠️ **Tarayıcıda test EDİLMEDİ** — bu turun tamamı kullanıcı testi bekliyor.
⚠️ **WebUI JS/controller testi yok** (harness boşluğu): overlay, popup ve şerit **birim testle kapsanmıyor**.

---

## Yapılıyor (In Progress)

Yok.

---

## Yapılacaklar (TODO)

### 🟢 Tarayıcı testi bekleyen (bu turda yazılanlar)

- **Valör popup'ı:** `Not Reversed` satır seçip Generate → image4 gibi dialog çıkıyor mu? T+0 seçilince
  ters fiş **aynı gün** mü kesiliyor (DB'den `DayDiff = 0` doğrulanmalı)?
- **Popup ÇIKMAMASI gereken hâl:** yalnız `Not Rediscounted` satır seçip Generate → soru **sorulmamalı**
- **Regenerate** → valör **sorulmamalı**, T+1 gitmeli
- **Sonuç grid'de:** hata alan satır `Error` rozeti + sebep `Status Description`'da; başarılı satır yeni
  durumu + aksiyona uygun metin; grid üstünde şerit
- **Tazeleme:** filtre değiştirince sonuç silinip DB durumu dönüyor mu (§ 8.4)
- **Cuma testi (önemli):** `ExecutionDate` = Cuma + T+1 → ters fiş **Pazartesi** olmalı, Cumartesi **olmamalı**
- Parçalama + `Processing N/M` (progress-27)
- IL satırında Generate/Regenerate (progress-26)

### 🔴 Kullanıcı aksiyonu (kod işi değil)

| # | Konu | Neden |
|---|---|---|
| 1 | **Kafka broker down** (`localhost:9092`) | fire-and-forget + hata yutuluyor → fişler NetTrexAcc'ye gitmemiş olabilir |
| 2 | **`AccAccountMap` konfigürasyonu** — `36099200` için Fimple 3058 | şu an fiş kesilemiyor; muhasebe konfigürasyonu |

### 🟡 Karar/onay bekleyen

| # | Konu |
|---|---|
| 3 | 🔴 **Batch'te hafta sonu valörlü ters fiş (%43)** — `ReverseBatchItem` takvim kullanmıyor. Manuel ekran düzeltildi, batch **dokunulmadı** (kapsam dışı + geçmiş veri etkisi) |
| 4 | 🔴 **`AccEntryMain`'de discriminator kolonu yok** — `ProductCode` tabloyu ayırmıyor (Bulgu 4). Bugün aralıklar ayrık olduğu için güvenli |
| 5 | **Audit yarım (C-19)** — T+0 fişi Generate'e basanı kaydetmiyor (Bulgu 5) |
| 6 | **Uzun koşuyu iptal edememe** — 20 satır ≈ dakikalar; `AbortController` + Cancel önerisi (progress-27) |
| 7 | `FxRate` hardcoded 0 · para birimi bazlı ondalık (JPY/KWD) yok · Kafka publish `CommitAsync`'ten önce · batch sorgularında `ProductCode` filtresi yok · `AccruedInterest`/`DailyAccrual` IL'de null · Execute-hang parkta |

### 🟨 Doküman ile BİLİNÇLİ farklar (kapatılmadı — iş birimi kararı gerekiyor)

| # | Doküman | Bizde | Sebep |
|---|---|---|---|
| D-1 | § 5.4 *"seçim … mevcut filtre kriterlerine uyan **tüm veri kümesini** kapsar"* (`100 of 248`) | Seçim **yüklenmiş satırlarla** sınırlı, aşınca uyarı | Sözleşme § 12: görülmeyen satıra fiş kesilmemeli. `SelectAll: bool` sözleşmede yok (`C-10` açık) |
| D-2 | § 5.3 `Revaluation Type` **çoklu filtre** | MM'de alan **gizli** (`revaluationTypes: []`) | `C-03` açık: değer kümesi tanımsız, listeyi döndüren uç yasak (§ 6.2). MM'de değer global parametreden geliyor |
| D-3 | § 6.2 `/manuel-reeskont/...` · § 6.3 `Html.DevExtreme().ManuelReeskont()` | `/manual-rediscount/...` · `.ManualRediscount()` | Kullanıcı kararı 2026-08-13 (kod adı İngilizce) |
| D-4 | § 5.5 `baseUrl` | `moduleCode` | Kullanıcı onayı: WebUI'de runtime base-URL resolver yok; `baseUrl` = uygulama kökü |
| D-5 | § 6.4.4 `Failed[].Reason` | `ReasonCode` + `ReasonDetail` | Üst küme; UI localize edebilsin diye (`C-13` önerisi) |
| D-6 | § 3.1 `Processing` durumu | Üretilmiyor (enum'da rezerve) | `C-07`: akış senkron, ara durum oluşmuyor |
| D-7 | § 0.1 Faz 2 `RegenerateToToday` | Backend hazır, **ekranda kapalı** | Faz 2 devreye alınmadı |
| D-8 | § 4.4 tek buton `Execute Selected` | İki buton `Generate` / `Regenerate` | `C-01`: doküman **iki tasarım nesli** taşıyor; yeni nesil (§ 4.6 + image2/3/5/6) esas alındı |
