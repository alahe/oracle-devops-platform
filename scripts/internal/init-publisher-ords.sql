-- ============================================================================
-- Oracle Analytics Publisher ORDS & SQL Developer Web Initialization
-- Enables ORDS REST services and SQL Developer Web for Publisher DB
-- ============================================================================
SET SERVEROUTPUT ON;

DECLARE
  v_count NUMBER;
BEGIN
  -- Enable ORDS REST Services for OAS_CONFIG schema
  SELECT COUNT(*) INTO v_count FROM dba_users WHERE username = 'OAS_CONFIG';
  IF v_count > 0 THEN
    ORDS.ENABLE_SCHEMA(
      p_enabled             => TRUE,
      p_schema              => 'OAS_CONFIG',
      p_url_mapping_type    => 'BASE_PATH',
      p_url_mapping_pattern => 'oas_config',
      p_auto_rest_auth      => FALSE
    );
    DBMS_OUTPUT.PUT_LINE('ORDS REST enabled for schema OAS_CONFIG (path: /ords/oas_config/)');
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('ORDS enablement notice: ' || SQLERRM);
END;
/
COMMIT;
EXIT;
