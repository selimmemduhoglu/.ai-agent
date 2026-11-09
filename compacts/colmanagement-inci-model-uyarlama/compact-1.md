# compact-1.md — ColManagement INCI model uyarlama

**Tarih:** 2026-10-22
**Önceki:** —

## Kullanıcı istekleri (kendi sözleri, özet)

1. (2026-10-21) INCI Excel'ini detaylı incele; `CollateralAggreement`→`Annex`, `...Product`→`AnnexProductScope`,
   `...Rule`→`AnnexMarginRule` gibi alan alan eşle, sonuç çıkar. → `05-INCI-VERI-MODELI-KARSILASTIRMA.md`.
2. (2026-10-21) *"Excel'in daha iyi olduğu yerler… al ve bizim daha iyi olduğumuz yerler içinde bizim ki kalsın…
   FloatingRateType ve benzeri tabloları al… NetTrexMM ve NetTrexColManagement'a istediğin gibi Select at."*
3. (2026-10-22, compact sonrası) **A:** InterestFree/OnReturn seed'leri *"şimdilik kalsın"* — ekranlar açılınca test
   ettikçe değişiklik söyleyecek. **B (K-44):** Transaction Collateral Definition'a göre girilir, Edit edilebilir;
   **Verify'dan sonra** her giriş/çıkış bir **Detail** oluşturur. Detail'lar **maker-checker**'dan geçer; verify sonrası
   Transaction edit'i direkt Detail olarak yansır. **Muhasebe fişi Detail başına** kesilir. **Cash alanları kalır.**
   *"ilk hareketten kastın nedir?"* diye sordu.
4. (2026-10-22) ColManagement + ColManagement.UI'yi lokalde kaldırdı:
   - `localhost:5105/Annex/Index` → `+` → `TypeError: Cannot read properties of undefined (reading 'option') at populateDropdowns (form.ts:80:30) / initFormPopup (form.ts:48) / handleNew (index.ts:76)`.
   - Grid kolon başlıkları key olarak görünüyor (`dgAnnexes-AnnexCode`) → localization yüklenmiyor.
   - "State" filtresi yerine **`Treasy.MM.UI` MmTransaction/Index**'teki State alanları alınsın; *"ColManagement.UI için
     her zaman Treasy.MM.UI'yi örnek al"* — dropdown'dan grid'e kadar.
   - CollateralDefinition ekranında da benzer hata var; ikisi de çalışmalı.

## Yapılanlar (2026-10-21)

- Detay → [`progress/28-inci-model-uyarlama.md`](../../feature-research/ColManagement-Feature/progress/28-inci-model-uyarlama.md).
- Script'ler `Treasy.ColManagement/.ai-agent/outputs/2026-10-21-ColManagement-InciModelUyarlama/` (0→1→2→0), çalıştırılmadı.
- Hata kaydı H-096 (Mapster navigation çift ekleme), H-097 (ESTR PointId=SOFR), H-098 (`/customer`,`/annex`,`/portfolio` select-f-key uçları tespit edilmedi).
- sql-log: `sql-log/colmanagement-inci-model-uyarlama/` #1-#9.

## Teknik tuzaklar bu turda

- Dosyalar CRLF; düzenleme satır sonunu korumalı. `dotnet build | head` takılıyor → çıktıyı dosyaya yönlendir.
- `tsc` 11 adet TS2581 değişiklikten **önce de** vardı.

## Açık kalanlar

- Ekran hataları (madde 4) — bu turda düzeltilecek.
- K-44 tasarımı kullanıcı cevabıyla netleşti; uygulama henüz yok.
