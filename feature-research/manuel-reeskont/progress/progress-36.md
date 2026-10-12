# progress-36 — 🔴 Regenerate valörleri SABİTLENDİ (analist kararı)

**Tarih:** 2026-08-20 (5. tur)
**Tetikleyen:** Kullanıcı iş analistiyle konuştu → Regenerate'te valör **sorulmayacak**

---

## 1. Kararın kendisi

Kullanıcının sözleri:

> *"Regenerate'te tersini kesme valör günü sorma popup'ını getirmiyoruz artık… ben hard olarak
> tersi için T+1 vereceğim, yani reeskontu kapatmış olacağım bu butonla. Nötreleme için zaten
> execute tarihinde olacak ve sonra da reeskontu execute tarihine kes ve tersini de bir sonraki
> güne kes ki o gün içinde reeskont düzgün bir şekilde kesilmiş olsun."*
>
> *"Artık sormuyoruz Regenerate'te tersi için T+0 mı T+1 mi istiyorsun diye. Generate yine aynı
> devam edecek."*

### Yeni kural tablosu

| Satırın durumu | Ne oluyor | Valörler |
|---|---|---|
| `Not Rediscounted` | ② yeni reeskont → ③ yeni ters fiş | ② **T+0** · ③ **T+1** |
| `Not Reversed` | ① nötrle → ② yeni reeskont → ③ yeni ters fiş | ① **T+0** · ② **T+0** · ③ **T+1** |
| `Rediscounted` | (çift zaten kapalı) ② yeni reeskont → ③ yeni ters fiş | ② **T+0** · ③ **T+1** |

**Hiçbiri kullanıcı seçimine bağlı değil.** Popup kaldırıldı.

### Kullanıcının sorduğu soruya cevap

> *"① ve ③ için benim seçtiğim valörün geçerli olması mantıklı mı?"*

**Hayır, değildi** — ve karar bunu düzeltti. ① **eski** döngüyü kapatan kayıt; valörü yeni
döngüyle ilgili bir tercih değil, muhasebe gereği. Aynı gün açılan reeskont **aynı gün** kapanmalı
ki o günün defterinde açık bırakılmış bir tahakkuk kalmasın. T+1 verilseydi eski fiş **bir sonraki
güne** kapanır, o günün defterinde **hem eski hem yeni** reeskont açık görünür ve **çift tahakkuk**
okunurdu — gerçek para, hata mesajı yok.

---

## 2. Dokümanla ilişki — bu bir SAPMA DEĞİL, DÖNÜŞ

| Doküman | Ne diyor |
|---|---|
| § 4.3 | *"…yeni reeskont kaydı oluşturulur ve buna karşılık gelen ters fiş kaydı **T+1 valörü ile** yeniden oluşturulur"* → valör **sabit** |
| § 8.2 | *"**Not Reversed** durumunda Execute öncesi ters fişin valörü sorulur… **Diğer durumlarda seçim sorulmaz.**"* |

🔴 Yani doküman Regenerate'te **hiç sormuyordu**. 2026-08-20 sabahı eklediğim soru (`D-12`)
dokümandan **sapmaydı**; kaldırılması **dokümana dönüş**. `D-12` **KAPANDI**.

⚠️ Dokümanın tanımlamadığı tek nokta ①'in (nötrleme kaydının) valörüydü. Analist bunu
**T+0** olarak netleştirdi — artık açık uç değil.

---

## 3. Kod değişiklikleri

### `NetTrex.MM` — `ExecutionsHandler.cs`

**a) Döngüde valör aksiyona göre:**

```csharp
var dayReverseDate =
    operation == RediscountOperation.Regenerate || catchUpDates.Count > 1
        ? (await calendarHelper.NextWorkingDayAsync(date, cancellationToken: cancellationToken)).Date
        : reverseValueDate;
```

- **Generate** → `reverseValueDate` (kullanıcının seçtiği T+0/T+1) — **değişmedi**
- **Regenerate** → her zaman `NextWorkingDay(date)` = **T+1**
- ⚠️ `request.ReverseValueType` Regenerate'te **yok sayılıyor**. Sözleşme alanı **duruyor**
  (Generate için gerekli), sadece Regenerate onu okumuyor.

🔑 Faz 2 (`RegenerateToToday`) zaten gün başına `NextWorkingDay(date)` istiyordu → yeni kural
onunla **kendiliğinden aynı hatta**; tek tarih ile çok tarih arasında davranış farkı kalmadı.

**b) `RegenerateAsync` — nötrleme T+0:**

```csharp
// ESKİ: reverseValueDate (kullanıcının seçtiği)
// YENİ: executionDate (T+0)
if (status == RediscountStatus.NotReversed)
    await CreateReverseAsync(existing!, item.LogicalReference, executionDate, currentUserId, ct);
```

Yeni ters fiş (③) `reverseValueDate` kullanmaya devam ediyor — ama çağıran artık oraya **her zaman
T+1** geçiriyor.

### `NetTrex.Web.UI`

| Dosya | Değişiklik |
|---|---|
| `component.js` | Valör sorusu **yalnız `operation === GENERATE`** + seçimde `Not Reversed` satır varsa. Regenerate dalı **kaldırıldı** |
| `actions.js` | `mrAskReverseValueType(rows)` — `operation` parametresi **kaldırıldı** (tek metin kaldı). Regenerate onay penceresinin alt satırı artık **her zaman `T+1` + `(sabit)`** notu |
| localization ×2 | `mr-rvt-LeadRegenerate` **silindi** · `mr-confirm-Fixed` (`(fixed)` / `(sabit)`) **eklendi** |

⚠️ `ReverseValueType` istekte hâlâ gönderiliyor (Regenerate'te `T1` varsayılanı) — modül yok
sayıyor. Sözleşme değişikliği **yok**.

---

## 4. 🔴 Yeni testler — davranış kilitlendi (190 → 193)

| Test | Ne kilitliyor |
|---|---|
| `Handle_RegenerateOnNotRediscounted_ShouldIgnoreReverseValueTypeAndUseNextWorkingDay` | İstek `T0` dese bile yeni ters fiş **takvimin verdiği T+1**. Mock `ExecDate.AddDays(3)` döndürüyor → `AddDays(1)` **olmadığını** da kanıtlıyor |
| `Handle_RegenerateOnNotReversed_NeutralizeShouldBeT0_AndNewReverseShouldBeT1` | 🔴 **İki ters fiş, İKİ FARKLI valör**: ① `ExecDate`, ③ `ExecDate.AddDays(3)`. Nötrlemenin T+1'e kaçmadığını kilitler — kaçarsa **çift tahakkuk** |
| `Handle_GenerateShouldStillHonourReverseValueTypeT0_AfterRegenerateRuleChange` | Generate'te `T0` **hâlâ** onurlandırılıyor — Regenerate düzeltmesi Generate'i **etkilemedi** |

---

## 5. Doğrulama

| Ne | Sonuç |
|---|---|
| MM testleri | **193 / 0 hata** (3 yeni) |
| JS testleri | **344/344** |
| `dotnet build NetTrex.MM.Api.Services` | **0 Error** |
| `dotnet build NetTrex.MM.Api` | ⚠️ **24 error — KOD DEĞİL**: `MSB3021` dll kilitli, MM API **çalışıyor**. Kullanıcı API'yi durdurup derlemeli |
| Sarkan referans taraması | temiz |
