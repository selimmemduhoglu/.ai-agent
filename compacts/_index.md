# Compacts — Sıkıştırma Öncesi Detay Kurtarma

> **Neden var:** `/compact` bağlamı düşürür. Sohbette geçen ama dosyalara yazılmayan şeyler
> (çalıştırılan komut, hatanın **aynı** metni, bir kararın **gerekçesi**, **kullanıcının verdiği cevaplar**)
> sıkıştırmada kaybolur. Bu klasör onları diskte tutar.
>
> **`progress/` ne yapıldığını, burası neden öyle yapıldığını söyler.**

---

## 🔴 Klasör yapısı — SOHBET BAŞINA KLASÖR

```
.ai-agent/compacts/
├── _index.md                       ← bu dosya (sohbet tablosu)
├── _precompact-instruction.md      ← PreCompact hook bunu basar
├── _postcompact-instruction.md     ← SessionStart:compact hook bunu basar
│
├── <chat-slug>/                    ← HER SOHBET İÇİN BİR KLASÖR
│   ├── _chat.md                    ← sohbet kimliği (ad, session id, tarih, konu)
│   ├── compact-1.md                ← o sohbetin 1. sıkıştırması
│   ├── compact-2.md                ← 2. sıkıştırması
│   └── compact-N.md
└── <baska-chat-slug>/
    └── ...
```

**Kural:**

1. Compact anında `<chat-slug>/` klasörü **var mı diye bak**.
2. **Varsa** → içindeki en büyük numaralı `compact-<n>.md`'yi bul, **`n+1` ile YENİ dosya** aç.
   Önceki compact dosyalarını **asla düzenleme/silme**.
3. **Yoksa** → klasörü aç, `_chat.md` yaz, `compact-1.md` ile başla.
4. Bu tablodaki satırı güncelle (sohbet başına **tek satır**, compact sayısı artar).

`<chat-slug>`: kullanıcının sohbete verdiği ad → kısa kebab-case. Bilmiyorsan **sorma**,
ana konudan türet ve `_chat.md` içine "türetildi" diye not düş.

---

## Ne zaman yazılır — 3 tetikleyici

| Tetikleyici | Ne zaman | Güvenilirlik |
|---|---|---|
| **PROAKTİF** (Hard Rule 10) | Bağlam ~%70 veya uzun işe girmeden önce — kendiliğinden | ✅ en güvenilir, birincil kural |
| **PreCompact hook** | `/compact` veya otomatik sıkıştırma **öncesi** | ⚠️ yazacak tur kalmayabilir — hatırlatıcıdır |
| **SessionStart:compact hook** | Sıkıştırmadan **hemen sonra**, özet context'teyken | ✅ asıl yazma anı — burada tur VAR |

Hook'lar `.claude/settings.local.json` içinde, **repo başına** kurulu.
⚠️ Hook yalnızca Claude Code **o reponun klasöründe** başlatıldığında çalışır. Başka repo cwd ise
tek garanti **Hard Rule 10**'dur.

Kurulu olduğu repolar → aşağıdaki [§ Hook kurulum durumu](#hook-kurulum-durumu).

---

## Zorunlu bölümler

```markdown
# Compact — <chat adı> · #<n>

**Sohbet:** <kullanıcının verdiği ad>  · **Session id:** <id>
**Tarih:** YYYY-MM-DD · **Sıra:** bu sohbetin <n>. compact'i
**Kapsanan aralık:** <ilk istekten şu ana / önceki compact'ten sonrası>
**Aktif iş dosyası:** <link — ör. manuel-reeskont/progress/progress-N.md>

## 1. Kullanıcının istekleri (sırayla, kendi kelimeleriyle)
[Her isteği kısalt ama ANLAMINI değiştirme. Verilen KARARLAR ve CEVAPLAR aynen buraya.]

## 2. Yapılanlar
[Dosya seviyesinde. Komut çalıştırıldıysa komutun aynısı.]

## 3. Kararlar ve gerekçeleri
| Karar | Alternatif | Neden bu seçildi |
|---|---|---|

## 4. Karşılaşılan hatalar
| Hata (AYNEN) | Kök neden | Çözüm / durum |
|---|---|---|

## 5. Ölçülen gerçekler
[Tahmin değil — dosyadan/çıktıdan doğrulanan bulgular, dosya yolu + satır.]

## 6. Açık kalanlar
[Kullanıcı kararı bekleyenler, doğrulanmamış varsayımlar, yarım işler.]

## 7. Sonraki session'a devir
[İlk yapılacak somut iş.]
```

---

## Sohbetler

| Sohbet | Klasör | Compact | Tarih | Konu |
|---|---|---|---|---|
| Manuel Reeskont — analiz & mimari | [manuel-reeskont-analiz/](manuel-reeskont-analiz/) | 2 | 2026-08-12 | Doküman analizi, MD katmanı, mimari kararı (Common → **iptal**, WebUI direkt) |
| Manuel Reeskont — kodlama (Faz 1–3) | [manuel-reeskont-kodlama/](manuel-reeskont-kodlama/) | 4 | 2026-08-17 | Faz 1–3 kod, canlı DB analizi, `accounting-db-script` + `mssql-read` skill'leri · **#3:** Web.UI doküman uyumluluğu (9/9 kapandı) + 🔤 rename `ManuelReeskont` → **`ManualRediscount`** + ölü modül client'ları silindi · MM 74 + JS 334 test yeşil · **#4:** DevExtreme reflection 500 fix (uncommitted), Docker ortam yanıtsızlığı raporu, kullanıcı DB'yi 191 endpoint'e bağladı, menü satırları DB'de var ama ekranda görünmüyor — `ModuleName`/Translation kolonları NULL şüphesi, mssql-read ile araştırılıyor |

---

## Hook kurulum durumu

| Repo | PreCompact | SessionStart:compact | Not |
|---|---|---|---|
| `NetTrex.MM` | ✅ | ✅ | 2026-08-12 kuruldu — **önce hiç yoktu**, bu yüzden compact'ler yazılmamış |
| `NetTrex.Web.UI` | ✅ | ✅ | 2026-08-12 kuruldu |
| `Treasy.MM.UI` | ✅ (eskiden) | ✅ | 2026-08-12 `SessionStart:compact` eklendi + klasör formatına geçildi |
| Diğer repolar | ⬜ | ⬜ | O repoda çalışmaya başlarken kur — şablon: `NetTrex.MM/.claude/settings.local.json` |

> **Cross-repo iş** (ör. Manuel Reeskont) hangi repo cwd olursa olsun compact'i **buraya**
> (`repos/.ai-agent/compacts/`) yazar — tek repoya özel sohbet o reponun kendi `compacts/`'ına.

---

## Kurallar

- Özet **kaybolan detayı** taşır — başka MD'de zaten yazan durum tablosunu tekrar etme, **link ver**.
- Kalıcı bilgi (ADR, tuzak) buraya değil kalıcı evine gider: `PROJECT_CONTEXT.md` § ADR / `MEMORY.md`.
  Buradaki kayıt **olayın anlık fotoğrafı**dır, arşiv değil.
- Dosyaları **silme** — kullanıcı kendisi siler.
