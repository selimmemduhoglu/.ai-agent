# progress-5 — `mssql-read` skill'i · mevcut ekranların analizi · **SÖZLEŞME DONDURULDU**

**Tarih:** 2026-08-13 · **Önceki:** [progress-4.md](progress-4.md)
**Tetikleyen istek:** *"önemli olan benim sana ilk attığım manuel reeskont dökümanıdır… soruların varsa
mevcut FX için yazılan şu an var olan manuel reeskont ekranına bakabilirsin, hali hazırda o ekran
çalışıyor… mantık yürüterek cevaplayarak yap bu yeni geliştirmeyi"* + *"MSSQL için… sadece SELECT
sorgusu atacak şekilde skill dosyası oluştur"*
**Kural:** Bu dosya progress-4'ün **güncellenmiş tam hali**dir. Öncekiler **düzenlenmedi**.

---

## ✅ YAPILDI (bu tur)

### A. `mssql-read` skill'i — salt-okunur DB erişimi

| Dosya | Ne |
|---|---|
| [`repos/.ai-agent/skills/mssql-read.md`](../../skills/mssql-read.md) | Gövde — mutlak SELECT kuralı · token koruma (7 kural) · bağlantı tablosu · komut şablonu · 6 hazır keşif sorgusu · 8 gotcha |
| `NetTrex.MM/.claude/skills/mssql-read/SKILL.md` | Tetikleyici wrapper |
| `NetTrex.Web.UI/.claude/skills/mssql-read/SKILL.md` | Tetikleyici wrapper (+ "bu reponun kendi DB'si yok" uyarısı) |
| `repos/CLAUDE.md` · `NetTrex.MM/CLAUDE.md` · `NetTrex.Web.UI/CLAUDE.md` | Skill bölümlerine **"koddan emin olamadığında DB'ye bak"** yönlendirmesi |
| 3 × `skills/_index.md` | Satır eklendi |

**Kurallar:** 🔴 yalnız `SELECT` (INSERT/UPDATE/DELETE/MERGE/DDL/`EXEC`/`sp_`/`xp_`/TRAN **yasak**;
tek izinli `SET NOCOUNT ON`) · her sorgu **`TOP (20)` + `ORDER BY Id DESC`** · kolonlar tek tek ·
yazma gerekiyorsa SQL `outputs/`'a yazılır, **kullanıcı uygular**.

**Bağlantı:** `NetTrex.MM/Code/docker-compose.override.yml:24` → `192.168.10.211` / `NetTrexMM`.
Credential MD'ye kopyalanmadı, kaynağından okunuyor.

🔴 **Kurulumda çıkan tuzak (`G-01`):** `-S 192.168.10.211` (tcp'siz) →
*"Named Pipes Provider: Could not open a connection to SQL Server [64]"*. Doğrusu **`-S "tcp:IP,1433"`**.

### B. Mevcut iki ekran uçtan uca okundu

**Beklenmedik bulgu: dokümanın 3 ekranından İKİSİ zaten yazılmış.**

| Ekran | Nerede | Uç |
|---|---|---|
| **Treasury (FX)** | `Controllers/ManuelReescont/ManuelRevaluationController.cs` · `Views/ManuelReescont/Index.cshtml` | `ManuelReescontApi : IClientFxAPI` → `POST /Rediscount/select` · `POST /Rediscount/update` |
| **Security (FI)** | `Controllers/FI/SecurityManuelReescont/` · `Services/FI/ISecurityManuelReescontApi.cs` | FI modülü |

**Mevcut FX ekranından ölçülenler:**

| Bulgu | Kanıt |
|---|---|
| Filtreler: Date (zorunlu) · Product (**çoklu** DropDownBox+dxList) · Status (**tekil** SelectBox) | `Index.cshtml:17-64` |
| **TEK aksiyon butonu** (`btnReescontKes` → "Reeskont Kes") | `Index.cshtml:66-75` |
| Aksiyon satırın **kendi durumunu** backend'e gönderiyor → backend ne yapacağına ondan karar veriyor | `Index.cshtml:209-218` · `RediscountTransactionUpdateItem` |
| Çoklu seçim + `SelectAllMode.AllPages` | `Index.cshtml:90-93` |
| Çift-tıklama koruması: buton `disabled` | `Index.cshtml:205-206`, `:233` |
| **Sayfalama YOK** · onay penceresi **YOK** · ters fiş valörü seçimi **YOK** | — |
| `MessageKey` **grid'de kolon olarak gösteriliyor** | `Index.cshtml:99` |
| Badge renkleri | `Index.cshtml:246-275` |
| Status enum'ında **`All = 1` VAR** | `Trex.Common.Models/Enums/ManualRediscount.cs` |
| Product enum'ı: `Fx=2, FXSwap=3, Pm=4, PmSwap=5, ExternalFWD=6, ExternalSWP=7` | aynı dosya |
| FI'nin muadili: `RediscountTransactionType` = `Buy/Sell/Repo/RRP/DTR/CPN/MTR` | `SecurityManuelReescontEnum.cs` |

### C. 🔑 M-08 — durum türetme **canlı DB'den doğrulandı** (`mssql-read` ilk kullanımı)

`dbo.AccEntryMain` üzerinde 3 sorgu:

| Ölçüm | Sonuç |
|---|---|
| `Type=2` (Revaluation) dağılımı | **2050** `IsReverse=0` · **1958** `IsReverse=1` → **92 ters alınmamış** |
| `ReverseId` | **hiç NULL değil** — yokluk **`0`** ile ifade ediliyor |
| Zincir | `Id=555801 (IsReverse=0, ReverseId=555809)` ⇄ `Id=555809 (IsReverse=1, ReverseId=555801)` — **çift yönlü** |
| `StateMaker` | orijinalde gerçek kullanıcı, **ters fişte `SYSTEM`** → **`T-01` canlıda doğrulandı** |
| Aynı `TxnId` | birden çok tarihte revaluation kaydı (`553292` → 07-30, 07-31, 08-04, 08-05) → **tarih filtresi zorunlu** |

**Kesin türetme kuralı:**

```text
R = TOP 1 (Type=2 AND TxnId=X AND IsReverse=0 AND ValueDate=D) ORDER BY Id DESC
R yok                → NotRediscounted
R var, ReverseId = 0 → NotReversed
R var, ReverseId > 0 → Rediscounted
```

→ Tek `LEFT JOIN` + projeksiyon, **N+1 yok**, sayfalanabilir.

### D. `R-16` (`FT-01` iki `MessageKey`) — **gözlemle kapandı**

DB'de **1958 başarılı ters fiş** var ve ters fiş `ReverseMessageKey` olmadan kesilemiyor
⇒ MM **doğru** `MessageKey`'i persist ediyor. Ayrıca `FimpleAccountingService.cs:188-193` ters fişte
`ReverseMessageKey: context.MessageKey` + `ReversAccountingTransactionDate: context.LogicalDate` gönderiyor
⇒ **T+1 valörü zaten parametrik** (C-08'in teknik kanıtı).

### E. 🔒 **`06-sozlesme.md` YAZILDI ve DONDURULDU** — 11 soru kapandı

| Soru | Karar | Dayanak |
|---|---|---|
| **C-01** aksiyon | **2 buton** (Generate·Regenerate) + satır durumu da gider | Mevcut ekran tek buton + durum-güdümlü; doküman bunu ikiye ayırıyor (birincil) |
| **C-01** `All` | ✅ **VAR**, filtre **tekil** | Enum'da `All=1` var, `SelectBox` tekil → §3.5 ile §4.7 **çelişmiyor** |
| **C-02** Product/SubProduct | **TEKİL** | **Kullanıcı kararı** |
| **C-05** | `Failed: ALREADY_REDISCOUNTED` | Sessiz atlama "yaptım" yalanı olur |
| **C-07** | **SENKRON**, `Processing` rezerve | Mevcut ekran senkron ve canlıda çalışıyor; `Take ≤ 200` |
| **C-08** | `ReverseValueDate` **KALIYOR** | MM zaten parametrik gönderiyor |
| **C-14** | `Data` item **içinde** | **Kullanıcı açıklaması** |
| **C-15** | UI'de JSON, ViewComponent hidden alana basar | Mevcut ekranlar Razor'da hard-code — genel ekranda imkânsız |
| **M-02** | SubProduct **string**, listesi kolon config'inde (3. endpoint yok) | Doküman 2 endpoint diyor |
| **M-05** | 2 ondalık | Fimple payload'ı `Debit: 14.47` |
| **M-07** | Fimple'a `"Rediscount"` (batch ile aynı) | `FimpleAccountingService.cs:162`; farklı tip EOD mutabakatını bozar |
| **M-08** | `ReverseId = 0 / > 0` | **Canlı DB** |
| **R-04** | Konu kapandı | Product zaten modülü belirliyor |

### 🔑 En büyük mimari kazanç

**Product tekil ⇒ her sorgu tam olarak BİR modüle gider.**

| Sonuç | Etki |
|---|---|
| 🔴 **`R-13` (çok modüllü sayfalama) ORTADAN KALKTI** | Planın en büyük belirsizliğiydi; `Skip`/`Take`/`TotalCount` artık **doğru** |
| Fan-out normal akışta gerekmiyor | Resolver yine çoklu destekli yazılır (Faz 3 opsiyonu) |
| Kolon config `(ProductGroup, Product)` çiftine bağlanabiliyor | `Data` tek modül şemasına göre çözülür |

### F. Hiyerarşi netleşti

**Mevcut ekranın "Product" filtresi = yeni dokümanın SubProduct'ı.** Yeni ekran üstüne bir seviye ekliyor:

```text
Treasury → FX Transactions   (→FX)      → Fx · FXSwap · Pm · PmSwap · ExternalFWD · ExternalSWP
         → MM/Loan Transactions (→MM)   → Murabaha · Wakala
Security → Security Transactions (→FI)  → Buy · Sell · Repo · RRP · DTR · CPN · MTR
```

### G. Sözleşmede **kasıtlı olarak reddedilenler**

| Ne | Neden |
|---|---|
| `SelectAll` (tüm veri kümesi) | Görülmeyen satıra fiş kesme riski → açık `TransactionId` listesi, max 200 |
| `MessageKey`'in UI'ye gitmesi | Muhasebe iç anahtarı; `executions`'da da kullanılmıyor |
| `IsSuccess = true` + boş hata | Mevcut FX akışının en büyük kusuru |
| 3. endpoint (SubProduct lookup) | Doküman 2 endpoint diyor |

---

### H. 🔴 SQL denetim kaydı kuruldu (kullanıcı talebi, tur içinde)

*"her SQL'e bağlanıp sorduğun soruyu ve response'unu görmek istiyorum ama **istisnasız hepsinin**
çünkü **tehlikeli aslında DB'ye bağlanman**"*

| Dosya | Ne |
|---|---|
| [`repos/.ai-agent/sql-log/_index.md`](../../sql-log/_index.md) | Klasör yapısı + 8 değişmez kural + sohbet tablosu |
| `sql-log/manuel-reeskont-analiz/01-sorgular.md` | **5 sorgunun tamamı** (1 başarısız dahil) + amaçları · parola maskeli |
| `sql-log/manuel-reeskont-analiz/02-ciktilar.md` | 5 ham çıktı + her birinin yorumu |
| `skills/mssql-read.md` | **"HER SORGU DENETİM KAYDINA YAZILIR"** bölümü — sorgu çalıştırılmadan **önce** yazılır |
| 2 × `SKILL.md` wrapper · 3 × `CLAUDE.md` | Denetim kaydı kuralı eklendi |

**Toplam:** 5 sorgu · 5 `SELECT` · **0 yazma işlemi**.

### I. Compact okuma boşluğu kapatıldı

Kullanıcı sordu: *"benim yazdıklarımı anlamak için compact dosyalarına bakıyor musun?"*
**Dürüst cevap: hayır** — `START-HERE.md`'de okuma sırasında vardı ama `manuel-reeskont` skill'inin
**ADIM 0 listesinde yoktu**, yani skill tetiklendiğinde compact'ler okunmuyordu.

**Fix:** ADIM 0'a iki satır eklendi —
`2b` compact'ler (*"`progress/` ne yapıldığını, compact **neden** öyle yapıldığını söyler.
Yeni oturumda veya sıkıştırma sonrasında **ATLAMA**"*) ve `2c` sql-log (*aynı sorguyu tekrar çalıştırma*).
`00-PANO.md` dosya haritasına da eklendi.

---

## 🔵 YAPILIYOR

Yok.

---

## ⬜ YAPILACAK

### 🔓 KAPI AÇIK — Faz 1 kodlanabilir

| # | İş | Repo |
|---|---|---|
| İ-10…İ-15 | `eligible-transactions` ucu: DTO'lar · durum türetmeli sayfalı sorgu · handler · validator · controller · test | `NetTrex.MM` |
| İ-20…İ-27 | Refit interface · `IManuelReeskontModuleResolver` · query service · sözleşme DTO'ları · `TreasuryReeskontController` | `NetTrex.Web.UI` |
| İ-30…İ-36 | ViewComponent · Razor · CSS · localization | `NetTrex.Web.UI` |
| İ-40…İ-45 | 6 JS dosyası (`MR_` prefix, nesil 3 class deseni) + kolon config JSON | `NetTrex.Web.UI` |

> Sözleşme dondurulduğu için **İ-01…İ-06 doğrulamaları artık bloke edici değil** — kodlama sırasında
> yapılacak (özellikle `F-14` aktif modül parametresi, `F-16` Refit timeout).

### Faz 2 (aksiyonlar) — artık bloke değil

`İ-50`…`İ-68` — aksiyon×durum matrisi `06-sozlesme.md` § 9'da kesin.

### Hâlâ dışarıdan cevap bekleyenler (**kodu bloke ETMİYOR**)

| # | Kime | Ne |
|---|---|---|
| `Ö-S-01…08` | Fimple ekibi | bulk hazine bağı · kısmi hata · **idempotency header** · Corporate `TransactionType` · `TransactionWorkgroupId` · batch yaşam döngüsü · reverse valörü · sürüm sapması |
| `Ö-04`/`Ö-05` | Muhasebe | ters fiş vs `Compensate` vs `Cancel` |
| C-20 | İş birimi | Eski FX ekranı silinecek mi, paralel mi yaşayacak |
| İ-71 | Selim | `NetTrex.Fx`'in 2 ucunu kim yazacak |

---

## Kararlar bu turda

| Karar | Gerekçe |
|---|---|
| **Sözleşme dondu** — 11 soru mantık yürüterek kapatıldı | Kullanıcının açık talimatı; her karar mevcut çalışan koda veya canlı veriye dayandırıldı |
| **`mssql-read` yalnız SELECT** + `TOP (20)` + `ORDER BY Id DESC` | Kullanıcının açık talimatı (token koruma + güvenlik) |
| Sözleşme enum'ı **dokümanın** numaralandırmasını kullanıyor (mevcut modüllerinkinden farklı) | Doküman birincil; FX/FI kendi iç enum'ını uçta map eder |
| `All` **filtre değeri**, row status **değil** → `Status = null` | Mevcut kod ikisini aynı enum'da karıştırıyor — kusur, tekrarlanmıyor |
| Mevcut ekranın 10 kusurundan **hiçbiri taşınmadı** | `analiz-6` § 7'de listelenmişti; sözleşme § 12'de açıkça reddedildi |
