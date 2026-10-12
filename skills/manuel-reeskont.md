# Skill — manuel-reeskont

**Ne zaman tetiklenir:** Manuel Reeskont geliştirmesiyle ilgili **her** istek — analiz, soru, sözleşme,
Web.UI base component, MM endpoint, kolon config, test.
Tetikleyici kelimeler: *manuel reeskont · manual rediscount · reeskont ekranı · base component ·
eligible-transactions · executions · Generate/Regenerate · ters fiş ekranı · Investment/Security/Treasury ekranı*

**Tür:** Analiz + Kod · **Kapsam:** cross-repo — **Faz 1: `NetTrex.Web.UI` + `NetTrex.MM`**

> 🔴 **MİMARİ v2 (2026-08-12) — `NetTrex.Common` KULLANILMIYOR.**
> Ekran WebUI'da, **WebUI Controller/service'ten modül API'lerine (MM · Fx · FI · InvFund) DİREKT**.
> Önceki v1 kararı (Common'da DailyFlow V2 tarzı fan-out) **İPTAL** → `ADR-MR-015`.
> **Faz 3'e kadar `NetTrex.Common`, `Treasy.MicroUI.Packages` ve MicroUI projelerine DOKUNMA.**
> Kullanıcının sözü: *"Common yok — MicroUI projeleri yok — package projesi yok şimdilik."*

> 📝 **Kod yorumu ve yanıt formatı kuralı (2026-09-22, sıkılaştırıldı 2026-09-29):** `PROJECT_CONTEXT.md` § 10'u
> oku — varsayılan yorum YOK, gerekirse tek satır NEDEN; `<summary>`/emoji yok; **"PO isteği / PO kararı / (PO tarih)"
> gibi iş kararı referansları koda ASLA yazılmaz** (progress/MD'ye yazılır). Ajan prompt'larına bu kural eklenir.
> Yanıtlarda kullanılan teknik açıklanır.

---

## ADIM 0 — Bağlamı yükle (ATLAMA)

Bu skill tetiklendiğinde **kod yazmadan önce** şunları oku:

| # | Dosya | Neden |
|---|-------|-------|
| 1 | `repos/.ai-agent/manuel-reeskont/00-PANO.md` | Şu an neredeyiz, ne bloke |
| 2 | `repos/.ai-agent/manuel-reeskont/progress/` → **en büyük numaralı** | Yapılanlar/Yapılıyor/Yapılacaklar |
| 2b | 🔵 `repos/.ai-agent/compacts/<chat-slug>/` → **en büyük numaralı** `compact-N.md` | **Kullanıcının kendi kelimeleriyle ne istediği**, verdiği kararlar ve **gerekçeleri**, çıkan hataların aynı metni. `progress/` *ne yapıldığını*, compact *neden öyle yapıldığını* söyler. **Yeni oturumda veya sıkıştırma sonrasında ATLAMA** |
| 2c | 🔵 `repos/.ai-agent/sql-log/<chat-slug>/` (varsa) | Daha önce DB'ye hangi soru soruldu, ne çıktı — **aynı sorguyu tekrar çalıştırma** |
| 3 | ⭐ `repos/.ai-agent/manuel-reeskont/05-faz-plani.md` | **İŞ EMRİ** — 6 faz, 58 iş kalemi (`İ-xx`), A/B bağımlılık matrisi, Definition of Done. **Hangi işi yapacağını buradan seç**, kendin uydurma |
| 4 | `repos/.ai-agent/manuel-reeskont/02-mimari-karar.md` | 18 ADR — **mimariyi yeniden tartışma**. § 0 = v1→v2 değişiklik kaydı |
| 5 | İlgili katmanın dosyası (aşağıdaki tabloya bak) | |

**İş bittiğinde `05-faz-plani.md` § 11 durum tablosunu güncelle** (tamamlanan/toplam).
Kod yazarken bilinmeyen bir karar varsayıldıysa `// VARSAYIM: <soru-kodu>` yorumu bırak (`R-15`).

| İstek şu katmanı ilgilendiriyorsa | Ek olarak oku |
|-----------------------------------|---------------|
| İş kuralı / doküman sorusu | `01-dokuman-analizi.md` (§3 aksiyon matrisi, §6 çelişkiler) |
| **Web.UI base component** | `analiz/analiz-6-webui-base-component-desenleri.md` (**en önemli** — desen nesilleri, `ajax.js`, `settings.baseUrl`, eski ekranın 10 kusuru) + `NetTrex.Web.UI/.ai-agent/PROJECT_CONTEXT.md` |
| **Web.UI'den modüllere fan-out** | `analiz/analiz-6` § 6 (Refit marker tablosu + `Startup.cs:58-75`) |
| MM backend | `03-mm-backend-envanteri.md` (§8 hazır↔yazılacak, §9 tuzaklar) + `NetTrex.MM/.ai-agent/PROJECT_CONTEXT.md` |
| **Fimple çağrısı / fiş / ters fiş / muhasebe** | ⭐ `07-fimple-entegrasyon.md` — baseline uç (`/Fx/TreasuryTransactions/DoAccounting`), gerçek payload'lar, `FT-01`…`FT-06` tuzakları, `Ö-01`…`Ö-09` alternatif API önerileri. **Fimple'a giden kod yazmadan ÖNCE oku** |
| Grid/filtre/ViewComponent emsali | `analiz/analiz-5-dailyflow-ui.md` (§D grid, §F ViewComponent) — ⚠️ **fan-out kısmı geçersiz**, yalnız UI deseni için |
| Faz 3 pakete taşıma | `analiz/analiz-1-microui-shell-paketler.md` (§B paketten ekran çıkma) |
| Bir soru/karar gerekiyorsa | `04-sorular.md` — **zaten sorulmuş mu, cevaplanmış mı?** |

---

## ADIM 1 — Sözleşme dondurulmuş mu? (KAPI)

```text
06-sozlesme.md var mı ve "DONDURULDU" işaretli mi?
   HAYIR → Kod YAZMA. Kullanıcıya 04-sorular.md § BLOKE EDENLER'i göster, cevap iste.
   EVET  → ADIM 2'ye geç.
```

> ✅ **2026-08-13 itibarıyla `06-sozlesme.md` DONDURULDU — KAPI AÇIK, kod yazılabilir.**
> **Kod yazmadan önce `06-sozlesme.md`'yi OKU** — request/response modelleri, enum'lar, `Data` sözlüğü
> kuralları, aksiyon×durum matrisi, validator kuralları, kolon config şeması **orada kesinleşti**.
> Modelleri kendin uydurma; sözleşmeden **birebir** yaz (`R-11` sürüm sapması).
> Sözleşmeyi değiştirmen gerekirse: önce `06`'yı güncelle → `02-mimari-karar.md`'ye ADR → etkilenen repoları listele.

**Sözleşmede kesinleşen ve sık unutulan 6 nokta:**

1. **Product tekil ⇒ her sorgu TEK modüle gider.** Çoklu modül fan-out'u normal akışta **yok** (`R-13` kapandı).
2. **`Status` filtresi tekil, `null` = All.** `All` bir **row status değil** — filtre değeridir.
3. **`MessageKey` UI'ye GİTMEZ** (mevcut FX ekranı gönderiyor — kusur, tekrarlanmıyor).
4. **`ReverseValueDate` sözleşmede VAR** — MM `FimpleAccountingService.cs:188-193`'te zaten parametrik.
5. **`SelectAll` YOK** — seçim her zaman açık `TransactionId` listesi, en fazla 200.
6. **`Failed` doluysa `IsSuccess = false`** — mevcut FX akışının en büyük hatası buydu.

**Bloke eden 4 soru** (bunlar cevapsızsa ekran baştan yazılır):

- **C-01** Execute Selected mi, Generate+Regenerate mi? `All` var mı?
  ⚠️ Kanıt: eski Fx ekranında `ManualRediscount.RediscountStatusTypes.**All**` **VAR** ve controller default'u o.
- **C-07** `executions` senkron mu asenkron mu?
- **C-08** `ExecutionsRequest` nihai modeli (`ReverseValueDate` nerede?)
- **C-02** Product tekli mi çoklu mu? Sub Product filtresi var mı?

> **İstisnalar — sözleşmeden bağımsız başlayabilir:**
> 1. **MM'in `eligible-transactions` sorgu tasarımı** (durum türetme mantığı, M-08).
> 2. `04-sorular.md` § B'deki **7 teknik kararın** araştırılması.
> 3. § 6'daki **F-13…F-18 doğrulamaları** (token, framework parametresi, timeout, okunmayan dosyalar).

---

## ADIM 2 — Hangi repoda çalışıyorum?

| Katman | Repo | Yol |
|--------|------|-----|
| **UI ekran + base component + fan-out** | `NetTrex.Web.UI` | `Code/Web/UI/Trex.WebUI/` — 3 controller `Controllers/ManuelReeskont/`, servis `Services/ManuelReeskont/`, bileşen `Views/Shared/Components/ManuelReeskont/`, JS `wwwroot/js/shared/components/manuel-reeskont/` |
| **MM endpoint'leri** | `NetTrex.MM` | `Code/Api/NetTrex.MM.Api{,.Services,.ResponseRequest}/ManuelReeskont/` |
| ~~Fan-out~~ | ~~`NetTrex.Common`~~ | ❌ **İŞ YOK** — `ADR-MR-015` |
| Faz 2 | `NetTrex.Fx` (+FI, InvFund) | 2 endpoint · Security/Investment ekranları |
| Faz 3 | `Treasy.MicroUI.Packages` | `Treasy.MicroUI.SharedDependency/Views/Shared/Components/` — **Faz 1'de DOKUNMA** |

🔴 **Cross-repo etki zinciri kuralı:** Sözleşmeye (endpoint/model/enum) dokunuyorsan, değişiklikten **önce** hangi
repoların etkilendiğini listele. v2'de sözleşme DTO'ları **Web.UI'de** yaşıyor ve her modül kendi kopyasını
tutuyor → bir alan eklemek **sessiz sürüm sapması** yaratır (`R-11`). `06-sozlesme.md` tek gerçek kaynaktır.

---

## ADIM 3 — Katman bazlı prosedür

### 3.A `NetTrex.Web.UI` — base component + 3 ekran + fan-out ⭐ (Faz 1'in ana işi)

#### 3.A.1 Önce oku (klonlanacak emsaller)

```text
wwwroot/js/shared/components/cashFlow/cashflow.component.js       ← İSKELET (class + deep-merge config)
wwwroot/js/shared/components/cashFlow/cashflow.context.js         ← state yönetimi
wwwroot/js/shared/components/limit-check/limit-check.constants.js ← prefix + enum/CssClass haritası
ViewComponents/LimitCheck/LimitCheckViewComponent.cs              ← modül parametreli ViewComponent
Views/Shared/Components/CashFlow/Default.cshtml                   ← (henüz okunmadı, F-17)
Controllers/ManuelReescont/ManuelRevaluationController.cs         ← ESKİ ekran: ne YAPILMAYACAĞI
Startup.cs:58-75                                                  ← Refit marker kayıtları
```

#### 3.A.2 Fan-out (modüllere direkt)

1. **Modül başına ince Refit interface** yaz — `Services/ManuelReeskont/`:
   `IManuelReeskontMmApi : IClientMMAPI` · `…FxApi : IClientFxAPI` · `…FiApi : IClientFiAPI` ·
   `…InvFundApi : IClientFundsAPI` (⚠️ **`Funds`**, `InvFund` değil).
   **DI kaydı / config key GEREKMEZ** — `RegisterClientWebApiRefitClients<T>` AppDomain'i tarar.
2. Modül seçimi **controller gövdesinde değil**, `IManuelReeskontModuleResolver` servisinde (`ADR-MR-018`) —
   3 controller aynı mantığı paylaşacak, Faz 3'te pakete taşınacak parça bu servis.
3. 🔴 **`Task.WhenAll` + MODÜL-BAŞINA `try/catch`** — çıplak `WhenAll` bir modül patlayınca **tüm isteği düşürür**.
   Kısmi hatalar response'a biriktirilir (`ADR-MR-008`).
4. 🔴 **Token durumu doğrulanmadı** (`F-13`) → `CurrentUserId`'yi modüle giden request body'sine **mutlaka koy**
   (`ADR-MR-012`). Motorlar `StateMaker`'ı kendisi yazıyor (`"SYSTEM"`/trader); kullanıcıyı yazmak motor context'ine
   `StateMaker` taşımayı gerektirir → sonraki faz. ChangeTracker aboneliğiyle damga yapma (progress-66'da geri alındı).
5. Aktif modül listesi: WebUI'de `IFrameworkParameterHelper` var → `General:AvailableModules` oradan okunabilir.
   ⚠️ **Doğrula** (`F-14`). `LimitCheckViewComponent` deseni: **parametre yoksa AKTİF kabul et**.
6. ⚠️ **`.ToContentExternal()` + `IsFailed()`** deseni yaygın ama `Load`'un **iki farklı şekil** döndürmesine yol
   açıyor (hata → obje, başarı → liste). **Tek tip response şekli** kullan.

#### 3.A.3 Controller & yetki

7. **3 ayrı controller** (`TreasuryReeskontController` / `SecurityReeskontController` /
   `InvestmentReeskontController`) — permission = `ControllerAdı/ActionAdı`. Tek generic controller yaparsan
   3 ekran **aynı** permission'ı paylaşır (`ADR-MR-003`, doküman §9 karşılanmaz).
8. **Mevcut `Controllers/ManuelReescont/`'a DOKUNMA** — yazım hatalı (`Reescont`), Fx'e hardwired,
   `namespace Trex.WebUI.Controllers.FX.Report`. Yeni klasör: `Controllers/ManuelReeskont/`.
   Eski ekranın silinip silinmeyeceği **C-20**'ye bağlı, iş birimi kararı.

#### 3.A.4 Base component (JS)

9. **Nesil 3 deseni** (`ADR-MR-016`): `class ManuelReeskontComponent`, `#private` field, **deep-merge config**,
   JSDoc `@typedef`, `settings.productGroup`, `dataSource.<op>.url` **override**, ayrı `Context` sınıfı.
   `paymentComponent.js` (nesil 1, tek dosya + global `const`) **model DEĞİL**.
10. Dosya bölümlemesi: `.component.js` · `.actions.js` · `.columns.js` · `.context.js` · `.constants.js` · `.endpoints.js`.
11. 🔴 **Sabitlere `MR_` prefix** ver — top-level `const` çakışması **tüm sayfayı SyntaxError ile çökertir**
    (Web.UI Hard Rule 4). `CLC_` limit-check'in, `CF_` cashflow'un.
12. **JS'i inline yazma** — eski ekranın hatası (`Views/ManuelReescont/Index.cshtml:127-298`).
13. 🔴 **`ajax.js`'in `get`/`post`'una satır-bazlı hata için güvenme** — `IsSuccess === false → null`
    (`ajax.js:20`, `:45`), grid **sessizce boşalır**. `executions` sonucunu (`Succeeded[]`/`Failed[]`) ham işle.
14. Status badge: `Object.freeze` enum + `CssClass` eşleme haritası (`limit-check.constants.js:39-73` deseni).
15. Para/oran formatı: **`DevExpress.localization.formatNumber`**, `toFixed` **değil**.
16. Localization: `.data-localization` + `data-localization-key` + `formatMessage`;
    `wwwroot/js/localization/pages/manuel-reeskont/manuel-reeskont-{tr,en}.json` — `tr` **gerçekten Türkçe** olsun.

#### 3.A.5 ViewComponent & Razor

17. **Tek** ViewComponent, `ProductGroup` parametresi alır (`LimitCheckViewComponent.model.Module` deseni).
18. Kolon config'i **sunucuda okuyup hidden alana bas** → ekstra roundtrip yok
    (`ApplyModuleParametersAsync` deseni). Alternatif `columns.url` config'te **hazır** bırakılır (C-15 / R-10).
19. **`AdvanceAndStateFilter` ViewComponent'ini yeniden kullan** (`ComponentConstants.cs:5`, 20+ view kullanıyor).
20. **Grid:** `Html.DevExtreme().DataGrid<T>().ToNetixDataGrid<T>(...)` + `.NetixDataSource(Model.GridModel, loadParams: ...)`.
    6 sabit kolon + kolon config'ten gelen ürüne özel kolonlar (`Data` sözlüğünden).
    ⚠️ **DevExtreme 22.2.6** — yeni sürüm API'si yok.
21. **`IsFirstLoad` guard'ı** — Product+SubProduct seçilmeden grid sorgulanmaz (doküman §5.3).
22. Filtreleri **`List<string>`** taşı; virgüllü string + `Split`/`Enum.Parse` **kullanma** (`ADR-MR-011`) —
    eski ekran bunu yapıyor ve geçersiz değerde **fırlatıyor** (`TryParse` yok).
23. **Server-side paging** (`Skip`/`Take`/`TotalCount`) — `ADR-MR-009`. Eski ekranda paging yok.

#### 3.A.6 Faz 3'ü ucuzlatan 4 kural (Faz 1'de uygula)

24. Component JS'i Web.UI global'lerine **fazladan** bağımlı olmasın (`settings`, `formatMessage`,
    `notifyError`, `get`/`post` dışına çıkma).
25. Endpoint yolları **config'ten** gelsin — hardcoded `/TreasuryReeskont/Load` yazma.
26. Razor bileşeni `Views/Shared/Components/` altında dursun (RCL'ye taşınabilir yol).
27. CSS + localization **ayrı dosyada**, inline değil.

### 3.B `NetTrex.MM` — 2 endpoint

1. **Motor yazma.** `IRevaluationAccountingService` (reeskont) + `IRevaluationReverseAccountingService` (ters fiş)
   tetiklenir. `NetTrex.MM.Api.csproj` → `Common.Services` referansı **var**, doğrudan inject edilebilir.
2. **`IFimpleAccountingService` `internal`** — API'den inject **edilemez**, servis üzerinden git.
3. `eligible-transactions` sorgusu: mevcut `GetPendingRevaluationTransactions` (`TransactionDataManager.cs:411`) **yetmez**
   (yalnız `NotRediscounted` + "aynı gün terslenmiş" veriyor, sayfalama yok). Yeni sorgu:
   4 durum türetme + `Skip`/`Take`/`TotalCount` + `Data` sözlüğü, **tek sorguda `LEFT JOIN` + projeksiyon**
   (FX'in N+1 hatasını tekrarlama).
4. **Ters fiş valörü:** `RevaluationReverseAccountingServiceContext.LogicalDate` = T+0 ise ExecutionDate,
   T+1 ise +1 iş günü. Factory satır 25'te `ValueDate = input.LogicalDate` yazıyor.
5. `ProductSourceType` ile MM↔IL dallanması (MM Hard Rule 4 / ADR-001) + `helper.GetIsEnabledInterbankLoanModule()`
   guard'ı (kapalı müşteride `TxnLoan` tablosu **yok**).
6. **Zorunlu düzeltmeler:**
   - `StateMaker` → `request.CurrentUserId`: motor değişikliği ister (`05_...ReverseStep.cs:32-33` `"SYSTEM"`) → sonraki faz
   - Çift-tıklama koruması — Fimple **idempotent değil** (`FimpleAccountingService.cs:281` her istekte yeni `Guid`)
   - Satır bazlı hata: `Succeeded[]` / `Failed[{TransactionId, LogicalReference, Reason}]`, **`IsSuccess = true` deme**
7. **Fimple hassasiyet/round kuralları** (workspace Hard Rule 4 · MM Hard Rule 11) — **oku ve uygula**.
8. Yeni entity/tablo gerekiyorsa `NetTrex.MM` `entity-creator` skill'ine delege et. Test → `test-writer`.
   ⚠️ MM'de `dotnet test` **çalışmaz** (xUnit v3 = MTP) — bin'deki exe'yi native argümanlarla koştur.
9. ⚠️ MM'de EF Core migration altyapısı **yok** — kolon/tablo değişimi idempotent `ALTER` SQL'i olarak
   `.ai-agent/outputs/`'a yazılır, kullanıcı uygular. Yeni kolon eklersen **History tablo + trigger** üçlü kontrolü.

### 3.C `NetTrex.Fx` ve diğer modüller (Faz 2)

Aynı 2 endpoint sözleşmesi. `NetTrex.Fx`'te mevcut `RediscountController` var — sözleşmeye uyarlanacak mı
yoksa yeni uç mu, **ve kim yazacak** → açık soru. FI/InvFund/OptFX/Deriv: **ürün ekipleri**.

### 3.D Faz 3 — `Treasy.MicroUI.Packages` (Faz 1'de DOKUNMA)

Razor+ViewComponent → `Treasy.MicroUI.SharedDependency/Views/Shared/Components/ManuelReeskont/`
+ csproj'a `<AdditionalFiles Include="..." />` · TS → `Treasy.MicroUI.Components/wwwroot/manuel-reeskont/`
→ `@treasy/components` · sürüm bump + Nexus publish.
Precedent: paketten **tam ekran** çıkıyor (`Views/Shared/Pages/Login/Index.cshtml`) + 10 DevExtreme grid'li bileşen.
⚠️ Bileşen içi caption'ları ekran bridge'ine hard-code bağlama (`CashFlow/Default.cshtml:9-10` tuzağı).
⚠️ `SharedDependency` sürümünü **csproj'dan** doğrula — MM.UI dokümanları bayat (1.0.3 yazıyor, gerçek 1.0.4-dev12).

---

## ADIM 4 — İş kuralı doğrulaması (kod yazarken)

**Aksiyon × Durum matrisi** — `01-dokuman-analizi.md` § 3.1'den, sözleşme dondurulunca oradan **teyit et**:

| Satır durumu | Generate | Regenerate |
|---|---|---|
| Not Rediscounted | Reeskont T+0 → `Not Reversed` | Önceki yok → yeni değerleme (T+0 + T+1) → `Rediscounted` |
| Not Reversed | Ters fiş (T+1 varsayılan / T+0 seçenek) → `Rediscounted` | Önceki geri al + yeni T+0 + T+1 → `Rediscounted` |
| Rediscounted | ⚠️ **C-05 açık** — atlanır mı, `Failed`'a mı düşer? | Geri al + yeniden değerle → `Rediscounted` |
| Processing / Error | Kapsam dışı | Kapsam dışı |

- ~~Generate, seçilenlerin tamamı aynı Revaluation Type değilse pasif (§4.6)~~ — kural UI'dan **bilerek kaldırıldı**.
- `Error` **kalıcı değil** — DB'ye yazılmaz, yalnız anlık UI.
- Backend **her satırın durumunu yeniden doğrular**; durumu değişeni işleme almaz (§4.5).

---

## ADIM 5 — İş bitince MD güncelle (ZORUNLU)

| Ne oldu | Nereye |
|---------|--------|
| **Her anlamlı iş** | `manuel-reeskont/progress/` → **YENİ numaralı** `progress-<N>.md` + `_index.md` satırı. Önceki dosyaları **asla düzenleme**. Öncekinin **güncellenmiş tam hali** olsun, 3 bölüm zorunlu |
| Durum/faz değişti | `manuel-reeskont/00-PANO.md` (üzerine yazılır) |
| **Yeni araştırma yapıldı** (ajanla **veya** doğrudan) | `manuel-reeskont/analiz/` → **YENİ numaralı** `analiz-<N>-<konu>.md`, çıktı **kısaltılmadan** + `_index.md` satırı |
| Soru cevaplandı / yeni soru çıktı | `manuel-reeskont/04-sorular.md` (Bölüm C'ye taşı, tarih koy) |
| Yeni ADR / mimari değişti | `manuel-reeskont/02-mimari-karar.md` § 3; cross-repo ise `repos/.ai-agent/PROJECT_CONTEXT.md` § 7 |
| Yeni tuzak / karar / tercih | cross-repo → `repos/.ai-agent/MEMORY.md` · **Web.UI'ye özel → `NetTrex.Web.UI/.ai-agent/MEMORY.md`** · MM'e özel → MM'in |
| Faz başladı/bitti | `manuel-reeskont/faz-docs/phase-N-*.md` |
| **Bağlam ~%70 / `/compact` / sıkıştırma sonrası ilk tur** | `repos/.ai-agent/compacts/<chat-slug>/compact-<n>.md` — klasör **var mı** bak, varsa **`n+1` yeni dosya**, yoksa klasör + `_chat.md` + `compact-1.md`. **Proaktif**, `/compact`'i bekleme |

---

## Gotcha — bu işte kanıtlanmış tuzaklar

| # | Tuzak |
|---|-------|
| G-01 | **Doküman iki tasarım nesli taşıyor.** "Execute Selected"lı bölümler/görseller **eski taslak**; diğer nesil Generate/Regenerate + `All`. Sözleşme dondurulmadan hangisine göre yazacağını **varsayma**. ⚠️ Ek kanıt: **eski Fx ekranında `RediscountStatusTypes.All` VAR** ve controller default'u o → "All var" tarafı güçlü |
| G-02 | ♻️ Dokümanın **`baseUrl` alanı kullanılmıyor** → **`moduleCode`** (`ADR-MR-002`). Sebep sadece tercih değil **teknik zorunluluk**: `settings.baseUrl` = `@Url.Content("~")` yani **uygulamanın kök yolu**, modül adresi değil. UI'den modül adresi vermek anlamsız |
| G-03 | Dokümanın istediği **`Skip`/`Take`** ve **`Data` dictionary** DailyFlow şablonunda **YOK** — bunlar **kasıtlı sapma** (`ADR-MR-009/010`). Emsali körü körüne kopyalama |
| G-04 | ♻️ Çıplak `Task.WhenAll` bir modül patlayınca **hepsini** düşürür → modül-başına `try/catch`. **Ve `ajax.js`'in `get`/`post`'u `IsSuccess === false` ise `null` döner → hata YUTULUR, grid sessizce boşalır** (`ajax.js:20`, `:45`) |
| G-05 | ♻️ **WebUI → modül çağrısında token taşınıyor mu belli değil** (`F-13`, doğrulanmadı) → `CurrentUserId` body'de gitmezse audit/`StateMaker` boş kalır. `CurrentUserId` her durumda güvenli |
| G-06 | MM'de Fimple **idempotent değil** → çift tıklama = **çift fiş + Fimple'a çift kayıt** |
| G-07 | `IFimpleAccountingService` **`internal`** — API katmanından inject edilemez |
| G-08 | MM'de `accEntryMain` hem `Transaction` hem `TransactionLoan`'a **aynı `TxnId` FK**'sıyla bağlı — `ProductSourceType` ile ayır |
| G-09 | Marker interface isimleri tutarsız: `IClientMMAPI` (çift M) · `IClientFundsAPI` (**Funds**, InvFund değil) · `IClientOptFXApi` / `IClientLimitApi` (küçük `Api`). Tip adını **dosya içinden** doğrula |
| G-10 | `Treasy.MM.UI` dokümanları SharedDependency **1.0.3** diyor, gerçek **1.0.4-dev12** — sürümü csproj'dan doğrula |
| G-11 | Enum drift: WebUI `ProductType` ↔ Common `DailyFlowProductType` aynı değil. Product/SubProduct **string** taşı |
| G-12 | **`Revaluation-research.md` bu iş DEĞİL** — o MM'in kendi EOD faiz tahakkuku araştırması. Karıştırma. Bu işin FX referansı: `FxManuelRevaluation-Reeskont-research.md` |
| G-13 ⭐ | 🔴 **`NetTrex.Common`'a KOD YAZMA.** v1 kararı iptal (`ADR-MR-015`). `analiz-4` ve `analiz-5`'teki Common fan-out bulguları **emsal/referans**; uygulanacak mimari **değil**. `02-mimari-karar.md` § 0'daki sürüm tablosuna bak |
| G-14 ⭐ | **Klasör adı tuzağı:** mevcut ekran `Controllers/ManuelReescont/` (**yazım hatalı**) + `namespace Trex.WebUI.Controllers.FX.Report`. Yeni kod `ManuelReeskont` (doğru yazım) klasörüne gider; **eskiye dokunulmaz**. Var olan bir dosyayı ararken yolu **klasörden değil namespace/using'lerden** tanı |
| G-15 ⭐ | **Top-level `const` çakışması tüm sayfayı çökertir** (SyntaxError). `MR_` prefix zorunlu. `function` redeclaration sorunsuz, `const` değil |
| G-16 ⭐ | `paymentComponent.js` kullanıcının emsal gösterdiği dosya ama **nesil 1** (tek dosya + global). İskelet **`cashFlow/`**'dan alınır (`ADR-MR-016`) — kullanıcıya bu tercih **açıklandı ve gerekçelendirildi** |
| G-17 ⭐ | Eski `Load` action'ı **iki farklı şekil** döndürüyor (hata → obje, başarı → liste). Tüketici JS için tutarsız → **tek tip response** kullan |
