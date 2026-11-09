# 33 — Tutar/oran hassasiyeti, Annex History, f-key enum hatası, Definition create/update EF hataları, API e2e testi

**Tarih:** 2026-10-22 · **Önceki:** [`32`](32-definition-tek-sayfa-info-boolean-fix.md)

## Düzeltmeler
| Belirti | Kök sebep | Düzeltme |
|---|---|---|
| Definition açılınca *"Conversion failed … 'PostOnly' to int"* | `annex/f-key` projeksiyonunda `(int)x.Direction`; kolon `HasConversion<string>` → EF SQL'de `CAST(Direction AS int)` | Enum SQL'den çekilip int'e bellekte çevriliyor |
| *"Invalid object name 'CollateralBusinessDayRule'"* | Lookup script'i yeni tabloyla tekrar koşulmadı | Kullanıcı `2026-10-22-ColManagement-LookupTablolari` script'ini tekrar koşacak |
| Annex History boş + console `Cannot read properties of undefined (reading 'option')` | Paket history grid'ini **`<anaGridId>History`** ID'siyle arıyor; Annex'te `dgAnnexHistory` (olması gereken `dgAnnexesHistory`) | ID + CSS + 10 loc key yeniden adlandırıldı. Definition (`dgCollateralDefinitionsHistory`) zaten doğruydu |
| Tutar/oran hassasiyeti | — | MM `UIConstants.NominalFormat` (`#,##0.00`) tutarlar: Dispute Tolerance, Threshold, MTA, Rounding Amount (min 0); `RateFormatScaleSix` oranlar: Spread, Fixed Rate. Grid + History kolonlarında tutar/tarih formatı |
| ValidFrom varsayılanı | Kullanıcı: ayın 1'i değil | `Trex:ColManagementLogicalDate`'in kendisi (Annex + Definition) |
| **Definition Create** her zaman hata (`CollateralEligibleCurrencyEntity … already being tracked`) ama satırlar yazılıyordu | Alt kayıtlar (PK = `DefinitionId` [+ `CurrencyCode`], `ValueGeneratedNever`) tanım commit'inden sonra FK set edilerek ayrı `Attach`'leniyordu → identity çakışması | Tanım + para birimleri + cash terms **tek graf** `InsertAsync` + tek `Commit` (FK'yi EF dolduruyor). H-096'nın Definition karşılığı |
| **Definition Update** `PK_CollateralEligibleCurrency` / `PK_CollateralCashTerms` ihlali | Aynı anahtar silme + ekleme tek `SaveChanges`'ta → EF INSERT'i önce gönderiyor | Silme sonrası ara `Commit`, sonra ekleme |

## API e2e testi (kullanıcı isteği: 10 annex + 10 annex'li + 10 standalone definition)
- UI Keycloak istediği (`SkipAuthorization=false`) ve tarayıcı olmadığı için test **backend API** üzerinden (UI controller'ları bu uçlara ince aktarım). VS fast-mode container'da süreç kapalıydı → yeni build container içinde geçici başlatıldı, test sonrası durduruldu.
- Senaryo: create → farklı kullanıcıyla verify → get → history; 3 annex + 3 definition update → re-verify → içerik kontrolü; state filtreleri; tüm lookup uçları. Çeşitlilik: Direction 1-3, 4 para birimi, ValidTo boş/dolu, 1-3 scope (Included No dahil), 0/2 margin rule, Rate Type Fixed/Floating/InterestFree, 1-4 eligible currency, IsEnabled false.
- **Tur 1-2:** Definition create/update hataları bulundu (yukarıda). **Tur 3: 158 adım, 1 hata** (yalnız `CollateralBusinessDayRule` tablosu yok). DB doğrulaması sql-log #33.
- Bulunan ek sorun: **Calendar tablosu boş** → `Today w/o deleted`, `Yesterday` ve sonraki filtreler **sonsuz döngü** (H-102). Referans veri kopya script'i 14 tabloya genişletildi (PK tabanlı, ön kontrol sql-log #29-#31).
- Test verisi: 30 Annex (`TST-ANX-%`) + 60 Definition (`TST-DEF-%`) DB'de. Temizlik: `Treasy.ColManagement/.ai-agent/outputs/2026-10-22-ColManagement-TestVeriTemizlik/1-NetTrexColManagement-TestVeriSil.sql`.

## Doğrulama
Rebuild backend + UI **0 hata**. UI ekranları tarayıcıda denenmedi (oturum gerektiriyor).
