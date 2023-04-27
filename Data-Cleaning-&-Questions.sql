-- Creating a DB and importing data from CSV file using "Table data import wizard"

CREATE DATABASE projects;

USE projects;

SELECT *
FROM hr;

DESC hr;

-- Data Cleaning (Cleansing / Scrubbing)

ALTER TABLE hr
CHANGE COLUMN ï»¿id emp_id VARCHAR(20);


-- Update "birthday" values
SELECT birthdate
FROM hr;

-- This is feature to switch off safe update mode - once you done updateig data you can switch it back to 1 means safe update mode is "ON"
SET sql_safe_updates = 0;

UPDATE hr
SET birthdate = CASE
	WHEN birthdate LIKE '%/%' THEN date_format(str_to_date(birthdate,'%m/%d/%Y'),'%Y-%m-%d')
	WHEN birthdate LIKE '%-%' THEN date_format(str_to_date(birthdate,'%m-%d-%Y'),'%Y-%m-%d')
  ELSE null
END;

-- Change "birthdate" data type from text to DATE
ALTER TABLE hr
MODIFY COLUMN birthdate DATE;

SELECT birthdate
FROM hr;

DESC hr;

UPDATE hr
SET hire_date = CASE
	WHEN hire_date LIKE '%/%' THEN date_format(str_to_date(hire_date,'%m/%d/%Y'),'%Y-%m-%d')
	WHEN hire_date LIKE '%-%' THEN date_format(str_to_date(hire_date,'%m-%d-%Y'),'%Y-%m-%d')
  ELSE null
END;

ALTER TABLE hr
MODIFY COLUMN hire_date DATE;

SELECT hire_date
FROM hr;


-- Cleaning data in "termdate" & replacing blanks with null values
SELECT termdate
FROM hr;

UPDATE hr
SET termdate = date_format(str_to_date(termdate, '%Y-%m-%d %H:%i:%s UTC'),'%Y-%m-%d')
WHERE termdate IS NOT NULL AND termdate != '';

ALTER TABLE hr
MODIFY COLUMN termdate DATE;

-- Adding "Age" Coloumn to hr table
ALTER TABLE hr ADD COLUMN age INT;

SET sql_safe_updates = 0;

UPDATE hr 
SET age = timestampdiff(YEAR, birthdate, CURDATE());

USE projects;
SELECT *
FROM hr;

-- Some "age" values are not real, aas the birthdate is wrongly entered, so will check values
SELECT min(age) AS Youngest, max(age) AS Oldest
FROM hr;

SELECT count(*)
FROM hr;

SELECT count(age)
FROM hr
WHERE age < 18;

-- out of 22412 records 967 records have age below 18 and these are not valid data

-- -------------------------------------------------------------------------------------------------------------------

-- QUESTIONS

-- 1. What is the gender breakdown of employees in the company?

SELECT gender, count(*) AS count
FROM hr
WHERE age >= 18
GROUP BY gender;

-- 2. What is the race/ethnicity breakdown of employees in the company?

SELECT race, count(*) AS count
FROM hr
WHERE age >= 18
GROUP BY race
ORDER BY count DESC;

-- 3. What is the age distribution of employees in the company?

SELECT
	min(age) AS youngest,
    min(age) AS oldest
FROM hr
WHERE age >= 18;

SELECT
	CASE
		WHEN age >= 18 AND age <= 24 THEN '18-24'
        WHEN age >= 25 AND age <= 34 THEN '25-34'
        WHEN age >= 35 AND age <= 44 THEN '35-44'
        WHEN age >= 45 AND age <= 54 THEN '44-54'
        WHEN age >= 55 AND age <= 64 THEN '55-64'
        ELSE '65+'
	END AS age_group, count(*) AS count
FROM hr
WHERE age >= 18
GROUP BY age_group
ORDER BY age_group;

-- 3. What is the age distribution of employees gender in the company?

SELECT
	CASE
		WHEN age >= 18 AND age <= 24 THEN '18-24'
        WHEN age >= 25 AND age <= 34 THEN '25-34'
        WHEN age >= 35 AND age <= 44 THEN '35-44'
        WHEN age >= 45 AND age <= 54 THEN '44-54'
        WHEN age >= 55 AND age <= 64 THEN '55-64'
        ELSE '65+'
	END AS age_group, gender, count(*) AS count
FROM hr
WHERE age >= 18
GROUP BY age_group, gender
ORDER BY age_group, gender;

-- 4. How many employees work at headquarters versus remote locations?
SELECT location, count(*) AS Count
FROM hr
WHERE age >= 18
GROUP BY location;

-- 5. What is the average length of employment for employees who have been terminated?
SELECT 
	avg(datediff(termdate, hire_date))/365 AS Avg_Length_Employment
    -- round(avg(datediff(termdate, hire_date))/365,2) AS Avg_Length_Employment
FROM hr
WHERE termdate <= curdate() AND age >= 18;

-- 6. How does the gender distribution vary across departments?
SELECT gender, department, count(*) AS count
FROM hr
WHERE age >= 18
GROUP BY gender, department
ORDER BY count DESC;

-- 7. What is the distribution of job titles across the company?
SELECT jobtitle, count(*) AS count
FROM hr
WHERE age >= 18
GROUP BY jobtitle
ORDER BY jobtitle DESC;

-- 8. Which department has the highest turnover rate (The rate of employees leave the company)?
-- Here we use subquery to get the results
SELECT department, total_count, terminated_count, terminated_count/total_count AS termination_rate
FROM (
	SELECT department, 
    count(*) AS total_count, 
    SUM(CASE WHEN termdate != '' AND termdate <= curdate() THEN 1 ELSE 0 END) AS terminated_count
    FROM hr
    WHERE age >=18
    Group by department
	) AS subquery
ORDER BY termination_rate DESC;

-- 9. What is the distribution of employees across locations by city and state?
SELECT location_state, count(*) AS count
FROM hr
WHERE age >= 18
GROUP BY location_state
ORDER BY count DESC;

-- 10. How has the company's employee count changed over time based on hire and term dates?
SELECT
	year,
    hires,
    terminations,
    hires - terminations AS net_change,
    (hires - terminations) / hires * 100 AS net_change_percentage
FROM (
	SELECT YEAR(hire_date) AS year,
    count(*) AS hires,
    SUM(CASE WHEN termdate != '' AND termdate <= curdate() THEN 1 ELSE 0 END) AS terminations
    FROM hr
    WHERE AGE >=18
    GROUP BY year
    ) AS subquery
ORDER BY year ASC;

-- 11. What is the tenure distribution (How long employees staying in each department) for each department?

SELECT department, round(avg(datediff(termdate, hire_date)/365),0) AS avg_tenure
FROM hr
WHERE termdate <= curdate() AND termdate <> '' AND age >= 18
GROUP BY department;