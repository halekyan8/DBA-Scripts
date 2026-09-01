# Metadata Management SQL Scripts

This folder contains SQL scripts for building and operating the database and table metadata collection system.

## Execution Order

To ensure proper setup, execute the scripts in the following order:

---

### DDL Scripts 

Run these first to create the required metadata tables:

```sql
ddl-database-metadata.sql
ddl-table-metadata.sql
```

These scripts:

* Create database-level metadata tables
* Create table-level metadata tables
* Define schema required for storing asset information

---

### Stored Procedures 

After the DDL scripts are successfully executed, run the stored procedures:

```sql
sp-get-asset-info-databases.sql
sp-get-asset-info-tables.sql
```

These procedures:

* Extract and populate metadata for databases
* Extract and populate metadata for tables
* Serve as the core logic for metadata ingestion

---

## Suggested Workflow

1. Execute DDL scripts once (initial setup)
2. Create stored procedures
3. Create SQLAgent Job(s) for metadata refresh

---

## File Overview

| File Name                      | Type             | Purpose                   |
| ------------------------------ | ---------------- | ------------------------- |
| `ddl-database-metadata.sql`       | DDL              | Database metadata tables             |
| `ddl-table-metadata.sql`          | DDL              | Table metadata tables                |
| `sp-get-asset-info-databases.sql` | Stored procedure | Collects database metadata           |
| `sp-get-asset-info-tables.sql`    | Stored procedure | Collects table metadata              |
| `db-inventory-detailed.sql`       | Query            | Returns detailed database inventory. |

---
