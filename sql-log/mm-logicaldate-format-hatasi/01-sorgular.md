# Sorgular — mm-logicaldate-format-hatasi

## #1

**Amaç:** UAT'ta `System.FormatException: String '2.11.2026' was not recognized as a valid DateTime`
hatası `Trex:MMLogicalDate` framework parametresinden mi geliyor doğrulamak — dev cluster'daki
referans değerin formatını (sıfır dolgulu mu) görmek için.

```sql
SET NOCOUNT ON;
SELECT TOP (20) Id, OptionPath, OptionName, ApplicationName, EnvironmentName, Value, StateId
FROM FrameworkParameter
WHERE OptionName IN ('MMLogicalDate', 'FxLogicalDate')
ORDER BY Id DESC;
```

DB: `NetTrexCommon` · Server: `tcp:192.168.10.211,1433` · User: `trusr` · Pass: `***`

⚠️ Not: hata UAT ortamından (`samplebankgcc`/GCCRIB) geliyor, bu sorgu **dev cluster**'a gidiyor —
farklı DB/ortam. Amaç yalnız format referansı, UAT'taki gerçek bozuk değeri görmek değil.
