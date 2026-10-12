use NetTrexDerivSWP
go

	DECLARE @OldTableName NVARCHAR(MAX);
	DECLARE @NewTableName NVARCHAR(MAX);
	DECLARE @SQL NVARCHAR(MAX);

	-- Cursor to loop through table names
	DECLARE table_cursor CURSOR FOR
	SELECT TABLE_NAME
	FROM INFORMATION_SCHEMA.TABLES
	WHERE TABLE_TYPE = 'BASE TABLE'
	  AND LOWER(LEFT(TABLE_NAME, 1)) +  SUBSTRING(TABLE_NAME, 2, 500) = TABLE_NAME COLLATE Latin1_General_BIN;

	OPEN table_cursor;

	FETCH NEXT FROM table_cursor INTO @OldTableName;

	WHILE @@FETCH_STATUS = 0
	BEGIN
		-- Create new table name with the first letter capitalized
		SET @NewTableName = UPPER(LEFT(@OldTableName, 1)) + SUBSTRING(@OldTableName, 2, LEN(@OldTableName));

		-- Build dynamic SQL for renaming the table
		SET @SQL = 'EXEC sp_rename ''' + @OldTableName + ''', ''' + @NewTableName + ''', ''OBJECT'';';

		-- Execute the renaming
		--PRINT @sql
    
		EXEC sp_executesql @SQL;

		FETCH NEXT FROM table_cursor INTO @OldTableName;
	END;

	CLOSE table_cursor;
	DEALLOCATE table_cursor;

go

	DECLARE @OldTriggerName NVARCHAR(MAX);
	DECLARE @NewTriggerName NVARCHAR(MAX);
	DECLARE @SQL NVARCHAR(MAX);

	-- Cursor to loop through table names
	DECLARE trigger_cursor CURSOR FOR
	select name
	FROM sys.objects
	WHERE type = 'TR'
	and LOWER(LEFT(name, 1)) +  SUBSTRING(name, 2, 500) = name COLLATE Latin1_General_BIN;

	OPEN trigger_cursor;

	FETCH NEXT FROM trigger_cursor INTO @OldTriggerName;

	WHILE @@FETCH_STATUS = 0
	BEGIN
		-- Create new trigger name with the first letter capitalized
		SET @NewTriggerName = UPPER(LEFT(@OldTriggerName, 1)) + SUBSTRING(@OldTriggerName, 2, LEN(@OldTriggerName));

		-- Build dynamic SQL for renaming the trigger
		SET @SQL = 'EXEC sp_rename ''' + @OldTriggerName + ''', ''' + @NewTriggerName + ''', ''OBJECT'';';

		-- Execute the renaming
		--PRINT @sql
    
		EXEC sp_executesql @SQL;

		FETCH NEXT FROM trigger_cursor INTO @OldTriggerName;
	END;

	CLOSE trigger_cursor;
	DEALLOCATE trigger_cursor;

go

DECLARE @OldName NVARCHAR(255)
	DECLARE @NewName NVARCHAR(255)
	DECLARE @TableName NVARCHAR(255)
	DECLARE @ColumnName NVARCHAR(255)
	DECLARE @SQL NVARCHAR(MAX)

	DECLARE ConstraintCursor CURSOR FOR
	SELECT 
		DC.name AS OldConstraintName,
		T.name AS TableName,
		C.name AS ColumnName
	FROM sys.default_constraints AS DC
	JOIN sys.columns AS C ON DC.parent_object_id = C.object_id AND DC.parent_column_id = C.column_id
	JOIN sys.tables AS T ON C.object_id = T.object_id
	JOIN sys.schemas s on s.schema_id = t.schema_id
	WHERE s.name = 'dbo'
	and t.name <> 'sysdiagrams'

	OPEN ConstraintCursor

	FETCH NEXT FROM ConstraintCursor INTO @OldName, @TableName, @ColumnName

	WHILE @@FETCH_STATUS = 0
	BEGIN
		SET @NewName = 'DF_' + @TableName + '_' + @ColumnName
		SET @SQL = 'EXEC sp_rename ''' + @OldName + ''', ''' + @NewName + ''', ''OBJECT'''
    
		--PRINT @SQL -- Bu satır, her bir rename komutunu yazdırır
		EXEC sp_executesql @SQL

		FETCH NEXT FROM ConstraintCursor INTO @OldName, @TableName, @ColumnName
	END

	CLOSE ConstraintCursor
	DEALLOCATE ConstraintCursor
go

	DECLARE @sql NVARCHAR(MAX) = '';

	-- Step 1: Generate Dynamic SQL to Rename All Unique Constraints
	SELECT @sql = @sql + 
		'EXEC sp_rename ''' + i.name + ''', ''UQ_' + t.name + '_' + c.name + ''';' + CHAR(13)
	FROM 
		sys.indexes i
	INNER JOIN 
		sys.index_columns ic ON i.object_id = ic.object_id AND i.index_id = ic.index_id
	INNER JOIN 
		sys.columns c ON ic.object_id = c.object_id AND ic.column_id = c.column_id
	INNER JOIN 
		sys.tables t ON i.object_id = t.object_id
	WHERE 
		i.is_unique = 1 -- Only unique constraints
		AND i.is_primary_key = 0 -- Exclude primary keys
		AND t.is_ms_shipped = 0; -- Exclude system tables

	EXEC sp_executesql @sql;

GO


	DECLARE @OldName NVARCHAR(255)
	DECLARE @NewName NVARCHAR(255)
	DECLARE @SQL NVARCHAR(MAX)

	DECLARE ConstraintCursor CURSOR FOR
	SELECT fk.name AS OldName,
    'FK_' + t.name + '_' + t2.name + '_' + STRING_AGG(c.name, '_') WITHIN GROUP (ORDER BY c.name ASC)  NewName
	FROM sys.foreign_keys AS fk
	JOIN sys.tables AS t ON fk.parent_object_id = t.object_id
	JOIN sys.schemas AS s ON t.schema_id = s.schema_id
	JOIN sys.tables AS t2 ON fk.referenced_object_id = t2.object_id
	JOIN sys.foreign_key_columns AS fkc ON fk.object_id = fkc.constraint_object_id
	JOIN sys.columns AS c ON fkc.parent_object_id = c.object_id AND fkc.parent_column_id = c.column_id
	WHERE s.name = 'dbo'
	GROUP BY fk.name, t.name, t2.name
	ORDER BY fk.name, t.name, t2.name;

	OPEN ConstraintCursor

	FETCH NEXT FROM ConstraintCursor INTO @OldName, @NewName

	WHILE @@FETCH_STATUS = 0
	BEGIN
		
		SET @SQL = 'EXEC sp_rename ''' + @OldName + ''', ''' + @NewName + ''''
    
		--PRINT @SQL -- Bu satır, her bir rename komutunu yazdırır
		EXEC sp_executesql @SQL

		FETCH NEXT FROM ConstraintCursor INTO @OldName, @NewName
	END

	CLOSE ConstraintCursor
	DEALLOCATE ConstraintCursor

	GO

	DECLARE @OldName NVARCHAR(255)
	DECLARE @NewName NVARCHAR(255)
	DECLARE @TableName NVARCHAR(255)
	DECLARE @SQL NVARCHAR(MAX)

	DECLARE ConstraintCursor CURSOR FOR
	SELECT 
    k.name AS OldPKName,
    t.name AS TableName	
	FROM sys.key_constraints AS k
	JOIN sys.tables AS t ON k.parent_object_id = t.object_id
	JOIN sys.schemas s on s.schema_id = t.schema_id
	WHERE s.name = 'dbo'
	and t.name <> 'sysdiagrams'
	and k.type = 'PK'

	OPEN ConstraintCursor

	FETCH NEXT FROM ConstraintCursor INTO @OldName, @TableName

	WHILE @@FETCH_STATUS = 0
	BEGIN
		SET @NewName = 'PK_' + @TableName
		SET @SQL = 'EXEC sp_rename ''' + @OldName + ''', ''' + @NewName + ''', ''OBJECT'''
    
		--PRINT @SQL -- Bu satır, her bir rename komutunu yazdırır
		EXEC sp_executesql @SQL

		FETCH NEXT FROM ConstraintCursor INTO @OldName, @TableName
	END

	CLOSE ConstraintCursor
	DEALLOCATE ConstraintCursor
