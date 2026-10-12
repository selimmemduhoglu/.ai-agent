# progress-63 — Notrleme eski sirasina dondu + Rediscounted'da Generate acildi (tum moduller) (2026-09-28)

> Onceki tur: [progress-62](progress-62.md). Tetikleyen: progress-62'deki "kopya T+n / tersi T" akisi da UAT'ta
> Fimple 24178 verdi. PO karari: notrleme **ilk haline** (1-2-3-4) doner; yarim kalan Regenerate icin
> Rediscounted satirda **Generate** acilir (bilincli kullanim, mizana bakilarak).

## Yapilanlar

1. **Notrleme sirasi eski haline (1 = ayna T, 2 = aynanin tersi mevcut ters fisin gercek valoru, Fimple ters alma):**
   - MM `RevaluationMirrorAccountingService` elle eski koduna cevrildi (HEAD = PR 12511 2-1/kopya surumunu iceriyordu).
   - DerivSwp `RevaluationMirrorService`, OptionsFX `RevaluationMirrorAccountingService`: HEAD'e restore (2-1 commit'lenmemisti).
   - FX: `neutralizeReverseFirst` / `updateRepository` tamamen kaldirildi (`ValuationService`, `FutureValuationService`,
     `ExternalValuationService`, 3 arayuz, `FxManualRediscountEngine` HEAD'e restore). `RevaluationReverseOperation`'a dokunulmadi.
   - MM statu korumasi (progress-62, "tersi onceki gune kesilmis reeskont") 3 veri dosyasindan kaldirildi.
2. **Generate / Rediscounted → yeni reeskont (notrleme YOK) → Not Reversed** — 4 modul handler'i
   (`case NotRediscounted: case Rediscounted:`). Sonraki Generate normal akisla ters fisi keser.
   FX'te `LoadPreValuation` ve grid valuation alt sorgusu en son valuation'i (Id desc) okuyor → dogru fis terslenir.
3. **UI (Common.UI + WebUI):** Rediscounted secimde Generate artik pasif degil (`mrAllRediscounted` blogu kalkti);
   Generate onayinda Rediscounted grubu "Rediscount entry T+0 → Not Reversed" + uyari notu
   (`mr-confirm-NoteGenerateOnRediscounted`: "Mevcut dongu notrlenMEZ… tamamlanmis kayitta tahakkuku ikiler").
   Bilgi penceresi metinleri (gen/regen Rediscounted) ve Regenerate onay sirasi/metinleri eski haline.

## Dogrulama

MM handler 92/92 · MM mirror 4/4 (eski akisa gore yeniden yazildi) · MM data 2/2 · DerivSwp 75/75 ·
OptionsFX 69/69 · FX 38/38 · WebUI jest 471/471 · Common.UI typecheck ✅. Tarayici / Fimple testi YOK.

## Sonradan (ayni gun) — PO kararlari

- ❌ **Rediscounted'da Generate GERI ALINDI**: saglam satirda tahakkuku ikiler, ekrandan geri alinamaz.
  4 modul handler'i + testler + UI (toolbar blogu, onay grubu, bilgi metni, lokalizasyon) eski haline.
  Madde 2 artik gecersiz. Yarim kalan Regenerate durumu icin cozum ACIK.
- ✅ **Sunucu tarafi sayfalama iptal** (her sayfada statu sayimi pahali). Mevcut tarayici sayfalamasi kalir.
- ✅ **Tek istek tavani kaldirildi**: MM / DerivSwp / OptionsFX / FX `EligibleTransactionsHandler.MaxTake` (2000)
  silindi; UI `MR_MAX_LOAD_ROWS = 2147483647` (C# int.MaxValue = "hepsi"). FX repository `skip + take` tasma
  korumasi. Take <= 0 → 50 (degismedi).

⬜ Commit YAPILMADI.
