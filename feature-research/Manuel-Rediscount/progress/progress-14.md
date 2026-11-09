# progress-14 — 🔴 TARAYICI TESTİ: ekran 500 veriyordu, düzeltildi · ortamda 2 blocker bulundu

**Tarih:** 2026-08-14 · **Önceki:** [progress-13.md](progress-13.md)
**Tetikleyen istek:** *"Manuel reeskont ekranını ben test edicem fakat senin de test etmeni istiyorum…
uzun vadede MM ile alakalı ekranları test edebilmen için en mantıklı yöntem ne?"*

**Yöntem:** headless Chromium (PlayWright repo'sunun `node_modules`'ı) + `docker logs ui-nettrex` +
Common API swagger sorgusu. Tek seferlik script'ler scratchpad'de, repoya yazılmadı.

---

## 1. 🔴 BULGU-1 — Ekran 500: `Html.DevExtreme().ManualRediscount()` runtime'da çöküyordu

Kayıtlı `storageState.json` çerezi ile `/TreasuryRediscount/Index` açıldı → **HTTP 500**:

```text
System.InvalidOperationException: Html.DevExtreme().ManualRediscount() çalışamadı:
DevExtreme WidgetFactory içinden IHtmlHelper çözülemedi (DevExtreme sürümü değişmiş olabilir).
Alternatif: @await Component.InvokeAsync("ManualRediscount", Model)
```

**Kök neden:** `ResolveHtmlHelper` yalnızca `factory.GetType().GetFields(...)` bakıyordu.
`GetFields(NonPublic)` ne **property**'leri ne de **base sınıfın private field**'larını döndürür —
helper ise base sınıftaki non-public **`Html` property**'sinin verdiği adapter'ın içinde
(`Framework.WebUI/Extensions/DevxReflectionExtension.cs:25,34` bu şekli zaten belgeliyor:
`FormItemEditorFactory.Html` property + `HtmlHelperAdapter._html` field).

**Neden derleme yakalamadı:** extension method tip olarak doğru; hata yalnız **çalışma anında**
reflection sonucu `null` dönünce oluşuyor. MM 74 + JS 334 birim test de bu katmana hiç dokunmuyor.
progress-13'te *"tarayıcıda çalıştırılmadı"* diye açık bırakılan risk **gerçekleşti**.

**Düzeltme (iki katmanlı):**

| Ne | Nerede |
|---|---|
| Reflection hiyerarşi yürüyor (base tipler + field **ve** property, derinlik 2, getter patlarsa atla) | `ManualRediscountBuilderExtensions.ResolveHtmlHelper` / `FindHtmlHelper` / `ReadMemberValues` |
| 🟢 **Reflection'sız overload** `Html.ManualRediscount()` eklendi | aynı dosya |
| 3 ekran view'ı reflection'sız overload'a geçirildi | `Views/ManualRediscount/{Treasury,Security,Investment}/Index.cshtml` |

**Gerekçe:** bu bileşen bir DevExtreme widget'ı **değil**; `WidgetFactory`'nin içine uzanmak
gereksiz kırılganlık. Doküman §6.3 söz dizimi ikinci overload olarak duruyor ama **sevk edilen
ekranlar onu kullanmıyor** → `09-dokuman-uyumluluk-raporu.md` § 5.5 **✅ → 🟡 söz dizimi sapması**.

`dotnet build Code/Web/UI/Trex.WebUI/Trex.WebUI.csproj` → **0 Error(s)**.

⚠️ **Tarayıcıda henüz DOĞRULANMADI** — `ui-nettrex` container'ı imajdan koşuyor, bind-mount yok;
düzeltmenin görülmesi için `docker compose build trex.webui` gerekiyor (kullanıcının ortamı, sorulmadan yapılmadı).

## 2. 🔴 BULGU-2 — Login tamamen kırık (bizim kodumuz değil, **sürüm skew**)

`POST http://localhost:5032/Login` → **500** (hem `selim` hem `admin`):

```text
System.NullReferenceException: Object reference not set to an instance of an object.
   at Framework.WebUI.Controllers.LoginController.Index(LoginViewModel) in ...\LoginController.cs:line 83
```

Container log'u zinciri gösteriyor:

```text
Start processing HTTP request POST http://192.168.10.173:5051/api/UserProfile/check-user-profiles-and-claims
Received HTTP response headers after 10.1149ms - 404
```

`LoginController.cs:78` `_userProfileApi.CheckUserProfilesAndClaims(...)` çağırıyor, `:83`
`userClaims.Data.HaveAnyClaim` okuyor → 404 sonrası `Data` **null** → NRE.

**Kanıt (sürüm skew):** endpoint `NetTrex.Common` **kaynağında var**
(`Controllers/Authentication/UserProfileController.cs:78` → `[HttpPost("check-user-profiles-and-claims")]`),
ama **192.168.10.173:5051'de deploy edilmiş sürümde YOK**. O sunucunun swagger'ı yalnızca
`select · get · getUserProfiles · create · update · delete` gösteriyor — `verify`, `reject`,
`history`, `check-user-profiles-and-claims` **hiçbiri yok** → deploy **bayat**.

**Etkisi:** Selim'in kendi tarayıcı testi de bu yüzden login olamaz.
**Çözüm (kullanıcıda):** ya 5051'deki Common API yeniden deploy edilir, ya
`Code/docker-compose.override.yml:23,54` (`Framework__Application__CommonApi` / `CommonApi`)
local Common'a çevrilir (satır zaten yorumda: `http://nettrexcommonwebapi:80/api`).

## 3. Ölçülen ortam

| Servis | Adres | Durum |
|---|---|---|
| WebUI (`ui-nettrex`) | `http://localhost:5032` | ✅ ayakta (302 → /Login) |
| MM WebApi (`nettrexmmwebapi`) | `http://localhost:5041` | ✅ swagger 200, health 200 |
| MM Batch | `5043` · MM Kafka `5044` | ✅ |
| Common API | `http://192.168.10.173:5051` | ⚠️ ayakta ama **bayat sürüm** |
| Micro UI (`Treasy.MM.UI`) | `5104` | ⬜ kapalı |
| Chromium (Playwright) | `~/AppData/Local/ms-playwright/chromium-1234` | ✅ kurulu |

---

## 4. Yapılanlar (Done)

- Tarayıcı smoke'u koşuldu → **BULGU-1** (bizim bug) + **BULGU-2** (ortam) bulundu.
- BULGU-1 düzeltildi (reflection + reflection'sız overload + 3 view), build ✅.
- `09-dokuman-uyumluluk-raporu.md` § 5.5 dürüstçe 🟡'ye çekildi.

## 5. Yapılıyor (In Progress)

- Uzun vadeli test stratejisi önerisi kullanıcıya sunuldu (3 katman: birim → **API sözleşme** → **ince tarayıcı smoke**;
  derin E2E yalnız para hareketi olan akışlarda). Kullanıcı kararı bekleniyor.

## 6. Yapılacaklar (TODO)

| # | İş | Sahip |
|---|---|---|
| 1 | `docker compose build trex.webui` + up → BULGU-1 fix'ini tarayıcıda doğrula | ⬜ onay bekliyor |
| 2 | Common API (5051) yeniden deploy **veya** `CommonApi`'yi local'e çevir → login'i aç | Selim |
| 3 | Menü + permission SQL scriptleri (`outputs/2026-08-13-ManualRediscount-*.sql`) | Selim |
| 4 | Tier-2 **API sözleşme testleri** (`Load` yanıt şekli · `Data` anahtarları ↔ kolon config JSON) | ⬜ |
| 5 | Tier-3 **ince tarayıcı smoke**'u (3 ekran: 200 · `pageerror` yok · asset 4xx yok · grid header'ları) | ⬜ |
| 6 | Faz 2 gerçek fiş testi (Fimple'a yazar) | ⬜ açık onay şart |
| 7 | Önceki açık kalemler değişmedi | → [progress-12.md § 5](progress-12.md) |
