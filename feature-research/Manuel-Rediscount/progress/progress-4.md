# progress-4 — Fimple entegrasyon sözleşmesi + alternatif API önerileri

**Tarih:** 2026-08-12 · **Önceki:** [progress-3.md](progress-3.md)
**Tetikleyen istek:** *"dökümandaki verilen fimple apilerini kullan, en sonda da mimari ile işin bitince
`Fimple-docs` ve `FimpleRequests` folderlarının içindeki filelara bak, fimple'daki apiler var,
alternatif olacak mantıklı api varsa öneride bulun — ama **sadece öneride bulunman için** verdim bu folderları"*
**Kural:** Bu dosya progress-3'ün **güncellenmiş tam hali**dir. Öncekiler **düzenlenmedi**.

---

## ✅ YAPILDI (bu tur)

### A. Durum tespiti — "dokümanda verilen Fimple API'leri" YOK

`Manuel Reeskont v1.docx` içindeki `word/document.xml` (50.558 karakter) tarandı:

```bash
unzip -p "Manuel Reeskont v1.docx" word/document.xml | sed 's/<[^>]*>/ /g' > /tmp/mr.txt
grep -o -i "fimple" /tmp/mr.txt | wc -l          # → 0
grep -o -i -E "api/v1|DoAccounting|AccountingType|MessageKey" /tmp/mr.txt   # → 0
grep -o -i -E "muhasebe|reeskont fişi" /tmp/mr.txt | sort | uniq -c          # → 8 muhasebe, 1 reeskont fişi
```

🔴 **Doküman Fimple'dan hiç bahsetmiyor.** Ekranı tanımlıyor, Fimple sözleşmesini tanımlamıyor.
→ Fimple ayağının tek gerçek kaynağı **MM'in mevcut entegrasyonu** (`IFimpleApi.cs`) + **`FimpleRequests` örnekleri**.
Bu boşluk `07-fimple-entegrasyon.md` ile kapatıldı.

### B. Baseline sözleşme ölçüldü

| Ne | Bulgu |
|---|---|
| Çağrılan uç | `POST /Fx/TreasuryTransactions/DoAccounting` (`IFimpleApi.cs:38`) — **hem fiş hem ters fiş** |
| Fimple tarafı | `ScopeKey = CREATE_TREASURY_TRANSACTION`, handler `Fi.Fx.Api/Impl/Command/TreasuryTransactionCommandHandler.cs` (yanıt `ExecutionTrace`'inden) |
| T+0 payload | `LogicalReference` · `AccountingType:"Rediscount"` · `DoAccounting:true` · `TransactionType:"Interbank"` · `AccountingModel{Code:"ThirdPartyEntry", ProcessCode:"ThirdPartyTreasuryAccounting", TransactionWorkgroupId:2, Details[]}` |
| Ters payload | `ReverseMessageKey` (long) · **`ReversAccountingTransactionDate`** · `DoReverseAccounting:true` · **`AccountingModel` YOK** (Fimple orijinalden türetiyor) |
| MM'de ayrıca kayıtlı | `/Accounting/AccountingEntries/DynamicAccounting` (**2 metot**), `/Accounting/CreateAccountings/DirectDynamicAccounting` (2 metot) |

### C. 🔑 Üç kritik çıkarım

1. **`ReversAccountingTransactionDate` VAR → dokümanın `ReverseValueDate`'i uygulanabilir** →
   **C-08'e kanıt**: alanın ikinci tanımda kaybolması dokümanın kopyala-yapıştır hatası, **teknik kısıt değil**.
   ⚠️ Fimple'ın alan adı **yazım hatalı** ("Revers"), DTO'da **aynen** yazılmalı (`R-17`).
2. **Ters fiş `ReverseMessageKey` olmadan kesilemez** → `MessageKey` zinciri durum türetmenin (M-08) temeli.
3. **Ters fişte `AccountingModel` yok** → ters fiş ucu **ucuz**, T+0 fişi pahalı.

### D. 6 Fimple tuzağı belgelendi (`FT-01`…`FT-06`)

| # | Tuzak |
|---|---|
| **FT-01** 🔴 | Yanıtta **İKİ `MessageKey`**: `Value.MessageKey` (fişin, `…152832`) ve zarf `MessageKey` (mesajın, `…894208`). Ters fiş **`Value.MessageKey`** istiyor → yanlışı persist edersen ters fiş **hiç çalışmaz** |
| **FT-02** 🔴 | Tip tutarsızlığı: yanıtta **string**, istekte **number** (19 hane → `long` şart, `int` taşar) |
| **FT-03** | `Success` + `Reasons[]` HTTP 200 içinde → doğru `RefitExtension` overload'u şart (MM MEMORY 2026-07-23 tuzağı) |
| **FT-04** | Fimple **saga** çalıştırıyor (`SagaOperationStatus`, `InitializeSagaInstance`) → telafi senaryosu var |
| **FT-05** ⭐ | Trace'te **`IdempotencyActionFilter.cs`** — **Fimple'da idempotency altyapısı VAR ama 3 döküman dosyasında "idempotenc" kelimesi HİÇ YOK** (`grep -i` → 0) |
| **FT-06** | Örnekler `v1.34.0-beta.40` / 2026-06-25 · döküman 2026-04-06 → sürüm sapması olabilir |

### E. 9 alternatif API önerisi çıkarıldı (`Ö-01`…`Ö-09`)

`Fimple-docs-Accounting.txt` (99 KB) tarandı, ~60 endpoint listelendi. Manuel Reeskont'a yarayabilecekler:

| # | Uç | Çözdüğü |
|---|---|---|
| **Ö-01** ⭐⭐⭐ | `POST /Accounting/AccountingEntries/DoManualBulk` | **C-07** — N satır → **1 çağrı** |
| **Ö-02** ⭐⭐⭐ | `BatchAccountingEntries/Queue` → `/{DraftId}/DoAccounting` → `GET /{DraftId}` | **C-07 asenkron** — dokümanın kayıp "6.1 Asenkron İşlem Mimarisi" bölümünün hazır cevabı; `Processing` durumu buna oturuyor |
| **Ö-03** ⭐⭐ | `PUT /AccountingEntries/ByMessageKey/{MessageKey}/Reverse` | Ters fiş — baseline çalışıyor, **değiştirme**; ama Ö-01/Ö-02 benimsenirse **gerekli hale gelir** |
| **Ö-04** ⭐⭐ | `MultipleAccounting` + **`/Compensate`** | Kısmi hata telafisi + Regenerate'in "geri al" adımı. ⚠️ **muhasebe kararı** |
| **Ö-05** ⭐ | `CancelAccounting` (`DELETE_ACCOUNTING`) | Fiş iptali — **kullanma**, ters fiş denetim izi bırakıyor |
| **Ö-06** ⭐⭐⭐ | `ByMessageKey` · `ByMainMessageKey` · `ByParameters` · `InfoByParameters` · `ManualAccountingEntries` | **M-08** + doküman §4.5 *"backend durumu yeniden doğrular"* → **gerçek** doğrulama. ⚠️ liste sorgusunda değil, `executions` anında |
| **Ö-07** ⭐ | `DynamicAccounting` — **MM'de zaten kayıtlı** | Kıyas noktası; döküman: *"reverse business key gönderilirse ters fiş keser"* |
| **Ö-08** ⭐⭐⭐ | Idempotency header (belgesiz, `FT-05`) | **`T-02` çift tıklama = çift fiş** kökten çözülür |
| **Ö-09** | `AccountingEntries` · `UpdateDescription` · `Copy` · `CreditBalanceControl` · `DepositAccounts` · `View/ByParameters` | **İlgisiz** — neden ilgisiz olduğu yazıldı |

### F. Önerim (karar kullanıcının)

| Faz | Ne |
|---|---|
| Faz 1 | Fimple **hiç çağrılmıyor** → değişiklik yok |
| Faz 2 | **Baseline ile başla** — kanıtlı, sıfır maliyet, **satır bazlı hata izolasyonu bedelsiz** (`ADR-MR-007`) |
| Faz 2 · paralel | `Ö-08` (idempotency) + `Ö-06` (ön-doğrulama) → **baseline'ı bozmadan** eklenir, en yüksek fayda/risk oranı |
| C-07 asenkron çıkarsa | `Ö-02` birinci, `Ö-01` ikinci aday → `İ-54` dispatcher dikişinin arkasına |
| Sorulmadan yapılmaz | `Ö-04` `Compensate` · `Ö-05` `Cancel` — **muhasebe/denetim** kararı |

> 🔑 **Ödünleşme tespiti:** Baseline'ın "N çağrı" dezavantajı aynı zamanda **avantajı** — her satır bağımsız,
> biri patlarsa diğerleri etkilenmiyor. Bulk'a geçiş kısmi hata raporlamasını Fimple'ın yanıt şekline
> bağımlı kılar → `Ö-S-02` cevaplanmadan bulk'a geçilmemeli (`R-19`).

### G. Üretilen / güncellenen dosyalar

| Dosya | Ne |
|---|---|
| **[`07-fimple-entegrasyon.md`](../07-fimple-entegrasyon.md)** ⭐ YENİ | 9 bölüm: kaynaklar · baseline uç · T+0 payload alan-alan analizi · ters fiş + 3 çıkarım · yanıt tuzakları (`FT-01`…`FT-06`) · **9 öneri (`Ö-01`…`Ö-09`)** · karşılaştırma tablosu · önerim · **8 Fimple sorusu (`Ö-S-01`…`Ö-S-08`)** · **5 risk (`R-16`…`R-20`)** |
| [`05-faz-plani.md`](../05-faz-plani.md) | **İ-09** (Faz 0 — `R-16` MessageKey doğrulaması) + **İ-65…İ-68** (Faz 2 — baseline, ön-doğrulama, idempotency, asenkron) · § 11 sayaçları (Faz 0: 9 · Faz 2: 19) · başlık linki |
| [`00-PANO.md`](../00-PANO.md) | Dosya haritasına `07` satırı |
| [`skills/manuel-reeskont.md`](../../skills/manuel-reeskont.md) | ADIM 0 tablosuna satır: **Fimple'a giden kod yazmadan önce `07`'yi oku** |

---

## 🔵 YAPILIYOR

Yok.

---

## ⬜ YAPILACAK

### Değişmeyen bloke edenler

`C-01` · `C-07` · `C-08` · `C-02` (iş birimi) · `04-sorular.md` § B'deki **7 teknik karar** (Selim) ·
`06-sozlesme.md` **dondurulacak**. Tam liste → [`05-faz-plani.md`](../05-faz-plani.md) § 8.

### Bu turda eklenen yeni işler

| # | İş | Kime |
|---|---|---|
| **İ-09** | `R-16` — MM hangi `MessageKey`'i persist ediyor? (`Value.MessageKey` mi zarf `MessageKey` mi) — **salt-okunur, şimdi yapılabilir** | ben |
| `Ö-S-01…08` | **8 soru Fimple ekibine** — bulk hazine bağı · kısmi hata · idempotency header · Corporate `TransactionType` · `TransactionWorkgroupId` · batch yaşam döngüsü · reverse valörü · sürüm sapması | Selim → Fimple |
| — | `Ö-04` / `Ö-05` **muhasebe birimine** sorulacak (ters fiş vs Compensate vs Cancel) | Selim → muhasebe |

### Faz sırası değişmedi

Faz 0 (İ-01…İ-09) → Faz 1 (İ-10…İ-45, **A/B'siz**) → Faz 2 (İ-50…İ-68) → Faz 3 → Faz 4 → Faz 5.

---

## Kararlar bu turda

| Karar | Gerekçe |
|---|---|
| **Fimple baseline DEĞİŞMİYOR** (`/Fx/TreasuryTransactions/DoAccounting`) | Kanıtlı çalışıyor, gerçek istek/yanıt elde; satır izolasyonu bedelsiz; alternatiflerin hazine bağı **belirsiz** |
| Öneriler **ADR'ye çevrilmedi** | Kullanıcı *"sadece öneride bulunman için"* dedi — kabul edilirse ADR yazılır |
| `Ö-06` ve `Ö-08` **baseline'a ek** olarak önerildi, alternatif olarak değil | İkisi de mevcut ucu bozmadan eklenebiliyor, en yüksek fayda/risk oranı |
| `Ö-04`/`Ö-05` teknik karar sayılmadı | Ters fiş / Compensate / Cancel arasındaki fark **mali tablo ve denetim izi** farkı |
