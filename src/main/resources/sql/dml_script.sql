ALTER TABLE CROPS DROP CONSTRAINT CROPS_RSR_RESULT_FKEY;
ALTER TABLE CROPS DROP CONSTRAINT CROPS_SPEC_NO_FKEY;
ALTER TABLE EMPLOYEES DROP CONSTRAINT EMPLOYEES_EDUCATION_FKEY;
ALTER TABLE EMPLOYEES DROP CONSTRAINT EMPLOYEES_TITLE_FKEY;
ALTER TABLE RESEARCH DROP CONSTRAINT RESEARCH_OGRN_FKEY;
ALTER TABLE RESEARCH DROP CONSTRAINT RESEARCH_LEAD_NO_FKEY;
ALTER TABLE RES_PROCEDURES DROP CONSTRAINT RES_PROCEDURES_PROC_NO_FKEY;
ALTER TABLE RES_PROCEDURES DROP CONSTRAINT RES_PROCEDURES_RES_ID_FKEY;
ALTER TABLE RES_SAMPLES DROP CONSTRAINT RES_SAMPLES_BRK_NO_FKEY;
ALTER TABLE RES_SAMPLES DROP CONSTRAINT RES_SAMPLES_RES_ID_FKEY;
ALTER TABLE RES_TEAM DROP CONSTRAINT RES_TEAM_CONTRACT_NO_FKEY;
ALTER TABLE RES_TEAM DROP CONSTRAINT RES_TEAM_RES_ID_FKEY;
----------------------------------------------------------
TRUNCATE TABLE TITLES;
TRUNCATE TABLE EDUCATION;
TRUNCATE TABLE SPECIES;
TRUNCATE TABLE CUSTOMERS;
TRUNCATE TABLE PROCEDURES;
TRUNCATE TABLE EMPLOYEES;
TRUNCATE TABLE RESEARCH;
TRUNCATE TABLE CROPS;
TRUNCATE TABLE RES_TEAM;
TRUNCATE TABLE RES_SAMPLES;
TRUNCATE TABLE RES_PROCEDURES;
----------------------------------------------------------
ALTER TABLE crops
    ADD CONSTRAINT crops_rsr_result_fkey FOREIGN KEY (rsr_result) REFERENCES INSPIRE.research (res_id) ON DELETE SET NULL;
ALTER TABLE crops
    ADD CONSTRAINT crops_spec_no_fkey FOREIGN KEY (spec_no) REFERENCES INSPIRE.species (spec_no) ON DELETE SET NULL;
ALTER TABLE employees
    ADD CONSTRAINT employees_education_fkey FOREIGN KEY (education) REFERENCES INSPIRE.education(edu_no) ON DELETE SET NULL;
ALTER TABLE employees
    ADD CONSTRAINT employees_title_fkey FOREIGN KEY (title) REFERENCES INSPIRE.titles(title_no) ON DELETE SET NULL;
ALTER TABLE res_procedures
    ADD CONSTRAINT res_procedures_proc_no_fkey FOREIGN KEY (proc_no) REFERENCES INSPIRE.procedures(proc_no) ON DELETE SET NULL;
ALTER TABLE res_procedures
    ADD CONSTRAINT res_procedures_res_id_fkey FOREIGN KEY (res_id) REFERENCES INSPIRE.research(res_id);
ALTER TABLE res_samples
    ADD CONSTRAINT res_samples_brk_no_fkey FOREIGN KEY (brk_no) REFERENCES INSPIRE.crops(brk_no) ON DELETE SET NULL;
ALTER TABLE res_samples
    ADD CONSTRAINT res_samples_res_id_fkey FOREIGN KEY (res_id) REFERENCES INSPIRE.research(res_id);
ALTER TABLE res_team
    ADD CONSTRAINT res_team_contract_no_fkey FOREIGN KEY (contract_no) REFERENCES INSPIRE.employees(contract_no) ON DELETE SET NULL;
ALTER TABLE res_team
    ADD CONSTRAINT res_team_res_id_fkey FOREIGN KEY (res_id) REFERENCES INSPIRE.research(res_id);
ALTER TABLE research
    ADD CONSTRAINT research_lead_no_fkey FOREIGN KEY (lead_no) REFERENCES INSPIRE.employees(contract_no) ON DELETE SET NULL;
ALTER TABLE research
    ADD CONSTRAINT research_ogrn_fkey FOREIGN KEY (ogrn) REFERENCES INSPIRE.customers(ogrn) ON DELETE SET NULL;
----------------------------------------------------------
alter table TITLES modify (TITLE_NO generated as identity (start with 1 increment by 1 nocache));
alter table EDUCATION modify (EDU_NO generated as identity (start with 1 increment by 1 nocache));
alter table SPECIES modify (SPEC_NO generated as identity (start with 1 increment by 1 nocache));
alter table PROCEDURES modify (PROC_NO generated as identity (start with 1 increment by 1 nocache));
alter table RESEARCH modify (RES_ID generated as identity (start with 1 increment by 1 nocache));
----------------------------------------------------------
BEGIN
    INSERT INTO species (spec_name) values ('яблоня');
    INSERT INTO species (spec_name) values ('черешня');
    INSERT INTO species (spec_name) values ('смородина');
    INSERT INTO species (spec_name) values ('слива');
    INSERT INTO species (spec_name) values ('персик');
    INSERT INTO species (spec_name) values ('груша');
    INSERT INTO species (spec_name) values ('вишня');
    INSERT INTO species (spec_name) values ('алыча');
    INSERT INTO species (spec_name) values ('айва');
    INSERT INTO species (spec_name) values ('абрикос');
    INSERT INTO species (spec_name) values ('черемуха');
END;

begin
    INSERT INTO titles (title_name) VALUES ('ученый биолог');
    INSERT INTO titles (title_name) VALUES ('специалист генной инженерии');
    INSERT INTO titles (title_name) VALUES ('технолог пищевой промышленности');
    INSERT INTO titles (title_name) VALUES ('эксперт по качеству');
    INSERT INTO titles (title_name) VALUES ('эколог');
    INSERT INTO titles (title_name) VALUES ('нутрициолог');
    INSERT INTO titles (title_name) VALUES ('биохимик');
    INSERT INTO titles (title_name) VALUES ('биотехнолог');
    INSERT INTO titles (title_name) VALUES ('генетик');
    INSERT INTO titles (title_name) VALUES ('инженер технолог');
end;

begin
    INSERT INTO education (edu_type) VALUES ('среднее');
    INSERT INTO education (edu_type) VALUES ('среднее специальное');
    INSERT INTO education (edu_type) VALUES ('неоконченное высшее');
    INSERT INTO education (edu_type) VALUES ('высшее');
    INSERT INTO education (edu_type) VALUES ('бакалавр');
    INSERT INTO education (edu_type) VALUES ('магистр');
    INSERT INTO education (edu_type) VALUES ('кандидат наук');
    INSERT INTO education (edu_type) VALUES ('доктор наук');
end;

begin
    INSERT INTO customers (ogrn, title, email, phone_number)
    VALUES ('1027739642281', 'фермерское хозяйство ГАСПАДАР', 'gaspadar@mail.by', '+375298572323');
    INSERT INTO customers (ogrn, title, email, phone_number)
    VALUES ('1935729642891', 'Зара-Агро ЗАО', 'zara.agro@mail.by', '+375294562623');
    INSERT INTO customers (ogrn, title, email, phone_number)
    VALUES ('1867819241701', 'фермерское хозяйство КРЫНИЦА', 'krunica@mail.by', '+375290172092');
    INSERT INTO customers (ogrn, title, email, phone_number)
    VALUES ('1044553943101', 'Городея ОАО', 'gorodia@mail.by', '+375298572323');
    INSERT INTO customers (ogrn, title, email, phone_number)
    VALUES ('1072337844141', 'МилкСервисПлюс ОАО', 'milkservice@mail.by', '+375292572733');
    INSERT INTO customers (ogrn, title, email, phone_number)
    VALUES ('1125139845201', 'Наномир фермерское хозяйство', 'nanomir@mail.by', '+375455723239');
    INSERT INTO customers (ogrn, title, email, phone_number)
    VALUES ('1028933646301', 'Крестьянское хозяйство ЗАО', 'kres.grodno@mail.io', '+375298571234');
    INSERT INTO customers (ogrn, title, email, phone_number)
    VALUES ('1621131446411', 'Гродно КУЛЬТХОЗ', 'kultxoz@mail.by', '+375673542312');
    INSERT INTO customers (ogrn, title, email, phone_number)
    VALUES ('1991232648581', 'Алесин сад ОАО', 'aleci.sad@gmail.com', '+375298796323');
end;

begin
    INSERT INTO procedures (proc_name, description)
    VALUES ('Высадка образца в грунт и адаптация в условиях', 'Приготовить почвенную смесь,
		насыпать почвенную смесь в бюксы для прогревания, 
	 	заполнить горшки почвенной смесью опустить микрорастение в слабый раствор перманганата калия,
	 	полить почвенную смесь слабым раствором перманганата калия, 
		сделать углубление в почве');
    INSERT INTO procedures (proc_name, description)
    VALUES ('Проведения анализа ПЦР продуктов в агарозном геле', 'Биомолекулы разделяются под действием электрического поля.
		Для перемещения заряженных молекул через матрицу агарозы, и биомолекулы разделяются по размеру в матрице геля агарозы.
		Большинство используемых гелей агарозы растворены на 0,7–2% в подходящем буфере для электрофореза.');
    INSERT INTO procedures (proc_name, description)
    VALUES ('Оценка засухоустойчивости', 'Определить физиологические изменения параметров водного режима
		растений в условиях засухи');
    INSERT INTO procedures (proc_name, description)
    VALUES ('Определение PH солевой вытяжки по методу цинао в почве участка', 'Упорядочить процесс агрохимического мониторинга почвы опытного
		участка, занятого БРК');
    INSERT INTO procedures (proc_name, description)
    VALUES ('Определение содержания углерода орг. соединений в почве участка', 'Упорядочить процесс агрохимического мониторинга почвы опытного
		участка, занятого БРК');
    INSERT INTO procedures (proc_name, description)
    VALUES ('Фенотипическая оценка растений', 'Фенотипическая оценка растений по способности к вегетативному
		размножению');
    INSERT INTO procedures (proc_name, description)
    VALUES ('Оценка ценности для технологической обработки', 'Определить пригодность плодов для производства варенья');
    INSERT INTO procedures (proc_name, description)
    VALUES ('Выделение ДНК из листьев', 'Лаборатория биохимической генетики');
    INSERT INTO procedures (proc_name, description)
    VALUES ('Ускорение микропобегов', 'Стимулировать корнеобразование у микропобега');
end;

begin
    INSERT INTO crops (brk_no, name, spec_no, winter_hardiness, pd_resistance, yields, rsr_result, notes)
    VALUES ('0001', 'Абориген', 1, 'Y', 'N', 'Y', NULL, 'Летний сорт, выведен в Дальневосточном научно-исследовательском институте сельского хозяйства от скрещивания
	сортов Августовское дальневосточное и Ребристое. Автор сорта А.В. Болоняев. Включен в Госреестр в 1974 году по Дальневосточному региону.');
    INSERT INTO crops (brk_no, name, spec_no, winter_hardiness, pd_resistance, yields, rsr_result, notes)
    VALUES ('0002', 'Аделина', 2, 'Y', 'Y', 'Y', NULL,
            'Оригинатор – Всероссийский НИИ генетики и селекции плодовых растений и Всероссийский НИИ селекции плодовых культур.');
    INSERT INTO crops (brk_no, name, spec_no, winter_hardiness, pd_resistance, yields, rsr_result, notes)
    VALUES ('0003', 'Алексий', 3, 'Y', 'N', 'Y', NULL,
            'Сорт получен во Всероссийском селекционно-технологическом институте садоводства и питомниководства из семян от свободного опыления сорта Занятная.');
    INSERT INTO crops (brk_no, name, spec_no, winter_hardiness, pd_resistance, yields, rsr_result, notes)
    VALUES ('0004', 'Гринсборо', 4, 'N', 'N', 'N', NULL,
            ' Дерево сильнорослое, крона раскидистая. Цветки розовидные.');
    INSERT INTO crops (brk_no, name, spec_no, winter_hardiness, pd_resistance, yields, rsr_result, notes)
    VALUES ('0005', 'Августинка', 5, 'Y', 'Y', 'N', NULL,
            'Побеги серовато-коричневые, толстые, коленчатые. Почки не прижатые, средней величины. Листья средней величины, зеленые. Листовая пластинка гладкая с волнистостью, изогнутая по центральной жилке.');
    INSERT INTO crops (brk_no, name, spec_no, winter_hardiness, pd_resistance, yields, rsr_result, notes)
    VALUES ('0006', 'Аляевская', 6, 'N', 'Y', 'N', NULL,
            'Поздняя розовая х Полжир. Оригинатор – Татарский НИИСХ. Авторы: Л.А. Севастьянова, В.А. Наумов. В госсортоиспытании с 1994 г.');
    INSERT INTO crops (brk_no, name, spec_no, winter_hardiness, pd_resistance, yields, rsr_result, notes)
    VALUES ('0007', 'Анастасия', 7, 'N', 'Y', 'N', NULL,
            ' Дерево сильнорослое. Крона широкопирамидальная, раскидистая, средней густоты.');
end;

begin
    INSERT INTO employees (contract_no, first_name, last_name, birth_date, hire_date, title, education)
    VALUES ('1194561', 'Георгий', 'Белов', to_date('1986-09-12', 'YYYY-MM-DD'), to_date('2003-12-26', 'YYYY-MM-DD'), 1,
            1);
    INSERT INTO employees (contract_no, first_name, last_name, birth_date, hire_date, title, education)
    VALUES ('1194161', 'Георгий', 'Хрипенко', to_date('1986-09-12', 'YYYY-MM-DD'), to_date('2003-12-26', 'YYYY-MM-DD'),
            1,
            7);
    INSERT INTO employees (contract_no, first_name, last_name, birth_date, hire_date, title, education)
    VALUES ('1115692', 'Мирослава', 'Бородина', to_date('1986-09-12', 'YYYY-MM-DD'),
            to_date('2003-11-24', 'YYYY-MM-DD'), 2, 2);
    INSERT INTO employees (contract_no, first_name, last_name, birth_date, hire_date, title, education)
    VALUES ('1010693', 'Георгий', 'Гришин', to_date('1985-09-12', 'YYYY-MM-DD'), to_date('2005-10-29', 'YYYY-MM-DD'), 3,
            3);
    INSERT INTO employees (contract_no, first_name, last_name, birth_date, hire_date, title, education)
    VALUES ('1323694', 'Ксения', 'Петрова', to_date('1984-09-12', 'YYYY-MM-DD'), to_date('2004-09-12', 'YYYY-MM-DD'), 4,
            4);
    INSERT INTO employees (contract_no, first_name, last_name, birth_date, hire_date, title, education)
    VALUES ('1239695', 'Арина', 'Тихомирова', to_date('1983-09-12', 'YYYY-MM-DD'), to_date('2017-08-11', 'YYYY-MM-DD'),
            5, 5);
    INSERT INTO employees (contract_no, first_name, last_name, birth_date, hire_date, title, education)
    VALUES ('1423696', 'Павел', 'Козловский', to_date('1982-09-12', 'YYYY-MM-DD'), to_date('2017-07-10', 'YYYY-MM-DD'),
            6, 6);
    INSERT INTO employees (contract_no, first_name, last_name, birth_date, hire_date, title, education)
    VALUES ('1946697', 'Георгий', 'Филиппов', to_date('1986-09-12', 'YYYY-MM-DD'), to_date('2017-06-09', 'YYYY-MM-DD'),
            7, 7);
    INSERT INTO employees (contract_no, first_name, last_name, birth_date, hire_date, title, education)
    VALUES ('1954698', 'Артём', 'Фирсов', to_date('1986-09-12', 'YYYY-MM-DD'), to_date('2016-05-04', 'YYYY-MM-DD'), 8,
            8);
    INSERT INTO employees (contract_no, first_name, last_name, birth_date, hire_date, title, education)
    VALUES ('1974699', 'Мия', 'Крылова', to_date('1987-09-12', 'YYYY-MM-DD'), to_date('2009-04-04', 'YYYY-MM-DD'), 9,
            4);
    INSERT INTO employees (contract_no, first_name, last_name, birth_date, hire_date, title, education)
    VALUES ('1903695', 'Варвара', 'Трифонова', to_date('1988-09-12', 'YYYY-MM-DD'), to_date('2010-03-08', 'YYYY-MM-DD'),
            3, 5);
    INSERT INTO employees (contract_no, first_name, last_name, birth_date, hire_date, title, education)
    VALUES ('1994694', 'Владимир', 'Кудрявцев', to_date('1989-09-12', 'YYYY-MM-DD'),
            to_date('2016-02-07', 'YYYY-MM-DD'), 1, 6);
    INSERT INTO employees (contract_no, first_name, last_name, birth_date, hire_date, title, education)
    VALUES ('1003693', 'Милана', 'Сорокина', to_date('1990-09-12', 'YYYY-MM-DD'), to_date('2015-01-18', 'YYYY-MM-DD'),
            2, 5);
    INSERT INTO employees (contract_no, first_name, last_name, birth_date, hire_date, title, education)
    VALUES ('1042692', 'Георгий', 'Исаев', to_date('1991-09-12', 'YYYY-MM-DD'), to_date('2014-01-17', 'YYYY-MM-DD'), 3,
            4);
    INSERT INTO employees (contract_no, first_name, last_name, birth_date, hire_date, title, education)
    VALUES ('1093691', 'Александр', 'Смирнов', to_date('1995-09-12', 'YYYY-MM-DD'), to_date('2018-01-16', 'YYYY-MM-DD'),
            4, 6);
    INSERT INTO employees (contract_no, first_name, last_name, birth_date, hire_date, title, education)
    VALUES ('1004697', 'Таисия', 'Черкасова', to_date('1999-09-12', 'YYYY-MM-DD'), to_date('2019-12-15', 'YYYY-MM-DD'),
            5, 7);
    INSERT INTO employees (contract_no, first_name, last_name, birth_date, hire_date, title, education)
    VALUES ('1075698', 'Нелли', 'Воробьева', to_date('1975-09-12', 'YYYY-MM-DD'), to_date('2004-12-14', 'YYYY-MM-DD'),
            6, 4);
    INSERT INTO employees (contract_no, first_name, last_name, birth_date, hire_date, title, education)
    VALUES ('1020699', 'Владимир', 'Исаев', to_date('1965-09-12', 'YYYY-MM-DD'), to_date('2002-04-04', 'YYYY-MM-DD'), 7,
            5);
    INSERT INTO employees (contract_no, first_name, last_name, birth_date, hire_date, title, education)
    VALUES ('1874694', 'Вероника', 'Белова', to_date('1973-09-12', 'YYYY-MM-DD'), to_date('2001-04-03', 'YYYY-MM-DD'),
            8, 6);
    INSERT INTO employees (contract_no, first_name, last_name, birth_date, hire_date, title, education)
    VALUES ('1750693', 'Владимир', 'Белов', to_date('1974-09-12', 'YYYY-MM-DD'), to_date('2000-05-02', 'YYYY-MM-DD'), 9,
            7);
    INSERT INTO employees (contract_no, first_name, last_name, birth_date, hire_date, title, education)
    VALUES ('1650691', 'Полина', 'Булатова', to_date('2001-09-12', 'YYYY-MM-DD'), to_date('2020-05-01', 'YYYY-MM-DD'),
            10, 4);
end;

begin
    INSERT INTO research (title, ogrn, start_date, finish_date, budget, lead_no)
    VALUES ('Выведение позднезимнего сорта яблока', '1027739642281', to_date('2022-04-03', 'YYYY-MM-DD'),
            to_date('2022-09-08', 'YYYY-MM-DD'), 5510, '1750693');
    INSERT INTO research (title, ogrn, start_date, finish_date, budget, lead_no)
    VALUES ('Выведение летнего сорта груши', '1935729642891', to_date('2021-12-23', 'YYYY-MM-DD'),
            to_date('2022-03-24', 'YYYY-MM-DD'), 3501, '1954698');
    INSERT INTO research (title, ogrn, start_date, finish_date, budget, lead_no)
    VALUES ('Селекция среднерослых культур', '1867819241701', to_date('2020-11-11', 'YYYY-MM-DD'),
            to_date('2021-11-04', 'YYYY-MM-DD'), 7500, '1423696');
    INSERT INTO research (title, ogrn, start_date, finish_date, budget, lead_no)
    VALUES ('Исследование морозостойкости персиковых культур', '1044553943101', to_date('2019-10-12', 'YYYY-MM-DD'),
            to_date('2020-09-09', 'YYYY-MM-DD'), 8500,
            '1423696');
    INSERT INTO research (title, ogrn, start_date, finish_date, budget, lead_no)
    VALUES ('Селекция сеянцев абрикоса', '1125139845201', to_date('2018-09-12', 'YYYY-MM-DD'),
            to_date('2019-05-27', 'YYYY-MM-DD'), 6220, '1020699');
    INSERT INTO research (title, ogrn, start_date, finish_date, budget, lead_no)
    VALUES ('Исследование урожайности степных сортов вишни', '1028933646301', to_date('2017-08-13', 'YYYY-MM-DD'),
            to_date('2018-06-03', 'YYYY-MM-DD'), 9512,
            '1994694');
    INSERT INTO research (title, ogrn, start_date, finish_date, budget, lead_no)
    VALUES ('Исследование устойчивости к вредителям садовых культур', '1028933646301',
            to_date('2016-07-17', 'YYYY-MM-DD'), to_date('2017-02-17', 'YYYY-MM-DD'), 5500,
            '1994694');
    INSERT INTO research (title, ogrn, start_date, finish_date, budget, lead_no)
    VALUES ('Селекция урожайных сортов персика', '1621131446411', to_date('2015-06-18', 'YYYY-MM-DD'),
            to_date('2015-12-18', 'YYYY-MM-DD'), 5500, '1020699');
    INSERT INTO research (title, ogrn, start_date, finish_date, budget, lead_no)
    VALUES ('Выведение крупных сортов сливы', '1991232648581', to_date('2014-05-19', 'YYYY-MM-DD'),
            to_date('2014-10-20', 'YYYY-MM-DD'), 3298, '1954698');
    INSERT INTO research (title, ogrn, start_date, finish_date, budget, lead_no)
    VALUES ('Выведение сортов смородины позднего срока созревания', '1125139845201',
            to_date('2013-04-20', 'YYYY-MM-DD'), to_date('2013-09-10', 'YYYY-MM-DD'), 3456,
            '1750693');
end;
BEGIN
    INSERT INTO crops (brk_no, name, spec_no, winter_hardiness, pd_resistance, yields, rsr_result, notes)
    VALUES ('0008', 'Аврора', 8, 'N', 'Y', 'N', 3,
            'Сорт выведен в Северо-Кавказском зональном научно-исследовательском институте садоводства и виноградарства (г. Краснодар)');
    INSERT INTO crops (brk_no, name, spec_no, winter_hardiness, pd_resistance, yields, rsr_result, notes)
    VALUES ('0009', 'Айсберг', 9, 'N', 'Y', 'N', 8,
            ' Деревья небольших размеров (3 м), сила роста умеренная. Однолетние побеги сильно ветвистые. Цветки крупные 3,5-4 см, белые.');
    INSERT INTO crops (brk_no, name, spec_no, winter_hardiness, pd_resistance, yields, rsr_result, notes)
    VALUES ('0010', 'Мавра', 10, 'Y', 'Y', 'Y', 1,
            'Гибрид от скрещивания формы № 1-5-13 черемухи виргинской с формой № 5-28-10 черемухи кистевой. Оригинатор – Центральный сибирский ботанический сад');
END;

begin
    INSERT INTO res_team (res_id, contract_no)
    VALUES (1, '1323694');
    INSERT INTO res_team (res_id, contract_no)
    VALUES (1, '1042692');
    INSERT INTO res_team (res_id, contract_no)
    VALUES (1, '1093691');
    INSERT INTO res_team (res_id, contract_no)
    VALUES (1, '1650691');
    INSERT INTO res_team (res_id, contract_no)
    VALUES (2, '1323694');
    INSERT INTO res_team (res_id, contract_no)
    VALUES (2, '1042692');
    INSERT INTO res_team (res_id, contract_no)
    VALUES (2, '1093691');
    INSERT INTO res_team (res_id, contract_no)
    VALUES (3, '1239695');
    INSERT INTO res_team (res_id, contract_no)
    VALUES (3, '1003693');
    INSERT INTO res_team (res_id, contract_no)
    VALUES (3, '1004697');
    INSERT INTO res_team (res_id, contract_no)
    VALUES (4, '1239695');
    INSERT INTO res_team (res_id, contract_no)
    VALUES (4, '1003693');
    INSERT INTO res_team (res_id, contract_no)
    VALUES (4, '1004697');
    INSERT INTO res_team (res_id, contract_no)
    VALUES (5, '1423696');
    INSERT INTO res_team (res_id, contract_no)
    VALUES (5, '1994694');
    INSERT INTO res_team (res_id, contract_no)
    VALUES (5, '1075698');
    INSERT INTO res_team (res_id, contract_no)
    VALUES (6, '1423696');
    INSERT INTO res_team (res_id, contract_no)
    VALUES (6, '1994694');
    INSERT INTO res_team (res_id, contract_no)
    VALUES (6, '1075698');
    INSERT INTO res_team (res_id, contract_no)
    VALUES (7, '1946697');
    INSERT INTO res_team (res_id, contract_no)
    VALUES (7, '1903695');
    INSERT INTO res_team (res_id, contract_no)
    VALUES (7, '1020699');
    INSERT INTO res_team (res_id, contract_no)
    VALUES (8, '1946697');
    INSERT INTO res_team (res_id, contract_no)
    VALUES (8, '1903695');
    INSERT INTO res_team (res_id, contract_no)
    VALUES (8, '1020699');
    INSERT INTO res_team (res_id, contract_no)
    VALUES (9, '1954698');
    INSERT INTO res_team (res_id, contract_no)
    VALUES (9, '1974699');
    INSERT INTO res_team (res_id, contract_no)
    VALUES (9, '1874694');
    INSERT INTO res_team (res_id, contract_no)
    VALUES (10, '1954698');
    INSERT INTO res_team (res_id, contract_no)
    VALUES (10, '1974699');
    INSERT INTO res_team (res_id, contract_no)
    VALUES (10, '1750693');
end;

begin
    INSERT INTO res_samples (brk_no, res_id)
    VALUES ('0002', 1);
    INSERT INTO res_samples (brk_no, res_id)
    VALUES ('0001', 1);
    INSERT INTO res_samples (brk_no, res_id)
    VALUES ('0003', 2);
    INSERT INTO res_samples (brk_no, res_id)
    VALUES ('0004', 2);
    INSERT INTO res_samples (brk_no, res_id)
    VALUES ('0005', 4);
    INSERT INTO res_samples (brk_no, res_id)
    VALUES ('0008', 5);
    INSERT INTO res_samples (brk_no, res_id)
    VALUES ('0008', 6);
    INSERT INTO res_samples (brk_no, res_id)
    VALUES ('0007', 8);
    INSERT INTO res_samples (brk_no, res_id)
    VALUES ('0010', 9);
    INSERT INTO res_samples (brk_no, res_id)
    VALUES ('0007', 9);
    INSERT INTO res_samples (brk_no, res_id)
    VALUES ('0009', 10);
end;

select * from PROCEDURES;

begin
    INSERT INTO res_procedures (res_id, proc_no)
    VALUES (1, 3);
    INSERT INTO res_procedures (res_id, proc_no)
    VALUES (2, 2);
    INSERT INTO res_procedures (res_id, proc_no)
    VALUES (2, 3);
    INSERT INTO res_procedures (res_id, proc_no)
    VALUES (3, 9);
    INSERT INTO res_procedures (res_id, proc_no)
    VALUES (3, 8);
    INSERT INTO res_procedures (res_id, proc_no)
    VALUES (3, 7);
    INSERT INTO res_procedures (res_id, proc_no)
    VALUES (4, 6);
    INSERT INTO res_procedures (res_id, proc_no)
    VALUES (4, 5);
    INSERT INTO res_procedures (res_id, proc_no)
    VALUES (4, 4);
    INSERT INTO res_procedures (res_id, proc_no)
    VALUES (5, 3);
    INSERT INTO res_procedures (res_id, proc_no)
    VALUES (5, 7);
    INSERT INTO res_procedures (res_id, proc_no)
    VALUES (6, 9);
    INSERT INTO res_procedures (res_id, proc_no)
    VALUES (7, 8);
    INSERT INTO res_procedures (res_id, proc_no)
    VALUES (7, 7);
    INSERT INTO res_procedures (res_id, proc_no)
    VALUES (8, 6);
    INSERT INTO res_procedures (res_id, proc_no)
    VALUES (8, 5);
    INSERT INTO res_procedures (res_id, proc_no)
    VALUES (9, 4);
    INSERT INTO res_procedures (res_id, proc_no)
    VALUES (10, 3);
    INSERT INTO res_procedures (res_id, proc_no)
    VALUES (10, 2);
    INSERT INTO res_procedures (res_id, proc_no)
    VALUES (10, 4);
end;