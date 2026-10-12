# AI md yapısı — envanter özeti (2026-10-02)

10 repoluk .NET treasury platformu. `ai-agent-context-kit` deseni: `CLAUDE.md`=Rules ·
`PROJECT_CONTEXT.md`=Architecture · `MEMORY.md`=Experience · `progress/`+`compacts/`+`sessions/`=History.
Yalnız sayı ve tespit. Token = `char/4` tahmini.

## A. YAPI

### A1 Üç `.ai-agent/` ağacı
| Kök | .md | Satır | Char | ~Token |
|---|---:|---:|---:|---:|
| `repos/.ai-agent/` (workspace) | 177 | 52 438 | 3 273 362 | ~818 300 |
| `NetTrex.MM/.ai-agent/` | 74 | 21 703 | 1 243 563 | ~310 900 |
| `Treasy.MM.UI/.ai-agent/` | 89 | 13 179 | 744 255 | ~186 100 |
| TOPLAM | 340 | 87 320 | 5 261 180 | ~1 315 300 |

### A2 Kit bileşeni × repo
| Kit bileşeni | repos/.ai-agent | NetTrex.MM | Treasy.MM.UI | NetTrex.Web.UI | NetTrex.Common |
|---|:--:|:--:|:--:|:--:|:--:|
| `CLAUDE.md` | YOK | YOK | VAR 147 satır | YOK | YOK |
| `AGENTS.md` | YOK | YOK | YOK | YOK | YOK |
| `.claude/settings*.json` | YOK | VAR | VAR | YOK | YOK |
| `.claude/skills/*/SKILL.md` | YOK | 6/15 dolu | 10/10 dolu | YOK | YOK |
| `START-HERE.md` | VAR 120 | YOK | VAR 100 | YOK | YOK |
| `PROJECT_CONTEXT.md` | VAR 217 | VAR 267 | VAR 157 | YOK | YOK |
| `MEMORY.md` | VAR 967 | VAR 987 | VAR 375 | YOK | YOK |
| `progress/` (kökte) | YOK¹ | YOK | YOK² | YOK | YOK |
| `compacts/` | 6 compact | 0 (yalnız _index) | 4 compact | YOK | YOK |
| `sessions/` | 0 arşiv | 2 arşiv | 1 arşiv | YOK | YOK |
| `skills/` | 6 | 10 | 10 | YOK | YOK |

¹ `feature-research/manuel-reeskont/progress/` altında 66 numaralı progress dosyası (kökte değil).
² Karşılığı `mm-microui-phase-docs/TODO-In Progress-Done/`, 27 numaralı dosya.

### A3 Kit'te olmayan ek yapılar
`sql-log/<is>/{01-sorgular,02-ciktilar}.md` (workspace 13 iş · MM 3 iş; workspace ~1,1 M char) ·
`reference/` 3 md (MM, 86 476 char) · `screens/` `inventory/` `mm-microui-phase-docs/` `tools/` (Treasy.MM.UI) ·
`MIGRATION.md` (Treasy.MM.UI, 230 satır · 18 899 char) · `MODULE-CREATION-GUIDE.md` (workspace, 352 satır · 21 637 char) ·
`_postcompact-instruction.md` (workspace, 22 satır).

### A4 Mükerrer ağaç
`repos/.ai-agent/sql-log/` ile `repos/.ai-agent/feature-research/sql-log/` aynı ağacın iki kopyası:
10 iş klasörü (20 md) birebir aynı · `_index.md` farklı · 3 klasör yalnız yeni konumda.
Mükerrer hacim **21 md · 745 295 char · ~186 300 token = workspace toplamının %23'ü**.

### A5 Kit sizing tavanını aşanlar (MEMORY ve skill tavanı ≈150 satır)
`NetTrex.MM/.ai-agent/MEMORY.md` 987 satır = 6,6× · `repos/.ai-agent/MEMORY.md` 967 = 6,4× ·
`Treasy.MM.UI/.ai-agent/MEMORY.md` 375 = 2,5× · 10 skill dosyası 157–445 satır = 1,0–3,0×.

## B. YÜKLEME GERÇEĞİ

### B1 Başlatma dizinine göre otomatik yüklenen zincir
| Başlatma dizini | Yüklenen | Char | ~Token |
|---|---|---:|---:|
| `repos\` | hiçbiri | 0 | 0 |
| `repos\.ai-agent\` | hiçbiri | 0 | 0 |
| `repos\NetTrex.MM\` | hiçbiri | 0 | 0 |
| `repos\NetTrex.Web.UI\` | hiçbiri | 0 | 0 |
| `repos\NetTrex.Common\` | hiçbiri | 0 | 0 |
| `repos\Treasy.MM.UI\` | CLAUDE.md 10 850 + PROJECT_CONTEXT 9 179 + MIGRATION 18 899 + MEMORY 29 566 | 68 494 | ~17 124 |

### B2 `CLAUDE.md` mevcudiyeti
YOK: `~/.claude/CLAUDE.md` · `source\CLAUDE.md` · `source\repos\CLAUDE.md` · `repos\.ai-agent\CLAUDE.md` ·
`NetTrex.MM` · `NetTrex.Web.UI` · `NetTrex.Common` · `Treasy.Common.UI`. **VAR: yalnız `repos\Treasy.MM.UI\CLAUDE.md`.**

Sebep: workspace `PROJECT_CONTEXT.md`/`MEMORY.md` yalnız bir `CLAUDE.md` içindeki `@import` ile yüklenir;
`@import` eden dosya hiçbir üst dizinde yok. `/context`'teki `MEMORY.md` farklı mekanizma:
`~/.claude/projects/c--Users-TREASY-49-source-repos--ai-agent/memory/MEMORY.md` = 2 499 char / 14 satır,
yanında 14 tekil memory dosyası (29 754 char).

### B3 Arşivde duran, canlıda olmayan `CLAUDE.md`'ler (`C:\Users\TREASY-49\Desktop\repo\`)
| Arşiv dosyası | Satır | Char | Tarih | `@import` |
|---|---:|---:|---|---|
| `Desktop\repo\CLAUDE.md` (workspace kökü) | 156 | 9 816 | 2026-08-13 | PROJECT_CONTEXT + MEMORY |
| `Desktop\repo\NetTrex.MM\CLAUDE.md` | 120 | 8 957 | 2026-08-28 | PROJECT_CONTEXT + MEMORY |
| `Desktop\repo\NetTrex.WEbUI\CLAUDE.md` | 110 | 6 263 | 2026-08-13 | PROJECT_CONTEXT + MEMORY (karşılıksız) |
| `Desktop\repo\Treasy.MM.UI\CLAUDE.md` | 132 | 9 320 | 2026-08-05 | — |
| `Desktop\repo\PlayWright\CLAUDE.md` | 186 | 14 301 | 2026-08-03 | — |

Arşivdeki `NetTrex.WEbUI\.ai-agent\` iskeleti var, içi boş (0 md).
Arşivde `NetTrex.WEbUI\.claude\skills\{db-script,manuel-reeskont,mssql-read}\SKILL.md` var.

### B4 Compact hook'ları
| Repo | PreCompact manual | PreCompact auto | SessionStart:compact | Hook hedef yolu |
|---|:--:|:--:|:--:|---|
| `repos\.ai-agent` | YOK | YOK | YOK | settings.json yok |
| `NetTrex.MM` | VAR | VAR | VAR | `C:/Users/Treasy-70/...` |
| `Treasy.MM.UI` | VAR | VAR | YOK | `C:/Users/Treasy-70/...` |
| `NetTrex.Web.UI` · `NetTrex.Common` | YOK | YOK | YOK | `.claude/` yok |
| global `~/.claude/settings.json` | YOK | YOK | YOK | yalnız caveman hook'ları |

`C:\Users\Treasy-70` bu makinede YOK (`/c/Users/` altında yalnız `TREASY-49`).
Hook kodu `try{readFileSync}catch(e){process.exit(0)}` → her çağrıda sessizce çıkıyor, hata üretmiyor.

### B5 Compact / session dosyaları gerçekten oluşuyor mu
`repos/.ai-agent/`: 6 compact (en son 2026-08-17) · 0 session arşivi.
`NetTrex.MM/.ai-agent/`: 0 compact (yalnız `_index` 2026-08-12) · 2 session (en son 2026-07-16).
`Treasy.MM.UI/.ai-agent/`: 4 compact (en son 2026-08-03) · 1 session (2026-07-31).
2026-08-17'den bugüne (≈6,5 hafta) hiçbir repoda compact yazılmamış.

## C. İÇERİK DAĞILIMI

### C1 `repos/.ai-agent/MEMORY.md` = 74 girdi
| Etiket | Adet | % |
|---|---:|---:|
| Web.UI'ye özel | 24 | 32% |
| cross-repo | 16 | 22% |
| tek özelliğe özel — Manuel Reeskont | 9 | 12% |
| prosedür (bir skill'e ait olabilir) | 9 | 12% |
| muhasebe motoru | 4 | 5% |
| Fimple | 4 | 5% |
| MM'e özel | 4 | 5% |
| Treasy.MM.UI'ye özel | 2 | 3% |
| NetTrex.Common'a özel | 1 | 1% |
| boş kabuk (içeriği taşınmış) | 1 | 1% |

Prosedür etiketli 9 girdinin hedefi: `release-note` 1 · `db-script` 1 · `feature-researcher` 1 ·
`test-writer` 1 · `localization-extractor` 1 · araç/meta 2 · genel çalışma disiplini 2.

### C2 Mükerrer girdiler
| # | Girdi | Yer |
|---|---|---|
| 1 | `baseUrl` → `moduleCode` | aynı dosyada s.93 + s.105, birebir aynı metin |
| 2 | EF Core `IsRequired()` navigation projeksiyonda satırı siler | workspace s.685 ↔ MM s.614 |
| 3 | `AccEntryEntity already being tracked` | aynı dosyada s.833 (çürütülen) + s.940 (yeni) |
| 4 | WebUI shared-script `const` çakışması | workspace s.299 ↔ MM s.820 |
| 5 | Solo geliştirici / Türkçe / commit kullanıcıda / çıktı dosyaya | üç MEMORY.md'de de |

### C3 Repo-özel MEMORY.md'ler
`NetTrex.MM/.ai-agent/MEMORY.md`: 79 girdi · 987 satır · 91 121 char · 5 bölüm (+3 başlıksız girdi s.1–64).
`Treasy.MM.UI/.ai-agent/MEMORY.md`: 50 girdi · 375 satır · 29 566 char · 4 bölüm.
MM 79 girdi: MM'e özel 38 · tek özellik (Eximbank) 24 · Fimple 6 · muhasebe 4 · cross-repo 4 · Web.UI'ye özel 1 · meta 2.
MMUI 50 girdi: Treasy.MM.UI'ye özel 33 · `Treasy.MicroUI.Base` paketi 8 · Web.UI'ye özel 4 · cross-repo 5.
Ölü `C:\Users\Treasy-70\...` yolu içeren girdiler: MM s.67 · MM s.374 · MMUI s.374.

### C4 Skill envanteri
| Repo | Skill | Gotcha var | Wrapper (`SKILL.md`) |
|---|---:|---:|---|
| `repos/.ai-agent/skills/` | 6 (+6 alt prosedür) | 5/6 | kendi `.claude/skills/` YOK; 5'i MM klasöründen; `release-note` hiçbir yerde yok |
| `NetTrex.MM/.ai-agent/skills/` | 10 | 6/10 | 15 klasörün 6'sı dolu, 9'u boş |
| `Treasy.MM.UI/.ai-agent/skills/` | 10 | 9/10 | 10/10 |
| TOPLAM | 26 | 20/26 | — |

150 satırı aşan 10 skill: `db-script` 445 · `feature-researcher` 317 · `accounting-db-script` 289 ·
`manuel-reeskont` 279 · `mssql-read` 209 · `yuk-testi` 199 · `js-to-ts-porter` 187 ·
`parity-reviewer` 185 · `screen-migrator` 181 · `localization-extractor` 157.

## D. EKSİK REPOLAR

### D1 "CommonUI" hangi repo
`NetTrex.Common` = backend (Web.Api + Batch + Gateway + 4 DB projesi), AI dokümanı YOK.
`Treasy.Common.UI` = frontend, Micro UI ortak UI reposu — "CommonUI" denen ayrı repo bu;
AI dokümanı YOK (yalnız `.claude/tasks/completed`).

### D2 AI dokümanı durumu
| Aranan | NetTrex.Web.UI | NetTrex.Common |
|---|---|---|
| `CLAUDE.md` | YOK (arşivde 110 satır) | YOK (arşivde de yok) |
| `AGENTS.md` · `.ai-agent/` | YOK (arşivde iskelet, 0 md) | YOK |
| `.claude/` | YOK (arşivde settings + 3 wrapper) | YOK |
| `README.md` | 20 satır — Azure DevOps TODO şablonu, içerik sıfır | 23 satır — aynı şablon, içerik sıfır |
| Gerçek içerikli diğer md | `tests/README.md` 244 satır · 11 972 char | `.docs/unit-test-coverage/README.md` 357 satır · 29 828 char · `Tools/oracle-entity-diff.md` 407 satır · 12 113 char |
| Diğer | — | `.serena/project.yml` (Serena MCP config) |

### D3 Yapı ve kod büyüklüğü
| Ölçüm | NetTrex.Web.UI | NetTrex.Common |
|---|---:|---:|
| `.csproj` / `.sln` | 32 / 1 | 22 / 5 (1 kod + 4 DB) |
| `.cs` dosya / satır | 6 089 / 172 367 | 4 709 / 204 017 |
| `.cshtml` | 505 / 94 711 | 0 |
| `.js` | 397 / 1 065 351 (vendor dahil) | 0 |
| `.ts` | 28 / 43 316 | 0 |
| `.sql` | 1 / 24 | 2 773 / 197 969 |

Web.UI katmanları: `Code/Framework` 20 proje · `Code/Web/UI` 9 · `Code/Web/Common` 1 · `Code/Common` 1 ·
`Code/StateEngine` 1 · `Code/UnitTest` 1 · `tests/{playwright,vitest,scripts}`.
Common katmanları: `Code/Batch` 5 · `Code/Gateway` 1 · `Code/NetTrex.Web.Api/Common` 5 ·
`Code/NetTrex.Web.Api/Web.Api` 5 · `Code/UnitTest` 5 · `...External.Fimple` 1 ·
`DB/{TrexCommon,TrexFramework,TrexFI,TaoBase_Net}`. Repoda `NetTrex - Backup.Common.Domain.csproj` dosyası duruyor.

### D4 İki repoya ait dağınık bilgi (340 md + 1 CLAUDE.md tarandı)
| Hedef | Geçtiği dosya | Eşleşen satır |
|---|---:|---:|
| `Web.UI` | 136 | 483 |
| `NetTrex.Common` ∪ `TrexCommon` ∪ `Common.Web.API` | 57 | 257 |

En yoğun 5 — Web.UI: `manuel-reeskont/progress/progress-2.md` 37 · `repos/.ai-agent/MEMORY.md` 22 ·
`manuel-reeskont/05-faz-plani.md` 17 · `analiz/analiz-0-...-SUPERSEDED.md` 13 · `manuel-reeskont/00-PANO.md` 12.
En yoğun 5 — Common: `analiz/analiz-4-common-fanout-backend.md` 37 ·
`sql-log/manuel-reeskont-kodlama/02-ciktilar.md` 22 · `.../01-sorgular.md` 17 ·
`analiz/analiz-5-dailyflow-ui.md` 11 · `NetTrex.MM/.../exim-mm-otomatik-borrowing/01-sorgular.md` 9.
Ek: `Treasy.MM.UI/.ai-agent/inventory/webui-mm-envanteri.md` 275 satır · 11 816 char — Web.UI MM ekran envanteri,
Treasy.MM.UI reposunda duruyor.

## TESPİT EDİLEMEYENLER
- Gerçek tokenizer ile token sayımı (char/4 tahmini kullanıldı).
- Web.UI'de yazılmış JS ile `wwwroot/lib` vendor JS'inin ayrışması.
- `NetTrex.MM/CLAUDE.md`'nin canlı repodan ne zaman/nasıl kaybolduğu (`.gitignore`'da `.claude/` + `.ai-agent/` var).
- `Treasy-70` → `TREASY-49` kırılmasının tam tarihi (arşiv klasörü 2026-09-11; compact zaten 2026-08-17'de durmuş).
- `feature-research/sql-log/` mükerrer kopyasının tarihi/sebebi · `Treasy.MM.UI/.ai-agent/skills/readme` girdisinin ne olduğu.
