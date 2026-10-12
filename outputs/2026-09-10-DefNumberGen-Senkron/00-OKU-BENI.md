# DefNumberGen senkronu — `LastNumber` = tabloların gerçek max Id'si

> 2026-09-10 · DB: `NetTrexAcc` (varyantı sen yaz) · 🔴 scriptleri **çalıştırmadım**

| Dosya | Ne yapar |
|---|---|
| [0-Kontrol-DefNumberGen.sql](0-Kontrol-DefNumberGen.sql) | Hiçbir şey yazmaz. Her tanım için `SimdikiLastNumber` / `OlmasiGereken` / `AtilanOruntuDisiSatir` raporu + atılan Id listesi |
| [1-Guncelle-DefNumberGen.sql](1-Guncelle-DefNumberGen.sql) | Aynı hesabı yapar, `UPDATE` eder (transaction + TRY/CATCH) |

Önce `0`'ı çalıştır, `AtilanId` listesine bak (gerçekten elle girilmiş mi), sonra `1`'i çalıştır.

---

## Senin iki script'inde bulduklarım

### Script 1 (tek `UPDATE ... FROM ... JOIN`)

| # | Sorun |
|---|---|
| 1 | 🔴 **Çalışmaz.** `UPDATE DefNumberGen ... FROM DefNumberGen d` — hedef tablo base adıyla, `FROM`'daki kopyası alias'la yazılmış. SQL Server bunu iki ayrı tablo referansı sayar: *Msg 8154, The table 'DefNumberGen' is ambiguous.* Doğrusu `UPDATE d SET ... FROM DefNumberGen d` |
| 2 | 🔴 `ISNULL(t.MaxId, 0)` → tablo boşsa `LastNumber = 0` yazar. Bir sonraki insert `0+1 = 1` alır ve **var olan Id'ye çarpabilir**. Boş tabloya dokunmamak lazım |
| 3 | `LastUpdateDate` güncellenmiyor |
| 4 | `BEGIN TRAN` var ama `TRY/CATCH` yok, `XACT_ABORT` kapalı → hata olursa transaction **açık kalır** |
| 5 | 🔴 Asıl derdini çözmüyor: `AccAccountMap` için `MAX(Id) = 12376128` → aynı değeri geri yazar |

### Script 2 (11 ayrı `UPDATE`)

| # | Durum |
|---|---|
| 1 | ✅ Sözdizimi doğru, `LastUpdateDate` var |
| 2 | ✅ `ISNULL(..., LastNumber)` — boş tabloda eski değeri koruyor (script 1'den **daha iyi**) |
| 3 | ⚠️ Transaction yok — 11 UPDATE'in 5'i geçip 6.'sı patlarsa yarım kalır |
| 4 | 🔴 Aynı sorun: `MAX(Id)` körlemesine alınıyor → `AccAccountMap` yine `12376128` |
| 5 | ⚠️ 11 kopya blok; yeni bir tanım eklenince 12. blok elle yazılacak |

---

## Örüntü dışı Id'yi nasıl yakalıyorum

Veriden ölçtüm (`sql-log` #15, #16):

- **Örüntü dışı Id sadece `AccAccountMap`'te var:** `12376128` (StateMaker `PARTNER.TREASY.005@…`, elle girilmiş). Normal blok **24997**'de bitiyor. Diğer 10 tabloda tepe bloğu bitişik.
- **Normal boşluklar** en fazla ~**9.600** (`AccEngineAccountRule`). Absürt olan **12.351.131** → ~1.300 kat.

Sabit eşik kırılgan olurdu, o yüzden **oransal** iki kural birlikte:

```sql
Id > @Kat * OncekiId                                  -- @Kat = 10
AND AdaSatirSayisi * 100 <= ToplamSatir * @AdaYuzde   -- @AdaYuzde = 5
```

**Neden ikisi birden:**

| Örnek | 10 kat kuralı | Ada boyutu | Sonuç |
|---|---|---|---|
| `AccAccountMap` 24997 → 12376128 | 12376128 > 249.970 ✅ | 1 satır / 4030 = %0,02 ✅ | **atılır** — doğru |
| `AccEngineItemCode` 197 → 1195 | 1195 > 1970 ❌ | — | atılmaz — doğru (gerçek blok, 40 satır) |
| `AccEngineDynamicRule` 5555 → 10000 | 10000 > 55.550 ❌ | — | atılmaz — doğru |

Tek başına "10 kat" kuralı `AccEngineItemType`/`ItemCode` gibi meşru sıçramaları yakalayabilirdi;
ada-boyutu kuralı onu kapatıyor. Senin dediğin *"absürt 50 tane Id"* senaryosu da çalışır:
50 satır / 4030 = %1,2 < %5 → yine atılır.

Eşikler script'in başında değişken — istersen oynarsın.

---

## Kararlar

- **Sayaç yalnız canlı tablolardan hesaplanıyor**, `*History` dahil edilmiyor. Sebep: History'nin kendi PK'si var (`HistoryId`), `Id` kolonu silinmiş kayıtların arşivi. `AccEngineDynamicRuleHistory`'de **2.000.290**'a kadar Id var (189 satır, OPT1 kuralları) — bunlar canlıdan silinmiş, sayaç bunlara göre şişirilmemeli.
- **Boş tabloya dokunulmuyor** (`OruntuMaxId IS NULL` → o satır atlanıyor, eski `LastNumber` kalıyor).
- **Değeri düşürmek güvenli**, çünkü düşürülen tek yer `AccAccountMap` ve üstündeki tek satır (12376128) çok uzakta — sayaç 24998'den yürürken oraya asla ulaşmaz.
- `AccEngineDynamicMap` `DefNumberGen`'de **yok** (11 tanım var, o listede değil) — script de eklemiyor.

🔑 **Aynı alışkanlık tekrar ediyor:** OPT1 kuralları da bir zamanlar 2.000.000'lik elle verilmiş
Id'lerle girilmiş. Yani bu script tek seferlik bir düzeltme değil, ara ara koşturulacak bir kontrol.

Sorgular ve ham çıktılar: [`sql-log/accengine-policy-silme/`](../../sql-log/accengine-policy-silme/02-ciktilar.md) (#15–#18)
