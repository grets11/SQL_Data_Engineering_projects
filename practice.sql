--1. Count postings by job_title_short, descending.

SELECT job_title_short, COUNT(*) postings
FROM job_postings_fact
GROUP BY 1
ORDER BY postings DESC;

--2. Postings per month (use job_posted_date). Which month was busiest?
SELECT 
    DATE_TRUNC('month', job_posted_date)::DATE AS date,
    COUNT(*) AS postings
FROM job_postings_fact
GROUP BY 1
ORDER BY postings DESC;

--3. For job_title_short = 'Data Analyst': total postings, how many are remote (job_work_from_home),
-- how many mention no degree, and the remote share as a percentage. One row.

--with FILTER
SELECT COUNT(*)                                          AS postings,
       COUNT(*) FILTER (WHERE job_work_from_home)        AS remote_count,
       COUNT(*) FILTER (WHERE job_no_degree_mention)     AS no_degree_count,
       ROUND(100.0 * COUNT(*) FILTER (WHERE job_work_from_home) / COUNT(*), 1) AS pct_remote
FROM job_postings_fact
WHERE job_title_short = 'Data Analyst';

--WITH CASE , COUNT
SELECT COUNT(*)                                                       AS postings,
       COUNT(CASE WHEN job_work_from_home THEN 1 END)                 AS remote_count,
       COUNT(CASE WHEN job_no_degree_mention THEN 1 END)              AS no_degree_count,
       ROUND(100.0 * COUNT(CASE WHEN job_work_from_home THEN 1 END)
                   / COUNT(*), 1)                                     AS pct_remote
FROM job_postings_fact
WHERE job_title_short = 'Data Analyst'

--WITH CASE , SUM
SELECT COUNT(*)                                                    AS postings,
       SUM(CASE WHEN job_work_from_home THEN 1 ELSE 0 END)         AS remote_count,
       SUM(CASE WHEN job_no_degree_mention THEN 1 ELSE 0 END)      AS no_degree_count,
       ROUND(100.0 * SUM(CASE WHEN job_work_from_home THEN 1 ELSE 0 END)
                   / COUNT(*), 1)                                  AS pct_remote
FROM job_postings_fact
WHERE job_title_short = 'Data Analyst'

--4. Top 10 job_country by postings, with each country's share of all postings.
SELECT 
    job_country,
    COUNT(*) AS postings,
    ROUND(100* COUNT(*)/SUM(COUNT(*)) OVER(),1)AS percentage --IMPORTANT 
FROM job_postings_fact
GROUP BY 1
ORDER BY postings DESC
LIMIT 10;

--5. How many postings have a non-null salary_year_avg? What percentage of all postings is that? One row, two numbers.

SELECT COUNT(salary_year_avg) FILTER(WHERE salary_year_avg IS NOT NULL), --NOT CORRECT. COUNT() ALREADY SKIPS NULLS
 100 * COUNT(salary_year_avg) FILTER(WHERE salary_year_avg IS NOT NULL)/ COUNT(*)
FROM job_postings_fact;

--CORRECT:
SELECT COUNT(*)                                            AS all_postings,
       COUNT(salary_year_avg)                              AS with_salary,
       ROUND(100.0 * COUNT(salary_year_avg) / COUNT(*), 2) AS pct_with_salary
FROM job_postings_fact;

--6. Average and median salary_year_avg by job_title_short, 
--only for titles with at least 100 salaried postings. Order by median descending.

SELECT job_title_short,
    AVG(salary_year_avg) AS avg,
    MEDIAN(salary_year_avg) AS median
FROM job_postings_fact
GROUP BY 1
HAVING COUNT(salary_year_avg) >= 100 --COUNT(salary_year_avg) not COUNT(*)
ORDER BY median DESC;

--8. Top 10 skills by number of postings requiring them. Join skills_job_dim → skills_dim.

SELECT s.skills,
COUNT(DISTINCT sj.job_id) as job_count 
FROM skills_dim s
LEFT JOIN skills_job_dim sj 
    ON sj.skill_id = s.skill_id
GROUP BY s.skills
ORDER BY job_count DESC
LIMIT 10;

--9. Same, but only for job_title_short = 'Data Engineer', and show each skill's share of Data Engineer postings.
WITH de AS (
    SELECT job_id FROM job_postings_fact WHERE job_title_short = 'Data Engineer'
) -- it was in CTE, because after this, we have to groupby skills only.. and job_id had to be Data Engineers 
SELECT s.skills,
       COUNT(DISTINCT sj.job_id) AS postings, 
       ROUND(100.0 * COUNT(DISTINCT sj.job_id) / (SELECT COUNT(*) FROM de), 1) AS pct_of_de_postings 
       --SELECT COUNT(*) FROM de is numbers of job_ids which are "Data engineers"
FROM de
JOIN skills_job_dim sj USING (job_id)
JOIN skills_dim s      USING (skill_id)
GROUP BY 1
ORDER BY postings DESC
LIMIT 10;


--10. Top 5 companies by number of postings, with their average salary_year_avg. Join to company_dim.

SELECT 
    c.name AS company_name, 
    AVG(j.salary_year_avg) as average_salary,
    COUNT(*) AS postings
FROM job_postings_fact j
JOIN company_dim c 
    ON c.company_id=j.company_id
GROUP BY 1
ORDER BY postings DESC
LIMIT 5;

--11. For each job_title_short, the top 3 skills by posting count, with rank.

WITH skill_counts AS (SELECT 
    j.job_title_short,
    s.skills,
    COUNT(DISTINCT j.job_id) AS postings, 
FROM job_postings_fact j
LEFT JOIN skills_job_dim sj ON sj.job_id=j.job_id
LEFT JOIN skills_dim s ON s.skill_id=sj.skill_id
GROUP BY 1,2),
ranked AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY job_title_short ORDER BY postings DESC) AS rn
    FROM skill_counts
)
SELECT job_title_short, skills, postings, rn
FROM ranked
WHERE rn <= 3
ORDER BY job_title_short, rn;

--12. Monthly postings for Data Analyst with a 3-month moving average and month-over-month percent change

WITH monthly AS(--NOT CORRECT
    SELECT 
        DATE_TRUNC('month', job_posted_date)::DATE AS date, 
        COUNT(*) AS postings
    FROM job_postings_fact
    WHERE job_title_short = 'Data Analyst'
    GROUP BY 1
)
SELECT 
    date, 
    postings, 
    ROUND(AVG(postings) OVER(ORDER BY date ROWS BETWEEN 2 PRECEDING AND CURRENT ROW),1) AS average_postings_by3,
    ROUND(100* postings/SUM(postings)OVER(ORDER BY date),1) as percentage --The numerator grows. The denominator grows faster — 
    --because the denominator keeps adding every month that came before. February's denominator is Jan+Feb. March's is Jan+Feb+Mar.
FROM monthly;

WITH monthly AS (
    SELECT DATE_TRUNC('month', job_posted_date)::DATE AS month,
           COUNT(*)                                   AS postings
    FROM job_postings_fact
    WHERE job_title_short = 'Data Analyst'
    GROUP BY 1
)
SELECT month,
       postings,
       ROUND(AVG(postings) OVER (ORDER BY month ROWS BETWEEN 2 PRECEDING AND CURRENT ROW), 1) AS ma3,
       ROUND(100.0 * (postings - LAG(postings) OVER (ORDER BY month)) 
                   / LAG(postings) OVER (ORDER BY month), 1) AS mom_pct --month-over-month change:
                   --(this month − last month) ÷ last month
FROM monthly
ORDER BY month;

--13. For each skill, its share of postings in the first half of the year vs the second half, and the change in share.
-- Which skills grew, which shrank?

WITH halves AS (
    SELECT s.skills,
           COUNT(*) FILTER (WHERE j.job_posted_date <  DATE '2023-07-01') AS h1,
           COUNT(*) FILTER (WHERE j.job_posted_date >= DATE '2023-07-01') AS h2
    FROM job_postings_fact j
    JOIN skills_job_dim sj USING (job_id)
    JOIN skills_dim s      USING (skill_id)
    GROUP BY 1
)
SELECT skills, h1, h2,
       ROUND(100.0 * h1 / SUM(h1) OVER (), 2)                                  AS h1_share_pct,
       ROUND(100.0 * h2 / SUM(h2) OVER (), 2)                                  AS h2_share_pct,
       ROUND(100.0 * h2 / SUM(h2) OVER () - 100.0 * h1 / SUM(h1) OVER (), 2)   AS change_pp
FROM halves
WHERE h1 + h2 >= 1000
ORDER BY change_pp DESC;


--14. Rank countries by median Data Analyst salary, but only countries with at least 50 salaried Data Analyst postings.
-- Show rank, median, and the count.

WITH salary_by_country AS (
SELECT 
    job_country,
    COUNT(salary_year_avg) AS postings,
    MEDIAN(salary_year_avg) as median_salary
FROM job_postings_fact
WHERE job_title_short ='Data Analyst'
GROUP BY 1
HAVING COUNT(salary_year_avg) >=50)
SELECT 
    job_country, 
    median_salary,
    postings,
    RANK() OVER(ORDER BY median_salary DESC) AS rank
FROM salary_by_country;


--A1. Per job_title_short: postings, remote postings, and remote rate. State the denominator before you write.

SELECT 
    job_title_short,
    COUNT(*) AS postings,
    COUNT(job_work_from_home) FILTER (WHERE job_work_from_home = TRUE) AS remote,
    ROUND(100* COUNT(job_work_from_home)FILTER (WHERE job_work_from_home = TRUE)/COUNT(*),1) AS remote_rate
FROM job_postings_fact
GROUP BY 1;

--OR:
SELECT job_title_short,
       COUNT(*)                                       AS postings,
       COUNT(*) FILTER (WHERE job_work_from_home)     AS remote,
       ROUND(100.0 * COUNT(*) FILTER (WHERE job_work_from_home) / COUNT(*), 1) AS remote_rate
FROM job_postings_fact
GROUP BY 1
ORDER BY postings DESC;


--A2. Per job_country: postings, salaried postings, median salary — only countries with at least 100 salaried postings. Show the count you filtered on.

SELECT 
    job_country,
    COUNT(*) AS postings, 
    COUNT(salary_year_avg) AS salaried_postings, 
    MEDIAN(salary_year_avg) AS median
FROM job_postings_fact
GROUP BY job_country
HAVING COUNT(salary_year_avg)>= 100
ORDER BY salaried_postings DESC;


--A3. Per month: total postings, remote postings, and remote share of that month.

SELECT 
    DATE_TRUNC('month', job_posted_date):: DATE as month,
    COUNT(*) AS postings,
    COUNT(*) FILTER(WHERE job_work_from_home) AS remote_postings,
    ROUND (100* COUNT(*) FILTER(WHERE job_work_from_home)/COUNT(*), 1) AS remote_percent
FROM job_postings_fact
GROUP BY 1
ORDER BY month;


--B1. For the top 5 titles by volume, the top 5 skills each, with each skill's share of that title's postings.
--HARD ONE!!!!!!

WITH title_totals AS (
    SELECT job_title_short, COUNT(*) AS title_postings
    FROM job_postings_fact
    GROUP BY 1
    ORDER BY title_postings DESC
    LIMIT 5                                     -- the top-5-titles step
),
skill_counts AS (
    SELECT j.job_title_short,
           s.skills,
           COUNT(DISTINCT j.job_id) AS skill_postings
    FROM job_postings_fact j
    JOIN title_totals      USING (job_title_short)   -- restricts to those 5 titles
    JOIN skills_job_dim sj USING (job_id)
    JOIN skills_dim s      USING (skill_id)
    GROUP BY 1, 2
)
SELECT sc.job_title_short,
       sc.skills,
       sc.skill_postings,
       tt.title_postings,
       ROUND(100.0 * sc.skill_postings / tt.title_postings, 1) AS pct_of_title
FROM skill_counts sc
JOIN title_totals tt USING (job_title_short)
QUALIFY ROW_NUMBER() OVER (PARTITION BY sc.job_title_short
                           ORDER BY sc.skill_postings DESC) <= 5
ORDER BY tt.title_postings DESC, sc.skill_postings DESC;
--QUALIFY is WHERE for window functions.

┌──────────────────────────────────────────┐
│            job_postings_fact             │
│                                          │
│ job_id                integer   not null │
│ company_id            integer            │
│ job_title_short       varchar            │
│ job_title             varchar            │
│ job_location          varchar            │
│ job_via               varchar            │
│ job_schedule_type     varchar            │
│ job_work_from_home    boolean            │
│ search_location       varchar            │
│ job_posted_date       timestamp          │
│ job_no_degree_mention boolean            │
│ job_health_insurance  boolean            │
│ job_country           varchar            │
│ salary_rate           varchar            │
│ salary_year_avg       double             │
│ salary_hour_avg       double             │
└──────────────────────────────────────────┘
┌───────────────────────────┐
│      skills_job_dim       │
│                           │
│ skill_id integer not null │
│ job_id   integer not null │
└───────────────────────────┘
┌───────────────────────────┐
│        skills_dim         │
│                           │
│ skill_id integer not null │
│ skills   varchar          │
│ type     varchar          │
└───────────────────────────┘


--B2. Skills that appear in Data Analyst postings but never in Data Engineer postings. 
--Two ways: NOT EXISTS, and EXCEPT. Which would you ship?

SELECT DISTINCT s.skills
FROM job_postings_fact j
JOIN skills_job_dim sj USING (job_id)
JOIN skills_dim s      USING (skill_id)
WHERE j.job_title_short = 'Data Analyst'
  AND NOT EXISTS (
        SELECT 1
        FROM job_postings_fact j2
        JOIN skills_job_dim sj2 USING (job_id)
        WHERE j2.job_title_short = 'Data Engineer'
          AND sj2.skill_id = sj.skill_id
  )
ORDER BY 1;

--B3. For each skill, median salary of postings requiring it vs median of postings not requiring it, and the gap. Only skills with 100+ salaried postings.
-- This one is hard — the "not requiring it" side isn't a filter, it's a second population.



B4. Per title, what share of postings mention no degree, and what share offer health insurance? Rank titles by the no-degree share. Do both shares in one pass.

Set C — time and windows

C1. Weekly postings for the top 3 titles, with a 4-week moving average per title. Something must restart — say what.

C2. For each title, its busiest and quietest month, on one row per title. FIRST_VALUE / LAST_VALUE, or two ROW_NUMBERs.

C3. Cumulative share of postings by company, ranked biggest first — i.e. "the top N companies account for X% of all postings." How concentrated is this market?

C4. Month-over-month change in remote share, in percentage points, not percent. Be careful about which you report.

Set D — check the instrument

These are real defects in this dataset. I haven't verified them; find out what's actually there.

D1. Are there duplicate postings? Same job_title, company_id and job_posted_date appearing more than once. How many, and how much would they inflate a company-level count?

D2. salary_rate has more than one value. What are they, and what does that mean for anyone summing salary_year_avg and salary_hour_avg together? Is salary_year_avg ever populated for hourly roles?

D3. Distribution of salary_year_avg: min, p1, p50, p99, max. Are the extremes plausible salaries? Quantify what the top few do to the mean.

--D4. job_location vs job_country vs search_location. Do they agree? What's the most common job_location, and is it a place?

--D5. Postings per day across the whole range. Is the coverage even? Look at the first and last weeks specifically.

D6. job_via — how many distinct sources, and how concentrated? Would a "skills by source" analysis be meaningful, or dominated by one channel?

Set E — judgment

--E1. A recruiter asks: "What should I pay a Data Analyst?"

--Answer in the message you'd actually send. A number, the population it describes, and the caveats that matter. Under 120 words.

--E2. A PM asks: "Which skill should we build a course for first?"

--There's no single right answer. Defend one with numbers, and say what would change your mind.