# Kirilim tablosu - Dunya Katilim - MM

> Kaynak: `imports/AccountingExcels` AccountMap sayfasi. Otomatik uretildi (2026-10-27). THP adi: katilim hesap plani PDF'inden; yaprak adlar ust seviye ile birlikte okunur.
> Kural sutunu: Rule1..Rule10 dolu olanlar `&` ile birlesik. Ayni (Path, Source) icinde `Order` kucuk olan once denenir; ilk tum-kurallari-gecen satir kazanir.
>

## TREX/BRWPLC1/MONEYMARKET/BRW/LCY

### CounterPartyGLAccount

| On | Order | Kurallar | THP | Target | THP adi | Cust/Acc | Not |
|---|---|---|---|---|---|---|---|
| E | 10 | IsAccountNeeded = 1 & UseExternalGLAccount = 1 |  | calc:ExternalGLAccount |  | C+A |  |
| E | 10 | Pas & IsAccountNeeded = 1 & UseExternalGLAccount = 0 | 338 | 3380000000 | KATILIM FONU VE DİĞER YABANCI KAYNAKLAR > PARA PİYASALARINA BORÇLAR - T.P. | C+A |  |
| E | 10 | Gil & IsAccountNeeded = 1 & UseExternalGLAccount = 0 | 338 | 3380000000 | KATILIM FONU VE DİĞER YABANCI KAYNAKLAR > PARA PİYASALARINA BORÇLAR - T.P. | C+A |  |

## TREX/BRWPLC1/MONEYMARKET/BRW/FCY

### CounterPartyGLAccount

| On | Order | Kurallar | THP | Target | THP adi | Cust/Acc | Not |
|---|---|---|---|---|---|---|---|
| E | 10 | IsAccountNeeded = 1 & UseExternalGLAccount = 1 |  | calc:ExternalGLAccount |  | C+A |  |
| E | 10 | Pas & IsAccountNeeded = 1 & UseExternalGLAccount = 0 | 339 | 3390000000 | KATILIM FONU VE DİĞER YABANCI KAYNAKLAR > PARA PİYASALARINA BORÇLAR - Y.P. | C+A |  |
| E | 20 | Gil & IsAccountNeeded = 1 & UseExternalGLAccount = 0 | 339 | 3390000000 | KATILIM FONU VE DİĞER YABANCI KAYNAKLAR > PARA PİYASALARINA BORÇLAR - Y.P. | C+A |  |

## TREX/BRWPLC1/MONEYMARKET/PLC/LCY

### CounterPartyGLAccount

| On | Order | Kurallar | THP | Target | THP adi | Cust/Acc | Not |
|---|---|---|---|---|---|---|---|
| E | 10 | IsAccountNeeded = 1 & UseExternalGLAccount = 1 |  | calc:ExternalGLAccount |  | C+A |  |
| E | 10 | IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = DOM & Mali Kesim & Kamu Mevduat Bankaları | 022010 | 0220100000 | YURTİÇİ BANKALAR - T.P. > VADELİ HESAP > KAMU MEVDUAT BANKALARI | C+A |  |
| E | 20 | IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = DOM & Mali Kesim & Özel Mevduat Bankaları | 022011 | 0220110000 | YURTİÇİ BANKALAR - T.P. > VADELİ HESAP > ÖZEL MEVDUAT BANKALARI | C+A |  |
| E | 30 | IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = DOM & Mali Kesim & Yabancı Mevduat Bankaları | 022012 | 0220120000 | YURTİÇİ BANKALAR - T.P. > VADELİ HESAP > YABANCI MEVDUAT BANKALARI | C+A |  |
| E | 40 | IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = DOM & Mali Kesim & Özel Kanunlara Göre Mevduat Kabulüne Yetkili Kuruluşlar | 022013 | 0220130000 | YURTİÇİ BANKALAR - T.P. > VADELİ HESAP > ÖZEL KANUNLARINA GÖRE MEVDUAT KABULÜNE YETKİLİ KURULUŞLAR | C+A |  |
| E | 50 | IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = DOM & Mali Kesim & Katılım Bankaları | 022014 | 0220140000 | YURTİÇİ BANKALAR - T.P. > VADELİ HESAP > KATILIM BANKALARI | C+A |  |
| E | 60 | IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = DOM & Mali Kesim & Kalkınma ve Yatırım Bankaları | 022015 | 0220150000 | YURTİÇİ BANKALAR - T.P. > VADELİ HESAP > KALKINMA VE YATIRIM BANKALARI | C+A |  |
| E | 10 | Pas & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC | 040 | 0400000000 | DÖNEN DEĞERLER > PARA PİYASALARINDAN ALACAKLAR - T.P. | C+A |  |

### InterestReceived

| On | Order | Kurallar | THP | Target | THP adi | Cust/Acc | Not |
|---|---|---|---|---|---|---|---|
| E | 10 | IsAccountNeeded = 1 & Market = OTC | 570011 | 5700110000 | ZORUNLU KARŞILIKLARDAN ALINAN GELİRLER - T.P. > TÜRKİYE CUMHURİYET MERKEZ BANKASINDAN > VADELİ HESAPLARDAN | C+A |  |

### InterestIncome

| On | Order | Kurallar | THP | Target | THP adi | Cust/Acc | Not |
|---|---|---|---|---|---|---|---|
| E | 10 | IsAccountNeeded = 1 & Market = OTC | 570011 | 5700110010 | ZORUNLU KARŞILIKLARDAN ALINAN GELİRLER - T.P. > TÜRKİYE CUMHURİYET MERKEZ BANKASINDAN > VADELİ HESAPLARDAN | C+A |  |

### AccruedIncome

| On | Order | Kurallar | THP | Target | THP adi | Cust/Acc | Not |
|---|---|---|---|---|---|---|---|
| E | 10 | IsAccountNeeded = 1 & Market = OTC | 22299 | 2229900010 | YATIRIM AMAÇLI DEĞERLER VE DİĞER AKTİFLER > DİĞER KÂR PAYI VE GELİR REESKONTLARI - T.P. > DİĞER | C+A |  |

## TREX/BRWPLC1/MONEYMARKET/PLC/FCY

### CounterPartyGLAccount

| On | Order | Kurallar | THP | Target | THP adi | Cust/Acc | Not |
|---|---|---|---|---|---|---|---|
| E | 10 | IsAccountNeeded = 1 & UseExternalGLAccount = 1 |  | calc:ExternalGLAccount |  | C+A |  |
| E | 10 | IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = DOM & Mali Kesim & Kamu Mevduat Bankaları | 023010 | 0230100000 | YURTİÇİ BANKALAR - Y.P. > VADELİ HESAP > KAMU MEVDUAT BANKALARI | C+A |  |
| E | 20 | IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = DOM & Mali Kesim & Özel Mevduat Bankaları | 023011 | 0230110000 | YURTİÇİ BANKALAR - Y.P. > VADELİ HESAP > ÖZEL MEVDUAT BANKALARI | C+A |  |
| E | 30 | IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = DOM & Mali Kesim & Yabancı Mevduat Bankaları | 023012 | 0230120000 | YURTİÇİ BANKALAR - Y.P. > VADELİ HESAP > YABANCI MEVDUAT BANKALARI | C+A |  |
| E | 40 | IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = DOM & Mali Kesim & Özel Kanunlara Göre Mevduat Kabulüne Yetkili Kuruluşlar | 023013 | 0230130000 | YURTİÇİ BANKALAR - Y.P. > VADELİ HESAP > ÖZEL KANUNLARINA GÖRE MEVDUAT KABULÜNE YETKİLİ KURULUŞLAR | C+A |  |
| E | 50 | IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = DOM & Mali Kesim & Katılım Bankaları | 023014 | 0230140000 | YURTİÇİ BANKALAR - Y.P. > VADELİ HESAP > KATILIM BANKALARI | C+A |  |
| E | 60 | IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = DOM & Mali Kesim & Kalkınma ve Yatırım Bankaları | 023015 | 0230150000 | YURTİÇİ BANKALAR - Y.P. > VADELİ HESAP > KALKINMA VE YATIRIM BANKALARI | C+A |  |
| E | 10 | Pas & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC | 041 | 0410000000 | DÖNEN DEĞERLER > PARA PİYASALARINDAN ALACAKLAR - Y.P. | C+A |  |

### InterestReceived

| On | Order | Kurallar | THP | Target | THP adi | Cust/Acc | Not |
|---|---|---|---|---|---|---|---|
| E | 10 | IsAccountNeeded = 1 & Market = OTC | 571011 | 5710110000 | BANKALARDAN ALINAN GELİRLER - Y.P. > YURTİÇİ BANKALARDAN > VADELİ HESAPLARDAN | C+A |  |

### InterestIncome

| On | Order | Kurallar | THP | Target | THP adi | Cust/Acc | Not |
|---|---|---|---|---|---|---|---|
| E | 10 | IsAccountNeeded = 1 & Market = OTC | 571011 | 5710110010 | BANKALARDAN ALINAN GELİRLER - Y.P. > YURTİÇİ BANKALARDAN > VADELİ HESAPLARDAN | C+A |  |

### AccruedIncome

| On | Order | Kurallar | THP | Target | THP adi | Cust/Acc | Not |
|---|---|---|---|---|---|---|---|
| E | 10 | IsAccountNeeded = 1 & Market = OTC | 22399 | 2239900000 | YATIRIM AMAÇLI DEĞERLER VE DİĞER AKTİFLER > DİĞER KÂR PAYI VE GELİR REESKONTLARI - Y.P. > DİĞER | C+A |  |

## TREX/BRWPLC1/LOAN/BRW/LCY

### CounterPartyGLAccount

| On | Order | Kurallar | THP | Target | THP adi | Cust/Acc | Not |
|---|---|---|---|---|---|---|---|
| E | 10 | IsAccountNeeded = 1 & UseExternalGLAccount = 1 |  | calc:ExternalGLAccount |  | C+A |  |
| E | 10 | Wakala & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = DOM & Term = Short & Mali Kesim & Bankalar | 34200 | 3420000000 | KATILIM FONU VE DİĞER YABANCI KAYNAKLAR > YURTİÇİ BANKALARDAN KULLANILAN KREDİLER - T.P. > KISA VADELİ | C+A |  |
| E | 20 | Wakala & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = DOM & Term = Short | 34400 | 3440000000 | KATILIM FONU VE DİĞER YABANCI KAYNAKLAR > YURTİÇİ DİĞER KURULUŞLARDAN KULLANILAN KREDİLER - T.P > KISA VADELİ | C+A |  |
| E | 10 | Wakala & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = DOM & Term = Long & Mali Kesim & Bankalar | 34210 | 3421000000 | KATILIM FONU VE DİĞER YABANCI KAYNAKLAR > YURTİÇİ BANKALARDAN KULLANILAN KREDİLER - T.P. > ORTA VE UZUN VADELİ | C+A |  |
| E | 20 | Wakala & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = DOM & Term = Long | 34410 | 3441000000 | KATILIM FONU VE DİĞER YABANCI KAYNAKLAR > YURTİÇİ DİĞER KURULUŞLARDAN KULLANILAN KREDİLER - T.P > ORTA VE UZUN VADELİ | C+A |  |
| E | 10 | Wakala & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = FRGN & Term = Short & Mali Kesim & Yurtdışı Bankalar | 348002 | 3480020000 | YURTDIŞINDAN KULLANILAN KREDİLER - T.P. > YURTDIŞI BANKALARDAN-KISA VADELİ > VEKALE | C+A |  |
| E | 10 | Wakala & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = FRGN & Term = Long & Mali Kesim & Yurtdışı Bankalar | 348102 | 3481020000 | YURTDIŞINDAN KULLANILAN KREDİLER - T.P. > YURTDIŞI BANKALARDAN-ORTA VE UZUN VADELİ > VEKALE | C+A |  |
| E | 10 | Murabaha & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = DOM & Term = Short & Mali Kesim & Bankalar | 34200 | 3420000000 | KATILIM FONU VE DİĞER YABANCI KAYNAKLAR > YURTİÇİ BANKALARDAN KULLANILAN KREDİLER - T.P. > KISA VADELİ | C+A |  |
| E | 20 | Murabaha & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = DOM & Term = Short | 34400 | 3440000000 | KATILIM FONU VE DİĞER YABANCI KAYNAKLAR > YURTİÇİ DİĞER KURULUŞLARDAN KULLANILAN KREDİLER - T.P > KISA VADELİ | C+A |  |
| E | 10 | Murabaha & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = DOM & Term = Long & Mali Kesim & Bankalar | 34210 | 3421000000 | KATILIM FONU VE DİĞER YABANCI KAYNAKLAR > YURTİÇİ BANKALARDAN KULLANILAN KREDİLER - T.P. > ORTA VE UZUN VADELİ | C+A |  |
| E | 20 | Murabaha & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = DOM & Term = Long | 34410 | 3441000000 | KATILIM FONU VE DİĞER YABANCI KAYNAKLAR > YURTİÇİ DİĞER KURULUŞLARDAN KULLANILAN KREDİLER - T.P > ORTA VE UZUN VADELİ | C+A |  |
| E | 10 | Murabaha & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = FRGN & Term = Short & Mali Kesim & Yurtdışı Bankalar | 348009 | 3480090000 | YURTDIŞINDAN KULLANILAN KREDİLER - T.P. > YURTDIŞI BANKALARDAN-KISA VADELİ > DİĞER | C+A |  |
| E | 10 | Murabaha & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = FRGN & Term = Long & Mali Kesim & Yurtdışı Bankalar | 348109 | 3481090000 | YURTDIŞINDAN KULLANILAN KREDİLER - T.P. > YURTDIŞI BANKALARDAN-ORTA VE UZUN VADELİ > DİĞER | C+A |  |
| E | 10 | Subordinated-Loan & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = DOM & Term = Long & Mali Kesim & Bankalar | 346000 | 3460000000 | SERMAYE HESAPLAMASINA DÂHİL EDİLECEK BORÇLANMA ARAÇLARI – T.P. > İLAVE ANA SERMAYE HESAPLAMASINA DÂHİL EDİLECEK BORÇLANMA ARAÇLARI > SERMAYE BENZERİ KREDİLER | C+A |  |
| E | 20 | Subordinated-Loan & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = DOM & Term = Long | 346000 | 3460001000 | SERMAYE HESAPLAMASINA DÂHİL EDİLECEK BORÇLANMA ARAÇLARI – T.P. > İLAVE ANA SERMAYE HESAPLAMASINA DÂHİL EDİLECEK BORÇLANMA ARAÇLARI > SERMAYE BENZERİ KREDİLER | C+A |  |
| E | 10 | Subordinated-Loan & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = FRGN & Term = Long & Mali Kesim & Yurtdışı Bankalar | 346000 | 3460002000 | SERMAYE HESAPLAMASINA DÂHİL EDİLECEK BORÇLANMA ARAÇLARI – T.P. > İLAVE ANA SERMAYE HESAPLAMASINA DÂHİL EDİLECEK BORÇLANMA ARAÇLARI > SERMAYE BENZERİ KREDİLER | C+A |  |
| E | 20 | Subordinated-Loan & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = FRGN & Term = Long | 346000 | 3460003000 | SERMAYE HESAPLAMASINA DÂHİL EDİLECEK BORÇLANMA ARAÇLARI – T.P. > İLAVE ANA SERMAYE HESAPLAMASINA DÂHİL EDİLECEK BORÇLANMA ARAÇLARI > SERMAYE BENZERİ KREDİLER | C+A |  |

### InterestPaid

| On | Order | Kurallar | THP | Target | THP adi | Cust/Acc | Not |
|---|---|---|---|---|---|---|---|
| E | 10 | Wakala & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Short & Mali Kesim & Bankalar | 64200 | 6420000000 | KÂR PAYI GİDERLERİ > YURTİÇİ BANKALARDAN KULLANILAN KREDİLERE VERİLEN KÂR PAYLARI - T.P. > KISA VADELİ | C+A |  |
| E | 20 | Wakala & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Short | 64400 | 6440000000 | KÂR PAYI GİDERLERİ > YURTİÇİ DİĞER KURULUŞLARDAN KULLANILAN KREDİLERE VERİLEN KÂR | C+A |  |
| E | 10 | Wakala & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Long & Mali Kesim & Bankalar | 64210 | 6421000000 | KÂR PAYI GİDERLERİ > YURTİÇİ BANKALARDAN KULLANILAN KREDİLERE VERİLEN KÂR PAYLARI - T.P. > ORTA VE UZUN VADELİ | C+A |  |
| E | 20 | Wakala & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Long | 64410 | 6441000000 | KÂR PAYI GİDERLERİ > YURTİÇİ DİĞER KURULUŞLARDAN KULLANILAN KREDİLERE VERİLEN KÂR > KISA VADELİ | C+A |  |
| E | 10 | Wakala & IsAccountNeeded = 1 & Market = OTC & Customer Location = FRGN & Term = Short & Mali Kesim & Yurtdışı Bankalar | 64800 | 6480000000 | KÂR PAYI GİDERLERİ > YURTDIŞI DİĞER KURULUŞLARDAN > YURTDIŞINDAN KULLANILAN KREDİLERE VERİLEN KÂR PAYLARI - T.P. | C+A |  |
| E | 10 | Wakala & IsAccountNeeded = 1 & Market = OTC & Customer Location = FRGN & Term = Long & Mali Kesim & Yurtdışı Bankalar | 64810 | 6481000000 | KÂR PAYI GİDERLERİ > YURTDIŞI DİĞER KURULUŞLARDAN > YURTDIŞI KURULUŞLARDAN-KISA VADELİ | C+A |  |
| E | 10 | Murabaha & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Short & Mali Kesim & Bankalar | 64200 | 6420000000 | KÂR PAYI GİDERLERİ > YURTİÇİ BANKALARDAN KULLANILAN KREDİLERE VERİLEN KÂR PAYLARI - T.P. > KISA VADELİ | C+A |  |
| E | 20 | Murabaha & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Short | 64400 | 6440000000 | KÂR PAYI GİDERLERİ > YURTİÇİ DİĞER KURULUŞLARDAN KULLANILAN KREDİLERE VERİLEN KÂR | C+A |  |
| E | 10 | Murabaha & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Long & Mali Kesim & Bankalar | 64210 | 6421000000 | KÂR PAYI GİDERLERİ > YURTİÇİ BANKALARDAN KULLANILAN KREDİLERE VERİLEN KÂR PAYLARI - T.P. > ORTA VE UZUN VADELİ | C+A |  |
| E | 20 | Murabaha & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Long | 64410 | 6441000000 | KÂR PAYI GİDERLERİ > YURTİÇİ DİĞER KURULUŞLARDAN KULLANILAN KREDİLERE VERİLEN KÂR > KISA VADELİ | C+A |  |
| E | 10 | Murabaha & IsAccountNeeded = 1 & Market = OTC & Customer Location = FRGN & Term = Short & Mali Kesim & Yurtdışı Bankalar | 64800 | 6480000000 | KÂR PAYI GİDERLERİ > YURTDIŞI DİĞER KURULUŞLARDAN > YURTDIŞINDAN KULLANILAN KREDİLERE VERİLEN KÂR PAYLARI - T.P. | C+A |  |
| E | 10 | Murabaha & IsAccountNeeded = 1 & Market = OTC & Customer Location = FRGN & Term = Long & Mali Kesim & Yurtdışı Bankalar | 64810 | 6481000000 | KÂR PAYI GİDERLERİ > YURTDIŞI DİĞER KURULUŞLARDAN > YURTDIŞI KURULUŞLARDAN-KISA VADELİ | C+A |  |
| E | 10 | Subordinated-Loan & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Long & Mali Kesim & Bankalar | 64600 | 6460000000 | KÂR PAYI GİDERLERİ > ORTA VE UZUN VADELİ > SERMAYE BENZERİ KREDİLERE VERİLEN KÂR PAYLARI - T.P. | C+A |  |
| E | 20 | Subordinated-Loan & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Long | 64601 | 6460100000 | KÂR PAYI GİDERLERİ > ORTA VE UZUN VADELİ | C+A |  |
| E | 10 | Subordinated-Loan & IsAccountNeeded = 1 & Market = OTC & Customer Location = FRGN & Term = Long & Mali Kesim & Yurtdışı Bankalar | 64602 | 6460200000 | KÂR PAYI GİDERLERİ > ORTA VE UZUN VADELİ > YURTİÇİ BANKALARDAN | C+A |  |
| E | 20 | Subordinated-Loan & IsAccountNeeded = 1 & Market = OTC & Customer Location = FRGN & Term = Long | 64603 | 6460300000 | KÂR PAYI GİDERLERİ > ORTA VE UZUN VADELİ > YURTİÇİ DİĞER KURULUŞLARDAN | C+A |  |

### InterestExpense

| On | Order | Kurallar | THP | Target | THP adi | Cust/Acc | Not |
|---|---|---|---|---|---|---|---|
| E | 10 | Wakala & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Short & Mali Kesim & Bankalar | 64200 | 6420000100 | KÂR PAYI GİDERLERİ > YURTİÇİ BANKALARDAN KULLANILAN KREDİLERE VERİLEN KÂR PAYLARI - T.P. > KISA VADELİ | C+A |  |
| E | 20 | Wakala & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Short | 64400 | 6440000100 | KÂR PAYI GİDERLERİ > YURTİÇİ DİĞER KURULUŞLARDAN KULLANILAN KREDİLERE VERİLEN KÂR | C+A |  |
| E | 10 | Wakala & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Long & Mali Kesim & Bankalar | 64210 | 6420000100 | KÂR PAYI GİDERLERİ > YURTİÇİ BANKALARDAN KULLANILAN KREDİLERE VERİLEN KÂR PAYLARI - T.P. > ORTA VE UZUN VADELİ | C+A |  |
| E | 20 | Wakala & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Long | 64410 | 6441000100 | KÂR PAYI GİDERLERİ > YURTİÇİ DİĞER KURULUŞLARDAN KULLANILAN KREDİLERE VERİLEN KÂR > KISA VADELİ | C+A |  |
| E | 10 | Wakala & IsAccountNeeded = 1 & Market = OTC & Customer Location = FRGN & Term = Short & Mali Kesim & Yurtdışı Bankalar | 64800 | 6480000100 | KÂR PAYI GİDERLERİ > YURTDIŞI DİĞER KURULUŞLARDAN > YURTDIŞINDAN KULLANILAN KREDİLERE VERİLEN KÂR PAYLARI - T.P. | C+A |  |
| E | 10 | Wakala & IsAccountNeeded = 1 & Market = OTC & Customer Location = FRGN & Term = Long & Mali Kesim & Yurtdışı Bankalar | 64810 | 6481000100 | KÂR PAYI GİDERLERİ > YURTDIŞI DİĞER KURULUŞLARDAN > YURTDIŞI KURULUŞLARDAN-KISA VADELİ | C+A |  |
| E | 10 | Murabaha & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Short & Mali Kesim & Bankalar | 64200 | 6420000100 | KÂR PAYI GİDERLERİ > YURTİÇİ BANKALARDAN KULLANILAN KREDİLERE VERİLEN KÂR PAYLARI - T.P. > KISA VADELİ | C+A |  |
| E | 20 | Murabaha & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Short | 64400 | 6440000100 | KÂR PAYI GİDERLERİ > YURTİÇİ DİĞER KURULUŞLARDAN KULLANILAN KREDİLERE VERİLEN KÂR | C+A |  |
| E | 10 | Murabaha & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Long & Mali Kesim & Bankalar | 64210 | 6420000100 | KÂR PAYI GİDERLERİ > YURTİÇİ BANKALARDAN KULLANILAN KREDİLERE VERİLEN KÂR PAYLARI - T.P. > ORTA VE UZUN VADELİ | C+A |  |
| E | 20 | Murabaha & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Long | 64410 | 6441000100 | KÂR PAYI GİDERLERİ > YURTİÇİ DİĞER KURULUŞLARDAN KULLANILAN KREDİLERE VERİLEN KÂR > KISA VADELİ | C+A |  |
| E | 10 | Murabaha & IsAccountNeeded = 1 & Market = OTC & Customer Location = FRGN & Term = Short & Mali Kesim & Yurtdışı Bankalar | 64800 | 6480000100 | KÂR PAYI GİDERLERİ > YURTDIŞI DİĞER KURULUŞLARDAN > YURTDIŞINDAN KULLANILAN KREDİLERE VERİLEN KÂR PAYLARI - T.P. | C+A |  |
| E | 10 | Murabaha & IsAccountNeeded = 1 & Market = OTC & Customer Location = FRGN & Term = Long & Mali Kesim & Yurtdışı Bankalar | 64810 | 6481000100 | KÂR PAYI GİDERLERİ > YURTDIŞI DİĞER KURULUŞLARDAN > YURTDIŞI KURULUŞLARDAN-KISA VADELİ | C+A |  |
| E | 10 | Subordinated-Loan & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Long & Mali Kesim & Bankalar | 64600 | 6460000100 | KÂR PAYI GİDERLERİ > ORTA VE UZUN VADELİ > SERMAYE BENZERİ KREDİLERE VERİLEN KÂR PAYLARI - T.P. | C+A |  |
| E | 20 | Subordinated-Loan & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Long | 64601 | 6460100100 | KÂR PAYI GİDERLERİ > ORTA VE UZUN VADELİ | C+A |  |
| E | 10 | Subordinated-Loan & IsAccountNeeded = 1 & Market = OTC & Customer Location = FRGN & Term = Long & Mali Kesim & Yurtdışı Bankalar | 64602 | 6460200100 | KÂR PAYI GİDERLERİ > ORTA VE UZUN VADELİ > YURTİÇİ BANKALARDAN | C+A |  |
| E | 20 | Subordinated-Loan & IsAccountNeeded = 1 & Market = OTC & Customer Location = FRGN & Term = Long | 64603 | 6460300100 | KÂR PAYI GİDERLERİ > ORTA VE UZUN VADELİ > YURTİÇİ DİĞER KURULUŞLARDAN | C+A |  |

### AccruedExpense

| On | Order | Kurallar | THP | Target | THP adi | Cust/Acc | Not |
|---|---|---|---|---|---|---|---|
| E | 10 | Wakala & IsAccountNeeded = 1 & Market = OTC | 36001 | 3600100000 | KATILIM FONU VE DİĞER YABANCI KAYNAKLAR > KÂR PAYI VE GİDER REESKONTLARI - T.P. > KULLANILAN KREDİ KÂR PAYI REESKONTLARI | C+A |  |
| E | 10 | Murabaha & IsAccountNeeded = 1 & Market = OTC | 36001 | 3600100000 | KATILIM FONU VE DİĞER YABANCI KAYNAKLAR > KÂR PAYI VE GİDER REESKONTLARI - T.P. > KULLANILAN KREDİ KÂR PAYI REESKONTLARI | C+A |  |
| E | 10 | Subordinated-Loan & IsAccountNeeded = 1 & Market = OTC | 36001 | 3600100000 | KATILIM FONU VE DİĞER YABANCI KAYNAKLAR > KÂR PAYI VE GİDER REESKONTLARI - T.P. > KULLANILAN KREDİ KÂR PAYI REESKONTLARI | C+A |  |

## TREX/BRWPLC1/LOAN/BRW/FCY

### CounterPartyGLAccount

| On | Order | Kurallar | THP | Target | THP adi | Cust/Acc | Not |
|---|---|---|---|---|---|---|---|
| E | 10 | IsAccountNeeded = 1 & UseExternalGLAccount = 1 |  | calc:ExternalGLAccount |  | C+A |  |
| E | 10 | Wakala & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = DOM & Term = Short & Mali Kesim & Bankalar | 34300 | 3430000000 | KATILIM FONU VE DİĞER YABANCI KAYNAKLAR > YURTİÇİ BANKALARDAN KULLANILAN KREDİLER - Y.P. > KISA VADELİ | C+A |  |
| E | 10 | Wakala & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = DOM & Term = Short | 34500 | 3450000000 | KATILIM FONU VE DİĞER YABANCI KAYNAKLAR > YURTİÇİ DİĞER KURULUŞLARDAN KULLANILAN KREDİLER -Y.P. > KISA VADELİ | C+A |  |
| E | 10 | Wakala & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = DOM & Term = Long & Mali Kesim & Bankalar | 34310 | 3431000000 | KATILIM FONU VE DİĞER YABANCI KAYNAKLAR > YURTİÇİ BANKALARDAN KULLANILAN KREDİLER - Y.P. > ORTA VE UZUN VADELİ | C+A |  |
| E | 10 | Wakala & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = DOM & Term = Long | 34510 | 3451000000 | KATILIM FONU VE DİĞER YABANCI KAYNAKLAR > YURTİÇİ DİĞER KURULUŞLARDAN KULLANILAN KREDİLER -Y.P. > ORTA VE UZUN VADELİ | C+A |  |
| E | 10 | Wakala & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = FRGN & Term = Short & Mali Kesim & Yurtdışı Bankalar | 349002 | 3490020000 | YURTDIŞINDAN KULLANILAN KREDİLER - Y.P. > YURTDIŞI BANKALARDAN-KISA VADELİ > VEKALE | C+A |  |
| E | 10 | Wakala & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = FRGN & Term = Long & Mali Kesim & Yurtdışı Bankalar | 349102 | 3491020000 | YURTDIŞINDAN KULLANILAN KREDİLER - Y.P. > YURTDIŞI BANKALARDAN-ORTA VE UZUN VADELİ > VEKALE | C+A |  |
| E | 10 | Murabaha & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = DOM & Term = Short & Mali Kesim & Bankalar | 34300 | 3430000000 | KATILIM FONU VE DİĞER YABANCI KAYNAKLAR > YURTİÇİ BANKALARDAN KULLANILAN KREDİLER - Y.P. > KISA VADELİ | C+A |  |
| E | 20 | Murabaha & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = DOM & Term = Short | 34500 | 3450000000 | KATILIM FONU VE DİĞER YABANCI KAYNAKLAR > YURTİÇİ DİĞER KURULUŞLARDAN KULLANILAN KREDİLER -Y.P. > KISA VADELİ | C+A |  |
| E | 10 | Murabaha & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = DOM & Term = Long & Mali Kesim & Bankalar | 34310 | 3431000000 | KATILIM FONU VE DİĞER YABANCI KAYNAKLAR > YURTİÇİ BANKALARDAN KULLANILAN KREDİLER - Y.P. > ORTA VE UZUN VADELİ | C+A |  |
| E | 10 | Murabaha & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = DOM & Term = Long | 34510 | 3451000000 | KATILIM FONU VE DİĞER YABANCI KAYNAKLAR > YURTİÇİ DİĞER KURULUŞLARDAN KULLANILAN KREDİLER -Y.P. > ORTA VE UZUN VADELİ | C+A |  |
| E | 10 | Murabaha & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = FRGN & Term = Short & Mali Kesim & Yurtdışı Bankalar | 349009 | 3490090000 | YURTDIŞINDAN KULLANILAN KREDİLER - Y.P. > YURTDIŞI BANKALARDAN-KISA VADELİ > DİĞER | C+A |  |
| E | 10 | Murabaha & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = FRGN & Term = Long & Mali Kesim & Yurtdışı Bankalar | 349109 | 3491090000 | YURTDIŞINDAN KULLANILAN KREDİLER - Y.P. > YURTDIŞI BANKALARDAN-ORTA VE UZUN VADELİ > DİĞER | C+A |  |
| E | 10 | Subordinated-Loan & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = DOM & Term = Long & Mali Kesim & Bankalar | 347000 | 3470000000 | SERMAYE HESAPLAMASINA DÂHİL EDİLECEK BORÇLANMA ARAÇLARI – Y.P. > İLAVE ANA SERMAYE HESAPLAMASINA DÂHİL EDİLECEK BORÇLANMA ARAÇLARI > SERMAYE BENZERİ KREDİLER | C+A |  |
| E | 20 | Subordinated-Loan & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = DOM & Term = Long | 347000 | 3470001000 | SERMAYE HESAPLAMASINA DÂHİL EDİLECEK BORÇLANMA ARAÇLARI – Y.P. > İLAVE ANA SERMAYE HESAPLAMASINA DÂHİL EDİLECEK BORÇLANMA ARAÇLARI > SERMAYE BENZERİ KREDİLER | C+A |  |
| E | 10 | Subordinated-Loan & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = FRGN & Term = Long & Mali Kesim & Yurtdışı Bankalar | 347000 | 3470002000 | SERMAYE HESAPLAMASINA DÂHİL EDİLECEK BORÇLANMA ARAÇLARI – Y.P. > İLAVE ANA SERMAYE HESAPLAMASINA DÂHİL EDİLECEK BORÇLANMA ARAÇLARI > SERMAYE BENZERİ KREDİLER | C+A |  |
| E | 20 | Subordinated-Loan & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = FRGN & Term = Long | 347000 | 3470003000 | SERMAYE HESAPLAMASINA DÂHİL EDİLECEK BORÇLANMA ARAÇLARI – Y.P. > İLAVE ANA SERMAYE HESAPLAMASINA DÂHİL EDİLECEK BORÇLANMA ARAÇLARI > SERMAYE BENZERİ KREDİLER | C+A |  |

### InterestPaid

| On | Order | Kurallar | THP | Target | THP adi | Cust/Acc | Not |
|---|---|---|---|---|---|---|---|
| E | 10 | Wakala & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Short & Mali Kesim & Bankalar | 64300 | 6430000000 | KÂR PAYI GİDERLERİ > YURTİÇİ BANKALARDAN KULLANILAN KREDİLERE VERİLEN KÂR PAYLARI - Y.P. > KISA VADELİ | C+A |  |
| E | 20 | Wakala & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Short | 64500 | 6450000000 | KÂR PAYI GİDERLERİ > PAYLARI - Y.P | C+A |  |
| E | 10 | Wakala & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Long & Mali Kesim & Bankalar | 64310 | 6431000000 | KÂR PAYI GİDERLERİ > YURTİÇİ BANKALARDAN KULLANILAN KREDİLERE VERİLEN KÂR PAYLARI - Y.P. > ORTA VE UZUN VADELİ | C+A |  |
| E | 20 | Wakala & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Long | 64510 | 6451000000 | KÂR PAYI GİDERLERİ | C+A |  |
| E | 10 | Wakala & IsAccountNeeded = 1 & Market = OTC & Customer Location = FRGN & Term = Short & Mali Kesim & Yurtdışı Bankalar | 64900 | 6490000000 | KÂR PAYI GİDERLERİ > YURTDIŞI FONLARDAN-ORTA VE UZUN VADELI > YURTDIŞINDAN KULLANILAN KREDİLERE VERİLEN KÂR PAYLARI - Y.P. | C+A |  |
| E | 10 | Wakala & IsAccountNeeded = 1 & Market = OTC & Customer Location = FRGN & Term = Long & Mali Kesim & Yurtdışı Bankalar | 64910 | 6491000000 | KÂR PAYI GİDERLERİ > YURTDIŞI FONLARDAN-ORTA VE UZUN VADELI > YURTDIŞI KURULUŞLARDAN-KISA VADELİ | C+A |  |
| E | 10 | Murabaha & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Short & Mali Kesim & Bankalar | 64300 | 6430000000 | KÂR PAYI GİDERLERİ > YURTİÇİ BANKALARDAN KULLANILAN KREDİLERE VERİLEN KÂR PAYLARI - Y.P. > KISA VADELİ | C+A |  |
| E | 20 | Murabaha & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Short | 64500 | 6450000000 | KÂR PAYI GİDERLERİ > PAYLARI - Y.P | C+A |  |
| E | 10 | Murabaha & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Long & Mali Kesim & Bankalar | 64310 | 6431000000 | KÂR PAYI GİDERLERİ > YURTİÇİ BANKALARDAN KULLANILAN KREDİLERE VERİLEN KÂR PAYLARI - Y.P. > ORTA VE UZUN VADELİ | C+A |  |
| E | 20 | Murabaha & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Long | 64510 | 6451000000 | KÂR PAYI GİDERLERİ | C+A |  |
| E | 10 | Murabaha & IsAccountNeeded = 1 & Market = OTC & Customer Location = FRGN & Term = Short & Mali Kesim & Yurtdışı Bankalar | 64900 | 6490000000 | KÂR PAYI GİDERLERİ > YURTDIŞI FONLARDAN-ORTA VE UZUN VADELI > YURTDIŞINDAN KULLANILAN KREDİLERE VERİLEN KÂR PAYLARI - Y.P. | C+A |  |
| E | 10 | Murabaha & IsAccountNeeded = 1 & Market = OTC & Customer Location = FRGN & Term = Long & Mali Kesim & Yurtdışı Bankalar | 64910 | 6491000000 | KÂR PAYI GİDERLERİ > YURTDIŞI FONLARDAN-ORTA VE UZUN VADELI > YURTDIŞI KURULUŞLARDAN-KISA VADELİ | C+A |  |
| E | 10 | Subordinated-Loan & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Long & Mali Kesim & Bankalar | 64700 | 6470000000 | KÂR PAYI GİDERLERİ > YURTDIŞI DİĞER KURULUŞLARDAN > SERMAYE BENZERİ KREDİLERE VERİLEN KÂR PAYLARI - Y.P. | C+A |  |
| E | 20 | Subordinated-Loan & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Long | 64701 | 6470100000 | KÂR PAYI GİDERLERİ > YURTDIŞI DİĞER KURULUŞLARDAN | C+A |  |
| E | 10 | Subordinated-Loan & IsAccountNeeded = 1 & Market = OTC & Customer Location = FRGN & Term = Long & Mali Kesim & Yurtdışı Bankalar | 64702 | 6470200000 | KÂR PAYI GİDERLERİ > YURTDIŞI DİĞER KURULUŞLARDAN > YURTİÇİ BANKALARDAN | C+A |  |
| E | 20 | Subordinated-Loan & IsAccountNeeded = 1 & Market = OTC & Customer Location = FRGN & Term = Long | 64703 | 6470300000 | KÂR PAYI GİDERLERİ > YURTDIŞI DİĞER KURULUŞLARDAN > YURTİÇİ DİĞER KURULUŞLARDAN | C+A |  |

### InterestExpense

| On | Order | Kurallar | THP | Target | THP adi | Cust/Acc | Not |
|---|---|---|---|---|---|---|---|
| E | 10 | Wakala & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Short & Mali Kesim & Bankalar | 64300 | 6430000100 | KÂR PAYI GİDERLERİ > YURTİÇİ BANKALARDAN KULLANILAN KREDİLERE VERİLEN KÂR PAYLARI - Y.P. > KISA VADELİ | C+A |  |
| E | 20 | Wakala & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Short | 64500 | 6450000100 | KÂR PAYI GİDERLERİ > PAYLARI - Y.P | C+A |  |
| E | 10 | Wakala & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Long & Mali Kesim & Bankalar | 64310 | 6431000100 | KÂR PAYI GİDERLERİ > YURTİÇİ BANKALARDAN KULLANILAN KREDİLERE VERİLEN KÂR PAYLARI - Y.P. > ORTA VE UZUN VADELİ | C+A |  |
| E | 20 | Wakala & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Long | 64510 | 6451000100 | KÂR PAYI GİDERLERİ | C+A |  |
| E | 10 | Wakala & IsAccountNeeded = 1 & Market = OTC & Customer Location = FRGN & Term = Short & Mali Kesim & Yurtdışı Bankalar | 64900 | 6490000100 | KÂR PAYI GİDERLERİ > YURTDIŞI FONLARDAN-ORTA VE UZUN VADELI > YURTDIŞINDAN KULLANILAN KREDİLERE VERİLEN KÂR PAYLARI - Y.P. | C+A |  |
| E | 10 | Wakala & IsAccountNeeded = 1 & Market = OTC & Customer Location = FRGN & Term = Long & Mali Kesim & Yurtdışı Bankalar | 64910 | 6491000100 | KÂR PAYI GİDERLERİ > YURTDIŞI FONLARDAN-ORTA VE UZUN VADELI > YURTDIŞI KURULUŞLARDAN-KISA VADELİ | C+A |  |
| E | 10 | Murabaha & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Short & Mali Kesim & Bankalar | 64300 | 6430000100 | KÂR PAYI GİDERLERİ > YURTİÇİ BANKALARDAN KULLANILAN KREDİLERE VERİLEN KÂR PAYLARI - Y.P. > KISA VADELİ | C+A |  |
| E | 20 | Murabaha & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Short | 64500 | 6450000100 | KÂR PAYI GİDERLERİ > PAYLARI - Y.P | C+A |  |
| E | 10 | Murabaha & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Long & Mali Kesim & Bankalar | 64310 | 6431000100 | KÂR PAYI GİDERLERİ > YURTİÇİ BANKALARDAN KULLANILAN KREDİLERE VERİLEN KÂR PAYLARI - Y.P. > ORTA VE UZUN VADELİ | C+A |  |
| E | 20 | Murabaha & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Long | 64510 | 6451000100 | KÂR PAYI GİDERLERİ | C+A |  |
| E | 10 | Murabaha & IsAccountNeeded = 1 & Market = OTC & Customer Location = FRGN & Term = Short & Mali Kesim & Yurtdışı Bankalar | 64900 | 6490000100 | KÂR PAYI GİDERLERİ > YURTDIŞI FONLARDAN-ORTA VE UZUN VADELI > YURTDIŞINDAN KULLANILAN KREDİLERE VERİLEN KÂR PAYLARI - Y.P. | C+A |  |
| E | 10 | Murabaha & IsAccountNeeded = 1 & Market = OTC & Customer Location = FRGN & Term = Long & Mali Kesim & Yurtdışı Bankalar | 64910 | 6491000100 | KÂR PAYI GİDERLERİ > YURTDIŞI FONLARDAN-ORTA VE UZUN VADELI > YURTDIŞI KURULUŞLARDAN-KISA VADELİ | C+A |  |
| E | 10 | Subordinated-Loan & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Long & Mali Kesim & Bankalar | 64700 | 6470000100 | KÂR PAYI GİDERLERİ > YURTDIŞI DİĞER KURULUŞLARDAN > SERMAYE BENZERİ KREDİLERE VERİLEN KÂR PAYLARI - Y.P. | C+A |  |
| E | 20 | Subordinated-Loan & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Long | 64701 | 6470100100 | KÂR PAYI GİDERLERİ > YURTDIŞI DİĞER KURULUŞLARDAN | C+A |  |
| E | 10 | Subordinated-Loan & IsAccountNeeded = 1 & Market = OTC & Customer Location = FRGN & Term = Long & Mali Kesim & Yurtdışı Bankalar | 64702 | 6470200100 | KÂR PAYI GİDERLERİ > YURTDIŞI DİĞER KURULUŞLARDAN > YURTİÇİ BANKALARDAN | C+A |  |
| E | 20 | Subordinated-Loan & IsAccountNeeded = 1 & Market = OTC & Customer Location = FRGN & Term = Long | 64703 | 6470300100 | KÂR PAYI GİDERLERİ > YURTDIŞI DİĞER KURULUŞLARDAN > YURTİÇİ DİĞER KURULUŞLARDAN | C+A |  |

### AccruedExpense

| On | Order | Kurallar | THP | Target | THP adi | Cust/Acc | Not |
|---|---|---|---|---|---|---|---|
| E | 10 | Wakala & IsAccountNeeded = 1 & Market = OTC | 36001 | 3610100000 | KATILIM FONU VE DİĞER YABANCI KAYNAKLAR > KÂR PAYI VE GİDER REESKONTLARI - T.P. > KULLANILAN KREDİ KÂR PAYI REESKONTLARI | C+A |  |
| E | 10 | Murabaha & IsAccountNeeded = 1 & Market = OTC | 36001 | 3610100000 | KATILIM FONU VE DİĞER YABANCI KAYNAKLAR > KÂR PAYI VE GİDER REESKONTLARI - T.P. > KULLANILAN KREDİ KÂR PAYI REESKONTLARI | C+A |  |
| E | 10 | Subordinated-Loan & IsAccountNeeded = 1 & Market = OTC | 36001 | 3610100000 | KATILIM FONU VE DİĞER YABANCI KAYNAKLAR > KÂR PAYI VE GİDER REESKONTLARI - T.P. > KULLANILAN KREDİ KÂR PAYI REESKONTLARI | C+A |  |

## TREX/BRWPLC1/LOAN/PLC/LCY

### CounterPartyGLAccount

| On | Order | Kurallar | THP | Target | THP adi | Cust/Acc | Not |
|---|---|---|---|---|---|---|---|
| E | 10 | IsAccountNeeded = 1 & UseExternalGLAccount = 1 |  | calc:ExternalGLAccount |  | C+A |  |
| E | 10 | Wakala & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = DOM & Term = Short & Mali Kesim & Bankalar & Fund Type EquityCapital | 126000 | 1260000000 | MALİ KESİME KULLANDIRILAN KISA VADELİ KREDİLER - T.P. > BANKALAR > ÖZKAYNAKLARDAN | C+A |  |
| E | 20 | Wakala & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = DOM & Term = Short & Mali Kesim & Bankalar & Fund Type ParticipationAccounts | 126002 | 1260020000 | MALİ KESİME KULLANDIRILAN KISA VADELİ KREDİLER - T.P. > BANKALAR > KATILMA HESAPLARINDAN | C+A |  |
| E | 30 | Wakala & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = DOM & Term = Short & Mali Kesim & Bankalar & Fund Type InvestmentAgency | 126004 | 1260040000 | MALİ KESİME KULLANDIRILAN KISA VADELİ KREDİLER - T.P. > BANKALAR > KATILMA HESAPLARI YATIRIM VEKÂLETİ HAVUZLARINDAN | C+A |  |
| E | 10 | Wakala & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = DOM & Term = Long & Mali Kesim & Bankalar & Fund Type EquityCapital | 146050 | 1460500000 | MALİ KESİME KULLANDIRILAN ORTA VE UZUN VADELİ KREDİLER - T.P. > BANKALAR > ÖZKAYNAKLARDAN | C+A |  |
| E | 20 | Wakala & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = DOM & Term = Long & Mali Kesim & Bankalar & Fund Type ParticipationAccounts | 146052 | 1460520000 | MALİ KESİME KULLANDIRILAN ORTA VE UZUN VADELİ KREDİLER - T.P. > BANKALAR > KATILMA HESAPLARINDAN | C+A |  |
| E | 30 | Wakala & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = DOM & Term = Long & Mali Kesim & Bankalar & Fund Type InvestmentAgency | 146054 | 1460540000 | MALİ KESİME KULLANDIRILAN ORTA VE UZUN VADELİ KREDİLER - T.P. > BANKALAR > KATILMA HESAPLARI YATIRIM VEKÂLETİ HAVUZLARINDAN | C+A |  |
| E | 10 | Wakala & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = FRGN & Term = Short & Mali Kesim & Yurtdışı Bankalar & Fund Type EquityCapital | 128000 | 1280000000 | YURTDIŞI KISA VADELİ KREDİLER - T.P. > BANKALAR > ÖZKAYNAKLARDAN | C+A |  |
| E | 20 | Wakala & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = FRGN & Term = Short & Mali Kesim & Yurtdışı Bankalar & Fund Type ParticipationAccounts | 128002 | 1280020000 | YURTDIŞI KISA VADELİ KREDİLER - T.P. > BANKALAR > KATILMA HESAPLARINDAN | C+A |  |
| E | 30 | Wakala & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = FRGN & Term = Short & Mali Kesim & Yurtdışı Bankalar & Fund Type InvestmentAgency | 128004 | 1280040000 | YURTDIŞI KISA VADELİ KREDİLER - T.P. > BANKALAR > KATILMA HESAPLARI YATIRIM VEKÂLETİ HAVUZLARINDAN | C+A |  |
| E | 10 | Wakala & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = FRGN & Term = Long & Mali Kesim & Yurtdışı Bankalar & Fund Type EquityCapital | 148000 | 1480000000 | YURTDIŞI ORTA VE UZUN VADELİ KREDİLER - T.P. > BANKALAR > ÖZKAYNAKLARDAN | C+A |  |
| E | 20 | Wakala & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = FRGN & Term = Long & Mali Kesim & Yurtdışı Bankalar & Fund Type ParticipationAccounts | 148002 | 1480020000 | YURTDIŞI ORTA VE UZUN VADELİ KREDİLER - T.P. > BANKALAR > KATILMA HESAPLARINDAN | C+A |  |
| E | 30 | Wakala & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = FRGN & Term = Long & Mali Kesim & Yurtdışı Bankalar & Fund Type InvestmentAgency | 148004 | 1480040000 | YURTDIŞI ORTA VE UZUN VADELİ KREDİLER - T.P. > BANKALAR > KATILMA HESAPLARI YATIRIM VEKÂLETİ HAVUZLARINDAN | C+A |  |
| E | 10 | Murabaha & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = DOM & Term = Short & Mali Kesim & Bankalar & Fund Type EquityCapital | 126000 | 1260000000 | MALİ KESİME KULLANDIRILAN KISA VADELİ KREDİLER - T.P. > BANKALAR > ÖZKAYNAKLARDAN | C+A |  |
| E | 20 | Murabaha & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = DOM & Term = Short & Mali Kesim & Bankalar & Fund Type ParticipationAccounts | 126002 | 1260020000 | MALİ KESİME KULLANDIRILAN KISA VADELİ KREDİLER - T.P. > BANKALAR > KATILMA HESAPLARINDAN | C+A |  |
| E | 30 | Murabaha & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = DOM & Term = Short & Mali Kesim & Bankalar & Fund Type InvestmentAgency | 126004 | 1260040000 | MALİ KESİME KULLANDIRILAN KISA VADELİ KREDİLER - T.P. > BANKALAR > KATILMA HESAPLARI YATIRIM VEKÂLETİ HAVUZLARINDAN | C+A |  |
| E | 10 | Murabaha & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = DOM & Term = Long & Mali Kesim & Bankalar & Fund Type EquityCapital | 146050 | 1460500000 | MALİ KESİME KULLANDIRILAN ORTA VE UZUN VADELİ KREDİLER - T.P. > BANKALAR > ÖZKAYNAKLARDAN | C+A |  |
| E | 20 | Murabaha & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = DOM & Term = Long & Mali Kesim & Bankalar & Fund Type ParticipationAccounts | 146052 | 1460520000 | MALİ KESİME KULLANDIRILAN ORTA VE UZUN VADELİ KREDİLER - T.P. > BANKALAR > KATILMA HESAPLARINDAN | C+A |  |
| E | 30 | Murabaha & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = DOM & Term = Long & Mali Kesim & Bankalar & Fund Type InvestmentAgency | 146054 | 1460540000 | MALİ KESİME KULLANDIRILAN ORTA VE UZUN VADELİ KREDİLER - T.P. > BANKALAR > KATILMA HESAPLARI YATIRIM VEKÂLETİ HAVUZLARINDAN | C+A |  |
| E | 10 | Murabaha & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = FRGN & Term = Short & Mali Kesim & Yurtdışı Bankalar & Fund Type EquityCapital | 128000 | 1280000000 | YURTDIŞI KISA VADELİ KREDİLER - T.P. > BANKALAR > ÖZKAYNAKLARDAN | C+A |  |
| E | 20 | Murabaha & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = FRGN & Term = Short & Mali Kesim & Yurtdışı Bankalar & Fund Type ParticipationAccounts | 128002 | 1280020000 | YURTDIŞI KISA VADELİ KREDİLER - T.P. > BANKALAR > KATILMA HESAPLARINDAN | C+A |  |
| E | 30 | Murabaha & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = FRGN & Term = Short & Mali Kesim & Yurtdışı Bankalar & Fund Type InvestmentAgency | 128004 | 1280040000 | YURTDIŞI KISA VADELİ KREDİLER - T.P. > BANKALAR > KATILMA HESAPLARI YATIRIM VEKÂLETİ HAVUZLARINDAN | C+A |  |
| E | 10 | Murabaha & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = FRGN & Term = Long & Mali Kesim & Yurtdışı Bankalar & Fund Type EquityCapital | 148000 | 1480000000 | YURTDIŞI ORTA VE UZUN VADELİ KREDİLER - T.P. > BANKALAR > ÖZKAYNAKLARDAN | C+A |  |
| E | 20 | Murabaha & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = FRGN & Term = Long & Mali Kesim & Yurtdışı Bankalar & Fund Type ParticipationAccounts | 148002 | 1480020000 | YURTDIŞI ORTA VE UZUN VADELİ KREDİLER - T.P. > BANKALAR > KATILMA HESAPLARINDAN | C+A |  |
| E | 30 | Murabaha & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = FRGN & Term = Long & Mali Kesim & Yurtdışı Bankalar & Fund Type InvestmentAgency | 148004 | 1480040000 | YURTDIŞI ORTA VE UZUN VADELİ KREDİLER - T.P. > BANKALAR > KATILMA HESAPLARI YATIRIM VEKÂLETİ HAVUZLARINDAN | C+A |  |
| E | 10 | Subordinated-Loan & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = DOM & Term = Long & Mali Kesim & Bankalar | 146050 | 1460500000 | MALİ KESİME KULLANDIRILAN ORTA VE UZUN VADELİ KREDİLER - T.P. > BANKALAR > ÖZKAYNAKLARDAN | C+A |  |
| E | 10 | Subordinated-Loan & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = FRGN & Term = Long & Mali Kesim & Yurtdışı Bankalar | 148030 | 1480300000 | KREDİLER > YURTDIŞI ORTA VE UZUN VADELİ KREDİLER - T.P. > SERMAYE BENZERİ KREDİLER | C+A |  |

### InterestReceived

| On | Order | Kurallar | THP | Target | THP adi | Cust/Acc | Not |
|---|---|---|---|---|---|---|---|
| E | 10 | Wakala & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Short & Mali Kesim & Bankalar & Fund Type EquityCapital | 526000 | 5260000000 | MALİ KESİME KULLANDIRILAN KISA VADELİ KREDİLERDEN ALINAN KÂR PAYLARI > BANKALAR > ÖZKAYNAKLARDAN | C+A |  |
| E | 20 | Wakala & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Short & Mali Kesim & Bankalar & Fund Type ParticipationAccounts | 526002 | 5260020000 | MALİ KESİME KULLANDIRILAN KISA VADELİ KREDİLERDEN ALINAN KÂR PAYLARI > BANKALAR > KATILMA HESAPLARINDAN | C+A |  |
| E | 30 | Wakala & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Short & Mali Kesim & Bankalar & Fund Type InvestmentAgency | 526004 | 5260040000 | MALİ KESİME KULLANDIRILAN KISA VADELİ KREDİLERDEN ALINAN KÂR PAYLARI > BANKALAR > KATILMA HESAPLARI YATIRIM VEKÂLETİ HAVUZLARINDAN | C+A |  |
| E | 10 | Wakala & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Long & Mali Kesim & Bankalar & Fund Type EquityCapital | 546050 | 5460500000 | MALİ KESİME KULLANDIRILAN ORTA VE UZUN VADELİ KREDİLERDEN ALINAN > BANKALAR > ÖZKAYNAKLARDAN | C+A |  |
| E | 20 | Wakala & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Long & Mali Kesim & Bankalar & Fund Type ParticipationAccounts | 546052 | 5460520000 | MALİ KESİME KULLANDIRILAN ORTA VE UZUN VADELİ KREDİLERDEN ALINAN > BANKALAR > KATILMA HESAPLARINDAN | C+A |  |
| E | 30 | Wakala & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Long & Mali Kesim & Bankalar & Fund Type InvestmentAgency | 546054 | 5460540000 | MALİ KESİME KULLANDIRILAN ORTA VE UZUN VADELİ KREDİLERDEN ALINAN > BANKALAR > KATILMA HESAPLARI YATIRIM VEKÂLETİ HAVUZLARINDAN | C+A |  |
| E | 10 | Wakala & IsAccountNeeded = 1 & Market = OTC & Customer Location = FRGN & Term = Short & Mali Kesim & Yurtdışı Bankalar & Fund Type EquityCapital | 528000 | 5280000000 | YURTDIŞI KISA VADELİ KREDİLERDEN ALINAN KÂR PAYLARI - T.P. > BANKALAR > ÖZKAYNAKLARDAN | C+A |  |
| E | 20 | Wakala & IsAccountNeeded = 1 & Market = OTC & Customer Location = FRGN & Term = Short & Mali Kesim & Yurtdışı Bankalar & Fund Type ParticipationAccounts | 528002 | 5280020000 | YURTDIŞI KISA VADELİ KREDİLERDEN ALINAN KÂR PAYLARI - T.P. > BANKALAR > KATILMA HESAPLARINDAN | C+A |  |
| E | 30 | Wakala & IsAccountNeeded = 1 & Market = OTC & Customer Location = FRGN & Term = Short & Mali Kesim & Yurtdışı Bankalar & Fund Type InvestmentAgency | 528004 | 5280040000 | YURTDIŞI KISA VADELİ KREDİLERDEN ALINAN KÂR PAYLARI - T.P. > BANKALAR > KATILMA HESAPLARI YATIRIM VEKÂLETİ HAVUZLARINDAN | C+A |  |
| E | 10 | Wakala & IsAccountNeeded = 1 & Market = OTC & Customer Location = FRGN & Term = Long & Mali Kesim & Yurtdışı Bankalar & Fund Type EquityCapital | 548000 | 5480000000 | YURTDIŞI ORTA VE UZUN VADELİ KREDİLERDEN ALINAN KÂR PAYLARI - T.P. > BANKALAR > ÖZKAYNAKLARDAN | C+A |  |
| E | 20 | Wakala & IsAccountNeeded = 1 & Market = OTC & Customer Location = FRGN & Term = Long & Mali Kesim & Yurtdışı Bankalar & Fund Type ParticipationAccounts | 548002 | 5480020000 | YURTDIŞI ORTA VE UZUN VADELİ KREDİLERDEN ALINAN KÂR PAYLARI - T.P. > BANKALAR > KATILMA HESAPLARINDAN | C+A |  |
| E | 30 | Wakala & IsAccountNeeded = 1 & Market = OTC & Customer Location = FRGN & Term = Long & Mali Kesim & Yurtdışı Bankalar & Fund Type InvestmentAgency | 548004 | 5480040000 | YURTDIŞI ORTA VE UZUN VADELİ KREDİLERDEN ALINAN KÂR PAYLARI - T.P. > BANKALAR > KATILMA HESAPLARI YATIRIM VEKÂLETİ HAVUZLARINDAN | C+A |  |
| E | 10 | Murabaha & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Short & Mali Kesim & Bankalar & Fund Type EquityCapital | 526000 | 5260000000 | MALİ KESİME KULLANDIRILAN KISA VADELİ KREDİLERDEN ALINAN KÂR PAYLARI > BANKALAR > ÖZKAYNAKLARDAN | C+A |  |
| E | 20 | Murabaha & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Short & Mali Kesim & Bankalar & Fund Type ParticipationAccounts | 526002 | 5260020000 | MALİ KESİME KULLANDIRILAN KISA VADELİ KREDİLERDEN ALINAN KÂR PAYLARI > BANKALAR > KATILMA HESAPLARINDAN | C+A |  |
| E | 30 | Murabaha & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Short & Mali Kesim & Bankalar & Fund Type InvestmentAgency | 526004 | 5260040000 | MALİ KESİME KULLANDIRILAN KISA VADELİ KREDİLERDEN ALINAN KÂR PAYLARI > BANKALAR > KATILMA HESAPLARI YATIRIM VEKÂLETİ HAVUZLARINDAN | C+A |  |
| E | 10 | Murabaha & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Long & Mali Kesim & Bankalar & Fund Type EquityCapital | 546050 | 5460500000 | MALİ KESİME KULLANDIRILAN ORTA VE UZUN VADELİ KREDİLERDEN ALINAN > BANKALAR > ÖZKAYNAKLARDAN | C+A |  |
| E | 20 | Murabaha & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Long & Mali Kesim & Bankalar & Fund Type ParticipationAccounts | 546052 | 5460520000 | MALİ KESİME KULLANDIRILAN ORTA VE UZUN VADELİ KREDİLERDEN ALINAN > BANKALAR > KATILMA HESAPLARINDAN | C+A |  |
| E | 30 | Murabaha & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Long & Mali Kesim & Bankalar & Fund Type InvestmentAgency | 546054 | 5460540000 | MALİ KESİME KULLANDIRILAN ORTA VE UZUN VADELİ KREDİLERDEN ALINAN > BANKALAR > KATILMA HESAPLARI YATIRIM VEKÂLETİ HAVUZLARINDAN | C+A |  |
| E | 10 | Murabaha & IsAccountNeeded = 1 & Market = OTC & Customer Location = FRGN & Term = Short & Mali Kesim & Yurtdışı Bankalar & Fund Type EquityCapital | 528000 | 5280000000 | YURTDIŞI KISA VADELİ KREDİLERDEN ALINAN KÂR PAYLARI - T.P. > BANKALAR > ÖZKAYNAKLARDAN | C+A |  |
| E | 20 | Murabaha & IsAccountNeeded = 1 & Market = OTC & Customer Location = FRGN & Term = Short & Mali Kesim & Yurtdışı Bankalar & Fund Type ParticipationAccounts | 528002 | 5280020000 | YURTDIŞI KISA VADELİ KREDİLERDEN ALINAN KÂR PAYLARI - T.P. > BANKALAR > KATILMA HESAPLARINDAN | C+A |  |
| E | 30 | Murabaha & IsAccountNeeded = 1 & Market = OTC & Customer Location = FRGN & Term = Short & Mali Kesim & Yurtdışı Bankalar & Fund Type InvestmentAgency | 528004 | 5280040000 | YURTDIŞI KISA VADELİ KREDİLERDEN ALINAN KÂR PAYLARI - T.P. > BANKALAR > KATILMA HESAPLARI YATIRIM VEKÂLETİ HAVUZLARINDAN | C+A |  |
| E | 10 | Murabaha & IsAccountNeeded = 1 & Market = OTC & Customer Location = FRGN & Term = Long & Mali Kesim & Yurtdışı Bankalar & Fund Type EquityCapital | 548000 | 5480000000 | YURTDIŞI ORTA VE UZUN VADELİ KREDİLERDEN ALINAN KÂR PAYLARI - T.P. > BANKALAR > ÖZKAYNAKLARDAN | C+A |  |
| E | 20 | Murabaha & IsAccountNeeded = 1 & Market = OTC & Customer Location = FRGN & Term = Long & Mali Kesim & Yurtdışı Bankalar & Fund Type ParticipationAccounts | 548002 | 5480020000 | YURTDIŞI ORTA VE UZUN VADELİ KREDİLERDEN ALINAN KÂR PAYLARI - T.P. > BANKALAR > KATILMA HESAPLARINDAN | C+A |  |
| E | 30 | Murabaha & IsAccountNeeded = 1 & Market = OTC & Customer Location = FRGN & Term = Long & Mali Kesim & Yurtdışı Bankalar & Fund Type InvestmentAgency | 548004 | 5480040000 | YURTDIŞI ORTA VE UZUN VADELİ KREDİLERDEN ALINAN KÂR PAYLARI - T.P. > BANKALAR > KATILMA HESAPLARI YATIRIM VEKÂLETİ HAVUZLARINDAN | C+A |  |
| E | 10 | Subordinated-Loan & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Long & Mali Kesim & Bankalar | 546050 | 5460500000 | MALİ KESİME KULLANDIRILAN ORTA VE UZUN VADELİ KREDİLERDEN ALINAN > BANKALAR > ÖZKAYNAKLARDAN | C+A |  |
| E | 10 | Subordinated-Loan & IsAccountNeeded = 1 & Market = OTC & Customer Location = FRGN & Term = Long & Mali Kesim & Yurtdışı Bankalar | 548030 | 5480300000 | KÂR PAYI GELİRLERİ > YURTDIŞI ORTA VE UZUN VADELİ KREDİLERDEN ALINAN KÂR PAYLARI - T.P. > SERMAYE BENZERİ KREDİLER | C+A |  |

### InterestIncome

| On | Order | Kurallar | THP | Target | THP adi | Cust/Acc | Not |
|---|---|---|---|---|---|---|---|
| E | 10 | Wakala & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Short & Mali Kesim & Bankalar & Fund Type EquityCapital | 526000 | 5260000010 | MALİ KESİME KULLANDIRILAN KISA VADELİ KREDİLERDEN ALINAN KÂR PAYLARI > BANKALAR > ÖZKAYNAKLARDAN | C+A |  |
| E | 20 | Wakala & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Short & Mali Kesim & Bankalar & Fund Type ParticipationAccounts | 526002 | 5260020010 | MALİ KESİME KULLANDIRILAN KISA VADELİ KREDİLERDEN ALINAN KÂR PAYLARI > BANKALAR > KATILMA HESAPLARINDAN | C+A |  |
| E | 30 | Wakala & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Short & Mali Kesim & Bankalar & Fund Type InvestmentAgency | 526004 | 5260040010 | MALİ KESİME KULLANDIRILAN KISA VADELİ KREDİLERDEN ALINAN KÂR PAYLARI > BANKALAR > KATILMA HESAPLARI YATIRIM VEKÂLETİ HAVUZLARINDAN | C+A |  |
| E | 10 | Wakala & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Long & Mali Kesim & Bankalar & Fund Type EquityCapital | 546050 | 5460500010 | MALİ KESİME KULLANDIRILAN ORTA VE UZUN VADELİ KREDİLERDEN ALINAN > BANKALAR > ÖZKAYNAKLARDAN | C+A |  |
| E | 20 | Wakala & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Long & Mali Kesim & Bankalar & Fund Type ParticipationAccounts | 546052 | 5460520010 | MALİ KESİME KULLANDIRILAN ORTA VE UZUN VADELİ KREDİLERDEN ALINAN > BANKALAR > KATILMA HESAPLARINDAN | C+A |  |
| E | 30 | Wakala & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Long & Mali Kesim & Bankalar & Fund Type InvestmentAgency | 546054 | 5460540010 | MALİ KESİME KULLANDIRILAN ORTA VE UZUN VADELİ KREDİLERDEN ALINAN > BANKALAR > KATILMA HESAPLARI YATIRIM VEKÂLETİ HAVUZLARINDAN | C+A |  |
| E | 10 | Wakala & IsAccountNeeded = 1 & Market = OTC & Customer Location = FRGN & Term = Short & Mali Kesim & Yurtdışı Bankalar & Fund Type EquityCapital | 528000 | 5280000010 | YURTDIŞI KISA VADELİ KREDİLERDEN ALINAN KÂR PAYLARI - T.P. > BANKALAR > ÖZKAYNAKLARDAN | C+A |  |
| E | 20 | Wakala & IsAccountNeeded = 1 & Market = OTC & Customer Location = FRGN & Term = Short & Mali Kesim & Yurtdışı Bankalar & Fund Type ParticipationAccounts | 528002 | 5280020010 | YURTDIŞI KISA VADELİ KREDİLERDEN ALINAN KÂR PAYLARI - T.P. > BANKALAR > KATILMA HESAPLARINDAN | C+A |  |
| E | 30 | Wakala & IsAccountNeeded = 1 & Market = OTC & Customer Location = FRGN & Term = Short & Mali Kesim & Yurtdışı Bankalar & Fund Type InvestmentAgency | 528004 | 5280040010 | YURTDIŞI KISA VADELİ KREDİLERDEN ALINAN KÂR PAYLARI - T.P. > BANKALAR > KATILMA HESAPLARI YATIRIM VEKÂLETİ HAVUZLARINDAN | C+A |  |
| E | 10 | Wakala & IsAccountNeeded = 1 & Market = OTC & Customer Location = FRGN & Term = Long & Mali Kesim & Yurtdışı Bankalar & Fund Type EquityCapital | 548000 | 5480000010 | YURTDIŞI ORTA VE UZUN VADELİ KREDİLERDEN ALINAN KÂR PAYLARI - T.P. > BANKALAR > ÖZKAYNAKLARDAN | C+A |  |
| E | 20 | Wakala & IsAccountNeeded = 1 & Market = OTC & Customer Location = FRGN & Term = Long & Mali Kesim & Yurtdışı Bankalar & Fund Type ParticipationAccounts | 548002 | 5480020010 | YURTDIŞI ORTA VE UZUN VADELİ KREDİLERDEN ALINAN KÂR PAYLARI - T.P. > BANKALAR > KATILMA HESAPLARINDAN | C+A |  |
| E | 30 | Wakala & IsAccountNeeded = 1 & Market = OTC & Customer Location = FRGN & Term = Long & Mali Kesim & Yurtdışı Bankalar & Fund Type InvestmentAgency | 548004 | 5480040010 | YURTDIŞI ORTA VE UZUN VADELİ KREDİLERDEN ALINAN KÂR PAYLARI - T.P. > BANKALAR > KATILMA HESAPLARI YATIRIM VEKÂLETİ HAVUZLARINDAN | C+A |  |
| E | 10 | Murabaha & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Short & Mali Kesim & Bankalar & Fund Type EquityCapital | 526000 | 5260000010 | MALİ KESİME KULLANDIRILAN KISA VADELİ KREDİLERDEN ALINAN KÂR PAYLARI > BANKALAR > ÖZKAYNAKLARDAN | C+A |  |
| E | 20 | Murabaha & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Short & Mali Kesim & Bankalar & Fund Type ParticipationAccounts | 526002 | 5260020010 | MALİ KESİME KULLANDIRILAN KISA VADELİ KREDİLERDEN ALINAN KÂR PAYLARI > BANKALAR > KATILMA HESAPLARINDAN | C+A |  |
| E | 30 | Murabaha & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Short & Mali Kesim & Bankalar & Fund Type InvestmentAgency | 526004 | 5260040010 | MALİ KESİME KULLANDIRILAN KISA VADELİ KREDİLERDEN ALINAN KÂR PAYLARI > BANKALAR > KATILMA HESAPLARI YATIRIM VEKÂLETİ HAVUZLARINDAN | C+A |  |
| E | 10 | Murabaha & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Long & Mali Kesim & Bankalar & Fund Type EquityCapital | 546050 | 5460500010 | MALİ KESİME KULLANDIRILAN ORTA VE UZUN VADELİ KREDİLERDEN ALINAN > BANKALAR > ÖZKAYNAKLARDAN | C+A |  |
| E | 20 | Murabaha & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Long & Mali Kesim & Bankalar & Fund Type ParticipationAccounts | 546052 | 5460520010 | MALİ KESİME KULLANDIRILAN ORTA VE UZUN VADELİ KREDİLERDEN ALINAN > BANKALAR > KATILMA HESAPLARINDAN | C+A |  |
| E | 30 | Murabaha & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Long & Mali Kesim & Bankalar & Fund Type InvestmentAgency | 546054 | 5460540010 | MALİ KESİME KULLANDIRILAN ORTA VE UZUN VADELİ KREDİLERDEN ALINAN > BANKALAR > KATILMA HESAPLARI YATIRIM VEKÂLETİ HAVUZLARINDAN | C+A |  |
| E | 10 | Murabaha & IsAccountNeeded = 1 & Market = OTC & Customer Location = FRGN & Term = Short & Mali Kesim & Yurtdışı Bankalar & Fund Type EquityCapital | 528000 | 5280000010 | YURTDIŞI KISA VADELİ KREDİLERDEN ALINAN KÂR PAYLARI - T.P. > BANKALAR > ÖZKAYNAKLARDAN | C+A |  |
| E | 20 | Murabaha & IsAccountNeeded = 1 & Market = OTC & Customer Location = FRGN & Term = Short & Mali Kesim & Yurtdışı Bankalar & Fund Type ParticipationAccounts | 528002 | 5280020010 | YURTDIŞI KISA VADELİ KREDİLERDEN ALINAN KÂR PAYLARI - T.P. > BANKALAR > KATILMA HESAPLARINDAN | C+A |  |
| E | 30 | Murabaha & IsAccountNeeded = 1 & Market = OTC & Customer Location = FRGN & Term = Short & Mali Kesim & Yurtdışı Bankalar & Fund Type InvestmentAgency | 528004 | 5280040010 | YURTDIŞI KISA VADELİ KREDİLERDEN ALINAN KÂR PAYLARI - T.P. > BANKALAR > KATILMA HESAPLARI YATIRIM VEKÂLETİ HAVUZLARINDAN | C+A |  |
| E | 10 | Murabaha & IsAccountNeeded = 1 & Market = OTC & Customer Location = FRGN & Term = Long & Mali Kesim & Yurtdışı Bankalar & Fund Type EquityCapital | 548000 | 5480000010 | YURTDIŞI ORTA VE UZUN VADELİ KREDİLERDEN ALINAN KÂR PAYLARI - T.P. > BANKALAR > ÖZKAYNAKLARDAN | C+A |  |
| E | 20 | Murabaha & IsAccountNeeded = 1 & Market = OTC & Customer Location = FRGN & Term = Long & Mali Kesim & Yurtdışı Bankalar & Fund Type ParticipationAccounts | 548002 | 5480020010 | YURTDIŞI ORTA VE UZUN VADELİ KREDİLERDEN ALINAN KÂR PAYLARI - T.P. > BANKALAR > KATILMA HESAPLARINDAN | C+A |  |
| E | 30 | Murabaha & IsAccountNeeded = 1 & Market = OTC & Customer Location = FRGN & Term = Long & Mali Kesim & Yurtdışı Bankalar & Fund Type InvestmentAgency | 548004 | 5480040010 | YURTDIŞI ORTA VE UZUN VADELİ KREDİLERDEN ALINAN KÂR PAYLARI - T.P. > BANKALAR > KATILMA HESAPLARI YATIRIM VEKÂLETİ HAVUZLARINDAN | C+A |  |
| E | 10 | Subordinated-Loan & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Long & Mali Kesim & Bankalar | 546050 | 5460500010 | MALİ KESİME KULLANDIRILAN ORTA VE UZUN VADELİ KREDİLERDEN ALINAN > BANKALAR > ÖZKAYNAKLARDAN | C+A |  |
| E | 10 | Subordinated-Loan & IsAccountNeeded = 1 & Market = OTC & Customer Location = FRGN & Term = Long & Mali Kesim & Yurtdışı Bankalar | 548030 | 5480300010 | KÂR PAYI GELİRLERİ > YURTDIŞI ORTA VE UZUN VADELİ KREDİLERDEN ALINAN KÂR PAYLARI - T.P. > SERMAYE BENZERİ KREDİLER | C+A |  |

### AccruedIncome

| On | Order | Kurallar | THP | Target | THP adi | Cust/Acc | Not |
|---|---|---|---|---|---|---|---|
| E | 10 | Wakala & IsAccountNeeded = 1 & Market = OTC & Fund Type EquityCapital | 220010 | 2200100000 | KREDİ KÂR PAYI GELİR TAHAKKUK REESKONTLARI - T.P. > KÂR PAYI REESKONTLARI > ÖZKAYNAKLARDAN | C+A |  |
| E | 20 | Wakala & IsAccountNeeded = 1 & Market = OTC & Fund Type ParticipationAccounts | 220012 | 2200120000 | KREDİ KÂR PAYI GELİR TAHAKKUK REESKONTLARI - T.P. > KÂR PAYI REESKONTLARI > KATILMA HESAPLARINDAN | C+A |  |
| E | 30 | Wakala & IsAccountNeeded = 1 & Market = OTC & Fund Type InvestmentAgency | 220014 | 2200140000 | KREDİ KÂR PAYI GELİR TAHAKKUK REESKONTLARI - T.P. > KÂR PAYI REESKONTLARI > KATILMA HESAPLARI YATIRIM VEKÂLETİ HAVUZLARINDAN | C+A |  |
| E | 10 | Murabaha & IsAccountNeeded = 1 & Market = OTC & Fund Type EquityCapital | 220010 | 2200100000 | KREDİ KÂR PAYI GELİR TAHAKKUK REESKONTLARI - T.P. > KÂR PAYI REESKONTLARI > ÖZKAYNAKLARDAN | C+A |  |
| E | 20 | Murabaha & IsAccountNeeded = 1 & Market = OTC & Fund Type ParticipationAccounts | 220012 | 2200120000 | KREDİ KÂR PAYI GELİR TAHAKKUK REESKONTLARI - T.P. > KÂR PAYI REESKONTLARI > KATILMA HESAPLARINDAN | C+A |  |
| E | 30 | Murabaha & IsAccountNeeded = 1 & Market = OTC & Fund Type InvestmentAgency | 220014 | 2200140000 | KREDİ KÂR PAYI GELİR TAHAKKUK REESKONTLARI - T.P. > KÂR PAYI REESKONTLARI > KATILMA HESAPLARI YATIRIM VEKÂLETİ HAVUZLARINDAN | C+A |  |
| E | 10 | Subordinated-Loan & IsAccountNeeded = 1 & Market = OTC | 220010 | 2200100000 | KREDİ KÂR PAYI GELİR TAHAKKUK REESKONTLARI - T.P. > KÂR PAYI REESKONTLARI > ÖZKAYNAKLARDAN | C+A |  |

## TREX/BRWPLC1/LOAN/PLC/FCY

### CounterPartyGLAccount

| On | Order | Kurallar | THP | Target | THP adi | Cust/Acc | Not |
|---|---|---|---|---|---|---|---|
| E | 10 | IsAccountNeeded = 1 & UseExternalGLAccount = 1 |  | calc:ExternalGLAccount |  | C+A |  |
| E | 10 | Wakala & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = DOM & Term = Short & Mali Kesim & Bankalar & Fund Type EquityCapital | 127000 | 1270000000 | MALİ KESİME KULLANDIRILAN KISA VADELİ KREDİLER - Y.P. > BANKALAR > ÖZKAYNAKLARDAN | C+A |  |
| E | 20 | Wakala & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = DOM & Term = Short & Mali Kesim & Bankalar & Fund Type ParticipationAccounts | 127002 | 1270020000 | MALİ KESİME KULLANDIRILAN KISA VADELİ KREDİLER - Y.P. > BANKALAR > KATILMA HESAPLARINDAN | C+A |  |
| E | 30 | Wakala & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = DOM & Term = Short & Mali Kesim & Bankalar & Fund Type InvestmentAgency | 127004 | 1270040000 | MALİ KESİME KULLANDIRILAN KISA VADELİ KREDİLER - Y.P. > BANKALAR > KATILMA HESAPLARI YATIRIM VEKÂLETİ HAVUZLARINDAN | C+A |  |
| E | 10 | Wakala & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = DOM & Term = Long & Mali Kesim & Bankalar & Fund Type EquityCapital | 147050 | 1470500000 | MALİ KESİME KULLANDIRILAN ORTA VE UZUN VADELİ KREDİLER - Y.P. > BANKALAR > ÖZKAYNAKLARDAN | C+A |  |
| E | 20 | Wakala & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = DOM & Term = Long & Mali Kesim & Bankalar & Fund Type ParticipationAccounts | 147052 | 1470520000 | MALİ KESİME KULLANDIRILAN ORTA VE UZUN VADELİ KREDİLER - Y.P. > BANKALAR > KATILMA HESAPLARINDAN | C+A |  |
| E | 30 | Wakala & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = DOM & Term = Long & Mali Kesim & Bankalar & Fund Type InvestmentAgency | 147054 | 1470540000 | MALİ KESİME KULLANDIRILAN ORTA VE UZUN VADELİ KREDİLER - Y.P. > BANKALAR > KATILMA HESAPLARI YATIRIM VEKÂLETİ HAVUZLARINDAN | C+A |  |
| E | 10 | Wakala & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = FRGN & Term = Short & Mali Kesim & Yurtdışı Bankalar & Fund Type EquityCapital | 129000 | 1290000000 | YURTDIŞI KISA VADELİ KREDİLER - Y.P. > BANKALAR > ÖZKAYNAKLARDAN | C+A |  |
| E | 20 | Wakala & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = FRGN & Term = Short & Mali Kesim & Yurtdışı Bankalar & Fund Type ParticipationAccounts | 129002 | 1290020000 | YURTDIŞI KISA VADELİ KREDİLER - Y.P. > BANKALAR > KATILMA HESAPLARINDAN | C+A |  |
| E | 30 | Wakala & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = FRGN & Term = Short & Mali Kesim & Yurtdışı Bankalar & Fund Type InvestmentAgency | 129004 | 1290040000 | YURTDIŞI KISA VADELİ KREDİLER - Y.P. > BANKALAR > KATILMA HESAPLARI YATIRIM VEKÂLETİ HAVUZLARINDAN | C+A |  |
| E | 10 | Wakala & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = FRGN & Term = Long & Mali Kesim & Yurtdışı Bankalar & Fund Type EquityCapital | 149000 | 1490000000 | YURTDIŞI ORTA VE UZUN VADELİ KREDİLER - Y.P. > BANKALAR > ÖZKAYNAKLARDAN | C+A |  |
| E | 20 | Wakala & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = FRGN & Term = Long & Mali Kesim & Yurtdışı Bankalar & Fund Type ParticipationAccounts | 149002 | 1490020000 | YURTDIŞI ORTA VE UZUN VADELİ KREDİLER - Y.P. > BANKALAR > KATILMA HESAPLARINDAN | C+A |  |
| E | 30 | Wakala & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = FRGN & Term = Long & Mali Kesim & Yurtdışı Bankalar & Fund Type InvestmentAgency | 149004 | 1490040000 | YURTDIŞI ORTA VE UZUN VADELİ KREDİLER - Y.P. > BANKALAR > KATILMA HESAPLARI YATIRIM VEKÂLETİ HAVUZLARINDAN | C+A |  |
| E | 10 | Murabaha & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = DOM & Term = Short & Mali Kesim & Bankalar & Fund Type EquityCapital | 127000 | 1270000000 | MALİ KESİME KULLANDIRILAN KISA VADELİ KREDİLER - Y.P. > BANKALAR > ÖZKAYNAKLARDAN | C+A |  |
| E | 20 | Murabaha & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = DOM & Term = Short & Mali Kesim & Bankalar & Fund Type ParticipationAccounts | 127002 | 1270020000 | MALİ KESİME KULLANDIRILAN KISA VADELİ KREDİLER - Y.P. > BANKALAR > KATILMA HESAPLARINDAN | C+A |  |
| E | 30 | Murabaha & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = DOM & Term = Short & Mali Kesim & Bankalar & Fund Type InvestmentAgency | 127004 | 1270040000 | MALİ KESİME KULLANDIRILAN KISA VADELİ KREDİLER - Y.P. > BANKALAR > KATILMA HESAPLARI YATIRIM VEKÂLETİ HAVUZLARINDAN | C+A |  |
| E | 10 | Murabaha & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = DOM & Term = Long & Mali Kesim & Bankalar & Fund Type EquityCapital | 147050 | 1470500000 | MALİ KESİME KULLANDIRILAN ORTA VE UZUN VADELİ KREDİLER - Y.P. > BANKALAR > ÖZKAYNAKLARDAN | C+A |  |
| E | 20 | Murabaha & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = DOM & Term = Long & Mali Kesim & Bankalar & Fund Type ParticipationAccounts | 147052 | 1470520000 | MALİ KESİME KULLANDIRILAN ORTA VE UZUN VADELİ KREDİLER - Y.P. > BANKALAR > KATILMA HESAPLARINDAN | C+A |  |
| E | 30 | Murabaha & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = DOM & Term = Long & Mali Kesim & Bankalar & Fund Type InvestmentAgency | 147054 | 1470540000 | MALİ KESİME KULLANDIRILAN ORTA VE UZUN VADELİ KREDİLER - Y.P. > BANKALAR > KATILMA HESAPLARI YATIRIM VEKÂLETİ HAVUZLARINDAN | C+A |  |
| E | 10 | Murabaha & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = FRGN & Term = Short & Mali Kesim & Yurtdışı Bankalar & Fund Type EquityCapital | 129000 | 1290000000 | YURTDIŞI KISA VADELİ KREDİLER - Y.P. > BANKALAR > ÖZKAYNAKLARDAN | C+A |  |
| E | 20 | Murabaha & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = FRGN & Term = Short & Mali Kesim & Yurtdışı Bankalar & Fund Type ParticipationAccounts | 129002 | 1290020000 | YURTDIŞI KISA VADELİ KREDİLER - Y.P. > BANKALAR > KATILMA HESAPLARINDAN | C+A |  |
| E | 30 | Murabaha & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = FRGN & Term = Short & Mali Kesim & Yurtdışı Bankalar & Fund Type InvestmentAgency | 129004 | 1290040000 | YURTDIŞI KISA VADELİ KREDİLER - Y.P. > BANKALAR > KATILMA HESAPLARI YATIRIM VEKÂLETİ HAVUZLARINDAN | C+A |  |
| E | 10 | Murabaha & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = FRGN & Term = Long & Mali Kesim & Yurtdışı Bankalar & Fund Type EquityCapital | 149000 | 1490000000 | YURTDIŞI ORTA VE UZUN VADELİ KREDİLER - Y.P. > BANKALAR > ÖZKAYNAKLARDAN | C+A |  |
| E | 20 | Murabaha & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = FRGN & Term = Long & Mali Kesim & Yurtdışı Bankalar & Fund Type ParticipationAccounts | 149002 | 1490020000 | YURTDIŞI ORTA VE UZUN VADELİ KREDİLER - Y.P. > BANKALAR > KATILMA HESAPLARINDAN | C+A |  |
| E | 30 | Murabaha & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = FRGN & Term = Long & Mali Kesim & Yurtdışı Bankalar & Fund Type InvestmentAgency | 149004 | 1490040000 | YURTDIŞI ORTA VE UZUN VADELİ KREDİLER - Y.P. > BANKALAR > KATILMA HESAPLARI YATIRIM VEKÂLETİ HAVUZLARINDAN | C+A |  |
| E | 10 | Subordinated-Loan & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = DOM & Term = Long & Mali Kesim & Bankalar | 147050 | 1470500000 | MALİ KESİME KULLANDIRILAN ORTA VE UZUN VADELİ KREDİLER - Y.P. > BANKALAR > ÖZKAYNAKLARDAN | C+A |  |
| E | 10 | Subordinated-Loan & IsAccountNeeded = 1 & UseExternalGLAccount = 0 & Market = OTC & Customer Location = FRGN & Term = Long & Mali Kesim & Yurtdışı Bankalar | 149030 | 1490300000 | KREDİLER > YURTDIŞI ORTA VE UZUN VADELİ KREDİLER - Y.P. > SERMAYE BENZERİ KREDİLER | C+A |  |

### InterestReceived

| On | Order | Kurallar | THP | Target | THP adi | Cust/Acc | Not |
|---|---|---|---|---|---|---|---|
| E | 10 | Wakala & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Short & Mali Kesim & Bankalar & Fund Type EquityCapital | 527000 | 5270000000 | KÂR PAYI GELİRLERİ > MALİ KESİME KULLANDIRILAN KISA VADELİ KREDİLERDEN ALINAN KÂR PAYLARI > BANKALAR | C+A |  |
| E | 20 | Wakala & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Short & Mali Kesim & Bankalar & Fund Type ParticipationAccounts | 527002 | 5270020000 | KÂR PAYI GELİRLERİ > MALİ KESİME KULLANDIRILAN KISA VADELİ KREDİLERDEN ALINAN KÂR PAYLARI > ÖZKAYNAKLARDAN | C+A |  |
| E | 30 | Wakala & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Short & Mali Kesim & Bankalar & Fund Type InvestmentAgency | 527004 | 5270040000 | KÂR PAYI GELİRLERİ > MALİ KESİME KULLANDIRILAN KISA VADELİ KREDİLERDEN ALINAN KÂR PAYLARI > KATILMA HESAPLARI ÖZEL FON HAVUZLARINDAN | C+A |  |
| E | 10 | Wakala & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Long & Mali Kesim & Bankalar & Fund Type EquityCapital | 547050 | 5470500000 | MALİ KESİME KULLANDIRILAN ORTA VE UZUN VADELİ KREDİLERDEN ALINAN > BANKALAR > ÖZKAYNAKLARDAN | C+A |  |
| E | 20 | Wakala & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Long & Mali Kesim & Bankalar & Fund Type ParticipationAccounts | 547052 | 5470520000 | MALİ KESİME KULLANDIRILAN ORTA VE UZUN VADELİ KREDİLERDEN ALINAN > BANKALAR > KATILMA HESAPLARINDAN | C+A |  |
| E | 30 | Wakala & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Long & Mali Kesim & Bankalar & Fund Type InvestmentAgency | 547054 | 5470540000 | MALİ KESİME KULLANDIRILAN ORTA VE UZUN VADELİ KREDİLERDEN ALINAN > BANKALAR > KATILMA HESAPLARI YATIRIM VEKÂLETİ HAVUZLARINDAN | C+A |  |
| E | 10 | Wakala & IsAccountNeeded = 1 & Market = OTC & Customer Location = FRGN & Term = Short & Mali Kesim & Yurtdışı Bankalar & Fund Type EquityCapital | 529000 | 5290000000 | YURTDIŞI KISA VADELİ KREDİLERDEN ALINAN KÂR PAYLARI - Y.P. > BANKALAR > ÖZKAYNAKLARDAN | C+A |  |
| E | 20 | Wakala & IsAccountNeeded = 1 & Market = OTC & Customer Location = FRGN & Term = Short & Mali Kesim & Yurtdışı Bankalar & Fund Type ParticipationAccounts | 529002 | 5290020000 | YURTDIŞI KISA VADELİ KREDİLERDEN ALINAN KÂR PAYLARI - Y.P. > BANKALAR > KATILMA HESAPLARINDAN | C+A |  |
| E | 30 | Wakala & IsAccountNeeded = 1 & Market = OTC & Customer Location = FRGN & Term = Short & Mali Kesim & Yurtdışı Bankalar & Fund Type InvestmentAgency | 529004 | 5290040000 | YURTDIŞI KISA VADELİ KREDİLERDEN ALINAN KÂR PAYLARI - Y.P. > BANKALAR > KATILMA HESAPLARI YATIRIM VEKÂLETİ HAVUZLARINDAN | C+A |  |
| E | 10 | Wakala & IsAccountNeeded = 1 & Market = OTC & Customer Location = FRGN & Term = Long & Mali Kesim & Yurtdışı Bankalar & Fund Type EquityCapital | 549000 | 5490000000 | YURTDIŞI ORTA VE UZUN VADELİ KREDİLERDEN ALINAN KÂR PAYLARI - Y.P. > BANKALAR > ÖZKAYNAKLARDAN | C+A |  |
| E | 20 | Wakala & IsAccountNeeded = 1 & Market = OTC & Customer Location = FRGN & Term = Long & Mali Kesim & Yurtdışı Bankalar & Fund Type ParticipationAccounts | 549002 | 5490020000 | YURTDIŞI ORTA VE UZUN VADELİ KREDİLERDEN ALINAN KÂR PAYLARI - Y.P. > BANKALAR > KATILMA HESAPLARINDAN | C+A |  |
| E | 30 | Wakala & IsAccountNeeded = 1 & Market = OTC & Customer Location = FRGN & Term = Long & Mali Kesim & Yurtdışı Bankalar & Fund Type InvestmentAgency | 549004 | 5490040000 | YURTDIŞI ORTA VE UZUN VADELİ KREDİLERDEN ALINAN KÂR PAYLARI - Y.P. > BANKALAR > KATILMA HESAPLARI YATIRIM VEKÂLETİ HAVUZLARINDAN | C+A |  |
| E | 10 | Murabaha & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Short & Mali Kesim & Bankalar & Fund Type EquityCapital | 527000 | 5270000000 | KÂR PAYI GELİRLERİ > MALİ KESİME KULLANDIRILAN KISA VADELİ KREDİLERDEN ALINAN KÂR PAYLARI > BANKALAR | C+A |  |
| E | 20 | Murabaha & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Short & Mali Kesim & Bankalar & Fund Type ParticipationAccounts | 527002 | 5270020000 | KÂR PAYI GELİRLERİ > MALİ KESİME KULLANDIRILAN KISA VADELİ KREDİLERDEN ALINAN KÂR PAYLARI > ÖZKAYNAKLARDAN | C+A |  |
| E | 30 | Murabaha & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Short & Mali Kesim & Bankalar & Fund Type InvestmentAgency | 527004 | 5270040000 | KÂR PAYI GELİRLERİ > MALİ KESİME KULLANDIRILAN KISA VADELİ KREDİLERDEN ALINAN KÂR PAYLARI > KATILMA HESAPLARI ÖZEL FON HAVUZLARINDAN | C+A |  |
| E | 10 | Murabaha & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Long & Mali Kesim & Bankalar & Fund Type EquityCapital | 547050 | 5470500000 | MALİ KESİME KULLANDIRILAN ORTA VE UZUN VADELİ KREDİLERDEN ALINAN > BANKALAR > ÖZKAYNAKLARDAN | C+A |  |
| E | 20 | Murabaha & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Long & Mali Kesim & Bankalar & Fund Type ParticipationAccounts | 547052 | 5470520000 | MALİ KESİME KULLANDIRILAN ORTA VE UZUN VADELİ KREDİLERDEN ALINAN > BANKALAR > KATILMA HESAPLARINDAN | C+A |  |
| E | 30 | Murabaha & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Long & Mali Kesim & Bankalar & Fund Type InvestmentAgency | 547054 | 5470540000 | MALİ KESİME KULLANDIRILAN ORTA VE UZUN VADELİ KREDİLERDEN ALINAN > BANKALAR > KATILMA HESAPLARI YATIRIM VEKÂLETİ HAVUZLARINDAN | C+A |  |
| E | 10 | Murabaha & IsAccountNeeded = 1 & Market = OTC & Customer Location = FRGN & Term = Short & Mali Kesim & Yurtdışı Bankalar & Fund Type EquityCapital | 529000 | 5290000000 | YURTDIŞI KISA VADELİ KREDİLERDEN ALINAN KÂR PAYLARI - Y.P. > BANKALAR > ÖZKAYNAKLARDAN | C+A |  |
| E | 20 | Murabaha & IsAccountNeeded = 1 & Market = OTC & Customer Location = FRGN & Term = Short & Mali Kesim & Yurtdışı Bankalar & Fund Type ParticipationAccounts | 529002 | 5290020000 | YURTDIŞI KISA VADELİ KREDİLERDEN ALINAN KÂR PAYLARI - Y.P. > BANKALAR > KATILMA HESAPLARINDAN | C+A |  |
| E | 30 | Murabaha & IsAccountNeeded = 1 & Market = OTC & Customer Location = FRGN & Term = Short & Mali Kesim & Yurtdışı Bankalar & Fund Type InvestmentAgency | 529004 | 5290040000 | YURTDIŞI KISA VADELİ KREDİLERDEN ALINAN KÂR PAYLARI - Y.P. > BANKALAR > KATILMA HESAPLARI YATIRIM VEKÂLETİ HAVUZLARINDAN | C+A |  |
| E | 10 | Murabaha & IsAccountNeeded = 1 & Market = OTC & Customer Location = FRGN & Term = Long & Mali Kesim & Yurtdışı Bankalar & Fund Type EquityCapital | 549000 | 5490000000 | YURTDIŞI ORTA VE UZUN VADELİ KREDİLERDEN ALINAN KÂR PAYLARI - Y.P. > BANKALAR > ÖZKAYNAKLARDAN | C+A |  |
| E | 20 | Murabaha & IsAccountNeeded = 1 & Market = OTC & Customer Location = FRGN & Term = Long & Mali Kesim & Yurtdışı Bankalar & Fund Type ParticipationAccounts | 549002 | 5490020000 | YURTDIŞI ORTA VE UZUN VADELİ KREDİLERDEN ALINAN KÂR PAYLARI - Y.P. > BANKALAR > KATILMA HESAPLARINDAN | C+A |  |
| E | 30 | Murabaha & IsAccountNeeded = 1 & Market = OTC & Customer Location = FRGN & Term = Long & Mali Kesim & Yurtdışı Bankalar & Fund Type InvestmentAgency | 549004 | 5490040000 | YURTDIŞI ORTA VE UZUN VADELİ KREDİLERDEN ALINAN KÂR PAYLARI - Y.P. > BANKALAR > KATILMA HESAPLARI YATIRIM VEKÂLETİ HAVUZLARINDAN | C+A |  |
| E | 10 | Subordinated-Loan & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Long & Mali Kesim & Bankalar | 547050 | 5470500000 | MALİ KESİME KULLANDIRILAN ORTA VE UZUN VADELİ KREDİLERDEN ALINAN > BANKALAR > ÖZKAYNAKLARDAN | C+A |  |
| E | 10 | Subordinated-Loan & IsAccountNeeded = 1 & Market = OTC & Customer Location = FRGN & Term = Long & Mali Kesim & Yurtdışı Bankalar | 549030 | 5490300000 | KÂR PAYI GELİRLERİ > YURTDIŞI ORTA VE UZUN VADELİ KREDİLERDEN ALINAN KÂR PAYLARI - Y.P. > SERMAYE BENZERİ KREDİLER | C+A |  |

### InterestIncome

| On | Order | Kurallar | THP | Target | THP adi | Cust/Acc | Not |
|---|---|---|---|---|---|---|---|
| E | 10 | Wakala & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Short & Mali Kesim & Bankalar & Fund Type EquityCapital | 527000 | 5270000010 | KÂR PAYI GELİRLERİ > MALİ KESİME KULLANDIRILAN KISA VADELİ KREDİLERDEN ALINAN KÂR PAYLARI > BANKALAR | C+A |  |
| E | 20 | Wakala & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Short & Mali Kesim & Bankalar & Fund Type ParticipationAccounts | 527002 | 5270020010 | KÂR PAYI GELİRLERİ > MALİ KESİME KULLANDIRILAN KISA VADELİ KREDİLERDEN ALINAN KÂR PAYLARI > ÖZKAYNAKLARDAN | C+A |  |
| E | 30 | Wakala & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Short & Mali Kesim & Bankalar & Fund Type InvestmentAgency | 527004 | 5270040010 | KÂR PAYI GELİRLERİ > MALİ KESİME KULLANDIRILAN KISA VADELİ KREDİLERDEN ALINAN KÂR PAYLARI > KATILMA HESAPLARI ÖZEL FON HAVUZLARINDAN | C+A |  |
| E | 10 | Wakala & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Long & Mali Kesim & Bankalar & Fund Type EquityCapital | 547050 | 5470500010 | MALİ KESİME KULLANDIRILAN ORTA VE UZUN VADELİ KREDİLERDEN ALINAN > BANKALAR > ÖZKAYNAKLARDAN | C+A |  |
| E | 20 | Wakala & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Long & Mali Kesim & Bankalar & Fund Type ParticipationAccounts | 547052 | 5470520010 | MALİ KESİME KULLANDIRILAN ORTA VE UZUN VADELİ KREDİLERDEN ALINAN > BANKALAR > KATILMA HESAPLARINDAN | C+A |  |
| E | 30 | Wakala & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Long & Mali Kesim & Bankalar & Fund Type InvestmentAgency | 547054 | 5470540010 | MALİ KESİME KULLANDIRILAN ORTA VE UZUN VADELİ KREDİLERDEN ALINAN > BANKALAR > KATILMA HESAPLARI YATIRIM VEKÂLETİ HAVUZLARINDAN | C+A |  |
| E | 10 | Wakala & IsAccountNeeded = 1 & Market = OTC & Customer Location = FRGN & Term = Short & Mali Kesim & Yurtdışı Bankalar & Fund Type EquityCapital | 529000 | 5290000010 | YURTDIŞI KISA VADELİ KREDİLERDEN ALINAN KÂR PAYLARI - Y.P. > BANKALAR > ÖZKAYNAKLARDAN | C+A |  |
| E | 20 | Wakala & IsAccountNeeded = 1 & Market = OTC & Customer Location = FRGN & Term = Short & Mali Kesim & Yurtdışı Bankalar & Fund Type ParticipationAccounts | 529002 | 5290020010 | YURTDIŞI KISA VADELİ KREDİLERDEN ALINAN KÂR PAYLARI - Y.P. > BANKALAR > KATILMA HESAPLARINDAN | C+A |  |
| E | 30 | Wakala & IsAccountNeeded = 1 & Market = OTC & Customer Location = FRGN & Term = Short & Mali Kesim & Yurtdışı Bankalar & Fund Type InvestmentAgency | 529004 | 5290040010 | YURTDIŞI KISA VADELİ KREDİLERDEN ALINAN KÂR PAYLARI - Y.P. > BANKALAR > KATILMA HESAPLARI YATIRIM VEKÂLETİ HAVUZLARINDAN | C+A |  |
| E | 10 | Wakala & IsAccountNeeded = 1 & Market = OTC & Customer Location = FRGN & Term = Long & Mali Kesim & Yurtdışı Bankalar & Fund Type EquityCapital | 549000 | 5490000010 | YURTDIŞI ORTA VE UZUN VADELİ KREDİLERDEN ALINAN KÂR PAYLARI - Y.P. > BANKALAR > ÖZKAYNAKLARDAN | C+A |  |
| E | 20 | Wakala & IsAccountNeeded = 1 & Market = OTC & Customer Location = FRGN & Term = Long & Mali Kesim & Yurtdışı Bankalar & Fund Type ParticipationAccounts | 549002 | 5490020010 | YURTDIŞI ORTA VE UZUN VADELİ KREDİLERDEN ALINAN KÂR PAYLARI - Y.P. > BANKALAR > KATILMA HESAPLARINDAN | C+A |  |
| E | 30 | Wakala & IsAccountNeeded = 1 & Market = OTC & Customer Location = FRGN & Term = Long & Mali Kesim & Yurtdışı Bankalar & Fund Type InvestmentAgency | 549004 | 5490040010 | YURTDIŞI ORTA VE UZUN VADELİ KREDİLERDEN ALINAN KÂR PAYLARI - Y.P. > BANKALAR > KATILMA HESAPLARI YATIRIM VEKÂLETİ HAVUZLARINDAN | C+A |  |
| E | 10 | Murabaha & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Short & Mali Kesim & Bankalar & Fund Type EquityCapital | 527000 | 5270000010 | KÂR PAYI GELİRLERİ > MALİ KESİME KULLANDIRILAN KISA VADELİ KREDİLERDEN ALINAN KÂR PAYLARI > BANKALAR | C+A |  |
| E | 20 | Murabaha & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Short & Mali Kesim & Bankalar & Fund Type ParticipationAccounts | 527002 | 5270020010 | KÂR PAYI GELİRLERİ > MALİ KESİME KULLANDIRILAN KISA VADELİ KREDİLERDEN ALINAN KÂR PAYLARI > ÖZKAYNAKLARDAN | C+A |  |
| E | 30 | Murabaha & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Short & Mali Kesim & Bankalar & Fund Type InvestmentAgency | 527004 | 5270040010 | KÂR PAYI GELİRLERİ > MALİ KESİME KULLANDIRILAN KISA VADELİ KREDİLERDEN ALINAN KÂR PAYLARI > KATILMA HESAPLARI ÖZEL FON HAVUZLARINDAN | C+A |  |
| E | 10 | Murabaha & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Long & Mali Kesim & Bankalar & Fund Type EquityCapital | 547050 | 5470500010 | MALİ KESİME KULLANDIRILAN ORTA VE UZUN VADELİ KREDİLERDEN ALINAN > BANKALAR > ÖZKAYNAKLARDAN | C+A |  |
| E | 20 | Murabaha & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Long & Mali Kesim & Bankalar & Fund Type ParticipationAccounts | 547052 | 5470520010 | MALİ KESİME KULLANDIRILAN ORTA VE UZUN VADELİ KREDİLERDEN ALINAN > BANKALAR > KATILMA HESAPLARINDAN | C+A |  |
| E | 30 | Murabaha & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Long & Mali Kesim & Bankalar & Fund Type InvestmentAgency | 547054 | 5470540010 | MALİ KESİME KULLANDIRILAN ORTA VE UZUN VADELİ KREDİLERDEN ALINAN > BANKALAR > KATILMA HESAPLARI YATIRIM VEKÂLETİ HAVUZLARINDAN | C+A |  |
| E | 10 | Murabaha & IsAccountNeeded = 1 & Market = OTC & Customer Location = FRGN & Term = Short & Mali Kesim & Yurtdışı Bankalar & Fund Type EquityCapital | 529000 | 5290000010 | YURTDIŞI KISA VADELİ KREDİLERDEN ALINAN KÂR PAYLARI - Y.P. > BANKALAR > ÖZKAYNAKLARDAN | C+A |  |
| E | 20 | Murabaha & IsAccountNeeded = 1 & Market = OTC & Customer Location = FRGN & Term = Short & Mali Kesim & Yurtdışı Bankalar & Fund Type ParticipationAccounts | 529002 | 5290020010 | YURTDIŞI KISA VADELİ KREDİLERDEN ALINAN KÂR PAYLARI - Y.P. > BANKALAR > KATILMA HESAPLARINDAN | C+A |  |
| E | 30 | Murabaha & IsAccountNeeded = 1 & Market = OTC & Customer Location = FRGN & Term = Short & Mali Kesim & Yurtdışı Bankalar & Fund Type InvestmentAgency | 529004 | 5290040010 | YURTDIŞI KISA VADELİ KREDİLERDEN ALINAN KÂR PAYLARI - Y.P. > BANKALAR > KATILMA HESAPLARI YATIRIM VEKÂLETİ HAVUZLARINDAN | C+A |  |
| E | 10 | Murabaha & IsAccountNeeded = 1 & Market = OTC & Customer Location = FRGN & Term = Long & Mali Kesim & Yurtdışı Bankalar & Fund Type EquityCapital | 549000 | 5490000010 | YURTDIŞI ORTA VE UZUN VADELİ KREDİLERDEN ALINAN KÂR PAYLARI - Y.P. > BANKALAR > ÖZKAYNAKLARDAN | C+A |  |
| E | 20 | Murabaha & IsAccountNeeded = 1 & Market = OTC & Customer Location = FRGN & Term = Long & Mali Kesim & Yurtdışı Bankalar & Fund Type ParticipationAccounts | 549002 | 5490020010 | YURTDIŞI ORTA VE UZUN VADELİ KREDİLERDEN ALINAN KÂR PAYLARI - Y.P. > BANKALAR > KATILMA HESAPLARINDAN | C+A |  |
| E | 30 | Murabaha & IsAccountNeeded = 1 & Market = OTC & Customer Location = FRGN & Term = Long & Mali Kesim & Yurtdışı Bankalar & Fund Type InvestmentAgency | 549004 | 5490040010 | YURTDIŞI ORTA VE UZUN VADELİ KREDİLERDEN ALINAN KÂR PAYLARI - Y.P. > BANKALAR > KATILMA HESAPLARI YATIRIM VEKÂLETİ HAVUZLARINDAN | C+A |  |
| E | 10 | Subordinated-Loan & IsAccountNeeded = 1 & Market = OTC & Customer Location = DOM & Term = Long & Mali Kesim & Bankalar | 547050 | 5470500010 | MALİ KESİME KULLANDIRILAN ORTA VE UZUN VADELİ KREDİLERDEN ALINAN > BANKALAR > ÖZKAYNAKLARDAN | C+A |  |
| E | 10 | Subordinated-Loan & IsAccountNeeded = 1 & Market = OTC & Customer Location = FRGN & Term = Long & Mali Kesim & Yurtdışı Bankalar | 549030 | 5490300010 | KÂR PAYI GELİRLERİ > YURTDIŞI ORTA VE UZUN VADELİ KREDİLERDEN ALINAN KÂR PAYLARI - Y.P. > SERMAYE BENZERİ KREDİLER | C+A |  |

### AccruedIncome

| On | Order | Kurallar | THP | Target | THP adi | Cust/Acc | Not |
|---|---|---|---|---|---|---|---|
| E | 10 | Wakala & IsAccountNeeded = 1 & Market = OTC & Fund Type EquityCapital | 221010 | 2210100000 | KREDİ KÂR PAYI GELİR TAHAKKUK REESKONTLARI - Y.P. > KÂR PAYI REESKONTLARI > ÖZKAYNAKLARDAN | C+A |  |
| E | 20 | Wakala & IsAccountNeeded = 1 & Market = OTC & Fund Type ParticipationAccounts | 221012 | 2210120000 | KREDİ KÂR PAYI GELİR TAHAKKUK REESKONTLARI - Y.P. > KÂR PAYI REESKONTLARI > KATILMA HESAPLARINDAN | C+A |  |
| E | 30 | Wakala & IsAccountNeeded = 1 & Market = OTC & Fund Type InvestmentAgency | 221014 | 2210140000 | KREDİ KÂR PAYI GELİR TAHAKKUK REESKONTLARI - Y.P. > KÂR PAYI REESKONTLARI > KATILMA HESAPLARI YATIRIM VEKÂLETİ HAVUZLARINDAN | C+A |  |
| E | 10 | Murabaha & IsAccountNeeded = 1 & Market = OTC & Fund Type EquityCapital | 221010 | 2210100000 | KREDİ KÂR PAYI GELİR TAHAKKUK REESKONTLARI - Y.P. > KÂR PAYI REESKONTLARI > ÖZKAYNAKLARDAN | C+A |  |
| E | 20 | Murabaha & IsAccountNeeded = 1 & Market = OTC & Fund Type ParticipationAccounts | 221012 | 2210120000 | KREDİ KÂR PAYI GELİR TAHAKKUK REESKONTLARI - Y.P. > KÂR PAYI REESKONTLARI > KATILMA HESAPLARINDAN | C+A |  |
| E | 30 | Murabaha & IsAccountNeeded = 1 & Market = OTC & Fund Type InvestmentAgency | 221014 | 2210140000 | KREDİ KÂR PAYI GELİR TAHAKKUK REESKONTLARI - Y.P. > KÂR PAYI REESKONTLARI > KATILMA HESAPLARI YATIRIM VEKÂLETİ HAVUZLARINDAN | C+A |  |
| E | 10 | Subordinated-Loan & IsAccountNeeded = 1 & Market = OTC | 221010 | 2210100000 | KREDİ KÂR PAYI GELİR TAHAKKUK REESKONTLARI - Y.P. > KÂR PAYI REESKONTLARI > ÖZKAYNAKLARDAN | C+A |  |

## TREX/BRWPLC1

### FxPositionLCY

| On | Order | Kurallar | THP | Target | THP adi | Cust/Acc | Not |
|---|---|---|---|---|---|---|---|
| E | 10 | (kuralsiz) | 294 | 29400 | YATIRIM AMAÇLI DEĞERLER VE DİĞER AKTİFLER > DÖVİZ ALIM/SATIM HESABI - T.P. |  | FxPosition |

### FxPosition

| On | Order | Kurallar | THP | Target | THP adi | Cust/Acc | Not |
|---|---|---|---|---|---|---|---|
| E | 10 | (kuralsiz) | 295 | 2950100000 | YATIRIM AMAÇLI DEĞERLER VE DİĞER AKTİFLER > DÖVİZ VAZİYETİ - Y.P. |  | FxPosition |

### OutgoingPaymentLCY

| On | Order | Kurallar | THP | Target | THP adi | Cust/Acc | Not |
|---|---|---|---|---|---|---|---|
| E | 5 | PaymentInstructionType = B2B & SettlementType = Gross & OutgoingPaymentAccountingType = TemporaryAccount & OutgoingPaymentAccountingGLType = Linked Account | 39299 | 3929900011 | KATILIM FONU VE DİĞER YABANCI KAYNAKLAR > ALACAKLI GEÇİCİ HESAPLAR - T.P. > DİĞER ALACAKLI GEÇİCİ HESAPLAR | C+A | Payment |
| E | 10 | PaymentInstructionType = B2B & SettlementType = Gross & OutgoingPaymentAccountingType = TemporaryAccount & OutgoingPaymentAccountingGLType = Ledger Account | 39299 | 3929900011 | KATILIM FONU VE DİĞER YABANCI KAYNAKLAR > ALACAKLI GEÇİCİ HESAPLAR - T.P. > DİĞER ALACAKLI GEÇİCİ HESAPLAR |  | Payment |
| E | 15 | PaymentInstructionType = B2B & SettlementType = Gross & OutgoingPaymentAccountingType = Cash Account |  | calc:OutgoingCorrespondentAccountGLCode |  | C+A | Payment |
| E | 20 | PaymentInstructionType = B2B & SettlementType = Net & OutgoingPaymentAccountingGLType = Linked Account | 39299 | 3929900011 | KATILIM FONU VE DİĞER YABANCI KAYNAKLAR > ALACAKLI GEÇİCİ HESAPLAR - T.P. > DİĞER ALACAKLI GEÇİCİ HESAPLAR | C+A | Payment |
| E | 25 | PaymentInstructionType = B2B & SettlementType = Net & OutgoingPaymentAccountingGLType = Ledger Account | 39299 | 3929900011 | KATILIM FONU VE DİĞER YABANCI KAYNAKLAR > ALACAKLI GEÇİCİ HESAPLAR - T.P. > DİĞER ALACAKLI GEÇİCİ HESAPLAR |  | Payment |
| E | 30 | PaymentInstructionType = A2A & SettlementType = Gross & OutgoingPaymentAccountingType = TemporaryAccount & OutgoingPaymentAccountingGLType = Linked Account | 39299 | 3929900011 | KATILIM FONU VE DİĞER YABANCI KAYNAKLAR > ALACAKLI GEÇİCİ HESAPLAR - T.P. > DİĞER ALACAKLI GEÇİCİ HESAPLAR | C+A | Payment |
| E | 35 | PaymentInstructionType = A2A & SettlementType = Gross & OutgoingPaymentAccountingType = TemporaryAccount & OutgoingPaymentAccountingGLType = Ledger Account | 39299 | 3929900011 | KATILIM FONU VE DİĞER YABANCI KAYNAKLAR > ALACAKLI GEÇİCİ HESAPLAR - T.P. > DİĞER ALACAKLI GEÇİCİ HESAPLAR |  | Payment |
| E | 40 | PaymentInstructionType = A2A & SettlementType = Gross |  | calc:OutgoingCorrespondentAccountGLCode |  | C+A | Payment |
| E | 45 | PaymentInstructionType = A2A & SettlementType = Net & OutgoingPaymentAccountingGLType = Linked Account | 39299 | 3929900011 | KATILIM FONU VE DİĞER YABANCI KAYNAKLAR > ALACAKLI GEÇİCİ HESAPLAR - T.P. > DİĞER ALACAKLI GEÇİCİ HESAPLAR | C+A | Payment |
| E | 50 | PaymentInstructionType = A2A & SettlementType = Net & OutgoingPaymentAccountingGLType = Ledger Account | 39299 | 3929900011 | KATILIM FONU VE DİĞER YABANCI KAYNAKLAR > ALACAKLI GEÇİCİ HESAPLAR - T.P. > DİĞER ALACAKLI GEÇİCİ HESAPLAR |  | Payment |
| E | 55 | PaymentInstructionType = V2V & SettlementType = Gross & OutgoingPaymentAccountingType = TemporaryAccount & OutgoingPaymentAccountingGLType = Linked Account | 39299 | 3929900011 | KATILIM FONU VE DİĞER YABANCI KAYNAKLAR > ALACAKLI GEÇİCİ HESAPLAR - T.P. > DİĞER ALACAKLI GEÇİCİ HESAPLAR | C+A | Payment |
| E | 60 | PaymentInstructionType = V2V & SettlementType = Gross & OutgoingPaymentAccountingType = TemporaryAccount & OutgoingPaymentAccountingGLType = Ledger Account | 39299 | 3929900011 | KATILIM FONU VE DİĞER YABANCI KAYNAKLAR > ALACAKLI GEÇİCİ HESAPLAR - T.P. > DİĞER ALACAKLI GEÇİCİ HESAPLAR |  | Payment |
| E | 65 | PaymentInstructionType = V2V & SettlementType = Gross |  | calc:TheirBeneficiaryCorrespondentGLCode |  | C+A | Payment |
| E | 70 | PaymentInstructionType = V2V & SettlementType = Net & OutgoingPaymentAccountingGLType = Linked Account | 39299 | 3929900011 | KATILIM FONU VE DİĞER YABANCI KAYNAKLAR > ALACAKLI GEÇİCİ HESAPLAR - T.P. > DİĞER ALACAKLI GEÇİCİ HESAPLAR | C+A | Payment |
| E | 75 | PaymentInstructionType = V2V & SettlementType = Net & OutgoingPaymentAccountingGLType = Ledger Account | 39299 | 3929900011 | KATILIM FONU VE DİĞER YABANCI KAYNAKLAR > ALACAKLI GEÇİCİ HESAPLAR - T.P. > DİĞER ALACAKLI GEÇİCİ HESAPLAR |  | Payment |
| E | 1000 | (kuralsiz) |  | calc:OutgoingExternalCustomerGLCode |  | C+A+WG | Payment |

### OutgoingPaymentFCY

| On | Order | Kurallar | THP | Target | THP adi | Cust/Acc | Not |
|---|---|---|---|---|---|---|---|
| E | 5 | PaymentInstructionType = B2B & SettlementType = Gross & OutgoingPaymentAccountingType = TemporaryAccount & OutgoingPaymentAccountingGLType = Linked Account | 39399 | 3939900011 | KATILIM FONU VE DİĞER YABANCI KAYNAKLAR > ALACAKLI GEÇİCİ HESAPLAR - Y.P. > DİĞER ALACAKLI GEÇİCİ HESAPLAR | C+A | Payment |
| E | 10 | PaymentInstructionType = B2B & SettlementType = Gross & OutgoingPaymentAccountingType = TemporaryAccount & OutgoingPaymentAccountingGLType = Ledger Account | 39399 | 3939900011 | KATILIM FONU VE DİĞER YABANCI KAYNAKLAR > ALACAKLI GEÇİCİ HESAPLAR - Y.P. > DİĞER ALACAKLI GEÇİCİ HESAPLAR |  | Payment |
| E | 15 | PaymentInstructionType = B2B & SettlementType = Gross & OutgoingPaymentAccountingType = Cash Account |  | calc:OutgoingCorrespondentAccountGLCode |  | C+A | Payment |
| E | 20 | PaymentInstructionType = B2B & SettlementType = Net & OutgoingPaymentAccountingGLType = Linked Account | 39399 | 3939900011 | KATILIM FONU VE DİĞER YABANCI KAYNAKLAR > ALACAKLI GEÇİCİ HESAPLAR - Y.P. > DİĞER ALACAKLI GEÇİCİ HESAPLAR | C+A | Payment |
| E | 25 | PaymentInstructionType = B2B & SettlementType = Net & OutgoingPaymentAccountingGLType = Ledger Account | 39399 | 3939900011 | KATILIM FONU VE DİĞER YABANCI KAYNAKLAR > ALACAKLI GEÇİCİ HESAPLAR - Y.P. > DİĞER ALACAKLI GEÇİCİ HESAPLAR |  | Payment |
| E | 30 | PaymentInstructionType = A2A & SettlementType = Gross & OutgoingPaymentAccountingType = TemporaryAccount & OutgoingPaymentAccountingGLType = Linked Account | 39399 | 3939900011 | KATILIM FONU VE DİĞER YABANCI KAYNAKLAR > ALACAKLI GEÇİCİ HESAPLAR - Y.P. > DİĞER ALACAKLI GEÇİCİ HESAPLAR | C+A | Payment |
| E | 35 | PaymentInstructionType = A2A & SettlementType = Gross & OutgoingPaymentAccountingType = TemporaryAccount & OutgoingPaymentAccountingGLType = Ledger Account | 39399 | 3939900011 | KATILIM FONU VE DİĞER YABANCI KAYNAKLAR > ALACAKLI GEÇİCİ HESAPLAR - Y.P. > DİĞER ALACAKLI GEÇİCİ HESAPLAR |  | Payment |
| E | 41 | PaymentInstructionType = A2A & SettlementType = Gross |  | calc:OutgoingCorrespondentAccountGLCode |  | C+A | Payment |
| E | 45 | PaymentInstructionType = A2A & SettlementType = Net & OutgoingPaymentAccountingGLType = Linked Account | 39399 | 3939900011 | KATILIM FONU VE DİĞER YABANCI KAYNAKLAR > ALACAKLI GEÇİCİ HESAPLAR - Y.P. > DİĞER ALACAKLI GEÇİCİ HESAPLAR | C+A | Payment |
| E | 50 | PaymentInstructionType = A2A & SettlementType = Net & OutgoingPaymentAccountingGLType = Ledger Account | 39399 | 3939900011 | KATILIM FONU VE DİĞER YABANCI KAYNAKLAR > ALACAKLI GEÇİCİ HESAPLAR - Y.P. > DİĞER ALACAKLI GEÇİCİ HESAPLAR |  | Payment |
| E | 55 | PaymentInstructionType = V2V & SettlementType = Gross & OutgoingPaymentAccountingType = TemporaryAccount & OutgoingPaymentAccountingGLType = Linked Account | 39399 | 3939900011 | KATILIM FONU VE DİĞER YABANCI KAYNAKLAR > ALACAKLI GEÇİCİ HESAPLAR - Y.P. > DİĞER ALACAKLI GEÇİCİ HESAPLAR | C+A | Payment |
| E | 60 | PaymentInstructionType = V2V & SettlementType = Gross & OutgoingPaymentAccountingType = TemporaryAccount & OutgoingPaymentAccountingGLType = Ledger Account | 39399 | 3939900011 | KATILIM FONU VE DİĞER YABANCI KAYNAKLAR > ALACAKLI GEÇİCİ HESAPLAR - Y.P. > DİĞER ALACAKLI GEÇİCİ HESAPLAR |  | Payment |
| E | 65 | PaymentInstructionType = V2V & SettlementType = Gross |  | calc:TheirBeneficiaryCorrespondentGLCode |  | C+A | Payment |
| E | 70 | PaymentInstructionType = V2V & SettlementType = Net & OutgoingPaymentAccountingGLType = Linked Account | 39399 | 3939900011 | KATILIM FONU VE DİĞER YABANCI KAYNAKLAR > ALACAKLI GEÇİCİ HESAPLAR - Y.P. > DİĞER ALACAKLI GEÇİCİ HESAPLAR | C+A | Payment |
| E | 75 | PaymentInstructionType = V2V & SettlementType = Net & OutgoingPaymentAccountingGLType = Ledger Account | 39399 | 3939900011 | KATILIM FONU VE DİĞER YABANCI KAYNAKLAR > ALACAKLI GEÇİCİ HESAPLAR - Y.P. > DİĞER ALACAKLI GEÇİCİ HESAPLAR |  | Payment |
| E | 1000 | (kuralsiz) |  | calc:OutgoingExternalCustomerGLCode |  | C+A+WG | Payment |

### IncomingPaymentLCY

| On | Order | Kurallar | THP | Target | THP adi | Cust/Acc | Not |
|---|---|---|---|---|---|---|---|
| E | 5 | PaymentInstructionType = B2B & SettlementType = Gross & IncomingPaymentAccountingType = Temporary Account & IncomingPaymentAccountingGLType = Linked Account | 28099 | 2809900011 | YATIRIM AMAÇLI DEĞERLER VE DİĞER AKTİFLER > BORÇLU GEÇİCİ HESAPLAR - T.P. > DİĞER BORÇLU GEÇİCİ HESAPLAR | C+A | Payment |
| E | 10 | PaymentInstructionType = B2B & SettlementType = Gross & IncomingPaymentAccountingType = Temporary Account & IncomingPaymentAccountingGLType = Ledger Account | 28099 | 2809900011 | YATIRIM AMAÇLI DEĞERLER VE DİĞER AKTİFLER > BORÇLU GEÇİCİ HESAPLAR - T.P. > DİĞER BORÇLU GEÇİCİ HESAPLAR |  | Payment |
| E | 15 | PaymentInstructionType = B2B & SettlementType = Gross & IncomingPaymentAccountingType = Cash Account |  | calc:IncomingCorrespondentAccountGLCode |  | C+A | Payment |
| E | 20 | PaymentInstructionType = B2B & SettlementType = Net & IncomingPaymentAccountingGLType = Linked Account | 28099 | 2809900011 | YATIRIM AMAÇLI DEĞERLER VE DİĞER AKTİFLER > BORÇLU GEÇİCİ HESAPLAR - T.P. > DİĞER BORÇLU GEÇİCİ HESAPLAR | C+A | Payment |
| E | 25 | PaymentInstructionType = B2B & SettlementType = Net & IncomingPaymentAccountingGLType = Ledger Account | 28099 | 2809900011 | YATIRIM AMAÇLI DEĞERLER VE DİĞER AKTİFLER > BORÇLU GEÇİCİ HESAPLAR - T.P. > DİĞER BORÇLU GEÇİCİ HESAPLAR |  | Payment |
| E | 30 | PaymentInstructionType = A2A & SettlementType = Gross & IncomingPaymentAccountingType = Temporary Account & IncomingPaymentAccountingGLType = Linked Account | 28099 | 2809900011 | YATIRIM AMAÇLI DEĞERLER VE DİĞER AKTİFLER > BORÇLU GEÇİCİ HESAPLAR - T.P. > DİĞER BORÇLU GEÇİCİ HESAPLAR | C+A | Payment |
| E | 35 | PaymentInstructionType = A2A & SettlementType = Gross & IncomingPaymentAccountingType = Temporary Account & IncomingPaymentAccountingGLType = Ledger Account | 28099 | 2809900011 | YATIRIM AMAÇLI DEĞERLER VE DİĞER AKTİFLER > BORÇLU GEÇİCİ HESAPLAR - T.P. > DİĞER BORÇLU GEÇİCİ HESAPLAR |  | Payment |
| E | 40 | PaymentInstructionType = A2A & SettlementType = Gross |  | calc:IncomingCorrespondentAccountGLCode |  | C+A | Payment |
| E | 45 | PaymentInstructionType = A2A & SettlementType = Net & IncomingPaymentAccountingGLType = Linked Account | 28099 | 2809900011 | YATIRIM AMAÇLI DEĞERLER VE DİĞER AKTİFLER > BORÇLU GEÇİCİ HESAPLAR - T.P. > DİĞER BORÇLU GEÇİCİ HESAPLAR | C+A | Payment |
| E | 50 | PaymentInstructionType = A2A & SettlementType = Net & IncomingPaymentAccountingGLType = Ledger Account | 28099 | 2809900011 | YATIRIM AMAÇLI DEĞERLER VE DİĞER AKTİFLER > BORÇLU GEÇİCİ HESAPLAR - T.P. > DİĞER BORÇLU GEÇİCİ HESAPLAR |  | Payment |
| E | 55 | PaymentInstructionType = V2V & SettlementType = Gross & IncomingPaymentAccountingType = Temporary Account & IncomingPaymentAccountingGLType = Linked Account | 28099 | 2809900011 | YATIRIM AMAÇLI DEĞERLER VE DİĞER AKTİFLER > BORÇLU GEÇİCİ HESAPLAR - T.P. > DİĞER BORÇLU GEÇİCİ HESAPLAR | C+A | Payment |
| E | 60 | PaymentInstructionType = V2V & SettlementType = Gross & IncomingPaymentAccountingType = Temporary Account & IncomingPaymentAccountingGLType = Ledger Account | 28099 | 2809900011 | YATIRIM AMAÇLI DEĞERLER VE DİĞER AKTİFLER > BORÇLU GEÇİCİ HESAPLAR - T.P. > DİĞER BORÇLU GEÇİCİ HESAPLAR |  | Payment |
| E | 65 | PaymentInstructionType = V2V & SettlementType = Gross |  | calc:TheirSenderCorrespondentGLCode |  | C+A | Payment |
| E | 70 | PaymentInstructionType = V2V & SettlementType = Net & IncomingPaymentAccountingGLType = Linked Account | 28099 | 2809900011 | YATIRIM AMAÇLI DEĞERLER VE DİĞER AKTİFLER > BORÇLU GEÇİCİ HESAPLAR - T.P. > DİĞER BORÇLU GEÇİCİ HESAPLAR | C+A | Payment |
| E | 75 | PaymentInstructionType = V2V & SettlementType = Net & IncomingPaymentAccountingGLType = Ledger Account | 28099 | 2809900011 | YATIRIM AMAÇLI DEĞERLER VE DİĞER AKTİFLER > BORÇLU GEÇİCİ HESAPLAR - T.P. > DİĞER BORÇLU GEÇİCİ HESAPLAR |  | Payment |
| E | 1000 | (kuralsiz) |  | calc:IncomingExternalCustomerGLCode |  | C+A+WG | Payment |

### IncomingPaymentFCY

| On | Order | Kurallar | THP | Target | THP adi | Cust/Acc | Not |
|---|---|---|---|---|---|---|---|
| E | 5 | PaymentInstructionType = B2B & SettlementType = Gross & IncomingPaymentAccountingType = Temporary Account & IncomingPaymentAccountingGLType = Linked Account | 28199 | 2819900011 | YATIRIM AMAÇLI DEĞERLER VE DİĞER AKTİFLER > BORÇLU GEÇİCİ HESAPLAR - Y.P. > DİĞER BORÇLU GEÇİCİ HESAPLAR | C+A | Payment |
| E | 10 | PaymentInstructionType = B2B & SettlementType = Gross & IncomingPaymentAccountingType = Temporary Account & IncomingPaymentAccountingGLType = Ledger Account | 28199 | 2819900011 | YATIRIM AMAÇLI DEĞERLER VE DİĞER AKTİFLER > BORÇLU GEÇİCİ HESAPLAR - Y.P. > DİĞER BORÇLU GEÇİCİ HESAPLAR |  | Payment |
| E | 15 | PaymentInstructionType = B2B & SettlementType = Gross & IncomingPaymentAccountingType = Cash Account |  | calc:IncomingCorrespondentAccountGLCode |  | C+A | Payment |
| E | 20 | PaymentInstructionType = B2B & SettlementType = Net & IncomingPaymentAccountingGLType = Linked Account | 28199 | 2819900011 | YATIRIM AMAÇLI DEĞERLER VE DİĞER AKTİFLER > BORÇLU GEÇİCİ HESAPLAR - Y.P. > DİĞER BORÇLU GEÇİCİ HESAPLAR | C+A | Payment |
| E | 25 | PaymentInstructionType = B2B & SettlementType = Net & IncomingPaymentAccountingGLType = Ledger Account | 28199 | 2819900011 | YATIRIM AMAÇLI DEĞERLER VE DİĞER AKTİFLER > BORÇLU GEÇİCİ HESAPLAR - Y.P. > DİĞER BORÇLU GEÇİCİ HESAPLAR |  | Payment |
| E | 30 | PaymentInstructionType = A2A & SettlementType = Gross & IncomingPaymentAccountingType = Temporary Account & IncomingPaymentAccountingGLType = Linked Account | 28199 | 2819900011 | YATIRIM AMAÇLI DEĞERLER VE DİĞER AKTİFLER > BORÇLU GEÇİCİ HESAPLAR - Y.P. > DİĞER BORÇLU GEÇİCİ HESAPLAR | C+A | Payment |
| E | 35 | PaymentInstructionType = A2A & SettlementType = Gross & IncomingPaymentAccountingType = Temporary Account & IncomingPaymentAccountingGLType = Ledger Account | 28199 | 2819900011 | YATIRIM AMAÇLI DEĞERLER VE DİĞER AKTİFLER > BORÇLU GEÇİCİ HESAPLAR - Y.P. > DİĞER BORÇLU GEÇİCİ HESAPLAR |  | Payment |
| E | 40 | PaymentInstructionType = A2A & SettlementType = Gross |  | calc:IncomingCorrespondentAccountGLCode |  | C+A | Payment |
| E | 45 | PaymentInstructionType = A2A & SettlementType = Net & IncomingPaymentAccountingGLType = Linked Account | 28199 | 2819900011 | YATIRIM AMAÇLI DEĞERLER VE DİĞER AKTİFLER > BORÇLU GEÇİCİ HESAPLAR - Y.P. > DİĞER BORÇLU GEÇİCİ HESAPLAR | C+A | Payment |
| E | 50 | PaymentInstructionType = A2A & SettlementType = Net & IncomingPaymentAccountingGLType = Ledger Account | 28199 | 2819900011 | YATIRIM AMAÇLI DEĞERLER VE DİĞER AKTİFLER > BORÇLU GEÇİCİ HESAPLAR - Y.P. > DİĞER BORÇLU GEÇİCİ HESAPLAR |  | Payment |
| E | 55 | PaymentInstructionType = V2V & SettlementType = Gross & IncomingPaymentAccountingType = Temporary Account & IncomingPaymentAccountingGLType = Linked Account | 28199 | 2819900011 | YATIRIM AMAÇLI DEĞERLER VE DİĞER AKTİFLER > BORÇLU GEÇİCİ HESAPLAR - Y.P. > DİĞER BORÇLU GEÇİCİ HESAPLAR | C+A | Payment |
| E | 60 | PaymentInstructionType = V2V & SettlementType = Gross & IncomingPaymentAccountingType = Temporary Account & IncomingPaymentAccountingGLType = Ledger Account | 28199 | 2819900011 | YATIRIM AMAÇLI DEĞERLER VE DİĞER AKTİFLER > BORÇLU GEÇİCİ HESAPLAR - Y.P. > DİĞER BORÇLU GEÇİCİ HESAPLAR |  | Payment |
| E | 65 | PaymentInstructionType = V2V & SettlementType = Gross |  | calc:TheirSenderCorrespondentGLCode |  | C+A | Payment |
| E | 70 | PaymentInstructionType = V2V & SettlementType = Net & IncomingPaymentAccountingGLType = Linked Account | 28199 | 2819900011 | YATIRIM AMAÇLI DEĞERLER VE DİĞER AKTİFLER > BORÇLU GEÇİCİ HESAPLAR - Y.P. > DİĞER BORÇLU GEÇİCİ HESAPLAR | C+A | Payment |
| E | 75 | PaymentInstructionType = V2V & SettlementType = Net & IncomingPaymentAccountingGLType = Ledger Account | 28199 | 2819900011 | YATIRIM AMAÇLI DEĞERLER VE DİĞER AKTİFLER > BORÇLU GEÇİCİ HESAPLAR - Y.P. > DİĞER BORÇLU GEÇİCİ HESAPLAR |  | Payment |
| E | 1000 | (kuralsiz) |  | calc:IncomingExternalCustomerGLCode |  | C+A+WG | Payment |
