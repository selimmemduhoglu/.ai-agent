# Collateral Bilgi Bankası — İNDEKS

> 🔴 **Bu klasör, Collateral modülü geliştirmesinde öğrenilen HER ŞEYİ saklar.**
> Sohbet compact edildiğinde veya sıfırdan bir context açıldığında kaybolmasın diye yazıldı.
> Ana agent'ın ve açtığı yan agent'ların bulgularının tamamı burada.
>
> **Son güncelleme:** 2026-10-07

---

> 🔴 **Burası BİLGİ bankası — ne öğrendik.** Plan ve durum burada **değil**:
> **nerede kaldık** → [`../02-DURUM.md`](../02-DURUM.md) ·
> **iş ne / fazlar** → [`../00-YOL-HARITASI.md`](../00-YOL-HARITASI.md) ·
> **bir fazın adımları** → [`../fazlar/`](../fazlar/) ·
> **adlandırma** → [`../01-KIMLIK.md`](../01-KIMLIK.md)
>
> 🔴 **Modül adı `ColManagement`** (2026-10-08). Bu klasördeki dosyalarda geçen `Collateral` ifadeleri
> tablo/domain adlarıdır; modül kimliği için [`../01-KIMLIK.md`](../01-KIMLIK.md) esastır.

---

## Ne zaman hangi dosyayı oku

| Diyeceğin iş | Önce oku |
|---|---|
| *"Bu tablo ne işe yarıyor / domaini anlat"* | **`09-tablolar-neden-var.md`** — domain bilmeyene yazıldı, baştan anlatır |
| *"Tabloları / Excel v6'yı / muhasebeyi / ödemeyi tasarla"* | 🔴 **`10-toplanti-2026-10-08.md`** — patron kararları `02` ve `09`'un önüne geçer |
| *"Script yaz"* | `05-kurulum-scriptleri.md` → `06-ev-konvansiyonlari.md` → `02-veri-modeli.md` |
| *"Backend projesini yaz"* | `03-uc-proje-karsilastirma.md` → `06-ev-konvansiyonlari.md` → `02-veri-modeli.md` |
| *"UI projesini yaz"* | `03-uc-proje-karsilastirma.md` (UI bölümü) + `NetTrex.Collateral/.ai-agent/00-FAZ-PLANI.md` |
| *"Excel'i güncelle"* | `02-veri-modeli.md` → `07-kararlar-ve-sorular.md` |
| *"Nerede kalmıştık"* | `07-kararlar-ve-sorular.md` → `NetTrex.Collateral/.ai-agent/00-FAZ-PLANI.md` |

---

## Dosyalar

| Dosya | İçerik | Kaynağı |
|---|---|---|
| [`01-is-analizi.md`](01-is-analizi.md) | Teminat nedir, 3 ekran, faz sınırı, iş kuralları, hesaplama formülleri | Fonksiyonel doküman v1.4 + ses kaydı |
| [`02-veri-modeli.md`](02-veri-modeli.md) | 20 iş tablosu + platform tabloları, kolonlar, Id stratejisi, Excel'in durumu | Excel v4 + doküman §10 |
| [`03-uc-proje-karsilastirma.md`](03-uc-proje-karsilastirma.md) | MM ↔ OptionsFX ↔ DerivSWP: kod yapısı, isimlendirme, pipeline, hangisini örnek alıyoruz | 3 repo kaynak okuması |
| [`04-db-envanteri.md`](04-db-envanteri.md) | 3 DB'nin tablo envanteri, kesişim, `DefNumberGen`, IDENTITY haritası | Canlı DB ölçümü (salt-okunur) |
| [`05-kurulum-scriptleri.md`](05-kurulum-scriptleri.md) | DerivSwp kurulum script'lerinin anatomisi, Collateral kurulum sırası | `Scripts/Ornek_Deriv_Scripts_DDL/` |
| [`06-ev-konvansiyonlari.md`](06-ev-konvansiyonlari.md) | İsimlendirme, tip, constraint, Id, trigger, audit kuralları — tek sayfa referans | 3 repo + 3 DB ölçümü |
| [`07-kararlar-ve-sorular.md`](07-kararlar-ve-sorular.md) | Verilmiş kararlar (K-xx) + açık sorular (A-xx) | Sohbet geçmişi |
| [`08-tuzaklar.md`](08-tuzaklar.md) | Ölçülmüş tuzaklar — tekrarlanmaması gerekenler | 3 repo + 3 DB ölçümü |
| [`09-tablolar-neden-var.md`](09-tablolar-neden-var.md) | 🔑 **Domain anlatımı** — teminat nedir, 3 katman neden var, her tablo ne işe yarar, ilişkilerin mantığı, uçtan uca örnek | Doküman + ses kaydı |
| [`10-toplanti-2026-10-08.md`](10-toplanti-2026-10-08.md) | 🔴 **Patron toplantısı** — ad kesinleşti, scaffolding, tablo revizyonu (Revaluation silindi, master-detail, MarginRule tartışmalı), muhasebe/nazım, Fimple yok, ödeme sistemi | Ses kaydı 2 |

---

## Kaynak dosyalar (bu klasörün dışında)

| Dosya | Ne |
|---|---|
| `../Hazine_Teminat_Yonetimi_Fonksiyonel_Teknik_Analiz(1) (1).docx` | **Fonksiyonel + teknik analiz v1.4, 30.09.2026.** §10'da 19 tablonun tam kolon speki |
| `../2026-10-07-Collateral-DB-Sema-v5.xlsx` | 🔑 **Asıl çalışma dosyası** — 32 sheet. ⚠️ Her güncellemede **versiyon +1 ve yeni dosya adı**; `00_Surum_Gecmisi`’ne ne/neden satırı 
| `../Collateral-toplantı-ses-kaydı.pdf` | İş birimi toplantısı, 53 sayfa ASR transcript'i |
| `../Scripts/Ornek_Deriv_Scripts_DDL/Kurulum Scriptleri/` | 🔑 **DerivSwp'un gerçek kurulum script'leri** — Collateral script'lerinin şablonu |
| `C:\Users\TREASY-49\source\repos\NetTrex.Collateral\.ai-agent\00-FAZ-PLANI.md` | Faz planı, ilerleme, repo-özel kararlar |
| `C:\Users\TREASY-49\source\repos\.ai-agent\skills\db-script.md` | SQL script yazarken **zorunlu** okunacak ev konvansiyonu |

---

## Çalışma sırası (kullanıcının belirlediği)

```
Excel kesinleşir  →  DB kurulum script'leri  →  Backend kodu  →  EN SON UI
```
Kod script'ten önce yazılmaz. UI en sonda (`Treasy.MM.UI`'den kopyalanarak).
