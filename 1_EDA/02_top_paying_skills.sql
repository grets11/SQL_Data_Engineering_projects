SELECT 
    sd.skills, 
    ROUND(MEDIAN(jpf.salary_year_avg),0) AS median_salary,
    COUNT(jpf.*) AS demand_count
FROM job_postings_fact AS jpf
INNER JOIN skills_job_dim AS sjd
    ON jpf.job_id = sjd.job_id
INNER JOIN skills_dim AS sd
    ON sd.skill_id = sjd.skill_id
WHERE 
    jpf.job_title_short ='Data Engineer'
    AND jpf.job_work_from_home = True
GROUP BY sd.skills
HAVING COUNT(jpf.*) > 100
ORDER BY median_salary DESC
LIMIT 25; 

/*
Here's a breakdown of the highest-paying skills for Data Engineers:
Key Insights:
- Rust remains the top-paying skill at $210K median salary, though demand is still relatively limited (232 postings)
- Terraform and Golang both have high median salaries at $184K, with strong demand (Terraform: 3,248 postings; Golan
Other notable skills with both high pay and moderate-to-high frequency include:
- Spring: $175.5K median salary (364 postings)
- Ne04j: $170K median salary (277 postings)
- GDPR: $169.6K median salary (582 postings)
- GraphQL: $167.5K median salary (445 postings)
- Kubernetes: $150.5K median salary (4,202 postings)
- Airflow: $150K median salary (9,996 postings)
Bitbucket, Ruby, Redis, Ansible, and Jupyter all appear in the top 25 for pay, each with hundreds of postings.
- Most skills on the list are no longer extreme statistical outliers with just a handful of postings; instead, many
Takeaway: While the very top-paying skill (Rust) still has less demand than major cloud and data tools, most of the
┌────────────┬───────────────┬──────────────┐
│   skills   │ median_salary │ demand_count │
│  varchar   │    double     │    int64     │
├────────────┼───────────────┼──────────────┤
│ rust       │      210000.0 │          232 │
│ terraform  │      184000.0 │         3248 │
│ golang     │      184000.0 │          912 │
│ spring     │      175500.0 │          364 │
│ neo4j      │      170000.0 │          277 │
│ gdpr       │      169616.0 │          582 │
│ zoom       │      168438.0 │          127 │
│ graphql    │      167500.0 │          445 │
│ mongo      │      162250.0 │          265 │
│ fastapi    │      157500.0 │          204 │
│ bitbucket  │      155000.0 │          478 │
│ django     │      155000.0 │          265 │
│ crystal    │      154224.0 │          129 │
│ atlassian  │      151500.0 │          249 │
│ c          │      151500.0 │          444 │
│ typescript │      151000.0 │          388 │
│ kubernetes │      150500.0 │         4202 │
│ ruby       │      150000.0 │          736 │
│ airflow    │      150000.0 │         9996 │
│ node       │      150000.0 │          179 │
│ css        │      150000.0 │          262 │
│ redis      │      149000.0 │          605 │
│ vmware     │      148798.0 │          136 │
│ ansible    │      148798.0 │          475 │
│ jupyter    │      147500.0 │          400 │
└────────────┴───────────────┴──────────────┘
  25 rows                         3 columns

*/