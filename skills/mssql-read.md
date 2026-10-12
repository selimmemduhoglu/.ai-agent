# Skill — mssql-read (SALT-OKUNUR DB erişimi)

**Ne zaman tetiklenir:** Kod/doküman okuyarak anlaşılamayan bir şeyi **gerçek veriden** doğrulaman gerektiğinde.
Tetikleyici kelimeler: *DB'ye bak · veritabanından kontrol et · tabloda ne var · gerçek veri · örnek kayıt ·
kolon dolu mu · kaç kayıt var · SELECT at · sorgula*

**Tür:** Salt-okunur araştırma · **Kapsam:** cross-repo

---

## 🔴 MUTLAK KURAL — YALNIZCA `SELECT`

Bu skill **sadece okur**. Aşağıdakiler **kesinlikle yasak** — tek istisnası yok:

```text
INSERT · UPDATE · DELETE · MERGE · TRUNCATE · DROP · ALTER · CREATE
EXEC · EXECUTE · sp_* · xp_* · BULK INSERT · OPENROWSET
GRANT · REVOKE · DENY · BACKUP · RESTORE · DBCC
BEGIN TRAN · COMMIT · ROLLBACK
SELECT ... INTO · UPDLOCK/XLOCK/TABLOCK hint'leri
```

**Tek izinli `SET`:** `SET NOCOUNT ON` (çıktıyı temizler, veriye dokunmaz).

**Veri değiştirmek gerekiyorsa:** SQL'i **çalıştırma**. Idempotent script'i `<repo>/.ai-agent/outputs/`
altına yaz, yolu bildir, **kullanıcı kendisi uygular**. (MM'de EF Core migration altyapısı yok — şema
dışarıdan yönetiliyor; bu kural oradan geliyor.)

---

## 🔴 TOKEN KORUMA KURALLARI (ZORUNLU)

Kullanıcının açık talimatı: *"çok data gelip seni yormasın ve token harcama"*.

| # | Kural                                                                                                                                                                       |
| - | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 1 | **Her sorguda `TOP (20)`** — istisnasız. Daha fazlası gerekiyorsa **önce gerekçesini söyle**, sonra en fazla `TOP (50)`                               |
| 2 | **`ORDER BY Id DESC`** — en yeni 20 kayıt. Tabloda `Id` yoksa `ORDER BY` için en yakın anahtarı kullan (`CreatedDate DESC`, `StateDate DESC`, PK DESC) |
| 3 | **`SELECT *` YASAK** — ihtiyacın olan kolonları **tek tek** yaz. Eğer ki tüm kolonlar gerekiyorsa SELECT * yapabilirsin. Bu repoda tablolar 40+ kolonlu |
| 4 | Uzun metin/JSON/blob kolonlarını çekme; gerekirse`LEFT(Kolon, 200) AS Kolon` ile kırp                                                                                 |
| 5 | Sayı yeterliyse satır çekme:`SELECT COUNT(*)` · `SELECT MIN/MAX` · `GROUP BY` + `COUNT`                                                                        |
| 6 | Çıktı 40 satırı geçiyorsa `                                                                                                                                           |
| 7 | Aynı bilgiyi ikinci kez sorgulama — bulguyu**hemen** ilgili MD'ye yaz                                                                                               |

---

## 🔴 ZORUNLU — HER SORGU DENETİM KAYDINA YAZILIR

Kullanıcının talimatı (2026-08-13): *"her SQL'e bağlanıp sorduğun soruyu ve response'unu görmek istiyorum
ama **istisnasız hepsinin** çünkü **tehlikeli aslında DB'ye bağlanman**, o yüzden görmem lazım."*

```text
.ai-agent/sql-log/<chat-slug>/01-sorgular.md    ← SQL + amaç      (çalıştırmadan ÖNCE yaz)
.ai-agent/sql-log/<chat-slug>/02-ciktilar.md    ← ham çıktı        (çıktı gelince yaz)
```

| # | Kural |
|---|---|
| 1 | **İSTİSNASIZ HER SORGU** — başarılı, **başarısız**, keşif, tekrar, `sys.tables` dahil |
| 2 | Sorguyu **çalıştırmadan ÖNCE** `01-sorgular.md`'ye yaz |
| 3 | İki dosya **aynı `#` numarası** ile eşleşir |
| 4 | Her sorguda **amaç**: *neyi neden öğrenmek istedim* |
| 5 | Çıktı **ham**; kırpıldıysa "kırpıldı" yaz |
| 6 | **Parolayı maskele** (`-P '***'`) |
| 7 | `<chat-slug>` **`compacts/` ile aynı** olmalı |
| 8 | Önceki kayıtları **asla düzenleme/silme** — denetim kaydı |

Klasör yoksa aç + [`sql-log/_index.md`](../sql-log/_index.md) tablosuna satır ekle.
**Bu adımı atlarsan skill'i ihlal etmiş olursun** — kullanıcı DB erişimini bu dosyalardan denetliyor.

---

## Bağlantı

**Credential'ları MD'ye kopyalama.** Kaynağından oku:

| Repo           | Kaynak dosya                                                                              | Server             | Database      |
| -------------- | ----------------------------------------------------------------------------------------- | ------------------ | ------------- |
| `NetTrex.MM` | `Code/docker-compose.override.yml` satır 24 (`ConnectionStrings__DefaultConnection`) | `192.168.10.211` | `NetTrexMM` |
| Diğer repolar | O reponun`docker-compose.override.yml`'ı — **önce oku, varsayma**              | ?                  | ?             |

Kullanıcı adı/parola ilgili `docker-compose.override.yml` satırındadır. Grep ile al:

```bash
grep -n "ConnectionStrings__DefaultConnection" Code/docker-compose.override.yml
```

### Komut şablonu

```bash
sqlcmd -S "tcp:<SERVER>,1433" -d <DB> -U <USER> -P '<PASSWORD>' -C -l 20 -W -s "|" \
  -Q "SET NOCOUNT ON; SELECT TOP (20) <kolonlar> FROM <tablo> WHERE <filtre> ORDER BY Id DESC;"
```

| Parametre                  | Neden                                                                                                                                                  |
| -------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `-S "tcp:<SERVER>,1433"` | 🔴**`tcp:` ve port ŞART.** Yalnız IP verirsen sqlcmd **Named Pipes**'a düşer → *"Could not open a connection to SQL Server [64]"* |
| `-C`                     | `TrustServerCertificate=True` (connection string'de de var)                                                                                          |
| `-l 20`                  | Login timeout 20 sn — sunucu erişilemezse hızlı düş                                                                                              |
| `-W -s "                   | "`                                                                                                                                                     |
| `-Q "..."`               | Tek sorgu çalıştır ve**çık** (interaktif mod açma)                                                                                        |

Bağlantı doğrulama (ilk kullanımda):

```bash
sqlcmd -S "tcp:192.168.10.211,1433" -d NetTrexMM -U trusr -P '<PWD>' -C -l 20 -W -s "|" \
  -Q "SET NOCOUNT ON; SELECT TOP 5 name FROM sys.tables ORDER BY name;"
```

---

## Keşif sorguları (hazır)

**Tablo ara:**

```sql
SET NOCOUNT ON;
SELECT TOP (20) name FROM sys.tables WHERE name LIKE '%Revaluation%' ORDER BY name;
```

**Kolonları listele:**

```sql
SET NOCOUNT ON;
SELECT c.name, t.name AS type, c.max_length, c.is_nullable
FROM sys.columns c
JOIN sys.types t ON t.user_type_id = c.user_type_id
WHERE c.object_id = OBJECT_ID('dbo.AccEntryMain')
ORDER BY c.column_id;
```

**Son 20 kayıt (asıl kullanım):**

```sql
SET NOCOUNT ON;
SELECT TOP (20) Id, TxnId, MessageKey, BusinessKey, IsReverse, ReverseId, ExternalState, ProductCode, Type
FROM dbo.AccEntryMain
ORDER BY Id DESC;
```

**Kolon gerçekten dolu mu (satır çekmeden):**

```sql
SET NOCOUNT ON;
SELECT COUNT(*) AS Toplam,
       SUM(CASE WHEN MessageKey IS NULL THEN 1 ELSE 0 END) AS MessageKeyNull
FROM dbo.AccEntryMain;
```

**Dağılım (satır çekmeden):**

```sql
SET NOCOUNT ON;
SELECT Type, IsReverse, COUNT(*) AS Adet
FROM dbo.AccEntryMain
GROUP BY Type, IsReverse
ORDER BY Adet DESC;
```

**Trigger gövdesi (MM'de `TxnLoanTrigger`/`TxnMMTrigger` tuzağı için):**

```sql
SET NOCOUNT ON;
SELECT TOP (20) name, is_disabled FROM sys.triggers ORDER BY name;
-- gövde için: EXEC sp_helptext ... ❌ YASAK (EXEC). Bunun yerine:
SELECT LEFT(m.definition, 4000) AS Body
FROM sys.sql_modules m
JOIN sys.triggers t ON t.object_id = m.object_id
WHERE t.name = 'TxnMMTrigger';
```

---

## Akış (her kullanımda)

1. **Neyi neden sorguladığını bir cümleyle yaz** — "X kolonu gerçekten doluyor mu, çünkü Y kararı buna bağlı".
2. Bağlantı bilgisini `docker-compose.override.yml`'dan **oku** (ezberden yazma).
3. Sorguyu kur → **`TOP (20)` + `ORDER BY Id DESC` + açık kolon listesi** kontrolünü yap.
4. Çalıştır.
5. **Bulguyu hemen yaz:** kalıcıysa `PROJECT_CONTEXT.md`/`MEMORY.md`, işe özelse ilgili analiz dosyası.
   Aynı sorguyu bir daha çalıştırmak zorunda kalma.
6. Sohbete **ham dökümü basma** — bulguyu özetle, gerekirse tablo yolu + kolon adı ver.

---

## Gotcha

| #              | Tuzak                                                                                                                                                                          |
| -------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| **G-01** | 🔴`-S 192.168.10.211` (tcp'siz) → **Named Pipes hatası**. Her zaman `-S "tcp:IP,1433"`                                                                             |
| **G-02** | Parola özel karakter içeriyor (`+`) → bash'te **tek tırnak** şart: `-P 'Ph4+...'`                                                                               |
| **G-03** | `sqlcmd` yolu: `/c/Program Files/Microsoft SQL Server/Client SDK/ODBC/170/Tools/Binn/` — PATH'te var, doğrudan çağrılabilir                                           |
| **G-04** | **`SELECT *` bir tabloyu 40+ kolonla döker** → context'i öldürür. Kolonları say                                                                                  |
| **G-05** | `sp_helptext` kullanma (**EXEC yasak**) → `sys.sql_modules.definition` kullan                                                                                       |
| **G-06** | **Bu canlıya benzer bir ortam.** Yanlışlıkla yazma riski olan hiçbir şey çalıştırma; şüphedeysen sorguyu **kullanıcıya göster**, sonra çalıştır |
| **G-07** | Tabloda`Id` yoksa `ORDER BY` atlanmaz — en yakın tarih/PK kolonuyla sırala, yoksa **`TOP (20)` anlamsız** (rastgele 20 satır)                                 |
| **G-08** | Fx/Common gibi başka modülün verisi gerekiyorsa**o reponun** connection string'i lazım — MM'in DB'sinde o tablolar **yok**                                    |

---

## Bu skill'in var olma sebebi

Kullanıcı (2026-08-12): *"eğer ki bazı anlamlandıramadığın konularda DB'ye erişmen gerekiyorsa bu skill
dosyasıyla dataları çekmen için… **sadece SELECT sorgusu atacak şekilde**… ORDER BY Id desc yap ve son
20 satırı çek ki çok data gelip seni yormasın ve token harcama"*

Tipik kullanım: bir kolonun gerçekten doldurulup doldurulmadığı · durum türetme mantığının gerçek veriyle
doğrulanması (`M-08`) · trigger'ın hangi kolonları taşıdığı · enum değerlerinin canlıdaki dağılımı ·
"bu senaryo hiç oluşmuş mu" sorusu.
