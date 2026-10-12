# progress-30 — Kullanıcı isteği: 6 + 4 madde (2026-08-19)

> **Kullanıcının talebi (kendi sözleriyle):** *"ben dökümanı okuyordum ve bu dökümandan anladığım
> kadarıyla seninle konuştuğumuz konular vardı, bu konulardan bazılarına netlik getirdim ve sana
> söyleyeceğim gibi çalışıyor değil mi? Bunun kontrolünü yap ve eğer ki böyle değilse istediğim
> şekilde yapmanı istiyorum kodları."*
>
> Tur içinde **3 ek mesaj** daha geldi (MM/IL sorguları · Faz 2 uyarısı · durumlar/Processing).
> Toplam **10 madde** işlendi.

---

## 0. Özet tablo — hangi madde ne oldu

| # | Kullanıcı isteği | Durum | Nerede |
|---|---|---|---|
| **1** | Grid üstündeki `Selection` (sayıya göre listeleme) menüsü **kaldırılsın** — pagination yeterli | ✅ **kaldırıldı** (WebUI'de; MM'de karşılığı **yoktu**) | `filters.js`, `component.js`, `constants.js`, `Default.cshtml`, css, localization |
| **2a** | **Generate** için seçim **aynı statüde** olmalı; farklı statülü satır seçilir seçilmez buton **disabled** + küçük bir yazı | ✅ **yapıldı** (yeni kural `D-10`) | `mrIsSingleStatus` + `mrUpdateToolbarState` + `mr-hint-*` |
| **2b** | **Regenerate**'te statü kısıtı **olmasın**, her satır kendi durumuna göre değerlendirilsin | ✅ **zaten böyleydi**, korundu | `mrUpdateToolbarState` (yalnız Generate'i kısıtlar) · `RegenerateAsync` |
| **2c** | Regenerate **en son `Rediscounted`** olacak şekilde | ✅ **zaten böyle** — doküman görseliyle **doğrulandı** | `ExecutionsHandler.RegenerateAsync` → `Success(Rediscounted)` |
| **3** | Generate/Regenerate **TEK istek** göndersin, döngü **backend'te** dönsün | ✅ **yapıldı** + 🔴 timeout kökten çözüldü | `#executeAll`, `MaxItems 10→50`, Refit timeout **10 dk** |
| **4** | Ters fiş **yalnız T+0 / T+1**, kullanıcıya sorulsun | ✅ **zaten yapılmıştı** (2026-08-18), doğrulandı | `mrAskReverseValueType` + `ReverseValueType` enum |
| **5** | § 8.2 valör popup'ı + § 8.3 Regenerate onayı + § 8.4 sonuç gösterimi **görsele daha çok benzesin** | ✅ **yeniden yazıldı** — `dxPopup` tabanlı ortak dialog kabuğu | `mrShowDialog` + `.mr-dialog` css |
| **6** | Generate/Regenerate **renkleri farklı** olsun (görselde farklı, bizde aynıydı) | ✅ **yapıldı** — lacivert / turuncu | `buttonClass` + `.mr-btn-generate` / `.mr-btn-regenerate` |
| **7** | MM ve InterbankLoan **ayrı tablolar** — Get/Select sorguları doğru mu, Strategy pattern'e uygun mu | 🟢 **doğru** + 1 **sessiz risk düzeltildi** | `AccountingDataManager.GetRevaluationByValueDateAsync` |
| **8** | `RegenerateToToday` **Faz 2** — biz Faz 1'deyiz, **verilen güne göre** hareket et | ✅ **zaten böyle** (`RegenerateToToday: false`) | `component.js` + `BuildCatchUpDates` |
| **9** | `Processing` durumu — butona basınca işlenen satırlar **anlık** gösterilsin, statüsü değişerek | ✅ **YENİ — eklendi** (`D-6` kapandı) | `mrSetPendingOverlay` |
| **10** | Durum **en son (güncel)** fişe göre belirlenmeli · tekrar istekte **backend'in son durumu** esas · UI kafa karıştırmasın | 🟢 sıralama **doğruydu** · 🔴 UI'da **gerçek bir tutarsızlık bulundu ve düzeltildi** | `dbStatus` + `mrEffectiveStatus` |

**Test:** MM **190/0** ✅ · JS **344/344** ✅ (10 yeni test) · `NetTrex.MM.Data` build **0 error** ·
`Trex.WebUI` build **0 error**.

---

## 1. `Selection` menüsü kaldırıldı (istek 1)

**Kullanıcı:** *"bu ekran üzerinde SELECTION alanı var ya buna gerek yok, burada sayıya göre
listeliyor ya bunu kaldıralım çünkü zaten benim datagrid'imdeki yapı pagination şeklinde, o yeterli
bana. Bunu WebUI ve MM tarafında işlevleri varsa sil, bunu ekrandan."*

**Ne vardı:** grid'in sol üstünde `[☑] ▾` caret menüsü — `Select All / 100 / 50 / 25 / Custom…` +
yanında `"100 of 248 selected"`. Doküman § 5.4 ve § 8.3 bunu **açıkça tanımlıyordu**.

**Silinenler:**

| Katman | Silinen |
|---|---|
| `manual-rediscount.filters.js` | `mrRenderSelectionMenu` · `mrApplySelectionCount` · `mrPromptSelectionCount` · `mrUpdateSelectionInfo` |
| `manual-rediscount.component.js` | `selectLoaded()` · `selectFirst(n)` · `#loadedKeys()` · ctor'daki menü çağrısı · `onSelectionChanged`'daki `mrUpdateSelectionInfo` |
| `manual-rediscount.constants.js` | `MR_SELECTION_MENU` · `MR_SelectCounts` |
| `Default.cshtml` | `<div class="mr-selection" id="mrSelectionMenu_…">` |
| `manual-rediscount.css` | `.mr-selection` · `.mr-selection-info` · `.mr-custom-input` |
| localization (en+tr) | `mr-select-Menu` · `mr-select-All` · `mr-select-Custom` · `mr-select-CustomPrompt` · `mr-select-Of` · `mr-select-Selected` · `mr-warn-SelectAllPageOnly` · `mr-warn-SelectCountTruncated` |

**MM tarafında karşılığı YOKTU** — arandı, bulunamadı: sözleşmede `SelectAll: bool` gibi bir alan
hiç açılmamıştı (§ 12 gereği açık `TransactionId` listesiyle çalışıyor), `Take` üst sınırı da
menüden bağımsız. Yani **silinecek bir MM işlevi yok**; sadece ekran tarafı temizlendi.

**Ne KALDI:** DevExtreme'in kendi başlık checkbox'ı (`allowSelectAll: true`) — görünen sayfayı seçer,
image3'te de var. Pager (`showPageSizeSelector`, `[25, 50, 100]`) duruyor. Seçim özeti
(*"Seçili 3 kayıt — Revaluation Type: … (karışık)"*, image3) **duruyor** — o bir menü değil.

🟨 **Dokümanla bilinçli fark `D-9`:** § 8.3'ün *"seçim tüm veri kümesini kapsar"* maddesi de bununla
düşüyor. Zaten hiç uygulanmamıştı (sözleşme § 12: görülmeyen satıra muhasebe fişi kesilmez), yani
pratikte kaybedilen bir davranış yok.

---

## 2. Generate: karışık **statü** → buton pasif (istek 2a)

**Kullanıcı:** *"generate için aynı statüde olmalı… diyelim ki Rediscounted 4 tane transaction
seçtim ve 5. olanı seçerken onun statüsü Rediscounted değilse yani farklıysa, bastığım an generate
butonu disabled olsun istiyorum. Ve bir yazı da çıkarabilirsin bir yerde küçük bir şekilde."*

**Yapılan:** `mrIsSingleStatus(uniqueKey, rows)` eklendi; `mrUpdateToolbarState` artık **iki** kapı
uyguluyor ve ikisi de **yalnız Generate**'i kısıtlıyor:

| Kapı | Kaynak |
|---|---|
| karışık **Revaluation Type** | doküman § 4.6 (zaten vardı) |
| karışık **Status** | 🔴 **kullanıcı kuralı** (`D-10`, yeni) |

İpucu satırı image3'e göre **iki satır**: üstte gri gerekçe, altında kalın turuncu sonuç.

```
seçim birden çok Status içerdiğinden,
Generate pasiftir
```

İki sebep birlikteyse ikisi de yazılır (`… ve …`).

🟨 **Bu dokümandan SAPMA (`D-10`) — açıkça söylüyorum:** doküman § 5.3 *"her kayıt üzerinde
uygulanacak işlem, kaydın kendi durumuna göre belirlenir"* diyerek karışık durumu **destekliyor**;
§ 4.6 pasifleştirmeyi **yalnız Revaluation Type** için tanımlıyor. **2026-08-18'de kullanıcıya
"karışık statüde Generate pasifleşmemeli, § 5.3 böyle diyor" demiştim** — kullanıcı bu turda
tersini istedi. Karar kullanıcının; gerekçesi de sağlam: Generate durum makinesini **bir adım**
ilerlettiği için karışık seçimde tek tıkla farklı işler yapılıyor ve onay penceresi ne olacağını
tek cümlede anlatamıyor.

**Regenerate'te uygulanmadı** — kullanıcı: *"regeneration için buna gerek yok, en fazla statülü
transaction seçilip her biri için durumu ve statüsü değerlendirilip aksiyon alınabilir."*
Teknik dayanak: Regenerate her satırı **aynı** sonuca götürüyor (`Rediscounted`).

**Testler:** `mrIsSingleStatus` için 4 test (aynı statü · kullanıcının verdiği 4+1 örneği · boş
seçim · overlay'li kalıcı durum).

---

## 3. Regenerate **`Rediscounted`**'da bitiyor (istek 2c) — GÖRSELDEN doğrulandı

**Kullanıcı:** *"regeneration içinde en son rediscounted olacak şekilde olmalı… regenerate'e
tıklandığında en son reeskont mu oluşuyor yoksa ters fişine kadar kesiyor musun diye — son kararım
en son reeskont kesilmesini istiyorum, bu halde olacak şekilde ayarla."*

İki cümle **iki farklı** şeye işaret ediyordu ve bu **fiş sayısını** değiştiren bir karardı:

| Okuma | Sonuç durumu | Fimple turu (`Not Reversed` satırda) |
|---|---|---|
| (a) *"en son rediscounted olacak"* | **`Rediscounted`** (ters fiş de kesilir) | 3 |
| (b) *"en son reeskont kesilsin"* | `Not Reversed` (ters fiş kesilmez) | 2 |

**Doküman (a)'yı söylüyor — üç ayrı yerde:**

1. § 4.3: *"mevcut reeskont ve ters fiş kayıtları karşı kayıtları ile kapatılır. Ardından, seçilen
   Execution Date (T+0) için yeni reeskont kaydı oluşturulur **ve buna karşılık gelen ters fiş
   kaydı T+1 valörü ile yeniden oluşturulur**."*
2. § 4.6: *"Varsa önceki değerleme geri alınır ve güncel değerle **yeni reeskont (T+0) ile ters fişi
   (T+1)** kesilir."*
3. 🔴 **§ 3.6 durum geçiş diyagramı (image1)** — en net kanıt:
   `Rediscounted --Re-run (re-value)--> "via Processing → stays Rediscounted"`
   ve altındaki not: *"A Rediscounted transaction can be re-run: it re-values (T+0 rediscount +
   T+1 reverse) and **returns to Rediscounted**."*

**Sonuç: kod DEĞİŞTİRİLMEDİ** — `RegenerateAsync` zaten `Success(item, RediscountStatus.Rediscounted)`
döndürüyor ve ters fişi kesiyor. Kullanıcının ilk cümlesi ("en son rediscounted") doküman ile
birebir; ikinci cümle muhtemelen aynı şeyi *"reeskontu tam olarak kesilsin"* anlamında söylüyor.

⚠️ **Eğer kastedilen (b) ise bu bir satır değişiklikle döner** (`RegenerateAsync`'in son
`CreateReverseAsync` çağrısı kalkar, dönüş `NotReversed` olur) — ama doküman üç yerde (a) dediği
için **kendi kararımla değiştirmedim**. Kullanıcı onayı gerekiyor.

---

## 4. TEK istek + timeout kökten çözüldü (istek 3)

**Kullanıcı:** *"generate ve regenerate butonlarına bastığım zaman tek seferde gidiyor isteğim değil
mi? Sonra içerde foreach içinde dönüyor değil mi? Bu şekilde istiyorum çünkü her transaction için
istek gitmiyor, performanslı olmaz. Tek seferde gitsin ama içerde dönsün, sonra da hata alınanları
Error statüsünde göstersin, hata alınmayanlar hata alınanlardan dolayı bozulmasın."*

**Eski hâl (2026-08-18):** `MR_EXECUTE_CHUNK_SIZE = 1` → **satır başına bir HTTP isteği**.
Gerekçesi `HttpClient`'ın **100 saniyelik** varsayılan timeout'uydu.

**Yeni hâl:** `#executeChunked` → **`#executeAll`**. Tüm satırlar tek gövdede;
döngü `ExecutionsHandler`'ın `foreach`'inde (satır başına `try/catch`, `ADR-MR-007`) — yani
*"hata alınmayanlar hata alınanlardan dolayı bozulmaz"* şartı **backend'de zaten** karşılanıyordu.

🔴 **Timeout'u parçalama olmadan çözmek zorunluydu**, yoksa 3-4 satırdan fazlası yapısal olarak
patlıyordu. Yapılan (yeni, bu tur):

```csharp
// Trex.FrameworkCommon/Api/RefitExtensions.cs — YENİ metot
public static void RegisterClientWebApiRefitClientTimeout<TApi>(
    this IServiceCollection services, TimeSpan timeout) where TApi : class
    => services.AddRefitClient(typeof(TApi), CreateRefitSettings())
               .ConfigureHttpClient(c => c.Timeout = timeout);

// Trex.WebUI/Startup.cs — IClientMMAPI taramasından SONRA
services.RegisterClientWebApiRefitClientTimeout<IManualRediscountMmApi>(TimeSpan.FromMinutes(10));
```

**Nasıl çalışıyor:** `AddRefitClient` aynı arayüz için ikinci kez çağrılıyor; `IHttpClientFactory`
adlandırılmış istemci ayarları **eklemeli** olduğu için ilk kaydın `BaseAddress` delegesi korunuyor,
bizim delege sonra koşup `Timeout`'u yazıyor.
⚠️ **`AddHttpMessageHandler` bilinçli olarak çağrılmadı** — aynı handler'ı zincire ikinci kez
eklemek onu iki kez koşturur (auth header iki kez yazılır).

**Diğer değişiklikler:**

| Ne | Eski | Yeni | Neden |
|---|---|---|---|
| `MaxItems` (MM) | 10 | **50** | Sınır artık normal akışta devrede; grid sayfa boyutuyla (50) hizalı |
| `MR_MAX_EXECUTE_ITEMS` (UI) | — | **50** | MM ile aynı sayı; UI aşarsa isteği hiç göndermiyor |
| ilerleme metni | `Processing 3/10…` | `Processing 10 records…` | Tek istek → parça sayacı yok |

🟥 **Kaybedilenler (bilinçli, kullanıcı isteği):**
1. `3/10` ilerleme göstergesi.
2. **Kısmi sonuç:** timeout/ağ hatasında `succeeded[]`/`failed[]` gelmez. Backend fişleri kesmiş
   olabilir. Bu yüzden transport hata metnine *"Hangi kayıtların işlendiğini görmek için listeyi
   yenileyin."* eklendi.

🔑 **Kazanılan:** N satır için 1 round-trip (eskiden N).

---

## 5. `Processing` (geçici durum) eklendi — `D-6` kapandı (istek 9)

**Kullanıcı:** *"Processing — İşlem core banking sistemine iletilmiş olup sonucu beklenmektedir. Bu
durum geçici olup sistemde kalıcı olarak saklanmaz. Bu durum var burada; biz butonlara
tıkladığımızda anlık olarak işlenen transaction'ları göstereceğiz bu şekilde statüsünü değiştirerek
değil mi? Ben bunu anladım, yanlış mı anlamışım."*

**Doğru anlamış — ama biz bunu YAPMIYORDUK.** `09-dokuman-uyumluluk-raporu.md`'de `D-6` olarak
*"`Processing` üretilmiyor (enum'da rezerve)"* yazıyordu.

**Şimdi yapıldı:** `mrSetPendingOverlay(uniqueKey, items)` — istek uçmadan hemen önce gönderilen tüm
satırlar `Processing` (mavi rozet, § 7.1) + `Status Description`'da *"Core banking sistemine
iletildi, sonuç bekleniyor."* Yanıt gelince `mrSetResultOverlay` üzerine yazar (yeni durum veya
`Error`). **DB'ye hiç yazılmaz** — doküman § 3.1 zaten *"kalıcı olarak saklanmaz"* diyor, image1 de
iki ara adımı **(transient)** etiketiyle gösteriyor.

`repaint()` şart — kolonlar `cellTemplate` kullandığı için overlay'i grid'e basan tek şey o.

⚠️ **Bilinen sınır:** `showLoader()` tüm ekranı yarı saydam bir shading ile kapatıyor, dolayısıyla
`Processing` rozetleri **soluk** görünür. Loader'ı kaldırmadım: fiş kesilirken filtre/pill'in
tıklanabilir kalması daha kötü.

---

## 6. 🔴 UI kafa karışıklığı — gerçek bir tutarsızlık bulundu ve düzeltildi (istek 10)

**Kullanıcı:** *"bak bu durumlara da çok dikkatli bak çünkü biz veritabanına hiçbir şey saklamıyoruz
ve UI tarafında gösteriyoruz ya bazı değişiklikleri anlık olarak; fakat tekrardan istek atıldığı
zaman her zaman backend'teki son durum değerlendirilmeli. UI tarafı kafa karışıklığına sebep
vermemeli."*

**Backend tarafı zaten doğruydu:** `ExecuteItemAsync` her satır için durumu **DB'den yeniden
türetiyor** (`GetRevaluationByValueDateAsync`) ve ekranın gördüğüyle uyuşmuyorsa işlem yapmadan
`STATUS_CHANGED` döndürüyor (doküman § 4.5).

**🔴 UI tarafında ise gerçek bir tutarsızlık vardı:** § 8.4 gereği Execute sonrası `refresh()`
**çağırmıyoruz** (sonuç ekranda kalsın diye). Bu yüzden `row.Status` **eski veri yüklemesinden**
kalma değeri taşımaya devam ediyordu. Kullanıcı o turda **başarılı** olmuş bir satırı tekrar seçip
Execute'a bastığında istekteki `CurrentStatus` **bayat** gidiyordu → modül § 4.5 gereği
`STATUS_CHANGED` ile reddediyordu → **kullanıcı için sebepsiz bir hata**.

**Çözüm:** overlay artık **iki ayrı şey** tutuyor:

| Alan | Ne | Kim kullanır |
|---|---|---|
| `status` / `description` | **GÖRÜNEN** durum (`Processing`, `Error` veya yeni durum) | grid `cellTemplate` |
| `dbStatus` | **KALICI (DB)** durum — yalnız işlem **başarılı** olduğunda güncellenir | `mrEffectiveStatus` |

`mrEffectiveStatus(uniqueKey, row)` = `dbStatus ?? row.Status`. Kullanan **her yer** buna geçirildi:

- istek gövdesindeki `CurrentStatus`
- `mrIsSingleStatus` (karışık statü kapısı)
- `mrNotReversedRows` (valör popup'ının kapısı)
- `mrCountByStatus` (Regenerate onayının kırılımı)

🔴 **`Error` ve `Processing` ASLA `CurrentStatus` olarak gönderilmez** — ikisi de kalıcı durum değil
(§ 3.1). Hata alan satırın `dbStatus`'ü **değişmez**: DB'de bir şey değişmedi, o yüzden kullanıcı
tekrar denediğinde istek **doğru** durumla gider.

**6 yeni test** bunu kilitliyor (Processing kalıcıyı ezmiyor · başarı `dbStatus`'ü güncelliyor ·
hata `Error` sızdırmıyor · başarı sonrası hata `dbStatus`'ü koruyor · overlay temizliği).

---

## 7. Dialog'lar görsele göre yeniden yazıldı (istek 5) + buton renkleri (istek 6)

**Kullanıcı:** *"§ 8.2 ve § 8.3 başlıklarını oku, orada mesela ters fiş için ekran görüntüsü attım
o şekilde sorgu soruluyor, sen bunu yaptın mı? … § 8.4 İşlem Sonucu ve Hata Gösterimi başlığındaki
görseldeki gibi mi gösteriyorsun, onu da düzelt, güzel bir şekilde sonuç göster, sen image'ları
okuyabiliyorsun diye biliyorum, ekran tasarımına daha da benzet."* +
*"Bir de renklerde dökümandaki tasarım gibi olsun, mesela Generate ve Regenerate renkleri farklı
butonların ama bizde aynı, bunlara dikkat et."*

### 7.1 Ortak dialog kabuğu — `mrShowDialog`

image4 / image5 / image6 üçünün de **ortak dili** var: **lacivert başlık şeridi + beyaz kalın
başlık**, beyaz gövde, altta **dolu lacivert onay** + **çerçevesiz metin "Vazgeç"**.

`DevExpress.ui.dialog.confirm/custom/alert` bunu **veremiyor**: başlığı gövde tipografisiyle basıyor
ve **wrapper class vermiyor** — pencereler `body`'nin altına açıldığı için `.mr-container` altından
CSS ile de yakalanamıyorlar.

Bu yüzden `dxPopup` tabanlı **tek bir kabuk** yazıldı:
`wrapperAttr: { class: "mr-dialog" }` → CSS ile tam kontrol; `toolbarItems` gerçek `dxButton`
olduğu için buton renkleri/sırası görselle birebir. Üç pencere de buna geçirildi:

| Pencere | Görsel | Butonlar |
|---|---|---|
| Ters fiş valörü | image4 | `Kes` (dolu lacivert) · `Vazgeç` (metin) |
| Generate / Regenerate onayı | image5 / image6 | `Onayla` · `Vazgeç` |
| İşlem sonucu (karışık) | — | `Tamam` |

🔑 **Kritik detay korundu:** radyo seçimi **pencere kapanmadan** okunuyor (`value` bir fonksiyon
olabiliyor) — `hide()` sonrası DOM'da bulunamaz.

### 7.2 Buton renkleri (image3)

| Buton | Renk | Pasif hâli |
|---|---|---|
| **Generate** | dolu **lacivert** `#1F3864` | gri-mavi `#8CA0BC` (image3'te de böyle) |
| **Regenerate** | dolu **turuncu** `#C0521F` | soluk turuncu `#DDB9A6` |

Eskiden **ikisi de** `stylingMode: "outlined"` ve **aynı** renkti. Renkler CSS'te (inline değil) ki
`dx-state-hover` / `dx-state-disabled` de kapsanabilsin. Özgüllük
`.dx-button.mr-btn-x.dx-button-mode-contained` (0,3,0) DevExtreme temasını geçiyor → `!important`
gerekmedi.

### 7.3 image7 sonuç şeridi

- Ayraç `·` → **virgül** (görselde *"2 başarılı, 2 hata"*).
- Not metni **alt satıra** alındı ve görselin cümlesiyle hizalandı: *"Başarılı ve hatalı kayıtlar
  aynı ekranda gösterilir. Hata bilgisi saklanmaz."*
- image5'e uyum: Reeskont maddesi artık **`(T+0 — tarih)`** yazıyor (görselde `(T+0)` var).

### 7.4 Localization boşluğu kapandı

`mrText(...)` ile kullanılan **17 anahtar** JSON dosyalarında **hiç yoktu** → TR kullanıcı
`mr-rvt-Title`, `mr-btn-Approve`, `mr-done-*`, `mr-result-Bar*` gibi metinlerde **İngilizce
fallback** görüyordu. Hepsi `en` + `tr` dosyalarına eklendi (toplam 103 anahtar).

---

## 8. MM ↔ InterbankLoan sorguları (istek 7)

**Kullanıcı:** *"MM ve InterbankLoan aynı proje içinde ya, burada ki fişleri yönetirken ve
Get-Select sorguları düzgün değil mi? Yani farklı DB'lerde/tablolarda transaction'lar, buna dikkat
ederek… ben accounting'leri steplerinde strategy pattern ile ayırmıştım, bunlara uygun değil mi?"*

### 8.1 Strategy pattern'e uygunluk — ✅ uygun

| Katman | Nasıl ayrılıyor | Bizim kod |
|---|---|---|
| **Transaction okuma** | iki ayrı servis: `RevaluationAccountingService` (→ `TxnMmEntity`) / `LoanRevaluationAccountingService` (→ `TxnLoanEntity`) | `CreateRevaluationAsync` `sourceType`'a göre **doğru servisi** seçiyor |
| **Pipeline içi ürün ayrımı** | `IRevaluationAccountingPersister.IsApplicable(ProductSourceType)` | Dokunulmadı — motor **yazılmadı**, mevcut pipeline tetikleniyor (`ADR-MR-005`) |
| **Ters fiş** | dallanma **yok ve gerekmiyor** — `AccEntryMain.Id` üzerinden çalışıyor | Batch de aynısını yapıyor (`ReverseBatchItem.cs:76` / `:109`) |

🔑 Bu, **ev konvansiyonunun aynısı**: `RevaluationBatchItem.cs:92-95` (MM) ve `:128-131` (Loan) tam
olarak bu dallanmayı yapıyor. **Ekran ile EOD batch aynı kod yolunu paylaşıyor.**

### 8.2 🔴 Sorgularda bir **sessiz risk** bulundu ve düzeltildi

`AccountingDataManager.GetRevaluationByValueDateAsync` — Manuel Reeskont'un durum türetme sorgusu.
`AccEntryMain` **paylaşılan** tablo (MM + Tawarruq + InterbankLoan) ve `AccEntryMainConfiguration.cs:72-80`
**iki navigation'ı da aynı `TxnId` FK'sına** bağlıyor, **discriminator yok**.

**Eski hâli:**
```csharp
query.Where(x => x.TransactionLoan.ProductDefinition.MainProductCode == x.ProductCode)
```
`Transaction` / `TransactionLoan` / `ProductDefinition` **hepsi required** navigation → EF **INNER
JOIN** üretiyor. Transaction ya da ürün tanımı satırı **eksikse** join boşa düşüyor, fiş
**bulunamıyor** ve `DeriveStatus(null)` → `NotRediscounted` diyor. Sonucu: aynı gün için **İKİNCİ
bir reeskont fişi** kesilir — **mükerrer muhasebe kaydı, hiçbir hata mesajı olmadan**.

Bu, dün canlı veride yakaladığımız `B-1` bug'ının **aynı sınıfı** (`MEMORY.md` → *"EF Core:
`IsRequired()` navigation'ı projeksiyonda dereference etmek SATIRI SESSİZCE SİLER"*).

**Yeni hâli — EXISTS alt sorgusu (join üretmiyor):**
```csharp
query = sourceType == ProductSourceType.InterbankLoan
    ? query.Where(x => transactionLoanRepository.Queryable()
        .Any(t => t.Id == x.TxnId && t.ProductDefinition.MainProductCode == x.ProductCode))
    : query.Where(x => transactionRepository.Queryable()
        .Any(t => t.Id == x.TxnId && t.Product.MainProductCode == x.ProductCode));
```
`AccountingDataManager` ctor'una `IRepository<TxnMmEntity>` + `IRepository<TxnLoanEntity>` eklendi.

**Ayrım iki koşullu ve ikisi de gerekli:**
- (a) `TxnId` **doğru tabloda** var mı → ürün ailesini bu belirler
- (b) fişin `ProductCode`'u o transaction'ın ürün tanımıyla tutuyor mu → Id örtüşmesi hâlinde
  **tiebreaker**. ⚠️ Tek başına **yetmez**: `ProductCode` bir **ürün sınıflandırması**, tablo
  göstergesi değil — DB'de `'Loan'` kodlu fişlerin bir kısmı `TxnMM`'de duruyor (progress-29'da
  ölçüldü).

### 8.3 ⚠️ Aynı tuzak `TransactionDataManager`'da hâlâ DURUYOR (düzeltilmedi)

Okuma ucundaki durum türetme (`TransactionDataManager`, satır ~101-105):
```csharp
.Where(a => … && a.ProductCode == x.Product.MainProductCode)
```
`x.Product` de required navigation. Ürün tanımı eksikse `RediscountReverseId = null` olur ve satır
`NotRediscounted` görünür → aynı mükerrer fiş riski.

**Düzeltmedim** çünkü: (a) ürün tanımı **referans veri**, silinmiyor; müşteri gibi dış senkronla
gelmiyor — orphan olasılığı düşük, (b) canlıda ölçüldü, tüm satırlarda çözülüyor
(`BasisOk = 1`, sql-log #32), (c) `TransactionDataManager` + `TransactionLoanDataManager` + testlerine
yeni repository enjeksiyonu, zaten büyük olan bu turun sonunda kazandırdığından fazla risk taşıyor.
**Onay verirsen aynı EXISTS desenine geçiririm.**

---

## 9. "Verilen güne göre" + Faz 2 uyarısı (istek 8) — ✅ zaten doğru

**Kullanıcı:** *"Regenerate işleminde, seçilen günden bugüne kadar geçmiş tarihli yeniden değerleme —
bu konu Faz 2'de, biz Faz 1'i yapıyoruz şimdi. Yani verilen güne göre hareket edeceksin: Generate
butonunda verilen güne göre kesecek fişi, Regenerate'te ise verilen güne göre hareket edecek."*

**Kod bunu zaten yapıyor:**

| Katman | Kanıt |
|---|---|
| Ekran | `RegenerateToToday: false` **sabit** gönderiliyor (`component.js`) — alan ekranda **hiç açılmadı** (`D-7`) |
| Modül | `BuildCatchUpDates(executionDate, regenerateToToday: false)` → **`[executionDate]`**, tek gün |
| Durum türetme | `GetRevaluationByValueDateAsync(txnId, **executionDate**, …)` → `x.ValueDate == valueDate` |
| Guard | `RegenerateToToday` + `Generate` kombinasyonu **açık redle** engelli (`INVALID_OPERATION`) |

Yani **Generate de Regenerate de yalnız filtredeki `Date` gününe** göre çalışıyor. Backend'deki
`RegenerateToToday` altyapısı (31 gün sınırı + testleri) **duruyor** ama **ölü kod** — Faz 2'de
ekranda bir switch açılınca devreye girer.

---

## 10. Durum "en son fişe göre" (istek 10, 1. yarı) — ✅ doğru

**Kullanıcı:** *"Bir transaction'ın durumu, ilgili işleme ait en son (güncel) reeskont ve ters fiş
hareketleri dikkate alınarak belirlenir — bu şekilde bir cümle var, biz buna dikkat ediyoruz değil
mi? Yani sondan sıralayarak bakıyoruz."*

**İki yerde de en son fiş alınıyor:**

| Sorgu | Sıralama |
|---|---|
| Okuma ucu (`TransactionDataManager`) | `.OrderByDescending(a => a.Id).Select(a => (int?)a.ReverseId).FirstOrDefault()` |
| Yazma ucu (`AccountingDataManager`) | `.OrderByDescending(x => x.Id).FirstOrDefaultAsync()` |

Türetme (`M-08`): `null` → fiş yok (`NotRediscounted`) · `0` → ters alınmamış (`NotReversed`) ·
`> 0` → ters alınmış (`Rediscounted`). ⚠️ `ReverseId` **NOT NULL**, yokluk `0` ile ifade ediliyor —
`IS NULL` çalışmaz.

---

## 11. Ters fiş T+1 / T+0 (istek 4) — ✅ zaten yapılmıştı, doğrulandı

Doküman § 4.2 dört şey söylüyor; dördü de karşılanıyor:

| Doküman | Kod |
|---|---|
| *"T+1 (Varsayılan): Execution Date + 1 **iş günü**"* | `ICalendarHelper.NextWorkingDayAsync` — düz `AddDays(1)` **değil** |
| *"T+0: Execution Date valörü ile aynı gün"* | `ReverseValueType.T0` → `executionDate` |
| *"Varsayılan seçim T+1"* | popup'ta T+1 radyosu `checked` · istek varsayılanı `T1` |
| *"Toplu çalıştırmada seçilen valör, işaretlenen **tüm** transaction'lara aynı şekilde uygulanır"* | `reverseValueType` **istek gövdesinde tek alan** — satır bazlı değil |
| *"başarıyla tamamlanması halinde kayıt **Rediscounted** durumuna geçer"* | `GenerateAsync`: `NotReversed` → `Success(Rediscounted)` |
| *"**Diğer durumlarda seçim sorulmaz**"* (§ 8.2) | popup yalnız Generate + seçimde `Not Reversed` satır varsa |

🔑 **Yeni kural bunu daha da temizledi:** Generate artık **tek statü** istediği için valör sorusu
her zaman **homojen** bir `Not Reversed` seçimine uygulanıyor.

---

## 12. 🟥 Dokümanın kendi içinde çelişkisi — bildiriyorum

**image1 (§ 3.6) notları** diyor: *"A failed operation returns the row to its **previous status**;
the error is shown as a brief notification (**no status, no column**)."*

**§ 8.4 gövdesi + image7** ise tam tersini gösteriyor: *"başarılı işlemlerle birlikte hata alanlar
da aynı ekranda (**Error olarak, nedeniyle**) görüntülenir"* ve image7'de `Status` kolonunda
**kırmızı `Error` rozeti** + `Status Description`'da sebep var.

**§ 8.4 + image7 esas alındı** (hata gösterimine ayrılmış bölüm + eşleşen görsel). Kullanıcı da
2026-08-18'de bunu istedi (*"bunların statüsü değişmedi, değişmesi gerekmiyor muydu"*).
**İş birimine sorulması gereken bir madde.**

---

## 13. Test durumu

| Suite | Sonuç |
|---|---|
| `NetTrex.MM.Api.Services.Tests` | **190 / 0** ✅ (`MaxItems` testi 11→51 satıra güncellendi) |
| `NetTrex.Web.UI` jest (5 suite) | **344 / 344** ✅ (10 yeni test) |
| `NetTrex.MM.Data` build | **0 error** |
| `Trex.WebUI` build | **0 error** |
| `node --check` (8 JS dosyası) | ✅ |
| localization JSON (en/tr) | ✅ geçerli, 103 anahtar |

⚠️ **`dotnet test` VSTest ile çalışmıyor** (`xunit.v3` → Microsoft Testing Platform).
Doğru komut:
```bash
cd Code/UnitTest/Api/NetTrex.MM.Api.Services.Tests/bin/Debug/net10.0
./NetTrex.MM.Api.Services.Tests.exe
```
jest için (`JS_ROOT` **Windows biçiminde** olmalı):
```bash
cd Code/UnitTest/Trex.WebUI.Tests/JSTests
JS_ROOT="C:\\Users\\Treasy-70\\source\\repos\\NetTrex.Web.UI\\Code" npx jest --coverage=false
```

🔴 **3 BAYAT TEST bulundu ve düzeltildi:** Türkçe metin bekliyorlardı, kod İngilizce fallback
üretiyor (`D-3`). Yani **yeşil sanılan** üç test aslında kırmızıydı ve bu tur ortaya çıktı.

---

## 14. Sırada ne var

| # | İş | Kimde |
|---|---|---|
| 1 | 🔴 **MM API + WebUI yeniden başlat** — `AccountingDataManager` ctor değişti, `Startup.cs` değişti | **kullanıcı** |
| 2 | Tarayıcı testi → `08-test-rehberi.md` § 11 | kullanıcı |
| 3 | **Regenerate'in ters fiş kesmesi** — doküman (a) diyor, kullanıcının ikinci cümlesi (b) olabilir | **kullanıcı onayı** |
| 4 | `TransactionDataManager`'daki kalan required-navigation tuzağı | onay bekliyor |
| 5 | image1 ↔ § 8.4 çelişkisi (`Error` gösterilecek mi) | iş birimi |
| 6 | Batch'in hafta sonu valörlü ters fişleri (%43) | onay bekliyor |
