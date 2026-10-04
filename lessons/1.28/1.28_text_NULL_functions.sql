SELECT LENGTH('SQL');
--same function:
SELECT CHAR_LENGTH('SQL');

SELECT UPPER('sql');

SELECT LOWER('SQL');

SELECT LEFT('SQL',2);

SELECT RIGHT('SQL',2);

SELECT SUBSTRING('SQL',2,2); --starting from 2nd char, and 2 char to extract

SELECT SUBSTRING('SQL',2,1); --starting from 2nd char, and 1 char to extract

SELECT CONCAT('SQL' ,'-' ,'Functions');
SELECT 'SQL' ||'-'|| 'Functions';

SELECT TRIM(' SQL ');
SELECT LTRIM(' SQL ');
SELECT RTRIM(' SQL ');

SELECT REPLACE('SQL','Q', '_');

SELECT REGEXP_REPLACE('azhar@gmail.com','^.*(@)', '\1'); --extracts email domain


WITH title_lower AS(
    SELECT 
        job_title,
        LOWER(TRIM(job_title)) AS job_title_clean
    FROM job_postings_fact
)
SELECT 
    job_title,
    CASE 
        WHEN job_title_clean LIKE '%data%' AND job_title_clean LIKE '%analyst%' THEN 'Data Analyst'
        WHEN job_title_clean LIKE '%data%' AND job_title_clean LIKE '%engineer%' THEN 'Data Engineer'
        WHEN job_title_clean LIKE '%data%' AND job_title_clean LIKE '%scientist%' THEN 'Data Scientist'
        ELSE 'Other'
    END AS job_title_category
FROM title_lower
ORDER BY RANDOM()
LIMIT 30;

--NULL FUNCTIONS:

SELECT NULLIF(10,10);
SELECT NULLIF(10,20);

SELECT 
    NULLIF(salary_year_avg,0),
    NULLIF(salary_hour_avg,0)
FROM job_postings_fact
WHERE salary_hour_avg IS NOT NULL OR salary_year_avg IS NOT NULL
LIMIT 10;

SELECT 
    MEDIAN(NULLIF(salary_year_avg,0)),
    MEDIAN(NULLIF(salary_hour_avg,0))
FROM job_postings_fact
WHERE salary_hour_avg IS NOT NULL OR salary_year_avg IS NOT NULL
LIMIT 10;

SELECT COALESCE(0,1,2);
SELECT COALESCE(NULL,1,2);
SELECT COALESCE(NULL, NULL, 2);

SELECT 
    salary_year_avg,
    salary_hour_avg,
    COALESCE(salary_year_avg,salary_hour_avg* 2080) --can list 3rd expression to replace to
FROM job_postings_fact
WHERE salary_hour_avg IS NOT NULL OR salary_year_avg IS NOT NULL
LIMIT 10;


--from 1.25 final example, we can simplify it using coalesce
WITH salaries AS(
    SELECT 
        job_title_short,
        salary_hour_avg,
        salary_year_avg,
        CASE
            WHEN salary_year_avg IS NOT NULL THEN salary_year_avg
            WHEN salary_hour_avg IS NOT NULL THEN salary_hour_avg*2080 --2080 working hours in the year
            --ELSE NULL
        END AS standardized_salary
    FROM job_postings_fact
    --WHERE salary_year_avg IS NOT NULL OR salary_hour_avg IS NOT NULL
)
SELECT 
    *,
    CASE 
        WHEN standardized_salary IS NULL THEN 'missing'
        WHEN standardized_salary < 75_000 THEN 'low'
        WHEN standardized_salary < 150_000 THEN 'medium'
        ELSE 'high'
    END AS salary_bucket
FROM salaries
ORDER BY standardized_salary DESC
LIMIT 10;

--into:
SELECT 
    job_title_short,
    salary_hour_avg,
    salary_year_avg,
    COALESCE(salary_year_avg,salary_hour_avg* 2080) standardized_salary,
    CASE 
        WHEN  COALESCE(salary_year_avg,salary_hour_avg* 2080) IS NULL THEN 'missing'
        WHEN  COALESCE(salary_year_avg,salary_hour_avg* 2080) < 75_000 THEN 'low'
        WHEN  COALESCE(salary_year_avg,salary_hour_avg* 2080) < 150_000 THEN 'medium'
        ELSE 'high'
    END AS salary_bucket
FROM job_postings_fact
ORDER BY standardized_salary DESC
LIMIT 10;