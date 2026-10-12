# Faz 3 — Backend İskelet (OptionsFX'ten kopyala → temizle → yeniden adlandır)

**Durum:** ✅ **BİTTİ 2026-10-08** · **Kayıt:** [`../progress/04-backend-iskelet.md`](../progress/04-backend-iskelet.md)

> 🔄 **Uygulanışı plandan FARKLI oldu (K-26):** dosya kopyalanmadı — OptionsFX'in yapısı **ölçülüp**
> iskelet sıfırdan üretildi. Aşağıdaki "kopyalama sonrası temizlik" adımları **gereksiz kaldı**;
> kalıntı/parola riski yapısal olarak ortadan kalktı. Ölçülen zincir deseni →
> `NetTrex.Collateral/.ai-agent/PROJECT_CONTEXT.md` §3.

> 🔑 **Sıra değişti (2026-10-08, kullanıcı kararı):** Backend iskeleti DB script'lerinden **önce**.
> Gerekçe: Excel patron sunumundan sonra değişebilir; script'i şimdi yazmak iki kez yazmak demek.
> İskelet şemadan bağımsız — entity yazılmadığı sürece DB'ye ihtiyaç yok.

## 1. Amaç

Çalışan, derlenen, **iş mantığı içermeyen** bir .NET çözüm ağacı. İçinde OptionsFX'ten tek bir
kelime kalmamış olacak.

## 2. Önce oku

- [`../bilgi-bankasi/03-uc-proje-karsilastirma.md`](../bilgi-bankasi/03-uc-proje-karsilastirma.md) — neden OptionsFX, hangi yapı
- [`../01-KIMLIK.md`](../01-KIMLIK.md) §2 (proje adları) ve §6 (doğrulama grep'leri)
- [`../../../MODULE-CREATION-GUIDE.md`](../../../MODULE-CREATION-GUIDE.md)

## 3. Neden OptionsFX, MM değil (19 maddelik karşılaştırmanın özeti)

merkezi paket yönetimi (`Directory.Build.props` + `Directory.Packages.props`) · `Data.Domain`
120 → **30 dosya** (`CoreDataSlice`) · pipeline tiplenmiş fluent builder · `Startup.cs` 95 satır,
ölü kod yok (MM'de kayıtsız `Worker` sınıfı duruyor) · DataManager/Repository 72+81 → **42+28** ·
EF config'lerde precision disiplini tam.

## 4. Adımlar

| # | Adım |
|---|---|
| 1 | Kullanıcı OptionsFX **dosyalarını** kopyalar (⚠️ `git clone` değil — geçmiş taşınmaz) |
| 2 | 🔴 `appsettings*.json` → **canlı DB parolaları düz metin** (`Password=Ph4+Gnr2ut`). **İlk commit'ten ÖNCE** temizlenir |
| 3 | Proje/klasör/namespace/assembly yeniden adlandırma → `NetTrex.ColManagement.*` |
| 4 | OptionsFX iş mantığı klasörleri silinir, katmanlar **boş** bırakılır |
| 5 | `Directory.Packages.props`: `NetTrex.Core.Parameter` **iki kez** listeli (10.0.4 + 10.0.1) → düzelt |
| 6 | 🔴 `Api.ResponseRequest/Transaction/BaseMmRequest.cs` — dosya adı MM'den kalma, içindeki sınıf `BaseOptionsFXRequest<T>`. **Aynı hatayı tekrarlama**, dosya adını da değiştir |
| 7 | Docker: `docker-compose.override.yml` servis adları + ortam değişkenleri |
| 8 | Doğrulama grep'leri ([`../01-KIMLIK.md`](../01-KIMLIK.md) §6) |

## 5. 🔴 Derlenir ama runtime'da sessizce patlayan yerler

Derleyici bunları **görmez** — grep şart:
- `appsettings.json` → `Assemblies:Handler` / `Assemblies:Validator` **string** assembly adları
- `Startup.cs` → Scrutor tarama assembly'leri
- Kafka topic adları
- `.sln` içindeki proje **yolları**

## 6. Bitiş kriteri

1. ✅ `dotnet build Code/NetTrex.ColManagement.sln` **hatasız**
2. ✅ `grep -ril "optionsfx\|optfx"` → **0 sonuç**
3. ✅ `appsettings*.json`'da parola/bağlantı dizesi **yok**
4. ✅ Repoda iş mantığı yok (entity/handler/controller boş)

## 7. Çıktı
`../progress/NN-backend-iskelet.md`
