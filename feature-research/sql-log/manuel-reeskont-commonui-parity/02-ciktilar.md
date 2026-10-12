# SQL Log — manuel-reeskont-commonui-parity — Çıktılar

## #1 — FrameworkPermission, `%ManuelRevaluation%` / `%Reescont%` / `%Revaluation%`

TOP (20) sınırına takıldı — muhtemelen daha fazla eşleşen satır var (kırpıldı).

```text
PermissionName|ApplicationName|IsEnabled|PermissionDescription
--------------|---------------|---------|---------------------
DerivSwpRevaluationReport_Displayer|Trex.WebUI|1|
InvFundRevaluationReport_Checker|Trex.WebUI|1|
InvFundRevaluationReport_Displayer|Trex.WebUI|1|
InvFundRevaluationReport_Maker|Trex.WebUI|1|
ManuelReescont_Checker|Trex.WebUI|1|
ManuelReescont_Displayer|Trex.WebUI|1|
ManuelReescont_Maker|Trex.WebUI|1|
ManuelRevaluation_Checker|Trex.WebUI|1|
ManuelRevaluation_Displayer|Trex.WebUI|1|
ManuelRevaluation_Maker|Trex.WebUI|1|
MmRevaluationReport_Checker|Trex.WebUI|1|
MmRevaluationReport_Displayer|Trex.WebUI|1|
MmRevaluationReport_Maker|Trex.WebUI|1|
OptFXRevaluationReport_Displayer|Trex.WebUI|1|
RevaluationReport_Checker|Trex.WebUI|1|
RevaluationReport_Displayer|Trex.WebUI|1|
RevaluationReport_Maker|Trex.WebUI|1|
SecurityManuelReescont_Checker|Trex.WebUI|1|
SecurityManuelReescont_Displayer|Trex.WebUI|1|
SecurityManuelReescont_Maker|Trex.WebUI|1|
```

**Not:** `ManuelReescont_*` ayrı bir permission grubu — kullanıcının işaret ettiği
`ManuelRevaluationController.cs` (namespace `Trex.WebUI.Controllers.FX.Report`,
route `ManuelRevaluation/*`) ile eşleşen grup `ManuelRevaluation_*`. `ManuelReescont_*`
muhtemelen ayrı/eski bir ekran — bu turda araştırılmadı.

## #2 — FrameworkPermissionAction, `ManuelRevaluation%` (daraltıldı)

```text
ApplicationName|PermissionName|ActionType|ActionValue|IsAllowed|ActionId
---------------|--------------|----------|-----------|---------|--------
Trex.WebUI|ManuelRevaluation_Checker|ControllerAction|ManuelRevaluation/Index|1|NULL
Trex.WebUI|ManuelRevaluation_Displayer|ControllerAction|ManuelRevaluation/Index|1|NULL
Trex.WebUI|ManuelRevaluation_Displayer|ControllerAction|ManuelRevaluation/Load|1|NULL
Trex.WebUI|ManuelRevaluation_Maker|ControllerAction|ManuelRevaluation/CreateReescont|1|NULL
Trex.WebUI|ManuelRevaluation_Maker|ControllerAction|ManuelRevaluation/CreateRevaluation|1|NULL
Trex.WebUI|ManuelRevaluation_Maker|ControllerAction|ManuelRevaluation/Index|1|NULL
```

## Yorum

- **Desen doğrulandı:** DB'de sadece controller'ın GERÇEK action'larına karşılık gelen satırlar
  var (`Index`, `Load`, `CreateReescont`) — framework-seviyesi/gizli ekstra bir action YOK.
  Bu, yeni Common.UI script'imin yaklaşımını (RediscountControllerBase'in 5 gerçek action'ı,
  fazlası yok) doğruluyor.
- **`CreateRevaluation`** kod tabanında (`ManuelRevaluationController.cs`) YOK — controller'da
  sadece `CreateReescont` var. DB'de kalan bu satır muhtemelen eski/silinmiş bir action'ın
  artığı (rename sonrası temizlenmemiş) — stale kayıt, örnek alınacak bir şey değil.
- **⚠️ `ManuelRevaluation_Maker`'da `Load` YOK** — sadece `Index` + iki create action'ı. Bu,
  Maker rolündeki kullanıcının grid'i (Load) YÜKLEYEMEDİĞİ, yani muhtemelen kırık bir permission
  seti. Benim script'imdeki "Maker = Displayer'ın tüm action'ları + Execute" deseni
  (WebUI'nin 2026-08-24 script'inde de kullanılmıştı, üretimde çalışıyor) BU eksik örnekten
  daha doğru/güvenli — kopyalanmadı, bilinçli olarak korundu.
