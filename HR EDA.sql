SELECT * FROM emp1 ;

-- Number of employee

SELECT
	COUNT(DISTINCT(empid)) AS num_employee
FROM emp1
WHERE exitdate = '0000-00-00' ;

-- Age range

SELECT
	MIN(age) AS youngest,
    MAX(age) AS oldest,
    ROUND(AVG(age), 0) AS avg_age
FROM emp1 
WHERE exitdate = '0000-00-00';

-- Group by age
-- Later on dashboard we can see that the percentage of employee who over 60 years old is 39%

SELECT
	CASE
		WHEN age >= 20 AND age <= 29 THEN '20 - 29'
        WHEN age >= 30 AND age <= 39 THEN '30 - 39'
        WHEN age >= 40 AND age <= 49 THEN '40 - 49'
        WHEN age >= 50 AND age <= 59 THEN '50 - 59'
        ELSE '60 or Above'
	END AS age_group,
    COUNT(*) as count
FROM emp1
WHERE exitdate = '0000-00-00'
GROUP BY age_group
ORDER BY age_group;

-- Gender distribution

SELECT
	gendercode,
    COUNT(gendercode)
FROM emp1
WHERE exitdate = '0000-00-00'
GROUP BY gendercode ;



-- to see employee performance every department using subquery and window function
-- here we can see percentage per department

SELECT
	departmenttype,
    `Performance Score`,
    num_emp,
    total_per_dep,
    CONCAT(ROUND((num_emp / total_per_dep)*100,0), '%')
FROM 	(
		SELECT
		departmenttype,
		`Performance Score`,
		COUNT(`Performance Score`) AS num_emp,
		SUM(COUNT(`Performance Score`)) OVER (PARTITION BY DepartmentType) AS total_per_dep
		FROM emp1
		WHERE exitdate = '0000-00-00'
		GROUP BY departmenttype, `Performance Score` 
		ORDER BY 1
		) AS subquery ;


-- The average length of employment for employees who have been exit
-- As the average is less than 2 years, therefore we count it in days

SELECT
	ROUND(AVG(DATEDIFF(exitdate, startdate)),0) AS avg_employment
FROM employee_data2
WHERE exitdate <> '0000-00-00';

SET sql_mode = ' ';

-- to count hire & exit per year using CTE and join 
-- exit employee has increased significantly every year

WITH hire_peryear AS
(
SELECT
	YEAR(startdate) AS start_year,
    COUNT(*) AS hire_count
FROM emp1 
GROUP BY start_year
),
exit_peryear AS
(
SELECT
	YEAR(exitdate) AS exit_year,
    COUNT(*) AS exit_count
FROM emp1
WHERE exitdate <> '0000-00-00'
GROUP BY exit_year
)
SELECT 
hire_peryear.start_year,
hire_peryear.hire_count,
exit_peryear.exit_count
FROM hire_peryear 
JOIN exit_peryear ON (hire_peryear.start_year = exit_peryear.exit_year)
ORDER BY 1
;


-- to count last 3 years employee turnover using CTE and join for each department
-- here we just do simple calculation by devide number of exit by number of employee at same periode
-- found that Executive Office department turnover is the highest for last 3 years
 
 WITH total23 AS
 (
 SELECT
    departmenttype,
    COUNT(empid) AS total_2023
FROM emp1
WHERE exitdate = '0000-00-00'
GROUP BY departmenttype
),
exit23 AS
(
SELECT
    departmenttype,
    COUNT(empid) AS exit_2023
FROM emp1
WHERE exitdate BETWEEN '2023-01-01' AND '2023-12-31' 
GROUP BY departmenttype
),
total22 AS
(
SELECT
    departmenttype,
    COUNT(empid) AS total_2022
FROM emp1
WHERE (exitdate >= '2022-12-31' OR exitdate = '0000-00-00') AND startdate <= '2022-12-31'
GROUP BY departmenttype
),
exit22 AS
(
SELECT
    departmenttype,
    COUNT(empid) AS exit_2022
FROM emp1
WHERE exitdate BETWEEN '2022-01-01' AND '2022-12-31' 
GROUP BY departmenttype
),
total21 AS
(
SELECT
    departmenttype,
    COUNT(empid) AS total_2021
FROM emp1
WHERE (exitdate >= '2021-12-31' OR exitdate = '0000-00-00') AND startdate <= '2021-12-31'
GROUP BY departmenttype
),
exit21 AS
(
SELECT
    departmenttype,
    COUNT(empid) AS exit_2021
FROM emp1
WHERE exitdate BETWEEN '2021-01-01' AND '2021-12-31' 
GROUP BY departmenttype
)
SELECT 
	total23.departmenttype,
    total21.total_2021,
    exit21.exit_2021,
    CONCAT(ROUND((exit21.exit_2021/total21.total_2021)*100,0),'%') AS turnover_2021,
    total22.total_2022,
    exit22.exit_2022,
    CONCAT(ROUND((exit22.exit_2022/total22.total_2022)*100,0),'%') AS turnover_2022,
    total23.total_2023,
    exit23.exit_2023,
    CONCAT(ROUND((exit23.exit_2023/total23.total_2023)*100,0),'%')AS turnover_2023
FROM total23
JOIN exit23 ON (total23.departmenttype = exit23.departmenttype)
JOIN total22 ON (total23.departmenttype = total22.departmenttype)
JOIN exit22 ON (total23.departmenttype = exit22.departmenttype)
JOIN total21 ON (total23.departmenttype = total21.departmenttype)
JOIN exit21 ON (total23.departmenttype = exit21.departmenttype)
; 



