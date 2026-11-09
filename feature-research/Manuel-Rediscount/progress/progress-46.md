# progress-46 — Statü değerleme döngüsü farkında · `Regenerate` çift tahakkuk onarıldı · **dar ekran layout çakışması düzeltildi**

**Tarih:** 2026-08-26 · **Repo:** `NetTrex.MM` + `NetTrex.Web.UI`
**Test:** MM 221/221 · JS 116/116 (manualRediscount) · **Build:** iki repo 0 Error

> `progress-45`'in tam hali + **bölüm 8** (kullanıcının yeni isteği: *"küçük bir ekranda
> butonlar çok yan yana olduğu için alanlar birbirinin üstüne biniyor"*).

---

## Kullanıcının soruları (1-3 önceki tur · 4 bu tur)

| # | Soru | Sonuç |
|---|------|:-----:|
| 1 | *"Neden `o tarihte aktif faiz dönemi var` şartına baktık, gerçekten gerekli miydi, önceden yazılmış sorguları referans alıp mı baktın?"* | ✅ Cevaplandı — **zorunlu**, iki bağımsız gerekçe |
| 2 | *"Statü durumlarında değerleme döngüsüne hakim olmak lazım… `isReverse` ve `reverseId`'ye bakman yeterli değil, bir de T+1 durumuna bakmak lazım"* | 🔴 **KULLANICI HAKLIYDI** — kod düzeltildi |
| 3 | *"Reeskont motorunu okuyup kesin sonucu çıkar"* (mutlak mı delta mı) | 🔴 **MUTLAK** — çift tahakkuk hatası doğrulandı ve onarıldı |
| 4 | *"Küçük bir ekranda açınca butonlar çok yan yana olduğu için alanlar birbirinin üstüne biniyor"* | ✅ Düzeltildi — **bölüm 8** |

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

## Test öncesi

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
