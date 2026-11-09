# Çıktılar — mm-logicaldate-format-hatasi

## #1

```
Id|OptionPath|OptionName|ApplicationName|EnvironmentName|Value|StateId
--|----------|----------|---------------|---------------|-----|-------
3636|Trex|MMLogicalDate|||26.10.2026|26
3635|Trex|FxLogicalDate|||04.11.2026|26
```

**Sonuç:** Dev cluster'da `MMLogicalDate` = `26.10.2026` — **sıfır dolgulu `dd.MM.yyyy`**, parse
sorunsuz. UAT'taki hatalı değer (`2.11.2026`, gün tek haneli) bu ortamda **yok** — doğrulama yalnız
format referansı için yapıldı, UAT'ın kendi `NetTrexCommon.FrameworkParameter` tablosu ayrı
sorgulanmalı (farklı sunucu/ortam, bu oturumdan erişilemedi).
