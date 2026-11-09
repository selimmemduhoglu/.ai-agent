# Kirilim tablosu - Tera (yatirim) - MM

> Kaynak: `imports/AccountingExcels` AccountMap sayfasi. Otomatik uretildi (2026-10-27). THP adi: yatirim hesap plani PDF'inden; yaprak adlar ust seviye ile birlikte okunur.
> Kural sutunu: Rule1..Rule10 dolu olanlar `&` ile birlesik. Ayni (Path, Source) icinde `Order` kucuk olan once denenir; ilk tum-kurallari-gecen satir kazanir.
>

## TREX/BRWPLC1/MONEYMARKET/BRW/LCY

### CounterPartyGLAccount

| On | Order | Kurallar | THP | Target | THP adi | Cust/Acc | Not |
|---|---|---|---|---|---|---|---|
| E | 10 | IsAccountNeeded = 1 & UseExternalGLAccount = 1 |  | calc:ExternalGLAccount |  | C+A |  |
| E | 10 | Money Market & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = DOM & Term = Short & Mali Kesim & Bankalar | 34200 | 34200000 | ALACAKLARDAN DOLAYI EDİNİLEN DİĞER VARLIKLAR > TÜRKİYE CUMHURİYET MERKEZ BANKASI KREDİLERİ - T.P. > TÜRKİYE CUMHURİYET MERKEZ BANKASI KREDİLERİ - Y.P. | C+A |  |
| E | 100 | Money Market & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = DOM & Term = Short | 34400 | 34400000 | ALACAKLARDAN DOLAYI EDİNİLEN DİĞER VARLIKLAR > ORTA VE UZUN VADELİ | C+A |  |
| E | 10 | Money Market & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = DOM & Term = Long & Mali Kesim & Bankalar | 34210 | 34210000 | ALACAKLARDAN DOLAYI EDİNİLEN DİĞER VARLIKLAR > TÜRKİYE CUMHURİYET MERKEZ BANKASI KREDİLERİ - T.P. | C+A |  |
| E | 100 | Money Market & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = DOM & Term = Long | 34410 | 34410000 | ALACAKLARDAN DOLAYI EDİNİLEN DİĞER VARLIKLAR | C+A |  |
| E | 10 | Money Market & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = FRGN & Term = Short & Mali Kesim & Yurtdışı Bankalar | 348009 | 34800900 | SERMAYE BENZERİ BORÇLANMA ARAÇLARI > YURTDIŞINDAN KULLANILAN KREDİLER - T.P. > SENDİKASYON KREDİLERİ | C+A |  |
| E | 100 | Money Market & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = FRGN & Term = Short | 348019 | 34801900 | SERMAYE BENZERİ BORÇLANMA ARAÇLARI > SEKÜRİTİZASYON KREDİLERİ > SENDİKASYON KREDİLERİ | C+A |  |
| E | 10 | Money Market & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = FRGN & Term = Long & Mali Kesim & Yurtdışı Bankalar | 348109 | 34810900 | SERMAYE BENZERİ BORÇLANMA ARAÇLARI > SEKÜRİTİZASYON KREDİLERİ > SENDİKASYON KREDİLERİ | C+A |  |
| E | 100 | Money Market & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = FRGN & Term = Long | 348119 | 34811900 | SERMAYE BENZERİ BORÇLANMA ARAÇLARI > SEKÜRİTİZASYON KREDİLERİ > SENDİKASYON KREDİLERİ | C+A |  |
| E | 10 | Money Market & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = TCMB | 32801 | 32801000 | ALACAKLARDAN DOLAYI EDİNİLEN DİĞER VARLIKLAR > PARA PİYASALARINA BORÇLAR - T.P. > BANKALARARASI PİYASALARA BORÇLAR | C+A |  |
| E | 20 | Money Market & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = TAKAS | 32802 | 32802000 | ALACAKLARDAN DOLAYI EDİNİLEN DİĞER VARLIKLAR > PARA PİYASALARINA BORÇLAR - T.P. > TAKASBANK PARA PİYASALARINA BORÇLAR | C+A |  |
| E | 30 | Money Market & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = BIST | 32803 | 32803000 | ALACAKLARDAN DOLAYI EDİNİLEN DİĞER VARLIKLAR > PARA PİYASALARINA BORÇLAR - T.P. > BORSA İSTANBUL PARA PİYASALARINA BORÇLAR | C+A |  |
| E | 10 | Pas & IsAccountNeeded = 1 & UseExternalGLAccount = 0 | 32801 | 32801000 | ALACAKLARDAN DOLAYI EDİNİLEN DİĞER VARLIKLAR > PARA PİYASALARINA BORÇLAR - T.P. > BANKALARARASI PİYASALARA BORÇLAR | C+A |  |
| E | 10 | Gil & IsAccountNeeded = 1 & UseExternalGLAccount = 0 | 32801 | 32801000 | ALACAKLARDAN DOLAYI EDİNİLEN DİĞER VARLIKLAR > PARA PİYASALARINA BORÇLAR - T.P. > BANKALARARASI PİYASALARA BORÇLAR | C+A |  |

### InterestPaid

| On | Order | Kurallar | THP | Target | THP adi | Cust/Acc | Not |
|---|---|---|---|---|---|---|---|
| E | 10 | Money Market & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Short & Mali Kesim & Bankalar | 62200 | 62200000 | FAİZ GİDERLERİ > TÜRKİYE CUMHURİYET MERKEZ BANKASI KRED. VER. FAİZ. - T.P. > TÜRKİYE CUMHURİYET MERKEZ BANKASI KRED. VER. FAİZ. - Y.P. | C+A |  |
| E | 100 | Money Market & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Short | 62201 | 62201000 | FAİZ GİDERLERİ > TÜRKİYE CUMHURİYET MERKEZ BANKASI KRED. VER. FAİZ. - T.P. | C+A |  |
| E | 10 | Money Market & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Long & Mali Kesim & Bankalar | 62200 | 62200100 | FAİZ GİDERLERİ > TÜRKİYE CUMHURİYET MERKEZ BANKASI KRED. VER. FAİZ. - T.P. > TÜRKİYE CUMHURİYET MERKEZ BANKASI KRED. VER. FAİZ. - Y.P. | C+A |  |
| E | 100 | Money Market & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Long | 62201 | 62201100 | FAİZ GİDERLERİ > TÜRKİYE CUMHURİYET MERKEZ BANKASI KRED. VER. FAİZ. - T.P. | C+A |  |
| E | 10 | Money Market & IsAccountNeeded = 1 & Market = OTC & Customer Location = FRGN & Term = Short & Mali Kesim & Yurtdışı Bankalar | 62400 | 62400000 | FAİZ GİDERLERİ > YURTİÇİNDEKİ DİĞER KURULUŞLARDAN KULLANILAN KREDİLERE | C+A |  |
| E | 100 | Money Market & IsAccountNeeded = 1 & Market = OTC & Customer Location = FRGN & Term = Short | 62401 | 62401000 | FAİZ GİDERLERİ | C+A |  |
| E | 10 | Money Market & IsAccountNeeded = 1 & Market = OTC & Customer Location = FRGN & Term = Long & Mali Kesim & Yurtdışı Bankalar | 62400 | 62400100 | FAİZ GİDERLERİ > YURTİÇİNDEKİ DİĞER KURULUŞLARDAN KULLANILAN KREDİLERE | C+A |  |
| E | 100 | Money Market & IsAccountNeeded = 1 & Market = OTC & Customer Location = FRGN & Term = Long | 62401 | 62401100 | FAİZ GİDERLERİ | C+A |  |
| E | 10 | Money Market & IsAccountNeeded = 1 & Market = TCMB | 62600 | 62600000 | FAİZ GİDERLERİ > YURTDIŞINDAKİ BANKALARDAN KULLANILAN KREDİLERE > (?) sayfa basligiyla birlesmis | C+A |  |
| E | 20 | Money Market & IsAccountNeeded = 1 & Market = TAKAS | 62601 | 62601000 | FAİZ GİDERLERİ > YURTDIŞINDAKİ BANKALARDAN KULLANILAN KREDİLERE | C+A |  |
| E | 30 | Money Market & IsAccountNeeded = 1 & Market = BIST | 62699 | 62699000 | FAİZ GİDERLERİ > YURTDIŞINDAKİ BANKALARDAN KULLANILAN KREDİLERE > BANKALARARASI PARA PİYASASI İŞLEMLERİNE | C+A |  |

### InterestExpense

| On | Order | Kurallar | THP | Target | THP adi | Cust/Acc | Not |
|---|---|---|---|---|---|---|---|
| E | 10 | Money Market & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Short & Mali Kesim & Bankalar | 62200 | 62200000 | FAİZ GİDERLERİ > TÜRKİYE CUMHURİYET MERKEZ BANKASI KRED. VER. FAİZ. - T.P. > TÜRKİYE CUMHURİYET MERKEZ BANKASI KRED. VER. FAİZ. - Y.P. | C+A |  |
| E | 100 | Money Market & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Short | 62201 | 62201000 | FAİZ GİDERLERİ > TÜRKİYE CUMHURİYET MERKEZ BANKASI KRED. VER. FAİZ. - T.P. | C+A |  |
| E | 10 | Money Market & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Long & Mali Kesim & Bankalar | 62200 | 62200100 | FAİZ GİDERLERİ > TÜRKİYE CUMHURİYET MERKEZ BANKASI KRED. VER. FAİZ. - T.P. > TÜRKİYE CUMHURİYET MERKEZ BANKASI KRED. VER. FAİZ. - Y.P. | C+A |  |
| E | 100 | Money Market & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Long | 62201 | 62201100 | FAİZ GİDERLERİ > TÜRKİYE CUMHURİYET MERKEZ BANKASI KRED. VER. FAİZ. - T.P. | C+A |  |
| E | 10 | Money Market & IsAccountNeeded = 1 & Market = OTC & Customer Location = FRGN & Term = Short & Mali Kesim & Yurtdışı Bankalar | 62400 | 62400000 | FAİZ GİDERLERİ > YURTİÇİNDEKİ DİĞER KURULUŞLARDAN KULLANILAN KREDİLERE | C+A |  |
| E | 100 | Money Market & IsAccountNeeded = 1 & Market = OTC & Customer Location = FRGN & Term = Short | 62401 | 62401000 | FAİZ GİDERLERİ | C+A |  |
| E | 10 | Money Market & IsAccountNeeded = 1 & Market = OTC & Customer Location = FRGN & Term = Long & Mali Kesim & Yurtdışı Bankalar | 62400 | 62400100 | FAİZ GİDERLERİ > YURTİÇİNDEKİ DİĞER KURULUŞLARDAN KULLANILAN KREDİLERE | C+A |  |
| E | 100 | Money Market & IsAccountNeeded = 1 & Market = OTC & Customer Location = FRGN & Term = Long | 62401 | 62401100 | FAİZ GİDERLERİ | C+A |  |
| E | 10 | Money Market & IsAccountNeeded = 1 & Market = TCMB | 62600 | 62600000 | FAİZ GİDERLERİ > YURTDIŞINDAKİ BANKALARDAN KULLANILAN KREDİLERE > (?) sayfa basligiyla birlesmis | C+A |  |
| E | 20 | Money Market & IsAccountNeeded = 1 & Market = TAKAS | 62601 | 62601000 | FAİZ GİDERLERİ > YURTDIŞINDAKİ BANKALARDAN KULLANILAN KREDİLERE | C+A |  |
| E | 30 | Money Market & IsAccountNeeded = 1 & Market = BIST | 62699 | 62699000 | FAİZ GİDERLERİ > YURTDIŞINDAKİ BANKALARDAN KULLANILAN KREDİLERE > BANKALARARASI PARA PİYASASI İŞLEMLERİNE | C+A |  |

### AccruedExpense

| On | Order | Kurallar | THP | Target | THP adi | Cust/Acc | Not |
|---|---|---|---|---|---|---|---|
| E | 10 | Money Market & IsAccountNeeded = 1 & Market = OTC | 36001 | 36001000 | ALACAKLARDAN DOLAYI EDİNİLEN DİĞER VARLIKLAR > KİRALAMA İŞLEMLERİNDEN BORÇLAR - T.P. > KİRALAMA İŞLEMLERİNDEN BORÇLAR - Y.P. | C+A |  |
| E | 10 | Money Market & IsAccountNeeded = 1 & Market = TCMB | 36099 | 36099200 | ALACAKLARDAN DOLAYI EDİNİLEN DİĞER VARLIKLAR > KİRALAMA İŞLEMLERİNDEN BORÇLAR - T.P. > GERÇEĞE UYGUN DEĞER FARKI KÂR/ZARARA YANSITILAN FİNANSAL YÜKÜMLÜ- | C+A |  |
| E | 20 | Money Market & IsAccountNeeded = 1 & Market = TAKAS | 36099 | 36099200 | ALACAKLARDAN DOLAYI EDİNİLEN DİĞER VARLIKLAR > KİRALAMA İŞLEMLERİNDEN BORÇLAR - T.P. > GERÇEĞE UYGUN DEĞER FARKI KÂR/ZARARA YANSITILAN FİNANSAL YÜKÜMLÜ- | C+A |  |
| E | 30 | Money Market & IsAccountNeeded = 1 & Market = BIST | 36099 | 36099200 | ALACAKLARDAN DOLAYI EDİNİLEN DİĞER VARLIKLAR > KİRALAMA İŞLEMLERİNDEN BORÇLAR - T.P. > GERÇEĞE UYGUN DEĞER FARKI KÂR/ZARARA YANSITILAN FİNANSAL YÜKÜMLÜ- | C+A |  |

## TREX/BRWPLC1/MONEYMARKET/BRW/FCY

### CounterPartyGLAccount

| On | Order | Kurallar | THP | Target | THP adi | Cust/Acc | Not |
|---|---|---|---|---|---|---|---|
| E | 10 | IsAccountNeeded = 1 & UseExternalGLAccount = 1 |  | calc:ExternalGLAccount |  | C+A |  |
| E | 10 | Money Market & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = DOM & Term = Short & Mali Kesim & Bankalar | 34300 | 34300000 | ALACAKLARDAN DOLAYI EDİNİLEN DİĞER VARLIKLAR > ORTA VE UZUN VADELİ | C+A |  |
| E | 100 | Money Market & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = DOM & Term = Short | 34500 | 34500000 | ALACAKLARDAN DOLAYI EDİNİLEN DİĞER VARLIKLAR > ORTA VE UZUN VADELİ | C+A |  |
| E | 10 | Money Market & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = DOM & Term = Long & Mali Kesim & Bankalar | 34310 | 34310000 | ALACAKLARDAN DOLAYI EDİNİLEN DİĞER VARLIKLAR | C+A |  |
| E | 100 | Money Market & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = DOM & Term = Long | 34510 | 34510000 | ALACAKLARDAN DOLAYI EDİNİLEN DİĞER VARLIKLAR > (?) sayfa basligiyla birlesmis | C+A |  |
| E | 10 | Money Market & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = FRGN & Term = Short & Mali Kesim & Yurtdışı Bankalar | 349009 | 34900900 | DİĞER > YURTDIŞINDAN KULLANILAN KREDİLER - Y.P. > SENDİKASYON KREDİLERİ | C+A |  |
| E | 100 | Money Market & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = FRGN & Term = Short | 340019 | 34901900 | ALACAKLARDAN DOLAYI EDİNİLEN DİĞER VARLIKLAR | C+A |  |
| E | 10 | Money Market & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = FRGN & Term = Long & Mali Kesim & Yurtdışı Bankalar | 349109 | 34910900 | DİĞER > SEKÜRİTİZASYON KREDİLERİ > SENDİKASYON KREDİLERİ | C+A |  |
| E | 100 | Money Market & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = FRGN & Term = Long | 349119 | 34911900 | DİĞER > SEKÜRİTİZASYON KREDİLERİ > SENDİKASYON KREDİLERİ | C+A |  |
| E | 10 | Money Market & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = TCMB | 32901 | 32901000 | ALACAKLARDAN DOLAYI EDİNİLEN DİĞER VARLIKLAR > PARA PİYASALARINA BORÇLAR - Y.P. > BANKALARARASI PİYASALARA BORÇLAR | C+A |  |
| E | 20 | Money Market & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = TAKAS | 32902 | 32902000 | ALACAKLARDAN DOLAYI EDİNİLEN DİĞER VARLIKLAR > PARA PİYASALARINA BORÇLAR - Y.P. > TAKASBANK PARA PİYASALARINA BORÇLAR | C+A |  |
| E | 30 | Money Market & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = BIST | 32903 | 32903000 | ALACAKLARDAN DOLAYI EDİNİLEN DİĞER VARLIKLAR > PARA PİYASALARINA BORÇLAR - Y.P. > BORSA İSTANBUL PARA PİYASALARINA BORÇLAR | C+A |  |
| E | 10 | Pas & IsAccountNeeded = 1 & UseExternalGLAccount = 0 | 32901 | 32901000 | ALACAKLARDAN DOLAYI EDİNİLEN DİĞER VARLIKLAR > PARA PİYASALARINA BORÇLAR - Y.P. > BANKALARARASI PİYASALARA BORÇLAR | C+A |  |
| E | 10 | Gil & IsAccountNeeded = 1 & UseExternalGLAccount = 0 | 32901 | 32901000 | ALACAKLARDAN DOLAYI EDİNİLEN DİĞER VARLIKLAR > PARA PİYASALARINA BORÇLAR - Y.P. > BANKALARARASI PİYASALARA BORÇLAR | C+A |  |

### InterestPaid

| On | Order | Kurallar | THP | Target | THP adi | Cust/Acc | Not |
|---|---|---|---|---|---|---|---|
| E | 10 | Money Market & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Short & Mali Kesim & Bankalar | 62300 | 62300000 | FAİZ GİDERLERİ > YURTİÇİNDEKİ DİĞER KURULUŞLARDAN KULLANILAN KREDİLERE | C+A |  |
| E | 100 | Money Market & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Short | 62301 | 62301000 | FAİZ GİDERLERİ | C+A |  |
| E | 10 | Money Market & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Long & Mali Kesim & Bankalar | 62300 | 62300100 | FAİZ GİDERLERİ > YURTİÇİNDEKİ DİĞER KURULUŞLARDAN KULLANILAN KREDİLERE | C+A |  |
| E | 100 | Money Market & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Long | 62301 | 62301100 | FAİZ GİDERLERİ | C+A |  |
| E | 10 | Money Market & IsAccountNeeded = 1 & Market = OTC & Customer Location = FRGN & Term = Short & Mali Kesim & Yurtdışı Bankalar | 62500 | 62500000 | FAİZ GİDERLERİ > YURTDIŞINDAKİ BANKALARDAN KULLANILAN KREDİLERE > YURTDIŞINDAKİ FONLARDAN KULLANILAN KREDİLERE | C+A |  |
| E | 100 | Money Market & IsAccountNeeded = 1 & Market = OTC & Customer Location = FRGN & Term = Short | 62501 | 62501000 | FAİZ GİDERLERİ > YURTDIŞINDAKİ BANKALARDAN KULLANILAN KREDİLERE | C+A |  |
| E | 10 | Money Market & IsAccountNeeded = 1 & Market = OTC & Customer Location = FRGN & Term = Long & Mali Kesim & Yurtdışı Bankalar | 62500 | 62500100 | FAİZ GİDERLERİ > YURTDIŞINDAKİ BANKALARDAN KULLANILAN KREDİLERE > YURTDIŞINDAKİ FONLARDAN KULLANILAN KREDİLERE | C+A |  |
| E | 100 | Money Market & IsAccountNeeded = 1 & Market = OTC & Customer Location = FRGN & Term = Long | 62501 | 62501100 | FAİZ GİDERLERİ > YURTDIŞINDAKİ BANKALARDAN KULLANILAN KREDİLERE | C+A |  |
| E | 10 | Money Market & IsAccountNeeded = 1 & Market = TCMB | 62700 | 62700000 | FAİZ GİDERLERİ > DİĞER > PARA PİYASASI İŞLEMLERİNE VERİLEN FAİZLER - Y.P | C+A |  |
| E | 20 | Money Market & IsAccountNeeded = 1 & Market = TAKAS | 62701 | 62701000 | FAİZ GİDERLERİ > DİĞER | C+A |  |
| E | 30 | Money Market & IsAccountNeeded = 1 & Market = BIST | 62799 | 62799000 | FAİZ GİDERLERİ > DİĞER > BANKALARARASI PARA PİYASASI İŞLEMLERİNE | C+A |  |

### InterestExpense

| On | Order | Kurallar | THP | Target | THP adi | Cust/Acc | Not |
|---|---|---|---|---|---|---|---|
| E | 10 | Money Market & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Short & Mali Kesim & Bankalar | 62300 | 62300000 | FAİZ GİDERLERİ > YURTİÇİNDEKİ DİĞER KURULUŞLARDAN KULLANILAN KREDİLERE | C+A |  |
| E | 100 | Money Market & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Short | 62301 | 62301000 | FAİZ GİDERLERİ | C+A |  |
| E | 10 | Money Market & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Long & Mali Kesim & Bankalar | 62300 | 62300100 | FAİZ GİDERLERİ > YURTİÇİNDEKİ DİĞER KURULUŞLARDAN KULLANILAN KREDİLERE | C+A |  |
| E | 100 | Money Market & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Long | 62301 | 62301100 | FAİZ GİDERLERİ | C+A |  |
| E | 10 | Money Market & IsAccountNeeded = 1 & Market = OTC & Customer Location = FRGN & Term = Short & Mali Kesim & Yurtdışı Bankalar | 62500 | 62500000 | FAİZ GİDERLERİ > YURTDIŞINDAKİ BANKALARDAN KULLANILAN KREDİLERE > YURTDIŞINDAKİ FONLARDAN KULLANILAN KREDİLERE | C+A |  |
| E | 100 | Money Market & IsAccountNeeded = 1 & Market = OTC & Customer Location = FRGN & Term = Short | 62501 | 62501000 | FAİZ GİDERLERİ > YURTDIŞINDAKİ BANKALARDAN KULLANILAN KREDİLERE | C+A |  |
| E | 10 | Money Market & IsAccountNeeded = 1 & Market = OTC & Customer Location = FRGN & Term = Long & Mali Kesim & Yurtdışı Bankalar | 62500 | 62500100 | FAİZ GİDERLERİ > YURTDIŞINDAKİ BANKALARDAN KULLANILAN KREDİLERE > YURTDIŞINDAKİ FONLARDAN KULLANILAN KREDİLERE | C+A |  |
| E | 100 | Money Market & IsAccountNeeded = 1 & Market = OTC & Customer Location = FRGN & Term = Long | 62501 | 62501100 | FAİZ GİDERLERİ > YURTDIŞINDAKİ BANKALARDAN KULLANILAN KREDİLERE | C+A |  |
| E | 10 | Money Market & IsAccountNeeded = 1 & Market = TCMB | 62700 | 62700000 | FAİZ GİDERLERİ > DİĞER > PARA PİYASASI İŞLEMLERİNE VERİLEN FAİZLER - Y.P | C+A |  |
| E | 20 | Money Market & IsAccountNeeded = 1 & Market = TAKAS | 62701 | 62701000 | FAİZ GİDERLERİ > DİĞER | C+A |  |
| E | 30 | Money Market & IsAccountNeeded = 1 & Market = BIST | 62799 | 62799000 | FAİZ GİDERLERİ > DİĞER > BANKALARARASI PARA PİYASASI İŞLEMLERİNE | C+A |  |

### AccruedExpense

| On | Order | Kurallar | THP | Target | THP adi | Cust/Acc | Not |
|---|---|---|---|---|---|---|---|
| E | 10 | Money Market & IsAccountNeeded = 1 & Market = OTC | 36101 | 36101000 | ALACAKLARDAN DOLAYI EDİNİLEN DİĞER VARLIKLAR > FAİZ VE GİDER REESKONTLARI - Y.P. | C+A |  |
| E | 10 | Money Market & IsAccountNeeded = 1 & Market = TCMB | 36199 | 36199200 | ALACAKLARDAN DOLAYI EDİNİLEN DİĞER VARLIKLAR | C+A |  |
| E | 20 | Money Market & IsAccountNeeded = 1 & Market = TAKAS | 36199 | 36199200 | ALACAKLARDAN DOLAYI EDİNİLEN DİĞER VARLIKLAR | C+A |  |
| E | 30 | Money Market & IsAccountNeeded = 1 & Market = BIST | 36199 | 36199200 | ALACAKLARDAN DOLAYI EDİNİLEN DİĞER VARLIKLAR | C+A |  |

## TREX/BRWPLC1/MONEYMARKET/PLC/LCY

### CounterPartyGLAccount

| On | Order | Kurallar | THP | Target | THP adi | Cust/Acc | Not |
|---|---|---|---|---|---|---|---|
| E | 10 | IsAccountNeeded = 1 & UseExternalGLAccount = 1 |  | calc:ExternalGLAccount |  | C+A |  |
| E | 10 | Money Market & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = DOM & Mali Kesim & Kamu Mevduat Bankaları | 022010 | 02201000 | YURTİÇİ BANKALAR - T.P. > VADELİ HESAP > KAMU MEVDUAT BANKALARI | C+A |  |
| E | 20 | Money Market & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = DOM & Mali Kesim & Özel Mevduat Bankaları | 022011 | 02201100 | YURTİÇİ BANKALAR - T.P. > VADELİ HESAP > ÖZEL MEVDUAT BANKALARI | C+A |  |
| E | 30 | Money Market & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = DOM & Mali Kesim & Yabancı Mevduat Bankaları | 022012 | 02201200 | YURTİÇİ BANKALAR - T.P. > VADELİ HESAP > YABANCI MEVDUAT BANKALARI | C+A |  |
| E | 40 | Money Market & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = DOM & Mali Kesim & Özel Kanunlara Göre Mevduat Kabulüne Yetkili Kuruluşlar | 022013 | 02201300 | YURTİÇİ BANKALAR - T.P. > VADELİ HESAP > ÖZEL KANUNLARINA GÖRE MEVDUAT KABULÜNE YETKİLİ KURULUŞLAR | C+A |  |
| E | 50 | Money Market & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = DOM & Mali Kesim & Katılım Bankaları | 022014 | 02201400 | YURTİÇİ BANKALAR - T.P. > VADELİ HESAP > KATILIM BANKALARI | C+A |  |
| E | 60 | Money Market & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = DOM & Mali Kesim & Kalkınma ve Yatırım Bankaları | 022015 | 02201500 | YURTİÇİ BANKALAR - T.P. > VADELİ HESAP > KALKINMA VE YATIRIM BANKALARI | C+A |  |
| E | 10 | Money Market & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = TCMB | 04001 | 04001000 | DÖNEN DEĞERLER > DİĞER > PARA PİYASALARINDAN ALACAKLAR - T.P. | C+A |  |
| E | 20 | Money Market & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = TAKAS | 04002 | 04002000 | DÖNEN DEĞERLER > DİĞER | C+A |  |
| E | 30 | Money Market & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = BIST | 04003 | 04003000 | DÖNEN DEĞERLER > DİĞER > BANKALARARASI PARA PİYASASINDAN ALACAKLAR | C+A |  |
| E | 10 | Pas & IsAccountNeeded = 1 & UseExternalGLAccount = 0 | 04001 | 04001000 | DÖNEN DEĞERLER > DİĞER > PARA PİYASALARINDAN ALACAKLAR - T.P. | C+A |  |

### InterestReceived

| On | Order | Kurallar | THP | Target | THP adi | Cust/Acc | Not |
|---|---|---|---|---|---|---|---|
| E | 10 | Money Market & IsAccountNeeded = 1 & Market = OTC | 570011 | 57001100 | BANKALARDAN ALINAN FAİZLER -T.P. > YURTİÇİ BANKALARDAN > VADELİ HESAPLARDAN | C+A |  |
| E | 20 | Money Market & IsAccountNeeded = 1 & Market = TCMB | 57200 | 57200000 | (?) sayfa basligiyla birlesmis > PARA PİYASASI İŞLEMLERİNDEN ALINAN FAİZLER - T.P. > BANKALARARASI PARA PİYASASI İŞLEMLERİNDEN | C+A |  |
| E | 30 | Money Market & IsAccountNeeded = 1 & Market = TAKAS | 57201 | 57201000 | (?) sayfa basligiyla birlesmis > PARA PİYASASI İŞLEMLERİNDEN ALINAN FAİZLER - T.P. > TAKASBANK PİYASASINDAN | C+A |  |
| E | 40 | Money Market & IsAccountNeeded = 1 & Market = BIST | 57299 | 57299000 | (?) sayfa basligiyla birlesmis > PARA PİYASASI İŞLEMLERİNDEN ALINAN FAİZLER - T.P. > DİĞER | C+A |  |

### InterestIncome

| On | Order | Kurallar | THP | Target | THP adi | Cust/Acc | Not |
|---|---|---|---|---|---|---|---|
| E | 10 | Money Market & IsAccountNeeded = 1 & Market = OTC | 570011 | 57001100 | BANKALARDAN ALINAN FAİZLER -T.P. > YURTİÇİ BANKALARDAN > VADELİ HESAPLARDAN | C+A |  |
| E | 20 | Money Market & IsAccountNeeded = 1 & Market = TCMB | 57200 | 57200000 | (?) sayfa basligiyla birlesmis > PARA PİYASASI İŞLEMLERİNDEN ALINAN FAİZLER - T.P. > BANKALARARASI PARA PİYASASI İŞLEMLERİNDEN | C+A |  |
| E | 30 | Money Market & IsAccountNeeded = 1 & Market = TAKAS | 57201 | 57201000 | (?) sayfa basligiyla birlesmis > PARA PİYASASI İŞLEMLERİNDEN ALINAN FAİZLER - T.P. > TAKASBANK PİYASASINDAN | C+A |  |
| E | 40 | Money Market & IsAccountNeeded = 1 & Market = BIST | 57299 | 57299000 | (?) sayfa basligiyla birlesmis > PARA PİYASASI İŞLEMLERİNDEN ALINAN FAİZLER - T.P. > DİĞER | C+A |  |

### AccruedIncome

| On | Order | Kurallar | THP | Target | THP adi | Cust/Acc | Not |
|---|---|---|---|---|---|---|---|
| E | 10 | Money Market & IsAccountNeeded = 1 & Market = OTC | 22299 | 22299500 | (?) sayfa basligiyla birlesmis > GERÇEĞE UYGUN DEĞER FARKI KÂR/ZARARA YANSITILAN KREDİLER DEĞER ARTIŞLARI > İTFA EDİLMİŞ MALİYETİ ÜZERİNDEN ÖLÇÜLEN MENKUL DEĞERLER | C+A |  |
| E | 20 | Money Market & IsAccountNeeded = 1 & Market = TCMB | 22299 | 22299500 | (?) sayfa basligiyla birlesmis > GERÇEĞE UYGUN DEĞER FARKI KÂR/ZARARA YANSITILAN KREDİLER DEĞER ARTIŞLARI > İTFA EDİLMİŞ MALİYETİ ÜZERİNDEN ÖLÇÜLEN MENKUL DEĞERLER | C+A |  |
| E | 30 | Money Market & IsAccountNeeded = 1 & Market = TAKAS | 22299 | 22299500 | (?) sayfa basligiyla birlesmis > GERÇEĞE UYGUN DEĞER FARKI KÂR/ZARARA YANSITILAN KREDİLER DEĞER ARTIŞLARI > İTFA EDİLMİŞ MALİYETİ ÜZERİNDEN ÖLÇÜLEN MENKUL DEĞERLER | C+A |  |
| E | 40 | Money Market & IsAccountNeeded = 1 & Market = BIST | 22299 | 22299500 | (?) sayfa basligiyla birlesmis > GERÇEĞE UYGUN DEĞER FARKI KÂR/ZARARA YANSITILAN KREDİLER DEĞER ARTIŞLARI > İTFA EDİLMİŞ MALİYETİ ÜZERİNDEN ÖLÇÜLEN MENKUL DEĞERLER | C+A |  |

## TREX/BRWPLC1/MONEYMARKET/PLC/FCY

### CounterPartyGLAccount

| On | Order | Kurallar | THP | Target | THP adi | Cust/Acc | Not |
|---|---|---|---|---|---|---|---|
| E | 10 | IsAccountNeeded = 1 & UseExternalGLAccount = 1 |  | calc:ExternalGLAccount |  | C+A |  |
| E | 10 | Money Market & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = DOM & Mali Kesim & Kamu Mevduat Bankaları | 023010 | 02301000 | YURTİÇİ BANKALAR - Y.P. > VADELİ HESAP > KAMU MEVDUAT BANKALARI | C+A |  |
| E | 20 | Money Market & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = DOM & Mali Kesim & Özel Mevduat Bankaları | 023011 | 02301100 | YURTİÇİ BANKALAR - Y.P. > VADELİ HESAP > ÖZEL MEVDUAT BANKALARI | C+A |  |
| E | 30 | Money Market & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = DOM & Mali Kesim & Yabancı Mevduat Bankaları | 023012 | 02301200 | YURTİÇİ BANKALAR - Y.P. > VADELİ HESAP > YABANCI MEVDUAT BANKALARI | C+A |  |
| E | 40 | Money Market & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = DOM & Mali Kesim & Özel Kanunlara Göre Mevduat Kabulüne Yetkili Kuruluşlar | 023013 | 02301300 | YURTİÇİ BANKALAR - Y.P. > VADELİ HESAP > ÖZEL KANUNLARINA GÖRE MEVDUAT KABULÜNE YETKİLİ KURULUŞLAR | C+A |  |
| E | 50 | Money Market & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = DOM & Mali Kesim & Katılım Bankaları | 023014 | 02301400 | YURTİÇİ BANKALAR - Y.P. > VADELİ HESAP > KATILIM BANKALARI | C+A |  |
| E | 60 | Money Market & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = DOM & Mali Kesim & Kalkınma ve Yatırım Bankaları | 023015 | 02301500 | YURTİÇİ BANKALAR - Y.P. > VADELİ HESAP > KALKINMA VE YATIRIM BANKALARI | C+A |  |
| E | 10 | Money Market & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = TCMB | 04101 | 04101000 | DÖNEN DEĞERLER > BORSA İSTANBUL PARA PİYASASINDAN ALACAKLAR > PARA PİYASALARINDAN ALACAKLAR - Y.P. | C+A |  |
| E | 20 | Money Market & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = TAKAS | 04102 | 04102000 | DÖNEN DEĞERLER > BORSA İSTANBUL PARA PİYASASINDAN ALACAKLAR | C+A |  |
| E | 30 | Money Market & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = BIST | 04103 | 04103000 | DÖNEN DEĞERLER > BORSA İSTANBUL PARA PİYASASINDAN ALACAKLAR > BANKALARARASI PARA PİYASASINDAN ALACAKLAR | C+A |  |
| E | 10 | Money Market & IsAccountNeeded = 1 & UseExternalGLAccount = 0 | 04101 | 04101000 | DÖNEN DEĞERLER > BORSA İSTANBUL PARA PİYASASINDAN ALACAKLAR > PARA PİYASALARINDAN ALACAKLAR - Y.P. | C+A |  |

### InterestReceived

| On | Order | Kurallar | THP | Target | THP adi | Cust/Acc | Not |
|---|---|---|---|---|---|---|---|
| E | 10 | Money Market & IsAccountNeeded = 1 & Market = OTC | 571011 | 57101100 | BANKALARDAN ALINAN FAİZLER - Y.P. > YURTİÇİ BANKALARDAN > VADELİ HESAPLARDAN | C+A |  |
| E | 20 | Money Market & IsAccountNeeded = 1 & Market = TCMB | 57300 | 57300000 | (?) sayfa basligiyla birlesmis > PARA PİYASASI İŞLEMLERİNDEN ALINAN FAİZLER - Y.P. > BANKALARARASI PARA PİYASASI İŞLEMLERİNDEN | C+A |  |
| E | 30 | Money Market & IsAccountNeeded = 1 & Market = TAKAS | 57301 | 57301000 | (?) sayfa basligiyla birlesmis > PARA PİYASASI İŞLEMLERİNDEN ALINAN FAİZLER - Y.P. > TAKASBANK PİYASASINDAN | C+A |  |
| E | 40 | Money Market & IsAccountNeeded = 1 & Market = BIST | 57399 | 57399000 | (?) sayfa basligiyla birlesmis > PARA PİYASASI İŞLEMLERİNDEN ALINAN FAİZLER - Y.P. > DİĞER | C+A |  |

### InterestIncome

| On | Order | Kurallar | THP | Target | THP adi | Cust/Acc | Not |
|---|---|---|---|---|---|---|---|
| E | 10 | Money Market & IsAccountNeeded = 1 & Market = OTC | 571011 | 57101100 | BANKALARDAN ALINAN FAİZLER - Y.P. > YURTİÇİ BANKALARDAN > VADELİ HESAPLARDAN | C+A |  |
| E | 20 | Money Market & IsAccountNeeded = 1 & Market = TCMB | 57300 | 57300000 | (?) sayfa basligiyla birlesmis > PARA PİYASASI İŞLEMLERİNDEN ALINAN FAİZLER - Y.P. > BANKALARARASI PARA PİYASASI İŞLEMLERİNDEN | C+A |  |
| E | 30 | Money Market & IsAccountNeeded = 1 & Market = TAKAS | 57301 | 57301000 | (?) sayfa basligiyla birlesmis > PARA PİYASASI İŞLEMLERİNDEN ALINAN FAİZLER - Y.P. > TAKASBANK PİYASASINDAN | C+A |  |
| E | 40 | Money Market & IsAccountNeeded = 1 & Market = BIST | 57399 | 57399000 | (?) sayfa basligiyla birlesmis > PARA PİYASASI İŞLEMLERİNDEN ALINAN FAİZLER - Y.P. > DİĞER | C+A |  |

### AccruedIncome

| On | Order | Kurallar | THP | Target | THP adi | Cust/Acc | Not |
|---|---|---|---|---|---|---|---|
| E | 10 | Money Market & IsAccountNeeded = 1 & Market = OTC | 22399 | 22399500 | (?) sayfa basligiyla birlesmis > DİĞER | C+A |  |
| E | 20 | Money Market & IsAccountNeeded = 1 & Market = TCMB | 22399 | 22399500 | (?) sayfa basligiyla birlesmis > DİĞER | C+A |  |
| E | 30 | Money Market & IsAccountNeeded = 1 & Market = TAKAS | 22399 | 22399500 | (?) sayfa basligiyla birlesmis > DİĞER | C+A |  |
| E | 40 | Money Market & IsAccountNeeded = 1 & Market = BIST | 22399 | 22399500 | (?) sayfa basligiyla birlesmis > DİĞER | C+A |  |

## TREX/BRWPLC1/LOAN/BRW/LCY

### CounterPartyGLAccount

| On | Order | Kurallar | THP | Target | THP adi | Cust/Acc | Not |
|---|---|---|---|---|---|---|---|
| E | 10 | IsAccountNeeded = 1 & UseExternalGLAccount = 1 |  | calc:ExternalGLAccount |  | C+A |  |
| E | 10 | Interbank Loan & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = DOM & Term = Short & Mali Kesim & Bankalar | 34200 | 34200000 | ALACAKLARDAN DOLAYI EDİNİLEN DİĞER VARLIKLAR > TÜRKİYE CUMHURİYET MERKEZ BANKASI KREDİLERİ - T.P. > TÜRKİYE CUMHURİYET MERKEZ BANKASI KREDİLERİ - Y.P. | C+A |  |
| E | 100 | Interbank Loan & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = DOM & Term = Short | 34400 | 34400000 | ALACAKLARDAN DOLAYI EDİNİLEN DİĞER VARLIKLAR > ORTA VE UZUN VADELİ | C+A |  |
| E | 10 | Interbank Loan & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = DOM & Term = Long & Mali Kesim & Bankalar | 34210 | 34210000 | ALACAKLARDAN DOLAYI EDİNİLEN DİĞER VARLIKLAR > TÜRKİYE CUMHURİYET MERKEZ BANKASI KREDİLERİ - T.P. | C+A |  |
| E | 100 | Interbank Loan & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = DOM & Term = Long | 34410 | 34410000 | ALACAKLARDAN DOLAYI EDİNİLEN DİĞER VARLIKLAR | C+A |  |
| E | 10 | Interbank Loan & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = FRGN & Term = Short & Mali Kesim & Yurtdışı Bankalar | 348009 | 34800900 | SERMAYE BENZERİ BORÇLANMA ARAÇLARI > YURTDIŞINDAN KULLANILAN KREDİLER - T.P. > SENDİKASYON KREDİLERİ | C+A |  |
| E | 100 | Interbank Loan & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = FRGN & Term = Short | 348019 | 34801900 | SERMAYE BENZERİ BORÇLANMA ARAÇLARI > SEKÜRİTİZASYON KREDİLERİ > SENDİKASYON KREDİLERİ | C+A |  |
| E | 10 | Interbank Loan & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = FRGN & Term = Long & Mali Kesim & Yurtdışı Bankalar | 348109 | 34810900 | SERMAYE BENZERİ BORÇLANMA ARAÇLARI > SEKÜRİTİZASYON KREDİLERİ > SENDİKASYON KREDİLERİ | C+A |  |
| E | 100 | Interbank Loan & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = FRGN & Term = Long | 348119 | 34811900 | SERMAYE BENZERİ BORÇLANMA ARAÇLARI > SEKÜRİTİZASYON KREDİLERİ > SENDİKASYON KREDİLERİ | C+A |  |
| E | 10 | Murabaha & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = DOM & Term = Short & Mali Kesim & Bankalar | 34200 | 34200010 | ALACAKLARDAN DOLAYI EDİNİLEN DİĞER VARLIKLAR > TÜRKİYE CUMHURİYET MERKEZ BANKASI KREDİLERİ - T.P. > TÜRKİYE CUMHURİYET MERKEZ BANKASI KREDİLERİ - Y.P. | C+A |  |
| E | 100 | Murabaha & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = DOM & Term = Short | 34400 | 34400010 | ALACAKLARDAN DOLAYI EDİNİLEN DİĞER VARLIKLAR > ORTA VE UZUN VADELİ | C+A |  |
| E | 10 | Murabaha & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = DOM & Term = Long & Mali Kesim & Bankalar | 34210 | 34210010 | ALACAKLARDAN DOLAYI EDİNİLEN DİĞER VARLIKLAR > TÜRKİYE CUMHURİYET MERKEZ BANKASI KREDİLERİ - T.P. | C+A |  |
| E | 100 | Murabaha & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = DOM & Term = Long | 34410 | 34410010 | ALACAKLARDAN DOLAYI EDİNİLEN DİĞER VARLIKLAR | C+A |  |
| E | 10 | Murabaha & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = FRGN & Term = Short & Mali Kesim & Yurtdışı Bankalar | 348009 | 34800910 | SERMAYE BENZERİ BORÇLANMA ARAÇLARI > YURTDIŞINDAN KULLANILAN KREDİLER - T.P. > SENDİKASYON KREDİLERİ | C+A |  |
| E | 100 | Murabaha & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = FRGN & Term = Short | 348019 | 34801910 | SERMAYE BENZERİ BORÇLANMA ARAÇLARI > SEKÜRİTİZASYON KREDİLERİ > SENDİKASYON KREDİLERİ | C+A |  |
| E | 10 | Murabaha & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = FRGN & Term = Long & Mali Kesim & Yurtdışı Bankalar | 348109 | 34810910 | SERMAYE BENZERİ BORÇLANMA ARAÇLARI > SEKÜRİTİZASYON KREDİLERİ > SENDİKASYON KREDİLERİ | C+A |  |
| E | 100 | Murabaha & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = FRGN & Term = Long | 348119 | 34811910 | SERMAYE BENZERİ BORÇLANMA ARAÇLARI > SEKÜRİTİZASYON KREDİLERİ > SENDİKASYON KREDİLERİ | C+A |  |
| E | 10 | Wakala & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = DOM & Term = Short & Mali Kesim & Bankalar | 34200 | 34200020 | ALACAKLARDAN DOLAYI EDİNİLEN DİĞER VARLIKLAR > TÜRKİYE CUMHURİYET MERKEZ BANKASI KREDİLERİ - T.P. > TÜRKİYE CUMHURİYET MERKEZ BANKASI KREDİLERİ - Y.P. | C+A |  |
| E | 100 | Wakala & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = DOM & Term = Short | 34400 | 34400020 | ALACAKLARDAN DOLAYI EDİNİLEN DİĞER VARLIKLAR > ORTA VE UZUN VADELİ | C+A |  |
| E | 10 | Wakala & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = DOM & Term = Long & Mali Kesim & Bankalar | 34210 | 34210020 | ALACAKLARDAN DOLAYI EDİNİLEN DİĞER VARLIKLAR > TÜRKİYE CUMHURİYET MERKEZ BANKASI KREDİLERİ - T.P. | C+A |  |
| E | 100 | Wakala & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = DOM & Term = Long | 34410 | 34410020 | ALACAKLARDAN DOLAYI EDİNİLEN DİĞER VARLIKLAR | C+A |  |
| E | 10 | Wakala & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = FRGN & Term = Short & Mali Kesim & Yurtdışı Bankalar | 348009 | 34800920 | SERMAYE BENZERİ BORÇLANMA ARAÇLARI > YURTDIŞINDAN KULLANILAN KREDİLER - T.P. > SENDİKASYON KREDİLERİ | C+A |  |
| E | 100 | Wakala & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = FRGN & Term = Short | 348019 | 34801920 | SERMAYE BENZERİ BORÇLANMA ARAÇLARI > SEKÜRİTİZASYON KREDİLERİ > SENDİKASYON KREDİLERİ | C+A |  |
| E | 10 | Wakala & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = FRGN & Term = Long & Mali Kesim & Yurtdışı Bankalar | 348109 | 34810920 | SERMAYE BENZERİ BORÇLANMA ARAÇLARI > SEKÜRİTİZASYON KREDİLERİ > SENDİKASYON KREDİLERİ | C+A |  |
| E | 100 | Wakala & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = FRGN & Term = Long | 348119 | 34811920 | SERMAYE BENZERİ BORÇLANMA ARAÇLARI > SEKÜRİTİZASYON KREDİLERİ > SENDİKASYON KREDİLERİ | C+A |  |

### InterestPaid

| On | Order | Kurallar | THP | Target | THP adi | Cust/Acc | Not |
|---|---|---|---|---|---|---|---|
| E | 10 | Interbank Loan & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Short & Mali Kesim & Bankalar | 62200 | 62200000 | FAİZ GİDERLERİ > TÜRKİYE CUMHURİYET MERKEZ BANKASI KRED. VER. FAİZ. - T.P. > TÜRKİYE CUMHURİYET MERKEZ BANKASI KRED. VER. FAİZ. - Y.P. | C+A |  |
| E | 100 | Interbank Loan & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Short | 62201 | 62201000 | FAİZ GİDERLERİ > TÜRKİYE CUMHURİYET MERKEZ BANKASI KRED. VER. FAİZ. - T.P. | C+A |  |
| E | 10 | Interbank Loan & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Long & Mali Kesim & Bankalar | 62200 | 62200100 | FAİZ GİDERLERİ > TÜRKİYE CUMHURİYET MERKEZ BANKASI KRED. VER. FAİZ. - T.P. > TÜRKİYE CUMHURİYET MERKEZ BANKASI KRED. VER. FAİZ. - Y.P. | C+A |  |
| E | 100 | Interbank Loan & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Long | 62201 | 62201100 | FAİZ GİDERLERİ > TÜRKİYE CUMHURİYET MERKEZ BANKASI KRED. VER. FAİZ. - T.P. | C+A |  |
| E | 10 | Interbank Loan & IsAccountNeeded = 1 & Market = OTC & Customer Location = FRGN & Term = Short & Mali Kesim & Yurtdışı Bankalar | 62400 | 62400000 | FAİZ GİDERLERİ > YURTİÇİNDEKİ DİĞER KURULUŞLARDAN KULLANILAN KREDİLERE | C+A |  |
| E | 100 | Interbank Loan & IsAccountNeeded = 1 & Market = OTC & Customer Location = FRGN & Term = Short | 62401 | 62401000 | FAİZ GİDERLERİ | C+A |  |
| E | 10 | Interbank Loan & IsAccountNeeded = 1 & Market = OTC & Customer Location = FRGN & Term = Long & Mali Kesim & Yurtdışı Bankalar | 62400 | 62400100 | FAİZ GİDERLERİ > YURTİÇİNDEKİ DİĞER KURULUŞLARDAN KULLANILAN KREDİLERE | C+A |  |
| E | 100 | Interbank Loan & IsAccountNeeded = 1 & Market = OTC & Customer Location = FRGN & Term = Long | 62401 | 62401100 | FAİZ GİDERLERİ | C+A |  |
| E | 10 | Murabaha & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Short & Mali Kesim & Bankalar | 62200 | 62200010 | FAİZ GİDERLERİ > TÜRKİYE CUMHURİYET MERKEZ BANKASI KRED. VER. FAİZ. - T.P. > TÜRKİYE CUMHURİYET MERKEZ BANKASI KRED. VER. FAİZ. - Y.P. | C+A |  |
| E | 100 | Murabaha & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Short | 62201 | 62201010 | FAİZ GİDERLERİ > TÜRKİYE CUMHURİYET MERKEZ BANKASI KRED. VER. FAİZ. - T.P. | C+A |  |
| E | 10 | Murabaha & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Long & Mali Kesim & Bankalar | 62200 | 62200110 | FAİZ GİDERLERİ > TÜRKİYE CUMHURİYET MERKEZ BANKASI KRED. VER. FAİZ. - T.P. > TÜRKİYE CUMHURİYET MERKEZ BANKASI KRED. VER. FAİZ. - Y.P. | C+A |  |
| E | 100 | Murabaha & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Long | 62201 | 62201110 | FAİZ GİDERLERİ > TÜRKİYE CUMHURİYET MERKEZ BANKASI KRED. VER. FAİZ. - T.P. | C+A |  |
| E | 10 | Murabaha & IsAccountNeeded = 1 & Market = OTC & Customer Location = FRGN & Term = Short & Mali Kesim & Yurtdışı Bankalar | 62400 | 62400010 | FAİZ GİDERLERİ > YURTİÇİNDEKİ DİĞER KURULUŞLARDAN KULLANILAN KREDİLERE | C+A |  |
| E | 100 | Murabaha & IsAccountNeeded = 1 & Market = OTC & Customer Location = FRGN & Term = Short | 62401 | 62401010 | FAİZ GİDERLERİ | C+A |  |
| E | 10 | Murabaha & IsAccountNeeded = 1 & Market = OTC & Customer Location = FRGN & Term = Long & Mali Kesim & Yurtdışı Bankalar | 62400 | 62400110 | FAİZ GİDERLERİ > YURTİÇİNDEKİ DİĞER KURULUŞLARDAN KULLANILAN KREDİLERE | C+A |  |
| E | 100 | Murabaha & IsAccountNeeded = 1 & Market = OTC & Customer Location = FRGN & Term = Long | 62401 | 62401110 | FAİZ GİDERLERİ | C+A |  |
| E | 10 | Wakala & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Short & Mali Kesim & Bankalar | 62200 | 62200020 | FAİZ GİDERLERİ > TÜRKİYE CUMHURİYET MERKEZ BANKASI KRED. VER. FAİZ. - T.P. > TÜRKİYE CUMHURİYET MERKEZ BANKASI KRED. VER. FAİZ. - Y.P. | C+A |  |
| E | 100 | Wakala & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Short | 62201 | 62201020 | FAİZ GİDERLERİ > TÜRKİYE CUMHURİYET MERKEZ BANKASI KRED. VER. FAİZ. - T.P. | C+A |  |
| E | 10 | Wakala & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Long & Mali Kesim & Bankalar | 62200 | 62200120 | FAİZ GİDERLERİ > TÜRKİYE CUMHURİYET MERKEZ BANKASI KRED. VER. FAİZ. - T.P. > TÜRKİYE CUMHURİYET MERKEZ BANKASI KRED. VER. FAİZ. - Y.P. | C+A |  |
| E | 100 | Wakala & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Long | 62201 | 62201120 | FAİZ GİDERLERİ > TÜRKİYE CUMHURİYET MERKEZ BANKASI KRED. VER. FAİZ. - T.P. | C+A |  |
| E | 10 | Wakala & IsAccountNeeded = 1 & Market = OTC & Customer Location = FRGN & Term = Short & Mali Kesim & Yurtdışı Bankalar | 62400 | 62400020 | FAİZ GİDERLERİ > YURTİÇİNDEKİ DİĞER KURULUŞLARDAN KULLANILAN KREDİLERE | C+A |  |
| E | 100 | Wakala & IsAccountNeeded = 1 & Market = OTC & Customer Location = FRGN & Term = Short | 62401 | 62401020 | FAİZ GİDERLERİ | C+A |  |
| E | 10 | Wakala & IsAccountNeeded = 1 & Market = OTC & Customer Location = FRGN & Term = Long & Mali Kesim & Yurtdışı Bankalar | 62400 | 62400120 | FAİZ GİDERLERİ > YURTİÇİNDEKİ DİĞER KURULUŞLARDAN KULLANILAN KREDİLERE | C+A |  |
| E | 100 | Wakala & IsAccountNeeded = 1 & Market = OTC & Customer Location = FRGN & Term = Long | 62401 | 62401120 | FAİZ GİDERLERİ | C+A |  |

### InterestExpense

| On | Order | Kurallar | THP | Target | THP adi | Cust/Acc | Not |
|---|---|---|---|---|---|---|---|
| E | 10 | Interbank Loan & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Short & Mali Kesim & Bankalar | 62200 | 62200000 | FAİZ GİDERLERİ > TÜRKİYE CUMHURİYET MERKEZ BANKASI KRED. VER. FAİZ. - T.P. > TÜRKİYE CUMHURİYET MERKEZ BANKASI KRED. VER. FAİZ. - Y.P. | C+A |  |
| E | 100 | Interbank Loan & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Short | 62201 | 62201000 | FAİZ GİDERLERİ > TÜRKİYE CUMHURİYET MERKEZ BANKASI KRED. VER. FAİZ. - T.P. | C+A |  |
| E | 10 | Interbank Loan & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Long & Mali Kesim & Bankalar | 62200 | 62200100 | FAİZ GİDERLERİ > TÜRKİYE CUMHURİYET MERKEZ BANKASI KRED. VER. FAİZ. - T.P. > TÜRKİYE CUMHURİYET MERKEZ BANKASI KRED. VER. FAİZ. - Y.P. | C+A |  |
| E | 100 | Interbank Loan & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Long | 62201 | 62201100 | FAİZ GİDERLERİ > TÜRKİYE CUMHURİYET MERKEZ BANKASI KRED. VER. FAİZ. - T.P. | C+A |  |
| E | 10 | Interbank Loan & IsAccountNeeded = 1 & Market = OTC & Customer Location = FRGN & Term = Short & Mali Kesim & Yurtdışı Bankalar | 62400 | 62400000 | FAİZ GİDERLERİ > YURTİÇİNDEKİ DİĞER KURULUŞLARDAN KULLANILAN KREDİLERE | C+A |  |
| E | 100 | Interbank Loan & IsAccountNeeded = 1 & Market = OTC & Customer Location = FRGN & Term = Short | 62401 | 62401000 | FAİZ GİDERLERİ | C+A |  |
| E | 10 | Interbank Loan & IsAccountNeeded = 1 & Market = OTC & Customer Location = FRGN & Term = Long & Mali Kesim & Yurtdışı Bankalar | 62400 | 62400100 | FAİZ GİDERLERİ > YURTİÇİNDEKİ DİĞER KURULUŞLARDAN KULLANILAN KREDİLERE | C+A |  |
| E | 100 | Interbank Loan & IsAccountNeeded = 1 & Market = OTC & Customer Location = FRGN & Term = Long | 62401 | 62401100 | FAİZ GİDERLERİ | C+A |  |
| E | 10 | Murabaha & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Short & Mali Kesim & Bankalar | 62200 | 62200010 | FAİZ GİDERLERİ > TÜRKİYE CUMHURİYET MERKEZ BANKASI KRED. VER. FAİZ. - T.P. > TÜRKİYE CUMHURİYET MERKEZ BANKASI KRED. VER. FAİZ. - Y.P. | C+A |  |
| E | 100 | Murabaha & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Short | 62201 | 62201010 | FAİZ GİDERLERİ > TÜRKİYE CUMHURİYET MERKEZ BANKASI KRED. VER. FAİZ. - T.P. | C+A |  |
| E | 10 | Murabaha & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Long & Mali Kesim & Bankalar | 62200 | 62200110 | FAİZ GİDERLERİ > TÜRKİYE CUMHURİYET MERKEZ BANKASI KRED. VER. FAİZ. - T.P. > TÜRKİYE CUMHURİYET MERKEZ BANKASI KRED. VER. FAİZ. - Y.P. | C+A |  |
| E | 100 | Murabaha & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Long | 62201 | 62201110 | FAİZ GİDERLERİ > TÜRKİYE CUMHURİYET MERKEZ BANKASI KRED. VER. FAİZ. - T.P. | C+A |  |
| E | 10 | Murabaha & IsAccountNeeded = 1 & Market = OTC & Customer Location = FRGN & Term = Short & Mali Kesim & Yurtdışı Bankalar | 62400 | 62400010 | FAİZ GİDERLERİ > YURTİÇİNDEKİ DİĞER KURULUŞLARDAN KULLANILAN KREDİLERE | C+A |  |
| E | 100 | Murabaha & IsAccountNeeded = 1 & Market = OTC & Customer Location = FRGN & Term = Short | 62401 | 62401010 | FAİZ GİDERLERİ | C+A |  |
| E | 10 | Murabaha & IsAccountNeeded = 1 & Market = OTC & Customer Location = FRGN & Term = Long & Mali Kesim & Yurtdışı Bankalar | 62400 | 62400110 | FAİZ GİDERLERİ > YURTİÇİNDEKİ DİĞER KURULUŞLARDAN KULLANILAN KREDİLERE | C+A |  |
| E | 100 | Murabaha & IsAccountNeeded = 1 & Market = OTC & Customer Location = FRGN & Term = Long | 62401 | 62401110 | FAİZ GİDERLERİ | C+A |  |
| E | 10 | Wakala & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Short & Mali Kesim & Bankalar | 62200 | 62200020 | FAİZ GİDERLERİ > TÜRKİYE CUMHURİYET MERKEZ BANKASI KRED. VER. FAİZ. - T.P. > TÜRKİYE CUMHURİYET MERKEZ BANKASI KRED. VER. FAİZ. - Y.P. | C+A |  |
| E | 100 | Wakala & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Short | 62201 | 62201020 | FAİZ GİDERLERİ > TÜRKİYE CUMHURİYET MERKEZ BANKASI KRED. VER. FAİZ. - T.P. | C+A |  |
| E | 10 | Wakala & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Long & Mali Kesim & Bankalar | 62200 | 62200120 | FAİZ GİDERLERİ > TÜRKİYE CUMHURİYET MERKEZ BANKASI KRED. VER. FAİZ. - T.P. > TÜRKİYE CUMHURİYET MERKEZ BANKASI KRED. VER. FAİZ. - Y.P. | C+A |  |
| E | 100 | Wakala & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Long | 62201 | 62201120 | FAİZ GİDERLERİ > TÜRKİYE CUMHURİYET MERKEZ BANKASI KRED. VER. FAİZ. - T.P. | C+A |  |
| E | 10 | Wakala & IsAccountNeeded = 1 & Market = OTC & Customer Location = FRGN & Term = Short & Mali Kesim & Yurtdışı Bankalar | 62400 | 62400020 | FAİZ GİDERLERİ > YURTİÇİNDEKİ DİĞER KURULUŞLARDAN KULLANILAN KREDİLERE | C+A |  |
| E | 100 | Wakala & IsAccountNeeded = 1 & Market = OTC & Customer Location = FRGN & Term = Short | 62401 | 62401020 | FAİZ GİDERLERİ | C+A |  |
| E | 10 | Wakala & IsAccountNeeded = 1 & Market = OTC & Customer Location = FRGN & Term = Long & Mali Kesim & Yurtdışı Bankalar | 62400 | 62400120 | FAİZ GİDERLERİ > YURTİÇİNDEKİ DİĞER KURULUŞLARDAN KULLANILAN KREDİLERE | C+A |  |
| E | 100 | Wakala & IsAccountNeeded = 1 & Market = OTC & Customer Location = FRGN & Term = Long | 62401 | 62401120 | FAİZ GİDERLERİ | C+A |  |

### AccruedExpense

| On | Order | Kurallar | THP | Target | THP adi | Cust/Acc | Not |
|---|---|---|---|---|---|---|---|
| E | 10 | Interbank Loan & IsAccountNeeded = 1 | 36001 | 36001000 | ALACAKLARDAN DOLAYI EDİNİLEN DİĞER VARLIKLAR > KİRALAMA İŞLEMLERİNDEN BORÇLAR - T.P. > KİRALAMA İŞLEMLERİNDEN BORÇLAR - Y.P. | C+A |  |
| E | 10 | Murabaha & IsAccountNeeded = 1 | 36001 | 36001010 | ALACAKLARDAN DOLAYI EDİNİLEN DİĞER VARLIKLAR > KİRALAMA İŞLEMLERİNDEN BORÇLAR - T.P. > KİRALAMA İŞLEMLERİNDEN BORÇLAR - Y.P. | C+A |  |
| E | 10 | Wakala & IsAccountNeeded = 1 | 36001 | 36001020 | ALACAKLARDAN DOLAYI EDİNİLEN DİĞER VARLIKLAR > KİRALAMA İŞLEMLERİNDEN BORÇLAR - T.P. > KİRALAMA İŞLEMLERİNDEN BORÇLAR - Y.P. | C+A |  |

## TREX/BRWPLC1/LOAN/BRW/FCY

### CounterPartyGLAccount

| On | Order | Kurallar | THP | Target | THP adi | Cust/Acc | Not |
|---|---|---|---|---|---|---|---|
| E | 10 | IsAccountNeeded = 1 & UseExternalGLAccount = 1 |  | calc:ExternalGLAccount |  | C+A |  |
| E | 10 | Interbank Loan & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = DOM & Term = Short & Mali Kesim & Bankalar | 34300 | 34300000 | ALACAKLARDAN DOLAYI EDİNİLEN DİĞER VARLIKLAR > ORTA VE UZUN VADELİ | C+A |  |
| E | 100 | Interbank Loan & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = DOM & Term = Short | 34500 | 34500000 | ALACAKLARDAN DOLAYI EDİNİLEN DİĞER VARLIKLAR > ORTA VE UZUN VADELİ | C+A |  |
| E | 10 | Interbank Loan & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = DOM & Term = Long & Mali Kesim & Bankalar | 34310 | 34310000 | ALACAKLARDAN DOLAYI EDİNİLEN DİĞER VARLIKLAR | C+A |  |
| E | 100 | Interbank Loan & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = DOM & Term = Long | 34510 | 34510000 | ALACAKLARDAN DOLAYI EDİNİLEN DİĞER VARLIKLAR > (?) sayfa basligiyla birlesmis | C+A |  |
| E | 10 | Interbank Loan & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = FRGN & Term = Short & Mali Kesim & Yurtdışı Bankalar | 349009 | 34900900 | DİĞER > YURTDIŞINDAN KULLANILAN KREDİLER - Y.P. > SENDİKASYON KREDİLERİ | C+A |  |
| E | 100 | Interbank Loan & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = FRGN & Term = Short | 340019 | 34901900 | ALACAKLARDAN DOLAYI EDİNİLEN DİĞER VARLIKLAR | C+A |  |
| E | 10 | Interbank Loan & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = FRGN & Term = Long & Mali Kesim & Yurtdışı Bankalar | 349109 | 34910900 | DİĞER > SEKÜRİTİZASYON KREDİLERİ > SENDİKASYON KREDİLERİ | C+A |  |
| E | 100 | Interbank Loan & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = FRGN & Term = Long | 349119 | 34911900 | DİĞER > SEKÜRİTİZASYON KREDİLERİ > SENDİKASYON KREDİLERİ | C+A |  |
| E | 10 | Murabaha & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = DOM & Term = Short & Mali Kesim & Bankalar | 34300 | 34300010 | ALACAKLARDAN DOLAYI EDİNİLEN DİĞER VARLIKLAR > ORTA VE UZUN VADELİ | C+A |  |
| E | 100 | Murabaha & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = DOM & Term = Short | 34500 | 34500010 | ALACAKLARDAN DOLAYI EDİNİLEN DİĞER VARLIKLAR > ORTA VE UZUN VADELİ | C+A |  |
| E | 10 | Murabaha & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = DOM & Term = Long & Mali Kesim & Bankalar | 34310 | 34310010 | ALACAKLARDAN DOLAYI EDİNİLEN DİĞER VARLIKLAR | C+A |  |
| E | 100 | Murabaha & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = DOM & Term = Long | 34510 | 34510010 | ALACAKLARDAN DOLAYI EDİNİLEN DİĞER VARLIKLAR > (?) sayfa basligiyla birlesmis | C+A |  |
| E | 10 | Murabaha & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = FRGN & Term = Short & Mali Kesim & Yurtdışı Bankalar | 349009 | 34900910 | DİĞER > YURTDIŞINDAN KULLANILAN KREDİLER - Y.P. > SENDİKASYON KREDİLERİ | C+A |  |
| E | 100 | Murabaha & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = FRGN & Term = Short | 349019 | 34901910 | DİĞER > SEKÜRİTİZASYON KREDİLERİ > SENDİKASYON KREDİLERİ | C+A |  |
| E | 10 | Murabaha & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = FRGN & Term = Long & Mali Kesim & Yurtdışı Bankalar | 349109 | 34910910 | DİĞER > SEKÜRİTİZASYON KREDİLERİ > SENDİKASYON KREDİLERİ | C+A |  |
| E | 100 | Murabaha & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = FRGN & Term = Long | 349119 | 34911910 | DİĞER > SEKÜRİTİZASYON KREDİLERİ > SENDİKASYON KREDİLERİ | C+A |  |
| E | 10 | Wakala & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = DOM & Term = Short & Mali Kesim & Bankalar | 34300 | 34300020 | ALACAKLARDAN DOLAYI EDİNİLEN DİĞER VARLIKLAR > ORTA VE UZUN VADELİ | C+A |  |
| E | 100 | Wakala & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = DOM & Term = Short | 34500 | 34500020 | ALACAKLARDAN DOLAYI EDİNİLEN DİĞER VARLIKLAR > ORTA VE UZUN VADELİ | C+A |  |
| E | 10 | Wakala & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = DOM & Term = Long & Mali Kesim & Bankalar | 34310 | 34310020 | ALACAKLARDAN DOLAYI EDİNİLEN DİĞER VARLIKLAR | C+A |  |
| E | 100 | Wakala & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = DOM & Term = Long | 34510 | 34510020 | ALACAKLARDAN DOLAYI EDİNİLEN DİĞER VARLIKLAR > (?) sayfa basligiyla birlesmis | C+A |  |
| E | 10 | Wakala & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = FRGN & Term = Short & Mali Kesim & Yurtdışı Bankalar | 349009 | 34900920 | DİĞER > YURTDIŞINDAN KULLANILAN KREDİLER - Y.P. > SENDİKASYON KREDİLERİ | C+A |  |
| E | 100 | Wakala & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = FRGN & Term = Short | 349019 | 34901920 | DİĞER > SEKÜRİTİZASYON KREDİLERİ > SENDİKASYON KREDİLERİ | C+A |  |
| E | 10 | Wakala & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = FRGN & Term = Long & Mali Kesim & Yurtdışı Bankalar | 349109 | 34910920 | DİĞER > SEKÜRİTİZASYON KREDİLERİ > SENDİKASYON KREDİLERİ | C+A |  |
| E | 100 | Wakala & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = FRGN & Term = Long | 349119 | 34911920 | DİĞER > SEKÜRİTİZASYON KREDİLERİ > SENDİKASYON KREDİLERİ | C+A |  |

### InterestPaid

| On | Order | Kurallar | THP | Target | THP adi | Cust/Acc | Not |
|---|---|---|---|---|---|---|---|
| E | 10 | Interbank Loan & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Short & Mali Kesim & Bankalar | 62300 | 62300000 | FAİZ GİDERLERİ > YURTİÇİNDEKİ DİĞER KURULUŞLARDAN KULLANILAN KREDİLERE | C+A |  |
| E | 100 | Interbank Loan & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Short | 62301 | 62301000 | FAİZ GİDERLERİ | C+A |  |
| E | 10 | Interbank Loan & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Long & Mali Kesim & Bankalar | 62300 | 62300100 | FAİZ GİDERLERİ > YURTİÇİNDEKİ DİĞER KURULUŞLARDAN KULLANILAN KREDİLERE | C+A |  |
| E | 100 | Interbank Loan & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Long | 62301 | 62301100 | FAİZ GİDERLERİ | C+A |  |
| E | 10 | Interbank Loan & IsAccountNeeded = 1 & Market = OTC & Customer Location = FRGN & Term = Short & Mali Kesim & Yurtdışı Bankalar | 62500 | 62500000 | FAİZ GİDERLERİ > YURTDIŞINDAKİ BANKALARDAN KULLANILAN KREDİLERE > YURTDIŞINDAKİ FONLARDAN KULLANILAN KREDİLERE | C+A |  |
| E | 100 | Interbank Loan & IsAccountNeeded = 1 & Market = OTC & Customer Location = FRGN & Term = Short | 62501 | 62501000 | FAİZ GİDERLERİ > YURTDIŞINDAKİ BANKALARDAN KULLANILAN KREDİLERE | C+A |  |
| E | 10 | Interbank Loan & IsAccountNeeded = 1 & Market = OTC & Customer Location = FRGN & Term = Long & Mali Kesim & Yurtdışı Bankalar | 62500 | 62500100 | FAİZ GİDERLERİ > YURTDIŞINDAKİ BANKALARDAN KULLANILAN KREDİLERE > YURTDIŞINDAKİ FONLARDAN KULLANILAN KREDİLERE | C+A |  |
| E | 100 | Interbank Loan & IsAccountNeeded = 1 & Market = OTC & Customer Location = FRGN & Term = Long | 62501 | 62501100 | FAİZ GİDERLERİ > YURTDIŞINDAKİ BANKALARDAN KULLANILAN KREDİLERE | C+A |  |
| E | 10 | Murabaha & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Short & Mali Kesim & Bankalar | 62300 | 62300010 | FAİZ GİDERLERİ > YURTİÇİNDEKİ DİĞER KURULUŞLARDAN KULLANILAN KREDİLERE | C+A |  |
| E | 100 | Murabaha & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Short | 62301 | 62301010 | FAİZ GİDERLERİ | C+A |  |
| E | 10 | Murabaha & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Long & Mali Kesim & Bankalar | 62300 | 62300110 | FAİZ GİDERLERİ > YURTİÇİNDEKİ DİĞER KURULUŞLARDAN KULLANILAN KREDİLERE | C+A |  |
| E | 100 | Murabaha & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Long | 62301 | 62301110 | FAİZ GİDERLERİ | C+A |  |
| E | 10 | Murabaha & IsAccountNeeded = 1 & Market = OTC & Customer Location = FRGN & Term = Short & Mali Kesim & Yurtdışı Bankalar | 62500 | 62500010 | FAİZ GİDERLERİ > YURTDIŞINDAKİ BANKALARDAN KULLANILAN KREDİLERE > YURTDIŞINDAKİ FONLARDAN KULLANILAN KREDİLERE | C+A |  |
| E | 100 | Murabaha & IsAccountNeeded = 1 & Market = OTC & Customer Location = FRGN & Term = Short | 62501 | 62501010 | FAİZ GİDERLERİ > YURTDIŞINDAKİ BANKALARDAN KULLANILAN KREDİLERE | C+A |  |
| E | 10 | Murabaha & IsAccountNeeded = 1 & Market = OTC & Customer Location = FRGN & Term = Long & Mali Kesim & Yurtdışı Bankalar | 62500 | 62500110 | FAİZ GİDERLERİ > YURTDIŞINDAKİ BANKALARDAN KULLANILAN KREDİLERE > YURTDIŞINDAKİ FONLARDAN KULLANILAN KREDİLERE | C+A |  |
| E | 100 | Murabaha & IsAccountNeeded = 1 & Market = OTC & Customer Location = FRGN & Term = Long | 62501 | 62501110 | FAİZ GİDERLERİ > YURTDIŞINDAKİ BANKALARDAN KULLANILAN KREDİLERE | C+A |  |
| E | 10 | Wakala & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Short & Mali Kesim & Bankalar | 62300 | 62300020 | FAİZ GİDERLERİ > YURTİÇİNDEKİ DİĞER KURULUŞLARDAN KULLANILAN KREDİLERE | C+A |  |
| E | 100 | Wakala & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Short | 62301 | 62301020 | FAİZ GİDERLERİ | C+A |  |
| E | 10 | Wakala & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Long & Mali Kesim & Bankalar | 62300 | 62300120 | FAİZ GİDERLERİ > YURTİÇİNDEKİ DİĞER KURULUŞLARDAN KULLANILAN KREDİLERE | C+A |  |
| E | 100 | Wakala & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Long | 62301 | 62301120 | FAİZ GİDERLERİ | C+A |  |
| E | 10 | Wakala & IsAccountNeeded = 1 & Market = OTC & Customer Location = FRGN & Term = Short & Mali Kesim & Yurtdışı Bankalar | 62500 | 62500020 | FAİZ GİDERLERİ > YURTDIŞINDAKİ BANKALARDAN KULLANILAN KREDİLERE > YURTDIŞINDAKİ FONLARDAN KULLANILAN KREDİLERE | C+A |  |
| E | 100 | Wakala & IsAccountNeeded = 1 & Market = OTC & Customer Location = FRGN & Term = Short | 62501 | 62501020 | FAİZ GİDERLERİ > YURTDIŞINDAKİ BANKALARDAN KULLANILAN KREDİLERE | C+A |  |
| E | 10 | Wakala & IsAccountNeeded = 1 & Market = OTC & Customer Location = FRGN & Term = Long & Mali Kesim & Yurtdışı Bankalar | 62500 | 62500120 | FAİZ GİDERLERİ > YURTDIŞINDAKİ BANKALARDAN KULLANILAN KREDİLERE > YURTDIŞINDAKİ FONLARDAN KULLANILAN KREDİLERE | C+A |  |
| E | 100 | Wakala & IsAccountNeeded = 1 & Market = OTC & Customer Location = FRGN & Term = Long | 62501 | 62501120 | FAİZ GİDERLERİ > YURTDIŞINDAKİ BANKALARDAN KULLANILAN KREDİLERE | C+A |  |

### InterestExpense

| On | Order | Kurallar | THP | Target | THP adi | Cust/Acc | Not |
|---|---|---|---|---|---|---|---|
| E | 10 | Interbank Loan & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Short & Mali Kesim & Bankalar | 62300 | 62300000 | FAİZ GİDERLERİ > YURTİÇİNDEKİ DİĞER KURULUŞLARDAN KULLANILAN KREDİLERE | C+A |  |
| E | 100 | Interbank Loan & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Short | 62301 | 62301000 | FAİZ GİDERLERİ | C+A |  |
| E | 10 | Interbank Loan & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Long & Mali Kesim & Bankalar | 62300 | 62300100 | FAİZ GİDERLERİ > YURTİÇİNDEKİ DİĞER KURULUŞLARDAN KULLANILAN KREDİLERE | C+A |  |
| E | 100 | Interbank Loan & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Long | 62301 | 62301100 | FAİZ GİDERLERİ | C+A |  |
| E | 10 | Interbank Loan & IsAccountNeeded = 1 & Market = OTC & Customer Location = FRGN & Term = Short & Mali Kesim & Yurtdışı Bankalar | 62500 | 62500000 | FAİZ GİDERLERİ > YURTDIŞINDAKİ BANKALARDAN KULLANILAN KREDİLERE > YURTDIŞINDAKİ FONLARDAN KULLANILAN KREDİLERE | C+A |  |
| E | 100 | Interbank Loan & IsAccountNeeded = 1 & Market = OTC & Customer Location = FRGN & Term = Short | 62501 | 62501000 | FAİZ GİDERLERİ > YURTDIŞINDAKİ BANKALARDAN KULLANILAN KREDİLERE | C+A |  |
| E | 10 | Interbank Loan & IsAccountNeeded = 1 & Market = OTC & Customer Location = FRGN & Term = Long & Mali Kesim & Yurtdışı Bankalar | 62500 | 62500100 | FAİZ GİDERLERİ > YURTDIŞINDAKİ BANKALARDAN KULLANILAN KREDİLERE > YURTDIŞINDAKİ FONLARDAN KULLANILAN KREDİLERE | C+A |  |
| E | 100 | Interbank Loan & IsAccountNeeded = 1 & Market = OTC & Customer Location = FRGN & Term = Long | 62501 | 62501100 | FAİZ GİDERLERİ > YURTDIŞINDAKİ BANKALARDAN KULLANILAN KREDİLERE | C+A |  |
| E | 10 | Murabaha & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Short & Mali Kesim & Bankalar | 62300 | 62300010 | FAİZ GİDERLERİ > YURTİÇİNDEKİ DİĞER KURULUŞLARDAN KULLANILAN KREDİLERE | C+A |  |
| E | 100 | Murabaha & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Short | 62301 | 62301010 | FAİZ GİDERLERİ | C+A |  |
| E | 10 | Murabaha & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Long & Mali Kesim & Bankalar | 62300 | 62300110 | FAİZ GİDERLERİ > YURTİÇİNDEKİ DİĞER KURULUŞLARDAN KULLANILAN KREDİLERE | C+A |  |
| E | 100 | Murabaha & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Long | 62301 | 62301110 | FAİZ GİDERLERİ | C+A |  |
| E | 10 | Murabaha & IsAccountNeeded = 1 & Market = OTC & Customer Location = FRGN & Term = Short & Mali Kesim & Yurtdışı Bankalar | 62500 | 62500010 | FAİZ GİDERLERİ > YURTDIŞINDAKİ BANKALARDAN KULLANILAN KREDİLERE > YURTDIŞINDAKİ FONLARDAN KULLANILAN KREDİLERE | C+A |  |
| E | 100 | Murabaha & IsAccountNeeded = 1 & Market = OTC & Customer Location = FRGN & Term = Short | 62501 | 62501010 | FAİZ GİDERLERİ > YURTDIŞINDAKİ BANKALARDAN KULLANILAN KREDİLERE | C+A |  |
| E | 10 | Murabaha & IsAccountNeeded = 1 & Market = OTC & Customer Location = FRGN & Term = Long & Mali Kesim & Yurtdışı Bankalar | 62500 | 62500110 | FAİZ GİDERLERİ > YURTDIŞINDAKİ BANKALARDAN KULLANILAN KREDİLERE > YURTDIŞINDAKİ FONLARDAN KULLANILAN KREDİLERE | C+A |  |
| E | 100 | Murabaha & IsAccountNeeded = 1 & Market = OTC & Customer Location = FRGN & Term = Long | 62501 | 62501110 | FAİZ GİDERLERİ > YURTDIŞINDAKİ BANKALARDAN KULLANILAN KREDİLERE | C+A |  |
| E | 10 | Wakala & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Short & Mali Kesim & Bankalar | 62300 | 62300020 | FAİZ GİDERLERİ > YURTİÇİNDEKİ DİĞER KURULUŞLARDAN KULLANILAN KREDİLERE | C+A |  |
| E | 100 | Wakala & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Short | 62301 | 62301020 | FAİZ GİDERLERİ | C+A |  |
| E | 10 | Wakala & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Long & Mali Kesim & Bankalar | 62300 | 62300120 | FAİZ GİDERLERİ > YURTİÇİNDEKİ DİĞER KURULUŞLARDAN KULLANILAN KREDİLERE | C+A |  |
| E | 100 | Wakala & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Long | 62301 | 62301120 | FAİZ GİDERLERİ | C+A |  |
| E | 10 | Wakala & IsAccountNeeded = 1 & Market = OTC & Customer Location = FRGN & Term = Short & Mali Kesim & Yurtdışı Bankalar | 62500 | 62500020 | FAİZ GİDERLERİ > YURTDIŞINDAKİ BANKALARDAN KULLANILAN KREDİLERE > YURTDIŞINDAKİ FONLARDAN KULLANILAN KREDİLERE | C+A |  |
| E | 100 | Wakala & IsAccountNeeded = 1 & Market = OTC & Customer Location = FRGN & Term = Short | 62501 | 62501020 | FAİZ GİDERLERİ > YURTDIŞINDAKİ BANKALARDAN KULLANILAN KREDİLERE | C+A |  |
| E | 10 | Wakala & IsAccountNeeded = 1 & Market = OTC & Customer Location = FRGN & Term = Long & Mali Kesim & Yurtdışı Bankalar | 62500 | 62500120 | FAİZ GİDERLERİ > YURTDIŞINDAKİ BANKALARDAN KULLANILAN KREDİLERE > YURTDIŞINDAKİ FONLARDAN KULLANILAN KREDİLERE | C+A |  |
| E | 100 | Wakala & IsAccountNeeded = 1 & Market = OTC & Customer Location = FRGN & Term = Long | 62501 | 62501120 | FAİZ GİDERLERİ > YURTDIŞINDAKİ BANKALARDAN KULLANILAN KREDİLERE | C+A |  |

### AccruedExpense

| On | Order | Kurallar | THP | Target | THP adi | Cust/Acc | Not |
|---|---|---|---|---|---|---|---|
| E | 10 | Interbank Loan & IsAccountNeeded = 1 | 36101 | 36101000 | ALACAKLARDAN DOLAYI EDİNİLEN DİĞER VARLIKLAR > FAİZ VE GİDER REESKONTLARI - Y.P. | C+A |  |
| E | 10 | Murabaha & IsAccountNeeded = 1 | 36101 | 36101010 | ALACAKLARDAN DOLAYI EDİNİLEN DİĞER VARLIKLAR > FAİZ VE GİDER REESKONTLARI - Y.P. | C+A |  |
| E | 10 | Wakala & IsAccountNeeded = 1 | 36101 | 36101020 | ALACAKLARDAN DOLAYI EDİNİLEN DİĞER VARLIKLAR > FAİZ VE GİDER REESKONTLARI - Y.P. | C+A |  |

## TREX/BRWPLC1/LOAN/PLC/LCY

### CounterPartyGLAccount

| On | Order | Kurallar | THP | Target | THP adi | Cust/Acc | Not |
|---|---|---|---|---|---|---|---|
| E | 10 | IsAccountNeeded = 1 & UseExternalGLAccount = 1 |  | calc:ExternalGLAccount |  | C+A |  |
| E | 10 | Interbank Loan & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = DOM & Term = Short & Teminatsız & Mali Kesim & Kamu Mevduat Bankaları | 126000 | 12600000 | MALİ KESİME KULLANDIRILAN KISA VADELİ KREDİLER - T.P. > AÇIK > KAMU MEVDUAT BANKALARI | C+A |  |
| E | 20 | Interbank Loan & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = DOM & Term = Short & Teminatsız & Mali Kesim & Özel Mevduat Bankaları | 126001 | 12600100 | MALİ KESİME KULLANDIRILAN KISA VADELİ KREDİLER - T.P. > AÇIK > ÖZEL MEVDUAT BANKALARI | C+A |  |
| E | 30 | Interbank Loan & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = DOM & Term = Short & Teminatsız & Mali Kesim & Yabancı Mevduat Bankaları | 126002 | 12600200 | MALİ KESİME KULLANDIRILAN KISA VADELİ KREDİLER - T.P. > AÇIK > YABANCI MEVDUAT BANKALARI | C+A |  |
| E | 40 | Interbank Loan & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = DOM & Term = Short & Teminatsız & Mali Kesim & Kamu Kalkınma ve Yatırım Bankaları | 126003 | 12600300 | MALİ KESİME KULLANDIRILAN KISA VADELİ KREDİLER - T.P. > AÇIK > KAMU KALKINMA VE YATIRIM BANKALARI | C+A |  |
| E | 50 | Interbank Loan & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = DOM & Term = Short & Teminatsız & Mali Kesim & Özel Kalkınma ve Yatırım Bankaları | 126004 | 12600400 | MALİ KESİME KULLANDIRILAN KISA VADELİ KREDİLER - T.P. > AÇIK > ÖZEL KALKINMA VE YATIRIM BANKALARI | C+A |  |
| E | 10 | Interbank Loan & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = DOM & Term = Short & Teminatlı & Mali Kesim & Kamu Mevduat Bankaları | 126010 | 12601000 | MALİ KESİME KULLANDIRILAN KISA VADELİ KREDİLER - T.P. > TEMİNATLI > KAMU MEVDUAT BANKALARI | C+A |  |
| E | 20 | Interbank Loan & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = DOM & Term = Short & Teminatlı & Mali Kesim & Özel Mevduat Bankaları | 126011 | 12601100 | MALİ KESİME KULLANDIRILAN KISA VADELİ KREDİLER - T.P. > TEMİNATLI > ÖZEL MEVDUAT BANKALARI | C+A |  |
| E | 30 | Interbank Loan & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = DOM & Term = Short & Teminatlı & Mali Kesim & Yabancı Mevduat Bankaları | 126012 | 12601200 | MALİ KESİME KULLANDIRILAN KISA VADELİ KREDİLER - T.P. > TEMİNATLI > YABANCI MEVDUAT BANKALARI | C+A |  |
| E | 40 | Interbank Loan & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = DOM & Term = Short & Teminatlı & Mali Kesim & Kamu Kalkınma ve Yatırım Bankaları | 126013 | 12601300 | MALİ KESİME KULLANDIRILAN KISA VADELİ KREDİLER - T.P. > TEMİNATLI > KAMU KALKINMA VE YATIRIM BANKALARI | C+A |  |
| E | 50 | Interbank Loan & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = DOM & Term = Short & Teminatlı & Mali Kesim & Özel Kalkınma ve Yatırım Bankaları | 126014 | 12601400 | MALİ KESİME KULLANDIRILAN KISA VADELİ KREDİLER - T.P. > TEMİNATLI > ÖZEL KALKINMA VE YATIRIM BANKALARI | C+A |  |
| E | 10 | Interbank Loan & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = DOM & Term = Long & Teminatsız & Mali Kesim & Kamu Mevduat Bankaları | 146000 | 14600000 | MALİ KESİME KULLANDIRILAN ORTA VE UZUN VADELİ KREDİLER - T.P. > AÇIK > KAMU MEVDUAT BANKALARI | C+A |  |
| E | 20 | Interbank Loan & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = DOM & Term = Long & Teminatsız & Mali Kesim & Özel Mevduat Bankaları | 146001 | 14600100 | MALİ KESİME KULLANDIRILAN ORTA VE UZUN VADELİ KREDİLER - T.P. > AÇIK > ÖZEL MEVDUAT BANKALARI | C+A |  |
| E | 30 | Interbank Loan & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = DOM & Term = Long & Teminatsız & Mali Kesim & Yabancı Mevduat Bankaları | 146002 | 14600200 | MALİ KESİME KULLANDIRILAN ORTA VE UZUN VADELİ KREDİLER - T.P. > AÇIK > YABANCI MEVDUAT BANKALARI | C+A |  |
| E | 40 | Interbank Loan & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = DOM & Term = Long & Teminatsız & Mali Kesim & Kamu Kalkınma ve Yatırım Bankaları | 146003 | 14600300 | MALİ KESİME KULLANDIRILAN ORTA VE UZUN VADELİ KREDİLER - T.P. > AÇIK > KAMU KALKINMA VE YATIRIM BANKALARI | C+A |  |
| E | 50 | Interbank Loan & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = DOM & Term = Long & Teminatsız & Mali Kesim & Özel Kalkınma ve Yatırım Bankaları | 146004 | 14600400 | MALİ KESİME KULLANDIRILAN ORTA VE UZUN VADELİ KREDİLER - T.P. > AÇIK > ÖZEL KALKINMA VE YATIRIM BANKALARI | C+A |  |
| E | 10 | Interbank Loan & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = DOM & Term = Long & Teminatlı & Mali Kesim & Kamu Mevduat Bankaları | 146010 | 14601000 | MALİ KESİME KULLANDIRILAN ORTA VE UZUN VADELİ KREDİLER - T.P. > TEMİNATLI > KAMU MEVDUAT BANKALARI | C+A |  |
| E | 20 | Interbank Loan & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = DOM & Term = Long & Teminatlı & Mali Kesim & Özel Mevduat Bankaları | 146011 | 14601100 | MALİ KESİME KULLANDIRILAN ORTA VE UZUN VADELİ KREDİLER - T.P. > TEMİNATLI > ÖZEL MEVDUAT BANKALARI | C+A |  |
| E | 30 | Interbank Loan & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = DOM & Term = Long & Teminatlı & Mali Kesim & Yabancı Mevduat Bankaları | 146012 | 14601200 | MALİ KESİME KULLANDIRILAN ORTA VE UZUN VADELİ KREDİLER - T.P. > TEMİNATLI > YABANCI MEVDUAT BANKALARI | C+A |  |
| E | 40 | Interbank Loan & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = DOM & Term = Long & Teminatlı & Mali Kesim & Kamu Kalkınma ve Yatırım Bankaları | 146013 | 14601300 | MALİ KESİME KULLANDIRILAN ORTA VE UZUN VADELİ KREDİLER - T.P. > TEMİNATLI > KAMU KALKINMA VE YATIRIM BANKALARI | C+A |  |
| E | 50 | Interbank Loan & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = DOM & Term = Long & Teminatlı & Mali Kesim & Özel Kalkınma ve Yatırım Bankaları | 146014 | 14601400 | MALİ KESİME KULLANDIRILAN ORTA VE UZUN VADELİ KREDİLER - T.P. > TEMİNATLI > ÖZEL KALKINMA VE YATIRIM BANKALARI | C+A |  |
| E | 10 | Interbank Loan & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = FRGN & Term = Short & Teminatsız & Mali Kesim & Yurtdışı Bankalar | 128000 | 12800000 | YURTDIŞI KISA VADELİ KREDİLER - T.P. > BANKALAR > AÇIK | C+A |  |
| E | 10 | Interbank Loan & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = FRGN & Term = Short & Teminatlı & Mali Kesim & Yurtdışı Bankalar | 128001 | 12800100 | YURTDIŞI KISA VADELİ KREDİLER - T.P. > BANKALAR > TEMİNATLI | C+A |  |
| E | 10 | Interbank Loan & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = FRGN & Term = Long & Teminatsız & Mali Kesim & Yurtdışı Bankalar | 148000 | 14800000 | YURTDIŞI ORTA VE UZUN VADELİ KREDİLER - T.P. > BANKALAR > AÇIK | C+A |  |
| E | 10 | Interbank Loan & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = FRGN & Term = Long & Teminatlı & Mali Kesim & Yurtdışı Bankalar | 148001 | 14800100 | YURTDIŞI ORTA VE UZUN VADELİ KREDİLER - T.P. > BANKALAR > TEMİNATLI | C+A |  |
| E | 10 | Murabaha & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = DOM & Term = Short & Teminatsız & Mali Kesim & Katılım Bankaları | 126005 | 12600510 | MALİ KESİME KULLANDIRILAN KISA VADELİ KREDİLER - T.P. > AÇIK > KATILIM BANKALARI | C+A |  |
| E | 10 | Murabaha & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = DOM & Term = Short & Teminatlı & Mali Kesim & Katılım Bankaları | 126015 | 12601510 | MALİ KESİME KULLANDIRILAN KISA VADELİ KREDİLER - T.P. > TEMİNATLI > KATILIM BANKALARI | C+A |  |
| E | 10 | Murabaha & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = DOM & Term = Long & Teminatsız & Mali Kesim & Katılım Bankaları | 146005 | 14600510 | MALİ KESİME KULLANDIRILAN ORTA VE UZUN VADELİ KREDİLER - T.P. > AÇIK > KATILIM BANKALARI | C+A |  |
| E | 10 | Murabaha & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = DOM & Term = Long & Teminatlı & Mali Kesim & Katılım Bankaları | 146015 | 14601510 | MALİ KESİME KULLANDIRILAN ORTA VE UZUN VADELİ KREDİLER - T.P. > TEMİNATLI > KATILIM BANKALARI | C+A |  |
| E | 10 | Murabaha & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = FRGN & Term = Short & Teminatsız & Mali Kesim & Yurtdışı Bankalar | 128000 | 12800010 | YURTDIŞI KISA VADELİ KREDİLER - T.P. > BANKALAR > AÇIK | C+A |  |
| E | 10 | Murabaha & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = FRGN & Term = Short & Teminatlı & Mali Kesim & Yurtdışı Bankalar | 128001 | 12800110 | YURTDIŞI KISA VADELİ KREDİLER - T.P. > BANKALAR > TEMİNATLI | C+A |  |
| E | 10 | Murabaha & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = FRGN & Term = Long & Teminatsız & Mali Kesim & Yurtdışı Bankalar | 148000 | 14800010 | YURTDIŞI ORTA VE UZUN VADELİ KREDİLER - T.P. > BANKALAR > AÇIK | C+A |  |
| E | 10 | Murabaha & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = FRGN & Term = Long & Teminatlı & Mali Kesim & Yurtdışı Bankalar | 148001 | 14800110 | YURTDIŞI ORTA VE UZUN VADELİ KREDİLER - T.P. > BANKALAR > TEMİNATLI | C+A |  |
| E | 10 | Wakala & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = DOM & Term = Short & Teminatsız & Mali Kesim & Katılım Bankaları | 126005 | 12600520 | MALİ KESİME KULLANDIRILAN KISA VADELİ KREDİLER - T.P. > AÇIK > KATILIM BANKALARI | C+A |  |
| E | 10 | Wakala & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = DOM & Term = Short & Teminatlı & Mali Kesim & Katılım Bankaları | 126015 | 12601520 | MALİ KESİME KULLANDIRILAN KISA VADELİ KREDİLER - T.P. > TEMİNATLI > KATILIM BANKALARI | C+A |  |
| E | 10 | Wakala & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = DOM & Term = Long & Teminatsız & Mali Kesim & Katılım Bankaları | 146005 | 14600520 | MALİ KESİME KULLANDIRILAN ORTA VE UZUN VADELİ KREDİLER - T.P. > AÇIK > KATILIM BANKALARI | C+A |  |
| E | 10 | Wakala & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = DOM & Term = Long & Teminatlı & Mali Kesim & Katılım Bankaları | 146015 | 14601520 | MALİ KESİME KULLANDIRILAN ORTA VE UZUN VADELİ KREDİLER - T.P. > TEMİNATLI > KATILIM BANKALARI | C+A |  |
| E | 10 | Wakala & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = FRGN & Term = Short & Teminatsız & Mali Kesim & Yurtdışı Bankalar | 128000 | 12800020 | YURTDIŞI KISA VADELİ KREDİLER - T.P. > BANKALAR > AÇIK | C+A |  |
| E | 10 | Wakala & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = FRGN & Term = Short & Teminatlı & Mali Kesim & Yurtdışı Bankalar | 128001 | 12800120 | YURTDIŞI KISA VADELİ KREDİLER - T.P. > BANKALAR > TEMİNATLI | C+A |  |
| E | 10 | Wakala & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = FRGN & Term = Long & Teminatsız & Mali Kesim & Yurtdışı Bankalar | 148000 | 14800020 | YURTDIŞI ORTA VE UZUN VADELİ KREDİLER - T.P. > BANKALAR > AÇIK | C+A |  |
| E | 10 | Wakala & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = FRGN & Term = Long & Teminatlı & Mali Kesim & Yurtdışı Bankalar | 148001 | 14800120 | YURTDIŞI ORTA VE UZUN VADELİ KREDİLER - T.P. > BANKALAR > TEMİNATLI | C+A |  |

### InterestReceived

| On | Order | Kurallar | THP | Target | THP adi | Cust/Acc | Not |
|---|---|---|---|---|---|---|---|
| E | 10 | Interbank Loan & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Short & Mali Kesim & Kamu Mevduat Bankaları | 52000 | 52000000 | (?) sayfa basligiyla birlesmis > KISA VADELİ FON KAYNAKLI KREDİLERDEN ALINAN FAİZLER - Y.P. > MALİ KESİME KULLANDIRILAN KISA VADELİ KREDİLERDEN ALINAN FAİZLER-T.P. | C+A |  |
| E | 20 | Interbank Loan & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Short & Mali Kesim & Özel Mevduat Bankaları | 52001 | 52001000 | (?) sayfa basligiyla birlesmis > KISA VADELİ FON KAYNAKLI KREDİLERDEN ALINAN FAİZLER - Y.P. | C+A |  |
| E | 30 | Interbank Loan & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Short & Mali Kesim & Yabancı Mevduat Bankaları | 52002 | 52002000 | (?) sayfa basligiyla birlesmis > KISA VADELİ FON KAYNAKLI KREDİLERDEN ALINAN FAİZLER - Y.P. > KAMU MEVDUAT BANKALARINDAN | C+A |  |
| E | 40 | Interbank Loan & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Short & Mali Kesim & Kamu Kalkınma ve Yatırım Bankaları | 52003 | 52003000 | (?) sayfa basligiyla birlesmis > KISA VADELİ FON KAYNAKLI KREDİLERDEN ALINAN FAİZLER - Y.P. > ÖZEL MEVDUAT BANKALARINDAN | C+A |  |
| E | 50 | Interbank Loan & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Short & Mali Kesim & Özel Kalkınma ve Yatırım Bankaları | 52004 | 52004000 | (?) sayfa basligiyla birlesmis > KISA VADELİ FON KAYNAKLI KREDİLERDEN ALINAN FAİZLER - Y.P. > YABANCI MEVDUAT BANKALARINDAN | C+A |  |
| E | 10 | Interbank Loan & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Long & Mali Kesim & Kamu Mevduat Bankaları | 54000 | 54000000 | (?) sayfa basligiyla birlesmis > ORTA VE UZUN VADELİ FON KAYNAKLI KREDİLERDEN ALINAN FAİZLER - Y.P. > MALİ KESİME KULLANDIRILAN ORTA UZUN VADELİ KREDİLERDEN ALINAN FAİZ- | C+A |  |
| E | 20 | Interbank Loan & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Long & Mali Kesim & Özel Mevduat Bankaları | 54001 | 54001000 | (?) sayfa basligiyla birlesmis > ORTA VE UZUN VADELİ FON KAYNAKLI KREDİLERDEN ALINAN FAİZLER - Y.P. > LER - T.P. | C+A |  |
| E | 30 | Interbank Loan & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Long & Mali Kesim & Yabancı Mevduat Bankaları | 54002 | 54002000 | (?) sayfa basligiyla birlesmis > ORTA VE UZUN VADELİ FON KAYNAKLI KREDİLERDEN ALINAN FAİZLER - Y.P. | C+A |  |
| E | 40 | Interbank Loan & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Long & Mali Kesim & Kamu Kalkınma ve Yatırım Bankaları | 54003 | 54003000 | (?) sayfa basligiyla birlesmis > ORTA VE UZUN VADELİ FON KAYNAKLI KREDİLERDEN ALINAN FAİZLER - Y.P. > KAMU MEVDUAT BANKALARINDAN | C+A |  |
| E | 50 | Interbank Loan & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Long & Mali Kesim & Özel Kalkınma ve Yatırım Bankaları | 54004 | 54004000 | (?) sayfa basligiyla birlesmis > ORTA VE UZUN VADELİ FON KAYNAKLI KREDİLERDEN ALINAN FAİZLER - Y.P. > ÖZEL MEVDUAT BANKALARINDAN | C+A |  |
| E | 10 | Interbank Loan & IsAccountNeeded = 1 & Market = OTC & Customer Location = FRGN & Term = Short & Mali Kesim & Yurtdışı Bankalar | 52200 | 52200000 | (?) sayfa basligiyla birlesmis > DİĞER MALİ KURULUŞLARDAN > YURTDIŞI KISA VADELİ KREDİLERDEN ALINAN FAİZLER - T.P. | C+A |  |
| E | 10 | Interbank Loan & IsAccountNeeded = 1 & Market = OTC & Customer Location = FRGN & Term = Long & Mali Kesim & Yurtdışı Bankalar | 54200 | 54200000 | (?) sayfa basligiyla birlesmis > SİGORTA ŞİRKETLERİNDEN > DİĞER MALİ KURULUŞLARDAN | C+A |  |
| E | 10 | Murabaha & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Short & Mali Kesim & Katılım Bankaları | 52005 | 52005010 | (?) sayfa basligiyla birlesmis > KISA VADELİ FON KAYNAKLI KREDİLERDEN ALINAN FAİZLER - Y.P. > KAMU KALKINMA VE YATIRIM BANKALARINDAN | C+A |  |
| E | 10 | Murabaha & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Long & Mali Kesim & Katılım Bankaları | 54005 | 54005010 | (?) sayfa basligiyla birlesmis > ORTA VE UZUN VADELİ FON KAYNAKLI KREDİLERDEN ALINAN FAİZLER - Y.P. > YABANCI MEVDUAT BANKALARINDAN | C+A |  |
| E | 10 | Murabaha & IsAccountNeeded = 1 & Market = OTC & Customer Location = FRGN & Term = Short & Mali Kesim & Yurtdışı Bankalar | 52200 | 52200010 | (?) sayfa basligiyla birlesmis > DİĞER MALİ KURULUŞLARDAN > YURTDIŞI KISA VADELİ KREDİLERDEN ALINAN FAİZLER - T.P. | C+A |  |
| E | 10 | Murabaha & IsAccountNeeded = 1 & Market = OTC & Customer Location = FRGN & Term = Long & Mali Kesim & Yurtdışı Bankalar | 54200 | 54200010 | (?) sayfa basligiyla birlesmis > SİGORTA ŞİRKETLERİNDEN > DİĞER MALİ KURULUŞLARDAN | C+A |  |
| E | 10 | Wakala & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Short & Mali Kesim & Katılım Bankaları | 52005 | 52005020 | (?) sayfa basligiyla birlesmis > KISA VADELİ FON KAYNAKLI KREDİLERDEN ALINAN FAİZLER - Y.P. > KAMU KALKINMA VE YATIRIM BANKALARINDAN | C+A |  |
| E | 10 | Wakala & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Long & Mali Kesim & Katılım Bankaları | 54005 | 54005020 | (?) sayfa basligiyla birlesmis > ORTA VE UZUN VADELİ FON KAYNAKLI KREDİLERDEN ALINAN FAİZLER - Y.P. > YABANCI MEVDUAT BANKALARINDAN | C+A |  |
| E | 10 | Wakala & IsAccountNeeded = 1 & Market = OTC & Customer Location = FRGN & Term = Short & Mali Kesim & Yurtdışı Bankalar | 52200 | 52200020 | (?) sayfa basligiyla birlesmis > DİĞER MALİ KURULUŞLARDAN > YURTDIŞI KISA VADELİ KREDİLERDEN ALINAN FAİZLER - T.P. | C+A |  |
| E | 10 | Wakala & IsAccountNeeded = 1 & Market = OTC & Customer Location = FRGN & Term = Long & Mali Kesim & Yurtdışı Bankalar | 54200 | 54200020 | (?) sayfa basligiyla birlesmis > SİGORTA ŞİRKETLERİNDEN > DİĞER MALİ KURULUŞLARDAN | C+A |  |

### InterestIncome

| On | Order | Kurallar | THP | Target | THP adi | Cust/Acc | Not |
|---|---|---|---|---|---|---|---|
| E | 10 | Interbank Loan & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Short & Mali Kesim & Kamu Mevduat Bankaları | 52000 | 52000000 | (?) sayfa basligiyla birlesmis > KISA VADELİ FON KAYNAKLI KREDİLERDEN ALINAN FAİZLER - Y.P. > MALİ KESİME KULLANDIRILAN KISA VADELİ KREDİLERDEN ALINAN FAİZLER-T.P. | C+A |  |
| E | 20 | Interbank Loan & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Short & Mali Kesim & Özel Mevduat Bankaları | 52001 | 52001000 | (?) sayfa basligiyla birlesmis > KISA VADELİ FON KAYNAKLI KREDİLERDEN ALINAN FAİZLER - Y.P. | C+A |  |
| E | 30 | Interbank Loan & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Short & Mali Kesim & Yabancı Mevduat Bankaları | 52002 | 52002000 | (?) sayfa basligiyla birlesmis > KISA VADELİ FON KAYNAKLI KREDİLERDEN ALINAN FAİZLER - Y.P. > KAMU MEVDUAT BANKALARINDAN | C+A |  |
| E | 40 | Interbank Loan & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Short & Mali Kesim & Kamu Kalkınma ve Yatırım Bankaları | 52003 | 52003000 | (?) sayfa basligiyla birlesmis > KISA VADELİ FON KAYNAKLI KREDİLERDEN ALINAN FAİZLER - Y.P. > ÖZEL MEVDUAT BANKALARINDAN | C+A |  |
| E | 50 | Interbank Loan & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Short & Mali Kesim & Özel Kalkınma ve Yatırım Bankaları | 52004 | 52004000 | (?) sayfa basligiyla birlesmis > KISA VADELİ FON KAYNAKLI KREDİLERDEN ALINAN FAİZLER - Y.P. > YABANCI MEVDUAT BANKALARINDAN | C+A |  |
| E | 10 | Interbank Loan & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Long & Mali Kesim & Kamu Mevduat Bankaları | 54000 | 54000000 | (?) sayfa basligiyla birlesmis > ORTA VE UZUN VADELİ FON KAYNAKLI KREDİLERDEN ALINAN FAİZLER - Y.P. > MALİ KESİME KULLANDIRILAN ORTA UZUN VADELİ KREDİLERDEN ALINAN FAİZ- | C+A |  |
| E | 20 | Interbank Loan & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Long & Mali Kesim & Özel Mevduat Bankaları | 54001 | 54001000 | (?) sayfa basligiyla birlesmis > ORTA VE UZUN VADELİ FON KAYNAKLI KREDİLERDEN ALINAN FAİZLER - Y.P. > LER - T.P. | C+A |  |
| E | 30 | Interbank Loan & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Long & Mali Kesim & Yabancı Mevduat Bankaları | 54002 | 54002000 | (?) sayfa basligiyla birlesmis > ORTA VE UZUN VADELİ FON KAYNAKLI KREDİLERDEN ALINAN FAİZLER - Y.P. | C+A |  |
| E | 40 | Interbank Loan & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Long & Mali Kesim & Kamu Kalkınma ve Yatırım Bankaları | 54003 | 54003000 | (?) sayfa basligiyla birlesmis > ORTA VE UZUN VADELİ FON KAYNAKLI KREDİLERDEN ALINAN FAİZLER - Y.P. > KAMU MEVDUAT BANKALARINDAN | C+A |  |
| E | 50 | Interbank Loan & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Long & Mali Kesim & Özel Kalkınma ve Yatırım Bankaları | 54004 | 54004000 | (?) sayfa basligiyla birlesmis > ORTA VE UZUN VADELİ FON KAYNAKLI KREDİLERDEN ALINAN FAİZLER - Y.P. > ÖZEL MEVDUAT BANKALARINDAN | C+A |  |
| E | 10 | Interbank Loan & IsAccountNeeded = 1 & Market = OTC & Customer Location = FRGN & Term = Short & Mali Kesim & Yurtdışı Bankalar | 52200 | 52200000 | (?) sayfa basligiyla birlesmis > DİĞER MALİ KURULUŞLARDAN > YURTDIŞI KISA VADELİ KREDİLERDEN ALINAN FAİZLER - T.P. | C+A |  |
| E | 10 | Interbank Loan & IsAccountNeeded = 1 & Market = OTC & Customer Location = FRGN & Term = Long & Mali Kesim & Yurtdışı Bankalar | 54200 | 54200000 | (?) sayfa basligiyla birlesmis > SİGORTA ŞİRKETLERİNDEN > DİĞER MALİ KURULUŞLARDAN | C+A |  |
| E | 10 | Murabaha & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Short & Mali Kesim & Katılım Bankaları | 52005 | 52005010 | (?) sayfa basligiyla birlesmis > KISA VADELİ FON KAYNAKLI KREDİLERDEN ALINAN FAİZLER - Y.P. > KAMU KALKINMA VE YATIRIM BANKALARINDAN | C+A |  |
| E | 10 | Murabaha & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Long & Mali Kesim & Katılım Bankaları | 54005 | 54005010 | (?) sayfa basligiyla birlesmis > ORTA VE UZUN VADELİ FON KAYNAKLI KREDİLERDEN ALINAN FAİZLER - Y.P. > YABANCI MEVDUAT BANKALARINDAN | C+A |  |
| E | 10 | Murabaha & IsAccountNeeded = 1 & Market = OTC & Customer Location = FRGN & Term = Short & Mali Kesim & Yurtdışı Bankalar | 52200 | 52200010 | (?) sayfa basligiyla birlesmis > DİĞER MALİ KURULUŞLARDAN > YURTDIŞI KISA VADELİ KREDİLERDEN ALINAN FAİZLER - T.P. | C+A |  |
| E | 10 | Murabaha & IsAccountNeeded = 1 & Market = OTC & Customer Location = FRGN & Term = Long & Mali Kesim & Yurtdışı Bankalar | 54200 | 54200010 | (?) sayfa basligiyla birlesmis > SİGORTA ŞİRKETLERİNDEN > DİĞER MALİ KURULUŞLARDAN | C+A |  |
| E | 10 | Wakala & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Short & Mali Kesim & Katılım Bankaları | 52005 | 52005020 | (?) sayfa basligiyla birlesmis > KISA VADELİ FON KAYNAKLI KREDİLERDEN ALINAN FAİZLER - Y.P. > KAMU KALKINMA VE YATIRIM BANKALARINDAN | C+A |  |
| E | 10 | Wakala & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Long & Mali Kesim & Katılım Bankaları | 54005 | 54005020 | (?) sayfa basligiyla birlesmis > ORTA VE UZUN VADELİ FON KAYNAKLI KREDİLERDEN ALINAN FAİZLER - Y.P. > YABANCI MEVDUAT BANKALARINDAN | C+A |  |
| E | 10 | Wakala & IsAccountNeeded = 1 & Market = OTC & Customer Location = FRGN & Term = Short & Mali Kesim & Yurtdışı Bankalar | 52200 | 52200020 | (?) sayfa basligiyla birlesmis > DİĞER MALİ KURULUŞLARDAN > YURTDIŞI KISA VADELİ KREDİLERDEN ALINAN FAİZLER - T.P. | C+A |  |
| E | 10 | Wakala & IsAccountNeeded = 1 & Market = OTC & Customer Location = FRGN & Term = Long & Mali Kesim & Yurtdışı Bankalar | 54200 | 54200020 | (?) sayfa basligiyla birlesmis > SİGORTA ŞİRKETLERİNDEN > DİĞER MALİ KURULUŞLARDAN | C+A |  |

### AccruedIncome

| On | Order | Kurallar | THP | Target | THP adi | Cust/Acc | Not |
|---|---|---|---|---|---|---|---|
| E | 10 | Interbank Loan & IsAccountNeeded = 1 | 22001 | 22001000 | (?) sayfa basligiyla birlesmis > ZORUNLU KARŞILIKLAR - Y.P. | C+A |  |
| E | 10 | Murabaha & IsAccountNeeded = 1 | 22001 | 22001010 | (?) sayfa basligiyla birlesmis > ZORUNLU KARŞILIKLAR - Y.P. | C+A |  |
| E | 10 | Wakala & IsAccountNeeded = 1 | 22001 | 22001020 | (?) sayfa basligiyla birlesmis > ZORUNLU KARŞILIKLAR - Y.P. | C+A |  |

## TREX/BRWPLC1/LOAN/PLC/FCY

### CounterPartyGLAccount

| On | Order | Kurallar | THP | Target | THP adi | Cust/Acc | Not |
|---|---|---|---|---|---|---|---|
| E | 10 | IsAccountNeeded = 1 & UseExternalGLAccount = 1 |  | calc:ExternalGLAccount |  | C+A |  |
| E | 10 | Interbank Loan & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = DOM & Term = Short & Teminatsız & Mali Kesim & Kamu Mevduat Bankaları | 127000 | 12700000 | MALİ KESİME KULLANDIRILAN KISA VADELİ KREDİLER - Y.P. > AÇIK > KAMU MEVDUAT BANKALARI | C+A |  |
| E | 20 | Interbank Loan & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = DOM & Term = Short & Teminatsız & Mali Kesim & Özel Mevduat Bankaları | 127001 | 12700100 | MALİ KESİME KULLANDIRILAN KISA VADELİ KREDİLER - Y.P. > AÇIK > ÖZEL MEVDUAT BANKALARI | C+A |  |
| E | 30 | Interbank Loan & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = DOM & Term = Short & Teminatsız & Mali Kesim & Yabancı Mevduat Bankaları | 127002 | 12700200 | MALİ KESİME KULLANDIRILAN KISA VADELİ KREDİLER - Y.P. > AÇIK > YABANCI MEVDUAT BANKALARI | C+A |  |
| E | 40 | Interbank Loan & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = DOM & Term = Short & Teminatsız & Mali Kesim & Kamu Kalkınma ve Yatırım Bankaları | 127003 | 12700300 | MALİ KESİME KULLANDIRILAN KISA VADELİ KREDİLER - Y.P. > AÇIK > KAMU KALKINMA VE YATIRIM BANKALARI | C+A |  |
| E | 50 | Interbank Loan & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = DOM & Term = Short & Teminatsız & Mali Kesim & Özel Kalkınma ve Yatırım Bankaları | 127004 | 12700400 | MALİ KESİME KULLANDIRILAN KISA VADELİ KREDİLER - Y.P. > AÇIK > ÖZEL KALKINMA VE YATIRIM BANKALARI | C+A |  |
| E | 10 | Interbank Loan & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = DOM & Term = Short & Teminatlı & Mali Kesim & Kamu Mevduat Bankaları | 127010 | 12701000 | MALİ KESİME KULLANDIRILAN KISA VADELİ KREDİLER - Y.P. > TEMİNATLI > KAMU MEVDUAT BANKALARI | C+A |  |
| E | 20 | Interbank Loan & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = DOM & Term = Short & Teminatlı & Mali Kesim & Özel Mevduat Bankaları | 127011 | 12701100 | MALİ KESİME KULLANDIRILAN KISA VADELİ KREDİLER - Y.P. > TEMİNATLI > ÖZEL MEVDUAT BANKALARI | C+A |  |
| E | 30 | Interbank Loan & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = DOM & Term = Short & Teminatlı & Mali Kesim & Yabancı Mevduat Bankaları | 127012 | 12701200 | MALİ KESİME KULLANDIRILAN KISA VADELİ KREDİLER - Y.P. > TEMİNATLI > YABANCI MEVDUAT BANKALARI | C+A |  |
| E | 40 | Interbank Loan & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = DOM & Term = Short & Teminatlı & Mali Kesim & Kamu Kalkınma ve Yatırım Bankaları | 127013 | 12701300 | MALİ KESİME KULLANDIRILAN KISA VADELİ KREDİLER - Y.P. > TEMİNATLI > KAMU KALKINMA VE YATIRIM BANKALARI | C+A |  |
| E | 50 | Interbank Loan & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = DOM & Term = Short & Teminatlı & Mali Kesim & Özel Kalkınma ve Yatırım Bankaları | 127014 | 12701400 | MALİ KESİME KULLANDIRILAN KISA VADELİ KREDİLER - Y.P. > TEMİNATLI > ÖZEL KALKINMA VE YATIRIM BANKALARI | C+A |  |
| E | 10 | Interbank Loan & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = DOM & Term = Long & Teminatsız & Mali Kesim & Kamu Mevduat Bankaları | 147000 | 14700000 | MALİ KESİME KULLANDIRILAN ORTA VE UZUN VADELİ KREDİLER - Y.P. > AÇIK > KAMU MEVDUAT BANKALARI | C+A |  |
| E | 20 | Interbank Loan & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = DOM & Term = Long & Teminatsız & Mali Kesim & Özel Mevduat Bankaları | 147001 | 14700100 | MALİ KESİME KULLANDIRILAN ORTA VE UZUN VADELİ KREDİLER - Y.P. > AÇIK > ÖZEL MEVDUAT BANKALARI | C+A |  |
| E | 30 | Interbank Loan & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = DOM & Term = Long & Teminatsız & Mali Kesim & Yabancı Mevduat Bankaları | 147002 | 14700200 | MALİ KESİME KULLANDIRILAN ORTA VE UZUN VADELİ KREDİLER - Y.P. > AÇIK > YABANCI MEVDUAT BANKALARI | C+A |  |
| E | 40 | Interbank Loan & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = DOM & Term = Long & Teminatsız & Mali Kesim & Kamu Kalkınma ve Yatırım Bankaları | 147003 | 14700300 | MALİ KESİME KULLANDIRILAN ORTA VE UZUN VADELİ KREDİLER - Y.P. > AÇIK > KAMU KALKINMA VE YATIRIM BANKALARI | C+A |  |
| E | 50 | Interbank Loan & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = DOM & Term = Long & Teminatsız & Mali Kesim & Özel Kalkınma ve Yatırım Bankaları | 147004 | 14700400 | MALİ KESİME KULLANDIRILAN ORTA VE UZUN VADELİ KREDİLER - Y.P. > AÇIK > ÖZEL KALKINMA VE YATIRIM BANKALARI | C+A |  |
| E | 10 | Interbank Loan & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = DOM & Term = Long & Teminatlı & Mali Kesim & Kamu Mevduat Bankaları | 147010 | 14701000 | MALİ KESİME KULLANDIRILAN ORTA VE UZUN VADELİ KREDİLER - Y.P. > TEMİNATLI > KAMU MEVDUAT BANKALARI | C+A |  |
| E | 20 | Interbank Loan & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = DOM & Term = Long & Teminatlı & Mali Kesim & Özel Mevduat Bankaları | 147011 | 14701100 | MALİ KESİME KULLANDIRILAN ORTA VE UZUN VADELİ KREDİLER - Y.P. > TEMİNATLI > ÖZEL MEVDUAT BANKALARI | C+A |  |
| E | 30 | Interbank Loan & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = DOM & Term = Long & Teminatlı & Mali Kesim & Yabancı Mevduat Bankaları | 147012 | 14701200 | MALİ KESİME KULLANDIRILAN ORTA VE UZUN VADELİ KREDİLER - Y.P. > TEMİNATLI > YABANCI MEVDUAT BANKALARI | C+A |  |
| E | 40 | Interbank Loan & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = DOM & Term = Long & Teminatlı & Mali Kesim & Kamu Kalkınma ve Yatırım Bankaları | 147013 | 14701300 | MALİ KESİME KULLANDIRILAN ORTA VE UZUN VADELİ KREDİLER - Y.P. > TEMİNATLI > KAMU KALKINMA VE YATIRIM BANKALARI | C+A |  |
| E | 50 | Interbank Loan & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = DOM & Term = Long & Teminatlı & Mali Kesim & Özel Kalkınma ve Yatırım Bankaları | 147014 | 14701400 | MALİ KESİME KULLANDIRILAN ORTA VE UZUN VADELİ KREDİLER - Y.P. > TEMİNATLI > ÖZEL KALKINMA VE YATIRIM BANKALARI | C+A |  |
| E | 10 | Interbank Loan & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = FRGN & Term = Short & Teminatsız & Mali Kesim & Yurtdışı Bankalar | 129000 | 12900000 | KREDİLER > (?) sayfa basligiyla birlesmis > YURTDIŞI KISA VADELİ KREDİLER - Y.P. | C+A |  |
| E | 10 | Interbank Loan & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = FRGN & Term = Short & Teminatlı & Mali Kesim & Yurtdışı Bankalar | 129001 | 12900100 | (?) sayfa basligiyla birlesmis > YURTDIŞI KISA VADELİ KREDİLER - Y.P. > BANKALAR | C+A |  |
| E | 10 | Interbank Loan & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = FRGN & Term = Long & Teminatsız & Mali Kesim & Yurtdışı Bankalar | 149000 | 14900000 | YURTDIŞI ORTA VE UZUN VADELİ KREDİLER - Y.P. > BANKALAR > AÇIK | C+A |  |
| E | 10 | Interbank Loan & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = FRGN & Term = Long & Teminatlı & Mali Kesim & Yurtdışı Bankalar | 149001 | 14900100 | YURTDIŞI ORTA VE UZUN VADELİ KREDİLER - Y.P. > BANKALAR > TEMİNATLI | C+A |  |
| E | 10 | Murabaha & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = DOM & Term = Short & Teminatsız & Mali Kesim & Katılım Bankaları | 127005 | 12700510 | MALİ KESİME KULLANDIRILAN KISA VADELİ KREDİLER - Y.P. > AÇIK > KATILIM BANKALARI | C+A |  |
| E | 10 | Murabaha & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = DOM & Term = Short & Teminatlı & Mali Kesim & Katılım Bankaları | 127015 | 12701510 | MALİ KESİME KULLANDIRILAN KISA VADELİ KREDİLER - Y.P. > TEMİNATLI > KATILIM BANKALARI | C+A |  |
| E | 10 | Murabaha & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = DOM & Term = Long & Teminatsız & Mali Kesim & Katılım Bankaları | 147005 | 14700510 | MALİ KESİME KULLANDIRILAN ORTA VE UZUN VADELİ KREDİLER - Y.P. > AÇIK > KATILIM BANKALARI | C+A |  |
| E | 10 | Murabaha & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = DOM & Term = Long & Teminatlı & Mali Kesim & Katılım Bankaları | 147015 | 14701510 | MALİ KESİME KULLANDIRILAN ORTA VE UZUN VADELİ KREDİLER - Y.P. > TEMİNATLI > KATILIM BANKALARI | C+A |  |
| E | 10 | Murabaha & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = FRGN & Term = Short & Teminatsız & Mali Kesim & Yurtdışı Bankalar | 129000 | 12900010 | KREDİLER > (?) sayfa basligiyla birlesmis > YURTDIŞI KISA VADELİ KREDİLER - Y.P. | C+A |  |
| E | 10 | Murabaha & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = FRGN & Term = Short & Teminatlı & Mali Kesim & Yurtdışı Bankalar | 129001 | 12900110 | (?) sayfa basligiyla birlesmis > YURTDIŞI KISA VADELİ KREDİLER - Y.P. > BANKALAR | C+A |  |
| E | 10 | Murabaha & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = FRGN & Term = Long & Teminatsız & Mali Kesim & Yurtdışı Bankalar | 149000 | 14900010 | YURTDIŞI ORTA VE UZUN VADELİ KREDİLER - Y.P. > BANKALAR > AÇIK | C+A |  |
| E | 10 | Murabaha & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = FRGN & Term = Long & Teminatlı & Mali Kesim & Yurtdışı Bankalar | 149001 | 14900110 | YURTDIŞI ORTA VE UZUN VADELİ KREDİLER - Y.P. > BANKALAR > TEMİNATLI | C+A |  |
| E | 10 | Wakala & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = DOM & Term = Short & Teminatsız & Mali Kesim & Katılım Bankaları | 127005 | 12700520 | MALİ KESİME KULLANDIRILAN KISA VADELİ KREDİLER - Y.P. > AÇIK > KATILIM BANKALARI | C+A |  |
| E | 10 | Wakala & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = DOM & Term = Short & Teminatlı & Mali Kesim & Katılım Bankaları | 127015 | 12701520 | MALİ KESİME KULLANDIRILAN KISA VADELİ KREDİLER - Y.P. > TEMİNATLI > KATILIM BANKALARI | C+A |  |
| E | 10 | Wakala & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = DOM & Term = Long & Teminatsız & Mali Kesim & Katılım Bankaları | 147005 | 14700520 | MALİ KESİME KULLANDIRILAN ORTA VE UZUN VADELİ KREDİLER - Y.P. > AÇIK > KATILIM BANKALARI | C+A |  |
| E | 10 | Wakala & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = DOM & Term = Long & Teminatlı & Mali Kesim & Katılım Bankaları | 147015 | 14701520 | MALİ KESİME KULLANDIRILAN ORTA VE UZUN VADELİ KREDİLER - Y.P. > TEMİNATLI > KATILIM BANKALARI | C+A |  |
| E | 10 | Wakala & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = FRGN & Term = Short & Teminatsız & Mali Kesim & Yurtdışı Bankalar | 129000 | 12900020 | KREDİLER > (?) sayfa basligiyla birlesmis > YURTDIŞI KISA VADELİ KREDİLER - Y.P. | C+A |  |
| E | 10 | Wakala & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = FRGN & Term = Short & Teminatlı & Mali Kesim & Yurtdışı Bankalar | 129001 | 12900120 | (?) sayfa basligiyla birlesmis > YURTDIŞI KISA VADELİ KREDİLER - Y.P. > BANKALAR | C+A |  |
| E | 10 | Wakala & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = FRGN & Term = Long & Teminatsız & Mali Kesim & Yurtdışı Bankalar | 149000 | 14900020 | YURTDIŞI ORTA VE UZUN VADELİ KREDİLER - Y.P. > BANKALAR > AÇIK | C+A |  |
| E | 10 | Wakala & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = FRGN & Term = Long & Teminatlı & Mali Kesim & Yurtdışı Bankalar | 149001 | 14900120 | YURTDIŞI ORTA VE UZUN VADELİ KREDİLER - Y.P. > BANKALAR > TEMİNATLI | C+A |  |

### InterestReceived

| On | Order | Kurallar | THP | Target | THP adi | Cust/Acc | Not |
|---|---|---|---|---|---|---|---|
| E | 10 | Interbank Loan & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Short & Mali Kesim & Kamu Mevduat Bankaları | 52100 | 52100000 | (?) sayfa basligiyla birlesmis > DİĞER MALİ KURULUŞLARDAN > MALİ KESİME KULLANDIRILAN KISA VADELİ KREDİLERDEN ALINAN FAİZLER - Y.P. | C+A |  |
| E | 20 | Interbank Loan & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Short & Mali Kesim & Özel Mevduat Bankaları | 52101 | 52101000 | (?) sayfa basligiyla birlesmis > DİĞER MALİ KURULUŞLARDAN | C+A |  |
| E | 30 | Interbank Loan & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Short & Mali Kesim & Yabancı Mevduat Bankaları | 52102 | 52102000 | (?) sayfa basligiyla birlesmis > DİĞER MALİ KURULUŞLARDAN > KAMU MEVDUAT BANKALARINDAN | C+A |  |
| E | 40 | Interbank Loan & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Short & Mali Kesim & Kamu Kalkınma ve Yatırım Bankaları | 52103 | 52103000 | (?) sayfa basligiyla birlesmis > DİĞER MALİ KURULUŞLARDAN > ÖZEL MEVDUAT BANKALARINDAN | C+A |  |
| E | 50 | Interbank Loan & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Short & Mali Kesim & Özel Kalkınma ve Yatırım Bankaları | 52104 | 52104000 | (?) sayfa basligiyla birlesmis > DİĞER MALİ KURULUŞLARDAN > YABANCI MEVDUAT BANKALARINDAN | C+A |  |
| E | 10 | Interbank Loan & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Long & Mali Kesim & Kamu Mevduat Bankaları | 54100 | 54100000 | (?) sayfa basligiyla birlesmis > MÜŞTERİ ADINA MENKUL DEĞER ALIM KREDİLERİNDEN | C+A |  |
| E | 20 | Interbank Loan & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Long & Mali Kesim & Özel Mevduat Bankaları | 54101 | 54101000 | (?) sayfa basligiyla birlesmis > MÜŞTERİ ADINA MENKUL DEĞER ALIM KREDİLERİNDEN > MALİ KESİME KULLANDIRILAN ORTA UZUN VADELİ KREDİLERDEN ALINAN FAİZ- | C+A |  |
| E | 30 | Interbank Loan & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Long & Mali Kesim & Yabancı Mevduat Bankaları | 54102 | 54102000 | (?) sayfa basligiyla birlesmis > MÜŞTERİ ADINA MENKUL DEĞER ALIM KREDİLERİNDEN > LER - Y.P. | C+A |  |
| E | 40 | Interbank Loan & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Long & Mali Kesim & Kamu Kalkınma ve Yatırım Bankaları | 54103 | 54103000 | (?) sayfa basligiyla birlesmis > MÜŞTERİ ADINA MENKUL DEĞER ALIM KREDİLERİNDEN | C+A |  |
| E | 50 | Interbank Loan & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Long & Mali Kesim & Özel Kalkınma ve Yatırım Bankaları | 54104 | 54104000 | (?) sayfa basligiyla birlesmis > MÜŞTERİ ADINA MENKUL DEĞER ALIM KREDİLERİNDEN > KAMU MEVDUAT BANKALARINDAN | C+A |  |
| E | 10 | Interbank Loan & IsAccountNeeded = 1 & Market = OTC & Customer Location = FRGN & Term = Short & Mali Kesim & Yurtdışı Bankalar | 52300 | 52300000 | (?) sayfa basligiyla birlesmis > DİĞER > (?) sayfa basligiyla birlesmis | C+A |  |
| E | 10 | Interbank Loan & IsAccountNeeded = 1 & Market = OTC & Customer Location = FRGN & Term = Long & Mali Kesim & Yurtdışı Bankalar | 54300 | 54300000 | (?) sayfa basligiyla birlesmis > MÜŞTERİ ADINA MENKUL DEĞER ALIM KREDİLERİNDEN > DİĞER | C+A |  |
| E | 10 | Murabaha & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Short & Mali Kesim & Katılım Bankaları | 52105 | 52105010 | (?) sayfa basligiyla birlesmis > DİĞER MALİ KURULUŞLARDAN > KAMU KALKINMA VE YATIRIM BANKALARINDAN | C+A |  |
| E | 10 | Murabaha & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Long & Mali Kesim & Katılım Bankaları | 54105 | 54105010 | (?) sayfa basligiyla birlesmis > MÜŞTERİ ADINA MENKUL DEĞER ALIM KREDİLERİNDEN > ÖZEL MEVDUAT BANKALARINDAN | C+A |  |
| E | 10 | Murabaha & IsAccountNeeded = 1 & Market = OTC & Customer Location = FRGN & Term = Short & Mali Kesim & Yurtdışı Bankalar | 52300 | 52300010 | (?) sayfa basligiyla birlesmis > DİĞER > (?) sayfa basligiyla birlesmis | C+A |  |
| E | 10 | Murabaha & IsAccountNeeded = 1 & Market = OTC & Customer Location = FRGN & Term = Long & Mali Kesim & Yurtdışı Bankalar | 54300 | 54300010 | (?) sayfa basligiyla birlesmis > MÜŞTERİ ADINA MENKUL DEĞER ALIM KREDİLERİNDEN > DİĞER | C+A |  |
| E | 10 | Wakala & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Short & Mali Kesim & Katılım Bankaları | 52105 | 52105020 | (?) sayfa basligiyla birlesmis > DİĞER MALİ KURULUŞLARDAN > KAMU KALKINMA VE YATIRIM BANKALARINDAN | C+A |  |
| E | 10 | Wakala & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Long & Mali Kesim & Katılım Bankaları | 54105 | 54105020 | (?) sayfa basligiyla birlesmis > MÜŞTERİ ADINA MENKUL DEĞER ALIM KREDİLERİNDEN > ÖZEL MEVDUAT BANKALARINDAN | C+A |  |
| E | 10 | Wakala & IsAccountNeeded = 1 & Market = OTC & Customer Location = FRGN & Term = Short & Mali Kesim & Yurtdışı Bankalar | 52300 | 52300020 | (?) sayfa basligiyla birlesmis > DİĞER > (?) sayfa basligiyla birlesmis | C+A |  |
| E | 10 | Wakala & IsAccountNeeded = 1 & Market = OTC & Customer Location = FRGN & Term = Long & Mali Kesim & Yurtdışı Bankalar | 54300 | 54300020 | (?) sayfa basligiyla birlesmis > MÜŞTERİ ADINA MENKUL DEĞER ALIM KREDİLERİNDEN > DİĞER | C+A |  |

### InterestIncome

| On | Order | Kurallar | THP | Target | THP adi | Cust/Acc | Not |
|---|---|---|---|---|---|---|---|
| E | 10 | Interbank Loan & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Short & Mali Kesim & Kamu Mevduat Bankaları | 52100 | 52100000 | (?) sayfa basligiyla birlesmis > DİĞER MALİ KURULUŞLARDAN > MALİ KESİME KULLANDIRILAN KISA VADELİ KREDİLERDEN ALINAN FAİZLER - Y.P. | C+A |  |
| E | 20 | Interbank Loan & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Short & Mali Kesim & Özel Mevduat Bankaları | 52101 | 52101000 | (?) sayfa basligiyla birlesmis > DİĞER MALİ KURULUŞLARDAN | C+A |  |
| E | 30 | Interbank Loan & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Short & Mali Kesim & Yabancı Mevduat Bankaları | 52102 | 52102000 | (?) sayfa basligiyla birlesmis > DİĞER MALİ KURULUŞLARDAN > KAMU MEVDUAT BANKALARINDAN | C+A |  |
| E | 40 | Interbank Loan & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Short & Mali Kesim & Kamu Kalkınma ve Yatırım Bankaları | 52103 | 52103000 | (?) sayfa basligiyla birlesmis > DİĞER MALİ KURULUŞLARDAN > ÖZEL MEVDUAT BANKALARINDAN | C+A |  |
| E | 50 | Interbank Loan & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Short & Mali Kesim & Özel Kalkınma ve Yatırım Bankaları | 52104 | 52104000 | (?) sayfa basligiyla birlesmis > DİĞER MALİ KURULUŞLARDAN > YABANCI MEVDUAT BANKALARINDAN | C+A |  |
| E | 10 | Interbank Loan & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Long & Mali Kesim & Kamu Mevduat Bankaları | 54100 | 54100000 | (?) sayfa basligiyla birlesmis > MÜŞTERİ ADINA MENKUL DEĞER ALIM KREDİLERİNDEN | C+A |  |
| E | 20 | Interbank Loan & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Long & Mali Kesim & Özel Mevduat Bankaları | 54101 | 54101000 | (?) sayfa basligiyla birlesmis > MÜŞTERİ ADINA MENKUL DEĞER ALIM KREDİLERİNDEN > MALİ KESİME KULLANDIRILAN ORTA UZUN VADELİ KREDİLERDEN ALINAN FAİZ- | C+A |  |
| E | 30 | Interbank Loan & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Long & Mali Kesim & Yabancı Mevduat Bankaları | 54102 | 54102000 | (?) sayfa basligiyla birlesmis > MÜŞTERİ ADINA MENKUL DEĞER ALIM KREDİLERİNDEN > LER - Y.P. | C+A |  |
| E | 40 | Interbank Loan & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Long & Mali Kesim & Kamu Kalkınma ve Yatırım Bankaları | 54103 | 54103000 | (?) sayfa basligiyla birlesmis > MÜŞTERİ ADINA MENKUL DEĞER ALIM KREDİLERİNDEN | C+A |  |
| E | 50 | Interbank Loan & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Long & Mali Kesim & Özel Kalkınma ve Yatırım Bankaları | 54104 | 54104000 | (?) sayfa basligiyla birlesmis > MÜŞTERİ ADINA MENKUL DEĞER ALIM KREDİLERİNDEN > KAMU MEVDUAT BANKALARINDAN | C+A |  |
| E | 10 | Interbank Loan & IsAccountNeeded = 1 & Market = OTC & Customer Location = FRGN & Term = Short & Mali Kesim & Yurtdışı Bankalar | 52300 | 52300000 | (?) sayfa basligiyla birlesmis > DİĞER > (?) sayfa basligiyla birlesmis | C+A |  |
| E | 10 | Interbank Loan & IsAccountNeeded = 1 & Market = OTC & Customer Location = FRGN & Term = Long & Mali Kesim & Yurtdışı Bankalar | 54300 | 54300000 | (?) sayfa basligiyla birlesmis > MÜŞTERİ ADINA MENKUL DEĞER ALIM KREDİLERİNDEN > DİĞER | C+A |  |
| E | 10 | Murabaha & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Short & Mali Kesim & Katılım Bankaları | 52105 | 52105010 | (?) sayfa basligiyla birlesmis > DİĞER MALİ KURULUŞLARDAN > KAMU KALKINMA VE YATIRIM BANKALARINDAN | C+A |  |
| E | 10 | Murabaha & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Long & Mali Kesim & Katılım Bankaları | 54105 | 54105010 | (?) sayfa basligiyla birlesmis > MÜŞTERİ ADINA MENKUL DEĞER ALIM KREDİLERİNDEN > ÖZEL MEVDUAT BANKALARINDAN | C+A |  |
| E | 10 | Murabaha & IsAccountNeeded = 1 & Market = OTC & Customer Location = FRGN & Term = Short & Mali Kesim & Yurtdışı Bankalar | 52300 | 52300010 | (?) sayfa basligiyla birlesmis > DİĞER > (?) sayfa basligiyla birlesmis | C+A |  |
| E | 10 | Murabaha & IsAccountNeeded = 1 & Market = OTC & Customer Location = FRGN & Term = Long & Mali Kesim & Yurtdışı Bankalar | 54300 | 54300010 | (?) sayfa basligiyla birlesmis > MÜŞTERİ ADINA MENKUL DEĞER ALIM KREDİLERİNDEN > DİĞER | C+A |  |
| E | 10 | Wakala & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Short & Mali Kesim & Katılım Bankaları | 52105 | 52105020 | (?) sayfa basligiyla birlesmis > DİĞER MALİ KURULUŞLARDAN > KAMU KALKINMA VE YATIRIM BANKALARINDAN | C+A |  |
| E | 10 | Wakala & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Long & Mali Kesim & Katılım Bankaları | 54105 | 54105020 | (?) sayfa basligiyla birlesmis > MÜŞTERİ ADINA MENKUL DEĞER ALIM KREDİLERİNDEN > ÖZEL MEVDUAT BANKALARINDAN | C+A |  |
| E | 10 | Wakala & IsAccountNeeded = 1 & Market = OTC & Customer Location = FRGN & Term = Short & Mali Kesim & Yurtdışı Bankalar | 52300 | 52300020 | (?) sayfa basligiyla birlesmis > DİĞER > (?) sayfa basligiyla birlesmis | C+A |  |
| E | 10 | Wakala & IsAccountNeeded = 1 & Market = OTC & Customer Location = FRGN & Term = Long & Mali Kesim & Yurtdışı Bankalar | 54300 | 54300020 | (?) sayfa basligiyla birlesmis > MÜŞTERİ ADINA MENKUL DEĞER ALIM KREDİLERİNDEN > DİĞER | C+A |  |

### AccruedIncome

| On | Order | Kurallar | THP | Target | THP adi | Cust/Acc | Not |
|---|---|---|---|---|---|---|---|
| E | 10 | Interbank Loan & IsAccountNeeded = 1 | 22101 | 22101000 | (?) sayfa basligiyla birlesmis > GERÇEĞE UYGUN DEĞER FARKI DİĞER KAPSAMLI GELİRE YANSITILAN KREDİLER DEĞER > KREDİ FAİZ VE GELİR TAHAKKUK VE REESKONTLARI - Y.P. | C+A |  |
| E | 10 | Murabaha & IsAccountNeeded = 1 | 22101 | 22101010 | (?) sayfa basligiyla birlesmis > GERÇEĞE UYGUN DEĞER FARKI DİĞER KAPSAMLI GELİRE YANSITILAN KREDİLER DEĞER > KREDİ FAİZ VE GELİR TAHAKKUK VE REESKONTLARI - Y.P. | C+A |  |
| E | 10 | Wakala & IsAccountNeeded = 1 | 22101 | 22101020 | (?) sayfa basligiyla birlesmis > GERÇEĞE UYGUN DEĞER FARKI DİĞER KAPSAMLI GELİRE YANSITILAN KREDİLER DEĞER > KREDİ FAİZ VE GELİR TAHAKKUK VE REESKONTLARI - Y.P. | C+A |  |

## TREX/BRWPLC1

### FxPositionLCY

| On | Order | Kurallar | THP | Target | THP adi | Cust/Acc | Not |
|---|---|---|---|---|---|---|---|
| E | 10 | (kuralsiz) | 294 | 29400 | (?) sayfa basligiyla birlesmis > EFEKTİF VAZİYETİ - Y.P. |  | FxPosition |

### FxPosition

| On | Order | Kurallar | THP | Target | THP adi | Cust/Acc | Not |
|---|---|---|---|---|---|---|---|
| E | 10 | (kuralsiz) | 295 | 29500000 | (?) sayfa basligiyla birlesmis > DÖVİZ ALIM/SATIM HESABI - T.P. |  | FxPosition |

### OutgoingPaymentLCY

| On | Order | Kurallar | THP | Target | THP adi | Cust/Acc | Not |
|---|---|---|---|---|---|---|---|
| E | 5 | PaymentInstructionType = B2B & SettlementType = Gross & OutgoingPaymentAccountingType = TemporaryAccount & OutgoingPaymentAccountingGLType = Linked Account | 392 | 39200840 | ALACAKLARDAN DOLAYI EDİNİLEN DİĞER VARLIKLAR > DİĞER MUHTELİF BORÇLAR | C+A | Payment |
| E | 10 | PaymentInstructionType = B2B & SettlementType = Gross & OutgoingPaymentAccountingType = TemporaryAccount & OutgoingPaymentAccountingGLType = Ledger Account | 392 | 39200840 | ALACAKLARDAN DOLAYI EDİNİLEN DİĞER VARLIKLAR > DİĞER MUHTELİF BORÇLAR |  | Payment |
| E | 15 | PaymentInstructionType = B2B & SettlementType = Gross & OutgoingPaymentAccountingType = Cash Account |  | calc:OutgoingCorrespondentAccountGLCode |  | C+A | Payment |
| E | 20 | PaymentInstructionType = B2B & SettlementType = Net & OutgoingPaymentAccountingGLType = Linked Account | 392 | 39200840 | ALACAKLARDAN DOLAYI EDİNİLEN DİĞER VARLIKLAR > DİĞER MUHTELİF BORÇLAR | C+A | Payment |
| E | 25 | PaymentInstructionType = B2B & SettlementType = Net & OutgoingPaymentAccountingGLType = Ledger Account | 392 | 39200840 | ALACAKLARDAN DOLAYI EDİNİLEN DİĞER VARLIKLAR > DİĞER MUHTELİF BORÇLAR |  | Payment |
| E | 30 | PaymentInstructionType = A2A & SettlementType = Gross & OutgoingPaymentAccountingType = TemporaryAccount & OutgoingPaymentAccountingGLType = Linked Account | 392 | 39200840 | ALACAKLARDAN DOLAYI EDİNİLEN DİĞER VARLIKLAR > DİĞER MUHTELİF BORÇLAR | C+A | Payment |
| E | 35 | PaymentInstructionType = A2A & SettlementType = Gross & OutgoingPaymentAccountingType = TemporaryAccount & OutgoingPaymentAccountingGLType = Ledger Account | 392 | 39200840 | ALACAKLARDAN DOLAYI EDİNİLEN DİĞER VARLIKLAR > DİĞER MUHTELİF BORÇLAR |  | Payment |
| E | 40 | PaymentInstructionType = A2A & SettlementType = Gross |  | calc:OutgoingCorrespondentAccountGLCode |  | C+A | Payment |
| E | 45 | PaymentInstructionType = A2A & SettlementType = Net & OutgoingPaymentAccountingGLType = Linked Account | 392 | 39200840 | ALACAKLARDAN DOLAYI EDİNİLEN DİĞER VARLIKLAR > DİĞER MUHTELİF BORÇLAR | C+A | Payment |
| E | 50 | PaymentInstructionType = A2A & SettlementType = Net & OutgoingPaymentAccountingGLType = Ledger Account | 392 | 39200840 | ALACAKLARDAN DOLAYI EDİNİLEN DİĞER VARLIKLAR > DİĞER MUHTELİF BORÇLAR |  | Payment |
| E | 55 | PaymentInstructionType = V2V & SettlementType = Gross & OutgoingPaymentAccountingType = TemporaryAccount & OutgoingPaymentAccountingGLType = Linked Account | 392 | 39200840 | ALACAKLARDAN DOLAYI EDİNİLEN DİĞER VARLIKLAR > DİĞER MUHTELİF BORÇLAR | C+A | Payment |
| E | 60 | PaymentInstructionType = V2V & SettlementType = Gross & OutgoingPaymentAccountingType = TemporaryAccount & OutgoingPaymentAccountingGLType = Ledger Account | 392 | 39200840 | ALACAKLARDAN DOLAYI EDİNİLEN DİĞER VARLIKLAR > DİĞER MUHTELİF BORÇLAR |  | Payment |
| E | 65 | PaymentInstructionType = V2V & SettlementType = Gross |  | calc:TheirBeneficiaryCorrespondentGLCode |  | C+A | Payment |
| E | 70 | PaymentInstructionType = V2V & SettlementType = Net & OutgoingPaymentAccountingGLType = Linked Account | 392 | 39200840 | ALACAKLARDAN DOLAYI EDİNİLEN DİĞER VARLIKLAR > DİĞER MUHTELİF BORÇLAR | C+A | Payment |
| E | 75 | PaymentInstructionType = V2V & SettlementType = Net & OutgoingPaymentAccountingGLType = Ledger Account | 392 | 39200840 | ALACAKLARDAN DOLAYI EDİNİLEN DİĞER VARLIKLAR > DİĞER MUHTELİF BORÇLAR |  | Payment |
| E | 1000 | (kuralsiz) |  | calc:OutgoingExternalCustomerGLCode |  | C+A+WG | Payment |

### OutgoingPaymentFCY

| On | Order | Kurallar | THP | Target | THP adi | Cust/Acc | Not |
|---|---|---|---|---|---|---|---|
| E | 5 | PaymentInstructionType = B2B & SettlementType = Gross & OutgoingPaymentAccountingType = TemporaryAccount & OutgoingPaymentAccountingGLType = Linked Account | 393 | 39300840 | ALACAKLARDAN DOLAYI EDİNİLEN DİĞER VARLIKLAR > DİĞER ALACAKLI GEÇİCİ HESAPLAR | C+A | Payment |
| E | 10 | PaymentInstructionType = B2B & SettlementType = Gross & OutgoingPaymentAccountingType = TemporaryAccount & OutgoingPaymentAccountingGLType = Ledger Account | 393 | 39300840 | ALACAKLARDAN DOLAYI EDİNİLEN DİĞER VARLIKLAR > DİĞER ALACAKLI GEÇİCİ HESAPLAR |  | Payment |
| E | 15 | PaymentInstructionType = B2B & SettlementType = Gross & OutgoingPaymentAccountingType = Cash Account |  | calc:OutgoingCorrespondentAccountGLCode |  | C+A | Payment |
| E | 20 | PaymentInstructionType = B2B & SettlementType = Net & OutgoingPaymentAccountingGLType = Linked Account | 393 | 39300840 | ALACAKLARDAN DOLAYI EDİNİLEN DİĞER VARLIKLAR > DİĞER ALACAKLI GEÇİCİ HESAPLAR | C+A | Payment |
| E | 25 | PaymentInstructionType = B2B & SettlementType = Net & OutgoingPaymentAccountingGLType = Ledger Account | 393 | 39300840 | ALACAKLARDAN DOLAYI EDİNİLEN DİĞER VARLIKLAR > DİĞER ALACAKLI GEÇİCİ HESAPLAR |  | Payment |
| E | 30 | PaymentInstructionType = A2A & SettlementType = Gross & OutgoingPaymentAccountingType = TemporaryAccount & OutgoingPaymentAccountingGLType = Linked Account | 393 | 39300840 | ALACAKLARDAN DOLAYI EDİNİLEN DİĞER VARLIKLAR > DİĞER ALACAKLI GEÇİCİ HESAPLAR | C+A | Payment |
| E | 35 | PaymentInstructionType = A2A & SettlementType = Gross & OutgoingPaymentAccountingType = TemporaryAccount & OutgoingPaymentAccountingGLType = Ledger Account | 393 | 39300840 | ALACAKLARDAN DOLAYI EDİNİLEN DİĞER VARLIKLAR > DİĞER ALACAKLI GEÇİCİ HESAPLAR |  | Payment |
| E | 41 | PaymentInstructionType = A2A & SettlementType = Gross |  | calc:OutgoingCorrespondentAccountGLCode |  | C+A | Payment |
| E | 45 | PaymentInstructionType = A2A & SettlementType = Net & OutgoingPaymentAccountingGLType = Linked Account | 393 | 39300840 | ALACAKLARDAN DOLAYI EDİNİLEN DİĞER VARLIKLAR > DİĞER ALACAKLI GEÇİCİ HESAPLAR | C+A | Payment |
| E | 50 | PaymentInstructionType = A2A & SettlementType = Net & OutgoingPaymentAccountingGLType = Ledger Account | 393 | 39300840 | ALACAKLARDAN DOLAYI EDİNİLEN DİĞER VARLIKLAR > DİĞER ALACAKLI GEÇİCİ HESAPLAR |  | Payment |
| E | 55 | PaymentInstructionType = V2V & SettlementType = Gross & OutgoingPaymentAccountingType = TemporaryAccount & OutgoingPaymentAccountingGLType = Linked Account | 393 | 39300840 | ALACAKLARDAN DOLAYI EDİNİLEN DİĞER VARLIKLAR > DİĞER ALACAKLI GEÇİCİ HESAPLAR | C+A | Payment |
| E | 60 | PaymentInstructionType = V2V & SettlementType = Gross & OutgoingPaymentAccountingType = TemporaryAccount & OutgoingPaymentAccountingGLType = Ledger Account | 393 | 39300840 | ALACAKLARDAN DOLAYI EDİNİLEN DİĞER VARLIKLAR > DİĞER ALACAKLI GEÇİCİ HESAPLAR |  | Payment |
| E | 65 | PaymentInstructionType = V2V & SettlementType = Gross |  | calc:TheirBeneficiaryCorrespondentGLCode |  | C+A | Payment |
| E | 70 | PaymentInstructionType = V2V & SettlementType = Net & OutgoingPaymentAccountingGLType = Linked Account | 393 | 39300840 | ALACAKLARDAN DOLAYI EDİNİLEN DİĞER VARLIKLAR > DİĞER ALACAKLI GEÇİCİ HESAPLAR | C+A | Payment |
| E | 75 | PaymentInstructionType = V2V & SettlementType = Net & OutgoingPaymentAccountingGLType = Ledger Account | 393 | 39300840 | ALACAKLARDAN DOLAYI EDİNİLEN DİĞER VARLIKLAR > DİĞER ALACAKLI GEÇİCİ HESAPLAR |  | Payment |
| E | 1000 | (kuralsiz) |  | calc:OutgoingExternalCustomerGLCode |  | C+A+WG | Payment |

### IncomingPaymentLCY

| On | Order | Kurallar | THP | Target | THP adi | Cust/Acc | Not |
|---|---|---|---|---|---|---|---|
| E | 5 | PaymentInstructionType = B2B & SettlementType = Gross & IncomingPaymentAccountingType = Temporary Account & IncomingPaymentAccountingGLType = Linked Account | 392 | 39200840 | ALACAKLARDAN DOLAYI EDİNİLEN DİĞER VARLIKLAR > DİĞER MUHTELİF BORÇLAR | C+A | Payment |
| E | 10 | PaymentInstructionType = B2B & SettlementType = Gross & IncomingPaymentAccountingType = Temporary Account & IncomingPaymentAccountingGLType = Ledger Account | 392 | 39200840 | ALACAKLARDAN DOLAYI EDİNİLEN DİĞER VARLIKLAR > DİĞER MUHTELİF BORÇLAR |  | Payment |
| E | 15 | PaymentInstructionType = B2B & SettlementType = Gross & IncomingPaymentAccountingType = Cash Account |  | calc:IncomingCorrespondentAccountGLCode |  | C+A | Payment |
| E | 20 | PaymentInstructionType = B2B & SettlementType = Net & IncomingPaymentAccountingGLType = Linked Account | 392 | 39200840 | ALACAKLARDAN DOLAYI EDİNİLEN DİĞER VARLIKLAR > DİĞER MUHTELİF BORÇLAR | C+A | Payment |
| E | 25 | PaymentInstructionType = B2B & SettlementType = Net & IncomingPaymentAccountingGLType = Ledger Account | 392 | 39200840 | ALACAKLARDAN DOLAYI EDİNİLEN DİĞER VARLIKLAR > DİĞER MUHTELİF BORÇLAR |  | Payment |
| E | 30 | PaymentInstructionType = A2A & SettlementType = Gross & IncomingPaymentAccountingType = Temporary Account & IncomingPaymentAccountingGLType = Linked Account | 392 | 39200840 | ALACAKLARDAN DOLAYI EDİNİLEN DİĞER VARLIKLAR > DİĞER MUHTELİF BORÇLAR | C+A | Payment |
| E | 35 | PaymentInstructionType = A2A & SettlementType = Gross & IncomingPaymentAccountingType = Temporary Account & IncomingPaymentAccountingGLType = Ledger Account | 392 | 39200840 | ALACAKLARDAN DOLAYI EDİNİLEN DİĞER VARLIKLAR > DİĞER MUHTELİF BORÇLAR |  | Payment |
| E | 40 | PaymentInstructionType = A2A & SettlementType = Gross |  | calc:IncomingCorrespondentAccountGLCode |  | C+A | Payment |
| E | 45 | PaymentInstructionType = A2A & SettlementType = Net & IncomingPaymentAccountingGLType = Linked Account | 392 | 39200840 | ALACAKLARDAN DOLAYI EDİNİLEN DİĞER VARLIKLAR > DİĞER MUHTELİF BORÇLAR | C+A | Payment |
| E | 50 | PaymentInstructionType = A2A & SettlementType = Net & IncomingPaymentAccountingGLType = Ledger Account | 392 | 39200840 | ALACAKLARDAN DOLAYI EDİNİLEN DİĞER VARLIKLAR > DİĞER MUHTELİF BORÇLAR |  | Payment |
| E | 55 | PaymentInstructionType = V2V & SettlementType = Gross & IncomingPaymentAccountingType = Temporary Account & IncomingPaymentAccountingGLType = Linked Account | 392 | 39200840 | ALACAKLARDAN DOLAYI EDİNİLEN DİĞER VARLIKLAR > DİĞER MUHTELİF BORÇLAR | C+A | Payment |
| E | 60 | PaymentInstructionType = V2V & SettlementType = Gross & IncomingPaymentAccountingType = Temporary Account & IncomingPaymentAccountingGLType = Ledger Account | 392 | 39200840 | ALACAKLARDAN DOLAYI EDİNİLEN DİĞER VARLIKLAR > DİĞER MUHTELİF BORÇLAR |  | Payment |
| E | 65 | PaymentInstructionType = V2V & SettlementType = Gross |  | calc:TheirSenderCorrespondentGLCode |  | C+A | Payment |
| E | 70 | PaymentInstructionType = V2V & SettlementType = Net & IncomingPaymentAccountingGLType = Linked Account | 392 | 39200840 | ALACAKLARDAN DOLAYI EDİNİLEN DİĞER VARLIKLAR > DİĞER MUHTELİF BORÇLAR | C+A | Payment |
| E | 75 | PaymentInstructionType = V2V & SettlementType = Net & IncomingPaymentAccountingGLType = Ledger Account | 392 | 39200840 | ALACAKLARDAN DOLAYI EDİNİLEN DİĞER VARLIKLAR > DİĞER MUHTELİF BORÇLAR |  | Payment |
| E | 1000 | (kuralsiz) |  | calc:IncomingExternalCustomerGLCode |  | C+A+WG | Payment |

### IncomingPaymentFCY

| On | Order | Kurallar | THP | Target | THP adi | Cust/Acc | Not |
|---|---|---|---|---|---|---|---|
| E | 5 | PaymentInstructionType = B2B & SettlementType = Gross & IncomingPaymentAccountingType = Temporary Account & IncomingPaymentAccountingGLType = Linked Account | 393 | 39300840 | ALACAKLARDAN DOLAYI EDİNİLEN DİĞER VARLIKLAR > DİĞER ALACAKLI GEÇİCİ HESAPLAR | C+A | Payment |
| E | 10 | PaymentInstructionType = B2B & SettlementType = Gross & IncomingPaymentAccountingType = Temporary Account & IncomingPaymentAccountingGLType = Ledger Account | 393 | 39300840 | ALACAKLARDAN DOLAYI EDİNİLEN DİĞER VARLIKLAR > DİĞER ALACAKLI GEÇİCİ HESAPLAR |  | Payment |
| E | 15 | PaymentInstructionType = B2B & SettlementType = Gross & IncomingPaymentAccountingType = Cash Account |  | calc:IncomingCorrespondentAccountGLCode |  | C+A | Payment |
| E | 20 | PaymentInstructionType = B2B & SettlementType = Net & IncomingPaymentAccountingGLType = Linked Account | 393 | 39300840 | ALACAKLARDAN DOLAYI EDİNİLEN DİĞER VARLIKLAR > DİĞER ALACAKLI GEÇİCİ HESAPLAR | C+A | Payment |
| E | 25 | PaymentInstructionType = B2B & SettlementType = Net & IncomingPaymentAccountingGLType = Ledger Account | 393 | 39300840 | ALACAKLARDAN DOLAYI EDİNİLEN DİĞER VARLIKLAR > DİĞER ALACAKLI GEÇİCİ HESAPLAR |  | Payment |
| E | 30 | PaymentInstructionType = A2A & SettlementType = Gross & IncomingPaymentAccountingType = Temporary Account & IncomingPaymentAccountingGLType = Linked Account | 393 | 39300840 | ALACAKLARDAN DOLAYI EDİNİLEN DİĞER VARLIKLAR > DİĞER ALACAKLI GEÇİCİ HESAPLAR | C+A | Payment |
| E | 35 | PaymentInstructionType = A2A & SettlementType = Gross & IncomingPaymentAccountingType = Temporary Account & IncomingPaymentAccountingGLType = Ledger Account | 393 | 39300840 | ALACAKLARDAN DOLAYI EDİNİLEN DİĞER VARLIKLAR > DİĞER ALACAKLI GEÇİCİ HESAPLAR |  | Payment |
| E | 40 | PaymentInstructionType = A2A & SettlementType = Gross |  | calc:IncomingCorrespondentAccountGLCode |  | C+A | Payment |
| E | 45 | PaymentInstructionType = A2A & SettlementType = Net & IncomingPaymentAccountingGLType = Linked Account | 393 | 39300840 | ALACAKLARDAN DOLAYI EDİNİLEN DİĞER VARLIKLAR > DİĞER ALACAKLI GEÇİCİ HESAPLAR | C+A | Payment |
| E | 50 | PaymentInstructionType = A2A & SettlementType = Net & IncomingPaymentAccountingGLType = Ledger Account | 393 | 39300840 | ALACAKLARDAN DOLAYI EDİNİLEN DİĞER VARLIKLAR > DİĞER ALACAKLI GEÇİCİ HESAPLAR |  | Payment |
| E | 55 | PaymentInstructionType = V2V & SettlementType = Gross & IncomingPaymentAccountingType = Temporary Account & IncomingPaymentAccountingGLType = Linked Account | 393 | 39300840 | ALACAKLARDAN DOLAYI EDİNİLEN DİĞER VARLIKLAR > DİĞER ALACAKLI GEÇİCİ HESAPLAR | C+A | Payment |
| E | 60 | PaymentInstructionType = V2V & SettlementType = Gross & IncomingPaymentAccountingType = Temporary Account & IncomingPaymentAccountingGLType = Ledger Account | 393 | 39300840 | ALACAKLARDAN DOLAYI EDİNİLEN DİĞER VARLIKLAR > DİĞER ALACAKLI GEÇİCİ HESAPLAR |  | Payment |
| E | 65 | PaymentInstructionType = V2V & SettlementType = Gross |  | calc:TheirSenderCorrespondentGLCode |  | C+A | Payment |
| E | 70 | PaymentInstructionType = V2V & SettlementType = Net & IncomingPaymentAccountingGLType = Linked Account | 393 | 39300840 | ALACAKLARDAN DOLAYI EDİNİLEN DİĞER VARLIKLAR > DİĞER ALACAKLI GEÇİCİ HESAPLAR | C+A | Payment |
| E | 75 | PaymentInstructionType = V2V & SettlementType = Net & IncomingPaymentAccountingGLType = Ledger Account | 393 | 39300840 | ALACAKLARDAN DOLAYI EDİNİLEN DİĞER VARLIKLAR > DİĞER ALACAKLI GEÇİCİ HESAPLAR |  | Payment |
| E | 1000 | (kuralsiz) |  | calc:IncomingExternalCustomerGLCode |  | C+A+WG | Payment |
