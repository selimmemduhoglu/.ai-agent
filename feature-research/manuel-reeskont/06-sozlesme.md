# 06 — SÖZLEŞME · **DONDURULDU** 🔒

> **Durum:** ✅ **DONDURULDU** — 2026-08-13
> **Yetki:** Kullanıcı (Selim) 2026-08-13'te açık talimat verdi: *"soruların varsa mevcut FX için yazılan
> şu an var olan manuel reeskont ekranına bakabilirsin, hali hazırda o ekran çalışıyor… bu benden yeni
> istenen yapıyı anlayıp en mantıklı olan sana nasıl geliyorsa sorularını o şekilde mantık yürüterek
> cevaplayarak yap"*
>
> **Bu dosya `manuel-reeskont` skill'inin KAPISI'dır.** DONDURULDU olduğu için **kod yazılabilir**.
> Değişiklik gerekirse: burayı güncelle → `02-mimari-karar.md`'ye ADR → etkilenen repoları listele (`R-11`).

**Kaynaklar:** doküman `Manuel Reeskont v1.docx` (**birincil**) · mevcut FX ekranı (**çalışan referans**) ·
mevcut FI `SecurityManuelReescont` ekranı · MM accounting altyapısı · Fimple gerçek payload'ları ·
**canlı DB ölçümü** (`mssql-read`)

---

## 0. Kararların dayanağı — neyi neye bakarak çözdüm

| Soru | Karar | Dayanak |
|---|---|---|
| **C-01** Aksiyon seti | **2 buton** (Generate · Regenerate), backend `Operation` alanıyla ayırır **+ satırın kendi durumu da gider** | Mevcut FX ekranında **tek buton** var (`btnReescontKes`) ve backend satırın `RediscountStatusType`'ına bakarak ne yapacağına karar veriyor. Doküman bunu **iki butona ayırıyor** — aynı backend davranışının UX olarak netleştirilmesi. Doküman birincil → 2 buton. Satır durumunun da gitmesi mevcut sözleşmeden **korunuyor** (doküman §4.5 "backend yeniden doğrular") |
| **C-01** `All` var mı | ✅ **VAR** — Status filtresi **tekil seçim**, içinde `All` seçeneği | `ManualRediscount.RediscountStatusTypes` içinde `All = 1` **var** ve `SelectBox` (tekil) ile bağlı. Doküman §3.5 "tek seçim" ile §4.7 "All eklenir" **çelişmiyor** — ikisi birlikte doğru: tekil dropdown, seçeneklerden biri `All` |
| **C-02** Product / SubProduct | **İkisi de TEKİL**, ikisi de zorunlu | **Kullanıcı kararı** (2026-08-13). Ayrıca doküman metni de tekil diyor |
| **C-05** `Rediscounted` satıra Generate | **`Failed[]`'a düşer**, sessizce atlanmaz | Doküman §4.5 backend'in yeniden doğrulamasını istiyor; sessiz atlama kullanıcıya "yaptım" yalanı söyler (`ADR-MR-007` ile aynı ilke) |
| **C-07** Senkron/asenkron | **SENKRON** (Faz 1-2). `Processing` durumu sözleşmede **rezerve**, kullanılmıyor | Mevcut FX ekranı **senkron** çalışıyor ve canlıda kullanılıyor: tek `$.ajax`, buton disable, sonra `refresh`. Asenkron altyapı (dokümanın kayıp §6.1) **yok**. Sayfalama (`Take ≤ 50`) 248 satırlık worst-case'i zaten kırıyor. Dikiş açık: `IManualRediscountExecutionDispatcher` |
| **C-08** `ExecutionsRequest` + `ReverseValueDate` | 🔴 **GÜNCELLENDİ 2026-08-18: alan `ReverseValueType` (enum T1/T0) oldu**, tarih alanı kaçış kapısı olarak kaldı — doküman § 6.4.3 zaten `enum?` diyordu, biz tarih olarak okumuşuz. Aşağıdaki gerekçe hâlâ geçerli (Fimple parametrik destekliyor), yalnız **kim hesaplıyor** değişti: artık modül | 🔑 MM kodu **zaten parametrik**: `FimpleAccountingService.cs:188-193` ters fişte `ReversAccountingTransactionDate: context.LogicalDate` gönderiyor, T+0 fişte `null`. Fimple de destekliyor. Dokümanın ikinci tanımında kaybolması **kopyala-yapıştır hatası** |
| **C-14** `Data` yerleşimi | Item'ın **içinde** `Data: Dictionary<string, object>` | **Kullanıcı açıklaması** (2026-08-13): *"ekrandaki kolonların modüllere göre değişkenlik gösterdiği için o alanların kolonları farklı, ona göre convert edilecek"* |
| **C-15** Kolon config yeri | **UI'de JSON dosyası**, ViewComponent hidden alana basar. `columns.url` dikişi açık | Mevcut ekranlar kolonları **Razor'da hard-code** ediyor (FX 21 kolon). Genel ekranda bu mümkün değil. Roundtrip'siz olması için `LimitCheckViewComponent` deseni |
| **M-02** SubProduct eşlemesi | **String**, listesi **kolon config'inden** gelir (ek endpoint YOK) | FX'in mevcut `RediscountProductTypes` (Fx/FXSwap/Pm/PmSwap/ExternalFWD/ExternalSWP) aslında **SubProduct** seviyesi. Yeni ekran üstüne bir seviye ekliyor (Product = modül). Doküman **2 endpoint** diyor → 3. endpoint açmamak için liste config'te |
| **M-05** Fimple yuvarlama | `RoundAwayFromZero(2)` — tutar alanları **2 ondalık** | Gerçek Fimple payload'ında `Debit: 14.47` / `Credit: 14.47` (2 ondalık). Workspace Hard Rule 4 + MM Hard Rule 11 |
| **M-07** Manuel fiş `AccountingType` | Fimple'a **`"Rediscount"`** (batch ile **aynı**); MM içi `accEntryMain.Type = 2` (Revaluation) | `FimpleAccountingService.cs:162` reeskont için `FimpleAccountingType.Rediscount` kullanıyor. Farklı tip göndermek EOD mutabakatını ve ters fiş zincirini bozar. Manuel-lik `StateMaker` ile ayrılır |
| **M-08** "Son aktif hareket" | 🔑 **`AccEntryMain`: `IsReverse = 0` satırın `ReverseId`'si 0 ise ters alınmamış, >0 ise alınmış** | **Canlı DB'den ölçüldü** (aşağıda § 6) |
| **R-04** `moduleCode` reddedilirse | Konu kapandı — Product **zaten** modülü belirliyor | Product tekil olduğu için `moduleCode` Product'tan türüyor; ayrı alan olarak da taşınıyor |

### 🔑 Product tekil olmasının **mimari sonucu**

Product tekil + zorunlu ⇒ **her sorgu tam olarak BİR modüle gider.**

| Sonuç | Etki |
|---|---|
| `Task.WhenAll` fan-out'u **normal akışta gerekmiyor** | `ADR-MR-008`'in "modül-başına try/catch" gereği basitleşiyor — yine de resolver çoklu modülü destekleyecek şekilde yazılıyor (Faz 3'te ProductGroup bazlı toplu görünüm istenirse) |
| 🔴 **`R-13` (çok modüllü sayfalama) ORTADAN KALKTI** | `Skip`/`Take`/`TotalCount` tek modülde uygulandığı için **doğru**. Bu, planın en büyük belirsizliğiydi |
| Kolon config **(ProductGroup, Product)** çiftine bağlanabiliyor | `Data` sözlüğü tek modülün şemasına göre çözülüyor |

---

## 1. Hiyerarşi ve ekranlar

```text
ProductGroup (ekran)        Product (tekil, → MODÜL)          SubProduct (tekil)
─────────────────────────────────────────────────────────────────────────────────────
Treasury                    FX Transactions      → FX          Fx · FXSwap · Pm · PmSwap ·
                                                               ExternalFWD · ExternalSWP
                            MM/Loan Transactions → MM          Murabaha · Wakala
                            Options              → OptFX       (ürün ekibi)
                            Derivatives          → DerivSWP    (ürün ekibi)
Security                    Security Transactions→ FI          Buy · Sell · Repo · ReverseRepo ·
                                                               DepoTransfer · CouponPayment · Maturation
Investment                  Fund Transactions    → InvFund     (ürün ekibi)
```

**Faz 1 kapsamı:** `Treasury` ekranı · Product = `MM/Loan Transactions` · Module = `MM`.

`SubProduct` her zaman **string**; `All` seçeneği **vardır** (tümü).

---

## 2. Endpoint sözleşmesi (modül API'leri — 2 uç)

Her modül **aynı iki ucu** açar. Yol modül tarafında:

```text
POST {module}/api/manual-rediscount/eligible-transactions
POST {module}/api/manual-rediscount/executions
```

WebUI bunlara **kendi Refit interface'iyle** gider (`ADR-MR-015`), araya `NetTrex.Common` **girmez**.

---

## 3. `eligible-transactions` — okuma

### 3.1 Request

```csharp
public sealed class EligibleTransactionsRequest
{
    public string ProductGroup { get; set; }      // "Treasury" | "Security" | "Investment"   (zorunlu)
    public string ModuleCode { get; set; }        // "MM" | "FX" | "FI" | "INVFUND"            (zorunlu)
    public string Product { get; set; }           // "MMLoanTransactions"                      (zorunlu, TEKİL)
    public string SubProduct { get; set; }        // "Murabaha"                    (zorunlu, TEKİL — §5.3)
    public List<string> RevaluationTypes { get; set; } = new();  // boş = tümü    (ÇOKLU — §5.3/§6.4.1)
    public Dictionary<string, object>? ExtraFilters { get; set; } // ürüne özgü ek filtre (§6.4.1)
    public DateTime ExecutionDate { get; set; }   // ekrandaki tarih filtresi (date, saat yok) (zorunlu)
    public int? Status { get; set; }              // null = All · aksi halde RediscountStatus  (TEKİL)
    public bool IsFirstLoad { get; set; }         // true → boş liste dön, sorgulama
    public int Skip { get; set; }                 // varsayılan 0
    public int Take { get; set; }                 // varsayılan 50, MAKSİMUM 2000
    public long CurrentUserId { get; set; }       // kimlik (token taşınmıyor — ADR-MR-012)
}
```

> `IsFirstLoad` mevcut FX sözleşmesinden **korundu** (`ManuelReescontSelectReqest.IsFirstLoad`).

### 3.2 Response

```csharp
public sealed class EligibleTransactionsResponse
{
    public bool IsSuccess { get; set; }
    public List<string> Messages { get; set; } = new();
    public int TotalCount { get; set; }                       // sayfalama için TOPLAM kayıt
    public List<ManualRediscountItem> Items { get; set; } = new();

    // ---- § 5.3 DURUM BAZLI ÖZET (grid üstü şerit) — sayfadan DEĞİL, filtrenin tamamından ----
    public ManualRediscountStatusSummary StatusSummary { get; set; } = new();
}

public sealed class ManualRediscountStatusSummary
{
    public int Total { get; set; }
    public int NotRediscounted { get; set; }
    public int NotReversed { get; set; }
    public int Rediscounted { get; set; }
    // "Processing / Error" kalemi UI'de TÜRETİLİR: Total − (diğer üçü). MM'de her zaman 0.
}

public sealed class ManualRediscountItem
{
    // ---- SABİT KOLONLAR — doküman § 5.1/§ 5.2 sırasıyla ----
    public long TransactionId { get; set; }                   // gizli · modül içi PK (TxnMm.Id / TxnLoan.Id)
    public string? Product { get; set; }                       // "Murabaha Borrowing" (boşsa alt ürün koduna düşer)
    public string LogicalReference { get; set; }              // "TMMBRW2606040005"
    public long? ExternalCustomerId { get; set; }             // karşı taraf müşteri numarası
    public string? ExternalCustomerName { get; set; }         // karşı taraf müşteri adı
    public int Status { get; set; }                           // RediscountStatus (aşağıda)
    public string? StatusDescription { get; set; }            // § 3.3 metinleri — modül üretir

    // ---- ÜRÜNE ÖZEL KOLONLAR ----
    public Dictionary<string, object?> Data { get; set; } = new();

    // ---- DESTEK ALANLARI (sabit kolon DEĞİL) ----
    public string SubProduct { get; set; }                    // "Murabaha" — filtre/gruplama
    public string? StatusReasonCode { get; set; }             // localize UI'de (ADR-MR-006)
    public string ProductSourceType { get; set; }             // "MoneyMarket" | "InterbankLoan" (MM'e özel ayrım)
    public string? RevaluationType { get; set; }              // § 4.6 karışık tip kuralı için
}
```

🔴 **`CustomerName` kaldırıldı**, yerine `ExternalCustomerId` + `ExternalCustomerName` geldi (§ 5.1 iki
ayrı kolon istiyor). 🔴 **`ValueDate` sabit kolon DEĞİL** — § 5.1 listesinde yok, `Data` sözlüğüne taşındı
ve ürün config'i üzerinden gösteriliyor.

🟢 **`MessageKey` salt gösterim olarak UI'ye gider (güncel, 2026-09-30):** `RediscountMessageKey` ve
`ReverseMessageKey` alanları yanıtta taşınır; **grid kolonu değildir**, yalnız onay penceresinde ve ayrı alan
olarak gösterilir (progress-60). `executions` hiçbirini girdi olarak kabul etmez — fiş `TransactionId`'den
çözülür. (Eski "UI'ye gönderilmez" kuralı 2026-08-21'de kaldırıldı, bkz. ek "9. tur".)

### 3.3 `Data` sözlüğü kuralları

| Kural |
|---|
| Anahtar **PascalCase**, kolon config'indeki `field` ile **birebir** aynı |
| Değer **primitif** olmalı: `string` · `decimal` · `DateTime` · `bool` · `int` · `null`. İç içe nesne/dizi **yok** |
| Para alanları **`decimal`**, `RoundAwayFromZero(2)` uygulanmış |
| Oran alanları **`decimal`**, 7 ondalık (mevcut ekran `RateFormatScaleSeven` kullanıyor) |
| Config'de olup `Data`'da olmayan anahtar → kolon **boş** gösterilir, hata **değil** |
| `Data`'da olup config'de olmayan anahtar → **görmezden gelinir** (ileri uyumluluk) |

**MM için `Data` anahtarları (Faz 1) — 13 anahtar:**

```text
ValueDate · TxnTypeCode · Direction · Currency · PrincipalAmount · InterestRate · StartDate ·
MaturityDate · AccruedInterest · DailyAccrual · PortfolioName · FundSourceName · DayCountBasis
```

> `ValueDate` buraya **sonradan taşındı** (2026-08-13): doküman § 5.1 sabit kolon listesinde yok.

---

## 4. `executions` — yazma

### 4.1 Request

```csharp
public sealed class ExecutionsRequest
{
    public string ProductGroup { get; set; }                  // zorunlu
    public string ModuleCode { get; set; }                    // zorunlu
    public string Product { get; set; }                       // zorunlu
    public RediscountOperation Operation { get; set; }        // Generate | Regenerate   (zorunlu)
    public DateTime ExecutionDate { get; set; }               // T+0 fiş valörü          (zorunlu)

    // 🔴 DEĞİŞTİ (2026-08-18): ters fiş valörü artık TARİH değil TÜR.
    // Doküman § 4.2 / § 6.4.3 / § 8.2 (image4) valörü serbest tarih olarak DEĞİL, iki seçenek
    // olarak tanımlıyor. Gerçek tarihi MODÜL hesaplar (T+1 = +1 İŞ GÜNÜ — takvim modülde).
    // § 6.4.3: yalnız `Not Reversed` satır işlenirken gönderilir, aksi halde null.
    public ReverseValueType? ReverseValueType { get; set; }   // T1 = 1 (varsayılan) | T0 = 2

    // Açık tarih — YALNIZCA `ReverseValueType` boşsa geçerli. Ekran BUNU GÖNDERMEZ;
    // ucu doğrudan çağıranlar (Swagger/entegrasyon/betik) için kaçış kapısı.
    public DateTime? ReverseValueDate { get; set; }

    public bool RegenerateToToday { get; set; }               // yalnız Regenerate'te anlamlı (**Faz 2**, doküman § 0.1)
    public List<ExecutionItem> Items { get; set; } = new();   // zorunlu, EN AZ 1
    public long CurrentUserId { get; set; }                   // zorunlu — StateMaker bundan yazılır
}

/// <summary>Ters fiş valörü — doküman § 4.2 / § 6.4.3. Serbest tarih YOK, iki seçenek var.</summary>
public enum ReverseValueType
{
    T1 = 1,   // varsayılan — ExecutionDate + 1 İŞ GÜNÜ (ICalendarHelper.NextWorkingDayAsync)
    T0 = 2    // aynı gün — ExecutionDate
}

public sealed class ExecutionItem
{
    public long TransactionId { get; set; }                   // zorunlu
    public string LogicalReference { get; set; }              // doğrulama/log için
    public int CurrentStatus { get; set; }                    // UI'nin gördüğü durum → backend YENİDEN doğrular (§4.5)
}

public enum RediscountOperation { Generate = 1, Regenerate = 2 }
```

> **Neden `Items[]` içinde `CurrentStatus` var:** mevcut FX sözleşmesinde de var
> (`RediscountTransactionUpdateItem.RediscountStatusType`). Doküman §4.5 backend'in durumu yeniden
> doğrulamasını istiyor — UI'nin gördüğü durum ile DB'deki durum **farklıysa** o satır `Failed[]`'a düşer
> (*"Kayıt siz listeyi açtıktan sonra değişti"*). Yarış koşulu koruması.

> 🔴 **`SelectAll` YOK.** Doküman "tüm veri kümesini seç" ima ediyor (C-10) ama sayfalama ile birlikte bu,
> kullanıcının **görmediği** satırlara fiş kesmek demek. Karar: seçim **her zaman açık `TransactionId` listesi**.
> "Tüm sayfaları seç" DevExtreme'de mümkün ama `Take ≤ 200` sınırıyla birlikte anlamlı ve güvenli.

### 4.2 Response

```csharp
public sealed class ExecutionsResponse
{
    public bool IsSuccess { get; set; }                       // Failed boş DEĞİLSE false
    public List<string> Messages { get; set; } = new();
    public List<ExecutionResultItem> Succeeded { get; set; } = new();
    public List<ExecutionResultItem> Failed { get; set; } = new();
}

public sealed class ExecutionResultItem
{
    public long TransactionId { get; set; }
    public string LogicalReference { get; set; }
    public int NewStatus { get; set; }                        // işlem sonrası durum
    public string? ReasonCode { get; set; }                   // Failed için zorunlu
    public string? ReasonDetail { get; set; }                 // Fimple hata metni vb.
}
```

🔴 **`IsSuccess = true` yalanı YASAK.** Mevcut FX akışının hatası buydu. `Failed` doluysa `IsSuccess = false`.

### 4.3 `ReasonCode` sözlüğü (UI localize eder — `ADR-MR-006`)

| Kod | Anlamı |
|---|---|
| `STATUS_CHANGED` | Satırın durumu listelendikten sonra değişti |
| `ALREADY_REDISCOUNTED` | `Rediscounted` satıra `Generate` geldi (**C-05**) |
| `NOT_REDISCOUNTED` | `Regenerate` istendi ama geri alınacak fiş yok |
| `NO_ACCRUAL` | Hesaplanacak tahakkuk yok (tutar 0) |
| `EXTERNAL_ERROR` | Fimple hatası — `ReasonDetail` Fimple metnini taşır |
| `NOT_WORKING_DAY` | ~~Valör iş günü değil~~ — 🔴 **KULLANILMIYOR** (2026-08-21): takvim kontrolü kalktığı için modül bu kodu hiç döndürmüyor. Sabit sözleşmede **rezerve** duruyor |
| `DUPLICATE_REQUEST` | Çift tıklama guard'ı yakaladı |
| `TRANSACTION_NOT_FOUND` | `TransactionId` bulunamadı / modüle ait değil |

---

## 5. Enum'lar

```csharp
public enum RediscountStatus
{
    Error          = 0,   // kalıcı DEĞİL — yalnız anlık UI (doküman §4.x)
    NotRediscounted= 1,
    Processing     = 2,   // REZERVE — Faz 1-2'de kullanılmıyor (C-07 senkron)
    NotReversed    = 3,
    Rediscounted   = 4,
}
```

> 🔴 **Mevcut modüllerin enum'ı FARKLI** — `ManualRediscount.RediscountStatusTypes`:
> `All=1, Rediscounted=2, NotRediscounted=3, NotReversed=5`.
> Yeni sözleşme **dokümanın** numaralandırmasını kullanır; FX/FI kendi iç enum'ını **uçta map eder**.
> `All` **row status değildir** — yalnız filtre değeridir ve sözleşmede `Status = null` ile ifade edilir.
> (Mevcut kod ikisini aynı enum'da karıştırıyor — bu bir kusur, tekrarlanmıyor.)

### Badge renkleri — 🔴 **doküman § 7.1 esas** (2026-08-13 düzeltildi)

Rozet **pastel zemin + koyu metin** (image2/image6); `MR_StatusPalette` → `{ bg, fg }`.

| Durum | Doküman rengi | `bg` | `fg` |
|---|---|---|---|
| `NotRediscounted` | turuncu | `#FDEBE0` | `#C0521F` |
| `Processing` | **mavi** | `#E5F1FB` | `#1F5FA8` |
| `NotReversed` | **sarı** | `#FCF3CF` | `#8A6D0B` |
| `Rediscounted` | yeşil | `#E7F4E4` | `#2E6B27` |
| `Error` | kırmızı | `#FDECEA` | `#A31D1D` |

> ⚠️ İlk sürüm renkleri **mevcut FX ekranından** (`Index.cshtml:246-275`) kopyalamıştı: orada
> `Processing` **sarı**, `NotReversed` **mor**. Doküman § 7.1 farklı söylüyor ve image1 (Status Flow)
> ile de tutarlı → **doküman kazandı**. Eski ekran ile doküman çeliştiğinde doküman esastır.

---

## 6. Durum türetme (M-08) — **canlı veriden doğrulandı**

`dbo.AccEntryMain` (2026-08-13, `mssql-read` ile ölçüldü):

| Ölçüm | Sonuç |
|---|---|
| `Type = 2` (Revaluation) | **2050** satır `IsReverse=0` · **1958** satır `IsReverse=1` → **92 ters alınmamış** |
| `ReverseId` | **hiç NULL değil** — yokluğu **`0`** ile ifade ediliyor |
| `MessageKey` | hiç NULL değil; eski kayıtlarda `0`, yenilerinde 18 haneli Fimple anahtarı |
| Zincir örneği | `Id=555801, IsReverse=0, ReverseId=555809` ⇄ `Id=555809, IsReverse=1, ReverseId=555801` — **çift yönlü** |
| `StateMaker` | orijinal fişte gerçek kullanıcı (`PARTNER.TREASY.002@…`), ters fişte **`SYSTEM`** → **`T-01` canlıda doğrulandı** |

### Türetme kuralı (kesin)

```sql
-- İşlem X, tarih D için (Type = 2 = Revaluation)
-- R = TOP 1 (IsReverse = 0 AND TxnId = X AND ValueDate = D) ORDER BY Id DESC

R yok                → NotRediscounted (1)
R var, ReverseId = 0 → NotReversed     (3)
R var, ReverseId > 0 → Rediscounted    (4)
```

✅ Tek `LEFT JOIN` + projeksiyon ile sayfalanabilir — **N+1 yok**.
⚠️ Aynı `TxnId`'nin **birden çok** tarihte revaluation kaydı var (ör. `TxnId=553292` → 07-30, 07-31, 08-04, 08-05)
→ tarih filtresi **zorunlu**, `ValueDate = ExecutionDate` ile eşleşir.
⚠️ `AccEntryMain.TxnId` hem `TxnMm` hem `TxnLoan`'a bakar → `ProductCode` + `ProductSourceType` ile ayır (`G-08`).

---

## 7. Fimple sözleşmesi (değişmiyor)

`POST /Fx/TreasuryTransactions/DoAccounting` — MM'de **zaten kurulu** (`FimpleAccountingService.cs`):

| Akış | `AccountingType` | `AccountingTransactionDate` | `ReversAccountingTransactionDate` | `ReverseMessageKey` |
|---|---|---|---|---|
| **T+0 reeskont** (satır 159-164) | `Rediscount` | `ExecutionDate` | `null` | `null` |
| **T+1 ters** (satır 188-193) | `Rediscount` | `null` | **`ReverseValueDate`** | orijinal `MessageKey` |

🔑 **Ters fiş valörü zaten parametrik** → buraya bağlanan değer, modülün `ReverseValueType`'tan
**hesapladığı** tarihtir (`ExecutionsHandler.ResolveReverseValueDateAsync`):
`T0` → `ExecutionDate` · `T1` → `ICalendarHelper.NextWorkingDayAsync(ExecutionDate)`.
🔴 **Düz `AddDays(1)` KULLANILIR** — T+1 = **+1 takvim günü** (`ADR-MR-027`, kullanıcı kararı 2026-08-21). Takvim servisi ve `MMSystemWDFlag` **okunmaz**; Cuma + 1 gün = Cumartesi ve bu **bilinçli**. Dokümanın eski *"1 iş günü"* ifadesi iş birimiyle konuşularak **takvim günü** olarak değiştirildi.

Detay + alternatif API önerileri → [`07-fimple-entegrasyon.md`](07-fimple-entegrasyon.md)

---

## 8. Kolon config şeması (UI tarafı)

`wwwroot/js/config/manual-rediscount/{productGroup}.json` — ekran başına **tek** dosya, içinde `products[]`.
Örnek: `treasury.json`

Alan adları **doküman § 5.5** ile birebir: `key` · `caption` · `dataType` · `format` · `alignment` · `order` · `width`.

```json
{
  "productGroup": "Treasury",
  "products": [
    {
      "product": "MMLoanTransactions",
      "moduleCode": "MM",
      "subProducts": [
        { "value": "Murabaha", "text": "Murabaha" },
        { "value": "Wakala",   "text": "Wakala" }
      ],
      "revaluationTypes": [
        { "value": "InterestAccrual", "text": "Interest Accrual" }
      ],
      "columns": [
        { "key": "ValueDate",       "caption": "mr-col-ValueDate",       "dataType": "date",  "width": 105, "order": 1 },
        { "key": "TxnTypeCode",     "caption": "mr-col-TxnTypeCode",     "dataType": "string","width": 90,  "order": 2 },
        { "key": "PrincipalAmount", "caption": "mr-col-PrincipalAmount", "dataType": "money", "width": 140, "order": 5,
          "format": "#,##0.00", "alignment": "right" }
      ]
    }
  ]
}
```

| `dataType` | Varsayılan format | Hizalama |
|---|---|---|
| `money` | `#,##0.00` (`format` ezer) | sağ |
| `rate` | `#,##0.#######` (`format` ezer) | sağ |
| `date` | DevExtreme `date` | varsayılan |
| `string` / `bool` / `int` | ham | varsayılan |

**Kurallar:**

- `order` verilmezse **dizi sırası** korunur.
- `alignment` verilirse tip varsayılanını **ezer**.
- `key` boşsa satır **atılır** — `Data.undefined` kolonu üretilmez.
- Config'de olup veride olmayan anahtar → boş hücre **+ konsol uyarısı** (§ 5.5).
- `revaluationTypes` tanımlı değilse **Revaluation Type filtresi gizlenir** (`C-03`: bu listeyi
  döndüren ayrı uç açılmaz, § 6.2 "2 endpoint dışında uç tanımlanmaz").

> 🔁 **Eski şema (`field` / `captionKey` / `type`) hâlâ kabul edilir** (`mrNormalizeColumnConfig`).
> Config dosyaları ürün ekiplerinde; hepsi aynı anda güncellenemez, eski şemayla yazılmış config kırılmaz.

> ⚠️ **`baseUrl` alanı YOK** (`ADR-MR-002`) — `moduleCode` var. İş birimine sözleşme değişikliği olarak bildirilecek.

---

## 9. Aksiyon × Durum matrisi (kesin)

| Satır durumu | **Generate** | **Regenerate** |
|---|---|---|
| `NotRediscounted` | T+0 reeskont fişi kes → **`NotReversed`** | 🔴 **Yeni değerleme oluştur** → `Rediscounted` (image6: *"Önceki değerleme bulunmadığından yeni değerleme oluşturulur"*) |
| `NotReversed` | T+1 ters fiş kes → **`Rediscounted`** | Ters fiş kes + yeni T+0 + T+1 → **`Rediscounted`** |
| `Rediscounted` | ❌ `Failed`: `ALREADY_REDISCOUNTED` (**C-05**) | Geri al + yeniden değerle → **`Rediscounted`** |
| `Error` / `Processing` | ❌ `Failed`: `OUT_OF_SCOPE` | ❌ `Failed`: `OUT_OF_SCOPE` |

> 🔴 **2026-08-13 düzeltmesi (davranış hatası):** `Regenerate` + `NotRediscounted` eskiden
> `NOT_REDISCOUNTED` ile **fail** ediyordu. image6 bunun tersini söylüyor — geri alınacak bir şey yoksa
> **yeni değerleme oluşturulur**. `ExecutionsHandler.RegenerateAsync` düzeltildi, test yenilendi.
>
> `Error`/`Processing` için `STATUS_CHANGED` yerine **`OUT_OF_SCOPE`** kullanılıyor: § 4.6
> *"kapsam dışında bırakılır"* diyor — kapsam dışı olmak **durum değişikliği değildir**.
> ⚠️ MM'de bu iki durum DB türetmesinden **hiç çıkmaz** (`ReverseId` null/0/>0 → 3 değer);
> backend dalı **savunma amaçlı**, gerçek filtreleme UI tarafında.

**UI kuralları:**

- Seçili satırların **tamamı aynı Revaluation Type** değilse `Generate` **pasif** (doküman §4.6) +
  buton altında **kalıcı ipucu**: *"Seçim birden çok Revaluation Type içerdiğinden Generate pasiftir"* (image3)
- Hiç satır seçili değilse iki buton da **pasif**
- Aksiyon çalışırken butonlar **disable** (mevcut ekranın `btnInstance.option("disabled", true)` deseni)
- İşlem bitince grid **refresh** + seçim **temizlenir**
- Onay penceresi: `Generate` → madde listesi (image5) · `Regenerate` → **durum bazlı kırılım** (image6),
  `Processing/Error` satırı yalnız **kayıt varsa** basılır

---

## 10. Doğrulama (validator) kuralları

| Alan | Kural |
|---|---|
| `ProductGroup` | Boş olamaz · `Treasury`/`Security`/`Investment` |
| `ModuleCode` | Boş olamaz · modülün kendi kodu ile **eşleşmeli** (MM ucu `MM` dışında bir değer görürse hata) |
| `Product` | Boş olamaz |
| `SubProduct` | 🔴 **Boş olamaz** (§ 5.3 *"boş gönderilemez"*) — UI ilk alt ürünü otomatik seçer |
| `RevaluationTypes` | Boş = tümü · doluysa satırın tipi listede yoksa satır **listelenmez** |
| `ExecutionDate` | Boş olamaz · **gelecek tarih olamaz**. 🔴 **İş günü kontrolü YOK** — doküman önceden *"iş günü olmalı"* diyordu; **dokümanı yazan iş birimiyle konuşuldu ve takvim günü olarak değiştirildi** (2026-08-21). Takvim/tatil hiçbir yerde okunmuyor — T+1 kuralıyla (`ADR-MR-027`) tutarlı |
| `ReverseValueType` | `null` · `1` (T+1) · `2` (T+0) — başka değer **hata** |
| `ReverseValueDate` | `null` veya **`>= ExecutionDate`** — 🔴 kural `>` iken `>=` yapıldı (2026-08-18): doküman § 8.2 **T+0'ı açıkça sunuyor**, eski kural onu yasaklıyordu. Yalnız `ReverseValueType` boşsa dikkate alınır |
| `Take` | `1..2000` — aşarsa **2000'e sabitlenir** (hata değil). 🔴 Tavan 2026-08-21'de 200'den 2000'e çıktı: ekran grid'i client-side, bir kapsamın **tüm statüleri** tek istekte çekiliyor (`ADR-MR-028`) |
| `Skip` | `>= 0` |
| `Items` | En az 1, en fazla **50** kayıt · `TransactionId` **tekil** olmalı. 🔴 **Sınır 2026-08-19'da 10 → 50 oldu** çünkü ekran artık satırları **parçalamıyor**: seçili satırların tamamı **TEK istekte** gidiyor ve döngü backend'te dönüyor (kullanıcı kararı: *"tek seferde gitsin ama içerde dönsün, her transaction için istek gitmiyor, performanslı olmaz"*). Değer grid'in sayfa boyutuyla (50) hizalı; UI ikizi `MR_MAX_EXECUTE_ITEMS`. Aşılırsa istek **hiç işlenmez** (`TOO_MANY_ITEMS`), sessizce kırpılmaz. ⚠️ 50 satır en kötü durumda dakikalar sürer → WebUI→MM Refit client timeout'u **10 dakika** (`Startup.cs` → `ManualRediscountRefitRegistration.RegisterManualRediscountMmApiTimeout`; ⚠️ **paylasılan** `RefitExtensions.cs`'e DOKUNULMADI); bu ayar olmadan `HttpClient` varsayılanı **100 sn**'dir ve iş **arka planda sürerken** istek iptal edilir |
| `CurrentUserId` | `> 0` — yoksa `StateMaker` yazılamaz |

---

## 11. Yetki

Ekran başına ayrı controller (`ADR-MR-003`) → permission = `ControllerAdı/ActionAdı`:

| Ekran | Controller | Permission |
|---|---|---|
| Treasury | `TreasuryRediscountController` | `TreasuryRediscount/Index` · `/Load` · `/Execute` |
| Security | `SecurityRediscountController` | `SecurityRediscount/*` |
| Investment | `InvestmentRediscountController` | `InvestmentRediscount/*` |

---

## 12. Bu sözleşmenin **dışında** bırakılanlar

| Ne | Neden |
|---|---|
| `SelectAll` (tüm veri kümesi) | Görülmeyen satıra fiş kesme riski — açık `TransactionId` listesi (§4.1) |
| Asenkron `executions` + `Processing` | Mevcut ekran senkron çalışıyor; dikiş açık (`IManualRediscountExecutionDispatcher`) |
| 3. endpoint (SubProduct lookup) | Doküman 2 endpoint diyor — liste kolon config'inde |
| `RegenerateToToday` | Alan sözleşmede **var**, davranışı **Faz 3** |
| Fimple bulk/batch API'leri | Öneri olarak `07`'de; baseline değişmiyor |

---

## 13. Değişiklik kaydı

| Tarih | Değişiklik |
|---|---|
| 2026-08-13 | **İlk sürüm — DONDURULDU.** C-01/02/05/07/08/14/15 + M-02/05/07/08 + R-04 kapatıldı; dayanaklar § 0'da |
| 2026-08-13 (2) | **Doküman uyumluluk turu** — `09-dokuman-uyumluluk-raporu.md`'deki 9 eksik kapatıldı: item'a `Product`/`ExternalCustomerId`/`ExternalCustomerName`/`StatusDescription`; response'a `StatusSummary`; request'e `RevaluationTypes`+`ExtraFilters`; `SubProduct` **zorunlu**; `CustomerName` **kaldırıldı**, `ValueDate` **`Data`'ya taşındı**; kolon sırası § 5.2'ye, config şeması § 5.5 adlarına, rozet renkleri § 7.1'e çekildi; `Regenerate`+`NotRediscounted` **davranış hatası** düzeltildi (`OUT_OF_SCOPE` reason code eklendi); giriş noktaları `Html.DevExtreme().ManualRediscount()` + `ManualRediscount.init()` |


---

## 🔴 EK — 2026-08-19 sözleşme notları (kullanıcı kararları)

### 1. Execute **TEK istek**, döngü modülde

Ekran seçili satırların **tamamını** tek `executions` çağrısında gönderir. Parçalama
(`MR_EXECUTE_CHUNK_SIZE = 1`, 2026-08-18) **kaldırıldı**.

| Şart | Nerede karşılanıyor |
|---|---|
| Satır bazlı sonuç (`Succeeded[]` / `Failed[]`) | `ExecutionsHandler` — satır başına `try/catch` (`ADR-MR-007`) |
| *"hata alınmayanlar hata alınanlardan bozulmasın"* | aynı yerde — bir satırın patlaması döngüyü kesmez |
| Timeout | Refit client timeout'u **10 dk** — ayar **yalnız `IManualRediscountMmApi`** için, ekranın kendi klasöründe (`ManualRediscountRefitRegistration.cs`) |

🟥 **Kaybedilen garanti:** timeout/ağ hatasında **kısmi sonuç** taşınamaz. Modül fişleri kesmiş olsa
bile ekran `succeeded[]`/`failed[]` göremez; hata metni kullanıcıya *"listeyi yenileyin"* der.
Bu, tek isteğin kabul edilen bedelidir.

### 2. `Processing` durumu artık **ÜRETİLİYOR** (`D-6` kapandı)

Doküman § 3.1 tanımı: *"İşlem core banking sistemine iletilmiş olup sonucu beklenmektedir. Bu durum
**geçici** olup sistemde kalıcı olarak saklanmaz."* image1 akışta **iki** ara adım olarak gösteriyor.

| Katman | Davranış |
|---|---|
| **Modül** | `Processing` **döndürmez** — akış senkron, `NewStatus` yalnız kalıcı durum taşır (`C-07` hâlâ açık) |
| **Ekran** | İstek uçmadan hemen önce gönderilen satırlar **`Processing`** gösterilir (`mrSetPendingOverlay`), yanıt gelince sonuç durumuyla değiştirilir. **DB'ye yazılmaz** |

### 3. 🔴 `CurrentStatus` = **en son bilinen KALICI durum**

Ekran Execute sonrası `refresh()` **çağırmaz** (§ 8.4: sonuç ekranda kalır). Bu yüzden satır
verisindeki `Status` bayat olabilir.

**Kural:** `Items[].CurrentStatus` alanına gönderilen değer, ekranın **en son bildiği kalıcı** durumdur:
- işlem **başarılı** olduysa → dönen `NewStatus`
- işlem **hata** aldıysa → değişmez (DB'de bir şey değişmedi)
- **`Error` (0) ve `Processing` (2) ASLA gönderilmez** — ikisi de kalıcı durum değil (§ 3.1)

Modül tarafı bu değeri § 4.5 gereği DB ile karşılaştırmaya devam eder (`STATUS_CHANGED`).
Uygulama: `mrEffectiveStatus` / overlay'in `dbStatus` alanı.

### 4. Generate **tek statü** ister (`D-10`)

🟨 **Dokümandan bilinçli SAPMA.** § 5.3 *"her kayıt üzerinde uygulanacak işlem, kaydın kendi durumuna
göre belirlenir"* diyor; § 4.6 pasifleştirmeyi **yalnız Revaluation Type** için tanımlıyor.

**Kullanıcı kararı 2026-08-19:** seçimde **birden çok Status** varsa **Generate pasif**.
**Regenerate etkilenmez** — o her satırı aynı sonuca (`Rediscounted`) götürüyor.

Sözleşmeye etkisi: **yok** (tamamen UI kapısı). Modül karışık statülü isteği kabul etmeye devam eder;
doğrudan çağıranlar (Swagger/betik) için davranış değişmedi.

### 5. Toplu seçim menüsü **YOK** (`D-9`)

§ 5.4 / § 8.3'ün `Select All / 100 / 50 / 25 / Custom` menüsü ve `"100 of 248 selected"` göstergesi
**kaldırıldı** (kullanıcı: *"datagrid'imdeki yapı pagination şeklinde, o yeterli"*).
Sözleşmeye etkisi **yok** — `SelectAll` gibi bir alan hiç açılmamıştı (§ 12).


---

## 🔴 EK — 2026-08-20 · `ReverseValueType` aksiyona göre yorumlanır

Analist kararı: **Regenerate'te ters fiş valörü sorulmaz.**

| Aksiyon | `ReverseValueType` | Modülün davranışı |
|---|---|---|
| **Generate** | `1` (T+1) / `2` (T+0) | **Okunur ve uygulanır** (§ 4.2 / § 8.2). Yalnız `Not Reversed` satırlar ters fiş üretir |
| **Regenerate** | ekran `1` gönderir | 🔴 **YOK SAYILIR.** Valörler sabit: nötrleme **T+0** · yeni reeskont **T+0** · yeni ters fiş **T+1** (`NextWorkingDay(executionDate)`) |

**Sözleşme alanı KALDIRILMADI** — Generate için gerekli, ayrıca doğrudan çağıranların (Swagger,
betik) gövdesi bozulmasın. Regenerate'te gönderilen değer sessizce yok sayılır.

### Nötrleme valörü (dokümanın tanımlamadığı nokta)

`Not Reversed` bir satır Regenerate edilirken **iki** ters fiş kesilir:

| # | Ne | Valör |
|---|---|---|
| ① | Eski açık reeskontu **kapatan** kayıt | **T+0** (execution date) |
| ③ | Yeni reeskontun ters fişi | **T+1** (bir sonraki **takvim** günü) |

🔴 ① için T+0 **zorunlu**: aynı gün açılan reeskont aynı gün kapanmalı. T+1 olsaydı eski fiş bir
sonraki güne kapanır, o günün defterinde **hem eski hem yeni** reeskont açık görünür ve
**çift tahakkuk** okunurdu.

Doküman § 4.3 kapatma kaydının valörünü tanımlamıyordu; bu, iş analistiyle netleştirilmiş bir
karardır ve **3 birim testiyle kilitlenmiştir**.

---

## 🔴 EK — 2026-08-21 · Kolon filtreleri + ilerleme ucu + T+1'in kaynağı

Üç sözleşme değişikliği. İkisi **alan ekleme** (geriye uyumlu), biri **davranış netleştirme**.

### 1. `eligible-transactions` → `Filters` (YENİ alan)

```csharp
public sealed class ManualRediscountColumnFilters
{
    public string? LogicalReference { get; set; }        // contains (LIKE %değer%)
    public string? ExternalCustomerId { get; set; }      // METİN olarak contains ("272" → 27253)
    public string? ExternalCustomerName { get; set; }    // contains
    public string? SearchText { get; set; }              // yukarıdaki üç alanda OR
}

// EligibleTransactionsRequest'e eklendi:
public ManualRediscountColumnFilters? Filters { get; set; }   // null / boş → filtre yok
```

**Neden sunucuda** (kullanıcı kararı 2026-08-20): grid `remoteOperations.paging` ile çalışıyor.
Tarayıcıda süzmek yalnız **yüklü sayfayı** süzer → kullanıcı "3 kayıt var" sanır, `TotalCount` ve
durum özeti (§ 5.3) filtreyle çelişir. Finansal ekranda kabul edilemez.

🔴 **Modülün uyması gereken 3 kural:**

1. Filtre **sayımlardan ÖNCE** uygulanır — `TotalCount` **ve** `StatusSummary` filtrelenmiş kümeyi anlatır.
2. Eşleşme **contains**, büyük/küçük harf duyarsız. Boş/whitespace alan **yok sayılır**.
3. Müşteri alanları **EXISTS** ile filtrelenir (`Any(...)`), navigation dereference ile **DEĞİL** —
   required navigation `INNER JOIN` üretip orphan FK'lı satırı sessizce siler (iki kez yaşandı).

**Filtrelenebilen alanlar YALNIZ bunlar.** `Data` sözlüğündeki ürüne özel kolonlar modülün
projeksiyonunda **türetiliyor** (tahakkuk toplamı, dönem faizi, portföy adı) → SQL'de filtrelenemez.
UI o kolonlarda filtre kutusu **açmaz**; `Status` filtresi pill grubunda kalır.

⚠️ **UI → sözleşme çevirisi UI'nin sorumluluğunda:** DevExtreme filtreyi ifade ağacı olarak veriyor,
`mrBuildServerFilters` yalnız şu üç şekli çeviriyor — tek koşul · `and` zinciri · aynı değerli `or`
(= arama kutusu). Çevrilemeyen ifade **uygulanmaz** ve kullanıcıya bildirilir (sessizce yok sayılmaz).

### 2. ~~`ProgressKey` + `executions/progress`~~ — 🔴 **GERİ ALINDI (2026-08-21)**

Bu turda eklenen ilerleme ucu ve `ProgressKey` alanı **kaldırıldı** (kullanıcı kararı:
*"Polling ile yaptığın tüm geliştirmeleri kaldır, Faz 1 için gerekli değilmiş."*).
Modüllerın **yapacak işi yok**: `executions` isteğinde böyle bir alan **beklenmiyor**, `progress`
diye bir uç **açılmayacak**. Ekran Execute sırasında yalnız kapsamı yazıyor.

### 3. T+1 = **ExecutionDate + 1 TAKVİM GÜNÜ** 🔴 (kural 2026-08-21'de değişti)

```
T+0  →  ExecutionDate
T+1  →  ExecutionDate.AddDays(1)      // tatil/hafta sonu kontrolü YOK
```

**Kullanıcı kararı** (kendi sözleriyle): *"Reverse için T+1 konusu için NextWorkingDay'e de bakma
SystemWDFlag'ine de bakma, direkt +1 gün deyip ilerleyelim… takvim günü olarak öyle ilerleyelim,
bu kesin bilgidir, her zaman 1 gün sonra olsun."*

| Önceki (2026-08-20) | Şimdi (2026-08-21) |
|---|---|
| `MMSystemWDFlag` okunur; `WeekdaysOnly`→+1 iş günü, diğerleri→+1 takvim günü | **Hiçbir parametre okunmaz**; her zaman +1 takvim günü |

🔴 **Modüller için zorunlu:** bu hesap **tek bir sınıfta** olmalı ve `executions` ile önizleme
ucu **aynısını** çağırmalı (`ADR-MR-025`). MM'de `ManualRediscountValueDateResolver`.

ℹ️ **Bilgi (davranışı etkilemez, ama bilinmesi gerek):** MM batch'i ters fişi hesaplanan bir ileri
tarihe değil, `ReverseBatchItem`'ın **kendi koşu gününün** `ExecDate`'ine kesiyor. Batch'in ters fişi
aynı güne mi sonraki güne mi kestiğini `Revaluation:MM.ReverseType` (`Eod`/`Bod`/`Atomic`), hangi
günlerde koştuğunu `SystemWDFlag` belirliyor. Ekran bu mekanizmayı **taklit etmiyor** — kullanıcı
kararıyla tek ve sabit kural uyguluyor. Ekran bu iki parametreyi kullanıcıya **gösteriyor**
(`ValueDates.ReverseType` ve grid ipuçları) ki farkı görebilsin.

### 4. `ValueDates` — ters fiş valör önizlemesi (YENİ, opsiyonel)

```jsonc
{
  "totalCount": 248,
  "items": [ /* ... */ ],
  "statusSummary": { /* ... */ },

  // YENİ — opsiyonel, null olabilir
  "valueDates": {
    "executionDate": "2026-08-21T00:00:00",  // T+0 — reeskont fişinin valörü
    "nextDate":      "2026-08-22T00:00:00",  // T+1 — +1 TAKVİM GÜNÜ
    "reverseType":   "Bod"                   // Eod | Bod | Atomic (bilgi amaçlı)
  }
}
```

| Alan | Kural |
|------|-------|
| `executionDate` | İsteğin `ExecutionDate`'i (gün bazında) |
| `nextDate` | `ExecutionDate + 1 takvim günü` — **hesap modülde**, UI'da değil |
| `reverseType` | `Revaluation:MM.ReverseType` adı; ekran ipuçunda gösteriyor |

🔴 **UI bu tarihi HESAPLAMAZ.** Modül bloğu vermezse valör kolonu **boş** kalır — tahmin edilmez.
⚠️ Hesap patlarsa blok `null` döner ve **liste normal gelir**; önizleme grid'in gelmemesine sebep olamaz.

### Cross-repo etki zinciri

| Repo | Ne yapmalı |
|---|---|
| `NetTrex.MM` | ✅ yapıldı (2 data manager + handler + yeni uç + 21 test) |
| `NetTrex.Web.UI` | ✅ yapıldı (DTO + Refit + `Progress` action + JS/CSS + 20 test) |
| `NetTrex.Fx` · FI · InvFund (Faz 2) | 🔴 `Filters` alanını **aynı adlarla** uygulamalı; uygulamazsa filtre **sessizce yok sayılır** (grid filtreli görünür, sonuç filtresiz gelir). `ValueDates` bloğu **opsiyonel** — doldurulmazsa valör kolonu boş görünür (kırılma yok) |
| `Treasy.MicroUI.Packages` (Faz 3) | dokunulmadı |

---

## Ek — 2026-08-21 (9. tur): `AccountingEntryId` / `AccountingMessageKey`

`eligible-transactions` yanıtındaki her satıra **iki opsiyonel alan** eklendi:

```jsonc
{
  "transactionId": 552549968,
  "logicalReference": "TMMBRW2505220009",
  "status": 3,
  "accountingEntryId": 555801,            // YENI — o tarihteki reeskont fişinin AccEntryMain.Id
  "accountingMessageKey": 695090587964321792  // YENI — Fimple mesaj anahtarı (yalnız ipuçu)
}
```

| Alan | Kural |
|------|-------|
| `accountingEntryId` | Durum türetilirken bulunan **aynı** fişin `Id`'si. Fiş yoksa `null` → ekran hücreyi **boş** gösterir (0 yazmaz) |
| `accountingMessageKey` | Aynı fişin `MessageKey`'i. Yalnız ipuçunda gösterilir |

🔴 **§ 12'nin *"MessageKey son kullanıcıya gösterilmez"* maddesi kaldırıldı** (kullanıcı kararı
2026-08-21): operasyon kesilen fişi muhasebe ekranında bulmak istiyor. İki alan da **salt
gösterim**; `executions` hiçbirini girdi olarak kabul etmez — fiş hâlâ `TransactionId`'den çözülür.

⚠️ Alanlar **aynı alt sorgu zinciriyle** (aynı `Where` + `OrderByDescending(Id)`) okunmalı ki
numara ile durum **aynı fişten** gelsin; farklı sıralama yazılırsa ekran başka bir fişin numarasını
gösterir.

| Repo | Durum |
|------|-------|
| `NetTrex.MM` | ✅ uygulandı (iki data manager + `MapItem`) |
| `NetTrex.Web.UI` | ✅ DTO + **Fiş No** kolonu + `/AccountingEntry/Index?accMainId=` linki |
| `NetTrex.Fx` · FI · InvFund | ⬜ Faz 2 — doldurulmazsa kolon **boş** görünür (kırılma yok) |

---

## Ek — 2026-08-21 (10. tur): grid client-side → `Status` ve `Filters` **gönderilmiyor**

Kullanıcı kararı (kendi sözleriyle): *"ben grid için her seferinde statüs filtrelerinde sunucuya
gitmek istemiyorum, tarih için her statüdeki datayı getirip statülere göre filtrelemeni istiyorum."*

**Sözleşme değişmedi — kullanımı değişti:**

| Alan | Modül | Ekran (Web.UI) |
|------|-------|----------------|
| `Status` | ✅ destekliyor (değişmedi) | ❌ **her zaman `null`** — tüm statüler istenir, süzgeç tarayicida |
| `Filters` | ✅ destekliyor (değişmedi) | ❌ **her zaman `null`** — kolon filtresi tarayicida |
| `Skip` | ✅ | her zaman `0` |
| `Take` | ✅ tavan **2000** | `2000` (`MR_MAX_LOAD_ROWS`) |
| `StatusSummary` (yanıt) | ✅ doluyor | ❌ okunmuyor — şerit tarayicida hesaplanıyor (`ADR-MR-029`) |
| `TotalCount` (yanıt) | ✅ | ✅ **kirpilma tespiti** için: `TotalCount > Items.Count` → ekran uyarır |

🔴 **Alanlar KALDIRILMADI**: modül ucu başka bir tüketici (Faz 2 MicroUI, dış sistem, rapor)
tarafından sayfalı/filtreli kullanılabilir. Silmek, çalışan ve testli bir yeteneği bu ekranın
tercihine kurban etmek olurdu.

⚠️ **Fx / FI / InvFund uygularken:** `Take` tavanını **2000** kabul edin ve `TotalCount`'u
**filtrenin tamamı** için doldurun — ekranın kirpilma uyarısı tam bu karşılaştırmaya dayanıyor.
`TotalCount = Items.Count` döndüren bir modül, eksik listeyi **sessiz** hale getirir.
