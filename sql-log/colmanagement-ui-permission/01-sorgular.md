# SQL Log — colmanagement-ui-permission — Sorgular

Bağlantı: `tcp:192.168.10.211,1433` / `NetTrexCommon` / `trusr` (kaynak: `NetTrex.Common/Code/docker-compose.override.yml`). Parola: `***`.
Varsayım: docker'daki ColManagement.UI'nin `CommonApi`'si (cluster 192.168.10.191:30825) bu DB'ye bakıyor — doğrulanmadı.

Soru: ColManagement.UI'de "+" butonu pasif (`hasInsertPermission` = `HasPermissionAsync("Annex","Form")`).
Common DB'de Annex/CollateralDefinition/TxnTransaction için hiç permission action satırı var mı, ve MM micro UI ekranları için (ProductDefinition) nasıl duruyor?

| # | Amaç | Yazma? |
|---|------|--------|
| 1 | `FrameworkPermissionAction` / `FrameworkPermission` kolon adları — sonraki sorguları doğru kurmak için | Hayır |
| 2 | `Annex/`, `CollateralDefinition/`, `TxnTransaction/` ile başlayan action satırı sayısı (grup bazlı) | Hayır |
| 3 | Emsal: `ProductDefinition/` action'ları hangi permission adlarına bağlı, kaç adet | Hayır |

## Sorgu #1
```sql
SET NOCOUNT ON;
SELECT t.name AS tablo, c.name AS kolon, ty.name AS tip
FROM sys.columns c
JOIN sys.tables t ON t.object_id = c.object_id
JOIN sys.types ty ON ty.user_type_id = c.user_type_id
WHERE t.name IN ('FrameworkPermissionAction','FrameworkPermission')
ORDER BY t.name, c.column_id;
```

## Sorgu #2
```sql
SET NOCOUNT ON;
SELECT TOP (20) LEFT(ActionValue, CHARINDEX('/', ActionValue + '/') - 1) AS Controller, PermissionName, ApplicationName, COUNT(*) AS Adet
FROM dbo.FrameworkPermissionAction
WHERE ActionValue LIKE 'Annex/%' OR ActionValue LIKE 'CollateralDefinition/%' OR ActionValue LIKE 'TxnTransaction/%'
GROUP BY LEFT(ActionValue, CHARINDEX('/', ActionValue + '/') - 1), PermissionName, ApplicationName
ORDER BY Controller DESC;
```

## Sorgu #3
```sql
SET NOCOUNT ON;
SELECT TOP (20) PermissionName, ApplicationName, ActionType, ActionValue, IsAllowed
FROM dbo.FrameworkPermissionAction
WHERE ActionValue LIKE 'ProductDefinition/%'
ORDER BY ActionId DESC;
```
