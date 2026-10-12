# progress-38 — PO'nun 7 maddesi TAMAM (blotter kolonları dahil)

**Tarih:** 2026-08-24
**Kapanan:** PO geri bildiriminin **son** maddesi — `MmRevaluationReport` (blotter) kolonları

---

## 1. Eklenen kolonlar

| Config `key` | Kaynak | `dataType` | Hizalama |
|---|---|---|---|
| `AccrualDay` | `TxnMm.Valuations` @ExecutionDate → `AccrualDay` | `string` | center |
| `DaysToMature` | **türetilmiş**: `MaturityDate − ExecutionDate` | `string` | center |
| `AccrualAmountSL` | `Valuations` @ExecutionDate | `money` | right |
| `AccrualAmountIRR` | `Valuations` @ExecutionDate (rapordaki *IRR (CL)*) | `money` | right |
| `AccrualAmountLCY` | `Valuations` @ExecutionDate | `money` | right |
| `FxRate` | `Valuations` @ExecutionDate → `FXRate` | `rate` | right |

PO'nun **isim isim istediği 4'ü** (`AccrualDay`, `DaysToMature`, `AccrualAmountSL`,
`AccrualAmountIRR (CL)`) + kendi seçtiğim **2 tanesi** (`AccrualAmountLCY`, `FxRate`).

### Neden bu ikisi eklendi

Aynı değerleme satırından geliyorlar → **ek sorgu maliyeti yok**. Reeskont için doğrudan
anlamlı: `AccrualAmountLCY` yerel para karşılığı (muhasebe fişi LCY üzerinden kesiliyor),
`FxRate` o tutarı üreten kur. Bir tutar yanlış görünüyorsa ilk bakılacak yer bu ikisi.

### 🔴 `AccrualDay` / `DaysToMature` neden `dataType: "string"`

İkisi de sayı ama **tutar değil**. `MEMORY.md`'de kayıtlı tuzak: DevExtreme `int` alanı
`number` sayıp kolonu **sağa** yaslıyor ve finansal ekranda sağa yaslı kolon **"tutar" okunuyor**.
`string` verilince hizalama kuralımız `center` uyguluyor — doğru okunuş.

---

## 2. 🔴 Değerleme koşmamışsa kolonlar BOŞ — hata değil

Bu alanlar **revaluation engine çıktısı** (`TxnMMDailyCalculation`). İlgili Execution Date için
değerleme koşmamışsa satır DB'de **yok** → kolonlar `null`.

⚠️ **`AccruedInterest` dolu kalır** çünkü o *o tarihe kadarki toplam*; geçmiş günlerin satırları
var. İkisini karıştırmamak lazım — canlıda `DailyAccrual` `null` iken `AccruedInterest` `42521.41`
dönüyordu (Seq logu, 2026-08-20).

🔵 **PO'ya önceden söylenmeli:** ilk açılışta bu kolonlar çoğunlukla boş görünecek.

### 🔴 InterbankLoan'da HER ZAMAN boş

`TxnLoan`'da günlük tahakkuk tablosu (`TxnMMDailyCalculation` muadili) **yok** —
`AccruedInterest`/`DailyAccrual` de bu yüzden `null` geçiliyordu.

Kolonlar InterbankLoan config'inde de **tanımlı bırakıldı**: boş hücre göstermek, kolonu hiç
göstermemekten iyi — kullanıcı iki ürün arasında geçerken **kolon düzeni değişmiyor**.
Doküman § 5.5 ile uyumlu: veri yoksa **hücre boş**, satır gizlenmez.

---

## 3. Dokunulan katmanlar (7)

| # | Dosya | Değişiklik |
|---|---|---|
| 1 | `TDMRediscountEligibleResult` | 5 yeni alan — 🔴 **SONA** eklendi |
| 2 | `TransactionDataManager` | `Valuations` @ExecutionDate'ten 5 skaler alt sorgu |
| 3 | `TransactionLoanDataManager` | 5 × `null` (gerekçe yorumda) |
| 4 | `EligibleTransactionsHandler` | `Data` sözlüğü + `MapItem`'a `executionDate` parametresi |
| 5 | `treasury.json` | MM + InterbankLoan'a **12 kolon** (6 × 2 ürün), `format` dahil |
| 6 | localization ×2 | 6 yeni `mr-col-*` → **153** anahtar |
| 7 | `EligibleTransactionsHandlerTests` | `BuildResult` 5 opsiyonel parametre + **3 yeni test** |

### 🔴 Neden alanlar record'un SONUNA eklendi

`TDMRediscountEligibleResult` **pozisyonel** bir record ve iki data manager onu **19 argümanlı**
konumsal çağrıyla dolduruyor. Araya alan eklemek argümanları **sessizce kaydırır**; tip uyumu
tesadüfen tutarsa **yanlış kolona yanlış veri** yazılır ve derleme hatası **vermez**.
Sona ekleme bu riski tamamen kaldırıyor.

### `DaysToMature` neden SQL'de değil handler'da

`EF.Functions.DateDiffDay` da kullanılabilirdi ama gereksiz çeviri riski: değer yalnızca
`MaturityDate` ve `executionDate`'e bağlı, ikisi de handler'da elimizde. Negatif olamaz —
uygunluk filtresi `MaturityDate > executionDate` şartı koyuyor.

### `Valuations` alt sorgusu satır kaybettirir mi? **Hayır**

`Valuations` bir **koleksiyon** navigation'ı → EF `EXISTS`/`APPLY` üretiyor, `INNER JOIN`
üretmiyor. `B-1` tuzağı (required navigation → satır sessizce düşer) burada **geçersiz**.

⚠️ Beş ayrı korelasyonlu alt sorgu oluyor; tek subquery + anonim tip pozisyonel record'a argüman
olarak verilemediği için bilinçli kabul edildi (aynı desen `AccruedInterest`/`DailyAccrual` için
zaten vardı).

---

## 4. Yeni testler (202 → 205)

| Test | Ne kilitliyor |
|---|---|
| `Handle_WhenValuationExists_ShouldMapBlotterColumnsIntoData` | Tutarlar **2 haneye yuvarlanır**, 🔴 `FxRate` **yuvarlanmaz** (6 hane gösterilecek; 2'ye kırpmak kur bilgisini bozar) |
| `Handle_WhenNoValuationForDate_BlotterColumnsShouldBeNullNotZero` | Değerleme yoksa `null` — **`0` değil**. Ve `AccruedInterest` **dolu kalır** (farklı şey ölçüyor) |
| `Handle_ShouldComputeDaysToMatureFromExecutionDate` | 27 Ekim → 14 Aralık = **48** gün |

### Güncellenen 2 test

| Test | Neden |
|---|---|
| `Handle_ShouldFillDataDictionaryWithContractKeys` | Anahtar listesi 12 → **18**. 🔑 Bu test bilinçli bir **bekçi**: `Data`'ya yeni anahtar eklenirse kırılır ve `treasury.json` + localization güncellemesi atlanmış olmaz |
| `Handle_WhenSubProductCodeIsNotInProductDefinition_...` | (önceki tur) `null` → **boş liste** |

⚠️ Kendi testimde bir hata yaptım ve düzelttim: `SetupDataManager()` **argümansız** çağrılırsa
`result = null` → `items` **boş** döner. Satır gerektiren her testte `BuildResult()` geçilmek zorunda.

---

## 5. Doğrulama

| Ne | Sonuç |
|---|---|
| MM testleri | **205 / 0 hata** (3 yeni) |
| JS testleri | **400 / 400** |
| `dotnet build NetTrex.MM.Api.Services` | **0 Error** |
| `dotnet build NetTrex.MM.Data` | **0 Error** |
| `dotnet build Trex.WebUI` | **0 Error** |

---

## 6. PO'nun 7 maddesi — KAPANDI

| # | İstek | Durum |
|---|---|---|
| 1 | Blotter kolonları | ✅ **bu tur** |
| 2 | Tarih / tutar / oran formatları | ✅ |
| 3 | House DataGrid görünümü (`Drag to group by`, toolbar) | ✅ |
| 4 | Status çoklu seçim | ✅ |
| 5 | SubProduct çoklu + `PrdProductDefinition`'dan dinamik + `Pass`/`Gil` hariç + InterbankLoan `!IsSameDay && !IsZeroRate` | ✅ |
| 6 | Tutar toplamı olmasın | ✅ (yok, koda not) |
| 7 | Gelecek tarih seçilemesin | ✅ |

Ek olarak: `Clear` butonu kaldırıldı (işlev grid toolbar'ındaki silgi ikonuna taşındı) ·
permission script'i SP deseniyle üretildi.
