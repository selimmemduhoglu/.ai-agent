# progress-33 — Fimple hata gövdesi, kaybolan başlıklar, Regenerate valör sorusu

**Tarih:** 2026-08-20 (aynı gün, `progress-32`'nin ardından)
**Tetikleyen:** İkinci tarayıcı testi — 3 satır `Error`, başlıklar kayıp

---

## 1. 🔴 `Error parsing NaN value` — gerçek Fimple hatası gizleniyordu

**Kullanıcının gördüğü:**

```
Newtonsoft.Json.JsonReaderException
Message=Error parsing NaN value. Path '', line 1, position 1.
   at NetTrex.MM.Common.Services.Extensions.RefitExtension.GetFimpleContentOrThrowAsync<T>
   in RefitExtension.cs:line 31
```

Gridde 3 satır: *"Generate — External system error — Failed to parse…"*

### Sebep zinciri

`RefitExtension.cs:30-31` — HTTP **başarısız** olduğunda hata gövdesini **koşulsuz** JSON sanıyordu:

```csharp
if (apiResponse.Error?.Content is not null && apiResponse.Error.Content.Length > 0)
    responseContent = JsonConvert.DeserializeObject<FimpleResponseBase<T>>(apiResponse.Error.Content);
```

Fimple/gateway düz metin döndürünce (`Not Found`, `No route…`, HTML sayfası) Newtonsoft ilk
karakter **`N`**'yi görüp `NaN` parse etmeye çalışıyor → `Error parsing NaN value … position 1`.

Sonra satır 61'deki `catch (JsonException)` bunu
`ExternalApiException("Failed to parse the API response…")` diye sarıyor.

🔴 **Asıl zarar:** HTTP durum kodu ve gövde **hiçbir yere yazılmıyor**. Kullanıcı *"parse
edemedim"* görüyor, oysa gerçek olay *"Fimple 404 döndü"* olabilir. Yani bu bir parse hatası
değil, **teşhis kaybı**.

### Çözüm

`LooksLikeJson` guard + hata mesajına **durum kodu ve gövde**:

```csharp
if (!LooksLikeJson(errorBody))
    throw new ExternalApiException(
        $"Fimple returned a non-JSON error response. HTTP {(int)apiResponse.StatusCode} " +
        $"({apiResponse.StatusCode}). Body: {Truncate(errorBody, 500)}");
```

`catch (JsonException)` mesajına da `ex.Message` eklendi — gerçekten bozuk JSON gelirse
parser'ın ne dediği görünsün.

### ⚠️ Ne DEĞİŞMEDİ

- JSON hata gövdesi yolu **aynı** (Fimple'ın normal `{ "Success": false, "Reasons": […] }` yanıtı)
- Başarılı yanıt yolu **aynı**
- Yeni exception **tipi yok** — hâlâ `ExternalApiException`, çağıranlar etkilenmiyor

Yani değişen tek şey **hata mesajının içeriği**. `RefitExtension` paylaşılan bir dosya ama
dokunulan yer yalnızca **hata yolu** ve müdahale teşhis kaybını gideriyor.

### 🔵 Sırada: gerçek sebep

Bir sonraki denemede mesaj artık şunu yazacak:
`Fimple returned a non-JSON error response. HTTP 404 (NotFound). Body: …`

Muhtemel adaylar (`MEMORY.md`'deki emsal): deploy edilmiş Fimple ucu kaynaktan geri kalmış,
adres/route yanlış, gateway araya girmiş. Durum kodu görülünce ayrışacak.

---

## 2. 🔴 Kolon başlıkları kayboldu — sebebi `columnFixing`

`progress-32`'de grid'e eklediğim `columnFixing: { enabled: true }` başlıkları **sildi**.

**Mekanizma:** kolon sabitleme açık olunca DevExtreme ayrı bir `.dx-datagrid-content-fixed`
tablosu üretiyor. **Hiçbir kolon sabitlenmemişken** bu tablonun başlık hücreleri **boş** kalıyor
ve gerçek başlığın üstünü örtüyor. Kullanıcının ekran görüntüsündeki tablo tam bu:
**seçim checkbox'ı görünüyor** (o sabit tabloda), **kolon adları görünmüyor**.

### Geri alınanlar

| Ayar | Neden geri alındı |
|---|---|
| `columnFixing: { enabled: true }` | 🔴 **başlıkları örtüyordu** |
| `rowAlternationEnabled: true` | kullanıcı beğenmedi: *"bir satırı koyu diğerini açık yapmışsın, bu böyle olmasın"* |
| `allowColumnResizing` · `columnResizingMode` · `columnMinWidth` · `wordWrapEnabled` | aynı turda eklendiği için şüpheliydi; gerek de yok |
| CSS `.dx-datagrid-headers … td` kuralı | hizalama zaten `columns.js`'ten geliyor; paylaşılan tema sınıfına dokunmamak daha güvenli |
| CSS `td[style*="text-align: right"]` | kırılgan — DevExtreme'in inline style bastığına güvenmek sürüm değişiminde sessizce kopar |

Grid ayarları tekrar **tam olarak eski üç satır**: `showBorders` · `columnAutoWidth` ·
`hoverStateEnabled`.

### 🔑 Ders (MEMORY'ye yazıldı)

Grid'e **aynı turda birden çok davranış ayarı eklenmez** — hangisinin kırdığı tarayıcıda tek
tek denenmeden anlaşılmıyor. Bu turda 6 ayar birlikte gitti, biri ekranı bozdu ve hepsini geri
almak gerekti.

### Korunanlar (kullanıcının asıl istediği)

Kolon **hizalamaları** (`columns.js`) ve **rozet genişliği** duruyor — bunlar grid option değil,
kolon tanımı ve CSS. Başlık kaybıyla ilgileri yok.

---

## 3. Aksiyon ipucu grid'i kaydırmıyor

**Kullanıcı:** *"birden fazla farklı statülü transaction seçince Generate için uyarı veriyor ama
bu UI'daki yapıyı bozup yazıyı koymak için grid'i aşağı kaydırıyor, ben grid'in bozulmasını
istemiyorum."*

`.mr-action-hint` grid'in üstünde **kendi satırındaydı** ve `display:none` → görünür geçişinde
grid aşağı kayıyordu. Ayrıca iki `display:block` span (gerekçe + sonuç) satırı iki katına
çıkarıyordu.

**Çözüm:** ipucu **özet şeridinin içine** alındı:

```html
<div class="mr-summary-row">
    <div class="mr-summary"     id="mrSummary_…"></div>
    <div class="mr-action-hint" id="mrActionHint_…"></div>   <!-- margin-left:auto -->
</div>
```

- Metin **tek satır** (`.mr-hint-reason` / `.mr-hint-effect` → `display: inline`)
- Satırın yüksekliğini **soldaki özet** belirliyor → ipucunun görünüp kaybolması hiçbir şeyi kaydırmıyor
- Dar ekranda `text-overflow: ellipsis`, tam metin `title` attribute'unda

⚠️ İkisi **ayrı kap**: `mrRenderSelectionSummary` özeti `.html()` ile komple değiştiriyor —
aynı kabın içinde olsalar ipucu her seçim değişiminde silinirdi.

---

## 4. 🔴 `D-12` — Regenerate de ters fiş valörünü soruyor

**Kullanıcı:** *"dokümana göre ben Regenerate'e bastığım zaman tersini hangi tarihe kesmek
istediğimi bana sorması gerekmiyor muydu, bunun için popup açmayacak mıydın, ben mi dokümanı
yanlış yorumladım?"*

### Dokümanın dediği

| Yer | Ne diyor |
|---|---|
| § 8.2 + image4 | Soru **`Not Reversed`** durumuna bağlı: *"3 Not Reversed satır için ters fiş hangi valörle kesilsin?"* · *"Diğer durumlarda seçim sorulmaz"* |
| § 4.3 | Regenerate'te *"ters fiş kaydı **T+1 valörü ile** yeniden oluşturulur"* → valör **sabit** |

Yani **doküman harfi harfine okununca Regenerate'te sorulmuyor** — kullanıcı yanlış yorumlamadı,
doküman iki yerde farklı yerden bakıyor.

### Ama kullanıcının mantığı tutarlı

Regenerate **her satır için** yeni bir T+0 reeskont **ve tersini** kesiyor. Yani ters fiş
kesiliyorsa valörünün sorulması doğal. Doküman burada kendi kuralını (§ 8.2 *"ters fiş kesilecekse
sor"*) Regenerate'e uygulamamış.

### Uygulanan kural

**Ters fiş kesilecekse sorulur.**

| Aksiyon | Sorulur mu |
|---|---|
| **Generate** | Yalnız seçimde `Not Reversed` satır varsa (§ 8.2 — değişmedi) |
| **Regenerate** | 🔴 **HER ZAMAN** (yeni) |

Varsayılan **T+1** kaldığı için hiçbir şey seçmeden onaylayan kullanıcı **dokümanın davranışını**
alır. Popup metni Regenerate'te farklı: *"N kayıt yeniden değerlenecek — yeni ters fiş hangi
valörle kesilsin?"* (`mr-rvt-LeadRegenerate`, iki dile eklendi).

### ⚠️ Backend'de değişiklik GEREKMEDİ

`ResolveReverseValueDateAsync` valörü istekten **bir kez** çözüp `RegenerateAsync`'e geçiriyor
(`ExecutionsHandler.cs:337`, `:359`). Yani T+0 seçimi Regenerate'te **zaten** onurlandırılıyordu —
ekran sadece sormuyordu. `06-sozlesme.md`'de değişiklik yok.

---

## 5. Doğrulama

| Ne | Sonuç |
|---|---|
| `dotnet build NetTrex.MM.Common.Services` | **0 Error** |
| `dotnet build Trex.WebUI` | **0 Error** |
| MM testleri | **190 / 0 hata** |
| JS testleri | **344/344** |
| Grid option taraması | `columnFixing` / `rowAlternation` / … → **temiz** (yalnız yorumda tarihsel not) |
