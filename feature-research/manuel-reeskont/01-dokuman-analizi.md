# Manuel Reeskont v2 — Doküman Analizi

> Kaynak: `.ai-agent/imports/Manuel Reeskont v1.docx` (Base Component — Fonksiyonel & Teknik Tasarım, v1.0, 28 Temmuz 2026)
> Bu dosya: dokümanın **tam analizi** — ne isteniyor, mevcut FX ekranından farkı, iç çelişkiler, eksikler, sorular.
> Mevcut FX ekranının kod analizi → [`../../NetTrex.MM/.ai-agent/feature-research/ManuelRevaluation/FxManuelRevaluation-Reeskont-research.md`](../../NetTrex.MM/.ai-agent/feature-research/ManuelRevaluation/FxManuelRevaluation-Reeskont-research.md)
>
> **Durum:** 🟡 Analiz turu — kullanıcı kararı bekleyen 19 açık soru var (§ 6).
> **Son Güncelleme:** 2026-08-12

---

## 1. Doküman Kimliği ve Talebin Özü

| Alan | Değer |
|------|-------|
| Doküman türü | Base Component — Fonksiyonel & Teknik Tasarım |
| Versiyon / Tarih | 1.0 · 28 Temmuz 2026 |
| Kullanım | **Tek base component**, üç ekran: Investment · Security · Treasury |
| Görsel sayısı | 7 (durum diyagramı 1 + mockup 6) |
| Teknoloji (§6.1) | ASP.NET MVC + jQuery + DevExtreme |

**Talebin özü:** FX'e hardwire edilmiş tek ekran yerine, **modül-agnostik tek bir base component**. Ürün ekipleri UI geliştirmez; sadece
(a) sözleşmeye uygun **2 endpoint** ve (b) bir **kolon konfigürasyon bloğu** teslim eder.

### 1.1 Üç seviyeli hiyerarşi (§1.3)

```
Manuel Reeskont (üst menü)
├── Investment  (ekran = ProductGroup)
│   ├── FON        → SubProduct: ürün bazında
│   ├── Hisse      → SubProduct: ürün bazında
│   └── Warrant    → SubProduct: ürün bazında
├── Security
│   ├── Bond       → SubProduct: ürün bazında
│   └── Repo       → SubProduct: ürün bazında
└── Treasury
    ├── FX Transaction        → SubProduct: Spot, Forward, Swap
    ├── MM/Loan Transactions  → SubProduct: Murabaha, Wakala   ← BİZİM SORUMLULUĞUMUZ
    ├── Options               → SubProduct: ürün bazında
    └── Derivative            → SubProduct: ürün bazında
```

- Ürüne özel kolon seti **Product** seviyesine bağlanır; SubProduct kolon setini değiştirmez, yalnızca veri kapsamını daraltır.
- Yeni ürün = ilgili ekranın altına Product tanımı + 2 endpoint + kolon config. UI'de yapısal değişiklik yok.

### 1.2 Fazlama (§0.1)

| Faz | Kapsam |
|-----|--------|
| **Faz 1** | Base component + **Treasury ekranı** (FX Transaction, MM/Loan, Options, Derivative). Generate + Regenerate, çok-statülü (All) çalışma, durum bazlı özet, onay penceresi. |
| Faz 2 | Security + Investment ekranları. Regenerate'te **seçilen günden bugüne** geçmiş tarihli yeniden değerleme. |
| Faz 3 | Generate/Regenerate **öncesinde** hesaplanan yeni değerleme tutarlarının **önizlemesi**. |
| Faz 4+ | Açık. |

> 🔴 **Bizi ilgilendiren:** Faz 1'de MM/Loan Transactions **Treasury ekranının içinde** — yani MM backend'i Faz 1'de endpoint sağlamak zorunda.

---

## 2. Eski (mevcut FX ekranı) ↔ Yeni (doküman) Karşılaştırması

Mevcut ekran: `NetTrex.Web.UI/Controllers/ManuelReescont/ManuelRevaluationController.cs` → `ManuelReescontApi` (Refit, `IClientFxAPI`)
→ `NetTrex.Fx` `RediscountController` → `ManualRediscountSelectHandler` / `ManualRediscountUpdateHandler`.

| # | Boyut | **Eski — mevcut FX ekranı** | **Yeni — doküman** |
|---|-------|------------------------------|---------------------|
| 1 | Ekran sayısı | 1 ekran, FX'e hardwire | 1 base component + 3 ekran (Investment/Security/Treasury) |
| 2 | Modül bağlama | Refit `IClientFxAPI` **sabit**; `[Post("/Rediscount/select")]` | Kolon config'teki `baseUrl` → **dinamik**; endpoint yolu sabit |
| 3 | Endpoint | `POST /Rediscount/select`<br>`POST /Rediscount/update` | `POST {baseUrl}/manuel-reeskont/eligible-transactions`<br>`POST {baseUrl}/manuel-reeskont/executions` |
| 4 | Ürün seçimi | `RediscountProductTypes` enum, **çoklu** seçim<br>(Fx / FXSwap / Pm / PmSwap / ExternalFWD / ExternalSWP), WebUI'de virgüllü string | **3 seviye**: ProductGroup (ekran) → Product (tekli, zorunlu) → SubProduct (tekli, zorunlu). **string**, enum değil |
| 5 | Status enum | `All=1, Rediscounted=2, NotRediscounted=3, Error=4, NotReversed=5` | `Error=0, NotRediscounted=1, Processing=2, NotReversed=3, Rediscounted=4` — **değerler tamamen değişti** |
| 6 | `Error` durumu | **Kalıcı** — `valuation.ValuationState == "Error"` DB'de duruyor, filtrelenebiliyor | **Kalıcı DEĞİL** — yalnız anlık UI gösterimi, DB'ye yazılmaz, filtresi yok |
| 7 | `Processing` durumu | **Yok** | **Yeni** — geçici, "core banking'e iletildi, sonuç bekleniyor" |
| 8 | Status türetme | Satır bazlı C# switch: `valuation == null` → NotRediscounted · `acc.ReverseId == 0` → NotReversed · `ValuationState=="Error"` → Error · else Rediscounted. Tarih filtresi valuation'da **yok** | "**en son / güncel aktif** muhasebe kaydı esas alınır" — bir transaction reeskont→ters→reeskont→ters döngüsü yaşamış olabilir, güncel çift dikkate alınır |
| 9 | Aksiyon | **Tek buton**: "REVALUATION CREATE" (`btnReescontKes`). Davranış status'e göre `BuildValuationAccounting` içinde 3 dala ayrılıyor | **İki buton**: **Generate** (eksiği tamamla) + **Regenerate** (geri al + yeniden değerle) |
| 10 | Ters fiş valörü | Kullanıcı seçimi **yok** (batch T+1 mantığı koda gömülü) | **T+0 / T+1 kullanıcı seçimi** (varsayılan T+1), Not Reversed'da sorulur |
| 11 | Onay penceresi | **Yok** — butona basınca direkt POST | **Zorunlu** — durum bazlı özet ile (image5/image6) |
| 12 | Toplu seçim | DevExtreme grid selection, yalnızca yüklenmiş satırlar | **Select All / 100 / 50 / 25 / Custom**, seçim **tüm filtre kümesini** kapsar, "100 of 248 selected", header checkbox indeterminate |
| 13 | Sayfalama | **Yok** — tüm liste tek seferde (`.AsEnumerable()` + satır başına 2 sorgu = N+1) | `Skip` / `Take` + `TotalCount` sözleşmede **zorunlu** |
| 14 | Kolonlar | FX'e özel ~21 kolon Razor'da **sabit** (BuyCcy, SellCcy, BuyAmount, MtmAmount, MtmLcyAmount, ValuationRate, DealRate…) | **6 sabit ortak kolon** + ürüne özel kolonlar **UI JSON config**'ten; veri satırda `Data` dictionary ile taşınır |
| 15 | Özet satırı | **Yok** | Grid üstünde **durum bazlı kayıt sayısı özeti** ("Toplam 248 kayıt · 120 Not Rediscounted · 60 Not Reversed · 50 Rediscounted · 18 Processing/Error") |
| 16 | Hata gösterimi | `Messages` listesi dönüyor ama **WebUI hiç okumuyor**; `IsSuccess` **her zaman true** → hatalar sessizce yutuluyor | `Succeeded[]` + `Failed[{TransactionId, LogicalReference, Reason}]`; UI Error rozeti + Status Description ile **gösterecek** |
| 17 | Yetki | Tek ekran | **3 ekran ayrı ayrı** yetkilendirilir (§9) |
| 18 | İlk açılış | Ekran açılır, `IsFirstLoad` ile sorgu atılır | Product + SubProduct seçilmeden **sorgu atılmaz**; grid bilgilendirme ile boş |
| 19 | Teknoloji | ASP.NET MVC + jQuery + DevExtreme (WebUI monolit) | **Aynı** — MicroUI hiç geçmiyor ⚠️ (§6, C-16) |

### 2.1 Eskiden korunacaklar

- Durum modelinin **çekirdek mantığı** aynı: "açık reeskont var mı / ters fişi atıldı mı".
- Reeskont T+0, ters fiş T+1 muhasebe deseni aynı.
- Regenerate ≈ eski `Rediscounted` dalı (delete + realign + recreate).
- Generate/NotReversed ≈ eski `NotReversed` dalı (yalnız DoReverse + Fimple sync).
- Generate/NotRediscounted ≈ eski `NotRediscounted` dalı (AddValuation + ExecuteAccounting + sync).

### 2.2 Eskinin düzeltilmesi gereken kusurları (yeni ekranda tekrarlanmamalı)

Bunlar FX kod analizinden çıkan **doğrulanmış** bulgular — yeni sözleşme bunların bir kısmını zaten çözüyor:

| Kusur | Yeni tasarımda | Not |
|-------|----------------|-----|
| `IsSuccess` her zaman `true`, hatalar yutuluyor | ✅ Çözülüyor (`Failed[]`) | Sözleşme zorunlu kılıyor |
| Sayfalama yok, N+1 sorgu | ✅ Çözülüyor (Skip/Take) | Backend'de projeksiyon şart |
| Onay yok — yanlışlıkla 248 kayda fiş kesilebilir | ✅ Çözülüyor (onay penceresi) | |
| Stale status race (grid yüklenip beklerken durum değişir) | ✅ Kısmen (§4.5 backend yeniden doğrular) | Lock/versiyon yok → C-11 |
| "Kim tetikledi" audit bilgisi yok | ❌ Sözleşmede yok | C-19'a eklendi |
| `AccountingType` tutarsızlığı (Future'da `Deleting`, diğerinde `Rediscount`) | ❌ Doküman kapsamı dışı | FX'in kendi işi |
| Ters fiş valörü koda gömülü | ✅ Çözülüyor (T+0/T+1 seçimi) | |

---

## 3. Nihai Kabul Edilen Fonksiyonel Model

> ⚠️ Doküman **iki tasarım nesli** taşıyor (bkz. C-01). Aşağıdaki tablo **yeni nesil** (Generate/Regenerate + All)
> okumasıdır; kullanıcı onayı bekliyor.

### 3.1 Aksiyon × Durum matrisi

| Satır durumu | **Generate** | **Regenerate** |
|--------------|--------------|----------------|
| **Not Rediscounted** | Reeskont fişi kes (T+0) → `Not Reversed` | Önceki değerleme yok → doğrudan yeni değerleme (reeskont T+0 + ters fiş T+1) → `Rediscounted` |
| **Not Reversed** | Ters fiş kes (T+1 varsayılan, T+0 seçenek) → `Rediscounted` | Önceki değerleme geri alınır + yeni reeskont T+0 + ters fiş T+1 → `Rediscounted` |
| **Rediscounted** | ⚠️ **Doküman söylemiyor** — muhtemelen atlanır (C-05) | Geri al + yeniden değerle → `Rediscounted` kalır |
| **Processing / Error** | Kapsam dışı (§3.2) | Kapsam dışı |

**Generate kısıtı (§4.6):** Seçilen kayıtların tamamı aynı `Revaluation Type` değilse **Generate pasif**, Regenerate aktif kalır (image3).

### 3.2 Durum geçiş akışı (image1)

```
Not Rediscounted ──Rediscount──► Processing ──success──► Not Reversed ──Reverse──► Processing ──success──► Rediscounted
       ▲                             │                        ▲                        │                        │
       └──────── error ──────────────┘                        └──────── error ─────────┘                   Re-run (re-value)
                                                                                                     (T+0 reeskont + T+1 ters) ─┘
```
- `Processing` geçici; başarıda sonraki duruma çözülür.
- Hata → satır **önceki durumuna döner**, hata anlık gösterilir (DB'ye yazılmaz).

### 3.3 Onay penceresi içerikleri (image5 / image6)

**Generate — Onay:** "Seçilen kayıtlar için aşağıdaki işlemler gerçekleştirilir: **Reeskont** — Not Rediscounted kayıtlar için oluşturulur (T+0). **Ters fiş** — Not Reversed kayıtlar için oluşturulur (T+1)."

**Regenerate — Onay (durum bazlı özet):**
- `30 kayıt` Not Rediscounted → "Önceki değerleme bulunmadığından yeni değerleme oluşturulur."
- `20 kayıt` Not Reversed → "Önceki değerleme geri alınır, yeni değerleme oluşturulur."
- `30 kayıt` Rediscounted → "Önceki değerleme geri alınır, yeni değerleme oluşturulur."
- `18 kayıt` Processing/Error → "İşleme uygun olmadığından **kapsam dışı bırakılır**."

---

## 4. Ekran Yapısı ve Sözleşme

### 4.1 Sabit (ortak) kolonlar — sıra değiştirilemez (§5.1, §5.2)

```
[☑ Seçim] → Product → Logical Reference → External Customer Id → External Customer Name
          → Status → Status Description → (ürüne özel kolonlar, UI JSON config'ten)
```

| Alan | Görünürlük | Not |
|------|-----------|-----|
| `TransactionId` | **Gizli** | İşlem yürütme + hata gösterimi bu alanla |
| `Product` | Görünür | |
| `LogicalReference` | Görünür | Durum takibi bunun üzerinden |
| `ExternalCustomerId` | Görünür | Core banking müşteri no |
| `ExternalCustomerName` | Görünür | |
| `Status` | Görünür | İngilizce etiket + renkli rozet |
| `StatusDescription` | Görünür | Dinamik açıklama / hata nedeni |

- **Ayrı `Action` veya `Last Result` kolonu YOK** (§5.2) — sonuç Status + StatusDescription'da.

### 4.2 Filtreler (§5.3)

| Filtre | Kardinalite | Zorunlu | Not |
|--------|-------------|---------|-----|
| Execution Date | tek tarih | (belirsiz — C-09) | Değerleme tarihi |
| Product | **tekli** | ✅ | Yalnız o ekranın (ProductGroup) ürünleri; kolon seti buna bağlı |
| Sub Product | **tekli** | ✅ | Product'a bağımlı liste; Product değişince sıfırlanır; kolon setini etkilemez |
| Revaluation Type | **çoklu** | ❌ | Değer kümesi dokümanda **tanımsız** (C-03) |
| Status | **tekli** + `All` | ❌ | `All` seçilirse karışık durumlar aynı listede |

- Product + SubProduct seçilmeden **grid sorgulanmaz**; ilk açılışta otomatik sorgu yok.
- Grid üstünde **durum bazlı kayıt sayısı özeti**.

### 4.3 Toplu seçim (§5.4)

- Header checkbox yanındaki caret → **Select All / 100 / 50 / 25 / Custom**.
- Seçim **görüntülenen sayfayı değil, filtreye uyan tüm veri kümesini** kapsar.
- Özet: `"100 of 248 selected"`. Kısmi seçimde header checkbox **indeterminate**.

### 4.4 Kolon konfigürasyonu (§5.5) — UI JSON

```jsonc
{
  "productGroup": "Treasury",          // Investment | Security | Treasury
  "product": "MM_LOAN",                // config anahtarı = productGroup + product
  "baseUrl": "https://.../mm",         // ürün servisinin adresi; sabit yol buna eklenir
  "columns": [
    { "key": "principalAmount", "caption": "Principal", "dataType": "number",
      "format": "#,##0.00", "width": 140, "alignment": "right", "order": 1 }
  ]
}
```

Kurallar:
- `key` değerleri, ürün servisinin `Data` sözlüğündeki alan adlarıyla **birebir aynı** olmak zorunda — **kırıcı sözleşme**.
- Config'te olup veride olmayan key → **boş hücre + geliştirici konsoluna uyarı** (sessiz geçilmez).
- Veride olup config'te olmayan alan → gösterilmez.
- Sonuç kümesi boş olsa dahi grid **kolonlarıyla birlikte kurulur**.
- Config **Product** seviyesine bağlanır; SubProduct bu yapıya girmez.

### 4.5 Endpoint sözleşmesi (§6.2) — yalnız 2 uç

```
POST {baseUrl}/manuel-reeskont/eligible-transactions
POST {baseUrl}/manuel-reeskont/executions
```

Örnek: `POST /fx/manuel-reeskont/eligible-transactions` · `POST /mm/manuel-reeskont/executions`
**Bu ikisi dışında ürün bazlı ek uç tanımlanmaz** (§6.2).

### 4.6 İstek / yanıt modelleri (§6.4)

**`EligibleTransactionsRequest`**
```
ExecutionDate     : DateTime
ProductGroup      : string        (zorunlu)
Product           : string        (zorunlu)
SubProduct        : string        (zorunlu, boş gönderilemez)
RevaluationTypes  : List<...>     (çoklu)
Status            : enum          Error=0, NotRediscounted=1, Processing=2, NotReversed=3, Rediscounted=4
Skip / Take       : sayfalama     (ortak sözleşmenin parçası)
Sıralama bilgisi  : (alan adı belirtilmemiş)
ExtraFilters      : Dictionary<string, object>   // ürüne özgü ek filtre ihtiyacı
```

**`EligibleTransactionsResponse`**
```
Items      : List<ManuelReeskontItem>
TotalCount : int
```
`ManuelReeskontItem`: `TransactionId` (gizli) · `Product` · `LogicalReference` · `ExternalCustomerId` ·
`ExternalCustomerName` · `Status` · `StatusDescription` · `Data: Dictionary<string, object>` (ürüne özel alanlar).
**Yanıtta kolon metadata'sı dönmez.**

**`ExecutionsRequest`** — ⚠️ dokümanda **iki farklı liste** var (C-08):

*Liste A (§6.4.3):*
```
ProductGroup / Product / SubProduct   (listeleme ile aynı, zorunlu)
Status            : enum              // çalıştırılan durum → aksiyonu belirler
TransactionIds    : List<string>
ReverseValueDate  : enum? (T1 | T0)   // yalnız Not Reversed'da; diğerlerinde null
```

*Liste B (§6.4.4 altındaki genişletme):*
```
Operation         : enum { Generate, Regenerate }
ProductGroup      : string
Product           : string
SubProduct        : string
ExecutionDate     : DateTime
RegenerateToToday : bool               // Regenerate için geçmiş tarih kapsamı (Faz 2)
TransactionIds    : List<string>
```
🔴 Liste B'de `Status` ve **`ReverseValueDate` YOK** — ama §4.2 hâlâ T+0/T+1 soruyor. Birleşik nihai model gerekli.

**`ExecutionsResponse`**
```
Succeeded : List<string>                 // başarılı TransactionId'ler
Failed    : List<ManuelReeskontError>    // { TransactionId, LogicalReference, Reason }
```
- Yeniden değerlenecek **gün aralığı ürün servisinde türetilir** — istemci gün listesi göndermez.
- İşlem başlatıldığında her kaydın **güncel durumu ürün servisinde yeniden doğrulanır**; durumu değişenler işleme alınmaz (§4.5).

### 4.7 UI entegrasyonu (§6.3)

```csharp
@(Html.DevExtreme().ManuelReeskont().ProductGroup("Treasury"))   // MVC / Razor
```
```js
ManuelReeskont.init({ productGroup: "Treasury" });                // jQuery
```
Her iki yolda da **yalnız ProductGroup** verilir; ürün listesi, kolon seti ve servis adresi config'ten çözülür.

### 4.8 Renklendirme (§7.1)

| Status | Rozet rengi |
|--------|-------------|
| Not Rediscounted | 🟠 Turuncu |
| Processing | 🔵 Mavi |
| Not Reversed | 🟡 Sarı |
| Rediscounted | 🟢 Yeşil |
| Error | 🔴 Kırmızı |

### 4.9 Ürün entegrasyon kontrol listesi (§6.5)

Bir ürünün kapsama alınması için ürün ekibinin teslim edeceği **tam olarak 2 şey**:
1. § 6.2'deki 2 endpoint, § 6.4 sözleşmesine uygun biçimde ürün mikroservisinde.
2. Kolon konfigürasyon bloğu (`productGroup`, `product`, `baseUrl`, `columns`).

---

## 5. Sorumluluk Dağılımı (§4.5, §6.2)

| Katman | Sorumluluk |
|--------|-----------|
| **Base component (UI)** | Filtre + zorunlu alan doğrulaması · kolon config uygulaması · grid kurulumu · toplu seçim · onay akışı · isteklerin sözleşmeye uygun hazırlanması · sonuç ve hata gösterimi |
| **Ürün servisi (backend)** | Reeskonta uygun işlemlerin belirlenmesi · satır verisinin sözleşmeye uygun döndürülmesi · **durum belirleme** · işlemin yürütülmesi · **durum yeniden doğrulaması** |

> 🔴 **İş kurallarında nihai otorite ürün servisidir.** UI yalnız kullanıcı seçimini ve ekranda görünen durumu iletir.
> Bu, MM tarafındaki geliştirmenin **ağırlık merkezi** demek: durum türetme, valör hesabı, muhasebe, Fimple senkronu hep bizde.

---

## 6. Açık Sorular / Çelişkiler / Eksikler

> Numaralandırma kalıcı — sonraki turlarda bu kodlarla referans verilir.
> Durum: 🔴 karar bekliyor · 🟡 varsayımla ilerlenebilir · ✅ kapandı

### 6.1 Doküman içi çelişkiler (iş birimine sorulacak)

| # | Konu | Çelişki | Durum |
|---|------|---------|-------|
| **C-01** | **Execute Selected vs Generate/Regenerate** | Doküman **iki tasarım nesli** taşıyor. Eski nesil: §4.4 "tek ana aksiyon **Execute Selected**", §3.5 durum geçiş tablosu, §5.4, §8.2, §8.3 metni + **image4 & image7** (butonda "Execute selected", Status'te *"tek seçim — 'All' yok"* yazıyor). Yeni nesil: §4.6/§4.7 **Generate + Regenerate**, §5.3 "Status filtresine All eklenir", §8.1 + **image2/3/5/6**. Hangisi nihai? | 🔴 |
| **C-02** | **Product tekli mi çoklu mu?** | Metin (§1.2, §5.3, §6.4.1): "Product **tekli**, zorunlu" + "SubProduct **tekli**, zorunlu, boş gönderilemez". Ama **tüm görsellerde** `Product: Murabaha, FX Spot +1` = **çoklu**, ve grid'de aynı ekranda Murabaha + FX Spot + FX Fwd + FX Swap satırları karışık. Dahası: **görsellerde Sub Product filtresi hiç yok**. Görseldeki değerler (Murabaha, FX Spot) aslında **SubProduct** seviyesinde — yani mockup "SubProduct çoklu seçim, Product yok" davranıyor. | 🔴 |
| **C-03** | **Revaluation Type** | §1.2 "tekli seçim" ↔ §5.3 "Çoklu Seçim" ↔ §6.4.1 `RevaluationTypes (List)`. Ayrıca **değer kümesi hiç tanımlanmamış** — görselde "FX Mark-to-Market", "Interest Accrual" görünüyor. Bu liste nereden gelecek? Sabit enum mı, ürün servisinden mi? **Sözleşmede bu listeyi döndüren endpoint yok** (§6.2 "2 endpoint dışında uç tanımlanmaz"). | 🔴 |
| **C-04** | **Product/SubProduct listesi kaynağı** | §1.3: "Sub Product listeleri **ilgili ürün servisi** tarafından sağlanır." §5.5: "Product listesi **kolon konfigürasyonundan** çözülür." §6.2: "**2 endpoint dışında ek uç tanımlanmaz**." → SubProduct'ı ürün servisi verecek ama onu getirecek uç yok. Ya JSON config'e SubProduct listesi de yazılacak, ya 3. uç gerekli. | 🔴 |
| **C-05** | **Generate + Rediscounted satırı** | §4.6 Generate'i yalnız NotRediscounted (reeskont) ve NotReversed (ters fiş) için tanımlıyor. Grid `All` modunda Rediscounted satır da seçilebiliyor. Generate'te bu satıra ne olacak — sessizce atlanır mı, `Failed`'a "uygun değil" olarak mı düşer, yoksa Generate pasif mi olur? Onay penceresinde (image5) Rediscounted satırı hiç geçmiyor. | 🔴 |
| **C-06** | **Regenerate + Not Reversed = kaç fiş?** | image6: "Not Reversed → **önceki değerleme geri alınır**, yeni değerleme oluşturulur." NotReversed'ın ters fişi yok. Muhasebe olarak: (1) mevcut reeskonta iptal/ters fiş + (2) yeni reeskont T+0 + (3) yeni ters fiş T+1 = **3 fiş** mi? Yoksa mevcut reeskont soft-delete edilip 2 fiş mi? | 🔴 |
| **C-07** | **Asenkron mimari bölümü dokümandan düşmüş** | İçindekiler'de **"6.1 Asenkron İşlem Mimarisi"** yazıyor; gövdede §6.1 **"Teknoloji ve Yapı"** olmuş. Asenkron bölümü **yok**. Kritik: `executions` **senkron mu asenkron mu**? 248 kayıt seçilirse ürün servisi 248 kez Fimple'a senkron HTTP atarsa **timeout kesin**. `Processing` durumunun varlığı asenkron bir tasarım ima ediyor (kuyruk + polling / SignalR). Ama `ExecutionsResponse` `Succeeded[]`/`Failed[]` döndürüyor — bu **senkron** bir imza. | 🔴 |
| **C-08** | **`ExecutionsRequest` iki versiyon** | §6.4.3 (Liste A): `Status` + `ReverseValueDate` var, `Operation`/`ExecutionDate` yok. §6.4.4 altındaki genişletme (Liste B): `Operation` + `ExecutionDate` + `RegenerateToToday` var, **`Status` ve `ReverseValueDate` yok**. §4.2 hâlâ T+0/T+1 soruyor → `ReverseValueDate` kaybolmuş. Nihai birleşik model nedir? | 🔴 |
| **C-09** | **`Execution Date` zorunluluğu ve sınırları** | §6.4.1'de zorunlu işareti Product/SubProduct'ta var, ExecutionDate'te **yok**. Varsayılan **bugün** mü, **logical date** mi? Geçmiş tarih seçilebilir mi? Gelecek tarih engellenecek mi? İş günü kontrolü var mı? MM'de `MMLogicalDate` framework parametresi var — reeskont buna bağlı olmalı gibi. | 🔴 |
| **C-10** | **Select All ↔ sayfalama** | §5.4 "seçim **tüm veri kümesini** kapsar" (248 kayıt) ↔ §6.4.1 `Skip/Take` var. Kullanıcı "Select All" derse UI 248 `TransactionId`'yi nasıl bulacak? Tüm sayfaları mı çekecek (248 satır ağ trafiği), yoksa `executions`'a "filtre gönder, sen bul" mu diyecek? **Sözleşmede `SelectAll: bool` + filtre alanları yok**, yalnız `TransactionIds` var. | 🔴 |
| **C-11** | **Eşzamanlılık / kilit** | İki kullanıcı aynı transaction'a aynı anda Generate basarsa? §4.5 "ürün servisi durumu yeniden doğrular" diyor ama **lock / rowversion / optimistic concurrency** yok → çift fiş riski. FX'te bu sorun **zaten var**. | 🔴 |
| **C-12** | **`Error = 0` filtre olarak gönderilebilir mi?** | §6.4.1 Status enum'ında `Error = 0` var ↔ §3.4 "kalıcı bir Error durumu **veya Error filtresi bulunmaz**" ↔ §5.3 "Status: yalnız NotRediscounted/NotReversed/Rediscounted biri seçilebilir" (+ All). Backend `Status = Error` gelirse ne yapacak — boş liste mi, doğrulama hatası mı? | 🟡 |
| **C-13** | **`StatusDescription` dili / üretici** | §3.3 tablosunda Türkçe + parantez İngilizce; görsellerde Türkçe ("Reeskont kesilmeyi bekliyor."). Sözleşmede `StatusDescription` **backend'den** geliyor. Backend Türkçe metin dönerse **çoklu dil kırılır** (MicroUI'lerde localization JSON var). **Öneri:** backend `StatusCode` + `ReasonCode` dönsün, metni UI localize etsin. | 🔴 |
| **C-14** | **`Data` sözlüğünün yeri** | §6.4.2'de `Data` maddesi `Items`/`TotalCount` ile aynı seviyede listelenmiş. Satır bazlı mı (`ManuelReeskontItem.Data`) yoksa response kökünde mi? Mantıken satır bazlı ama netleştirilmeli. | 🟡 |
| **C-15** | **Kolon config'in fiziksel yeri ve sürümlenmesi** | §5.5 "UI tarafında tutulan JSON". Nerede — dosya (`wwwroot/config/*.json`), appsettings, DB? §5.5 "yeni ürünün kolonları için **servis tarafında** sürüm çıkılmasını gerektirmez" diyor — ama **UI tarafında sürüm çıkmayı gerektiriyor**. Bilinçli mi? Alternatif: config'i Common API'den servis etmek (deploy'suz ürün ekleme). | 🔴 |
| **C-16** | **MicroUI hiç geçmiyor** 🔴🔴 | Doküman monolit varsayımı üzerine kurulu: "ASP.NET MVC + jQuery + DevExtreme", Razor'a `@(Html.DevExtreme().ManuelReeskont()…)`. Ama MM artık **`Treasy.MM.UI` MicroUI**'de. Base component hem monolit `NetTrex.Web.UI`'de hem MicroUI'lerde çalışacaksa **NuGet paketi (RCL: view + static asset + TagHelper) olmak zorunda**. Ayrıca `Html.DevExtreme()` extension'ına ekleme yapmak DevExtreme namespace'ine yazmak demek. **Bu benim en büyük mimari sorum.** | 🔴 |
| **C-17** | **Hata gösterim biçimi çelişkisi** | §3.1 + §5.1: hata **Status Description kolonunda** gösterilir. image1 notu: *"the error is shown as a brief notification (**no status, no column**)"*. Diyagram eski tasarımdan kalmış görünüyor. | 🟡 |
| **C-18** | **Yetki granülaritesi** | §9 yetkiyi **3 ekran** bazında tanımlıyor. Ürün/SubProduct bazlı yetki gerekmiyor mu? Bir kullanıcı Treasury'ye erişip MM'i görebilsin ama FX'i görmesin senaryosu var mı? Ayrıca **aksiyon bazlı** yetki (görüntüleme ≠ fiş kesme) hiç geçmiyor — reeskont kesmek muhasebe etkisi olan bir işlem, salt-görüntüleme rolü olmalı gibi. | 🔴 |
| **C-19** | **Audit / iz kaydı** | Sözleşmede "**kim** tetikledi, **ne zaman**" alanı yok. Manuel fiş kesme muhasebe etkili bir işlem; kullanıcı + zaman + aksiyon (Generate/Regenerate) + valör seçimi kaydedilmeli. FX'te de **yok** (bilinen eksik). | 🔴 |

### 6.2 MM'e özel açık konular

| # | Konu | Durum |
|---|------|-------|
| **M-01** | MM'in değerlemesi FX gibi **MtM** değil, **faiz tahakkuku** (accrual). Doküman "tüm modüllerin reeskontu FX gibi T+0 fiş + T+1 ters fiş çalışır" varsayıyor. MM'de bu desen **var mı**? Yoksa MM'in `NotReversed` durumu iş anlamında **yeniden tasarım** gerektirir. | 🔴 (araştırılıyor) |
| **M-02** | MM'de `Murabaha` / `Wakala` SubProduct değerleri koda nasıl eşlenir (`ProductDefinition`? `TransactionCode`? enum?). Sözleşme **string** SubProduct gönderiyor — eşleme tablosu gerekli. | 🔴 (araştırılıyor) |
| **M-03** | MM'de `RevaluationType` karşılığı ne? Görselde "Interest Accrual" MM satırlarında görünüyor. MM'de birden fazla değerleme türü var mı? | 🔴 |
| **M-04** | `InterbankLoan` (TxnLoan) bu ekranda **ayrı SubProduct** mı, MM/Loan Transactions'ın içinde mi? Doküman "MM/**Loan** Transactions" diyor → ikisi birlikte. IL modülü **opsiyonel** (`InterbankLoan:Enabled`, kapalı müşteride tablo yok) → SubProduct listesi bu flag'e göre filtrelenmeli. | 🔴 |
| **M-05** | Fimple'a gidecek tutarlarda **hassasiyet/round kuralları** (CLAUDE.md Hard Rule 11) bu akışta hangi alanlara uygulanacak? | 🔴 |
| **M-06** | MM'in mevcut EOD revaluation batch'i ile bu manuel ekran **aynı kod yolunu** mu kullanacak (FX'te öyle: manuel ekran = batch'in satır bazlı manuel tetikleyicisi)? Kod tekrarı olmaması için tercih edilen bu. | 🟡 |

---

## 7. Mimari Değerlendirme

> Bu bölüm ayrı dosyada: [`02-mimari-karar.md`](02-mimari-karar.md)

---

## 8. Kaynak Dosyalar

| Ne | Yol |
|----|-----|
| Doküman (orijinal) | `.ai-agent/imports/Manuel Reeskont v1.docx` |
| Doküman (düz metin, dönüştürülmüş) | scratchpad `manuel-reeskont-v1.txt` (geçici) |
| Görseller | docx içi `word/media/image1..7.png` |
| Mevcut FX ekranı — kod analizi | [`../../NetTrex.MM/.ai-agent/feature-research/ManuelRevaluation/FxManuelRevaluation-Reeskont-research.md`](../../NetTrex.MM/.ai-agent/feature-research/ManuelRevaluation/FxManuelRevaluation-Reeskont-research.md) |
| Mevcut FX ekranı — iş birimi dokümanı | `../../NetTrex.MM/.ai-agent/feature-research/ManuelRevaluation/2026-07-27-ManuelRevaluation-IsBirimi-Dokumani.md` |
| Mevcut FX ekranı — teknik kod analizi | `../../NetTrex.MM/.ai-agent/feature-research/ManuelRevaluation/2026-07-27-ManuelRevaluation-Teknik-Kod-Analizi.md` |

### 8.1 Görsel envanteri

| Görsel | İçerik | Hangi tasarım nesli |
|--------|--------|---------------------|
| image1 | Status Flow diyagramı (İngilizce) | Eski (Execute/notification) |
| image2 | Genel görünüm: `All` + durum özeti + **Generate/Regenerate** | **Yeni** |
| image3 | Karışık Revaluation Type → **Generate pasif** | **Yeni** |
| image4 | Not Reversed → **Ters Fiş Valörü Seç** popup (T+1/T+0) · butonda "Execute selected" | Karma |
| image5 | **Generate — Onay** penceresi | **Yeni** |
| image6 | **Regenerate — Onay** penceresi (durum bazlı özet) | **Yeni** |
| image7 | İşlem sonucu: 2 başarılı + 2 Error aynı grid'de · butonda "Execute selected" | Karma |
