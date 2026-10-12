# Skill Index — Cross-Repo Prosedürler

> Bunlar **birden fazla repoya** dokunan prosedürlerdir. Tek repoya özel skill'ler o reponun
> `.claude/skills/`'inde durur ve cwd o repo olduğunda tetiklenir.
>
> Skill tetiklendiğinde dosyayı oku ve adımları **eksiksiz** uygula — kısaltma/atlama yok.

| Skill | Ne zaman | Tür | Tetikleyici (`.claude/skills/`) |
|-------|----------|-----|--------------------------------|
| [manuel-reeskont](manuel-reeskont.md) | Manuel Reeskont geliştirmesinde herhangi bir iş (analiz · sözleşme · MM endpoint · base component · UI) | Analiz + Kod | `NetTrex.MM/.claude/skills/manuel-reeskont/` · `NetTrex.Web.UI/.claude/skills/manuel-reeskont/` |
| [accounting-db-script](accounting-db-script.md) 💰 | **Muhasebe ile ilgili HER iş** — GL/fiş/kural sorusu, `AccEngine*` analizi, muhasebe scripti üretimi. Bilgi tabanı: `NetTrex.MM/.ai-agent/feature-research/Accounting-Engine-research.md`. 🔴 Script **çalıştırılmaz**, `outputs/`'a yazılır · `DefNumberGen` sayacı zorunlu | Analiz + Script | `NetTrex.MM/.claude/skills/accounting-db-script/` |
| [db-script](db-script.md) 📜 | **DB'ye YAZAN her SQL** — tablo/kolon/index/trigger, framework parametresi, permission, menü, SP. Emsaller: `NetTrex.MM/.ai-agent/imports/Örnek_Scriptler/`. 🔴 Script **koşulmaz**, `outputs/`'a yazılır · parametre **`sp_FrameworkAddParameter` ile** · `Txn*` Id'si IDENTITY **değil** | Script | `NetTrex.MM/.claude/skills/db-script/` · `NetTrex.Web.UI/.claude/skills/db-script/` |
| [mssql-read](mssql-read.md) 🔵 | Koddan/dokümandan **emin olamadığın** bir şeyi gerçek veriden doğrulamak. 🔴 **YALNIZ `SELECT`** · `TOP (20)` · `ORDER BY Id DESC` · yazma gerekiyorsa SQL `outputs/`'a yazılır, kullanıcı uygular | Salt-okunur | `NetTrex.MM/.claude/skills/mssql-read/` · `NetTrex.Web.UI/.claude/skills/mssql-read/` |
| [yuk-testi](yuk-testi.md) 🏋️ | **Yük / performans testi datası** — gerçek bir şablon işlemi N kez klonlayan script (MM `TxnMM`+detay+açılış fişi, FX `txnFX`). Referans script'ler: `yuk-testi/`. 🔴 Script **koşulmaz**, `outputs/`'a yazılır · her zaman `0-DOGRULAMA` + `1..N` + `9-GERI-AL` · `DefNumberGen` sayacı (MM önek `55`, FX `11`) · `@TemplateReference` **doldurulmalı** | Script | `NetTrex.MM/.claude/skills/yuk-testi/` · `NetTrex.Fx/.claude/skills/yuk-testi/` |
| [release-note](release-note.md) 📝 | **"release note yaz"** — DevOps board work item formunun alanlarına (Title/Summary/Testing Information/Impact Analysis/How To?/Definition and configuration/Scopekey Information/Process Changes/Customer Action Required, hepsi TR+EN) yapıştırılacak düz metin üretir. 🔴 Markdown/prose değil, board üslubu (düz paragraf, kısa teknik cümle) · yapay zeka yazdığı belli olmayacak · `Customer`/`Jira Id`/`DevOps Item Id` uydurulmaz | Yazım şablonu | (kayıt yok — CLAUDE.md üzerinden manuel tetiklenir) |

---

## Repo-özel skill'ler — nerede ne var

### `NetTrex.MM/.claude/skills/`

| Skill | Ne zaman |
|-------|----------|
| `entity-creator` | Yeni EF Core entity / tablo / DbSet |
| `pipeline-step-adder` | Accounting step pipeline'a yeni adım |
| `persister-strategy-adder` | Yeni `ProductSourceType` için persister |
| `batch-item-creator` | Yeni `BatchItem` |
| `batch-item-guide` | Mevcut `BatchItem` analiz / değişiklik / debug |
| `test-writer` | xUnit v3 testi |
| `code-reviewer` | "şu kodu incele / doğru mu / kontrol et" |
| `feature-researcher` | "[Konu] araştır / nasıl çalışıyor / uçtan uca göster" |
| `project-context-sync` | MM'e özel mimari değişikliği |
| `session-archiver` | MM oturumu kapanışı |

### `Treasy.MM.UI/.claude/skills/`

| Skill | Ne zaman |
|-------|----------|
| `screen-migrator` | Web.UI ekranını MicroUI'ye taşıma (orkestratör) |
| `razor-view-migrator` · `js-to-ts-porter` · `model-porter` · `api-reference-creator` | Taşımanın alt adımları |
| `localization-extractor` | Localization JSON çıkarımı |
| `shared-component-porter` | Paylaşılan bileşen taşıma (**tek ekran / MM içi ortak / pakete** karar tablosu) |
| `parity-reviewer` | Kaynak↔hedef parite denetimi |
| `migration-sync` · `session-archiver` | MD güncelleme |

---

## Çakışan tetikleyiciler — ayrım

- **"şu kodu/değişikliği incele, doğru mu?"** → `code-reviewer` (mevcut kodu denetler)
- **"[Konu] geliştirmesini incele / nasıl çalışıyor / araştır"** → `feature-researcher` (uçtan uca araştırır, salt-okunur)
- **"yük testi / N adet işlem bas / performans testi datası"** → `yuk-testi` (DB'ye yazan script olsa da
  `db-script`'ten **önce** gelir; iskelet kuralları `db-script`'ten miras). Manuel Reeskont için de geçerli
- **Manuel Reeskont'la ilgili HER ŞEY** → `manuel-reeskont` (yukarıdakilerden **önce** gelir; içinde hangi
  alt-skill'e delege edeceği yazılı)
