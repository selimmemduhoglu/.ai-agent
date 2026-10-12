# Faz 9 — Değerleme · Limit · Muhasebe · Ödeme Mesajı

**Durum:** ⬜ · **Ön koşul:** Faz 8 · ⚠️ İş birimi toplantısı cevapları gerekli

## 1. Amaç
İşlemin çevresindeki dört yardımcı akış.

## 2. Alt başlıklar

| # | Konu | Tablo | Açık soru |
|---|---|---|---|
| 9a | **Değerleme** | `ColManagementRevaluation` | `SnapshotStage` = ENTRY/VERIFY/EOD/SETTLEMENT. ⚠️ EOD otomatik değerleme faz-1 planında **yok** |
| 9b | **Limit** | `TxnLimitSnapshot` | 🔴 `A-13`: limit servisi faz-1'de mi? Doküman detaylı, transcript'te **teyit yok** |
| 9c | **Muhasebe** | `AccEntryMain` · `AccEntry` · `AccEngineGeneratedAccountRule` + `8-NetTrexAcc-CM-DML.sql` | Kural ağacı `NetTrexAcc`'te |
| 9d | **Ödeme mesajı** | `TxnMessage` · `TxnMessageEvent` · `TxnPaymentInstruction` | 🔴 `A-12`/`A-14` |

## 3. 🔴 Muhasebe tuzakları (ölçülmüş — para kaybettirir)

- 🔴 **Tahakkuk motoru MUTLAK tutar basıyorsa "yeniden üret" = ÇİFT KAYIT.** Persist adımı
  koşulsuz `InsertAsync` yapıyor olabilir, o güne fiş var mı **bakmaz**. Bir muhasebe akışına
  "düzelt/yeniden üret" eklemeden **önce** motorun tutar semantiğini (mutlak mı delta mı) ve
  persist adımının idempotent olup olmadığını **ölç**.
- 🔴 **Fimple bir fişi BİR KEZ tersler.** Düzeltme "ters işaretli YENİ normal fiş" (ayna çifti)
  olarak kesilir. Ayna çifti orijinalin **aynı iki gününe** düşmek zorunda; valörler **DB'den okunur**
  (`ReverseId` → o satırın `ValueDate`'i), hesaplanmaz.
- 🔴 **Defter (ledger) hesabına `ReferenceType`/`ReferenceNumber` gönderilemez** (Fimple `Code 3058`).
  Çözümün doğru evi **konfigürasyon** (`AccAccountMap`), kod değil.
- ⚠️ **Muhasebe zincirinde FK yok** — yanlış sırada silme **sessizce orphan** üretir. Snapshot alıp
  yaprak→kök sil, sonda kalıntı sayımı 0 değilse `THROW`.

## 4. 🔴 Mesaj tarafı tuzakları
- **API geçidi kendi zarfını ekliyor ve `IsSuccess`'i EZİYOR.** Geçit arkasındaki çağıran
  `isSuccess`'e bakarak karar **veremez**; sözleşmede dallanma `errorCode` + `actionRequired` +
  `transactionId` üzerinden tanımlanır.
- **`MessageType` kullanıcı seçmez, route belirler.**
- Fimple'ın 56 state'i → **5 iş durumu**na indirilir (`TxnMessageEvent`).

## 5. Bitiş kriteri
1. ✅ Her alt başlık kendi `progress/` satırını almış
2. ✅ Muhasebe fişi Fimple'a gidiyor ve kabul ediliyor
3. ✅ "Yeniden üret" senaryosu **çift kayıt üretmiyor** (açıkça test edildi)

## 6. Çıktı
`../progress/09a..09d-*.md`
