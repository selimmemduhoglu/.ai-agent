# 17 — PO Toplantı #3 Sentezi · Opening-Reverse Muhasebe · İlk Entity/Configuration Katmanı

**Tarih:** 2026-10-13

## 1. Ne yapıldı

### a) PO toplantısı #3 sentezi
- [`bilgi-bankasi/11-ui-ekran-rehberi.md`](../bilgi-bankasi/11-ui-ekran-rehberi.md) yazıldı — PO'nun
  `Dinamik-Ekran/index.html` prototipi (`data-key`/`data-control`/`data-required` işaretli) + ses kaydı 3
  transcript'i (ASR, ~250 satır) birlikte okunup 3 ekranın (Annex/Definition/Transaction) tam alan listesi,
  formülleri (`app.js`'ten) ve iş akışı kuralları tek dosyada toplandı.
- `02-DURUM.md` ve `bilgi-bankasi/07-kararlar-ve-sorular.md` güncellendi: `A-21` (ürün kataloğu: MM dinamik +
  diğerleri hardcode) ve `A-24` (AnnexMarginRule ayrı tablo) kapandı; `K-48`..`K-53` eklendi (Opening+Reverse
  dışında muhasebe yok · forward batch yok · Status 2 seçenekli · Direction sabit enum · CashTerms'ten
  settlement/account çıktı · Annex/Definition verify-sonrası-edit kuralı).

### b) Opening'in Reverse'i — Accounting/Delete pipeline'ı
Kullanıcı kararı: *"reeskont zaten yok, maturation zaten yok. Reverse de revaluation'ın reverse'ü değil
opening için yapılacak."* OptionsFX'in `Accounting/Delete` deseni (Opening+Revaluation+Interbank dalları
olan tam hali) **Opening-only** olacak şekilde trimlenip taşındı:
- `IDeleteAccountingService` + `DeleteAccountingPipelineContext`/`DeleteAccountingServiceContext` +
  `DeleteAccountingMakerCheckerModel`
- 5 step: Prepare (`GetNonReversedOpeningWithTransactionIdAsync`) → CustomerExternalSync
  (`SendDynamicReverseAccounting`, Interbank dalı yok — Opening pipeline'ındaki K-46 kararıyla tutarlı) →
  ReverseOpening (zaten ported olan generic `IAccountingReverseFactory` ile debit/credit flip) →
  PersistChange (`UpdateReverseIdAsync` + yeni `TDMUpdateFlowFieldsForDeleteModel`) → InternalSync (Kafka)
- `IAccountingReverseFactory`/`AccountingReverseCreateFactoryContext` zaten OptionsFX'ten birebir taşınmış
  ve DI'da kayıtlıymış (önceki oturumdan) — yeniden yazılmadı, olduğu gibi kullanıldı.

### c) Yanlış önkoşulla yazılmış BOD/EOD scaffolding temizlendi
Önceki oturumda "Batch'i BOD/EOD item'larla tamamla" isteği üzerine periyodik Revaluation/Maturation
muhasebesi var sanılarak scaffold edilmişti (`IMaturationAccountingService`, `MaturationBatchItem`,
`MaturationContexts`). Bugünkü netleşmeyle (K-48) bunlar **hiç gerekmiyor** — kısmen zaten silinmiş
bulundu (muhtemelen IDE/kullanıcı tarafı), kalanlar temizlendi:
- `ITransactionDataManager`'dan 4 ölü `GetPending*` metodu + `TDMPendingTransactionResults.cs` (3 kayıt, hiç
  implementasyonu yoktu) silindi
- `IAccountingDataManager`'dan `GetNonReverseRevaluationWithTransactionIdAsync` /
  `GetNonReversedMaturationWithTransactionIdAsync` / `GetVerifiedOpeningByDateRangeAsync` + concrete
  gövdeleri + arayüzde hiç olmayan yetim `GetLastActiveRevaluationAsync` silindi
- `IHelper.GetRevaluationReverseType()` + `FrameworkParameterConstants.ReverseType` silindi
- **Dokunulmadı:** `IAccountingManager`/`AccountingType` enum'ı ve Accounting-engine katmanındaki
  Maturation/Revaluation modelleri — bunlar OptionsFX'in paylaşılan, jenerik muhasebe motoru yüzeyi
  (ExerciseSettlement/PremiumSettlement ile aynı statüde, K-26/K-31 "bütün yapı taşınır, kullanılmayan
  zararsız dursun" ilkesiyle)

### d) İlk entity + EF configuration katmanı
Excel v5'in **per-tablo sheet'lerinden** (UML özet diyagramı eksik/bayat çıktı — bkz. §2) birebir: 10 tablo,
entity + `IEntityTypeConfiguration` ikilisi olarak yazıldı. **Yalnız entity/config — Repository/Handler/
Controller yok**, kullanıcı isim/tip onayı verene kadar.

| Grup | Tablolar |
|---|---|
| Annex | `Annex` (IDENTITY, `MakerCheckerEntity`) · `AnnexProductScope` · `AnnexMarginRule` (FK → `AnnexProductScope.Id`, **Annex'e değil** — bkz §2) |
| Definition | `CollateralDefinition` (IDENTITY, `MakerCheckerEntity`) · `CollateralEligibleCurrency` (composite PK) · `CollateralCashTerms` (PK=FK, 1:0..1) |
| Transaction | `TxnTransaction` (**DefNumberGen**, yeni ortak `FlowEntity` tabanı) · `TxnTransactionCash` (PK=FK) · `TxnPaymentInstruction` (versiyonlu: `TxnId`+`InstructionVersion`) |
| Bakiye | `CollateralPosition` (composite PK, History yok, K-15 zorunlu) |

**Yeni platform parçası:** `Data.Domain/Shared/FlowEntity.cs` — OptionsFX'in kendi projesinde tuttuğu
(`NetTrex.OptionsFX.Data.Domain.Shared.FlowEntity : IFlowEntity`) sınıfın birebir portu. `TxnTransaction`
basit `MakerCheckerEntity`'den DEĞİL bundan türüyor çünkü Excel'in StateId'si `bigint` + Previous*/FlowId/
LastActionId/PreviousActionId alanları var — Annex/Definition'ın 3 alanlık basit maker-checker'ından
**daha zengin bir flow geçmişi** taşıyor (Create→Verify→Edit→Verify döngüsü, K-44).

**Yeni enum dosyası:** `Data.Core/Enums/Collateral/CollateralEnums.cs` — `CollateralDirection`,
`CollateralType`, `CollateralMarginType`, `CollateralMarginParty`, `CollateralRoundingMethod`,
`CollateralTransactionType`, `CollateralFxRateSource`, `CollateralCashRateType`,
`CollateralCompoundingMethod`, `CollateralDayCount`, `CollateralPaymentFrequency`,
`CollateralBusinessDayRule` — hepsi `nvarchar` kolonlara `.HasConversion<string>()` ile yazılıyor (K-51:
sabit kod listesi, dinamik master tablo değil).

**Ortak tablolar** (`CusCustomer`→`CustomerEntity`, `PrfPortfolio`→`PortfolioEntity`,
`SettlementType`/`PaymentInstructionType`) MM/OptionsFX'ten **zaten** önceki oturumda taşınmıştı — yeniden
yazılmadı, doğrudan referans alındı. `Currency` CoreDataSlice paketinden geliyor
(`NetTrex.Core.Data.Domain.Common.Definitions.Currency.CurrencyEntity`, `Code` doğal PK) — OptionsFX'in
`TxnMmEntityConfiguration`/`CurrencyDataManager`'ı ile ilspycmd üzerinden tip doğrulandı.

## 2. 🔴 Ölçülen tuzak — UML özet diyagramı BAYAT, per-tablo sheet'ler esas

`00_UML_Diyagram` sheet'i "canlı, formülle okunuyor" yazsa da `Annex`'in `RevisionNo` kolonunu hiç
göstermiyordu ve `AnnexMarginRule`'ın FK'ini `AnnexId → Annex.Id` gösteriyordu — oysa `AnnexMarginRule`'ın
**kendi sheet'i** `ProductScopeId → AnnexProductScope.Id` diyor (`🆕 v5` etiketli, UI/transcript'le de
tutarlı: "Add Rule her zaman seçili Product Scope context'ini kullanır, kullanıcıdan tekrar istenmez").
Formül hücreleri muhtemelen satır eklenince yeniden hesaplanmamış. **Ders:** Excel'den entity çıkarırken
özet diyagram değil, **her tablonun kendi sheet'i** okunmalı — bu oturumda 9 sheet (`Annex`,
`AnnexProductScope`, `AnnexMarginRule`, `CollateralDefinition`, `CollateralEligibleCurrency`,
`CollateralCashTerms`, `TxnTransaction`, `TxnTransactionCash`, `TxnPaymentInstruction`) + `CollateralPosition`
tek tek açılıp doğrulandı.

## 3. Bilinçli bırakılanlar / sıradaki adım

- **`TxnTransactionDetail` yazılmadı** — Excel v5'te hâlâ yok (`A-27` açık, "Excel v6'da tasarlanacak").
  K-40/K-44'ün gerektirdiği master-detail yapı entity seviyesinde henüz yok; icat edilmedi, bilerek
  bekletiliyor.
- **Security tarafı** (`CollateralSecurityRule/ISIN/Terms`, `TxnTransactionSecurity`,
  `CollateralSettlementMap`) yazılmadı — K-17 (Faz 1 = yalnız nakit).
- **SSI master** yok — `TxnPaymentInstruction`'daki `WeSendSsiId` vb. alanlar şimdilik navigasyonsuz
  `long?` (Excel'de de "🔴 SSI master (yeni)" notu var, henüz tasarlanmadı).
- Repository/DataManager/Handler/Controller katmanı **yazılmadı** — kullanıcının *"isimlendirmelerine ve
  tiplerine baktıktan sonra DB'ye script ile atarız"* sözü gereği, entity/config ilk onay turunu bekliyor.
- `Delete`/Reverse akışının **tetiklendiği yer** (TxnTransaction'ı "Delete" işaretleyip Verify eden
  handler) henüz yok — `IDeleteAccountingService` hazır ama çağıran yok.

## 4. Doğrulama

`dotnet build Treasy.ColManagement.sln --no-restore` → **0 hata** (937 uyarı, hepsi önceden var olan
nullable/unused-parameter uyarıları, bu oturumun eklediği dosyalardan kaynaklı değil).
