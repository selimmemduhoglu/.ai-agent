# 27 — Transaction MM flow desenine çekildi; Annex/Definition History GET

**Tarih:** 2026-10-16 · **Faz:** 4/11 · **Çıktı:** backend `Api.Model/ResponseRequest/Services/Transaction/Deal`, UI `Core/Models/TxnTransaction`, `TxnTransactionController`, `form.ts`, `Index.cshtml`, `outputs/.../8-NetTrexCommon-Flow-DML.sql`

## Bulgu (kontrol turu)
- Annex/Definition: MM `ProductDefinition` ile birebir (state engine `States` 16-30 + `IStateEngine.ProcessAction`); tek fark History POST/body (MM GET/query).
- Transaction: MM `MmTransaction` flow'unu (Netix.Core.Flow ComplexFlow) kullanması gerekirken Create/Update/Get/Select düz `BaseIdentityRequest`/`ResponseBase`, UI Verify/Reject/Delete `request.Transaction` null (NRE), Create'te StateId/StateMaker/StateDate/FlowId boş, Select/Get `FlowItem` değil (AvailableActions yok), Index `GetCanUserCreate` çağırmıyor.

## Değişiklikler
- Annex/CollateralDefinition: backend `history` `[HttpGet]`+`[FromQuery]`, Refit `[Get]`+`[Query]`.
- Backend Txn: `TxnTransactionBaseModel/CreateModel/UpdateModel : FlowItem`; Get/Select modelleri `FlowItem`; Create/Update/Get/Select request'leri `BaseColManagementTransactionRequest` (nested `Transaction`; Get `IQueryRequest`, Select `IQueryFilterRequest`); tüm response'lar `BaseFlowResponse`; Create/Update/Get/Select handler `FlowHandler` (Create/Update `UpdateStates(model)`; Select `StateFilterExpressionCreator.GetFlow` filtresi); Verify/Reject/Delete'e kayıt-yok kontrolü (`GetEntityAsync` null döner). Tarihler `DateTime` (DevExtreme DateBox ISO gönderir, `DateOnly` reddederdi; Annex ile tutarlı).
- UI Txn: request'ler `BaseFlowRequest`/`BaseFlowFilterRequest`, response'lar `BaseFlowResponse`, modeller `FlowItem`; controller MM gibi: `Index` `GetCanUserCreate`, Create `ActionId=INSERT`, Update/Delete/Verify/Reject önce `Get` + `ApplyFlowState`; `form.ts` `{Transaction: ...}`; grid `FlowColumnsWithMakerChecker`.
- `8-NetTrexCommon-Flow-DML.sql` (yeni): FlowSet + FlowRequestMap + FlowTransition, MM flow set'inden klon.

## Doğrulama
Backend solution build 0 hata, UI build 0 hata. 🔴 Çalışma zamanında DENENMEDİ; script 8 çalıştırılmadı. Unit test yok (projede test klasörü boş).

## Açık kalanlar
- Script 8 NetTrexCommon'da koşulmalı + Redis FlowSet/FlowTransition cache temizliği; `FlowRequestMap`/`FlowTransition` kolon adları DerivSwp emsalinden alındı, canlı şema doğrulanmadı.
- Kullanıcı profilleri (maker/checker) MM'le aynı flow kurallarına bağlı.
- `MinimumAmount` Get handler'da hâlâ doldurulmuyor; Txn formunda Currency/SettlementType/PaymentInstructionType/SSI lookup'ları yok (`form.ts` TODO).
- Update artık flow'dan geçiyor ama Detail satırı üretimi (K-44) hâlâ yok.
