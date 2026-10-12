# 02 — Yedek, Yükleme Onarımı ve Taşıma Planı (Aşama 2/N)

> **Tarih:** 2026-10-02 · 1. aşama: [`01-envanter.md`](01-envanter.md) · Taşıma tablosu: [`02-tasima-plani.md`](02-tasima-plani.md)
> **Bu turda:** yedek alındı · git depoları kuruldu · yükleme zinciri onarıldı · taşıma planı **yalnız yazıldı, uygulanmadı**.
> **Commit atılmadı. Hiçbir dosya silinmedi.**

---

# BÖLÜM 1 — YEDEK

## 1.1 Zip

`C:\Users\TREASY-49\Desktop\_ai-md-yedek-2026-10-02.zip` · **11,14 MB · 579 dosya**

| Kaynak | Dosya |
|---|---:|
| `repos\.ai-agent\` | 256 |
| `NetTrex.MM\.ai-agent\` | 163 |
| `NetTrex.MM\.claude\` | 7 |
| `Treasy.MM.UI\.ai-agent\` | 93 |
| `Treasy.MM.UI\.claude\` | 11 |
| `Treasy.MM.UI\CLAUDE.md` | 1 |
| `~/.claude/settings.json` | 1 |
| `~/.claude/projects/*/memory/` (2 proje) | 18 |
| `Desktop\repo\` — 6 `CLAUDE.md` (tüm derinlik) + 4 `.claude\` klasörü (23 dosya) | 29 |
| **TOPLAM** | **579** |

### Doğrulama — üç kademe

| Kademe | Yöntem | Sonuç |
|---|---|---|
| staging ↔ orijinal | `diff -rq` (5 ağaç) + `cmp` (2 tekil dosya) | **fark yok** |
| zip ↔ staging | yol listesi `Compare-Object` | **fark yok** |
| zip ↔ staging | ham byte toplamı | **19 277 324 = 19 277 324** |

⚠️ **İlk üretilen zip bozuktu ve yeniden üretildi.** `ZipFile::CreateFromDirectory` .NET Framework 4.x
altında giriş adlarını `\` ile yazıyor; ZIP spec `/` ister ve bazı araçlar klasör yapısını okuyamaz.
Zip, `ZipArchive` + açık `CreateEntryFromFile` ile `/` ve UTF-8 ad kodlamasıyla yeniden üretildi
(Türkçe klasör adları için gerekli: `Örnek_Scriptler`, `MicroUI-yapısının…`).

## 1.2 Yerel git depoları

| Klasör | Branch | Remote | İzlenecek dosya | Diskteki dosya |
|---|---|---:|---:|---:|
| `repos\.ai-agent` | `main` | 0 | 256 | 256 |
| `NetTrex.MM\.ai-agent` | `main` | 0 | 163 | 163 |
| `Treasy.MM.UI\.ai-agent` | `main` | 0 | 93 | 93 |

**İç içe depo dış repoyu etkilemiyor — doğrulandı:**

- `repos\` git reposu **değil** (`git rev-parse` → `fatal: not a git repository`) → `repos\.ai-agent` için dış repo yok.
- `NetTrex.MM/.gitignore:274` → `.ai-agent/` · `Treasy.MM.UI/.gitignore:167` → `.ai-agent/`;
  `git check-ignore -v` ikisini de doğruladı.
- `git init` sonrası her iki dış repoda `git status --porcelain` → **0 satır**.

🔴 **İstisna — `NetTrex.MM/.claude/settings.local.json` dış MM reposunda İZLENİYOR.**
`git ls-files .claude` bunu gösteriyor. `.gitignore`'da `.claude/` yazması etkisiz: gitignore
zaten izlenen dosyaya işlemez. Bu turda o dosyanın `hooks` bölümü değiştirildi (§2.4) →
**MM'in `git status`'ünde değişmiş görünecek.** `Treasy.MM.UI`'de hiçbir şey izlenmiyor, sorun yok.

## 1.3 Baseline commit — ❌ ATILMADI

Kullanıcı "devam" dediğinde üç depoda da commit yoktu:

```
fatal: your current branch 'main' does not have any commits yet   (3 deponun hepsinde)
```

Bölüm 2 yine de uygulandı; geri dönüş yolu olarak **zip yedeği** ve ek olarak
değiştirilen 5 dosyanın ayrı kopyası alındı:

```
<scratchpad>/bolum2-oncesi/
├── Treasy.MM.UI-CLAUDE.md
├── NetTrex.MM-settings.local.json
├── Treasy.MM.UI-settings.local.json
├── NetTrex.MM-MEMORY.md
└── Treasy.MM.UI-MEMORY.md
```

---

# BÖLÜM 2 — YÜKLEME ONARIMI

## 2.1 Resmi dokümantasyondan doğrulananlar

Kaynak: **code.claude.com/docs** (`docs.claude.com/en/docs/claude-code/*` buraya 301 yönleniyor).

### (1) `CLAUDE.md`'nin üst dizinlerden yüklenmesi

> "Claude Code loads `CLAUDE.md` and `CLAUDE.local.md` from your current working directory and
> every directory above it. Run Claude Code in `foo/bar/` and it loads instructions from
> `foo/bar/CLAUDE.md`, `foo/CLAUDE.md`, and any `CLAUDE.local.md` files alongside them."
> — [code.claude.com/docs/en/memory § How CLAUDE.md files load](https://code.claude.com/docs/en/memory)

> "All discovered files are concatenated into context rather than overriding each other. Across the
> directory tree, content is ordered from the filesystem root down to your working directory …
> **instructions closer to where you launched Claude are read last**."
> — aynı bölüm

✅ **Tasarım kararı doğrulandı:** `repos\CLAUDE.md` üst dizin olduğu için her repodan başlatılan
oturumda yüklenir; repo `CLAUDE.md`'si **sonra** okunur, yani çakışmada repo katmanı daha ağır basar.

> "Claude also discovers `CLAUDE.md` and `CLAUDE.local.md` files in subdirectories under your current
> working directory. Instead of loading them at launch, they are included when Claude reads files in
> those subdirectories."

→ `repos\`'tan başlatılan bir oturumda `NetTrex.MM\CLAUDE.md` **başlangıçta yüklenmez**, ancak
Claude o alt dizinde bir dosya okuduğunda devreye girer.

### (2) `--add-dir` / additional working directory

> "The `--add-dir` flag gives Claude access to additional directories outside your main working
> directory. **By default, CLAUDE.md files from these directories are not loaded.**"
> "To also load memory files from additional directories, set the
> `CLAUDE_CODE_ADDITIONAL_DIRECTORIES_CLAUDE_MD` environment variable."
> "This loads `CLAUDE.md`, `.claude/CLAUDE.md`, `.claude/rules/*.md`, and `CLAUDE.local.md` from the
> additional directory."

✅ 1. aşama tespiti doğrulandı. ⚠️ Bu env var **açılmamalı**: açılırsa bu oturumdaki 11 additional
directory'nin `CLAUDE.md`'leri de yüklenir ve token yükü katlanır.

### (3) `@import` çözümü ve derinlik

> "Both relative and absolute paths are allowed. **Relative paths resolve relative to the file
> containing the import, not the working directory.** Imported files can recursively import other
> files, with a **maximum depth of four hops**."

> "Import parsing skips Markdown code spans and fenced code blocks."

> "An import in a project-level memory file is **external** when its path resolves outside your
> working directory… The first time Claude Code encounters external imports in a project, it shows
> an approval dialog listing the files."

✅ Yeni desen bu kurallara göre kuruldu:
`repos\CLAUDE.md` (hop 0) → `@.ai-agent/CLAUDE.md` (hop 1) → `@MEMORY.md` (hop 2). **Limit 4, kullanılan 2.**
⚠️ `NetTrex.MM`'den başlatılan bir oturumda `repos\CLAUDE.md`'nin importu çalışma dizininin
**dışına** düşer → Claude Code **bir kez onay dialogu** gösterecek. Reddedilirse workspace katmanı
sessizce yüklenmez.

> "**Size**: target under 200 lines per CLAUDE.md file… **Imports help you organize a long file but
> don't reduce its context cost, because imported files also load at launch.**"

⚠️ Kullanıcının "asıl içerik `.ai-agent/CLAUDE.md`'de yaşasın" kararı **token tasarrufu sağlamaz** —
kazanç yalnızca versiyonlanabilirliktir. Bu dokümanda açıkça yazıyor.

### (4) Skill keşif konumları

> "**Parent directories**: Claude Code loads project skills from `.claude/skills/` in the starting
> directory and **every parent directory up to the repository root**."
> "**Additional directories**: `--add-dir` or `/add-dir` loads skills from that directory's `.claude/skills/`"
> "Personal: `~/.claude/skills/<skill-name>/SKILL.md` — All your projects on this machine"
> "**If SKILL.md is missing**: The skill folder doesn't load."
> "**Description only**: All skill descriptions are loaded into context automatically… truncated at
> **1,536 characters**. **Full body**: Loads only when invoked."
> — [code.claude.com/docs/en/skills](https://code.claude.com/docs/en/skills)

⚠️ **Sonuç:** "repository root"a kadar çıkıldığı için `repos\.claude\skills\` bir repo içinden
(`NetTrex.MM` kendi başına bir git reposu) **yüklenmez**. Workspace skill'lerinin her repoda
görünmesinin tek garantili yolu `~/.claude/skills/` (personal scope) veya her repoya wrapper kopyası.
Şu an çalışmasının sebebi: `NetTrex.MM` additional working directory olarak ekli.

### (5) Hook ortam değişkenleri

> | `CLAUDE_PROJECT_DIR` | **All hooks** | Project root where the session started. Remains constant even when Claude enters a worktree |
> — [code.claude.com/docs/en/hooks](https://code.claude.com/docs/en/hooks)

> **Exit Code 2** — "Blocking error… `PreCompact`: blocks compaction"
> **Other Non-Zero Exit Codes** — "Non-blocking error. **Action: Proceeds with the action.**
> Stdout/stderr: Reported as `<hook name> hook error` notice with the first line of stderr"
> "**Important**: Exit code 1 does NOT block by default. Use exit code 2 to enforce policy."

✅ Bu, kullanıcının istediği davranışın tam karşılığı: **exit 1** = görünür uyarı + compact engellenmez.

> `PreCompact` matcher: `manual` | `auto`
> `SessionStart` matcher: `startup` | `resume` | `clear` | `compact` | `fork`
> `additionalContext` — "Size limit: 10,000 characters per field"

## 2.2 (a) Arşiv ↔ bugünkü yapı karşılaştırması

### Workspace `Desktop\repo\CLAUDE.md` (156 satır, 2026-08-13)

| # | Fark | İşlem |
|---|---|---|
| 1 | `C:\Users\Treasy-70\source\repos` (s.3) | ✅ **düzeltildi** → `TREASY-49` |
| 2 | `@.ai-agent/PROJECT_CONTEXT.md` · `@.ai-agent/MEMORY.md` | ✅ **düzeltildi** → `@PROJECT_CONTEXT.md` · `@MEMORY.md` (dosya artık `.ai-agent/` içinde) |
| 3 | 9 markdown link hedefi `](.ai-agent/…)` | ✅ **düzeltildi** → `](…)` |
| 4 | `.ai-agent/manuel-reeskont/00-PANO.md` — klasör taşınmış | ✅ **düzeltildi** → `feature-research/manuel-reeskont/00-PANO.md` (2 yer: link hedefi + link metni) |
| 5 | Repo haritasında **`repos\` altında olmayan 7 repo**: `NetTrex.InvFund`, `Treasy.Shell`, `Treasy.MicroUI.Packages`, `Treasy.MicroUI.Base`, `Treasy.OptionsFX.UI`, `Treasy.MicroUI.Deriv`, `PlayWright` | ⬜ **dokunulmadı** — içerik; "ölü yol" değil |
| 6 | Repo haritasında **eksik**: `Treasy.Common.UI` (diskte var) | ⬜ dokunulmadı |
| 7 | `NetTrex.Web.UI` satırında "Kendi CLAUDE.md'si ✅" — dosya yok | ⬜ dokunulmadı |
| 8 | `ai-agent-context-kit` "Diğer" tablosunda — gerçek yeri `Desktop\repo\` | ⬜ dokunulmadı |
| 9 | 🔴 **Hard Rule 12 YOK** — arşivde 11 kural var | ⬜ **içerik eklenmedi** — bkz. §2.7 |

### `Desktop\repo\NetTrex.MM\CLAUDE.md` (120 satır, 2026-08-28)

| # | Fark | İşlem |
|---|---|---|
| 1 | `C:\Users\Treasy-70\source\repos\CLAUDE.md` | ✅ düzeltildi |
| 2 | `@.ai-agent/…` importları | ✅ düzeltildi |
| 3 | `](.ai-agent/…)` link hedefleri (4 yer) | ✅ düzeltildi |
| 4 | `[mssql-read](../.ai-agent/skills/mssql-read.md)` — dosya bir seviye derinleşti | ✅ düzeltildi → `../../.ai-agent/skills/mssql-read.md` |
| 5 | "En son oturum arşivi `SessionStart` hook'u ile otomatik enjekte edilir" — **MM'de `SessionStart:startup` hook'u yok** (yalnız `compact` var) | ⬜ dokunulmadı — yanlış bilgi, kullanıcı kararı gerekir |
| 6 | s.9 yazım hatası: "açıkça **mmdbelirt**" | ⬜ dokunulmadı |
| 7 | MM'in Hard Rule 12'si = "testler gözden geçirilir" (workspace HR 12'den farklı konu) | — bilgi notu |

### `Treasy.MM.UI/CLAUDE.md` (canlı, 147 satır)

| # | Fark | İşlem |
|---|---|---|
| 1 | "İlgili Repolar" tablosunda **5 satır** `C:\Users\Treasy-70\…` | ✅ düzeltildi |
| 2 | `@.ai-agent/PROJECT_CONTEXT.md` · `MIGRATION.md` · `MEMORY.md` | ✅ düzeltildi |
| 3 | `](.ai-agent/…)` link hedefleri (5 yer) | ✅ düzeltildi |
| 4 | Tablodaki `Treasy.OptionsFX.UI` ve `Treasy.MicroUI.Base` **diskte yok** | ⬜ dokunulmadı |
| 5 | Hard Rule 13 (`InterbankLoan:Enabled`) **mevcut** — `WS-MEM:26`'nın referansı geçerli | ✅ doğrulandı |

## 2.3 (a,b) Yeni yapı — 6 dosya

| Dosya | Durum | Satır | İçerik |
|---|---|---:|---|
| `repos\CLAUDE.md` | 🆕 **oluşturuldu** | 7 | yalnız `@.ai-agent/CLAUDE.md` |
| `repos\.ai-agent\CLAUDE.md` | 🆕 **oluşturuldu** | 156 | arşivden, ölü yollar düzeltilmiş |
| `NetTrex.MM\CLAUDE.md` | 🆕 **oluşturuldu** | 7 | yalnız `@.ai-agent/CLAUDE.md` |
| `NetTrex.MM\.ai-agent\CLAUDE.md` | 🆕 **oluşturuldu** | 120 | arşivden, ölü yollar düzeltilmiş |
| `Treasy.MM.UI\CLAUDE.md` | ♻️ **üzerine yazıldı** | 147 → 7 | yalnız `@.ai-agent/CLAUDE.md` |
| `Treasy.MM.UI\.ai-agent\CLAUDE.md` | 🆕 **oluşturuldu** | 147 | canlı içerik, ölü yollar düzeltilmiş |

Kök dosyaların gövdesi (üçü de aynı desen):

```markdown
# CLAUDE.md — <ad>

<!-- Asil icerik .ai-agent/CLAUDE.md'dedir; bu dosya yalniz onu import eder.
     Boylece <workspace|repo> kurallari .ai-agent git deposunda versiyonlanir. -->

@.ai-agent/CLAUDE.md
```

> Blok HTML yorumu bilinçli: *"Block-level HTML comments in CLAUDE.md files are stripped before the
> content is injected into Claude's context"* — bakımcıya not, token maliyeti yok.

## 2.4 (c) Hook onarımı

### Önce — üç kusur

1. **Yol ölü:** `C:/Users/Treasy-70/...` — o kullanıcı dizini makinede yok.
2. **Hata sessiz:** `catch(e){process.exit(0)}` — exit 0, çıktı yok, uyarı yok.
3. **MMUI'de `SessionStart:compact` eksik**, workspace'te hiçbir hook yok.

### Sonra — yeni hook gövdesi

```js
const fs=require('fs'),p=require('path');
const a=process.argv.slice(1),n=a[0],ev=a[1],msg=a[2];
const r=process.env.CLAUDE_PROJECT_DIR||process.cwd();
const c=[p.join(r,'.ai-agent','compacts',n),p.join(r,'..','.ai-agent','compacts',n)];
let t=null;for(const f of c){try{t=fs.readFileSync(f,'utf8');break}catch(e){}}
if(t===null){console.error('['+ev+' hook] talimat dosyasi bulunamadi: '+n+' | bakilan: '+c.join(' ; '));process.exit(1)}
process.stdout.write(JSON.stringify({systemMessage:msg,hookSpecificOutput:{hookEventName:ev,additionalContext:t}}))
```

| Değişiklik | Gerekçe |
|---|---|
| Sabit kullanıcı yolu → `process.env.CLAUDE_PROJECT_DIR` | doküman: "All hooks · Project root where the session started" |
| `process.cwd()` yedeği | env var yoksa çalışmaya devam eder |
| İki aday yol: `<root>/.ai-agent/compacts/` → `<root>/../.ai-agent/compacts/` | MM'in kendi `_precompact-instruction.md`'si yok; workspace'inkine düşüyor — **dosya kopyalamadan tek kaynak** |
| `exit 0` sessiz → `console.error(...)` + `exit 1` | doküman: exit 1 non-blocking, stderr ilk satırı `hook error` olarak gösterilir; **compact engellenmez** (yalnız exit 2 engeller) |
| `args` dizisine dosya adı + olay + mesaj parametre olarak | tek gövde, üç repo, iki olay |

### Üç dosyada yapılan

| Dosya | Önce | Sonra |
|---|---|---|
| `repos\.claude\settings.json` | 🆕 **yoktu** | `PreCompact:manual` + `PreCompact:auto` + `SessionStart:compact` |
| `NetTrex.MM\.claude\settings.local.json` | 3 hook (ölü yol) | 3 hook (onarıldı) · `permissions` **korundu** |
| `Treasy.MM.UI\.claude\settings.local.json` | 2 hook (ölü yol) | 3 hook — **`SessionStart:compact` eklendi** · `permissions` **korundu** |

### Hook'lar gerçekten çalıştırıldı — sonuçlar

| Başlatma dizini | Olay | exit | JSON | `additionalContext` |
|---|---|---:|:--:|---:|
| `repos` | PreCompact | 0 | ✅ | 1 303 char |
| `repos` | SessionStart | 0 | ✅ | 897 char |
| `NetTrex.MM` | PreCompact | 0 | ✅ | 1 303 char *(yedek yoldan — workspace dosyası)* |
| `NetTrex.MM` | SessionStart | 0 | ✅ | 897 char *(yedek yol)* |
| `Treasy.MM.UI` | PreCompact | 0 | ✅ | 1 026 char *(kendi dosyası)* |
| `Treasy.MM.UI` | SessionStart | 0 | ✅ | 897 char *(yedek yol)* |
| **sahte dizin** (hata yolu) | PreCompact | **1** | — | stderr: `[PreCompact hook] talimat dosyasi bulunamadi: _precompact-instruction.md \| bakilan: …` |
| **sahte dizin** | SessionStart | **1** | — | stderr: `[SessionStart hook] talimat dosyasi bulunamadi: _postcompact-instruction.md \| bakilan: …` |

## 2.5 (d) Ölü `Treasy-70` yolları

⚠️ **Düzeltme:** 1. aşama raporunda "MEMORY'lerde 3 ölü yol" yazmıştım. Gerçek sayı **2**:

| Dosya:satır | Yol | İşlem |
|---|---|---|
| `NetTrex.MM/.ai-agent/MEMORY.md:67` | `C:\Users\Treasy-70\source\repos\Playwrite` | ✅ `TREASY-49` |
| `Treasy.MM.UI/.ai-agent/MEMORY.md:374` | `C:\Users\Treasy-70\source\repos\PlayWright` | ✅ `TREASY-49` |

🔴 **Ama hedef hâlâ yok:** `repos\PlayWright` ve `repos\Playwrite` klasörlerinin **ikisi de diskte
mevcut değil**. Arşivde `Desktop\repo\PlayWright\` var. Yani bu iki girdi kullanıcı adı düzeldikten
sonra da ölü referans — klasörün nereye taşındığı **tespit edilemedi**.

### Kapsam dışı bırakılmayan ek onarım: kırık skill wrapper'ları

Denetim sırasında bulundu — **skill'leri fiilen kırıyordu**:

| Dosya | Satır | Önce | Sonra |
|---|---:|---|---|
| `NetTrex.MM/.claude/skills/accounting-db-script/SKILL.md` | 16 | `C:\Users\Treasy-70\…\accounting-db-script.md` | ✅ `TREASY-49` |
| `NetTrex.MM/.claude/skills/db-script/SKILL.md` | 17 | `…\db-script.md` | ✅ |
| `NetTrex.MM/.claude/skills/manuel-reeskont/SKILL.md` | 20 | `…\manuel-reeskont.md` | ✅ |
| `NetTrex.MM/.claude/skills/mssql-read/SKILL.md` | 15 | `…\mssql-read.md` | ✅ |

Bu dört wrapper, skill gövdesinin **mutlak yolunu** gösteriyordu. Yol ölü olduğu için skill
tetiklendiğinde gövde dosyası okunamıyordu. `yuk-testi` zaten `TREASY-49` kullanıyordu.
Dört hedefin de artık var olduğu doğrulandı (`.ai-agent/skills/*.md`).
`Treasy.MM.UI` wrapper'ları **göreli yol** kullanıyor — hiç etkilenmemişler.

### Diğer `Treasy-70` izleri — **dokunulmadı**

19 dosyada daha geçiyor: `compacts/`, `feature-research/`, `progress/`, `outputs/` altındaki
tarihsel kayıtlar + `outputs/.../scripts/*.py` + `MODULE-CREATION-GUIDE.md` + `START-HERE.md` +
`Treasy.MM.UI/.ai-agent/inventory/`, `mm-microui-phase-docs/`, `tools/`.
Bunlar tarihsel/arşiv içerik; onarım kapsamı dışında bırakıldı.

### Yan etki — fark edildi ve geri alındı

`sed -i` `NetTrex.MM/.ai-agent/MEMORY.md`'nin satır sonlarını **CRLF→LF**'e çevirdi (986 satır).
Fark edildi, dosya CRLF'e geri döndürüldü; **byte farkı 0**. Normalize edilmiş karşılaştırmada
iki dosya arasındaki **tek içerik farkı** istenen `Treasy-70 → TREASY-49` satırı.
`Treasy.MM.UI/.ai-agent/MEMORY.md` zaten LF'ti, etkilenmedi.

## 2.6 (e) Caveman hook'ları — ölçüm (dokunulmadı)

`~/.claude/settings.json` içindeki iki hook gerçekten çalıştırılıp çıktıları ölçüldü:

| Hook | Olay | Enjekte edilen | Boyut | Sıklık | ~Token |
|---|---|---|---:|---|---:|
| `caveman-activate.js` | `SessionStart` (matcher yok → tüm kaynaklar) | düz metin — "CAVEMAN MODE ACTIVE — level: full" + Persistence / Rules / Auto-Clarity / Boundaries bölümleri | **1 215 char** | oturum başına 1 | **~304** |
| `caveman-mode-tracker.js` | `UserPromptSubmit` | JSON `additionalContext`: *"CAVEMAN MODE ACTIVE (full). Drop articles/filler/pleasantries/hedging. Fragments OK. Code/commits/security: write normal."* | **~121 char** | **her kullanıcı mesajında** | **~30** |

Doküman: `SessionStart` ve `UserPromptSubmit` exit-0 stdout'u *"plain-text stdout added as context
Claude can see"* — yani ikisi de gerçekten bağlama giriyor.

**Toplam maliyet:** oturum açılışında ~304 token sabit + her kullanıcı mesajında ~30 token.
40 mesajlık bir oturumda ≈ **1 500 token**. Dosya yapısı yükünün yanında ihmal edilebilir.
**Kullanıcı isteği gereği dokunulmadı.**

## 2.7 Kararsız kaldığım / kullanıcı kararı bekleyen noktalar

| # | Konu | Durum |
|---|---|---|
| 1 | 🔴 **Workspace Hard Rule 12 kayıp.** `WS-MEM:284` *"Tarih kaynağı kuralı CLAUDE.md Hard Rule 12'ye TAŞINDI (2026-09-04)"* diyor, ama arşiv sürümü 2026-08-13 tarihli ve yalnız 11 kural içeriyor. Kuralın özü başka bir dosyadan kurtarıldı: `NetTrex.MM/.ai-agent/outputs/2026-08-31-Eximbank-Teslim/3-Senior-Kod-Incelemesi.md:1757` → *"kayıt damgası `IDateTimeProvider`, iş günü `GetLogicalDateAsync()`, dış sözleşmede `DateOnly`. Provider'ın TZ problemini çözmediği ölçümü de kuralın içinde."* **Tam metin kayıp.** | ⬜ *"içeriği başka şekilde değiştirme"* talimatı gereği **eklenmedi**. Yeniden yazılsın mı? |
| 2 | Arşiv repo haritasındaki 7 olmayan repo + eksik `Treasy.Common.UI` + `NetTrex.Web.UI` "CLAUDE.md'si ✅" yanlışı | ⬜ dokunulmadı — düzeltilsin mi? |
| 3 | MM CLAUDE.md'deki *"En son oturum arşivi `SessionStart` hook'u ile otomatik enjekte edilir"* — böyle bir hook **yok** | ⬜ dokunulmadı — hook kurulsun mu, cümle mi silinsin? |
| 4 | `repos\PlayWright` klasörü diskte yok; iki MEMORY girdisi hâlâ ölü klasörü gösteriyor | ⬜ klasör nerede? |
| 5 | Workspace skill'leri `repos\.claude\skills\` üzerinden **yüklenemez** (doküman: "up to the repository root"). Kalıcı çözüm `~/.claude/skills/` veya her repoya wrapper kopyası | ⬜ hangisi? |
| 6 | `NetTrex.MM/.claude/settings.local.json` dış repoda izleniyor → hook değişikliği MM'in `git status`'ünde görünür | ⬜ `git rm --cached` ile takipten çıkarılsın mı? |
| 7 | İlk oturumda workspace importu için **external import onay dialogu** çıkacak (repo içinden başlatıldığında) | ℹ️ bilgi — bir kez onaylanmalı |

## 2.8 (f) Doğrulama — yükleme zinciri ve token

`@import`'lar resmi kurala göre çözülerek (göreli yol = import eden dosyaya göre, kod bloğu/backtick
atlanır, max 4 hop) hesaplandı.

### Zincirler

**`repos\`** (ve `repos\.ai-agent`, `NetTrex.Web.UI`, `NetTrex.Common` — hepsi aynı):
```
CLAUDE.md                        7 satır ·    217 char · ~54 tok
└─ .ai-agent/CLAUDE.md         157 satır ·  9 166 char · ~2 292 tok
   ├─ .ai-agent/PROJECT_CONTEXT.md  217 satır · 13 046 char · ~3 262 tok
   └─ .ai-agent/MEMORY.md          967 satır · 81 545 char · ~20 386 tok
TOPLAM: 4 dosya · 1 348 satır · 103 974 char · ~25 994 tok
```

**`repos\NetTrex.MM`:**
```
CLAUDE.md → .ai-agent/CLAUDE.md → PROJECT_CONTEXT + MEMORY        (workspace, ~25 994 tok)
NetTrex.MM/CLAUDE.md               7 satır ·    196 char ·    ~49 tok
└─ NetTrex.MM/.ai-agent/CLAUDE.md  121 satır ·  8 267 char · ~2 067 tok
   ├─ …/PROJECT_CONTEXT.md         267 satır · 17 149 char · ~4 287 tok
   └─ …/MEMORY.md                  987 satır · 90 135 char · ~22 534 tok
TOPLAM: 8 dosya · 2 730 satır · 219 721 char · ~54 930 tok
```

**`repos\Treasy.MM.UI`:**
```
workspace zinciri                                                  (~25 994 tok)
Treasy.MM.UI/CLAUDE.md               7 satır ·    198 char ·    ~50 tok
└─ …/.ai-agent/CLAUDE.md           148 satır · 10 069 char · ~2 517 tok
   ├─ …/PROJECT_CONTEXT.md         157 satır ·  9 179 char · ~2 295 tok
   ├─ …/MIGRATION.md               230 satır · 18 899 char · ~4 725 tok
   └─ …/MEMORY.md                  375 satır · 29 566 char · ~7 392 tok
TOPLAM: 9 dosya · 2 265 satır · 171 885 char · ~42 971 tok
```

### Özet ve bütçe

| Başlatma dizini | Önce (1. aşama) | Sonra | Bütçe 15 000 |
|---|---:|---:|---|
| `repos\` | 0 | **25 994** | ❌ **+10 994** |
| `repos\.ai-agent` | 0 | **25 994** | ❌ +10 994 |
| `repos\NetTrex.MM` | 0 | **54 930** | ❌ **+39 930** |
| `repos\Treasy.MM.UI` | 17 124 | **42 971** | ❌ **+27 971** |
| `repos\NetTrex.Web.UI` | 0 | **25 994** | ❌ +10 994 |
| `repos\NetTrex.Common` | 0 | **25 994** | ❌ +10 994 |

🔴 **Bütçe her dizinde aşılıyor.** Kullanıcı kararı gereği MEMORY'ler bu turda inceltilmedi
(*"bilgi kaybetmektense geçici token maliyetini kabul ediyorum"*).

**Aşımın kaynağı — üç MEMORY dosyası:**

| Dosya | ~Token | Aşımdaki payı |
|---|---:|---|
| `NetTrex.MM/.ai-agent/MEMORY.md` | 22 534 | MM zincirinin **%41'i** |
| `repos/.ai-agent/MEMORY.md` | 20 386 | her zincirde sabit yük |
| `Treasy.MM.UI/.ai-agent/MEMORY.md` | 7 392 | MMUI zincirinin %17'si |
| **toplam MEMORY** | **50 312** | MM zincirinin **%92'si** |

Bölüm 3 planı uygulandığında tahmini düşüş: `repos\` ~10 300 ✅ · `NetTrex.MM` ~20 000 ·
`Treasy.MM.UI` ~20 400 (ayrıntı: [`02-tasima-plani.md`](02-tasima-plani.md) § D.3).

⚠️ Not: `~/.claude/projects/.../memory/` auto-memory katmanı bu hesaba **dahil değil**
(2 499 char index + 14 dosya; doküman: *"Loaded into: Every session (first 200 lines or 25KB)"*).
Caveman hook'u da dahil değil (~304 tok açılış + ~30 tok/mesaj).

### Değiştirilen dosyaların tam listesi

| # | Dosya | İşlem |
|---|---|---|
| 1 | `repos\CLAUDE.md` | 🆕 oluşturuldu |
| 2 | `repos\.ai-agent\CLAUDE.md` | 🆕 oluşturuldu (arşivden) |
| 3 | `repos\.claude\settings.json` | 🆕 oluşturuldu (hook) |
| 4 | `NetTrex.MM\CLAUDE.md` | 🆕 oluşturuldu |
| 5 | `NetTrex.MM\.ai-agent\CLAUDE.md` | 🆕 oluşturuldu (arşivden) |
| 6 | `NetTrex.MM\.claude\settings.local.json` | ♻️ `hooks` değişti, `permissions` korundu |
| 7 | `NetTrex.MM\.ai-agent\MEMORY.md` | ♻️ s.67 ölü yol |
| 8 | `NetTrex.MM\.claude\skills\accounting-db-script\SKILL.md` | ♻️ s.16 ölü yol |
| 9 | `NetTrex.MM\.claude\skills\db-script\SKILL.md` | ♻️ s.17 ölü yol |
| 10 | `NetTrex.MM\.claude\skills\manuel-reeskont\SKILL.md` | ♻️ s.20 ölü yol |
| 11 | `NetTrex.MM\.claude\skills\mssql-read\SKILL.md` | ♻️ s.15 ölü yol |
| 12 | `Treasy.MM.UI\CLAUDE.md` | ♻️ 147 satır → 7 satırlık import |
| 13 | `Treasy.MM.UI\.ai-agent\CLAUDE.md` | 🆕 oluşturuldu (canlı içerikten) |
| 14 | `Treasy.MM.UI\.claude\settings.local.json` | ♻️ `hooks` değişti + `SessionStart:compact` eklendi |
| 15 | `Treasy.MM.UI\.ai-agent\MEMORY.md` | ♻️ s.374 ölü yol |
| 16–18 | 3 rapor dosyası (`outputs/2026-10-02-md-yapi-denetimi/02-*.md`) | 🆕 |

**Silinen dosya: 0 · Commit: 0**

---

# BÖLÜM 3 — TAŞIMA PLANI

Tam eşleme tablosu ayrı dosyada: [`02-tasima-plani.md`](02-tasima-plani.md).

## 3.1 Hedef bazında özet (203 girdi)

| Hedef | Workspace 74 | MM 79 | MMUI 50 | Toplam |
|---|---:|---:|---:|---:|
| Bulunduğu MEMORY'de kalır (kısaltılarak) | 9 | 37 | 24 | **70** |
| `NetTrex.Web.UI/.ai-agent/MEMORY.md` 🆕 | 12 | 0 | 1 | **13** |
| `NetTrex.Common/.ai-agent/MEMORY.md` 🆕 | 1 | 0 | 0 | **1** |
| `reference/fimple.md` 🆕 | 4 | 5 | 0 | **9** |
| `reference/muhasebe-motoru.md` 🆕 | 4 | 7 | 0 | **11** |
| `NetTrex.Web.UI/.ai-agent/reference/devextreme.md` 🆕 | 9 | 0 | 0 | **9** |
| Özellik klasörü — `manuel-reeskont/13-tuzaklar.md` 🆕 | 9 | 0 | 0 | **9** |
| Özellik klasörü — `Eximbank-tuzaklar.md` 🆕 | 1 | 17 | 0 | **18** |
| Skill `Gotcha` bölümü | 7 | 1 | 13 | **21** |
| `CLAUDE.md` Hard Rule'a terfi | 11 | 3 | 2 | **16** |
| `screens/*` | 0 | 0 | 3 | **3** |
| `tools/` | 0 | 0 | 1 | **1** |
| Diğer MEMORY'ye taşınır | 4 | 0 | 0 | **4** |
| 🔁 başka girdiyle birleşir | 3 | 9 | 6 | **18** |
| **TOPLAM** | **74** | **79** | **50** | **203** ✅ |

## 3.2 Birleştirilecek 10 mükerrer küme

Ayrıntı: `02-tasima-plani.md` § D.2. Önemli olanlar:

- **Tercih dörtlüsü** (solo geliştirici / Türkçe / commit kullanıcıda / büyük çıktı dosyaya)
  üç MEMORY'de de var → **12 girdi, 4 kalacak**.
- `AccEntryEntity already being tracked` iki girdi: biri **çürütülen** teşhis.
  Birleşmede çürütülen hipotez **silinmiyor** — "neden bu değil" kaydı bir sonraki araştırmayı kısaltır.
- `baseUrl → moduleCode` aynı dosyada **birebir iki kez** (s.93, s.105).

## 3.3 `feature-research/sql-log/` mükerrer ağacı

21 md · 745 295 char · ~186 300 token. 10 iş klasörü byte-birebir aynı, 3 iş yalnız yeni konumda,
`_index.md` iki yerde farklı. Plan: `_index.md`'ler **birleştirilir** (çakışan satırda her iki metin
de korunur), eski ağaç `_arsiv/2026-10-02-sql-log-eski-konum/` altına **taşınır — silinmez**.
Ayrıntı: `02-tasima-plani.md` § E.

## 3.4 Uygulama sırası

Yeni hedef dosyaları önce **oluştur**, içeriği **kopyala**, doğrula; MEMORY'lerden kısaltma
**en sonda**. Ayrıntı: `02-tasima-plani.md` § F.

---

## Tespit edilemeyenler

- `repos\PlayWright` / `repos\Playwrite` klasörünün bugünkü yeri (arşivde `Desktop\repo\PlayWright\` var).
- Workspace `CLAUDE.md` Hard Rule 12'nin **tam metni** (yalnız özeti kurtarıldı).
- `NetTrex.MM/CLAUDE.md`'nin canlı repodan ne zaman silindiği.
- Gerçek tokenizer ile token sayımı — tüm sayılar `char/4` tahmini.
- İlk oturumda external-import onay dialogunun gerçekten çıkıp çıkmadığı (yeni oturum gerektirir).
