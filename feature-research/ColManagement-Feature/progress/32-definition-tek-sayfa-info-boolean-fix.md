# 32 — Status/Included false hatası, ValidTo min, Definition tek sayfa + Annex'ten doldurma, info ikonları, popup ölçek

**Tarih:** 2026-10-22 · **Önceki:** [`31`](31-annex-iki-tab-performans.md)

## Kararlar (kullanıcı)
- **K-56:** *"MM'in ekranındaki gibi kalsın… Annex ve CollateralDefinition MM'deki ProductDefinition tablosu gibi olsun"* → tanımlar maker-checker; FlowId/Trader/Previous* eklenmez.
- **K-57:** Definition'da Annex seçilirse Counterparty, Valid From/To, Eligibility Direction, Valuation Currency **Annex'ten gelir ve kilitlenir**; seçilmezse elle girilir.

## Yapılanlar
| Konu | Ne |
|---|---|
| Status=Inactive / Included=No → "is required" | DevExtreme `required` kuralı `false`'u boş sayıyor. Status (Annex+Definition) `IsRequired(false)` + custom kural `isBooleanSelected` (bridge); grid Included `validationRules` custom. Emsal: aynı formdaki `IsNegativeRateAllowed` |
| ValidTo | ValidFrom değişince `dbValidTo.min` = ValidFrom → önceki günler takvimde kapalı (Annex + Definition) |
| Varsayılan filtre | Annex + Definition Index `param ?? "1"` (Active Records, MM ProductDefinition gibi). "Today" = `StateDate.Date == Trex:ColManagementLogicalDate`; StateDate gerçek saat (`dateTimeProvider`) → mantıksal tarih geride ise Today boş görünür |
| Definition formu | 3 tab kaldırıldı → 3 kart alt alta; Eligible Currencies tam genişlik form alanı (`Width 100%`, `MaxDisplayedTags 12`). Preview da tab'sız |
| Annex'ten doldurma | `annex/f-key` + BaseCurrencyCode, Direction(int), ValidFrom, ValidTo. `sbAnnex` valueChanged → `updateData` + 5 editör `readOnly` |
| Business Day Rule DB'den | 5. lookup tablosu `CollateralBusinessDayRule` (Id=enum) + `api/collateral-business-day-rule/select-f-key`; script `2026-10-22-ColManagement-LookupTablolari` güncellendi (tekrar koşulmalı) + kurulum seti |
| Info (i) | `js/shared/field-help.ts`: form render sonrası `getEditor(field)` etiketine ikon + tooltip. Metinler Dinamik-Ekran `HELP` (TR) + EN çevirisi; key `helpAnnex-*`, `helpCollateralDefinition-*` (12 + 19) |
| Popup ölçek | Annex + Definition `Height: 'auto'`, `MaxHeight: 92vh`, `Width: 1000` → içerik kadar; Annex grid'leri 220px. History grid'i MM `mm-transaction.css` deseniyle `height: calc(80vh - 80px)` (Annex, Definition) |

## Açık / not
- MM ürünü seçilince SubProduct boş: MM API (`MMApi` → `localhost:5041`) ayakta değil; katalog 5 sn sonra boş döner. MM ayağa kalkınca gelir.
- ValidFrom varsayılanı mantıksal ayın 1'i (15.10 → 01.10) — tasarım gereği; mantıksal tarihin kendisi istenirse tek satır.

## Doğrulama
Rebuild backend+UI **0 hata**; `tsc` 18 (tümü TS2581 jQuery `$` tipi). Tarayıcıda denenmedi.
