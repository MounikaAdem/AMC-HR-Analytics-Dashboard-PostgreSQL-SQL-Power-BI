drop table if exists Hr_analysis

CREATE TABLE Hr_analysis (
    Employee_ID            INT PRIMARY KEY,
	Age                    INT,
	Gender                 VARCHAR(10),
    Department             VARCHAR(50),
    Job_Role               VARCHAR(60),   
    Experience_Years       DECIMAL(4,1),
    KPI_Score              DECIMAL(3,2),
	Target_Achievement     INT,
	Base_Salary_LPA        DECIMAL(10,2),
	Variable_Pay_LPA       DECIMAL(10,2),
    Job_Satisfaction       INT,
    Work_Life_Balance      INT,
    Attrition_Flag         VARCHAR(5)
);

select count(*) from Hr_analysis


SELECT * FROM Hr_analysis
LIMIT 10;

--Remove the duplicated values
DELETE FROM Hr_analysis
WHERE Employee_ID IN (
  SELECT Employee_ID
  FROM (
    SELECT Employee_ID,
           ROW_NUMBER() OVER (PARTITION BY Employee_ID ORDER BY Employee_ID) AS rn
    FROM Hr_analysis
  ) t
  WHERE rn > 1
);


UPDATE Hr_analysis
SET KPI_Score = 3
WHERE KPI_Score NOT BETWEEN 1 AND 5;


--Exploratory Data Analysis(EDA)
--Total Employees
SELECT COUNT(*) AS total_employees
FROM Hr_analysis;

--Headcount by Department
SELECT Department, COUNT(*) AS employee_count
FROM Hr_analysis
GROUP BY Department
ORDER BY employee_count DESC;

--Gender Distribution
SELECT Gender, COUNT(*) AS count
FROM Hr_analysis
GROUP BY Gender;

SELECT department,
       ROUND(AVG(experience_years), 2) AS avg_experience
FROM hr_analysis
GROUP BY department;

--Performance Analysis
--Average KPI score by Department

SELECT Department,
       ROUND(AVG(KPI_Score), 2) AS avg_kpi
FROM Hr_analysis
GROUP BY Department
ORDER BY avg_kpi DESC;

--High Performers(that KPI greater than or equal to 4)
SELECT COUNT(*) AS high_performers
FROM Hr_analysis
WHERE KPI_Score >= 4;

--Experience vs Performance

SELECT Experience_Years,
       ROUND(AVG(KPI_Score), 2) AS avg_kpi
FROM Hr_analysis
GROUP BY Experience_Years
ORDER BY Experience_Years;

--Relation Between KPI Score and Target Achievement
SELECT
  CASE
    WHEN kpi_score >= 4 THEN 'High KPI'
    WHEN kpi_score >= 3 THEN 'Medium KPI'
    ELSE 'Low KPI'
  END AS kpi_category,
  ROUND(AVG(target_achievement), 2) AS avg_target_achievement
FROM hr_analysis
GROUP BY kpi_category;

--Attrition Analysis
--Overall Attrition Rate
SELECT
  ROUND(
    COUNT(*) FILTER (WHERE attrition_flag = 'Yes') * 100.0 / COUNT(*),
    2
  ) AS attrition_rate_percentage
FROM hr_analysis;


--Attrition rate by Department
SELECT department,
       COUNT(*) FILTER (WHERE attrition_flag = 'Yes') AS attritions,
       COUNT(*) AS total_employees,
       ROUND(
         COUNT(*) FILTER (WHERE attrition_flag = 'Yes') * 100.0 / COUNT(*),
         2
       ) AS attrition_rate
FROM hr_analysis
GROUP BY department
ORDER BY attrition_rate DESC;


--Are high performers leaving?
SELECT
  CASE
    WHEN kpi_score >= 4 THEN 'High Performers'
    WHEN kpi_score >= 3 THEN 'Medium Performers'
    ELSE 'Low Performers'
  END AS performance_group,
  COUNT(*) FILTER (WHERE attrition_flag = 'Yes') AS attritions
FROM hr_analysis
GROUP BY performance_group;

--Compensation Analysis
--Average Salary by Department
SELECT department,
       ROUND(AVG(base_salary_lpa), 2) AS avg_salary_lpa
FROM hr_analysis
GROUP BY department
ORDER BY avg_salary_lpa DESC;

--Does Higher KPI lead to higher variable pay?

SELECT
  ROUND(AVG(kpi_score),2) AS avg_kpi,
  ROUND(AVG(variable_pay_lpa),2) AS avg_variable_pay
FROM hr_analysis
GROUP BY job_role;

--Job Satisfaction VS KPI Score
SELECT job_satisfaction,
       ROUND(AVG(kpi_score),2) AS avg_kpi
FROM hr_analysis
GROUP BY job_satisfaction
ORDER BY job_satisfaction;

--Identify high-risk Employees(Attrition Prediction)
SELECT employee_id, department, job_role, kpi_score,
       job_satisfaction, work_life_balance
FROM hr_analysis
WHERE attrition_flag = 'Yes'
  AND kpi_score >= 4;
























