# Skill — accounting-excel-thp

**Ne zaman tetiklenir:** Muhasebe **Excel'i** veya **THP (Tekdüzen Hesap Planı)** ile ilgili her iş — Excel'de
GL/kırılım değişikliği, "bu işlem hangi hesaba düşer / neden şu hesaba düştü", yatırım ↔ katılım farkı, yeni müşteri
Excel'inin incelenmesi, AccountMap satırı, Shared kuralı, `AccountingSqlGenerator.ts` çıktısı.
Tetikleyici kelimeler: *THP · tekdüzen hesap planı · yatırım THP · katılım THP · kırılım · AccountMap Excel ·
Shared sayfası · Fund Type · Teminatlı · Kuruluş alt tipi · TargetMainGL · Target · BRWPLC Excel · Dost · Dünya · Tera ·
OptionsFX Accounting Excel · hesap planı kodu · `022010` / `328` / `126000` gibi THP kodu*

**Tür:** Analiz + Excel değişiklik rehberi · **Kapsam:** cross-repo (Excel → generator → `NetTrexAcc`)
**Kardeşi:** [`accounting-db-script`](accounting-db-script.md) — motor/DB/script tarafı. **Biri tetiklenince ikisi de okunur.**

---

## ADIM 0 — OKUMA SIRASI (atlama)

1. **Bu dosya.**
2. 🔴 [`NetTrex.MM/.ai-agent/feature-research/Accounting-Excel-THP-research.md`](../../NetTrex.MM/.ai-agent/feature-research/Accounting-Excel-THP-research.md)
   — Excel anatomisi · seçim mantığı · THP anatomisi · kırılım tabloları · bilinen tutarsızlıklar · playbook. **Ezberden cevap verme.**
3. Soru **motor/DB** ise → [`Accounting-Engine-research.md`](../../NetTrex.MM/.ai-agent/feature-research/Accounting-Engine-research.md) ve `accounting-db-script`.
4. **Satır satır kırılım** gerekiyorsa → `.ai-agent/outputs/2026-10-27-Accounting-Excel-THP/kirilim-{Dost|Dunya|Tera|OptFX}.md`.
   THP kodu arama → `thp-katilim-index.tsv` (güvenilir) / `thp-yatirim-index.tsv` (**kayma riskli**).

---

## 1. 🔴 DEĞİŞMEZ KURALLAR

| # | Kural |
|---|---|
| 1 | **THP PDF'i metin olarak okunur ama güvenilmez ölçüde kayar.** Katılım: `-layout` iyi. Yatırım: **ham mod** (`pdftotext -f N -l N THP.pdf -`, `-layout` yok) + sayfa numarasıyla doğrula. **6 haneli yaprak adlarına** iki PDF'te de güvenme, karar vermeden **sayfayı ham modda aç** |
| 2 | **Hangi workbook hangi plan:** Tera = **yatırım** (8 hane GL), Dost + Dünya + OptionsFX Dünya = **katılım** (10 hane GL, Fund Type var). Yeni Excel gelince önce bunu tespit et, **varsayma** |
| 3 | `Target` = fişe yazılan **gerçek GL**; `TargetMainGL` = fişe **taşınan** THP kodu (GL'i belirlemez). İkisi birbirinin **prefix**'i olmalı — değişiklikte **ikisi birden** güncellenir |
| 4 | **Kural kolonlarının anlamı satır ailesine göre değişir** (ürün Path'lerinde R4=Market, ödeme satırlarında R4=PaymentInstructionType). Rule numarasına göre kod yazma, kural **adına** göre |
| 5 | **Shared'de olmayan kural adı AccountMap'e yazılmaz**; yeni kuralın JS'inde `TxnModel.X` **gerçek property** olmalı (A-28, sessiz hep-false) |
| 6 | **Component kodu workbook'a bağlı** (Revaluation = 512 katılım / 510 Tera). Script yazarken **o workbook'un Shared'inden** kopyala |
| 7 | **Script'i ben çalıştırmam.** Generator Excel'de (Office Script) Selim'de koşar; ürettiğim SQL `<repo>/.ai-agent/outputs/`'a yazılır |
| 8 | Selim "excel üzerinde şunu değiştir" derse Excel'i **ben** değiştiririm — ama **orijinali ezmem**: `imports/AccountingExcels/` içinde **yeni versiyonlu kopya** (`<ad> v2.xlsx`), değişen hücrelerin **önce/sonra** listesi sohbete (`feedback_excel_versioning`). Araç: Node + `exceljs` (scratchpad'e `npm i exceljs` + table-xform yaması, `validate-accountmap.js` başlığında). **Ölçüldü (2026-10-27, Tera, oku→yaz→oku):** açılır liste doğrulamaları (MoneyMarket 1320 · Loan 640 · AccountMap 9216 · Shared 12), birleşik hücreler, 9 tablo, koşullu biçim sayıları **birebir korundu**. Ölçülmedi: hücre stilleri/renkler/sütun genişliği. Her yazımdan sonra dosyayı **yeniden oku** ve bu sayıları karşılaştır; fark varsa Selim'e **söyle**, "oldu" deme. AccountMap `Rule` hücreleri Shared tablolarına bağlı **açılır liste** — yeni kural adı önce Shared tablosuna girmeli |
| 9 | Değişiklik öncesi **tutarsızlık taraması** çalıştırılır, sonrası tekrar (aşağıda) |

---

## 2. Akış

### A) Soru: "bu kombinasyon hangi hesaba gider / neden bu hesaba gitti"
1. Workbook + Path + Source belirle (ör. `…/MONEYMARKET/PLC/LCY`, `CounterPartyGLAccount`).
2. `kirilim-*.md`'de o Path/Source tablosunu aç; işlemin boyutlarını (ürün · market · yerleşim · vade · kuruluş alt tipi · fund type · teminat) **Rule kolonlarına** sırayla uydur — **Order küçükten**, ilk tüm kuralları geçen satır.
3. Hesap kodunu THP'de ara (ham mod); adını **hiyerarşiyle** (ana → alt → detay) oku.
4. Fişte farklı çıktıysa → DB'de `AccEntry.AccAccountMapId`, `Source`, `TargetMainGL`, `GLCode` (okuma → `mssql-read`); sonra [`accounting-db-script`](accounting-db-script.md) Gotcha A-20…A-30 (Path eler/öncelik vermez · ordinal · gölgeleme · cache · property typo).

### B) İş: "Excel'de şunu değiştir"
1. Değişiklik türünü playbook tablosundan bul (research §7): GL değişimi · yeni alt tip/market/ürün · yeni ürün bloğu · Order · yeni alias.
2. **Etki zincirini yaz** (Hard Rule 9): hangi sayfalar (ürün sayfası `Expected GL`, Shared, AccountMap), hangi workbook'lar (Dost/Dünya aynı iskelet), canlıda hangi DB.
3. Tara: `node .ai-agent/outputs/2026-10-27-Accounting-Excel-THP/scripts/validate-accountmap.js "<xlsx>"` (exceljs gerekir, bkz. script başlığı) — **önce** (mevcut borç) ve **sonra**.
4. Kardeş karşılaştırması: LCY↔FCY (`34200↔34300`, `328↔329`, `022↔023`), Paid↔Expense, kısa↔uzun, Teminatlı↔Teminatsız / Fund Type üçlüsü (`…0/…2/…4`).
5. Değişikliği **kopya xlsx**'e uygula (Kural 8) → önce/sonra tablosu + doğrulama sonucu. Üretim DB'sine etkisi için (gerekirse) UPDATE script'i (`Order/IsEnabled/Description` idempotency anahtarında **yok**, A-26) + cache temizliği (A-23); generator'ı Selim Excel'de koşturur.
6. Yeni öğrenileni **research dosyasına** ve bu skill'in Gotcha'sına işle (`feedback_feed_research_back_into_skills`).

### C) İş: "yeni müşteri Excel'i geldi / incele"
1. Sayfa adları + satır sayıları; Shared'de rule kümesi; GL hane; Fund Type var mı; market kümesi.
2. Mevcut üç workbook ile **Shared farkı** (research §2.2) ve AccountMap satır farkı.
3. `validate-accountmap.js` → bulgu listesi (research §6 biçimi). **Düzeltme önermeden önce kardeş satırlara bak** — hangisi yanlış (`Target` mi `TargetMainGL` mi) kanıtla.
4. Yeni workbook'u research §1 tablosuna satır olarak ekle.

---

## 3. THP hızlı sözlük (ayrıntı research §4–§5)

| Boyut | Yatırım | Katılım |
|---|---|---|
| Gelir/gider adı | faiz (`622/624/626`, `570/572`) | kâr payı (`642–649`, `526/528/546/548`) |
| PPB borç | `328/329` → `01` bankalararası · `02` Takasbank · `03` BIST | `338/339` |
| Mali kesime kredi (placement) | `126/127/146/147/128/129`: `…00` açık / `…01` teminatlı × banka türü `0–5` | aynı ana kodlar, son hane **fon kaynağı** `0` özkaynak · `2` katılma · `4` yatırım vekâleti |
| Borç krediler | `342/343` yurtiçi bankalar · `344/345` diğer · `348/349` yurtdışı (`…000` sendikasyon · `001` sekürizasyon · `009` diğer) | aynı + `…002` Vekale |
| Reeskont borç | `36001` kullanılan kredi faiz reeskontu | `36001` (T.P.) / `36101` (Y.P.) kâr payı reeskontu |
| Banka alt tipi (`CorporateDetailType`) | 33 Kamu · 34 Özel · 35 Yabancı · 37 Özel Kanun · 38 Katılım · 39/40 Kalkınma-Yatırım · 43 Yurtdışı | aynı |
| Banka içi soneki | vade `00/01`, ürün `00/10/20` (Interbank/Murabaha/Wakala) | `…0000` ödenen / `…0010`·`…0100` tahakkuk |

---

## Gotcha

| # | Tuzak |
|---|---|
| **E-01** | 🔴 `imports/THP/` **excel değil PDF**. Yatırım PDF'in `-layout` çıktısı **kayar**; ham mod + sayfa doğrulaması şart |
| **E-02** | `Target` ile `TargetMainGL` uyuşmazsa **Target** fişi belirler. 2026-10-27 taramasında **15 satır** uyuşmuyor (research §6) — iş birimi teyidi bekliyor, düzeltilmedi |
| **E-03** | Component kodu workbook'a göre değişir: Revaluation **512 (Dost/Dünya) / 510 (Tera)**, Commission 511 yalnız Tera. DB doğrulaması **yapılmadı** |
| **E-04** | Ödeme satırlarında (`TREX/BRWPLC1`, `TREX/OPT1` kökü) Rule kolonları **ürün satırlarından farklı** anlam taşır; `Order 1000` kuralsız satır = `*ExternalCustomerGLCode` (calc) |
| **E-05** | `FxPositionLCY` Target'ı **5 hane** (`29400`) — diğer her satır 8/10. Düzensiz ama tutarlı; "düzeltme" |
| **E-06** | `Expected GL Code` (ürün sayfası) **dokümantasyondur**, üretime girmez; asıl kaynak AccountMap. İkisi sapabilir — değişiklikte ikisini de güncelle |
| **E-07** | Sayısal Alias (Commission `84099000`, `83000000`) GL'i kural içine **sabitler**; AccountMap değişikliği onu **etkilemez** |
| **E-08** | Excel, Shared'e göre ada bağlı çalışır; kural adında fazladan boşluk/büyük-küçük harf farkı = **çözülemeyen kural** (GEN_LOG'da görünür) |
| **E-09** | Dünya ve Dost aynı iskelet — birinde yapılan düzeltme **diğerinde de** aranmalı (tutarsızlıkların çoğu iki dosyada birden duruyor) |
| **E-10** | Yatırım workbook'unda Fund Type, katılımda Teminat/Market(TCMB·TAKAS·BIST) boyutu **yok** — bir workbook'un satırını diğerine kopyalama, kural kümesi farklı |

---

## Bu skill'in kaynağı

- `imports/AccountingExcels/` — `BRWPLC - Dost.xlsx`, `MM Accounting - Dünya Katılım.xlsx`, `MM Accounting - Tera.xlsx`, `OptionsFX Accounting - Dünya Katılım.xlsx`, `AccountingSqlGenerator.ts`, `Muhasebeler.png`
- `imports/THP/THP.pdf`, `THP-KATILIM.pdf`
- `outputs/2026-10-27-Accounting-Excel-THP/` — kırılım tabloları, THP indeksleri, doğrulama script'i
- Araştırma tarihi **2026-10-27**
