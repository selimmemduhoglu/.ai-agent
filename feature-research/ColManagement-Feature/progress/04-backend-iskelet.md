# 04 — Backend İskeleti (Faz 3)

**Tarih:** 2026-10-08 · **Faz:** 3 · **Repo:** `NetTrex.Collateral` (hedef ad `NetTrex.ColManagement`)
**Çıktı:** `Code/NetTrex.ColManagement.sln` — **54 proje**, `dotnet build` **0 hata**

---

## Yöntem

🔴 **K-01 değişti — dosya kopyalamadım, ÖLÇÜP ÜRETTİM.**

Önceki plan *"kullanıcı OptionsFX dosyalarını kopyalar, Claude temizler"* idi. Bunun yerine
OptionsFX'in yapısı **ölçüldü** ve iskelet sıfırdan üretildi:

1. 54 `csproj` okundu → `Sdk`, `ProjectReference`, `PackageReference` çıkarıldı
2. `Directory.Build.props` · `Directory.Packages.props` · `UnitTests/Directory.Build.props` · `NuGet.config` okundu
3. Bağımlılık grafiği çıkarıldı → **zincir deseni** görüldü
4. Aynı graf `NetTrex.ColManagement` adlarıyla üretildi

**Neden kopyalamak yerine üretmek daha iyi çıktı:**

| Kopyalama | Üretme |
|---|---|
| 🔴 OptionsFX `appsettings.json`'da **canlı DB parolaları düz metin** (`Password=Ph4+Gnr2ut`) — temizlenmeyi bekler | Parola **hiç gelmedi** |
| OptionsFX iş kodu gelir, sonra silinir — artık kalma riski | Kod **hiç gelmedi** |
| `grep -ri "optionsfx"` ile kalıntı avı gerekir | 🟢 Kalıntı **yapısal olarak imkânsız** |
| `BaseMmRequest.cs` gibi yanlış dosya adları taşınır | Yeni adlar baştan doğru |
| Mükerrer paket satırı taşınır | Üretirken **düzeltildi** |

⚠️ **Bedeli:** OptionsFX'in `Extensions/`, `appsettings` yapılandırması ve `Startup` gövdesi
gelmedi — bunlar **Faz 5**'te OptionsFX'e bakılarak yazılacak. İskelet için gereksizdi.

---

## 🔑 Ölçülen yapı: zincir deseni

Her proje **tam olarak bir** önceki projeye referans veriyor. Zincirin başı (`*.Core`) paketleri ve
**başka grupların toplayıcı projesini** alıyor. Dairesel bağımlılık yapısal olarak imkânsız.

```
X.Core → X.Model → X.ResponseRequest → X.Abstractions → X.Mapper → X.Services → X
```

| Grup | Adet | Zincir başı neye bağlı | Sapma |
|---|---:|---|---|
| **Data** | 8 | — (yalnız paket) | zincirde fazladan `Domain`; toplayıcı `Data → Domain + Repository`; `Services` yerine `Repository` |
| **Accounting** | 6 | `Data` | `ResponseRequest` **yok** |
| **Common** | 7 | `Accounting` + `Data` | zincir dışı bağımsız **`Common.Kafka`** |
| **Api** | 6 | `Common.Services` + `Data` | `Abstractions` **yok**; `Api` **[Web SDK]** |
| **Batch** | 7 | `Common.Services` | `Abstractions` yerine **`Batch.Items`**; `Batch.Api` **[Web SDK]** |
| **Consumer** | 7 | `Common.Kafka` + `Common.Services` + `Data` | `Consumer.Api` **[Web SDK]** |
| **UnitTests** | 13 | — | `UnitTests/<Grup>/` alt klasörleri |

**Grup sırası:** `Data → Accounting → Common → {Api, Batch, Consumer}`

---

## Değişiklikler

| Dosya | Durum |
|---|---|
| `Code/NetTrex.ColManagement.sln` | 🆕 54 proje, 7 çözüm klasörü + 5 test alt klasörü |
| `Code/Directory.Build.props` | 🆕 `net10.0` · `Nullable` · `ImplicitUsings` |
| `Code/Directory.Packages.props` | 🆕 OptionsFX'ten; 🔴 **mükerrer `NetTrex.Core.Parameter` 10.0.1 temizlendi** (10.0.4 kaldı) |
| `Code/UnitTests/Directory.Build.props` | 🆕 test paketleri merkezî |
| `Code/NuGet.config` | 🔄 **OptionsFX'inki ile değiştirildi** — MM'inkinde `TreasyNuget` feed'i **yoktu**, `Treasy.QuGet` oradan geliyor |
| 41 üretim + 13 test `csproj` | 🆕 3-10 satır (merkezî paket yönetimi sayesinde) |
| 3 Web projesi: `Program.cs` + `Startup.cs` + `appsettings.json` | 🆕 minimum — Web SDK `Main` ister |
| `README.md` | 🔄 ColManagement |
| `.ai-agent/CLAUDE.md` · `PROJECT_CONTEXT.md` · `MEMORY.md` | 🔄 ColManagement + ölçülen proje haritası |
| `Treasy.Collateral.UI/.gitignore` | 🆕 `Treasy.MM.UI`'den + AI blokları |

---

## Doğrulama

```
dotnet restore NetTrex.ColManagement.sln   → 54/54 restored
dotnet build   NetTrex.ColManagement.sln   → Build succeeded. 0 Error(s)
```

- ✅ `.ai-agent/` · `CLAUDE.md` · `.claude/` **iki repoda da** gitignore'da
  (`git check-ignore` ile tek tek doğrulandı; `git status` yalnız `README.md` + `.gitignore` + `Code/` gösteriyor)
- ✅ `Treasy.QuGet` paketi restore oldu → `TreasyNuget` feed'i doğru
- ⚠️ Restore'da `NU1903` uyarıları: `System.Security.Cryptography.Xml` 8.0.2 **bilinen yüksek önemde zafiyet**.
  Transitif bağımlılık (OptionsFX'te de var). Üretime çıkmadan önce bakılmalı — **bu fazın işi değil**

---

## Kararlar

| # | Karar | Gerekçe |
|---|---|---|
| **K-26** | 🔄 **K-01 revize: dosya kopyalanmadı, yapı ölçülüp üretildi** | Parola/ölü kod/kalıntı riski **tamamen** ortadan kalktı. Kopyalamanın tek gerçek kazancı olan "paket sürümlerini okumak" zaten ölçümle elde edildi |
| **K-27** | Tüm gruplar (Batch · Consumer dahil) **şimdi** kuruldu | Zincir **mimarinin kendisi**. Sonradan eklemek `.sln`'e ve bağımlılık grafiğine tekrar tekrar dokunmak demek; boş csproj bedava |
| **K-28** | `NuGet.config` **OptionsFX'ten**, MM'den değil | MM'de `TreasyNuget` yok → `Treasy.QuGet` restore edilemezdi. Sessizce sonraki fazda patlardı |

---

## Açık kalanlar

| # | Ne | Nereye |
|---|---|---|
| — | `Startup.cs` gövdeleri (DI, Swagger, CORS, `AddSchemaMapping`) | **Faz 5** |
| — | `appsettings.json` gerçek değerleri (bağlantı, Kafka, parametre API) | **Faz 5** · 🔴 parola repoya **yazılmaz** |
| — | Repo adı `NetTrex.Collateral` → `NetTrex.ColManagement` | Kullanıcı · patron toplantısı sonrası |
| `A-08` | Modül kodu (`CM`?) — kodda henüz kullanılmadı | Faz 0 |
| — | `NU1903` zafiyet uyarısı | Üretim öncesi |
