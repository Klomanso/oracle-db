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
CREATE OR REPLACE VIEW res_result AS
SELECT coalesce(c.name, '<NO RESULT>')  crop_name
     , coalesce(r.title, '<BASE CROP>') research_title
     , CASE
           WHEN r.start_date IS NULL AND r.finish_date IS NULL THEN '<NO PERIOD>'
           ELSE concat(to_char(r.start_date, 'DD.MM.YYYY'), concat(' -- ', to_char(r.finish_date, 'DD.MM.YYYY')))
    END
                                        research_period
FROM research r
         FULL OUTER JOIN CROPS c ON r.res_id = c.rsr_result
ORDER BY crop_name DESC;
-----------------------
SELECT *
FROM res_result;
-----------------------
UPDATE res_result
SET crop_name = 'TEST_CROP_NAME'
WHERE crop_name = 'Алексий';
-----------------------
INSERT INTO res_result (crop_name, research_title, research_period)
VALUES ('TEST_NAME', '<BASE CROP>', '03.04.2022 -- 08.09.2022');
-----------------------
DELETE
FROM res_result
WHERE crop_name = 'Алексий';
---------------------------------------------------------------------