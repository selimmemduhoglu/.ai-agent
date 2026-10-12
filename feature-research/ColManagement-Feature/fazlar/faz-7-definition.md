# Faz 7 — CollateralDefinition Ucu

**Durum:** ⬜ · **Ön koşul:** Faz 6 (desen kuruldu)

## 1. Amaç
`CollateralDefinition` + **6 alt tablo**, Cash/Security varyantıyla.

## 2. Önce oku
- [`../bilgi-bankasi/09-tablolar-neden-var.md`](../bilgi-bankasi/09-tablolar-neden-var.md) — uygunluk kuralı, haircut, FX adjustment
- Excel v5 → `CollateralDefinition` + `CollateralEligibleCurrency` · `CollateralCashTerms` · `CollateralSettlementMap` · `CollateralSecurityRule` · `CollateralSecurityISIN` · `CollateralSecurityTerms`

## 3. Varyant kuralı
| `CollateralType` | Dolan alt tablolar |
|---|---|
| `CASH` | `CollateralEligibleCurrency` · `CollateralCashTerms` · `CollateralSettlementMap` |
| `SECURITY` | `CollateralSecurityRule` **veya** `CollateralSecurityISIN` (`SecurityScope`'a göre) · `CollateralSecurityTerms` · `CollateralSettlementMap` |

🔴 **İkisi birden dolmaz.** Validator bunu zorlar (DB'de CHECK constraint **yok**, `K-07`).

## 4. Faz sınırı
⚠️ `CollateralCashTerms` **saklanır, hesaplanmaz** — faiz/tahakkuk motoru bu fazda yazılmaz (`K-22`).
⚠️ Menkul tarafı tablo + CRUD olarak kurulur; **değerleme** Faz 9'da.

## 5. Bitiş kriteri
1. ✅ Cash ve Security varyantları ayrı ayrı yaratılıp onaylanabiliyor
2. ✅ Yanlış varyanta alt satır yazma denemesi **reddediliyor**
3. ✅ `CollateralDefinitionHistory` doluyor
4. ✅ Testler yeşil + raporlandı

## 6. Çıktı
`../progress/07-definition.md`
