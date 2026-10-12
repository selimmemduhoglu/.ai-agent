# 16 — MM ile Karşılaştırma + Docker/Helm MM'e Birebir

**Tarih:** 2026-10-09 · build **0 hata**

**Kullanıcı:** *"MM'de helm nasılsa ya da Docker dosyaları nasılsa sen de buraya aynı şekilde koy. Sen şimdi tablolar
dışında backend bitti diyorsun ama MM projesiyle karşılaştır bakalım gerçekten bitmiş mi. Biz doğru yansıtmış mıyız?"*

## 1. Docker / helm — MM ile birebir

| Dosya | Önce | Şimdi |
|---|---|---|
| `Dockerfile` ×3 | Ağaçtan üretilmiş, yorumlu, `--no-restore` | **MM biçimi**: grup başlıkları (`# Api`, `# Common`…), MM'in proje sırası, `# Restore NuGet packages` / `# Build the project` / `# Publish the project` adımları. Tek fark: `Directory.Build.props` + `Directory.Packages.props` COPY satırları (merkezi paket yönetimi — OptionsFX'te de böyle) |
| `Dockerfile_sonarqube` ×3 | Benim şablonum | **MM birebir** (Api coverlet msbuild, Batch XPlat, Consumer testleri yorumda — H-087, H-089 aynen) |
| `docker-compose.yml` / `.override.yml` | Benim biçimim | **MM birebir**: `version 3.7`, `trex-network`, servisler `ColManagementWebApi` / `ColManagementKafkaApi` / `ColManagementBatchWebApi`, MM'in env listesi + yorumlu alternatifler. Parola/ClientSecret yer tutucu, DB `NetTrexColManagement` |
| `docker-compose.dcproj` · `Code/launchSettings.json` | yoktu | **MM'den** (yeni GUID); dcproj `.sln`'e eklendi, build etkilenmedi |
| `helm/` · `pipelines/` · `azure-pipelines*.yml` | MM'den, bazı anahtarlar çıkarılmıştı | **MM birebir** — yalnız `ClientSecret` yer tutucu (H-086 artık "aynen") |
| `.dockerignore` | — | zaten MM ile aynı |

## 2. MM ile karşılaştırma — "tablolar dışında bitti mi?"

MM'in 50 projesindeki her klasör tarandı. Sınıflandırma:

### ✅ Bizde var (MM'de de var)
Startup ×3 · DI · Seq/Serilog · Fimple auth/muhasebe/veri/bildirim · Kafka producer + Consumer · Accounting motoru ·
Batch (BOD/EOD, Hangfire, SignalR, takvim, LogicalDateUpdate, DateTimeCheck) · EOD/BatchLog/JobCron uçları · TxnNote/TxnDocument ·
Calendar/Currency/Customer/Portfolio/FinancialInstitution/PaymentInstructionType/SettlementType/ProductDefinition uçları ·
Data helper'ları · sayaç üretici · StateEngine · ChangeTracker · BatchDbContext · helm/pipeline/Docker.

### 🆕 Bu turda eksik bulunup eklenen
| Parça | Kaynak | Not |
|---|---|---|
| `FKeyAccounting` (işlemin muhasebe fişleri — handler/RR/model) | OFX (MM'de aynı) | Uç Transaction controller'ıyla gelecek |
| **Kur servisleri** `IFxRateService` · `IInterestRateService` + `FxRate`/`InterestRate`/`InterestRateDetail` DataManager'ları + modeller | **MM** (kullanıcı kararı) | OFX bunu QuGet ile yapıyordu. Core.Data entity'lerine bağlandı |
| `FloatingRateType` (entity · config · DataManager) | MM | `InterestRateService` istiyor — MM'in modül tablosu → H-094 |
| `RateConstants` · `MathExtension.RoundAwayFromZero` · `RateAbmType` · `IHelper.GetInterestRateFloatingChart*` (+ `CM.DepoRate:*` parametreleri) | MM | |
| **Country topic** `country-insert` (request · handler · `ICountryRepository`) | **MM** (kullanıcı kararı) | Entity OFX'in; alan eşlemesi `CountryMapper` (`Code→CountryCode`) — H-093 |

### ❌ MM'de olup bilinçli alınmayan
| Parça | Neden |
|---|---|
| `FxRateValidationBatchItem` · `InterestRateValidationBatchItem` | 🔴 MM'de **boş** — `NotImplementedException` (H-091). Kullanıcıya sorarken çalışır sanılmıştı, düzeltme bildirildi |
| InterbankLoan · Tawarruq · PassGil · CashFlow · Amortization · Fee · Forward · LoanRevaluation · IssueBond | MM ürünlerine özel iş |
| MarketIntegration (Bloomberg/SFTP/Minio) · Stp · ExternalStp · ExternalTransactionBooking (Eximbank) · ExternalMaps | MM entegrasyonları |
| TransferMessage · Payment (+Steps) · Account (Fimple hesap) | Ödeme mesajı — A-26 ertelendi |
| Commission/Tax calculators · Tax topic'leri | MM ürün hesapları |
| DailyCheck · AccountOperation (hesap kapama) · FundSource · AccountSelectionType · AccountingCalculationMethodType · AmortizationType · TxnType · Market · MarketCustomerMap · DateBasis uçları | MM ekranlarına özel |
| `UiCultureActionFilterAttribute` | Ölü (H-095) |

### ⏳ Tabloya bağlı — entity'lerle gelecek
Transaction uçları (+ paging/`SortDescriptor`) · TxnDetail · muhasebe olayı · Reconciliation · DailyFlow/DailyFlowV2 (Common fan-out sözleşmesi) ·
TransactionHistory · grid durum filtreleri (`QueryableExtension`) · ManualRediscount (gerekirse) · ColManagement EOD batch item'ları.

**Sonuç:** Karşılaştırma öncesi "bitti" demem **eksikti** — kur servisleri, Country beslemesi ve FKeyAccounting MM'de olup bizde yoktu; eklendi.
Bu turdan sonra MM'in tablodan bağımsız ve ColManagement'a uygulanabilir parçası kalmadı.

## 3. Doğrulama
`dotnet build` (dcproj dahil) → **0 hata**. ⚠️ Docker build / helm template / servisler çalıştırılmadı.
