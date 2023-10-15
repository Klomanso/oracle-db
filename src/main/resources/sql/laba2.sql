-- 1.Условный запрос (Бюджет исследования больше 5000)
SELECT title, budget
FROM research
WHERE budget > 5000
ORDER BY budget;
------------------------------------
-- 2.Параметрический запрос (Предоставить информацию по указанному исследованию(res_id))
SELECT *
FROM research
WHERE res_id = :value;
------------------------------------
-- 3.Запрос на объединение (Вывести полные имена кандидатов наук, которые не были
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
-- 4.Итоговый запрос с использованием JOIN-ON, JOIN-USING, NATURAL-JOIN
-- (Вывести итоговый бюджет исследований в которых в качестве
-- образца использовалась 'вишня')
SELECT sum(r.budget) cherry_full_budget
     , s.spec_name
FROM species s
         NATURAL JOIN crops c
         INNER JOIN res_samples rs USING (BRK_no)
         INNER JOIN research r ON r.RES_ID = rs.RES_ID
WHERE s.spec_name LIKE '%вишня%'
GROUP BY s.spec_name;
------------------------------------
-- 5.Итоговый запрос с использованием группировки по части поля с типом дата
-- (Вывести количество количество исследований по месяцам первого квартала)
WITH first_quarter_count AS (SELECT extract(month from r.finish_date) res_month
                                  , count(*)                          res
                             FROM research r
                             WHERE extract(MONTH FROM r.finish_date) BETWEEN 1 AND 3
                             GROUP BY extract(MONTH FROM r.finish_date)),
     first_quarter_months AS (SELECT rownum AS mon
                              FROM dual
                              CONNECT BY level <= 3)
SELECT to_char(to_date(fqm.mon, 'MM'), 'Month') quarter_month
     , nvl(fqc.res, '0')                        res_amount
FROM first_quarter_months fqm
         LEFT JOIN first_quarter_count fqc
                   ON fqm.mon = fqc.res_month
ORDER BY fqm.mon;
------------------------------------
-- 6.Запрос с внешним соединением(LEFT-JOIN)
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
-- 7.Запрос с внешним соединением(FULL-JOIN)
-- (Вывести названия базовых культур вместе с производными культурами,
-- a также названия и периоды проведения всех исследований)
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
-- 8.Запрос с использованием предиката (IN) в подзапросе
-- (Вывести идентификаторы исследований, которые проводились
-- для открытых акционерных обществ(ОАО))
SELECT res_id
FROM research r
WHERE r.ogrn IN (SELECT ogrn
                 FROM customers
                 WHERE title LIKE '%ОАО%');
------------------------------------
-- 9.Запрос с использованием предиката (ANY) в подзапросе
-- (Вывести имена сотрудников, образование которых
--  соответствует образованию руководителей проводивших исследования)
SELECT e.contract_no, (e.first_name || ' ' || e.last_name) full_name
FROM employees e
WHERE e.education > ANY (SELECT e.education
                         FROM EMPLOYEES e
                                  INNER JOIN research r ON e.contract_no = r.lead_no);
------------------------------------
-- 10.Запрос с использованием предиката (EXISTS) в подзапросе
-- (Вывести названия и бюджет успешных исследований)
SELECT r.title, r.budget
FROM research r
WHERE exists(SELECT 1
             FROM crops c
             WHERE r.res_id = c.rsr_result
               AND c.rsr_result IS NOT NULL);
------------------------------------
-- 11.Запрос на обновление (UPDATE)
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
-- 12.Перекрестный запрос (PIVOT)
-- (Вывести динамику проведения исследований по месяцам
-- для степени образования руководителей исследований)
SELECT *
FROM (SELECT edu.edu_type edu_types, extract(month from r.start_date) months
      FROM research r
               INNER JOIN employees e ON r.lead_no = e.contract_no
               INNER JOIN education edu ON edu.edu_no = e.education)
    PIVOT (count(months) FOR months IN (1,2,3,4,5,6,7,8,9,10,11,12));
------------------------------------
