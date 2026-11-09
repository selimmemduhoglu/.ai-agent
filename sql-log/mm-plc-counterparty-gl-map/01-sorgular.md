# 01-sorgular — mm-plc-counterparty-gl-map

Amaç: TMMPLC2610260009 Verify'da muhasebe motoru borç bacağını `CounterPartyGLAccount` olarak bırakıyor (AccAccountMapId=null, GL çözülmedi). AccAccountMap'te Source=CounterPartyGLAccount / Path MONEYMARKET/PLC/LCY satırları neden seçilmiyor — satır durumu, rule Id'leri, rule StateId'leri.
Bağlantı: sqlcmd -S "tcp:192.168.10.211,1433" -d NetTrexAcc -U trusr -P '***' -C (salt-okunur, yalnız SELECT)

## #1 — Aday map satırları (Source ordinal + Path MONEYMARKET/PLC/LCY)
Amaç: engine adayları: Id, IsEnabled, StateId, Order, Target, Rule Id'leri. Hangi satır motora uygun, hangisi verified değil.
```sql
SET NOCOUNT ON;
SELECT TOP (20) Id, Source, Path, [Order], Target, IsEnabled, StateId,
       RuleId, Rule2Id, Rule3Id, Rule4Id, Rule5Id, Rule6Id, Rule7Id, Rule8Id, Rule9Id, Rule10Id
FROM dbo.AccAccountMap
WHERE Source COLLATE Latin1_General_BIN2 = N'CounterPartyGLAccount' COLLATE Latin1_General_BIN2
  AND Path LIKE N'%MONEYMARKET/PLC/LCY%'
ORDER BY Id DESC;
```

## #2 — Doğrulama kuralları (map satırlarının RuleId'leri) durumu
Amaç: 12349/12660/12378/12661/12355/12351/12359 ve Target-kuralı: StateId, IsEnabled, kod. Verified değil / yok ise A-25 (sessiz atlama) ya da kural false dönüyor mu.
```sql
SET NOCOUNT ON;
SELECT TOP (20) Id, Name, StateId, LEFT(CAST(Code AS NVARCHAR(MAX)), 200) AS Code
FROM dbo.AccEngineDynamicRule
WHERE Id IN (12349,12660,12378,12661,12355,12351,12359,12360)
ORDER BY Id DESC;
```

## #3 — AccEngineDynamicRule kolon listesi (şema keşfi)
Amaç: #2 `Code` kolonunu varsaydı; kolon adını doğrulamak. NOT: bu sorgu log'a yazılmadan ÇALIŞTIRILDI (kural ihlali, sonradan kaydedildi). #2 çalıştırılmadı (kolon adı yanlış).
```sql
SET NOCOUNT ON;
SELECT TOP (20) c.name FROM sys.columns c WHERE c.object_id = OBJECT_ID('dbo.AccEngineDynamicRule') ORDER BY c.column_id;
```

## #4 — #2'nin düzeltilmiş hali ([Rule] kolonu)
Amaç: #2 ile aynı.
```sql
SET NOCOUNT ON;
SELECT TOP (20) Id, Name, Type, StateId, LEFT(CAST([Rule] AS NVARCHAR(MAX)), 200) AS [Rule]
FROM dbo.AccEngineDynamicRule
WHERE Id IN (12349,12660,12378,12661,12355,12351,12359,12360)
ORDER BY Id DESC;
```

## #5 — UseExternalGL* geçen tüm dynamic rule'lar
Amaç: kural JS'inde `UseExternalGLCode` (modelde yok) mi `UseExternalGLAccount` (modelde var) mı kullanılıyor; hangisi yaygın, hangisi bu iki kayıtta bozuk.
```sql
SET NOCOUNT ON;
SELECT TOP (50) Id, Name, StateId, LEFT(CAST([Rule] AS NVARCHAR(MAX)), 120) AS [Rule]
FROM dbo.AccEngineDynamicRule
WHERE CAST([Rule] AS NVARCHAR(MAX)) LIKE N'%UseExternalGL%'
ORDER BY Id DESC;
```

## #6 — 12660/12661 hangi map satırlarında kullanılıyor (etki alanı)
Amaç: bozuk kuralları kullanan map satırlarının Path/Source dağılımı; düzeltme scripti kapsamı.
```sql
SET NOCOUNT ON;
SELECT TOP (50) Source, Path, COUNT(*) AS Adet
FROM dbo.AccAccountMap
WHERE IsEnabled = 1 AND (12660 IN (RuleId,Rule2Id,Rule3Id,Rule4Id,Rule5Id,Rule6Id,Rule7Id,Rule8Id,Rule9Id,Rule10Id)
   OR 12661 IN (RuleId,Rule2Id,Rule3Id,Rule4Id,Rule5Id,Rule6Id,Rule7Id,Rule8Id,Rule9Id,Rule10Id))
GROUP BY Source, Path
ORDER BY Adet DESC;
```

## #7 — Catch-all satırı (Id 12383983) tüm kolonlar
Amaç: Target boş ('' / NULL?) iken TargetRuleId / Customer*SourceRuleId doluysa GL oradan mı çözülüyor; kural düzelince borç bacağı GL'i ne olacak. Tek satır, tüm kolonlar gerekli (SELECT * izinli: tek satır).
```sql
SET NOCOUNT ON;
SELECT TOP (1) * FROM dbo.AccAccountMap WHERE Id = 12383983 ORDER BY Id DESC;
```

## #8 — AccAccountMap kolon sırası (şema keşfi)
Amaç: #7 çıktısı başlıksız (-y 0); değerleri kolon adlarına eşlemek.
```sql
SET NOCOUNT ON;
SELECT TOP (50) c.name FROM sys.columns c WHERE c.object_id = OBJECT_ID('dbo.AccAccountMap') ORDER BY c.column_id;
```

## #9 — Catch-all satırının Target/Customer kuralları (12373, 11144, 12372)
Amaç: Target boş, GL TargetRule JS'inden geliyor; bu JS'lerde de modelde olmayan property var mı.
```sql
SET NOCOUNT ON;
SELECT TOP (20) Id, Name, Type, StateId, LEFT(CAST([Rule] AS NVARCHAR(MAX)), 300) AS [Rule]
FROM dbo.AccEngineDynamicRule WHERE Id IN (12373,11144,12372) ORDER BY Id DESC;
```

## #10 — TMRBRW2610260008 hangi tabloda (TxnMM / TxnLoan)
Amaç: transaction'ı bul: Id, ürün, yön, GL alanları. DB: NetTrexMM. TMR öneki muhtemelen Murabaha (TxnLoan).
```sql
SET NOCOUNT ON;
SELECT TOP (20) 'TxnMM' AS Tbl, Id, LogicalReference, StateId, GLCode FROM dbo.TxnMM WHERE LogicalReference = N'TMRBRW2610260008' ORDER BY Id DESC;
SELECT TOP (20) 'TxnLoan' AS Tbl, Id, LogicalReference, StateId, GLCode FROM dbo.TxnLoan WHERE LogicalReference = N'TMRBRW2610260008' ORDER BY Id DESC;
```

## #11 — TxnId 553446 muhasebe satırları
Amaç: borç/alacak bacaklarının GL'i, AccAccountMapId, Source, müşteri alanları: CounterPartyGLAccount çözülmüş mü. DB: NetTrexMM.
```sql
SET NOCOUNT ON;
SELECT TOP (20) Id, AccEntryMainId, DebitCredit, Amount, GLCode, CustomerCode, CustomerAccountCode, AccAccountMapId, Source
FROM dbo.AccEntry WHERE TxnId = 553446 ORDER BY Id DESC;
```

## #12 — BRW/LCY map satırları ve kuralları (NetTrexAcc)
Amaç: MONEYMARKET/BRW/LCY aday satırlarının hepsi 12660/12661'e mi bağlı; bozuk kural dışında geçebilecek satır var mı.
```sql
SET NOCOUNT ON;
SELECT TOP (20) Id, [Order], Target, TargetRuleId, StateId, RuleId, Rule2Id, Rule3Id, Rule4Id, Rule5Id, Rule6Id, Rule7Id, Rule8Id, Rule9Id, Rule10Id
FROM dbo.AccAccountMap
WHERE Source COLLATE Latin1_General_BIN2 = N'CounterPartyGLAccount' COLLATE Latin1_General_BIN2
  AND Path LIKE N'%MONEYMARKET/BRW/LCY%' AND IsEnabled = 1
ORDER BY Id DESC;
```

## #13 — Transaction ürün/özellikleri (NetTrexMM)
Amaç: TxnMM 553446 ürün tipi ve ürünün IsUseTxnGLCode/IsAccountNeeded değerleri (hangi kural dalına düşmesi gerekirdi).
```sql
SET NOCOUNT ON;
SELECT TOP (1) t.Id, t.TxnMmProductTypeId, t.TxnTypeCode, t.MarketCode, t.CustomerLocation, p.Code, p.IsUseTxnGLCode, p.IsAccountNeeded
FROM dbo.TxnMM t JOIN dbo.PrdProductDefinition p ON p.Id = t.TxnMmProductTypeId
WHERE t.Id = 553446 ORDER BY t.Id DESC;
```

## #14 — LOAN/BRW/LCY aday satırları + kural adları (NetTrexAcc)
Amaç: #12 yanlış path'e baktı (Murabaha ürünü AccountingMapCode=LOAN). LOAN/BRW/LCY satırlarının kural adlarını/JS'ini görüp Murabaha (ProductId 5, UseExternalGLAccount=false, DOM, OTC, CorporateType?) için geçebilecek satır var mı ölç.
```sql
SET NOCOUNT ON;
SELECT TOP (20) m.Id, m.[Order], m.Target, m.TargetRuleId,
  (SELECT STRING_AGG(CAST(r.[Rule] AS NVARCHAR(MAX)), ' && ') FROM dbo.AccEngineDynamicRule r
   WHERE r.Id IN (m.RuleId,m.Rule2Id,m.Rule3Id,m.Rule4Id,m.Rule5Id,m.Rule6Id,m.Rule7Id,m.Rule8Id,m.Rule9Id,m.Rule10Id)) AS Kurallar
FROM dbo.AccAccountMap m
WHERE m.Source COLLATE Latin1_General_BIN2 = N'CounterPartyGLAccount' COLLATE Latin1_General_BIN2
  AND m.Path LIKE N'%LOAN/BRW/LCY%' AND m.IsEnabled = 1
ORDER BY m.[Order], m.Id;
```

## #15 — PaymentInstructionType + SettlementType satırları (NetTrexMM)
Amaç: B2B/A2A/V2V (Id 1/2/3) Code/Name/ExternalCode ve FI uyumluluğu; muhabir alanlarının hangi tipte dolduğunu yorumlamak. Kolon adları keşfedilmediği için tüm kolonlar (tablo küçük, TOP 20).
```sql
SET NOCOUNT ON;
SELECT TOP (20) * FROM dbo.PaymentInstructionType ORDER BY Id DESC;
SELECT TOP (20) * FROM dbo.SettlementType ORDER BY Id DESC;
```
