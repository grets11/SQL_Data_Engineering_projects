--Count rows, aggregation only
SELECT 
COUNT(*)
FROM job_postings_fact;

--Count rows, window functions
SELECT 
    job_id,
    COUNT(*) OVER()
FROM job_postings_fact;

SELECT 
    job_id,
    job_title_short,
    salary_hour_avg,
    AVG(salary_hour_avg) OVER() --average of all salary_hour_avg
FROM job_postings_fact;

SELECT 
    job_id,
    job_title_short,
    salary_hour_avg,
    AVG(salary_hour_avg) OVER(PARTITION BY job_title_short)
FROM job_postings_fact;

SELECT 
    job_id,
    job_title_short,
    company_id,
    salary_hour_avg,
    AVG(salary_hour_avg) OVER(PARTITION BY job_title_short, company_id)
FROM job_postings_fact
WHERE salary_hour_avg IS NOT NULL
LIMIT 10;

--Order by, ranking hourly salary
SELECT 
    job_id,
    job_title_short,
    salary_hour_avg,
    RANK() OVER(ORDER BY salary_hour_avg DESC) AS rank_hourly_salary
FROM job_postings_fact
WHERE salary_hour_avg IS NOT NULL
--ORDER BY salary_hour_avg DESC
LIMIT 10;

SELECT 
    job_posted_date,
    job_title_short,
    salary_hour_avg,
    AVG(salary_hour_avg) OVER(
        PARTITION BY job_title_short 
        ORDER BY job_posted_date
    )AS running_avg_hourly_by_title
FROM job_postings_fact
WHERE salary_hour_avg IS NOT NULL 
    AND job_title_short = 'Data Engineer'
ORDER BY job_title_short, job_posted_date
LIMIT 10;

/*
┌─────────────────────┬─────────────────┬─────────────────┬─────────────────────────────┐
│   job_posted_date   │ job_title_short │ salary_hour_avg │ running_avg_hourly_by_title │
│      timestamp      │     varchar     │     double      │           double            │
├─────────────────────┼─────────────────┼─────────────────┼─────────────────────────────┤
│ 2023-01-01 23:06:55 │ Data Engineer   │            64.5 │                        64.5 │
│ 2023-01-02 13:08:25 │ Data Engineer   │            25.5 │                        45.0 │
│ 2023-01-02 14:08:27 │ Data Engineer   │            70.0 │          53.333333333333336 │
│ 2023-01-02 14:49:19 │ Data Engineer   │            28.5 │                      47.125 │
│ 2023-01-02 15:07:38 │ Data Engineer   │            62.5 │                        50.2 │
│ 2023-01-03 16:38:29 │ Data Engineer   │            62.5 │                       52.25 │
│ 2023-01-03 16:38:52 │ Data Engineer   │            65.0 │           54.07142857142857 │
│ 2023-01-03 23:33:27 │ Data Engineer   │            24.0 │                     50.3125 │
│ 2023-01-03 23:39:47 │ Data Engineer   │            24.0 │          47.388888888888886 │
│ 2023-01-03 23:51:05 │ Data Engineer   │            20.0 │                       44.65 │
└─────────────────────┴─────────────────┴─────────────────┴─────────────────────────────┘
*/

SELECT 
    job_id,
    job_title_short,
    salary_hour_avg,
    RANK() OVER(
        PARTITION BY job_title_short
        ORDER BY salary_hour_avg DESC
    ) AS rank_hourly_salary
FROM job_postings_fact
WHERE salary_hour_avg IS NOT NULL
ORDER BY salary_hour_avg DESC, job_title_short --order of these matter
LIMIT 10;

/*
┌─────────┬───────────────────────────┬─────────────────┬────────────────────┐
│ job_id  │      job_title_short      │ salary_hour_avg │ rank_hourly_salary │
│  int32  │          varchar          │     double      │       int64        │
├─────────┼───────────────────────────┼─────────────────┼────────────────────┤
│  256566 │ Data Analyst              │           391.0 │                  1 │
│ 1004296 │ Data Scientist            │           250.0 │                  1 │
│  110897 │ Data Analyst              │           242.5 │                  2 │
│  646328 │ Data Scientist            │           237.5 │                  2 │
│  210821 │ Data Scientist            │           225.0 │                  3 │
│ 1203880 │ Data Engineer             │           221.0 │                  1 │
│ 1056728 │ Machine Learning Engineer │           220.0 │                  1 │
│  193693 │ Data Analyst              │           210.0 │                  3 │
│  452720 │ Data Analyst              │           200.0 │                  4 │
│  835548 │ Data Scientist            │           200.0 │                  4 │
└─────────┴───────────────────────────┴─────────────────┴────────────────────┘
*/

SELECT 
    job_posted_date,
    job_title_short,
    salary_hour_avg,
    SUM(salary_hour_avg) OVER( --CUMILATIVELY SUMS salary
        PARTITION BY job_title_short 
        ORDER BY job_posted_date
    )AS running_avg_hourly_by_title
FROM job_postings_fact
WHERE salary_hour_avg IS NOT NULL 
    AND job_title_short = 'Data Engineer'
ORDER BY job_title_short, job_posted_date
LIMIT 10;

SELECT 
    job_posted_date,
    job_title_short,
    salary_hour_avg,
    MIN(salary_hour_avg) OVER(
        PARTITION BY job_title_short 
        ORDER BY job_posted_date
    )AS running_avg_hourly_by_title
FROM job_postings_fact
WHERE salary_hour_avg IS NOT NULL 
    AND job_title_short = 'Data Engineer'
ORDER BY job_title_short, job_posted_date
LIMIT 10;


SELECT 
    job_id,
    job_title_short,
    salary_hour_avg,
    RANK() OVER(ORDER BY salary_hour_avg DESC) AS rank_hourly_salary
FROM job_postings_fact
WHERE salary_hour_avg IS NOT NULL
ORDER BY salary_hour_avg DESC
LIMIT 140;

SELECT 
    job_id,
    job_title_short,
    salary_hour_avg,
    DENSE_RANK() OVER(ORDER BY salary_hour_avg DESC) AS rank_hourly_salary
FROM job_postings_fact
WHERE salary_hour_avg IS NOT NULL
ORDER BY salary_hour_avg DESC
LIMIT 140;

SELECT 
    job_id,
    job_title_short,
    salary_hour_avg,
    ROW_NUMBER() OVER(ORDER BY salary_hour_avg DESC) AS rank_hourly_salary
FROM job_postings_fact
WHERE salary_hour_avg IS NOT NULL
ORDER BY rank_hourly_salary
LIMIT 140;

SELECT 
    *,
    ROW_NUMBER() OVER(ORDER BY job_posted_date)
FROM job_postings_fact
ORDER BY job_posted_date
LIMIT 20;

--LAG()

SELECT
    job_id, 
    company_id,
    job_title,
    job_title_short,
    salary_year_avg,
    LAG(salary_year_avg) OVER(
            PARTITION BY company_id
            ORDER BY job_posted_date
    ) AS previous_posting_salary,
    salary_year_avg - LAG(salary_year_avg) OVER(
        PARTITION BY company_id 
        ORDER BY job_posted_date) AS salary_change
FROM 
    job_postings_fact
WHERE salary_year_avg IS NOT NULL
ORDER BY company_id, job_posted_date
LIMIT 60;
/*
┌─────────┬────────────┬──────────────────────────────────────┬───────────────────────┬─────────────────┬─────────────────────────┬───────────────┐
│ job_id  │ company_id │              job_title               │    job_title_short    │ salary_year_avg │ previous_posting_salary │ salary_change │
│  int32  │   int32    │               varchar                │        varchar        │     double      │         double          │    double     │
├─────────┼────────────┼──────────────────────────────────────┼───────────────────────┼─────────────────┼─────────────────────────┼───────────────┤
│  842003 │       4593 │ Data Scientist                       │ Data Scientist        │         75000.0 │                    NULL │          NULL │
│  995381 │       4593 │ Lead Data Engineer                   │ Data Engineer         │        150000.0 │                 75000.0 │       75000.0 │
│  128388 │       4594 │ Data Scientist                       │ Data Scientist        │         90000.0 │                    NULL │          NULL │
│  134272 │       4594 │ AI/ML Health Data Scientist - Senio… │ Senior Data Scientist │        112450.0 │                 90000.0 │       22450.0 │
│  143916 │       4594 │ Data Scientist                       │ Data Scientist        │         90000.0 │                112450.0 │      -22450.0 │
│  159423 │       4594 │ Data Scientist - Analyst             │ Data Scientist        │         90000.0 │                 90000.0 │           0.0 │
│  164436 │       4594 │ Data Scientist - Senior Consultant   │ Data Scientist        │         90000.0 │                 90000.0 │           0.0 │
│  167525 │       4594 │ AI/ML Health Data Scientist - Senio… │ Senior Data Scientist │        115000.0 │                 90000.0 │       25000.0 │
*/
--LEAD()

SELECT
    job_id, 
    company_id,
    job_title,
    job_title_short,
    salary_year_avg,
    LEAD(salary_year_avg) OVER(
            PARTITION BY company_id
            ORDER BY job_posted_date
    ) AS previous_posting_salary,
    salary_year_avg - LEAD(salary_year_avg) OVER(
        PARTITION BY company_id 
        ORDER BY job_posted_date) AS salary_change
FROM 
    job_postings_fact
WHERE salary_year_avg IS NOT NULL
ORDER BY company_id, job_posted_date
LIMIT 10;
/*
┌─────────┬────────────┬──────────────────────────────────────┬───────────────────────┬─────────────────┬─────────────────────────┬───────────────┐
│ job_id  │ company_id │              job_title               │    job_title_short    │ salary_year_avg │ previous_posting_salary │ salary_change │
│  int32  │   int32    │               varchar                │        varchar        │     double      │         double          │    double     │
├─────────┼────────────┼──────────────────────────────────────┼───────────────────────┼─────────────────┼─────────────────────────┼───────────────┤
│  842003 │       4593 │ Data Scientist                       │ Data Scientist        │         75000.0 │                150000.0 │      -75000.0 │
│  995381 │       4593 │ Lead Data Engineer                   │ Data Engineer         │        150000.0 │                    NULL │          NULL │
│  128388 │       4594 │ Data Scientist                       │ Data Scientist        │         90000.0 │                112450.0 │      -22450.0 │
│  134272 │       4594 │ AI/ML Health Data Scientist - Senio… │ Senior Data Scientist │        112450.0 │                 90000.0 │       22450.0 │
│  143916 │       4594 │ Data Scientist                       │ Data Scientist        │         90000.0 │                 90000.0 │           0.0 │
│  159423 │       4594 │ Data Scientist - Analyst             │ Data Scientist        │         90000.0 │                 90000.0 │           0.0 │
│  164436 │       4594 │ Data Scientist - Senior Consultant   │ Data Scientist        │         90000.0 │                115000.0 │      -25000.0 │
│  167525 │       4594 │ AI/ML Health Data Scientist - Senio… │ Senior Data Scientist │        115000.0 │                129050.0 │      -14050.0 │
│  179599 │       4594 │ Data Analyst - Business Intelligence │ Data Analyst          │        129050.0 │                115000.0 │       14050.0 │
│  235865 │       4594 │ Cleared Data Scientist               │ Data Scientist        │        115000.0 │                 90000.0 │       25000.0 │
*/