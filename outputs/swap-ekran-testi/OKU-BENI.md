# Swap ekran testi (DB vs FX API)

Çalıştır: `node swap-compare.js 2026-10-06` (argüman = FX mantıksal tarih, DaysToMaturity için)
FX API `localhost:5011` açık olmalı. fx.txt / pm.txt = sql-log #142/#143 çıktısı (taze veri için yeniden çek).
Beklenen DB'den bağımsız hesaplanır: aktif = (StateId & 7) == 2, SwapRate = (far/near-1)*360/gün*100,
Yield = near non-base tutar * rate/100 * gün/360, sıralama ValueDate, SwapType, PkgNo, LegType, Id.
