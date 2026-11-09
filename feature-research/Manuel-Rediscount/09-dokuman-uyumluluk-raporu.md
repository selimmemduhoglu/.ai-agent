# 09 — DÖKÜMAN UYUMLULUK RAPORU (madde madde)

> **Amaç:** `Manuel Reeskont v1.docx`'in **her maddesi** için "ne isteniyordu / biz ne yaptık / durum".
>
> ⚠️ **Bu rapor için doküman BAŞTAN SONA yeniden okundu** (412 paragraf, tam çıkarım).
> İlk okumam paragraf bölmesi olmadan yapılmıştı ve **bazı maddeler gözden kaçmıştı** —
> bu raporda o boşluklar **açıkça işaretlendi**.
>
> **Tarih:** 2026-08-13 · Kod durumu: `NetTrex.MM` ✅ build · `NetTrex.Web.UI` ✅ build
> · MM birim test **74 ✅** · Web.UI JS test **34 ✅** (jest; tüm suite 334, 34'ü bizim)
>
> 🟢 **2. TUR (2026-08-13 akşam) — § 9'daki 9 eksiğin TAMAMI kapatıldı.**
> Her maddenin altına ✅ **KAPANDI** satırı eklendi; § 9 artık **kapanış tablosu**.

---

## 0. ÖZET — dürüst tablo

| | 1. tur | **2. tur (güncel)** |
|---|---|---|
| ✅ **Tam yapıldı** | 28 | **37** |
| 🟡 **Kısmen / farklı yapıldı** (gerekçeli, onaylı sapma) | 6 | 6 |
| ❌ **YAPILMADI** | 9 | **0** |
| ⏸️ **Kapsam dışı bırakıldı** (kullanıcı kararı) | 3 | 3 |

**Ayrıca 1. turda hiç fark edilmemiş bir davranış hatası bulundu ve düzeltildi:**
`Regenerate` + `NotRediscounted` `NOT_REDISCOUNTED` ile fail ediyordu; image6 *"Önceki değerleme
bulunmadığından yeni değerleme oluşturulur"* diyor → artık yeni değerleme oluşturuluyor.

**Kapsam dışı kalanlar (değişmedi):** Faz 3 tutar önizlemesi · doküman § 5.4'ün "seçim tüm veri
kümesini kapsar" maddesi (sözleşme § 12 — görülmeyen satıra fiş kesme riski) · MicroUI'ye taşıma
(kullanıcı: *"ben deyince"*).

---

## 1. Amaç, Kapsam, Hiyerarşi (§0 · §1)

| # | Doküman ne istiyor | Biz ne yaptık | Durum |
|---|---|---|---|
| 1.1 | Tek base component; Investment/Security/Treasury üç ekran | `ManualRediscountViewComponent` + 6 JS dosyası; 3 ekran aynı bileşeni farklı `ProductGroup` ile çağırıyor | ✅ |
| 1.2 | Ürün ekipleri UI geliştirmez; 2 endpoint + kolon config verir | `RediscountControllerBase` + config JSON; MM ucu yazıldı, Fx/FI/InvFund **Refit arayüzleri hazır**, uçlar sahiplerinde | ✅ |
| 1.3 | Durum takibi **Logical Reference** bazında | `LogicalReference` her satırda ve `ExecutionItem`'da taşınıyor | ✅ |
| 1.4 | Üç seviyeli seçim: Ekran → Product → Sub Product | `ProductGroup` (controller) → `Product` (tekil) → `SubProduct` (tekil, config'ten bağımlı liste) | ✅ |
| 1.5 | Product değişince Sub Product listesi yüklenir, seçim **sıfırlanır** | `onProductChanged` → `#syncSubProducts()` listeyi kurup değeri boşaltıyor | ✅ |
| 1.6 | Ürüne özel kolonlar **Product** seviyesine bağlı; Sub Product kolon setini değiştirmez | Config `products[].columns`; `SubProduct` yalnız filtre | ✅ |
| 1.7 | Menü: Manuel Reeskont üst menüsü altında 3 ekran | `2026-08-13-ManualRediscount-Menu-Script.sql` — `ParentId 129`, sıra 66/67/68 | ✅ |
| 1.8 | Hata **anlık** gösterilir, DB'de/geçici tabloda saklanmaz | `Failed[]` yalnız response'ta; DB'ye yazılmıyor | ✅ |
| 1.9 | Seçilenler **backend'de yeniden doğrulanır** | `ExecutionsHandler` her satırın durumunu DB'den yeniden türetiyor; uyuşmazsa `STATUS_CHANGED` | ✅ |

---

## 2. Durum Modeli (§3)

| # | Doküman | Biz | Durum |
|---|---|---|---|
| 2.1 | 5 durum: `Error=0`, `NotRediscounted=1`, `Processing=2`, `NotReversed=3`, `Rediscounted=4` | `RediscountStatus` enum'ı **birebir** aynı değerlerle | ✅ |
| 2.2 | `Processing` geçici, kalıcı saklanmaz | Enum'da **rezerve**, akış senkron olduğu için kullanılmıyor | ✅ |
| 2.3 | Durum **en son aktif hareketten** belirlenir | 🔑 `AccEntryMain`: `IsReverse=0` satırın `ReverseId`'si `null`→NotRediscounted · `0`→NotReversed · `>0`→Rediscounted. **Canlı veriden doğrulandı**, 3 testle kilitli | ✅ |
| 2.4 | `Processing`/`Error` kayıtları aksiyon kapsamı dışında | Matriste ikisi de `STATUS_CHANGED` ile reddediliyor | ✅ |
| 2.5 | **`Status Description` zorunlu görünür alan** — kullanıcıya anlaşılır mesaj (§3.3 tablosu: her durum için metin) | ✅ `ManualRediscountItem.StatusDescription` (MM `ResolveStatusDescription` her durum için § 3.3 metnini üretiyor) + grid'de `Status Description` kolonu | ✅ **KAPANDI** |
| 2.6 | Durum geçişleri (§3.5) | Aksiyon×durum matrisi olarak uygulandı, her hücre testli | ✅ |

---

## 3. Fonksiyonel Kurallar (§4)

| # | Doküman | Biz | Durum |
|---|---|---|---|
| 3.0 | 🔴 **image6: `Regenerate` + `Not Rediscounted` → "Önceki değerleme bulunmadığından yeni değerleme oluşturulur"** | 1. turda `NOT_REDISCOUNTED` ile **fail** ediyordu — **davranış hatası**. `RegenerateAsync` düzeltildi: `NotRediscounted` → doğrudan yeni değerleme; `Processing`/`Error` → `OUT_OF_SCOPE` | ✅ **DÜZELTİLDİ** |
| 3.1 | `Not Rediscounted` → T+0 reeskont → `Not Reversed` | `GenerateAsync` → `IRevaluationAccountingService` | ✅ |
| 3.2 | `Not Reversed` → ters fiş (**T+1 varsayılan, T+0 seçenek**) → `Rediscounted` | Ters fiş valörü **DateBox** ile seçiliyor, varsayılan T+0+1 | 🟡 **farklı** — doküman **T+1/T+0 iki seçenekli enum** istiyor, biz **serbest tarih** yaptık (daha geniş ama birebir değil) |
| 3.3 | `Rediscounted` → Re-run: mevcut kayıtlar kapatılır, yeni T+0 + T+1 | `RegenerateAsync` | ✅ |
| 3.4 | Toplu çalıştırmada seçilen valör **tüm** kayıtlara uygulanır | Tek `ReverseValueDate` tüm `Items` için | ✅ |
| 3.5 | **§4.4 Execute Selected** (tek buton, durum-güdümlü) | ❌ yapılmadı — **§4.6 Generate/Regenerate** yapıldı | 🟡 **bilinçli** — doküman **iki tasarım nesli** taşıyor (`C-01`); yeni nesil seçildi |
| 3.6 | **§4.6 Generate / Regenerate** iki aksiyon | Toolbar'da iki buton, `actions` map'i | ✅ |
| 3.7 | `All` seçilince farklı durumlar aynı listede; işlem **kaydın kendi durumuna** göre | `Status=null` → tümü; handler her satırın durumuna göre dallanıyor | ✅ |
| 3.8 | Karışık `Revaluation Type` → **Generate pasif**, Regenerate aktif | `mrIsSingleRevaluationType()` — Generate pasif, Regenerate etkilenmiyor + uyarı mesajı | ✅ |
| 3.9 | §4.7 Onay penceresi (işlem özeti) | `mrConfirmExecution` — **Generate:** madde listesi (image5) · **Regenerate:** durum bazlı kırılım + `Processing/Error → kapsam dışı` (image6). 0 kayıtlı durum satırı basılmaz | ✅ **görsele göre yenilendi** |
| 3.10 | §4.5 Ürün servisi nihai otorite, durum yeniden doğrulanır | ✅ (2.x/1.9) | ✅ |

---

## 4. 🔴 Ekran Tasarımı — EN ÇOK BOŞLUK BURADA (§5)

### 4.1 Zorunlu alanlar (§5.1)

| Alan | Doküman | Biz | Durum |
|---|---|---|---|
| `TransactionId` | Gizli | Var, grid'de gösterilmiyor | ✅ |
| **`Product`** | **Görünür kolon** | `ManualRediscountItem.Product` (MM'de `ProductName`; boşsa alt ürün koduna fallback) + grid kolonu | ✅ **KAPANDI** |
| `Logical Reference` | Görünür | Var | ✅ |
| **`External Customer Id`** | **Görünür** | `ExternalCustomerId` (`long?`) — MM sorgusunda `Customer.ExternalCustomerId` | ✅ **KAPANDI** |
| **`External Customer Name`** | **Görünür** | `ExternalCustomerName` — `CustomerName` **kaldırıldı** | ✅ **KAPANDI** |
| `Status` | Görünür + rozet | Var, rozetli (pastel zemin + koyu metin, image2) | ✅ |
| **`Status Description`** | **Görünür, zorunlu** | `StatusDescription` + grid kolonu | ✅ **KAPANDI** |

**Sabit kolon setinden çıkarılanlar:** `SubProduct` (destek alanı olarak kaldı — filtre/gruplama) ve
`ValueDate` (§5.1 listesinde yok → `Data` sözlüğüne taşındı, ürün config'inde `order: 1`).

### 4.2 Kolon sırası (§5.2)

**Doküman:** `[☑] → Product → Logical Reference → External Customer Id → External Customer Name → Status → Status Description → ürüne özel`

**Bizde (güncel):** aynen bu sıra — `mrBuildFixedColumns()`; seçim kutusu kolonunu DevExtreme
`selection` ayarı ekler. Sıra **jest testiyle kilitli** (`manualRediscountComponent.test.js`).

✅ **KAPANDI**

### 4.3 Filtreler (§5.3)

| Filtre | Doküman | Biz | Durum |
|---|---|---|---|
| `Execution Date` | var | var | ✅ |
| `Product` | tekli, **zorunlu** | tekli, zorunlu | ✅ |
| `Sub Product` | tekli, **ZORUNLU** — boş gönderilemez | Validator `NotEmpty` (MM) + UI'de `All` seçeneği **kaldırıldı**, ilk alt ürün otomatik seçili, boşsa `IsFirstLoad` | ✅ **KAPANDI** |
| **`Revaluation Type`** | **Filtre** (§5.3: çoklu · §1.2: tekli — doküman kendi içinde çelişiyor) | **TagBox (çoklu)** filtre + request `RevaluationTypes` + MM'de filtre uygulanıyor. Liste ürün config'inden (`revaluationTypes`); tanımsızsa filtre **gizlenir** (`C-03` — 3. uç açılmadı) | ✅ **KAPANDI** (§5.3 çoklu okuması seçildi) |
| `Status` | tekli + **`All`** | tekli **pill** grubu, ilk pill `All` (image2) | ✅ **görsele göre yenilendi** |
| Product+SubProduct seçilmeden **grid sorgulanmaz** | var | `IsFirstLoad = Product ‖ SubProduct ‖ ExecutionDate boş` | ✅ **KAPANDI** |
| Product değişince Sub Product sıfırlanır **ve grid boşalır** | var | Sıfırlanıyor ✅, grid refresh ✅, `revaluationTypes` de yeniden kurulur | ✅ |
| **Durum bazlı özet satırı** (grid üstünde, Status altında kayıt sayıları) | var | Response'ta `StatusSummary` (MM sorgusunda durum bazlı sayaçlar) → `mrRenderSummary` şeridi. `Processing / Error` kalemi `Total − diğer üçü`'nden **türetilir**, 0 ise basılmaz | ✅ **KAPANDI** |
| **Seçim özeti** (image3: *"Seçili 3 kayıt — Revaluation Type: … (karışık)"*) | dokümanda görsel | `mrRenderSelectionSummary` — seçim varken özet şeridinin yerine geçer, seçim kalkınca eski özet geri döner | ✅ **ek** |

### 4.4 Toplu seçim (§5.4)

| Doküman | Biz | Durum |
|---|---|---|
| Caret menüsü: **Select All / 100 / 50 / 25 / Custom** | `mrRenderSelectionMenu` → `dxDropDownButton`; `Custom…` adet sorar | ✅ **KAPANDI** |
| Seçim **tüm veri kümesini** kapsar (sayfa değil) | ❌ **bilinçli reddedildi** — sözleşme § 12: görülmeyen satıra fiş kesme riski. `Select All` **yüklü satırları** kapsar ve daha fazlası varsa kullanıcı **uyarılır** (sessiz kısıtlama yok) | ⏸️ **kasıtlı** |
| **"100 of 248 selected"** özeti | `mrUpdateSelectionInfo` — `selectedCount of totalCount selected` | ✅ **KAPANDI** |
| **Indeterminate** (yarı seçili) checkbox | 🟡 DevExtreme varsayılanı sağlıyor olabilir — **hâlâ doğrulanmadı** (tarayıcı testinde bakılacak) | 🟡 |

### 4.5 Kolon konfigürasyonu (§5.5)

| Doküman alanı | Biz | Durum |
|---|---|---|
| `productGroup` · `product` | aynı | ✅ |
| **`baseUrl`** | **`moduleCode`** | 🟡 **onaylı sapma** (`ADR-MR-002`) — `settings.baseUrl` uygulama kökü, modül adresi değil |
| `columns[].key` | **`key`** (eski `field` de kabul) | ✅ **KAPANDI** |
| `columns[].caption` | **`caption`** (eski `captionKey` de kabul) — değer localization anahtarı olabilir, `mrText` çözemezse metnin kendisi basılır | ✅ **KAPANDI** |
| `columns[].dataType` | **`dataType`** (eski `type` de kabul) | ✅ **KAPANDI** |
| `columns[].format` | **`format`** — money/rate/date biçimlendirmesine geçer | ✅ **KAPANDI** |
| `columns[].width` | var | ✅ |
| **`columns[].alignment`** | **`alignment`** — tip varsayılanını (money/rate → sağ) **ezer** | ✅ **KAPANDI** |
| **`columns[].order`** | **`order`** — verilmezse dizi sırası korunur | ✅ **KAPANDI** |
| Config'de olup veride olmayan key → **boş hücre + konsola uyarı** | `mrWarnMissingDataKeys` — ilk satıra bakıp eksik anahtarları tek uyarıda listeler (200×12 uyarı basıp konsolu boğmuyor) | ✅ **KAPANDI** |
| Veride olup config'de olmayan → gösterilmez | ✅ | ✅ |
| Sonuç boş olsa da grid **kolonlarıyla kurulur** | ✅ | ✅ |

---

## 5. Teknik Mimari (§6)

| # | Doküman | Biz | Durum |
|---|---|---|---|
| 5.1 | ASP.NET MVC + jQuery + DevExtreme | Aynen | ✅ |
| 5.2 | Endpoint yolları: `POST {baseUrl}/manual-rediscount/eligible-transactions` ve `/executions` | `POST api/manual-rediscount/eligible-transactions` · `/executions` | ✅ |
| 5.3 | Bu iki uç dışında **ek uç yok** | Yok | ✅ |
| 5.4 | UI servis adresini **`baseUrl`'den çözer** | 🟡 UI modül adresi **bilmiyor**; `moduleCode` → sunucuda resolver | 🟡 **onaylı sapma** (`ADR-MR-015`) — teknik zorunluluk |
| 5.5 | **`@(Html.DevExtreme().ManualRediscount().ProductGroup("Treasury"))`** | 🔴 **2026-08-14 tarayıcı testi:** bu biçim runtime'da **500** verdi (`InvalidOperationException` — `WidgetFactory` içinden `IHtmlHelper` reflection ile çözülemiyor; ilk sürüm yalnız `GetFields` bakıyordu, helper base sınıftaki **property** zincirindeydi). Reflection hiyerarşi yürüyecek şekilde düzeltildi **ama 3 ekranın view'ı reflection'sız `Html.ManualRediscount()` overload'ına geçirildi** — aynı builder, aynı davranış, kırılgan katman yok. Doküman biçimi ikinci overload olarak **duruyor** | 🟡 **söz dizimi sapması** — `Html.DevExtreme().` öneki düştü |
| 5.6 | **`ManualRediscount.init({ productGroup: "Treasury" })`** | `manual-rediscount.init.js` — tek global isim `ManualRediscount` (`init`/`get`); `new ManualRediscountComponent({...})` de çalışmaya devam ediyor | ✅ **KAPANDI** |
| 5.7 | §6.4.1 Request: `ExecutionDate`, `ProductGroup`, `Product`, `SubProduct`, **`RevaluationTypes (List)`**, `Status`, `Skip`/`Take`, **`ExtraFilters`** | Hepsi var — `RevaluationTypes` (TagBox) + `ExtraFilters` (`settings.extraFilters`, olduğu gibi taşınır) eklendi | ✅ **KAPANDI** |
| 5.8 | §6.4.2 Response satırı: `TransactionId`, **`Product`**, `LogicalReference`, **`ExternalCustomerId`**, **`ExternalCustomerName`**, `Status`, **`StatusDescription`**, `Data` | 4 alan eklendi (bkz. § 4.1); `CustomerName` kaldırıldı, `ValueDate` `Data`'ya taşındı; response'a ayrıca `StatusSummary` | ✅ **KAPANDI** |
| 5.9 | `Data` sözlüğü; kolon metadata'sı **dönmez** | ✅ | ✅ |
| 5.10 | §6.4.3 `TransactionIds (List<string>)` | 🟡 `Items[{TransactionId, LogicalReference, CurrentStatus}]` — **zenginleştirildi** (§4.5 yeniden doğrulama için) | 🟡 **bilinçli** |
| 5.11 | `ReverseValueDate (enum? T1/T0)` | 🟡 `DateTime?` | 🟡 |
| 5.12 | `Operation` + `RegenerateToToday` | ✅ ikisi de var | ✅ |
| 5.13 | §6.4.4 `Succeeded (List<string>)` · `Failed[{TransactionId, LogicalReference, Reason}]` | `Succeeded`/`Failed` nesne listesi (`ReasonCode` + `ReasonDetail`) | 🟡 daha zengin |
| 5.14 | Gün aralığı **ürün servisinde** türetilir, istemci gün listesi göndermez | `BuildCatchUpDates` MM'de | ✅ |

---

## 6. UI/UX Renkleri (§7.1) — ✅ DÜZELTİLDİ

Rozet artık **pastel zemin + koyu metin** (image2/image6 birebir): `MR_StatusPalette → { bg, fg }`.

| Durum | Doküman | 1. tur (yanlış) | **Güncel** | Durum |
|---|---|---|---|---|
| Not Rediscounted | **Turuncu** | `#fa7408` | `#FDEBE0` / `#C0521F` | ✅ |
| **Processing** | **Mavi** | `#c6b81c` **sarı** | `#E5F1FB` / `#1F5FA8` | ✅ **DÜZELTİLDİ** |
| **Not Reversed** | **Sarı** | `#961da3` **mor** | `#FCF3CF` / `#8A6D0B` | ✅ **DÜZELTİLDİ** |
| Rediscounted | **Yeşil** | `#5B913B` | `#E7F4E4` / `#2E6B27` | ✅ |
| Error | **Kırmızı** | `#A31D1D` | `#FDECEA` / `#A31D1D` | ✅ |

**Neden yanlıştı:** renkler **mevcut FX ekranından** kopyalanmıştı (`Index.cshtml:246-275`).
**Ders:** eski ekran ile doküman çeliştiğinde **doküman esastır**. İki renk artık jest testiyle kilitli.

---

## 7. Yetkilendirme (§9)

| Doküman | Biz | Durum |
|---|---|---|
| Üç ekran **ayrı ayrı** yetkilendirilir | 3 ayrı controller (`ADR-MR-003`) + `2026-08-13-ManualRediscount-Permission-Script.sql` (3 ekran × `_Displayer`/`_Maker`) | ✅ |

---

## 8. Fazlama (§0.1) — dokümanın fazları ile bizimkiler

| Doküman fazı | Kapsam | Bizde |
|---|---|---|
| **Faz 1** | Base component + Treasury · Generate/Regenerate · **All** · **durum bazlı özet** · onay penceresi | ✅ **hepsi** — durum bazlı özet de eklendi |
| **Faz 2** | Security + Investment ekranları · **RegenerateToToday** | ✅ ikisi de |
| **Faz 3** | Generate/Regenerate **öncesi tutar önizlemesi** | ⏸️ **yapılmadı** (kapsam dışı, sonraya) |
| Faz 4+ | İleride tanımlanacak | — |

---

## 9. ✅ KAPANIŞ TABLOSU — 9 eksiğin tamamı kapatıldı (2026-08-13, 2. tur)

| # | Eksik | Nerede kapatıldı | Durum |
|---|---|---|---|
| 1 | **`Status Description`** alanı + kolonu (§3.3 metinleri) | MM `ResolveStatusDescription` + item alanı · Web.UI DTO · `mrBuildFixedColumns` · tr/en localization | ✅ |
| 2 | **`Product`** görünür kolonu | MM `TDMRediscountEligibleResult.ProductName` → `Product` (boşsa alt ürün koduna fallback) + sabit kolon | ✅ |
| 3 | **`External Customer Id`/`Name`** alanı + kolonu | MM sorgusu + DTO + 2 sabit kolon; `CustomerName` kaldırıldı | ✅ |
| 4 | **Kolon sırası** dokümana göre | `mrBuildFixedColumns()` § 5.2 sırası — **jest testiyle kilitli** | ✅ |
| 5 | **`Sub Product` zorunlu** | MM validator `NotEmpty` + UI'de `All` kaldırıldı, ilk değer otomatik, `IsFirstLoad` guard'ı | ✅ |
| 6 | **`Revaluation Type` filtresi** (+ `RevaluationTypes`) | TagBox filtre + request alanı + MM'de filtre; liste ürün config'inden (`C-03`) | ✅ |
| 7 | **Durum bazlı özet satırı** | MM sorgusunda durum sayaçları → `StatusSummary` → `mrRenderSummary` şeridi (+ image3 seçim özeti) | ✅ |
| 8 | 🔴 **Rozet renkleri** (Processing mavi, Not Reversed sarı) | `MR_StatusPalette` — doküman § 7.1, jest testiyle kilitli | ✅ |
| 9 | **`Html.DevExtreme().ManualRediscount()`** + **`ManualRediscount.init()`** | `ManualRediscountBuilderExtensions.cs` + `manual-rediscount.init.js`; 3 ekran güncellendi | ✅ |

**Ek maddeler de kapandı:** kolon config alan adları (`key`/`caption`/`dataType`/`format`/`alignment`/`order`,
eski şema geriye dönük kabul) · eksik anahtar için **konsol uyarısı** · `Select All / 100 / 50 / 25 / Custom`
menüsü + `"N of M selected"`.

**Fazladan yapılan (dokümanın açık talebi değil, görselden/koddan çıktı):**

- `Regenerate` + `NotRediscounted` **davranış hatası** düzeltmesi (image6)
- `OUT_OF_SCOPE` reason code — `Processing`/`Error` için "kapsam dışı" ≠ "durum değişti"
- Generate pasifken buton altında **kalıcı ipucu** (image3) — notify 3 saniyede kayboluyordu
- `mrEscapeHtml` — müşteri adı/referans `innerHTML`'e basıldığı için DOM enjeksiyonu kapatıldı

### Test durumu

| Katman | Ne | Sonuç |
|---|---|---|
| MM | `NetTrex.MM.Api.Services.Tests.exe -namespace "*ManualRediscount*"` | **74 test · 0 hata** |
| Web.UI JS | `npx jest --testPathPattern manuelReeskont` (JS_ROOT=`…/NetTrex.Web.UI/Code`) | **34 test · 0 hata** |
| Web.UI JS (tüm suite) | `npx jest` | **334 test · 0 hata** (34'ü bizim) (regresyon yok) |
| MM build | `dotnet build Code\NetTrex.MM.sln` | ✅ |
| Web.UI build | `dotnet build Code/Web/UI/Trex.WebUI/Trex.WebUI.csproj` | ✅ 0 error |

⚠️ **Web.UI'de C# tarafı için Manual Rediscount birim testi yazılmadı** — `RediscountControllerBase`/
`ManualRediscountQueryService` karar taşıyor ama Web.UI test projesinde controller testi deseni yok
(yalnız `Controllers/Funds` altında bir örnek + Reqnroll feature'ları). Karar mantığının tamamı
(durum türetme, aksiyon×durum matrisi) **MM'de** ve orada testli; Web.UI tarafı ince proxy.
Bunu **bilinçli olarak** atladım — sessizce geçmiyorum.

---

## 10. Neden kaçtı — dürüst değerlendirme

İlk okumamda docx'i **paragraf bölmesi olmadan** düz metne çevirmiştim; tablolar ve madde listeleri
birbirine karışmıştı. §5.1 zorunlu alan tablosu, §5.2 kolon sırası, §7.1 renk listesi ve §6.3 giriş
noktaları o çıkarımda **okunaklı değildi**.

Bu turda `<w:p>` sınırlarından bölerek yeniden çıkardım (412 paragraf) → maddeler net göründü.

**Ders:** binary dokümanı düz metne çevirirken **paragraf/tablo yapısını koruyan** bir dönüşüm
kullanılmalı; aksi halde "okudum" demek yanıltıcı olur.


---

## 🔴 2026-08-18 REVİZYON — kaynak `.docx` ham okundu, 4 sapma kapandı

> Önceki bölümler türev özet (`01-dokuman-analizi.md`) üzerinden yazılmıştı. Bu revizyonda kaynak
> **`Manuel Reeskont v1.docx`** doğrudan parse edildi (**318 satır** metin + tablo hücreleri) ve
> **7 görselin tamamı** incelendi. İki sapma **yalnız görsellerde** görünüyordu.

### Kapanan 4 madde

| # | Doküman maddesi | Önce | Sonra |
|---|---|---|---|
| **F-1** | § 3.4 · § 5.2 · § 8.4 + `image7` — işlem sonucu **Status / Status Description** kolonlarında gösterilir; ayrı "Last Result" kolonu **açılmaz** | ❌ Sonuç yalnız dialog'da; `finally` hemen `refresh()` çağırıp sonucu **anında siliyordu** | ✅ Hata alan satır **anlık `Error`** + sebep `Status Description`'da · başarılı satır yeni durumu · grid üstünde `image7` şeridi · `refresh()` kaldırıldı (§ 8.4: *"sayfa yenilendiğinde kalıcı DB durumu"*) |
| **F-2** | § 4.2 · § 6.4.3 · § 8.2 + `image4` — `ReverseValueDate (**enum?**, T1/T0)`, **yalnız `Not Reversed`**'da sorulur; T+1 = **+1 iş günü** | ❌ Filtre çubuğunda **serbest tarih kutusu**; `Min = ExecutionDate+1` **T+0'ı tamamen engelliyordu**; `AddDays(1)` **takvim bilmiyordu** | ✅ Kutu kaldırıldı · `image4` popup'ı (yalnız `Not Reversed` varsa) · istek `ReverseValueType` taşıyor · tarih **modülde** `ICalendarHelper.NextWorkingDayAsync` ile · validator `>` → **`>=`** |
| **F-3** | `image7` — sonuç metni **ne yapıldığını** anlatır | ❌ Tek "başarılı" metni | ✅ Aksiyona göre metin (Generate 1 fiş · Regenerate `Not Reversed`'da **3 fiş**) + **hangi işlem** öneki |
| **F-4** | § 4.6 — karışık **Revaluation Type** → Generate pasif | ✅ **zaten vardı** | Değişmedi. ⚠️ MM'de `RevaluationType` **global framework parametresinden** geldiği için tüm satırlarda aynı → kural **pratikte hiç tetiklenmez** |

### Test edilerek doğrulanan maddeler

| Doküman | Nasıl doğrulandı |
|---|---|
| § 3.2 durum türetme (`ReverseId`) | DB: `TxnId 553337` iki tam döngü, `ReverseId` **iki yönlü** bağlı |
| § 4.3 Re-run "mevcut kayıtlar karşı kayıtları ile kapatılır, sonra yeni çift" | DB: `555825/555826` → `555827/555828` (Regenerate imzası) |
| § 4.2 T+0 seçeneği geçerli | DB: `DayDiff = 0` ters fişler **canlıda var** → eski validator kuralım çürütüldü |
| § 3.3 `StatusDescription` metinleri | Kod: 5 durum için İngilizce metinler doküman parantezleriyle örtüşüyor |
| § 9 üç ekran ayrı yetkilendirme | 3 controller mevcut (`Treasury`/`Security`/`Investment`) + permission script `FrameworkPermission`'a yazıyor |
| § 5.5 config'de olup veride olmayan key → boş hücre + konsol uyarısı | `mrWarnMissingDataKeys` |

### 🔴 Doküman uyumluluğunu ETKİLEYEN, test sırasında bulunan bug

**B-1 (kapandı, restart bekliyor):** ekranın özet şeridi *"1 Not Reversed"* derken grid'de o satır
**yoktu** — EF required navigation → INNER JOIN → orphan FK'da satır sessizce düşüyor.
Bu, doküman § 3.2/§ 5.1'i **fiilen ihlal ediyordu**: uygun bir işlem listelenmiyordu ve kullanıcı
ona fiş kesemiyordu. Detay → `progress/progress-29.md`, `sql-log #30–#33`.

### 🟨 Bilinçli farklar (kapatılmadı — iş birimi kararı gerekiyor)

| # | Doküman | Bizde | Dayanak |
|---|---|---|---|
| D-1 | § 5.4 seçim **tüm veri kümesini** kapsar (`100 of 248`) | **Yüklenmiş satırlar**, aşınca uyarı | Görülmeyen satıra fiş kesilmemeli; `SelectAll` sözleşmede yok (`C-10` **açık**) |
| D-2 | § 5.3 `Revaluation Type` **çoklu filtre** | MM'de **gizli** | `C-03` **açık**: değer kümesi tanımsız, listeyi döndüren uç § 6.2'de yasak |
| D-3 | § 6.2 `/manuel-reeskont/…` · § 6.3 `ManuelReeskont()` | `/manual-rediscount/…` · `ManualRediscount()` | Kullanıcı kararı 2026-08-13 |
| D-4 | § 5.5 `baseUrl` | `moduleCode` | Kullanıcı onayı; WebUI'de runtime base-URL resolver yok |
| D-5 | § 6.4.4 `Failed[].Reason` | `ReasonCode` + `ReasonDetail` | Üst küme; UI localize edebilsin (`C-13`) |
| ~~D-6~~ | § 3.1 `Processing` durumu | ✅ **KAPANDI 2026-08-19** — ekran istek uçarken satırları `Processing` gösteriyor (`mrSetPendingOverlay`), DB'ye yazılmıyor. Modül hâlâ `Processing` döndürmüyor (`C-07`) | Kullanıcı: *"butonlara tıkladığımızda anlık olarak işlenen transaction'ları göstereceğiz, statüsünü değiştirerek"* |
| D-7 | § 0.1 **Faz 2** `RegenerateToToday` | Backend hazır, **ekranda kapalı** | Faz 2 devreye alınmadı |
| D-8 | § 4.4 tek buton `Execute Selected` | İki buton | `C-01`: doküman **iki tasarım nesli** taşıyor, yeni nesil esas alındı |

🔴 **Dürüst özet:** doküman **birebir uygulanmadı**. 4 madde bu turda kapandı; **8 madde bilinçli
olarak farklı** ve bunların 4'ü (`D-1`, `D-2`, `D-6`, `D-8`) **cevap bekleyen `C-xx` sorusundan**
kaynaklanıyor — tercih değil, **belirsizlik**.


---

## 🔴 EK — 2026-08-19 revizyonu

### Kapanan

| # | Neydi | Nasıl kapandı |
|---|---|---|
| `D-6` | § 3.1 `Processing` üretilmiyordu | Ekran istek uçarken satırları `Processing` gösteriyor (geçici, DB'ye yazılmıyor). image1'deki iki ara adım artık ekranda görünüyor |

### Yeni bilinçli farklar

| # | Doküman | Bizde | Dayanak |
|---|---|---|---|
| **D-9** | § 5.4 / § 8.3 toplu seçim menüsü (`Select All / 100 / 50 / 25 / Custom`) + `"100 of 248 selected"` | **YOK** — grid'in kendi pagination'ı + başlık checkbox'ı | Kullanıcı kararı 2026-08-19: *"datagrid'imdeki yapı pagination şeklinde, o yeterli bana"*. `D-1` de bununla düşüyor (zaten § 12 gereği uygulanmamıştı) |
| **D-10** | § 5.3 *"her kayıt üzerinde uygulanacak işlem, kaydın kendi durumuna göre belirlenir"* — karışık **statü** desteklenir; § 4.6 pasifleştirme **yalnız Revaluation Type** için | Karışık **Status** varsa **Generate pasif** (Regenerate aktif) | 🔴 Kullanıcı kararı 2026-08-19: *"generate için aynı statüde olmalı… 5. olanın statüsü farklıysa bastığım an generate butonu disabled olsun"*. ⚠️ **2026-08-18'de ona "§ 5.3 böyle diyor, pasifleşmemeli" demiştim** — kullanıcı tersini istedi, karar onun |

### 🟥 Dokümanın kendi içinde çelişkisi (iş birimine sorulmalı)

| Nerede | Ne diyor |
|---|---|
| **image1 (§ 3.6) notları** | *"A failed operation returns the row to its **previous status**; the error is shown as a brief notification (**no status, no column**)."* |
| **§ 8.4 gövdesi + image7** | *"başarılı işlemlerle birlikte hata alanlar da aynı ekranda (**Error olarak, nedeniyle**) görüntülenir"* + image7'de `Status` kolonunda **kırmızı `Error` rozeti**, `Status Description`'da sebep |

**§ 8.4 + image7 esas alındı** — hata gösterimine ayrılmış bölüm, eşleşen görseli var ve kullanıcının
2026-08-18 talebi de bu yönde (*"bunların statüsü değişmedi, değişmesi gerekmiyor muydu"*).
image1'in notu ise `Error`'ün **kalıcı olmadığını** doğru anlatıyor — çelişki yalnız **gösterim
yüzeyinde**.

### ✅ Bu turda doğrulanan (değişiklik gerekmedi)

| Doküman | Kod |
|---|---|
| § 4.3 / § 4.6 / **image1** — Regenerate yeni reeskont (T+0) **ve** ters fişini (T+1) keser, `Rediscounted`'a döner | `RegenerateAsync` → `Success(Rediscounted)` ✅ image1 notu birebir: *"it re-values (T+0 rediscount + T+1 reverse) and returns to Rediscounted"* |
| § 4.2 — T+1 = **+1 iş günü** · T+0 aynı gün · varsayılan T+1 · toplu işlemde **tüm** satırlara aynı valör | `ICalendarHelper.NextWorkingDayAsync` · `ReverseValueType` istekte **tek** alan ✅ |
| § 3.2 — durum **en son (güncel)** reeskont/ters fiş hareketine göre | iki sorguda da `.OrderByDescending(Id).First…` ✅ |
| § 4.5 — tekrar çalıştırmada backend **güncel durumu yeniden değerlendirir** | `ExecuteItemAsync` DB'den yeniden türetiyor, uyuşmazsa `STATUS_CHANGED` ✅ |
| § 0.1 — `RegenerateToToday` **Faz 2** | Ekran `false` gönderiyor, `BuildCatchUpDates` tek gün döndürüyor ✅ (`D-7`) |


---

## 🔴 EK — 2026-08-20 (ilk tarayıcı testi)

| # | Doküman | Bizde | Dayanak |
|---|---|---|---|
| **D-11** | § 5.3 / § 6.4.1 `RevaluationTypes` **filtresi**; § 4.6 *"seçimin tamamı aynı Revaluation Type değilse Generate pasif"* | Filtre **YOK**, kapı **YOK**, seçim özetinde de **görünmüyor** | 🔴 Kullanıcı kararı 2026-08-20: *"bu atomic-EOD-BOD durumlarının bir önemi yok, bu durumlara bakıyorsan gerek yok ve ekranda da gözükmesin."* **Teknik dayanak:** MM'de değer global bir framework parametresinden geliyor (`Revaluation:MM.ReverseType` → Eod/Bod/Atomic) → tüm satırlarda **aynı**; filtre tek değerli, şerit hep `Atomic` yazıyor, § 4.6 kapısı **hiç tetiklenmiyordu**. Sözleşmedeki `RevaluationTypes` alanı **duruyor** (UI doldurmuyor) |

### Yerine gelen

Seçim özeti şeridi artık **durum kırılımı** gösteriyor:
`Seçili 5 kayıt — 4 Not Rediscounted · 1 Rediscounted (karışık)`.
`D-10` (karışık statü → Generate pasif) için doğrudan işe yarayan bilgi bu; `(karışık)` etiketi
butonun pasifleşeceğini **önceden** haber veriyor.

### § 5.2 kolon hizalamaları — doküman sessiz, kural bizde

Doküman kolon **sırasını** tanımlıyor, hizalamayı tanımlamıyor. Kullanıcı isteğiyle (2026-08-20)
kural yazıldı ve teste bağlandı: kısa kod/referans/tarih → **center**, tutar/oran → **right**,
serbest metin → **left**.

⚠️ `Status` alanı `int` olduğu için hizalama **açık yazılmak zorunda** — aksi halde DevExtreme
tipi `number` sayıp başlığı ve hücreyi **sağa** yaslıyor. Finansal ekranda sağa yaslı kolon
"tutar" okunur; bu yüzden `ExternalCustomerId` için de test **`not.toBe("right")`** invariantını
kilitliyor.


---

## 🔴 EK — 2026-08-20 (ikinci tur)

| # | Doküman | Bizde | Dayanak |
|---|---|---|---|
| **D-12** | § 8.2: ters fiş valörü sorusu **yalnız `Not Reversed`** durumunda · *"Diğer durumlarda seçim sorulmaz"* · § 4.3: Regenerate'te ters fiş **T+1 valörü ile** yeniden oluşturulur (sabit) | **Regenerate'te de soruluyor** (varsayılan T+1) | 🔴 Kullanıcı isteği 2026-08-20: *"dokümana göre ben Regenerate'e bastığım zaman tersini hangi tarihe kesmek istediğimi bana sorması gerekmiyor muydu?"* **Gerekçe:** Regenerate her satır için yeni bir T+0 reeskont **ve tersini** kesiyor → § 8.2'nin kendi mantığı ("ters fiş kesilecekse sor") Regenerate'e de uyar. Doküman bu kuralı Regenerate'e uygulamamış. Varsayılan T+1 kaldığı için hiçbir şey seçmeyen kullanıcı **dokümanın davranışını** alır. ⚠️ **Backend'de değişiklik yok** — `ResolveReverseValueDateAsync` T+0'ı Regenerate'te zaten onurlandırıyordu |

### Kullanıcı dokümanı yanlış mı yorumladı?

**Hayır — doküman kendi içinde tutarsız.** § 8.2 soruyu *"ters fiş kesilecekse"* mantığına
bağlıyor ama kapıyı `Not Reversed` **durumuna** yazıyor; § 4.3 ise Regenerate'in ters fiş
kestiğini açıkça söylüyor. İki madde birlikte okununca soru Regenerate'te de doğal.
Harfi harfine okunuşta ise sorulmuyor. Karar kullanıcıya bırakıldı, kullanıcı sorulmasını istedi.


---

## 🔴 EK — 2026-08-20 (üçüncü tur)

### `D-12` genişletildi — kural netleşti

Kullanıcı **doküman yazarına sordu**; cevap: Generate ve Regenerate **ikisinde de** ters fiş
valörü sorulmalı. Uygulanan kural: **ters fiş kesilecekse sorulur.**

| Aksiyon | Seçim | Popup |
|---|---|---|
| Generate | `Not Reversed` | ✅ açılır |
| Generate | `Not Rediscounted` | ❌ açılmaz — § 4.1'e göre bu adımda **yalnız reeskont (T+0)** kesilir, ters fiş üretilmez; sorulan valör hiçbir yerde kullanılmazdı |
| Regenerate | her seçim | ✅ her zaman açılır |

`D-10` sayesinde Generate seçimi homojen olduğu için "Generate'te sorulmuyor" durumu yalnız
ters fiş kesilmeyen adımda oluşuyor. Her koşulda sorulması istenirse tek satırlık değişiklik.

### ✅ Bu turda DOĞRULANAN (kod değişmedi)

| Doküman | Kod |
|---|---|
| § 3.1/§ 3.2 — durum *"ilgili **Execution Date** için"* ve *"**en son (güncel)** hareket"*e göre | `TransactionDataManager.cs:100-108` → `a.ValueDate == executionDate` + `.OrderByDescending(a.Id).FirstOrDefault()` ✅ |
| § 3.2 tablo — `null`/açık/kapalı reeskont ayrımı | `ReverseId` `null` → NotRediscounted · `0` → NotReversed · `>0` → Rediscounted ✅ (`ReverseId` NOT NULL, yokluk `0`) |
| § 3.3 — Status Description metinleri | `EligibleTransactionsHandler.ResolveStatusDescription` ✅ |
| § 4.2 — *"toplu çalıştırmada seçilen valör tüm transaction'lara aynı şekilde uygulanır"* | `reverseValueDate` istekten **bir kez** çözülüyor (`ExecutionsHandler.cs:264`) ✅ |
| § 4.4/§ 8.3 — Regenerate onay penceresi, **durum bazında** kırılım | `mrBuildRegenerateConfirmBody` — görselin satır satır karşılığı ✅ |
| § 4.5 — tekrar çalıştırmada backend durumu **yeniden değerlendirir** | `ExecuteItemAsync` her satır için DB'den türetiyor (`:265-268`) ✅ |

### 🔵 Statü şüphesinin gerçek cevabı

18.08'de `Rediscounted` görünen satır 20.08 listesinde **hiç yok**. Sebep statü türetme **değil**,
**uygunluk filtresi**: `MaturityDate > executionDate` ve faiz döneminin Execution Date'i
kapsaması. Vadesi geçen / faiz dönemi kapanan işlem reeskonta tabi değildir.
⚠️ Bu filtre EOD sorgusuyla **birebir aynı** — ekran ile batch aynı kümeyi görüyor (kasıtlı).


---

## 🟢 EK — 2026-08-20 (beşinci tur) · `D-12` KAPANDI

| # | Neydi | Nasıl kapandı |
|---|---|---|
| ~~`D-12`~~ | Regenerate'te ters fiş valörü **soruluyordu** (2026-08-20 sabahı eklenmişti) | 🟢 **Soru KALDIRILDI.** İş analisti kararı: Regenerate'te valör sabit. Dokümanın § 4.3 (*"ters fiş kaydı **T+1 valörü ile** yeniden oluşturulur"*) ve § 8.2 (*"Diğer durumlarda seçim sorulmaz"*) maddeleri **zaten böyle diyordu** → sormak sapmaydı, kaldırmak **dokümana dönüş** |

### Dokümanın açık bıraktığı nokta artık kapalı

§ 4.3 *"mevcut reeskont ve ters fiş kayıtları karşı kayıtları ile kapatılır"* diyor ama
**kapatma kaydının valörünü** tanımlamıyor. Analist netleştirdi:

| Kayıt | Valör | Gerekçe |
|---|---|---|
| ① nötrleme (eski döngüyü kapatan) | **T+0** | Aynı gün açılan reeskont aynı gün kapanmalı; T+1 olsaydı o günün defterinde **hem eski hem yeni** reeskont açık görünür → **çift tahakkuk** |
| ② yeni reeskont | **T+0** | § 4.1 / § 4.3 — Execution Date valörü |
| ③ yeni ters fiş | **T+1** | § 4.3 — birebir |

3 birim testiyle kilitlendi (`ExecutionsHandlerTests`, 190 → **193**).

### Generate değişmedi

§ 4.2 / § 8.2 aynen geçerli: `Not Reversed` satırlar için valör **sorulur** (T+1 varsayılan),
`Not Rediscounted` adımında ters fiş kesilmediği için **sorulmaz**.
Regresyon testi: `Handle_GenerateShouldStillHonourReverseValueTypeT0_AfterRegenerateRuleChange`.
