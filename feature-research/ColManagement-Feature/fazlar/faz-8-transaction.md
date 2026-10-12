# Faz 8 — TxnTransaction Ucu + Bakiye

**Durum:** ⬜ · **Ön koşul:** Faz 7 · 🔴 **Modülün kalbi — para burada hareket ediyor**

## 1. Amaç
Increase/Decrease hareketi, alt tipleri, bakiye güncellemesi ve detay sekmesi sorgusu.

## 2. Önce oku
- [`../bilgi-bankasi/09-tablolar-neden-var.md`](../bilgi-bankasi/09-tablolar-neden-var.md) — uçtan uca örnek
- [`../bilgi-bankasi/08-tuzaklar.md`](../bilgi-bankasi/08-tuzaklar.md) — **tamamı**
- Excel v5 → `TxnTransaction` · `TxnTransactionCash` · `TxnTransactionSecurity` · `CollateralPosition`

## 3. Kurallar
| Konu | Kural |
|---|---|
| `Id` | 🔴 `DefNumberGen` sayacından — **IDENTITY değil**. EF: `.ValueGeneratedNever()` |
| `LogicalReference` | `sp_GetNewRefNumber` üretir |
| Yön | `INCREASE` = para **bana** gelir · `DECREASE` = **benden** çıkar (transcript'te 3 kez teyit) |
| Alt tip | `CollateralType`'a göre `TxnTransactionCash` **veya** `TxnTransactionSecurity` — 1:1, PK = FK |
| Snapshot | `CurrentBalanceBefore` işlem anındaki bakiyeyi **saklar** (sonradan kanıt) |
| Kur | `FxRateSource` = `SYSTEM` / `MANUAL` — elle girilen kur işaretlenir |
| Detay sekmesi | **Kendi tablosu YOK** — aynı `CollateralDefinition`'ın `TxnTransaction` satırları + running balance |

## 4. 🔴 Bakiye — eşzamanlılık
`CollateralPosition` **zorunlu** (`K-15`). Decrease işleminde satır `UPDLOCK` ile kilitlenir.
İki eşzamanlı Decrease'in bakiyeyi aşmasını engelleyen **tek deterministik yol** bu.

## 5. Tuzaklar
- 🔴 **Toplu yazma döngüsü:** bir satırın `Added` artığı sonrakinin `Commit`'ine karışır →
  kullanıcının *"hata"* gördüğü satır gerçekte **kayıt yazmış** olabilir. Satır başına
  `ChangeTracker.Clear()`. İzolasyon **lifetime'dan değil scope'tan** gelir (`Transient` çözmez).
- 🔴 **`Where(...)` içinde required navigation** → INNER JOIN → kayıt "yok" görünür → **mükerrer**
  kayıt üretilir. `EXISTS` / `Any(...)` kullan.
- 🔴 **Dış uca makullük sınırı koymak çözüm değil** — büyük değer çökme üretiyorsa doğru cevap
  **kök sebep**. (Ölçülmüş emsal: `decimal(36,18)` kolonuna 1e11 yazınca .NET `decimal` 28 anlamlı
  basamak sınırını aşıyor.) ⚠️ Sınır konacaksa **aynı kolona yazan TÜM alanlara** birlikte konur.

## 6. Bitiş kriteri
1. ✅ Increase + Decrease uçtan uca, bakiye doğru
2. ✅ Eşzamanlı iki Decrease testi — bakiye **aşılmıyor**
3. ✅ Detay sekmesi sorgusu running balance üretiyor
4. ✅ `TxnTransactionHistory` doluyor
5. ✅ Testler yeşil + raporlandı

## 7. Çıktı
`../progress/08-transaction.md`
