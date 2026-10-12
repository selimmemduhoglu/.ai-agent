# Referans — `2-NetTrexFX-YukTesti-3000-Islem.sql`

> Skill: [yuk-testi](../yuk-testi.md) · Kaynak: `repos/.ai-agent/outputs/2026-09-26-ManuelReeskont-YukTesti/`

**Amaç:** Tek bir verified FX Spot/Forward/Future işlemini şablon alıp `txnFX`'e N klon basar — Manuel Reeskont
listeleme / sayfalama / Search / Generate / Regenerate performansı için.

**Yazdıkları:** yalnız `txnFX` (`Id = '11' + defNumberGen(1)`). **Yazmadıkları:** `txnFxValuation`,
`accEntryMain/accEntry`, `TxnSync` — FX listesi açılış muhasebesi aramıyor; klonlar "Not Rediscounted".

| Parametre | Değer | Not |
|---|---|---|
| `USE [...]` | `NetTrexFX` | 🔴 Ortama göre düzelt (DOGRULAMA sorgu 0) |
| `@TemplateReference` | placeholder `'TFXFW2609XXXXXXX'` | 🔴 **DOLDUR** (DOGRULAMA sorgu 1). Doldurulmazsa `THROW 50002 'Sablon islem bulunamadi'` |
| `@CloneCount` | `3000` | |
| `@RefPrefix` | `'TFXFWYT'` | 🔴 `TFX` ile başlamalı, `TFXSW` ile başlamamalı. GERI-AL ile aynı; kontrol `SELECT`'i sabit `'TFXFWYT%'` |
| `@BusinessKeyBase` | `999000000000000000` | NULL olamaz (`BuildValuation`) |
| `@TradeDate` / `@ValueDate` | `NULL` | NULL → şablonunki; `ValueDate > TradeDate` olmalı |

**Hata kodları:** 50001 önek kuralı · 50002 şablon yok · 50003 verified değil · 50004 instrument 69/70/71 değil ·
50005 `ValueDate <= TradeDate` · 50006 `defNumberGen` 1 yok · 50007 int sınırı · 50008 ayrılan Id aralığı dolu.

**Koşma:** DOGRULAMA → bu script → kontrol `SELECT`'i (`KlonSayisi = 3000`). İdempotent: klon varsa `atlandi`
basar. Geri alma: [fx-geri-al.md](fx-geri-al.md).

```sql
/* ==================================================================================================
   2 - NetTrexFX  --  Manuel Reeskont yuk testi: 3000 adet FX islemi (klon)
   --------------------------------------------------------------------------------------------------
   Gecerli (verified) TEK bir FX islemini sablon alir ve txnFX tablosuna N kopyasini ekler. Amac
   Manuel Reeskont ekraninin listeleme / sayfalama / Search / Generate / Regenerate performansini
   gercekci hacimle test etmek.

   Neden klon: Customer / Portfolio / Instrument / Direction / doviz cifti sablondan gelir, yani FK'lar
   ve muhasebe motoru kurali (NetTrex/FX/{Instrument.Code}/{Direction}/ OnEOD) garanti gecerli.
   Kolon listesi sys.columns'tan CALISMA ANINDA okunur -> canli semaya birebir uyar.

   Klonda degisenler (gerisi sablonla ayni):
     Id                  '11' + defNumberGen(EntityColumnType = 1) sayaci  (FxTransaction.Insert ile ayni formul)
     LogicalReference    @RefPrefix + 5 hane  (TFX ile baslamali, TFXSW ile BASLAMAMALI -> FX alt urunu)
     BusinessKey         @BusinessKeyBase + n  (null olamaz: BuildValuation .Value okuyor)
     ExternalReference   NULL  (dolu olursa mukerrer kontrolune takilir)
     Linked*             NULL
     TradeDate/ValueDate @TradeDate/@ValueDate verilirse onlar, yoksa sablonunki
     StateDate/CreatedDate GETDATE()

   YAZILMAYANLAR (bilincli): txnFxValuation, accEntryMain/accEntry (acilis muhasebesi), TxnSync.
   FX listesi acilis muhasebesi ARAMIYOR; klonlar ekranda "Not Rediscounted" gorunur.

   Idempotent: @RefPrefix ile baslayan islem varsa HICBIR SEY yapmaz (atlandi basar).
   Geri alma: 9-GERI-AL-NetTrexFX-YukTesti.sql

   ONCE: 0-DOGRULAMA-NetTrexFX.sql (sablon secimi, sayac, tetikleyici, parametreler)
   ================================================================================================== */

USE [NetTrexFX]   -- !!! ORTAMA GORE DEGISTIR (NetTrexFX_Dev, NetTrexFX_133 ...) -- DOGRULAMA sorgu 0
GO

SET NOCOUNT ON;
SET XACT_ABORT ON;

-- ==================================================================================================
-- PARAMETRELER
-- ==================================================================================================
DECLARE @TemplateReference varchar(50) = 'TFXFW2609XXXXXXX';  -- !!! DOLDUR -- DOGRULAMA sorgu 1
DECLARE @CloneCount        int         = 3000;
DECLARE @RefPrefix         varchar(20) = 'TFXFWYT';            -- klon referans oneki (TFX..., TFXSW DEGIL)
DECLARE @BusinessKeyBase   bigint      = 999000000000000000;   -- gercek Snowflake anahtarlariyla cakismaz
DECLARE @TradeDate         date        = NULL;                 -- NULL -> sablonun TradeDate'i
DECLARE @ValueDate         date        = NULL;                 -- NULL -> sablonun ValueDate'i

BEGIN TRY
    BEGIN TRANSACTION;

    -- ==============================================================================================
    -- 1. KONTROLLER
    -- ==============================================================================================
    IF EXISTS (SELECT 1 FROM dbo.txnFX WHERE LogicalReference LIKE @RefPrefix + '%')
    BEGIN
        PRINT 'txnFX: ' + @RefPrefix + '% referansli klonlar zaten mevcut, atlandi. (Tekrar icin once 9-GERI-AL)';
        COMMIT TRANSACTION;
        RETURN;
    END

    IF @RefPrefix NOT LIKE 'TFX%' OR @RefPrefix LIKE 'TFXSW%'
        THROW 50001, '@RefPrefix TFX ile baslamali ve TFXSW ile baslamamali (alt urun onekten cozuluyor).', 1;

    DECLARE @TemplateId bigint, @TemplateStateId bigint, @TemplateInstrumentId int,
            @TemplateBusinessKey bigint, @TemplateTrade date, @TemplateValue date;

    SELECT @TemplateId = Id, @TemplateStateId = StateId, @TemplateInstrumentId = InstrumentId,
           @TemplateBusinessKey = BusinessKey, @TemplateTrade = CAST(TradeDate AS date),
           @TemplateValue = CAST(ValueDate AS date)
    FROM dbo.txnFX
    WHERE LogicalReference = @TemplateReference;

    IF @TemplateId IS NULL
        THROW 50002, 'Sablon islem bulunamadi (@TemplateReference).', 1;

    IF (@TemplateStateId & 6) <> 2
        THROW 50003, 'Sablon islem verified degil (StateId 18/26 olmali) -- klonlar listede gorunmez.', 1;

    IF @TemplateInstrumentId NOT IN (69, 70, 71)
        THROW 50004, 'Sablon InstrumentId 69 (Spot) / 70 (Forward) / 71 (Future) degil -- FX alt urunu listesine girmez.', 1;

    IF COALESCE(@ValueDate, @TemplateValue) <= COALESCE(@TradeDate, @TemplateTrade)
        THROW 50005, 'ValueDate, TradeDate''ten buyuk olmali (liste kosulu ValueDate.Date > TradeDate.Date).', 1;

    PRINT 'Sablon: Id=' + CAST(@TemplateId AS varchar(20)) + '  Ref=' + @TemplateReference;

    -- ==============================================================================================
    -- 2. ID SAYACI -- defNumberGen(EntityColumnType = 1, TransactionFx_Id), onek '11'
    -- ==============================================================================================
    DECLARE @Last int;

    SELECT @Last = ISNULL(LastNumber, 0)
    FROM dbo.defNumberGen WITH (UPDLOCK, HOLDLOCK)
    WHERE EntityColumnType = 1;

    IF @Last IS NULL
        THROW 50006, 'defNumberGen EntityColumnType = 1 (TransactionFx_Id) satiri yok.', 1;

    -- Id = int.Parse("11" + sayac) -> int'e sigmali.
    IF CAST('11' + CAST(@Last + @CloneCount AS varchar(12)) AS bigint) > 2147483647
        THROW 50007, 'Sayac + @CloneCount, 11 onekiyle int sinirini asiyor.', 1;

    UPDATE dbo.defNumberGen
    SET LastNumber = @Last + @CloneCount, LastUpdateDate = GETDATE()
    WHERE EntityColumnType = 1;

    PRINT 'defNumberGen(1): ' + CAST(@Last AS varchar(12)) + ' -> ' + CAST(@Last + @CloneCount AS varchar(12));

    -- ==============================================================================================
    -- 3. ESLEME TABLOSU -- klon n -> yeni Id / referans / BusinessKey
    -- ==============================================================================================
    IF OBJECT_ID('tempdb..#FxCloneMap') IS NOT NULL DROP TABLE #FxCloneMap;

    CREATE TABLE #FxCloneMap
    (
        [N]               int          NOT NULL PRIMARY KEY,
        [NewId]           bigint       NOT NULL,
        [NewReference]    varchar(50)  NOT NULL,
        [NewBusinessKey]  bigint       NOT NULL
    );

    ;WITH Tally AS
    (
        SELECT TOP (@CloneCount) ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS N
        FROM sys.all_objects a CROSS JOIN sys.all_objects b
    )
    INSERT INTO #FxCloneMap (N, NewId, NewReference, NewBusinessKey)
    SELECT N,
           CAST('11' + CAST(@Last + N AS varchar(12)) AS bigint),
           @RefPrefix + RIGHT('00000' + CAST(N AS varchar(5)), 5),
           @BusinessKeyBase + N
    FROM Tally;

    IF EXISTS (SELECT 1 FROM dbo.txnFX t JOIN #FxCloneMap m ON m.NewId = t.Id)
        THROW 50008, 'Ayrilan Id araliginda mevcut txnFX kaydi var -- sayac bozuk, DOGRULAMA sorgu 3.', 1;

    -- ==============================================================================================
    -- 4. txnFX KLONLARI -- kolon listesi canli semadan
    -- ==============================================================================================
    DECLARE @Columns nvarchar(max), @Values nvarchar(max), @Sql nvarchar(max);

    SELECT
        @Columns = STRING_AGG(CAST(QUOTENAME(c.name) AS nvarchar(max)), N', ') WITHIN GROUP (ORDER BY c.column_id),
        @Values  = STRING_AGG(CAST(
            CASE c.name
                WHEN 'Id'                         THEN N'm.NewId'
                WHEN 'LogicalReference'           THEN N'm.NewReference'
                WHEN 'BusinessKey'                THEN N'm.NewBusinessKey'
                WHEN 'ExternalReference'          THEN N'NULL'
                WHEN 'ExternalReferenceSourceId'  THEN N'NULL'
                WHEN 'LinkedTransactionId'        THEN N'NULL'
                WHEN 'LinkedTransactionReference' THEN N'NULL'
                WHEN 'LinkedTransactionTrader'    THEN N'NULL'
                WHEN 'LinkedTransactionReasonType' THEN N'NULL'
                WHEN 'TradeDate'                  THEN N'COALESCE(CAST(@TradeDate AS datetime), s.[TradeDate])'
                WHEN 'ValueDate'                  THEN N'COALESCE(CAST(@ValueDate AS datetime), s.[ValueDate])'
                WHEN 'StateDate'                  THEN N'GETDATE()'
                WHEN 'CreatedDate'                THEN N'GETDATE()'
                ELSE N's.' + QUOTENAME(c.name)
            END AS nvarchar(max)), N', ') WITHIN GROUP (ORDER BY c.column_id)
    FROM sys.columns c
    WHERE c.object_id = OBJECT_ID(N'dbo.txnFX')
      AND c.is_identity = 0
      AND c.is_computed = 0;

    SET @Sql = N'INSERT INTO dbo.txnFX (' + @Columns + N') ' +
               N'SELECT ' + @Values + N' FROM dbo.txnFX s CROSS JOIN #FxCloneMap m WHERE s.Id = @TemplateId; ' +
               N'SET @Rows = @@ROWCOUNT;';

    DECLARE @Rows int;

    EXEC sys.sp_executesql @Sql,
        N'@TemplateId bigint, @TradeDate date, @ValueDate date, @Rows int OUTPUT',
        @TemplateId = @TemplateId, @TradeDate = @TradeDate, @ValueDate = @ValueDate, @Rows = @Rows OUTPUT;

    PRINT 'txnFX: ' + CAST(@Rows AS varchar(10)) + ' klon eklendi (' + @RefPrefix + '00001 .. ).';

    COMMIT TRANSACTION;
    PRINT 'YUK TESTI VERISI BASARILI -- NetTrexFX';

END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    PRINT '*** HATA -- Script geri alindi. ***';
    PRINT 'Hata No    : ' + CAST(ERROR_NUMBER() AS NVARCHAR(10));
    PRINT 'Hata Mesaji: ' + ERROR_MESSAGE();
    PRINT 'Satir No   : ' + CAST(ERROR_LINE() AS NVARCHAR(10));
    THROW;
END CATCH;
GO

-- Kontrol: 3000 satir beklenir.
SELECT COUNT(*) AS KlonSayisi, MIN(LogicalReference) AS IlkRef, MAX(LogicalReference) AS SonRef,
       MIN(Id) AS IlkId, MAX(Id) AS SonId
FROM dbo.txnFX
WHERE LogicalReference LIKE 'TFXFWYT%';
GO
```
