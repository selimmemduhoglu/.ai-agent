# progress-52 — Test turu bulguları: OptFX numara üreteci + DerivSwp mirror commit

**Tarih:** 2026-09-18
**Tetikleyen:** Kullanıcı testi — *"bu hatayı aldım option'da"* (Seq log) + *"Deriv'de regenerate'e bastıktan sonra 3 satır yazdı, MM'deki gibi 4 satır olması gerekmiyor mu, hata mı yaptın kontrol et"*
**Durum:** DerivSwp bug **bulundu ve düzeltildi** · OptFX teşhisi **DB doğrulaması bekliyor**

---

## 1. 🔴 DerivSwp — mirror'ın ters fişi sessizce siliniyordu (DÜZELTİLDİ)

### Belirti

`Rediscounted` statüdeki bir satıra **Regenerate** basıldığında ekran başarılı dönüyor ama defterde **4 yerine 3** fiş oluşuyor.

Kullanıcının gönderdiği ekranda (`TDCCS26091400001`, işlem tarihi 16.09.2026):

| Id | ValueDate | Tip | Kaynak | Durum |
|---|---|---|---|---|
| 881137 | 16.09.2026 | Revaluation | mirror (karşı fiş) | ✅ yazıldı |
| — | 17.09.2026 | Ters Fiş | **mirror'ın tersi** | ❌ **KAYIP** |
| 881138 | 16.09.2026 | Revaluation | yeni reeskont | ✅ |
| 881139 | 17.09.2026 | Ters Fiş | yeni reeskontun tersi | ✅ |

### Kök neden

DerivSwp'de `AccountingReverseService.ExecuteAsync` **commit atmaz**. `accEntryMainRepository.Update(...)` + `Insert(...)` + `accEntryRepository.InsertRange(...)` yapıp çıkar; **commit sorumluluğu çağırana aittir.**

- `ExecutionsHandler.CreateReverseAsync` bunu biliyordu → sonrasında `unitOfWork.Commit()` var. ✅
- `RevaluationMirrorService.ExecuteAsync` **bilmiyordu**:

```
mirror insert
unitOfWork.Commit()                      ← mirror diske yazıldı (881137)
changeTrackerService.Reset()
accountingReverseService.ExecuteAsync()  ← insert TRACKER'DA, commit YOK
   ↓ dönüş
ExecutionsHandler.NeutralizeCompletedCycleAsync
   → changeTrackerService.Reset()        ← ChangeTracker.Clear()
   ↓
bekleyen insert ÇÖPE                     ← ters fiş kayboldu
```

### İkincil zarar (görünmeyen)

Aynı `Reset()` `accEntryMainRepository.Update(accEntryMainEntity)`'i de yuttu → **mirror satırının `ReverseId` kalıcı olarak `0`**. Yani 881137:

- tersi olmayan bir reeskont fişi olarak duruyor,
- statü çözümlemesi (`ReverseId` + ters fişin `ValueDate`) onu okursa **yanlış** karar verir.

### Defter etkisi

- **16.09** → `881129` (eski reeskont) + `881137` (mirror, ters yönlü) = net **0** ✅
- **17.09** → `881136` (eski reeskontun tersi) var, `881137`'nin tersi **yok** → **fazla bacak açıkta** 🔴
- Fimple tarafı: mirror servisi Fimple'a insert'ten **önce** sync ediyor (`SynchronizeAsync`, satır 38-39) ve reverse servisi de kendi sync'ini yapıyor → **Fimple ters fişi aldı, lokal DB almadı** = defterler tutarsız (OptFX'teki `990` vakasının aynısı).

### Düzeltme

`NetTrex.DerivSwp.Common.Operation/Services/Accounting/Mirror/RevaluationMirrorService.cs` — `ExecuteAsync` sonuna:

```csharp
// AccountingReverseService commit atmaz; burada commit edilmezse ters fis cagiranin Reset'inde silinir.
unitOfWork.Commit();

changeTrackerService.Reset();
```

`NetTrex.DerivSwp.Common.Operation` derlendi → **0 Error** (386 warning, hepsi önceden var olan nullable/CA uyarıları).

### Neden MM ve OptFX'te yok

Her ikisinde de `RevaluationReverseAccountingService` commit'i **kendi içinde** atıyor:

- `NetTrex.MM.Common.Services/.../RevaluationReverse/RevaluationReverseAccountingService.cs:23`
- `NetTrex.OptionsFX.Common.Services/.../RevaluationReverse/RevaluationReverseAccountingService.cs:69`

DerivSwp'nin `AccountingReverseService`'i **başka bir soydan** geliyor (batch item'lar ve `AccountingDeleteService` de kullanıyor, onlar da commit'i dışarıda atıyor). Bu farkı modül entegrasyonunda ölçmemişim — hata bende.

**FX etkilenmiyor:** FX'te mirror servisi hiç yok, motorun `Rediscounted` dalı işi kendi içinde yapıyor ve `ExecutionsHandler.RunEngineAsync` her çağrı sonrası commit + Reset atıyor.

### 🔴 Genel kural (rehbere trap #10 olarak eklendi)

> Yeni modüle reverse/mirror servisi eklerken **commit'in kimde olduğunu ölç**. `changeTrackerService.Reset()` **her zaman** commit'ten *sonra* gelmeli. `Reset()` = `ChangeTracker.Clear()` = commit edilmemiş her şeyi sessizce siler, **hata vermez**.

### ⬜ Kalan iş

- **Veri onarımı:** mevcut DB'de bu yoldan geçmiş satırlar var (`881119/881120/881121` üçlüsü 15.09'da aynı deseni gösteriyor). `ReverseId = 0` olan mirror satırları ve karşılıksız kalan ters valör bacakları için envanter sorgusu + onarım kararı gerekiyor — **yapılmadı**.
- Düzeltme sonrası **uçtan uca Regenerate testi** — 4 satır çıkıyor mu, Fimple ikinci ters fişi kabul ediyor mu.

---

## 2. OptFX — `Id: 990` / numara üreteci (teşhis tamam, DB doğrulaması bekliyor)

Önceki turda tespit edildi, burada özet:

- `NumberGeneratorDataManager` Id'yi `int.Parse($"{99}{Number}")` ile kuruyor → `Number = 0` ise **her satır** `990` alıyor → EF `another instance with the key value '{Id: 990}' is already being tracked`.
- `sp_GetNewNumbers` yalnız `DefNumberGen`'de o `EntityColumnType` satırı **yoksa** 0/NULL döner (`@@ROWCOUNT = 0` → `RAISERROR`, `@new_last_no` NULL kalır).
- Koda guard eklendi: eksik/0 numara → `DataServiceException` (açıklayıcı mesaj, `DefNumberGen` satırını işaret ediyor). `NetTrex.OptionsFX.Data.csproj` tek başına derlendi → **0 Error**; solution derlenemedi (`MSB3021/MSB3027` dosya kilidi, `NetTrex.OptionsFX.Api (25528)` ayakta).
- Script: `outputs/2026-09-17-OptFX-DefNumberGen-Reseed.sql` (teşhis + yorumlu idempotent MERGE).
- 🔴 **Doğrulama yapılamadı:** `trusr` kullanıcısı `NetTrexOptFX-investmentbank` DB'sine yetkili değil (`Login failed`). Teşhis bölümünün o DB'deki çıktısı bekleniyor.
- 🔴 Yan etki: Fimple ters fişi oluşturdu (`CreateReverseAccounting → Success: true`, `OriginalBusinessKey 712063615941812225` = AccEntryMain 992065), lokal yazma patladı → tekrar denemeden önce Fimple'daki fiş kontrol edilmeli.
- Repo taraması: `sp_GetNewNumbers` ve `DefNumberGen` seed satırları **hiçbir repoda .sql olarak tutulmuyor** → ortam verisi, yeni/restore DB'de eksik kalması beklenen senaryo.

---

## 3. Dokümantasyon

- `12-modul-yayilim-rehberi.md` § 10 → **trap #10** (mirror commit) eklendi. Trap #9 (numara üreteci) önceki turda eklenmişti.

---

## 4. Değişen dosyalar

| Repo | Dosya | Değişiklik |
|---|---|---|
| NetTrex.DerivSwp | `Common.Operation/Services/Accounting/Mirror/RevaluationMirrorService.cs` | `ExecuteAsync` sonuna `unitOfWork.Commit()` + `changeTrackerService.Reset()` |
| NetTrex.OptionsFX | `Data/Managers/Generators/NumberGeneratorDataManager.cs` | (önceki tur) eksik/0 numara guard'ı |
| .ai-agent | `manuel-reeskont/12-modul-yayilim-rehberi.md` | trap #10 |
| .ai-agent | `manuel-reeskont/progress/progress-52.md` | bu dosya |

---

## 5. Dört modülün karşılaştırmalı denetimi (2026-09-18)

**Tetikleyen:** *"aynı sorun diğer modüllerde de var mı diye bak, eksik satır basılamaz"* + *"Fimple ve Kafka konfigürasyonları düzgün çalışıyor mu"*

### 5.1 Fiş kesme zinciri — fiş başına Fimple / Kafka / commit

| Modül | Reeskont | Ters fiş | Mirror | Commit sahibi |
|---|---|---|---|---|
| **MM** | Fimple ✅ Kafka ✅ | Fimple ✅ Kafka ✅ | Fimple ✅ Kafka ✅ (`PublishAsync`) | Servislerin **içinde** |
| **OptFX** | Fimple ✅ Kafka ✅ | Fimple ✅ Kafka ✅ | Fimple ✅ Kafka ✅ (`PublishAsync`) | Servislerin **içinde** |
| **DerivSwp** | Fimple ✅ Kafka ✅ (`RevaluationOperation`) | Fimple ✅ Kafka ✅ | Fimple ✅ Kafka ✅ | **Çağıranda** 🔴 |
| **FX** | Fimple ✅ Kafka ✅ (3 valuation servisi, her birinde 6 `SendKafka` + 2 `SyncDoAccounting`) | aynı servis | yok (motor içinde) | **Çağıranda**, `TransactionScope` içinde |

MM/OptFX'te Kafka pipeline adımıyla gidiyor (`…InternalSyncStep` → `IMessagingService.SendAccountingMainEntryMessageAsync`), mirror'da doğrudan `PublishAsync`.

### 5.2 Eksik satır riski — her `Reset()` çağrısı denetlendi

`changeTrackerService.Reset()` = `ChangeTracker.Clear()` = commit edilmemiş her şeyi **sessizce** siler. Tüm çağrı yerleri:

| Modül | `Reset()` yerleri | Her biri commit'ten **sonra** mı? |
|---|---|---|
| MM | handler 169 (satır başı), 213 (catch) | ✅ servisler kendi commit'ini atıyor |
| OptFX | handler 94, 132, 296, 315, 348 · mirror 48 | ✅ |
| DerivSwp | handler 99, 137, 297, 320, 353 · mirror 48, **63** | ✅ **63 bu turda eklendi** (§ 1) |
| FX | handler 125 (scope başı), 171 (catch), 332 | ✅ `RunEngineAsync` önce commit |

**Sonuç: § 1'deki bug DerivSwp'ye özgüydü.** MM ve OptFX'te reverse/mirror servisleri commit'i kendi içinde attığı için aynı hata oluşamıyor; FX'te mirror servisi hiç yok.

DerivSwp'nin commit atmayan `AccountingReverseService`'inin diğer çağıranları da denetlendi:

| Çağıran | Commit |
|---|---|
| `ExecutionsHandler.CreateReverseAsync` | ✅ satır 352 |
| `RevaluationMirrorService` | ✅ **bu turda eklendi** |
| `Batch.Items/BeginOfDay/ReverseBatchItem:73` | ✅ |
| `Batch.Items/EndOfDay/ReverseBatchItem:73` | ✅ |
| `AccountingDeleteService` (4 yer) | ⬜ görünür commit yok — çağıranı `TransactionVerifyOperation`, **manuel reeskont yolunda değil**, incelenmedi |

Kafka'nın geçici olarak kapatıldığı 3 çağrı (`GECICI (manuel reeskont testi)` işareti) dört repoda da **kalmamış** — geri açılmış.

### 5.3 🔴 Gizli değişmez: "en büyük Id kazanır"

Üç modülün de statü sorgusu aynı:

```csharp
.Where(x => x.TxnId == ... && x.Type == Revaluation && !x.IsReverse && x.ValueDate == date)
.OrderByDescending(x => x.Id).FirstOrDefault()
```

Regenerate sonrası o valörde **iki** `IsReverse = false` satır var: mirror ve yeni reeskont. Doğru cevap yeni reeskont — ve sorgu onu **yalnızca** mirror'dan sonra yazıldığı ve Id sayacı **monoton arttığı** için buluyor.

🔴 Sayaç geri giderse (OptFX `DefNumberGen` vakası, § 2) bu değişmez kırılır: mirror küçük Id alır, sorgu **eski** reeskontu döndürür, bir sonraki Regenerate **yanlış fişi** nötrler. İki bug birbirini besliyor.

Kod bu varsayımı hiçbir yerde yazmıyor ve doğrulamıyor.

### 5.4 🔴 FX'e özgü: `TransactionScope` dış sistemi kapsamıyor

FX tek modül olarak satırı `TransactionScope(RequiresNew)` içine alıyor — yerel defter için **ya hep ya hiç**. Ama Fimple (`SyncDoAccounting`) ve Kafka (`SendKafka`) çağrıları **scope'un içinde, commit'ten önce** yapılıyor ve HTTP/Kafka rollback'e tabi değil.

Sonuç: FX'te bir satır yarıda patlarsa **o satırın TÜM fişleri** yerelden geri alınır, ama Fimple ve Kafka onları çoktan almıştır. Diğer üç modülde sapma tek fişle sınırlı; FX'te satırın tamamı.

Ek gözlemler (ölçüldü, değerlendirilmedi):
- Fimple HTTP çağrıları scope'un içinde → ağ gecikmesi boyunca DB kilidi tutuluyor.
- `syncMessagesSender.SyncDoAccounting(...).GetAwaiter().GetResult()` — async üstünde senkron bekleme.
- FX reeskont yolunda **Dapper yok** (tek bağlantı) ve bağlantı dizesinde `Enlist` geçersiz kılınmamış → MSDTC yükseltmesi beklenmiyor. ⬜ **Ama uçtan uca hiç çalıştırılmadı.**
- `unitOfWork.Rollback()` `Netix.Core.Repository` paketinde, kaynağı repoda yok → scope içinde ne yaptığı **doğrulanmadı**.

### 5.5 Mimari uyum

Her modül kendi desenini kullanıyor, ortak bir şey dayatılmamış:

| Modül | Fiş kesme deseni |
|---|---|
| MM | pipeline adımları + `IAccountingDataManager` |
| OptFX | pipeline adımları + `IAccountingDataManager` |
| DerivSwp | `IOperationFactory` + repository |
| FX | `IValuationService.BuildValuationAccounting` (statü parametresiyle içeride dallanıyor) |

Sözleşme (`06-sozlesme.md`) ve statü türetimi (§ 4.1) dördünde de aynı.
