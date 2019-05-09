USE SPI
GO

BEGIN TRANSACTION

SET NOCOUNT ON;

DECLARE @spName VARCHAR(150)
DECLARE @spTable TABLE(sp_def NVARCHAR(MAX))
DECLARE @spNewDef NVARCHAR(MAX)
DECLARE @TotalPrints INT
DECLARE @Counter INT

DECLARE sp_cur CURSOR 
	FOR SELECT o.name --, m.definition [old_definition]
				  --, REPLACE(m.definition, 'SPE_', 'SPI_') [new_definition]
          FROM sys.all_sql_modules m 
	INNER JOIN sys.objects o on m.object_id = o.object_id
	     WHERE m.definition like '%SPE_%'
		    
OPEN sp_cur

FETCH NEXT FROM sp_cur
INTO @spName

WHILE @@FETCH_STATUS = 0
BEGIN
	
	PRINT '-- Name: ' + @spName
	PRINT '------------------------------------'

	INSERT INTO @spTable	
	EXECUTE sp_helptext @spName

	SELECT @spNewDef = ''

	UPDATE @spTable SET sp_def = REPLACE(REPLACE(sp_def, 'SPE_', 'SPI_'), 'CREATE', 'ALTER') 

	SELECT @spNewDef = @spNewDef + sp_def FROM @spTable

	PRINT '-- Proc [' + @spName + '] Length [' + CAST(LEN(@spNewDef) AS VARCHAR(18)) + ']'

	SET @TotalPrints = ((LEN(@spNewDef) / 4000) + 1) 

	PRINT '-- Total Prints: ' + CAST(@TotalPrints AS VARCHAR(10))

	SET @Counter = 0
	PRINT 'GO'

	IF @TotalPrints > 1
	BEGIN
		WHILE @Counter < @TotalPrints
		BEGIN
			--PRINT '-- TotalPrint > 1 - Counter = [' + CAST(@Counter AS VARCHAR(10)) + ']'
			--PRINT '-- Copying string from : [' + CAST(@Counter * 4000 as VARCHAR(10)) + '] to [' + CAST((@Counter + 1) * 4000 as VARCHAR(10)) + ']'
			PRINT CAST(SUBSTRING(@spNewDef, @Counter * 4000, (@Counter + 1) * 4000) AS NVARCHAR(MAX))
			SET @Counter = @Counter + 1
		END
	END
	ELSE
	BEGIN
		PRINT CAST(@spNewDef AS NTEXT)
	END
	
	
	--EXECUTE @spNewDef

	DELETE FROM @spTable

	FETCH NEXT FROM sp_cur 
	INTO @spName
END

CLOSE sp_cur
DEALLOCATE sp_cur

ROLLBACK


