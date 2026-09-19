# Exploratory Data Analysis w/ SQL: Job Market Analysis

![Project 1 Overview](../Images/1_1_Project1_EDA.png)

A SQL project analyzing the data engineer job
market using real world job posting data. It
demonstrates my ability to **write
production-quality analytical SQL, design
efficient queries, and turn business questions
into data-driven insights**.

## Executive Summary
- **Project scope:** Built **3 analytical
queries** that answer key questions about the data
engineer job market
- **Data modeling:** Used **multi-table joins**
across fact and dimension tables to extract
insights
- **Analytics:** Applied **aggregations
filtering, and sorting** to find top skills by
demand, salary,
and overall value
- **Outcomes:** Delivered **actionable
insights** on SQL/Python dominance, cloud trends,
and salary patterns

[Top demanded skills Query](../1_EDA/01_top_demanded_skills.sql)  
[Top payiing skills Query](../1_EDA/02_top_paying_skills.sql)  
[Optimal skills Query](../1_EDA/03_Optimal_skills.sql)

## Problem and Context
Job market analysts need to answer questions like:
- **Most in-demand:** *Which skills are most
in-demand for data engineers?*
- **Highest paid:** *Which skills command the
highest salaries?*
- **Best trade-off:** *What is the optimal
skill set balancing demand and compensation?*

![Data Warehouse](../Images/1_2_Data_Warehouse.png)

- **Fact Table:** 'job_postings_fact' - Central
table containing job posting details (job titles,
locations, salaries,
dates, etc.)
- **Dimension Tables:**
    - `company_dim` - Company information linked to
    job postings  
    - `skills dim` - Skills catalog with skill names
    and types  
- **Bridge Table:** `skills_job_dim`- Resolves
the many-to-many relationship between job postings
and skills  

By querying across these interconnected tables, I
extracted insights about skill demand, salary
patterns, and optimal skill combinations for data
engineering roles.

## Tech Stack

- **Query Engine:** DuckDB for fast OLAP-style analytical queries
- **Language:** SQL (ANSI-style with analytical functions)
- **Data Model:** Star schema with fact dimension + bridge tables
- **Development:** VS Code for SQL editing Terminal for DuckDB CLI
- **Version Control:** Git/GitHub for versioned SQL scripts

