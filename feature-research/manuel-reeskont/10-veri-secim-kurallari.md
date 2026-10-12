# 10 — Manuel Reeskont: Bir tarih seçtiğimde hangi işlemler listelenir?

> **Amaç:** ekranın veri seçim kurallarını **iş birimine anlatılabilir** biçimde, **koddan
> doğrulanmış** olarak yazmak. Her kuralın yanında gerçek kod satırı var; hiçbir madde yorum değil.
>
> **Kaynak dosyalar (MM):**
> `Data/NetTrex.MM.Data/Managers/Transaction/TransactionDataManager.cs` → `GetRediscountEligibleTransactionsAsync`
> `Data/NetTrex.MM.Data/Managers/InterbankLoan/TransactionLoanDataManager.cs` (Interbank Loan karşılığı)
> `Api/NetTrex.MM.Api.Services/ManualRediscount/Handlers/EligibleTransactionsHandler.cs`
>
> **Tarih:** 2026-08-21

---

## 0. Tek paragrafta cevap (iş birimi için)

> Ekran, seçtiğiniz **işlem tarihinde faiz tahakkuku olması gereken** Money Market / Interbank Loan
> işlemlerini listeler. Bir işlemin listeye girmesi için o tarihte **onaylı** olması, **başlamış**
> ama **vadesi gelmemiş** olması, **açılış muhasebe fişinin kesilmiş** olması ve o tarihin
> **açık bir faiz döneminin içinde** kalması gerekir. Bu beş şart, gün sonu (EOD) reeskont
> **batch'inin kullandığı şartların birebir aynısıdır** — yani ekran, batch'in o gün işleyeceği
> işlem kümesini gösterir. Listedeki her satırın **durumu** (Not Rediscounted / Not Reversed /
> Rediscounted) o tarihe ait muhasebe fişine bakılarak **hesaplanır**; işlemin üzerinde tutulan bir
> alan değildir.

---

## 1. Sorgu hiç çalışmayan hâl: üç filtre de zorunlu

Ekranın üstündeki üç alan (**Execution Date**, **Product**, **Sub Product**) **zorunludur**. Biri
boşken sunucuya **hiç** gidilmez; grid "seçim yapın" mesajını gösterir.

```javascript
// manual-rediscount.component.js — #buildRequest()
IsFirstLoad: mrIsEmpty(product) || mrIsEmpty(subProduct) || mrIsEmpty(executionDate),
```

```csharp
// EligibleTransactionsHandler.cs
if (request.IsFirstLoad)
    return new EligibleTransactionsResponse { IsSuccess = true, TotalCount = 0 };
```

🔴 **İş kuralı:** *"alt ürün seçimi tekildir ve boş gönderilemez"* (doküman § 5.3). Bu yüzden alt
ürün listesi ekran açılırken **ilk seçenekle otomatik dolar** — kullanıcı boş bırakamaz.

⚠️ **İşlem tarihi geçmiş bir gün olabilir**, ama **gelecek tarih olamaz** ve **iş günü kontrolü
yoktur** (iş birimi kararı 2026-08-21 — hafta sonu/tatil de seçilebilir).

---

## 2. Satır seviyesindeki beş şart — kodun tamamı

Aşağıdaki blok, ekranın veri kaynağının **tek** filtre bloğudur (Money Market yolu):

```csharp
// TransactionDataManager.GetRediscountEligibleTransactionsAsync
var revaluationType = AccountingType.Revaluation.ToIntValue();   // 2
var openingType     = AccountingType.Opening.ToIntValue();       // 1

var query = transactionRepository.Queryable()
    .AsNoTracking()
    .Where(x => StateConstants.VerifiedStatesId.Contains((int)x.StateId) &&        // (1)
                x.MaturityDate > executionDate &&                                  // (2)
                x.ValueDate <= executionDate &&                                    // (3)
                x.AccountingMainEntries.Any(w => w.Type == openingType &&          // (4)
                                                 w.ProductCode == x.Product.MainProductCode) &&
                x.Details.Any(w => w.IsPrincipalAmount == false &&                 // (5)
                                   w.PeriodStartDate <= executionDate &&
                                   w.PeriodEndDate > executionDate));

if (subProductTypeId.HasValue)                                                     // (6)
    query = query.Where(x => x.TxnMmProductTypeId == subProductTypeId.Value);
```

| # | Kod | İş dilinde ne demek | Neden böyle |
|---|-----|---------------------|-------------|
| **1** | `StateConstants.VerifiedStatesId.Contains(x.StateId)` | İşlem **onaylı/doğrulanmış** durumda | Taslak, onay bekleyen, iptal edilmiş işleme reeskont kesilmez. Küme framework'ten gelir ve **batch ile aynıdır** |
| **2** | `x.MaturityDate > executionDate` | **Vadesi seçilen tarihten sonra** | Vadesi gelen işlem o gün kapanır (Maturation fişi); artık reeskont üretmez. ⚠️ Vade **tam o gün** ise satır **gelmez** (`>` kullanılıyor) |
| **3** | `x.ValueDate <= executionDate` | İşlem **başlamış** (valörü gelmiş) | İleri valörlü işlem o gün faiz işletmez |
| **4** | `AccountingMainEntries.Any(Type == Opening && ProductCode == Product.MainProductCode)` | İşlemin **açılış fişi kesilmiş** | Muhasebeye hiç girmemiş işleme reeskont fişi kesilemez. 🔴 `ProductCode` karşılaştırması **zorunlu**: `accEntryMain` tablosu MM / Interbank Loan / Tawarruq için **paylaşılan** ve ayırt edici bir kolon yok — filtresiz kullanımda başka ürünün fişi bu satıra sayılırdı |
| **5** | `Details.Any(!IsPrincipalAmount && PeriodStartDate <= executionDate && PeriodEndDate > executionDate)` | Seçilen tarih **açık bir faiz döneminin içinde** | Reeskont = o güne düşen faiz tahakkuku. Tarih hiçbir faiz döneminin içinde değilse tahakkuk edecek bir şey yok. ⚠️ Dönem **tam o gün bitiyorsa** (`PeriodEndDate == tarih`) satır **gelmez** |
| **6** | `x.TxnMmProductTypeId == subProductTypeId` | Seçilen **alt ürün** | Alt ürün tekil ve zorunlu |

### 2.1 Interbank Loan farkı — tek madde

Aynı beş şart geçerlidir; **faiz dönemi başka tabloda** durur:

```csharp
// TransactionLoanDataManager — (5)'in Interbank Loan karşılığı
x.CashFlows.Any(w => w.FlowTypeId == interestFlowType &&
                     w.PeriodStartDate <= executionDate &&
                     w.PeriodEndDate > executionDate)
```

Alt ürün de `x.ProductDefinitionId` üzerinden süzülür (MM'de `TxnMmProductTypeId`).

> ⚠️ **Interbank Loan satırlarında `Accrued Interest` / `Daily Accrual` kolonları BOŞ gelir.**
> `TxnLoan` tarafında MM'deki günlük tahakkuk tablosunun karşılığı yok; doğru formül iş birimiyle
> netleşmediği için **bilerek** doldurulmadı (uydurulmuş bir tutar göstermek yerine boş bırakıldı).

### 2.2 Alt ürün adı → koddaki karşılığı

```csharp
// EligibleTransactionsHandler.ResolveSubProductTypeId
"MURABAHA"      => ProductAccountingCodeType.MURABAHA
"WAKALA"/"WAKALE" => ProductAccountingCodeType.WAKALE
"MONEYMARKET"   => ProductAccountingCodeType.MONEYMARKET
"TERMDEPOSIT"   => ProductAccountingCodeType.TERMDEPOSIT
"PASSGIL" => 7 · "SYNDICATION" => 9 · "SECURITIZATION" => 10 · "POSTFINANCING" => 11
```

🔴 Listede olmayan bir alt ürün adı gelirse **filtre uygulanmaz** (tüm alt ürünler döner) — yeni bir
alt ürün tanımlanırsa bu eşleme **güncellenmelidir**.

---

## 3. Durum (Status) nasıl hesaplanıyor — bu bir kolon değil

Listedeki her satırın durumu, **o tarihe ait reeskont fişine** bakılarak türetilir:

```csharp
// TransactionDataManager — projeksiyon
RediscountReverseId = x.AccountingMainEntries
    .Where(a => a.Type == revaluationType && !a.IsReverse &&
                a.ValueDate == executionDate &&
                a.ProductCode == x.Product.MainProductCode)
    .OrderByDescending(a => a.Id)
    .Select(a => (int?)a.ReverseId)
    .FirstOrDefault();
```

```csharp
// EligibleTransactionsHandler.DeriveStatus
null => RediscountStatus.NotRediscounted,   // o tarihe reeskont fişi HİÇ kesilmemiş
0    => RediscountStatus.NotReversed,       // reeskont fişi var, TERS FİŞİ yok
_    => RediscountStatus.Rediscounted       // reeskont + ters fiş tamam
```

| Durum | Ne demek | Ekranda ne yapılabilir |
|-------|----------|------------------------|
| **Not Rediscounted** | O tarihe reeskont fişi hiç kesilmemiş | **Generate** → T+0 reeskont fişi keser |
| **Not Reversed** | Reeskont fişi var, ters fişi yok | **Generate** → yalnız ters fişi keser (valörü sorulur: T+1 / T+0) |
| **Rediscounted** | İkisi de tamam | **Regenerate** → eskisini nötrler, yeniden kesler |

🔴 **İş birimine anlatılması gereken en önemli nokta:** durum **tarihe göre** hesaplanır. Aynı işlem
**21.08 için "Not Rediscounted"**, **20.08 için "Rediscounted"** görünebilir. Bu bir tutarsızlık
değil, tanımın kendisi: reeskont **gün bazlı** bir işlemdir ve her gün için ayrı fiş kesilir.

⚠️ `ReverseId` kolonu veritabanında **NOT NULL**'dır; "yok" hâli **0** ile ifade edilir. Bu yüzden
`IS NULL` sorgusu çalışmaz — üç durumun ayrımı `null / 0 / >0` üçlüsüyle yapılır.

---

## 4. Ters fiş valörü kolonu — gerçek mi, önizleme mi?

| Satırın hâli | Kolonda ne yazar | Kaynak |
|---|---|---|
| Ters fiş **kesilmiş** | Fişin **gerçek** valörü | `accEntryMain.ValueDate` (ters fiş kaydı) |
| Ters fiş **kesilmemiş** | **Önizleme** (T+1 = işlem tarihi + 1 takvim günü) — *italik/soluk* yazılır | Kural, modülde tek sınıfta |
| **Not Rediscounted** | `-` | Bu adımda ters fiş kesilmiyor |

🔴 **Neden ayrım şart:** ters fişin valörünü **kullanıcı seçiyor** (T+1 varsayılan, T+0 mümkün).
Ekran, kesilmiş bir fişin tarihini **kuraldan türetirse** yalan söyler — 2026-08-21'de tam bu yaşandı:
T+0 ile kesilen bir satırda kolon T+1 gösteriyordu. Artık kesilmiş fişin tarihi **muhasebeden**
okunuyor.

```csharp
// TransactionDataManager — ters fişin GERÇEK valörü (EXISTS ile, join YOK)
RediscountReverseValueDate = x.AccountingMainEntries
    .Where(r => r.IsReverse && r.Type == revaluationType &&
                r.ProductCode == x.Product.MainProductCode &&
                x.AccountingMainEntries.Any(a =>
                    a.Id == r.ReverseId && !a.IsReverse &&
                    a.Type == revaluationType &&
                    a.ValueDate == executionDate &&
                    a.ProductCode == x.Product.MainProductCode))
    .OrderByDescending(r => r.Id)
    .Select(r => (DateTime?)r.ValueDate)
    .FirstOrDefault();
```

---

## 5. Listeye **girmeyen** işlemler (sık sorulan)

| Neden gelmedi | Hangi şart |
|---|---|
| İşlem onaylı değil (taslak / onay bekliyor / iptal) | (1) |
| Vadesi geçmiş **veya vadesi tam o gün** | (2) |
| İleri valörlü (henüz başlamamış) | (3) |
| Açılış muhasebe fişi kesilmemiş | (4) |
| O tarih hiçbir faiz döneminin içinde değil (**veya dönem tam o gün bitiyor**) | (5) |
| Başka alt üründen | (6) |
| **Interbank Loan** işlemi, ama ürün olarak "MM Transactions" seçilmiş | Ürün seçimi — ikisi **ayrı ürün**, ayrı tablolar (`TxnMM` / `TxnLoan`) |
| Ana para satırı (faiz olmayan detay) | (5) — `IsPrincipalAmount == false` |

---

## 6. Batch (EOD) ile aynı listeyi mi görüyoruz?

**Uygunluk şartları birebir aynı** — kod yorumu bunu açıkça söylüyor:

```csharp
// Uygunluk filtresi — mevcut EOD sorgusuyla (GetPendingRevaluationTransactions) BİREBİR aynı,
// böylece ekran ile batch aynı işlem kümesini görür.
```

Kalan farklar **bilinçli**:

| Konu | Ekran | Batch |
|---|---|---|
| Kapsam | seçilen **tek** tarih + **tek** alt ürün | koşu günü + kurulu tüm ürünler |
| Ters fiş valörü | **T+1 = +1 takvim günü** (ya da kullanıcı T+0 der) | kendi koşu gününe keser; `Revaluation:MM.ReverseType` (Eod/Bod/Atomic) belirler |
| Hafta sonu | tarih serbest, kontrol yok | `SystemWDFlag` `WeekdaysOnly` ise hafta sonu **koşmaz** |
| Tetikleyen | kullanıcı, satır seçerek | zamanlanmış iş, tüm küme |

🔴 **Bilinen ödün:** `WeekdaysOnly` kurulu bir müşteride ekran Cumartesi valörlü ters fiş kesebilir,
batch ise Pazartesi'ye keserdi. İş birimi kararı: **her zaman +1 takvim günü** (tek ve öngörülebilir
kural). Fimple hafta sonu valörünü reddederse kural yeniden konuşulacak.

---

## 7. Grid üstündeki sayılar nereden geliyor?

`Toplam 12 kayıt · 9 Not Rediscounted · 0 Not Reversed · 3 Rediscounted`

Bu sayılar **tarayıcıda**, listenin **o an gösterdiği küme** üzerinden hesaplanır. Kolon filtresi
yazdığınızda sayılar **aynı anda** küçülür; şerit ile tablodaki satır sayısı **asla** çelişmez.

⚠️ Bir kapsamda **2000'den fazla** uygun işlem varsa liste kırpılır ve şeritte **kırmızı uyarı**
çıkar (*"Yalnızca ilk 2000 / N kayıt"*). O durumda kapsamı daraltmak (tarih / alt ürün) gerekir —
eksik listeyle karar verilmesin diye sessiz kalınmıyor.

---

## 8. İş birimi/operasyon kendi doğrulamasını yapmak isterse (salt-okunur SQL)

Aşağıdaki sorgu, ekranın **uygunluk** filtresinin SQL karşılığıdır. Tarihi ve alt ürünü değiştirip
sayının ekranla eşleştiği doğrulanabilir.
🔴 **Yalnızca `SELECT`** — hiçbir şey değiştirmez.

```sql
DECLARE @ExecutionDate date = '2026-08-21';
DECLARE @SubProductTypeId int = NULL;   -- NULL = tüm alt ürünler

SELECT TOP (20)
       t.Id,
       t.LogicalReference,
       t.ValueDate,
       t.MaturityDate,
       -- Durum: o tarihteki EN SON ters-olmayan reeskont fişinin ReverseId'si
       -- (yok = Not Rediscounted · 0 = Not Reversed · >0 = Rediscounted)
       (SELECT TOP (1) a.ReverseId
          FROM accEntryMain a
         WHERE a.TxnId = t.Id AND a.Type = 2 AND a.IsReverse = 0
           AND a.ValueDate = @ExecutionDate
           AND a.ProductCode = p.MainProductCode
         ORDER BY a.Id DESC) AS RediscountReverseId
  FROM TxnMM t
  JOIN prdProductDefinition p ON p.Id = t.TxnMmProductTypeId
 WHERE t.MaturityDate > @ExecutionDate
   AND t.ValueDate   <= @ExecutionDate
   AND (@SubProductTypeId IS NULL OR t.TxnMmProductTypeId = @SubProductTypeId)
   AND EXISTS (SELECT 1 FROM accEntryMain o
                WHERE o.TxnId = t.Id AND o.Type = 1
                  AND o.ProductCode = p.MainProductCode)
   AND EXISTS (SELECT 1 FROM txnMMDetail d
                WHERE d.TxnId = t.Id AND d.IsPrincipalAmount = 0
                  AND d.PeriodStartDate <= @ExecutionDate
                  AND d.PeriodEndDate   >  @ExecutionDate)
 ORDER BY t.Id DESC;
```

⚠️ **Bu sorguda eksik olan tek şart: `StateId` (onaylı durum) filtresi.** Onaylı state kümesi
(`StateConstants.VerifiedStatesId`) framework paketinden geliyor ve **kaynak kodda okunamadı**
(*tespit edilmedi*) → sayılar ekrandan **fazla** çıkabilir; fark onaysız işlemlerdir. Kesin liste
gerekiyorsa state kümesi framework tarafından teyit edilip `AND t.StateId IN (...)` eklenmelidir.

📌 `Type = 1` = Opening · `Type = 2` = Revaluation (`AccountingType` enum'ı).
📌 Tablolar: `TxnMM` · `txnMMDetail` · `accEntryMain` · `prdProductDefinition`
(kolon adları property adlarıyla birebir — EF'te `HasColumnName` override'ı yok).

---

## 9. Özet — tek slaytlık anlatım

1. **Tarih + Ürün + Alt Ürün** seç (üçü zorunlu).
2. Ekran o tarihte **faiz tahakkuku olması gereken onaylı işlemleri** getirir — batch'in gördüğü küme.
3. Her satırın **durumu** o tarihin muhasebe fişinden **hesaplanır**, işlemde saklı değildir.
4. **Generate** bir adım ilerletir (reeskont → ters fiş), **Regenerate** baştan kesler.
5. Ters fiş valörü: **kesilmişse gerçek tarih**, kesilmemişse **T+1 önizlemesi** (+1 takvim günü).
6. Sayılar ve filtreler **tarayıcıda** çalışır; 2000 satır üstünde **uyarı** çıkar.
