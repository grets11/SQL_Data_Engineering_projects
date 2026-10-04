-- subquery:
SELECT *
FROM (
    SELECT *
    FROM job_postings_fact
    WHERE salary_year_avg IS NOT NULL
        OR salary_hour_avg IS NOT NULL
)
LIMIT 10;

--CTE
WITH valid_salaries AS(
    SELECT *
    FROM job_postings_fact
    WHERE salary_year_avg IS NOT NULL
        OR salary_hour_avg IS NOT NULL
)
SELECT *
FROM valid_salaries;

--1 subquery in select: show each job's salary next to overall market median
SELECT 
    job_title_short,
    salary_year_avg,
    (
    SELECT MEDIAN(salary_year_avg)
    FROM job_postings_fact 
    ) AS market_median_salary
FROM job_postings_fact
WHERE salary_year_avg IS NOT NULL
LIMIT 10;

--2 subquery in from: stage only jobs that are remote before aggregating to determine the remote median salary per job
SELECT 
    job_title_short,
    MEDIAN(salary_year_avg)AS median_salary,--aggregated by each job_title_short
    (
    SELECT MEDIAN(salary_year_avg) --not grouped by, but overall median across whole market
    FROM job_postings_fact 
    WHERE job_work_from_home = TRUE
    ) AS market_remote_median_salary
FROM (
    SELECT job_title_short, salary_year_avg
    FROM job_postings_fact
    WHERE job_work_from_home = TRUE
) AS clean_jobs
GROUP BY job_title_short
LIMIT 10;

DESCRIBE
SELECT *
FROM job_postings_fact
LIMIT 10;

--3: subquery in having. keep only job titles whose median salary is above the overall median
SELECT 
    job_title_short,
    MEDIAN(salary_year_avg)AS median_salary,--aggregated by each job_title_short
    (
    SELECT MEDIAN(salary_year_avg) --not grouped by, but overall median across whole market
    FROM job_postings_fact 
    WHERE job_work_from_home = TRUE
    ) AS market_remote_median_salary
FROM (
    SELECT job_title_short, salary_year_avg
    FROM job_postings_fact
    WHERE job_work_from_home = TRUE
) AS clean_jobs
GROUP BY job_title_short
HAVING MEDIAN(salary_year_avg) > (
    SELECT MEDIAN(salary_year_avg) --not grouped by, but overall median across whole market
    FROM job_postings_fact 
    WHERE job_work_from_home = TRUE
)
LIMIT 10;

--4 CTE Example
--Compare how much more (or less) remote roles pay compared to onsite roles for each job title.
--Use a CTE to calculate the median salary by title and work arrangement, then compare those medians

WITH title_median AS(
    SELECT 
        job_title_short,
        job_work_from_home,
        MEDIAN(salary_year_avg)::INT AS median_salary
    FROM job_postings_fact
    WHERE job_country = 'United States'
    GROUP BY 
        job_title_short,
        job_work_from_home
)
SELECT 
    r.job_title_short,
    r.median_salary AS remote_median_salary,
    o.median_salary AS onsite_median_salary,
    (r.median_salary - o.median_salary) AS remote_premium
FROM title_median AS r
INNER JOIN title_median AS o
    ON o.job_title_short=r.job_title_short
WHERE r.job_work_from_home = TRUE 
    AND o.job_work_from_home=FALSE
ORDER BY remote_premium DESC;


SELECT *
FROM range(3) AS src(key);

SELECT *
FROM range(2) AS trg(key);

SELECT *
FROM range(3) AS src(key)
WHERE EXISTS(
    SELECT 1
    FROM range(2) AS trg(key)
    WHERE trg.key = src.key
);

SELECT *
FROM range(3) AS src(key)
WHERE NOT EXISTS(
    SELECT 1
    FROM range(2) AS trg(key)
    WHERE trg.key = src.key
);


--Final Example
--Identify job postings that have no associated skills before loading them into a data mart
SELECT *
FROM job_postings_fact
ORDER BY job_id
LIMIT 10;

SELECT *
FROM skills_job_dim
ORDER BY job_id
LIMIT 40;

SELECT *
FROM job_postings_fact as tgt
WHERE NOT EXISTS(
    SELECT 1
    FROM skills_job_dim AS src
    WHERE tgt.job_id = src.job_id
)
ORDER BY job_id;

SELECT *
FROM job_postings_fact as tgt
WHERE EXISTS(
    SELECT 1
    FROM skills_job_dim AS src
    WHERE tgt.job_id = src.job_id
)
ORDER BY job_id;