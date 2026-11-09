# 18 — Transaction Verify Tamamlandı · UI İskeleti (Faz 10-11) · Annex Backend CRUD

**Tarih:** 2026-10-14

## 1. TxnTransaction Verify handler + Opening accounting tek-para-birimli hale getirildi

- `TxnTransactionVerifyHandler` yazıldı — MM'nin `TransactionVerifyHandler`'ıyla birebir aynı kontrol akışı:
  `UpdateStates` → `FlowStateHelper.IsUnverifiedState`/`IsActiveState` dalı → `IOpeningAccountingService`/
  `IDeleteAccountingService`. `FlowEntityExtensions.UpdateStates(FlowItem)` yeni eklendi.
- **Engel çözüldü:** Opening accounting pipeline'ı OptionsFX'in çifte-para-birimi (CCY1/CCY2, SideTypeName/
  OptionTypeName, Interbank/Customer dal ayrımı) modelini taşımıştı — Collateral tek para birimli. MM'nin
  kendi Opening modeli incelenip (`CCY1=CCY2`, `Amount1=Amount2` — aynı-para-birimi çift kayıt için yapısal
  olarak doğru, hile değil) `OpeningAccountingPipelineContextMapper`/`AccountingManagerOpeningAccountingContextMapper`/
  `TransactionDataManagerGetResult`/`TransactionDataManager` yeniden yazıldı. Generic Accounting Engine'e
  (`AccountingEngineModel`, dış paketin kendi floor'u yalnızca `TxnReference/TxnNo/.../PathRuleId`) dokunulmadı.
  🔑 SSI/müşteri-cari-hesap GL çözümlemesi henüz yok (SSI master tablosu yok) — alanlar `null`/raw id,
  kod içinde TODO ile işaretli, uydurulmadı.
- `OpeningAccountingPersistChangeStep`'te gerçek bir hata bulunup düzeltildi: dinamik senkron atlanınca
  `BusinessKey` sessizce `0`'a düşüyordu — artık mevcut değeri koruyor.

## 2. Treasy.ColManagement.UI — Faz 10 (iskelet) + Faz 11 (3 ekran) tamam

Workspace kararı: repo-içi `.ai-agent` **ince pointer** (kullanıcı onayı) — asıl plan burada.

- **Faz 10:** `Treasy.MM.UI` emsal alındı ama **güncel haliyle** — MM.UI `Treasy.MicroUI.SharedDependency`'den
  `Treasy.Pure.*` (NuGet 1.0.1) + `@treasy/*` (npm 1.2.1) paket ailesine geçmiş, `Program.cs` 3 satıra inmiş.
  Core/Business/Web + `docker-compose-ui.dcproj`, port **5105/7105**, vite **6105**, `microCode=ColManagementUI`.
  🔑 **`Treasy.Pure.Client`'ta henüz `IClientColManagementApi` marker'ı yok ama engel değil** —
  `RegisterClientWebApiRefitClients<T>()` public/generic (ilspycmd ile doğrulandı), lokal marker + elle
  `services.RegisterClientWebApiRefitClients<IClientColManagementApi>(configuration, "ColManagementApi")`
  yeterli, paket güncellemesi gerekmiyor.
- **Faz 11 — 3 ekran, üçü de build+Vite bundle+`npm run typecheck` 0 hata:**
  - **Annex:** header CRUD tam (Product Scope/Margin Rule alt-grid'leri bilinçli ertelendi, TODO placeholder).
  - **CollateralDefinition:** Annex ile aynı yapı + `CollateralType=Security` TS'te seçilemez yapıldı
    (`onSelectionChanging` iptal — DevExtreme SelectBox item-level disable desteklemiyor).
  - **TxnTransaction:** Create+Verify UI kontratları **gerçek backend kontratlarıyla alan-alan eşleşecek**
    şekilde yazıldı (Create düz, Verify nested `.Transaction` — backend'in iki farklı şeklini birebir
    yansıtıyor). Increase/Decrease SSI alan-flip TS'te uygulandı (SSI master yok, alanlar placeholder).
  - Ölçülen gerçek bulgu: `@treasy/core/screen-types`'ta `Clone` yok, Clone=`ScreenTypes.Create`'e eşlenir.
- **Docker dosyaları eklendi** (kullanıcı isteği, sonradan): `docker-compose(.override).yaml` + `Dockerfile` +
  `.sln` kaydı, MM.UI'den birebir. ⚠️ Dockerfile'ın `npm test` adımı hiç Vitest testi olmadığı için
  **ilk gerçek `docker build`'de patlayacak** — bilerek, test yazılana kadar.
- `.gitignore` MM.UI ile **byte-birebir** (ilk kopya generic boilerplate çıkmıştı, kullanıcı fark edip düzelttirdi).

## 3. Annex — backend CRUD'un tamamı (Select/Get/Create/Update/Delete/Verify/Reject/Undo/History)

🔑 **Reject/Undo/History bu repoda hiç yoktu** (yalnız Transaction'ın Create+Verify'ı vardı) — MM'in
ProductDefinition'ı + **bu repodaki JobCron** (aynı şeyi zaten yapıyormuş) incelenip JobCron'un deseni
birebir alındı (daha güncel/sade: `BaseMakerCheckerRequest<T>` tek tip tüm aksiyonlarda, `IStateEngine`
doğrudan handler'a inject, ayrı DataManager katmanı yok).

- `IStateEngine.ProcessAction(stateId, actionId)` — ilspycmd ile `Netix.Core.Flow.StateEngine.dll`
  decompile edilip **Insert=1/Update=2/Delete=3/Verify=4/Reject=5/Undo=6** paket-sabiti olduğu kesinleşti
  (MM'in `CrudType` enum'ı bu sabitlerin yerel kopyası, konfigüre edilebilir değil).
  `NetTrex.ColManagement.Data.StateEngine.States`/`StateFilterExpression` zaten generic ve hazır — Annex
  hiçbir yeni state-makinesi kodu gerektirmedi.
- `AnnexEntity` → `AnnexBase`(ortak alanlar)/`AnnexEntity`/`AnnexHistory` olarak refactor edildi (JobCronBase/
  JobCronEntity/JobCronHistory deseniyle birebir — History trigger'la dolar, C# hiç INSERT etmez).
  `IAnnexRepository`/`IAnnexHistoryRepository` (`IRepository<T>` marker, ekstra metot yok).
  Undo, JobCron'un kendi (MM'den daha iyi) deseniyle: son history satırı değil **son VERIFIED history
  satırı**na döner (`States.InputVerified`/`EditVerified`).
  `Update`/`Delete` handler'ları `TxnTransactionEntity.AnnexId` üzerinden **EXISTS** ile "kullanımda mı"
  kontrolü yapıyor (rehber §4.3) — required-navigation INNER JOIN tuzağından kaçınmak için `.Include()`
  + bellek-içi okuma kullanıldı (`.Select()` içinde `x.Customer!.Name` yazılmadı).
- Build 0 hata (backend). **DB script'i yazılmadı** — Annex'in kendi tabloları (ve şimdi `AnnexHistory` +
  trigger'ı) `02-DURUM.md`'deki 3 açık karara (modül kodu/sayaç/DB adı) bağlı, onlar netleşmeden hiçbir
  DDL script'i (bu dahil) yazılmıyor — bilinçli, atlanmadı.

## 4. Açık kalanlar

- CollateralDefinition ve TxnTransaction'ın backend CRUD'u henüz yok (Annex'in deseni hazır, aynısı
  tekrarlanacak).
- Product Scope/Margin Rule UI alt-grid'leri + bunların Annex backend'ine persist edilmesi.
- SSI master tablosu, Customer/Currency/Portfolio/CollateralDefinition FKey uçları (UI'den beklenen,
  backend'de henüz yok).
- `CollateralPosition` Verify-anı `UPDLOCK`/`ROWLOCK` upsert'i — hâlâ yapılmadı, MM'de emsali yok (genuinely
  yeni desen).
