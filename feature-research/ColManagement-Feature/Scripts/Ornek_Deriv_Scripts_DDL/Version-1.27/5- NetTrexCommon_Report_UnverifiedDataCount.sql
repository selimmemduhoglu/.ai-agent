USE [NetTrexCommon]
GO

IF NOT EXISTS (SELECT 1
               FROM DefCountMonitoring
               WHERE ScreenName = N'DerivSwp Transactions')
BEGIN
    DECLARE @lastID int;
	SELECT top 1 @lastID = Id from DefCountMonitoring order by Id desc
    INSERT INTO DefCountMonitoring ([Id], [ScreenName], [Query], [ScreenUrl], [Connection], [DefaultUnverifiedStateId], [State])
    VALUES (@lastID + 1, N'DerivSwp Transactions', N'EXEC sp_UnverifiedDataCount_TxnDerivSwp',
			N'DerivSwp/Index', N'Connection', 3, 1);
END;

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT 1 
				FROM INFORMATION_SCHEMA.ROUTINES 
				WHERE ROUTINE_TYPE = 'PROCEDURE' 
				  AND ROUTINE_SCHEMA = 'dbo' 
				  AND ROUTINE_NAME = 'sp_UnverifiedDataCount_TxnDerivSwp')
BEGIN
	EXEC('
		CREATE   PROCEDURE [dbo].[sp_UnverifiedDataCount_TxnDerivSwp]
		AS
		BEGIN
			SET NOCOUNT ON;
			DECLARE @UnverifiedDataCount INT;
			SELECT @UnverifiedDataCount = COUNT(*)
			FROM NetTrexDerivSWP.dbo.TxnTransaction tt
			WHERE (tt.StateId & 2) <> 2
			  AND (tt.StateId & 1) <> 1;
			SELECT @UnverifiedDataCount AS UnverifiedDataCount;
		END'
	)
END;


