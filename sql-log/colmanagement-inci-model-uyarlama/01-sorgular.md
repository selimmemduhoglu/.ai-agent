# 01 — Sorgular (colmanagement-inci-model-uyarlama)

> Sohbet: INCI veri modelinden faiz parametre tablolari + model iyilestirmeleri (2026-10-21).
> Yalniz SELECT. Parola maskeli.

## #1 — NetTrexMM
**Amac:** MM'deki faiz parametre tablolarinin adlari (RateType/InterestMethod/Frequency/FloatingRateType)
```bash
sqlcmd -S "tcp:192.168.10.211,1433" -d NetTrexMM -U trusr -P '***' -C -l 20 -W -s "|" -Q "SET NOCOUNT ON; SELECT TOP (20) name, create_date FROM sys.tables WHERE name LIKE '%RateType%' OR name LIKE '%InterestMethod%' OR name LIKE '%DateBasis%' ORDER BY name;"
```

## #2 — NetTrexMM
**Amac:** 4 faiz parametre tablosunun kolon semasi (tip, uzunluk, null, identity, default)
```bash
sqlcmd -S "tcp:192.168.10.211,1433" -d NetTrexMM -U trusr -P '***' -C -l 20 -W -s "|" -Q "SET NOCOUNT ON; SELECT OBJECT_NAME(c.object_id) AS Tbl, c.column_id, c.name, t.name AS type, c.max_length, c.precision, c.scale, c.is_nullable, c.is_identity, OBJECT_DEFINITION(c.default_object_id) AS Def, OBJECT_NAME(c.default_object_id) AS DfName FROM sys.columns c JOIN sys.types t ON t.user_type_id=c.user_type_id WHERE c.object_id IN (OBJECT_ID('dbo.RateType'),OBJECT_ID('dbo.InterestMethod'),OBJECT_ID('dbo.InterestMethodFrequency'),OBJECT_ID('dbo.FloatingRateType')) ORDER BY Tbl, c.column_id;"
```

## #3 — NetTrexMM
**Amac:** RateType, InterestMethod, InterestMethodFrequency seed verisi (script'e birebir tasimak icin)
```bash
sqlcmd -S "tcp:192.168.10.211,1433" -d NetTrexMM -U trusr -P '***' -C -l 20 -W -s "|" -Q "SET NOCOUNT ON; SELECT TOP (20) 'RateType' T, Id, Code, Name, Description, IsEnabled FROM dbo.RateType UNION ALL SELECT TOP (20) 'InterestMethod', Id, Code, Name, Description, IsEnabled FROM dbo.InterestMethod UNION ALL SELECT TOP (20) 'InterestMethodFrequency', Id, Code, Name, Description, IsEnabled FROM dbo.InterestMethodFrequency ORDER BY 1, 2 DESC;"
```

## #4 — NetTrexMM
**Amac:** FloatingRateType seed verisi
```bash
sqlcmd -S "tcp:192.168.10.211,1433" -d NetTrexMM -U trusr -P '***' -C -l 20 -W -s "|" -Q "SET NOCOUNT ON; SELECT TOP (20) Id, Code, Name, Description, IsEnabled, Currency, PointId, ChartId FROM dbo.FloatingRateType ORDER BY Id DESC;"
```

## #5 — NetTrexColManagement
**Amac:** Degisecek tablolarda kac satir var (migration veri tasimali mi)
```bash
sqlcmd -S "tcp:192.168.10.211,1433" -d NetTrexColManagement -U trusr -P '***' -C -l 20 -W -s "|" -Q "SET NOCOUNT ON; SELECT 'Annex' T, COUNT(*) N FROM dbo.Annex UNION ALL SELECT 'AnnexProductScope', COUNT(*) FROM dbo.AnnexProductScope UNION ALL SELECT 'AnnexMarginRule', COUNT(*) FROM dbo.AnnexMarginRule UNION ALL SELECT 'CollateralDefinition', COUNT(*) FROM dbo.CollateralDefinition UNION ALL SELECT 'CollateralCashTerms', COUNT(*) FROM dbo.CollateralCashTerms UNION ALL SELECT 'TxnTransaction', COUNT(*) FROM dbo.TxnTransaction UNION ALL SELECT 'TxnTransactionCash', COUNT(*) FROM dbo.TxnTransactionCash UNION ALL SELECT 'TxnTransactionDetail', COUNT(*) FROM dbo.TxnTransactionDetail UNION ALL SELECT 'CollateralPosition', COUNT(*) FROM dbo.CollateralPosition UNION ALL SELECT 'FloatingRateType', COUNT(*) FROM dbo.FloatingRateType UNION ALL SELECT 'DateBasis', COUNT(*) FROM dbo.DateBasis UNION ALL SELECT 'AccEntryMain', COUNT(*) FROM dbo.AccEntryMain;"
```

## #6 — NetTrexMM
**Amac:** DateBasis kodlari (CashTerms.DayCount enum'unun Act360/Act365/30-360 karsiligi hangi BasisCode)
```bash
sqlcmd -S "tcp:192.168.10.211,1433" -d NetTrexMM -U trusr -P '***' -C -l 20 -W -s "|" -Q "SET NOCOUNT ON; SELECT TOP (20) BasisCode, BasisName, NumberOfDays, Denominator, StateId FROM dbo.DefDateBasis ORDER BY BasisCode;"
```

## #7 — NetTrexColManagement
**Amac:** Bizdeki DateBasis tablosunun kolonlari (CoreData kopyasi) - FK hedefi dogrulama
```bash
sqlcmd -S "tcp:192.168.10.211,1433" -d NetTrexColManagement -U trusr -P '***' -C -l 20 -W -s "|" -Q "SET NOCOUNT ON; SELECT c.name, t.name AS type, c.max_length, c.is_nullable FROM sys.columns c JOIN sys.types t ON t.user_type_id=c.user_type_id WHERE c.object_id = OBJECT_ID('dbo.DateBasis') ORDER BY c.column_id;"
```

## #8 — NetTrexMM
**Amac:** TxnLoan odeme/muhabir/mesaj durumu kolonlarinin fiziksel tip ve uzunluklari (ColManagement'a birebir tasimak icin)
```bash
sqlcmd -S "tcp:192.168.10.211,1433" -d NetTrexMM -U trusr -P '***' -C -l 20 -W -s "|" -Q "SET NOCOUNT ON; SELECT c.column_id, c.name, t.name AS type, c.max_length, c.is_nullable FROM sys.columns c JOIN sys.types t ON t.user_type_id=c.user_type_id WHERE c.object_id = OBJECT_ID('dbo.TxnLoan') AND (c.name LIKE '%Correspondent%' OR c.name LIKE '%PaymentAccounting%' OR c.name LIKE '%MessageStatus%' OR c.name IN ('SendConfirmation','SendPayment','SendNoticeToReceive','Instructions','SettlementTypeId','PaymentInstructionTypeId')) ORDER BY c.column_id;"
```

## #9 — NetTrexMM
**Amac:** MessageStatus kolonlari hangi tablolarda ve tip/uzunlugu ne
```bash
sqlcmd -S "tcp:192.168.10.211,1433" -d NetTrexMM -U trusr -P '***' -C -l 20 -W -s "|" -Q "SET NOCOUNT ON; SELECT TOP (20) OBJECT_NAME(c.object_id) AS Tbl, c.name, t.name AS type, c.max_length, c.is_nullable FROM sys.columns c JOIN sys.types t ON t.user_type_id=c.user_type_id WHERE c.name LIKE '%MessageStatus%' AND OBJECT_NAME(c.object_id) NOT LIKE '%History' ORDER BY Tbl, c.name;"
```

## #10 — NetTrexColManagement
**Amac:** Dropdown uclari bos donuyor: Customer/Portfolio/Currency nesneleri var mi, tablo mu synonym mu
```bash
sqlcmd -S "tcp:192.168.10.211,1433" -d NetTrexColManagement -U trusr -P '***' -C -l 20 -W -s "|" -Q "SELECT TOP (20) o.name, o.type_desc, s.base_object_name FROM sys.objects o LEFT JOIN sys.synonyms s ON s.object_id = o.object_id WHERE o.name LIKE '%Currency%' OR o.name LIKE '%Customer%' OR o.name LIKE '%Portfolio%' ORDER BY o.name DESC"
```

## #11 — NetTrexColManagement
**Amac:** Customer/Portfolio/Currency satir sayilari ve StateId dagilimi (bos donmenin sebebi)
```bash
sqlcmd -S "tcp:192.168.10.211,1433" -d NetTrexColManagement -U trusr -P '***' -C -l 20 -W -s "|" -Q "SELECT TOP (20) 'Currency' AS T, StateId, COUNT(*) AS Cnt FROM Currency GROUP BY StateId UNION ALL SELECT 'Customer', StateId, COUNT(*) FROM Customer GROUP BY StateId UNION ALL SELECT 'Portfolio', StateId, COUNT(*) FROM Portfolio GROUP BY StateId ORDER BY 1 DESC"
```

## #12 — NetTrexMM
**Amac:** Karsilastirma: MM'de ayni tablolarin satir sayisi (veri MM'de var mi)
```bash
sqlcmd -S "tcp:192.168.10.211,1433" -d NetTrexMM -U trusr -P '***' -C -l 20 -W -s "|" -Q "SELECT TOP (20) 'Currency' AS T, COUNT(*) AS Cnt FROM Currency UNION ALL SELECT 'Customer', COUNT(*) FROM Customer UNION ALL SELECT 'Portfolio', COUNT(*) FROM Portfolio ORDER BY 1 DESC"
```

## #13 — NetTrexMM
**Amac:** MM referans verisini (currency/customer/portfolio) nereden okuyor: tablo mu view/synonym mu
```bash
sqlcmd -S "tcp:192.168.10.211,1433" -d NetTrexMM -U trusr -P '***' -C -l 20 -W -s "|" -Q "SELECT TOP (20) o.name, o.type_desc, s.base_object_name FROM sys.objects o LEFT JOIN sys.synonyms s ON s.object_id = o.object_id WHERE o.type IN ('U','V','SN') AND (o.name LIKE '%Currency' OR o.name LIKE '%Customer' OR o.name LIKE '%Portfolio') ORDER BY o.name DESC"
```

## #14 — NetTrexMM
**Amac:** MM'de referans tablolarin dolulugu (ColManagement ile karsilastirma)
```bash
sqlcmd -S "tcp:192.168.10.211,1433" -d NetTrexMM -U trusr -P '***' -C -l 20 -W -s "|" -Q "SELECT TOP (20) 'Currency' AS T, COUNT(*) AS Cnt FROM Currency UNION ALL SELECT 'CusCustomer', COUNT(*) FROM CusCustomer UNION ALL SELECT 'PrfPortfolio', COUNT(*) FROM PrfPortfolio ORDER BY 1 DESC"
```

## #15 — NetTrexColManagement
**Amac:** Currency/Customer/Portfolio kolon listesi (kopyalama script'i icin)
```bash
sqlcmd -S "tcp:192.168.10.211,1433" -d NetTrexColManagement -U trusr -P '***' -C -l 20 -W -s "|" -Q "SELECT TOP (20) TABLE_NAME, STRING_AGG(CAST(COLUMN_NAME + ':' + DATA_TYPE + ':' + IS_NULLABLE AS nvarchar(max)), ', ') WITHIN GROUP (ORDER BY ORDINAL_POSITION) AS Cols FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME IN ('Currency','Customer','Portfolio') GROUP BY TABLE_NAME ORDER BY TABLE_NAME DESC"
```

## #16 — NetTrexMM
**Amac:** MM Currency/CusCustomer/PrfPortfolio kolon listesi (kaynak eslemesi)
```bash
sqlcmd -S "tcp:192.168.10.211,1433" -d NetTrexMM -U trusr -P '***' -C -l 20 -W -s "|" -Q "SELECT TOP (20) TABLE_NAME, STRING_AGG(CAST(COLUMN_NAME + ':' + DATA_TYPE AS nvarchar(max)), ', ') WITHIN GROUP (ORDER BY ORDINAL_POSITION) AS Cols FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME IN ('Currency','CusCustomer','PrfPortfolio') GROUP BY TABLE_NAME ORDER BY TABLE_NAME DESC"
```

## #17 — NetTrexColManagement
**Amac:** Kopya script'i oncesi: hedefte olup MM kaynaginda olmayan kolonlar (NOT NULL olan script'i durdurur)
```bash
sqlcmd -S "tcp:192.168.10.211,1433" -d NetTrexColManagement -U trusr -P '***' -C -l 20 -W -s "|" -Q "SELECT TOP (20) t.TABLE_NAME, t.COLUMN_NAME, t.IS_NULLABLE, t.COLUMN_DEFAULT FROM NetTrexColManagement.INFORMATION_SCHEMA.COLUMNS t WHERE t.TABLE_NAME IN ('Currency','Customer','Portfolio') AND NOT EXISTS (SELECT 1 FROM NetTrexMM.INFORMATION_SCHEMA.COLUMNS s WHERE s.TABLE_NAME = CASE t.TABLE_NAME WHEN 'Customer' THEN 'CusCustomer' WHEN 'Portfolio' THEN 'PrfPortfolio' ELSE 'Currency' END AND s.COLUMN_NAME = t.COLUMN_NAME) ORDER BY t.TABLE_NAME DESC, t.COLUMN_NAME"
```

## #18 — NetTrexColManagement
**Amac:** #17 tekrar (COLLATE DATABASE_DEFAULT ile): hedefte olup kaynakta olmayan kolonlar
```bash
sqlcmd -S "tcp:192.168.10.211,1433" -d NetTrexColManagement -U trusr -P '***' -C -l 20 -W -s "|" -Q "SELECT TOP (20) t.TABLE_NAME, t.COLUMN_NAME, t.IS_NULLABLE, t.COLUMN_DEFAULT FROM NetTrexColManagement.INFORMATION_SCHEMA.COLUMNS t WHERE t.TABLE_NAME IN ('Currency','Customer','Portfolio') AND NOT EXISTS (SELECT 1 FROM NetTrexMM.INFORMATION_SCHEMA.COLUMNS s WHERE s.TABLE_NAME COLLATE DATABASE_DEFAULT = CASE t.TABLE_NAME WHEN 'Customer' THEN 'CusCustomer' WHEN 'Portfolio' THEN 'PrfPortfolio' ELSE 'Currency' END AND s.COLUMN_NAME COLLATE DATABASE_DEFAULT = t.COLUMN_NAME COLLATE DATABASE_DEFAULT) ORDER BY t.TABLE_NAME DESC, t.COLUMN_NAME"
```

## #19 — NetTrexColManagement
**Amac:** Kopya script'i: kesisen kolonlarda tip/uzunluk/nullable uyusmazligi (truncation/NULL riski)
```bash
sqlcmd -S "tcp:192.168.10.211,1433" -d NetTrexColManagement -U trusr -P '***' -C -l 20 -W -s "|" -Q "SELECT TOP (20) OBJECT_NAME(t.object_id) AS Tbl, t.name, TYPE_NAME(t.user_type_id) AS DstType, t.max_length AS DstLen, t.is_nullable AS DstNull, TYPE_NAME(s.user_type_id) AS SrcType, s.max_length AS SrcLen, s.is_nullable AS SrcNull FROM sys.columns t JOIN NetTrexMM.sys.columns s ON s.object_id = CASE OBJECT_NAME(t.object_id) WHEN 'Customer' THEN OBJECT_ID('NetTrexMM.dbo.CusCustomer') WHEN 'Portfolio' THEN OBJECT_ID('NetTrexMM.dbo.PrfPortfolio') ELSE OBJECT_ID('NetTrexMM.dbo.Currency') END AND s.name COLLATE DATABASE_DEFAULT = t.name COLLATE DATABASE_DEFAULT WHERE t.object_id IN (OBJECT_ID('dbo.Currency'), OBJECT_ID('dbo.Customer'), OBJECT_ID('dbo.Portfolio')) AND (t.user_type_id <> s.user_type_id OR t.max_length < s.max_length OR (t.is_nullable = 0 AND s.is_nullable = 1)) ORDER BY 1 DESC"
```

## #20 — NetTrexColManagement
**Amac:** Customer/Portfolio/Currency uzerindeki FK'lar (kopya sirasinda ihlal riski)
```bash
sqlcmd -S "tcp:192.168.10.211,1433" -d NetTrexColManagement -U trusr -P '***' -C -l 20 -W -s "|" -Q "SELECT TOP (20) fk.name, OBJECT_NAME(fk.parent_object_id) AS Child, OBJECT_NAME(fk.referenced_object_id) AS Parent FROM sys.foreign_keys fk WHERE fk.parent_object_id IN (OBJECT_ID('dbo.Currency'), OBJECT_ID('dbo.Customer'), OBJECT_ID('dbo.Portfolio')) ORDER BY 1 DESC"
```

## #21 — NetTrexMM
**Amac:** Kaynakta NULL StateMaker/StateId/StateDate var mi (hedef NOT NULL)
```bash
sqlcmd -S "tcp:192.168.10.211,1433" -d NetTrexMM -U trusr -P '***' -C -l 20 -W -s "|" -Q "SELECT TOP (20) 'CusCustomer' AS T, SUM(CASE WHEN StateMaker IS NULL THEN 1 ELSE 0 END) AS NullMaker, 0 AS NullState, 0 AS NullDate FROM CusCustomer UNION ALL SELECT 'PrfPortfolio', SUM(CASE WHEN StateMaker IS NULL THEN 1 ELSE 0 END), 0, 0 FROM PrfPortfolio UNION ALL SELECT 'Currency', SUM(CASE WHEN StateMaker IS NULL THEN 1 ELSE 0 END), SUM(CASE WHEN StateId IS NULL THEN 1 ELSE 0 END), SUM(CASE WHEN StateDate IS NULL THEN 1 ELSE 0 END) FROM Currency ORDER BY 1 DESC"
```

## #22 — NetTrexMM
**Amac:** Maker-checker karsilastirmasi: TxnMM / TxnLoan / PrdProductDefinition flow+audit kolonlari
```bash
sqlcmd -S "tcp:192.168.10.211,1433" -d NetTrexMM -U trusr -P '***' -C -l 20 -W -s "|" -Q "SELECT TOP (20) TABLE_NAME, COLUMN_NAME, DATA_TYPE, IS_NULLABLE FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME IN ('TxnMM','TxnLoan','PrdProductDefinition') AND (COLUMN_NAME LIKE 'State%' OR COLUMN_NAME LIKE 'Previous%' OR COLUMN_NAME LIKE 'Created%' OR COLUMN_NAME LIKE '%Action%' OR COLUMN_NAME IN ('FlowId','Trader','ConcurrencyDate','UpdateDate','UpdatedBy','InputDate')) ORDER BY TABLE_NAME DESC, COLUMN_NAME"
```

## #23 — NetTrexMM
**Amac:** Maker-checker: PrdProductDefinition (MM'in maker-checker TANIM tablosu) flow/audit kolonlari
```bash
sqlcmd -S "tcp:192.168.10.211,1433" -d NetTrexMM -U trusr -P '***' -C -l 20 -W -s "|" -Q "SELECT TOP (20) TABLE_NAME, COLUMN_NAME, DATA_TYPE, IS_NULLABLE FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME IN ('PrdProductDefinition') AND (COLUMN_NAME LIKE 'State%' OR COLUMN_NAME LIKE 'Previous%' OR COLUMN_NAME LIKE 'Created%' OR COLUMN_NAME LIKE '%Action%' OR COLUMN_NAME IN ('FlowId','Trader','ConcurrencyDate')) ORDER BY COLUMN_NAME"
```

## #24 — NetTrexColManagement
**Amac:** Maker-checker: Annex / CollateralDefinition / TxnTransaction flow+audit kolonlari
```bash
sqlcmd -S "tcp:192.168.10.211,1433" -d NetTrexColManagement -U trusr -P '***' -C -l 20 -W -s "|" -Q "SELECT TOP (40) TABLE_NAME, COLUMN_NAME, DATA_TYPE, IS_NULLABLE FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME IN ('Annex','CollateralDefinition','TxnTransaction') AND (COLUMN_NAME LIKE 'State%' OR COLUMN_NAME LIKE 'Previous%' OR COLUMN_NAME LIKE 'Created%' OR COLUMN_NAME LIKE '%Action%' OR COLUMN_NAME IN ('FlowId','Trader','ConcurrencyDate','InputDate','TransactionOriginType')) ORDER BY TABLE_NAME DESC, COLUMN_NAME"
```

## #25 — NetTrexColManagement
**Amac:** Today/Yesterday filtresi asili kaliyor: Calendar tablosunda yil/para birimi satiri var mi
```bash
sqlcmd -S "tcp:192.168.10.211,1433" -d NetTrexColManagement -U trusr -P '***' -C -l 20 -W -s "|" -Q "SELECT TOP (20) CurrencyCode, [Year], COUNT(*) AS Gun FROM Calendar GROUP BY CurrencyCode, [Year] ORDER BY [Year] DESC"
```

## #26 — NetTrexMM
**Amac:** Karsilastirma: MM Calendar dolulugu
```bash
sqlcmd -S "tcp:192.168.10.211,1433" -d NetTrexMM -U trusr -P '***' -C -l 20 -W -s "|" -Q "SELECT TOP (20) CurrencyCode, [Year], COUNT(*) AS Gun FROM Calendar GROUP BY CurrencyCode, [Year] ORDER BY [Year] DESC"
```

## #27 — NetTrexColManagement
**Amac:** Bos referans tablolari: ColManagement'ta 0 satirli, MM'de ayni adla dolu tablolar
```bash
sqlcmd -S "tcp:192.168.10.211,1433" -d NetTrexColManagement -U trusr -P '***' -C -l 20 -W -s "|" -Q "SELECT TOP (40) t.name AS Tablo, mm.Cnt AS MmSatir FROM sys.tables t JOIN sys.partitions p ON p.object_id = t.object_id AND p.index_id IN (0,1) JOIN (SELECT mt.name COLLATE DATABASE_DEFAULT AS name, SUM(mp.rows) AS Cnt FROM NetTrexMM.sys.tables mt JOIN NetTrexMM.sys.partitions mp ON mp.object_id = mt.object_id AND mp.index_id IN (0,1) GROUP BY mt.name) mm ON mm.name = t.name COLLATE DATABASE_DEFAULT GROUP BY t.name, mm.Cnt HAVING SUM(p.rows) = 0 AND mm.Cnt > 0 ORDER BY t.name DESC"
```

## #28 — NetTrexColManagement
**Amac:** DateBasis nerede: ColManagement ve MM'de DateBasis adli tablo/satir
```bash
sqlcmd -S "tcp:192.168.10.211,1433" -d NetTrexColManagement -U trusr -P '***' -C -l 20 -W -s "|" -Q "SELECT TOP (20) 'CM' AS Db, name FROM sys.tables WHERE name LIKE '%DateBasis%' UNION ALL SELECT 'MM', name COLLATE DATABASE_DEFAULT FROM NetTrexMM.sys.tables WHERE name LIKE '%DateBasis%' ORDER BY 1 DESC"
```

## #29 — NetTrexColManagement
**Amac:** Genis kopya on kontrol: hedefte kaynaksiz NOT NULL kolon, tip/uzunluk farki, PK yok
```bash
sqlcmd -S "tcp:192.168.10.211,1433" -d NetTrexColManagement -U trusr -P '***' -C -l 20 -W -s "|" -Q "SELECT TOP (40) m.Dst, t.name AS Kolon, CASE WHEN s.name IS NULL THEN 'KAYNAKTA YOK (NOT NULL)' WHEN t.user_type_id <> s.user_type_id THEN 'TIP FARKLI' WHEN t.max_length < s.max_length AND t.max_length <> -1 THEN 'HEDEF KISA' ELSE 'NULL->NOT NULL' END AS Sorun FROM (VALUES ('Currency','Currency'),('CusCustomer','Customer'),('PrfPortfolio','Portfolio'),('DefDateBasis','DateBasis'),('Calendar','Calendar'),('Holiday','Holiday'),('HalfWorkingDay','HalfWorkingDay'),('CurrencyPair','CurrencyPair'),('Market','Market'),('MarketCustomerMap','MarketCustomerMap'),('SettlementType','SettlementType'),('PaymentInstructionType','PaymentInstructionType'),('Chart','Chart'),('Point','Point')) m(Src,Dst) JOIN sys.columns t ON t.object_id = OBJECT_ID('dbo.' + m.Dst) LEFT JOIN NetTrexMM.sys.columns s ON s.object_id = OBJECT_ID('NetTrexMM.dbo.' + m.Src) AND s.name COLLATE DATABASE_DEFAULT = t.name COLLATE DATABASE_DEFAULT WHERE t.is_computed = 0 AND ((s.name IS NULL AND t.is_nullable = 0 AND t.default_object_id = 0 AND t.is_identity = 0) OR (s.name IS NOT NULL AND (t.user_type_id <> s.user_type_id OR (t.max_length < s.max_length AND t.max_length <> -1) OR (t.is_nullable = 0 AND s.is_nullable = 1)))) UNION ALL SELECT m.Dst, '-', 'PK YOK' FROM (VALUES ('Currency','Currency'),('CusCustomer','Customer'),('PrfPortfolio','Portfolio'),('DefDateBasis','DateBasis'),('Calendar','Calendar'),('Holiday','Holiday'),('HalfWorkingDay','HalfWorkingDay'),('CurrencyPair','CurrencyPair'),('Market','Market'),('MarketCustomerMap','MarketCustomerMap'),('SettlementType','SettlementType'),('PaymentInstructionType','PaymentInstructionType'),('Chart','Chart'),('Point','Point')) m(Src,Dst) WHERE NOT EXISTS (SELECT 1 FROM sys.indexes i WHERE i.object_id = OBJECT_ID('dbo.' + m.Dst) AND i.is_primary_key = 1) ORDER BY 1 DESC"
```

## #30 — NetTrexMM
**Amac:** Kopya on kontrol: NOT NULL hedef kolonlarina gidecek NULL degerler ve uzun Name'ler
```bash
sqlcmd -S "tcp:192.168.10.211,1433" -d NetTrexMM -U trusr -P '***' -C -l 20 -W -s "|" -Q "SELECT TOP (20) 'SettlementType.ExternalCode' AS K, COUNT(*) AS Sorunlu FROM SettlementType WHERE ExternalCode IS NULL UNION ALL SELECT 'Point.State*', COUNT(*) FROM Point WHERE StateId IS NULL OR StateMaker IS NULL OR StateDate IS NULL UNION ALL SELECT 'MarketCustomerMap.StateMaker', COUNT(*) FROM MarketCustomerMap WHERE StateMaker IS NULL UNION ALL SELECT 'Market.Name/StateMaker', COUNT(*) FROM Market WHERE Name IS NULL OR StateMaker IS NULL UNION ALL SELECT 'CurrencyPair.*', COUNT(*) FROM CurrencyPair WHERE IsCalculatedPair IS NULL OR OrderNo IS NULL OR IsPM IS NULL OR StateId IS NULL OR StateMaker IS NULL OR StateDate IS NULL UNION ALL SELECT 'Chart.State*', COUNT(*) FROM Chart WHERE StateId IS NULL OR StateMaker IS NULL OR StateDate IS NULL UNION ALL SELECT 'Calendar.Year/DayOfYear', COUNT(*) FROM Calendar WHERE [Year] IS NULL OR DayOfYear IS NULL UNION ALL SELECT 'SettlementType.Name max', MAX(LEN(Name)) FROM SettlementType UNION ALL SELECT 'PaymentInstructionType.Name max', MAX(LEN(Name)) FROM PaymentInstructionType ORDER BY 1 DESC"
```

## #31 — NetTrexColManagement
**Amac:** Hedef Name kolon uzunluklari (SettlementType, PaymentInstructionType)
```bash
sqlcmd -S "tcp:192.168.10.211,1433" -d NetTrexColManagement -U trusr -P '***' -C -l 20 -W -s "|" -Q "SELECT TOP (20) OBJECT_NAME(object_id) AS T, name, max_length FROM sys.columns WHERE name = 'Name' AND object_id IN (OBJECT_ID('dbo.SettlementType'), OBJECT_ID('dbo.PaymentInstructionType')) ORDER BY 1 DESC"
```

## #32 — NetTrexColManagement
**Amac:** Definition create duplicate teshisi: test tanimlarinin eligible currency ve cash terms satirlari
```bash
sqlcmd -S "tcp:192.168.10.211,1433" -d NetTrexColManagement -U trusr -P '***' -C -l 20 -W -s "|" -Q "SELECT TOP (20) d.Id, d.CollateralCode, (SELECT COUNT(*) FROM CollateralEligibleCurrency e WHERE e.DefinitionId = d.Id) AS Ccy, (SELECT COUNT(*) FROM CollateralCashTerms c WHERE c.DefinitionId = d.Id) AS Cash FROM CollateralDefinition d ORDER BY d.Id DESC"
```

## #33 — NetTrexColManagement
**Amac:** e2e tur 3 dogrulama: tanim basina eligible currency / cash terms, annex basina scope / rule
```bash
sqlcmd -S "tcp:192.168.10.211,1433" -d NetTrexColManagement -U trusr -P '***' -C -l 20 -W -s "|" -Q "SELECT TOP (20) d.CollateralCode, d.StateId, (SELECT COUNT(*) FROM CollateralEligibleCurrency e WHERE e.DefinitionId = d.Id) AS Ccy, (SELECT COUNT(*) FROM CollateralCashTerms c WHERE c.DefinitionId = d.Id) AS Cash, (SELECT TOP 1 c.FixedRate FROM CollateralCashTerms c WHERE c.DefinitionId = d.Id) AS Fixed FROM CollateralDefinition d WHERE d.CollateralCode LIKE 'TST-DEF-3-%' ORDER BY d.Id DESC"
```

## #34 — NetTrexColManagement
**Amac:** Temizlik script'i icin: Annex/Definition ile iliskili tablolar ve DefinitionId/AnnexId kolonlari
```bash
sqlcmd -S "tcp:192.168.10.211,1433" -d NetTrexColManagement -U trusr -P '***' -C -l 20 -W -s "|" -Q "SELECT TOP (30) TABLE_NAME, COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME IN ('AnnexId','DefinitionId') OR (TABLE_NAME IN ('Annex','AnnexHistory','CollateralDefinition','CollateralDefinitionHistory') AND COLUMN_NAME IN ('AnnexCode','CollateralCode')) ORDER BY TABLE_NAME DESC"
```

## #35 — NetTrexColManagement
**Amac:** Test kayitlari sayisi ve TxnTransaction'da kullanim (silme guvenli mi)
```bash
sqlcmd -S "tcp:192.168.10.211,1433" -d NetTrexColManagement -U trusr -P '***' -C -l 20 -W -s "|" -Q "SELECT TOP (20) 'Annex' AS T, COUNT(*) AS C FROM Annex WHERE AnnexCode LIKE 'TST-ANX-%' UNION ALL SELECT 'Definition', COUNT(*) FROM CollateralDefinition WHERE CollateralCode LIKE 'TST-DEF-%' UNION ALL SELECT 'TxnKullanan', COUNT(*) FROM TxnTransaction t JOIN CollateralDefinition d ON d.Id = t.DefinitionId WHERE d.CollateralCode LIKE 'TST-DEF-%' ORDER BY 1 DESC"
```
