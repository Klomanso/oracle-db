-- 1) Горизонтальное обновляемое представление
-- Выбрать сотрудников, с высшим образованием
CREATE OR REPLACE VIEW higher_edu AS
SELECT e.contract_no,
       e.hire_date,
       e.first_name,
       e.last_name,
       e.birth_date,
       e.education
FROM employees e
WHERE e.education = 4
WITH CHECK OPTION;
-----------
SELECT *
FROM higher_edu;
------------- BAD INSERT -------------
INSERT INTO higher_edu (contract_no,
                        first_name, last_name, birth_date,
                        hire_date, education)
VALUES (
           -- random 7 digits id
           to_char(floor(DBMS_RANDOM.VALUE(1000000, 9999999))),
           -- first, last name
           'TEST', 'USER',
           -- birth_date
           to_date('1986-09-12', 'YYYY-MM-DD'),
           -- hire_date
           to_date('2003-04-26', 'YYYY-MM-DD'),
           -- education
           1);
------------- GOOD INSERT -------------
INSERT INTO higher_edu (contract_no,
                        first_name, last_name, birth_date,
                        hire_date, education)
VALUES (
           -- random 7 digits id
           to_char(floor(DBMS_RANDOM.VALUE(1000000, 9999999))),
           -- first, last name
           'TEST', 'USER',
           -- birth_date
           to_date('1986-09-12', 'YYYY-MM-DD'),
           -- hire_date
           to_date('2003-12-26', 'YYYY-MM-DD'),
           -- education
           4);
---------------------------------------------------------------------
-- 2) Работа с данными только в рабочие дни
CREATE OR REPLACE VIEW working_days_spec_view AS
SELECT *
FROM SPECIES
WHERE (to_char(sysdate, 'D') BETWEEN '2' AND '6')
  AND (to_char(sysdate, 'HH24:MI') BETWEEN '09:00' AND '17:00')
WITH CHECK OPTION;
--------------------
SELECT *
FROM WORKING_DAYS_SPEC_VIEW;
---------------------------------------------------------------------
-- 3) Вертикальное необновляемое представление
CREATE OR REPLACE VIEW emp_view AS
SELECT DISTINCT e.first_name,
       e.last_name,
       t.title_name,
       ed.edu_type,
       extract(MONTH from e.hire_date) hire_month
FROM employees e
         LEFT JOIN titles t ON e.title = t.title_no
         INNER JOIN education ed ON ed.edu_no = e.education
WHERE extract(MONTH FROM e.hire_date) = 4;
-----------------------
SELECT *
FROM emp_view;
-----------------------
DELETE
FROM emp_view
WHERE edu_type = 'среднее';
---------------------------------------------------------------------