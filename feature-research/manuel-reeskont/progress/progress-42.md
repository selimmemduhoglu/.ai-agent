# progress-42 — Voucher kolonu ve akıllı seçim geri alındı · **ters fiş valörü artık GERÇEK** · başlıklar tam · veri seçim kuralları dokümanı

**Tarih:** 2026-08-21 · **Tur:** 11 · **Repolar:** `NetTrex.MM` · `NetTrex.Web.UI`

Kullanıcının bu turdaki beş isteği:
> **(1)** *"Voucher kolonunu siler misin, bu kolonu istemiyorum, gerek duymuyorum."*
> **(2)** *"Select Eligible Rows butonuna da gerek duymuyorum, silelim."*
> **(3)** *"TMMBRW2608210002 için ben T+0'da reverse kestim ve aynı güne tersi kesildi, ama nedense
> manuel reeskont ekranında reverse value date alanı bir gün sonrası için yazılmış. Neden böyle?
> `accEntryMain`'den alman gerekmiyor mu kesilen tarihi?"* 🔴 **gerçek hata**
> **(4)** *"Kolon isimleri tam olarak gözüksün — dinamik mi yapsak yoksa standart bir genişlik mi?"*
> **(5)** *"Bir tarih seçtiğim zaman gelen datalar neye göre geliyor, tam olarak hangi şartlara göre
> geldiğini açıkla — kodları da göster, iş birimine açıklayacak şekilde yap."*

---

## 1. 🔴 Ters fiş valörü artık **gerçek** — `ADR-MR-031`

**Hata neydi:** valör kolonu **her zaman** T+1 önizlemesini yazıyordu. Kullanıcı T+0 seçip ters fiş
kesince muhasebede tarih 21.08 oldu, ekran ise 22.08 gösterdi → **onaylanmış bir muhasebe kaydı
hakkında yanlış bilgi**. Ekran görüntüsünde üç `Rediscounted` satırın hepsinde bu vardı.

**Kök sebep:** T+0/T+1 seçimi **kullanıcıya ait** (§ 8.2). Yani kesilmiş bir ters fişin valörü bir
kuraldan türetilemez — sadece fişin kendisi bilir. Kolon ise yanıt seviyesindeki `ValueDates`
önizlemesini (tek kural: +1 takvim günü) yazıyordu.

**Çözüm:**

| Katman | Değişiklik |
|---|---|
| `TDMRediscountEligibleResult` | `DateTime? RediscountReverseValueDate` |
| İki data manager | ters fişin valörü `accEntryMain`'den, **`Any(...)` = EXISTS** ile |
| MM `ManualRediscountItem` | `DateTime? ReverseValueDate` |
| WebUI DTO | aynı alan |
| `columns.js` | dolu ise **gerçek** tarih (düz yazı), boş ise **önizleme** (italik/soluk + "Preview" ipucu) |

```csharp
RediscountReverseValueDate = x.AccountingMainEntries
    .Where(r => r.IsReverse && r.Type == revaluationType &&
                r.ProductCode == x.Product.MainProductCode &&
                x.AccountingMainEntries.Any(a =>
                    a.Id == r.ReverseId && !a.IsReverse &&
                    a.Type == revaluationType &&
                    a.ValueDate == executionDate &&
                    a.ProductCode == x.Product.MainProductCode))
    .OrderByDescending(r => r.Id)
    .Select(r => (DateTime?)r.ValueDate)
    .FirstOrDefault()
```

🔴 **`Any(...)` bilinçli:** required navigation'ı projeksiyonda dereference etmek EF'te INNER JOIN
üretip satırı sessizce düşürüyor / mükerrer sonuç veriyor (bu işte **iki kez** yaşandı — `MEMORY.md`).
EXISTS join üretmez.

🔑 **Taşınabilir kural (`ADR-MR-031`):** **geçmiş = kayıttan, gelecek = kuraldan.** Olmuş bir muhasebe
olayının tarihi/hâli **defterden** okunur; olacak bir şey kuraldan türetilir ve **önizleme olduğu
belli edilir**. Fx/FI/InvFund uygulanırken aynı ayrım korunmalı.

---

## 2. "Voucher No" kolonu geri alındı

Kaldırılanlar: grid kolonu · `mrVoucherCellTemplate` · `MR_ACCOUNTING_ENTRY_URL` ·
`mrAccountingEntryUrl` + host ayarı · MM'in `RediscountEntryId`/`RediscountMessageKey` alanları ·
WebUI DTO'daki `AccountingEntryId`/`AccountingMessageKey` · 2 localization anahtarı · 2 MM testi + 2 JS testi.

🔴 **Paylaşılan ekrana dokunuş da geri alındı:** `Views/Report/Accounting/AccountingEntry/Index.cshtml`
içine eklenen `?accMainId=` ön filtre betiği **silindi** — tek tüketicisi bu linkti, kalması
paylaşılan bir ekranda gerekçesiz bir davranış olurdu.

📌 **Sözleşme etkisi:** § 12'nin *"MessageKey son kullanıcıya gösterilmez"* maddesi **yeniden
yürürlükte**. MM yanıtında iki alan da yok; yerine gelen `ReverseValueDate` bir kimlik değil, **tarih**.

---

## 3. "Select eligible rows" geri alındı

`mrSelectGenerateEligible` · `mrRenderSmartSelectButton` · `#filteredRows()` · `.mr-smart-select`
CSS · 5 localization anahtarı · 5 test kaldırıldı.

Seçim artık iki hareketle yapılıyor: **statü pill'i** (tek kovaya indirir) + **grid başlık tiki**.
Kalan tek risk, başlık tikinin client-side grid'de kapsamın tamamını seçmesi (>50) — Execute bunu
**açık redle** karşılıyor (uyarı + fiş kesmez), yani sessiz bir hata yolu değil.

---

## 4. Kolon başlıkları tam görünüyor — `ADR-MR-032`

Sorunun cevabı **"dinamik"**: sabit genişlik vermek, uzun başlığı olan her kolonda aynı sorunu
yeniden üretir (bir dilde sığan başlık diğerinde sığmaz — ekran iki dilli).

| Önce | Sonra |
|---|---|
| `width: 130/150/190/220...` (kolon **kilitli**) | `minWidth: ...` (**taban**; kolon içerik+başlık kadar genişler) |
| `width: column.width \|\| 120` (ürüne özel) | `minWidth: column.width \|\| 120` — config'deki değer artık **taban** |
| Başlık sığmazsa DevExtreme `...` ile **kırpıyor** | CSS ile **iki satıra sarıyor** (`.dx-datagrid-headers .dx-datagrid-text-content`) |

⚠️ Bedeli: çok kolonlu ekranda tablo yatayda daha geniş → **yatay kaydırma**. Kırpılmış başlık yerine
kaydırma bilinçli tercih: kullanıcı kolonun ne olduğunu okuyamazsa filtreyi/sıralamayı **yanlış
kolona** uygular. Kural yalnız **başlık** satırına uygulandı — veri hücreleri tek satır kaldı
(`wordWrapEnabled` açmak satır yüksekliğini veriye göre oynatırdı).

---

## 5. Yeni doküman: veri seçim kuralları (iş birimi için)

[`10-veri-secim-kurallari.md`](../10-veri-secim-kurallari.md) — 9 bölüm:
tek paragraflık cevap · zorunlu üç filtre · **satır seviyesindeki 6 şart** (kod + iş dili + neden) ·
Interbank Loan farkı · durumun nasıl **hesaplandığı** · valör kolonunun gerçek/önizleme ayrımı ·
**listeye girmeyen** işlemler tablosu · batch ile karşılaştırma · **salt-okunur doğrulama SQL'i**.

Koddan çıkarılan altı şart: `StateId` onaylı · `MaturityDate > tarih` · `ValueDate <= tarih` ·
**açılış fişi var** (`ProductCode` eşleşmeli) · tarih **açık faiz döneminin içinde**
(MM `Details`, IL `CashFlows`) · alt ürün eşleşmesi.

⚠️ Dokümandaki SQL'de **`StateId` filtresi eksik**: onaylı state kümesi
(`StateConstants.VerifiedStatesId`) framework paketinden geliyor, kaynakta **okunamadı**
(*tespit edilmedi*) → doğrulama sorgusu ekrandan **fazla** satır dönebilir; dokümanda bu açıkça yazılı.

---

## 6. Test / build

| | Önce | Şimdi |
|---|---|---|
| MM | 210 | **211** ✅ (+3 valör testi, −2 fiş no testi) |
| JS (Manuel Reeskont) | 108 | **100** ✅ (+6 yeni, −14 geri alınan) |
| Build | ✅ | MM 0 error · WebUI 0 error |

**Yeni MM testleri:** ters fiş varsa **gerçek** valör taşınır (ve yanıt seviyesindeki önizleme
**değişmez**) · ters fiş yoksa `null` · voucher alanları **artık yok** (reflection ile sabitlendi).
**Yeni JS testleri:** gerçek valör yazılır ve önizleme değil · camelCase alan adı okunur · önizleme
görsel olarak işaretlenir · `Not Rediscounted` → `-` · sabit kolonlarda `width` **yok** ·
ürüne özel kolonlarda `minWidth`.

⚠️ Düzeltilen bayat test: kolon sırası testi `AccountingEntryId` bekliyordu. Ayrıca yeni bir tarih
testi `toISOString()` yüzünden UTC'ye kaydığı için (+03'te 21.08 → "2026-08-20") mock **yerel**
tarih yazacak şekilde düzeltildi — testin kendisi yanlış ölçüyordu.

**Tarayıcıda DENENMEDİ** → [`08-test-rehberi.md`](../08-test-rehberi.md) § 21 (12 madde).
En kritik ikisi: **(1)** T+0 ile kesilmiş satırda valör = **işlem tarihi** · **(2)** ekrandaki tarih
ile **Module Accounting**'deki ters fiş valörünün birebir aynı olması.

---

## 7. Açık kaçaklar (değişmedi)

| Kaçak | Durum |
|---|---|
| K-1 Regenerate'in üç ayrı commit'i (dış transaction yok) | ⬜ açık |
| K-2 Fimple sync yerel commit'ten önce | ⬜ açık |
| K-3 mükerrer guard process-içi (cluster kilidi yok) | ⬜ açık |
| K-4 döngü ortasında iptal | ⬜ açık |
| K-7 T+1 hafta sonuna düşebilir (Fimple kabul eder mi) | ⬜ canlı testte ölçülecek |
