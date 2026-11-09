# 34 — V2 revize: backend + DB script seti (2026-11-02)

## Ne yapıldı
Yeni analiz dokümanı (TRS-COL-FA-001 v0.2) + `Treasy_Collateral_Veri_Modeli.xlsx` + `Collateral_Demo.html`
okunup mevcut koda kıyasla farklar çıkarıldı → [`06-V2-REVIZE-ANALIZ.md`](../06-V2-REVIZE-ANALIZ.md).
4 soru kullanıcıya soruldu (K-58..K-61): akış kolonları Excel'e uy, ürün kataloğu modül DB'sinde,
muhasebe Detail başına, enum alanlar int+lookup. Kararlar `bilgi-bankasi/07-kararlar-ve-sorular.md`'ye işlendi.

**Backend tamamen yeniden yazıldı** (Data, Common, Api katmanları):
- `Annex` → `CollateralAnnex` + `CollateralAnnexProduct`/`CollateralAnnexRule`, tam FlowEntity.
- `CollateralDefinition` düzleştirildi (CashTerms/EligibleCurrency alt tabloları kalktı).
- `TxnTransaction` = kalıcı pozisyon başlığı; `TxnTransactionDetail` = hareket (Increase/Decrease,
  tutar, ödeme alanları); `TxnTransactionCash`/`CollateralPosition` kalktı.
- Yeni lookup/parametre tabloları: `MarginType` (CollateralMarginType'tan yeniden adlandı),
  `CollateralType`, `CollateralAmountType`, `CollateralStatus`, `CollateralInterestSettlement`,
  `CollateralTransactionType`, `CollateralProduct`+`CollateralSubProduct`, `CollateralDailyCalculation`,
  `PaymentFrequency` (InterestMethodFrequency'den).
- Annex/Definition/Transaction'ın tüm handler+validator'ları yeniden yazıldı (Create/Update/Delete/
  Verify/Reject/Get/List/History/FKey). Annex/Definition Undo kaldırıldı (doküman kapsamı dışı).
- Muhasebe: Opening artık **Detail (hareket) başına** çalışıyor (K-60); Delete'te onaylı hareket
  sayısı kadar ters fiş.
- Backend tüm `.sln` 0 hata ile derleniyor.

**DB script seti v2** (`Treasy.ColManagement/.ai-agent/outputs/2026-11-02-ColManagement-Kurulum-v2/`):
boş DB'ye uygulanacak tam set. Platform/referans/ürün katalog bölümleri (A/B/C) v1'den değişmedi,
module-özgü tablolar (D) ve lookup'lar (F) yeniden yazıldı. Kullanıcı DB'yi silip bu setle kuracak.

## Açık / sonraki adım
- **UI (Treasy.ColManagement.UI) henüz güncellenmedi** — Razor view'ları ve TS dosyaları eski alan
  adlarını (`AnnexCode`, `MtaAmount`, `Party`, vb.) kullanıyor, backend'le uyuşmuyor; derlenmeyecek.
  Sıradaki iş: Annex (tek sayfa, 3 bölüm) / Definition (düz) / Transaction (2 tab + hareket listesi)
  ekranlarını yeni sözleşmeye göre yeniden yazmak.
- K-55 (TxnTransactionDetail akışı) artık v2 ile birlikte kodlandı — eski açık madde kapandı.
