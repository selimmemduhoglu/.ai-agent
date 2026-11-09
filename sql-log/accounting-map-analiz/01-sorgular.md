# 01-sorgular — accounting-map-analiz

Amaç: AccAccountMap seçim mantığını (NetTrex.Core `AccountingEngine.GetAccAccountMap`: Source==GLCode, IsEnabled, Path null/Contains, OrderBy(Order), ilk geçerli kural-seti kazanır) gerçek veriyle doğrulamak: Order eşitliği var mı, Path biçimleri, kuralsız (catch-all) satırlar, Ccy kullanımı (MM `HandleMap` ikinci remap), zincirli map riski.
Bağlantı: sqlcmd -S "tcp:192.168.10.211,1433" -d NetTrexAcc -U trusr -P '***' -C (salt-okunur, yalnız SELECT)
DB varyantı: NetTrexAcc (Acc repo docker-compose'u NetTrexAcc_Dev'i gösteriyor — canlı değil, analiz DB'si; A-04).

## #1 — Order eşitliği (aynı Source+Path+Order, birden çok aktif satır)
Amaç: Aynı Order'a düşen satırlarda seçim DB dönüş sırasına kalıyor mu — pratikte kaç grup var.
```sql
SET NOCOUNT ON;
SELECT TOP (20) Source, Path, [Order], COUNT(*) AS Adet
FROM dbo.AccAccountMap WHERE IsEnabled = 1
GROUP BY Source, Path, [Order] HAVING COUNT(*) > 1
ORDER BY COUNT(*) DESC;
```

## #2 — Path biçim dağılımı (aktif satırlar)
Amaç: Path NULL (global) / slash'lı / slash'sız / event adı içeren sayıları — `EventPath.Contains(Path)` semantiği için.
```sql
SET NOCOUNT ON;
SELECT CASE WHEN Path IS NULL THEN 'NULL'
            WHEN Path LIKE N'%/On%' THEN 'event-iceren'
            WHEN Path LIKE N'%/' THEN 'slash-sonlu'
            ELSE 'slash-siz' END AS Sekil, COUNT(*) AS Adet
FROM dbo.AccAccountMap WHERE IsEnabled = 1
GROUP BY CASE WHEN Path IS NULL THEN 'NULL'
            WHEN Path LIKE N'%/On%' THEN 'event-iceren'
            WHEN Path LIKE N'%/' THEN 'slash-sonlu'
            ELSE 'slash-siz' END
ORDER BY Adet DESC;
```

## #3 — Kuralsız (catch-all) satırlar ve Order aralığı
Amaç: Hiç ValidationRule (Rule1..10) olmayan satır "her zaman geçerli" — Order'ı kurallı satırlardan büyük mü (gölgeleme riski).
```sql
SET NOCOUNT ON;
SELECT CASE WHEN RuleId IS NULL AND Rule2Id IS NULL AND Rule3Id IS NULL AND Rule4Id IS NULL AND Rule5Id IS NULL
             AND Rule6Id IS NULL AND Rule7Id IS NULL AND Rule8Id IS NULL AND Rule9Id IS NULL AND Rule10Id IS NULL
            THEN 'kuralsiz' ELSE 'kurali' END AS Tip,
       COUNT(*) AS Adet, MIN([Order]) AS MinOrder, MAX([Order]) AS MaxOrder
FROM dbo.AccAccountMap WHERE IsEnabled = 1
GROUP BY CASE WHEN RuleId IS NULL AND Rule2Id IS NULL AND Rule3Id IS NULL AND Rule4Id IS NULL AND Rule5Id IS NULL
             AND Rule6Id IS NULL AND Rule7Id IS NULL AND Rule8Id IS NULL AND Rule9Id IS NULL AND Rule10Id IS NULL
            THEN 'kuralsiz' ELSE 'kurali' END;
```

## #4 — Ccy kolonu doluluğu
Amaç: Motor `Ccy`'yi filtrelemiyor, MM `HandleMap` `Ccy == Fcy` ile eşliyor — kolon gerçekten dolu mu.
```sql
SET NOCOUNT ON;
SELECT CASE WHEN Ccy IS NULL THEN 'NULL' WHEN LTRIM(RTRIM(Ccy)) = '' THEN 'bos' ELSE 'dolu' END AS Ccy_Durum, COUNT(*) AS Adet
FROM dbo.AccAccountMap WHERE IsEnabled = 1
GROUP BY CASE WHEN Ccy IS NULL THEN 'NULL' WHEN LTRIM(RTRIM(Ccy)) = '' THEN 'bos' ELSE 'dolu' END;
```

## #5 — Zincirli map (bir satırın Target'ı başka aktif satırın Source'u)
Amaç: Engine GLCode'u Target'a çevirir, sonra MM HandleMap Target'ı tekrar Source diye arar — zincir var mı sayısı.
```sql
SET NOCOUNT ON;
SELECT COUNT(*) AS ZincirliSatir
FROM dbo.AccAccountMap a
WHERE a.IsEnabled = 1 AND a.Target IS NOT NULL
  AND EXISTS (SELECT 1 FROM dbo.AccAccountMap b WHERE b.IsEnabled = 1 AND b.Source = a.Target);
```

## #6 — StateId dağılımı (aktif satırlar)
Amaç: Select handler `VerifiedStatesId` filtreliyor — aktif satırların kaçı verified dışı (motora hiç gelmez).
```sql
SET NOCOUNT ON;
SELECT StateId, COUNT(*) AS Adet FROM dbo.AccAccountMap WHERE IsEnabled = 1 GROUP BY StateId ORDER BY Adet DESC;
```

## #7 — Gölgelenen satırlar (aynı Source+Path'te kuralsız satır, daha küçük/eşit Order)
Amaç: Kuralsız satır her zaman geçerli → aynı Source+Path grubunda ondan SONRA gelen (Order büyük) kurallı satır motora hiç seçilemez. Kaç satır etkileniyor (kaba sayım, aynı Path birebir eşleşmesiyle).
```sql
SET NOCOUNT ON;
SELECT COUNT(*) AS GolgelenenKuralliSatir
FROM dbo.AccAccountMap k
WHERE k.IsEnabled = 1
  AND (k.RuleId IS NOT NULL OR k.Rule2Id IS NOT NULL OR k.Rule3Id IS NOT NULL OR k.Rule4Id IS NOT NULL OR k.Rule5Id IS NOT NULL
    OR k.Rule6Id IS NOT NULL OR k.Rule7Id IS NOT NULL OR k.Rule8Id IS NOT NULL OR k.Rule9Id IS NOT NULL OR k.Rule10Id IS NOT NULL)
  AND EXISTS (SELECT 1 FROM dbo.AccAccountMap c
              WHERE c.IsEnabled = 1 AND c.Source = k.Source AND ISNULL(c.Path, N'') = ISNULL(k.Path, N'')
                AND c.RuleId IS NULL AND c.Rule2Id IS NULL AND c.Rule3Id IS NULL AND c.Rule4Id IS NULL AND c.Rule5Id IS NULL
                AND c.Rule6Id IS NULL AND c.Rule7Id IS NULL AND c.Rule8Id IS NULL AND c.Rule9Id IS NULL AND c.Rule10Id IS NULL
                AND c.[Order] < k.[Order]);
```

## #6 (tekrar) — StateId dağılımı
Not: İlk çalıştırmada çıktı kaydedilemedi (benim `tee` yol hatam — sorgu çalıştı, çıktı yazılamadı). Aynı sorgu tekrar çalıştırıldı.

## #8 — Ccy dolu 14 aktif satır
Amaç: MM `HandleMap` (Source==GLCode && Ccy==Fcy, SingleOrDefault) fiilen hangi satırlarda devreye girebilir; hangi Source/Path'ler.
```sql
SET NOCOUNT ON;
SELECT TOP (20) Id, Source, Ccy, Path, Target, [Order]
FROM dbo.AccAccountMap WHERE IsEnabled = 1 AND Ccy IS NOT NULL ORDER BY Id DESC;
```

## #9 — Motor adayı simülasyonu: Source=FxPositionLCY, EventPath=TREX/BRWPLC1/MONEYMARKET/BRW/FCY/OnRevaluation
Amaç: Ekran görüntüsündeki reeskont bacağı için motorun aday listesini (ordinal Source, Path null/Contains, Order sıralı) SQL'de taklit edip önerilen okuma şablonunu doğrulamak; popup'taki (harf duyarsız) listeyle farkı görmek.
```sql
SET NOCOUNT ON;
SELECT TOP (20) Id, Source, Path, [Order], Target, TargetRuleId, RuleId, Rule2Id, Rule3Id, Rule4Id, Rule5Id, Rule6Id, Rule7Id, Rule8Id, Rule9Id, Rule10Id, StateId
FROM dbo.AccAccountMap
WHERE IsEnabled = 1
  AND Source COLLATE Latin1_General_BIN2 = N'FxPositionLCY' COLLATE Latin1_General_BIN2
  AND (Path IS NULL OR CHARINDEX(Path COLLATE Latin1_General_BIN2, N'TREX/BRWPLC1/MONEYMARKET/BRW/FCY/OnRevaluation' COLLATE Latin1_General_BIN2) > 0)
ORDER BY [Order], Id;
```

## #10 — Aynı kaynak, harf duyarsız (popup davranışı): Source = FxPositionLCY, collation varsayılan
Amaç: Popup'ın SQL collation ile gösterdiği satırların motor adayından farkı (FXPositionLCY satırları).
```sql
SET NOCOUNT ON;
SELECT TOP (20) Id, Source, Path, [Order], Ccy, Target
FROM dbo.AccAccountMap
WHERE IsEnabled = 1 AND Source = N'FxPositionLCY'
ORDER BY Id DESC;
```
