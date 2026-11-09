# PANO — Manuel Reeskont Base Component

> 📘 **Yeni modüle Manuel Reeskont yazılacaksa (FI / InvFund):**
> tek talimat dosyası [`12-modul-yayilim-rehberi.md`](12-modul-yayilim-rehberi.md). Bu pano
> MM + WebUI'nin **ilk** geliştirme sürecinin panosudur.
>
> 🆕 **2026-09-30 ([progress-66](progress/progress-66.md)):** StateMaker damgası geri alındı → sonraki faz (motor değişikliği gerekir) ·
> MM `InterbankLoan:Enabled=false` → IL ürün listesine gelmez, okuma/yazma uçları `PRODUCT_DISABLED` döner, MM etkilenmez ·
> FX motor ters fiş üretmezse satır artık başarısız · `AccruedInterest` değerleme yoksa yine `null`.
>
> **Modül durumu (2026-09-21):** MM (+InterbankLoan) ✅ prod · DerivSwp 🧪 test ·
> OptFX 🧪 test · **FX 🟢 kod hazır, build+test yeşil, uçtan uca test bekliyor**
> ([progress-51](progress/progress-51.md)) · FI / InvFund ⬜
>
> 🆕 **Son turlar — PO ekran iyileştirmeleri** ([progress-53](progress/progress-53.md) · [54](progress/progress-54.md) · [55](progress/progress-55.md) · [56](progress/progress-56.md) · [57](progress/progress-57.md)):
> alt ürün kutusu `DropDownBox` · kolonlar sola yaslı + dar · satır bazlı **Muhasebe** düğmesi ·
> **sunucu tarafı `LogicalReference` filtresi** · blotter alan eşitliği (`StartDate` → **`ValueDate`**) ·
> Generate sonrası değerleme kolonları artık doluyor (`refreshKeepingOverlay`).
> Satır içi **Acc.** kolonu + `Module Accounting` sekmesi için **yeni `SelectAcc` ucu** (ürüne göre 5 modüle dağıtım) ·
> alt üründe **Select All** · statü rozeti sabit 128px.
> 🔴 **InterbankLoan artık kendi blotter kolonlarını kullanıyor** (`LOAN_REVALUATION`, 46 kolon) — MM'inkiler DEĞİL ·
> kolon genişlikleri `minWidth`'e geri alındı · statü kolonu Execute sırasında genişliyor.
> 🔴 Referans filtresi **çift yollu**: alt ürün seçili değilse SUNUCU (tek satır), seçiliyse TARAYICI (sıfır istek) ·
> alt ürün kutusu ürün değişince `repaint()` ile tazeleniyor.
> 🆕 **5. tur (progress-57):** SubProduct popup'ı zoom'dan bağımsız sabit genişlik (`DropDownOptions.Width(300)`) ·
> Yenile+Export dışarıdan kaldırılıp grid'in kendi toolbar'ına toplandı (tek ikon artık `hardRefresh`) ·
> **Txn Id** kolonu Column Chooser'a eklendi, varsayılan **kapalı**.
> 🔴 `stateStoring` anahtarı `-v3` oldu.
> 🆕 **6. tur (progress-58):** SubProduct popup genişliği artık İÇERİĞE göre (150–300px, sabit 300 kaldırıldı) ·
> kolon başlıkları sürükle-bırakla ANLIK yer değiştirir ama KALICI değil (`stateStoring` → `type:"custom"`,
> `visibleIndex` kaydedilmeden atılıyor) · Status bilgi penceresi 760px + Generate/Regenerate metni sadeleşti ·
> 🔴 **SubProduct seçimi artık otomatik istek ATMIYOR** — Logical Reference'ın yanındaki büyüteç GENEL arama
> düğmesi oldu (`applyFilters`), Product+SubProduct+Referans o an doluysa hepsini tek istekte uyguluyor.
> Cross-repo kontrolü: bu turun MM değişiklikleri FX/DerivSwp/OptFX'e taşınacak bir şey içermiyor (doğrulandı).
> 🆕 **7. tur (progress-59):** Log. Ref. kutusundaki büyüteç kaldırılıp Form'un altına dört kutunun ORTAK
> **CLEAR + SEARCH** düğmeleri kondu (desen: MM Advance Search) ·
> 🔴 **MICRO UI TAŞIMASI BAŞLADI**: Manuel Reeskont `NetTrex.Web.UI` → **`Treasy.Common.UI`**,
> branch **`main-manuel-reeskont-development`**. Core+Business+Web katmanları, 4 Razor, **8 JS → 9 TS modülü**,
> `bridges/exposeNamespacedApi`, CSS/localization/config taşındı. Modül fan-out'u artık Controller içinde
> switch (`IClient*Api` türevleri → DI/BaseAddress otomatik); resolver/ModuleClient/QueryService katmanı düştü.
> 🔴 **Muhasebe (Acc.) kolonu hedefte DEVRE DIŞI** — `_AccountingDisplay` partial'ı Framework.WebUI'da, Common.UI'de yok.
> ⬜ tarayıcı testi yapılmadı · ⬜ Common.UI'de menü/permission kaydı gerekiyor.
> 🆕 **8. tur (progress-61, 2026-09-25) — PO sunum sonrası 8 madde, yalnız MM + Common.UI:** istek artık YALNIZ Search'te
> (Product değişimi temizler, SubProduct/Tarih hiçbir şey yapmaz) · Log. Ref. alt ürünle birlikte de SUNUCUDA ·
> Ext. Customer Id varsayılan kapalı (`stateStoring` `-v4`) · 🔴 Regenerate/Rediscounted nötrleme **önce ters fişin
> karşıtı, sonra reeskontun aynası** (Fimple'a iki ayrı revaluation fişi — UAT'ta doğrulanmalı) · seçim sınırı **30** ·
> popup'lar `treasy-popup` · Regenerate onayında **"en sonda ters fiş kesilsin"** kutusu (`CreateReverse`).
> ⬜ WebUI + DerivSwp + OptFX + Fx kullanıcı onayından sonra.
> ❓ PO'ya açık sorular: InterbankLoan `MaturityAmount` hangi toplam · FX `MessageKey` kolonu istiyor mu? ·
> PO'nun 5. turdaki 3. maddesi kesik geldi, tekrar bekleniyor.

> **Bu dosya işin ana panosudur.** "Şu an neredeyiz, sırada ne var, ne bloke" sorusunun **tek** cevabı burası.
> **Üzerine yazılır** — tarihsel iz [`progress/`](progress/_index.md)'te.
>
> **Son Güncelleme:** 2026-08-21 (**11. tur — ters fiş valörü artık GERÇEK (`ADR-MR-031`) · Voucher kolonu + akıllı seçim geri alındı · kolon başlıkları tam (`ADR-MR-032`) · yeni doküman: veri seçim kuralları**)
>
> Geçmiş turlar: 10. tur — grid TAMAMEN CLIENT-SIDE (`ADR-MR-028`) · özet şerit tarayicida ([progress-41](progress/progress-41.md)) · 9. tur — K-5 damgası · Fiş No kolonu · akıllı seçim · `stateStoring` ([progress-40](progress/progress-40.md)) · 7. tur — polling geri alındı · T+1 = +1 takvim günü ([progress-38..39](progress/_index.md)). **Bu turun kaydı:** [progress-42](progress/progress-42.md) · tarayici testleri: [08-test-rehberi § 20](08-test-rehberi.md)
>
> **Genel durum:** 🟡 **Kod hazır ve testli · MM API + WebUI restart + tarayıcı testi bekliyor**
>
> | Ne | Durum |
> |---|---|
> | `06-sozlesme.md` | 🔓 **güncellendi 2026-08-21 (7. tur)** — `Filters` (kolon filtreleri) · `ValueDates` (valör önizlemesi) · **T+1 = +1 takvim günü** · ~~`ProgressKey`/`progress`~~ **geri alındı** |
> | Kod — `NetTrex.MM` + `NetTrex.Web.UI` | ✅ ikisi de build (0 error) |
> | Testler | MM **204/204** ✅ · JS **378/378** ✅ |
> | 🔴 **Sırada — kullanıcı** | **MM API + WebUI yeniden başlat** (handler ctor'ları değişti, `executions/progress` ucu **silindi**, yeni response alanı + yeni JS/CSS/lokalizasyon) → sonra [`08-test-rehberi.md`](08-test-rehberi.md) ve [`progress/progress-38.md`](progress/progress-38.md) § 5 |
> | 🔴 **Tarayıcıda özellikle bakılacak** | **(1)** Ters fiş valörü: Execution Date **Cuma** seçilince kolon **Cumartesi** göstermeli ve `AccEntryMain` ters fişinin `ValueDate`'i birebir aynı olmalı · **(2)** External Customer Id filtresi — sunucuda `CONVERT(nvarchar) LIKE` üretiyor (`long?` kolon), EF çevirisi patlarsa grid hata verir |
> | 🟠 **MM'e bildirilecek bulgu** | `ReverseBatchItem.Start` guard'ı yalnız `WeekdaysOnly`'yi kontrol ediyor → `HolidaysButNotWeekends` (2) kurulmuş müşteride batch **hafta sonu da koşuyor**. Ekran batch'in fiilî davranışını taklit ediyor; batch düzeltilirse `ResolveNextDayAsync` de düzeltilmeli |
> | 🔴 **Ortam kaynaklı 3 açık kalem** (bu ekranın kodu değil) | Redis timeout (`Netix.AccAccountingMapDefinition` ~5 MB hash) · Kafka `localhost:9094` erişilemiyor (dev ayarı) · **Accounting DB deploy skew**: `AccEntry` tablosunda `ConvertedCCYSource`/`CustomerAccountBranchCodeSource`/`ExtendedText1..5` kolonları **yok** → `select-detail` 500 |
> | Beklemede | Faz 4 MicroUI (*"ben deyince"*) · Fx/FI/InvFund uçları (modül sahipleri — 🔴 artık `Filters` alanını da uygulamaları gerek) · Faz 5 önizleme |
>
> Ayrıntı → [`progress/progress-37.md`](progress/progress-37.md)

---

> 🔴 **2026-08-21 (7. tur) — İKİ KURAL DEĞİŞTİ:**
> **(1) Polling geri alındı.** İlerleme ucu (`executions/progress`), `ProgressKey`, tracker ve JS poll
> döngüsü **tamamen silindi** (`ADR-MR-020` geri alındı). Ekran Execute sırasında yalnız kapsamı
> yazıyor. Kullanıcı: *"Faz 1 için gerekli değilmiş, daha sonra daha güzel bir yapı kurulacak."*
> **(2) T+1 = ExecutionDate + 1 TAKVİM GÜNÜ** (`ADR-MR-027`). Takvim servisi ve `MMSystemWDFlag`
> **okunmuyor**; `ADR-MR-021` değişti. Hesabın tek evi `ManualRediscountValueDateResolver`.
> Detay → [`progress/progress-38.md`](progress/progress-38.md)

## 🔴 2026-08-21 (6. tur) — Filtre · ilerleme · T+1'in gerçek kaynağı

| İstek (kullanıcı) | Sonuç |
|---|---|
| *"process deyip hangi transaction'da olduğunu gösterebiliyor musun?"* | ✅ Yeni **salt-okunur uç** `GET api/manual-rediscount/executions/progress` + `ProgressKey`. Ekran 1.5 sn'de bir poll ediyor → **`3/8 · TMMBRW…`** + satır hücresinde *"şu an işleniyor"*. Execute **tek istek** kaldı (2026-08-19 kararı bozulmadı). İlerleme process-içi bellekte; bulunamazsa **genel mesaja düşer, hata basmaz** (`ADR-MR-020`) |
| *"batch'te ters fiş T+1 için next working day mi, direkt 1 gün sonra mı? systemWDFlag'e göre galiba, sen bak"* | 🔴 **Ölçüldü — kullanıcı haklıydı.** Batch T+1'i *hesaplamıyor*: ters fişi **kendi koşu gününün** `ExecDate`'iyle kesiyor (`ReverseBatchItem`), koşu günlerini `MMSystemWDFlag` belirliyor. Ekran artık aynı ayrımı yapıyor: `WeekdaysOnly` → +1 **iş günü** · `EveryDay`/`HolidaysButNotWeekends` → +1 **takvim günü** · parametre okunamazsa iş günü. Emsal: `AccountingExecutorBase.GetWorkingDates` (`ADR-MR-021`, 4 test) |
| *"kolonların filtreleri neden yok, arama da olsun"* | ✅ **SUNUCU TARAFI** filtre (kullanıcı seçimi): sözleşmeye `Filters` eklendi, iki data manager'da **sayımlardan önce** uygulanıyor → özet şeridi + `TotalCount` filtreyle tutarlı. Filtrelenebilen: **referans · müşteri no · müşteri adı** + arama kutusu. Diğer kolonlarda kutu **hiç açılmıyor** (türetilmiş/sabit alanlar) (`ADR-MR-019`) |
| *"status pill'ine her tıklamada backend'e istek gidiyor, maliyetli değil mi? UI'da filtrelese?"* | ✅ **Sunucu tarafı doğru yer** (bayat durumla fiş kesmek çift tahakkuk riski; UI'da süzmek için paging'i kapatmak gerekir, `Take` tavanı 200). Ama maliyet düşürüldü: durum filtresi varken **3 gereksiz `COUNT` kalktı** → pill tıklaması başına **4 sorgu yerine 1**, sonuç birebir aynı (`ADR-MR-024`) |
| *"transaction olmasa bile data grid uzasın"* | ✅ `calc(100vh - 340px)` + `min-height: 380px` (emsal: `money-market.css`) |
| *"Export butonu tabloyu bir satır aşağı itmiş"* | ✅ Grid'in kendi export toolbar'ı **kapatıldı**, buton **sağ üst köşeye** alındı (emsal: `.mm-import-wrapper`). Dosya içeriği aynı — export grid API'siyle yapılıyor. ⚠️ Export **görünen sayfayı** yazar (`ADR-MR-022`) |
| *"Generate/Regenerate köşesine info ikonu"* | ✅ Buton köşesinde **i** ikonu → durum bazlı açıklama penceresi; **pasif butonda da** çalışıyor ("neden pasif"in cevabı da orada). Metinler `ExecutionsHandler` dallanmasından birebir (`ADR-MR-023`) |

⚠️ **Bu turda `02-mimari-karar.md` yanlışlıkla sıfırlandı** (Python `open(p,'w')` truncate + encode hatası)
ve Claude Code transkriptinden **tam** geri getirildi; satır numaraları birebir eşleşti. Ders `MEMORY.md`'de.

---

## 🔴 2026-08-20 (5. tur) — Regenerate valörleri SABİT (analist kararı)

**Kullanıcı iş analistiyle konuştu.** Regenerate'te ters fiş valörü **artık sorulmuyor**.

| Satırın durumu | Ne oluyor | Valörler |
|---|---|---|
| `Not Rediscounted` | ② yeni reeskont → ③ yeni ters fiş | ② **T+0** · ③ **T+1** |
| `Not Reversed` | ① nötrle → ② yeni reeskont → ③ yeni ters fiş | ① **T+0** · ② **T+0** · ③ **T+1** |
| `Rediscounted` | ② yeni reeskont → ③ yeni ters fiş | ② **T+0** · ③ **T+1** |

**Generate değişmedi** — `Not Reversed` satırlar için valör hâlâ **soruluyor** (§ 4.2 / § 8.2).

### 🟢 `D-12` KAPANDI — bu bir sapma değil, DÖNÜŞ

Doküman § 4.3 (*"ters fiş kaydı **T+1 valörü ile** yeniden oluşturulur"*) ve § 8.2
(*"Diğer durumlarda seçim sorulmaz"*) **zaten böyle diyordu**. Sabah eklediğim soru sapmaydı.

⚠️ Dokümanın **tanımlamadığı** tek nokta ①'in (nötrleme kaydının) valörüydü → analist **T+0**
dedi. Gerekçe: aynı gün açılan reeskont aynı gün kapanmalı; T+1 olsaydı o günün defterinde
**hem eski hem yeni** reeskont açık görünür ve **çift tahakkuk** okunurdu.

### Kod + test

| Katman | Değişiklik |
|---|---|
| `ExecutionsHandler` | Döngü: Regenerate → her zaman `NextWorkingDay(date)`. `RegenerateAsync`: nötrleme `executionDate` (T+0) |
| Sözleşme | `ReverseValueType` **duruyor**; Regenerate'te **yok sayılıyor** (Generate için gerekli) |
| UI | Regenerate popup'ı **kaldırıldı**; onay penceresinde `T+1 (sabit)` |
| Test | 🔴 **3 yeni** (190 → **193**): ①/③ valör ayrımı + Generate'in etkilenmediği |

⚠️ `dotnet build NetTrex.MM.Api` **24 error** verdi — **kod değil**, dll kilitli (`MSB3021`),
MM API çalışıyor. `NetTrex.MM.Api.Services` tek başına **0 error**.


---

## 🟢 2026-08-20 (4. tur) — Fimple hatası ÇÖZÜLDÜ (konfigürasyon)

Kullanıcı Seq log'larını attı. `RefitExtension` düzeltmesi işini yaptı — hata artık gizlenmiyor:

```
Fimple Error => Code: 3058, Message: Hesap tanımında defter türündeki muhasebe hesapları için
referans türü ve referans no alanları boş olmalıdır. Defter hesabı: (36099200)
```

| Ne | Sonuç |
|---|---|
| **Kök sebep** | `36099200` Fimple'da **defter (ledger) hesabı** → referans alanları boş olmalı. `AccAccountMap 23298` (`RuleId 33340`) defter hesabı için de `CustomerAccountCode` (`346178`) üretiyor → `FimpleAccountingDetailModelMapper.cs:46` referansı dolduruyor → red |
| 🔴 **Manuel mi batch mi?** | **FARK YOK.** Mapper ve `FimpleAccountingService` paylaşılan; EOD batch de `15_RevaluationAccountingSyncStep`'ten aynı yere geliyor. Aynı transaction batch'te de **aynı 3058**'i alır |
| **Sınıfı** | 🔴 **KONFİGÜRASYON**, Manuel Reeskont bug'ı değil. PANO'da **zaten açık** olan kalem (`AccAccountMap` `36099200`/`36199200`) — log **teyit** etti |
| **Kod** | ⚠️ **DEĞİŞTİRİLMEDİ.** `CustomerAccountCode` null olunca mapper kendiliğinden `ReferenceType: null` gönderiyor → düzeltme konfigürasyonda. Detay → [`outputs/2026-08-20-fimple-3058-defter-hesabi.md`](../outputs/2026-08-20-fimple-3058-defter-hesabi.md) |
| **Yan bulgu** | `FxRate: 0.0` — ayrı açık kalem, yabancı parada kontrol edilmeli |

### Ekran düzeltmeleri (aynı tur)

| İstek | Sonuç |
|---|---|
| *"dark mode'da popup okunmuyor, dark'a özel bir şey yapmadan çöz"* | ✅ Dialog **kendi renklerini taşıyor** — `@media` / `.dx-theme-dark` **yok**. İki modda da dokümandaki tasarım |
| *"T+0 üstte olsun"* | ✅ sıra değişti, **varsayılan hâlâ T+1** (§ 4.2) |
| *"hangi transaction hangi hatayı aldı, statüsüyle"* | ✅ sonuç penceresinde **satır başına durum rozeti** (`item.NewStatus`) |
| *"1 rows processed yazısı kötü"* | ✅ **sayı rozeti + tek kelime** başlık (yeşil `1 Succeeded` / kırmızı `1 Failed`) — tekil/çoğul sorunu yapı değişikliğiyle çözüldü |
| Regenerate valörü kimin için geçerli? | 🟢 **Her satır için** — `RegenerateAsync`'in **üç dalı da** yeni bir ters fiş kesiyor (§ 4.3 ile aynı). ⚠️ `Not Reversed` dalında eski fişi **nötrleyen** ters fiş de aynı valörle kesiliyor; doküman bunu tanımlamıyor → **iş birimine sorulmalı** |


---

## 🔴 2026-08-20 (3. tur) — Doküman yeniden okundu

| # | İstek | Sonuç |
|---|---|---|
| 1 | *"onay popup'ını yaptın mı?"* | ✅ **Evet** — `mrBuildRegenerateConfirmBody` görselin satır satır karşılığı (lead + durum kırılımı + rozet + kural metni + Onayla/Vazgeç). Ek olarak fiş/ters fiş valörü de yazıyor |
| 2 | *"step'ler aynıyken bu hatayı nasıl alıyoruz?"* | 🟢 **Haklısın, kod aynı** — manuel ve batch ikisi de `RevaluationAccountingPipeline` → `15_RevaluationAccountingSyncStep`. Fark **kod dışında**. 3 aday sıralandı, **1. sırada auth** (`FimpleAuthService.cs:41` `Login` ucu da aynı wrapper'ı kullanıyor; 404 → `"Not Found"` → `N` → NaN). Seq'ten çekilecekler listelendi |
| 3 | *"statü mantığı düzgün çalışmıyor sanıyorum, dokümanı tekrar oku"* | 🟢 `.docx` düz metne çıkarıldı, § 3 birebir okundu → **mantık DOĞRU**. 18.08'de `Rediscounted` olan satırın 20.08'de kaybolması **statü değil uygunluk filtresi** (vade / faiz dönemi) — EOD sorgusuyla birebir aynı |
| 4 | *"dokümanda Execution Date yazıyor, sen Date yapmışsın"* | ✅ EN/TR ikisinde de **`Execution Date`** |
| 5 | *"Generate ve Regenerate ikisinde de ters fiş popup'ı çıkmalı"* (doküman yazarına soruldu) | ✅ Kural: **ters fiş kesilecekse sorulur**. Regenerate → **her zaman**. Generate → `Not Reversed` seçiminde. ⚠️ `Not Rediscounted` Generate'inde ters fiş **kesilmiyor** (§ 4.1) — orada soru sorulmuyor; her koşulda istenirse tek satır |
| 6 | *"Regenerate'te foreach'te statülere ayrı ayrı bakıyorsun değil mi?"* | 🟢 **Evet** — `ExecuteItemAsync` her satır için DB'den `DeriveStatus` yapıp dallanıyor; hepsi `Rediscounted`'da bitiyor. Valör tek ve tüm satırlara aynı (§ 4.2) |
| 7 | *"dropdown'lar çok geniş"* · *"Status Description dinamik olsun"* | ✅ `ColCount(4)` + `max-width: 320px` · `width: 320` → `minWidth: 260` |

### 🔵 Sıradaki tek engel

**Fimple hatasının HTTP durum kodu.** Log mesajı artık taşıyor. Seq çıktısı gelince ayrışacak.
⚠️ Paylaşım öncesi `client_secret` maskelenmeli.


---

## 🔴 2026-08-20 (2. tur) — İkinci tarayıcı testi

| # | Sorun | Sonuç |
|---|---|---|
| 1 | `Error parsing NaN value … position 1` + gridde *"Failed to parse…"* | ✅ `RefitExtension` HTTP hata gövdesini **koşulsuz JSON** sanıyordu; düz metin (`Not Found`) Newtonsoft'u `NaN` parse'ına sokuyordu ve **gerçek Fimple hatasını gizliyordu**. Artık mesajda **HTTP durumu + gövde** var → sebep bir sonraki denemede görünecek |
| 2 | *"kolonlar gelmiyor, gözükmüyor gitti"* | ✅ Sebep **`columnFixing`**: boş `.dx-datagrid-content-fixed` katmanı başlığı örtüyordu. Grid ayarlarının **6'sı** geri alındı |
| 3 | *"bir satırı koyu diğerini açık yapmışsın, beğenmedim"* | ✅ `rowAlternationEnabled` kaldırıldı |
| 4 | *"uyarı UI'yı bozup grid'i aşağı kaydırıyor"* | ✅ İpucu özet şeridinin **içine** alındı (tek satır, sağa yaslı) → grid **kaymıyor** |
| 5 | *"Regenerate'te ters fişi hangi tarihe keseceğimi sorması gerekmiyor muydu?"* | ✅ **`D-12`** — soruluyor artık. Doküman harfi harfine sorulmadığını söylüyordu (§ 8.2 + § 4.3) ama kullanıcının mantığı tutarlı. **Backend'de değişiklik gerekmedi** |

### 🔑 Ders

**Grid'e aynı turda birden çok davranış ayarı eklenmez.** 6 ayar birlikte gitti, biri ekranı
bozdu, hepsini geri almak gerekti. Kullanıcının asıl istediği (hizalama + rozet) grid option
değil kolon tanımı/CSS olduğu için **korundu**.


---

## 🔴 2026-08-20 — İlk tarayıcı testi

| # | İstek | Sonuç |
|---|---|---|
| 1 | *"neden bu `JsonReaderException` hatasını aldım ve çok aldım debug ederken"* | ✅ Sebep: Fimple **token** isteği `application/x-www-form-urlencoded` (`client_id=…` → ilk karakter **`c`**), `JsonDocument.Parse` reddediyordu. Exception **zaten yakalanıyordu** (first-chance gürültüsü). `LooksLikeJson` guard'ı eklendi — **çıktı değişmiyor** |
| 2 | *"Generate ve Regenerate neden Status butonlarının hizasında değil"* | ✅ Toolbar `.mr-status-bar` içine alındı (`margin-left:auto`), `.mr-toolbar-row` silindi |
| 3 | *"kolon içlerindeki yazı ortalansın ve tiplerine bak"* | ✅ Tip→hizalama kuralı + 4 yeni test. 🔴 `Status` `int` olduğu için DevExtreme başlığı **sağa** yaslıyordu |
| 4 | *"status rozetleri hücresini full kaplamış"* | ✅ `width:160px` → içeriğe göre (`min-width` + padding + nowrap) |
| 5 | *"normal ekranlara bak, daha güzel gözüksün"* | ✅ `rowAlternation` · `wordWrap:false` · `columnMinWidth` · `columnFixing` · dikey ortalama · tabular rakam |
| 6 | *"ReverseType atomic — bu durumların önemi yok, ekranda gözükmesin"* | ✅ **`D-11`**: 6 katman + 2 localization + 5 test kalktı. Yerine seçim özetinde **durum kırılımı** |

### 🟥 Dokunulmayan güvenlik bulgusu

`ExternalHttpLoggingDelegateHandler` token isteğinin gövdesini ham logladığı için
**`client_secret` düz metin olarak log'a yazılıyor**. Bugüne kadar da böyleydi; guard bunu
değiştirmedi. Handler MM'deki **tüm** Fimple çağrılarının log'unu ürettiği için maskeleme
2026-08-19 kuralı gereği (*"paylaşılan dosyaya davranış değiştiren dokunuş yok"*) **kullanıcı
onayına** bırakıldı — yama hazır.


---

## 🔴 2026-08-19 — Kullanıcının 10 maddesi

| # | İstek | Sonuç |
|---|---|---|
| 1 | `Selection` menüsü kaldırılsın (pagination yeterli) | ✅ silindi — WebUI'de; **MM'de karşılığı yoktu**. Dokümandan bilinçli fark `D-9` |
| 2 | **Generate** aynı statü istesin, farklı statü seçilince **disabled** + küçük yazı | ✅ `mrIsSingleStatus`; ipucu image3 gibi iki satır. 🟨 **Dokümandan SAPMA `D-10`** — § 5.3 karışık durumu destekliyor, kullanıcı kararı üstün |
| 3 | **Regenerate**'te statü kısıtı olmasın, her satır kendi durumuna göre | ✅ zaten öyle — kapı **yalnız** Generate'e uygulanıyor |
| 4 | Regenerate **`Rediscounted`**'da bitsin | ✅ zaten öyle — **image1 diyagramı** *"re-values (T+0 + T+1 reverse) and returns to Rediscounted"* diyor. **Kod değişmedi** (bkz. onay bekleyen karar) |
| 5 | **TEK istek** gitsin, döngü backend'te dönsün | ✅ `#executeChunked` → `#executeAll`. 🔴 Timeout: Refit client'ı **10 dk**, `MaxItems` 10→**50**. ⚠️ **2026-08-19 revizyon:** ayar ilk yazılışında paylasılan `RefitExtensions.cs`'e girmişti — kullanıcı itiraz etti (*"benim yapımdaki timeout durumlarını ellemişsin"*), **geri alındı** ve `ManualRediscountRefitRegistration.cs`'e taşındı (blast radius = **1 arayüz**) |
| 6 | Ters fiş yalnız **T+0 / T+1**, sorulsun | ✅ zaten yapılmıştı (2026-08-18); § 4.2'nin 6 maddesi tek tek doğrulandı |
| 7 | § 8.2 / § 8.3 / § 8.4 **görsele daha çok benzesin** | ✅ üç pencere `dxPopup` tabanlı **tek kabuğa** (`mrShowDialog`) alındı: lacivert başlık şeridi + dolu lacivert onay + metin Vazgeç |
| 8 | Generate/Regenerate **renkleri farklı** olsun | ✅ Generate **lacivert** `#1F3864` · Regenerate **turuncu** `#C0521F` (image3); pasif hâlleri de görselden |
| 9 | MM/IL sorguları + Strategy pattern uyumlu mu | 🟢 uygun · 🔴 **1 sessiz risk düzeltildi** (aşağıda) |
| 10 | `Processing` anlık gösterilsin · durum en son fişe göre · tekrar istekte **backend'in son durumu** esas | ✅ `Processing` **eklendi** (`D-6` kapandı) · sıralama zaten doğruydu · 🔴 **UI tutarsızlığı bulundu ve düzeltildi** (aşağıda) |

### 🔴 Bu turda bulunan iki gerçek sorun

| # | Sorun | Sonuç |
|---|---|---|
| **B-3** | `AccountingDataManager.GetRevaluationByValueDateAsync` MM/IL ayrımını **required navigation** üzerinden yapıyordu (`x.TransactionLoan.ProductDefinition.MainProductCode`). EF **INNER JOIN** üretiyor; transaction ya da ürün tanımı eksikse fiş **bulunamıyor** → `DeriveStatus(null)` → `NotRediscounted` → aynı güne **İKİNCİ reeskont fişi** kesilir. `B-1`'in aynı sınıfı, ama sonucu **mükerrer muhasebe kaydı** | ✅ **EXISTS alt sorgusuna** çevrildi (join üretmez); ctor'a 2 repository eklendi |
| **B-4** | § 8.4 gereği Execute sonrası `refresh()` çağırmıyoruz → `row.Status` **bayat** kalıyor. Kullanıcı o turda **başarılı** olmuş satırı tekrar seçip Execute'a basınca bayat `CurrentStatus` gidiyor → modül § 4.5 gereği `STATUS_CHANGED` ile reddediyor → **sebepsiz hata** | ✅ overlay ikiye ayrıldı: `status` (görünen) + **`dbStatus`** (kalıcı). İstek gövdesi ve tüm kural kapıları `mrEffectiveStatus`'ü kullanıyor; `Error`/`Processing` **asla** gönderilmiyor |

### ⚠️ Kapatılmayan, bilinçli bırakılanlar

- `TransactionDataManager`'daki **aynı required-navigation tuzağı** (`x.Product.MainProductCode`) —
  ürün tanımı referans veri olduğu için orphan olasılığı düşük; canlıda ölçüldü, çözülüyor. **Onay bekliyor.**
- 🟥 **Doküman kendi içinde çelişiyor:** image1 notları *"hata satırı önceki durumuna döner, kısa bir
  bildirim gösterilir (**durum yok, kolon yok**)"* diyor; § 8.4 + image7 ise **`Error` rozeti + sebep**
  gösteriyor. **§ 8.4 + image7 esas alındı** (kullanıcı isteği de bu yönde). İş birimine sorulmalı.
- Tek isteğe dönüldüğü için **kısmi sonuç garantisi kayboldu**: timeout/ağ hatasında backend fiş kesmiş
  olsa bile ekran `succeeded[]`/`failed[]` göremiyor (hata metni *"listeyi yenileyin"* diyor).

---

## 2026-08-18 — Önceki tur (doküman hizalama + 2 sessiz bug)

### Kaynak doküman ilk kez HAM okundu
`Manuel Reeskont v1.docx` → `word/document.xml` parse edildi (**318 satır** metin + tablo hücreleri)
ve **7 görselin tamamı** (`image1…image7`) tek tek incelendi.
🔑 **Ders:** iki sapma **yalnız görsellerde** ve § 8 gövdesinde görünüyordu; türev özetim (`01-dokuman-analizi.md`)
üzerinden çalışırken ikisi de gözden kaçmıştı.

### Dokümana hizalanan 4 madde

| # | Doküman | Eski hâli | Yeni hâli |
|---|---|---|---|
| **F-1** | § 3.4 · § 5.2 · § 8.4 + image7 — sonuç **Status/Status Description** kolonlarında | Sonuç yalnız dialog'da; `finally` hemen `refresh()` çağırıp **sonucu anında siliyordu** | Hata alan satır **anlık `Error`** + sebep `Status Description`'da · başarılı satır yeni durumu · grid üstünde **image7 şeridi** · `refresh()` **kaldırıldı** |
| **F-2** | § 4.2 · § 6.4.3 · § 8.2 + image4 — valör **T+1/T+0 enum**, yalnız `Not Reversed`'da sorulur | Filtre çubuğunda **serbest tarih kutusu** + `Min = ExecutionDate+1` (**T+0'ı tamamen engelliyordu**) | Kutu **kaldırıldı** · image4 popup'ı · istek `ReverseValueType` taşıyor · tarihi **modül** hesaplıyor |
| **F-3** | image7 — sonuç metni işi anlatır | Tek "başarılı" metni | Aksiyona göre metin (Generate 1 fiş / Regenerate **3 fiş** keser) |
| **F-4** | § 4.6 — karışık **Revaluation Type** → Generate pasif | ✅ vardı | 🔴 **Sonradan UI'dan bilerek KALDIRILDI** — kural artık yok (2026-09-30 review'da doğrulandı) |

🔴 **F-2'de iki katlı kendi hatam:** `Min` kısıtını progress-25'te **ben ekledim** ve T+0/T+1
etiketlerini *"yalan söylüyor"* diyerek sildim; gerekçem "kullanıcı serbest tarih seçebiliyor" idi.
Doküman serbest tarihe **hiç izin vermiyor** — etiketler doğruydu, serbest kutu yanlıştı.
Yanında **gerçek bir bug** çıktı: `AddDays(1)` → **Cuma + 1 = Cumartesi**. Artık
`ICalendarHelper.NextWorkingDayAsync`. Validator `>` → **`>=`** (T+0 artık geçerli).

### 🔴 Uçtan uca testte bulunan 2 SESSİZ bug

| # | Bug | Kanıt | Durum |
|---|---|---|---|
| **B-1** | **Grid'de satır sessizce kayboluyordu** — required navigation (`Customer`, `Direction`) `.Select()` içinde dereference edilince EF **INNER JOIN** üretiyor, orphan FK'da satır düşüyor; `CountAsync` o join'i yapmadığı için **saymaya devam ediyor** | API: `totalCount = 1`, `items = 0` (**aynı** sorgu) · `TxnMM 553292` → `CustomerId = 1086`, `cusCustomer`'da **YOK** (sql-log #32) | ✅ **Düzeltildi** — alanlar **skaler subquery** ile okunuyor (MM + IL) · ⏳ **restart bekliyor** |
| **B-2** | Execute sonucu **grid'e yazılmıyordu** — `calculateCellValue` DevExtreme'de veri yüklenirken **bir kez** hesaplanıp önbelleğe alınıyor, `repaint()` onu yenilemiyor | Kullanıcı ekran görüntüsü: şerit *"2 failed"* diyor, satır hâlâ `Not Rediscounted` | ✅ **Düzeltildi** — `cellTemplate`'e geçildi (her boyamada çalışır) |

**B-1'in kullanıcıya etkisi:** `Not Reversed` satıra **hiç ulaşılamıyordu** → ters fiş valörü popup'ı
tetiklenemiyor, o işleme fiş kesilemiyordu. **Hata mesajı da yoktu.**

### Diğer düzeltmeler
- Onay penceresi `dialog.confirm` (**Yes/No**) → `dialog.custom` (**Onayla/Vazgeç**, image5/image6)
- Hata metinleri **hangi işlem** olduğunu söylüyor (`Generate — …` / `Regenerate — …`)
- Loader **her parçada yeniden assert ediliyor** (kullanıcı: *"birincisinde hata aldı, loading kapandı ama arkada devam ediyordu"* — kapatanı kesin bulamadım, tahmin yerine dayanıklı hale getirildi)

### DB'den doğrulananlar (11 sorgu, `sql-log/manuel-reeskont-kodlama/`)
- ✅ **Ekranın kestiği fişler doğru** — `TxnId 553337` iki tam döngü, `ReverseId` iki yönlü, Regenerate imzası § 4.3 ile birebir
- ~~✅ **T-01 fix çalışıyor**~~ — 🔴 2026-09-30 review: kodda artık YOKTU (ters fiş `"SYSTEM"`, reeskont trader'ı yazıyordu).
  🟡 **Sonraki faz:** doğru çözüm motor context'ine `StateMaker` taşımak; tracker üzerinden damga denendi ve geri alındı → [progress-66](progress/progress-66.md)
- ✅ **Id örtüşmesi YOK** — TxnMM `551.002–553.337` · TxnLoan `1.201.069–1.201.167`, kesişim **boş** → progress-26'nın açık kalemi **kapandı**
- ✅ **Aynı gün (T+0) ters fiş canlıda VAR** → eski validator kuralım çürütüldü
- 🔴 **Hafta sonu valörlü ters fiş canlıda %43** (1983'ün 853'ü; Pazar 645, Cumartesi 208) — **batch** kaynaklı, batch **düzeltilmedi**
- 🔴 **`ProductCode` TABLOYU GÖSTERMİYOR** — `'Loan'` fişlerinin tamamı TxnMM'de, `'MM'` fişlerinin bir kısmı TxnLoan'da → ayrımı yapan navigation join; `ProductCode` tiebreaker olarak **yetmez**
- 🟡 **Audit yarım (C-19)** — T+0 fişi Generate'e basanı kaydetmiyor (transaction'ın maker'ını taşıyor)

### 🟨 Doküman ile bilinçli farklar (kapatılmadı — iş birimi kararı gerekiyor)
`D-1` § 5.4 Select All tüm veri kümesi (bizde **yüklenmiş satırlar**, `C-10` açık) ·
`D-2` § 5.3 Revaluation Type filtresi (MM'de **gizli**, `C-03` açık) ·
`D-3` endpoint/tip adları **İngilizce** (kullanıcı kararı) ·
`D-4` `baseUrl` → **`moduleCode`** (kullanıcı onayı) ·
`D-5` `Reason` → **`ReasonCode` + `ReasonDetail`** (üst küme) ·
`D-6` `Processing` durumu **üretilmiyor** (`C-07`) ·
`D-7` `RegenerateToToday` backend hazır, **ekranda kapalı** (**Faz 2**) ·
`D-8` tek buton `Execute Selected` → **iki buton** (`C-01`, doküman iki tasarım nesli taşıyor)

---

## 1. Hedef

FX'e hardwire edilmiş mevcut Manuel Reeskont ekranı yerine **modül-agnostik tek base component**:
3 ekran (Investment · Security · Treasury), ürün ekipleri yalnız **2 endpoint** + **kolon config** teslim eder.

### 🔴 Mimari — v2 (GEÇERLİ, 2026-08-12)

**WebUI base component → WebUI Controller/service → modül API'lerine (MM · Fx · FI · InvFund) DİREKT Refit fan-out.**

**`NetTrex.Common` KULLANILMIYOR.** Önceki v1 kararı ("Common'a tek uç, orada DailyFlow V2 tarzı fan-out")
kullanıcı tarafından **iptal edildi** → `ADR-MR-015`.
**Faz 3'e kadar `NetTrex.Common`, `Treasy.MicroUI.Packages` ve MicroUI projelerine dokunulmuyor.**

Kaynak doküman: `.ai-agent/imports/Manuel Reeskont v1.docx` (v1.0, 28 Temmuz 2026)

---

## 2. Faz Panosu

🔴 **Fazlandırma 2026-08-12'de yeniden yapıldı** — A/B cevapları olmadan yapılabilen her şey Faz 1'e,
A/B gerektiren her şey Faz 2'ye ayrıldı. **İş emri + iş kalemi (`İ-xx`) listesi → [`05-faz-plani.md`](05-faz-plani.md)**

| Faz | Kapsam | Repolar | A/B gerekli? | Durum |
|-----|--------|---------|---|-------|
| **0** | **Analiz & doğrulama** — doküman · FX ekranı · MM envanteri · WebUI desen envanteri · mimari · MD altyapısı · **6 teknik doğrulama + sözleşme taslağı** | — | ❌ | ✅ **bitti** (sözleşme donduruldu) |
| **1** | **İskelet & okuma yolu** — Treasury ekranı açılıyor, filtre çalışıyor, MM verisi **sayfalı** grid'de, durum badge'leri | `NetTrex.Web.UI` + `NetTrex.MM` | ❌ | ✅ **kodlandı** · backend uçtan uca doğrulandı · ⬜ tarayıcı testi |
| **2** | **Aksiyonlar & yazma yolu** — Generate/Regenerate, onay penceresi, satır bazlı sonuç, MM `executions`, ters fiş | `NetTrex.Web.UI` + `NetTrex.MM` | ✅ **C-01/07/08** | ✅ **kodlandı** · ⬜ **gerçek fiş testi onay bekliyor** (Fimple'a yazar) |
| **3** | Diğer modüller (Fx, FI, InvFund) 2 endpoint · Security + Investment ekranları · `RegenerateToToday` | `NetTrex.Fx` + ürün ekipleri | 🟡 C-02 | 🟡 **UI + MM tarafı bitti** · modül uçları **sahiplerinde** |
| **4** | Base component → `Treasy.MicroUI.SharedDependency` + `@treasy/components`; MicroUI'ler **import eder** | `Treasy.MicroUI.Packages` + MicroUI'ler | ❌ | ⏸️ **kullanıcı kararı bekliyor** (*"ben deyince"*) |
| **5** | Generate/Regenerate **öncesi** yeni değerleme tutarlarının önizlemesi | — | ✅ | ⬜ |

> 🟢 **Ek tur (2026-08-13): doküman uyumluluğu.** `09-dokuman-uyumluluk-raporu.md`'de tespit edilen
> **9 eksik** kapatıldı (kolon seti/sırası · `StatusDescription` · durum özeti şeridi · pill filtre ·
> `Revaluation Type` · `SubProduct` zorunlu · rozet renkleri § 7.1 · config şeması § 5.5 ·
> `Html.DevExtreme().ManualRediscount()` + `ManualRediscount.init()`), ayrıca **`Regenerate` +
> `NotRediscounted` davranış hatası** düzeltildi. Detay → `progress/progress-12.md`.

**Eski↔yeni eşleme:** eski Faz 1 = yeni **Faz 1 + 2** · eski Faz 2 = yeni Faz 3 (MicroUI kısmı Faz 4'e) · eski Faz 3 = yeni Faz 5.

---

## 3. ✅ BLOKE EDENLER — **HEPSİ KAPANDI (2026-08-13)** · KOD YAZILABİLİR

> 🔒 **[`06-sozlesme.md`](06-sozlesme.md) DONDURULDU.** Kullanıcı talimatıyla (*"mevcut FX ekranına bakıp
> mantık yürüterek cevapla"*) 11 açık soru kapatıldı; her kararın dayanağı `06-sozlesme.md` § 0'da.
>
> **Kapanan:** C-01 (2 buton + `All` var, tekil filtre) · C-02 (Product/SubProduct **tekil** — kullanıcı) ·
> C-05 (`Failed`) · C-07 (**senkron**) · C-08 (`ReverseValueDate` **kalıyor** — MM zaten parametrik) ·
> C-14 (`Data` item içinde — kullanıcı) · C-15 (UI JSON) · M-02 (SubProduct string, config'te) ·
> M-05 (2 ondalık) · M-07 (`Rediscount`, batch ile aynı) · **M-08 (canlı DB'den doğrulandı)** · R-04 (konu kapandı)
>
> 🔑 **En büyük kazanç:** Product tekil ⇒ **her sorgu tek modüle gidiyor** ⇒ `R-13` (çok modüllü sayfalama) **ortadan kalktı**.

<details><summary>Kapanmadan önceki hâli (tarihsel)</summary>

| # | Soru | Kim cevaplayacak |
|---|------|------------------|
| **C-01** | **Execute Selected mi, Generate + Regenerate mi?** Doküman **iki tasarım nesli** taşıyor. `All` var mı yok mu? ⚠️ **Yeni kanıt:** mevcut Fx ekranında `RediscountStatusTypes.All` **VAR** ve controller default'u o → "All var" tarafı güçlü | İş birimi |
| **C-07** | **`executions` senkron mu asenkron mu?** Dokümanın içindekiler'inde "6.1 Asenkron İşlem Mimarisi" var, **gövdede bölüm YOK**. 248 kayıt × senkron Fimple = timeout. ⚠️ v2'de Common'ın 10 dk Refit timeout'u da yok → WebUI timeout'u doğrulanmalı (`F-16`) | İş birimi |
| **C-08** | **`ExecutionsRequest` nihai modeli ne?** İki farklı alan listesi var; `ReverseValueDate` ikincisinde **kayıp** | İş birimi |
| **C-02** | **Product tekli mi çoklu mu? Sub Product filtresi var mı?** Metin "tekli+zorunlu" diyor, **tüm görsellerde çoklu** ve Sub Product filtresi **hiç yok** | İş birimi |

</details>

Tam liste → [`04-sorular.md`](04-sorular.md) · **kararların dayanağı** → [`06-sozlesme.md`](06-sozlesme.md) § 0

---

## 4. Sıradaki Somut Adımlar

Tam liste ve bağımlılıklar → [`05-faz-plani.md`](05-faz-plani.md) § 9. Özet:

| Sıra | İş | Bağımlılık |
|---|----|-----------|
| 1 | **İ-01…İ-06** — 6 teknik doğrulama (token · `General:AvailableModules` · `ModuleConstants` · Refit timeout · 2 okunmayan Razor/wrapper) | ❌ yok, **bugün** |
| 2 | **İ-07** — `06-sozlesme-taslak.md`: `eligible-transactions` **kesin**, `executions` **varyantlı** | ❌ yok |
| 3 | **İ-08** — MM durum türetme sorgusu **tasarımı** (M-08 için 3 alternatif + karşılaştırma) | ❌ yok |
| 4 | 🔴 **`04-sorular.md` § A'yı iş birimine gönder** | — |
| 5 | 🔴 **§ B'den önce şu 4'ü karara bağla:** `C-14` · `C-15` · `M-02` · `M-08` — Faz 1'i açan tek şey | Selim |
| 6 | Faz 1 kodlama (**İ-10…İ-45**, 24 kalem) — MM okuma ucu + Web.UI iskelet + base component | 5 |
| 7 | `06-sozlesme.md` DONDUR | 4 + § B tamamı |
| 8 | Faz 2 kodlama (**İ-50…İ-64**) | 7 |

> 💡 **1-2-3 şimdi başlayabilir** — hiçbir cevaba bağlı değil.
> 💡 Faz 1 için iş biriminden **hiçbir şey gerekmiyor** — yalnız Selim'in **4 kararı** (§5).
> 💡 `M-08` varsayımla geçilirse **yüksek dönüş maliyeti** var → tasarımı yaz, kodlamayı cevaba bırak.

---

## 5. Dosya Haritası

| Dosya | İçerik |
|-------|--------|
| [`00-PANO.md`](00-PANO.md) | **bu dosya** — şu anki durum |
| [`01-dokuman-analizi.md`](01-dokuman-analizi.md) | Doküman tam analizi · eski↔yeni 19 boyutlu karşılaştırma · 20 çelişki (C-xx) |
| [`02-mimari-karar.md`](02-mimari-karar.md) | **v2** mimari · § 0 sürüm tablosu · § 2 base component tasarımı · **18 ADR** · 18 boşluk (F-xx) · 12 risk (R-xx) |
| [`03-mm-backend-envanteri.md`](03-mm-backend-envanteri.md) | MM'de hazır/yazılacak · 11 tuzak (T-xx) · 9 MM sorusu (M-xx) |
| [`04-sorular.md`](04-sorular.md) | **İş birimine gönderilecek** + Selim'in kararı + kapanmışlar |
| [`05-faz-plani.md`](05-faz-plani.md) | ⭐ **İŞ EMRİ** — 6 faz · **58 iş kalemi (`İ-xx`)** · A/B bağımlılık matrisi · faz başına Definition of Done · varsayım tablosu. **Her ilerlemede buradan gidilir** |
| `06-sozlesme.md` | ⬜ **Nihai sözleşme — kod öncesi DONDURULACAK (skill'in KAPISI)**. Öncesinde `06-sozlesme-taslak.md` (İ-07) |
| [`10-is-birimi-release-notu.md`](10-is-birimi-release-notu.md) | ⭐ **İş birimi için** — ekran nasıl çalışır, alan veri kaynakları, buton davranışları, görsel yer tutucuları (2026-08-17) |
| [`07-fimple-entegrasyon.md`](07-fimple-entegrasyon.md) | ⭐ **Fimple ayağı** — baseline uç + gerçek payload'lar · 6 tuzak (`FT-xx`) · **9 alternatif API önerisi (`Ö-xx`)** · 8 Fimple sorusu (`Ö-S-xx`) · 5 risk (`R-16`…`R-20`). ⚠️ § 5 **öneri**, karar verilmedi |
| [`analiz/`](analiz/_index.md) | **Ham araştırma çıktıları** — dosya yolu + satır referanslı kanıt (**7 kayıt**: analiz-0 arşiv + 1…6) |
| [`progress/`](progress/_index.md) | Sürümlenmiş durum kaydı — **en güncel: [progress-2.md](progress/progress-2.md)** |
| `faz-docs/` | ⬜ Faz başlayınca `phase-N-*.md` |

**İlgili dış dosyalar:**

| Ne | Yol |
|----|-----|
| Kaynak doküman | `../imports/Manuel Reeskont v1.docx` + `manuel-reeskont-v1-duz-metin.txt` + `manuel-reeskont-gorseller/` (7 png) |
| **Mevcut FX ekranının kod analizi** | `../../NetTrex.MM/.ai-agent/feature-research/ManuelRevaluation/FxManuelRevaluation-Reeskont-research.md` |
| Mevcut FX ekranı — iş birimi dokümanı | `../../NetTrex.MM/.ai-agent/feature-research/ManuelRevaluation/2026-07-27-ManuelRevaluation-IsBirimi-Dokumani.md` |
| MM'in EOD accrual araştırması (**ayrı konu!**) | `../../NetTrex.MM/.ai-agent/feature-research/Revaluation-research.md` |
| **Web.UI repo hafızası** (2026-08-12 kuruldu) | `../../NetTrex.Web.UI/.ai-agent/{PROJECT_CONTEXT,MEMORY}.md` |
| Bu sohbetin compact'leri | `../compacts/manuel-reeskont-analiz/` — **yeni oturumda OKUNUR** (kullanıcının kendi kelimeleri + karar gerekçeleri) |
| 🔴 **DB erişim denetim kaydı** | `../sql-log/manuel-reeskont-analiz/{01-sorgular,02-ciktilar}.md` — istisnasız her sorgu + çıktısı |

---

## 6. Karar Kaydı (kullanıcı onaylı)

| Tarih | Karar |
|-------|-------|
| 2026-08-12 | ~~Fan-out `NetTrex.Common`'da — DailyFlow deseni (ADR-MR-001)~~ ❌ **İPTAL, aynı gün** |
| 2026-08-12 | 🔴 **`NetTrex.Common` hiçbir şekilde kullanılmayacak** — fan-out **WebUI Controller/service'te**, modüllere direkt (`ADR-MR-015`) |
| 2026-08-12 | 🔴 **Faz sırası:** (1) Web.UI + MM → (2) diğer modüller → (3) `Treasy.MicroUI.Packages` + MicroUI import (`ADR-MR-017`) |
| 2026-08-12 | **`baseUrl` → `moduleCode`** — iş birimine sözleşme değişikliği olarak bildirilecek (`ADR-MR-002`) |
| 2026-08-12 | **Base component deseni:** iskelet `cashFlow/` (nesil 3), dosya bölümlemesi + prefix `limit-check/` (`ADR-MR-016`) |
| 2026-08-12 | **Workspace md katmanı kuruldu** — `repos/CLAUDE.md` + `repos/.ai-agent/`; cross-repo işler burada yaşar |
| 2026-08-12 | **`NetTrex.Web.UI`'ye ayrı MD katmanı kuruldu** — workspace katmanı cross-repo/kısa kalmalı |
| 2026-08-12 | **`manuel-reeskont` skill'i** — gövde workspace'te, wrapper **hem MM hem Web.UI**'de |
| 2026-08-12 | **Araştırmalar ham haliyle** `analiz/` altına, her cevaptan sonra yeni numaralı dosya |
| 2026-08-12 | **Compact'ler diske, sohbet başına klasör** — `compacts/<chat-slug>/compact-<n>.md`; `PreCompact` + `SessionStart:compact` hook'ları repo başına kurulu |

---

## 7. Ölçülen Kritik Gerçekler (tahmin değil)

### v2 mimarisini destekleyenler

| Bulgu | Kanıt |
|-------|-------|
| ✅ **4 modülün Refit marker'ı Web.UI'de ZATEN kayıtlı** (`IClientMMAPI` · `IClientFxAPI` · `IClientFiAPI` · `IClientFundsAPI`) — ek DI/config gerekmiyor | [`analiz-6`](analiz/analiz-6-webui-base-component-desenleri.md) § 6 · `Startup.cs:58-75` |
| ✅ **`moduleCode` house convention** — `CashFlowComponent.settings.moduleCode` var, request'e `Module` olarak basılıyor | analiz-6 § 3 · `cashflow.component.js:112`, `:983` |
| ✅ **Config-driven endpoint override deseni mevcut** (`dataSource.<op>.url`) | analiz-6 § 3 · `cashflow.component.js:990-992` |
| ✅ **Modül parametreli ViewComponent + hidden alan deseni mevcut** | analiz-6 § 4 · `LimitCheckViewComponent.cs` |
| ✅ **MM'de T+0 fiş + ters fiş deseni TAM KURULU** — FX ile aynı `accEntryMain` şeması | [`analiz-2`](analiz/analiz-2-mm-revaluation-backend.md) § C |
| ✅ Faz 3 için: paketten **tam ekran** + 10 grid'li ortak bileşen çıkıyor (RCL) | [`analiz-1`](analiz/analiz-1-microui-shell-paketler.md) § B |

### Tuzaklar

| Bulgu | Kanıt |
|-------|-------|
| 🔴 **`settings.baseUrl` modül adresi DEĞİL** — `@Url.Content("~")`, uygulamanın kök yolu → **modül seçimi zorunlu olarak sunucuda** | analiz-6 § 2 · `_ErrorLayout.cshtml:54-56` |
| 🔴 **`ajax.js` hatayı YUTUYOR** — `IsSuccess === false → null`, grid sessizce boşalır | analiz-6 § 2 · `ajax.js:20`, `:45` |
| 🔴 **Eski `Load` iki farklı şekil döndürüyor** (hata → obje, başarı → liste) | analiz-6 § 7 |
| 🔴 **Top-level `const` çakışması tüm sayfayı SyntaxError ile çökertir** → `MR_` prefix zorunlu | Web.UI Hard Rule 4 |
| 🔴 **Fimple çağrısı idempotent değil** (her istek yeni `Guid`) → çift tıklama koruması API'de | analiz-2 § E (T-02) |
| 🔴 Web.UI permission = **ControllerAdı/ActionAdı** → 3 ekran = **3 controller** | [`analiz-3`](analiz/analiz-3-webui-common-yapi.md) § E (F-11) |
| 🔴 **Server-side paging hiçbir emsalde YOK** — doküman zorunlu kılıyor, kasıtlı sapılacak | analiz-5 § D (F-06) · analiz-6 § 7 |
| 🔴 Marker adları tutarsız: `IClientMMAPI` (çift M) · `IClientFundsAPI` (**Funds**) · `IClientOptFXApi` (küçük `Api`) | analiz-6 § 6 |
| 🔴 Eski ekran klasörü **`ManuelReescont`** (yazım hatalı), namespace **`…FX.Report`** → yeni kod ayrı klasöre, eskiye dokunulmaz | analiz-6 § 7 (G-14) |

### v2 ile açılan doğrulama boşlukları

| # | Ne |
|---|---|
| `F-13` | WebUI → modül Refit çağrısında **bearer token taşınıyor mu?** |
| `F-14` | WebUI'den **`General:AvailableModules`** framework parametresi okunabiliyor mu? |
| `F-15` | WebUI'de Common'ın `ModuleConstants` karşılığı var mı? |
| `F-16` | WebUI Refit **timeout** değeri nedir? (Common'da 10 dk idi) |
| `F-17` | `Views/Shared/Components/{CashFlow,LimitCheck}/Default.cshtml` okunmadı |
| `F-18` | `ManuelReescontApi` wrapper'ının içi okunmadı |

### v1'den kalan, artık konu dışı olanlar

`F-01` (InvFund Common client'ı) · `F-03` (Common `Task.WhenAll`) · `F-04` (`ToContentGeneral`) ·
`F-05` (Common token) — **Common kullanılmadığı için geçersiz**. Ölçümler `analiz-4`/`analiz-5`'te
emsal olarak duruyor; `02-mimari-karar.md` § 0 hangisinin hâlâ geçerli olduğunu işaretliyor.
