# SQL Çıktıları — linked-transaction-development

## #1 — FX: TxnFX kolon tipleri (LinkedTransaction alanları)
```
name|type|max_length|is_nullable
TransactionOriginType|int|4|0
LinkedTransactionId|bigint|8|1
LinkedTransactionReference|nvarchar|200|1
LinkedTransactionTrader|nvarchar|200|1
LinkedTransactionReasonType|int|4|1
```
⚠️ Wiki nvarchar(50)/(80) diyor, gerçek FX Dev DB'de ikisi de nvarchar(100 karakter = max_length 200 byte).
FX'in deploy'u wiki spesifikasyonundan sapmış. MM script'i **wiki'nin spesifikasyonunu** (50/80) esas
alacak — paketin `ConfigureTransactionEntity()` metodu C#'ta da 50/80 `HasMaxLength` uyguluyor (wiki metni).

## #2 — FX: TxnFX son 20 kayıt
Tüm 20 satır `TransactionOriginType=1` (Manual), `LinkedTransactionId/Reference/Trader/ReasonType` hepsi NULL.
Henüz canlıda bir Exercise/Rollover/Unwind türetilmiş FX işlemi oluşmamış (Generated=2 satırı hiç yok).

## #3 — FX: TransactionOriginType / LinkedTransactionReasonType dağılımı
```
TransactionOriginType|LinkedTransactionReasonType|Adet
1 (Manual)|NULL|147
3 (Imported)|NULL|9
```
`None` (0) hiç persist edilmemiş — wiki'nin "None veritabanına yazılmaz" kuralı doğrulandı.
Generated hiç yok → derived-transaction akışı FX'te de henüz canlı veri üretmemiş, yalnız plumbing var.

## #4 — MM: TxnMM kolon listesi
76 kolon. `TransactionOriginType`/`LinkedTransaction*` **yok** (beklendiği gibi — henüz eklenmedi).
`Id` bigint NOT NULL (IDENTITY değil, DefNumberGen). `ExternalReferenceSourceId` int NULL mevcut.

## #5 — MM: TxnMM ExternalReferenceSourceId dağılımı
```
Toplam|ImportedOlacak|ManualOlacak
675|146|529
```
Migration script'in 2. adımı (`CASE WHEN ExternalReferenceSourceId IS NOT NULL THEN 3 ELSE 1 END`) 675 satırı
güvenle ikiye ayırıyor.

## #6 — MM: txnMMHistory satır sayısı + dağılım
```
Toplam|ImportedOlacak|ManualOlacak
3887|188|3699
```
Aynı backfill kuralı history'de de uygulanabilir — küçük tablo, tek seferde güvenli.

**Ek kontrol:** `txnMMHistory` PK `HistoryId` (bigint, IDENTITY), `Id` ayrıca bigint NOT NULL (kaynak TxnMM.Id, IDENTITY değil).

## #7 — MM: TxnMMTrigger gövdesi
🔴 **KRİTİK BULGU:** `TxnMMHistory` uygulama kodundan hiç INSERT edilmiyor (`ITransactionHistoryDataManager.Insert`
tanımlı ama hiçbir çağıranı yok — grep ile doğrulandı). Tüm history satırları **`TxnMMTrigger`**
(`FOR INSERT, UPDATE`) tarafından, **açık kolon listesiyle** (`SELECT *` değil) üretiliyor.
Kolon listesi 76 TxnMM kolonunun 74'ünü kapsıyor (StateId/StateMaker/StateDate dahil, 2'si — kontrol
edilmedi hangileri eksik, önemsiz) + sondaki `LastActionId`/`PreviousActionId` **alfabetik sırayı
bozarak listenin sonuna eklenmiş** (önceki bir migration'ın izi — yeni kolonlar da aynı şekilde
**sona eklenecek**, mevcut 74 kolon yeniden sıralanmayacak).
**Sonuç:** TxnMM'e 5 yeni kolon eklemek yetmez — **`TxnMMTrigger` güncellenmezse** `TxnMMHistory`'nin
yeni kolonları sonsuza kadar NULL kalır (insert hata vermez, sessiz boşluk). Script'e
`CREATE OR ALTER TRIGGER` ile güncellenmiş gövde eklenecek.

## #11 — RolloverParentTransactionId konsolidasyonu etki boyutu
TxnMM: 4 satir, txnMMHistory: 13 satir -- 2-NetTrexMM-RolloverParentTransactionId-Drop.sql'in
BATCH 1'i (mutabakat) tam olarak bu satirlari kapsiyor, sonraki ALTER TABLE DROP COLUMN guvenli.
