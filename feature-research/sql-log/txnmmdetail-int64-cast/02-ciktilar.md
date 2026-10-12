# SQL Log — Çıktılar

## #1 — BAŞARISIZ

```text
Sqlcmd: Error: Microsoft ODBC Driver 17 for SQL Server : Login failed for user 'trusr'..
```

Yorum: `docker-compose.override.yml` satır 24'teki credential ile login reddedildi (parola değişmiş/stale olabilir). Tekrar denenmedi.
