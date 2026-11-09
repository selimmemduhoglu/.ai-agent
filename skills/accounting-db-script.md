# Skill — accounting-db-script

**Ne zaman tetiklenir:** Muhasebe (accounting) tarafıyla ilgili **her** iş — sorgu, script, kural analizi,
GL/fiş sorusu, yeni ürün/politika muhasebesi.
Tetikleyici kelimeler: *muhasebe · accounting · GL · fiş · ters fiş · reeskont kuralı ·
`AccEngine*` · `AccEntryMain` · `AccAccountMap` · `DefNumberGen` · muhasebe scripti · BRWPLC ·
ItemCode · AccountRule · component type · muhasebe kuralı ekle/sil*

**Tür:** Analiz + Script üretimi · **Kapsam:** cross-repo (`NetTrex.MM` merkezli, DB `NetTrexAcc`)

---

## ADIM 0 — ÖNCE BUNU OKU (atlama)

```text
NetTrex.MM/.ai-agent/feature-research/Accounting-Engine-research.md
```

Motorun yapısı, tablo zinciri, `DefNumberGen`, script anatomisi, gerçek `Revaluation` GL kuralı,
**AccAccountMap seçim algoritması (§4.10)** ve **doğrulanmamış maddeler** orada. **Ezberden cevap verme** — bu dosya + DB tek doğru kaynak.

🔴 **Soru Excel / THP / kırılım / "hangi hesaba düşer" ise ikinci ayak** (2026-10-27):

```text
NetTrex.MM/.ai-agent/feature-research/Accounting-Excel-THP-research.md   (Excel anatomisi · THP · kırılım tabloları · tutarsızlıklar)
repos/.ai-agent/skills/accounting-excel-thp.md                          (Excel değişiklik prosedürü + Gotcha E-01…E-10)
```

Yani muhasebe işi **iki bilgi dosyasından** beslenir: motor/DB → `Accounting-Engine-research.md`, Excel/THP → `Accounting-Excel-THP-research.md`.

DB'ye bakman gerekiyorsa → [`mssql-read`](mssql-read.md) skill'i (🔴 yalnız `SELECT`, her sorgu log'lanır).

---

## 1. Zihinsel model — 5 seviyeli zincir

```text
AccEngineItem        ürün/politika ağacı   Path = 'TREX/<POLİTİKA>/<ÜRÜN>/<YÖN>/<...>/<PARA>/'
  └── AccEngineEvent      olay              EventTypeCode = OnOpening | OnRevaluation | OnMaturation | ...
        └── AccEngineGroup                  EventId · Order
              └── AccEngineComponent         GroupId · ComponentTypeCode (510 = Revaluation)
                    └── AccEngineAccountRule ⭐  GLCode · DebitCredit · AmountSource · CcySource ...
```

Yanında bağımsız duran: **`AccAccountMap`** (kendi `Path` kolonu var — zincire join edilmez).

🔴 **Ürün ağacı ≠ politika ağacı.** `TREX/MM/…` altında `OnRevaluation` **yoktur**;
reeskont kuralları `TREX/BRWPLC1/MONEYMARKET|LOAN/{BRW,PLC}/{LCY,FCY}/` altındadır.

---

## 2. 🔴 DEĞİŞMEZ KURALLAR

| # | Kural |
|---|---|
| 1 | **Script'i ASLA çalıştırma.** Yazma içeren SQL `<repo>/.ai-agent/outputs/`'a yazılır, **kullanıcı uygular** |
| 2 | Okuma gerekiyorsa **`mssql-read`** skill'i — yalnız `SELECT`, `TOP (20)`, her sorgu `sql-log/`'a |
| 3 | **Id'ler IDENTITY DEĞİL** — `DefNumberGen`'den rezerve edilir, script sonunda **sayaç güncellenir** |
| 4 | Her `INSERT` **`IF NOT EXISTS`** ile sarılır; Id **yalnız insert olduysa** artar |
| 5 | Script `BEGIN TRANSACTION` + `TRY/CATCH` + `ROLLBACK` iskeletiyle yazılır |
| 6 | Her adımdan sonra `PRINT ... + CAST(@@ROWCOUNT AS VARCHAR)` |
| 7 | 🔴 **`USE [<DB>]` satırında varyantı doğrula** — `NetTrexAcc` ≠ `NetTrexAcc_Dev` ≠ `NetTrexAcc_134_Test_Selim`. **Canlı DB adı yazma** |
| 8 | Silme **yaprak→kök** sırasıyla; `AccEngineItem`'da **önce çocuklar, sonra kök** |
| 9 | Her şey `Path LIKE 'TREX/<POLİTİKA>%'` çapasına dayanır — çapayı daraltmadan silme |

---

## 3. Id rezervasyonu (`DefNumberGen`)

| `EntityColumnType` | `Definition` |
|---|---|
| 1 | `AccEngineDynamicRule Id` |
| 2 | `AccEngineAccountRule Id` |
| 3 | `AccEngineComponent Id` |
| 4 | `AccEngineGroup Id` |
| 5 | `AccEngineEvent Id` |
| 6 | `AccEngineComponentAccount Id` |
| 7 | `AccEngineItem Id` |
| 8 | `AccEngineItemCode Id` |
| 9 | `AccEngineItemType Id` |
| 10 | `AccEngineModelDefinition Id` |
| 11 | `AccAccountMap Id` |

```sql
-- Başta oku
SELECT @lastAccEngineAccountRuleId = LastNumber + 1
FROM dbo.DefNumberGen
WHERE EntityColumnType = 2 AND Definition = N'AccEngineAccountRule Id'
IF (@lastAccEngineAccountRuleId = 0) THROW 500001, 'AccEngineAccountRule Last Id Not Found', 1

-- Sonda güncelle  🔴 UNUTULURSA SONRAKİ ÇALIŞTIRMA PK ÇAKIŞTIRIR
UPDATE dbo.DefNumberGen
SET LastNumber = @lastAccEngineAccountRuleId, LastUpdateDate = GETDATE()
WHERE EntityColumnType = 2 AND Definition = N'AccEngineAccountRule Id';
```

---

## 4. Script iskeleti (kopyala)

```sql
USE [<DB-VARYANTI>];   -- 🔴 doğrula
GO
BEGIN TRANSACTION;
BEGIN TRY
    DECLARE @stateMaker NVARCHAR(50) = N'SYSTEM',
            @stateDate  DATETIME     = GETDATE(),
            @StateId    INT          = 18,
            @lastXId    INT          = 0;
    DECLARE @tempTable TABLE (Id INT);

    -- 1) DefNumberGen oku (+THROW)
    -- 2) IF NOT EXISTS + INSERT ... OUTPUT inserted.Id INTO @tempTable
    --    SELECT @xId = Id FROM @tempTable; DELETE FROM @tempTable
    --    SELECT @lastXId = @lastXId + 1
    -- 3) DefNumberGen güncelle

    COMMIT TRANSACTION;
    PRINT '✅ tamamlandı';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    PRINT '❌ Hata: ' + ERROR_MESSAGE();
    PRINT 'Satır: ' + CAST(ERROR_LINE() AS VARCHAR);
END CATCH
```

`StateId = 18` · `StateMaker = 'SYSTEM'` üretim scriptlerinde kullanılan değerler.

---

## 4.9 🔴 SILME YUZEYI - olculdu 2026-09-10 (`sql-log/accengine-policy-silme`)

Bir politika agacini (`TREX/<KOD>/`) silerken **dokunulacak** ve **dokunulmayacak** tablolar:

| Silinir | Nasil |
|---|---|
| `AccEngineAccountRule` | `ComponentId IN (@Components)` |
| `AccEngineComponent` | `Id IN (@Components)` |
| `AccEngineGroup` | `Id IN (@Groups)` |
| `AccEngineEvent` | `Id IN (@Events)` |
| `AccAccountMap` | kendi `Path`'i |
| **`AccEngineDynamicMap`** | kendi `Path`'i - 🔴 **eski `tumyapiyiSilmeScript`'te YOKTU** (`TREX/MM/`, `TREX/InvFund/`, `TREX/TEST/`, `TREX/PM/`, `TREX/FX/` satirlari var) |
| `AccEngineItem` | once `LIKE 'TREX/X/%'`, sonra kok |

| Silinmez | Neden |
|---|---|
| `AccEngineItemCode` | kullanici karari 2026-09-10 |
| `AccEngineDynamicRule` | **paylasilan havuz** (434) - baska politikanin validasyonu/aciklamasi olabilir. Script sonunda "referanssiz kalanlar" **rapor** edilir |
| `AccEngineComponentAccount` | 🔑 **`ComponentId` kolonu YOK** - anahtari `ComponentTypeCode + GLCode`, component **tipine** bagli |
| `AccEngineComponentType` / `EventType` / `ItemType` / `ModelDefinition` / `Template` / `Account` | paylasilan referans |
| `AccEngine*History` | denetim kaydi |
| `AccEngineGeneratedAccountRule` | 🔴 **kural degil, URETILMIS FIS satiri** (`Amount`, `AccountingValueDate`, `TxnNo`) - silinmez, **varsa script durur** |
| `DefNumberGen` | sayaclar ileride kalsin (geri cekmek PK cakismasi uretir) |

### 🔴 Zincirde FK YOK - sira bize ait

Tum `Acc*` tablolarinda **yalnizca 6 FK** var ve zincirin **tek**i `Group.EventId`.
`Event.ItemId` - `Component.GroupId` - `AccountRule.ComponentId` **FK degil** ->
yanlis sirada silmek **hata vermez, sessizce orphan birakir**.
Olculdu: DB'de **454 sahipsiz `AccountRule` + 80 sahipsiz `Component` + 5 sahipsiz `Event`** duruyor.

✅ **Desen:** join ile kademe kademe silme yerine **once SNAPSHOT** (`@Items/@Events/@Groups/@Components`
tablo degiskenlerine Id topla), sonra Id ile sil. Item silindikten sonra join ile alt seviyeye
**ulasilamaz**.

### 🔴 Path capasi - `LIKE 'TREX/X%'` YETMEZ

Kok Path'ler **karisik**: `TREX/FI` ve `TREX/SEC1` **slash'siz**, `TREX/MM/` - `TREX/OPT1/` -
`TREX/InvFund/` - `TREX/BRWPLC1/` **slash'li**. Ayrica `LIKE 'TREX/MM%'` `TREX/MMXYZ`'yi de yakalar.

```sql
WHERE Path = N'TREX/X' OR Path = N'TREX/X/' OR Path LIKE N'TREX/X/%'
```

⚠ **Ayni ItemCode baska agacin altinda da olabilir:** `TREX/SEC1/FI` (Id 1001, ParentId 1000)
**FI politikasi degil**, SEC1'in cocugu. Yukaridaki capa onu yakalamaz - ama script bunu
**"DOKUNULMADI" diye listelemeli** ki silen kisi gorsun.
⚠ `AccAccountMap`'te ayni politikanin satirlari **hem** `TREX/OPT1` **hem** `TREX/OPT1/...` Path'iyle
duruyor; 16 satirin `Path`'i **NULL** (global - dokunulmaz).
ℹ Collation `SQL_Latin1_General_CP1254_CI_AS` -> `LIKE` **case-insensitive** (`InvFund`/`invfund` fark etmez).

### Prod silme script'i iskeleti (emsal)

`.ai-agent/outputs/2026-09-10-AccEngine-Politika-Silme/` - 5 script + `00-OKU-BENI.md`.
Zorunlu parcalar: `USE [__PROD_DB_ADINI_YAZ__]` (bilerek gecersiz - unutulursa **hemen durur**) -
`@DryRun BIT = 1` (rollback ile deneme turu) - GUARD-A (agac bulunamazsa hicbir sey silme) -
GUARD-B (uretilmis fis varsa dur) - silme sonrasi **kalinti sayimi 0 degilse `THROW`**.

---

## 5. Temizlik scriptleri — 3 seviye

| Seviye | Silinen | Korunan | Ne zaman |
|---|---|---|---|
| **Tam** | AccountRule → AccAccountMap → Component → Group → Event → **Item** → **ItemCode** | — | Script 1+2 baştan |
| **İçerik** | AccountRule → AccAccountMap → Component → Group → Event | **Item · ItemCode** | Yalnız Script 2 tekrar |
| **Sadece map** | `AccAccountMap` | diğer her şey | Hesap eşlemesi Excel'den yenilenecek |

```sql
-- Zincirli silme (AccountRule örneği)
DELETE ar FROM dbo.AccEngineAccountRule ar
INNER JOIN dbo.AccEngineComponent comp ON ar.ComponentId = comp.Id
INNER JOIN dbo.AccEngineGroup     grp  ON comp.GroupId   = grp.Id
INNER JOIN dbo.AccEngineEvent     evt  ON grp.EventId    = evt.Id
INNER JOIN dbo.AccEngineItem      itm  ON evt.ItemId     = itm.Id
WHERE itm.Path LIKE 'TREX/<POLİTİKA>%';

-- AccAccountMap AYRI (kendi Path'i)
DELETE FROM dbo.AccAccountMap WHERE Path LIKE 'TREX/<POLİTİKA>%';

-- Item: önce çocuklar, sonra kök
DELETE FROM dbo.AccEngineItem WHERE Path LIKE 'TREX/<POLİTİKA>/%';
DELETE FROM dbo.AccEngineItem WHERE Path = 'TREX/<POLİTİKA>/';
```

---

## 6. `AccEngineAccountRule` — GL kuralının anatomisi

```text
GLCode                    hesap kodu (InterestExpense, AccruedExpense, FxPosition, FxPositionLCY…)
DebitCredit               'Debit' | 'Credit'
AmountSource              AccrualAmount | AccrualAmountLCY | …   ← TxnModel alanı
CcySource / FcySource     CCY | LocalCCY
LcyEqvtSource / FcyAmtSource
ValueDateSource / TxnDateSource   LogicalDate | …
TxnNoSource               TxnNo
ReverseRebook             0/1
CalculationRuleId · CommentRuleId · CustomerCodeSource · CustomerAccountCodeSource
```

`*Source` alanları **sabit değil, `TxnModel` bağlamındaki alan adları**.
`AccEngineDynamicRule.[Rule]` **JavaScript** tutar:
`N'TxnModel.ValueDate.getTime() === TxnModel.LogicalDate.getTime()'`

### Referans: FCY borçlanma reeskontu = **4 satır**

| GLCode | D/C | AmountSource | CcySource |
|---|---|---|---|
| `InterestExpense` | Debit | `AccrualAmountLCY` | `LocalCCY` |
| `FxPositionLCY` | Credit | `AccrualAmountLCY` | `LocalCCY` |
| `FxPosition` | Debit | `AccrualAmount` | `CCY` |
| `AccruedExpense` | Credit | `AccrualAmount` | `CCY` |

LCY işlemde `FxPosition` köprüsü **gerekmez** (2 satır).
`AccrualAmount` kaynağı: **`TxnMMDailyCalculation.AccrualAmount`** (MM'in günlük tahakkuk tablosu).

### `ComponentTypeCode` kodları

`502`/`503` Opening (BRW/PLC) · `504`/`505` Maturation · `507` ve `506`+`110` Payment ·
**Revaluation = `512` (Dost/Dünya Excel Shared) / `510` (Tera Excel Shared)** · `511` Commission (yalnız Tera) ·
OptionsFX: `515–518` BUY/SELL CALL/PUT · `519/520` Premium · `508/509` MTM · `521–524` Cash Settlement/Derivative Realized.
🔴 **Workbook'a bağlı** — script yazarken **o workbook'un Shared sayfasından** kopyala; hangisi canlı `AccEngineComponentType` →
`mssql-read` ile doğrula (**tespit edilmedi**). Ayrıntı: `Accounting-Excel-THP-research.md` §2.1

---

## 6.5 `AccAccountMap` seçimi — özet (detay: research **§4.10**)

Engine **NetTrex.Core** repo'sundadır (NuGet `NetTrex.Core.Accounting.Engine`), modülün **kendi process'inde** koşar; Accounting API yalnız DB okur + Redis doldurur.
`NetTrex.Accounting/Code/Accounting/*Engine*` **eski nesildir** — davranışı oradan okuma.

```text
adaylar = Source == rule.GLCode (ordinal, harf duyarlı) AND IsEnabled AND (Path NULL OR EventPath.Contains(Path))
sıra    = ORDER BY Order (stabil; eşitse listedeki = DB dönüş sırası, ikinci kriter YOK)
seçim   = sırayla ilk "tüm Rule1..Rule10'u geçen" satır (kuralsız = her zaman geçer) ; hiçbiri → GLCode aynen kalır
sonra   = MM HandleMap: Source == (Target) AND Ccy == Fcy  → para birimi bölme (SingleOrDefault, Path/Order yok)
```

Yeni satır yazarken: `Source` harfi harfine · `Path` slash'sız · catch-all **en yüksek Order** · yazdıktan sonra **map cache'ini temizle** (24 saat TTL).

---

## 7. Akış (her kullanımda)

1. `Accounting-Engine-research.md`'yi oku.
2. Sorunun **okuma** mı **script üretme** mi olduğunu belirle.
3. Okuma → `mssql-read` (log zorunlu). Script → § 4 iskeleti + § 2 kuralları.
4. Script üretiyorsan **hangi temizlik seviyesinin** gerektiğini de yaz (§ 5).
5. Script'i `<repo>/.ai-agent/outputs/YYYY-MM-DD-<konu>.sql` olarak yaz, **yolu bildir**, çalıştırma.
6. Yeni öğrenilen her şeyi `Accounting-Engine-research.md`'ye **ekle** (bu skill'in bilgi tabanı odur).

---

## Gotcha

| # | Tuzak |
|---|---|
| **A-01** | 🔴 Id'ler `IDENTITY` değil — `DefNumberGen` güncellenmezse **PK çakışması** |
| **A-02** | `AccAccountMap` zincire join edilmez, **kendi `Path`'i** ile silinir |
| **A-03** | `AccEngineItem` silinirken **önce çocuklar** (`Path LIKE 'X/%'`), sonra kök (`Path = 'X/'`) |
| **A-04** | 🔴 **DB varyantı** — ~50 `NetTrexAcc_*` var. Yanlış varyantta inceleme/script **yanıltır** |
| **A-05** | `TREX/MM/…` altında `OnRevaluation` **yok** — politika ağacına (`TREX/BRWPLC1/…`) bak |
| **A-06** | `AccEntryMain` **hem `NetTrexMM`'de hem `NetTrexAcc`'te** var; **3 tip farkı**: `ValueDate` date/datetime · `TxnId` bigint/int · `Flag`/`Flags` |
| **A-07** | `AccEngineModelDefinition` script tarafından **üretilmez** — yoksa `THROW` (`'Borrowing & Placement V1'`) |
| **A-08** | Her tanım tablosunun `*History` ikizi var; sorgularken hangisine baktığını karıştırma |
| **A-16** | 🔴 Tablolarda **elle girilmis absurt Id** var (`AccAccountMap` 12376128, normal blok 24997te biter; `AccEngineDynamicRuleHistory` 2.000.290). `DefNumberGen.LastNumber = MAX(Id)` demek **korlemesine yanlis** - once oruntu disi ada ayiklanir. Emsal: `outputs/2026-09-10-DefNumberGen-Senkron/` |
| **A-17** | `UPDATE DefNumberGen ... FROM DefNumberGen d` **calismaz** (Msg 8154 ambiguous). Hedef alias ile yazilir: `UPDATE d SET ... FROM DefNumberGen d` |
| **A-18** | Sayac hesabina `*History` **katilmaz** - History kendi PK-sini (`HistoryId`) tasir, `Id` silinmis kayitlarin arsividir |
| **A-10** | 🔴 Zincirde **FK yok** (tek istisna `Group.EventId`) - yanlis silme sirasi hata vermez, **orphan** birakir. Once snapshot, sonra Id ile sil |
| **A-11** | 🔴 `AccEngineDynamicMap` unutuluyor - kendi `Path`'i var, eski temizlik scriptinde **yoktu** |
| **A-12** | 🔴 `AccEngineGeneratedAccountRule` **kural degil uretilmis fis** - silme, once **kontrol et** |
| **A-13** | `AccEngineComponentAccount`'ta `ComponentId` **yok** (`ComponentTypeCode`+`GLCode`) - politika silerken **dokunma** |
| **A-14** | Kok `Path`'ler slash'li/slash'siz **karisik** (`TREX/FI` vs `TREX/MM/`); `LIKE 'TREX/X%'` yanlis koke uzanir. `= X` / `= X/` / `LIKE X/%` uclusunu kullan |
| **A-15** | Ayni `ItemCode` baska agacin altinda olabilir (`TREX/SEC1/FI`) - silinmeyenleri script **ekrana bassin** |
| **A-09** | MM `AccountingType.Manuel = 5`'in motordaki karşılığı **tespit edilmedi** — manuel fiş tipi sorusunda varsayma |
| **A-19** | 🔴 Güncel engine **`NetTrex.Core`**'da; `NetTrex.Accounting/Code/Accounting/*Engine*` **eski nesil** (Roslyn, map mantığı yok). Motor davranışı sorusunda oraya bakma |
| **A-20** | Map seçiminde **Path öncelik vermez**, yalnız eler (`EventPath.Contains(Path)`); sıra **Order**; eşit Order'da ikinci kriter yok (DB dönüş sırası) |
| **A-21** | `Source` karşılaştırması motorda **ordinal** (`FxPositionLCY` ≠ `FXPositionLCY`), DB/popup'ta **harf duyarsız** — popup'ta görünen satır seçilen satır **değil** |
| **A-22** | Kuralsız map satırı her zaman geçer → sonrasındaki satırları gölgeler; catch-all'u en yüksek `Order`'a koy |
| **A-23** | Map cache (`Netix.AccAccountingMapDefinition`, 24 saat) yalnız **Verify**/Sync'te temizlenir; script'le yazılan satır cache temizlenmeden **motora görünmez** |
| **A-25** | 🔴 Map satırının `RuleIdN`'i **verified olmayan ya da var olmayan** dynamic rule'a işaret ederse kural **sessizce atlanır** → satır **daha geniş** eşleşir (kural kalmazsa catch-all). Yanlış koşulda seçilen satırda önce rule'ların `StateId`'sine bak |
| **A-26** | `AccountingSqlGenerator.ts` (`imports/`) idempotency anahtarı **`Order`/`IsEnabled`/`Description`'ı içermez** — yalnız bunları değiştirip tekrar koşturmak **no-op**. Güncelleme için UPDATE script'i yaz (+ cache temizle) |
| **A-27** | `NetTrex.Core` **kütüphane**; ona HTTP isteği atılmaz. MM → Accounting API'ye yalnız `/AccAccountingMap/Select` (**boş gövde**) gider; model hiç gönderilmez, seçim MM process'inde |
| **A-28** | 🔴 Dynamic rule JS'i (`TxnModel.X`) **derlenmez**: modelde olmayan property → `undefined` → kural **sessizce hep false**, hata yok. Canlı olay (2026-10-26): kural `12660/12661` `UseExternalGLCode` okuyordu (model: `UseExternalGLAccount`) → 110 `CounterPartyGLAccount` map satırı seçilmedi, fişte GL **sembolik adıyla** kaldı. Yeni kuralda property adını `AccountingEngineModel.cs`'den doğrula; sonra canlı işlemde fişte `AccAccountMapId` dolu mu bak |
| **A-29** | Excel `Shared` sayfası dynamic rule gövdesinin **kaynağı** (generator oradan SQL basar). DB'deki kuralı düzeltirsen Excel'i de düzelt, yoksa yeniden üretimde bug döner. Tarama: `AccEntry.GLCode` sembolik (`*GLAccount`/`CounterPartyGLAccount`) **ve** `AccAccountMapId IS NULL` = map seçilememiş fiş |
| **A-30** | Map çıktı alanları **bağımsız**: `GLCode` = `TargetRule` > `Target` > (map yoksa AccountRule.GLCode); `Customer*/Account/WorkGroup/Type` her biri map `*SourceRule` > `AccountRule.*Source` > null. Müşteri kolonları Target'ı **ezmez**, yanına eklenir. Map seçilemezse müşteri/hesap da **boş** kalır. Ödeme map satırları (Rule6=`*AccountingType`, Rule7=`*GLType`): Linked=GL+müşteri+hesap, Ledger=yalnız GL, Cash=GL JS'ten (`*CorrespondentAccountGLCode`). Detay → `Accounting-Engine-research.md` §4.12 |
| **A-31** | Ödeme map satırlarında **V2V = Vostro** (`PaymentInstructionType` Id 3), A2A = Nostro (Id 2), B2B = BankToBank (Id 1). B2B/A2A `Outgoing|IncomingCorrespondent*` (bizim muhabir hesabımız), Vostro `TheirBeneficiary|TheirSender*` (karşı bankanın bizdeki hesabı) okur. Ekran: We Send=Outgoing, We Receive=Incoming, They Send=TheirSender, They Receive=TheirBeneficiary. Detay → `Accounting-Engine-research.md` §4.12.3 |
| **A-32** | 🔴 **Excel/THP işi ayrı skill:** kırılım, "hangi hesaba düşer", AccountMap/Shared Excel değişikliği → [`accounting-excel-thp`](accounting-excel-thp.md). `Target`/`TargetMainGL` uyuşmazlığı, THP PDF kayması, workbook başına component kodu orada |
| **A-33** | `TargetMainGL` fişe **taşınır**, GL'i belirlemez; fişe yazılan hesap `Target`. 2026-10-27 taramasında Excel'lerde **15 satırda** `Target` ≠ `TargetMainGL` prefix (iş birimi teyidi bekliyor) |
| **A-34** | Kural kolonu (`Rule1..10`) anlamı satır ailesine göre değişir: ürün satırlarında R4=Market…R10=Fund Type, ödeme kaynaklarında (kök Path) R4=PaymentInstructionType…R7=GLType. Rule **adına** göre düşün, kolon numarasına göre değil |
| **A-35** | Excel'de `Fund Type` (EquityCapital/ParticipationAccounts/InvestmentAgency) **yalnız katılım** workbook'larında; THP son hanesi `0/2/4`. Yatırım (Tera) bunun yerine `Teminatlı/Teminatsız` + TCMB/TAKAS/BIST market'i kullanır |
| **A-24** | MM `HandleMap` ikinci remap'tir (`Source == Target-GL && Ccy == Fcy`, `SingleOrDefault`): yeni kuralda `Ccy` kolonu kullanma, `(Source,Ccy)` tekrarı exception atar |

---

## Bu skill'in kaynağı

- **Canlı DB:** `NetTrexAcc` — 43 tablo, `AccEngineAccountRule` 8.655 kayıt (`sql-log` #8-#16)
- **Üretim scriptleri:** `Desktop/SQL-Helper-Scripts/1-Yapılan-İşlerin-Scriptleri/FeatureScripts/`
  `DubaiScriptGeliştirmesi/BRWPLC-DUBAI` (1.175 satırlık script + 3 temizlik seviyesi) ·
  `Commission/Commission-Accounting` · `Tawarruq`
- **Kod:** `NetTrex.MM` accounting pipeline'ları, `AccEntryMainEntity`, `AccountingType` enum'ı
- **Excel + THP (2026-10-27):** `imports/AccountingExcels/` (4 workbook + `AccountingSqlGenerator.ts`), `imports/THP/` (2 PDF) →
  `Accounting-Excel-THP-research.md` · [`accounting-excel-thp`](accounting-excel-thp.md)
