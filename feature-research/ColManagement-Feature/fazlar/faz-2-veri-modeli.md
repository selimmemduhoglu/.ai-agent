# Faz 2 — Veri Modeli (Excel v5)

**Durum:** ✅ BİTTİ (2026-10-07) · **Kayıt:** [`../progress/02-excel-v5.md`](../progress/02-excel-v5.md)

## 1. Amaç

DDL'in **tek kaynağı** olan tablo/kolon şemasını kesinleştirmek.

## 2. Çıktı

🔑 [`../2026-10-07-Collateral-DB-Sema-v5.xlsx`](../2026-10-07-Collateral-DB-Sema-v5.xlsx) — 32 sheet.

| Sheet grubu | İçerik |
|---|---|
| `00_Surum_Gecmisi` | v1→v5 ne değişti, **neden** |
| `00_Genel_Bakis` | 3 ekran · tablo kategorileri · Id stratejisi · açık kararlar |
| `00_Tip_Kurallari` | 🔴 PK `bigint` · para `decimal(38,10)` · oran `decimal(18,10)` · float YASAK |
| `00_Sabitler` | StateId bitmask · ActionId · 30+ kod listesi · FrameworkParameter · DefNumberGen seed · logical date tuzağı |
| `00_DB_Nesneleri` | Tablo dışında üretilecek kalemler |
| `00_Constraint_Index` | PK/UQ/IX/DF adları + "DB zorlayamaz" servis invariant'ları |
| `00_Iliskiler` | FK→PK haritası |
| `00_History_Tablolari` | 4 History tablosu + trigger kuralları |
| `00_CoreDataSlice` | Referans verisi paketten gelir, **kod yazılmaz** |
| `00_Platform_Tablolari` | Flow · DefNumberGen · muhasebe fişi · Hangfire + modülün tanındığı 4 yer |
| 21 tablo sheet'i | Kolon · Tip · Null · Default · Index/Constraint · FK · Açıklama |

## 3. 🔴 Excel kuralı

**Her güncellemede sürüm +1 ve YENİ dosya adı.** Eski dosya yerinde kalır.
`00_Surum_Gecmisi`'ne **ne** ve **neden** satırı yazılır.

## 4. ⬜ v6'yı tetikleyecek şeyler

- Faz 0 kararları (modül kodu, sayaç öneki) → `00_Sabitler`
- 🔄 `ColManagementRevaluation` / `ColManagementAuditLog` yeniden adlandırması
- İş birimi toplantısı cevapları (`A-13`…`A-21`)
- `CoreDataSlice` üye listesi netleşince → `00_CoreDataSlice`

## 5. Tuzaklar

- ⚠️ **ExcelJS:** `cell.value.formula` kontrolü yetmez — paylaşılan formüllerde `sharedFormula`
  da kontrol edilmeli, yoksa kaydederken
  `Shared Formula master must exist above and or left of clone` hatası gelir.
- ⚠️ **Yeniden adlandırmada sıra kritik:** uzun ad önce (`DefCollateralAnnexProductScope` →
  `DefCollateralAnnex` → `DefCollateral`). Kısa önce uygulanırsa `DefCollateralAnnex` →
  `CollateralDefinitionAnnex` olur.
- ⚠️ **Sheet adı sınırı 31 karakter.**
- ⚠️ Excel kullanıcıda açıksa yazma **EBUSY** verir — yeni dosya adı bunu da çözüyor.
