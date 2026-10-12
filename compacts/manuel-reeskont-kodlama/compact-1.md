# Compact — Manuel Reeskont · kodlama · #1

**Sohbet:** Manuel Reeskont — kodlama (Faz 1–3) · **Session id:** `4bedf830-dc64-4a25-922a-6dd86ca8e2be`
**Tarih:** 2026-08-13 · **Sıra:** bu sohbetin 1. compact'i
**Kapsanan aralık:** sohbetin başı (mimari v2 talimatı) → doküman uyumluluk raporu + 9 eksiğin kapatılmaya başlanması
**Aktif iş dosyası:** [manuel-reeskont/progress/progress-11.md](../../manuel-reeskont/progress/progress-11.md)
**Uyumluluk raporu:** [09-dokuman-uyumluluk-raporu.md](../../manuel-reeskont/09-dokuman-uyumluluk-raporu.md)

---

## 1. Kullanıcının istekleri (sırayla, kendi kelimeleriyle)

1. **Mimari v2 dayatması:** *"WebUI'da base component'imiz olacak ve Controller'dan backend projelerine
   istekler gönderilecek… **bu mimaride Common projesine ihtiyacımız yok**… Common projesini hiçbir
   şekilde kullanmayacağız."* Fazlar: (1) WebUI+MM, (2) diğer modüller, (3) `Treasy.MicroUI.Packages`.
   Referans desenler: `paymentComponent.js`, Limit entegrasyonu ViewComponent'leri, `wwwroot/js/shared`.
   *"Common yok - MicroUI projeleri yok - package projesi yok şimdilik"*
2. **Compact'ler diske, sohbet başına klasör:** *"her compact yaptığım zaman compact çıktısını da bu md
   dosyasına yaz… istisnasız hepsinin… geriye dönük bu dosyalarda görmek istiyorum… bunu titizlikle md
   dosyalarında her seferinde çalışacak şekilde entegre et."*
3. **Web.UI MD katmanı:** genel katman yetmiyorsa *"MM ve MMMicroUI projesinde ki gibi aynı mantıkta"* kur.
4. *"Faz 1'i kodla."*
5. *"Faz 2'ye geç"*
6. *"Şimdi ekranı ayağa kaldır ve Faz 1 ve Faz 2'yi test et sonra da hata çıkarsa ayıkla ve sonra da Faz 3'e geç"*
7. *"Faz 1 ve 2 testi için araştırma ve yaptıklarını bir md dosyasına yaz ben tüm fazlar bittikten sonra
   sana browser üzerinden test yaptıracam"* → sonra Faz 3.
8. **Kapsam daraltma:** *"NetTrexFx uçlarını ve MM dışındakileri modül sahipleri yazar sen MM'dekileri yaz şimdilik"*
9. **SQL görünürlüğü:** connection string verildi (`192.168.10.211` / `NetTrexMM`), *"sen select sorguları at
   ve bağlan"*, *"Accounting için NetTrexAcc'ye bağlanıp tabloları incelemen lazım"*.
10. **DB kapsam düzeltmesi:** *"sen NetTrexMM ve NetTrexAcc'ye bağlan Fx'e değil biz MM modülünü yazıyoruz"*
    (mevcut manuel reeskont ekranını örnek almak için NetTrexFx'e bakılabilir).
11. **MicroUI ertelendi + accounting skill:** *"bu microUI işini yapma sonra ben deyince yapacaksın… sen her
    öğrendiğin accounting bilgisini bir md dosyasına yaz ve **accounting Db script adında skill**'inde olsun."*
    3 script klasörü verildi → *"scriptlerin ne işe yaradıklarını öğren… hangi tablolar ne işe yarıyor öğren"*.
12. **Kalan işler:** *"murabaha ve wakala için de tabi ki OnRevaluation var **tüm ürünler için var**…
    **Permission kayıtlarını da yaz.** Birim testleri sonra yazarız. **Açık kalem işlerini de bitir.**"*
13. **Meta soru (kritik):** *"ben sana her bir şey geliştir veya fix yaz dediğimde kodu değiştirince
    **ilgili unit testlerini de gözden geçiriyorsun di mi bu çok önemli**"* → cevap: evet, ama yazılı kural
    değildi → **Hard Rule** olarak yazıldı.
14. *"Unit testleri de yaz ve bitir. MM projesinde."*
15. **Uyumluluk denetimi:** git changes'a bak + ilk `Manuel Reeskont v1.docx`'i **tekrar oku** ve
    *"o dökümanda istenen her şeyin tamamiyle yapıldığını açıkla… **madde madde**"*.
16. **EN SON:** *"**hepsini bitir. döküman ne diyorsa onu yap** eski versiyonu sadece referans almıştın…
    **dökümanda ki her şey doğru olmalı ve dökümanda istenen şekilde olmalı.** görseller için…
    `.ai-agent/imports/manuel-reeskont-gorseller` buradan incele ve **hepsini tamamla**"*

---

## 2. Yapılanlar

### Kod — MM (`NetTrex.MM`)

Yeni: `Api.ResponseRequest/ManuelReeskont/` (enum + 2 request + 2 response),
`Api.Services/ManuelReeskont/Handlers/` (`EligibleTransactionsHandler`, `ExecutionsHandler`),
`Validators/` (2), `Api/Controllers/ManuelReeskont/ManuelReeskontController.cs` (`api/manuel-reeskont`),
`Data.Model/.../TDMRediscountEligibleResult.cs`.
Değişen: `TransactionDataManager` (+uygunluk sorgusu), `IAccountingDataManager`/`AccountingDataManager`
(+`GetRevaluationByValueDateAsync`), `RevaluationReverseAccountingServiceContext`/`PipelineContext`/`Mapper`/
`05_RevaluationReverseAccountingReverseStep` (**T-01**: `StateMaker` artık parametre).

### Kod — Web.UI (`NetTrex.Web.UI`)

`Trex.Web.Business.Models/Models/ManuelReeskont/` (enum + Req/Res),
`Trex.WebUI/Services/ManuelReeskont/` (Refit arayüzü + modül resolver + query service),
`Controllers/ManuelReeskont/` (base + Treasury/Security/Investment),
`ViewComponents/ManuelReeskont/`, `Views/Shared/Components/ManuelReeskont/Default.cshtml`,
`wwwroot/js/shared/components/manuel-reeskont/` (6 dosya), `wwwroot/js/config/manuel-reeskont/*.json` (3),
CSS + tr/en lokalizasyon. `Startup.cs`'e 4 modül client + resolver + query service.

### Script (uygulanmadı — kullanıcı uygulayacak)

- `outputs/2026-08-13-ManuelReeskont-Menu-Script.sql` — 3 `FrameworkMenu`, `ParentId=129`, order 66/67/68
- `outputs/2026-08-13-ManuelReeskont-Permission-Script.sql` — 3 ekran × `_Displayer`/`_Maker`

### Testler

`Code/UnitTest/Api/NetTrex.MM.Api.Services.Tests/ManuelReeskont/` — 3 dosya, **59 test, 0 hata**.
Komut (⚠️ `dotnet test` çalışmaz):

```powershell
.\Code\UnitTest\Api\NetTrex.MM.Api.Services.Tests\bin\Debug\net10.0\NetTrex.MM.Api.Services.Tests.exe -namespace "*ManuelReeskont*"
```

### MD / skill

- `skills/mssql-read.md` — salt SELECT + **zorunlu audit log**
- `skills/accounting-db-script.md` — 5 katmanlı zincir, 9 değişmez kural, `DefNumberGen`, temizlik seviyeleri
- `NetTrex.MM/.ai-agent/feature-research/Accounting-Engine-research.md`
- `manuel-reeskont/06-sozlesme.md` **donduruldu**, `08-test-rehberi.md`, `09-dokuman-uyumluluk-raporu.md`
- `sql-log/manuel-reeskont-analiz/` — 16 sorgu + çıktı, **0 write**
- progress-2 … progress-11
- **Hard Rule** eklendi: workspace `CLAUDE.md` #10, `NetTrex.MM/CLAUDE.md` #12 → *kod değişince ilgili
  unit testler gözden geçirilir*

---

## 3. Kararlar ve gerekçeleri

| Karar | Alternatif | Neden bu seçildi |
|---|---|---|
| `IQueryFilterRequest` marker'ı | `BaseFlowRequest` akışına uy | Bu uç salt-okunur; marker reponun **kendi** kaçış kapısı (`TransactionSelectRequest` deseni). Yoksa 500. |
| `$.ajax` doğrudan, `ajax.js` değil | Ortak helper | `ajax.js` `IsSuccess=false`'u **yutup `null` dönüyor** (satır 20/45) → hata mesajı kaybolur |
| 3 ayrı Controller | Tek controller + parametre | Web.UI permission granülaritesi **ControllerName/ActionName** (`ADR-MR-003`) |
| Ürün **tekil** seçim | Çoklu ürün | Her sorgu tam **bir** modüle gider → `Skip/Take/TotalCount` doğru; `R-13` çoklu-modül sayfalama sorunu ortadan kalktı |
| Status türetme `AccEntryMain.ReverseId` | Ayrı durum kolonu | Canlı veriden doğrulandı (`M-08`); şema değişikliği gerekmiyor |
| `StateMaker` parametre | `"SYSTEM"` sabit kalsın | Manuel işlemde fişi **kullanıcı** kesiyor; batch davranışı default ile korundu (`T-01`) |
| Menü/permission script yazıldı ama **uygulanmadı** | Ben uygulayayım | Yazma yetkisi kullanıcıda; `mssql-read` salt-SELECT |

---

## 4. Karşılaşılan hatalar

| Hata (AYNEN) | Kök neden | Çözüm |
|---|---|---|
| `'TxnMmEntity' does not contain a definition for 'CashFlows'` | Uygunluk filtresini **Loan** data manager'dan kopyaladım | MM'de `Details` + `PeriodStartDate/PeriodEndDate` |
| `The type or namespace name 'BaseFlowResponse' could not be found` | eksik using | `using Netix.Core.Flow.Model.Dto;` |
| `cannot convert from 'string' to 'Netix.Core.ResponseRequest.Message'` | `Messages` = `List<Message>` | `new() { Text, MessageType, MessageCode }` (JobCron deseni) |
| `'decimal' does not contain a definition for 'RoundAwayFromZero'` | eksik using | `using NetTrex.MM.Common.Core.Extensions;` |
| `The type or namespace name 'IClientMMAPI' could not be found` | yanlış namespace varsayımı | `Trex.WebUI.Services.Abstract` (`Trex.FrameworkCommon.Api` değil) |
| `Cannot implicitly convert type 'ResponseOf<T>' to 'T'` | `ToContentExternal()` sarmalıyor | `external.IsFailed()` + `external.Data`; `Message` **`.Data` üzerinde** |
| 🐞 HTTP 500 · `The request 'EligibleTransactionsRequest' should have a flow property` | `FlowPipelineBehavior` state-machine bekliyor | `IQueryFilterRequest` + `int StateFilter` |
| 🐞 Uç 4 satır döndü, **hepsi `subProduct: "ISSUE"`** (`TISBRW…`) | Uygunluk filtresini EOD sorgusundan aldım ama MM ekranlarının **ISSUE hariç** kuralını almadım | `query.Where(x => x.TxnMmProductTypeId != (int)ProductAccountingCodeType.ISSUE)` — sonra `TMMBRW2505220009` doğrulandı |
| `cannot convert ... 'System.Func<int,DateTime>'` (AddDays) | `AddDays(double)` | `Select(offset => executionDate.AddDays(offset))` |
| `RevaluationReverseType could not be found` | enum `Api.IssueBond`'da, `Api.Services` referans vermiyor | 3 değerli switch (`1→Eod`, `2→Bod`, `3→Atomic`) |
| `MSB3027`/`MSB3021` — dosya kilidi | Çalışan uygulama DLL'i tutuyor | Build'den önce `TaskStop` |
| sqlcmd `Named Pipes Provider: Could not open a connection` | `-S 192.168.10.211` Named Pipes'a düşüyor | `-S "tcp:192.168.10.211,1433"` (**G-01**) |
| Web.UI komut satırı config argümanlarını yok sayıyor | özel `Framework.Startup.DefaultStartup` | `--no-launch-profile` + environment variable |
| Her iki uygulama da `CommonApi` olmadan açılmıyor | başlangıçta framework parametrelerini çekiyorlar | cluster: `http://192.168.10.191:30825/api` |
| `Treasy.MM.UI/settings.local.json` yazımı classifier tarafından bloklandı | — | Dürüstçe raporlandı, JSON kullanıcıya verildi; **workaround yapılmadı** |

---

## 5. Ölçülen gerçekler

- `Trex.WebUI/Startup.cs:58-75` — `IClientMMAPI`/`IClientFxAPI`/`IClientFiAPI`/`IClientFundsAPI`/`IClientOptFXApi`
  **zaten kayıtlı** (`RegisterClientWebApiRefitClients<T>` AppDomain tarar) → ek DI yok, `F-01` boşluğu kapandı.
  ⚠️ InvFund marker'ının adı **`IClientFundsAPI`** (`IClientInvFundAPI` değil).
- `settings.baseUrl` = **uygulama kökü** (`@Url.Content("~")`), modül adresi **değil** → modül yönlendirmesi
  sunucu tarafında yapılmak zorunda.
- Canlı DB: `AccEntryMain` `Type=2, IsReverse=0` → 2050 satır; `ReverseId` **hiç NULL değil**;
  ters fişlerde `StateMaker='SYSTEM'` → **T-01'in canlı kanıtı**.
- `NetTrexAcc` 43 tablo. Zincir: `AccEngineItem → AccEngineEvent → AccEngineGroup → AccEngineComponent →
  AccEngineAccountRule`; `AccAccountMap` ayrı (kendi `Path`'i); ID'ler **IDENTITY değil** → `DefNumberGen`.
  `ComponentTypeCode 510 = Revaluation`. `OnRevaluation` kuralları `TREX/BRWPLC1/…` politika ağacında,
  `TREX/MM/…` altında **değil**.
- Kullanıcının `Manuel-Reeskont/` script klasöründe **yalnızca docx** var → menü/permission scriptleri bu
  özellik için **ilk**.
- 🔴 **İlk docx çıkarımı tablo/paragraf yapısını kaybetmişti** → `<w:p>` bölerek yeniden çıkarıldı
  (412 paragraf) → § 5.1 zorunlu kolonlar, § 5.2 kolon sırası, § 7.1 rozet renkleri, § 6.3 giriş noktaları
  **yanlış okunmuş** çıktı → 9 gerçek eksik.

---

## 6. Açık kalanlar

**Kapatılmakta olan 9 eksik** (detay: `09-dokuman-uyumluluk-raporu.md` § 9):

1. `StatusDescription` alanı + kolonu (§ 3.3 metinleri) — ✅ MM tarafı yazıldı
2. `Product` görünür kolon — ✅ data+sözleşme
3. `External Customer Id` — ✅ data+sözleşme
4. Kolon sırası § 5.2: `[☑] → Product → Logical Reference → External Customer Id → External Customer Name → Status → Status Description → ürüne özel`
5. `Sub Product` **zorunlu** (şu an opsiyonel/All)
6. `Revaluation Type` **filtresi** + `RevaluationTypes` alanı — ✅ MM tarafı
7. Durum özet şeridi (`Toplam 248 kayıt · 120 Not Rediscounted · …`) — ✅ data+sözleşme
8. Rozet renkleri: **Processing = mavi**, **Not Reversed = sarı**
9. `@(Html.DevExtreme().ManuelReeskont().ProductGroup("Treasury"))` + `ManuelReeskont.init({productGroup})`

**Görsellerden çıkan ek gereksinimler:**

- Status filtresi **pill buton** (`All`/`Not Rediscounted`/`Not Reversed`/`Rediscounted`), dropdown değil
- Generate onayı: madde işaretli (Reeskont T+0 / Ters fiş T+1)
- Regenerate onayı: **durum bazlı kırılım** + `Processing/Error → kapsam dışında bırakılır`
- 🔴 **Davranış hatası:** `Regenerate` + `NotRediscounted` → *"Önceki değerleme bulunmadığından **yeni
  değerleme oluşturulur**"* olmalı; şu anki kod `NOT_REDISCOUNTED` hatası dönüyor
- Config şema alan adları: `key`/`caption`/`dataType`/`format`/`alignment`/`order`; eksik key → console warning
- `ExtraFilters` (Dictionary) — ✅ sözleşmeye eklendi
- Select All / N menüsü (100/50/25/Custom) + "100 of 248 selected"

**Kullanıcıya/başkasına ait:** menü+permission script uygulaması · tarayıcı testi · Faz 2 gerçek fiş testi
(**onay şart** — Fimple'a yazar, geri alınamaz) · Faz 4 MicroUI (*"ben deyince"*) · Fimple sorularu `Ö-S-01…08` ·
`C-20` eski ekran kararı.

---

## 7. Sonraki session'a devir

**MM derlenmiyor durumda** — data katmanı yeni alanlarla güncellendi, API katmanı kısmen.

Sıradaki somut adımlar:

1. `EligibleTransactionsHandler.MapItem` → `Product`, `ExternalCustomerId`, `ExternalCustomerName`,
   `StatusDescription` doldur (imza `TDMRediscountEligibleResult`'un yeni şekline göre).
2. `ExecutionsHandler.RegenerateAsync` → `NotRediscounted` artık **yeni değerleme oluşturur** (hata dönmez).
3. `EligibleTransactionsRequestValidator` → `SubProduct` **zorunlu**.
4. Birim testleri **Hard Rule 12** gereği güncelle
   (`Handle_RegenerateOnNotRediscounted_ShouldFailWithNotRediscounted` geçersiz → yeniden yaz;
   `SetupDataManager` yeni record şekline göre).
5. Web.UI: kolon seti/sırası, rozet renkleri, özet şeridi, pill filtreler, onay pencereleri, giriş noktaları.
6. `06-sozlesme.md` + `09-dokuman-uyumluluk-raporu.md` güncelle, `progress-12` yaz.
