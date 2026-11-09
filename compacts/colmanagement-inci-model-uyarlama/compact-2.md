# compact-2.md — ColManagement ekran turları (2026-10-22)

**Önceki:** [compact-1.md](compact-1.md)

## Bu sohbette yapılan turlar (detay progress'te)
- progress/29: popup show sırası, 54 grid loc key, MmTransaction State filtresi + backend `ApplyStateFilter`/`ApplyMakerCheckerStateFilter`, FKey uçları, referans veri kopya script'i.
- progress/30: Annex 2×2 kart, 4 lookup tablosu (Id=enum değeri, Code=enum adı), Product/SubProduct Manuel Reeskont deseni (MM API), ValidFrom = mantıksal ayın 1'i, validator'lar Handlers/Validators klasörlerine (ajan), UI Rebuild SWA fix (H-101).
- progress/31: Annex 2 tab (New/Edit/Preview), Copy/Undo kaldırıldı, Logical Date başlıkta, performans (MM 5 sn timeout, cache, paralel).

## Kullanıcı kararları (kendi sözleri, 2026-10-22)
- *"MM in ekranındaki gibi kalsın… Annex ve CollateralDefinition MM'deki ProductDefinition tablosu gibi olsun"* → tanımlar maker-checker kalır, flow engine'e geçmez.
- Collateral Definition: Annex seçilirse Counterparty, Valid alanları, Eligibility Direction, Valuation Currency **annex'ten gelsin ve disabled**; seçilmezse elle girilsin.
- Tüm dropdown'lar DB'den (Business Day Rule dahil). Alanların yanında **info (i)** + Dinamik-Ekran'daki açıklamalar, TR/EN localization, Annex + Definition.
- Definition'da 3 tab kaldırılsın, alt alta. Eligible Currencies uzunluğu düzeltilsin.
- Popup ölçekleme/responsive **MM MmTransaction'daki js/css gibi**; popup ve History grid'indeki boş alt alan olmasın.

## Teknik tuzaklar
- Bash heredoc içinde `'` + `?` karışık uzun içerik → "unexpected EOF"; Write tool kullan.
- node -e içinde RegExp güvenilmez; script dosyası + düz string replace; CRLF dosyalarda `\r\n` normalize et.
- DevExtreme `CustomizeText` Razor'da fonksiyon ADI ister (`"Annex.yesNoText"`), `new JS(...)` değil.
