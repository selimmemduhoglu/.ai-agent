# 14 — Api Tanım Uçları (A)

**Tarih:** 2026-10-09 · `dotnet build` **0 hata**

Kullanıcı: *"tamam A'dan başla"* — MM ∩ OptionsFX ortak, entity'den bağımsız Api uçları.

| Uç | Kaynak | Uçlar |
|---|---|---|
| Calendar | **MM** (OFX'inki QuGet'e bağlı — H-082) | `CheckWorkingDay` · `CheckWorkingDays` · `NextWorkingDay` · `GetWorkingDay` (+ validator) |
| Currencies | OFX | `f-key` · `pair` · `pairs` |
| Customers | OFX | `overview` · `accounts` (Fimple müşteri hesapları) |
| Portfolios | OFX | `f-key` |
| JobCron | OFX (MM ile aynı uç seti) | `select` · `create` · `update` · `delete` · `verify` · `reject` · `undo` · `history` (+ validator) |
| FinancialInstitution | OFX | `payment-option` · `our-correspondent-banks` · `their-correspondent-banks` |
| PaymentInstructionType · SettlementType · ProductDefinitions | OFX | `overview` |

Her uç: controller + handler + request/response + model + Mapster mapper. Toplam ~100 dosya.
**Alınmayan:** `Documents/compliance`, `CustomerCompliance` (OFX'e özel — H-081). MM'in ek uçları → H-080.
🔴 **Route adları MM'den farklı** (H-079) — UI `Treasy.MM.UI`'den kopyalanacağı için UI fazında karar gerekiyor.

DI kontrolü: enjekte edilen 41 çözüm-içi arayüzün hepsinin implementasyonu var (kalanlar Refit, runtime üretiliyor).
⚠️ Çalıştırılmadı.

**Sırada (B):** helm chart ×3 · azure-pipelines ×3 · `pipelines/templates` · `Dockerfile_sonarqube`.
