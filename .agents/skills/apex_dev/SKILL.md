---
name: apex_dev_sso_troubleshooting
description: Guidelines for APEX developer provisioning, APEX_LANG localization engine, SQLcl split exports, ORDS AutoREST, and Azure Entra-ID SSO integration.
---

# APEX Workspace Management, APEX_LANG Localization & Developer SSO

This skill covers best practices for APEX developer management, runtime multi-language translation via the `APEX_LANG` API, SQLcl split application exports, ORDS AutoREST publishing, and Single Sign-On (SSO / Azure Entra-ID) integration.

---

## 1. APEX_LANG Runtime Localization & Translation Engine

Oracle APEX provides the native `APEX_LANG` PL/SQL package to translate text messages, seed translations, and publish localized application versions:

### 1.1 Dynamic Runtime Message Retrieval
```sql
-- Retrieve localized string for current session language or explicit language code:
l_msg := APEX_LANG.MESSAGE(
    p_name => 'ORDER_CONFIRMED',
    p0     => :P1_ORDER_ID,
    p_lang => 'ET'
);
```

### 1.2 Programmatic Message Provisioning (Shared Components)
```sql
-- Register or update a translatable text message:
APEX_LANG.CREATE_MESSAGE(
    p_application_id => 100,
    p_name           => 'WELCOME_USER',
    p_language       => 'et',
    p_message_text   => 'Tere tulemast süsteemi, %0!'
);
```

### 1.3 Seeding & Publishing Translated Applications
```sql
-- 1. Seed translations from primary language to target language:
APEX_LANG.SEED_TRANSLATIONS(p_application_id => 100, p_language => 'et');

-- 2. Publish the localized application:
APEX_LANG.PUBLISH_APPLICATION(p_application_id => 100, p_language => 'et');

-- 3. Switch active session language:
APEX_UTIL.SET_SESSION_LANG(p_lang => 'et');
```

---

## 2. Developer Account Provisioning (PL/SQL)

### Provisioning in Specific Workspace
```sql
DECLARE
  v_workspace_id NUMBER;
BEGIN
  -- 1. Locate workspace security group ID
  v_workspace_id := APEX_UTIL.find_security_group_id('PROXY_WORKSPACE');
  APEX_UTIL.set_security_group_id(v_workspace_id);
  
  -- 2. Create non-expiring developer account
  APEX_UTIL.create_user(
      p_user_name                    => 'allan.lahe',
      p_email_address                => 'allan@company.com',
      p_web_password                 => 'StrongDevPass2026!',
      p_developer_privs              => 'CREATE:DATA_LOADER:EDIT:HELP:MONITOR:VARIABLE',
      p_account_expiry               => sysdate + 3650,
      p_account_locked               => 'N',
      p_change_password_on_first_use => 'N'
  );
  COMMIT;
END;
/
```

> [!IMPORTANT]
> **Schema Provisioning Invariant (`_oracle_script = FALSE`):**
> When creating application schemas in PDB (`FREEPDB1`), always execute `ALTER SESSION SET "_oracle_script" = FALSE;`. If created with `_oracle_script = TRUE`, Oracle marks them as `ORACLE_MAINTAINED='Y'`, causing APEX to fail with `ORA-20001: Schema name is a reserved schema`.

---

## 3. SQLcl Split Export / Import (Git-Friendly APEX CI/CD)

```bash
# Export APEX application in readable, split format for Git:
sql /@DB_PROXY_DEV <<EOF
apex export -workspaceId 123456789 -applicationId 100 -split -expSupportingObjects Y
EXIT;
EOF
```

---

## 4. ORDS AutoREST & Custom REST Modules

### 4.1 AutoREST Enable a Table
```sql
BEGIN
  ORDS.ENABLE_OBJECT(
      p_enabled        => TRUE,
      p_schema         => 'PROXY_SCHEMA',
      p_object         => 'CUSTOMERS',
      p_object_type    => 'TABLE',
      p_object_alias   => 'customers',
      p_auto_rest_auth => FALSE
  );
  COMMIT;
END;
/
```

### 4.2 Define Custom REST Handler
```sql
BEGIN
  ORDS.DEFINE_MODULE(p_module_name => 'api.v1', p_base_path => 'v1/');
  ORDS.DEFINE_TEMPLATE(p_module_name => 'api.v1', p_pattern => 'orders/:id');
  ORDS.DEFINE_HANDLER(
      p_module_name => 'api.v1',
      p_pattern     => 'orders/:id',
      p_method      => 'GET',
      p_source_type => ORDS.SOURCE_TYPE_COLLECTION_FEED,
      p_source      => 'SELECT * FROM orders WHERE order_id = :id'
  );
  COMMIT;
END;
/
```

---

## 5. SSO Bypass & Lockout Recovery

- **URL Bypass Parameter:** Append `&fsp_sso_login_override=y` to login URL:
  `http://localhost:8088/ords/f?p=4550:1:::&fsp_sso_login_override=y`
- **Emergency DB Reset:**
  ```sql
  ALTER SESSION SET CONTAINER = FREEPDB1;
  BEGIN
      apex_instance_admin.set_parameter('APEX_BUILDER_AUTHENTICATION', 'APEX');
      COMMIT;
  END;
  /
  ```

---

## 6. Automated Verification (`scripts/test-browser-login.sh`)

```bash
# Run automated E2E login and authentication validation:
./scripts/test-browser-login.sh
```

---

## 7. APEX Engine Installation & Troubleshooting Matrix

| Issue / Symptom | Root Cause | Mandatory Architectural Pattern |
| :--- | :--- | :--- |
| **`Enter value for apex_:` prompt** | `apex_rest_config_core.sql` resets SQL*Plus `SET DEFINE '&'`. Comment with `&` is parsed as variable. | Always emit `SET DEFINE OFF;` immediately after vendor scripts and replace `&` with `and` in SQL comments. |
| **`ORA-03114` during recompilation** | `sys.utl_recomp.recomp_parallel` spawns `DBMS_SCHEDULER` jobs that fail TCP listener auth in PDB (`ORA-609`). | Replace parallel recompilation with in-session serial recompilation (`sys.utl_recomp.recomp_serial`). |
| **I/O lock freeze / Datafile resize bottleneck** | Small default `SYSAUX` (480M) triggers 50+ consecutive 10MB auto-extensions. | Pre-allocate `SYSAUX` (2048M), `SYSTEM` (1024M), `UNDOTBS1` (512M) with `AUTOEXTEND ON NEXT 128M` before installation. |
| **`LOADING` state / Incomplete upgrade** | Manual `DROP USER APEX_XXXXXX CASCADE` leaves orphaned `SYS.DBA_REGISTRY` entries. | Never manually drop APEX engine schemas; let `apexins.sql` manage schema upgrades cleanly. |
| **`ORA-01017` on PDB SYS connection** | SYS password not synchronized in `CDB$ROOT` passwordfile (`orapw`). | Sync SYS password in `CDB$ROOT` via local OS authentication (`/ as sysdba`) before TCP connections. |
| **`HTTP 574` / `ORA-01017` on `|default|lo|` pool** | ORDS `default/pool.xml` or custom pool XML contains unexpanded `placeholder` or unquoted heredoc variable. | Use unquoted heredoc (`cat << EOF_POOL`) and ensure entrypoint dynamically syncs `APEX_LISTENER_PWD` into all `/etc/ords/config/databases/*/pool.xml`. |
| **`HTTP 404` on APEX Builder / `apex_admin`** | ORDS `pool.xml` missing PL/SQL gateway enablement. | Explicitly configure `<entry key="plsql.gateway.mode">proxied</entry>` and `<entry key="feature.apex">true</entry>` in all ORDS database pools. |
| **`ORA-12752` Clock Skew Crash** | Pausing database containers (`podman stop`) during background tasks causes VM clock jumps. | Never pause database containers in multi-DB clusters; tune SGA/PGA per instance instead. |

