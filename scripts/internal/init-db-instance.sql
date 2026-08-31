-- ============================================================================
-- Profile-Driven Instance Initialization Script (init-db-instance.sql)
-- Handles Memory Tuning, Tablespaces, Schemas, and Network ACLs based on Profile
-- ============================================================================

ALTER SESSION SET CONTAINER = CDB$ROOT;

-- 1. Memory and Instance Optimization for Free DB Containers (Zero License Risk)
BEGIN
  EXECUTE IMMEDIATE 'ALTER SYSTEM SET sga_target = 768M SCOPE = SPFILE';
  EXECUTE IMMEDIATE 'ALTER SYSTEM SET pga_aggregate_target = 384M SCOPE = SPFILE';
  EXECUTE IMMEDIATE 'ALTER SYSTEM SET control_management_pack_access = ''NONE'' SCOPE = BOTH';
  EXECUTE IMMEDIATE 'ALTER PROFILE DEFAULT LIMIT FAILED_LOGIN_ATTEMPTS UNLIMITED PASSWORD_LIFE_TIME UNLIMITED';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

-- 2. Switch to Pluggable Database FREEPDB1
BEGIN
  EXECUTE IMMEDIATE 'ALTER SESSION SET CONTAINER = FREEPDB1';
  EXECUTE IMMEDIATE 'ALTER PROFILE DEFAULT LIMIT FAILED_LOGIN_ATTEMPTS UNLIMITED PASSWORD_LIFE_TIME UNLIMITED';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

-- 3. Dynamic Profile-Driven Network ACLs for Outbound Proxy (Egress REST/Kafka)
DECLARE
  v_acl_exists NUMBER;
BEGIN
  SELECT COUNT(*) INTO v_acl_exists FROM dba_network_acls WHERE acl LIKE '%apex_proxy%';
  IF v_acl_exists = 0 THEN
    DBMS_NETWORK_ACL_ADMIN.APPEND_HOST_ACE(
      host       => '*',
      lower_port => 1,
      upper_port => 65535,
      ace        => xs$ace_type(
                      privilege_list => xs$name_list('connect', 'resolve'),
                      principal_name => 'APEX_240100',
                      principal_type => xs_acl.ptype_db
                    )
    );
  END IF;
EXCEPTION WHEN OTHERS THEN NULL;
END;
/
