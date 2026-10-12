# 02-ciktilar.md — manuel-reeskont-kodlama

Ham çıktılar. Numaralar `01-sorgular.md` ile eşleşir.

---

## #1

```
name
----
NetTrexCommon
NetTrexCommon_132
NetTrexCommon_132_Dev
NetTrexCommon_132_Dev_Deneme
NetTrexCommon_132_Emre
NetTrexCommon_133
NetTrexCommon_133_Dev
NetTrexCommon_134
NetTrexCommon_134_Dev
NetTrexCommon_135
NetTrexCommon_135_Dev
NetTrexCommon_20260810
NetTrexCommon_AI
NetTrexCommon_Auto
NetTrexCommon_Aytemiz
NetTrexCommon_DbTest
NetTrexCommon_Demo
NetTrexCommon_Destek
NetTrexCommon_Dev
NetTrexCommon_Dev_Flow
```
(20 satır — `TOP(20)` limiti dolmuş olabilir, tam liste değil.)

---

## #2

```
Id|Description|MenuKey|IsActive|ParentId
--|-----------|-------|--------|--------
(0 rows)
```

---

## #3

```
ModuleName|Adet
----------|----
GENERAL|262
Accounting|14
DERIV|4
OptionsFX|2
```

---

## #4

```
Id|Description|MenuKey|ModuleName|ParentId|IsActive
--|-----------|-------|----------|--------|--------
129|Reconciliation|ReconciliationKey|GENERAL|999|1
276|Manuel Revaluation|ManuelRevaluation|GENERAL|129|1
339|Security Manuel Revaluation|SecurityManuelReescontKey|GENERAL|129|1
1548|Fund Commission Definition|CommissionDefinitionKey|GENERAL|358|1
1551|Commission Monitoring|TreasuryManagementKey|GENERAL|1507|1
```

---

## #5

```
Id|Description|MenuKey|ModuleName|IsActive|ParentId|ItemOrderId|ForcedPermission
--|-----------|-------|----------|--------|--------|-----------|----------------
2551|Manuel Reeskont - Hazine|TreasuryReeskontKey|General|1|129|66|NULL
2552|Manuel Reeskont - Menkul Kiymet|SecurityReeskontKey|General|1|129|67|NULL
2553|Manuel Reeskont - Yatirim|InvestmentReeskontKey|General|1|129|68|NULL
```

---

## #6

```
Id|TranslationYatirimEN|TranslationYatirimTR|TranslationKatilimEN|TranslationKatilimTR
--|--------------------|--------------------|--------------------|--------------------
2551|NULL|NULL|NULL|NULL
2552|NULL|NULL|NULL|NULL
2553|NULL|NULL|NULL|NULL
```

---

## #7

```
Id|Description|TranslationYatirimEN|TranslationYatirimTR|TranslationKatilimEN|TranslationKatilimTR
--|-----------|--------------------|--------------------|--------------------|--------------------
276|Manuel Revaluation|Manuel Revaluation|Manuel Revaluation|Manuel Revaluation|Manuel Revaluation
339|Security Manuel Revaluation|Security Manuel Revaluation|Security Manuel Revaluation|Security Manuel Revaluation|Security Manuel Revaluation
1548|Fund Commission Definition|Fund Commission Definition|Fund Commission Definition|Fund Commission Definition|Fund Commission Definition
1551|Commission Monitoring|Commission Monitoring|Komisyon Izleme|Commission Monitoring|Komisyon Izleme
```

---

## #8

```
name|type|is_nullable
----|----|-----------
Id|int|0
ApplicationName|nvarchar|0
Description|nvarchar|1
MenuKey|nvarchar|1
MenuType|nvarchar|1
Value|nvarchar|1
ForcedUrl|nvarchar|1
ForcedPermission|nvarchar|1
Icon|nvarchar|1
IsActive|bit|1
ItemOrderId|int|1
ParentId|int|1
StateDate|datetime|1
StateId|int|1
StateMaker|nvarchar|1
ModuleName|nvarchar|1
TranslationYatirimEN|nvarchar|1
TranslationYatirimTR|nvarchar|1
TranslationKatilimEN|nvarchar|1
TranslationKatilimTR|nvarchar|1
```

---

## Yorum / Bulgu

Kullanıcının "kolon boş mu bıraktım" şüphesi **kısmen doğru, ama şekli farklı**:

1. **`ModuleName` boş DEĞİL — yanlış case, AMA sonuçsuz.** `'General'` yazılmış, olması gereken
   `'GENERAL'` (282 aktif satırın TAMAMI `GENERAL`/`Accounting`/`DERIV`/`OptionsFX`). ⚠️ **Sonradan
   kod incelemesiyle REFÜTE edildi:** `GetModuleMenuHandler.cs:217-222` filtreyi
   `StringComparison.InvariantCultureIgnoreCase` ile yapıyor — case **hiç önemli değil**. Bu bir red herring.
2. **`Translation*` kolonları gerçekten NULL** — ama bu da tek başına menüden düşürmüyor (aşağıdaki #9'a
   bak: 13 aktif satırda zaten NULL, hepsi görünür durumda) — kozmetik, blocker değil.
3. **Asıl kök sebep (kod incelemesiyle doğrulandı):** `GetModuleMenuHandler.cs` menü listesini Redis'te
   kullanıcı bazlı cache'liyor (`ModuleMenu:{UserId}`, TTL 8 saat), `FrameworkMenu` INSERT/UPDATE tarafında
   bu cache'i temizleyen kod **yok**. Kullanıcı modülü daha önce açtıysa DB güncel olsa bile 8 saat eski
   liste görünür. Detay: `MEMORY.md` § Bilinen Tuzaklar (cross-repo), `progress-15.md`.
4. **DB karışıklığı da var ama ayrı konu:** `docker-compose.override.yml`'in işaret ettiği
   `NetTrexCommon_Dev`'de bu 3 satır hiç yok (#2) — ama bu, yerel docker-compose stack'i için geçerli,
   kullanıcının 191 cluster'ındaki gerçek Common API `NetTrexCommon` (plain) DB'sine bağlı olabilir.
   Doğrulanamadı (`kubectl` bu makineden cluster'a erişemiyor, context yok).

---

## #9

```
ToplamAktif|YatirimEN_Null|YatirimTR_Null|KatilimEN_Null|EN_TR_Ayni_YaniCeviriYok
-----------|--------------|--------------|--------------|------------------------
282|13|13|13|265
```

**Yorum:** Kullanıcının şüphesi doğru — bu genel bir teknik borç, yalnız Reeskont'a özgü değil.
282 aktif satırın **13'ü** (3 Reeskont dahil, 10'u önceden var) çeviri kolonlarını hiç doldurmamış (NULL).
**265'i (%94)** `TranslationYatirimEN = TranslationYatirimTR` — yani "İngilizce" kolonu gerçekte
Türkçe metnin kopyası, hiç çevrilmemiş. Gerçek EN/TR ayrımı yapılmış satır sayısı: 282-265=17.
Bu, `ModuleName`/cache bulgusundan **ayrı, önceden var olan** bir veri kalitesi sorunu — menünün
görünmemesiyle ilgisi yok (13 örnekten 10'u zaten bu haliyle aktif ve muhtemelen görünüyor), ama
kullanıcının "eksik ve Türkçe ve geride kalmış" tespiti DB genelinde doğrulandı.

---

## #10

```
NetTrexMM
NetTrexMM_132
NetTrexMM_132_Dev
NetTrexMM_133
NetTrexMM_133_Dev
NetTrexMM_134
NetTrexMM_134_Dev
NetTrexMM_134_SP
NetTrexMM_134_SS
NetTrexMM_134_ST
NetTrexMM_135
NetTrexMM_135_Dev
NetTrexMM_Auto
NetTrexMM_Aytemiz
NetTrexMM_DbTest
NetTrexMM_Demo
NetTrexMM_Destek
NetTrexMM_Dev
NetTrexMM_Dev_Flow
NetTrexMM_DunyaProd
```
Freshness kontrolü (MAX(StateDate) TxnMM): `NetTrexMM`=2026-08-12 · **`NetTrexMM_134`=2026-08-14 (en güncel)**
· `NetTrexMM_134_Dev`=2026-05-03 · `NetTrexMM_Dev`=2025-12-12 · `NetTrexMM_135`=2026-08-11.
**`NetTrexMM_134` seçildi** (en güncel/aktif görünen).

## #11 — tablo adları doğrulandı

`TxnMM`, `TxnMMDetail`, `AccEntryMain` (`dbo.`). FK: `AccEntryMain.TxnId` (bigint) — kolon adı
`TxnMmId` DEĞİL. `AccountingType.Opening=1`, `Revaluation=2`. `ProductAccountingCodeType.ISSUE=3`
(ilk denemede yanlışlıkla 6 yazılmıştı, düzeltildi). `StateId` dağılımı: `18` baskın (372/672) —
"Verified" karşılığı olarak kabul edildi (framework `States.InputVerified` NuGet'te, sayısal değeri
kaynaktan doğrulanamadı, DB'deki dominant değerle **ampirik** teyit edildi).

## #12 — Hangi tarihte eligible veri var (2026-08-01 → 2026-09-05 tarandı)

```
TestDate   |EligibleCount
2026-08-01 |2
2026-08-02 |2
2026-08-15 |1
2026-08-16 |1
2026-08-17 |1   <-- BUGÜN
2026-08-18..09-01 | 1 (aynı kayıt hâlâ vadesi dolmadığı için taşıyor)
```

## #13 — 2026-08-17 (bugün) için eligible satırın detayı

```
Id     |LogicalReference   |ValueDate |MaturityDate|TxnMmProductTypeId|StateId
553395 |TMMBRW2608140004   |2026-08-15|2026-09-02  |1 (MONEYMARKET)   |18
```

## #14 — 2026-08-01 için eligible satırlar

```
Id     |LogicalReference   |ValueDate |MaturityDate|TxnMmProductTypeId|StateId
553334 |TMMBRW2607300003   |2026-07-30|2026-08-03  |1 (MONEYMARKET)   |18
553336 |TMMBRW2607300006   |2026-07-30|2026-08-03  |1 (MONEYMARKET)   |18
```

## 🔑 Bulgu — asıl sebep DB'de değil, WebUI config'inde

**Tüm eligible test verisi `TxnMmProductTypeId = 1` (MoneyMarket)** — ama
`wwwroot/js/config/manual-rediscount/treasury.json`'daki MM `subProducts` listesi yalnızca
`Murabaha`/`Wakala` içeriyor, **`MoneyMarket` (ve `TermDeposit`) hiç yok**. UI SubProduct alanı
zorunlu ve ilk değeri otomatik seçiyor (`Murabaha`) — bu değer DB'deki hiçbir satırla eşleşmiyor,
bu yüzden hangi tarih seçilirse seçilsin **her zaman "Total 0 records"** görünüyor. Backend
(`EligibleTransactionsHandler.ResolveSubProductTypeId`) `"MONEYMARKET"`/`"TERMDEPOSIT"` string'lerini
**zaten doğru eşliyor** — eksik olan tek şey config dosyasındaki 2 seçenek. Kod değişikliği gerekmez,
`treasury.json` düzeltmesi yeterli.

---

## #15

```
name
----
ProductDefinitionId
RateTypeId
FloatingRateTypeId
LiquidationTypeId
PaymentInstructionTypeId
SettlementTypeId
```

## #16

```
ProductDefinitionId|Code|Name
-------------------|----|----
2|Loan|Interbank Loan
```

---

## #17 — 🔴 BAŞARISIZ: DB'ye bağlanılamadı

```text
Sqlcmd: Error: Microsoft ODBC Driver 17 for SQL Server : TCP Provider: The wait operation timed out.
Sqlcmd: Error: Microsoft ODBC Driver 17 for SQL Server : Login timeout expired.
Sqlcmd: Error: ... Server is not found or not accessible ...
```

Komut (parola maskeli):
```bash
sqlcmd -S "tcp:192.168.10.211,1433" -d NetTrexMM_134 -U trusr -P '***' -C -l 20 -W -s "|" -Q "..."
```

**Sonuç:** `192.168.10.211` şu anda erişilemiyor (daha önce bu oturumda #15/#16 çalışmıştı — ağ/VPN
durumu değişmiş olabilir). Id çakışma sorusu **DB'den doğrulanamadı**.

**Karar:** Çakışma olasılığı **varsayılarak** ilerlendi — `GetRevaluationByValueDateAsync`'e
`ProductCode` filtresi eklenmesi zaten *her koşulda* doğru olan davranış (AccEntryMain paylaşılan
tablo, ProductCode onun discriminator'ı). Çakışma olmasa bile filtre zararsız; olursa gerçek para
hatasını önlüyor. Yani doğrulama yapılamaması kararı değiştirmiyor.

---

## Tur 2026-08-18 (akşam) — Çıktılar

🔑 **DB bu turda ERİŞİLEBİLİR.** progress-26'daki #17 (`192.168.10.211` login timeout) artık geçerli değil;
o turda açık kalan doğrulamalar burada kapandı. DB: `NetTrexMM`.

### #18 — Revaluation fişleri (`Type = 2`), en yeni 20

```
Id     |TxnId  |ProductCode|TxnType|Type|IsReverse|ReverseId|ValueDate |StateMaker
555828 |553337 |MM         |BRW    |2   |1        |555827   |2026-08-19|PARTNER_NETIX_001@…
555827 |553337 |MM         |BRW    |2   |0        |555828   |2026-08-18|PARTNER.TREASY.004@…
555826 |553337 |MM         |BRW    |2   |1        |555825   |2026-08-19|PARTNER_NETIX_001@…
555825 |553337 |MM         |BRW    |2   |0        |555826   |2026-08-18|PARTNER.TREASY.004@…
555811 |553292 |MM         |BRW    |2   |0        |0        |2026-08-05|PARTNER.TREASY.002@…
555809 |553292 |MM         |BRW    |2   |1        |555801   |2026-08-04|SYSTEM
...
```

**Okunanlar:**
- ✅ **Ekranın kestiği fişler DB'de doğru duruyor.** `TxnId 553337` için **iki tam döngü**:
  `555825`(T+0 18.08) + `555826`(T+1 19.08), sonra `555827`(T+0 18.08) + `555828`(T+1 19.08).
  İkinci döngü **Regenerate**'in imzası: önceki çift kapalı (`ReverseId` dolu), üzerine yeni çift.
  Doküman § 4.3 (*"mevcut reeskont ve ters fiş kayıtları karşı kayıtları ile kapatılır, ardından
  yeni reeskont ve ters fiş"*) ile birebir.
- ✅ `ReverseId` **iki yönlü** bağlı (T+0 → T+1 ve T+1 → T+0). `DeriveStatus`'ün
  `ReverseId = 0 → NotReversed` kuralı DB'de karşılığını buluyor.
- ✅ **T-01 fix çalışıyor:** ters fişin `StateMaker`'ı `SYSTEM` **değil**, gerçek kullanıcı
  (`PARTNER_NETIX_001@…`). Batch'in kestikleri hâlâ `SYSTEM` — doğru, batch zaten sistem.
- 🟡 **T+0'ın `StateMaker`'ı ekranı kullanan kişi DEĞİL** → bkz. #28.

### #20 — T+0 / T+1 çifti: valör farkı + hafta günü

```
T0Id  |T0Value   |T1Id  |T1Value   |DayDiff|T1Weekday|TxnId |StateMaker
555827|2026-08-18|555828|2026-08-19|1      |Wednesday|553337|PARTNER_NETIX_001@…
555825|2026-08-18|555826|2026-08-19|1      |Wednesday|553337|PARTNER_NETIX_001@…
555801|2026-07-31|555809|2026-08-04|4      |Tuesday  |553292|SYSTEM
555798|2026-07-31|555800|2026-07-31|0      |Friday   |553306|SYSTEM
555797|2026-07-31|555799|2026-07-31|0      |Friday   |553283|SYSTEM
555774|2026-07-25|555775|2026-07-27|2      |Monday   |553292|SYSTEM
555770|2026-07-24|555772|2026-07-25|1      |Saturday |553292|SYSTEM   ← 🔴
555769|2026-07-24|555771|2026-07-25|1      |Saturday |553275|SYSTEM   ← 🔴
```

**Okunanlar:**
- 🔴 **CUMARTESİ valörlü ters fiş var** (`555772`, `555771`): 2026-07-24 **Cuma** + 1 gün = Cumartesi.
  Doküman § 4.2 *"Execution Date + 1 **iş günü**"* diyor. Bu satırlar **batch** üretimi
  (`StateMaker = SYSTEM`), bizim ekran değil — yani düz `AddDays(1)` davranışı **mevcut sistemde de var**.
- ✅ `DayDiff = 0` (**aynı gün** ters fiş) satırları **canlıda mevcut** (`555798→555800`, `555797→555799`).
  Bu, eski validator kuralımın (`ReverseValueDate > ExecutionDate`, gerekçe: *"aynı gün ters fiş
  muhasebeyi anlamsız kılar"*) **yanlış olduğunu kanıtlıyor** — canlı veri T+0 tersini üretiyor.
  Kural `>=`'e çevrildi (doküman § 8.2 T+0'ı açıkça sunuyor).
- `DayDiff` dağılımı 0/1/2/4 → batch'te takvim mantığı **kısmen** var, tutarlı değil.

### #22 — Ters fişlerin hafta günü dağılımı (ölçek)

```
Weekday  |Cnt
Sunday   |645   ← 🔴
Tuesday  |255
Monday   |235
Wednesday|232
Thursday |222
Saturday |208   ← 🔴
Friday   |186
```

🔴 **1983 ters fişin 853'ü (%43) hafta sonu valörlü** — Pazar en kalabalık kova.
Bu, `AddDays(1)` davranışının **canlı ölçekteki izi**. Bizim yeni kodumuz artık
`ICalendarHelper.NextWorkingDayAsync` kullanıyor; **batch hâlâ eski yolda**.

### #21 — `AccEntryMain.ProductCode` dağılımı

```
ProductCode|Cnt |MinTxnId|MaxTxnId
MM         |4676|551011  |1201167
TWR        |46  |501002  |501028
Loan       |20  |552940  |553162
```

### #23 — Aynı `TxnId` iki farklı `ProductCode` altında mı

**BOŞ** → hiçbir `TxnId`'nin iki ürün koduna ait fişi yok.

### #24 — `ProductCode='MM'` ama `TxnId ≥ 1201069` (TxnLoan uzayı)

13 satır. Örnek: `555481`(Type=2, T+0) + `555482`(Type=2, IsReverse=1) → `TxnId 1201155`, `ProductCode='MM'`.

### #25 — Id aralıkları 🔑 (progress-26'da erişilemeyen doğrulama)

```
Tbl    |MinId  |MaxId  |Cnt
TxnMM  |551002 |553337 |631
TxnLoan|1201069|1201167|95
```

### #26 — Aynı Id iki tabloda birlikte var mı

**BOŞ** → ✅ **örtüşme YOK.**

### #27 — `ProductCode='Loan'` fişleri hangi tabloya ait

20/20 satırın hepsi: `InTxnMM = 1`, `InTxnLoan = 0`.

### #28 — T+0'ın `StateMaker`'ı

```
Id    |LogicalReference|StateMaker                          |StateDate
553337|TMMBRW2608180001|PARTNER.TREASY.004@INVESTMENTBANK.COM|2026-08-18 13:56:16
```

---

## 🔴 Bu turun ana DB bulguları

1. **Id örtüşmesi YOK — risk latent (doğrulandı).** `TxnMM` 551.002–553.337 · `TxnLoan`
   1.201.069–1.201.167, kesişim **boş** (#25, #26). progress-26'daki "latent" değerlendirmesi
   **artık ölçülmüş bilgi**; o turdaki açık kalem **kapandı**.

2. 🔴 **`ProductCode` TABLOYU GÖSTERMİYOR — bu, progress-26'daki varsayımımı düzeltiyor.**
   `ProductCode` `PrdProductDefinition.MainProductCode`'dan geliyor, yani bir **ürün** sınıflandırması;
   hangi tabloya (TxnMM/TxnLoan) ait olduğunu **söylemiyor**:
   - `ProductCode='Loan'` fişlerinin **tamamı TxnMM**'e ait (#27)
   - `ProductCode='MM'` fişlerinin bir kısmı **TxnLoan**'a ait (#24)
   **Sonuç:** eklediğim filtre (`x.Transaction.Product.MainProductCode == x.ProductCode`) fişin
   ProductCode'unu **kendi join'lendiği transaction'ın** ürün koduyla karşılaştırdığı için
   **tutarlıdır ve zarar vermez**, ama **tabloları ayırt eden şey o değil** — ayrımı yapan asıl şey
   navigation join'inin kendisi (Id aralıkları ayrık olduğu için yanlış tabloya join **tutmuyor**).
   Aralıklar bir gün örtüşürse `ProductCode` **tiebreaker olarak yetmez** (iki transaction'ın
   `MainProductCode`'u aynı olabilir). Gerçek çözüm bir **discriminator kolonu**dur — ayrı iş.

3. 🔴 **Hafta sonu valörlü ters fiş, canlıda %43** (#22). Bizim kod artık takvim kullanıyor;
   **batch düzeltilmedi** (kapsam dışı, ayrı iş).

4. 🟡 **Audit boşluğu (doküman C-19):** T+0 fişinin `StateMaker`'ı **transaction'ın maker'ı**
   (`PARTNER.TREASY.004`, #28 ile doğrulandı), ekranda Generate'e basan kişi **değil**
   (o kişi yalnız T+1'de görünüyor: `PARTNER_NETIX_001`). Yani "bu reeskontu kim manuel tetikledi"
   bilgisi **yarım** kayıtlı. Muhasebe kaydının sahipliğini değiştirmek onay gerektirir — **yapılmadı**.

---

## Tur 2026-08-18 (gece) — Ekran testi + 🔴 SESSİZ SATIR KAYBI bulundu

### #29 — Ekranda `Not Reversed` görünecek satırlar hangi tarihte

```
Id    |TxnId |ValueDate |ReverseId|LogicalReference
555811|553292|2026-08-05|0        |TMMBRW2607140004
555810|553292|2026-08-04|0        |TMMBRW2607140004
555808|553217|2026-06-04|0        |TMMBRW2606040004
555807|553216|2026-06-04|0        |TMMBRW2606040003
555806|553215|2026-06-04|0        |TMMBRW2606040002
555805|553214|2026-06-04|0        |TMMBRW2606040001
555631|553266|2026-07-11|0        |TMMPLC2607020011
```

Kullanıcı `18.08.2026` ile test ediyordu; o tarihte `Not Reversed` satır **yok** → ters fiş valörü
popup'ı doğru davranıp hiç açılmadı (doküman § 8.2: *"Diğer durumlarda seçim sorulmaz"*).

### #30 — Kaybolan satırın `TxnTypeCode`'u `defTxnType`'ta var mı

```
Id    |LogicalReference|TxnTypeCode|StateId|TxnTypeExists
553311|TMMBRW2608055001|BRW        |18     |1
553306|TMMBRW2607240005|BRW        |18     |1
553292|TMMBRW2607140004|BRW        |18     |1   ← kaybolan satır
553283|TMMBRW2607060003|BRW        |18     |1
```

Dördü de sağlam → ilk hipotezim (`Direction` INNER JOIN'i) **çürüdü**.

### #31 — Required FK'lar dolu mu

```
Id    |CustomerId|BasisCode|TxnMmProductTypeId|MarketCode|Ccy|TermId
553311|2107      |1        |1                 |TCMB      |TRY|1
553306|2107      |2        |1                 |TAKAS     |USD|1
553292|1086      |1        |1                 |OTC       |TRY|1   ← CustomerId FARKLI
553283|2107      |2        |1                 |TAKAS     |USD|1
```

Hepsi dolu; tek gözle görülür fark kaybolan satırın `CustomerId`'si.

### #32 — 🔴 KÖK SEBEP: `CustomerId = 1086` `cusCustomer`'da YOK

```
Id    |CustomerId|CustOk|BasisCode|BasisOk
553311|2107      |1     |1        |1
553306|2107      |1     |2        |1
553292|1086      |0     |1        |1   ← 🔴 MÜŞTERİ KAYDI YOK
553283|2107      |1     |2        |1
```

⚠️ Bu sorgu iki kez `Invalid column name` ile başarısız oldu (ikisi de benim hatam, denetim gereği
kayıtta): (1) `defDateBasis.Id` — anahtar `BasisCode`; (2) `cusCustomer.CustomerId` — anahtar `Id`.
Doğru hâli yukarıdaki.

### #33 — `cusCustomer` kolonları (anahtar adı doğrulaması)

`Id (int)` · `ShortName` · `Name` · `Ccy` · `BranchId` · `SIC` · `BusinessSegmentCode` ·
`CustomerRoleFlags` · `ActiveFromDate` · `ActiveToDate` · `Language` · `Attention` …

---

## 🔴 Bu turun ana bulgusu — özet şeridi ile grid ayrışıyordu

**Belirti (API ile ölçüldü, tarayıcı gerekmedi):**
`POST /api/manual-rediscount/eligible-transactions`, `ExecutionDate = 2026-08-05`,
`SubProduct = MoneyMarket`:

| Filtre | `totalCount` | `len(items)` | `statusSummary` |
|---|---|---|---|
| `Status = null` (All) | 4 | **3** | `{total:4, notRediscounted:3, notReversed:1, rediscounted:0}` |
| `Status = 3` (NotReversed) | 1 | **0** | `{total:1, notReversed:1}` |

**Sebep:** `TransactionDataManager.GetRediscountEligibleTransactionsAsync` içinde sayım ve satır
listesi **aynı** `IQueryable`'dan türüyor, ama satır projeksiyonu required navigation'ları
dereference ediyor:
- `p.Entity.Customer != null ? … : null` → `Customer` **`IsRequired()`** (`TxnMmEntityConfiguration.cs:95-98`)
- `p.Entity.Direction.Name` → `Direction` **`IsRequired()`** (`:110-113`), guard bile yok

EF Core required navigation için **INNER JOIN** üretiyor ve `!= null` guard'ını **sadeleştirip atıyor**.
Orphan FK'da (`CustomerId = 1086`) satır **sessizce düşüyor**; `CountAsync` o join'i hiç yapmadığı
için saymaya devam ediyor.

**Kullanıcıya etkisi:** özet "1 Not Reversed" diyor, grid'de satır yok → kullanıcı o satıra
**hiç ulaşamıyor**, ters fiş valörü sorusu tetiklenemiyor, reeskont kesilemiyor.
Hata mesajı da yok — **sessiz** kayıp.

**Fix:** müşteri ve işlem türü alanları **skaler subquery** ile okunuyor (join üretmiyor → satır
düşmüyor, alan boş kalıyor). MM ve IL data manager'larında uygulandı.
⚠️ `Product` (FK `TxnMmProductTypeId`) ve `Basis` (FK `BasisCode`) de `IsRequired()` ve hâlâ
navigation üzerinden okunuyor — bugün orphan yok (`BasisOk = 1`), tuzak **latent** olarak duruyor.


---

## Tur 2026-08-24

### #34 — BASARISIZ

```text
Msg 207, Level 16, State 1, Server srv-mssql, Line 1
Invalid column name 'ModuleCode'.
Msg 207, Level 16, State 1, Server srv-mssql, Line 1
Invalid column name 'IsActive'.
```

Kolon adi varsayimi yanlis (`ModuleCode`, `IsActive` yok). Sema #35 ile dogrulanacak.


### #35 — BASARILI (sema)

```text
Id|int · Code|nvarchar · Name|nvarchar · AccountingMapCode|nvarchar · MainProductCode|nvarchar
ExternalMainProductCode|nvarchar · UseFundSource|bit · UseSubFundSource|bit · UseOnUnitValue|bit
IsBorrowing|bit · IsPlacement|bit · IsAccountNeeded|bit · IsAllowRollover|bit · IsAllowBrokerage|bit
IsMultiplePayment|bit · IsTaxApplicable|bit · IsUseTxnGLCode|bit · IsCollateralized|bit
IsIntraBank|bit · IsSameDay|bit · IsZeroRate|bit · IsGenerateFWDAccounting|bit
IsDefaultProduction|bit · AccountSelectionTypeId|int · AccountingCalculationMethodTypeId|int
Order|int · IsEnabled|bit · StateId|int · StateMaker|nvarchar · StateDate|datetime
ExternalSubProductCode|nvarchar · LogicalReferenceTypeId|int · IsMarketCommissionApplicable|bit
IsAllowTawarruq|bit
```

🔑 **Bulgu:** `ModuleCode` YOK. Modul ayrimi **`MainProductCode`** ile yapiliyor.
Aktiflik kolonu **`IsEnabled`** (`IsActive` degil).


### #36 — BASARILI (11 satir, TAMAMI)

```text
Id|Code           |Name           |MainProductCode|IsEnabled|StateId|Order
 1|MoneyMarket    |Money Market   |MM             |1        |26     |5
 2|Loan           |Interbank Loan |MM             |1        |26     |10
 3|Issue          |Bond Issue     |MM             |1        |18     |15
 4|Wakale         |Wakale         |MM             |1        |26     |20
 5|Murabaha       |Murabaha       |MM             |1        |26     |25
 6|TermDeposit    |Term Deposit   |MM             |0        |18     |30
 7|Pass           |Pas            |MM             |1        |18     |30
 8|Gil            |Gil            |MM             |1        |18     |35
 9|Syndication    |Syndication    |MM             |1        |18     |40
10|Securitization |Securitization |MM             |1        |18     |45
11|Post-Financing |Post-Financing |MM             |1        |18     |55
```

🔴 **BULGULAR**

1. **`Pas` = `Code 'Pass'`** (cift `s`!), **`Gil` = `Code 'Gil'`**. Kullanicinin *"hard olarak
   Pass ve Gil yazip listeden cikarabilirsin"* dedigi kayitlar bunlar. `Name` degerleri `Pas`/`Gil`,
   `Code` degerleri `Pass`/`Gil` — filtre **`Code`** uzerinden yazilmali (`Name` ile yazilirsa
   `Pas` != `Pass` tuzagi olur).
2. 🔴 **`MainProductCode` HEPSINDE `MM`.** Yani "MM Transactions" ile "InterbankLoan
   Transactions" ayrimi bu kolonda **YOK**. Ayrim urun tanimi seviyesinde: `Loan` (Id 2) =
   InterbankLoan urunu, digerleri TxnMM tarafi.
3. `TermDeposit` (Id 6) **`IsEnabled = 0`** — listeye zaten girmemeli.
4. `ModuleCode` kolonu **yok**; `EligibleTransactionsHandler.ResolveSubProductTypeIdAsync`'in
   `GetSubProductIdByCodeAsync(ExpectedModuleCode, code)` cagrisi `MainProductCode`'a bakiyor olmali.
5. Tabloda toplam **11 satir** (TOP 50 sinirina yaklasilmadi) — liste tamami goruldu, tekrar
   sorgu gerekmiyor.

## Tur 2026-08-26 — MM / InterbankLoan tablo izolasyonu

DB: `NetTrexMM` · sunucu erisilebilir. Komut sablonu (parola maskeli):
`sqlcmd -S "tcp:192.168.10.211,1433" -d NetTrexMM -U trusr -P '***' -C -l 20 -W -s "|" -Q "..."`

### #37 — BASARILI

```text
Tbl    |MinId  |MaxId  |Cnt
TxnMM  |551002 |553350 |640
TxnLoan|1201069|1201167|95
```

🔑 Araliklar **AYRIK**. TxnMM 551002-553350, TxnLoan 1201069-1201167. Arada ~648.000
bosluk var.

### #38 — BASARILI

```text
KesisenIdSayisi
0
```

🔑 **Fiili cakisma YOK.** Iki tabloda ayni Id'ye sahip tek satir bile yok.

### #39 — BASARILI

```text
ProductCode|Cnt
MM         |4774
TWR        |46
Loan       |20
```

⚠ Beklenmedik: fis tarafinda **uc** deger var, oysa `#36` urun **tanimi** tablosunda
`MainProductCode` hepsinde `'MM'`. Yani `accEntryMain.ProductCode` her zaman
`MainProductCode`'dan gelmiyor.

### #40 — CALISTIRILMADI

#38 sifir dondugu icin "cakisan Id'nin fisleri karisiyor mu" sorusu **anlamsizlasti**
(cakisan Id yok). Sorgu kurulmus ama kosulmadi.

### #41 — BASARILI (20 satir)

```text
Id    |TxnId |ProductCode|TxnTypeCode|Type|IsReverse|ReverseId|ValueDate
554576|553159|Loan       |BRW        |1   |0        |0        |2026-03-10
554575|553160|Loan       |BRW        |1   |0        |0        |2026-03-10
554574|553162|Loan       |BRW        |1   |0        |0        |2026-03-10
554573|553161|Loan       |BRW        |1   |1        |554572   |2026-03-10
554572|553161|Loan       |BRW        |1   |0        |554573   |2026-03-10
... (Id 554279'a kadar, hepsi Type=1, TxnId 552940-553162 araliginda)
```

🔑 `ProductCode='Loan'` fislerinin TxnId'leri **TxnMM araliginda** (551002-553350),
TxnLoan araliginda **degil**. Ve **hepsi `Type=1` (Opening)** — reeskont (`Type=2`) yok.

### #42 — BASARILI — 🔑 BU TURUN BELIRLEYICI SORGUSU

```text
ProductCode|Type|Cnt
MM         |2   |363
MM         |1   |51
MM         |4   |4
```

🔑 **TxnLoan islemlerinin fislerinin TAMAMI `ProductCode='MM'`.** Yani Loan tarafinin
fisleri de `'MM'` ile yaziliyor — `ProductDefinition.MainProductCode` (`#36`: `'MM'`) ile
tutarli. Korktugum "Loan ucu kendi fislerini goremiyor" senaryosu **YOK**.

### #43 — BASARISIZ (sozdizimi)

```text
Msg 130, Level 15, State 1, Server srv-mssql, Line 1
Cannot perform an aggregate function on an expression containing an aggregate or a subquery.
```

`SUM(CASE WHEN EXISTS(...))` T-SQL'de gecersiz. `#44` olarak LEFT JOIN ile yeniden yazildi.

### #44 — BASARILI

```text
ProductCode|Type|Cnt|TxnMMde|TxnLoanda
Loan       |1   |20 |20     |0
TWR        |1   |46 |0      |0
```

🔴 Iki bulgu:
1. `Loan` kodlu 20 acilis fisinin **tamami TxnMM**'de — TxnLoan'da hicbiri yok.
2. `TWR` (Tawarruq) kodlu 46 acilis fisinin TxnId'si **NE TxnMM'de NE TxnLoan'da** —
   yani **oksuz FK**. (`MEMORY.md`'deki required-navigation tuzaginin canli ornegi.)

### #45 — BASARILI

```text
TableName|ColName|is_identity|seed_value|increment_value|last_value
TxnLoan  |Id     |0          |NULL      |NULL           |NULL
TxnMM    |Id     |0          |NULL      |NULL           |NULL
```

🔴 **Iki kolon da IDENTITY DEGIL.** Id'yi veritabani uretmiyor.

### #46 — BASARILI

```text
TxnMmProductTypeId|Code       |Name          |Cnt
1                 |MoneyMarket|Money Market  |428
5                 |Murabaha   |Murabaha      |95
3                 |Issue      |Bond Issue    |53
4                 |Wakale     |Wakale        |50
2                 |Loan       |Interbank Loan|12
8                 |Gil        |Gil           |1
7                 |Pass       |Pas           |1
```

🔴 `TxnMM` tablosunda **12 satir** `TxnMmProductTypeId = 2` (**Interbank Loan**) urunlu.
Yani "Interbank Loan" urunu **iki tabloda da** var: TxnMM'de 12, TxnLoan'da 95.

### #47 — BASARILI (12 satir)

```text
Id    |TxnMmProductTypeId|AcilisMM|AcilisLoan|ReeskontFisi
553293|2                 |0       |0         |0
553191|2                 |0       |0         |0
553155|2                 |0       |0         |0
552942|2                 |1       |0         |2
552870|2                 |1       |0         |0
552869|2                 |1       |0         |0
552868|2                 |1       |0         |0
552867|2                 |1       |0         |0
552866|2                 |1       |0         |1
552498|2                 |1       |0         |2
551966|2                 |1       |0         |4
551067|2                 |0       |0         |0
```

🔑 O 12 satirin **hicbirinde** `'Loan'` kodlu acilis yok; 8'inde normal `'MM'` acilis var
(4'unde hic acilis yok — uygunluk sarti onlari zaten disliyor, dogru davranis).
Yani bu satirlar Manuel Reeskont **MM** listesinde gorunuyor ve reeskont da kesilmis
(`ReeskontFisi` 1/2/4). Kor nokta **bu satirlarda degil**.

### #48a — BASARILI (bos)

```text
name|start_value|increment|current_value
(satir yok)
```

Veritabaninda **hic `SEQUENCE` yok**.

### #48b — BASARILI

```text
TriggerName    |TableName|is_disabled
TxnLoanTrigger |TxnLoan  |0
TxnMMTrigger   |TxnMM    |0
```

### #49 — BASARILI (govde kirpildi, `LEFT(...,2000)`)

```text
TxnLoanTrigger : CREATE TRIGGER [dbo].[TxnLoanTrigger] ON dbo.Txn... (yorum: "Trigger'i yeni
                 kolonlar sona eklenmis sekilde yeniden olustur")
TxnMMTrigger   : CREATE TRIGGER [dbo].[TxnMMTrigger] ON [dbo].[TxnMM] FOR INSERT, UPDATE
                 AS BEGIN SET NOCOUNT ON; INSERT INTO [dbo].[TxnMMHistory] (...)
```

🔑 Iki trigger da **HISTORY/AUDIT** trigger'i — `*History` tablosuna kopyaliyor.
**Id uretmiyorlar.** Dolayisiyla Id'yi **uygulama** atiyor.
⚠ Uygulamada Id'nin nerede atandigi **tespit edilemedi** (kodda `sequence`/`numerator`/
`GetNextId` deseni bulunamadi).

### #50 — BASARILI

```text
LoanAcilisliTxn|AyricaMMAcilisiVar|ReeskontFisiVar
19             |0                 |0
```

🔑 `'Loan'` kodlu acilis fisi olan **19** islemin:
- **hicbirinde** ayrica `'MM'` kodlu acilis **yok**
- **hicbirinde** reeskont fisi (`Type=2`) **yok**

Yani bu 19 islem Manuel Reeskont MM uygunluk sartini (`acilis fisi ProductCode='MM'`)
saglamiyor → ekranda **gorunmuyor**. Ama EOD batch'i de ayni filtreyi kullandigi icin
onlari da hic degerlememis (`ReeskontFisiVar = 0`) → **ekran batch ile TUTARLI**,
Manuel Reeskont'un urettigi bir sapma degil. Veri sorusu olarak kullaniciya bildirilecek.

---

## 🔑 Bu turun sonucu — kullanicinin sorusuna cevap

**Soru:** *"Select ve execute islemlerinde MM ve InterbankLoan yine ayri gidiyor degil mi,
yanlislikla birbirinin tablolarina bakip islem yapmiyorlar?"*

**Cevap: Hayir, birbirinin tablolarina bakmiyorlar — ama guvence sanildigi yerden gelmiyor.**

| Katman | Ayrim gercekten neyle saglaniyor |
|---|---|
| Handler dispatch | `ResolveProductSourceType(request.Product)` → `MoneyMarket` / `InterbankLoan`. Temiz, tek karar noktasi |
| Select (liste) | Ayri data manager, ayri repository (`TxnMmEntity` / `TxnLoanEntity`). Tablo secimi **derleme zamaninda** sabit |
| Execute | `GetRevaluationByValueDateAsync(..., sourceType)` → EXISTS ile ilgili tabloyu dogruluyor |
| Ters fis / reeskont servisi | `sourceType == InterbankLoan ? loanRevaluationAccountingService : revaluationAccountingService` |

🔴 **Ama `ProductCode` ayrimi ETKISIZ.** Kodda ayrim
`a.ProductCode == x.Product.MainProductCode` (MM) / `== x.ProductDefinition.MainProductCode`
(Loan) ile yapiliyor; `#36` + `#42` gosterdi ki **ikisi de `'MM'`**. Yani o filtre MM ile
Loan'i **ayirmiyor** — sadece `'Loan'`/`'TWR'` kodlu eski/oksuz fisleri disliyor.

🔴 **Gercek koruma `accEntryMain.TxnId`'nin ayrikligi**, ve o **yapisal garanti degil**:
- `accEntryMain.TxnId` **ayni kolon** iki tabloya FK
  (`AccEntryMainConfiguration.cs:69-77`) — join'de discriminator yok
- `TxnMM.Id` / `TxnLoan.Id` **IDENTITY degil** (`#45`), **sequence yok** (`#48a`),
  trigger'lar **Id uretmiyor** (`#49`) → Id'yi uygulama atiyor
- Bugun kesisim **0** (`#38`) ve araliklar ~648.000 uzak (`#37`)

→ Yani cakisma **bugun yok**, ama bunu garanti eden bir kisit (UNIQUE, CHECK, ayri
sequence) **tespit edilmedi**. TxnMM 1201069'a ulasirsa cakisma baslar.

## Tur 2026-08-26 (2) — `AccEntryEntity` EF tracking hatasi

DB: `NetTrexMM` · komut sablonu (parola maskeli):
`sqlcmd -S "tcp:192.168.10.211,1433" -d NetTrexMM -U trusr -P '***' -C -l 20 -W -s "|" -Q "..."`

### #51 — BASARILI · 🔑 HIPOTEZI CURUTTU

```sql
CREATE PROCEDURE [dbo].[sp_GetNewNumbers] @EntityColumnType int, @CountToGenerate int
AS
BEGIN
    SET NOCOUNT ON;
    ... parametre kontrolu ...
    DECLARE @new_last_no int;

    UPDATE dbo.defNumberGen WITH (ROWLOCK, UPDLOCK)
    SET @new_last_no   = LastNumber = LastNumber + @CountToGenerate,
        LastUpdateDate = GETDATE()
    WHERE EntityColumnType = @EntityColumnType;

    IF @@ROWCOUNT = 0 ... RAISERROR ...

    DECLARE @start_no int = @new_last_no - @CountToGenerate + 1;
    WITH NumberSequence AS (SELECT @start_no ... UNION ALL ... )
    SELECT GeneratedNumber FROM NumberSequence OPTION (MAXRECURSION 0);
END
```

🔑 **Sayac MONOTON.** `UPDATE ... WITH (ROWLOCK, UPDLOCK)` + tek ifadede
`SET @degisken = Kolon = Kolon + @count` deseni; ayni satirda kilit alindigi icin es zamanli
cagrilar bile **ayni numarayi alamaz**. Yani *"SP mukerrer Id dagitiyor"* hipotezi **CURUK**.
⚠ Tek kalan kirilganlik: `UPDATE` ambient transaction'in icinde — transaction **rollback**
olursa sayac da geri sarar ve ayni numaralar tekrar dagitilir.

### #52 — CALISTIRILMADI

`#54` ayni bilgiyi (sayac satirlari) daha dogrudan verdigi icin sema sorgusu gereksizleşti.

### #53 — CALISTIRILMADI

`#51`+`#54` "Id'yi uygulama atiyor" zincirini kapatti; IDENTITY sorgusu ek bilgi tasimiyordu.

### #54 — BASARILI · 🔑 IKINCI HIPOTEZI DE CURUTTU

```text
EntityColumnType|LastNumber|LastUpdateDate          |MaxAccEntryMainId|MaxAccEntryId|MaxTxnMmId
1               |3361      |2026-08-28 10:44:43.910 |555968           |5512296      |553350
2               |5970      |2026-08-31 17:58:34.630 |555968           |5512296      |553350
3               |12300     |2026-08-31 17:58:34.657 |555968           |5512296      |553350
4               |7956      |2026-08-31 17:58:34.660 |555968           |5512296      |553350
```

Id = `int.Parse("55" + LastNumber)` oldugu icin kiyas:

| Tur | Sayac → dagitacagi SONRAKI Id | Tablonun MAX'i | Durum |
|---|---|---|---|
| 1 `TransactionMM_Id` | 3361 → **553362** | `TxnMM` 553350 | ✅ sayac **onde** |
| 2 `AccountingEntryMain_Id` | 5970 → **555971** | `accEntryMain` 555968 | ✅ sayac **onde** |
| 3 `AccountingEntry_Id` | 12300 → **5512301** | `accEntry` 5512296 | ✅ sayac **onde** |

🔑 **SAYAC KAYMASI YOK.** Dagitilacak Id'ler tabloda mevcut olan en büyük Id'nin
**ustunde**. Yani *"sayac zaten var olan Id'yi dagitiyor"* hipotezi de **CURUK**.

ℹ Yan gozlem: `LastUpdateDate` 2-3-4 icin **ayni saniye** (17:58:34) — son Manuel Reeskont
kosusunun izi; sayaclar calisiyor.

⚠ Yapisal not (bugun sorun degil, ileride olabilir): `TransactionMM_Id`,
`AccountingEntryMain_Id` ve `AccountingEntry_Id` **ucu de `55` onekini** kullaniyor. Sayaclar
ayri satirlar ve tablolar ayri oldugu icin çakisma **anlamsiz**, ama uretilen Id'ler ayni
sayisal uzayda gorunuyor (`accEntryMain` 555968 vs `accEntry` 5512296) — log/hata okurken
"bu Id hangi tablodan?" sorusu karisabiliyor.

### #55 — CALISTIRILMADI

`#54` sayac ile MAX arasindaki iliskiyi kesin gosterdigi icin (sayac **onde**) "sonraki Id
tabloda var mi" sorusu **anlamsizlasti** — cevabi zorunlu olarak "yok". Sorgu kurulmus,
kosulmamistir.

---

## 🔑 Bu turun sonucu

Kullanicinin `Generate` sirasinda aldigi
`The instance of entity type 'AccEntryEntity' cannot be tracked because another instance with the
same key value for {'Id'} is already being tracked` hatasinin **veri/Id uretimi kaynakli
OLMADIGI** kanitlandi:

- SP mukerrer numara **uretemez** (`#51`)
- Sayaclar tablonun MAX'inin **onunde**, yani var olan Id **dagitilmiyor** (`#54`)

→ Sebep **EF change tracker**'da: istek basina tek (scoped) `DbContext`, `ExecutionsHandler`
N satiri **ayni context uzerinde** isliyor ve kod ayni muhasebe satirlarini bazi yerlerde
**tracked**, bazi yerlerde `AsNoTracking` okuyor. Kesin tetikleyici **tespit edilemedi** —
stack trace gerekiyor.


## Tur 2026-09-01 — Ayna çifti canlı test doğrulaması — SONUÇ

TxnId 553344 (TMMBRW2608210004, RevaluationType=Atomic) için accEntryMain zinciri:

| Id | ValueDate | IsReverse | ReverseId | Description | StateDate (local) |
|---|---|---|---|---|---|
| 555976 | 08-31 | 0 | 555978 | (kullanıcının kendi tıklaması, benim testimden ÖNCE) | 15:50:36 |
| 555978 | **08-31** | 1 | 555976 | Ters Fiş (kullanıcı) — **AYNI GÜN** | 16:14:37 |
| 555979 | 08-31 | 0 | 555980 | (benim Execute#1: Generate, CurrentStatus=1) | 16:19:18 |
| 555980 | **09-01** | 1 | 555979 | Ters Fiş (benim Execute#2) — **T+1** | 16:19:27 |
| 555981 | 08-31 | 0 | 555982 | Ayna çifti R1' (benim Execute#3: Regenerate) | 16:19:35 |
| 555982 | **09-01** | 1 | 555981 | Ayna çifti Rev1' — **T+1** | 16:19:36 |
| 555983 | 08-31 | 0 | 555984 | (kullanıcı, benden bağımsız — ekran hâlâ açıktı) | 16:20:06 |
| 555984 | **09-01** | 1 | 555983 | Ters Fiş | 16:20:07 |

**Bulgu:** Aynı transaction, aynı RevaluationType=Atomic için ters fiş valörü İKİ FARKLI kural
üretti — kullanıcının UI'den attığı ilk çift (555976/555978) reverse'i **AYNI GÜNE** (08-31)
kesti; benim ham `Execute` çağrılarım (`ReverseValueType`/`ReverseValueDate` hiç göndermeden)
**T+1**'e (09-01) kesti. Sunucu varsayılanı statik +1 gün; UI muhtemelen `RevaluationType`'a
göre `ReverseValueType` hesaplayıp gönderiyor, ben o hesaplamayı atladığım için varsayılana
düştüm. Ayrı bir bug değil — benim ham isteğimin eksik alanı. Ama açığa çıkardığı gerçek soru:
sunucu, `ReverseValueType`'ı `RevaluationType`'a göre DOĞRULUYOR mu, yoksa istemciden geleni
körü körüne mi kesiyor? Koddan bakılacak.

**Kapanış:** Yanlış alarm — `ReverseValueType` UI'de kullanıcının seçtiği bir radio (T0/T1,
varsayılan T1), `RevaluationType`'a bağlı otomatik kural değil. Ham curl bu alanı göndermediği
için sunucu varsayılana (T+1) düştü; kullanıcının kendi tıklaması T0 seçmiş olmalı. Kod tasarımla
tutarlı, aksiyon gerekmiyor.

---

## 2026-09-04 — `sp_GetNewNumbers` sozlesmesi

**Sonuc: HIPOTEZ CURUTULDU.** SP `@CountToGenerate` kadar **ardisik ve tekil** sayi donduruyor:

```sql
UPDATE dbo.defNumberGen WITH (ROWLOCK, UPDLOCK)
SET @new_last_no = LastNumber = LastNumber + @CountToGenerate, LastUpdateDate = GETDATE()
WHERE EntityColumnType = @EntityColumnType;
...
DECLARE @start_no int = @new_last_no - @CountToGenerate + 1;
WITH NumberSequence AS (SELECT @start_no ... UNION ALL SELECT GeneratedNumber + 1 ...)
SELECT GeneratedNumber FROM NumberSequence OPTION (MAXRECURSION 0);
```

- Tek `UPDATE` ifadesi + `UPDLOCK` → **atomik**, mukerrer sayi uretemez.
- Donen satir sayisi **tam** `@CountToGenerate` → `acEntryIds` listesi detay sayisindan
  kisa donemez, yani "geri kalan detaylarin `Id`'si `0`'da kalir" senaryosu **olusamaz**.
- `@CountToGenerate <= 0` icin `RAISERROR` → sessiz bos liste de yok.

➡️ `AccEntryEntity ... already being tracked` hatasinin kaynagi **Id uretimi degil**.
Kalan tek aciklama: cakisan ikinci nesne **onceki bir istekten** kalmis, yani hatayi yasayan
`DbContext` istegi asiyor. (Manuel Reeskont yolundaki tum okumalar `AsNoTracking`.)

---

## 2026-09-04 — Deploy sonrasi tekrar-uretim adayi

| Id | TxnId | ValueDate | IsReverse | ReverseId | StateDate |
|---|---|---|---|---|---|
| 556006 | 553344 | 2026-09-04 | 1 | 556002 | 2026-09-04 10:57:22 |
| 556002 | 553344 | 2026-09-03 | 0 | **556006** | 2026-09-04 10:28:03 |
| 555975 | 553336 | 2026-09-01 | 1 | 555974 | 2026-09-01 15:10:07 |
| 555974 | 553336 | 2026-08-31 | 0 | 555975 | 2026-09-01 15:10:06 |

**Sonuc:**

- **553344 / 09-03 → `Rediscounted`**: `556002`'nin `ReverseId = 556006`, ters fisin valoru
  **09-04 > 09-03**. Generate `ALREADY_REDISCOUNTED` doner → **hatayi tekrar uretmez**.
  (Regenerate icin uygun.)
- **553336 → 09-03 valorlu fis YOK** (en son 08-31/09-01). Durum `NotRediscounted` →
  cluster'in 07:28:18'de patlattigi **birebir ayni istek**. DB durumu o andan beri degismedi
  (son `StateDate` 2026-09-01 15:10) → **en iyi tekrar-uretim adayi**.
- Yan dogrulama: `556002` (10:28:03) ve `556006` (10:57:22) **local** process pencerelerine denk
  geliyor → Seq process eslemem bagimsiz olarak dogrulandi.

---

## 2026-09-10 — #56-#59 ciktilari (tek fis mi, sayac onde mi)

### #56 — defNumberGen kolonlari
`EntityColumnType (int)` · `LastNumber (int)` · `Definition (nvarchar)` · `LastUpdateDate (datetime)`

### #57 — defNumberGen sayaclari (2026-09-10)
| EntityColumnType | Definition | LastNumber | LastUpdateDate |
|---|---|---|---|
| 4 | Generated Account | 8000 | 2026-09-10 11:52:32.290 |
| 3 | Account Entry | **12390** | 2026-09-10 11:52:32.287 |
| 2 | Acc Entry Main Id | **6008** | 2026-09-10 11:52:32.267 |
| 1 | Txn Mm Id | 3378 | 2026-09-10 07:45:44.960 |

Uc sayac **ayni saniyede** (267/287/290 ms) → **tek** `AccountingDataManager.InsertAsync` cagrisi.

### #57b — accEntryMain MAX(Id) = **556006** (2026-09-04 10:57)
→ sonraki Id 556009; **556007 ve 556008 yakilmis** = **2 basarisiz deneme** (ikisi ayri istek).

### #59 — accEntry MAX(Id) = **5512384** (main 556006, txn 553344)
→ sonraki Id 5512391; **12385..12390 yakilmis** = 6 numara / 2 deneme.
Bacak sayilari: TRY-only fis **2 bacak**, TRY+USD fis **4 bacak** (ornek main 555989/555990).

🔑 **SONUC:** sayac **MONOTON ve ONDE** — generator var olan bir `accEntry.Id`'sini **tekrar dagitmiyor**.
Yani `AccEntryEntity ... already being tracked` cakismasi **DB'den okunmus bir satirla olamaz**.
Seq dokumu de tek satir gosteriyor (`Succeeded: []`, `Failed: 1`, RequestId `0HNOF1PFRP44A:00000002`)
→ **tek item, tek insert**. Onceki "ayni scope'ta 1-4 insert zincirleniyor" aciklamasi bu olayi
**aciklamiyor** ve geri alindi.

## 2026-09-15 — DerivSwp `interestRateDetailList is null` teshis ciktilari

**S-01** — `TDCCS26081800001` = TxnId 88167, Receive TRY/Chart 7, Pay USD/Chart 7.
`TDIRS26072700001` = TxnId 88164, Receive TRY/Chart 7, Pay TRY/Chart 7.

**S-02** — ChartId 7'de 2026-09-10 tarihli HIC `InterestRate` basligi yok; son kayit 2026-09-09 (yalniz TRY, 4 detay).

**S-03** — Chart 2/4/5 tum para birimlerinde 2026-09-15'e kadar guncel. Chart 7 listede yok (geride).

**S-04** — ChartId 7 kirilimi:
| Ccy | Detay | Ilk | Son |
|---|---|---|---|
| TRY | 7669 | 2025-05-10 | **2026-09-09** |
| EUR | 10146 | 2025-05-10 | **2026-06-18** |
| USD | 10147 | 2025-05-10 | **2026-06-18** |

**S-05** — HATA: `Invalid column name 'ValueDate'/'StateId'` (tablo `CalculationDate` kullaniyor, state kolonu yok).

**S-06** — `DerivativesRevaluation`: TxnId 88164 (IRS, TRY/TRY) → 2026-08-31, 09-07, **09-09**. TxnId 88167 (CCS, TRY/USD) → **hic kayit yok**.

### Sonuc
Hata veri eksikliginden; manuel reeskont kodundan degil. Iki ayri bosluk:
1. Chart 7'de 2026-09-10 egrisi yok → o islem tarihinde chart 7'ye bagli HER islem patlar (IRS dahil).
2. Chart 7 USD/EUR 2026-06-18'den beri bos → CCS islemleri EOD batch'te de hic degerlenememis.

### DUZELTME (S-09b / S-10) — veri ara donemde degismis
S-02/S-04 sirasinda chart 7'nin son gunu TRY=2026-09-09, USD/EUR=2026-06-18 goruldu. Birkac
dakika sonra ayni sorgular calistirildiginda chart 7'ye **2026-09-15 ve 2026-09-16** yuklenmis
(gunde 78 detay: 22 TRY + 28 EUR + 28 USD). Gercek boşluk:

| Aralik | Durum |
|---|---|
| … 2026-06-28 | dolu (78 detay/gun) |
| **2026-06-29 → 2026-09-14** | **BOS** |
| 2026-09-15, 09-16 | dolu |

Bu, `Execution Date = 10.09.2026` hatasini ve `15.09.2026` basarisini aciklar.

### Sema bulgular (S-07, S-11, S-12, S-13a)
- `InterestRate.Id` ve `InterestRateDetail.Id` **IDENTITY DEGIL** → insert Id uretmeli.
- `DefNumberGen`'de InterestRate icin sayac satiri **yok** → MAX(Id)+1 guvenli.
- `InterestRateDetail.PointDate` sabit `1900-01-01`; `SymbolName` NULL; `Source` = `Bloomberg`.
- `PointDays` detayda yok, `Point.Days` uzerinden gelir.
- `Point` tablosunda kolon adi `PointCode` (`Code` degil).

### Uretilen script
`.ai-agent/outputs/2026-09-15-DerivSwp-InterestRate-Backfill/` → `01-backfill-interest-rate.sql`,
`02-dogrulama.sql`, `03-geri-alma.sql`, `README.md`. **Kullanici uygular.**

### S-16 — `NetTrexOptFX` DefNumberGen
```
EntityColumnType|LastNumber|Definition|LastUpdateDate
4|633|AccEngineGeneratedAccountRule_Id|2026-08-26 15:57:58.753
3|757|AccEntry_Id|2026-08-26 15:57:58.743
2|125|AccEntryMain_Id|2026-08-26 15:57:58.720
1|126|Txn_Id|2026-09-17 13:27:12.780
```

### S-17 — `sp_GetNewNumbers` govdesi (MSSQL)
```sql
UPDATE dbo.defNumberGen WITH (ROWLOCK, UPDLOCK)
SET @new_last_no = LastNumber = LastNumber + @CountToGenerate, LastUpdateDate = GETDATE()
WHERE EntityColumnType = @EntityColumnType;
...
WITH NumberSequence AS (SELECT @start_no AS GeneratedNumber UNION ALL
                        SELECT GeneratedNumber + 1 FROM NumberSequence WHERE GeneratedNumber < @new_last_no)
SELECT GeneratedNumber FROM NumberSequence OPTION (MAXRECURSION 0);
```
🔴 **Donen kolon adi `GeneratedNumber`.**

### S-18 — `NetTrexOptFX`.AccEntryMain en buyuk Id
```
Id|TxnId|Type|IsReverse|ReverseId|ValueDate|StateDate
99125|99117|1|0|0|2026-08-13|2026-08-26 15:57:50.343
99124|99116|1|0|0|2026-08-19|2026-08-26 15:48:40.213
... (kirpildi, en yeni kayit 2026-08-26)
```
→ Hata veren istek 992060+ / 2026-09-17 → **API bu DB'de degil**.

### S-19 — Sunucudaki OPTFX veritabanlari
18 adet; ilgili olanlar: `NetTrexOPTFX` (id 191), `NetTrexOptFX-investmentbank` (launchSettings
`Api:UAT-Investment` profilinde). Hepsi CI collation.

### S-20 — `NetTrexOptFX-investmentbank`
```
Login failed for user 'trusr'.
Cannot open database "NetTrexOptFX-investmentbank" requested by the login. The login failed.
```
→ `trusr` bu DB'ye yetkili degil. **Sorgu calistirilamadi.**

### S-21 — çıktı (ham)
```
tbl|idx|type_desc|keys|incl
---|---|---------|----|----
AccEntryMain|PK_AccEntryMain|CLUSTERED|Id|NULL
CusCustomer|IX_CusCustomer_ExternalCustomerId|NONCLUSTERED|ExternalCustomerId|ShortName
DefTxnType|PK_DefTxnType|CLUSTERED|TxnTypeCode|NULL
LoanRevaluation|PK_LoanRevaluation|CLUSTERED|Id|NULL
TxnLoan|PK_TxnLoan|CLUSTERED|Id|NULL
TxnMM|PK_TxnMM|CLUSTERED|Id|NULL
TxnMM|UQ_TxnMM_LogicalReference|NONCLUSTERED|LogicalReference|NULL
TxnMM|IX_TxnMM_StateDate|NONCLUSTERED|StateDate|StateId
TxnMM|IX_TxnMM_ValueDate|NONCLUSTERED|ValueDate|NULL
TxnMM|IX_TxnMM_MaturityDate|NONCLUSTERED|MaturityDate|NULL
TxnMmDailyCalculation|PK_TxnMmDailyCalculation|CLUSTERED|Id|NULL
TxnMMDetail|PK_TxnMMDetail|CLUSTERED|Id|NULL
name|rows
----|----
AccEntryMain|8010
CusCustomer|109
LoanRevaluation|188
TxnLoan|96
TxnMM|3663
TxnMmDailyCalculation|1154
TxnMMDetail|10657
```
**Yorum:** AccEntryMain / TxnMMDetail / TxnMmDailyCalculation'da yalnız PK (Id) var — TxnId FK index'i YOK. CusCustomer'da clustered/PK yok (heap), Id araması tarama. Satır başına korele alt sorgular her seferinde tablo taraması yapıyor → 3006 satır × ~25 alt sorgu × 5 sorgu. Listeleme yavaşlığının ana sebebi.

### S-22 — çıktı
```
run1: items=3005 total=3005 NR=3005 NRev=0 R=0 elapsed=96648ms  (DbCommand ilk-satır süreleri: 313/184/189/203/1273 ms)
run2: items=3005 total=3005 NR=3005 NRev=0 R=0 elapsed=75103ms  (46/128/157/619/991 ms)
```
Items SELECT (ham, EF üretimi):
```sql
      SELECT [s].[Id], [s].[LogicalReference], [s].[TxnMmProductTypeId], [s].[Name], (
          SELECT TOP(1) [c].[ExternalCustomerId]
          FROM [cusCustomer] AS [c]
          WHERE [c].[Id] = [s].[CustomerId]), (
          SELECT TOP(1) [c0].[Name]
          FROM [cusCustomer] AS [c0]
          WHERE [c0].[Id] = [s].[CustomerId]), (
          SELECT TOP(1) [a0].[ReverseId]
          FROM [accEntryMain] AS [a0]
          WHERE [s].[Id] = [a0].[TxnId] AND [a0].[Type] = @revaluationType AND [a0].[IsReverse] = CAST(0 AS bit) AND [a0].[ValueDate] = @executionDate AND [a0].[ProductCode] = [s].[MainProductCode]
          ORDER BY [a0].[Id] DESC), CASE
          WHEN (
              SELECT TOP(1) [a1].[ReverseId]
              FROM [accEntryMain] AS [a1]
              WHERE [s].[Id] = [a1].[TxnId] AND [a1].[Type] = @revaluationType AND [a1].[IsReverse] = CAST(0 AS bit) AND [a1].[ValueDate] = @executionDate AND [a1].[ProductCode] = [s].[MainProductCode]
              ORDER BY [a1].[Id] DESC) IS NULL OR (
              SELECT TOP(1) [a2].[ReverseId]
              FROM [accEntryMain] AS [a2]
              WHERE [s].[Id] = [a2].[TxnId] AND [a2].[Type] = @revaluationType AND [a2].[IsReverse] = CAST(0 AS bit) AND [a2].[ValueDate] = @executionDate AND [a2].[ProductCode] = [s].[MainProductCode]
              ORDER BY [a2].[Id] DESC) = 0 THEN NULL
          ELSE (
              SELECT TOP(1) [a3].[ValueDate]
              FROM [accEntryMain] AS [a3]
              WHERE [s].[Id] = [a3].[TxnId] AND [a3].[Id] = (
                  SELECT TOP(1) [a4].[ReverseId]
                  FROM [accEntryMain] AS [a4]
                  WHERE [s].[Id] = [a4].[TxnId] AND [a4].[Type] = @revaluationType AND [a4].[IsReverse] = CAST(0 AS bit) AND [a4].[ValueDate] = @executionDate AND [a4].[ProductCode] = [s].[MainProductCode]
                  ORDER BY [a4].[Id] DESC))
      END, [s].[TxnTypeCode], (
          SELECT TOP(1) [d1].[Name]
          FROM [defTxnType] AS [d1]
          WHERE [d1].[TxnTypeCode] = [s].[TxnTypeCode]), [s].[Ccy], [s].[DealAmount], (
          SELECT TOP(1) [t1].[InterestRate]
          FROM [txnMMDetail] AS [t1]
          WHERE [s].[Id] = [t1].[TxnId] AND [t1].[IsPrincipalAmount] = CAST(0 AS bit)), [s].[ValueDate], [s].[MaturityDate], (
          SELECT COALESCE(SUM([t2].[AccrualAmount]), 0.0)
          FROM [txnMmDailyCalculation] AS [t2]
          WHERE [s].[Id] = [t2].[TxnMmId] AND [t2].[CalculationDate] <= @executionDate), (
          SELECT TOP(1) [t3].[AccrualAmount]
          FROM [txnMmDailyCalculation] AS [t3]
          WHERE [s].[Id] = [t3].[TxnMmId] AND [t3].[CalculationDate] = @executionDate), [p0].[Name], [d].[Name], [d0].[BasisName], (
          SELECT TOP(1) [t4].[AccrualDay]
          FROM [txnMmDailyCalculation] AS [t4]
          WHERE [s].[Id] = [t4].[TxnMmId] AND [t4].[CalculationDate] = @executionDate), (
          SELECT TOP(1) [t5].[AccrualAmountSL]
          FROM [txnMmDailyCalculation] AS [t5]
          WHERE [s].[Id] = [t5].[TxnMmId] AND [t5].[CalculationDate] = @executionDate), (
          SELECT TOP(1) [t6].[AccrualAmountIRR]
          FROM [txnMmDailyCalculation] AS [t6]
          WHERE [s].[Id] = [t6].[TxnMmId] AND [t6].[CalculationDate] = @executionDate), (
          SELECT TOP(1) [t7].[AccrualAmountLCY]
          FROM [txnMmDailyCalculation] AS [t7]
          WHERE [s].[Id] = [t7].[TxnMmId] AND [t7].[CalculationDate] = @executionDate), (
          SELECT TOP(1) [t8].[FXRate]
          FROM [txnMmDailyCalculation] AS [t8]
          WHERE [s].[Id] = [t8].[TxnMmId] AND [t8].[CalculationDate] = @executionDate), [s].[MarketCode], [s].[InputDate], [s].[TradeDate], [s].[MaturityAmount], (
          SELECT TOP(1) [t9].[PeriodStartDate]
          FROM [txnMMDetail] AS [t9]
          WHERE [s].[Id] = [t9].[TxnId] AND [t9].[IsPrincipalAmount] = CAST(0 AS bit)), (
          SELECT TOP(1) [t10].[PeriodEndDate]
          FROM [txnMMDetail] AS [t10]
          WHERE [s].[Id] = [t10].[TxnId] AND [t10].[IsPrincipalAmount] = CAST(0 AS bit)), (
          SELECT TOP(1) [t11].[Amount]
          FROM [txnMMDetail] AS [t11]
          WHERE [s].[Id] = [t11].[TxnId] AND [t11].[IsPrincipalAmount] = CAST(0 AS bit)), [s].[AccountNumber], (
          SELECT TOP(1) [d2].[Name]
          FROM [cusCustomer] AS [c1]
          LEFT JOIN [defCorporateType] AS [d2] ON [c1].[CorporateTypeId] = [d2].[Id]
          WHERE [c1].[Id] = [s].[CustomerId] AND [d2].[Id] IS NOT NULL), (
          SELECT TOP(1) [d3].[Name]
          FROM [cusCustomer] AS [c2]
          LEFT JOIN [defCorporateDetailType] AS [d3] ON [c2].[CorporateDetailTypeId] = [d3].[Id]
          WHERE [c2].[Id] = [s].[CustomerId] AND [d3].[Id] IS NOT NULL), CASE
          WHEN (
              SELECT TOP(1) [a5].[ReverseId]
              FROM [accEntryMain] AS [a5]
              WHERE [s].[Id] = [a5].[TxnId] AND [a5].[Type] = @revaluationType AND [a5].[IsReverse] = CAST(0 AS bit) AND [a5].[ValueDate] = @executionDate AND [a5].[ProductCode] = [s].[MainProductCode]
              ORDER BY [a5].[Id] DESC) IS NULL OR (
              SELECT TOP(1) [a6].[ReverseId]
              FROM [accEntryMain] AS [a6]
              WHERE [s].[Id] = [a6].[TxnId] AND [a6].[Type] = @revaluationType AND [a6].[IsReverse] = CAST(0 AS bit) AND [a6].[ValueDate] = @executionDate AND [a6].[ProductCode] = [s].[MainProductCode]
              ORDER BY [a6].[Id] DESC) = 0 THEN NULL
          ELSE (
              SELECT TOP(1) [a7].[MessageKey]
              FROM [accEntryMain] AS [a7]
              WHERE [s].[Id] = [a7].[TxnId] AND [a7].[Id] = (
                  SELECT TOP(1) [a8].[ReverseId]
                  FROM [accEntryMain] AS [a8]
                  WHERE [s].[Id] = [a8].[TxnId] AND [a8].[Type] = @revaluationType AND [a8].[IsReverse] = CAST(0 AS bit) AND [a8].[ValueDate] = @executionDate AND [a8].[ProductCode] = [s].[MainProductCode]
                  ORDER BY [a8].[Id] DESC))
      END, (
          SELECT TOP(1) [a9].[MessageKey]
          FROM [accEntryMain] AS [a9]
          WHERE [s].[Id] = [a9].[TxnId] AND [a9].[Type] = @revaluationType AND [a9].[IsReverse] = CAST(0 AS bit) AND [a9].[ValueDate] = @executionDate AND [a9].[ProductCode] = [s].[MainProductCode]
          ORDER BY [a9].[Id] DESC)
      FROM (
          SELECT [t].[Id], [t].[AccountNumber], [t].[BasisCode], [t].[Ccy], [t].[CustomerId], [t].[DealAmount], [t].[FundSourceId], [t].[InputDate], [t].[LogicalReference], [t].[MarketCode], [t].[MaturityAmount], [t].[MaturityDate], [t].[PortfolioId], [t].[TradeDate], [t].[TxnMmProductTypeId], [t].[TxnTypeCode], [t].[ValueDate], [p].[MainProductCode], [p].[Name]
          FROM [TxnMM] AS [t]
          INNER JOIN [prdProductDefinition] AS [p] ON [t].[TxnMmProductTypeId] = [p].[Id]
          WHERE CAST([t].[StateId] AS int) IN (26, 18) AND [t].[MaturityDate] > @executionDate AND [t].[ValueDate] <= @executionDate AND EXISTS (
              SELECT 1
              FROM [accEntryMain] AS [a]
              WHERE [t].[Id] = [a].[TxnId] AND [a].[Type] = @openingType AND [a].[ProductCode] = [p].[MainProductCode]) AND EXISTS (
              SELECT 1
              FROM [txnMMDetail] AS [t0]
              WHERE [t].[Id] = [t0].[TxnId] AND [t0].[IsPrincipalAmount] = CAST(0 AS bit) AND [t0].[PeriodStartDate] <= @executionDate AND [t0].[PeriodEndDate] > @executionDate)
          ORDER BY [t].[Id] DESC
          OFFSET @p ROWS FETCH NEXT @p10 ROWS ONLY
      ) AS [s]
      LEFT JOIN [prfPortfolio] AS [p0] ON [s].[PortfolioId] = [p0].[Id]
      LEFT JOIN [defFundSource] AS [d] ON [s].[FundSourceId] = [d].[Id]
      INNER JOIN [defDateBasis] AS [d0] ON [s].[BasisCode] = [d0].[BasisCode]
      ORDER BY [s].[Id] DESC
```
**Yorum:** COUNT sorguları toplam <1 sn. Süre items SELECT'in satır üretiminde: satır başına 13 accEntryMain + 4 txnMMDetail + 6 txnMmDailyCalculation + 4 cusCustomer korele alt sorgu, TxnId index'i olmadığından her biri tablo taraması → ~75-96 sn.

### S-24 — çalıştırılmadı (bkz. S-25)

### S-25 — çıktı (ham)
```
ValueDate|ProductCode|IsReverse|Adet
---------|-----------|---------|----
2026-09-29|MM|1|2
2026-09-28|MM|0|3
2026-09-28|MM|1|1
2026-09-24|MM|1|2
2026-09-23|MM|0|2
2026-09-23|MM|1|1
2026-09-22|MM|0|4
2026-09-22|MM|1|7
2026-09-21|MM|0|4
2026-09-21|MM|1|4
2026-09-20|MM|0|5
2026-09-20|MM|1|2
2026-09-19|MM|0|2
2026-09-19|MM|1|2
2026-09-18|MM|0|2
2026-09-18|MM|1|1
2026-09-17|MM|0|1
2026-09-16|MM|0|3
2026-09-16|MM|1|7
2026-09-15|MM|0|9
```

### S-26 — çıktı (ham, kırpıldı: satır başı 250 karakter)
```
LOAN 2026-09-28 st=all skip=0 take=all items=10 total=10 NR=10 NRev=0 R=0 old=1098ms new=501ms EQUAL
LOAN 2026-09-28 st=1 skip=0 take=all items=10 total=10 NR=10 NRev=0 R=0 old=667ms new=114ms EQUAL
LOAN 2026-09-28 st=3 skip=0 take=all items=0 total=0 NR=0 NRev=0 R=0 old=381ms new=64ms EQUAL
LOAN 2026-09-28 st=4 skip=0 take=all items=0 total=0 NR=0 NRev=0 R=0 old=583ms new=36ms EQUAL
LOAN 2026-09-22 st=all skip=0 take=all items=11 total=11 NR=11 NRev=0 R=0 old=297ms new=98ms EQUAL
LOAN 2026-09-22 st=1 skip=0 take=all items=11 total=11 NR=11 NRev=0 R=0 old=224ms new=80ms EQUAL
LOAN 2026-09-22 st=3 skip=0 take=all items=0 total=0 NR=0 NRev=0 R=0 old=110ms new=25ms EQUAL
LOAN 2026-09-22 st=4 skip=0 take=all items=0 total=0 NR=0 NRev=0 R=0 old=89ms new=32ms EQUAL
LOAN 2026-09-23 st=all skip=0 take=all items=10 total=10 NR=10 NRev=0 R=0 old=270ms new=92ms EQUAL
LOAN 2026-09-23 st=1 skip=0 take=all items=10 total=10 NR=10 NRev=0 R=0 old=202ms new=92ms EQUAL
LOAN 2026-09-23 st=3 skip=0 take=all items=0 total=0 NR=0 NRev=0 R=0 old=105ms new=24ms EQUAL
LOAN 2026-09-23 st=4 skip=0 take=all items=0 total=0 NR=0 NRev=0 R=0 old=82ms new=26ms EQUAL
LOAN 2026-09-27 st=all skip=0 take=all items=10 total=10 NR=10 NRev=0 R=0 old=321ms new=76ms EQUAL
LOAN 2026-09-27 st=1 skip=0 take=all items=10 total=10 NR=10 NRev=0 R=0 old=224ms new=73ms EQUAL
LOAN 2026-09-27 st=3 skip=0 take=all items=0 total=0 NR=0 NRev=0 R=0 old=100ms new=22ms EQUAL
LOAN 2026-09-27 st=4 skip=0 take=all items=0 total=0 NR=0 NRev=0 R=0 old=348ms new=23ms EQUAL
MM 2026-09-28 st=3 skip=0 take=all items=0 total=0 NR=0 NRev=0 R=0 old=894ms new=105ms EQUAL
MM 2026-09-28 st=4 skip=0 take=all items=1 total=1 NR=0 NRev=0 R=1 old=781ms new=209ms EQUAL
MM 2026-09-22 st=3 skip=0 take=all items=0 total=0 NR=0 NRev=0 R=0 old=472ms new=55ms EQUAL
MM 2026-09-22 st=4 skip=0 take=all items=1 total=1 NR=0 NRev=0 R=1 old=434ms new=162ms EQUAL
MM 2026-09-23 st=4 skip=0 take=all items=1 total=1 NR=0 NRev=0 R=1 old=403ms new=114ms EQUAL
MM 2026-09-28 st=all skip=10 take=25 items=25 total=3006 NR=3005 NRev=0 R=1 old=1626ms new=128ms DIFF
   counts old: 3006/3005/0/1 items 25
   OLD {"TransactionId":556390,"LogicalReference":"TMMBRWYT02990","ProductTypeId":1,"ProductName":"Money Market","ExternalCustomerId":27253,"ExternalCustomerName":"\u0130\u015F Bankas\u0131","RediscountReverseId":null,"ReverseValueDate":null,"TxnType
   NEW {"TransactionId":556390,"LogicalReference":"TMMBRWYT02990","ProductTypeId":1,"ProductName":"Money Market","ExternalCustomerId":27253,"ExternalCustomerName":"\u0130\u015F Bankas\u0131","RediscountReverseId":null,"ReverseValueDate":null,"TxnType
MM 2026-09-28 st=1 skip=3000 take=50 items=5 total=3005 NR=3005 NRev=0 R=0 old=925ms new=114ms DIFF
   counts old: 3005/3005/0/0 items 5
   OLD {"TransactionId":553397,"LogicalReference":"TMMPLC2609240001","ProductTypeId":1,"ProductName":"Money Market","ExternalCustomerId":27106,"ExternalCustomerName":"Akbank A.\u015E.","RediscountReverseId":null,"ReverseValueDate":null,"TxnTypeCode":
   NEW {"TransactionId":553397,"LogicalReference":"TMMPLC2609240001","ProductTypeId":1,"ProductName":"Money Market","ExternalCustomerId":27106,"ExternalCustomerName":"Akbank A.\u015E.","RediscountReverseId":null,"ReverseValueDate":null,"TxnTypeCode":
MM 2026-09-28 st=all skip=0 take=all items=3006 total=3006 NR=3005 NRev=0 R=1 old=73867ms new=1313ms DIFF
   counts old: 3006/3005/0/1 items 3006
   OLD {"TransactionId":556400,"LogicalReference":"TMMBRWYT03000","ProductTypeId":1,"ProductName":"Money Market","ExternalCustomerId":27253,"ExternalCustomerName":"\u0130\u015F Bankas\u0131","RediscountReverseId":null,"ReverseValueDate":null,"TxnType
   NEW {"TransactionId":556400,"LogicalReference":"TMMBRWYT03000","ProductTypeId":1,"ProductName":"Money Market","ExternalCustomerId":27253,"ExternalCustomerName":"\u0130\u015F Bankas\u0131","RediscountReverseId":null,"ReverseValueDate":null,"TxnType
MM 2026-09-27 st=all skip=0 take=all items=3005 total=3005 NR=3005 NRev=0 R=0 old=75465ms new=3340ms DIFF
   counts old: 3005/3005/0/0 items 3005
   OLD {"TransactionId":556400,"LogicalReference":"TMMBRWYT03000","ProductTypeId":1,"ProductName":"Money Market","ExternalCustomerId":27253,"ExternalCustomerName":"\u0130\u015F Bankas\u0131","RediscountReverseId":null,"ReverseValueDate":null,"TxnType
   NEW {"TransactionId":556400,"LogicalReference":"TMMBRWYT03000","ProductTypeId":1,"ProductName":"Money Market","ExternalCustomerId":27253,"ExternalCustomerName":"\u0130\u015F Bankas\u0131","RediscountReverseId":null,"ReverseValueDate":null,"TxnType
DONE fails=4
```
**Yorum:** 21/25 vaka birebir EŞİT. 4 DIFF yalnız AccruedInterest ölçeği: eski 0.000000000000000000 (SQL COALESCE(SUM,0.0)), yeni 0 — sayısal eşit, handler RoundAwayFromZero(2). MM 3005 satır: eski 75465 ms → yeni 3340 ms. S-27'de normalize ederek tekrar.

### S-28 — çıktı (ham)
```
YukTestiAdet|TxnFxToplam
------------|-----------
0|0
tbl|idx|type_desc|keys
---|---|---------|----
AccEntryMain|PK_AccEntryMain|CLUSTERED|Id
CusCustomer|PK_CusCustomer|CLUSTERED|Id
TxnExternalValuationHistory|PK_TxnExternalValuationHistory|CLUSTERED|HistoryId
TxnFX|PK_TxnFX|CLUSTERED|Id
TxnFX|IX_InstrumentId_CustomerId_TxnTypeCode_TradeDate_SettleDate_StateId_Inc|NONCLUSTERED|InstrumentId,CustomerId,TxnTypeCode,TradeDate,SettleDate,StateId
TxnFX|UQ_TxnFX_LogicalReference|NONCLUSTERED|LogicalReference
TxnFxSwapValuation|PK_TxnFxSwapValuation|CLUSTERED|Id
TxnFxSwapValuationHistory|PK_TxnFxSwapValuationHistory|CLUSTERED|HistoryId
TxnFxValuation|PK_TxnFxValuation|CLUSTERED|Id
TxnFxValuationHistory|PK_TxnFxValuationHistory|CLUSTERED|HistoryId
TxnPmSwapValuation|PK_TxnPmSwapValuation|CLUSTERED|Id
TxnPmSwapValuationHistory|PK_TxnPmSwapValuationHistory|CLUSTERED|HistoryId
TxnPmValuation|PK_TxnPmValuation|CLUSTERED|Id
TxnPmValuationHistory|PK_TxnPmValuationHistory|CLUSTERED|HistoryId
name|rows
----|----
AccEntryMain|48
CusCustomer|104
TxnExternalValuation|0
TxnExternalValuationHistory|0
TxnFX|0
TxnFxSwapValuation|0
TxnFxSwapValuationHistory|0
TxnFxValuation|8
TxnFxValuationHistory|66
TxnPmSwapValuation|0
TxnPmSwapValuationHistory|0
TxnPmValuation|0
TxnPmValuationHistory|0
```

**Yorum:** NetTrexFX_133 boş (TxnFX 0). AccEntryMain'de TxnId index'i YOK, valuation tablolarında TxnId index'i YOK (yalnız PK). Yük testi verisi başka DB'de.

### S-29 — çıktı (ham)
```
name|create_date
----|-----------
NetTrexFX_P_Test|2026-09-23 16:20:13.203
NetTrexOptFx_136_Test|2026-09-03 11:02:20.777
NetTrexFX_136_Test|2026-09-03 11:01:54.093
NetTrexOptFx_136_Dev|2026-09-03 10:59:58.170
NetTrexFX_136_Dev|2026-09-03 10:59:26.820
NetTrexOptFx_136|2026-09-03 10:56:14.287
NetTrexFX_136|2026-09-03 10:55:37.503
NetTrexOptFX_135_Test|2026-09-02 10:46:14.383
NetTrexFX_135_Test|2026-09-02 10:44:34.630
NetTrexOPTFX_133_Dene|2026-07-21 10:15:17.360
EasyFx|2026-07-20 17:54:35.973
NetTrexOPTFX_133_Test|2026-07-14 15:52:46.867
NetTrexOptFX_135_Dev|2026-07-08 09:22:19.493
NetTrexFX_135_Dev|2026-07-08 09:22:03.740
NetTrexOptFX_135|2026-07-08 09:20:50.330
NetTrexFX_135|2026-07-08 09:20:37.517
NetTrexOPTFX_Dev|2026-06-26 08:57:58.660
NetTrexFX_DunyaProd|2026-06-11 16:58:26.877
NetTrexOptFX_UAT|2026-05-22 14:25:40.840
NetTrexFX_UAT|2026-05-22 14:25:28.273
```

### S-30 — çıktı (ham; Db|TxnFx|YukTesti|Reeskont|FxValuation|SonTrade)
```
NetTrexFX|5|0|29|5|2026-09-21 00:00:00.000
NetTrexFX_Dev|156|0|11710|21|2026-08-28 00:00:00.000
NetTrexFX_P_Test|126|0|273|43|2024-11-28 00:00:00.000
NetTrexFX_136|14|0|20|5|2026-08-11 00:00:00.000
NetTrexFX_136_Dev|14|0|20|5|2026-08-11 00:00:00.000
NetTrexFX_136_Test|14|0|20|5|2026-08-11 00:00:00.000
```

### S-27 — çıktı (ham)
```
MM 2026-09-28 st=all skip=10 take=25 items=25 total=3006 NR=3005 NRev=0 R=1 old=2125ms new=547ms EQUAL
MM 2026-09-28 st=1 skip=3000 take=50 items=5 total=3005 NR=3005 NRev=0 R=0 old=968ms new=138ms EQUAL
MM 2026-09-28 st=all skip=0 take=all items=3006 total=3006 NR=3005 NRev=0 R=1 old=92007ms new=1805ms EQUAL
MM 2026-09-27 st=all skip=0 take=all items=3005 total=3005 NR=3005 NRev=0 R=0 old=81925ms new=1274ms EQUAL
DONE fails=0
```
**Yorum:** Ölçek normalize edilince 4 vaka da EŞİT → MM + IL tüm 25 vaka birebir aynı. MM 3006 satır: eski 92007 ms → yeni 1805 ms.

### S-31 — çıktı (ham)
```
ValueDate|ProductCode|IsReverse|Adet
---------|-----------|---------|----
2026-02-05|PM|1|100
2026-02-04|PM|1|5485
2026-02-04|PM|0|5585
2025-09-09|FX|1|17
2025-09-01|FX|0|117
2025-09-01|FX|1|102
2025-08-29|FX|1|1
2025-08-29|FX|0|1
2025-08-28|FX|0|3
2025-08-28|FX|1|3
2025-08-12|FX|0|1
2024-10-18|PM|1|3
2024-10-18|SWAPPM|1|1
2024-10-18|PM|0|4
2024-10-18|SWAPPM|0|2
2024-05-09|PM|0|7
2024-05-09|SWAPPM|0|16
2024-05-09|SWAPFX|0|8
2024-05-09|SWAPPM|1|16
2024-05-09|SWAPFX|1|8
```

### S-32 — çıktı (ham)
```
FaizSatiri|IslemAdedi
----------|----------
10|1
4|2
3|11
2|17
1|5269
```

### S-33 — çıktı (ham)
```
TxnId|Id|PStart|PEnd|InterestRate|Amount|LogicalReference|StateId|Maturity
-----|--|------|----|------------|------|----------------|-------|--------
553289|4577|2026-07-14|2026-10-05|5.0000000000|500000.000000000000000000|TISBRW2607140001|22|2025-11-04
553289|4578|2026-10-05|2026-12-28|5.0000000000|500000.000000000000000000|TISBRW2607140001|22|2025-11-04
553289|4579|2026-12-28|2027-03-22|5.0000000000|500000.000000000000000000|TISBRW2607140001|22|2025-11-04
553289|4580|2027-03-22|2027-06-10|5.0000000000|500000.000000000000000000|TISBRW2607140001|22|2025-11-04
553256|4510|2026-07-02|2027-07-02|.0000000000|.000000000000000000|TISBRW2607020001|22|2025-11-04
553256|4511|2027-07-02|2028-07-02|.0000000000|.000000000000000000|TISBRW2607020001|22|2025-11-04
553209|4431|2026-05-14|2026-11-12|15.0000000000|7500000.000000000000000000|TISBRW2605140006|22|2025-11-04
553209|4432|2026-11-12|2027-05-13|15.0000000000|7500000.000000000000000000|TISBRW2605140006|22|2025-11-04
552910|3823|2025-12-03|2026-06-03|15.0000000000|28650000.000000000000000000|TISBRW2512020001|22|2025-11-04
552910|3824|2026-06-03|2026-12-02|15.0000000000|28650000.000000000000000000|TISBRW2512020001|22|2025-11-04
552910|3825|2026-12-02|2027-06-02|15.0000000000|28650000.000000000000000000|TISBRW2512020001|22|2025-11-04
552910|3826|2027-06-02|2027-12-01|15.0000000000|28650000.000000000000000000|TISBRW2512020001|22|2025-11-04
552910|3827|2027-12-01|2028-05-31|15.0000000000|28650000.000000000000000000|TISBRW2512020001|22|2025-11-04
552910|3828|2028-05-31|2028-11-29|15.0000000000|28650000.000000000000000000|TISBRW2512020001|22|2025-11-04
552910|3829|2028-11-29|2029-05-30|15.0000000000|28650000.000000000000000000|TISBRW2512020001|22|2025-11-04
552910|3830|2029-05-30|2029-11-28|15.0000000000|28650000.000000000000000000|TISBRW2512020001|22|2025-11-04
552910|3831|2029-11-28|2030-05-29|15.0000000000|28650000.000000000000000000|TISBRW2512020001|22|2025-11-04
552910|3832|2030-05-29|2030-12-03|15.0000000000|28650000.000000000000000000|TISBRW2512020001|22|2025-11-04
552906|3818|2025-11-27|2025-12-01|20.0000000000|1000000.000000000000000000|TISBRW2511270008|22|2025-11-04
552906|3819|2025-12-01|2025-12-02|20.0000000000|1000000.000000000000000000|TISBRW2511270008|22|2025-11-04
```

### S-34 — çıktı (ham)
```
StateId|CokFaizSatirliIslem
-------|-------------------
22|27
```

### S-35 — çıktı (ham, satır başı 260 karakter)
```
2026-02-04 spot=False st=all skip=0 take=all items=0 total=0 NR=0 NRev=0 R=0 old=14195ms new=278ms EQUAL
2026-02-04 spot=False st=all skip=2 take=5 items=0 total=0 NR=0 NRev=0 R=0 old=390ms new=136ms EQUAL
2026-02-04 spot=False st=1 skip=0 take=all items=0 total=0 NR=0 NRev=0 R=0 old=2126ms new=90ms EQUAL
2026-02-04 spot=False st=3 skip=0 take=all items=0 total=0 NR=0 NRev=0 R=0 old=1819ms new=94ms EQUAL
2026-02-04 spot=False st=4 skip=0 take=all items=0 total=0 NR=0 NRev=0 R=0 old=1928ms new=95ms EQUAL
2026-02-04 spot=True st=all skip=0 take=all items=149 total=149 NR=149 NRev=0 R=0 old=2192ms new=630ms EQUAL
2026-02-04 spot=True st=all skip=2 take=5 items=5 total=149 NR=149 NRev=0 R=0 old=1621ms new=337ms EQUAL
2026-02-04 spot=True st=1 skip=0 take=all items=149 total=149 NR=149 NRev=0 R=0 old=3515ms new=1487ms EQUAL
2026-02-04 spot=True st=3 skip=0 take=all items=0 total=0 NR=0 NRev=0 R=0 old=1706ms new=423ms EQUAL
2026-02-04 spot=True st=4 skip=0 take=all items=0 total=0 NR=0 NRev=0 R=0 old=1722ms new=264ms EQUAL
2026-02-05 spot=False st=all skip=0 take=all items=0 total=0 NR=0 NRev=0 R=0 old=276ms new=124ms EQUAL
2026-02-05 spot=False st=all skip=2 take=5 items=0 total=0 NR=0 NRev=0 R=0 old=267ms new=98ms EQUAL
2026-02-05 spot=False st=1 skip=0 take=all items=0 total=0 NR=0 NRev=0 R=0 old=369ms new=112ms EQUAL
2026-02-05 spot=False st=3 skip=0 take=all items=0 total=0 NR=0 NRev=0 R=0 old=352ms new=111ms EQUAL
2026-02-05 spot=False st=4 skip=0 take=all items=0 total=0 NR=0 NRev=0 R=0 old=354ms new=97ms EQUAL
2026-02-05 spot=True st=all skip=0 take=all items=66 total=66 NR=66 NRev=0 R=0 old=3757ms new=132ms EQUAL
2026-02-05 spot=True st=all skip=2 take=5 items=5 total=66 NR=66 NRev=0 R=0 old=2638ms new=110ms EQUAL
2026-02-05 spot=True st=1 skip=0 take=all items=66 total=66 NR=66 NRev=0 R=0 old=6621ms new=179ms EQUAL
2026-02-05 spot=True st=3 skip=0 take=all items=0 total=0 NR=0 NRev=0 R=0 old=4824ms new=107ms EQUAL
2026-02-05 spot=True st=4 skip=0 take=all items=0 total=0 NR=0 NRev=0 R=0 old=3012ms new=501ms EQUAL
2025-09-01 spot=False st=all skip=0 take=all items=4 total=4 NR=0 NRev=0 R=4 old=1355ms new=369ms EQUAL
2025-09-01 spot=False st=all skip=2 take=5 items=2 total=4 NR=0 NRev=0 R=4 old=300ms new=113ms EQUAL
2025-09-01 spot=False st=1 skip=0 take=all items=0 total=0 NR=0 NRev=0 R=0 old=394ms new=130ms EQUAL
2025-09-01 spot=False st=3 skip=0 take=all items=0 total=0 NR=0 NRev=0 R=0 old=487ms new=107ms EQUAL
2025-09-01 spot=False st=4 skip=0 take=all items=4 total=4 NR=0 NRev=0 R=4 old=391ms new=121ms EQUAL
2025-09-01 spot=True st=all skip=0 take=all items=16 total=16 NR=0 NRev=0 R=16 old=342ms new=206ms EQUAL
2025-09-01 spot=True st=all skip=2 take=5 items=5 total=16 NR=0 NRev=0 R=16 old=354ms new=172ms EQUAL
2025-09-01 spot=True st=1 skip=0 take=all items=0 total=0 NR=0 NRev=0 R=0 old=1571ms new=105ms EQUAL
2025-09-01 spot=True st=3 skip=0 take=all items=0 total=0 NR=0 NRev=0 R=0 old=469ms new=125ms EQUAL
2025-09-01 spot=True st=4 skip=0 take=all items=16 total=16 NR=0 NRev=0 R=16 old=645ms new=203ms EQUAL
2025-08-28 spot=False st=all skip=0 take=all items=2 total=2 NR=2 NRev=0 R=0 old=380ms new=156ms EQUAL
2025-08-28 spot=False st=all skip=2 take=5 items=0 total=2 NR=2 NRev=0 R=0 old=321ms new=95ms EQUAL
2025-08-28 spot=False st=1 skip=0 take=all items=2 total=2 NR=2 NRev=0 R=0 old=461ms new=135ms EQUAL
2025-08-28 spot=False st=3 skip=0 take=all items=0 total=0 NR=0 NRev=0 R=0 old=357ms new=96ms EQUAL
2025-08-28 spot=False st=4 skip=0 take=all items=0 total=0 NR=0 NRev=0 R=0 old=392ms new=92ms EQUAL
2025-08-28 spot=True st=all skip=0 take=all items=5 total=5 NR=5 NRev=0 R=0 old=303ms new=106ms EQUAL
2025-08-28 spot=True st=all skip=2 take=5 items=3 total=5 NR=5 NRev=0 R=0 old=292ms new=115ms EQUAL
2025-08-28 spot=True st=1 skip=0 take=all items=5 total=5 NR=5 NRev=0 R=0 old=388ms new=116ms EQUAL
2025-08-28 spot=True st=3 skip=0 take=all items=0 total=0 NR=0 NRev=0 R=0 old=356ms new=93ms EQUAL
2025-08-28 spot=True st=4 skip=0 take=all items=0 total=0 NR=0 NRev=0 R=0 old=396ms new=88ms EQUAL
2024-10-18 spot=False st=all skip=0 take=all items=0 total=0 NR=0 NRev=0 R=0 old=292ms new=100ms EQUAL
2024-10-18 spot=False st=all skip=2 take=5 items=0 total=0 NR=0 NRev=0 R=0 old=257ms new=109ms EQUAL
2024-10-18 spot=False st=1 skip=0 take=all items=0 total=0 NR=0 NRev=0 R=0 old=355ms new=106ms EQUAL
2024-10-18 spot=False st=3 skip=0 take=all items=0 total=0 NR=0 NRev=0 R=0 old=410ms new=103ms EQUAL
2024-10-18 spot=False st=4 skip=0 take=all items=0 total=0 NR=0 NRev=0 R=0 old=390ms new=98ms EQUAL
2024-10-18 spot=True st=all skip=0 take=all items=0 total=0 NR=0 NRev=0 R=0 old=285ms new=111ms EQUAL
2024-10-18 spot=True st=all skip=2 take=5 items=0 total=0 NR=0 NRev=0 R=0 old=272ms new=88ms EQUAL
2024-10-18 spot=True st=1 skip=0 take=all items=0 total=0 NR=0 NRev=0 R=0 old=380ms new=91ms EQUAL
2024-10-18 spot=True st=3 skip=0 take=all items=0 total=0 NR=0 NRev=0 R=0 old=345ms new=88ms EQUAL
2024-10-18 spot=True st=4 skip=0 take=all items=0 total=0 NR=0 NRev=0 R=0 old=457ms new=103ms EQUAL
2024-05-09 spot=False st=all skip=0 take=all items=0 total=0 NR=0 NRev=0 R=0 old=285ms new=84ms EQUAL
2024-05-09 spot=False st=all skip=2 take=5 items=0 total=0 NR=0 NRev=0 R=0 old=277ms new=103ms EQUAL
2024-05-09 spot=False st=1 skip=0 take=all items=0 total=0 NR=0 NRev=0 R=0 old=407ms new=98ms EQUAL
2024-05-09 spot=False st=3 skip=0 take=all items=0 total=0 NR=0 NRev=0 R=0 old=366ms new=98ms EQUAL
2024-05-09 spot=False st=4 skip=0 take=all items=0 total=0 NR=0 NRev=0 R=0 old=390ms new=96ms EQUAL
2024-05-09 spot=True st=all skip=0 take=all items=0 total=0 NR=0 NRev=0 R=0 old=295ms new=108ms EQUAL
2024-05-09 spot=True st=all skip=2 take=5 items=0 total=0 NR=0 NRev=0 R=0 old=282ms new=103ms EQUAL
2024-05-09 spot=True st=1 skip=0 take=all items=0 total=0 NR=0 NRev=0 R=0 old=390ms new=118ms EQUAL
2024-05-09 spot=True st=3 skip=0 take=all items=0 total=0 NR=0 NRev=0 R=0 old=395ms new=114ms EQUAL
2024-05-09 spot=True st=4 skip=0 take=all items=0 total=0 NR=0 NRev=0 R=0 old=465ms new=106ms EQUAL
2026-08-20 spot=False st=all skip=0 take=all items=0 total=0 NR=0 NRev=0 R=0 old=325ms new=122ms EQUAL
2026-08-20 spot=False st=all skip=2 take=5 items=0 total=0 NR=0 NRev=0 R=0 old=273ms new=108ms EQUAL
2026-08-20 spot=False st=1 skip=0 take=all items=0 total=0 NR=0 NRev=0 R=0 old=369ms new=100ms EQUAL
2026-08-20 spot=False st=3 skip=0 take=all items=0 total=0 NR=0 NRev=0 R=0 old=345ms new=114ms EQUAL
2026-08-20 spot=False st=4 skip=0 take=all items=0 total=0 NR=0 NRev=0 R=0 old=364ms new=99ms EQUAL
2026-08-20 spot=True st=all skip=0 take=all items=0 total=0 NR=0 NRev=0 R=0 old=309ms new=116ms EQUAL
2026-08-20 spot=True st=all skip=2 take=5 items=0 total=0 NR=0 NRev=0 R=0 old=290ms new=95ms EQUAL
2026-08-20 spot=True st=1 skip=0 take=all items=0 total=0 NR=0 NRev=0 R=0 old=518ms new=145ms EQUAL
2026-08-20 spot=True st=3 skip=0 take=all items=0 total=0 NR=0 NRev=0 R=0 old=362ms new=110ms EQUAL
2026-08-20 spot=True st=4 skip=0 take=all items=0 total=0 NR=0 NRev=0 R=0 old=469ms new=175ms EQUAL
DONE fails=0
```
**Yorum:** 98 vakanın 98'i birebir EŞİT (fails=0). Örn. 2026-02-05 spot=true 66 satır: eski 3757 ms → yeni 132 ms.
> Düzeltme (S-35 yorumu): vaka sayısı 98 değil **70**; 70/70 EŞİT.

### S-36 — çıktı (ham)
```
-- NetTrexDerivSWP
ValueDate|IsReverse|Adet
---------|---------|----
2026-09-22|1|2
2026-09-17|1|16
2026-09-16|0|26
2026-09-16|1|7
2026-09-15|0|9
2026-09-15|1|7
2026-09-10|1|1
2026-09-09|0|1
-- NetTrexOPTFX
ValueDate|IsReverse|Adet
---------|---------|----
2026-09-26|1|1
2026-09-25|0|4
2026-09-25|1|3
```

### S-37 — çıktı (ham)
```
2026-09-16 st=all skip=0 take=all items=3 total=3 NR=1 NRev=0 R=2 old=7356ms new=269ms EQUAL
2026-09-16 st=all skip=2 take=5 items=1 total=3 NR=1 NRev=0 R=2 old=84ms new=47ms EQUAL
2026-09-16 st=1 skip=0 take=all items=1 total=1 NR=1 NRev=0 R=0 old=156ms new=47ms EQUAL
2026-09-16 st=3 skip=0 take=all items=0 total=0 NR=0 NRev=0 R=0 old=131ms new=25ms EQUAL
2026-09-16 st=4 skip=0 take=all items=2 total=2 NR=0 NRev=0 R=2 old=155ms new=52ms EQUAL
2026-09-15 st=all skip=0 take=all items=3 total=3 NR=2 NRev=0 R=1 old=97ms new=45ms EQUAL
2026-09-15 st=all skip=2 take=5 items=1 total=3 NR=2 NRev=0 R=1 old=80ms new=41ms EQUAL
2026-09-15 st=1 skip=0 take=all items=2 total=2 NR=2 NRev=0 R=0 old=51ms new=45ms EQUAL
2026-09-15 st=3 skip=0 take=all items=0 total=0 NR=0 NRev=0 R=0 old=35ms new=24ms EQUAL
2026-09-15 st=4 skip=0 take=all items=1 total=1 NR=0 NRev=0 R=1 old=44ms new=46ms EQUAL
2026-09-17 st=all skip=0 take=all items=3 total=3 NR=3 NRev=0 R=0 old=94ms new=36ms EQUAL
2026-09-17 st=all skip=2 take=5 items=1 total=3 NR=3 NRev=0 R=0 old=82ms new=37ms EQUAL
2026-09-17 st=1 skip=0 take=all items=3 total=3 NR=3 NRev=0 R=0 old=65ms new=43ms EQUAL
2026-09-17 st=3 skip=0 take=all items=0 total=0 NR=0 NRev=0 R=0 old=43ms new=17ms EQUAL
2026-09-17 st=4 skip=0 take=all items=0 total=0 NR=0 NRev=0 R=0 old=41ms new=23ms EQUAL
2026-09-22 st=all skip=0 take=all items=3 total=3 NR=3 NRev=0 R=0 old=102ms new=39ms EQUAL
2026-09-22 st=all skip=2 take=5 items=1 total=3 NR=3 NRev=0 R=0 old=83ms new=37ms EQUAL
2026-09-22 st=1 skip=0 take=all items=3 total=3 NR=3 NRev=0 R=0 old=59ms new=38ms EQUAL
2026-09-22 st=3 skip=0 take=all items=0 total=0 NR=0 NRev=0 R=0 old=41ms new=21ms EQUAL
2026-09-22 st=4 skip=0 take=all items=0 total=0 NR=0 NRev=0 R=0 old=35ms new=19ms EQUAL
2026-09-09 st=all skip=0 take=all items=3 total=3 NR=2 NRev=0 R=1 old=87ms new=52ms EQUAL
2026-09-09 st=all skip=2 take=5 items=1 total=3 NR=2 NRev=0 R=1 old=104ms new=40ms EQUAL
2026-09-09 st=1 skip=0 take=all items=2 total=2 NR=2 NRev=0 R=0 old=67ms new=44ms EQUAL
2026-09-09 st=3 skip=0 take=all items=0 total=0 NR=0 NRev=0 R=0 old=32ms new=18ms EQUAL
2026-09-09 st=4 skip=0 take=all items=1 total=1 NR=0 NRev=0 R=1 old=39ms new=40ms EQUAL
2026-09-28 st=all skip=0 take=all items=3 total=3 NR=3 NRev=0 R=0 old=92ms new=40ms EQUAL
2026-09-28 st=all skip=2 take=5 items=1 total=3 NR=3 NRev=0 R=0 old=87ms new=49ms EQUAL
2026-09-28 st=1 skip=0 take=all items=3 total=3 NR=3 NRev=0 R=0 old=59ms new=48ms EQUAL
2026-09-28 st=3 skip=0 take=all items=0 total=0 NR=0 NRev=0 R=0 old=38ms new=22ms EQUAL
2026-09-28 st=4 skip=0 take=all items=0 total=0 NR=0 NRev=0 R=0 old=31ms new=16ms EQUAL
DONE cases=30 fails=0
```
**Yorum:** 30/30 EŞİT.

### S-38 — çıktı (ham)
```
2026-09-25 st=all skip=0 take=all items=1 total=1 NR=0 NRev=0 R=1 old=10949ms new=485ms EQUAL
2026-09-25 st=all skip=2 take=5 items=0 total=1 NR=0 NRev=0 R=1 old=105ms new=17ms EQUAL
2026-09-25 st=1 skip=0 take=all items=0 total=0 NR=0 NRev=0 R=0 old=278ms new=19ms EQUAL
2026-09-25 st=3 skip=0 take=all items=0 total=0 NR=0 NRev=0 R=0 old=283ms new=26ms EQUAL
2026-09-25 st=4 skip=0 take=all items=1 total=1 NR=0 NRev=0 R=1 old=269ms new=53ms EQUAL
2026-09-26 st=all skip=0 take=all items=1 total=1 NR=1 NRev=0 R=0 old=105ms new=43ms EQUAL
2026-09-26 st=all skip=2 take=5 items=0 total=1 NR=1 NRev=0 R=0 old=94ms new=15ms EQUAL
2026-09-26 st=1 skip=0 take=all items=1 total=1 NR=1 NRev=0 R=0 old=67ms new=56ms EQUAL
2026-09-26 st=3 skip=0 take=all items=0 total=0 NR=0 NRev=0 R=0 old=77ms new=24ms EQUAL
2026-09-26 st=4 skip=0 take=all items=0 total=0 NR=0 NRev=0 R=0 old=87ms new=24ms EQUAL
2026-09-24 st=all skip=0 take=all items=0 total=0 NR=0 NRev=0 R=0 old=89ms new=17ms EQUAL
2026-09-24 st=all skip=2 take=5 items=0 total=0 NR=0 NRev=0 R=0 old=107ms new=17ms EQUAL
2026-09-24 st=1 skip=0 take=all items=0 total=0 NR=0 NRev=0 R=0 old=73ms new=16ms EQUAL
2026-09-24 st=3 skip=0 take=all items=0 total=0 NR=0 NRev=0 R=0 old=72ms new=20ms EQUAL
2026-09-24 st=4 skip=0 take=all items=0 total=0 NR=0 NRev=0 R=0 old=70ms new=14ms EQUAL
2026-09-28 st=all skip=0 take=all items=0 total=0 NR=0 NRev=0 R=0 old=88ms new=13ms EQUAL
2026-09-28 st=all skip=2 take=5 items=0 total=0 NR=0 NRev=0 R=0 old=106ms new=20ms EQUAL
2026-09-28 st=1 skip=0 take=all items=0 total=0 NR=0 NRev=0 R=0 old=81ms new=14ms EQUAL
2026-09-28 st=3 skip=0 take=all items=0 total=0 NR=0 NRev=0 R=0 old=73ms new=18ms EQUAL
2026-09-28 st=4 skip=0 take=all items=0 total=0 NR=0 NRev=0 R=0 old=77ms new=17ms EQUAL
DONE cases=20 fails=0
```

### S-39 — çıktı (ham; Db|Txn|Reeskont|SonReeskont)
```
NetTrexOPTFX_134|21|0|NULL
NetTrexOptFx_136|100|0|NULL
NetTrexOptFx_136_Test|98|0|NULL
NetTrexOptFX_135|25|0|NULL
NetTrexOPTFX_Dev|18|0|NULL
NetTrexOptFX_UAT|2|0|NULL
```

### S-40 — çıktı (ham)
```
2026-03-01 st=all skip=0 take=all items=0 total=0 NR=0 NRev=0 R=0 old=9862ms new=167ms EQUAL
2026-03-01 st=all skip=2 take=5 items=0 total=0 NR=0 NRev=0 R=0 old=147ms new=38ms EQUAL
2026-03-01 st=1 skip=0 take=all items=0 total=0 NR=0 NRev=0 R=0 old=459ms new=20ms EQUAL
2026-03-01 st=3 skip=0 take=all items=0 total=0 NR=0 NRev=0 R=0 old=360ms new=16ms EQUAL
2026-03-01 st=4 skip=0 take=all items=0 total=0 NR=0 NRev=0 R=0 old=733ms new=254ms EQUAL
2026-06-01 st=all skip=0 take=all items=5 total=5 NR=5 NRev=0 R=0 old=881ms new=1361ms EQUAL
2026-06-01 st=all skip=2 take=5 items=3 total=5 NR=5 NRev=0 R=0 old=296ms new=381ms EQUAL
2026-06-01 st=1 skip=0 take=all items=5 total=5 NR=5 NRev=0 R=0 old=478ms new=113ms EQUAL
2026-06-01 st=3 skip=0 take=all items=0 total=0 NR=0 NRev=0 R=0 old=123ms new=40ms EQUAL
2026-06-01 st=4 skip=0 take=all items=0 total=0 NR=0 NRev=0 R=0 old=130ms new=26ms EQUAL
2026-08-11 st=all skip=0 take=all items=2 total=2 NR=2 NRev=0 R=0 old=227ms new=92ms EQUAL
2026-08-11 st=all skip=2 take=5 items=0 total=2 NR=2 NRev=0 R=0 old=160ms new=52ms EQUAL
2026-08-11 st=1 skip=0 take=all items=2 total=2 NR=2 NRev=0 R=0 old=143ms new=149ms EQUAL
2026-08-11 st=3 skip=0 take=all items=0 total=0 NR=0 NRev=0 R=0 old=143ms new=59ms EQUAL
2026-08-11 st=4 skip=0 take=all items=0 total=0 NR=0 NRev=0 R=0 old=139ms new=319ms EQUAL
2026-09-01 st=all skip=0 take=all items=0 total=0 NR=0 NRev=0 R=0 old=622ms new=149ms EQUAL
2026-09-01 st=all skip=2 take=5 items=0 total=0 NR=0 NRev=0 R=0 old=429ms new=55ms EQUAL
2026-09-01 st=1 skip=0 take=all items=0 total=0 NR=0 NRev=0 R=0 old=206ms new=46ms EQUAL
2026-09-01 st=3 skip=0 take=all items=0 total=0 NR=0 NRev=0 R=0 old=155ms new=44ms EQUAL
2026-09-01 st=4 skip=0 take=all items=0 total=0 NR=0 NRev=0 R=0 old=518ms new=16ms EQUAL
2026-09-28 st=all skip=0 take=all items=0 total=0 NR=0 NRev=0 R=0 old=159ms new=36ms EQUAL
2026-09-28 st=all skip=2 take=5 items=0 total=0 NR=0 NRev=0 R=0 old=141ms new=19ms EQUAL
2026-09-28 st=1 skip=0 take=all items=0 total=0 NR=0 NRev=0 R=0 old=105ms new=60ms EQUAL
2026-09-28 st=3 skip=0 take=all items=0 total=0 NR=0 NRev=0 R=0 old=128ms new=39ms EQUAL
2026-09-28 st=4 skip=0 take=all items=0 total=0 NR=0 NRev=0 R=0 old=70ms new=17ms EQUAL
DONE cases=25 fails=0
```

### S-41 — çıktı (ham)
```
Msg 144, Level 15, State 1, Server srv-mssql, Line 1
Cannot use an aggregate or a subquery in an expression used for the group by list of a GROUP BY clause.
```

### S-41 — çıktı: Msg 144 (aggregate/subquery GROUP BY'da kullanılamaz)

### S-42 — çıktı (ham)
```
IsReverse|BacaktaReverseIdVar|Adet
---------|-------------------|----
0|0|2165
0|1|9
1|0|39
1|1|2041
```

### S-DS-01 — çıktı (ham)
```
IsReverse|MainReversed|LegHasReverseId|Adet
---------|------------|---------------|----
0|0|0|308
0|1|0|220
0|1|1|8
1|1|1|227
```

### S-DS-02 — çıktı (ham)
```
Id|TxnId|VD|ReverseId|LegId|LegRev|SrcMain|SrcIsRev|SrcTxn|SrcVD|SrcRev|SrcRevVD|MirrorRevVD
--|-----|--|---------|-----|------|-------|--------|------|-----|------|--------|-----------
881170|88169|2026-09-16|881171|882880|882868|881164|0|88169|2026-09-16|881165|2026-09-17|2026-09-17
881170|88169|2026-09-16|881171|882879|882867|881164|0|88169|2026-09-16|881165|2026-09-17|2026-09-17
881166|88164|2026-09-16|881167|882872|882808|881134|0|88164|2026-09-16|881135|2026-09-17|2026-09-17
881166|88164|2026-09-16|881167|882871|882807|881134|0|88164|2026-09-16|881135|2026-09-17|2026-09-17
881159|88169|2026-09-16|881160|882858|882854|881157|0|88169|2026-09-16|881158|2026-09-17|2026-09-17
881159|88169|2026-09-16|881160|882857|882853|881157|0|88169|2026-09-16|881158|2026-09-17|2026-09-17
881155|88169|2026-09-16|881156|882850|882846|881153|0|88169|2026-09-16|881154|2026-09-17|2026-09-17
881155|88169|2026-09-16|881156|882849|882845|881153|0|88169|2026-09-16|881154|2026-09-17|2026-09-17
881151|88169|2026-09-16|881152|882842|882824|881142|0|88169|2026-09-16|881143|2026-09-17|2026-09-17
881151|88169|2026-09-16|881152|882841|882823|881142|0|88169|2026-09-16|881143|2026-09-17|2026-09-17
881140|88169|2026-09-16|881141|882820|882816|881138|0|88169|2026-09-16|881139|2026-09-17|2026-09-17
881140|88169|2026-09-16|881141|882819|882815|881138|0|88169|2026-09-16|881139|2026-09-17|2026-09-17
881137|88169|2026-09-16|881150|882814|882798|881129|0|88169|2026-09-16|881136|2026-09-17|2026-09-22
881137|88169|2026-09-16|881150|882813|882797|881129|0|88169|2026-09-16|881136|2026-09-17|2026-09-22
881133|88164|2026-09-16|881149|882806|882802|881131|0|88164|2026-09-16|881132|2026-09-17|2026-09-22
881133|88164|2026-09-16|881149|882805|882801|881131|0|88164|2026-09-16|881132|2026-09-17|2026-09-22
```
Bulgu: 8 ayna adayının tüm bacakları aynı işlem/aynı gündeki ters-olmayan kaynak reeskontun bacaklarını gösteriyor; normal (terslenmiş) reeskontlarda bacak ReverseId boş (S-DS-01: 220 satır). İşaret DerivSwp'de de geçerli.

### S-OF-01 — çıktı (NetTrexOPTFX)
```
IsReverse|MainReversed|LegHasReverseId|Adet
---------|------------|---------------|----
0|1|0|4
1|1|1|4
```
Bulgu: Ters olmayan (normal, terslenmiş) 4 reeskontun hiçbir bacağında ReverseId dolu değil; ReverseId yalnız ters fiş (IsReverse=1) bacaklarında dolu (AccountingReverseReverseFactory). Bu DB'de ayna fiş hiç yok (Regenerate hiç çalışmamış). Kod: BuildMirror ayna bacaklarına ReverseId = kaynak bacak Id yazar ve ayna IsReverse=0 → "ters olmayan reeskontun bacağında ReverseId != null && != 0 → ayna" işareti OptionsFX'te geçerli (MM/DerivSwp ile aynı).

### S-FX-01 — çıktı
```
IsReverse|DescKind|LegHasReverseId|Adet
---------|--------|---------------|----
0|OTHER|0|5860
1|OTHER|0|79
1|OTHER|1|212
1|REVERSE|0|5132
1|REVERSE|1|427
```
**Bulgu:** FX_Dev'de "İptal Fiş:" / "Cancellation:" önekli hiçbir reeskont fişi yok (ayna hiç kesilmemiş ya da önek farklı). Ters olmayan reeskontların hiçbirinin bacağında ReverseId yok.

### S-FX-02 — çıktı (20 satır, TOP 20)
```
Id|TxnId|VD|ReverseId|StateId|ProductCode|Descr
--|-----|--|---------|-------|-----------|-----
1113983|33758|2026-02-04|1114132|18|PM|TPMSP26020400263 referansli Yabanci Para Akbank A.S. ile yapilan SPOT 41 XAU ali
1113982|33757|2026-02-04|1114131|18|PM|TPMSP26020400262 referansli Yabanci Para Akbank A.S. ile yapilan SPOT 206,324 US
1113981|33756|2026-02-04|1114130|18|PM|TPMSP26020400261 referansli Yabanci Para Akbank A.S. ile yapilan SPOT 41 XAU ali
1113980|33755|2026-02-04|1114129|18|PM|TPMSP26020400260 referansli Yabanci Para Akbank A.S. ile yapilan SPOT 47 XAU ali
1113979|33754|2026-02-04|1114128|18|PM|TPMSP26020400259 referansli Yabanci Para Akbank A.S. ile yapilan SPOT 236,511 US
1113978|33753|2026-02-04|1114127|18|PM|TPMSP26020400258 referansli Yabanci Para Akbank A.S. ile yapilan SPOT 47 XAU ali
1113977|33752|2026-02-04|1114126|18|PM|TPMSP26020400257 referansli Yabanci Para Akbank A.S. ile yapilan SPOT 236,508 US
1113976|33751|2026-02-04|1114125|18|PM|TPMSP26020400256 referansli Yabanci Para Akbank A.S. ile yapilan SPOT 47 XAU ali
1113975|33750|2026-02-04|1114124|18|PM|TPMSP26020400255 referansli Yabanci Para Akbank A.S. ile yapilan SPOT 236,508 US
1113974|33749|2026-02-04|1114123|18|PM|TPMSP26020400254 referansli Yabanci Para Akbank A.S. ile yapilan SPOT 47 XAU ali
1113973|33748|2026-02-04|1114122|18|PM|TPMSP26020400253 referansli Yabanci Para Akbank A.S. ile yapilan SPOT 236,505 US
1113972|33732|2026-02-04|1114121|18|PM|TPMSP26020400237 referansli Yabanci Para Akbank A.S. ile yapilan SPOT 46 XAU ali
1113971|33731|2026-02-04|1114120|18|PM|TPMSP26020400236 referansli Yabanci Para Akbank A.S. ile yapilan SPOT 231,437 US
1113970|33730|2026-02-04|1114119|18|PM|TPMSP26020400235 referansli Yabanci Para Akbank A.S. ile yapilan SPOT 46 XAU ali
1113969|33729|2026-02-04|1114118|18|PM|TPMSP26020400234 referansli Yabanci Para Akbank A.S. ile yapilan SPOT 231,443 US
1113968|33728|2026-02-04|1114117|18|PM|TPMSP26020400233 referansli Yabanci Para Akbank A.S. ile yapilan SPOT 46 XAU ali
1113967|33727|2026-02-04|1114116|18|PM|TPMSP26020400232 referansli Yabanci Para Akbank A.S. ile yapilan SPOT 231,443 US
1113966|33726|2026-02-04|1114115|18|PM|TPMSP26020400231 referansli Yabanci Para Akbank A.S. ile yapilan SPOT 46 XAU ali
1113965|33725|2026-02-04|1114114|18|PM|TPMSP26020400230 referansli Yabanci Para Akbank A.S. ile yapilan SPOT 231,443 US
1113964|33724|2026-02-04|1114113|18|PM|TPMSP26020400229 referansli Yabanci Para Akbank A.S. ile yapilan SPOT 10 XAU ali
```
**Bulgu:** Gelen 20 satırın hepsi "aynı gün birden fazla reeskont" (batch tekrarı) kolundan; hiçbiri "İptal/Cancel" içermiyor. Sayım S-FX-03 ile.

### S-FX-03 — çıktı
```
IsReverse|Iptal|Cancel|Toplam
---------|-----|------|------
0|0|0|5860
1|0|0|5850
```
**Bulgu:** FX_Dev'de hiç ayna (DoForward) fişi yok — "İptal Fiş:" / "Cancellation:" işareti gerçek veriyle DOĞRULANAMADI.

### S-FX-04 — çıktı
```
ProductCode|Adet
-----------|----
PM|5626
FX|146
SWAPPM|44
SWAPFX|44
```
**Bulgu:** Native reeskontlar ProductCode ile ayrışıyor (NULL yok). External (Fimple FWD/SWP) reeskont fişi FX_Dev'de hiç yok → External ProductCode doğrulanamadı; Execute'ta External için listelemeyle aynı (ProductCode'suz) kural korunur.

### S-43 — çıktı (ham, satır başı 330)
```
LOAN 2026-09-28 st=all skip=0 take=all items=10 total=10 NR=10 NRev=0 R=0 mirror=0 pending=0 old=883ms new=551ms EQUAL
LOAN 2026-09-28 st=1 skip=0 take=all items=10 total=10 NR=10 NRev=0 R=0 mirror=0 pending=0 old=543ms new=83ms EQUAL
LOAN 2026-09-28 st=3 skip=0 take=all items=0 total=0 NR=0 NRev=0 R=0 mirror=0 pending=0 old=157ms new=41ms EQUAL
LOAN 2026-09-28 st=4 skip=0 take=all items=0 total=0 NR=0 NRev=0 R=0 mirror=0 pending=0 old=132ms new=33ms EQUAL
LOAN 2026-09-22 st=all skip=0 take=all items=11 total=11 NR=11 NRev=0 R=0 mirror=0 pending=0 old=260ms new=86ms EQUAL
LOAN 2026-09-22 st=1 skip=0 take=all items=11 total=11 NR=11 NRev=0 R=0 mirror=0 pending=0 old=200ms new=88ms EQUAL
LOAN 2026-09-22 st=3 skip=0 take=all items=0 total=0 NR=0 NRev=0 R=0 mirror=0 pending=0 old=105ms new=33ms EQUAL
LOAN 2026-09-22 st=4 skip=0 take=all items=0 total=0 NR=0 NRev=0 R=0 mirror=0 pending=0 old=83ms new=36ms EQUAL
LOAN 2026-09-23 st=all skip=0 take=all items=10 total=10 NR=10 NRev=0 R=0 mirror=0 pending=0 old=268ms new=85ms EQUAL
LOAN 2026-09-23 st=1 skip=0 take=all items=10 total=10 NR=10 NRev=0 R=0 mirror=0 pending=0 old=211ms new=87ms EQUAL
LOAN 2026-09-23 st=3 skip=0 take=all items=0 total=0 NR=0 NRev=0 R=0 mirror=0 pending=0 old=107ms new=34ms EQUAL
LOAN 2026-09-23 st=4 skip=0 take=all items=0 total=0 NR=0 NRev=0 R=0 mirror=0 pending=0 old=78ms new=35ms EQUAL
LOAN 2026-09-27 st=all skip=0 take=all items=10 total=10 NR=10 NRev=0 R=0 mirror=0 pending=0 old=275ms new=84ms EQUAL
LOAN 2026-09-27 st=1 skip=0 take=all items=10 total=10 NR=10 NRev=0 R=0 mirror=0 pending=0 old=215ms new=84ms EQUAL
LOAN 2026-09-27 st=3 skip=0 take=all items=0 total=0 NR=0 NRev=0 R=0 mirror=0 pending=0 old=118ms new=34ms EQUAL
LOAN 2026-09-27 st=4 skip=0 take=all items=0 total=0 NR=0 NRev=0 R=0 mirror=0 pending=0 old=340ms new=39ms EQUAL
MM 2026-09-28 st=3 skip=0 take=all items=0 total=0 NR=0 NRev=0 R=0 mirror=0 pending=0 old=654ms new=348ms EQUAL
MM 2026-09-28 st=4 skip=0 take=all items=0 total=0 NR=0 NRev=0 R=0 mirror=0 pending=0 old=580ms new=136ms DIFF
   counts old: 1/0/0/1 items 1
MM 2026-09-22 st=3 skip=0 take=all items=0 total=0 NR=0 NRev=0 R=0 mirror=0 pending=0 old=505ms new=70ms EQUAL
MM 2026-09-22 st=4 skip=0 take=all items=1 total=1 NR=0 NRev=0 R=1 mirror=0 pending=0 old=437ms new=476ms EQUAL
MM 2026-09-23 st=3 skip=0 take=all items=0 total=0 NR=0 NRev=0 R=0 mirror=0 pending=0 old=495ms new=304ms EQUAL
MM 2026-09-23 st=4 skip=0 take=all items=0 total=0 NR=0 NRev=0 R=0 mirror=0 pending=0 old=394ms new=64ms DIFF
   counts old: 1/0/0/1 items 1
MM 2026-09-16 st=3 skip=0 take=all items=0 total=0 NR=0 NRev=0 R=0 mirror=0 pending=0 old=458ms new=72ms EQUAL
MM 2026-09-16 st=4 skip=0 take=all items=0 total=0 NR=0 NRev=0 R=0 mirror=0 pending=0 old=382ms new=63ms EQUAL
MM 2026-09-15 st=3 skip=0 take=all items=1 total=1 NR=0 NRev=1 R=0 mirror=0 pending=0 old=530ms new=212ms EQUAL
MM 2026-09-15 st=4 skip=0 take=all items=0 total=0 NR=0 NRev=0 R=0 mirror=0 pending=0 old=438ms new=85ms DIFF
   counts old: 2/0/0/2 items 2
MM 2026-09-28 st=all skip=10 take=25 items=25 total=3006 NR=3006 NRev=0 R=0 mirror=0 pending=0 old=1675ms new=128ms DIFF
   counts old: 3006/3005/0/1 items 25
MM 2026-09-28 st=1 skip=3000 take=50 items=6 total=3006 NR=3006 NRev=0 R=0 mirror=1 pending=0 old=784ms new=168ms DIFF
   counts old: 3005/3005/0/0 items 5
   OLD {"TransactionId":553397,"LogicalReference":"TMMPLC2609240001","ProductTypeId":1,"ProductName":"Money Market","ExternalCustomerId":27106,"ExternalCustomerName":"Akbank A.\u015E.","RediscountReverseId":null,"ReverseValueDate":null,"TxnTypeCode":"PLC","DirectionName":"Placement","Ccy":"TRY","PrincipalAmount":1000000,"Interes
   NEW {"TransactionId":553398,"LogicalReference":"TMMPLC2609280001","ProductTypeId":1,"ProductName":"Money Market","ExternalCustomerId":27106,"ExternalCustomerName":"Akbank A.\u015E.","RediscountReverseId":556110,"ReverseValueDate":"2026-09-29T00:00:00","TxnTypeCode":"PLC","DirectionName":"Placement","Ccy":"TRY","PrincipalAmoun
MM 2026-09-28 st=all skip=0 take=all items=3006 total=3006 NR=3006 NRev=0 R=0 mirror=1 pending=0 old=70742ms new=11720ms DIFF
   counts old: 3006/3005/0/1 items 3006
DONE fails=6
```
**Yorum:** Ayna olmayan tüm vakalar EŞİT. DIFF'ler yalnız en son fişi tersi olan AYNA olan günler (9/15, 9/23, 9/28): eski Rediscounted sayıyordu, yeni NotRediscounted (gün net 0) — tasarım gereği. Tam liste yeni sürede 11,7 sn: ayna sorgusu yavaş, S-44'te ölçülecek.

### S-44 — çıktı: harness derleme hatası nedeniyle ilk koşu geçersiz; ikinci koşu: toplam ~13,3 sn — yavaş olan iki valuation SELECT'i (~6 sn/adet), ayna sorgusu 16-24 ms.

### S-45 — çıktı (ham, kırpıldı)
```
run0 total=3922ms items=3006
   Executed DbCommand (80ms) [Param | SELECT [t].[Id]       FROM [TxnMM] AS [t]       INNER JOIN [prdProductDefinition
   Executed DbCommand (32ms) [Param | SELECT [a1].[TxnId], [a1].[Id], [a1].[ReverseId], [a1].[MessageKey], (           
   Executed DbCommand (372ms) [Para | SELECT [t].[Id], [t].[LogicalReference], [t].[TxnMmProductTypeId], [p].[Name] AS [
   Executed DbCommand (65ms) [Param | SELECT [t2].[TxnId], [t2].[Id], [t2].[InterestRate], [t2].[PeriodStartDate], [t2].
   Executed DbCommand (39ms) [Param | SELECT [t2].[TxnMmId] AS [TxnId], COALESCE(SUM([t2].[AccrualAmount]), 0.0) AS [Acc
   Executed DbCommand (34ms) [Param | SELECT [t2].[TxnMmId], [t2].[Id], [t2].[AccrualAmount], [t2].[AccrualDay], [t2].[A
run1 total=4181ms items=3006
   Executed DbCommand (63ms) [Param | SELECT [t].[Id]       FROM [TxnMM] AS [t]       INNER JOIN [prdProductDefinition
   Executed DbCommand (50ms) [Param | SELECT [a1].[TxnId], [a1].[Id], [a1].[ReverseId], [a1].[MessageKey], (           
   Executed DbCommand (63ms) [Param | SELECT [t].[Id], [t].[LogicalReference], [t].[TxnMmProductTypeId], [p].[Name] AS [
   Executed DbCommand (56ms) [Param | SELECT [t2].[TxnId], [t2].[Id], [t2].[InterestRate], [t2].[PeriodStartDate], [t2].
   Executed DbCommand (53ms) [Param | SELECT [t2].[TxnMmId] AS [TxnId], COALESCE(SUM([t2].[AccrualAmount]), 0.0) AS [Acc
   Executed DbCommand (35ms) [Param | SELECT [t2].[TxnMmId], [t2].[Id], [t2].[AccrualAmount], [t2].[AccrualDay], [t2].[A
```
**Yorum:** 6 SELECT toplam ~0,3 sn. S-44'teki 6 sn'lik valuation süreleri geçici (eşzamanlı ajan sorguları). Toplam ~4 sn EF loglama açıkken.

### S-46 — çıktı (ham, kırpıldı)
```
LOAN 2026-09-28 st=all skip=0 take=all items=10 total=10 NR=10 NRev=0 R=0 mirror=0 pending=0 old=1442ms new=657ms EQUAL
LOAN 2026-09-28 st=1 skip=0 take=all items=10 total=10 NR=10 NRev=0 R=0 mirror=0 pending=0 old=395ms new=170ms EQUAL
LOAN 2026-09-28 st=3 skip=0 take=all items=0 total=0 NR=0 NRev=0 R=0 mirror=0 pending=0 old=430ms new=33ms EQUAL
LOAN 2026-09-28 st=4 skip=0 take=all items=0 total=0 NR=0 NRev=0 R=0 mirror=0 pending=0 old=164ms new=299ms EQUAL
LOAN 2026-09-22 st=all skip=0 take=all items=11 total=11 NR=11 NRev=0 R=0 mirror=0 pending=0 old=461ms new=176ms EQUAL
LOAN 2026-09-22 st=1 skip=0 take=all items=11 total=11 NR=11 NRev=0 R=0 mirror=0 pending=0 old=286ms new=153ms EQUAL
LOAN 2026-09-22 st=3 skip=0 take=all items=0 total=0 NR=0 NRev=0 R=0 mirror=0 pending=0 old=155ms new=45ms EQUAL
LOAN 2026-09-22 st=4 skip=0 take=all items=0 total=0 NR=0 NRev=0 R=0 mirror=0 pending=0 old=141ms new=36ms EQUAL
LOAN 2026-09-23 st=all skip=0 take=all items=10 total=10 NR=10 NRev=0 R=0 mirror=0 pending=0 old=361ms new=173ms EQUAL
LOAN 2026-09-23 st=1 skip=0 take=all items=10 total=10 NR=10 NRev=0 R=0 mirror=0 pending=0 old=314ms new=126ms EQUAL
LOAN 2026-09-23 st=3 skip=0 take=all items=0 total=0 NR=0 NRev=0 R=0 mirror=0 pending=0 old=148ms new=54ms EQUAL
LOAN 2026-09-23 st=4 skip=0 take=all items=0 total=0 NR=0 NRev=0 R=0 mirror=0 pending=0 old=295ms new=58ms EQUAL
LOAN 2026-09-27 st=all skip=0 take=all items=10 total=10 NR=10 NRev=0 R=0 mirror=0 pending=0 old=360ms new=174ms EQUAL
LOAN 2026-09-27 st=1 skip=0 take=all items=10 total=10 NR=10 NRev=0 R=0 mirror=0 pending=0 old=543ms new=178ms EQUAL
LOAN 2026-09-27 st=3 skip=0 take=all items=0 total=0 NR=0 NRev=0 R=0 mirror=0 pending=0 old=291ms new=303ms EQUAL
LOAN 2026-09-27 st=4 skip=0 take=all items=0 total=0 NR=0 NRev=0 R=0 mirror=0 pending=0 old=96ms new=46ms EQUAL
MM 2026-09-28 st=3 skip=0 take=all items=0 total=0 NR=0 NRev=0 R=0 mirror=0 pending=0 old=556ms new=111ms EQUAL
MM 2026-09-28 st=4 skip=0 take=all items=1 total=1 NR=0 NRev=0 R=1 mirror=0 pending=0 old=454ms new=278ms EQUAL
MM 2026-09-22 st=3 skip=0 take=all items=0 total=0 NR=0 NRev=0 R=0 mirror=0 pending=0 old=481ms new=505ms EQUAL
MM 2026-09-22 st=4 skip=0 take=all items=1 total=1 NR=0 NRev=0 R=1 mirror=0 pending=0 old=495ms new=230ms EQUAL
MM 2026-09-23 st=3 skip=0 take=all items=0 total=0 NR=0 NRev=0 R=0 mirror=0 pending=0 old=551ms new=64ms EQUAL
MM 2026-09-23 st=4 skip=0 take=all items=1 total=1 NR=0 NRev=0 R=1 mirror=0 pending=0 old=512ms new=204ms EQUAL
MM 2026-09-16 st=3 skip=0 take=all items=0 total=0 NR=0 NRev=0 R=0 mirror=0 pending=0 old=605ms new=385ms EQUAL
MM 2026-09-16 st=4 skip=0 take=all items=0 total=0 NR=0 NRev=0 R=0 mirror=0 pending=0 old=592ms new=131ms EQUAL
MM 2026-09-15 st=3 skip=0 take=all items=1 total=1 NR=0 NRev=1 R=0 mirror=0 pending=0 old=596ms new=336ms EQUAL
MM 2026-09-15 st=4 skip=0 take=all items=2 total=2 NR=0 NRev=0 R=2 mirror=0 pending=0 old=604ms new=1148ms EQUAL
MM 2026-09-28 st=all skip=10 take=25 items=25 total=3006 NR=3005 NRev=0 R=1 mirror=0 pending=0 old=2120ms new=291ms EQUAL
MM 2026-09-28 st=1 skip=3000 take=50 items=5 total=3005 NR=3005 NRev=0 R=0 mirror=0 pending=0 old=1082ms new=167ms EQUAL
MM 2026-09-28 st=all skip=0 take=all items=3006 total=3006 NR=3005 NRev=0 R=1 mirror=0 pending=0 old=75318ms new=876ms EQUAL
DONE fails=0
```
**Yorum:** 29/29 EŞİT. MM tam liste 3006 satır: eski 75318 ms → yeni 876 ms.
