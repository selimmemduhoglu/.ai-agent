# SQL Sorguları — MM Kafka notification fix (ExternalNotification truncate)

| Toplam sorgu | Yazma işlemi |
|---|---|
| 2 | **0** |

Bağlantı: `sqlcmd -S "tcp:192.168.10.211,1433" -d NetTrexCommon -U trusr -P '***' -C -l 20 -W -s "|"`

---

## #1 — ExternalNotification kolon tipleri/uzunlukları

**Amaç:** Müşteride Common `ExternalNotificationHandler` insert'i "String or binary data would be truncated" veriyor. Repoda MSSQL kolon boyutu yok (EF config boş, yalnız Oracle mapping). Hangi kolonun dar olduğunu bulmak.

```sql
SET NOCOUNT ON;
SELECT TOP (20) c.name, t.name AS type, c.max_length, c.is_nullable
FROM sys.columns c
JOIN sys.types t ON t.user_type_id = c.user_type_id
WHERE c.object_id = OBJECT_ID('dbo.ExternalNotification')
ORDER BY c.column_id;
```

## #2 — Son kayıtlarda alan uzunlukları

**Amaç:** Gerçek kayıtlarda ToMail/Subject/MailBody/NotificationResult uzunluklarını görmek; hangi modülün mail'i kolon limitine yakın.

```sql
SET NOCOUNT ON;
SELECT TOP (20) Id, Module, IsSuccess, LEN(ToMail) AS ToMailLen, LEN(ToCc) AS ToCcLen, LEN(Subject) AS SubjectLen,
       LEN(MailBody) AS MailBodyLen, LEN(NotificationResult) AS ResultLen, LEFT(NotificationResult, 120) AS Result
FROM dbo.ExternalNotification
ORDER BY Id DESC;
```
