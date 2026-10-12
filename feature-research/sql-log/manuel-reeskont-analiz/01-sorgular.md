# SQL Sorguları — Sohbet: `manuel-reeskont-analiz`

> 🔴 **Bu dosya bir DENETİM KAYDIDIR.** Kullanıcının talimatı (2026-08-13):
> *"ben senin her SQL'e bağlanıp sorduğun soruyu ve response'unu görmek istiyorum ama **istisnasız
> hepsinin** çünkü tehlikeli aslında DB'ye bağlanman, o yüzden görmem lazım"*
>
> **Kural:** DB'ye giden **HER** sorgu — başarılı, başarısız, keşif, tekrar — buraya yazılır.
> Çıktıları → [`02-ciktilar.md`](02-ciktilar.md) (aynı `#` numarası ile eşleşir).
> **Hiçbir sorgu atlanmaz.** Sorguyu çalıştırmadan **önce** buraya yaz.

**Sohbet:** Manuel Reeskont — analiz & mimari · **Session id:** `4bedf830-dc64-4a25-922a-6dd86ca8e2be`
**Bağlantı:** `tcp:192.168.10.211,1433` / `NetTrexMM` / kullanıcı `trusr`
(kaynak: `NetTrex.MM/Code/docker-compose.override.yml:24`)

---

## Özet tablo

| # | Tarih      | Amaç                                                                                | Tablo            | Sonuç                                        |
| - | ---------- | ------------------------------------------------------------------------------------ | ---------------- | --------------------------------------------- |
| 1 | 2026-08-13 | Bağlantı testi + reeskont/muhasebe tablolarını ara                               | `sys.tables`   | ❌**BAŞARISIZ** — Named Pipes hatası |
| 2 | 2026-08-13 | Bağlantı testi (tcp ile tekrar)                                                    | `sys.tables`   | ✅ 5 satır                                   |
| 3 | 2026-08-13 | **M-08** — fiş/ters fiş dağılımı, `ReverseId`/`MessageKey` NULL mı | `AccEntryMain` | ✅ 6 satır                                   |
| 4 | 2026-08-13 | `AccEntryMain` kolon şeması                                                      | `sys.columns`  | ✅ 22 satır                                  |
| 5 | 2026-08-13 | **M-08** — son 20 revaluation kaydında zincir yapısı                       | `AccEntryMain` | ✅ 20 satır                                  |

**Toplam:** 5 sorgu · 5 `SELECT` · **0 yazma işlemi** · 1 başarısız (bağlantı hatası)

---

## 8 — Sunucudaki veritabanlarını listele

**Amaç:** Kullanıcı `NetTrexAcc` (muhasebe) ve `NetTrexFx` veritabanlarından bahsetti. Hangi DB'ler
gerçekten var, adları tam olarak ne?

```sql
SET NOCOUNT ON;
SELECT name, state_desc FROM sys.databases ORDER BY name;
```

---

## 9 — `NetTrexAcc` tablo listesi

**Amaç:** Muhasebe tarafını öğrenmek — hangi tablolar var, isimlendirme nasıl.

```sql
-- NetTrexAcc üzerinde
SET NOCOUNT ON;
SELECT name FROM sys.tables ORDER BY name;
```

---

## 10 — `NetTrexAcc` tablo boyutları (kayıt sayısı)

**Amaç:** Hangi tablolar gerçekten kullanılıyor (dolu), hangileri boş — muhasebe akışının merkezini bulmak.
**Not:** Satır çekmeden, yalnız sayı → token korunur (skill kuralı 5).

```sql
SET NOCOUNT ON;
SELECT TOP (30) t.name AS TableName, SUM(p.rows) AS [Rows]
FROM sys.tables t
JOIN sys.partitions p ON p.object_id = t.object_id AND p.index_id IN (0,1)
GROUP BY t.name
ORDER BY SUM(p.rows) DESC;
```

---

## 15 — Muhasebe motoru şemaları (3 tablo)

**Amaç:** #11 kolon adlarını tahmin ettiğim için **hata aldı**; gerçek şemaları almak.

```sql
-- NetTrexAcc — AccEngineEvent, AccEngineItem, AccEngineAccountRule, AccEngineComponent, AccEngineGroup için tekrarlandı
SET NOCOUNT ON;
SELECT c.name + ' ' + t.name AS Kolon
FROM sys.columns c JOIN sys.types t ON t.user_type_id = c.user_type_id
WHERE c.object_id = OBJECT_ID('dbo.<TABLO>')
ORDER BY c.column_id;
```

---

## 16 — `OnRevaluation` hangi ürünlerde + MM ürün ağacı

**Amaç:** Reeskontun GL kurallarının hangi ürün ağacında tanımlı olduğunu bulmak.
İlk denenen join (`ItemCode IN ('MM','MURABAHA') AND EventTypeCode='OnRevaluation'`) **0 satır** döndü —
sebebini anlamak için.

```sql
SET NOCOUNT ON;
SELECT TOP (25) i.ItemCode, i.Path, COUNT(*) AS EventAdet
FROM dbo.AccEngineItem i
JOIN dbo.AccEngineEvent e ON e.ItemId = i.Id
WHERE e.EventTypeCode = 'OnRevaluation'
GROUP BY i.ItemCode, i.Path
ORDER BY i.Path;

SET NOCOUNT ON;
SELECT TOP (20) Id, ItemCode, Path
FROM dbo.AccEngineItem
WHERE Path LIKE 'TREX/MM%'
ORDER BY Path;
```

> ⚠️ Ayrıca çalıştırılan ve **0 satır** dönen join (kurgunun kendisini ortaya çıkardı):
> `AccEngineItem → AccEngineEvent → AccEngineGroup → AccEngineComponent → AccEngineAccountRule`
> filtre: `i.ItemCode IN ('MM','MURABAHA') AND e.EventTypeCode='OnRevaluation'`

---

## 11 — `NetTrexAcc` muhasebe motoru: olay tipleri

**Amaç:** Muhasebe motorunun (`AccEngine*`) nasıl kurgulandığını öğrenmek. Reeskont (Revaluation)
hangi olay/ürün altında tanımlı?

```sql
-- NetTrexAcc
SET NOCOUNT ON;
SELECT TOP (20) Id, Name, Code, EventTypeId FROM dbo.AccEngineEvent ORDER BY Id DESC;
```

---

## 12 — `NetTrexAcc` vs `NetTrexMM`: `AccEntryMain` şeması aynı mı?

**Amaç:** Muhasebe fişi hem MM'de hem Acc'te tutuluyor. İki şema aynı mı, fark ne?
Manuel Reeskont'un fişi hangisine yazıyor?

```sql
-- NetTrexAcc
SET NOCOUNT ON;
SELECT c.name + ' ' + t.name AS Kolon
FROM sys.columns c JOIN sys.types t ON t.user_type_id = c.user_type_id
WHERE c.object_id = OBJECT_ID('dbo.AccEntryMain')
ORDER BY c.column_id;
```

---

## 13 — `NetTrexAcc.AccEntryMain` — son 20 kayıt

**Amaç:** Acc tarafındaki fişlerin MM'dekilerle ilişkisi (ProductCode, Type dağılımı, MM'den mi geliyor).

```sql
-- NetTrexAcc
SET NOCOUNT ON;
SELECT TOP (20) Id, ValueDate, ProductCode, Type, IsReverse, ReverseId, MessageKey, StateMaker
FROM dbo.AccEntryMain
ORDER BY Id DESC;
```

---

## 14 — `NetTrexMM` dolu tablolar

**Amaç:** MM tarafının tablo envanteri — hangi tablolar merkezde.

```sql
-- NetTrexMM
SET NOCOUNT ON;
SELECT TOP (25) t.name AS TableName, SUM(p.rows) AS Kayit
FROM sys.tables t
JOIN sys.partitions p ON p.object_id = t.object_id AND p.index_id IN (0,1)
GROUP BY t.name
ORDER BY SUM(p.rows) DESC;
```

---

## 7 — Faz 1 testi için veri olan tarihi bul ✅

**Amaç:** `eligible-transactions` ucu `2026-08-05` için `totalCount: 0` döndü. Uç çalışıyor ama
`NetTrexMM_Dev`'de o tarihte uygun kayıt yok. Hangi tarihte reeskont kaydı var, onu bulmak için.

```sql
SET NOCOUNT ON;
SELECT TOP (20) ValueDate, COUNT(*) AS Adet
FROM dbo.AccEntryMain
WHERE Type = 2
GROUP BY ValueDate
ORDER BY ValueDate DESC;
```

---

## 6 — Test için hangi DB'de veri var? ✅

**Amaç:** MM API'nin `launchSettings.json`'ı **`NetTrexMM_Dev`**'e bakıyor, oysa M-08 analizini
**`NetTrexMM`**'de yapmıştım. Faz 1'i test ederken hangi veritabanını kullanacağımı belirlemek için
ikisinde de reeskonta uygun kayıt var mı kontrol edildi.

```sql
-- NetTrexMM_Dev üzerinde
SET NOCOUNT ON;
SELECT COUNT(*) AS RevaluationKayitSayisi FROM dbo.AccEntryMain WHERE Type = 2;
```

```bash
sqlcmd -S "tcp:192.168.10.211,1433" -d NetTrexMM_Dev -U trusr -P '***' -C -l 20 -W -s "|" -Q "..."
```

---

## 1 — Bağlantı testi + tablo arama ❌

**Amaç:** `sqlcmd` çalışıyor mu, reeskont/muhasebe tabloları hangi adlarla var?

```sql
SET NOCOUNT ON;
SELECT TOP 5 name FROM sys.tables
WHERE name LIKE '%Revaluation%' OR name LIKE '%accEntry%'
ORDER BY name;
```

```bash
sqlcmd -S 192.168.10.211 -d NetTrexMM -U trusr -P '***' -C -l 15 -W -s "|" -Q "..."
```

**Sonuç:** ❌ Bağlanamadı — `-S` parametresinde `tcp:` öneki ve port yok → Named Pipes'a düştü.
→ Skill'e `G-01` gotcha'sı olarak yazıldı.

---

## 2 — Bağlantı testi (tcp ile) ✅

**Amaç:** Aynı test, `tcp:IP,1433` ile.

```sql
SET NOCOUNT ON;
SELECT TOP 5 name FROM sys.tables ORDER BY name;
```

```bash
sqlcmd -S "tcp:192.168.10.211,1433" -d NetTrexMM -U trusr -P '***' -C -l 20 -W -s "|" -Q "..."
```

---

## 3 — `AccEntryMain` dağılımı (M-08 için) ✅

**Amaç:** Durum türetme kuralını bulmak. Reeskont fişi ile ters fişi ayıran alan hangisi,
`ReverseId` ve `MessageKey` NULL olabiliyor mu?
**Neden satır çekmedim:** `GROUP BY` + `COUNT` yeterli → token korunur (skill kuralı 5).

```sql
SET NOCOUNT ON;
SELECT Type,
       IsReverse,
       COUNT(*) AS Adet,
       SUM(CASE WHEN ReverseId  IS NULL THEN 1 ELSE 0 END) AS ReverseIdNull,
       SUM(CASE WHEN MessageKey IS NULL THEN 1 ELSE 0 END) AS MsgKeyNull
FROM dbo.AccEntryMain
GROUP BY Type, IsReverse
ORDER BY Type, IsReverse;
```

---

## 4 — `AccEntryMain` kolon şeması ✅

**Amaç:** 5 numaralı sorguyu `SELECT *` yapmadan yazabilmek için kolon adları ve tipleri
(skill kuralı 3: kolonlar tek tek yazılır).

```sql
SET NOCOUNT ON;
SELECT c.name + ' ' + t.name AS Kolon
FROM sys.columns c
JOIN sys.types t ON t.user_type_id = c.user_type_id
WHERE c.object_id = OBJECT_ID('dbo.AccEntryMain')
ORDER BY c.column_id;
```

---

## 5 — Son 20 revaluation kaydı (M-08 kesinleştirme) ✅

**Amaç:** Fiş ↔ ters fiş zincirinin **nasıl** kurulduğunu görmek: `ReverseId` yönü,
ters alınmamış kaydın nasıl göründüğü, `StateMaker`'ın ters fişte ne olduğu (`T-01` doğrulaması).
**Kurallar:** `TOP (20)` ✅ · `ORDER BY Id DESC` ✅ · kolonlar tek tek ✅

```sql
SET NOCOUNT ON;
SELECT TOP (20)
       Id, TxnId, ValueDate, IsReverse, ReverseId,
       MessageKey, ExternalState, ProductCode, TxnTypeCode, StateMaker
FROM dbo.AccEntryMain
WHERE Type = 2                 -- 2 = Revaluation
ORDER BY Id DESC;
```
