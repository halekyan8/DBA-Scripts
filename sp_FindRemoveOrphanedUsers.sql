USE DBAMonitor
GO

CREATE OR ALTER PROCEDURE dbo.sp_FindDeleteOrphanedUsers
    @Delete BIT = 0
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @db_name SYSNAME;
    DECLARE @user_name SYSNAME;
    DECLARE @SQL NVARCHAR(MAX);

    IF OBJECT_ID('tempdb..#LoginUserMap') IS NOT NULL 
        DROP TABLE #LoginUserMap;

    CREATE TABLE #LoginUserMap (
        database_name   SYSNAME,
        user_name       SYSNAME,
        mapped_login    SYSNAME NULL,
        is_orphaned     BIT
    );

    EXEC sp_MSforeachdb '
    USE [?];
    IF ''?'' NOT IN (''tempdb'')
    BEGIN
        INSERT INTO #LoginUserMap 
            (database_name, user_name, mapped_login, is_orphaned)
        SELECT 
            DB_NAME(),
            dp.name,
            sp.name,
            CASE 
                WHEN sp.sid IS NULL 
                     AND dp.type IN (''S'',''U'') 
                THEN 1 
                ELSE 0 
            END
        FROM sys.database_principals dp
        LEFT JOIN sys.server_principals sp 
            ON dp.sid = sp.sid
        WHERE dp.type IN (''S'',''U'',''G'')
          AND dp.name NOT IN 
              (''dbo'',''guest'',''INFORMATION_SCHEMA'',''sys'')
          AND dp.name NOT LIKE ''MS_%'' 
          AND dp.name NOT LIKE ''##%''
    END
    ';

    IF @Delete = 0
    BEGIN
        PRINT 'Delete parameter is set to 0 (Show only).';
        PRINT 'To delete orphaned users, execute:';
        PRINT 'EXEC dbo.sp_FindDeleteOrphanedUsers @Delete = 1;';
        PRINT '';
    END
    ELSE
    BEGIN
        PRINT 'Delete parameter is set to 1.';
        PRINT 'Orphaned users will be deleted.';
        PRINT '';
    END;

    SELECT *
    FROM #LoginUserMap
    WHERE is_orphaned = 1;

    DECLARE orphan_cursor CURSOR FOR
    SELECT database_name, user_name 
    FROM #LoginUserMap 
    WHERE is_orphaned = 1
    ORDER BY database_name, user_name;

    OPEN orphan_cursor;

    FETCH NEXT FROM orphan_cursor
    INTO @db_name, @user_name;

    WHILE @@FETCH_STATUS = 0
    BEGIN

        SET @SQL = 
            'USE [' + REPLACE(@db_name, ']', ']]') + ']; ';

        IF @Delete = 1
        BEGIN
            SET @SQL = @SQL +
                'BEGIN TRY
                    DROP USER IF EXISTS [' 
                    + REPLACE(@user_name, ']', ']]') + '];

                    PRINT ''[DELETED] User: [' 
                    + REPLACE(@user_name, ']', ']]') 
                    + '] | Database: [' 
                    + REPLACE(@db_name, ']', ']]') + ']'';
                END TRY
                BEGIN CATCH
                    PRINT ''[FAILED] User: [' 
                    + REPLACE(@user_name, ']', ']]') 
                    + '] | Database: [' 
                    + REPLACE(@db_name, ']', ']]') + ']'';

                    PRINT ''Error: '' + ERROR_MESSAGE();
                END CATCH;';

            EXEC sp_executesql @SQL;
        END
        ELSE
        BEGIN
            SET @SQL = @SQL +
                'PRINT ''[WOULD DELETE] User: [' 
                + REPLACE(@user_name, ']', ']]') 
                + '] | Database: [' 
                + REPLACE(@db_name, ']', ']]') + ']';

            PRINT @SQL;
        END;

        FETCH NEXT FROM orphan_cursor
        INTO @db_name, @user_name;
    END

    CLOSE orphan_cursor;
    DEALLOCATE orphan_cursor;

    DROP TABLE #LoginUserMap;
END;
GO