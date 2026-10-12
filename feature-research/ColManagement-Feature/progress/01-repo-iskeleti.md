# Faz 1 — Repo İskeleti ve MD Omurgası

> **Durum:** 🟡 Faz 1a tamam · Faz 1b (çözüm ağacı) devam ediyor
> **Başlangıç:** 2026-10-05

Bu dosya **adım adım** ne yapıldığını kaydeder. Amaç: sıfırdan bir sohbete başlayan birinin
"nereye kadar gelmişiz, hangi dosya neden var" sorusunu buradan cevaplayabilmesi.

---

## Faz 1a — Repo iskeleti + dokümantasyon omurgası ✅

### Adım 1 — Repo durumu tespit edildi
```
NetTrex.Collateral/     → boş, yalnız README.md (placeholder), git kurulu
Treasy.Collateral.UI/   → boş, yalnız README.md (placeholder), git kurulu
remote: http://tfs.netix.com.tr:8080/tfs/NetixCollection/NetTrex/_git/NetTrex.Collateral
```

### Adım 2 — Yöntem kararı: MM toplu kopyalanmadı
Karar ve 4 maddelik gerekçe → [`00-FAZ-PLANI.md` K-01](../00-YOL-HARITASI.md).
Özet: sır sızıntısı riski (MM `appsettings.json`'ında commit'li sırlar var) · Collateral MM'in alt
kümesi (8 modül klasöründen 5'i) · MM'de ölçülmüş ölü/kırık kod · toplu rename'de sessiz runtime hatası.

**Uygulanan ayrım:**
- **Birebir kopyalanan** (iş mantığı içermeyen): `.gitignore`, `Code/.dockerignore`, `Code/NuGet.config`
- **Yalnız şekli alınan** (içerik sıfırdan): `Program.cs`, `Startup.cs`, DI extension'ları,
  `GlobalUsings.cs`, `EfDbContext`, `appsettings.json` → Faz 2

### Adım 3 — Klasör yapısı kuruldu
```
NetTrex.Collateral/
├── .ai-agent/
│   ├── 00-FAZ-PLANI.md          ← 🔴 sıfırdan context'in ana girişi
│   ├── CLAUDE.md                ← repo kuralları (kök CLAUDE.md bunu import eder)
│   ├── PROJECT_CONTEXT.md       ← mimari hafıza (fazlar ilerledikçe dolacak)
│   ├── MEMORY.md                ← tuzaklar + tercihler
│   ├── progress/                ← bu dosya ve kardeşleri
│   ├── reference/               ← (boş) modüle özel referans belgeleri
│   ├── outputs/                 ← 🔴 SQL script'leri buraya yazılır, çalıştırılmaz
│   ├── imports/                 ← (boş) dışarıdan gelen belgeler
│   ├── sessions/ · compacts/    ← (boş) oturum arşivi
│   └── sql-log/                 ← (boş) mssql-read sorgu kayıtları
├── Code/
│   ├── NuGet.config             ← MM'den birebir (nuget.org + NetixNuget + NetTrexNuget)
│   └── .dockerignore            ← MM'den birebir
├── Database/Migrations/         ← (boş) el yazımı SQL, EF migration YOK
├── .gitignore                   ← MM'den birebir (277 satır)
├── CLAUDE.md                    ← 6 satırlık stub, .ai-agent/CLAUDE.md'yi import eder
└── README.md                    ← modül tanıtımı + nereden başlanacağı
```

### Adım 4 — Dokümantasyon omurgası yazıldı

| Dosya | Neden var |
|---|---|
| `00-FAZ-PLANI.md` | **Tek giriş noktası.** 8 fazın tanımı, Faz 1 bitiş kriteri, verilmiş 8 karar (K-01…K-08) gerekçeleriyle, 6 açık soru (A-01…A-06), başvurulacak kaynaklar, çalışma kuralları |
| `.ai-agent/CLAUDE.md` | Repo kuralları — 14 Hard Rule (MM'inkinden MM'e özgü olanlar çıkarıldı, Collateral'a özgü Id/EF-config/CHECK kuralları eklendi), komutlar, skill yönlendirmesi |
| `PROJECT_CONTEXT.md` | Mimari hafıza. Şu an çoğu "⬜ Faz N'de yazılacak" — stack, dikey akış, Id konvansiyonu (3 farklı davranış) ve referans kopyaları bölümleri dolu |
| `MEMORY.md` | MM'de **ölçülmüş** 8 tuzak (EF config insert patlaması, DefNumberGen+enum çifti, trigger kolon sırası, isimsiz DEFAULT, sp_FrameworkAddParameter davranışı, Redis menü cache, consumer doğrulama eksikliği, required navigation INNER JOIN) + 5 tercih |
| `README.md` | Modülün ne olduğu + "önce 00-FAZ-PLANI.md oku" yönlendirmesi |

🔑 **MM'in CLAUDE.md deseni birebir alındı:** kök `CLAUDE.md` yalnızca `@.ai-agent/CLAUDE.md` import eden
6 satırlık stub; asıl içerik `.ai-agent/` altında, böylece repo kuralları `.ai-agent` ile birlikte
versiyonlanıyor.

---

## Faz 1b — Çözüm ağacı ⬜ SIRADA

**Hedef:** `Code/NetTrex.Collateral.sln` + boş `.csproj`'lar, `dotnet build` hatasız geçiyor, iş mantığı yok.

Planlanan modül klasörleri (MM'in 8'inden 5'i — gerekçe `PROJECT_CONTEXT.md` §3):
`Api/` · `Data/` · `Common/` · `Consumer/` · `UnitTest/`
**Alınmayanlar:** `Accounting/` (faz-1 kapsamı dışı) · `MarketIntegration/` (MM'e özgü) ·
`Batch/` (sonraki faz)

⚠️ **Dikkat edilecek:** MM paket sürümlerini proje başına pinliyor (merkezi CPM dosyası yok).
Sürümler MM'in `.csproj`'larından **okunarak** alınacak, tahmin edilmeyecek.

---

## Bu fazda verilen kararlar

| # | Karar | Nerede kayıtlı |
|---|---|---|
| K-01 | MM toplu kopyalanmadı, iskelet seçilerek kuruldu | `00-FAZ-PLANI.md` §5 |
| — | Faz 1 ikiye bölündü: 1a dokümantasyon+iskelet, 1b çözüm ağacı | bu dosya |

## Doğrulama

- [x] Klasör yapısı MM ile aynı desende
- [x] Kök `CLAUDE.md` → `.ai-agent/CLAUDE.md` import zinciri kuruldu
- [x] Sıfırdan context için tek giriş noktası (`00-FAZ-PLANI.md`) yazıldı
- [ ] `dotnet build` geçiyor — Faz 1b bitince
