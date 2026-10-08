--duckdb dw_marts.duckdb -c ".read build_dw_marts.sql"

.read 01_Create_Tables_.sql

.read 02_load_schema.sql