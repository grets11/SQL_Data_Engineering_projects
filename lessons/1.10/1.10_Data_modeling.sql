SELECT *
FROM company_dim
WHERE name IN('Facebook', 'Meta');

SELECT *
FROM information_schema.tables;

SELECT *
FROM information_schema.tables
WHERE table_catalog = 'data_jobs';

SELECT *
FROM information_schema.columns
WHERE table_catalog = 'data_jobs';

SELECT *
FROM information_schema.table_constraints
WHERE table_catalog = 'data_jobs';

PRAGMA show_tables;

PRAGMA show_tables_expanded;

DESCRIBE job_postings_fact;

SELECT table_name, column_name, data_type
FROM information_schema.columns
WHERE table_catalog='data_jobs';

SELECT *
FROM information_schema.table_constraints
WHERE table_catalog = 'data_jobs'; --changes just to check git