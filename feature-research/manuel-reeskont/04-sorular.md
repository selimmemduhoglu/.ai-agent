# Sorular — Kod Yazılmadan Önce Cevaplanması Gerekenler

> Kaynak: [`01-dokuman-analizi.md`](01-dokuman-analizi.md) § 6 · [`02-mimari-karar.md`](02-mimari-karar.md) § 6 · [`03-mm-backend-envanteri.md`](03-mm-backend-envanteri.md) § 10
> Numaralar **kalıcı** — sonraki turlarda bu kodlarla referans verilir.
>
> **Bölüm A** iş birimine gönderilecek · **Bölüm B** Selim'in kendi kararı · **Bölüm C** kapanmış olanlar.
> **Son Güncelleme:** 2026-08-12

---

## 🔴 BLOKE EDENLER — bunlar cevaplanmadan kod yazılmaz

| # | Soru | Neden bloke ediyor |
|---|------|--------------------|
| **C-01** | **Execute Selected mi, Generate + Regenerate mi?** Doküman **iki tasarım nesli** taşıyor (§3.5/§4.4/§5.4/§8.2/§8.3 + image1/4/7 = Execute Selected · §4.6/§4.7/§5.3/§8.1 + image2/3/5/6 = Generate/Regenerate). Status filtresinde `All` **var mı yok mu**? (image4/image7: *"tek seçim — 'All' yok"* · §5.3: *"All seçeneği eklenir"*) | Aksiyon modeli **tüm** UI akışını, request modelini ve backend dallanmasını belirliyor. Yanlış nesle göre yazılan ekran **baştan yapılır** |
| **C-07** | **`executions` senkron mu asenkron mu?** Dokümanın içindekiler'inde **"6.1 Asenkron İşlem Mimarisi"** var ama **gövdede bu bölüm YOK** (§6.1 "Teknoloji ve Yapı" olmuş). `Processing` durumunun varlığı asenkron ima ediyor; `ExecutionsResponse` `Succeeded[]`/`Failed[]` ise **senkron** bir imza | 248 kayıt × senkron Fimple HTTP = **timeout kesin**. Asenkron ise kuyruk + durum sorgulama ucu + polling/SignalR gerekir → **kod mimarisini kökten değiştirir** |
| **C-08** | **`ExecutionsRequest` nihai modeli ne?** §6.4.3'te `Status` + `ReverseValueDate` var / `Operation`, `ExecutionDate` yok. §6.4.4 altındaki genişletmede `Operation` + `ExecutionDate` + `RegenerateToToday` var / **`Status` ve `ReverseValueDate` YOK** — oysa §4.2 hâlâ T+0/T+1 soruyor | Sözleşme dondurulmadan iki taraf (UI + 6 modül servisi) kod yazamaz |
| **C-02** | **Product tekli mi çoklu mu? Sub Product filtresi var mı?** Metin (§1.2/§5.3/§6.4.1): "Product **tekli**, zorunlu" + "SubProduct **tekli**, zorunlu, boş gönderilemez". **Tüm görsellerde** `Product: Murabaha, FX Spot +1` = **çoklu**, grid'de Murabaha+FX Spot+FX Fwd+FX Swap **karışık**, ve **Sub Product filtresi hiç yok**. Görseldeki değerler (Murabaha, FX Spot) aslında **SubProduct** seviyesinde | Kolon konfigürasyonu **Product** seviyesine bağlı (§5.5). Product çoklu olursa "hangi ürünün kolon seti" sorusu cevapsız kalır → grid kurulamaz |

---

## Bölüm A — İş Birimine Sorulacaklar

### A.1 Filtreler ve veri kümesi

| # | Soru |
|---|------|
| **C-03** | **Revaluation Type:** tekli mi çoklu mu? (§1.2 "tekli" ↔ §5.3 "Çoklu" ↔ §6.4.1 `RevaluationTypes (List)`). Ayrıca **değer kümesi hiç tanımlanmamış** — görselde "FX Mark-to-Market" ve "Interest Accrual" var. Bu liste **nereden** gelecek: sabit ortak enum mu, her ürün servisi kendi listesini mi verir? Sözleşmede bu listeyi döndüren **endpoint yok** (§6.2 "2 endpoint dışında uç tanımlanmaz") |
| **C-04** | **Product / Sub Product listesi kaynağı:** §1.3 "Sub Product listeleri **ürün servisi** tarafından sağlanır" ↔ §5.5 "Product listesi **kolon konfigürasyonundan** çözülür" ↔ §6.2 "2 endpoint dışında ek uç tanımlanmaz". SubProduct'ı ürün servisi verecekse **onu getirecek uç yok**. Ya JSON config'e SubProduct listesi de yazılacak, ya **3. endpoint** gerekli — hangisi? |
| **C-09** | **`Execution Date`:** zorunlu mu? Varsayılan **bugün** mü, sistemin **logical date**'i mi? **Geçmiş tarih** seçilebilir mi? **Gelecek tarih** engellenecek mi? **İş günü** kontrolü var mı? (MM'de `MMLogicalDate` framework parametresi var — reeskont buna bağlı olmalı gibi görünüyor) |
| **C-10** | **Select All ↔ sayfalama:** §5.4 "seçim **tüm veri kümesini** kapsar" (248 kayıt) ama §6.4.1'de `Skip`/`Take` var ve `ExecutionsRequest`'te yalnız `TransactionIds` listesi var. Kullanıcı "Select All" derse UI 248 id'yi **nasıl** bulacak? Tüm sayfaları mı çekecek, yoksa sözleşmeye `SelectAll: bool` + filtre alanları mı eklenecek? |
| **C-12** | **`Error = 0` filtre olarak gönderilebilir mi?** §6.4.1 Status enum'ında `Error = 0` var ↔ §3.4 "kalıcı Error durumu **veya Error filtresi bulunmaz**" ↔ §5.3 "yalnız NotRediscounted/NotReversed/Rediscounted". Backend `Status = Error` isteği alırsa: boş liste mi, doğrulama hatası mı? |

### A.2 Aksiyon davranışı

| # | Soru |
|---|------|
| **C-05** | **Generate + `Rediscounted` satırı:** §4.6 Generate'i yalnız `NotRediscounted` (reeskont) ve `NotReversed` (ters fiş) için tanımlıyor. `All` modunda `Rediscounted` satır da seçilebiliyor. Generate'te bu satıra ne olacak — **sessizce atlanır**, `Failed`'a "uygun değil" olarak **düşer**, yoksa Generate **pasif** mi olur? Generate onay penceresinde (image5) `Rediscounted` hiç geçmiyor |
| **C-06** | **Regenerate + `Not Reversed` = kaç fiş kesilecek?** image6: "*Not Reversed → önceki değerleme geri alınır, yeni değerleme oluşturulur*". Ama `NotReversed`'ın ters fişi **yok**. Muhasebe olarak: **(1)** mevcut reeskonta iptal/ters fiş + **(2)** yeni reeskont T+0 + **(3)** yeni ters fiş T+1 = **3 fiş** mi? Yoksa mevcut reeskont **soft-delete** edilip 2 fiş mi? |
| **C-11** | **Eşzamanlılık:** İki kullanıcı aynı transaction'a **aynı anda** Generate basarsa? §4.5 "ürün servisi durumu yeniden doğrular" diyor ama lock / rowversion / optimistic concurrency **yok**. İş birimi çift fiş riskini kabul ediyor mu, kilit isteniyor mu? (⚠️ MM'de Fimple çağrısı **idempotent değil** — envanter § 5.2) |
| **C-20** | 🔴 **YENİ — Mevcut FX Manuel Reeskont ekranı ne olacak?** Yeni ekran devreye girince **silinecek mi**, paralel mi yaşayacak? İkisi paralel çalışırsa aynı transaction'a **iki ayrı ekrandan** fiş kesilebilir (mevcut ekranda onay penceresi bile yok) |

### A.3 Gösterim ve yetki

| # | Soru |
|---|------|
| **C-13** | **`StatusDescription`'ı kim üretiyor, hangi dilde?** Sözleşmede backend'den geliyor; §3.3 tablosu Türkçe (+parantez İngilizce), görsellerde Türkçe. **Backend serbest Türkçe metin dönerse çoklu dil kırılır** (MicroUI'lerde localization JSON var). **Öneri:** backend `StatusCode` + `ReasonCode` dönsün, metni UI localize etsin. Kabul mü? |
| **C-17** | **Hata gösterim biçimi:** §3.1 + §5.1 "hata **Status Description kolonunda**" ↔ image1 notu "*the error is shown as a brief notification (**no status, no column**)*". Hangisi? (Diyagram eski tasarımdan kalmış görünüyor) |
| **C-18** | **Yetki granülaritesi:** §9 yetkiyi **3 ekran** bazında tanımlıyor. **(a)** Ürün/SubProduct bazlı yetki gerekiyor mu (Treasury'ye erişip MM'i gör, FX'i görme)? **(b)** **Aksiyon bazlı** yetki gerekiyor mu — salt-görüntüleme rolü var mı? Reeskont kesmek muhasebe etkili bir işlem |
| **C-19** | **Audit / iz kaydı:** Sözleşmede "**kim** tetikledi, **ne zaman**" alanı yok. Manuel fiş kesme muhasebe etkili — kullanıcı + zaman + aksiyon (Generate/Regenerate) + valör seçimi kaydedilmeli mi? (Mevcut FX ekranında da **yok**) |

### A.4 MM'e özel

| # | Soru |
|---|------|
| **M-03** | **MM'de `Revaluation Type` karşılığı ne?** MM kodunda bu kavram **tespit edilmedi**. En yakın: `AccountingCalculationMethodType` (SL / IRRCL) — ama bu bir **hesap yöntemi**, "değerleme türü" değil. Görselde MM satırlarında "Interest Accrual" görünüyor. MM için bu filtrenin değer kümesi ne olacak? |
| **M-04** | **InterbankLoan ayrı SubProduct mu?** Doküman "MM/**Loan** Transactions" diyor → ikisi birlikte. IL modülü **opsiyonel** (`InterbankLoan:Enabled`; kapalı müşteride `TxnLoan` tablosu **yok**) → SubProduct listesi bu flag'e göre filtrelenecek, doğru mu? |
| **M-09** | **IssueBond bu ekrana girecek mi?** MM'in EOD batch'i IssueBond için **ayrı yola** sapıyor (`RevaluationBatchItem.cs:73` → `issueBondRevaluationOperationBase`). Girecekse: ayrı **Product** mı, MM'in **SubProduct**'ı mı? Yoksa Security ekranındaki **Bond** bu mu? |

---

## Bölüm B — Selim'in Kendi Kararı (teknik)

| # | Konu | Öneri |
|---|------|-------|
| **C-15** | **Kolon config'in fiziksel yeri:** dosya (`wwwroot/js/config/`), appsettings, yoksa DB/Common API? §5.5 "yeni ürünün kolonları için **servis tarafında** sürüm çıkılmaz" diyor ama **UI tarafında sürüm çıkmayı** gerektiriyor | Faz 1: **dosya** (basit, yeterli). Faz 2+: Common API'den servis et → deploy'suz ürün ekleme |
| **C-14** | **`Data` sözlüğünün yeri:** §6.4.2'de `Items`/`TotalCount` ile aynı seviyede listelenmiş — satır bazlı mı (`ManuelReeskontItem.Data`), response kökünde mi? | **Satır bazlı** (`ManuelReeskontItem.Data`). Sözleşmeye böyle yaz |
| **M-02** | **SubProduct → MM eşlemesi:** `DailyFlowProductType` (en zengin: MoneyMarket/InterbankLoan/Issue/Vakale/Murabaha/TermDeposit/Pass/Gil/Syndication/Securitization/PostFinancing) mi, `ProductDefinition.ExternalSubProductCode` mi? | **`ProductDefinition`** asıl kaynak (DB tablosu, müşteri bazlı değişebilir); enum sabit liste. Dropdown `ProductDefinition`'dan beslenmeli |
| **M-07** | **Manuel kesilen fişin `accEntryMain.Type`'ı:** `Revaluation = 2` mi, `Manuel = 5` mi? (`Manuel = 5` tanımlı ama yalnız IssueBond açıklamasında kullanılıyor) | **`Revaluation = 2`** — batch ile manuel aynı motoru kullanıyor, fiş tipi aynı olmalı; "kim kesti" bilgisi audit alanına (C-19) |
| **M-08** | **"En son aktif hareket" tanımı:** `MAX(accEntryMain.Id)` mi, `MAX(ValueDate)` mi, `CalculationDate == ExecutionDate` filtresi mi? Doküman §3.2 "en güncel ve **aktif** muhasebe kaydı esas alınır" diyor ama tanım vermiyor | Netleştirilmeli — durum türetmenin **kalbi** bu. Adayı: `CalculationDate == ExecutionDate` + `Type == Revaluation` + `IsReverse == false`, sonra `ReverseId == 0` kontrolü |
| **M-05** | **Fimple round kuralları** hangi alanlara uygulanacak (CLAUDE.md Hard Rule 4) | Mevcut `SendRevaluationAccountingAsync` yolunu kullandığımız için **muhtemelen zaten uygulanıyor** — doğrulanmalı |
| **R-04** | **`baseUrl` → `moduleCode` sözleşme değişikliği** iş birimi tarafından kabul edilmezse alternatif? | Alternatif: Web.UI'ye runtime base-URL resolver yaz (**yeni altyapı** + ADR gerekir). Karar: `moduleCode` teklif edilecek (kullanıcı onayı 2026-08-12) |

---

## Bölüm C — Kapanmış Sorular

| # | Soru | Cevap | Tarih |
|---|------|-------|-------|
| **M-01** | MM'de T+0 fiş + ters fiş deseni var mı? Yoksa MM'in `NotReversed` durumu iş anlamında yeniden tasarım gerektirir | ✅ **VAR, tam kurulu.** MM `accEntryMain`/`accEntry` şemasını FX ile **aynı alan isimleriyle** kullanıyor (`IsReverse`, `ReverseId`, `MessageKey`). Ayrı `RevaluationReverse` pipeline'ı + `AccountingReverseFactory` var. Zamanlaması bile parametrik: `RevaluationReverseType { Eod=1, Bod=2, Atomic=3 }` | 2026-08-12 |
| **M-06** | Manuel ekran EOD batch ile **aynı kod yolunu** mu kullanacak? | ✅ **Evet** — `IRevaluationAccountingService` + `IRevaluationReverseAccountingService`. Yeni hesap motoru **yazılmayacak** (ADR-MR-005) | 2026-08-12 |
| **C-16** | Doküman MicroUI'den hiç bahsetmiyor — base component monolit varsayımı üzerine kurulu. Nereye yazılacak? | ✅ **Kullanıcı kararı:** ekran `NetTrex.Web.UI`'de, fan-out **`NetTrex.Common` backend'inde** (DailyFlow deseni). Base component MicroUI'ler (Deriv, OptionsFX, MM) tarafından **Invoke** edilecek; MicroUI'si olmayan modüller Web.UI üzerinden aynı yapıyı kullanır | 2026-08-12 |
| **R-04a** | `baseUrl` mi `moduleCode` mü? | ✅ **`moduleCode`** — iş birimine sözleşme değişikliği olarak bildirilecek | 2026-08-12 |
