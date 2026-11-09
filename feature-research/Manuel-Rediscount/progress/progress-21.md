# progress-21 — Ters fiş LogicalReference bug'ı bulundu+düzeltildi; Fimple ENOTFOUND açıklandı; Execute-hang parkta

**Tarih:** 2026-08-17/18

## Neden

Kullanıcı üç şey istedi bu turda:
1. Execute sırasında container'ın neden düştüğünü/asıldığını bulmaya çalıştık (uzun canlı debug turu) —
   sonunda kullanıcı **"bu sorunu bırakalım başka şeylere odaklanalım"** dedi. **Çözülmedi, parkta.**
2. `RevaluationBatchItem` + `ReverseBatchItem` (EOD/BOD) — mevcut, kanıtlanmış batch akışına bak,
   bizim `ExecutionsHandler`'ın **aynı yoldan gidip gitmediğini** karşılaştır ("aynı yoldan gidiyorlardır
   zaten eksik olmasın").
3. Karşılaştırmadan çıkan bulguyu **düzelt** ("bunu da düzelt" / "hallet").

## 🔴 Execute-hang soruşturması — SONUÇSUZ, KULLANICI TARAFINDAN PARK EDİLDİ

Uzun bir canlı debug turu yapıldı (Seq REST API sorguları, `docker top`/`docker inspect`, VS Processes
penceresi, Hot Reload aç/kapa, canlı `docker logs -f` izleme). Bulgular:

- Bazı Execute istekleri **tam 200 dönüyor** (6-7 saniyede, Redis timeout'a rağmen HTTP fallback'le kurtarıyor).
- Bazıları **hiç log basmadan sonsuza kadar asılıyor** (`Handler Request Data` sonrası sessizlik, `docker logs -f` canlı izlendi — hiçbir şey yazmıyor).
- `docker inspect` → container **hiç çökmüyor** (`OOMKilled=false`, `Status=running`) — bir seferinde
  `docker top` sadece VS'in debug wrapper'ını (`DistrolessHelper.dll --wait`) gösterdi, gerçek app
  process'i **yoktu** — yani "container düştü" hissi aslında **VS debuggee'sinin kopması**.
- VS Output'ta bir seferinde `exited with code 0` (graceful, crash değil) görüldü; Hot Reload açık/kapalı
  ikisinde de tekrarlanabildi — Hot Reload teorisi **doğrulanamadı, çürütülemedi de**.
- `DistKey: ObjectKey=null` log satırı Netix.Core'un kendi (derlenmiş, kaynağı görünmeyen) pipeline'ından
  geliyor — distributed lock teorisi **kod tarafından doğrulanamadı** (kaynak NuGet paketinde, repoda yok).
- **Kullanıcı bu soruşturmayı durdurdu.** Bir sonraki oturumda tekrar ederse buradan devam edilebilir:
  şüpheli kalan tek somut iz `DistKey`/`ObjectKey` — Netix.Core'un lock mekanizmasının nasıl çalıştığı
  (Redis mi, hangi key, TTL var mı) confluence/framework ekibine sorulabilir.

## Batch ↔ ExecutionsHandler karşılaştırması

`RevaluationBatchItem.cs` + `ReverseBatchItem.cs` (EOD `Code/Batch/.../EndOfDay/`, BOD
`Code/Batch/.../BeginOfDay/`) okundu, `ExecutionsHandler.cs` ile satır satır karşılaştırıldı.

**Aynı:**
- İkisi de **aynı iki servisi** çağırıyor: `IRevaluationAccountingService.ExecuteAsync(RevaluationAccountingServiceContext(TransactionId, LogicalDate))`
  ve `IRevaluationReverseAccountingService.ExecuteAsync(RevaluationReverseAccountingServiceContext(...))`.
  **Ayrı bir "manuel motor" yok** — ekran ile batch **birebir aynı** Fimple entegrasyon kod yolunu paylaşıyor (ADR-MR-005 doğrulandı).
- Hata izolasyonu aynı desende: batch her transaction'ı `try/catch` içine alıp `LogWarning(ex.Message)`
  yapıyor (diğerlerini düşürmüyor); `ExecutionsHandler` her item'ı `try/catch` içine alıp
  `response.Failed.Add(..., ex.Message)` yapıyor (diğerlerini düşürmüyor). **Fimple hata mesajı ikisinde
  de aynen kullanıcıya/loga kadar geliyor** — kullanıcının sorduğu "batch'te düzgün dönüyor, burada da
  öyle değil mi" sorusunun cevabı: **evet, aynı mekanizma**.

**🔴 Fark (bug, düzeltildi) — ters fişin `LogicalReference`'ı yanlış alandan geliyordu:**

`ExecutionsHandler.CreateReverseAsync` (eski hali), `RevaluationReverseAccountingServiceContext`'in
2. parametresine (`LogicalReference`) `source.Description` veriyordu. `AccEntryMainEntity`'de
`LogicalReference` diye bir alan **yok**; `Description` ise Fimple'ın ürettiği serbest metin açıklama
(ör. *"Takasbank ile yapılan TMMBRW2608060014 referanslı 6646,48 TRY değerli borç alma işlemi reeskont
fişi"*) — transaction'ın gerçek `TMMBRW...` referansı **değil**.

Bu alan iç log değil, **doğrudan Fimple'a gidiyor**
(`RevaluationReverseAccountingExternalSyncStep.cs:26` → `FimpleAccountingSendRevaluationReverseAccountingContext.LogicalReference`).
Batch (`ReverseBatchItem`) bunu her zaman **doğru** yapıyor — kendi DTO'sunda
(`TDMPendingRevaluationReverseTransactionResult`) `TxnMM`/`TxnLoan` ile join'lenmiş gerçek `LogicalReference`'ı taşıyor.

**Neden testler yakalamadı:** `ExecutionsHandlerTests.BuildVoucher`'da test fixture'ı **bilerek/yanlışlıkla**
`Description = Lr` (test sabiti, gerçek `LogicalReference` değeriyle aynı) yazıyordu — bug'ı maskeliyordu.
82 test yeşilken bile bu satır canlıda yanlış değer üretiyordu.

**Fix:**
- `CreateReverseAsync`'e `string logicalReference` parametresi eklendi, `source.Description` yerine kullanılıyor.
- 3 çağrı noktası (`GenerateAsync`'in `NotReversed` dalı, `RegenerateAsync`'in nötrleme + final dalı)
  `item.LogicalReference` geçirecek şekilde güncellendi.
- Test fixture'ı düzeltildi: `BuildVoucher.Description` artık **kasıtlı olarak `Lr`'den farklı**, gerçekçi
  bir Fimple açıklama metni (bug'ı bir daha maskelemesin diye).
- Yeni regresyon testi: `Handle_ShouldPassItemLogicalReferenceNotVoucherDescriptionToReverseService` —
  `RevaluationReverseAccountingServiceContext.LogicalReference == Lr` doğrudan assert ediliyor.

## Fimple `ENOTFOUND fi-saga-api.fi-backend.svc.cluster.local` — bizim kodumuzda değil

Kullanıcının Seq'ten attığı log: Fimple **200 OK** dönüyor ama gövdede `"Success": false`,
`Reasons: [{"Code":500,"Text":"getaddrinfo ENOTFOUND fi-saga-api.fi-backend.svc.cluster.local", ...}]`.

`fi-saga-api.fi-backend.svc.cluster.local` — **Fimple'ın kendi Kubernetes cluster'ının içindeki bir servis
adı** (bizim değil). Fimple'ın kendi saga/workflow backend'i o anda kendi içinde bu servise ulaşamamış —
**bizim tarafımızda, bizim koddan çağrılan hiçbir şeyle ilgisi yok**, Fimple test ortamının kendi geçici
altyapı sorunu. `RefitExtension.GetFimpleContentOrThrowAsync` bu `Reasons[0].Code/Text`'i okuyup
`ExternalApiException` fırlatıyor — bu da hem batch'te hem bizde **aynı, doğru davranış**
(EXTERNAL_ERROR olarak yukarı taşınıyor).

## Test durumu

`NetTrex.MM.Api.Api` (host) VS'de canlı çalıştığı için `dotnet build NetTrex.MM.sln` dosya kilidi hatası
verdi (bilinen durum, host'a dokunulmadı) — sadece test projesi build edildi:
- `dotnet build UnitTest/Api/NetTrex.MM.Api.Services.Tests/...csproj` → **0 error**.
- `NetTrex.MM.Api.Services.Tests.exe -namespace "*ManualRediscount*"` → **83 test, 0 hata** (82 → 83, yeni regresyon testi).

## Açık kalan

- **Execute-hang mistery** — parkta, kullanıcı isteğiyle durduruldu. Yeniden gündeme gelirse `DistKey`/lock
  mekanizması framework tarafına sorulmalı.
- IL fiş kesme (Execute/Generate/Regenerate) hâlâ yazılmadı — ayrı onay bekliyor (progress-20'den beri değişmedi).
- `dotnet build NetTrex.MM.sln` (host dahil tam solution) bu oturumda hiç doğrulanamadı — host container
  ayakta olduğu sürece bu normal, kullanıcı kendi IDE'sinde zaten sürekli build ediyor.
