# Localization Excel Uyarlama — Analiz

**Tarih:** 2026-09-10 · **Kaynak:** `.ai-agent/imports/localization-dictionary-en-tr 1.xlsx`
**Kapsam:** `NetTrex.Web.UI` (asıl iş) + `NetTrex.MM` (kontrol edildi) · Referans: `Treasy.MM.UI` + `Treasy.MicroUI.Packages`

---

## 1. Excel ne diyor — 5 sekme

| Sekme | Satır | Ne |
|---|---:|---|
| **Dictionary** | 9.328 | `Module/File` · `Key` · `English` · `Turkish` · `Note` — **repodan üretilmiş envanter**. Yol biçimi (`pages/treasury/money-market/money-market`, `global/devextreme-global`) birebir `Trex.WebUI/wwwroot/js/localization/**` ağacı. `Note` boşlukları işaretliyor: `untranslated (EN==TR)` 3.983 · `no TR entry` 839 · `no EN entry` 20 |
| **Yatırım Bankası** | 3.622 | İş biriminin onayladığı **EN → TR sözlüğü** (+ `Occurrences`) |
| **Katılım Bankası** | 3.622 | Aynı sözlüğün **katılım bankacılığı** varyantı |
| **Kısaltmalar** | 16 | NBD/YPB/LPB/İGO/PGD… + iki bankacılık için ayrışan kısaltmalar (`FRN` → **DFT** vs **DGT**) |
| **Sheet1** | 338 | Yalnız İngilizce liste; 338'inin **tamamı** sözlükte var → çalışma artığı, ayrı gereksinim değil |

🔑 **İstenen şey:** Dictionary sekmesi **soru kağıdı**, Yatırım/Katılım sekmeleri **cevap kağıdı**.
Yani: repodaki eksik/çevrilmemiş TR değerlerini bu sözlükten doldur — ve **iki banka tipi için ayrı** doldur.

### Yatırım ↔ Katılım farkı: 94 terim

Tamamı aynı ekseni izliyor: **faiz → getiri / kâr payı**.

| English | Yatırım | Katılım |
|---|---|---|
| Interest Rate | Faiz Oranı | Getiri Oranı |
| Interest Amount | Faiz Tutarı | Getiri Tutarı |
| Interest Method | Faiz Yöntemi | Getiri Yöntemi |
| Accrued Interest | Tahakkuk Etmiş Faiz | Tahakkuk Eden Getiri |
| FRN Rate | **DFT** Faiz Oranı | **DGT** Getiri Oranı |
| Deposit Rates | Mevduat Faiz Oranları | Mevduat Getiri Oranları |
| Rate & Interest | Kur ve Faiz | Kur ve Getiri |

Tam liste → [`data/glossary-diff-yatirim-katilim.tsv`](data/glossary-diff-yatirim-katilim.tsv)

---

## 2. Repodaki GERÇEK durum (Excel'e değil, canlı dosyalara bakıldı)

`Trex.WebUI/wwwroot/js/localization/**` → **219 modül**, 434 JSON, **10.323 EN key** / 9.605 TR key.

> ⚠️ Excel'in Dictionary sekmesi **bayat**: 198 modül tanıyor, repoda **21 modül daha** var
> (`tender-bid/*` 5, `warrant/*` 4, `Funds/fdk-*`, `inv-fund-sweep*`, `tefas-member`,
> `limit-check-component`, `advance-search-component`, `security-depot-mapping`,
> `takasbank-reconciliation`, `mkk-dibs-buy-sell-declaration`, `spk`, `commodity-option`).
> Bu modüller sözlükte **hiç sorulmamış** — iş birimine geri sorulacak liste.

### Boşluk tablosu (canlı ölçüm, 176 modül etkilenmiş)

| Durum | Satır | Açıklama |
|---|---:|---|
| `UNTRANSLATED` (TR == EN) | **4.116** | TR dosyasında key var ama değer İngilizce |
| `NO_TR_KEY` | **568** | EN'de var, TR dosyasında key yok |
| `NO_TR_FILE` | **171** | TR dosyası **hiç yok** (5 modül) |
| `NO_EN_KEY` | 21 | TR'de var, EN'de yok (ters yönde boşluk) |
| **TOPLAM** | **4.876** | EN key'lerin **%47'si** |

**TR dosyası hiç olmayan 5 modül:** `Funds/customer-stopage-view` · `Funds/inv-fund-customer-order-status`
· `Funds/inv-fund-order-cancel` · `Funds/inv-fund-txn-history` · `login/ip-address`

### Excel ne kadarını kapatıyor

| | Satır |
|---|---:|
| Sözlükten **doldurulabilir** | **4.734** (%97,1) |
| Sözlükte **karşılığı yok** | **121** |
| Kapsam dışı (`NO_EN_KEY`) | 21 |
| Bunlardan **banka tipine göre ayrışan** | **114** satır / **18 modül** |

Tam veri → [`data/gaps-live.tsv`](data/gaps-live.tsv) · eksikler → [`data/not-in-glossary.tsv`](data/not-in-glossary.tsv)

En büyük 10 modül:

| Boşluk | Doldurulabilir | Şema | Modül |
|---:|---:|---:|---|
| 333 | 333 | 0 | `global/devextreme-global` |
| 292 | 287 | 0 | `global/treasy-global` |
| 248 | 247 | 32 | `pages/treasury/derivatives/irs-cirs` |
| 247 | 240 | 4 | `global/main-menu` |
| 199 | 190 | 4 | `pages/treasury/options/options-fx` |
| 195 | 191 | 4 | `global/main-menu-yatirim` |
| **194** | **194** | **4** | **`pages/treasury/money-market/money-market`** |
| 193 | 192 | 4 | `global/main-menu-katilim` |
| 142 | 140 | 1 | `pages/Funds/funds-definition` |
| **141** | **141** | **14** | **`pages/treasury/interbank-loan/interbank-loan`** |

---

## 3. MM kapsamı

| Modül | Boşluk | Doldurulabilir | Sözlükte yok | Şema ayrımı |
|---|---:|---:|---:|---:|
| `treasury/money-market/money-market` | 194 | 194 | 0 | 4 |
| `treasury/interbank-loan/interbank-loan` | 141 | 141 | 0 | 14 |
| `treasury/tawarruq/tawarruq` | 128 | 128 | 0 | 0 |
| `definitions/product-types/mm-product` | 94 | 94 | 0 | 0 |
| `reports/interbank-loan/interbank-loan-revaluation-report` | 41 | 41 | 0 | 0 |
| `treasury/money-market/repo-transactions` | 34 | 28 | 6 | 0 |
| `reports/money-market/money-market-revaluation-report` | 32 | 31 | 1 | 0 |
| `manuel-reescont/manuel-reescont` (eski FX/FI ekranı) | 27 | 27 | 0 | 0 |
| `reconciliation/platform-reconciliation/external-mm-stp` | 25 | 25 | 0 | 0 |
| `treasury/issue-bond-revaluation/issue-bond-revaluation` | 10 | 10 | 0 | 0 |
| `treasury/issue-bond/issue-bond` | 2 | 2 | 0 | 0 |
| **TOPLAM MM** | **728** | **721** | **7** | **18** |

MM'in şema ayrımı gerektiren 18 satırı: `dgInterbankLoan-InterestMethod*`, `frmInterbankLoan-FloatingRateType`,
`frmInterbankLoan-RateSection` (**Kur ve Faiz** ↔ **Kur ve Getiri**), `frmMMTransaction-ProfitAmount`,
`frmMMPreview-ProfitAmount`, `gridFileImportMM-Faiz*`. Detay → [`data/mm-gaps.tsv`](data/mm-gaps.tsv)

### `NetTrex.MM` (backend) — iş yok denecek kadar az

- Localization altyapısı yok: `resx` **hiç yok**, `IStringLocalizer` **hiç kullanılmıyor**.
  `RequestLocalizationOptions` var ama **iki kültür de `en-US`** (`NetTrex.MM.Api/Startup.cs:93-99`).
- Hardcoded İngilizce mesaj: **40** `WithMessage(...)` + **14** `Message = "..."` ≈ **54 satır**.
- Bunlar UI'ye ham İngilizce düşüyor. **Ama** UI zaten kendi doğrulamasını kendi key'iyle yapıyor —
  emsal: `interbank-loan/popups/form.js:975`
  `formatMessage("frmInterbankLoan-FloatingRateTypeError") || "Floating Rate Type is required."`
  Yani backend metni yalnız istek API'ye **gerçekten gittiğinde** görünüyor.
- **Sonuç:** Excel'in uyarlanması **backend'e dokunmayı gerektirmiyor**. Backend mesajlarının
  Türkçeleştirilmesi ayrı ve daha büyük bir iş (mesaj → hata kodu sözleşmesi gerekir). Karar senin.

---

## 4. Mekanizma: banka tipi anahtarı ZATEN KURULU — verisi BOŞ, bundler'ı BOZUK

### 4.1 Kurulu olan (çalışıyor)

```
appsettings / env:  Framework:Application:PreferredLanguageScheme = "katilim" | "yatirim" | ""
   -> LanguageProvider.GetPreferredLanguageScheme()   (Framework.WebUI/Helpers/LanguageProvider.cs:69)
   -> _FrameworkDependencies.cshtml:28   settings.languageScheme
   -> dx.messages.loader.js              buildBundleNames(lang, scheme)
        oncelik: {scheme}-{lang}  ->  {lang}  ->  "en"    (Object.assign, en yuksek en son)
   -> dosya adi: bundle.messages.katilim.tr.json
```

Dil `SystemLanguage` cookie'sinden (`GetSelectedLanguage`), desteklenen diller `en` + `tr`.
Testleri de var: `JSTests/localizationLoader.test.js`, `Helpers/LanguageProviderTests.cs`.
Docker: `docker-compose.override.yml:82` → `Framework__Application__PreferredLanguageScheme: "yatirim"`.
`_FrameworkDependencies.cshtml:76` **yalnız `dx.messages.loader.js`**'i yüklüyor — eski
`dx.messages.{en,tr,yatirim,katilim}.js` dosyaları **ölü**.

### 4.2 🔴 BOZUK OLAN: `Program.cs` bundler'ı şema-farkında değil

`Trex.WebUI/Program.cs:39` → `LanguageList = { "tr", "en", "yatirim", "katilim" }`
`Trex.WebUI/Program.cs:172` → `Directory.GetFiles(dir, $"*{language}.json")`

Üç ayrı sonuç:

1. 🔴 **`tr` bundle'ı şema dosyalarını YUTUYOR.** `*tr.json` glob'u `main-menu-katilim.tr.json` ve
   `main-menu-yatirim.tr.json`'u da yakalıyor → düz `tr` bundle'ına karışıyorlar, alfabetik sırada
   **son yazan kazanıyor (yatirim)**.
   **Kanıt (ölçüldü):** `mainMenu-QuantKey` ve `mainMenu-VolSmileDeltaPlot` **yalnız**
   `main-menu-yatirim.tr.json`'da var — ama `bundle.messages.tr.json`'da **duruyorlar**.
   Ve `mainMenu-REPOTransactionsKey` katılım dosyasında *"Commitment-Based Sukuk Transactions"*
   iken düz `tr` bundle'ında *"REPO Transactions"* yazıyor.
   ⚠️ Bugün gözle görünmüyor çünkü şema dosyalarının **çoğu değeri baz ile aynı**. Excel'in
   94 ayrışan terimi girildiği an **katılım metinleri düz `tr` bundle'ına sızacak**.
2. 🔴 **Loader'ın istediği dosyayı bundler ÜRETMİYOR.** Bundler `bundle.messages.katilim.json`
   üretiyor (2 byte, `{}`), loader ise `bundle.messages.katilim.tr.json` istiyor. Var olan
   `.katilim.tr.json` / `.yatirim.tr.json` dosyaları **elle** konmuş (23.08, 195 key, yalnız menü) —
   build onları **tazelemiyor**, sessizce bayatlıyorlar.
3. `bundle.messages.yatirim.json` / `.katilim.json` = **ölü dosya**. İçerik
   `{"mainMenu-DepositRatesKey": "Faiz Oranları (Yatirim)"}` — dil eki olmayan
   `main-menu-yatirim.json` POC dosyasından geliyor, hiçbir yerden okunmuyor.

### 4.3 ✅ DOĞRU EMSAL: `Treasy.MicroUI.Packages` bundler'ı

`Treasy.MicroUI.SharedDependency/buildTransitive/Treasy.MicroUI.SharedDependency.targets`
(`TreasyBundleLocalizationFiles` task) sözleşmeyi zaten doğru kuruyor:

| Kaynak dosya | Grup | Çıktı |
|---|---|---|
| `x-tr.json` | `tr` | `tr.json` |
| `x-katilim.tr.json` | `katilim-tr` | `katilim-tr.json` |
| `x-a.b.c.json` | — | **warning + skip** |

- Son `-`'den sonrası **tek nokta** içeriyorsa `{scheme}.{lang}`; hiç nokta yoksa düz dil.
- Şema dosyası düz dil grubuna **girmez** → 4.2/1'deki sızma **yapısal olarak imkânsız**.
- `JsonCommentHandling.Skip` + `AllowTrailingCommas` (WebUI JSON'ları `//` yorum içeriyor — gerekli).
- Bozuk JSON → `LogError` (build kırılır); WebUI karşılığı `FrameworkException`.

⚠️ MicroUI tarafında da **veri boş**: `Treasy.MM.UI/wwwroot/localization/general/general-katilim.tr.json`
= `{}`, `bundles/localization/katilim-tr.json` = `{}`. Yani platformda **anahtar takılı, kutu boş**.

---

## 5. Yapılacak iş (öneri, onay bekliyor)

**Faz 0 — bundler'ı düzelt (kod, ~1 dosya).** `Program.cs`'i MicroUI targets'ıyla aynı sözleşmeye getir:
`{scheme}.{lang}` gruplaması, düz dil bundle'ından şema dosyalarını **çıkar**, çıktı adı
`bundle.messages.{scheme}.{lang}.json`, ölü `yatirim.json`/`katilim.json` üretimini kaldır.
🔴 **Bu faz olmadan veriyi girmek zararlı** — katılım metni düz `tr`'ye sızar.
Test: JS tarafında `localizationLoader.test.js` var; bundler için C# testi **yok**, yazılacak.

**Faz 1 — baz TR'yi doldur (veri, 176 modül).** 4.734 satır. Kaynak = **Yatırım** sözlüğü
(varsayılan kurulum yatırım/mevduat bankası; `docker-compose.override.yml` de öyle diyor).
`NO_TR_FILE` 5 modül için TR dosyası oluştur.

**Faz 2 — katılım şema dosyaları (veri, 18 modül).** Yalnız **114 ayrışan satır** için
`<modül>-katilim.tr.json` yaz. Ayrışmayan 4.620 satır şema dosyasına **kopyalanmaz** —
loader'ın fallback'i baz `tr`'yi zaten getiriyor. (Bugünkü `main-menu-katilim.tr.json`
195 key ile tam kopya; o da 1 key'e inecek.)

**Faz 3 — kalan 121 + 21 satır.** Sözlükte karşılığı olmayanlar ve Excel'in görmediği 21 yeni
modül → iş birimine tek liste olarak sorulur.

**MM önce mi?** MM kapsamı 728 satır / 11 modül, tamamı Faz 1+2'nin alt kümesi. İstersen
Faz 1'i MM ile başlatıp aynı script'i diğer modüllere uygularız.

---

## 6. Sana sorular

1. **Faz 0 onayı:** `Program.cs` bundler'ına dokunayım mı? (Paylaşılan framework dosyası değil,
   `Trex.WebUI` içi — ama build davranışını değiştiriyor. Alternatif: MicroUI targets'ını
   referans alıp `Trex.WebUI.csproj`'a ayrı bir MSBuild target koymak, `Program.cs`'e hiç dokunmamak.)
2. **Varsayılan hangisi?** Baz `tr` = Yatırım, şema dosyası = Katılım. Tersi de mümkün.
   `docker-compose.override.yml` "yatirim" diyor → önerim yatırım.
3. **Kapsam:** hepsi (4.734) mi, yoksa **yalnız MM** (721) mi?
4. **Backend:** `NetTrex.MM`'in 54 hardcoded mesajı bu işin parçası mı? (Önerim: hayır, ayrı iş.)
5. **Uygulama biçimi:** script ile toplu üretim (tekrarlanabilir — Excel yenilenince yeniden koşar)
   mi, elle dosya dosya mı? Önerim: script + üretilen JSON'lar commit'lenir, script `.ai-agent/`'ta kalır.
6. **`Occurrences` kolonu** (Yatırım sekmesi) öncelik sırası mı, yoksa sadece bilgi mi?

---

## 7. Görseldeki TFS — ⚠️ tespit edilmedi

Paylaştığın görselde **TFS/DevOps work item yok**. Görsel bir **Teams sohbeti**:
`docker-compose` ekran görüntüleri, *"WebUI da zamanında 2gb yer ayırmışsın / bunu kendin mi
yaptın biri mi söyledi"*, 4 Ağustos'ta iki dosya eki (`2026-08-04-mi…`) ve MD sistem kiti
hakkında Osman Onurcan ile yazışma (*"eyv / cansin"*).
**Localization ile ilgili tek satır geçmiyor.** Yanlış görsel yüklenmiş olabilir —
work item ekranını tekrar atarsan onu da okurum.

---

## Veri dosyaları

| Dosya | Satır | Ne |
|---|---:|---|
| [`data/gaps-live.tsv`](data/gaps-live.tsv) | 4.876 | Canlı repodaki tüm boşluklar + sözlük karşılığı (Y ve K) + şema bayrağı |
| [`data/mm-gaps.tsv`](data/mm-gaps.tsv) | 728 | Aynısının MM kesiti |
| [`data/glossary-diff-yatirim-katilim.tsv`](data/glossary-diff-yatirim-katilim.tsv) | 94 | Banka tipine göre ayrışan terimler |
| [`data/not-in-glossary.tsv`](data/not-in-glossary.tsv) | 121 | Sözlükte karşılığı olmayan boşluklar |

Kolonlar: `module · key · en · current_tr · status · fill_source · tr_yatirim · tr_katilim · scheme_split · scope`

### Ölçüm script'leri

Excel okuma + envanter + kapsama script'leri scratchpad'de üretildi
(`dump.py` · `inv.py` · `cov.py` · `gen.py`). Kalıcı hale getirilecekse
`.ai-agent/skills/` altına taşınır — Faz 1/2 aynı script'lerin üzerine kurulacak.
