# progress-15 — Menü satırları DB'de doğru ama ekranda görünmüyordu: kök sebep Redis cache, case değil

**Tarih:** 2026-08-17

## Neden araştırıldı

Kullanıcı 2026-08-13 script'iyle eklenen 3 menü satırını (`TreasuryReeskontKey`/`SecurityReeskontKey`/
`InvestmentReeskontKey`) SSMS'te DB'de gördü (Id 2551/2552/2553, IsActive=1, ParentId=129 doğru) ama
ekranda hiçbiri görünmüyordu. Şüphe: script `ModuleName`/Translation kolonlarını boş mu bırakmış.

## Bulgular

1. **`ModuleName` boş değil, ama `'General'` yazılmış** (olması gereken `'GENERAL'` — 282 aktif satırın
   tamamı `GENERAL`/`Accounting`/`DERIV`/`OptionsFX`, hiçbiri karışık case değil).
2. **4 `Translation*` kolonu gerçekten NULL** — incelenen 4 referans satırın (276, 339, 1548, 1551)
   hiçbirinde NULL yok.
3. **Kod doğrulaması (agent, `NetTrex.Common` + `NetTrex.Web.UI` taraması):**
   `GetModuleMenuHandler.cs:217-222` `ModuleName`'i `StringComparison.InvariantCultureIgnoreCase` ile
   karşılaştırıyor → **case önemsiz**, madde 1 red herring.
4. **Asıl sebep:** aynı handler, menü listesini Redis'te kullanıcı bazlı cache'liyor
   (`ModuleMenu:{UserId}`, TTL **8 saat**, `RedisParameterConstants.cs:65`). `FrameworkMenu` INSERT/UPDATE
   tarafında bu cache'i temizleyen **hiçbir kod yok**. Kullanıcı modülü daha önce açtıysa DB güncel olsa
   bile 8 saat eski liste görünür.

Kalıcı kayıt: [`.ai-agent/MEMORY.md`](../../MEMORY.md) § Bilinen Tuzaklar (cross-repo) — yeni madde.
DB kanıtı: [`sql-log/manuel-reeskont-kodlama/`](../../sql-log/manuel-reeskont-kodlama/).

## Aksiyon

- **Öncelik 1 — Redis flush:** `192.168.10.191:30379`'da `ModuleMenu:*` hash'lerini temizle (veya 8 saat
  bekle), sonra tekrar dene. Bu asıl blocker.
- **Öncelik 2 (kozmetik ama önerilir) — DB tutarlılığı:** fix script yazıldı:
  [`NetTrex.MM/.ai-agent/outputs/2026-08-17-FrameworkMenu-Reeskont-ModuleName-Translation-Fix.sql`](../../../NetTrex.MM/.ai-agent/outputs/2026-08-17-FrameworkMenu-Reeskont-ModuleName-Translation-Fix.sql)
  — `ModuleName` → `GENERAL`, 4 Translation kolonu dolduruluyor. **Çalıştırılmadı** (mssql-read: yalnız
  SELECT), kullanıcı DB varyantını (`NetTrexCommon` vs `NetTrexCommon_Dev` vs cluster'ın gerçek DB'si)
  teyit edip kendisi çalıştıracak.

## Açık kalan (compact-3/4'ten devam)

- DevExtreme reflection fix (`ManualRediscountBuilderExtensions.cs`) hâlâ uncommitted, build temiz,
  **live doğrulanmadı**.
- `ui-nettrex` container'ın önceki tur sonundaki yanıtsızlığı (empty reply, sıfır log) — kullanıcı DB
  bağlantısını 191 cluster'ına çevirdiğini söyledi ama container durumu ayrıca tekrar kontrol edilmedi.
- Login/Common-API deploy-skew, Tier-2/3 test kararı — cevapsız.
