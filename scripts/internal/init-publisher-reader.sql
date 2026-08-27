-- ============================================================================
-- SQL script: init-publisher-reader.sql
-- Description: Creates the PUBLISHER_READER system user for Oracle Analytics Publisher
-- ============================================================================
SET FEEDBACK ON
SET ECHO ON

DECLARE
    v_count NUMBER;
    v_pwd   VARCHAR2(255) := '&1';
    v_sql   VARCHAR2(1000);
BEGIN
    SELECT COUNT(*) INTO v_count FROM dba_users WHERE username = 'PUBLISHER_READER';
    
    IF v_count = 0 THEN
        v_sql := 'CREATE USER PUBLISHER_READER IDENTIFIED BY "' || v_pwd || '" DEFAULT TABLESPACE USERS TEMPORARY TABLESPACE TEMP QUOTA 50M ON USERS';
        EXECUTE IMMEDIATE v_sql;
        DBMS_OUTPUT.PUT_LINE('✅ Kasutaja PUBLISHER_READER loodud.');
    ELSE
        v_sql := 'ALTER USER PUBLISHER_READER IDENTIFIED BY "' || v_pwd || '" ACCOUNT UNLOCK';
        EXECUTE IMMEDIATE v_sql;
        DBMS_OUTPUT.PUT_LINE('ℹ️ Kasutaja PUBLISHER_READER parool uuendatud.');
    END IF;
    
    EXECUTE IMMEDIATE 'GRANT CREATE SESSION TO PUBLISHER_READER';
    EXECUTE IMMEDIATE 'GRANT SELECT ANY TABLE TO PUBLISHER_READER';
    EXECUTE IMMEDIATE 'GRANT SELECT ANY DICTIONARY TO PUBLISHER_READER';
END;
/
EXIT;
