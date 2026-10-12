# 10 — OptionsFX Altyapısı Taşındı (Data · Batch · Bildirim/Kafka)

**Tarih:** 2026-10-09 · **Faz:** 5 (devamı) · `dotnet build -t:Rebuild` **0 hata** · 250 `.cs`

---

## 0. Kullanıcı düzeltmeleri (önceki turun yanlış okuması)

| Konu | Doğrusu |
|---|---|
| Fimple | 🔴 *"Fimple tamamiyle kullanılacak, onu yanlış anlamışsın."* Transcript'teki "Fimple burada hiç olmayacak" yalnız **ödeme mesajı** bağlamında → **K-43**. `progress/09`'daki A-23 sorusu geçersiz |
| Ödeme | Faz 1'de ödeme sistemi yok; detail'da **"ödeme mesajı gönderildi" bayrağı** (A-26, kesinleşmedi) |
| Scaffolding | *"Bu konu bir dursun sonra bakıcaz"* → A-22 ertelendi |
| İsim | *"ColManagement olsun karar verdiğimiz gibi"* |
| İşin özü | 3 ekran (Annex · Collateral · Txn); **Txn değişmez, her hareket TxnDetail** → **K-44**, tahta `bilgi-bankasi/10` §6b |
| Klasör | `Colleteral-Feature` → **`ColManagement-Feature`** (Excel kapatılınca yapıldı; 15 dosyadaki referans güncellendi, kalıntı 0) |

---

## 1. Ne taşındı (iş tablolarından BAĞIMSIZ altyapı)

Kural: tablo tasarımı kesinleşmediği için yalnız **her modülde aynı olan** platform parçaları.

| Katman | Taşınan |
|---|---|
| `Data.Domain` | `FlowEntity` · `MakerCheckerEntity` · `NewNumberEntity` · `NewReferenceEntity` · `FlowTransitionDataEntity` · Batch ×4 (`BatchItem`/`BatchSet`/`BatchLog`/`BatchLogDetail`) · `JobCron` (+History) · muhasebe ×3 (`AccEntryMain`/`AccEntry`/`AccEngineGeneratedAccountRule`) |
| `Data.Repository` | EF config'leri · `FlowTransitionData`/Batch/JobCron repository'leri · **`BatchDbContext`** (+DI kaydı) |
| `Data.Abstractions` | `IHelper` · `ICommonApi` · `IAccountingApi` · `IChangeTrackerDataService` · sayaç üretici arayüzleri · repository arayüzleri |
| `Data` | `Helper` (ColManagement'e daraltıldı) · `FlowDataProvider` · `ParameterDataProvider` · `AccountingEngineDataFactory` · `RefitExtensions` · `ChangeTrackerDataService` · `NumberGenerator`/`ReferenceGenerator` (+MsSql/Oracle sorgu fabrikaları) · `StateEngine` |
| `Data.Core` | Enum'lar (`EntityColumnType` · `SystemWDFlagType` · `BatchSetType` · `CustomFilter` · `StateFilterType` · `FlowStateConstants`) · `FrameworkParameterExtension` · `RateTypeConverter` · `DataServiceException` · parametre sabitleri (CM. önekli) |
| `Data.ResponseRequest` / `Data.Model` | Flow · Accounting · FrameworkParameter DTO'ları · `AccAccountingMapModel` · State modelleri |
| `Common` | `IFimpleNotificationApi` + servis · `IMessagingService` + `MessagingService` · `IKafkaProducerService` + `KafkaProducerService` · `KafkaTopicConstants` · `AccountingEntryMainMessageModel` · `JsonSerializableExtensions` |
| `Batch` | `BatchRunOperation` · `BatchDataProvider` · `BatchNotificationFacade` · SignalR log stratejisi · Hangfire job factory + BOD/EOD job'ları · `ScheduleJobOperation` · BOD/EOD/Schedule handler'ları · `BatchRunController` · `IndexController` (+`/health`) · `DateTimeCheckBatchItem` · `LogicalDateUpdateBatchItem` |
| DI | `AddData` OptionsFX listesi **açıldı** (Helper · FlowEngine · Refit CommonApi/AccountingApi · `AddQuant`…) · `AddBatchServices` açıldı |

**Alınmayan (OptionsFX'e özel):** CustomerPayment · DerivativeResultForm · SyncMissingTransactionsToLimit ·
Revaluation/Reverse/Maturation/Exercise/Premium batch item'ları · PreciousMetal · Volatility · Document/KKB/Catalog Fimple API'leri ·
`SendNotificationWithDocument` (yalnız türev formu kullanıyordu).
**Henüz alınmayan:** muhasebe servisleri (`AccountingService`/`Manager`/validator) — olay tipleri ve path iş kararına bağlı.

🔑 `AddQuant()` opsiyon fiyatlamasına özel değil: **`ICalendarService`'i** (QuGet) kaydediyor → açıldı.

---

## 2. 🔴 Bulunan açıklar — her biri OptionsFX **ve** MM'de kontrol edildi

| # | Yer | OptionsFX | MM | Sonucu | Düzeltme |
|---|---|:-:|:-:|---|---|
| 1 | `BatchDataProvider.IsWorkingDay` / `IsHalfWorkingDay` | 🔴 sabit `true` | ✅ gerçek kontrol | Batch **tatil günü de koşar** | `ICalendarService.IsWorkingDay` + Core.Data `HalfWorkingDayEntity` sorgusu |
| 2 | `Data/Refit/ToContent()` | 🔴 | 🔴 | API hata dönerse **boş `T`** döner (hata yutulur) + `throw ex` stack'i siler. `FlowDataProvider` null listeyle NRE, `AccountingEngineDataFactory` **boş kural setiyle** devam eder | Hata/boş gövdede `DataServiceException` (HTTP kodu + gövde) |
| 3 | `AccountingEngineDataFactory` | 🔴 | 🔴 | `IsSuccess=false` → sessizce **boş kurallar** → fiş üretilmez, yanıltıcı "zero amount" hatası | `IsSuccess=false` → `DataServiceException` |
| 4 | `MessagingService` | 🔴 | 🔴 | `_ = SendAsync(...)` fire-and-forget — muhasebe fişi mesajı kaybolabilir, çağıran bilmez | `await` |
| 5 | `KafkaProducerService` | 🔴 | 🔴 | Hata `LogInformation(e.Message)` — stack/topic/key yok, Seq'te **Error değil** · Scrutor taraması **scoped** kaydediyor → istek başına yeni Kafka bağlantısı | `LogError(e, Topic, Key)` · **Singleton** · librdkafka log'u `Debug` |
| 6 | `FlowDataProvider.UpsertFlowData` | 🔴 | 🔴 | `DateTime.Now` (Hard Rule 12) | `IDateTimeProvider` |
| 7 | `BatchNotificationFacade` | 🔴 | — | Mail konusu `DateTime.UtcNow` → gece yarısından sonraki EOD **ertesi günün** tarihini taşır · log yoksa `First()` patlar | Konu = `ExecDate` (logical date) · boş log guard'ı |
| 8 | `BatchRunOperation` | 🔴 | — | Kök `BatchItem` tanımlı değilse `First()` → *"Sequence contains no elements"* · 5 kopya metot · BOD'da `PageUID` atanmıyor | Tek `Execute(...)` + anlamlı `BatchServiceException` |
| 9 | `LogicalDateUpdateBatchItem` | 🔴 | ✅ | `(bool)response.Content?.IsSuccess` → HTTP hatasında **NRE** · `OptionName` sabit string | Desen eşleşmesi + `FrameworkParameterConstants.LogicalDateOptionName` (tek kaynak) |
| 10 | `ScheduleHandler` | 🔴 | — | Hangfire kaydı hatası yakalanıp **log'lanmadan** döner | `LogError` |
| 11 | EF config: muhasebe ×3 · `BatchItem` · `BatchSet` | 🔴 | — | DB'de IDENTITY değil (sayaç/seed) ama config `ValueGeneratedNever` yok | `ValueGeneratedNever()` (`04-db-envanteri`) |
| 12 | EF config: `FlowTransitionData` | 🔴 `ValueGeneratedOnAdd` | — | DB'de IDENTITY değil, kod Id'yi kendisi üretiyor | `ValueGeneratedNever()` |
| 13 | `FimpleSendNotificationResponse` | 🔴 `class X(...)` | — | Primary ctor parametreleri **property değil** → yanıt alanları boş | `record` |
| 14 | `States.GetStateIdList` / `GetStateName` | 🔴 | — | Bilinmeyen filtre/Id'de NRE | guard |
| 15 | `BatchSignalRStrategy` | 🔴 | 🔴 | `HubConnectionsEodUrl` yoksa `null` ile bağlantı | Anahtar appsettings ×3 + compose'a eklendi; yoksa anlamlı hata |
| 16 | Batch `/health` | — | — | OptionsFX `IndexController`'da `/health` var, bizim ayrı `HealthCheckController` da vardı → **iki uç aynı rota** = runtime `AmbiguousMatchException` | Bizimki silindi |
| 17 | `Helper.GetFXRateTransactionChartAbmAsync` | 🔴 | — | Transaction ABM'si için **Accounting** ABM anahtarını okuyor | Doğru anahtar |
| 18 | `AccountingEntryMain.Transaction` navigation | — | — | `TxnTransactionEntity` henüz yok; required navigation INNER JOIN tuzağı | Yorumda, Txn entity'siyle açılacak |

### Bildirilen, dokunulmayan
| Konu | Neden |
|---|---|
| Sayaç `int.Parse($"{önek}{sayı}")` — 2 haneli önekle ~10 milyon kayıt tavanı (OptionsFX + MM aynı) | Bu modülün hacmi için uzak; değiştirmek muhasebe Id tipini (int) etkiler |
| `FlowDataProvider` cache boşsa her çağrıda Common API'ye gider, sonucu cache'e **yazmaz** (OptionsFX + MM) | Cache'i Common dolduruyor; performans konusu |
| `BatchSignalRStrategy` `.Wait()` + bağlanamazsa sessizce geçer | Strateji `BatchLogStyleFactory` içinde `new`'leniyor, logger zinciri değişiklik ister |
| `IndexController` `GET /schedule` durum değiştiriyor | OptionsFX/MM sözleşmesi, WebUI çağırıyor olabilir |
| 2 nullable uyarısı `FlowEntity` | Paketteki `IFlowEntity.PreviousStateMaker` non-null, DB kolonu nullable — paket sözleşmesi |

---

## 3. Yeni sabitler / yapılandırma

| | Değer | Not |
|---|---|---|
| Sayaç öneki | **77** (öneri) | Dolu: FX 11/22/33/44 · MM 50/55/120 · DerivSwp 88 · OptionsFX 99 — **A-09 onayı** |
| Hangfire job anahtarları | `ColManagementEod` · `ColManagementBod` | `defJobCron.Key` seed'i bunlarla eşleşmeli (Faz 4) |
| `LogicalDateOptionName` | `ColManagementLogicalDate` | `LogicalDate = "Trex:" + bu` — Common'a giden ad ile okunan anahtar tek kaynaktan |
| `HubConnectionsEodUrl` | appsettings ×3 + compose | 57 anahtar, üç projede birebir |
| `BatchSetType` | yalnız `Eod=1`, `Bod=2` | `BatchSet` seed'i |

## 4. Doğrulama
```
dotnet build NetTrex.ColManagement.sln -t:Rebuild → 0 Error(s); kod uyarısı 2 (bilinçli, §2)
```
- ✅ OptionsFX kalıntı taraması (`OptFX|Derivative|Premium|PreciousMetal|NETTREXOPTFX`) → yalnız yorumlanmış kayıtlar
- ✅ appsettings ×3 → 57/57 anahtar birebir, JSON geçerli
- ⚠️ **Çalıştırılmadı** — DB/Kafka/Redis/Seq yok; `BatchDbContext`'in batch tablolarını bulması Faz 4 script'ine bağlı
