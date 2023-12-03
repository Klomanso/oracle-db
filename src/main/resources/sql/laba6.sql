------------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TYPE input_columns AS TABLE OF VARCHAR2(1000);
------------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TYPE join_st AS OBJECT
(
    join_type      varchar2(100),
    join_table     varchar2(100),
    join_alias     varchar2(100),
    join_condition varchar2(100)
);
------------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TYPE joins IS TABLE OF JOIN_ST;
------------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TYPE from_st AS OBJECT
(
    from_table  varchar2(100),
    table_alias varchar2(100)
);
------------------------------------------------------------------------------------------------------------------------
---------------------------------------------TASK_2---------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

CREATE OR REPLACE PROCEDURE create_new_object(target_object varchar2, target_name varchar2, source_name varchar2,
                                              in_column_list input_columns default input_columns(),
                                              limit_rows number default 0,
                                              drop_exist number default 0) AS
    --
    e_invalid_input_param EXCEPTION;
    PRAGMA exception_init (e_invalid_input_param, -20111);

    --
    result_statement varchar2(4000) := 'CREATE ';

    --
    PROCEDURE drop_object(target varchar2, name varchar2) AS
    BEGIN
        EXECUTE IMMEDIATE 'DROP ' || target || ' ' || name;
        DBMS_OUTPUT.PUT_LINE('drop ' || trim(upper(target)) || ' "' || trim(upper(name)) || '"');
    EXCEPTION
        WHEN OTHERS THEN
            IF sqlcode != -0942 THEN RAISE; END IF;
            DBMS_OUTPUT.PUT_LINE('There was not before ' || trim(upper(target)) || ' "' || trim(upper(name)) ||
                                 '" -> skip object dropping');
    END;

    --
    FUNCTION check_param_2_valid_target_name(in_target_name VARCHAR2) RETURN BOOLEAN AS
        l_tst PLS_INTEGER;
    BEGIN
        WITH exists_schema_names AS (SELECT TABLE_NAME names
                                     FROM ALL_TABLES
                                     WHERE OWNER = 'INSPIRE'
                                     UNION
                                     SELECT VIEW_NAME
                                     FROM ALL_VIEWS
                                     WHERE OWNER = 'INSPIRE')
        SELECT 1
        INTO l_tst
        FROM exists_schema_names
        WHERE names = trim(upper(in_target_name));
        RETURN FALSE;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN TRUE;
    END;

    --
    FUNCTION check_param_3_exists_source_table(in_source_name VARCHAR2) RETURN BOOLEAN AS
        l_tst PLS_INTEGER;
    BEGIN
        SELECT 1 INTO l_tst FROM ALL_TABLES where OWNER = 'INSPIRE' AND TABLE_NAME = TRIM(UPPER(in_source_name));
        RETURN TRUE;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN FALSE;
    END;

    --
    FUNCTION check_param_4_valid_columns(in_table_name varchar2, in_columns input_columns) RETURN BOOLEAN AS
        table_columns   input_columns;
        l_input_columns input_columns := input_columns();
    BEGIN
        IF in_columns.COUNT = 0 THEN
            RETURN TRUE;
        END IF;
        FOR i IN in_columns.FIRST..in_columns.LAST
            LOOP
                l_input_columns.extend;
                l_input_columns(i) := trim(upper(in_columns(i)));
            END LOOP;
        SELECT COLUMN_NAME BULK COLLECT
        INTO table_columns
        FROM ALL_TAB_COLS
        WHERE OWNER = 'INSPIRE'
          AND TABLE_NAME = TRIM(UPPER(in_table_name));
        IF l_input_columns SUBMULTISET OF table_columns THEN
            RETURN TRUE;
        ELSE
            RETURN FALSE;
        END IF;
    END;

    --
    FUNCTION append_columns_to_statement(in_columns input_columns) RETURN varchar2 AS
        result varchar2(1000);
    BEGIN
        IF in_columns.COUNT = 0 THEN
            RETURN '*';
        END IF;
        FOR i IN in_columns.FIRST..in_columns.LAST
            LOOP
                result := result || ', ' || TRIM(UPPER(in_columns(i)));
            END LOOP;
        RETURN substr(result, 3, length(result));
    END;

    --
    FUNCTION append_limit_rows_to_statement(in_rows NUMBER) RETURN VARCHAR2 AS
    BEGIN
        IF in_rows > 0 THEN
            RETURN ' FETCH NEXT ' || TO_CHAR(in_rows) || ' ROWS ONLY';
        ELSE
            RETURN '';
        END IF;
    END;

    --
    PROCEDURE print_statement(source varchar2) AS
        line    varchar2(1000);
        pattern varchar2(1000);
    BEGIN
        FOR i IN 1..length(source)
            LOOP
                line := line || '*';
            END LOOP;
        line := line || '********';
        pattern := substr(line, 2, length(line) - 2);
        DBMS_OUTPUT.PUT_LINE(' ');
        DBMS_OUTPUT.PUT_LINE(line);
        DBMS_OUTPUT.PUT_LINE('*' || replace(pattern, '*', ' ') || '*');
        DBMS_OUTPUT.PUT_LINE('*   ' || source || '   *');
        DBMS_OUTPUT.PUT_LINE('*' || replace(pattern, '*', ' ') || '*');
        DBMS_OUTPUT.PUT_LINE(line);
        DBMS_OUTPUT.PUT_LINE(' ');
    END;

BEGIN
    CASE UPPER(TRIM(target_object))
        WHEN 'TABLE' THEN result_statement := result_statement || 'TABLE ';
        WHEN 'VIEW' THEN result_statement := result_statement || 'VIEW ';
        ELSE raise_application_error(-20111, 'Invalid 1 argument. Must be <TABLE> or <VIEW>.');
        END CASE;
    IF drop_exist = 1 THEN
        drop_object(target_object, target_name);
    END IF;
    IF check_param_2_valid_target_name(target_name) THEN
        result_statement := result_statement || trim(upper(target_name)) || ' ';
    ELSE
        raise_application_error(-20111, 'Invalid 2 argument. Object with such name already exists.');
    END IF;
    IF check_param_3_exists_source_table(source_name) THEN
        result_statement := result_statement || 'AS (SELECT ';
    ELSE
        raise_application_error(-20111, 'Invalid 3 argument. Source table with such name does not exist.');
    END IF;
    IF check_param_4_valid_columns(source_name, in_column_list) THEN
        result_statement :=
                    result_statement || append_columns_to_statement(in_column_list)
                    || ' FROM ' || trim(upper(source_name)) || append_limit_rows_to_statement(limit_rows) || ')';
    ELSE
        raise_application_error(-20111, 'Invalid 4 argument. Source table does not have such columns.');
    END IF;
    print_statement(result_statement);
    EXECUTE IMMEDIATE result_statement;
EXCEPTION
    WHEN
        OTHERS THEN
        dbms_output.put_line('Oops! Something went wrong!');
        dbms_output.put_line('Error code: ' || sqlcode);
        dbms_output.put_line('Error message: ' || sqlerrm);
END;

------------------------------------------------------------------------------------------------------------------------
begin
    CREATE_NEW_OBJECT(
            target_object => 'TABLE',
            target_name => 'res_copy',
            source_name => 'research',
            in_column_list => input_columns('res_id', 'budget', 'lead_no'),
            limit_rows => 0,
            drop_exist => 1);
end;
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
---------------------------------------------TASK_3---------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

CREATE OR REPLACE PROCEDURE get_table_column_info(tab_name varchar2, col_name varchar2) AS

    --
    e_invalid_input_param EXCEPTION;
    PRAGMA exception_init (e_invalid_input_param, -20112);

    --
    stm_total_rec          varchar2(500) := 'SELECT COUNT(*) FROM ';
    stm_total_not_null_rec varchar2(500) := 'SELECT COUNT(TO_CHAR(';
    stm_total_distinct_rec varchar2(500) := 'SELECT COUNT(DISTINCT TO_CHAR(';
    stm_get_column_values  varchar2(500) := 'SELECT DISTINCT TO_CHAR(';

    --
    total_rec              pls_integer;
    total_distinct_rec     pls_integer;
    total_not_null_rec     pls_integer;
    l_columns              input_columns;

    --
    FUNCTION exists_target_table(in_target_table VARCHAR2) RETURN BOOLEAN AS
        l_tst PLS_INTEGER;
    BEGIN
        SELECT 1 INTO l_tst FROM ALL_TABLES where OWNER = 'INSPIRE' AND TABLE_NAME = TRIM(UPPER(in_target_table));
        RETURN TRUE;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN FALSE;
    END;

    --
    FUNCTION valid_column(in_table_name varchar2, in_column varchar2) RETURN BOOLEAN AS
        table_columns input_columns;
    BEGIN
        SELECT COLUMN_NAME BULK COLLECT
        INTO table_columns
        FROM ALL_TAB_COLS
        WHERE OWNER = 'INSPIRE'
          AND TABLE_NAME = TRIM(UPPER(in_table_name));
        IF TRIM(UPPER(in_column)) MEMBER OF table_columns THEN
            RETURN TRUE;
        ELSE
            RETURN FALSE;
        END IF;
    END;

BEGIN
    IF NOT EXISTS_TARGET_TABLE(tab_name) THEN
        raise_application_error(-20112, 'Invalid 1 argument. Target table does not exist.');
    END IF;
    IF NOT VALID_COLUMN(tab_name, col_name) THEN
        raise_application_error(-20112, 'Invalid 2 argument. Target table does not have such column.');
    END IF;
    EXECUTE IMMEDIATE stm_total_rec || TRIM(UPPER(tab_name)) INTO total_rec;
    EXECUTE IMMEDIATE stm_total_not_null_rec || TRIM(UPPER(col_name)) || ')) FROM ' ||
                      TRIM(UPPER(tab_name)) INTO total_not_null_rec;
    EXECUTE IMMEDIATE stm_total_distinct_rec || TRIM(UPPER(col_name)) || ')) FROM ' ||
                      TRIM(UPPER(tab_name)) INTO total_distinct_rec;
    EXECUTE IMMEDIATE stm_get_column_values || TRIM(UPPER(col_name)) || ') FROM ' ||
                      TRIM(UPPER(tab_name)) BULK COLLECT INTO l_columns;
    DBMS_OUTPUT.PUT_LINE('TABLE: ' || TRIM(UPPER(tab_name)) || ' | COLUMN: ' || TRIM(UPPER(col_name)));
    DBMS_OUTPUT.PUT_LINE('COLUMN TOTAL RECORDS: ' || total_rec);
    DBMS_OUTPUT.PUT_LINE('COLUMN TOTAL NOT NULL RECORDS: ' || total_not_null_rec);
    DBMS_OUTPUT.PUT_LINE('COLUMN TOTAL NULL RECORDS: ' || (total_rec - total_not_null_rec));
    DBMS_OUTPUT.PUT_LINE('COLUMN TOTAL DISTINCT NOT NULL RECORDS: ' || total_distinct_rec);
    DBMS_OUTPUT.PUT_LINE('COLUMN VALUES:');
    FOR i IN l_columns.FIRST ..l_columns.LAST
        LOOP
            DBMS_OUTPUT.PUT_LINE(i || ') ' || NVL(l_columns(i), 'NULL'));
        END LOOP;
EXCEPTION
    WHEN
        OTHERS THEN
        dbms_output.put_line('Oops! Something went wrong!');
        dbms_output.put_line('Error code: ' || sqlcode);
        dbms_output.put_line('Error message: ' || sqlerrm);
END;

------------------------------------------------------------------------------------------------------------------------
BEGIN
    GET_TABLE_COLUMN_INFO('res_team', 'res_id');
END;
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
---------------------------------------------TASK_4---------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

CREATE OR REPLACE PROCEDURE reduce_table_into_column(left_table varchar2, right_table varchar2) AS

    --
    e_invalid_input_param EXCEPTION;
    PRAGMA exception_init (e_invalid_input_param, -20113);

    --
    new_collection_type_name   VARCHAR2(300);
    new_table_name             VARCHAR2(300);
    stm_alter_table_add_column VARCHAR2(300);

    --
    TYPE otm_type IS RECORD
                     (
                         PARENT_TABLE varchar2(300),
                         PK_COLUMN    varchar2(300),
                         CHILD_TABLE  VARCHAR2(300),
                         FK_COLUMN    VARCHAR2(300)
                     );
    one_to_many_relationship   otm_type;

    --
    PROCEDURE print_statement(source varchar2) AS
        line    varchar2(1000);
        pattern varchar2(1000);
    BEGIN
        FOR i IN 1..length(source)
            LOOP
                line := line || '*';
            END LOOP;
        line := line || '********';
        pattern := substr(line, 2, length(line) - 2);
        DBMS_OUTPUT.PUT_LINE(' ');
        DBMS_OUTPUT.PUT_LINE(line);
        DBMS_OUTPUT.PUT_LINE('*' || replace(pattern, '*', ' ') || '*');
        DBMS_OUTPUT.PUT_LINE('*   ' || source || '   *');
        DBMS_OUTPUT.PUT_LINE('*' || replace(pattern, '*', ' ') || '*');
        DBMS_OUTPUT.PUT_LINE(line);
        DBMS_OUTPUT.PUT_LINE(' ');
    END;

    --
    FUNCTION exists_target_table(in_target_table VARCHAR2) RETURN BOOLEAN AS
        l_tst PLS_INTEGER;
    BEGIN
        SELECT 1 INTO l_tst FROM ALL_TABLES where OWNER = 'INSPIRE' AND TABLE_NAME = TRIM(UPPER(in_target_table));
        RETURN TRUE;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN FALSE;
    END;

    --
    FUNCTION one_to_many_exists_between(LEFT_TABLE VARCHAR2, RIGHT_TABLE VARCHAR2, OTM IN OUT OTM_TYPE) RETURN BOOLEAN AS
    BEGIN
        WITH CONSTRAINT_DATA AS (SELECT ACC.TABLE_NAME, ACC.COLUMN_NAME, AC.CONSTRAINT_NAME, AC.R_CONSTRAINT_NAME
                                 FROM ALL_CONSTRAINTS AC
                                          INNER JOIN ALL_CONS_COLUMNS ACC ON AC.CONSTRAINT_NAME = ACC.CONSTRAINT_NAME
                                 WHERE AC.OWNER = 'INSPIRE')
        SELECT L.TABLE_NAME PARENT_TABLE, L.COLUMN_NAME PK_COLUMN, R.TABLE_NAME CHILD_TABLE, R.COLUMN_NAME FK_COLUMN
        INTO OTM
        FROM CONSTRAINT_DATA L
                 INNER JOIN CONSTRAINT_DATA R ON L.CONSTRAINT_NAME = R.R_CONSTRAINT_NAME
        WHERE L.TABLE_NAME = TRIM(UPPER(LEFT_TABLE))
          AND R.TABLE_NAME = TRIM(UPPER(RIGHT_TABLE))
            FETCH FIRST ROW ONLY;
        RETURN TRUE;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN FALSE;
    END;

    --
    FUNCTION create_table_collection_type(object_type_name varchar2,
                                          source_table varchar2) RETURN VARCHAR2 AS
        --
        object_type_fields         varchar2(500);
        varchar2_mask              varchar2(100) := 'VARCHAR2(500)';
        stm_create_type            varchar2(500) := 'CREATE OR REPLACE TYPE ' ||
                                                    TRIM(UPPER(object_type_name)) || ' AS OBJECT (';
        stm_create_collection_type varchar2(500) := 'CREATE OR REPLACE TYPE COLLECTION_' ||
                                                    TRIM(UPPER(object_type_name)) ||
                                                    ' IS TABLE OF ' || TRIM(UPPER(object_type_name));
        --
        TYPE col_info IS RECORD
                         (
                             column_name varchar2(500),
                             data_type   varchar2(500)
                         );
        TYPE column_info IS TABLE OF col_info;
        columns_info               column_info;

        --
        PROCEDURE print_statement(source varchar2) AS
            line    varchar2(1000);
            pattern varchar2(1000);
        BEGIN
            FOR i IN 1..length(source)
                LOOP
                    line := line || '*';
                END LOOP;
            line := line || '********';
            pattern := substr(line, 2, length(line) - 2);
            DBMS_OUTPUT.PUT_LINE(' ');
            DBMS_OUTPUT.PUT_LINE(line);
            DBMS_OUTPUT.PUT_LINE('*' || replace(pattern, '*', ' ') || '*');
            DBMS_OUTPUT.PUT_LINE('*   ' || source || '   *');
            DBMS_OUTPUT.PUT_LINE('*' || replace(pattern, '*', ' ') || '*');
            DBMS_OUTPUT.PUT_LINE(line);
            DBMS_OUTPUT.PUT_LINE(' ');
        END;

    BEGIN
        SELECT COLUMN_NAME, DATA_TYPE BULK COLLECT
        INTO columns_info
        FROM ALL_TAB_COLS
        WHERE OWNER = 'INSPIRE'
          AND TABLE_NAME = TRIM(UPPER(source_table));
        FOR i IN columns_info.FIRST..columns_info.LAST
            LOOP
                CASE UPPER(TRIM(columns_info(i).data_type))
                    WHEN 'VARCHAR2' THEN object_type_fields :=
                                object_type_fields || ', ' || columns_info(i).column_name || ' ' || varchar2_mask;
                    WHEN 'CHAR' THEN object_type_fields :=
                                object_type_fields || ', ' || columns_info(i).column_name || ' ' || varchar2_mask;
                    ELSE object_type_fields :=
                                object_type_fields || ', ' || columns_info(i).column_name || ' ' ||
                                columns_info(i).data_type;
                    END CASE;
            END LOOP;
        object_type_fields := substr(object_type_fields, 3, length(object_type_fields)) || ')';
        stm_create_type := stm_create_type || object_type_fields;
        print_statement(stm_create_type);
        EXECUTE IMMEDIATE stm_create_type;
        print_statement(stm_create_collection_type);
        EXECUTE IMMEDIATE stm_create_collection_type;
        RETURN 'COLLECTION_' || TRIM(UPPER(object_type_name));
    END;

    --
    PROCEDURE reduce_child_table(new_tab_name varchar2, new_column_type varchar2, one_to_many otm_type) as

        --
        parent_ids            INPUT_COLUMNS;
        stm_select_parent_ids VARCHAR2(300);
        stm_update_parent_row VARCHAR2(300);

    BEGIN
        stm_select_parent_ids := 'SELECT ' || one_to_many.PK_COLUMN || ' FROM ' || one_to_many.PARENT_TABLE;
        stm_update_parent_row :=
                    'UPDATE ' || new_tab_name || ' SET ' || one_to_many.CHILD_TABLE ||
                    ' = CAST(MULTISET(SELECT * FROM ' ||
                    one_to_many.CHILD_TABLE || ' WHERE ' || one_to_many.FK_COLUMN ||
                    ' = :v) AS ' || new_column_type || ') WHERE ' || one_to_many.PK_COLUMN || ' = :v';
        EXECUTE IMMEDIATE stm_select_parent_ids BULK COLLECT INTO parent_ids;
        FOR i IN parent_ids.FIRST..parent_ids.LAST
            LOOP
                EXECUTE IMMEDIATE stm_update_parent_row USING parent_ids(i), parent_ids(i);
            END LOOP;
    END;

BEGIN
    IF NOT exists_target_table(left_table) THEN
        raise_application_error(-20113, 'Invalid 1 argument. Target table does not exist.');
    END IF;
    IF NOT exists_target_table(right_table) THEN
        raise_application_error(-20113, 'Invalid 2 argument. Target table does not exist.');
    END IF;
    IF one_to_many_exists_between(left_table, right_table, one_to_many_relationship) THEN
        DBMS_OUTPUT.PUT_LINE('PARENT TABLE: ' || one_to_many_relationship.PARENT_TABLE);
        DBMS_OUTPUT.PUT_LINE('CHILD TABLE: ' || one_to_many_relationship.CHILD_TABLE);
    ELSIF one_to_many_exists_between(right_table, left_table, one_to_many_relationship) THEN
        DBMS_OUTPUT.PUT_LINE('PARENT TABLE: ' || one_to_many_relationship.PARENT_TABLE);
        DBMS_OUTPUT.PUT_LINE('CHILD TABLE: ' || one_to_many_relationship.CHILD_TABLE);
    ELSE
        raise_application_error(-20113, 'There isn''t ONE_TO_MANY relationship between tables.');
    END IF;
    new_collection_type_name := CREATE_TABLE_COLLECTION_TYPE(
                'TYPE_' || TO_CHAR(SYS_GUID()), one_to_many_relationship.CHILD_TABLE);
    new_table_name := one_to_many_relationship.PARENT_TABLE || '_' || TO_CHAR(SYS_GUID());
    CREATE_NEW_OBJECT(
            target_object => 'TABLE',
            target_name => new_table_name,
            source_name => one_to_many_relationship.PARENT_TABLE,
            drop_exist => 1);
    stm_alter_table_add_column :=
                'ALTER TABLE ' || new_table_name || ' ADD ' || one_to_many_relationship.CHILD_TABLE || ' ' ||
                new_collection_type_name ||
                ' NESTED TABLE ' || one_to_many_relationship.CHILD_TABLE || ' STORE AS ' ||
                one_to_many_relationship.CHILD_TABLE || TO_CHAR(SYS_GUID());
    print_statement(stm_alter_table_add_column);
    EXECUTE IMMEDIATE stm_alter_table_add_column;
    REDUCE_CHILD_TABLE(new_table_name, new_collection_type_name, one_to_many_relationship);
    COMMIT;
EXCEPTION
    WHEN
        OTHERS THEN
        dbms_output.put_line('Oops! Something went wrong!');
        dbms_output.put_line('Error code: ' || sqlcode);
        dbms_output.put_line('Error message: ' || sqlerrm);
        ROLLBACK;
END;

-----------------------------------------------------------------------------------------------------------------------
BEGIN
    reduce_table_into_column('employees', 'education');
END;
------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------
---------------------------------------------TASK_1---------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

CREATE OR REPLACE PROCEDURE execute_dql(select_st input_columns,
                                        from_st from_st,
                                        join_st joins default null,
                                        where_st varchar2 default null,
                                        group_by_st varchar2 default null,
                                        having_st varchar2 default null,
                                        order_by_st varchar2 default null,
                                        offset_st varchar2 default null,
                                        fetch_st varchar2 default null,
                                        slot_size number default 20) AS
    --
    cursor_id      pls_integer;
    num_of_columns pls_integer;
    row_processed  pls_integer;
    row_idx        pls_integer := 0;
    select_string  varchar2(1000);
    column_val     varchar2(5000);
    fetched_row    varchar2(10000);

    --
    FUNCTION number_of_columns(select_stm input_columns, from_stm varchar2, joins joins) RETURN NUMBER AS
        num         PLS_INTEGER;
        tables_str  varchar2(300);
        select_stmt varchar2(500)
            := 'SELECT COUNT(COLUMN_NAME) FROM ALL_TAB_COLS WHERE OWNER = ''INSPIRE'' AND TABLE_NAME IN (''' ||
               trim(upper(from_stm)) || '''';
    BEGIN
        IF joins IS NOT NULL THEN
            FOR i IN joins.FIRST..joins.LAST
                LOOP
                    tables_str := tables_str || ', ''' || trim(upper(joins(i).JOIN_TABLE)) || '''';
                END LOOP;
            select_stmt := select_stmt || tables_str;
        END IF;
        select_stmt := select_stmt || ')';
        IF select_stm(1) = '*' THEN
            EXECUTE IMMEDIATE select_stmt INTO num;
            RETURN num;
        ELSE
            RETURN select_stm.COUNT;
        END IF;
    END;

    --
    FUNCTION get_column_list(in_columns input_columns) RETURN VARCHAR2 AS
        result varchar2(300);
    BEGIN
        IF in_columns(1) = '*' THEN
            RETURN '*';
        ELSE
            FOR i IN in_columns.FIRST..in_columns.LAST
                LOOP
                    result := result || ', ' || in_columns(i);
                END LOOP;
        END IF;
        RETURN substr(result, 3, length(result));
    END;

    --
    PROCEDURE print_statement(source varchar2) AS
        line    varchar2(1000);
        pattern varchar2(1000);
    BEGIN
        FOR i IN 1..length(source)
            LOOP
                line := line || '*';
            END LOOP;
        line := line || '********';
        pattern := substr(line, 2, length(line) - 2);
        DBMS_OUTPUT.PUT_LINE(' ');
        DBMS_OUTPUT.PUT_LINE(line);
        DBMS_OUTPUT.PUT_LINE('*' || replace(pattern, '*', ' ') || '*');
        DBMS_OUTPUT.PUT_LINE('*   ' || source || '   *');
        DBMS_OUTPUT.PUT_LINE('*' || replace(pattern, '*', ' ') || '*');
        DBMS_OUTPUT.PUT_LINE(line);
        DBMS_OUTPUT.PUT_LINE(' ');
    END;

    --
    FUNCTION print_header(in_columns input_columns, from_table varchar2, join_tables joins,
                          slot_length pls_integer) RETURN NUMBER AS
        l_columns     input_columns;
        result_header varchar2(1000);
        tables_s      varchar2(300);
        select_stmt   varchar2(500)
            := 'SELECT COLUMN_NAME FROM ALL_TAB_COLS WHERE OWNER = ''INSPIRE'' AND TABLE_NAME IN(''' ||
               trim(upper(from_table)) || '''';
    BEGIN
        IF join_tables IS NOT NULL THEN
            FOR i IN join_tables.FIRST..join_tables.LAST
                LOOP
                    tables_s := tables_s || ', ''' || trim(upper(join_tables(i).JOIN_TABLE)) || '''';
                END LOOP;
        END IF;
        select_stmt := select_stmt || tables_s || ')';
        IF in_columns(1) = '*' THEN
            EXECUTE IMMEDIATE select_stmt BULK COLLECT INTO l_columns;
        ELSE
            l_columns := in_columns;
        END IF;
        result_header := '|    ' || rpad(to_char(unistr('\2116')), 6);
        FOR i IN l_columns.FIRST..l_columns.LAST
            LOOP
                result_header := result_header || '|    ' || RPAD(nvl(l_columns(i), 'NULL'), slot_length);
            END LOOP;
        DBMS_OUTPUT.PUT_LINE(result_header || '|');
        RETURN LENGTH(result_header) + 2;
    END;

BEGIN
    num_of_columns := number_of_columns(select_st, from_st.FROM_TABLE, join_st);
    select_string := 'SELECT ' || get_column_list(select_st) || ' FROM '
        || trim(upper(from_st.FROM_TABLE)) || ' ' || trim(upper(from_st.TABLE_ALIAS)) || ' ';
    IF join_st IS NOT NULL THEN
        FOR i IN join_st.FIRST..join_st.LAST
            LOOP
                select_string :=
                            select_string || trim(upper(join_st(i).JOIN_TYPE)) || ' JOIN ' ||
                            trim(upper(join_st(i).JOIN_TABLE)) ||
                            ' ' || trim(upper(join_st(i).JOIN_ALIAS)) || ' ' || join_st(i).JOIN_CONDITION || ' ';
            END LOOP;
    END IF;
    IF where_st IS NOT NULL THEN
        select_string := select_string || 'WHERE ' || where_st || ' ';
    END IF;
    IF group_by_st IS NOT NULL THEN
        select_string := select_string || 'GROUP BY ' || group_by_st || ' ';
    END IF;
    IF having_st IS NOT NULL THEN
        select_string := select_string || 'HAVING ' || having_st || ' ';
    END IF;
    IF order_by_st IS NOT NULL THEN
        select_string := select_string || 'ORDER BY ' || order_by_st || ' ';
    END IF;
    IF offset_st IS NOT NULL THEN
        select_string := select_string || 'OFFSET ' || offset_st || ' ';
    END IF;
    IF fetch_st IS NOT NULL THEN
        select_string := select_string || 'FETCH ' || fetch_st || ' ';
    END IF;
    select_string := trim(select_string);
    print_statement(select_string);
    cursor_id := DBMS_SQL.open_cursor;
    DBMS_SQL.parse(cursor_id, select_string, DBMS_SQL.native);
    FOR i IN 1..num_of_columns
        LOOP
            DBMS_SQL.define_column(cursor_id, i, 'print_column', 2000);
        END LOOP;
    row_processed := DBMS_SQL.EXECUTE(cursor_id);
    IF select_st(1) = '*' AND join_st IS NOT NULL THEN
        print_statement('I can''t guarantee the correct column order');
    ELSE
        DBMS_OUTPUT.PUT_LINE(lpad(' ',
                                  print_header(in_columns => select_st, from_table => from_st.FROM_TABLE,
                                               join_tables => join_st,
                                               slot_length => slot_size), '-'));
    END IF;
    LOOP
        IF DBMS_SQL.fetch_rows(cursor_id) = 0 THEN
            EXIT;
        END IF;
        row_idx := row_idx + 1;
        FOR i IN 1..num_of_columns
            LOOP
                DBMS_SQL.column_value(cursor_id, i, column_val);
                fetched_row := fetched_row || '|    ' || rpad(nvl(column_val, 'NULL'), slot_size);
            END LOOP;
        DBMS_OUTPUT.put_line('|    ' || rpad(row_idx, 6) || fetched_row || '|');
        fetched_row := '';
    END LOOP;
    DBMS_SQL.close_cursor(cursor_id);
EXCEPTION
    WHEN
        OTHERS THEN
        dbms_output.put_line('Oops! Something went wrong!');
        dbms_output.put_line('Error code: ' || sqlcode);
        dbms_output.put_line('Error message: ' || sqlerrm);
END;

-----------------------------------------------------------------------------------------------------------------------
begin
    execute_dql(select_st => input_columns('count(*)'),
                from_st => from_st(from_table => 'research', table_alias => 'r'),
                join_st => joins(join_st(join_type => 'inner', join_table => 'customers', join_alias => 'c',
                                         join_condition => 'on c.ogrn = r.ogrn'),
                                 join_st(join_type => 'left', join_table => 'crops', join_alias => 'cr',
                                         join_condition => 'on cr.rsr_result = r.res_id')),
                slot_size => 20
        );
end;
-----------------------------------------------------------------------------------------------------------------------