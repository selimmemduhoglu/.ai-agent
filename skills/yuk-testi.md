# Skill — yuk-testi (yük testi / performans testi datası — gerçek işlemi klonlama)

**Ne zaman tetiklenir:** Bir ekranın/servisin hacim altında davranışını ölçmek için DB'ye **N adet sahte
işlem** basan script gerektiğinde.
Tetikleyici: *yük testi · load test · performans testi · performans testi datası · dummy işlem ·
sahte işlem üret · N adet işlem klonla · 3000 işlem bas · test datası çoğalt · hacim testi*

**Tür:** Script üretimi · **Kapsam:** cross-repo (`NetTrexMM`, `NetTrexFX`; aynı desen diğer modüllere
uyarlanır)

**Referans uygulama (Manuel Reeskont, 2026-09-26):** `repos/.ai-agent/outputs/2026-09-26-ManuelReeskont-YukTesti/`
— script'lerin tam metni bu skill'in klasöründe:

| Dosya | Ne |
|---|---|
| [mm-dogrulama.md](yuk-testi/mm-dogrulama.md) | `0-DOGRULAMA-NetTrexMM.sql` — salt-okunur: şablon seçimi, sayaçlar, trigger, unique index, Fimple sync |
| [fx-dogrulama.md](yuk-testi/fx-dogrulama.md) | `0-DOGRULAMA-NetTrexFX.sql` — aynısı FX için |
| [mm-3000-islem.md](yuk-testi/mm-3000-islem.md) | `1-NetTrexMM-YukTesti-3000-Islem.sql` — `TxnMM` + `txnMMDetail` + açılış `accEntryMain` klonu |
| [fx-3000-islem.md](yuk-testi/fx-3000-islem.md) | `2-NetTrexFX-YukTesti-3000-Islem.sql` — `txnFX` klonu |
| [mm-geri-al.md](yuk-testi/mm-geri-al.md) | `9-GERI-AL-NetTrexMM-YukTesti.sql` — klonları + testte üretilen reeskont kayıtlarını siler |
| [fx-geri-al.md](yuk-testi/fx-geri-al.md) | `9-GERI-AL-NetTrexFX-YukTesti.sql` — aynısı FX için |

Yeni bir yük testi yazarken **önce bu script'leri oku**, sıfırdan yazma — deseni kopyala, tabloları değiştir.

---

## 🔴 MUTLAK KURALLAR

| # | Kural |
|---|---|
| 1 | **Script'i ASLA çalıştırma.** `repos/.ai-agent/outputs/<YYYY-MM-DD>-<Is>-YukTesti/`'e yaz, yolu bildir — **kullanıcı uygular** |
| 2 | **Her zaman üçlü teslim:** `0-DOGRULAMA-*` (salt-okunur) + `1..N-<DB>-YukTesti-*` (yazan) + `9-GERI-AL-*` (geri alma). Geri alma script'i olmayan yük testi **teslim edilmez** |
| 3 | **Idempotent.** Önekle başlayan klon varsa script **hiçbir şey yapmaz**, `PRINT '... atlandi'` basıp `COMMIT` + `RETURN` eder. Geri alma da klon yoksa her adımda 0 satır siler |
| 4 | **Uydurma veri yok — gerçek bir şablon işlem klonlanır.** Customer/Product/Portfolio/Instrument/Ccy/yön şablondan gelir → FK'lar ve muhasebe motoru eşleme kuralları garanti geçerli |
| 5 | **Kolon listesi dinamik** — `sys.columns`'tan çalışma anında okunur (`is_identity = 0 AND is_computed = 0`), `STRING_AGG` + `sp_executesql`. Elle kolon listesi **yazma**; canlı şema ortamdan ortama farklı |
| 6 | **Benzersiz önek.** Klon referansı = `@RefPrefix` + 5 hane (`TMMBRWYT00001`, `TFXFWYT00001`). Önek gerçek referans deseniyle **çakışmamalı**, ama modülün referans ailesi içinde kalmalı (§5 FX `TFXSW` tuzağı) |
| 7 | 🔴 **`Txn*` Id'si IDENTITY DEĞİL** — `DefNumberGen` sayacından rezerve edilir, `UPDLOCK, HOLDLOCK` ile kilitlenip **tek seferde `+N`** ilerletilir. MM öneki **`55`**, FX öneki **`11`** (`Id = '<önek>' + sayaç`). Sonuç `int`'e sığmalı (`2147483647`) |
| 8 | **Ayrılan Id aralığı boş mu** — insert öncesi `#CloneMap` ile mevcut tabloya `JOIN`, doluysa `THROW` (sayaç bozuk demektir) |
| 9 | **`BusinessKey` yeni, `ExternalReference`/link/rollover kolonları `NULL`.** `@BusinessKeyBase = 999000000000000000` + n → gerçek Snowflake anahtarlarıyla çakışmaz. Dış referans dolu kalırsa mükerrer kontrolüne takılır |
| 10 | **Trigger'lar History'yi kendisi yazar** (`TxnMMTrigger` → `TxnMMHistory`). History'ye elle insert **yazma**; geri almada History **silinir** |
| 11 | **Yalnız yük testi ortamı.** Canlı/UAT'ta koşulmaz — script başlığına yaz. `USE [...]` satırı ortama göre düzeltilir (`NetTrexMM_134`, `NetTrexFX_Dev` ...) |
| 12 | Genel iskelet/üslup [`db-script`](db-script.md) ile aynı: `SET XACT_ABORT ON` + `TRY/TRANSACTION/CATCH/ROLLBACK/THROW`, her adımda `PRINT @@ROWCOUNT`, script gövdesinde **ASCII** (Türkçe karakter yok). DB'den bir şey doğrulaman gerekiyorsa [`mssql-read`](mssql-read.md) |

---

## 1. Dosya düzeni

```text
repos/.ai-agent/outputs/<YYYY-MM-DD>-<Is>-YukTesti/
├── 0-DOGRULAMA-NetTrexMM.sql              ← SALT-OKUNUR. Önce koşulur, şablonu buradan seçersin
├── 0-DOGRULAMA-NetTrexFX.sql
├── 1-NetTrexMM-YukTesti-<N>-Islem.sql     ← yazan script, DB başına bir dosya
├── 2-NetTrexFX-YukTesti-<N>-Islem.sql
├── 9-GERI-AL-NetTrexMM-YukTesti.sql       ← 9 = en son, geri alma
└── 9-GERI-AL-NetTrexFX-YukTesti.sql
```

## 2. Neyi klonla, neyi klonlama — **hedef sorgudan türet**

🔑 Klonlanacak tablo seti, **test edilen ekranın liste sorgusunun ve motorun okuduğu** tablolardan çıkar.
Kodu okumadan tablo ekleme/çıkarma yapma.

| Modül | Klonlanan | Neden | Bilinçli olarak YAZILMAYAN |
|---|---|---|---|
| **MM** | `TxnMM` (1 satır/klon) | Ana işlem | — |
| | `txnMMDetail` (şablonun **tüm** periyotları, `Id` IDENTITY, `TxnId` = klon) | Reeskont faiz periyodundan hesaplanır (`IsPrincipalAmount = 0`) | — |
| | `accEntryMain` **açılış başlığı** (`Type = 1`, 1 satır/klon, `Id` = `'55'` + `DefNumberGen(2)`) | Liste sorgusu açılış fişini **arıyor** (`ProductCode = MainProductCode`) | Bacaklar (`accEntry`, `accEngineGeneratedAccountRule`) — liste yalnız başlığa bakıyor, motor açılış fişini okumuyor. `MessageKey = 0` (Fimple anahtarı kopyalanmaz), `ReverseId = 0`, `IsReverse = 0` |
| | | | Reeskont fişleri (`Type = 2`), `txnMmDailyCalculation` → klonlar **"Not Rediscounted"** görünür |
| **FX** | `txnFX` (1 satır/klon) | Ana işlem | `txnFxValuation`, `accEntryMain/accEntry` (açılış), `TxnSync` — FX listesi açılış muhasebesi **aramıyor** |

**Üzerine yazılan kolonlar (gerisi `s.<kolon>`):**

| Kolon | MM `TxnMM` | FX `txnFX` | MM `accEntryMain` |
|---|---|---|---|
| `Id` | `m.NewId` (`55`+sayaç 1) | `m.NewId` (`11`+sayaç 1) | `m.NewMainId` (`55`+sayaç 2) |
| `LogicalReference` | `m.NewReference` | `m.NewReference` | — |
| `BusinessKey` | `m.NewBusinessKey` | `m.NewBusinessKey` (🔴 NULL olamaz — `BuildValuation` `.Value` okuyor) | `m.NewBusinessKey` |
| `ExternalReference`, `ExternalReferenceSourceId` | `NULL` | `NULL` | — |
| Bağlantılar | `RolloverParentTransactionId = NULL` | `LinkedTransactionId/Reference/Trader/ReasonType = NULL` | `TxnId = m.NewId`, `MessageKey/ReverseId/IsReverse = 0` |
| Tarih | `StateDate`, `CreatedDate = GETDATE()` | + `TradeDate/ValueDate = COALESCE(@param, s.*)` | `StateDate = GETDATE()` |

## 3. `DefNumberGen` sayaçları

| DB | `EntityColumnType` | Ne | Önek | Script ilerletir mi |
|---|---|---|---|:---:|
| `NetTrexMM` | 1 | `TransactionMM_Id` | `55` | ✅ `+N` |
| `NetTrexMM` | 2 | `AccountingEntryMain_Id` | `55` | ✅ `+N` (açılış başlığı klonlandığı için) |
| `NetTrexFX` | 1 | `TransactionFx_Id` | `11` | ✅ `+N` |
| `NetTrexFX` | 11 / 12 / 13 | `FxAccEntry_Id` / `GeneratedAccountingEntry_Id` / `FxAccEntryMain_Id` | — | ❌ (klonlanmıyor; test sırasında uygulama üretir) |

Formül koddakiyle aynı (`TransactionFactory` / `FxTransaction.Insert`: `int.Parse("<önek>" + sayaç)`;
`sp_GetNewNumbers` gibi `LastNumber += N`). **Geri almada sayaç geri sarılmaz** — boşluk kalır, zararsız.

## 4. Parametreler (yazan script'in başı)

| Parametre | Örnek | Not |
|---|---|---|
| `USE [...]` | `NetTrexMM` / `NetTrexFX` | 🔴 **Ortama göre düzelt** — DOGRULAMA sorgu 0 |
| `@TemplateReference` | MM: `N'TMMBRW2608170002'` · FX: `'TFXFW2609...'` | 🔴 **DOLDUR** — DOGRULAMA sorgu 1'den seçilir. Script'te placeholder (`TMMBRW2609XXXXXX`, `TFXFW2609XXXXXXX`) durur |
| `@CloneCount` | `3000` | 5 haneli sonek → önek başına en fazla 99999 |
| `@RefPrefix` | `N'TMMBRWYT'` / `'TFXFWYT'` | 🔴 GERI-AL'daki `@RefPrefix` ile **aynı** olmalı |
| `@BusinessKeyBase` | `999000000000000000` | Değiştirme |
| `@TradeDate`, `@ValueDate` (FX) | `NULL` | `NULL` → şablonunki. `ValueDate > TradeDate` zorunlu |

**Şablon seçim ölçütleri (DOGRULAMA sorgu 1):**

- **MM:** `StateId IN (18, 26)` (verified) · `ValueDate <= @D < MaturityDate` · ürünün `MainProductCode`'uyla açılış fişi (`accEntryMain Type = 1`) var · `@D`'yi kapsayan faiz periyodu (`txnMMDetail IsPrincipalAmount = 0`) var.
- **FX:** `(StateId & 6) = 2` (verified) · `InstrumentId IN (69 Spot, 70 Forward, 71 Future)` · `ValueDate > GETDATE()` · `ValueDate.Date > TradeDate.Date` · `LogicalReference NOT LIKE 'TFXSW%'`.
- ⭐ **En iyi şablon: daha önce reeskontu BAŞARIYLA kesilmiş olan** (`OncekiReeskont > 0`) — muhasebe kuralı / kur / faiz eğrisi o işlem için ortamda çalışıyor demektir.
- 🔴 Klonlar şablonun tarihlerini taşır — MM'de hepsi aynı `ValueDate/MaturityDate`. Test edilecek Execution Date'e göre şablonu seç.

## 5. Adım adım — yeni modül / ürün / adet için uyarlama

1. **Hedefi netleştir:** hangi ekran/servis, hangi Execution Date, kaç işlem, hangi DB(ler).
2. **Liste sorgusunu ve motoru kodda oku** → işlemin listeye girmesi için hangi tabloda hangi satır
   gerekiyor (MM: açılış `accEntryMain`; FX: yok). Klonlanacak tablo seti = bu (§2).
3. **Id üretimini kodda bul:** hangi tablo IDENTITY, hangisi `DefNumberGen`; `EntityColumnType` ve önek
   (`55`, `11`, ...). Bilmediğin önek/tip → DOGRULAMA'ya sorgu (sorgu 2-3 kalıbı), **uydurma**.
4. **Unique index + trigger + referans kuralları:** DOGRULAMA sorgu 4 (trigger) ve 6 (unique index) →
   üzerine yazılacak kolonlar (`LogicalReference`, `BusinessKey`, `ExternalReference` ...) ve History tablosu.
   Koddaki referans-önekinden alt ürün çözümü var mı bak (FX: `TFX` ile başlamalı, `TFXSW` swap'a düşer).
5. **Öneki seç:** `<modül referans ailesi>` + `YT` (MM `TMMBRWYT`, FX `TFXFWYT`). Kolon uzunluğuna
   `önek + 5 hane` sığmalı.
6. **`0-DOGRULAMA`'yı yaz** (emsal: [mm-dogrulama.md](yuk-testi/mm-dogrulama.md)): DB adı · şablon adayları
   `TOP (20)` · sayaçlar · sayaç sağlamlığı (`MAX(Id) < '<önek>' + LastNumber`) · trigger'lar · mevcut klon
   sayısı (0 beklenir) · unique index · dış senkron parametreleri (`NetTrexCommon.FrameworkParameter`).
7. **Yazan script'i emsalden kopyala** ([mm-3000-islem.md](yuk-testi/mm-3000-islem.md)), bölümleri koru:
   `1. KONTROLLER` (idempotency + şablon var mı + listeye girme koşulları, her biri ayrı `THROW 5000x`) →
   `2. ID SAYACLARI` (`UPDLOCK, HOLDLOCK`, int sınırı, `+N`) → `3. ESLEME TABLOSU` (`#CloneMap`: Tally
   `sys.all_objects CROSS JOIN`, n → NewId/NewReference/NewBusinessKey, aralık boş mu) → `4..` tablo başına
   dinamik `INSERT ... SELECT ... CROSS JOIN #CloneMap` → `COMMIT` → **GO sonrası kontrol `SELECT`'i**.
8. **`9-GERI-AL`'ı yaz** ([mm-geri-al.md](yuk-testi/mm-geri-al.md)): `#Clones` (önekle), `#Mains` → **yaprak→kök**
   sil. Klonladıklarının yanında **testin ürettiklerini** de sil (reeskont fişi, `txnMmDailyCalculation`,
   `txnFxValuation`, `accEngineGeneratedAccountRule`). Opsiyonel tablo/kolon → `OBJECT_ID` / `COL_LENGTH` guard.
9. **Önek her yerde aynı mı** — yazan script'in `@RefPrefix`'i, kontrol `SELECT`'indeki sabit `LIKE`,
   DOGRULAMA sorgu 5, GERI-AL `@RefPrefix` (§7 tuzak 4).
10. **Teslim** (§8).

## 6. Koşma sırası · doğrulama · geri alma

**Sıra (kullanıcı koşar):**

1. `0-DOGRULAMA-<DB>.sql` → DB adını, şablonu, sayaçları, trigger'ları kontrol et. Mevcut klon = **0** olmalı.
2. 🔴 Yük testinde **dış muhasebe senkronunu kapat**: `NetTrexCommon.FrameworkParameter`
   `Trex:FimpleAccountingSync = false` (DOGRULAMA sorgu 7). Açıkken Generate/Regenerate, Fimple'ın **hiç
   görmediği** klon referanslarıyla gerçek Fimple'a gider (reddedilir ya da çöp kayıt açar).
3. Yazan script'te `USE` + `@TemplateReference` doldur → koş. Beklenen çıktı:
   `Sablon: Id=...` · `DefNumberGen(1): X -> X+N` · `TxnMM: N klon eklendi.` · ... · `YUK TESTI VERISI BASARILI -- <DB>`.
4. Script sonundaki kontrol `SELECT`'i: MM → `KlonIslem = N`, `KlonDetay = N x (şablonun detay sayısı)`,
   `KlonAcilisFisi = N`. FX → `KlonSayisi = N`, `IlkRef/SonRef = <önek>00001 / <önek>0N`.
5. Ekranda doğrula: klonlar listede **"Not Rediscounted"** olarak görünmeli; sayfalama/Search/Generate/Regenerate ölçülür.
6. Bitince `9-GERI-AL-<DB>-YukTesti.sql` → `GERI ALMA BASARILI -- <DB>`, sonra DOGRULAMA sorgu 5 → **0**.

**Geri almanın silmedikleri:** Kafka ile `NetTrexAcc`'a gitmiş muhasebe kopyaları, Fimple'a gitmiş fişler
(sync açıkken test yapıldıysa), `DefNumberGen` sayaçları. Bunları script notuna ve teslim mesajına yaz.

| Silme sırası (yaprak→kök) | |
|---|---|
| **MM** | `txnMmDailyCalculation` → `accEngineGeneratedAccountRule` (`accEntry.EngineId` ile) → `accEntry` → `accEntryMain` → `txnMMDetail` → `TxnMMHistory` → `TxnMM` |
| **FX** | `txnFxValuation` → `accEngineGeneratedAccountRule` (`MainId` kolonu varsa) → `accEntry` → `accEntryMain` → `txnFXHistory` → `txnFX` |

`accEntryMain.ReverseId` kendi tablosuna FK → ters fiş çifti **tek `DELETE` ifadesinde** silinir.

---

## 7. Gotcha'lar

| 🔴 | Tuzak |
|---|---|
| 1 | ⭐ **`THROW 50001/50002 'Sablon islem bulunamadi (@TemplateReference).'`** — placeholder (`TMMBRW2609XXXXXX`) doldurulmadan koşuldu, ya da referans o DB'de yok (yanlış `USE`). Çözüm: DOGRULAMA sorgu 1'den gerçek referansı yaz, ör. `DECLARE @TemplateReference nvarchar(80) = N'TMMBRW2608170002';` (UAT'ta Manuel Reeskont testinde kullanılan MM işlemi — **ortama özgü**, başka DB'de yeniden seç). Teslimde bunu **ayrıca hatırlat** |
| 2 | Şablon verified değil / açılış fişi yok / faiz detayı yok / FX instrument dışı → `THROW 5000x`. Klonlar listede görünmeyeceği için bilerek durdurur — başka şablon seç |
| 3 | **Sayaç bozuk** (`MAX(Id) >= '<önek>' + LastNumber`) → `THROW 50007/50008` (MM) / `50008` (FX). Sayacı düzeltmeden koşma; DOGRULAMA sorgu 3 |
| 4 | **Kontrol `SELECT`'i ve DOGRULAMA sorgu 5 öneki SABİT yazıyor** (`'TMMBRWYT%'`, `'TFXFWYT%'`) — `GO` sonrası `@RefPrefix` görünmez. Öneki değiştirirsen **bu satırları ve GERI-AL'ı da** değiştir |
| 5 | **FX öneki `TFX` ile başlamalı, `TFXSW` ile BAŞLAMAMALI** — alt ürün referans önekinden çözülüyor; `TFXSW` → swap'a düşer, listeye girmez |
| 6 | FX `BusinessKey` NULL olamaz — `BuildValuation` `.Value` okuyor, patlar |
| 7 | `ExternalReference` kopyalanırsa mükerrer kontrolüne takılır → `NULL` |
| 8 | `Id = '<önek>' + sayaç` **int'e sığmalı** — `@CloneCount` büyükse `THROW 50006/50007` |
| 9 | Fimple sync açıkken Generate/Regenerate → gerçek Fimple'a çöp gider ve geri alma bunu **silemez** |
| 10 | `RETURN` (idempotent dal) transaction açıkken çıkmasın diye **önce `COMMIT`** |
| 11 | `GO` `TRY/CATCH` içine giremez — tüm yazma **tek batch**; kontrol `SELECT`'i `GO`'dan sonra ayrı batch |
| 12 | Tally `TOP (@CloneCount)` `sys.all_objects` × `sys.all_objects` — milyonlarca satır üretebilir, `@CloneCount` 5 haneyi (`99999`) geçmez |
| 13 | Klonlar **aynı müşteri/ürün/tarihleri** taşır — dağılım (farklı müşteri, vade) gereken testte bu desen yetmez; kullanıcıya söyle, birden fazla şablonla ayrı önekli koşu öner |
| 14 | Canlı/UAT'ta koşulmaz — geri alma da yalnız test ortamı içindir |

---

## 8. Teslim

Kullanıcıya **şunları** söyle:

1. Dosya yolları ve **koşma sırası** (`0` → `1`/`2` → test → `9`).
2. 🔴 **Doldurulması gerekenler:** `USE [...]` ve `@TemplateReference` (doldurulmazsa *"Sablon islem bulunamadi"*).
3. Fimple/dış senkron parametresinin kapatılması önerisi.
4. Hangi tabloların klonlandığı, hangilerinin bilinçli yazılmadığı (§2) → ekranda ne görünecek.
5. Geri almanın **silmediği** şeyler (Kafka/Fimple kopyaları, sayaçlar).
6. Doğrulanmamış varsayım varsa hangi DOGRULAMA sorgusunun doğrulayacağı.

Yeni öğrenilen her yük testi bilgisi (yeni modül, yeni tuzak) **bu dosyaya** eklenir; yeni referans
script'ler `yuk-testi/` klasörüne md olarak konur.
