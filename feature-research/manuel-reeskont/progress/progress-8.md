# progress-8 — 🧪 CANLI TEST: Faz 1 doğrulandı · 2 bug bulundu ve düzeltildi

**Tarih:** 2026-08-13 · **Önceki:** [progress-7.md](progress-7.md)
**Tetikleyen istek:** *"Şimdi ekranı ayağa kaldır ve Faz 1 ve Faz 2'yi test et, sonra da hata çıkarsa ayıkla"*
**Kural:** Bu dosya progress-7'nin **güncellenmiş tam hali**dir. Öncekiler **düzenlenmedi**.

---

## 🔴 Kritik durum — Faz 2 canlı testi YAPILMADI (kasıtlı)

`executions` ucu **gerçek muhasebe fişi keser ve Fimple'a gider** — geri alınamaz, dış sisteme yazar.
Kullanıcı onayı olmadan tetiklenmedi. **Yazma yapmayan** tüm yollar (validasyon, guard'lar) test edildi.

---

## Ortam kurulumu — kullanıcının stack'ine DOKUNULMADI

Docker'da kullanıcının kendi stack'i çalışıyordu (**eski image'lar**):

```text
nettrexmmwebapi   0.0.0.0:5041->80/tcp
ui-nettrex        0.0.0.0:5032->80/tcp
redis             0.0.0.0:6379->6379/tcp
```

Bu container'lara **dokunulmadı** (rebuild/restart yok). Kendi build'im **ayrı portlarda** kaldırıldı:

| Uygulama | Port | Komut notu |
|---|---|---|
| MM API | **5141** | `dotnet run --launch-profile "NetTrex.MM.Api:Dev-Investment" -- --urls=http://localhost:5141 --CommonApi=http://192.168.10.191:30825/api` |
| Web.UI | **5132** | `--no-launch-profile` + **env değişkenleriyle** (aşağıda G-2) |

**DB:** `NetTrexMM_Dev` (launchSettings'in gösterdiği) — 81 revaluation kaydı var (`sql-log` #6).

### Ortam engelleri (kod hatası DEĞİL)

| # | Engel | Çözüm |
|---|---|---|
| **G-1** | Her iki uygulama da **açılışta `CommonApi`'ye** (framework parametreleri) bağlanıyor; `localhost:5050` boştu → *"Hosting failed to start"* | Cluster Common API'si verildi: `http://192.168.10.191:30825/api` |
| **G-2** | 🔴 **Web.UI komut satırı config argümanlarını OKUMUYOR** (özel host builder — `Framework.Startup.DefaultStartup`). `-- --CommonApi=...` **etkisiz**; `--launch-profile` env'i de üzerine yazıyor | `--no-launch-profile` + tüm ayarlar **env değişkeni** olarak verildi |
| **G-3** | Port 5041/5032 doluydu (docker) | 5141 / 5132 kullanıldı |
| **G-4** | Web.UI **login'e yönlendiriyor** — `Framework__Application__SkipAuthorization=true` **yetkiyi** atlıyor, **kimlik doğrulamayı** değil | ⬜ Tarayıcı testi **kullanıcı girişi gerektiriyor** |
| — | `State cache failed to populate state from redis` → `ArgumentNullException (items)` | **Mevcut framework sorunu**, benim kodumla ilgisi yok; açılışı engellemiyor |

---

## 🐞 BUG 1 — Flow pipeline hatası (500) · DÜZELTİLDİ

**Belirti:** İlk çağrıda HTTP **500**.

```text
System.InvalidOperationException: The request
'NetTrex.MM.Api.ResponseRequest.ManuelReeskont.Request.EligibleTransactionsRequest'
should have a flow property
   at Netix.Core.Handler.PipelineBehaviors.FlowPipelineBehavior`2.Handle(...)
```

**Kök neden:** `BaseMmRequest<T>` → `BaseFlowRequest<T>` **state-machine akışı** içindir. Salt-okunur bir
sorgu (ve bizim `executions`'ımız gibi state geçişi olmayan bir yazma) bu pipeline'a uymaz.

**Çözüm:** `IQueryFilterRequest` marker'ı — repo'da zaten var olan escape hatch.
Emsal: `TransactionSelectRequest`, `TawarruqSelectRequest`, `IssueBondSelectRequest`, `InterbankLoanSelectRequest`.

Arayüz `int StateFilter` zorunlu kılıyor → iki request'e de eklendi ve **"sözleşmenin parçası değil,
bu uçta kullanılmıyor"** diye açıkça belgelendi (uygunluk filtresi state'i kendi içinde
`StateConstants.VerifiedStatesId` ile uyguluyor).

⚠️ `ExecutionsRequest`'te marker'ın adı ("query") yanıltıcı — **işlevi flow pipeline'ını devre dışı
bırakmak**; dosyada bu açıkça yazıldı.

## 🐞 BUG 2 — IssueBond işlemleri MM ekranında görünüyordu · DÜZELTİLDİ

**Belirti:** Uç 4 kayıt döndürdü ama hepsi `subProduct: "ISSUE"`, referanslar `TISBRW2510270020` gibi
— bunlar **tahvil ihraç (IssueBond)** işlemleri, MM/Loan ürünü değil.

**Kök neden:** Uygunluk filtresini EOD sorgusundan (`GetPendingRevaluationTransactions`) aldım ama
MM ekranlarının **ISSUE dışlama** kuralını almamıştım. `TransactionSelectHandler` bunu yapıyor:

```csharp
data = data.Where(x => x.TxnMmProductTypeId != (int)ProductAccountingCodeType.ISSUE);
```

**Çözüm:** Aynı filtre `GetRediscountEligibleTransactionsAsync`'e eklendi.
**Doğrulama:** Fix sonrası `TMMBRW2505220009` / `subProduct: "MONEYMARKET"` geldi — doğru ürün.

---

## ✅ Faz 1 — backend uçtan uca DOĞRULANDI

`POST http://localhost:5141/api/manuel-reeskont/eligible-transactions`

| Test | Sonuç |
|---|---|
| Sayfalama | `Take=3` → 3 item, `totalCount=4` ✅ |
| **Durum türetme (M-08)** | `status:1` NotRediscounted · `status:3` NotReversed · `status:4` Rediscounted — üçü de gerçek veride görüldü ✅ |
| `Data` sözlüğü | 12 anahtarın tamamı dolu (`PrincipalAmount`, `InterestRate`, `AccruedInterest`, `DailyAccrual`, `PortfolioName`, `DayCountBasis`, …) ✅ |
| Para yuvarlama | `880000.00`, `-40952.92` → 2 ondalık ✅ |
| `Status` filtresi | `Status=1` → 1 kayıt · `Status=4` → 0 kayıt ✅ |
| `SubProduct` filtresi | `Murabaha` → 0 (kayıt MONEYMARKET) ✅ |
| `IsFirstLoad` guard | boş liste + `isSuccess:true`, modüle hiç gidilmiyor ✅ |
| Modül guard | `ModuleCode=FX` → `MODULE_MISMATCH`, veri dönmüyor ✅ |
| `MessageKey` sızıntısı | Yanıtta **yok** ✅ (sözleşme § 3.2) |

**Örnek yanıt (kısaltıldı):**

```json
{"totalCount":1,"items":[{"transactionId":552549968,"logicalReference":"TMMBRW2505220009",
"subProduct":"MONEYMARKET","customerName":"Akbank A.Ş.","valueDate":"2025-04-16T00:00:00","status":1,
"data":{"TxnTypeCode":"BRW","Direction":"Borrowing","Currency":"TRY","PrincipalAmount":1000.00,
"InterestRate":20.0000000000,"MaturityDate":"2025-12-14T00:00:00","DayCountBasis":"ACT / 360"},
"productSourceType":"MoneyMarket"}],"isSuccess":true}
```

## ✅ Faz 2 — yazma yapmayan yollar doğrulandı

`POST http://localhost:5141/api/manuel-reeskont/executions` — **hiçbir fiş kesilmedi**

| Test | Sonuç |
|---|---|
| Boş `Items` | `"En az bir işlem seçilmelidir."` ✅ |
| Geçersiz `Operation` (9) | `"Operation yalnızca Generate (1) veya Regenerate (2) olabilir."` ✅ |
| Gelecek `ExecutionDate` | `"ExecutionDate gelecek tarih olamaz."` ✅ |
| `ReverseValueDate == ExecutionDate` | `"ReverseValueDate, ExecutionDate'ten sonra olmalıdır."` ✅ |
| Yanlış modül | `MODULE_MISMATCH` — döngüye hiç girmiyor ✅ |

⬜ **Gerçek fiş kesme testi YAPILMADI** — kullanıcı onayı bekliyor.

## ✅ Web.UI — kimliksiz doğrulanabilenler

| Test | Sonuç |
|---|---|
| Uygulama ayağa kalkıyor (5132) | ✅ |
| 9 statik varlık (6 JS + config JSON + CSS + localization) | **hepsi HTTP 200** ✅ |
| JS sözdizimi (`node --check`) | 6/6 **OK** ✅ |
| **`const` çakışması taraması** (tüm `js/shared` ile) | **Çakışma YOK** ✅ (`MR_` prefix disiplini işe yaradı) |
| Ekran render'ı | ⬜ **login gerekiyor** — kullanıcı girişi olmadan test edilemedi |

---

## 🔵 YAPILIYOR

Yok. **Sunucular ayakta bırakıldı** (MM API 5141, Web.UI 5132) — kullanıcı giriş yapıp ekranı görebilsin.

---

## ⬜ YAPILACAK

### Kullanıcıdan gerekenler

| # | Ne | Neden |
|---|---|---|
| 1 | 🔴 **Faz 2 gerçek test onayı** — Generate/Regenerate gerçek fiş keser + **Fimple'a gider** | Geri alınamaz, dış sisteme yazar |
| 2 | **Web.UI'ye giriş** (http://localhost:5132/TreasuryReeskont/Index) | Kimlik doğrulama atlanamıyor |
| 3 | §4.6 `RevaluationType` kararı (progress-7'deki açık kalem) | Sözleşmede alan yok |

### Faz 2 gerçek test yapıldığında doğrulanacaklar

- `AccEntryMain`'de yeni T+0 fişi (`Type=2`, `IsReverse=0`) oluştu mu
- Ters fişte **`StateMaker` gerçek kullanıcı** mı (**`T-01` fix'inin canlı kanıtı**)
- `ReverseId` çift yönlü bağlandı mı
- Fimple'a giden `ReversAccountingTransactionDate` doğru mu
- Aynı satıra ikinci kez Generate → `ALREADY_REDISCOUNTED`

### Sonra

Faz 3 — `İ-70`…`İ-76` (Fx/FI/InvFund uçları + Security/Investment ekranları).

---

## Kararlar bu turda

| Karar | Gerekçe |
|---|---|
| Kullanıcının docker stack'ine **dokunulmadı**, ayrı portlar kullanıldı | Rebuild/restart onun ortamını değiştirirdi |
| Faz 2 gerçek testi **yapılmadı** | Geri alınamaz + dış sisteme (Fimple) yazar — onay şart |
| ISSUE filtresi eklendi | Testte yakalandı; MM ekranlarının mevcut kuralı |
| `IQueryFilterRequest` iki request'e de eklendi | Repo'nun kendi escape hatch'i; `StateFilter` sözleşme dışı diye belgelendi |
