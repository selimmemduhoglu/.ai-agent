# 07 — Fimple Entegrasyonu: Mevcut Sözleşme + Alternatif API Önerileri

> **Amaç:** Manuel Reeskont ekranının **Fimple ayağını** kesinleştirmek — bugün hangi API çağrılıyor,
> payload'da ne var, ekranın tasarımına ne zorunluluk getiriyor; ve **alternatif olabilecek** Fimple API'leri.
>
> ⚠️ **§ 5 tamamen ÖNERİ'dir.** Kullanıcı bu klasörleri *"sadece öneride bulunman için"* verdi.
> Mimari kararı (`02-mimari-karar.md`) ve iş emri (`05-faz-plani.md`) **değişmedi** —
> önerilerden biri kabul edilirse o zaman ADR yazılır.
>
> **Son Güncelleme:** 2026-08-12

---

## 0. Kaynaklar ve durum tespiti

| Kaynak | Ne var | Durum |
|---|---|---|
| `imports/Manuel Reeskont v1.docx` | 🔴 **Fimple'dan HİÇ bahsetmiyor** — `word/document.xml` (50.558 karakter) tarandı, **"fimple" eşleşmesi 0**. API yolu, `AccountingType`, `MessageKey` de yok. Yalnız 8 kez "muhasebe", 1 kez "reeskont fişi" geçiyor | ✅ ölçüldü |
| `HelperFolder/FimpleRequests/` | **Gerçek istek/yanıt örnekleri** — `Revaluation`, `Revaluation Reverse`, `Create`, `ForwardCreate`, `ForwardBatch-DoAccounting`, `Maturation` | ✅ okundu |
| `HelperFolder/Fimple-docs/Document(ctrl+c)/` | API referans dökümleri — `Accounting` (99 KB), `Fx` (215 KB), `Transfers` (59 KB), `Deposit` (**0 byte — boş**) | ✅ Accounting tarandı |
| `NetTrex.MM/.../Refit/External/IFimpleApi.cs` | MM'in **fiilen çağırdığı** endpoint'ler | ✅ okundu |

> 🔑 **Sonuç:** *"dokümanda verilen Fimple API'leri"* diye bir şey **yok** — doküman ekranı tanımlıyor,
> Fimple sözleşmesini tanımlamıyor. Fimple ayağının tek gerçek kaynağı **MM'in mevcut entegrasyonu**
> (`IFimpleApi`) + **`FimpleRequests` örnekleri**. Bu dosya o boşluğu kapatıyor.

---

## 1. Bugün kullanılan API (BASELINE — değişmiyor)

MM'in reeskont ve ters fiş için çağırdığı tek uç:

```csharp
// NetTrex.MM.Common.Abstractions/Refit/External/IFimpleApi.cs:38
[Post("/Fx/TreasuryTransactions/DoAccounting")]
```

Aynı endpoint **hem fiş hem ters fiş** kesiyor — ayrım `DoAccounting` / `DoReverseAccounting` bayraklarında.
Fimple tarafında karşılığı: `ScopeKey = CREATE_TREASURY_TRANSACTION`,
handler `Fi.Fx.Api/Impl/Command/TreasuryTransactionCommandHandler.cs` (response `ExecutionTrace`'inden okundu).

MM'de kayıtlı diğer muhasebe uçları (**reeskont için kullanılmıyor** ama mevcut):

| Endpoint | Not |
|---|---|
| `POST /Accounting/AccountingEntries/DynamicAccounting` | **2 metotla kayıtlı** — dinamik fiş; ters fiş de kesebiliyor (bkz. Ö-09) |
| `POST /Accounting/CreateAccountings/DirectDynamicAccounting` | 2 metot |
| `POST /Fx/TreasuryTransactions/{Create,DirectCreate,DirectAccounting,MessageTransaction,TermPayment}` | işlem yaşam döngüsü |

---

## 2. Reeskont fişi (T+0) — gerçek payload anatomisi

`FimpleRequests/Revaluation/Request.txt` — **aynen**:

```json
{
  "LogicalReference": "TMMBRW2606040005",
  "AccountingType": "Rediscount",
  "AccountingTransactionDate": "2026-06-25T00:00:00+03:00",
  "DoAccounting": true,
  "DoReverseAccounting": false,
  "TransactionType": "Interbank",
  "AccountingModel": {
    "TransactionDate": "2026-06-25T00:00:00+03:00",
    "Description": "Central Bank of Kenya ile yapılan TMMBRW2606040005 referanslı 14,47 TRY değerli borç alma işlemi reeskont fişi",
    "Code": "ThirdPartyEntry",
    "ProcessCode": "ThirdPartyTreasuryAccounting",
    "TransactionWorkgroupId": 2,
    "Details": [
      { "SequenceNumber": 1, "GLAccount": "62699000", "CustomerId": "460788",
        "ReferenceType": "TreasuryAccount", "ReferenceNumber": "260316", "CurrencyId": "TRY",
        "Description": "…reeskont fişi", "FxRate": 0.0,
        "Debit": 14.47, "Credit": 0.0,
        "GroupGuid": "3039dfac-a8bf-48f8-8f55-ba13d2750863", "RowVersion": 1 },
      { "SequenceNumber": 2, "GLAccount": "36099000", "CustomerId": "460788",
        "ReferenceType": "TreasuryAccount", "ReferenceNumber": "260316", "CurrencyId": "TRY",
        "Description": "…reeskont fişi", "FxRate": 0.0,
        "Debit": 0.0, "Credit": 14.47,
        "GroupGuid": "3039dfac-a8bf-48f8-8f55-ba13d2750863", "RowVersion": 1 }
    ]
  }
}
```

### Alan bazlı analiz — ekranı bağlayan noktalar

| Alan | Değer / kural | Manuel Reeskont'a etkisi |
|---|---|---|
| `LogicalReference` | İşlemin LR'si (`TMM…`) | Grid'de zaten gösteriliyor; `executions` isteği **TransactionId** taşıyor → backend LR'yi kendi çözer. ⚠️ Aynı LR hem `TxnMm` hem `TxnLoan`'da olabilir → `ProductSourceType` ile ayır (`G-08`) |
| `AccountingType` | **`"Rediscount"`** (string!) | `FimpleAccountingType.Rediscount = 1` enum'ının string karşılığı. Manuel fiş için ayrı bir tip **gerekiyor mu** → **M-07** hâlâ açık |
| `AccountingTransactionDate` | T+0 valörü, **+03:00 offset'li** | Ekrandan gelen `ExecutionDate`. ⚠️ Offset'li gönderiliyor — UTC'ye çevirme hatası valörü **bir gün kaydırır** |
| `DoAccounting` / `DoReverseAccounting` | `true/false` çifti | Tek endpoint, iki mod. Ekranın Generate/Regenerate akışı bu iki bayrağın kombinasyonuna iniyor |
| `TransactionType` | `"Interbank"` | MM'de Interbank/Corporate ayrımı var → Corporate işlemde farklı değer bekleniyor (**doğrulanmadı** → `Ö-S-04`) |
| `AccountingModel.Code` | `"ThirdPartyEntry"` | Sabit |
| `AccountingModel.ProcessCode` | `"ThirdPartyTreasuryAccounting"` | Sabit |
| `TransactionWorkgroupId` | `2` | Muhasebe birimi. Hard-code mu, parametreden mi → **doğrulanmadı** (`Ö-S-05`) |
| `Details[].GLAccount` | `62699000` (borç) / `36099000` (alacak) | GL eşlemesi MM'in accounting motorundan geliyor — ekran **karışmıyor** |
| `Details[].Debit` / `Credit` | **14.47 → 2 ondalık** | 🔴 **Fimple hassasiyet kuralı** (MM Hard Rule 11 / workspace Hard Rule 4). `RoundAwayFromZero(2)` zorunlu → **İ-61** |
| `Details[].FxRate` | `0.0` | TRY olduğu için 0; dövizde kur beklenir |
| `Details[].GroupGuid` | **İki satırda AYNI** | Fişin satırlarını gruplayan anahtar. 🔴 MM her istekte **yeni `Guid`** üretiyor (`FimpleAccountingService.cs:281`) → **idempotency yok** (`T-02`) |
| `Details[].RowVersion` | `1` | Sabit |
| `Description` | Türkçe, işlem detayı gömülü | Şablon MM'de üretiliyor; manuel fişte "manuel" ibaresi olacak mı → **iş birimi sorusu** |

---

## 3. Ters fiş (T+1) — payload

`FimpleRequests/Revaluation Reverse/Request.txt` — **aynen**:

```json
{
  "LogicalReference": "TMMBRW2606040005",
  "ReverseMessageKey": 680957473713147904,
  "AccountingType": "Rediscount",
  "ReversAccountingTransactionDate": "2026-06-25T00:00:00+03:00",
  "DoAccounting": false,
  "DoReverseAccounting": true,
  "TransactionType": "Interbank"
}
```

### 🔑 Üç kritik çıkarım

**1. `ReversAccountingTransactionDate` VAR → dokümanın `ReverseValueDate`'i uygulanabilir (C-08'e kanıt).**
Doküman §4.2 T+0/T+1 istiyor ama `ExecutionsRequest`'in ikinci tanımında `ReverseValueDate` **kayıp** (C-08).
Fimple tarafı bu ayrı tarihi **zaten destekliyor** → alan sözleşmede **kalmalı**; kaybolması dokümanın
kopyala-yapıştır hatası, teknik bir kısıt **değil**.
⚠️ Fimple'ın alan adı **`Revers`AccountingTransactionDate** — "Reverse" değil. **Yazım hatası Fimple'da**;
DTO'da bire bir bu şekilde yazılmalı yoksa alan sessizce `null` gider.

**2. Ters fiş için `ReverseMessageKey` ZORUNLU → `MessageKey` kalıcı tutulmalı.**
Ters fiş, orijinal fişin `MessageKey`'i olmadan kesilemez. Yani:

- `accEntryMain.MessageKey` **doğru şekilde persist edilmiş olmalı** (MM'de var — `analiz-2`)
- `eligible-transactions` yanıtı, `Not Reversed` durumundaki satır için backend'in ters fişi kesebilmesi
  adına **MessageKey'i çözebilir durumda olmalı** (UI'ye göndermek **şart değil**, hatta göndermemek daha iyi)
- **Durum türetme (M-08) bu zincire dayanıyor:** `MessageKey` var + `IsReverse = false` → `Not Reversed`;
  ters kaydı da varsa → `Rediscounted`

**3. Ters fişte `AccountingModel` YOK.** Fimple orijinal fişten satırları kendisi bulup tersine çeviriyor.
→ Ters fiş için MM'de GL/tutar yeniden hesaplanmaz. **Ters fiş ucu ucuz**, T+0 fişi pahalı.

---

## 4. Yanıt anatomisi ve tuzaklar

`FimpleRequests/Revaluation/Response.txt` (`ExecutionTrace` hariç):

```json
{
  "Value": { "Id": 61225, "AccountingType": "Rediscount", "MessageKey": "681584965004152832" },
  "Reasons": [],
  "Success": true,
  "BusinessKey": "681584964876894209",
  "MessageKey":  "681584964876894208",
  "SdkVersion": "1.34.84.0",
  "ServiceVersion": "v1.34.0-beta.40",
  "ScopeKey": "CREATE_TREASURY_TRANSACTION",
  "SagaOperationStatus": 0,
  "ExecutionTrace": "[…]"
}
```

| # | Tuzak | Sonuç |
|---|---|---|
| **FT-01** | 🔴 **İKİ AYRI `MessageKey` var:** `Value.MessageKey` (**fişin** anahtarı, `…152832`) ve zarf seviyesindeki `MessageKey` (**mesajın** anahtarı, `…894208`). Ters fişte gereken **`Value.MessageKey`** | Yanlışını persist edersen ters fiş **çalışmaz**; hata da net olmaz |
| **FT-02** | 🔴 **Tip tutarsızlığı:** yanıtta `MessageKey` **string** (`"681584965004152832"`), ters fiş isteğinde `ReverseMessageKey` **number** (`680957473713147904`) | 19 haneli → `int` taşar; `long` şart. JSON serileştirmede string↔long dönüşümü açıkça yapılmalı |
| **FT-03** | `Success` + `Reasons[]` **HTTP 200 içinde** geliyor | `RefitExtension` doğru overload'u seçilmeli: generic `FimpleResponseBase<T>` → `GetFimpleContentOrThrowAsync`; **non-generic** `FimpleResponseBase` → `GetFimpleUnitOrThrowAsync`. Yanlış seçimde Fimple iş hatası **sessizce yutulur** (MM MEMORY, 2026-07-23) |
| **FT-04** | `SagaOperationStatus: 0` + trace'te `InitializeSagaInstance` | Fimple tarafı **saga** çalıştırıyor → kısmi başarı/telafi senaryosu var. `Ö-04` (`Compensate`) bununla ilgili |
| **FT-05** | ⭐ Trace'te **`IdempotencyActionFilter.cs`** var (`Fi.ApiBase/ActionFilter/`) | **Fimple'da idempotency altyapısı VAR.** API dökümanlarında **hiç geçmiyor** (`grep -i idempotenc` → 0 eşleşme, 3 dosya). Header ile kullanılabiliyorsa `T-02` (çift tıklama = çift fiş) **kökten** çözülür → `Ö-08`, Fimple ekibine sorulacak |
| **FT-06** | `ServiceVersion: v1.34.0-beta.40` · `SdkVersion: 1.34.84.0` | Örnekler **2026-06-25** tarihli, döküman **2026-04-06** güncellemeli. Yeni sürümde alan değişmiş olabilir → kodlamadan önce canlı bir çağrıyla teyit |

---

## 5. 🔵 ALTERNATİF API ÖNERİLERİ (yalnızca öneri — karar kullanıcının)

`Fimple-docs-Accounting.txt` taramasından çıkan, Manuel Reeskont'a **doğrudan** yarayabilecek uçlar.

### Ö-01 ⭐⭐⭐ `POST /Accounting/AccountingEntries/DoManualBulk` — "Bulk create manual accounting entries"

| | |
|---|---|
| **Çözdüğü sorun** | 🔴 **C-07 / R-02 — 248 satır × senkron Fimple çağrısı = timeout.** Tek HTTP isteğinde çok fiş |
| **Scope** | `CREATE_ACCOUNTING` |
| **Kazanç** | N satır → **1 çağrı**. Ağ gidiş-dönüşü, token yenileme, timeout riski **N kat** düşer |
| 🔴 **Risk** | **"Manual" fiş, TreasuryTransaction fişi DEĞİL.** Baseline `AccountingType: "Rediscount"` + `LogicalReference` + `TransactionType: "Interbank"` ile Fimple'ın **hazine işlemi** bağlamına bağlanıyor. `DoManualBulk` muhtemelen bu bağı **kurmuyor** → hazine raporları, `AccountingType` bazlı sorgular ve **ters fiş zinciri** (`ReverseMessageKey`) kırılabilir |
| **Önerim** | **Faz 2'de araştır, Faz 1'de kullanma.** Fimple ekibine sor: *"DoManualBulk ile kesilen fiş `AccountingType=Rediscount` + `LogicalReference` bağını koruyor mu, `ByMessageKey/Reverse` ile terslenebiliyor mu?"* Cevap "evet" ise C-07'nin **en temiz** çözümü bu |

### Ö-02 ⭐⭐⭐ `BatchAccountingEntries` üçlüsü — asenkron kuyruk

```text
POST /api/v1/Accounting/BatchAccountingEntries/Queue                              → kuyruğa at
POST /api/v1/Accounting/BatchAccountingEntries/{DraftId}/DoAccounting             → toplu muhasebeleştir
GET  /api/v1/Accounting/BatchAccountingEntries/{DraftId}                          → durum sorgula
GET  /api/v1/Accounting/BatchAccountingEntries/ByParameters                       → liste
PUT  /api/v1/Accounting/BatchAccountingEntries                                    → güncelle
```

| | |
|---|---|
| **Çözdüğü sorun** | 🔴 **C-07 asenkron.** Dokümanın kayıp "6.1 Asenkron İşlem Mimarisi" bölümünün **hazır cevabı**: draft → queue → poll |
| **Ekrana uyumu** | Doküman'daki **`Processing`** durumu (`Status = 2`) tam bu modele oturuyor. `DraftId` = ekranın takip anahtarı |
| **Bizde emsal VAR** | `FimpleRequests/ForwardBatch-DoAccounting/` — MM zaten **bir batch DoAccounting** akışı kullanıyor (⚠️ `Response.txt` **0 byte**, yanıt şekli bilinmiyor) |
| 🔴 **Risk** | Ö-01 ile aynı "manual/batch fiş ≠ treasury fiş" sorusu · draft yaşam döngüsü ek state (DB'de `DraftId` tutulacak) · yanıt şekli belgesiz |
| **Önerim** | **C-07 "asenkron" çıkarsa birinci aday.** `İ-54`'teki `IManuelReeskontExecutionDispatcher` dikişi tam bunun için açıldı — dispatcher'ın arkasına konur, çağıran kod değişmez |

### Ö-03 ⭐⭐ `PUT /Accounting/AccountingEntries/ByMessageKey/{MessageKey}/Reverse`

| | |
|---|---|
| **Ne** | Fişi **MessageKey ile doğrudan** tersine çevirir. Kardeşi: `ByBusinessKey/{BusinessKey}/Reverse`, ayrıca `POST /AccountingEntries/Reverse` |
| **Baseline'a göre** | Bugün ters fiş `/Fx/TreasuryTransactions/DoAccounting` + `DoReverseAccounting: true` + `ReverseMessageKey` ile kesiliyor — **çalışıyor** |
| **Kazancı** | Semantik olarak daha net (REST yolu ters fişi anlatıyor), gövde neredeyse boş |
| 🔴 **Risk** | Baseline **çalışıyor ve kanıtlı** (`FimpleRequests/Revaluation Reverse`). Bu uç `AccountingType`/hazine bağını koruyor mu **bilinmiyor**. ⚠️ Ayrıca **`ReversAccountingTransactionDate` (T+1 valörü) parametresi var mı belirsiz** — yoksa doküman §4.2 karşılanamaz |
| **Önerim** | **Değiştirme.** Yalnız `Ö-01`/`Ö-02` benimsenirse (manual/batch fiş kesilirse) ters fiş için **bu uç gerekli hale gelir** — çünkü o fişlerin `TreasuryTransactions` karşılığı olmayabilir |

### Ö-04 ⭐⭐ `MultipleAccounting` + `MultipleAccounting/Compensate`

```text
POST /api/v1/Accounting/AccountingEntries/MultipleAccounting              → çoklu fiş
POST /api/v1/Accounting/AccountingEntries/MultipleAccounting/Compensate   → telafi (geri alma)
```

| | |
|---|---|
| **Çözdüğü sorun** | **`Compensate`** → toplu işlemde **kısmen başarı** durumunda başarılı olanları geri alma. `ADR-MR-007` (satır bazlı izolasyon) + `FT-04` (saga) ile aynı hizada |
| **Regenerate'e uyumu** | Regenerate = "önceki fişi geri al + yeniden değerle". Bugün bu **ters fiş** ile yapılıyor; `Compensate` daha doğru semantik olabilir |
| 🔴 **Risk** | `Compensate`'in muhasebe etkisi ters fişten **farklı** olabilir (kayıt silme vs karşı kayıt) → **mali tablo/denetim** etkisi. Bu bir **muhasebe kararı**, teknik tercih değil |
| **Önerim** | **Muhasebe birimine sor**, kendi başına karar verme. Ters fiş izi bırakır, `Compensate` bırakmayabilir |

### Ö-05 ⭐ `POST /Accounting/AccountingEntries/CancelAccounting` — "Receipt cancellation"

| | |
|---|---|
| **Scope** | `DELETE_ACCOUNTING` · **Starting process:** `CancelAccounting` |
| **İlgisi** | Regenerate'in "önceki fişi geri al" adımı için **üçüncü** seçenek (ters fiş / Compensate / Cancel) |
| 🔴 **Risk** | `DELETE_ACCOUNTING` scope'u = **fiş iptali**. Aynı gün içinde mi kısıtlı, kapanmış dönemde çalışıyor mu **bilinmiyor**. Reeskont fişi ertesi gün terslendiği için "iptal" penceresi kaçmış olabilir |
| **Önerim** | **Kullanma** — ters fiş deseni MM+FX'te kurulu ve denetim izi bırakıyor. Yalnızca "aynı gün, henüz gün sonu almadan yanlış fişi tamamen yok et" gibi bir iş kuralı çıkarsa değerlendir |

### Ö-06 ⭐⭐⭐ Durum doğrulama / sorgu uçları — **M-08 için**

```text
GET /api/v1/Accounting/AccountingEntries/ByMessageKey/{MessageKey}
GET /api/v1/Accounting/AccountingEntries/ByMainMessageKey/{MainMessageKey}
GET /api/v1/Accounting/AccountingEntries/ByParameters
GET /api/v1/Accounting/AccountingEntries/InfoByParameters
GET /api/v1/Accounting/AccountingEntries/ManualAccountingEntries/     ← FromDate/ToDate/ReferenceType/ReferenceNumber/WorkgroupId
GET /api/v1/Accounting/AccountTransactions/CheckTransaction
```

| | |
|---|---|
| **Çözdüğü sorun** | 🔴 **M-08 "son aktif hareket" tanımı** + doküman §4.5 *"backend her satırın durumunu yeniden doğrular"* |
| **Neden değerli** | Bugün durum **yalnız bizim `accEntryMain`**'imizden türetiliyor. Fimple ile **sapma** olursa (bizde fiş var, Fimple'da yok / tersi) ekran **yalan söyler** ve kullanıcı çift fiş keser. `ByMessageKey` ile fişin Fimple'da **gerçekten** var olduğu doğrulanabilir |
| **`ByMainMessageKey`** | Fiş↔ters fiş **zincirini** tek çağrıda verebilir → durum türetme (`Not Reversed` mi `Rediscounted` mi) doğrudan buradan okunabilir |
| 🔴 **Risk** | **Performans:** 248 satır × 1 GET = liste ekranını öldürür. Sayfa başına (50 satır) bile ağır |
| **Önerim** | **Liste sorgusunda KULLANMA** — durum bizim tablodan türetilsin (hızlı). **`executions` anında, satır bazında KULLAN** — fiş kesmeden önce `ByMessageKey`/`ByMainMessageKey` ile teyit et. Böylece §4.5'in "yeniden doğrula" şartı **gerçek** doğrulama olur, sadece kendi tablomuza bakmak değil. Ayrıca **mutabakat (reconciliation) raporu** için `ManualAccountingEntries` + `ByParameters` ideal — `FromDate`/`ToDate`/`ReferenceType`/`ReferenceNumber` filtreleri bizim ihtiyacımıza tam uyuyor |

### Ö-07 ⭐ `POST /Accounting/AccountingEntries/DynamicAccounting` — **MM'de ZATEN kayıtlı**

| | |
|---|---|
| **Durum** | `IFimpleApi.cs:62` ve `:72` — **iki metotla bağlı**, MM başka akışlarda kullanıyor |
| **Döküman notu (aynen)** | *"This API can also be used to issue a reverse accounting entry. **If the reverse business key is sent full, a reverse entry is issued.**"* |
| **İlgisi** | Tek uçtan hem fiş hem ters fiş — baseline'ın `DoAccounting`/`DoReverseAccounting` deseninin muhasebe tarafındaki eşleniği. **Zaten entegre** olduğu için deneme maliyeti en düşük |
| **Önerim** | `Ö-01`/`Ö-02` araştırılırken **kıyas noktası** olarak dene — Refit interface'i, auth'u, hata sarmalayıcısı hazır |

### Ö-08 ⭐⭐⭐ Idempotency header — **`T-02`'nin kökten çözümü**

| | |
|---|---|
| **Kanıt** | Yanıt `ExecutionTrace`'inde `Fi.ApiBase/ActionFilter/**IdempotencyActionFilter.cs**:76` çalışıyor |
| **Belge durumu** | 🔴 3 döküman dosyasında **"idempotenc" kelimesi hiç yok** (`grep -i` → 0) — özellik var, belgesiz |
| **Bizdeki sorun** | `FimpleAccountingService.cs:281` her istekte **yeni `Guid`** üretiyor → çift tıklama = **çift fiş + Fimple'da çift kayıt** |
| **Öneri** | Fimple ekibine sor: *"hangi header (`Idempotency-Key`?), TTL ne, aynı key + farklı gövde ne yapıyor?"* Destekliyorsa: key = **deterministik** (`{TxnId}-{AccountingType}-{ValueDate}-{IsReverse}`) → Fimple ikinci isteği **kendisi** yutar. Bu, uygulama tarafındaki kilit/guard'dan **çok daha güvenli** (birden fazla pod, retry, kullanıcı F5) |
| **Yerine geçmez** | `İ-59` (uygulama tarafı guard) **yine yazılır** — Fimple desteklemezse tek koruma o |

### Ö-09 — Kullanılmayacak ama bilinmesi gerekenler

| Uç | Neden ilgisiz |
|---|---|
| `AccountingEntries` (tek fiş, `POST`) | Baseline zaten fiş kesiyor; hazine bağı yok |
| `ById/{Id}/UpdateDescription` | Fişin açıklamasını düzeltmek — ekranın kapsamında değil |
| `ByBusinessKey/{BusinessKey}/Copy` | Fiş kopyalama — Regenerate'in "aynısını tekrar kes" senaryosu **değil** (tutar yeniden hesaplanmalı) |
| `CreditBalanceControl` / `DebitDepositAccounts` / `DepositAccounts` | Hesap bakiyesi/mevduat — reeskont akışında yok |
| `View/ByParameters` | Muhasebe görünümü raporu |

---

## 6. Karşılaştırma — mevcut vs alternatifler

| Kriter | Baseline `/Fx/TreasuryTransactions/DoAccounting` | `Ö-01 DoManualBulk` | `Ö-02 BatchAccountingEntries` |
|---|---|---|---|
| Kanıtlı çalışıyor mu | ✅ **Evet** (gerçek istek/yanıt elde) | ❓ denenmedi | 🟡 MM'de benzer akış var, yanıt şekli belgesiz |
| N satır için çağrı sayısı | **N** (+ N ters fiş) | **1** | **2-3** (queue + do + poll) |
| C-07 timeout riski | 🔴 Yüksek | 🟢 Düşük | 🟢 Düşük (asenkron) |
| Hazine bağı (`AccountingType`, `LogicalReference`) | ✅ Korunuyor | ❓ **belirsiz — en büyük risk** | ❓ belirsiz |
| Ters fiş zinciri (`ReverseMessageKey`) | ✅ Aynı uçtan | ❓ `Ö-03` gerekebilir | ❓ `Ö-03` gerekebilir |
| T+1 ayrı valör (`ReversAccountingTransactionDate`) | ✅ **Destekliyor** | ❓ | ❓ |
| Satır bazlı hata izolasyonu (`ADR-MR-007`) | ✅ Doğal (her satır ayrı çağrı) | 🔴 **Bulk'ta kısmi hata nasıl dönüyor?** | 🟡 Draft durumundan okunur |
| Uygulama maliyeti | **0** (mevcut) | Orta | Yüksek (state + polling) |

> 🔑 **Satır bazlı hata izolasyonu ödünleşmesi:** Baseline'ın "N çağrı" dezavantajı aynı zamanda
> **avantajı** — her satır bağımsız, biri patlarsa diğerleri etkilenmiyor (`ADR-MR-007` bedelsiz sağlanıyor).
> Bulk'a geçiş, kısmi hata raporlamasını **Fimple'ın yanıt şekline** bağımlı kılar. Bu yüzden bulk'a
> geçmeden önce *"kısmi hatada ne dönüyor"* sorusunun cevabı **şart**.

---

## 7. Önerim — özet

| Faz | Ne yapılsın |
|---|---|
| **Faz 1** (okuma) | Fimple **hiç çağrılmıyor** → değişiklik yok. Yalnız `MessageKey` zincirinin (`FT-01`) durum türetmede doğru kullanıldığından emin ol |
| **Faz 2** (yazma) | **Baseline ile başla** — kanıtlı, sıfır maliyet, satır izolasyonu bedelsiz. `IManuelReeskontExecutionDispatcher` dikişi zaten açık |
| **Faz 2 · paralel** | `Ö-08` (idempotency) + `Ö-06` (`ByMessageKey`/`ByMainMessageKey` ile satır bazlı ön-doğrulama) → **ikisi de baseline'ı bozmadan** eklenir, en yüksek fayda/risk oranı |
| **C-07 "asenkron" çıkarsa** | `Ö-02` birinci aday, `Ö-01` ikinci. Dispatcher'ın arkasına konur |
| **Sorulmadan yapılmayacak** | `Ö-04` `Compensate` ve `Ö-05` `CancelAccounting` — **muhasebe/denetim** kararı, teknik tercih değil |

---

## 8. Fimple ekibine sorulacaklar (yeni)

| # | Soru | Neyi açar |
|---|---|---|
| **Ö-S-01** | `DoManualBulk` ile kesilen fiş `AccountingType = Rediscount` + `LogicalReference` + `TransactionType` hazine bağını **koruyor mu**? | `Ö-01` |
| **Ö-S-02** | `DoManualBulk` / `MultipleAccounting` **kısmi hatada** ne dönüyor — hepsi geri mi alınıyor, satır bazlı sonuç mu? | `Ö-01`, `Ö-04`, `ADR-MR-007` |
| **Ö-S-03** | **Idempotency** hangi header ile çalışıyor, TTL ne, aynı key + farklı gövde ne yapıyor? | `Ö-08` — `T-02` |
| **Ö-S-04** | Corporate (müşterili) işlemde `TransactionType` değeri ne? (`"Interbank"` yerine) | Baseline, Corporate reeskont |
| **Ö-S-05** | `TransactionWorkgroupId: 2` sabit mi, muhasebe birimine göre mi değişiyor? (`AccountingUnits/ByUserActiveWorkgroupId` uçları var) | Baseline |
| **Ö-S-06** | `BatchAccountingEntries` yanıt şekli + draft yaşam döngüsü (durumlar, TTL, hata) nedir? | `Ö-02` — `C-07` |
| **Ö-S-07** | `ByMessageKey/{MessageKey}/Reverse` ters fiş **valörünü** parametre olarak alıyor mu? | `Ö-03` — doküman §4.2 T+1 |
| **Ö-S-08** | Örnekler `v1.34.0-beta.40`, döküman **2026-04-06** güncellemeli. Reeskont payload'ında değişen alan var mı? | `FT-06` |

---

## 9. Riskler (bu analizden çıkan)

| # | Risk | Etki | Azaltma |
|---|---|---|---|
| **R-16** ⭐ | 🔴 **Yanlış `MessageKey` persist edilirse** (`Value.MessageKey` yerine zarf `MessageKey`) ters fiş çalışmaz, hata da net olmaz | 🔴 Yüksek | `FT-01` — MM'de mevcut kodun hangisini aldığı **doğrulanacak** (yeni iş kalemi) |
| **R-17** ⭐ | `ReversAccountingTransactionDate` **yazım hatalı** (Fimple'da "Revers"); DTO'da düzeltilirse alan **sessizce null** gider → ters fiş yanlış valörle keser | 🟠 Orta | Alan adı **aynen** yazılacak + entegrasyon testinde valör doğrulanacak |
| **R-18** ⭐ | Tarih alanları **`+03:00` offset'li**; UTC dönüşümü valörü **bir gün kaydırabilir** | 🟠 Orta | `DateTimeOffset` kullan, `DateTime.UtcNow` ile karıştırma; T+0/T+1 testleri gün sınırında (23:00-01:00) yapılacak |
| **R-19** ⭐ | Bulk/batch'e geçilirse **satır bazlı hata izolasyonu** (`ADR-MR-007`) Fimple'ın yanıt şekline bağımlı hale gelir | 🟠 Orta | `Ö-S-02` cevaplanmadan bulk'a geçilmeyecek |
| **R-20** ⭐ | `Fimple-docs-Deposit.txt` **0 byte** (boş) · `ForwardBatch-DoAccounting/Response.txt` **0 byte** | 🟡 Düşük | Mevduat uçları gerekirse kaynak yeniden alınacak |
