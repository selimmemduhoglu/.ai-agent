# SQL Log — manuel-reeskont-commonui-parity — Sorgular

> `<chat-slug>` bu oturum için **türetildi** (kullanıcı ad vermedi) — konu: Manuel Reeskont
> Common.UI/WebUI parity düzeltmeleri + permission script'i.

Özet: **Sorgu: 2 · Yazma: 0**

---

## #1 — Eski Manuel Revaluation ekranının GERÇEK permission satırları (FrameworkPermission)

**Amaç:** Kullanıcı yeni Common.UI Manuel Reeskont controller'ları için ürettiğim permission
script'inin (Index/Load/AccountingDetails/SelectAcc, Displayer+Maker) yeterli olup olmadığını,
daha önce prod'da çalışan eski ekranın (`ManuelRevaluationController`, WebUI, `Trex.WebUI`) canlı
permission kayıtlarıyla karşılaştırarak doğrulamamı istedi — varsayımla değil gerçek veriyle.

```sql
SET NOCOUNT ON;
SELECT TOP (20) PermissionName, ApplicationName, IsEnabled, PermissionDescription
FROM FrameworkPermission
WHERE PermissionName LIKE '%ManuelRevaluation%' OR PermissionName LIKE '%Reescont%'
   OR PermissionName LIKE '%Revaluation%'
ORDER BY PermissionName;
```

DB: `NetTrexCommon` · Server: `tcp:192.168.10.211,1433` · User: `trusr` · Pass: `***`
(kaynak: `NetTrex.Common/Code/docker-compose.override.yml:27`)

---

## #2 — Aynı ekranın FrameworkPermissionAction satırları

**Amaç:** Eski ekranın hangi controller/action çiftlerine gerçekten permission verilmiş olduğunu
görmek — benim ürettiğim script'te action listesi eksik mi fazla mı kontrol etmek için.

```sql
SET NOCOUNT ON;
SELECT TOP (20) ApplicationName, PermissionName, ActionType, ActionValue, IsAllowed, ActionId
FROM FrameworkPermissionAction
WHERE PermissionName LIKE '%ManuelRevaluation%' OR PermissionName LIKE '%Reescont%'
   OR PermissionName LIKE '%Revaluation%'
ORDER BY PermissionName, ActionValue;
```

DB: `NetTrexCommon` · Server: `tcp:192.168.10.211,1433` · User: `trusr` · Pass: `***`
