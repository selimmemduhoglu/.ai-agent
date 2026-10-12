# progress-3 — Faz planı (iş emri) çıkarıldı · A/B'siz yapılabilir iş ayrıştırıldı

**Tarih:** 2026-08-12 · **Önceki:** [progress-2.md](progress-2.md)
**Tetikleyen istek:** *"A ve B olmadan yapının mimarisini ve analizini çıkarabilir misin? … güzel bir şekilde
bu işin mimarisini ve analizini çıkar ve **fazlandır** ve bana rapor olarak sun ve bunu da md dosyası haline
getir, sonra da her ilerleme kat ettiğin zaman o mimari ve analiz fazlarından gideceksin, her seferinde oku,
ben beğenmediğim yerleri değiştireceğim"*
**Kural:** Bu dosya progress-2'nin **güncellenmiş tam hali**dir. progress-1 ve -2 **düzenlenmedi**.

---

## 🔑 Bu turun sonucu

**Soru:** A ve B cevapları olmadan ne kadarı yapılabilir?
**Cevap: ~%70.** Bloke eden sorular **davranışı** belirliyor, **iskeleti** değil.

Fazlandırma buna göre **yeniden yapıldı** — A/B'siz yapılabilen her şey **Faz 1**'e, A/B gerektiren her şey
**Faz 2**'ye ayrıldı. Eski "Faz 1 = base component + Treasury ekranı" tek parçası bölündü.

**Yeni dosya:** [`05-faz-plani.md`](../05-faz-plani.md) — **iş emri**: 6 faz · **58 iş kalemi (`İ-01`…`İ-90`)** ·
A/B bağımlılık matrisi · faz başına Definition of Done · varsayım/dönüş-maliyeti tablosu · 3 yeni risk.

### Yöntem — "dikiş yerlerini şimdi aç, kararı sonra ver"

Bilinmeyen her karar için **soyutlama dikişi**; cevap gelince **tek yerde** doldurulur:

| Bilinmeyen | Dikiş | Cevap gelince değişen |
|---|---|---|
| C-01 aksiyon seti | `actions` config map'i | Map'in içeriği — toolbar kodu değil |
| C-01 `All` var mı | `allowAll: bool` | Tek bayrak |
| C-07 senkron/asenkron | `IManuelReeskontExecutionDispatcher` (tek imza) | Dispatcher **implementasyonu** |
| C-08 alanlar | DTO'da **opsiyonel** (`ReverseValueDate?` vb.) | Zorunlu/opsiyonel + validator |
| C-02 tekli/çoklu | Filtre `multiple: bool` | Tek bayrak |
| C-15 config yeri | `columns: { config, url }` ikisi de destekli | Hangisinin dolduğu |

⚠️ Dikiş ≠ "iki davranışı birlikte yaz". İki akışı paralel kodlamak **çöp iş**; dikiş = **tek noktada değişebilirlik**.

---

## ✅ YAPILDI

### A. progress-1'den devralınan (değişmedi)

- `Manuel Reeskont v1.docx` (416 satır + **7 görsel**) baştan sona okundu
- `01-dokuman-analizi.md` (C-01…C-20) · `03-mm-backend-envanteri.md` (T-01…T-11, M-01…M-09) · `04-sorular.md`
- 5 ajan araştırması `analiz/analiz-1…5` **ham** olarak
- Workspace MD katmanı + `manuel-reeskont` skill'i

### B. progress-2'den devralınan (değişmedi)

- 🔴 **Mimari v2:** `NetTrex.Common` **çıkarıldı**, WebUI Controller'dan modüllere **direkt** (`ADR-MR-015`).
  Uygulanabilirlik ölçüldü: 4 modülün Refit marker'ı `Startup.cs:58-75`'te **zaten kayıtlı**, ek DI gerekmez
- `analiz/analiz-6` — WebUI desen envanteri (3 nesil · `settings.baseUrl` gerçeği · `ajax.js` yutma ·
  eski Fx ekranının **10 kusuru** · `RediscountStatusTypes.All` **VAR** bulgusu)
- `02-mimari-karar.md` **v2** — § 0 sürüm tablosu · § 2 base component tasarımı · **18 ADR** · F-13…F-18 · R-11/R-12
- `NetTrex.Web.UI`'ye **MD katmanı kuruldu** (repoda hiçbir şey yoktu) + skill wrapper'ı
- 🔴 **Compact sistemi:** sohbet başına klasör · `PreCompact` + `SessionStart:compact` hook'ları
  (MM ✅ · Web.UI ✅ · MM.UI ⚠️ classifier engelledi, kullanıcı elle ekleyecek) · bu oturumun 2 compact'i geriye dönük yazıldı

### C. Bu turda yapılan

| İş | Çıktı |
|---|---|
| **A/B bağımlılık analizi** | Hangi sorunun hangi iş kalemini blokladığı → `05-faz-plani.md` § 8 |
| **Yeniden fazlandırma** (6 faz) | Faz 1 = A/B'siz iskelet+okuma · Faz 2 = A/B'li aksiyonlar+yazma |
| **58 iş kalemi** `İ-xx` | Faz 0: İ-01…08 · Faz 1: İ-10…45 · Faz 2: İ-50…64 · Faz 3: İ-70…76 · Faz 4: İ-80…83 · Faz 5: İ-90 |
| **Faz başına Definition of Done** | Faz 1: 9 madde · Faz 2: 7 madde — ölçülebilir kabul kriteri |
| **Varsayım tablosu** | 4 Selim kararı için varsayım + **dönüş maliyeti**; `M-08` **yüksek** işaretli |
| **3 yeni risk** | `R-13` çok modüllü sayfalama · `R-14` aksiyonsuz Faz 1 test yanılgısı · `R-15` sessiz varsayım |
| `00-PANO.md` güncellendi | Yeni faz tablosu + eski↔yeni eşleme + 8 adımlık sıradaki iş + `05` dosya haritası satırı |
| `progress/_index.md` | progress-3 satırı |

### 🔴 Bu turda ortaya çıkan en önemli iki bulgu

**1. `R-13` — çok modüllü sayfalama tuzağı.**
`Skip`/`Take` **modül başına** uygulanırsa aggregate sonuç ve `TotalCount` **yanlış** olur.
Faz 1'de tek modül (MM) olduğu için **sorun görünmez**, Faz 3'te patlar. Üç seçenek:
(a) her modülden tam liste + UI'de birleştir/sayfala (bellek riski), (b) modül başına `Take` + yaklaşık
`TotalCount` (kullanıcıya yalan), (c) tek modül seçimini zorunlu kıl.
**`TotalCount`'un sözleşmedeki tanımı bu karara bağlı** → `06-sozlesme-taslak.md`'de açıkça yazılacak.

**2. Faz 1 iş biriminden HİÇBİR ŞEY beklemiyor — yalnız Selim'den 4 karar.**
`C-14` (`Data` yerleşimi) · `C-15` (kolon config yeri) · `M-02` (SubProduct eşlemesi) · `M-08` ("son aktif hareket").
Bunlardan üçü varsayımla geçilebilir (düşük/orta dönüş maliyeti), **`M-08` geçilemez** — yanlış varsayım
tüm durum türetmeyi bozar. Bu yüzden `İ-08`'de **tasarım yazılıp kodlama cevaba bırakılacak**.

---

## 🔵 YAPILIYOR

Yok. Kullanıcı `05-faz-plani.md`'yi gözden geçirecek, beğenmediği yerleri değiştirecek; sonra § A/§ B cevapları gelecek.

---

## ⬜ YAPILACAK

### Şimdi başlanabilir (hiçbir cevaba bağlı değil)

| İ | İş | Repo |
|---|---|---|
| **İ-01** | `F-13` Refit çağrısında bearer token taşınıyor mu (`Trex.FrameworkCommon/Api/RefitExtensions.cs`) | Web.UI |
| **İ-02** | `F-14` `General:AvailableModules` `IFrameworkParameterHelper` ile okunabiliyor mu | Web.UI |
| **İ-03** | `F-15` `ModuleConstants` karşılığı var mı | Web.UI |
| **İ-04** | `F-16` Refit **timeout** değeri | Web.UI |
| **İ-05** | `F-17` `Views/Shared/Components/{CashFlow,LimitCheck}/Default.cshtml` oku | Web.UI |
| **İ-06** | `F-18` `ManuelReescontApi` wrapper'ının içi | Web.UI |
| **İ-07** | **`06-sozlesme-taslak.md`** — `eligible-transactions` kesin, `executions` varyantlı, `TotalCount` R-13 notuyla | — |
| **İ-08** | MM durum türetme sorgusu **tasarımı** — M-08 için 3 alternatif + karşılaştırma tablosu | MM |

### 🔴 Kullanıcı kararı bekleyen

| # | Ne | Kim |
|---|---|---|
| 1 | `05-faz-plani.md`'yi gözden geçir, beğenmediğin yerleri söyle | Selim |
| 2 | **Faz 1'i açan 4 karar:** `C-14` · `C-15` · `M-02` · `M-08` (§ B'de öneriler yazılı) | Selim |
| 3 | `04-sorular.md` § A'yı iş birimine gönder (16 soru, 4'ü bloke eden) | Selim → iş birimi |
| 4 | § B'nin kalan 3 maddesi: `M-05` · `M-07` · `R-04` (Faz 2/3'ü etkiliyor, Faz 1'i **etkilemiyor**) | Selim |

### Faz 1 kodlama (İ-10…İ-45, 24 kalem — 4 karar sonrası)

MM okuma ucu (İ-10…15) · Web.UI sunucu katmanı (İ-20…27) · ViewComponent & Razor (İ-30…36) ·
base component JS (İ-40…45). Detay ve dosya listesi → `05-faz-plani.md` § 3.

### Faz 2 (İ-50…İ-64) — C-01/C-07/C-08 sonrası · Faz 3 (İ-70…76) · Faz 4 (İ-80…83) · Faz 5 (İ-90)

Detay → `05-faz-plani.md` § 4-7.

### Keşfedilen yan işler (devam)

| # | İş |
|---|---|
| 1 | ⚠️ `Treasy.MM.UI/.claude/settings.local.json`'a `SessionStart:compact` hook'unu **kullanıcı elle ekleyecek** (classifier engelledi) |
| 2 | `Treasy.MM.UI` dokümanları bayat: SharedDependency **1.0.3** yazıyor, gerçek **1.0.4-dev12** |
| 3 | `FIApi` / `WarrantApi` / `LimitApi` config key'leri var ama **backend repo'ları `repos/` altında yok** |
| 4 | Eski Fx ekranının **10 kusuru** (analiz-6 § 7) — düzeltilecek mi silinecek mi, **C-20**'ye bağlı |
| 5 | `Treasy.Shell` ile `NetTrex.Web.UI` ilişkisi net değil |
| 6 | ⚠️ Kullanıcının yarım kalan mesajı: *"dökümanda ki"* — devamı beklendi, cevap gelmedi |

---

## Kararlar bu turda

| Karar | Gerekçe |
|---|---|
| **Fazlandırma A/B bağımlılığına göre yapıldı** (6 faz) | Cevap beklemek işi tamamen durdurmasın; %70'i şimdi yapılabilir |
| **Faz 1'e aksiyon konmadı** (aksiyonsuz okuma ekranı) | C-01/07/08 aksiyonların **tamamını** belirliyor; varsayımla yazmak çöp iş olurdu |
| **Dikiş yerleri açık, davranış boş** | Cevap gelince tek noktada dolar; iki akışı paralel yazmak yasak |
| **`İ-08` tasarım olarak yazılacak, kodlanmayacak** | `M-08` yanlış varsayımı **tüm durum türetmeyi** bozar (yüksek dönüş maliyeti) |
| **Varsayımlar koda `// VARSAYIM: <soru-kodu>` yorumu olarak yazılacak** | `R-15` — cevap gelince grep'lenebilir olsun |
| `TotalCount` tanımı `R-13` kararına bağlanacak | Çok modüllü sayfalamada `TotalCount` anlamı değişir |
