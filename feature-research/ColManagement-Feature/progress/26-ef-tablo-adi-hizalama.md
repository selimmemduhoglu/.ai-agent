# 26 — EF `ToTable` adları DDL'e hizalandı

**Tarih:** 2026-10-16 · **Faz:** 4/11 · **Çıktı:** `Treasy.ColManagement/Code/Data/NetTrex.ColManagement.Data.Repository/DbContext/EfConfiguration/**` (11 config) + `outputs/2026-10-14-ColManagement-Kurulum/6-NetTrexColManagement-DML.sql`, `CREATION_SCRIPT.md`

## Yöntem
Kullanıcı `1-NetTrexColManagement-DDL.sql`'de tablo adlarını değiştirdi (MM/Common öneklerini kaldırdı). DDL tek gerçek kaynak
olduğu için EF config'ler DDL'e çekildi. CoreDataSlice tabloları adını `NetTrex.Core.Data` paketinden alıyor — paket DLL'inin
string literal'leri okundu: `Calendar/Chart/Currency/CurrencyPair/DateBasis/FXRate/FXRateDetail/HalfWorkingDay/Holiday/InterestRate/InterestRateDetail/Point`
zaten DDL ile aynı, dokunulmadı.

## Değişiklikler
| Config | Eski | Yeni |
|---|---|---|
| AccountingEntryConfiguration | `accEntry` | `AccEntry` |
| AccountingGeneratedAccountRuleEntityConfiguration | `accEngineGeneratedAccountRule` | `AccEngineGeneratedAccountRule` |
| BitMaskConfiguration | `DefBitMask` | `BitMask` |
| PortfolioInstrumentConfiguration | `PrfInstrument` | `PortfolioInstrument` |
| ProductInstrumentConfiguration | `PrdInstrument` | `ProductInstrument` |
| PortfolioConfiguration | `PrfPortfolio` | `Portfolio` |
| JobCronConfiguration / JobCronHistoryConfiguration | `defJobCron` / `defJobCronHistory` | `JobCron` / `JobCronHistory` |
| CustomerConfiguration | `cusCustomer` | `Customer` |
| CorporateTypeEntityConfiguration | `defCorporateType` | `CorporateType` |
| CorporateDetailTypeEntityConfiguration | `defCorporateDetailType` | `CorporateDetailType` |

Ek: script 6 DML `defJobCron` → `JobCron` (yeni DDL'e karşı patlardı). `CREATION_SCRIPT.md`'de eski adlar + script 5 "BİLEREK BOŞ" satırı güncellendi.

## Doğrulama
Geçici konsol projesiyle (scratchpad, repoya girmedi) gerçek `EfDbContext` modeli (`ApplyConfigurationsFromAssembly` + `ApplyCoreDataModel`)
döküldü ve DDL ile kıyaslandı: **50 EF tablosunun 50'si DDL'de aynı adla var**; DDL'de olup EF'te olmayan yalnız `DefNumberGen`/`DefRefNumGen` (entity'siz sayaçlar).
Build 0 hata. Koddaki raw SQL / test'lerde eski ad geçmiyor (grep).

## Açık kalanlar (bu turda DOKUNULMADI)
- 🔴 `TxnTransactionDetail.TxnTransactionEntityId`: EF modelinde gölge FK var, DDL'de yok. Sebep: `TxnTransactionDetailConfiguration:52` `HasOne(Transaction).WithMany()`,
  `TxnTransactionConfiguration:92` `HasMany(Details).WithOne(Transaction)` — aynı navigation iki ilişkide. Detay satırı okunurken/yazılırken `Invalid column name` bekleniyor. Öneri: `.WithMany(x => x.Details)`.
- CoreData entity'lerinde (`Calendar.CalNo`, `Holiday.CalNo`, `*.StateMaker` null'luk, `CurrencyPair.OrderNo/IsCalculatedPair`) ve `MarketCustomerMap.StateId` null'luk farkı: DDL yorumlarına göre MM'e göre bilinçli; dump `mapper=null` ile alındı, `ApplyMappingFixes` etkisi ölçülmedi.
