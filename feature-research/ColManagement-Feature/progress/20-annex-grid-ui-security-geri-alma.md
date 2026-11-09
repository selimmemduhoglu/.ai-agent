# 20 — CollateralPosition devreye girdi, Annex alt-grid UI'si, Security tamamen geri alındı

**Tarih:** 2026-10-14

## 1. `CollateralPosition` artık gerçek çalışıyor (Cash-only)

Entity + EF config önceki turda vardı ama hiçbir handler onu okumuyor/yazmıyordu — `Cash.CurrentBalanceBefore`
hep `0` sabitti (kod yorumu: *"Yeni thread'in ilk hareketi - once bakiye yok"*). Şimdi:

- `TxnTransactionFactory.CreateAsync` → yeni hareket için `(DefinitionId, MarginType, CurrencyCode)` ile
  pozisyonu okuyup gerçek `CurrentBalanceBefore`'u set ediyor.
- `TxnTransactionVerifyHandler` → `IsActiveState` (Opening) dalında pozisyonu **artırıyor/azaltıyor**
  (Increase/Decrease), `else` (Delete-verify) dalında **ters çeviriyor**. Satır bulunamazsa INSERT,
  bulunursa UPDATE. 🔴 **Bilinen sınır:** satır-bazlı oku-sonra-yaz, atomik `UPDLOCK`/`MERGE` değil —
  aynı asset'e eşzamanlı iki Verify gelirse yarışma riski bilerek kabul edildi (DB script'i yok, sonraki
  turda ele alınacak).
- `TxnTransactionGetHandler` → `CurrentBalance`'ı artık pozisyondan gerçekten okuyor (önceden hep `0`'dı).

## 2. Annex Product Scope / Margin Rule — backend + UI tamam

Backend: `AnnexProductScopeModel`/`AnnexMarginRuleModel` (nested) `BaseAnnexRequest`/`AnnexModel`'e
eklendi, `CreateAnnexHandler`/`UpdateAnnexHandler` (replace-all 2 seviyeli: önce rule'lar sonra scope'lar
silinir, sonra scope'lar + rule'ları sırayla eklenir) ve `GetAnnexHandler` (scope+rule'ları yükleyip
nest eder) wire edildi.

UI: `Treasy.ColManagement.UI.Core`'da model sınıfları zaten vardı (Faz 11'de scaffold edilmiş, hiç
kullanılmıyordu — Razor'da "ProductScopeTodo" placeholder duruyordu). Gerçek grid'ler eklendi:

- `_Form.cshtml`: placeholder'ın yerine 2 boş `<div>` (Product Scope + Margin Rule).
- `form.ts`: `$(selector).dxDataGrid({...})` ile **JS'ten dinamik grid construction** — bu projede
  (ve emsal aldığı Treasy.MM.UI'de) **ilk kez** kullanılan bir desen, çünkü nested bir koleksiyonu
  bir popup içine inject edilen formda düzenlemek için DevExtreme Form'un `.Form<T>()` fluent API'si
  yetmiyor (yalnız tekil nesne alanları için). Prototipteki "+Add Product" / "+Add Rule" modallerini
  elle inşa etmek yerine DevExtreme grid'in **kendi `editing: {mode:'popup'}` özelliği** kullanıldı —
  stabil, dokümante, test edilmemiş custom popup lifecycle riski yok.
  - Margin Rule grid'i, Product Scope grid'inde seçili satırın `MarginRules` dizisine **aynı referansla**
    bağlanıyor — CRUD orada direkt o diziyi mutate ediyor, ayrı bir sync kodu gerekmiyor.
  - Product/SubProduct/Currency seçenekleri **statik liste** (gerçek bir katalog ucu yok, prototipteki
    gibi) — TODO olarak işaretli.
- `_Preview.cshtml`: salt-okunur 2 ayrı `DataGrid<T>` (server-render, `Model.Annex.ProductScopes` /
  `.SelectMany(x => x.MarginRules)` ile local binding — mevcut `EligibleCurrenciesPreview` deseniyle aynı).

**Doğrulama:** `dotnet build` (backend + UI) → 0 hata. `npm run typecheck` → yalnız **önceden var olan**
jQuery `$` tip tanımı eksikliği (bu dosyalardaki 2 yeni `$(...)` çağrısı da aynı, zaten bilinen gap'e
düşüyor — yeni bir hata kategorisi değil).

## 3. 🔴 K-54 — Security tamamen geri alındı

Kullanıcı: *"Security ile alakalı hiç bir geliştirme yapmana gerek yok istemiyorum gerek olmadığına
kanaat getirdik"* → *"security kısımlarını istemiyorum onlardan vazgeçtik... sadece Cash yapısıyla
devam edicez"*.

Bu turda önce TAM bir Security-side backend yazılmıştı (CollateralDefinition için 3 yeni entity —
Eligibility/Valuation/Settlement — + EF config + model + Create/Update/Get handler dallanması;
TxnTransaction için `TxnTransactionSecurityEntity` + `Factory`/`Verify`/`Update`/`Get` dallanması +
`CollateralDefinitionDataManager.GetForSecurityTransactionAsync`). Kullanıcı mesajı gelince **aynı
oturumda tamamen geri alındı**:

- 12 yeni dosya silindi (entity/config/model).
- 3 nav prop (`CollateralDefinitionEntity`), 4 DbSet (`EfDbContext`), 3 `HasOne` bloğu
  (`CollateralDefinitionConfiguration`) kaldırıldı.
- 8 enum (`CollateralSecurityScope/Type`, `CollateralIssuerType`, `CollateralPriceSource/Type`,
  `CollateralHaircutMethod`, `CollateralIncomeTreatment`, `CollateralCorporateActionHandling`)
  `CollateralEnums.cs`'ten çıkarıldı.
- `TxnTransactionCreateCommand`/`Result`, `TxnTransactionFactory`, 3 Request DTO (Create/Update/Get),
  4 Handler (Create/Verify/Update/Get) ve 2 Validator **Cash-only** hallerine geri döndürüldü —
  ama **CollateralPosition wiring'i (yukarıdaki §1) korundu**, çünkü o Security'ye değil Cash'e ait.
- `grep -rln "CollateralSecurity\|TxnTransactionSecurity"` → **0 sonuç**, temiz.

**Ders:** Security kapsamı iş birimi onayı olmadan tahmin edilmemeliydi — dökümanda `CollateralType`
enum'ının `Security` seçeneği durduğu için "er ya da geç gerekecek" varsayıldı, ama kullanıcı Faz 1'i
**Cash'e kilitleme** kararı verdi. `CollateralType.Security` enum değeri **kaldırılmadı** (ekranlarda
zaten seçim sunulmuyor, DB'ye gitmiyor) — yalnız ona özel hiçbir kod yazılmayacak.

## 4. Doğrulama

`dotnet build Treasy.ColManagement.sln` → 0 hata. `dotnet build Treasy.ColManagement.UI.sln` → 0 hata.
`npm run typecheck` (UI Web) → yalnız önceden bilinen jQuery `$` eksikliği, yeni hata yok.
`grep` ile Security kalıntısı taraması → temiz.

## 5. Açık kalanlar

- `TxnTransactionSelectHandler`'daki eksik state filtresi (TODO, `FlowEntity`/`IMakerCheckerEntity`
  arayüz uyuşmazlığı).
- `TxnTransactionDetail` (K-44, verify-sonrası edit → Detail satırı) — hâlâ yazılmadı.
- Pozisyon upsert'teki eşzamanlılık riski (satır-bazlı oku-yaz, atomik değil) — DB script aşamasında
  ele alınacak.
- DB script'leri — A-08/A-09/A-10 hâlâ açık, bu iş dışında.
