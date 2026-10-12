# CLAUDE.md — Treasy / NetTrex Workspace

Bu dosya **workspace katmanıdır** — `C:\Users\TREASY-49\source\repos` altındaki **tüm** repoları kapsar.
Cwd hangi repo olursa olsun bu dosya (üst dizin olduğu için) **otomatik yüklenir**.

**Kullanıcı:** Selim Memduhoğlu — Treasury platformunu solo geliştiriyor.
Ben burada senior bir .NET + TypeScript geliştiricisi gibi davranırım: önce anlar, plan sunar, sonra yazarım.

Genel mimari ve cross-repo hafıza aşağıdaki import'larla otomatik yüklenir:

@PROJECT_CONTEXT.md
@MEMORY.md

> **Katman ayrımı:** Bu dosya **cross-repo** kuralları taşır. Bir repoya özel kurallar (build komutu,
> o repodaki pattern'ler, o repoya özel Hard Rule'lar) **o reponun kendi `CLAUDE.md`'sindedir** ve
> cwd o repo olduğunda ayrıca yüklenir. İkisi çakışırsa **repo-özel kural kazanır**.

> **Yeni oturuma başlarken** → [`.ai-agent/START-HERE.md`](START-HERE.md)

---

## Repo Haritası

Detaylı mimari (portlar, bağlantı topolojisi, hangi modül nerede) → [`.ai-agent/PROJECT_CONTEXT.md`](PROJECT_CONTEXT.md)

> **Klon** sütunu bu makinedeki durumu gösterir. `repos\` altında **olmayan** bir repo platformda vardır
> ama burada klonlu değildir — oradaki bir dosyaya referans verirken bunu hesaba kat, **tahmin etme**.

### Backend (modül API'leri)

| Repo | Modül | Klon | `CLAUDE.md` |
|------|-------|:----:|:-----------:|
| `NetTrex.MM` | Money Market + InterbankLoan + IssueBond | ✅ | ✅ |
| `NetTrex.Fx` | FX + PM (kıymetli maden) | ✅ | ⬜ |
| `NetTrex.Common` | Ortak/referans veri, menü, parametre, SWIFT + 4 DB projesi (`TrexCommon`, `TrexFramework`, `TrexFI`, `TaoBase_Net`) | ✅ | ✅ |
| `NetTrex.Accounting` | Muhasebe motoru | ✅ | ⬜ |
| `NetTrex.OptionsFX` | FX Opsiyon | ✅ | ⬜ |
| `NetTrex.DerivSwp` | Türev / Swap | ✅ | ⬜ |
| `NetTrex.InvFund` | Yatırım Fonu | ❌ | — |

### UI

| Repo | Ne | Klon | `CLAUDE.md` |
|------|----|:----:|:-----------:|
| `NetTrex.Web.UI` | **Monolit UI** (`Trex.WebUI`) — tüm modüllerin ekranları | ✅ | ✅ |
| `Treasy.MM.UI` | MM Micro UI | ✅ | ✅ |
| `Treasy.Common.UI` | **Ortak Micro UI** — Micro UI'lerin paylaştığı UI katmanı | ✅ | ⬜ |
| `Treasy.Shell` | Micro UI **host** — YARP reverse proxy + HTML rewrite | ❌ | — |
| `Treasy.MicroUI.Packages` | `SharedDependency` (RCL) + 12 npm paketi (`@treasy/*`) | ❌ | — |
| `Treasy.MicroUI.Base` | Micro UI iskeleti + sıfırdan kurma rehberi | ❌ | — |
| `Treasy.OptionsFX.UI` | OptionsFX Micro UI (ilk örnek, pattern referansı) | ❌ | — |
| `Treasy.MicroUI.Deriv` | Deriv Micro UI | ❌ | — |

### Diğer

| Repo | Ne | Klon |
|------|----|:----:|
| `PlayWright` | E2E test paketi (Playwright/TypeScript) | ❌ — `repos\` altında **yok**; arşiv kopyası `C:\Users\TREASY-49\Desktop\repo\PlayWright\` |
| `ai-agent-context-kit` | Bu md metodolojisinin kaynağı — konvansiyon değişikliği önce buraya | ❌ `repos\` altında değil → `C:\Users\TREASY-49\Desktop\repo\ai-agent-context-kit\` |

---

## Cross-Repo Hard Rule'lar

Repo-özel Hard Rule'lara **ek**tir; ihlal edilmez.

1. **Dil:** Türkçe yanıt; teknik terimler (Controller, Handler, Refit, ViewComponent, Entity, DI) İngilizce kalır.
2. **Önce plan, sonra kod.** Mimari/yıkıcı değişikliklerde planı göster, **onay bekle**; rutin işlerde makul kararları kendin ver.
3. **Financial precision:** para → `decimal` zorunlu, `float`/`double` **yasak**. Yuvarlama repo-özel helper ile.
4. **Fimple hassasiyet kuralları:** ThirdParty olan Fimple'a giden değerlerde noktadan sonra hassasiyet kuralları var —
   geliştirme yaparken bu kurallar **okunur** ve **gerekliyse** değerler round edilir.
5. **Git:** kullanıcı onayı olmadan commit/push **yok**; kullanıcı commit'i kendisi yapar — **önerme**.
6. **Küçük değişiklik → yalnız değişen bloğu düzenle.** Tüm dosyayı yeniden yazma.
7. **Asla tarama:** `bin/`, `obj/`, `.vs/`, `.sonarlint/`, `node_modules/`, `TestResults/`, `dist/`, `wwwroot/bundles/`.
8. **Emin değilsen dur, sor — uydurma.** Bir katmanda/repoda bir şey bulamadıysan **"tespit edilmedi"** diye açıkça yaz.
9. 🔴 **Cross-repo değişiklikte etki zincirini yaz.** Bir sözleşme (endpoint, model, enum, paket sürümü) değişiyorsa
   **hangi repoların** etkilendiğini değişiklikten **önce** listele. Tek repoda derlenen bir değişiklik diğerini sessizce kırabilir.
10. 🔴 **Kod değişince İLGİLİ TESTLER GÖZDEN GEÇİRİLİR — istisnasız.** Davranış eklerken/değiştirirken/silerken:
    testi **var mı** bak → varsa **güncelle** → yoksa ve davranış **karar taşıyorsa** (dallanma, guard,
    hesap, sözleşme maddesi) **yaz** → **çalıştır ve sonucu raporla**.
    ⚠️ **Yeşil kalan bayat test, testsizlikten daha tehlikelidir.** Kasıtlı yazmıyorsan **açıkça söyle**.
11. 🔴 **Compact özeti DİSKE yazılır — SOHBET BAŞINA KLASÖR.**
    **Yol:** `<repo>/.ai-agent/compacts/<chat-slug>/compact-<n>.md`
    **Akış:** klasör **var mı** bak → **varsa** en büyük `n`'i bul, **`n+1` ile YENİ dosya** aç (öncekilere
    **dokunma**) → **yoksa** klasörü aç + `_chat.md` + `compact-1.md`. Sonra `_index.md`'ye satır.
    **Ne zaman:** (a) **PROAKTİF** — bağlam ~%70 veya uzun işe girmeden önce, `/compact`'i **bekleme**;
    (b) `PreCompact` hook hatırlatır; (c) `SessionStart:compact` hook'u sıkıştırmadan **hemen sonra**
    tetikler — **o turda başka işe başlamadan yaz**, özet o an context'te.
    Format ve şablon → [`.ai-agent/compacts/_index.md`](compacts/_index.md).
    **Neden:** sıkıştırma anına tepki vermek güvenilmez — kural o anda gözden kaçan ilk şey oluyor.
    Nitekim 2026-08-12'ye kadar `NetTrex.MM`'de hiç hook kurulu olmadığı için **hiçbir compact yazılmadı**;
    2026-08-17 — 2026-10-02 arasında da hook yolları ölü olduğu için **hiçbir repoda compact yazılmadı**.
<!-- HR 12 (2026-09-04'te eklenmişti) 2026-10-02'de yeniden yazıldı: arşiv kopyası 2026-08-13 tarihli
     olduğu için kuralın orijinal metnini taşımıyordu. Kaynaklar: MEMORY.md s.284 (ölçüm) ·
     NetTrex.MM/.ai-agent/outputs/2026-08-31-Eximbank-Teslim/3-Senior-Kod-Incelemesi.md § I.6 (kuralın özeti) ·
     MEMORY.md s.174 (STJ DateTime ölçüm matrisi). Orijinal ifade birebir değildir. -->
12. 🔴 **Tarih kaynağı — üç ayrı karar, üç ayrı mekanizma.**
    - **Kayıt damgası** (`CreateDate`, `UpdateDate` gibi) → `IDateTimeProvider`. `DateTime.Now` / `DateTime.Today` **yazma**.
    - **İş günü kararı** (vade, valör, "geçmiş/gelecek tarih" reddi) → **`GetLogicalDateAsync()`**.
      ⚠️ `DateTimeProvider.GetCurrentDateTime()` **ölçüldü**: `DateTime.Now` ile **birebir aynı**, `Kind = Local`.
      Yani provider TZ problemini **çözmüyor** — UAE (+04) gibi kurulumlarda gün kayar.
      TZ'den bağımsız gün gerekiyorsa `GetLogicalDateAsync()` **zorunlu**, provider yetmez.
    - **Dış sözleşmede tarih alanı** → **`DateOnly`**. `System.Text.Json` `DateTime`'ı yalnız ISO 8601 kabul eder;
      `04.09.2026` / `2026.09.04` / `2026-9-4` **400** verir ve istek `Mediator`'a hiç ulaşmaz (hata sözlüğümüz devreye girmez).
      Offset'li gönderimde STJ sunucu yerel saatine çevirir → **gün sessizce kayar**. `DateOnly` saat/offset/nokta
      biçimlerinin **hepsini** reddeder, yalnız `yyyy-MM-dd` geçer. `DateOnly?` + zorunluluk kontrolü **birlikte**
      kullanılır (gönderilmezse `default` = `0001-01-01`).
    **Emsal:** MM Manuel Reeskont validator'ü `DateTime.Today` ile "future date" reddi yapıyordu → `IIBUAE-886` (UAE kurulumu).

---

## Aktif Cross-Repo İşler

| İş | Kapsadığı repolar | Pano |
|----|-------------------|------|
| **Manuel Reeskont — generic base component** | **Faz 1:** `NetTrex.Web.UI` + `NetTrex.MM` · **Faz 2:** `NetTrex.Fx` (+FI, InvFund) · **Faz 3:** `Treasy.MicroUI.Packages` + MicroUI'ler | [`.ai-agent/feature-research/manuel-reeskont/00-PANO.md`](feature-research/manuel-reeskont/00-PANO.md) |

> 🔴 **Manuel Reeskont'ta `NetTrex.Common` KULLANILMIYOR** (kullanıcı kararı 2026-08-12 → `ADR-MR-015`).
> Ekran WebUI'da, **WebUI Controller'dan modül API'lerine (MM/Fx/FI/InvFund) DİREKT** gidiliyor.
> Önceki "Common'a git, oradan modüllere dağıt" kararı **iptal**. Common'ın DailyFlow V2 fan-out deseni
> (`ADR-WS-001`) platformun geçerli deseni olarak duruyor — ama **bu iş onu kullanmıyor**.
> Faz 3'e kadar **MicroUI ve paket projelerine de dokunulmuyor**.

> 🔴 **ColManagement (eski adı Collateral) modülü — geliştirme/review öncesi MD'LER OKUNUR.**
> Kullanıcı bu modülle ilgili bir iş istediğinde, koda/script'e dokunmadan **önce**:
> 1. [`.ai-agent/feature-research/ColManagement-Feature/02-DURUM.md`](feature-research/ColManagement-Feature/02-DURUM.md)
>    — 🔴 **nerede kaldık**, hangi faz, ne bloke, kullanıcının kendi sözleri
> 2. [`00-YOL-HARITASI.md`](feature-research/ColManagement-Feature/00-YOL-HARITASI.md) — iş ne, fazlar, değişmez kurallar
> 3. İlgili [`fazlar/faz-N-*.md`](feature-research/ColManagement-Feature/fazlar/) — o fazın adımları ve tuzakları
> 4. Faz dosyasının *"Önce oku"* bölümündeki **1-2** bilgi dosyası
>
> ⚠️ [`bilgi-bankasi/`](feature-research/ColManagement-Feature/bilgi-bankasi/) **on dosyadır, hepsini birden okuma**
> — token israfı. Hangi işte hangisi gerektiği `00-INDEX.md`'de tablo hâlinde.
> 🔴 **Modül adı `ColManagement`** (2026-10-08 son karar). Repo adları hâlâ `*.Collateral` — kullanıcı rename edecek.
> 🔴 **"compact" denince ÖNCE `02-DURUM.md` güncellenir**, sonra `compacts/<chat-slug>/compact-<n>.md`.

> Bir iş **birden fazla repoya** dokunuyorsa panosu **buraya** açılır (`.ai-agent/<is-adi>/`), tek repoya
> dokunuyorsa o reponun kendi `.ai-agent/`'ında kalır.

---

## Skill'ler

Cross-repo prosedürler → [`.ai-agent/skills/_index.md`](skills/_index.md)
Repo-özel skill'ler o reponun `.claude/skills/`'inde (ör. `NetTrex.MM`: `entity-creator`, `batch-item-creator`, `code-reviewer`, `feature-researcher`, …).

Skill tetiklendiğinde dosyayı oku ve adımları **eksiksiz** uygula — kısaltma/atlama yok.

### 🔵 Kod/doküman yetmiyorsa → `mssql-read`

Bir davranışı koddan **kesin** çıkaramıyorsan (kolon gerçekten doluyor mu, durum nasıl türüyor, trigger neyi
taşıyor, bu senaryo canlıda hiç oluşmuş mu) **tahmin etme** — [`mssql-read`](skills/mssql-read.md)
skill'i ile veritabanına **salt-okunur** bak.

🔴 **YALNIZCA `SELECT`.** INSERT/UPDATE/DELETE/EXEC/DDL **yasak**. Her sorgu **`TOP (20)` + `ORDER BY Id DESC`**,
`SELECT *` yok. Yazma gerekiyorsa SQL `.ai-agent/outputs/`'a yazılır, **kullanıcı uygular**.

🔴 **DENETİM KAYDI ZORUNLU:** DB'ye giden **istisnasız her sorgu** (başarısızlar dahil) →
`.ai-agent/sql-log/<chat-slug>/01-sorgular.md` (çalıştırmadan **önce**) + `02-ciktilar.md` (çıktı gelince).
Parola maskelenir. `<chat-slug>` = `compacts/` ile aynı. **Kullanıcı DB erişimini bu dosyalardan denetliyor.**

---

## Değişiklik Sonrası — MD Görevleri

| Olay | Ne yapılır |
|------|-----------|
| **Anlamlı bir iş bitti/ilerledi** (cross-repo iş) | `.ai-agent/<is-adi>/progress/` altına **YENİ NUMARALI** dosya + `_index.md`'ye satır. **Önceki dosyaları asla düzenleme/silme.** |
| **Cross-repo mimari değişti** (yeni repo, port, paket sürümü, sözleşme, topoloji) | `.ai-agent/PROJECT_CONTEXT.md` |
| **Yeni karar / tuzak / tercih** (cross-repo) | `.ai-agent/MEMORY.md` — promotion rule dosyanın başında |
| **Tek repoya özel** her şey | O reponun kendi `.ai-agent/`'ı |
| **Bağlam ~%70** VEYA `/compact` VEYA sıkıştırma sonrası ilk tur | Hard Rule 10 → `compacts/<chat-slug>/compact-<n>.md` (**yeni** numaralı dosya) |
| **Oturum kapanışı** ("bitti/kaydet/özet/arşivle") | `.ai-agent/sessions/` — onay beklemeden. Session dosyalarını **silme** (kullanıcı siler). |

---

## Çalışma Alanları

| Klasör | Ne için |
|--------|---------|
| [.ai-agent/START-HERE.md](START-HERE.md) | Yeni session açılış protokolü — okuma sırası, "nerede kaldık" |
| [.ai-agent/PROJECT_CONTEXT.md](PROJECT_CONTEXT.md) | **Genel mimari** — repo topolojisi, portlar, hangi modül nasıl kullanılır, ADR'ler |
| [.ai-agent/MEMORY.md](MEMORY.md) | Cross-repo karar / tuzak / tercih (inbox — promotion rule geçerli) |
| [.ai-agent/feature-research/manuel-reeskont/](feature-research/manuel-reeskont/) | Aktif cross-repo iş: analiz + mimari + sözleşme + progress |
| [.ai-agent/skills/](skills/) | Cross-repo prosedürler |
| [.ai-agent/compacts/](compacts/) | Sıkıştırma öncesi detay kurtarma (komut, hatanın aynısı, karar gerekçesi). **Yeni oturumda ve sıkıştırma sonrasında OKUNUR** — kullanıcının kendi kelimeleriyle ne istediği burada |
| [.ai-agent/sql-log/](sql-log/_index.md) | 🔴 **DB erişim denetim kaydı** — sohbet başına klasör, istisnasız her sorgu + çıktısı |
| [.ai-agent/sessions/](sessions/) | Oturum kapanış arşivleri |
| [.ai-agent/imports/](imports/) | Kullanıcının cross-repo analiz için bıraktığı dosyalar |
| [.ai-agent/outputs/](outputs/) | Büyük çıktılar — sohbete basmak yerine buraya yaz, yolu bildir |
