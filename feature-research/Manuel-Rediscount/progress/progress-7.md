# progress-7 — 🟢 FAZ 2 KODLANDI (aksiyonlar & yazma yolu)

**Tarih:** 2026-08-13 · **Önceki:** [progress-6.md](progress-6.md)
**Tetikleyen istek:** *"Faz 2'ye geç"*
**Kural:** Bu dosya progress-6'nın **güncellenmiş tam hali**dir. Öncekiler **düzenlenmedi**.

**Sonuç:** ✅ `NetTrex.MM` **Build succeeded** · ✅ `NetTrex.Web.UI` **Build succeeded**

---

## ✅ YAPILDI — Faz 2 (İ-50…İ-65)

### A. `NetTrex.MM` — altyapı

| İş | Dosya | Ne |
|---|---|---|
| — | `Data.Abstractions/.../IAccountingDataManager.cs` + impl | **`GetRevaluationByValueDateAsync(txnId, valueDate)`** — hem durum türetme hem ters fiş girdileri (`Id`/`LogicalReference`/`BusinessKey`/`MessageKey`) tek çağrıda |
| **İ-60** | `RevaluationReverseAccountingServiceContext` · `…PipelineContext` · `…PipelineContextMapper` · `05_RevaluationReverseAccountingReverseStep` | 🔴 **`T-01` DÜZELTİLDİ** — ters fişin `StateMaker`'ı artık gerçek kullanıcı |

**`T-01` fix'i nasıl güvenli yapıldı:** Ters fiş pipeline'ı **batch ile ortaktır** (MM Hard Rule 10).
Bu yüzden `StateMaker` **opsiyonel parametre** (`string? StateMaker = null`) olarak eklendi:

```csharp
var stateMaker = string.IsNullOrWhiteSpace(stepContext.PipelineContext.StateMaker)
    ? "SYSTEM"                                  // batch → davranış DEĞİŞMEDİ
    : stepContext.PipelineContext.StateMaker;   // manuel ekran → gerçek kullanıcı
```

Mapster `MapWith` **positional** yazıldı (Hard Rule 5 — named argument CS0853 verir).

### B. `NetTrex.MM` — `executions` ucu

| İş | Dosya |
|---|---|
| **İ-57** | `Api.ResponseRequest/ManuelReeskont/Request/ExecutionsRequest.cs` **(YENİ)** + `Response/ExecutionsResponse.cs` **(YENİ)** (+ `ReeskontReasonCodes`) |
| **İ-57** | `Api.Services/ManuelReeskont/Handlers/ExecutionsHandler.cs` **(YENİ)** — aksiyon×durum matrisi |
| **İ-57** | `Api.Services/ManuelReeskont/Validators/ExecutionsRequestValidator.cs` **(YENİ)** |
| **İ-57** | `Api/Controllers/ManuelReeskont/ManuelReeskontController.cs` — `POST api/manuel-reeskont/executions` |

**Uygulanan matris (sözleşme § 9):**

| Durum | Generate | Regenerate |
|---|---|---|
| `NotRediscounted` | T+0 fiş → `NotReversed` | ❌ `NOT_REDISCOUNTED` |
| `NotReversed` | T+1 ters fiş → `Rediscounted` | ters fiş + yeni T+0 + yeni ters → `Rediscounted` |
| `Rediscounted` | ❌ `ALREADY_REDISCOUNTED` (**C-05**) | yeni T+0 + yeni ters → `Rediscounted` |
| `Error`/`Processing` | ❌ `STATUS_CHANGED` | ❌ `STATUS_CHANGED` |

**Handler'ın 5 kritik davranışı:**

1. **Motor yazılmadı** (`ADR-MR-005`) — `IRevaluationAccountingService` + `IRevaluationReverseAccountingService` tetikleniyor → ekran ile EOD batch **aynı kod yolu**
2. **Durum yeniden doğrulanıyor** (doküman §4.5) — UI'nin gördüğü `CurrentStatus` ≠ DB → `STATUS_CHANGED` (yarış koşulu koruması)
3. **Satırlar sırayla**, her biri kendi `try/catch`'inde (`ADR-MR-007`) — paralel değil, çünkü **Fimple idempotent değil**
4. **Çift-tıklama guard'ı** (`İ-59`) — `ConcurrentDictionary` ile in-flight kilit. ⚠️ **Yalnız process içi**; çok pod'lu ortamda korumaz → gerçek çözüm Fimple idempotency (`Ö-08`, `Ö-S-03` soruldu)
5. **`IsSuccess = Failed.Count == 0`** — "başarılı" yalanı yok

### C. `NetTrex.Web.UI` — sunucu

| İş | Dosya |
|---|---|
| **İ-56** | `Models/ManuelReeskont/{Req/ExecutionsRequest,Res/ExecutionsResponse}.cs` **(YENİ)** — MM ile birebir |
| **İ-56** | `Services/ManuelReeskont/IManuelReeskontMmApi.cs` — `Executions` Refit metodu |
| **İ-56** | `IManuelReeskontModuleResolver.cs` + `ManuelReeskontModuleResolver.cs` — `ExecutionsAsync` |
| **İ-56** | `ManuelReeskontQueryService.cs` — `ExecuteAsync` + `FailedExecution` |
| **İ-56** | `Controllers/ManuelReeskont/TreasuryReeskontController.cs` — `POST Execute` |

### D. `NetTrex.Web.UI` — aksiyon UI

| İş | Dosya |
|---|---|
| **İ-50** | `manuel-reeskont.actions.js` — **yeniden yazıldı**: varsayılan Generate/Regenerate seti, toolbar üretimi, seçim bazlı aktiflik, **çalışırken kilit** |
| **İ-51** | aynı dosya — `mrConfirmExecution` onay penceresi (kaç satır · T+0 valörü · T+1 valörü) |
| **İ-52** | `Default.cshtml` — **Ters Fiş Valörü** DateBox'ı (varsayılan T+0 + 1 gün) |
| **İ-56** | `manuel-reeskont.endpoints.js` — `mrExecute` · `manuel-reeskont.component.js` — `execute(operation)` |
| — | `mrShowExecutionResult` — **satır bazlı sonuç**: başarılılar toast, başarısızlar **sebebiyle** liste hâlinde |
| — | localization tr/en — 8 `ReasonCode` + aksiyon/onay metinleri · CSS — onay + hata listesi |

---

## ⚠️ Uygulanamayan bir doküman kuralı — açık kalem

**Doküman §4.6:** *"Generate, seçilenlerin tamamı aynı Revaluation Type değilse pasif."*

🔴 **Sözleşmede `RevaluationType` alanı YOK** — ne `ManuelReeskontItem`'da ne kolon config'inde.
Uydurmadım; kural **uygulanmadı** ve açık kalem olarak kaydedildi.

**Seçenekler (karar gerekiyor):**

1. `ManuelReeskontItem`'a `RevaluationType` eklenir (sözleşme değişikliği → `R-11` etki zinciri)
2. Kuralın MM için karşılığı yoksa **iş birimine sorulur** (FX'e özel bir kavram olabilir)
3. `SubProduct` uniformity'si proxy olarak kullanılır — ⚠️ **aynı şey değil**, önermiyorum

---

## Karşılaşılan hata

Faz 2'de **derleme hatası çıkmadı** — Faz 1'de öğrenilen desenler (Message yapısı, `ToContentExternal` →
`ResponseOf<T>`, marker namespace'i) doğrudan uygulandı.

---

## 🔵 YAPILIYOR

Yok.

---

## ⬜ YAPILACAK

### Kod bitti — kalan ortam/doğrulama işleri

| # | İş |
|---|---|
| 1 | 🔴 **Uçtan uca test** — MM API + Web.UI ayağa kalkacak, `/TreasuryReeskont` üzerinden Generate → T+0 fişi `AccEntryMain`'de, Regenerate → ters + yeni fiş doğrulanacak |
| 2 | 🔴 **`StateMaker` doğrulaması** — manuel ters fişte artık gerçek kullanıcı yazıyor mu (`mssql-read` ile son 20 satır) |
| 3 | Permission kaydı: `TreasuryReeskont/Index` · `/Load` · `/Execute` |
| 4 | İ-15 xUnit v3 testleri (handler matrisi için birim test) |
| 5 | `Ö-08` idempotency — Fimple cevabı gelince (`Ö-S-03`) process-içi guard'ın üstüne konacak |
| 6 | §4.6 `RevaluationType` kararı (yukarıdaki açık kalem) |

### Faz 3 — diğer modüller & 2 ekran (`İ-70`…`İ-76`)

`IManuelReeskontFxApi`/`FiApi`/`InvFundApi` + adaptörler (resolver **değişmeyecek**) ·
`SecurityReeskontController` + `InvestmentReeskontController` · `RegenerateToToday`.

### Faz 4 — pakete taşıma (`İ-80`…`İ-83`)

Faz 1-2'de 4 taşınabilirlik kuralına uyuldu: endpoint config'ten (`dataSource.load.url` / `.execute.url`),
Razor `Views/Shared/Components/`'ta, CSS + localization ayrı dosyada, JS yalnız `settings`/`formatMessage`/
`notifyError`/`$.ajax`'a bağımlı.

---

## Kararlar bu turda

| Karar | Gerekçe |
|---|---|
| `StateMaker` **opsiyonel parametre** ile geçirildi | Ters fiş pipeline'ı batch ile ortak (Hard Rule 10) — batch davranışı **değişmemeli** |
| Satırlar **sırayla** işleniyor (paralel değil) | Fimple idempotent değil; paralel çağrı çift fiş riskini büyütür |
| Çift-tıklama guard'ı **process-içi** | Cluster-safe değil ve **öyle olduğu iddia edilmiyor**; gerçek çözüm Fimple idempotency |
| `ReverseValueDate` UI'dan **açık** gönderiliyor | Backend varsayılanı `+1 gün` (takvim servisi çağrılmıyor) — ⚠️ iş günü kaydırması UI'da |
| §4.6 kuralı **uygulanmadı**, açık kalem yazıldı | Sözleşmede `RevaluationType` yok — uydurmak yerine sormak |
| `actions: null` → varsayılan set · `{}` → salt-okunur | Faz 3'te başka tüketici (MicroUI) toolbar'sız kullanmak isteyebilir |
