# progress-23 — 🔴 KÖK SEBEP: `IsFailed()` kontrolü Fimple hata metinlerini çöpe atıyordu

**Tarih:** 2026-08-18

## Neden

progress-22'de "Error: Execution failed." semptomunu iki yerde hafiflettim (controller `Messages`
fallback'i + JS transport catch'i) ama **kök sebebi bulmamıştım**. Kullanıcı ısrar etti:
*"sen bana sana sorduğum açıklamayı yap… Fimple'dan hata geldiği zaman nasıl ilerleme kat ediyor…
FX tarafındaki manuel reeskonta bak bakalım… ben ekranda sadece hata görüyorum ama normalde Fimple'dan
bize anlamlı mesaj gelmiş olsa bile."*

Zinciri uçtan uca izleyince kök sebep bulundu — semptom değil, **veri kaybının tam yeri**.

## 🔴 Kök sebep — `ManualRediscountQueryService` satır 78 (ve 49)

```csharp
if (external is null || external.IsFailed() || external.Data is null)
    return FailedExecution(external?.Data?.Message ?? $"'{request.ModuleCode}' modülünden yanıt alınamadı.");
```

Üç bağlantılı gerçek bunu bozuyor:

1. **`IsFailed()` = `!IsSuccess`** — `Framework.Abstractions/Messaging/BaseResponse.cs:25`.
2. **`ToContentExternal` modülün `IsSuccess`'ini AYNEN kopyalar** —
   `Trex.FrameworkCommon/Api/RefitExtensions.cs:53` → `result.IsSuccess = serviceResult.Content.IsSuccess;`
3. **MM `Failed[]` doluysa TASARIM GEREĞİ `IsSuccess = false` döner** — `ExecutionsHandler.cs:171`
   (`ADR-MR-007`, *"IsSuccess = true yalanı yok"*).

Zincirin sonucu: **Fimple bir satırda hata verdiği anda `IsFailed()` true oluyor** → `if` tetikleniyor →
`external.Data` (içinde `Failed[]`, `Succeeded[]`, tüm `ReasonDetail` metinleri) **komple çöpe gidiyor**,
yerine tek satırlık `FailedExecution(...)` konuyor.

Üstüne ikinci bir kusur: `external?.Data?.Message` — `Data` **null değil** (yanıt geldi), `Message` ise
**boş string**. `??` operatörü boş string'de tetiklenmez → mesaj `""` kalıyor → `Messages[0].Text = ""`.

Ekranda (`manual-rediscount.actions.js:250-253`):
```js
if (isSuccess === false && succeeded.length === 0 && failed.length === 0)   // ← failed artık BOŞ
    notifyError(response.message || mrText("mr-error-ExecuteFailed", ...));  // ← "" falsy → fallback
```
→ **"Error: Execution failed."** Kullanıcının gördüğü tam olarak bu, tesadüf değil.

Yani Fimple'ın anlamlı metni (`"Fimple Error => Code: 3058, Message: Hesap tanımında defter türündeki
muhasebe hesapları için referans türü ve referans no alanları boş olmalıdır. Defter hesabı: (36099200)"`)
`ExecutionsHandler`'da **doğru şekilde** `Failed[0].ReasonDetail`'e yazılıyordu ve MM 200 ile **doğru
şekilde** döndürüyordu — WebUI service katmanı onu **son adımda** atıyordu.

## Fix

Her iki metotta (`ExecuteAsync` + `GetEligibleTransactionsAsync`) `IsFailed()` kontrolü **kaldırıldı**.
Transport hatasının tek doğru göstergesi **`Data is null`**: `ToContentExternal`, Refit hatası yolunda
(`RefitExtensions.cs:41-49`) `Data`'yı **hiç set etmez**, doğrudan `return` eder. `Data` geldiyse elimizde
gerçek bir modül yanıtı var — `IsSuccess`/`Messages`/`Failed[]` içinde doğru bilgi zaten mevcut, olduğu
gibi taşınmalı.

```csharp
if (external?.Data is null)
    return FailedExecution(ResolveTransportMessage(external, request.ModuleCode));

return external.Data;
```

Ayrıca yeni `ResolveTransportMessage` helper'ı: eski kod `external?.Data?.Message` okuyordu ama
transport hatasında `Data` **tanımı gereği null** — yani o ifade **her zaman** null'dı, Refit'in gerçek
hata metni hiç kullanılmıyordu. Artık `external.Messages` (ToContentExternal'ın Refit hatasını yazdığı
yer, `RefitExtensions.cs:46`) ilk dolu metinden okunuyor, yoksa jenerik metne düşülüyor.

`System.Linq` using'i eklendi (`FirstOrDefault` için).

## Eski FX ekranı ne yapıyordu (kullanıcı sordu)

`Views/ManuelReescont/Index.cshtml:226-235`:
```js
success: function(response) {
    if (response.IsSuccess) {
    }          // ← BOŞ BLOK
},
complete: function() { onFilterChanged(); btnInstance.option("disabled", false); }
```
`error` handler'ı **hiç yok**, `success` bloğu **boş**. Eski ekran hatayı **hiç göstermiyordu** — sadece
grid'i yeniliyor ve butonu açıyordu. Oradan alınacak bir desen yok; bizim `mrShowExecutionResult`
tasarımı (satır bazlı, `ReasonCode` localize + `ReasonDetail` ham metin, dialog'da) zaten çok daha
ileride. Sorun tasarımda değil, **verinin ona ulaşmamasındaydı**.

## Neden batch/verify'da bu sorun yok

Batch tek transaction üzerinden gider: `catch (Exception ex) → LogWarning(ex.Message)` — mesaj tek yere
düşer, listeye girmez, `IsSuccess` bayrağıyla ilişkisi yoktur. Verify'da da tek işlem: `RefitExtensions`
hatayı `Messages`'a koyar, `BaseController` doğrudan basar. **Tek transaction = tek mesaj**, bu bug'ın
oluşabileceği "liste + bayrak" ikilemi hiç doğmuyor.

Manuel Reeskont N satırlı olduğu için `Failed[]`/`Succeeded[]` + `IsSuccess` bayrağı birlikte taşınıyor —
bu bug tam da o kombinasyonda doğdu: **bayrağa bakıp listeyi atmak**.

## Test durumu

- `dotnet build Web/UI/Trex.WebUI/Trex.WebUI.csproj` → **0 error** (arka planda koştu, exit 0).
- ⚠️ **Bu davranış için test YAZILMADI.** `ManualRediscountQueryService` bir Refit client'ı
  (`IManualRediscountModuleResolver` → `ToContentExternal` extension) çağırıyor; extension metot statik
  olduğu için mock'lanamaz, `ApiResponse<T>` üretmek gerekir. Bu projede emsal bir WebUI service testi
  bulunamadı (harness yok). 🔴 **Karar taşıyan bir dallanma testsiz kaldı** — Hard Rule 10 gereği
  açıkça belirtiyorum, sessizce geçmiyorum. Kurulması istenirse ayrı iş.
- ⚠️ Tarayıcıda **doğrulanmadı** — kullanıcının bir sonraki canlı testinde Fimple hatası tekrar
  üretilirse ekranda artık dialog içinde tam Fimple metni görünmeli.

## Açık kalan

- WebUI service/controller test harness'i (yok, kurulması ayrı iş).
- JS jest altyapısı `npm install` bekliyor.
- Execute-hang soruşturması parkta (progress-21).
- IL fiş kesme (write-side) hâlâ yazılmadı, ayrı onay bekliyor (progress-20).
