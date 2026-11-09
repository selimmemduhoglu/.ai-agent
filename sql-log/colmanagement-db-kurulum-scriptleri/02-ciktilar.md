# 02-ciktilar.md — colmanagement-db-kurulum-scriptleri

Tum 4 sorgu da **basarisiz** — sunucuya baglanilamadi:

```
Sqlcmd: Error: Microsoft ODBC Driver 17 for SQL Server : TCP Provider: The wait operation timed out.
Sqlcmd: Error: Microsoft ODBC Driver 17 for SQL Server : Login timeout expired.
Sqlcmd: Error: ... Server is not found or not accessible ...
```

`192.168.10.211,1433` bu makineden su an erisilemiyor (VPN/ag kapali olabilir). Dort soru da
**dogrulanmadi** — kullanim rehberinde (`00-OKU-BENI.md`) ve `0-DOGRULAMA-NetTrexCommon.sql`
icinde kullaniciya birakildi:

1. FrameworkMenu root/parent deseni (MM/OptionsFX hangi MenuKey altinda duruyor)
2. `General:AvailableModules` guncel degeri
3. `sp_GetNewNumbers`/`sp_GetNewRefNumber` NetTrexMM'de var mi (TrexFramework'ten mi geliyor)
4. NetTrexOPTFX `PrdInstrument` kolon tipleri (ColManagement'teki ayni-adli kopya tablonun
   belirsiz kalan 11 kolonu icin)

---

## 2026-10-15 ikinci tur — BASARILI (parola MM'in docker-compose.override.yml'inden alindi,
sunucu/login paylasimli: `trusr`/`Ph4+Gnr2ut`, 192.168.10.211)

**Q5** (NetTrexAcc.AccEntryMain TOP 20 TxnId/Id): basarili, 20 satir dondu, en yuksek Id ~6.667.361,
TxnId'ler 664-666bin bandinda (o anin en guncel yazimlari).

**Q5b** (TxnId ilk-2-hane dagilimi, agrege): 12 farkli "prefix" bucket'i bulundu:
`11,12,14,22,33,44,50,55,66,77,88,99`. "12" aslinda 120 (3 haneli, MM Loan).

**Q5c/Q5d/Q5e** (ProductCode kirilim): prefix'lerin gercek sahibi netlesti:

| Prefix | ProductCode | Modul |
|---|---|---|
| 11 | FX | NetTrex.Fx (TransactionFx_Id) |
| 22 | SWAPFX | NetTrex.Fx (TransactionSwap_Id) |
| 33 | PM | NetTrex.Fx (TransactionPm_Id) |
| 44 | SWAPPM | NetTrex.Fx (TransactionPmSwap_Id) |
| 50 | TWR | NetTrex.MM Tawarruq |
| 55 | MM | NetTrex.MM (ana) |
| 66 | FI | **tespit edilmedi repo** (Fixed Income, PROJECT_CONTEXT'te de "repo yok" yaziyor) |
| 🔴 77 | IFN | **NetTrex.InvFund** — ColManagement'in o ana kadar kullandigi ModulePrefix=77 ile CAKISIYOR |
| 88 | IRS/CCS | NetTrex.DerivSwp |
| 99 | OPT | NetTrex.OptionsFX |
| 120 | MM | NetTrex.MM InterbankLoan |

**Sonuc:** ColManagement'in `ModulePrefix` sabiti **77'den 60'a** cekildi (60 hicbir yerde yok).
Kod: `Data/NetTrex.ColManagement.Data/Managers/Generators/NumberGeneratorDataManager.cs`.

**Q6** (NetTrexMM sys.procedures): 9 SP bulundu — `GenerateInsert`, `sp_GetNewNumbers`,
`sp_GetNewRefNumber`, `sp_InsertTxnSyncDetail`, `sp_MDL_Credits`, `sp_MDL_Credits_cls`,
`sp_mdwGetCustomerByBaseNo`, `sp_MmNovareg`, `sr_MDL_BankLoanDeposits`. Kullanicinin SSMS
ekran goruntusuyle birebir dogrulandi. Yalniz ilk ikisi (`sp_GetNewNumbers`/`sp_GetNewRefNumber`)
module-agnostik/framework SP'si — geri kalani MM'e ozel.

**Q7a/Q7b** (SP govdeleri, `OBJECT_DEFINITION`): tam govde okundu, ColManagement'e birebir
kopyalandi → `outputs/.../7-NetTrexColManagement-StoredProcedures.sql`. Govde modul-bagimsiz
(icinde "NetTrexMM" gecmiyor) — hicbir degisiklik gerekmedi. `sp_GetNewRefNumber`'in
`@TypeKey nvarchar(50)` parametresi, ColManagement DDL'deki `DefRefNumGen.TypeKey nvarchar(30)`
ile CAKISIYORDU -- DDL 50'ye cikarildi.

**Q8** (NetTrexColManagement tum tablo satir sayisi): 51/51 tablo mevcut, DDL ile birebir.
`BatchSet=2`, `DefNumberGen=4`, `ProductDefinition=1`, gerisi 0 (beklenen, henuz islem yok).
**Kullanicinin 1-6 script'leri calistirdigi DOGRULANDI.**

**Q9** (NetTrexMM tum tablo listesi, 128 tablo): kaydedildi, ColManagement'in Section B'siyle
karsilastirildi — eksik gorunen tablolarin (Tax*, RateSource, Branch, ExternalCustomerMap/UserMap,
DefBitMaskSet, DefAccrual/Amortization/AmountSlab/InventoryType/LegalVehicle/Location/
NotificationTemplate) HICBIRINE ColManagement'in kendi EF entity/config'inde referans YOK —
kod onceligi kuralina gore (kafadan eklenmez) bu tablolar ACILMADI. `PrdInstrument` MM'de
GERCEKTEN VAR (DerivSwp'de degil) — kolonlari okundu, ColManagement'in kendi entity/config'i ile
tutarli bulundu (tip/nullable zaten C# kodunda acik, yalniz uzunluklar MM'den dogrulandi).

**Q10** (NetTrexCommon FrameworkMenu root, `ParentId IS NULL`): 0 satir dondu — kok sentinel
NULL DEGIL. Takip sorgusuyla bulundu: gercek sentinel **`999`**. `TreasuryKey` (Id=12,
ParentId=999) gercek anahtar — onceki tahmin `'Treasury'` (Key eki eksik) YANLISTI, script 3
duzeltildi.

**Q11** (`General:AvailableModules`): `FX;FI;MM;Common;DerivSWP;InvFund;OptFX;Limit;Warrant;Equity`
— ColManagement yok, D-04 acik kaldi (elle eklenecek, hangi literal ad kullanilacagi is karari).

**Q12** (NetTrexOPTFX PrdInstrument): 0 satir — OptionsFX'te bu tablo hic yok (ne `%Instrument%`
desenine uyan baska bir tablo da yok). K-02/K-39/K-45'in "OptionsFX mimari ata" ilkesi bu tablo
icin uygulanamaz; MM tek kaynak (Q9'da cozuldu).
