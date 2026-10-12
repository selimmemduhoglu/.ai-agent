# 01 — Envanter: AI md yapısı denetimi (Aşama 1/N)

> **Tarih:** 2026-10-02 · **Kapsam:** ölçüm. Bu turda hiçbir dosya oluşturulmadı/değiştirilmedi/silinmedi (bu rapor hariç).
> **Terminoloji:** `ai-agent-context-kit` (`C:\Users\TREASY-49\Desktop\repo\ai-agent-context-kit`) —
> Katman 1 *Rules* (`CLAUDE.md`), Katman 2 *Architecture* (`PROJECT_CONTEXT.md`),
> Katman 3 *Experience* (`MEMORY.md`), Katman 4 *History* (`progress/` · `compacts/` · `sessions/`).
> Promotion rule, sizing guide ve two-file skill pattern aynı kit dokümanlarından.
>
> **Token tahmini yöntemi:** `char / 4`. Türkçe + çok sembollü md'de gerçek değer bundan %15–30 yüksek olabilir.
> Kesin tokenizer ölçümü yapılmadı — "tespit edilemedi".

---

## 0. Kit referansı ve bulunduğu yer

Kit `repos/` altında **değil**: `C:\Users\TREASY-49\Desktop\repo\ai-agent-context-kit`.
`docs/01-memory-layers.md` … `docs/05-multi-tool-portability.md` okundu. Kit'in öngördüğü template ağacı:

```
template/
├── CLAUDE.md                     (Katman 1 — Rules)
├── AGENTS.md                     (portability pointer)
├── .claude/settings.json.example (hooks + permissions)
├── .claude/skills/<ad>/SKILL.md  (ince wrapper — two-file pattern)
└── .ai-agent/
    ├── START-HERE.md
    ├── PROJECT_CONTEXT.md        (Katman 2 — Architecture)
    ├── MEMORY.md                 (Katman 3 — Experience)
    ├── README.md
    ├── progress/_index.md        (Katman 4 — append-only, numaralı)
    ├── compacts/_index.md + _precompact-instruction.md
    ├── sessions/README.md
    ├── outputs/README.md
    ├── feature-research/README.md
    ├── imports/README.md
    └── skills/_index.md + _TEMPLATE.md + 4 örnek skill
```

Kit'in **sizing guide**'ı (her istekte yüklenen dosyalar için tavan):

| Dosya | Hedef | Sert tavan |
|---|---|---|
| `CLAUDE.md` | 1–2 ekran | 3 ekran |
| `PROJECT_CONTEXT.md` | 2–3 ekran | 5 ekran |
| `MEMORY.md` | 1–3 ekran | aşınca buda |
| Skill dosyası | 1–3 ekran | aşarsa böl |

*(Bu raporda 1 ekran ≈ 50 satır kabul edildi.)*

---

# A. YAPI

## A.1 Üç `.ai-agent/` ağacının toplamı

| Kök | .md sayısı | Satır | Char | ~Token (char/4) |
|---|---:|---:|---:|---:|
| `repos/.ai-agent/` (workspace) | 177 | 52 438 | 3 273 362 | ~818 300 |
| `NetTrex.MM/.ai-agent/` | 74 | 21 703 | 1 243 563 | ~310 900 |
| `Treasy.MM.UI/.ai-agent/` | 89 | 13 179 | 744 255 | ~186 100 |
| **TOPLAM** | **340** | **87 320** | **5 261 180** | **~1 315 300** |

> Bu hacmin tamamı otomatik yüklenmiyor — fiilen yüklenen kısım B bölümünde.

## A.2 `repos/.ai-agent/` — klasör ağacı (2–3 seviye)

```
.ai-agent/
├── .claude/scheduled_tasks.lock        <- settings.json YOK, hook YOK
├── START-HERE.md                 120 satır ·   6 171 char · ~1 543 tok
├── PROJECT_CONTEXT.md            217 satır ·  13 046 char · ~3 262 tok
├── MEMORY.md                     967 satır ·  81 545 char · ~20 386 tok
├── MODULE-CREATION-GUIDE.md      352 satır ·  21 637 char · ~5 409 tok   <- kit'te YOK
├── compacts/                     _index · _precompact · _postcompact + 2 sohbet klasörü (6 compact)
├── feature-research/
│   ├── manuel-reeskont/          13 kök md + analiz/ + faz-docs/ + progress/ (66 dosya)
│   ├── swap-mm-rapor/            2 md
│   ├── ColManagement-Feature/       xlsx · pdf · docx (md yok)
│   └── sql-log/                  21 md · 745 295 char · MÜKERRER KOPYA (bkz. A.6)
├── imports/                      docx · xlsx · png · txt (md yok)
├── outputs/                      10 iş klasörü (md + sql)
├── sessions/README.md            <- hiç session arşivi yok
├── skills/                       6 skill md + yuk-testi/ (6 alt prosedür) + _index
└── sql-log/                      13 iş klasörü × (01-sorgular.md + 02-ciktilar.md)
```

### En büyük 15 dosya

| Dosya | Satır | Char | ~Token |
|---|---:|---:|---:|
| `feature-research/sql-log/swap-mm-rapor/01-sorgular.md` | 4 589 | 273 240 | 68 310 |
| `sql-log/swap-mm-rapor/01-sorgular.md` | 4 589 | 273 240 | 68 310 |
| `feature-research/sql-log/swap-mm-rapor/02-ciktilar.md` | 1 830 | 205 649 | 51 412 |
| `sql-log/swap-mm-rapor/02-ciktilar.md` | 1 830 | 205 649 | 51 412 |
| `feature-research/sql-log/manuel-reeskont-kodlama/02-ciktilar.md` | 1 908 | 98 621 | 24 655 |
| `sql-log/manuel-reeskont-kodlama/02-ciktilar.md` | 1 908 | 98 621 | 24 655 |
| **`MEMORY.md`** | **967** | **81 545** | **20 386** |
| `feature-research/sql-log/manuel-reeskont-kodlama/01-sorgular.md` | 1 634 | 78 704 | 19 676 |
| `sql-log/manuel-reeskont-kodlama/01-sorgular.md` | 1 634 | 78 704 | 19 676 |
| `feature-research/manuel-reeskont/progress/_index.md` | 88 | 68 659 | 17 165 |
| `feature-research/manuel-reeskont/08-test-rehberi.md` | 1 006 | 61 617 | 15 404 |
| `feature-research/manuel-reeskont/progress/progress-50.md` | 1 075 | 54 893 | 13 723 |
| `feature-research/manuel-reeskont/05-faz-plani.md` | 344 | 47 751 | 11 938 |
| `feature-research/manuel-reeskont/12-modul-yayilim-rehberi.md` | 862 | 46 532 | 11 633 |
| `feature-research/manuel-reeskont/progress/progress-49.md` | 878 | 44 585 | 11 146 |

## A.3 `NetTrex.MM/.ai-agent/` — klasör ağacı

```
NetTrex.MM/
├── CLAUDE.md                     ❌ YOK
├── .claude/
│   ├── settings.local.json       hook'lar kurulu (ama yolları ölü — bkz. B.3)
│   └── skills/                   15 klasör, 6'sında SKILL.md, 9'u BOŞ
└── .ai-agent/
    ├── PROJECT_CONTEXT.md        267 satır ·  17 149 char · ~4 287 tok
    ├── MEMORY.md                 987 satır ·  91 121 char · ~22 780 tok
    ├── START-HERE.md             ❌ YOK
    ├── compacts/_index.md        <- yalnız index; HİÇ compact dosyası yok
    ├── feature-research/         18 kök md + Batch-Items/ (4) + ManuelRevaluation/ (3)
    ├── imports/                  sql · xlsx · docx · msg · json · png
    ├── outputs/                  16 iş klasörü/dosya (md + sql + docx + postman json)
    ├── reference/                3 md   <- kit'te YOK
    │   ├── db-mimarisi-tanim-islem-akisi.md  538 satır · 35 407 char
    │   ├── repository-envanteri.md           329 satır · 27 017 char
    │   └── tablo-rehberi.md                  486 satır · 24 052 char
    ├── sessions/                 2 arşiv (2026-06-08 · 2026-07-16)
    ├── skills/                   10 skill md + _index
    └── sql-log/                  3 iş klasörü
```

### En büyük 10 dosya

| Dosya | Satır | Char | ~Token |
|---|---:|---:|---:|
| `feature-research/Exim-MM-Otomatik-Borrowing-tasarim.md` | 2 392 | 128 821 | 32 205 |
| **`MEMORY.md`** | **987** | **91 121** | **22 780** |
| `outputs/2026-08-31-Eximbank-Teslim/3-Senior-Kod-Incelemesi.md` | 1 763 | 86 760 | 21 690 |
| `sql-log/exim-mm-otomatik-borrowing/02-ciktilar.md` | 1 510 | 63 821 | 15 955 |
| `sql-log/exim-mm-otomatik-borrowing/01-sorgular.md` | 1 258 | 47 468 | 11 867 |
| `feature-research/InterbankLoan-research.md` | 798 | 40 995 | 10 249 |
| `.../2026-07-27-ManuelRevaluation-Teknik-Kod-Analizi.md` | 496 | 40 059 | 10 015 |
| `reference/db-mimarisi-tanim-islem-akisi.md` | 538 | 35 407 | 8 852 |
| `outputs/2026-08-31-Eximbank-Teslim/1-Musteri-Mail-Model-Sozlesmesi.md` | 394 | 33 791 | 8 448 |
| `feature-research/.../FxManuelRevaluation-Reeskont-research.md` | 483 | 32 377 | 8 094 |

## A.4 `Treasy.MM.UI/.ai-agent/` — klasör ağacı

```
Treasy.MM.UI/
├── CLAUDE.md                     147 satır ·  10 850 char · ~2 713 tok   <- TEK CANLI CLAUDE.md
├── .claude/
│   ├── settings.local.json       PreCompact var, SessionStart:compact YOK, yolları ölü
│   └── skills/                   10 klasör, 10'unda da SKILL.md ✅
└── .ai-agent/
    ├── START-HERE.md             100 satır ·   4 434 char · ~1 109 tok
    ├── PROJECT_CONTEXT.md        157 satır ·   9 179 char · ~2 295 tok
    ├── MEMORY.md                 375 satır ·  29 566 char · ~7 392 tok
    ├── MIGRATION.md              230 satır ·  18 899 char · ~4 725 tok   <- kit'te YOK (pano)
    ├── compacts/                 4 compact + _index + _precompact-instruction
    ├── feature-research/README.md   (boş iskelet)
    ├── imports/                  1 md
    ├── inventory/                4 md   <- kit'te YOK
    ├── mm-microui-phase-docs/    <- kit'te YOK; fiilen progress/ görevi görüyor
    │   ├── TODO-In Progress-Done/   27 numaralı dosya + _index
    │   ├── phase-0 / 1 / 2 / 4 / 7 md
    │   └── kaynak-hedef-fark-plani.md
    ├── outputs/                  kaynak-hedef-fark/ (8 md) + 4 kök md + helper klasörü
    ├── screens/                  6 ekran md + README   <- kit'te YOK
    ├── sessions/                 1 arşiv (2026-07-31)
    ├── skills/                   10 skill md + _index + readme/
    └── tools/                    bridge-audit.js · parity-count.py · run-local-stack.md
```

## A.5 Kit yapısına göre repo-repo karşılaştırma

| Kit bileşeni | `repos/.ai-agent` | `NetTrex.MM` | `Treasy.MM.UI` | `NetTrex.Web.UI` | `NetTrex.Common` |
|---|:--:|:--:|:--:|:--:|:--:|
| `CLAUDE.md` (Katman 1) | ❌ YOK | ❌ YOK | ✅ 147 satır | ❌ YOK | ❌ YOK |
| `AGENTS.md` | ❌ | ❌ | ❌ | ❌ | ❌ |
| `.claude/settings*.json` | ❌ (yalnız lock) | ✅ | ✅ | ❌ | ❌ |
| `.claude/skills/*/SKILL.md` | ❌ hiç yok | ⚠️ 6/15 dolu | ✅ 10/10 | ❌ | ❌ |
| `START-HERE.md` | ✅ 120 satır | ❌ YOK | ✅ 100 satır | ❌ | ❌ |
| `PROJECT_CONTEXT.md` (K2) | ✅ 217 satır | ✅ 267 satır | ✅ 157 satır | ❌ | ❌ |
| `MEMORY.md` (K3) | ✅ 967 satır | ✅ 987 satır | ✅ 375 satır | ❌ | ❌ |
| `progress/` (K4) | ❌ kökte yok¹ | ❌ YOK | ❌ yok² | ❌ | ❌ |
| `compacts/` (K4) | ✅ 6 compact | ⚠️ yalnız `_index` | ✅ 4 compact | ❌ | ❌ |
| `sessions/` (K4) | ⚠️ yalnız README | ✅ 2 arşiv | ✅ 1 arşiv | ❌ | ❌ |
| `skills/` | ✅ 6 (+6 alt) | ✅ 10 | ✅ 10 | ❌ | ❌ |
| `outputs/` | ✅ | ✅ | ✅ | ❌ | ❌ |
| `feature-research/` | ✅ | ✅ | ⚠️ boş README | ❌ | ❌ |
| `imports/` | ✅ | ✅ | ⚠️ boş README | ❌ | ❌ |

¹ `repos/.ai-agent/feature-research/manuel-reeskont/progress/` altında **66 numaralı progress dosyası** var —
kit'in öngördüğü kök `progress/` değil, iş-altı konumda.
² `Treasy.MM.UI` karşılığı `mm-microui-phase-docs/TODO-In Progress-Done/` (27 numaralı dosya) — aynı işlev, farklı ad.

### Kit'te olmayan ek yapılar

| Yapı | Nerede | Ne yapıyor |
|---|---|---|
| `sql-log/<is>/01-sorgular.md` + `02-ciktilar.md` | workspace (13 iş), MM (3 iş) | `mssql-read` skill'inin zorunlu denetim kaydı |
| `reference/` | NetTrex.MM | DB mimarisi · repository envanteri · tablo rehberi (3 md · 86 476 char) |
| `screens/` · `inventory/` · `mm-microui-phase-docs/` · `tools/` | Treasy.MM.UI | ekran panosu · envanter · faz dokümanları · yardımcı script |
| `MIGRATION.md` | Treasy.MM.UI | taşıma panosu (`CLAUDE.md`'den `@import` ediliyor) |
| `MODULE-CREATION-GUIDE.md` | workspace | yeni modül scaffold rehberi (352 satır) |
| `_postcompact-instruction.md` | workspace | `SessionStart:compact` hook metni (kit'te yok) |
| `feature-research/sql-log/` | workspace | `sql-log/`'un eski tam kopyası — bkz. A.6 |

## A.6 Mükerrer ağaç tespiti

`repos/.ai-agent/sql-log/` ile `repos/.ai-agent/feature-research/sql-log/` **aynı ağacın iki kopyası**.
`diff -rq` sonucu:

- 10 iş klasörü (20 md) **birebir aynı**
- `_index.md` iki yerde **farklı** (eski kopya geride kalmış)
- Yalnızca yeni konumda olanlar: `collateral-db-isimlendirme`, `collateral-db-nesne-envanteri`, `db-mimarisi-tanim-islem-akisi`

**Mükerrer hacim:** `feature-research/sql-log/` = 21 md · **745 295 char · ~186 300 token**
— workspace `.ai-agent` toplamının **%23'ü**.

---

# B. YÜKLEME GERÇEĞİ

## B.1 Otomatik yüklenen zincir — başlatma dizinine göre

Claude Code `CLAUDE.md`'yi **cwd'den kök dizine doğru** arar, ayrıca `~/.claude/CLAUDE.md` global dosyasını yükler.
`PROJECT_CONTEXT.md` / `MEMORY.md` **kendiliğinden yüklenmez** — yalnız bir `CLAUDE.md` içinden `@import` ile gelir.

Ölçülen gerçek:

| Dosya | Durum |
|---|---|
| `~/.claude/CLAUDE.md` (global) | ❌ **YOK** |
| `C:\Users\TREASY-49\source\CLAUDE.md` | ❌ YOK |
| `C:\Users\TREASY-49\source\repos\CLAUDE.md` | ❌ **YOK** |
| `repos\.ai-agent\CLAUDE.md` | ❌ YOK |
| `repos\NetTrex.MM\CLAUDE.md` | ❌ **YOK** |
| `repos\NetTrex.Web.UI\CLAUDE.md` | ❌ YOK |
| `repos\NetTrex.Common\CLAUDE.md` | ❌ YOK |
| `repos\Treasy.MM.UI\CLAUDE.md` | ✅ VAR (147 satır) |

### Zincir tablosu

| Başlatma dizini | Yüklenen zincir | Char | ~Token |
|---|---|---:|---:|
| `repos\` | — hiçbiri — | 0 | 0 |
| `repos\.ai-agent\` (bu oturum) | — hiçbiri — | 0 | 0 |
| `repos\NetTrex.MM\` | — hiçbiri — | 0 | 0 |
| `repos\NetTrex.Web.UI\` | — hiçbiri — | 0 | 0 |
| `repos\NetTrex.Common\` | — hiçbiri — | 0 | 0 |
| `repos\Treasy.MM.UI\` | `CLAUDE.md` 10 850 → `@.ai-agent/PROJECT_CONTEXT.md` 9 179 → `@.ai-agent/MIGRATION.md` 18 899 → `@.ai-agent/MEMORY.md` 29 566 | **68 494** | **~17 124** |

> **Not:** bu oturumda `NetTrex.MM`, `Treasy.MM.UI`, `NetTrex.Web.UI`, `NetTrex.Common` vb.
> *additional working directory* olarak ekli. Bu, o dizinlerdeki `.claude/skills/*/SKILL.md`
> wrapper'larının görünmesini sağlıyor (oturum skill listesinde `db-script`, `mssql-read`,
> `screen-migrator` … bu yüzden var) — **ama `CLAUDE.md` yükleme zincirini değiştirmiyor.**

## B.2 `/context`'te neden yalnız `memory/MEMORY.md` (1.1k) göründü

Ölçülen sebep **tek**: **yükleyecek `CLAUDE.md` yok.**

1. Workspace `PROJECT_CONTEXT.md` ve `MEMORY.md`, kit deseninde bir `CLAUDE.md`'nin `@import` satırlarıyla yüklenir.
2. `repos\CLAUDE.md` ve `repos\.ai-agent\CLAUDE.md` **mevcut değil** → `@import` eden hiçbir dosya yok → ikisi de yüklenmiyor.
3. `/context`'te görünen `MEMORY.md`, `.ai-agent/MEMORY.md` **değil**; Claude Code'un kendi kalıcı hafıza dizinidir:
   `C:\Users\TREASY-49\.claude\projects\c--Users-TREASY-49-source-repos--ai-agent\memory\MEMORY.md`
   — **2 499 char / 14 satır** (index), yanında 14 tekil memory dosyası (toplam 29 754 char).
   Bu, kit yapısıyla ilgisi olmayan **ayrı bir mekanizma**.

### Kaybolan `CLAUDE.md`'ler nerede

`C:\Users\TREASY-49\Desktop\repo\` altında, **kullanıcı dizini taşımasından (`Treasy-70` → `TREASY-49`,
`Desktop\_claude-migration-backup-20260911-093012`) kalma bir arşiv kopyası** duruyor ve aradığımız dosyaları içeriyor:

| Arşiv dosyası | Satır | Char | Son değişiklik | `@import` satırları |
|---|---:|---:|---|---|
| `Desktop\repo\CLAUDE.md` (**workspace kökü**) | 156 | 9 816 | 2026-08-13 | `@.ai-agent/PROJECT_CONTEXT.md` · `@.ai-agent/MEMORY.md` |
| `Desktop\repo\NetTrex.MM\CLAUDE.md` | 120 | 8 957 | 2026-08-28 | aynı ikisi |
| `Desktop\repo\NetTrex.WEbUI\CLAUDE.md` | 110 | 6 263 | 2026-08-13 | aynı ikisi |
| `Desktop\repo\Treasy.MM.UI\CLAUDE.md` | 132 | 9 320 | 2026-08-05 | (canlıda daha yeni sürüm var) |
| `Desktop\repo\PlayWright\CLAUDE.md` | 186 | 14 301 | 2026-08-03 | — |

Arşivdeki `NetTrex.WEbUI\.ai-agent\` klasör iskeleti **var ama içi boş** (hiç md yok) —
yani Web.UI için `PROJECT_CONTEXT.md`/`MEMORY.md` **hiç yazılmamış**; `CLAUDE.md`'deki o iki `@import` orada da ölüydü.
Arşivde ayrıca `NetTrex.WEbUI\.claude\skills\{db-script,manuel-reeskont,mssql-read}\SKILL.md` var.

**Canlı `source\repos\` altında bu dosyaların hiçbiri yok.** Taşımadan sonra geri konmamışlar.

## B.3 Compact hook'ları

| Repo | `PreCompact: manual` | `PreCompact: auto` | `SessionStart: compact` | Hook hedef yolu |
|---|:--:|:--:|:--:|---|
| `repos\.ai-agent` (workspace) | ❌ | ❌ | ❌ | `.claude/` içinde yalnız `scheduled_tasks.lock`; `settings.json` **yok** |
| `NetTrex.MM` | ✅ | ✅ | ✅ | `C:/Users/`**`Treasy-70`**`/source/repos/.ai-agent/compacts/_precompact-instruction.md` |
| `Treasy.MM.UI` | ✅ | ✅ | ❌ **eksik** | `C:/Users/`**`Treasy-70`**`/source/repos/Treasy.MM.UI/.ai-agent/compacts/_precompact-instruction.md` |
| `NetTrex.Web.UI` | ❌ | ❌ | ❌ | `.claude/` yok |
| `NetTrex.Common` | ❌ | ❌ | ❌ | `.claude/` yok |
| `~/.claude/settings.json` (global) | ❌ | ❌ | ❌ | yalnız caveman `SessionStart` + `UserPromptSubmit` hook'ları |

🔴 **Kurulu hook'ların hepsi ölü.** Hook komutu:

```js
const fs=require('fs'); let t='';
try{ t = fs.readFileSync(process.argv[1],'utf8') } catch(e){ process.exit(0) }   // <-- sessiz çıkış
```

`C:\Users\Treasy-70` dizini **bu makinede yok** (doğrulandı: `/c/Users/` altında yalnız `TREASY-49`).
`readFileSync` her çağrıda hata veriyor, `catch` **exit 0** ile sessizce çıkıyor —
hata görünmüyor, hiçbir talimat enjekte edilmiyor.

### Compact dosyaları gerçekten oluşuyor mu

| Konum | Compact sayısı | En son tarih |
|---|---:|---|
| `repos/.ai-agent/compacts/` | 6 (2 sohbet klasörü) | **2026-08-17** |
| `NetTrex.MM/.ai-agent/compacts/` | **0** (yalnız `_index.md`) | 2026-08-12 (index) |
| `Treasy.MM.UI/.ai-agent/compacts/` | 4 | **2026-08-03** |

**2026-08-17'den bu yana (≈6,5 hafta) hiçbir repoda compact yazılmamış.**

### Session arşivleri

| Konum | Arşiv sayısı | En son |
|---|---:|---|
| `repos/.ai-agent/sessions/` | **0** (yalnız README) | — |
| `NetTrex.MM/.ai-agent/sessions/` | 2 | 2026-07-16 |
| `Treasy.MM.UI/.ai-agent/sessions/` | 1 | 2026-07-31 |

---

# C. İÇERİK DAĞILIMI

> Yalnız sayım + etiketleme. Taşıma önerisi **yok**.

## C.1 `repos/.ai-agent/MEMORY.md` — 74 girdi

Bölümler: `Kullanıcı Tercihleri` (s.18) · `Cross-Repo Kararlar` (s.64) ·
`Bilinen Tuzaklar (cross-repo)` (s.112) · `Açık İşler` (s.914).

| Etiket | Adet | % |
|---|---:|---:|
| **Web.UI'ye özel** | 24 | 32% |
| **cross-repo** (gerçekten her repoyu ilgilendiren) | 16 | 22% |
| **tek özelliğe özel — Manuel Reeskont** | 9 | 12% |
| **prosedür** (bir skill'e ait olabilir) | 9 | 12% |
| **muhasebe motoru** | 4 | 5% |
| **Fimple** | 4 | 5% |
| **MM'e özel** | 4 | 5% |
| **Treasy.MM.UI'ye özel** | 2 | 3% |
| **NetTrex.Common'a özel** | 1 | 1% |
| **boş kabuk** (içeriği başka yere taşınmış, not kalmış) | 1 | 1% |
| **TOPLAM** | **74** | |

### Etiketli tam liste

| Satır | Girdi (kısaltılmış) | Etiket |
|---:|---|---|
| 20 | Solo geliştirici | cross-repo |
| 22 | Türkçe iletişim | cross-repo |
| 23 | Claude ASLA commit/push/PR yapmaz | cross-repo |
| 26 | MM işi `InterbankLoan:Enabled`'a göre davranır | **MM'e özel** |
| 29 | Büyük çıktıyı sohbete basma | cross-repo |
| 30 | Kod yorumu kısa — `<summary>` yeterli | cross-repo |
| 37 | "Release note yaz" → `skills/release-note.md` | prosedür → `release-note` |
| 47 | SQL script konvansiyonu → `skills/db-script.md` | prosedür → `db-script` |
| 52 | MD metodolojisi `ai-agent-context-kit`'ten | cross-repo (meta) |
| 57 | Workspace md katmanı istendi | cross-repo (meta) |
| 66 | Paylaşılan framework dosyalarına davranış dokunuşu yok | cross-repo |
| 77 | Manuel Reeskont: `NetTrex.Common` kullanılmıyor | **Manuel Reeskont** |
| 93 | `baseUrl` → `moduleCode` | **Manuel Reeskont** · 🔁 **MÜKERRER** |
| 99 | Base component referans deseni = `cashFlow/` | **Web.UI'ye özel** |
| 105 | `baseUrl` → `moduleCode` | 🔁 **s.93'ün birebir kopyası** |
| 114 | Dış uca makullük sınırı koymazsan process düşer | **MM'e özel** (Eximbank) |
| 149 | API geçidi kendi zarfını ekliyor, `IsSuccess`'i eziyor | **Fimple** |
| 174 | STJ `DateTime` yalnız ISO 8601 kabul eder | cross-repo |
| 199 | Fimple bir fişi bir kez tersler | **Fimple** + muhasebe |
| 220 | Toplu yazma döngüsü: `Added` artığı sonraki `Commit`'e karışır | cross-repo (EF / UnitOfWork) |
| 257 | Reeskontun ters fişi T+1 olmak zorunda değil | **Manuel Reeskont** |
| 284 | Tarih kaynağı kuralı `CLAUDE.md` HR12'ye **taşındı** | **boş kabuk** ⚠️ işaret ettiği `CLAUDE.md` artık yok |
| 290 | CSS eşit specificity'de kaynak sırası kazanır | **Web.UI'ye özel** |
| 299 | Çok dosyalı JS'te top-level `const` iki kez tanımlanamaz | **Web.UI'ye özel** |
| 315 | `formatDate(d,"shortDate")` ev standardı değil | **Web.UI'ye özel** |
| 329 | Onay penceresi "kural" yazarsa kullanıcı anlamıyor | **Manuel Reeskont** (UX) |
| 344 | Mutlak konumlu ⓘ rozeti için `position` ezilmeli | **Web.UI'ye özel** |
| 353 | Sistem parametresine Id yazılmaz, `Code` yazılır | cross-repo |
| 368 | "Dokümanı okudum" yetmez, koşan kod karşılığını ara | prosedür → `feature-researcher` |
| 381 | Tahakkuk motoru mutlak tutar basıyorsa "yeniden üret" = çift kayıt | **muhasebe motoru** |
| 404 | Ekranın "uygun işlem" şartları servisin ön koşuludur | **Manuel Reeskont** |
| 414 | Bir metnin yokluğunu üretilebildiği ortamda test et | prosedür → `test-writer` |
| 424 | DevExtreme `Form` içinde runtime `dataSource` kayboluyor | **Web.UI'ye özel** |
| 439 | DevExtreme `noDataText` kaydırma genişliğine göre konumlanır | **Web.UI'ye özel** |
| 450 | Sözleşmeye alan eklerken Web.UI DTO kopyası unutuluyor | cross-repo |
| 463 | `TagBox` + `ApplyValueMode.UseButtons` | **Web.UI'ye özel** |
| 473 | `PrdProductDefinition` `Code`/`Name` → `Pass`/`Pas` | **MM'e özel** |
| 485 | MD'ye Python `open(p,'w')` ile yazma | prosedür (araç) |
| 499 | Sunucu taraflı sayfalı grid'de DX filtresi yalnız yüklü sayfayı süzer | **Web.UI'ye özel** |
| 523 | Manuel Reeskont T+1 = +1 takvim günü | **Manuel Reeskont** |
| 546 | "Platform plumbing"i önce ÖLÇ sonra yaz | prosedür |
| 558 | `export:{enabled:true}` grid'in üstüne toolbar ekler | **Web.UI'ye özel** |
| 566 | Grid'i sayfa boyunca uzatmanın house pattern'i | **Web.UI'ye özel** |
| 572 | Fimple: defter hesabına `ReferenceType` gönderilemez (3058) | **Fimple** |
| 588 | DX dialog'u iki temada okunur yapmak | **Web.UI'ye özel** |
| 599 | `columnFixing:{enabled:true}` başlıkları siler | **Web.UI'ye özel** |
| 611 | `GetFimpleContentOrThrowAsync` hata gövdesini JSON sanıyordu | **Fimple** |
| 625 | Log handler'ları JSON varsayıyor | **Web.UI'ye özel** |
| 640 | DX `int` alanı `number` sayıp kolonu sağa yaslıyor | **Web.UI'ye özel** |
| 648 | Web.UI → modül Refit çağrılarında timeout ayarlı değil | **Web.UI'ye özel** |
| 676 | `dotnet test` VSTest ile MM testlerini bulamıyor (`xunit.v3`) | **MM'e özel** |
| 685 | EF Core `IsRequired()` navigation projeksiyonda satırı siler | cross-repo · 🔁 **MM MEMORY s.614 ile aynı** |
| 706 | `WidgetFactory` içinden `IHtmlHelper` reflection | **Web.UI'ye özel** |
| 718 | Deploy edilmiş modül API'si kaynaktan geri kalabilir | cross-repo |
| 727 | `FrameworkMenu`'ye satır eklemek yetmez — Redis menü cache | **NetTrex.Common'a özel** |
| 740 | Refit marker interface isimleri tutarsız | **Web.UI'ye özel** |
| 746 | Web.UI'de runtime base-URL resolver yok | **Web.UI'ye özel** |
| 751 | Web.UI permission = ControllerAdı/ActionAdı | **Web.UI'ye özel** |
| 755 | `Treasy.MM.UI`'de ekran bazlı sunucu yetkisi kapalı | **Treasy.MM.UI'ye özel** |
| 759 | Compact hook'ları repo başına kurulur | prosedür (meta) |
| 770 | `ManualRediscount` adı Web.UI'de zaten dolu | **Manuel Reeskont** |
| 781 | Eski ekranla doküman çelişirse doküman kazanır | prosedür |
| 787 | Web.UI'de JS birim testi altyapısı var ama kurulu değil | **Web.UI'ye özel** |
| 795 | `Html.DevExtreme().X()` için `WidgetFactory<TModel>` | **Web.UI'ye özel** |
| 801 | Web.UI JSON serileştirmesi PascalCase | **Web.UI'ye özel** |
| 806 | `Treasy.MM.UI` doküman bayatlığı — SharedDependency sürümü | **Treasy.MM.UI'ye özel** |
| 813 | "Base component" iddiasını view'daki global bozar | **Manuel Reeskont** |
| 817 | Seq'te LOCAL ve CLUSTER aynı sunucuya yazıyor | cross-repo (altyapı) |
| 833 | `AccEntryEntity already being tracked` — **çürütülen** teşhis | **muhasebe motoru** · 🔁 s.940 ile örtüşüyor |
| 847 | Muhasebe motorunda silme: zincirde FK yok, orphan üretir | **muhasebe motoru** |
| 869 | Localization sözlüğü kör uygulanmaz | prosedür → `localization-extractor` |
| 890 | `Trex.WebUI/Program.cs` bundler şema dosyalarını sızdırıyor | **Web.UI'ye özel** |
| 920 | `AddScoped<IDataContext>` + `AddTreasyDbContext` aynı scope'ta | cross-repo (framework) |
| 940 | `AccEntryEntity already being tracked` — temiz context'le patlamıyor | **muhasebe motoru** · 🔁 s.833 ile örtüşüyor |

### Mükerrer girdiler

| # | Girdi | Yerler |
|---|---|---|
| 1 | `baseUrl` → `moduleCode` | **aynı dosyada** s.93 ve s.105 — birebir aynı metin |
| 2 | EF Core `IsRequired()` navigation projeksiyonda satırı siler | `repos/.ai-agent/MEMORY.md` s.685 ↔ `NetTrex.MM/.ai-agent/MEMORY.md` s.614 |
| 3 | `AccEntryEntity ... already being tracked` | aynı dosyada s.833 (çürütülen teşhis) + s.940 (yeni teşhis) — iki girdi, tek olay |
| 4 | WebUI shared-script `const` çakışması | `repos/.ai-agent/MEMORY.md` s.299 ↔ `NetTrex.MM/.ai-agent/MEMORY.md` s.820 |
| 5 | Solo geliştirici / Türkçe / commit kullanıcıda / büyük çıktı dosyaya | **üç MEMORY.md'de de** (workspace s.20–29 · MM s.73–77 · MMUI s.15–19) |

## C.2 Repo-özel `MEMORY.md`'ler

### `NetTrex.MM/.ai-agent/MEMORY.md` — 79 girdi · 987 satır · 91 121 char

Bölümler: `Kullanıcı Tercihleri` (s.65) · `Mimari Kararlar` (s.81) · `Bilinen Tuzaklar` (s.505) ·
`2026-08-31 — Eximbank ucu: durum bitmask'i, GL kolonlari, preview alanlari` (s.829 — **tarih başlıklı ad-hoc bölüm, kit şemasında yok**) ·
`Açık İşler` (s.981).
Ayrıca **s.1–64 arasında bölüm başlığı olmayan 3 girdi** (s.13 · 38 · 48) — dosyanın başında başlıksız duruyorlar.

| Etiket | Adet |
|---|---:|
| MM'e özel | 38 |
| tek özelliğe özel — **Eximbank** | 24 |
| Fimple | 6 |
| muhasebe motoru | 4 |
| cross-repo (yanlış katmanda) | 4 |
| Web.UI'ye özel (yanlış repoda) | 1 (s.820) |
| meta/araç (`.claude/skills` boşluğu, Playwright yolu) | 2 |

⚠️ s.67 ve s.374: **`C:\Users\Treasy-70\...`** yolu — ölü yol, B.2'deki taşımadan kalma.

### `Treasy.MM.UI/.ai-agent/MEMORY.md` — 50 girdi · 375 satır · 29 566 char

Bölümler: `Kullanıcı Tercihleri` (s.13) · `Mimari Kararlar` (s.30) · `Bilinen Tuzaklar` (s.127) · `Açık İşler` (s.368).

| Etiket | Adet |
|---|---:|
| Treasy.MM.UI'ye özel (Micro UI paketi, bridge, vite, helm) | 33 |
| `Treasy.MicroUI.Base` / paket kaynaklı | 8 |
| Web.UI'ye özel (kaynak taraf) | 4 |
| cross-repo | 5 |

⚠️ s.374: **`C:\Users\Treasy-70\source\repos\PlayWright`** — ölü yol.

### Üç `MEMORY.md` boyut karşılaştırması (kit tavanı: 1–3 ekran ≈ 50–150 satır)

| Dosya | Satır | Kit tavanının katı |
|---|---:|---:|
| `NetTrex.MM/.ai-agent/MEMORY.md` | 987 | **~6,6×** |
| `repos/.ai-agent/MEMORY.md` | 967 | **~6,4×** |
| `Treasy.MM.UI/.ai-agent/MEMORY.md` | 375 | **~2,5×** |

## C.3 Skill envanteri

### `repos/.ai-agent/skills/` — 6 skill + 6 alt prosedür

| Skill | Satır | Gotcha | `.claude/skills/<ad>/SKILL.md` wrapper |
|---|---:|:--:|---|
| `accounting-db-script.md` | 289 | ✅ | `NetTrex.MM/.claude/skills/` (2 294 char) |
| `db-script.md` | 445 | ✅ | `NetTrex.MM/.claude/skills/` (2 442 char) |
| `manuel-reeskont.md` | 279 | ✅ | `NetTrex.MM/.claude/skills/` (2 371 char) |
| `mssql-read.md` | 209 | ✅ | `NetTrex.MM/.claude/skills/` (2 218 char) |
| `release-note.md` | 111 | ✅ | ❌ **hiçbir repoda wrapper yok** |
| `yuk-testi.md` | 199 | ❌ | `NetTrex.MM/.claude/skills/` + `NetTrex.Fx/.claude/skills/` (2 309 char) |
| `_index.md` | 56 | — | — |
| `yuk-testi/{mm,fx}-{3000-islem,dogrulama,geri-al}.md` | 94–271 | — | alt prosedür dosyaları |

> Workspace'in kendi `.claude/skills/` klasörü **yok**. Workspace skill'leri yalnızca
> `NetTrex.MM/.claude/skills/` içindeki wrapper'lar sayesinde tetiklenebiliyor —
> o da ancak MM *additional working directory* olarak eklenmişse.
> Kit'in two-file pattern'inde tetikleyiciyi wrapper'ın `description`'ı taşır; wrapper yoksa skill yalnız elle çağrılır.

### `NetTrex.MM/.ai-agent/skills/` — 10 skill

| Skill | Satır | Gotcha | Wrapper |
|---|---:|:--:|:--:|
| `batch-item-creator.md` | 100 | ✅ | ❌ klasör **boş** |
| `batch-item-guide.md` | 72 | ❌ | ❌ klasör boş |
| `code-reviewer.md` | 78 | ❌ | ❌ klasör boş |
| `entity-creator.md` | 98 | ✅ | ❌ klasör boş |
| `feature-researcher.md` | 317 | ❌ | ❌ klasör boş |
| `persister-strategy-adder.md` | 82 | ✅ | ❌ klasör boş |
| `pipeline-step-adder.md` | 86 | ✅ | ❌ klasör boş |
| `project-context-sync.md` | 44 | ✅ | ❌ klasör boş |
| `session-archiver.md` | 71 | ❌ | ❌ klasör boş |
| `test-writer.md` | 136 | ✅ | ❌ klasör boş |
| `_index.md` | 34 | — | — |

🔴 `NetTrex.MM/.claude/skills/` altındaki **15 klasörün 9'u tamamen boş** (`SKILL.md` yok) →
bu skill'lerin **hiçbiri otomatik tetiklenmiyor**.
*(MM'in kendi `MEMORY.md`'si s.348'de 2026-08-26'da "13 klasörün 10'u BOŞ" diye kaydetmiş; bugün 15 klasörün 9'u boş.)*

### `Treasy.MM.UI/.ai-agent/skills/` — 10 skill

| Skill | Satır | Gotcha | Wrapper |
|---|---:|:--:|:--:|
| `api-reference-creator.md` | 109 | ✅ | ✅ 391 char |
| `js-to-ts-porter.md` | 187 | ✅ | ✅ 472 char |
| `localization-extractor.md` | 157 | ✅ | ✅ 424 char |
| `migration-sync.md` | 62 | ✅ | ✅ 343 char |
| `model-porter.md` | 81 | ✅ | ✅ 386 char |
| `parity-reviewer.md` | 185 | ✅ | ✅ 467 char |
| `razor-view-migrator.md` | 147 | ✅ | ✅ 417 char |
| `screen-migrator.md` | 181 | ✅ | ✅ 372 char |
| `session-archiver.md` | 67 | ❌ | ✅ 297 char |
| `shared-component-porter.md` | 111 | ✅ | ✅ 475 char |
| `_index.md` | 89 | — | — |

**Gotcha özeti:** workspace 5/6 · MM 6/10 · Treasy.MM.UI 9/10 → **20/26 skill'de Gotcha var.**

**Kit sizing (skill ≤ 3 ekran ≈ 150 satır) aşanlar (10 skill):**
`db-script.md` 445 · `feature-researcher.md` 317 · `accounting-db-script.md` 289 · `manuel-reeskont.md` 279 ·
`mssql-read.md` 209 · `yuk-testi.md` 199 · `js-to-ts-porter.md` 187 · `parity-reviewer.md` 185 ·
`screen-migrator.md` 181 · `localization-extractor.md` 157.

---

# D. EKSİK REPOLAR

## D.0 "CommonUI" sorusu — hangi repo?

`repos/` altında **iki ayrı** "Common" var, karıştırılmamalı:

| Repo | Ne | AI dokümanı |
|---|---|---|
| **`NetTrex.Common`** | **Backend** — `NetTrex.Common.Web.API` + Batch + Gateway + 4 DB projesi (`TrexCommon`, `TrexFramework`, `TrexFI`, `TaoBase_Net`). Kullanıcı/menü/yetki/parametre/SWIFT tarafı. | ❌ yok |
| **`Treasy.Common.UI`** | **Frontend** — Micro UI tarafının ortak UI reposu (`Treasy.Common.UI.slnx`, `src/`, `tests/`, helm, pipelines). "CommonUI" denen ayrı repo **bu**. | ❌ yok (`.claude/tasks/completed` dışında hiçbir şey; `CLAUDE.md` · `.ai-agent/` yok) |

Bu aşamanın görev kapsamı `NetTrex.Common` olduğu için ayrıntılı ölçüm ona yapıldı;
`Treasy.Common.UI`'nin de **tamamen dokümansız** olduğu not edilir.

## D.1 `NetTrex.Web.UI`

### AI dokümanı durumu

| Aranan | Sonuç |
|---|---|
| `CLAUDE.md` | ❌ YOK (arşiv kopyası: `Desktop\repo\NetTrex.WEbUI\CLAUDE.md` — 110 satır · 6 263 char · 2026-08-13) |
| `AGENTS.md` | ❌ YOK |
| `.claude/` | ❌ YOK (arşivde `settings.local.json` + 3 `SKILL.md` wrapper vardı) |
| `.ai-agent/` | ❌ YOK (arşivde klasör iskeleti vardı, **içi boştu** — hiç md yok) |
| `README.md` | 20 satır — Azure DevOps **TODO şablonu**, içerik sıfır |
| `tests/README.md` | 244 satır · 11 972 char — Playwright + Vitest test rehberi, **gerçek içerik** |

**Arşivdeki `CLAUDE.md`'nin içeriği (özet):**
repo tanımı (monolit UI, backend'i yok, tüm veri modül API'lerinden Refit ile; MM · InterbankLoan · Fx · PM · FI ·
InvFund · Deriv/Swap · OptionsFX · Warrant · Limit · Common ekranları burada) ·
build komutları (`Code\Trex.Web.UI.sln`; npm/webpack build **yok**, JS `wwwroot/` altında ham) ·
**12 Hard Rule** (dil · önce plan · `decimal` zorunlu + `formatNumber` · shared script top-level `const` çakışması
sayfayı komple öldürür · Refit marker adları tutarsız · yetki = Controller/Action · commit yok ·
küçük değişiklik = yalnız değişen blok (JS dosyaları 1000+ satır) · taranmayacak klasörler ·
emin değilsen sor · DevExtreme **22.2.6** · Fimple hassasiyet kuralları) ·
skill tablosu (`manuel-reeskont`, `mssql-read` + `sql-log` denetim kaydı zorunluluğu) ·
MD güncelleme görevleri · çalışma alanları tablosu.
İçindeki `@.ai-agent/PROJECT_CONTEXT.md` ve `@.ai-agent/MEMORY.md` import'ları **karşılıksız**.

### Klasör yapısı / katmanlar

```
NetTrex.Web.UI/
├── Code/Trex.Web.UI.sln
│   ├── Common/Trex.Common.Models
│   ├── Framework/            20 proje: Abstractions · Authentication · Authorization · Caching · CMP ·
│   │                         Configuration · Data · GenericReporting · Hangfire · InquiryLog ·
│   │                         Logging.SqlLogger · MakerChecker · PipelineBehaviours · SSO · Startup ·
│   │                         Utility · WebApi · WebUI · WinSvc
│   ├── StateEngine/Netix.Core.Flow.StateEngine
│   ├── UnitTest/Trex.WebUI.Tests
│   └── Web/
│       ├── Common/Trex.Web.Business.Models
│       └── UI/  NeTrex.Framework.Api (Trex.UIApi) · Trex.Business · Trex.Business.Models ·
│                Trex.Data · Trex.FrameworkCommon · Trex.Integration ·
│                Trex.Integration.Abstractions · Trex.Notification · Trex.WebUI
├── Dependencies/   Aspose · DB · DevExtreme (18.2.7 / 19.1.6 / 21)
├── helm/nettrex-ui · pipelines/templates/steps
└── tests/   playwright{fixtures,specs} · vitest{helpers,setup,testScripts,types} · scripts
```

### Kod büyüklüğü

| Uzantı | Dosya | Satır |
|---|---:|---:|
| `.cs` | 6 089 | 172 367 |
| `.cshtml` | 505 | 94 711 |
| `.js` | 397 | 1 065 351 ⚠️ |
| `.ts` | 28 | 43 316 |
| `.sql` | 1 | 24 |
| `.csproj` | 32 | — |

⚠️ `.js` satırı `wwwroot/lib` altındaki **vendor kütüphanelerini de içeriyor**
(`bin`/`obj`/`node_modules` hariç tutuldu, `wwwroot/lib` tutulmadı).
Yazılmış proje JS'i bundan belirgin küçük — **ayrıştırılmadı, tespit edilemedi**.

## D.2 `NetTrex.Common`

### AI dokümanı durumu

| Aranan | Sonuç |
|---|---|
| `CLAUDE.md` | ❌ YOK (arşivde de yok) |
| `AGENTS.md` | ❌ YOK |
| `.claude/` | ❌ YOK |
| `.ai-agent/` | ❌ YOK |
| `.serena/project.yml` | ✅ VAR — Serena MCP proje tanımı (araç config'i, bilgi taşımıyor) |
| `README.md` | 23 satır — Azure DevOps **TODO şablonu**, içerik sıfır |
| `.docs/unit-test-coverage/README.md` | 357 satır · 29 828 char — **gerçek içerik**: unit test coverage raporlama |
| `Tools/oracle-entity-diff.md` | 407 satır · 12 113 char — **gerçek içerik**: Oracle entity diff aracı |

### Klasör yapısı / katmanlar

```
NetTrex.Common/
├── Code/NetTrex.Common.sln
│   ├── Batch/        NetTrex.Common.Batch.{Business, Business.Models, Core, Integration, WebApi}
│   ├── Gateway/      Gateway.Api
│   ├── NetTrex.Common.ResponseRequest.External.Fimple/
│   ├── NetTrex.Web.Api/
│   │   ├── Common/   NetTrex.Common.{Core, Domain, Flow, Operations, Repository}
│   │   │             ⚠️ `NetTrex - Backup.Common.Domain.csproj` — artık (backup) csproj dosyası
│   │   └── Web.Api/  NetTrex.Common.{Business, KafkaService, Model, ResponseRequest, Web.API}
│   └── UnitTest/     Api/{Business.Test, Core.Test} · Batch/{Batch.Core.Test} ·
│                     Common/{Flow.Test, Operations.Test}
├── DB/   TaoBase_Net.sln · TrexCommon.sln · TrexFI.sln · TrexFramework.sln
│         her biri: dbo/ · Security/ · sql_change/ · sql_changes/  (+TrexFramework: HangFire/)
├── .docs/unit-test-coverage/{merged,raw}
├── Dependencies/   Aspose · DB · DevExtreme (18.2.7 / 19.1.6)
├── Tools/ · helm/ · pipelines/
└── azure-pipelines{,-batch,-gateway}.yml
```

### Kod büyüklüğü

| Uzantı | Dosya | Satır |
|---|---:|---:|
| `.cs` | 4 709 | 204 017 |
| `.sql` | 2 773 | 197 969 |
| `.csproj` | 22 | — |
| `.sln` | 5 (1 kod + 4 DB) | — |

> Repo'nun yaklaşık yarısı SQL: 4 veritabanı projesi (`TrexCommon`, `TrexFramework`, `TrexFI`, `TaoBase_Net`)
> `sql_change/` + `sql_changes/` klasörleriyle 197 969 satır. Bu, mevcut hiçbir AI dokümanında haritalanmamış.

## D.3 Bu iki repoya ait dağınık bilgi — nerede duruyor

Arama kapsamı: `repos/.ai-agent` + `NetTrex.MM/.ai-agent` + `Treasy.MM.UI/.ai-agent` + `Treasy.MM.UI/CLAUDE.md`
(toplam 340 md + 1 CLAUDE.md).

| Hedef | Geçtiği dosya | Eşleşen satır |
|---|---:|---:|
| `Web.UI` | **136 dosya** | **483 satır** |
| `NetTrex.Common` ∪ `TrexCommon` ∪ `Common.Web.API` | **57 dosya** | **257 satır** |

### `Web.UI` bilgisinin en yoğun olduğu 12 dosya

| Satır | Dosya |
|---:|---|
| 37 | `.ai-agent/feature-research/manuel-reeskont/progress/progress-2.md` |
| 22 | `.ai-agent/MEMORY.md` |
| 17 | `.ai-agent/feature-research/manuel-reeskont/05-faz-plani.md` |
| 13 | `.ai-agent/feature-research/manuel-reeskont/analiz/analiz-0-ilk-mimari-taslak-SUPERSEDED.md` |
| 12 | `.ai-agent/feature-research/manuel-reeskont/00-PANO.md` |
| 12 | `.ai-agent/PROJECT_CONTEXT.md` |
| 11 | `Treasy.MM.UI/.ai-agent/MEMORY.md` |
| 10 | `NetTrex.MM/.ai-agent/feature-research/Exim-MM-Otomatik-Borrowing-research.md` |
| 10 | `.ai-agent/skills/manuel-reeskont.md` |
| 10 | `.ai-agent/feature-research/manuel-reeskont/12-modul-yayilim-rehberi.md` |
| 9 | `.ai-agent/feature-research/manuel-reeskont/09-dokuman-uyumluluk-raporu.md` |
| 9 | `.ai-agent/feature-research/manuel-reeskont/02-mimari-karar.md` |

Ayrıca `Treasy.MM.UI/.ai-agent/inventory/webui-mm-envanteri.md` (275 satır · 11 816 char) —
Web.UI'nin MM ekranlarının birebir envanteri; Web.UI'ye ait en yapılandırılmış tek belge,
ama `Treasy.MM.UI` reposunda duruyor.

### `NetTrex.Common` bilgisinin en yoğun olduğu 10 dosya

| Satır | Dosya |
|---:|---|
| 37 | `.ai-agent/feature-research/manuel-reeskont/analiz/analiz-4-common-fanout-backend.md` |
| 22 | `.ai-agent/sql-log/manuel-reeskont-kodlama/02-ciktilar.md` (+ mükerrer kopyası) |
| 17 | `.ai-agent/sql-log/manuel-reeskont-kodlama/01-sorgular.md` (+ mükerrer kopyası) |
| 11 | `.ai-agent/feature-research/manuel-reeskont/analiz/analiz-5-dailyflow-ui.md` |
| 9 | `NetTrex.MM/.ai-agent/sql-log/exim-mm-otomatik-borrowing/01-sorgular.md` |
| 9 | `.ai-agent/skills/db-script.md` |
| 8 | `.ai-agent/PROJECT_CONTEXT.md` |
| 6 | `.ai-agent/feature-research/manuel-reeskont/progress/progress-1.md` |
| 5 | `NetTrex.MM/.ai-agent/feature-research/Exim-MM-Otomatik-Borrowing-tasarim.md` |
| 5 | `.ai-agent/sql-log/_index.md` |

---

## Tespit edilemeyenler

- Gerçek tokenizer ile token sayımı — `char / 4` tahmini kullanıldı.
- `NetTrex.Web.UI` içindeki **yazılmış** JS ile `wwwroot/lib` vendor JS'inin ayrışması.
- `NetTrex.MM/CLAUDE.md`'nin canlı repodan **ne zaman / nasıl** kaybolduğu.
  (`git log --diff-filter=D -- CLAUDE.md` → `6e02b1258` commit'inde silinmiş görünüyor; ancak `.gitignore`'da
  `.claude/` ve `.ai-agent/` ignore'lu olduğu için dosyanın disk üstündeki son hali git ile izlenemiyor.)
- Hook yollarındaki `Treasy-70` → `TREASY-49` kırılmasının **tam tarihi**.
  (`Desktop\_claude-migration-backup-20260911-093012` klasör adı 2026-09-11'i işaret ediyor,
  ama compact yazımı zaten 2026-08-17'de durmuş — iki olay bağımsız olabilir.)
- `Treasy.MM.UI/.ai-agent/skills/readme` girdisinin ne olduğu (klasör, içinde md yok).
- `repos/.ai-agent/feature-research/sql-log/` kopyasının **hangi tarihte / neden** oluştuğu.
