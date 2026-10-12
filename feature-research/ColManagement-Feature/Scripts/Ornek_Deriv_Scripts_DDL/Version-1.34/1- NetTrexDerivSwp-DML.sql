/*
===============================================================================
  Migration : Spread alanlari int -> decimal(18,10)
  Branch    : brn-v1.34.0.0
  Aciklama  : DerivSwp Spread (bps) alanlari kesirli deger destekleyecek sekilde
              int'ten decimal(18,10)'a genisletilir.
              int -> decimal genisleme donusumudur; mevcut veriler kayipsiz tasinir.
  ONEMLI    : Bu script, kod (C# entity + EF config) deploy'u ile SENKRON
              calistirilmalidir. Kolonlar NOT NULL (EF: IsRequired) kalir.
  Idempotent: Her ALTER, kolon zaten decimal(18,10) ise atlanir.
===============================================================================
*/

USE NetTrexDerivSWP
 
SET NOCOUNT ON;
SET XACT_ABORT ON;
BEGIN TRAN;

DECLARE @sql nvarchar(max);

/* Yardimci: kolon zaten decimal(18,10) degilse ALTER uygular */
DECLARE Cur CURSOR LOCAL FAST_FORWARD FOR
SELECT t.TableName, t.ColumnName
FROM (VALUES
    ('dbo.TxnTransaction'        , 'ReceiveSpread'),
    ('dbo.TxnTransaction'        , 'PaySpread'),
    ('dbo.TxnTransactionHistory' , 'ReceiveSpread'),
    ('dbo.TxnTransactionHistory' , 'PaySpread'),
    ('dbo.TxnCashFlow'           , 'Spread'),
    ('dbo.TxnCashFlowHistory'    , 'Spread'),
    ('dbo.DerivativesRevaluation', 'ReceiveSpread'),
    ('dbo.DerivativesRevaluation', 'PaySpread'),
    ('dbo.DerivativesRevaluation', 'ReceivePeriodSpread'),
    ('dbo.DerivativesRevaluation', 'PayPeriodSpread')
) AS t(TableName, ColumnName);

DECLARE @Table sysname, @Column sysname;

OPEN Cur;
FETCH NEXT FROM Cur INTO @Table, @Column;

WHILE @@FETCH_STATUS = 0
BEGIN
    IF OBJECT_ID(@Table) IS NULL
    BEGIN
        RAISERROR('Tablo bulunamadi: %s (atlaniyor)', 10, 1, @Table) WITH NOWAIT;
    END
    ELSE IF NOT EXISTS (
        SELECT 1
        FROM sys.columns c
        JOIN sys.types  ty ON ty.user_type_id = c.user_type_id
        WHERE c.object_id = OBJECT_ID(@Table)
          AND c.name = @Column
          AND ty.name = 'decimal'
          AND c.precision = 18
          AND c.scale = 10
    )
    BEGIN
        SET @sql = N'ALTER TABLE ' + @Table + N' ALTER COLUMN ' + QUOTENAME(@Column)
                 + N' decimal(18,10) NOT NULL;';
        PRINT @sql;
        EXEC sp_executesql @sql;
    END
    ELSE
    BEGIN
        PRINT N'-- Zaten decimal(18,10): ' + @Table + N'.' + @Column + N' (atlaniyor)';
    END

    FETCH NEXT FROM Cur INTO @Table, @Column;
END

CLOSE Cur;
DEALLOCATE Cur;

COMMIT;
PRINT 'Spread migration tamamlandi.';
