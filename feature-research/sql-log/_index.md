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

> **Bağlandığım veritabanları:** `NetTrexMM` · `NetTrexMM_Dev` · `NetTrexAcc` · `NetTrexCommon` · `NetTrexCommon_Dev` · `master` (yalnız DB listesi).
> `NetTrexFx`'e **bağlanılmadı** (kullanıcı: *"biz MM modülünü yazıyoruz"*).

---

## İlgili

- Skill gövdesi → [`skills/mssql-read.md`](../skills/mssql-read.md)
- Compact kayıtları → [`compacts/_index.md`](../compacts/_index.md) (aynı `<chat-slug>`)
