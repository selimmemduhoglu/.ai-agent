# progress/ — Yapılan İş Kaydı

> 🔴 **APPEND-ONLY.** Yeni iş = **yeni numaralı** dosya. Önceki dosyalar **asla düzenlenmez/silinmez**.
> Durum bilgisi burada değil → [`../02-DURUM.md`](../02-DURUM.md).

| # | Dosya | Tarih | Ne yapıldı |
|---|---|---|---|
| 01 | [`01-repo-iskeleti.md`](01-repo-iskeleti.md) | 2026-10-05 | Repo dosyaları + `.ai-agent/` MD omurgası |
| 02 | [`02-excel-v5.md`](02-excel-v5.md) | 2026-10-07 | Excel v5 — isimlendirme ev konvansiyonuna geçti, ProductDefinition + 3 yeni sheet |
| 03 | [`03-md-faz-yapisi.md`](03-md-faz-yapisi.md) | 2026-10-08 | Modül adı **ColManagement**; 13 faz dosyası + `02-DURUM.md` + işin ana evi workspace'e taşındı |
| 04 | [`04-backend-iskelet.md`](04-backend-iskelet.md) | 2026-10-08 | **Faz 3** — `NetTrex.ColManagement.sln` 54 proje, build 0 hata. OptionsFX ölçülüp üretildi (kopyalanmadı) |
| 05 | [`05-backend-altyapi.md`](05-backend-altyapi.md) | 2026-10-08 | **Faz 5** — DI omurgası, `EfDbContext`, `CoreDataSlice` (D-01 kapandı), pipeline, `Startup`. Build 0 hata |
| 06 | [`06-auth-fimple-consumer.md`](06-auth-fimple-consumer.md) | 2026-10-08 | **Faz 5 devamı** — Fimple/Keycloak auth, Refit altyapısı, Kafka Consumer. 2 tuzak düzeltildi. 🔴 Unit test yazılmıyor kararı |
| 07 | [`07-mm-tabani-ve-loglama.md`](07-mm-tabani-ve-loglama.md) | 2026-10-08 | Taban **MM**'e çevrildi (Accounting hariç) · Seq loglamada 9 açık kapatıldı · appsettings 3 projede birebir aynı · yorumlar budandı |
| 08 | [`08-temel-yapi-tamam.md`](08-temel-yapi-tamam.md) | 2026-10-08 | **Faz 5 kapandı** — Consumer OptionsFX teyit · Dockerfile ×3 (ağaçtan üretildi) · launchSettings · appsettings.Development · K-37 kaynak seçim ilkesi |
| 16 | [`16-mm-karsilastirma.md`](16-mm-karsilastirma.md) | 2026-10-09 | Docker/compose/dcproj/helm MM'e birebir · MM karşılaştırması: kur servisleri + Country topic + FKeyAccounting eklendi; MM EOD kur kontrolleri boş (H-091) |
| 15 | [`15-dagitim-helm-pipeline.md`](15-dagitim-helm-pipeline.md) | 2026-10-09 | B: helm ×3 (9 ortam) · azure-pipelines ×3 · templates · Dockerfile_sonarqube ×3 · port 5061-63 · ES sink · route=OptionsFX (K-47) |
| 14 | [`14-api-tanim-uclari.md`](14-api-tanim-uclari.md) | 2026-10-09 | A: Calendar (MM) + Currency/Customer/Portfolio/JobCron/FinancialInstitution/PaymentInstructionType/SettlementType/ProductDefinition (OFX) uçları · route farkı H-079 |
| 13 | [`13-consumer-data-common.md`](13-consumer-data-common.md) | 2026-10-09 | Consumer bitti (3 topic) · EOD/BatchLog/Not/Doküman uçları · Data/Common MM∩OFX ortak parçalar · Common muhasebe shared modelleri. Tablodan bağımsız backend işi kalmadı |
| 12 | [`12-hata-kaydi-ve-muhasebe.md`](12-hata-kaydi-ve-muhasebe.md) | 2026-10-09 | **K-46** `03-HATA-KAYDI.md` açıldı (70 madde) · Accounting grubu + Fimple muhasebe/veri servisleri OptionsFX'ten aynen taşındı |
| 11 | [`11-mm-takvim-ve-quget.md`](11-mm-takvim-ve-quget.md) | 2026-10-09 | **K-45** belirsizlikte MM. `AddQuant`/QuGet çıktı → MM `CalendarHelper`; `DateTimeProvider` decompile edildi (= `DateTime.Now`, TZ container'dan); Batch bildirim + SignalR MM'e döndü |
| 10 | [`10-optionsfx-altyapi-portu.md`](10-optionsfx-altyapi-portu.md) | 2026-10-09 | OptionsFX Data/Batch/Bildirim-Kafka altyapısı taşındı; 18 açık OptionsFX+MM'de kontrol edildi. Fimple düzeltmesi (K-43), TxnDetail ilkesi (K-44), klasör `ColManagement-Feature` |
| 09 | [`09-optionsfx-hizalama.md`](09-optionsfx-hizalama.md) | 2026-10-09 | Patron toplantısı sonrası **K-39**: Seq MM, gerisi OptionsFX. Startup ×3 · Auth/Fimple · DI hizalandı; OptionsFX'in 15 açığı bildirildi/düzeltildi |

## Dosya biçimi

```
# NN — <başlık>
**Tarih:** · **Faz:** · **Çıktı:** (dosya yolları)
## Yöntem        — nasıl yapıldı, hangi komut/script
## Değişiklikler  — ne değişti
## Kararlar       — bu turda verilenler, gerekçesiyle
## Doğrulama      — 🔴 NASIL doğrulandı (çıktı/ölçüm)
## Açık kalanlar  — bir sonraki tura devredenler
```
