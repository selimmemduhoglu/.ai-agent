# 21 — DB Kurulum Script'leri (Faz 4) + Docker Compose Port Çakışması

**Tarih:** 2026-10-14 · **Faz:** 4 (DB kurulum script'leri) · **Çıktı:** `Treasy.ColManagement/.ai-agent/outputs/2026-10-14-ColManagement-Kurulum/` (10 dosya)

## Yöntem

- Docker compose hatası (ekran görüntüsü): `docker-compose.override.yml` + container logları okundu.
- DB script'leri için Excel v5 bu oturumdan önce silinmişti (git status: `D`) — **gerçek EF Core
  entity + Fluent config sınıfları** tek kaynak alındı. İki Explore agent'a paralel görev verildi:
  Accounting/Collateral/Transaction/Data.Core grubu + Common/Definitions/ProductDefinition grubu —
  her ikisi de entity + config dosyalarını **tam okuyup** kolon/tip/index/ilişki döküm çıkardı.
  Ardından `grep -rn "\.ToTable("` ile tüm 41 fiziksel tablo adı tek tek doğrulandı (agent raporundaki
  bazı tahminler — örn. `defJobCron` — bu şekilde teyit edildi).
- DerivSwp'nin kurulum script'i (`Scripts/Ornek_Deriv_Scripts_DDL/Kurulum Scriptleri/`) **biçim**
  için kaynak alındı; ColManagement'in EF entity'si olmayan 10 CoreDataSlice tablosu (`Currency`,
  `CurrencyPair`, `FXRate(Detail)`, `Calendar`, `Holiday`, `HalfWorkingDay`, `DateBasis`, `Chart`,
  `Point`, `InterestRate(Detail)`) + `DefNumberGen`/`DefRefNumGen` oradan **birebir** alındı (paket
  tabloları, kaynağı yok).
- `mssql-read` ile 4 soru doğrulanmaya çalışıldı (menü parent key, `AvailableModules` değeri,
  `sp_GetNewNumbers` kaynağı, `PrdInstrument`'ın belirsiz kolonları) — `192.168.10.211,1433`'e bu
  oturumdan erişilemedi (VPN kapalı), audit `.ai-agent/sql-log/colmanagement-db-kurulum-scriptleri/`.

## Değişiklikler

### A) Docker compose teşhisi (kod değişikliği yok)
VS hata ekranı: *"Can not find container for the service 'ColManagementWebApi'"* + log'da
*"Bind for 0.0.0.0:5063 failed: port is already allocated"* + orphan container uyarısı
(`nettrexcolmanagementkafkaapi`). Teşhis: 5063 **ColManagementConsumerApi**'nin portu
(`docker-compose.override.yml:47`); `docker ps -a` ile kontrol edilince o an **hiçbir**
ColManagement container'ı ayakta değildi — port çakışması **geçiciydi** (önceki crash'ten kalan
orphan, o sırada hâlâ 5063'ü tutuyordu). Çözüm kullanıcıya **anlatıldı**: `docker compose up
--remove-orphans` ile yeniden başlat; container'lar zaten temizlenmiş görünüyor.

### B) DB kurulum script seti (10 dosya, `.ai-agent/outputs/2026-10-14-ColManagement-Kurulum/`)
| Dosya | İçerik |
|---|---|
| `0-NetTrexColManagement_Create-...sql` | DB oluşturma, DerivSwp'den uyarlandı |
| `0-DOGRULAMA-NetTrexCommon.sql` | 4 salt-okunur sorgu (menü parent, AvailableModules, sayaç SP, PrdInstrument) |
| `1-NetTrexColManagement-DDL.sql` | **51 tablo** (A: platform altyapısı 13 · B: ortak referans kopyası 26 · C: ürün katalogu 1 · D: modül-özgü 10 · E: history+trigger 5 çift) |
| `2-NetTrexCommon-DML.sql` | CM Root portföy (TR/GCIB altına) · DailyCheck validation BatchItem · `DefCountMonitoring` + SP |
| `3-NetTrexCommon-Menu-DML.sql` | 4 `FrameworkMenu` satırı (kök + Annex/Definition/Transaction, route `cm/...`) |
| `4-NetTrexCommon-Parameter-DML.sql` | 8 güvenli varsayılan + Grup B (muhasebe/bildirim, iş kararı bekliyor, yorumda) |
| `5-NetTrexCommon-Permission-DML.sql` | **bilerek boş** — ColManagement saf Micro UI, `CustomAuthorize` hiç kullanılmıyor (grep ile doğrulandı) |
| `6-NetTrexColManagement-DML.sql` | `DefNumberGen` 4 satır · `BatchSet` 1/2 · `defJobCron` 2 satır · `ProductDefinition` yalnız CASH (K-54) |
| `9-CorrectObjectNames.sql` | Otomatik adlı nesne taraması (hepsi zaten açık adlı yazıldığı için doğrulama amaçlı) |
| `CREATION_SCRIPT.md` | 🔑 Kullanıcının istediği kalıcı metodoloji dosyası — amaç/yazma şekli/kaynak önceliği/8 açık nokta |

## Kararlar

- **Excel yerine gerçek kod kaynak alındı** — 2026-10-07 tarihli şema dosyası silinmiş, ama kod
  daha güncel ve kesin (Security rollback sonrası gerçek şemayı yansıtıyor, Excel yansıtmazdı).
- **Fiziksel FOREIGN KEY yazılmadı** — ev konvansiyonu ölçümüne (125 tabloda 14 FK, hepsi referans
  tablosuna) sadık kalındı; EF'in çok sayıdaki `HasOne/HasForeignKey`'i kavramsal kaldı.
- **Referans kopya tablolarının 9'unda EF config `.ValueGeneratedNever()` YAZMIYOR** (agent
  taramasıyla bulundu: `defCorporateType`, `defCorporateDetailType`, `cusCustomer`,
  `FloatingRateType`, `defJobCron`, `PrfPortfolio`, `PaymentInstructionType`, `ProductDefinition`,
  `PrdInstrument`) — DDL yine de ev konvansiyonuna göre (IDENTITY değil) yazıldı; EF config'teki bu
  eksiklik ayrı bir teknik borç olarak not edildi (kod yama yapılmadı, yalnız DB'de doğru fiziksel
  şema kuruldu).
- **FlowSet/FlowState/FlowTransition seed'i TAMAMEN ÇIKARILDI** — planlama dosyası
  (`faz-4-db-kurulum-scriptleri.md`) bunları modül DB'sinde bekliyordu; `FlowDataProvider.cs`
  okunduğunda bunların **NetTrexCommon'ın API'sinden** çekilip Redis'te cache'lendiği görüldü,
  modülde böyle bir tablo yok. Planlama varsayımı güncel koda göre **yanlış** çıktı.
- **ProductDefinition'a yalnız CASH (Id=1)** — K-54 (Security kapsam dışı) kararına sadık kalındı.
- **A-08/A-09/A-10 artık kod tarafından fiilen çözülmüş** — `ModulePrefix=77` kodda hardcoded,
  DB adı `docker-compose.override.yml`'de zaten `NetTrexColManagement`, modül kodu `CM` zaten
  kullanılıyor. Script'ler bu fiili değerleri aynen kullandı; `02-DURUM.md`'deki "⬜ onay bekliyor"
  işareti kaldırıldı (fiilen kullanılıyor olarak işaretlendi).

## Doğrulama

🔴 **Script'ler ÇALIŞTIRILMADI** (kural gereği) — yalnız yapısal sağlık kontrolü yapıldı:
- Her dosyada `BEGIN`/`END` sayısı **birebir eşit** (8 dosyada tek tek doğrulandı).
- `1-DDL.sql`'de 55 `CREATE TABLE` bloğu, 65 `GO`, placeholder (`<Tablo>` vb.) kalıntısı **sıfır**.
- `grep -rn "\.ToTable("` ile DDL'deki 41 EF-kaynaklı tablo adı kod ile **birebir** karşılaştırıldı.

⚠️ **Gerçek bir SQL Server'a karşı DENENMEDİ** (bu makineden DB'ye erişim yok) — ilk gerçek
koşumda sözdizimi hatası çıkma ihtimali sıfır değil, özellikle `EXEC('CREATE TRIGGER ...')`
sarmalı 5 trigger'da.

## Açık kalanlar (= `CREATION_SCRIPT.md` §6, 8 madde)

1. FrameworkMenu parent `MenuKey` — tahmin (`'Treasury'`), DB'ye erişilince doğrulanmalı.
2. `General:AvailableModules` — elle güncellenecek, script dokunmuyor.
3. `sp_GetNewNumbers`/`sp_GetNewRefNumber` kaynağı — TrexFramework DB projesinden geldiği varsayımı doğrulanmadı.
4. `PrdInstrument`'ın 11 belirsiz kolonu — DerivSwp'den alındı, OptionsFX ile karşılaştırılmadı.
5. `defJobCron` vb. 9 tablonun EF config'inde `.ValueGeneratedNever()` eksik — teknik borç.
6. `sp_UnverifiedDataCount_TxnTransaction_ColManagement`'ın bitmask değerleri (`Verified=2`/`Rejected=1`) varsayım.
7. `ValidateColManagementTransactionsBatchItem` sınıfı — NetTrex.Common reposunda **yazılması gereken cross-repo iş**.
8. `TxnTransactionHistory`/`ProductDefinitionHistory` — 01-KIMLIK'te planlı ama kodda henüz yok, DDL'e de eklenmedi.
