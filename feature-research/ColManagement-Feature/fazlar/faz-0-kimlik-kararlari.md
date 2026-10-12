# Faz 0 — Kimlik ve İsimlendirme Kararları

**Durum:** 🟡 3 karar açık · **Bloke ettiği:** Faz 3 (script'in içine gömülüyorlar)

## 1. Amaç

Modülün platformdaki kimliğini sabitlemek. Bu kararlar **script metninin içine** giriyor —
sonradan değişirse script, DDL, parametre satırları, menü ve Fimple sözleşmesi birlikte değişir.

## 2. Önce oku

- [`../01-KIMLIK.md`](../01-KIMLIK.md) — adlandırma sözlüğü (tek gerçek kaynak)
- [`../bilgi-bankasi/06-ev-konvansiyonlari.md`](../bilgi-bankasi/06-ev-konvansiyonlari.md) — modülün tanındığı 4 yer

## 3. Kararlar

| # | Konu | Durum | Not |
|---|---|---|---|
| ✅ | Modül adı **ColManagement** | ✅ 2026-10-08 | Kullanıcı kararı, son |
| ✅ | Tablo adlandırma kuralı | ✅ 2026-10-08 | `Collateral`=domain · `ColManagement`=modül kimliği → [`01-KIMLIK.md`](../01-KIMLIK.md) §3 |
| **A-08** | Modül kodu | ⬜ | Öneri **`CM`**. Kullanıldığı yer: `ProductDefinition.ExternalMainProductCode` · `PrfPortfolio.Module` · parametre path · `BatchModuleType` · `General:AvailableModules` |
| **A-09** | Sayaç öneki | ⬜ | 🔴 **iki haneli zorunlu**. MM 55/50/120 · OptionsFX 99 dolu. Seçilen önek `DefNumberGen` seed satırına ve `sp_GetNewRefNumber` çağrılarına girer |
| **A-10** | DB adı | ⬜ | Öneri **`NetTrexColManagement`**. Sunucuda `%Collateral%` / `%ColManagement%` DB'si **yok** (ölçüldü) |
| **A-11** | `CoreDataSlice` üye listesi | ⬜ ölçüm | `NetTrex.Core.Data` DLL'i decompile edilip enum okunacak. Faz 3'ü **kısmen** bloke eder (hangi referans tabloları kurulacak) |

## 4. Bitiş kriteri

[`../01-KIMLIK.md`](../01-KIMLIK.md)'teki ⬜ işaretli satırların **hepsi** ✅ olmuş olacak.

## 5. Tuzaklar

- 🔴 **Üç haneli önek seçme** — tavanı ~999.999 kayda düşürür ve bu **koddan** gelir, kolonu
  `bigint` yapmak kurtarmaz.
- 🔴 **Parametreye Id yazma** — referans tablosuna işaret eden parametre **`Code`** taşır.
  `Id` ortamdan ortama değişir. ⚠️ `Name` de olmaz (`PrdProductDefinition` Id 7 → Code `Pass`,
  Name `Pas`), `ExternalCode` de olmaz (o Fimple'ın dili) — **ama dış çağrıda `ExternalCode` kullanılır**.
- ⚠️ `BatchModuleType` enum değeri **boş** bir sayı olmalı; mevcutlar FI=1 FX=2 Common=3 MM=4
  DerivSWP=5 InvFund=6 OptFX=9 Limit=10.

## 6. Çıktı

[`../01-KIMLIK.md`](../01-KIMLIK.md) güncellenir + `../progress/` altına satır.
