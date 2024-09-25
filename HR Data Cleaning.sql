-- Dataset source : https://www.kaggle.com/datasets/ravindrasinghrana/employeedataset

CREATE DATABASE employee ;

USE employee ;

-- import data set, right click Tables and choose Table Data Import Wizard

SELECT * FROM employee_data ;

-- Create duplicate table and name it as emp1
-- We will use emp1 and raw data will be remain unchanged, in case we need it in future

CREATE TABLE emp1
LIKE employee_data ;

INSERT INTO emp1
SELECT * FROM employee_data ;

SELECT * FROM emp1 ;

-- Doing some data cleaning

ALTER TABLE emp1
RENAME COLUMN ï»¿EmpID TO EmpID ;

-- Checking any duplicate data using CTE and window function

WITH duplicate_cte AS 
(
SELECT 
	empid,
	ROW_NUMBER() OVER(PARTITION BY empid) AS row_num
FROM emp1
) 
SELECT * FROM duplicate_cte
WHERE row_num > 1 ; -- No duplicate data

-- We have some columns contain date value, but the type of data is text
-- Therefore we need to change the type of data into date

DESCRIBE emp1 ;

-- column : startdate

SELECT 
	startdate 
FROM emp1;

SELECT 
	startdate,
	STR_TO_DATE(startdate, '%d-%b-%y') 
FROM emp1 ;

UPDATE emp1
SET startdate = STR_TO_DATE(startdate, '%d-%b-%y') ;

SELECT
	startdate
FROM emp1 ;

ALTER TABLE emp1
MODIFY COLUMN startdate DATE ;

-- Column : exitdate

SET sql_mode = ' '; -- As exitdate has blank value, we need to run this query first

SELECT exitdate,
STR_TO_DATE(exitdate, '%d-%b-%y')
FROM emp1 
WHERE exitdate != ' ' AND exitdate IS NOT NULL;

UPDATE emp1
SET exitdate = STR_TO_DATE(exitdate, '%d-%b-%y')
WHERE exitdate != ' ' AND exitdate IS NOT NULL;

ALTER TABLE emp1
MODIFY COLUMN exitdate DATE ;

-- Column DOB

UPDATE emp1
SET DOB = STR_TO_DATE(DOB, '%d-%m-%Y') ;

ALTER TABLE emp1
MODIFY COLUMN DOB DATE ;

-- To add age column

ALTER TABLE emp1
ADD COLUMN age INT ;

UPDATE emp1
SET age = TIMESTAMPDIFF(YEAR, DOB, CURDATE());

SELECT age FROM emp1 ;





