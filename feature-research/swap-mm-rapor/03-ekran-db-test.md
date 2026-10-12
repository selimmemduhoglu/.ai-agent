# Valör-Vade Raporu — ekran ↔ DB tutarlılık testi (2026-10-01)

Ekranın veri kaynağı (Common.UI Load → modül ucu) ile NetTrexMM / NetTrexFX SELECT sonuçları karşılaştırıldı. SQL ve çıktılar: `sql-log/swap-mm-rapor` #50–#132. Mantıksal tarih: MM 01.10.2026, FX 02.10.2026 (Redis cache).

Karşılaştırılan: kayıt/paket sayısı, totalCount, toplam tutar/getiri, satır bazında tüm kolonlar (Id veya grup anahtarı ile), filtre sınırları, sıralama, vadeye kalan ≥ 0, swap oranı/getiri/kar-zarar formülü, referans listesi.

## Money Market (TxnMM)

| # | Senaryo | Filtre | Ekran (API) | DB | Sonuç |
|---|---|---|---|---|---|
| 50 | Ekran varsayılanı (bu ay) | valör 2026-10-01–2026-10-31 | 0 | 0 | ✅ |
| 51 | Eylül 2026 valör | valör 2026-09-01–2026-09-30 | 21 | 21 | ✅ |
| 52 | Yalnız valör başlangıç | valör 2026-09-15–… | 17 | 17 | ✅ |
| 53 | Yalnız valör bitiş | valör …–2025-09-30 | 2 | 2 | ✅ |
| 54 | Tek gün valör (iki uç dahil) | valör 2026-09-18–2026-09-18 | 8 | 8 | ✅ |
| 55 | Ay sonu sınırı (30.09 dahil) | valör 2026-09-30–2026-09-30 | 4 | 4 | ✅ |
| 56 | Vade aralığı Eylül 2026 | vade 2026-09-01–2026-09-30 | 18 | 18 | ✅ |
| 57 | Yalnız vade başlangıç | vade 2026-11-01–… | 9 | 9 | ✅ |
| 58 | Yalnız vade bitiş | vade …–2025-10-31 | 90 | 90 | ✅ |
| 59 | Valör + vade birlikte | valör 2026-09-01–2026-09-30, vade 2026-11-01–2026-12-31 | 5 | 5 | ✅ |
| 60 | Tüm aralık, tüm alt ürünler | valör 2020-01-01–2030-12-31, vade 2020-01-01–2035-12-31 | 356 | 356 | ✅ |
| 61 | Alt ürün: Money Market | valör 2025-01-01–…, alt ürün [MoneyMarket] | 288 | 288 | ✅ |
| 62 | Alt ürün: Murabaha | valör 2020-01-01–…, alt ürün [Murabaha] | 50 | 50 | ✅ |
| 63 | Alt ürün: Wakale + Loan | valör 2020-01-01–…, alt ürün [Wakale,Loan] | 18 | 18 | ✅ |
| 64 | Alt ürün: veri olmayan (Bond Issue) | valör 2020-01-01–…, alt ürün [Issue] | 0 | 0 | ✅ |
| 65 | Alt ürün: pasif ürün (TermDeposit) | valör 2020-01-01–…, alt ürün [TermDeposit] | 0 | 0 | ✅ |
| 66 | Yalnız referans (tarih yok) | ref 'TMMPLC2609' | 12 | 12 | ✅ |
| 67 | Referans + tarih | valör 2026-09-01–2026-09-30, ref 'BRW' | 9 | 9 | ✅ |
| 68 | Tam referans | ref 'TMMBRW2609110002' | 1 | 1 | ✅ |
| 69 | Olmayan referans | ref 'YOKBOYLEREF' | 0 | 0 | ✅ |

## Interbank Loan (TxnLoan)

| # | Senaryo | Filtre | Ekran (API) | DB | Sonuç |
|---|---|---|---|---|---|
| 70 | Ekran varsayılanı (bu ay) | valör 2026-10-01–2026-10-31 | 0 | 0 | ✅ |
| 71 | Nisan 2026 valör | valör 2026-04-01–2026-04-30 | 19 | 19 | ✅ |
| 72 | Mayıs 2026 valör | valör 2026-05-01–2026-05-31 | 11 | 11 | ✅ |
| 73 | Haziran 2026 valör | valör 2026-06-01–2026-06-30 | 17 | 17 | ✅ |
| 74 | Yalnız valör başlangıç | valör 2026-06-15–… | 11 | 11 | ✅ |
| 75 | Yalnız valör bitiş | valör …–2026-05-15 | 27 | 27 | ✅ |
| 76 | Tek gün valör (12.06 iki uç dahil) | valör 2026-06-12–2026-06-12 | 4 | 4 | ✅ |
| 77 | Vade aralığı H2 2026 | vade 2026-07-01–2026-12-31 | 23 | 23 | ✅ |
| 78 | Yalnız vade başlangıç (2027+) | vade 2027-01-01–… | 5 | 5 | ✅ |
| 79 | Yalnız vade bitiş | vade …–2026-06-30 | 21 | 21 | ✅ |
| 80 | Tek gün vade (15.06) | vade 2026-06-15–2026-06-15 | 4 | 4 | ✅ |
| 81 | Valör + vade birlikte | valör 2026-06-01–2026-06-30, vade 2026-09-01–2026-10-31 | 5 | 5 | ✅ |
| 82 | Tüm aralık, tüm alt ürünler | valör 2020-01-01–2030-12-31 | 49 | 49 | ✅ |
| 83 | Alt ürün: Interbank Loan | valör 2020-01-01–…, alt ürün [Loan] | 49 | 49 | ✅ |
| 84 | Alt ürün: Money Market (IL'de yok) | valör 2020-01-01–…, alt ürün [MoneyMarket] | 0 | 0 | ✅ |
| 85 | Alt ürün: Loan + Murabaha | valör 2026-06-01–2026-06-30, alt ürün [Loan,Murabaha] | 17 | 17 | ✅ |
| 86 | Yalnız referans (tarih yok) | ref 'TLNPLC' | 21 | 21 | ✅ |
| 87 | Referans + tarih | valör 2026-06-01–2026-06-30, ref 'BRW' | 11 | 11 | ✅ |
| 88 | Tam referans (faiz oranı boş kayıt) | ref 'TLNBRW2606200001' | 1 | 1 | ✅ |
| 89 | Tam referans (faiz oranı 0 kayıt) | ref 'TLNBRW2606120006' | 1 | 1 | ✅ |

## FX Swap (TxnFXSwap)

| # | Senaryo | Filtre | Ekran (API) | DB | Sonuç |
|---|---|---|---|---|---|
| 90 | Ekran varsayılanı (bu ay) | valör 2026-10-01–2026-10-31 | 2 satır / 3 işlem | 2 satır / 3 işlem | ✅ (sqlcmd Ş görüntüleme; #112 DB değeri Ş) |
| 91 | Yalnız valör başlangıç | valör 2026-10-01–… | 2 satır / 3 işlem | 2 satır / 3 işlem | ✅ |
| 92 | Yalnız valör bitiş (öncesi) | valör …–2026-09-30 | 0 satır / 0 işlem | 0 satır / 0 işlem | ✅ |
| 93 | Tek gün valör 01.10 | valör 2026-10-01–2026-10-01 | 2 satır / 3 işlem | 2 satır / 3 işlem | ✅ |
| 94 | Valör 02.10 sonrası | valör 2026-10-02–… | 0 satır / 0 işlem | 0 satır / 0 işlem | ✅ |
| 95 | Vade aralığı Ekim | vade 2026-10-01–2026-10-31 | 2 satır / 3 işlem | 2 satır / 3 işlem | ✅ |
| 96 | Yalnız vade başlangıç 03.10 | vade 2026-10-03–… | 1 satır / 1 işlem | 1 satır / 1 işlem | ✅ |
| 97 | Yalnız vade bitiş 02.10 | vade …–2026-10-02 | 1 satır / 2 işlem | 1 satır / 2 işlem | ✅ |
| 98 | Tek gün vade 07.10 | vade 2026-10-07–2026-10-07 | 1 satır / 1 işlem | 1 satır / 1 işlem | ✅ |
| 99 | Tek gün vade 13.10 (silinmiş paket) | vade 2026-10-13–2026-10-13 | 0 satır / 0 işlem | 0 satır / 0 işlem | ✅ |
| 100 | Valör + vade birlikte | valör 2026-10-01–2026-10-01, vade 2026-10-02–2026-10-02 | 1 satır / 2 işlem | 1 satır / 2 işlem | ✅ |
| 101 | Geniş aralık | valör 2020-01-01–2030-12-31, vade 2020-01-01–2030-12-31 | 2 satır / 3 işlem | 2 satır / 3 işlem | ✅ |
| 102 | Yalnız referans önek | ref 'TFXSW261001' | 2 satır / 3 işlem | 2 satır / 3 işlem | ✅ |
| 103 | Tam referans (near bacak) | ref 'TFXSW26100100011' | 1 satır / 1 işlem | 1 satır / 1 işlem | ✅ |
| 104 | Tam referans (far bacak) | ref 'TFXSW26100100010' | 1 satır / 1 işlem | 1 satır / 1 işlem | ✅ |
| 105 | Referans + tarih | valör 2026-10-01–2026-10-31, ref 'TFXSW26100100013' | 1 satır / 1 işlem | 1 satır / 1 işlem | ✅ |
| 106 | Olmayan referans | ref 'YOKBOYLEREF' | 0 satır / 0 işlem | 0 satır / 0 işlem | ✅ |
| 107 | Input (16) paketin referansı | ref 'TFXSW26100100005' | 0 satır / 0 işlem | 0 satır / 0 işlem | ✅ |
| 108 | DeleteVerified (22) paketin referansı | ref 'TFXSW26100100007' | 0 satır / 0 işlem | 0 satır / 0 işlem | ✅ |
| 109 | FX + PM birlikte seçili (FX satırları) | valör 2026-10-01–2026-10-31, alt ürün [FxSwap,PmSwap] | 2+1 satır (bu tür + diğer) | 2 satır / 3 işlem | ✅ |

## PM Swap (TxnPMSwap)

| # | Senaryo | Filtre | Ekran (API) | DB | Sonuç |
|---|---|---|---|---|---|
| 113 | Ekran varsayılanı (bu ay) | valör 2026-10-01–2026-10-31 | 1 satır / 4 işlem | 1 satır / 4 işlem | ✅ (sqlcmd Ş görüntüleme; #112 DB değeri Ş) |
| 114 | Yalnız valör başlangıç | valör 2026-10-01–… | 1 satır / 4 işlem | 1 satır / 4 işlem | ✅ |
| 115 | Yalnız valör bitiş (öncesi) | valör …–2026-09-30 | 0 satır / 0 işlem | 0 satır / 0 işlem | ✅ |
| 116 | Tek gün valör 01.10 | valör 2026-10-01–2026-10-01 | 1 satır / 4 işlem | 1 satır / 4 işlem | ✅ |
| 117 | Valör 02.10 sonrası | valör 2026-10-02–… | 0 satır / 0 işlem | 0 satır / 0 işlem | ✅ |
| 118 | Vade aralığı Ekim | vade 2026-10-01–2026-10-31 | 1 satır / 4 işlem | 1 satır / 4 işlem | ✅ |
| 119 | Yalnız vade başlangıç 03.10 | vade 2026-10-03–… | 0 satır / 0 işlem | 0 satır / 0 işlem | ✅ |
| 120 | Yalnız vade bitiş 02.10 | vade …–2026-10-02 | 1 satır / 4 işlem | 1 satır / 4 işlem | ✅ |
| 121 | Tek gün vade 02.10 | vade 2026-10-02–2026-10-02 | 1 satır / 4 işlem | 1 satır / 4 işlem | ✅ |
| 122 | Valör + vade birlikte | valör 2026-10-01–2026-10-01, vade 2026-10-02–2026-10-02 | 1 satır / 4 işlem | 1 satır / 4 işlem | ✅ |
| 123 | Geniş aralık | valör 2020-01-01–2030-12-31, vade 2020-01-01–2030-12-31 | 1 satır / 4 işlem | 1 satır / 4 işlem | ✅ |
| 124 | Yalnız referans önek | ref 'TPMSW261001' | 1 satır / 4 işlem | 1 satır / 4 işlem | ✅ |
| 125 | Tam referans (near, 423 ons paket) | ref 'TPMSW26100100003' | 1 satır / 1 işlem | 1 satır / 1 işlem | ✅ |
| 126 | Tam referans (far bacak) | ref 'TPMSW26100100008' | 1 satır / 1 işlem | 1 satır / 1 işlem | ✅ |
| 127 | Referans + tarih | valör 2026-10-01–2026-10-31, ref 'TPMSW26100100013' | 1 satır / 1 işlem | 1 satır / 1 işlem | ✅ |
| 128 | Olmayan referans | ref 'YOKBOYLEREF' | 0 satır / 0 işlem | 0 satır / 0 işlem | ✅ |
| 129 | Input (16) paketin referansı | ref 'TPMSW26100100009' | 0 satır / 0 işlem | 0 satır / 0 işlem | ✅ |
| 130 | DeleteVerified (22) XAU/USD | ref 'TPMSW26100100005' | 0 satır / 0 işlem | 0 satır / 0 işlem | ✅ |
| 131 | DeleteVerified (22) XAU/TRY | ref 'TPMSW26100100001' | 0 satır / 0 işlem | 0 satır / 0 işlem | ✅ |
| 132 | FX + PM birlikte seçili (PM satırları) | valör 2026-10-01–2026-10-31, alt ürün [FxSwap,PmSwap] | 1+2 satır (bu tür + diğer) | 1 satır / 4 işlem | ✅ |

## Bulgular

| # | Önem | Bulgu | Kanıt |
|---|---|---|---|
| T2 | ORTA (ortam) | Redis `Netix.FrameworkParameterDefinition` içinde `Trex:FxLogicalDate` = 02.10.2026, DB `FrameworkParameter` = 01.10.2026. FX "Vadeye Kalan" 1 gün eksik (07.10 → 5 gün) | #29, redis-cli hget (salt okunur) |

## Bug değil

- IL'de başlık faizi NULL/0 olan kredide Getiri Oranı = TxnCashFlow ilk faiz dönemi Rate (TLNBRW2606200001: %0,5392). Ekran DB ile birebir; kullanıcı kararı (2026-10-01): DB ile aynıysa doğru, test verisi.
- Swap oranlarındaki uç değerler (PM 1 günlük %372, FX 1 günlük %136) test verisinden; formül ve sonuç DB ile birebir.

- MM ürününde TMRBRW (Murabaha), TWABRW (Wakale), TLNBRW (TxnMM Loan) satırları: alt ürün listesinde enabled oldukları için geliyor.
- IL'de "bu ay" (Ekim) 0 kayıt: aktif TxnLoan valörleri 2026-04 … 2026-09.
- Input (16) ve DeleteVerified (22) swap paketleri referansla aransa da gelmiyor: Active Records filtresi doğru.
- Aktif kayıtların tamamı StateId 18 — MM container'ı eski (VerifiedStatesId) ya da yeni (ActiveRecords) kodla çalışsa da sonuç aynı.
