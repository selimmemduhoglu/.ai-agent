# 00-YOL-HARITASI.md — ColManagement Modülü

> 🔴 **HER İSTEKTE İLK OKUNAN DOSYA BU.** Sohbet sıfırlanmış, compact edilmiş, hiç bağlam yok —
> fark etmez: buradan devam edebilmelisin.
>
> **Son güncelleme:** 2026-10-08 · **Güncel faz:** Faz 3 (DB kurulum script'leri) — başlamadı

---

## 0. Bu dosya nasıl kullanılır (Claude için protokol)

| Adım | Ne yapılır |
|---|---|
| 0 | 🔴 [`02-DURUM.md`](02-DURUM.md) oku — **nerede kaldık**, hangi faz, ne bloke, kullanıcının kendi sözleri |
| 0c | Mimari tartışma (A bizim ↔ B Aret/FI) → [`04-MIMARI-KARSILASTIRMA.md`](04-MIMARI-KARSILASTIRMA.md) |
| 0b | 🔴 Kod taşırken açık görürsen **düzeltme** → [`03-HATA-KAYDI.md`](03-HATA-KAYDI.md)'ye numaralı yaz (kullanıcı geliştirme sonunda karar verecek) |
| 1 | Bu dosyayı oku — iş ne, faz listesi (§4), değişmez kurallar (§7) |
| 2 | Kullanıcının istediği iş hangi faza giriyorsa [`fazlar/faz-N-*.md`](fazlar/) dosyasını oku |
| 3 | O faz dosyası hangi bilgi dosyalarını gerektirdiğini **kendi başında yazar** — yalnız onları aç |
| 4 | İş bitince [`progress/`](progress/) altına **yeni numaralı** dosya + bu dosyadaki faz tablosunu güncelle |

🔴 **[`bilgi-bankasi/`](bilgi-bankasi/) altındaki 10 dosyanın hepsini birden OKUMA** — token israfı.
Hangi işte hangisi gerektiği [`bilgi-bankasi/00-INDEX.md`](bilgi-bankasi/00-INDEX.md)'te tablo hâlinde.

🔴 **Önceki progress dosyalarını ASLA düzenleme/silme** — append-only.

---

## 1. Bu iş ne?

**ColManagement** = Hazine **Teminat Yönetimi** modülü. Katılım/yatırım bankaları için
Treasy/NetTrex treasury platformuna eklenen yeni bir finansal ürün ailesi.

**Teminat (collateral):** bir tarafın karşı tarafa olan kredi riskini azaltmak için verdiği
**nakit** veya **menkul kıymet**. Modül üç katmanlı:

```
Annex (sözleşmesel çerçeve: Threshold / MTA / Rounding)
  └─> CollateralDefinition (hangi varlık teminat kabul edilir, hangi şartla)
        └─> TxnTransaction (fiili Increase/Decrease hareketi)
              └─> CollateralPosition (bakiye)
```

Domain'i hiç bilmiyorsan → [`bilgi-bankasi/09-tablolar-neden-var.md`](bilgi-bankasi/09-tablolar-neden-var.md)
(sıfırdan anlatır: neden 3 katman, hangi tablo ne işe yarar, uçtan uca örnek).

---

## 2. 🔴 Modül adı: **ColManagement** (2026-10-08, kullanıcı kararı — SON KARAR)

Önceki ad `Collateral`. Artık **ColManagement** kullanılıyor. Adlandırma sözlüğünün tamamı →
[`01-KIMLIK.md`](01-KIMLIK.md). Özet:

| Ne | Ad |
|---|---|
| Backend repo | `NetTrex.ColManagement` *(kullanıcı yeniden adlandıracak)* |
| UI repo | `Treasy.ColManagement.UI` *(kullanıcı yeniden adlandıracak)* |
| Veritabanı | `NetTrexColManagement` |
| Namespace kökü / assembly | `NetTrex.ColManagement.*` |
| Modül kodu | `CM` ⬜ *(onay bekliyor)* |

🔑 **Tablo adlarında kural:** tablo **ne tuttuğunu** anlatır, projenin adını değil.
`Collateral` kelimesi **domain** (teminat varlığı) olduğu yerde kalır; `ColManagement` **modül
kimliği** olduğu yere girer. Ayrıntı ve tam liste → [`01-KIMLIK.md`](01-KIMLIK.md) §3.

---

## 3. İş sırası (kullanıcı belirledi, değişmez)

```
Backend İSKELETİ  →  Excel kesinleşir  →  DB script'leri  →  Backend İŞ KODU  →  EN SON UI
```

🔑 **Sıra 2026-10-08'de değişti** (kullanıcı): iskelet script'ten **önce**. İskelet şemadan bağımsız
(entity yok), şema ise patron sunumundan sonra değişebilir.

🔴 **Ama ENTITY/iş kodu script'ten önce yazılmaz.** DDL Excel'den, entity DDL'den üretilir.
Ters yönde çalışmak üç yerde ayrışma üretir.

---

## 4. Fazlar

> 🔴 **Faz DURUMLARI burada değil** → [`02-DURUM.md`](02-DURUM.md) §1. Bu tablo **statik plan**;
> durumu iki yerde tutmak ayrışma üretir.

| Faz | Kapsam | Dosya |
|---|---|---|
| **0** | Kimlik & isimlendirme (modül kodu, sayaç öneki, DB adı) | [`fazlar/faz-0-kimlik-kararlari.md`](fazlar/faz-0-kimlik-kararlari.md) |
| **1** | Repo iskeleti + MD omurgası | [`fazlar/faz-1-repo-iskeleti.md`](fazlar/faz-1-repo-iskeleti.md) |
| **2** | Veri modeli — Excel | [`fazlar/faz-2-veri-modeli.md`](fazlar/faz-2-veri-modeli.md) |
| **3** | **Backend iskelet** — OptionsFX/MM yapısına göre çözüm ağacı | [`fazlar/faz-3-backend-iskelet.md`](fazlar/faz-3-backend-iskelet.md) |
| **4** | 🔴 **DB kurulum script'leri** (0-9 sırası, DerivSwp şablonu) | [`fazlar/faz-4-db-kurulum-scriptleri.md`](fazlar/faz-4-db-kurulum-scriptleri.md) |
| **5** | Backend altyapı — DbContext, `CoreDataSlice`, DI, entity base, pipeline | [`fazlar/faz-5-backend-altyapi.md`](fazlar/faz-5-backend-altyapi.md) |
| **6** | **Annex** ucu — ilk dikey dilim, deseni kurar | [`fazlar/faz-6-annex.md`](fazlar/faz-6-annex.md) |
| **7** | **CollateralDefinition** ucu (+6 alt tablo, Cash/Security varyantı) | [`fazlar/faz-7-definition.md`](fazlar/faz-7-definition.md) |
| **8** | **TxnTransaction** ucu + `CollateralPosition` bakiye kilidi | [`fazlar/faz-8-transaction.md`](fazlar/faz-8-transaction.md) |
| **9** | Değerleme · Limit · Muhasebe · Ödeme mesajı | [`fazlar/faz-9-muhasebe-mesaj-limit.md`](fazlar/faz-9-muhasebe-mesaj-limit.md) |
| **10** | **UI iskeleti** — `Treasy.MM.UI`'den kopyala, Shell'e kaydet | [`fazlar/faz-10-ui-iskelet.md`](fazlar/faz-10-ui-iskelet.md) |
| **11** | **UI ekranları** — 3 ekran + 2 popup + detay sekmesi | [`fazlar/faz-11-ui-ekranlar.md`](fazlar/faz-11-ui-ekranlar.md) |
| **12** | Uçtan uca doğrulama, EOD, release note | [`fazlar/faz-12-uctan-uca.md`](fazlar/faz-12-uctan-uca.md) |

**Faz bitiş kriteri:** her fazın sonunda [`progress/`](progress/) altına **yeni numaralı** dosya
(ne yapıldı · hangi dosyalar · hangi kararlar · **nasıl doğrulandı**) + [`02-DURUM.md`](02-DURUM.md) güncellenir.

---

## 5. Açık kararlar

Faz 4'ü (script) bloke eden 3 karar + iş birimi toplantısı soruları + ölçülecekler →
🔴 [`02-DURUM.md`](02-DURUM.md) §2. Gerekçeleriyle tam liste →
[`bilgi-bankasi/07-kararlar-ve-sorular.md`](bilgi-bankasi/07-kararlar-ve-sorular.md).

---

## 6. Dosya haritası

```
repos/.ai-agent/feature-research/ColManagement-Feature/     ← 🔑 BU İŞİN ANA EVİ
├── 00-YOL-HARITASI.md          ← bu dosya. Statik plan: iş ne, fazlar, kurallar
├── 01-KIMLIK.md                ← ColManagement adlandırma sözlüğü (tek gerçek kaynak)
├── 02-DURUM.md                 ← 🔴 CANLI DURUM: nerede kaldık, açık uçlar, compact protokolü
├── 2026-10-07-...-v5.xlsx      ← 🔑 DB şeması. DDL buradan üretilir
├── Hazine_Teminat_...docx      ← fonksiyonel analiz v1.4
├── Collateral-toplantı-...pdf  ← iş birimi toplantısı transcript'i
├── Scripts/Ornek_Deriv_...     ← 🔑 DerivSwp'un gerçek kurulum script'leri (şablon)
├── bilgi-bankasi/              ← BİLGİ: ne öğrendik (10 dosya, indeksten seç)
├── fazlar/                     ← PLAN: ne yapacağız (13 dosya, faz başına 1)
└── progress/                   ← KAYIT: ne yaptık (append-only, numaralı)
```

Repo-içi `.ai-agent/` klasörleri **ince**: yalnız o repoya özel şey + buraya pointer.

| Repo | Ne tutar |
|---|---|
| `NetTrex.ColManagement/.ai-agent/` | Build komutu, repo-özel tuzak, bu dosyaya pointer |
| `Treasy.ColManagement.UI/.ai-agent/` | (Faz 10'da açılacak) |

---

## 7. Değişmez kurallar (bu iş için)

Workspace `CLAUDE.md` Hard Rule'larına **ek**. İhlal edilmez.

1. 🔴 **PK'ler `bigint`** — ofis kuralı. DerivSwp `int` başlayıp v1.30'da 3 migration script'iyle çevirmek zorunda kaldı.
2. 🔴 **Para `decimal(38,10)` · oran `decimal(18,10)` · `float`/`double` YASAK.** `decimal(38,2)` fiziksel DB'de **hiç yok**.
3. 🔴 **CHECK constraint yazılmaz**, FK yalnız referans tablolarına ve `NO_ACTION`. (MM: 125 tabloya 0 CHECK / 14 FK.) Excel'deki `> 0`, `0..1` ifadeleri **servis katmanı** kuralı.
4. 🔴 **Ana işlem tablosu + 3 muhasebe tablosu `DefNumberGen`'den; gerisi IDENTITY.** 3/3 modülde ölçüldü.
5. 🔴 **Script ÇALIŞTIRILMAZ** — `outputs/`'a yazılır, **kullanıcı uygular**.
6. 🔴 **DB'ye yalnız `SELECT`**, her sorgu `TOP (20)` + denetim kaydı (`sql-log/`).
7. 🔴 **Claude commit/push/PR yapmaz**, önermez de.
8. **Kod yorumu nadir ve kısa** — `<remarks>` yok, "PO kararı" referansı **hiç** yok.
9. **Excel her güncellemede sürüm +1 + yeni dosya adı** + `00_Surum_Gecmisi` satırı.
10. 🔴 **UNIT TEST YAZILMAZ** (kullanıcı kararı 2026-10-08): *"tüm projeyi yazdıktan sonra unit testleri yazacağız… hiçbir şekilde unit testlere zaman harcayamayız."* 13 test projesi **boş iskelet** duruyor. Workspace `CLAUDE.md` Hard Rule 10'a **bilinçli istisna** — kullanıcı haber verince test turu açılır.
11. 🔴 **"compact" denince ÖNCE [`02-DURUM.md`](02-DURUM.md) güncellenir**, sonra `compacts/<chat-slug>/compact-<n>.md` yazılır. Protokol → [`02-DURUM.md`](02-DURUM.md) §5.

---

## 8. Kaynak güvenilirliği — önce bunu bil

| Kaynak | Güven |
|---|---|
| Fonksiyonel doküman **§10 (DB bölümü)** | 🔴 **İş analisti sahiplenmiyor:** *"Teknik analizi tamamen [AI] için çıkardı… Buralar yanlış olabilir"* (transcript 1577-1600). Excel bu bölümden türedi ama **körü körüne değil** — mantıklı hâle getirildi |
| Toplantı transcript'i | 🔑 **İş kararlarında BAĞLAYICI.** ⚠️ ASR bozuk yerleri var |
| Doküman — ISO/SWIFT mesaj standardı | ✅ Bu kısımda doküman daha isabetli |
| Ev konvansiyonu (tip, isim, constraint) | ✅ **Ölçüldü** — 3 repo + 3 canlı DB |
| Mevcut ekranlardan kopyalanan desen | ⚠️ Desen meşru, **iş kuralı dokümandan** alınır. Çeliştiğinde **çalışan kod** kazanır |
