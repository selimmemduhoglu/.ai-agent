# progress-37 — PO geri bildirimi (7 madde)

> # 🔴 BU DOSYADAKI 1. BOLUM YANLISTI — DUZELTME (2026-08-24)
>
> `progress-37` ilk yazildiginda *"`ADR-MR-028` karar alinmis ama kodda yok"* dedim. **Yanlis.**
> `ADR-MR-028` ve `ADR-MR-029` **kodda UYGULANMIS**:
>
> | Ne | Kodda |
> |---|---|
> | `remoteOperations` | ✅ `false` (`component.js:604`) |
> | Kapsam tek istekte | ✅ `#fetchScope` + `#cache` + `#scopeKey` |
> | Statu suzgeci tarayicida | ✅ `#applyStatusFilter` |
> | Ozet serit tarayicida | ✅ `#renderLocalSummary` + `mrCountStatuses` |
> | Tavan uyarisi | ✅ `mrTruncationNotice` |
> | Kolon filtresi + huni | ✅ `filterRow` + `headerFilter` |
> | Testler | ✅ 344 → **400** |
>
> **Hatanin sebebi:** dosyayi turun basinda okudum, o okuma **eski** durumu gosterdi; refactor
> paralel bir oturumda uygulanmisti. Ikinci okumada satir numaralari ~70 satir kaymis olarak
> geldi ve gercek durum ortaya cikti.
>
> 🔑 **Ders:** cok oturumlu bir repoda "kod X'i yapmiyor" demeden **once** dosyayi TEKRAR
> oku. Karar dosyasi (`02-mimari-karar.md`) ile kod arasinda bosluk oldugunu iddia etmek
> maliyetli bir yanlistir: kullaniciya yapilmis isi yeniden yaptirtir.
>
> Asagidaki § 1 **tarihsel kayit** olarak duruyor; **gecerli degil**.


**Tarih:** 2026-08-24
**Tetikleyen:** Kullanıcı ekranı **Product Owner**'a gösterdi, 7 madde geldi

---

## 1. 🔴 EN ÖNEMLİ BULGU — `ADR-MR-028`/`-029` KARAR ALINMIŞ AMA KODDA YOK

`02-mimari-karar.md:242-243` (2026-08-21, **✅ Karar**):

> **`ADR-MR-028`** — *"GRID TAMAMEN CLIENT-SIDE. Bir `ExecutionDate + Product + SubProduct` kapsamı
> için tüm statüler tek istekte çekilir (`Take = 2000`); statü pill'i, kolon filtresi, sıralama,
> sayfalama, başlık filtresi (huni) **tarayıcıda** uygulanır. `remoteOperations: false`.
> Ekran artık `Status` ve `Filters` göndermiyor."*
>
> **`ADR-MR-029`** — *"Özet şerit tarayıcıda hesaplanır; sunucunun `StatusSummary` alanı
> kullanılmıyor."*

**Koddaki gerçek durum (2026-08-24 itibarıyla ölçüldü):**

| Ne | ADR ne diyor | Kod ne yapıyor |
|---|---|---|
| `remoteOperations` | `false` | 🔴 `{ paging: true, filtering: false, sorting: false }` |
| `Status` gönderimi | gönderilmez | 🔴 `Status: mrIsEmpty(statusRaw) ? null : Number(statusRaw)` |
| Özet şerit kaynağı | tarayıcı | 🔴 sunucunun `StatusSummary`'si (`mrRenderSummary`) |
| Sayfalama | tarayıcı | 🔴 `Skip`/`Take` sunucuya gidiyor |

**Yani ADR karar olarak yazılmış, uygulanmamış.** `progress` serisi 36'ya kadar (2026-08-20)
bu refactor'dan hiç söz etmiyor.

### 🔴 Neden PO'nun maddeleri buna bağlı

| PO maddesi | ADR-MR-028 olmadan ne olur |
|---|---|
| **3** — house grid template (*"Drag to group by"*, filtre satırı) | 🔴 Grup panel ve kolon filtresi **yalnız yüklü sayfayı** süzer. `MEMORY.md`'de bu tuzak zaten kayıtlı: *"kullanıcı '3 kayıt var' sanır, oysa diğer sayfalarda daha vardır"*. Finansal ekranda kabul edilemez |
| **4** — Status çoklu seçim | ADR-MR-028 ile **bedava** (tüm statüler zaten yüklü → pill tarayıcıda süzer). ADR olmadan **sözleşme değişikliği** gerekir (`Status: int?` → `Statuses: int[]`) + sorgu + 4 `COUNT` |
| **6** — *"Amountları toplayarak gösterme"* | House grid `NetixEnableDynamicFooterSummaries` ile footer toplamı **otomatik** açıyor; sunucu taraflı sayfalamada bu ayrıca **tüm veriyi çekmeye** zorluyor (`GridBuilderExtensions.cs:335` notu) |

**Sonuç: 3 → 4 → 6 sırası ADR-MR-028'in üstünde durur. Önce o.**

---

## 2. PO'nun 7 maddesi — durum

| # | İstek | Durum |
|---|---|---|
| 1 | `MmRevaluationReport`'tan kolonlar: **`AccrualDay`**, **`DaysToMature`**, **`AccrualAmountSL`**, **`AccrualAmountIRR (CL)`** + mantıklı olanlar | ⏳ **Yapılmadı** — bkz. § 3 (kaynak bulundu, 5 katman dokunuşu) |
| 2 | Tarih / tutar / oran formatları `MmTransaction` ekranı gibi | ✅ **YAPILDI** |
| 3 | DataGrid house template (`Drag to group by`, `Clear`) | 🔴 **ADR-MR-028'e bağlı** |
| 4 | Status **çoklu** seçim | 🔴 **ADR-MR-028'e bağlı** (onunla bedava) |
| 5 | SubProduct **çoklu** seçim | ⏳ Sözleşme değişikliği gerekir (`SubProduct` → `SubProducts[]`) — ADR-MR-028 bunu **çözmez**, SubProduct *kapsam* filtresi |
| 6 | Özet şeridin yanındaki **tutar toplamı** kalksın | ✅ **Bugün böyle bir toplam YOK** — house grid'e geçerken footer summary **açılmayacak** diye kayda geçti |
| 7 | `Execution Date` **gelecek tarih seçilemesin** | ✅ **YAPILDI** |

---

## 3. Madde 1 — kaynak bulundu, dokunulacak katmanlar

Değerler `TxnMMDailyCalculationEntity` (= `TxnMmEntity.Valuations`) içinde:

```csharp
public int      AccrualDay        { get; set; }
public decimal  AccrualAmount     { get; set; }
public decimal? AccrualAmountSL   { get; set; }
public decimal? AccrualAmountIRR  { get; set; }   // rapordaki "IRR (CL)"
public decimal? AccrualAmountLCY  { get; set; }
public decimal? FXRate            { get; set; }
public decimal  BaseAmount        { get; set; }
```

`DaysToMature` türetilir: `(MaturityDate - executionDate).Days`.
`MmRevaluationReport`'ta ayrıca `PeriodStartDate` / `PeriodEndDate` / `PeriodAmount` /
`DaysToPeriodEndDate` / `MarketCode` var — reeskont için değerli, eklenmesi öneriliyor.

### ⚠️ PO'ya söylenmesi gereken: bu kolonlar BOŞ görünebilir

`DailyAccrual` şu an canlıda **`null`** dönüyor (Seq log'u, 2026-08-20 koşusu). Sebep: bu alanlar
**revaluation engine çıktısı** (`TxnMMDailyCalculation`); ilgili Execution Date için değerleme
**koşmamışsa** satır yok. `AccruedInterest` (tarihe kadarki **toplam**) doluydu çünkü geçmiş
günlerin satırları var.

🔑 Yani yeni kolonlar *"reeskont kesilmeden önce"* çoğunlukla boş olacak. Bu **hata değil**, ama
PO ekranda boş kolon görünce hata sanacaktır — **önceden söylenmeli**.

### Dokunulacak katmanlar (mekanik ama geniş)

1. `TDMRediscountEligibleResult` — 19 parametreli **pozisyonel** record'a 6-8 alan
2. `TransactionDataManager.GetRediscountEligibleTransactionsAsync` — projeksiyon
3. `TransactionLoanDataManager` — aynısı (aynı record'u kullanıyor)
4. `EligibleTransactionsHandler.MapItem` — `Data` sözlüğü (MM + Loan)
5. `treasury.json` — kolon config'i (`key` + `caption` + `dataType` + `format` + `order`)
6. localization ×2 — yeni `mr-col-*` anahtarları
7. testler — `EligibleTransactionsHandlerTests`

🔴 Pozisyonel record olduğu için **argüman sırası kaydırma riski yüksek**: yeni alanları
**sonuna** eklemek ve iki manager'ı da aynı turda güncellemek şart. Ayrı ve odaklı bir tur olarak
yapılmalı.

---

## 4. Bugün yapılanlar

### Madde 2 — formatlar

`wwwroot/js/config/manual-rediscount/treasury.json` → **12 kolona** `format` yazıldı.
Değerler `Trex.Common.Models/Models/Base/UIConstants.cs` ile **birebir**:

| `dataType` | `format` | UIConstants karşılığı |
|---|---|---|
| `date` | `dd.MM.yyyy` | `DateFormat` |
| `money` | `#,##0.00` | `NominalFormat` |
| `rate` | `#,##0.000000` | `RateFormatScaleSix` |

🔑 **Kod değişikliği gerekmedi** — `mrBuildDataColumns` `format` alanını zaten okuyordu
(`definition.format` / `mrFormatMoney(value, column.format)`). Eksik olan **config**'ti.
Tarih kolonları format verilmediği için DevExtreme varsayılanına (`8/18/2026`) düşüyordu;
artık `18.08.2026`.

### Madde 7 — gelecek tarih engeli

`Default.cshtml` → DateBox'a `.Max(...)`. Modülde FluentValidation kuralı **zaten var**; bu
UI aynası, kullanıcı sunucudan hata almadan önce engelleniyor.

⚠️ Tavan `Model.ExecutionDate > DateTime.Today ? Model.ExecutionDate : DateTime.Today` —
varsayılan değer (logical date) bugünden ilerideyse kendi tavanını aşıp "geçersiz" görünmesin.

---

## 5. Doğrulama

| Ne | Sonuç |
|---|---|
| `dotnet build Trex.WebUI` | **0 Error** |
| `treasury.json` | `json.loads` ile doğrulandı, 12 kolon güncellendi |

---

## 6. Sıradaki karar (kullanıcıya soruldu)

**`ADR-MR-028` uygulanacak mı, şimdi mi?** Uygulanırsa madde **3, 4, 6** düzgün çözülür.
Uygulanmazsa madde 3 ve 4 için sunucu tarafına **çoklu statü + kolon filtresi + grup** desteği
yazmak gerekir — daha fazla iş, daha fazla risk, ve `MEMORY.md`'deki *"filtre yalnız yüklü
sayfayı süzer"* tuzağına açık.


---

## 7. 🔴 DÜZELTİLMİŞ DURUM TABLOSU (2026-08-24, ikinci tur)

| # | PO isteği | Durum |
|---|---|---|
| 1 | Rapor kolonları (`AccrualDay`, `DaysToMature`, `AccrualAmountSL`, `AccrualAmountIRR` + öneriler) | ⏳ **Sırada** — kaynak bulundu (`TxnMMDailyCalculationEntity`), 7 katman |
| 2 | Tarih / tutar / oran formatları | ✅ **YAPILDI** — `treasury.json`, 12 kolon |
| 3 | House DataGrid görünümü (`Drag to group by`, `Clear`) | ✅ **YAPILDI** — `groupPanel` + `grouping` + `columnChooser` + `Clear` butonu. `filterRow`/`headerFilter` **zaten vardı** |
| 4 | Status **çoklu** seçim | ✅ **YAPILDI** — pill'ler toggle, `data-mr-status` virgüllü liste, `mrSelectedStatuses` |
| 5 | SubProduct **çoklu** seçim | ⏳ **Sırada** — tek gerçek sözleşme değişikliği (`SubProduct` → `SubProducts[]`) |
| 6 | Tutar toplamı olmasın | ✅ **Zaten yok** — grid'de `summary` tanımlı değil; koda **açık not** düşüldü |
| 7 | Gelecek tarih seçilemesin | ✅ **YAPILDI** — DateBox `.Max(...)` |

### Madde 4 neden bedava geldi

`ADR-MR-028` sayesinde **tüm statüler zaten yüklü**. Pill'ler sunucuya gitmiyor, yüklü kümeyi
süzüyor → çoklu seçim **sunucu sözleşmesine hiç dokunmadan** yapıldı.
Sunucu sayfalaması olsaydı: `Status: int?` → `Statuses: int[]` + sorgu + 4 `COUNT` gerekirdi.

### Madde 3 detayı

| Eklendi | Neden |
|---|---|
| `groupPanel: { visible: true, allowColumnDragging: true }` | PO'nun istediği *"Drag to group by"* şeridi |
| `grouping: { autoExpandAll: false, contextMenuEnabled: true }` | Gruplar kapalı açılsın (13+ kolonda okunurluk), başlık sağ tık menüsü |
| `columnChooser: { enabled: true, mode: "select" }` | Kullanıcı gereksiz kolonu kapatabilsin |
| `Clear` butonu (`mrRenderClearButton` + `clearFilters()`) | `MmRevaluationReport`'taki `Clear`'ın muadili: `Outlined` + `remove` ikonu |

🔴 **`Clear` KAPSAMI TEMİZLEMEZ.** Sıfırladığı: statü pill'leri · kolon filtre satırı · huni ·
sıralama · gruplama · grid'in `localStorage` durumu. **Dokunmadığı:** `Execution Date` /
`Product` / `Sub Product` — bunlar filtre değil **kapsam** (`#scopeKey`); temizlenirse grid boşalır
ve kullanıcı veriyi geri getirmenin yolunu bulamaz. Referans ekranda da `Clear` tarihi sıfırlamıyor.

⚠️ `clearFilters()` **sunucuya yeni istek atmıyor** — kapsam değişmediği için önbellekteki satırlar
kullanılıyor. `ADR-MR-028`'in asıl kazancı bu.

### Madde 6 — koda not düşüldü

`#renderGrid` içine açık yorum: *"`summary` BİLİNÇLİ OLARAK TANIMLANMADI (PO isteği 2026-08-24)"*.
Ayrıca not edildi: house Razor grid'i (`NetixEnableDynamicFooterSummaries`) footer toplamını
**otomatik** açıyor; bizim grid JS'te kurulduğu için o davranış gelmiyor.

---

## 8. Doğrulama

| Ne | Sonuç |
|---|---|
| JS testleri | **400/400** (paralel oturum 344 → 400'e çıkarmış) |
| `dotnet build Trex.WebUI` | **0 Error** |


---

## 9. 🔵 Madde 5'in ŞARTNAMESİ netleşti (kullanıcı eki, 2026-08-24)

> *"Benim Product'larımda Money Market ve InterbankLoan var; bunların ekranları
> `MmTransaction/Index` ve `InterbankLoan/Index`. Buralarda `Product` ve `Product Type` diye
> kolonlar var — bu kolonlar nasıl doluyorsa sen de bu Product'ların SubProduct'larını buna göre
> doldur."*

### Kaynak bulundu

| Ekran | Editör | Kaynak |
|---|---|---|
| `MmTransaction/Index:62-71` | `#mmProductTypeSelectBox` | `MmTransaction` / **`GetProductDefinitions`** → `ValueExpr("Id")` · `DisplayExpr("Name")` |
| `InterbankLoan/Index:64-70` | `#ilProductTypeSelectBox` | `InterbankLoan` / **`GetProductDefinitions`** → aynı şekil |

### Bizdeki durum

- 🔴 UI'daki alt ürün listesi **`treasury.json`'da elle yazılı** (`subProducts`) — kullanıcının
  itirazı tam buraya.
- 🟢 MM tarafı **zaten referans veriden** çözüyor:
  `ResolveSubProductTypeIdAsync` → `productDefinitionDataManager.GetSubProductIdByCodeAsync(moduleCode, code)`.
  Yani sunucu tarafı hard-coded **değil**; yalnız **liste** UI'da sabit.

### Madde 5 için hedef tasarım

**UI**

1. `treasury.json` → statik `subProducts` yerine kaynak tanımı:
   ```json
   "subProductSource": { "controller": "MmTransaction", "action": "GetProductDefinitions" }
   ```
   (InterbankLoan ürünü için `"controller": "InterbankLoan"`.)
2. `#syncSubProducts` bu uca gidip listeyi doldurur.
3. `SelectBox` → **`TagBox`** (çoklu seçim, PO isteği).
4. Değer olarak **`Id`** gönderilir — o iki ekranın `ProductTypeId` olarak gönderdiği alanın aynısı.

**MM**

| Katman | Değişiklik |
|---|---|
| `EligibleTransactionsRequest` | `List<int>? SubProductTypeIds` **eklenir** (`SubProduct` string alanı **kalır** — doğrudan çağıranlar için) |
| `EligibleTransactionsHandler` | `SubProductTypeIds` doluysa onu kullan; boşsa `ResolveSubProductTypeIdAsync(SubProduct)` sonucunu tek elemanlı liste yap |
| `TransactionDataManager` + `TransactionLoanDataManager` | `int? subProductTypeId` → `IReadOnlyCollection<int>? subProductTypeIds`, filtre `Contains` |
| Testler | çoklu id + geriye dönük tek `SubProduct` yolu |

🔑 **Kazanç:** kod eşlemesi (`"MONEYMARKET"` → id) UI'dan tamamen kalkıyor; liste ürün tanımı
tablosundan geliyor. Yeni bir alt ürün tanımlandığında **hiçbir yerde kod değişmiyor** —
`treasury.json`'daki elle yazılı liste bugün bunu gerektiriyordu.

⚠️ `GetProductDefinitions` o modülün **tüm** ürün tanımlarını döndürüyor; reeskonta uygun olmayan
bir alt ürün seçilirse grid boş gelir (uygunluk filtresi süzer) — hata değil, ama alt ürün listesini
daraltmak gerekip gerekmediği **iş birimine sorulmalı**.


---

## 10. 🔴 DB doğrulaması — SubProduct kaynağı ve `Pas`/`Gil` (2026-08-24)

`PrdProductDefinition` okundu (sql-log `#34`-`#36`, `manuel-reeskont-kodlama`).

| Id | `Code` | `Name` | `MainProductCode` | `IsEnabled` |
|---|---|---|---|---|
| 1 | `MoneyMarket` | Money Market | MM | 1 |
| 2 | `Loan` | Interbank Loan | MM | 1 |
| 3 | `Issue` | Bond Issue | MM | 1 |
| 4 | `Wakale` | Wakale | MM | 1 |
| 5 | `Murabaha` | Murabaha | MM | 1 |
| 6 | `TermDeposit` | Term Deposit | MM | **0** |
| 7 | 🔴 **`Pass`** | **Pas** | MM | 1 |
| 8 | 🔴 **`Gil`** | **Gil** | MM | 1 |
| 9 | `Syndication` | Syndication | MM | 1 |
| 10 | `Securitization` | Securitization | MM | 1 |
| 11 | `Post-Financing` | Post-Financing | MM | 1 |

### 🔴 Bulgu 1 — `Pas` ekranda, `Pass` kodda

Kullanıcı *"hard olarak **Pass** ve **Gil** yazıp listeden çıkarabilirsin"* dedi ve **doğru** kodu
verdi: `Code = 'Pass'` (**çift `s`**), `Name = 'Pas'` (tek `s`).

⚠️ Filtre **`Code`** üzerinden yazılmalı. `Name` ile yazılırsa `'Pas' != 'Pass'` tuzağı oluşur ve
filtre sessizce çalışmaz.

Dışlanacak: `Code IN ('Pass', 'Gil')`.

### 🔴 Bulgu 2 — `MainProductCode` ayrım yapmıyor

**11 satırın hepsi `MainProductCode = 'MM'`.** Yani `MM Transactions` ile
`InterbankLoan Transactions` ayrımı bu kolonda **yok**; ayrım ürün tanımı seviyesinde
(`Loan` = Id 2 → InterbankLoan). `ModuleCode` kolonu tabloda **hiç yok**.

### Bulgu 3 — Referans ekranların filtreleri (kod okundu)

| Ekran | Filtre |
|---|---|
| `MmTransactionController.cs:825-829` | 🔴 **filtre YOK** — `ProductDefinitionOverviewRequest()` sonucunun **tamamı** |
| `InterbankLoanController.cs:420-433` | `!IsSameDay && !IsZeroRate`, sıralama `ExternalSubProductCode == "MLN" ? 0 : 1` → `ThenBy(ExternalSubProductCode)`. Yorum: *"Syndication, Securitization, Interbank Loan, Post-Financing"* |

### Madde 5 için nihai kural

| Ürün | Alt ürün listesi |
|---|---|
| `MMTransactions` | tüm ürün tanımları · `IsEnabled = 1` · **`Code NOT IN ('Pass','Gil')`** |
| `InterbankLoanTransactions` | `!IsSameDay && !IsZeroRate` · `IsEnabled = 1` · **`Code NOT IN ('Pass','Gil')`** |

`TermDeposit` `IsEnabled = 0` olduğu için zaten düşüyor.

---

## 11. ✅ Permission script'i üretildi

`.ai-agent/outputs/2026-08-24-manuel-reeskont-permission-script.sql`

🔴 **Çalıştırılmadı** — `mssql-read` skill'i yalnız `SELECT` yapar; script'i **kullanıcı uygular**.

| Ne | Kaç |
|---|---|
| `FrameworkPermission` | 6 satır (Treasury/Investment/Security × Displayer/Maker) — DB'de **zaten var**, idempotent |
| `FrameworkPermissionAction` | **9 satır** — asıl iş burada |

Eşleme:

| Permission | Action'lar |
|---|---|
| `*Reeskont_Displayer` | `<X>Rediscount/Index` · `<X>Rediscount/Load` |
| `*Reeskont_Maker` | `<X>Rediscount/Execute` |

🔴 **`_Checker` YOK** — bu ekranda maker-checker akışı yok, fiş anında kesiliyor.
🔴 **`_Maker` ayrı tutulmak zorunda:** `Execute` gerçek muhasebe fişi kesip Fimple'a gidiyor;
salt izleyen kullanıcı fiş kesememeli.

⚠️ **Permission adı ≠ controller adı** (bilinçli): permission'lar `...Reeskont...` (DB'de öyle),
controller'lar `...Rediscount...`. Eşleşme `ActionValue` üzerinden kuruluyor — permission adını
değiştirmeye gerek yok.

### Script sonrası 2 kritik adım

1. **Profile ataması** — script permission'ı *tanımlar*, kullanıcıya *atamaz*. `ProfilePermission`
   ekranından ilgili profile eklenmeli.
2. 🔴 **Redis cache** — `MEMORY.md`'deki kayıtlı tuzak: `GetModuleMenuHandler` menüyü
   `ModuleMenu:{UserId}` altında **8 saat** cache'liyor ve INSERT eden hiçbir yer temizlemiyor.
   Değişiklik sonrası `ModuleMenu:*` temizlenmeli.
