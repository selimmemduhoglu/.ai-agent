# 29 — Annex / Collateral Definition / Txn ekran hataları, State filtresi, FKey uçları

**Tarih:** 2026-10-22 · **Faz:** 10/11 (UI) + 6/7/8 (backend) · **Önceki:** [`28`](28-inci-model-uyarlama.md)

Kullanıcı ColManagement + ColManagement.UI'yi lokalde açtı (`localhost:5105/Annex/Index`). Sözleri:
*"Annex ekranını açtım ve ekran görüntüsündeki hatayı aldım neden? · Localization eklenmedi mi, neden kolon isimleri bu şekilde? ·
Records to be listed alanı için… MmTransaction/Index ekranına bak, oradaki State alanlarını al… ColManagement.UI için her zaman
Treasy.MM.UI'yi örnek al… Annex ve CollateralDefinition ekranlarının çalışmasını bekliyorum."*

## Kök sebepler ve yapılanlar

| # | Belirti | Kök sebep | Düzeltme |
|---|---|---|---|
| 1 | `+` → `TypeError: Cannot read properties of undefined (reading 'option') at populateDropdowns (form.ts:80)` | DevExtreme popup `contentTemplate`'i **`show()` anında** render eder. Kod `getSelectBox(...)`'u show'dan **önce** çağırıyordu → widget DOM'da yok → `undefined`. MM `initFormPopup` sırası: content → `setPopupOptions` → **`show()`** → dropdown/data | 3 ekranın (`annex`, `collateral-definition`, `txn-transaction`) `form.ts`'i MM sırasına alındı + MM gibi `try/catch` → `notifyError` + `finally loader.hide()` |
| 2 | Grid başlıkları `dgAnnexes-AnnexCode` | `AddFor` kolonları `{gridId}-{Field}` key'i ister; JSON'larda yalnız `pageTitle` + `frm*` vardı | 54 key (en+tr) eklendi: ana grid + History grid + `popupTitle` + eksik `frmAnnexPreview-Tab3Title`. Değerler aynı dosyadaki `frm*` etiketlerinden. Tarayıcı script'i: `formatMessage('…')`/`AddFor` taraması → 3 ekranda **eksik 0** |
| 3 | "State" etiketi | `UseDefaultStateFilter = true` → paket `TreasyStateFilter()` → `global-state`. MmTransaction liste overload'unu kullanıyor → `global-recordsList` ("Records to be listed") | 3 ekran: VM'e `CustomFilter`, controller `Index(string? param)` → `StateHelper.Rates.GetFxRateWithParamStates(param, "MM")`, view'da `StateFilterTemplateName` + `Templates/_CustomStateFilter.cshtml` (MM birebir) |
| 3b | Backend yeni Id'leri (6 Today, 7, 9-17, 21) tanımıyordu | Annex/Definition `StateFilterExpression.Get` → sözlükte yok → `KeyNotFound`; `QueryableExtension` yalnız `SetCalendar` iskeletiydi | `QueryableExtension.ApplyStateFilter` MM'den port (FlowEntity, Txn) + `ApplyMakerCheckerStateFilter` (Annex/Definition; 1-5 `StateFilterType`, 6+ MM `CustomFilter` anlamı). List request'lerinde `StateFilter` → `int` |
| 4 | Dropdown'lar | UI Refit rotaları backend'de yoktu (H-098) | `customer/select-f-key` → `customers/overview` (MM gibi aktif + FI) · `portfolio/select-f-key` → `portfolios/f-key` · yeni `annex/f-key`, `collateral-definition/f-key` (aktif + `IsEnabled`) · yeni `currencies/f-key` bağlantısı → Base/Dispute/Valuation Currency + Eligible Currencies TagBox + margin-rule lookup (sabit `["EUR","TRY","USD","GBP"]` silindi). `DisplayExpr("code")` → `"Code"` (JSON PascalCase) |
| 5 | Dropdown'lar yine boş olacaktı | `NetTrexColManagement`'ta `Currency`/`Customer`/`Portfolio` **0 satır** (Consumer senkronu hiç akmamış). MM'de 56/111/29 | `Treasy.ColManagement/.ai-agent/outputs/2026-10-22-ColManagement-ReferansVeri/` — kesişen kolonlarla kopya, idempotent, collation farkı (`COLLATE DATABASE_DEFAULT`) |

## Doğrulama
- Backend `Treasy.ColManagement.sln` **0 hata**; UI `Treasy.ColManagement.UI.sln` **0 hata**; `tsc` yalnız önceden var olan 11 TS2581.
- Bundle (`wwwroot/bundles/localization/en.json`) yeni key'leri içeriyor.
- Çalışan backend'e GET: `rate-type` 3 satır (21 script'leri koşulmuş), `currencies`/`customers`/`portfolios` **boş** → sql-log #10-#18.
- 🔴 **Doğrulanmayan:** servisler yeni kodla yeniden başlatılmadı, ekranlar tarayıcıda denenmedi; kopya script'i çalıştırılmadı.

## Kararlar
- K-55 (K-44 netleşmesi) kararlara yazıldı. Seed `InterestFree`/`OnReturn`: *"şimdilik kalsın"*.
- Widget tipleri (MM'de Currency `Lookup`, Customer `DropDownBox`) bu turda **değiştirilmedi** — SelectBox kaldı; kullanıcı test ederken isterse MM'e çevrilir.

## Açık kalanlar
- H-099 (list handler'larda required `Customer` Include → INNER JOIN).
- K-55 uygulaması (Detail akışı) — kod yok.
