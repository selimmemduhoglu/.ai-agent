# 08 — TEST REHBERİ (Faz 1 & Faz 2)

> **Bu dosya, tüm fazlar bittikten sonra yapılacak TARAYICI TESTİ için hazırlanmıştır.**
> İçinde: ortamın nasıl ayağa kaldırılacağı · hangi test verisinin kullanılacağı · çalıştırılmış
> ve çalıştırılmamış test senaryoları · doğrulama SQL'leri · bulunan bug'lar.
>
> Kullanıcı talimatı (2026-08-13): *"Faz 1 ve 2 testi için araştırma ve yaptıklarını bir md dosyasına yaz,
> ben tüm fazlar bittikten sonra sana browser üzerinden test yaptıracağım, o yüzden tüm test bilgilerini kullanacağım."*
>
> **Son Güncelleme:** 2026-08-13 · İlgili kayıt: [`progress/progress-8.md`](progress/progress-8.md)

---

## 1. Ortam — nasıl ayağa kaldırılır

### 1.1 🔴 Önce bunu bil: kullanıcının docker stack'i zaten çalışıyor

```text
nettrexmmwebapi      0.0.0.0:5041->80/tcp      ← ESKİ image, yeni kod YOK
ui-nettrex           0.0.0.0:5032->80/tcp      ← ESKİ image, yeni kod YOK
nettrexmmbatchwebapi 0.0.0.0:5043->80/tcp
micro-ui-mm          0.0.0.0:5104->80/tcp
treasy-shell         0.0.0.0:5100->80/tcp
redis                0.0.0.0:6379->6379/tcp
seq                  0.0.0.0:9085->80/tcp
```

**Bu container'lara DOKUNULMADI.** Yeni kodu test etmek için **ayrı portlar** kullanıldı.
Alternatif (istenirse): `docker compose up --build` ile image'ları yenile — ama bu kullanıcının
ortamını değiştirir, **onay ister**.

### 1.2 MM API — port 5141

```bash
cd "C:/Users/Treasy-70/source/repos/NetTrex.MM/Code/Api/NetTrex.MM.Api"
dotnet run --launch-profile "NetTrex.MM.Api:Dev-Investment" --no-build \
  -- --urls=http://localhost:5141 --CommonApi=http://192.168.10.191:30825/api
```

- MM API **komut satırı config argümanlarını OKUYOR** → `--urls` ve `--CommonApi` çalışıyor.
- `--CommonApi` **zorunlu**: uygulama açılışta framework parametrelerini Common'dan çeker.
  Yerelde Common yoksa *"Hosting failed to start"* verir.

### 1.3 Web.UI — port 5132

🔴 **Web.UI komut satırı config argümanlarını OKUMUYOR** (özel host builder:
`Framework.Startup.DefaultStartup`). `--launch-profile` de env'i üzerine yazıyor.
**Çözüm: `--no-launch-profile` + env değişkenleri.**

```bash
cd "C:/Users/Treasy-70/source/repos/NetTrex.Web.UI/Code/Web/UI/Trex.WebUI"

ASPNETCORE_ENVIRONMENT=Development \
ASPNETCORE_URLS=http://localhost:5132 \
TZ=Europe/Istanbul \
Serilog__WriteTo__0__Args__serverUrl=http://localhost:9085 \
FeatureFlags__Redis__ConnectionUrl=localhost:6379 \
Framework__Application__CommonApi=http://192.168.10.191:30825/api \
Framework__Application__SkipAuthorization=true \
CommonApi=http://192.168.10.191:30825/api \
CommonBatchApi=http://192.168.10.191:30825 \
MMApi=http://localhost:5141/api \
MMBatchApi=http://localhost:5043 \
AccountingApi=http://192.168.10.191:30825/api \
FXApi=http://192.168.10.191:31598/api \
dotnet run --no-launch-profile --no-build
```

**Ekran adresi:** `http://localhost:5132/TreasuryRediscount/Index`

### 1.4 Ortam engelleri (kod hatası DEĞİL)

| # | Engel | Belirti | Çözüm |
|---|---|---|---|
| **G-1** | Açılışta `CommonApi` zorunlu | `Hosting failed to start` · `No connection ... (localhost:5050)` | Cluster Common: `http://192.168.10.191:30825/api` |
| **G-2** | Web.UI CLI config okumuyor | Override'a rağmen hâlâ `localhost:5050`'ye gidiyor | `--no-launch-profile` + env |
| **G-3** | Port çakışması | `address already in use` (5041/5032) | 5141 / 5132 |
| **G-4** | 🔴 **Kimlik doğrulama atlanamıyor** | `/TreasuryRediscount/Index` → **Login sayfası** (HTTP 200, `<title>Treasy</title>`) | **Tarayıcıda giriş yapılacak.** `SkipAuthorization` yalnız **yetkiyi** atlıyor |
| **G-5** | `State cache failed to populate state from redis` → `ArgumentNullException (items)` | Açılış log'unda | **Mevcut framework sorunu**, bizim kodla ilgisiz, açılışı engellemiyor |

---

## 2. Test verisi

**DB:** `NetTrexMM_Dev` · Server `192.168.10.211` (bağlantı: `NetTrex.MM/Code/docker-compose.override.yml`)

> ⚠️ `launchSettings.json` `NetTrexMM_Dev`'i gösteriyor; M-08 analizi ise `NetTrexMM`'de yapılmıştı.
> **İkisini karıştırma.**

| Ölçüm | Değer |
|---|---|
| `AccEntryMain` `Type=2` (Revaluation) kayıt sayısı | **81** |
| En yeni reeskont tarihleri | `2025-10-29`(1) · `2025-10-28`(2) · **`2025-10-27`(14)** · `2025-10-26`(8) · `2025-10-25`(5) · `2025-10-24`(10) |
| **Test için seçilen tarih** | **`2025-10-27`** |

### Bu tarihte ekranın döndürdüğü kayıt

| Alan | Değer |
|---|---|
| `TransactionId` | **552549968** |
| `LogicalReference` | **TMMBRW2505220009** |
| `SubProduct` | `MONEYMARKET` |
| `CustomerName` | Akbank A.Ş. |
| `Status` | **1 = NotRediscounted** (bu tarihte fişi yok) |
| `PrincipalAmount` / `InterestRate` | `1000.00` / `20.0000000000` |
| `StartDate` / `MaturityDate` | `2025-04-16` / `2025-12-14` |

> ISSUE filtresi eklenmeden **önce** 4 kayıt dönüyordu; hepsi tahvil (`TISBRW...`) idi (bkz. § 5 Bug 2).

---

## 3. Faz 1 — çalıştırılan testler (HEPSİ GEÇTİ ✅)

**Uç:** `POST http://localhost:5141/api/manual-rediscount/eligible-transactions`

### 3.1 Temel sorgu + sayfalama

```bash
curl -s -X POST http://localhost:5141/api/manual-rediscount/eligible-transactions \
  -H "Content-Type: application/json" \
  -d '{"ProductGroup":"Treasury","ModuleCode":"MM","Product":"MMLoanTransactions",
       "ExecutionDate":"2025-10-27","IsFirstLoad":false,"Skip":0,"Take":3,"CurrentUserId":"TEST"}'
```

| Kontrol | Beklenen | Sonuç |
|---|---|---|
| HTTP | 200 | ✅ |
| `isSuccess` | `true` | ✅ |
| `Take=3` iken item sayısı | ≤ 3, `totalCount` **filtrenin tamamı** | ✅ (3 item / totalCount 4 — ISSUE fix'i öncesi) |
| `Data` sözlüğü | 12 anahtar dolu | ✅ |
| Para formatı | 2 ondalık (`880000.00`, `-40952.92`) | ✅ |
| **`MessageKey`** | Yanıtta **OLMAMALI** | ✅ yok |

### 3.2 Durum türetme (M-08) — üç durum da gerçek veride görüldü

| Durum | Değer | Görüldü |
|---|---|---|
| NotRediscounted | 1 | ✅ `TMMBRW2505220009` |
| NotReversed | 3 | ✅ `TISBRW2510270020` (ISSUE fix'i öncesi) |
| Rediscounted | 4 | ✅ `TISBRW2510270001` (ISSUE fix'i öncesi) |

### 3.3 Filtreler ve guard'lar

| Senaryo | İstek farkı | Beklenen | Sonuç |
|---|---|---|---|
| Status = NotRediscounted | `"Status":1` | 1 kayıt | ✅ |
| Status = Rediscounted | `"Status":4` | 0 kayıt | ✅ |
| SubProduct = Murabaha | `"SubProduct":"Murabaha"` | 0 (kayıt MONEYMARKET) | ✅ |
| Status = All | `Status` gönderme | tüm kayıtlar | ✅ |
| **`IsFirstLoad` guard** | `"IsFirstLoad":true` | boş liste + `isSuccess:true`, **modüle gitmez** | ✅ |
| **Modül guard** | `"ModuleCode":"FX"` | `isSuccess:false` + `MODULE_MISMATCH` | ✅ |

---

## 4. Faz 2 — durum

**Uç:** `POST http://localhost:5141/api/manual-rediscount/executions`

### 4.1 Çalıştırılanlar — YAZMA YAPMAYAN yollar (HEPSİ GEÇTİ ✅)

| # | Senaryo | Beklenen mesaj | Sonuç |
|---|---|---|---|
| 1 | `"Items":[]` | "En az bir işlem seçilmelidir." | ✅ |
| 2 | `"Operation":9` | "Operation yalnızca Generate (1) veya Regenerate (2) olabilir." | ✅ |
| 3 | `"ExecutionDate":"2030-01-01"` | "ExecutionDate gelecek tarih olamaz." | ✅ |
| 4 | `ReverseValueDate == ExecutionDate` | "ReverseValueDate, ExecutionDate'ten sonra olmalıdır." | ✅ |
| 5 | `"ModuleCode":"FX"` | `MODULE_MISMATCH` — döngüye **hiç girmiyor** | ✅ |

### 4.2 🔴 ÇALIŞTIRILMAYAN — gerçek fiş kesme (ONAY BEKLİYOR)

**Neden yapılmadı:** `executions` **gerçek muhasebe fişi üretir ve Fimple'a gider**.
Geri alınamaz, dış sisteme yazar → kullanıcı onayı olmadan tetiklenmedi.

**Onay verildiğinde çalıştırılacak istek:**

```bash
curl -s -X POST http://localhost:5141/api/manual-rediscount/executions \
  -H "Content-Type: application/json" \
  -d '{"ProductGroup":"Treasury","ModuleCode":"MM","Product":"MMLoanTransactions",
       "Operation":1,
       "ExecutionDate":"2025-10-27",
       "ReverseValueDate":"2025-10-28",
       "Items":[{"TransactionId":552549968,"LogicalReference":"TMMBRW2505220009","CurrentStatus":1}],
       "CurrentUserId":"SELIM.TEST"}'
```

**Beklenen:** `Succeeded[0].NewStatus == 3` (NotReversed) · `Failed` boş · `isSuccess: true`

### 4.3 Gerçek test sonrası DOĞRULAMA SQL'leri

> `mssql-read` skill kuralı: **her sorgu** `sql-log/`'a yazılır · yalnız `SELECT` · `TOP (20)` · `ORDER BY Id DESC`.

**(a) T+0 fişi oluştu mu:**

```sql
SET NOCOUNT ON;
SELECT TOP (20) Id, TxnId, ValueDate, IsReverse, ReverseId, MessageKey, StateMaker, Type
FROM dbo.AccEntryMain
WHERE TxnId = 552549968 AND Type = 2
ORDER BY Id DESC;
```

| Kontrol | Beklenen |
|---|---|
| Yeni satır | `IsReverse = 0` · `ValueDate = 2025-10-27` · `ReverseId = 0` |
| `MessageKey` | **0 olmamalı** (Fimple'a gitti demek) |
| `StateMaker` | **`SELIM.TEST`** (istekteki `CurrentUserId`) |

**(b) 🔑 `T-01` fix'inin kanıtı — ters fiş sonrası:**

Generate'i **ikinci kez** çalıştır (`CurrentStatus: 3`) → ters fiş kesilir. Sonra:

```sql
SET NOCOUNT ON;
SELECT TOP (20) Id, TxnId, ValueDate, IsReverse, ReverseId, StateMaker
FROM dbo.AccEntryMain
WHERE TxnId = 552549968 AND Type = 2
ORDER BY Id DESC;
```

| Kontrol | Beklenen | Neden önemli |
|---|---|---|
| Ters satır | `IsReverse = 1` · `ValueDate = 2025-10-28` | `ReverseValueDate` Fimple'a doğru gitti |
| Çift yönlü bağ | T+0'ın `ReverseId` = ters satırın `Id` **ve** tersi | M-08 zinciri |
| 🔴 **Ters satırın `StateMaker`'ı** | **`SELIM.TEST`** — **`SYSTEM` DEĞİL** | **`T-01` fix'inin canlı kanıtı.** Testten önce ters fişler hep `SYSTEM` idi |

**(c) Aynı satıra ikinci Generate (C-05):**

```json
{"Operation":1,"Items":[{"TransactionId":552549968,"CurrentStatus":4}], ...}
```

Beklenen: `Failed[0].ReasonCode == "ALREADY_REDISCOUNTED"` · `isSuccess: false`

**(d) Durum uyuşmazlığı (§4.5 yarış koşulu):**

Gerçek durum `3` iken `CurrentStatus: 1` gönder →
`Failed[0].ReasonCode == "STATUS_CHANGED"` · hiçbir fiş kesilmemeli.

---

## 5. Bulunan bug'lar (ikisi de DÜZELTİLDİ)

### 🐞 Bug 1 — Flow pipeline hatası (HTTP 500)

```text
System.InvalidOperationException: The request '...EligibleTransactionsRequest'
should have a flow property
   at Netix.Core.Handler.PipelineBehaviors.FlowPipelineBehavior`2.Handle(...)
```

**Kök neden:** `BaseMmRequest<T>` → `BaseFlowRequest<T>` **state-machine akışı** içindir.
**Çözüm:** `IQueryFilterRequest` marker'ı (repo'nun kendi escape hatch'i — `TransactionSelectRequest`,
`TawarruqSelectRequest`, `IssueBondSelectRequest`, `InterbankLoanSelectRequest` hepsi kullanıyor).
Arayüz `int StateFilter` zorunlu kılıyor → eklendi, **"sözleşme dışı, bu uçta kullanılmıyor"** diye işaretlendi.

**Etkilenen dosyalar:** `EligibleTransactionsRequest.cs`, `ExecutionsRequest.cs`

### 🐞 Bug 2 — IssueBond işlemleri MM ekranında görünüyordu

**Belirti:** 4 kaydın hepsi `subProduct: "ISSUE"`, referanslar `TISBRW2510270020` gibi — **tahvil ihraç**.

**Kök neden:** Uygunluk filtresi EOD sorgusundan (`GetPendingRevaluationTransactions`) alınmıştı ama
MM ekranlarının **ISSUE dışlama** kuralı alınmamıştı.

**Çözüm** (`TransactionDataManager.GetRediscountEligibleTransactionsAsync`):

```csharp
query = query.Where(x => x.TxnMmProductTypeId != (int)ProductAccountingCodeType.ISSUE);
```

**Doğrulama:** Fix sonrası `TMMBRW2505220009` / `MONEYMARKET` geldi ✅

---

## 6. Web.UI — kimliksiz doğrulananlar

| Test | Sonuç |
|---|---|
| Uygulama ayağa kalkıyor (5132) | ✅ |
| 6 JS + kolon config JSON + CSS + localization JSON (**9 varlık**) | **hepsi HTTP 200** ✅ |
| `node --check` (6 JS) | **6/6 OK** ✅ |
| **`const` çakışması** — tüm `wwwroot/js/shared` ile karşılaştırıldı | **ÇAKIŞMA YOK** ✅ (`MR_` prefix'i tuttu) |
| Ekran render'ı | ⬜ **login gerekiyor** (G-4) |

**Statik varlık kontrol komutu:**

```bash
for f in js/shared/components/manual-rediscount/manuel-reeskont.{component,constants,actions,columns,context,endpoints}.js \
         js/config/manual-rediscount/treasury.json \
         css/shared/components/manual-rediscount.css \
         js/localization/pages/manual-rediscount/manuel-reeskont-tr.json; do
  echo "$(curl -s -o /dev/null -w '%{http_code}' http://localhost:5132/$f)  $f"
done
```

---

## 7. 🖥️ TARAYICI TEST KONTROL LİSTESİ (tüm fazlar bitince)

> Ekran: `http://localhost:5132/TreasuryRediscount/Index` — **önce giriş yap**.

### 7.1 Ekran açılışı

> 🔵 **2026-08-13 güncellemesi:** doküman uyumluluk turundan sonra ekran **değişti** —
> Status filtresi **pill**, grid üstünde **özet şeridi**, `Revaluation Type` filtresi,
> yeni kolon seti/sırası, yeni rozet renkleri, `Select All / N` menüsü, yenilenmiş onay pencereleri.
> Aşağıdaki maddeler **güncel hale** göre yazıldı (progress-12).

- [ ] Sayfa açılıyor, hata yok (F12 → Console **temiz**)
- [ ] Filtreler görünüyor: **Tarih · Ürün · Alt Ürün · Revaluation Type · Ters Fiş Valörü**
- [ ] Ürün varsayılan **MM/Loan Transactions**
- [ ] Alt Ürün listesi kolon config'inden geliyor: **Murabaha · Wakala** — 🔴 **"Tümü" seçeneği YOK**
      (§5.3 zorunlu) ve **ilk değer otomatik seçili**
- [ ] `Revaluation Type` **çoklu seçim** (TagBox); Treasury config'inde tek değer var (`Interest Accrual`).
      Config'de `revaluationTypes` **olmayan** bir ürün seçilirse alan **gizleniyor**
- [ ] Durum filtresi **pill buton grubu**: `All` (koyu dolgu, seçili) · `Not Rediscounted` (kırmızı çerçeve)
      · `Not Reversed` (sarı) · `Rediscounted` (yeşil) — 🔴 **`Processing`/`Error` pill'i YOK**
- [ ] Ters Fiş Valörü varsayılan = **Tarih + 1 gün**
- [ ] Toolbar'da **Generate** ve **Regenerate** butonları var, ikisi de **PASİF** (seçim yok)
- [ ] Sol tarafta **seçim menüsü** (caret) var: `Select All · 100 · 50 · 25 · Custom…`

### 7.2 Grid ve veri

- [ ] Tarihi **2025-10-27** yap → grid dolu
- [ ] 🔴 **Kolon sırası tam olarak:** `[☑] → Product → Logical Reference → External Customer Id →
      External Customer Name → Status → Status Description →` ürüne özel
- [ ] `Product` dolu (boşsa alt ürün kodu yazıyor) · `External Customer Id` **sola** yaslı
- [ ] `Status Description` dolu ve durumla uyumlu:
      NotRediscounted → *"Reeskont işlemi oluşturulmayı bekliyor."* ·
      NotReversed → *"Ters fiş işlemi oluşturulmayı bekliyor."* ·
      Rediscounted → *"Reeskont ve ilgili ters fiş işlemleri başarıyla tamamlandı."*
- [ ] **`CustomerName` kolonu YOK**; `Valör` artık **ürüne özel** kolonlar arasında (ilk sırada)
- [ ] Ürüne özel kolonlar config `order`'ına göre sıralı (Valör → İşlem Tipi → Yön → Döviz → …)
- [ ] 🔴 **Rozet renkleri (doküman § 7.1):** NotRediscounted **turuncu** (`#FDEBE0`/`#C0521F`) ·
      NotReversed **SARI** (`#FCF3CF`/`#8A6D0B`) · Rediscounted **yeşil** (`#E7F4E4`/`#2E6B27`).
      ⚠️ Mor rozet görürsen eski CSS/JS önbellekte kalmış — hard refresh
- [ ] Para kolonları **2 ondalık**, sağa hizalı; oran kolonları 7 ondalık
- [ ] **`MessageKey` kolonu YOK** (kasıtlı)
- [ ] Sayfalama çalışıyor, `totalCount` doğru; sayfa boyutu değiştirilebiliyor (25/50/100)
- [ ] Filtre değişince grid yenileniyor **ve seçim temizleniyor**

### 7.2.1 Durum bazlı özet şeridi (§5.3) — YENİ

- [ ] Grid üstünde şerit var: `Toplam N kayıt · X Not Rediscounted · Y Not Reversed · Z Rediscounted`
- [ ] Sayılar **sayfa değil, filtrenin tamamı** için (2. sayfaya geçince değişmiyor)
- [ ] `X + Y + Z == Toplam` ise **"Processing / Error" kalemi basılmıyor** (MM'de normal durum)
- [ ] Satır seçince şerit **seçim özetine** dönüşüyor: `Seçili 3 kayıt` (+ birden çok
      Revaluation Type varsa `— Revaluation Type: … (karışık)`)
- [ ] Seçim kaldırılınca **durum özeti geri geliyor**
- [ ] Sağda `"N of M selected"` bilgisi güncelleniyor

### 7.2.2 Toplu seçim menüsü (§5.4) — YENİ

- [ ] `25` → ilk 25 satır seçili · `50` → 50 · `100` → 100
- [ ] `Select All` → **yüklü** satırların tamamı seçili; daha fazla kayıt varsa **bilgi mesajı** çıkıyor
      (*"Seçim yüklenmiş satırları kapsar…"*)
- [ ] `Custom…` → adet soruyor; yüklüden fazlası istenirse **uyarı** verip yüklü olanları seçiyor
- [ ] Yarı seçili durumda başlık checkbox'ı **indeterminate** görünüyor (⚠️ doğrulanmadı, bak)

### 7.3 Filtreler

- [ ] Pill `Not Rediscounted` → yalnız turuncu rozetliler · `Rediscounted` → yalnız yeşiller
- [ ] Aynı pill'e ikinci kez basmak **yeni sorgu tetiklemiyor**
- [ ] Alt Ürün = **Murabaha** → yalnız Murabaha
- [ ] `Revaluation Type` = `Interest Accrual` → satırlar geliyor; listede olmayan bir tip seçilirse
      grid **boşalıyor** (MM'de değerleme tipi global parametreden gelir, tüm satırlar aynı)
- [ ] Ürün **veya Alt Ürün** seçilmeden grid **sorgulanmıyor** (`IsFirstLoad`)

### 7.4 Aksiyonlar (⚠️ **gerçek fiş keser**)

- [ ] Satır seç → butonlar **aktifleşiyor**
- [ ] Seçim kaldır → butonlar **pasifleşiyor**
- [ ] **Generate onay penceresi (image5):** başlık `Generate — Onay` · madde listesi
      **Reeskont** → *"Not Rediscounted kayıtlar için oluşturulur (T+0: …)"* ve
      **Ters fiş** → *"Not Reversed kayıtlar için oluşturulur (T+1: …)"* · altta seçili kayıt sayısı
- [ ] **Regenerate onay penceresi (image6):** başlık `Regenerate — Onay` · **durum bazlı kırılım**,
      her satırda `N kayıt` + rozet + kural metni:
      NotRediscounted → *"Önceki değerleme bulunmadığından yeni değerleme oluşturulur."* ·
      NotReversed/Rediscounted → *"Önceki değerleme geri alınır, yeni değerleme oluşturulur."*
- [ ] Regenerate onayında **0 kayıtlı durum satırı BASILMIYOR** (yalnız seçimde var olan durumlar)
- [ ] Onayı iptal et → **hiçbir şey olmuyor**
- [ ] Onayla → başarı toast'ı + **grid yenileniyor** + durum ilerliyor
- [ ] İşlem sırasında butonlar **kilitli**
- [ ] Zaten `Rediscounted` bir satıra Generate → **hata listesi** açılıyor, sebep: "Zaten reeskont edilmiş"
- [ ] 🔴 **`Regenerate` + `Not Rediscounted` satır → HATA DEĞİL**, yeni değerleme oluşuyor
      (2026-08-13 davranış düzeltmesi — eskiden `NOT_REDISCOUNTED` ile fail ediyordu)
- [ ] **Kısmi başarı**: bir satır başarılı + bir satır hatalı → **ikisi de gösteriliyor**, "başarılı" yalanı yok
- [ ] **Karışık Revaluation Type** (birden çok tip seçili): `Generate` **pasif**, `Regenerate` aktif ve
      toolbar altında **kalıcı ipucu** görünüyor: *"Seçim birden çok Revaluation Type içerdiğinden
      Generate pasiftir"* (image3). ⚠️ MM'de tip global parametreden geldiği için bu senaryo
      **MM'de üretilemez** — Fx/FI uçları bağlanınca test edilebilir

### 7.5 Dil

- [ ] TR'de tüm başlıklar/rozetler **Türkçe** (`Reeskont Edilmedi`, `Tersi Alınmadı`, …)
- [ ] EN'e geçince İngilizce
- [ ] Hata sebepleri localize (`mr-reason-*`)

### 7.6 Konsol / ağ

- [ ] `Load` isteği **`/TreasuryRediscount/Load`**'a gidiyor (modül adresine **değil**)
- [ ] Yanıt şekli **tek tip**: `{data, totalCount, isSuccess, message}`
- [ ] MM API kapalıyken → grid **sessizce boşalmıyor**, hata mesajı görünüyor
- [ ] `const` çakışması yok (sayfa `SyntaxError` vermiyor)

---

## 8. Test edilemeyenler / bilinen eksikler

| # | Ne | Neden |
|---|---|---|
| 1 | Gerçek fiş kesme | Onay bekliyor (§4.2) |
| 2 | Ekran render'ı | Login gerekiyor (G-4) |
| 3 | Doküman §4.6 "aynı Revaluation Type" kuralı | **Sözleşmede alan yok** — uygulanmadı (progress-7 açık kalemi) |
| 4 | Çok pod'lu çift-tıklama | Guard **process-içi**; gerçek çözüm Fimple idempotency (`Ö-08`) |
| 5 | Fx / FI / InvFund uçları | Faz 3 |
| 6 | Security / Investment ekranları | Faz 3 |

---

## 9. İlgili dosyalar

| Ne | Yol |
|---|---|
| Sözleşme (dondurulmuş) | [`06-sozlesme.md`](06-sozlesme.md) |
| Faz planı / iş kalemleri | [`05-faz-plani.md`](05-faz-plani.md) |
| Fimple sözleşmesi + öneriler | [`07-fimple-entegrasyon.md`](07-fimple-entegrasyon.md) |
| Test turunun kaydı | [`progress/progress-8.md`](progress/progress-8.md) |
| **Çalıştırılan SQL'lerin tamamı** | [`../sql-log/manuel-reeskont-analiz/`](../sql-log/manuel-reeskont-analiz/01-sorgular.md) |

---

## 10. 🔴 2026-08-18 turu — YENİ test maddeleri (doküman hizalama + 2 sessiz bug)

> ⚠️ **ÖN KOŞUL:** MM API **yeniden başlatılmış** olmalı. Data manager fix'i (`B-1`) DLL kilidi
> yüzünden çalışan sürece yüklenemedi (`NetTrex.MM.Api` PID kilidi). Restart olmadan `T-01…T-04`
> testleri **eski davranışı** gösterir.

### 10.1 Ters fiş valörü popup'ı (doküman § 8.2 + image4)

| # | Adım | Beklenen |
|---|---|---|
| **T-01** | `Date` = **05.08.2026**, Product `MM Transactions`, Sub Product `Money Market` | Grid'de **`TMMBRW2607140004`** satırı **`Not Reversed`** durumunda görünür. 🔴 Restart öncesi bu satır **hiç görünmüyordu** (özet "1 Not Reversed" derken grid boştu) |
| **T-02** | O satırı seç → **Generate** | **"Select Reverse Entry Value Date"** popup'ı açılır: `T+1 — standard (next business day)` **seçili**, `T+0 — same day (execution date)` seçenek, `Onayla`/`Vazgeç` |
| **T-03** | `Vazgeç` | **Hiçbir şey yapılmaz** (§ 4.4) — fiş kesilmez, onay penceresi de açılmaz |
| **T-04** | Yalnız **`Not Rediscounted`** satır seç → Generate | 🔴 Popup **AÇILMAZ** (§ 8.2 *"Diğer durumlarda seçim sorulmaz"*) — doğrudan onay penceresine geçer |
| **T-05** | **Regenerate** (hangi durum olursa) | 🔴 Popup **AÇILMAZ** — § 4.3/§ 4.6 ters fişi **T+1**'e sabitliyor |
| **T-06** | Filtre çubuğuna bak | 🔴 **`Reverse Value Date` alanı YOK** — valör bir filtre değil, Execute anında sorulan bir soru |

### 10.2 🔴 İŞ GÜNÜ testi — bu turun en kritik maddesi

| # | Adım | Beklenen |
|---|---|---|
| **T-07** | `ExecutionDate` = bir **CUMA**, `Not Reversed` satır, Generate → **T+1** | Ters fişin valörü **PAZARTESİ** olmalı. 🔴 **Cumartesi ÇIKARSA fix çalışmıyor** demektir |
| **T-08** | `AccEntryMain`'den doğrula | `SELECT ... WHERE IsReverse = 1 ORDER BY Id DESC` → `DATENAME(WEEKDAY, ValueDate)` **hafta içi** olmalı |
| **T-09** | T+0 seçerek kes | Ters fişin `ValueDate`'i **`ExecutionDate` ile aynı** (`DayDiff = 0`). Eskiden validator bunu **reddediyordu** |

> 🔑 Neden kritik: canlı veride **1983 ters fişin 853'ü (%43) hafta sonu valörlü** (sql-log #22).
> Bunlar **batch** kaynaklı ve batch **düzeltilmedi**; manuel ekran artık takvim kullanıyor.
> Bu test ikisinin ayrıştığını doğrular.

### 10.3 İşlem sonucunun grid'e yazılması (§ 3.4 · § 5.2 · § 8.4 + image7)

| # | Adım | Beklenen |
|---|---|---|
| **T-10** | Hata alacak bir satırla Generate (ör. `AccAccountMap` eksik olan) | 🔴 Satırın **Status**'ü **`Error`** (kırmızı rozet) olur ve **Status Description**'da sebep yazar. Restart öncesi satır eski durumunda kalıyordu |
| **T-11** | Grid'in üstüne bak | Şerit: `Generate — Execution result (live): 2 failed  The error state is not stored…` |
| **T-12** | Karışık sonuç (bazı satır geçer, bazısı patlar) | Geçenler **yeni durumu** + aksiyona uygun metin (`Rediscount entry created.` / `Reverse entry created.`), patlayanlar `Error` + sebep — **aynı ekranda** |
| **T-13** | Regenerate ile patlat | Metin **`Regenerate — …`** ile başlar (hangi işlem olduğu belli) |
| **T-14** | Filtreyi değiştir / pill'e bas | 🔴 Sonuç **silinir**, satır **DB durumuna** döner (§ 8.4). `Error` kalıcı **değil** |
| **T-15** | Excel export | Export'ta **DB durumu** görünür, `Error` **girmez** (§ 3.1: kalıcı değil) |

### 10.4 Loading ve çoklu seçim

| # | Adım | Beklenen |
|---|---|---|
| **T-16** | 3 satır seç → Generate | Toolbar altında `Processing 1/3…` → `2/3…` → `3/3…` ilerler; **loader tüm süre boyunca açık kalır** |
| **T-17** | 1. satır hata alsın | 🔴 Loader **kapanmaz**, döngü devam eder (kullanıcı bulgusu: eskiden loading kayboluyor, işlem arkada sürüyordu) |
| **T-18** | Ağ/timeout hatası (transport) | Kalan parçalar **denenmez**, o ana kadar birikmiş sonuç **gösterilir** |
| **T-19** | 20 satır seç | Timeout **olmamalı** — her istek 1 satır taşıyor (`MR_EXECUTE_CHUNK_SIZE = 1`) |

### 10.5 Onay pencereleri (image5 / image6)

| # | Adım | Beklenen |
|---|---|---|
| **T-20** | Generate onayı | Butonlar **`Onayla` / `Vazgeç`** (eskiden DevExtreme'in `Yes/No`'suydu) · madde madde liste · seçili kayıt sayısı |
| **T-21** | Regenerate onayı | image6 gibi **durum bazlı kırılım**: her durum için rozet + kayıt sayısı + ne olacağı · `Processing/Error` **"kapsam dışı bırakılır"** satırı ayrıca |
| **T-22** | Karışık **statü** seç (All filtresinde) | 🔴 Generate **pasifleşmez** — § 5.3 *"her kayıt üzerinde uygulanacak işlem, kaydın kendi durumuna göre belirlenir"*. Pasifleştirme kuralı **Revaluation Type** içindir, statü için değil |

### 10.6 Sayım tutarlılığı (B-1 regresyonu)

| # | Adım | Beklenen |
|---|---|---|
| **T-23** | Özet şeridindeki sayılarla grid satır sayısını **karşılaştır** | 🔴 **Eşit olmalı.** Özet "N" derken grid'de N'den az satır varsa → EF INNER JOIN tuzağı geri gelmiş (`MEMORY.md`'deki nota bak) |
| **T-24** | Müşterisi olmayan (orphan `CustomerId`) bir satır | Satır **görünür**, `External Customer Id`/`Name` hücreleri **boş** — satır gizlenmez |

### 10.7 Bu turda API ile ölçülenler (tarayıcı gerekmedi)

| Ne | Sonuç |
|---|---|
| `reverseValueType` deploy'da mı | ✅ MM swagger `ExecutionsRequest` şemasında **var** |
| Okuma ucu çalışıyor mu | ✅ `HTTP 200`, `05.08.2026` için 4 kayıt |
| Sayım/liste tutarlılığı | 🔴 `totalCount = 4` / `items = 3` · `Status=3` ile `1` / `0` → **B-1 bulundu** |
| Alt ürün taraması | `Money Market` dışındaki 7 alt üründe o tarihte kayıt **yok** |


---

## 11. 🔴 2026-08-19 turu — YENİ test maddeleri (kullanıcının 10 maddesi)

> ⚠️ **ÖN KOŞUL: hem MM API hem WebUI yeniden başlatılmalı.**
> `AccountingDataManager`'ın **constructor'ı** değişti (2 yeni repository) ve WebUI `Startup.cs`'e
> Refit timeout kaydı eklendi. Restart olmadan DI hatası veya eski davranış görürsün.

### 11.1 `Selection` menüsü kaldırıldı

| # | Adım | Beklenen |
|---|---|---|
| **T-25** | Grid'in **sol üstüne** bak | 🔴 `Selection ▾` menüsü ve `"100 of 248 selected"` yazısı **YOK** |
| **T-26** | Grid başlığındaki checkbox | ✅ **DURUYOR** — görünen sayfanın satırlarını seçer (image3) |
| **T-27** | Grid'in **altına** bak | Pager duruyor: sayfa numaraları + `25 / 50 / 100` sayfa boyutu seçici |
| **T-28** | Satır seç | Özet şeridi *"Seçili N kayıt — Revaluation Type: …"* olur (image3) — bu **kaldırılmadı** |

### 11.2 🔴 Generate karışık statüde pasif (`D-10`)

| # | Adım | Beklenen |
|---|---|---|
| **T-29** | `Status` = **All** · aynı statüden 4 satır seç | **Generate AKTİF**, ipucu satırı **yok** |
| **T-30** | 5. satır olarak **farklı statülü** bir satır seç | 🔴 **Generate anında PASİF** olur + toolbar altında iki satır: gri *"seçim birden çok Status içerdiğinden,"* + kalın turuncu **"Generate pasiftir"** |
| **T-31** | Aynı seçimde **Regenerate** | 🔴 **AKTİF kalır** — kısıt yalnız Generate'e uygulanır |
| **T-32** | Farklı statülü satırın seçimini kaldır | Generate **geri aktif** olur, ipucu kaybolur |
| **T-33** | Karışık **Revaluation Type** (MM'de pratikte tetiklenmez) | Aynı davranış; iki sebep birlikteyse ipucu *"… ve …"* ile ikisini de yazar |

### 11.3 🔴 TEK istek (parçalama kalktı)

| # | Adım | Beklenen |
|---|---|---|
| **T-34** | Tarayıcı **Network** sekmesini aç → 5 satır seç → Generate | 🔴 **TEK** `POST .../Execute` isteği görünür (eskiden **5 ayrı** istek vardı) |
| **T-35** | İstek gövdesi (`Payload`) | `Items` dizisinde **5 eleman** |
| **T-36** | Toolbar altındaki metin | `Processing 5 records…` (🔴 `3/5` **değil** — tek istek, parça sayacı yok) |
| **T-37** | 51 satır seçmeye çalış (sayfa boyutunu 100 yap) | 🔴 İstek **hiç gitmez**; *"En fazla 50 kayıt"* uyarısı çıkar |
| **T-38** | 10+ satırla uzun bir koşu yap (toplam süre 100 sn'yi geçsin) | 🔴 **timeout OLMAMALI**. Ayar: `ManualRediscountRefitRegistration.RegisterManualRediscountMmApiTimeout` → 10 dk, **yalnız** `IManualRediscountMmApi`'ye. *"The request was canceled due to the configured HttpClient.Timeout of 100 seconds"* görürsen **WebUI restart edilmemiş** |
| **T-38b** | 🔴 **Regresyon: diğer ekranlar etkilenmedi mi?** MM Transaction listesi · FX Transaction · EOD · Daily Flow V2 — birini açıp normal bir kayıt/listeleme yap | Hepsi **eskisi gibi** çalışır. `RefitExtensions.cs` bit-bit orijinal olduğu için bu **yapısal olarak** değişemez; kontrol yine de kullanıcının "yan etki görmek istemiyorum" şartının kanıtı |

### 11.4 🔴 `Processing` geçici durumu (yeni)

| # | Adım | Beklenen |
|---|---|---|
| **T-39** | 3 satır seç → Generate → onayla → **ekrana bak** | 🔴 Satırlar **anında `Processing`** (mavi rozet) + `Status Description`'da *"Core banking sistemine iletildi, sonuç bekleniyor."* ⚠️ Loader shading yüzünden **soluk** görünür, normal |
| **T-40** | Yanıt gelince | `Processing` **kaybolur**, yerine yeni durum (yeşil/sarı) veya kırmızı **`Error`** gelir |
| **T-41** | `Status` filtresine bak | 🔴 `Processing` **filtre olarak YOK** (§ 3.4 / `C-12`) — yalnız rozet olarak görünür |
| **T-42** | Sayfayı yenile / filtre değiştir | `Processing` ve `Error` **silinir**, satır **DB durumunda** görünür (§ 8.4) |

### 11.5 🔴 Tekrar Execute — bayat durum göndermiyor (`B-4` regresyonu)

| # | Adım | Beklenen |
|---|---|---|
| **T-43** | `Not Rediscounted` bir satır seç → Generate (**başarılı** olsun) | Satır `Not Reversed` görünür. **`refresh()` yapma** |
| **T-44** | 🔴 **AYNI** satırı tekrar seç → Generate | Valör popup'ı **açılır** (satır artık `Not Reversed`) ve işlem **çalışır**. 🔴 *"The record changed after it was listed"* (`STATUS_CHANGED`) hatası **GELMEMELİ** — gelirse `dbStatus` mekanizması çalışmıyor |
| **T-45** | Network → 2. isteğin gövdesi | `Items[0].CurrentStatus` = **3** (`Not Reversed`), **1 değil** |
| **T-46** | Hata almış bir satırı tekrar dene | Gövdede `CurrentStatus` satırın **DB durumu** olur — 🔴 **`0` (`Error`) veya `2` (`Processing`) ASLA gönderilmez** |
| **T-47** | Başarılı satır + hata almış satırı birlikte seç → Generate | Statüleri **farklı** olduğu için Generate **pasifleşir** (`D-10`) — ipucu bunu söyler |

### 11.6 Dialog tasarımı (image4 / image5 / image6)

| # | Adım | Beklenen |
|---|---|---|
| **T-48** | Herhangi bir onay penceresi aç | 🔴 Üstte **LACİVERT başlık şeridi**, içinde **beyaz kalın** başlık (image5/image6) |
| **T-49** | Butonlara bak | **`Onayla`** dolu lacivert · **`Vazgeç`** çerçevesiz gri metin — sırası `Onayla` sonra `Vazgeç` |
| **T-50** | Valör popup'ı (image4) | Başlık **"Ters Fiş Valörü Seç"** · iki radyo · **T+1 seçili** · seçili seçenek **mavi çerçeve + açık mavi zemin** · `Kes` / `Vazgeç` |
| **T-51** | Popup'ta `T+0` seç → `Kes` | Onay penceresinde ters fiş valörü **"T+0 — aynı gün"** yazar |
| **T-52** | Pencerenin dışına tıkla | 🔴 **KAPANMAZ** (muhasebe fişi onayı — yanlışlıkla iptal riski) |
| **T-53** | `×` veya `ESC` | Kapanır ve **Vazgeç ile aynı** sonucu verir (hiçbir şey yapılmaz) |
| **T-54** | Generate onayı gövdesi | Reeskont maddesinde **`(T+0 — tarih)`**, ters fiş maddesinde **`T+1 …`** (image5) |
| **T-55** | Regenerate onayı | image6 gibi **durum bazlı kırılım**: her durum için `N kayıt` + rozet + ne olacağı; `Processing/Error` satırı **"kapsam dışında bırakılır"** |

### 11.7 Buton renkleri (image3)

| # | Adım | Beklenen |
|---|---|---|
| **T-56** | Satır seç, iki butona bak | 🔴 **Generate LACİVERT**, **Regenerate TURUNCU** — ikisi de **dolu** zeminli, artık **aynı renk değil** |
| **T-57** | Generate'i pasifleştir (karışık statü) | Buton **gri-mavi** olur (image3'teki soluk Generate) |
| **T-58** | Butonların üzerine gel | Hover'da ikisi de **koyulaşır** |

### 11.8 MM ↔ InterbankLoan ayrımı (`B-3` regresyonu)

| # | Adım | Beklenen |
|---|---|---|
| **T-59** | `Product` = **MM Transactions** ile bir Generate yap, sonra `AccEntryMain`'i sorgula | Kesilen fişin `TxnId`'si **`TxnMM`**'de var; `ProductCode` o transaction'ın `MainProductCode`'u |
| **T-60** | `Product` = **InterbankLoan Transactions** ile aynısı | `TxnId` **`TxnLoan`**'da |
| **T-61** | 🔴 **Mükerrer fiş kontrolü:** aynı satıra aynı gün için **ikinci** kez Generate | *"already been rediscounted"* (`ALREADY_REDISCOUNTED`) döner. 🔴 **İkinci bir reeskont fişi kesilirse** `B-3` geri gelmiş demektir |

### 11.9 "Verilen güne göre" (Faz 1)

| # | Adım | Beklenen |
|---|---|---|
| **T-62** | `Date` = geçmiş bir gün seç → Generate | Fiş **yalnız o günün** valörüyle kesilir; bugüne kadarki günler **işlenmez** (`RegenerateToToday` **Faz 2**) |
| **T-63** | Aynısını Regenerate ile | Aynı — tek gün. Network gövdesinde `RegenerateToToday: false` |
| **T-64** | Regenerate sonrası satır | 🔴 **`Rediscounted`** olur (reeskont **ve** ters fiş kesildi — image1: *"returns to Rediscounted"*) |


---

## 12. 🔴 2026-08-20 turu — ekran düzeni + log gürültüsü

> ⚠️ **ÖN KOŞUL: MM API ve WebUI yeniden başlatılmalı** (`ExternalHttpLoggingDelegateHandler` ve
> `Startup.cs` değişti) + tarayıcıda **hard refresh** (`Ctrl+F5`) — CSS/JS `asp-append-version`
> ile sürümlü ama cache'i zorlamak güvenli.

### 12.1 Log gürültüsü

| # | Adım | Beklenen |
|---|---|---|
| **T-65** | Debugger bağlı, bir Generate yap → Output/Exception penceresine bak | 🔴 `JsonReaderException: 'c' is an invalid start of a value` **artık ATILMIYOR** |
| **T-66** | Log dosyasında token isteğinin gövdesine bak | Gövde eskisi gibi **ham** yazılmış (`client_id=…&…`) — çıktı **değişmedi**, yalnız exception kalktı |
| **T-67** | Fimple'ın JSON yanıtına bak | Hâlâ **girintili (pretty)** yazılıyor; `ExecutionTrace` alanı hâlâ çıkarılıyor |
| **T-68** | 🟥 **Güvenlik kontrolü:** log'da `client_secret` ara | Düz metin **görünecek** — bu bilinen ve **dokunulmayan** konu; maskeleme kullanıcı onayı bekliyor |

### 12.2 Buton hizası

| # | Adım | Beklenen |
|---|---|---|
| **T-69** | Ekranı aç, `Status` pill satırına bak | 🔴 **Generate ve Regenerate AYNI SATIRDA**, en sağda — pill'lerle **tam hizada** |
| **T-70** | Tarayıcı penceresini daralt | Butonlar **alt satıra düşmüyor** (`flex-wrap: nowrap`); daralınca pill'ler kendi içinde sarar |
| **T-71** | Grid'in üstünde boş bir satır kaldı mı | 🔴 Kalmadı — eski `.mr-toolbar-row` kabı **silindi** |

### 12.3 Kolon hizalama ve tipler

| # | Adım | Beklenen |
|---|---|---|
| **T-72** | `Status` kolonu **başlığına** bak | 🔴 **ORTALI** — eskiden sağa kaçmıştı (alan `int`, DevExtreme `number` sayıyordu) |
| **T-73** | `Product` · `Logical Reference` · `External Customer Id` · `Value Date` · `Txn Type` · `Direction` · `Currency` | Hepsi **ortalı** (başlık + hücre birlikte) |
| **T-74** | `Principal Amount` · `Interest Rate` · `Accrued Interest` · `Daily Accrual` | **SAĞA** yaslı, basamaklar alt alta hizalı |
| **T-75** | `External Customer Name` · `Status Description` | **SOLA** yaslı (serbest metin) |
| **T-76** | Uzun bir müşteri adı olan satır | Hücre **iki satıra bölünmüyor** (`wordWrapEnabled: false`); tam metin tooltip'te |
| **T-77** | Satırlara bak | **Bir atlayarak** hafif zemin farkı var (`rowAlternationEnabled`) |
| **T-78** | En sağa kaydır | Kolonlar ezilmiyor (`columnMinWidth: 70`); kolon başlığına sağ tık → **sabitleme** seçeneği var |

### 12.4 Durum rozeti

| # | Adım | Beklenen |
|---|---|---|
| **T-79** | `Status` hücrelerine bak | 🔴 Rozet **hücreyi kaplamıyor** — genişlik metne göre, hücrede **ortalı** |
| **T-80** | `Not Rediscounted` (en uzun metin) | Tek satırda, **kırpılmadan** (`white-space: nowrap`, `min-width: 112px`) |
| **T-81** | Onay penceresindeki kırılım rozetleri | Daha küçük ve **taban genişliği yok** (`.mr-badge-inline`) |

### 12.5 🔴 Revaluation Type tamamen kalktı (`D-11`)

| # | Adım | Beklenen |
|---|---|---|
| **T-82** | Filtre satırına bak | 🔴 `Revaluation Type` kutusu **YOK**; 3 filtre kaldı: `Date` · `Product` · `Sub Product` (form `ColCount(3)`) |
| **T-83** | Satır seç, özet şeridine bak | 🔴 `Revaluation Type: Atomic` **yazmıyor**. Yerine **durum kırılımı**: *"Seçili 5 kayıt — 4 Not Rediscounted · 1 Rediscounted (karışık)"* |
| **T-84** | Aynı statüden birkaç satır seç | Kırılım tek kalem, **`(karışık)` etiketi YOK**, Generate **aktif** |
| **T-85** | Farklı statülü bir satır ekle | Kırılım iki kalem + turuncu kalın **`(karışık)`** + Generate **pasif** + ipucu (`D-10`) |
| **T-86** | Network → `Load` isteğinin gövdesi | 🔴 `RevaluationTypes` **gönderilmiyor** |
| **T-87** | Generate'i karışık **statüyle** dene | Pasif — ipucunda **yalnız** *"birden çok Status"* sebebi yazar; *"Revaluation Type"* sebebi **hiç geçmez** |


---

## 13. 🔴 2026-08-20 (2. tur) — düzeltmeler

> ⚠️ **MM API + WebUI restart** (`RefitExtension` değişti) + tarayıcıda **`Ctrl+F5`**.

### 13.1 Fimple hata mesajı artık teşhis ediyor

| # | Adım | Beklenen |
|---|---|---|
| **T-88** | `Error` alan bir satırla Generate'i tekrar dene, `Status Description`'a ve log'a bak | 🔴 Mesaj artık *"Failed to parse the API response"* **değil** — `Fimple returned a non-JSON error response. HTTP <kod> (<durum>). Body: …` yazacak |
| **T-89** | Debugger: `Error parsing NaN value` | 🔴 **Atılmıyor** — JSON olmayan gövde parse'a hiç girmiyor |
| **T-90** | 🔵 **Asıl teşhis:** T-88'deki HTTP kodunu oku | `404` → Fimple ucu/adres yanlış veya deploy geri kalmış · `502/503` → gateway/servis ayakta değil · `401/403` → token. Sebep buradan ayrışır |
| **T-91** | Fimple'ın **normal** iş hatası (`Success: false` + `Reasons`) | Eskisi gibi `Fimple Error => Code: …, Message: …` — bu yol **değişmedi** |

### 13.2 Kolon başlıkları geri geldi

| # | Adım | Beklenen |
|---|---|---|
| **T-92** | Ekranı aç, grid başlığına bak | 🔴 **Kolon adları görünüyor**: `Product` · `Logical Reference` · `External Customer Id` · … (`columnFixing` kaldırıldı) |
| **T-93** | Satırlara bak | 🔴 **Zebra çizgi YOK** — hepsi aynı zemin (kullanıcı beğenmedi) |
| **T-94** | Kolon başlığına sağ tık | Sabitleme menüsü **yok** (`columnFixing` kapalı) — beklenen |
| **T-95** | Hizalamalar (§ 12.3, `T-72`…`T-75`) | **Korunmuş olmalı** — hizalama grid option değil, kolon tanımı |
| **T-96** | Rozet genişliği (`T-79`, `T-80`) | **Korunmuş olmalı** — CSS |

### 13.3 İpucu grid'i kaydırmıyor

| # | Adım | Beklenen |
|---|---|---|
| **T-97** | Aynı statüden 2 satır seç → grid'in üst kenarının ekran konumunu **not al** | — |
| **T-98** | Farklı statülü bir satır ekle (ipucu görünür) | 🔴 **Grid HİÇ KAYMIYOR**; ipucu özet şeridinin **sağ ucunda**, **tek satır** |
| **T-99** | Seçimi kaldır (ipucu kaybolur) | Grid yine kaymıyor |
| **T-100** | Pencereyi daralt | İpucu **kırpılır** (`…`), satır büyümez; üzerine gelince tam metin tooltip'te |

### 13.4 Regenerate ters fiş valörü (`D-12`)

| # | Adım | Beklenen |
|---|---|---|
| **T-101** | Herhangi bir satır seç → **Regenerate** | 🔴 **Valör popup'ı AÇILIR** — *"1 kayıt yeniden değerlenecek — yeni ters fiş hangi valörle kesilsin?"*, **T+1 seçili** |
| **T-102** | `T+0` seç → `Kes` | Onay penceresinde ters fiş valörü **T+0** yazar |
| **T-103** | Popup'ta `Vazgeç` | Hiçbir şey yapılmaz, onay penceresi **açılmaz** |
| **T-104** | Network → istek gövdesi | `ReverseValueType: 2` (T+0) veya `1` (T+1) |
| **T-105** | 🔴 Backend gerçekten uyguladı mı: `AccEntry`'de ters fişin valörü | T+0 seçildiyse **execution date**; T+1 seçildiyse **+1 iş günü** |
| **T-106** | **Generate** ile `Not Rediscounted` bir satır (ters fiş üretmez) | Popup **AÇILMAZ** — § 8.2 kapısı Generate'te değişmedi |
| **T-107** | **Generate** ile `Not Reversed` bir satır | Popup **açılır**, metin *"Not Reversed satır için…"* (Regenerate metninden farklı) |


---

## 14. 🔴 2026-08-20 (3. tur)

### 14.1 Etiket ve genişlikler

| # | Adım | Beklenen |
|---|---|---|
| **T-108** | Filtre satırındaki ilk etiket | 🔴 **`Execution Date`** (eskiden `Date` / `Tarih`) |
| **T-109** | Üç dropdown'ın genişliği | 🔴 Belirgin şekilde **daha dar** — her biri satırın ~1/4'ü, üstelik en fazla 320px |
| **T-110** | Çok geniş ekranda (2560px) | Alanlar **büyümüyor** (CSS tavanı) |
| **T-111** | Uzun hata metinli bir `Error` satırı | 🔴 `Status Description` kolonu **daha geniş** — sabit 320px yok, kalan alanı alıyor |
| **T-112** | Çok kolonlu görünümde aynı kolon | En az 260px kalıyor, tamamen ezilmiyor |

### 14.2 Ters fiş valörü — iki aksiyon (`D-12`)

| # | Adım | Beklenen |
|---|---|---|
| **T-113** | `Status` = `Not Reversed` · satır seç → **Generate** | 🔴 Popup **açılır** — *"N Not Reversed satır için…"* |
| **T-114** | `Status` = `Not Rediscounted` · satır seç → **Generate** | Popup **açılmaz** (bu adımda ters fiş kesilmiyor — § 4.1). ⚠️ Kullanıcı her koşulda istiyorsa bu davranış değişecek |
| **T-115** | Herhangi bir satır → **Regenerate** | 🔴 Popup **her zaman açılır** — *"N kayıt yeniden değerlenecek…"* |
| **T-116** | Regenerate'te `T+0` seç → onayla | `AccEntry`'de ters fişin valörü **execution date** |
| **T-117** | Regenerate'te `T+1` (varsayılan) | Ters fiş valörü **+1 iş günü** (Cuma → Pazartesi) |
| **T-118** | Karışık statülü seçim → Regenerate → onay penceresi | Durum bazında kırılım (görsel gibi); `T+0`/`T+1` seçimi **tüm** satırlara uygulanır |
| **T-119** | Regenerate sonrası satırlar | Hepsi **`Rediscounted`** |

### 14.3 Statü doğrulaması (kod değişmedi — regresyon kontrolü)

| # | Adım | Beklenen |
|---|---|---|
| **T-120** | `Execution Date` = 18.08.2026 | `TMMBRW2608180001` → **`Rediscounted`** |
| **T-121** | `Execution Date` = 20.08.2026 | Aynı satır **listede yok** — vade/faiz dönemi filtresi (statü hatası **değil**) |
| **T-122** | Bir satıra Generate → sonra `Execution Date`'i değiştir → geri dön | Durum **o tarihe göre** okunuyor: kesilen tarihte `Not Reversed`, diğer tarihte `Not Rediscounted` |
| **T-123** | Aynı transaction'a iki farklı tarihte reeskont kes | İki tarih **bağımsız** durum gösteriyor (`ValueDate == executionDate`) |

### 14.4 🔵 Fimple hatası teşhisi (Seq)

| # | Adım | Ne aranacak |
|---|---|---|
| **T-124** | Hata anının CorrelationId scope'unu Seq'te aç | `>>>>>>>>> {Method} {Url}` satırlarının **tamamı** — hangi uca gidiliyor, **tam URL** |
| **T-125** | `<<<<<<<<< {StatusCode}` satırı | **Durum kodu**: `404` → uç/adres · `502/503` → servis · `401/403` → **auth** |
| **T-126** | `ExternalApiException` mesajı | Artık `HTTP {kod} ({durum}). Body: …` taşıyor |
| **T-127** | 🔴 **Auth adayı:** aynı scope'ta Keycloak/`Login` çağrısı var mı | `FimpleAuthService.cs:37`/`:41` de aynı wrapper'ı kullanıyor — hata **oradan** geliyorsa muhasebe adımına hiç gelinmemiştir |
| **T-128** | EOD batch'in aynı işlem için ürettiği `>>>>>>>>>` satırları | İki URL **yan yana** → fark anında görünür |
| **T-129** | ⚠️ Paylaşmadan önce | Log'da `client_secret` **düz metin** — maskele (`outputs/2026-08-20-client-secret-log-maskeleme.md`) |


---

## 15. 🔴 2026-08-20 (4. tur) — dark mode, sonuç penceresi, Fimple 3058

### 15.1 Dark mode dialog

| # | Adım | Beklenen |
|---|---|---|
| **T-130** | 🔴 **Dark mode**'da valör popup'ını aç | Gövde **açık zeminli**, yazılar **koyu ve okunur** — normal mod ile **aynı** görünüyor |
| **T-131** | Seçili seçenek (`T+1`) | Açık mavi zemin + **koyu lacivert** yazı (`#14395F`) — beyaz-üstüne-mavi okunmazlığı **yok** |
| **T-132** | Radyo kutucukları | Açık zeminde **görünür** (`accent-color`) |
| **T-133** | Normal mode'da aynı popup | 🔴 **Bozulmamış** olmalı — değişiklik dark'a özel değil, ikisini de kapsıyor |
| **T-134** | Regenerate onay penceresi + sonuç penceresi (dark) | İkisi de okunur; ikincil metinler (kural açıklaması, hata sebebi) **gri ama okunur** |

### 15.2 T+0 / T+1 sırası ve varsayılan

| # | Adım | Beklenen |
|---|---|---|
| **T-135** | Valör popup'ı | 🔴 **`T+0` ÜSTTE**, `T+1` altta |
| **T-136** | Hiçbir şeye dokunmadan `Apply` | 🔴 **T+1** uygulanır (varsayılan değişmedi — § 4.2) · Network'te `ReverseValueType: 1` |
| **T-137** | `T+0` seç → `Apply` | `ReverseValueType: 2` |

### 15.3 Sonuç penceresi

| # | Adım | Beklenen |
|---|---|---|
| **T-138** | Karışık sonuç (1 başarılı + 1 hatalı) | 🔴 Başlıklar **sayı rozeti + tek kelime**: yeşil `1` `Succeeded` · kırmızı `1` `Failed`. *"1 rows processed"* **yazmıyor** |
| **T-139** | Her satırın yanı | 🔴 **Durum rozeti** var — başarılıda **yeni** durum, hatalıda **değişmemiş** (kalıcı) durum |
| **T-140** | Hata satırı | Referans + rozet **üst satırda**, uzun Fimple mesajı **alt satırda** (küçük, gri) |
| **T-141** | Regenerate ile karışık statülü seçim → hata al | 🔴 Hangi **durumdaki** satırın patladığı rozetten anlaşılıyor (`D-10` Regenerate'i kısıtlamıyor, bu yüzden gerekli) |

### 15.4 🔵 Fimple 3058 — konfigürasyon düzeltmesi sonrası

| # | Adım | Beklenen |
|---|---|---|
| **T-142** | `AccAccountMap` `23298` düzeltilmeden dene | `Code: 3058 … Defter hesabı: (36099200)` — **beklenen**, kod hatası değil |
| **T-143** | Düzeltme sonrası log'daki gövde | `{ "GLAccount": "36099200", "ReferenceType": null, "ReferenceNumber": null }` |
| **T-144** | Düzeltme sonrası sonuç | `Succeeded` + statü **`Not Reversed`** |
| **T-145** | 🔴 Aynı transaction'ı **EOD batch** ile dene (düzeltme öncesi) | **Aynı 3058** hatası — mapper/servis paylaşılan, manuel/batch farkı yok. Bu, sorunun konfigürasyon olduğunun kanıtı |
| **T-146** | Log'da `FxRate` | `0.0` görünüyor — **ayrı açık kalem**, yabancı para reeskontunda kontrol edilmeli |


---

## 16. 🔴 2026-08-20 (5. tur) — Regenerate valörleri sabit

> ⚠️ **MM API yeniden başlatılmalı** (`ExecutionsHandler` değişti) + tarayıcıda `Ctrl+F5`.
> ⚠️ Derleme sırasında `MSB3021` (dll kilitli) alırsan **API çalışıyor** — önce durdur.

### 16.1 Regenerate artık SORMUYOR

| # | Adım | Beklenen |
|---|---|---|
| **T-147** | Herhangi bir satır seç → **Regenerate** | 🔴 **Valör popup'ı AÇILMAZ** — doğrudan onay penceresi gelir |
| **T-148** | Regenerate onay penceresinin alt satırı | `Reverse voucher value date: T+1 …` **`(sabit)`** notuyla |
| **T-149** | Network → istek gövdesi | `ReverseValueType: 1` gönderiliyor (varsayılan) — modül **yok sayıyor**, sorun değil |

### 16.2 🔴 Valörlerin gerçekten doğru kesildiği — `AccEntry` kontrolü

| # | Senaryo | `AccEntry`'de beklenen |
|---|---|---|
| **T-150** | `Not Rediscounted` bir satır → **Regenerate** | Yeni reeskont **ValueDate = Execution Date** · yeni ters fiş **ValueDate = +1 İŞ GÜNÜ** |
| **T-151** | 🔴 `Not Reversed` bir satır → **Regenerate** | **İKİ** ters fiş: ① eski fişin tersi **ValueDate = Execution Date (T+0)** · ③ yeni fişin tersi **ValueDate = +1 iş günü (T+1)**. İkisi **farklı tarih** olmalı |
| **T-152** | `Rediscounted` bir satır → **Regenerate** | Yeni reeskont T+0 · yeni ters fiş T+1 · eski çifte **dokunulmaz** (zaten kapalı) |
| **T-153** | Execution Date **Cuma** seç → Regenerate | Ters fiş **Pazartesi** (takvim) — `AddDays(1)` ile Cumartesi **OLMAZ** |
| **T-154** | 🔴 **Çift tahakkuk kontrolü:** T-151 sonrası o günün defterinde açık reeskont sayısı | **1** (yeni olan). ① T+1'e kaçmışsa **2 açık reeskont** görünür → regresyon |

### 16.3 Generate etkilenmedi (regresyon)

| # | Adım | Beklenen |
|---|---|---|
| **T-155** | `Not Reversed` satır → **Generate** | 🔴 Valör popup'ı **AÇILIR** (T+0 üstte, T+1 seçili) |
| **T-156** | `T+0` seç → onayla | Ters fiş **ValueDate = Execution Date** |
| **T-157** | `T+1` seç → onayla | Ters fiş **ValueDate = +1 iş günü** |
| **T-158** | `Not Rediscounted` satır → **Generate** | Popup **açılmaz**; yalnız reeskont (T+0) kesilir, satır `Not Reversed` olur |

---

## 17. 🔴 2026-08-21 (6. tur) — kolon filtresi · ilerleme göstergesi · T+1 kuralı · grid/UI

**Önce:** MM API **ve** WebUI yeniden başlatılmalı (yeni uç + `ExecutionsHandler` yeni DI parametresi
+ yeni JS/CSS). Sert yenileme (Ctrl+F5) — JS/CSS `asp-append-version` ile gelse de tarayıcı önbelleği.

### 17.1 Kolon filtreleri (sunucu taraflı)

| # | Adım | Beklenen | Neden bu ölçüt |
|---|---|---|---|
| 1 | `Logical Reference` filtresine referansın bir parçasını yaz (`TMMBRW26`), filtre ikonuna bas | Grid **ve** üstteki özet şeridi **ve** sayfa sayısı birlikte daralır | Özet/sayım değişmiyorsa filtre sunucuya **gitmemiş**, tarayıcıda uygulanmış demektir |
| 2 | 🔴 `External Customer Id` filtresine **kısmi** değer yaz (`272`) | `27253` gibi kayıtlar gelir; **hata çıkmaz** | Sunucuda `CONVERT(nvarchar) LIKE` üretiliyor (`long?` alan). EF çevirisi patlarsa grid kırmızı hata basar — bu maddenin tek amacı o |
| 3 | `External Customer Name` filtresi (`Bankası`) | Kısmi eşleşme çalışır, büyük/küçük harf duyarsız | Kolon collation'ı CI |
| 4 | Grid'in sağ üstündeki **arama kutusu** (`İş`) | Referans **veya** müşteri adı **veya** müşteri no eşleşen satırlar | Arama tek `SearchText` alanı olarak gidiyor, üç alanda OR'lanıyor |
| 5 | Filtre + `Status` pill birlikte | İkisi **AND**'lenir; özet şeridi filtrelenmiş kümeyi anlatır | Filtre sayımlardan önce uygulanıyor |
| 6 | `Product` / `Status` / `Status Description` / ürüne özel kolonlar | Bu kolonlarda **filtre kutusu YOK** | Türetilmiş/sabit alanlar; boş kutu "filtrelenebilir" yalanı olurdu |
| 7 | Filtre kutusunun operatör menüsü | Yalnız **contains** | Sunucu tek eşleşme türü destekliyor |
| 8 | Sayfa 2'ye geç, filtre uygula | Filtre uygulanınca **1. sayfaya** döner ve sayım tutarlı kalır | Server-side paging + filtre birlikte |

### 17.2 ~~İlerleme göstergesi~~ — ❌ **GEÇERSİZ (2026-08-21)**

Bu bölümün 9-13. maddeleri **kaldırıldı**: poll altyapısı kullanıcı kararıyla tamamen silindi
(*"Faz 1 için gerekli değilmiş"*). Yerine § 18.1'e bak.

### 17.3 ~~T+1 valörü — `MMSystemWDFlag`~~ — ❌ **GEÇERSİZ (2026-08-21)**

14-17. maddeler **kaldırıldı**: T+1 artık `MMSystemWDFlag`'e bakmıyor, kural **+1 takvim günü**
(`ADR-MR-027`). Yerine § 18.2'ye bak.

### 17.4 Info ikonu · export · grid yüksekliği

| # | Adım | Beklenen |
|---|---|---|
| 18 | Generate'in köşesindeki **i** ikonuna bas (hiç satır seçmeden — buton pasifken) | Pencere **açılır**; 3 durum için ne yapıldığı yazar (`Rediscounted` satırda Generate'in **hata verdiği** açıkça yazılı) |
| 19 | Regenerate'in **i** ikonu | Üç durumun da `Rediscounted`'a gittiği + valörün sorulmadığı (T+1 sabit) yazar |
| 20 | Info penceresi dark mode | Metin okunur (dialog kendi renklerini taşıyor, temadan devralmıyor) |
| 21 | **Export** butonu | Sayfanın **sağ üst köşesinde**; grid başlıkları **kaymamış**, tablo bir satır aşağı **inmemiş** |
| 22 | Export'a bas | `manuel-reeskont.xlsx` iner; içinde **görünen kolonlar** ve formatlar (tutarlar sayı olarak) var. ⚠️ Yalnız **görünen sayfa** yazılır — buton ipucu bunu söylüyor |
| 23 | 1-2 satır dönen bir filtre uygula | Grid **sayfayı doldurmaya devam eder** (kısa tablo + boş alan yerine sabit yükseklik) |
| 24 | Pencereyi küçült/büyüt | Grid yüksekliği `100vh`'e göre uyum sağlar, sayfa **dikey kaymaz** |

### 17.5 `Status` pill maliyeti (regresyon)

| # | Adım | Beklenen |
|---|---|---|
| 25 | Pill'ler arasında geçiş yap, ağ sekmesini izle | Her tıklama **1 istek** (bu değişmedi); ama sunucuda artık **4 yerine 1 sorgu** koşuyor |
| 26 | `All` pill'i | Özet şeridi **üç kırılımı da** gösterir (sayımlar burada gerçekten yapılıyor) |
| 27 | `Not Rediscounted` pill'i | Özet şeridinde yalnız o kova dolu, diğerleri `0` — ve **grid satır sayısıyla tutarlı** |

---

## 18. 🔴 2026-08-21 (7. tur) — polling kaldırıldı · T+1 = +1 takvim günü · 5 UX kazanımı

**Önce:** MM API **ve** WebUI yeniden başlatılmalı — handler ctor'ları değişti (`ICalendarHelper`/`IHelper`
çıktı), `executions/progress` ucu **silindi**, yanıta `valueDates` eklendi, JS/CSS/lokalizasyon değişti.
Ctrl+F5 ile sert yenileme.

### 18.1 Polling gerçekten kalkmış mı

| # | Adım | Beklenen | Neden bu ölçüt |
|---|---|---|---|
| 1 | 5-8 satır seç, Generate → onayla | Yazı yalnız **"8 kayıt işleniyor…"**; `3/8` gibi sayac ve referans **YOK** | Poll kaldırıldı; kalan yazı statik |
| 2 | Tarayıcı ağ sekmesi (Execute sürerken) | **Hiç** `Progress` çağrısı yok; tek bir `Execute` isteği açık bekliyor | Tek istek yapısı (2026-08-19) korunuyor |
| 3 | Konsol | `mrStartProgressPolling is not defined` gibi hata **yok** | Silinen fonksiyonların çağrılmadığını kanıtlar |
| 4 | Seçili satırların rozeti | Bekleme sırasında **Processing** (mavi), yanıt gelince gerçek sonuca döner | `Processing` overlay'i poll'a bağlı değildi, durmalı |
| 5 | `GET /TreasuryRediscount/Progress` adresini elle çağır | **404** | Action silindi |

### 18.2 T+1 = ExecutionDate + 1 TAKVİM GÜNÜ

| # | Adım | Beklenen | Neden bu ölçüt |
|---|---|---|---|
| 6 | Execution Date = **Cuma**, grid'e bak | **Ters Fiş Valörü** kolonu **Cumartesi** gösteriyor | Yeni kural kaydırma yapmıyor — bu **beklenen** davranış |
| 7 | Kolon ipucu (hover) | *"Kural: işlem tarihi + 1 takvim günü"* + batch `reverseType` | Kullanıcı kuralı ekranda görebilmeli |
| 8 | `Not Rediscounted` satır | Kolonda **`-`**, ipuçta *"bu adımda ters fiş kesilmez"* | O adımda yalnız reeskont kesiliyor (§ 4.1) |
| 9 | Resmi tatil gününe denk gelen tarih | Yine **+1 gün** (tatil atlanmıyor) | Takvim servisi çağrılmıyor |
| 10 | 🔴 `Not Reversed` satıra T+1 ile Generate | `AccEntryMain` ters fiş satırının `ValueDate`'i ekranda görülen tarihle **birebir** aynı | Önizleme ile fiş **aynı sınıftan** hesaplanıyor (`ADR-MR-025`) |
| 11 | 🔴 Fimple/muhasebe tepkisi | Hafta sonu valörü **kabul edilmeli**; reddederse (`Code ...`) kural yeniden konuşulacak | Bilinçli ödünün gerçek sınavı bu madde |
| 12 | Onay penceresi | Ters fiş satırında **gerçek tarih** (`T+1 — 22.08.2026`) | Etiket artık tarih taşıyor |
| 13 | Regenerate onay penceresi | `T+1 — <tarih>` + **(sabit)** notu | Regenerate'te valör sorulmuyor (§ 4.3) |

### 18.3 5 UX kazanımı

| # | Adım | Beklenen |
|---|---|---|
| 14 | Ürün/alt ürün seçmeden ekranı aç | *"Kayıtları listelemek için ürün, alt ürün ve işlem tarihi seçin"* |
| 15 | Olmayan referansla filtrele | *"Filtreye/aramaya uyan kayıt yok"* |
| 16 | Filtreyi temizle, kayıt olmayan tarih seç | *"Bu tarihte reeskont bekleyen işlem yok"* |
| 17 | Bir durum pill'i seç (o kovada kayıt yok) | *"Seçilen tarihte bu durumda kayıt yok"* |
| 18 | 3 satır seç | Şeritte *"Seçili 3 kayıt — … · 1 ürün · Toplam: X TRY"* |
| 19 | Farklı para birimli satır ekle | Para birimleri **ayrı** toplanıyor (`1.500,00 TRY · 200,00 USD`) |
| 20 | Tutar alanı olmayan bir üründe seçim | Tutar kısmı **hiç görünmüyor** (0,00 yazılmıyor) |
| 21 | Bir satır hata alsın | `Status` hücresinde kırmızı **`!`**; hover'da tam metin |
| 22 | `!` düğmesine tıkla | Pencere açılır, uzun Fimple metni kaydırılabilir; **satır seçilmez** (checkbox değişmez) |
| 23 | Sonuç penceresini kapat | `!` düğmesi ve sebep **grid'de kalır** |
| 24 | Sonuç şeridinde **"Başarısızları seç"** | Yalnız hatalı satırlar seçili; **Execute otomatik başlamaz** |
| 25 | Hatalı satır 2. sayfada olacak şekilde dene | **Uyarı** çıkıyor: *"N başarısız kayıt başka sayfada…"* |
| 26 | Dark mode | `!` düğmesi ve hata penceresi okunur |
| 27 | Regresyon | Export sağ üstte, tablo aşağı **inmemiş**; grid sayfa boyunca uzun; kolon filtreleri çalışıyor |

> Kayıt: [`progress/progress-38.md`](progress/progress-38.md)

---

## 19. 🔴 2026-08-21 (9. tur) — K-5 damgası · Fiş No · sonuç Excel'i · akıllı seçim · onay toplamları · stateStoring

**Önce:** MM API **ve** WebUI yeniden başlat (paylaşılan muhasebe servislerine opsiyonel parametre
eklendi, okuma ucu iki yeni alan döndürüyor, yeni JS/CSS/lokalizasyon). Ctrl+F5.

| # | Adım | Beklenen | Neden bu ölçüt |
|---|---|---|---|
| 1 | 🔴 `Not Rediscounted` satıra Generate → DB'de yeni `AccEntryMain` | `StateMaker` = **senin kullanıcı adın** (eskiden işlemin dealer'ı yazıyordu) | `K-5` düzeltmesi |
| 2 | 🔴 **Batch'i çalıştır** (EOD revaluation) → kestiği fiş | `StateMaker` **değişmemiş** olmalı (işlemin kendi değeri) | Paylaşılan servise dokunuldu; batch davranışı bit-bit aynı kalmalı |
| 3 | Reeskont edilmiş satırda **Fiş No** kolonu | Fiş numarası görünür, ipuçunda `MessageKey` | Yeni alanlar |
| 4 | Fiş numarasına tıkla | **Yeni sekmede** `/AccountingEntry/Index?accMainId=...` açılır ve filtre kutusu **dolu** gelir, grid o fişi listeler | Muhasebe ekranına eklenen ön filtre |
| 5 | `Not Rediscounted` satırda Fiş No | **Boş** (0 yazmıyor) | Fiş yok |
| 6 | Muhasebe ekranı yetkisi olmayan kullanıcıyla tıkla | Yeni sekmede yetki hatası; **reeskont ekranı açık kalır** | Link bilinçli `target="_blank"` |
| 7 | Execute sonrası şeritte **Excel** | Dosya iner: Referans · Sonuç · Durum · Ayrıntı (hata sebepleri **tam metin**) | Sonuç DB'ye yazılmıyor; kalıcı kayıt buradan |
| 8 | **"Uygun satırları seç"** butonu (karışık sayfa) | Yalnız `Not Rediscounted` satırlar seçilir; yoksa `Not Reversed` kovasi | Generate tek statü ister (`D-10`) |
| 9 | Sayfada yalnız `Rediscounted` varken aynı buton | Seçim yapılmaz + uyarı | Boşuna istek gitmesin |
| 10 | Onay penceresi | **Toplam nominal** (+ varsa **toplam tahakkuk**) para birimi bazında | Fiş kesmeden önce ölçek görünmeli |
| 11 | Kolon genişliğini değiştir, F5 | Düzen **korunur** (`stateStoring`, `localStorage`) | ⚠️ Filtre ve **sayfa numarası** da saklanır; "veri yok" sanan kullanıcı filtre kutusuna bakmalı |
| 12 | Treasury'de düzen değiştir, Security ekranını aç | Security'nin düzeni **etkilenmez** | Anahtar `productGroup` bazında |

> Kayıt: [`progress/progress-40.md`](progress/progress-40.md)

---

## 20. 🔴 2026-08-21 (10. tur) — grid CLIENT-SIDE · onay toplamları kalktı · sonuç Excel'i tüm kolonlar · base component

**Önce:** MM API **ve** WebUI yeniden başlat, Ctrl+F5 (yeni JS/CSS + `MaxTake` 2000).
⚠️ `stateStoring` açık — eski bir filtre/sayfa saklanmış olabilir; ilk açılışta filtre satırını kontrol et.

| # | Adım | Beklenen | Neden bu ölçüt |
|---|---|---|---|
| 1 | 🔴 Ekranı aç, **F12 → Network**'ü izle. `All` → `Not Rediscounted` → `Not Reversed` → `All` tıkla | **Hiç yeni `Load` isteği gitmez** (ilk yükleme dışında); liste anında süzülür | Kullanıcının asıl istediği şey (`ADR-MR-028`) |
| 2 | Kolon filtresine referans parçası yaz | Anında süzülür, **istek gitmez**; özet şerit aynı anda küçülür | Şerit ile grid **asla** çelişmemeli (`ADR-MR-029`) |
| 3 | 🔴 Başlıktaki **huni** ikonuna bas (ör. External Customer Name) | Deger listesi **tüm kapsamdan** gelir (yalnız 1. sayfadan değil) | Huni bu yüzden kapalıydı; açılmasının geçerliliği bu |
| 4 | Bir kolon başlığına tıklayıp sırala (ör. **Principal Amount**) | Tüm kapsam sıralanır; 2. sayfaya geçince sıra **devam eder** | Eskiden yalnız yüklü sayfa sıralanıyordu → kapalıydı |
| 5 | Tutar kolonunda sıralama | **Sayısal** sıra (1.000 > 900) — alfabetik değil | `dataType: "number"` açık yazıldı |
| 6 | Tarih/ürün/alt ürün değiştir | **Tek** yeni `Load` isteği gider | Kapsam parmak izi değişti |
| 7 | 🔴 Execute et, sonra bir pill'e bas | **Yeni istek gider** ve durumlar **taze** gelir (islenen satır yeni statüsünde) | Execute sonrası önbellek geçersiz kılınıyor — bayat durum göstermek **yasak** |
| 8 | ⚠️ 2000'den fazla uygun işlemi olan bir tarih/alt ürün seç (varsa) | Şeritte **kırmızı** *"Yalnızca ilk 2000 / N kayıt"* + notify uyarısı | Sessiz eksik liste finansal ekranda kabul edilemez |
| 9 | 🔴 Onay penceresini aç (Generate ve Regenerate) | **Toplam nominal / tahakkuk satırları YOK**; kayıt sayısı ve durum kırılımı duruyor | Kullanıcı kararı: *"gereksiz, silelim"* |
| 10 | 🔴 Execute → sonuç şeridinde **Excel** | Dosyada **Sonuç · Durum · Ayrıntı** + **ekranın tüm kolonları** (ürüne özel dahil) | Kullanıcı isteği 2026-08-21 |
| 11 | Aynı dosyada tutar ve tarih hücreleri | **Sayı** ve **tarih** olarak gelir (metin değil) — Excel'de toplanabilir/sıralanabilir | Ham deger yazılıyor, bicimlenmis metin degil |
| 12 | Bir kolonu grid'de gizle, tekrar Excel al | Gizli kolon dosyada **yok** | Kolon listesi grid'den okunuyor |
| 13 | **"Uygun satırları seç"** (kapsamda 50'den fazla uygun satır varsa) | En fazla **50** seçilir + *"kalan: N"* yazılır | Başlıktaki tik tüm kümeyi seçer ve Execute reddeder — bu buton tavanı kendi uygular |
| 14 | Başlık tiki ile **hepsini** seç (>50 satır) → Generate | *"En fazla 50 kayıt"* uyarısı; **fiş kesilmez** | Client-side seçimin yeni riski; guard yerinde |
| 15 | 🔴 **Fiş No** linkine bas | Yeni sekmede `/AccountingEntry/Index?accMainId=...` açılır ve filtre **dolu** | Yol artık **konfigürasyondan** geliyor (`ADR-MR-030`) — kırılmadığını doğrula |
| 16 | Security ve Investment ekranlarını aç | Filtre değişimi **kendi** grid'ini tazeler | `window.mrInstance` kalktı; instance `uniqueKey` ile çözülüyor |

> Kayıt: [`progress/progress-41.md`](progress/progress-41.md)

---

## 21. 🔴 2026-08-21 (11. tur) — Voucher kolonu kalktı · akıllı seçim kalktı · **ters fiş valörü gerçek** · başlıklar tam

**Önce:** MM API **ve** WebUI yeniden başlat, Ctrl+F5.

| # | Adım | Beklenen | Neden bu ölçüt |
|---|---|---|---|
| 1 | 🔴 Bir satıra **T+0** ile Generate (ters fiş) → valör kolonuna bak | **İşlem tarihi** yazar (T+1 değil), yazı **düz** (italik değil), ipuçu *"Kesilen ters fişin valör tarihi"* | `ADR-MR-031` — bu turun asıl hatası |
| 2 | Aynı satırın muhasebe fişine bak (Module Accounting) | Ters fiş valörü ekrandaki tarihle **birebir** aynı | Ekran ile defter ayrışmamalı |
| 3 | **T+1** ile Generate yapılmış başka bir satır | İşlem tarihi **+1 gün** yazar | Aynı kolon iki farklı gerçeği doğru göstermeli |
| 4 | `Not Reversed` satır (ters fiş **yok**) | Tarih **italik/soluk**, ipuçunda *"Önizleme - ters fiş henüz kesilmedi"* | Önizleme ile gerçek karışmamalı |
| 5 | `Not Rediscounted` satır | Kolonda `-` | Bu adımda ters fiş kesilmiyor |
| 6 | 🔴 Grid'in kolonlarına bak | **"Voucher No" kolonu YOK** | Kullanıcı kararı |
| 7 | Toolbar'a bak | **"Select eligible rows" butonu YOK** | Kullanıcı kararı |
| 8 | 🔴 `/AccountingEntry/Index` ekranını normal yoldan (menü) aç | Ekran **eskisi gibi** çalışır; hiçbir ön filtre uygulanmaz | O paylaşılan ekrana eklenen `?accMainId=` betigi **geri alındı** |
| 9 | 🔴 Tüm kolon başlıklarını oku (yatayda kaydırarak) | **Hiçbir başlıkta `...` yok**; sığmayan başlık **iki satıra** sarıyor | `ADR-MR-032` |
| 10 | Sonuç Excel'i al | Dosyada **Voucher No kolonu yok**, diğer tüm ekran kolonları var | Kolon listesi grid'den okunuyor |
| 11 | Başlık tiki ile 50'den fazla satır seç → Generate | *"En fazla 50 kayıt"* uyarısı, fiş **kesilmez** | Akıllı seçim kalktı; guard tek koruma |
| 12 | Interbank Loan ürününde aynı valör testleri | Aynı davranış (iki data manager aynı deseni taşıyor) | Tek yerde düzeltip diğerini unutmak klasik tuzak |

> Kayıt: [`progress/progress-42.md`](progress/progress-42.md) · Veri seçim kuralları: [`10-veri-secim-kurallari.md`](10-veri-secim-kurallari.md)
