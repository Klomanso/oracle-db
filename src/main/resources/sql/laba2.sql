-- Условный запрос (Бюджет исследования больше 5000)
SELECT budget
FROM research
WHERE budget > 5000
ORDER BY budget;
------------------------------------
-- Параметрический запрос (Предоставить информацию по указанному исследованию(res_id))
SELECT *
FROM research
WHERE res_id = :value;
------------------------------------
-- Запрос на объединение (Вывести полные имена кандидатов наук, которые не были
-- руководителями исследований и названия процедур, в которых упоминается "почва")
WITH candidate_science AS (SELECT emp.contract_no
                                , concat(first_name, ' ' || last_name) AS full_name
                           FROM employees emp
                                    INNER JOIN education edu ON emp.education = edu.edu_no
                           WHERE edu_type = 'кандидат наук')
SELECT cs.full_name
FROM candidate_science cs
WHERE NOT exists(SELECT 1
                 FROM research r
                 WHERE r.LEAD_NO = cs.CONTRACT_NO)

UNION

SELECT proc_name
FROM procedures
WHERE description
          LIKE '%почв%'
ORDER BY full_name;
------------------------------------
-- Итоговый запрос с использованием JOIN-ON, JOIN-USING, NATURAL-JOIN
-- (Вывести итоговый бюджет исследований в которых в качестве
-- образца использовалась 'вишня')
SELECT sum(r.budget) cherry_full_budget
FROM species s
         NATURAL JOIN crops c
         INNER JOIN res_samples rs USING (BRK_no)
         INNER JOIN research r ON r.RES_ID = rs.RES_ID
WHERE s.spec_name LIKE '%вишня%'
GROUP BY s.spec_name;
------------------------------------
-- Итоговый запрос с использованием группировки по части поля с типом дата
-- (Вывести  общее количество исследований, которые были завершены
-- в первом квартале года)
SELECT sum(res) total_first_quarter_res_amount
FROM (SELECT count(*) res
      FROM research r
      WHERE extract(MONTH FROM r.finish_date) BETWEEN 1 AND 3
      GROUP BY extract(MONTH FROM r.finish_date));
------------------------------------
-- Запрос с внешним соединением(LEFT-JOIN)
-- (Вывести имена и должности сотрудников, которые ни разу
-- не привлекались к исследованию в качестве членов команды)
SELECT (e.first_name || ' ' || e.last_name) full_name
     , t.title_name
FROM employees e
         INNER JOIN titles t ON e.title = t.title_no
         LEFT OUTER JOIN res_team USING (contract_no)
         LEFT OUTER JOIN research r USING (res_id)
WHERE r.title IS NULL
ORDER BY full_name;
------------------------------------
-- Запрос с внешним соединением(FULL-JOIN)
-- (Вывести названия базовых культур вместе с производными культурами,
-- a также названия и периоды проведения всех исследований)
-- CHECK coalesce(concat(to_char(r.start_date), concat(' -- ', to_char(r.finish_date))), '<NO PERIOD>') research_period
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
------------------------------------
-- Запрос с использованием предиката (IN) в подзапросе
-- (Вывести идентификаторы исследований, которые проводились
-- для открытых акционерных обществ(ОАО))
SELECT res_id
FROM research r
WHERE r.ogrn IN (SELECT ogrn
                 FROM customers
                 WHERE title LIKE '%ОАО%');
------------------------------------
-- Запрос с использованием предиката (ANY) в подзапросе
-- (Вывести имена сотрудников, которые были руководителями
-- исследований, проводимых после 2017 года)
SELECT (e.first_name || ' ' || e.last_name) full_name, e.CONTRACT_NO
FROM EMPLOYEES e
WHERE e.contract_no = ANY (SELECT lead_no
                           FROM research
                           WHERE extract(YEAR FROM start_date) > 2017);
------------------------------------
-- Запрос с использованием предиката (EXISTS) в подзапросе
-- (Вывести названия и бюджет успешных исследований)
SELECT r.title, r.budget
FROM research r
WHERE exists(SELECT 1
             FROM crops c
             WHERE r.res_id = c.rsr_result
               AND c.rsr_result IS NOT NULL);
------------------------------------
-- Запрос на обновление (UPDATE)
-- (если ОАО -> изменить mail домен на 'oao.mail.by'
--  если ЗАО -> изменить mail домен на 'zao.mail.by'
--  во всех остальных изменить mail домен на 'mail.by')
UPDATE customers c
SET c.email =
        CASE
            WHEN c.title LIKE '%ОАО%' THEN
                replace(c.email, substr(c.email, instr(c.email, '@') + 1), 'oao.mail.by')
            WHEN c.title LIKE '%ЗАО%' THEN
                replace(c.email, substr(c.email, instr(c.email, '@') + 1), 'zao.mail.by')
            ELSE
                replace(c.email, substr(c.email, instr(c.email, '@') + 1), 'mail.by')
            END;
------------------------------------
-- Перекрестный запрос (PIVOT)
-- (Вывести динамику проведения исследований по месяцам
-- для степени образования руководителей исследований)
SELECT *
FROM (SELECT edu.edu_type edu_types, extract(month from r.start_date) months
      FROM research r
               INNER JOIN employees e ON r.lead_no = e.contract_no
               INNER JOIN education edu ON edu.edu_no = e.education)
    PIVOT (count(months) FOR months IN (1,2,3,4,5,6,7,8,9,10,11,12));
------------------------------------
