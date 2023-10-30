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
-- (Вывести названия базовых культур вместе с производными культурами,
-- a также названия и периоды проведения всех исследований)
CREATE OR REPLACE VIEW res_customers AS
SELECT r.TITLE,
       r.BUDGET,
       r.START_DATE,
       r.FINISH_DATE,
       c.TITLE        customer_title,
       c.EMAIL        customer_email,
       c.PHONE_NUMBER customer_number
FROM research r
         FULL OUTER JOIN CUSTOMERS c ON r.OGRN = c.OGRN;
-----------------------
SELECT *
FROM res_customers;
-----------------------
UPDATE res_customers
SET BUDGET = 8888
WHERE TITLE = 'Селекция урожайных сортов персика';
-----------------------
INSERT INTO res_customers (TITLE, BUDGET, START_DATE, FINISH_DATE, customer_title, customer_email, customer_number)
VALUES ('research2', 1333, to_date('2012-04-22', 'YYYY-MM-DD'), to_date('2013-01-22', 'YYYY-MM-DD'),
        'TEST_TRIGGER_CUSTOMER', 'test@mail.by', '+375455723239');
-----------------------
DELETE
FROM res_customers
WHERE TITLE = 'Селекция урожайных сортов персика';
---------------------------------------------------------------------