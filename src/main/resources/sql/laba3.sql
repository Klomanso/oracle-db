-- 1) Горизонтальное представление
-- Выбрать сотрудников, должностей
-- которых больше всего в интституте
CREATE OR REPLACE VIEW max_title_emp AS
SELECT *
FROM employees
WHERE title IN (WITH title_count AS (SELECT title, count(*) num
                                     FROM employees
                                     GROUP BY title)
                SELECT title
                FROM title_count
                WHERE num = (SELECT max(num) FROM title_count))
WITH CHECK OPTION CONSTRAINT max_check;
-----------
SELECT *
FROM MAX_TITLE_EMP;
-----------
INSERT INTO max_title_emp (contract_no,
                           first_name, last_name, birth_date,
                           hire_date, title, education)
VALUES (
           -- random 7 digits id
           to_char(floor(DBMS_RANDOM.VALUE(1000000, 9999999))),
           -- first, last name
           'TEST', 'USER',
           -- birth_date
           to_date('1986-09-12', 'YYYY-MM-DD'),
           -- hire_date
           to_date('2003-12-26', 'YYYY-MM-DD'),
           -- title, education
           floor(DBMS_RANDOM.VALUE(1, 5)), 1);
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
--------------------
INSERT INTO working_days_spec_view (SPEC_NAME)
VALUES ('fsd');
---------------------------------------------------------------------
-- 3) Вертикальное необновляемое представление
CREATE OR REPLACE VIEW emp_view AS
SELECT concat(e.first_name, concat(' ', e.last_name)) full_name,
       t.title_name,
       ed.edu_type
FROM employees e
         INNER JOIN titles t ON e.title = t.title_no
         INNER JOIN education ed ON ed.edu_no = e.education
WITH READ ONLY;
-----------------------
SELECT *
FROM emp_view;
-----------------------
INSERT INTO emp_view (full_name, title_name, edu_type)
VALUES ('a', 'b', 'c');
---------------------------------------------------------------------