# progress-6 — 🟢 FAZ 1 KODLANDI (okuma yolu uçtan uca)

**Tarih:** 2026-08-13 · **Önceki:** [progress-5.md](progress-5.md)
**Tetikleyen istek:** *"Faz 1'i kodla."*
**Kural:** Bu dosya progress-5'in **güncellenmiş tam hali**dir. Öncekiler **düzenlenmedi**.

**Sonuç:** ✅ `NetTrex.MM` **Build succeeded** · ✅ `NetTrex.Web.UI` **Build succeeded**

---

## ✅ YAPILDI — Faz 1 (İ-10…İ-45)

### A. `NetTrex.MM` — okuma ucu (İ-10…İ-14)

| İş | Dosya | Not |
|---|---|---|
| İ-11 | `Data.Model/Managers/Transaction/TDMRediscountEligibleResult.cs` **(YENİ)** | Projeksiyon record'u + `TDMRediscountEligiblePagedResult` |
| İ-11 | `Data.Abstractions/.../ITransactionDataManager.cs` | `GetRediscountEligibleTransactionsAsync(...)` eklendi |
| İ-11 | `Data/Managers/Transaction/TransactionDataManager.cs` | **Tek sorgu**, durum türetmeli, sayfalı — N+1 yok |
| İ-10 | `Api.ResponseRequest/ManuelReeskont/ManuelReeskontEnums.cs` **(YENİ)** | `RediscountStatus`, `RediscountOperation` |
| İ-10 | `Api.ResponseRequest/ManuelReeskont/{Request,Response}/` **(YENİ)** | Sözleşme § 3.1 / § 3.2 birebir |
| İ-12 | `Api.Services/ManuelReeskont/Handlers/EligibleTransactionsHandler.cs` **(YENİ)** | Durum türetme + `Data` sözlüğü + SubProduct eşleme |
| İ-12 | `Api.Services/ManuelReeskont/Validators/EligibleTransactionsRequestValidator.cs` **(YENİ)** | Sözleşme § 10 |
| İ-13 | `Api/Controllers/ManuelReeskont/ManuelReeskontController.cs` **(YENİ)** | `POST api/manuel-reeskont/eligible-transactions` |

**Sorgunun çekirdeği (M-08 canlı veriden doğrulanmıştı):**

```csharp
RediscountReverseId = x.AccountingMainEntries
    .Where(a => a.Type == revaluationType && !a.IsReverse && a.ValueDate == executionDate)
    .OrderByDescending(a => a.Id)
    .Select(a => (int?)a.ReverseId)
    .FirstOrDefault();
// null → NotRediscounted · 0 → NotReversed · >0 → Rediscounted
```

**Uygunluk filtresi mevcut EOD sorgusuyla BİREBİR aynı** (`GetPendingRevaluationTransactions`)
→ ekran ile batch **aynı işlem kümesini** görür.

### B. `NetTrex.Web.UI` — sunucu katmanı (İ-20…İ-27)

| İş | Dosya |
|---|---|
| İ-23 | `Trex.Web.Business.Models/Models/ManuelReeskont/{ManuelReeskontEnums,Req,Res}` **(YENİ)** — modül DTO'ları ile birebir |
| İ-20 | `Services/ManuelReeskont/IManuelReeskontMmApi.cs` **(YENİ)** — `: IClientMMAPI`, **DI kaydı gerekmez** |
| İ-21 | `Services/ManuelReeskont/IManuelReeskontModuleResolver.cs` + `ManuelReeskontModuleResolver.cs` **(YENİ)** |
| İ-22 | `Services/ManuelReeskont/ManuelReeskontQueryService.cs` **(YENİ)** |
| İ-24 | `Controllers/ManuelReeskont/TreasuryReeskontController.cs` **(YENİ)** |
| — | `Startup.cs` — 3 servis DI kaydı (adaptör + resolver + query service) |

### C. `NetTrex.Web.UI` — ViewComponent & Razor (İ-30…İ-36)

| İş | Dosya |
|---|---|
| İ-31 | `Models/Shared/Components/ManuelReeskont/ManuelReeskontComponentViewModel.cs` **(YENİ)** |
| İ-30 | `ViewComponents/ManuelReeskont/ManuelReeskontViewComponent.cs` **(YENİ)** — kolon config'i **sunucuda okur, hidden alana basar** |
| İ-32 | `Views/Shared/Components/ManuelReeskont/Default.cshtml` **(YENİ)** — 4 filtre + boş toolbar + grid |
| İ-33 | `Views/ManuelReeskont/Treasury/Index.cshtml` **(YENİ)** — sadece `Component.InvokeAsync` |
| İ-35 | `wwwroot/css/shared/components/manuel-reeskont.css` **(YENİ)** |
| İ-36 | `wwwroot/js/localization/pages/manuel-reeskont/manuel-reeskont-{tr,en}.json` **(YENİ)** — `tr` gerçekten Türkçe |

### D. Base component — 6 JS dosyası (İ-40…İ-45)

```text
wwwroot/js/shared/components/manuel-reeskont/
├── manuel-reeskont.constants.js   MR_ prefix'li selector + Status enum + renk/localization haritası
├── manuel-reeskont.endpoints.js   $.ajax DOĞRUDAN (ajax.js hata yutmasın)
├── manuel-reeskont.context.js     state kabı (cashflow.context.js deseni)
├── manuel-reeskont.columns.js     6 sabit kolon + Data sözlüğünden ürüne özel kolonlar
├── manuel-reeskont.actions.js     Faz 2 iskeleti — actions map'i boş, toolbar üretilmiyor
└── manuel-reeskont.component.js   class + #private + deep-merge config + server-side paging
```

`wwwroot/js/config/manuel-reeskont/treasury.json` **(YENİ)** — MM/Loan Transactions, 2 SubProduct, 12 kolon.

---

## Sözleşmeye uyum — kritik noktalar

| Sözleşme kuralı | Nasıl uygulandı |
|---|---|
| Product **tekil** ⇒ tek modül | `SelectBox` (tekil) · `moduleCode` ürün config'inden · query service'te **fan-out YOK** |
| Server-side paging (`ADR-MR-009`) | `CustomStore` + `remoteOperations.paging` + `TotalCount` |
| `Status` tekil, `null` = All | `All` seçeneğinin **değeri boş**; `mrIsEmpty` → `null` |
| `MessageKey` UI'ye **gitmez** | Ne DTO'da ne kolonlarda var |
| `Data` sözlüğü | `Dictionary<string, object>` + `dataField: "Data.{field}"` |
| **Tek tip response şekli** | `Load` her durumda `{data, totalCount, isSuccess, message}` döner |
| Hata **yutulmaz** | `ajax.js` yerine `$.ajax` doğrudan; `isSuccess === false` → `notifyError` |
| `MR_` prefix | Tüm top-level sabitler |
| Faz 3 taşınabilirlik | Endpoint config'ten (`dataSource.load.url`), Razor `Views/Shared/Components/`'ta, CSS+localization ayrı dosyada |

---

## Karşılaşılan hatalar ve çözümleri

| Hata (aynen) | Kök neden | Çözüm |
|---|---|---|
| `'TxnMmEntity' does not contain a definition for 'CashFlows'` | Emsal aldığım `GetPendingRevaluationTransactions` gövdesi **`TransactionLoanDataManager`**'ınmış; MM'de faiz dönemi `CashFlows` değil **`Details`** üzerinden | `x.Details.Any(w => !w.IsPrincipalAmount && w.PeriodStartDate <= date && w.PeriodEndDate > date)` |
| `The type or namespace name 'BaseFlowResponse' could not be found` | `using Netix.Core.Flow.Model.Dto` eksik | eklendi |
| `cannot convert from 'string' to 'Netix.Core.ResponseRequest.Message'` | `Messages` `List<Message>`; string kabul etmiyor | `new() { Text, MessageType, MessageCode }` (JobCron handler deseni) |
| `'decimal' does not contain a definition for 'RoundAwayFromZero'` | `using NetTrex.MM.Common.Core.Extensions` eksik | eklendi |
| `The type or namespace name 'IClientMMAPI' could not be found` | Marker `Trex.WebUI.Services.Abstract`'ta (`Trex.FrameworkCommon.Api`'de değil) | using düzeltildi |
| `Cannot implicitly convert type 'ResponseOf<T>' to 'T'` | `ToContentExternal()` **`ResponseOf<T>`** döner | `external.IsFailed()` + `external.Data` |
| `'ResponseOf<T>' does not contain a definition for 'Message'` | `Message` `ResponseOf` üzerinde değil, **`Data`** üzerinde | `external?.Data?.Message` |

---

## 🔵 YAPILIYOR

Yok.

---

## ⬜ YAPILACAK

### Faz 1 — kalan doğrulama

| # | İş |
|---|---|
| 1 | 🔴 **Uçtan uca çalıştırma testi** — MM API + Web.UI ayağa kaldırılıp `/TreasuryReeskont` açılacak (`05-faz-plani.md` § 3.5 Definition of Done listesi) |
| 2 | Yetki kaydı: `TreasuryReeskont/Index` · `/Load` permission'ları tanımlanmalı (yoksa ekran açılmaz) |
| 3 | Menü kaydı — menü `NetTrex.Common`'da script ile üretiliyor, MM/Web.UI buna dokunmuyor |
| 4 | İ-15 xUnit v3 testi (⚠️ `dotnet test` çalışmaz — bin'deki exe + native argüman) |
| 5 | `F-14` aktif modül parametresi · `F-16` Refit timeout doğrulaması |

### Faz 2 (aksiyonlar) — `İ-50`…`İ-68`

Sözleşme § 4 + § 9 kesin. `actions` map'i, onay pencereleri, `executions` ucu, Fimple baseline (`İ-65`),
çift-tıklama guard'ı (`İ-59`), `StateMaker` düzeltmesi (`İ-60` — **canlıda `SYSTEM` olduğu doğrulandı**).

### Dışarıdan cevap bekleyenler (**kodu bloke etmiyor**)

`Ö-S-01…08` (Fimple) · `Ö-04`/`Ö-05` (muhasebe) · `C-20` (eski ekran) · `İ-71` (Fx uçlarını kim yazacak).

---

## Kararlar bu turda

| Karar | Gerekçe |
|---|---|
| Kolon config **ProductGroup başına tek dosya** (`treasury.json`), içinde ürün dizisi | Ürün eklemek dosya eklemeyi gerektirmesin; ViewComponent tek dosya okur |
| Grid'de **sıralama kapalı** (ürüne özel kolonlarda) | Sıralama sunucuda değil; türetilmiş alanda client-side sıralama sayfalı veride **yanıltır** |
| `ajax.js` yerine **doğrudan `$.ajax`** | `IsSuccess === false → null` hatayı yutuyor, grid sessizce boşalıyordu |
| Config dosyası yoksa bileşen **çökmez**, 6 sabit kolonla açılır | `LimitCheck`'in "parametre yoksa aktif kabul et" doktriniyle aynı hat |
| Faz 1'de `selection` **açık** ama aksiyon yok | `R-14`: aksiyon eklenince grid/seçim varsayımı kırılmasın |
