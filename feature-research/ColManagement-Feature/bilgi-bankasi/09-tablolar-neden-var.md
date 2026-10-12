# 09 — Tablolar Neden Var? (domain anlatımı)

> **Kime yazıldı:** Collateral domainini bilmeyen ama bu modülü yazacak geliştiriciye.
> İş mantığını ve tabloların varlık sebebini anlatır — kolon listelerini **tekrarlamaz**
> (onlar `../2026-10-04-Collateral-DB-Sema-v4.xlsx`'te).
> **Son güncelleme:** 2026-10-07

---

## 1. Problem: teminat neden var?

Bizimle Garanti arasında bir **FX forward** var — 3 ay sonra 10M USD alacağız, kur bugünden sabit.
Bugünden vadeye kadar piyasa oynuyor. USD yükselirse işlem **bizim lehimize** döner, Garanti bize
borçlanır. Garanti vadeden önce batarsa o kârı alamayız.

**Teminat bunu çözer:** kim kârdaysa, karşı taraftan nakit/menkul tutar. Piyasa her gün oynadığı için
teminat tutarı da değişir — bugün 2M alırsın, yarın 500K geri verirsin.

Bu alışverişin kuralları önceden **yazılı sözleşmeye** bağlanır. Collateral modülü bu sözleşmeyi ve
günlük hareketleri yönetir.

---

## 2. Neden 3 katman?

```
1. ANNEX          sözleşme kuralları        → yılda birkaç kez değişir
2. DEFINITION     neyi kabul ediyorum       → ayda birkaç kez değişir
3. TRANSACTION    bugün ne hareket etti     → her gün
```

**Neden ayrı?** Hepsi transaction'da olsaydı her gün sözleşme şartlarını yeniden girmek gerekirdi.
Dahası sözleşme değiştiğinde **eski işlemler eski kurallarla açıklanabilir kalmalı** — denetçi 3 ay
sonra *"neden 5M yatırdım da 4.9M saydın?"* diye sorduğunda cevap verilebilmeli.

🔑 **Tasarımın tamamı bunun üzerine kurulu.**

---

## 3. Katman 1 — ANNEX (sözleşme)

### `Annex` — sözleşme başlığı

Garanti ile imzalanan CSA'nın sistemdeki karşılığı.

| Kolon                          | Ne işe yarar                                                                                                                            |
| ------------------------------ | ---------------------------------------------------------------------------------------------------------------------------------------- |
| `AnnexCode` + `RevisionNo` | İş kodu +**sürüm**. Sözleşme tadil edilince **yeni satır** açılır, eskisi durur                                    |
| `CustomerId`                 | Hangi karşı taraf (Garanti)                                                                                                            |
| `MasterAgreementText`        | *"ISDA 2002 Master Agreement"* — serbest metin, çünkü onlarca varyant var                                                          |
| `CollateralDocumentText`     | *"2016 CSA for Variation Margin"* — aynı sebeple serbest metin                                                                       |
| `BaseCurrencyCode`           | 🔑**Her şeyin ölçüldüğü para birimi.** EUR yatırılsa bile *"ne kadar teminat var"* sorusu bu para biriminde cevaplanır |
| `Direction`                  | BOTH / POST_ONLY / RECEIVE_ONLY — sadece verebilir miyim, alabilir miyim, ikisi de mi                                                   |
| `ValidFrom` / `ValidTo`    | Bu şartların geçerli olduğu dönem                                                                                                   |
| `DisputeToleranceAmount`     | Benim hesabım 5M, karşınınki 5.05M. Fark toleransın altındaysa uyuşmazlık açılmaz                                              |

### `AnnexProductScope` — sözleşme hangi işlemleri kapsıyor

Satır başına bir **Product + SubProduct + MarginType** kombinasyonu.

**Neden gerekli:** sözleşme FX forward'ları kapsıyor olabilir ama repo'yu kapsamıyordur. Ya da FX için
VM teminatı var ama IM yok.

`IsIncluded` bit'i sayesinde *"FX hariç tüm ürünler"* denebiliyor — kapsam dışı da satır olarak yazılıp
`0` işaretleniyor. (Transcript 180: *"sadece FX olmayacak, diğer tüm ürünler olacak"*)

### `AnnexMarginRule` — rakamlar

🔑 **Kural taraf başına ayrı**, çünkü şartlar **asimetrik**:
*"Sen benim 1M riskimi teminatsız taşıyabilirsin ama ben seninkinin ancak 2M'ını taşırım."* (195-198)

| Kolon                                   | Somut anlamı                                                                                             |
| --------------------------------------- | --------------------------------------------------------------------------------------------------------- |
| `Party`                               | OWN / COUNTERPARTY — kural kime ait                                                                      |
| `ThresholdAmount`                     | Teminatsız kabul edilen risk tavanı.**Risk 6M, threshold 2M → yalnız 4M teminat istenir**       |
| `MtaAmount`                           | Minimum transfer. Fark 50K, MTA 200K →**hiç para hareket etmez.** Operasyonel gürültüyü keser |
| `RoundingAmount` + `RoundingMethod` | 207K çıktıysa 10K'nın katına yuvarla → 210K.*"15.000 giremezsiniz, 10.000'in katları"* (265-268) |

🔑 Kapsam satırı başına **en fazla 2 satır** — biri bizim, biri karşı tarafın (251-255).

---

## 4. Katman 2 — DEFINITION (neyi kabul ediyorum)

### `CollateralDefinition`

Annex'in altında somut olarak ne kabul edildiği: *"Garanti'den TRY ve EUR nakit alırım"* ya da
*"şu ISIN'li devlet tahvilini alırım"*.

- Bir Annex'in altında **onlarca definition** olabilir — transcript'e göre **70'e kadar** (433-440)
- `AnnexId` **nullable** — sözleşmesiz standalone tanım da yapılabiliyor
- `CollateralType` (CASH / SECURITY) hangi alt tabloların devreye gireceğini belirler

### Nakit tarafı

| Tablo                                    | Ne işe yarar                                                                                                                                                                                                                                |
| ---------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **`CollateralEligibleCurrency`** | Hangi para birimleri kabul ediliyor.`FxAdjustmentRate` burada: sözleşme *"EUR yatırırsan TRY değerinden %2 kır"* diyorsa o oran                                                                                                    |
| **`CollateralCashTerms`**        | Elinde tuttuğun nakde**faiz ödersin** (nemalandırma). Referans oran, spread, gün sayma, ödeme sıklığı. ⚠️ Faz 1'de **yalnız saklanır**, hesaplama motoru yok — toplantıda da kaldırılması konuşuldu (518-542) |
| **`CollateralSettlementMap`**    | Paranın fiziksel olarak nereye gideceği: hangi hesap, hangi SSI, hangi ödeme rotası. Yön bazında ayrı (gelen/giden farklı hesap). 🔑**Neden burada, transaction'da değil?** Dealer her gün hesap numarası yazmasın diye    |

### Menkul tarafı

| Tablo                                 | Ne işe yarar                                                                                                |
| ------------------------------------- | ------------------------------------------------------------------------------------------------------------ |
| **`CollateralSecurityRule`**  | Kural bazlı uygunluk:*"devlet tahvili, rating ≥ A, kalan vade < 5 yıl"*                                 |
| **`CollateralSecurityISIN`**  | Tekil liste:*"tam olarak şu ISIN'ler"*                                                                    |
| **`CollateralSecurityTerms`** | Menkul nasıl değerlenecek: fiyat kaynağı, kirli/temiz fiyat,**haircut** oranları, minimum nominal |

Hangisinin geçerli olduğunu definition'daki `SecurityScope` söyler (Eligibility Rule ↔ Specific ISIN).

> **Haircut nedir:** 1M'lik tahvil 1M sayılmaz, %5 kırpılıp 950K sayılır — çünkü fiyatı düşebilir.
> 🔑 **Nakitte haircut YOKTUR** (1 TL her zaman 1 TL'dir); yalnız para birimi farkı için
> `FxAdjustment` vardır. Doküman bu ayrımı özellikle vurguluyor (§5.1.5).

---

## 5. Katman 3 — TRANSACTION (hareket)

### `TxnTransaction` — işlem başlığı

| Kolon                          | Neden var                                                                                                                     |
| ------------------------------ | ----------------------------------------------------------------------------------------------------------------------------- |
| `DefinitionId` / `AnnexId` | 🔑**Hangi kural sürümüyle yapıldığı.** Koda değil, **o günkü revizyona** işaret eder                   |
| `TransactionType`            | INCREASE =**para bana gelir** · DECREASE = **benden çıkar** (transcript'te 3 kez teyit: 238, 669-683, 918-920) |
| `MarginType`                 | VM/IM/IA/Other — 🔑**bakiyeler ayrı takip edilir**, karıştırılmaz (168-175)                                       |
| `TradeDate` / `ValueDate`  | Anlaşma günü / para hareket günü. Pratikte aynı,**T+0** (660-661)                                                 |
| `LogicalReference`           | Sistemin ürettiği iş referansı (`sp_GetNewRefNumber`)                                                                   |
| `LifecycleStatus`            | Draft → Verified → Sent → Settled —**settlement** yaşam döngüsü                                                 |
| `StateId`                    | Maker-checker onayı (girildi/onaylandı/reddedildi) — yaşam döngüsünden**AYRI**                                   |
| `Description` / `Memo`     | Operasyonun not alanı.*"O şeyin durumunu yazsın, ertesi gün hatırlasın diye"* (1232-1236)                             |
| `AccountingReference`        | Muhasebe iş numarası (739)                                                                                                  |

### `TxnTransactionCash` ve `TxnTransactionSecurity` (1:1 alt tip)

🔑 **Neden ayrı tablo?** Nakit ve menkulün alanları tamamen farklı. Tek tabloda tutulsa kolonların
yarısı hep NULL olur.

**Değerleme zinciri — nakit:**

```
Amount × FxRate = TransactionValue
TransactionValue × (1 − FxAdjustmentRate) = AdjustedEligibleValue
```

**Değerleme zinciri — menkul:**

```
Nominal × Price / PriceFactor = MarketValue
MarketValue × FxRate × (1 − AssetHaircut) × (1 − FxHaircut) = AdjustedEligibleValue
```

`CurrentBalanceBefore` — işlem öncesi bakiyenin **fotoğrafı**, sonradan kanıt için.

---

## 6. Destek tabloları — hepsinin tek mantığı: **kanıt**

Bu grubun tamamı *"o anki hesabı dondurmak"* için var.

| Tablo                                         | Neden                                                                                                                                                                                                                                                                                                                       |
| --------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **`CollateralRevaluation`**           | Bugün kullanılan kur yarın farklı olacak. Denetçi*"neden 49.82M saydın?"* diye sorduğunda o anki kur/fiyat/haircut gösterilebilmeli.`SnapshotStage` **ENTRY** (kullanıcının gördüğü) ve **VERIFY** (sunucunun hesapladığı) ayrı tutulur — 🔑 **ikisi tutmazsa işlem kesinleşmez** |
| **`TxnCollateralLimit`**              | Limit servisinin Verify anındaki cevabı. 🔑 Verify'ı bloke edip etmeme kararını**ekran değil servisin `blocking_flag`'i** verir, o da donuyor                                                                                                                                                                 |
| **`TxnCollateralPaymentInstruction`** | 4 SSI slotu. INCREASE'de`TheySend`+`WeReceive`, DECREASE'de `WeSend`+`TheyReceive` zorunlu. **Sürümlü** — Verify sonrası üzerine yazılmaz                                                                                                                                                              |
| **`TxnCollateralMessage`**            | Üretilen SWIFT/ödeme talimatı (pacs.009 / MT202 / sese.023)                                                                                                                                                                                                                                                              |
| **`TxnCollateralMessageEvent`**       | O mesaja ne oldu: Sent → Accepted → Settled.**Append-only.** 🔑 Neden ayrı tablo? *"Ağ kabul etti"* ile *"para gerçekten gitti"* **farklı olaylar** ve ikisinin de zamanı lazım. Fimple'ın **56 state'i** buraya ham yazılıp **5 iş durumuna** indiriliyor (1536-1542)              |
| **`CollateralAuditLog`**              | Kim ne zaman neyi değiştirdi (before/after JSON)                                                                                                                                                                                                                                                                          |

### `TxnCollateralPosition` — bakiye

İki sebepten var:

1. **Performans** — her seferinde tüm defteri `SUM` etmemek için
2. 🔴 **Eşzamanlılık** — iki kullanıcı aynı anda Decrease yaparsa, bakiye defterden hesaplanırsa
   **ikisi de kontrolden geçer** ve bakiye eksiye düşer. Kilitlenebilir tek satır bunu çözer
   (`WITH (UPDLOCK, ROWLOCK)` — `sp_GetNewNumbers`'ın kanıtlanmış kalıbı)

Kırılım: `DefinitionId + MarginType + Asset` — çünkü VM bakiyesi ile IM bakiyesi **ayrı paralar**.

⚠️ İki bakiye kavramı var: **para birimi bazında** bakiye (bu tablo) ve **base currency'de global
balance** (transcript 288-303). İkincisi bu satırların base ccy'ye çevrilmiş toplamı.

---

## 7. İlişkilerin mantığı — tek cümlede

> 🔑 **Kurallar yukarıdan aşağı akar ve kullanıldığı anda dondurulur.**

```Markdown
Annex ──kural──► Definition ──uygunluk──► Transaction ──┬─► Cash / Security    (ne hareket etti)
                                                        ├─► Revaluation        (hangi kurla)
                                                        ├─► Limit              (limit ne dedi)
                                                        ├─► PaymentInstruction (hangi hesaptan)
                                                        └─► Message → Event    (mesaj ne oldu)
                                      └──────────────► Position (bakiye)
```

Transaction, Definition ve Annex'in **kod'una değil `Id`'sine** bağlanıyor — yani **o günkü revizyona**.
Yarın sözleşme değişir, yeni revizyon açılır; dünkü işlem hâlâ dünkü kurallara bakar.

🔴 **Bu yüzden Annex ve Definition satırları hiç UPDATE edilmez — değişiklik = yeni satır.**

---

## 8. Uçtan uca örnek

```
1. Garanti ile CSA imzalandı
   Annex: AnnexCode='GRNT-CSA-01', RevisionNo=1, BaseCurrency=TRY, Direction=BOTH
   AnnexProductScope: Product=FX, SubProduct=Forward, MarginType=VM, IsIncluded=1
   AnnexMarginRule: Party=COUNTERPARTY, Threshold=2.000.000, MTA=200.000,
                    Rounding=10.000 / NEAREST

2. "Garanti'den EUR nakit kabul ederim"
   CollateralDefinition: Code='GRNT-CASH', Type=CASH, ValuationCurrency=TRY, AnnexId=<1>
   CollateralEligibleCurrency: EUR, FxAdjustmentRate=0,02
   CollateralSettlementMap: INCREASE → nostro hesabı + SSI

3. Bugün piyasa oynadı, Garanti 1M EUR yatıracak
   TxnTransaction:        Type=INCREASE, MarginType=VM, DefinitionId=<2>, AnnexId=<1>
   TxnTransactionCash:    Amount=1.000.000 EUR, FxRate=49,82
                          TransactionValue      = 49.820.000 TRY
                          AdjustedEligibleValue = 48.823.600 TRY   (%2 FX adjustment düşülmüş)
   CollateralRevaluation: kur 49,82 donduruldu (ENTRY + VERIFY)
   TxnCollateralLimit:    limit servisi "AVAILABLE, blocking=false" dedi, donduruldu
   PaymentInstruction:    TheySend=Garanti hesabı, WeReceive=bizim nostro
   Message:               pacs.009 üretildi
   MessageEvent:          GENERATED → SENT → ACCEPTED → SETTLED
   Position:              (Definition, VM, EUR) bakiyesi 1.000.000 arttı
```

---

## 9. `ProductDefinition` ≠ `CollateralDefinition` — karıştırma

|           | `CollateralDefinition` (dokümandan)                | `ProductDefinition` (platform tablosu)                                                  |
| --------- | ----------------------------------------------------- | ----------------------------------------------------------------------------------------- |
| Ne        | Kullanıcının ekrandan girdiği**iş verisi** | Modülün**kendi ürün çeşitlerinin konfigürasyonu**                            |
| Örnek    | *"Garanti'den TRY ve EUR nakit kabul ederim"*       | MM'de 11 satır (MoneyMarket, Loan, Tawarruq…), DerivSwp'de 2 (IRS, CCS), OptionsFX'te 1 |
| Kim girer | İş kullanıcısı, her gün/hafta                   | Kurulum script'i, bir kez                                                                 |
| İçerik  | uygunluk kuralları                                   | `AccountingMapCode`, `ExternalMainProductCode`, `PortfolioRootPath`, `IsEnabled`  |

🔑 **`ProductDefinition` neden gerekli:** modülün platformda tanındığı **4 yerden biri** burası —
`ExternalMainProductCode='CL'`, portföy kök yolu ve muhasebe map kodu orada yaşıyor. OptionsFX'in tek
satırı bile var, çünkü entegrasyon oraya asılı.

⚠️ Annex'teki `ProductCode`/`SubProductCode` ise **başka modüllerin ürünlerini** gösteriyor
(*"bu annex FX forward işlemlerimi kapsıyor"*) — Collateral'ın kendi `ProductDefinition`'ına değil,
ortak ürün kataloğuna bakıyor. **Bu nokta hâlâ netleşmedi** (bkz `07-kararlar-ve-sorular.md` A-05).

---

## 10. `MarginType = ALL` — neden enum'a eklenmemeli

Annex'te her Product+SubProduct satırı için *"bu annex hangi teminat çağrısı türünü kapsıyor"*
seçiliyor. Transcript'te *"All seçersen hepsini kullanabilirim"* deniyor (164).

🔴 **`ALL` enum'a konursa**, *"VM kapsamda mı?"* diye soran her sorgu
`MarginType='VM' OR MarginType='ALL'` yazmak zorunda kalır — ve bu bir yerde unutulur, **sessizce
yanlış sonuç** verir.

✅ **Doğrusu:** UI *"All"* seçilince **4 satır yazar**. Depolama ucuz, sorgu temiz kalır.
Dokümanın kendi `IsIncluded` mantığı da aynı felsefede.

---

## 11. Limit servisi nedir

Transaction ekranında **karşı tarafın kredi limitini salt-okunur gösteren** bölüm (doküman §6.3).
Platformda altyapı zaten var: `LimitApi` config key'i, `IClientLimitApi` Refit marker'ı, MM Micro
UI'sinde `LimitCheck` bileşeni.

Verify anında limit servisine soruluyor, dönen cevap: ülke limiti · toplam limit · kullanılmış · kalan ·
kullanım oranı · bu işlemin risk tutarı · **karar kodu** · **blocking flag**.

🔑 Teminat alması her kurumda limiti tüketmez — **risk tutarını ve blokaj kararını ekran varsaymaz**,
servisin cevabı esastır.

⚠️ `repos/.ai-agent/PROJECT_CONTEXT.md` §9: *"Limit modülünün backend reposu tespit edilmedi —
`LimitApi` config key'i var ama repo yok."* Bu bankada kurulu mu, faz-1'de bağlanacak mı — **açık soru**
(`07-kararlar-ve-sorular.md` A-13).
