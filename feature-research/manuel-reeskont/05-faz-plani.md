# 05 — Mimari & Analiz Faz Planı (İŞ EMRİ)

> **Bu dosya işin yürütme planıdır.** Her ilerlemede **buradan** gidilir: iş kalemi (`İ-xx`) seçilir,m ekal çne akiaun dsa varo Onreatilvbit diia Wavabahaurm
> yapılır, `progress/` altına yeni numaralı dosya yazılır, buradaki durum güncellenir.
>
> Mimari **gerekçeleri** → [`02-mimari-karar.md`](02-mimari-karar.md) (18 ADR) ·
> Doküman analizi → [`01-dokuman-analizi.md`](01-dokuman-analizi.md) · Ham ölçümler → [`analiz/`](analiz/_index.md)
> **Fimple sözleşmesi + alternatif API önerileri** → [`07-fimple-entegrasyon.md`](07-fimple-entegrasyon.md) ·
> Anlık durum → [`00-PANO.md`](00-PANO.md)
>
> **Son Güncelleme:** 2026-08-12 · **Mimari:** v2 (Common yok, WebUI → modül direkt)

---

## 0. Bu planın çıkış noktası — "A ve B olmadan ne kadarını yapabiliriz?"

**Cevap: işin ~%70'i.** Çünkü bloke eden sorular **davranışı** belirliyor, **iskeleti** değil.

| A/B'nin belirlediği                         | A/B'den bağımsız olan                                                                      |
| -------------------------------------------- | --------------------------------------------------------------------------------------------- |
| Toolbar'da kaç buton, adları ne (C-01)     | Grid, filtre paneli, kolon config mekanizması, sayfalama                                     |
| `executions` senkron mu asenkron mu (C-07) | Modüle giden Refit katmanı, resolver, 3 controller, yetki                                   |
| `ExecutionsRequest` alanları (C-08)       | `eligible-transactions` sözleşmesi ve MM sorgusu                                          |
| Product filtresi tekli mi çoklu mu (C-02)   | Filtre bileşeninin**kendisi** (çoklu/tekli bir config bayrağı)                      |
| Kolon config'in fiziksel yeri (C-15)         | Config'i**okuyup uygulayan** kod (`columns.config` + `columns.url` ikisi de hazır) |
| `Data` sözlüğünün yerleşimi (C-14)   | `Data` sözlüğünü **çözen** kolon üretici                                      |

### 🔑 Yöntem — "dikiş yerlerini şimdi aç, kararı sonra ver"

Bilinmeyen her karar için **soyutlama dikişi** bırakılır; cevap geldiğinde **tek yerde** doldurulur:

| Bilinmeyen            | Bırakılan dikiş                                                                                                | Cevap gelince değişen                                        |
| --------------------- | ----------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------- |
| C-01 aksiyon seti     | `actions` config map'i (`{ key, label, enabled, confirm, handler }`)                                          | Sadece map'in içeriği — toolbar kodu değişmez             |
| C-01`All` var mı   | Status filtresi`allowAll: bool` config'i                                                                        | Tek bayrak                                                     |
| C-07 senkron/asenkron | `IManualRediscountExecutionDispatcher` — `ExecuteAsync` tek imza; arkasında ya doğrudan çağrı ya job+poll | Dispatcher'ın**implementasyonu**, çağıran kod değil |
| C-08 alanlar          | Sözleşme DTO'sunda**opsiyonel** (`ReverseValueDate?`, `Operation?`, `RegenerateToToday?`)           | Zorunlu/opsiyonel işaretleri + validator                      |
| C-02 tekli/çoklu     | Filtre bileşeni`multiple: bool`                                                                                | Tek bayrak + validator                                         |
| C-15 config yeri      | `columns: { config: null, url: "" }` — ikisi de destekli                                                       | Hangisinin dolduğu                                            |

⚠️ **Dikiş bırakmak "her şeyi yaz" değildir.** Dikiş = **tek noktada değişebilirlik**. İki farklı davranışı
birlikte kodlamak (ör. hem Execute-Selected hem Generate/Regenerate akışını yazmak) **yapılmaz** — çöp iş olur.

---

## 1. Faz Haritası (yeniden fazlandı)

⚠️ **Önceki fazlandırma değişti.** Eski Faz 1 (base component + Treasury ekranı, tek parça) → yeni **Faz 1 + Faz 2**'ye
bölündü, çünkü Faz 1'in tamamı A/B'den bağımsız çıkarılabiliyor.

| Faz         | Adı                            | Sonuç (Definition of Done)                                                                                                                                        | A/B gerekli?                 | Durum                     |
| ----------- | ------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ---------------------------- | ------------------------- |
| **0** | Analiz & doğrulama             | Mimari kararı + ölçümler + 6 teknik doğrulama + sözleşme**taslağı**                                                                                 | ❌ Hayır                    | 🟡 %85                    |
| **1** | **İskelet & okuma yolu** | Treasury ekranı**açılıyor**, filtre çalışıyor, MM verisi grid'de sayfalı listeleniyor, durumlar badge'li görünüyor. **Aksiyon butonu YOK** | ❌ Hayır                    | ⬜**Başlayabilir** |
| **2** | Aksiyonlar & yazma yolu         | Generate/Regenerate (veya Execute Selected) çalışıyor, onay penceresi, satır bazlı sonuç, MM`executions`                                                  | ✅**C-01/07/08 şart** | ⬜ Bloke                  |
| **3** | Diğer modüller & 2 ekran      | Fx + FI + InvFund uçları · Security + Investment ekranları · çok modüllü fan-out gerçek veriyle                                                           | 🟡 Kısmen (C-02)            | ⬜                        |
| **4** | Pakete taşıma                 | Base component`Treasy.MicroUI.SharedDependency` + `@treasy/components`; MicroUI'ler import ediyor                                                              | ❌ Hayır                    | ⬜                        |
| **5** | Önizleme                       | Generate/Regenerate**öncesi** yeni değerleme tutarı önizlemesi (doküman Faz 3)                                                                          | ✅                           | ⬜                        |

**Eski↔yeni eşleme:** eski Faz 1 = yeni Faz 1 + 2 · eski Faz 2 = yeni Faz 3 (+ MicroUI kısmı Faz 4'e) ·
eski Faz 3 = yeni Faz 5.

---

## 2. FAZ 0 — Analiz & Doğrulama (A/B'siz · %85)

### Bitmiş

| İş                                      | Çıktı                                                                                      |
| ----------------------------------------- | --------------------------------------------------------------------------------------------- |
| Doküman analizi (416 satır + 7 görsel) | `01-dokuman-analizi.md` — 19 boyutlu eski↔yeni, **C-01…C-20**                      |
| Mimari kararı v2                         | `02-mimari-karar.md` — **18 ADR**, F-xx, R-xx                                        |
| MM backend envanteri                      | `03-mm-backend-envanteri.md` — T-01…T-11, M-01…M-09                                      |
| WebUI desen envanteri                     | `analiz/analiz-6` — 3 desen nesli, `settings.baseUrl` gerçeği, eski ekranın 10 kusuru |
| Soru listesi                              | `04-sorular.md` — A(16) · B(7) · C(4 kapalı)                                            |
| MD/skill altyapısı                      | workspace katmanı · Web.UI katmanı · compact sistemi · skill v2                          |

### Kalan — hepsi A/B'siz yapılabilir

| İş               | Ne                                                                                                                                                                                                                                                                                      | Neden şimdi                                                                                                                              |
| ------------------ | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------- |
| **İ-01**    | `F-13` WebUI → modül Refit çağrısında **bearer token taşınıyor mu?** (`Trex.FrameworkCommon/Api/RefitExtensions.cs`)                                                                                                                                                 | Audit/`StateMaker` tasarımı buna bağlı                                                                                              |
| **İ-02**    | `F-14` WebUI'den **`General:AvailableModules`** okunabiliyor mu (`IFrameworkParameterHelper`)                                                                                                                                                                               | Kapalı modül fan-out'a girmesin                                                                                                         |
| **İ-03**    | `F-15` WebUI'de `ModuleConstants` karşılığı var mı → yoksa `ManualRediscountModuleConstants` yazılacak                                                                                                                                                                      | `moduleCode` sabitleri                                                                                                                  |
| **İ-04**    | `F-16` WebUI Refit **timeout** değeri                                                                                                                                                                                                                                          | C-07 senkron çıkarsa kritik                                                                                                             |
| **İ-05**    | `F-17` `Views/Shared/Components/{CashFlow,LimitCheck}/Default.cshtml` oku                                                                                                                                                                                                           | Razor + hidden alan yerleşimi                                                                                                            |
| **İ-06**    | `F-18` `ManuelReescontApi` wrapper'ının içi (hangi marker, hangi endpoint)                                                                                                                                                                                                       | Faz 3'te Fx ucu                                                                                                                           |
| **İ-07**    | **`06-sozlesme-taslak.md`** — `eligible-transactions` **kesinleşmiş**, `executions` **varyantlı** (C-07/C-08 için A/B/C seçenekleri yan yana)                                                                                                             | İş birimi cevabı gelince taslak →`06-sozlesme.md` (DONDURULDU) olarak kapanır                                                      |
| **İ-08**    | MM`eligible-transactions` **durum türetme sorgusu tasarımı** (M-08 "son aktif hareket" tanımı 3 alternatifle)                                                                                                                                                              | MM'in en riskli parçası; sözleşmeden bağımsız                                                                                      |
| **İ-09** ⭐ | 🔴**`R-16` — MM hangi `MessageKey`'i persist ediyor?** Fimple yanıtında **iki** var: `Value.MessageKey` (fişin) ve zarf `MessageKey` (mesajın). Ters fiş **`Value.MessageKey`** istiyor. Yanlışı kayıtlıysa ters fiş **hiç çalışmaz** | Faz 2'nin temeli; salt-okunur kontrol, şimdi yapılır. Detay →[`07-fimple-entegrasyon.md`](07-fimple-entegrasyon.md) § 4 (`FT-01`) |

> **İ-07 kritik:** `eligible-transactions` (okuma) sözleşmesi A/B'den **bağımsız kesinleşebilir** —
> filtreler + 6 sabit kolon + `Data` sözlüğü + `Skip`/`Take`/`TotalCount`. Bloke olan yalnız **`executions`**.
> Bu yüzden Faz 1 tam olarak `eligible-transactions` üzerine kurulu.

---

## 3. FAZ 1 — İskelet & Okuma Yolu (A/B'siz · ŞİMDİ BAŞLAYABİLİR) ⭐

**Hedef:** `/TreasuryRediscount` açılıyor → filtre seçiliyor → MM'den sayfalı veri geliyor → grid'de
6 sabit kolon + ürüne özel kolonlar + durum badge'leri görünüyor. **Hiçbir aksiyon butonu yok.**

### 3.1 `NetTrex.MM` — okuma ucu

| İş            | Dosya                                                                                    | Not                                                                                                                                         |
| --------------- | ---------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------- |
| **İ-10** | `Api.ResponseRequest/ManualRediscount/{Request,Response}/`                               | `EligibleTransactionsRequest/Response` + `ManualRediscountItem` (6 sabit alan + `Data: Dictionary<string,object>`)                      |
| **İ-11** | `Data/Managers/.../` durum türetmeli sayfalı sorgu                                   | İ-08 tasarımından.**Tek sorguda `LEFT JOIN` + projeksiyon** — FX'in N+1 hatasını tekrarlama. `Skip`/`Take`/`TotalCount` |
| **İ-12** | `Api.Services/ManualRediscount/Handlers/` + `Validators/`                              | `FlowHandler`/`BaseHandler` deseni                                                                                                      |
| **İ-13** | `Api/Controllers/ManualRediscount/ManualRediscountController.cs`                           | `POST api/manual-rediscount/eligible-transactions`                                                                                          |
| **İ-14** | `ProductSourceType` (MM↔IL) ayrımı + `GetIsEnabledInterbankLoanModule()` guard'ı | Kapalı müşteride`TxnLoan` **yok**                                                                                                |
| **İ-15** | Test (xUnit v3)                                                                          | ⚠️`dotnet test` **çalışmaz** — bin'deki exe + native argüman                                                                 |

**Yazılmayacak:** hesap motoru. Mevcut `IRevaluationAccountingService` / `IRevaluationReverseAccountingService`
Faz 2'de tetiklenecek.

### 3.2 `NetTrex.Web.UI` — sunucu katmanı

| İş            | Dosya                                                                    | Not                                                                                                                                                          |
| --------------- | ------------------------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| **İ-20** | `Services/ManualRediscount/IManualRediscountMmApi.cs` (`: IClientMMAPI`) | **DI kaydı gerekmez** — AppDomain taraması                                                                                                          |
| **İ-21** | `Services/ManualRediscount/IManualRediscountModuleResolver.cs` + impl      | `moduleCode` → client. Faz 3'te 3 client daha eklenecek, **arayüz değişmeyecek**                                                                 |
| **İ-22** | `Services/ManualRediscount/ManualRediscountQueryService.cs`                | `Task.WhenAll` + **modül-başına `try/catch`** → kısmi hata toplama (`ADR-MR-008`). Faz 1'de tek modül ama **çoklu için yazılır** |
| **İ-23** | `Models/ManualRediscount/` sözleşme DTO'ları                          | MM'inkiyle**birebir** — `06-sozlesme` tek gerçek kaynak (`R-11`)                                                                                 |
| **İ-24** | `Controllers/ManualRediscount/TreasuryRediscountController.cs`             | `Index` + `Load`. **Tek tip response şekli** (eski ekranın iki-şekilli `Load`'unu kopyalama)                                                  |
| **İ-25** | `ManualRediscountModuleConstants` (İ-03 sonucuna göre)                 | `moduleCode` sabitleri                                                                                                                                     |
| **İ-26** | Aktif modül okuma (İ-02 sonucuna göre)                                | Parametre yoksa**AKTİF** kabul et (`LimitCheckViewComponent` deseni)                                                                                |
| **İ-27** | `CurrentUserId`'nin request'e eklenmesi (`ADR-MR-012`)               | İ-01 sonucundan bağımsız**her durumda güvenli**                                                                                                   |

### 3.3 `NetTrex.Web.UI` — ViewComponent & Razor

| İş            | Dosya                                                            | Not                                                                                                                           |
| --------------- | ---------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------- |
| **İ-30** | `ViewComponents/ManualRediscount/ManualRediscountViewComponent.cs` | `ProductGroup` parametreli. Kolon config'i **hidden alana basar** (`LimitCheckViewComponent` deseni, roundtrip yok) |
| **İ-31** | `Models/Shared/Components/ManualRediscount/…ViewModel.cs`       | `ProductGroup`, `ColumnsJson`, `IsModuleEnabled`, `LogicalDate`, `UniqueKey`                                        |
| **İ-32** | `Views/Shared/Components/ManualRediscount/Default.cshtml`        | Filtre paneli + DevExtreme grid +**boş toolbar yeri** (Faz 2'de dolacak)                                               |
| **İ-33** | `Views/ManualRediscount/Treasury/Index.cshtml`                   | ViewComponent'i Invoke eder                                                                                                   |
| **İ-34** | `AdvanceAndStateFilter` ViewComponent'ini yeniden kullan       | `ComponentConstants.cs:5` — 20+ view kullanıyor                                                                           |
| **İ-35** | `wwwroot/css/shared/components/manual-rediscount.css`            | Badge renkleri dahil,**inline değil**                                                                                  |
| **İ-36** | Localization`manuel-reeskont-{tr,en}.json`                     | `tr` **gerçekten Türkçe**                                                                                          |

### 3.4 `NetTrex.Web.UI` — base component (JS)

| İş            | Dosya                            | Not                                                                                                                                                                                                                                  |
| --------------- | -------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| **İ-40** | `manual-rediscount.constants.js` | **`MR_` prefix'li** selector'lar + `Status` enum (`Object.freeze`) + `CssClass` haritası. `limit-check.constants.js:39-73` deseni                                                                                   |
| **İ-41** | `manual-rediscount.endpoints.js` | `get`/`post` sarmalayıcıları. ⚠️ `ajax.js` `IsSuccess === false → null` **yutuyor** → Faz 2'de ham işleme gerekecek, şimdi not düş                                                                          |
| **İ-42** | `manual-rediscount.context.js`   | Seçili satır + filtre state.`cashflow.context.js` deseni (merge'li `setState`)                                                                                                                                                 |
| **İ-43** | `manual-rediscount.columns.js`   | Kolon config'i (hidden alan**veya** url) oku → 6 sabit + `Data` sözlüğünden ürüne özel kolonlar üret                                                                                                                |
| **İ-44** | `manual-rediscount.component.js` | `class ManualRediscountComponent`, `#private` field, **deep-merge config**, JSDoc `@typedef`. Grid + filtre + **server-side paging** + `IsFirstLoad` guard'ı. `actions` map'i **boş** tanımlı (dikiş) |
| **İ-45** | `manual-rediscount.actions.js`   | **Faz 1'de boş iskelet** — `actions` map'ini okuyup toolbar üretecek fonksiyon, içi Faz 2'de                                                                                                                             |

### 3.5 Faz 1 — Definition of Done

- [ ] `/TreasuryRediscount` açılıyor, yetki `TreasuryRediscount/Index` üzerinden çalışıyor
- [ ] Filtre seçilmeden grid **sorgulanmıyor** (`IsFirstLoad`)
- [ ] MM'den **sayfalı** veri geliyor (`Skip`/`Take`/`TotalCount` doğru)
- [ ] 6 sabit kolon + `Data`'dan gelen ürüne özel kolonlar görünüyor
- [ ] Durum badge'leri doğru renkte
- [ ] Modül patlarsa **grid boşalmıyor**, hata **görünüyor** (kısmi hata yolu test edildi)
- [ ] `CurrentUserId` MM'e ulaşıyor (log/SEQ'te doğrulandı)
- [ ] `MR_` prefix disiplinine uyuldu, başka ekranla `const` çakışması yok
- [ ] Build temiz (`dotnet build Code\Trex.Web.UI.sln` + `dotnet build Code\NetTrex.MM.sln`)

---

## 4. FAZ 2 — Aksiyonlar & Yazma Yolu (🔴 C-01 / C-07 / C-08 ŞART)

| İş               | Ne                                                                                                                                                                                                                                                                                                                                                                                                     | Hangi soruya bağlı                                                                 |
| ------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ------------------------------------------------------------------------------------ |
| **İ-50**    | Toolbar aksiyonları (`actions` map'i doldurulur)                                                                                                                                                                                                                                                                                                                                                    | **C-01**                                                                       |
| **İ-51**    | Onay penceresi/leri (`_GenerateConfirm` / `_RegenerateConfirm` veya tek `_ExecuteConfirm`)                                                                                                                                                                                                                                                                                                       | **C-01**                                                                       |
| **İ-52**    | `_ReverseValueDate.cshtml` — T+0/T+1 seçimi                                                                                                                                                                                                                                                                                                                                                        | **C-08** (`ReverseValueDate` var mı)                                        |
| **İ-53**    | Status filtresi`allowAll` bayrağı                                                                                                                                                                                                                                                                                                                                                                  | **C-01**                                                                       |
| **İ-54**    | `IManualRediscountExecutionDispatcher` implementasyonu (senkron **veya** job+poll)                                                                                                                                                                                                                                                                                                               | **C-07**                                                                       |
| **İ-55**    | `Processing` durumunun UI davranışı (polling / disable)                                                                                                                                                                                                                                                                                                                                           | **C-07**                                                                       |
| **İ-56**    | Web.UI`Execute` action'ı + satır bazlı sonuç gösterimi (`Succeeded[]`/`Failed[]`)                                                                                                                                                                                                                                                                                                           | C-01 + C-08                                                                          |
| **İ-57**    | MM`POST api/manual-rediscount/executions` + handler + validator                                                                                                                                                                                                                                                                                                                                        | C-07 + C-08                                                                          |
| **İ-58**    | MM:`IRevaluationAccountingService` + `IRevaluationReverseAccountingService` tetikleme, ters fiş valörü                                                                                                                                                                                                                                                                                          | C-08                                                                                 |
| **İ-59**    | MM:**çift-tıklama guard'ı** (Fimple **idempotent değil**, her istekte yeni `Guid`)                                                                                                                                                                                                                                                                                                   | — (zorunlu, sorusuz)                                                                |
| **İ-60**    | MM:`StateMaker` hardcoded `"SYSTEM"`/`18` → `CurrentUserId` (T-01)                                                                                                                                                                                                                                                                                                                            | — (zorunlu)                                                                         |
| **İ-61**    | MM:**Fimple hassasiyet/round kuralları** kontrolü                                                                                                                                                                                                                                                                                                                                              | **M-05** (§B)                                                                 |
| **İ-62**    | Manuel fiş`AccountingType` değeri                                                                                                                                                                                                                                                                                                                                                                  | **M-07** (§B)                                                                 |
| **İ-63**    | Backend'in her satırın durumunu**yeniden doğrulaması** (§4.5)                                                                                                                                                                                                                                                                                                                               | C-01 (davranış matrisi)                                                            |
| **İ-64**    | `Rediscounted` satıra Generate gelirse ne olur                                                                                                                                                                                                                                                                                                                                                      | **C-05**                                                                       |
| **İ-65** ⭐ | **Fimple baseline entegrasyonu** — `POST /Fx/TreasuryTransactions/DoAccounting`, T+0 (`DoAccounting:true`) + ters (`DoReverseAccounting:true` + `ReverseMessageKey`). ⚠️ Alan adı **`ReversAccountingTransactionDate`** (Fimple'ın yazım hatası, **aynen** yazılacak — `R-17`) · tarihler `+03:00` offset'li, UTC'ye çevirme valörü kaydırır (`R-18`) | — (zorunlu). Detay →[`07-fimple-entegrasyon.md`](07-fimple-entegrasyon.md) § 2-3 |
| **İ-66** ⭐ | **`Ö-06` satır bazlı ön-doğrulama** — fiş kesmeden önce `GET /Accounting/AccountingEntries/ByMessageKey/{MessageKey}` (veya `ByMainMessageKey`) ile Fimple'da gerçekten var mı teyit. Doküman §4.5'in *"backend durumu yeniden doğrular"* şartını **gerçek** doğrulamaya çevirir. ⚠️ **Liste sorgusunda KULLANMA** (248 × GET)                         | — (öneri, baseline'ı bozmaz)                                                      |
| **İ-67** ⭐ | **`Ö-08` idempotency** — Fimple'da `IdempotencyActionFilter` **var** ama **belgesiz**. `Ö-S-03` cevabı gelirse deterministik key (`{TxnId}-{AccountingType}-{ValueDate}-{IsReverse}`) → çift fiş **Fimple'da** engellenir. ⚠️ `İ-59` (uygulama guard'ı) **yine yazılır**                                                                          | `Ö-S-03`                                                                          |
| **İ-68** ⭐ | **C-07 asenkron çıkarsa:** `Ö-02 BatchAccountingEntries` (`/Queue` → `/{DraftId}/DoAccounting` → `GET /{DraftId}`) dispatcher'ın arkasına konur. İkinci aday `Ö-01 DoManualBulk`. ⚠️ İkisi de "manual/batch fiş hazine bağını koruyor mu" sorusuna bağlı (`Ö-S-01`)                                                                                               | **C-07** + `Ö-S-01`, `Ö-S-02`, `Ö-S-06`                               |

### Faz 2 — Definition of Done

- [ ] Aksiyon(lar) çalışıyor, onay penceresi doğru özet gösteriyor
- [ ] T+0 fiş + T+1 ters fiş `accEntryMain`'de doğru valörle oluşuyor
- [ ] Bir satır patlarsa diğerleri **etkilenmiyor**, `Failed[]`'da sebep görünüyor
- [ ] **`IsSuccess = true` yalanı yok** (FX'in hatası)
- [ ] Çift tıklama **çift fiş üretmiyor**
- [ ] `StateMaker` gerçek kullanıcı
- [ ] Fimple'a giden değerler hassasiyet kurallarına uygun

---

## 5. FAZ 3 — Diğer Modüller & 2 Ekran

| İş            | Ne                                                                                                   | Bağımlılık |
| --------------- | ---------------------------------------------------------------------------------------------------- | -------------- |
| **İ-70** | `IManualRediscountFxApi` / `…FiApi` / `…InvFundApi` + resolver'a ekleme                        | Faz 2          |
| **İ-71** | `NetTrex.Fx` 2 endpoint — mevcut `RediscountController` uyarlanacak mı? **kim yazacak?** | açık soru    |
| **İ-72** | FI + InvFund uçları (ürün ekipleri) + kolon config teslimi                                       | dış ekip     |
| **İ-73** | `SecurityRediscountController` + `InvestmentRediscountController` + view'ları                       | —             |
| **İ-74** | Çok modüllü fan-out gerçek veriyle: kısmi hata, aggregate sıralama, sayfalama                  | İ-70          |
| **İ-75** | Product/SubProduct filtresi çoklu/tekli nihai hali                                                  | **C-02** |
| **İ-76** | `RegenerateToToday` (geçmiş tarihli yeniden değerleme)                                          | C-08           |

> ⚠️ **Çok modüllü sayfalama tuzağı:** `Skip`/`Take` **modül başına** uygulanırsa aggregate sonuç yanlış olur.
> Faz 3'te karar gerekecek: (a) her modülden tam liste çekip UI'de birleştir+sayfala (bellek riski),
> (b) modül başına `Take` + toplam yaklaşık `TotalCount` (kullanıcıya yalan), (c) tek modül seçimini zorunlu kıl.
> **Faz 1'de tek modül olduğu için sorun görünmez** — Faz 3'e girmeden bu karar alınmalı. Yeni risk: **`R-13`**.

---

## 6. FAZ 4 — Pakete Taşıma (`Treasy.MicroUI.Packages`)

| İş            | Ne                                                                                                                                 |
| --------------- | ---------------------------------------------------------------------------------------------------------------------------------- |
| **İ-80** | Razor + ViewComponent →`Treasy.MicroUI.SharedDependency/Views/Shared/Components/ManualRediscount/` + csproj `<AdditionalFiles>` |
| **İ-81** | JS → TS portu →`Treasy.MicroUI.Components/wwwroot/manuel-reeskont/` → `@treasy/components`                                  |
| **İ-82** | Sürüm bump + Nexus publish (⚠️ sürümü**csproj'dan** doğrula, doküman bayat)                                         |
| **İ-83** | MicroUI'lerde (`Treasy.MM.UI`, `Treasy.OptionsFX.UI`, `Treasy.MicroUI.Deriv`) import + route                                 |

**Faz 1'de uyulacak 4 taşınabilirlik kuralı** (bunlara uyulmazsa Faz 4 pahalanır — `R-12`):

1. Component JS'i Web.UI global'lerine **fazladan** bağımlı olmasın (`settings`, `formatMessage`, `notifyError`, `get`/`post` dışına çıkma)
2. Endpoint yolları **config'ten** (`dataSource.*.url`) — hardcoded `/TreasuryRediscount/Load` yazma
3. Razor bileşeni `Views/Shared/Components/` altında (RCL'ye taşınabilir yol)
4. CSS + localization **ayrı dosyada**, inline değil

---

## 7. FAZ 5 — Önizleme

**İ-90** Generate/Regenerate **öncesi** hesaplanacak değerleme tutarlarının önizlemesi (doküman Faz 3).
Muhasebe motorunu **yazmadan** çalıştırıp sonucu göstermeyi gerektirir → MM'de "dry-run" modu gerekebilir.
Kapsam netleşmedi; iş birimi tanımı bekliyor.

---

## 8. A/B Bağımlılık Matrisi

Cevap geldiğinde **hangi iş açılıyor**:

| Soru                                          | Kim         | Açtığı iş kalemleri            | Blokladığı faz                                             |
| --------------------------------------------- | ----------- | ----------------------------------- | ------------------------------------------------------------- |
| **C-01** aksiyon seti + `All`         | İş birimi | İ-50, İ-51, İ-53, İ-63, İ-64   | Faz 2                                                         |
| **C-07** senkron/asenkron               | İş birimi | İ-54, İ-55, İ-57                 | Faz 2                                                         |
| **C-08** `ExecutionsRequest`          | İş birimi | İ-52, İ-56, İ-57, İ-58, İ-76   | Faz 2                                                         |
| **C-02** Product tekli/çoklu           | İş birimi | İ-75 (+ İ-44'te filtre bayrağı) | Faz 3 (Faz 1'i**bloke etmez** — bayrak)                |
| **C-05** `Rediscounted` + Generate    | İş birimi | İ-64                               | Faz 2                                                         |
| **C-14** `Data` yerleşimi            | Selim       | İ-10, İ-43                        | Faz 1 —**karar gerek** ⚠️                            |
| **C-15** kolon config yeri              | Selim       | İ-30, İ-43                        | Faz 1 —**karar gerek** ⚠️ (varsayılan: hidden alan) |
| **M-02** SubProduct eşlemesi           | Selim       | İ-11, İ-44                        | Faz 1 —**karar gerek** ⚠️                            |
| **M-08** "son aktif hareket"            | Selim       | İ-08, İ-11                        | Faz 1 —**karar gerek** ⚠️                            |
| **M-05** Fimple yuvarlama               | Selim       | İ-61                               | Faz 2                                                         |
| **M-07** manuel fiş `AccountingType` | Selim       | İ-62                               | Faz 2                                                         |
| **R-04** `moduleCode` reddedilirse    | Selim       | İ-21, İ-25                        | Faz 3                                                         |

### 🔴 Faz 1 için Selim'den **4 karar** gerekli (iş biriminden değil)

`C-14` · `C-15` · `M-02` · `M-08` → bunlar `04-sorular.md` **§ B**'de, önerilerim yazılı.
Bu dördü olmadan Faz 1'in **İ-08, İ-10, İ-11, İ-30, İ-43, İ-44** kalemleri varsayımla yazılır.

**Varsayımla ilerlenebilir mi?** Evet, şu varsayımlarla — beğenmezsen tek yerde döner:

| Soru                      | Varsayacağım                                                                                  | Dönüş maliyeti                                                 |
| ------------------------- | ----------------------------------------------------------------------------------------------- | ----------------------------------------------------------------- |
| C-14`Data` yerleşimi   | Item'ın**içinde** `Data: Dictionary<string,object>` (doküman böyle)                 | Düşük — DTO + kolon üretici                                  |
| C-15 kolon config yeri    | **UI'de JSON dosyası**, ViewComponent hidden alana basar; `columns.url` dikişi açık | Düşük — config kaynağı değişir                            |
| M-02 SubProduct eşlemesi | `DailyFlowProductType` (en zengin liste) + **string** taşıma                          | Orta — enum/sabit listesi                                        |
| M-08 "son aktif hareket"  | `accEntryMain`'de **`IsReverse = false` ve en büyük `Id`** olan kayıt            | **Yüksek** — sorgu mantığı ve durum türetme değişir |

⚠️ **M-08 riskli.** Yanlış varsayım tüm durum türetmeyi bozar → **İ-08'i tasarım olarak yazıp
kodlamayı M-08 cevabına bırakmak** daha güvenli.

---

## 9. Sıradaki 3 Somut Adım (bugün başlanabilir)

| Sıra | İş                                                                                                                        | Neden                                                                                 |
| ----- | --------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------- |
| 1     | **İ-01 … İ-06** (6 doğrulama)                                                                                     | Salt-okunur, hiçbir karara bağlı değil, Faz 1'in temelini kesinleştirir          |
| 2     | **İ-07** `06-sozlesme-taslak.md` — `eligible-transactions` **kesin**, `executions` **varyantlı** | İş birimi cevabı gelince taslak dondurulur; Faz 1 zaten okuma yolu üzerine kurulu |
| 3     | **İ-08** MM durum türetme sorgusu **tasarımı** (3 alternatif, M-08 için karşılaştırma tablosu)         | Selim'in M-08 kararını**kolaylaştırır** — soru yerine seçenek sunar      |

> Bu 3 adım bitince Faz 1'in kodlanmasına başlamak için yalnız **§ 8'deki 4 karar** kalıyor.

---

## 10. Yeni Riskler (bu planla ortaya çıkanlar)

| #                 | Risk                                                                                                                                                            | Etki       | Azaltma                                                                                                                                         |
| ----------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------- | ----------------------------------------------------------------------------------------------------------------------------------------------- |
| **R-13** ⭐ | **Çok modüllü sayfalama** — `Skip`/`Take` modül başına uygulanırsa aggregate yanlış. Faz 1'de tek modül olduğu için **görünmez** | 🔴 Yüksek | Faz 3'e girmeden karar: UI'de birleştir / yaklaşık`TotalCount` / tek modül zorunlu. `TotalCount` sözleşmesi buna göre tanımlanmalı |
| **R-14** ⭐ | Faz 1 "aksiyonsuz ekran" olarak test edilirse, Faz 2'de aksiyon eklendiğinde grid/state varsayımları kırılabilir                                           | 🟠 Orta    | `actions` map'i ve seçim (`selection.bulk`) **Faz 1'de config olarak tanımlı** olsun, içi boş kalsın                            |
| **R-15** ⭐ | Varsayımla yazılan Faz 1 kalemleri (§8) cevap gelince**sessizce** yanlış kalabilir                                                                   | 🟠 Orta    | Her varsayım koda`// VARSAYIM: <soru-kodu>` yorumu olarak yazılır, cevap gelince grep'lenir                                                |

---

## 11. Durum Takibi

| Faz | İş kalemi aralığı | Tamamlanan      | Durum                                                                                                                                                                                                                                                                                                                                                                                                           |
| --- | ---------------------- | --------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 0   | İ-01 … İ-09         | 2/9             | 🟢 Sözleşme**DONDURULDU** · İ-08 (M-08) + İ-09 (`R-16`) canlı veriyle kapandı · kalan: İ-01…İ-06 doğrulamaları (bloke edici **değil**)                                                                                                                                                                                                                                              |
| 1   | İ-10 … İ-45         | **24/24** ✅ | 🟢 **TAMAM.** Kod + **İ-15 birim testler (59 test, 0 hata)** + permission/menü scriptleri (`outputs/`). Kalan yalnız **kullanıcı işi**: scriptleri uygula + tarayıcı testi. Detay → [progress-11](progress/progress-11.md)                                                                                                                                                                                                                                          |
| 2   | İ-50 … İ-68         | **14/19** | 🟢**KODLANDI, İKİ REPO DA DERLENDİ.** Aksiyon×durum matrisi · onay penceresi · satır bazlı sonuç · **T-01 fix** · çift-tıklama guard'ı (process-içi). Kalan: İ-66/67/68 (Fimple ön-doğrulama/idempotency/asenkron — Fimple cevabına bağlı) + §4.6 `RevaluationType` açık kalemi. Detay → [progress-7](progress/progress-7.md)                                            |
| 3   | İ-70 … İ-76         | **5/7**   | 🟢**UI TARAFI KODLANDI** — 3 Refit interface + 3 adaptör · `RediscountControllerBase` + Security/Investment controller & view · security/investment kolon config'leri. **Kalan:** `İ-71`/`İ-72` (modül uçları — Fx/FI/InvFund ekiplerinde) · `İ-76` `RegenerateToToday` **bilinçli uygulanmadı** (iş kuralı tanımsız). Detay → [progress-9](progress/progress-9.md) |
| 4   | İ-80 … İ-83         | 0/4             | ⬜                                                                                                                                                                                                                                                                                                                                                                                                              |
| 5   | İ-90                  | 0/1             | ⬜                                                                                                                                                                                                                                                                                                                                                                                                              |

### 🔴 2026-08-21 (6. + 7. tur) — plan dışı ama tamamlanan işler

Bunlar `İ-xx` listesinde **yoktu**; kullanıcı isteğiyle geldi ve sözleşmeye alan ekledi:

| İş | Repo | Durum | ADR |
|---|---|---|---|
| Kolon filtreleri + arama (sunucu taraflı) | MM + Web.UI | ✅ | `ADR-MR-019` |
| ~~İlerleme ucu (`executions/progress`) + `ProgressKey`~~ | MM + Web.UI | ❌ **GERİ ALINDI** (2026-08-21, kullanıcı: *"Faz 1 için gerekli değilmiş"*) — tümü silindi | `ADR-MR-020` (geri alındı) |
| ~~T+1 = `MMSystemWDFlag`~~ → **T+1 = +1 takvim günü** | MM | ✅ **değişti** (2026-08-21) — takvim/flag okunmuyor | `ADR-MR-027` (`-021` yerine) |
| Export butonu grid dışına | Web.UI | ✅ | `ADR-MR-022` |
| Generate/Regenerate info ikonu | Web.UI | ✅ | `ADR-MR-023` |
| Pill sorgu maliyeti 4 → 1 | MM | ✅ | `ADR-MR-024` |
| Grid sayfa boyu yükseklik | Web.UI | ✅ | — |
| Valör hesabı tek sınıfa (`ManualRediscountValueDateResolver`) | MM | ✅ | `ADR-MR-025` |
| Valör önizleme kolonu (`ValueDates`) | MM + Web.UI | ✅ | `ADR-MR-026` |
| Duruma göre boş liste mesajı | Web.UI | ✅ | — |
| "Başarısızları seç" butonu | Web.UI | ✅ | — |
| Satır içi hata sebebi (`!` düğmesi) | Web.UI | ✅ | — |
| Seçim özetinde ürün + tutar | Web.UI | ✅ | — |

🔴 **Faz 3'e (`İ-71`/`İ-72`) yeni yük:** Fx/FI/InvFund uçları artık `Filters` alanını da **aynı adlarla**
uygulamak zorunda; uygulamazlarsa ekranda filtre görünür ama sonuç **filtresiz** gelir (`R-11`).
`ProgressKey`/`progress` ucu **opsiyonel** — açılmazsa ekran yalnız genel "N kayıt işleniyor" yazar.

> Her ilerlemede: bu tablo güncellenir + `progress/` altına **yeni numaralı** dosya + `00-PANO.md` tazelenir.
