/* ==================================================================================================
   1 - NetTrexMM  --  Manuel Reeskont listeleme / fis sorgulari icin FK index'leri
   --------------------------------------------------------------------------------------------------
   AccEntryMain, TxnMMDetail, TxnMmDailyCalculation, TxnCashFlow, LoanRevaluation tablolarinda yalniz
   PK (Id) var; islem (TxnId) uzerinden yapilan her arama tablo taramasi. Kod tarafi (set-based sorgu)
   tek basina listelemeyi ~75 sn'den ~1.5 sn'ye indirdi; bu index'ler veri buyudukce hem listeyi hem
   islem bazli fis aramalarini (Generate/Regenerate, muhasebe popup'i) korur.
   Idempotent: tabloda ayni kolonla baslayan bir index varsa atlar, tekrar kosulabilir.
   Veri degistirmez. Buyuk tabloda CREATE INDEX kisa sureli kilit alir: yogun saat disinda kosun.
   MM'de EF Core migration altyapisi YOK; sema bu script ile yonetilir.
   Olcum: .ai-agent/sql-log/manuel-reeskont-kodlama S-21..S-27
   ================================================================================================== */

USE [NetTrexMM]   -- !!! ORTAMA GORE DEGISTIR (ornek: NetTrexMM_37_28092026_MR)
GO
SET NOCOUNT ON;
GO

-- ------------------------------------------------------------------------------------------------
-- AccEntryMain (TxnId,Type,ValueDate)
-- ------------------------------------------------------------------------------------------------
IF OBJECT_ID(N'[dbo].[AccEntryMain]', N'U') IS NULL
    PRINT 'AccEntryMain tablosu yok, atlandi.';
ELSE IF EXISTS (SELECT 1
                FROM sys.indexes i
                JOIN sys.index_columns ic ON ic.object_id = i.object_id AND ic.index_id = i.index_id AND ic.key_ordinal = 1
                JOIN sys.columns c ON c.object_id = ic.object_id AND c.column_id = ic.column_id
                WHERE i.object_id = OBJECT_ID(N'[dbo].[AccEntryMain]') AND c.name = N'TxnId')
    PRINT 'AccEntryMain: TxnId ile baslayan index zaten var, atlandi.';
ELSE
BEGIN
    CREATE NONCLUSTERED INDEX [IX_AccEntryMain_TxnId_Type_ValueDate] ON [dbo].[AccEntryMain] ([TxnId] ASC, [Type] ASC, [ValueDate] ASC);
    PRINT 'IX_AccEntryMain_TxnId_Type_ValueDate eklendi.';
END
GO

-- ------------------------------------------------------------------------------------------------
-- TxnMMDetail (TxnId)
-- ------------------------------------------------------------------------------------------------
IF OBJECT_ID(N'[dbo].[TxnMMDetail]', N'U') IS NULL
    PRINT 'TxnMMDetail tablosu yok, atlandi.';
ELSE IF EXISTS (SELECT 1
                FROM sys.indexes i
                JOIN sys.index_columns ic ON ic.object_id = i.object_id AND ic.index_id = i.index_id AND ic.key_ordinal = 1
                JOIN sys.columns c ON c.object_id = ic.object_id AND c.column_id = ic.column_id
                WHERE i.object_id = OBJECT_ID(N'[dbo].[TxnMMDetail]') AND c.name = N'TxnId')
    PRINT 'TxnMMDetail: TxnId ile baslayan index zaten var, atlandi.';
ELSE
BEGIN
    CREATE NONCLUSTERED INDEX [IX_TxnMMDetail_TxnId] ON [dbo].[TxnMMDetail] ([TxnId] ASC);
    PRINT 'IX_TxnMMDetail_TxnId eklendi.';
END
GO

-- ------------------------------------------------------------------------------------------------
-- TxnMmDailyCalculation (TxnMmId,CalculationDate)
-- ------------------------------------------------------------------------------------------------
IF OBJECT_ID(N'[dbo].[TxnMmDailyCalculation]', N'U') IS NULL
    PRINT 'TxnMmDailyCalculation tablosu yok, atlandi.';
ELSE IF EXISTS (SELECT 1
                FROM sys.indexes i
                JOIN sys.index_columns ic ON ic.object_id = i.object_id AND ic.index_id = i.index_id AND ic.key_ordinal = 1
                JOIN sys.columns c ON c.object_id = ic.object_id AND c.column_id = ic.column_id
                WHERE i.object_id = OBJECT_ID(N'[dbo].[TxnMmDailyCalculation]') AND c.name = N'TxnMmId')
    PRINT 'TxnMmDailyCalculation: TxnMmId ile baslayan index zaten var, atlandi.';
ELSE
BEGIN
    CREATE NONCLUSTERED INDEX [IX_TxnMmDailyCalculation_TxnMmId_CalculationDate] ON [dbo].[TxnMmDailyCalculation] ([TxnMmId] ASC, [CalculationDate] ASC);
    PRINT 'IX_TxnMmDailyCalculation_TxnMmId_CalculationDate eklendi.';
END
GO

-- ------------------------------------------------------------------------------------------------
-- TxnCashFlow (TxnId)
-- ------------------------------------------------------------------------------------------------
IF OBJECT_ID(N'[dbo].[TxnCashFlow]', N'U') IS NULL
    PRINT 'TxnCashFlow tablosu yok, atlandi.';
ELSE IF EXISTS (SELECT 1
                FROM sys.indexes i
                JOIN sys.index_columns ic ON ic.object_id = i.object_id AND ic.index_id = i.index_id AND ic.key_ordinal = 1
                JOIN sys.columns c ON c.object_id = ic.object_id AND c.column_id = ic.column_id
                WHERE i.object_id = OBJECT_ID(N'[dbo].[TxnCashFlow]') AND c.name = N'TxnId')
    PRINT 'TxnCashFlow: TxnId ile baslayan index zaten var, atlandi.';
ELSE
BEGIN
    CREATE NONCLUSTERED INDEX [IX_TxnCashFlow_TxnId] ON [dbo].[TxnCashFlow] ([TxnId] ASC);
    PRINT 'IX_TxnCashFlow_TxnId eklendi.';
END
GO

-- ------------------------------------------------------------------------------------------------
-- LoanRevaluation (TxnId,CalculationDate)
-- ------------------------------------------------------------------------------------------------
IF OBJECT_ID(N'[dbo].[LoanRevaluation]', N'U') IS NULL
    PRINT 'LoanRevaluation tablosu yok, atlandi.';
ELSE IF EXISTS (SELECT 1
                FROM sys.indexes i
                JOIN sys.index_columns ic ON ic.object_id = i.object_id AND ic.index_id = i.index_id AND ic.key_ordinal = 1
                JOIN sys.columns c ON c.object_id = ic.object_id AND c.column_id = ic.column_id
                WHERE i.object_id = OBJECT_ID(N'[dbo].[LoanRevaluation]') AND c.name = N'TxnId')
    PRINT 'LoanRevaluation: TxnId ile baslayan index zaten var, atlandi.';
ELSE
BEGIN
    CREATE NONCLUSTERED INDEX [IX_LoanRevaluation_TxnId_CalculationDate] ON [dbo].[LoanRevaluation] ([TxnId] ASC, [CalculationDate] ASC);
    PRINT 'IX_LoanRevaluation_TxnId_CalculationDate eklendi.';
END
GO

-- Kontrol: 5 satir beklenir (tablo yoksa eksik).
SELECT t.name AS Tablo, i.name AS IndexAdi
FROM sys.indexes i JOIN sys.tables t ON t.object_id = i.object_id
WHERE i.name IN (N'IX_AccEntryMain_TxnId_Type_ValueDate', N'IX_TxnMMDetail_TxnId',
                 N'IX_TxnMmDailyCalculation_TxnMmId_CalculationDate', N'IX_TxnCashFlow_TxnId',
                 N'IX_LoanRevaluation_TxnId_CalculationDate')
ORDER BY t.name;
GO
