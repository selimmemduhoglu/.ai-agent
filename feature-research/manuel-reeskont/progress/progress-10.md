# progress-10 — 🟢 Açık kalemler kapandı · permission/menü scriptleri · accounting bilgi tabanı

**Tarih:** 2026-08-13 · **Önceki:** [progress-9.md](progress-9.md)
**Tetikleyen istek:** *"Murabaha ve Wakala için de tabi ki OnRevaluation var, tüm ürünler için var…
sen geriye kalan işlerini de bitir… Permission kayıtlarını da yaz. Birim testleri sonra yazarız.
Açık kalem işlerini de bitir."* + *"her öğrendiğin accounting bilgisini bir md dosyasına yaz ve
accounting DB script adında skill'in de olsun"*
**Kural:** Bu dosya progress-9'un **güncellenmiş tam hali**dir. Öncekiler **düzenlenmedi**.

**Sonuç:** ✅ `NetTrex.MM` **Build succeeded** · ✅ `NetTrex.Web.UI` **Build succeeded** · ✅ 6/6 JS `node --check`

> ⏸️ **Faz 4 (MicroUI / `Treasy.MicroUI.Packages`) ERTELENDİ** — kullanıcı kararı:
> *"bu MicroUI işini yapma, sonra ben deyince yapacaksın."* Şimdilik **yalnız WebUI + MM**.

---

## ✅ A. Accounting bilgi tabanı + skill

### A.1 Skill: `accounting-db-script`

| Dosya | Ne |
|---|---|
| [`repos/.ai-agent/skills/accounting-db-script.md`](../../skills/accounting-db-script.md) | Gövde — 5 seviyeli zincir · 9 değişmez kural · `DefNumberGen` tablosu · script iskeleti · 3 temizlik seviyesi · GL kuralı anatomisi · **9 gotcha (`A-01`…`A-09`)** |
| `NetTrex.MM/.claude/skills/accounting-db-script/SKILL.md` | Tetikleyici wrapper |
| `NetTrex.MM/CLAUDE.md` · 2 × `skills/_index.md` | Kayıt |

**En kritik iki kural:** script **çalıştırılmaz** (`outputs/`'a yazılır, kullanıcı uygular) ·
DB **varyantı doğrulanır** (~50 `NetTrexAcc_*`).

### A.2 Bilgi tabanı genişletildi — [`Accounting-Engine-research.md`](../../../NetTrex.MM/.ai-agent/feature-research/Accounting-Engine-research.md)

Kullanıcının 3 script klasörü (`BRWPLC-DUBAI` · `Commission` · `Tawarruq`) + permission örnekleri okundu:

| Bulgu | Detay |
|---|---|
| 🔴 **`DefNumberGen`** | `AccEngine*` Id'leri **`IDENTITY` DEĞİL** — sayaçtan rezerve edilir (11 tanım), script sonunda **güncellenir**, yoksa **PK çakışması** |
| **Idempotency** | Her `INSERT` `IF NOT EXISTS` ile sarılı; Id **yalnız insert olduysa** artar; `OUTPUT inserted.Id INTO @tempTable` ile zincir taşınır |
| **3 temizlik seviyesi** | Tam (Item+ItemCode dahil) · İçerik (Item korunur) · Sadece `AccAccountMap`. Silme **yaprak→kök**, Item'da **önce çocuklar** |
| **`AccAccountMap` ayrı** | Zincire join edilmez, **kendi `Path`'i** ile silinir |
| **ComponentTypeCode** | `502`/`503` Opening · `504`/`505` Maturation · `507`, `506`+`110` Payment · **`510` Revaluation** |
| ⭐ **Gerçek reeskont GL kuralı** | FCY borçlanma = **4 satır**: `InterestExpense` D / `FxPositionLCY` C (LCY) + `FxPosition` D / `AccruedExpense` C (CCY). `AmountSource = AccrualAmount` → **`TxnMMDailyCalculation`** — ekranın `Data.DailyAccrual`'ı ile **aynı kaynak** |
| **`AccEngineDynamicRule`** | Kurallar **JavaScript**: `TxnModel.ValueDate.getTime() === TxnModel.LogicalDate.getTime()` |
| **Script arşivi haritası** | 19 klasör / 116 dosya — "ne arıyorsan nereye bak" tablosu eklendi |

---

## ✅ B. Menü + Permission scriptleri (kullanıcı talebi)

Kullanıcının kendi deseni (`MarketCustomerMap`, `Rollover`, `Cancebility`) birebir izlendi.

| Dosya | Ne |
|---|---|
| [`NetTrex.MM/.ai-agent/outputs/2026-08-13-ManuelReeskont-Menu-Script.sql`](../../../NetTrex.MM/.ai-agent/outputs/2026-08-13-ManuelReeskont-Menu-Script.sql) | 3 ekranı `NetTrexCommon.FrameworkMenu`'ye ekler · idempotent · `TRY/CATCH` · geri alma bloğu |
| [`NetTrex.MM/.ai-agent/outputs/2026-08-13-ManuelReeskont-Permission-Script.sql`](../../../NetTrex.MM/.ai-agent/outputs/2026-08-13-ManuelReeskont-Permission-Script.sql) | 3 ekran × 2 rol + action eşlemeleri |

**Menü yerleşimi (ölçüldü, `sql-log` #17):** mevcut iki ekran **`ParentId = 129`** altında
(`ManuelRevaluation` sıra 60 · `SecurityManuelReescont` sıra 65) → yeni ekranlar **66/67/68**.

**Roller — `_Checker` YOK:**

| Rol | Action'lar | Neden |
|---|---|---|
| `<Ekran>_Displayer` | `Index` · `Load` | Salt-okunur |
| `<Ekran>_Maker` | `Index` · `Load` · **`Execute`** | Fiş keser |

Manuel Reeskont **maker-checker ekranı değil** (Verify/Reject akışı yok) → `_Checker` yazılmadı.
⚠️ `Execute` yetkisi **gerçek fiş üretir ve Fimple'a gider** — script içinde uyarı olarak yazılı.

🔴 Scriptler **çalıştırılmadı** — `outputs/`'ta, kullanıcı uygular.

---

## ✅ C. Açık kalemler kapandı

### C.1 `OnRevaluation` Murabaha/Wakala'da var mı → ✅ **Kullanıcı yanıtı: tüm ürünlerde var**

Bu, `Accounting-Engine-research.md` § 5 madde 1'i kapatıyor. Manuel Reeskont Murabaha/Wakala
satırlarında fiş kesebilir.

### C.2 Doküman §4.6 — "aynı Revaluation Type" kuralı → ✅ **UYGULANDI (generic)**

🔑 **Ölçüm:** MM'de değerleme tipi **işlem bazlı değil, GLOBAL** —
framework parametresi `Revaluation:MM.ReverseType` (`IHelper.GetRevaluationReverseType()` →
`Eod`/`Bod`/`Atomic`). Yani MM'de **tüm satırlar aynı değeri taşır** ve kural fiilen engellemez.

**Karar:** Kuralı yine de **generic** uygula —

| Katman | Değişiklik |
|---|---|
| MM | `ManuelReeskontItem.RevaluationType` eklendi; handler `IHelper`'dan okuyup **tüm satırlara** yazıyor. Parametre yoksa `null` (ekran çökmez) |
| Web.UI DTO | `RevaluationType` eklendi |
| `manuel-reeskont.actions.js` | `mrIsSingleRevaluationType()` — seçili satırlarda **birden fazla farklı tip** varsa **Generate pasif**. Alan boşsa kural **uygulanmaz** |
| UX | Buton sessizce pasifleşmiyor — *"Seçili kayıtlar farklı değerleme tipinde"* uyarısı çıkıyor (tr/en) |

→ Satır bazında değişen bir modül (ör. FX) bu alanı doldurduğunda kural **kendiliğinden** devreye girer.
**MM'de engellemez.**

### C.3 `RegenerateToToday` (`İ-76`) → ✅ **UYGULANDI**

Önceki turda "tanımsız iş kuralı" diye `NOT_IMPLEMENTED` döndürüyordu. Şimdi anlamlandırıldı:

> **Geçmiş bir tarih düzeltilince sonraki günlerin tahakkuku da o değere dayandığı için,
> `ExecutionDate`'ten bugüne kadar HER GÜN yeniden değerlenir.**

| Kural | Detay |
|---|---|
| Yalnız `Regenerate` | `Generate` + `RegenerateToToday` → `INVALID_OPERATION` |
| 🔴 **Üst sınır `MaxCatchUpDays = 31`** | Döngü **gerçek fiş üretiyor**: 200 satır × 60 gün = 12.000 Fimple çağrısı olurdu. Sınır aşılırsa istek **hiç işlenmez** (`RANGE_TOO_LARGE`) — yarım bırakmaktansa hiç başlamamak |
| Her günün ters fişi | `date + 1 gün` (tek tarihte ise istekteki `ReverseValueDate`) |
| Bir gün patlarsa | **Zincir durur** — sonraki günler o güne dayanıyor. `ReasonDetail`'e `(durduğu tarih: yyyy-MM-dd)` yazılır |

⚠️ **Bilinçli sadeleştirme:** takvim (iş günü) filtresi uygulanmıyor — uygunluk zaten
`eligible-transactions` sorgusunda faiz dönemine göre belirleniyor ve tahakkuku olmayan güne
motor fiş üretmiyor. "Bugün" = `DateTime.Today` (logical date servisi bu handler'a enjekte edilmedi).

---

## 🔵 YAPILIYOR

Yok. ⚠️ Sunucular **durduruldu** (build için dosya kilidi açılması gerekti). Test için yeniden
kaldırılacak — komutlar [`08-test-rehberi.md`](../08-test-rehberi.md) § 1'de.

---

## ⬜ YAPILACAK

| # | İş | Kim |
|---|---|---|
| 1 | **Menü + permission scriptlerini uygula** (`outputs/`) — ekran bunlarsız açılmaz | Selim |
| 2 | 🔴 **Tarayıcı testi** — tüm fazlar bitti, kontrol listesi `08-test-rehberi.md` § 7 (~40 madde) | Selim + ben |
| 3 | Faz 2 **gerçek fiş testi** onayı (Fimple'a yazar) | Selim |
| 4 | **Birim testler** (`İ-15`) — *"sonra yazarız"* | ertelendi |
| 5 | **Faz 4 MicroUI/Packages** — *"ben deyince"* | ertelendi |
| 6 | `Ö-S-01…08` Fimple soruları · `Ö-04`/`Ö-05` muhasebe soruları · `C-20` eski ekran kararı | Selim |

---

## Kararlar bu turda

| Karar | Gerekçe |
|---|---|
| §4.6 kuralı **generic** yazıldı, MM'de no-op | Değer MM'de global; kuralı silmek yerine veri-güdümlü bıraktım — başka modül doldurunca çalışır |
| `RegenerateToToday` **31 gün** ile sınırlı, aşılırsa **hiç işlenmez** | Fiş üreten döngüde kısmi işlem, hiç işlememekten kötü |
| Bir gün patlayınca **zincir durur** | Sonraki günlerin tahakkuku o güne dayanıyor — devam etmek yanlış veri üretir |
| `_Checker` rolü **yazılmadı** | Ekranda Verify/Reject yok; olmayan rolü tanımlamak yetki modelini kirletir |
| Scriptler `outputs/`'a, **çalıştırılmadı** | `accounting-db-script` skill kuralı + kullanıcının kendi akışı |
| `RevaluationReverseType` enum'ı yerine **elle eşleme** | Enum `Api.IssueBond` projesinde; `Api.Services` ona referans vermiyor — proje referansı eklemek yerine 3 değerli switch |
