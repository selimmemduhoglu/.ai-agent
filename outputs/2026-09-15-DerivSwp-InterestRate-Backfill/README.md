# DerivSwp — Getiri Egrisi Backfill (2026-09-15)

## Neden

`NetTrex.DerivSwp` degerleme motoru (`TotalNpvStep` → `InterestRateService`) her iki bacak icin ayri getiri egrisi cekiyor:

```csharp
// InterestRateDetailRepository.GetListByFilter(chartId, currency, calculateDate)
x.InterestRate.ChartId == chartId &&
x.InterestRate.YieldDate == calculateDate.Date &&     // 🔴 TAM esitlik — onceki gune DUSMEZ
x.Ccy == currency &&
StateConstants.VerifiedStatesId.Contains(x.InterestRate.StateId)
```

O gun icin egri yoksa liste bos doner:

```csharp
if (interestRateDetailList.IsNullOrEmpty())
    throw new InternalServiceException($"{nameof(interestRateDetailList)} is null");
```

Davranis farki:
- **EOD batch** → bu hatayi `WARNING` yazip isleme devam ediyor, `RevaluationBatchItem Success` donuyor.
- **Manuel Reeskont** → satiri `Failed`'a atiyor, ekranda `External system error — interestRateDetailList is null` gosteriyor.

## Tespit (2026-09-15)

`ChartId = 7` (DerivSwp islemlerinin `ReceiveIndexChartId` / `PayIndexChartId` degeri):

| Aralik | Durum |
|---|---|
| … 2026-06-28 | dolu — gunde 78 detay |
| **2026-06-29 → 2026-09-14** | **BOS** |
| 2026-09-15, 2026-09-16 | dolu — 78 detay (22 TRY + 28 EUR + 28 USD) |

Bu yuzden `Execution Date = 10.09.2026` patliyor, `15.09.2026` calisiyor.

## Sema notlari

| Nokta | Deger |
|---|---|
| `InterestRate.Id` | 🔴 IDENTITY **degil** — script `MAX(Id)+1` uretir |
| `InterestRateDetail.Id` | 🔴 IDENTITY **degil** |
| `DefNumberGen` | InterestRate icin sayac satiri **yok** — numarator bozulmaz |
| `StateId = 18` | `InputVerified` — sorgu bu durumu arar, degistirme |
| `InterestRateDetail.PointDate` | kaynakta sabit `1900-01-01` (kullanilmayan alan) |
| `PointDays` | detayda **yok**, `Point.Days` uzerinden gelir — klonlamada sorun cikarmaz |
| `Source` | `Bloomberg` |

## Calistirma sirasi

1. `02-dogrulama.sql` — mevcut durumu gor (D-2 eksik gunleri listeler)
2. `01-backfill-interest-rate.sql` — parametreleri ayarla, calistir
3. `02-dogrulama.sql` — tekrar calistir, D-2 bos donmeli
4. Ekranda `Execution Date` = eski bir tarih sec, `GENERATE`

Gerekirse: `03-geri-alma.sql` — script'in ekledigi satirlari siler (`StateMaker` damgasindan bulur).

## Parametreler (`01`)

```sql
DECLARE @ChartId          int  = 7;             -- gerekirse 2/4/5 icin de ayri kosulabilir
DECLARE @SourceYieldDate  date = '2026-09-15';  -- klonlanacak saglam gun
DECLARE @FromDate         date = '2026-06-29';
DECLARE @ToDate           date = '2026-09-14';
DECLARE @IncludeWeekends  bit  = 1;             -- EOD hafta sonu da kosuyor -> 1 birak
```

## Uyarilar

- Klonlanan oranlar **her gun ayni** olur. Fonksiyonel test icin yeterli; **oran dogrulugu / raporlama testi icin degil**.
- Satirlar `StateMaker = 'SCRIPT.BACKFILL@TEST'` damgasi tasir — gercek market data yuklemesinden ayirt edilebilir ve geri alma script'i sadece bunlari siler.
- 🔴 Prod'a uygulanmaz. Prod'da eksik egri market data surecinin isidir.
- Script idempotent: dolu gunleri atlar, ikinci kez calistirilabilir.

## Ilgili

- Sorgu denetim kaydi: `.ai-agent/sql-log/manuel-reeskont-kodlama/01-sorgular.md` (S-01 … S-13a)
- Modul yayilim rehberi: `.ai-agent/manuel-reeskont/12-modul-yayilim-rehberi.md`
