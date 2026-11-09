# SQL Log — colmanagement-ui-permission — Çıktılar

## Çıktı #1
```
tablo|kolon|tip
-----|-----|---
FrameworkPermission|PermissionName|nvarchar
FrameworkPermission|ApplicationName|nvarchar
FrameworkPermission|IsEnabled|bit
FrameworkPermission|PermissionDescription|nvarchar
FrameworkPermissionAction|ApplicationName|nvarchar
FrameworkPermissionAction|PermissionName|nvarchar
FrameworkPermissionAction|ActionType|nvarchar
FrameworkPermissionAction|ActionValue|nvarchar
FrameworkPermissionAction|IsAllowed|bit
FrameworkPermissionAction|ActionId|bigint
```

## Çıktı #2
```
Controller|PermissionName|ApplicationName|Adet
----------|--------------|---------------|----
```

## Çıktı #3
```
PermissionName|ApplicationName|ActionType|ActionValue|IsAllowed
--------------|---------------|----------|-----------|---------
ProductDefinition_Maker|Trex.WebUI|ControllerAction|ProductDefinition/Update|1
ProductDefinition_Maker|Trex.WebUI|ControllerAction|ProductDefinition/UndoProductDefinition/DeleteProductDefinition/UpdateProductDefinition/Create|1
ProductDefinition_Maker|Trex.WebUI|ControllerAction|ProductDefinition/Undo|1
ProductDefinition_Maker|Trex.WebUI|ControllerAction|ProductDefinition/Delete|1
ProductDefinition_Maker|Trex.WebUI|ControllerAction|ProductDefinition/Create|1
ProductDefinition_Displayer|Trex.WebUI|ControllerAction|ProductDefinition/Preview|1
ProductDefinition_Displayer|Trex.WebUI|ControllerAction|ProductDefinition/Load|1
ProductDefinition_Displayer|Trex.WebUI|ControllerAction|ProductDefinition/Index|1
ProductDefinition_Displayer|Trex.WebUI|ControllerAction|ProductDefinition/History|1
ProductDefinition_Displayer|Trex.WebUI|ControllerAction|ProductDefinition/GetMarkets|1
ProductDefinition_Displayer|Trex.WebUI|ControllerAction|ProductDefinition/GetLogicalReferenceTypes|1
ProductDefinition_Displayer|Trex.WebUI|ControllerAction|ProductDefinition/GetAccountSelectionTypeSelectFKey|1
ProductDefinition_Displayer|Trex.WebUI|ControllerAction|ProductDefinition/GetAccountingMapCodes|1
ProductDefinition_Displayer|Trex.WebUI|ControllerAction|ProductDefinition/GetAccountingCalculationMethodTypeSelectFKey|1
ProductDefinition_Displayer|Trex.WebUI|ControllerAction|ProductDefinition/Get|1
ProductDefinition_Displayer|Trex.WebUI|ControllerAction|ProductDefinition/Form|1
ProductDefinition_Checker|Trex.WebUI|ControllerAction|ProductDefinition/Verify|1
ProductDefinition_Checker|Trex.WebUI|ControllerAction|ProductDefinition/RejectProductDefinition/Verify|1
ProductDefinition_Checker|Trex.WebUI|ControllerAction|ProductDefinition/Reject|1
```

(Sorgular #1-#3 tamamlandi; tumu salt-okunur SELECT.)
