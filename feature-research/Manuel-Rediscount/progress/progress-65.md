# progress-65 — Review sonrası düzeltmeler: StateMaker, InterbankLoan flag, FX ters fiş kontrolü, testler, temizlik (2026-09-30)

> Önceki tur: [progress-64](progress-64.md). Tetikleyen: 6 repoluk review raporu (WebUI · Common.UI · MM · FX · DerivSwp · OptFX).
> Kural: modüllerin manuel reeskont dışı koduna ve motorlarına dokunulmaz.

## Kararlar
- **StateMaker = işlemi yapan kullanıcı** (4 modül). Motor değişmedi.
- **InterbankLoan:Enabled=false** → IL ürün listesine gelmez, IL için hiçbir manuel reeskont işlemi çalışmaz, MM etkilenmez.
- **AccruedInterest**: değerleme yoksa eskisi gibi `null` (0 değil).
- **FX ters fiş**: motor ters fiş üretmezse (`ValuationProduced=false`) satır başarılı sayılmaz.
- **C5 (FX ProductCode)**: zorunlu değil — FX Id'leri tablo önekli (TxnFx 11…, TxnSwap 22…, TxnPm 33…, TxnPmSwap 44…), yerli
  işlemlerde çakışma yok. External `LocalId` DB'den doğrulanmadı. Dokunulmadı.
- **Common.UI çift bildirim**: diğer sayfalarla aynı desen (`catch → notifyError`), bırakıldı.
- **WebUI Acc. butonu** bulgusu yanlıştı: `#popupAcc` `_FrameworkLayout.cshtml:58`'de, `Accounting` action'ı `BaseController.cs:37`'de.

## StateMaker mekanizması
Her modülün MR'a özel tracker servisine `StampNewAccountingEntriesAsync(stateMaker, ct)`:
satır başında `MAX(Id)` okunur, EF `ChangeTracker.Tracked` + `StateChanged` dinlenir; muhasebe ana fişi `Added` ya da
`Modified` ve `Id > MAX(Id)` ise `StateMaker` = kullanıcı. Fiş kaydedilmeden ve Kafka mesajı üretilmeden önce yazılır.
Mevcut fişin `ReverseId` güncellemesi / silme işareti etkilenmez. Handler: `Reset()` sonrası `using var stamp = ...`.
- FX ana fişi dış muhasebe paketi ekleyip `UpdateAndDetach` ile yazıyor → `Modified + yeni Id` kuralı bunu yakalıyor.
- FX, DerivSwp, OptFX `ExecutionsRequest`'te `CurrentUserId` YOKTU (UI gönderiyordu, bağlanmıyordu) → düz property eklendi
  (base sınıf değişmedi); validator'lara `CurrentUserId` zorunlu kuralı.
- ⚠️ DerivSwp: `AccountingReverseService` Kafka'yı `Insert`'ten ÖNCE gönderiyor → önceden var olan fişin tersinde DB'de kullanıcı,
  Kafka payload'unda kaynak fişin StateMaker'ı. Düzeltmesi motor değişikliği ister; yapılmadı.

## InterbankLoan flag (MM + UI)
- MM `EligibleTransactionsHandler` / `ExecutionsHandler`: IL + flag kapalı → `PRODUCT_DISABLED`, veri katmanına hiç gidilmez.
- Yeni `GET api/manual-rediscount/products` (`ProductsHandler`) → açık ürünler.
- WebUI `ManualRediscountQueryService.GetEnabledProductsAsync` + `IManualRediscountModuleClient.IsProductEnabledAsync`;
  Common.UI `RediscountControllerBase.GetEnabledProductsAsync`. MM'e ulaşılamazsa IL gizlenir, diğer ürünler açılır.

## FX ValuationProduced
- Generate+NotReversed ve Regenerate+NotReversed 1. aşama: üretilmezse `NOT_REDISCOUNTED` ile Failed (rollback güvenli —
  o aşamada hiçbir şey yazılmadı; 1. aşamada durunca 2. aşama çalışmaz, gün ikiye katlanmaz).
- Regenerate son ters fiş üretilmezse satır **Success(NotReversed)**: önceki aşamalar Fimple'a gitti, rollback DB'yi Fimple'dan koparırdı.

## Temizlik
PO/tarihli notlar (MM test, WebUI/Common.UI js/ts/css/test/json, WebUI controller) · bayat yorumlar (IL "nota bakın", validator
"müşteri adı", constants JSDoc, DTO "sunucuda filtrelenir"/"üst sınırı modül uygular") · bayat test adları · 6 ölü localization
anahtarı · `MR_ROOT`/`MR_CLEAR`/`MR_PRODUCT_GROUP` · FX `ExistsAsync`, `Classify` sarmalayıcı, `FxRediscountStatusFilter` ·
DerivSwp/OptFX `RediscountStatusFilter` · DerivSwp valuation sorgusu 16 kolona projeksiyon · çift boş satırlar.

## Doğrulama
| Repo | Build | Test |
|---|---|---|
| MM | Rebuild 0 hata | Api 325/325 · Data 31/31 · Common.Services 292/292 |
| FX | Rebuild 0 hata | ManualRediscount 59/59 |
| DerivSwp | Rebuild 0 hata | 108/108 · Operation 145/145 · Batch 9/9 |
| OptFX | Rebuild 0 hata | 147/147 |
| WebUI | 0 hata | jest 490/490 · C# `ManualRediscountQueryServiceTests` 4/4 |
| Common.UI | 0 hata | typecheck temiz |

Yeni testlerin çoğu EF InMemory ile gerçek `EfDbContext` üzerinde (MM 10.0.5, DerivSwp 10.0.5, FX/OptFX 10.0.10).

## Dokümanlar
`06-sozlesme.md` (MessageKey salt gösterim) · `00-PANO.md` (F-4 Revaluation Type kuralı kaldırıldı, T-01) ·
`skills/manuel-reeskont.md`.
