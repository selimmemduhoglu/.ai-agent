# Accounting Excel + THP — ham çıktılar (2026-10-27)

Bilgi tabanı: `NetTrex.MM/.ai-agent/feature-research/Accounting-Excel-THP-research.md` · Skill: `skills/accounting-excel-thp.md`.

| Dosya | Ne | Güvenilirlik |
|---|---|---|
| `kirilim-Dost.md` · `kirilim-Dunya.md` | Katılım BRWPLC AccountMap'i, Path × Source × kural → THP kodu + THP adı | Kural/Order/Target = Excel'den birebir. THP **adı** katılım PDF'inden |
| `kirilim-Tera.md` | Yatırım MM AccountMap'i | Kural/Order/Target birebir. THP adı **yatırım PDF layout çıktısından → kayabilir**; kesin ad için `kirilim-Tera-thp-karsilastirma.md` + PDF ham mod |
| `kirilim-OptFX.md` | OptionsFX Dünya Katılım AccountMap'i | 6 haneli `96xxxx/87xxxx` adları **kaymış olabilir**; yapıdan (son hane) oku |
| `kirilim-Tera-thp-karsilastirma.md` | Tera'nın kullandığı 159 THP kodunun iki plandaki zinciri yan yana | Yatırım sütunu kayma riskli |
| `thp-katilim-index.tsv` | Katılım THP: kod · ad · zincir | 3–5 hane güvenilir; 6 hane yaprak adları kayabilir |
| `thp-yatirim-index.tsv` | Yatırım THP: kod · ad · zincir | **Kayma riskli** (`pdftotext -layout`). Karar vermeden sayfayı ham modda aç |
| `scripts/validate-accountmap.js` | AccountMap tutarlılık taraması (Target prefix, tekrar, catch-all Order, hane dağılımı) | Okuma-yalnız |

**Yeniden üretim:** `pdftotext -enc UTF-8 -layout <pdf> out.txt` → kod/ad ayrıştırma; Excel → `exceljs` ile sayfa dökümü
(exceljs `table-xform.js` satır 101 yaması gerekir, `validate-accountmap.js` başlığına bak). Üretim script'leri bu klasörde
saklanmadı (tek seferlik); mantık research dosyasında anlatılı.
