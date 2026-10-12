# AccountingEngine — politika ağacı silme scriptleri

> 2026-09-10 · FI · MM · TEST · OPT1 · InvFund
> 🔴 Scriptleri **çalıştırmadım**, uygulayan sensin.

| Dosya | Ne yapar |
|---|---|
| [0-Kontrol-Sayimlari.sql](0-Kontrol-Sayimlari.sql) | **Hiçbir şey silmez**, sayar. `@kod` değişkenini değiştirip 5 politika için de çalıştır |
| [1-Sil-FI.sql](1-Sil-FI.sql) | `TREX/FI` |
| [2-Sil-MM.sql](2-Sil-MM.sql) | `TREX/MM` |
| [3-Sil-TEST.sql](3-Sil-TEST.sql) | `TREX/TEST` |
| [4-Sil-OPT1.sql](4-Sil-OPT1.sql) | `TREX/OPT1` |
| [5-Sil-InvFund.sql](5-Sil-InvFund.sql) | `TREX/InvFund` |

Sıra önemli değil, beşi bağımsız. Her biri tek transaction.
`USE [__PROD_DB_ADINI_YAZ__]` bilerek geçersiz — unutulursa script hemen durur, yanlış DB'de silmez.

---

## Silme sırası

```
AccEngineAccountRule → AccEngineComponent → AccEngineGroup → AccEngineEvent
                     → AccAccountMap → AccEngineDynamicMap → AccEngineItem (alt, sonra kök)
```

**Silinmiyor:** `AccEngineItemCode` (senin kararın) · `AccEngineDynamicRule` (paylaşılan kural havuzu) ·
`AccEngineComponentAccount` / `ComponentType` / `EventType` / `ItemType` / `ModelDefinition` /
`Template` / `Account` (paylaşılan referans) · `AccEngine*History` · `AccEngineGeneratedAccountRule`
(kural değil, üretilmiş fiş) · `DefNumberGen`.

---

## Neden Id'ler önce toplanıyor

Tablolar arasında **FK yok** (tek istisna `Group.EventId`). `AccEngineItem` silinince
Event/Group/Component'e giden yol kopar — join'le arayan sonraki `DELETE` hiçbir şey bulamaz ve
o satırlar **sessizce sahipsiz kalır**. DB'de hâlâ **454 sahipsiz `AccountRule` + 80 `Component` +
5 `Event`** duruyor; muhtemelen geçmişte böyle oluşmuş.

Onun için önce 4 temp tabloya Id toplanıyor, sonra `Id IN (...)` ile siliniyor.

## Neden `LIKE 'TREX/X%'` değil

Kök Path'ler karışık: `TREX/FI` **slash'sız**, `TREX/MM/` **slash'lı**. Ayrıca `LIKE 'TREX/MM%'`
`TREX/MMXYZ` gibi başka bir kökü de yakalar. Kullanılan çapa:

```sql
WHERE Path IN (N'TREX/MM', N'TREX/MM/') OR Path LIKE N'TREX/MM/%'
```

## 🔴 FI özel

İki ayrı FI node'u var — script'in başında not olarak da duruyor:

```
Id 106  Path 'TREX/FI'        <- silinecek olan
Id 1001 Path 'TREX/SEC1/FI'   <- SEC1 ağacının çocuğu, SİLİNMEZ
```

Yukarıdaki çapa `TREX/SEC1/FI` ile eşleşmez. Kontrol scripti bunu ayrıca listeliyor.

---

## Ölçüm (test DB'si `NetTrexAcc` @192.168.10.211 — **prod değil**)

| Politika | Item | Event | Group | Component | AccountRule | AccAccountMap | DynamicMap |
|---|---:|---:|---:|---:|---:|---:|---:|
| FI | 244 | 187 | 524 | 2164 | 4375 | 0 | 0 |
| MM | 129 | 101 | 156 | 338 | 802 | 0 | 1 |
| TEST | 0 | 0 | 0 | 0 | 0 | 0 | 1 |
| OPT1 | 20 | 60 | 108 | 281 | 759 | 568 | 0 |
| InvFund | 28 | 18 | 76 | 76 | 390 | 119 | 1 |

⚠️ Prod'da `TEST` ağacı var, bu DB'de yok → prod sayıları farklı çıkacak.
`0-Kontrol-Sayimlari.sql`'i **atlama**.

Sorgular ve ham çıktılar: [`sql-log/accengine-policy-silme/`](../../sql-log/accengine-policy-silme/01-sorgular.md)
