# SQL Çıktıları — MM Kafka notification fix

> DB: `NetTrexCommon` @ 192.168.10.211 (bizim test ortamı, **müşteri DB'si değil**)

## #1 — ExternalNotification kolonları (ham)

```text
name|type|max_length|is_nullable
Id|int|4|0
Module|nvarchar|100|1
Product|nvarchar|100|1
Purpose|nvarchar|1000|1
ToMail|nvarchar|600|1
ToCc|nvarchar|600|1
ToBcc|nvarchar|600|1
Subject|nvarchar|600|1
MailBody|nvarchar|-1|1
ToPhoneNumber|nvarchar|1000|1
SmsBody|nvarchar|1000|1
NotificationCode|nvarchar|300|0
IsSuccess|bit|1|0
NotificationResult|nvarchar|-1|1
BusinessKey|bigint|8|1
MessageKey|bigint|8|1
ChannelType|nvarchar|100|1
```

**Yorum:** `max_length` byte cinsinden (nvarchar → karakter = /2). ToMail/ToCc/ToBcc/Subject = 300 karakter, Module/ChannelType = 50, NotificationCode = 150, MailBody/NotificationResult = MAX. Müşterinin MM EOD verisi (To ≈134 karakter, Subject ≈30) bu şemaya sığar → müşteri DB şeması farklı olmalı.

## #2 — Son 20 kayıt uzunlukları (ham)

```text
Id|Module|IsSuccess|ToMailLen|ToCcLen|SubjectLen|MailBodyLen|ResultLen|Result
40015|Common|0|0|0|22|9476|40|Mail Service Not Send reason:Bad Request
40014|Common|0|22|0|37|1053|40|Mail Service Not Send reason:Bad Request
40013|FI|0|29|NULL|69|90637|40|Mail Service Not Send reason:Bad Request
40012|FI|0|26|0|68|680|40|Mail Service Not Send reason:Bad Request
40011|Common|0|0|0|22|13980|40|Mail Service Not Send reason:Bad Request
40010|Common|0|0|0|22|14819|40|Mail Service Not Send reason:Bad Request
40009|Common|0|0|0|22|9476|40|Mail Service Not Send reason:Bad Request
40008|Common|0|22|0|37|1231|40|Mail Service Not Send reason:Bad Request
40007|FI|0|29|NULL|69|90180|40|Mail Service Not Send reason:Bad Request
40006|FI|0|26|0|68|680|90|Mail Service encountered an error: Network is unreachable (identity.test.fimple.co.uk:443)
40005|Common|0|0|0|22|9476|40|Mail Service Not Send reason:Bad Request
40004|Common|0|0|0|22|5045|40|Mail Service Not Send reason:Bad Request
40003|Common|0|22|0|37|1019|40|Mail Service Not Send reason:Bad Request
40002|FI|0|29|NULL|69|90637|40|Mail Service Not Send reason:Bad Request
40001|Common|0|0|0|22|10696|40|Mail Service Not Send reason:Bad Request
40000|Common|0|22|0|37|1019|40|Mail Service Not Send reason:Bad Request
39999|FI|0|29|NULL|69|90637|40|Mail Service Not Send reason:Bad Request
39998|Common|0|0|0|22|9476|40|Mail Service Not Send reason:Bad Request
39997|Common|0|22|0|37|2366|40|Mail Service Not Send reason:Bad Request
39996|FI|0|29|NULL|69|90637|40|Mail Service Not Send reason:Bad Request
```

**Yorum:** Fimple hata verdiğinde `NotificationResult` kısa (40 karakter) → truncate kaynağı o değil. Bizde 90K karakterlik body sorunsuz yazılıyor (MailBody = MAX). Test ortamında MM kaydı yok; tüm kayıtlar IsSuccess=0 (test Fimple'ı Bad Request dönüyor).
