# progress-66 — Review düzeltmeleri, StateMaker damgası geri alındı: InterbankLoan flag, FX ters fiş kontrolü, testler, temizlik (2026-09-30)

> Önceki tur: [progress-65](progress-65.md). Tetikleyen: kullanıcı "StateMaker için ChangeTracker'a abone olup MAX(Id) üzerinden fiş bulmayalım; gerekmedikçe tracker'a müdahale etmeyelim".
> Kural: modüllerin manuel reeskont dışı koduna ve motorlarına dokunulmaz.

## Kararlar
- **StateMaker damgası KALDIRILDI** (4 modül). Fişler motorun yazdığıyla kalır (`"SYSTEM"` / işlemin trader'ı). Düzgün çözüm motor
  context'ine `StateMaker` taşımak (motor değişikliği) → **sonraki faz**, Rediscounted + Regenerate açıklarıyla birlikte.
- **InterbankLoan:Enabled=false** → IL ürün listesine gelmez, IL için hiçbir manuel reeskont işlemi çalışmaz, MM etkilenmez.
- **AccruedInterest**: değerleme yoksa eskisi gibi `null` (0 değil).
- **FX ters fiş**: motor ters fiş üretmezse (`ValuationProduced=false`) satır başarılı sayılmaz.
- **C5 (FX ProductCode)**: zorunlu değil — FX Id'leri tablo önekli (TxnFx 11…, TxnSwap 22…, TxnPm 33…, TxnPmSwap 44…), yerli
  işlemlerde çakışma yok. External `LocalId` DB'den doğrulanmadı. Dokunulmadı.
- **Common.UI çift bildirim**: diğer sayfalarla aynı desen (`catch → notifyError`), bırakıldı.
- **WebUI Acc. butonu** bulgusu yanlıştı: `#popupAcc` `_FrameworkLayout.cshtml:58`'de, `Accounting` action'ı `BaseController.cs:37`'de.

## StateMaker — neden geri alındı
- progress-65'teki `StampNewAccountingEntriesAsync` (EF `Tracked`/`StateChanged` aboneliği + satır öncesi `MAX(Id)`) tracker'a
  müdahale ediyordu; kullanıcı istemedi. 4 modülün tracker servisi HEAD hâline döndü, damga testleri silindi.
- Motora dokunmadan basit bir alternatif yok: fiş kaydedildikten sonra `UPDATE StateMaker` yapmak, önceden gönderilmiş
  Kafka/Fimple mesajıyla DB'yi farklılaştırır.
- FX / DerivSwp / OptFX `ExecutionsRequest`'e eklenen `CurrentUserId` ve validator kuralı da kaldırıldı (kullanan kalmadı).
  MM'deki `CurrentUserId` zorunluluğu eskiden beri var, dokunulmadı.
- MM / DerivSwp / OptFX test projelerindeki EF InMemory paketi kaldırıldı; FX'te repository testleri kullandığı için duruyor.

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
| MM | Rebuild 0 hata | Api 323/323 · Data 25/25 · Common.Services 292/292 (progress-65 turunda; bu turda MR dışı değişiklik yok) |
| FX | Rebuild 0 hata | ManualRediscount 50/50 |
| DerivSwp | Rebuild 0 hata | 97/97 (test projesi sln'de yok, ayrıca derlendi) |
| OptFX | Rebuild 0 hata | 134/134 |
| WebUI | 0 hata | jest 490/490 · C# `ManualRediscountQueryServiceTests` 4/4 |
| Common.UI | 0 hata | typecheck temiz |

FX `ManualRediscountRepositoryTest` EF InMemory 10.0.10 ile gerçek `EfDbContext` üzerinde koşar.

## Dokümanlar
`06-sozlesme.md` (MessageKey salt gösterim) · `00-PANO.md` (F-4 Revaluation Type kuralı kaldırıldı · T-01 StateMaker açık, sonraki faz) ·
`skills/manuel-reeskont.md`.

## Araştırma — Bloomberg STP (MM)
- `StpBloombergBatchItem` → `MarketIntegrationManager.CreateFromBloombergRawDataAsync` → `TransactionCreator.CreateAsync` bir
  **`TxnMmEntity`** üretir → `ITransactionDataManager.InsertAsync` → **TxnMM** tablosu (`ExternalReferenceSourceId = Bloomberg`).
- Ürün `BloombergDataAdapter.GetProductId` ile mevcut tanımlara eşlenir: Deposit/Normal → 1, IslamicDeposit/Wakala → 4, Murabaha → 5.
- `GetBloombergDoVerify` açıksa işlem 18 (verified) + açılış muhasebesi; kapalıysa 16 kalır, onaylanınca kapsama girer.
- Sonuç: manuel reeskontta **ayrı alt ürün gerekmez**; STP işlemleri kendi ürününün alt ürün seçiminde listelenir. FX'teki
  External FWD/SWP ayrı tablodan (`FimpleForward/SwapTransaction`) geldiği için ayrı kaynak; MM'de böyle ayrı bir tablo yok.
