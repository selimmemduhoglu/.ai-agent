# Compact 1 — md yapı denetimi (2026-10-02 … 2026-10-05)

> Sohbet: `.ai-agent/` md yapısının denetimi, onarımı ve eksik repolara yayılması.
> Çıktılar: `.ai-agent/outputs/2026-10-02-md-yapi-denetimi/` (01-envanter, 01-ozet, 02-onarim-ve-plan, 02-tasima-plani, 02-ozet)

## Kullanıcının kendi kelimeleriyle ne istedi

- **Aşama 1 (envanter):** *"mevcut yapıyı hiçbir bilgi kaybetmeden daha iyi hale getirmek ve eksik repolara aynı kalitede yapı kurmak"*. Ölç, dosya oluşturma/değiştirme/silme yok.
- **Aşama 2:** yedek + git init + yükleme onarımı + taşıma planı. *"Commit atma. Silme yapma."*
- **Aşama 3 (bu tur):** *"benim sana söylediğim projelerde MD dosyaları var ve bazılarında da yok bunlara da ekleme yapalım dedim ve bunların md yapısı aynı mimaride ve aynı mantıkta olsun."*
- 🔑 **Asıl amaç (kullanıcı açıkladı):** *"ben md dosyalarımı projelerde değiştirdim baya ve bazı isteklerim acaba çalışmıyor ve benim md dosyalarımın içeriğini daha performanslı ve eksiksiz bir şekilde yapman için uğraşıyorum."* Claude app ile bu oturum arasında köprü oluyordu.
- 🔴 **Commit kuralı (tekrar teyit):** *"sen hiçbir modülde commit atma bana bırak"* · MD'ler hiçbir projede commit edilmiyor, local'de kalıyor.

## Kullanıcının verdiği kararlar

| Karar | İçerik |
|---|---|
| Oturum başlatma | Çalışılan reponun klasöründen; `repos\CLAUDE.md` workspace katmanını, repo `CLAUDE.md`'si repo katmanını yükler |
| CLAUDE.md deseni | Asıl içerik `<klasör>\.ai-agent\CLAUDE.md`'de (versiyonlansın diye); kök `CLAUDE.md` yalnız `@.ai-agent/CLAUDE.md` satırı |
| Token bütçesi | Hedef ~15k; aşım kabul — *"bilgi kaybetmektense geçici token maliyetini kabul ediyorum"* |
| Kapsam (AskUserQuestion) | **4 seçeneğin hepsi**: denetim + küçük eksikler + Web.UI/Common kurulumu + 203 girdilik taşıma |
| Hard Rule 12 + repo haritası | *"İkisini de tamamla"* — yazdıklarımı ayrıca göster |
| Skill erişimi | **`~/.claude/skills/`** (personal scope) |

## Aşama 1 — en kritik bulgular

1. Canlıda tek `CLAUDE.md` `Treasy.MM.UI`'de → workspace `PROJECT_CONTEXT.md` (217 satır) + `MEMORY.md` (967 satır) **hiçbir oturumda yüklenmiyordu**.
2. Kayıp `CLAUDE.md`'ler `C:\Users\TREASY-49\Desktop\repo\` arşivinde: workspace (156 satır, 2026-08-13), `NetTrex.MM` (120 satır, 2026-08-28), `NetTrex.WEbUI` (110 satır, 2026-08-13). `Treasy-70` → `TREASY-49` kullanıcı dizini taşımasından kalma.
3. Tüm compact hook'ları ölü (`C:/Users/Treasy-70/...`, `catch{exit 0}` sessiz) → **2026-08-17'den beri hiç compact yazılmamış**.
4. Workspace `MEMORY.md`'nin **%32'si Web.UI'ye ait** — yanlış katmanda. 203 girdinin tamamı etiketlendi.
5. `NetTrex.Web.UI` + `NetTrex.Common`: hiçbir AI dokümanı yok. README'leri Azure DevOps TODO şablonu.
6. `feature-research/sql-log/` = `sql-log/`'un eski tam kopyası (21 md · 745 295 char · ~186 300 tok).
7. "CommonUI" sorusunun cevabı: ayrı repo **`Treasy.Common.UI`** (frontend), `NetTrex.Common` (backend) ile karıştırılmamalı.

## Aşama 2 — yapılanlar

Yedek: `Desktop\_ai-md-yedek-2026-10-02.zip` · 579 dosya · 3 kademe doğrulandı (byte toplamı 19 277 324 = 19 277 324).
⚠️ İlk zip `\` giriş adlarıyla üretildi (.NET Framework `ZipFile::CreateFromDirectory` davranışı) → `/` + UTF-8 ile yeniden üretildi.

Git: 3 `.ai-agent` deposu `git init` (branch `main`, remote 0). **Kullanıcı baseline commit atmadı** — 3 depo da 0 commit.

18 dosya değişti. Yükleme zinciri kuruldu (6 `CLAUDE.md`), hook'lar onarıldı (3 settings), ölü yollar düzeltildi (4 SKILL.md + 2 MEMORY).

## Dokümandan doğrulananlar (code.claude.com/docs)

- CLAUDE.md: *"loads from your current working directory and every directory above it"*; sıra kökten cwd'ye, **cwd'ye yakın son okunur**.
- `--add-dir`: *"By default, CLAUDE.md files from these directories are **not loaded**"*; opt-in `CLAUDE_CODE_ADDITIONAL_DIRECTORIES_CLAUDE_MD`.
- `@import`: *"resolve relative to the file containing the import"*, **max 4 hop**, code span/fence atlanır, çalışma dizini dışı = **external → onay dialogu**.
- CLAUDE.md boyut: *"target under 200 lines"*; *"imports … **don't reduce its context cost**"*.
- Skill keşfi: `~/.claude/skills/` · `.claude/skills/` **starting dir + every parent up to the repository root** · `--add-dir` dizinleri. Eksik `SKILL.md` → *"the skill folder doesn't load"*. Precedence **Enterprise > Personal > Project**.
- Hook: `CLAUDE_PROJECT_DIR` **all hooks**. **exit 1 = non-blocking**, stderr ilk satırı `hook error` olarak gösterilir; **exit 2 PreCompact'i engeller**.

🔑 Sonuç: `repos\.claude\skills\` bir repo içinden **yüklenmez** (repo kökünün üstünde kalıyor) → `~/.claude/skills/` seçildi.

## Aşama 3 — bu turda yapılanlar (devam ediyor)

| # | İş | Durum |
|---|---|---|
| 1 | Workspace `CLAUDE.md` repo haritası: **Klon** sütunu eklendi, olmayan 7 repo `❌` işaretlendi (silinmedi), `Treasy.Common.UI` eklendi, `PlayWright`/`ai-agent-context-kit` gerçek konumları yazıldı | ✅ |
| 2 | **Hard Rule 12 yeniden yazıldı** (kayıptı). 3 madde: kayıt damgası `IDateTimeProvider` · iş günü `GetLogicalDateAsync()` (provider TZ'yi çözmüyor, ölçüldü) · dış sözleşme `DateOnly` (STJ ISO-8601 + offset gün kayması). HTML yorumuyla "yeniden yazıldı, orijinal birebir değil" notu düşüldü | ✅ |
| 3 | `~/.claude/skills/` kuruldu: 5 wrapper kopyalandı + `release-note` wrapper'ı sıfırdan yazıldı (hiç yoktu) | ✅ **canlı doğrulandı** — `release-note` harness skill listesinde belirdi |
| 4 | MM'in **10 boş skill klasörü** dolduruldu (önceki raporda 9 demiştim, gerçek 10). Göreli yol `.ai-agent/skills/<ad>.md` kullanıldı — mutlak yol bir daha kırılmasın | ✅ |
| 5 | MM'e `START-HERE.md` (165 satır) — Katman A/B/C okuma sırası, iş tipine göre ilk durak tablosu | ✅ |
| 6 | `NetTrex.Web.UI` yapısı: `CLAUDE.md` (13 HR) + `PROJECT_CONTEXT.md` + `MEMORY.md` + `START-HERE.md` + `skills/_index.md` + `reference/devextreme.md` + 6 iskelet dosyası + hook | ✅ |
| 7 | `NetTrex.Common` yapısı: `CLAUDE.md` (12 HR) + `PROJECT_CONTEXT.md` + `MEMORY.md` + `START-HERE.md` + `skills/_index.md` + 6 iskelet dosyası + hook | ✅ |
| 8 | 203 girdilik MEMORY taşıması | ⏳ **sıradaki tur** |
| 9 | `sql-log` mükerrer birleştirmesi | ⏳ |

### 🔴 Bu turda ortaya çıkan kritik olay — MM hook'u GERİ ALINDI

Kullanıcı MM'de branch değiştirdi (`main-issuebond-feature-removed` → `main`, son commit `38199f65f`
"Merged PR 12778"). `NetTrex.MM/.claude/settings.local.json` **dış repoda izlendiği** için git onu
repo sürümüyle **ezdi** → hook yolu tekrar `C:/Users/Treasy-70/...` oldu, onarım kayboldu.
Yeniden uygulandı. **Her branch değişiminde tekrar olacak.**
✅ Tek kalıcı çözüm: `git -C NetTrex.MM rm --cached .claude/settings.local.json` (dosya diskte kalır).

### Web.UI / Common için alınan teknik karar

İki repoda da `.ai-agent/` **`.gitignore`'da yoktu** → yeni dosyalar git'e girecekti.
`.gitignore` **değiştirilmedi** (repo dosyası, commit'lenir). Bunun yerine
**`.git/info/exclude`** kullanıldı (local, commit'lenmez): `.ai-agent/` · `.claude/` · `CLAUDE.md` · `AGENTS.md`.
`git check-ignore` ile doğrulandı — hiçbir AI dosyası `git status`'te görünmüyor.

### Doğrulamalar (canlı)

- `~/.claude/skills/` kurulumu: `release-note` + 8 MM skill'i **harness skill listesinde belirdi** → personal scope çalışıyor.
- Hook testi **5 repo × 2 olay = 10 kombinasyon**: hepsi exit 0 + geçerli JSON + dolu `additionalContext`
  (`repos`/`MM`/`Web.UI`/`Common` 1303ch yedek yoldan · `Treasy.MM.UI` 1026ch kendi dosyasından · SessionStart 897ch).
- Yükleme zinciri (char/4): `repos` ~26 584 · `MM` ~55 767 · `Treasy.MM.UI` ~43 562 ·
  **`Web.UI` ~31 532** · **`Common` ~31 213**. Workspace `MEMORY.md` (20 386) her zincirde sabit yük —
  aşımın kaynağı hâlâ o.

## Açık / kullanıcıya sorulmuş ama cevaplanmamış

| # | Konu |
|---|---|
| 1 | `NetTrex.MM/.claude/settings.local.json` **dış MM reposunda izleniyor** (gitignore öncesi commit'lenmiş). Hook değişikliğim `git status`'te ` M` olarak duruyor. `git rm --cached` yapılsın mı? |
| 2 | MM CLAUDE.md'si *"en son oturum arşivi SessionStart hook'u ile enjekte edilir"* diyor — **öyle bir hook yok**. Kurulsun mu, cümle mi silinsin? |
| 3 | `repos\PlayWright` diskte yok (arşivde `Desktop\repo\PlayWright\`). 2 MEMORY girdisi hâlâ ölü klasörü gösteriyor |
| 4 | Repo içinden ilk oturumda **external import onay dialogu** çıkacak — bir kez onaylanmalı, reddedilirse workspace katmanı sessizce yüklenmez |
| 5 | Kullanıcının son mesajında **5. madde boş kaldı** |

## Ölçümler (char/4 tahmini)

Onarım sonrası oturum yükü: `repos\` ~25 994 · `NetTrex.MM` ~54 930 · `Treasy.MM.UI` ~42 971 ·
`NetTrex.Web.UI` / `NetTrex.Common` / `.ai-agent` ~25 994. Aşımın %92'si 3 MEMORY (toplam 50 312 tok).
Caveman hook'u: SessionStart 1 215 char (~304 tok, oturum başına) + UserPromptSubmit ~121 char (~30 tok, **her mesajda**).

## Komutlar / olaylar

- `git init -b main` × 3 (`.ai-agent` klasörleri) — remote eklenmedi
- Hook testi: 3 repo × 2 olay = 6 kombinasyon exit 0 + geçerli JSON; sahte dizinde exit 1 + görünür stderr
- `sed -i` yan etkisi: MM `MEMORY.md` CRLF→LF oldu (986 satır) → **geri alındı**, byte farkı 0
- Hook gövdesinde kaçış hatası: heredoc `'\\n'` gerçek satır sonuna dönüştü → `console.error` ile çözüldü
