
DROP TABLE IF EXISTS
	species
	, crops
	, res_samples 
	, res_procedures 
	, "procedures" 
	, research 
	, customers 
	, res_team 
	, education 
	, employees 
	, titles
	;

--
-- Name: crops; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE crops (
    brk_no varchar(10) PRIMARY KEY,
    name varchar(80) NOT NULL,
    spec_no int,
    winter_hardiness boolean DEFAULT false,
    pd_resistance boolean DEFAULT false,
    yields boolean DEFAULT false,
    rsr_result int,
    notes text,
    CONSTRAINT crops_brk_no_check CHECK (((brk_no)::text ~ '^\d{4}\Z'::text))
);


--
-- Name: customers; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE customers (
    ogrn varchar(20) PRIMARY KEY,
    title varchar(80) NOT NULL,
    email varchar(50) NOT NULL,
    phone_number varchar(50) NOT NULL,
    CONSTRAINT ogrn_check CHECK (((ogrn)::text ~ '^\d{13}\Z'::text))
);

--
-- Name: education; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE education (
    edu_no serial PRIMARY KEY,
    edu_type varchar(80) NOT NULL
);


--
-- Name: employees; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE employees (
    contract_no varchar(10) PRIMARY KEY,
    first_name varchar(80),
    last_name varchar(80),
    birth_date date NOT NULL,
    hire_date date NOT NULL,
    title int,
    education int,
    CONSTRAINT employees_birth_date_check CHECK ((age(now(), (birth_date)::timestamp with time zone) >= '18 years'::interval)),
    CONSTRAINT employees_contract_no_check CHECK (((contract_no)::text ~ '^\d{7}\Z'::text))
);


--
-- Name: procedures; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE procedures (
    proc_no serial PRIMARY KEY,
    proc_name varchar(80) NOT NULL,
    description text,
    duration interval NOT NULL,
    CONSTRAINT procedures_duration_check CHECK ((duration <= '7 days'::interval))
);

--
-- Name: res_procedures; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE res_procedures (
    res_id int,
    proc_no int,
    PRIMARY KEY (res_id, proc_no)
);

--
-- Name: res_samples; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE res_samples (
    brk_no varchar(10),
    res_id int,
    PRIMARY KEY (brk_no, res_id)
);




--
-- Name: res_team; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE res_team (
    res_id int,
    contract_no varchar(10),
    PRIMARY KEY (res_id, contract_no)
);


--
-- Name: research; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE research (
    res_id serial PRIMARY KEY,
    title varchar(150) NOT NULL,
    ogrn varchar(20),
    from_date date NOT NULL,
    finish_date date NOT NULL,
    budget NUMERIC(12,2),
    lead_no varchar(10),
    CONSTRAINT research_budget_check CHECK ((budget > (0))),
    CONSTRAINT research_duration_check CHECK (((age(finish_date, from_date) >= '3 mons'::interval)
    	AND (age(finish_date, from_date) <= '1 year'::interval)))
);

--
-- Name: species; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE species (
    spec_no serial PRIMARY KEY,
    spec_name varchar(50) NOT NULL
);

--
-- Name: titles; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE titles (
    title_no serial PRIMARY KEY,
    title_name varchar(80) NOT NULL
);


--
-- Name: crops crops_rsr_result_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE crops
    ADD CONSTRAINT crops_rsr_result_fkey FOREIGN KEY (rsr_result) REFERENCES public.research(res_id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: crops crops_spec_no_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE crops
    ADD CONSTRAINT crops_spec_no_fkey FOREIGN KEY (spec_no) REFERENCES public.species(spec_no) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: employees employees_education_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE employees
    ADD CONSTRAINT employees_education_fkey FOREIGN KEY (education) REFERENCES public.education(edu_no) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: employees employees_title_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE employees
    ADD CONSTRAINT employees_title_fkey FOREIGN KEY (title) REFERENCES public.titles(title_no) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: res_procedures res_procedures_proc_no_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE res_procedures
    ADD CONSTRAINT res_procedures_proc_no_fkey FOREIGN KEY (proc_no) REFERENCES public.procedures(proc_no) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: res_procedures res_procedures_res_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE res_procedures
    ADD CONSTRAINT res_procedures_res_id_fkey FOREIGN KEY (res_id) REFERENCES public.research(res_id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: res_samples res_samples_brk_no_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE res_samples
    ADD CONSTRAINT res_samples_brk_no_fkey FOREIGN KEY (brk_no) REFERENCES public.crops(brk_no) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: res_samples res_samples_res_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE res_samples
    ADD CONSTRAINT res_samples_res_id_fkey FOREIGN KEY (res_id) REFERENCES public.research(res_id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: res_team res_team_contract_no_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE res_team
    ADD CONSTRAINT res_team_contract_no_fkey FOREIGN KEY (contract_no) REFERENCES public.employees(contract_no) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: res_team res_team_res_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE res_team
    ADD CONSTRAINT res_team_res_id_fkey FOREIGN KEY (res_id) REFERENCES public.research(res_id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: research research_lead_no_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE research
    ADD CONSTRAINT research_lead_no_fkey FOREIGN KEY (lead_no) REFERENCES public.employees(contract_no) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: research research_ogrn_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE research
    ADD CONSTRAINT research_ogrn_fkey FOREIGN KEY (ogrn) REFERENCES public.customers(ogrn) ON UPDATE CASCADE ON DELETE SET NULL;






















