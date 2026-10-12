# Faz 6 — Annex Ucu (ilk dikey dilim)

**Durum:** ⬜ · **Ön koşul:** Faz 5

## 1. Amaç

Uçtan uca **bir** ekranın backend'i: Annex (sözleşmesel çerçeve) + 2 alt tablo.
Bu faz **deseni kurar** — Faz 7 ve 8 bu desenin tekrarı.

## 2. Önce oku
- [`../bilgi-bankasi/09-tablolar-neden-var.md`](../bilgi-bankasi/09-tablolar-neden-var.md) — Annex ne işe yarar
- [`../bilgi-bankasi/01-is-analizi.md`](../bilgi-bankasi/01-is-analizi.md) — Threshold/MTA/Rounding kuralları
- Excel v5 → `Annex`, `AnnexProductScope`, `AnnexMarginRule` sheet'leri

## 3. Katman akışı (her uçta aynı)

```
Controller → Request → Validator → Handler → Mapper → Factory → DataManager → Entity
                                                                    └─> UnitOfWork.CommitAsync()
```

## 4. Adımlar
1. Entity + `IEntityTypeConfiguration` (3 tablo) — `MakerCheckerEntity` tabanı
2. `AnnexHistory` entity'si **yazılmaz** (trigger yazıyor, kod okumuyor)
3. DataManager + Repository
4. Request/Response DTO'ları
5. Handler (Create / Update / Delete / Verify / Reject / List / GetById)
6. Validator'lar
7. Controller
8. Birim testleri

## 5. İş kuralları (dokümandan)
- Her revizyon **yeni satır** (`AnnexCode` + `RevisionNo`) — satır **güncellenmez**
- `AnnexMarginRule`: kapsam başına en çok 2 satır (`OWN` / `COUNTERPARTY`)
- `MarginType = ALL` **yok** — UI 4 satır yazar (`K-24`)
- Kullanılabilirlik: `(StateId & 2) = 2 AND IsEnabled = 1`

## 6. Tuzaklar
- 🔴 **`StateId` testi `== 18` ile YAPILMAZ** — bitmask. `FlowStateHelper.CheckState(...)` kullan
- 🔴 Tarih alanı dış sözleşmede **`DateOnly`** (`DateTime` nokta ayraçlı tarihte 400 verir ve istek `Mediator`'a hiç ulaşmaz)
- 🔴 İş günü kararı `GetLogicalDateAsync()`, kayıt damgası `IDateTimeProvider`. `DateTime.Now` **yazma**

## 7. Bitiş kriteri
1. ✅ 7 uç Swagger'dan çalışıyor
2. ✅ Maker-checker akışı (Create → Verify) DB'de doğru `StateId` üretiyor
3. ✅ `AnnexHistory` trigger'ı UPDATE'te satır yazıyor
4. ✅ Birim testleri yeşil + **sonuç raporlandı**

## 8. Çıktı
`../progress/06-annex.md`
