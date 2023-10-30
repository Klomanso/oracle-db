alter table crops drop constraint crops_rsr_result_fkey;
alter table crops drop constraint crops_spec_no_fkey;
alter table employees drop constraint employees_education_fkey;
alter table employees drop constraint employees_title_fkey;
alter table research drop constraint research_ogrn_fkey;
alter table research drop constraint research_lead_no_fkey;
alter table res_procedures drop constraint res_procedures_proc_no_fkey;
alter table res_procedures drop constraint res_procedures_res_id_fkey;
alter table res_samples drop constraint res_samples_brk_no_fkey;
alter table res_samples drop constraint res_samples_res_id_fkey;
alter table res_team drop constraint res_team_contract_no_fkey;
alter table res_team drop constraint res_team_res_id_fkey;
----------------------------------------------------
drop table INSPIRE.education;
drop table INSPIRE.species;
drop table INSPIRE.titles;
drop table INSPIRE.procedures;
drop table INSPIRE.customers;
drop table INSPIRE.crops;
drop table INSPIRE.employees;
drop table INSPIRE.research;
drop table res_procedures;
drop table res_team;
drop table res_samples;
-- ---------------------------------------
create table INSPIRE.education
(
    edu_no   Number generated always as identity (start with 1 increment by 1 nocache) primary key,
    edu_type varchar2(80) not null
);
-- ---------------------------------------
create table INSPIRE.species
(
    spec_no   Number generated always as identity (start with 1 increment by 1 nocache) primary key,
    spec_name varchar2(50) not null unique
);
-- ---------------------------------------
create table INSPIRE.titles
(
    title_no   Number generated always as identity (start with 1 increment by 1 nocache) primary key,
    title_name varchar2(80) not null
);
-- ---------------------------------------
create table INSPIRE.procedures
(
    proc_no     NUMBER GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1 NOCACHE) PRIMARY KEY,
    proc_name   VARCHAR2(150) NOT NULL,
    description CLOB
);
-- ---------------------------------------
create table INSPIRE.customers
(
    ogrn         varchar2(20) PRIMARY KEY,
    title        varchar(80) NOT NULL,
    email        varchar(50) NOT NULL,
    phone_number varchar(50) NOT NULL,
    CONSTRAINT ogrn_check CHECK (regexp_like(ogrn, '^\d{13}\Z'))
);
-- ---------------------------------------
create table INSPIRE.crops
(
    brk_no           varchar2(10) PRIMARY KEY,
    name             varchar(80) NOT NULL,
    spec_no          int,
    winter_hardiness char(1) check (winter_hardiness in ('Y', 'N')),
    pd_resistance    char(1) check (pd_resistance in ('Y', 'N')),
    yields           char(1) check (yields in ('Y', 'N')),
    rsr_result       int,
    notes            clob,
    CONSTRAINT crops_brk_no_check CHECK (regexp_like(brk_no, '^\d{4}\Z'))
);
-- ---------------------------------------
create table INSPIRE.employees
(
    contract_no varchar(10) PRIMARY KEY,
    first_name  varchar(80),
    last_name   varchar(80),
    birth_date  date NOT NULL,
    hire_date   date NOT NULL,
    title       int,
    education   int,
    CONSTRAINT employees_contract_no_check CHECK (regexp_like(contract_no, '^\d{7}\Z'))
);

-- ---------------------------------------

create table INSPIRE.research
(
    res_id      NUMBER GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1 NOCACHE) PRIMARY KEY,
    title       VARCHAR(150) NOT NULL,
    ogrn        VARCHAR(20),
    start_date  DATE         NOT NULL,
    finish_date DATE,
    budget      NUMERIC(12, 2),
    lead_no     varchar(10),
    CONSTRAINT research_budget_check CHECK ((budget > (0)))
);

-- -----------------------------------
CREATE TABLE res_procedures
(
    res_id  int,
    proc_no int,
    PRIMARY KEY (res_id, proc_no)
);

CREATE TABLE res_samples
(
    brk_no varchar(10),
    res_id int,
    PRIMARY KEY (brk_no, res_id)
);

CREATE TABLE res_team
(
    res_id      int,
    contract_no varchar(10),
    PRIMARY KEY (res_id, contract_no)
);

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

CREATE INDEX test_idx ON customers(email);

CREATE OR REPLACE SYNONYM workers FOR inspire.employees;