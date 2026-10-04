--Bucket salaries

SELECT 
    job_title_short,
    salary_hour_avg,
    CASE 
        WHEN salary_hour_avg < 25 THEN 'low'
        WHEN salary_hour_avg < 50 THEN 'medium'
        ELSE 'high'
    END AS salary_category
FROM job_postings_fact
WHERE salary_hour_avg IS NOT NULL
LIMIT 10;

--Handling Missing Data

SELECT 
    job_title_short,
    salary_hour_avg,
    CASE 
        WHEN salary_hour_avg IS NULL THEN 'missing'
        WHEN salary_hour_avg < 25 THEN 'low'
        WHEN salary_hour_avg < 50 THEN 'medium'
        ELSE 'high'
    END AS salary_category
FROM job_postings_fact
LIMIT 10;

--Categorizing Categorical Values

SELECT 
    job_title,
    CASE 
        WHEN job_title LIKE '%Data%' AND job_title LIKE '%Analyst%' THEN 'Data Analyst'
        WHEN job_title LIKE '%Data%' AND job_title LIKE '%Engineer%' THEN 'Data Engineer'
        WHEN job_title LIKE '%Data%' AND job_title LIKE '%Scientist%' THEN 'Data Scientist'
        ELSE 'Other'
    END AS job_title_category,
    job_title_short
FROM job_postings_fact
ORDER BY RANDOM()
LIMIT 10;

--Conditional Aggregation

SELECT 
    job_title_short,
    COUNT(*) AS total_postings,
    MEDIAN(
        CASE 
            WHEN salary_year_avg < 100_000 THEN salary_year_avg
            --ELSE NULL
        END
    ) AS median_low_salary,
    MEDIAN(
        CASE 
            WHEN salary_year_avg >= 100_000 THEN salary_year_avg
            --ELSE NULL
        END
    ) AS median_high_salary
FROM job_postings_fact
WHERE salary_year_avg IS NOT NULL
GROUP BY job_title_short;

--Conditional Calculations

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