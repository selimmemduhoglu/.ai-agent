# MM Localization — Uygulama Raporu

**Tarih:** 2026-09-10 · **Work item:** 36527 (MM Testleri) + 36529 (InterbankLoan)
**Emsal:** `NetTrex.Web.UI` PR 11994 → commit `3de0ddaec` ("FX Language Translates")
**Repo:** `NetTrex.Web.UI` · commit **yapılmadı**, working tree'de duruyor

---

## 1. FX commit'i ne yapmış (emsal analizi)

`3de0ddaec` (7 Eylül, Emrullah Acar) — **3 saat önce `67ea683c` ile revert edildi**
(PR 12136 "Revert 'FX Language Translates'").

Gerçek iş 4 kalemden oluşuyor (kalan dosyalar merge/bundle gürültüsü):

| # | Ne | Dosya |
|---|---|---|
| 1 | Base `-tr.json`'lara Excel sözlüğünün **Yatırım** ifadesi yazıldı | `fx-transaction-tr.json` (185 satır) · `pm-transaction-tr.json` (156) · `fx-swap-transaction-tr.json` (119) · `pm-swap-transaction-tr.json` (118) |
| 2 | Ayrışan key'ler için **şema dosyası** açıldı | `*-katilim.tr.json` + `*-yatirim.tr.json` (8 dosya, 3-4 key) |
| 3 | Eksik EN key eklendi | `fx-swap-transaction-en.json` +1 (`dgFxSwapCustomer-datagrid-ExternalCustomerId`) |
| 4 | Bundler glob'u düzeltildi | `Program.cs:172` `*{language}.json` → **`*-{language}.json`** |

Şema dosyası formatı (birebir kopyaladım):

```
﻿{
  //fx-transaction - katilim scheme overrides----------------------------------------
  "dgFxTransactionValuation-ValuationBuyInterestRate": "Değerleme Alış Getiri Oranı",
  ...
}
```

BOM var · 2 boşluk girinti · başlıkta `//<modül> - <şema> scheme overrides` + tire dolgusu ·
yalnız **ayrışan** key'ler (tam kopya değil).

### ✅ Kaynağın Excel olduğu doğrulandı — %97,3

FX'in 4 dosyasındaki 602 key'i Excel'in **Yatırım** sekmesiyle karşılaştırdım:
**586 birebir eşleşiyor**. Yani "sözlüğü uygula" doğru okuma. Kısaltmalar sekmesi de kullanılmış:
`Id` → **Kimlik** · `MTM` → **PGD** · `LCY` → **LPB**.

### 🔴 16 sapma — ve hepsi öğretici (kör lookup yanlış çeviri üretir)

| Sınıf | Örnek | Ders |
|---|---|---|
| **EN dosyası bozuk** | `dgPmTransactionValuation-MtmAmount` EN=`'Deal Rate'`, PR TR=`'PGD Tutarı'` · `formTxnSwap-SellAmnt` EN=`'Buy Amount'`, PR TR=`'Satış Tutarı'` | EN değerleri bir satır **kaymış**; PR yazan kişi **key'e** göre çevirmiş, EN'e göre değil |
| **`No` çift anlamlı** | `dgPmTheirSend-CounterPartyAccountNumber` EN=`'No'` → sözlük `'Hayır'`, PR `'Hesap Numarası'` | Kısaltmalar sekmesi bunu **zaten söylüyor**: `No → Numara (Acc No = Hesap Numarası)` |
| **Terim çakışması** | `Future` → sözlük `'Vadeli İşlem'`, PR `'Vadeli İşlem Sözleşmesi'` (çünkü `Forward` da `'Vadeli İşlem'`) | Sözlük iki EN terimine aynı TR'yi vermiş; ekranda ayırmak gerekiyor |

🔑 **Sonuç:** çeviri kaynağı EN metni **değil**, `(EN metni + key bağlamı)` çiftidir.

---

## 2. MM'de ne yapıldı

### Kapsam

`repo-transactions` **bilerek dışarıda**: key'leri `dgFiRepo*` → FI ekranı, MM work item'ı değil.
Ayrıca en riskli dosya (389 key'in 35'i sözlükte yok, 38 şüpheli). Kararı sana bırakıyorum.

### Değişen dosyalar (9 base + 8 yeni şema)

| Modül | Değişen satır | Şema key |
|---|---:|---:|
| `treasury/money-market/money-market` | 191 | 10 |
| `treasury/interbank-loan/interbank-loan` | 177 | 22 |
| `treasury/tawarruq/tawarruq` | 128 | — |
| `definitions/product-types/mm-product` | 94 | — |
| `treasury/issue-bond/issue-bond` | 52 | 5 |
| `reports/interbank-loan/interbank-loan-revaluation-report` | 41 | — |
| `reports/money-market/money-market-revaluation-report` | 31 | 1 |
| `reconciliation/platform-reconciliation/external-mm-stp` | 25 | — |
| `treasury/issue-bond-revaluation/issue-bond-revaluation` | 10 | — |
| **TOPLAM** | **749** | **38** (4 modül × 2 dosya) |

Ayrıca: **117 key zaten sözlükle uyumluydu** (dokunulmadı) · **3 key sözlükte yok** (dokunulmadı).

Tam liste → [`data/mm-applied.tsv`](data/mm-applied.tsv) (749 satır: `module · key · en · old_tr · new_tr · source`)
Karar tablosu → [`data/mm-plan.tsv`](data/mm-plan.tsv) (1258 key, `action` + `suspicion` kolonlu)

### Uygulanan override'lar (sözlük yanlış olduğu için)

Script'te `override()` fonksiyonunda, gerekçesiyle:

| EN | Key deseni | Sözlük | Yazılan | Neden |
|---|---|---|---|---|
| `Rate` | `*InterestRate` / `*-Rate` | **`Kur`** | `Faiz Oranı` / `Getiri Oranı` | Sözlük `Rate`'i **döviz kuru** sanıyor; bu key'ler faiz oranı. `Kur` yazmak finansal olarak yanlış |
| `no` | `*AccountNumber` | **`Hayır`** | `Hesap Numarası` | FX PR'ı da böyle yaptı; Kısaltmalar sekmesi de öyle diyor |

Bu 2 kural 16 satırı kurtardı. Override olmasa MM'de faiz oranı kolonları **"Kur"** yazacaktı.

### Örnek — `money-market-tr.json` neredeyse tamamen İngilizceydi

```diff
-  "dgMMTransactions-pageTitle": "Borrowing and Placement",
+  "dgMMTransactions-pageTitle": "Borç Alma ve Borç Verme",
-  "dgMMTransactions-Id": "Id",
+  "dgMMTransactions-Id": "Kimlik",
-  "dgMMTransactions-CustomerName": "Counterparty",
+  "dgMMTransactions-CustomerName": "Karşı Kurum",
-  "dgMMTransactions-InterestRate": "Rate",
+  "dgMMTransactions-InterestRate": "Faiz Oranı",      <- OVERRIDE (sözlük "Kur" derdi)
-  "dgMMTransactions-InterestAmount": "Accrued amount",
+  "dgMMTransactions-InterestAmount": "Tahakkuk Tutarı",
```

### Nasıl yazıldı — satır bazlı, biçim korunarak

[`scripts/apply-mm.py`](scripts/apply-mm.py). JSON'u parse edip yeniden serialize **etmiyor**;
`"key": "value"` satırında yalnız **değeri** değiştiriyor. Böylece key sırası · `//` yorumları ·
BOM · girinti · satır sonları **birebir korunuyor** → diff yalnız gerçekten değişen satırları
gösteriyor (**749 insertion / 749 deletion**, tek satır fazlası yok).

`--apply` bayrağı olmadan dry-run. Excel yenilenirse tekrar koşulur.

### Doğrulama

- **442 localization JSON'un tamamı parse ediliyor** (0 hata) — `//` yorumlu ve trailing comma'lı
  olanlar dahil, `Program.cs`'in `JObject.Parse`'ıyla aynı toleransla.
- 8 yeni şema dosyasında **EN'de karşılığı olmayan key yok** (orphan = 0).
- Satır sonu değişmedi (`git diff` 749/749, EOL gürültüsü yok).
- ⚠️ **Test koşulmadı** çünkü koşacak test yok: `localizationLoader.test.js` loader mantığını
  test ediyor, JSON içeriğini değil. Bu bir **boşluk** — bkz. § 4.

---

## 3. 🔴 DOKUNMADIĞIM AMA GEREKEN ŞEY: `Program.cs` bundler'ı

Şema dosyalarını yazdım ama **bundler onları doğru yere koymuyor**. Şu anki hâliyle:

```csharp
Program.cs:39   LanguageList = { "tr", "en", "yatirim", "katilim" }
Program.cs:172  Directory.GetFiles(directoryPath, $"*{language}.json")
```

1. 🔴 `*tr.json` glob'u yeni `*-katilim.tr.json` dosyalarını **düz `tr` bundle'ına** katıyor →
   katılım metinleri normal Türkçe'ye sızıyor. Alfabetik sırada son yazan kazanıyor.
   **Bu zaten yaşanıyor:** `mainMenu-QuantKey` ve `mainMenu-VolSmileDeltaPlot` yalnız
   `main-menu-yatirim.tr.json`'da var ama `bundle.messages.tr.json`'da **duruyorlar**;
   `mainMenu-REPOTransactionsKey` katılımda *"Commitment-Based Sukuk Transactions"* iken
   düz `tr` bundle'ında *"REPO Transactions"* yazıyor.
2. 🔴 Loader `bundle.messages.katilim.tr.json` istiyor; bundler `bundle.messages.katilim.json`
   üretiyor (2 byte, `{}`). Yani şema dosyaları **hiçbir bundle'a girmiyor**; loader elle konmuş
   bayat bir dosyayı okuyor (23.08 tarihli, 195 key, yalnız menü).
   ⚠️ **PR 11994 bunu da çözmüyordu** — glob'u `*-{language}.json` yapmak
   `*-katilim.tr.json`'u `*-katilim.json` desenine sokmaz. Revert'in sebebi bu olabilir.

### Önerim — 2 satır, `Trex.WebUI` içinde, blast radius = bundler

```csharp
// Program.cs:39
private static List<string> LanguageList = new List<string>
    { "tr", "en", "katilim.tr", "katilim.en", "yatirim.tr", "yatirim.en" };

// Program.cs:172
files.AddRange(Directory.GetFiles(directoryPath, $"*-{language}.json"));
```

Neden bu ikisi birlikte çalışıyor:
- `*-tr.json` artık `x-katilim.tr.json`'u yakalamıyor → **sızma yapısal olarak bitiyor**.
- `*-katilim.tr.json` yakalanıyor, mevcut `bundle.messages.{0}.json` template'i
  **`bundle.messages.katilim.tr.json`** üretiyor — loader'ın tam istediği ad.
- Ölü `bundle.messages.yatirim.json` / `.katilim.json` üretimi kendiliğinden bitiyor.

Bu, `Treasy.MicroUI.Packages`'ın **zaten doğru** olan sözleşmesiyle de hizalanıyor
(`SharedDependency.targets` → `TreasyBundleLocalizationFiles`: son `-`'den sonrası tek nokta
içeriyorsa `{scheme}.{lang}` grubu, hiç nokta yoksa düz dil).

### 🔴 Neden kendim yapmadım

- Bu bir **build davranışı** değişikliği ve bundler **tüm ekranların** localization'ını besliyor.
  Senin kuralın: paylaşılan yola radikal dokunuş yok, side effect ölçülemezse yapılmaz.
- PR 11994'ün aynı satırı **3 saat önce revert edildi** ve **revert'in gerekçesini bilmiyorum**.
  Aynı satırı gerekçesini bilmeden geri getirmek doğru değil.

### ⚠️ O yüzden şu an: BUILD ALMA

Kaynak `-tr.json`'lar güncel, **bundle'lar eski** → çalışan uygulama henüz etkilenmedi.
`dotnet run --generate-bundle` koşarsan bundler mevcut bozuk glob'la çalışır ve
**katılım metinlerini düz `tr` bundle'ına yazar**. Bundle üretimini `Program.cs` kararından
**sonra** yapalım.

---

## 4. Kalan boşluklar

| Konu | Durum |
|---|---|
| `Program.cs` bundler fix | ⏸️ **onay bekliyor** (§ 3) |
| Bundle üretimi | ⏸️ bundler fix'ten sonra |
| `repo-transactions` (389 key, 35'i sözlükte yok) | ⏸️ FI ekranı — kapsama alınacak mı? |
| Sözlükte karşılığı olmayan 3 MM key'i | iş birimine sorulacak |
| **Localization bütünlük testi yok** | 🔴 Şu an hiçbir test `-en.json` ↔ `-tr.json` key eşliğini, şema dosyalarının orphan key'ini veya `TR == EN` kalmış satırları görmüyor. Yazılabilir (C#, `Trex.WebUI.Tests`) — ama repo genelinde **4.876 boşluk** olduğu için ilk gün **kırmızı** olur. Ya MM kapsamıyla başlatılır ya baseline'lı yazılır. Kararı sana bırakıyorum |
| MM backend 54 hardcoded İngilizce mesaj | ayrı iş (bkz. `01-analiz.md` § 3) |
| Excel'in görmediği 21 yeni modül | iş birimine sorulacak (bkz. `01-analiz.md` § 2) |

---

## 5. Geri alma

```
git -C NetTrex.Web.UI checkout -- Code/Web/UI/Trex.WebUI/wwwroot/js/localization/
git -C NetTrex.Web.UI clean -f Code/Web/UI/Trex.WebUI/wwwroot/js/localization/
```

⚠️ `Code/docker-compose.override.yml` staged olarak duruyor — **benim değişikliğim değil**,
senin ortam ayarların. Ona dokunmadım, geri alma komutları da kapsamıyor.
