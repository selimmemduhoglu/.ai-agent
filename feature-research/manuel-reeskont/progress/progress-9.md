# progress-9 — 🟢 FAZ 3 KODLANDI (3 ekran + 4 modül) · test rehberi yazıldı

**Tarih:** 2026-08-13 · **Önceki:** [progress-8.md](progress-8.md)
**Tetikleyen istek:** *"Faz 1 ve 2 testi için araştırma ve yaptıklarını bir md dosyasına yaz… şimdilik Faz 3'e geç"*
**Kural:** Bu dosya progress-8'in **güncellenmiş tam hali**dir. Öncekiler **düzenlenmedi**.

**Sonuç:** ✅ `NetTrex.MM` **Build succeeded** · ✅ `NetTrex.Web.UI` **Build succeeded**

---

## ✅ A. Test rehberi — [`08-test-rehberi.md`](../08-test-rehberi.md) (YENİ)

Kullanıcı tarayıcı testini **tüm fazlar bitince** yapacak; o güne kadar hiçbir bilgi kaybolmasın diye
9 bölümlük rehber yazıldı:

| Bölüm | İçerik |
|---|---|
| § 1 | **Ortam kurulumu** — birebir komutlar, portlar, env değişkenleri, 5 ortam engeli (`G-1`…`G-5`) |
| § 2 | **Test verisi** — `NetTrexMM_Dev`, tarih `2025-10-27`, işlem `TMMBRW2505220009` (`TxnId 552549968`) |
| § 3 | Faz 1'de **çalıştırılan** testler + curl'ler + beklenen/gerçekleşen |
| § 4 | Faz 2 — çalıştırılan (validasyon) **ve çalıştırılmayan** (gerçek fiş) + **doğrulama SQL'leri** |
| § 5 | Bulunan 2 bug, kök nedeni ve fix'i |
| § 6 | Web.UI'de kimliksiz doğrulananlar + statik varlık kontrol komutu |
| § 7 | 🖥️ **TARAYICI TEST KONTROL LİSTESİ** — 6 başlık, ~40 madde |
| § 8 | Test edilemeyenler ve nedenleri |
| § 9 | İlgili dosyalar |

---

## ✅ B. Faz 3 — 4 modül · 3 ekran

### B.1 Modül client'ları (`İ-70`)

`Services/ManuelReeskont/IManuelReeskontModuleApis.cs` **(YENİ)** — 3 Refit interface:

| Interface | Marker | Modül ucu durumu |
|---|---|---|
| `IManuelReeskontFxApi` | `IClientFxAPI` | ⬜ `NetTrex.Fx`'te henüz yok (`İ-71`) |
| `IManuelReeskontFiApi` | `IClientFiAPI` | ⬜ ürün ekibinde (`İ-72`) |
| `IManuelReeskontInvFundApi` | **`IClientFundsAPI`** ⚠️ (`InvFund` değil — `G-09`) | ⬜ ürün ekibinde |

`ManuelReeskontModuleResolver.cs`'e 3 adaptör eklendi (`Fx…`, `Fi…`, `InvFund…ModuleClient`) ·
`Startup.cs`'e 3 DI kaydı.

> 🔑 **`ManuelReeskontModuleResolver` sınıfı Faz 1'den beri DEĞİŞMEDİ** — `IEnumerable<IManuelReeskontModuleClient>`
> ile adaptörleri DI'dan topluyor. Yeni modül eklemek = **1 interface + 1 adaptör + 1 DI satırı**.
> `ADR-MR-018`'in (resolver servisi, controller'da değil) karşılığını aldığı yer burası.

> 🔑 **`F-01` kendiliğinden kapandı.** v1'de (Common mimarisi) en büyük boşluk "Common'da InvFund
> Refit client'ı yok" idi. v2'de Common çıkarıldı; Web.UI'de `IClientFundsAPI` **zaten kayıtlı**
> (`Startup.cs:66`) → Investment ekranı için ekstra altyapı gerekmedi.

### B.2 Ortak controller base (`İ-73`)

`Controllers/ManuelReeskont/ReeskontControllerBase.cs` **(YENİ)** — `abstract`, üç ekranın ortak
`Index` / `Load` / `Execute` mantığını taşır.

**Neden base + 3 ince controller?** Yetki granülaritesi `ControllerAdı/ActionAdı` (`ADR-MR-003`).
Action'lar base'te tanımlı olsa da permission **türeyen** sınıfın adıyla çözülür
(`TreasuryReeskont/Load`, `SecurityReeskont/Load`, …) → **yetki ayrımı korunur, mantık tekrarlanmaz**.

| Controller | ProductGroup | UniqueKey | Ürünler |
|---|---|---|---|
| `TreasuryReeskontController` | Treasury | `trs` | MM/Loan Transactions (**MM ✅**) · FX Transactions (⬜) |
| `SecurityReeskontController` **(YENİ)** | Security | `sec` | Security Transactions (⬜ FI) |
| `InvestmentReeskontController` **(YENİ)** | Investment | `inv` | Fund Transactions (⬜ InvFund) |

`TreasuryReeskontController` **yeniden yazıldı** — artık base'den türüyor, 25 satır.

### B.3 View'lar ve kolon config'leri (`İ-73`)

| Dosya | Not |
|---|---|
| `Views/ManuelReeskont/Security/Index.cshtml` **(YENİ)** | Yalnız `Component.InvokeAsync` — ekrana özel mantık **YOK** |
| `Views/ManuelReeskont/Investment/Index.cshtml` **(YENİ)** | aynı |
| `wwwroot/js/config/manuel-reeskont/security.json` **(YENİ)** | 7 SubProduct (FI'nın `RediscountTransactionType` enum'ından türetildi) + 11 kolon |
| `wwwroot/js/config/manuel-reeskont/investment.json` **(YENİ)** | ⚠️ **TASLAK** — ürün ekibiyle teyit edilecek; dosyada açıkça yazılı |
| localization tr/en | 6 yeni kolon anahtarı (`SecurityCode`, `NominalAmount`, `Price`, `FundCode`, `UnitCount`, `UnitPrice`) |

> 🔑 **Base component'e tek satır kod eklenmedi.** Üç ekran aynı `ManuelReeskontViewComponent` +
> aynı 6 JS dosyasını kullanıyor; fark yalnızca **ProductGroup** ve **kolon config'i**.
> Doküman'ın "ürün ekipleri yalnız 2 endpoint + kolon config teslim eder" hedefi **doğrulandı**.

### B.4 `RegenerateToToday` (`İ-76`) — 🔴 BİLİNÇLİ OLARAK UYGULANMADI

Doküman *"Regenerate'te geçmiş tarihli yeniden değerleme"* diyor ama **hangi tarihlerin** yeniden
değerleneceğini tanımlamıyor. Muhasebe fişi üreten bir davranışı tanımsız varsayımla yazmak
**istenmeyen fişlere** yol açar; sessizce yok saymak da kullanıcıya yalan olur.

**Çözüm:** `ExecutionsHandler` açık hata döndürüyor —

```csharp
if (request.RegenerateToToday)
    → IsSuccess = false, MessageCode = "NOT_IMPLEMENTED",
      "…hangi tarihlerin yeniden değerleneceği iş birimi tarafından tanımlanmadı. İstek işlenmedi."
```

Alan sözleşmede **duruyor**; iş birimi tanımı gelince yalnız bu blok doldurulacak.

---

## ✅ C. Doğrulama (build + çalışan uygulama)

| Kontrol | Sonuç |
|---|---|
| `NetTrex.MM` build | ✅ Build succeeded |
| `NetTrex.Web.UI` build | ✅ Build succeeded |
| 3 kolon config HTTP | `treasury.json` **200** · `security.json` **200** · `investment.json` **200** ✅ |
| 3 ekran route | `TreasuryReeskont` **302** · `SecurityReeskont` **302** · `InvestmentReeskont` **302** ✅ (302 = route çözüldü, login'e yönlendi) |

**Derleme tuzağı:** Uygulamalar çalışırken build **MSB3027 file lock** verir
(`The file is locked by: "Trex.WebUI (1884)"`). Önce `TaskStop`, sonra build, sonra yeniden başlat.

---

## ✅ D. Muhasebe (Accounting) araştırması — `NetTrexAcc` incelendi

Kullanıcı sordu: *"neden SQL sorgularını ve çıktılarını göremiyorum, sorgu atmıyor musun?"*
**Cevap: atıyorum ve kaydediyorum** — `sql-log/manuel-reeskont-analiz/` altında 7 sorgu+çıktı zaten vardı.
Bu turda **9 sorgu daha** eklendi → **toplam 16 sorgu · 0 yazma işlemi**.

**Yeni belge:** [`NetTrex.MM/.ai-agent/feature-research/Accounting-Engine-research.md`](../../../NetTrex.MM/.ai-agent/feature-research/Accounting-Engine-research.md)

| Bulgu | Detay |
|---|---|
| **Fiş İKİ yerde** | `AccEntryMain`/`AccEntry` hem `NetTrexMM`'de hem `NetTrexAcc`'te. **3 tip farkı:** `ValueDate` date/datetime · `TxnId` bigint/int · `Flag`/`Flags` |
| **Kural motoru zinciri** | `AccEngineItem`(521) → `AccEngineEvent`(591) → `AccEngineGroup`(1.139) → `AccEngineComponent`(3.655) → **`AccEngineAccountRule`(8.655)** |
| **GL kararı kuralda** | `GLCode` · `DebitCredit` · `AmountSource` · `ValueDateSource` · `ReverseRebook` — kodda hard-code **değil** |
| **`OnRevaluation` = 36 kural** | MM'in `AccountingType.Revaluation`'ının motordaki karşılığı |
| 🔑 **Ürün ağacı ≠ politika ağacı** | `TREX/MM/…` altında `OnRevaluation` **YOK**; kurallar **`TREX/BRWPLC1/MONEYMARKET|LOAN/{BRW,PLC}/{LCY,FCY}/`** altında |
| Versiyonlama | Her tanım tablosunun `*History` ikizi var (maker-checker) |

**Manuel Reeskont'a etkisi:** Ekran GL'e karışmıyor, servisi tetikliyor → `ADR-MR-005` doğru karar.
⚠️ Murabaha/Wakala için `OnRevaluation` kuralı **var mı** doğrulanmadı (araştırma § 5, madde 1).

---

## 🔵 YAPILIYOR

Yok. Sunucular ayakta: **MM API 5141** · **Web.UI 5132**.

---

## ⬜ YAPILACAK

### Kullanıcıdan gerekenler (kod bloke değil)

| # | Ne |
|---|---|
| 1 | 🔴 **Faz 2 gerçek fiş testi onayı** — Fimple'a yazar, geri alınamaz ([`08-test-rehberi.md`](../08-test-rehberi.md) § 4.2-4.3) |
| 2 | **Tarayıcı testi** — tüm fazlar bitti, rehber § 7 hazır. Giriş gerekiyor |
| 3 | Doküman **§4.6 `RevaluationType`** kararı (sözleşmede alan yok) |
| 4 | **`RegenerateToToday`** iş kuralı tanımı |
| 5 | `İ-71` — `NetTrex.Fx`'in 2 ucunu **kim yazacak?** |
| 6 | `Ö-S-01…08` Fimple ekibi soruları · `Ö-04`/`Ö-05` muhasebe soruları |
| 7 | Permission kayıtları: 3 ekran × (`Index`/`Load`/`Execute`) |

### Faz 4 — pakete taşıma (`İ-80`…`İ-83`)

Faz 1-3 boyunca **4 taşınabilirlik kuralına uyuldu**:
endpoint config'ten (`dataSource.load.url` / `.execute.url`) · Razor `Views/Shared/Components/`'ta ·
CSS + localization ayrı dosyada · JS yalnız `settings`/`formatMessage`/`notifyError`/`$.ajax`'a bağımlı.

---

## Kararlar bu turda

| Karar | Gerekçe |
|---|---|
| **Abstract base + 3 ince controller** | Mantık tekrarı yok ama permission **türeyen sınıf adıyla** çözüldüğü için yetki ayrımı korunuyor |
| FX/FI/InvFund interface'leri **modül ucu yokken de yazıldı** | Uç açıldığında UI'de **değişiklik gerekmeyecek**; karşı tarafın durumu dosyada açıkça yazılı |
| `investment.json` **taslak** olarak işaretlendi | Ürün ekibiyle teyit edilmemiş bir şeyi kesinmiş gibi göstermemek için |
| **`RegenerateToToday` uygulanmadı**, açık hata döndürüyor | Tanımsız iş kuralıyla muhasebe fişi üretmek riskli; sessiz no-op ise yanıltıcı |
| Kullanıcının docker stack'ine yine dokunulmadı | 5141/5132 ayrı portlarda çalışıldı |
