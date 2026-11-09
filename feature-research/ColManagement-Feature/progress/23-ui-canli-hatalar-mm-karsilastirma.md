# 23 — ColManagement.UI Canlı Hataları: MM.UI ile Karşılaştırılıp Düzeltildi

**Tarih:** 2026-10-15 · **Faz:** 11 (UI ekranları, devam) · **Çıktı:** `Treasy.ColManagement.UI` kod düzeltmeleri

## Yöntem

Kullanıcı `Treasy.ColManagement.UI`'yi ayağa kaldırıp tarayıcıdan gerçek ekranlara girdi, 3 ayrı
canlı hata bildirdi. Kullanıcının standing talimatı: *"ColManagement.UI projesi MM.UI projesi ile
aynı olacak sadece modüller farklı"* — her hatada MM.UI'nin aynı konumdaki dosyası referans alındı
(decompile gerektiren paket tiplerinde `.nuget/packages` altındaki DLL'ler `grep -a` ile string
taraması yapılarak incelendi, ör. `IMakerCheckerEntityWithStateName`'in hangi pakette tanımlı
olduğu ve hangi property'leri istediği böyle bulundu).

## Değişiklikler

### A) `http://localhost:5105/` → 404 (login sonrası ana sayfa yok)
MM.UI'de kök route `DashboardController`/`Views/Dashboard/` üzerinden çözülüyor (Shell/
SharedDependency'nin varsayılan route'u `Dashboard` bekliyor). ColManagement.UI'de bunun yerine
`HomeController`/`Views/Home/` vardı — view içeriği zaten `"dashboard-pageTitle"` localization
key'ini kullanıyordu (isimlendirme hatası, içerik niyeti zaten "Dashboard"muş). `HomeController`
→ `DashboardController`, `Views/Home/` → `Views/Dashboard/` olarak MM.UI ile birebir eşlendi.

### B) Annex / CollateralDefinition / TxnTransaction Index ekranları çöküyordu
```
System.ArgumentException: XxxSelectModel type should be derived from IMakerCheckerEntityWithStateName.
  at Treasy.Pure.DevExtreme...TrexColumnsWithMakerChecker[T]
```
MM.UI'de DevExtreme grid'i bu generic constraint'i karşılamak için SelectModel'ler iki örüntüden
birini kullanıyor:
- **MakerChecker (Flow olmayan) ekran** → `: TrexMakerCheckerListItem` (`Treasy.Pure.Client.Models.BaseModels`) — emsal: `ProductDefinitionSelectModel`. Bu base `StateId`/`StateMaker`/`StateDate`/`StateName`'i zaten veriyor.
- **Flow tabanlı ekran** → `: FlowItem` (`Netix.Core.Flow.Model.DomainModel`) — emsal: `InterbankLoanBaseModel`. Bu base `Id`/`StateId`/`StateMaker`/`StateDate`/`StateName`/`FlowId`/`LastActionId`/`PreviousActionId`/`CreatedBy`/`CreatedDate`'i veriyor.

ColManagement'in 3 SelectModel'i de **düz class**'tı, hiçbir base/interface yok, `StateName` hiç
yoktu. Backend tipine göre ayrıldı:
- `AnnexSelectModel`, `CollateralDefinitionSelectModel` → `TrexMakerCheckerListItem` (backend
  `AnnexEntity`/`CollateralDefinitionEntity` düz `MakerCheckerEntity`, Flow değil).
- `TxnTransactionSelectModel` → `FlowItem` (backend `TxnTransactionEntity : FlowEntity`).

Her üçünde de artık base'den gelen `StateId`/`StateMaker`/`StateDate` (+ TxnTransaction'da `Id`)
kendi tekrar tanımları kaldırıldı. Paket referansı eklemeye gerek kalmadı — ikisi de
`Treasy.Pure.Components`/`Netix.Core.Flow.StateEngine` üzerinden zaten transitif olarak geliyordu
(MM.UI.Core'un referans listesiyle birebir aynı doğrulandı).

### C) `/health` "beyaz ekran" — GERÇEK HATA DEĞİL
`curl -D -` ile 5061/5062/5063 `/health` test edildi: üçü de birebir `200 OK, Content-Length: 0`.
Boş gövdeli 200 zaten `HealthController`'ın tasarımı — tarayıcıda "beyaz ekran" olarak görünmesi
beklenen davranış. Kullanıcının 5061'de farklı gördüğü şey muhtemelen tarayıcı/tab kalıntısıydı.

### D) DB script'lerinde 2 canlı çalıştırma hatası (kullanıcı gerçek DB'ye karşı koşturdu)
- **Script 3 (Menü):** `FrameworkMenu.MenuType` **int değil**, `FrameworkMenuType`'a FK'li bir
  **string**. Script `1`/`2` yazmıştı → `FK_FrameworkMenu_FrameworkMenuType_MenuType` ihlali,
  4 satır da eklenemedi (INSERT başarısız olsa da sonraki `PRINT` yine de çalıştığı için
  "oluşturuldu" mesajı yanıltıcı çıktı — doğrulama SELECT'i "0 rows" dedi). Canlı DB'den gerçek
  değerler okundu: grup/kök düğüm → `'None'`, ekrana giden yaprak düğüm → `'ControllerAction'`
  (MM'in `TreasuryKey`/`MoneyMarketKey` emsali). 4 INSERT düzeltildi.
- **Script 6 (defJobCron):** Bu oturumun kendi önceki düzeltmesinin yan etkisi — `defJobCron.Id`
  IDENTITY yapılmıştı (MM karşılaştırmasında, bkz. `progress/22`) ama seed script'i hâlâ elle
  `Id=1/2` basıyordu → `IDENTITY_INSERT OFF` hatası. `Id` INSERT'ten çıkarıldı, IDENTITY
  üretsin (kod zaten `[Key]`'e göre arıyor).
İkisi de idempotent, hiçbir satır gerçekte oluşmadığı için **aynen tekrar çalıştırılabilir**.

## Kararlar

- **SelectModel base sınıfı seçim kuralı netleşti** (ileride yeni ekran eklenirken kullanılacak):
  backend entity `FlowEntity`'den türüyorsa UI SelectModel `FlowItem`'dan türer; düz
  `MakerCheckerEntity`'den türüyorsa `TrexMakerCheckerListItem`'dan türer. Asla sıfırdan
  `StateId`/`StateMaker`/`StateDate` alanı elle yazılmaz.
- Decompile edilmiş paket tipleri (`IMakerCheckerEntityWithStateName`, `FlowItem`) için kaynak yok
  — `~/.nuget/packages/<paket>/<versiyon>/lib/net10.0/*.dll` üzerinde `grep -a -o` ile metadata
  string taraması yapmak, PowerShell `Assembly.LoadFrom` (net10 assembly, .NET Framework 5.1'den
  yüklenemiyor) denemesinden daha güvenilir çıktı.

## Doğrulama

`dotnet build Treasy.ColManagement.UI.Web.csproj`: **0 hata** (Razor view derlemesi dahil —
`Index.cshtml`'lerin `TrexColumnsWithMakerChecker<T>` çağrıları yeni base class'larla tip uyumlu).
Docker image rebuild edildi, container sağlıklı başladı, crash yok. Tarayıcıda login sonrası
ekranlar **kullanıcı tarafından doğrulanacak** (bu session'da auth gerektirdiği için curl ile
tam doğrulanamadı).

## Açık kalanlar

- Annex/CollateralDefinition/TxnTransaction Index ekranlarının gerçek tarayıcı testi kullanıcıda.
- Script 3 ve script 6 kullanıcı tarafından yeniden çalıştırılacak.
- İleride History/Preview gibi başka MakerChecker-tabanlı grid eklenirse aynı base-class kuralı
  (bu dosyanın "Kararlar" bölümü) uygulanmalı.
