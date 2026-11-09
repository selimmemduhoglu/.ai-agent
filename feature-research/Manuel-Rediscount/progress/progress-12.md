# progress-12 — ✅ DOKÜMAN UYUMLULUĞU TAMAMLANDI · 9 eksik kapandı · MM 74 + JS 34 test

**Tarih:** 2026-08-13 · **Önceki:** [progress-11.md](progress-11.md)
**Tetikleyen istek:** *"hepsini bitir. döküman ne diyorsa onu yap… dökümanda ki her şey doğru olmalı
ve dökümanda istenen şekilde olmalı. görseller için sen zaten buraya çıkarmıştın
`.ai-agent/imports/manuel-reeskont-gorseller` buradan incele ve hepsini tamamla"*
**Kural:** Bu dosya progress-11'in **devamı**dır. Öncekiler **düzenlenmedi**.

```text
=== MM ===
dotnet build Code\NetTrex.MM.sln                                    → Build succeeded
NetTrex.MM.Api.Services.Tests.exe -namespace "*ManuelReeskont*"     → Total: 74, Errors: 0, Failed: 0

=== Web.UI ===
dotnet build Code/Web/UI/Trex.WebUI/Trex.WebUI.csproj               → 0 Error(s)
npx jest --testPathPattern manuelReeskont                           → 34 passed
npx jest  (tüm suite)                                               → 368 passed  (regresyon yok)
```

🔴 **[09-dokuman-uyumluluk-raporu.md](../09-dokuman-uyumluluk-raporu.md)'daki 9 eksiğin TAMAMI kapatıldı.**
Rapor `§ 9`'da artık **kapanış tablosu** var; her madde satırının altına ✅ **KAPANDI** yazıldı.

---

## 1. MM tarafı

| Dosya | Ne yapıldı |
|---|---|
| `Data.Model/.../TDMRediscountEligibleResult.cs` | `ProductName` · `ExternalCustomerId` · `ExternalCustomerName` eklendi · `TDMRediscountEligiblePagedResult`'a **3 durum sayacı** |
| `Api.ResponseRequest/.../Response/EligibleTransactionsResponse.cs` | § 5.1 sabit kolon seti · **`ManuelReeskontStatusSummary`** · `CustomerName` **kaldırıldı** · `ValueDate` **`Data`'ya taşındı** |
| `Api.ResponseRequest/.../Request/EligibleTransactionsRequest.cs` | `SubProduct` **zorunlu** · `RevaluationTypes` (çoklu) · `ExtraFilters` |
| `Api.Services/.../EligibleTransactionsHandler.cs` | `ResolveStatusDescription` (§3.3 metinleri) · `Product` fallback · `RevaluationTypes` filtresi · `StatusSummary` |
| `Api.Services/.../EligibleTransactionsRequestValidator.cs` | `SubProduct` `NotEmpty` |
| `Api.ResponseRequest/.../Response/ExecutionsResponse.cs` | `ReeskontReasonCodes.OutOfScope` |
| `Api.Services/.../ExecutionsHandler.cs` | 🔴 **DAVRANIŞ HATASI DÜZELTİLDİ** (aşağıda § 3) |
| 3 test dosyası | 59 → **74 test** |

## 2. Web.UI tarafı

| Dosya | Ne yapıldı |
|---|---|
| `Models/ManuelReeskont/Res/EligibleTransactionsResponse.cs` | MM sözleşmesine hizalandı + `StatusSummary` |
| `Models/ManuelReeskont/Req/EligibleTransactionsRequest.cs` | `RevaluationTypes` · `ExtraFilters` · `SubProduct` zorunlu notu |
| `Controllers/ManuelReeskont/ReeskontControllerBase.cs` | `Load` yanıtına **`statusSummary`** · `GetStatuses()` **kaldırıldı** (liste artık JS'te, iki kaynak-tek gerçek riski) |
| `Models/Shared/Components/.../ManuelReeskontComponentViewModel.cs` | `Statuses` **kaldırıldı** |
| **YENİ** `Extensions/ManuelReeskont/ManuelReeskontBuilderExtensions.cs` | `Html.DevExtreme().ManuelReeskont().ProductGroup(...)` (§6.3) |
| `Views/ManuelReeskont/{Treasury,Security,Investment}/Index.cshtml` | 3 ekran doküman biçimine geçti |
| `Views/Shared/Components/ManuelReeskont/Default.cshtml` | Status SelectBox → **pill kabı** · `Revaluation Type` TagBox · özet şeridi · seçim menüsü · aksiyon ipucu · `SubProduct` `IsRequired` |
| `wwwroot/js/.../manuel-reeskont.constants.js` | **`MR_StatusPalette`** (doküman § 7.1) · `MR_StatusFilters` · `MR_SelectCounts` · `mrEscapeHtml` · `mrFormatMoney/Rate(value, format)` |
| `wwwroot/js/.../manuel-reeskont.columns.js` | § 5.2 kolon sırası · `mrNormalizeColumnConfig` (§5.5 adları + eski şema) · `order`/`alignment`/`format` · `mrWarnMissingDataKeys` |
| **YENİ** `wwwroot/js/.../manuel-reeskont.filters.js` | Pill filtre · özet şeridi · seçim özeti (image3) · `Select All / N / Custom` + `"N of M selected"` |
| `wwwroot/js/.../manuel-reeskont.actions.js` | Onay pencereleri **image5/image6'ya göre** yenilendi · `mrCountByStatus` · kalıcı ipucu |
| `wwwroot/js/.../manuel-reeskont.component.js` | `selectLoaded`/`selectFirst` · `#syncRevaluationTypes` · `SubProduct` zorunlu guard'ı · özet/seçim bilgisi · eksik anahtar uyarısı |
| **YENİ** `wwwroot/js/.../manuel-reeskont.init.js` | `ManuelReeskont.init({ productGroup })` (§6.3) |
| `wwwroot/css/.../manuel-reeskont.css` | Pill · özet şeridi · onay penceresi · pastel rozet |
| `wwwroot/js/config/manuel-reeskont/{treasury,security,investment}.json` | § 5.5 alan adları · `order` · `ValueDate` · `revaluationTypes` |
| `localization/.../manuel-reeskont-{tr,en}.json` | ~35 yeni anahtar |
| **YENİ** `UnitTest/Trex.WebUI.Tests/JSTests/manuelReeskontComponent.test.js` | **34 jest testi** |

---

## 3. 🔴 Bulunan davranış hatası — `Regenerate` + `NotRediscounted`

**image6 ne diyor:** `Not Rediscounted` satırlar için *"Önceki değerleme bulunmadığından **yeni
değerleme oluşturulur**"*.

**Kod ne yapıyordu:** `NOT_REDISCOUNTED` reason code'u ile **fail** ediyordu
(*"Geri alınacak bir reeskont fişi yok"*).

**Düzeltme** (`ExecutionsHandler.RegenerateAsync`):

```csharp
if (status is RediscountStatus.Processing or RediscountStatus.Error)
    return Fail(item, ReeskontReasonCodes.OutOfScope,
        $"'{status}' durumundaki kayıtlar Regenerate kapsamı dışında bırakılır.");

// Ters alınmamış fiş varsa önce onu nötrle (Rediscounted ise zaten nötr,
// NotRediscounted ise nötrlenecek bir şey yok — doğrudan yeni değerleme).
if (status == RediscountStatus.NotReversed)
    await CreateReverseAsync(existing!, reverseValueDate, currentUserId, cancellationToken);
```

`Processing`/`Error` için `STATUS_CHANGED` yerine **`OUT_OF_SCOPE`**: § 4.6 *"kapsam dışında bırakılır"*
diyor — kapsam dışı olmak **durum değişikliği değildir**, kullanıcıya yanlış sebep gösterilmemeli.

⚠️ **Dürüst not:** MM'de `Processing`/`Error` DB türetmesinden **hiç çıkmaz** (`ReverseId` null/0/>0 →
3 değer). Bu dal **savunma amaçlı**; gerçek filtreleme UI tarafında. Bu yüzden o dal için
"ulaşılamayan davranışı test eden" bir test **yazmadım**, gerekçeyi test dosyasının XML doc'una yazdım.

---

## 4. Kararlar

| Karar | Alternatif | Neden |
|---|---|---|
| `ValueDate` sabit kolon değil → `Data` | Top-level property bırak | § 5.1 zorunlu kolon listesinde **yok**; sabit set dokümanla birebir olmalı |
| Status filtresi **pill**, dropdown değil | SelectBox koru | image2/image3 pill gösteriyor; `All` dahil **tekil seçim** → sözleşme § 5 ile de tutarlı |
| Status listesi yalnız **JS'te** | Controller'da da tut | İki kaynak-tek gerçek: liste iki yerde olursa biri bayatlar |
| Kolon config'de **eski şema da kabul** | Yalnız yeni adlar | Config dosyaları ürün ekiplerinde; hepsi aynı anda güncellenemez |
| `Revaluation Type` listesi **config'den** | 3. endpoint aç | § 6.2 *"2 endpoint dışında uç tanımlanmaz"* (`C-03`) |
| `Select All` = **yüklü satırlar** + uyarı | Tüm veri kümesi | Sözleşme § 12 — görülmeyen satıra fiş kesme riski. Sessiz kısıtlama yerine **uyarı** |
| `Html.DevExtreme().ManuelReeskont()` **reflection** ile | Yalnız `Component.InvokeAsync` | Doküman § 6.3 bu biçimi istiyor; DevExtreme `IHtmlHelper`'ı public açmıyor. Framework'te aynı desen var (`DevxReflectionExtension.cs`). Çözülemezse **açıklayıcı exception** (sessiz boş içerik değil) |
| `mrEscapeHtml` eklendi | Ham `innerHTML` | Müşteri adı/referans DB'den geliyor ve `innerHTML`'e basılıyor → DOM enjeksiyonu kapatıldı |

---

## 5. Açık kalanlar (kod tarafında iş YOK)

| # | Ne | Kim |
|---|---|---|
| 1 | Menü + permission SQL scriptleri (`outputs/`) uygulanacak | **Selim** |
| 2 | Tarayıcı testi — [`08-test-rehberi.md`](../08-test-rehberi.md) ~40 madde (+ yeni: pill, özet şeridi, onay pencereleri, `Select All / N`, indeterminate checkbox) | **Selim** |
| 3 | Faz 2 **gerçek fiş** testi — Fimple'a yazar, geri alınamaz | **onay bekliyor** |
| 4 | Faz 4 MicroUI'ye taşıma | *"ben deyince"* |
| 5 | Fx / FI / InvFund modül uçları | modül sahipleri |
| 6 | Fimple ekibine sorular `Ö-S-01…08` | **Selim** |
| 7 | `C-20` eski FX ekranı ne olacak | **Selim** |
| 8 | Faz 3 tutar önizlemesi (doküman fazı) | kapsam dışı, sonraya |

**Yeni açık (araç):** `NetTrex.MM/.claude/settings.local.json` içindeki **PreCompact hook'u şema hatası
veriyor** — `hookSpecificOutput.additionalContext` PreCompact şemasında yok:
`Hook JSON output validation failed — (root): Invalid input`. Hatırlatma hiç basılmıyor;
komut yalnız `systemMessage` basacak şekilde düzeltilmeli.
