# progress-31 — Timeout değişikliği geri alındı, ekran klasörüne taşındı

**Tarih:** 2026-08-19 (aynı gün, `progress-30`'un ardından)
**Tetikleyen:** Kullanıcının `T-34` / `T-38` sorusu + **itirazı**

---

## 1. Kullanıcının itirazı (kendi sözleri)

> *"bu time out muhabbeti içinde ne yaptığını tam olarak anlamadım fakat benim amacım şuydu aslında
> sen ne kadar transaction seçersen seç foreach içinde transaction'ları döneceksin ya bunları tek tek
> sırayla istek atacaksın… ama sen radikal bir şekilde benim yapımdaki timeout durumlarını falan
> ellemişsin galiba bu isteyeceğim bir şey değil, side effect'inin ne olacağını bilemem, çok detaylı
> test gerekir, genel olarak bunu radikal değişiklik yaparsak bakamam açıkçası."*

**Haklı.** `progress-30`'da timeout ayarı `Trex.FrameworkCommon/Api/RefitExtensions.cs`'e yazılmıştı.
O dosya **19 Refit marker'ının tamamının** geçtiği paylaşılan yol. Yeni metot additive olsa da
`RegisterClientWebApiRefitClients<T>`'nin gövdesi de refactor edilmişti (`CreateRefitSettings()`
çıkarımı) — semantik olarak aynı, ama **yan etkisi ancak her ekran tek tek test edilerek** görülebilir.
Kullanıcı solo geliştirici; bu regresyon yüzeyini kabul etmiyor.

---

## 2. Ne yapıldı

| Adım | Sonuç |
|---|---|
| `git checkout -- Trex.FrameworkCommon/Api/RefitExtensions.cs Trex.WebUI/Startup.cs` | ✅ Kaynak diff'i **boş** — paylaşılan dosya bit-bit orijinal (BOM eklenmesi de geri gitti) |
| Yeni dosya: `Trex.WebUI/Services/ManualRediscount/ManualRediscountRefitRegistration.cs` (74 satır) | Timeout ayarı **ekranın kendi klasöründe** |
| `Startup.cs` — 1 çağrı + 5 satır yorum, **tam nitelendirilmiş** (`using` eklenmedi → gölgeleme riski sıfır) | Yalnız `IManualRediscountMmApi`'ye bağlı |
| JSDoc atıfları (`component.js:280`, `constants.js:149`) | Yeni yola güncellendi |

### Blast radius karşılaştırması

| | `progress-30` (geri alındı) | Şimdi |
|---|---|---|
| Değişen paylaşılan dosya | `RefitExtensions.cs` (19 marker'ın yolu) | **yok** |
| Timeout'u değişen arayüz | 1 (`IManualRediscountMmApi`) | 1 (aynı) |
| Regresyon yüzeyi | teorik olarak tüm ekranlar (ölçülemez) | **1 arayüz** (yapısal olarak sınırlı) |

### Neden ayar tamamen kaldırılmadı

Kullanıcının **kendi** şartı *"tek seferde gitsin ama içerde dönsün"* ile 100 sn duvarı
**birlikte var olamıyor**: Execute satır başına Fimple'a çıkıyor (~6-50 sn/satır), yani 3-4 satırda
duvar aşılıyor. `MaxItems`'ı düşürmek de çözmüyor — 50 sn/satır senaryosunda **2 satır** bile yetiyor.

🔴 Ve iptal **işi geri almıyor:** WebUI beklemeyi bırakıyor, MM'deki `foreach` arka planda devam edip
**fiş kesmeye devam ediyor**. Yani timeout bir "yavaşlık" değil, **yanlış sonuç raporlama** problemi.
Bu yüzden ayar korundu, ama **yeri değiştirildi**.

**Kullanıcı yine istemezse** alternatifler (hiçbiri bedava değil, kullanıcıya sunuldu):
1. `MaxItems`'ı 3-5'e düşür → duvar **garanti değil**, sadece olasılık düşer.
2. Satır bazlı istek (`progress-30` öncesi hâli) → performans şartına aykırı.
3. Fire-and-poll (`202` + job id + `Processing` polling) → gerçek `Processing` semantiği, timeout
   tamamen ortadan kalkar; **yeni uç + durum saklama** gerekir → **Faz 2 işi**.

---

## 3. Yeni cross-repo kural (MEMORY.md'ye yazıldı)

> **Paylaşılan framework dosyalarına DAVRANIŞ değiştiren dokunuş YOK.** Bir ekranın ihtiyacı
> `Trex.FrameworkCommon` / `Framework.WebUI` gibi tüm ekranların geçtiği bir dosyayı değiştirmeyi
> gerektiriyorsa değiştirilmez — ayar/override **ekranın kendi klasörüne** yazılır ve `Startup.cs`'te
> tek satırla **yalnız o tipe** bağlanır. Emsal: `ManualRediscountRefitRegistration.cs`.

`MEMORY.md`'deki timeout tuzağı girdisi de bu yönde düzeltildi (eski hâli `RefitExtensions.cs`'e
yazmayı öneriyordu) + ikinci `AddRefitClient` çağrısında **`RefitSettings` geçmenin zorunlu** olduğu
eklendi (geçilmezse Refit varsayılan serializer'a düşer → gövde PascalCase → modül alanları `null`).

---

## 4. Doğrulama

| Ne | Sonuç |
|---|---|
| `git diff` — `Trex.FrameworkCommon/` | **boş** |
| `dotnet build Trex.WebUI.csproj` | **0 Error** (1549 warning — mevcut) |
| JS testleri | **344/344** ✅ |
| `T-38` güncellendi + **`T-38b` eklendi** | Diğer ekranların (MM/FX Transaction, EOD, Daily Flow V2) regresyon kontrolü |

---

## 5. Kullanıcının diğer 2 sorusu (kod değişmedi, doğrulandı)

| Soru | Cevap |
|---|---|
| *"Generate/Regenerate'e basınca process statüsüne geçmeli, bitince Error/durumlar basılmalı"* | ✅ `component.js:230` `mrSetPendingOverlay` → `repaint()` → istek → `:332` `mrSetResultOverlay` üzerine yazar. ⚠️ `showLoader()` shading'i rozetleri **soluklaştırıyor** — kullanıcıya "Processing'i net görmek istersen loader'ı kaldırırız" diye soruldu |
| *"bir işlem yapıldığında statüsü değişiyor, bir kez daha çalıştırılabilir ve son durumuna göre ilerlenecek"* | ✅ `B-4` düzeltmesi: overlay'de `dbStatus` + `mrEffectiveStatus`; istek gövdesindeki `CurrentStatus` **en son bilinen kalıcı** durum; `Error`/`Processing` asla gönderilmiyor. Modül tarafı § 4.5 gereği DB'den yeniden türetip karşılaştırıyor |
