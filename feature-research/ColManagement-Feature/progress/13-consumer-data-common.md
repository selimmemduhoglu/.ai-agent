# 13 — Consumer Tamamlandı · EOD/BatchLog · Not/Doküman · Data/Common Ortak Parçalar

**Tarih:** 2026-10-09 · **Faz:** 5 (devamı) · `dotnet build -t:Rebuild` **0 hata** · 612 `.cs`

**Kullanıcı:** *"Sıradakileri yap, 3 tanesini de. Consumer tarafını tamamen bitir, sonra da Data ve Common projelerini
yapacaksın… MM ve Option'da kullanılan ve bende de kesinlikle kullanılacakları al… sonra da Common'daki Accounting
yapısını alırsın. Backend projesini bir düzenleyelim, sonra UI projesine de biraz bakarız."*

Kural: **MM ∩ OptionsFX** ve ColManagement'ta kesin kullanılacak olan alındı; açıklar düzeltilmedi → `03-HATA-KAYDI` H-071…H-078.

## 1. Consumer — bitti

| | |
|---|---|
| Topic'ler | `customer-insert` · `portfolio-insert` · `corporate-type-insert` (MM'de de var) + `CoreDataSlice` 10 dilim |
| Handler | `CustomerCreateHandler` · `PortfolioCreateHandler` · `CreateCorporateTypeHandler` |
| Request/Model/Mapper/Core | OptionsFX'ten aynen (19 dosya) |
| Data | `CustomerEntity` · `PortfolioEntity` · `CountryEntity` · `CorporateType`/`CorporateDetailType` + EF config + DataManager'lar (Customer, Portfolio, CorporateType ×2, Currency, CurrencyPair) · `ChartRepository` |
| Alınmayan | `IKafkaConsumerService` / `IKafkaConsumerMessageService` / `KafkaConsumerSettingsFactory` (ölü — H-007) |

## 2. Api — EOD + Batch log + Not + Doküman

| Uç grubu | Kaynak | Not |
|---|---|---|
| `EodController` (liste · tarihçe · sayım · güncelle) | OptionsFX (MM'le yalnız biçim farkı) | `BatchDbContext` üstünde |
| `BatchLogController` (ana liste · detay · batch set FKey) | OptionsFX (MM'de de var) | |
| `TransactionNoteController` · `TransactionDocumentController` | OptionsFX | `TxnNote`(+History) · `TxnDocument`(+History) entity/config/DataManager · `DocumentManagementService` |
| DI | `AddDocumentManagementDI` + `IDocumentManagementService` açıldı (Api; Batch'te OFX gibi — H-077) · `DocumentAppSettings:ApiSource` appsettings ×3 (58 anahtar) |

OptionsFX'in `Controller` klasörü bizde `Controllers` (H-011).

## 3. Data / Common — ortak parçalar (MM ∩ OptionsFX)

| Alınan | MM'de | Not |
|---|:-:|---|
| `ProductDefinition` (entity · config · DataManager · DbSet) | ✅ | Id `int` → H-073 |
| `SettlementType` · `PaymentInstructionType` (entity · config · repository) | ✅ | |
| `StateFilterHelper` | ✅ | |
| `TenantModel` | ✅ | |
| `CurrencyService` (+ model) | ✅ | |
| `TransactionSynchronizationDataManager` (`TxnSync`) | — | Fimple muhasebe senkronu kullanıyor |
| Fimple `Auth/Login` modelinin tam hâli (`AppContext`/`TenantContext`/`UserContext`) | — | OptionsFX auth |
| `FimpleDataService` mapper'ları (`Mapper/External/Data`) + müşteri dokümanı modelleri | — | servis daha önce taşınmıştı |
| Common.Core: `Lists` · `SystemConstants` · `CustomerAccountConstants` · `CustomerType` · `Crypto` · `TimeSpanExtension` | — | |
| `RequestTypeCodes` | — | `OptFXTransactionRequest` → **`ColManagementTransactionRequest`** (Common'da FlowSet kaydı gerekecek — H-076) |

**Alınmayan (opsiyona özel ya da karar bekliyor):** Deal (`TxnTransaction` opsiyon entity'si) · Revaluation · CustomerRisk ·
ManualRediscount · Limit (A-13) · Yfr · DerivativeSettlementForm · pricing Engines · Fimple Catalog/KKB · PaymentMessages (A-26) ·
Commission/Tax sabitleri · `TransactionHistoryDataManager` (Txn entity'sine bağlı).

## 4. Common muhasebe yapısı

| Alınan | |
|---|---|
| `Common.Model/Accounting/Shared` | `AccountingCustomerModel` · `AccountingProductModel` · `AccountingTransactionModel` · `AccountingSettlementTypeModel` · `AccountingPaymentInstructionTypeModel` · `AccountingMakerCheckerModel` · `AccountingInterbankPaymentModel` · `AccountingHelperModel` · `AccountingDateBasisModel` · `ConversionModel` |
| `Common.Mapper/Accounting/Shared` | fiş (`AccEntryMain`/`AccEntry`/üretilen kural) + Kafka mesaj + Fimple dinamik muhasebe mapper'ları (önceki tur) |
| Alınmayan | Operasyon servisleri (`Opening`…`Delete`) — ColManagement'ın tek olayı TxnDetail; detail entity'si + nazım kararı (A-25) gelince **Opening deseniyle** yazılacak · `PaymentMessageTransactionModel` + Opening/Exercise TermPayment mapper'ları (opsiyon işlem modeline bağlı — H-078) |

## 5. Doğrulama
```
dotnet build -t:Rebuild → 0 Error(s)
appsettings ×3 → 58/58 anahtar birebir, JSON geçerli
```
⚠️ Çalıştırılmadı.

## 6. Sırada
Backend'de iş tablosundan bağımsız iş **kalmadı**. Sonraki adımlar tablo/iş kararına bağlı:
Annex · Collateral · TxnTransaction + **TxnTransactionDetail** entity'leri → uçlar → TxnDetail muhasebe olayı.
Kullanıcı: *"backend projesini bir düzenleyelim, sonra UI projesine de biraz bakarız."*
