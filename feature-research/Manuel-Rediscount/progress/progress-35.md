# progress-35 — Fimple 3058 teşhis edildi, dark mode dialog, sonuç penceresi

**Tarih:** 2026-08-20 (4. tur)
**Tetikleyen:** Kullanıcının Seq log'ları + 3 ekran isteği

---

## 1. 🟢 Fimple hatası TEŞHİS EDİLDİ — konfigürasyon, kod değil

Kullanıcı Seq log'larını attı. `RefitExtension` düzeltmesi işini yaptı: hata artık
*"Failed to parse the API response"* değil, Fimple'ın **kendi mesajı**:

```
Fimple Error => Code: 3058, Message: Hesap tanımında defter türündeki muhasebe hesapları için
referans türü ve referans no alanları boş olmalıdır. Defter hesabı: (36099200)
```

Kullanıcı doğruladı: *"şu an loglara baktığım zaman güzel gidiyor, Fimple tarafından gelen
hataları direkt yazıyor."*

### Kök sebep

Gönderilen gövdede **2. detay satırı**:

```json
{ "GLAccount": "36099200", "ReferenceType": "TreasuryAccount", "ReferenceNumber": "346178" }
```

`36099200` Fimple'da **defter (ledger) hesabı** → referans alanları **boş** olmalı.

`FimpleAccountingDetailModelMapper.cs:46-57` tek bir şeye bakıyor:

```csharp
var isReferenceType = accountingEntryModel.CustomerAccountCode != null;
```

GL'in defter hesabı olup olmadığına **bakmıyor** — bakamaz da, o bilgi Fimple'da. Muhasebe
motoru (`AccAccountMapId 23298`, `RuleId 33340`) defter hesabı için de `CustomerAccountCode`
(`346178`) üretiyor; mapper görevini yapıp referans alanlarını dolduruyor.

### 🔴 Kullanıcının "manuel mi batch mi" sorusunun kesin cevabı: FARK YOK

`FimpleAccountingDetailModelMapper` ve `FimpleAccountingService` **paylaşılan**; EOD batch de
`15_RevaluationAccountingSyncStep` üzerinden aynı yerden geçiyor. Aynı transaction batch'te
çalıştırılsa **aynı 3058**'i alır.

⚠️ Bu kalem `00-PANO.md`'de **zaten açıktı**: *"`AccAccountMap` config errors
(`36099200`/`36199200`)"*. Log yeni bir bulgu değil, **teyit** getirdi.

### Çözüm — kod DEĞİŞTİRİLMEDİ

`AccAccountMap` `23298` satırı defter hesabı için müşteri hesap kodu üretmemeli.
`CustomerAccountCode` `null` olduğunda mapper **kendiliğinden** `ReferenceType: null` +
`ReferenceNumber: null` gönderiyor → Fimple kabul eder. **Kod değişikliği gerekmiyor.**

Mapper'a "defter hesabı listesi" koymak reddedildi: o bilgi Fimple'ın hesap tanımında, MM'de
ikinci kopya tutmak kaçınılmaz sapma üretir; ayrıca mapper **tüm** MM muhasebe akışlarında ortak
(2026-08-19 kuralı).

Detay + doğrulama adımı → [`outputs/2026-08-20-fimple-3058-defter-hesabi.md`](../../outputs/2026-08-20-fimple-3058-defter-hesabi.md)

### Yan bulgu

Log'daki her iki detayda `"FxRate": 0.0`. TRY/TRY'de zararsız ama **PANO'daki açık kalem**;
yabancı para reeskontunda kur hesabı yanlış olabilir.

---

## 2. Regenerate'te ters fiş valörü kimin için geçerli — cevap

**Kullanıcının sorusu:** *"Regenerate'te her koşulda popup açıyoruz; bazı transaction'ların
statüsü `Rediscounted` olduğunda ve toplu işlem seçtiğimde T+0/T+1 seçmem bu işlemler için ne
ifade edecek? Çünkü tersi kesilmişler için Regenerate yaptığında sadece reeskontu kesilecek
olanlar olacak…"*

🔴 **Premis yanlış — Regenerate HER satır için yeni bir ters fiş de kesiyor.**
`RegenerateAsync` (`ExecutionsHandler.cs:330-361`) üç dala ayrılıyor ama **üçü de** aynı yerde
bitiyor:

| Satırın durumu | Ne yapılıyor | Seçilen valör nereye uygulanıyor |
|---|---|---|
| `Not Rediscounted` | yeni reeskont (T+0) → **yeni ters fiş** | **yeni ters fiş** |
| `Not Reversed` | ① açık fişi nötrle → ② yeni reeskont (T+0) → ③ **yeni ters fiş** | ① **ve** ③ (ikisi de aynı valör) |
| `Rediscounted` | çift zaten kapalı → yeni reeskont (T+0) → **yeni ters fiş** | **yeni ters fiş** |

```csharp
if (status == RediscountStatus.NotReversed)
    await CreateReverseAsync(existing!, item.LogicalReference, reverseValueDate, …);   // ①

await CreateRevaluationAsync(item.TransactionId, executionDate, sourceType, …);        // ②
var created = await accountingDataManager.GetRevaluationByValueDateAsync(…);
await CreateReverseAsync(created, item.LogicalReference, reverseValueDate, …);         // ③
```

Doküman § 4.3 de aynısını diyor: *"mevcut reeskont ve ters fiş kayıtları karşı kayıtları ile
kapatılır. Ardından… yeni reeskont kaydı oluşturulur **ve buna karşılık gelen ters fiş kaydı
T+1 valörü ile yeniden oluşturulur**."*

**Sonuç:** seçilen T+0/T+1, Regenerate'te **istisnasız her seçili satır** için anlamlı.
"Sadece tersi kesilecekler için geçerli" değil — hepsi için yeni bir ters fiş kesiliyor.

### ⚠️ Bilinçli bırakılan ayrıntı (dokümanda tanımsız)

`Not Reversed` dalında **①** (eski açık fişi nötrleyen ters fiş) da **aynı** valörle kesiliyor.
Doküman kapatma kaydının valörünü tanımlamıyor. Alternatif, o fişi kendi orijinal tarihine göre
kapatmak olurdu. Aynı valörü kullanmak tercih edildi çünkü kullanıcı **tek** bir valör seçiyor ve
iki farklı valör onay penceresinde anlatılamaz. **İş birimine sorulmalı.**

---

## 3. Ekran düzeltmeleri

| # | İstek | Ne yapıldı |
|---|---|---|
| 1 | *"dark mode'da valör popup'ında yazılar okunmuyor, normal modda çok güzel"* + *"dark moda özel bir şey yapmadan çöz"* | 🔴 **Dark mode'a özel HİÇBİR seçici kullanılmadı** (`@media` yok, `.dx-theme-dark` yok). Dialog **kendi kendine yeterli** hale getirildi: `.mr-dialog .dx-popup-content` zemin `#fff` + metin `#1f2937`, `.mr-rvt-option` zemin/metin açıkça, seçili seçenek `#EAF3FC` üzerine **`#14395F`** metin, `accent-color` radyo için. Pencere artık iki modda da **dokümandaki tasarımın aynısı** (görsel de açık zeminli + lacivert başlıklı) |
| 2 | *"T+0 seçeneği T+1'in üstünde olsun"* | ✅ sıra değişti. ⚠️ **Varsayılan hâlâ T+1** (`checked` onda) — doküman § 4.2 *"Varsayılan seçim T+1'dir"*. Sıra değişti, davranış değişmedi |
| 3 | *"hangi transaction'dan hangi hatayı aldığı statüsüyle verilse daha iyi olmaz mı"* | ✅ Sonuç penceresinde her satırın yanında **durum rozeti**. Kaynak `item.NewStatus` — başarısız satırda modül bunu **değiştirmeden** döndürüyor (§ 3.4: *"başarısız işlem sonrasında transaction mevcut durumunu korur"*), yani rozet **kalıcı** durumu gösteriyor; başarılı satırda **yeni** durumu. 🔑 Gerekçe: Regenerate karışık statüyle çalışabiliyor (`D-10` yalnız Generate'i kısıtlıyor), o yüzden "şu referans patladı" yetmiyor |
| 4 | *"1 rows processed yazısı kötü, buraları güzelleştir"* | ✅ Tekil/çoğul sorunu **dilbilgisiyle değil yapıyla** çözüldü: sayı renkli bir **rozette**, yanında tek kelime başlık (`1` `Succeeded` / `1` `Failed`). Yeşil/kırmızı renk kodlu. Her dilde çalışıyor. Yeni anahtarlar: `mr-result-HeadSucceeded` / `mr-result-HeadFailed` |
| 5 | (aynı isteğin devamı) | Hata satırı **iki satıra** bölündü: üstte referans + rozet, altta `.mr-fail-reason` içinde sebep (12px, gri). Eskiden uzun Fimple mesajı referansı boğuyordu |

---

## 4. Doğrulama

| Ne | Sonuç |
|---|---|
| JS testleri | **344/344** |
| Fimple hata görünürlüğü | 🟢 **kullanıcı canlıda doğruladı** |
| Dark mode | ⏳ kullanıcı testi bekliyor (`T-130`…) |
