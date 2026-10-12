# Faz 1 — Repo İskeleti ve MD Omurgası

**Durum:** ✅ BİTTİ (2026-10-05) · **Kayıt:** [`../progress/01-repo-iskeleti.md`](../progress/01-repo-iskeleti.md)

## 1. Amaç

Repoda iş mantığı olmadan, kurulum dosyaları ve bağlam omurgası hazır olsun.

## 2. Yapıldı

| Dosya | Kaynak |
|---|---|
| `.gitignore` · `Code/NuGet.config` · `Code/.dockerignore` | NetTrex.MM'den birebir |
| `CLAUDE.md` (6 satırlık stub → `.ai-agent/CLAUDE.md` import) | MM deseni |
| `README.md` | — |
| `.ai-agent/` omurgası (`compacts` `imports` `outputs` `progress` `reference` `sessions` `sql-log`) | MM deseni |

## 3. ⚠️ İptal edilen kapsam

**Faz 1b (boş çözüm ağacı) İPTAL.** `.sln` + boş `.csproj`'lar elle kurulmayacak —
Faz 4'te OptionsFX'ten kopyalanacak (K-01 revize). 50+ csproj'u elle yazmak için paket
sürümlerini zaten OptionsFX'ten okumak gerekiyordu.

## 4. ⬜ Faz 0 kararı sonrası yapılacak düzeltme

Repo adı `NetTrex.Collateral` → `NetTrex.ColManagement` olunca:
`CLAUDE.md`, `README.md` ve `.ai-agent/` içindeki yol/ad referansları güncellenir.
