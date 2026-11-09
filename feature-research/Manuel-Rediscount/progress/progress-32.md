# progress-32 — İlk tarayıcı testi: log gürültüsü + ekran düzeni

**Tarih:** 2026-08-20
**Tetikleyen:** Kullanıcının ilk canlı testi (ekran görüntüsü: karanlık tema, 8 kayıt, `Not Rediscounted`)

---

## 1. `JsonReaderException` — debug'da sürekli düşen exception

**Kullanıcının gördüğü:**

```
System.Text.Json.JsonReaderException
Message='c' is an invalid start of a value. LineNumber: 0 | BytePositionInLine: 0.
   at NetTrex.MM.Common.Services.Handlers.ExternalHttpLoggingDelegateHandler.PrettyPrint(String json)
   in ExternalHttpLoggingDelegateHandler.cs:line 79
```

### Sebep

`ExternalHttpLoggingDelegateHandler` **her** giden HTTP isteğinin gövdesini loglarken
`PrettyPrint` → `JsonDocument.Parse` çağırıyor. Ama gövde her zaman JSON **değil**:
Fimple'ın token ucu `application/x-www-form-urlencoded` gönderiyor —
`FimpleAuthService.cs:29-32`:

```
client_id=…&client_secret=…&grant_type=client_credentials
```

İlk karakter **`c`** → `System.Text.Json` konumu 0'da reddediyor. `'c'` harfi tam olarak
`client_id`'nin ilk harfi.

### Neden "çok" alındı

Manuel Reeskont **satır başına** Fimple'a gidiyor → token isteği de sıklaşıyor. Her token
isteğinde bir exception atılıyor.

### Neden aslında bir hata değildi

`PrettyPrint` ve `StripVerboseFields`'ın **ikisinde de `try/catch` vardı** ve `catch` gövdeyi
ham döndürüyordu. Yani log doğru yazılıyordu, akış bozulmuyordu. Kullanıcının gördüğü şey
**first-chance exception** — Visual Studio yakalanan exception'ı da gösteriyor.

### Çözüm

Parse etmeden **önce** JSON'a benziyor mu bak:

```csharp
private static bool LooksLikeJson(string? body)
{
    if (string.IsNullOrWhiteSpace(body)) return false;
    var trimmed = body.AsSpan().TrimStart();
    return trimmed.Length > 0 && (trimmed[0] == '{' || trimmed[0] == '[');
}
```

`PrettyPrint` ve `StripVerboseFields` başında guard. **Çıktı değişmiyor** — JSON olmayan gövde
eskiden de ham dönüyordu; tek fark exception'ın hiç atılmaması. `try/catch` blokları **duruyor**
(bozuk JSON hâlâ mümkün).

### 🟥 Aynı yerde bulunan, DOKUNULMAYAN güvenlik sorunu

`PrettyPrint` başarısız olunca gövdeyi **ham** logluyor → token isteğinin `client_secret`'ı
**düz metin olarak log'a yazılıyor**. Bu bugüne kadar da böyleydi (guard bunu değiştirmedi).

**Değiştirmedim** çünkü handler MM'deki **tüm** Fimple çağrılarının log'unu üretiyor ve
maskeleme log içeriğini herkes için değiştirir — 2026-08-19 kuralı (*"paylaşılan dosyaya
davranış değiştiren dokunuş yok"*) gereği kullanıcı kararı. Hazır yama kullanıcıya sunuldu.

---

## 2. Ekran düzeni — kullanıcının 4 maddesi

| # | İstek | Ne yapıldı |
|---|---|---|
| 1 | *"Generate ve Regenerate neden Status butonlarının tam hizasında değil de biraz altında sağda kalmış"* | Toolbar `.mr-toolbar-row`'dan çıkarılıp **`.mr-status-bar` içine** alındı; `margin-left: auto` ile sağa yapışıyor. `.mr-toolbar-row` kabı ve CSS kuralı silindi. `flex-wrap: nowrap` → dar ekranda butonlar tekrar alt satıra düşmesin |
| 2 | *"kolon içlerindeki yazı ortalansın ve tiplerine bak"* | Tip → hizalama kuralı tablolaştırıldı: kısa kod/referans/tarih → **center**, tutar/oran → **right**, serbest metin (müşteri adı, açıklama) → **left**. 🔴 `Status` için hizalama **açık yazılmak zorundaydı**: alan `int` olduğu için DevExtreme `number` sayıp başlığı sağa yaslıyordu (ekran görüntüsünde "Status" başlığının sağa kaçmasının sebebi) |
| 3 | *"status içindeki statüsler biraz daha güzel durabilir, hücresini full kaplamış"* | Rozet `<div>` → `<span>`, CSS'te `width: 160px` → `min-width: 112px` + `padding: 3px 14px` + `white-space: nowrap`. Genişlik artık **içeriğe göre**; hücrede ortalanması kolonun `alignment: "center"` ayarından geliyor |
| 4 | *"ReverseType atomic falan yazıyor, bu atomic-EOD-BOD durumlarının bir önemi yok, ekranda da gözükmesin"* | Aşağıda — `D-11` |

### Ek grid ayarları (*"normal ekranlara bak ve daha güzel gözükmesi için ayarlar mısın"*)

| Ayar | Neden |
|---|---|
| `rowAlternationEnabled: true` | 13+ kolonlu gridde göz kayıyor |
| `wordWrapEnabled: false` | hücre iki satıra bölünmesin, satır yükseklikleri eşit kalsın |
| `columnMinWidth: 70` | `columnAutoWidth` ile kolonların ezilmesini önler |
| `columnFixing` + `allowColumnResizing` | yatay kaydırırken kimlik kolonları sabitlenebilsin |
| CSS: hücre `vertical-align: middle`, `padding: 7px` | dikey ortalama + eşit satır yüksekliği |
| CSS: `font-variant-numeric: tabular-nums` | referans ve tutar kolonlarında basamaklar alt alta |
| CSS: `.dx-command-select { text-align:center }` | seçim kutusu kolonu ortalı |

⚠️ Tüm CSS `.mr-container` ile daraltıldı — aynı sayfadaki başka grid'ler etkilenmiyor.

---

## 3. 🔴 `D-11` — Revaluation Type ekrandan tamamen kalktı

**Kullanıcı:** *"bir de sistemde ReverseType atomic falan yazıyor, bu atomic-EOD-BOD durumlarının
bir önemi yok, bu durumlara bakıyorsan gerek yok ve ekranda da gözükmesin."*

Değer MM'de **global bir framework parametresinden** geliyor
(`EligibleTransactionsHandler.ResolveRevaluationType` → `Revaluation:MM.ReverseType` →
`1=Eod / 2=Bod / 3=Atomic`), yani **tüm satırlarda aynı**. Sonuç: filtre tek değerli, şerit hep
`Atomic` yazıyor, § 4.6 kapısı hiç tetiklenmiyor.

### Kalkanlar

| Katman | Ne kalktı |
|---|---|
| `Default.cshtml` | `Revaluation Type` TagBox filtresi · form `ColCount(4)` → **`(3)`** |
| `component.js` | `#syncRevaluationTypes` · `#currentRevaluationTypes` · 2 çağrı yeri · istekteki `RevaluationTypes` |
| `actions.js` | `mrIsSingleRevaluationType` **fonksiyonu** + § 4.6 kapısı + "karışık Revaluation Type" ipucu satırı |
| `filters.js` | seçim özetindeki `Revaluation Type: Atomic` kırılımı |
| `constants.js` | `MR_REVALUATION_TYPE` |
| localization ×2 | `mr-filter-RevaluationType` · `mr-warn-MixedRevaluationType` (103 → **101** anahtar) |
| testler | `mrIsSingleRevaluationType` bloğu (5 test) + `EXPORTED` girdisi |

### Yerine gelen

Seçim özeti şeridi artık **durum kırılımı** gösteriyor:
`Seçili 5 kayıt — 4 Not Rediscounted · 1 Rediscounted (karışık)`

Gerekçe: kullanıcının `D-10` kapısı (karışık statü → Generate pasif) için **doğrudan işe yarayan**
bilgi bu. `(karışık)` turuncu ve kalın → butonun pasifleşeceğinin ön haberi.
Durum **overlay'den** okunuyor (`mrEffectiveStatus`) — aynı turda işlenmiş satırın gerçek durumu
grid verisinde değil overlay'de.

### ⚠️ Sözleşmeye etkisi

**Yok.** `RevaluationTypes` alanı sözleşmede **duruyor**; UI artık doldurmuyor.
`EligibleTransactionsHandler.cs:96` koşulu `Count: > 0` olduğu için gönderilmeyince filtre
uygulanmıyor. Modülde **kod değişmedi** — doğrudan çağıranlar (Swagger/betik) için davranış aynı.

🟥 Ama o bloğun kendisi bir mayın: koşul tuttuğunda `items = []` yapıp `TotalCount`'u ayrı
hesaplıyor → **"özet N diyor ama liste boş"** sınıfı bir tutarsızlık üretebilir. UI artık
tetiklemiyor; temizliği kullanıcı onayına bırakıldı.

---

## 4. Doğrulama

| Ne | Sonuç |
|---|---|
| `dotnet build NetTrex.MM.Common.Services` | **0 Error** |
| `dotnet build Trex.WebUI` | **0 Error** |
| MM testleri (`.exe`, xunit.v3) | **190 / 0 hata** |
| JS testleri | **344/344** — 1 test kırıldı (eski `left` hizalaması), yeni kurala göre yazıldı, üstüne **4 yeni** hizalama testi eklendi |
| Sarkan referans taraması | temiz (yalnız yorumlarda tarihsel atıf) |
