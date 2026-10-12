# progress-40 — K-5 damgası · K-6 doküman düzeltmesi · 5 küçük özellik

**Tarih:** 2026-08-21 · **Tur:** 9 · **Repolar:** `NetTrex.MM` · `NetTrex.Web.UI`

Kullanıcı, progress-39'daki denetim bulgularından üçüne karar verdi:
> **(1)** *"K-5 … bunu ekle tamamdır."*
> **(2)** *"K-6 — dokümanda bunu diyor fakat ben dokümanı yazanla konuştum, iş günü değil takvim günü
> yap dedi. md'leri de bu şekilde düzelt."*
> **(3)** *"Küçük: fiş numarası/MessageKey kolonu + muhasebe fişine link · sonuç Excel'i · sadece
> Generate edilebilecekleri seç · onay penceresinde toplam nominal/tahakkuk · stateStoring —
> bu güzel olur bunu da ekle."*

---

## 1. K-5 — T+0 reeskont fişi artık **işlemi çalıştıran** kullanıcıyla damgalanıyor

**Sorun (progress-39'da bulundu):** ters fiş gerçek kullanıcıyı taşırken (`T-01`), T+0 reeskont fişi
`RevaluationAccountingPipelineContextMapper.cs:33` üzerinden **işlemin kendi `StateMaker`'ı**
(işlemi açan dealer) ile damgalanıyordu → *"bu reeskontu ekrandan kim kesti"* sorusunun cevabı yoktu.

**Çözüm — ters fişteki desenin aynısı:**

| Dosya | Değişiklik |
|---|---|
| `RevaluationAccountingServiceContext` | `string? StateMaker = null` (3. **opsiyonel** parametre) |
| `RevaluationAccountingService` · `LoanRevaluationAccountingService` | Değer geldiyse `pipelineContext.Transaction with { StateMaker = ... }` |
| `ExecutionsHandler.CreateRevaluationAsync` | `currentUserId` geçiriyor (boşsa `null`) |

🔴 **Batch yolu bit-bit aynı:** hiçbir batch item bu alanı göndermiyor → `null` → eski davranış.
Bu, paylaşılan dosyaya dokunmanın **tek kabul edilebilir** şekli (kullanıcı kuralı 2026-08-19).

**Testler (+2):** `Handle_GenerateOnNotRediscounted_ShouldStampCurrentUserOnRevaluationVoucher` ·
`Handle_GenerateOnLoanProduct_ShouldStampCurrentUserOnRevaluationVoucher` (InterbankLoan yolu da).

---

## 2. K-6 — "iş günü" → "takvim günü" (doküman yazarının onayı)

Kod **zaten** takvim kullanmıyordu (`ADR-MR-027`); çelişen taraf **dokümandı**. Düzeltilen yerler
(`06-sozlesme.md`):

| Yer | Önce | Sonra |
|---|---|---|
| § 10 validasyon tablosu | `ExecutionDate` … **iş günü** olmalı | **iş günü kontrolü YOK** + gerekçe (iş birimi kararı 2026-08-21) |
| T+1 notu | *"Düz `AddDays(1)` KULLANILMAZ — § 4.2 +1 iş günü diyor"* | *"Düz `AddDays(1)` **KULLANILIR** — T+1 = +1 takvim günü"* |
| `NOT_WORKING_DAY` sebep kodu | "Valör iş günü değil" | **KULLANILMIYOR** — sözleşmede rezerve (modül hiç döndürmüyor) |
| ③ adım tablosu | T+1 (bir sonraki **iş** günü) | T+1 (bir sonraki **takvim** günü) |

➡️ Böylece **doküman ↔ kod ↔ ADR** üçü hizalandı. `ExecutionDate` için tek kural kaldı:
**boş olamaz + gelecek tarih olamaz.**

---

## 3. Beş küçük özellik

### 3.1 Fiş No kolonu + muhasebe ekranına link

**MM:** okuma sorgusu, durumu türeten **aynı** alt sorgu zincirinden fişin `Id`'sini ve
`MessageKey`'ini de çekiyor (`TDMRediscountEligibleResult.RediscountEntryId` /
`RediscountMessageKey` → `ManualRediscountItem.AccountingEntryId` / `AccountingMessageKey`).

🔴 **Aynı `Where` + `OrderByDescending(Id)` bilinçli**: farklı sıralama yazılırsa numara başka bir
fişi gösterebilir — durum ile numara **aynı satırdan** gelmek zorunda.

**WebUI:** grid'in **en sonunda** `Fiş No` kolonu. Fiş yoksa hücre **boş** (0 yazmıyor). Numaraya
tıklamak `/AccountingEntry/Index?accMainId=…`'yi **yeni sekmede** açıyor; ipuçta `MessageKey`.

⚠️ `Views/Report/Accounting/AccountingEntry/Index.cshtml`'e **query string ön filtresi** eklendi
(`accMainId` varsa filtre kutusunu doldur + grid'i tazele). Parametre yoksa **hiçbir şey olmuyor** →
o ekranın mevcut davranışı bit-bit aynı. Yeni sekme bilinçli: muhasebe ekranı yetkisi olmayan
kullanıcı yetki hatası alsa bile reeskont ekranı (ve o turun sonucu) kaybolmuyor.

🔴 **Sözleşme değişikliği:** § 12'nin *"MessageKey son kullanıcıya gösterilmez"* maddesi kullanıcı
kararıyla **kaldırıldı**. İki alan da salt gösterim; `executions` hiçbirini girdi kabul etmiyor.

### 3.2 Sonuç Excel'i

Sonuç şeridinde **Excel** düğmesi: o turun satırları (Referans · Sonuç · Durum · **Ayrıntı** =
tam hata metni). Gerekçe: sonuç DB'ye yazılmıyor (§ 3.1), sayfa yenilenince kayboluyor → operasyonun
elinde kalıcı bir kayıt olsun. ExcelJS + FileSaver ana layout'ta **zaten** yüklü
(`_FrameworkDependencies.cshtml:71-72`) — yeni kütüphane yok.

### 3.3 "Uygun satırları seç"

Toolbar'da yeni buton (`mrSelectGenerateEligible`). Generate **tek statü** istediği için kör bir
"hepsini seç" işe yaramaz; seçim **tek kovaya** indirgeniyor: önce `Not Rediscounted`, yoksa
`Not Reversed`. `Rediscounted` satır **hiç** seçilmiyor. Sayfada uygun satır yoksa seçim yapmıyor +
uyarıyor. ⚠️ Yalnız **yüklü sayfa** değerlendiriliyor; seçilen adet kullanıcıya yazılıyor.

### 3.4 Onay penceresinde toplamlar

`mrConfirmTotals(rows)` → **toplam nominal** ve (varsa) **toplam tahakkuk**, para birimi bazında
ayrı ayrı. Alan yoksa o satır **hiç** yazılmıyor (0,00 yanıltıcı olurdu). Generate ve Regenerate
onaylarının ikisinde de görünüyor.

### 3.5 `stateStoring`

`{ enabled: true, type: "localStorage", storageKey: "mr-grid-{productGroup}", savingTimeout: 500 }`.
Kolon genişliği/sırası/görünürlüğü ve filtre değerleri F5 sonrası korunuyor. Anahtar **ekran bazlı**
→ Treasury/Security/Investment birbirinin düzenini ezmiyor.

⚠️ **Bilinen yan etki:** filtre **ve sayfa numarası** da saklanıyor. Kullanıcı filtre bırakıp
döndüğünde "veri yok" sanabilir; test rehberi § 19/11 bunu söylüyor.

---

## 4. Test / build

| | Önce | Şimdi |
|---|---|---|
| MM | 206 | **210** ✅ (+2 K-5, +2 Fiş No alanları) |
| JS (Manuel Reeskont) | 83 | **92** ✅ (+9: Fiş No 3, onay toplamları 3, akıllı seçim 3) |
| JS (tüm suite) | 383 | **392** ✅ |
| Build | ✅ | MM 0 error · WebUI 0 error |

Bayat 2 test güncellendi: valör kolonu artık **sondan bir önceki** (Fiş No sona geçti), sabit kolon
`dataField` listesine `AccountingEntryId` eklendi.

**Tarayıcıda DENENMEDİ** → [`08-test-rehberi.md`](../08-test-rehberi.md) § 19 (12 madde).
En kritik ikisi: **(1)** ekrandan kesilen fişte `StateMaker` = kullanıcı · **(2)** batch'in kestiği
fişte `StateMaker` **değişmemiş** (paylaşılan servise dokunduk, batch etkilenmemeli).

---

## 5. Bu turda dokunulan kaçaklar

| Kaçak | Durum |
|---|---|
| K-5 (T+0 fişinde StateMaker yok) | ✅ **kapandı** |
| K-6 (doküman "iş günü" diyor) | ✅ **kapandı** (doküman düzeltildi, kod zaten doğruydu) |
| K-1 · K-2 · K-3 · K-4 · K-7 | ⬜ açık — karar/onay bekliyor (progress-39 § 3) |
