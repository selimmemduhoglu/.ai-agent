# SQL Log — txnMMDetail Int32→Int64 cast hatası

| Özet | Değer |
|---|---|
| Sorgu | 1 |
| Yazma | 0 |

---

## #1 — txnMMDetail kolon tipleri

**Amaç:** `/api/transaction/create` → `InvalidCastException: Int32 → Int64` (EF `PropagateResults`). Entity `TxnMMDetailEntity.Id` `long`; DB kolonu `int` identity mi doğrulamak.

```bash
sqlcmd -S "tcp:192.168.10.211,1433" -d NetTrexMM -U trusr -P '***' -C -l 20 -W -s "|" -Q "SET NOCOUNT ON; SELECT TOP (20) DB_NAME() AS Db, c.name, t.name AS type, c.is_identity FROM sys.columns c JOIN sys.types t ON t.user_type_id = c.user_type_id WHERE c.object_id = OBJECT_ID('dbo.txnMMDetail') ORDER BY c.column_id;"
```
