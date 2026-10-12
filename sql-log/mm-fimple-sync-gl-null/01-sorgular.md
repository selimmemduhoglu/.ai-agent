# SQL Sorguları — mm-fimple-sync-gl-null

Amaç: MM'de Fimple sync sırasında `IncomingPaymentAccountingGL` / `OutgoingPaymentAccountingGL`
kolonlarının bazı işlemlerde NULL kalmasının sebebini gerçek veriden doğrulamak.
Bağlantı: 192.168.10.211 / NetTrexMM_134 / trusr / -P '***'

## 1 — Hangi DB'de bu LogicalReference'lar var + TxnMM GL alanları
Amaç: Osman'ın ekran görüntüsündeki NULL satır (TWABRW2609110002) ile dolu satırları
(TWABRW2609170002, TWABRW2609180001/2) yan yana görüp farkı bulmak.
```sql
SET NOCOUNT ON;
SELECT TOP (20) Id, LogicalReference, SettlementTypeId, IsIntraBank,
       IncomingPaymentAccountingGL, IncomingPaymentAccountingType, IncomingPaymentAccountingGLType,
       OutgoingPaymentAccountingGL, OutgoingPaymentAccountingType, OutgoingPaymentAccountingGLType,
       ProductId, StateId, BusinessKey
FROM dbo.TxnMM
ORDER BY Id DESC;
```

## 2 — TxnMM kolon listesi (1 numaralı sorgu Invalid column name aldı)
Amaç: IsIntraBank / ProductId kolonlarının gerçek adını bulmak.
```sql
SET NOCOUNT ON;
SELECT c.name, t.name AS type, c.is_nullable
FROM sys.columns c JOIN sys.types t ON t.user_type_id=c.user_type_id
WHERE c.object_id = OBJECT_ID('dbo.TxnMM') ORDER BY c.column_id;
```

## 3 — TxnMM son 20 kayıt, GL + type + settlement alanları (düzeltilmiş kolon adları)
Amaç: NULL GL olan satırları dolu olanlarla karşılaştırmak; SettlementTypeId/type ilişkisini görmek.
```sql
SET NOCOUNT ON;
SELECT TOP (20) Id, LogicalReference, TxnMmProductTypeId, SettlementTypeId, CustomerIsFinancialInstitution,
       IncomingPaymentAccountingGL, IncomingPaymentAccountingType, IncomingPaymentAccountingGLType,
       OutgoingPaymentAccountingGL, OutgoingPaymentAccountingType, OutgoingPaymentAccountingGLType,
       StateId, BusinessKey
FROM dbo.TxnMM ORDER BY Id DESC;
```

## 4 — StateId=18 (muhasebeleşmiş) işlemlerde NULL GL dağılımı
Amaç: NULL'un hangi ürün tipi / settlement tipi / GLType kombinasyonunda oluştuğunu görmek
(StateId 16 = henüz onaylanmamış, muhasebe yok, NULL normal — onları hariç tut).
```sql
SET NOCOUNT ON;
SELECT TOP (20) TxnMmProductTypeId, SettlementTypeId, IncomingPaymentAccountingType,
       IncomingPaymentAccountingGLType, CustomerIsFinancialInstitution,
       COUNT(*) AS Adet, SUM(CASE WHEN IncomingPaymentAccountingGL IS NULL THEN 1 ELSE 0 END) AS InGLNull,
       SUM(CASE WHEN OutgoingPaymentAccountingGL IS NULL THEN 1 ELSE 0 END) AS OutGLNull
FROM dbo.TxnMM WHERE StateId = 18
GROUP BY TxnMmProductTypeId, SettlementTypeId, IncomingPaymentAccountingType,
         IncomingPaymentAccountingGLType, CustomerIsFinancialInstitution
ORDER BY InGLNull DESC;
```

## 5 — AccEntry tablosunda Source değerlerinin dağılımı
Amaç: FindPaymentClearingGLCodes "Source LIKE %IncomingPayment%" filtresiyle çalışıyor.
Gerçekte Source'ta hangi değerler var, kaçı NULL?
```sql
SET NOCOUNT ON;
SELECT TOP (20) Source, COUNT(*) AS Adet FROM dbo.AccEntry GROUP BY Source ORDER BY COUNT(*) DESC;
```

## 6 — AccEntry.Source dağılımı (sonuç: IncomingAgentPaymentAmount / OutgoingAgentPaymentAmount var!)
```sql
SET NOCOUNT ON;
SELECT TOP (20) ISNULL(Source,'<NULL>') AS Src, COUNT(*) AS Adet
FROM dbo.AccEntry GROUP BY Source ORDER BY COUNT(*) DESC;
```

## 7 — GL'i NULL kalmış StateId=18 işlemlerin AccEntry Source'ları
Amaç: Hipotezi doğrulamak — NULL GL'li işlemlerde payment bacağının Source'u
"IncomingAgentPaymentAmount" gibi Contains("IncomingPayment") ile eşleşmeyen bir değer mi?
```sql
SET NOCOUNT ON;
SELECT TOP (20) t.LogicalReference, t.TxnMmProductTypeId, t.SettlementTypeId,
       t.IncomingPaymentAccountingGL, t.OutgoingPaymentAccountingGL,
       e.Source, e.GLCode, e.DebitCredit, e.Amount
FROM dbo.TxnMM t
JOIN dbo.AccEntryMain m ON m.TxnId = t.Id
JOIN dbo.AccEntry e ON e.AccEntryMainId = m.Id
WHERE t.StateId = 18 AND t.IncomingPaymentAccountingGL IS NULL
ORDER BY t.Id DESC;
```

## 8 — IssueBond (PT=3) hariç, NULL GL'li işlemlerin payment bacağı Source'ları
Amaç: 7 numaralı sorgu sadece IssueBond döndü (Source hep NULL, ayrı akış).
MM ürünlerinde (PT 1,2,4,5) NULL GL'li işlemlerde Source LIKE '%Payment%' satırlarına bakmak.
```sql
SET NOCOUNT ON;
SELECT TOP (20) t.LogicalReference, t.TxnMmProductTypeId, t.SettlementTypeId,
       t.IncomingPaymentAccountingGL, t.OutgoingPaymentAccountingGL, e.Source, e.GLCode, e.DebitCredit
FROM dbo.TxnMM t
JOIN dbo.AccEntryMain m ON m.TxnId = t.Id
JOIN dbo.AccEntry e ON e.AccEntryMainId = m.Id
WHERE t.StateId = 18 AND t.TxnMmProductTypeId <> 3
  AND (t.IncomingPaymentAccountingGL IS NULL OR t.OutgoingPaymentAccountingGL IS NULL)
  AND e.Source LIKE '%Payment%'
ORDER BY t.Id DESC;
```

## 9 — TxnSync (Fimple'a giden kayıt) vs TxnMM (DB) GL karşılaştırması
Amaç: Hipotez — MmOpeningAccountingPersister TxnMM'e mirror'lanmış (In ?? Out) değer yazıyor,
ama TxnSync + Fimple payload'a ham PaymentClearingGL gidiyor → bir taraf NULL.
İki tabloyu yan yana koyup doğrula.
```sql
SET NOCOUNT ON;
SELECT TOP (20) s.LogicalReference, s.IncomingPaymentAccountingGL AS SyncInGL,
       s.OutgoingPaymentAccountingGL AS SyncOutGL,
       t.IncomingPaymentAccountingGL AS TxnInGL, t.OutgoingPaymentAccountingGL AS TxnOutGL,
       s.IncomingPaymentAccountingType, s.OutgoingPaymentAccountingType
FROM dbo.TxnSync s JOIN dbo.TxnMM t ON t.LogicalReference = s.LogicalReference
ORDER BY s.Id DESC;
```

## 10 — TxnSync vs TxnMM (9 no'lu sorgu, çalıştırıldı — hipotez DOĞRULANDI)
TxnMM'de her iki kolon dolu (mirror), TxnSync'te bir tanesi NULL.

## 11 — CashFlow tablosunda tek taraflı NULL var mı (term payment sync'i besliyor)
Amaç: FimpleTermPaymentTransactionModelMapper ham PaymentClearingGL gönderiyor;
cashflow tarafında da aynı tek-taraflı NULL deseni var mı?
```sql
SET NOCOUNT ON;
SELECT TOP (20) COUNT(*) AS Adet,
  SUM(CASE WHEN IncomingPaymentAccountingGL IS NULL AND OutgoingPaymentAccountingGL IS NOT NULL THEN 1 ELSE 0 END) AS SadeceInNull,
  SUM(CASE WHEN OutgoingPaymentAccountingGL IS NULL AND IncomingPaymentAccountingGL IS NOT NULL THEN 1 ELSE 0 END) AS SadeceOutNull,
  SUM(CASE WHEN IncomingPaymentAccountingGL IS NOT NULL AND OutgoingPaymentAccountingGL IS NOT NULL THEN 1 ELSE 0 END) AS IkisiDolu
FROM dbo.TxnCashFlow;
```

## 12 — IncomingAgentPaymentAmount / OutgoingAgentPaymentAmount Source'lu fişlerin işlemleri
Amaç: Contains("IncomingPayment") bu Source'ları yakalamıyor. Bu fişlerin bulunduğu
işlemlerde ayrıca IncomingPaymentLCY/FCY bacağı da var mı? Yoksa GL gerçekten NULL kalıyor mu?
predicate'i genişletmek gerekip gerekmediğine karar vermek için.
```sql
SET NOCOUNT ON;
SELECT TOP (20) t.LogicalReference, t.TxnMmProductTypeId, m.Type AS MainType,
       t.IncomingPaymentAccountingGL, t.OutgoingPaymentAccountingGL,
       STRING_AGG(e.Source, ' , ') AS Sources
FROM dbo.AccEntry e
JOIN dbo.AccEntryMain m ON m.Id = e.AccEntryMainId
JOIN dbo.TxnMM t ON t.Id = m.TxnId
WHERE m.Id IN (SELECT AccEntryMainId FROM dbo.AccEntry WHERE Source LIKE '%AgentPaymentAmount')
GROUP BY t.LogicalReference, t.TxnMmProductTypeId, m.Type,
         t.IncomingPaymentAccountingGL, t.OutgoingPaymentAccountingGL
ORDER BY t.LogicalReference DESC;
```

## 13 — 12 boş döndü: AgentPaymentAmount fişleri hangi ürün/ProductCode'a ait?
Amaç: TxnMM ile join tutmadı → bu fişler TxnLoan (interbank loan) tarafında olabilir.
```sql
SET NOCOUNT ON;
SELECT TOP (20) m.ProductCode, m.Type, COUNT(*) AS Adet
FROM dbo.AccEntry e JOIN dbo.AccEntryMain m ON m.Id = e.AccEntryMainId
WHERE e.Source LIKE '%AgentPaymentAmount'
GROUP BY m.ProductCode, m.Type ORDER BY COUNT(*) DESC;
```

## 14 — Tawarruq (TWR) hangi tabloda + GL alanları
Amaç: AgentPaymentAmount Source'lu 108 fiş TWR ürününe ait (MType=1 açılış).
Osman'ın ekranındaki NULL satır TWABRW2609110002 → Tawarruq. Tablo ve GL durumunu gör.
```sql
SET NOCOUNT ON;
SELECT TOP (20) name FROM sys.tables WHERE name LIKE '%Tawarruq%' OR name LIKE 'TxnLoan%' ORDER BY name;
```

## 15 — TWA* (Tawarruq) işlemlerinde GL durumu ve TxnSync karşılığı
Amaç: Tawarruq açılışında Source = IncomingAgentPaymentAmount olduğu için
FindPaymentClearingGLCodes hiç eşleşme bulamıyor → her iki GL de NULL kalıyor mu?
```sql
SET NOCOUNT ON;
SELECT TOP (20) t.Id, t.LogicalReference, t.TxnMmProductTypeId, t.StateId,
       t.IncomingPaymentAccountingGL, t.OutgoingPaymentAccountingGL,
       t.IncomingPaymentAccountingType, t.OutgoingPaymentAccountingType
FROM dbo.TxnMM t WHERE t.LogicalReference LIKE 'TWA%' AND t.StateId = 18
ORDER BY t.Id DESC;
```

## 16 — Tawarruq açılış fişinin (ProductCode=TWR, Type=1) tüm Source + GLCode satırları
Amaç: Tawarruq açılışında hem IncomingPaymentLCY hem IncomingAgentPaymentAmount var mı,
yoksa sadece AgentPaymentAmount mı? predicate genişletme kararı için son kontrol.
```sql
SET NOCOUNT ON;
SELECT TOP (20) m.Id AS MainId, m.TxnId, ISNULL(e.Source,'<NULL>') AS Src, e.GLCode, e.DebitCredit
FROM dbo.AccEntryMain m JOIN dbo.AccEntry e ON e.AccEntryMainId = m.Id
WHERE m.ProductCode = 'TWR' AND m.Type = 1
  AND m.Id = (SELECT MAX(Id) FROM dbo.AccEntryMain WHERE ProductCode='TWR' AND Type=1)
ORDER BY e.Id;
```

## 17 — Sync+Txn tarafı NULL/NULL kalan işlemlerde hiç ödeme bacağı var mı?
Amaç: Kullanıcının fix sonrası test çıktısında 4 satır NULL/NULL (TMMPLC2609170001,
TMMPLC2609120001, TMRBRW2608200004, TMMPLC2608100004). Bunlarda AccEntry'de gerçekten
ödeme bacağı (Incoming*/Outgoing*Payment*) yok mu, yoksa ayrı bir eksiklik mi var?
```sql
SET NOCOUNT ON;
SELECT TOP (20) t.LogicalReference, m.Id AS MainId, m.Type AS MType,
       ISNULL(e.Source,'<NULL>') AS Src, e.GLCode, e.DebitCredit
FROM dbo.TxnMM t
LEFT JOIN dbo.AccEntryMain m ON m.TxnId = t.Id
LEFT JOIN dbo.AccEntry e ON e.AccEntryMainId = m.Id
WHERE t.LogicalReference IN ('TMMPLC2609170001','TMMPLC2609120001','TMRBRW2608200004','TMMPLC2608100004')
ORDER BY t.LogicalReference DESC, m.Id, e.Id;
```

## 18 — Aynı fişte hem doğrudan hem agent ödeme bacağı bulunuyor mu?
Amaç: Fix'teki OrderBy(AgentPayment ? 1 : 0) gerçekten gerekli mi? Yalnızca bir fişte
hem "IncomingPaymentLCY/FCY" hem "IncomingAgentPaymentAmount" varsa anlamlı olur.
```sql
SET NOCOUNT ON;
SELECT TOP (20) m.Id AS MainId, m.ProductCode, m.Type,
       SUM(CASE WHEN e.Source LIKE 'Incoming%Payment%' AND e.Source NOT LIKE '%AgentPayment%' THEN 1 ELSE 0 END) AS InDirect,
       SUM(CASE WHEN e.Source LIKE 'Incoming%AgentPayment%' THEN 1 ELSE 0 END) AS InAgent,
       SUM(CASE WHEN e.Source LIKE 'Outgoing%Payment%' AND e.Source NOT LIKE '%AgentPayment%' THEN 1 ELSE 0 END) AS OutDirect,
       SUM(CASE WHEN e.Source LIKE 'Outgoing%AgentPayment%' THEN 1 ELSE 0 END) AS OutAgent
FROM dbo.AccEntryMain m JOIN dbo.AccEntry e ON e.AccEntryMainId = m.Id
GROUP BY m.Id, m.ProductCode, m.Type
HAVING (SUM(CASE WHEN e.Source LIKE 'Incoming%Payment%' AND e.Source NOT LIKE '%AgentPayment%' THEN 1 ELSE 0 END) > 0
        AND SUM(CASE WHEN e.Source LIKE 'Incoming%AgentPayment%' THEN 1 ELSE 0 END) > 0)
    OR (SUM(CASE WHEN e.Source LIKE 'Outgoing%Payment%' AND e.Source NOT LIKE '%AgentPayment%' THEN 1 ELSE 0 END) > 0
        AND SUM(CASE WHEN e.Source LIKE 'Outgoing%AgentPayment%' THEN 1 ELSE 0 END) > 0)
ORDER BY m.Id DESC;
```
