# 24 — Annex / CollateralDefinition: UI ↔ Backend sözleşmesi MM'e hizalandı

**Tarih:** 2026-10-15 · **Faz:** 11 (UI ekranları, devam) · **Repolar:** `Treasy.ColManagement` (backend) + `Treasy.ColManagement.UI`

## Belirti
`localhost:5105/Annex/Index` ve `/CollateralDefinition/Index` açılıyor, ardından "Error: Not Found" toast'u,
grid boş ("No data to display", "-1 items"), "+" butonu pasif. Network: `/base/GetStates` 404.

## Kök sebepler (MM.UI / NetTrex.MM ile karşılaştırma)
| # | Bulgu | MM | ColManagement (önce) |
|---|---|---|---|
| 1 | `/base/GetStates` 404 — paket JS'i (`@treasy/flow`) senkron çağırıyor | `Controllers/BaseControllers/BaseController.cs` var | **yoktu** → eklendi |
| 2 | Select response alan adı | `ProductDefinitions` (UI ile aynı) | backend `AnnexListItems` / `CollateralDefinitionListItems`, UI `Annexes` / `CollateralDefinitions` → grid hep `null` |
| 3 | Create/Update gövdesi | iç içe `{ ProductDefinition: {...}, StateMaker }` | backend **düz** (`BaseAnnexRequest`), UI iç içe gönderiyor → tüm alanlar boş |
| 4 | Verify/Delete/Reject state'i | handler `CrudType.X` ile **kendisi** belirler | handler `request.ActionId/StateId` bekliyordu, UI hiç göndermiyor (0) |
| 5 | `form.ts` Get yanıtı | controller `Json(response.Data.X)` döner, JS doğrudan kullanır | JS `response.Annex` okuyordu → undefined (3 ekran) |
| 6 | Delete handler | `StateMaker` atar | atamıyordu |

## Değişiklikler
- **Karar (kullanıcı):** backend MM şekline çekilsin.
- Backend: `CrudType` enum (`Data.Core/Enums`), Annex+Definition `Create/Update` request'leri iç içe model
  (`AnnexCreateModel`/`AnnexUpdateModel`, `CollateralDefinitionCreateModel`/`UpdateModel`), `Delete/Verify/Reject/Undo`
  yalnız `BaseMakerCheckerRequest` (Id+StateMaker), `BaseAnnexRequest`/`BaseCollateralDefinitionRequest` silindi,
  handler'lar `States.Input` / `States.Edit` / `CrudType.*` kullanıyor, validator'lar iç içe modele taşındı,
  list response'ları `Annexes`/`CollateralDefinitions`.
- UI: `BaseController.cs` eklendi; 3 `form.ts` Get yanıtını doğrudan kullanıyor; `launchSettings`/`appsettings`
  `ColManagementApi` portu `58267` → `5061` (docker'da `docker-compose.override.yaml` ezdiği için etkisiz).

## Doğrulama
`dotnet build` backend Api: 0 hata · UI Web: 0 hata · `tsc --noEmit`: yalnız yerel `@types/jquery` eksikliği (docker kurar).
🔴 **Çalışma zamanında doğrulanmadı** — docker rebuild + tarayıcı testi kullanıcıda. Unit test yok (kullanıcı kararı K-30).

## Açık kalanlar
- "+" butonu pasifliği **kanıtlanamadı**: docker'da `SkipAuthorization: "false"` + CommonApi cluster'da → yetki menüden
  geliyor; `FrameworkMenu` satırları (script 3) cluster Common DB'sinde yoksa/Redis `ModuleMenu:*` cache'i bayatsa
  buton pasif kalır. `GetMenu` yanıtı (292 B) şüpheli.
- FKey uçları (`customer/annex/collateral-definition/portfolio select-f-key`) backend'de yok → form dropdown'ları boş.
- TxnTransaction: wire adları uyumlu, ama state `FlowState`/`BaseColManagementTransactionRequest` ile çalışıyor —
  MM `MmTransaction` akışıyla ayrıca karşılaştırılmadı.
- Backend'de `ActionId/StateId/StateDate` alanları `BaseMakerCheckerRequest`'te duruyor (JobCron kullanıyor).
