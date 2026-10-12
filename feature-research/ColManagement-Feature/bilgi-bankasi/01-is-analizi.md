# 01 — İş Analizi

> Kaynaklar: fonksiyonel doküman **v1.4 (30.09.2026)** + **toplantı ses kaydı** (53 sayfa ASR transcript'i).
> **Son güncelleme:** 2026-10-07
>
> 🔴 **KAYNAK GÜVENİLİRLİĞİ — önce bunu oku.** Toplantıda iş analisti (SPK_3) dokümanın **teknik/DB
> bölümünü sahiplenmiyor**: *"Teknik analizi tamamen [AI] için çıkardı. O yüzden yanlış olabilir…
> Ben bunları bilmiyorum. **Buralar yanlış olabilir**"* (transcript 1577-1600 — `CHK` constraint'i
> tanımıyor). Yani dokümanın **§10 DB tasarımı AI üretimi ve doğrulanmamış**; Excel'in kaynağı da o.
> **İş kararlarında transcript bağlayıcı**, ISO/mesaj standardı detayında doküman daha isabetli.

---

## 1. Collateral nedir

Bir tarafın karşı tarafa olan mevcut veya potansiyel kredi riskini azaltmak için verdiği **nakit** ya da
**menkul kıymet**. Bankalar arası yüksek meblağlı işlemlerde karşı tarafın temerrüdünde açık riski
sınırlar.

Sözleşme katmanı iki kademeli:

- **Master Agreement (çerçeve sözleşme)** — ISDA · GMRA · GMSLA. Temel ilişki, temerrüt, netting çerçevesi.
  *"Çerçeve sabit"* (transcript 7)
- **Collateral Annex (CSA)** — rakamsal kurallar. *"Annex'in rakamları değişiyor"* (7)

---

## 2. 🔴 Faz 1 kapsamı — transcript'ten

| Konu                                                          | Faz 1'de                                                                           | Kanıt (transcript satırı)                                                                                                                                                |
| ------------------------------------------------------------- | ---------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Nakit teminat**                                       | ✅ VAR                                                                             | *"Biz nakit tarafını yapacağız"* (15)                                                                                                                                 |
| **Menkul kıymet**                                      | ❌**YOK** — tasarımda duruyor, geliştirmeyi **başka ekip** yapacak | (14-16, 616-620)                                                                                                                                                            |
| **Nemalandırma / faiz**                                | ❌**KALDIRILDI** (toplantıda)                                               | *"kaldırsak daha mantıklı olur"* → *"Tamam"* → *"şurayı kaldırıyorum"* (518-542). Gerekçe: *"eklersem nemalandırma hesaplamasını da yap derler"* (552) |
| **Reeskont / tahakkuk**                                 | ❌ YOK                                                                             | SPK_2*"Reeskont hesaplamanız var mı?"* → SPK_1 **"Yok."** (993-995)                                                                                              |
| **Exposure / MTM otomatik hesabı**                     | ❌ YOK —**tutarlar ELLE giriliyor**                                         | *"Rakamların hesaplanması da elle yapılıyor… Adam elle giriyor"* (735-736); *"şu an planımız olmayan bir şey bu"* (1005-1010)                                  |
| **Müşteri tarafı**                                   | ❌ YOK — yalnız counterparty/interbank                                           | *"Müşteri tarafı bu yok. Müşteri yok"* (1099)                                                                                                                        |
| **Netting**                                             | Bankalar**gross** çalışıyor; alan yine de konsun                         | (1017-1020, 1106-1110)                                                                                                                                                      |
| **Değerleme modülü + karşı bankaya otomatik mail** | ❌ gelecek faz                                                                     | (901-904)                                                                                                                                                                   |
| **Ödeme mesajı (MT202/pacs.009)**                     | ✅ VAR — ama 🔴**ilk kez burada kuruluyor**                                 | *"gerçek para transferi yapacağımız **ilk yer burası**"* (1520-1522); *"bu modülün **iki katı kadar** orada bir iş var"* (1358-1360)               |
| **Confirmation/bildirim mesajı**                       | ⚠️**belirsiz** (ASR bozuk)                                                 | (1388-1394)                                                                                                                                                                 |
| **Limit servisi**                                       | ⚠️**toplantıda teyit edilmedi**                                           | doküman §6.3'te var, transcript'te yok                                                                                                                                    |

### Dokümanda **olup** transcript'te kaldırılan

1. 🔴 **Cash Interest Terms** (doküman §5.1.4, Excel `CollateralCashTerms`) → **kaldırıldı**
2. **EOD değerleme snapshot'ı** — günlük otomatik değerleme planda yok *(çıkarım)*
3. **Dispute Tolerance** — doküman §4.2/§8.4'te detaylı, transcript'te **hiç geçmiyor** *(belirsiz)*

---

## 3. Ekranlar

**3 ekran** (transcript 780): 2 tanım + 1 işlem.

```
Annex (sözleşmesel çerçeve)
  └─► Collateral Definition (hangi varlık teminat kabul edilir)
        └─► Collateral Transaction  ── 2 TAB ──┬─ Transaction
                                               └─ Transaction Detail (hareket defteri)
```

🔑 *"**İki tab'lı olacak Transaction**"* (758) · *"İki tane tanım ekranı olacak, sonra Collateral
Management olacak. Orada da Transaction gireceğiz"* (828)
🔑 Ayrı **Margin Call ekranı/nesnesi YOK** (doküman sat. 776 ile uyumlu).

### Kardinalite

- **Annex 1 : N Collateral Definition** — bir counterparty altında **70 taneye kadar** definition olabilir (433-440)
- 🔴 **Collateral Definition 1 : 1 aktif Transaction** — *"Bir Annex'e bağlı collateral için bir
  transaksiyon olabiliyor değil mi? İki olabilir mi? Olamaz değil mi? **Bu validasyonlarımız da olacak**"* (760-763)
- **Annex opsiyonel:** Definition standalone olabilir (`AnnexId` nullable)

---

## 4. 🔴 Transaction modeli — doküman ile transcript ÇELİŞİYOR

|                       | Doküman + Excel                              | Transcript                                    |
| --------------------- | --------------------------------------------- | --------------------------------------------- |
| Her Increase/Decrease | **ayrı** `TxnTransaction` satırı    | **aynı** master transaction'ın edit'i |
| Transaction Detail    | türetilmiş görünüm,**tablosu yok** | **gerçek tablo** — hareket defteri    |

**Transcript'in dediği:**

> *"Bizim bir **master transaction**'umuz o. Bu collateral'a bağlı olan transaction **bir tane** üretilsin.
> Onun günlük gelirleri giderleri, üzerine değişen balanslar **detail'e tutulsun**. Detail'de tutulursa
> ben onların **ödemesini, muhasebe iş numarasını** o detayların üzerine koyayım"* (736-740)
> SPK_4: *"Bütün değişimleri **ayrı bir defterde** tutalım"* (754) → *"Transaction detail gibi"* (756)

Davranış: *"Her açtığında buranın **boş** geliyor olması lazım"* (1163-1165) ·
*"Update ettiğimde şuradaki **global balansım değişiyordu**"* (1192-1194)

🔴 **Bu, Excel'de karşılığı olmayan en kritik karar.** Detail tablosunun ihtiyaç duyduğu kolonlar
(transcript'ten çıkarım): `TxnId` · `SeqNo` · `TradeDate`/`ValueDate` · `TransactionType` · `Amount` ·
`CurrencyCode` · `FxRate` · `TransactionValue` · `BalanceAfter` · **`AccountingReference`** · `MessageId` ·
`CreatedBy/Date`

### "Finansal etki yaratan edit" ayrımı

> *"Sen edit'e bastın… Sen gidip aslında comment'ini değiştirdin. Benim burada **gerçekten bir hareket
> var mı yok mu**? Bunu anlamam lazım"* (1313-1320) · *"description yazıp update etsem bile **finansal
> hiçbir etkisi yok**"* (1283-1285) · *"belli alanlar değişirse regenerate ediyorum"* (1302-1352)

→ Detail satırı **yalnız hareket alanları** değişince yazılır. Tetikleyici alan listesi tanımlanmalı.

---

## 5. Margin tipleri

**VM** (Variation Margin) · **IM** (Initial Margin) · **IA** (Independent Amount) · **Other Collateral**
*"Standartlar bu. Bu dünya böyle çalışıyor"* (46) — genişlemez.

- Annex'te **ürün başına** seçiliyor, 🔑 **`ALL` seçeneği var**: *"VM mi, IM mi, IA mı, Other mı?
  **All** seçersen hepsini kullanabilirim"* (160-164)
- **Bakiyeler ayrı takip ediliyor:** *"Onlar ayrı ayrı takip ediyorlar… Bir birlik teminatı, bir
  sürdürme teminatı gibi"* (168-175)
- Ürün kapsamı negatif de ifade edilebiliyor: *"sadece FX olmayacak, diğer tüm ürünler olacak"* (180)
  → `IsIncluded` bit kolonu bunu karşılıyor

---

## 6. Hesaplama parametreleri

| Kavram                      | Anlamı                                                                                        | Transcript     |
| --------------------------- | ---------------------------------------------------------------------------------------------- | -------------- |
| **Threshold**         | Teminatsız kabul edilen risk tavanı. 6M teminat − 2M threshold = 4M gönderilir             | (199-208)      |
| **MTA**               | Transfer alt sınırı.*"MTA 200.000… altına düşerse o 50'yi gönderme"*                 | (213-215)      |
| **Rounding**          | Aşağı/yukarı/en yakın**+ katları**: *"15.000 giremezsiniz… 10.000'in katları"* | (258-268)      |
| **Dispute Tolerance** | ⚠️ Transcript'te**hiç geçmiyor**                                                     | doküman §4.2 |

🔴 **Her kural için en fazla İKİ satır:** *"İki tane. Bir tane bizim, bir tane karşı tarafın…
İki olabilir maksimum"* (251-255). Asimetrik olabiliyor: *"sen bana 1 milyona kadar… ama ben sana
2 milyondan sonra"* (195-198).

⚠️ **Açık talep — dinamik kural motoru:** SPK_1 *"Yeni kriter eklenme ihtimali yok mu? Bunlara bir
dinamiklik düşünelim… Bir JavaScript olsa… transaction'ı verdiğin anda true/false'u çıkaralım"*
(275-282). **Cevap alınmadı, karara bağlanmadı.**

---

## 7. Yön semantiği (3 kez teyit edildi)

| Transaction Type   | Anlamı            | Para                       |
| ------------------ | ------------------ | -------------------------- |
| **INCREASE** | Teminatım artar   | 🔑**BANA gelir**     |
| **DECREASE** | Teminatım azalır | 🔑**BENDEN çıkar** |

(238-239, 669-683, 918-920). → Excel'in `WeReceiveSsiId` INCREASE'de zorunlu / `SendPayment` yalnız
DECREASE kuralı ✅ **doğru**.

**Trade Date = Value Date, T+0:** *"Trade date ile value date aynı oluyor. Zaten işlem aynı gün
gönderiliyor. T0"* (660-661).

---

## 8. Bakiye takibi

- **Global balance base currency'de**: *"base currency TL ama dolar göndermek istiyorsam… global
  balansım, toplamda ne kadar para vermişim, o doları TL'ye çevirip tutuyorum"* (288-303, 692-700)
- **Döviz bazında ayrı takip de mümkün**: *"bir bankanın iki farklı teminatını takip edebiliyor.
  Euro'yu ayrı, doları ayrı"* (506-509)

→ İki kavram var: **para birimi bazında bakiye** + **base ccy'de global balance**.

---

## 9. Validasyon — UI mı backend mi

🔑 **Kritik pasaj (650-658) çözümü:** Konu **Annex'siz Definition** senaryosu.

- **Annex YOKSA** → Threshold/MTA/Rounding **değerleri de yok** → o validasyonlar **çalışmaz**,
  kullanıcı serbest tutar girer
- **Annex VARSA** → değerler ekranda **gösterilir (UI)** ve **backend kontrol eder**

> *"Onları da zaten biz **ön tarafta göstereceğiz, arka tarafta kontrolümüz var**"* (654-656)
> *"onu bilmen lazım ama **kontrollerini yapacağız**"* (223)

**Tek kaynak backend; UI yalnız bilgilendirme + erken uyarı.**

Diğer validasyonlar: Increase/Decrease yönü ile taraf kontrolü (237-246) · Collateral başına tek aktif
transaction (760-763) · MTA altı tutar reddi (235-236).

---

## 10. Entegrasyon

### Fimple

> *"Verify ettiğim anda bir mesaj generate ediyorum. Generate ettiği mesajı **Fimple'a iletiyor**.
> Sonra Fimple'da sürekli onun **state'ini takip edip, 50-60 tane state'i var**… **Bizde bu tasarım
> hiç yok**"* (1480-1490)
> *"**56 state'i** alıp ben de Beklemede / Gönderildi / Bekliyor / Ödendi / Ödenmedi — **5 state'e**
> denk gelecek"* (1536-1542)

⚠️ SPK_1 mesaj tablosunun **ortak/paylaşılan** olmasını istiyor: *"ödeme mesajlarının **ara bir
tablosu**… **ortak bir yerde**"* (1490-1494). Excel bunu Collateral DB'sine koyuyor.
🔴 **Mimari açık konu.**

### Mesaj tipleri

- **Nakit:** MT202 / pacs.009. Collateral'a özel mesaj **yok** — *"para transferi olduğu için
  collateral'da da kullanılıyor"* (1416-1424)
- **Menkul:** sese.023 / MT54x (1432-1434)
- Fimple hem MT hem MX destekliyor (1468-1470)
- 🔑 **Route önce seçilir, mesaj tipi türetilir** (1444-1452) — doküman ve Excel ile ✅ hizalı
- 🔴 **SEPA/ISO geçişi + adres/kontak zenginleştirmesi** ayrı, büyük iş (1600-1615) — faz-1 kapsamı belirsiz

### Payment Component

*"**Aynen, bu bizim Payment Component'imiz**"* (1043-1067). Default'lar Definition'da,
Transaction'da yeniden doldurulabilir (1073-1077).
Tipler: Bank-to-bank · Account-to-account · Nostro/Vostro (1111-1115).

### FX kuru

*"Değiştireceksek o kuru bizim rate'imiz çalışmayabilir"* → *"**manuelde yazabiliriz**"* →
*"**Biz default koyarız**… Karşı banka 'sen bana 49'dan çevir' diyor"* (885-893)
→ Kurun **manuel mi sistem mi** olduğu saklanmalı.

### Muhasebe

- *"Margin call ile aynı muhasebeyi yapıyoruz"* (989); banka açısından sadece **para transferi**,
  Nostro/Vostro (964-975); ayrı reeskont/kar-zarar muhasebesi yok (962-964)
- 🔑 Detail satırına **muhasebe iş numarası** konması isteniyor (739)

### Menkul saklama (faz 2)

Takasbank · Euroclear · **MKK** (601-614). ⚠️ Excel'de **MKK yok**.

---

## 11. Terminoloji sözlüğü (ASR bozulmalarıyla)

| İş birimi (TR)               | İngilizce                         | ASR bozulması                  |
| ------------------------------ | ---------------------------------- | ------------------------------- |
| Çerçeve sözleşme           | Master Agreement (ISDA/GMRA/GMSLA) | `İZDA` `CIMRA` `CİMSLA` |
| Annex / aneks                  | Collateral Annex / CSA             | —                              |
| Teminat                        | Collateral                         | `korektör` `kolye`         |
| Başlangıç teminatı         | Initial Margin (IM)                | `Initial Monitory`            |
| Değişen/sürdürme teminatı | Variation Margin (VM)              | `Relation Monitory`           |
| Bağımsız teminat            | Independent Amount (IA)            | `Independent Envelope`        |
| Karşı taraf                  | Counterparty                       | `kanti partisi`               |
| Eşik                          | Threshold                          | 🔑`T-shirt`                   |
| Minimum transfer tutarı       | MTA                                | `amorti` `emanet`           |
| Nemalandırma                  | Interest accrual / remuneration    | —                              |
| Kesinti                        | Haircut (asset + FX)               | —                              |
| Saklama kurumu                 | Custodian / CSD-ICSD               | —                              |
| Defter                         | Ledger                             | —                              |
| Hepsi                          | All (MarginType)                   | `Adrede`                      |
| Fimple                         | Fimple                             | `Phinexus`                    |
| menkul                         | menkul kıymet / security          | `menkun`                      |
