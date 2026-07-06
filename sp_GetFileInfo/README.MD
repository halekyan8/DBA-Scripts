# sp_GetFileInfo

`sp_GetFileInfo` collects data and log file size details across online user databases, including total size, used space, free space, free space percent, and physical path.

## Files

| Script | Target version | Notes |
| --- | --- | --- |
| `sp_GetFileInfo2016.sql` | SQL Server 2016 and earlier compatibility | Uses `LTRIM(RTRIM(...))` for whitespace cleanup. |
| `sp_GetFileInfo2022.sql` | SQL Server 2022 compatibility | Uses `TRIM(...)` for whitespace cleanup. |

## Version Differences

- SQL Server 2017 introduced the basic `TRIM()` function. Use `LTRIM(RTRIM(...))` when you need compatibility with SQL Server 2016 or earlier.
- `sp_GetFileInfo2022.sql` uses `CREATE OR ALTER PROCEDURE`, which is available in modern SQL Server versions.
- `sp_GetFileInfo2016.sql` uses `CREATE PROCEDURE` plus `SET ANSI_NULLS` and `SET QUOTED_IDENTIFIER` statements for older-version compatibility.
- Both versions use `STRING_SPLIT` for comma-separated drive and file-type filters. Confirm compatibility level and availability before running in older environments.

## Parameters

| Parameter | Purpose | Example |
| --- | --- | --- |
| `@disk_name` | Optional comma-separated drive-letter filter. Pass letters only, without colon. | `'D,E'` |
| `@file_type` | Optional file type filter. Supports `r` or `ROWS` for data files, and `l` or `LOG` for log files. | `'r'` |

## Examples

```sql
EXEC dbo.sp_GetFileInfo;
EXEC dbo.sp_GetFileInfo @disk_name = 'D,E';
EXEC dbo.sp_GetFileInfo @file_type = 'LOG';
EXEC dbo.sp_GetFileInfo @disk_name = 'L', @file_type = 'l';
```

## Before Running

- Review the target database name in the script. The current scripts use `DBAMonitor`.
- Run the version that matches the oldest SQL Server version or compatibility requirement in the target environment.
- Test in a non-production environment before deploying to production.
