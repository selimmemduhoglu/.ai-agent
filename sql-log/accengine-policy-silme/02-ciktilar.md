# 02 — Çıktılar · `accengine-policy-silme`

> **DB:** `NetTrexAcc` @ `tcp:192.168.10.211,1433` (`trusr` / `-P '***'`)
> 🔴 **Bu DB PROD DEĞİL.** Kanıt: kullanıcının 2. ekran görüntüsünde (prod) **`TEST (TestItem)`** kökü var,
> bu DB'de `TREX/TEST%` altında **hiç `AccEngineItem` yok** (#12). Yani prod ayrı bir `NetTrexAcc_*` varyantı.

---

## #1 — `AccEngine*` / `AccAccount*` tabloları (31 tablo)

```
AccAccountMap|4030            AccEngineDynamicMap|11
AccAccountMapHistory|4462     AccEngineDynamicRule|434
AccEngineAccount|885          AccEngineDynamicRuleHistory|500
AccEngineAccountHistory|76    AccEngineEvent|601
AccEngineAccountRule|8699     AccEngineEventHistory|1331
AccEngineAccountRuleHistory|12785   AccEngineEventType|18
AccEngineApplication|1        AccEngineEventTypeHistory|0
AccEngineComponent|3681       AccEngineGeneratedAccountRule|0
AccEngineComponentAccount|1073      AccEngineGroup|1157
AccEngineComponentHistory|4542      AccEngineGroupHistory|2077
AccEngineComponentType|168    AccEngineItem|531
AccEngineComponentTypeHistory|21    AccEngineItemCode|100
AccEngineItemCodeHistory|24   AccEngineItemHistory|448
AccEngineItemType|40          AccEngineItemTypeHistory|42
AccEngineModelDefinition|32   AccEngineModelDefinitionHistory|90
AccEngineTemplate|2
```

## #2 — FK ilişkileri (**yalnız 6 tane**)

```
FK_AccEngineAccountRule_AccEngineDynamicRule_CommentRuleId | AccEngineAccountRule -> AccEngineDynamicRule | NO_ACTION
FK_AccEngineComponent_AccEngineComponentType_ComponentTypeCode | AccEngineComponent -> AccEngineComponentType | NO_ACTION
FK_AccEngineComponent_AccEngineDynamicRule_ValidationRuleId | AccEngineComponent -> AccEngineDynamicRule | NO_ACTION
FK_AccEngineEvent_AccEngineEventType_EventTypeCode | AccEngineEvent -> AccEngineEventType | NO_ACTION
FK_AccEngineGroup_AccEngineDynamicRule_ValidationRuleId | AccEngineGroup -> AccEngineDynamicRule | NO_ACTION
FK_AccEngineGroup_AccEngineEvent_EventId | AccEngineGroup -> AccEngineEvent | NO_ACTION
```

🔑 **Zincirin kendisinde FK YOK** (`Event.ItemId`, `Component.GroupId`, `AccountRule.ComponentId` **FK değil**).
Tek gerçek zincir FK'sı `Group.EventId`. Yani **cascade yok, sıra bize ait**; yanlış sırada silmek
hata vermez, **sessizce orphan bırakır**.

## #3 — ❌ BAŞARISIZ

```
Msg 207, Level 16, State 1 — Invalid column name 'ItemTypeId'.
```
Doğru kolon adı `ItemTypeCode` (nvarchar, koda göre) → #6 ile tekrarlandı.

## #6 — `AccEngineItemCode` (100 satır, ilgili olanlar)

```
123|FI|Fixed Income|Prd            1304|TEST|Deneme|TestItem
168|MM|Money Market|Prd            1353|INVFUNDS|Invesment Funds|Prd
1300|SEC1|Secutity Basic Version|Prd   1366|InvFund|Invesment Funds|Prd
1305|DV|Derivatives|Prd            1377|OPT1|Options Version 1|Prd
1354|BRWPLC1|Borrowing & Placement Version 1|Prd   167|FX|Foreign Exchange|Prd
```

⚠️ **`INVFUNDS` (1353) ve `InvFund` (1366) iki AYRI ItemCode.** Ağaçta kullanılan `InvFund`.

## #7 — Kök node'lar ve alt ağaç sayıları

```
Id  |ItemCode|ParentId|Path
106 |FI      |NULL    |TREX/FI          ← 🔴 SONDA SLASH YOK
427 |MM      |NULL    |TREX/MM/
1000|SEC1    |NULL    |TREX/SEC1        ← slash yok
1001|FI      |1000    |TREX/SEC1/FI     ← 🔴 SEC1 ALTINDA AYRI BİR "FI" NODE'U
2257|InvFund |NULL    |TREX/InvFund/
2601|OPT1    |0       |TREX/OPT1/       ← ParentId NULL değil, 0
```

Kök başına `AccEngineItem` sayısı:
```
TREX/BRWPLC1/|22   TREX/FI|1    TREX/FI/|243   TREX/FX/|17   TREX/InvFund/|28
TREX/MM/|129       TREX/OPT1/|20  TREX/PM/|25  TREX/SEC1|1   TREX/SEC1/|37   TREX/DV/|8
```

## #8 — `AccAccountMap` ve `AccEngineDynamicMap`

`AccAccountMap` kök dağılımı (Path dolu olanlar):
```
TREX/BRWPLC1|68   TREX/BRWPLC1/|498   TREX/DV|80   TREX/DV/|94   TREX/FX|64
TREX/InvFund|75   TREX/InvFund/|44    TREX/OPT1|69 TREX/OPT1/|499  TREX/PM|96
TREX/SEC1|2327    TREX/SEC1/|100
Path IS NULL: 16
```
🔴 **`TREX/MM` ve `TREX/FI` için AccAccountMap satırı YOK** (bu DB'de). Ayrıca aynı politikanın
satırları **hem slash'lı hem slash'sız** Path ile duruyor → çapa iki formu da kapsamalı.

`AccEngineDynamicMap` (11 satır — **eski silme scriptinin HİÇ dokunmadığı tablo**):
```
Id|DynamicRuleId|Source|Target|Path
 5|1   |030-bilanço|030062001|Trex
 6|2   |030-bilanço|030062002|Trex
 8|2210|TRD-LCY-AssetAmount|03002900|(boş)
 9|2210|TRD-LCY-Payment|39200000|(boş)
10|2210|TRD-LCY-Contingent|97800000|(boş)
11|2210|TRD-LCY-ContingentOffset|98000000|(boş)
12|2208|039010093|223010171|TREX/TEST/      ← TEST
13|5   |0042612006|0042612006|TREX/MM/      ← MM
14|2208|0042612006|02000000|TREX/PM/
15|5   |02000000|02000000|TREX/InvFund/     ← InvFund
16|10  |0042612006|02100000|TREX/FX/
```

## #9 — Zincir kolonu olan TÜM tablolar (silme yüzeyi)

```
CANLI:   AccEngineItem.Path · AccEngineEvent.ItemId · AccEngineGroup.EventId ·
         AccEngineComponent.GroupId · AccEngineAccountRule.ComponentId ·
         AccEngineGeneratedAccountRule.ComponentId · AccAccountMap.Path · AccEngineDynamicMap.Path
HISTORY: AccAccountMapHistory.Path · AccEngineAccountRuleHistory.ComponentId ·
         AccEngineComponentHistory.GroupId · AccEngineEventHistory.ItemId ·
         AccEngineGroupHistory.EventId · AccEngineItemHistory.Path/ItemCode
```

## #10 — 5 politika için zincir sayımları (bu DB)

```
Code   |Item|Event|Group|Component|AccountRule|AccAccountMap|DynamicMap
FI     | 244| 187 | 524 |  2164   |   4375    |      0      |    0
InvFund|  28|  18 |  76 |    76   |    390    |    119      |    1
MM     | 129| 101 | 156 |   338   |    802    |      0      |    1
OPT1   |  20|  60 | 108 |   281   |    759    |    568      |    0
TEST   |   0|   0 |   0 |     0   |      0    |      0      |    1
```

## #11 — Orphan kontrolü 🔴

```
OrphanEvent       |   5
OrphanGroup       |   0
OrphanComponent   |  80
OrphanAccountRule | 454
ItemParentMissing |   0
```
🔴 **Zincirde zaten 454 sahipsiz `AccEngineAccountRule` + 80 sahipsiz `AccEngineComponent` var.**
Bunlar hangi politikaya aitti **artık bilinemez** (üst kayıt yok) → yeni script'ler bunlara dokunmaz,
yalnız **sayısını raporlar**. Sebep muhtemelen geçmişte üstten-alta (yanlış sırada) yapılmış bir silme.

## #12 — Collation / Path NULL / TEST

```
DbCollation  : SQL_Latin1_General_CP1254_CI_AS   → LIKE karşılaştırması CASE-INSENSITIVE
ItemPathNull : 0
TEST ağacı   : 0 satır (bu DB'de TREX/TEST yok — prod'da var, ekran görüntüsü 2)
```

## #13 — `AccEngineGeneratedAccountRule` gerçekte NE

Kolonları: `PackageNo · ComponentId · RuleId · GLCode · CustomerCode · DebitCredit · **Amount** ·
TxnNo · TxnRef · **AccountingValueDate** · AccountingGenerationDate · Ccy · LcyEquivalent · MainId · Flags`

🔴 **Bu bir KURAL tablosu değil, ÜRETİLMİŞ FİŞ SATIRI tablosu** (tutar + valör + txn referansı taşıyor).
Bu DB'de 0 satır; **prod'da dolu olabilir**. Silme script'i buna **dokunmaz** — bunun yerine
"bu politikanın component'lerine bağlı üretilmiş fiş var mı" diye **ön kontrol** yapıp durur.

## #14 - `AccEngineGroup` kolonları

```
Id | EventId | ValidationRuleId | Order | ModifiedBy | ModifiedDate | StateId | StateDate | StateMaker
```
`ValidationRuleId` **var** - rapor sorgusu geçerli.

## #15 - En buyuk 6 Id (tablo basina)

```
AccAccountMap      4030 satir | 12376128 <- TEK BASINA COK YUKARIDA | sonra 24997, 24996, 24995, 24994, 24993
AccEngineAccountRule 7897 | 44430, 44429, 44428, 44427, 44426, 44425   (bitisik)
AccEngineComponent   3343 | 19971 ... 19966                            (bitisik)
AccEngineComponentAccount 1073 | 4507, 4501, 4499, 4498, 4497, 4496
AccEngineDynamicRule  434 | 12507 ... 12502                            (bitisik)
AccEngineEvent        500 | 7173 ... 7168                              (bitisik)
AccEngineGroup       1001 | 9768 ... 9763                              (bitisik)
AccEngineItem         402 | 2655 ... 2650                              (bitisik)
AccEngineItemCode     100 | 1493 ... 1488                              (bitisik)
AccEngineItemType      40 | 211 ... 206                                (bitisik)
AccEngineModelDefinition 32 | 174, 172, 171, 170, 164, 135
```
🔑 **Orustu disi Id YALNIZ `AccAccountMap`'te var:** `12376128` (StateMaker
`PARTNER.TREASY.005@INVESTMENTBANK.COM`, elle girilmis). Normal blok **24997**'de bitiyor.
⚠ `COUNT(*)` degerleri #1'deki `sys.partitions` sayilarindan farkli
(or. AccEngineAccountRule 7897 vs 8699) - `sys.partitions` yaklasik, `COUNT(*)` kesin.

## #16 - En buyuk bosluklar

```
AccAccountMap            12351131 (12376128'in altinda)  <- ABSURD
AccAccountMap (2.)           6150
AccEngineAccountRule         9596  <- normal bosluklarin en buyugu
AccEngineDynamicRule         4445
AccEngineComponent           3814
AccEngineGroup               2224
AccEngineEvent               1931
AccEngineItem                 859
AccEngineComponentAccount     995
AccEngineItemCode             998
AccEngineItemType             101
AccEngineModelDefinition      101
```
🔑 **Normal bosluk en fazla ~9.600; absurt olan 12.351.131 - yaklasik 1.300 kat.**
Yani sabit bir esik yerine **oransal** kural yazilabilir: bir Id, kendinden onceki Id'nin
**10 katindan** buyukse kopus. (12376128 > 10 x 24997 = 249.970 ✓;
`AccEngineItemCode`'un 197 -> 1195 sicramasi 1195 > 1970 degil ✗, yani **atilmaz** - dogru.)

## #17 - Canli vs History MAX(Id)

```
Tablo                     CanliMax   HistMax
AccAccountMap             12376128   12376128
AccEngineAccountRule         44430     44430
AccEngineComponent           19971     19971
AccEngineDynamicRule         12507   2000290   <-- FARKLI
AccEngineEvent                7173      7173
AccEngineGroup                9768      9768
AccEngineItem                 2655      2655
AccEngineItemCode             1493      1493
AccEngineItemType              211       211
AccEngineModelDefinition       174       174
DefNumberGen kolonlari: EntityColumnType | LastNumber | Definition | LastUpdateDate
```

## #18 - History'deki 2.000.000'lik Id'ler

```
Kolonlar: HistoryId (kendi PK'si) | Id (entity Id) | Name | Rule | Type | Description | State*
En buyuk 5: 2000290 OPT1 Revaluation Accounting Description
            2000289 OPT1 ExerciseSettlement ...
            2000288 OPT1 Maturation ...
            2000287 OPT1 PremiumSettlement ...
            2000286 OPT1 Opening ...
Id > 12507 olan history satiri: 189
```
🔑 History'nin **kendi PK'si `HistoryId`**; `Id` entity Id'si. OPT1 kurallari bir zamanlar
**2.000.000'lik elle verilmis Id'lerle** girilmis, sonra canlidan silinmis. Yani "elle absurt Id
verme" bu DB'de **tekrar eden bir aliskanlik** - sayac hesabi bunu ayiklamak zorunda.
✅ Karar: sayac **yalniz canli tablolardan** hesaplanir; History'ye bakilmaz (o zaten silinmis
kayitlarin arsivi ve kendi PK'si var).
