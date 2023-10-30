-- <5+ package>
CREATE OR REPLACE PACKAGE lab_4 IS

    -- constants
    gc_task_option CONSTANT VARCHAR2(40) := 'Вариант 19 -> (Science Institute)';
    gc_task_function_description CONSTANT VARCHAR2(255)
        := 'Написать функцию, подсчитывающую количество сотрудников с заданным образованием';
    gc_task_procedure_description VARCHAR2(255)
        := 'Создать процедуру, "переводящую" культуры заданного вида ' ||
           'в другие виды с сохранением "результата исследования"';

    -- functions
    FUNCTION count_emp_by(in_edu_no IN NUMBER) RETURN NUMBER;
    FUNCTION count_emp_by(in_edu_type IN VARCHAR2) RETURN NUMBER;

    -- procedures
    PROCEDURE eradicate_species(in_target_species IN species.spec_name%TYPE);

END lab_4;

CREATE OR REPLACE PACKAGE BODY lab_4 AS
    -- <2+ function>
    FUNCTION count_emp_by(in_edu_no IN NUMBER) RETURN NUMBER IS

        -- variables
        l_total_emp PLS_INTEGER := 0;

    BEGIN
        SELECT total
        INTO l_total_emp
        FROM (SELECT count(*) total
              FROM employees e
                       INNER JOIN education edu ON e.education = edu.edu_no
              WHERE edu.edu_no = in_edu_no);
        -- <2.2+ dbms_output>
        dbms_output.put_line('Education id: ' || in_edu_no);
        dbms_output.put_line('Number of records: ' || l_total_emp);
        RETURN l_total_emp;
    EXCEPTION
        WHEN OTHERS THEN
            dbms_output.put_line('Oops! Something went wrong!');
            dbms_output.put_line('Error code: ' || sqlcode);
            dbms_output.put_line('Error message: ' || sqlerrm);
            RETURN l_total_emp;
    END;

    -- <4+ function overloading>
    FUNCTION count_emp_by(in_edu_type VARCHAR2) RETURN NUMBER IS

        -- variables
        l_total_emp PLS_INTEGER := 0;

        -- exceptions
        e_bad_education_type EXCEPTION;
        PRAGMA EXCEPTION_INIT (e_bad_education_type, -20001);

        -- local module <3+ local module>
        FUNCTION is_valid_education_type(in_edu_type education.edu_type%TYPE) RETURN BOOLEAN AS
            l_tst PLS_INTEGER;
        BEGIN
            SELECT 1 into l_tst FROM education WHERE edu_type = in_edu_type;
            RETURN TRUE;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                RETURN FALSE;
        END;
    BEGIN
        IF is_valid_education_type(in_edu_type) THEN
            SELECT total
            INTO l_total_emp
            FROM (SELECT count(*) total
                  FROM employees e
                           INNER JOIN education edu ON e.education = edu.edu_no
                  WHERE edu.edu_type = in_edu_type);
        ELSE
            RAISE e_bad_education_type;
        END IF;
        dbms_output.put_line('Education type: ' || in_edu_type);
        dbms_output.put_line('Number of records: ' || l_total_emp);
        RETURN l_total_emp;
    EXCEPTION
        -- <2.3+ user and system exception handling>
        WHEN e_bad_education_type THEN
            dbms_output.put_line('Oops! <' || in_edu_type || '> is invalid education type!');
            RETURN l_total_emp;
        WHEN
            OTHERS THEN
            dbms_output.put_line('Oops! Something went wrong!');
            dbms_output.put_line('Error code: ' || sqlcode);
            dbms_output.put_line('Error message: ' || sqlerrm);
            RETURN l_total_emp;
    END;

    -- <1+ procedure>
    -- Удалить заданный вид. Культуры удаленного вида переопределить
    -- в другие виды по принципу: если культура является результатом исследования,
    -- задать вид из списка культур, которые также являются рез-ми исследований;
    -- если культура базовая, задать вид из списка базовых культур.
    PROCEDURE eradicate_species(in_target_species IN species.spec_name%TYPE) IS

        -- local variables
        l_rand_idx            PLS_INTEGER;
        l_rand_spec_no        species.spec_no%TYPE;
        l_target_spec_no      species.spec_no%TYPE;

        -- cursors <2.1+ explicit cursor>
        CURSOR c_crops_to_transfer IS
            SELECT brk_no, spec_no, rsr_result
            FROM crops
            WHERE spec_no = l_target_spec_no
                FOR UPDATE OF spec_no;
        CURSOR c_crops_spec_rsr_res IS
            SELECT spec_no, rsr_result
            FROM crops
            WHERE spec_no <> l_target_spec_no
            ORDER BY 1;

        -- nested tables
        TYPE t_NOT_null_rsr_result_type
            IS TABLE OF crops.spec_no%TYPE;
        TYPE t_null_rsr_result_type
            IS TABLE OF crops.spec_no%TYPE;

        -- type variables
        r_crop_spec_rsr_res   c_crops_spec_rsr_res%ROWTYPE;
        t_NOT_null_res_result t_NOT_null_rsr_result_type := t_NOT_null_rsr_result_type();
        t_null_res_result     t_null_rsr_result_type     := t_null_rsr_result_type();

        -- exceptions
        e_bad_species_name EXCEPTION;
        PRAGMA EXCEPTION_INIT (e_bad_species_name, -20002);

        -- local module
        FUNCTION is_valid_species_type(in_spec_name species.spec_name%TYPE) RETURN BOOLEAN AS
            l_tst PLS_INTEGER;
        BEGIN
            SELECT 1 into l_tst FROM species WHERE spec_name = in_spec_name;
            RETURN TRUE;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                RETURN FALSE;
        END;

    BEGIN
        IF is_valid_species_type(in_target_species) THEN
            SELECT spec_no INTO l_target_spec_no FROM species WHERE spec_name = in_target_species;
            OPEN c_crops_spec_rsr_res;
            LOOP
                FETCH c_crops_spec_rsr_res INTO r_crop_spec_rsr_res;
                EXIT WHEN c_crops_spec_rsr_res%NOTFOUND;
                IF r_crop_spec_rsr_res.rsr_result IS NULL THEN
                    t_null_res_result.EXTEND;
                    t_null_res_result(t_null_res_result.LAST) := r_crop_spec_rsr_res.spec_no;
                ELSE
                    t_NOT_null_res_result.EXTEND;
                    t_NOT_null_res_result(t_NOT_null_res_result.LAST) := r_crop_spec_rsr_res.spec_no;
                END IF;
            END LOOP;
            CLOSE c_crops_spec_rsr_res;
        ELSE
            RAISE e_bad_species_name;
        END IF;
        FOR rec_crop IN c_crops_to_transfer
            LOOP
                IF rec_crop.RSR_RESULT IS NULL THEN
                    l_rand_idx := DBMS_RANDOM.VALUE(t_null_res_result.FIRST, t_null_res_result.LAST);
                    IF l_rand_idx IS NOT NULL THEN
                        l_rand_spec_no := t_null_res_result(l_rand_idx);
                    ELSE
                        l_rand_spec_no := NULL;
                    END IF;
                ELSE
                    l_rand_idx := DBMS_RANDOM.VALUE(t_NOT_null_res_result.FIRST, t_NOT_null_res_result.LAST);
                    IF l_rand_idx IS NOT NULL THEN
                        l_rand_spec_no := t_NOT_null_res_result(l_rand_idx);
                    ELSE
                        l_rand_spec_no := NULL;
                    END IF;
                END IF;
                UPDATE crops SET spec_no = l_rand_spec_no WHERE brk_no = rec_crop.brk_no;
            END LOOP;
        DELETE FROM species WHERE spec_no = l_target_spec_no;
        COMMIT;
    EXCEPTION
        WHEN
            e_bad_species_name THEN
            dbms_output.put_line('Oops! <' || in_target_species || '> is invalid species name!');
            ROLLBACK;
        WHEN
            OTHERS THEN
            dbms_output.put_line('Oops! Something went wrong!');
            dbms_output.put_line('Error code: ' || sqlcode);
            dbms_output.put_line('Error message: ' || sqlerrm);
            ROLLBACK;
    END;
END lab_4;

BEGIN
    dbms_output.put_line(lab_4.gc_task_option);
    dbms_output.put_line(lab_4.gc_task_procedure_description);
    dbms_output.put_line('--------------------------------------------');
    dbms_output.put_line(lab_4.COUNT_EMP_BY(in_edu_type => 'бакалавр'));
    dbms_output.put_line(lab_4.COUNT_EMP_BY(4));

    -- todo: add put_line more
    lab_4.eradicate_species('груша');
END;
