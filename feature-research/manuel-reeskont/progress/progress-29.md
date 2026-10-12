# progress-29 — Ekran uçtan uca test edildi: 2 SESSİZ bug bulundu + tüm MD'ler güncellendi

**Tarih:** 2026-08-18 (gece)
**Tetikleyen (kullanıcı):**
1. *"test etmen için baştan başlatıyorum test et başlattım"*
2. *"bu manuel reeskont business'ı koduyla ilgili olarak bildiklerimi ve son halini md dosyalarında güncelle, o kadar manuel reeskont md'si var güncellenmesi lazım"*
3. Ara mesaj: *"hataların var hala… hangi işi yaparken hata aldın onu da belirt ve 2 işlem seçtim, birincisinde hata aldı ve garip bir şekilde loading kapandı ama arkada backend'te devam ediyordu"*
4. Ara mesaj: *"bu image'da olduğu gibi… bu işlevleri yapmamış gibisin"* (image4 valör popup'ı + image6 Regenerate onayı)

---

## Yapılanlar (Done)

### 1. Ortam doğrulandı — fiş üreten çağrı BİLEREK tetiklenmedi

| Ne | Durum |
|---|---|
| WebUI | ✅ `localhost:5032` (container `ui-nettrex`) |
| MM API | ✅ `localhost:5041` (host'ta, VS'ten — container değil) |
| `reverseValueType` deploy'da mı | ✅ MM swagger `ExecutionsRequest` şemasında **var** → rebuild tuttu |

🔴 `executions` ucunu **kendim çağırmadım** — gerçek muhasebe fişi üretip Fimple'a gidiyor.
Yalnız **yan etkisiz** yollar test edildi (okuma ucu + guard reddi + swagger).

### 2. 🔴 B-1 — GRID'DE SATIR SESSİZCE KAYBOLUYORDU (en ciddi bulgu)

**Belirti (API ile ölçüldü, tarayıcı gerekmedi):**

| Filtre | `totalCount` | `len(items)` | `statusSummary` |
|---|---|---|---|
| `Status = null` (All) | 4 | **3** | `notReversed: 1` |
| `Status = 3` (NotReversed) | 1 | **0** | `notReversed: 1` |

Özet şeridi *"1 Not Reversed"* diyor, grid'de o satır **yok**. Aynı sorgu, sayım buluyor, liste bulamıyor.

**Kök sebep:** `TransactionDataManager.GetRediscountEligibleTransactionsAsync` satır projeksiyonunda
**required navigation** dereference ediliyordu:
- `p.Entity.Customer != null ? … : null` → `Customer` **`IsRequired()`** (`TxnMmEntityConfiguration.cs:95-98`)
- `p.Entity.Direction.Name` → `Direction` **`IsRequired()`** (`:110-113`), **guard bile yok**

EF Core required navigation için **INNER JOIN** üretiyor ve `!= null` guard'ını
**sadeleştirip atıyor**. FK dolu ama karşılığı yoksa (**orphan**) satır **sessizce düşüyor**;
`CountAsync` o join'i hiç yapmadığı için **saymaya devam ediyor**.

**Canlı kanıt (sql-log #30–#33):**
```
Id     CustomerId  CustOk   BasisCode BasisOk  TxnTypeCode TxnTypeExists
553311 2107        1        1         1        BRW         1
553306 2107        1        2         1        BRW         1
553292 1086        0  ←🔴  1         1        BRW         1
553283 2107        1        2         1        BRW         1
```
`TxnMM 553292` (`TMMBRW2607140004`) → `CustomerId = 1086`, **`cusCustomer`'da YOK**.
Aynı tarihteki diğer 3 satırın müşterisi (`2107`) var, o yüzden onlar dönüyordu.

> ⚠️ İlk hipotezim **`Direction`** idi (guard'sız olduğu için) — `defTxnType`'ta `BRW` **var** çıktı,
> hipotez **çürüdü** ve doğru sebebe FK karşılaştırmasıyla ulaşıldı.

**Kullanıcıya etkisi:** `Not Reversed` satıra **hiç ulaşılamıyordu** → ters fiş valörü popup'ı
tetiklenemiyor, o işleme fiş kesilemiyordu. **Hata mesajı da yoktu.**
Kullanıcının *"bu işlevleri yapmamış gibisin"* demesinin gerçek sebebi buydu: popup kodu diskte
vardı ama **tetikleyecek satır ekrana hiç gelmiyordu**.

**Fix:** alanlar **skaler subquery** ile okunuyor (join üretmez → satır düşmez, alan boş kalır):
```csharp
customerRepository.Queryable().Where(c => c.Id == p.Entity.CustomerId)
    .Select(c => c.Name).FirstOrDefault()
```
- `TransactionDataManager` (MM) — `IRepository<CustomerEntity>` + `IRepository<TxnTypeEntity>` enjekte edildi
- `TransactionLoanDataManager` (IL) — **aynı desen vardı**, önleyici olarak düzeltildi
  (`CustomerId` `int` → EF required sayıyor; `Direction` açık `IsRequired()`)
- Emsal: `AccountingDataManager` 3 repository alıyor → çoklu repository enjeksiyonu ev konvansiyonu

⚠️ **Aynı tuzak duruyor:** `Product` (FK `TxnMmProductTypeId`) ve `Basis` (FK `BasisCode`) da
`IsRequired()` ve hâlâ navigation üzerinden okunuyor. Bugün orphan yok (`BasisOk = 1`) → **latent**.

⏳ **Restart bekliyor:** DLL kilidi (`NetTrex.MM.Api` PID 13980) yüzünden çalışan sürece yüklenemedi.
Kod derleniyor (`NetTrex.MM.Data` → 0 error), yalnız DLL değiştirilemiyor.

### 3. 🔴 B-2 — Execute sonucu grid'e YAZILMIYORDU

Kullanıcının ekran görüntüsü: şerit *"Execution result (live): 2 failed"* çıkıyor (F-1'in şeridi
çalışıyor) ama satır hâlâ **`Not Rediscounted`** — `Error` olmamış.

**Sebep:** `calculateCellValue` kullanmışım. DevExtreme onu **veri yüklenirken bir kez** hesaplayıp
önbelleğe alıyor; `repaint()` önbelleği **yenilemiyor** → overlay ekrana hiç yansımıyor.

**Fix:** her iki kolon (`Status`, `StatusDescription`) **`cellTemplate`**'e geçirildi — template
**her boyamada** çalıştığı için overlay'i doğru anda okuyor. `dataField` **duruyor**: sıralama ve
Excel export **DB durumunu** kullanır (§ 3.1 gereği `Error` export'a girmemeli).
`StatusDescription` hücresine ayrıca `title` (tooltip) eklendi — ham Fimple metni uzun.

### 4. Loader dayanıklı hale getirildi

Kullanıcı: *"birincisinde hata aldı ve garip bir şekilde loading kapandı ama arkada backend'te devam ediyordu"*.

**Araştırıldı:** `mrExecute` ham `$.ajax` (loader çağrısı yok) · `site.js`'te global
`ajaxStart/ajaxStop` **yok** (`ajaxComplete` var, loader'a dokunmuyor) · `#DefaultLoadPanel`'de
`hideOnOutsideClick` **set edilmemiş** · `hideLoader()`'ın başka çağıranı yok.
🔴 **Kapatanı kesin tespit edemedim.**

**Karar:** tahmin yerine **her parçada `showLoader()` yeniden assert ediliyor**. `show()` idempotent.
Kim kapatırsa kapatsın gösterge geri geliyor — fiş üreten bir döngüde "görünmez şekilde sürmek"
en tehlikeli hâl.

### 5. Hata metinleri artık **hangi işlem** olduğunu söylüyor (kullanıcı isteği)

`mrOperationLabel(operation)` eklendi; şu üç yere işlendi:
- Dialog başlığı: `Generate — 0 succeeded · 2 failed`
- Grid `Status Description`: `Generate — External system error — Fimple Error => …`
- Sonuç şeridi: `Regenerate — Execution result (live): …`

Gerekçe doc'a yazıldı: aynı satır Generate ile de Regenerate ile de patlayabilir ve **sebepleri
farklıdır** — Regenerate önce ters fiş kesip sonra yeniden değerliyor, hata **üç ayrı Fimple
turundan** birinde olabilir.

### 6. Onay penceresi butonları mockup'a çekildi

`DevExpress.ui.dialog.confirm` DevExtreme'in **`Yes`/`No`** butonlarını basıyordu; image5/image6
**`Onayla`/`Vazgeç`** gösteriyor. `dialog.custom`'a geçildi, metinler localization'dan
(`mr-btn-Approve` eklendi: EN `Approve` / TR `Onayla`), onay butonu vurgulu.

### 7. Kullanıcının 3 sorusu cevaplandı (kod okunarak)

| Soru | Cevap |
|---|---|
| `Processing 2/3…` nasıl basılıyor | Sıralı `await` döngüsü; her tur başında `mrSetActionHint` DOM'a yazıyor. Timer/polling/SignalR **yok**. `await` fonksiyonu duraklatıp tarayıcıya **boyama turu** verdiği için görünüyor — satırlar `Promise.all` ile paralel atılsaydı hiç görünmezdi |
| Karışık **statü** seçilince Generate pasif olmalı mıydı | **Hayır** — doküman § 5.3 *"her kayıt üzerinde uygulanacak işlem, kaydın kendi durumuna göre belirlenir"*. Pasifleştirme kuralı **Revaluation Type** içindir (§ 4.6), statü için değil. `All` filtresinin var olma sebebi tam olarak bu |
| Bu iş için tablo/kolon eklendi mi | **Hayır.** `NetTrex.MM`'de `Migrations` klasörü **hiç yok**; hiçbir entity/EF config'te `Rediscount` geçmiyor; ürettiğim 2 script'te **0** `ALTER TABLE`/`CREATE TABLE` (yalnız `dbo.FrameworkMenu` + `dbo.FrameworkPermission`). Durum **hesaplanıyor** (`DeriveStatus`), saklanmıyor. 🔎 **FX'te ise VAR:** `FxValuationEntity.ValuationState` + `ValuationStateDescription` **kalıcı kolonlar** ve `ManualRediscountSelectHandler.cs:132` `ValuationState == "Error"` okuyor. Yeni doküman bunu bilerek terk etmiş (§ 3.1/§ 3.4). ⚠️ `NetTrex.Fx` reposunda bu kolona **yazan kod bulamadım** — kolon okunuyor ama dolduran yer bu repoda değil; FX DB'sine bakmadım |

### 8. MD dosyaları güncellendi (kullanıcı isteği)

| Dosya | Ne yapıldı |
|---|---|
| `06-sozlesme.md` | 🔴 **Sözleşme değişikliği:** `ReverseValueDate` (tarih) → **`ReverseValueType` (enum T1/T0)`**; `ReverseValueType` enum tanımı eklendi; validasyon `>` → **`>=`**; `Items` sınırı 200 → **10**; `C-08` satırı güncellendi; Fimple bağlantı notu takvim gerekçesiyle yenilendi |
| `00-PANO.md` | **Üzerine yazıldı** — güncel durum, 4 doküman hizalaması (F-1…F-4), 2 sessiz bug (B-1/B-2), DB bulguları, 8 bilinçli fark (D-1…D-8) |
| `08-test-rehberi.md` | **§ 10 eklendi** — 24 yeni test maddesi (`T-01…T-24`): valör popup'ı, **iş günü (Cuma→Pazartesi) testi**, sonucun grid'e yazılması, loader, onay pencereleri, **sayım tutarlılığı regresyonu** |
| `NetTrex.MM/.ai-agent/MEMORY.md` | EF INNER JOIN tuzağı **tam gerekçeli** eklendi (canlı kanıt + çözüm deseni + latent kalanlar) |
| `.ai-agent/MEMORY.md` (workspace) | Aynı tuzağın **kısa cross-repo** hâli — EF Core geneli, her repoyu ilgilendiriyor |
| `sql-log/manuel-reeskont-kodlama/` | `#29–#33` sorguları **çalıştırılmadan önce** + çıktıları sonra; başarısız 2 sorgu da (benim kolon adı hatalarım) kayıtta |
| `progress/progress-29.md` + `_index.md` | Bu dosya |

---

## Yapılıyor (In Progress)

Yok — bu turda başlanan her şey tamamlandı. **Doğrulanması** MM API restart'ına bağlı.

---

## Yapılacaklar (TODO)

### 🔴 Hemen — kullanıcı aksiyonu

| # | Konu | Neden |
|---|---|---|
| **1** | **MM API'yi yeniden başlat** | B-1 fix'i DLL kilidi yüzünden yüklenemedi. Restart olmadan `Not Reversed` satır **hâlâ görünmez** |
| **2** | `08-test-rehberi.md` § 10 → **T-01, T-07, T-10** | Sırasıyla: satır görünüyor mu · **Cuma → Pazartesi** · satır `Error` oluyor mu |
| 3 | **Kafka broker down** (`localhost:9092`) | fire-and-forget + hata yutuluyor → fişler NetTrexAcc'ye gitmemiş olabilir |
| 4 | **`AccAccountMap` konfigürasyonu** | Fimple `3015`/`3067`: *"defter hesabı 36199200 bulunmamaktadır"*, *"geri tarihli muhasebe tarihinden küçük olamaz"* — muhasebe konfigürasyonu, kod işi değil |

### 🟡 Karar/onay bekleyen

| # | Konu |
|---|---|
| 5 | 🔴 **Batch'te hafta sonu valörlü ters fiş (%43)** — `ReverseBatchItem` takvim kullanmıyor; manuel ekran düzeltildi, batch **dokunulmadı** (geçmiş veri etkisi) |
| 6 | ⚠️ **`Product`/`Basis` navigation'ları hâlâ INNER JOIN riski taşıyor** (latent) |
| 7 | 🔴 **`AccEntryMain`'de discriminator kolonu yok** — `ProductCode` tabloyu ayırmıyor |
| 8 | **Audit yarım (C-19)** — T+0 fişi Generate'e basanı kaydetmiyor |
| 9 | **Uzun koşuyu iptal edememe** — `AbortController` + Cancel önerisi |
| 10 | `FxRate` hardcoded 0 · para birimi bazlı ondalık (JPY/KWD) yok · Kafka publish `CommitAsync`'ten önce · batch sorgularında `ProductCode` filtresi yok · `AccruedInterest`/`DailyAccrual` IL'de null · Execute-hang parkta |
| 11 | **İş birimine sorulacak `C-xx`** — `C-01` · `C-03` · `C-05` · `C-06` (Regenerate + `Not Reversed` = kaç fiş) · `C-07` · `C-10` · `C-13` · `C-17` · `C-18` · `C-19` · `C-20` |

### ⚠️ Test altyapısı boşlukları

- **B-1 birim testle kapsanamıyor** — gerçek DB + orphan FK verisi gerekiyor. Derleme ve 190 birim test bunu **göremedi**; yalnız API'yi çağırıp `totalCount` ↔ `items.Count` karşılaştırınca çıktı. **Kalıcı çözüm:** entegrasyon testi ya da `T-23` maddesinin manuel kontrolü
- WebUI controller/service test harness'i **yok** → overlay, popup, şerit, loader **birim testle kapsanmıyor**
- JS jest `node_modules` **yok**
- DataManager LINQ→SQL sorguları birim testle kapsanmıyor

---

## Test durumu

| Ne | Sonuç |
|---|---|
| `NetTrex.MM.Api.Services.Tests` — `*ManualRediscount*` | **100 / 0 hata** |
| `NetTrex.MM.Api.Services.Tests` — tamamı | **190 / 0 hata** |
| `NetTrex.MM.Data.Tests` | **3 / 0** (constructor yeni repository'lerle güncellendi) |
| `NetTrex.MM.Data.Repository.Tests` | **271 / 0** |
| `NetTrex.MM.Data` build | **0 error** |
| `NetTrex.MM.Api` build | ⚠️ derleme temiz, **DLL kilidi** (çalışan süreç) → restart gerekiyor |
| JS `node --check` | **8/8 OK** |
| Localization JSON | **4/4 geçerli** (`mr-btn-Approve` eklendi) |
| API — okuma ucu | ✅ `HTTP 200` |
| API — swagger `reverseValueType` | ✅ **var** |

⚠️ **Tarayıcı testi YAPILMADI** — MM API restart'ı bekliyor.
