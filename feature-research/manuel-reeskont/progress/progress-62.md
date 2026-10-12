# progress-62 — Regenerate/Rediscounted notrleme: Fimple 24178 duzeltmesi (yalniz MM) (2026-09-28)

> Onceki tur: [progress-61](progress-61.md). Tetikleyen: UAT'ta `TMMBRW2608170002`, ExecutionDate 23.09,
> Regenerate → `Fimple Error => Code: 24178, Message: Reeskont muhasebesi (...) zaten mevcut.`
> (3. adim: yeni reeskont).

## Kok sebep

progress-61'deki 2-1 akisi iki notrleme kaydini Fimple'a **birbirinden bagimsiz iki reeskont fisi** olarak
gonderiyordu. T'deki kayit Fimple icin "tersi alinmamis reeskont" -> ayni gune yeni reeskont reddedildi.

## Yeni akis (PO onayi 2026-09-28)

| # | Kayit | Valor | Bacak | Fimple |
|---|---|---|---|---|
| 1 | Reeskontun AYNI bacakli kopyasi | mevcut ters fisin GERCEK valoru (DB'den, T+1 varsayilmaz) | reeskontla ayni | reeskont fisi |
| 2 | Kopyanin tersi | T | ters | **ters alma** (kopyanin MessageKey'i) |
| 3-4 | Yeni reeskont + tersi | T / T+1 | | degismedi |

- `RevaluationMirrorAccountingService`: kopya kur → Fimple reeskont → DB + Kafka → commit → standart
  `RevaluationReverseAccountingService` (ters alma, "Ters Fis:" aciklamasi, ReverseId baglari) valor T.
  Fabrika bagimliligi kalkti.
- **Koruma kurali** ("tersi kendisinden ONCEKI bir gune kesilmis reeskont o gunun reeskontu sayilmaz"):
  kopya T+n'de ters olmayan reeskont olarak durdugu icin olmadan T+n statusu yanlis okunur ve
  **gun sonu batch'i T+n reeskontunu atlardi**. Eklenen yerler:
  `AccountingDataManager.GetRevaluationByValueDateAsync` · `TransactionDataManager` / `TransactionLoanDataManager`
  liste alt sorgulari + `noRevaluationQuery` + `revaluationReverseCheck`.
  `ReverseId == 0` filtreli okuyucular (ters fis batch'leri, silme, son aktif reeskont) etkilenmiyor.
- Onay penceresi metni (Common.UI + WebUI): "Mevcut reeskontun kopyasi, ters fisin valorune — mevcut ters
  fisi notrler" / "Onun ters fisi (T+0) — mevcut reeskontu notrler". Diger modullerde de dogru (bacak/tarih
  ayni, fark yalniz Fimple modellemesi).

## Dogrulama

MM mirror 4/4 (yeni) · AccountingDataManager koruma 3/3 (yeni) · MM handler 92/92 · MM API build ✅ ·
Common.UI typecheck ✅ · WebUI jest 470/470. Tarayici / Fimple testi YOK.

## UAT'ta bakilacak

1. Fimple geriye tarihli ters almayi (kopya T+n, tersi T) kabul ediyor mu.
2. T+n gununun kendi reeskontu Fimple'da acikken 1. kayit yine 24178 alir mi.

## TODO

- MM'de calisirsa DerivSwp / OptionsFX / FX'e ayni desen (FX'te `RevaluationReverseOperation` aciklama
  mantigina DOKUNMADAN).

⬜ Commit YAPILMADI.
