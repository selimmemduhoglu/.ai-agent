# 11 — Statü Algoritması: Değerleme Döngüsü (kanıtlı)

**Tarih:** 2026-08-26 · **Kaynak kod:** `NetTrex.MM` branch `main-manuel-reeskont-squash`
**Durum:** 🔴 **v1 (2026-08-25) YANLIŞTI** — düzeltildi. Aşağısı geçerli sürüm.

---

## 0. v1'in hatası

v1'de *"`Rediscounted` = reeskont fişinin tersi var, tersin valörüne bakılmıyor"* yazmıştım ve
doküman § 3.2'deki **"(t+1)"** parantezini *"yalnızca tanımlayıcı"* saymıştım. **Yanlış.**

Kullanıcının uyarısı doğru çıktı: **değerleme döngüsü** belirleyici. Kanıt bir sonraki bölümde.

---

## 1. 🔴 Kanıt — EOD batch'i kuralı zaten uyguluyor

`TransactionDataManager.GetPendingRevaluationTransactions` (satır 615+) — **canlıda her gece
koşan** sorgu. "Bugün reeskont kesilecekler" kümesini **iki dalın `Union`**'ı olarak kuruyor:

```csharp
// (a) o güne hiç reeskont fişi olmayanlar
var noRevaluationQuery = query.Where(x =>
    !x.AccountingMainEntries.Any(w => w.ValueDate == logicalDate &&
                                      w.Type == Revaluation && !w.IsReverse));

// (b) o güne fişi OLAN ama tersi DE AYNI GÜNE kesilmiş olanlar
var revaluationReverseCheck = query.Where(x =>
    x.AccountingMainEntries
        .Where(a => a.ValueDate == logicalDate && a.Type == Revaluation &&
                    a.ReverseId != 0 && !a.IsReverse)
        .OrderByDescending(a => a.Id).Select(a => a.ReverseId).Take(1)
        .Any(reverseId => x.AccountingMainEntries.Any(f =>
            f.Id == reverseId &&
            f.ValueDate == logicalDate)));      // 🔑 TERSİN VALÖRÜ = O GÜN

var finalQuery = noRevaluationQuery.Union(revaluationReverseCheck);
```

Metodun **kendi XML yorumu** bunu yazıyor:

> *"Includes transactions that either have **no revaluation** for the given date **or whose
> revaluation was reversed on the same date**."*

**Sonuç:** platform, tersi aynı güne kesilmiş bir reeskontu **"reeskont yok"** sayıp **yeniden
kesiyor**. Yani o gün **değerlenmemiş** kabul ediliyor.

Doküman § 3.2 aynısını söylüyor:

> *Not Rediscounted: … **veya en son oluşturulan reeskont kaydı ile buna ait ters fişin aynı
> değerleme döngüsü içerisinde kapanmış olması** halinde oluşur.*

---

## 2. Defter matematiği — neden böyle

Reeskont fişi gün-T'ye `+A`, ters fişi kendi valörüne `−A` yazıyor
(`AccountingReverseFactory`: Debit ↔ Credit takas, **aynı tutar**).

| Senaryo | Gün-T | Gün-T+1 | Anlamı |
|---|---|---|---|
| R(T,+A) · ters yok | **+A** | — | tahakkuk açıkta → `NotReversed` |
| R(T,+A) · Rev(**T+1**,−A) | **+A** | −A | gün-T defterinde tahakkuk **durdu** → **değerlendi** → `Rediscounted` |
| R(T,+A) · Rev(**T+0**,−A) | **0** | — | aynı gün açılıp kapandı → **iptal** → `NotRediscounted` |

🔑 **T+0 ters fiş bir "tamamlama" değil, bir "geri alma" aksiyonudur.** § 4.2'nin T+0 seçeneği
ancak böyle anlam kazanıyor.

⚠️ **Doküman § 4.2 ile çelişki bilinçli olarak doküman aleyhine çözüldü.** § 4.2, T+0 seçilirse
kaydın `Rediscounted` olacağını yazıyor; bu § 3.2 ve EOD batch'i ile çelişiyor. Kullanıcı kararı:
**değerleme döngüsü esas**.

---

## 3. Geçerli algoritma

**Adım 1 — o güne ait en son reeskont fişi** (değişmedi):

```csharp
AccEntryMain kayıtlarından:  Type = Revaluation · IsReverse = false
                             ValueDate == ExecutionDate
                             ProductCode == transaction.Product.MainProductCode
en yüksek Id  →  o fişin ReverseId'si
```

**Adım 2 — ters fişin VALÖRÜ** (yeni):

```csharp
ReverseValueDate = ReverseId > 0 ? (o fişin ValueDate'i) : null
```

**Adım 3 — türetme** (`ManualRediscountStatusResolver.Resolve`):

| Koşul | Durum |
|---|---|
| `ReverseId == null` (o güne fiş yok) | `NotRediscounted` |
| `ReverseId == 0` (tersi yok) | `NotReversed` |
| `ReverseValueDate == null` (ters fiş satırı **bulunamadı**) | `NotReversed` — veri anomalisi, tahakkuk açıkta |
| `ReverseValueDate > ExecutionDate` | **`Rediscounted`** |
| `ReverseValueDate <= ExecutionDate` | **`NotRediscounted`** (iptal) |

⚠️ EOD `==` ile karşılaştırıyor, biz `<=`. Valörü `ExecutionDate`'ten **önce** olan bir ters fiş de
gün-T tahakkukunu taşımıyor; `==` ile böyle bir satır `Rediscounted` görünüp "değerlendi" yalanı
üretirdi.

### Kuralın üç kopyası — birlikte değişir

| Yer | Ne yapıyor |
|---|---|
| `ManualRediscountStatusResolver` (`Api.Services/ManualRediscount`) | **Bellekte** türetme — tek gerçek kaynak |
| `TransactionDataManager.GetRediscountEligibleTransactionsAsync` | **SQL** filtre + üç sayım (MM) |
| `TransactionLoanDataManager.GetRediscountEligibleTransactionsAsync` | **SQL** filtre + üç sayım (Loan) |

Katman yönü ters (Data → Api.Services referansı yok) olduğu için ortak sınıfa alınamadı.
🔴 Biri değişirse **diğerleri de** değişmeli: ayrışırsa ekran bir durum gösterir, yazma ucu
başkasını doğrular ve **her satır `STATUS_CHANGED` ile reddedilir**.

⚠️ SQL'de üç dal **toplamda tüm satırları kapsamak zorunda**; aksi halde bir satır hiçbir kovaya
düşmez, `TotalCount`'ta sayılır ama listede görünmez ("özet N diyor, grid boş" tuzağı).
`ReverseValueDate == null` bu yüzden **açıkça** `NotReversed` kovasına yazıldı.

---

## 4. 🔴 Reeskont motoru MUTLAK tutar basıyor — delta değil

v1'de *"doğrulamadım"* dediğim soru. Cevap: **mutlak (kümülatif)**.

`SLCalculatorContextMapper`:

```csharp
.Map(dest => dest.PassedDay, src => (src.LogicalDate - src.CashFlow.StartDate).Days + 1)
```

`SLCalculator`:

```csharp
rateComponent = Rate * PassedDay / (DaysInYear * 100);
totalAccruedAmount = PrincipalAmount * (rateComponent + spreadComponent);
```

`PassedDay` = **dönem başından** o güne kadar geçen gün. Yani tutar, faiz döneminin başından
`ExecutionDate`'e kadar **birikmiş toplam tahakkuk**. Bu tutar `AccrualAmount` olarak doğrudan
muhasebe fişine gidiyor (`AccountingManagerRevaluationAccountingContextMapper:31`).

Ve `20_RevaluationAccountingPersistChangeStep` **koşulsuz `InsertAsync`** yapıyor — o güne fiş var
mı diye **bakmıyor**.

**Sonuç:** aynı güne ikinci bir reeskont kesilirse gün-T bakiyesi `A1 + A2` olur — yaklaşık **iki
katı**. Delta olsaydı sorun olmayacaktı; değil.

ℹ️ Değerleme **tablosu** (`TxnMMDailyCalculation`) idempotent: `RevaluationAccountingPersister`
aynı `(transactionId, calculationDate)` satırını **siliyor** ve yenisini yazıyor. Yani ekranda
gördüğün tahakkuk doğru kalıyor; bozulan şey **muhasebe defteri**.

---

## 5. 🔴 `Regenerate` + `Rediscounted` — çift tahakkuk onarıldı

**Eskiden:** statü `Rediscounted` iken hiçbir şey nötrlenmiyordu, doğrudan ikinci bir
reeskont+ters çifti ekleniyordu → gün-T bakiyesi **çift**.

**Şimdi** iki aşamalı (doküman § 4.3):

```
1. AŞAMA — gün-T'yi net sıfıra indir
   NotRediscounted  → yapılacak bir şey yok (zaten sıfır)
   NotReversed      → mevcut fişe T+0 ters fiş
   Rediscounted     → İKİ karşı kayıt:
                        (a) R1'in karşı kaydı, valör = R1.ValueDate   (T)   → gün-T: +A1 −A1 = 0
                        (b) Rev1'in karşı kaydı, valör = Rev1.ValueDate (T+1) → gün-T+1: −A1 +A1 = 0
2. AŞAMA — yeni R2(T) + Rev2(T+1)
```

Yalnız (a) yapılsa gün-T doğru olur ama gün-T+1'de fazladan `−A1` kalırdı. **İkisi de şart.**

Nötrleme yapılamıyorsa (ters fiş satırı kayıp) **hiç fiş kesilmiyor** — devam etmek bakiyeyi
çiftlerdi.

### ⚠️ Bu, platformda yeni bir hareket türü

MM'de bugüne kadar **hiçbir akış** tersi alınmış bir fişi ya da bir ters fişi tekrar terslemiyordu
— muhasebe **silme** akışı bile yalnız `ReverseId == 0` olanı tersliyor
(`GetNonReverseRevaluationWithTransactionIdAsync`).

- **Mekanizma yeni değil:** `IRevaluationReverseAccountingService` herhangi bir fişi herhangi bir
  valörle tersleyebiliyor, guard'ı **yok**.
- **Kullanımı yeni** → 🔴 **Fimple tarafında duman testi yapılmadan canlıya alınmamalı.**
- Blast radius **1 dosya**: `ExecutionsHandler`. Paylaşılan muhasebe servislerine/factory'ye
  dokunulmadı.

### Yan etki — ölçüldü, güvenli

Ters fiş kesmek kaynak fişin `ReverseId`'sini **üzerine yazıyor**
(`10_RevaluationReverseAccountingPersistChangeStep`), yani `R1 → Rev1` geri-işaretçisi kayboluyor.
`ReverseId`'nin **tüm** okuyucuları tarandı: hepsi ya `== 0` / `!= 0` testi yapıyor, ya da o
tarihin **en son** fişini alıyor. Hiçbiri `R1 ↔ Rev1` kimliğini yürümüyor.

EOD'nin `GetPendingRevaluationTransactions`'ı da en son fişi (yeni `R2`) aldığı için doğru sonucu
veriyor: `R2.ReverseId → Rev2(T+1) ≠ T` → "reeskont var, iptal edilmemiş" → yeniden kesmiyor. ✅

---

## 6. `Generate` + `NotReversed` + T+0 — yeni durum düzeltildi

Eskiden **sabit** `Rediscounted` dönüyordu. Artık valöre bağlı:

| Ters fiş valörü | Yeni durum |
|---|---|
| **T+1** | `Rediscounted` |
| **T+0** | `NotRediscounted` (iptal) |

Sabit `Rediscounted` dönmek T+0 seçen kullanıcıya "değerlendi" yalanı söylüyordu; sayfa
yenilendiğinde satır `NotRediscounted` görünüyor ve ikisi çelişiyordu.

---

## 7. Kapsam sorgusu — 5. şart neden var

Soru: *"neden `o tarihte aktif faiz dönemi var` şartına baktık, gerçekten gerekli miydi?"*

**Evet, zorunlu.** İki bağımsız gerekçe:

**(a) Emsal — uydurulmadı.** `GetPendingRevaluationTransactions` (EOD) aynı şartı kullanıyor;
kalıp **2025-07-16**'dan beri kodda (`git log -S "PeriodEndDate > logicalDate"` →
`fda5e5638`). Ekran ile batch'in **aynı kümeyi** görmesi için birebir alındı.

**(b) Motorun kendi ön koşulu.** Reeskont motoru işlemi şöyle çekiyor
(`GetTransactionForRevaluationEngineAsync`):

```csharp
.Include(x => x.Details.Where(w =>
        w.PeriodEndDate > logicalDate &&
        w.PeriodStartDate <= logicalDate &&
        !w.IsPrincipalAmount))
```

ve mapper **guard'sız** `First()` çağırıyor:

```csharp
var transactionCashFlow = transactionEntity.Details.First();   // RevaluationEnginePipelineContextMapper:23
```

O tarihi kapsayan faiz dönemi satırı yoksa koleksiyon **boş** → `InvalidOperationException:
Sequence contains no elements`. Yani şart kaldırılsa ekran, **Generate'e basınca patlayacak**
satırları listeler ve kullanıcı anlamsız bir `EXTERNAL_ERROR` görürdü.

⚠️ Not: kod yorumumdaki *"EOD ile birebir aynı"* ifadesi **tam doğru değil** — EOD'nin açılış-fişi
kontrolünde `ProductCode` şartı **yok**, bizde **var** (MM ↔ Loan ayrımı). Ekranın kapsamı EOD'nin
**alt kümesi**. Diğer dört şart karakter karakter aynı.

---

## 8. Generate / Regenerate — güncel matris

`ExecutionDate` hesabın **bazı**; hangi işlemin yapılacağını **statü** belirliyor. Sunucu, UI'nin
gönderdiği `CurrentStatus`'ü **yeniden doğruluyor** (§ 4.5) — uyuşmazsa `STATUS_CHANGED`.

| Statü | **Generate** | **Regenerate** |
|---|---|---|
| `NotRediscounted` | Reeskont (valör = T) → `NotReversed` | Yeni çift: R(T) + Rev(T+1) → `Rediscounted` |
| `NotReversed` | Ters fiş, valör = kullanıcının T+0/T+1 seçimi → **T+1: `Rediscounted` · T+0: `NotRediscounted`** | Mevcut fişe T+0 ters (nötrleme) → yeni çift → `Rediscounted` |
| `Rediscounted` | ❌ `ALREADY_REDISCOUNTED` | **İki karşı kayıt** (T ve T+1) → yeni çift → `Rediscounted` |
| `Processing`/`Error` | ❌ `OUT_OF_SCOPE` | ❌ `OUT_OF_SCOPE` |

- T+1 = ExecutionDate + 1 takvim günü (`ManualRediscountValueDateResolver`), iş günü kontrolü yok.
- Regenerate'te kullanıcının T+0/T+1 seçimi **yok sayılır** — her zaman T+1.
- `RegenerateToToday`: T'den bugüne her gün, üst sınır 31 gün; bir gün patlarsa zincir durur.
- İstek başına en fazla 50 satır; aşılırsa istek **hiç işlenmez**.

---

## 9. Dokunulan dosyalar

| Dosya | Ne |
|---|---|
| `ManualRediscountStatusResolver.cs` | **YENİ** — döngü farkında türetme, tek gerçek kaynak |
| `TDMRediscountEligibleResult.cs` | `ReverseValueDate` alanı |
| `TransactionDataManager.cs` | 2 aşamalı projeksiyon · 3 filtre dalı · 3 sayım |
| `TransactionLoanDataManager.cs` | aynısı (Loan) |
| `IAccountingDataManager` + `AccountingDataManager` | `GetEntryValueDateAsync` |
| `EligibleTransactionsHandler.cs` | resolver'a bağlandı, yerel `DeriveStatus` **silindi** |
| `ExecutionsHandler.cs` | resolver · T+0 yeni durum · `NeutralizeCompletedCycleAsync` |
| `EligibleTransactionsHandlerTests.cs` · `ExecutionsHandlerTests.cs` | döngü matrisi + çift tahakkuk testleri |

---

## 10. Test edilmesi gerekenler (tarayıcı + Fimple)

1. Tersi **T+0** kesilmiş bir satır ekranda **`Not Rediscounted`** görünüyor mu?
2. `Not Reversed` satıra **T+0** ile Generate → rozet `Not Rediscounted` mı?
3. `Rediscounted` satıra Regenerate → **üç** ters fiş kesiliyor mu (2 nötrleme + 1 yeni) ve
   Fimple hepsini kabul ediyor mu? 🔴 **Karşı kayıtların Fimple'da reddedilme riski burada.**
4. Regenerate sonrası gün-T defter bakiyesi **çift değil** mi (`AccEntryMain` + Fimple).
5. Özet şeridi sayıları grid'le tutarlı mı (üç kovanın toplamı = Total).
