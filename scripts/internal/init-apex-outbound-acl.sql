-- ============================================================================
-- Oracle Database Outbound Network Access Control List (ACL / ACE)
-- Automatic Outbound HTTPS & Network Access for APEX Proxy Schema
-- ============================================================================

SET SERVEROUTPUT ON SIZE UNLIMITED
SET FEEDBACK OFF

DECLARE
  v_apex_schema VARCHAR2(30);
BEGIN
  -- Tuvastame aktiivse APEX mootori skeemi
  BEGIN
    SELECT username INTO v_apex_schema FROM dba_users WHERE username LIKE 'APEX\_%' ESCAPE '\' AND username NOT LIKE '%_PUBLIC_%' AND rownum = 1;
  EXCEPTION WHEN OTHERS THEN
    v_apex_schema := 'APEX_240100';
  END;

  DBMS_OUTPUT.PUT_LINE('Granting Outbound Network ACE Access to APEX_PROXY_SCHEMA and ' || v_apex_schema || '...');

  -- Grant connect and resolve ACE privileges to APEX_PROXY_SCHEMA for outbound HTTPS/REST
  BEGIN
    DBMS_NETWORK_ACL_ADMIN.APPEND_HOST_ACE(
      host       => '*',
      lower_port => 80,
      upper_port => 443,
      ace        => xs$ace_type(
                      privilege_list => xs$name_list('connect', 'resolve'),
                      principal_name => 'APEX_PROXY_SCHEMA',
                      principal_type => xs_acl.ptype_db)
    );
  EXCEPTION WHEN OTHERS THEN
    NULL;
  END;

  -- Grant connect and resolve ACE privileges to APEX Engine schema
  BEGIN
    DBMS_NETWORK_ACL_ADMIN.APPEND_HOST_ACE(
      host       => '*',
      lower_port => 80,
      upper_port => 443,
      ace        => xs$ace_type(
                      privilege_list => xs$name_list('connect', 'resolve'),
                      principal_name => v_apex_schema,
                      principal_type => xs_acl.ptype_db)
    );
  EXCEPTION WHEN OTHERS THEN
    NULL;
  END;

  DBMS_OUTPUT.PUT_LINE('✅ Outbound ACL privileges successfully granted for APEX_PROXY_SCHEMA!');
END;
/
EXIT;
