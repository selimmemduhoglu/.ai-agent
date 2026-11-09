# 28 — INCI veri modelinden alınanlar uygulandı (faiz parametre tabloları, margin rule → Annex, ödeme snapshot bloğu)

**Tarih:** 2026-10-21 · **Faz:** 4/6/7/8/11 · **Kaynak analiz:** [`05-INCI-VERI-MODELI-KARSILASTIRMA.md`](../05-INCI-VERI-MODELI-KARSILASTIRMA.md) §4

Kullanıcının sözü: *"Excel'in daha iyi olduğu yerler… al ve bizim daha iyi olduğumuz yerler içinde bizim ki kalsın… FloatingRateType ve benzeri tabloları al… MM DB'sinden de yararlanabilirsin."*

## Değişiklikler

| §4 madde | Ne yapıldı |
|---|---|
| **4 — Faiz parametreleri** | `RateType` · `InterestMethod` · `InterestMethodFrequency` tabloları NetTrexMM şemasıyla açıldı (Id seed, IDENTITY değil, `ValueGeneratedNever`); `FloatingRateType` MM'deki 15 satırla dolduruldu. `CollateralCashTerms`: `RateType`/`ReferenceRateCode`/`SpreadBps`/`CompoundingMethod`/`DayCount`/`PaymentFrequency` (enum metinleri) **silindi** → `RateTypeId`/`FloatingRateTypeId`/`Spread`/`InterestMethodId`/`DateBasisCode`/`InterestMethodFrequencyId` (MM `TxnLoan` kolon adları). 4 enum silindi. 4 lookup ucu (`api/rate-type`, `interest-method`, `interest-method-frequency`, `floating-rate-type` → `select-f-key`). UI formu SelectBox'larla API'den doluyor (+ `DateBasis` Common'dan) |
| **1 — Margin kuralı sözleşmeye bağlı** | `AnnexMarginRule.ProductScopeId` → `AnnexId`, tekillik `(AnnexId, Party, CurrencyCode)`. `Annex.MarginRules` (backend + UI modeli), Create/Update/Get handler'ları annex seviyesinde; UI'de margin grid'i ürün kapsamı seçimine bağlı değil |
| **3 — Ödeme snapshot bloğu** | `TxnTransaction` + `TxnTransactionDetail`: 4 SSI Id'si silindi → MM `TxnLoan`'ın 22 muhabir alanı + `TxnMM`'in 3 `*MessageStatus` alanı (uzunluklar canlı MM DB'sinden). Ortak arayüz `ICollateralPaymentFields` + `CopyPaymentFieldsTo`. `Instructions` 500→1000. Validator: We Send/They Receive/We Receive/They Send kuralları muhabir Id'leriyle aynı anlamda yeniden yazıldı. UI 4 kutu korunup yeni alanlara bağlandı |
| **5 — Detail'da margin tipi** | `TxnTransactionDetail.MarginType nvarchar(15) NOT NULL` (enum string, bizim enum saklama kuralı) |
| **2 — Başlıkta hareket yok** | ⏸ **ERTELENDİ** — Create/Verify/muhasebe/position/UI akışını baştan kurmayı gerektiriyor; tasarım soruları kullanıcıya soruldu (aşağıda) |

**Bizde kalanlar (değiştirilmedi):** `CollateralEligibleCurrency` · `CurrentBalanceBefore/After` + `CollateralPosition` · versiyon/History · `IsEnabled` · `IsIncluded`.

## Script'ler

`Treasy.ColManagement/.ai-agent/outputs/2026-10-21-ColManagement-InciModelUyarlama/` — sıra **0 → 1 → 2 → 0**:
- `0-DOGRULAMA-…sql` salt-okunur
- `1-…FaizParametreTablolari.sql` — 3 tablo DDL + 27 seed (idempotent, mevcut satır ezilmez)
- `2-…ModelUyarlama.sql` — tek TRY/CATCH; 4 tablodan biri doluysa `THROW 50001` (kolon silme veri kaybı)

Sıfırdan kurulum seti (`2026-10-14-ColManagement-Kurulum/1-DDL` + `6-DML`) aynı değişikliklerle güncellendi.

## Kararlar
- MM'de olmayan 2 seed satırı PO speki için eklendi: `RateType 3 InterestFree`, `InterestMethodFrequency 7 OnReturn` — **kullanıcı onayı bekliyor**.
- `CompoundingMethod = None` artık `InterestMethodId = null`.
- `DateBasisCode nvarchar(4)` — Common `DateBasis.BasisCode` (Id değil, MM `TxnLoan` de kod tutuyor).
- Muhabir Id'leri UI'de numara kutusu: Fimple'dan dolduran Payment component henüz yok.

## Doğrulama
- `NetTrexColManagement` ölçümü (sql-log `colmanagement-inci-model-uyarlama` #5): 4 tablo **0 satır** → koruma tetiklenmez.
- Backend `Treasy.ColManagement.sln` build **0 hata**; UI sln build 0 hata, `tsc` yalnız değişiklikten **önce de olan** 11 TS2581 (`git stash` ile karşılaştırıldı).
- 🔴 **Doğrulanmayan:** script'ler DB'de çalıştırılmadı (kural: kullanıcı uygular); servisler ayağa kaldırılmadı; Annex Mapster graf davranışı çalışma zamanında denenmedi (H-096).

## Açık kalanlar
- §4.2 (K-44) tasarım soruları — ilk hareket başlıkla mı · Detail başına flow onayı mı · Detail başına fiş · `TxnTransactionCash` + başlık hareket kolonları kalkacak mı.
- H-096 · H-097 · H-098.
