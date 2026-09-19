SELECT
    jpf.*,
    cd.*
FROM job_postings_fact AS jpf
LEFT JOIN company_dim AS cd
    ON jpf.company_id= cd.company_id
LIMIT 10;

SELECT
    jpf.job_id,
    jpf.job_title_short,
    cd.company_id,
    cd.name AS company_name,
    jpf.job_location
FROM job_postings_fact AS jpf
LEFT JOIN company_dim AS cd
    ON jpf.company_id= cd.company_id
LIMIT 10;

SELECT *
FROM skills_dim
LIMIT 10;

SELECT *
FROM skills_job_dim
LIMIT 10;

SELECT 
    jpf.job_id,
    jpf.job_title_short,
    sjd.skill_id,
    sd.skills
FROM job_postings_fact AS jpf
LEFT JOIN skills_job_dim AS sjd
    ON jpf.job_id = sjd.job_id
LEFT JOIN skills_dim AS sd
    ON sjd.skill_id = sd.skill_id
LIMIT 10;

SELECT 
    cd.name AS company_name,
    COUNT(jpf.*) AS posting_count
FROM job_postings_fact AS jpf
LEFT JOIN company_dim AS cd
    ON jpf.company_id= cd.company_id
WHERE jpf.job_country = 'United States'
GROUP BY cd.name;

EXPLAIN ANALYZE
SELECT 
    cd.name AS company_name,
    COUNT(jpf.job_id) AS posting_count
FROM job_postings_fact AS jpf
LEFT JOIN company_dim AS cd
    ON jpf.company_id= cd.company_id
WHERE jpf.job_country = 'United States'
GROUP BY cd.name
HAVING COUNT(jpf.job_id) > 3000
ORDER BY posting_count DESC;
