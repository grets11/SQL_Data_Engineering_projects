--Array Intro
SELECT[1,2,3];

SELECT['python', 'sql', 'r'] AS skills_array;

WITH skills AS (
    SELECT 'python' AS skill
    UNION ALL 
    SELECT 'sql'
    UNION ALL
    SELECT 'r'
) 
SELECT ARRAY_AGG(skill) AS skills_array --LIST()
FROM skills;

WITH skills AS (
    SELECT 'python' AS skill
    UNION ALL 
    SELECT 'sql'
    UNION ALL
    SELECT 'r'
),
skills_array AS (
    SELECT ARRAY_AGG(skill ORDER BY skill) AS skills
    FROM skills
)
SELECT 
    skills[1] AS first_skill,
    skills[2] AS second_skill,
    skills[3] AS third_skill
FROM skills_array;

--STRUCT intro:
SELECT {skill: 'python', type: 'programming'} AS skill_struct;

WITH skill_struct AS(
    SELECT 
        STRUCT_PACK(
            skill := 'python',
            type := 'programming'
        ) AS s
)
SELECT 
    s.skill,
    s.type
FROM skill_struct;


SELECT 'python' AS skill, 'programming' AS type
UNION ALL 
SELECT 'sql', 'query_language'
UNION ALL
SELECT 'r', 'programming';

WITH skill_table AS(
    SELECT 'python' AS skills, 'programming' AS types
    UNION ALL 
    SELECT 'sql', 'query_language'
    UNION ALL
    SELECT 'r', 'programming'
)
SELECT STRUCT_PACK(
    skill := skills,
    type := types
)
FROM skill_table;


--ARRAY OF STRUCKS:
SELECT [
    {skill : 'python', type : 'programming'},
    {skill : 'sql', type : 'query_language'},
    {skill : 'r', type : 'programming'}
] AS skills_array_of_structs;

WITH skill_table AS(
    SELECT 'python' AS skills, 'programming' AS types
    UNION ALL 
    SELECT 'sql', 'query_language'
    UNION ALL
    SELECT 'r', 'programming'
)
SELECT 
    ARRAY_AGG(
        STRUCT_PACK(
        skill := skills,
        type := types
        )
    )
FROM skill_table;

WITH skill_table AS(
    SELECT 'python' AS skills, 'programming' AS types
    UNION ALL 
    SELECT 'sql', 'query_language'
    UNION ALL
    SELECT 'r', 'programming'
), skills_array_struct AS(
    SELECT 
        ARRAY_AGG(
            STRUCT_PACK(
                skill := skills,
                type := types
            )
        ) array_struct
    FROM skill_table
)
SELECT
     array_struct[1].skill,
     array_struct[2].type,
     array_struct[3]
FROM skills_array_struct;

--MAP INTRO:

SELECT MAP {'skill': 'python', 'type' : 'programming'};

WITH skill_map AS(
    SELECT MAP {'skill': 'python', 'type' : 'programming'} AS skill_type
)
SELECT 
    skill_type['skill'],
    skill_type['type']
FROM skill_map;

--JSON INTRO:
SELECT 
    '{"skill" : "python", "type" : "programming"}'::JSON AS skill_json;


SELECT 
    TO_JSON('{"skill" : "python", "type" : "programming"}')AS skill_json;

WITH raw_skill_json AS(
    SELECT 
    '{"skill" : "python", "type" : "programming"}'::JSON AS skill_json
)
SELECT 
    STRUCT_PACK(
        skill := json_extract_string(skill_json, '$.skill'),
        type := json_extract_string(skill_json, '$.type')
        )
FROM raw_skill_json;

--JSON to ARRAY of STRUCT:
WITH raw_json AS(
SELECT '[
    {"skill" : "python", "type" : "programming"},
    {"skill" : "sql", "type" : "query_language"},
    {"skill" : "r", "type" : "programming"}
] '::JSON AS skills_json
)
SELECT 
        ARRAY_AGG(
            STRUCT_PACK(
            skill := json_extract_string(e.value, '$.skill'),
            type := json_extract_string(e.value, '$.type')
            )
            ORDER BY json_extract_string(e.value, '$.skill')
        ) AS skills
FROM raw_json, json_each(skills_json) AS e;

SELECT
    jpf.job_id,
    jpf.job_title_short,
    jpf.salary_year_avg,
    sd.skills
FROM job_postings_fact AS jpf
LEFT JOIN skills_job_dim AS sjd
    ON jpf.job_id=sjd.job_id
LEFT JOIN skills_dim AS sd
    ON sd.skill_id = sjd. skill_id;


SELECT
    jpf.job_id,
    jpf.job_title_short,
    jpf.salary_year_avg,
    ARRAY_AGG(sd.skills) AS skills_array
FROM job_postings_fact AS jpf
LEFT JOIN skills_job_dim AS sjd
    ON jpf.job_id = sjd.job_id
LEFT JOIN skills_dim AS sd
    ON sd.skill_id = sjd.skill_id
GROUP BY ALL;

CREATE OR REPLACE TEMP TABLE job_skills_array AS
SELECT
    jpf.job_id,
    jpf.job_title_short,
    jpf.salary_year_avg,
    ARRAY_AGG(sd.skills) AS skills_array
FROM job_postings_fact AS jpf
LEFT JOIN skills_job_dim AS sjd
    ON jpf.job_id = sjd.job_id
LEFT JOIN skills_dim AS sd
    ON sd.skill_id = sjd.skill_id
GROUP BY ALL;

WITH skills AS (
    SELECT 'python' AS skill
    UNION ALL 
    SELECT 'sql'
    UNION ALL
    SELECT 'r'
),
skills_array AS (
    SELECT ARRAY_AGG(skill ORDER BY skill) AS skills
    FROM skills
)
SELECT 
    UNNEST(skills)
FROM skills_array;

WITH flat_skills AS (
    SELECT
        job_id,
        job_title_short,
        salary_year_avg,
        UNNEST(skills_array) AS skill
    FROM
    job_skills_array
)
SELECT
    skill,
    MEDIAN(salary_year_avg) AS median_salary
FROM flat_skills
GROUP BY skill
ORDER BY median_salary DESC;

CREATE OR REPLACE TEMP TABLE job_skills_array_struct AS
SELECT
    jpf.job_id,
    jpf.job_title_short,
    jpf.salary_year_avg,
    ARRAY_AGG(
        STRUCT_PACK(
            skill_type :=sd.type,
            skill_name :=sd.skills
        )
    ) AS skills_type
FROM job_postings_fact AS jpf
LEFT JOIN skills_job_dim AS sjd
    ON jpf.job_id = sjd.job_id
LEFT JOIN skills_dim AS sd
    ON sd.skill_id = sjd.skill_id
GROUP BY ALL;

SELECT
    job_id,
    job_title_short,
    salary_year_avg,
    UNNEST(skills_type).skill_type AS skill_type,
    UNNEST(skills_type).skill_name AS skill_name
FROM
    job_skills_array_struct;

WITH flat_skills AS (
    SELECT
        job_id,
        job_title_short,
        salary_year_avg,
        UNNEST(skills_type).skill_type AS skill_type,
        UNNEST(skills_type).skill_name AS skill_name
    FROM
        job_skills_array_struct
)
SELECT
    skill_type,
    MEDIAN(salary_year_avg) AS median_salary
FROM flat_skills
GROUP BY skill_type;