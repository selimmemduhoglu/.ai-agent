# Progress 1 — İş 2 tamam (ProductDefinition Visible Screens) · İş 1 onay bekliyor

**Tarih:** 2026-11-09 · **Repolar:** NetTrex.MM · Treasy.MM.UI · DB NetTrexMM (script)

## İş 2 — yapıldı
- **DB script** (kullanıcı uygular): `NetTrex.MM/.ai-agent/outputs/2026-11-09-ProductDefinition-VisibleScreens/`
  `0-DOGRULAMA` → `1-NetTrexMM-…` (2 kolon + History + trigger DROP/CREATE açık kolon listesi) · `9-GERI-AL` · `TEST-REHBERI.md`
- **NetTrex.MM:** entity/history/EF config · 6 API model · `ProductScreenType` enum · `Overview?Screen=` filtresi (IL + flag kapalı → `PRODUCT_DISABLED`) ·
  `GET api/product-definition/screens` · Mapster: Create null→true, Update null→mevcut değer · `Common/ProductDefinitionMapper`'dan çift kayıt (Create/Update) silindi.
- **Treasy.MM.UI:** Core modeller · Refit `Screens` · ProductDefinition form TagBox (Account Selection altı, varsayılan iki ekran seçili) ·
  grid/history/preview kolonları (IL kolonu yalnız modül açıkken) · `MmTransaction`/`InterbankLoan` `GetProductDefinitions` → `Overview(Screen)` ·
  IL'deki `!IsSameDay && !IsZeroRate` filtresi **kaldırıldı** · `utils/visibleScreens.ts` + Vitest.
- **Testler:** MM Api.Mapper 35 · Api.Services 362 · Data 33 · Data.Repository 273 · MM.UI Vitest 92 → **hepsi yeşil**; `tsc --noEmit` 0 hata.
- **MD:** IL flag birinci öncelik → workspace `CLAUDE.md` HR13, `NetTrex.MM` HR13, `feature-researcher` ADIM -1, `code-reviewer` §0, auto-memory.

## İş 1 — kod YOK, onay bekliyor
Ölçülen riskler (sql-log `il-reeskont-urun-ekran` #10-#12): açık IL işlemlerinin tamamı IRR-CL üründe (72 işlem NPV → IRR'ye geçer) ·
5 amortismanlı açık işlemde IRR `TxnLoan.PrincipalAmount` (ilk anapara) kullanıyor → şişer · aynı GL'lere artık tahakkuk gider (iş birimi teyidi).
