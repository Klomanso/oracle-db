-------------------------------------------TASK_1-----------------------------------------------------------------------
CREATE SEQUENCE inspire.audit_sequence;

CREATE TABLE inspire.audit_customers
(
    log_id      NUMBER,
    action_time TIMESTAMP,
    action_user VARCHAR2(30),
    table_name  VARCHAR2(20),
    dml_command VARCHAR2(10),
    customer_id VARCHAR2(13)
);

CREATE TABLE inspire.audit_customers_values
(
    log_id         NUMBER,
    updated_column VARCHAR2(30),
    old_value      VARCHAR2(80),
    new_value      VARCHAR2(80)
);

CREATE OR REPLACE TRIGGER inspire.audit_customers_trg
    AFTER INSERT OR UPDATE OR DELETE
    ON customers
    FOR EACH ROW
DECLARE
    action_timestamp TIMESTAMP;
BEGIN
    action_timestamp := localtimestamp;
    IF INSERTING THEN
        INSERT INTO audit_customers
        VALUES (audit_sequence.nextval, action_timestamp, User, 'CUSTOMERS', 'INSERT', :NEW.ogrn);
    ELSIF DELETING THEN
        INSERT INTO audit_customers
        VALUES (audit_sequence.nextval, action_timestamp, User, 'CUSTOMERS', 'DELETE', :OLD.ogrn);
    ELSE
        INSERT INTO audit_customers
        VALUES (audit_sequence.nextval, action_timestamp, User, 'CUSTOMERS', 'UPDATE', :OLD.ogrn);
        IF UPDATING ('TITLE') THEN
            INSERT INTO audit_customers_values
            VALUES (audit_sequence.currval, 'TITLE', :OLD.title, :NEW.title);
        END IF;
        IF UPDATING ('EMAIL') THEN
            INSERT INTO audit_customers_values
            VALUES (audit_sequence.currval, 'EMAIL', :OLD.email, :NEW.email);
        END IF;
        IF UPDATING ('PHONE_NUMBER') THEN
            INSERT INTO audit_customers_values
            VALUES (audit_sequence.currval, 'PHONE_NUMBER', :OLD.phone_number, :NEW.phone_number);
        END IF;
    END IF;
END;
-------------------------------------------FINISH_TASK_1----------------------------------------------------------------
-------------------------------------------TASK_2-----------------------------------------------------------------------
CREATE SEQUENCE inspire.audit_ddl_sequence;

CREATE TABLE inspire.audit_ddl
(
    log_id       NUMBER,
    action_time  TIMESTAMP,
    os_user      VARCHAR2(255),
    current_user VARCHAR2(255),
    host         VARCHAR2(255),
    ip           VARCHAR2(255),
    owner        VARCHAR2(30),
    type         VARCHAR2(30),
    name         VARCHAR2(30),
    sys_event    VARCHAR2(30)
);

CREATE OR REPLACE TRIGGER inspire.audit_ddl_trg
    AFTER CREATE OR ALTER OR DROP
    ON SCHEMA
BEGIN
    IF ((to_char(sysdate, 'D') BETWEEN '2' AND '6') AND
        (to_char(sysdate, 'HH24:MI') BETWEEN '09:00' AND '17:00')) THEN
        INSERT INTO audit_ddl
        VALUES (audit_ddl_sequence.nextval, localtimestamp,
                sys_context('USERENV', 'OS_USER'),
                sys_context('USERENV', 'CURRENT_USER'),
                sys_context('USERENV', 'HOST'),
                sys_context('USERENV', 'IP_ADDRESS'),
                ora_dict_obj_owner, ora_dict_obj_type,
                ora_dict_obj_name, ora_sysevent);
    ELSE
        RAISE_APPLICATION_ERROR(-20003,
                                'Unable to perform DDL actions at: ' || to_char(sysdate, 'Day, HH24:MI'));
    END IF;
END;
-------------------------------------------FINISH_TASK_2----------------------------------------------------------------
-------------------------------------------TASK_3-----------------------------------------------------------------------
CREATE SEQUENCE inspire.audit_user_events_sequence;

CREATE TABLE inspire.audit_user_events
(
    log_id      NUMBER,
    action_time TIMESTAMP,
    action_user VARCHAR2(255),
    host        VARCHAR2(255),
    ip          VARCHAR2(255),
    terminal    VARCHAR2(255),
    sys_event   VARCHAR2(30),
    table_rec   NUMBER
);

CREATE OR REPLACE PROCEDURE inspire.log_user_actions IS
    main_table_records PLS_INTEGER;
BEGIN
    SELECT count(*) INTO main_table_records FROM research;
    INSERT INTO audit_user_events
    VALUES (audit_user_events_sequence.nextval, localtimestamp, user,
            sys_context('USERENV', 'HOST'),
            sys_context('USERENV', 'IP_ADDRESS'),
            sys_context('USERENV', 'TERMINAL'),
            ora_sysevent, main_table_records);
    COMMIT;
END;

CREATE OR REPLACE TRIGGER inspire.audit_user_login_trg
    AFTER LOGON
    ON SCHEMA
BEGIN
    log_user_actions();
END;

CREATE OR REPLACE TRIGGER inspire.audit_user_logoff_trg
    BEFORE LOGOFF
    ON SCHEMA
BEGIN
    log_user_actions();
END;
-------------------------------------------FINISH_TASK_3----------------------------------------------------------------
-------------------------------------------TASK_4-----------------------------------------------------------------------
CREATE OR REPLACE TRIGGER inspire.check_employee_birth_date_trg
    BEFORE INSERT OR UPDATE of birth_date
    ON employees
    FOR EACH ROW
BEGIN
    IF (trunc(months_between(sysdate, :NEW.birth_date) / 12) < 18)
    THEN
        RAISE_APPLICATION_ERROR(-20004, 'Birth Date must be > 18');
    END IF;
END;

CREATE OR REPLACE TRIGGER inspire.res_team_check_trg
    AFTER INSERT
    ON RES_TEAM
    FOR EACH ROW
DECLARE
    l_avg_budget            NUMBER(12, 2);
    l_avg_budget_30_percent NUMBER(12, 2);
    old_budget              NUMBER(12, 2);
    new_budget              NUMBER(12, 2);
BEGIN
    SELECT avg(BUDGET) INTO l_avg_budget FROM research;
    l_avg_budget_30_percent := l_avg_budget * 0.3;

    SELECT budget INTO old_budget FROM research WHERE res_id = :NEW.res_id;
    new_budget := old_budget + (0.15 * old_budget);

    IF ((new_budget - l_avg_budget) > l_avg_budget_30_percent) THEN
        IF ((old_budget - l_avg_budget) > l_avg_budget_30_percent) THEN
            new_budget := old_budget;
        ELSE
            new_budget := l_avg_budget + l_avg_budget_30_percent;
        END IF;
    ELSE
        NULL;
    END IF;

    UPDATE research SET budget = new_budget WHERE res_id = :NEW.res_id;
END;

CREATE OR REPLACE TRIGGER inspire.check_research_duration_trg
    BEFORE INSERT OR UPDATE of START_DATE, FINISH_DATE
    ON inspire.RESEARCH
    FOR EACH ROW
DECLARE
    research_month_period PLS_INTEGER;
BEGIN
    IF INSERTING THEN
        research_month_period := abs(months_between(:NEW.finish_date, :NEW.start_date));
        DBMS_OUTPUT.PUT_LINE('Research month period: ' || research_month_period);
        IF (:NEW.finish_date IS NOT NULL) THEN
            IF (research_month_period < 3) OR (research_month_period > 12)
            THEN
                RAISE_APPLICATION_ERROR(-20005, 'Research duration must be in [3,12] month''s period');
            END IF;
        END IF;
    ELSIF UPDATING THEN
        IF UPDATING ('START_DATE') OR UPDATING ('FINISH_DATE') THEN
            RAISE_APPLICATION_ERROR(-20006, 'Unable to update period of the research');
        END IF;
    END IF;
END;

CREATE TABLE inspire.research_log
(
    res_id      NUMBER,
    title       VARCHAR2(150),
    budget      NUMERIC(12, 2),
    start_date  DATE,
    finish_date DATE,
    leader_name VARCHAR2(150),
    team_size   NUMBER,
    log_time    TIMESTAMP
);

CREATE OR REPLACE PROCEDURE inspire.research_log_proc AS
BEGIN
    INSERT INTO research_log
    WITH res_emp_count AS (SELECT res_id, count(*) emp_amount
                           FROM res_team
                           GROUP BY res_id)
    SELECT r.res_id,
           r.title,
           r.budget,
           r.start_date,
           r.finish_date,
           (e.FIRST_NAME || ' ' || e.last_name) leader_name,
           rec.emp_amount,
           systimestamp
    FROM RESEARCH r
             LEFT JOIN EMPLOYEES e ON e.CONTRACT_NO = r.LEAD_NO
             LEFT JOIN res_emp_count rec ON r.res_id = rec.RES_ID
    WHERE r.res_id NOT IN
          (SELECT res_id FROM research_log);
    COMMIT;
END;

BEGIN
    DBMS_SCHEDULER.CREATE_SCHEDULE(
            schedule_name => 'RESEARCH_LOG_SCHEDULE',
            start_date => SYSTIMESTAMP,
            repeat_interval => 'FREQ=MINUTELY;INTERVAL=1;BYSECOND=20',
            end_date => SYSTIMESTAMP + INTERVAL '4' month,
            comments => 'Log research every minute'
        );
END;

BEGIN
    DBMS_SCHEDULER.CREATE_PROGRAM(
            program_name => 'RESEARCH_LOG_PROGRAM',
            enabled => TRUE,
            program_type => 'STORED_PROCEDURE',
            program_action => 'INSPIRE.RESEARCH_LOG_PROC',
            number_of_arguments => 0,
            comments => 'Log research program, invoke in the job'
        );
END;

BEGIN
    DBMS_SCHEDULER.CREATE_JOB(
            job_name => 'RESEARCH_LOG_JOB',
            program_name => 'RESEARCH_LOG_PROGRAM',
            schedule_name => 'RESEARCH_LOG_SCHEDULE',
            enabled => TRUE,
            comments => 'Log research job, enabled'
        );
END;
-------------------------------------------FINISH_TASK_4----------------------------------------------------------------
-------------------------------------------TASK_5-----------------------------------------------------------------------
-- good example of compound trigger (use it)
CREATE OR REPLACE TRIGGER inspire.crops_update_trg
    FOR UPDATE OF winter_hardiness, pd_resistance, yields
    ON crops
    COMPOUND TRIGGER
    TYPE r_crop_type IS RECORD
                        (
                            crop_id      crops.brk_no%TYPE,
                            spec_id      crops.spec_no%TYPE,
                            wh_new_value crops.WINTER_HARDINESS%TYPE,
                            pd_new_value crops.PD_RESISTANCE%TYPE,
                            yd_new_value crops.YIELDS%TYPE
                        );

    TYPE t_crop_type IS TABLE OF r_crop_type INDEX BY pls_integer;

    t_crop t_crop_type;
    l_fixed_info constant varchar2(30) := 'update from trigger';

AFTER EACH ROW IS
    l_info varchar2(30);
BEGIN
    dbms_application_info.read_client_info(l_info);
    IF l_info IS NULL OR l_info != l_fixed_info THEN
        t_crop(t_crop.COUNT + 1).crop_id := :OLD.BRK_NO;
        t_crop(t_crop.COUNT).spec_id := :OLD.spec_no;
        IF UPDATING ('WINTER_HARDINESS') THEN
            t_crop(t_crop.COUNT).wh_new_value := :NEW.WINTER_HARDINESS;
        END IF;
        IF UPDATING ('PD_RESISTANCE') THEN
            t_crop(t_crop.COUNT).pd_new_value := :NEW.PD_RESISTANCE;
        END IF;
        IF UPDATING ('YIELDS') THEN
            t_crop(t_crop.COUNT).yd_new_value := :NEW.YIELDS;
        END IF;
    END IF;
END AFTER EACH ROW;
    AFTER STATEMENT IS
        l_old_info varchar2(30);
    BEGIN
        dbms_application_info.read_client_info(l_old_info);
        dbms_application_info.set_client_info(l_fixed_info);
        FOR idx IN 1..t_crop.COUNT
            LOOP
                IF t_crop(idx).wh_new_value IS NOT NULL THEN
                    UPDATE crops
                    SET WINTER_HARDINESS = t_crop(idx).wh_new_value
                    WHERE spec_no = t_crop(idx).spec_id;
                END IF;
                IF t_crop(idx).pd_new_value IS NOT NULL THEN
                    UPDATE crops
                    SET PD_RESISTANCE = t_crop(idx).pd_new_value
                    WHERE spec_no = t_crop(idx).spec_id;
                END IF;
                IF t_crop(idx).yd_new_value IS NOT NULL THEN
                    UPDATE crops
                    SET YIELDS = t_crop(idx).yd_new_value
                    WHERE spec_no = t_crop(idx).spec_id;
                END IF;
            END LOOP;
        dbms_application_info.set_client_info(l_old_info);
    END AFTER STATEMENT;
    END crops_update_trg;

-- bad example of compound trigger (do not use)
CREATE OR REPLACE TRIGGER inspire.crops_update_trg2
    FOR UPDATE OF winter_hardiness, pd_resistance, yields
    ON crops
    COMPOUND TRIGGER
    TYPE r_crop_type IS RECORD
                        (
                            crop_id          crops.brk_no%TYPE,
                            notes            crops.notes%TYPE,
                            notes_append_rec varchar2(255)
                        );

    TYPE t_crop_type IS TABLE OF r_crop_type INDEX BY pls_integer;

    t_crop t_crop_type;

AFTER EACH ROW IS
BEGIN
    t_crop(t_crop.COUNT + 1).crop_id := :OLD.BRK_NO;
    t_crop(t_crop.COUNT).notes := :OLD.NOTES;

    IF UPDATING ('WINTER_HARDINESS') THEN
        t_crop(t_crop.COUNT).notes_append_rec := concat(t_crop(t_crop.COUNT).notes_append_rec,
                                                        '{ winter_hardiness: ' || :OLD.WINTER_HARDINESS ||
                                                        ' -> ' ||
                                                        :NEW.WINTER_HARDINESS || ' }');
    END IF;
    IF UPDATING ('PD_RESISTANCE') THEN
        t_crop(t_crop.COUNT).notes_append_rec := concat(t_crop(t_crop.COUNT).notes_append_rec,
                                                        '{ pd_resistance: ' || :OLD.PD_RESISTANCE ||
                                                        ' -> ' ||
                                                        :NEW.PD_RESISTANCE || ' }');
    END IF;
    IF UPDATING ('YIELDS') THEN
        t_crop(t_crop.COUNT).notes_append_rec := concat(t_crop(t_crop.COUNT).notes_append_rec,
                                                        '{ yields: ' || :OLD.YIELDS || ' -> ' ||
                                                        :NEW.YIELDS || ' }');
    END IF;
END AFTER EACH ROW;
    AFTER STATEMENT IS
        upd_date_rec varchar2(50);
    BEGIN
        upd_date_rec := concat(' (Updated: ', to_char(sysdate, 'DD-MM-YYYY') || ': ');
        FOR idx IN 1..t_crop.COUNT
            LOOP
                UPDATE crops
                SET notes = concat(t_crop(idx).notes, upd_date_rec || t_crop(idx).notes_append_rec || ')')
                WHERE brk_no = t_crop(idx).crop_id;
            END LOOP;
    END AFTER STATEMENT;
    END crops_update_trg2;
-------------------------------------------FINISH_TASK_5----------------------------------------------------------------
-------------------------------------------TASK_6-----------------------------------------------------------------------
CREATE OR REPLACE TRIGGER inspire.update_view_trg
    INSTEAD OF INSERT OR UPDATE OR DELETE
    on res_customers
    FOR EACH ROW
DECLARE
    rand_customer_id VARCHAR2(13);
BEGIN
    rand_customer_id := substr(to_char(DBMS_RANDOM.value()), 2, 13);
    IF INSERTING THEN
        INSERT INTO CUSTOMERS (OGRN, TITLE, EMAIL, PHONE_NUMBER)
        VALUES (rand_customer_id, :NEW.customer_title, :NEW.customer_email, :NEW.customer_number);
        INSERT INTO research (TITLE, OGRN, START_DATE, FINISH_DATE, BUDGET, LEAD_NO)
        VALUES (:NEW.title, rand_customer_id, :NEW.start_date, :NEW.finish_date, :NEW.budget, null);
    ELSIF UPDATING THEN
        IF UPDATING ('TITLE') THEN
            UPDATE research set title = :NEW.title where title = :OLD.title;
        END IF;
        IF UPDATING ('BUDGET') THEN
            UPDATE research set budget = :NEW.budget where budget = :OLD.budget;
        END IF;
        IF UPDATING ('CUSTOMER_TITLE') THEN
            UPDATE customers c set c.title = :NEW.CUSTOMER_TITLE where c.title = :OLD.CUSTOMER_TITLE;
        END IF;
        IF UPDATING ('CUSTOMER_EMAIL') THEN
            UPDATE customers c set c.EMAIL = :NEW.CUSTOMER_EMAIL where c.EMAIL = :OLD.CUSTOMER_EMAIL;
        END IF;
        IF UPDATING ('CUSTOMER_NUMBER') THEN
            UPDATE customers c set c.PHONE_NUMBER = :NEW.CUSTOMER_NUMBER where c.PHONE_NUMBER = :OLD.CUSTOMER_NUMBER;
        END IF;
        IF UPDATING ('START_DATE') THEN
            RAISE_APPLICATION_ERROR(-20007, 'Unable to update START_DATE in this view');
        END IF;
        IF UPDATING ('FINISH_DATE') THEN
            RAISE_APPLICATION_ERROR(-20007, 'Unable to update FINISH_DATE in this view');
        END IF;
    ELSIF DELETING THEN
        DELETE FROM research r WHERE r.title = :OLD.title;
        DELETE FROM customers c WHERE c.title = :OLD.CUSTOMER_TITLE;
    END IF;
END;
-------------------------------------------FINISH_TASK_6----------------------------------------------------------------