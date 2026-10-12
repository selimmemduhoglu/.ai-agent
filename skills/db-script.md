# Skill — db-script (SQL script üretimi — ev konvansiyonu)

**Ne zaman tetiklenir:** DB'ye **yazan** herhangi bir SQL üretmen gerektiğinde — yeni tablo/kolon,
framework parametresi, permission, menü satırı, SP/trigger, referans veri.
Tetikleyici: *script yaz · script hazırla · DDL · tablo oluştur · kolon ekle · parametre ekle ·
permission ekle · menü ekle · migration*

**Tür:** Script üretimi · **Kapsam:** cross-repo (SP'ler `NetTrexCommon`'da, tüm modüller kullanır)

---

## 🔴 MUTLAK KURALLAR

| # | Kural |
|---|---|
| 1 | **Script'i ASLA çalıştırma.** `<repo>/.ai-agent/outputs/`'a yaz, yolu bildir — **kullanıcı uygular** |
| 2 | **EF Core migration YOK.** Şema dışarıdan yönetiliyor; her şema değişikliği bu script'lerle gider |
| 3 | **Her script idempotent.** İkinci kez koşunca hata vermeyecek, mevcut veriyi ezmeyecek |
| 4 | **Her dalda `PRINT`** — hem yapıldı hem atlandı dalında. Uygulayan kişi ekrandan takip ediyor |
| 5 | **Parametre = SP ile.** Elle `INSERT INTO FrameworkParameter` **yazma** (§3) |
| 6 | Okuma gerekiyorsa [`mssql-read`](mssql-read.md) — yalnız `SELECT`, her sorgu `sql-log/`'a |
| 7 | Muhasebe (`AccEngine*`) script'i ise [`accounting-db-script`](accounting-db-script.md) **önce** gelir |

**Emsal script'ler:** `NetTrex.MM/.ai-agent/imports/Örnek_Scriptler/` — kullanıcının canlıda koşan
script'leri. Yeni bir yapı (SP çağrısı, tablo, trigger) yazacaksan **önce oradan emsalini bul**.

🔑 **Framework SP'lerinin KAYNAĞI REPODA:**
`NetTrex.Common/DB/TrexFramework/dbo/Stored Procedures/` (aynı kopya `NetTrex.Accounting` ve
`NetTrex.Fx` altında da var). Bir SP'nin ne yaptığından emin değilsen **DB'ye sormadan önce buraya bak**:

| SP | Repoda | Ne yapıyor |
|---|:---:|---|
`sp_FrameworkAddPermission` | ✅ | `FrameworkPermission`'a rol ekler (`IsEnabled = 1`) |
`sp_FrameworkAddPermissionAction` | ✅ | Role controller/action izni ekler |
`sp_FrameworkAddProfile` | ✅ | Profil + kullanıcı listesi |
`sp_FrameworkAddProfilePermission` | ✅ | Profile rol bağlar. ⚠️ Profil yoksa **sessizce `Profile NOT FOUND` basıp geçer**, hata vermez |
`sp_FrameworkAddParameter` | 🔴 **YOK** | Yalnız DB'de. Ölçümü §3'te — tekrar sorgulamaya gerek yok |

**Dördü de idempotent** (`IF NOT EXISTS` + `print '... EXISTS'`).

---

## 1. Dosya düzeni

Bir iş **birden fazla DB**'ye dokunuyorsa **DB başına ayrı dosya**, uygulama sırasına göre numaralı:

```text
.ai-agent/outputs/<YYYY-MM-DD>-<Is-Adi>/
├── 0-DOGRULAMA-<konu>.sql              ← SALT-OKUNUR. Migration DEĞİL. Uygulamadan ÖNCE koşulur
├── 1-NetTrexMM-<Konu>.sql              ← modül DB'si (tablo, kolon, trigger)
└── 2-NetTrexCommon-<Konu>.sql          ← framework DB'si (parametre, permission, menü)
```

Tek dosya yetiyorsa: `.ai-agent/outputs/<YYYY-MM-DD>-<DB>-<Konu>.sql`

**Neden ayrı `0-DOGRULAMA` dosyası:** uygulanacak script baştan sona koşabilmeli. `SELECT`'leri
migration'ın içine gömersen uygulayan kişi çıktıyı okumak için script'i durdurmak zorunda kalır.

🔴 **Değer uyduramadığın her alan `0-DOGRULAMA`'ya bir sorgu olarak girer** ve migration'daki
satırın yorumunda *"DOGRULAMA sorgusu N"* diye referanslanır. Uydurulmuş bir `PortfolioId`
derlenmez, patlamaz — **yanlış portföye işlem açar**.

---

## 2. Başlık bloğu (her dosyada)

```sql
/* ==================================================================================================
   <n> - <DB>  --  <Konu>
   --------------------------------------------------------------------------------------------------
   <1-3 satır: ne yapıyor, kim kullanıyor>

   Idempotent: tekrar kosulabilir, <ne olur>.
   MM'de EF Core migration altyapisi YOK; sema bu script ile yonetilir.

   Tasarim: <tasarım dokümanının yolu>
   ================================================================================================== */
```

⚠️ **Script gövdesinde Türkçe karakter kullanma** (`ı ş ğ ü ö ç`). Farklı collation/kod sayfasıyla
açılan bir SSMS penceresinde bozuk görünür. `PRINT`'lerde de ASCII yaz (`olusturuldu`, `atlandi`).
Emsal script'lerde her ikisi de var; **ASCII tercih edilir**.

---

## 3. Framework parametresi → **SP ile**

```sql
USE NetTrexCommon
GO

-- <OptionPath>:<OptionName> -- <ne ise yariyor>
exec [dbo].[sp_FrameworkAddParameter] '<OptionPath>','<OptionName>','<Value>';

GO
```

Kod tarafındaki sabit `"<OptionPath>:<OptionName>"` biçimindedir
(`FrameworkParameterConstants.cs`) — script'teki iki argüman **bu sabitin iki yarısıdır**.

**SP'nin ölçülmüş davranışı** (2026-08-26, `OBJECT_DEFINITION` ile okundu):

| Gerçek | Sonuç |
|---|---|
| `IF NOT EXISTS` ile sarılı, varsa `Parameter EXISTS` basıp geçiyor | ✅ **İdempotent** — tekrar koşulabilir |
| Mevcut değeri **EZMEZ** | 🔴 **Değer değiştirmek için script YETMEZ** — satır elle `UPDATE` edilir. Script'e bu notu yaz |
| `StateId in (22, 30)` (silinmiş) satırları exists kontrolüne **katmıyor** | Silinmiş parametre yeniden eklenebilir |
| İmza: `@OptionPath nvarchar(250)`, **`@OptionName nvarchar(50)`**, `@Value nvarchar(4000)` | 🔴 OptionName **50 karakter** — kolon 200 olsa da sınır SP'den |
| Boş `@Value` → `return`, satır **yazılmaz** | Boş değer gerekiyorsa SP kullanılamaz |
| Sabit yazdığı alanlar | `ApplicationName=''`, `EnvironmentName=''`, `ServerName=''`, `IsEncrypted=0`, `StateId=18`, `StateMaker='SYSTEM'` |
| Vermediği `NOT NULL` kolonların DEFAULT'u var | `CreatedBy (N'')`, `CreatedDate (getdate())`, `FlowId (0)`, `LastActionId (0)` |

Script sonuna **kontrol sorgusu** koy: `SELECT ... WHERE OptionPath = '<Path>' ORDER BY OptionName;`
ve kaç satır beklendiğini yaz.

🔑 **OptionPath tasarımı:** bir işin tüm parametreleri **tek `OptionPath` altında** toplanır
(`Eximbank` + `MM.IsEnabled`, `MM.AutoVerify`, …) → tek sorguyla hepsi görünür. Path'i alt alt
kırmak (`Eximbank.MM` / `Eximbank.Common`) işletmeyi zorlaştırır.

---

## 4. Permission → **SP ile** (yalnız `Trex.WebUI`)

```sql
USE NetTrexCommon
GO

-- Temel roller
EXEC sp_FrameworkAddPermission @PermissionName = '<Ekran>_Maker',     @ApplicationName = 'Trex.WebUI';
EXEC sp_FrameworkAddPermission @PermissionName = '<Ekran>_Checker',   @ApplicationName = 'Trex.WebUI';
EXEC sp_FrameworkAddPermission @PermissionName = '<Ekran>_Displayer', @ApplicationName = 'Trex.WebUI';

GO

-- DISPLAYER
exec sp_FrameworkAddPermissionAction '<Ekran>_Displayer', 'Trex.WebUI', '<Controller>/<Action>'
...
-- MAKER
exec sp_FrameworkAddPermissionAction '<Ekran>_Maker', 'Trex.WebUI', '<Controller>/Create'
...
-- CHECKER
exec sp_FrameworkAddPermissionAction '<Ekran>_Checker', 'Trex.WebUI', '<Controller>/Verify'
GO
```

Roller `-- DISPLAYER / -- MAKER / -- CHECKER` yorumlarıyla **gruplanır**, action'lar tek tek yazılır.

🔑 **`@ControlleractionList` virgülle ayrılmış liste kabul ediyor** — SP içinde `charindex(',')` ile
parçalıyor. Yani tek çağrıda birden çok action geçilebilir. Emsal script'ler yine de **satır başına
bir action** yazıyor: hangisinin eklendiği/atlandığı `PRINT`'te ayrı ayrı görünsün diye. **Bu deseni
koru.**

⚠️ SP argümanlardaki **tüm boşlukları siliyor** (`REPLACE(..., ' ', '')`) — permission adında boşluk
kullanma. Ayrıca iç değişken `VARCHAR(8000)`; çok uzun bir liste **sessizce kırpılır**.
Web.UI permission'ı **`ControllerAdı/ActionAdı`** olduğu için ekranın **her** action'ı listelenmeli;
biri atlanırsa o buton sessizce 403 alır.

🔴 **Modül API'si (`NetTrex.MM.Api` vb.) için permission satırı YAZILMAZ.** Bu mekanizma
`Trex.WebUI` controller/action'ları içindir; modül API koruması Netix global policy'sinden gelir.

---

## 5. DDL — tablo / kolon / index

**İskelet** (`GO` **TRY/CATCH içine giremez** — tek batch):

```sql
USE <DB>
GO

BEGIN TRY
    BEGIN TRANSACTION;

    -- ==============================================================================================
    -- 1. TABLO
    -- ==============================================================================================
    IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[<Tablo>]') AND type = N'U')
    BEGIN
        CREATE TABLE [dbo].[<Tablo>]
        (
            [Id]        int             IDENTITY(1,1)   NOT NULL,
            [Kolon]     nvarchar(100)                   NULL,   -- ne oldugu
            ...
            CONSTRAINT [PK_<Tablo>] PRIMARY KEY CLUSTERED ([Id] ASC)
        );
        PRINT '<Tablo> tablosu olusturuldu.';
    END
    ELSE
    BEGIN
        PRINT '<Tablo> tablosu zaten mevcut, atlandi.';
    END

    -- ==============================================================================================
    -- 2. INDEX
    -- ==============================================================================================
    IF NOT EXISTS (SELECT 1 FROM sys.indexes
                   WHERE object_id = OBJECT_ID(N'[dbo].[<Tablo>]') AND name = N'IX_<Tablo>_<Kolon>')
    BEGIN
        CREATE NONCLUSTERED INDEX [IX_<Tablo>_<Kolon>] ON [dbo].[<Tablo>] ([<Kolon>] ASC);
        PRINT 'IX_<Tablo>_<Kolon> eklendi.';
    END
    ELSE
    BEGIN
        PRINT 'IX_<Tablo>_<Kolon> zaten mevcut, atlandi.';
    END

    COMMIT TRANSACTION;
    PRINT 'MIGRATION BASARILI -- <Tablo>';

END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    PRINT '*** HATA -- Script geri alindi. ***';
    PRINT 'Hata No    : ' + CAST(ERROR_NUMBER() AS NVARCHAR(10));
    PRINT 'Hata Mesaji: ' + ERROR_MESSAGE();
    PRINT 'Satir No   : ' + CAST(ERROR_LINE() AS NVARCHAR(10));
    THROW;
END CATCH;
GO
```

**Kolon bloğu biçimi:** köşeli parantezli ad · **hizalı** tip · hizalı NULL/NOT NULL · satır sonunda
`-- ne oldugu` yorumu. Enum kolonlarında **değer listesi yorumda**
(`-- 0 Received / 1 Error / 2 Success`).

**Kolon ekleme** (`INFORMATION_SCHEMA` ile kontrol, `DF_` isimli constraint):

```sql
IF NOT EXISTS (
    SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_NAME = '<Tablo>' AND COLUMN_NAME = '<Kolon>'
)
BEGIN
    ALTER TABLE [dbo].[<Tablo>]
        ADD [<Kolon>] bit NOT NULL CONSTRAINT [DF_<Tablo>_<Kolon>] DEFAULT (0);
    PRINT '[<Tablo>] -- <Kolon> kolonu eklendi.';
END
ELSE
    PRINT '[<Tablo>] -- <Kolon> zaten mevcut, atlandi.';
```

⚠️ **Tip değiştiriyorsan** kontrole `AND DATA_TYPE = '<eski>'` ekle — yoksa ikinci koşuda tekrar
`ALTER` etmeye çalışır.

🔴 **Kolon eklerken History tablosunu ve trigger'ı UNUTMA** (§7).

### İsim konvansiyonu

| Nesne | Biçim |
|---|---|
Primary key | `PK_<Tablo>` |
Unique index/constraint | `UQ_<Tablo>_<İlkKolon>` — 🔑 composite olsa bile **yalnız ilk kolon** ada girer (ölçüldü: `UQ_FXRateDetail_FXRateId` 3 kolonluk) |
Non-unique index | `IX_<Tablo>_<Kolon>` |
Default constraint | `DF_<Tablo>_<Kolon>` |
Foreign key | `FK_<BağımlıTablo>_<HedefTablo>_<FkKolonu>` (EF default kalıbı; ölçüldü 14/14 uyuyor) |
Trigger | `<Tablo>Trigger` |

🔴 **İsimsiz `DEFAULT` yazma.** `ALTER TABLE … ADD <kolon> … DEFAULT (0)` dersen SQL Server
`DF__TxnTawarr__Exter__458AE82D` gibi bir ad üretir — MM'de bu hatadan **1 tane** var, kopyalama.

### 🔴 Ne YAZILMAZ (ölçüldü 2026-10-02, `NetTrexMM` 125 tablo)

| Nesne | Gerçek | Kural |
|---|---|---|
| **CHECK constraint** | `sys.check_constraints` = **0 satır** | **Yazma.** `Amount > 0`, `Status IN (…)` gibi kontroller FluentValidation/domain katmanında. Sapılacaksa ayrı karar + yeni isim kalıbı (`CK_<Tablo>_<Kural>`) gerekir |
| **Foreign key (işlem tabloları arası)** | 125 tabloda **14 FK**, hepsi referans/tanım tablosuna, hepsi `NO_ACTION`. `TxnMM`'in tek FK'sı `RolloverTypeId`. Son 2 yılın hiçbir script'inde `FOREIGN KEY` geçmiyor | İşlem/detay/history arası FK **yazma**. Yazılacaksa yalnız sabit referans tablosuna, `ON DELETE` **yazma** (NO_ACTION default). `CASCADE` ev deseninde yok |
| **Filtered / partial unique index** | 5 unique'in **hiçbiri** filtered değil | `WHERE … IS NOT NULL`'lu unique **emsalsiz**. Gerekirse ya bilinçli sapma, ya kolonu `NOT NULL DEFAULT('')` yapıp düz `UQ_` |
| **Yeni stored procedure** | 125 tabloya karşılık **9 SP** (2 sayaç + legacy entegrasyon/rapor) | Yeni tablo SP açmayı **gerektirmez**. İstisna: ekran rozetinde sayı gösterilecekse `sp_UnverifiedDataCount_<Ekran>` (§8) |
| **Yeni function** | 28 scalar + 1 TVF, hepsi 2020-2025 legacy finans kütüphanesi (`fn_Accrual`, `fd_LgDt`, `fn_ConvertCCY`…) | Yeni function **yazma**; mevcutları çağır |

### Varsayılan değer kalıpları (ölçüldü: 45 DF constraint)

| Kolon | Default |
|---|---|
`StateId` | `((18))` — framework "yeni/doğrulanmamış" |
`StateDate` / `CreatedDate` | `(getdate())` |
`StateMaker` | `('system')` |
bit bayrakları | `((0))` (açık olması gerekenlerde `((1))`) |
zorunlu `nvarchar` | `('')` — NULL yerine boş string |

---

## 6. `Id` — IDENTITY mi, `DefNumberGen` mi?

> ⚠️ **Düzeltildi 2026-10-02.** Bu bölümün eski hâli *"`Txn*` tablolarında `Id` IDENTITY değildir"*
> diyordu. Ölçüm bunun **hem eksik hem yanıltıcı** olduğunu gösterdi — kural ne "`Txn` öneki"ne ne de
> "ana entity"ye bağlı; **fiilen sayaç kullanan tabloların listesi sabit ve 2024-02'den beri
> büyümüyor**. Aşağıdaki §6.0 **önce okunur**, sonra eski anlatım (hâlâ geçerli olan kısmı) gelir.

### 🔑 6.0 — ÖNCE BUNU OKU: yeni tabloda varsayılan **IDENTITY** (ölçüldü 2026-10-02)

`sys.tables.create_date` ile bakınca desen **tarihsel**, güncel ev kuralı değil:

| Tablo | Oluşturma | `Id` | History |
|---|---|---|---|
| `DefJobCron` (+History) | 2020-08-28 | **IDENTITY int** | ✅ |
| `DefNotification` · `DefNotificationTemplate` | 2020-08-28 | **IDENTITY int** | ❌ |
| **`PrdProductDefinitionMarketMap`** | **2024-02-29** | **DefNumberGen** | ❌ |
| `PrdProductDefinition` (+History) | 2024-10-15 | DefNumberGen (**ölü**, §6.1) | ✅ |
| `TxnCashFlow` (+History) | 2026-04-09 | **IDENTITY** | ✅ |
| **`AmortizationConfiguration`** (+History) | **2026-04-21** | **IDENTITY `bigint`** | ✅ |

- 🔴 **2024-02'den sonra açılan HİÇBİR tablo `DefNumberGen` kullanmıyor.** 2026'da açılan iki tablonun
  ikisi de IDENTITY, ikincisi `bigint` IDENTITY (gotcha #14 ile uyumlu).
- 🔑 **Yeni tabloda varsayılan `bigint IDENTITY(1,1)`'dir.** Sayaç yalnız **açık bir gerekçe** varsa
  seçilir: (a) tek round-trip'te N adet Id topluca rezerve edilecekse, (b) Id'nin kendisinden ürün
  ayırt edilecekse (`55…` MM / `120…` Loan prefix'i), (c) mevcut bir sayaçlı ailenin kardeşi ise
  (ör. yeni bir `Txn<Ürün>` ana işlem tablosu).
- 🔑 **IDENTITY ile History BAĞIMSIZ** — ikisini birbirine bağlayan kural **yok**.
  `PrdProductDefinitionMarketMap`'te sayaç var History yok; `DefJobCron`/`AmortizationConfiguration`'da
  tam tersi. History kriteri ayrı ve §7'de.
- 🔴 **Referans veri kopyası tablolar bu tartışmanın DIŞINDA.** `CusCustomer`, `PrfPortfolio`,
  `Currency`, `Calendar`, `FXRate`… `Id`'leri IDENTITY değildir ama sayaç da kullanmazlar —
  **`NetTrexCommon`'ın Id'si birebir kopyalanır**. Bunlara ne IDENTITY ne `DefNumberGen` satırı
  verilir; EF'te `.ValueGeneratedNever()` yazılır. Tam envanter:
  `NetTrex.MM/.ai-agent/reference/db-mimarisi-tanim-islem-akisi.md` §30.

### 🔴 6.0.1 — EF config'te `Id` AÇIKÇA işaretlenir (yoksa insert sessizce patlar)

Script'i yazan kişi EF config'i de kontrol etmeli — ikisi tutarsızsa hata **runtime'da** çıkar:

| Fiziksel kolon | EF config'te yazılacak | Emsal |
|---|---|---|
| `IDENTITY(1,1)` | `builder.Property(x => x.Id).UseIdentityColumn().IsRequired();` | `TxnCashFlow`, `TxnNote`, `AmortizationConfiguration` |
| IDENTITY değil (sayaç / dış Id) | `builder.Property(x => x.Id).ValueGeneratedNever();` | `PortfolioConfiguration`, `MarketCustomerMapConfiguration` |

**Hiçbirini yazmamak tuzaktır:** EF convention'ı `int` PK'yı `ValueGeneratedOnAdd` sayar; entity'ye
Id `0` (CLR default) verilirse EF kolonu INSERT'ten **çıkarır** ve `OUTPUT INSERTED.Id` bekler —
kolon IDENTITY değilse insert patlar. Canlı emsal §6.1'de.

### 🔴 6.1 — Ölçülmüş canlı tuzak: `PrdProductDefinition` Create yolu

| Sayaç | `LastNumber` | Gerçek Id'ler | Durum |
|---|---:|---|---|
| `Product Definition Market Map Id` (6) | **1032** | `MAX(Id) = 1032` | ✅ canlı, birebir tutuyor |
| `Product Definition Id` (5) | **999** | `MIN=1 · MAX=11` | 🔴 **ÖLÜ** — hiç kullanılmamış |

`ProductDefinitionCreateHandler.cs:41,61-62` → **iki sayaç çağrısı da yoruma alınmış**, Id sabit `0`
veriliyor. `ProductDefinitionConfiguration.cs` / `ProductDefinitionMarketConfiguration.cs` ise `Id`
için ne `.UseIdentityColumn()` ne `.ValueGeneratedNever()` yazıyor (§6.0.1).
⚠️ **Çıkarım — kod seviyesi, runtime'da DENENMEDİ ("tahmin"):** bu ikisi birleşince ekrandan yeni
ürün tanımı **oluşturma yolu kırık**. Veri destekliyor (Create'ten gelmiş 1000+ Id'li satır yok) ama
kesin kanıt değil. Yeni bir tabloda **aynı hataya düşme**.

### 6.2 — Sayaç kullanılacaksa: enum + satır **ÇİFT** olarak gerekir

🔴 `DefNumberGen` satırı **tek başına yetmez**. Kod tarafında `EntityColumnType`
(`Code/Data/NetTrex.MM.Data.Core/Enums/EntityColumnType.cs`) enum'ına **aynı sayısal değerle** bir
üye eklenmeli. Ölçüldü: enum'daki 9 değerin 8'i (`None = 0` hariç) tablodaki 8 satırla **birebir**
eşleşiyor.

- `sp_GetNewNumbers` tanımsız `EntityColumnType` için **`RAISERROR`** atıyor → eksikse hata **ilk
  üretim denemesinde**, derleme zamanında **değil**.
- Enum değeri var ama DB satırı yoksa da aynı hata. **İkisi birlikte gider.**

---

### 6.3 — Sayaç seçildiyse: satır ekleme kalıbı (eski §6 anlatımı, hâlâ geçerli)

🔴 `DefNumberGen` kullanacak bir tablo açıyorsan sayaç satırı da eklenmeli:

```sql
IF NOT EXISTS (SELECT 1 FROM DefNumberGen WHERE Definition = '<Txn X Id>')
BEGIN
    DECLARE @NextType INT;
    SELECT @NextType = ISNULL(MAX(EntityColumnType), 0) + 1 FROM DefNumberGen;

    INSERT INTO DefNumberGen (EntityColumnType, LastNumber, Definition, LastUpdateDate)
    VALUES (@NextType, 1000, '<Txn X Id>', GETDATE());

    PRINT 'DefNumberGen kaydi eklendi. Type ID: ' + CAST(@NextType AS VARCHAR(10));
END
ELSE
    PRINT 'DefNumberGen kaydi zaten mevcut.';
```

**Log / append-only tablolar IDENTITY olur** ve `DefNumberGen` kaydı **istemez**. Ayrımı script
notlarında **açıkça yaz** — okuyan kişi "sayaç eklemeyi unuttun mu?" diye sormasın.

🔑 **Ölçülmüş gerçek (2026-10-02) — kural "`Txn` öneki" değil.** ⚠️ Bu satır daha önce *"kural ANA
ENTITY'dir"* diyordu; o da **yetersiz** çıktı — `PrdProductDefinitionMarketMap` ana entity değil ama
sayaç kullanıyor, `TxnCashFlow` düzenlenebilir ana alt kayıt ama IDENTITY. **Gerçek kural: aşağıdaki
8 satır sabit bir liste; 2024-02'den beri yenisi eklenmedi** (§6.0). `DefNumberGen`'de **8 satır** var,
tamamı:

| EntityColumnType | LastNumber | Definition |
|---:|---:|---|
1 | 3412 | `Txn Mm Id` |
2 | 6141 | `Acc Entry Main Id` |
3 | 12694 | `Account Entry` |
4 | 8174 | `Generated Account` |
5 | 999 | `Product Definition Id` |
6 | 1032 | `Product Definition Market Map Id` |
7 | 1052 | `Txn Tawarruq Id` |
8 | 1168 | `Txn Loan Id` |

- **`PrdProductDefinition` de sayaçtan** — yani ekrandan düzenlenen **tanım** tabloları da IDENTITY değil.
  ⚠️ Ama bu sayaç **ölü**: `LastNumber = 999` iken gerçek Id'ler `1..11` (§6.1). Yani satırın varlığı
  "bu desen kullanılıyor" demek **değil** — `LastNumber`'ı tablodaki `MAX(Id)` ile karşılaştır.
- Buna karşılık `TxnCashFlow`, `TxnDocument`, `TxnNote`, `TxnMMDetail`, `TxnMMTax`, `TxnState`, `TxnSync`
  **`Txn` önekli olmalarına rağmen IDENTITY** ve satırları **yok**.
- 🔑 **Alt/eşleme tablosu için tek sayaçlı emsal `PrdProductDefinitionMarketMap`** (2024-02) ve o
  emsal **tekrarlanmamış**. Ekrandan düzenlenen bir tanımın alt tablosunu açıyorsan (Add Product /
  Add Rule penceresinden girilen satırlar) **`bigint IDENTITY` seç** — güncel emsal
  `AmortizationConfiguration` (2026-04) ve `TxnCashFlow` (2026-04).
- **`Definition` formatı:** boşluklarla ayrılmış Title Case — PascalCase tablo adının kelimelere bölünmüş
  hali + `Id`. Dikkat: `'Txn Mm Id'` (MM değil **Mm**). Prefix bazen düşüyor (`Prd` → `'Product Definition Id'`),
  bazen kalıyor (`Txn`, `Acc`). Yeni satırda **mevcut emsale bak**.
- `LastNumber` başlangıcı emsalde **1000**, `EntityColumnType` `MAX+1` ile hesaplanır.

⚠️ **`DefRefNumGen` ile karıştırma:** `LogicalReference` üretimi ayrı tablo + ayrı SP
(`sp_GetNewRefNumber @TypeKey`, `TypeKey nvarchar` + `LastReference int`, satırlar günlük: `T250429|7`).
SP satır yoksa **kendisi oluşturuyor** → script'le önceden satır eklemeye **gerek yok**.

### 🔑 Üç modül karşılaştırması (ölçüldü 2026-10-07: MM · OPTFX · DerivSWP)

Önceki ölçüm yalnız MM'e bakıyordu ve "desen terk edilmiş" izlenimi veriyordu. **Üç DB birlikte
ölçülünce tablo değişti:** OPTFX ve DerivSWP sayacı **aktif** kullanıyor (DerivSWP'ninki 2026-10-06'da
güncellenmiş). Desen terk edilmemiş, **kapsamı dar**: 4 çekirdek satır.

| Ect | NetTrexMM (eski biçim) | NetTrexOPTFX / NetTrexDerivSWP (yeni biçim) |
|---|---|---|
1 | `Txn Mm Id` | **`Txn_Id`** |
2 | `Acc Entry Main Id` | **`AccEntryMain_Id`** |
3 | `Account Entry` | **`AccEntry_Id`** |
4 | `Generated Account` | **`AccEngineGeneratedAccountRule_Id`** |
5-8 | `Product Definition Id`, `Product Definition Market Map Id`, `Txn Tawarruq Id`, `Txn Loan Id` | — (modüle özgü, yok) |

🔑 **Yeni modülde alt tireli biçim kullanılır** (`Txn_Id`), MM'in boşluklu biçimi eski.
`EntityColumnType` enum'ı da OptionsFX'in nötr biçimiyle: `None=0 · TransactionId=1 ·
AccountingEntryMainId=2 · AccountingEntryId=3 · GeneratedAccountingEntryId=4` (MM'de `TransactionMM_Id`
gibi modül adı + `_Id` soneki var, **kopyalanmaz**).

**Sayaç alan / almayan — üç DB'de de aynı:**
| Sayaçtan (IDENTITY **değil**) | IDENTITY (sayaç satırı **açılmaz**) |
|---|---|
| Ana işlem tablosu (`TxnMM` / `TxnTransaction`) — **bigint** · `AccEntryMain` · `AccEntry` · `AccEngineGeneratedAccountRule` — **int** | `TxnNote` · `TxnDocument` · `TxnSync` · `TxnCashFlow` · `BatchLog` · `BatchLogDetail` · `DefJobCron` · tüm `*History` |

⚠️ **`ProductDefinition`'da ev geleneği YOK:** MM sayaçlı (kodu ölü) · OPTFX sayaçsız, elle · DerivSWP
IDENTITY. Üç modül üç çözüm — yeni modülde bu **karar verilmesi gereken** tek yer.

### 🔴 Sayaç önekinin `int` tavanı (hesaplandı, tahmin değil)

`NumberGeneratorDataService.GetNewNumbersWithPrefixAsync` üretilen numarayı önekle **birleştirip
`int.Parse` ediyor**: `int.Parse($"{prefix}{number}")`.

| Önek | Örnek | Tavan |
|---|---|---|
| iki haneli (MM `55`, OptionsFX `99`) | `55` + 7 hane | ~**9.999.999 kayıt** |
| üç haneli (MM Loan `120`) | `120` + 6 hane | ~**999.999 kayıt** |

Kolon `bigint` ama üretici `int` — tavan **koddan** geliyor. Yeni modülde önek seçerken **iki haneli**
seç; üç haneli önek canlıda milyonuncu kayıtta `OverflowException` demek.

---

## 7. History tablosu + trigger

🔴 **Kriter ölçüldü (2026-10-02) ve düzeltildi: "StateId varsa History" YANLIŞ.**
`StateId` **55 tabloda** var ama History yalnız **9**'unda. Gerçek kriter: **kullanıcının ekrandan
düzenlediği entity**.

| History VAR (9 tablo = 9 trigger, 1:1) | History YOK |
|---|---|
`TxnMM`, `TxnLoan`, `TxnTawarruq` (3 ana işlem — tek `FlowId`+`LastActionId` taşıyanlar) · `PrdProductDefinition` · `AmortizationConfiguration` · `DefJobCron` · `TxnCashFlow`, `TxnDocument`, `TxnNote` (düzenlenebilir alt kayıtlar) | Referans/enum tabloları (`Def*`, `Currency`, `Market`, `TaxType` — StateId'si olsa bile) · log/append-only (`TxnSync`, `BatchLog*`, `PaymentMessage`) · hesaplama çıktıları (`TxnMmDailyCalculation`, `LoanRevaluation`) · muhasebe (`AccEntry`, `AccEntryMain`) |

History tablosunun PK'sı **ayrı bir `HistoryId`** (IDENTITY); ana tablonun `Id`'si normal kolon olarak taşınır.

🔑 **History ile `Id` üretimi BİRBİRİNDEN BAĞIMSIZ** (ölçüldü 2026-10-02) — "sayaç varsa History olur"
diye bir kural **yok**: `PrdProductDefinitionMarketMap`'te sayaç var History **yok**;
`DefJobCron`/`AmortizationConfiguration` **IDENTITY** ama History **var**. İki kararı ayrı ver (§6.0).

🔑 **Tanım tablosunun ALT tablosu için** (Add Product / Add Rule penceresinden girilen satırlar):
satır **parasal/iş şartı** taşıyorsa (tutar, oran, haircut, tarih aralığı, limit) → **History VAR**
(emsal: `TxnCashFlow`, `AmortizationConfiguration`). Satır **saf eşleme** ise (yalnız iki FK + bir
`bit`/`Order`) → **History YOK** (emsal: `PrdProductDefinitionMarketMap`).

🔴 **Referans veri kopyası tablolarına History YAZILMAZ** — tarihçe `NetTrexCommon`'da duruyor
(`CustomerHistory`, `PortfolioHistory`…). MM'in 9 History tablosunun **hiçbiri** kopya değil.

Böyle bir entity `<Tablo>History` + `<Tablo>Trigger` ister:

```sql
CREATE OR ALTER TRIGGER [dbo].[<Tablo>Trigger]
ON [dbo].[<Tablo>]
FOR INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO [dbo].[<Tablo>History] SELECT * FROM inserted;
END
GO
```

🔴 **`CREATE TRIGGER` batch'in İLK satırı olmak zorunda.** `IF`/`TRY` içine koyacaksan `EXEC('...')`
ile sarmala — emsal: `9-NetTrexCommon-SwiftMessageFullScript.sql`. `CREATE OR ALTER` kullanabiliyorsan
kendi batch'inde bırak, sarmalamaya gerek kalmaz.

🔴 **Yeni trigger'ı AÇIK KOLON LİSTESİYLE yaz.** MM'de iki kuşak var:
- Eski (`PrdProductDefinitionTrigger`): `INSERT INTO …History SELECT * FROM inserted;` — `BEGIN/END` ve
  `SET NOCOUNT ON` bile yok. **Kopyalama.**
- Doğru (`TxnMMTrigger`): `SET NOCOUNT ON;` + `INSERT INTO [dbo].[TxnMMHistory] ([AccountNumber],[BasisCode],…)
  SELECT [AccountNumber],[BasisCode],… FROM inserted;`

`SELECT *` kolon **sırasına** bağımlıdır; ana tabloya kolon eklendiğinde History'ye de **aynı sırada**
eklenmezse trigger sessizce yanlış kolona yazar.

**Log/append-only tablo History istemez** — gerekçesini script notuna yaz.

## 8. Diğer hazır kalıplar

**Menü satırı** (`FrameworkMenu`, `NetTrexCommon`) — `MenuKey` ile `IF NOT EXISTS`, tüm kolonlar
açık: `ApplicationName, Description, MenuKey, MenuType, Value, ForcedUrl, ForcedPermission, Icon,
IsActive, ItemOrderId, ParentId, StateDate, StateId (18), StateMaker ('system')`.
🔴 **Satır eklemek yetmez** — menü Redis'te `ModuleMenu:{UserId}` altında **8 saat** cache'li.
Script'e *"Redis `ModuleMenu:*` temizlenmeli"* notunu yaz.

**Sayım ekranı** (`DefCountMonitoring` + `sp_UnverifiedDataCount_<Ekran>`) — emsal:
`7-NetTrexMM-Tawarruq-Report-UnverifiedRecords_sp (1).sql`.

🔴 **İkisi de `NetTrexCommon`'da durur** (modül DB'sinde değil) ama SP **cross-database** sorgular:
`FROM NetTrexMM.dbo.TxnTawarruq tw WITH (NOLOCK)`. Ölçüldü: Common'da **30 SP + 30 DefCountMonitoring
satırı**, birebir eşleşiyor.

🔑 **Tablo başına değil, EKRAN başına bir çift.** 20 tablolu bir modül 20 SP istemez; maker-checker
ekranı sayısı kadar ister.

```sql
-- DefCountMonitoring satırı (Id IDENTITY DEĞİL, MAX(Id)+1)
Id | ScreenName nvarchar(100)      | Query                                            | ScreenUrl                   | Connection   | DefaultUnverifiedStateId | State
19 | 'Tawarruq Transactions'       | 'EXEC sp_UnverifiedDataCount_txnTawarruq @CurrentUserId' | 'general/Tawarruq/Index' | 'Connection' | '3' (nvarchar)           | 1
```
`Connection` literal `'Connection'` · `DefaultUnverifiedStateId` literal `'3'` · `State = 0` satırı kapatır.

SP `IF OBJECT_ID(...) IS NULL` + `EXEC('CREATE PROCEDURE …')` ile kurulur (GO sorunu); içinde `''` ile
kaçırılmış tek tırnaklar var. Gövdenin iki kritik parçası:
`SELECT @HavePermission = dbo.fn_HasPermissionWithUserId(@CurrentUserId, '<Ekran>\_%')` ve
doğrulanmamış tanımı **bitmask** ile: `WHERE (StateId & 2) <> 2 AND (StateId & 1) <> 1`. Yetki yoksa `-1` döner.

**Referans/enum satırı** (`defXxx`) — `IF NOT EXISTS ... WHERE Id = <n>`. Kolon listesini
**önce doğrula**, tahmin etme.

---

## Gotcha'lar

| 🔴 | Tuzak |
|---|---|
| 1 | **`GO`, `TRY/CATCH` içine giremez.** Transaction'la sarılı her şey **tek batch** olmalı |
| 2 | **`CREATE TRIGGER` / `CREATE PROCEDURE` batch'in ilk satırı olmalı** → `EXEC('...')` ile sarmala |
| 3 | **`sp_FrameworkAddParameter` mevcut değeri EZMEZ** — değer güncellemek için script yetmez, elle `UPDATE` |
| 4 | **`@OptionName` sınırı 50 karakter** (kolon 200 olsa da) |
| 5 | **Boş `@Value` yazılamaz** — SP `return` ediyor |
| 6 | ⚠️ **Düzeltildi 2026-10-02:** eskiden *"`Txn*` tablosunda `Id` IDENTITY değil, `DefNumberGen` şart"* yazıyordu. Doğrusu: sayaç kullanan tablolar **sabit 8'lik bir liste**, 2024-02'den beri yenisi yok; **yeni tabloda varsayılan `bigint IDENTITY`** (§6.0). Mevcut sayaçlı bir aileye kardeş ekliyorsan sayaç şart, yoksa **PK çakışması** |
| 7 | **Menü satırı Redis cache'i invalidate etmiyor** — 8 saat eski menü görünür |
| 8 | **Kolon tipi değiştiren kontrole `DATA_TYPE` ekle**, yoksa ikinci koşuda tekrar `ALTER` dener |
| 9 | **`defExternalReferenceSource` gibi referans tablosunda satır yoksa**, ona required navigation'la bağlı kayıtlar listede **sessizce görünmez** (INNER JOIN) — kaynak Id ekliyorsan referans satırını da ekle |
| 10 | ~50 `NetTrexAcc_*` DB varyantı var — muhasebe script'inde `USE [...]` satırını **doğrula**, canlı adı yazma |
| 11 | **Türkçe karakter** kullanma; collation farkında bozuk görünür |
| 12 | **`sp_FrameworkAddProfilePermission` profil yoksa hata VERMEZ** — `Profile NOT FOUND` basıp geçer. Profil satırını **önce** ekle, `PRINT` çıktısını oku |
| 13 | Permission SP'leri argümanlardaki **tüm boşlukları siliyor**; iç değişken `VARCHAR(8000)` → uzun action listesi **sessizce kırpılır** |
| 14 | 🔴 **Yeni tabloda PK `bigint` olacak** (ofis kuralı, 2026-10-02). Eski tablolar `int` ama migrasyon bigint yönünde — emsal: `Örnek_Scriptler/4-NetTrexMM-TxnMmDailyCalculation-TxnMmId-long.sql`. Eski bir tabloyu emsal alıp `int` yazma |
| 15 | 🔴 **`float`/`double`/`real` finansal hiçbir kolonda kullanılmaz** — yalnız `decimal`. Para/fiyat/nominal/FX kuru `decimal(38,10)` · oran-yüzde-haircut (0..1) `decimal(18,10)`. ⚠️ Bu dosyanın eski sürümlerinde ve `PROJECT_CONTEXT.md`'de geçen "para `(38,2)`" bilgisi **yanlış** — fiziksel DB'de `(38,2)` hiç yok, yalnız bir EF config satırında var |
| 16 | **`sp_UnverifiedDataCount_*` ve `DefCountMonitoring` modül DB'sinde değil `NetTrexCommon`'da** — yanlış DB'ye yazarsan ekran rozeti sessizce boş kalır |
| 19 | 🔴 **`*History` tablosunda IDENTITY `Id`'de DEĞİL `HistoryId`'de.** Üç DB'de istisnasız: `HistoryId` IDENTITY, `Id` kaynak satırın Id'sini **taşır**. "Tabloda IDENTITY kolonu var" ≠ "`Id` IDENTITY" — `sys.columns.is_identity` ile tablo bazlı bakarsan yanlış sonuç çıkarırsın |
| 20 | 🔴 **Önek + sayaç `int.Parse` ediliyor** (`GetNewNumbersWithPrefixAsync`). İki haneli önekle tavan ~9.999.999, üç haneli önekle ~999.999 kayıt. Kolon `bigint` olması seni kurtarmaz — tavan koddan geliyor (bkz §6) |
| 21 | **Muhasebe KURAL tabloları modül DB'sinde YOK.** `AccAccountMap`, `AccEngineEvent`, `AccEngineComponent`, `AccountRule`, `AccEngineDynamicMap` → ayrı `NetTrexAcc_*` DB'lerinde (sunucuda 50+ kopya). Modül DB'si yalnız **kesilmiş fişi** tutar: `AccEntryMain` · `AccEntry` · `AccEngineGeneratedAccountRule`. Yanlış DB'ye `USE` yazmak sessiz başarısızlık üretir |
| 22 | **Hangfire `dbo`da değil `Hangfire` şemasında** (büyük H küçük f), 11 tablo, üç DB'de de aynı set |
| 17 | 🔴 **EF config'te `Id` işaretlenmezse insert patlar** (ölçüldü 2026-10-02). EF convention'ı `int` PK'yı `ValueGeneratedOnAdd` sayar → Id `0` verilince kolonu INSERT'ten **çıkarır** ve `OUTPUT INSERTED.Id` bekler; kolon IDENTITY değilse hata. Script'le birlikte EF config'i de kontrol et: IDENTITY ise `.UseIdentityColumn()`, sayaç/dış Id ise `.ValueGeneratedNever()` — **açıkça yaz**. Canlı emsal: `ProductDefinitionConfiguration`/`ProductDefinitionMarketConfiguration` ikisinde de **hiçbiri yok**, `ProductDefinitionCreateHandler` Id `0` veriyor → Create yolu kırık (§6.1) |
| 18 | 🔴 **Referans veri kopyası tablosuna IDENTITY de `DefNumberGen` de verme** — `CusCustomer`/`PrfPortfolio`/`Currency`/`Calendar`/`FXRate`… `NetTrexCommon`'ın Id'sini birebir taşır (`.ValueGeneratedNever()`), History'si **yoktur** (tarihçe Common'da). Yeni modül DB'si kurarken açılacak kopya listesi: `reference/db-mimarisi-tanim-islem-akisi.md` §30 |
| 20 | 🔴 **Bir `FOR INSERT,UPDATE` trigger'ı olan tabloyu TOPLU `UPDATE` ile backfill etmek, trigger KAPATILMADAN yapılırsa her satır için SAHTE bir history satırı üretir (ölçüldü 2026-10-06).** Trigger hangi kolonun değiştiğine bakmaz — `UPDATE dbo.TxnMM SET YeniKolon = … WHERE YeniKolon IS NULL` gibi bütün tabloyu tek seferde dolduran bir backfill, her satır için trigger'ı tetikler ve `txnMMHistory`'ye GERÇEK bir durum değişikliği olmadan bir satır daha yazar. Kanıt: dev'de 675 satırlık backfill → `txnMMHistory`'ye **677 fazladan** satır (HistoryId yeni, ama `StateDate`/`CreatedDate` aylar öncesine ait — trigger `inserted`'tan olduğu gibi kopyalıyor). PROD'da binlerce satırlık tabloda bu, History'yi sessizce şişirir. **Çözüm:** backfill'den hemen önce `DISABLE TRIGGER [dbo].[X] ON tablo;`, backfill'den sonra trigger zaten `CREATE OR ALTER` ile yeniden yaratılıyorsa otomatik enabled döner (ayrıca `ENABLE TRIGGER` yazmaya gerek yok). **Ek önlem:** canlıda bu adım çalışırken trigger kısa süreliğine kapalı olacağı için backfill'i **uygulamanın o tabloya yazmadığı bir bakım penceresinde** çalıştır — aksi halde o pencerede gelen gerçek bir INSERT/UPDATE'in history satırı sessizce kaybolur. |
| 21 | 🔴 **Aynı batch'te `ALTER TABLE ADD <kolon>` + o kolonu kullanan DML = `Invalid column name` (ölçüldü 2026-10-06).** SQL Server bir batch'i (GO'ya kadar olan blok) **çalıştırmadan önce tek seferde derliyor/bind ediyor** — `ALTER TABLE dbo.X ADD Y int NULL;` sonra AYNI BATCH'TE `UPDATE dbo.X SET Y = …` yazarsan, derleyici `Y`'yi batch'in **başındaki** (henüz eklenmemiş) haliyle arar; `ALTER TABLE`'ın kendisi çalışacak olsa bile fark etmez. Belirti: `Msg 207, Invalid column name` — hem backfill/`ALTER COLUMN NOT NULL` satırında hem (varsa) trigger içinde. **Çözüm:** kolon ekleme ile onu kullanan her adımı (backfill, NOT NULL, trigger) **ayrı `GO` batch'lerine böl** — her batch bir öncekinin DDL'ini görür. `TRY/CATCH` tek batch'le sınırlı olduğu (GO'yu geçemez) için atomikliği `BEGIN TRY` yerine `SET XACT_ABORT ON; BEGIN TRANSACTION;` ile sağla — bu ikisi GO sınırlarını geçer, aynı oturumda kalındığı sürece transaction açık kalır ve hangi batch'te olursa olsun bir hata çıkarsa **tamamı** geri alınır. Emsal: `linked-transaction-development/1-NetTrexMM-LinkedTransaction.sql` — ilk sürüm tek TRY/CATCH batch'inde yazılmıştı, backfill satırında patladı; `GO` + `SET XACT_ABORT ON` ile düzeldi. ⚠️ Bir batch hata verirse transaction kapandığı için SONRAKİ batch'ler de hata basar — bunlar gürültü, asıl hata **ilk** çıkandır. |

---

## Teslim

Script'i yazdıktan sonra kullanıcıya **şunları** söyle:

1. Dosya yolları, **uygulama sırası** (`0` → `1` → `2`).
2. `0-DOGRULAMA`'nın **migration olmadığı**, önce koşulması gerektiği.
3. **Uydurulmuş / doğrulanmamış her değer** — hangi sorgu doğrulayacak.
4. Tekrar koşulabilir mi, koşulursa ne **olmaz** (değer güncellenmez gibi).
5. Script dışında gereken elle adım (Redis flush, servis restart).

Yeni öğrenilen her konvansiyon **bu dosyaya** eklenir.
