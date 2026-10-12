# Release Note (Board alanları) - Valör-Vade Raporu (AD-8945)

> Board alanlarına **düz metin** olarak yapıştırılır. Ekran/menü adı isim seçiminden sonra değişirse
> Title ve How To? alanlarındaki "Valör-Vade Raporu" güncellenir.

**Title:** Tarih Filtreli Swap ve Money Market Valör-Vade Raporu

**Title EN:** Date Filtered Swap and Money Market Value Maturity Report

**Jira Id:** AD-8945 (Jira'dan, kontrol edin)

**DevOps Item Id:** ❓ kullanıcı dolduracak

**RN Added / RN ID / Used in Release Note / Is Profession Services?:** ❓ kullanıcı/board

**Version No:** 1.37.0.0 (öneri; son release dalı v1.36.0.x)

**Project:** Common (ekran) + MM + FX (servisler)

**Customer:** ❓ kullanıcı dolduracak

**Summary:**
Money Market, Interbank Loan ve FX/PM Swap işlemleri için valör tarihi ve vade tarihi aralığına göre filtrelenen yeni bir rapor ekranı Common UI altına eklendi. Ekranda ürün seçilince istek ilgili modüle gidiyor, Money Market ve Interbank Loan verisi MM modülünden, swap verisi FX modülünden geliyor ve grid kolonları seçilen ürüne göre değişiyor. Swap tarafında aynı karşı taraf, parite, near ve far valör ile aynı yöndeki işlemler tek satırda toplanıyor, swap oranı tutar ağırlıklı hesaplanıyor. Rapor müşterinin kullandığı Excel formatında dışarı alınabiliyor.

**Summary EN:**
A new report screen was added under Common UI for Money Market, Interbank Loan and FX/PM Swap transactions, filtered by value date and maturity date ranges. When a product is selected the request goes to the related module, Money Market and Interbank Loan data comes from the MM module and swap data from the FX module, and the grid columns change according to the selected product. On the swap side, deals with the same counterparty, currency pair, near and far value dates and direction are grouped into one row and the swap rate is calculated amount weighted. The report can be exported in the customer's Excel format.

**Testing Information:**
MM tarafında 30, FX tarafında 36 unit test yazıldı. Tarih aralığı kontrolleri, ürün ve modül eşleşmesi, en az bir tarih zorunluluğu, Interbank Loan parametresinin açık ve kapalı olması, alt ürün ve referans filtreleri, swap gruplama, ağırlıklı oran, getiri ve kar zarar hesapları test ediliyor. Swap oranı ve getiri müşterinin gönderdiği Excel'deki rakamlarla karşılaştırıldı (toplam 203.553.350, oran %39,65, PM swap %4,65). MM ve FX servisleri lokal ortamda gerçek veri ile çağrıldı, Money Market ve Interbank Loan kayıtlarında tüm kolonların dolduğu kontrol edildi.

**Testing Information EN:**
30 unit tests were written on the MM side and 36 on the FX side. Date range checks, product and module matching, the at least one date rule, the Interbank Loan parameter on and off, sub product and reference filters, swap grouping, weighted rate, yield and profit loss calculations are covered. Swap rate and yield were compared with the figures in the customer's Excel file (total 203,553,350, rate 39.65%, PM swap 4.65%). MM and FX services were called locally with real data and all columns were checked to be filled for Money Market and Interbank Loan records.

**Impact Analysis:**
Yeni bir ekran ve yeni servisler eklendi, mevcut ekranlarda ve tablolarda değişiklik yok. MM ve FX modüllerine salt okunur api/value-maturity-report/transactions servisi, MM'e ayrıca api/value-maturity-report/products servisi eklendi, veritabanı şemasında değişiklik yapılmadı. Sadece onaylı işlemler ve ürün tanımında aktif (Enabled) olan ürünler rapora geliyor. Interbank Loan ürünü MM appsettings içindeki InterbankLoan:Enabled parametresi açıksa ürün listesinde görünüyor, kapalıysa listeye gelmiyor ve servis de Interbank Loan için çalışmıyor, Money Market bundan etkilenmiyor. Vadesi geçmiş işlemlerde vadeye kalan gün 0 gösteriliyor. Tek sorguda en fazla 5000 kayıt getiriliyor, fazlası olduğunda ekranda uyarı çıkıyor.

**Impact Analysis EN:**
A new screen and new services were added, existing screens and tables are not changed. A read only api/value-maturity-report/transactions service was added to the MM and FX modules and an api/value-maturity-report/products service to MM, no database schema change was made. Only verified transactions of products enabled in the product definition are included in the report. The Interbank Loan product is listed only when the InterbankLoan:Enabled parameter in the MM appsettings is on, when it is off the product is not listed and the service does not run for Interbank Loan, Money Market is not affected. Days to maturity is shown as 0 for matured transactions. A single query returns at most 5000 records, a warning is shown on the screen when there are more.

**How To?:**
Reports menüsü altından Valör-Vade Raporu ekranı açılır. Ürün alanından Money Market, Interbank Loan veya Swap seçilir, Alt Ürün alanında Money Market ve Interbank Loan için ürün tanımındaki aktif alt ürünler, Swap için FX Swap ve PM Swap gelir ve hepsi seçili gelir, istenen alt ürünler bırakılır. Valör tarihi başlangıç bitiş ve vade tarihi başlangıç bitiş alanlarından en az biri girilir, aralığın bir tarafı boş bırakılabilir, ekran açıldığında valör tarihi içinde bulunulan ayın ilk ve son günüyle dolu gelir. Belirli bir işlem aranacaksa Ref. alanına referans yazılıp Enter'a basılır, bu durumda tarih girmek zorunlu değil. Ara butonuna basılır, sonuç grid üzerindeki Excel ikonu ile dışarı alınır.

**How To? EN:**
The Value Maturity Report screen is opened from the Reports menu. Money Market, Interbank Loan or Swap is selected in the Product field. The Sub Product field lists the enabled product definitions for Money Market and Interbank Loan and FX Swap and PM Swap for Swap, all of them come selected and the user keeps the ones needed. At least one of value date from to and maturity date from to is entered, one side of a range can be left empty, when the screen opens the value date is filled with the first and last day of the current month. To find a specific transaction a reference is typed into the Log. Ref. field and Enter is pressed, a date is not required in that case. The Search button is pressed and the result is exported with the Excel icon on the grid.

**Definition and configuration:**
Menü scripti (Reports altında Valör-Vade Raporu) ve permission scripti (ValueMaturityReport_Displayer rolü, Index ve Load action'ları) NetTrexCommon veritabanında çalıştırılmalı. Rol ilgili kullanıcı profillerine bağlanmalı. Script sonrası Redis'teki menü ve yetki cache'i temizlenmeli. Interbank Loan'ın raporda görünmesi için MM servisinin appsettings dosyasında InterbankLoan:Enabled true olmalı.

**Definition and configuration EN:**
The menu script (Value Maturity Report under Reports) and the permission script (ValueMaturityReport_Displayer role with Index and Load actions) must be run on the NetTrexCommon database. The role must be assigned to the related user profiles. After the scripts, the menu and permission cache in Redis must be cleared. For Interbank Loan to appear in the report, InterbankLoan:Enabled must be true in the MM service appsettings.

**Scopekey Information:** (⚠️ alan anlamı doğrulanmadı, arama anahtar kelimesi olarak yazıldı)
Valör-Vade Raporu, Swap Raporu, Money Market, Interbank Loan, FX Swap, PM Swap, Valör Tarihi, Vade Tarihi, Excel

**Scopekey Information EN:**
Value Maturity Report, Swap Report, Money Market, Interbank Loan, FX Swap, PM Swap, Value Date, Maturity Date, Excel

**Process Changes:**
Kullanıcılar Money Market, Interbank Loan ve swap işlemlerinin valör ve vade listesini ayrı ekranlardan toplamak yerine tek ekrandan tarih aralığı vererek alabiliyor. Swap işlemleri gruplanmış ve oranı hesaplanmış olarak geliyor, Excel çıktısı ek düzenleme gerektirmeden kullanılabiliyor.

**Process Changes EN:**
Users can get the value and maturity list of Money Market, Interbank Loan and swap transactions from a single screen by giving a date range instead of collecting it from separate screens. Swap transactions come grouped with the rate calculated, and the Excel output can be used without further editing.

**Customer Action Required:**
Menü ve permission scriptleri çalıştırılmalı, ValueMaturityReport_Displayer rolü ekranı kullanacak profillere verilmeli ve cache temizlenmeli.

**Customer Action Required EN:**
The menu and permission scripts must be run, the ValueMaturityReport_Displayer role must be given to the profiles that will use the screen and the cache must be cleared.

**Ekler:** ❓ kullanıcı (ekran görüntüsü)
