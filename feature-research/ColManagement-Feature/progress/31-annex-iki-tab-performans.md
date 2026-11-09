# 31 — Annex 2 tab düzeni (New/Edit/Preview), Copy/Undo kaldırıldı, Logical Date, açılış performansı

**Tarih:** 2026-10-22 · **Önceki:** [`30`](30-annex-ekran-ux-lookup-tablolari.md)

Kullanıcı: *"2 tab olsun; Annex için olan 2 alan alt alta, Margin ve Scope 2. tab'ta alt alta… new, edit, preview hepsi için"* ·
*"Popup new ile açıldıktan sonra Scope ve Margin alanları geç yükleniyor"* · *"sağ üstte LogicalDate neden yok?"* ·
*"copy butonuna gerek yok, Undo'ya gerek yok"* · maker-checker kolonları TxnMM ile karşılaştırılsın.

## Yapılanlar
| Konu | Ne |
|---|---|
| 2 tab | `_Form` + `_Preview`: Tab 1 = Identity + Validity kartları alt alta; Tab 2 = Product Scope + Party Margin Terms alt alta. `DeferRendering(false)`. Popup 1100×85vh |
| Preview | Direction/MarginType/Party/RoundingMethod adları sunucuda lookup'la (5 istek `Task.WhenAll`), ürün adı `ProductScopeCatalog.ProductNames()` (MM'e gitmez), Included `Annex.yesNoText` |
| Geç yükleme kök sebebi | 7 lookup `Promise.all` içindeydi ve biri MM'e giden katalog; MM erişilemezken HttpClient varsayılanı **100 sn** bekliyordu. Çözüm: MM çağrıları paralel + **5 sn** `CancellationToken`; grid'ler katalogu beklemeden çiziliyor, katalog gelince `columnOption` ile lookup güncelleniyor; lookup + form HTML + varsayılan tarih **sayfa ömrü boyunca cache** (boş katalog cache'lenmez); kayıt isteği lookup'larla **paralel**. Definition (9 sıralı await → tek `Promise.all`) ve Txn de paralel |
| Logical Date | 3 Index'te `AddViewBag("CurrentLogicalDate", …"dd/MM/yyyy")` (MM deseni), `Trex:ColManagementLogicalDate` |
| Copy/Undo | GridModel'den `CopyAction`/`RejectUndoAction` çıkarıldı (paket JS: `action !== undefined` ise buton görünür); `index.ts`'lerdeki `btnTbCopy`/`btnCtCopy` bağlamaları ve `BTN_TB_COPY` silindi. Undo controller action'ı ve backend ucu duruyor (kullanılmıyor) |

## Maker-checker kolon karşılaştırması (sql-log #22-#24)
- `TxnTransaction`: TxnMM'in flow kolonlarının **hepsi var** (FlowId, LastActionId, PreviousActionId, PreviousStateId/Date/Maker, Trader, InputDate, CreatedBy/Date). Eksik: `TransactionOriginType`, `LinkedTransaction*` (maker-checker değil).
- `Annex`, `CollateralDefinition`: MakerChecker tanım modeli (StateId/StateMaker/StateDate + CreatedBy/Date; önceki hâller History tablosunda). MM'in kendi tanım tablosu `PrdProductDefinition` da aynı modelde (CreatedBy bile yok). FlowId/Trader/Previous* eklemek = tanımları **flow engine**'e taşımak → mimari karar, **kullanıcıya soruldu**, kod yok.

## Doğrulama
- Rebuild `--no-incremental`: backend **0 hata**, UI **0 hata**; `tsc` 12 (hepsi TS2581 jQuery `$` tipi, önceden var olan sınıf; yeni `$(...)` kullanımı +1).
- 🔴 Tarayıcıda denenmedi.
