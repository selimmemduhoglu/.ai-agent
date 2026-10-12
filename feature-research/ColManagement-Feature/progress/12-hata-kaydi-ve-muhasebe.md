# 12 — Hata Kaydı Açıldı + Muhasebe Katmanı Taşındı

**Tarih:** 2026-10-09 · **Faz:** 5 (devamı) · `dotnet build -t:Rebuild` **0 hata**

## 1. Yeni çalışma kuralı — K-46

*"Bildirdiğim ama dokunmadıklarım bu tip noktaları da ayrı bir dosyada tutar mısın… madde madde numaralandırarak
gördüğün her problemi, eksikliği ve düzeltilmesi gereken şeyleri… Şu an yapmamamızın sebebi: hem yavaşlamamak hem de
neden bu şekilde yapıldığını bilmiyorum, belki bilinçlidir belki bilinçsizdir. Sen MM ve Option'daki gibi yap, MM'i
önceliklendirerek aynısını geçir gitsin… ben sonra bakacağım ve mantıklı olanları yapacağız."*

→ [`../03-HATA-KAYDI.md`](../03-HATA-KAYDI.md) — **70 madde** (H-001…H-070), her biri OFX/MM sütunlu.
Önceki turlarda düzeltilmiş olanlar `✅` ile duruyor; bundan sonra açık **düzeltilmez**, aynen taşınıp kayda yazılır.
Tek istisna: taşımayı/derlemeyi **engelleyen** durum (ör. H-067 — QuGet kaldırıldığı için zorunlu).

## 2. Muhasebe — OptionsFX'ten aynen

| Katman | Taşınan |
|---|---|
| `Accounting.*` (6 proje) | **Tamamı** — `AccountingManager` · `AccountingService` · `AccountingPathBuilder` · `AccountingValidationService` + validator'lar · engine/entry/rule modelleri + mapper'lar · enum/constraint/exception · DI (OptionsFX birebir) |
| `Common` | `IFimpleAccountingService` + `FimpleAccountingService` · `IFimpleDataService` + `FimpleDataService` · `IAccountingReverseFactory` + `AccountingReverseFactory` · paylaşılan muhasebe mapper'ları (`AccountingEntryMainEntityMapper`, `AccountingEngineGeneratedAccountRuleEntityMapper`, `AccountingEntryMessageModelMapper`, `FimpleAccountingDynamicAccountingContextMapper`) · Fimple muhasebe/veri model + request/response'ları · `IFimpleApi` **tam hâli** · `ResponseRequest/Base` |
| `Data` | `IAccountingDataManager` + `AccountingDataManager` · `TxnSyncEntity` (+config, repository) · `AccountingType` · `PaymentAccountingTypeConstraint` |
| DI | `IFimpleAccountingService` · `IFimpleDataService` · `IAccountingReverseFactory` açıldı |

**Alınmayan (opsiyon operasyon servisleri):** `Common.Services/Accounting/{Opening,Maturation,Premium,Exercise,Revaluation,
RevaluationReverse,RevaluationMirror,MaturationReverse,Delete}` + mapper/model'leri (~5.000 satır). ColManagement'ın tek
muhasebe olayı **TxnDetail değişikliği** (K-44); bu servislerin ColManagement karşılığı detail tasarımı + nazım kararıyla (A-25)
yazılacak. Desen (Service + Prepare/AccountingEntry/Internal/External/PersistChange step'leri) Opening'den alınacak.

**Yöntem:** derleme hatasından eksik tipi bulup OptionsFX'ten kopyalayan döngü (CS0246/CS0103/CS0234/CS1061 → tanımlayan
dosya); opsiyon operasyon klasörleri kara listede. GlobalUsings OptionsFX'le birleştirildi, çözülemeyen 2 satır düştü.

## 3. Hata kaydına eklenen yeni maddeler
H-065 opsiyona özel muhasebe modeli · H-066 path şeması · H-067 QuGet'li PM dalı (MM gibi LCY/FCY'ye indirildi) ·
H-068 `HandleMap` her fişte API + sync-over-async (OFX+MM) · H-069 kullanılmayan Fimple uçları · H-070 `/Fx/` yolu (hata değil, not).

## 4. Doğrulama
```
dotnet build -t:Rebuild → 0 Error(s)
```
Uyarılar: OptionsFX'ten gelen DTO'larda nullable (`CS8618`) + `FlowEntity` (H-041) — aynen bırakıldı.
⚠️ Çalıştırılmadı.

## 5. Sırada (iş tablosundan bağımsız kalanlar)
1. Consumer: müşteri/portföy/ülke/kurum tipi kopyaları (`customer-insert`, `portfolio-insert`, `corporate-type-insert`) — OptionsFX
2. Api: EOD ekran uçları (`GetEodList`, `GetEodHistoryList`, `UpdateEod`) — `BatchDbContext` üstünde
3. `TxnNote` / `TxnDocument` (platform yardımcı tabloları)
