# SQL Çıktıları — collateral-db-tablo-id-stratejisi

## #1 — DefNumberGen kolon şeması
Üç DB'de de **birebir aynı**: `Definition nvarchar` · `EntityColumnType int` · `LastNumber int` · `LastUpdateDate datetime`.
(`Id` kolonu **yok** — PK `EntityColumnType`.)

## #2 — DefNumberGen içeriği
```
Db|Ect|Definition|LastNumber|LastUpdateDate
DERIVSWP|1|Txn_Id|171|2026-09-17 17:18:23.750
DERIVSWP|2|AccEntryMain_Id|1184|2026-10-06 21:00:29.657
DERIVSWP|3|AccEntry_Id|2908|2026-10-06 21:00:29.653
DERIVSWP|4|accEngineGeneratedAccountRule_Id|2360|2026-10-06 21:00:29.657
MM|1|Txn Mm Id|3416|2026-10-07 11:52:42.290
MM|2|Acc Entry Main Id|6154|2026-10-05 14:32:56.170
MM|3|Account Entry|12720|2026-10-05 14:32:56.173
MM|4|Generated Account|8190|2026-10-05 14:32:56.173
MM|5|Product Definition Id|999|2025-03-23 17:46:00.133
MM|6|Product Definition Market Map Id|1032|2025-12-17 14:41:13.653
MM|7|Txn Tawarruq Id|1052|2026-09-24 14:13:41.467
MM|8|Txn Loan Id|1168|2026-09-15 17:38:46.097
OPTFX|1|Txn_Id|129|2026-09-28 11:11:31.577
OPTFX|2|AccEntryMain_Id|137|2026-09-30 16:03:15.780
OPTFX|3|AccEntry_Id|807|2026-09-30 16:03:15.790
OPTFX|4|AccEngineGeneratedAccountRule_Id|659|2026-09-30 16:03:15.800
```

## #3 — BAŞARISIZ (Msg 130)

## #4 — Tablo / IDENTITY özeti
```
Db|Tablolar|IdentityVar|IdentityYok|DboDisi(Hangfire)
DERIVSWP|78|27|51|11
MM|125|45|80|11
OPTFX|53|17|36|11
```

## #5 — Tam pivot tablo listesi
(Çıktı 133 satır — rapora işlendi. Biçim: `I:<satır>`=IDENTITY, `N:<satır>`=IDENTITY yok, `.`=tablo yok.
Tam ham çıktı sohbet transkriptinde; özet rapor çağırana iletildi.)

## #6 — MM IDENTITY olmayan 74 dbo tablosu (Id tipi | PK)
Özet: `Id` kolonu **olup IDENTITY olmayan** tablolar = sayaçtan beslenenler (`TxnMM`/`TxnLoan`/`TxnTawarruq`
bigint, `AccEntry*`/`AccEngineGeneratedAccountRule` int, `PrdProductDefinition*` int) + referans/kopya
tablolar (`Calendar`, `Holiday`, `FXRate*`, `InterestRate*`, `Chart`, `Point`, `PrfPortfolio`, `CusCustomer` …).
`Id` kolonu **hiç olmayanlar**: `Currency`(PK Code), `CurrencyPair`, `CusAccount`, `CusSIC`, `DefAccrual`,
`DefAmortization`, `DefBitMask`, `DefCountry`, `DefDateBasis`, `DefNumberGen`, `DefRefNumGen`, `DefTaxOffice`,
`DefTxnType`, `Market`, `PrdProductTxn`, `PrdSubType`, `PrfInstrument`, `TxnTax`, `UsrUserFavoritesMenu`,
`MDL_*`. PK'sız: `AccEftAccount`, `AccEntryType`, `CusCustomer`, `MDL_*`.
(Ham çıktı transkriptte.)

## #7 — OPTFX / DSWP ana tablolarda `Id.is_identity`
```
DSWP|AccEngineGeneratedAccountRule|int|0   DSWP|AccEntry|int|0   DSWP|AccEntryMain|int|0
DSWP|TxnTransaction|bigint|0   DSWP|TxnTransactionHistory|bigint|0
DSWP|ProductDefinition|int|1   DSWP|TxnCashFlow|bigint|1  DSWP|TxnDocument|int|1
DSWP|TxnNote|int|1  DSWP|TxnSync|bigint|1  DSWP|DerivativesRevaluation|bigint|1
OPTFX|AccEngineGeneratedAccountRule|int|0  OPTFX|AccEntry|int|0  OPTFX|AccEntryMain|int|0
OPTFX|TxnTransaction|bigint|0  OPTFX|TxnTransactionHistory|bigint|0
OPTFX|ProductDefinition|int|0  OPTFX|VolatilityRate|bigint|0
OPTFX|TxnDocument|bigint|1  OPTFX|TxnNote|bigint|1  OPTFX|TxnSync|bigint|1  OPTFX|OptionsFXRevaluation|bigint|1
```

## #8 — History tablolarında IDENTITY kolonu = `HistoryId` (hepsinde, 3 DB)
MM'de ayrıca `Id` IDENTITY olanlar: `BatchLog`, `BatchLogDetail`, `TxnCashFlow`, `TxnDocument`,
`TxnMmDailyCalculation`, `TxnMMDetail`, `TxnNote`, `TxnSync`.

## #9 / #10 — `sys.databases` listesi `NetTrexAcc_*` ve `NetTrexCommon_*` kopyalarıyla doldu (TOP 50 kesildi)

## #11 — `%Collateral%` DB sayısı = **0** (henüz yok)
