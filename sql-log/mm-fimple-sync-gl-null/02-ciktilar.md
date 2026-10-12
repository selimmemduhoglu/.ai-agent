# SQL Çıktıları — mm-fimple-sync-gl-null

## 1 — HATA
```
Msg 207, Level 16, State 1, Server srv-mssql, Line 1
Invalid column name 'IsIntraBank'.
Msg 207 ... Invalid column name 'ProductId'.
```

## 2 — TxnMM kolon listesi
IsIntraBank ve ProductId kolonları TxnMM'de YOK. Var olan ilgili kolonlar:
`TxnMmProductTypeId`, `SettlementTypeId`, `CustomerIsFinancialInstitution`,
`IncomingPaymentAccountingType/GLType/GL`, `OutgoingPaymentAccountingType/GLType/GL`.
(IsIntraBank runtime'da türetiliyor, kolon değil.)

## 3 — TxnMM son 20 kayıt (kırpılmadı)
StateId=16 olanların hepsinde GL NULL (henüz muhasebeleşmemiş → normal).
StateId=18 olanlarda: TMMPLC2609160004 In=Out=39099300, TMRBRW2609160002 In=Out=39200840,
TISBRW2609160001 (PT=3, IssueBond) In=Out=NULL.

## 4 — StateId=18'de NULL GL dağılımı
```
PT|ST|InType|InGLType|IsFI|Adet|InGLNull|OutGLNull
1|1|TempAcc|LedgerAcc|1|213|148|57
3|NULL|NULL|LedgerAcc|0|30|30|30
5|1|TempAcc|LedgerAcc|1|47|19|47
3|NULL|NULL|NULL|1|17|17|17
1|2|TempAcc|LedgerAcc|1|27|15|18
3|NULL|NULL|LedgerAcc|1|8|8|8
1|1|TempAcc|LedgerAcc|0|14|7|3
1|1|CashAcc|LinkAcc|1|2|2|1
1|NULL|TempAcc|LedgerAcc|1|2|2|2
1|2|CashAcc|LinkAcc|1|4|2|2
4|1|TempAcc|LedgerAcc|1|9|2|8
5|2|TempAcc|LedgerAcc|1|10|1|8
5|NULL|TempAcc|LedgerAcc|1|1|1|1
4|1|TempAcc|LedgerAcc|0|1|1|0
2|1|TempAcc|LedgerAcc|1|5|1|4
2|1|CashAcc|LinkAcc|1|3|0|3
```
**Bulgu:** InGLNull ≠ OutGLNull. Persister ikisine de aynı değeri yazdığı halde
oranlar farklı → NULL, AccountingType/GLType/SettlementType ile korele DEĞİL.

## 5/6 — AccEntry.Source dağılımı
```
<NULL>|6331   InterestIncome|2476   AccruedIncome|2476   InterestExpense|1086
AccruedExpense|1085   CounterPartyGLAccount|647   IncomingPaymentLCY|385
FxPosition|285   FxPositionLCY|285   OutgoingPaymentLCY|275   InterestReceived|113
IncomingAgentPaymentAmount|76   IncomingPaymentFCY|50   InterestPaid|43
OutgoingAgentPaymentAmount|32   OutgoingPaymentFCY|25
```
**Bulgu:** `Contains("IncomingPayment")` → IncomingPaymentLCY/FCY yakalar,
`IncomingAgentPaymentAmount` (76 satır) ve `OutgoingAgentPaymentAmount` (32 satır)
**yakalanmaz**. İkincil bir eksik eşleşme kaynağı.

## 7 — NULL GL'li işlemlerin AccEntry Source'ları
Sadece TISBRW* (PT=3, IssueBond) döndü, Source hepsinde NULL → IssueBond ayrı akış,
bu bug'ın konusu değil.

## 8 — PT<>3, NULL GL'li işlemlerin payment bacakları (kırpılmadı, ilk 20)
```
TMMBRW2607170002|1|1|39200840|-|IncomingPaymentLCY|39200840|Debit|1
TMMBRW2607170002|1|1|39200840|-|OutgoingPaymentLCY|39200840|Credit|4
TMMBRW2607030002|1|1|39200840|-|IncomingPaymentLCY|39200840|Debit|1
TMRBRW2607030001|5|2|39200840|-|IncomingPaymentLCY|39200840|Debit|1
TMMPLC2607010003|1|1|-|32000002|OutgoingPaymentLCY|32000002|Credit|1
TMMPLC2607010003|1|1|-|32000002|IncomingPaymentLCY|32000002|Debit|4
TMMPLC2606300009|1|1|-|39200840|OutgoingPaymentLCY|39200840|Credit|1
... (aynı desen)
```
**Bulgu:** Açılış fişinde (AccEntryMain.Type=1) tek payment bacağı var:
BRW → sadece `IncomingPaymentLCY`, PLC → sadece `OutgoingPaymentLCY`.
İkisi de aynı GL koduna gidiyor (39200840 / 32000002) → mirror iş kuralı doğru.

## 9/10 — TxnSync (Fimple'a giden) vs TxnMM (DB) — 🔴 KÖK NEDEN
```
Id |LR               |SyncInGL|SyncOutGL|TxnInGL |TxnOutGL
377|TMMPLC2609160004 |-       |39099300 |39099300|39099300
376|TMRBRW2609160002 |39200840|-        |39200840|39200840
374|TMMPLC2609090006 |-       |39300840 |39300840|39300840
373|TMMBRW2609090001 |39200840|-        |39200840|39200840
372|TMMPLC2609090003 |-       |39099300 |39099300|39099300
371|TMMBRW2609030004 |39200840|-        |39200840|39200840
... (istisnasız aynı desen)
```
**TxnMM'de her iki kolon dolu, Fimple'a giden TxnSync'te bir tanesi NULL.**
Osman'ın Fx ekran görüntüsündeki ThirdPartyTransaction NULL'ları ile birebir aynı desen.

## 11 — TxnCashFlow tek taraflı NULL
```
Adet|SadeceInNull|SadeceOutNull|IkisiDolu|IkisiNull
405 |41          |58           |0        |306
```
**Bulgu:** CashFlow'da **hiçbir** satırda ikisi birlikte dolu değil (IkisiDolu=0).
Term payment sync (FimpleTermPaymentTransactionModelMapper) buradan besleniyor →
aynı hata payment/maturation akışlarında da var.

## 17 — NULL/NULL işlemlerin ödeme bacağı kontrolü
```
LR|MainId|MType|Src|GLCode|DC
(0 satır)
```
**Bulgu:** Bu LogicalReference'lar `NetTrexMM_134`'te **yok**. Kullanıcı testi **başka bir
veritabanında** almış (kendi test/prod-benzeri ortamı). Bu satırların analizi o ortamda
yapılmalı — 134'ten doğrulanamaz.

## 18 — Aynı fişte hem doğrudan hem agent ödeme bacağı var mı?
```
MainId|PC|MType|InDirect|InAgent|OutDirect|OutAgent
(0 satır)
```
**Bulgu:** `NetTrexMM_134`'te **hiçbir** fişte doğrudan (`IncomingPaymentLCY/FCY`) ve agent
(`IncomingAgentPaymentAmount`) bacağı **birlikte** bulunmuyor. Tawarruq fişlerinde yalnız agent,
MM fişlerinde yalnız doğrudan bacak var. → Fix'teki `OrderBy(AgentPayment ? 1 : 0)` mevcut veride
**hiçbir zaman devreye girmiyor**; savunma amaçlı, gerekliliği ispatlanmış değil.
