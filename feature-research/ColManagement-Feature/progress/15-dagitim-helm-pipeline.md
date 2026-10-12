# 15 — Dağıtım: Helm · Azure Pipelines · Sonarqube (B)

**Tarih:** 2026-10-09 · build **0 hata**

## Kullanıcı kararları (AskUserQuestion, 2026-10-09)
| Soru | Cevap |
|---|---|
| Route adları (H-079) | *"routing adları da Option'dan alınsın… UI'da da adları aynı şekilde Option'dan alabilirsin ama UI'a geçince konuşalım"* → **OptionsFX route'ları kalıyor** (K-47) |
| Values ortamları | **MM gibi** — katilim · test · v1.34dev · v1.34test · v1.35dev · v1.35test · v134 · v136dev · yatirim |
| Port / image | **5061 · 5062 · 5063** + **MM ad deseni** → `nettrex/nettrexcolmanagement-api` · `-batchapi` · `-kafkaapi` |
| Pipeline tetikleyici | **MM** — `brn-v*_dev` + `brn-v*_test` |
| Elasticsearch | **Evet, OptionsFX gibi** — kimlik bilgisi K8s secret `elasticsearch-auth`'tan |
| Tercih | *"senin bu şekilde bunlar nereden alınsın diye sormanı sevdim, sor bana"* → hafıza: MM/OFX sözleşme/UI farkında **sor** |

## Üretilen (MM'den dönüştürülerek — 66 dosya)
| | |
|---|---|
| `helm/nettrex-colmanagement` · `-batch` · `-kafka` | Chart + templates + 9 ortam values'ı. Servis adları `nettrex-colmanagement-web/-batch/-kafka(-<ortam>)` |
| `azure-pipelines.yml` · `-batch.yml` · `-kafka.yml` | MM birebir, ad/image/Dockerfile yolu ColManagement |
| `pipelines/templates/**` | dev · production · docker-build-push · fimple-push · git-tagging · version-calculation |
| `Dockerfile_sonarqube` ×3 | Bizim Dockerfile (ağaçtan üretilmiş COPY listesi) + MM'in sonar adımları; proje adı `NetTrex.ColManagement-WEB/-Batch.Api/-Consumer`; testler bizim `UnitTests/` projeleri (Consumer'da yorumda, MM gibi) |

**Dönüşüm kuralları:** `nettrex-mm*`→`nettrex-colmanagement*` · `nettrexmm-`→`nettrexcolmanagement-` · 5041/42/43→5061/62/63 ·
`ClientSecret` → yer tutucu (18 dosya) · `ApplicationSettings__KafkaBootstrapServers` (27) · `FIApi` (18) · `FXApi` (9) çıkarıldı.

## Kod/konfig tarafı
- `appsettings` ×3: Serilog `WriteTo[2]` = **Elasticsearch** (`nodeUris` lokal `http://localhost:9200`, index `nettrex-colmanagement-{0:yyyy-MM-dd}`, kimlik yok — helm secret'tan) · `Using`'e `Serilog.Sinks.Elasticsearch` (paket zaten dolaylı geliyor). 58/58 anahtar birebir.
- Lokal portlar da **5061/5062/5063** (launchSettings + compose) — MM'de lokal = cluster portu.

## 🔴 Kullanıcıya bildirilen
**H-083:** `.gitignore`'da `helm/` var (MM'den). MM'de helm daha önce zorla eklendiği için izleniyor; **yeni repoda helm commit'e girmez** → satırı kaldır ya da `git add -f helm`.

⚠️ Helm/pipeline çalıştırılmadı (`helm template` yok). Sonarqube testleri boş projelerde koşar (K-30).
