# 19 — CollateralDefinition backend CRUD + TxnTransaction CRUD tamamlandı + UI tutarlılık düzeltmesi

**Tarih:** 2026-10-14

## 1. CollateralDefinition — backend CRUD tamamı

Annex'in 2026-10-14'te kurulan deseni (`MakerCheckerEntity` + `IStateEngine.ProcessAction` +
JobCron'dan uyarlanmış History/Undo) birebir tekrarlandı:

- `CollateralDefinitionBase`/`CollateralDefinitionEntity`/`CollateralDefinitionHistory` 3'lü
  Base/Entity/History ayrımı (`Data.Domain/Collateral/CollateralDefinitionEntity.cs`)
- `CollateralDefinitionHistoryConfiguration` (JobCronHistoryConfiguration deseni)
- `ICollateralDefinitionRepository` / `ICollateralDefinitionHistoryRepository` + implementasyonlar
- 9 Handler (Select/Get/Create/Update/Delete/Verify/Reject/Undo/History) + `CollateralDefinitionController`
  (`api/collateral-definition`)
- **Create/Update'in nested child yazımı:** `EligibleCurrencies` (çoklu) + `CashTerms` (tekil, opsiyonel)
  header commit'inden **SONRA** ayrı `InsertAsync`+`Commit` turlarıyla yazılıyor — `entity.Id` header
  commit'ten önce `0` olduğu için FK'ler sırayla kuruluyor. Update'te `EligibleCurrencies` **tamamen
  silinip yeniden yazılıyor** (replace-all), `CashTerms` var/yok durumuna göre upsert/delete.
- "Used by transaction" kilidi: Update/Delete, `IRepository<TxnTransactionEntity>.AnyAsync(x =>
  x.DefinitionId == id)` **EXISTS** ile reddediyor (Annex'teki `AnnexId` kilidinin aynısı).
- Build: **0 hata**, ilk denemede (Annex turunda öğrenilen `InsertAsync`/`UpdateAsync` 1-arg imzası +
  `using Netix.Core.Repository;` dersi baştan uygulandı).

## 2. TxnTransaction — kalan CRUD (Select/Get/DetailList/Update/Delete/Reject)

🔴 **Önemli ayrım, Annex/Definition'dan FARKLI:** `TxnTransactionEntity : FlowEntity`
(`Netix.Core.Flow.Model.Entity.IFlowEntity`), Annex/Definition'ın tabanı olan
`Netix.Core.Flow.StateEngine.IMakerCheckerEntity` **DEĞİL**. Bu yüzden:
- `StateFilterExpression.Get<T>()` TxnTransaction için **kullanılamaz** (generic constraint uyuşmuyor) —
  `TxnTransactionSelectHandler` şimdilik filtresiz tüm kayıtları döndürüyor, kod içinde TODO ile işaretli.
- Delete/Reject **state-makine değil, düz `UpdateStates(FlowItem)` çağrısı** — MM'in gerçek
  `TransactionDeleteHandler`/`TransactionRejectHandler`'ı okunarak doğrulandı (ikisi de: map + `UpdateStates`
  + `Update` + Commit, **muhasebe çağrısı YOK**). Yalnız Verify, `IsActiveState`/`IsUnverifiedState`'e göre
  Opening/Delete muhasebesine dallanıyor (daha önce tamamlanmıştı).
- **TxnTransaction'ın Undo'su YOK** — MM'in Transaction/Deal vertical'ında da yok (dosya listesiyle
  doğrulandı: Create/Delete/Get/History/Reject/Rollover/Select/Update/Verify, Undo hiç yok).
- `TxnTransactionUpdateHandler`: header + `Cash` alanlarını yerinde günceller. **K-44 (verify-sonrası her
  edit bir `TxnTransactionDetail` satırı üretir) bilerek UYGULANMADI** — `CollateralPosition` (running
  balance) olmadan Detail'in `CurrentBalanceBefore/After`'i hesaplanamıyor, kod içinde TODO ile işaretli.
- `TxnTransactionController` (`api/transaction`): `select`/`get`/`detail-list`/`create`/`update`/`delete`/
  `verify`/`reject` — 8 action.
- Build: **0 hata**.

## 3. UI tarafında bulunan ve düzeltilen tutarsızlık

Bu session'da daha önce (Faz 10/11'de) `Treasy.ColManagement.UI`'de TxnTransaction'ın Delete/Reject/Undo
request modelleri **yanlışlıkla Annex/Definition'ın düz `BaseMakerCheckerRequest<T>` kalıbıyla** yazılmıştı.
Backend'in gerçek `TxnTransactionDeleteRequest`/`RejectRequest`'i (nested `FlowItem`-şekilli
`TxnTransactionVerifyModel`, `Verify` ile **paylaşılan** aynı model) yazılınca bu fark netleşti. Düzeltme:

- `TxnTransactionDeleteRequest`/`RejectRequest` (UI Core) → `BaseIdentityRequest<T>` + nested
  `Transaction: TxnTransactionVerifyModel` olacak şekilde yeniden yazıldı.
- `TxnTransactionUndoRequest`/`UndoResponse` (UI Core) **silindi** — bu entity'de Undo yok.
- `ITxnTransactionApi` (UI Business, Refit) → `Undo` metodu kaldırıldı, gerçek backend ucuna karşılık
  gelen `Update` metodu eklendi (`TxnTransactionUpdateRequest`/`Response`, backend'in düz şekliyle birebir —
  yeni yazıldı, UI Core'da önceden hiç yoktu).
- `TxnTransactionController` (UI Web):
  - `Index()`'teki `RejectUndoAction = nameof(Undo)` satırı kaldırıldı (grid artık Undo butonu göstermeyecek).
  - `Delete`/`Reject` action'ları artık `request.Transaction.StateMaker = ...` set ediyor (eski
    `request.StateMaker`/`request.Id = request.Key` satırları zaten **derlenmezdi** — `BaseIdentityRequest<T>`
    yalnız `Id` taşıyor, `Key`/`StateMaker` yok).
  - `Update` action'ı artık gerçek `/transaction/update`'e gidiyor (eski stopgap `Create`'i tekrar
    çağırma hilesi kaldırıldı).
  - `Undo` action'ı tamamen silindi.
- Doğrulama: `dotnet build Treasy.ColManagement.UI.sln` → **0 hata** · `npm run typecheck` (Web) →
  yalnız **önceden var olan** jQuery `$` tip tanımı eksikliği hataları (3 ekranın hepsinde ve
  `@treasy/client` paketinin kendi kaynağında da var — bu session'ın değişikliğiyle **ilgisiz**, yeni
  hata eklenmedi).

## 4. Kapanmayan / ertelenen (bilerek)

- `TxnTransactionSelectHandler`'da state filtresi yok (yukarıda açıklandı) — TODO kod içinde duruyor.
- K-44 (Detail satırı üretimi) hem backend Update hem UI'de **henüz yok** — `CollateralPosition` tasarımı
  şart koşuluyor, ayrı bir iş.
- DB script'leri (AnnexHistory/CollateralDefinitionHistory dahil) **hâlâ** A-08/A-09/A-10'a bloke.
- Bu iş için **unit test yazılmadı** — K-30 kullanıcı kararı (proje bitene kadar test yok) gereği.
