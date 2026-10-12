# Aşama 2 özeti — yedek, yükleme onarımı, taşıma planı (2026-10-02)

Aşama 1 envanteri: 10 repoluk .NET treasury platformunda AI bağlam dosyaları ölçülmüştü.
Bu turda yedek alındı, yükleme zinciri onarıldı, taşıma planı yazıldı (uygulanmadı).
Yalnız sayı ve tespit. Token = `char/4` tahmini. Commit: 0. Silinen dosya: 0.

## 0. YEDEK

Zip `Desktop\_ai-md-yedek-2026-10-02.zip` · 11,14 MB · **579 dosya**.
Doğrulama: staging↔orijinal `diff -rq` fark yok · zip↔staging yol listesi fark yok ·
ham byte 19 277 324 = 19 277 324.
İlk zip `\` giriş adlarıyla üretildi (.NET Framework), `/` + UTF-8 ile yeniden üretildi.

Git: `repos\.ai-agent` (256 dosya) · `NetTrex.MM\.ai-agent` (163) · `Treasy.MM.UI\.ai-agent` (93),
branch `main`, remote 0. Dış repolarda `git status` 0 satır.
**Baseline commit kullanıcı tarafından ATILMADI** — 3 depo da boş; Bölüm 2 yine de uygulandı.
`NetTrex.MM/.claude/settings.local.json` dış MM reposunda **izleniyor** (gitignore etkisiz).

## 1. DOKÜMANDAN DOĞRULANANLAR (code.claude.com/docs)

| Konu | Doğrulanan |
|---|---|
| CLAUDE.md yükleme | "loads from your current working directory and every directory above it"; sıra kökten cwd'ye, **cwd'ye yakın olan son okunur** |
| `--add-dir` | "**By default, CLAUDE.md files from these directories are not loaded**"; opt-in: `CLAUDE_CODE_ADDITIONAL_DIRECTORIES_CLAUDE_MD` |
| `@import` göreli yol | "**resolve relative to the file containing the import**, not the working directory" |
| `@import` derinlik | "**maximum depth of four hops**" |
| `@import` dışarı | çalışma dizini dışına düşen import = external → **ilk seferde onay dialogu** |
| CLAUDE.md boyut | "target under **200 lines**"; "imports … **don't reduce its context cost**" |
| Skill keşfi | `~/.claude/skills/` · `.claude/skills/` **starting dir + every parent up to the repository root** · `--add-dir` dizinleri |
| Skill eksik SKILL.md | "**the skill folder doesn't load**" |
| Hook env | `CLAUDE_PROJECT_DIR` — **All hooks**, "project root where the session started" |
| Hook exit 1 | non-blocking; "stderr … reported as `<hook name> hook error` notice"; **"exit code 1 does NOT block"** |
| Hook exit 2 | PreCompact'te **compact'i engeller** |

Sonuç: `repos\.claude\skills\` bir repo içinden **yüklenmez** (repo kökünün üstünde kalıyor).

## 2. YAPILAN DEĞİŞİKLİKLER (18 dosya)

| # | Dosya | Ne değişti |
|---|---|---|
| 1 | `repos\CLAUDE.md` | 🆕 7 satır, yalnız `@.ai-agent/CLAUDE.md` |
| 2 | `repos\.ai-agent\CLAUDE.md` | 🆕 156 satır, arşivden (`Desktop\repo\CLAUDE.md`, 2026-08-13) |
| 3 | `repos\.claude\settings.json` | 🆕 PreCompact manual+auto, SessionStart:compact |
| 4 | `NetTrex.MM\CLAUDE.md` | 🆕 7 satır import |
| 5 | `NetTrex.MM\.ai-agent\CLAUDE.md` | 🆕 120 satır, arşivden (2026-08-28) |
| 6 | `NetTrex.MM\.claude\settings.local.json` | ♻️ hooks yenilendi, permissions korundu |
| 7 | `NetTrex.MM\.ai-agent\MEMORY.md` | ♻️ s.67 `Treasy-70`→`TREASY-49` |
| 8–11 | `NetTrex.MM\.claude\skills\{accounting-db-script,db-script,manuel-reeskont,mssql-read}\SKILL.md` | ♻️ gövde yolu `Treasy-70`→`TREASY-49` (skill'ler kırıktı) |
| 12 | `Treasy.MM.UI\CLAUDE.md` | ♻️ 147 satır → 7 satır import |
| 13 | `Treasy.MM.UI\.ai-agent\CLAUDE.md` | 🆕 147 satır, canlı içerikten |
| 14 | `Treasy.MM.UI\.claude\settings.local.json` | ♻️ hooks yenilendi + **SessionStart:compact eklendi** |
| 15 | `Treasy.MM.UI\.ai-agent\MEMORY.md` | ♻️ s.374 `Treasy-70`→`TREASY-49` |
| 16–18 | `outputs/2026-10-02-md-yapi-denetimi/02-*.md` | 🆕 3 rapor |

CLAUDE.md'lerde düzeltilen ölü yol türleri: `Treasy-70` kullanıcı dizini (7 satır) ·
`@.ai-agent/X` → `@X` (8 import) · `](.ai-agent/X)` → `](X)` (18 link) ·
`.ai-agent/manuel-reeskont/` → `feature-research/manuel-reeskont/` (2) ·
`../.ai-agent/` → `../../.ai-agent/` (1).
İçerik değiştirilmedi (ölü yol dışında).

Hook eski/yeni: sabit `C:/Users/Treasy-70/...` → `process.env.CLAUDE_PROJECT_DIR` +
iki aday yol (`<root>/.ai-agent/compacts/`, `<root>/../.ai-agent/compacts/`) ·
`catch{exit 0}` sessiz → `console.error(...)` + **exit 1** (görünür, engellemez).

Yan etki: `sed -i` MM MEMORY'yi CRLF→LF çevirdi (986 satır) → **geri alındı**, byte farkı 0.

## 3. DOĞRULAMA

### 3.1 Hook'lar çalıştırıldı

| Başlatma dizini | Olay | exit | JSON | additionalContext |
|---|---|---:|:--:|---:|
| repos | PreCompact | 0 | ✅ | 1 303 char |
| repos | SessionStart | 0 | ✅ | 897 char |
| NetTrex.MM | PreCompact | 0 | ✅ | 1 303 (yedek yol) |
| NetTrex.MM | SessionStart | 0 | ✅ | 897 (yedek yol) |
| Treasy.MM.UI | PreCompact | 0 | ✅ | 1 026 (kendi dosyası) |
| Treasy.MM.UI | SessionStart | 0 | ✅ | 897 (yedek yol) |
| sahte dizin | PreCompact | **1** | — | stderr uyarısı basıldı |
| sahte dizin | SessionStart | **1** | — | stderr uyarısı basıldı |

### 3.2 Yükleme zinciri — onarım sonrası

| Başlatma dizini | Dosya | Satır | ~Token (önce → sonra) | Bütçe 15k |
|---|---:|---:|---|---|
| `repos\` | 4 | 1 348 | 0 → **25 994** | ❌ +10 994 |
| `repos\.ai-agent` | 4 | 1 348 | 0 → **25 994** | ❌ +10 994 |
| `repos\NetTrex.MM` | 8 | 2 730 | 0 → **54 930** | ❌ +39 930 |
| `repos\Treasy.MM.UI` | 9 | 2 265 | 17 124 → **42 971** | ❌ +27 971 |
| `repos\NetTrex.Web.UI` | 4 | 1 348 | 0 → **25 994** | ❌ +10 994 |
| `repos\NetTrex.Common` | 4 | 1 348 | 0 → **25 994** | ❌ +10 994 |

Aşımın kaynağı 3 MEMORY: MM 22 534 · workspace 20 386 · MMUI 7 392 = **50 312 token**
(MM zincirinin %92'si). Kullanıcı kararıyla bu turda inceltilmedi.

### 3.3 Caveman hook'ları (ölçüldü, dokunulmadı)

| Hook | Olay | Boyut | Sıklık | ~Token |
|---|---|---:|---|---:|
| `caveman-activate.js` | SessionStart | 1 215 char düz metin | oturum başına 1 | ~304 |
| `caveman-mode-tracker.js` | UserPromptSubmit | ~121 char `additionalContext` | **her mesajda** | ~30 |


## 4. TAŞIMA PLANI — hedef bazında (203 girdi, uygulanmadı)

| Hedef | WS 74 | MM 79 | MMUI 50 | Toplam |
|---|---:|---:|---:|---:|
| Bulunduğu MEMORY'de kalır (kısaltılır) | 9 | 37 | 24 | 70 |
| `NetTrex.Web.UI/.ai-agent/MEMORY.md` 🆕 | 12 | 0 | 1 | 13 |
| `NetTrex.Common/.ai-agent/MEMORY.md` 🆕 | 1 | 0 | 0 | 1 |
| `reference/fimple.md` 🆕 | 4 | 5 | 0 | 9 |
| `reference/muhasebe-motoru.md` 🆕 | 4 | 7 | 0 | 11 |
| `NetTrex.Web.UI/.../reference/devextreme.md` 🆕 | 9 | 0 | 0 | 9 |
| `manuel-reeskont/13-tuzaklar.md` 🆕 | 9 | 0 | 0 | 9 |
| `Eximbank-tuzaklar.md` 🆕 | 1 | 17 | 0 | 18 |
| Skill `Gotcha` | 7 | 1 | 13 | 21 |
| `CLAUDE.md` Hard Rule | 11 | 3 | 2 | 16 |
| `screens/*` | 0 | 0 | 3 | 3 |
| `tools/` | 0 | 0 | 1 | 1 |
| Diğer MEMORY | 4 | 0 | 0 | 4 |
| 🔁 birleşir | 3 | 9 | 6 | 18 |
| **TOPLAM** | **74** | **79** | **50** | **203** |

Taşıma sonrası tahmin: WS-MEM 967→~190 satır · MM-MEM 987→~250 · MMUI-MEM 375→~150.
Oturum yükü: `repos\` ~10 300 ✅ · MM ~20 000 ❌ · MMUI ~20 400 ❌
(kalan aşım `PROJECT_CONTEXT.md` + `MIGRATION.md`, bu planın kapsamı dışında).

Birleştirilecek mükerrer küme: **10**. En büyüğü tercih dörtlüsü (3 MEMORY'de de var, 12 girdi → 4).
`feature-research/sql-log/` mükerrer ağacı: 21 md · 745 295 char · ~186 300 token;
`_index.md`'ler birleştirilir, eski ağaç `_arsiv/` altına taşınır (silinmez).

## 5. KARARSIZ KALINAN / KULLANICI KARARI BEKLEYEN

| # | Konu |
|---|---|
| 1 | Workspace `CLAUDE.md` **Hard Rule 12 kayıp**. `WS-MEM:284` "HR12'ye taşındı (2026-09-04)" diyor, arşiv sürümü 2026-08-13 ve 11 kural içeriyor. Özeti kurtarıldı (`NetTrex.MM/.ai-agent/outputs/2026-08-31-Eximbank-Teslim/3-Senior-Kod-Incelemesi.md:1757`: kayıt damgası `IDateTimeProvider`, iş günü `GetLogicalDateAsync()`, dış sözleşme `DateOnly`). **Tam metin yok** — yeniden yazılsın mı? |
| 2 | Arşiv repo haritasında diskte **olmayan 7 repo** (`NetTrex.InvFund`, `Treasy.Shell`, `Treasy.MicroUI.Packages`, `Treasy.MicroUI.Base`, `Treasy.OptionsFX.UI`, `Treasy.MicroUI.Deriv`, `PlayWright`); **eksik** `Treasy.Common.UI`; `NetTrex.Web.UI` için "Kendi CLAUDE.md'si ✅" yanlışı — düzeltilsin mi? |
| 3 | `NetTrex.MM/.ai-agent/CLAUDE.md`: "En son oturum arşivi `SessionStart` hook'u ile otomatik enjekte edilir" — **böyle bir hook yok** (yalnız `compact` var). Hook kurulsun mu, cümle mi silinsin? |
| 4 | `repos\PlayWright` / `repos\Playwrite` **diskte yok**; 2 MEMORY girdisi kullanıcı adı düzeltildikten sonra da ölü klasörü gösteriyor. Klasör nerede? |
| 5 | Workspace skill'leri `repos\.claude\skills\`'ten **yüklenemez** (doküman: repository root'a kadar). `~/.claude/skills/` mi, her repoya wrapper kopyası mı? |
| 6 | `NetTrex.MM/.claude/settings.local.json` dış repoda izleniyor → hook değişikliği MM `git status`'ünde görünüyor. `git rm --cached` yapılsın mı? |
| 7 | Repo içinden başlatılan ilk oturumda workspace importu için **external import onay dialogu** çıkacak — bir kez onaylanması gerekiyor. |

## 6. TESPİT EDİLEMEYENLER

- `repos\PlayWright` klasörünün bugünkü yeri.
- Workspace Hard Rule 12'nin tam metni (yalnız özeti kurtarıldı).
- `NetTrex.MM/CLAUDE.md`'nin canlı repodan ne zaman silindiği.
- Gerçek tokenizer ile token sayımı (tümü `char/4`).
- External-import onay dialogunun gerçekten çıkıp çıkmadığı (yeni oturum gerektirir).
