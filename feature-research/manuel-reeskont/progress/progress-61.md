# progress-61 — PO sunum sonrası 8 madde: MM + Common.UI (2026-09-25)

> Önceki tur: [progress-60](progress-60.md). Tetikleyen istek: PO sunumu sonrası 8 maddelik
> geliştirme/düzeltme listesi. Kapsam kararı (kullanıcı): **önce yalnız `NetTrex.MM` + `Treasy.Common.UI`**,
> kullanıcı tek tek kontrol edip onay verince **WebUI + DerivSwp + OptionsFX + Fx**.

## Durum

🟡 **5 repo + Common.UI kod hazır, tüm testler yeşil, tarayıcı testi yok.** Kullanıcı onayı ("WebUI/DerivSwp/OptionsFX/Fx bunları tamamla") sonrası port da yapıldı — bkz. § Port.

---

## Yapılanlar (Done)

### 1 — İstek yalnız Search'te (Common.UI)

- **Kök sebep:** progress-60 sonrası eklenen `onSubProductChanged → #clearGridData()` grid'e yeni store
  bağlıyordu; DevExtreme yeni store'u **hemen `load`** ediyor, `#buildRequest()` da CANLI kutulardan
  okuduğu için SubProduct seçer seçmez istek gidiyordu. Aynı yol Product değişiminde de (Log. Ref. doluysa)
  istek atıyordu.
- **Çözüm:** `#appliedFilters` — Search anında (`applyFilters`) kutuların anlık kopyası alınır; istek
  YALNIZ bundan kurulur. Product değişince `#appliedFilters = null` → store yeniden bağlanır ama
  `IsFirstLoad` döner, istek YOK; SubProduct sıfırlanır, satırlar silinir, kolonlar yeniden kurulur.
- SubProduct değişimi: istek yok, temizlik yok (yalnız popup checkbox senkronu kaldı).
- Execution Date değişimi: hiçbir şey (zaten bağlı handler yoktu).
- Log. Ref. kutusunda **Enter = Search** (`onFilterChanged` artık `applyFilters`; eskiden `refresh()` idi).
- Execute artık Search anındaki tarihi kullanıyor (kutudaki tarih sonradan değiştiyse fiş o güne kesilmez).

### 2 — Log. Ref. her zaman sunucuda

- Eski kural "alt ürün seçiliyse referans TARAYICIDA süzülür" kaldırıldı (`#useServerSideReference`,
  `#applyReferenceFilter` silindi). Artık referans doluysa `Filters.LogicalReference` HER istekte gidiyor;
  MM `TransactionDataManager` zaten `subProductTypeIds` + `filters`'ı aynı `IQueryable`'a ekliyordu
  (tek SQL: `... IN (...) AND LogicalReference LIKE N'%x%'`). Backend değişikliği gerekmedi.
- Not: `Contains` → `LIKE '%x%'` index seek yapamaz; kazanç satır sayısında (sayımlar, korele alt
  sorgular, ağ, tarayıcı). Tam referans aranıyorsa `StartsWith`/eşitlik seek'e çevrilebilir — **önerildi,
  uygulanmadı**.

### 3 — Pagination (soru, kod değişmedi)

- Grid pager'ı var (25/50/100) ama **tarayıcı tarafı** (`remoteOperations: false`, ADR-MR-028).
  Tek istek `Take = MR_MAX_LOAD_ROWS = 2000` (MM `MaxTake = 2000`); DB tarafında `OFFSET 0 FETCH 2000`.
  4000 satırlık kapsamda ilk 2000 gelir + "kırpıldı" uyarısı çıkar. Sunucu tarafı sayfalama önerildi,
  karar kullanıcıda.

### 4 — Ext. Customer Id

- `columns.ts`: caption `Ext. Customer Id` (TR `Harici Müş. No`), `visible: false` — Column Chooser'dan açılır.
- `stateStoring` anahtarı **`-v4`** (v3'te kayıtlı "görünür" durumu varsayılanı eziyordu). Yan etki:
  kullanıcıların kayıtlı kolon düzeni bir kez sıfırlanır.

### 5 — Regenerate/Rediscounted nötrleme sırası 2-1 (MM)

- `RevaluationMirrorAccountingService` yeniden yazıldı. Yeni sıra (Fimple, DB Id ve Kafka üçünde de):
  **(2)** mevcut ters fişi nötrleyen kayıt (T+n, reeskontun kendi yönü) → **(1)** mevcut reeskontu
  nötrleyen ayna (T+0, ters yön) → (3) yeni reeskont → (4) yeni tersi.
- 🔴 **Fimple davranışı değişti:** (2) eskiden aynanın MessageKey'i ile Fimple "ters alma"
  (`SendRevaluationReverseAccountingAsync`) idi — ayna henüz Fimple'da yokken bu yapılamaz. Artık (2) de
  açık bacaklarıyla **ayrı revaluation fişi** (`SendRevaluationAccountingAsync`, `LogicalDate = T+n`).
  **UAT'ta Fimple ile doğrulanmalı** (ileri valörlü revaluation fişini kabul ediyor mu).
- DB şekli eskiyle aynı: ayna `IsReverse=false`, `ReverseId = (2).Id` (insert'ten ÖNCE dolu);
  (2) `IsReverse=true`, `ReverseId = ayna.Id`, bacak `ReverseId`'leri ayna bacaklarına; açıklamalar
  aynı fabrikadan (`AccountingReverseFactory`, "Ters Fiş: ..."). Fiş açıklama mantığına dokunulmadı.
- UI onayında da sıra 2-1 ve metin güncel (`mr-confirm-EntryMirrorReverse`).

### 6 — 30 kayıt sınırı

- UI `MR_MAX_EXECUTE_ITEMS = 30`; seçim > 30 → Generate + Regenerate pasif, altta ipucu
  ("Tek seferde en fazla 30 kayıt işlenebilir (N seçili). Generate ve Regenerate pasif").
- MM `ExecutionsHandler.MaxItems = 30` (validator + guard aynı sabiti okuyor).

### 7 — Popup'lar genel stil

- `mrShowDialog` + muhasebe popup'ı: `wrapperAttr: "treasy-popup ..."` (MmTransaction'daki genel popup
  sınıfı), başlık `Ana [ek]` biçimi (`popup-title-span`, `PopupBuilder.onTitleRendered` deseni),
  alt butonlar metin stili + ikon (Onayla `check`, Vazgeç `clear`, tek butonlu pencerelerde `isblank`).
- CSS: lacivert başlık, beyaz zemin zorlaması, dolu buton renkleri kaldırıldı — tema/genel stil devrede.

### 8 — Regenerate "en sonda ters fiş kesilsin" kutusu

- Regenerate onay penceresinde fiş listesinin altında `dxCheckBox`, varsayılan **açık**. Kapatılınca liste
  ve alt satır anında değişir (yeni tersi satırı düşer, hedef statü Not Reversed).
- Sözleşme: `ExecutionsRequest.CreateReverse` (bool, varsayılan `true` — alan gelmezse eski davranış).
  Common.UI Core DTO + MM request DTO'ya eklendi (Controller passthrough, eşleme gerekmedi).
- MM `RegenerateAsync`: `createReverse=false` → 2. aşamadaki yeni reeskontun tersi kesilmez, sonuç
  `NotReversed`. 1. aşama nötrlemeleri (NotReversed'ın T+0 kapanışı, Rediscounted'ın ayna çifti) etkilenmez.

## Doğrulama

- MM `NetTrex.MM.Api.Services.Tests` → `ExecutionsHandlerTests`: **47/47** ✅ (3 yeni `WithoutFinalReverse`
  testi + limit testi `MaxItems + 1`).
- MM `NetTrex.MM.Common.Services.Tests` → yeni `RevaluationMirrorAccountingServiceTests` (sıra, çift bağı,
  açıklama) + `RevaluationReverseAccountingServiceTests`: **4/4** ✅.
  ⚠️ Projenin tamamı filtresiz koşunca 10 dk'da bitmedi (entegrasyon testleri?) — yalnız ilgili sınıflar koşuldu.
- Common.UI `npm run typecheck` ✅ temiz.
- Common.UI `Treasy.Common.UI.Web.csproj` build ✅ 0 hata (`-nodeReuse:false` ile — C# Dev Kit'in açık MSBuild node'u normal `dotnet build`'i kilitliyordu).
- ⬜ Tarayıcı testi yok.

## Port — WebUI + DerivSwp + OptionsFX + Fx (kullanıcı onayı 2026-09-25)

- **WebUI** (JS ikizi): component (`#appliedFilters`, LogRef her zaman sunucuda, `-v4`, `CreateReverse`),
  init (Enter = Search, SubProduct değişimi istek atmaz), constants (30), columns (Ext. Customer Id kapalı),
  actions (popup kabuğu `netix-popup` — WebUI'nin genel popup sınıfı, başlık `[ek]`, metin+ikon butonlar;
  30 limiti; Regenerate kutusu; 2-1 sırası), CSS, lokalizasyon, `ExecutionsRequest.CreateReverse` (passthrough).
  Muhasebe popup'ı zaten framework'ün `#popupAcc`'ı — dokunulmadı.
- **DerivSwp**: `MaxItems 30`, `CreateReverse`, `RevaluationMirrorService` 2-1 (tersin Id'leri sayaçtan ÖNCE
  ayrılıyor; FI → `SyncAccounting`, müşteri → `DynamicAccounting`; açıklama biçimi `AccountingReverseService` ile birebir).
  Önceki turdan kalan kırık test (`DerivRediscountEligibleResult` yeni alanları) düzeltildi.
- **OptionsFX**: `MaxItems 30`, `CreateReverse`, `RevaluationMirrorAccountingService` 2-1 (MM ile aynı desen + FI/müşteri dalı).
  Mirror birim testi yazılamadı: `IFimpleAccountingService` internal, test projesine görünmüyor.
- **Fx**: `MaxItems 30`, `CreateReverse`. Ayna çifti `ValuationService` / `FutureValuationService` /
  `ExternalValuationService.BuildValuationAccounting` içinde; yeni opsiyonel `neutralizeReverseFirst = false`
  parametresi — yalnız yeni ekranın motoru (`FxManualRediscountEngine`) `true` geçiyor, **eski FX ekranı
  (`ManualRediscountUpdateHandler`) birebir aynı çalışır**. `RevaluationReverseOperation`'a (açıklama mantığı)
  DOKUNULMADI; yerel kayıtlar eski sırayla (DoForward → DoReverse) kurulur, Fimple + Kafka'ya önce tersin
  karşıtı gider. `ProcessAccountingSync`'e `updateRepository = true` parametresi: yeni yolda `UpdateAndDetach`
  atlanıyor (aynadaki `ReverseId` güncellemesi kopmasın). FX'te DB Id sırası 1<2 kalır (Fimple/Kafka sırası 2-1).

**Doğrulama (port):** DerivSwp 75/75 · OptionsFX 69/69 · Fx 38/38 · WebUI jest 468/468 (manuel reeskont 147,
3 yeni test) · WebUI `Trex.WebUI.csproj` build ✅.

## Yapılıyor (In Progress)

- Kullanıcının madde madde kontrolü.

## Yapılacaklar (TODO)

- ✅ Yük testi script'leri yazıldı (çalıştırılmadı — kullanıcı çalıştıracak): `.ai-agent/outputs/2026-09-26-ManuelReeskont-YukTesti/`
  (0-DOGRULAMA-MM/FX · 1-NetTrexMM 3000 klon · 2-NetTrexFX 3000 klon · 9-GERI-AL-MM/FX). Şablon işlem klonlanır,
  kolon listeleri `sys.columns`'tan dinamik; Id'ler DefNumberGen + önek (MM `55`, FX `11`). Kullanıcı sonra liste/sayfalama/
  Search/Execute'ı test edecek. Not: tek istek `MaxTake = 2000` → 3000 kapsamda kırpılma uyarısı beklenir.
- UAT: (2) no'lu fişin Fimple'a ayrı revaluation fişi olarak kabul edildiğini doğrula.
- Karar bekleyen: sunucu tarafı sayfalama · referans filtresi `StartsWith`.

## Commit durumu

⬜ Commit/push YAPILMADI — kullanıcı kendisi atacak.
