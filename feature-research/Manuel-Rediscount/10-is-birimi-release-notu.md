# Manuel Reeskont — İş Birimi Release Notu

> **Amaç:** Bu doküman, Manuel Reeskont ekranının (Treasury/Security/Investment) **nasıl çalıştığını**
> baştan sona, iş biriminin anlayacağı dille anlatır. Teknik ekip için detaylar dipnot/ek olarak verildi.
> **Kaynak:** `Manuel Reeskont v1.docx` (28 Temmuz 2026) — bu ekran o dokümanın uygulamaya geçmiş hali.
>
> 🔴 **Ekran görüntüleri:** Bu doküman ekran görüntüsü **yer tutucularıyla** hazırlandı — Claude sohbet
> içinde gösterilen görselleri diske yazamıyor (yalnızca görüyor, dosya olarak kaydedemiyor). Aşağıdaki
> `[GÖRSEL-N]` etiketli yerlere kendi ekran görüntülerinizi ekleyin (aynı görüntüleri bu sohbette
> paylaştınız — hangi görselin nereye gideceği başlıkta belirtildi).
>
> **Tarih:** 2026-08-17 · **Ekran durumu:** Faz 1-2-3 tamamlandı, doküman uyumluluğu **%93 (43/46 madde)**,
> tarayıcı testi devam ediyor.

---

## 1. Ekran Ne İşe Yarıyor

Manuel Reeskont, vadesi gelmemiş işlemlerin (mevduat, sendikasyon vb.) faiz tahakkukunu **manuel olarak**
reeskont edip muhasebe fişi kesmeyi sağlayan ekrandır. Normalde bu işlem gün sonu (EOD) batch'i tarafından
otomatik yapılır; bu ekran, batch'in yapacağı işi **istenildiğinde elle** tetikleme imkânı verir
(örn. gün içinde erken kapanış, düzeltme, test senaryosu).

Üç ayrı menü altında **aynı ekran motoru** çalışır — ürün grubuna göre farklı veri gösterir:

| Menü | ProductGroup | Kapsam |
|---|---|---|
| **Manuel Reeskont - Hazine** | `Treasury` | Para piyasası, FX, türev/swap, FX opsiyon işlemleri |
| **Manuel Reeskont - Menkul Kıymet** | `Security` | Sabit getirili menkul kıymet işlemleri |
| **Manuel Reeskont - Yatırım** | `Investment` | Yatırım fonu işlemleri |

`[GÖRSEL-1]` — sidebar menüsünde 3 ekranın göründüğü görsel (ilk paylaştığınız tam ekran görüntü).

---

## 2. Ekrandaki Alanlar — Veri Nereden Geliyor?

Bu bölüm **en kritik** kısım: her alanın verisi nereden geliyor, kim değiştirebiliyor, kod değişikliği
mi gerektiriyor yoksa bir yapılandırma dosyası mı yeterli.

### 2.1 Özet tablo

| Alan | Kaynak | Statik mi / Dinamik mi | Değiştirmek için |
|---|---|---|---|
| **Date** | Sunucu — o anki **iş günü** (sistem "logical date"i) | 🟢 **Dinamik** — her açılışta güncel | Kod değişikliği gerekmez, otomatik |
| **Product** | Sunucu — ekran koduna gömülü **kısa liste** (Treasury: MM, FX, DerivSwp, OptFX) | 🟡 **Yapılandırılabilir** — kod içinde ama tek satırlık, sabit veri değil | Bir satır kod ekleme (yeni ürün) |
| **Sub Product** | Bir **yapılandırma dosyası** (o modülün sahibi ürün ekibi tarafından teslim edilir) | 🟢 **Dinamik/config-driven** | Sadece dosya düzenleme, **kod değişikliği yok** |
| **Revaluation Type** | Aynı yapılandırma dosyası | 🟢 **Dinamik/config-driven** | Sadece dosya düzenleme, **kod değişikliği yok** |
| **Reverse Value Date** | Sunucu — **Date + 1 gün** olarak hesaplanır | 🟢 **Dinamik** — Date değişince otomatik kayar | Kod değişikliği gerekmez |
| **Grid verisi (satırlar)** | İlgili modülün (MM/FX/…) kendi API'si — **canlı veri**, her zaman güncel | 🟢 Tamamen dinamik | — |

**Kısacası:** Yalnızca "hangi ürünler bu ekranda görünsün" sorusunun cevabı (Product listesi) ekran
kodunun içinde küçük bir listedir — bunun nedeni, **hangi modüle gidileceği** bir sunucu/güvenlik
kararı olduğu için (bir istek asla yanlış modüle gitmemeli). Alt ürün listesi, değerleme tipi listesi
ve grid'deki kolonlar ise **hiçbir şekilde kodda yazılı değildir** — her modül ekibinin kendi
teslim ettiği bir yapılandırma dosyasından okunur. Bu, ekranın **sürdürülebilir** olmasının sebebidir:
yeni bir alt ürün eklemek için kimse Web.UI'yi derleyip yeniden dağıtmaz, yalnızca o dosyayı günceller.

### 2.2 Detaylı akış — teknik ek

<details>
<summary>Teknik ekip için: dosya/kod referansları</summary>

- **Date:** `RediscountControllerBase.Index()` → `_DateTimeProvider.GetCurrentDateTime().Date`.
  Aynı çağrı, platformun EOD ekranında (`EodController.cs:47`) doğrudan `LogicalDate` alanına
  atanıyor — yani bu, takvim "bugünü" değil sistemin **iş günü**dür, platformun her yerinde aynı
  kaynaktan gelir.
- **Product:** Her ekranın kendi controller'ında (`TreasuryRediscountController.GetProducts()`,
  `SecurityRediscountController.GetProducts()`, `InvestmentRediscountController.GetProducts()`)
  küçük bir `{Value, Text, ModuleCode}` listesi. `ModuleCode` — o ürünün hangi modülün API'sine
  (MM/FX/FI/InvFund/DerivSwp/OptFX) gideceğini sunucuya söyler. Bu liste bilinçli olarak koddadır
  çünkü "hangi isteğin hangi modüle gideceği" bir yönlendirme/güvenlik kararıdır.
- **Sub Product + Revaluation Type + Grid kolonları:** `wwwroot/js/config/manual-rediscount/
  {treasury,security,investment}.json` — sayfa her açıldığında sunucu bu dosyayı okur
  (`ManualRediscountViewComponent.ReadColumnsConfigAsync`), içeriğini sayfaya **görünmez bir alana**
  gömer (ekstra bir ağ isteği olmadan). Tarayıcı, Product değiştikçe bu veriden ilgili ürünün
  alt-ürün/değerleme-tipi/kolon bloğunu okur (`mrResolveProductConfig`). Örnek — bugünkü Treasury
  dosyasının MM bloğu:
  ```json
  {
    "product": "MMLoanTransactions",
    "moduleCode": "MM",
    "subProducts": [
      { "value": "Murabaha", "text": "Murabaha" },
      { "value": "Wakala", "text": "Wakala" }
    ],
    "revaluationTypes": [
      { "value": "InterestAccrual", "text": "Interest Accrual" }
    ]
  }
  ```
  Bu dosyaya yeni bir alt ürün eklemek (örn. "Tawarruq") **tek satır JSON eklemek**tir — kod
  derlemesi/dağıtımı gerekmez.
- **Reverse Value Date:** `Default.cshtml:83` → `Model.ExecutionDate.AddDays(1)` (düz takvim +1,
  hafta sonu/tatil atlaması yok — doküman da bunu şart koşmuyor, kullanıcı serbestçe değiştirebilir).
- **Grid verisi:** `TreasuryRediscount/Load` ucu → `ManualRediscountQueryService` → ilgili modülün
  Refit client'ı (bugün yalnız MM bağlı) → modülün kendi veritabanı. **Cache yok, her sorgu canlı.**

</details>

`[GÖRSEL-2]` — Date/Product/Sub Product/Revaluation Type/Reverse Value Date alanlarının göründüğü
filtre satırının yakın çekimi.

---

## 3. Durum Modeli ve Renkler

Her işlem satırı 5 durumdan birinde olur:

| Durum | Anlamı | Renk |
|---|---|---|
| **Not Rediscounted** | Reeskont fişi hiç kesilmemiş | 🟠 Turuncu |
| **Processing** | İşlem sürüyor (geçici, kalıcı görünmez) | 🔵 Mavi |
| **Not Reversed** | Reeskont fişi kesildi, ters fişi henüz kesilmedi | 🟡 Sarı |
| **Rediscounted** | Reeskont + ters fiş tamamlandı | 🟢 Yeşil |
| **Error** | İşlem hata verdi | 🔴 Kırmızı |

Ekranın üstünde durum bazlı **pill (buton) filtresi** var: `All / Not Rediscounted / Not Reversed /
Rediscounted`. Bir pill'e tıklamak grid'i o duruma göre filtreler. Filtrenin **hemen altında** bir
özet şeridi vardır: *"Toplam 248 kayıt · 120 Not Rediscounted · 60 Not Reversed · 50 Rediscounted"* —
bu sayılar **sayfadaki değil, filtrenin tamamındaki** kayıt sayılarıdır.

`[GÖRSEL-3]` — durum pill'lerinin ve özet şeridinin göründüğü kısım.

---

## 4. Butonlar — Ne Zaman Aktif, Ne Yapıyor

### 4.1 Generate

| Durum | Aktif mi? |
|---|---|
| Hiç satır seçili değil | ❌ Pasif |
| En az 1 satır seçili, hepsi **aynı** Revaluation Type | ✅ Aktif |
| Seçim **birden fazla farklı** Revaluation Type içeriyor | ❌ Pasif — buton altında *"Seçim birden çok Revaluation Type içerdiğinden Generate pasiftir"* uyarısı **kalıcı olarak** gösterilir (3 saniyede kaybolan bildirim değil) |

**Ne yapar:** Seçili `Not Rediscounted` satırlar için reeskont fişi (T+0, Date alanındaki tarih) keser;
`Not Reversed` satırlar için ters fiş (T+1, Reverse Value Date) keser. Tıklanınca önce bir **onay
penceresi** açılır — hangi işlemin hangi tarihle yapılacağını madde madde gösterir, kullanıcı onaylamadan
hiçbir şey çalışmaz.

### 4.2 Regenerate

| Durum | Aktif mi? |
|---|---|
| Hiç satır seçili değil | ❌ Pasif |
| En az 1 satır seçili (Revaluation Type karışık olsa bile) | ✅ Aktif — bu buton karışık seçimden **etkilenmez** |

**Ne yapar:** Seçili satırları **durumlarına göre** yeniden değerler:
- `Not Rediscounted` → önceki değerleme yok, yeni değerleme oluşturulur.
- `Not Reversed` / `Rediscounted` → önceki değerleme geri alınır, yeni değerleme oluşturulur.
- `Processing` / `Error` → işleme uygun değil, **kapsam dışı bırakılır** (sessizce atlanmaz, onay
  penceresinde ayrıca "N kayıt kapsam dışında bırakılır" satırı gösterilir).

Onay penceresi burada da açılır, bu sefer **durum bazlı kırılım** halinde (kaç kayıt hangi durumda,
her birine ne olacağı).

### 4.3 Ortak kurallar

- İşlem çalışırken (onay verildikten sonra) **her iki buton da** kilitlenir — aynı işlemi iki kez
  tetiklemeyi engeller.
- Sonuç **satır bazlı** gösterilir: kaç kayıt başarılı, kaç kayıt başarısız — başarısızsa sebebiyle
  birlikte (örn. *"Aynı işlem için başka bir istek çalışıyor"*, *"Zaten reeskont edilmiş"*).
  Bazı satırlar başarısız olduysa ekran asla toptan "başarılı" demez.
- **Toplu seçim menüsü** (☑ ikonunun yanı): Select All / 100 / 50 / 25 / Custom… — seçim yalnızca
  **o an ekrana yüklenmiş** satırları kapsar (henüz görülmeyen bir satıra yanlışlıkla fiş kesilmesin
  diye bilinçli bir sınırlama — muhasebe etkili bir işlem geri alınması pahalıdır).

`[GÖRSEL-4]` — Generate/Regenerate butonlarının ve onay penceresinin göründüğü an.

---

## 5. Bilinen Sınırlamalar / Henüz Hazır Olmayanlar

| Ne | Durum |
|---|---|
| **FX, DerivSwp, OptFX ürünleri** (Treasury) | Dropdown'da görünüyor ama henüz **arkası boş** — ilgili modül ekibi kendi yapılandırma dosyasını + API ucunu teslim etmedi. Seçilirse ekran artık kırmızı hata **vermiyor**, "Bu modül için ekran henüz hazır değil" uyarısı gösteriyor (2026-08-17'de düzeltildi). |
| **Security / Investment ekranları** | Aynı durum — FI ve InvFund modül uçları ürün ekiplerinde. |
| **Değerleme öncesi tutar önizlemesi** | Kapsam dışı bırakıldı (ileride ayrı bir faz). |
| **"Tüm veri kümesini seç"** | Doküman bunu istiyordu, bilinçli olarak **yapılmadı** — görülmeyen satıra fiş kesme riski var. |
| **MicroUI'ye taşıma** | Kullanıcı kararına bağlı, henüz başlamadı. |

---

## 6. 2026-08-17'de Düzeltilen İki Sorun

1. **Kırmızı "[object Object]" hatası (grid içinde).** Sistem verileri getirirken bir ağ/sunucu
   hatası olduğunda (örn. geçici bağlantı kopması), ekran bunu **düzgün bir uyarı mesajı yerine** ham
   teknik bir metinle gösteriyordu. Kod tarafında eksik bir hata yakalama bulundu ve düzeltildi —
   artık aynı durumda kullanıcı "Kayıtlar getirilemedi" gibi anlaşılır bir uyarı görecek.
2. **FX ürünü seçilince ekranın "bozuk" görünmesi.** Sebebi yukarıda (§5) anlatıldı — artık
   bilgilendirici bir mesajla gösteriliyor, kırmızı zorunlu-alan hatası yok.

---

## 7. Doküman Uyumluluğu — Madde Madde (Özet)

> Tam teknik tablo: `.ai-agent/manuel-reeskont/09-dokuman-uyumluluk-raporu.md` (46 madde, satır satır
> "doküman ne istedi / biz ne yaptık / kanıt"). Aşağıda iş birimi için özet:

| Bölüm | Sonuç |
|---|---|
| Amaç, kapsam, hiyerarşi (Ekran → Ürün → Alt Ürün) | ✅ 9/9 tam |
| Durum modeli (5 durum + geçişler) | ✅ 6/6 tam |
| Fonksiyonel kurallar (Generate/Regenerate, onay penceresi) | ✅ 9/10 tam, 1 bilinçli sapma (Execute Selected yerine Generate/Regenerate — doküman iki farklı tasarım nesli taşıyordu, yenisi seçildi) |
| Ekran tasarımı (zorunlu alanlar, kolon sırası, filtreler) | ✅ hepsi kapatıldı — ilk turda 9 eksik bulundu, **tamamı kapatıldı** |
| Teknik mimari (endpoint'ler, request/response şekli) | ✅ 12/14 tam, 2 küçük onaylı sapma |
| Renkler (§7.1) | ✅ düzeltildi — Processing mavi, Not Reversed sarı (ilk turda ikisi yanlıştı) |
| Yetkilendirme | ✅ 3 ekran ayrı ayrı yetkilendirildi |

**Genel: 43/46 madde (%93) tam veya gerekçeli-onaylı sapmayla karşılandı. Sıfır madde "yapılmadı."**
Geriye kalan 3 madde **bilinçli kapsam dışı** kararlarıdır (§5'te listelendi), unutulan değil.

---

## 8. Ekran Görüntüsü Eki

| # | Ne gösteriyor | Nereye |
|---|---|---|
| GÖRSEL-1 | Sidebar menü + genel ekran | § 1 |
| GÖRSEL-2 | Filtre alanları yakın çekim | § 2.2 |
| GÖRSEL-3 | Durum pill'leri + özet şeridi | § 3 |
| GÖRSEL-4 | Generate/Regenerate + onay penceresi | § 4.3 |

**Not:** Bu ekran görüntülerini siz ekleyeceksiniz (sohbette paylaştığınız görseller) — yukarıdaki
tabloda hangisinin nereye gittiği belirtildi.
