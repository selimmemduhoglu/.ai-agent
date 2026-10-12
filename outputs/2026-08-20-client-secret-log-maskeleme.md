# `client_secret` log'a düz metin yazılıyor — hazır yama (UYGULANMADI)

**Tarih:** 2026-08-20
**Durum:** 🟥 **Kullanıcı onayı bekliyor — kod DEĞİŞTİRİLMEDİ**
**Dosya:** `NetTrex.MM/Code/Common/NetTrex.MM.Common.Services/Handlers/ExternalHttpLoggingDelegateHandler.cs`

---

## Bulgu

Handler giden her isteğin gövdesini logluyor. JSON olmayan gövde `PrettyPrint`'ten **ham** dönüyor.
Fimple'ın token ucu form-urlencoded gönderdiği için (`FimpleAuthService.cs:29-32`) log'a şu düşüyor:

```
>>>>>>>>> Request Body: client_id=<...>&client_secret=<GERÇEK SIR>&grant_type=client_credentials
```

Bu **yeni bir regresyon değil** — bugüne kadar da böyleydi. 2026-08-20'de eklenen `LooksLikeJson`
guard'ı yalnız exception'ı önledi, log içeriğine dokunmadı.

**Neden şimdi önemli:** Manuel Reeskont satır başına Fimple'a gidiyor → token isteği sıklaştı →
sır log'da **daha sık** görünüyor.

## Neden kendim uygulamadım

Handler MM'deki **tüm** Fimple çağrılarının log'unu üretiyor. Maskeleme, log çıktısını her akış
için değiştirir. 2026-08-19 kuralı (`MEMORY.md` → *"paylaşılan framework dosyalarına davranış
değiştiren dokunuş YOK"*) gereği bu **kullanıcı kararı**.

## Yama

`LooksLikeJson`'un hemen altına:

```csharp
    // Form-urlencoded govdede sir tasiyan alanlar. JSON govdede bu alanlar gecmiyor
    // (Fimple is uclarinda credential yok) - yine de ayni maske ikisine de uygulanir.
    private static readonly string[] SecretKeys = ["client_secret", "password", "access_token", "refresh_token"];

    /// <summary>
    /// Govdedeki sir tasiyan alanlarin DEGERINI maskeler. Anahtar adlari korunur ki
    /// log hala hangi alanin gonderildigini gostersin.
    /// </summary>
    private static string MaskSecrets(string body)
    {
        if (string.IsNullOrEmpty(body)) return body;

        foreach (var key in SecretKeys)
        {
            // form-urlencoded:  key=deger&...      JSON: "key":"deger"
            body = System.Text.RegularExpressions.Regex.Replace(
                body,
                $@"({System.Text.RegularExpressions.Regex.Escape(key)}""?\s*[=:]\s*""?)([^&""\s,}}]+)",
                "$1***",
                System.Text.RegularExpressions.RegexOptions.IgnoreCase);
        }

        return body;
    }
```

Sonra **iki** çağrı yerinde sar:

```csharp
// LogRequestAsync icinde
logger.LogInformation(message: " >>>>>>>>> Request Body: {Body}", MaskSecrets(PrettyPrint(requestBody)));

// LogResponseAsync icinde
logger.LogInformation(message: " <<<<<<<<< {StatusCode} Response Body: {Body}",
    (int)response.StatusCode, MaskSecrets(StripVerboseFields(responseBody)));
```

## Etki

| | Öncesi | Sonrası |
|---|---|---|
| Token isteği log'u | `client_secret=<gerçek sır>` | `client_secret=***` |
| Token **yanıtı** log'u | `"access_token":"eyJ…"` | `"access_token":"***"` |
| Diğer Fimple çağrıları | değişmez | değişmez (bu anahtarlar geçmiyor) |

⚠️ Yanıttaki `access_token` maskelenirse bir sorunu **token'ın kendisine bakarak** debug etmek
zorlaşır. Sadece isteği maskelemek istersen `LogResponseAsync`'i değiştirme.

⚠️ Regex gövdeyi metin olarak işler — çok büyük JSON yanıtlarda 4 anahtar için 4 tarama yapar.
Ölçülebilir bir maliyet değil, ama log handler'ı sıcak yolda olduğu için biliniyor olsun.
