/* ==================================================================================================
   1 - NetTrexMM  --  Manuel Reeskont yuk testi: 3000 adet MM islemi (klon)
   --------------------------------------------------------------------------------------------------
   Gecerli (verified, acilis muhasebesi kesilmis) TEK bir MM islemini sablon alir ve N kopyasini ekler.
   Amac Manuel Reeskont ekraninin listeleme / sayfalama / Search / Generate / Regenerate performansini
   gercekci hacimle test etmek.

   Neden klon: Customer / Product / Term / FundSource / doviz / yon sablondan gelir -> FK'lar ve
   reeskont motorunun esleme kurallari (Direction + Product.AccountingMapCode + Ccy) garanti gecerli.
   Kolon listeleri sys.columns'tan CALISMA ANINDA okunur -> canli semaya birebir uyar.

   Her klon icin yazilanlar:
     TxnMM          1 satir  Id = '55' + DefNumberGen(1) sayaci (TransactionFactory ile ayni formul)
                             LogicalReference = @RefPrefix + 5 hane, BusinessKey = @BusinessKeyBase + n,
                             ExternalReference / ExternalReferenceSourceId / RolloverParentTransactionId = NULL
                             -> TxnMMTrigger History satirini KENDISI yazar.
     txnMMDetail    sablonun tum detaylari (Id IDENTITY), TxnId = klon Id
     accEntryMain   1 satir  ACILIS (Type = 1) basligi, Id = '55' + DefNumberGen(2) sayaci.
                             Liste sorgusu bu satiri ARIYOR (bacaklarina bakmiyor); reeskont motoru acilis
                             fisini hic okumuyor -> bacaklar (accEntry / accEngineGeneratedAccountRule)
                             bilincli olarak KLONLANMAZ. MessageKey = 0 (sablonun Fimple anahtari kopyalanmaz).

   YAZILMAYANLAR: reeskont fisleri (Type = 2), txnMmDailyCalculation -> klonlar "Not Rediscounted" gorunur.

   Idempotent: @RefPrefix ile baslayan islem varsa HICBIR SEY yapmaz (atlandi basar).
   Geri alma: 9-GERI-AL-NetTrexMM-YukTesti.sql
   ONCE: 0-DOGRULAMA-NetTrexMM.sql (sablon secimi, sayaclar, tetikleyiciler, parametreler)
   ================================================================================================== */

USE [NetTrexMM]   -- !!! ORTAMA GORE DEGISTIR (NetTrexMM_134, NetTrexMM_Dev ...) -- DOGRULAMA sorgu 0
GO

SET NOCOUNT ON;
SET XACT_ABORT ON;

-- ==================================================================================================
-- PARAMETRELER
-- ==================================================================================================
DECLARE @TemplateReference nvarchar(80) = N'TMMBRW2609XXXXXX';  -- !!! DOLDUR -- DOGRULAMA sorgu 1
DECLARE @CloneCount        int          = 3000;
DECLARE @RefPrefix         nvarchar(20) = N'TMMBRWYT';          -- klon referans oneki
DECLARE @BusinessKeyBase   bigint       = 999000000000000000;   -- gercek Snowflake anahtarlariyla cakismaz

BEGIN TRY
    BEGIN TRANSACTION;

    -- ==============================================================================================
    -- 1. KONTROLLER
    -- ==============================================================================================
    IF EXISTS (SELECT 1 FROM dbo.TxnMM WHERE LogicalReference LIKE @RefPrefix + N'%')
    BEGIN
        PRINT 'TxnMM: klonlar zaten mevcut, atlandi. (Tekrar icin once 9-GERI-AL)';
        COMMIT TRANSACTION;
        RETURN;
    END

    DECLARE @TemplateId bigint, @TemplateStateId int, @MainProductCode nvarchar(10), @OpeningId int;

    SELECT @TemplateId = t.Id, @TemplateStateId = t.StateId, @MainProductCode = p.MainProductCode
    FROM dbo.TxnMM t
    JOIN dbo.prdProductDefinition p ON p.Id = t.TxnMmProductTypeId
    WHERE t.LogicalReference = @TemplateReference;

    IF @TemplateId IS NULL
        THROW 50001, 'Sablon islem bulunamadi (@TemplateReference).', 1;

    IF @TemplateStateId NOT IN (18, 26)
        THROW 50002, 'Sablon islem verified degil (StateId 18/26 olmali) -- klonlar listede gorunmez.', 1;

    -- Liste kosulu: urunun ana urun koduyla kesilmis ACILIS fisi.
    SELECT TOP (1) @OpeningId = a.Id
    FROM dbo.accEntryMain a
    WHERE a.TxnId = @TemplateId AND a.Type = 1 AND a.ProductCode = @MainProductCode
    ORDER BY a.Id DESC;

    IF @OpeningId IS NULL
        THROW 50003, 'Sablonun acilis fisi (accEntryMain Type = 1) yok -- klonlar listede gorunmez. Baska sablon sec.', 1;

    IF NOT EXISTS (SELECT 1 FROM dbo.txnMMDetail d WHERE d.TxnId = @TemplateId AND d.IsPrincipalAmount = 0)
        THROW 50004, 'Sablonun faiz (IsPrincipalAmount = 0) detayi yok -- reeskont hesaplanamaz.', 1;

    PRINT 'Sablon: Id=' + CAST(@TemplateId AS varchar(20)) + '  Ref=' + CAST(@TemplateReference AS varchar(80)) +
          '  AcilisFisi=' + CAST(@OpeningId AS varchar(20));

    -- ==============================================================================================
    -- 2. ID SAYACLARI -- DefNumberGen(1 = TransactionMM_Id, 2 = AccountingEntryMain_Id), onek '55'
    --    (sp_GetNewNumbers ile ayni: LastNumber += N, satirlar kilitli)
    -- ==============================================================================================
    DECLARE @LastTxn int, @LastMain int;

    SELECT @LastTxn = LastNumber FROM dbo.DefNumberGen WITH (UPDLOCK, HOLDLOCK) WHERE EntityColumnType = 1;
    SELECT @LastMain = LastNumber FROM dbo.DefNumberGen WITH (UPDLOCK, HOLDLOCK) WHERE EntityColumnType = 2;

    IF @LastTxn IS NULL OR @LastMain IS NULL
        THROW 50005, 'DefNumberGen 1 / 2 satiri yok.', 1;

    -- Id = int.Parse("55" + sayac) -> int'e sigmali.
    IF CAST('55' + CAST(@LastTxn + @CloneCount AS varchar(12)) AS bigint) > 2147483647
       OR CAST('55' + CAST(@LastMain + @CloneCount AS varchar(12)) AS bigint) > 2147483647
        THROW 50006, 'Sayac + @CloneCount, 55 onekiyle int sinirini asiyor.', 1;

    UPDATE dbo.DefNumberGen SET LastNumber = @LastTxn + @CloneCount, LastUpdateDate = GETDATE()
    WHERE EntityColumnType = 1;
    UPDATE dbo.DefNumberGen SET LastNumber = @LastMain + @CloneCount, LastUpdateDate = GETDATE()
    WHERE EntityColumnType = 2;

    PRINT 'DefNumberGen(1): ' + CAST(@LastTxn AS varchar(12)) + ' -> ' + CAST(@LastTxn + @CloneCount AS varchar(12));
    PRINT 'DefNumberGen(2): ' + CAST(@LastMain AS varchar(12)) + ' -> ' + CAST(@LastMain + @CloneCount AS varchar(12));

    -- ==============================================================================================
    -- 3. ESLEME TABLOSU -- klon n -> yeni Id / referans / BusinessKey / acilis fisi Id
    -- ==============================================================================================
    IF OBJECT_ID('tempdb..#MmCloneMap') IS NOT NULL DROP TABLE #MmCloneMap;

    CREATE TABLE #MmCloneMap
    (
        [N]               int           NOT NULL PRIMARY KEY,
        [NewId]           bigint        NOT NULL,
        [NewReference]    nvarchar(80)  NOT NULL,
        [NewBusinessKey]  bigint        NOT NULL,
        [NewMainId]       int           NOT NULL
    );

    ;WITH Tally AS
    (
        SELECT TOP (@CloneCount) ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS N
        FROM sys.all_objects a CROSS JOIN sys.all_objects b
    )
    INSERT INTO #MmCloneMap (N, NewId, NewReference, NewBusinessKey, NewMainId)
    SELECT N,
           CAST('55' + CAST(@LastTxn + N AS varchar(12)) AS bigint),
           @RefPrefix + RIGHT(N'00000' + CAST(N AS nvarchar(5)), 5),
           @BusinessKeyBase + N,
           CAST('55' + CAST(@LastMain + N AS varchar(12)) AS int)
    FROM Tally;

    IF EXISTS (SELECT 1 FROM dbo.TxnMM t JOIN #MmCloneMap m ON m.NewId = t.Id)
        THROW 50007, 'Ayrilan TxnMM Id araliginda mevcut kayit var -- sayac bozuk, DOGRULAMA sorgu 3.', 1;

    IF EXISTS (SELECT 1 FROM dbo.accEntryMain a JOIN #MmCloneMap m ON m.NewMainId = a.Id)
        THROW 50008, 'Ayrilan accEntryMain Id araliginda mevcut kayit var -- sayac bozuk, DOGRULAMA sorgu 3.', 1;

    DECLARE @Columns nvarchar(max), @Values nvarchar(max), @Sql nvarchar(max), @Rows int;

    -- ==============================================================================================
    -- 4. TxnMM KLONLARI (TxnMMTrigger History'yi yazar)
    -- ==============================================================================================
    SELECT
        @Columns = STRING_AGG(CAST(QUOTENAME(c.name) AS nvarchar(max)), N', ') WITHIN GROUP (ORDER BY c.column_id),
        @Values  = STRING_AGG(CAST(
            CASE c.name
                WHEN 'Id'                          THEN N'm.NewId'
                WHEN 'LogicalReference'            THEN N'm.NewReference'
                WHEN 'BusinessKey'                 THEN N'm.NewBusinessKey'
                WHEN 'ExternalReference'           THEN N'NULL'
                WHEN 'ExternalReferenceSourceId'   THEN N'NULL'
                WHEN 'RolloverParentTransactionId' THEN N'NULL'
                WHEN 'StateDate'                   THEN N'GETDATE()'
                WHEN 'CreatedDate'                 THEN N'GETDATE()'
                ELSE N's.' + QUOTENAME(c.name)
            END AS nvarchar(max)), N', ') WITHIN GROUP (ORDER BY c.column_id)
    FROM sys.columns c
    WHERE c.object_id = OBJECT_ID(N'dbo.TxnMM') AND c.is_identity = 0 AND c.is_computed = 0;

    SET @Sql = N'INSERT INTO dbo.TxnMM (' + @Columns + N') SELECT ' + @Values +
               N' FROM dbo.TxnMM s CROSS JOIN #MmCloneMap m WHERE s.Id = @TemplateId; SET @Rows = @@ROWCOUNT;';

    EXEC sys.sp_executesql @Sql, N'@TemplateId bigint, @Rows int OUTPUT',
        @TemplateId = @TemplateId, @Rows = @Rows OUTPUT;

    PRINT 'TxnMM: ' + CAST(@Rows AS varchar(10)) + ' klon eklendi.';

    -- ==============================================================================================
    -- 5. txnMMDetail -- sablonun tum periyotlari (Id IDENTITY)
    -- ==============================================================================================
    SELECT
        @Columns = STRING_AGG(CAST(QUOTENAME(c.name) AS nvarchar(max)), N', ') WITHIN GROUP (ORDER BY c.column_id),
        @Values  = STRING_AGG(CAST(
            CASE c.name WHEN 'TxnId' THEN N'm.NewId' ELSE N's.' + QUOTENAME(c.name) END
            AS nvarchar(max)), N', ') WITHIN GROUP (ORDER BY c.column_id)
    FROM sys.columns c
    WHERE c.object_id = OBJECT_ID(N'dbo.txnMMDetail') AND c.is_identity = 0 AND c.is_computed = 0;

    SET @Sql = N'INSERT INTO dbo.txnMMDetail (' + @Columns + N') SELECT ' + @Values +
               N' FROM dbo.txnMMDetail s CROSS JOIN #MmCloneMap m WHERE s.TxnId = @TemplateId; SET @Rows = @@ROWCOUNT;';

    EXEC sys.sp_executesql @Sql, N'@TemplateId bigint, @Rows int OUTPUT',
        @TemplateId = @TemplateId, @Rows = @Rows OUTPUT;

    PRINT 'txnMMDetail: ' + CAST(@Rows AS varchar(10)) + ' satir eklendi.';

    -- ==============================================================================================
    -- 6. accEntryMain -- ACILIS basligi (Type = 1), liste kosulu icin
    -- ==============================================================================================
    SELECT
        @Columns = STRING_AGG(CAST(QUOTENAME(c.name) AS nvarchar(max)), N', ') WITHIN GROUP (ORDER BY c.column_id),
        @Values  = STRING_AGG(CAST(
            CASE c.name
                WHEN 'Id'          THEN N'm.NewMainId'
                WHEN 'TxnId'       THEN N'm.NewId'
                WHEN 'BusinessKey' THEN N'm.NewBusinessKey'
                WHEN 'MessageKey'  THEN N'0'
                WHEN 'ReverseId'   THEN N'0'
                WHEN 'IsReverse'   THEN N'0'
                WHEN 'StateDate'   THEN N'GETDATE()'
                ELSE N's.' + QUOTENAME(c.name)
            END AS nvarchar(max)), N', ') WITHIN GROUP (ORDER BY c.column_id)
    FROM sys.columns c
    WHERE c.object_id = OBJECT_ID(N'dbo.accEntryMain') AND c.is_identity = 0 AND c.is_computed = 0;

    SET @Sql = N'INSERT INTO dbo.accEntryMain (' + @Columns + N') SELECT ' + @Values +
               N' FROM dbo.accEntryMain s CROSS JOIN #MmCloneMap m WHERE s.Id = @OpeningId; SET @Rows = @@ROWCOUNT;';

    EXEC sys.sp_executesql @Sql, N'@OpeningId int, @Rows int OUTPUT',
        @OpeningId = @OpeningId, @Rows = @Rows OUTPUT;

    PRINT 'accEntryMain (acilis): ' + CAST(@Rows AS varchar(10)) + ' satir eklendi.';

    COMMIT TRANSACTION;
    PRINT 'YUK TESTI VERISI BASARILI -- NetTrexMM';

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

-- Kontrol: 3000 islem, 3000 x (sablonun detay sayisi) detay, 3000 acilis fisi beklenir.
SELECT
    (SELECT COUNT(*) FROM dbo.TxnMM WHERE LogicalReference LIKE N'TMMBRWYT%') AS KlonIslem,
    (SELECT COUNT(*) FROM dbo.txnMMDetail d JOIN dbo.TxnMM t ON t.Id = d.TxnId
      WHERE t.LogicalReference LIKE N'TMMBRWYT%') AS KlonDetay,
    (SELECT COUNT(*) FROM dbo.accEntryMain a JOIN dbo.TxnMM t ON t.Id = a.TxnId
      WHERE t.LogicalReference LIKE N'TMMBRWYT%' AND a.Type = 1) AS KlonAcilisFisi;
GO
