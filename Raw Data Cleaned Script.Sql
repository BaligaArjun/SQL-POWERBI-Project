SELECT *
FROM messy_datase AS ms;

1. ---- cleaning full_name
SET SQL_SAFE_UPDATES = 0;
ALTER TABLE messy_datase ADD COLUMN Person_name VARCHAR(100);
UPDATE messy_datase

SET person_name = CONCAT(
  UPPER(LEFT(SUBSTRING_INDEX(full_name, ' ', 1), 1)),
  LOWER(SUBSTRING(SUBSTRING_INDEX(full_name, ' ', 1), 2)),
  ' ',
  UPPER(LEFT(SUBSTRING_INDEX(full_name, ' ', -1), 1)),
  LOWER(SUBSTRING(SUBSTRING_INDEX(full_name, ' ', -1), 2))
  )
WHERE full_name IS NOT NULL;



2. ----- Cleaning phone_number

ALTER TABLE messy_datase ADD COLUMN cleaned_phone VARCHAR(100);
UPDATE messy_datase AS m

JOIN (
    SELECT
        id,  
        CONCAT(
            LEFT(REGEXP_REPLACE(phone,'[^0-9]',''),3), '-', 
            SUBSTRING(REGEXP_REPLACE(phone,'[^0-9]',''),4,3), '-', 
            SUBSTRING(REGEXP_REPLACE(phone,'[^0-9]',''),7,4),
            IF(REGEXP_SUBSTR(phone,'x[0-9]+$') IS NOT NULL,
               CONCAT(' ext ', REPLACE(REGEXP_SUBSTR(phone,'x[0-9]+$'),'x','')),
               ''
            )
        ) AS cleaned_phone
    FROM messy_datase
) AS t
ON m.id = t.id
SET m.cleaned_phone = t.cleaned_phone;

SELECT
    phone,
    cleaned_phone,
    CASE
        WHEN LENGTH(REGEXP_REPLACE(cleaned_phone,'[^0-9]','')) < 10 THEN 'Invalid'
        WHEN LENGTH(REGEXP_REPLACE(cleaned_phone,'[^0-9]','')) > 15 THEN 'Invalid'
        ELSE 'Valid'
    END AS Phone_Status
FROM messy_datase;



SELECT
phone,
cleaned_phone,
CASE
WHEN LENGTH(cleaned_phone) < 10 THEN 'In Valid'
WHEN LENGTH(cleaned_phone) > 15 THEN 'In Valid'
ELSE 'Valid '
END AS Phone_Status
FROM messy_datase

3. ----- Cleaning country _Names

ALTER TABLE messy_datase ADD COLUMN cleaned_country VARCHAR(100);
UPDATE messy_datase
SET cleaned_country = CASE
WHEN country NOT LIKE '% %'
THEN CONCAT(UPPER(LEFT(country, 1)), LOWER(SUBSTRING(country, 2)))
ELSE CONCAT(
  UPPER(LEFT(SUBSTRING_INDEX(country, ' ', 1), 1)),
  LOWER(SUBSTRING(SUBSTRING_INDEX(country, ' ', 1), 2)),
  ' ',
  UPPER(LEFT(SUBSTRING_INDEX(country, ' ', -1), 1)),
  LOWER(SUBSTRING(SUBSTRING_INDEX(country, ' ', -1), 2))
) 
END 
WHERE full_name IS NOT NULL;


4. ---- Cleaning DOB
ALTER TABLE messy_datase ADD COLUMN cleaned_Dob VARCHAR(100);
UPDATE messy_datase
SET cleaned_dob = DATE_FORMAT(STR_TO_DATE(TRIM(dob), '%d/%m/%Y'), '%d/%m/%Y') 
WHERE dob IS NOT NULL;

5. ----Cleaning join_date
ALTER TABLE messy_datase ADD COLUMN cleaned_Join_Date VARCHAR(100);
UPDATE messy_datase
	SET cleaned_join_date = CASE
WHEN join_date LIKE '%-%'
	THEN DATE_FORMAT(STR_TO_DATE(TRIM(join_date), '%d-%m-%Y'), '%d/%m/%Y')
WHEN join_date LIKE '%/%'
	THEN DATE_FORMAT(STR_TO_DATE(TRIM(join_date), '%d/%m/%Y'), '%d/%m/%Y')
    ELSE NULL
END 

6. ----Salary_cleaning

ALTER TABLE messy_datase 
	ADD COLUMN cleaned_Salary VARCHAR(100);
UPDATE messy_datase
	SET cleaned_salary = FORMAT(CAST(salary AS DECIMAL(15,2)), 2) 
WHERE salary IS NOT NULL;

ALTER TABLE messy_datase 
	ADD COLUMN cleaned_email VARCHAR(100);
UPDATE messy_datase
SET cleaned_email = CONCAT(
	SUBSTRING_INDEX(email, '@', 1), '@arjun.in')
    WHERE email LIKE '%@example.%';


DROP TABLE IF EXISTS new_data;
CREATE TABLE `new_data` (
  `full_name` text,
  `email` text,
  `phone` text,
  `dob` text,
  `country` text,
  `salary` double DEFAULT NULL,
  `join_date` text,
  `department` text
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;



INSERT INTO new_data (
    full_name,
    email,
    phone,
    dob,
    country,
    salary,
    join_date,
    department
)
SELECT
    Person_name,               -- cleaned full name
    cleaned_email,             -- cleaned email
    cleaned_phone,             -- cleaned phone
    cleaned_Dob,               -- cleaned DOB
    cleaned_country,           -- cleaned country
   REPLACE(cleaned_Salary, ',', '') + 0,
    cleaned_Join_Date,         -- cleaned join date
    COALESCE(department,'Other')  -- department, filling NULLs with 'Other'
FROM messy_datase;


select *
from new_data;





