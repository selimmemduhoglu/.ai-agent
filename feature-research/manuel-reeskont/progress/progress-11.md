# progress-11 — ✅ BİRİM TESTLER YAZILDI · 59 test, 0 hata

**Tarih:** 2026-08-13 · **Önceki:** [progress-10.md](progress-10.md)
**Tetikleyen istek:** *"o zaman MicroUI geliştirmesi ve tarayıcı testi ve Faz 2 gerçek fiş testleri
dışında unit testler mi kaldı? Eğer ki böyleyse unit testleri de yaz ve bitir. MM projesinde."*
**Kural:** Bu dosya progress-10'un **güncellenmiş tam hali**dir. Öncekiler **düzenlenmedi**.

```text
=== TEST EXECUTION SUMMARY ===
   NetTrex.MM.Api.Services.Tests  Total: 59, Errors: 0, Failed: 0, Skipped: 0, Time: 5.621s
```

✅ `NetTrex.MM` **Build succeeded** · ✅ **59/59 test geçti**

---

## Yazılan test dosyaları

Konum: `Code/UnitTest/Api/NetTrex.MM.Api.Services.Tests/ManuelReeskont/`

| Dosya | Test sayısı | Kapsam |
|---|---|---|
| `Handlers/EligibleTransactionsHandlerTests.cs` | ~24 | Okuma ucu — guard'lar, durum türetme, SubProduct eşleme, sayfalama, `Data` sözlüğü, `RevaluationType` |
| `Handlers/ExecutionsHandlerTests.cs` | ~17 | Yazma ucu — **aksiyon×durum matrisi**, `T-01`, `C-08`, satır bazlı izolasyon |
| `Validators/ManuelReeskontValidatorTests.cs` | ~18 | İki validator — sözleşme § 10 |

Çalıştırma (⚠️ `dotnet test` bu repoda **çalışmaz** — xUnit v3 = MTP):

```bash
Code/UnitTest/Api/NetTrex.MM.Api.Services.Tests/bin/Debug/net10.0/NetTrex.MM.Api.Services.Tests.exe \
  -namespace "*ManuelReeskont*"
```

---

## Neyi sabitledik — sözleşmenin testle korunan maddeleri

### `eligible-transactions`

| Test | Koruduğu karar |
|---|---|
| `Handle_WhenIsFirstLoad_ShouldReturnEmptyAndNeverQueryDataManager` | Ekran ilk açılışta **modüle hiç gitmiyor** (§ 3.1) |
| `Handle_WhenModuleCodeIsNotMm_ShouldFailAndNeverQueryDataManager` | Yanlış modül **sessizce veri döndürmüyor** |
| `Handle_ShouldDeriveStatusFromRediscountReverseId` (3 vaka) | 🔑 **M-08** — `null`→NotRediscounted · `0`→NotReversed · `>0`→Rediscounted. **Canlı veriden çıkarılan kural artık testle kilitli** |
| `Handle_WhenSubProductGiven_ShouldPassMatchingProductTypeIdToDataManager` (4 vaka) | `Murabaha`/`Wakala`/**`Wakale`** yazım toleransı (iş birimi ≠ MM enum yazımı) |
| `Handle_WhenSubProductIsAllOrEmpty_ShouldPassNullToDataManager` (3 vaka) | `All`/boş/null → tümü |
| `Handle_WhenTakeExceedsUpperBound_ShouldClampTo200` · `...IsZero_ShouldFallBackToDefault` · `...SkipIsNegative...` | Sayfalama sınırları (§ 10) |
| `Handle_ShouldPassDateWithoutTimeComponent` | `AccEntryMain.ValueDate` **`date`** tipinde — saat taşınırsa eşleşme kaçardı |
| `Handle_ShouldFillDataDictionaryWithContractKeys` | 12 anahtarın **tamamı** (§ 3.3) |
| `Handle_ShouldRoundMoneyFieldsToTwoDecimals` | 🔴 **Fimple hassasiyet kuralı** (Hard Rule 11) |
| **`Handle_ShouldNotExposeAnyAccountingMessageKey`** | 🔴 `MessageKey` UI'ye **gitmiyor** — eski FX ekranının kusuru **regresyona karşı kilitlendi** |
| `Handle_ShouldFillRevaluationTypeFromFrameworkParameter` (3 vaka) | §4.6 — `Eod`/`Bod`/`Atomic` |
| `Handle_WhenRevaluationTypeParameterThrows_ShouldNotFailTheScreen` | Parametre yoksa **ekran çökmüyor** |

### `executions` — aksiyon×durum matrisi (§ 9)

| Test | Koruduğu karar |
|---|---|
| `Handle_GenerateOnNotRediscounted_...ReturnNotReversed` | T+0 fiş kesiliyor, **ters fiş servisi çağrılmıyor** |
| `Handle_GenerateOnNotReversed_...ReturnRediscounted` | Ters fiş kesiliyor, **revaluation çağrılmıyor** |
| `Handle_GenerateOnRediscounted_ShouldFailWithAlreadyRediscounted` | **C-05** — sessizce atlanmıyor |
| `Handle_RegenerateOnNotRediscounted_ShouldFailWithNotRediscounted` | Geri alınacak fiş yok |
| `Handle_RegenerateOnNotReversed_ShouldReverseThenRevalueThenReverseAgain` | **1 revaluation + 2 ters fiş** çağrısı |
| `Handle_WhenUiStatusDiffersFromDatabase_ShouldFailWithStatusChanged` | §4.5 **yarış koşulu** koruması — hiçbir fiş kesilmiyor |
| **`Handle_ShouldPassCurrentUserIdAsStateMakerToReverseService`** | 🔑 **`T-01` fix'i testle kilitli** — ters fiş artık `SYSTEM` değil |
| `Handle_WhenCurrentUserIdIsEmpty_ShouldLeaveStateMakerNull...` | **Batch davranışı korunuyor** (null → pipeline `SYSTEM`e düşer) |
| `Handle_ShouldUseReverseValueDateForReverseVoucher` | **C-08** — T+1 valörü ters fişe gidiyor |
| `Handle_WhenReverseValueDateOmitted_ShouldDefaultToNextDay` | Varsayılan +1 gün |
| `Handle_WhenRegenerateToTodayUsedWithGenerate_...InvalidOperation` | `RegenerateToToday` yalnız Regenerate'te |
| `Handle_WhenRegenerateToTodayRangeTooLarge_ShouldProcessNothing` | 🔴 **31 gün sınırı — yarım işlem YOK** |
| `Handle_WhenAccountingServiceThrows_ShouldFailOnlyThatRow...` | `ADR-MR-007` satır bazlı izolasyon |
| **`Handle_WhenOneRowFails_ShouldStillProcessTheOtherRow`** | 🔴 Bir satır patlarken diğeri işleniyor **ve `IsSuccess = false`** — mevcut FX akışının en büyük kusuru |
| `Handle_WhenAllRowsSucceed_ShouldReturnIsSuccessTrue` | Tersi de doğru |

### Validator'lar (§ 10)

Boş `Items` · 200 üstü · **aynı `TransactionId` iki kez** · geçersiz `Operation` · gelecek tarih ·
`ReverseValueDate ≤ ExecutionDate` · boş `CurrentUserId` · `IsFirstLoad`'da içerik kurallarının
**atlanması** · `Take` üst sınırının **hata olmaması**.

---

## Uygulanan test kuralları (`test-writer` skill'i)

| Kural | Uygulama |
|---|---|
| `[Collection("CommonCollection")]` + `CommonFixture` | ✅ 3 sınıfta da |
| `[TestSubject(typeof(...))]` · `_sut` · `Method_Scenario_Expected` | ✅ |
| Shouldly | ✅ (`ShouldBe`, `ShouldContain`, `ShouldBeEmpty`) |
| 🔴 **Mock tip-eşleşmesi** (sessiz hata tuzağı) | `GetRevaluationByValueDateAsync(long, DateTime, CT)` → `It.IsAny<long>()`. `int` yazılsaydı mock **default dönerdi** ve testler yanlış davranışı doğrulardı |
| 🔴 **`FlowHandler.UnitOfWork` NRE** | Sorun **çıkmadı**: okuma ucu salt-okunur, yazma ucu commit'i **muhasebe servislerinin içinde** yapıyor (mock'lu). `try/catch(NRE)` anti-pattern'ine **başvurulmadı** |
| `ValueTask` dönüşleri | `.Returns(ValueTask.FromResult(...))` — açık ve güvenli |
| FluentValidation | `TestHelper` → `_sut.TestValidate(req)` + `ShouldHaveValidationErrorFor` |

---

## 🔵 YAPILIYOR

Yok.

---

## ⬜ YAPILACAK — kod tarafında iş KALMADI

| # | İş | Durum |
|---|---|---|
| 1 | **Menü + permission scriptlerini uygula** (`outputs/`) | Selim — ekran bunlarsız açılmaz |
| 2 | 🔴 **Tarayıcı testi** — kontrol listesi [`08-test-rehberi.md`](../08-test-rehberi.md) § 7 (~40 madde) | Selim + ben |
| 3 | **Faz 2 gerçek fiş testi** onayı (Fimple'a yazar) | Selim |
| 4 | **Faz 4 — MicroUI / Packages** | ⏸️ *"ben deyince"* |
| 5 | `Ö-S-01…08` Fimple · `Ö-04`/`Ö-05` muhasebe · `C-20` eski ekran kararı | Selim |

---

## Kararlar bu turda

| Karar | Gerekçe |
|---|---|
| `MessageKey` **yokluğu** için açık test yazıldı | Sözleşmenin "negatif" maddesi; regresyonu yakalayacak tek şey test |
| `Wakale` yazımı da kabul ediliyor ve **testle sabitlendi** | İş birimi `Wakala` diyor, MM enum'ı `WAKALE` — satır kaybolmasın |
| `CurrentUserId` boşken `StateMaker = null` beklentisi test edildi | **Batch davranışının korunduğunun** kanıtı (Hard Rule 10 — ortak pipeline) |
| Aksiyon×durum matrisinin **her hücresi** ayrı test | Fiş üreten dallanma; yanlış hücre canlıda geri alınamaz fiş demek |
