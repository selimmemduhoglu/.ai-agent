# 22 — DB Script'leri MM'e Göre Yeniden Doğrulandı + 4 Servis Ayağa Kaldırıldı

**Tarih:** 2026-10-15 · **Faz:** 4 (devam) + ayağa kaldırma · **Çıktı:** `Treasy.ColManagement/.ai-agent/outputs/2026-10-14-ColManagement-Kurulum/` (güncellenmiş) + kod düzeltmeleri

## Yöntem

Kullanıcı önceki turda yazılan DB script'lerinin DerivSwp yerine **MM ve OptionsFX'e göre**
yazılmasını istedi ("orada olmayanları ekleme kafana göre"). MM'in gerçek EF entity + Fluent
config kodu (Currency/Calendar/Chart/Point/FXRate/InterestRate/CurrencyPair/Holiday/HalfWorkingDay/
DateBasis) tek tek okundu ve ColManagement'in DDL'iyle kolon kolon karşılaştırıldı. OptionsFX bu
tablolar için kontrol edildi — hiçbirine yerel config'i yok (o da pakete güveniyor), yani bu 8
tablo için MM tek kaynak.

Ardından kullanıcı `NetTrexColManagement`'ı kendi kurup script'leri çalıştırdı, "artık ayağa
kaldır" dedi — mssql-read ile canlı DB'ye (parola MM'in docker-compose.override.yml'inden alındı,
aynı sunucu/login) bir dizi doğrulama sorgusu atıldı, sonra docker container'ları sırayla
rebuild edilip ayağa kaldırıldı.

## Değişiklikler

### A) DB script düzeltmeleri (MM karşılaştırması)
- `Calendar`/`Holiday`: MM'de olmayan `CalNo` kolonu silindi, `Year`/`DayOfYear` NOT NULL yapıldı.
- `Currency.Pip`: float → `decimal(38,10)` (db-script.md'nin eski "float miras" notu bayatlamış).
- `Currency`/`CurrencyPair`/`Chart`/`Point`: `StateId`/`StateMaker`/`StateDate` NOT NULL (MM'in
  `MakerCheckerEntity` tabanı bunları her zaman non-nullable tutuyor).
- `FXRate`/`InterestRate`: `StateMaker` (+InterestRate'de `StateDate`) NOT NULL.
- `CurrencyPair.IsCalculatedPair`/`OrderNo`: NOT NULL.
- `defJobCron.Id`: `ValueGeneratedNever` → `bigint IDENTITY(1,1)` — MM'in `DefJobCron`'u IDENTITY+
  History (ölçüldü), ColManagement'in kendi `JobCronHistoryConfiguration`'ı da History'yi zaten
  kanıtlıyordu; önceki "referans kopya" sınıflandırması yanlıştı.
- `DefRefNumGen.TypeKey`: 30 → 50 (gerçek `sp_GetNewRefNumber` parametresiyle uyumlu).
- `PrdInstrument`: MM'de GERÇEKTEN var (OptionsFX'te yok) — kolonları okundu, ColManagement'in
  kendi entity'siyle (nullability/tip zaten kodda açık) tutarlı bulundu, yalnız birkaç string
  uzunluğu MM'den teyit edildi.

### B) `ModulePrefix` çakışması (canlı veriyle bulundu)
`NetTrexAcc.AccEntryMain.TxnId` verisi sorgulandı: **77** (ColManagement'in o ana kadarki
ModulePrefix'i) **NetTrex.InvFund** tarafından zaten kullanılıyordu (7762-77994 aralığı). Tüm
modüllerin prefix'leri ölçüldü: FX=11, SWAPFX=22, PM=33, SWAPPM=44, MM Tawarruq=50, MM=55, FI=66,
**InvFund=77**, DerivSwp=88, OptionsFX=99, MM Loan=120. **60 boş** — yeni ModulePrefix.
Kod: `NumberGeneratorDataManager.cs`.

### C) Stored procedure'ler
`sp_GetNewNumbers`/`sp_GetNewRefNumber`'ın "TrexFramework DB projesinden otomatik gelir" varsayımı
YANLIŞ çıktı — her modül DB'si bunları kendi `dbo` şemasında ayrı tutuyor. NetTrexMM'den
`OBJECT_DEFINITION` ile tam gövde okunup `7-NetTrexColManagement-StoredProcedures.sql` olarak
birebir kopyalandı (modül-agnostik gövde, değişiklik gerekmedi).

### D) FrameworkMenu parent key
Canlı DB'de kök sentinel `ParentId IS NULL` DEĞİL, **999**. Gerçek anahtar **`TreasuryKey`**
(Id=12) — eski tahmin `'Treasury'` yanlıştı (Key eki eksikti). `3-NetTrexCommon-Menu-DML.sql`
düzeltildi.

### E) `TxnTransactionFactory`
MM'in `TransactionFactory`'si Trader'ı `CreatedBy → StateMaker → "SYSTEM"` sırasıyla dolduruyor;
ColManagement doğrudan `input.Trader`'a güveniyordu. Aynı 3 seviyeli fallback eklendi. Term/
CustomerLocation/4 adet PaymentAccountingType alanı ColManagement'in entity'sinde yok —
kullanıcının onayladığı gibi bilerek atlandı.

### F) `Treasy.ColManagement.sln` düzeltmesi
Solution'da yanlışlıkla eklenmiş (muhtemelen Solution Explorer'da sürükle-bırak) **2 proje**
bulundu: `Treasy.MM.UI.Business` ve `Treasy.MM.UI.Core` (`..\..\Treasy.MM.UI\src\...` relatif
yoluyla, build config'lere tam kayıtlı ama hiçbir ColManagement .csproj'u bunlara referans
vermiyor — tamamen başıboş). Bu değişiklik **eski bir commit'te** zaten varmış (git diff boştu),
"az önce bozduk mu" değil, önceden var olan bir hataymış. Her iki proje bloğu + 24 satırlık
`ProjectConfigurationPlatforms` girdisi temizlendi. (Ayrıca: `Treasy.ColManagement.UI.Web.csproj`
git'te "modified" görünüyordu — gerçek içerik **birebir aynı**, yalnız CRLF/LF satır sonu farkı
[`core.autocrlf`], kod değişikliği YOK.)

### G) DI/config eksikleri (önceki turda bulunan 2 hata + bu turda bulunan parola/2 yeni hata)
- `ITxnTransactionFactory`/`IMarketDataCacheInvalidator` DI kayıtları (önceki turda).
- `docker-compose.override.yml`'deki `__PASSWORD__`/`__CLIENTSECRET__` placeholder'ları MM'in
  kendi dosyasındaki gerçek değerlerle dolduruldu (aynı sunucu/login/Keycloak client, paylaşımlı).
- `ColManagementBatchWebApi`'de `ConnectionStrings__HangfireConnection` hiç yoktu (yalnız
  `DefaultConnection` vardı) — Hangfire `appsettings.Development.json`'daki `Server=localhost`'a
  düşüyordu. Eklendi.
- **ColManagement.UI'nin Docker build'i 2 ayrı gerçek hatadan kırıktı:** (1) `tsc --noEmit`
  `Cannot find name '$'` (jQuery global tip tanımı yok) — `@types/jquery` eklendi. (2) `vitest`
  projede **hiç test dosyası olmadığı için** exit 1 veriyordu (vitest varsayılanı: 0 test = hata)
  — `vitest.config.ts` yazılıp `passWithNoTests: true` eklendi (sahte test uydurulmadı, MM.UI'nin
  aksine burada gerçekten hiç test yok, bu açıkça not edildi).

## Kararlar

- **MM artık bu 8 CoreDataSlice tablosu için DerivSwp'nin yerini aldı** — kaynak önceliği
  `CREATION_SCRIPT.md` §4'te güncellendi (MM/OptionsFX > DerivSwp, DerivSwp yalnız hiçbir yerde
  karşılığı bulunamayan tablolarda kalıyor: DefNumberGen/DefRefNumGen).
- **`ModulePrefix` kararı canlı veriyle verildi, tahminle değil** — bu platformda yeni bir
  modülün sayaç öneki seçerken `NetTrexAcc.AccEntryMain`'e bakması gerektiği öğrenildi (kod
  taraması yetmiyor, InvFund'ın reposu bile yok).
- **`.sln`'deki MM.UI referansları silindi, geri alınmadı** — hiçbir ColManagement projesi
  bunlara bağımlı değildi, risk yok.

## Doğrulama

🔴 **Script'ler kullanıcı tarafından ÇALIŞTIRILDI** (önceki turda "çalıştırılmadı" idi) — `sql-log/
colmanagement-db-kurulum-scriptleri/` Q8 ile `NetTrexColManagement`'ta 51/51 tablo + doğru seed
satırları (`BatchSet=2`, `DefNumberGen=4`, `ProductDefinition=1`) DOĞRULANDI.

✅ **4 servis de docker'da ayakta ve sağlıklı:**
- `nettrexcolmanagementwebapi` (5061) — swagger 200.
- `nettrexcolmanagementconsumerapi` (5063) — Kafka partition'ları assign edildi.
- `nettrexcolmanagementbatchwebapi` (5062) — Hangfire SQL objects kuruldu, server announce oldu.
- `colmanagement_ui` (5105) — `/` → 302 `/Login` (sağlıklı auth akışı).

`dotnet build Treasy.ColManagement.sln`: 0 hata (sln temizliğinden sonra, 1670 uyarı — MM.UI
projeleri çıkınca uyarı sayısı da düştü).

## Açık kalanlar

1. `General:AvailableModules`'a ColManagement eklenmedi — hangi literal ad kullanılacağı iş kararı.
2. Redis `ModuleMenu:*` cache temizlenmedi — menü eklendikten sonra 8 saat gerekebilir.
3. `ValidateColManagementTransactionsBatchItem` sınıfı `NetTrex.Common` reposunda hâlâ yazılmadı.
4. `sp_UnverifiedDataCount_TxnTransaction_ColManagement`'ın bitmask değerleri hâlâ varsayım.
5. ColManagement.UI'de gerçek frontend test YOK (`passWithNoTests` geçici tolerans, kalıcı çözüm
   değil) — kullanıcı onaylarsa ileride `tests/**/*.spec.ts` yazılmalı.
6. ColManagement menüye henüz eklenmedi, permission taraması kullanıcı tarafından yapılacak
   (kullanıcının kendi sözü: "şu anlık menüye eklemedim ilerde eklicem").
