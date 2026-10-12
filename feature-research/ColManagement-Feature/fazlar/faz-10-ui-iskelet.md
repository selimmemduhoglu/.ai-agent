# Faz 10 — UI İskeleti (`Treasy.ColManagement.UI`)

**Durum:** ⬜ · **Ön koşul:** Faz 8 (işlem ucu çalışıyor) · **Repo:** `Treasy.ColManagement.UI`

## 1. Amaç
Micro UI projesi ayağa kalksın, Shell'den açılsın, menüsü gelsin. Ekran yok.

## 2. Emsal
🔑 **`Treasy.MM.UI`** — kullanıcı kararı. (`Treasy.OptionsFX.UI` ilk örnek ama local'de **yok**.)

## 3. Mimari hatırlatma
Shell **iframe değil, MVC area değil** → **YARP reverse proxy + HTML response rewrite**
(`MicroFrontendHtmlRewriteMiddleware`). Shell portu `5206`.

## 4. Adımlar
| # | Adım |
|---|---|
| 1 | `Treasy.MM.UI` dosyaları kopyalanır, `ColManagement` olarak yeniden adlandırılır |
| 2 | `Treasy.MicroUI.SharedDependency` (RCL) referansı — sürüm **csproj'dan** doğrulanır, dokümandan değil |
| 3 | `@treasy/*` npm paketleri (Nexus `192.168.10.241:8081/repository/treasy-npm/`) |
| 4 | Vite + localization bundler MSBuild target'ları |
| 5 | 🔴 **Shell'e kayıt İKİ YERDE:** `MicroFrontends:Services` (code, baseAddress, `/Discovery/Info`, `/Discovery/Health`) **ve** `ReverseProxy:Routes/Clusters`. **Route prefix = `code`** |
| 6 | Port: `51xx` web / `61xx` vite, son iki hane aynı |
| 7 | Refit client: `IClientColManagementApi` + `ColManagementApi` config key |

## 5. Tuzaklar
- 🔴 **Menü Discovery'den gelmez** — `SharedDependency/MenuController` → **Common API** `GetModuleMenu`.
  `FrameworkMenu`'ye satır eklemek **yetmez**: `ModuleMenu:{UserId}` Redis hash'i **8 saat** bayat kalır.
- ⚠️ `Treasy.MM.UI`'de ekran bazlı sunucu yetkisi **fiilen kapalı** (tek `[CustomAuthorize]` yok,
  Shell'de `SkipAuthorization: true`). Bu boşluğu **bilerek** devral.
- ⚠️ `SharedDependency` sürümünü **csproj'dan** doğrula — dokümanlar bayat (1.0.3 yazarken gerçek 1.0.4-dev12).
- ⚠️ Micro UI sıfırdan kurma rehberi `Treasy.MicroUI.Base`'de ama **bu makinede klonlu değil**.

## 6. Bitiş kriteri
1. ✅ Shell'den `/cm/` açılıyor
2. ✅ Menü geliyor (Redis temizlendikten sonra)
3. ✅ `/Discovery/Health` yeşil
4. ✅ Backend'e bir Refit çağrısı gidip dönüyor

## 7. Çıktı
`../progress/10-ui-iskelet.md`
