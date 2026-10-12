# progress-34 — Statü doğrulaması, Fimple hata teşhis planı, filtre genişliği

**Tarih:** 2026-08-20 (3. tur)
**Tetikleyen:** Kullanıcının 7 maddesi + dokümanın (`Manuel Reeskont v1.docx`) yeniden okunması

---

## 1. Doküman yeniden okundu — statü mantığı DOĞRU

`.docx` `word/document.xml`'den düz metne çıkarıldı (412 paragraf) ve § 3 birebir okundu.

### § 3.2 "Durumların Belirlenmesi" — dokümanın tam cümleleri

| Durum | Dokümanın koşulu (birebir) |
|---|---|
| **Not Rediscounted** | *"Transaction için açık (ters fiş ile kapatılmamış) bir reeskont kaydı bulunmamaktadır… hiç reeskont oluşturulmamış olması **veya** en son oluşturulan reeskont kaydı ile buna ait ters fişin aynı değerleme döngüsü içerisinde kapanmış olması halinde oluşur. Her iki durumda da, **ilgili Execution Date için** yeni bir reeskont kaydı oluşturulması gerekmektedir."* |
| **Not Reversed** | *"Transaction için oluşturulmuş bir reeskont kaydı bulunmaktadır ancak bu kayda karşılık gelen ters fiş henüz oluşturulmamıştır."* |
| **Rediscounted** | *"**İlgili Execution Date için** oluşturulmuş reeskont kaydı ile buna karşılık gelen ters fiş kaydı (t+1) mevcuttur. **En son aktif hareket**, tamamlanmış bir reeskont–ters fiş çiftini temsil etmektedir."* |

Ayrıca § 3.2 girişi: *"Bir transaction'ın durumu, ilgili işleme ait **en son (güncel)** reeskont ve
ters fiş hareketleri dikkate alınarak belirlenir."*

### Kodun yaptığı (`TransactionDataManager.cs:100-108`)

```csharp
RediscountReverseId = x.AccountingMainEntries
    .Where(a => a.Type == revaluationType &&
                !a.IsReverse &&
                a.ValueDate == executionDate &&              // ← Execution Date'e GÖRE
                a.ProductCode == x.Product.MainProductCode)
    .OrderByDescending(a => a.Id)                            // ← EN SON fiş
    .Select(a => (int?)a.ReverseId)
    .FirstOrDefault()
```

| Türetme | Doküman karşılığı |
|---|---|
| `null` → **Not Rediscounted** | o Execution Date için reeskont fişi yok → "yeni bir reeskont oluşturulması gerekmektedir" ✅ |
| `0` → **Not Reversed** | reeskont var, ters fiş yok (`ReverseId` NOT NULL, yokluk `0`) ✅ |
| `> 0` → **Rediscounted** | o Execution Date için reeskont + ters fiş çifti tamam ✅ |

**Sonuç: doküman ile kod birebir örtüşüyor.**
- `a.ValueDate == executionDate` → *"ilgili Execution Date için"* ✅
- `.OrderByDescending(a.Id).First…` → *"en son (güncel) hareket"* ✅
- `!a.IsReverse` → ters fişler durum kaynağı değil, `ReverseId` üzerinden okunuyor ✅

### Kullanıcının şüphesini doğrulayan somut kanıt (ekran görüntüleri)

| Execution Date | Toplam | Rediscounted |
|---|---|---|
| **18.08.2026** | 9 | **1** (`TMMBRW2608180001`) |
| **20.08.2026** | 8 | **0** |

Aynı transaction 18.08 için `Rediscounted`, 20.08 listesinde **hiç yok**. İkisi de doğru:
- 18.08 için reeskont + ters fiş kesilmiş → `Rediscounted`
- 20.08'de listeden düşmesinin sebebi **statü değil UYGUNLUK filtresi**:

```csharp
x.MaturityDate > executionDate &&
x.ValueDate <= executionDate &&
x.Details.Any(w => !w.IsPrincipalAmount &&
                   w.PeriodStartDate <= executionDate &&
                   w.PeriodEndDate > executionDate)
```

Vadesi geçen ya da faiz dönemi kapanan işlem reeskonta tabi değildir → listeden düşer.
⚠️ Bu filtre EOD sorgusuyla (`GetPendingRevaluationTransactions`) **birebir aynı** — yani ekran
ile batch **aynı işlem kümesini** görüyor. Kasıtlı.

**Yani statü mantığı bozuk değil.** Kullanıcının şüphesi haklı bir şüpheydi ama sebep başkaydı.

---

## 2. Onay penceresi — YAPILDI

`mrBuildRegenerateConfirmBody` (`actions.js:341`) görselin birebir karşılığı:

| Görselde | Kodda |
|---|---|
| Lacivert başlık "Regenerate — Onay" | `mrShowDialog` + `.mr-dialog .dx-popup-title` |
| *"Seçilen kayıtlar yeniden değerlenir:"* | `mr-confirm-RegenerateLead` |
| `• 30 kayıt [Not Rediscounted] Önceki değerleme bulunmadığından…` | `mrRegenerateLine(counts.notRediscounted, …, "mr-confirm-RegenNoPrevious")` |
| `• 20 kayıt [Not Reversed] Önceki değerleme geri alınır…` | `mrRegenerateLine(counts.notReversed, …, "mr-confirm-RegenReplace")` |
| `• 30 kayıt [Rediscounted] Önceki değerleme geri alınır…` | aynı kural metni |
| `• 18 kayıt [Processing/Error] İşleme uygun olmadığından kapsam dışı` | `mrRegenerateLine(counts.outOfScope, …, "mr-confirm-RegenOutOfScope")` |
| `Onayla` (dolu lacivert) / `Vazgeç` (metin) | `mr-dialog-ok` / `mr-dialog-cancel` |

Ek olarak görselde olmayan ama gerekli bir alt satır var: **fiş valörü** ve **ters fiş valörü**
(`mr-confirm-ExecutionDate` / `mr-confirm-ReverseValueDate`) — kullanıcı neyi onayladığını görüyor.

🔑 `0` kayıtlı durum satırı **hiç basılmıyor** — "0 kayıt Not Reversed" yazmak var olmayan bir
kova gösterir.

---

## 3. 🔴 Fimple hatası — kod aynı, o yüzden fark KOD DIŞINDA

Kullanıcı haklı: **step'ler gerçekten aynı.**

```
Manuel Reeskont Execute ──┐
                          ├─► RevaluationAccountingService (Strategy)
EOD Batch (RevaluationBatchItem) ──┘        │
                                            ▼
                              RevaluationAccountingPipeline
                              01 Prepare → 05 Accrual → 10 AccountingEntry
                              → 15 SyncStep ──► IFimpleAccountingService
                                                 .SendRevaluationAccountingAsync
                              → 20 PersistChange → 25 InternalSync
```

`15_RevaluationAccountingSyncStep.cs:29` her iki yolda da **aynı** metodu çağırıyor.
Yani "manuel mi batch mi" sorusunun cevabı: **kod olarak fark yok.**

### Fark KOD DIŞINDA — 3 aday

| # | Aday | Neden mantıklı |
|---|---|---|
| **1** | 🔴 **Auth (token/login)** | `FimpleAuthService.cs:37` ve `:41` **de** `GetFimpleContentOrThrowAsync` kullanıyor. `:41` → `fimpleKeycloakApi.Login(accessToken)`. Bu uç 404 dönerse gövde `"Not Found"` olur → `N` → **`Error parsing NaN value`**. Hata imzası buna tam oturuyor. Emsali `MEMORY.md`'de var: *"deploy edilmiş modül API'si kaynaktan geri kalabilir → 404 → NullReference"* |
| **2** | **`LogicalDate` farkı** | Manuel ekran **geçmiş bir Execution Date** seçebiliyor (18.08, 20.08); batch **cari** günle koşuyor. Fimple muhasebe gününü kapatmışsa reddeder. ⚠️ Ama bu **iş reddi** olur → Fimple JSON döner (`Success:false` + `Reasons`) → hata `Fimple Error => Code: …` olurdu, `NaN` değil. **Bu yüzden 2. sırada** |
| **3** | **`ExternalAccountingSyncState` farkı** | `15_…SyncStep.cs:19` bu flag `false` ise Fimple çağrısı **hiç yapılmıyor**. Batch bunu farklı okuyorsa (farklı ortam/parametre) batch Fimple'a çıkmıyor olabilir — o zaman "batch çalışıyor" gözlemi Fimple'ın hiç denenmemesinden geliyordur |

### 🔑 `NaN` hata imzasının söylediği kesin şey

`Error parsing NaN value … position 1` demek: **HTTP başarısız** + **gövde JSON DEĞİL** (ilk
karakter `N`). Fimple'ın **iş** hatası JSON döner. Yani bu bir iş kuralı reddi **değil** —
**routing / auth / gateway** katmanında bir şey. Aday 1 ve 3 bu yüzden aday 2'den güçlü.

### Sırada: Seq'ten ne çekilmeli

Log mesajı artık `HTTP {kod} ({durum}). Body: …` içeriyor. Seq'te şunlar gerekiyor:

1. `>>>>>>>>> {Method} {Url}` satırlarının **tamamı** (hata anına ait CorrelationId scope'u) —
   hangi uca gidildiği ve **tam URL**
2. `<<<<<<<<< {StatusCode} Response Body:` satırı — **durum kodu**
3. `ExternalApiException` mesajı — artık gövdeyi taşıyor
4. Aynı zaman aralığında **EOD batch**'in aynı işlem için ürettiği `>>>>>>>>>` satırları
   (varsa) — iki URL'yi **yan yana** koymak farkı anında gösterir

⚠️ Log'da `client_secret` **düz metin**; Seq çıktısını paylaşmadan önce maskele
(`outputs/2026-08-20-client-secret-log-maskeleme.md`).

---

## 4. `D-12` genişletildi — Generate ve Regenerate ikisi de soruyor

Kullanıcı **doküman yazarına sordu**, cevap: *"Generate ve Regenerate'te ters fiş için popup
çıkması lazım, T+0 mı T+1 mi diye sorulması lazım."*

### Uygulanan kural: **ters fiş kesilecekse sorulur**

| Aksiyon | Seçim | Popup |
|---|---|---|
| **Generate** | `Not Reversed` satırlar | ✅ **açılır** — bu satırlar ters fiş üretiyor |
| **Generate** | `Not Rediscounted` satırlar | ❌ açılmaz — § 4.1: bu adımda **yalnız reeskont (T+0)** kesilir, ters fiş **yok**; sorulan valör hiçbir yerde kullanılmazdı |
| **Regenerate** | her seçim | ✅ **her zaman açılır** — § 4.3: *"yeni reeskont (T+0) **ve** ters fişi"* |

🔑 `D-10` (karışık statü → Generate pasif) sayesinde Generate seçimi **homojen**: ya tamamı
`Not Reversed` (→ sorulur) ya tamamı `Not Rediscounted` (→ ters fiş yok). Yani pratikte
"Generate'te popup çıkmıyor" durumu **yalnız** ters fiş kesilmeyen adımda oluşuyor.

⚠️ Kullanıcı **her koşulda** sorulmasını isterse tek satır (`reverseRows` koşulunu kaldır) —
ama o zaman `Not Rediscounted` Generate'inde kullanıcıya **hiçbir yerde kullanılmayan** bir soru
sorulur. Kullanıcıya soruldu.

### Regenerate'te satır bazlı statü — DOĞRULANDI

Kullanıcı: *"foreach'te dönerken ayrı ayrı bakıyorum statülerine değil mi?"*

`ExecutionsHandler.cs:265-282` — evet:

```csharp
foreach (var item in request.Items)          // :197
{
    var existing = await accountingDataManager.GetRevaluationByValueDateAsync(
        item.TransactionId, executionDate, sourceType, cancellationToken);   // :265
    var actualStatus = DeriveStatus(existing);                               // :268
    …
    RediscountOperation.Regenerate => await RegenerateAsync(
        item, actualStatus, existing, executionDate, reverseValueDate, …)     // :280
}
```

Her satırın durumu **DB'den kendi başına** türetiliyor ve `RegenerateAsync` ona göre dallanıyor:
`NotReversed` → önce mevcut fişi nötrle, sonra yeniden değerle · `NotRediscounted` → doğrudan
yeni değerleme · `Rediscounted` → geri al + yeniden değerle. Hepsi **`Rediscounted`** ile bitiyor.

**Valör tek:** `reverseValueDate` istekten **bir kez** çözülüp tüm satırlara aynı uygulanıyor
(`:264`) — doküman § 4.2: *"Toplu çalıştırma senaryolarında seçilen valör seçeneği, işaretlenen
tüm transaction'lara aynı şekilde uygulanır."* ✅

---

## 5. Görsel düzeltmeler

| # | İstek | Ne yapıldı |
|---|---|---|
| 1 | *"dokümanda Execution Date yazıyor, sen Date yapmışsın"* | `mr-filter-ExecutionDate`: EN `"Date"` → `"Execution Date"` · TR `"Tarih"` → `"Execution Date"` (doküman ve ekran görselleri İngilizce etiket kullanıyor) |
| 2 | *"dropdown alanları çok geniş olmuş, daralt"* | Form `ColCount(3)` → **`(4)`** (3 alan → her biri satırın 1/4'ü, son çeyrek boş) + CSS tavanı `.mr-filters .dx-texteditor { max-width: 320px }` |
| 3 | *"Status Description bazen sığmıyor, dinamik genişlikte olsun"* | Sabit `width: 320` **kaldırıldı** → `minWidth: 260`. `columnAutoWidth: true` bu kolona **kalan alanı** veriyor |

---

## 6. Doğrulama

| Ne | Sonuç |
|---|---|
| `dotnet build Trex.WebUI` | **0 Error** |
| JS testleri | **344/344** |
| Doküman § 3 ↔ kod karşılaştırması | **örtüşüyor** (kod değişmedi) |
| Onay penceresi ↔ görsel | **örtüşüyor** (kod değişmedi) |
| `foreach` satır bazlı statü | **doğrulandı** (kod değişmedi) |
