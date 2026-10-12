# SQL Log — DB Erişim Denetim Kaydı

> 🔴 **Neden var:** Kullanıcının talimatı (2026-08-13):
> *"ben senin her SQL'e bağlanıp sorduğun soruyu ve response'unu görmek istiyorum ama **istisnasız
> hepsinin** çünkü **tehlikeli aslında DB'ye bağlanman**, o yüzden görmem lazım."*
>
> DB erişimi denetlenebilir olmalı. Bu klasör, `mssql-read` skill'i ile çalıştırılan **her** sorgunun
> ve **her** çıktının kalıcı kaydıdır.

---

## 🔴 Klasör yapısı — SOHBET BAŞINA KLASÖR

```text
.ai-agent/sql-log/
├── _index.md                       ← bu dosya (sohbet tablosu)
└── <chat-slug>/                    ← compacts/ ile AYNI slug
    ├── 01-sorgular.md              ← çalıştırılan SQL'ler + amaç
    └── 02-ciktilar.md              ← ham çıktılar + yorum
```

`<chat-slug>` **`compacts/` ile aynı** olmalı — aynı sohbetin compact'i ve SQL log'u eşleşsin.

---

## Değişmez kurallar

| # | Kural |
|---|---|
| 1 | 🔴 **İSTİSNASIZ HER SORGU** yazılır — başarılı, **başarısız**, keşif, tekrar, `sys.tables` dahil |
| 2 | Sorgu **çalıştırılmadan ÖNCE** `01-sorgular.md`'ye yazılır; çıktı gelince `02-ciktilar.md`'ye |
| 3 | İki dosya **aynı `#` numarası** ile eşleşir |
| 4 | Her sorguda **amaç** yazılır: *neyi neden öğrenmek istedim* |
| 5 | Çıktı **ham** yazılır; kırpıldıysa **"kırpıldı"** diye belirtilir |
| 6 | **Parola maskelenir** (`-P '***'`) — sunucu/DB/kullanıcı adı kalır |
| 7 | `01-sorgular.md` başındaki **özet tablosu** her sorgudan sonra güncellenir (yazma işlemi sayısı **her zaman 0** olmalı) |
| 8 | Önceki kayıtlar **asla düzenlenmez/silinmez** — denetim kaydıdır |

> ⚠️ **Yazma işlemi kaydı hiç olmamalı.** `mssql-read` yalnız `SELECT` yapar. Bu dosyada bir
> `INSERT/UPDATE/DELETE/DDL` görürsen **kural ihlali** olmuş demektir.

---

## Sohbetler

| Sohbet | Klasör | Sorgu | Yazma | Tarih | Konu |
|---|---|---|---|---|---|
| Manuel Reeskont — analiz & mimari | [manuel-reeskont-analiz/](manuel-reeskont-analiz/01-sorgular.md) | **16** | **0** | 2026-08-13 | `AccEntryMain` durum türetme (`M-08`) · şema keşfi · Faz 1 test verisi · **`NetTrexAcc` muhasebe motoru envanteri** (`AccEngine*`, `OnRevaluation`, ürün ağacı) |
| ProductDefinition edit/save fix | [productdefinition-edit-fix/](productdefinition-edit-fix/01-sorgular.md) | **2** | **0** | 2026-08-13 | `PrdProductDefinition` Order=30 çift kayıt doğrulaması (Id=7 aktif + Id=6 disabled) — uniqueness validator tuzağı |
| Manuel Reeskont — kodlama | [manuel-reeskont-kodlama/](manuel-reeskont-kodlama/01-sorgular.md) | **14** | **0** | 2026-08-17 | `NetTrexCommon.FrameworkMenu` menü görünürlüğü (Redis cache asıl sebep) + `NetTrexMM_134.TxnMM`/`AccEntryMain`/`TxnMMDetail` — Manual Rediscount eligible sorgusu hangi tarihte veri döndürüyor, gerçek sebep `treasury.json`'da `MoneyMarket` subproduct'ının hiç tanımlı olmaması |
| AccEngine politika silme scriptleri | [accengine-policy-silme/](accengine-policy-silme/01-sorgular.md) | **13** | **0** | 2026-09-10 | `NetTrexAcc` muhasebe motoru silme yüzeyi — zincirde FK yok (yalnız `Group.EventId`), `AccEngineDynamicMap` eski silme scriptinde **unutulmuş**, `TREX/SEC1/FI` ayrı FI node'u, kök Path'ler **slash'lı/slash'sız karışık**, 454 orphan `AccountRule` |
| MM Fimple SYNC — NULL PaymentAccountingGL | [mm-fimple-sync-gl-null/](mm-fimple-sync-gl-null/01-sorgular.md) | **11** | **0** | 2026-09-18 | `NetTrexMM_134` — `TxnMM`'de mirror'lanmış GL dolu ama Fimple'a giden `TxnSync`'te tek taraf **NULL**; `AccEntry.Source` değerleri (`IncomingAgentPaymentAmount` → `Contains("IncomingPayment")` ile eşleşmiyor); `TxnCashFlow`'da **hiçbir** satırda ikisi birlikte dolu değil (405 satır, IkisiDolu=0) |
| Manuel Reeskont — Common.UI/WebUI parity | [manuel-reeskont-commonui-parity/](manuel-reeskont-commonui-parity/01-sorgular.md) | **2** | **0** | 2026-09-24 | `NetTrexCommon.FrameworkPermission`/`FrameworkPermissionAction` — eski `ManuelRevaluationController` (WebUI, FX-only) permission deseni doğrulandı: sadece gerçek action'lara satır var, fazlası yok; `ManuelRevaluation_Maker`'da `Load` eksik (muhtemelen bozuk/stale örnek) — yeni Common.UI script'inde kopyalanmadı |
| txnMMDetail Int32→Int64 cast hatası | [txnmmdetail-int64-cast/](txnmmdetail-int64-cast/01-sorgular.md) | **1** | **0** | 2026-09-25 | `txnMMDetail.Id` kolon tipi kontrolü — login başarısız (`trusr`), sonuç alınamadı |
| MM Kafka notification fix | [mm-kafka-notification-fix/](mm-kafka-notification-fix/01-sorgular.md) | **2** | **0** | 2026-09-30 | `NetTrexCommon.ExternalNotification` kolon boyutları (ToMail/Subject 300, MailBody/NotificationResult MAX) — müşterideki "String or binary data would be truncated" test şemasıyla açıklanamıyor, müşteri şeması farklı |
| Swap & MM Raporu (AD-8945) | [swap-mm-rapor/](swap-mm-rapor/01-sorgular.md) | **4** | **0** | 2026-09-26 | Oran birimi (`txnMMDetail.InterestRate`, `TxnCashFlow.Rate`) + `txnFXSwap` bacak yapısı |
| DB mimarisi — tanım→işlem→değerleme→muhasebe akışı | [db-mimarisi-tanim-islem-akisi/](db-mimarisi-tanim-islem-akisi/01-sorgular.md) | **10** | **0** | 2026-10-02 | `defNumberGen`/`ExternalMM`/`accEngineGeneratedAccountRule`/`txnMMTax`/`txnNote`/`Market`/`Currency`/`LogicalReferenceType` ilk kez işlendi; `sp_GetNewNumbers` gövdesi (ROWLOCK/UPDLOCK atomik sayaç); **`LoanRevaluation`** adlı AYRI bir reeskont tablosu keşfedildi (`TxnMMDailyCalculation`'dan tamamen farklı, denormalize şema) — Collateral modülü için tanım→işlem akışı referans dokümanı (`reference/db-mimarisi-tanim-islem-akisi.md`) |
| Collateral DB isimlendirme konvansiyonu | [collateral-db-isimlendirme/](collateral-db-isimlendirme/01-sorgular.md) | **7** | **0** | 2026-10-02 | `NetTrexMM` `sys.*` katalog taraması — fiziksel tablo adları hep PascalCase prefix (`CusCustomer`, `DefDateBasis`); `decimal(38,2)` DB'de yok (para `38,10`); Id tip dağılımı; `Is*` bit kalıbı; PK/FK/IX/DF ad kalıbı |
| Collateral — DB nesne envanteri (SP/FN/constraint/trigger) | [collateral-db-nesne-envanteri/](collateral-db-nesne-envanteri/01-sorgular.md) | **11** | **0** | 2026-10-02 | `NetTrexMM`: 9 SP (hiçbiri `sp_UnverifiedDataCount_*` değil), 28 scalar FN (legacy finans), **0 CHECK constraint**, yalnız **16 FK** (2'si HangFire), 45 DF (44'ü `DF_` kalıbında), 5 unique index (filtered yok), 9 trigger = 9 History (1:1), `DefNumberGen` 8 satır (`'Txn Mm Id'` formatı). `NetTrexCommon`: **30 adet `sp_UnverifiedDataCount_*`** + `DefCountMonitoring` 30 satır — sayım SP'leri Common'da ama MM'i cross-database sorguluyor |

| Collateral — alt tablo Id deseni + referans veri kopyaları | [collateral-alt-tablo-ve-referans-kopya/](collateral-alt-tablo-ve-referans-kopya/01-sorgular.md) | **7** | **0** | 2026-10-02 | `PrdProductDefinitionMarketMap.Id` **IDENTITY DEĞİL** (sayaç 1032 = canlı Id'lerle birebir) ama History **yok**; `PrdProductDefinition` sayacı **ölü** (Id 1..11, sayaç 999, kodda çağrı yorumda). En yeni emsal `AmortizationConfiguration` (2026-04-21) → **IDENTITY bigint + History**. `NetTrexMM`'de `Id` IDENTITY olmayan **65/125** tablo — çoğu Common'dan kopyalanan referans verisi (kaynak Id birebir taşınıyor). Common↔MM **44 kopya tablo** eşleşmesi (`Customer`→`CusCustomer`, `Portfolio`→`PrfPortfolio`, `Country`→`DefCountry`…) satır sayılarıyla ölçüldü |
| LinkedTransaction alanları — MM'e ekleme | [linked-transaction-development/](linked-transaction-development/01-sorgular.md) | **7** | **0** | 2026-10-06 | `NetTrexFX_Dev.TxnFX` — wiki'nin 50/80 karakter spesifikasyonuna karşı gerçek kolon genişliği **100/100** (sapma, MM wiki'yi esas alacak); 147 Manual + 9 Imported, `None`/`Generated` hiç persist edilmemiş. `NetTrexMM.TxnMM` (675 satır, 146 Imported/529 Manual) ve `txnMMHistory` (3887 satır, 188/3699) backfill dağılımı ölçüldü. 🔴 **`TxnMMTrigger`** keşfedildi — `TxnMMHistory` uygulama kodundan hiç yazılmıyor, tamamen bu trigger'ın açık kolon listesiyle besleniyor; yeni 5 kolon trigger'a eklenmezse History sessizce NULL kalır |

> **Bağlandığım veritabanları:** `NetTrexMM` · `NetTrexMM_Dev` · `NetTrexAcc` · `NetTrexCommon` · `NetTrexCommon_Dev` · `NetTrexFX_Dev` · `master` (yalnız DB listesi).
> `NetTrexFX_Dev`'e kullanıcı onayıyla **2026-10-06'da ilk kez bağlanıldı** (LinkedTransaction geliştirmesi için FX'teki referans implementasyonu doğrulamak amacıyla) — önceki kural ("biz MM modülünü yazıyoruz") bu iş için kullanıcı tarafından **açıkça gevşetildi**: *"Gerekli yerlerde Fx dbsine sorgu atabilirsin."*

---

## İlgili

- Skill gövdesi → [`skills/mssql-read.md`](../skills/mssql-read.md)
- Compact kayıtları → [`compacts/_index.md`](../compacts/_index.md) (aynı `<chat-slug>`)
| `collateral-db-tablo-id-stratejisi` | 2026-10-07 | NetTrexCollateral için tablo envanteri + IDENTITY/DefNumberGen Id stratejisi (MM · OPTFX · DerivSWP karşılaştırması) |
| `mm-revaluation-report-manuel-kayit` | 2026-10-09 | txnMmDailyCalculation fiziksel şema (Identity/FK/trigger) — MmRevaluationReport ekranına manuel reeskont satırı |
